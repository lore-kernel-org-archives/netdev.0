From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] net: dsa: bcm_sf2: Add VLAN support
Date: Thu,  9 Jun 2016 17:42:08 -0700
Message-ID: <1465519328-14249-5-git-send-email-f.fainelli@gmail.com>
References: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
	idosch@mellanox.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35891 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbcFJAmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 20:42:45 -0400
Received: by mail-pf0-f195.google.com with SMTP id 62so3818938pfd.3
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 17:42:44 -0700 (PDT)
In-Reply-To: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for configuring VLANs on the Broadcom Starfigther2 switch.
This is all done through the bridge vlan facility just like other DSA
drivers.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 266 +++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/bcm_sf2.h |  10 ++
 2 files changed, 275 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index d726f5906ef9..cd1d630ae3a9 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -467,7 +467,7 @@ static int bcm_sf2_fast_age_op(struct bcm_sf2_priv *priv)
 	u32 reg;
 
 	reg = core_readl(priv, CORE_FAST_AGE_CTRL);
-	reg |= EN_AGE_PORT | EN_AGE_DYNAMIC | FAST_AGE_STR_DONE;
+	reg |= EN_AGE_PORT | EN_AGE_VLAN | EN_AGE_DYNAMIC | FAST_AGE_STR_DONE;
 	core_writel(priv, reg, CORE_FAST_AGE_CTRL);
 
 	do {
@@ -498,13 +498,86 @@ static int bcm_sf2_sw_fast_age_port(struct dsa_switch *ds, int port)
 	return bcm_sf2_fast_age_op(priv);
 }
 
+static int bcm_sf2_sw_fast_age_vlan(struct bcm_sf2_priv *priv, u16 vid)
+{
+	core_writel(priv, vid, CORE_FAST_AGE_VID);
+
+	return bcm_sf2_fast_age_op(priv);
+}
+
+static int bcm_sf2_vlan_op_wait(struct bcm_sf2_priv *priv)
+{
+	unsigned int timeout = 10;
+	u32 reg;
+
+	do {
+		reg = core_readl(priv, CORE_ARLA_VTBL_RWCTRL);
+		if (!(reg & ARLA_VTBL_STDN))
+			return 0;
+
+		usleep_range(1000, 2000);
+	} while (timeout--);
+
+	return -ETIMEDOUT;
+}
+
+static int bcm_sf2_vlan_op(struct bcm_sf2_priv *priv, u8 op)
+{
+	core_writel(priv, ARLA_VTBL_STDN | op, CORE_ARLA_VTBL_RWCTRL);
+
+	return bcm_sf2_vlan_op_wait(priv);
+}
+
+static void bcm_sf2_set_vlan_entry(struct bcm_sf2_priv *priv, u16 vid,
+				   struct bcm_sf2_vlan *vlan)
+{
+	int ret;
+
+	core_writel(priv, vid & VTBL_ADDR_INDEX_MASK, CORE_ARLA_VTBL_ADDR);
+	core_writel(priv, vlan->untag << UNTAG_MAP_SHIFT | vlan->members,
+		    CORE_ARLA_VTBL_ENTRY);
+
+	ret = bcm_sf2_vlan_op(priv, ARLA_VTBL_CMD_WRITE);
+	if (ret)
+		pr_err("failed to write VLAN entry\n");
+}
+
+static int bcm_sf2_get_vlan_entry(struct bcm_sf2_priv *priv, u16 vid,
+				  struct bcm_sf2_vlan *vlan)
+{
+	u32 entry;
+	int ret;
+
+	core_writel(priv, vid & VTBL_ADDR_INDEX_MASK, CORE_ARLA_VTBL_ADDR);
+
+	ret = bcm_sf2_vlan_op(priv, ARLA_VTBL_CMD_READ);
+	if (ret)
+		return ret;
+
+	entry = core_readl(priv, CORE_ARLA_VTBL_ENTRY);
+	vlan->members = entry & FWD_MAP_MASK;
+	vlan->untag = (entry >> UNTAG_MAP_SHIFT) & UNTAG_MAP_MASK;
+
+	return 0;
+}
+
 static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
 			      struct net_device *bridge)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	s8 cpu_port = ds->dst->cpu_port;
 	unsigned int i;
 	u32 reg, p_ctl;
 
+	/* Make this port leave the all VLANs join since we will have proper
+	 * VLAN entries from now on
+	 */
+	reg = core_readl(priv, CORE_JOIN_ALL_VLAN_EN);
+	reg &= ~BIT(port);
+	if ((reg & BIT(cpu_port)) == BIT(cpu_port))
+		reg &= ~BIT(cpu_port);
+	core_writel(priv, reg, CORE_JOIN_ALL_VLAN_EN);
+
 	priv->port_sts[port].bridge_dev = bridge;
 	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
 
@@ -536,6 +609,7 @@ static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	struct net_device *bridge = priv->port_sts[port].bridge_dev;
+	s8 cpu_port = ds->dst->cpu_port;
 	unsigned int i;
 	u32 reg, p_ctl;
 
