From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] pch_gbe: Fix the checksum fill to the error
 location
Date: Tue, 17 Jul 2012 09:33:07 +0200
Message-ID: <1342510387.2626.174.camel@edumazet-glaptop>
References: <40680C535D6FE6498883F1640FACD44D011432D4@ka-exchange-1.kontronamerica.local>
	 <1342508968.2626.148.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Zhong Hongbo <hongbo.zhong@windriver.com>
To: Andy Cress <andy.cress@us.kontron.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60612 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764Ab2GQHdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 03:33:12 -0400
Received: by eaak11 with SMTP id k11so29856eaa.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 00:33:10 -0700 (PDT)
In-Reply-To: <1342508968.2626.148.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 09:09 +0200, Eric Dumazet wrote:

> Hmm... I fail to understand why you care about NIC doing checksums,
> while pch_gbe_tx_queue() make a _copy_ of each outgoing
> packets.
> 
> There _must_ be a way to avoid most of these copies (ie not touching
> payload), only mess with the header to insert these 2 nul bytes ?
> 
> /* [Header:14][payload] ---> [Header:14][paddong:2][payload]    */
> 
> So at device setup : dev->needed_headroom = 2;
> 
> and in xmit,
> 
> 	if (skb_headroom(skb) < 2) {
> 		struct sk_buff *skb_new;
> 
> 		skb_new = skb_realloc_headroom(skb, 2);
> 		if (!skb_new) { handle error }
> 		consume_skb(skb);
> 		skb = skb_new;
> 	}
> 	ptr = skb_push(skb, 2);
> 	memmove(ptr, ptr + 2, ETH_HLEN);
> 	ptr[ETH_HLEN] = 0;
> 	ptr[ETH_HLEN + 1] = 0;
> 
> 

Something like the following (untested) patch


 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c |   55 +++++-----
 1 file changed, 29 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index b100656..2d3d982 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1163,7 +1163,7 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 	struct pch_gbe_hw *hw = &adapter->hw;
 	struct pch_gbe_tx_desc *tx_desc;
 	struct pch_gbe_buffer *buffer_info;
-	struct sk_buff *tmp_skb;
+	char *ptr;
 	unsigned int frame_ctrl;
 	unsigned int ring_num;
 
@@ -1221,18 +1221,27 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 
 
 	buffer_info = &tx_ring->buffer_info[ring_num];
-	tmp_skb = buffer_info->skb;
+	if (skb_headroom(skb) < 2) {
+		struct sk_buff *skb_new;
+
+		skb_new = skb_realloc_headroom(skb, 2);
+		if (!skb_new) {
+			tx_ring->next_to_use = ring_num;
+			dev_kfree_skb_any(skb);
+			return;
+		}
+		consume_skb(skb);
+		skb = skb_new;
+	}
 
 	/* [Header:14][payload] ---> [Header:14][paddong:2][payload]    */
-	memcpy(tmp_skb->data, skb->data, ETH_HLEN);
-	tmp_skb->data[ETH_HLEN] = 0x00;
-	tmp_skb->data[ETH_HLEN + 1] = 0x00;
-	tmp_skb->len = skb->len;
-	memcpy(&tmp_skb->data[ETH_HLEN + 2], &skb->data[ETH_HLEN],
-	       (skb->len - ETH_HLEN));
+	ptr = skb_push(skb, 2);
+	memmove(ptr, ptr + 2, ETH_HLEN);
+	ptr[ETH_HLEN] = 0x00;
+	ptr[ETH_HLEN + 1] = 0x00;
 	/*-- Set Buffer information --*/
-	buffer_info->length = tmp_skb->len;
-	buffer_info->dma = dma_map_single(&adapter->pdev->dev, tmp_skb->data,
+	buffer_info->length = skb->len;
+	buffer_info->dma = dma_map_single(&adapter->pdev->dev, skb->data,
 					  buffer_info->length,
 					  DMA_TO_DEVICE);
 	if (dma_mapping_error(&adapter->pdev->dev, buffer_info->dma)) {
@@ -1240,18 +1249,20 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 		buffer_info->dma = 0;
 		buffer_info->time_stamp = 0;
 		tx_ring->next_to_use = ring_num;
+		dev_kfree_skb_any(skb);
 		return;
 	}
 	buffer_info->mapped = true;
 	buffer_info->time_stamp = jiffies;
+	buffer_info->skb = skb;
 
 	/*-- Set Tx descriptor --*/
 	tx_desc = PCH_GBE_TX_DESC(*tx_ring, ring_num);
-	tx_desc->buffer_addr = (buffer_info->dma);
-	tx_desc->length = (tmp_skb->len);
-	tx_desc->tx_words_eob = ((tmp_skb->len + 3));
+	tx_desc->buffer_addr = buffer_info->dma;
+	tx_desc->length = skb->len;
+	tx_desc->tx_words_eob = skb->len + 3;
 	tx_desc->tx_frame_ctrl = (frame_ctrl);
-	tx_desc->gbec_status = (DSC_INIT16);
+	tx_desc->gbec_status = DSC_INIT16;
 
 	if (unlikely(++ring_num == tx_ring->count))
 		ring_num = 0;
@@ -1265,7 +1276,6 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 	pch_tx_timestamp(adapter, skb);
 #endif
 
-	dev_kfree_skb_any(skb);
 }
 
 /**
@@ -1543,19 +1553,12 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
 					struct pch_gbe_tx_ring *tx_ring)
 {
 	struct pch_gbe_buffer *buffer_info;
-	struct sk_buff *skb;
 	unsigned int i;
-	unsigned int bufsz;
 	struct pch_gbe_tx_desc *tx_desc;
 
-	bufsz =
-	    adapter->hw.mac.max_frame_size + PCH_GBE_DMA_ALIGN + NET_IP_ALIGN;
-
 	for (i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
-		skb = netdev_alloc_skb(adapter->netdev, bufsz);
-		skb_reserve(skb, PCH_GBE_DMA_ALIGN);
-		buffer_info->skb = skb;
+		buffer_info->skb = NULL;
 		tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
 		tx_desc->gbec_status = (DSC_INIT16);
 	}
@@ -1622,9 +1625,9 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 					 buffer_info->length, DMA_TO_DEVICE);
 			buffer_info->mapped = false;
 		}
-		if (buffer_info->skb) {
-			pr_debug("trim buffer_info->skb : %d\n", i);
-			skb_trim(buffer_info->skb, 0);
+		if (skb) {
+			dev_kfree_skb_any(skb);
+			buffer_info->skb = NULL;
 		}
 		tx_desc->gbec_status = DSC_INIT16;
 		if (unlikely(++i == tx_ring->count))
