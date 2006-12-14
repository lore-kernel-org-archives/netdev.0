From: linas@austin.ibm.com (Linas Vepstas)
Subject: Revised: [PATCH 1/14] Spidernet DMA coalescing
Date: Thu, 14 Dec 2006 13:38:06 -0600
Message-ID: <20061214193806.GX4329@austin.ibm.com>
References: <20061213210010.GR4329@austin.ibm.com> <20061213210659.GA1915@austin.ibm.com> <20061214110517.GA13377@infradead.org> <20061214170737.GS4329@austin.ibm.com> <20061214173534.GA3452@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	James K Lewis <jim@jklewis.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:47427 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbWLNTiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 14:38:08 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBEJc8MO011826
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 14:38:08 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBEJc7CM400576
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 12:38:07 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBEJc6Ni032062
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 12:38:07 -0700
To: Christoph Hellwig <hch@infradead.org>,
	Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061214173534.GA3452@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andrew, 

I'm hoping its not irritatingly obthersome to ask you to rip out 
the first patch of this series, and replace it with the one below. 

On Thu, Dec 14, 2006 at 05:35:34PM +0000, Christoph Hellwig wrote:
> On Thu, Dec 14, 2006 at 11:07:37AM -0600, Linas Vepstas wrote:
> > Being unclear on the concept, should a send a new version of this patch,
> > or should I send a new patch that removes this?
> 
> For just the memset issue an incremental patch would be fine.  But given
> the small mistake in the patch description a resend with the fixed
> description mighrt be in order here.

--linas

The current driver code performs 512 DMA mappings of a bunch of 
32-byte ring descriptor structures. This is silly, as they are 
all in contiguous memory. This patch changes the code to 
dma_alloc_coherent() each rx/tx ring as a whole.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c         |  101 +++++++++++++++++----------------------
 drivers/net/spider_net.h         |   17 +-----
 drivers/net/spider_net_ethtool.c |    4 -
 3 files changed, 52 insertions(+), 70 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-13 14:23:11.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-14 11:02:59.000000000 -0600
