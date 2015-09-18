From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH/RFC net-next v3 4/4] ravb: Add support for r8a7795 SoC
Date: Fri, 18 Sep 2015 15:03:23 +0900
Message-ID: <1442556203-657-5-git-send-email-horms+renesas@verge.net.au>
References: <1442556203-657-1-git-send-email-horms+renesas@verge.net.au>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Magnus Damm <magnus.damm@gmail.com>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58825 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbbIRGDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 02:03:55 -0400
In-Reply-To: <1442556203-657-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

This patch supports the r8a7795 SoC by:
- Using two interrupts
  + One for E-MAC
  + One for everything else
  + Both can be handled by the existing common interrupt handler, which
    affords a simpler update to support the new SoC. In future some
    consideration may be given to implementing multiple interrupt handlers
- Limiting the phy speed to 100Mbit/s for the new SoC;
  at this time it is not clear how this restriction may be lifted
  but I hope it will be possible as more information comes to light

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
[horms: reworked]
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
v0 [Kazuya Mizuguchi]

v1 [Simon Horman]
* Updated patch subject

v2 [Simon Horman]
* Reworked based on extensive feedback from
  Geert Uytterhoeven and Sergei Shtylyov.
* Broke binding update out into separate patch

v3 [Simon Horman]
* Check new return value of phy_set_max_speed()
---
 drivers/net/ethernet/renesas/ravb.h      |  7 ++++
 drivers/net/ethernet/renesas/ravb_main.c | 63 ++++++++++++++++++++++++++++----
 2 files changed, 62 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
index a157aaaaff6a..0623fff932e4 100644
--- a/drivers/net/ethernet/renesas/ravb.h
+++ b/drivers/net/ethernet/renesas/ravb.h
@@ -766,6 +766,11 @@ struct ravb_ptp {
 	struct ravb_ptp_perout perout[N_PER_OUT];
 };
 
+enum ravb_chip_id {
+	RCAR_GEN2,
+	RCAR_GEN3,
+};
+
 struct ravb_private {
 	struct net_device *ndev;
 	struct platform_device *pdev;
@@ -806,6 +811,8 @@ struct ravb_private {
 	int msg_enable;
 	int speed;
 	int duplex;
+	int emac_irq;
+	enum ravb_chip_id chip_id;
 
 	unsigned no_avb_link:1;
 	unsigned avb_link_active_low:1;
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 4ca093d033f8..8cc5ec5ed19a 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -889,6 +889,22 @@ static int ravb_phy_init(struct net_device *ndev)
 		return -ENOENT;
 	}
 
+	/* This driver only support 10/100Mbit speeds on Gen3
+	 * at this time.
+	 */
+	if (priv->chip_id == RCAR_GEN3) {
+		int err;
+
+		err = phy_set_max_speed(phydev, SPEED_100);
+		if (err) {
+			netdev_err(ndev, "failed to limit PHY to 100Mbit/s\n");
+			phy_disconnect(phydev);
+			return err;
+		}
+
+		netdev_info(ndev, "limited PHY to 100Mbit/s\n");
+	}
+
 	netdev_info(ndev, "attached PHY %d (IRQ %d) to driver %s\n",
 		    phydev->addr, phydev->irq, phydev->drv->name);
 
@@ -1197,6 +1213,15 @@ static int ravb_open(struct net_device *ndev)
 		goto out_napi_off;
 	}
 
+	if (priv->chip_id == RCAR_GEN3) {
+		error = request_irq(priv->emac_irq, ravb_interrupt,
+				    IRQF_SHARED, ndev->name, ndev);
+		if (error) {
+			netdev_err(ndev, "cannot request IRQ\n");
+			goto out_free_irq;
+		}
+	}
+
 	/* Device init */
 	error = ravb_dmac_init(ndev);
 	if (error)
@@ -1220,6 +1245,7 @@ out_ptp_stop:
 	ravb_ptp_stop(ndev);
 out_free_irq:
 	free_irq(ndev->irq, ndev);
+	free_irq(priv->emac_irq, ndev);
 out_napi_off:
 	napi_disable(&priv->napi[RAVB_NC]);
 	napi_disable(&priv->napi[RAVB_BE]);
@@ -1625,10 +1651,20 @@ static int ravb_mdio_release(struct ravb_private *priv)
 	return 0;
 }
 
+static const struct of_device_id ravb_match_table[] = {
+	{ .compatible = "renesas,etheravb-r8a7790", .data = (void *)RCAR_GEN2 },
+	{ .compatible = "renesas,etheravb-r8a7794", .data = (void *)RCAR_GEN2 },
+	{ .compatible = "renesas,etheravb-r8a7795", .data = (void *)RCAR_GEN3 },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, ravb_match_table);
+
 static int ravb_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
+	const struct of_device_id *match;
 	struct ravb_private *priv;
+	enum ravb_chip_id chip_id;
 	struct net_device *ndev;
 	int error, irq, q;
 	struct resource *res;
@@ -1657,7 +1693,14 @@ static int ravb_probe(struct platform_device *pdev)
 	/* The Ether-specific entries in the device structure. */
 	ndev->base_addr = res->start;
 	ndev->dma = -1;
-	irq = platform_get_irq(pdev, 0);
+
+	match = of_match_device(of_match_ptr(ravb_match_table), &pdev->dev);
+	chip_id = (enum ravb_chip_id)match->data;
+
+	if (chip_id == RCAR_GEN3)
+		irq = platform_get_irq_byname(pdev, "ch22");
+	else
+		irq = platform_get_irq(pdev, 0);
 	if (irq < 0) {
 		error = irq;
 		goto out_release;
@@ -1688,6 +1731,17 @@ static int ravb_probe(struct platform_device *pdev)
 	priv->avb_link_active_low =
 		of_property_read_bool(np, "renesas,ether-link-active-low");
 
+	if (chip_id == RCAR_GEN3) {
+		irq = platform_get_irq_byname(pdev, "ch24");
+		if (irq < 0) {
+			error = irq;
+			goto out_release;
+		}
+		priv->emac_irq = irq;
+	}
+
+	priv->chip_id = chip_id;
+
 	/* Set function */
 	ndev->netdev_ops = &ravb_netdev_ops;
 	ndev->ethtool_ops = &ravb_ethtool_ops;
@@ -1818,13 +1872,6 @@ static const struct dev_pm_ops ravb_dev_pm_ops = {
 #define RAVB_PM_OPS NULL
 #endif
 
-static const struct of_device_id ravb_match_table[] = {
-	{ .compatible = "renesas,etheravb-r8a7790" },
-	{ .compatible = "renesas,etheravb-r8a7794" },
-	{ }
-};
-MODULE_DEVICE_TABLE(of, ravb_match_table);
-
 static struct platform_driver ravb_driver = {
 	.probe		= ravb_probe,
 	.remove		= ravb_remove,
-- 
2.1.4
