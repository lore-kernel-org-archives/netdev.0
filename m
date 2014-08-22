From: "Fedor Babkin" <fedor.babkin@gmx.net>
Subject: Routes with unreachable gateways are staying in the routing table
 and they are functional
Date: Fri, 22 Aug 2014 17:11:29 +0200
Message-ID: <trinity-f1954363-c4ef-47d2-9508-7174b7e2501e-1408720289787@3capp-gmx-bs15>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:60960 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932120AbaHVPLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Aug 2014 11:11:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I noticed that in case a network interface has two addresses assigned (no matter if IPv4 or IPv6) from subnets A and B, the route to reach subnet C via the gateway in A is staying configured and functional when subnet A is removed from the interface. Let me illustrate the behavior with IPv4 example.

Starting point. eth0 has 2 subnets, the route to reach 3-rd subnet via gw in one of them is present:
eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:12:34:57 brd ff:ff:ff:ff:ff:ff
    inet 10.20.10.3/24 brd 10.20.10.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 10.30.10.3/24 brd 10.30.10.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe12:3457/64 scope link
       valid_lft forever preferred_lft forever
root@ubuntu14-4-vm:~# ip ro ls
10.11.10.0/24 via 10.30.10.1 dev eth0
10.20.10.0/24 dev eth0  proto kernel  scope link  src 10.20.10.3
10.30.10.0/24 dev eth0  proto kernel  scope link  src 10.30.10.3

Delete 10.30.10.3/24, the indirect route persists:
root@ubuntu14-4-vm:~# ip ro ls
10.11.10.0/24 via 10.30.10.1 dev eth0
10.20.10.0/24 dev eth0  proto kernel  scope link  src 10.20.10.3

Ping to destinations in 10.11.10.0/24 works, unreachable gateway 10.30.10.1 is resolved, even recovers in case of neighbor flushes.
root@ubuntu14-4-vm:~# ping 10.11.10.1
PING 10.11.10.1 (10.11.10.1) 56(84) bytes of data.
64 bytes from 10.11.10.1: icmp_seq=1 ttl=64 time=0.706 ms
root@ubuntu14-4-vm:~# ip n l
10.30.10.1 dev eth0 lladdr 52:54:00:12:34:56 REACHABLE

The above was observed with kernel version 2.6.32 and confirmed with 3.13.0 In case of IPv6 this behavior is more disturbing as there is always LLA assigned, so applications have to orchestrate the removal of unreachable routes. 
If it's an intended implementation, would be helpful to know a reason behind it. Thanks for your support.

Regards,
Fedor
