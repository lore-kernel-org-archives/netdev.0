From: pablo@netfilter.org
Subject: [PATCH 10/21] netfilter: nf_conntrack: move initialization out of pernet operations
Date: Fri, 25 Jan 2013 14:54:42 +0100
Message-ID: <1359122093-3404-11-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60304 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932248Ab3AYNzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 08:55:13 -0500
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

nf_conntrack initialization and cleanup codes happens in pernet
operations function. This task should be done in module_init/exit.
We can't use init_net to identify if it's the right time to initialize
or cleanup since we cannot make assumption on the order netns are
created/destroyed.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_core.h |    8 ++-
 net/netfilter/nf_conntrack_core.c         |   96 +++++++++++------------------
 net/netfilter/nf_conntrack_standalone.c   |   56 ++++++++++-------
 3 files changed, 77 insertions(+), 83 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index e98aeb3..e05c1f6 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -25,12 +25,16 @@ extern unsigned int nf_conntrack_in(struct net *net,
 				    unsigned int hooknum,
 				    struct sk_buff *skb);
 
-extern int nf_conntrack_init(struct net *net);
-extern void nf_conntrack_cleanup(struct net *net);
+extern int nf_conntrack_init_net(struct net *net);
+extern void nf_conntrack_cleanup_net(struct net *net);
 
 extern int nf_conntrack_proto_init(struct net *net);
 extern void nf_conntrack_proto_fini(struct net *net);
 
+extern int nf_conntrack_init_start(void);
+extern void nf_conntrack_cleanup_start(void);
+
+extern void nf_conntrack_init_end(void);
 extern void nf_conntrack_cleanup_end(void);
 
 extern bool
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 85aa4b7..fb3e514 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1334,8 +1334,14 @@ static int untrack_refs(void)
 	return cnt;
 }
 
-static void nf_conntrack_cleanup_init_net(void)
+void nf_conntrack_cleanup_start(void)
 {
+	RCU_INIT_POINTER(ip_ct_attach, NULL);
+}
+
+void nf_conntrack_cleanup_end(void)
+{
+	RCU_INIT_POINTER(nf_ct_destroy, NULL);
 	while (untrack_refs() > 0)
 		schedule();
 
@@ -1344,8 +1350,18 @@ static void nf_conntrack_cleanup_init_net(void)
 #endif
 }
 
-static void nf_conntrack_cleanup_net(struct net *net)
+/*
+ * Mishearing the voices in his head, our hero wonders how he's
+ * supposed to kill the mall.
+ */
+void nf_conntrack_cleanup_net(struct net *net)
 {
+	/*
+	 * This makes sure all current packets have passed through
+	 *  netfilter framework.  Roll on, two-stage module
+	 *  delete...
+	 */
+	synchronize_net();
  i_see_dead_people:
 	nf_ct_iterate_cleanup(net, kill_all, NULL);
 	nf_ct_release_dying_list(net);
@@ -1355,6 +1371,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 	}
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
+	nf_conntrack_proto_fini(net);
 	nf_conntrack_labels_fini(net);
 	nf_conntrack_helper_fini(net);
 	nf_conntrack_timeout_fini(net);
@@ -1367,27 +1384,6 @@ static void nf_conntrack_cleanup_net(struct net *net)
 	free_percpu(net->ct.stat);
 }
 
-/* Mishearing the voices in his head, our hero wonders how he's
-   supposed to kill the mall. */
-void nf_conntrack_cleanup(struct net *net)
-{
-	if (net_eq(net, &init_net))
-		RCU_INIT_POINTER(ip_ct_attach, NULL);
-
-	/* This makes sure all current packets have passed through
-	   netfilter framework.  Roll on, two-stage module
-	   delete... */
-	synchronize_net();
-	nf_conntrack_proto_fini(net);
-	nf_conntrack_cleanup_net(net);
-}
-
-void nf_conntrack_cleanup_end(void)
-{
-	RCU_INIT_POINTER(nf_ct_destroy, NULL);
-	nf_conntrack_cleanup_init_net();
-}
-
 void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls)
 {
 	struct hlist_nulls_head *hash;
@@ -1478,7 +1474,7 @@ void nf_ct_untracked_status_or(unsigned long bits)
 }
 EXPORT_SYMBOL_GPL(nf_ct_untracked_status_or);
 
-static int nf_conntrack_init_init_net(void)
+int nf_conntrack_init_start(void)
 {
 	int max_factor = 8;
 	int ret, cpu;
@@ -1526,6 +1522,16 @@ err_extend:
 	return ret;
 }
 
+void nf_conntrack_init_end(void)
+{
+	/* For use by REJECT target */
+	RCU_INIT_POINTER(ip_ct_attach, nf_conntrack_attach);
+	RCU_INIT_POINTER(nf_ct_destroy, destroy_conntrack);
+
+	/* Howto get NAT offsets */
+	RCU_INIT_POINTER(nf_ct_nat_offset, NULL);
+}
+
 /*
  * We need to use special "null" values, not used in hash table
  */
@@ -1533,7 +1539,7 @@ err_extend:
 #define DYING_NULLS_VAL		((1<<30)+1)
 #define TEMPLATE_NULLS_VAL	((1<<30)+2)
 
