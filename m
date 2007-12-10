From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/5] ipv6:  make flowlabel to return an error
Date: Mon, 10 Dec 2007 16:09:11 +0100
Message-ID: <20071210151425.106827965@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:4175 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbXLJPSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 10:18:09 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lBAFI7Jx162114
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:18:07 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBAFI7sg4632666
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:18:07 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBAFHoZl011432
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:17:51 GMT
Content-Disposition: inline; filename=make-ip6-flowlabel-init-return-an-error-code.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the flowlab subsystem to return an error code and makes
some cleanup with procfs ifdefs.
The af_inet6 will use the flowlabel init return code to check the initialization
was correct.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ipv6.h       |    2 +-
 net/ipv6/af_inet6.c      |    5 ++++-
 net/ipv6/ip6_flowlabel.c |   30 +++++++++++++++++++++++-------
 3 files changed, 28 insertions(+), 9 deletions(-)

Index: net-2.6.25/include/net/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/ipv6.h
+++ net-2.6.25/include/net/ipv6.h
@@ -219,7 +219,7 @@ extern struct ipv6_txoptions	*fl6_merge_
 						   struct ipv6_txoptions * fopt);
 extern void			fl6_free_socklist(struct sock *sk);
 extern int			ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen);
-extern void			ip6_flowlabel_init(void);
+extern int			ip6_flowlabel_init(void);
 extern void			ip6_flowlabel_cleanup(void);
 
 static inline void fl6_sock_release(struct ip6_flowlabel *fl)
Index: net-2.6.25/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/af_inet6.c
+++ net-2.6.25/net/ipv6/af_inet6.c
@@ -851,7 +851,9 @@ static int __init inet6_init(void)
 	err = ip6_route_init();
 	if (err)
 		goto ip6_route_fail;
-	ip6_flowlabel_init();
+	err = ip6_flowlabel_init();
+	if (err)
+		goto ip6_flowlabel_fail;
 	err = addrconf_init();
 	if (err)
 		goto addrconf_fail;
@@ -874,6 +876,7 @@ out:
 
 addrconf_fail:
 	ip6_flowlabel_cleanup();
+ip6_flowlabel_fail:
 	ip6_route_cleanup();
 ip6_route_fail:
 #ifdef CONFIG_PROC_FS
Index: net-2.6.25/net/ipv6/ip6_flowlabel.c
===================================================================
--- net-2.6.25.orig/net/ipv6/ip6_flowlabel.c
+++ net-2.6.25/net/ipv6/ip6_flowlabel.c
@@ -692,20 +692,36 @@ static const struct file_operations ip6f
 	.llseek		=	seq_lseek,
 	.release	=	seq_release_private,
 };
-#endif
 
+static int ip6_flowlabel_proc_init(struct net *net)
+{
+	if (!proc_net_fops_create(net, "ip6_flowlabel", S_IRUGO, &ip6fl_seq_fops))
+		return -ENOMEM;
+	return 0;
+}
 
-void ip6_flowlabel_init(void)
+static void ip6_flowlabel_proc_fini(struct net *net)
 {
-#ifdef CONFIG_PROC_FS
-	proc_net_fops_create(&init_net, "ip6_flowlabel", S_IRUGO, &ip6fl_seq_fops);
+	proc_net_remove(net, "ip6_flowlabel");
+}
+#else
+static inline int ip6_flowlabel_proc_init(struct net *net)
+{
+	return 0;
+}
+static inline void ip6_flowlabel_proc_fini(struct net *net)
+{
+	return ;
+}
 #endif
+
+int ip6_flowlabel_init(void)
+{
+	return ip6_flowlabel_proc_init(&init_net);
 }
 
 void ip6_flowlabel_cleanup(void)
 {
 	del_timer(&ip6_fl_gc_timer);
-#ifdef CONFIG_PROC_FS
-	proc_net_remove(&init_net, "ip6_flowlabel");
-#endif
+	ip6_flowlabel_proc_fini(&init_net);
 }

-- 
