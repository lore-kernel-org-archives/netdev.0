From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v7 net-next 10/12] bridge: Add vlan support for local fdb entries
Date: Wed, 30 Jan 2013 22:12:57 -0500
Message-ID: <1359601979-14942-11-git-send-email-vyasevic@redhat.com>
References: <1359601979-14942-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49649 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756626Ab3AaDNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 22:13:16 -0500
In-Reply-To: <1359601979-14942-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When VLAN is added to the port, a local fdb entry for that port
(the entry with the mac address of the port) is added for that
VLAN.  This way we can correctly determine if the traffic
is for the bridge itself.  If the address of the port changes,
we try to change all the local fdb entries we have for that port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_fdb.c     |   61 +++++++++++++++++++++++++++++++++++-----------
 net/bridge/br_if.c      |    2 +-
 net/bridge/br_private.h |   10 +++++++-
 net/bridge/br_vlan.c    |   55 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 111 insertions(+), 17 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9553cff..574c1e0 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -28,7 +28,7 @@
 
 static struct kmem_cache *br_fdb_cache __read_mostly;
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		      const unsigned char *addr);
+		      const unsigned char *addr, u16 vid);
 static void fdb_notify(struct net_bridge *br,
 		       const struct net_bridge_fdb_entry *, int);
 
@@ -92,6 +92,7 @@ static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 {
 	struct net_bridge *br = p->br;
+	bool no_vlan = (nbp_get_vlan_info(p) == NULL) ? true : false;
 	int i;
 
 	spin_lock_bh(&br->hash_lock);
@@ -106,10 +107,12 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 			if (f->dst == p && f->is_local) {
 				/* maybe another port has same hw addr? */
 				struct net_bridge_port *op;
+				u16 vid = f->vlan_id;
 				list_for_each_entry(op, &br->port_list, list) {
 					if (op != p &&
 					    ether_addr_equal(op->dev->dev_addr,
-							     f->addr.addr)) {
+							     f->addr.addr) &&
+					    nbp_vlan_find(op, vid)) {
 						f->dst = op;
 						goto insert;
 					}
@@ -117,27 +120,55 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 
 				/* delete old one */
 				fdb_delete(br, f);
-				goto insert;
+insert:
+				/* insert new address,  may fail if invalid
+				 * address or dup.
+				 */
+				fdb_insert(br, p, newaddr, vid);
+
+				/* if this port has no vlan information
+				 * configured, we can safely be done at
+				 * this point.
+				 */
+				if (no_vlan)
+					goto done;
 			}
 		}
 	}
- insert:
-	/* insert new address,  may fail if invalid address or dup. */
-	fdb_insert(br, p, newaddr);
 
+done:
 	spin_unlock_bh(&br->hash_lock);
 }
 
 void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 {
 	struct net_bridge_fdb_entry *f;
+	struct net_port_vlans *pv;
+	u16 vid = 0;
 
 	/* If old entry was unassociated with any port, then delete it. */
 	f = __br_fdb_get(br, br->dev->dev_addr, 0);
 	if (f && f->is_local && !f->dst)
 		fdb_delete(br, f);
 
-	fdb_insert(br, NULL, newaddr);
+	fdb_insert(br, NULL, newaddr, 0);
+
+	/* Now remove and add entries for every VLAN configured on the
+	 * bridge.  This function runs under RTNL so the bitmap will not
+	 * change from under us.
+	 */
+	pv = br_get_vlan_info(br);
+	if (!pv)
+		return;
+
+	for (vid = find_next_bit(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN, vid);
+	     vid < BR_VLAN_BITMAP_LEN;
+	     vid = find_next_bit(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN, vid+1)) {
+		f = __br_fdb_get(br, br->dev->dev_addr, vid);
+		if (f && f->is_local && !f->dst)
+			fdb_delete(br, f);
+		fdb_insert(br, NULL, newaddr, vid);
+	}
 }
 
 void br_fdb_cleanup(unsigned long _data)
@@ -380,15 +411,15 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 }
 
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		  const unsigned char *addr)
+		  const unsigned char *addr, u16 vid)
 {
-	struct hlist_head *head = &br->hash[br_mac_hash(addr, 0)];
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
 
 	if (!is_valid_ether_addr(addr))
 		return -EINVAL;
 
-	fdb = fdb_find(head, addr, 0);
+	fdb = fdb_find(head, addr, vid);
 	if (fdb) {
 		/* it is okay to have multiple ports with same
 		 * address, just use the first one.
@@ -401,7 +432,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		fdb_delete(br, fdb);
 	}
 
-	fdb = fdb_create(head, source, addr, 0);
+	fdb = fdb_create(head, source, addr, vid);
 	if (!fdb)
 		return -ENOMEM;
 
@@ -412,12 +443,12 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 
 /* Add entry for local address of interface */
 int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		  const unsigned char *addr)
+		  const unsigned char *addr, u16 vid)
 {
 	int ret;
 
 	spin_lock_bh(&br->hash_lock);
-	ret = fdb_insert(br, source, addr);
+	ret = fdb_insert(br, source, addr, vid);
 	spin_unlock_bh(&br->hash_lock);
 	return ret;
 }
