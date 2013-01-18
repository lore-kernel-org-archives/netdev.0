From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RESEND 01/10] netfilter: move nf_conntrack initialize out of pernet operations
Date: Fri, 18 Jan 2013 18:16:21 +0800
Message-ID: <1358504190-6094-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, ebiederm@xmission.com, canqunzhang@gmail.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58894 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751830Ab3ARKQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 05:16:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now,the netfilter initialize and cleanup codes are
in pernet operations function.
This job should be done in module_init/exit.We can't use
init_net to identify if it's the right time to initialize
or cleanup.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_core.h |  8 ++-
 net/netfilter/nf_conntrack_core.c         | 96 ++++++++++++-------------------
 net/netfilter/nf_conntrack_standalone.c   | 28 ++++++---
 3 files changed, 62 insertions(+), 70 deletions(-)

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
index e4a0c4f..79eee4e 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1331,8 +1331,14 @@ static int untrack_refs(void)
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
 
@@ -1341,8 +1347,18 @@ static void nf_conntrack_cleanup_init_net(void)
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
@@ -1352,6 +1368,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 	}
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
+	nf_conntrack_proto_fini(net);
 	nf_conntrack_helper_fini(net);
 	nf_conntrack_timeout_fini(net);
 	nf_conntrack_ecache_fini(net);
@@ -1363,27 +1380,6 @@ static void nf_conntrack_cleanup_net(struct net *net)
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
@@ -1474,7 +1470,7 @@ void nf_ct_untracked_status_or(unsigned long bits)
 }
 EXPORT_SYMBOL_GPL(nf_ct_untracked_status_or);
 
-static int nf_conntrack_init_init_net(void)
+int nf_conntrack_init_start(void)
 {
 	int max_factor = 8;
 	int ret, cpu;
@@ -1522,6 +1518,16 @@ err_extend:
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
@@ -1529,7 +1535,7 @@ err_extend:
 #define DYING_NULLS_VAL		((1<<30)+1)
 #define TEMPLATE_NULLS_VAL	((1<<30)+2)
 
-static int nf_conntrack_init_net(struct net *net)
+int nf_conntrack_init_net(struct net *net)
 {
 	int ret;
 
@@ -1583,7 +1589,12 @@ static int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_helper_init(net);
 	if (ret < 0)
 		goto err_helper;
+	ret = nf_conntrack_proto_init(net);
+	if (ret < 0)
+		goto err_proto;
 	return 0;
+err_proto:
+	nf_conntrack_helper_fini(net);
 err_helper:
 	nf_conntrack_timeout_fini(net);
 err_timeout:
@@ -1610,38 +1621,3 @@ s16 (*nf_ct_nat_offset)(const struct nf_conn *ct,
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
index e7185c6..00bf93c 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -530,11 +530,11 @@ static void nf_conntrack_standalone_fini_sysctl(struct net *net)
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
 	ret = nf_conntrack_standalone_init_proc(net);
@@ -550,30 +550,42 @@ static int nf_conntrack_net_init(struct net *net)
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
+	ret = register_pernet_subsys(&nf_conntrack_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+	nf_conntrack_init_end();
+	return 0;
+out_pernet:
+	nf_conntrack_cleanup_end();
+out_start:
+	return ret;
 }
 
 static void __exit nf_conntrack_standalone_fini(void)
 {
+	nf_conntrack_cleanup_start();
 	unregister_pernet_subsys(&nf_conntrack_net_ops);
 	nf_conntrack_cleanup_end();
 }
-- 
1.7.11.7
