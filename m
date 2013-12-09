From: "Asano, Yasushi" <yasushi.asano@jp.fujitsu.com>
Subject: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime state-changing
 behavior while valid_lft is infinity
Date: Mon, 9 Dec 2013 05:54:37 +0000
Message-ID: <4AE7B88EC8BA74469869BB7EEB7D66671BF656D2@g01jpexmbyt23>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:46708 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124Ab3LIFyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 00:54:43 -0500
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A0BB23EE15A
	for <netdev@vger.kernel.org>; Mon,  9 Dec 2013 14:54:40 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9384B45DEBA
	for <netdev@vger.kernel.org>; Mon,  9 Dec 2013 14:54:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.nic.fujitsu.com [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AFBB45DEB5
	for <netdev@vger.kernel.org>; Mon,  9 Dec 2013 14:54:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D93DE08001
	for <netdev@vger.kernel.org>; Mon,  9 Dec 2013 14:54:40 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FABF1DB8038
	for <netdev@vger.kernel.org>; Mon,  9 Dec 2013 14:54:40 +0900 (JST)
Received: from localhost.localdomain (localhost [127.0.0.1])
	by g01jpfmpwyt01.exch.g01.fujitsu.local (Postfix) with ESMTP id E1D986D6485
	for <netdev@vger.kernel.org>; Mon,  9 Dec 2013 14:54:39 +0900 (JST)
Received: from g01jpexchyt35.g01.fujitsu.local (unknown [10.128.193.4])
	by g01jpfmpwyt01.exch.g01.fujitsu.local (Postfix) with ESMTP id B5CD26D64E4
	for <netdev@vger.kernel.org>; Mon,  9 Dec 2013 14:54:38 +0900 (JST)
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from: Yasushi Asano  <yasushi.asano@jp.fujitsu.com>

There is a problem when setting the lifetime of an IPv6 address.
When I set preferred_lft to a value not zero or infinity, while valid_lft is infinity(0xffffffff)
preferred lifetime is set to forever and does not update.
Therefore preferred lifetime never becomes deprecated.

I think valid lifetime and preferred lifetime should be set independently,
even if valid lifetime is infinity, preferred lifetime must expire correctly (meaning it must eventually become deprecated)

I made a patch for 3.12 stable to solve the problem.

< console log before patching >
using the ip addr command to verify the problem
------------------------------------------------------------------------------------------------------------
# # ip addr add 2002:100:10:1::100/64 dev eth1 valid_lft 0xffffffff preferred_lft 20
# # ip addr show eth1

3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
link/ether 00:04:9f:02:00:5e brd ff:ff:ff:ff:ff:ff
inet 192.168.0.101/24 brd 192.168.0.255 scope global eth1
inet6 2002:100:10:1::100/64 scope global       <----- The address doesn't become deprecated after 20seconds.
valid_lft forever preferred_lft forever        <----- preferred_lft becomes forever instead of 20seconds.
inet6 fe80::204:9fff:fe02:5e/64 scope link            Therefore lifetime(preferred_lft) is not updating.
valid_lft forever preferred_lft forever
------------------------------------------------------------------------------------------------------------

< console log after patching >
using the ip addr command to verify it runs correctly
------------------------------------------------------------------------------------------------------------
# ifconfig eth1 192.168.0.101 netmask 255.255.255.0
# ip addr add 2002:100:10:1::100/64 dev eth1 valid_lft 0xffffffff preferred_lft 20
# ip addr show eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:04:9f:02:00:5e brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.101/24 brd 192.168.0.255 scope global eth1
    inet6 2002:100:10:1::100/64 scope global dynamic   <------------- "global dynamic"
       valid_lft forever preferred_lft 16sec           <--------------it begins counting down from 20seconds
    inet6 fe80::204:9fff:fe02:5e/64 scope link
       valid_lft forever preferred_lft forever
# ip addr show eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:04:9f:02:00:5e brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.101/24 brd 192.168.0.255 scope global eth1
    inet6 2002:100:10:1::100/64 scope global dynamic   <------------ "global dynamic"
       valid_lft forever preferred_lft 11sec           <------------ it continues counting down. 
    inet6 fe80::204:9fff:fe02:5e/64 scope link
       valid_lft forever preferred_lft forever
# ip addr show eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:04:9f:02:00:5e brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.101/24 brd 192.168.0.255 scope global eth1
    inet6 2002:100:10:1::100/64 scope global deprecated dynamic <- "deprecated dynamic"
       valid_lft forever preferred_lft 0sec            <----------- it expired because it became zero seconds and it changed to "deprecated".
    inet6 fe80::204:9fff:fe02:5e/64 scope link
       valid_lft forever preferred_lft forever
#

------------------------------------------------------------------------------------------------------------
net/ipv6/addrconf.c | 8 +++++---
1 file changed, 5 insertions(+), 3 deletions(-)


diff -buprNE a/net/ipv6/addrconf.c b-1/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2012-06-13 09:40:27.000000000 +0900
+++ b-1/net/ipv6/addrconf.c	2013-11-08 12:00:59.107840672 +0900
@@ -755,6 +755,7 @@ static void ipv6_del_addr(struct inet6_i
 					if (!onlink)
 						onlink = -1;
 
+					if (ifp->valid_lft != INFINITY_LIFE_TIME) {
 					spin_lock(&ifa->lock);
 
 					lifetime = addrconf_timeout_fixup(ifa->valid_lft, HZ);
@@ -771,6 +772,7 @@ static void ipv6_del_addr(struct inet6_i
 			}
 		}
 	}
+	}
 	write_unlock_bh(&idev->lock);
 
 	addrconf_del_timer(ifp);
@@ -2137,7 +2139,6 @@ static int inet6_addr_add(struct net *ne
 	} else {
 		expires = 0;
 		flags = 0;
-		ifa_flags |= IFA_F_PERMANENT;
 	}
 
 	timeout = addrconf_timeout_fixup(prefered_lft, HZ);
@@ -3177,9 +3178,11 @@ restart:
 					ifp->flags |= IFA_F_DEPRECATED;
 				}
 
+
+				if (ifp->valid_lft != INFINITY_LIFE_TIME) {
 				if (time_before(ifp->tstamp + ifp->valid_lft * HZ, next))
 					next = ifp->tstamp + ifp->valid_lft * HZ;
-
+				}
 				spin_unlock(&ifp->lock);
 
 				if (deprecate) {
@@ -3309,7 +3312,6 @@ static int inet6_addr_modify(struct inet
 	} else {
 		expires = 0;
 		flags = 0;
-		ifa_flags |= IFA_F_PERMANENT;
 	}
 
 	timeout = addrconf_timeout_fixup(prefered_lft, HZ);


