From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 04/13] via-velocity: use netdev_alloc_skb
Date: Wed, 16 Apr 2008 16:37:31 -0700
Message-ID: <20080416233757.241708328@vyatta.com>
References: <20080416233727.732025083@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:43788 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753015AbYDPXt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 19:49:28 -0400
Content-Disposition: inline; filename=via-velocity
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_skb for rx buffer allocation. This sets skb->dev
and can be overriden for NUMA machines.

Change code to return new buffer rather than call by reference.

Compile tested only!

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/via-velocity.c	2008-04-02 10:55:31.000000000 -0700
+++ b/drivers/net/via-velocity.c	2008-04-16 16:20:44.000000000 -0700
@@ -1490,24 +1490,18 @@ static inline void velocity_rx_csum(stru
  *	enough. This function returns a negative value if the received
  *	packet is too big or if memory is exhausted.
  */
-static inline int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size,
-				   struct velocity_info *vptr)
+static int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size,
+			    struct velocity_info *vptr)
 {
 	int ret = -1;
-
 	if (pkt_size < rx_copybreak) {
 		struct sk_buff *new_skb;
 
-		new_skb = dev_alloc_skb(pkt_size + 2);
+		new_skb = netdev_alloc_skb(vptr->dev, pkt_size + 2);
 		if (new_skb) {
-			new_skb->dev = vptr->dev;
 			new_skb->ip_summed = rx_skb[0]->ip_summed;
-
-			if (vptr->flags & VELOCITY_FLAGS_IP_ALIGN)
-				skb_reserve(new_skb, 2);
-
-			skb_copy_from_linear_data(rx_skb[0], new_skb->data,
-						  pkt_size);
+			skb_reserve(new_skb, 2);
+			skb_copy_from_linear_data(*rx_skb, new_skb->data, pkt_size);
 			*rx_skb = new_skb;
 			ret = 0;
 		}
@@ -1619,7 +1613,7 @@ static int velocity_alloc_rx_buf(struct 
 	struct rx_desc *rd = &(vptr->rd_ring[idx]);
 	struct velocity_rd_info *rd_info = &(vptr->rd_info[idx]);
 
-	rd_info->skb = dev_alloc_skb(vptr->rx_buf_sz + 64);
+	rd_info->skb = netdev_alloc_skb(vptr->dev, vptr->rx_buf_sz + 64);
 	if (rd_info->skb == NULL)
 		return -ENOMEM;
 
@@ -1628,7 +1622,6 @@ static int velocity_alloc_rx_buf(struct 
 	 *	64byte alignment.
 	 */
 	skb_reserve(rd_info->skb, (unsigned long) rd_info->skb->data & 63);
-	rd_info->skb->dev = vptr->dev;
 	rd_info->skb_dma = pci_map_single(vptr->pdev, rd_info->skb->data, vptr->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
 	/*

-- 

