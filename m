From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 6/7] arc_emac: remove custom "max-speed" parsing code
Date: Thu, 5 Dec 2013 14:52:15 -0800
Message-ID: <1386283936-26104-7-git-send-email-florian@openwrt.org>
References: <1386283936-26104-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <abrodkin@synopsys.com>,
	<rob.herring@calxeda.com>, <mark.rutland@arm.com>,
	<sebastian.hesselbarth@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:38756 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754242Ab3LEXCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:02:01 -0500
In-Reply-To: <1386283936-26104-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

The ARC emac driver was the only in-tree to parse a PHY device
'max-speed' property but yet failed to do it correctly because
'max-speed' is supposed to set a PHY device supported features, not the
advertising features as it was done.

Now that of_mdiobus_register() takes care of doing that, remove the
custom 'max-speed' parsing code.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/arc/emac.h      |  2 --
 drivers/net/ethernet/arc/emac_main.c | 20 +-------------------
 2 files changed, 1 insertion(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
index dc08678..928fac6 100644
--- a/drivers/net/ethernet/arc/emac.h
+++ b/drivers/net/ethernet/arc/emac.h
@@ -122,7 +122,6 @@ struct buffer_state {
  * @link:	PHY's last seen link state.
  * @duplex:	PHY's last set duplex mode.
  * @speed:	PHY's last set speed.
- * @max_speed:	Maximum supported by current system network data-rate.
  */
 struct arc_emac_priv {
 	/* Devices */
@@ -152,7 +151,6 @@ struct arc_emac_priv {
 	unsigned int link;
 	unsigned int duplex;
 	unsigned int speed;
-	unsigned int max_speed;
 };
 
 /**
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index b2ffad1..eedf2a5 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -381,17 +381,7 @@ static int arc_emac_open(struct net_device *ndev)
 	phy_dev->autoneg = AUTONEG_ENABLE;
 	phy_dev->speed = 0;
 	phy_dev->duplex = 0;
-	phy_dev->advertising = phy_dev->supported;
-
-	if (priv->max_speed > 100) {
-		phy_dev->advertising &= PHY_GBIT_FEATURES;
-	} else if (priv->max_speed <= 100) {
-		phy_dev->advertising &= PHY_BASIC_FEATURES;
-		if (priv->max_speed <= 10) {
-			phy_dev->advertising &= ~SUPPORTED_100baseT_Half;
-			phy_dev->advertising &= ~SUPPORTED_100baseT_Full;
-		}
-	}
+	phy_dev->advertising &= phy_dev->supported;
 
 	priv->last_rx_bd = 0;
 
@@ -704,14 +694,6 @@ static int arc_emac_probe(struct platform_device *pdev)
 	/* Set poll rate so that it polls every 1 ms */
 	arc_reg_set(priv, R_POLLRATE, clock_frequency / 1000000);
 
-	/* Get max speed of operation from device tree */
-	if (of_property_read_u32(pdev->dev.of_node, "max-speed",
-				 &priv->max_speed)) {
-		dev_err(&pdev->dev, "failed to retrieve <max-speed> from device tree\n");
-		err = -EINVAL;
-		goto out;
-	}
-
 	ndev->irq = irq;
 	dev_info(&pdev->dev, "IRQ is %d\n", ndev->irq);
 
-- 
1.8.3.2
