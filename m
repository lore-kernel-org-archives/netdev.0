From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/4] tulip: Convert printks to netdev_<level>
Date: Wed, 11 May 2011 21:59:31 -0700
Message-ID: <1305176371.6124.29.camel@Joe-Laptop>
References: <cover.1304733889.git.joe@perches.com>
	 <84a86a5b89eac3aec88427c8afd09591bd5b0cfc.1304733889.git.joe@perches.com>
	 <20110512040906.GB8885@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tobias Ringstrom <tori@unhappy.mine.nu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1544 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752928Ab1ELE7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 00:59:34 -0400
In-Reply-To: <20110512040906.GB8885@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-11 at 22:09 -0600, Grant Grundler wrote:
> Some additional clean ups to consider in a future patch:
> o replace "if (skb == NULL)" with "if (!skb)" 

Hey Grant.

I generally don't change those.
While I prefer (!ptr), others prefer explicit comparisons.
I do have a script that does the conversion though.
(de4x5.c is a mess and I didn't change it)

Here's the output with hoisted assigns from if too.
(and a spelling fix I noticed)

 drivers/net/tulip/de2104x.c     |    3 ++-
 drivers/net/tulip/dmfe.c        |   11 ++++++-----
 drivers/net/tulip/eeprom.c      |    6 +++---
 drivers/net/tulip/interrupt.c   |   18 +++++++++---------
 drivers/net/tulip/timer.c       |    2 +-
 drivers/net/tulip/tulip_core.c  |   15 +++++++++------
 drivers/net/tulip/uli526x.c     |   15 +++++++--------
 drivers/net/tulip/winbond-840.c |   14 ++++++++------
 drivers/net/tulip/xircom_cb.c   |   12 ++++++------
 9 files changed, 51 insertions(+), 45 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index e2f6923..45a4843 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -2170,7 +2170,8 @@ static int de_resume (struct pci_dev *pdev)
 		goto out;
 	if (!netif_running(dev))
 		goto out_attach;
-	if ((retval = pci_enable_device(pdev))) {
+	retval = pci_enable_device(pdev);
+	if (retval) {
 		netdev_err(dev, "pci_enable_device failed in resume\n");
 		goto out;
 	}
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 4685127..588d6b4 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -400,7 +400,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 
 	/* Init network device */
 	dev = alloc_etherdev(sizeof(*db));
-	if (dev == NULL)
+	if (!dev)
 		return -ENOMEM;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -1009,10 +1009,10 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 					db->dm910x_chk_mode = 3;
 				} else {
 					/* Good packet, send to upper layer */
-					/* Shorst packet used new SKB */
+					/* Short packet used new SKB */
 					if ((rxlen < RX_COPY_SIZE) &&
-						((newskb = dev_alloc_skb(rxlen + 2))
-						!= NULL)) {
+					    (newskb =
+						dev_alloc_skb(rxlen + 2))) {
 
 						skb = newskb;
 						/* size less than COPY_SIZE, allocate a rxlen SKB */
@@ -1561,7 +1561,8 @@ static void allocate_rx_buffer(struct dmfe_board_info *db)
 	rxptr = db->rx_insert_ptr;
 
 	while(db->rx_avail_cnt < RX_DESC_CNT) {
-		if ( ( skb = dev_alloc_skb(RX_ALLOC_SIZE) ) == NULL )
+		skb = dev_alloc_skb(RX_ALLOC_SIZE);
+		if (!skb)
 			break;
 		rxptr->rx_skb_ptr = skb; /* FIXME (?) */
 		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev, skb->data,
diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
index fa5eee9..a11eb73 100644
--- a/drivers/net/tulip/eeprom.c
+++ b/drivers/net/tulip/eeprom.c
@@ -123,7 +123,7 @@ static void __devinit tulip_build_fake_mediatable(struct tulip_private *tp)
 		tp->mtable = kmalloc(sizeof(struct mediatable) +
 				     sizeof(struct medialeaf), GFP_KERNEL);
 
-		if (tp->mtable == NULL)
+		if (!tp->mtable)
 			return; /* Horrible, impossible failure. */
 
 		tp->mtable->defaultmedia = 0x800;
@@ -192,7 +192,7 @@ void __devinit tulip_parse_eeprom(struct net_device *dev)
 		  break;
 		}
 	  }
-	  if (eeprom_fixups[i].name == NULL) { /* No fixup found. */
+	  if (!eeprom_fixups[i].name) { /* No fixup found. */
 		  pr_info("%s: Old style EEPROM with no media selection information\n",
 			  dev->name);
 		return;
@@ -230,7 +230,7 @@ subsequent_board:
 		mtable = kmalloc(sizeof(struct mediatable) +
 				 count * sizeof(struct medialeaf),
 				 GFP_KERNEL);
-		if (mtable == NULL)
+		if (!mtable)
 			return;				/* Horrible, impossible failure. */
 		last_mediatable = tp->mtable = mtable;
 		mtable->defaultmedia = media;
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index 5350d75..1a1bff5 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -68,12 +68,12 @@ int tulip_refill_rx(struct net_device *dev)
 	/* Refill the Rx ring buffers. */
 	for (; tp->cur_rx - tp->dirty_rx > 0; tp->dirty_rx++) {
 		entry = tp->dirty_rx % RX_RING_SIZE;
-		if (tp->rx_buffers[entry].skb == NULL) {
+		if (!tp->rx_buffers[entry].skb) {
 			struct sk_buff *skb;
 			dma_addr_t mapping;
 
 			skb = tp->rx_buffers[entry].skb = dev_alloc_skb(PKT_BUF_SZ);
-			if (skb == NULL)
+			if (!skb)
 				break;
 
 			mapping = pci_map_single(tp->pdev, skb->data, PKT_BUF_SZ,
@@ -205,7 +205,7 @@ int tulip_poll(struct napi_struct *napi, int budget)
                                /* Check if the packet is long enough to accept without copying
                                   to a minimally-sized skbuff. */
                                if (pkt_len < tulip_rx_copybreak &&
-                                   (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+				   (skb = dev_alloc_skb(pkt_len + 2))) {
                                        skb_reserve(skb, 2);    /* 16 byte align the IP header */
                                        pci_dma_sync_single_for_cpu(tp->pdev,
 								   tp->rx_buffers[entry].mapping,
@@ -311,7 +311,7 @@ int tulip_poll(struct napi_struct *napi, int budget)
          tulip_refill_rx(dev);
 
          /* If RX ring is not full we are out of memory. */
-         if (tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL)
+	 if (!tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb)
 		 goto oom;
 
          /* Remove us from polling list and enable RX intr. */
@@ -334,10 +334,10 @@ int tulip_poll(struct napi_struct *napi, int budget)
 
  not_done:
          if (tp->cur_rx - tp->dirty_rx > RX_RING_SIZE/2 ||
-             tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL)
+	     !tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb)
                  tulip_refill_rx(dev);
 
-         if (tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL)
+	 if (!tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb)
 		 goto oom;
 
          return work_done;
@@ -431,7 +431,7 @@ static int tulip_rx(struct net_device *dev)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < tulip_rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = dev_alloc_skb(pkt_len + 2))) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(tp->pdev,
 							    tp->rx_buffers[entry].mapping,
@@ -591,7 +591,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 					break;			/* It still has not been Txed */
 
 				/* Check for Rx filter setup frames. */
-				if (tp->tx_buffers[entry].skb == NULL) {
+				if (!tp->tx_buffers[entry].skb) {
 					/* test because dummy frames not mapped */
 					if (tp->tx_buffers[entry].mapping)
 						pci_unmap_single(tp->pdev,
@@ -775,7 +775,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 
 	/* check if the card is in suspend mode */
 	entry = tp->dirty_rx % RX_RING_SIZE;
-	if (tp->rx_buffers[entry].skb == NULL) {
+	if (!tp->rx_buffers[entry].skb) {
 		if (tulip_debug > 1)
 			dev_warn(&dev->dev,
 				 "in rx suspend mode: (%lu) (tp->cur_rx = %u, ttimer = %d, rx = %d) go/stay in suspend mode\n",
diff --git a/drivers/net/tulip/timer.c b/drivers/net/tulip/timer.c
index 2017faf..afc5445 100644
--- a/drivers/net/tulip/timer.c
+++ b/drivers/net/tulip/timer.c
@@ -43,7 +43,7 @@ void tulip_media_task(struct work_struct *work)
 	default: {
 		struct medialeaf *mleaf;
 		unsigned char *p;
-		if (tp->mtable == NULL) {	/* No EEPROM info, use generic code. */
+		if (!tp->mtable) {	/* No EEPROM info, use generic code. */
 			/* Not much that can be done.
 			   Assume this a generic MII or SYM transceiver. */
 			next_tick = 60*HZ;
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 82f8764..0ab2465 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -384,7 +384,7 @@ static void tulip_up(struct net_device *dev)
 
 	/* Allow selecting a default media. */
 	i = 0;
-	if (tp->mtable == NULL)
+	if (!tp->mtable)
 		goto media_picked;
 	if (dev->if_port) {
 		int looking_for = tulip_media_cap[dev->if_port] & MediaIsMII ? 11 :
@@ -642,7 +642,7 @@ static void tulip_init_ring(struct net_device *dev)
 		   use skb_reserve() to align the IP header! */
 		struct sk_buff *skb = dev_alloc_skb(PKT_BUF_SZ);
 		tp->rx_buffers[i].skb = skb;
-		if (skb == NULL)
+		if (!skb)
 			break;
 		mapping = pci_map_single(tp->pdev, skb->data,
 					 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
@@ -728,7 +728,7 @@ static void tulip_clean_tx_ring(struct tulip_private *tp)
 		}
 
 		/* Check for Tx filter setup frames. */
-		if (tp->tx_buffers[entry].skb == NULL) {
+		if (!tp->tx_buffers[entry].skb) {
 			/* test because dummy frames not mapped */
 			if (tp->tx_buffers[entry].mapping)
 				pci_unmap_single(tp->pdev,
@@ -821,7 +821,7 @@ static void tulip_free_ring (struct net_device *dev)
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		struct sk_buff *skb = tp->tx_buffers[i].skb;
 
-		if (skb != NULL) {
+		if (skb) {
 			pci_unmap_single(tp->pdev, tp->tx_buffers[i].mapping,
 					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb (skb);
@@ -1900,12 +1900,15 @@ static int tulip_resume(struct pci_dev *pdev)
 	if (!netif_running(dev))
 		return 0;
 
-	if ((retval = pci_enable_device(pdev))) {
+	retval = pci_enable_device(pdev);
+	if (retval) {
 		pr_err("pci_enable_device failed in resume\n");
 		return retval;
 	}
 
-	if ((retval = request_irq(dev->irq, tulip_interrupt, IRQF_SHARED, dev->name, dev))) {
+	retval = request_irq(dev->irq, tulip_interrupt, IRQF_SHARED,
+			     dev->name, dev);
+	if (retval) {
 		pr_err("request_irq failed in resume\n");
 		return retval;
 	}
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 9e63f40..a6f6a9e 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -286,7 +286,7 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 
 	/* Init network device */
 	dev = alloc_etherdev(sizeof(*db));
-	if (dev == NULL)
+	if (!dev)
 		return -ENOMEM;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -324,14 +324,12 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 
 	/* Allocate Tx/Rx descriptor memory */
 	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
-	if(db->desc_pool_ptr == NULL)
-	{
+	if (!db->desc_pool_ptr) {
 		err = -ENOMEM;
 		goto err_out_nomem;
 	}
 	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
-	if(db->buf_pool_ptr == NULL)
-	{
+	if (!db->buf_pool_ptr) {
 		err = -ENOMEM;
 		goto err_out_nomem;
 	}
@@ -404,7 +402,7 @@ err_out_nomem:
 		pci_free_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20,
 			db->desc_pool_ptr, db->desc_pool_dma_ptr);
 
-	if(db->buf_pool_ptr != NULL)
+	if (db->buf_pool_ptr)
 		pci_free_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
 			db->buf_pool_ptr, db->buf_pool_dma_ptr);
 err_out_disable:
@@ -844,7 +842,7 @@ static void uli526x_rx_packet(struct net_device *dev, struct uli526x_board_info
 				/* Good packet, send to upper layer */
 				/* Shorst packet used new SKB */
 				if ((rxlen < RX_COPY_SIZE) &&
-				    (((new_skb = dev_alloc_skb(rxlen + 2)) != NULL))) {
+				    (new_skb = dev_alloc_skb(rxlen + 2))) {
 					skb = new_skb;
 					/* size less than COPY_SIZE, allocate a rxlen SKB */
 					skb_reserve(skb, 2); /* 16byte align */
@@ -1440,7 +1438,8 @@ static void allocate_rx_buffer(struct uli526x_board_info *db)
 	rxptr = db->rx_insert_ptr;
 
 	while(db->rx_avail_cnt < RX_DESC_CNT) {
-		if ( ( skb = dev_alloc_skb(RX_ALLOC_SIZE) ) == NULL )
+		skb = dev_alloc_skb(RX_ALLOC_SIZE);
+		if (!skb)
 			break;
 		rxptr->rx_skb_ptr = skb; /* FIXME (?) */
 		rxptr->rdes2 = cpu_to_le32(pci_map_single(db->pdev,
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 862eadf..a957e72 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -647,7 +647,8 @@ static int netdev_open(struct net_device *dev)
 	if (debug > 1)
 		netdev_dbg(dev, "w89c840_open() irq %d\n", dev->irq);
 
-	if((i=alloc_ringdesc(dev)))
+	i = alloc_ringdesc(dev);
+	if (i)
 		goto out_err;
 
 	spin_lock_irq(&np->lock);
@@ -817,7 +818,7 @@ static void init_rxtx_rings(struct net_device *dev)
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz);
 		np->rx_skbuff[i] = skb;
-		if (skb == NULL)
+		if (!skb)
 			break;
 		np->rx_addr[i] = pci_map_single(np->pci_dev,skb->data,
 					np->rx_buf_sz,PCI_DMA_FROMDEVICE);
@@ -1231,7 +1232,7 @@ static int netdev_rx(struct net_device *dev)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = dev_alloc_skb(pkt_len + 2))) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(np->pci_dev,np->rx_addr[entry],
 							    np->rx_skbuff[entry]->len,
@@ -1269,10 +1270,10 @@ static int netdev_rx(struct net_device *dev)
 	for (; np->cur_rx - np->dirty_rx > 0; np->dirty_rx++) {
 		struct sk_buff *skb;
 		entry = np->dirty_rx % RX_RING_SIZE;
-		if (np->rx_skbuff[entry] == NULL) {
+		if (!np->rx_skbuff[entry]) {
 			skb = dev_alloc_skb(np->rx_buf_sz);
 			np->rx_skbuff[entry] = skb;
-			if (skb == NULL)
+			if (!skb)
 				break;			/* Better luck next round. */
 			np->rx_addr[entry] = pci_map_single(np->pci_dev,
 							skb->data,
@@ -1618,7 +1619,8 @@ static int w840_resume (struct pci_dev *pdev)
 	if (netif_device_present(dev))
 		goto out; /* device not suspended */
 	if (netif_running(dev)) {
-		if ((retval = pci_enable_device(pdev))) {
+		retval = pci_enable_device(pdev);
+		if (retval) {
 			dev_err(&dev->dev,
 				"pci_enable_device failed in resume\n");
 			goto out;
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 988b8eb..1cb7208 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -230,12 +230,12 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 
 	/* Allocate the send/receive buffers */
 	private->rx_buffer = pci_alloc_consistent(pdev,8192,&private->rx_dma_handle);
-	if (private->rx_buffer == NULL) {
+	if (!private->rx_buffer) {
 		pr_err("%s: no memory for rx buffer\n", __func__);
 		goto rx_buf_fail;
 	}
 	private->tx_buffer = pci_alloc_consistent(pdev,8192,&private->tx_dma_handle);
-	if (private->tx_buffer == NULL) {
+	if (!private->tx_buffer) {
 		pr_err("%s: no memory for tx buffer\n", __func__);
 		goto tx_buf_fail;
 	}
@@ -546,8 +546,8 @@ static void setup_descriptors(struct xircom_private *card)
 	u32 address;
 	int i;
 
-	BUG_ON(card->rx_buffer == NULL);
-	BUG_ON(card->tx_buffer == NULL);
+	BUG_ON(!card->rx_buffer);
+	BUG_ON(!card->tx_buffer);
 
 	/* Receive descriptors */
 	memset(card->rx_buffer, 0, 128);	/* clear the descriptors */
@@ -1086,7 +1086,7 @@ investigate_read_descriptor(struct net_device *dev, struct xircom_private *card,
 		}
 
 		skb = dev_alloc_skb(pkt_len + 2);
-		if (skb == NULL) {
+		if (!skb) {
 			dev->stats.rx_dropped++;
 			goto out;
 		}
@@ -1125,7 +1125,7 @@ investigate_write_descriptor(struct net_device *dev,
 	}
 #endif
 	if (status > 0) {	/* bit 31 is 0 when done */
-		if (card->tx_skb[descnr]!=NULL) {
+		if (card->tx_skb[descnr]) {
 			dev->stats.tx_bytes += card->tx_skb[descnr]->len;
 			dev_kfree_skb_irq(card->tx_skb[descnr]);
 		}

> o in general, HW doesn't return signed integer values.  Where possible,
>   I prefer to see "unsigned int status;" and "if (status)".

That one is yours to change if you want.