@@ -280,72 +280,65 @@ spider_net_free_chain(struct spider_net_
 {
 	struct spider_net_descr *descr;
 
-	for (descr = chain->tail; !descr->bus_addr; descr = descr->next) {
-		pci_unmap_single(card->pdev, descr->bus_addr,
-				 SPIDER_NET_DESCR_SIZE, PCI_DMA_BIDIRECTIONAL);
+	descr = chain->ring;
+	do {
 		descr->bus_addr = 0;
-	}
+		descr->next_descr_addr = 0;
+		descr = descr->next;
+	} while (descr != chain->ring);
+
+	dma_free_coherent(&card->pdev->dev, chain->num_desc,
+	    chain->ring, chain->dma_addr);
 }
 
 /**
- * spider_net_init_chain - links descriptor chain
+ * spider_net_init_chain - alloc and link descriptor chain
  * @card: card structure
  * @chain: address of chain
- * @start_descr: address of descriptor array
- * @no: number of descriptors
  *
- * we manage a circular list that mirrors the hardware structure,
+ * We manage a circular list that mirrors the hardware structure,
  * except that the hardware uses bus addresses.
  *
- * returns 0 on success, <0 on failure
+ * Returns 0 on success, <0 on failure
  */
 static int
 spider_net_init_chain(struct spider_net_card *card,
-		       struct spider_net_descr_chain *chain,
-		       struct spider_net_descr *start_descr,
-		       int no)
+		       struct spider_net_descr_chain *chain)
 {
 	int i;
 	struct spider_net_descr *descr;
 	dma_addr_t buf;
+	size_t alloc_size;
 
-	descr = start_descr;
-	memset(descr, 0, sizeof(*descr) * no);
+	alloc_size = chain->num_desc * sizeof (struct spider_net_descr);
 
-	/* set up the hardware pointers in each descriptor */
-	for (i=0; i<no; i++, descr++) {
-		descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
+	chain->ring = dma_alloc_coherent(&card->pdev->dev, alloc_size,
+		&chain->dma_addr, GFP_KERNEL);
 
-		buf = pci_map_single(card->pdev, descr,
-				     SPIDER_NET_DESCR_SIZE,
-				     PCI_DMA_BIDIRECTIONAL);
+	if (!chain->ring)
+		return -ENOMEM;
 
-		if (pci_dma_mapping_error(buf))
-			goto iommu_error;
+	/* Set up the hardware pointers in each descriptor */
+	descr = chain->ring;
+	buf = chain->dma_addr;
+	for (i=0; i < chain->num_desc; i++, descr++) {
+		descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 
 		descr->bus_addr = buf;
+		descr->next_descr_addr = 0;
 		descr->next = descr + 1;
 		descr->prev = descr - 1;
 
+		buf += sizeof(struct spider_net_descr);
 	}
 	/* do actual circular list */
-	(descr-1)->next = start_descr;
-	start_descr->prev = descr-1;
+	(descr-1)->next = chain->ring;
+	chain->ring->prev = descr-1;
 
 	spin_lock_init(&chain->lock);
-	chain->head = start_descr;
-	chain->tail = start_descr;
-
+	chain->head = chain->ring;
+	chain->tail = chain->ring;
 	return 0;
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
@@ -707,7 +700,7 @@ spider_net_set_low_watermark(struct spid
 	}
 
 	/* If TX queue is short, don't even bother with interrupts */
-	if (cnt < card->num_tx_desc/4)
+	if (cnt < card->tx_chain.num_desc/4)
 		return cnt;
 
 	/* Set low-watermark 3/4th's of the way into the queue. */
@@ -1652,26 +1645,25 @@ spider_net_open(struct net_device *netde
 {
 	struct spider_net_card *card = netdev_priv(netdev);
 	struct spider_net_descr *descr;
-	int i, result;
+	int result;
 
-	result = -ENOMEM;
-	if (spider_net_init_chain(card, &card->tx_chain, card->descr,
-	                          card->num_tx_desc))
+	result = spider_net_init_chain(card, &card->tx_chain);
+	if (result)
 		goto alloc_tx_failed;
-
 	card->low_watermark = NULL;
 
-	/* rx_chain is after tx_chain, so offset is descr + tx_count */
-	if (spider_net_init_chain(card, &card->rx_chain,
-	                          card->descr + card->num_tx_desc,
-	                          card->num_rx_desc))
+	result = spider_net_init_chain(card, &card->rx_chain);
+	if (result)
 		goto alloc_rx_failed;
 
-	descr = card->rx_chain.head;
-	for (i=0; i < card->num_rx_desc; i++, descr++)
+	/* Make a ring of of bus addresses */
+	descr = card->rx_chain.ring;
+	do {
 		descr->next_descr_addr = descr->next->bus_addr;
+		descr = descr->next;
+	} while (descr != card->rx_chain.ring);
 
-	/* allocate rx skbs */
+	/* Allocate rx skbs */
 	if (spider_net_alloc_rx_skbs(card))
 		goto alloc_skbs_failed;
 
@@ -1924,6 +1916,7 @@ spider_net_stop(struct net_device *netde
 
 	/* release chains */
 	spider_net_release_tx_chain(card, 1);
+	spider_net_free_rx_chain_contents(card);
 
 	spider_net_free_chain(card, &card->tx_chain);
 	spider_net_free_chain(card, &card->rx_chain);
@@ -2054,8 +2047,8 @@ spider_net_setup_netdev(struct spider_ne
 
 	card->options.rx_csum = SPIDER_NET_RX_CSUM_DEFAULT;
 
-	card->num_tx_desc = tx_descriptors;
-	card->num_rx_desc = rx_descriptors;
+	card->tx_chain.num_desc = tx_descriptors;
+	card->rx_chain.num_desc = rx_descriptors;
 
 	spider_net_setup_netdev_ops(netdev);
 
@@ -2104,12 +2097,8 @@ spider_net_alloc_card(void)
 {
 	struct net_device *netdev;
 	struct spider_net_card *card;
-	size_t alloc_size;
 
-	alloc_size = sizeof (*card) +
-		sizeof (struct spider_net_descr) * rx_descriptors +
-		sizeof (struct spider_net_descr) * tx_descriptors;
-	netdev = alloc_etherdev(alloc_size);
+	netdev = alloc_etherdev(sizeof(struct spider_net_card));
 	if (!netdev)
 		return NULL;
 
Index: linux-2.6.19-git7/drivers/net/spider_net.h
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.h	2006-12-13 14:23:11.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.h	2006-12-14 11:01:37.000000000 -0600
@@ -378,6 +378,9 @@ struct spider_net_descr_chain {
 	spinlock_t lock;
 	struct spider_net_descr *head;
 	struct spider_net_descr *tail;
+	struct spider_net_descr *ring;
+	int num_desc;
+	dma_addr_t dma_addr;
 };
 
 /* descriptor data_status bits */
@@ -397,8 +400,6 @@ struct spider_net_descr_chain {
  * 701b8000 would be correct, but every packets gets that flag */
 #define SPIDER_NET_DESTROY_RX_FLAGS	0x700b8000
 
-#define SPIDER_NET_DESCR_SIZE		32
-
 /* this will be bigger some time */
 struct spider_net_options {
 	int rx_csum; /* for rx: if 0 ip_summed=NONE,
@@ -441,25 +442,17 @@ struct spider_net_card {
 	struct spider_net_descr_chain rx_chain;
 	struct spider_net_descr *low_watermark;
 
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
-
-	struct spider_net_descr descr[0];
+	struct spider_net_options options;
 };
 
 #define pr_err(fmt,arg...) \
Index: linux-2.6.19-git7/drivers/net/spider_net_ethtool.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net_ethtool.c	2006-12-13 14:23:11.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net_ethtool.c	2006-12-13 14:23:24.000000000 -0600
@@ -158,9 +158,9 @@ spider_net_ethtool_get_ringparam(struct 
 	struct spider_net_card *card = netdev->priv;
 
 	ering->tx_max_pending = SPIDER_NET_TX_DESCRIPTORS_MAX;
-	ering->tx_pending = card->num_tx_desc;
+	ering->tx_pending = card->tx_chain.num_desc;
 	ering->rx_max_pending = SPIDER_NET_RX_DESCRIPTORS_MAX;
-	ering->rx_pending = card->num_rx_desc;
+	ering->rx_pending = card->rx_chain.num_desc;
 }
 
 static int spider_net_get_stats_count(struct net_device *netdev)
