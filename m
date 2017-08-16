From: David Lamparter <equinox@diac24.net>
Subject: [PATCH 1/6] bridge: learn dst metadata in FDB
Date: Wed, 16 Aug 2017 19:01:57 +0200
Message-ID: <20170816170202.456851-2-equinox@diac24.net>
References: <20170816170202.456851-1-equinox@diac24.net>
Cc: amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        David Lamparter <equinox@diac24.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:43692 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752337AbdHPRCS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 13:02:18 -0400
In-Reply-To: <20170816170202.456851-1-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements holding dst metadata information in the bridge layer,
but only for unicast entries in the MAC table.  Multicast is still left
to design and implement.

Signed-off-by: David Lamparter <equinox@diac24.net>
---
 include/net/dst_metadata.h | 19 +++++++++++++------
 net/bridge/br_device.c     |  4 ++++
 net/bridge/br_fdb.c        | 45 +++++++++++++++++++++++++++++++--------------
 net/bridge/br_input.c      |  6 ++++--
 net/bridge/br_private.h    |  4 +++-
 5 files changed, 55 insertions(+), 23 deletions(-)

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index a803129a4849..8858dc441458 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -56,16 +56,15 @@ static inline bool skb_valid_dst(const struct sk_buff *skb)
 	return dst && !(dst->flags & DST_METADATA);
 }
 
-static inline int skb_metadata_dst_cmp(const struct sk_buff *skb_a,
-				       const struct sk_buff *skb_b)
+static inline int dst_metadata_cmp(const struct dst_entry *dst_a,
+				   const struct dst_entry *dst_b)
 {
 	const struct metadata_dst *a, *b;
-
-	if (!(skb_a->_skb_refdst | skb_b->_skb_refdst))
+	if (!(dst_a || dst_b))
 		return 0;
 
-	a = (const struct metadata_dst *) skb_dst(skb_a);
-	b = (const struct metadata_dst *) skb_dst(skb_b);
+	a = (const struct metadata_dst *) dst_a;
+	b = (const struct metadata_dst *) dst_b;
 
 	if (!a != !b || a->type != b->type)
 		return 1;
@@ -83,6 +82,14 @@ static inline int skb_metadata_dst_cmp(const struct sk_buff *skb_a,
 	}
 }
 
+static inline int skb_metadata_dst_cmp(const struct sk_buff *skb_a,
+				       const struct sk_buff *skb_b)
+{
+	if (!(skb_a->_skb_refdst | skb_b->_skb_refdst))
+		return 0;
+	return dst_metadata_cmp(skb_dst(skb_a), skb_dst(skb_b));
+}
+
 void metadata_dst_free(struct metadata_dst *);
 struct metadata_dst *metadata_dst_alloc(u8 optslen, enum metadata_type type,
 					gfp_t flags);
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 861ae2a165f4..534cacf02f8d 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -53,6 +53,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	brstats->tx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
+	skb_dst_drop(skb);
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
 	skb_reset_mac_header(skb);
@@ -81,6 +82,9 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 		else
 			br_flood(br, skb, BR_PKT_MULTICAST, false, true);
 	} else if ((dst = br_fdb_find_rcu(br, dest, vid)) != NULL) {
+		struct dst_entry *md_dst = rcu_dereference(dst->md_dst);
+		if (md_dst)
+			skb_dst_set_noref(skb, md_dst);
 		br_forward(dst->dst, skb, false, true);
 	} else {
 		br_flood(br, skb, BR_PKT_UNICAST, false, true);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index a79b648aac88..0751fcb89699 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -25,11 +25,13 @@
 #include <asm/unaligned.h>
 #include <linux/if_vlan.h>
 #include <net/switchdev.h>
+#include <net/dst_metadata.h>
 #include "br_private.h"
 
 static struct kmem_cache *br_fdb_cache __read_mostly;
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		      const unsigned char *addr, u16 vid);
+		      struct dst_entry *md_dst, const unsigned char *addr,
+		      u16 vid);
 static void fdb_notify(struct net_bridge *br,
 		       const struct net_bridge_fdb_entry *, int);
 
