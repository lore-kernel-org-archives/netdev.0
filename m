From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/7] 8139cp: ring_info removal for the receive path
Date: Thu, 31 Aug 2006 22:49:54 +0200
Message-ID: <20060831204954.GC14181@electric-eye.fr.zoreil.com>
References: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Pierre Ossman <drzeus-list@drzeus.cx>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:62123 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932444AbWHaUwL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 16:52:11 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ring_info.len field is not used at all. cp_private.rx_skb is
turned into an array of sk_buff *.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

---

 drivers/net/8139cp.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

0ba894d420b845667e2981c2147af974a755fba2
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index ae9bb75..0725681 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -354,7 +354,7 @@ struct cp_private {
 
 	unsigned		rx_tail		____cacheline_aligned;
 	struct cp_desc		*rx_ring;
-	struct ring_info	rx_skb[CP_RX_RING_SIZE];
+	struct sk_buff		*rx_skb[CP_RX_RING_SIZE];
 	unsigned		rx_buf_sz;
 
 	unsigned		tx_head		____cacheline_aligned;
@@ -541,7 +541,7 @@ rx_status_loop:
 		struct cp_desc *desc;
 		unsigned buflen;
 
-		skb = cp->rx_skb[rx_tail].skb;
+		skb = cp->rx_skb[rx_tail];
 		BUG_ON(!skb);
 
 		desc = &cp->rx_ring[rx_tail];
@@ -596,7 +596,7 @@ rx_status_loop:
 
 		mapping = pci_map_single(cp->pdev, new_skb->data, buflen,
 					 PCI_DMA_FROMDEVICE);
-		cp->rx_skb[rx_tail].skb = new_skb;
+		cp->rx_skb[rx_tail] = new_skb;
 
 		cp_rx_skb(cp, skb, desc);
 		rx++;
@@ -1097,7 +1097,7 @@ static int cp_refill_rx (struct cp_priva
 
 		mapping = pci_map_single(cp->pdev, skb->data, cp->rx_buf_sz,
 					 PCI_DMA_FROMDEVICE);
-		cp->rx_skb[i].skb = skb;
+		cp->rx_skb[i] = skb;
 
 		cp->rx_ring[i].opts2 = 0;
 		cp->rx_ring[i].addr = cpu_to_le64(mapping);
@@ -1152,11 +1152,11 @@ static void cp_clean_rings (struct cp_pr
 	unsigned i;
 
 	for (i = 0; i < CP_RX_RING_SIZE; i++) {
-		if (cp->rx_skb[i].skb) {
+		if (cp->rx_skb[i]) {
 			desc = cp->rx_ring + i;
 			pci_unmap_single(cp->pdev, le64_to_cpu(desc->addr),
 					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-			dev_kfree_skb(cp->rx_skb[i].skb);
+			dev_kfree_skb(cp->rx_skb[i]);
 		}
 	}
 
@@ -1176,7 +1176,7 @@ static void cp_clean_rings (struct cp_pr
 	memset(cp->rx_ring, 0, sizeof(struct cp_desc) * CP_RX_RING_SIZE);
 	memset(cp->tx_ring, 0, sizeof(struct cp_desc) * CP_TX_RING_SIZE);
 
-	memset(&cp->rx_skb, 0, sizeof(struct ring_info) * CP_RX_RING_SIZE);
+	memset(cp->rx_skb, 0, sizeof(struct sk_buff *) * CP_RX_RING_SIZE);
 	memset(&cp->tx_skb, 0, sizeof(struct ring_info) * CP_TX_RING_SIZE);
 }
 
-- 
1.3.1

