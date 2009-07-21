From: Dave Jones <davej@redhat.com>
Subject: [1/4] Remove unused zero-copy code from velocity NIC driver.
Date: Mon, 20 Jul 2009 23:34:56 -0400
Message-ID: <200907211640.n6LGeH7l011444@gelk.kernelslacker.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52608 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755753AbZGUQkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 12:40:18 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n6LGeJAL001591
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:19 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n6LGeItk025773
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:18 -0400
Received: from gelk.kernelslacker.org (vpn-10-139.bos.redhat.com [10.16.10.139])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n6LGeHD4015095
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:17 -0400
Received: from gelk.kernelslacker.org (gelk.kernelslacker.org [127.0.0.1])
	by gelk.kernelslacker.org (8.14.3/8.14.3) with ESMTP id n6LGeHqk011445
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code hasn't been enabled in forever.

Signed-off-by: Dave Jones <davej@redhat.com>
---
 drivers/net/via-velocity.c |   77 ++++++-------------------------------------
 1 files changed, 11 insertions(+), 66 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 3ba3595..4ebe2ca 100644
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
 
 		pktlen = max_t(unsigned int, skb->len, ETH_ZLEN);
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
-- 
1.6.2.5

