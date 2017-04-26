From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: [PATCH] net: macb: fix phy interrupt parsing
Date: Wed, 26 Apr 2017 12:06:28 +0200
Message-ID: <20170426100628.14493-1-alexandre.belloni@free-electrons.com>
Cc: Bartosz Folta <bfolta@cadence.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Nicolas Ferre <nicolas.ferre@microchip.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:44568 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2997060AbdDZKGq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 06:06:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 83a77e9ec415, the phydev irq is explicitly set to PHY_POLL when
there is no pdata. It doesn't work on DT enabled platforms because the
phydev irq is already set by libphy before.

Fixes: 83a77e9ec415 ("net: macb: Added PCI wrapper for Platform Driver.")
Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
---
 drivers/net/ethernet/cadence/macb.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e131ecd17ab9..004223a866fe 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -432,15 +432,17 @@ static int macb_mii_probe(struct net_device *dev)
 	}
 
 	pdata = dev_get_platdata(&bp->pdev->dev);
-	if (pdata && gpio_is_valid(pdata->phy_irq_pin)) {
-		ret = devm_gpio_request(&bp->pdev->dev, pdata->phy_irq_pin,
-					"phy int");
-		if (!ret) {
-			phy_irq = gpio_to_irq(pdata->phy_irq_pin);
-			phydev->irq = (phy_irq < 0) ? PHY_POLL : phy_irq;
+	if (pdata) {
+		if (gpio_is_valid(pdata->phy_irq_pin)) {
+			ret = devm_gpio_request(&bp->pdev->dev,
+						pdata->phy_irq_pin, "phy int");
+			if (!ret) {
+				phy_irq = gpio_to_irq(pdata->phy_irq_pin);
+				phydev->irq = (phy_irq < 0) ? PHY_POLL : phy_irq;
+			}
+		} else {
+			phydev->irq = PHY_POLL;
 		}
-	} else {
-		phydev->irq = PHY_POLL;
 	}
 
 	/* attach the mac to the phy */
-- 
2.11.0
