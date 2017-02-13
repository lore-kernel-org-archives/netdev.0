From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 1/3] bridge: fdb: converge fdb searching functions into one
Date: Mon, 13 Feb 2017 14:59:09 +0100
Message-ID: <1486994351-1137-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1486994351-1137-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36305 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752822AbdBMOAP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 09:00:15 -0500
Received: by mail-wm0-f44.google.com with SMTP id c85so308677272wmi.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 06:00:09 -0800 (PST)
In-Reply-To: <1486994351-1137-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch we had 3 different fdb searching functions which was
confusing. This patch reduces all of them to one - fdb_find_rcu(), and
two flavors: br_fdb_find() which requires hash_lock and br_fdb_find_rcu
which requires RCU. This makes it clear what needs to be used, we also
remove two abusers of __br_fdb_get which called it under hash_lock and
replace them with br_fdb_find().

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_device.c  |   2 +-
 net/bridge/br_fdb.c     | 113 ++++++++++++++++++++----------------------------
 net/bridge/br_input.c   |   4 +-
 net/bridge/br_private.h |   5 ++-
 4 files changed, 54 insertions(+), 70 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index d208ee9ab60a..ea71513fca21 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -79,7 +79,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 			br_multicast_flood(mdst, skb, false, true);
 		else
 			br_flood(br, skb, BR_PKT_MULTICAST, false, true);
-	} else if ((dst = __br_fdb_get(br, dest, vid)) != NULL) {
+	} else if ((dst = br_fdb_find_rcu(br, dest, vid)) != NULL) {
 		br_forward(dst->dst, skb, false, true);
 	} else {
 		br_flood(br, skb, BR_PKT_UNICAST, false, true);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 5693168e88b6..04a53a0b733d 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -28,9 +28,6 @@
 #include "br_private.h"
 
 static struct kmem_cache *br_fdb_cache __read_mostly;
-static struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
-					     const unsigned char *addr,
-					     __u16 vid);
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		      const unsigned char *addr, u16 vid);
 static void fdb_notify(struct net_bridge *br,
@@ -86,6 +83,43 @@ static void fdb_rcu_free(struct rcu_head *head)
 	kmem_cache_free(br_fdb_cache, ent);
 }
 
+static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
+						 const unsigned char *addr,
+						 __u16 vid)
+{
+	struct net_bridge_fdb_entry *f;
+
+	hlist_for_each_entry_rcu(f, head, hlist)
+		if (ether_addr_equal(f->addr.addr, addr) && f->vlan_id == vid)
+			break;
+
+	return f;
+}
+
+/* requires bridge hash_lock */
+static struct net_bridge_fdb_entry *br_fdb_find(struct net_bridge *br,
+						const unsigned char *addr,
+						__u16 vid)
+{
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
+	struct net_bridge_fdb_entry *fdb;
+
+	rcu_read_lock();
+	fdb = fdb_find_rcu(head, addr, vid);
+	rcu_read_unlock();
+
+	return fdb;
+}
+
+struct net_bridge_fdb_entry *br_fdb_find_rcu(struct net_bridge *br,
+					     const unsigned char *addr,
+					     __u16 vid)
+{
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
+
+	return fdb_find_rcu(head, addr, vid);
+}
+
 /* When a static FDB entry is added, the mac address from the entry is
  * added to the bridge private HW address list and all required ports
  * are then updated with the new information.
@@ -198,11 +232,10 @@ void br_fdb_find_delete_local(struct net_bridge *br,
 			      const struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid)
 {
-	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *f;
 
 	spin_lock_bh(&br->hash_lock);
-	f = fdb_find(head, addr, vid);
+	f = br_fdb_find(br, addr, vid);
 	if (f && f->is_local && !f->added_by_user && f->dst == p)
 		fdb_delete_local(br, p, f);
 	spin_unlock_bh(&br->hash_lock);
@@ -266,7 +299,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	spin_lock_bh(&br->hash_lock);
 
 	/* If old entry was unassociated with any port, then delete it. */
-	f = __br_fdb_get(br, br->dev->dev_addr, 0);
+	f = br_fdb_find(br, br->dev->dev_addr, 0);
 	if (f && f->is_local && !f->dst && !f->added_by_user)
 		fdb_delete_local(br, NULL, f);
 
@@ -281,7 +314,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	list_for_each_entry(v, &vg->vlan_list, vlist) {
 		if (!br_vlan_should_use(v))
 			continue;
-		f = __br_fdb_get(br, br->dev->dev_addr, v->vid);
+		f = br_fdb_find(br, br->dev->dev_addr, v->vid);
 		if (f && f->is_local && !f->dst && !f->added_by_user)
 			fdb_delete_local(br, NULL, f);
 		fdb_insert(br, NULL, newaddr, v->vid);
@@ -380,24 +413,6 @@ void br_fdb_delete_by_port(struct net_bridge *br,
 	spin_unlock_bh(&br->hash_lock);
 }
 
-/* No locking or refcounting, assumes caller has rcu_read_lock */
-struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
-					  const unsigned char *addr,
-					  __u16 vid)
-{
-	struct net_bridge_fdb_entry *fdb;
-
-	hlist_for_each_entry_rcu(fdb,
-				&br->hash[br_mac_hash(addr, vid)], hlist) {
-		if (ether_addr_equal(fdb->addr.addr, addr) &&
-		    fdb->vlan_id == vid) {
-			return fdb;
-		}
-	}
-
-	return NULL;
-}
-
 #if IS_ENABLED(CONFIG_ATM_LANE)
 /* Interface used by ATM LANE hook to test
  * if an addr is on some other bridge port */
