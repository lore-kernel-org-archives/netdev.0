From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: fec: Support phys probed from devicetree and fixed-link
Date: Mon, 11 Aug 2014 17:35:33 +0200
Message-ID: <1407771333-24683-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	kernel@pengutronix.de, devicetree@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58957 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692AbaHKPfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 11:35:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for specifying the phy to be used with the fec in the
devicetree using the standard phy-handle property and also supports
fixed-link.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt | 29 ++++++++-
 drivers/net/ethernet/freescale/fec.h              |  1 +
 drivers/net/ethernet/freescale/fec_main.c         | 76 +++++++++++++++=
+-------
 3 files changed, 84 insertions(+), 22 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Docume=
ntation/devicetree/bindings/net/fsl-fec.txt
index 6bc84adb10c0..8a2c7b55ec16 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -12,7 +12,14 @@ Optional properties:
   only if property "phy-reset-gpios" is available.  Missing the proper=
ty
   will have the duration be 1 millisecond.  Numbers greater than 1000 =
are
   invalid and 1 millisecond will be used instead.
-- phy-supply: regulator that powers the Ethernet PHY.
+- phy-supply : regulator that powers the Ethernet PHY.
+- phy-handle : phandle to the PHY device connected to this device.
+- fixed-link : Assume a fixed link. See fixed-link.txt in the same dir=
ectory.
+  Use instead of phy-handle.
+
+Optional subnodes:
+- mdio : specifies the mdio bus in the FEC, used as a container for ph=
y nodes
+  according to phy.txt in the same directory
=20
 Example:
=20
@@ -25,3 +32,23 @@ ethernet@83fec000 {
 	local-mac-address =3D [00 04 9F 01 1B B9];
 	phy-supply =3D <&reg_fec_supply>;
 };
