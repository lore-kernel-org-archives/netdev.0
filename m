From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 3/7] net: dsa: add slave to port helper
Date: Mon, 16 Oct 2017 11:12:15 -0400
Message-ID: <20171016151219.22023-4-vivien.didelot@savoirfairelinux.com>
References: <20171016151219.22023-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016151219.22023-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many portions of DSA core code require to get the dsa_port structure
corresponding to a slave net_device. For this purpose, introduce a
dsa_slave_to_port() helper.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa_priv.h    |   7 +++
 net/dsa/legacy.c      |   6 +-
 net/dsa/slave.c       | 167 +++++++++++++++++++++++++-------------------------
 net/dsa/tag_brcm.c    |   9 ++-
 net/dsa/tag_dsa.c     |  10 +--
 net/dsa/tag_edsa.c    |  10 +--
 net/dsa/tag_ksz.c     |   4 +-
 net/dsa/tag_lan9303.c |   4 +-
 net/dsa/tag_mtk.c     |   4 +-
 net/dsa/tag_qca.c     |   5 +-
 net/dsa/tag_trailer.c |   4 +-
 11 files changed, 115 insertions(+), 115 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 2850077cc9cc..569a4929b4c9 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -169,6 +169,13 @@ int dsa_slave_resume(struct net_device *slave_dev);
 int dsa_slave_register_notifier(void);
 void dsa_slave_unregister_notifier(void);
 
+static inline struct dsa_port *dsa_slave_to_port(const struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	return p->dp;
+}
+
 /* switch.c */
 int dsa_switch_register_notifier(struct dsa_switch *ds);
 void dsa_switch_unregister_notifier(struct dsa_switch *ds);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index b0fefbffe082..cc28c6f792a3 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -740,8 +740,7 @@ int dsa_legacy_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		       const unsigned char *addr, u16 vid,
 		       u16 flags)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_port *dp = p->dp;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 
 	return dsa_port_fdb_add(dp, addr, vid);
 }
@@ -750,8 +749,7 @@ int dsa_legacy_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 		       struct net_device *dev,
 		       const unsigned char *addr, u16 vid)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_port *dp = p->dp;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 
 	return dsa_port_fdb_del(dp, addr, vid);
 }
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index f31737256f69..894602c88b09 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -72,8 +72,8 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
 static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_port *dp = p->dp;
 	struct net_device *master = dsa_master_netdev(p);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	int err;
 
 	if (!(master->flags & IFF_UP))
