From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 5/6] switchdev: remove FIB offload infrastructure
Date: Mon, 26 Sep 2016 12:52:33 +0200
Message-ID: <1474887154-6286-6-git-send-email-jiri@resnulli.us>
References: <1474887154-6286-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com, kaber@trash.net, john@phrozen.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33077 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966086AbcIZKwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 06:52:46 -0400
Received: by mail-wm0-f68.google.com with SMTP id w84so13469271wmg.0
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 03:52:45 -0700 (PDT)
In-Reply-To: <1474887154-6286-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since this is now taken care of by FIB notifier, remove the code, with
all unused dependencies.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip_fib.h      |   2 -
 include/net/switchdev.h   |  40 ----------
 net/ipv4/fib_frontend.c   |  13 ----
 net/ipv4/fib_rules.c      |   2 -
 net/ipv4/fib_trie.c       | 104 +-------------------------
 net/switchdev/switchdev.c | 181 ----------------------------------------------
 6 files changed, 1 insertion(+), 341 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index ffccf17..b9314b4 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -243,7 +243,6 @@ int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
 		   struct netlink_callback *cb);
 int fib_table_flush(struct net *net, struct fib_table *table);
 struct fib_table *fib_trie_unmerge(struct fib_table *main_tb);
-void fib_table_flush_external(struct fib_table *table);
 void fib_free_table(struct fib_table *tb);
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
@@ -356,7 +355,6 @@ static inline int fib_num_tclassid_users(struct net *net)
 }
 #endif
 int fib_unmerge(struct net *net);
-void fib_flush_external(struct net *net);
 
 /* Exported by fib_semantics.c */
 int ip_fib_check_default(__be32 gw, struct net_device *dev);
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 729fe15..eba80c4 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -68,7 +68,6 @@ struct switchdev_attr {
 enum switchdev_obj_id {
 	SWITCHDEV_OBJ_ID_UNDEFINED,
 	SWITCHDEV_OBJ_ID_PORT_VLAN,
-	SWITCHDEV_OBJ_ID_IPV4_FIB,
 	SWITCHDEV_OBJ_ID_PORT_FDB,
 	SWITCHDEV_OBJ_ID_PORT_MDB,
 };
@@ -92,21 +91,6 @@ struct switchdev_obj_port_vlan {
 #define SWITCHDEV_OBJ_PORT_VLAN(obj) \
 	container_of(obj, struct switchdev_obj_port_vlan, obj)
 
-/* SWITCHDEV_OBJ_ID_IPV4_FIB */
-struct switchdev_obj_ipv4_fib {
-	struct switchdev_obj obj;
-	u32 dst;
-	int dst_len;
-	struct fib_info *fi;
-	u8 tos;
-	u8 type;
-	u32 nlflags;
-	u32 tb_id;
-};
-
-#define SWITCHDEV_OBJ_IPV4_FIB(obj) \
-	container_of(obj, struct switchdev_obj_ipv4_fib, obj)
-
 /* SWITCHDEV_OBJ_ID_PORT_FDB */
 struct switchdev_obj_port_fdb {
 	struct switchdev_obj obj;
@@ -209,11 +193,6 @@ int switchdev_port_bridge_setlink(struct net_device *dev,
 				  struct nlmsghdr *nlh, u16 flags);
 int switchdev_port_bridge_dellink(struct net_device *dev,
 				  struct nlmsghdr *nlh, u16 flags);
-int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
-			   u8 tos, u8 type, u32 nlflags, u32 tb_id);
-int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
-			   u8 tos, u8 type, u32 tb_id);
-void switchdev_fib_ipv4_abort(struct fib_info *fi);
 int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			   struct net_device *dev, const unsigned char *addr,
 			   u16 vid, u16 nlm_flags);
@@ -304,25 +283,6 @@ static inline int switchdev_port_bridge_dellink(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static inline int switchdev_fib_ipv4_add(u32 dst, int dst_len,
-					 struct fib_info *fi,
-					 u8 tos, u8 type,
-					 u32 nlflags, u32 tb_id)
-{
-	return 0;
-}
-
-static inline int switchdev_fib_ipv4_del(u32 dst, int dst_len,
-					 struct fib_info *fi,
-					 u8 tos, u8 type, u32 tb_id)
-{
-	return 0;
-}
-
-static inline void switchdev_fib_ipv4_abort(struct fib_info *fi)
-{
-}
-
 static inline int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 					 struct net_device *dev,
 					 const unsigned char *addr,
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 86c43dc..c3b8047 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -189,19 +189,6 @@ static void fib_flush(struct net *net)
 		rt_cache_flush(net);
 }
 
