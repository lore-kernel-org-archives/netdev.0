From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/7] net: dsa: bcm_sf2: Prepare for different register layouts
Date: Fri, 20 Jan 2017 12:36:29 -0800
Message-ID: <20170120203634.2773-3-f.fainelli@gmail.com>
References: <20170120203634.2773-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35417 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753657AbdATUgp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 15:36:45 -0500
Received: by mail-pg0-f68.google.com with SMTP id 204so7667544pge.2
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 12:36:45 -0800 (PST)
In-Reply-To: <20170120203634.2773-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for supporting a new device with a slightly different
register layout, affecting the SWITCH_REG and SWITCH_CORE address
spaces, perform a few preparatory steps:

- allow matching the compatible string against a data description
- convert the SWITCH_REG register accesses into an indirection table
- prepare for supporting a SWITCH_CORE register alignment requirement

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c      | 57 +++++++++++++++++++++++++++++++++++++-----
 drivers/net/dsa/bcm_sf2.h      | 34 +++++++++++++++++++++++--
 drivers/net/dsa/bcm_sf2_regs.h | 43 ++++++++++++++++++-------------
 3 files changed, 109 insertions(+), 25 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 31d017086f8b..d952099afc60 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1009,10 +1009,49 @@ static const struct dsa_switch_ops bcm_sf2_ops = {
 	.port_fdb_del		= b53_fdb_del,
 };
 
