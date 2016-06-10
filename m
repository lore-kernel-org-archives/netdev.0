From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/5] net: dsa: b53: Plug in VLAN support
Date: Thu,  9 Jun 2016 18:23:57 -0700
Message-ID: <1465521837-30193-6-git-send-email-f.fainelli@gmail.com>
References: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
	jon.mason@broadcom.com, hemal.shah@broadcom.com,
	bandaru.viswanath@broadcom.com, michael.chan@broadcom.com,
	jogo@openwrt.org, cphealy@gmail.com, ardeleanalex@gmail.com,
	jiri@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33646 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbcFJBYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 21:24:12 -0400
Received: by mail-pf0-f193.google.com with SMTP id c74so3875765pfb.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 18:24:12 -0700 (PDT)
In-Reply-To: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for configuration VLANs on B53 devices by implementing the
port VLAN add/del/dump functions. We currently default to a behavior
which is equivalent to having VLAN filtering turned on, where all VLANs
not programmed into the VLAN port-based vector will be discarded on
ingress.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 256 +++++++++++++++++++++++++++++++++++----
 drivers/net/dsa/b53/b53_priv.h   |  13 +-
 2 files changed, 243 insertions(+), 26 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index ad1d68272016..5321083379c7 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -186,15 +186,15 @@ static int b53_do_vlan_op(struct b53_device *dev, u8 op)
 	return -EIO;
 }
 
-static void b53_set_vlan_entry(struct b53_device *dev, u16 vid, u16 members,
-			       u16 untag)
+static void b53_set_vlan_entry(struct b53_device *dev, u16 vid,
+			       struct b53_vlan *vlan)
 {
 	if (is5325(dev)) {
 		u32 entry = 0;
 
-		if (members) {
-			entry = ((untag & VA_UNTAG_MASK_25) << VA_UNTAG_S_25) |
-				members;
+		if (vlan->members) {
+			entry = ((vlan->untag & VA_UNTAG_MASK_25) <<
+				 VA_UNTAG_S_25) | vlan->members;
 			if (dev->core_rev >= 3)
 				entry |= VA_VALID_25_R4 | vid << VA_VID_HIGH_S;
 			else
@@ -207,9 +207,9 @@ static void b53_set_vlan_entry(struct b53_device *dev, u16 vid, u16 members,
 	} else if (is5365(dev)) {
 		u16 entry = 0;
 
-		if (members)
-			entry = ((untag & VA_UNTAG_MASK_65) << VA_UNTAG_S_65) |
-				members | VA_VALID_65;
+		if (vlan->members)
+			entry = ((vlan->untag & VA_UNTAG_MASK_65) <<
+				 VA_UNTAG_S_65) | vlan->members | VA_VALID_65;
 
 		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_WRITE_65, entry);
 		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_TABLE_ACCESS_65, vid |
@@ -217,13 +217,55 @@ static void b53_set_vlan_entry(struct b53_device *dev, u16 vid, u16 members,
 	} else {
 		b53_write16(dev, B53_ARLIO_PAGE, dev->vta_regs[1], vid);
 		b53_write32(dev, B53_ARLIO_PAGE, dev->vta_regs[2],
-			    (untag << VTE_UNTAG_S) | members);
+			    (vlan->untag << VTE_UNTAG_S) | vlan->members);
 
 		b53_do_vlan_op(dev, VTA_CMD_WRITE);
 	}
+
+	dev_dbg(dev->ds->dev, "VID: %d, members: 0x%04x, untag: 0x%04x\n",
+		vid, vlan->members, vlan->untag);
+}
+
+static void b53_get_vlan_entry(struct b53_device *dev, u16 vid,
+			       struct b53_vlan *vlan)
+{
+	if (is5325(dev)) {
+		u32 entry = 0;
+
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_TABLE_ACCESS_25, vid |
+			    VTA_RW_STATE_RD | VTA_RW_OP_EN);
+		b53_read32(dev, B53_VLAN_PAGE, B53_VLAN_WRITE_25, &entry);
+
+		if (dev->core_rev >= 3)
+			vlan->valid = !!(entry & VA_VALID_25_R4);
+		else
+			vlan->valid = !!(entry & VA_VALID_25);
+		vlan->members = entry & VA_MEMBER_MASK;
+		vlan->untag = (entry >> VA_UNTAG_S_25) & VA_UNTAG_MASK_25;
+
+	} else if (is5365(dev)) {
+		u16 entry = 0;
+
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_TABLE_ACCESS_65, vid |
+			    VTA_RW_STATE_WR | VTA_RW_OP_EN);
+		b53_read16(dev, B53_VLAN_PAGE, B53_VLAN_WRITE_65, &entry);
+
+		vlan->valid = !!(entry & VA_VALID_65);
+		vlan->members = entry & VA_MEMBER_MASK;
+		vlan->untag = (entry >> VA_UNTAG_S_65) & VA_UNTAG_MASK_65;
+	} else {
+		u32 entry = 0;
+
+		b53_write16(dev, B53_ARLIO_PAGE, dev->vta_regs[1], vid);
+		b53_do_vlan_op(dev, VTA_CMD_READ);
+		b53_read32(dev, B53_ARLIO_PAGE, dev->vta_regs[2], &entry);
+		vlan->members = entry & VTE_MEMBERS;
+		vlan->untag = (entry >> VTE_UNTAG_S) & VTE_MEMBERS;
+		vlan->valid = true;
+	}
 }
 
