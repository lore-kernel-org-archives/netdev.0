From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 1/16] Spidernet DMA coalescing
Date: Wed, 6 Dec 2006 17:27:45 -0600
Message-ID: <20061206232745.GA4649@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:58481 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937788AbWLFX14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 18:27:56 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB6NRoMn001402
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:27:50 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6NRlHE295962
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:27:49 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6NRjO7006896
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:27:46 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206223223.GH17931@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The current driver code performs 512 DMA mappings of a bunch of 
32-byte structures. This is silly, as they are all in contiguous 
memory. Ths patch changes the code to DMA map the entie area
with just one call.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Acked-by: Joel Schopp <jschopp@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |  107 +++++++++++++++++++++++------------------------
 drivers/net/spider_net.h |   16 ++-----
 2 files changed, 59 insertions(+), 64 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-06 15:53:23.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-06 15:56:20.000000000 -0600
@@ -269,25 +269,6 @@ spider_net_get_descr_status(struct spide
 }
 
 /**
- * spider_net_free_chain - free descriptor chain
- * @card: card structure
- * @chain: address of chain
- *
- */
-static void
-spider_net_free_chain(struct spider_net_card *card,
-		      struct spider_net_descr_chain *chain)
-{
-	struct spider_net_descr *descr;
-
-	for (descr = chain->tail; !descr->bus_addr; descr = descr->next) {
-		pci_unmap_single(card->pdev, descr->bus_addr,
-				 SPIDER_NET_DESCR_SIZE, PCI_DMA_BIDIRECTIONAL);
-		descr->bus_addr = 0;
-	}
-}
-
-/**
  * spider_net_init_chain - links descriptor chain
  * @card: card structure
  * @chain: address of chain
@@ -299,15 +280,15 @@ spider_net_free_chain(struct spider_net_
  *
  * returns 0 on success, <0 on failure
  */
