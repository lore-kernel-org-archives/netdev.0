From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 05/12] bridge: Add vlan to unicast fdb entries
Date: Tue, 18 Dec 2012 14:00:56 -0500
Message-ID: <1355857263-31197-6-git-send-email-vyasevic@redhat.com>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61894 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755503Ab2LRTBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 14:01:31 -0500
In-Reply-To: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds vlan to unicast fdb entries that are created for
learned addresses (not the manually configured ones).  It adds
vlan id into the hash mix and uses vlan as an addditional parameter
for an entry match.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_bridge.h |    2 +-
 net/bridge/br_device.c         |    6 ++-
 net/bridge/br_fdb.c            |   70 +++++++++++++++++++++++----------------
 net/bridge/br_input.c          |   16 +++++----
 net/bridge/br_private.h        |    7 +++-
 5 files changed, 60 insertions(+), 41 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 9a0f6ff..52aa738 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -94,7 +94,7 @@ struct __fdb_entry {
 	__u32 ageing_timer_value;
 	__u8 port_hi;
 	__u8 pad0;
-	__u16 unused;
+	__u16 fdb_vid;
 };
 
 /* Bridge Flags */
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 57c5bac..1f9d0f9 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -31,6 +31,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_bridge_mdb_entry *mdst;
 	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
 	struct net_bridge_vlan *vlan;
+	u16 vid;
 
 	rcu_read_lock();
 #ifdef CONFIG_BRIDGE_NETFILTER
@@ -51,7 +52,8 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Any vlan transmitted by the bridge itself is permitted.
 	 * Try to cache the vlan in the CB to speed up forwarding.
 	 */
-	vlan = br_vlan_find(br, br_get_vlan(skb));
+	vid = br_get_vlan(skb);
+	vlan = br_vlan_find(br, vid);
 	if (vlan)
 		BR_INPUT_SKB_CB(skb)->vlan = vlan;
 
@@ -75,7 +77,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 			br_multicast_deliver(mdst, skb);
 		else
 			br_flood_deliver(br, skb);
-	} else if ((dst = __br_fdb_get(br, dest)) != NULL)
+	} else if ((dst = __br_fdb_get(br, dest, vid)) != NULL)
 		br_deliver(dst->dst, skb);
 	else
 		br_flood_deliver(br, skb);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index d9576e6..a244efc 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -23,6 +23,7 @@
 #include <linux/slab.h>
 #include <linux/atomic.h>
 #include <asm/unaligned.h>
+#include <linux/if_vlan.h>
 #include "br_private.h"
 
 static struct kmem_cache *br_fdb_cache __read_mostly;
@@ -67,11 +68,11 @@ static inline int has_expired(const struct net_bridge *br,
 		time_before_eq(fdb->updated + hold_time(br), jiffies);
 }
 
-static inline int br_mac_hash(const unsigned char *mac)
+static inline int br_mac_hash(const unsigned char *mac, __u16 vid)
 {
-	/* use 1 byte of OUI cnd 3 bytes of NIC */
+	/* use 1 byte of OUI and 3 bytes of NIC */
 	u32 key = get_unaligned((u32 *)(mac + 2));
-	return jhash_1word(key, fdb_salt) & (BR_HASH_SIZE - 1);
+	return jhash_2words(key, vid, fdb_salt) & (BR_HASH_SIZE - 1);
 }
 
 static void fdb_rcu_free(struct rcu_head *head)
@@ -132,7 +133,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	struct net_bridge_fdb_entry *f;
 
 	/* If old entry was unassociated with any port, then delete it. */
-	f = __br_fdb_get(br, br->dev->dev_addr);
+	f = __br_fdb_get(br, br->dev->dev_addr, 0);
 	if (f && f->is_local && !f->dst)
 		fdb_delete(br, f);
 
