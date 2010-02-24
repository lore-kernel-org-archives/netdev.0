From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: [PATCH] sis190: handle DMA mapping errors
Date: Wed, 24 Feb 2010 21:41:18 +0300
Message-ID: <20100224184118.GA4237@coldcone>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:32373 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757477Ab0BXSj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 13:39:26 -0500
Received: by fg-out-1718.google.com with SMTP id d23so92459fga.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2010 10:39:23 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
---
 drivers/net/sis190.c |   27 +++++++++++++++++++--------
 1 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 4487b06..80af4a4 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -484,18 +484,24 @@ static struct sk_buff *sis190_alloc_rx_skb(struct sis190_private *tp,
 {
 	u32 rx_buf_sz = tp->rx_buf_sz;
 	struct sk_buff *skb;
+	dma_addr_t mapping;
 
 	skb = netdev_alloc_skb(tp->dev, rx_buf_sz);
-	if (likely(skb)) {
-		dma_addr_t mapping;
-
-		mapping = pci_map_single(tp->pci_dev, skb->data, tp->rx_buf_sz,
-					 PCI_DMA_FROMDEVICE);
-		sis190_map_to_asic(desc, mapping, rx_buf_sz);
-	} else
-		sis190_make_unusable_by_asic(desc);
+	if (unlikely(!skb))
+		goto skb_alloc_failed;
+	mapping = pci_map_single(tp->pci_dev, skb->data, tp->rx_buf_sz,
+			PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(tp->pci_dev, mapping))
+		goto out;
+	sis190_map_to_asic(desc, mapping, rx_buf_sz);
 
 	return skb;
+
+out:
+	dev_kfree_skb_any(skb);
+skb_alloc_failed:
+	sis190_make_unusable_by_asic(desc);
+	return NULL;
 }
 
 static u32 sis190_rx_fill(struct sis190_private *tp, struct net_device *dev,
@@ -1184,6 +1190,11 @@ static netdev_tx_t sis190_start_xmit(struct sk_buff *skb,
 	}
 
 	mapping = pci_map_single(tp->pci_dev, skb->data, len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(tp->pci_dev, mapping)) {
+		netif_err(tp, tx_err, dev,
+				"PCI mapping failed, dropping packet");
+		return NETDEV_TX_BUSY;
+	}
 
 	tp->Tx_skbuff[entry] = skb;
 
