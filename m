From: Dave Jones <davej@redhat.com>
Subject: Re: velocity driver unmaps incorrect size.
Date: Sun, 21 Jun 2009 22:51:55 -0400
Message-ID: <20090622025155.GB3157@redhat.com>
References: <20090621173745.GC26093@redhat.com> <20090621.184345.194558005.davem@davemloft.net> <20090622024044.GA3157@redhat.com> <20090621.194248.72335974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60346 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752423AbZFVCvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 22:51:55 -0400
Content-Disposition: inline
In-Reply-To: <20090621.194248.72335974.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 21, 2009 at 07:42:48PM -0700, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Sun, 21 Jun 2009 22:40:44 -0400
 > 
 > > On Sun, Jun 21, 2009 at 06:43:45PM -0700, David Miller wrote:
 > > 
 > >  > Is it possible that for some reason
 > >  > your build is forcing VELOCITY_ZERO_COPY_SUPPORT to be defined
 > >  > for some reason?
 > > 
 > > Memory corruption maybe?
 > > It's especially odd in that it only happens once during boot,
 > > and never happens again. This is my firewall/router, so there's
 > > more packets going through that box than any other I have.
 > 
 > I would not be inclined to this theory.  Regardless of what garbage is
 > read from skb->len, it's always going to be at least ETH_ZLEN due to
 > the "max of skb->len and ETH_ZLEN" assignment there.

Yeah, seems unlikely.  Compiler bug seems unlikely too, given it's a one-off.
I'll see if I can come up with some other debug patches to figure out what's
going on in there.

 > > btw, given the zerocopy stuff has been disabled for so long,
 > > is it worth keeping it ?
 > 
 > I'm pretty sure it should be tossed.  I wonder if anyone even tries
 > to build that code these days.



Remove unused Velocity zero copy code.

This code hasn't been enabled in years.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index b02f7ad..faae32c 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -976,9 +976,6 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 	dev->netdev_ops = &velocity_netdev_ops;
 	dev->ethtool_ops = &velocity_ethtool_ops;
 
-#ifdef  VELOCITY_ZERO_COPY_SUPPORT
-	dev->features |= NETIF_F_SG;
-#endif
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
 		NETIF_F_HW_VLAN_RX;
 
@@ -1849,11 +1846,7 @@ static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_
 
 		pktlen = (skb->len > ETH_ZLEN ? : ETH_ZLEN);
 		for (i = 0; i < tdinfo->nskb_dma; i++) {
-#ifdef VELOCITY_ZERO_COPY_SUPPORT
-			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], le16_to_cpu(td->tdesc1.len), PCI_DMA_TODEVICE);
-#else
 			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], pktlen, PCI_DMA_TODEVICE);
-#endif
 			tdinfo->skb_dma[i] = 0;
 		}
 	}
@@ -2095,13 +2088,6 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	len = cpu_to_le16(pktlen);
 
-#ifdef VELOCITY_ZERO_COPY_SUPPORT
-	if (skb_shinfo(skb)->nr_frags > 6 && __skb_linearize(skb)) {
-		kfree_skb(skb);
-		return 0;
-	}
-#endif
-
 	spin_lock_irqsave(&vptr->lock, flags);
 
 	index = vptr->tx.curr[qnum];
@@ -2111,59 +2097,18 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 	td_ptr->tdesc1.TCR = TCR0_TIC;
 	td_ptr->td_buf[0].size &= ~TD_QUEUE;
 
-#ifdef VELOCITY_ZERO_COPY_SUPPORT
-	if (skb_shinfo(skb)->nr_frags > 0) {
-		int nfrags = skb_shinfo(skb)->nr_frags;
-		tdinfo->skb = skb;
-		if (nfrags > 6) {
-			skb_copy_from_linear_data(skb, tdinfo->buf, skb->len);
-			tdinfo->skb_dma[0] = tdinfo->buf_dma;
-			td_ptr->tdesc0.len = len;
-			td_ptr->tx.buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
-			td_ptr->tx.buf[0].pa_high = 0;
-			td_ptr->tx.buf[0].size = len;	/* queue is 0 anyway */
-			tdinfo->nskb_dma = 1;
-		} else {
-			int i = 0;
-			tdinfo->nskb_dma = 0;
-			tdinfo->skb_dma[i] = pci_map_single(vptr->pdev, skb->data,
-						skb_headlen(skb), PCI_DMA_TODEVICE);
-
-			td_ptr->tdesc0.len = len;
-
-			/* FIXME: support 48bit DMA later */
-			td_ptr->tx.buf[i].pa_low = cpu_to_le32(tdinfo->skb_dma);
-			td_ptr->tx.buf[i].pa_high = 0;
-			td_ptr->tx.buf[i].size = cpu_to_le16(skb_headlen(skb));
-
-			for (i = 0; i < nfrags; i++) {
-				skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-				void *addr = (void *)page_address(frag->page) + frag->page_offset;
-
-				tdinfo->skb_dma[i + 1] = pci_map_single(vptr->pdev, addr, frag->size, PCI_DMA_TODEVICE);
-
-				td_ptr->tx.buf[i + 1].pa_low = cpu_to_le32(tdinfo->skb_dma[i + 1]);
-				td_ptr->tx.buf[i + 1].pa_high = 0;
-				td_ptr->tx.buf[i + 1].size = cpu_to_le16(frag->size);
-			}
-			tdinfo->nskb_dma = i - 1;
-		}
+	/*
+	 *	Map the linear network buffer into PCI space and
+	 *	add it to the transmit ring.
+	 */
+	tdinfo->skb = skb;
+	tdinfo->skb_dma[0] = pci_map_single(vptr->pdev, skb->data, pktlen, PCI_DMA_TODEVICE);
+	td_ptr->tdesc0.len = len;
+	td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
+	td_ptr->td_buf[0].pa_high = 0;
+	td_ptr->td_buf[0].size = len;
+	tdinfo->nskb_dma = 1;
 
-	} else
-#endif
-	{
-		/*
-		 *	Map the linear network buffer into PCI space and
-		 *	add it to the transmit ring.
-		 */
-		tdinfo->skb = skb;
-		tdinfo->skb_dma[0] = pci_map_single(vptr->pdev, skb->data, pktlen, PCI_DMA_TODEVICE);
-		td_ptr->tdesc0.len = len;
-		td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
-		td_ptr->td_buf[0].pa_high = 0;
-		td_ptr->td_buf[0].size = len;
-		tdinfo->nskb_dma = 1;
-	}
 	td_ptr->tdesc1.cmd = TCPLS_NORMAL + (tdinfo->nskb_dma + 1) * 16;
 
 	if (vptr->vlgrp && vlan_tx_tag_present(skb)) {
