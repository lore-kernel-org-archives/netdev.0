From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] myri10ge: check for pci_map_page errors
Date: Thu, 7 Aug 2014 14:02:22 +0200
Message-ID: <20140807120222.GA12461@redhat.com>
References: <20140806132516.GA3222@redhat.com>
 <CAOJe8K1EwVpGeiMSwSX98-Vonxb-2N2nbYVyEVJjZPsu-3=R+Q@mail.gmail.com>
 <20140806.134851.991301500346816280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kda@linux-powerpc.org, netdev@vger.kernel.org, hykim@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28056 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754303AbaHGMEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2014 08:04:23 -0400
Content-Disposition: inline
In-Reply-To: <20140806.134851.991301500346816280.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 06, 2014 at 01:48:51PM -0700, David Miller wrote:
> From: Denis Kirjanov <kda@linux-powerpc.org>
> Date: Wed, 6 Aug 2014 18:47:48 +0400
> 
> > On 8/6/14, Stanislaw Gruszka <sgruszka@redhat.com> wrote:
> >> On IOMMU systems DMA mapping can fail, we need to check for that
> >> possibility.
> >>
> >> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> >> ---
> >>  drivers/net/ethernet/myricom/myri10ge/myri10ge.c | 21
> >> ++++++++++++++++++---
> >>  1 file changed, 18 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> >> b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> >> index f3d5d79..17f869a 100644
> >> --- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> >> +++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> > 
> > You did miss the one in myri10ge_xmit
> 
> Indeed, Stanislaw please take care of that case too and resubmit
> this patch.

Fixing myri10ge_xmit is not trivial. I prepared below patch, but
I need to test it with fault injection to cover each case.
I'll post it after finish testing.

Stanislaw  

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index f3d5d79..a173c98 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -872,6 +872,10 @@ static int myri10ge_dma_test(struct myri10ge_priv *mgp, int test_type)
 		return -ENOMEM;
 	dmatest_bus = pci_map_page(mgp->pdev, dmatest_page, 0, PAGE_SIZE,
 				   DMA_BIDIRECTIONAL);
+	if (unlikely(pci_dma_mapping_error(mgp->pdev, dmatest_bus))) {
+		__free_page(dmatest_page);
+		return -ENOMEM;
+	}
 
 	/* Run a small DMA test.
 	 * The magic multipliers to the length tell the firmware
@@ -1293,6 +1297,7 @@ myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 			int bytes, int watchdog)
 {
 	struct page *page;
+	dma_addr_t bus;
 	int idx;
 #if MYRI10GE_ALLOC_SIZE > 4096
 	int end_offset;
@@ -1317,11 +1322,21 @@ myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 					rx->watchdog_needed = 1;
 				return;
 			}
+
+			bus = pci_map_page(mgp->pdev, page, 0,
+					   MYRI10GE_ALLOC_SIZE,
+					   PCI_DMA_FROMDEVICE);
+			if (unlikely(pci_dma_mapping_error(mgp->pdev, bus))) {
+				__free_pages(page, MYRI10GE_ALLOC_ORDER);
+				if (rx->fill_cnt - rx->cnt < 16)
+					rx->watchdog_needed = 1;
+				return;
+			}
+
 			rx->page = page;
 			rx->page_offset = 0;
-			rx->bus = pci_map_page(mgp->pdev, page, 0,
-					       MYRI10GE_ALLOC_SIZE,
-					       PCI_DMA_FROMDEVICE);
+			rx->bus = bus;
+
 		}
 		rx->info[idx].page = rx->page;
 		rx->info[idx].page_offset = rx->page_offset;
@@ -2763,6 +2778,35 @@ myri10ge_submit_req(struct myri10ge_tx_buf *tx, struct mcp_kreq_ether_send *src,
 	mb();
 }
 
+static void myri10ge_unmap_tx_dma(struct myri10ge_priv *mgp,
+				  struct myri10ge_tx_buf *tx, int idx)
+{
+	unsigned int len;
+	int last_idx;
+
+	/* Free any DMA resources we've alloced and clear out the skb slot */
+	last_idx = (idx + 1) & tx->mask;
+	idx = tx->req & tx->mask;
+	do {
+		len = dma_unmap_len(&tx->info[idx], len);
+		if (len) {
+			if (tx->info[idx].skb != NULL)
+				pci_unmap_single(mgp->pdev,
+						 dma_unmap_addr(&tx->info[idx],
+								bus), len,
+						 PCI_DMA_TODEVICE);
+			else
+				pci_unmap_page(mgp->pdev,
+					       dma_unmap_addr(&tx->info[idx],
+							      bus), len,
+					       PCI_DMA_TODEVICE);
+			dma_unmap_len_set(&tx->info[idx], len, 0);
+			tx->info[idx].skb = NULL;
+		}
+		idx = (idx + 1) & tx->mask;
+	} while (idx != last_idx);
+}
+
 /*
  * Transmit a packet.  We need to split the packet so that a single
  * segment does not cross myri10ge->tx_boundary, so this makes segment
@@ -2786,7 +2830,7 @@ static netdev_tx_t myri10ge_xmit(struct sk_buff *skb,
 	u32 low;
 	__be32 high_swapped;
 	unsigned int len;
-	int idx, last_idx, avail, frag_cnt, frag_idx, count, mss, max_segments;
+	int idx, avail, frag_cnt, frag_idx, count, mss, max_segments;
 	u16 pseudo_hdr_offset, cksum_offset, queue;
 	int cum_len, seglen, boundary, rdma_count;
 	u8 flags, odd_flag;
@@ -2883,9 +2927,12 @@ again:
 
 	/* map the skb for DMA */
 	len = skb_headlen(skb);
