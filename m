From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6.26 patch 6/6][NETNS][IPV6] tcp6 - make proc per namespace
Date: Thu, 13 Mar 2008 12:46:15 +0100
Message-ID: <20080313114948.342020574@mai.toulouse-stg.fr.ibm.com>
References: <20080313114609.176640638@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:47601 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbYCMLvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 07:51:44 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2DBphCc086836
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:43 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2DBph1L647364
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 12:51:43 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2DBpg9R011191
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 12:51:42 +0100
Content-Disposition: inline; filename=tcp6-proc-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the proc for tcp6 to be per namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ipv6.h  |    4 ++--
 include/net/tcp.h   |    4 ++--
 net/ipv4/tcp_ipv4.c |   12 ++++++------
 net/ipv6/af_inet6.c |   15 ++++++++++-----
 net/ipv6/tcp_ipv6.c |    8 ++++----
 5 files changed, 24 insertions(+), 19 deletions(-)

Index: net-2.6.26/include/net/tcp.h
===================================================================
--- net-2.6.26.orig/include/net/tcp.h
+++ net-2.6.26/include/net/tcp.h
@@ -1336,8 +1336,8 @@ struct tcp_iter_state {
 	struct seq_operations	seq_ops;
 };
 
-extern int tcp_proc_register(struct tcp_seq_afinfo *afinfo);
-extern void tcp_proc_unregister(struct tcp_seq_afinfo *afinfo);
+extern int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo);
+extern void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo);
 
 extern struct request_sock_ops tcp_request_sock_ops;
 extern struct request_sock_ops tcp6_request_sock_ops;
Index: net-2.6.26/net/ipv6/tcp_ipv6.c
===================================================================
--- net-2.6.26.orig/net/ipv6/tcp_ipv6.c
+++ net-2.6.26/net/ipv6/tcp_ipv6.c
@@ -2129,14 +2129,14 @@ static struct tcp_seq_afinfo tcp6_seq_af
 	.seq_fops	= &tcp6_seq_fops,
 };
 
-int __init tcp6_proc_init(void)
+int tcp6_proc_init(struct net *net)
 {
-	return tcp_proc_register(&tcp6_seq_afinfo);
+	return tcp_proc_register(net, &tcp6_seq_afinfo);
 }
 
-void tcp6_proc_exit(void)
+void tcp6_proc_exit(struct net *net)
 {
-	tcp_proc_unregister(&tcp6_seq_afinfo);
+	tcp_proc_unregister(net, &tcp6_seq_afinfo);
 }
 #endif
 
Index: net-2.6.26/include/net/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/ipv6.h
+++ net-2.6.26/include/net/ipv6.h
@@ -595,8 +595,8 @@ extern int  ac6_proc_init(void);
 extern void ac6_proc_exit(void);
 extern int  raw6_proc_init(void);
 extern void raw6_proc_exit(void);
-extern int  tcp6_proc_init(void);
-extern void tcp6_proc_exit(void);
+extern int  tcp6_proc_init(struct net *net);
+extern void tcp6_proc_exit(struct net *net);
 extern int  udp6_proc_init(struct net *net);
 extern void udp6_proc_exit(struct net *net);
 extern int  udplite6_proc_init(void);
Index: net-2.6.26/net/ipv4/tcp_ipv4.c
===================================================================
--- net-2.6.26.orig/net/ipv4/tcp_ipv4.c
+++ net-2.6.26/net/ipv4/tcp_ipv4.c
@@ -2253,7 +2253,7 @@ static int tcp_seq_release(struct inode 
 	return 0;
 }
 
-int tcp_proc_register(struct tcp_seq_afinfo *afinfo)
+int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 {
 	int rc = 0;
 	struct proc_dir_entry *p;
@@ -2266,7 +2266,7 @@ int tcp_proc_register(struct tcp_seq_afi
 	afinfo->seq_fops->llseek	= seq_lseek;
 	afinfo->seq_fops->release	= tcp_seq_release;
 
-	p = proc_net_fops_create(&init_net, afinfo->name, S_IRUGO, afinfo->seq_fops);
+	p = proc_net_fops_create(net, afinfo->name, S_IRUGO, afinfo->seq_fops);
 	if (p)
 		p->data = afinfo;
 	else
@@ -2274,11 +2274,11 @@ int tcp_proc_register(struct tcp_seq_afi
 	return rc;
 }
 
-void tcp_proc_unregister(struct tcp_seq_afinfo *afinfo)
+void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo)
 {
 	if (!afinfo)
 		return;
-	proc_net_remove(&init_net, afinfo->name);
+	proc_net_remove(net, afinfo->name);
 	memset(afinfo->seq_fops, 0, sizeof(*afinfo->seq_fops));
 }
 
@@ -2419,12 +2419,12 @@ static struct tcp_seq_afinfo tcp4_seq_af
 
 int __init tcp4_proc_init(void)
 {
-	return tcp_proc_register(&tcp4_seq_afinfo);
+	return tcp_proc_register(&init_net, &tcp4_seq_afinfo);
 }
 
 void tcp4_proc_exit(void)
 {
-	tcp_proc_unregister(&tcp4_seq_afinfo);
+	tcp_proc_unregister(&init_net, &tcp4_seq_afinfo);
 }
 #endif /* CONFIG_PROC_FS */
 
Index: net-2.6.26/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.26.orig/net/ipv6/af_inet6.c
+++ net-2.6.26/net/ipv6/af_inet6.c
@@ -859,15 +859,25 @@ static int inet6_net_init(struct net *ne
 	err = udp6_proc_init(net);
 	if (err)
 		goto out;
+	err = tcp6_proc_init(net);
+	if (err)
+		goto proc_tcp6_fail;
 out:
 #endif
 	return err;
+
+#ifdef CONFIG_PROC_FS
+proc_tcp6_fail:
+	udp6_proc_exit(net);
+	goto out;
+#endif
 }
 
 static void inet6_net_exit(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
 	udp6_proc_exit(net);
+	tcp6_proc_exit(net);
 #endif
 }
 
@@ -951,8 +961,6 @@ static int __init inet6_init(void)
 	err = -ENOMEM;
 	if (raw6_proc_init())
 		goto proc_raw6_fail;
-	if (tcp6_proc_init())
-		goto proc_tcp6_fail;
 	if (udplite6_proc_init())
 		goto proc_udplite6_fail;
 	if (ipv6_misc_proc_init())
@@ -1037,8 +1045,6 @@ proc_anycast6_fail:
 proc_misc6_fail:
 	udplite6_proc_exit();
 proc_udplite6_fail:
-	tcp6_proc_exit();
-proc_tcp6_fail:
 	raw6_proc_exit();
 proc_raw6_fail:
 #endif
@@ -1098,7 +1104,6 @@ static void __exit inet6_exit(void)
 	ac6_proc_exit();
 	ipv6_misc_proc_exit();
 	udplite6_proc_exit();
-	tcp6_proc_exit();
 	raw6_proc_exit();
 #endif
 	ipv6_netfilter_fini();

-- 
