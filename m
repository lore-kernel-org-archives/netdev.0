From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 03/19] netfilter: acct: move initial codes out of pernet_operations
Date: Fri, 28 Dec 2012 10:36:29 +0800
Message-ID: <1356662206-2260-3-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:12405 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753081Ab2L1Cis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 21:38:48 -0500
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the global initial codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_acct.h |  6 +++--
 net/netfilter/nf_conntrack_acct.c         | 37 ++++++++++++-------------------
 net/netfilter/nf_conntrack_core.c         | 15 +++++++++----
 3 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_acct.h b/include/net/netfilter/nf_conntrack_acct.h
index 463ae8e..2bdb7a1 100644
--- a/include/net/netfilter/nf_conntrack_acct.h
+++ b/include/net/netfilter/nf_conntrack_acct.h
@@ -57,7 +57,9 @@ static inline void nf_ct_set_acct(struct net *net, bool enable)
 	net->ct.sysctl_acct = enable;
 }
 
-extern int nf_conntrack_acct_init(struct net *net);
-extern void nf_conntrack_acct_fini(struct net *net);
+extern int nf_conntrack_acct_pernet_init(struct net *net);
+extern void nf_conntrack_acct_pernet_fini(struct net *net);
 
+extern int nf_conntrack_acct_init(void);
+extern void nf_conntrack_acct_fini(void);
 #endif /* _NF_CONNTRACK_ACCT_H */
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index 7df424e..8138555 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -106,36 +106,27 @@ static void nf_conntrack_acct_fini_sysctl(struct net *net)
 }
 #endif
 
-int nf_conntrack_acct_init(struct net *net)
+int nf_conntrack_acct_pernet_init(struct net *net)
 {
-	int ret;
-
 	net->ct.sysctl_acct = nf_ct_acct;
 
-	if (net_eq(net, &init_net)) {
-		ret = nf_ct_extend_register(&acct_extend);
-		if (ret < 0) {
-			printk(KERN_ERR "nf_conntrack_acct: Unable to register extension\n");
-			goto out_extend_register;
-		}
-	}
-
-	ret = nf_conntrack_acct_init_sysctl(net);
-	if (ret < 0)
-		goto out_sysctl;
+	return nf_conntrack_acct_init_sysctl(net);
+}
 
-	return 0;
+void nf_conntrack_acct_pernet_fini(struct net *net)
+{
+	nf_conntrack_acct_fini_sysctl(net);
+}
 
-out_sysctl:
-	if (net_eq(net, &init_net))
-		nf_ct_extend_unregister(&acct_extend);
-out_extend_register:
+int nf_conntrack_acct_init(void)
+{
+	int ret = nf_ct_extend_register(&acct_extend);
+	if (ret < 0)
+		pr_err("nf_conntrack_acct: Unable to register extension\n");
 	return ret;
 }
 
-void nf_conntrack_acct_fini(struct net *net)
+void nf_conntrack_acct_fini(void)
 {
-	nf_conntrack_acct_fini_sysctl(net);
-	if (net_eq(net, &init_net))
-		nf_ct_extend_unregister(&acct_extend);
+	nf_ct_extend_unregister(&acct_extend);
 }
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 96b281f..feb08d0 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1362,7 +1362,7 @@ void nf_conntrack_cleanup_net(struct net *net)
 	nf_conntrack_timeout_fini(net);
 	nf_conntrack_ecache_fini(net);
 	nf_conntrack_tstamp_fini(net);
-	nf_conntrack_acct_fini(net);
+	nf_conntrack_acct_pernet_fini(net);
 	nf_conntrack_expect_pernet_fini(net);
 	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
 	kfree(net->ct.slabname);
@@ -1378,6 +1378,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_acct_fini();
 	nf_conntrack_expect_fini();
 }
 
@@ -1503,6 +1504,10 @@ int nf_conntrack_init_start(void)
 	if (ret < 0)
 		goto err_expect;
 
+	ret = nf_conntrack_acct_init();
+	if (ret < 0)
+		goto err_acct;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1520,8 +1525,10 @@ int nf_conntrack_init_start(void)
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 err_extend:
-	nf_conntrack_expect_fini();
+	nf_conntrack_acct_fini();
 #endif
+err_acct:
+	nf_conntrack_expect_fini();
 err_expect:
 	return ret;
 }
@@ -1570,7 +1577,7 @@ int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_expect_pernet_init(net);
 	if (ret < 0)
 		goto err_expect;
-	ret = nf_conntrack_acct_init(net);
+	ret = nf_conntrack_acct_pernet_init(net);
 	if (ret < 0)
 		goto err_acct;
 	ret = nf_conntrack_tstamp_init(net);
@@ -1598,7 +1605,7 @@ err_timeout:
 err_ecache:
 	nf_conntrack_tstamp_fini(net);
 err_tstamp:
-	nf_conntrack_acct_fini(net);
+	nf_conntrack_acct_pernet_fini(net);
 err_acct:
 	nf_conntrack_expect_pernet_fini(net);
 err_expect:
-- 
1.7.11.7
