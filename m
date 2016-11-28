From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [PATCH] net: macb: Write only necessary bits in NCR in macb reset
Date: Mon, 28 Nov 2016 14:53:49 +0530
Message-ID: <1480325029-39224-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <harinik@xilinx.com>, <michals@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
        <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In macb_reset_hw, use read-modify-write to disable RX and TX.
This way exiting settings and reserved bits wont be disturbed.
Use the same method for clearing statistics as well.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 0e489bb..80ccfc4 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1743,15 +1743,18 @@ static void macb_init_rings(struct macb *bp)
 static void macb_reset_hw(struct macb *bp)
 {
 	struct macb_queue *queue;
-	unsigned int q;
+	unsigned int q, ctrl;
 
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