-void b53_set_forwarding(struct b53_device *dev, int enable)
+static void b53_set_forwarding(struct b53_device *dev, int enable)
 {
 	u8 mgmt;
 
@@ -237,7 +279,7 @@ void b53_set_forwarding(struct b53_device *dev, int enable)
 	b53_write8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, mgmt);
 }
 
-static void b53_enable_vlan(struct b53_device *dev, int enable)
+static void b53_enable_vlan(struct b53_device *dev, bool enable)
 {
 	u8 mgmt, vc0, vc1, vc4 = 0, vc5;
 
@@ -271,12 +313,6 @@ static void b53_enable_vlan(struct b53_device *dev, int enable)
 		if (is5325(dev) || is5365(dev))
 			vc1 |= VC1_RX_MCST_TAG_EN;
 
-		if (!is5325(dev) && !is5365(dev)) {
-			if (dev->allow_vid_4095)
-				vc5 |= VC5_VID_FFF_EN;
-			else
-				vc5 &= ~VC5_VID_FFF_EN;
-		}
 	} else {
 		vc0 &= ~(VC0_VLAN_EN | VC0_VID_CHK_EN | VC0_VID_HASH_VID);
 		vc1 &= ~(VC1_RX_MCST_UNTAG_EN | VC1_RX_MCST_FWD_EN);
@@ -290,11 +326,11 @@ static void b53_enable_vlan(struct b53_device *dev, int enable)
 
 		if (is5325(dev) || is5365(dev))
 			vc1 &= ~VC1_RX_MCST_TAG_EN;
-
-		if (!is5325(dev) && !is5365(dev))
-			vc5 &= ~VC5_VID_FFF_EN;
 	}
 
+	if (!is5325(dev) && !is5365(dev))
+		vc5 &= ~VC5_VID_FFF_EN;
+
 	b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL0, vc0);
 	b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL1, vc1);
 
@@ -373,6 +409,13 @@ static int b53_fast_age_port(struct b53_device *dev, int port)
 	return b53_flush_arl(dev, FAST_AGE_PORT);
 }
 
