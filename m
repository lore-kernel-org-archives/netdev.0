From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 2/2] net: fec: Add support for phys from devicetree
Date: Mon, 21 Jan 2013 09:37:55 +0100
Message-ID: <1358757475-21035-3-git-send-email-s.hauer@pengutronix.de>
References: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de>
Cc: linux-arm-kernel@lists.infradead.org, shawn.guo@linaro.org,
	davem@davemloft.net, Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55492 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509Ab3AUIiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 03:38:09 -0500
In-Reply-To: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for specifying the phy for the fec driver through the
devicetree. Possible usecases are:

- The fec internal MDIO bus has multiple phys connected and a particular
  one has to be chosen which is physically connected to the (RG)MII interface.
- The phy is connected to an external MDIO bus.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt |   20 +++++++
 drivers/net/ethernet/freescale/fec.c              |   61 +++++++++++++--------
 drivers/net/ethernet/freescale/fec.h              |    1 +
 3 files changed, 59 insertions(+), 23 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index d536392..ec7060b 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -15,6 +15,9 @@ Optional properties:
   only if property "phy-reset-gpios" is available.  Missing the property
   will have the duration be 1 millisecond.  Numbers greater than 1000 are
   invalid and 1 millisecond will be used instead.
+- phy : a phandle for the PHY device used for the fec. Used to specify an
+  external phy or to specify a particular address if the mdio bus has multiple
+  phys on it.
 
 Example:
 
@@ -26,3 +29,20 @@ ethernet@83fec000 {
 	phy-reset-gpios = <&gpio2 14 0>; /* GPIO2_14 */
 	local-mac-address = [00 04 9F 01 1B B9];
 };
+
+Example with specific phy address:
+
+ethernet@83fec000 {
+	compatible = "fsl,imx51-fec", "fsl,imx27-fec";
+	reg = <0x83fec000 0x4000>;
+	interrupts = <87>;
+	phy-mode = "mii";
+	phy-reset-gpios = <&gpio2 14 0>; /* GPIO2_14 */
+	local-mac-address = [00 04 9F 01 1B B9];
+	phy = &phy3;
+
+	phy3: ethernet-phy@3 {
+		reg = <3>;
+		device_type = "ethernet-phy";
+	};
+};
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 2f86557..54a8506 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -48,6 +48,7 @@
 #include <linux/of_device.h>
 #include <linux/of_gpio.h>
 #include <linux/of_net.h>
+#include <linux/of_mdio.h>
 #include <linux/pinctrl/consumer.h>
 #include <linux/regulator/consumer.h>
 
@@ -950,31 +951,38 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 
 	fep->phy_dev = NULL;
 
-	/* check for attached phy */
-	for (phy_id = 0; (phy_id < PHY_MAX_ADDR); phy_id++) {
-		if ((fep->mii_bus->phy_mask & (1 << phy_id)))
-			continue;
-		if (fep->mii_bus->phy_map[phy_id] == NULL)
-			continue;
-		if (fep->mii_bus->phy_map[phy_id]->phy_id == 0)
-			continue;
-		if (dev_id--)
-			continue;
-		strncpy(mdio_bus_id, fep->mii_bus->id, MII_BUS_ID_SIZE);
-		break;
-	}
+	if (fep->phy_node) {
+		phy_dev = of_phy_connect(ndev, fep->phy_node, &fec_enet_adjust_link, 0,
+			      fep->phy_interface);
+	} else {
+		/* check for attached phy */
+		for (phy_id = 0; (phy_id < PHY_MAX_ADDR); phy_id++) {
+			if ((fep->mii_bus->phy_mask & (1 << phy_id)))
+				continue;
+			if (fep->mii_bus->phy_map[phy_id] == NULL)
+				continue;
+			if (fep->mii_bus->phy_map[phy_id]->phy_id == 0)
+				continue;
+			if (dev_id--)
+				continue;
+			strncpy(mdio_bus_id, fep->mii_bus->id, MII_BUS_ID_SIZE);
+			break;
+		}
+
+		if (phy_id >= PHY_MAX_ADDR) {
+			printk(KERN_INFO
+				"%s: no PHY, assuming direct connection to switch\n",
+				ndev->name);
+			strncpy(mdio_bus_id, "fixed-0", MII_BUS_ID_SIZE);
+			phy_id = 0;
+		}
+
+		snprintf(phy_name, sizeof(phy_name), PHY_ID_FMT, mdio_bus_id, phy_id);
 
-	if (phy_id >= PHY_MAX_ADDR) {
-		printk(KERN_INFO
-			"%s: no PHY, assuming direct connection to switch\n",
-			ndev->name);
-		strncpy(mdio_bus_id, "fixed-0", MII_BUS_ID_SIZE);
-		phy_id = 0;
+		phy_dev = phy_connect(ndev, phy_name, &fec_enet_adjust_link, 0,
+				      fep->phy_interface);
 	}
 
-	snprintf(phy_name, sizeof(phy_name), PHY_ID_FMT, mdio_bus_id, phy_id);
-	phy_dev = phy_connect(ndev, phy_name, &fec_enet_adjust_link, 0,
-			      fep->phy_interface);
 	if (IS_ERR(phy_dev)) {
 		printk(KERN_ERR "%s: could not attach to PHY\n", ndev->name);
 		return PTR_ERR(phy_dev);
@@ -1076,7 +1084,12 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	for (i = 0; i < PHY_MAX_ADDR; i++)
 		fep->mii_bus->irq[i] = PHY_POLL;
 
-	if (mdiobus_register(fep->mii_bus))
+	if (fep->phy_node)
+		err = of_mdiobus_register(fep->mii_bus, pdev->dev.of_node);
+	else
+		err = mdiobus_register(fep->mii_bus);
+
+	if (err)
 		goto err_out_free_mdio_irq;
 
 	mii_cnt++;
@@ -1493,6 +1506,8 @@ static int fec_probe_dt(struct fec_enet_private *fep)
 
 	fep->phy_interface = of_get_phy_mode(np);
 
+	fep->phy_node = of_parse_phandle(np, "phy", 0);
+
 	return -ENODEV;
 }
 
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index c5a3bc1..0120ea6 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -236,6 +236,7 @@ struct fec_enet_private {
 	/* Phylib and MDIO interface */
 	struct	mii_bus *mii_bus;
 	struct	phy_device *phy_dev;
+	struct	device_node *phy_node;
 	int	mii_timeout;
 	uint	phy_speed;
 	phy_interface_t	phy_interface;
-- 
1.7.10.4
