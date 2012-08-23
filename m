From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH bridge 2/5] bridge: Add vlan to unicast fdb entries
Date: Thu, 23 Aug 2012 15:29:52 -0400
Message-ID: <1345750195-31598-3-git-send-email-vyasevic@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759156Ab2HWT37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 15:29:59 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7NJTxfp013086
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 15:29:59 -0400
In-Reply-To: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds vlan to unicast fdb entries that are created for
learned addresses (not the manually configured ones).  It adds
vlan id into the hash mix and uses vlan as an addditional parameter
for an entry match.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/if_bridge.h |    1 +
 net/bridge/br_device.c    |    2 +-
 net/bridge/br_fdb.c       |   71 ++++++++++++++++++++++++++------------------
 net/bridge/br_input.c     |   14 ++++++---
 net/bridge/br_private.h   |    7 +++-
 5 files changed, 58 insertions(+), 37 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index dd3f201..288ff10 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -95,6 +95,7 @@ struct __fdb_entry {
 	__u8 port_hi;
 	__u8 pad0;
 	__u16 unused;
+#define fdb_vid unused
 };
 
 #ifdef __KERNEL__
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 3334845..e321b9d 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -66,7 +66,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 			br_multicast_deliver(mdst, skb);
 		else
 			br_flood_deliver(br, skb);
-	} else if ((dst = __br_fdb_get(br, dest)) != NULL)
+	} else if ((dst = __br_fdb_get(br, dest, vlan_tx_tag_get(skb))) != NULL)
 		br_deliver(dst->dst, skb);
 	else
 		br_flood_deliver(br, skb);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index d21f323..478ca1d 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -23,6 +23,7 @@
 #include <linux/slab.h>
 #include <linux/atomic.h>
 #include <asm/unaligned.h>
+#include <linux/if_vlan.h>
 #include "br_private.h"
 
 static struct kmem_cache *br_fdb_cache __read_mostly;
@@ -67,11 +68,12 @@ static inline int has_expired(const struct net_bridge *br,
 		time_before_eq(fdb->updated + hold_time(br), jiffies);
 }
 
-static inline int br_mac_hash(const unsigned char *mac)
+static inline int br_mac_hash(const unsigned char *mac, __u16 vlan_tci)
 {
-	/* use 1 byte of OUI cnd 3 bytes of NIC */
+	/* use 1 byte of OUI and 3 bytes of NIC */
 	u32 key = get_unaligned((u32 *)(mac + 2));
-	return jhash_1word(key, fdb_salt) & (BR_HASH_SIZE - 1);
+	return jhash_2words(key, (vlan_tci & VLAN_VID_MASK),
+				fdb_salt) & (BR_HASH_SIZE - 1);
 }
 
 static void fdb_rcu_free(struct rcu_head *head)
@@ -132,7 +134,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	struct net_bridge_fdb_entry *f;
 
 	/* If old entry was unassociated with any port, then delete it. */
-	f = __br_fdb_get(br, br->dev->dev_addr);
+	f = __br_fdb_get(br, br->dev->dev_addr, 0);
 	if (f && f->is_local && !f->dst)
 		fdb_delete(br, f);
 