@@ -122,7 +122,7 @@ static int dsa_slave_close(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct net_device *master = dsa_master_netdev(p);
-	struct dsa_port *dp = p->dp;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 
 	if (dev->phydev)
 		phy_stop(dev->phydev);
@@ -246,14 +246,13 @@ dsa_slave_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		   struct net_device *dev, struct net_device *filter_dev,
 		   int *idx)
 {
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	struct dsa_slave_dump_ctx dump = {
 		.dev = dev,
 		.skb = skb,
 		.cb = cb,
 		.idx = *idx,
 	};
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_port *dp = p->dp;
 	int err;
 
 	err = dsa_port_fdb_dump(dp, dsa_slave_port_fdb_do_dump, &dump);
@@ -274,8 +273,7 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 				   const struct switchdev_attr *attr,
 				   struct switchdev_trans *trans)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_port *dp = p->dp;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	int ret;
 
 	switch (attr->id) {
@@ -301,8 +299,7 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 				  const struct switchdev_obj *obj,
 				  struct switchdev_trans *trans)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_port *dp = p->dp;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	int err;
 
 	/* For the prepare phase, ensure the full set of changes is feasable in
@@ -329,8 +326,7 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 static int dsa_slave_port_obj_del(struct net_device *dev,
 				  const struct switchdev_obj *obj)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_port *dp = p->dp;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	int err;
 
 	switch (obj->id) {
@@ -351,8 +347,8 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 static int dsa_slave_port_attr_get(struct net_device *dev,
 				   struct switchdev_attr *attr)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
@@ -431,11 +427,11 @@ static void dsa_slave_get_drvinfo(struct net_device *dev,
 
 static int dsa_slave_get_regs_len(struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 
 	if (ds->ops->get_regs_len)
-		return ds->ops->get_regs_len(ds, p->dp->index);
+		return ds->ops->get_regs_len(ds, dp->index);
 
 	return -EOPNOTSUPP;
 }
@@ -443,11 +439,11 @@ static int dsa_slave_get_regs_len(struct net_device *dev)
 static void
 dsa_slave_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *_p)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 
 	if (ds->ops->get_regs)
-		ds->ops->get_regs(ds, p->dp->index, regs, _p);
+		ds->ops->get_regs(ds, dp->index, regs, _p);
 }
 
 static u32 dsa_slave_get_link(struct net_device *dev)
@@ -462,8 +458,8 @@ static u32 dsa_slave_get_link(struct net_device *dev)
 
 static int dsa_slave_get_eeprom_len(struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 
 	if (ds->cd && ds->cd->eeprom_len)
 		return ds->cd->eeprom_len;
@@ -477,8 +473,8 @@ static int dsa_slave_get_eeprom_len(struct net_device *dev)
 static int dsa_slave_get_eeprom(struct net_device *dev,
 				struct ethtool_eeprom *eeprom, u8 *data)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 
 	if (ds->ops->get_eeprom)
 		return ds->ops->get_eeprom(ds, eeprom, data);
@@ -489,8 +485,8 @@ static int dsa_slave_get_eeprom(struct net_device *dev,
 static int dsa_slave_set_eeprom(struct net_device *dev,
 				struct ethtool_eeprom *eeprom, u8 *data)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 
 	if (ds->ops->set_eeprom)
 		return ds->ops->set_eeprom(ds, eeprom, data);
@@ -501,8 +497,8 @@ static int dsa_slave_set_eeprom(struct net_device *dev,
 static void dsa_slave_get_strings(struct net_device *dev,
 				  uint32_t stringset, uint8_t *data)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 
 	if (stringset == ETH_SS_STATS) {
 		int len = ETH_GSTRING_LEN;
@@ -512,7 +508,7 @@ static void dsa_slave_get_strings(struct net_device *dev,
 		strncpy(data + 2 * len, "rx_packets", len);
 		strncpy(data + 3 * len, "rx_bytes", len);
 		if (ds->ops->get_strings)
-			ds->ops->get_strings(ds, p->dp->index, data + 4 * len);
+			ds->ops->get_strings(ds, dp->index, data + 4 * len);
 	}
 }
 
@@ -520,8 +516,9 @@ static void dsa_slave_get_ethtool_stats(struct net_device *dev,
 					struct ethtool_stats *stats,
 					uint64_t *data)
 {
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 	struct pcpu_sw_netstats *s;
 	unsigned int start;
 	int i;
@@ -543,13 +540,13 @@ static void dsa_slave_get_ethtool_stats(struct net_device *dev,
 		data[3] += rx_bytes;
 	}
 	if (ds->ops->get_ethtool_stats)
-		ds->ops->get_ethtool_stats(ds, p->dp->index, data + 4);
+		ds->ops->get_ethtool_stats(ds, dp->index, data + 4);
 }
 
 static int dsa_slave_get_sset_count(struct net_device *dev, int sset)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 
 	if (sset == ETH_SS_STATS) {
 		int count;
@@ -566,29 +563,29 @@ static int dsa_slave_get_sset_count(struct net_device *dev, int sset)
 
 static void dsa_slave_get_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 
 	if (ds->ops->get_wol)
-		ds->ops->get_wol(ds, p->dp->index, w);
+		ds->ops->get_wol(ds, dp->index, w);
 }
 
 static int dsa_slave_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 	int ret = -EOPNOTSUPP;
 
 	if (ds->ops->set_wol)
-		ret = ds->ops->set_wol(ds, p->dp->index, w);
+		ret = ds->ops->set_wol(ds, dp->index, w);
 
 	return ret;
 }
 
 static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 	int ret;
 
 	/* Port's PHY and MAC both need to be EEE capable */
@@ -598,7 +595,7 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	if (!ds->ops->set_mac_eee)
 		return -EOPNOTSUPP;
 
-	ret = ds->ops->set_mac_eee(ds, p->dp->index, e);
+	ret = ds->ops->set_mac_eee(ds, dp->index, e);
 	if (ret)
 		return ret;
 
@@ -613,8 +610,8 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 
 static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 	int ret;
 
 	/* Port's PHY and MAC both need to be EEE capable */
@@ -624,7 +621,7 @@ static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 	if (!ds->ops->get_mac_eee)
 		return -EOPNOTSUPP;
 
