From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 04/12] amd8111e: add GRO support
Date: Sat,  4 Feb 2017 15:24:54 -0800
Message-ID: <20170204232502.22361-5-edumazet@google.com>
References: <20170204232502.22361-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35767 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751767AbdBDXZW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 18:25:22 -0500
Received: by mail-pf0-f174.google.com with SMTP id f144so14408665pfa.2
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 15:25:17 -0800 (PST)
In-Reply-To: <20170204232502.22361-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use napi_complete_done() instead of __napi_complete() to :

1) Get support of gro_flush_timeout if opt-in
2) Not rearm interrupts for busy-polling users.
3) use standard NAPI API.
4) get rid of baroque code and ease maintenance.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/amd/amd8111e.c | 164 ++++++++++++++++--------------------
 1 file changed, 72 insertions(+), 92 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 9595f1bc535b73306720e4d0005fe58d2025..7b5df562f30f5625cdc2e1e5b6d59bff6919 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -695,125 +695,105 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 	void __iomem *mmio = lp->mmio;
 	struct sk_buff *skb,*new_skb;
 	int min_pkt_len, status;
-	unsigned int intr0;
 	int num_rx_pkt = 0;
 	short pkt_len;
 #if AMD8111E_VLAN_TAG_USED
 	short vtag;
 #endif
-	int rx_pkt_limit = budget;
-	unsigned long flags;
 
