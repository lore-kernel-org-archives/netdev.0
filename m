From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/9] net: dsa: store a dsa_port in dsa_slave_priv
Date: Fri, 27 Jan 2017 15:29:39 -0500
Message-ID: <20170127202944.28598-5-vivien.didelot@savoirfairelinux.com>
References: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Store a pointer to the dsa_port structure in the dsa_slave_priv
structure, instead of the switch/port index.

This will allow to store more information such as the bridge device,
needed in DSA drivers for multi-chip configuration.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h    |   8 +--
 net/dsa/slave.c       | 164 +++++++++++++++++++++++++-------------------------
 net/dsa/tag_brcm.c    |   4 +-
 net/dsa/tag_dsa.c     |   8 +--
 net/dsa/tag_edsa.c    |   8 +--
 net/dsa/tag_qca.c     |   2 +-
 net/dsa/tag_trailer.c |   2 +-
 7 files changed, 96 insertions(+), 100 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 16194a4bb2fe..c519bd0e9206 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -25,12 +25,8 @@ struct dsa_slave_priv {
 	struct sk_buff *	(*xmit)(struct sk_buff *skb,
 					struct net_device *dev);
 
-	/*
-	 * Which switch this port is a part of, and the port index
-	 * for this port.
-	 */
-	struct dsa_switch	*parent;
-	u8			port;
+	/* DSA port data, such as switch, port index, etc. */
+	struct dsa_port		*dp;
 
 	/*
 	 * The phylib phy_device pointer for the PHY connected
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 759824ba5545..2ea220bc4bba 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -61,7 +61,7 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	return p->parent->dst->master_netdev->ifindex;
+	return p->dp->ds->dst->master_netdev->ifindex;
 }
 
 static inline bool dsa_port_is_bridged(struct dsa_slave_priv *p)
@@ -96,8 +96,8 @@ static void dsa_port_set_stp_state(struct dsa_switch *ds, int port, u8 state)
 static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
-	struct dsa_switch *ds = p->parent;
+	struct net_device *master = p->dp->ds->dst->master_netdev;
+	struct dsa_switch *ds = p->dp->ds;
 	u8 stp_state = dsa_port_is_bridged(p) ?
 			BR_STATE_BLOCKING : BR_STATE_FORWARDING;
 	int err;
@@ -123,12 +123,12 @@ static int dsa_slave_open(struct net_device *dev)
 	}
 
 	if (ds->ops->port_enable) {
-		err = ds->ops->port_enable(ds, p->port, p->phy);
+		err = ds->ops->port_enable(ds, p->dp->index, p->phy);
 		if (err)
 			goto clear_promisc;
 	}
 
-	dsa_port_set_stp_state(ds, p->port, stp_state);
+	dsa_port_set_stp_state(ds, p->dp->index, stp_state);
 
 	if (p->phy)
 		phy_start(p->phy);
@@ -151,8 +151,8 @@ static int dsa_slave_open(struct net_device *dev)
 static int dsa_slave_close(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
-	struct dsa_switch *ds = p->parent;
+	struct net_device *master = p->dp->ds->dst->master_netdev;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (p->phy)
 		phy_stop(p->phy);
@@ -168,9 +168,9 @@ static int dsa_slave_close(struct net_device *dev)
 		dev_uc_del(master, dev->dev_addr);
 
 	if (ds->ops->port_disable)
-		ds->ops->port_disable(ds, p->port, p->phy);
+		ds->ops->port_disable(ds, p->dp->index, p->phy);
 
-	dsa_port_set_stp_state(ds, p->port, BR_STATE_DISABLED);
+	dsa_port_set_stp_state(ds, p->dp->index, BR_STATE_DISABLED);
 
 	return 0;
 }
@@ -178,7 +178,7 @@ static int dsa_slave_close(struct net_device *dev)
 static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
+	struct net_device *master = p->dp->ds->dst->master_netdev;
 
 	if (change & IFF_ALLMULTI)
 		dev_set_allmulti(master, dev->flags & IFF_ALLMULTI ? 1 : -1);
@@ -189,7 +189,7 @@ static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 static void dsa_slave_set_rx_mode(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
+	struct net_device *master = p->dp->ds->dst->master_netdev;
 
 	dev_mc_sync(master, dev);
 	dev_uc_sync(master, dev);
@@ -198,7 +198,7 @@ static void dsa_slave_set_rx_mode(struct net_device *dev)
 static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
+	struct net_device *master = p->dp->ds->dst->master_netdev;
 	struct sockaddr *addr = a;
 	int err;
 
@@ -228,16 +228,17 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 				   struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_port *dp = p->dp;
+	struct dsa_switch *ds = dp->ds;
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->ops->port_vlan_prepare || !ds->ops->port_vlan_add)
 			return -EOPNOTSUPP;
 
-		return ds->ops->port_vlan_prepare(ds, p->port, vlan, trans);
+		return ds->ops->port_vlan_prepare(ds, dp->index, vlan, trans);
 	}
 
-	ds->ops->port_vlan_add(ds, p->port, vlan, trans);
+	ds->ops->port_vlan_add(ds, dp->index, vlan, trans);
 
 	return 0;
 }
@@ -246,12 +247,12 @@ static int dsa_slave_port_vlan_del(struct net_device *dev,
 				   const struct switchdev_obj_port_vlan *vlan)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (!ds->ops->port_vlan_del)
 		return -EOPNOTSUPP;
 
-	return ds->ops->port_vlan_del(ds, p->port, vlan);
+	return ds->ops->port_vlan_del(ds, p->dp->index, vlan);
 }
 
 static int dsa_slave_port_vlan_dump(struct net_device *dev,
@@ -259,10 +260,10 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 				    switchdev_obj_dump_cb_t *cb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->ops->port_vlan_dump)
-		return ds->ops->port_vlan_dump(ds, p->port, vlan, cb);
+		return ds->ops->port_vlan_dump(ds, p->dp->index, vlan, cb);
 
 	return -EOPNOTSUPP;
 }
@@ -272,16 +273,16 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 				  struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->ops->port_fdb_prepare || !ds->ops->port_fdb_add)
 			return -EOPNOTSUPP;
 
-		return ds->ops->port_fdb_prepare(ds, p->port, fdb, trans);
+		return ds->ops->port_fdb_prepare(ds, p->dp->index, fdb, trans);
 	}
 
-	ds->ops->port_fdb_add(ds, p->port, fdb, trans);
+	ds->ops->port_fdb_add(ds, p->dp->index, fdb, trans);
 
 	return 0;
 }
@@ -290,11 +291,11 @@ static int dsa_slave_port_fdb_del(struct net_device *dev,
 				  const struct switchdev_obj_port_fdb *fdb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	int ret = -EOPNOTSUPP;
 
 	if (ds->ops->port_fdb_del)
-		ret = ds->ops->port_fdb_del(ds, p->port, fdb);
+		ret = ds->ops->port_fdb_del(ds, p->dp->index, fdb);
 
 	return ret;
 }
@@ -304,10 +305,10 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 				   switchdev_obj_dump_cb_t *cb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->ops->port_fdb_dump)
-		return ds->ops->port_fdb_dump(ds, p->port, fdb, cb);
+		return ds->ops->port_fdb_dump(ds, p->dp->index, fdb, cb);
 
 	return -EOPNOTSUPP;
 }
@@ -317,16 +318,16 @@ static int dsa_slave_port_mdb_add(struct net_device *dev,
 				  struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->ops->port_mdb_prepare || !ds->ops->port_mdb_add)
 			return -EOPNOTSUPP;
 
-		return ds->ops->port_mdb_prepare(ds, p->port, mdb, trans);
+		return ds->ops->port_mdb_prepare(ds, p->dp->index, mdb, trans);
 	}
 
-	ds->ops->port_mdb_add(ds, p->port, mdb, trans);
+	ds->ops->port_mdb_add(ds, p->dp->index, mdb, trans);
 
 	return 0;
 }
@@ -335,10 +336,10 @@ static int dsa_slave_port_mdb_del(struct net_device *dev,
 				  const struct switchdev_obj_port_mdb *mdb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->ops->port_mdb_del)
-		return ds->ops->port_mdb_del(ds, p->port, mdb);
+		return ds->ops->port_mdb_del(ds, p->dp->index, mdb);
 
 	return -EOPNOTSUPP;
 }
@@ -348,10 +349,10 @@ static int dsa_slave_port_mdb_dump(struct net_device *dev,
 				   switchdev_obj_dump_cb_t *cb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->ops->port_mdb_dump)
-		return ds->ops->port_mdb_dump(ds, p->port, mdb, cb);
+		return ds->ops->port_mdb_dump(ds, p->dp->index, mdb, cb);
 
 	return -EOPNOTSUPP;
 }
@@ -371,12 +372,12 @@ static int dsa_slave_stp_state_set(struct net_device *dev,
 				   struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (switchdev_trans_ph_prepare(trans))
 		return ds->ops->port_stp_state_set ? 0 : -EOPNOTSUPP;
 
-	dsa_port_set_stp_state(ds, p->port, attr->u.stp_state);
+	dsa_port_set_stp_state(ds, p->dp->index, attr->u.stp_state);
 
 	return 0;
 }
@@ -386,14 +387,14 @@ static int dsa_slave_vlan_filtering(struct net_device *dev,
 				    struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	/* bridge skips -EOPNOTSUPP, so skip the prepare phase */
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
 	if (ds->ops->port_vlan_filtering)
-		return ds->ops->port_vlan_filtering(ds, p->port,
+		return ds->ops->port_vlan_filtering(ds, p->dp->index,
 						    attr->u.vlan_filtering);
 
 	return 0;
@@ -419,7 +420,7 @@ static int dsa_slave_ageing_time(struct net_device *dev,
 				 struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	unsigned long ageing_jiffies = clock_t_to_jiffies(attr->u.ageing_time);
 	unsigned int ageing_time = jiffies_to_msecs(ageing_jiffies);
 
@@ -428,7 +429,7 @@ static int dsa_slave_ageing_time(struct net_device *dev,
 		return 0;
 
 	/* Keep the fastest ageing time in case of multiple bridges */
-	ds->ports[p->port].ageing_time = ageing_time;
+	p->dp->ageing_time = ageing_time;
 	ageing_time = dsa_fastest_ageing_time(ds, ageing_time);
 
 	if (ds->ops->set_ageing_time)
@@ -553,13 +554,13 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 				      struct net_device *br)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	int ret = -EOPNOTSUPP;
 
 	p->bridge_dev = br;
 
 	if (ds->ops->port_bridge_join)
-		ret = ds->ops->port_bridge_join(ds, p->port, br);
+		ret = ds->ops->port_bridge_join(ds, p->dp->index, br);
 
 	return ret == -EOPNOTSUPP ? 0 : ret;
 }
@@ -567,25 +568,25 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 static void dsa_slave_bridge_port_leave(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 
 	if (ds->ops->port_bridge_leave)
-		ds->ops->port_bridge_leave(ds, p->port);
+		ds->ops->port_bridge_leave(ds, p->dp->index);
 
 	p->bridge_dev = NULL;
 
 	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
 	 */
-	dsa_port_set_stp_state(ds, p->port, BR_STATE_FORWARDING);
+	dsa_port_set_stp_state(ds, p->dp->index, BR_STATE_FORWARDING);
 }
 
 static int dsa_slave_port_attr_get(struct net_device *dev,
 				   struct switchdev_attr *attr)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
@@ -633,7 +634,7 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Queue the SKB for transmission on the parent interface, but
 	 * do not modify its EtherType
 	 */
-	nskb->dev = p->parent->dst->master_netdev;
+	nskb->dev = p->dp->ds->dst->master_netdev;
 	dev_queue_xmit(nskb);
 
 	return NETDEV_TX_OK;
@@ -680,10 +681,10 @@ static void dsa_slave_get_drvinfo(struct net_device *dev,
 static int dsa_slave_get_regs_len(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->ops->get_regs_len)
-		return ds->ops->get_regs_len(ds, p->port);
+		return ds->ops->get_regs_len(ds, p->dp->index);
 
 	return -EOPNOTSUPP;
 }
@@ -692,10 +693,10 @@ static void
 dsa_slave_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *_p)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->ops->get_regs)