+
+Example with phy specified:
+
+ethernet@83fec000 {
+	compatible =3D "fsl,imx51-fec", "fsl,imx27-fec";
+	reg =3D <0x83fec000 0x4000>;
+	interrupts =3D <87>;
+	phy-mode =3D "mii";
+	phy-reset-gpios =3D <&gpio2 14 0>; /* GPIO2_14 */
+	local-mac-address =3D [00 04 9F 01 1B B9];
+	phy-supply =3D <&reg_fec_supply>;
+	phy-handle =3D <&ethphy>;
+	mdio {
+		ethphy: ethernet-phy@6 {
+			compatible =3D "ethernet-phy-ieee802.3-c22";
+			reg =3D <6>;
+			max-speed =3D <100>;
+		};
+	};
+};
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/etherne=
t/freescale/fec.h
index 671d080105a7..f643d3e8f81d 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -317,6 +317,7 @@ struct fec_enet_private {
 	int	mii_timeout;
 	uint	phy_speed;
 	phy_interface_t	phy_interface;
+	struct device_node *phy_node;
 	int	link;
 	int	full_duplex;
 	int	speed;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 77037fd377b8..9816392982d6 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -52,6 +52,7 @@
 #include <linux/of.h>
 #include <linux/of_device.h>
 #include <linux/of_gpio.h>
+#include <linux/of_mdio.h>
 #include <linux/of_net.h>
 #include <linux/regulator/consumer.h>
 #include <linux/if_vlan.h>
@@ -1636,29 +1637,37 @@ static int fec_enet_mii_probe(struct net_device=
 *ndev)
=20
 	fep->phy_dev =3D NULL;
=20
-	/* check for attached phy */
-	for (phy_id =3D 0; (phy_id < PHY_MAX_ADDR); phy_id++) {
-		if ((fep->mii_bus->phy_mask & (1 << phy_id)))
-			continue;
-		if (fep->mii_bus->phy_map[phy_id] =3D=3D NULL)
-			continue;
-		if (fep->mii_bus->phy_map[phy_id]->phy_id =3D=3D 0)
-			continue;
-		if (dev_id--)
-			continue;
-		strncpy(mdio_bus_id, fep->mii_bus->id, MII_BUS_ID_SIZE);
-		break;
-	}
+	if (fep->phy_node) {
+		phy_dev =3D of_phy_connect(ndev, fep->phy_node,
+					 &fec_enet_adjust_link, 0,
+					 fep->phy_interface);
+	} else {
+		/* check for attached phy */
+		for (phy_id =3D 0; (phy_id < PHY_MAX_ADDR); phy_id++) {
+			if ((fep->mii_bus->phy_mask & (1 << phy_id)))
+				continue;
+			if (fep->mii_bus->phy_map[phy_id] =3D=3D NULL)
+				continue;
+			if (fep->mii_bus->phy_map[phy_id]->phy_id =3D=3D 0)
+				continue;
+			if (dev_id--)
+				continue;
+			strncpy(mdio_bus_id, fep->mii_bus->id, MII_BUS_ID_SIZE);
+			break;
+		}
=20
-	if (phy_id >=3D PHY_MAX_ADDR) {
-		netdev_info(ndev, "no PHY, assuming direct connection to switch\n");
-		strncpy(mdio_bus_id, "fixed-0", MII_BUS_ID_SIZE);
-		phy_id =3D 0;
+		if (phy_id >=3D PHY_MAX_ADDR) {
+			netdev_info(ndev, "no PHY, assuming direct connection to switch\n")=
;
+			strncpy(mdio_bus_id, "fixed-0", MII_BUS_ID_SIZE);
+			phy_id =3D 0;
+		}
+
+		snprintf(phy_name, sizeof(phy_name),
+			 PHY_ID_FMT, mdio_bus_id, phy_id);
+		phy_dev =3D phy_connect(ndev, phy_name, &fec_enet_adjust_link,
+				      fep->phy_interface);
 	}
=20
-	snprintf(phy_name, sizeof(phy_name), PHY_ID_FMT, mdio_bus_id, phy_id)=
;
-	phy_dev =3D phy_connect(ndev, phy_name, &fec_enet_adjust_link,
-			      fep->phy_interface);
 	if (IS_ERR(phy_dev)) {
 		netdev_err(ndev, "could not attach to PHY\n");
 		return PTR_ERR(phy_dev);
@@ -1694,6 +1703,7 @@ static int fec_enet_mii_init(struct platform_devi=
ce *pdev)
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	const struct platform_device_id *id_entry =3D
 				platform_get_device_id(fep->pdev);
+	struct device_node *node;
 	int err =3D -ENXIO, i;
=20
 	/*
@@ -1761,7 +1771,15 @@ static int fec_enet_mii_init(struct platform_dev=
ice *pdev)
 	for (i =3D 0; i < PHY_MAX_ADDR; i++)
 		fep->mii_bus->irq[i] =3D PHY_POLL;
=20
-	if (mdiobus_register(fep->mii_bus))
+	node =3D of_get_child_by_name(pdev->dev.of_node, "mdio");
+	if (node) {
+		err =3D of_mdiobus_register(fep->mii_bus, node);
+		of_node_put(node);
+	} else {
+		err =3D mdiobus_register(fep->mii_bus);
+	}
+
+	if (err)
 		goto err_out_free_mdio_irq;
=20
 	mii_cnt++;
@@ -2485,6 +2503,7 @@ fec_probe(struct platform_device *pdev)
 	struct resource *r;
 	const struct of_device_id *of_id;
 	static int dev_id;
+	struct device_node *np =3D pdev->dev.of_node, *phy_node;
=20
 	of_id =3D of_match_device(fec_dt_ids, &pdev->dev);
 	if (of_id)
@@ -2524,6 +2543,18 @@ fec_probe(struct platform_device *pdev)
=20
 	platform_set_drvdata(pdev, ndev);
=20
+	phy_node =3D of_parse_phandle(np, "phy-handle", 0);
+	if (!phy_node && of_phy_is_fixed_link(np)) {
+		ret =3D of_phy_register_fixed_link(np);
+		if (ret < 0) {
+			dev_err(&pdev->dev,
+				"broken fixed-link specification\n");
+			goto failed_phy;
+		}
+		phy_node =3D of_node_get(np);
+	}
+	fep->phy_node =3D phy_node;
+
 	ret =3D of_get_phy_mode(pdev->dev.of_node);
 	if (ret < 0) {
 		pdata =3D dev_get_platdata(&pdev->dev);
@@ -2628,6 +2659,8 @@ failed_init:
 failed_regulator:
 	fec_enet_clk_enable(ndev, false);
 failed_clk:
+failed_phy:
+	of_node_put(phy_node);
 failed_ioremap:
 	free_netdev(ndev);
=20
@@ -2649,6 +2682,7 @@ fec_drv_remove(struct platform_device *pdev)
 	if (fep->ptp_clock)
 		ptp_clock_unregister(fep->ptp_clock);
 	fec_enet_clk_enable(ndev, false);
+	of_node_put(fep->phy_node);
 	free_netdev(ndev);
=20
 	return 0;
--=20
2.0.1
