From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/7] net: dsa: bcm_sf2: Add support for BCM7278 integrated switch
Date: Fri, 20 Jan 2017 12:36:30 -0800
Message-ID: <20170120203634.2773-4-f.fainelli@gmail.com>
References: <20170120203634.2773-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35421 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753659AbdATUgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 15:36:46 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so7667567pge.2
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 12:36:46 -0800 (PST)
In-Reply-To: <20170120203634.2773-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the integrated switch found on BCM7278:

- core_reg_align is set to 1, to force a translation into the target
  address space which is 8 bytes aligned
- an alternate SWITCH_REG layout is provided since registers are largely
  bit/masks compatible but have different offsets
- conditional for all CORE_STS_OVERRIDE_{IMP,GMII_P} since those got
  moved way out of the traditional register space

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 .../bindings/net/brcm,bcm7445-switch-v4.0.txt      |  2 +-
 drivers/net/dsa/b53/b53_common.c                   | 12 +++++
 drivers/net/dsa/b53/b53_priv.h                     |  4 +-
 drivers/net/dsa/bcm_sf2.c                          | 56 ++++++++++++++++++----
 drivers/net/dsa/bcm_sf2_regs.h                     |  4 ++
 5 files changed, 68 insertions(+), 10 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt b/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt
index fb40891ee606..e1b2c3e32859 100644
--- a/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt
+++ b/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt
@@ -2,7 +2,7 @@
 
 Required properties:
 
-- compatible: should be "brcm,bcm7445-switch-v4.0"
+- compatible: should be "brcm,bcm7445-switch-v4.0" or "brcm,bcm7278-switch-v4.0"
 - reg: addresses and length of the register sets for the device, must be 6
   pairs of register addresses and lengths
 - interrupts: interrupts for the devices, must be two interrupts
diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 5102a3701a1a..5cbb14f6a03b 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1685,6 +1685,18 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
 	},
+	{
+		.chip_id = BCM7278_DEVICE_ID,
+		.dev_name = "BCM7278",
+		.vlans = 4096,
+		.enabled_ports = 0x1ff,
+		.arl_entries= 4,
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
 };
 
 static int b53_switch_init(struct b53_device *dev)
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 86f125d55aaf..a8031b382c55 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -62,6 +62,7 @@ enum {
 	BCM53019_DEVICE_ID = 0x53019,
 	BCM58XX_DEVICE_ID = 0x5800,
 	BCM7445_DEVICE_ID = 0x7445,
+	BCM7278_DEVICE_ID = 0x7278,
 };
 
 #define B53_N_PORTS	9
@@ -179,7 +180,8 @@ static inline int is5301x(struct b53_device *dev)
 static inline int is58xx(struct b53_device *dev)
 {
 	return dev->chip_id == BCM58XX_DEVICE_ID ||
-		dev->chip_id == BCM7445_DEVICE_ID;
+		dev->chip_id == BCM7445_DEVICE_ID ||
+		dev->chip_id == BCM7278_DEVICE_ID;
 }
 
 #define B53_CPU_PORT_25	5
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index d952099afc60..02afa0598b24 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -64,7 +64,12 @@ static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	u32 reg, val;
+	u32 reg, val, offset;
+
+	if (priv->type == BCM7445_DEVICE_ID)
+		offset = CORE_STS_OVERRIDE_IMP;
+	else
+		offset = CORE_STS_OVERRIDE_IMP2;
 
 	/* Enable the port memories */
 	reg = core_readl(priv, CORE_MEM_PSM_VDD_CTRL);
@@ -121,9 +126,9 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 	core_writel(priv, reg, CORE_BRCM_HDR_TX_DIS);
 
 	/* Force link status for IMP port */
-	reg = core_readl(priv, CORE_STS_OVERRIDE_IMP);
+	reg = core_readl(priv, offset);
 	reg |= (MII_SW_OR | LINK_STS);
-	core_writel(priv, reg, CORE_STS_OVERRIDE_IMP);
+	core_writel(priv, reg, offset);
 }
 
 static void bcm_sf2_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
