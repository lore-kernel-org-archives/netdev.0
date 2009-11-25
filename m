From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH v3 5/7] via-velocity: Re-enable transmit scatter-gather
 support
Date: Wed, 25 Nov 2009 09:22:13 +0100
Message-ID: <20091125092213.423d0dd7@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091123152724.2871cf4d@marrow.netinsight.se>
	<20091123153133.2237b04c@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:41401 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752573AbZKYIWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 03:22:12 -0500
In-Reply-To: <20091123153133.2237b04c@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The velocity hardware can handle up to 7 memory segments. This can be
turned on and off via ethtool. The support was removed in commit

  83c98a8cd04dd0f848574370594886ba3bf56750

but is re-enabled and cleaned up here. It's off by default.

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
ChangeLog:

  * (David Miller) return NETDEV_TX_OK from the velocity_xmit
    function. I'm still a bit unsure on what to actually return in
    these cases (they are error cases), but other drivers seem to
    return NETDEV_TX_OK, so that's what I went with.

 drivers/net/via-velocity.c |   88 +++++++++++++++++++++++++++++---------------
 1 files changed, 58 insertions(+), 30 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 06a6d80..2ad25a9 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -9,7 +9,6 @@
  *
  * TODO
  *	rx_copybreak/alignment
- *	Scatter gather
  *	More testing
  *
  * The changes are (c) Copyright 2004, Red Hat Inc. <alan@lxorguk.ukuu.org.uk>
@@ -1656,12 +1655,10 @@ out:
  */
 static int velocity_init_td_ring(struct velocity_info *vptr)
 {
-	dma_addr_t curr;
 	int j;
 
 	/* Init the TD ring entries */
 	for (j = 0; j < vptr->tx.numq; j++) {
-		curr = vptr->tx.pool_dma[j];
 
 		vptr->tx.infos[j] = kcalloc(vptr->options.numtx,
 					    sizeof(struct velocity_td_info),
@@ -1727,21 +1724,27 @@ err_free_dma_rings_0:
  *	Release an transmit buffer. If the buffer was preallocated then
  *	recycle it, if not then unmap the buffer.
  */
-static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_info *tdinfo)
+static void velocity_free_tx_buf(struct velocity_info *vptr,
+		struct velocity_td_info *tdinfo, struct tx_desc *td)
 {
 	struct sk_buff *skb = tdinfo->skb;
-	int i;
-	int pktlen;
 
 	/*
 	 *	Don't unmap the pre-allocated tx_bufs
 	 */
 	if (tdinfo->skb_dma) {
+		int i;
 
-		pktlen = max_t(unsigned int, skb->len, ETH_ZLEN);
 		for (i = 0; i < tdinfo->nskb_dma; i++) {
-			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], pktlen, PCI_DMA_TODEVICE);
-			tdinfo->skb_dma[i] = 0;
+			size_t pktlen = max_t(size_t, skb->len, ETH_ZLEN);
+
+			/* For scatter-gather */
+			if (skb_shinfo(skb)->nr_frags > 0)
+				pktlen = max_t(size_t, pktlen,
+						td->td_buf[i].size & ~TD_QUEUE);
+
+			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i],
+					le16_to_cpu(pktlen), PCI_DMA_TODEVICE);
 		}
 	}
 	dev_kfree_skb_irq(skb);
@@ -1943,7 +1946,7 @@ static int velocity_tx_srv(struct velocity_info *vptr, u32 status)
 				stats->tx_packets++;
 				stats->tx_bytes += tdinfo->skb->len;
 			}
-			velocity_free_tx_buf(vptr, tdinfo);
+			velocity_free_tx_buf(vptr, tdinfo, td);
 			vptr->tx.used[qnum]--;
 		}
 		vptr->tx.tail[qnum] = idx;
@@ -2543,14 +2546,27 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	struct velocity_td_info *tdinfo;
 	unsigned long flags;
 	int pktlen;
-	__le16 len;
-	int index;
+	int index, prev;
+	int i = 0;
 
 	if (skb_padto(skb, ETH_ZLEN))
 		goto out;
-	pktlen = max_t(unsigned int, skb->len, ETH_ZLEN);
 