@@ -174,6 +176,8 @@ static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 	if (f->is_static)
 		fdb_del_hw_addr(br, f->addr.addr);
 
+	dst_release(rcu_access_pointer(f->md_dst));
+
 	hlist_del_init_rcu(&f->hlist);
 	fdb_notify(br, f, RTM_DELNEIGH);
 	call_rcu(&f->rcu, fdb_rcu_free);
@@ -260,7 +264,7 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 
 insert:
 	/* insert new address,  may fail if invalid address or dup. */
-	fdb_insert(br, p, newaddr, 0);
+	fdb_insert(br, p, NULL, newaddr, 0);
 
 	if (!vg || !vg->num_vlans)
 		goto done;
@@ -270,7 +274,7 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 	 * from under us.
 	 */
 	list_for_each_entry(v, &vg->vlan_list, vlist)
-		fdb_insert(br, p, newaddr, v->vid);
+		fdb_insert(br, p, NULL, newaddr, v->vid);
 
 done:
 	spin_unlock_bh(&br->hash_lock);
@@ -289,10 +293,11 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	if (f && f->is_local && !f->dst && !f->added_by_user)
 		fdb_delete_local(br, NULL, f);
 
-	fdb_insert(br, NULL, newaddr, 0);
+	fdb_insert(br, NULL, NULL, newaddr, 0);
 	vg = br_vlan_group(br);
 	if (!vg || !vg->num_vlans)
 		goto out;
+
 	/* Now remove and add entries for every VLAN configured on the
 	 * bridge.  This function runs under RTNL so the bitmap will not
 	 * change from under us.
@@ -303,7 +308,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 		f = br_fdb_find(br, br->dev->dev_addr, v->vid);
 		if (f && f->is_local && !f->dst && !f->added_by_user)
 			fdb_delete_local(br, NULL, f);
-		fdb_insert(br, NULL, newaddr, v->vid);
+		fdb_insert(br, NULL, NULL, newaddr, v->vid);
 	}
 out:
 	spin_unlock_bh(&br->hash_lock);
@@ -477,6 +482,7 @@ int br_fdb_fillbuf(struct net_bridge *br, void *buf,
 
 static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 					       struct net_bridge_port *source,
+					       struct dst_entry *md_dst,
 					       const unsigned char *addr,
 					       __u16 vid,
 					       unsigned char is_local,
@@ -488,6 +494,7 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 	if (fdb) {
 		memcpy(fdb->addr.addr, addr, ETH_ALEN);
 		fdb->dst = source;
+		rcu_assign_pointer(fdb->md_dst, dst_clone(md_dst));
 		fdb->vlan_id = vid;
 		fdb->is_local = is_local;
 		fdb->is_static = is_static;
@@ -501,7 +508,8 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 }
 
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		  const unsigned char *addr, u16 vid)
+		      struct dst_entry *md_dst, const unsigned char *addr,
+		      u16 vid)
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
@@ -521,7 +529,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		fdb_delete(br, fdb);
 	}
 
-	fdb = fdb_create(head, source, addr, vid, 1, 1);
+	fdb = fdb_create(head, source, md_dst, addr, vid, 1, 1);
 	if (!fdb)
 		return -ENOMEM;
 
@@ -537,13 +545,14 @@ int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 	int ret;
 
 	spin_lock_bh(&br->hash_lock);
-	ret = fdb_insert(br, source, addr, vid);
+	ret = fdb_insert(br, source, NULL, addr, vid);
 	spin_unlock_bh(&br->hash_lock);
 	return ret;
 }
 
 void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
-		   const unsigned char *addr, u16 vid, bool added_by_user)
+		   struct dst_entry *md_dst, const unsigned char *addr,
+		   u16 vid, bool added_by_user)
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
@@ -558,6 +567,9 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 	      source->state == BR_STATE_FORWARDING))
 		return;
 
+	if (md_dst && !(md_dst->flags & DST_METADATA))
+		md_dst = NULL;
+
 	fdb = fdb_find_rcu(head, addr, vid);
 	if (likely(fdb)) {
 		/* attempt to update an entry for a local interface */