@@ -591,7 +596,12 @@ static void bcm_sf2_sw_adjust_link(struct dsa_switch *ds, int port,
 	struct ethtool_eee *p = &priv->port_sts[port].eee;
 	u32 id_mode_dis = 0, port_mode;
 	const char *str = NULL;
-	u32 reg;
+	u32 reg, offset;
+
+	if (priv->type == BCM7445_DEVICE_ID)
+		offset = CORE_STS_OVERRIDE_GMIIP_PORT(port);
+	else
+		offset = CORE_STS_OVERRIDE_GMIIP2_PORT(port);
 
 	switch (phydev->interface) {
 	case PHY_INTERFACE_MODE_RGMII:
@@ -662,7 +672,7 @@ static void bcm_sf2_sw_adjust_link(struct dsa_switch *ds, int port,
 	if (phydev->duplex == DUPLEX_FULL)
 		reg |= DUPLX_MODE;
 
-	core_writel(priv, reg, CORE_STS_OVERRIDE_GMIIP_PORT(port));
+	core_writel(priv, reg, offset);
 
 	if (!phydev->is_pseudo_fixed_link)
 		p->eee_enabled = bcm_sf2_eee_init(ds, port, phydev);
@@ -672,9 +682,14 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 					 struct fixed_phy_status *status)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	u32 duplex, pause;
+	u32 duplex, pause, offset;
 	u32 reg;
 
+	if (priv->type == BCM7445_DEVICE_ID)
+		offset = CORE_STS_OVERRIDE_GMIIP_PORT(port);
+	else
+		offset = CORE_STS_OVERRIDE_GMIIP2_PORT(port);
+
 	duplex = core_readl(priv, CORE_DUPSTS);
 	pause = core_readl(priv, CORE_PAUSESTS);
 
@@ -703,13 +718,13 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 		status->duplex = !!(duplex & (1 << port));
 	}
 
-	reg = core_readl(priv, CORE_STS_OVERRIDE_GMIIP_PORT(port));
+	reg = core_readl(priv, offset);
 	reg |= SW_OVERRIDE;
 	if (status->link)
 		reg |= LINK_STS;
 	else
 		reg &= ~LINK_STS;
-	core_writel(priv, reg, CORE_STS_OVERRIDE_GMIIP_PORT(port));
+	core_writel(priv, reg, offset);
 
 	if ((pause & (1 << port)) &&
 	    (pause & (1 << (port + PAUSESTS_TX_PAUSE_SHIFT)))) {
@@ -1038,10 +1053,35 @@ static const struct bcm_sf2_of_data bcm_sf2_7445_data = {
 	.reg_offsets	= bcm_sf2_7445_reg_offsets,
 };
 
+static const u16 bcm_sf2_7278_reg_offsets[] = {
+	[REG_SWITCH_CNTRL]	= 0x00,
+	[REG_SWITCH_STATUS]	= 0x04,
+	[REG_DIR_DATA_WRITE]	= 0x08,
+	[REG_DIR_DATA_READ]	= 0x0c,
+	[REG_SWITCH_REVISION]	= 0x10,
+	[REG_PHY_REVISION]	= 0x14,
+	[REG_SPHY_CNTRL]	= 0x24,
+	[REG_RGMII_0_CNTRL]	= 0xe0,
+	[REG_RGMII_1_CNTRL]	= 0xec,
+	[REG_RGMII_2_CNTRL]	= 0xf8,
+	[REG_LED_0_CNTRL]	= 0x40,
+	[REG_LED_1_CNTRL]	= 0x4c,
+	[REG_LED_2_CNTRL]	= 0x58,
+};
+
+static const struct bcm_sf2_of_data bcm_sf2_7278_data = {
+	.type		= BCM7278_DEVICE_ID,
+	.core_reg_align	= 1,
+	.reg_offsets	= bcm_sf2_7278_reg_offsets,
+};
+
 static const struct of_device_id bcm_sf2_of_match[] = {
 	{ .compatible = "brcm,bcm7445-switch-v4.0",
 	  .data = &bcm_sf2_7445_data
 	},
+	{ .compatible = "brcm,bcm7278-switch-v4.0",
+	  .data = &bcm_sf2_7278_data
+	},
 	{ /* sentinel */ },
 };
 MODULE_DEVICE_TABLE(of, bcm_sf2_of_match);
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index f5e566304f0c..3b33b8010cc8 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -134,6 +134,9 @@ enum bcm_sf2_reg_offs {
 #define  GMII_SPEED_UP_2G		(1 << 6)
 #define  MII_SW_OR			(1 << 7)
 
+/* Alternate layout for e.g: 7278 */
+#define CORE_STS_OVERRIDE_IMP2		0x39040
+
 #define CORE_NEW_CTRL			0x00084
 #define  IP_MC				(1 << 0)
 #define  OUTRANGEERR_DISCARD		(1 << 1)
@@ -151,6 +154,7 @@ enum bcm_sf2_reg_offs {
 #define  SW_LEARN_CNTL(x)		(1 << (x))
 
 #define CORE_STS_OVERRIDE_GMIIP_PORT(x)	(0x160 + (x) * 4)
+#define CORE_STS_OVERRIDE_GMIIP2_PORT(x) (0x39000 + (x) * 8)
 #define  LINK_STS			(1 << 0)
 #define  DUPLX_MODE			(1 << 1)
 #define  SPEED_SHIFT			2
-- 
2.9.3
