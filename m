From: Feng Tang <feng.tang@intel.com>
Subject: [PATCH] net: alx: Work around the DMA RX overflow issue
Date: Sun, 12 Jun 2016 17:36:37 +0800
Message-ID: <1465724197-26253-1-git-send-email-feng.tang@intel.com>
Cc: Feng Tang <feng.tang@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54558 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709AbcFLJmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jun 2016 05:42:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 26c5f03 uses a new skb allocator to avoid the RFD overflow
issue.

But from debugging without datasheet, we found the error always
happen when the DMA RX address is set to 0x....fc0, which is very
likely to be a HW/silicon problem.

So one idea is instead of adding a new allocator, why not just
hitting the right target by avaiding the error-prone DMA address?

This patch will actually
* Remove the commit 26c5f03
* Apply rx skb with 64 bytes longer space, and if the allocated skb
  has a 0x...fc0 address, it will use skb_resever(skb, 64) to
  advance the address, so that the RX overflow can be avoided.

In theory this method should also apply to atl1c driver, which
I can't find anyone who can help to test on real devices.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=70761
Signed-off-by: Feng Tang <feng.tang@intel.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
Tested-by: Ole Lukoie <olelukoie@mail.ru>
---
 drivers/net/ethernet/atheros/alx/alx.h  |  4 ---
 drivers/net/ethernet/atheros/alx/main.c | 61 ++++++++-------------------------
 2 files changed, 14 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
index d02c424..8fc93c5 100644
--- a/drivers/net/ethernet/atheros/alx/alx.h
+++ b/drivers/net/ethernet/atheros/alx/alx.h
@@ -96,10 +96,6 @@ struct alx_priv {
 	unsigned int rx_ringsz;
 	unsigned int rxbuf_size;
 
-	struct page  *rx_page;
-	unsigned int rx_page_offset;
-	unsigned int rx_frag_size;
-
 	struct napi_struct napi;
 	struct alx_tx_queue txq;
 	struct alx_rx_queue rxq;
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c98acdc..e708e36 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -70,35 +70,6 @@ static void alx_free_txbuf(struct alx_priv *alx, int entry)
 	}
 }
 
-static struct sk_buff *alx_alloc_skb(struct alx_priv *alx, gfp_t gfp)
-{
-	struct sk_buff *skb;
-	struct page *page;
-
-	if (alx->rx_frag_size > PAGE_SIZE)
-		return __netdev_alloc_skb(alx->dev, alx->rxbuf_size, gfp);
-
-	page = alx->rx_page;
-	if (!page) {
-		alx->rx_page = page = alloc_page(gfp);
-		if (unlikely(!page))
-			return NULL;
-		alx->rx_page_offset = 0;
-	}
-
-	skb = build_skb(page_address(page) + alx->rx_page_offset,
-			alx->rx_frag_size);
-	if (likely(skb)) {
-		alx->rx_page_offset += alx->rx_frag_size;
-		if (alx->rx_page_offset >= PAGE_SIZE)
-			alx->rx_page = NULL;
-		else
-			get_page(page);
-	}
-	return skb;
-}
-
-
 static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
 {
 	struct alx_rx_queue *rxq = &alx->rxq;
@@ -115,9 +86,22 @@ static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
 	while (!cur_buf->skb && next != rxq->read_idx) {
 		struct alx_rfd *rfd = &rxq->rfd[cur];
 
-		skb = alx_alloc_skb(alx, gfp);
+		/*
+		 * When DMA RX address is set to something like
+		 * 0x....fc0, it will be very likely to cause DMA
+		 * RFD overflow issue.
+		 *
+		 * To work around it, we apply rx skb with 64 bytes
+		 * longer space, and offset the address whenever
+		 * 0x....fc0 is detected.
+		 */
+		skb = __netdev_alloc_skb(alx->dev, alx->rxbuf_size + 64, gfp);
 		if (!skb)
 			break;
+
+		if (((unsigned long)skb->data & 0xfff) == 0xfc0)
+			skb_reserve(skb, 64);
+
 		dma = dma_map_single(&alx->hw.pdev->dev,
 				     skb->data, alx->rxbuf_size,
 				     DMA_FROM_DEVICE);
@@ -153,7 +137,6 @@ static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
 		alx_write_mem16(&alx->hw, ALX_RFD_PIDX, cur);
 	}
 
-
 	return count;
 }
 
@@ -622,11 +605,6 @@ static void alx_free_rings(struct alx_priv *alx)
 	kfree(alx->txq.bufs);
 	kfree(alx->rxq.bufs);
 
-	if (alx->rx_page) {
-		put_page(alx->rx_page);
-		alx->rx_page = NULL;
-	}
-
 	dma_free_coherent(&alx->hw.pdev->dev,
 			  alx->descmem.size,
 			  alx->descmem.virt,
@@ -681,7 +659,6 @@ static int alx_request_irq(struct alx_priv *alx)
 				  alx->dev->name, alx);
 		if (!err)
 			goto out;
-
 		/* fall back to legacy interrupt */
 		pci_disable_msi(alx->hw.pdev);
 	}
@@ -725,7 +702,6 @@ static int alx_init_sw(struct alx_priv *alx)
 	struct pci_dev *pdev = alx->hw.pdev;
 	struct alx_hw *hw = &alx->hw;
 	int err;
-	unsigned int head_size;
 
 	err = alx_identify_hw(alx);
 	if (err) {
@@ -741,12 +717,7 @@ static int alx_init_sw(struct alx_priv *alx)
 
 	hw->smb_timer = 400;
 	hw->mtu = alx->dev->mtu;
-
 	alx->rxbuf_size = ALX_MAX_FRAME_LEN(hw->mtu);
-	head_size = SKB_DATA_ALIGN(alx->rxbuf_size + NET_SKB_PAD) +
-		    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-	alx->rx_frag_size = roundup_pow_of_two(head_size);
-
 	alx->tx_ringsz = 256;
 	alx->rx_ringsz = 512;
 	hw->imt = 200;
@@ -848,7 +819,6 @@ static int alx_change_mtu(struct net_device *netdev, int mtu)
 {
 	struct alx_priv *alx = netdev_priv(netdev);
 	int max_frame = ALX_MAX_FRAME_LEN(mtu);
-	unsigned int head_size;
 
 	if ((max_frame < ALX_MIN_FRAME_SIZE) ||
 	    (max_frame > ALX_MAX_FRAME_SIZE))
@@ -860,9 +830,6 @@ static int alx_change_mtu(struct net_device *netdev, int mtu)
 	netdev->mtu = mtu;
 	alx->hw.mtu = mtu;
 	alx->rxbuf_size = max(max_frame, ALX_DEF_RXBUF_SIZE);
-	head_size = SKB_DATA_ALIGN(alx->rxbuf_size + NET_SKB_PAD) +
-		    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-	alx->rx_frag_size = roundup_pow_of_two(head_size);
 	netdev_update_features(netdev);
 	if (netif_running(netdev))
 		alx_reinit(alx);
-- 
2.5.0
