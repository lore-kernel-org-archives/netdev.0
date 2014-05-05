From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] jme: Fix DMA unmap warning
Date: Mon,  5 May 2014 14:51:47 -0400
Message-ID: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39591 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbaEESwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 14:52:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The jme driver forgot to check the return status from pci_map_page in its tx
path, causing a dma api warning on unmap.  Easy fix, just do the check and
augment the tx path to tell the stack that the driver is busy so we re-queue the
frame.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Guo-Fu Tseng <cooldavid@cooldavid.org>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/ethernet/jme.c | 53 ++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 47 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index b0c6050..6e664d9 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1988,7 +1988,7 @@ jme_alloc_txdesc(struct jme_adapter *jme,
 	return idx;
 }
 
-static void
+static int
 jme_fill_tx_map(struct pci_dev *pdev,
 		struct txdesc *txdesc,
 		struct jme_buffer_info *txbi,
@@ -2005,6 +2005,9 @@ jme_fill_tx_map(struct pci_dev *pdev,
 				len,
 				PCI_DMA_TODEVICE);
 
+	if (unlikely(pci_dma_mapping_error(pdev, dmaaddr)))
+		return -EINVAL;
+
 	pci_dma_sync_single_for_device(pdev,
 				       dmaaddr,
 				       len,
@@ -2021,9 +2024,30 @@ jme_fill_tx_map(struct pci_dev *pdev,
 
 	txbi->mapping = dmaaddr;
 	txbi->len = len;
+	return 0;
 }
 
-static void
+static void jme_drop_tx_map(struct jme_adapter *jme, int startidx, int endidx)
+{
+	struct jme_ring *txring = &(jme->txring[0]);
+	struct jme_buffer_info *txbi = txring->bufinf, *ctxbi;
+	int mask = jme->tx_ring_mask;
+	int j;
+
+	for (j = startidx ; j < endidx ; ++j) {
+		ctxbi = txbi + ((startidx + j + 2) & (mask));
+		pci_unmap_page(jme->pdev,
+				ctxbi->mapping,
+				ctxbi->len,
+				PCI_DMA_TODEVICE);
+
+				ctxbi->mapping = 0;
+				ctxbi->len = 0;
+	}
+
+}
+
+static int
 jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 {
 	struct jme_ring *txring = &(jme->txring[0]);
@@ -2034,25 +2058,37 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 	int mask = jme->tx_ring_mask;
 	const struct skb_frag_struct *frag;
 	u32 len;
+	int ret = 0;
 
 	for (i = 0 ; i < nr_frags ; ++i) {
 		frag = &skb_shinfo(skb)->frags[i];
 		ctxdesc = txdesc + ((idx + i + 2) & (mask));
 		ctxbi = txbi + ((idx + i + 2) & (mask));
 
-		jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi,
+		ret = jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi,
 				skb_frag_page(frag),
 				frag->page_offset, skb_frag_size(frag), hidma);
+		if (ret) {
+			jme_drop_tx_map(jme, idx, idx+i);
+			goto out;
+		}
+
 	}
 
 	len = skb_is_nonlinear(skb) ? skb_headlen(skb) : skb->len;
 	ctxdesc = txdesc + ((idx + 1) & (mask));
 	ctxbi = txbi + ((idx + 1) & (mask));
-	jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi, virt_to_page(skb->data),
+	ret = jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi, virt_to_page(skb->data),
 			offset_in_page(skb->data), len, hidma);
+	if (ret)
+		jme_drop_tx_map(jme, idx, idx+i);
+
+out:
+	return ret;
 
 }
 
+
 static int
 jme_tx_tso(struct sk_buff *skb, __le16 *mss, u8 *flags)
 {
@@ -2131,6 +2167,7 @@ jme_fill_tx_desc(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 	struct txdesc *txdesc;
 	struct jme_buffer_info *txbi;
 	u8 flags;
+	int ret = 0;
 
 	txdesc = (struct txdesc *)txring->desc + idx;
 	txbi = txring->bufinf + idx;
@@ -2155,7 +2192,10 @@ jme_fill_tx_desc(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 	if (jme_tx_tso(skb, &txdesc->desc1.mss, &flags))
 		jme_tx_csum(jme, skb, &flags);
 	jme_tx_vlan(skb, &txdesc->desc1.vlan, &flags);
-	jme_map_tx_skb(jme, skb, idx);
+	ret = jme_map_tx_skb(jme, skb, idx);
+	if (ret)
+		return ret;
+
 	txdesc->desc1.flags = flags;
 	/*
 	 * Set tx buffer info after telling NIC to send
@@ -2228,7 +2268,8 @@ jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_BUSY;
 	}
 
-	jme_fill_tx_desc(jme, skb, idx);
+	if (jme_fill_tx_desc(jme, skb, idx))
+		return NETDEV_TX_BUSY;
 
 	jwrite32(jme, JME_TXCS, jme->reg_txcs |
 				TXCS_SELECT_QUEUE0 |
-- 
1.8.3.1