-static int
+static void
 spider_net_init_chain(struct spider_net_card *card,
 		       struct spider_net_descr_chain *chain,
 		       struct spider_net_descr *start_descr,
+		       dma_addr_t buf,
 		       int no)
 {
 	int i;
 	struct spider_net_descr *descr;
-	dma_addr_t buf;
 
 	descr = start_descr;
 	memset(descr, 0, sizeof(*descr) * no);
@@ -316,17 +297,12 @@ spider_net_init_chain(struct spider_net_
 	for (i=0; i<no; i++, descr++) {
 		descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 
-		buf = pci_map_single(card->pdev, descr,
-				     SPIDER_NET_DESCR_SIZE,
-				     PCI_DMA_BIDIRECTIONAL);
-
-		if (pci_dma_mapping_error(buf))
-			goto iommu_error;
-
 		descr->bus_addr = buf;
+		descr->next_descr_addr = 0;
 		descr->next = descr + 1;
 		descr->prev = descr - 1;
 
+		buf += sizeof(struct spider_net_descr);
 	}
 	/* do actual circular list */
 	(descr-1)->next = start_descr;
@@ -335,17 +311,6 @@ spider_net_init_chain(struct spider_net_
 	spin_lock_init(&chain->lock);
 	chain->head = start_descr;
 	chain->tail = start_descr;
-
-	return 0;
-
-iommu_error:
-	descr = start_descr;
-	for (i=0; i < no; i++, descr++)
-		if (descr->bus_addr)
-			pci_unmap_single(card->pdev, descr->bus_addr,
-					 SPIDER_NET_DESCR_SIZE,
-					 PCI_DMA_BIDIRECTIONAL);
-	return -ENOMEM;
 }
 
 /**
@@ -1652,24 +1617,32 @@ spider_net_open(struct net_device *netde
 {
 	struct spider_net_card *card = netdev_priv(netdev);
 	struct spider_net_descr *descr;
-	int i, result;
+	int result = -ENOMEM;
 
-	result = -ENOMEM;
-	if (spider_net_init_chain(card, &card->tx_chain, card->descr,
-	                          card->num_tx_desc))
-		goto alloc_tx_failed;
+	card->descr_dma_addr = pci_map_single(card->pdev, card->descr,
+	        (card->num_tx_desc+card->num_rx_desc)*sizeof(struct spider_net_descr),
+				     PCI_DMA_BIDIRECTIONAL);
+	if (pci_dma_mapping_error(card->descr_dma_addr))
+		return -ENOMEM;
+
+	spider_net_init_chain(card, &card->tx_chain, card->descr,
+	                          card->descr_dma_addr,
+	                          card->num_tx_desc);
 
 	card->low_watermark = NULL;
 
 	/* rx_chain is after tx_chain, so offset is descr + tx_count */
-	if (spider_net_init_chain(card, &card->rx_chain,
+	spider_net_init_chain(card, &card->rx_chain,
 	                          card->descr + card->num_tx_desc,
-	                          card->num_rx_desc))
-		goto alloc_rx_failed;
+	                          card->descr_dma_addr
+					+ card->num_tx_desc * sizeof(struct spider_net_descr),
+	                          card->num_rx_desc);
 
 	descr = card->rx_chain.head;
-	for (i=0; i < card->num_rx_desc; i++, descr++)
+	do {
 		descr->next_descr_addr = descr->next->bus_addr;
+		descr = descr->next;
+	} while (descr != card->rx_chain.head);
 
 	/* allocate rx skbs */
 	if (spider_net_alloc_rx_skbs(card))
@@ -1695,10 +1668,21 @@ spider_net_open(struct net_device *netde
 register_int_failed:
 	spider_net_free_rx_chain_contents(card);
 alloc_skbs_failed:
-	spider_net_free_chain(card, &card->rx_chain);
-alloc_rx_failed:
-	spider_net_free_chain(card, &card->tx_chain);
-alloc_tx_failed:
+	descr = card->rx_chain.head;
+	do {
+		descr->bus_addr = 0;
+		descr = descr->next;
+	} while (descr != card->rx_chain.head);
+
+	descr = card->tx_chain.head;
+	do {
+		descr->bus_addr = 0;
+		descr = descr->next;
+	} while (descr != card->tx_chain.head);
+
+	pci_unmap_single(card->pdev, card->descr_dma_addr,
+	   (card->num_tx_desc+card->num_rx_desc)*sizeof(struct spider_net_descr),
+	                 PCI_DMA_BIDIRECTIONAL);
 	return result;
 }
 
@@ -1901,6 +1885,7 @@ int
 spider_net_stop(struct net_device *netdev)
 {
 	struct spider_net_card *card = netdev_priv(netdev);
+	struct spider_net_descr *descr;
 
 	tasklet_kill(&card->rxram_full_tl);
 	netif_poll_disable(netdev);
@@ -1924,9 +1909,23 @@ spider_net_stop(struct net_device *netde
 
 	/* release chains */
 	spider_net_release_tx_chain(card, 1);
+	spider_net_free_rx_chain_contents(card);
+
+	descr = card->rx_chain.head;
+	do {
+		descr->bus_addr = 0;
+		descr = descr->next;
+	} while (descr != card->rx_chain.head);
+
+	descr = card->tx_chain.head;
+	do {
+		descr->bus_addr = 0;
+		descr = descr->next;
+	} while (descr != card->tx_chain.head);
 
-	spider_net_free_chain(card, &card->tx_chain);
-	spider_net_free_chain(card, &card->rx_chain);
+	pci_unmap_single(card->pdev, card->descr_dma_addr,
+	      (card->num_tx_desc+card->num_rx_desc)*sizeof(struct spider_net_descr),
+	                 PCI_DMA_BIDIRECTIONAL);
 
 	return 0;
 }
Index: linux-2.6.19-git7/drivers/net/spider_net.h
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.h	2006-12-06 15:53:23.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.h	2006-12-06 15:56:20.000000000 -0600
@@ -397,8 +397,6 @@ struct spider_net_descr_chain {
  * 701b8000 would be correct, but every packets gets that flag */
 #define SPIDER_NET_DESTROY_RX_FLAGS	0x700b8000
 
-#define SPIDER_NET_DESCR_SIZE		32
-
 /* this will be bigger some time */
 struct spider_net_options {
 	int rx_csum; /* for rx: if 0 ip_summed=NONE,
@@ -437,28 +435,26 @@ struct spider_net_card {
 
 	void __iomem *regs;
 
+	int num_rx_desc;
+	int num_tx_desc;
 	struct spider_net_descr_chain tx_chain;
 	struct spider_net_descr_chain rx_chain;
 	struct spider_net_descr *low_watermark;
+	dma_addr_t descr_dma_addr;
 
-	struct net_device_stats netdev_stats;
-
-	struct spider_net_options options;
-
-	spinlock_t intmask_lock;
 	struct tasklet_struct rxram_full_tl;
 	struct timer_list tx_timer;
-
 	struct work_struct tx_timeout_task;
 	atomic_t tx_timeout_task_counter;
 	wait_queue_head_t waitq;
 
 	/* for ethtool */
 	int msg_enable;
-	int num_rx_desc;
-	int num_tx_desc;
+	struct net_device_stats netdev_stats;
 	struct spider_net_extra_stats spider_stats;
+	struct spider_net_options options;
 
+	/* Must be last element in the structure */
 	struct spider_net_descr descr[0];
 };
 
