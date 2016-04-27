From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 01/20] net: dsa: introduce a dsa_port structure
Date: Wed, 27 Apr 2016 18:29:58 -0400
Message-ID: <1461796217-18893-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce a new dsa_port structure, used to store port-centric
information, such as a pointer to its DSA switch and its port number.
It will later contains further data, such as its bridge device.

This is a first step towards implementing cross-chip port operations.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h     |   5 ++
 net/dsa/dsa.c         |  10 +++-
 net/dsa/dsa_priv.h    |  13 ++---
 net/dsa/slave.c       | 147 +++++++++++++++++++++++++-------------------------
 net/dsa/tag_brcm.c    |   4 +-
 net/dsa/tag_dsa.c     |   8 +--
 net/dsa/tag_edsa.c    |   8 +--
 net/dsa/tag_trailer.c |   2 +-
 8 files changed, 104 insertions(+), 93 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 2d280ab..255c108 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -122,6 +122,11 @@ struct dsa_switch_tree {
 	struct dsa_switch	*ds[DSA_MAX_SWITCHES];
 };
 
+struct dsa_port {
+	struct dsa_switch	*ds;
+	int			port;
+};
+
 struct dsa_switch {
 	/*
 	 * Parent switch tree, and switch index.
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index d61ceed..222494c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -219,6 +219,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 {
 	struct dsa_switch_driver *drv = ds->drv;
 	struct dsa_switch_tree *dst = ds->dst;
+	struct dsa_port *dp[DSA_MAX_PORTS];
 	struct dsa_chip_data *pd = ds->pd;
 	bool valid_name_found = false;
 	int index = ds->index;
@@ -230,6 +231,13 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
 		char *name;
 
+		dp[i] = devm_kzalloc(parent, sizeof(*dp), GFP_KERNEL);
+		if (dp[i] == NULL)
+			return -ENOMEM;
+
+		dp[i]->ds = ds;
+		dp[i]->port = i;
+
 		name = pd->port_names[i];
 		if (name == NULL)
 			continue;
@@ -328,7 +336,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		if (!(ds->enabled_port_mask & (1 << i)))
 			continue;
 
-		ret = dsa_slave_create(ds, parent, i, pd->port_names[i]);
+		ret = dsa_slave_create(dp[i], parent, pd->port_names[i]);
 		if (ret < 0) {
 			netdev_err(dst->master_netdev, "[%d]: can't create dsa slave device for port %d(%s): %d\n",
 				   index, i, pd->port_names[i], ret);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index dfa3377..c7d5df0 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -26,13 +26,6 @@ struct dsa_slave_priv {
 					struct net_device *dev);
 
 	/*
-	 * Which switch this port is a part of, and the port index
-	 * for this port.
-	 */
-	struct dsa_switch	*parent;
-	u8			port;
-
-	/*
 	 * The phylib phy_device pointer for the PHY connected
 	 * to this port.
 	 */
@@ -46,6 +39,9 @@ struct dsa_slave_priv {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll		*netpoll;
 #endif
+
+	/* DSA specific data */
+	struct dsa_port		*dp;
 };
 
 /* dsa.c */
@@ -54,8 +50,7 @@ extern char dsa_driver_version[];
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
-int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
-		     int port, char *name);
+int dsa_slave_create(struct dsa_port *dp, struct device *parent, char *name);
 void dsa_slave_destroy(struct net_device *slave_dev);
 int dsa_slave_suspend(struct net_device *slave_dev);
 int dsa_slave_resume(struct net_device *slave_dev);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 3b6750f..6115444 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -61,7 +61,7 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	return p->parent->dst->master_netdev->ifindex;
+	return p->dp->ds->dst->master_netdev->ifindex;
 }
 
 static inline bool dsa_port_is_bridged(struct dsa_slave_priv *p)
@@ -72,8 +72,8 @@ static inline bool dsa_port_is_bridged(struct dsa_slave_priv *p)
 static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
+	struct net_device *master = ds->dst->master_netdev;
 	u8 stp_state = dsa_port_is_bridged(p) ?
 			BR_STATE_BLOCKING : BR_STATE_FORWARDING;
 	int err;
@@ -99,13 +99,13 @@ static int dsa_slave_open(struct net_device *dev)
 	}
 
 	if (ds->drv->port_enable) {
-		err = ds->drv->port_enable(ds, p->port, p->phy);
+		err = ds->drv->port_enable(ds, p->dp->port, p->phy);
 		if (err)
 			goto clear_promisc;
 	}
 
 	if (ds->drv->port_stp_state_set)
