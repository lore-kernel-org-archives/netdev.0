From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 5/5] mv643xx_eth: enforce multiple-of-8-bytes receive buffer size restriction
Date: Sun, 24 Aug 2008 04:06:02 +0200
Message-ID: <20080824020602.GF8762@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>, Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:57616 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbYHXCGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 22:06:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv643xx_eth hardware ignores the lower three bits of the buffer
size field in receive descriptors, causing the reception of full-sized
packets to fail at some MTUs.  Fix this by rounding the size of
allocated receive buffers up to a multiple of eight bytes.

While we are at it, add a bit of extra space to each receive buffer so
that we can handle multiple vlan tags on ingress.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index e33dfc0..a02a5f4 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -474,11 +474,19 @@ static void rxq_refill(struct rx_queue *rxq)
 		/*
 		 * Reserve 2+14 bytes for an ethernet header (the
 		 * hardware automatically prepends 2 bytes of dummy
-		 * data to each received packet), 4 bytes for a VLAN
-		 * header, and 4 bytes for the trailing FCS -- 24
-		 * bytes total.
+		 * data to each received packet), 16 bytes for up to
+		 * four VLAN tags, and 4 bytes for the trailing FCS
+		 * -- 36 bytes total.
 		 */
-		skb_size = mp->dev->mtu + 24;
+		skb_size = mp->dev->mtu + 36;
+
+		/*
+		 * Make sure that the skb size is a multiple of 8
+		 * bytes, as the lower three bits of the receive
+		 * descriptor's buffer size field are ignored by
+		 * the hardware.
+		 */
+		skb_size = (skb_size + 7) & ~7;
 
 		skb = dev_alloc_skb(skb_size + dma_get_cache_alignment() - 1);
 		if (skb == NULL)
@@ -552,7 +560,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		spin_unlock_irqrestore(&mp->lock, flags);
 
 		dma_unmap_single(NULL, rx_desc->buf_ptr + 2,
-				 mp->dev->mtu + 24, DMA_FROM_DEVICE);
+				 rx_desc->buf_size, DMA_FROM_DEVICE);
 		rxq->rx_desc_count--;
 		rx++;
 
-- 
1.5.6.4
