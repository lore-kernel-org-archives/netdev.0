From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 2/3] net/macb: add support for phy irq via gpio pin
Date: Sun, 11 Nov 2012 23:23:26 +0100
Message-ID: <1352672607-12793-3-git-send-email-manabian@gmail.com>
References: <1352672607-12793-1-git-send-email-manabian@gmail.com>
Cc: plagnioj@jcrosoft.com, netdev@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:42020 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351Ab2KKWYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 17:24:00 -0500
Received: by mail-la0-f46.google.com with SMTP id h6so4139350lag.19
        for <netdev@vger.kernel.org>; Sun, 11 Nov 2012 14:24:00 -0800 (PST)
In-Reply-To: <1352672607-12793-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 1fac769..ca34efc 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -16,6 +16,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/init.h>
+#include <linux/gpio.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -261,7 +262,9 @@ static void macb_handle_link_change(struct net_device *dev)
 static int macb_mii_probe(struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
+	struct macb_platform_data *pdata;
 	struct phy_device *phydev;
+	int phy_irq;
 	int ret;
 
 	phydev = phy_find_first(bp->mii_bus);
@@ -270,7 +273,14 @@ static int macb_mii_probe(struct net_device *dev)
 		return -1;
 	}
 
-	/* TODO : add pin_irq */
+	pdata = dev_get_platdata(&bp->pdev->dev);
+	if (pdata && gpio_is_valid(pdata->phy_irq_pin)) {
+		ret = devm_gpio_request(&bp->pdev->dev, pdata->phy_irq_pin, "phy int");
+		if (!ret) {
+			phy_irq = gpio_to_irq(pdata->phy_irq_pin);
+			phydev->irq = (phy_irq < 0) ? PHY_POLL : phy_irq;
+		}
+	}
 
 	/* attach the mac to the phy */
 	ret = phy_connect_direct(dev, phydev, &macb_handle_link_change, 0,
-- 
1.8.0