-		ds->drv->port_stp_state_set(ds, p->port, stp_state);
+		ds->drv->port_stp_state_set(ds, p->dp->port, stp_state);
 
 	if (p->phy)
 		phy_start(p->phy);
@@ -128,8 +128,8 @@ out:
 static int dsa_slave_close(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
+	struct net_device *master = ds->dst->master_netdev;
 
 	if (p->phy)
 		phy_stop(p->phy);
@@ -145,10 +145,10 @@ static int dsa_slave_close(struct net_device *dev)
 		dev_uc_del(master, dev->dev_addr);
 
 	if (ds->drv->port_disable)
-		ds->drv->port_disable(ds, p->port, p->phy);
+		ds->drv->port_disable(ds, p->dp->port, p->phy);
 
 	if (ds->drv->port_stp_state_set)
-		ds->drv->port_stp_state_set(ds, p->port, BR_STATE_DISABLED);
+		ds->drv->port_stp_state_set(ds, p->dp->port, BR_STATE_DISABLED);
 
 	return 0;
 }
@@ -156,7 +156,7 @@ static int dsa_slave_close(struct net_device *dev)
 static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
+	struct net_device *master = p->dp->ds->dst->master_netdev;
 
 	if (change & IFF_ALLMULTI)
 		dev_set_allmulti(master, dev->flags & IFF_ALLMULTI ? 1 : -1);
@@ -167,7 +167,7 @@ static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 static void dsa_slave_set_rx_mode(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
+	struct net_device *master = p->dp->ds->dst->master_netdev;
 
 	dev_mc_sync(master, dev);
 	dev_uc_sync(master, dev);
@@ -176,7 +176,7 @@ static void dsa_slave_set_rx_mode(struct net_device *dev)
 static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
+	struct net_device *master = p->dp->ds->dst->master_netdev;
 	struct sockaddr *addr = a;
 	int err;
 
@@ -206,16 +206,16 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 				   struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->drv->port_vlan_prepare || !ds->drv->port_vlan_add)
 			return -EOPNOTSUPP;
 
-		return ds->drv->port_vlan_prepare(ds, p->port, vlan, trans);
+		return ds->drv->port_vlan_prepare(ds, p->dp->port, vlan, trans);
 	}
 
-	ds->drv->port_vlan_add(ds, p->port, vlan, trans);
+	ds->drv->port_vlan_add(ds, p->dp->port, vlan, trans);
 
 	return 0;
 }
@@ -224,12 +224,12 @@ static int dsa_slave_port_vlan_del(struct net_device *dev,
 				   const struct switchdev_obj_port_vlan *vlan)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (!ds->drv->port_vlan_del)
 		return -EOPNOTSUPP;
 
-	return ds->drv->port_vlan_del(ds, p->port, vlan);
+	return ds->drv->port_vlan_del(ds, p->dp->port, vlan);
 }
 
 static int dsa_slave_port_vlan_dump(struct net_device *dev,
@@ -237,10 +237,10 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 				    switchdev_obj_dump_cb_t *cb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->drv->port_vlan_dump)
-		return ds->drv->port_vlan_dump(ds, p->port, vlan, cb);
+		return ds->drv->port_vlan_dump(ds, p->dp->port, vlan, cb);
 
 	return -EOPNOTSUPP;
 }
@@ -250,16 +250,16 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 				  struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->drv->port_fdb_prepare || !ds->drv->port_fdb_add)
 			return -EOPNOTSUPP;
 
-		return ds->drv->port_fdb_prepare(ds, p->port, fdb, trans);
+		return ds->drv->port_fdb_prepare(ds, p->dp->port, fdb, trans);
 	}
 
-	ds->drv->port_fdb_add(ds, p->port, fdb, trans);
+	ds->drv->port_fdb_add(ds, p->dp->port, fdb, trans);
 
 	return 0;
 }
@@ -268,11 +268,11 @@ static int dsa_slave_port_fdb_del(struct net_device *dev,
 				  const struct switchdev_obj_port_fdb *fdb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	int ret = -EOPNOTSUPP;
 
 	if (ds->drv->port_fdb_del)
-		ret = ds->drv->port_fdb_del(ds, p->port, fdb);
+		ret = ds->drv->port_fdb_del(ds, p->dp->port, fdb);
 
 	return ret;
 }
@@ -282,10 +282,10 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 				   switchdev_obj_dump_cb_t *cb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->drv->port_fdb_dump)
-		return ds->drv->port_fdb_dump(ds, p->port, fdb, cb);
+		return ds->drv->port_fdb_dump(ds, p->dp->port, fdb, cb);
 
 	return -EOPNOTSUPP;
 }
