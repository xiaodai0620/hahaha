#!/bin/bash
date=`date +%F-%T`
name=$USER
ips=`ip a | awk -F " " 'NR==9 {print $2}'`
hostname=`hostname`
CPU=`df -Th | sed -r -n '1,2p'`
CPUFUZAI=`uptime | awk 'NR==1{print $8,$9,$10}'`
echo "**用户名：$name"
echo "**当前主机名:$hostname"
echo "**IP地址：$ips"
echo "**当前时间为：$date"
echo "**CPU平均负载为：$CPUFUZAI"
echo "**磁盘使用率：
$CPU"
echo "=======================nginx============================="
netstat -tanlp | grep nginx
if [ $? -eq 0 ]
then
        echo "nginx 已经启动"
else
        echo "nginx 没有启动"
fi
echo "=======================mysql============================="
netstat -tanlp | grep mysql &> /dev/null
if [ $? -eq 0 ]
then
        echo "mysql 已经启动"
else
        echo "mysql 没有启动"
fi
menu (){
cat <<EOF
	    ==================================
	    |      1.配置WEB服务             |
	    |      2.配置MYSQL服务           |
	    |      3.配置Network服务         |
	    |      4.更改密码                |
	    |      5.配置YUM                 |
	    |      6.关闭并开机关闭防火墙    |
	    |      7.清空当前内存缓存        |
	    |      8.退出                    |
	    ==================================
EOF
}
menua (){
cat <<EOF
	==========================
	|     1-1启动WEB服务     |
	|     1-2停止WEB服务	 |
	|     1-3重启WEB服务	 |
	|     1-4返回上一级	 |
	==========================
EOF
}
menub (){
cat <<EOF
        ==========================
        |     1-1启动MYSQL   	 |
        |     1-2停止MYSQL    	 |
        |     1-3重启MYSQL       |
        |     1-4返回上一级      |
        ==========================
EOF
}
while :
do	
	menu
	read -p "请选择你的服务选项: "  num
	case $num in
	  1)#配置WEB服务
		echo "系统正在加载，请耐心等待"
		yum -y install nginx &> /dev/null
		if [ $? -eq 0 ]
		then
		echo "web服务nginx已配置完成"
		   while :
		   do
		    menua
		   read -p "请选择你的web服务选项: " numb
		   case $numb in
		   1)#启动WEB服务
			systemctl start nginx
			if [ $? -eq 0 ]
			then
				echo "nginx 已启动服务"
			else
				echo "请手工检查"
			fi
		   ;;
		   2)#停止WEB服务
			systemctl stop nginx
		 	if [ $? -eq 0 ]
                	then
                        	echo "nginx 已停止服务"
                	else
                        	echo "请手工检查"
			fi
		   ;;
		   3)#重启WEB服务
			systemctl restart  nginx
			if [ $? -eq 0 ]
                	then
                        	echo "nginx 已重启服务"
                	else
                        	echo "请手工检查"
			fi
		   ;;
		   4)#返回上一级
			break
		   ;;
		   *)
			echo "请输入正确的服务选项"
		   ;;
		   esac
			done
		else
			echo "请检查yum源"
		fi
	  ;;
	  2) #配置MYSQL服务
		echo "系统正在加载，请耐心等待"
		yum -y install mariadb && yum -y install mariadb-server &> /dev/null
		if [ $? -eq 0 ]
		then
			echo "mysql安装成功"
			while :
                	do
                   	menub
                	read -p "请选择你的MYSQL服务选项: " numbe
                	case $numbe in
                	1)#启动WEB服务
				systemctl start mariadb
                		if [ $? -eq 0 ]
                		then
                        		echo "mysql 已启动服务"
                		else
                        		echo "请手工检查"
                		fi
                	;;
                	2)#停止WEB服务
				systemctl stop mariadb
                 		if [ $? -eq 0 ]
                		then
                        		echo "mysql 已停止服务"
                		else
                        		echo "请手工检查"
				fi 
                	;;
                	3)#重启WEB服务
				 systemctl restart  mariadb
                		if [ $? -eq 0 ]
                		then
                        		echo "mysql 已重启服务"
                		else
                        		echo "请手工检查"
	       			fi 
                	;;
                	4)#返回上一级
				break
                	;;
                	*)
                        echo "请输入正确的服务选项"
                	;;
                	esac
                    done
		else 
			echo "请检查yum源"
		fi
	  ;;
	  3)#配置Network服务
		read -p "请输入你要指定的网关： "  gw
		read -p "请输入你要制定的IP ：  "  my_ip
			echo "正在配置网络......."
		cat > /etc/sysconfig/network-scripts/ifcfg-ens33  <<-EOF
		TYPE="Ethernet"
		BOOTPROTO="none"
		DEVICE="ens33"
		ONBOOT="yes"
		IPADDR=$my_ip
		PREFIX=24
		GATEWAY=$gw
		DNS1=114.114.114.114
		EOF
		systemctl stop NetworkManager &>/dev/null
		systemctl restart network &>/dev/null
		if [ $? -eq 0 ]
		then
			echo "网络配置完成！"
		else
		echo "配置错误！....请检查环境后在进行配置！"
		fi
	  ;;
	  4)#更改密码
		passwd
	  ;;
	  5)#配置yum源
		yum clean all
		yum make cache
		if [ $? -eq 0 ]
		then
			echo "已有yum源，不用再安装"
		else 
			cd /etc/yum.repos.d && mkdir ./bak && mv *.repo ./bak && curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && yum clean all && yum makecache && yum -y install epel-release && yum makecache
			if [$? -eq 0]
			then 
				echo "yum源已成功安装"
			else
				echo "请检查你的网络或出现其他问题"
			fi
		fi

	  ;;
	  6)#关闭防火墙及开机关闭防火墙、selinux
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
		setenforce 0 &>/dev/null
		systemctl stop firewalld &>/dev/null
		systemctl disable firewalld &>/dev/null
		echo "防火墙与selinux均已经关闭！"
	  ;;
	  7)#清理缓存
		echo 3 > /proc/sys/vm/drop_caches
		echo "缓存已清理"
	  ;;
	  8)#退出	
		exit 0
	  ;;
	  *)
		echo "请输入正确的选项"
	  ;;
	esac
done
