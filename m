From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH 5/5] net: macb: Fix race between HW and driver
Date: Sun,  4 May 2014 15:43:02 -0700
Message-ID: <1399243382-12528-6-git-send-email-soren.brinkmann@xilinx.com>
References: <1399243382-12528-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	git@xilinx.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Michal Simek <michal.simek@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:47105 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905AbaEDWof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 18:44:35 -0400
In-Reply-To: <1399243382-12528-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under "heavy" RX load, the driver cannot handle the descriptors fast
enough. In detail, when a descriptor is consumed, its used flag is
cleared and once the RX budget is consumed all descriptors with a
cleared used flag are prepared to receive more data. Under load though,
the HW may constantly receive more data and use those descriptors with a
cleared used flag before they are actually prepared for next usage.

The head and tail pointers into the RX-ring should always be valid and
we can omit clearing and checking of the used flag.

Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
---

---
 drivers/net/ethernet/cadence/macb.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 3e13aa31548a..e9daa072ebb4 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -599,25 +599,16 @@ static void gem_rx_refill(struct macb *bp)
 {
 	unsigned int		entry;
 	struct sk_buff		*skb;
-	struct macb_dma_desc	*desc;
 	dma_addr_t		paddr;
 
 	while (CIRC_SPACE(bp->rx_prepared_head, bp->rx_tail, RX_RING_SIZE) > 0) {
-		u32 addr, ctrl;
-
 		entry = macb_rx_ring_wrap(bp->rx_prepared_head);
-		desc = &bp->rx_ring[entry];
 
 		/* Make hw descriptor updates visible to CPU */
 		rmb();
 
-		addr = desc->addr;
-		ctrl = desc->ctrl;
 		bp->rx_prepared_head++;
 
-		if ((addr & MACB_BIT(RX_USED)))
-			continue;
-
 		if (bp->rx_skbuff[entry] == NULL) {
 			/* allocate sk_buff for this free entry in ring */
 			skb = netdev_alloc_skb(bp->dev, bp->rx_buffer_size);
@@ -698,7 +689,6 @@ static int gem_rx(struct macb *bp, int budget)
 		if (!(addr & MACB_BIT(RX_USED)))
 			break;
 
-		desc->addr &= ~MACB_BIT(RX_USED);
 		bp->rx_tail++;
 		count++;
 
-- 
1.9.2.1.g06c4abd