-	len = cpu_to_le16(pktlen);
+	/* The hardware can handle at most 7 memory segments, so merge
+	 * the skb if there are more */
+	if (skb_shinfo(skb)->nr_frags > 6 && __skb_linearize(skb)) {
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+	/* If it's still above 6 we can't do anything */
+	if (skb_shinfo(skb)->nr_frags > 6) {
+		dev_err(&vptr->pdev->dev,
+				"via-velocity: more than 6 frags, can't send.\n");
+		return NETDEV_TX_OK;
+	}
+	pktlen = skb_shinfo(skb)->nr_frags == 0 ?
+			max_t(unsigned int, skb->len, ETH_ZLEN) :
+				skb_headlen(skb);
 
 	spin_lock_irqsave(&vptr->lock, flags);
 
@@ -2567,11 +2583,24 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	 */
 	tdinfo->skb = skb;
 	tdinfo->skb_dma[0] = pci_map_single(vptr->pdev, skb->data, pktlen, PCI_DMA_TODEVICE);
-	td_ptr->tdesc0.len = len;
+	td_ptr->tdesc0.len = cpu_to_le16(pktlen);
 	td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
 	td_ptr->td_buf[0].pa_high = 0;
-	td_ptr->td_buf[0].size = len;
-	tdinfo->nskb_dma = 1;
+	td_ptr->td_buf[0].size = cpu_to_le16(pktlen);
+
+	/* Handle fragments */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		tdinfo->skb_dma[i + 1] = pci_map_page(vptr->pdev, frag->page,
+				frag->page_offset, frag->size,
+				PCI_DMA_TODEVICE);
+
+		td_ptr->td_buf[i + 1].pa_low = cpu_to_le32(tdinfo->skb_dma[i + 1]);
+		td_ptr->td_buf[i + 1].pa_high = 0;
+		td_ptr->td_buf[i + 1].size = cpu_to_le16(frag->size);
+	}
+	tdinfo->nskb_dma = i + 1;
 
 	td_ptr->tdesc1.cmd = TCPLS_NORMAL + (tdinfo->nskb_dma + 1) * 16;
 
@@ -2592,23 +2621,21 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 			td_ptr->tdesc1.TCR |= (TCR0_UDPCK);
 		td_ptr->tdesc1.TCR |= TCR0_IPCK;
 	}
-	{
 
-		int prev = index - 1;
+	prev = index - 1;
+	if (prev < 0)
+		prev = vptr->options.numtx - 1;
+	td_ptr->tdesc0.len |= OWNED_BY_NIC;
+	vptr->tx.used[qnum]++;
+	vptr->tx.curr[qnum] = (index + 1) % vptr->options.numtx;
 
-		if (prev < 0)
-			prev = vptr->options.numtx - 1;
-		td_ptr->tdesc0.len |= OWNED_BY_NIC;
-		vptr->tx.used[qnum]++;
-		vptr->tx.curr[qnum] = (index + 1) % vptr->options.numtx;
+	if (AVAIL_TD(vptr, qnum) < 1)
+		netif_stop_queue(dev);
 
-		if (AVAIL_TD(vptr, qnum) < 1)
-			netif_stop_queue(dev);
+	td_ptr = &(vptr->tx.rings[qnum][prev]);
+	td_ptr->td_buf[0].size |= TD_QUEUE;
+	mac_tx_queue_wake(vptr->mac_regs, qnum);
 
-		td_ptr = &(vptr->tx.rings[qnum][prev]);
-		td_ptr->td_buf[0].size |= TD_QUEUE;
-		mac_tx_queue_wake(vptr->mac_regs, qnum);
-	}
 	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&vptr->lock, flags);
 out:
@@ -3398,6 +3425,7 @@ static const struct ethtool_ops velocity_ethtool_ops = {
 	.set_wol	=	velocity_ethtool_set_wol,
 	.get_msglevel	=	velocity_get_msglevel,
 	.set_msglevel	=	velocity_set_msglevel,
+	.set_sg 	=	ethtool_op_set_sg,
 	.get_link	=	velocity_get_link,
 	.get_coalesce	=	velocity_get_coalesce,
 	.set_coalesce	=	velocity_set_coalesce,
-- 
1.6.0.4

