From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 1/8] net/macb: check all address registers sets
Date: Wed,  7 Nov 2012 19:14:50 +0100
Message-ID: <1352312097-31320-2-git-send-email-manabian@gmail.com>
References: <1352312097-31320-1-git-send-email-manabian@gmail.com>
Cc: plagnioj@jcrosoft.com, netdev@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:60048 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043Ab2KGSPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 13:15:14 -0500
Received: by mail-lb0-f174.google.com with SMTP id n3so1512078lbo.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 10:15:13 -0800 (PST)
In-Reply-To: <1352312097-31320-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macb driver in u-boot uses the first register set while
the at91_ether driver in u-boot uses the second register set.

By checking all register set, like at91_ether does, this code
can be shared between the drivers.

This only changes behavior on macb if no vaild address
is found in the first register set.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 13c3c33..3b609be 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -114,23 +114,28 @@ static void __init macb_get_hwaddr(struct macb *bp)
 	u32 bottom;
 	u16 top;
 	u8 addr[6];
+	int i;
 
-	bottom = macb_or_gem_readl(bp, SA1B);
-	top = macb_or_gem_readl(bp, SA1T);
-
-	addr[0] = bottom & 0xff;
-	addr[1] = (bottom >> 8) & 0xff;
-	addr[2] = (bottom >> 16) & 0xff;
-	addr[3] = (bottom >> 24) & 0xff;
-	addr[4] = top & 0xff;
-	addr[5] = (top >> 8) & 0xff;
-
-	if (is_valid_ether_addr(addr)) {
-		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
-	} else {
-		netdev_info(bp->dev, "invalid hw address, using random\n");
-		eth_hw_addr_random(bp->dev);
+	/* Check all 4 address register for vaild address */
+	for (i = 0; i < 4; i++) {
+		bottom = macb_or_gem_readl(bp, SA1B + i * 8);
+		top = macb_or_gem_readl(bp, SA1T + i * 8);
+
+		addr[0] = bottom & 0xff;
+		addr[1] = (bottom >> 8) & 0xff;
+		addr[2] = (bottom >> 16) & 0xff;
+		addr[3] = (bottom >> 24) & 0xff;
+		addr[4] = top & 0xff;
+		addr[5] = (top >> 8) & 0xff;
+
+		if (is_valid_ether_addr(addr)) {
+			memcpy(bp->dev->dev_addr, addr, sizeof(addr));
+			return;
+		}
 	}
+
+	netdev_info(bp->dev, "invalid hw address, using random\n");
+	eth_hw_addr_random(bp->dev);
 }
 
 static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
-- 
1.8.0