@@ -305,12 +305,12 @@ static int dsa_slave_stp_state_set(struct net_device *dev,
 				   struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (switchdev_trans_ph_prepare(trans))
 		return ds->drv->port_stp_state_set ? 0 : -EOPNOTSUPP;
 
-	ds->drv->port_stp_state_set(ds, p->port, attr->u.stp_state);
+	ds->drv->port_stp_state_set(ds, p->dp->port, attr->u.stp_state);
 
 	return 0;
 }
@@ -320,14 +320,14 @@ static int dsa_slave_vlan_filtering(struct net_device *dev,
 				    struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	/* bridge skips -EOPNOTSUPP, so skip the prepare phase */
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
 	if (ds->drv->port_vlan_filtering)
-		return ds->drv->port_vlan_filtering(ds, p->port,
+		return ds->drv->port_vlan_filtering(ds, p->dp->port,
 						    attr->u.vlan_filtering);
 
 	return 0;
@@ -435,13 +435,13 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 				      struct net_device *br)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	int ret = -EOPNOTSUPP;
 
 	p->bridge_dev = br;
 
 	if (ds->drv->port_bridge_join)
-		ret = ds->drv->port_bridge_join(ds, p->port, br);
+		ret = ds->drv->port_bridge_join(ds, p->dp->port, br);
 
 	return ret == -EOPNOTSUPP ? 0 : ret;
 }
@@ -449,11 +449,11 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 static void dsa_slave_bridge_port_leave(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 
 	if (ds->drv->port_bridge_leave)
-		ds->drv->port_bridge_leave(ds, p->port);
+		ds->drv->port_bridge_leave(ds, p->dp->port);
 
 	p->bridge_dev = NULL;
 
@@ -461,14 +461,15 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev)
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
 	 */
 	if (ds->drv->port_stp_state_set)
-		ds->drv->port_stp_state_set(ds, p->port, BR_STATE_FORWARDING);
+		ds->drv->port_stp_state_set(ds, p->dp->port,
+					    BR_STATE_FORWARDING);
 }
 
 static int dsa_slave_port_attr_get(struct net_device *dev,
 				   struct switchdev_attr *attr)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
@@ -516,7 +517,7 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Queue the SKB for transmission on the parent interface, but
 	 * do not modify its EtherType
 	 */
-	nskb->dev = p->parent->dst->master_netdev;
+	nskb->dev = p->dp->ds->dst->master_netdev;
 	dev_queue_xmit(nskb);
 
 	return NETDEV_TX_OK;
@@ -570,10 +571,10 @@ static void dsa_slave_get_drvinfo(struct net_device *dev,
 static int dsa_slave_get_regs_len(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->drv->get_regs_len)
-		return ds->drv->get_regs_len(ds, p->port);
+		return ds->drv->get_regs_len(ds, p->dp->port);
 
 	return -EOPNOTSUPP;
 }
@@ -582,10 +583,10 @@ static void
 dsa_slave_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *_p)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->drv->get_regs)
-		ds->drv->get_regs(ds, p->port, regs, _p);
+		ds->drv->get_regs(ds, p->dp->port, regs, _p);
 }
 
 static int dsa_slave_nway_reset(struct net_device *dev)
@@ -613,7 +614,7 @@ static u32 dsa_slave_get_link(struct net_device *dev)
 static int dsa_slave_get_eeprom_len(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->pd->eeprom_len)
 		return ds->pd->eeprom_len;
@@ -628,7 +629,7 @@ static int dsa_slave_get_eeprom(struct net_device *dev,
 				struct ethtool_eeprom *eeprom, u8 *data)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->drv->get_eeprom)
 		return ds->drv->get_eeprom(ds, eeprom, data);
@@ -640,7 +641,7 @@ static int dsa_slave_set_eeprom(struct net_device *dev,
 				struct ethtool_eeprom *eeprom, u8 *data)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->drv->set_eeprom)
 		return ds->drv->set_eeprom(ds, eeprom, data);
@@ -652,7 +653,7 @@ static void dsa_slave_get_strings(struct net_device *dev,
 				  uint32_t stringset, uint8_t *data)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (stringset == ETH_SS_STATS) {
 		int len = ETH_GSTRING_LEN;
@@ -662,7 +663,7 @@ static void dsa_slave_get_strings(struct net_device *dev,
 		strncpy(data + 2 * len, "rx_packets", len);
 		strncpy(data + 3 * len, "rx_bytes", len);
 		if (ds->drv->get_strings != NULL)
-			ds->drv->get_strings(ds, p->port, data + 4 * len);
+			ds->drv->get_strings(ds, p->dp->port, data + 4 * len);
 	}
 }
 