+static int b53_fast_age_vlan(struct b53_device *dev, u16 vid)
+{
+	b53_write16(dev, B53_CTRL_PAGE, B53_FAST_AGE_VID_CTRL, vid);
+
+	return b53_flush_arl(dev, FAST_AGE_VLAN);
+}
+
 static void b53_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 {
 	struct b53_device *dev = ds_to_priv(ds);
@@ -453,12 +496,13 @@ static void b53_enable_mib(struct b53_device *dev)
 
 static int b53_configure_vlan(struct b53_device *dev)
 {
+	struct b53_vlan vl = { 0 };
 	int i;
 
 	/* clear all vlan entries */
 	if (is5325(dev) || is5365(dev)) {
 		for (i = 1; i < dev->num_vlans; i++)
-			b53_set_vlan_entry(dev, i, 0, 0);
+			b53_set_vlan_entry(dev, i, &vl);
 	} else {
 		b53_do_vlan_op(dev, VTA_CMD_CLEAR);
 	}
@@ -554,6 +598,7 @@ static int b53_reset_switch(struct b53_device *priv)
 	/* reset vlans */
 	priv->enable_jumbo = false;
 
+	memset(priv->vlans, 0, sizeof(*priv->vlans) * priv->num_vlans);
 	memset(priv->ports, 0, sizeof(*priv->ports) * priv->num_ports);
 
 	return b53_switch_reset(priv);
@@ -818,6 +863,151 @@ static void b53_adjust_link(struct dsa_switch *ds, int port,
 	}
 }
 
+static int b53_vlan_filtering(struct dsa_switch *ds, int port,
+			      bool vlan_filtering)
+{
+	return 0;
+}
+
+static int b53_vlan_prepare(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_vlan *vlan,
+			    struct switchdev_trans *trans)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+
+	if ((is5325(dev) || is5365(dev)) && vlan->vid_begin == 0)
+		return -EOPNOTSUPP;
+
+	if (vlan->vid_end > dev->num_vlans)
+		return -ERANGE;
+
+	b53_enable_vlan(dev, true);
+
+	return 0;
+}
+
+static void b53_vlan_add(struct dsa_switch *ds, int port,
+			 const struct switchdev_obj_port_vlan *vlan,
+			 struct switchdev_trans *trans)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
+	unsigned int cpu_port = dev->cpu_port;
+	struct b53_vlan *vl;
+	u16 vid;
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		vl = &dev->vlans[vid];
+
+		b53_get_vlan_entry(dev, vid, vl);
+
+		vl->members |= BIT(port) | BIT(cpu_port);
+		if (untagged)
+			vl->untag |= BIT(port) | BIT(cpu_port);
+		else
+			vl->untag &= ~(BIT(port) | BIT(cpu_port));
+
+		b53_set_vlan_entry(dev, vid, vl);
+		b53_fast_age_vlan(dev, vid);
+	}
+
+	if (pvid) {
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(port),
+			    vlan->vid_end);
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(cpu_port),
+			    vlan->vid_end);
+		b53_fast_age_vlan(dev, vid);
+	}
+}
+
+static int b53_vlan_del(struct dsa_switch *ds, int port,
+			const struct switchdev_obj_port_vlan *vlan)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	unsigned int cpu_port = dev->cpu_port;
+	struct b53_vlan *vl;
+	u16 vid;
+	u16 pvid;
+
+	b53_read16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(port), &pvid);
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
+		vl = &dev->vlans[vid];
+
+		b53_get_vlan_entry(dev, vid, vl);
+
+		vl->members &= ~BIT(port);
+		if ((vl->members & BIT(cpu_port)) == BIT(cpu_port))
+			vl->members = 0;
+
+		if (pvid == vid) {
+			if (is5325(dev) || is5365(dev))
+				pvid = 1;
+			else
+				pvid = 0;
+		}
+
+		if (untagged) {
+			vl->untag &= ~(BIT(port));
+			if ((vl->untag & BIT(cpu_port)) == BIT(cpu_port))
+				vl->untag = 0;
+		}
+
+		b53_set_vlan_entry(dev, vid, vl);
+		b53_fast_age_vlan(dev, vid);
+	}
+
+	b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(port), pvid);
+	b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(cpu_port), pvid);
+	b53_fast_age_vlan(dev, pvid);
+
+	return 0;
+}
+
+static int b53_vlan_dump(struct dsa_switch *ds, int port,
+			 struct switchdev_obj_port_vlan *vlan,
+			 int (*cb)(struct switchdev_obj *obj))
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	u16 vid, vid_start = 0, pvid;
+	struct b53_vlan *vl;
+	int err = 0;
+
+	if (is5325(dev) || is5365(dev))
+		vid_start = 1;
+
+	b53_read16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(port), &pvid);
+
+	/* Use our software cache for dumps, since we do not have any HW
+	 * operation returning only the used/valid VLANs
+	 */
+	for (vid = vid_start; vid < dev->num_vlans; vid++) {
+		vl = &dev->vlans[vid];
+
+		if (!vl->valid)
+			continue;
+
+		if (!(vl->members & BIT(port)))
+			continue;
+
+		vlan->vid_begin = vlan->vid_end = vid;
+		vlan->flags = 0;
+
+		if (vl->untag & BIT(port))
+			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+		if (pvid == vid)
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
 /* Address Resolution Logic routines */
 static int b53_arl_op_wait(struct b53_device *dev)
 {
@@ -1096,8 +1286,9 @@ static void b53_br_leave(struct dsa_switch *ds, int port)
 {
 	struct b53_device *dev = ds_to_priv(ds);
 	struct net_device *bridge = dev->ports[port].bridge_dev;
+	struct b53_vlan *vl = &dev->vlans[0];
 	unsigned int i;
-	u16 pvlan, reg;
+	u16 pvlan, reg, pvid;
 
 	b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), &pvlan);
 
@@ -1119,6 +1310,16 @@ static void b53_br_leave(struct dsa_switch *ds, int port)
 	b53_write16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), pvlan);
 	dev->ports[port].vlan_ctl_mask = pvlan;
 	dev->ports[port].bridge_dev = NULL;
