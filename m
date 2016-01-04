From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 09/24] phy: mdio-octeon: Use devm_mdiobus_alloc_size()
Date: Mon,  4 Jan 2016 18:36:47 +0100
Message-ID: <1451929022-5580-10-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34948 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752733AbcADRhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:37:38 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than use devm_kzalloc(), use the mdio helper function.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/mdio-octeon.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index fcf4e4df7cc8..0d5da1312dd3 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -268,12 +268,13 @@ static int octeon_mdiobus_write(struct mii_bus *bus, int phy_id,
 static int octeon_mdiobus_probe(struct platform_device *pdev)
 {
 	struct octeon_mdiobus *bus;
+	struct mii_bus *mii_bus;
 	struct resource *res_mem;
 	union cvmx_smix_en smi_en;
 	int err = -ENOENT;
 
-	bus = devm_kzalloc(&pdev->dev, sizeof(*bus), GFP_KERNEL);
-	if (!bus)
+	mii_bus = devm_mdiobus_alloc_size(&pdev->dev, sizeof(*bus));
+	if (!mii_bus)
 		return -ENOMEM;
 
 	res_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -282,6 +283,8 @@ static int octeon_mdiobus_probe(struct platform_device *pdev)
 		return -ENXIO;
 	}
 
+	bus = mii_bus->priv;
+	bus->mii_bus = mii_bus;
 	bus->mdio_phys = res_mem->start;
 	bus->regsize = resource_size(res_mem);
 
@@ -298,10 +301,6 @@ static int octeon_mdiobus_probe(struct platform_device *pdev)
 		return -ENOMEM;
 	}
 
-	bus->mii_bus = mdiobus_alloc();
-	if (!bus->mii_bus)
-		goto fail;
-
 	smi_en.u64 = 0;
 	smi_en.s.en = 1;
 	oct_mdio_writeq(smi_en.u64, bus->register_base + SMI_EN);
@@ -326,7 +325,6 @@ static int octeon_mdiobus_probe(struct platform_device *pdev)
 	return 0;
 fail_register:
 	mdiobus_free(bus->mii_bus);
-fail:
 	smi_en.u64 = 0;
 	oct_mdio_writeq(smi_en.u64, bus->register_base + SMI_EN);
 	return err;
-- 
2.6.4
