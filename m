From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RESEND 06/10] netfilter: timeout: move initial codes out of pernet_operations
Date: Fri, 18 Jan 2013 18:16:26 +0800
Message-ID: <1358504190-6094-6-git-send-email-gaofeng@cn.fujitsu.com>
References: <1358504190-6094-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, ebiederm@xmission.com, canqunzhang@gmail.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1358504190-6094-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the global initial codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_timeout.h | 12 ++++++------
 net/netfilter/nf_conntrack_core.c            | 15 ++++++++-------
 net/netfilter/nf_conntrack_timeout.c         | 22 +++++++---------------
 3 files changed, 21 insertions(+), 28 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_timeout.h b/include/net/netfilter/nf_conntrack_timeout.h
index e41e472..b009f98 100644
--- a/include/net/netfilter/nf_conntrack_timeout.h
+++ b/include/net/netfilter/nf_conntrack_timeout.h
@@ -76,17 +76,17 @@ nf_ct_timeout_lookup(struct net *net, struct nf_conn *ct,
 }
 
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
-extern int nf_conntrack_timeout_init(struct net *net);
-extern void nf_conntrack_timeout_fini(struct net *net);
+extern int nf_conntrack_timeout_init(void);
+extern void nf_conntrack_timeout_fini(void);
 #else
-static inline int nf_conntrack_timeout_init(struct net *net)
+static inline int nf_conntrack_timeout_init(void)
 {
-        return 0;
+	return 0;
 }
 
-static inline void nf_conntrack_timeout_fini(struct net *net)
+static inline void nf_conntrack_timeout_fini(void)
 {
-        return;
+	return;
 }
 #endif /* CONFIG_NF_CONNTRACK_TIMEOUT */
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 8a6c7b6..9aea05f 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1345,6 +1345,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_timeout_fini();
 	nf_conntrack_ecache_fini();
 	nf_conntrack_tstamp_fini();
 	nf_conntrack_acct_fini();
@@ -1374,7 +1375,6 @@ void nf_conntrack_cleanup_net(struct net *net)
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
 	nf_conntrack_proto_fini(net);
 	nf_conntrack_helper_fini(net);
-	nf_conntrack_timeout_fini(net);
 	nf_conntrack_ecache_pernet_fini(net);
 	nf_conntrack_tstamp_pernet_fini(net);
 	nf_conntrack_acct_pernet_fini(net);
@@ -1518,6 +1518,10 @@ int nf_conntrack_init_start(void)
 	if (ret < 0)
 		goto err_ecache;
 
+	ret = nf_conntrack_timeout_init();
+	if (ret < 0)
+		goto err_timeout;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1535,8 +1539,10 @@ int nf_conntrack_init_start(void)
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 err_extend:
-	nf_conntrack_ecache_fini();
+	nf_conntrack_timeout_fini();
 #endif
+err_timeout:
+	nf_conntrack_ecache_fini();
 err_ecache:
 	nf_conntrack_tstamp_fini();
 err_tstamp:
@@ -1612,9 +1618,6 @@ int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_ecache_pernet_init(net);
 	if (ret < 0)
 		goto err_ecache;
-	ret = nf_conntrack_timeout_init(net);
-	if (ret < 0)
-		goto err_timeout;
 	ret = nf_conntrack_helper_init(net);
 	if (ret < 0)
 		goto err_helper;
@@ -1625,8 +1628,6 @@ int nf_conntrack_init_net(struct net *net)
 err_proto:
 	nf_conntrack_helper_fini(net);
 err_helper:
-	nf_conntrack_timeout_fini(net);
-err_timeout:
 	nf_conntrack_ecache_pernet_fini(net);
 err_ecache:
 	nf_conntrack_tstamp_pernet_fini(net);
diff --git a/net/netfilter/nf_conntrack_timeout.c b/net/netfilter/nf_conntrack_timeout.c
index a878ce5..5b6d25b 100644
--- a/net/netfilter/nf_conntrack_timeout.c
+++ b/net/netfilter/nf_conntrack_timeout.c
@@ -37,24 +37,16 @@ static struct nf_ct_ext_type timeout_extend __read_mostly = {
 	.id	= NF_CT_EXT_TIMEOUT,
 };
 
-int nf_conntrack_timeout_init(struct net *net)
+int nf_conntrack_timeout_init(void)
 {
 	int ret = 0;
-
-	if (net_eq(net, &init_net)) {
-		ret = nf_ct_extend_register(&timeout_extend);
-		if (ret < 0) {
-			printk(KERN_ERR "nf_ct_timeout: Unable to register "
-					"timeout extension.\n");
-			return ret;
-		}
-	}
-
-	return 0;
+	ret = nf_ct_extend_register(&timeout_extend);
+	if (ret < 0) {
+		pr_err("nf_ct_timeout: Unable to register timeout extension.\n");
+	return ret;
 }
 
-void nf_conntrack_timeout_fini(struct net *net)
+void nf_conntrack_timeout_fini(void)
 {
-	if (net_eq(net, &init_net))
-		nf_ct_extend_unregister(&timeout_extend);
+	nf_ct_extend_unregister(&timeout_extend);
 }
-- 
1.7.11.7