@@ -231,13 +233,16 @@ void br_fdb_delete_by_port(struct net_bridge *br,
 
 /* No locking or refcounting, assumes caller has rcu_read_lock */
 struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
-					  const unsigned char *addr)
+					  const unsigned char *addr,
+					  __u16 vlan_tci)
 {
 	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
 
-	hlist_for_each_entry_rcu(fdb, h, &br->hash[br_mac_hash(addr)], hlist) {
-		if (ether_addr_equal(fdb->addr.addr, addr)) {
+	hlist_for_each_entry_rcu(fdb, h,
+				&br->hash[br_mac_hash(addr, vlan_tci)], hlist) {
+		if (ether_addr_equal(fdb->addr.addr, addr) &&
+		    fdb->vlan_id == (vlan_tci & VLAN_VID_MASK) ) {
 			if (unlikely(has_expired(br, fdb)))
 				break;
 			return fdb;
@@ -261,7 +266,7 @@ int br_fdb_test_addr(struct net_device *dev, unsigned char *addr)
 	if (!port)
 		ret = 0;
 	else {
-		fdb = __br_fdb_get(port->br, addr);
+		fdb = __br_fdb_get(port->br, addr, 0);
 		ret = fdb && fdb->dst && fdb->dst->dev != dev &&
 			fdb->dst->state == BR_STATE_FORWARDING;
 	}
@@ -313,6 +318,7 @@ int br_fdb_fillbuf(struct net_bridge *br, void *buf,
 			fe->is_local = f->is_local;
 			if (!f->is_static)
 				fe->ageing_timer_value = jiffies_to_clock_t(jiffies - f->updated);
+			fe->fdb_vid = f->vlan_id;
 			++fe;
 			++num;
 		}
@@ -325,26 +331,30 @@ int br_fdb_fillbuf(struct net_bridge *br, void *buf,
 }
 
 static struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
-					     const unsigned char *addr)
+					     const unsigned char *addr,
+					     __u16 vlan_tci)
 {
 	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
 
 	hlist_for_each_entry(fdb, h, head, hlist) {
-		if (ether_addr_equal(fdb->addr.addr, addr))
+		if (ether_addr_equal(fdb->addr.addr, addr) &&
+		    fdb->vlan_id == (vlan_tci & VLAN_VID_MASK))
 			return fdb;
 	}
 	return NULL;
 }
 
 static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
-						 const unsigned char *addr)
+						 const unsigned char *addr,
+						 __u16 vlan_tci)
 {
 	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
 
 	hlist_for_each_entry_rcu(fdb, h, head, hlist) {
-		if (ether_addr_equal(fdb->addr.addr, addr))
+		if (ether_addr_equal(fdb->addr.addr, addr) &&
+		    fdb->vlan_id == (vlan_tci & VLAN_VID_MASK))
 			return fdb;
 	}
 	return NULL;
@@ -352,7 +362,8 @@ static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
 
 static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 					       struct net_bridge_port *source,
-					       const unsigned char *addr)
+					       const unsigned char *addr,
+					       __u16 vlan_tci)
 {
 	struct net_bridge_fdb_entry *fdb;
 
@@ -360,6 +371,7 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 	if (fdb) {
 		memcpy(fdb->addr.addr, addr, ETH_ALEN);
 		fdb->dst = source;
+		fdb->vlan_id = (vlan_tci & VLAN_VID_MASK);
 		fdb->is_local = 0;
 		fdb->is_static = 0;
 		fdb->updated = fdb->used = jiffies;
@@ -371,13 +383,13 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		  const unsigned char *addr)
 {
-	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, 0)];
 	struct net_bridge_fdb_entry *fdb;
 
 	if (!is_valid_ether_addr(addr))
 		return -EINVAL;
 
-	fdb = fdb_find(head, addr);
+	fdb = fdb_find(head, addr, 0);
 	if (fdb) {
 		/* it is okay to have multiple ports with same
 		 * address, just use the first one.
@@ -390,7 +402,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		fdb_delete(br, fdb);
 	}
 
-	fdb = fdb_create(head, source, addr);
+	fdb = fdb_create(head, source, addr, 0);
 	if (!fdb)
 		return -ENOMEM;
 
@@ -412,9 +424,9 @@ int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 }
 
 void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
-		   const unsigned char *addr)
+		   const unsigned char *addr, __u16 vlan_tci)
 {
-	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan_tci)];
 	struct net_bridge_fdb_entry *fdb;
 
 	/* some users want to always flood. */
@@ -426,7 +438,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 	      source->state == BR_STATE_FORWARDING))
 		return;
 
-	fdb = fdb_find_rcu(head, addr);
+	fdb = fdb_find_rcu(head, addr, vlan_tci);
 	if (likely(fdb)) {
 		/* attempt to update an entry for a local interface */
 		if (unlikely(fdb->is_local)) {
@@ -441,8 +453,8 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		}
 	} else {
 		spin_lock(&br->hash_lock);
-		if (likely(!fdb_find(head, addr))) {
-			fdb = fdb_create(head, source, addr);
+		if (likely(!fdb_find(head, addr, vlan_tci))) {
+			fdb = fdb_create(head, source, addr, vlan_tci);
 			if (fdb)
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
 		}
@@ -571,18 +583,18 @@ out:
 
 /* Update (create or replace) forwarding database entry */
 static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
-			 __u16 state, __u16 flags)
+			 __u16 state, __u16 flags, __u16 vlan_tci)
 {
 	struct net_bridge *br = source->br;
-	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan_tci)];
 	struct net_bridge_fdb_entry *fdb;
 
