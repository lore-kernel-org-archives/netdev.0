From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/3] net: bcmgenet: add EEE support
Date: Tue, 25 Nov 2014 21:16:35 -0800
Message-ID: <1416978996-24808-3-git-send-email-f.fainelli@gmail.com>
References: <1416978996-24808-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:39184 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbaKZFQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 00:16:43 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so2106400pac.11
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 21:16:43 -0800 (PST)
In-Reply-To: <1416978996-24808-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow enabling and disabling EEE using the designated ethtool getters
and setters. GENET allows controlling EEE at the UniMAC, RBUF and TBUF
levels. We also take care of restoring EEE after a suspend/resume cycle
if it was enabled prior to suspending.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 96 ++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  4 ++
 2 files changed, 100 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index fcbf1255ae5a..bf44e0e23799 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -714,6 +714,91 @@ static void bcmgenet_get_ethtool_stats(struct net_device *dev,
 	}
 }
 
+static void bcmgenet_eee_enable_set(struct net_device *dev, bool enable)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	u32 off = priv->hw_params->tbuf_offset + TBUF_ENERGY_CTRL;
+	u32 reg;
+
+	if (enable && !priv->clk_eee_enabled) {
+		clk_prepare_enable(priv->clk_eee);
+		priv->clk_eee_enabled = true;
+	}
+
+	reg = bcmgenet_umac_readl(priv, UMAC_EEE_CTRL);
+	if (enable)
+		reg |= EEE_EN;
+	else
+		reg &= ~EEE_EN;
+	bcmgenet_umac_writel(priv, reg, UMAC_EEE_CTRL);
+
+	/* Enable EEE and switch to a 27Mhz clock automatically */
+	reg = __raw_readl(priv->base + off);
+	if (enable)
+		reg |= TBUF_EEE_EN | TBUF_PM_EN;
+	else
+		reg &= ~(TBUF_EEE_EN | TBUF_PM_EN);
+	__raw_writel(reg, priv->base + off);
+
+	/* Do the same for thing for RBUF */
+	reg = bcmgenet_rbuf_readl(priv, RBUF_ENERGY_CTRL);
+	if (enable)
+		reg |= RBUF_EEE_EN | RBUF_PM_EN;
+	else
+		reg &= ~(RBUF_EEE_EN | RBUF_PM_EN);
+	bcmgenet_rbuf_writel(priv, reg, RBUF_ENERGY_CTRL);
+
+	if (!enable && priv->clk_eee_enabled) {
+		clk_disable_unprepare(priv->clk_eee);
+		priv->clk_eee_enabled = false;
+	}
+
+	priv->eee.eee_enabled = enable;
+	priv->eee.eee_active = enable;
+}
+
+static int bcmgenet_get_eee(struct net_device *dev, struct ethtool_eee *e)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	struct ethtool_eee *p = &priv->eee;
+
+	if (GENET_IS_V1(priv))
+		return -EOPNOTSUPP;
+
+	e->eee_enabled = p->eee_enabled;
+	e->eee_active = p->eee_active;
+	e->tx_lpi_timer = bcmgenet_umac_readl(priv, UMAC_EEE_LPI_TIMER);
+
+	return phy_ethtool_get_eee(priv->phydev, e);
+}
+
+static int bcmgenet_set_eee(struct net_device *dev, struct ethtool_eee *e)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	struct ethtool_eee *p = &priv->eee;
+	int ret = 0;
+
+	if (GENET_IS_V1(priv))
+		return -EOPNOTSUPP;
+
+	p->eee_enabled = e->eee_enabled;
+
+	if (!p->eee_enabled) {
+		bcmgenet_eee_enable_set(dev, false);
+	} else {
+		ret = phy_init_eee(priv->phydev, 0);
+		if (ret) {
+			netif_err(priv, hw, dev, "EEE initialization failed\n");
+			return ret;
+		}
+
+		bcmgenet_umac_writel(priv, e->tx_lpi_timer, UMAC_EEE_LPI_TIMER);
+		bcmgenet_eee_enable_set(dev, true);
+	}
+
+	return phy_ethtool_set_eee(priv->phydev, e);
+}
+
 /* standard ethtool support functions. */
 static struct ethtool_ops bcmgenet_ethtool_ops = {
 	.get_strings		= bcmgenet_get_strings,
@@ -727,6 +812,8 @@ static struct ethtool_ops bcmgenet_ethtool_ops = {
 	.set_msglevel		= bcmgenet_set_msglevel,
 	.get_wol		= bcmgenet_get_wol,
 	.set_wol		= bcmgenet_set_wol,
+	.get_eee		= bcmgenet_get_eee,
+	.set_eee		= bcmgenet_set_eee,
 };
 
 /* Power down the unimac, based on mode. */
@@ -2585,6 +2672,12 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	if (IS_ERR(priv->clk_wol))
 		dev_warn(&priv->pdev->dev, "failed to get enet-wol clock\n");
 
+	priv->clk_eee = devm_clk_get(&priv->pdev->dev, "enet-eee");
+	if (IS_ERR(priv->clk_eee)) {
+		dev_warn(&priv->pdev->dev, "failed to get enet-eee clock\n");
+		priv->clk_eee = NULL;
+	}
+
 	err = reset_umac(priv);
 	if (err)
 		goto err_clk_disable;
@@ -2735,6 +2828,9 @@ static int bcmgenet_resume(struct device *d)
 
 	phy_resume(priv->phydev);
 
+	if (priv->eee.eee_enabled)
+		bcmgenet_eee_enable_set(dev, true);
+
 	bcmgenet_netif_start(dev);
 
 	return 0;
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index ea6f0ab566bf..b36ddec0cc0a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -573,6 +573,8 @@ struct bcmgenet_priv {
 	struct device_node *phy_dn;
 	struct mii_bus *mii_bus;
 	u16 gphy_rev;
+	struct clk *clk_eee;
+	bool clk_eee_enabled;
 
 	/* PHY device variables */
 	int old_link;
@@ -609,6 +611,8 @@ struct bcmgenet_priv {
 	u32 wolopts;
 
 	struct bcmgenet_mib_counters mib;
+
+	struct ethtool_eee eee;
 };
 
 #define GENET_IO_MACRO(name, offset)					\
-- 
2.1.0
