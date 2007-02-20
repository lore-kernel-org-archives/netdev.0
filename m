From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 8/12] spidernet: separate hardware state from driver state.
Date: Tue, 20 Feb 2007 16:40:06 -0600
Message-ID: <20070220224006.GH28895@austin.ibm.com>
References: <20070220221314.GU923@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	kou.ishizaki@toshiba.co.jp, arnd@arndb.de,
	Jens Osterkamp <jens@de.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:38308 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161010AbXBTWkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 17:40:09 -0500
Content-Disposition: inline
In-Reply-To: <20070220221314.GU923@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch separates the hardware descriptor state from the 
driver descriptor state, per (old) suggestion from Ben Herrenschmidt.
This compiles and boots and seems to work. 

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Cc: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

----
 drivers/net/spider_net.c |  150 ++++++++++++++++++++++++++---------------------
 drivers/net/spider_net.h |   16 +++--
 2 files changed, 95 insertions(+), 71 deletions(-)

Index: linux-2.6.20-git16/drivers/net/spider_net.h
===================================================================
--- linux-2.6.20-git16.orig/drivers/net/spider_net.h	2007-02-20 15:02:42.000000000 -0600
+++ linux-2.6.20-git16/drivers/net/spider_net.h	2007-02-20 15:02:44.000000000 -0600
@@ -25,7 +25,7 @@
 #ifndef _SPIDER_NET_H
 #define _SPIDER_NET_H
 
-#define VERSION "1.6 B"
+#define VERSION "1.6 C"
 
 #include "sungem_phy.h"
 
