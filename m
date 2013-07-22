From: Neil Horman <nhorman@tuxdriver.com>
Subject: [net PATCH] 8139cp: Add dma_mapping_error checking
Date: Mon, 22 Jul 2013 14:14:42 -0400
Message-ID: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52664 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347Ab3GVSO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 14:14:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Self explanitory dma_mapping_error addition to the 8139 driver, based on this:
https://bugzilla.redhat.com/show_bug.cgi?id=947250

It showed several backtraces arising for dma_map_* usage without checking the
return code on the mapping.  Add the check and abort the rx/tx operation if its
failed.  Untested as I have no hardware and the reporter has wandered off, but
seems pretty straightforward.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/ethernet/realtek/8139cp.c | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 0352345..b7ec733 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -533,6 +533,11 @@ rx_status_loop:
 
 		mapping = dma_map_single(&cp->pdev->dev, new_skb->data, buflen,
 					 PCI_DMA_FROMDEVICE);
+		if (dma_mapping_error(&cp->pdev->dev, mapping)) {
+			kfree_skb(skb);
+			break;
+		}
+
 		cp->rx_skb[rx_tail] = new_skb;
 
 		cp_rx_skb(cp, skb, desc);
@@ -749,6 +754,11 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 
 		len = skb->len;
 		mapping = dma_map_single(&cp->pdev->dev, skb->data, len, PCI_DMA_TODEVICE);
+		if (dma_mapping_error(&cp->pdev->dev, mapping)) {
+			kfree_skb(skb);
+			goto out_unlock;
+		}
+
 		txd->opts2 = opts2;
 		txd->addr = cpu_to_le64(mapping);
 		wmb();
@@ -786,6 +796,11 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 		first_len = skb_headlen(skb);
 		first_mapping = dma_map_single(&cp->pdev->dev, skb->data,
 					       first_len, PCI_DMA_TODEVICE);
+		if (dma_mapping_error(&cp->pdev->dev, first_mapping)) {
+			kfree_skb(skb);
+			goto out_unlock;
+		}
+
 		cp->tx_skb[entry] = skb;
 		entry = NEXT_TX(entry);
 
@@ -799,6 +814,20 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 			mapping = dma_map_single(&cp->pdev->dev,
 						 skb_frag_address(this_frag),
 						 len, PCI_DMA_TODEVICE);
+			if (dma_mapping_error(&cp->pdev->dev, mapping)) {
+				/* Unwind the mappnigs we have */
+				for (frag = 0; frag+first_entry < entry; frag++) {
+					cp->tx_skb[frag+first_entry] = NULL;
+					txd = &cp->tx_ring[frag+first_entry];
+					this_frag = &skb_shinfo(skb)->frags[frag];
+					dma_unmap_single(&cp->pdev->dev, le64_to_cpu(txd->addr),
+							 skb_frag_size(this_frag), PCI_DMA_TODEVICE); 
+				}
+				
+				kfree_skb(skb);
+				goto out_unlock;
+			}
+
 			eor = (entry == (CP_TX_RING_SIZE - 1)) ? RingEnd : 0;
 
 			ctrl = eor | len | DescOwn;
@@ -859,6 +888,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 	if (TX_BUFFS_AVAIL(cp) <= (MAX_SKB_FRAGS + 1))
 		netif_stop_queue(dev);
 
+out_unlock:
 	spin_unlock_irqrestore(&cp->lock, intr_flags);
 
 	cpw8(TxPoll, NormalTxPoll);
@@ -1054,6 +1084,10 @@ static int cp_refill_rx(struct cp_private *cp)
 
 		mapping = dma_map_single(&cp->pdev->dev, skb->data,
 					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+		if (dma_mapping_error(&cp->pdev->dev, mapping)) {
+			kfree_skb(skb);
+			goto err_out;
+		}
 		cp->rx_skb[i] = skb;
 
 		cp->rx_ring[i].opts2 = 0;
-- 
1.8.1.4