@@ -231,13 +232,16 @@ void br_fdb_delete_by_port(struct net_bridge *br,
 
 /* No locking or refcounting, assumes caller has rcu_read_lock */
 struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
-					  const unsigned char *addr)
+					  const unsigned char *addr,
+					  __u16 vid)
 {
 	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
 
-	hlist_for_each_entry_rcu(fdb, h, &br->hash[br_mac_hash(addr)], hlist) {
-		if (ether_addr_equal(fdb->addr.addr, addr)) {
+	hlist_for_each_entry_rcu(fdb, h,
+				&br->hash[br_mac_hash(addr, vid)], hlist) {
+		if (ether_addr_equal(fdb->addr.addr, addr) &&
+		    fdb->vlan_id == vid) {
 			if (unlikely(has_expired(br, fdb)))
 				break;
 			return fdb;
@@ -261,7 +265,7 @@ int br_fdb_test_addr(struct net_device *dev, unsigned char *addr)
 	if (!port)
 		ret = 0;
 	else {
-		fdb = __br_fdb_get(port->br, addr);
+		fdb = __br_fdb_get(port->br, addr, 0);
 		ret = fdb && fdb->dst && fdb->dst->dev != dev &&
 			fdb->dst->state == BR_STATE_FORWARDING;
 	}
@@ -313,6 +317,7 @@ int br_fdb_fillbuf(struct net_bridge *br, void *buf,
 			fe->is_local = f->is_local;
 			if (!f->is_static)
 				fe->ageing_timer_value = jiffies_delta_to_clock_t(jiffies - f->updated);
+			fe->fdb_vid = f->vlan_id;
 			++fe;
 			++num;
 		}
@@ -325,26 +330,30 @@ int br_fdb_fillbuf(struct net_bridge *br, void *buf,
 }
 
 static struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
-					     const unsigned char *addr)
+					     const unsigned char *addr,
+					     __u16 vid)
 {
 	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
 
 	hlist_for_each_entry(fdb, h, head, hlist) {
-		if (ether_addr_equal(fdb->addr.addr, addr))
+		if (ether_addr_equal(fdb->addr.addr, addr) &&
+		    fdb->vlan_id == vid)
 			return fdb;
 	}
 	return NULL;
 }
 
 static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
-						 const unsigned char *addr)
+						 const unsigned char *addr,
+						 __u16 vid)
 {
 	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
 
 	hlist_for_each_entry_rcu(fdb, h, head, hlist) {
-		if (ether_addr_equal(fdb->addr.addr, addr))
+		if (ether_addr_equal(fdb->addr.addr, addr) &&
+		    fdb->vlan_id == vid)
 			return fdb;
 	}
 	return NULL;
@@ -352,7 +361,8 @@ static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
 
 static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 					       struct net_bridge_port *source,
-					       const unsigned char *addr)
+					       const unsigned char *addr,
+					       __u16 vid)
 {
 	struct net_bridge_fdb_entry *fdb;
 
@@ -360,6 +370,7 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 	if (fdb) {
 		memcpy(fdb->addr.addr, addr, ETH_ALEN);
 		fdb->dst = source;
+		fdb->vlan_id = vid;
 		fdb->is_local = 0;
 		fdb->is_static = 0;
 		fdb->updated = fdb->used = jiffies;
@@ -371,13 +382,13 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
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
@@ -390,7 +401,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		fdb_delete(br, fdb);
 	}
 
-	fdb = fdb_create(head, source, addr);
+	fdb = fdb_create(head, source, addr, 0);
 	if (!fdb)
 		return -ENOMEM;
 
@@ -412,9 +423,9 @@ int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 }
 
 void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
-		   const unsigned char *addr)
+		   const unsigned char *addr, u16 vid)
 {
-	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
 
 	/* some users want to always flood. */
@@ -426,7 +437,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 	      source->state == BR_STATE_FORWARDING))
 		return;
 
