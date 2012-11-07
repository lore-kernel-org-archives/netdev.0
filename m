From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 2/8] net/macb: support reversed hw addr
Date: Wed,  7 Nov 2012 19:14:51 +0100
Message-ID: <1352312097-31320-3-git-send-email-manabian@gmail.com>
References: <1352312097-31320-1-git-send-email-manabian@gmail.com>
Cc: plagnioj@jcrosoft.com, netdev@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:36135 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732Ab2KGSPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 13:15:15 -0500
Received: by mail-lb0-f174.google.com with SMTP id n3so1512096lbo.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 10:15:14 -0800 (PST)
In-Reply-To: <1352312097-31320-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is used on one AT91RM9200 board where a bootloader stores
the Ethernet address in the wrong order.

Support this on macb so address setting functions can be shared
with the at91_ether driver.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 3b609be..a9e5a50 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -111,22 +111,34 @@ static void __macb_set_hwaddr(struct macb *bp)
 
 static void __init macb_get_hwaddr(struct macb *bp)
 {
+	struct macb_platform_data *pdata;
 	u32 bottom;
 	u16 top;
 	u8 addr[6];
 	int i;
 
+	pdata = bp->pdev->dev.platform_data;
+
 	/* Check all 4 address register for vaild address */
 	for (i = 0; i < 4; i++) {
 		bottom = macb_or_gem_readl(bp, SA1B + i * 8);
 		top = macb_or_gem_readl(bp, SA1T + i * 8);
 
-		addr[0] = bottom & 0xff;
-		addr[1] = (bottom >> 8) & 0xff;
-		addr[2] = (bottom >> 16) & 0xff;
-		addr[3] = (bottom >> 24) & 0xff;
-		addr[4] = top & 0xff;
-		addr[5] = (top >> 8) & 0xff;
+		if (pdata && pdata->rev_eth_addr) {
+			addr[5] = bottom & 0xff;
+			addr[4] = (bottom >> 8) & 0xff;
+			addr[3] = (bottom >> 16) & 0xff;
+			addr[2] = (bottom >> 24) & 0xff;
+			addr[1] = top & 0xff;
+			addr[0] = (top & 0xff00) >> 8;
+		} else {
+			addr[0] = bottom & 0xff;
+			addr[1] = (bottom >> 8) & 0xff;
+			addr[2] = (bottom >> 16) & 0xff;
+			addr[3] = (bottom >> 24) & 0xff;
+			addr[4] = top & 0xff;
+			addr[5] = (top >> 8) & 0xff;
+		}
 
 		if (is_valid_ether_addr(addr)) {
 			memcpy(bp->dev->dev_addr, addr, sizeof(addr));
-- 
1.8.0
