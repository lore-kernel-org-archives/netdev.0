From: Jon DeVree <jadevree@mtu.edu>
Subject: address pingable with interface down
Date: Wed, 10 May 2006 15:48:18 -0400
Message-ID: <20060510194818.GB4460@junkers.homelinux.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Return-path: <netdev-owner@vger.kernel.org>
Received: from node7.mtu.edu ([141.219.69.7]:17341 "EHLO node7.mtu.edu")
	by vger.kernel.org with ESMTP id S1751498AbWEJTs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 15:48:27 -0400
Received: from node6.edge.dcsint.mtu.edu (node6.mtu.edu [141.219.69.6])
	by node7.mtu.edu (8.13.1/8.13.1) with ESMTP id k4AJmRXF008767
	for <netdev@vger.kernel.org>; Wed, 10 May 2006 15:48:27 -0400
Received: from node34.edge.dcsint.mtu.edu (node34.mtu.edu [141.219.69.34])
	by node6.edge.dcsint.mtu.edu (8.12.11.20060308/8.12.8) with ESMTP id k4AJmRRf014884
	for <netdev@vger.kernel.org>; Wed, 10 May 2006 15:48:27 -0400
Received: from mail.mtu.edu (campus4.mtu.edu [141.219.70.4])
	by node34.edge.dcsint.mtu.edu (8.12.11/8.12.11) with ESMTP id k4AJmQd1031847
	for <netdev@vger.kernel.org>; Wed, 10 May 2006 15:48:26 -0400
	(envelope-from jon787@junkers.homelinux.net)
Received: from node6.edge.dcsint.mtu.edu (node6.mtu.edu [141.219.69.6])
	by mail.mtu.edu (8.13.6/8.11.6) with ESMTP id k4AJmP9F004774
	for <netdev@vger.kernel.org>; Wed, 10 May 2006 15:48:26 -0400 (EDT)
Received: from junkers.setec ([64.241.37.140])
	(authenticated bits=0)
	by node6.edge.dcsint.mtu.edu (8.12.11.20060308/8.12.3/auth_ssl.mc v1.0) with ESMTP id k4AJmJp7014829
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 10 May 2006 15:48:25 -0400
Received: from jon787 by junkers.setec with local (Exim 4.62)
	(envelope-from <jon787@junkers.homelinux.net>)
	id 1FdufT-0001IU-FH
	for netdev@vger.kernel.org; Wed, 10 May 2006 15:48:19 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

I've noticed in the past that the address owned by an interface is still
pingable after that interface is brought down. This appears to be
because the routing table entry for the address itself is never removed
when the interface is brought down. I'm curious if this is desired
behavior or if this is a bug. I've managed to patch my kernel to remove
the leftover entry and it doesn't seem to have any ill effects but I
haven't tried any of the more advanced routing setups with it this way.

Attached is one possible patch. Its a simple one, not the best one
because like I said, I don't know if this was the desired behavior or
not. If this is the desired behavior I'm curious why.

Steps to reproduce:
# ip route show table 0 dev eth0
# ifconfig eth0 1.2.3.4
# ip route show table 0 dev eth0
1.0.0.0/8  proto kernel  scope link  src 1.2.3.4 
broadcast 1.0.0.0  table local  proto kernel  scope link  src 1.2.3.4 
local 1.2.3.4  table local  proto kernel  scope host  src 1.2.3.4 
broadcast 1.255.255.255  table local  proto kernel  scope link  src 1.2.3.4
# ifconfig eth0 down
# ip route show table 0 dev eth0
local 1.2.3.4  table local  proto kernel  scope host  src 1.2.3.4
# ping -c 1 1.2.3.4
PING 1.2.3.4 (1.2.3.4) 56(84) bytes of data.
64 bytes from 1.2.3.4: icmp_seq=1 ttl=64 time=0.104 ms

--- 1.2.3.4 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.104/0.104/0.104/0.000 ms


I asked on LKML about this when I first noticed it but didn't get an
answer, so I figured I'd try the more specific mailing list.
-- 
Jon
X(7x): A program for managing terminals. See also screen(1).

--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="fib_disable_ip.diff"

--- linux-2.6.13.2-clean/net/ipv4/fib_frontend.c	2006-05-10 15:36:14.000000000 -0400
+++ linux-2.6.13.2/net/ipv4/fib_frontend.c	2006-05-10 15:36:25.000000000 -0400
@@ -629,7 +629,7 @@
 		rt_cache_flush(-1);
 		break;
 	case NETDEV_DOWN:
-		fib_disable_ip(dev, 0);
+		fib_disable_ip(dev, 1);
 		break;
 	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGE:

--HlL+5n6rz5pIUxbD--
