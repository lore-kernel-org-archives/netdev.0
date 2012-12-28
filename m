From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 04/19] netfilter: tstamp: move initial codes out of pernet_operations
Date: Fri, 28 Dec 2012 10:36:30 +0800
Message-ID: <1356662206-2260-4-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36421 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752395Ab2L1Cip (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 21:38:45 -0500
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the global initial codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_timestamp.h | 21 ++++++++++++---
 net/netfilter/nf_conntrack_core.c              | 15 ++++++++---
 net/netfilter/nf_conntrack_timestamp.c         | 37 +++++++++-----------------
 3 files changed, 41 insertions(+), 32 deletions(-)

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
index feb08d0..b8fb65a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1361,7 +1361,7 @@ void nf_conntrack_cleanup_net(struct net *net)
 	nf_conntrack_helper_fini(net);
 	nf_conntrack_timeout_fini(net);
 	nf_conntrack_ecache_fini(net);
-	nf_conntrack_tstamp_fini(net);
+	nf_conntrack_tstamp_pernet_fini(net);
 	nf_conntrack_acct_pernet_fini(net);
 	nf_conntrack_expect_pernet_fini(net);
 	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
@@ -1378,6 +1378,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_tstamp_fini();
 	nf_conntrack_acct_fini();
 	nf_conntrack_expect_fini();
 }
@@ -1508,6 +1509,10 @@ int nf_conntrack_init_start(void)
 	if (ret < 0)
 		goto err_acct;
 
+	ret = nf_conntrack_tstamp_init();
+	if (ret < 0)
+		goto err_tstamp;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1525,8 +1530,10 @@ int nf_conntrack_init_start(void)
 
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
@@ -1580,7 +1587,7 @@ int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_acct_pernet_init(net);
 	if (ret < 0)
 		goto err_acct;
-	ret = nf_conntrack_tstamp_init(net);
+	ret = nf_conntrack_tstamp_pernet_init(net);
 	if (ret < 0)
 		goto err_tstamp;
 	ret = nf_conntrack_ecache_init(net);
@@ -1603,7 +1610,7 @@ err_helper:
 err_timeout:
 	nf_conntrack_ecache_fini(net);
 err_ecache:
-	nf_conntrack_tstamp_fini(net);
+	nf_conntrack_tstamp_pernet_fini(net);
 err_tstamp:
 	nf_conntrack_acct_pernet_fini(net);
 err_acct:
diff --git a/net/netfilter/nf_conntrack_timestamp.c b/net/netfilter/nf_conntrack_timestamp.c
index 7ea8026..2df0135 100644
--- a/net/netfilter/nf_conntrack_timestamp.c
+++ b/net/netfilter/nf_conntrack_timestamp.c
@@ -88,37 +88,26 @@ static void nf_conntrack_tstamp_fini_sysctl(struct net *net)
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
+}
 
-	ret = nf_conntrack_tstamp_init_sysctl(net);
+int nf_conntrack_tstamp_init(void)
+{
+	int ret = nf_ct_extend_register(&tstamp_extend);
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
1.7.11.7
