From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 1/6] r8169: check dma mapping failures
Date: Fri, 15 Oct 2010 14:15:17 +0200
Message-ID: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754651Ab0JOMNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 08:13:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check possible dma mapping errors and do clean up if it happens,
when sending frames stop the tx queue.

Fix overwrap bug in rtl8169_tx_clear on the way.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
All patches in series was tested on RTL8111/8168B

 drivers/net/r8169.c |   69 ++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 46 insertions(+), 23 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bc669a4..a6c4f90 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4018,20 +4018,25 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
 
 	skb = __netdev_alloc_skb(dev, rx_buf_sz + pad, gfp);
 	if (!skb)
-		goto err_out;
+		goto err_out_0;
 
 	skb_reserve(skb, align ? ((pad - 1) & (unsigned long)skb->data) : pad);
 
 	mapping = dma_map_single(&pdev->dev, skb->data, rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
+	if (dma_mapping_error(&pdev->dev, mapping))
+		goto err_free_skb_1;
 
 	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
-out:
+
 	return skb;
 
-err_out:
+err_free_skb_1:
+	dev_kfree_skb(skb);
+
+err_out_0:
 	rtl8169_make_unusable_by_asic(desc);
-	goto out;
+	return NULL;
 }
 
 static void rtl8169_rx_clear(struct rtl8169_private *tp)
@@ -4115,12 +4120,12 @@ static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct ring_info *tx_skb,
 	tx_skb->len = 0;
 }
 
-static void rtl8169_tx_clear(struct rtl8169_private *tp)
+static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start, int n)
 {
-	unsigned int i;
+	int i;
 
-	for (i = tp->dirty_tx; i < tp->dirty_tx + NUM_TX_DESC; i++) {
-		unsigned int entry = i % NUM_TX_DESC;
+	for (i = 0; i < n; i++) {
+		unsigned int entry = (start + i) % NUM_TX_DESC;
 		struct ring_info *tx_skb = tp->tx_skb + entry;
 		unsigned int len = tx_skb->len;
 
@@ -4136,6 +4141,11 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
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
 
@@ -4254,6 +4264,8 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		addr = ((void *) page_address(frag->page)) + frag->page_offset;
 		mapping = dma_map_single(&tp->pci_dev->dev, addr, len,
 					 PCI_DMA_TODEVICE);
+		if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
+			goto err_out;
 
 		/* anti gcc 2.95.3 bugware (sic) */
 		status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
@@ -4270,6 +4282,10 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 	}
 
 	return cur_frag;
+
+err_out:
+	rtl8169_tx_clear_range(tp, tp->cur_tx, cur_frag);
+	return -EIO;
 }
 
 static inline u32 rtl8169_tso_csum(struct sk_buff *skb, struct net_device *dev)
@@ -4296,40 +4312,44 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
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
+		goto err_stop_0;
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
@@ -4351,7 +4371,10 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	return NETDEV_TX_OK;
 
-err_stop:
+err_dma_1:
+	rtl8169_unmap_tx_skb(tp->pci_dev, tp->tx_skb + entry, txd);
+
+err_stop_0:
 	netif_stop_queue(dev);
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_BUSY;
-- 
1.7.1

