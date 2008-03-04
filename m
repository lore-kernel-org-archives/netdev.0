From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 12/12][NETNS][IPV6] route6 - Make ip6_dst_gc simpler
Date: Tue, 04 Mar 2008 22:03:38 +0100
Message-ID: <20080304211044.458249424@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:10817 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831AbYCDVN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:13:27 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m24LDQYC382366
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:26 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LDQEO2031716
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 22:13:26 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LDP2i015208
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:25 GMT
Content-Disposition: inline; filename=route6-make-ip6_dst_gc-simpler.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches improves the readibility of the ip6_dst_gc() routine.
It simplifies long lines which grow a lot due to the introduction
of network namespaces support.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/route.c |   20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -992,22 +992,26 @@ int icmp6_dst_gc(int *more)
 
 static int ip6_dst_gc(struct dst_ops *ops)
 {
-	struct net *net = ops->dst_net;
 	unsigned long now = jiffies;
+	struct net *net = ops->dst_net;
+	int rt_min_interval = net->ipv6.sysctl.ip6_rt_gc_min_interval;
+	int rt_max_size = net->ipv6.sysctl.ip6_rt_max_size;
+	int rt_elasticity = net->ipv6.sysctl.ip6_rt_gc_elasticity;
+	int rt_gc_timeout = net->ipv6.sysctl.ip6_rt_gc_timeout;
+	unsigned long rt_last_gc = net->ipv6.ip6_rt_last_gc;
 
-	if (time_after(net->ipv6.ip6_rt_last_gc + net->ipv6.sysctl.ip6_rt_gc_min_interval, now) &&
-	    atomic_read(&net->ipv6.ip6_dst_ops->entries) <= net->ipv6.sysctl.ip6_rt_max_size)
+	if (time_after(rt_last_gc + rt_min_interval, now) &&
+	    atomic_read(&ops->entries) <= rt_max_size)
 		goto out;
 
 	net->ipv6.ip6_rt_gc_expire++;
 	fib6_run_gc(net->ipv6.ip6_rt_gc_expire, net);
 	net->ipv6.ip6_rt_last_gc = now;
-	if (atomic_read(&net->ipv6.ip6_dst_ops->entries) < net->ipv6.ip6_dst_ops->gc_thresh)
-		net->ipv6.ip6_rt_gc_expire = net->ipv6.sysctl.ip6_rt_gc_timeout>>1;
-
+	if (atomic_read(&ops->entries) < ops->gc_thresh)
+		net->ipv6.ip6_rt_gc_expire = rt_gc_timeout>>1;
 out:
-	net->ipv6.ip6_rt_gc_expire -= net->ipv6.ip6_rt_gc_expire>>net->ipv6.sysctl.ip6_rt_gc_elasticity;
-	return (atomic_read(&net->ipv6.ip6_dst_ops->entries) > net->ipv6.sysctl.ip6_rt_max_size);
+	net->ipv6.ip6_rt_gc_expire -= net->ipv6.ip6_rt_gc_expire>>rt_elasticity;
+	return (atomic_read(&ops->entries) > rt_max_size);
 }
 
 /* Clean host part of a prefix. Not necessary in radix tree,

-- 
