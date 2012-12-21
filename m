From: Hemmo Nieminen <hemmo.nieminen@iki.fi>
Subject: [RFC] Route lost when src address is removed.
Date: Fri, 21 Dec 2012 14:09:53 +0200
Message-ID: <20121221120953.GC15934@fcku.lan>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="mYCpIKhGyMATD0i+"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:42163 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab2LUMJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 07:09:38 -0500
Received: by mail-la0-f49.google.com with SMTP id r15so4808052lag.8
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 04:09:37 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hi,

A route is lost to a subnet, even if it still has addresses
in that subnet.

In normal situations, it seems, a route's source address is the
same as the subnet's primary address and if it gets removed, the
route's source address is updated to be the new primary address.

If, however, the route's source address has been changed to some
other IP address than the primary address, the route is lost
when the source address is removed. This leaves us with IP
addresses in a subnet but no route to that subnet.

I encountered this and was not able to figure out whether this
behaviour is intentional or not? I would sort of expect the
route the be updated to have e.g. the primary address as the new
source address but perhaps not in all cases... What do you
think?

Attached below an example run that should also include all the
information needed to reproduce this.

-- 
Hemmo

--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="route.log"

[root@fcku ~]# ip a s eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:23:54:20:73:3e brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.105/24 brd 192.168.1.255 scope global eth0
    inet6 fe80::223:54ff:fe20:733e/64 scope link 
       valid_lft forever preferred_lft forever
[root@fcku ~]# ip a a 1.1.1.1/24 dev eth0
[root@fcku ~]# ip a a 1.1.1.2/24 dev eth0
[root@fcku ~]# ip a a 1.1.1.3/24 dev eth0
[root@fcku ~]# ip a s eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:23:54:20:73:3e brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.105/24 brd 192.168.1.255 scope global eth0
    inet 1.1.1.1/24 scope global eth0
    inet 1.1.1.2/24 scope global secondary eth0
    inet 1.1.1.3/24 scope global secondary eth0
    inet6 fe80::223:54ff:fe20:733e/64 scope link 
       valid_lft forever preferred_lft forever
[root@fcku ~]# ip r s
default via 192.168.1.1 dev eth0  metric 202 
1.1.1.0/24 dev eth0  proto kernel  scope link  src 1.1.1.1 
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.105  metric 202 
[root@fcku ~]# ip r replace 1.1.1.0/24 dev eth0  proto kernel  scope link  src 1.1.1.2
[root@fcku ~]# ip r s
default via 192.168.1.1 dev eth0  metric 202 
1.1.1.0/24 dev eth0  proto kernel  scope link  src 1.1.1.2 
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.105  metric 202 
[root@fcku ~]# ip a d 1.1.1.2/24 dev eth0
[root@fcku ~]# ip a s eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:23:54:20:73:3e brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.105/24 brd 192.168.1.255 scope global eth0
    inet 1.1.1.1/24 scope global eth0
    inet 1.1.1.3/24 scope global secondary eth0
    inet6 fe80::223:54ff:fe20:733e/64 scope link 
       valid_lft forever preferred_lft forever
[root@fcku ~]# ip r s
default via 192.168.1.1 dev eth0  metric 202 
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.105  metric 202 
[root@fcku ~]# uname -a
Linux fcku 3.6.10-1-ARCH #1 SMP PREEMPT Tue Dec 11 09:40:17 CET 2012 x86_64 GNU/Linux
[root@fcku ~]# ip -V
ip utility, iproute2-ss121001
[root@fcku ~]# 

--mYCpIKhGyMATD0i+--
