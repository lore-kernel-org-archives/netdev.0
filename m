From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RESEND 07/10] netfilter: helper: move initial codes out of pernet_operations
Date: Fri, 18 Jan 2013 18:16:27 +0800
Message-ID: <1358504190-6094-7-git-send-email-gaofeng@cn.fujitsu.com>
References: <1358504190-6094-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, ebiederm@xmission.com, canqunzhang@gmail.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58894 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751915Ab3ARKQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 05:16:20 -0500
In-Reply-To: <1358504190-6094-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the global initial codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_helper.h |  7 ++--
 net/netfilter/nf_conntrack_core.c           | 15 ++++++---
 net/netfilter/nf_conntrack_helper.c         | 52 ++++++++++++++---------------
 3 files changed, 41 insertions(+), 33 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 9aad956..ce27edf 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -82,8 +82,11 @@ static inline void *nfct_help_data(const struct nf_conn *ct)
 	return (void *)help->data;
 }
 
-extern int nf_conntrack_helper_init(struct net *net);
-extern void nf_conntrack_helper_fini(struct net *net);
+extern int nf_conntrack_helper_pernet_init(struct net *net);
+extern void nf_conntrack_helper_pernet_fini(struct net *net);
+
+extern int nf_conntrack_helper_init(void);
+extern void nf_conntrack_helper_fini(void);
 
 extern int nf_conntrack_broadcast_help(struct sk_buff *skb,
 				       unsigned int protoff,
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 9aea05f..91b240c 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1345,6 +1345,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_helper_fini();
 	nf_conntrack_timeout_fini();
 	nf_conntrack_ecache_fini();
 	nf_conntrack_tstamp_fini();
@@ -1374,7 +1375,7 @@ void nf_conntrack_cleanup_net(struct net *net)
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
 	nf_conntrack_proto_fini(net);
-	nf_conntrack_helper_fini(net);
+	nf_conntrack_helper_pernet_fini(net);
 	nf_conntrack_ecache_pernet_fini(net);
 	nf_conntrack_tstamp_pernet_fini(net);
 	nf_conntrack_acct_pernet_fini(net);
@@ -1522,6 +1523,10 @@ int nf_conntrack_init_start(void)
 	if (ret < 0)
 		goto err_timeout;
 
+	ret = nf_conntrack_helper_init();
+	if (ret < 0)
+		goto err_helper;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1539,8 +1544,10 @@ int nf_conntrack_init_start(void)
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 err_extend:
-	nf_conntrack_timeout_fini();
+	nf_conntrack_helper_fini();
 #endif
+err_helper:
+	nf_conntrack_timeout_fini();
 err_timeout:
 	nf_conntrack_ecache_fini();
 err_ecache:
@@ -1618,7 +1625,7 @@ int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_ecache_pernet_init(net);
 	if (ret < 0)
 		goto err_ecache;
-	ret = nf_conntrack_helper_init(net);
+	ret = nf_conntrack_helper_pernet_init(net);
 	if (ret < 0)
 		goto err_helper;
 	ret = nf_conntrack_proto_init(net);
@@ -1626,7 +1633,7 @@ int nf_conntrack_init_net(struct net *net)
 		goto err_proto;
 	return 0;
 err_proto:
-	nf_conntrack_helper_fini(net);
+	nf_conntrack_helper_pernet_fini(net);
 err_helper:
 	nf_conntrack_ecache_pernet_fini(net);
 err_ecache:
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 884f2b3..1fda099 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -423,44 +423,42 @@ static struct nf_ct_ext_type helper_extend __read_mostly = {
 	.id	= NF_CT_EXT_HELPER,
 };
 
-int nf_conntrack_helper_init(struct net *net)
+int nf_conntrack_helper_pernet_init(struct net *net)
 {
-	int err;
-
 	net->ct.auto_assign_helper_warned = false;
 	net->ct.sysctl_auto_assign_helper = nf_ct_auto_assign_helper;
+	return nf_conntrack_helper_init_sysctl(net);
+}
 
-	if (net_eq(net, &init_net)) {
-		nf_ct_helper_hsize = 1; /* gets rounded up to use one page */
-		nf_ct_helper_hash =
-			nf_ct_alloc_hashtable(&nf_ct_helper_hsize, 0);
-		if (!nf_ct_helper_hash)
-			return -ENOMEM;
+void nf_conntrack_helper_pernet_fini(struct net *net)
+{
+	nf_conntrack_helper_fini_sysctl(net);
+}
 
-		err = nf_ct_extend_register(&helper_extend);
-		if (err < 0)
-			goto err1;
+int nf_conntrack_helper_init(void)
+{
+	int ret;
+	nf_ct_helper_hsize = 1; /* gets rounded up to use one page */
+	nf_ct_helper_hash =
+		nf_ct_alloc_hashtable(&nf_ct_helper_hsize, 0);
+	if (!nf_ct_helper_hash)
+		return -ENOMEM;
+
+	ret = nf_ct_extend_register(&helper_extend);
+	if (ret < 0) {
+		pr_err("nf_ct_helper: Unable to register helper extension.\n");
+		goto out_extend;
 	}
 
-	err = nf_conntrack_helper_init_sysctl(net);
-	if (err < 0)
-		goto out_sysctl;
-
 	return 0;
 
-out_sysctl:
-	if (net_eq(net, &init_net))
-		nf_ct_extend_unregister(&helper_extend);
-err1:
+out_extend:
 	nf_ct_free_hashtable(nf_ct_helper_hash, nf_ct_helper_hsize);
-	return err;
+	return ret;
 }
 
-void nf_conntrack_helper_fini(struct net *net)
+void nf_conntrack_helper_fini(void)
 {
-	nf_conntrack_helper_fini_sysctl(net);
-	if (net_eq(net, &init_net)) {
-		nf_ct_extend_unregister(&helper_extend);
-		nf_ct_free_hashtable(nf_ct_helper_hash, nf_ct_helper_hsize);
-	}
+	nf_ct_extend_unregister(&helper_extend);
+	nf_ct_free_hashtable(nf_ct_helper_hash, nf_ct_helper_hsize);
 }
-- 
1.7.11.7
