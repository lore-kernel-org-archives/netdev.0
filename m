From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [PATCH] udp: Don't save dst in udpv6_sendmsg()
Date: Fri, 23 Oct 2009 16:43:36 +0530
Message-ID: <20091023111336.4733.4901.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:49836 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751786AbZJWLNh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2009 07:13:37 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9NB3kos003436
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 07:03:46 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9NBDfkR086522
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 07:13:41 -0400
Received: from d01av01.pok.ibm.com (d03av01 [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9NBDfxf002171
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 07:13:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Since ip6_datagram_connect saves the dst entry, it is not
required to do the same in every iteration of udpv6_sendmsg.
It also breaks the txq# caching, which then gets updated
every time in dev_pick_tx only to get reset again here.
Update dst only if ip6_sk_dst_lookup changed the dst entry.

Performance: I ran netperf UDPv6 RR to use connected sockets.
Tested with a 70 min run, aggregate of 5 netperf runs for
each result.

------------------------  UDPv6 RR Test  ---------------------
#procs  Org TPS     New TPS (%)       Org SD    New SD (%)
--------------------------------------------------------------
1       119031      118793 (-0.19)      82         77 (-5.23)
2       217572      218607 (0.47)      315        300 (-4.65)
4       258463      258823 (0.13)     1334       1248 (-6.44)
8       318018      319425 (0.44)     5735       5500 (-4.09)
10      395531      401529 (1.51)     9901       9507 (-3.98)
12      453319      453492 (0.03)    15473       15131 (-2.21)
--------------------------------------------------------------

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/ipv6/udp.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -ruNp org/net/ipv6/udp.c new/net/ipv6/udp.c
--- org/net/ipv6/udp.c	2009-10-19 11:58:16.000000000 +0530
+++ new/net/ipv6/udp.c	2009-10-23 10:42:35.000000000 +0530
@@ -990,7 +990,8 @@ do_append_data:
 
 	if (dst) {
 		if (connected) {
-			ip6_dst_store(sk, dst,
+			if (__sk_dst_get(sk) != dst)
+				ip6_dst_store(sk, dst,
 				      ipv6_addr_equal(&fl.fl6_dst, &np->daddr) ?
 				      &np->daddr : NULL,
 #ifdef CONFIG_IPV6_SUBTREES
