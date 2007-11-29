From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [9/12] pasemi_mac: SKB unmap optimization
Date: Wed, 28 Nov 2007 20:57:45 -0600
Message-ID: <20071129025745.GJ17215@lixom.net>
References: <20071129025410.GA17215@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:36916 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758755AbXK2Cye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 21:54:34 -0500
Content-Disposition: inline
In-Reply-To: <20071129025410.GA17215@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: SKB unmap optimization

Avoid touching skb_shinfo() in the unmap path, since it turns out to
normally cause cache misses and delays. instead, save number of fragments
in the TX_RING_INFO structures since that's all that's needed anyway.


Signed-off-by: Olof Johansson <olof@lixom.net>

---
 drivers/net/pasemi_mac.c |   39 +++++++++++++++++++++++++--------------
 1 file changed, 25 insertions(+), 14 deletions(-)

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -253,11 +253,11 @@ static int get_skb_hdr(struct sk_buff *s
 }
 
 static int pasemi_mac_unmap_tx_skb(struct pasemi_mac *mac,
+				    const int nfrags,
 				    struct sk_buff *skb,
 				    const dma_addr_t *dmas)
 {
 	int f;
-	int nfrags = skb_shinfo(skb)->nr_frags;
 	struct pci_dev *pdev = mac->dma_pdev;
 
 	pci_unmap_single(pdev, dmas[0], skb_headlen(skb), PCI_DMA_TODEVICE);
@@ -425,7 +425,7 @@ static void pasemi_mac_free_tx_resources
 	unsigned int i, j;
 	struct pasemi_mac_buffer *info;
 	dma_addr_t dmas[MAX_SKB_FRAGS+1];
-	int freed;
+	int freed, nfrags;
 	int start, limit;
 
 	start = txring->next_to_clean;
@@ -438,10 +438,12 @@ static void pasemi_mac_free_tx_resources
 	for (i = start; i < limit; i += freed) {
 		info = &txring->ring_info[(i+1) & (TX_RING_SIZE-1)];
 		if (info->dma && info->skb) {
-			for (j = 0; j <= skb_shinfo(info->skb)->nr_frags; j++)
+			nfrags = skb_shinfo(info->skb)->nr_frags;
+			for (j = 0; j <= nfrags; j++)
 				dmas[j] = txring->ring_info[(i+1+j) &
 						(TX_RING_SIZE-1)].dma;
-			freed = pasemi_mac_unmap_tx_skb(mac, info->skb, dmas);
+			freed = pasemi_mac_unmap_tx_skb(mac, nfrags,
+							info->skb, dmas);
 		} else
 			freed = 2;
 	}
@@ -749,6 +751,8 @@ static int pasemi_mac_clean_tx(struct pa
 	unsigned long flags;
 	struct sk_buff *skbs[TX_CLEAN_BATCHSIZE];
 	dma_addr_t dmas[TX_CLEAN_BATCHSIZE][MAX_SKB_FRAGS+1];
+	int nf[TX_CLEAN_BATCHSIZE];
+	int nr_frags;
 
 	total_count = 0;
 	batch_limit = TX_CLEAN_BATCHSIZE;
@@ -758,6 +762,8 @@ restart:
 	start = txring->next_to_clean;
 	ring_limit = txring->next_to_fill;
 
+	prefetch(&TX_DESC_INFO(txring, start+1).skb);
+
 	/* Compensate for when fill has wrapped but clean has not */
 	if (start > ring_limit)
 		ring_limit += TX_RING_SIZE;
@@ -771,6 +777,9 @@ restart:
 		u64 mactx = TX_DESC(txring, i);
 		struct sk_buff *skb;
 
+		skb = TX_DESC_INFO(txring, i+1).skb;
+		nr_frags = TX_DESC_INFO(txring, i).dma;
+
 		if ((mactx  & XCT_MACTX_E) ||
 		    (*chan->status & PAS_STATUS_ERROR))
 			pasemi_mac_tx_error(mac, mactx);
@@ -779,21 +788,22 @@ restart:
 			/* Not yet transmitted */
 			break;
 
-		skb = TX_DESC_INFO(txring, i+1).skb;
-		skbs[descr_count] = skb;
+		buf_count = 2 + nr_frags;
+		/* Since we always fill with an even number of entries, make
+		 * sure we skip any unused one at the end as well.
+		 */
+		if (buf_count & 1)
+			buf_count++;
 
-		buf_count = 2 + skb_shinfo(skb)->nr_frags;
-		for (j = 0; j <= skb_shinfo(skb)->nr_frags; j++)
+		for (j = 0; j <= nr_frags; j++)
 			dmas[descr_count][j] = TX_DESC_INFO(txring, i+1+j).dma;
 
+		skbs[descr_count] = skb;
+		nf[descr_count] = nr_frags;
+
 		TX_DESC(txring, i) = 0;
 		TX_DESC(txring, i+1) = 0;
 
-		/* Since we always fill with an even number of entries, make
-		 * sure we skip any unused one at the end as well.
-		 */
-		if (buf_count & 1)
-			buf_count++;
 		descr_count++;
 	}
 	txring->next_to_clean = i & (TX_RING_SIZE-1);
@@ -802,7 +812,7 @@ restart:
 	netif_wake_queue(mac->netdev);
 
 	for (i = 0; i < descr_count; i++)
-		pasemi_mac_unmap_tx_skb(mac, skbs[i], dmas[i]);
+		pasemi_mac_unmap_tx_skb(mac, nf[i], skbs[i], dmas[i]);
 
 	total_count += descr_count;
 
@@ -1299,6 +1309,7 @@ static int pasemi_mac_start_tx(struct sk
 	}
 
 	TX_DESC(txring, fill) = mactx;
+	TX_DESC_INFO(txring, fill).dma = nfrags;
 	fill++;
 	TX_DESC_INFO(txring, fill).skb = skb;
 	for (i = 0; i <= nfrags; i++) {
