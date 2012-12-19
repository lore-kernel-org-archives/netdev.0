From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V3 13/13] bridge: Add vlan support for local fdb entries
Date: Wed, 19 Dec 2012 12:30:48 -0500
Message-ID: <1355938248-8407-14-git-send-email-vyasevic@redhat.com>
References: <1355938248-8407-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com, erdnetdev@gmail.com,
	jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37531 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755756Ab2LSRbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 12:31:20 -0500
In-Reply-To: <1355938248-8407-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When VLAN is added to the port, a local fdb entry for that port
(the entry with the mac address of the port) is added for that
VLAN.  This way we can correctly determine if the traffic
is for the bridge itself.  If the address of the port changes,
we try to change all the local fdb entries we have for that port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_fdb.c     |   66 ++++++++++++++++++++++++++++++++++-------------
 net/bridge/br_if.c      |   28 +++++++++++++++++++-
 net/bridge/br_private.h |    4 ++-
 3 files changed, 78 insertions(+), 20 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index f1199e4..0666295 100644
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
+	int no_vlan = list_empty(&p->vlan_list);
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
+	struct net_bridge_vlan *vlan;
+	struct hlist_node *node;
+	int i;
 
 	/* If old entry was unassociated with any port, then delete it. */
 	f = __br_fdb_get(br, br->dev->dev_addr, 0);
 	if (f && f->is_local && !f->dst)
 		fdb_delete(br, f);
 
-	fdb_insert(br, NULL, newaddr);
+	fdb_insert(br, NULL, newaddr, 0);
+
+	/* Now remove and add entries for every VLAN configured on the
+	 * bridge.
+	 */
+	for (i = 0; i < BR_VID_HASH_SIZE; i++) {
+		hlist_for_each_entry_rcu(vlan, node,
+					 &br->vlan_hlist[i], hlist) {
+			if (vlan->vid == BR_INVALID_VID || vlan->vid == 0)
+				continue;
+
+			f = __br_fdb_get(br, br->dev->dev_addr, vlan->vid);
+			if (f && f->is_local && !f->dst)
+				fdb_delete(br, f);
+			fdb_insert(br, NULL, newaddr, vlan->vid);
+		}
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
@@ -710,10 +741,9 @@ out:
 	return err;
 }
 
-static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr,
-			      u16 vlan)
+int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr,
+			u16 vlan)
 {
-	struct net_bridge *br = p->br;
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan)];
 	struct net_bridge_fdb_entry *fdb;
 
@@ -721,7 +751,7 @@ static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr,
 	if (!fdb)
 		return -ENOENT;
 
-	fdb_delete(p->br, fdb);
+	fdb_delete(br, fdb);
 	return 0;
 }
 
@@ -731,7 +761,7 @@ static int __br_fdb_delete(struct net_bridge_port *p,
 	int err;
 
 	spin_lock_bh(&p->br->hash_lock);
-	err = fdb_delete_by_addr(p, addr, vid);
+	err = fdb_delete_by_addr(p->br, addr, vid);
 	spin_unlock_bh(&p->br->hash_lock);
 
 	return err;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 8f27da7..fa333fc 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -179,6 +179,11 @@ struct net_bridge_vlan *br_vlan_add(struct net_bridge *br, u16 vid,
 
 	hlist_add_head_rcu(&vlan->hlist, &br->vlan_hlist[br_vlan_hash(vid)]);
 
+	if (br_fdb_insert(br, NULL, br->dev->dev_addr, vid)) {
+		br_err(br,
+		       "failed insert local address bridge forwarding table\n");
+	}
+
 untagged:
 	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
 		br_vlan_add_untagged(br, vlan);
@@ -208,6 +213,12 @@ static void br_vlan_del(struct net_bridge *br, struct net_bridge_vlan *vlan,
 	if (!bitmap_empty(vlan->port_bitmap, PORT_BITMAP_LEN))
 		return;
 
+	if (vlan->vid) {
+		spin_lock_bh(&br->hash_lock);
+		fdb_delete_by_addr(br, br->dev->dev_addr, vlan->vid);
+		spin_unlock_bh(&br->hash_lock);
+	}
+
 	vlan->vid = BR_INVALID_VID;
 
 	/* If, for whatever reason, bridge still has a ref on this vlan
@@ -381,6 +392,12 @@ int nbp_vlan_add(struct net_bridge_port *p, u16 vid, u16 flags)
 			goto del_vlan;
 	}
 
+	if (br_fdb_insert(p->br, p, dev->dev_addr, vid)) {
+		br_err(p->br,
+		       "failed insert local address bridge forwarding table\n");
+		goto del_vlan;
+	}
+
 	return 0;
 
 clean_up:
@@ -413,6 +430,15 @@ int nbp_vlan_delete(struct net_bridge_port *p, u16 vid, u16 flags)
 		pr_warn("failed to kill vid %d for device %s\n",
 			vid, dev->name);
 
+	if (vid) {
+		/* If the VID !=0 remove fdb for this vid. VID 0 is special
+		 * in that it's the default and is always there in the fdb.
+		 */
+		spin_lock_bh(&p->br->hash_lock);
+		fdb_delete_by_addr(p->br, p->dev->dev_addr, vid);
+		spin_unlock_bh(&p->br->hash_lock);
+	}
+
 	pve->vid = BR_INVALID_VID;
 
 	vlan = pve->vlan;
@@ -758,7 +784,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	dev_set_mtu(br->dev, br_min_mtu(br));
 
-	if (br_fdb_insert(br, p, dev->dev_addr))
+	if (br_fdb_insert(br, p, dev->dev_addr, 0))
 		netdev_err(dev, "failed insert local address bridge forwarding table\n");
 
 	kobject_uevent(&p->kobj, KOBJ_ADD);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 00e07c8..495ec5a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -407,11 +407,13 @@ extern int br_fdb_fillbuf(struct net_bridge *br, void *buf,
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
-- 
1.7.7.6