+	bus = pci_map_single(mgp->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	if (unlikely(pci_dma_mapping_error(mgp->pdev, bus)))
+		goto drop;
+
 	idx = tx->req & tx->mask;
 	tx->info[idx].skb = skb;
-	bus = pci_map_single(mgp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 	dma_unmap_addr_set(&tx->info[idx], bus, bus);
 	dma_unmap_len_set(&tx->info[idx], len, len);
 
@@ -2984,12 +3031,16 @@ again:
 			break;
 
 		/* map next fragment for DMA */
-		idx = (count + tx->req) & tx->mask;
 		frag = &skb_shinfo(skb)->frags[frag_idx];
 		frag_idx++;
 		len = skb_frag_size(frag);
 		bus = skb_frag_dma_map(&mgp->pdev->dev, frag, 0, len,
 				       DMA_TO_DEVICE);
+		if (unlikely(pci_dma_mapping_error(mgp->pdev, bus))) {
+			myri10ge_unmap_tx_dma(mgp, tx, idx);
+			goto drop;
+		}
+		idx = (count + tx->req) & tx->mask;
 		dma_unmap_addr_set(&tx->info[idx], bus, bus);
 		dma_unmap_len_set(&tx->info[idx], len, len);
 	}
@@ -3020,31 +3071,8 @@ again:
 	return NETDEV_TX_OK;
 
 abort_linearize:
-	/* Free any DMA resources we've alloced and clear out the skb
-	 * slot so as to not trip up assertions, and to avoid a
-	 * double-free if linearizing fails */
+	myri10ge_unmap_tx_dma(mgp, tx, idx);
 
-	last_idx = (idx + 1) & tx->mask;
-	idx = tx->req & tx->mask;
-	tx->info[idx].skb = NULL;
-	do {
-		len = dma_unmap_len(&tx->info[idx], len);
-		if (len) {
-			if (tx->info[idx].skb != NULL)
-				pci_unmap_single(mgp->pdev,
-						 dma_unmap_addr(&tx->info[idx],
-								bus), len,
-						 PCI_DMA_TODEVICE);
-			else
-				pci_unmap_page(mgp->pdev,
-					       dma_unmap_addr(&tx->info[idx],
-							      bus), len,
-					       PCI_DMA_TODEVICE);
-			dma_unmap_len_set(&tx->info[idx], len, 0);
-			tx->info[idx].skb = NULL;
-		}
-		idx = (idx + 1) & tx->mask;
-	} while (idx != last_idx);
 	if (skb_is_gso(skb)) {
 		netdev_err(mgp->dev, "TSO but wanted to linearize?!?!?\n");
 		goto drop;