@@ -412,7 +427,7 @@ int br_fdb_test_addr(struct net_device *dev, unsigned char *addr)
 	if (!port)
 		ret = 0;
 	else {
-		fdb = __br_fdb_get(port->br, addr, 0);
+		fdb = br_fdb_find_rcu(port->br, addr, 0);
 		ret = fdb && fdb->dst && fdb->dst->dev != dev &&
 			fdb->dst->state == BR_STATE_FORWARDING;
 	}
@@ -474,34 +489,6 @@ int br_fdb_fillbuf(struct net_bridge *br, void *buf,
 	return num;
 }
 
-static struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
-					     const unsigned char *addr,
-					     __u16 vid)
-{
-	struct net_bridge_fdb_entry *fdb;
-
-	hlist_for_each_entry(fdb, head, hlist) {
-		if (ether_addr_equal(fdb->addr.addr, addr) &&
-		    fdb->vlan_id == vid)
-			return fdb;
-	}
-	return NULL;
-}
-
-static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
-						 const unsigned char *addr,
-						 __u16 vid)
-{
-	struct net_bridge_fdb_entry *fdb;
-
-	hlist_for_each_entry_rcu(fdb, head, hlist) {
-		if (ether_addr_equal(fdb->addr.addr, addr) &&
-		    fdb->vlan_id == vid)
-			return fdb;
-	}
-	return NULL;
-}
-
 static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 					       struct net_bridge_port *source,
 					       const unsigned char *addr,
@@ -535,7 +522,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 	if (!is_valid_ether_addr(addr))
 		return -EINVAL;
 
-	fdb = fdb_find(head, addr, vid);
+	fdb = br_fdb_find(br, addr, vid);
 	if (fdb) {
 		/* it is okay to have multiple ports with same
 		 * address, just use the first one.
@@ -608,7 +595,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		}
 	} else {
 		spin_lock(&br->hash_lock);
-		if (likely(!fdb_find(head, addr, vid))) {
+		if (likely(!fdb_find_rcu(head, addr, vid))) {
 			fdb = fdb_create(head, source, addr, vid, 0, 0);
 			if (fdb) {
 				if (unlikely(added_by_user))
@@ -792,7 +779,7 @@ static int fdb_add_entry(struct net_bridge *br, struct net_bridge_port *source,
 		return -EINVAL;
 	}
 
-	fdb = fdb_find(head, addr, vid);
+	fdb = br_fdb_find(br, addr, vid);
 	if (fdb == NULL) {
 		if (!(flags & NLM_F_CREATE))
 			return -ENOENT;
@@ -942,10 +929,9 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 static int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr,
 			      u16 vid)
 {
-	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
 
-	fdb = fdb_find(head, addr, vid);
+	fdb = br_fdb_find(br, addr, vid);
 	if (!fdb)
 		return -ENOENT;
 
@@ -969,10 +955,9 @@ static int fdb_delete_by_addr_and_port(struct net_bridge_port *p,
 				       const u8 *addr, u16 vlan)
 {
 	struct net_bridge *br = p->br;
-	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan)];
 	struct net_bridge_fdb_entry *fdb;
 
-	fdb = fdb_find(head, addr, vlan);
+	fdb = br_fdb_find(br, addr, vlan);
 	if (!fdb || fdb->dst != p)
 		return -ENOENT;
 
@@ -1117,7 +1102,7 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 	spin_lock_bh(&br->hash_lock);
 
 	head = &br->hash[br_mac_hash(addr, vid)];
-	fdb = fdb_find(head, addr, vid);
+	fdb = br_fdb_find(br, addr, vid);
 	if (!fdb) {
 		fdb = fdb_create(head, p, addr, vid, 0, 0);
 		if (!fdb) {
@@ -1145,15 +1130,13 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid)
 {
-	struct hlist_head *head;
 	struct net_bridge_fdb_entry *fdb;
 	int err = 0;
 
 	ASSERT_RTNL();
 	spin_lock_bh(&br->hash_lock);
 
-	head = &br->hash[br_mac_hash(addr, vid)];
-	fdb = fdb_find(head, addr, vid);
+	fdb = br_fdb_find(br, addr, vid);
 	if (fdb && fdb->added_by_external_learn)
 		fdb_delete(br, fdb);
 	else
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 4615a9b3e26c..236f34244dbe 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -114,7 +114,7 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 			return;
 		}
 
-		f = __br_fdb_get(br, n->ha, vid);
+		f = br_fdb_find_rcu(br, n->ha, vid);
 		if (f && ((p->flags & BR_PROXYARP) ||
 			  (f->dst && (f->dst->flags & BR_PROXYARP_WIFI)))) {
 			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, skb->dev, tip,
@@ -189,7 +189,7 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 		}
 		break;
 	case BR_PKT_UNICAST:
-		dst = __br_fdb_get(br, dest, vid);
+		dst = br_fdb_find_rcu(br, dest, vid);
 	default:
 		break;
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1cbbf63a5ef7..61368186edea 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -507,8 +507,9 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr);
 void br_fdb_cleanup(struct work_struct *work);
 void br_fdb_delete_by_port(struct net_bridge *br,
 			   const struct net_bridge_port *p, u16 vid, int do_all);
-struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
-					  const unsigned char *addr, __u16 vid);
+struct net_bridge_fdb_entry *br_fdb_find_rcu(struct net_bridge *br,
+					     const unsigned char *addr,
+					     __u16 vid);
 int br_fdb_test_addr(struct net_device *dev, unsigned char *addr);
 int br_fdb_fillbuf(struct net_bridge *br, void *buf, unsigned long count,
 		   unsigned long off);
-- 
2.1.4