-		ds->ops->get_regs(ds, p->port, regs, _p);
+		ds->ops->get_regs(ds, p->dp->index, regs, _p);
 }
 
 static int dsa_slave_nway_reset(struct net_device *dev)
@@ -723,7 +724,7 @@ static u32 dsa_slave_get_link(struct net_device *dev)
 static int dsa_slave_get_eeprom_len(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->cd && ds->cd->eeprom_len)
 		return ds->cd->eeprom_len;
@@ -738,7 +739,7 @@ static int dsa_slave_get_eeprom(struct net_device *dev,
 				struct ethtool_eeprom *eeprom, u8 *data)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->ops->get_eeprom)
 		return ds->ops->get_eeprom(ds, eeprom, data);
@@ -750,7 +751,7 @@ static int dsa_slave_set_eeprom(struct net_device *dev,
 				struct ethtool_eeprom *eeprom, u8 *data)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->ops->set_eeprom)
 		return ds->ops->set_eeprom(ds, eeprom, data);
@@ -762,7 +763,7 @@ static void dsa_slave_get_strings(struct net_device *dev,
 				  uint32_t stringset, uint8_t *data)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (stringset == ETH_SS_STATS) {
 		int len = ETH_GSTRING_LEN;
@@ -772,7 +773,7 @@ static void dsa_slave_get_strings(struct net_device *dev,
 		strncpy(data + 2 * len, "rx_packets", len);
 		strncpy(data + 3 * len, "rx_bytes", len);
 		if (ds->ops->get_strings)
-			ds->ops->get_strings(ds, p->port, data + 4 * len);
+			ds->ops->get_strings(ds, p->dp->index, data + 4 * len);
 	}
 }
 