@@ -567,10 +579,15 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 					source->dev->name, addr, vid);
 		} else {
 			unsigned long now = jiffies;
+			struct dst_entry *ref_md = rcu_access_pointer(fdb->md_dst);
 
 			/* fastpath: update of existing entry */
-			if (unlikely(source != fdb->dst)) {
+			if (unlikely(source != fdb->dst ||
+			    dst_metadata_cmp(md_dst, ref_md))) {
 				fdb->dst = source;
+				dst_release(ref_md);
+				rcu_assign_pointer(fdb->md_dst,
+						dst_clone(md_dst));
 				fdb_modified = true;
 				/* Take over HW learned entry */
 				if (unlikely(fdb->added_by_external_learn))
@@ -586,7 +603,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 	} else {
 		spin_lock(&br->hash_lock);
 		if (likely(!fdb_find_rcu(head, addr, vid))) {
-			fdb = fdb_create(head, source, addr, vid, 0, 0);
+			fdb = fdb_create(head, source, md_dst, addr, vid, 0, 0);
 			if (fdb) {
 				if (unlikely(added_by_user))
 					fdb->added_by_user = 1;
@@ -781,7 +798,7 @@ static int fdb_add_entry(struct net_bridge *br, struct net_bridge_port *source,
 		if (!(flags & NLM_F_CREATE))
 			return -ENOENT;
 
-		fdb = fdb_create(head, source, addr, vid, 0, 0);
+		fdb = fdb_create(head, source, NULL, addr, vid, 0, 0);
 		if (!fdb)
 			return -ENOMEM;
 
@@ -844,7 +861,7 @@ static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge *br,
 		}
 		local_bh_disable();
 		rcu_read_lock();
-		br_fdb_update(br, p, addr, vid, true);
+		br_fdb_update(br, p, NULL, addr, vid, true);
 		rcu_read_unlock();
 		local_bh_enable();
 	} else if (ndm->ndm_flags & NTF_EXT_LEARNED) {
@@ -1071,7 +1088,7 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 	head = &br->hash[br_mac_hash(addr, vid)];
 	fdb = br_fdb_find(br, addr, vid);
 	if (!fdb) {
-		fdb = fdb_create(head, p, addr, vid, 0, 0);
+		fdb = fdb_create(head, p, NULL, addr, vid, 0, 0);
 		if (!fdb) {
 			err = -ENOMEM;
 			goto err_unlock;
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 7637f58c1226..df10c87b2499 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -150,7 +150,8 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
 	if (p->flags & BR_LEARNING)
-		br_fdb_update(br, p, eth_hdr(skb)->h_source, vid, false);
+		br_fdb_update(br, p, skb_dst(skb), eth_hdr(skb)->h_source,
+			      vid, false);
 
 	local_rcv = !!(br->dev->flags & IFF_PROMISC);
 	dest = eth_hdr(skb)->h_dest;
@@ -230,7 +231,8 @@ static void __br_handle_local_finish(struct sk_buff *skb)
 
 	/* check if vlan is allowed, to avoid spoofing */
 	if (p->flags & BR_LEARNING && br_should_learn(p, skb, &vid))
-		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid, false);
+		br_fdb_update(p->br, p, skb_dst(skb),
+				eth_hdr(skb)->h_source, vid, false);
 }
 
 /* note: already called with rcu_read_lock */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index fd9ee73e0a6d..b73f34ed765f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -164,6 +164,7 @@ struct net_bridge_vlan_group {
 struct net_bridge_fdb_entry {
 	struct hlist_node		hlist;
 	struct net_bridge_port		*dst;
+	struct dst_entry __rcu		*md_dst;
 
 	mac_addr			addr;
 	__u16				vlan_id;
@@ -524,7 +525,8 @@ int br_fdb_fillbuf(struct net_bridge *br, void *buf, unsigned long count,
 int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		  const unsigned char *addr, u16 vid);
 void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
-		   const unsigned char *addr, u16 vid, bool added_by_user);
+		   struct dst_entry *md_dst, const unsigned char *addr,
+		   u16 vid, bool added_by_user);
 
 int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 		  struct net_device *dev, const unsigned char *addr, u16 vid);
-- 
2.13.0
