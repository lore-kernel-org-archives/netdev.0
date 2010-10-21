From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 1/8] r8169: check dma mapping failures
Date: Thu, 21 Oct 2010 10:25:36 +0200
Message-ID: <1287649543-6569-2-git-send-email-sgruszka@redhat.com>
References: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14411 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223Ab0JUIXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 04:23:22 -0400
In-Reply-To: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check possible dma mapping errors and do clean up if it happens.

Fix overwrap bug in rtl8169_tx_clear on the way.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |   66 +++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 48 insertions(+), 18 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 1760533..01d96a7 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3992,11 +3992,18 @@ static struct sk_buff *rtl8169_alloc_rx_data(struct pci_dev *pdev,
 		if (!data)
 			return NULL;
 	}
+
 	mapping = dma_map_single(&pdev->dev, rtl8169_align(data), rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
+	if (unlikely(dma_mapping_error(&pdev->dev, mapping)))
+		goto err_out;
 
 	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
 	return data;
+
+err_out:
+	kfree(data);
+	return NULL;
 }
 
 static void rtl8169_rx_clear(struct rtl8169_private *tp)
@@ -4080,12 +4087,13 @@ static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct ring_info *tx_skb,
 	tx_skb->len = 0;
 }
 
-static void rtl8169_tx_clear(struct rtl8169_private *tp)
+static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start,
+				   unsigned int n)
 {
 	unsigned int i;
 
-	for (i = tp->dirty_tx; i < tp->dirty_tx + NUM_TX_DESC; i++) {
-		unsigned int entry = i % NUM_TX_DESC;
+	for (i = 0; i < n; i++) {
+		unsigned int entry = (start + i) % NUM_TX_DESC;
 		struct ring_info *tx_skb = tp->tx_skb + entry;
 		unsigned int len = tx_skb->len;
 
@@ -4101,6 +4109,11 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 			tp->dev->stats.tx_dropped++;
 		}
 	}
+}
+
+static void rtl8169_tx_clear(struct rtl8169_private *tp)
+{
+	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
 	tp->cur_tx = tp->dirty_tx = 0;
 }
 
@@ -4219,6 +4232,8 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		addr = ((void *) page_address(frag->page)) + frag->page_offset;
 		mapping = dma_map_single(&tp->pci_dev->dev, addr, len,
 					 PCI_DMA_TODEVICE);
+		if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
+			goto err_out;
 
 		/* anti gcc 2.95.3 bugware (sic) */
 		status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
@@ -4235,6 +4250,10 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 	}
 
 	return cur_frag;
+
+err_out:
+	rtl8169_tx_clear_range(tp, tp->cur_tx + 1, cur_frag);
+	return -EIO;
 }
 
 static inline u32 rtl8169_tso_csum(struct sk_buff *skb, struct net_device *dev)
@@ -4261,40 +4280,44 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	unsigned int frags, entry = tp->cur_tx % NUM_TX_DESC;
+	unsigned int entry = tp->cur_tx % NUM_TX_DESC;
 	struct TxDesc *txd = tp->TxDescArray + entry;
 	void __iomem *ioaddr = tp->mmio_addr;
 	dma_addr_t mapping;
 	u32 status, len;
 	u32 opts1;
+	int frags;
 
 	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
 		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
-		goto err_stop;
+		goto err_stop_0;
 	}
 
 	if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
-		goto err_stop;
+		goto err_stop_0;
+
+	len = skb_headlen(skb);
+	mapping = dma_map_single(&tp->pci_dev->dev, skb->data, len,
+				 PCI_DMA_TODEVICE);
+	if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
+		goto err_dma_0;
+
+	tp->tx_skb[entry].len = len;
+	txd->addr = cpu_to_le64(mapping);
+	txd->opts2 = cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
 
 	opts1 = DescOwn | rtl8169_tso_csum(skb, dev);
 
 	frags = rtl8169_xmit_frags(tp, skb, opts1);
-	if (frags) {
-		len = skb_headlen(skb);
+	if (frags < 0)
+		goto err_dma_1;
+	else if (frags)
 		opts1 |= FirstFrag;
-	} else {
-		len = skb->len;
+	else {
 		opts1 |= FirstFrag | LastFrag;
 		tp->tx_skb[entry].skb = skb;
 	}
 
-	mapping = dma_map_single(&tp->pci_dev->dev, skb->data, len,
-				 PCI_DMA_TODEVICE);
-
-	tp->tx_skb[entry].len = len;
-	txd->addr = cpu_to_le64(mapping);
-	txd->opts2 = cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
-
 	wmb();
 
 	/* anti gcc 2.95.3 bugware (sic) */
@@ -4316,7 +4339,14 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	return NETDEV_TX_OK;
 
-err_stop:
+err_dma_1:
+	rtl8169_unmap_tx_skb(tp->pci_dev, tp->tx_skb + entry, txd);
+err_dma_0:
+	dev_kfree_skb(skb);
+	dev->stats.tx_dropped++;
+	return NETDEV_TX_OK;
+
+err_stop_0:
 	netif_stop_queue(dev);
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_BUSY;
-- 
1.6.5.2