@@ -671,20 +672,20 @@ static void dsa_slave_get_ethtool_stats(struct net_device *dev,
 					uint64_t *data)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	data[0] = dev->stats.tx_packets;
 	data[1] = dev->stats.tx_bytes;
 	data[2] = dev->stats.rx_packets;
 	data[3] = dev->stats.rx_bytes;
 	if (ds->drv->get_ethtool_stats != NULL)
-		ds->drv->get_ethtool_stats(ds, p->port, data + 4);
+		ds->drv->get_ethtool_stats(ds, p->dp->port, data + 4);
 }
 
 static int dsa_slave_get_sset_count(struct net_device *dev, int sset)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (sset == ETH_SS_STATS) {
 		int count;
@@ -702,20 +703,20 @@ static int dsa_slave_get_sset_count(struct net_device *dev, int sset)
 static void dsa_slave_get_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->drv->get_wol)
-		ds->drv->get_wol(ds, p->port, w);
+		ds->drv->get_wol(ds, p->dp->port, w);
 }
 
 static int dsa_slave_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	int ret = -EOPNOTSUPP;
 
 	if (ds->drv->set_wol)
-		ret = ds->drv->set_wol(ds, p->port, w);
+		ret = ds->drv->set_wol(ds, p->dp->port, w);
 
 	return ret;
 }
@@ -723,13 +724,13 @@ static int dsa_slave_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	int ret;
 
 	if (!ds->drv->set_eee)
 		return -EOPNOTSUPP;
 
-	ret = ds->drv->set_eee(ds, p->port, p->phy, e);
+	ret = ds->drv->set_eee(ds, p->dp->port, p->phy, e);
 	if (ret)
 		return ret;
 
@@ -742,13 +743,13 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	int ret;
 
 	if (!ds->drv->get_eee)
 		return -EOPNOTSUPP;
 
-	ret = ds->drv->get_eee(ds, p->port, e);
+	ret = ds->drv->get_eee(ds, p->dp->port, e);
 	if (ret)
 		return ret;
 
@@ -763,7 +764,7 @@ static int dsa_slave_netpoll_setup(struct net_device *dev,
 				   struct netpoll_info *ni)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	struct net_device *master = ds->dst->master_netdev;
 	struct netpoll *netpoll;
 	int err = 0;