@@ -853,20 +854,20 @@ static void dsa_slave_get_ethtool_stats(struct net_device *dev,
 					uint64_t *data)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	data[0] = dev->stats.tx_packets;
 	data[1] = dev->stats.tx_bytes;
 	data[2] = dev->stats.rx_packets;
 	data[3] = dev->stats.rx_bytes;
 	if (ds->ops->get_ethtool_stats)
-		ds->ops->get_ethtool_stats(ds, p->port, data + 4);
+		ds->ops->get_ethtool_stats(ds, p->dp->index, data + 4);
 }
 
 static int dsa_slave_get_sset_count(struct net_device *dev, int sset)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (sset == ETH_SS_STATS) {
 		int count;
@@ -884,20 +885,20 @@ static int dsa_slave_get_sset_count(struct net_device *dev, int sset)
 static void dsa_slave_get_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	if (ds->ops->get_wol)
-		ds->ops->get_wol(ds, p->port, w);
+		ds->ops->get_wol(ds, p->dp->index, w);
 }
 
 static int dsa_slave_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	int ret = -EOPNOTSUPP;
 
 	if (ds->ops->set_wol)
-		ret = ds->ops->set_wol(ds, p->port, w);
+		ret = ds->ops->set_wol(ds, p->dp->index, w);
 
 	return ret;
 }
