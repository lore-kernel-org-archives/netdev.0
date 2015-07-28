From: mohun106@gmail.com
Subject: [PATCH v2 2/3] net: mdio-octeon: Fix octeon_mdiobus_probe function for return values
Date: Tue, 28 Jul 2015 15:12:12 -0700
Message-ID: <1438121533-21528-3-git-send-email-mohun106@gmail.com>
References: <1438121533-21528-1-git-send-email-mohun106@gmail.com>
Cc: ddaney@caviumnetworks.com, sgoutham@caviumnetworks.com,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	Tomasz Nowicki <tomasz.nowicki@linaro.org>
To: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35923 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615AbbG1WM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:12:27 -0400
In-Reply-To: <1438121533-21528-1-git-send-email-mohun106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>

This patch fixes a possible crash in the octeon_mdiobus_probe function
if the return values are not handled properly.

Signed-off-by: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
Signed-off-by: Tomasz Nowicki <tomasz.nowicki@linaro.org>
---
 drivers/net/phy/mdio-octeon.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index 1509937..fcf4e4d 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -277,24 +277,28 @@ static int octeon_mdiobus_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	res_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-
 	if (res_mem == NULL) {
 		dev_err(&pdev->dev, "found no memory resource\n");
-		err = -ENXIO;
-		goto fail;
+		return -ENXIO;
 	}
+
 	bus->mdio_phys = res_mem->start;
 	bus->regsize = resource_size(res_mem);
+
 	if (!devm_request_mem_region(&pdev->dev, bus->mdio_phys, bus->regsize,
 				     res_mem->name)) {
 		dev_err(&pdev->dev, "request_mem_region failed\n");
-		goto fail;
+		return -ENXIO;
 	}
+
 	bus->register_base =
 		(u64)devm_ioremap(&pdev->dev, bus->mdio_phys, bus->regsize);
+	if (!bus->register_base) {
+		dev_err(&pdev->dev, "dev_ioremap failed\n");
+		return -ENOMEM;
+	}
 
 	bus->mii_bus = mdiobus_alloc();
-
 	if (!bus->mii_bus)
 		goto fail;
 
-- 
1.7.1
