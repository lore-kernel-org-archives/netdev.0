From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6.26 patch 1/6][NETNS][IPV6] mcast - fix compilation warning when procfs is not compiled in
Date: Thu, 13 Mar 2008 12:46:10 +0100
Message-ID: <20080313114906.630781867@mai.toulouse-stg.fr.ibm.com>
References: <20080313114609.176640638@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:57658 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbYCMLvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 07:51:02 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2DBp1gk111066
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:01 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2DBp1QP1773608
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 12:51:01 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2DBp0Yv010301
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 12:51:01 +0100
Content-Disposition: inline; filename=mcast-fix-procfs-config-no-warning.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_PROC_FS=no, the out_sock_create label is not used because the code
using it is disabled and that leads to a warning at compile time.

This patch fix that by making a specific function to initialize proc for igmp6,
and remove the annoying CONFIG_PROC_FS sections in init/exit function.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/mcast.c |   53 ++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 38 insertions(+), 15 deletions(-)

Index: net-2.6.26/net/ipv6/mcast.c
===================================================================
--- net-2.6.26.orig/net/ipv6/mcast.c
+++ net-2.6.26/net/ipv6/mcast.c
@@ -2633,6 +2633,41 @@ static const struct file_operations igmp
 	.llseek		=	seq_lseek,
 	.release	=	seq_release_net,
 };
+
+static int igmp6_proc_init(struct net *net)
+{
+	int err;
+
+	err = -ENOMEM;
+	if (!proc_net_fops_create(net, "igmp6", S_IRUGO, &igmp6_mc_seq_fops))
+		goto out;
+	if (!proc_net_fops_create(net, "mcfilter6", S_IRUGO,
+				  &igmp6_mcf_seq_fops))
+		goto out_proc_net_igmp6;
+
+	err = 0;
+out:
+	return err;
+
+out_proc_net_igmp6:
+	proc_net_remove(net, "igmp6");
+	goto out;
+}
+
+static void igmp6_proc_exit(struct net *net)
+{
+	proc_net_remove(net, "mcfilter6");
+	proc_net_remove(net, "igmp6");
+}
+#else
+static int igmp6_proc_init(struct net *net)
+{
+	return 0;
+}
+static void igmp6_proc_exit(struct net *net)
+{
+	;
+}
 #endif
 
 static int igmp6_net_init(struct net *net)
@@ -2658,18 +2693,9 @@ static int igmp6_net_init(struct net *ne
 	np = inet6_sk(sk);
 	np->hop_limit = 1;
 
-#ifdef CONFIG_PROC_FS
-	err = -ENOMEM;
-	if (!proc_net_fops_create(net, "igmp6", S_IRUGO, &igmp6_mc_seq_fops))
+	err = igmp6_proc_init(net);
+	if (err)
 		goto out_sock_create;
-	if (!proc_net_fops_create(net, "mcfilter6", S_IRUGO,
-				  &igmp6_mcf_seq_fops)) {
-		proc_net_remove(net, "igmp6");
-		goto out_sock_create;
-	}
-#endif
-
-	err = 0;
 out:
 	return err;
 
@@ -2681,10 +2707,7 @@ out_sock_create:
 static void igmp6_net_exit(struct net *net)
 {
 	sk_release_kernel(net->ipv6.igmp_sk);
-#ifdef CONFIG_PROC_FS
-	proc_net_remove(net, "mcfilter6");
-	proc_net_remove(net, "igmp6");
-#endif
+	igmp6_proc_exit(net);
 }
 
 static struct pernet_operations igmp6_net_ops = {

-- 
