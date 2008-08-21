From: adobriyan@gmail.com
Subject: [PATCH 31/38] netns ct: GRE conntracking in netns
Date: Fri, 22 Aug 2008 02:09:03 +0400
Message-ID: <20080821220903.GE31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* make keymap list per-netns
* do the same for lock while I'm at it (not strictly necessary)
* flush keymap at netns stop and module unload time.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netfilter/nf_conntrack_proto_gre.h |    2 
 net/netfilter/nf_conntrack_pptp.c                |    2 
 net/netfilter/nf_conntrack_proto_gre.c           |   98 +++++++++++++++++------
 3 files changed, 76 insertions(+), 26 deletions(-)

--- a/include/linux/netfilter/nf_conntrack_proto_gre.h
+++ b/include/linux/netfilter/nf_conntrack_proto_gre.h
@@ -87,7 +87,7 @@ int nf_ct_gre_keymap_add(struct nf_conn *ct, enum ip_conntrack_dir dir,
 /* delete keymap entries */
 void nf_ct_gre_keymap_destroy(struct nf_conn *ct);
 
-extern void nf_ct_gre_keymap_flush(void);
+extern void nf_ct_gre_keymap_flush(struct net *net);
 extern void nf_nat_need_gre(void);
 
 #endif /* __KERNEL__ */
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -602,7 +602,7 @@ static int __init nf_conntrack_pptp_init(void)
 static void __exit nf_conntrack_pptp_fini(void)
 {
 	nf_conntrack_helper_unregister(&pptp);
-	nf_ct_gre_keymap_flush();
+	nf_ct_gre_keymap_flush(&init_net);
 }
 
 module_init(nf_conntrack_pptp_init);
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -29,8 +29,11 @@
 #include <linux/list.h>
 #include <linux/seq_file.h>
 #include <linux/in.h>
+#include <linux/netdevice.h>
 #include <linux/skbuff.h>
-
+#include <net/dst.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_core.h>
@@ -40,19 +43,23 @@
 #define GRE_TIMEOUT		(30 * HZ)
 #define GRE_STREAM_TIMEOUT	(180 * HZ)
 
-static DEFINE_RWLOCK(nf_ct_gre_lock);
-static LIST_HEAD(gre_keymap_list);
+static int proto_gre_net_id;
+struct netns_proto_gre {
+	rwlock_t		keymap_lock;
+	struct list_head	keymap_list;
+};
 
-void nf_ct_gre_keymap_flush(void)
+void nf_ct_gre_keymap_flush(struct net *net)
 {
+	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
 	struct nf_ct_gre_keymap *km, *tmp;
 
-	write_lock_bh(&nf_ct_gre_lock);
-	list_for_each_entry_safe(km, tmp, &gre_keymap_list, list) {
+	write_lock_bh(&net_gre->keymap_lock);
+	list_for_each_entry_safe(km, tmp, &net_gre->keymap_list, list) {
 		list_del(&km->list);
 		kfree(km);
 	}
-	write_unlock_bh(&nf_ct_gre_lock);
+	write_unlock_bh(&net_gre->keymap_lock);
 }
 EXPORT_SYMBOL(nf_ct_gre_keymap_flush);
 
@@ -67,19 +74,20 @@ static inline int gre_key_cmpfn(const struct nf_ct_gre_keymap *km,
 }
 
 /* look up the source key for a given tuple */
-static __be16 gre_keymap_lookup(struct nf_conntrack_tuple *t)
+static __be16 gre_keymap_lookup(struct net *net, struct nf_conntrack_tuple *t)
 {
+	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
 	struct nf_ct_gre_keymap *km;
 	__be16 key = 0;
 
-	read_lock_bh(&nf_ct_gre_lock);
-	list_for_each_entry(km, &gre_keymap_list, list) {
+	read_lock_bh(&net_gre->keymap_lock);
+	list_for_each_entry(km, &net_gre->keymap_list, list) {
 		if (gre_key_cmpfn(km, t)) {
 			key = km->tuple.src.u.gre.key;
 			break;
 		}
 	}
-	read_unlock_bh(&nf_ct_gre_lock);
+	read_unlock_bh(&net_gre->keymap_lock);
 
 	pr_debug("lookup src key 0x%x for ", key);
 	nf_ct_dump_tuple(t);
@@ -91,20 +99,22 @@ static __be16 gre_keymap_lookup(struct nf_conntrack_tuple *t)
 int nf_ct_gre_keymap_add(struct nf_conn *ct, enum ip_conntrack_dir dir,
 			 struct nf_conntrack_tuple *t)
 {
+	struct net *net = nf_ct_net(ct);
+	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
 	struct nf_conn_help *help = nfct_help(ct);
 	struct nf_ct_gre_keymap **kmp, *km;
 
 	kmp = &help->help.ct_pptp_info.keymap[dir];
 	if (*kmp) {
 		/* check whether it's a retransmission */
-		read_lock_bh(&nf_ct_gre_lock);
-		list_for_each_entry(km, &gre_keymap_list, list) {
+		read_lock_bh(&net_gre->keymap_lock);
+		list_for_each_entry(km, &net_gre->keymap_list, list) {
 			if (gre_key_cmpfn(km, t) && km == *kmp) {
-				read_unlock_bh(&nf_ct_gre_lock);
+				read_unlock_bh(&net_gre->keymap_lock);
 				return 0;
 			}
 		}
-		read_unlock_bh(&nf_ct_gre_lock);
+		read_unlock_bh(&net_gre->keymap_lock);
 		pr_debug("trying to override keymap_%s for ct %p\n",
 			 dir == IP_CT_DIR_REPLY ? "reply" : "orig", ct);
 		return -EEXIST;
@@ -119,9 +129,9 @@ int nf_ct_gre_keymap_add(struct nf_conn *ct, enum ip_conntrack_dir dir,
 	pr_debug("adding new entry %p: ", km);
 	nf_ct_dump_tuple(&km->tuple);
 
-	write_lock_bh(&nf_ct_gre_lock);
-	list_add_tail(&km->list, &gre_keymap_list);
-	write_unlock_bh(&nf_ct_gre_lock);
+	write_lock_bh(&net_gre->keymap_lock);
+	list_add_tail(&km->list, &net_gre->keymap_list);
+	write_unlock_bh(&net_gre->keymap_lock);
 
 	return 0;
 }
@@ -130,12 +140,14 @@ EXPORT_SYMBOL_GPL(nf_ct_gre_keymap_add);
 /* destroy the keymap entries associated with specified master ct */
 void nf_ct_gre_keymap_destroy(struct nf_conn *ct)
 {
+	struct net *net = nf_ct_net(ct);
+	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
 	struct nf_conn_help *help = nfct_help(ct);
 	enum ip_conntrack_dir dir;
 
 	pr_debug("entering for ct %p\n", ct);
 
-	write_lock_bh(&nf_ct_gre_lock);
+	write_lock_bh(&net_gre->keymap_lock);
 	for (dir = IP_CT_DIR_ORIGINAL; dir < IP_CT_DIR_MAX; dir++) {
 		if (help->help.ct_pptp_info.keymap[dir]) {
 			pr_debug("removing %p from list\n",
@@ -145,7 +157,7 @@ void nf_ct_gre_keymap_destroy(struct nf_conn *ct)
 			help->help.ct_pptp_info.keymap[dir] = NULL;
 		}
 	}
-	write_unlock_bh(&nf_ct_gre_lock);
+	write_unlock_bh(&net_gre->keymap_lock);
 }
 EXPORT_SYMBOL_GPL(nf_ct_gre_keymap_destroy);
 
@@ -164,6 +176,7 @@ static bool gre_invert_tuple(struct nf_conntrack_tuple *tuple,
 static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 			     struct nf_conntrack_tuple *tuple)
 {
+	struct net *net = dev_net(skb->dev ? skb->dev : skb->dst->dev);
 	const struct gre_hdr_pptp *pgrehdr;
 	struct gre_hdr_pptp _pgrehdr;
 	__be16 srckey;
@@ -190,7 +203,7 @@ static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 	}
 
 	tuple->dst.u.gre.key = pgrehdr->call_id;
-	srckey = gre_keymap_lookup(tuple);
+	srckey = gre_keymap_lookup(net, tuple);
 	tuple->src.u.gre.key = srckey;
 
 	return true;
@@ -287,15 +300,53 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 #endif
 };
 
+static int proto_gre_net_init(struct net *net)
+{
+	struct netns_proto_gre *net_gre;
+	int rv;
+
+	net_gre = kmalloc(sizeof(struct netns_proto_gre), GFP_KERNEL);
+	if (!net_gre)
+		return -ENOMEM;
+	rwlock_init(&net_gre->keymap_lock);
+	INIT_LIST_HEAD(&net_gre->keymap_list);
+
+	rv = net_assign_generic(net, proto_gre_net_id, net_gre);
+	if (rv < 0)
+		kfree(net_gre);
+	return rv;
+}
+
+static void proto_gre_net_exit(struct net *net)
+{
+	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
+
+	nf_ct_gre_keymap_flush(net);
+	kfree(net_gre);
+}
+
+static struct pernet_operations proto_gre_net_ops = {
+	.init = proto_gre_net_init,
+	.exit = proto_gre_net_exit,
+};
+
 static int __init nf_ct_proto_gre_init(void)
 {
-	return nf_conntrack_l4proto_register(&nf_conntrack_l4proto_gre4);
+	int rv;
+
+	rv = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_gre4);
+	if (rv < 0)
+		return rv;
+	rv = register_pernet_gen_device(&proto_gre_net_id, &proto_gre_net_ops);
+	if (rv < 0)
+		nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
+	return rv;
 }
 
 static void nf_ct_proto_gre_fini(void)
 {
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
-	nf_ct_gre_keymap_flush();
+	unregister_pernet_gen_device(proto_gre_net_id, &proto_gre_net_ops);
 }
 
 module_init(nf_ct_proto_gre_init);
-- 
1.5.6.3


