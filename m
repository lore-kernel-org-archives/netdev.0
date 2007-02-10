From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH: 3/5]: spidernet: fix racy double-free of skb
Date: Fri, 9 Feb 2007 18:19:56 -0600
Message-ID: <20070210001956.GC2396@austin.ibm.com>
References: <20070210000128.GJ5616@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:43561 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946791AbXBJAUX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 19:20:23 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1A0KKFg018293
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:20:20 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1A0KKiE172314
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:20:20 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1A0Jvwg021627
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:19:58 -0500
Content-Disposition: inline
In-Reply-To: <20070210000128.GJ5616@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It appears that under certain circumstances, a race will result
in a double-free of an skb. This patch null's out the skb pointer
upon the skb free, avoiding the inadvertent deref of bogus data.
The next patch fixes the actual race.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Cc: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

----
 drivers/net/spider_net.c |   23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

Index: linux-2.6.20-git4/drivers/net/spider_net.c
===================================================================
--- linux-2.6.20-git4.orig/drivers/net/spider_net.c	2007-02-09 16:56:25.000000000 -0600
+++ linux-2.6.20-git4/drivers/net/spider_net.c	2007-02-09 16:56:30.000000000 -0600
@@ -360,10 +360,11 @@ spider_net_free_rx_chain_contents(struct
 	descr = card->rx_chain.head;
 	do {
 		if (descr->skb) {
-			dev_kfree_skb(descr->skb);
 			pci_unmap_single(card->pdev, descr->hwdescr->buf_addr,
 					 SPIDER_NET_MAX_FRAME,
 					 PCI_DMA_BIDIRECTIONAL);
+			dev_kfree_skb(descr->skb);
+			descr->skb = NULL;
 		}
 		descr = descr->next;
 	} while (descr != card->rx_chain.head);
@@ -417,6 +418,7 @@ spider_net_prepare_rx_descr(struct spide
 			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
 	if (pci_dma_mapping_error(buf)) {
 		dev_kfree_skb_any(descr->skb);
+		descr->skb = NULL;
 		if (netif_msg_rx_err(card) && net_ratelimit())
 			pr_err("Could not iommu-map rx buffer\n");
 		card->spider_stats.rx_iommu_map_error++;
@@ -646,6 +648,7 @@ static int
 spider_net_prepare_tx_descr(struct spider_net_card *card,
 			    struct sk_buff *skb)
 {
+	struct spider_net_descr_chain *chain = &card->tx_chain;
 	struct spider_net_descr *descr;
 	struct spider_net_hw_descr *hwdescr;
 	dma_addr_t buf;
@@ -660,10 +663,15 @@ spider_net_prepare_tx_descr(struct spide
 		return -ENOMEM;
 	}
 
-	spin_lock_irqsave(&card->tx_chain.lock, flags);
+	spin_lock_irqsave(&chain->lock, flags);
 	descr = card->tx_chain.head;
+	if (descr->next == chain->tail->prev) {
+		spin_unlock_irqrestore(&chain->lock, flags);
+		pci_unmap_single(card->pdev, buf, skb->len, PCI_DMA_TODEVICE);
+		return -ENOMEM;
+	}
 	hwdescr = descr->hwdescr;
-	card->tx_chain.head = descr->next;
+	chain->head = descr->next;
 
 	descr->skb = skb;
 	hwdescr->buf_addr = buf;
@@ -673,7 +681,7 @@ spider_net_prepare_tx_descr(struct spide
 
 	hwdescr->dmac_cmd_status =
 			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_NOCS;
-	spin_unlock_irqrestore(&card->tx_chain.lock, flags);
+	spin_unlock_irqrestore(&chain->lock, flags);
 
 	if (skb->protocol == htons(ETH_P_IP))
 		switch (skb->nh.iph->protocol) {
@@ -802,6 +810,7 @@ spider_net_release_tx_chain(struct spide
 		chain->tail = descr->next;
 		hwdescr->dmac_cmd_status |= SPIDER_NET_DESCR_NOT_IN_USE;
 		skb = descr->skb;
+		descr->skb = NULL;
 		buf_addr = hwdescr->buf_addr;
 		spin_unlock_irqrestore(&chain->lock, flags);
 
@@ -867,13 +876,10 @@ spider_net_xmit(struct sk_buff *skb, str
 {
 	int cnt;
 	struct spider_net_card *card = netdev_priv(netdev);
-	struct spider_net_descr_chain *chain = &card->tx_chain;
 
 	spider_net_release_tx_chain(card, 0);
 
-	if ((chain->head->next == chain->tail->prev) ||
-	   (spider_net_prepare_tx_descr(card, skb) != 0)) {
-
+	if (spider_net_prepare_tx_descr(card, skb) != 0) {
 		card->netdev_stats.tx_dropped++;
 		netif_stop_queue(netdev);
 		return NETDEV_TX_BUSY;
@@ -1091,6 +1097,7 @@ spider_net_decode_one_descr(struct spide
 
 bad_desc:
 	dev_kfree_skb_irq(descr->skb);
+	descr->skb = NULL;
 	hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	return 0;
 }