-void fib_flush_external(struct net *net)
-{
-	struct fib_table *tb;
-	struct hlist_head *head;
-	unsigned int h;
-
-	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
-		head = &net->ipv4.fib_table_hash[h];
-		hlist_for_each_entry(tb, head, tb_hlist)
-			fib_table_flush_external(tb);
-	}
-}
-
 /*
  * Find address type as if only "dev" was present in the system. If
  * on_dev is NULL then all interfaces are taken into consideration.
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index ebadf6b..2e50062 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -228,7 +228,6 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	rule4->tos = frh->tos;
 
 	net->ipv4.fib_has_custom_rules = true;
-	fib_flush_external(rule->fr_net);
 	call_fib_rule_notifiers(net, FIB_EVENT_RULE_ADD);
 
 	err = 0;
@@ -251,7 +250,6 @@ static int fib4_rule_delete(struct fib_rule *rule)
 		net->ipv4.fib_num_tclassid_users--;
 #endif
 	net->ipv4.fib_has_custom_rules = true;
-	fib_flush_external(rule->fr_net);
 	call_fib_rule_notifiers(net, FIB_EVENT_RULE_DEL);
 errout:
 	return err;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 51a4537..31cef36 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -81,7 +81,6 @@
 #include <net/tcp.h>
 #include <net/sock.h>
 #include <net/ip_fib.h>
-#include <net/switchdev.h>
 #include <trace/events/fib.h>
 #include "fib_lookup.h"
 
@@ -1215,17 +1214,6 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 			new_fa->tb_id = tb->tb_id;
 			new_fa->fa_default = -1;
 
-			err = switchdev_fib_ipv4_add(key, plen, fi,
-						     new_fa->fa_tos,
-						     cfg->fc_type,
-						     cfg->fc_nlflags,
-						     tb->tb_id);
-			if (err) {
-				switchdev_fib_ipv4_abort(fi);
-				kmem_cache_free(fn_alias_kmem, new_fa);
-				goto out;
-			}
-
 			hlist_replace_rcu(&fa->fa_list, &new_fa->fa_list);
 
 			alias_free_mem_rcu(fa);
@@ -1273,18 +1261,10 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 	new_fa->tb_id = tb->tb_id;
 	new_fa->fa_default = -1;
 
-	/* (Optionally) offload fib entry to switch hardware. */
-	err = switchdev_fib_ipv4_add(key, plen, fi, tos, cfg->fc_type,
-				     cfg->fc_nlflags, tb->tb_id);
-	if (err) {
-		switchdev_fib_ipv4_abort(fi);
-		goto out_free_new_fa;
-	}
-
 	/* Insert new entry to the list. */
 	err = fib_insert_alias(t, tp, l, new_fa, fa, key);
 	if (err)
-		goto out_sw_fib_del;
+		goto out_free_new_fa;
 
 	if (!plen)
 		tb->tb_num_default++;
@@ -1297,8 +1277,6 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 succeeded:
 	return 0;
 
-out_sw_fib_del:
-	switchdev_fib_ipv4_del(key, plen, fi, tos, cfg->fc_type, tb->tb_id);
 out_free_new_fa:
 	kmem_cache_free(fn_alias_kmem, new_fa);
 out:
@@ -1591,9 +1569,6 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 	if (!fa_to_delete)
 		return -ESRCH;
 
-	switchdev_fib_ipv4_del(key, plen, fa_to_delete->fa_info, tos,
-			       cfg->fc_type, tb->tb_id);
-
 	call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, key, plen,
 				 fa_to_delete->fa_info, tos, cfg->fc_type,
 				 tb->tb_id, 0);
@@ -1785,80 +1760,6 @@ out:
 	return NULL;
 }
 
