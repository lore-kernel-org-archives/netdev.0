From: Axel Lin <axel.lin@ingics.com>
Subject: [RFT][PATCH 1/2] phy: bcm-ns2-pcie: Get rid of struct ns2_pci_phy
Date: Sat, 25 Jun 2016 00:25:01 +0800
Message-ID: <1466785501.13259.1.camel@ingics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pramod Kumar <pramod.kumar@broadcom.com>,
	Jon Mason <jonmason@broadcom.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36362 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbcFXQZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 12:25:08 -0400
Received: by mail-pa0-f67.google.com with SMTP id av7so3301488pac.3
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 09:25:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By setting phy_set_drvdata(phy, mdiodev), struct ns2_pci_phy can be
removed.

Signed-off-by: Axel Lin <axel.lin@ingics.com>
---
I don't have this h/w. Appreciate if someone can test this patch serial.
 drivers/phy/phy-bcm-ns2-pcie.c | 25 +++++--------------------
 1 file changed, 5 insertions(+), 20 deletions(-)

diff --git a/drivers/phy/phy-bcm-ns2-pcie.c b/drivers/phy/phy-bcm-ns2-pcie.c
index 9513f7a..ee61772 100644
--- a/drivers/phy/phy-bcm-ns2-pcie.c
+++ b/drivers/phy/phy-bcm-ns2-pcie.c
@@ -18,11 +18,6 @@
 #include <linux/phy.h>
 #include <linux/phy/phy.h>
 
-struct ns2_pci_phy {
-	struct mdio_device *mdiodev;
-	struct phy *phy;
-};
-
 #define BLK_ADDR_REG_OFFSET	0x1f
 #define PLL_AFE1_100MHZ_BLK	0x2100
 #define PLL_CLK_AMP_OFFSET	0x03
@@ -30,17 +25,17 @@ struct ns2_pci_phy {
 
 static int ns2_pci_phy_init(struct phy *p)
 {
-	struct ns2_pci_phy *phy = phy_get_drvdata(p);
+	struct mdio_device *mdiodev = phy_get_drvdata(p);
 	int rc;
 
 	/* select the AFE 100MHz block page */
-	rc = mdiobus_write(phy->mdiodev->bus, phy->mdiodev->addr,
+	rc = mdiobus_write(mdiodev->bus, mdiodev->addr,
 			   BLK_ADDR_REG_OFFSET, PLL_AFE1_100MHZ_BLK);
 	if (rc)
 		goto err;
 
 	/* set the 100 MHz reference clock amplitude to 2.05 v */
-	rc = mdiobus_write(phy->mdiodev->bus, phy->mdiodev->addr,
+	rc = mdiobus_write(mdiodev->bus, mdiodev->addr,
 			   PLL_CLK_AMP_OFFSET, PLL_CLK_AMP_2P05V);
 	if (rc)
 		goto err;
@@ -48,7 +43,7 @@ static int ns2_pci_phy_init(struct phy *p)
 	return 0;
 
 err:
-	dev_err(&phy->mdiodev->dev, "Error %d writing to phy\n", rc);
+	dev_err(&mdiodev->dev, "Error %d writing to phy\n", rc);
 	return rc;
 }
 
@@ -60,7 +55,6 @@ static int ns2_pci_phy_probe(struct mdio_device *mdiodev)
 {
 	struct device *dev = &mdiodev->dev;
 	struct phy_provider *provider;
-	struct ns2_pci_phy *p;
 	struct phy *phy;
 
 	phy = devm_phy_create(dev, dev->of_node, &ns2_pci_phy_ops);
@@ -69,16 +63,7 @@ static int ns2_pci_phy_probe(struct mdio_device *mdiodev)
 		return PTR_ERR(phy);
 	}
 
-	p = devm_kmalloc(dev, sizeof(struct ns2_pci_phy),
-			 GFP_KERNEL);
-	if (!p)
-		return -ENOMEM;
-
-	p->mdiodev = mdiodev;
-	dev_set_drvdata(dev, p);
-
-	p->phy = phy;
-	phy_set_drvdata(phy, p);
+	phy_set_drvdata(phy, mdiodev);
 
 	provider = devm_of_phy_provider_register(&phy->dev,
 						 of_phy_simple_xlate);
-- 
2.5.0
