From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 21/39] mv643xx_eth: move port_receive() into its only caller
Date: Tue,  3 Jun 2008 13:02:36 +0200
Message-ID: <1212490974-23719-22-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48757 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754947AbYFCMAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:30 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The port_receive() function is a remnant of the original mv643xx_eth
HAL split.  This patch moves port_receive() into its caller, so that
the top and the bottom half of RX processing no longer communicate
via the HAL FUNC_RET_STATUS/pkt_info mechanism abstraction anymore.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   91 ++++++++++++++++-----------------------------
 1 files changed, 32 insertions(+), 59 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 15a17e2..2fac2b6 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -509,64 +509,38 @@ static inline void mv643xx_eth_rx_refill_descs_timer_wrapper(unsigned long data)
 	mv643xx_eth_rx_refill_descs((struct net_device *)data);
 }
 
-static FUNC_RET_STATUS port_receive(struct mv643xx_eth_private *mep,
-						struct pkt_info *pkt_info)
+static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 {
-	int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
-	volatile struct rx_desc *rx_desc;
-	unsigned int command_status;
-	unsigned long flags;
-
-	spin_lock_irqsave(&mep->lock, flags);
-
-	/* Get the Rx Desc ring 'curr and 'used' indexes */
-	rx_curr_desc = mep->rx_curr_desc;
-	rx_used_desc = mep->rx_used_desc;
-
-	rx_desc = &mep->rx_desc_area[rx_curr_desc];
-
-	/* The following parameters are used to save readings from memory */
-	command_status = rx_desc->cmd_sts;
-	rmb();
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	unsigned int received_packets = 0;
 
-	/* Nothing to receive... */
-	if (command_status & BUFFER_OWNED_BY_DMA) {
-		spin_unlock_irqrestore(&mep->lock, flags);
-		return ETH_END_OF_JOB;
-	}
+	while (budget-- > 0) {
+		struct sk_buff *skb;
+		volatile struct rx_desc *rx_desc;
+		unsigned int cmd_sts;
+		unsigned long flags;
 
-	pkt_info->byte_cnt = rx_desc->byte_cnt - ETH_HW_IP_ALIGN;
-	pkt_info->cmd_sts = command_status;
-	pkt_info->buf_ptr = rx_desc->buf_ptr + ETH_HW_IP_ALIGN;
-	pkt_info->return_info = mep->rx_skb[rx_curr_desc];
-	pkt_info->l4i_chk = rx_desc->buf_size;
+		spin_lock_irqsave(&mep->lock, flags);
 
-	/*
-	 * Clean the return info field to indicate that the
-	 * packet has been moved to the upper layers
-	 */
-	mep->rx_skb[rx_curr_desc] = NULL;
+		rx_desc = &mep->rx_desc_area[mep->rx_curr_desc];
 
-	/* Update current index in data structure */
-	rx_next_curr_desc = (rx_curr_desc + 1) % mep->rx_ring_size;
-	mep->rx_curr_desc = rx_next_curr_desc;
+		cmd_sts = rx_desc->cmd_sts;
+		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
+			spin_unlock_irqrestore(&mep->lock, flags);
+			break;
+		}
+		rmb();
 
-	spin_unlock_irqrestore(&mep->lock, flags);
+		skb = mep->rx_skb[mep->rx_curr_desc];
+		mep->rx_skb[mep->rx_curr_desc] = NULL;
 
-	return ETH_OK;
-}
+		mep->rx_curr_desc = (mep->rx_curr_desc + 1) % mep->rx_ring_size;
 
-static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
-{
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
-	unsigned int received_packets = 0;
-	struct sk_buff *skb;
-	struct pkt_info pkt_info;
+		spin_unlock_irqrestore(&mep->lock, flags);
 
-	while (budget-- > 0 && port_receive(mep, &pkt_info) == ETH_OK) {
-		dma_unmap_single(NULL, pkt_info.buf_ptr, ETH_RX_SKB_SIZE,
-							DMA_FROM_DEVICE);
+		dma_unmap_single(NULL, rx_desc->buf_ptr + ETH_HW_IP_ALIGN,
+					ETH_RX_SKB_SIZE, DMA_FROM_DEVICE);
 		mep->rx_desc_count--;
 		received_packets++;
 
@@ -575,18 +549,17 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 		 * Note byte count includes 4 byte CRC count
 		 */
 		stats->rx_packets++;
-		stats->rx_bytes += pkt_info.byte_cnt;
-		skb = pkt_info.return_info;
+		stats->rx_bytes += rx_desc->byte_cnt - ETH_HW_IP_ALIGN;
+
 		/*
 		 * In case received a packet without first / last bits on OR
 		 * the error summary bit is on, the packets needs to be dropeed.
 		 */
-		if (((pkt_info.cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
+		if (((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
 					(RX_FIRST_DESC | RX_LAST_DESC))
-				|| (pkt_info.cmd_sts & ERROR_SUMMARY)) {
+				|| (cmd_sts & ERROR_SUMMARY)) {
 			stats->rx_dropped++;
-			if ((pkt_info.cmd_sts & (RX_FIRST_DESC |
-							RX_LAST_DESC)) !=
+			if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
 				(RX_FIRST_DESC | RX_LAST_DESC)) {
 				if (net_ratelimit())
 					printk(KERN_ERR
@@ -594,7 +567,7 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 						"on multiple descriptors\n",
 						dev->name);
 			}
-			if (pkt_info.cmd_sts & ERROR_SUMMARY)
+			if (cmd_sts & ERROR_SUMMARY)
 				stats->rx_errors++;
 
 			dev_kfree_skb_irq(skb);
@@ -603,12 +576,12 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 			 * The -4 is for the CRC in the trailer of the
 			 * received packet
 			 */
-			skb_put(skb, pkt_info.byte_cnt - 4);
+			skb_put(skb, rx_desc->byte_cnt - ETH_HW_IP_ALIGN - 4);
 
-			if (pkt_info.cmd_sts & LAYER_4_CHECKSUM_OK) {
+			if (cmd_sts & LAYER_4_CHECKSUM_OK) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 				skb->csum = htons(
-					(pkt_info.cmd_sts & 0x0007fff8) >> 3);
+					(cmd_sts & 0x0007fff8) >> 3);
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 #ifdef MV643XX_ETH_NAPI
-- 
1.5.3.4