-/* Caller must hold RTNL */
-void fib_table_flush_external(struct fib_table *tb)
-{
-	struct trie *t = (struct trie *)tb->tb_data;
-	struct key_vector *pn = t->kv;
-	unsigned long cindex = 1;
-	struct hlist_node *tmp;
-	struct fib_alias *fa;
-
-	/* walk trie in reverse order */
-	for (;;) {
-		unsigned char slen = 0;
-		struct key_vector *n;
-
-		if (!(cindex--)) {
-			t_key pkey = pn->key;
-
-			/* cannot resize the trie vector */
-			if (IS_TRIE(pn))
-				break;
-
-			/* resize completed node */
-			pn = resize(t, pn);
-			cindex = get_index(pkey, pn);
-
-			continue;
-		}
-
-		/* grab the next available node */
-		n = get_child(pn, cindex);
-		if (!n)
-			continue;
-
-		if (IS_TNODE(n)) {
-			/* record pn and cindex for leaf walking */
-			pn = n;
-			cindex = 1ul << n->bits;
-
-			continue;
-		}
-
-		hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
-			struct fib_info *fi = fa->fa_info;
-
-			/* if alias was cloned to local then we just
-			 * need to remove the local copy from main
-			 */
-			if (tb->tb_id != fa->tb_id) {
-				hlist_del_rcu(&fa->fa_list);
-				alias_free_mem_rcu(fa);
-				continue;
-			}
-
-			/* record local slen */
-			slen = fa->fa_slen;
-
-			if (!fi || !(fi->fib_flags & RTNH_F_OFFLOAD))
-				continue;
-
-			switchdev_fib_ipv4_del(n->key, KEYLENGTH - fa->fa_slen,
-					       fi, fa->fa_tos, fa->fa_type,
-					       tb->tb_id);
-		}
-
-		/* update leaf slen */
-		n->slen = slen;
-
-		if (hlist_empty(&n->leaf)) {
-			put_child_root(pn, n->key, NULL);
-			node_free(n);
-		}
-	}
-}
-
 /* Caller must hold RTNL. */
 int fib_table_flush(struct net *net, struct fib_table *tb)
 {
@@ -1909,9 +1810,6 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 				continue;
 			}
 
-			switchdev_fib_ipv4_del(n->key, KEYLENGTH - fa->fa_slen,
-					       fi, fa->fa_tos, fa->fa_type,
-					       tb->tb_id);
 			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL,
 						 n->key,
 						 KEYLENGTH - fa->fa_slen,
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index abd8d2a..02beb35 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -21,7 +21,6 @@
 #include <linux/workqueue.h>
 #include <linux/if_vlan.h>
 #include <linux/rtnetlink.h>
