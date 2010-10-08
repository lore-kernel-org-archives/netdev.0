From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [RFC PATCH 1/2] r8169: check dma mapping failures
Date: Fri,  8 Oct 2010 16:30:02 +0200
Message-ID: <1286548203-10831-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757342Ab0JHO2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 10:28:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is on top on my two r8169 patches just send.

Check possible dma mapping errors and do clean up if it happens.
Patch was not tested.

BTW: I see many drivers do not check these, so is really possible to
have this errors, and if yes, when ?
---
 drivers/net/r8169.c |   36 ++++++++++++++++++++++++++++--------
 1 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bc669a4..b3b28b1 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4018,20 +4018,24 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
 
 	skb = __netdev_alloc_skb(dev, rx_buf_sz + pad, gfp);
 	if (!skb)
-		goto err_out;
+		goto err0;
 
 	skb_reserve(skb, align ? ((pad - 1) & (unsigned long)skb->data) : pad);
 
 	mapping = dma_map_single(&pdev->dev, skb->data, rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
+	if (dma_mapping_error(&pdev->dev, mapping))
+		goto err1;
 
 	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
-out:
+
 	return skb;
 
-err_out:
+err1:
+	dev_kfree_skb(skb);
+err0:
 	rtl8169_make_unusable_by_asic(desc);
-	goto out;
+	return NULL;
 }
 
 static void rtl8169_rx_clear(struct rtl8169_private *tp)
@@ -4115,11 +4119,11 @@ static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct ring_info *tx_skb,
 	tx_skb->len = 0;
 }
 
-static void rtl8169_tx_clear(struct rtl8169_private *tp)
+static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start, u32 end)
 {
-	unsigned int i;
+	u32 i;
 
-	for (i = tp->dirty_tx; i < tp->dirty_tx + NUM_TX_DESC; i++) {
+	for (i = start; i < end; i++) {
 		unsigned int entry = i % NUM_TX_DESC;
 		struct ring_info *tx_skb = tp->tx_skb + entry;
 		unsigned int len = tx_skb->len;
@@ -4136,6 +4140,11 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 			tp->dev->stats.tx_dropped++;
 		}
 	}
+}
+
+static inline void rtl8169_tx_clear(struct rtl8169_private *tp)
+{
+	rtl8169_tx_clear_range(tp, tp->dirty_tx, tp->dirty_tx + NUM_TX_DESC);
 	tp->cur_tx = tp->dirty_tx = 0;
 }
 
@@ -4254,6 +4263,8 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		addr = ((void *) page_address(frag->page)) + frag->page_offset;
 		mapping = dma_map_single(&tp->pci_dev->dev, addr, len,
 					 PCI_DMA_TODEVICE);
+		if (dma_mapping_error(&tp->pci_dev->dev, mapping))
+			return -cur_frag;
 
 		/* anti gcc 2.95.3 bugware (sic) */
 		status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
@@ -4314,7 +4325,10 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	opts1 = DescOwn | rtl8169_tso_csum(skb, dev);
 
 	frags = rtl8169_xmit_frags(tp, skb, opts1);
-	if (frags) {
+	if (frags < 0) {
+		frags = -frags;
+		goto err_dma;
+	} else if (frags) {
 		len = skb_headlen(skb);
 		opts1 |= FirstFrag;
 	} else {
@@ -4325,6 +4339,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	mapping = dma_map_single(&tp->pci_dev->dev, skb->data, len,
 				 PCI_DMA_TODEVICE);
+	if (dma_mapping_error(&tp->pci_dev->dev, mapping))
+		goto err_dma;
 
 	tp->tx_skb[entry].len = len;
 	txd->addr = cpu_to_le64(mapping);
@@ -4355,6 +4371,10 @@ err_stop:
 	netif_stop_queue(dev);
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_BUSY;
+
+err_dma:
+	rtl8169_tx_clear_range(tp, entry, entry + frags + 1);
+	return NETDEV_TX_OK;
 }
 
 static void rtl8169_pcierr_interrupt(struct net_device *dev)
-- 
1.7.1

