From: pablo@netfilter.org
Subject: [PATCH 13/21] netfilter: nf_ct_tstamp: move initialization out of pernet_operations
Date: Fri, 25 Jan 2013 14:54:45 +0100
Message-ID: <1359122093-3404-14-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

Move the global initial codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_timestamp.h |   21 ++++++++++---
 net/netfilter/nf_conntrack_core.c              |   15 ++++++---
 net/netfilter/nf_conntrack_timestamp.c         |   39 +++++++++---------------
 3 files changed, 43 insertions(+), 32 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_timestamp.h b/include/net/netfilter/nf_conntrack_timestamp.h
index fc9c82b..b004614 100644
--- a/include/net/netfilter/nf_conntrack_timestamp.h
+++ b/include/net/netfilter/nf_conntrack_timestamp.h
@@ -48,15 +48,28 @@ static inline void nf_ct_set_tstamp(struct net *net, bool enable)
 }
 
 #ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
-extern int nf_conntrack_tstamp_init(struct net *net);
-extern void nf_conntrack_tstamp_fini(struct net *net);
+extern int nf_conntrack_tstamp_pernet_init(struct net *net);
+extern void nf_conntrack_tstamp_pernet_fini(struct net *net);
+
+extern int nf_conntrack_tstamp_init(void);
+extern void nf_conntrack_tstamp_fini(void);
 #else
-static inline int nf_conntrack_tstamp_init(struct net *net)
+static inline int nf_conntrack_tstamp_pernet_init(struct net *net)
+{
+	return 0;
+}
+
+static inline void nf_conntrack_tstamp_pernet_fini(struct net *net)
+{
+	return;
+}
+
+static inline int nf_conntrack_tstamp_init(void)
 {
 	return 0;
 }
 
-static inline void nf_conntrack_tstamp_fini(struct net *net)
+static inline void nf_conntrack_tstamp_fini(void)
 {
 	return;
 }
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f4c6d4a..20ebfff 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1348,6 +1348,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_tstamp_fini();
 	nf_conntrack_acct_fini();
 	nf_conntrack_expect_fini();
 }
@@ -1378,7 +1379,7 @@ void nf_conntrack_cleanup_net(struct net *net)
 	nf_conntrack_helper_fini(net);
 	nf_conntrack_timeout_fini(net);
 	nf_conntrack_ecache_fini(net);
-	nf_conntrack_tstamp_fini(net);
+	nf_conntrack_tstamp_pernet_fini(net);
 	nf_conntrack_acct_pernet_fini(net);
 	nf_conntrack_expect_pernet_fini(net);
 	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
@@ -1512,6 +1513,10 @@ int nf_conntrack_init_start(void)
 	if (ret < 0)
 		goto err_acct;
 
+	ret = nf_conntrack_tstamp_init();
+	if (ret < 0)
+		goto err_tstamp;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1529,8 +1534,10 @@ int nf_conntrack_init_start(void)
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 err_extend:
-	nf_conntrack_acct_fini();
+	nf_conntrack_tstamp_fini();
 #endif
+err_tstamp:
+	nf_conntrack_acct_fini();
 err_acct:
 	nf_conntrack_expect_fini();
 err_expect:
@@ -1596,7 +1603,7 @@ int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_acct_pernet_init(net);
 	if (ret < 0)
 		goto err_acct;
-	ret = nf_conntrack_tstamp_init(net);
+	ret = nf_conntrack_tstamp_pernet_init(net);
 	if (ret < 0)
 		goto err_tstamp;
 	ret = nf_conntrack_ecache_init(net);
@@ -1627,7 +1634,7 @@ err_helper:
 err_timeout:
 	nf_conntrack_ecache_fini(net);
 err_ecache:
-	nf_conntrack_tstamp_fini(net);
+	nf_conntrack_tstamp_pernet_fini(net);
 err_tstamp:
 	nf_conntrack_acct_pernet_fini(net);
 err_acct:
diff --git a/net/netfilter/nf_conntrack_timestamp.c b/net/netfilter/nf_conntrack_timestamp.c
index 7ea8026..902fb0a 100644
--- a/net/netfilter/nf_conntrack_timestamp.c
+++ b/net/netfilter/nf_conntrack_timestamp.c
@@ -88,37 +88,28 @@ static void nf_conntrack_tstamp_fini_sysctl(struct net *net)
 }
 #endif
 
-int nf_conntrack_tstamp_init(struct net *net)
+int nf_conntrack_tstamp_pernet_init(struct net *net)
 {
-	int ret;
-
 	net->ct.sysctl_tstamp = nf_ct_tstamp;
+	return nf_conntrack_tstamp_init_sysctl(net);
+}
 
-	if (net_eq(net, &init_net)) {
-		ret = nf_ct_extend_register(&tstamp_extend);
-		if (ret < 0) {
-			printk(KERN_ERR "nf_ct_tstamp: Unable to register "
-					"extension\n");
-			goto out_extend_register;
-		}
-	}
+void nf_conntrack_tstamp_pernet_fini(struct net *net)
+{
+	nf_conntrack_tstamp_fini_sysctl(net);
+	nf_ct_extend_unregister(&tstamp_extend);
+}
 
-	ret = nf_conntrack_tstamp_init_sysctl(net);
+int nf_conntrack_tstamp_init(void)
+{
+	int ret;
+	ret = nf_ct_extend_register(&tstamp_extend);
 	if (ret < 0)
-		goto out_sysctl;
-
-	return 0;
-
-out_sysctl:
-	if (net_eq(net, &init_net))
-		nf_ct_extend_unregister(&tstamp_extend);
-out_extend_register:
+		pr_err("nf_ct_tstamp: Unable to register extension\n");
 	return ret;
 }
 
-void nf_conntrack_tstamp_fini(struct net *net)
+void nf_conntrack_tstamp_fini(void)
 {
-	nf_conntrack_tstamp_fini_sysctl(net);
-	if (net_eq(net, &init_net))
-		nf_ct_extend_unregister(&tstamp_extend);
+	nf_ct_extend_unregister(&tstamp_extend);
 }
-- 
1.7.10.4

