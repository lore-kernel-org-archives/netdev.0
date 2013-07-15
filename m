From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [RFC PATCH 3/3] net: mvneta: add support for fixed links
Date: Mon, 15 Jul 2013 17:34:10 +0200
Message-ID: <1373902450-11857-4-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:58221 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932580Ab3GOPec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 11:34:32 -0400
In-Reply-To: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following the introduction of of_phy_register_fixed_link(), this patch
introduces fixed link support in the mvneta driver, for Marvell Armada
370/XP SOCs.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 .../bindings/net/marvell-armada-370-neta.txt       | 24 +++++++++++++++++++---
 drivers/net/ethernet/marvell/mvneta.c              | 18 +++++++++++-----
 2 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
index 859a6fa..31e61c0 100644
--- a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
+++ b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
@@ -4,13 +4,21 @@ Required properties:
 - compatible: should be "marvell,armada-370-neta".
 - reg: address and length of the register set for the device.
 - interrupts: interrupt for the device
-- phy: A phandle to a phy node defining the PHY address (as the reg
-  property, a single integer).
 - phy-mode: The interface between the SoC and the PHY (a string that
   of_get_phy_mode() can understand)
 - clocks: a pointer to the reference clock for this device.
 
-Example:
+Optional properties:
+
+- phy: A phandle to a phy node defining the PHY address (as the reg
+  property, a single integer). Note: if this property isn't present,
+  then fixed link is assumed, and the 'fixed-link' property is
+  mandatory.
+- fixed-link: A 5 elements array that describe a fixed link, see
+  fixed-link.txt for details. Note: if a 'phy' property is present,
+  this 'fixed-link' property is ignored.
+
+Examples:
 
 ethernet@d0070000 {
 	compatible = "marvell,armada-370-neta";
@@ -21,3 +29,13 @@ ethernet@d0070000 {
 	phy = <&phy0>;
 	phy-mode = "rgmii-id";
 };
+
+ethernet@d0070000 {
+	compatible = "marvell,armada-370-neta";
+	reg = <0xd0070000 0x2500>;
+	interrupts = <8>;
+	clocks = <&gate_clk 4>;
+	status = "okay";
+	fixed-link = <1 1 1000 0 0>;
+	phy-mode = "rgmii-id";
+};
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 712779f..0bd1590 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2349,8 +2349,12 @@ static int mvneta_mdio_probe(struct mvneta_port *pp)
 {
 	struct phy_device *phy_dev;
 
-	phy_dev = of_phy_connect(pp->dev, pp->phy_node, mvneta_adjust_link, 0,
-				 pp->phy_interface);
+	if (pp->phy_node)
+		phy_dev = of_phy_connect(pp->dev, pp->phy_node, mvneta_adjust_link, 0,
+					 pp->phy_interface);
+	else
+		phy_dev = of_phy_connect_fixed_link(pp->dev, mvneta_adjust_link,
+						    pp->phy_interface);
 	if (!phy_dev) {
 		netdev_err(pp->dev, "could not find the PHY\n");
 		return -ENODEV;
@@ -2708,9 +2712,13 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	phy_node = of_parse_phandle(dn, "phy", 0);
 	if (!phy_node) {
-		dev_err(&pdev->dev, "no associated PHY\n");
-		err = -ENODEV;
-		goto err_free_irq;
+		/* No 'phy' found, see if we have a 'fixed-link'
+		 * property */
+		err = of_phy_register_fixed_link(dn);
+		if (err < 0) {
+			dev_err(&pdev->dev, "no 'phy' or 'fixed-link' properties\n");
+			goto err_free_irq;
+		}
 	}
 
 	phy_mode = of_get_phy_mode(dn);
-- 
1.8.1.2
