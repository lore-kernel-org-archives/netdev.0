From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 2/2] net: systemport: pad packets to a minimum of 68 bytes
Date: Wed, 14 May 2014 19:32:14 -0700
Message-ID: <1400121134-6088-3-git-send-email-f.fainelli@gmail.com>
References: <1400121134-6088-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, David Laight <David.Laight@aculab.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59241 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaEOCcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 22:32:32 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so419873pbb.5
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 19:32:31 -0700 (PDT)
In-Reply-To: <1400121134-6088-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packets need to be at least 64 bytes to enter the switch port logic,
including the FCS, otherwise they will be discarded as RUNT packets.

With packets having Broadcom tags, the 4-bytes tag is first stripped
off the packet, and the packet length is then checked, so we need to
make sure that the packet length with FCS is at least 64 bytes.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v5:
- properly explain the 68 bytes padding requirement due to how the switch
  ingress port logic works with switch tags

Changes in v4:
- respin due to first patch

Changes in v3:
- reword the commit message and comment to explain the special hardware
  requirements
- print skb_len instead of skb->len in the DMA map failure error

Changes in v2:
- add missing skb_padto() to zero-out packets

 drivers/net/ethernet/broadcom/bcmsysport.c | 24 ++++++++++++++++++++----
 drivers/net/ethernet/broadcom/bcmsysport.h |  6 +++---
 2 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 3950364..8edc098 100644
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
@@ -848,10 +849,25 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 		}
 	}
 
-	mapping = dma_map_single(kdev, skb->data, skb->len, DMA_TO_DEVICE);
+	/* The Ethernet switch we are interfaced with needs packets to be at
+	 * least 64 bytes (including FCS) otherwise they will be discarded when
+	 * they enter the switch port logic. When Broadcom tags are enabled, we
+	 * need to make sure that packets are at least 68 bytes
+	 * (including FCS and tag) because the length verification is done after
+	 * the Broadcom tag is stripped off the ingress packet.
+	 */
+	if (skb_padto(skb, ETH_ZLEN + ENET_BRCM_TAG_LEN)) {
+		ret = NETDEV_TX_OK;
+		goto out;
+	}
+
+	skb_len = skb->len < ETH_ZLEN + ENET_BRCM_TAG_LEN ?
+			ETH_ZLEN + ENET_BRCM_TAG_LEN : skb->len;
+
+	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
 	if (dma_mapping_error(kdev, mapping)) {
 		netif_err(priv, tx_err, dev, "DMA map failed at %p (len=%d)\n",
-				skb->data, skb->len);
+				skb->data, skb_len);
 		ret = NETDEV_TX_OK;
 		goto out;
 	}
@@ -860,14 +876,14 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
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
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index a0441e7..abdeb62 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -29,11 +29,11 @@
 /* Default RX buffer allocation size */
 #define RX_BUF_LENGTH		2048
 
-/* Body(1500) + EH_SIZE(14) + VLANTAG(4) + BRCMTAG(6) + FCS(4) = 1528.
+/* Body(1500) + EH_SIZE(14) + VLANTAG(4) + BRCMTAG(4) + FCS(4) = 1526.
  * 1536 is multiple of 256 bytes
  */
-#define ENET_BRCM_TAG_LEN	6
-#define ENET_PAD		8
+#define ENET_BRCM_TAG_LEN	4
+#define ENET_PAD		10
 #define UMAC_MAX_MTU_SIZE	(ETH_DATA_LEN + ETH_HLEN + VLAN_HLEN + \
 				 ENET_BRCM_TAG_LEN + ETH_FCS_LEN + ENET_PAD)
 
-- 
1.9.1
