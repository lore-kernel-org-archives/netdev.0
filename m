From: David Miller <davem@davemloft.net>
Subject: Re: via-velocity dma-debug warnings again. (2.6.35.2)
Date: Wed, 01 Sep 2010 13:34:14 -0700 (PDT)
Message-ID: <20100901.133414.24593005.davem@davemloft.net>
References: <20100901122059.5761802f@marrow.netinsight.se>
	<20100901.130333.148556201.davem@davemloft.net>
	<20100901200555.GA30689@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.kagstrom@netinsight.net, netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45137
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752142Ab0IAUd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 16:33:57 -0400
In-Reply-To: <20100901200555.GA30689@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 1 Sep 2010 16:05:55 -0400

> On Wed, Sep 01, 2010 at 01:03:33PM -0700, David Miller wrote:
>  > You'll have to use exactly the same formula for computing the length
>  > as the pci_map_single() call uses, which is:
>  > 
>  > 	pktlen = skb_shinfo(skb)->nr_frags == 0 ?
>  > 			max_t(unsigned int, skb->len, ETH_ZLEN) :
>  > 				skb_headlen(skb);
>  > 
>  > Otherwise packets smaller than ETH_ZLEN will be unmapped properly
>  > and trigger the same kind of debugging checks Dave is seeing.
> 
> Looks like you're right.
> 
> [ 5674.506024] via-velocity 0000:00:0e.0: DMA-API: device driver frees DMA memory with different size [device address=0x0000000018e555fa] [map size=54 bytes] [unmap size=108 bytes]

Looking more closely at this driver, it is ALL KINDS OF MESSED UP and
is full of mega-lulz wrt. TX dma mapping handling.

It computes a length as an integer, with an override that comes from
the TX descriptor.  Then it unconditionally little-endian converts
the thing.

First, it uses pci_unmap_single() instead of pci_unmap_page() for the
fragments.

Second, for a fragmented SKB it fetches the length from the descriptor
which as we saw can be modified by the chip.

Third, it makes NULL pointer checks that make absolutely no sense.
It checks "td_info->skb_dma" which is an array, that will never be
NULL.  It also checks &(vptr->tx.infos[q][n]) against NULL which
will not be NULL even if vptr->tx.infos is which is maybe what it
meant to check.

Let's try to unravel all of this mess.

Dave can you test out this patch?

Ugh, while writing this I spotted another bug.  It can't do this
ETH_ZLEN thing, it has to use skb_padto().  Otherwise it's just
transmitting arbitrary kernel memory at the end of the SKB
buffer onto the network which is a big no-no.  I'll fix that
with another patch.

via-velocity: Fix TX buffer unmapping.

Fix several bugs in TX buffer DMA unmapping:

1) Use pci_unmap_page() as appropriate.

2) Don't try to fetch the length from the DMA descriptor,
   the chip and modify that value.  Use the correct lengths,
   calculated the same way as is done at map time.

3) Kill meaningless NULL checks (against embedded sized
   arrays which can never be NULL, and against the address
   of the non-zero indexed entry of an array).

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index fd69095..d5873ac 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1696,6 +1696,13 @@ err_free_dma_rings_0:
 	goto out;
 }
 
+static inline int tx_skb_headlen(struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->nr_frags == 0 ?
+		max_t(unsigned int, skb->len, ETH_ZLEN) :
+		skb_headlen(skb);
+}
+
 /**
  *	velocity_free_tx_buf	-	free transmit buffer
  *	@vptr: velocity
@@ -1705,28 +1712,21 @@ err_free_dma_rings_0:
  *	recycle it, if not then unmap the buffer.
  */
 static void velocity_free_tx_buf(struct velocity_info *vptr,
-		struct velocity_td_info *tdinfo, struct tx_desc *td)
+		struct velocity_td_info *tdinfo)
 {
 	struct sk_buff *skb = tdinfo->skb;
+	int i;
 
-	/*
-	 *	Don't unmap the pre-allocated tx_bufs
-	 */
-	if (tdinfo->skb_dma) {
-		int i;
-
-		for (i = 0; i < tdinfo->nskb_dma; i++) {
-			size_t pktlen = max_t(size_t, skb->len, ETH_ZLEN);
+	pci_unmap_single(vptr->pdev, tdinfo->skb_dma[0],
+			 tx_skb_headlen(skb), PCI_DMA_TODEVICE);
 
-			/* For scatter-gather */
-			if (skb_shinfo(skb)->nr_frags > 0)
-				pktlen = max_t(size_t, pktlen,
-						td->td_buf[i].size & ~TD_QUEUE);
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i],
-					le16_to_cpu(pktlen), PCI_DMA_TODEVICE);
-		}
+		pci_unmap_page(vptr->pdev, tdinfo->skb_dma[i + 1],
+			       frag->size, PCI_DMA_TODEVICE);
 	}
+
 	dev_kfree_skb_irq(skb);
 	tdinfo->skb = NULL;
 }
@@ -1739,22 +1739,8 @@ static void velocity_free_td_ring_entry(struct velocity_info *vptr,
 							 int q, int n)
 {
 	struct velocity_td_info *td_info = &(vptr->tx.infos[q][n]);
-	int i;
-
-	if (td_info == NULL)
-		return;
 
-	if (td_info->skb) {
-		for (i = 0; i < td_info->nskb_dma; i++) {
-			if (td_info->skb_dma[i]) {
-				pci_unmap_single(vptr->pdev, td_info->skb_dma[i],
-					td_info->skb->len, PCI_DMA_TODEVICE);
-				td_info->skb_dma[i] = 0;
-			}
-		}
-		dev_kfree_skb(td_info->skb);
-		td_info->skb = NULL;
-	}
+	velocity_free_tx_buf(vptr, td_info);
 }
 
 /**
@@ -1925,7 +1911,7 @@ static int velocity_tx_srv(struct velocity_info *vptr)
 				stats->tx_packets++;
 				stats->tx_bytes += tdinfo->skb->len;
 			}
-			velocity_free_tx_buf(vptr, tdinfo, td);
+			velocity_free_tx_buf(vptr, tdinfo);
 			vptr->tx.used[qnum]--;
 		}
 		vptr->tx.tail[qnum] = idx;
@@ -2534,9 +2520,7 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	pktlen = skb_shinfo(skb)->nr_frags == 0 ?
-			max_t(unsigned int, skb->len, ETH_ZLEN) :
-				skb_headlen(skb);
+	pktlen = tx_skb_headlen(skb);
 
 	spin_lock_irqsave(&vptr->lock, flags);
 
