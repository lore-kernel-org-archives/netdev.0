From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next] bridge: Synchronize unicast filtering
	with FDB
Date: Fri,  3 Jun 2016 17:33:28 +0900
Message-ID: <1464942808-3945-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Patrick Schaaf <netdev@bof.de>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Patrick Schaaf reported that flooding due to a missing fdb entry of
the address of macvlan on the bridge device caused high CPU
consumption of an openvpn process behind a tap bridge port.
Adding an fdb entry of the macvlan address can suppress flooding
and avoid this problem.

This change makes bridge able to synchronize unicast filtering with
fdb automatically so admin do not need to manually add an fdb entry.
This effectively supports IFF_UNICAST_FLT in bridge, thus adding an
macvlan device would not place bridge into promiscuous mode as well.

Reported-by: Patrick Schaaf <netdev@bof.de>
Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_device.c  |   7 +--
 net/bridge/br_fdb.c     | 117 +++++++++++++++++++++++++++++++++++++++++++-----
 net/bridge/br_private.h |   7 +--
 net/bridge/br_vlan.c    |  11 +++--
 4 files changed, 120 insertions(+), 22 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 2c8095a..9b56802 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -123,8 +123,9 @@ static int br_dev_open(struct net_device *dev)
 	return 0;
 }
 
-static void br_dev_set_multicast_list(struct net_device *dev)
+static void br_dev_set_rx_mode(struct net_device *dev)
 {
+	br_fdb_sync_uc(netdev_priv(dev));
 }
 
 static void br_dev_change_rx_flags(struct net_device *dev, int change)
@@ -329,7 +330,7 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_start_xmit		 = br_dev_xmit,
 	.ndo_get_stats64	 = br_get_stats64,
 	.ndo_set_mac_address	 = br_set_mac_address,
-	.ndo_set_rx_mode	 = br_dev_set_multicast_list,
+	.ndo_set_rx_mode	 = br_dev_set_rx_mode,
 	.ndo_change_rx_flags	 = br_dev_change_rx_flags,
 	.ndo_change_mtu		 = br_change_mtu,
 	.ndo_do_ioctl		 = br_dev_ioctl,
@@ -373,7 +374,7 @@ void br_dev_setup(struct net_device *dev)
 	dev->destructor = br_dev_free;
 	dev->ethtool_ops = &br_ethtool_ops;
 	SET_NETDEV_DEVTYPE(dev, &br_type);
-	dev->priv_flags = IFF_EBRIDGE | IFF_NO_QUEUE;
+	dev->priv_flags = IFF_EBRIDGE | IFF_NO_QUEUE | IFF_UNICAST_FLT;
 
 	dev->features = COMMON_FEATURES | NETIF_F_LLTX | NETIF_F_NETNS_LOCAL |
 			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index dcea4f4..bc082e6 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -184,28 +184,36 @@ static void fdb_delete_local(struct net_bridge *br,
 	vg = br_vlan_group(br);
 	v = br_vlan_find(vg, vid);
 	/* Maybe bridge device has same hw addr? */
-	if (p && ether_addr_equal(br->dev->dev_addr, addr) &&
-	    (!vid || (v && br_vlan_should_use(v)))) {
-		f->dst = NULL;
-		f->added_by_user = 0;
-		return;
+	if (p && (!vid || (v && br_vlan_should_use(v)))) {
+		struct netdev_hw_addr *ha;
+
+		if (ether_addr_equal(br->dev->dev_addr, addr)) {
+			f->dst = NULL;
+			f->added_by_user = 0;
+			return;
+		}
+		netdev_for_each_uc_addr(ha, br->dev) {
+			if (ether_addr_equal(ha->addr, addr)) {
+				f->dst = NULL;
+				f->added_by_user = 0;
+				return;
+			}
+		}
 	}
 
 	fdb_delete(br, f);
 }
 
-void br_fdb_find_delete_local(struct net_bridge *br,
-			      const struct net_bridge_port *p,
-			      const unsigned char *addr, u16 vid)
+static void fdb_find_delete_local(struct net_bridge *br,
+				  const struct net_bridge_port *p,
+				  const unsigned char *addr, u16 vid)
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *f;
 
-	spin_lock_bh(&br->hash_lock);
 	f = fdb_find(head, addr, vid);
 	if (f && f->is_local && !f->added_by_user && f->dst == p)
 		fdb_delete_local(br, p, f);
-	spin_unlock_bh(&br->hash_lock);
 }
 
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
@@ -288,6 +296,95 @@ out:
 	spin_unlock_bh(&br->hash_lock);
 }
 
