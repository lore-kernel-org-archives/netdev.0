From: Neil Horman <nhorman@tuxdriver.com>
Subject: [net PATCH v3] 8139cp: Add dma_mapping_error checking
Date: Mon, 29 Jul 2013 13:05:35 -0400
Message-ID: <1375117535-12906-1-git-send-email-nhorman@tuxdriver.com>
References: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51173 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755404Ab3G2RFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 13:05:55 -0400
In-Reply-To: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
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
CC: Francois Romieu <romieu@fr.zoreil.com>

---
Change notes:

v2) Added stats update for tx_dropped as per Francois Romieu

v3)
* Updated rx patch to handle dma errors properly.  Francois had pointed out that
I needed to increment the rx_dropped stat there, but the problem was a bit
deeper.  I actually had to move the dma_mapping and error check higher in the
path, so that, in the event of a failure, we could drop the received skb, and
reuse its existing mapping in the rx ring.  this is in line with what happens if
the skb allocation fails

* Updated the tx path to have a common goto for mapping failures, so we only
have one location to drop the skb

* Moved the unwind code into a separate helper function, as per Francois
suggestion.  I though it would be alot of parameter passing and not very
adventageous, but on second look I think its more readable.
---
 drivers/net/ethernet/realtek/8139cp.c | 48 ++++++++++++++++++++++++++++++++---
 1 file changed, 45 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 0352345..3042030 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -478,7 +478,7 @@ rx_status_loop:
 
 	while (1) {
 		u32 status, len;
-		dma_addr_t mapping;
+		dma_addr_t mapping, new_mapping;
 		struct sk_buff *skb, *new_skb;
 		struct cp_desc *desc;
 		const unsigned buflen = cp->rx_buf_sz;
@@ -520,6 +520,13 @@ rx_status_loop:
 			goto rx_next;
 		}
 
+		new_mapping = dma_map_single(&cp->pdev->dev, new_skb->data, buflen,
+					 PCI_DMA_FROMDEVICE);
+		if (dma_mapping_error(&cp->pdev->dev, new_mapping)) {
+			dev->stats.rx_dropped++;
+			goto rx_next;
+		}
+
 		dma_unmap_single(&cp->pdev->dev, mapping,
 				 buflen, PCI_DMA_FROMDEVICE);
 
@@ -531,12 +538,11 @@ rx_status_loop:
 
 		skb_put(skb, len);
 
-		mapping = dma_map_single(&cp->pdev->dev, new_skb->data, buflen,
-					 PCI_DMA_FROMDEVICE);
 		cp->rx_skb[rx_tail] = new_skb;
 
 		cp_rx_skb(cp, skb, desc);
 		rx++;
+		mapping = new_mapping;
 
 rx_next:
 		cp->rx_ring[rx_tail].opts2 = 0;
@@ -716,6 +722,22 @@ static inline u32 cp_tx_vlan_tag(struct sk_buff *skb)
 		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
 }
 
+static void unwind_rx_frag_mapping(struct cp_private *cp, struct sk_buff *skb,
+				   int first, int entry_last)
+{
+	int frag, index;
+	struct cp_desc *txd;
+	skb_frag_t *this_frag;
+	for (frag = 0; frag+first < entry_last; frag++) {
+		index = first+frag;
+		cp->tx_skb[index] = NULL;
+		txd = &cp->tx_ring[index];
+		this_frag = &skb_shinfo(skb)->frags[frag];
+		dma_unmap_single(&cp->pdev->dev, le64_to_cpu(txd->addr),
+				 skb_frag_size(this_frag), PCI_DMA_TODEVICE);
+	}
+}
+
 static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 					struct net_device *dev)
 {
@@ -749,6 +771,9 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 
 		len = skb->len;
 		mapping = dma_map_single(&cp->pdev->dev, skb->data, len, PCI_DMA_TODEVICE);
+		if (dma_mapping_error(&cp->pdev->dev, mapping))
+			goto out_dma_error;
+
 		txd->opts2 = opts2;
 		txd->addr = cpu_to_le64(mapping);
 		wmb();
@@ -786,6 +811,9 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 		first_len = skb_headlen(skb);
 		first_mapping = dma_map_single(&cp->pdev->dev, skb->data,
 					       first_len, PCI_DMA_TODEVICE);
+		if (dma_mapping_error(&cp->pdev->dev, first_mapping))
+			goto out_dma_error;
+
 		cp->tx_skb[entry] = skb;
 		entry = NEXT_TX(entry);
 
@@ -799,6 +827,11 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 			mapping = dma_map_single(&cp->pdev->dev,
 						 skb_frag_address(this_frag),
 						 len, PCI_DMA_TODEVICE);
+			if (dma_mapping_error(&cp->pdev->dev, mapping)) {
+				unwind_rx_frag_mapping(cp, skb, first_entry, entry);
+				goto out_dma_error;
+			}
+
 			eor = (entry == (CP_TX_RING_SIZE - 1)) ? RingEnd : 0;
 
 			ctrl = eor | len | DescOwn;
@@ -859,11 +892,16 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 	if (TX_BUFFS_AVAIL(cp) <= (MAX_SKB_FRAGS + 1))
 		netif_stop_queue(dev);
 
+out_unlock:
 	spin_unlock_irqrestore(&cp->lock, intr_flags);
 
 	cpw8(TxPoll, NormalTxPoll);
 
 	return NETDEV_TX_OK;
+out_dma_error:
+	kfree_skb(skb);
+	cp->dev->stats.tx_dropped++;
+	goto out_unlock;
 }
 
 /* Set or clear the multicast filter for this adaptor.
@@ -1054,6 +1092,10 @@ static int cp_refill_rx(struct cp_private *cp)
 
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
