From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [RFC PATCHv2 4/4] net: mvneta: add support for fixed links
Date: Fri,  6 Sep 2013 17:18:21 +0200
Message-ID: <1378480701-12908-5-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Florian Fainelli <florian@openwrt.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:41904 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753581Ab3IFPS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 11:18:27 -0400
In-Reply-To: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following the introduction of of_phy_register_fixed_link(), this patch
introduces fixed link support in the mvneta driver, for Marvell Armada
370/XP SOCs.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 .../devicetree/bindings/net/marvell-armada-370-neta.txt        |  4 ++--
 drivers/net/ethernet/marvell/mvneta.c                          | 10 ++++++----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
index 859a6fa..4d07d4e 100644
--- a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
+++ b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
@@ -4,8 +4,8 @@ Required properties:
 - compatible: should be "marvell,armada-370-neta".
 - reg: address and length of the register set for the device.
 - interrupts: interrupt for the device
-- phy: A phandle to a phy node defining the PHY address (as the reg
-  property, a single integer).
+- phy: A phandle to the PHY node describing the PHY to which this
+  Ethernet controller is connected to.
 - phy-mode: The interface between the SoC and the PHY (a string that
   of_get_phy_mode() can understand)
 - clocks: a pointer to the reference clock for this device.
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index b017818..6da1516 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2711,10 +2711,12 @@ static int mvneta_probe(struct platform_device *pdev)
 	}
 
 	phy_node = of_parse_phandle(dn, "phy", 0);
-	if (!phy_node) {
-		dev_err(&pdev->dev, "no associated PHY\n");
-		err = -ENODEV;
-		goto err_free_irq;
+	if (of_phy_is_fixed_link(phy_node)) {
+		err = of_phy_register_fixed_link(phy_node);
+		if (err < 0) {
+			dev_err(&pdev->dev, "cannot register fixed PHY\n");
+			goto err_free_irq;
+		}
 	}
 
 	phy_mode = of_get_phy_mode(dn);
-- 
1.8.1.2