+struct bcm_sf2_of_data {
+	u32 type;
+	const u16 *reg_offsets;
+	unsigned int core_reg_align;
+};
+
+/* Register offsets for the SWITCH_REG_* block */
+static const u16 bcm_sf2_7445_reg_offsets[] = {
+	[REG_SWITCH_CNTRL]	= 0x00,
+	[REG_SWITCH_STATUS]	= 0x04,
+	[REG_DIR_DATA_WRITE]	= 0x08,
+	[REG_DIR_DATA_READ]	= 0x0C,
+	[REG_SWITCH_REVISION]	= 0x18,
+	[REG_PHY_REVISION]	= 0x1C,
+	[REG_SPHY_CNTRL]	= 0x2C,
+	[REG_RGMII_0_CNTRL]	= 0x34,
+	[REG_RGMII_1_CNTRL]	= 0x40,
+	[REG_RGMII_2_CNTRL]	= 0x4c,
+	[REG_LED_0_CNTRL]	= 0x90,
+	[REG_LED_1_CNTRL]	= 0x94,
+	[REG_LED_2_CNTRL]	= 0x98,
+};
+
+static const struct bcm_sf2_of_data bcm_sf2_7445_data = {
+	.type		= BCM7445_DEVICE_ID,
+	.core_reg_align	= 0,
+	.reg_offsets	= bcm_sf2_7445_reg_offsets,
+};
+
+static const struct of_device_id bcm_sf2_of_match[] = {
+	{ .compatible = "brcm,bcm7445-switch-v4.0",
+	  .data = &bcm_sf2_7445_data
+	},
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, bcm_sf2_of_match);
+
 static int bcm_sf2_sw_probe(struct platform_device *pdev)
 {
 	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
 	struct device_node *dn = pdev->dev.of_node;
+	const struct of_device_id *of_id = NULL;
+	const struct bcm_sf2_of_data *data;
 	struct b53_platform_data *pdata;
 	struct dsa_switch_ops *ops;
 	struct bcm_sf2_priv *priv;
@@ -1040,11 +1079,22 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	if (!pdata)
 		return -ENOMEM;
 
+	of_id = of_match_node(bcm_sf2_of_match, dn);
+	if (!of_id || !of_id->data)
+		return -EINVAL;
+
+	data = of_id->data;
+
+	/* Set SWITCH_REG register offsets and SWITCH_CORE align factor */
+	priv->type = data->type;
+	priv->reg_offsets = data->reg_offsets;
+	priv->core_reg_align = data->core_reg_align;
+
 	/* Auto-detection using standard registers will not work, so
 	 * provide an indication of what kind of device we are for
 	 * b53_common to work with
 	 */
-	pdata->chip_id = BCM7445_DEVICE_ID;
+	pdata->chip_id = priv->type;
 	dev->pdata = pdata;
 
 	priv->dev = dev;
@@ -1190,11 +1240,6 @@ static int bcm_sf2_resume(struct device *dev)
 static SIMPLE_DEV_PM_OPS(bcm_sf2_pm_ops,
 			 bcm_sf2_suspend, bcm_sf2_resume);
 
-static const struct of_device_id bcm_sf2_of_match[] = {
-	{ .compatible = "brcm,bcm7445-switch-v4.0" },
-	{ /* sentinel */ },
-};
-MODULE_DEVICE_TABLE(of, bcm_sf2_of_match);
 
 static struct platform_driver bcm_sf2_driver = {
 	.probe	= bcm_sf2_sw_probe,
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 4531c2333e86..a1430866bd79 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -61,6 +61,11 @@ struct bcm_sf2_priv {
 	void __iomem			*fcb;
 	void __iomem			*acb;
 
+	/* Register offsets indirection tables */
+	u32 				type;
+	const u16			*reg_offsets;
+	unsigned int			core_reg_align;
+
 	/* spinlock protecting access to the indirect registers */
 	spinlock_t			indir_lock;
 
@@ -104,6 +109,11 @@ static inline struct bcm_sf2_priv *bcm_sf2_to_priv(struct dsa_switch *ds)
 	return dev->priv;
 }
 
+static inline u32 bcm_sf2_mangle_addr(struct bcm_sf2_priv *priv, u32 off)
+{
+	return off << priv->core_reg_align;
+}
+
 #define SF2_IO_MACRO(name) \
 static inline u32 name##_readl(struct bcm_sf2_priv *priv, u32 off)	\
 {									\
@@ -153,8 +163,28 @@ static inline void intrl2_##which##_mask_set(struct bcm_sf2_priv *priv, \
 	priv->irq##which##_mask |= (mask);				\
 }									\
 
-SF2_IO_MACRO(core);
-SF2_IO_MACRO(reg);
+static inline u32 core_readl(struct bcm_sf2_priv *priv, u32 off)
+{
+	u32 tmp = bcm_sf2_mangle_addr(priv, off);
+	return __raw_readl(priv->core + tmp);
+}
+
+static inline void core_writel(struct bcm_sf2_priv *priv, u32 val, u32 off)
+{
+	u32 tmp = bcm_sf2_mangle_addr(priv, off);
+	__raw_writel(val, priv->core + tmp);
+}
+
+static inline u32 reg_readl(struct bcm_sf2_priv *priv, u16 off)
+{
+	return __raw_readl(priv->reg + priv->reg_offsets[off]);
+}
+
+static inline void reg_writel(struct bcm_sf2_priv *priv, u32 val, u16 off)
+{
+	__raw_writel(val, priv->reg + priv->reg_offsets[off]);
+}
+
 SF2_IO64_MACRO(core);
 SF2_IO_MACRO(intrl2_0);
 SF2_IO_MACRO(intrl2_1);
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 838fe373cd6f..f5e566304f0c 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -12,22 +12,36 @@
 #define __BCM_SF2_REGS_H
 
 /* Register set relative to 'REG' */
-#define REG_SWITCH_CNTRL		0x00
-#define  MDIO_MASTER_SEL		(1 << 0)
 
-#define REG_SWITCH_STATUS		0x04
-#define REG_DIR_DATA_WRITE		0x08
-#define REG_DIR_DATA_READ		0x0C
+enum bcm_sf2_reg_offs {
+	REG_SWITCH_CNTRL = 0,
+	REG_SWITCH_STATUS,
+	REG_DIR_DATA_WRITE,
+	REG_DIR_DATA_READ,
+	REG_SWITCH_REVISION,
+	REG_PHY_REVISION,
+	REG_SPHY_CNTRL,
+	REG_RGMII_0_CNTRL,
+	REG_RGMII_1_CNTRL,
+	REG_RGMII_2_CNTRL,
+	REG_LED_0_CNTRL,
+	REG_LED_1_CNTRL,
+	REG_LED_2_CNTRL,
+	REG_SWITCH_REG_MAX,
+};
+
+/* Relative to REG_SWITCH_CNTRL */
+#define  MDIO_MASTER_SEL		(1 << 0)
 
-#define REG_SWITCH_REVISION		0x18
+/* Relative to REG_SWITCH_REVISION */
 #define  SF2_REV_MASK			0xffff
 #define  SWITCH_TOP_REV_SHIFT		16
 #define  SWITCH_TOP_REV_MASK		0xffff
 
-#define REG_PHY_REVISION		0x1C
+/* Relative to REG_PHY_REVISION */
 #define  PHY_REVISION_MASK		0xffff
 
-#define REG_SPHY_CNTRL			0x2C
+/* Relative to REG_SPHY_CNTRL */
 #define  IDDQ_BIAS			(1 << 0)
 #define  EXT_PWR_DOWN			(1 << 1)
 #define  FORCE_DLL_EN			(1 << 2)
@@ -37,13 +51,8 @@
 #define  PHY_PHYAD_SHIFT		8
 #define  PHY_PHYAD_MASK			0x1F
 
-#define REG_RGMII_0_BASE		0x34
-#define REG_RGMII_CNTRL			0x00
-#define REG_RGMII_IB_STATUS		0x04
-#define REG_RGMII_RX_CLOCK_DELAY_CNTRL	0x08
-#define REG_RGMII_CNTRL_SIZE		0x0C
-#define REG_RGMII_CNTRL_P(x)		(REG_RGMII_0_BASE + \
-					((x) * REG_RGMII_CNTRL_SIZE))
+#define REG_RGMII_CNTRL_P(x)		(REG_RGMII_0_CNTRL + (x))
+
 /* Relative to REG_RGMII_CNTRL */
 #define  RGMII_MODE_EN			(1 << 0)
 #define  ID_MODE_DIS			(1 << 1)
@@ -61,8 +70,8 @@
 #define  LPI_COUNT_SHIFT		9
 #define  LPI_COUNT_MASK			0x3F
 
-#define REG_LED_CNTRL_BASE		0x90
-#define REG_LED_CNTRL(x)		(REG_LED_CNTRL_BASE + (x) * 4)
+#define REG_LED_CNTRL(x)		(REG_LED_0_CNTRL + (x))
+
 #define  SPDLNK_SRC_SEL			(1 << 24)
 
 /* Register set relative to 'INTRL2_0' and 'INTRL2_1' */
-- 
2.9.3