@@ -713,8 +744,8 @@ out:
 	return err;
 }
 
-static int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr,
-			      u16 vlan)
+int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr,
+		       u16 vlan)
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan)];
 	struct net_bridge_fdb_entry *fdb;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 335c60c..ef1b914 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -397,7 +397,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	dev_set_mtu(br->dev, br_min_mtu(br));
 
-	if (br_fdb_insert(br, p, dev->dev_addr))
+	if (br_fdb_insert(br, p, dev->dev_addr, 0))
 		netdev_err(dev, "failed insert local address bridge forwarding table\n");
 
 	kobject_uevent(&p->kobj, KOBJ_ADD);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index dcba510..57fb7e3 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -380,11 +380,13 @@ extern int br_fdb_fillbuf(struct net_bridge *br, void *buf,
 			  unsigned long count, unsigned long off);
 extern int br_fdb_insert(struct net_bridge *br,
 			 struct net_bridge_port *source,
-			 const unsigned char *addr);
+			 const unsigned char *addr,
+			 u16 vid);
 extern void br_fdb_update(struct net_bridge *br,
 			  struct net_bridge_port *source,
 			  const unsigned char *addr,
 			  u16 vid);
+extern int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr, u16 vid);
 
 extern int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 			 struct net_device *dev,
@@ -571,6 +573,7 @@ extern int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
 extern int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 extern int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 extern void nbp_vlan_flush(struct net_bridge_port *port);
+extern bool nbp_vlan_find(struct net_bridge_port *port, u16 vid);
 
 static inline struct net_port_vlans *br_get_vlan_info(
 						const struct net_bridge *br)
@@ -660,6 +663,11 @@ static inline struct net_port_vlans *nbp_get_vlan_info(
 	return NULL;
 }
 
+static inline bool nbp_vlan_find(struct net_bridge_port *port, u16 vid)
+{
+	return false;
+}
+
 static inline u16 br_vlan_get_tag(const struct sk_buff *skb, u16 *tag)
 {
 	return 0;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 16565d1..1a91fde 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -275,6 +275,15 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 	if (err)
 		goto out;
 
+	if (vid) {
+		err = br_fdb_insert(br, NULL, br->dev->dev_addr, vid);
+		if (err) {
+			br_err(br, "failed insert local address into bridge "
+			       "forwarding table\n");
+			goto out;
+		}
+	}
+
 	rcu_assign_pointer(br->vlan_info, pv);
 	return 0;
 out:
@@ -293,6 +302,15 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
 	if (!pv)
 		return -EINVAL;
 
+	if (vid) {
+		/* If the VID !=0 remove fdb for this vid. VID 0 is special
+		 * in that it's the default and is always there in the fdb.
+		 */
+		spin_lock_bh(&br->hash_lock);
+		fdb_delete_by_addr(br, br->dev->dev_addr, vid);
+		spin_unlock_bh(&br->hash_lock);
+	}
+
 	__vlan_del(pv, vid);
 	return 0;
 }
@@ -351,6 +369,15 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 	if (err)
 		goto clean_up;
 
+	if (vid) {
+		err = br_fdb_insert(port->br, port, port->dev->dev_addr, vid);
+		if (err) {
+			br_err(port->br, "failed insert local address into "
+			       "bridge forwarding table\n");
+			goto clean_up;
+		}
+	}
+
 	rcu_assign_pointer(port->vlan_info, pv);
 	return 0;
 
@@ -370,6 +397,15 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 	if (!pv)
 		return -EINVAL;
 
+	if (vid) {
+		/* If the VID !=0 remove fdb for this vid. VID 0 is special
+		 * in that it's the default and is always there in the fdb.
+		 */
+		spin_lock_bh(&port->br->hash_lock);
+		fdb_delete_by_addr(port->br, port->dev->dev_addr, vid);
+		spin_unlock_bh(&port->br->hash_lock);
+	}
+
 	return __vlan_del(pv, vid);
 }
 
@@ -385,3 +421,22 @@ void nbp_vlan_flush(struct net_bridge_port *port)
 
 	__vlan_flush(pv);
 }
+
+bool nbp_vlan_find(struct net_bridge_port *port, u16 vid)
+{
+	struct net_port_vlans *pv;
+	bool found = false;
+
+	rcu_read_lock();
+	pv = rcu_dereference(port->vlan_info);
+
+	if (!pv)
+		goto out;
+
+	if (test_bit(vid, pv->vlan_bitmap))
+		found = true;
+
+out:
+	rcu_read_unlock();
+	return found;
+}
-- 
1.7.7.6