@@ -559,6 +633,13 @@ static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port)
 	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(port));
 	priv->port_sts[port].vlan_ctl_mask = p_ctl;
 	priv->port_sts[port].bridge_dev = NULL;
+
+	/* Make this port join all VLANs without VLAN entries */
+	reg = core_readl(priv, CORE_JOIN_ALL_VLAN_EN);
+	reg |= BIT(port);
+	if (!(reg & BIT(cpu_port)))
+		reg |= BIT(cpu_port);
+	core_writel(priv, reg, CORE_JOIN_ALL_VLAN_EN);
 }
 
 static void bcm_sf2_sw_br_set_stp_state(struct dsa_switch *ds, int port,
@@ -1312,6 +1393,182 @@ static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 	return p->ethtool_ops->set_wol(p, wol);
 }
 
+static void bcm_sf2_enable_vlan(struct bcm_sf2_priv *priv, bool enable)
+{
+	u32 mgmt, vc0, vc1, vc4, vc5;
+
+	mgmt = core_readl(priv, CORE_SWMODE);
+	vc0 = core_readl(priv, CORE_VLAN_CTRL0);
+	vc1 = core_readl(priv, CORE_VLAN_CTRL1);
+	vc4 = core_readl(priv, CORE_VLAN_CTRL4);
+	vc5 = core_readl(priv, CORE_VLAN_CTRL5);
+
+	mgmt &= ~SW_FWDG_MODE;
+
+	if (enable) {
+		vc0 |= VLAN_EN | VLAN_LEARN_MODE_IVL;
+		vc1 |= EN_RSV_MCAST_UNTAG | EN_RSV_MCAST_FWDMAP;
+		vc4 &= ~(INGR_VID_CHK_MASK << INGR_VID_CHK_SHIFT);
+		vc4 |= INGR_VID_CHK_DROP;
+		vc5 |= DROP_VTABLE_MISS | EN_VID_FFF_FWD;
+	} else {
+		vc0 &= ~(VLAN_EN | VLAN_LEARN_MODE_IVL);
+		vc1 &= ~(EN_RSV_MCAST_UNTAG | EN_RSV_MCAST_FWDMAP);
+		vc4 &= ~(INGR_VID_CHK_MASK << INGR_VID_CHK_SHIFT);
+		vc5 &= ~(DROP_VTABLE_MISS | EN_VID_FFF_FWD);
+		vc4 |= INGR_VID_CHK_VID_VIOL_IMP;
+	}
+
+	core_writel(priv, vc0, CORE_VLAN_CTRL0);
+	core_writel(priv, vc1, CORE_VLAN_CTRL1);
+	core_writel(priv, 0, CORE_VLAN_CTRL3);
+	core_writel(priv, vc4, CORE_VLAN_CTRL4);
+	core_writel(priv, vc5, CORE_VLAN_CTRL5);
+	core_writel(priv, mgmt, CORE_SWMODE);
+}
+
+static void bcm_sf2_sw_configure_vlan(struct dsa_switch *ds)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	unsigned int port;
+
+	/* Clear all VLANs */
+	bcm_sf2_vlan_op(priv, ARLA_VTBL_CMD_CLEAR);
+
+	for (port = 0; port < priv->hw_params.num_ports; port++) {
+		if (!((1 << port) & ds->enabled_port_mask))
+			continue;
+
+		core_writel(priv, 1, CORE_DEFAULT_1Q_TAG_P(port));
+	}
+}
+
+static int bcm_sf2_sw_vlan_filtering(struct dsa_switch *ds, int port,
+				     bool vlan_filtering)
+{
+	return 0;
+}
+
+static int bcm_sf2_sw_vlan_prepare(struct dsa_switch *ds, int port,
+				   const struct switchdev_obj_port_vlan *vlan,
+				   struct switchdev_trans *trans)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+
+	bcm_sf2_enable_vlan(priv, true);
+
+	return 0;
+}
+
+static void bcm_sf2_sw_vlan_add(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_port_vlan *vlan,
+				struct switchdev_trans *trans)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
+	s8 cpu_port = ds->dst->cpu_port;
+	struct bcm_sf2_vlan *vl;
+	u16 vid;
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		vl = &priv->vlans[vid];
+
+		bcm_sf2_get_vlan_entry(priv, vid, vl);
+
+		vl->members |= BIT(port) | BIT(cpu_port);
+		if (untagged)
+			vl->untag |= BIT(port) | BIT(cpu_port);
+		else
+			vl->untag &= ~(BIT(port) | BIT(cpu_port));
+
+		bcm_sf2_set_vlan_entry(priv, vid, vl);
+		bcm_sf2_sw_fast_age_vlan(priv, vid);
+	}
+
+	if (pvid) {
+		core_writel(priv, vlan->vid_end, CORE_DEFAULT_1Q_TAG_P(port));
+		core_writel(priv, vlan->vid_end,
+			    CORE_DEFAULT_1Q_TAG_P(cpu_port));
+		bcm_sf2_sw_fast_age_vlan(priv, vid);
+	}
+}
+
+static int bcm_sf2_sw_vlan_del(struct dsa_switch *ds, int port,
+			       const struct switchdev_obj_port_vlan *vlan)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	s8 cpu_port = ds->dst->cpu_port;
+	struct bcm_sf2_vlan *vl;
+	u16 vid, pvid;
+	int ret;
+
+	pvid = core_readl(priv, CORE_DEFAULT_1Q_TAG_P(port));
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		vl = &priv->vlans[vid];
+
+		ret = bcm_sf2_get_vlan_entry(priv, vid, vl);
+		if (ret)
+			return ret;
+
+		vl->members &= ~BIT(port);
+		if ((vl->members & BIT(cpu_port)) == BIT(cpu_port))
+			vl->members = 0;
+		if (pvid == vid)
+			pvid = 0;
+		if (untagged) {
+			vl->untag &= ~BIT(port);
+			if ((vl->untag & BIT(port)) == BIT(cpu_port))
+				vl->untag = 0;
+		}
+
+		bcm_sf2_set_vlan_entry(priv, vid, vl);
+		bcm_sf2_sw_fast_age_vlan(priv, vid);
+	}
+
+	core_writel(priv, pvid, CORE_DEFAULT_1Q_TAG_P(port));
+	core_writel(priv, pvid, CORE_DEFAULT_1Q_TAG_P(cpu_port));
+	bcm_sf2_sw_fast_age_vlan(priv, vid);
+
+	return 0;
+}
+
+static int bcm_sf2_sw_vlan_dump(struct dsa_switch *ds, int port,
+				struct switchdev_obj_port_vlan *vlan,
+				int (*cb)(struct switchdev_obj *obj))
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_port_status *p = &priv->port_sts[port];
+	struct bcm_sf2_vlan *vl;
+	u16 vid, pvid;
+	int err = 0;
+
+	pvid = core_readl(priv, CORE_DEFAULT_1Q_TAG_P(port));
+
+	for (vid = 0; vid < VLAN_N_VID; vid++) {
+		vl = &priv->vlans[vid];
+
+		if (!(vl->members & BIT(port)))
+			continue;
+
+		vlan->vid_begin = vlan->vid_end = vid;
+		vlan->flags = 0;
+
+		if (vl->untag & BIT(port))
+			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+		if (p->pvid == vid)
+			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
+
+		err = cb(&vlan->obj);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
 static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 {
 	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
@@ -1403,6 +1660,8 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 			bcm_sf2_port_disable(ds, port, NULL);
 	}
 
+	bcm_sf2_sw_configure_vlan(ds);
+
 	rev = reg_readl(priv, REG_SWITCH_REVISION);
 	priv->hw_params.top_rev = (rev >> SWITCH_TOP_REV_SHIFT) &
 					SWITCH_TOP_REV_MASK;
@@ -1457,6 +1716,11 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.port_fdb_add		= bcm_sf2_sw_fdb_add,
 	.port_fdb_del		= bcm_sf2_sw_fdb_del,
 	.port_fdb_dump		= bcm_sf2_sw_fdb_dump,
+	.port_vlan_filtering	= bcm_sf2_sw_vlan_filtering,
+	.port_vlan_prepare	= bcm_sf2_sw_vlan_prepare,
+	.port_vlan_add		= bcm_sf2_sw_vlan_add,
+	.port_vlan_del		= bcm_sf2_sw_vlan_del,
+	.port_vlan_dump		= bcm_sf2_sw_vlan_dump,
 };
 
 static int __init bcm_sf2_init(void)
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index bde11ebb2742..463bed8cbe4c 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -21,6 +21,7 @@
 #include <linux/ethtool.h>
 #include <linux/types.h>
 #include <linux/bitops.h>
+#include <linux/if_vlan.h>
 
 #include <net/dsa.h>
 
@@ -50,6 +51,7 @@ struct bcm_sf2_port_status {
 	struct ethtool_eee eee;
 
 	u32 vlan_ctl_mask;
+	u16 pvid;
 
 	struct net_device *bridge_dev;
 };
@@ -63,6 +65,11 @@ struct bcm_sf2_arl_entry {
 	u8 is_static:1;
 };
 
+struct bcm_sf2_vlan {
+	u16 members;
+	u16 untag;
+};
+
 static inline void bcm_sf2_mac_from_u64(u64 src, u8 *dst)
 {
 	unsigned int i;
@@ -148,6 +155,9 @@ struct bcm_sf2_priv {
 	struct device_node		*master_mii_dn;
 	struct mii_bus			*slave_mii_bus;
 	struct mii_bus			*master_mii_bus;
+
+	/* Cache of programmed VLANs */
+	struct bcm_sf2_vlan		vlans[VLAN_N_VID];
 };
 
 struct bcm_sf2_hw_stats {
-- 
2.7.4