@@ -905,13 +906,13 @@ static int dsa_slave_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	int ret;
 
 	if (!ds->ops->set_eee)
 		return -EOPNOTSUPP;
 
-	ret = ds->ops->set_eee(ds, p->port, p->phy, e);
+	ret = ds->ops->set_eee(ds, p->dp->index, p->phy, e);
 	if (ret)
 		return ret;
 
@@ -924,13 +925,13 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	int ret;
 
 	if (!ds->ops->get_eee)
 		return -EOPNOTSUPP;
 
-	ret = ds->ops->get_eee(ds, p->port, e);
+	ret = ds->ops->get_eee(ds, p->dp->index, e);
 	if (ret)
 		return ret;
 
@@ -945,7 +946,7 @@ static int dsa_slave_netpoll_setup(struct net_device *dev,
 				   struct netpoll_info *ni)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	struct net_device *master = ds->dst->master_netdev;
 	struct netpoll *netpoll;
 	int err = 0;
@@ -988,7 +989,7 @@ static int dsa_slave_get_phys_port_name(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	if (snprintf(name, len, "p%d", p->port) >= len)
+	if (snprintf(name, len, "p%d", p->dp->index) >= len)
 		return -EINVAL;
 
 	return 0;
@@ -1059,7 +1060,7 @@ static struct device_type dsa_type = {
 static void dsa_slave_adjust_link(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	unsigned int status_changed = 0;
 
 	if (p->old_link != p->phy->link) {
@@ -1078,7 +1079,7 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 	}
 
 	if (ds->ops->adjust_link && status_changed)
-		ds->ops->adjust_link(ds, p->port, p->phy);
+		ds->ops->adjust_link(ds, p->dp->index, p->phy);
 
 	if (status_changed)
 		phy_print_status(p->phy);
@@ -1092,9 +1093,9 @@ static int dsa_slave_fixed_link_update(struct net_device *dev,
 
 	if (dev) {
 		p = netdev_priv(dev);
-		ds = p->parent;
+		ds = p->dp->ds;
 		if (ds->ops->fixed_link_update)
-			ds->ops->fixed_link_update(ds, p->port, status);
+			ds->ops->fixed_link_update(ds, p->dp->index, status);
 	}
 
 	return 0;
@@ -1105,7 +1106,7 @@ static int dsa_slave_phy_connect(struct dsa_slave_priv *p,
 				 struct net_device *slave_dev,
 				 int addr)
 {
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 
 	p->phy = mdiobus_get_phy(ds->slave_mii_bus, addr);
 	if (!p->phy) {
@@ -1125,13 +1126,13 @@ static int dsa_slave_phy_connect(struct dsa_slave_priv *p,
 static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 				struct net_device *slave_dev)
 {
-	struct dsa_switch *ds = p->parent;
+	struct dsa_switch *ds = p->dp->ds;
 	struct device_node *phy_dn, *port_dn;
 	bool phy_is_fixed = false;
 	u32 phy_flags = 0;
 	int mode, ret;
 
-	port_dn = ds->ports[p->port].dn;
+	port_dn = p->dp->dn;
 	mode = of_get_phy_mode(port_dn);
 	if (mode < 0)
 		mode = PHY_INTERFACE_MODE_NA;
@@ -1152,7 +1153,7 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	}
 
 	if (ds->ops->get_phy_flags)
-		phy_flags = ds->ops->get_phy_flags(ds, p->port);
+		phy_flags = ds->ops->get_phy_flags(ds, p->dp->index);
 
 	if (phy_dn) {
 		int phy_id = of_mdio_parse_addr(&slave_dev->dev, phy_dn);
@@ -1187,9 +1188,10 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	 * MDIO bus instead
 	 */
 	if (!p->phy) {
-		ret = dsa_slave_phy_connect(p, slave_dev, p->port);
+		ret = dsa_slave_phy_connect(p, slave_dev, p->dp->index);
 		if (ret) {
-			netdev_err(slave_dev, "failed to connect to port %d: %d\n", p->port, ret);
+			netdev_err(slave_dev, "failed to connect to port %d: %d\n",
+				   p->dp->index, ret);
 			if (phy_is_fixed)
 				of_phy_deregister_fixed_link(port_dn);
 			return ret;
@@ -1275,8 +1277,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev->vlan_features = master->vlan_features;
 
 	p = netdev_priv(slave_dev);
-	p->parent = ds;
-	p->port = port;
+	p->dp = &ds->ports[port];
 	p->xmit = dst->tag_ops->xmit;
 
 	p->old_pause = -1;
@@ -1309,10 +1310,9 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 void dsa_slave_destroy(struct net_device *slave_dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(slave_dev);
-	struct dsa_switch *ds = p->parent;
 	struct device_node *port_dn;
 
-	port_dn = ds->ports[p->port].dn;
+	port_dn = p->dp->dn;
 
 	netif_carrier_off(slave_dev);
 	if (p->phy) {
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 93e4458c02f9..5d925b6b2bb1 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -80,9 +80,9 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 			((skb->priority << BRCM_IG_TC_SHIFT) & BRCM_IG_TC_MASK);
 	brcm_tag[1] = 0;
 	brcm_tag[2] = 0;
-	if (p->port == 8)
+	if (p->dp->index == 8)
 		brcm_tag[2] = BRCM_IG_DSTMAP2_MASK;
-	brcm_tag[3] = (1 << p->port) & BRCM_IG_DSTMAP1_MASK;
+	brcm_tag[3] = (1 << p->dp->index) & BRCM_IG_DSTMAP1_MASK;
 
 	return skb;
 
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 8fa4b1942671..72579ceea381 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -33,8 +33,8 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * Construct tagged FROM_CPU DSA tag from 802.1q tag.
 		 */
 		dsa_header = skb->data + 2 * ETH_ALEN;
-		dsa_header[0] = 0x60 | p->parent->index;
-		dsa_header[1] = p->port << 3;
+		dsa_header[0] = 0x60 | p->dp->ds->index;
+		dsa_header[1] = p->dp->index << 3;
 
 		/*
 		 * Move CFI field from byte 2 to byte 1.
@@ -54,8 +54,8 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * Construct untagged FROM_CPU DSA tag.
 		 */
 		dsa_header = skb->data + 2 * ETH_ALEN;
-		dsa_header[0] = 0x40 | p->parent->index;
-		dsa_header[1] = p->port << 3;
+		dsa_header[0] = 0x40 | p->dp->ds->index;
+		dsa_header[1] = p->dp->index << 3;
 		dsa_header[2] = 0x00;
 		dsa_header[3] = 0x00;
 	}
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 929de581a846..648c051817a1 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -42,8 +42,8 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		edsa_header[1] = ETH_P_EDSA & 0xff;
 		edsa_header[2] = 0x00;
 		edsa_header[3] = 0x00;
-		edsa_header[4] = 0x60 | p->parent->index;
-		edsa_header[5] = p->port << 3;
+		edsa_header[4] = 0x60 | p->dp->ds->index;
+		edsa_header[5] = p->dp->index << 3;
 
 		/*
 		 * Move CFI field from byte 6 to byte 5.
@@ -67,8 +67,8 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		edsa_header[1] = ETH_P_EDSA & 0xff;
 		edsa_header[2] = 0x00;
 		edsa_header[3] = 0x00;
-		edsa_header[4] = 0x40 | p->parent->index;
-		edsa_header[5] = p->port << 3;
+		edsa_header[4] = 0x40 | p->dp->ds->index;
+		edsa_header[5] = p->dp->index << 3;
 		edsa_header[6] = 0x00;
 		edsa_header[7] = 0x00;
 	}
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 736ca8e8c31e..30240f343aea 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -54,7 +54,7 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Set the version field, and set destination port information */
 	hdr = QCA_HDR_VERSION << QCA_HDR_XMIT_VERSION_S |
 		QCA_HDR_XMIT_FROM_CPU |
-		BIT(p->port);
+		BIT(p->dp->index);
 
 	*phdr = htons(hdr);
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index d8e55a845d7f..26f977176978 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -50,7 +50,7 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	trailer = skb_put(nskb, 4);
 	trailer[0] = 0x80;
-	trailer[1] = 1 << p->port;
+	trailer[1] = 1 << p->dp->index;
 	trailer[2] = 0x10;
 	trailer[3] = 0x00;
 
-- 
2.11.0
