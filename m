From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 2/2] net: systemport: pad packets to a minimum of 64 bytes
Date: Wed,  7 May 2014 14:36:04 -0700
Message-ID: <1399498564-22037-3-git-send-email-f.fainelli@gmail.com>
References: <1399498564-22037-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:52040 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbaEGVgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 17:36:31 -0400
Received: by mail-pa0-f42.google.com with SMTP id rd3so1719292pab.29
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 14:36:31 -0700 (PDT)
In-Reply-To: <1399498564-22037-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch fabric which is used behind the Broadcom SYSTEMPORT Ethernet
controller will discard any incoming packet that is not 64 bytes or
more. Since the UniMAC hardware transmits up to the specified size, just
make sure that we properly pad the end of the packet with zeroes using
skb_padto() and set a minimum packet length of 64 bytes.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v3:
- reword the commit message and comment to explain the special hardware
  requirements
- print skb_len instead of skb->len in the DMA map failure error

Changes in v2:
- add missing skb_padto() to zero-out packets

 drivers/net/ethernet/broadcom/bcmsysport.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index e118e7411ca4..413366570c7e 100644
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
@@ -848,10 +849,22 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 		}
 	}
 
-	mapping = dma_map_single(kdev, skb->data, skb->len, DMA_TO_DEVICE);
+	/* The Ethernet switch we are interfaced with needs packets to be at
+	 * least 64 bytes otherwise they will be discarded when they enter
+	 * the switch port logic. The UniMAC hardware transmits up to the
+	 * specified length.
+	 */
+	if (skb_padto(skb, 64)) {
+		ret = NETDEV_TX_OK;
+		goto out;
+	}
+
+	skb_len = skb->len < 64 ? 64 : skb->len;
+
+	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
 	if (dma_mapping_error(kdev, mapping)) {
 		netif_err(priv, tx_err, dev, "DMA map failed at %p (len=%d)\n",
-				skb->data, skb->len);
+				skb->data, skb_len);
 		ret = NETDEV_TX_OK;
 		goto out;
 	}
@@ -860,14 +873,14 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
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