@@ -858,7 +859,7 @@ static struct device_type dsa_type = {
 static void dsa_slave_adjust_link(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	unsigned int status_changed = 0;
 
 	if (p->old_link != p->phy->link) {
@@ -877,7 +878,7 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 	}
 
 	if (ds->drv->adjust_link && status_changed)
-		ds->drv->adjust_link(ds, p->port, p->phy);
+		ds->drv->adjust_link(ds, p->dp->port, p->phy);
 
 	if (status_changed)
 		phy_print_status(p->phy);
@@ -891,9 +892,9 @@ static int dsa_slave_fixed_link_update(struct net_device *dev,
 
 	if (dev) {
 		p = netdev_priv(dev);
-		ds = p->parent;
+		ds = p->dp->ds;
 		if (ds->drv->fixed_link_update)
-			ds->drv->fixed_link_update(ds, p->port, status);
+			ds->drv->fixed_link_update(ds, p->dp->port, status);
 	}
 
 	return 0;
@@ -904,7 +905,7 @@ static int dsa_slave_phy_connect(struct dsa_slave_priv *p,
 				 struct net_device *slave_dev,
 				 int addr)
 {
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	p->phy = mdiobus_get_phy(ds->slave_mii_bus, addr);
 	if (!p->phy) {
@@ -924,14 +925,14 @@ static int dsa_slave_phy_connect(struct dsa_slave_priv *p,
 static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 				struct net_device *slave_dev)
 {
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	struct dsa_chip_data *cd = ds->pd;
 	struct device_node *phy_dn, *port_dn;
 	bool phy_is_fixed = false;
 	u32 phy_flags = 0;
 	int mode, ret;
 
-	port_dn = cd->port_dn[p->port];
+	port_dn = cd->port_dn[p->dp->port];
 	mode = of_get_phy_mode(port_dn);
 	if (mode < 0)
 		mode = PHY_INTERFACE_MODE_NA;
@@ -952,7 +953,7 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	}
 
 	if (ds->drv->get_phy_flags)
-		phy_flags = ds->drv->get_phy_flags(ds, p->port);
+		phy_flags = ds->drv->get_phy_flags(ds, p->dp->port);
 
 	if (phy_dn) {
 		int phy_id = of_mdio_parse_addr(&slave_dev->dev, phy_dn);
@@ -984,9 +985,11 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	 * MDIO bus instead
 	 */
 	if (!p->phy) {
-		ret = dsa_slave_phy_connect(p, slave_dev, p->port);
+		ret = dsa_slave_phy_connect(p, slave_dev, p->dp->port);
 		if (ret) {
-			netdev_err(slave_dev, "failed to connect to port %d: %d\n", p->port, ret);
+			netdev_err(slave_dev,
+				   "failed to connect to port %d: %d\n",
+				   p->dp->port, ret);
 			return ret;
 		}
 	}
@@ -1034,12 +1037,13 @@ int dsa_slave_resume(struct net_device *slave_dev)
 	return 0;
 }
 
-int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
-		     int port, char *name)
+int dsa_slave_create(struct dsa_port *dp, struct device *parent, char *name)
 {
+	struct dsa_switch *ds = dp->ds;
 	struct net_device *master = ds->dst->master_netdev;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
+	int port = dp->port;
 	int ret;
 
 	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
@@ -1063,8 +1067,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev->vlan_features = master->vlan_features;
 
 	p = netdev_priv(slave_dev);
-	p->parent = ds;
-	p->port = port;
+	p->dp = dp;
 
 	switch (ds->dst->tag_protocol) {
 #ifdef CONFIG_NET_DSA_TAG_DSA
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index e2aadb7..3d5aabc 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -80,9 +80,9 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 			((skb->priority << BRCM_IG_TC_SHIFT) & BRCM_IG_TC_MASK);
 	brcm_tag[1] = 0;
 	brcm_tag[2] = 0;
-	if (p->port == 8)
+	if (p->dp->port == 8)
 		brcm_tag[2] = BRCM_IG_DSTMAP2_MASK;
-	brcm_tag[3] = (1 << p->port) & BRCM_IG_DSTMAP1_MASK;
+	brcm_tag[3] = (1 << p->dp->port) & BRCM_IG_DSTMAP1_MASK;
 
 	return skb;
 
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index aa780e4..c870cfa 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -33,8 +33,8 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * Construct tagged FROM_CPU DSA tag from 802.1q tag.
 		 */
 		dsa_header = skb->data + 2 * ETH_ALEN;
-		dsa_header[0] = 0x60 | p->parent->index;
-		dsa_header[1] = p->port << 3;
+		dsa_header[0] = 0x60 | p->dp->ds->index;
+		dsa_header[1] = p->dp->port << 3;
 
 		/*
 		 * Move CFI field from byte 2 to byte 1.
@@ -54,8 +54,8 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * Construct untagged FROM_CPU DSA tag.
 		 */
 		dsa_header = skb->data + 2 * ETH_ALEN;
-		dsa_header[0] = 0x40 | p->parent->index;
-		dsa_header[1] = p->port << 3;
+		dsa_header[0] = 0x40 | p->dp->ds->index;
+		dsa_header[1] = p->dp->port << 3;
 		dsa_header[2] = 0x00;
 		dsa_header[3] = 0x00;
 	}
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 2288c80..898f949d 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -42,8 +42,8 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		edsa_header[1] = ETH_P_EDSA & 0xff;
 		edsa_header[2] = 0x00;
 		edsa_header[3] = 0x00;
-		edsa_header[4] = 0x60 | p->parent->index;
-		edsa_header[5] = p->port << 3;
+		edsa_header[4] = 0x60 | p->dp->ds->index;
+		edsa_header[5] = p->dp->port << 3;
 
 		/*
 		 * Move CFI field from byte 6 to byte 5.
@@ -67,8 +67,8 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		edsa_header[1] = ETH_P_EDSA & 0xff;
 		edsa_header[2] = 0x00;
 		edsa_header[3] = 0x00;
-		edsa_header[4] = 0x40 | p->parent->index;
-		edsa_header[5] = p->port << 3;
+		edsa_header[4] = 0x40 | p->dp->ds->index;
+		edsa_header[5] = p->dp->port << 3;
 		edsa_header[6] = 0x00;
 		edsa_header[7] = 0x00;
 	}
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index b6ca089..eaa3440 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -50,7 +50,7 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	trailer = skb_put(nskb, 4);
 	trailer[0] = 0x80;
-	trailer[1] = 1 << p->port;
+	trailer[1] = 1 << p->dp->port;
 	trailer[2] = 0x10;
 	trailer[3] = 0x00;
 
-- 
2.8.0
