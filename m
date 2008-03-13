From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6.26 patch 5/6][NETNS][IPV6] udp6 - make proc per namespace
Date: Thu, 13 Mar 2008 12:46:14 +0100
Message-ID: <20080313114937.492112301@mai.toulouse-stg.fr.ibm.com>
References: <20080313114609.176640638@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:25746 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396AbYCMLvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 07:51:39 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m2DBpbAD124792
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:38 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2DBpbwc2040036
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:37 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2DBpan3026793
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:36 GMT
Content-Disposition: inline; filename=udp6-proc-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The proc init/exit functions take a new network namespace parameter
in order to register/unregister /proc/net/udp6 for a namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ipv6.h  |    4 ++--
 include/net/udp.h   |    4 ++--
 net/ipv4/udp.c      |   12 ++++++------
 net/ipv4/udplite.c  |    2 +-
 net/ipv6/af_inet6.c |   19 ++++++++++++-------
 net/ipv6/udp.c      |    8 ++++----
 net/ipv6/udplite.c  |    4 ++--
 7 files changed, 29 insertions(+), 24 deletions(-)

Index: net-2.6.26/net/ipv6/udp.c
===================================================================
--- net-2.6.26.orig/net/ipv6/udp.c
+++ net-2.6.26/net/ipv6/udp.c
@@ -989,13 +989,13 @@ static struct udp_seq_afinfo udp6_seq_af
 	.seq_fops	= &udp6_seq_fops,
 };
 
-int __init udp6_proc_init(void)
+int udp6_proc_init(struct net *net)
 {
-	return udp_proc_register(&udp6_seq_afinfo);
+	return udp_proc_register(net, &udp6_seq_afinfo);
 }
 
-void udp6_proc_exit(void) {
-	udp_proc_unregister(&udp6_seq_afinfo);
+void udp6_proc_exit(struct net *net) {
+	udp_proc_unregister(net, &udp6_seq_afinfo);
 }
 #endif /* CONFIG_PROC_FS */
 
Index: net-2.6.26/include/net/udp.h
===================================================================
--- net-2.6.26.orig/include/net/udp.h
+++ net-2.6.26/include/net/udp.h
@@ -200,8 +200,8 @@ struct udp_iter_state {
 };
 
 #ifdef CONFIG_PROC_FS
-extern int udp_proc_register(struct udp_seq_afinfo *afinfo);
-extern void udp_proc_unregister(struct udp_seq_afinfo *afinfo);
+extern int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo);
+extern void udp_proc_unregister(struct net *net, struct udp_seq_afinfo *afinfo);
 
 extern int  udp4_proc_init(void);
 extern void udp4_proc_exit(void);
Index: net-2.6.26/net/ipv4/udp.c
===================================================================
--- net-2.6.26.orig/net/ipv4/udp.c
+++ net-2.6.26/net/ipv4/udp.c
@@ -1632,7 +1632,7 @@ static int udp_seq_release(struct inode 
 }
 
 /* ------------------------------------------------------------------------ */
