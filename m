From: pablo@netfilter.org
Subject: [PATCH 15/21] netfilter: nf_ct_timeout: move initialization out of pernet_operations
Date: Fri, 25 Jan 2013 14:54:47 +0100
Message-ID: <1359122093-3404-16-git-send-email-pablo@netfilter.org>
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
 include/net/netfilter/nf_conntrack_timeout.h |    8 ++++----
 net/netfilter/nf_conntrack_core.c            |   15 ++++++++-------
 net/netfilter/nf_conntrack_timeout.c         |   23 +++++++----------------
 3 files changed, 19 insertions(+), 27 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_timeout.h b/include/net/netfilter/nf_conntrack_timeout.h
index e41e472..d23aceb 100644
--- a/include/net/netfilter/nf_conntrack_timeout.h
+++ b/include/net/netfilter/nf_conntrack_timeout.h
@@ -76,15 +76,15 @@ nf_ct_timeout_lookup(struct net *net, struct nf_conn *ct,
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
         return 0;
 }
 
-static inline void nf_conntrack_timeout_fini(struct net *net)
+static inline void nf_conntrack_timeout_fini(void)
 {
         return;
 }
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 048fe77..4f4d107 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1348,6 +1348,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_timeout_fini();
 	nf_conntrack_ecache_fini();
 	nf_conntrack_tstamp_fini();
 	nf_conntrack_acct_fini();
@@ -1378,7 +1379,6 @@ void nf_conntrack_cleanup_net(struct net *net)
 	nf_conntrack_proto_fini(net);
 	nf_conntrack_labels_fini(net);
 	nf_conntrack_helper_fini(net);
-	nf_conntrack_timeout_fini(net);
 	nf_conntrack_ecache_pernet_fini(net);
 	nf_conntrack_tstamp_pernet_fini(net);
 	nf_conntrack_acct_pernet_fini(net);
@@ -1522,6 +1522,10 @@ int nf_conntrack_init_start(void)
 	if (ret < 0)
 		goto err_ecache;
 
+	ret = nf_conntrack_timeout_init();
+	if (ret < 0)
+		goto err_timeout;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1539,8 +1543,10 @@ int nf_conntrack_init_start(void)
 
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
@@ -1616,9 +1622,6 @@ int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_ecache_pernet_init(net);
 	if (ret < 0)
 		goto err_ecache;
-	ret = nf_conntrack_timeout_init(net);
-	if (ret < 0)
-		goto err_timeout;
 	ret = nf_conntrack_helper_init(net);
 	if (ret < 0)
 		goto err_helper;
@@ -1637,8 +1640,6 @@ err_proto:
 err_labels:
 	nf_conntrack_helper_fini(net);
 err_helper:
-	nf_conntrack_timeout_fini(net);
-err_timeout:
 	nf_conntrack_ecache_pernet_fini(net);
 err_ecache:
 	nf_conntrack_tstamp_pernet_fini(net);
diff --git a/net/netfilter/nf_conntrack_timeout.c b/net/netfilter/nf_conntrack_timeout.c
index a878ce5..93da609 100644
--- a/net/netfilter/nf_conntrack_timeout.c
+++ b/net/netfilter/nf_conntrack_timeout.c
@@ -37,24 +37,15 @@ static struct nf_ct_ext_type timeout_extend __read_mostly = {
 	.id	= NF_CT_EXT_TIMEOUT,
 };
 
-int nf_conntrack_timeout_init(struct net *net)
+int nf_conntrack_timeout_init(void)
 {
-	int ret = 0;
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
+	int ret = nf_ct_extend_register(&timeout_extend);
+	if (ret < 0)
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
1.7.10.4

