From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RESEND 08/10] netfilter: proto: move initial codes out of pernet_operations
Date: Fri, 18 Jan 2013 18:16:28 +0800
Message-ID: <1358504190-6094-8-git-send-email-gaofeng@cn.fujitsu.com>
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
 include/net/netfilter/nf_conntrack_core.h |  7 +++++--
 net/netfilter/nf_conntrack_core.c         | 13 +++++++++---
 net/netfilter/nf_conntrack_proto.c        | 35 +++++++++++++++++--------------
 3 files changed, 34 insertions(+), 21 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index e05c1f6..3952e92 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -28,8 +28,11 @@ extern unsigned int nf_conntrack_in(struct net *net,
 extern int nf_conntrack_init_net(struct net *net);
 extern void nf_conntrack_cleanup_net(struct net *net);
 
-extern int nf_conntrack_proto_init(struct net *net);
-extern void nf_conntrack_proto_fini(struct net *net);
+extern int nf_conntrack_proto_init(void);
+extern void nf_conntrack_proto_fini(void);
+
+extern int nf_conntrack_proto_pernet_init(struct net *net);
+extern void nf_conntrack_proto_pernet_fini(struct net *net);
 
 extern int nf_conntrack_init_start(void);
 extern void nf_conntrack_cleanup_start(void);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 91b240c..be43427 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1345,6 +1345,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_proto_fini();
 	nf_conntrack_helper_fini();
 	nf_conntrack_timeout_fini();
 	nf_conntrack_ecache_fini();
@@ -1374,7 +1375,7 @@ void nf_conntrack_cleanup_net(struct net *net)
 	}
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
-	nf_conntrack_proto_fini(net);
+	nf_conntrack_proto_pernet_fini(net);
 	nf_conntrack_helper_pernet_fini(net);
 	nf_conntrack_ecache_pernet_fini(net);
 	nf_conntrack_tstamp_pernet_fini(net);
@@ -1532,6 +1533,10 @@ int nf_conntrack_init_start(void)
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
@@ -1542,10 +1547,12 @@ int nf_conntrack_init_start(void)
 	nf_ct_untracked_status_or(IPS_CONFIRMED | IPS_UNTRACKED);
 	return 0;
 
+err_proto:
 #ifdef CONFIG_NF_CONNTRACK_ZONES
+	nf_ct_extend_unregister(&nf_ct_zone_extend);
 err_extend:
-	nf_conntrack_helper_fini();
 #endif
+	nf_conntrack_helper_fini();
 err_helper:
 	nf_conntrack_timeout_fini();
 err_timeout:
@@ -1628,7 +1635,7 @@ int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_helper_pernet_init(net);
 	if (ret < 0)
 		goto err_helper;
-	ret = nf_conntrack_proto_init(net);
+	ret = nf_conntrack_proto_pernet_init(net);
 	if (ret < 0)
 		goto err_proto;
 	return 0;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 51e928d..3d01b90 100644
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
@@ -520,29 +519,33 @@ int nf_conntrack_proto_init(struct net *net)
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
-
 	pn->users--;
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
1.7.11.7

