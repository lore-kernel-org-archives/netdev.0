From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 03/25] netns ct: boring netns boilerplate
Date: Sun, 22 Jun 2008 05:01:11 +0400
Message-ID: <20080622010111.GD5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:2329 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbYFVBFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 21:05:20 -0400
Received: by ug-out-1314.google.com with SMTP id h2so243890ugf.16
        for <netdev@vger.kernel.org>; Sat, 21 Jun 2008 18:05:19 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/net_namespace.h               |    4 ++++
 include/net/netfilter/nf_conntrack_core.h |    4 ++--
 include/net/netns/conntrack.h             |    6 ++++++
 net/netfilter/nf_conntrack_core.c         |    9 +++++++--
 net/netfilter/nf_conntrack_expect.c       |    4 ++--
 net/netfilter/nf_conntrack_standalone.c   |   21 ++++++++++++++++++---
 6 files changed, 39 insertions(+), 9 deletions(-)

--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -15,6 +15,7 @@
 #include <net/netns/ipv6.h>
 #include <net/netns/dccp.h>
 #include <net/netns/x_tables.h>
+#include <net/netns/conntrack.h>
 
 struct proc_dir_entry;
 struct net_device;
@@ -63,6 +64,9 @@ struct net {
 #endif
 #ifdef CONFIG_NETFILTER
 	struct netns_xt		xt;
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	struct netns_ct		ct;
+#endif
 #endif
 	struct net_generic	*gen;
 };
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -24,8 +24,8 @@ extern unsigned int nf_conntrack_in(int pf,
 				    unsigned int hooknum,
 				    struct sk_buff *skb);
 
-extern int nf_conntrack_init(void);
-extern void nf_conntrack_cleanup(void);
+extern int nf_conntrack_init(struct net *net);
+extern void nf_conntrack_cleanup(struct net *net);
 
 extern int nf_conntrack_proto_init(void);
 extern void nf_conntrack_proto_fini(void);
new file mode 100644
--- /dev/null
+++ b/include/net/netns/conntrack.h
@@ -0,0 +1,6 @@
+#ifndef __NETNS_CONNTRACK_H
+#define __NETNS_CONNTRACK_H
+
+struct netns_ct {
+};
+#endif
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -996,8 +996,10 @@ EXPORT_SYMBOL_GPL(nf_conntrack_flush);
 
 /* Mishearing the voices in his head, our hero wonders how he's
    supposed to kill the mall. */
-void nf_conntrack_cleanup(void)
+void nf_conntrack_cleanup(struct net *net)
 {
+	if (net != &init_net)
+		return;
 	rcu_assign_pointer(ip_ct_attach, NULL);
 
 	/* This makes sure all current packets have passed through
@@ -1109,11 +1111,14 @@ EXPORT_SYMBOL_GPL(nf_conntrack_set_hashsize);
 module_param_call(hashsize, nf_conntrack_set_hashsize, param_get_uint,
 		  &nf_conntrack_htable_size, 0600);
 
-int __init nf_conntrack_init(void)
+int nf_conntrack_init(struct net *net)
 {
 	int max_factor = 8;
 	int ret;
 
+	if (net != &init_net)
+		return 0;
+
 	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
 	 * machine has 512 buckets. >= 1GB machines have 16384 buckets. */
 	if (!nf_conntrack_htable_size) {
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -537,7 +537,7 @@ static const struct file_operations exp_file_ops = {
 };
 #endif /* CONFIG_PROC_FS */
 
-static int __init exp_proc_init(void)
+static int exp_proc_init(void)
 {
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *proc;
@@ -558,7 +558,7 @@ static void exp_proc_remove(void)
 
 module_param_named(expect_hashsize, nf_ct_expect_hsize, uint, 0600);
 
-int __init nf_conntrack_expect_init(void)
+int nf_conntrack_expect_init(void)
 {
 	int err = -ENOMEM;
 
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -446,11 +446,26 @@ static void nf_conntrack_standalone_fini_sysctl(void)
 }
 #endif /* CONFIG_SYSCTL */
 
+static int nf_conntrack_net_init(struct net *net)
+{
+	return nf_conntrack_init(net);
+}
+
+static void nf_conntrack_net_exit(struct net *net)
+{
+	nf_conntrack_cleanup(net);
+}
+
+static struct pernet_operations nf_conntrack_net_ops = {
+	.init = nf_conntrack_net_init,
+	.exit = nf_conntrack_net_exit,
+};
+
 static int __init nf_conntrack_standalone_init(void)
 {
 	int ret;
 
-	ret = nf_conntrack_init();
+	ret = register_pernet_subsys(&nf_conntrack_net_ops);
 	if (ret < 0)
 		goto out;
 	ret = nf_conntrack_standalone_init_proc();
@@ -464,7 +479,7 @@ static int __init nf_conntrack_standalone_init(void)
 out_sysctl:
 	nf_conntrack_standalone_fini_proc();
 out_proc:
-	nf_conntrack_cleanup();
+	unregister_pernet_subsys(&nf_conntrack_net_ops);
 out:
 	return ret;
 }
@@ -473,7 +488,7 @@ static void __exit nf_conntrack_standalone_fini(void)
 {
 	nf_conntrack_standalone_fini_sysctl();
 	nf_conntrack_standalone_fini_proc();
-	nf_conntrack_cleanup();
+	unregister_pernet_subsys(&nf_conntrack_net_ops);
 }
 
 module_init(nf_conntrack_standalone_init);
-- 
1.5.4.5


