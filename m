From: pablo@netfilter.org
Subject: [PATCH 12/21] netfilter: nf_ct_acct: move initialization out of pernet_operations
Date: Fri, 25 Jan 2013 14:54:44 +0100
Message-ID: <1359122093-3404-13-git-send-email-pablo@netfilter.org>
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
 include/net/netfilter/nf_conntrack_acct.h |    6 +++--
 net/netfilter/nf_conntrack_acct.c         |   36 +++++++++++------------------
 net/netfilter/nf_conntrack_core.c         |   15 ++++++++----
 3 files changed, 28 insertions(+), 29 deletions(-)

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
index 7df424e..2d3030a 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -106,36 +106,26 @@ static void nf_conntrack_acct_fini_sysctl(struct net *net)
 }
 #endif
 
-int nf_conntrack_acct_init(struct net *net)
+int nf_conntrack_acct_pernet_init(struct net *net)
 {
-	int ret;
-
 	net->ct.sysctl_acct = nf_ct_acct;
+	return nf_conntrack_acct_init_sysctl(net);
+}
 
-	if (net_eq(net, &init_net)) {
-		ret = nf_ct_extend_register(&acct_extend);
-		if (ret < 0) {
-			printk(KERN_ERR "nf_conntrack_acct: Unable to register extension\n");
-			goto out_extend_register;
-		}
-	}
+void nf_conntrack_acct_pernet_fini(struct net *net)
+{
+	nf_conntrack_acct_fini_sysctl(net);
+}
 
-	ret = nf_conntrack_acct_init_sysctl(net);
+int nf_conntrack_acct_init(void)
+{
+	int ret = nf_ct_extend_register(&acct_extend);
 	if (ret < 0)
-		goto out_sysctl;
-
-	return 0;
-
-out_sysctl:
-	if (net_eq(net, &init_net))
-		nf_ct_extend_unregister(&acct_extend);
-out_extend_register:
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
index a3cca57..f4c6d4a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1348,6 +1348,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_acct_fini();
 	nf_conntrack_expect_fini();
 }
 
@@ -1378,7 +1379,7 @@ void nf_conntrack_cleanup_net(struct net *net)
 	nf_conntrack_timeout_fini(net);
 	nf_conntrack_ecache_fini(net);
 	nf_conntrack_tstamp_fini(net);
-	nf_conntrack_acct_fini(net);
+	nf_conntrack_acct_pernet_fini(net);
 	nf_conntrack_expect_pernet_fini(net);
 	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
 	kfree(net->ct.slabname);
@@ -1507,6 +1508,10 @@ int nf_conntrack_init_start(void)
 	if (ret < 0)
 		goto err_expect;
 
+	ret = nf_conntrack_acct_init();
+	if (ret < 0)
+		goto err_acct;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1524,8 +1529,10 @@ int nf_conntrack_init_start(void)
 
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
@@ -1586,7 +1593,7 @@ int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_expect_pernet_init(net);
 	if (ret < 0)
 		goto err_expect;
-	ret = nf_conntrack_acct_init(net);
+	ret = nf_conntrack_acct_pernet_init(net);
 	if (ret < 0)
 		goto err_acct;
 	ret = nf_conntrack_tstamp_init(net);
@@ -1622,7 +1629,7 @@ err_timeout:
 err_ecache:
 	nf_conntrack_tstamp_fini(net);
 err_tstamp:
-	nf_conntrack_acct_fini(net);
+	nf_conntrack_acct_pernet_fini(net);
 err_acct:
 	nf_conntrack_expect_pernet_fini(net);
 err_expect:
-- 
1.7.10.4

