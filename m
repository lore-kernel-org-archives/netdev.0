From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: skge driver oops
Date: Fri, 26 May 2006 08:17:37 -0700
Message-ID: <20060526081737.5c5b422f@localhost.localdomain>
References: <BB1F4EFD574E9F409035BDA71C9612500241A2@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'Krzysztof Oledzki'" <olel@ans.pl>, netdev@vger.kernel.org,
	"'david@mantara.com'" <david@mantara.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58771 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750877AbWEZPSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 11:18:00 -0400
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
In-Reply-To: <BB1F4EFD574E9F409035BDA71C9612500241A2@exchange.i-bn>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please give this a try, it rearranges the transmit buffer management,
and may avoid issues with partial completions causing SKB reuse.

--- skge.orig/drivers/net/skge.c
+++ skge/drivers/net/skge.c
@@ -2372,7 +2372,8 @@ static int skge_xmit_frame(struct sk_buf
 					   frag->size, PCI_DMA_TODEVICE);
 
 			e = e->next;
-			e->skb = NULL;
+			e->skb = skb;
+
 			tf = e->desc;
 			tf->dma_lo = map;
 			tf->dma_hi = (u64) map >> 32;
@@ -2408,36 +2409,42 @@ static int skge_xmit_frame(struct sk_buf
 	return NETDEV_TX_OK;
 }
 
-static void skge_tx_complete(struct skge_port *skge, struct skge_element *last)
+
+static void skge_tx_done(struct skge_port *skge, struct skge_element *e)
 {
 	struct pci_dev *pdev = skge->hw->pdev;
-	struct skge_element *e;
+	const struct skge_tx_desc *td = e->desc;
 
-	for (e = skge->tx_ring.to_clean; e != last; e = e->next) {
-		struct sk_buff *skb = e->skb;
-		int i;
-
-		e->skb = NULL;
+	/* skb header vs. fragment */
+	if (td->control & BMU_STF)
 		pci_unmap_single(pdev, pci_unmap_addr(e, mapaddr),
-				 skb_headlen(skb), PCI_DMA_TODEVICE);
+				 pci_unmap_len(e, maplen),
+				 PCI_DMA_TODEVICE);
+	else
+		pci_unmap_page(pdev, pci_unmap_addr(e, mapaddr),
+			       pci_unmap_len(e, maplen),
+			       PCI_DMA_TODEVICE);
 
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			e = e->next;
-			pci_unmap_page(pdev, pci_unmap_addr(e, mapaddr),
-				       skb_shinfo(skb)->frags[i].size,
-				       PCI_DMA_TODEVICE);
-		}
+	if (td->control & BMU_EOF) {
+		if (unlikely(netif_msg_tx_done(skge)))
+			printk(KERN_DEBUG PFX "%s: tx done slot %td\n",
+			       skge->netdev->name, e - skge->tx_ring.start);
 
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(e->skb);
 	}
-	skge->tx_ring.to_clean = e;
+	e->skb = NULL;
 }
 
+/* Free all buffers in transmit ring */
 static void skge_tx_clean(struct skge_port *skge)
 {
+	struct skge_element *e;
 
 	spin_lock_bh(&skge->tx_lock);
-	skge_tx_complete(skge, skge->tx_ring.to_use);
+	for (e = skge->tx_ring.to_clean; e != skge->tx_ring.to_use; e = e->next)
+		skge_tx_done(skge, e);
+
+	skge->tx_ring.to_clean = e;
 	netif_wake_queue(skge->netdev);
 	spin_unlock_bh(&skge->tx_lock);
 }
@@ -2665,30 +2672,24 @@ resubmit:
 	return NULL;
 }
 
-static void skge_tx_done(struct skge_port *skge)
+/* Free all buffers in Tx ring which are no longer owned by device */
+static void skge_tx_complete(struct skge_port *skge)
 {
 	struct skge_ring *ring = &skge->tx_ring;
-	struct skge_element *e, *last;
+	struct skge_element *e;
 
 	spin_lock(&skge->tx_lock);
-	last = ring->to_clean;
+	skge_write8(skge->hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_IRQ_CL_F);
+
 	for (e = ring->to_clean; e != ring->to_use; e = e->next) {
 		struct skge_tx_desc *td = e->desc;
 
 		if (td->control & BMU_OWN)
 			break;
 
-		if (td->control & BMU_EOF) {
-			last = e->next;
-			if (unlikely(netif_msg_tx_done(skge)))
-				printk(KERN_DEBUG PFX "%s: tx done slot %td\n",
-				       skge->netdev->name, e - ring->start);
-		}
+		skge_tx_done(skge, e);
 	}
-
-	skge_tx_complete(skge, last);
-
-	skge_write8(skge->hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_IRQ_CL_F);
+	skge->tx_ring.to_clean = e;
 
 	if (skge_avail(&skge->tx_ring) > TX_LOW_WATER)
 		netif_wake_queue(skge->netdev);
@@ -2705,7 +2706,7 @@ static int skge_poll(struct net_device *
 	int to_do = min(dev->quota, *budget);
 	int work_done = 0;
 
-	skge_tx_done(skge);
+	skge_tx_complete(skge);
 
 	for (e = ring->to_clean; prefetch(e->next), work_done < to_do; e = e->next) {
 		struct skge_rx_desc *rd = e->desc;
