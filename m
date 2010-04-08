From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH] udp: fix for unicast RX path optimization
Date: Thu, 08 Apr 2010 16:56:48 +0200
Message-ID: <4BBDEEB0.7060003@dti2.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:4425 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758728Ab0DHPCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 11:02:14 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v10.1.2)
	with ESMTP id md50008327144.msg
	for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 16:56:50 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Commits 5051ebd275de672b807c28d93002c2fb0514a3c9 and
5051ebd275de672b807c28d93002c2fb0514a3c9 ("ipv[46]: udp: optimize unicast RX
path") broke some programs.

	After upgrading a L2TP server to 2.6.33 it started to fail, tunnels going up an
down, after the 10th tunnel came up. My modified rp-l2tp uses a global
unconnected socket bound to (INADDR_ANY, 1701) and one connected socket per
tunnel after parameter negotiation.

	After ten sockets were open and due to mixed parameters to
udp[46]_lib_lookup2() kernel started to drop packets.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
diff -uNrp linux-2.6.33/net/ipv4/udp.c kernel-netns/net/ipv4/udp.c
--- linux-2.6.33/net/ipv4/udp.c	2010-02-24 19:52:17.000000000 +0100
+++ kernel-netns/net/ipv4/udp.c	2010-04-08 15:07:21.888717449 +0200
@@ -471,8 +471,8 @@ static struct sock *__udp4_lib_lookup(st
 			if (hslot->count < hslot2->count)
 				goto begin;

-			result = udp4_lib_lookup2(net, INADDR_ANY, sport,
-						  daddr, hnum, dif,
+			result = udp4_lib_lookup2(net, saddr, sport,
+						  INADDR_ANY, hnum, dif,
 						  hslot2, slot2);
 		}
 		rcu_read_unlock();
diff -uNrp linux-2.6.33/net/ipv6/udp.c kernel-netns/net/ipv6/udp.c
--- linux-2.6.33/net/ipv6/udp.c	2010-02-24 19:52:17.000000000 +0100
+++ kernel-netns/net/ipv6/udp.c	2010-04-08 15:07:57.081396901 +0200
@@ -258,8 +258,8 @@ static struct sock *__udp6_lib_lookup(st
 			if (hslot->count < hslot2->count)
 				goto begin;

-			result = udp6_lib_lookup2(net, &in6addr_any, sport,
-						  daddr, hnum, dif,
+			result = udp6_lib_lookup2(net, saddr, sport,
+						  &in6addr_any, hnum, dif,
 						  hslot2, slot2);
 		}
 		rcu_read_unlock();

