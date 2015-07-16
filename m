From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/6] net: bcmgenet: Determine PHY type before scanning MDIO bus
Date: Thu, 16 Jul 2015 15:51:17 -0700
Message-ID: <1437087079-21678-5-git-send-email-f.fainelli@gmail.com>
References: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36408 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756131AbbGPWxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:53:24 -0400
Received: by pachj5 with SMTP id hj5so49930818pac.3
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:53:23 -0700 (PDT)
In-Reply-To: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our internal GPHY might be powered off before we attempt scanning the
MDIO bus and bind a driver to it. The way we are currently determining
whether a PHY is internal or not is done *after* we have successfully
matched its driver. If the PHY is powered down, it will not respond to
the MDIO bus, so we will not be able to bind a driver to it.

Our Device Tree for GENET interfaces specifies a "phy-mode" value:
"internal" which tells if this internal uses an internal PHY or not.

If of_get_phy_mode() fails to parse the 'phy-mode' property, do an
additional manual lookup, and if we find "internal" set the
corresponding internal variable accordingly.

Replace all uses of phy_is_internal() with a check against
priv->internal_phy to avoid having to rely on whether or not
priv->phydev is set correctly.

Fixes: 1c1008c793fa4 ("net: bcmgenet: add main driver file")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 14 ++++++-------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 29 +++++++++++++++++++++-----
 3 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 2efe72f94869..076565463226 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1724,7 +1724,7 @@ static int init_umac(struct bcmgenet_priv *priv)
 	int0_enable |= UMAC_IRQ_TXDMA_DONE;
 
 	/* Monitor cable plug/unplugged event for internal PHY */
-	if (phy_is_internal(priv->phydev)) {
+	if (priv->internal_phy) {
 		int0_enable |= UMAC_IRQ_LINK_EVENT;
 	} else if (priv->ext_phy) {
 		int0_enable |= UMAC_IRQ_LINK_EVENT;
@@ -2631,7 +2631,7 @@ static int bcmgenet_open(struct net_device *dev)
 	/* If this is an internal GPHY, power it back on now, before UniMAC is
 	 * brought out of reset as absolutely no UniMAC activity is allowed
 	 */
-	if (phy_is_internal(priv->phydev))
+	if (priv->internal_phy)
 		bcmgenet_power_up(priv, GENET_POWER_PASSIVE);
 
 	/* take MAC out of reset */
@@ -2650,7 +2650,7 @@ static int bcmgenet_open(struct net_device *dev)
 
 	bcmgenet_set_hw_addr(priv, dev->dev_addr);
 
-	if (phy_is_internal(priv->phydev)) {
+	if (priv->internal_phy) {
 		reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
 		reg |= EXT_ENERGY_DET_MASK;
 		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
@@ -2756,7 +2756,7 @@ static int bcmgenet_close(struct net_device *dev)
 	free_irq(priv->irq0, priv);
 	free_irq(priv->irq1, priv);
 
-	if (phy_is_internal(priv->phydev))
+	if (priv->internal_phy)
 		ret = bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
 
 	if (!IS_ERR(priv->clk))
@@ -3318,7 +3318,7 @@ static int bcmgenet_suspend(struct device *d)
 	if (device_may_wakeup(d) && priv->wolopts) {
 		ret = bcmgenet_power_down(priv, GENET_POWER_WOL_MAGIC);
 		clk_prepare_enable(priv->clk_wol);
-	} else if (phy_is_internal(priv->phydev)) {
+	} else if (priv->internal_phy) {
 		ret = bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
 	}
 
@@ -3347,7 +3347,7 @@ static int bcmgenet_resume(struct device *d)
 	/* If this is an internal GPHY, power it back on now, before UniMAC is
 	 * brought out of reset as absolutely no UniMAC activity is allowed
 	 */
-	if (phy_is_internal(priv->phydev))
+	if (priv->internal_phy)
 		bcmgenet_power_up(priv, GENET_POWER_PASSIVE);
 
 	bcmgenet_umac_reset(priv);
@@ -3369,7 +3369,7 @@ static int bcmgenet_resume(struct device *d)
 
 	bcmgenet_set_hw_addr(priv, dev->dev_addr);
 
-	if (phy_is_internal(priv->phydev)) {
+	if (priv->internal_phy) {
 		reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
 		reg |= EXT_ENERGY_DET_MASK;
 		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 9f9ac0089d4d..84274de83670 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -593,6 +593,7 @@ struct bcmgenet_priv {
 	/* MDIO bus variables */
 	wait_queue_head_t wq;
 	struct phy_device *phydev;
+	bool internal_phy;
 	struct device_node *phy_dn;
 	struct device_node *mdio_dn;
 	struct mii_bus *mii_bus;
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index c5f9c7b5d9e7..35df947e738c 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -227,10 +227,10 @@ int bcmgenet_mii_config(struct net_device *dev, bool init)
 	u32 port_ctrl;
 	u32 reg;
 
-	priv->ext_phy = !phy_is_internal(priv->phydev) &&
+	priv->ext_phy = !priv->internal_phy &&
 			(priv->phy_interface != PHY_INTERFACE_MODE_MOCA);
 
-	if (phy_is_internal(priv->phydev))
+	if (priv->internal_phy)
 		priv->phy_interface = PHY_INTERFACE_MODE_NA;
 
 	switch (priv->phy_interface) {
@@ -248,7 +248,7 @@ int bcmgenet_mii_config(struct net_device *dev, bool init)
 
 		bcmgenet_sys_writel(priv, port_ctrl, SYS_PORT_CTRL);
 
-		if (phy_is_internal(priv->phydev)) {
+		if (priv->internal_phy) {
 			phy_name = "internal PHY";
 			bcmgenet_internal_phy_setup(dev);
 		} else if (priv->phy_interface == PHY_INTERFACE_MODE_MOCA) {
@@ -386,7 +386,7 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 	/* The internal PHY has its link interrupts routed to the
 	 * Ethernet MAC ISRs
 	 */
-	if (phy_is_internal(priv->phydev))
+	if (priv->internal_phy)
 		priv->mii_bus->irq[phydev->addr] = PHY_IGNORE_INTERRUPT;
 	else
 		priv->mii_bus->irq[phydev->addr] = PHY_POLL;
@@ -479,7 +479,9 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 {
 	struct device_node *dn = priv->pdev->dev.of_node;
 	struct device *kdev = &priv->pdev->dev;
+	const char *phy_mode_str = NULL;
 	char *compat;
+	int phy_mode;
 	int ret;
 
 	compat = kasprintf(GFP_KERNEL, "brcm,genet-mdio-v%d", priv->version);
@@ -503,7 +505,24 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 	priv->phy_dn = of_parse_phandle(dn, "phy-handle", 0);
 
 	/* Get the link mode */
-	priv->phy_interface = of_get_phy_mode(dn);
+	phy_mode = of_get_phy_mode(dn);
+	priv->phy_interface = phy_mode;
+
+	/* We need to specifically look up whether this PHY interface is internal
+	 * or not *before* we even try to probe the PHY driver over MDIO as we
+	 * may have shut down the internal PHY for power saving purposes.
+	 */
+	if (phy_mode < 0) {
+		ret = of_property_read_string(dn, "phy-mode", &phy_mode_str);
+		if (ret < 0) {
+			dev_err(kdev, "invalid PHY mode property\n");
+			return ret;
+		}
+
+		priv->phy_interface = PHY_INTERFACE_MODE_NA;
+		if (!strcasecmp(phy_mode_str, "internal"))
+			priv->internal_phy = true;
+	}
 
 	return 0;
 }
-- 
2.1.0
