From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 3/7] e1000: perform copybreak ahead of dma unmap
Date: Sat, 30 Aug 2014 20:28:23 +0200
Message-ID: <1409423307-23470-4-git-send-email-fw@strlen.de>
References: <1409423307-23470-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43555 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751897AbaH3S24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2014 14:28:56 -0400
In-Reply-To: <1409423307-23470-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we unmap the dma range, then copy to new skb.
Change this so we can keep the mapping in case the data is copied.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 73 ++++++++++++++++-----------
 1 file changed, 43 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index f79ba40..0cb05a5 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4074,6 +4074,16 @@ static bool e1000_tbi_should_accept(struct e1000_adapter *adapter,
 	return false;
 }
 
+static struct sk_buff *e1000_alloc_rx_skb(struct e1000_adapter *adapter,
+					  unsigned int bufsz)
+{
+	struct sk_buff *skb = netdev_alloc_skb_ip_align(adapter->netdev, bufsz);
+
+	if (unlikely(!skb))
+		adapter->alloc_rx_buff_failed++;
+	return skb;
+}
+
 /**
  * e1000_clean_jumbo_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
@@ -4259,25 +4269,25 @@ next_desc:
 /* this should improve performance for small packets with large amounts
  * of reassembly being done in the stack
  */
-static void e1000_check_copybreak(struct net_device *netdev,
-				 struct e1000_buffer *buffer_info,
-				 u32 length, struct sk_buff **skb)
+static struct sk_buff *e1000_copybreak(struct e1000_adapter *adapter,
+				       struct e1000_buffer *buffer_info,
+				       u32 length, const void *data)
 {
-	struct sk_buff *new_skb;
+	struct sk_buff *skb;
 
 	if (length > copybreak)
-		return;
+		return NULL;
 
-	new_skb = netdev_alloc_skb_ip_align(netdev, length);
-	if (!new_skb)
-		return;
+	skb = e1000_alloc_rx_skb(adapter, length);
+	if (!skb)
+		return NULL;
+
+	dma_sync_single_for_cpu(&adapter->pdev->dev, buffer_info->dma,
+				length, DMA_FROM_DEVICE);
+
+	memcpy(skb_put(skb, length), data, length);
 
-	skb_copy_to_linear_data_offset(new_skb, -NET_IP_ALIGN,
-				       (*skb)->data - NET_IP_ALIGN,
-				       length + NET_IP_ALIGN);
-	/* save the skb in buffer_info as good */
-	buffer_info->skb = *skb;
-	*skb = new_skb;
+	return skb;
 }
 
 /**
@@ -4315,10 +4325,18 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
-		skb = buffer_info->skb;
-		buffer_info->skb = NULL;
+		length = le16_to_cpu(rx_desc->length);
 
-		prefetch(skb->data - NET_IP_ALIGN);
+		prefetch(buffer_info->skb->data - NET_IP_ALIGN);
+		skb = e1000_copybreak(adapter, buffer_info, length,
+				      buffer_info->skb->data);
+		if (!skb) {
+			skb = buffer_info->skb;
+			buffer_info->skb = NULL;
+			dma_unmap_single(&pdev->dev, buffer_info->dma,
+					 buffer_info->length, DMA_FROM_DEVICE);
+			buffer_info->dma = 0;
+		}
 
 		if (++i == rx_ring->count) i = 0;
 		next_rxd = E1000_RX_DESC(*rx_ring, i);
@@ -4328,11 +4346,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		cleaned = true;
 		cleaned_count++;
-		dma_unmap_single(&pdev->dev, buffer_info->dma,
-				 buffer_info->length, DMA_FROM_DEVICE);
-		buffer_info->dma = 0;
 
-		length = le16_to_cpu(rx_desc->length);
 		/* !EOP means multiple descriptors were used to store a single
 		 * packet, if thats the case we need to toss it.  In fact, we
 		 * to toss every packet with the EOP bit clear and the next
@@ -4345,8 +4359,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		if (adapter->discarding) {
 			/* All receives must fit into a single buffer */
 			netdev_dbg(netdev, "Receive packet consumed multiple buffers\n");
-			/* recycle */
-			buffer_info->skb = skb;
+			dev_kfree_skb(skb);
 			if (status & E1000_RXD_STAT_EOP)
 				adapter->discarding = false;
 			goto next_desc;
@@ -4360,8 +4373,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			} else if (netdev->features & NETIF_F_RXALL) {
 				goto process_skb;
 			} else {
-				/* recycle */
-				buffer_info->skb = skb;
+				dev_kfree_skb(skb);
 				goto next_desc;
 			}
 		}
@@ -4376,9 +4388,10 @@ process_skb:
 			 */
 			length -= 4;
 
-		e1000_check_copybreak(netdev, buffer_info, length, &skb);
-
-		skb_put(skb, length);
+		if (buffer_info->skb == NULL)
+			skb_put(skb, length);
+		else /* copybreak skb */
+			skb_trim(skb, length);
 
 		/* Receive Checksum Offload */
 		e1000_rx_checksum(adapter,
@@ -4524,7 +4537,7 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 		skb = buffer_info->skb;
 		if (skb) {
 			skb_trim(skb, 0);
-			goto map_skb;
+			goto skip;
 		}
 
 		skb = netdev_alloc_skb_ip_align(netdev, bufsz);
@@ -4561,7 +4574,6 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 		}
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
-map_skb:
 		buffer_info->dma = dma_map_single(&pdev->dev,
 						  skb->data,
 						  buffer_info->length,
@@ -4599,6 +4611,7 @@ map_skb:
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
 		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
 
+skip:
 		if (unlikely(++i == rx_ring->count))
 			i = 0;
 		buffer_info = &rx_ring->buffer_info[i];
-- 
1.8.1.5
