From: Neil Armstrong <superna9999@gmail.com>
Subject: [PATCH 2/2 v2] net: macb: Handle errors in RX path
Date: Fri, 18 Jul 2014 12:14:45 +0200
Message-ID: <53C8F395.6050600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In certain circumstances, the MACB fails to write correct RX ring
descriptor, and lead to actually managed by BUG_ON() error cases.

Handle these two cases by returning error values, while resetting
the RX ring and RX HW path in the poll methos.

In the same time, check and handle BNA and OVR into poll method
by using the same error management.

Signed-off-by: Neil Armstrong <narmstrong@neotion.com>
---
 drivers/net/ethernet/cadence/macb.c |   54 +++++++++++++++++++++++++++++++---
 1 files changed, 49 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 20ad483..f88ebc9 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -755,6 +755,17 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 		macb_rx_ring_wrap(first_frag),
 		macb_rx_ring_wrap(last_frag), len);
 
+	if (!(desc->ctrl & MACB_BIT(RX_EOF))) {
+		netdev_vdbg(bp->dev, "macb_rx_frame missing EOF\n");
+		return -EIO;
+	}
+
+	desc = macb_rx_desc(bp, first_frag);
+	if (!(desc->ctrl & MACB_BIT(RX_SOF))) {
+		netdev_vdbg(bp->dev, "macb_rx_frame missing SOF\n");
+		return -EIO;
+	}
+
 	/*
 	 * The ethernet header starts NET_IP_ALIGN bytes into the
 	 * first buffer. Since the header is 14 bytes, this makes the
@@ -789,7 +800,10 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 		unsigned int frag_len = bp->rx_buffer_size;
 
 		if (offset + frag_len > len) {
-			BUG_ON(frag != last_frag);
+			if (frag != last_frag) {
+				dev_kfree_skb_any(skb);
+				return -EIO;
+			}
 			frag_len = len - offset;
 		}
 		skb_copy_to_linear_data_offset(skb, offset,
@@ -844,9 +858,13 @@ static int macb_rx(struct macb *bp, int budget)
 
 		if (ctrl & MACB_BIT(RX_EOF)) {
 			int dropped;
-			BUG_ON(first_frag == -1);
+			if (first_frag == -1)
+				return -EIO;
 
 			dropped = macb_rx_frame(bp, first_frag, tail);
+			if (dropped < 0)
+				return dropped;
+
 			first_frag = -1;
 			if (!dropped) {
 				received++;
@@ -872,12 +890,22 @@ static int macb_poll(struct napi_struct *napi, int budget)
 	status = macb_readl(bp, RSR);
 	macb_writel(bp, RSR, status);
 
-	work_done = 0;
+	work_done = -EIO;
 
 	netdev_vdbg(bp->dev, "poll: status = %08lx, budget = %d\n",
-		   (unsigned long)status, budget);
+			(unsigned long)status, budget);
+
+	if (status & (MACB_BIT(OVR) | MACB_BIT(BNA)) ||
+	    !(status & MACB_BIT(REC))) {
+		netdev_err(bp->dev, "RX error, status = %02lx\n",
+			   (unsigned long)status);
+		goto rx_out;
+	}
 
 	work_done = bp->macbgem_ops.mog_rx(bp, budget);
+	if (work_done < 0)
+		goto rx_out;
+
 	if (work_done < budget) {
 		napi_complete(napi);
 
@@ -892,7 +920,23 @@ static int macb_poll(struct napi_struct *napi, int budget)
 		}
 	}
 
-	/* TODO: Handle errors */
+	return work_done;
+
+rx_out:
+	/* In case of error, disable RX and reset
+	 * the descriptor ring before re-enabling RX.
+	 */
+	macb_writel(bp, NCR, macb_readl(bp, NCR) & ~MACB_BIT(RE));
+
+	bp->macbgem_ops.mog_init_rx_rings(bp);
+	macb_writel(bp, RBQP, bp->rx_ring_dma);
+
+	/* Re-enable RX and get notified for new packets */
+	macb_writel(bp, NCR, macb_readl(bp, NCR) | MACB_BIT(RE));
+
+	napi_complete(napi);
+
+	macb_writel(bp, IER, MACB_RX_INT_FLAGS);
 
 	return work_done;
 }
-- 
1.7.0.4