-	ret = ds->ops->get_mac_eee(ds, p->dp->index, e);
+	ret = ds->ops->get_mac_eee(ds, dp->index, e);
 	if (ret)
 		return ret;
 
@@ -676,9 +673,9 @@ static void dsa_slave_poll_controller(struct net_device *dev)
 static int dsa_slave_get_phys_port_name(struct net_device *dev,
 					char *name, size_t len)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 
-	if (snprintf(name, len, "p%d", p->dp->index) >= len)
+	if (snprintf(name, len, "p%d", dp->index) >= len)
 		return -EINVAL;
 
 	return 0;
@@ -701,14 +698,15 @@ static int dsa_slave_add_cls_matchall(struct net_device *dev,
 				      struct tc_cls_matchall_offload *cls,
 				      bool ingress)
 {
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_mall_tc_entry *mall_tc_entry;
 	__be16 protocol = cls->common.protocol;
-	struct dsa_switch *ds = p->dp->ds;
 	struct net *net = dev_net(dev);
-	struct dsa_slave_priv *to_p;
+	struct dsa_switch *ds = dp->ds;
 	struct net_device *to_dev;
 	const struct tc_action *a;
+	struct dsa_port *to_dp;
 	int err = -EOPNOTSUPP;
 	LIST_HEAD(actions);
 	int ifindex;
@@ -741,13 +739,12 @@ static int dsa_slave_add_cls_matchall(struct net_device *dev,
 		mall_tc_entry->type = DSA_PORT_MALL_MIRROR;
 		mirror = &mall_tc_entry->mirror;
 
-		to_p = netdev_priv(to_dev);
+		to_dp = dsa_slave_to_port(to_dev);
 
-		mirror->to_local_port = to_p->dp->index;
+		mirror->to_local_port = to_dp->index;
 		mirror->ingress = ingress;
 
-		err = ds->ops->port_mirror_add(ds, p->dp->index, mirror,
-					       ingress);
+		err = ds->ops->port_mirror_add(ds, dp->index, mirror, ingress);
 		if (err) {
 			kfree(mall_tc_entry);
 			return err;
@@ -762,9 +759,9 @@ static int dsa_slave_add_cls_matchall(struct net_device *dev,
 static void dsa_slave_del_cls_matchall(struct net_device *dev,
 				       struct tc_cls_matchall_offload *cls)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	struct dsa_mall_tc_entry *mall_tc_entry;
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 
 	if (!ds->ops->port_mirror_del)
 		return;
@@ -777,8 +774,7 @@ static void dsa_slave_del_cls_matchall(struct net_device *dev,
 
 	switch (mall_tc_entry->type) {
 	case DSA_PORT_MALL_MIRROR:
-		ds->ops->port_mirror_del(ds, p->dp->index,
-					 &mall_tc_entry->mirror);
+		ds->ops->port_mirror_del(ds, dp->index, &mall_tc_entry->mirror);
 		break;
 	default:
 		WARN_ON(1);
@@ -855,25 +851,25 @@ static void dsa_slave_get_stats64(struct net_device *dev,
 static int dsa_slave_get_rxnfc(struct net_device *dev,
 			       struct ethtool_rxnfc *nfc, u32 *rule_locs)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 
 	if (!ds->ops->get_rxnfc)
 		return -EOPNOTSUPP;
 
-	return ds->ops->get_rxnfc(ds, p->dp->index, nfc, rule_locs);
+	return ds->ops->get_rxnfc(ds, dp->index, nfc, rule_locs);
 }
 
 static int dsa_slave_set_rxnfc(struct net_device *dev,
 			       struct ethtool_rxnfc *nfc)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+	struct dsa_switch *ds = dp->ds;
 
 	if (!ds->ops->set_rxnfc)
 		return -EOPNOTSUPP;
 
-	return ds->ops->set_rxnfc(ds, p->dp->index, nfc);
+	return ds->ops->set_rxnfc(ds, dp->index, nfc);
 }
 
 static const struct ethtool_ops dsa_slave_ethtool_ops = {
@@ -933,8 +929,9 @@ static struct device_type dsa_type = {
 
 static void dsa_slave_adjust_link(struct net_device *dev)
 {
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 	unsigned int status_changed = 0;
 
 	if (p->old_link != dev->phydev->link) {
@@ -953,7 +950,7 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 	}
 
 	if (ds->ops->adjust_link && status_changed)
-		ds->ops->adjust_link(ds, p->dp->index, dev->phydev);
+		ds->ops->adjust_link(ds, dp->index, dev->phydev);
 
 	if (status_changed)
 		phy_print_status(dev->phydev);
@@ -962,14 +959,14 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 static int dsa_slave_fixed_link_update(struct net_device *dev,
 				       struct fixed_phy_status *status)
 {
-	struct dsa_slave_priv *p;
 	struct dsa_switch *ds;
+	struct dsa_port *dp;
 
 	if (dev) {
-		p = netdev_priv(dev);
-		ds = p->dp->ds;
+		dp = dsa_slave_to_port(dev);
+		ds = dp->ds;
 		if (ds->ops->fixed_link_update)
-			ds->ops->fixed_link_update(ds, p->dp->index, status);
+			ds->ops->fixed_link_update(ds, dp->index, status);
 	}
 
 	return 0;
@@ -978,8 +975,9 @@ static int dsa_slave_fixed_link_update(struct net_device *dev,
 /* slave device setup *******************************************************/
 static int dsa_slave_phy_connect(struct net_device *slave_dev, int addr)
 {
+	struct dsa_port *dp = dsa_slave_to_port(slave_dev);
 	struct dsa_slave_priv *p = netdev_priv(slave_dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_switch *ds = dp->ds;
 
 	slave_dev->phydev = mdiobus_get_phy(ds->slave_mii_bus, addr);
 	if (!slave_dev->phydev) {
@@ -997,14 +995,15 @@ static int dsa_slave_phy_connect(struct net_device *slave_dev, int addr)
 
 static int dsa_slave_phy_setup(struct net_device *slave_dev)
 {
+	struct dsa_port *dp = dsa_slave_to_port(slave_dev);
 	struct dsa_slave_priv *p = netdev_priv(slave_dev);
-	struct dsa_switch *ds = p->dp->ds;
-	struct device_node *phy_dn, *port_dn;
+	struct device_node *port_dn = dp->dn;
+	struct dsa_switch *ds = dp->ds;
+	struct device_node *phy_dn;
 	bool phy_is_fixed = false;
 	u32 phy_flags = 0;
 	int mode, ret;
 
-	port_dn = p->dp->dn;
 	mode = of_get_phy_mode(port_dn);
 	if (mode < 0)
 		mode = PHY_INTERFACE_MODE_NA;
@@ -1025,7 +1024,7 @@ static int dsa_slave_phy_setup(struct net_device *slave_dev)
 	}
 
 	if (ds->ops->get_phy_flags)
-		phy_flags = ds->ops->get_phy_flags(ds, p->dp->index);
+		phy_flags = ds->ops->get_phy_flags(ds, dp->index);
 
 	if (phy_dn) {
 		int phy_id = of_mdio_parse_addr(&slave_dev->dev, phy_dn);
@@ -1061,10 +1060,10 @@ static int dsa_slave_phy_setup(struct net_device *slave_dev)
 	 * MDIO bus instead
 	 */
 	if (!slave_dev->phydev) {
-		ret = dsa_slave_phy_connect(slave_dev, p->dp->index);
+		ret = dsa_slave_phy_connect(slave_dev, dp->index);
 		if (ret) {
 			netdev_err(slave_dev, "failed to connect to port %d: %d\n",
-				   p->dp->index, ret);
+				   dp->index, ret);
 			if (phy_is_fixed)
 				of_phy_deregister_fixed_link(port_dn);
 			return ret;
@@ -1118,7 +1117,7 @@ static void dsa_slave_notify(struct net_device *dev, unsigned long val)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct net_device *master = dsa_master_netdev(p);
-	struct dsa_port *dp = p->dp;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	struct dsa_notifier_register_info rinfo = {
 		.switch_number = dp->ds->index,
 		.port_number = dp->index,
@@ -1202,8 +1201,8 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 
 out_phy:
 	phy_disconnect(slave_dev->phydev);
-	if (of_phy_is_fixed_link(p->dp->dn))
-		of_phy_deregister_fixed_link(p->dp->dn);
+	if (of_phy_is_fixed_link(port->dn))
+		of_phy_deregister_fixed_link(port->dn);
 out_free:
 	free_percpu(p->stats64);
 	free_netdev(slave_dev);
@@ -1213,10 +1212,9 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 
 void dsa_slave_destroy(struct net_device *slave_dev)
 {
+	struct dsa_port *dp = dsa_slave_to_port(slave_dev);
 	struct dsa_slave_priv *p = netdev_priv(slave_dev);
-	struct device_node *port_dn;
-
-	port_dn = p->dp->dn;
+	struct device_node *port_dn = dp->dn;
 
 	netif_carrier_off(slave_dev);
 	if (slave_dev->phydev) {
@@ -1239,8 +1237,7 @@ static bool dsa_slave_dev_check(struct net_device *dev)
 static int dsa_slave_changeupper(struct net_device *dev,
 				 struct netdev_notifier_changeupper_info *info)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_port *dp = p->dp;
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	int err = NOTIFY_DONE;
 
 	if (netif_is_bridge_master(info->upper_dev)) {
@@ -1283,14 +1280,14 @@ static void dsa_slave_switchdev_event_work(struct work_struct *work)
 		container_of(work, struct dsa_switchdev_event_work, work);
 	struct net_device *dev = switchdev_work->dev;
 	struct switchdev_notifier_fdb_info *fdb_info;
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	int err;
 
 	rtnl_lock();
 	switch (switchdev_work->event) {
 	case SWITCHDEV_FDB_ADD_TO_DEVICE:
 		fdb_info = &switchdev_work->fdb_info;
-		err = dsa_port_fdb_add(p->dp, fdb_info->addr, fdb_info->vid);
+		err = dsa_port_fdb_add(dp, fdb_info->addr, fdb_info->vid);
 		if (err) {
 			netdev_dbg(dev, "fdb add failed err=%d\n", err);
 			break;
@@ -1301,7 +1298,7 @@ static void dsa_slave_switchdev_event_work(struct work_struct *work)
 
 	case SWITCHDEV_FDB_DEL_TO_DEVICE:
 		fdb_info = &switchdev_work->fdb_info;
-		err = dsa_port_fdb_del(p->dp, fdb_info->addr, fdb_info->vid);
+		err = dsa_port_fdb_del(dp, fdb_info->addr, fdb_info->vid);
 		if (err) {
 			netdev_dbg(dev, "fdb del failed err=%d\n", err);
 			dev_close(dev);
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index cc4f472fbd77..2a0fa9f9f7ca 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -61,7 +61,7 @@
 
 static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	u16 queue = skb_get_queue_mapping(skb);
 	u8 *brcm_tag;
 
@@ -82,15 +82,14 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 		       ((queue & BRCM_IG_TC_MASK) << BRCM_IG_TC_SHIFT);
 	brcm_tag[1] = 0;
 	brcm_tag[2] = 0;
-	if (p->dp->index == 8)
+	if (dp->index == 8)
 		brcm_tag[2] = BRCM_IG_DSTMAP2_MASK;
-	brcm_tag[3] = (1 << p->dp->index) & BRCM_IG_DSTMAP1_MASK;
+	brcm_tag[3] = (1 << dp->index) & BRCM_IG_DSTMAP1_MASK;
 
 	/* Now tell the master network device about the desired output queue
 	 * as well
 	 */
-	skb_set_queue_mapping(skb, BRCM_TAG_SET_PORT_QUEUE(p->dp->index,
-							   queue));
+	skb_set_queue_mapping(skb, BRCM_TAG_SET_PORT_QUEUE(dp->index, queue));
 
 	return skb;
 }
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index c77218f173d1..fe3c9700a8c8 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -18,7 +18,7 @@
 
 static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	u8 *dsa_header;
 
 	/*
@@ -34,8 +34,8 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * Construct tagged FROM_CPU DSA tag from 802.1q tag.
 		 */
 		dsa_header = skb->data + 2 * ETH_ALEN;
-		dsa_header[0] = 0x60 | p->dp->ds->index;
-		dsa_header[1] = p->dp->index << 3;
+		dsa_header[0] = 0x60 | dp->ds->index;
+		dsa_header[1] = dp->index << 3;
 
 		/*
 		 * Move CFI field from byte 2 to byte 1.
@@ -55,8 +55,8 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * Construct untagged FROM_CPU DSA tag.
 		 */
 		dsa_header = skb->data + 2 * ETH_ALEN;
-		dsa_header[0] = 0x40 | p->dp->ds->index;
-		dsa_header[1] = p->dp->index << 3;
+		dsa_header[0] = 0x40 | dp->ds->index;
+		dsa_header[1] = dp->index << 3;
 		dsa_header[2] = 0x00;
 		dsa_header[3] = 0x00;
 	}
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 0b83cbe0c9e8..c683e240bafc 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -19,7 +19,7 @@
 
 static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	u8 *edsa_header;
 
 	/*
@@ -43,8 +43,8 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		edsa_header[1] = ETH_P_EDSA & 0xff;
 		edsa_header[2] = 0x00;
 		edsa_header[3] = 0x00;
-		edsa_header[4] = 0x60 | p->dp->ds->index;
-		edsa_header[5] = p->dp->index << 3;
+		edsa_header[4] = 0x60 | dp->ds->index;
+		edsa_header[5] = dp->index << 3;
 
 		/*
 		 * Move CFI field from byte 6 to byte 5.
@@ -68,8 +68,8 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		edsa_header[1] = ETH_P_EDSA & 0xff;
 		edsa_header[2] = 0x00;
 		edsa_header[3] = 0x00;
-		edsa_header[4] = 0x40 | p->dp->ds->index;
-		edsa_header[5] = p->dp->index << 3;
+		edsa_header[4] = 0x40 | dp->ds->index;
+		edsa_header[5] = dp->index << 3;
 		edsa_header[6] = 0x00;
 		edsa_header[7] = 0x00;
 	}
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index b241c990cde0..66e443fd7675 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -34,7 +34,7 @@
 
 static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	struct sk_buff *nskb;
 	int padlen;
 	u8 *tag;
@@ -72,7 +72,7 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tag = skb_put(nskb, KSZ_INGRESS_TAG_LEN);
 	tag[0] = 0;
-	tag[1] = 1 << p->dp->index; /* destination port */
+	tag[1] = 1 << dp->index; /* destination port */
 
 	return nskb;
 }
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 4f211e56c81f..c709adb5efd9 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -42,7 +42,7 @@
 
 static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	u16 *lan9303_tag;
 
 	/* insert a special VLAN tag between the MAC addresses
@@ -62,7 +62,7 @@ static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	lan9303_tag = (u16 *)(skb->data + 2 * ETH_ALEN);
 	lan9303_tag[0] = htons(ETH_P_8021Q);
-	lan9303_tag[1] = htons(p->dp->index | BIT(4));
+	lan9303_tag[1] = htons(dp->index | BIT(4));
 
 	return skb;
 }
diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index 968586c5d40e..5abebbfd7060 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -23,7 +23,7 @@
 static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
 				    struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	u8 *mtk_tag;
 
 	if (skb_cow_head(skb, MTK_HDR_LEN) < 0)
@@ -36,7 +36,7 @@ static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
 	/* Build the tag after the MAC Source Address */
 	mtk_tag = skb->data + 2 * ETH_ALEN;
 	mtk_tag[0] = 0;
-	mtk_tag[1] = (1 << p->dp->index) & MTK_HDR_XMIT_DP_BIT_MASK;
+	mtk_tag[1] = (1 << dp->index) & MTK_HDR_XMIT_DP_BIT_MASK;
 	mtk_tag[2] = 0;
 	mtk_tag[3] = 0;
 
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 8d33d9ebf910..b0274b6781cb 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -38,7 +38,7 @@
 
 static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	u16 *phdr, hdr;
 
 	dev->stats.tx_packets++;
@@ -54,8 +54,7 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Set the version field, and set destination port information */
 	hdr = QCA_HDR_VERSION << QCA_HDR_XMIT_VERSION_S |
-		QCA_HDR_XMIT_FROM_CPU |
-		BIT(p->dp->index);
+		QCA_HDR_XMIT_FROM_CPU | BIT(dp->index);
 
 	*phdr = htons(hdr);
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 61668be267f5..8b205bb5f521 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -16,7 +16,7 @@
 
 static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = dsa_slave_to_port(dev);
 	struct sk_buff *nskb;
 	int padlen;
 	u8 *trailer;
@@ -48,7 +48,7 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	trailer = skb_put(nskb, 4);
 	trailer[0] = 0x80;
-	trailer[1] = 1 << p->dp->index;
+	trailer[1] = 1 << dp->index;
 	trailer[2] = 0x10;
 	trailer[3] = 0x00;
 
-- 
2.14.2
