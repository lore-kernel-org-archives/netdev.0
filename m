From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: systemport: pad packets to a minimum of 64 bytes
Date: Sat,  3 May 2014 11:31:14 -0700
Message-ID: <1399141874-12003-3-git-send-email-f.fainelli@gmail.com>
References: <1399141874-12003-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:55062 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbaECSbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 14:31:34 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so7148435pad.15
        for <netdev@vger.kernel.org>; Sat, 03 May 2014 11:31:34 -0700 (PDT)
In-Reply-To: <1399141874-12003-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch fabric which is used behind the Broadcom SYSTEMPORT Ethernet
controller will discard any incoming packet that is not 64 bytes or
more. Since the UniMAC hardware automatically pads up to the specified
length, we can simply ensure we instruct it to transmit >= 64 bytes
packets.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index e118e74..a49c381 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -821,6 +821,7 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 	struct bcm_sysport_cb *cb;
 	struct netdev_queue *txq;
 	struct dma_desc *desc;
+	unsigned int skb_len;
 	dma_addr_t mapping;
 	u32 len_status;
 	u16 queue;
@@ -848,7 +849,14 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 		}
 	}
 
-	mapping = dma_map_single(kdev, skb->data, skb->len, DMA_TO_DEVICE);
+	/* The Ethernet switch we are interfaced with needs packets to be at
+	 * least 64 bytes otherwise they will be discarded when they enter
+	 * the switch port logic. The UniMAC hardware automatically pads if
+	 * instructed to do so.
+	 */
+	skb_len = skb->len < 64 ? 64 : skb->len;
+
+	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
 	if (dma_mapping_error(kdev, mapping)) {
 		netif_err(priv, tx_err, dev, "DMA map failed at %p (len=%d)\n",
 				skb->data, skb->len);
@@ -860,14 +868,14 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 	cb = &ring->cbs[ring->curr_desc];
 	cb->skb = skb;
 	dma_unmap_addr_set(cb, dma_addr, mapping);
-	dma_unmap_len_set(cb, dma_len, skb->len);
+	dma_unmap_len_set(cb, dma_len, skb_len);
 
 	/* Fetch a descriptor entry from our pool */
 	desc = ring->desc_cpu;
 
 	desc->addr_lo = lower_32_bits(mapping);
 	len_status = upper_32_bits(mapping) & DESC_ADDR_HI_MASK;
-	len_status |= (skb->len << DESC_LEN_SHIFT);
+	len_status |= (skb_len << DESC_LEN_SHIFT);
 	len_status |= (DESC_SOP | DESC_EOP | TX_STATUS_APP_CRC) <<
 			DESC_STATUS_SHIFT;
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
-- 
1.9.1
