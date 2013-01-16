From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V6 13/14] bridge: Add vlan support for local fdb entries
Date: Wed, 16 Jan 2013 13:18:08 -0500
Message-ID: <1358360289-23249-14-git-send-email-vyasevic@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	shemminger@vyatta.com, mst@redhat.com, shmulik.ladkani@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62939 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756262Ab3APSSb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 13:18:31 -0500
In-Reply-To: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When VLAN is added to the port, a local fdb entry for that port
(the entry with the mac address of the port) is added for that
VLAN.  This way we can correctly determine if the traffic
is for the bridge itself.  If the address of the port changes,
we try to change all the local fdb entries we have for that port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_fdb.c     |   62 +++++++++++++++++++++++++++++++++++-----------
 net/bridge/br_if.c      |    2 +-
 net/bridge/br_private.h |    4 ++-
 net/bridge/br_vlan.c    |   25 +++++++++++++++++-
 4 files changed, 74 insertions(+), 19 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 90d0bc9..942fe49 100644
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
+	int no_vlan = list_empty(&p->vlan_info.vlan_list);
 	int i;
 
 	spin_lock_bh(&br->hash_lock);
@@ -106,10 +107,13 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 			if (f->dst == p && f->is_local) {
 				/* maybe another port has same hw addr? */
 				struct net_bridge_port *op;
+				u16 vid = f->vlan_id;
 				list_for_each_entry(op, &br->port_list, list) {
 					if (op != p &&
 					    ether_addr_equal(op->dev->dev_addr,
-							     f->addr.addr)) {
+							     f->addr.addr) &&
+					    nbp_vlan_find(&op->vlan_info,
+							  vid)) {
 						f->dst = op;
 						goto insert;
 					}
@@ -117,27 +121,55 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 
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
@@ -380,15 +412,15 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
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
@@ -401,7 +433,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		fdb_delete(br, fdb);
 	}
 
-	fdb = fdb_create(head, source, addr, 0);
+	fdb = fdb_create(head, source, addr, vid);
 	if (!fdb)
 		return -ENOMEM;
 
@@ -412,12 +444,12 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 
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
@@ -710,8 +742,8 @@ out:
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
index 48dcd6c..45b4ee6 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -400,7 +400,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	dev_set_mtu(br->dev, br_min_mtu(br));
 
-	if (br_fdb_insert(br, p, dev->dev_addr))
+	if (br_fdb_insert(br, p, dev->dev_addr, 0))
 		netdev_err(dev, "failed insert local address bridge forwarding table\n");
 
 	kobject_uevent(&p->kobj, KOBJ_ADD);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 287374c..46f8bdc 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -420,11 +420,13 @@ extern int br_fdb_fillbuf(struct net_bridge *br, void *buf,
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
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 58cfbb4..40ef79f 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -392,6 +392,14 @@ int nbp_vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 	if (err)
 		goto del_vlan;
 
+	err = br_fdb_insert(br, p,
+			    (p ? p->dev->dev_addr : br->dev->dev_addr), vid);
+	if (err) {
+		br_err(br,
+		       "failed insert local address bridge forwarding table\n");
+		goto del_vlan;
+	}
+
 	return 0;
 
 clean_up:
@@ -409,13 +417,17 @@ int nbp_vlan_delete(struct net_port_vlans *v, u16 vid)
 	struct net_port_vlan *pve;
 	struct net_bridge_vlan *vlan;
 	struct net_bridge *br;
+	unsigned char *addr;
 
 	ASSERT_RTNL();
 
-	if (v->port_idx)
+	if (v->port_idx) {
 		br = vlans_to_port(v)->br;
-	else
+		addr = vlans_to_port(v)->dev->dev_addr;
+	} else {
 		br = vlans_to_bridge(v);
+		addr = br->dev->dev_addr;
+	}
 
 	pve = nbp_vlan_find(v, vid);
 	if (!pve)
@@ -435,6 +447,15 @@ int nbp_vlan_delete(struct net_port_vlans *v, u16 vid)
 			pr_warn("failed to kill vid %d for device %s\n",
 				vid, dev->name);
 	}
+
+	if (vid) {
+		/* If the VID !=0 remove fdb for this vid. VID 0 is special
+		 * in that it's the default and is always there in the fdb.
+		 */
+		spin_lock_bh(&br->hash_lock);
+		fdb_delete_by_addr(br, addr, vid);
+		spin_unlock_bh(&br->hash_lock);
+	}
 	pve->vid = BR_INVALID_VID;
 
 	rcu_assign_pointer(pve->vlan, NULL);
-- 
1.7.7.6