-	fdb = fdb_find_rcu(head, addr);
+	fdb = fdb_find_rcu(head, addr, vid);
 	if (likely(fdb)) {
 		/* attempt to update an entry for a local interface */
 		if (unlikely(fdb->is_local)) {
@@ -441,8 +452,8 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		}
 	} else {
 		spin_lock(&br->hash_lock);
-		if (likely(!fdb_find(head, addr))) {
-			fdb = fdb_create(head, source, addr);
+		if (likely(!fdb_find(head, addr, vid))) {
+			fdb = fdb_create(head, source, addr, vid);
 			if (fdb)
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
 		}
@@ -571,18 +582,18 @@ out:
 
 /* Update (create or replace) forwarding database entry */
 static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
-			 __u16 state, __u16 flags)
+			 __u16 state, __u16 flags, __u16 vid)
 {
 	struct net_bridge *br = source->br;
-	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
 
-	fdb = fdb_find(head, addr);
+	fdb = fdb_find(head, addr, vid);
 	if (fdb == NULL) {
 		if (!(flags & NLM_F_CREATE))
 			return -ENOENT;
 
-		fdb = fdb_create(head, source, addr);
+		fdb = fdb_create(head, source, addr, vid);
 		if (!fdb)
 			return -ENOMEM;
 		fdb_notify(br, fdb, RTM_NEWNEIGH);
@@ -629,11 +640,12 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 
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
 
@@ -643,10 +655,10 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr)
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
index e475f49..e51eb24 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -42,10 +42,10 @@ static int br_pass_frame_up(struct sk_buff *skb)
 		       netif_receive_skb);
 }
 
-static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb)
+static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb,
+			       u16 vid)
 {
 	struct net_port_vlan *pve;
-	u16 vid;
 
 	BR_INPUT_SKB_CB(skb)->vlan = NULL;
 
@@ -55,7 +55,6 @@ static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb)
 	if (list_empty(&p->vlan_list))
 		return true;
 
-	vid = br_get_vlan(skb);
 	pve = nbp_vlan_find(p, vid);
 	if (pve) {
 		BR_INPUT_SKB_CB(skb)->vlan = pve->vlan;
@@ -74,16 +73,18 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct sk_buff *skb2;
+	u16 vid;
 
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
-	if (!br_allowed_ingress(p, skb))
+	vid = br_get_vlan(skb);
+	if (!br_allowed_ingress(p, skb, vid))
 		goto drop;
 
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
-	br_fdb_update(br, p, eth_hdr(skb)->h_source);
+	br_fdb_update(br, p, eth_hdr(skb)->h_source, vid);
 
 	if (!is_broadcast_ether_addr(dest) && is_multicast_ether_addr(dest) &&
 	    br_multicast_rcv(br, p, skb))
@@ -118,7 +119,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
 			skb2 = skb;
 
 		br->dev->stats.multicast++;
-	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
+	} else if ((dst = __br_fdb_get(br, dest, vid)) &&
+			dst->is_local) {
 		skb2 = skb;
 		/* Do not forward the packet since it's local. */
 		skb = NULL;
@@ -147,7 +149,7 @@ static int br_handle_local_finish(struct sk_buff *skb)
 {
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 
-	br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
+	br_fdb_update(p->br, p, eth_hdr(skb)->h_source, br_get_vlan(skb));
 	return 0;	 /* process further */
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6793088..7a28900 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -95,6 +95,7 @@ struct net_bridge_fdb_entry
 	mac_addr			addr;
 	unsigned char			is_local;
 	unsigned char			is_static;
+	__u16				vlan_id;
 };
 
 struct net_bridge_port_group {
@@ -392,7 +393,8 @@ extern void br_fdb_cleanup(unsigned long arg);
 extern void br_fdb_delete_by_port(struct net_bridge *br,
 				  const struct net_bridge_port *p, int do_all);
 extern struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
-						 const unsigned char *addr);
+						 const unsigned char *addr,
+						 __u16 vid);
 extern int br_fdb_test_addr(struct net_device *dev, unsigned char *addr);
 extern int br_fdb_fillbuf(struct net_bridge *br, void *buf,
 			  unsigned long count, unsigned long off);
@@ -401,7 +403,8 @@ extern int br_fdb_insert(struct net_bridge *br,
 			 const unsigned char *addr);
 extern void br_fdb_update(struct net_bridge *br,
 			  struct net_bridge_port *source,
-			  const unsigned char *addr);
+			  const unsigned char *addr,
+			  u16 vid);
 
 extern int br_fdb_delete(struct ndmsg *ndm,
 			 struct net_device *dev,
-- 
1.7.7.6