-#include <net/ip_fib.h>
 #include <net/switchdev.h>
 
 /**
@@ -344,8 +343,6 @@ static size_t switchdev_obj_size(const struct switchdev_obj *obj)
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		return sizeof(struct switchdev_obj_port_vlan);
-	case SWITCHDEV_OBJ_ID_IPV4_FIB:
-		return sizeof(struct switchdev_obj_ipv4_fib);
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		return sizeof(struct switchdev_obj_port_fdb);
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
@@ -1108,184 +1105,6 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_dump);
 
-static struct net_device *switchdev_get_lowest_dev(struct net_device *dev)
-{
-	const struct switchdev_ops *ops = dev->switchdev_ops;
-	struct net_device *lower_dev;
-	struct net_device *port_dev;
-	struct list_head *iter;
-
-	/* Recusively search down until we find a sw port dev.
-	 * (A sw port dev supports switchdev_port_attr_get).
-	 */
-
-	if (ops && ops->switchdev_port_attr_get)
-		return dev;
-
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		port_dev = switchdev_get_lowest_dev(lower_dev);
-		if (port_dev)
-			return port_dev;
-	}
-
-	return NULL;
-}
-
-static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
-{
-	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
-	};
-	struct switchdev_attr prev_attr;
-	struct net_device *dev = NULL;
-	int nhsel;
-
-	ASSERT_RTNL();
-
-	/* For this route, all nexthop devs must be on the same switch. */
-
-	for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
-		const struct fib_nh *nh = &fi->fib_nh[nhsel];
-
-		if (!nh->nh_dev)
-			return NULL;
-
-		dev = switchdev_get_lowest_dev(nh->nh_dev);
-		if (!dev)
-			return NULL;
-
-		attr.orig_dev = dev;
-		if (switchdev_port_attr_get(dev, &attr))
-			return NULL;
-
-		if (nhsel > 0 &&
-		    !netdev_phys_item_id_same(&prev_attr.u.ppid, &attr.u.ppid))
-				return NULL;
-
-		prev_attr = attr;
-	}
-
-	return dev;
-}
-
-/**
- *	switchdev_fib_ipv4_add - Add/modify switch IPv4 route entry
- *
- *	@dst: route's IPv4 destination address
- *	@dst_len: destination address length (prefix length)
- *	@fi: route FIB info structure
- *	@tos: route TOS
- *	@type: route type
- *	@nlflags: netlink flags passed in (NLM_F_*)
- *	@tb_id: route table ID
- *
- *	Add/modify switch IPv4 route entry.
- */
-int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
-			   u8 tos, u8 type, u32 nlflags, u32 tb_id)
-{
-	struct switchdev_obj_ipv4_fib ipv4_fib = {
-		.obj.id = SWITCHDEV_OBJ_ID_IPV4_FIB,
-		.dst = dst,
-		.dst_len = dst_len,
-		.fi = fi,
-		.tos = tos,
-		.type = type,
-		.nlflags = nlflags,
-		.tb_id = tb_id,
-	};
-	struct net_device *dev;
-	int err = 0;
-
-	/* Don't offload route if using custom ip rules or if
-	 * IPv4 FIB offloading has been disabled completely.
-	 */
-
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-	if (fi->fib_net->ipv4.fib_has_custom_rules)
-		return 0;
-#endif
-
-	if (fi->fib_net->ipv4.fib_offload_disabled)
-		return 0;
-
-	dev = switchdev_get_dev_by_nhs(fi);
-	if (!dev)
-		return 0;
-
-	ipv4_fib.obj.orig_dev = dev;
-	err = switchdev_port_obj_add(dev, &ipv4_fib.obj);
-	if (!err)
-		fib_info_offload_inc(fi);
-
-	return err == -EOPNOTSUPP ? 0 : err;
-}
-EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_add);
-
-/**
- *	switchdev_fib_ipv4_del - Delete IPv4 route entry from switch
- *
- *	@dst: route's IPv4 destination address
- *	@dst_len: destination address length (prefix length)
- *	@fi: route FIB info structure
- *	@tos: route TOS
- *	@type: route type
- *	@tb_id: route table ID
- *
- *	Delete IPv4 route entry from switch device.
- */
-int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
-			   u8 tos, u8 type, u32 tb_id)
-{
-	struct switchdev_obj_ipv4_fib ipv4_fib = {
-		.obj.id = SWITCHDEV_OBJ_ID_IPV4_FIB,
-		.dst = dst,
-		.dst_len = dst_len,
-		.fi = fi,
-		.tos = tos,
-		.type = type,
-		.nlflags = 0,
-		.tb_id = tb_id,
-	};
-	struct net_device *dev;
-	int err = 0;
-
-	if (!(fi->fib_flags & RTNH_F_OFFLOAD))
-		return 0;
-
-	dev = switchdev_get_dev_by_nhs(fi);
-	if (!dev)
-		return 0;
-
-	ipv4_fib.obj.orig_dev = dev;
-	err = switchdev_port_obj_del(dev, &ipv4_fib.obj);
-	if (!err)
-		fib_info_offload_dec(fi);
-
-	return err == -EOPNOTSUPP ? 0 : err;
-}
-EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_del);
-
-/**
- *	switchdev_fib_ipv4_abort - Abort an IPv4 FIB operation
- *
- *	@fi: route FIB info structure
- */
-void switchdev_fib_ipv4_abort(struct fib_info *fi)
-{
-	/* There was a problem installing this route to the offload
-	 * device.  For now, until we come up with more refined
-	 * policy handling, abruptly end IPv4 fib offloading for
-	 * for entire net by flushing offload device(s) of all
-	 * IPv4 routes, and mark IPv4 fib offloading broken from
-	 * this point forward.
-	 */
-
-	fib_flush_external(fi->fib_net);
-	fi->fib_net->ipv4.fib_offload_disabled = true;
-}
-EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_abort);
-
 bool switchdev_port_same_parent_id(struct net_device *a,
 				   struct net_device *b)
 {
-- 
2.5.5