-static int nf_conntrack_init_net(struct net *net)
+int nf_conntrack_init_net(struct net *net)
 {
 	int ret;
 
@@ -1592,8 +1598,13 @@ static int nf_conntrack_init_net(struct net *net)
 	if (ret < 0)
 		goto err_labels;
 
+	ret = nf_conntrack_proto_init(net);
+	if (ret < 0)
+		goto err_proto;
 	return 0;
 
+err_proto:
+	nf_conntrack_labels_fini(net);
 err_labels:
 	nf_conntrack_helper_fini(net);
 err_helper:
@@ -1622,38 +1633,3 @@ s16 (*nf_ct_nat_offset)(const struct nf_conn *ct,
 			enum ip_conntrack_dir dir,
 			u32 seq);
 EXPORT_SYMBOL_GPL(nf_ct_nat_offset);
-
-int nf_conntrack_init(struct net *net)
-{
-	int ret;
-
-	if (net_eq(net, &init_net)) {
-		ret = nf_conntrack_init_init_net();
-		if (ret < 0)
-			goto out_init_net;
-	}
-	ret = nf_conntrack_proto_init(net);
-	if (ret < 0)
-		goto out_proto;
-	ret = nf_conntrack_init_net(net);
-	if (ret < 0)
-		goto out_net;
-
-	if (net_eq(net, &init_net)) {
-		/* For use by REJECT target */
-		RCU_INIT_POINTER(ip_ct_attach, nf_conntrack_attach);
-		RCU_INIT_POINTER(nf_ct_destroy, destroy_conntrack);
-
-		/* Howto get NAT offsets */
-		RCU_INIT_POINTER(nf_ct_nat_offset, NULL);
-	}
-	return 0;
-
-out_net:
-	nf_conntrack_proto_fini(net);
-out_proto:
-	if (net_eq(net, &init_net))
-		nf_conntrack_cleanup_init_net();
-out_init_net:
-	return ret;
-}
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index e7185c6..725bf04 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -472,13 +472,6 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 {
 	struct ctl_table *table;
 
-	if (net_eq(net, &init_net)) {
-		nf_ct_netfilter_header =
-		       register_net_sysctl(&init_net, "net", nf_ct_netfilter_table);
-		if (!nf_ct_netfilter_header)
-			goto out;
-	}
-
 	table = kmemdup(nf_ct_sysctl_table, sizeof(nf_ct_sysctl_table),
 			GFP_KERNEL);
 	if (!table)
@@ -502,10 +495,6 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 out_unregister_netfilter:
 	kfree(table);
 out_kmemdup:
-	if (net_eq(net, &init_net))
-		unregister_net_sysctl_table(nf_ct_netfilter_header);
-out:
-	printk(KERN_ERR "nf_conntrack: can't register to sysctl.\n");
 	return -ENOMEM;
 }
 
@@ -513,8 +502,6 @@ static void nf_conntrack_standalone_fini_sysctl(struct net *net)
 {
 	struct ctl_table *table;
 
-	if (net_eq(net, &init_net))
-		unregister_net_sysctl_table(nf_ct_netfilter_header);
 	table = net->ct.sysctl_header->ctl_table_arg;
 	unregister_net_sysctl_table(net->ct.sysctl_header);
 	kfree(table);
@@ -530,51 +517,78 @@ static void nf_conntrack_standalone_fini_sysctl(struct net *net)
 }
 #endif /* CONFIG_SYSCTL */
 
-static int nf_conntrack_net_init(struct net *net)
+static int nf_conntrack_pernet_init(struct net *net)
 {
 	int ret;
 
-	ret = nf_conntrack_init(net);
+	ret = nf_conntrack_init_net(net);
 	if (ret < 0)
 		goto out_init;
+
 	ret = nf_conntrack_standalone_init_proc(net);
 	if (ret < 0)
 		goto out_proc;
+
 	net->ct.sysctl_checksum = 1;
 	net->ct.sysctl_log_invalid = 0;
 	ret = nf_conntrack_standalone_init_sysctl(net);
 	if (ret < 0)
 		goto out_sysctl;
+
 	return 0;
 
 out_sysctl:
 	nf_conntrack_standalone_fini_proc(net);
 out_proc:
-	nf_conntrack_cleanup(net);
+	nf_conntrack_cleanup_net(net);
 out_init:
 	return ret;
 }
 
-static void nf_conntrack_net_exit(struct net *net)
+static void nf_conntrack_pernet_exit(struct net *net)
 {
 	nf_conntrack_standalone_fini_sysctl(net);
 	nf_conntrack_standalone_fini_proc(net);
-	nf_conntrack_cleanup(net);
+	nf_conntrack_cleanup_net(net);
 }
 
 static struct pernet_operations nf_conntrack_net_ops = {
-	.init = nf_conntrack_net_init,
-	.exit = nf_conntrack_net_exit,
+	.init = nf_conntrack_pernet_init,
+	.exit = nf_conntrack_pernet_exit,
 };
 
 static int __init nf_conntrack_standalone_init(void)
 {
-	return register_pernet_subsys(&nf_conntrack_net_ops);
+	int ret = nf_conntrack_init_start();
+	if (ret < 0)
+		goto out_start;
+
+	nf_ct_netfilter_header =
+		register_net_sysctl(&init_net, "net", nf_ct_netfilter_table);
+	if (!nf_ct_netfilter_header)
+		goto out_sysctl;
+
+	ret = register_pernet_subsys(&nf_conntrack_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
+	nf_conntrack_init_end();
+	return 0;
+
+out_pernet:
+	unregister_net_sysctl_table(nf_ct_netfilter_header);
+out_sysctl:
+	pr_err("nf_conntrack: can't register to sysctl.\n");
+	nf_conntrack_cleanup_end();
+out_start:
+	return ret;
 }
 
 static void __exit nf_conntrack_standalone_fini(void)
 {
+	nf_conntrack_cleanup_start();
 	unregister_pernet_subsys(&nf_conntrack_net_ops);
+	unregister_net_sysctl_table(nf_ct_netfilter_header);
 	nf_conntrack_cleanup_end();
 }
 
-- 
1.7.10.4
