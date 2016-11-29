From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [PATCH v2] net: macb: Write only necessary bits in NCR in macb reset
Date: Tue, 29 Nov 2016 11:26:25 +0530
Message-ID: <1480398985-24037-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <harinik@xilinx.com>, <michals@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
        <harinikatakamlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0051.outbound.protection.outlook.com ([104.47.37.51]:3808
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752592AbcK2F4r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 00:56:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In macb_reset_hw, use read-modify-write to disable RX and TX.
Existing settings, for ex. management port enable,
are being cleared in the current implementation.
Also certain reserved bits are read only.
Hence it is better to use read-modify-write.
Use the same method for clearing statistics as well.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
---

v2:
Make ctrl type as u32
Improve commit description

---
 drivers/net/ethernet/cadence/macb.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 0e489bb..2ce3407 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1744,14 +1744,18 @@ static void macb_reset_hw(struct macb *bp)
 {
 	struct macb_queue *queue;
 	unsigned int q;
+	u32 ctrl;
 
 	/* Disable RX and TX (XXX: Should we halt the transmission
 	 * more gracefully?)
 	 */
-	macb_writel(bp, NCR, 0);
+	ctrl = macb_readl(bp, NCR);
+	ctrl &= ~(MACB_BIT(RE) | MACB_BIT(TE));
+	macb_writel(bp, NCR, ctrl);
 
 	/* Clear the stats registers (XXX: Update stats first?) */
-	macb_writel(bp, NCR, MACB_BIT(CLRSTAT));
+	ctrl |= MACB_BIT(CLRSTAT);
+	macb_writel(bp, NCR, ctrl);
 
 	/* Clear all status flags */
 	macb_writel(bp, TSR, -1);
-- 
2.7.4
