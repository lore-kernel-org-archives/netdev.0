From: pablo@netfilter.org
Subject: [PATCH 18/21] netfilter: nf_ct_proto: move initialization out of pernet_operations
Date: Fri, 25 Jan 2013 14:54:50 +0100
Message-ID: <1359122093-3404-19-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60349 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757371Ab3AYNzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 08:55:23 -0500
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Move the global initial codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_core.h |    7 ++++--
 net/netfilter/nf_conntrack_core.c         |   13 ++++++++---
 net/netfilter/nf_conntrack_proto.c        |   34 ++++++++++++++++-------------
 3 files changed, 34 insertions(+), 20 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index e05c1f6..930275fa 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -28,8 +28,11 @@ extern unsigned int nf_conntrack_in(struct net *net,
 extern int nf_conntrack_init_net(struct net *net);
 extern void nf_conntrack_cleanup_net(struct net *net);
 
-extern int nf_conntrack_proto_init(struct net *net);
-extern void nf_conntrack_proto_fini(struct net *net);
+extern int nf_conntrack_proto_pernet_init(struct net *net);
+extern void nf_conntrack_proto_pernet_fini(struct net *net);
+
+extern int nf_conntrack_proto_init(void);
+extern void nf_conntrack_proto_fini(void);
 
 extern int nf_conntrack_init_start(void);
 extern void nf_conntrack_cleanup_start(void);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index a4a3bcf..c8e001a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1348,6 +1348,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_proto_fini();
 	nf_conntrack_labels_fini();
 	nf_conntrack_helper_fini();
 	nf_conntrack_timeout_fini();
@@ -1378,7 +1379,7 @@ void nf_conntrack_cleanup_net(struct net *net)
 	}
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
-	nf_conntrack_proto_fini(net);
+	nf_conntrack_proto_pernet_fini(net);
 	nf_conntrack_helper_pernet_fini(net);
 	nf_conntrack_ecache_pernet_fini(net);
 	nf_conntrack_tstamp_pernet_fini(net);
@@ -1540,6 +1541,10 @@ int nf_conntrack_init_start(void)
 	if (ret < 0)
 		goto err_extend;
 #endif
+	ret = nf_conntrack_proto_init();
+	if (ret < 0)
+		goto err_proto;
+
 	/* Set up fake conntrack: to never be deleted, not in any hashes */
 	for_each_possible_cpu(cpu) {
 		struct nf_conn *ct = &per_cpu(nf_conntrack_untracked, cpu);
@@ -1550,10 +1555,12 @@ int nf_conntrack_init_start(void)
 	nf_ct_untracked_status_or(IPS_CONFIRMED | IPS_UNTRACKED);
 	return 0;
 
+err_proto:
 #ifdef CONFIG_NF_CONNTRACK_ZONES
+	nf_ct_extend_unregister(&nf_ct_zone_extend);
 err_extend:
-	nf_conntrack_labels_fini();
 #endif
+	nf_conntrack_labels_fini();
 err_labels:
 	nf_conntrack_helper_fini();
 err_helper:
@@ -1638,7 +1645,7 @@ int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_helper_pernet_init(net);
 	if (ret < 0)
 		goto err_helper;
-	ret = nf_conntrack_proto_init(net);
+	ret = nf_conntrack_proto_pernet_init(net);
 	if (ret < 0)
 		goto err_proto;
 	return 0;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 51e928d..f0ec07c 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -503,9 +503,8 @@ void nf_conntrack_l4proto_unregister(struct net *net,
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
 
-int nf_conntrack_proto_init(struct net *net)
+int nf_conntrack_proto_pernet_init(struct net *net)
 {
-	unsigned int i;
 	int err;
 	struct nf_proto_net *pn = nf_ct_l4proto_net(net,
 					&nf_conntrack_l4proto_generic);
@@ -520,19 +519,12 @@ int nf_conntrack_proto_init(struct net *net)
 	if (err < 0)
 		return err;
 
-	if (net == &init_net) {
-		for (i = 0; i < AF_MAX; i++)
-			rcu_assign_pointer(nf_ct_l3protos[i],
-					   &nf_conntrack_l3proto_generic);
-	}
-
 	pn->users++;
 	return 0;
 }
 
-void nf_conntrack_proto_fini(struct net *net)
+void nf_conntrack_proto_pernet_fini(struct net *net)
 {
-	unsigned int i;
 	struct nf_proto_net *pn = nf_ct_l4proto_net(net,
 					&nf_conntrack_l4proto_generic);
 
@@ -540,9 +532,21 @@ void nf_conntrack_proto_fini(struct net *net)
 	nf_ct_l4proto_unregister_sysctl(net,
 					pn,
 					&nf_conntrack_l4proto_generic);
-	if (net == &init_net) {
-		/* free l3proto protocol tables */
-		for (i = 0; i < PF_MAX; i++)
-			kfree(nf_ct_protos[i]);
-	}
+}
+
+int nf_conntrack_proto_init(void)
+{
+	unsigned int i;
+	for (i = 0; i < AF_MAX; i++)
+		rcu_assign_pointer(nf_ct_l3protos[i],
+				   &nf_conntrack_l3proto_generic);
+	return 0;
+}
+
+void nf_conntrack_proto_fini(void)
+{
+	unsigned int i;
+	/* free l3proto protocol tables */
+	for (i = 0; i < PF_MAX; i++)
+		kfree(nf_ct_protos[i]);
 }
-- 
1.7.10.4