-	if (rx_pkt_limit <= 0)
-		goto rx_not_empty;
+	while (num_rx_pkt < budget) {
+		status = le16_to_cpu(lp->rx_ring[rx_index].rx_flags);
+		if (status & OWN_BIT)
+			break;
 
-	do{
-		/* process receive packets until we use the quota.
-		 * If we own the next entry, it's a new packet. Send it up.
+		/* There is a tricky error noted by John Murphy,
+		 * <murf@perftech.com> to Russ Nelson: Even with
+		 * full-sized * buffers it's possible for a
+		 * jabber packet to use two buffers, with only
+		 * the last correctly noting the error.
 		 */
-		while(1) {
-			status = le16_to_cpu(lp->rx_ring[rx_index].rx_flags);
-			if (status & OWN_BIT)
-				break;
-
-			/* There is a tricky error noted by John Murphy,
-			 * <murf@perftech.com> to Russ Nelson: Even with
-			 * full-sized * buffers it's possible for a
-			 * jabber packet to use two buffers, with only
-			 * the last correctly noting the error.
-			 */
-			if(status & ERR_BIT) {
-				/* resetting flags */
-				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
-				goto err_next_pkt;
-			}
-			/* check for STP and ENP */
-			if(!((status & STP_BIT) && (status & ENP_BIT))){
-				/* resetting flags */
-				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
-				goto err_next_pkt;
-			}
-			pkt_len = le16_to_cpu(lp->rx_ring[rx_index].msg_count) - 4;
+		if (status & ERR_BIT) {
+			/* resetting flags */
+			lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
+			goto err_next_pkt;
+		}
+		/* check for STP and ENP */
+		if (!((status & STP_BIT) && (status & ENP_BIT))){
+			/* resetting flags */
+			lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
+			goto err_next_pkt;
+		}
+		pkt_len = le16_to_cpu(lp->rx_ring[rx_index].msg_count) - 4;
 
 #if AMD8111E_VLAN_TAG_USED
-			vtag = status & TT_MASK;
-			/*MAC will strip vlan tag*/
-			if (vtag != 0)
-				min_pkt_len =MIN_PKT_LEN - 4;
+		vtag = status & TT_MASK;
+		/* MAC will strip vlan tag */
+		if (vtag != 0)
+			min_pkt_len = MIN_PKT_LEN - 4;
 			else
 #endif
-				min_pkt_len =MIN_PKT_LEN;
+			min_pkt_len = MIN_PKT_LEN;
 
-			if (pkt_len < min_pkt_len) {
-				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
-				lp->drv_rx_errors++;
-				goto err_next_pkt;
-			}
-			if(--rx_pkt_limit < 0)
-				goto rx_not_empty;
-			new_skb = netdev_alloc_skb(dev, lp->rx_buff_len);
-			if (!new_skb) {
-				/* if allocation fail,
-				 * ignore that pkt and go to next one
-				 */
-				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
-				lp->drv_rx_errors++;
-				goto err_next_pkt;
-			}
+		if (pkt_len < min_pkt_len) {
+			lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
+			lp->drv_rx_errors++;
+			goto err_next_pkt;
+		}
+		new_skb = netdev_alloc_skb(dev, lp->rx_buff_len);
+		if (!new_skb) {
+			/* if allocation fail,
+			 * ignore that pkt and go to next one
+			 */
+			lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
+			lp->drv_rx_errors++;
+			goto err_next_pkt;
+		}
 
-			skb_reserve(new_skb, 2);
-			skb = lp->rx_skbuff[rx_index];
-			pci_unmap_single(lp->pci_dev,lp->rx_dma_addr[rx_index],
-					 lp->rx_buff_len-2, PCI_DMA_FROMDEVICE);
-			skb_put(skb, pkt_len);
-			lp->rx_skbuff[rx_index] = new_skb;
-			lp->rx_dma_addr[rx_index] = pci_map_single(lp->pci_dev,
-								   new_skb->data,
-								   lp->rx_buff_len-2,
-								   PCI_DMA_FROMDEVICE);
+		skb_reserve(new_skb, 2);
+		skb = lp->rx_skbuff[rx_index];
+		pci_unmap_single(lp->pci_dev,lp->rx_dma_addr[rx_index],
+				 lp->rx_buff_len-2, PCI_DMA_FROMDEVICE);
+		skb_put(skb, pkt_len);
+		lp->rx_skbuff[rx_index] = new_skb;
+		lp->rx_dma_addr[rx_index] = pci_map_single(lp->pci_dev,
+							   new_skb->data,
+							   lp->rx_buff_len-2,
+							   PCI_DMA_FROMDEVICE);
 
-			skb->protocol = eth_type_trans(skb, dev);
+		skb->protocol = eth_type_trans(skb, dev);
 
 #if AMD8111E_VLAN_TAG_USED
-			if (vtag == TT_VLAN_TAGGED){
-				u16 vlan_tag = le16_to_cpu(lp->rx_ring[rx_index].tag_ctrl_info);
-				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
-			}
-#endif
-			netif_receive_skb(skb);
-			/*COAL update rx coalescing parameters*/
-			lp->coal_conf.rx_packets++;
-			lp->coal_conf.rx_bytes += pkt_len;
-			num_rx_pkt++;
-
-		err_next_pkt:
-			lp->rx_ring[rx_index].buff_phy_addr
-				= cpu_to_le32(lp->rx_dma_addr[rx_index]);
-			lp->rx_ring[rx_index].buff_count =
-				cpu_to_le16(lp->rx_buff_len-2);
-			wmb();
-			lp->rx_ring[rx_index].rx_flags |= cpu_to_le16(OWN_BIT);
-			rx_index = (++lp->rx_idx) & RX_RING_DR_MOD_MASK;
+		if (vtag == TT_VLAN_TAGGED){
+			u16 vlan_tag = le16_to_cpu(lp->rx_ring[rx_index].tag_ctrl_info);
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 		}
-		/* Check the interrupt status register for more packets in the
-		 * mean time. Process them since we have not used up our quota.
-		 */
-		intr0 = readl(mmio + INT0);
-		/*Ack receive packets */
-		writel(intr0 & RINT0,mmio + INT0);
+#endif
+		napi_gro_receive(napi, skb);
+		/* COAL update rx coalescing parameters */
+		lp->coal_conf.rx_packets++;
+		lp->coal_conf.rx_bytes += pkt_len;
+		num_rx_pkt++;
+
+err_next_pkt:
+		lp->rx_ring[rx_index].buff_phy_addr
+			= cpu_to_le32(lp->rx_dma_addr[rx_index]);
+		lp->rx_ring[rx_index].buff_count =
+			cpu_to_le16(lp->rx_buff_len-2);
+		wmb();
+		lp->rx_ring[rx_index].rx_flags |= cpu_to_le16(OWN_BIT);
+		rx_index = (++lp->rx_idx) & RX_RING_DR_MOD_MASK;
+	}
 
-	} while(intr0 & RINT0);
+	if (num_rx_pkt < budget && napi_complete_done(napi, num_rx_pkt)) {
+		unsigned long flags;
 
-	if (rx_pkt_limit > 0) {
 		/* Receive descriptor is empty now */
 		spin_lock_irqsave(&lp->lock, flags);
-		__napi_complete(napi);
 		writel(VAL0|RINTEN0, mmio + INTEN0);
 		writel(VAL2 | RDMD0, mmio + CMD0);
 		spin_unlock_irqrestore(&lp->lock, flags);
 	}
 
-rx_not_empty:
 	return num_rx_pkt;
 }
 
-- 
2.11.0.483.g087da7b7c-goog
