From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 1/7] bridge: Fix the way finding the old local fdb entry in br_fdb_changeaddr
Date: Mon,  2 Dec 2013 15:40:32 +0900
Message-ID: <1385966439-26526-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:56250 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556Ab3LBGl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 01:41:59 -0500
In-Reply-To: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_fdb_changeaddr() assumes that there is at most one local entry per port
per vlan. It used to be true, but since commit 36fd2b63e3b4 ("bridge: allow
creating/deleting fdb entries via netlink"), it has been not.
Therefore, the function might fail to search a correct previous address
to be deleted and delete an arbitrary local entry if user has added local
entries manually.

Example of problematic case:
  ip link set eth0 address ee:ff:12:34:56:78
  brctl addif br0 eth0
  bridge fdb add 12:34:56:78:90:ab dev eth0 master
  ip link set eth0 address aa:bb:cc:dd:ee:ff
Then, the address 12:34:56:78:90:ab might be deleted instead of
ee:ff:12:34:56:78, the original mac address of eth0.

To fix this, remember the mac addresses of bridge ports and use them to
find old fdb entries when changing their mac addresses.
It is no longer necessary to seek all fdb hash chains, as we can call
fdb_find() with the address to get the corresponding entry.

This approach also has secondary effects that we will come to be able to
share the code between br_fdb_changeaddr() and br_fdb_change_mac_address(),
and prevent unnecessary bridge id recalculation in br_device_event().

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c     | 89 ++++++++++++++++++++++++++++---------------------
 net/bridge/br_if.c      |  1 +
 net/bridge/br_notify.c  |  9 +++--
 net/bridge/br_private.h |  1 +
 4 files changed, 59 insertions(+), 41 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 33e8f23..d29e184 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -27,6 +27,9 @@
 #include "br_private.h"
 
 static struct kmem_cache *br_fdb_cache __read_mostly;
+static struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
+					     const unsigned char *addr,
+					     __u16 vid);
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		      const unsigned char *addr, u16 vid);
 static void fdb_notify(struct net_bridge *br,
@@ -89,54 +92,64 @@ static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 	call_rcu(&f->rcu, fdb_rcu_free);
 }
 
+/* Delete a local entry if no other port had the same address. */
+static void fdb_delete_local(struct net_bridge *br,
+			     const struct net_bridge_port *p,
+			     const unsigned char *addr, u16 vid)
+{
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
+	struct net_bridge_fdb_entry *f;
+	struct net_bridge_port *op;
+
+	f = fdb_find(head, addr, vid);
+	if (!f || !f->is_local || f->dst != p)
+		return;
+
+	/* Maybe another port has same hw addr? */
+	list_for_each_entry(op, &br->port_list, list) {
+		if (op != p && ether_addr_equal(op->dev->dev_addr, addr) &&
+		    nbp_vlan_find(op, vid)) {
+			f->dst = op;
+			return;
+		}
+	}
+
+	fdb_delete(br, f);
+}
+
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 {
 	struct net_bridge *br = p->br;
-	bool no_vlan = (nbp_get_vlan_info(p) == NULL) ? true : false;
-	int i;
+	struct net_port_vlans *pv;
+	const unsigned char *oldaddr = p->prev_addr.addr;
+	u16 vid;
+
+	ASSERT_RTNL();
 
 	spin_lock_bh(&br->hash_lock);
 
-	/* Search all chains since old address/hash is unknown */
-	for (i = 0; i < BR_HASH_SIZE; i++) {
-		struct hlist_node *h;
-		hlist_for_each(h, &br->hash[i]) {
-			struct net_bridge_fdb_entry *f;
+	/* Delete old one, may fail if corresponding entry was associated
+	 * with another port or user deleted it.
+	 */
+	fdb_delete_local(br, p, oldaddr, 0);
 
-			f = hlist_entry(h, struct net_bridge_fdb_entry, hlist);
-			if (f->dst == p && f->is_local) {
-				/* maybe another port has same hw addr? */
-				struct net_bridge_port *op;
-				u16 vid = f->vlan_id;
-				list_for_each_entry(op, &br->port_list, list) {
-					if (op != p &&
-					    ether_addr_equal(op->dev->dev_addr,
-							     f->addr.addr) &&
-					    nbp_vlan_find(op, vid)) {
-						f->dst = op;
-						goto insert;
-					}
-				}
+	/* Insert new address, may fail if invalid address or dup. */
+	fdb_insert(br, p, newaddr, 0);
 
-				/* delete old one */
-				fdb_delete(br, f);
-insert:
-				/* insert new address,  may fail if invalid
-				 * address or dup.
-				 */
-				fdb_insert(br, p, newaddr, vid);
-
-				/* if this port has no vlan information
-				 * configured, we can safely be done at
-				 * this point.
-				 */
-				if (no_vlan)
-					goto done;
-			}
-		}
+	/* Now remove and add entries for every VLAN configured on the
+	 * port.  This function runs under RTNL so the bitmap will not
+	 * change from under us.
+	 */
+	pv = nbp_get_vlan_info(p);
+	if (!pv)
+		goto out;
+
+	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
+		fdb_delete_local(br, p, oldaddr, vid);
+		fdb_insert(br, p, newaddr, vid);
 	}
 
-done:
+out:
 	spin_unlock_bh(&br->hash_lock);
 }
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 4bf02ad..346b2b2 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -406,6 +406,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	if (br_fdb_insert(br, p, dev->dev_addr, 0))
 		netdev_err(dev, "failed insert local address bridge forwarding table\n");
+	memcpy(p->prev_addr.addr, dev->dev_addr, ETH_ALEN);
 
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 2998dd1..3d3f7a1 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -34,7 +34,7 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct net_bridge_port *p;
 	struct net_bridge *br;
-	bool changed_addr;
+	bool changed_addr = false;
 	int err;
 
 	/* register of bridge completed, add sysfs entries */
@@ -57,8 +57,11 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 
 	case NETDEV_CHANGEADDR:
 		spin_lock_bh(&br->lock);
-		br_fdb_changeaddr(p, dev->dev_addr);
-		changed_addr = br_stp_recalculate_bridge_id(br);
+		if (!ether_addr_equal(dev->dev_addr, p->prev_addr.addr)) {
+			br_fdb_changeaddr(p, dev->dev_addr);
+			memcpy(p->prev_addr.addr, dev->dev_addr, ETH_ALEN);
+			changed_addr = br_stp_recalculate_bridge_id(br);
+		}
 		spin_unlock_bh(&br->lock);
 
 		if (changed_addr)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 229d820..0902658 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -195,6 +195,7 @@ struct net_bridge_port
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	struct net_port_vlans __rcu	*vlan_info;
 #endif
+	mac_addr			prev_addr;
 };
 
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
-- 
1.8.1.2
