From: pablo@netfilter.org
Subject: [PATCH 17/21] netfilter: nf_ct_labels: move initialization out of pernet_operations
Date: Fri, 25 Jan 2013 14:54:49 +0100
Message-ID: <1359122093-3404-18-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60331 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757340Ab3AYNzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 08:55:20 -0500
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Move the global initial codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_labels.h |    8 ++++----
 net/netfilter/nf_conntrack_core.c           |   17 ++++++++---------
 net/netfilter/nf_conntrack_labels.c         |   11 ++++-------
 3 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_labels.h b/include/net/netfilter/nf_conntrack_labels.h
index a3ce5d0..c985695 100644
--- a/include/net/netfilter/nf_conntrack_labels.h
+++ b/include/net/netfilter/nf_conntrack_labels.h
@@ -50,9 +50,9 @@ int nf_connlabels_replace(struct nf_conn *ct,
 			  const u32 *data, const u32 *mask, unsigned int words);
 
 #ifdef CONFIG_NF_CONNTRACK_LABELS
-int nf_conntrack_labels_init(struct net *net);
-void nf_conntrack_labels_fini(struct net *net);
+int nf_conntrack_labels_init(void);
+void nf_conntrack_labels_fini(void);
 #else
-static inline int nf_conntrack_labels_init(struct net *n) { return 0; }
-static inline void nf_conntrack_labels_fini(struct net *net) {}
+static inline int nf_conntrack_labels_init(void) { return 0; }
+static inline void nf_conntrack_labels_fini(void) {}
 #endif
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 06b8cdb..a4a3bcf 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1348,6 +1348,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_labels_fini();
 	nf_conntrack_helper_fini();
 	nf_conntrack_timeout_fini();
 	nf_conntrack_ecache_fini();
@@ -1378,7 +1379,6 @@ void nf_conntrack_cleanup_net(struct net *net)
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
 	nf_conntrack_proto_fini(net);
-	nf_conntrack_labels_fini(net);
 	nf_conntrack_helper_pernet_fini(net);
 	nf_conntrack_ecache_pernet_fini(net);
 	nf_conntrack_tstamp_pernet_fini(net);
@@ -1531,6 +1531,10 @@ int nf_conntrack_init_start(void)
 	if (ret < 0)
 		goto err_helper;
 
+	ret = nf_conntrack_labels_init();
+	if (ret < 0)
+		goto err_labels;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1548,8 +1552,10 @@ int nf_conntrack_init_start(void)
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 err_extend:
-	nf_conntrack_helper_fini();
+	nf_conntrack_labels_fini();
 #endif
+err_labels:
+	nf_conntrack_helper_fini();
 err_helper:
 	nf_conntrack_timeout_fini();
 err_timeout:
@@ -1632,19 +1638,12 @@ int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_helper_pernet_init(net);
 	if (ret < 0)
 		goto err_helper;
-
-	ret = nf_conntrack_labels_init(net);
-	if (ret < 0)
-		goto err_labels;
-
 	ret = nf_conntrack_proto_init(net);
 	if (ret < 0)
 		goto err_proto;
 	return 0;
 
 err_proto:
-	nf_conntrack_labels_fini(net);
-err_labels:
 	nf_conntrack_helper_pernet_fini(net);
 err_helper:
 	nf_conntrack_ecache_pernet_fini(net);
diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
index e1d1eb8..8fe2e99 100644
--- a/net/netfilter/nf_conntrack_labels.c
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -101,15 +101,12 @@ static struct nf_ct_ext_type labels_extend __read_mostly = {
 	.id     = NF_CT_EXT_LABELS,
 };
 
-int nf_conntrack_labels_init(struct net *net)
+int nf_conntrack_labels_init(void)
 {
-	if (net_eq(net, &init_net))
-		return nf_ct_extend_register(&labels_extend);
-	return 0;
+	return nf_ct_extend_register(&labels_extend);
 }
 
-void nf_conntrack_labels_fini(struct net *net)
+void nf_conntrack_labels_fini(void)
 {
-	if (net_eq(net, &init_net))
-		nf_ct_extend_unregister(&labels_extend);
+	nf_ct_extend_unregister(&labels_extend);
 }
-- 
1.7.10.4