+
+	if (is5325(dev) || is5365(dev))
+		pvid = 1;
+	else
+		pvid = 0;
+
+	b53_get_vlan_entry(dev, pvid, vl);
+	vl->members |= BIT(port) | BIT(dev->cpu_port);
+	vl->untag |= BIT(port) | BIT(dev->cpu_port);
+	b53_set_vlan_entry(dev, pvid, vl);
 }
 
 static void b53_br_set_stp_state(struct dsa_switch *ds, int port,
@@ -1187,6 +1388,11 @@ static struct dsa_switch_driver b53_switch_ops = {
 	.port_bridge_join	= b53_br_join,
 	.port_bridge_leave	= b53_br_leave,
 	.port_stp_state_set	= b53_br_set_stp_state,
+	.port_vlan_filtering	= b53_vlan_filtering,
+	.port_vlan_prepare	= b53_vlan_prepare,
+	.port_vlan_add		= b53_vlan_add,
+	.port_vlan_del		= b53_vlan_del,
+	.port_vlan_dump		= b53_vlan_dump,
 	.port_fdb_prepare	= b53_fdb_prepare,
 	.port_fdb_dump		= b53_fdb_dump,
 	.port_fdb_add		= b53_fdb_add,
@@ -1446,6 +1652,12 @@ static int b53_switch_init(struct b53_device *dev)
 	if (!dev->ports)
 		return -ENOMEM;
 
+	dev->vlans = devm_kzalloc(dev->dev,
+				  sizeof(struct b53_vlan) * dev->num_vlans,
+				  GFP_KERNEL);
+	if (!dev->vlans)
+		return -ENOMEM;
+
 	dev->reset_gpio = b53_switch_get_reset_gpio(dev);
 	if (dev->reset_gpio >= 0) {
 		ret = devm_gpio_request_one(dev->dev, dev->reset_gpio,
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index c19842960f28..5d8c602fb877 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -69,6 +69,12 @@ struct b53_port {
 	struct net_device *bridge_dev;
 };
 
+struct b53_vlan {
+	u16 members;
+	u16 untag;
+	bool valid;
+};
+
 struct b53_device {
 	struct dsa_switch *ds;
 	struct b53_platform_data *pdata;
@@ -99,14 +105,13 @@ struct b53_device {
 	/* Master MDIO bus we got probed from */
 	struct mii_bus *bus;
 
-	/* Slave MDIO bus we created */
-	struct mii_bus *slave_bus;
 	void *priv;
 
 	/* run time configuration */
-	unsigned enable_jumbo:1;
-	unsigned allow_vid_4095:1;
+	bool enable_jumbo;
+
 	unsigned int num_vlans;
+	struct b53_vlan *vlans;
 	unsigned int num_ports;
 	struct b53_port *ports;
 };
-- 
2.7.4
