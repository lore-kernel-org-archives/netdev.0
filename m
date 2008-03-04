From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 03/12][NETNS][IPV6] route6 - Make proc entry /proc/net/rt6_stats per namespace
Date: Tue, 04 Mar 2008 22:03:29 +0100
Message-ID: <20080304211016.033911301@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:4683 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbYCDVMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:12:54 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m24LCrG1186464
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:53 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LCqLE2031640
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 22:12:52 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LCq1W019353
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:52 GMT
Content-Disposition: inline; filename=route6-make-proc-entry-rt6_stats-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the proc entry /proc/net/rt6_stats work in all network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/route.c |   26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -2353,21 +2353,31 @@ static const struct file_operations ipv6
 
 static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = (struct net *)seq->private;
 	seq_printf(seq, "%04x %04x %04x %04x %04x %04x %04x\n",
-		   init_net.ipv6.rt6_stats->fib_nodes,
-		   init_net.ipv6.rt6_stats->fib_route_nodes,
-		   init_net.ipv6.rt6_stats->fib_rt_alloc,
-		   init_net.ipv6.rt6_stats->fib_rt_entries,
-		   init_net.ipv6.rt6_stats->fib_rt_cache,
+		   net->ipv6.rt6_stats->fib_nodes,
+		   net->ipv6.rt6_stats->fib_route_nodes,
+		   net->ipv6.rt6_stats->fib_rt_alloc,
+		   net->ipv6.rt6_stats->fib_rt_entries,
+		   net->ipv6.rt6_stats->fib_rt_cache,
 		   atomic_read(&ip6_dst_ops.entries),
-		   init_net.ipv6.rt6_stats->fib_discarded_routes);
+		   net->ipv6.rt6_stats->fib_discarded_routes);
 
 	return 0;
 }
 
 static int rt6_stats_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, rt6_stats_seq_show, NULL);
+	struct net *net = get_proc_net(inode);
+	return single_open(file, rt6_stats_seq_show, net);
+}
+
+static int rt6_stats_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct net *net = (struct net *)seq->private;
+	put_net(net);
+	return single_release(inode, file);
 }
 
 static const struct file_operations rt6_stats_seq_fops = {
@@ -2375,7 +2385,7 @@ static const struct file_operations rt6_
 	.open	 = rt6_stats_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = single_release,
+	.release = rt6_stats_seq_release,
 };
 #endif	/* CONFIG_PROC_FS */
 

-- 
