From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 14/17] netfilter: adjust l4proto_gre4 to the nf_conntrack_l4proto_register
Date: Fri, 27 Apr 2012 17:38:01 +0800
Message-ID: <1335519484-6089-15-git-send-email-gaofeng@cn.fujitsu.com>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

move the nf_conntrack_l4proto_register from module_init to
proto_gre_net_ops.init.

and use gre_pernet to replace net_generic.

because gre proto has no sysctl,so only need to initial pernet data
for gre proto.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_gre.c |   56 ++++++++++++++++++++------------
 1 files changed, 35 insertions(+), 21 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 4bf6b4e..8d70452 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -54,13 +54,20 @@ static unsigned int gre_timeouts[GRE_CT_MAX] = {
 
 static int proto_gre_net_id __read_mostly;
 struct netns_proto_gre {
+	struct nf_proto_net	nf;
 	rwlock_t		keymap_lock;
 	struct list_head	keymap_list;
+	unsigned int		gre_timeouts[GRE_CT_MAX];
 };
 
+static inline struct netns_proto_gre *gre_pernet(struct net *net)
+{
+	return net_generic(net, proto_gre_net_id);
+}
+
 void nf_ct_gre_keymap_flush(struct net *net)
 {
-	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
+	struct netns_proto_gre *net_gre = gre_pernet(net);
 	struct nf_ct_gre_keymap *km, *tmp;
 
 	write_lock_bh(&net_gre->keymap_lock);
@@ -85,7 +92,7 @@ static inline int gre_key_cmpfn(const struct nf_ct_gre_keymap *km,
 /* look up the source key for a given tuple */
 static __be16 gre_keymap_lookup(struct net *net, struct nf_conntrack_tuple *t)
 {
-	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
+	struct netns_proto_gre *net_gre = gre_pernet(net);
 	struct nf_ct_gre_keymap *km;
 	__be16 key = 0;
 
@@ -109,7 +116,7 @@ int nf_ct_gre_keymap_add(struct nf_conn *ct, enum ip_conntrack_dir dir,
 			 struct nf_conntrack_tuple *t)
 {
 	struct net *net = nf_ct_net(ct);
-	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
+	struct netns_proto_gre *net_gre = gre_pernet(net);
 	struct nf_conn_help *help = nfct_help(ct);
 	struct nf_ct_gre_keymap **kmp, *km;
 
@@ -150,7 +157,7 @@ EXPORT_SYMBOL_GPL(nf_ct_gre_keymap_add);
 void nf_ct_gre_keymap_destroy(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
-	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
+	struct netns_proto_gre *net_gre = gre_pernet(net);
 	struct nf_conn_help *help = nfct_help(ct);
 	enum ip_conntrack_dir dir;
 
@@ -237,7 +244,7 @@ static int gre_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 
 static unsigned int *gre_get_timeouts(struct net *net)
 {
-	return gre_timeouts;
+	return gre_pernet(net)->gre_timeouts;
 }
 
 /* Returns verdict for packet, and may modify conntrack */
@@ -339,6 +346,18 @@ gre_timeout_nla_policy[CTA_TIMEOUT_GRE_MAX+1] = {
 };
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
+static int gre_init_net(struct net *net, u_int8_t compat)
+{
+	int i;
+	struct netns_proto_gre *net_gre = gre_pernet(net);
+
+	rwlock_init(&net_gre->keymap_lock);
+	INIT_LIST_HEAD(&net_gre->keymap_list);
+	for (i = 0; i < GRE_CT_MAX; i++)
+		net_gre->gre_timeouts[i] = gre_timeouts[i];
+	return 0;
+}
+
 /* protocol helper struct */
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 	.l3proto	 = AF_INET,
@@ -368,20 +387,24 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 		.nla_policy	= gre_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+	.net_id		= &proto_gre_net_id,
+	.init_net	= gre_init_net,
 };
 
 static int proto_gre_net_init(struct net *net)
 {
-	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
-
-	rwlock_init(&net_gre->keymap_lock);
-	INIT_LIST_HEAD(&net_gre->keymap_list);
-
-	return 0;
+	int ret = 0;
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_gre4);
+	if (ret < 0)
+		pr_err("nf_conntrack_l4proto_gre4 :protocol register failed.\n");
+	return ret;
 }
 
 static void proto_gre_net_exit(struct net *net)
 {
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_gre4);
 	nf_ct_gre_keymap_flush(net);
 }
 
@@ -394,20 +417,11 @@ static struct pernet_operations proto_gre_net_ops = {
 
 static int __init nf_ct_proto_gre_init(void)
 {
-	int rv;
-
-	rv = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_gre4);
-	if (rv < 0)
-		return rv;
-	rv = register_pernet_subsys(&proto_gre_net_ops);
-	if (rv < 0)
-		nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
-	return rv;
+	return register_pernet_subsys(&proto_gre_net_ops);
 }
 
 static void __exit nf_ct_proto_gre_fini(void)
 {
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
 	unregister_pernet_subsys(&proto_gre_net_ops);
 }
 
-- 
1.7.7.6