@@ -364,8 +364,8 @@ enum spider_net_int2_status {
 #define SPIDER_NET_DESCR_NOT_IN_USE		0xF0000000
 #define SPIDER_NET_DESCR_TXDESFLG		0x00800000
 
-struct spider_net_descr {
-	/* as defined by the hardware */
+/* Descriptor, as defined by the hardware */
+struct spider_net_hw_descr {
 	u32 buf_addr;
 	u32 buf_size;
 	u32 next_descr_addr;
@@ -374,13 +374,15 @@ struct spider_net_descr {
 	u32 valid_size;	/* all zeroes for tx */
 	u32 data_status;
 	u32 data_error;	/* all zeroes for tx */
+} __attribute__((aligned(32)));
 
-	/* used in the driver */
+struct spider_net_descr {
+	struct spider_net_hw_descr *hwdescr;
 	struct sk_buff *skb;
 	u32 bus_addr;
 	struct spider_net_descr *next;
 	struct spider_net_descr *prev;
-} __attribute__((aligned(32)));
+};
 
 struct spider_net_descr_chain {
 	spinlock_t lock;
@@ -388,6 +390,7 @@ struct spider_net_descr_chain {
 	struct spider_net_descr *tail;
 	struct spider_net_descr *ring;
 	int num_desc;
+	struct spider_net_hw_descr *hwring;
 	dma_addr_t dma_addr;
 };
 
@@ -464,6 +467,9 @@ struct spider_net_card {
 	struct net_device_stats netdev_stats;
 	struct spider_net_extra_stats spider_stats;
 	struct spider_net_options options;
+
+	/* Must be last item in struct */
+	struct spider_net_descr darray[0];
 };
 
 #define pr_err(fmt,arg...) \
Index: linux-2.6.20-git16/drivers/net/spider_net.c
===================================================================
--- linux-2.6.20-git16.orig/drivers/net/spider_net.c	2007-02-20 15:02:42.000000000 -0600
+++ linux-2.6.20-git16/drivers/net/spider_net.c	2007-02-20 15:02:44.000000000 -0600
@@ -299,9 +299,9 @@ spider_net_get_mac_address(struct net_de
  * returns the status as in the dmac_cmd_status field of the descriptor
  */
 static inline int
-spider_net_get_descr_status(struct spider_net_descr *descr)
+spider_net_get_descr_status(struct spider_net_hw_descr *hwdescr)
 {
-	return descr->dmac_cmd_status & SPIDER_NET_DESCR_IND_PROC_MASK;
+	return hwdescr->dmac_cmd_status & SPIDER_NET_DESCR_IND_PROC_MASK;
 }
 
 /**
@@ -319,12 +319,12 @@ spider_net_free_chain(struct spider_net_
 	descr = chain->ring;
 	do {
 		descr->bus_addr = 0;
-		descr->next_descr_addr = 0;
+		descr->hwdescr->next_descr_addr = 0;
 		descr = descr->next;
 	} while (descr != chain->ring);
 
 	dma_free_coherent(&card->pdev->dev, chain->num_desc,
-	    chain->ring, chain->dma_addr);
+	    chain->hwring, chain->dma_addr);
 }
 
 /**
@@ -343,31 +343,34 @@ spider_net_init_chain(struct spider_net_
 {
 	int i;
 	struct spider_net_descr *descr;
+	struct spider_net_hw_descr *hwdescr;
 	dma_addr_t buf;
 	size_t alloc_size;
 
-	alloc_size = chain->num_desc * sizeof (struct spider_net_descr);
+	alloc_size = chain->num_desc * sizeof(struct spider_net_hw_descr);
 
-	chain->ring = dma_alloc_coherent(&card->pdev->dev, alloc_size,
+	chain->hwring = dma_alloc_coherent(&card->pdev->dev, alloc_size,
 		&chain->dma_addr, GFP_KERNEL);
 
-	if (!chain->ring)
+	if (!chain->hwring)
 		return -ENOMEM;
 
-	descr = chain->ring;
-	memset(descr, 0, alloc_size);
+	memset(chain->ring, 0, chain->num_desc * sizeof(struct spider_net_descr));
 
 	/* Set up the hardware pointers in each descriptor */
+	descr = chain->ring;
+	hwdescr = chain->hwring;
 	buf = chain->dma_addr;
-	for (i=0; i < chain->num_desc; i++, descr++) {
-		descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
+	for (i=0; i < chain->num_desc; i++, descr++, hwdescr++) {
+		hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
+		hwdescr->next_descr_addr = 0;
 
+		descr->hwdescr = hwdescr;
 		descr->bus_addr = buf;
-		descr->next_descr_addr = 0;
 		descr->next = descr + 1;
 		descr->prev = descr - 1;
 
-		buf += sizeof(struct spider_net_descr);
+		buf += sizeof(struct spider_net_hw_descr);
 	}
 	/* do actual circular list */
 	(descr-1)->next = chain->ring;
@@ -394,7 +397,7 @@ spider_net_free_rx_chain_contents(struct
 	do {
 		if (descr->skb) {
 			dev_kfree_skb(descr->skb);
-			pci_unmap_single(card->pdev, descr->buf_addr,
+			pci_unmap_single(card->pdev, descr->hwdescr->buf_addr,
 					 SPIDER_NET_MAX_FRAME,
 					 PCI_DMA_BIDIRECTIONAL);
 		}
@@ -416,6 +419,7 @@ static int
 spider_net_prepare_rx_descr(struct spider_net_card *card,
 			    struct spider_net_descr *descr)
 {
+	struct spider_net_hw_descr *hwdescr = descr->hwdescr;
 	dma_addr_t buf;
 	int offset;
 	int bufsize;
@@ -434,11 +438,11 @@ spider_net_prepare_rx_descr(struct spide
 		card->spider_stats.alloc_rx_skb_error++;
 		return -ENOMEM;
 	}
-	descr->buf_size = bufsize;
-	descr->result_size = 0;
-	descr->valid_size = 0;
-	descr->data_status = 0;
-	descr->data_error = 0;
+	hwdescr->buf_size = bufsize;
+	hwdescr->result_size = 0;
+	hwdescr->valid_size = 0;
+	hwdescr->data_status = 0;
+	hwdescr->data_error = 0;
 
 	offset = ((unsigned long)descr->skb->data) &
 		(SPIDER_NET_RXBUF_ALIGN - 1);
@@ -447,21 +451,21 @@ spider_net_prepare_rx_descr(struct spide
 	/* iommu-map the skb */
 	buf = pci_map_single(card->pdev, descr->skb->data,
 			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
-	descr->buf_addr = buf;
 	if (pci_dma_mapping_error(buf)) {
 		dev_kfree_skb_any(descr->skb);
 		if (netif_msg_rx_err(card) && net_ratelimit())
 			pr_err("Could not iommu-map rx buffer\n");
 		card->spider_stats.rx_iommu_map_error++;
-		descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
+		hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	} else {
-		descr->next_descr_addr = 0;
+		hwdescr->buf_addr = buf;
+		hwdescr->next_descr_addr = 0;
 		wmb();
-		descr->dmac_cmd_status = SPIDER_NET_DESCR_CARDOWNED |
+		hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_CARDOWNED |
 					 SPIDER_NET_DMAC_NOINTR_COMPLETE;
 
 		wmb();
-		descr->prev->next_descr_addr = descr->bus_addr;
+		descr->prev->hwdescr->next_descr_addr = descr->bus_addr;
 	}
 
 	return 0;
@@ -517,7 +521,7 @@ spider_net_refill_rx_chain(struct spider
 	if (!spin_trylock_irqsave(&chain->lock, flags))
 		return;
 
-	while (spider_net_get_descr_status(chain->head) ==
+	while (spider_net_get_descr_status(chain->head->hwdescr) ==
 			SPIDER_NET_DESCR_NOT_IN_USE) {
 		if (spider_net_prepare_rx_descr(card, chain->head))
 			break;
@@ -679,6 +683,7 @@ spider_net_prepare_tx_descr(struct spide
 			    struct sk_buff *skb)
 {
 	struct spider_net_descr *descr;
+	struct spider_net_hw_descr *hwdescr;
 	dma_addr_t buf;
 	unsigned long flags;
 
@@ -693,30 +698,32 @@ spider_net_prepare_tx_descr(struct spide
 
 	spin_lock_irqsave(&card->tx_chain.lock, flags);
 	descr = card->tx_chain.head;
+	hwdescr = descr->hwdescr;
 	card->tx_chain.head = descr->next;
 
-	descr->buf_addr = buf;
-	descr->buf_size = skb->len;
-	descr->next_descr_addr = 0;
 	descr->skb = skb;
-	descr->data_status = 0;
+	hwdescr->buf_addr = buf;
+	hwdescr->buf_size = skb->len;
+	hwdescr->next_descr_addr = 0;
+	hwdescr->data_status = 0;
 
-	descr->dmac_cmd_status =
+	hwdescr->dmac_cmd_status =
 			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_NOCS;
 	spin_unlock_irqrestore(&card->tx_chain.lock, flags);
 
 	if (skb->protocol == htons(ETH_P_IP))
 		switch (skb->nh.iph->protocol) {
 		case IPPROTO_TCP:
-			descr->dmac_cmd_status |= SPIDER_NET_DMAC_TCP;
+			hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_TCP;
 			break;
 		case IPPROTO_UDP:
-			descr->dmac_cmd_status |= SPIDER_NET_DMAC_UDP;
+			hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_UDP;
 			break;
 		}
 
 	/* Chain the bus address, so that the DMA engine finds this descr. */
-	descr->prev->next_descr_addr = descr->bus_addr;
+	wmb();
+	descr->prev->hwdescr->next_descr_addr = descr->bus_addr;
 
 	card->netdev->trans_start = jiffies; /* set netdev watchdog timer */
 	return 0;
@@ -725,16 +732,17 @@ spider_net_prepare_tx_descr(struct spide
 static int
 spider_net_set_low_watermark(struct spider_net_card *card)
 {
+	struct spider_net_descr *descr = card->tx_chain.tail;
+	struct spider_net_hw_descr *hwdescr;
 	unsigned long flags;
 	int status;
 	int cnt=0;
 	int i;
-	struct spider_net_descr *descr = card->tx_chain.tail;
 
 	/* Measure the length of the queue. Measurement does not
 	 * need to be precise -- does not need a lock. */
 	while (descr != card->tx_chain.head) {
-		status = descr->dmac_cmd_status & SPIDER_NET_DESCR_NOT_IN_USE;
+		status = descr->hwdescr->dmac_cmd_status & SPIDER_NET_DESCR_NOT_IN_USE;
 		if (status == SPIDER_NET_DESCR_NOT_IN_USE)
 			break;
 		descr = descr->next;
@@ -753,10 +761,12 @@ spider_net_set_low_watermark(struct spid
 
 	/* Set the new watermark, clear the old watermark */
 	spin_lock_irqsave(&card->tx_chain.lock, flags);
-	descr->dmac_cmd_status |= SPIDER_NET_DESCR_TXDESFLG;
-	if (card->low_watermark && card->low_watermark != descr)
-		card->low_watermark->dmac_cmd_status =
-		     card->low_watermark->dmac_cmd_status & ~SPIDER_NET_DESCR_TXDESFLG;
+	descr->hwdescr->dmac_cmd_status |= SPIDER_NET_DESCR_TXDESFLG;
+	if (card->low_watermark && card->low_watermark != descr) {
+		hwdescr = card->low_watermark->hwdescr;
+		hwdescr->dmac_cmd_status =
+		     hwdescr->dmac_cmd_status & ~SPIDER_NET_DESCR_TXDESFLG;
+	}
 	card->low_watermark = descr;
 	spin_unlock_irqrestore(&card->tx_chain.lock, flags);
 	return cnt;
@@ -779,6 +789,7 @@ spider_net_release_tx_chain(struct spide
 {
 	struct spider_net_descr_chain *chain = &card->tx_chain;
 	struct spider_net_descr *descr;
+	struct spider_net_hw_descr *hwdescr;
 	struct sk_buff *skb;
 	u32 buf_addr;
 	unsigned long flags;
@@ -787,8 +798,9 @@ spider_net_release_tx_chain(struct spide
 	while (chain->tail != chain->head) {
 		spin_lock_irqsave(&chain->lock, flags);
 		descr = chain->tail;
+		hwdescr = descr->hwdescr;
 
-		status = spider_net_get_descr_status(descr);
+		status = spider_net_get_descr_status(hwdescr);
 		switch (status) {
 		case SPIDER_NET_DESCR_COMPLETE:
 			card->netdev_stats.tx_packets++;
@@ -824,9 +836,9 @@ spider_net_release_tx_chain(struct spide
 		}
 
 		chain->tail = descr->next;
-		descr->dmac_cmd_status |= SPIDER_NET_DESCR_NOT_IN_USE;
+		hwdescr->dmac_cmd_status |= SPIDER_NET_DESCR_NOT_IN_USE;
 		skb = descr->skb;
-		buf_addr = descr->buf_addr;
+		buf_addr = hwdescr->buf_addr;
 		spin_unlock_irqrestore(&chain->lock, flags);
 
 		/* unmap the skb */
@@ -862,7 +874,7 @@ spider_net_kick_tx_dma(struct spider_net
 
 	descr = card->tx_chain.tail;
 	for (;;) {
-		if (spider_net_get_descr_status(descr) ==
+		if (spider_net_get_descr_status(descr->hwdescr) ==
 				SPIDER_NET_DESCR_CARDOWNED) {
 			spider_net_write_reg(card, SPIDER_NET_GDTDCHA,
 					descr->bus_addr);
@@ -958,17 +970,18 @@ static void
 spider_net_pass_skb_up(struct spider_net_descr *descr,
 		       struct spider_net_card *card)
 {
+	struct spider_net_hw_descr *hwdescr= descr->hwdescr;
 	struct sk_buff *skb;
 	struct net_device *netdev;
 	u32 data_status, data_error;
 
-	data_status = descr->data_status;
-	data_error = descr->data_error;
+	data_status = hwdescr->data_status;
+	data_error = hwdescr->data_error;
 	netdev = card->netdev;
 
 	skb = descr->skb;
 	skb->dev = netdev;
-	skb_put(skb, descr->valid_size);
+	skb_put(skb, hwdescr->valid_size);
 
 	/* the card seems to add 2 bytes of junk in front
 	 * of the ethernet frame */
@@ -1044,9 +1057,10 @@ spider_net_decode_one_descr(struct spide
 {
 	struct spider_net_descr_chain *chain = &card->rx_chain;
 	struct spider_net_descr *descr = chain->tail;
+	struct spider_net_hw_descr *hwdescr = descr->hwdescr;
 	int status;
 
-	status = spider_net_get_descr_status(descr);
+	status = spider_net_get_descr_status(hwdescr);
 
 	/* Nothing in the descriptor, or ring must be empty */
 	if ((status == SPIDER_NET_DESCR_CARDOWNED) ||
@@ -1057,7 +1071,7 @@ spider_net_decode_one_descr(struct spide
 	chain->tail = descr->next;
 
 	/* unmap descriptor */
-	pci_unmap_single(card->pdev, descr->buf_addr,
+	pci_unmap_single(card->pdev, hwdescr->buf_addr,
 			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
 
 	if ( (status == SPIDER_NET_DESCR_RESPONSE_ERROR) ||
@@ -1080,27 +1094,26 @@ spider_net_decode_one_descr(struct spide
 	}
 
 	/* The cases we'll throw away the packet immediately */
-	if (descr->data_error & SPIDER_NET_DESTROY_RX_FLAGS) {
+	if (hwdescr->data_error & SPIDER_NET_DESTROY_RX_FLAGS) {
 		if (netif_msg_rx_err(card))
 			pr_err("%s: error in received descriptor found, "
 			       "data_status=x%08x, data_error=x%08x\n",
 			       card->netdev->name,
-			       descr->data_status, descr->data_error);
+			       hwdescr->data_status, hwdescr->data_error);
 		goto bad_desc;
 	}
 
-	if (descr->dmac_cmd_status & 0xfefe) {
+	if (hwdescr->dmac_cmd_status & 0xfefe) {
 		pr_err("%s: bad status, cmd_status=x%08x\n",
 			       card->netdev->name,
-			       descr->dmac_cmd_status);
-		pr_err("buf_addr=x%08x\n", descr->buf_addr);
-		pr_err("buf_size=x%08x\n", descr->buf_size);
-		pr_err("next_descr_addr=x%08x\n", descr->next_descr_addr);
-		pr_err("result_size=x%08x\n", descr->result_size);
-		pr_err("valid_size=x%08x\n", descr->valid_size);
-		pr_err("data_status=x%08x\n", descr->data_status);
-		pr_err("data_error=x%08x\n", descr->data_error);
-		pr_err("bus_addr=x%08x\n", descr->bus_addr);
+			       hwdescr->dmac_cmd_status);
+		pr_err("buf_addr=x%08x\n", hwdescr->buf_addr);
+		pr_err("buf_size=x%08x\n", hwdescr->buf_size);
+		pr_err("next_descr_addr=x%08x\n", hwdescr->next_descr_addr);
+		pr_err("result_size=x%08x\n", hwdescr->result_size);
+		pr_err("valid_size=x%08x\n", hwdescr->valid_size);
+		pr_err("data_status=x%08x\n", hwdescr->data_status);
+		pr_err("data_error=x%08x\n", hwdescr->data_error);
 		pr_err("which=%ld\n", descr - card->rx_chain.ring);
 
 		card->spider_stats.rx_desc_error++;
@@ -1109,12 +1122,12 @@ spider_net_decode_one_descr(struct spide
 
 	/* Ok, we've got a packet in descr */
 	spider_net_pass_skb_up(descr, card);
-	descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
+	hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	return 1;
 
 bad_desc:
 	dev_kfree_skb_irq(descr->skb);
-	descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
+	hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	return 0;
 }
 
@@ -2200,9 +2213,6 @@ spider_net_setup_netdev(struct spider_ne
 
 	card->options.rx_csum = SPIDER_NET_RX_CSUM_DEFAULT;
 
-	card->tx_chain.num_desc = tx_descriptors;
-	card->rx_chain.num_desc = rx_descriptors;
-
 	spider_net_setup_netdev_ops(netdev);
 
 	netdev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX;
@@ -2250,8 +2260,11 @@ spider_net_alloc_card(void)
 {
 	struct net_device *netdev;
 	struct spider_net_card *card;
+	size_t alloc_size;
 
-	netdev = alloc_etherdev(sizeof(struct spider_net_card));
+	alloc_size = sizeof(struct spider_net_card) +
+	   (tx_descriptors + rx_descriptors) * sizeof(struct spider_net_descr);
+	netdev = alloc_etherdev(alloc_size);
 	if (!netdev)
 		return NULL;
 
@@ -2262,6 +2275,11 @@ spider_net_alloc_card(void)
 	init_waitqueue_head(&card->waitq);
 	atomic_set(&card->tx_timeout_task_counter, 0);
 
+	card->rx_chain.num_desc = rx_descriptors;
+	card->rx_chain.ring = card->darray;
+	card->tx_chain.num_desc = tx_descriptors;
+	card->tx_chain.ring = card->darray + rx_descriptors;
+
 	return card;
 }
 