-int udp_proc_register(struct udp_seq_afinfo *afinfo)
+int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
 {
 	struct proc_dir_entry *p;
 	int rc = 0;
@@ -1645,7 +1645,7 @@ int udp_proc_register(struct udp_seq_afi
 	afinfo->seq_fops->llseek	= seq_lseek;
 	afinfo->seq_fops->release	= udp_seq_release;
 
-	p = proc_net_fops_create(&init_net, afinfo->name, S_IRUGO, afinfo->seq_fops);
+	p = proc_net_fops_create(net, afinfo->name, S_IRUGO, afinfo->seq_fops);
 	if (p)
 		p->data = afinfo;
 	else
@@ -1653,11 +1653,11 @@ int udp_proc_register(struct udp_seq_afi
 	return rc;
 }
 
-void udp_proc_unregister(struct udp_seq_afinfo *afinfo)
+void udp_proc_unregister(struct net *net, struct udp_seq_afinfo *afinfo)
 {
 	if (!afinfo)
 		return;
-	proc_net_remove(&init_net, afinfo->name);
+	proc_net_remove(net, afinfo->name);
 	memset(afinfo->seq_fops, 0, sizeof(*afinfo->seq_fops));
 }
 
@@ -1709,12 +1709,12 @@ static struct udp_seq_afinfo udp4_seq_af
 
 int __init udp4_proc_init(void)
 {
-	return udp_proc_register(&udp4_seq_afinfo);
+	return udp_proc_register(&init_net, &udp4_seq_afinfo);
 }
 
 void udp4_proc_exit(void)
 {
-	udp_proc_unregister(&udp4_seq_afinfo);
+	udp_proc_unregister(&init_net, &udp4_seq_afinfo);
 }
 #endif /* CONFIG_PROC_FS */
 
Index: net-2.6.26/net/ipv4/udplite.c
===================================================================
--- net-2.6.26.orig/net/ipv4/udplite.c
+++ net-2.6.26/net/ipv4/udplite.c
@@ -105,7 +105,7 @@ void __init udplite4_register(void)
 	inet_register_protosw(&udplite4_protosw);
 
 #ifdef CONFIG_PROC_FS
-	if (udp_proc_register(&udplite4_seq_afinfo)) /* udplite4_proc_init() */
+	if (udp_proc_register(&init_net, &udplite4_seq_afinfo))
 		printk(KERN_ERR "%s: Cannot register /proc!\n", __func__);
 #endif
 	return;
Index: net-2.6.26/net/ipv6/udplite.c
===================================================================
--- net-2.6.26.orig/net/ipv6/udplite.c
+++ net-2.6.26/net/ipv6/udplite.c
@@ -115,11 +115,11 @@ static struct udp_seq_afinfo udplite6_se
 
 int __init udplite6_proc_init(void)
 {
-	return udp_proc_register(&udplite6_seq_afinfo);
+	return udp_proc_register(&init_net, &udplite6_seq_afinfo);
 }
 
 void udplite6_proc_exit(void)
 {
-	udp_proc_unregister(&udplite6_seq_afinfo);
+	udp_proc_unregister(&init_net, &udplite6_seq_afinfo);
 }
 #endif
Index: net-2.6.26/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.26.orig/net/ipv6/af_inet6.c
+++ net-2.6.26/net/ipv6/af_inet6.c
@@ -842,6 +842,8 @@ static void cleanup_ipv6_mibs(void)
 
 static int inet6_net_init(struct net *net)
 {
+	int err = 0;
+
 	net->ipv6.sysctl.bindv6only = 0;
 	net->ipv6.sysctl.flush_delay = 0;
 	net->ipv6.sysctl.ip6_rt_max_size = 4096;
@@ -853,12 +855,20 @@ static int inet6_net_init(struct net *ne
 	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 
-	return 0;
+#ifdef CONFIG_PROC_FS
+	err = udp6_proc_init(net);
+	if (err)
+		goto out;
+out:
+#endif
+	return err;
 }
 
 static void inet6_net_exit(struct net *net)
 {
-	return;
+#ifdef CONFIG_PROC_FS
+	udp6_proc_exit(net);
+#endif
 }
 
 static struct pernet_operations inet6_net_ops = {
@@ -943,8 +953,6 @@ static int __init inet6_init(void)
 		goto proc_raw6_fail;
 	if (tcp6_proc_init())
 		goto proc_tcp6_fail;
-	if (udp6_proc_init())
-		goto proc_udp6_fail;
 	if (udplite6_proc_init())
 		goto proc_udplite6_fail;
 	if (ipv6_misc_proc_init())
@@ -1029,8 +1037,6 @@ proc_anycast6_fail:
 proc_misc6_fail:
 	udplite6_proc_exit();
 proc_udplite6_fail:
-	udp6_proc_exit();
-proc_udp6_fail:
 	tcp6_proc_exit();
 proc_tcp6_fail:
 	raw6_proc_exit();
@@ -1092,7 +1098,6 @@ static void __exit inet6_exit(void)
 	ac6_proc_exit();
 	ipv6_misc_proc_exit();
 	udplite6_proc_exit();
-	udp6_proc_exit();
 	tcp6_proc_exit();
 	raw6_proc_exit();
 #endif
Index: net-2.6.26/include/net/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/ipv6.h
+++ net-2.6.26/include/net/ipv6.h
@@ -597,8 +597,8 @@ extern int  raw6_proc_init(void);
 extern void raw6_proc_exit(void);
 extern int  tcp6_proc_init(void);
 extern void tcp6_proc_exit(void);
-extern int  udp6_proc_init(void);
-extern void udp6_proc_exit(void);
+extern int  udp6_proc_init(struct net *net);
+extern void udp6_proc_exit(struct net *net);
 extern int  udplite6_proc_init(void);
 extern void udplite6_proc_exit(void);
 extern int  ipv6_misc_proc_init(void);

-- 