-	fdb = fdb_find(head, addr);
+	fdb = fdb_find(head, addr, vlan_tci);
 	if (fdb == NULL) {
 		if (!(flags & NLM_F_CREATE))
 			return -ENOENT;
 
-		fdb = fdb_create(head, source, addr);
+		fdb = fdb_create(head, source, addr, vlan_tci);
 		if (!fdb)
 			return -ENOMEM;
 		fdb_notify(br, fdb, RTM_NEWNEIGH);
@@ -628,11 +640,12 @@ int br_fdb_add(struct ndmsg *ndm, struct net_device *dev,
 
 	if (ndm->ndm_flags & NTF_USE) {
 		rcu_read_lock();
-		br_fdb_update(p->br, p, addr);
+		br_fdb_update(p->br, p, addr, 0);
 		rcu_read_unlock();
 	} else {
 		spin_lock_bh(&p->br->hash_lock);
-		err = fdb_add_entry(p, addr, ndm->ndm_state, nlh_flags);
+		err = fdb_add_entry(p, addr, ndm->ndm_state, nlh_flags,
+				0);
 		spin_unlock_bh(&p->br->hash_lock);
 	}
 
@@ -642,10 +655,10 @@ int br_fdb_add(struct ndmsg *ndm, struct net_device *dev,
 static int fdb_delete_by_addr(struct net_bridge_port *p, u8 *addr)
 {
 	struct net_bridge *br = p->br;
-	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, 0)];
 	struct net_bridge_fdb_entry *fdb;
 
-	fdb = fdb_find(head, addr);
+	fdb = fdb_find(head, addr, 0);
 	if (!fdb)
 		return -ENOENT;
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index b7ca3b3..a4579ee 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -62,12 +62,15 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	 * only traffic matching the VLAN filter.
 	 */
 	vlan_map = rcu_dereference(p->vlan_map);
-	if (vlan_map && !test_bit((skb->vlan_tci & VLAN_VID_MASK), vlan_map))
-		goto drop;
+	if (vlan_map && vlan_tx_tag_present(skb)) {
+		unsigned short vid = vlan_tx_tag_get(skb) & VLAN_VID_MASK;
+		if (!test_bit(vid+1, vlan_map))
+			goto drop;
+	}
 
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
-	br_fdb_update(br, p, eth_hdr(skb)->h_source);
+	br_fdb_update(br, p, eth_hdr(skb)->h_source, vlan_tx_tag_get(skb));
 
 	if (!is_broadcast_ether_addr(dest) && is_multicast_ether_addr(dest) &&
 	    br_multicast_rcv(br, p, skb))
@@ -102,7 +105,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
 			skb2 = skb;
 
 		br->dev->stats.multicast++;
-	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
+	} else if ((dst = __br_fdb_get(br, dest, vlan_tx_tag_get(skb))) &&
+			dst->is_local) {
 		skb2 = skb;
 		/* Do not forward the packet since it's local. */
 		skb = NULL;
@@ -131,7 +135,7 @@ static int br_handle_local_finish(struct sk_buff *skb)
 {
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 
-	br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
+	br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vlan_tx_tag_get(skb));
 	return 0;	 /* process further */
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8da90e8..921b927 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -72,6 +72,7 @@ struct net_bridge_fdb_entry
 	unsigned long			updated;
 	unsigned long			used;
 	mac_addr			addr;
+	__u16				vlan_id;
 	unsigned char			is_local;
 	unsigned char			is_static;
 };
@@ -352,7 +353,8 @@ extern void br_fdb_cleanup(unsigned long arg);
 extern void br_fdb_delete_by_port(struct net_bridge *br,
 				  const struct net_bridge_port *p, int do_all);
 extern struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
-						 const unsigned char *addr);
+						 const unsigned char *addr,
+						 __u16 vlan_tci);
 extern int br_fdb_test_addr(struct net_device *dev, unsigned char *addr);
 extern int br_fdb_fillbuf(struct net_bridge *br, void *buf,
 			  unsigned long count, unsigned long off);
@@ -361,7 +363,8 @@ extern int br_fdb_insert(struct net_bridge *br,
 			 const unsigned char *addr);
 extern void br_fdb_update(struct net_bridge *br,
 			  struct net_bridge_port *source,
-			  const unsigned char *addr);
+			  const unsigned char *addr,
+			  __u16 vlan_tci);
 
 extern int br_fdb_delete(struct ndmsg *ndm,
 			 struct net_device *dev,
-- 
1.7.7.6
