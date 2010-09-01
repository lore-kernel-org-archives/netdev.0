From: David Miller <davem@davemloft.net>
Subject: Re: via-velocity dma-debug warnings again. (2.6.35.2)
Date: Wed, 01 Sep 2010 13:37:33 -0700 (PDT)
Message-ID: <20100901.133733.223467599.davem@davemloft.net>
References: <20100901200555.GA30689@redhat.com>
	<20100901.133414.24593005.davem@davemloft.net>
	<20100901.133547.236248297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.kagstrom@netinsight.net, netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36968
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751564Ab0IAUhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 16:37:16 -0400
In-Reply-To: <20100901.133547.236248297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 01 Sep 2010 13:35:47 -0700 (PDT)

> From: David Miller <davem@davemloft.net>
> Date: Wed, 01 Sep 2010 13:34:14 -0700 (PDT)
> 
>> Ugh, while writing this I spotted another bug.  It can't do this
>> ETH_ZLEN thing, it has to use skb_padto().  Otherwise it's just
>> transmitting arbitrary kernel memory at the end of the SKB
>> buffer onto the network which is a big no-no.  I'll fix that
>> with another patch.
> 
> Actually, these ETH_ZLEN things in the length calculation can
> just be deleted. It does in fact use skb_padto() properly earlier
> in the xmit function.

New patch:

via-velocity: Fix TX buffer unmapping.

Fix several bugs in TX buffer DMA unmapping:

1) Use pci_unmap_page() as appropriate.

2) Don't try to fetch the length from the DMA descriptor,
   the chip and modify that value.  Use the correct lengths,
   calculated the same way as is done at map time.

3) Kill meaningless NULL checks (against embedded sized
   arrays which can never be NULL, and against the address
   of the non-zero indexed entry of an array).

4) max() on ETH_ZLEN is not necessary and just adds
   confusion, since the xmit function does a proper
   skb_padto() very early on.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index fd69095..4167e1f 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1705,28 +1705,21 @@ err_free_dma_rings_0:
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
+			 skb_headlen(skb), PCI_DMA_TODEVICE);
 
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
@@ -1739,22 +1732,8 @@ static void velocity_free_td_ring_entry(struct velocity_info *vptr,
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
@@ -1925,7 +1904,7 @@ static int velocity_tx_srv(struct velocity_info *vptr)
 				stats->tx_packets++;
 				stats->tx_bytes += tdinfo->skb->len;
 			}
-			velocity_free_tx_buf(vptr, tdinfo, td);
+			velocity_free_tx_buf(vptr, tdinfo);
 			vptr->tx.used[qnum]--;
 		}
 		vptr->tx.tail[qnum] = idx;
@@ -2534,9 +2513,7 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	pktlen = skb_shinfo(skb)->nr_frags == 0 ?
-			max_t(unsigned int, skb->len, ETH_ZLEN) :
-				skb_headlen(skb);
+	pktlen = skb_headlen(skb);
 
 	spin_lock_irqsave(&vptr->lock, flags);
 