+void br_fdb_sync_uc(struct net_bridge *br)
+{
+	struct net_bridge_vlan_group *vg;
+	struct netdev_hw_addr *ha;
+	int i;
+
+	spin_lock_bh(&br->hash_lock);
+
+	for (i = 0; i < BR_HASH_SIZE; i++) {
+		struct hlist_node *h;
+
+		hlist_for_each(h, &br->hash[i]) {
+			struct net_bridge_fdb_entry *f;
+
+			f = hlist_entry(h, struct net_bridge_fdb_entry, hlist);
+			if (!f->dst && f->is_local && !f->added_by_user &&
+			    !ether_addr_equal(f->addr.addr, br->dev->dev_addr)) {
+				/* delete old one */
+				fdb_delete_local(br, NULL, f);
+			}
+		}
+	}
+
+	vg = br_vlan_group(br);
+
+	/* insert new address,  may fail if invalid address or dup. */
+	netdev_for_each_uc_addr(ha, br->dev) {
+		struct net_bridge_vlan *v;
+
+		fdb_insert(br, NULL, ha->addr, 0);
+
+		if (!vg || !vg->num_vlans)
+			continue;
+
+		list_for_each_entry(v, &vg->vlan_list, vlist)
+			fdb_insert(br, NULL, ha->addr, v->vid);
+	}
+
+	spin_unlock_bh(&br->hash_lock);
+}
+
+int br_fdb_add_vlan(struct net_bridge *br, struct net_bridge_port *p, u16 vid)
+{
+	struct netdev_hw_addr *ha, *ha2;
+	int err = 0;
+
+	spin_lock_bh(&br->hash_lock);
+	if (p) {
+		err = fdb_insert(br, p, p->dev->dev_addr, vid);
+	} else {
+		netdev_for_each_uc_addr(ha, br->dev) {
+			err = fdb_insert(br, NULL, ha->addr, vid);
+			if (err)
+				goto undo;
+		}
+		err = fdb_insert(br, NULL, br->dev->dev_addr, vid);
+		if (err)
+			goto undo;
+	}
+out:
+	spin_unlock_bh(&br->hash_lock);
+
+	return err;
+
+undo:
+	netdev_for_each_uc_addr(ha2, br->dev) {
+		if (ha2 == ha)
+			break;
+		fdb_find_delete_local(br, NULL, ha2->addr, vid);
+	}
+	goto out;
+}
+
+void br_fdb_delete_vlan(struct net_bridge *br, struct net_bridge_port *p,
+			u16 vid)
+{
+	struct netdev_hw_addr *ha;
+
+	spin_lock_bh(&br->hash_lock);
+	if (p) {
+		fdb_find_delete_local(br, p, p->dev->dev_addr, vid);
+	} else {
+		netdev_for_each_uc_addr(ha, br->dev)
+			fdb_find_delete_local(br, NULL, ha->addr, vid);
+		fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
+	}
+	spin_unlock_bh(&br->hash_lock);
+}
+
 void br_fdb_cleanup(unsigned long _data)
 {
 	struct net_bridge *br = (struct net_bridge *)_data;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c7fb5d7..d07d24c 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -463,11 +463,12 @@ static inline void br_netpoll_disable(struct net_bridge_port *p)
 int br_fdb_init(void);
 void br_fdb_fini(void);
 void br_fdb_flush(struct net_bridge *br);
-void br_fdb_find_delete_local(struct net_bridge *br,
-			      const struct net_bridge_port *p,
-			      const unsigned char *addr, u16 vid);
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr);
 void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr);
+void br_fdb_sync_uc(struct net_bridge *br);
+int br_fdb_add_vlan(struct net_bridge *br, struct net_bridge_port *p, u16 vid);
+void br_fdb_delete_vlan(struct net_bridge *br, struct net_bridge_port *p,
+			u16 vid);
 void br_fdb_cleanup(unsigned long arg);
 void br_fdb_delete_by_port(struct net_bridge *br,
 			   const struct net_bridge_port *p, u16 vid, int do_all);
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index b6de4f4..86ac873 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -246,7 +246,7 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 
 	/* Add the dev mac and count the vlan only if it's usable */
 	if (br_vlan_should_use(v)) {
-		err = br_fdb_insert(br, p, dev->dev_addr, v->vid);
+		err = br_fdb_add_vlan(br, p, v->vid);
 		if (err) {
 			br_err(br, "failed insert local address into bridge forwarding table\n");
 			goto out_filt;
@@ -266,7 +266,7 @@ out:
 
 out_fdb_insert:
 	if (br_vlan_should_use(v)) {
-		br_fdb_find_delete_local(br, p, dev->dev_addr, v->vid);
+		br_fdb_delete_vlan(br, p, v->vid);
 		vg->num_vlans--;
 	}
 
@@ -557,8 +557,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 			if (!(flags & BRIDGE_VLAN_INFO_BRENTRY))
 				return -EINVAL;
 			/* It was only kept for port vlans, now make it real */
-			ret = br_fdb_insert(br, NULL, br->dev->dev_addr,
-					    vlan->vid);
+			ret = br_fdb_add_vlan(br, NULL, vlan->vid);
 			if (ret) {
 				br_err(br, "failed insert local address into bridge forwarding table\n");
 				return ret;
@@ -610,7 +609,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
 	if (!v || !br_vlan_is_brentry(v))
 		return -ENOENT;
 
-	br_fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
+	br_fdb_delete_vlan(br, NULL, vid);
 	br_fdb_delete_by_port(br, NULL, vid, 0);
 
 	return __vlan_del(v);
@@ -1036,7 +1035,7 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 	v = br_vlan_find(nbp_vlan_group(port), vid);
 	if (!v)
 		return -ENOENT;
-	br_fdb_find_delete_local(port->br, port, port->dev->dev_addr, vid);
+	br_fdb_delete_vlan(port->br, port, vid);
 	br_fdb_delete_by_port(port->br, port, vid, 0);
 
 	return __vlan_del(v);
-- 
1.8.3.1
