From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] 2.6.0-test4 - more sis190 nit II/II
Date: Wed, 27 Aug 2003 00:14:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827001437.B23532@electric-eye.fr.zoreil.com>
References: <20030826205136.GA32063@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20030826205136.GA32063@gtf.org>; from jgarzik@pobox.com on Tue, Aug 26, 2003 at 04:51:36PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> <jgarzik@redhat.com> (03/08/26 1.1298)
>    [netdrvr sis190] make driver depend on CONFIG_BROKEN
>    
>    Until RX path is cleaned up to use PCI DMA API and
>    not virt_to_bus.
> 
> <jgarzik@redhat.com> (03/08/26 1.1297)
>    [netdrvr sis190] convert TX path to use PCI DMA API
>    
>    Also, minor changes:
>    * mark ->hard_start_xmit ETH_ZLEN test as unlikely()
>    * use cpu_to_le32() and le32_to_cpu() in TX path
>    * fix two leak in error path, in ->hard_start_xmit
>    * don't test netif_queue_stopped() in TX completion path,
>      netif_wake_queue() already does that.
> 

Is plain old patch for the previous items available somewhere ? I had just
finished that (no more work on it before 24h):


Missing pieces for DMA-API.
- SiS190_init_ring: the global area for the received data is mapped.
  This area is persistent during the whole driver's life.
  It only needs to be unmapped in SiS190_close() as no other exit/error
  path exists.
- SiS190_rx_interrupt: no map/unmap for received data buffer. A single
  sync operation is done. Btw, there is no need to store the same value
  in RxDescArray[cur_rx].buf_addr over and over again.
- SiS190_start_xmit: transmitted data buffer is mapped.
- SiS190_tx_clear/SiS190_tx_interrupt: transmitted data buffer is unmapped.


 drivers/net/sis190.c |  109 ++++++++++++++++++++++++++-------------------------
 1 files changed, 57 insertions(+), 52 deletions(-)

diff -puN drivers/net/sis190.c~sis190-dma-mapping drivers/net/sis190.c
--- linux-2.6.0-test4/drivers/net/sis190.c~sis190-dma-mapping	Tue Aug 26 22:28:01 2003
+++ linux-2.6.0-test4-fr/drivers/net/sis190.c	Wed Aug 27 00:00:54 2003
@@ -824,19 +824,19 @@ SiS190_init_ring(struct net_device *dev)
 		tp->Tx_skbuff[i] = NULL;
 	}
 	for (i = 0; i < NUM_RX_DESC; i++) {
+		struct RxDesc *desc = tp->RxDescArray + i;
 
-		tp->RxDescArray[i].PSize = 0x0;
+		desc->PSize = 0x0;
 
 		if (i == (NUM_RX_DESC - 1))
-			tp->RxDescArray[i].buf_Len = BIT_31 + RX_BUF_SIZE;	//bit 31 is End bit
+			desc->buf_Len = BIT_31 + RX_BUF_SIZE;	//bit 31 is End bit
 		else
-			tp->RxDescArray[i].buf_Len = RX_BUF_SIZE;
-
-#warning Replace virt_to_bus with DMA mapping
-		tp->RxBufferRing[i] = &(tp->RxBufferRings[i * RX_BUF_SIZE]);
-		tp->RxDescArray[i].buf_addr = virt_to_bus(tp->RxBufferRing[i]);
-		tp->RxDescArray[i].status = OWNbit | INTbit;
+			desc->buf_Len = RX_BUF_SIZE;
 
+		tp->RxBufferRing[i] = tp->RxBufferRings + i * RX_BUF_SIZE;
+		desc->buf_addr = pci_map_single(tp->pci_dev,
+			tp->RxBufferRing[i], RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+		desc->status = OWNbit | INTbit;
 	}
 
 }
@@ -848,8 +848,14 @@ SiS190_tx_clear(struct sis190_private *t
 
 	tp->cur_tx = 0;
 	for (i = 0; i < NUM_TX_DESC; i++) {
-		if (tp->Tx_skbuff[i] != NULL) {
-			dev_kfree_skb(tp->Tx_skbuff[i]);
+		struct sk_buff *skb = tp->Tx_skbuff[i];
+
+		if (skb != NULL) {
+			pci_unmap_single(tp->pci_dev,
+				tp->TxDescArray[i].buf_addr,
+				(skb->len > ETH_ZLEN) ? skb->len : ETH_ZLEN,
+				PCI_DMA_TODEVICE);
+			dev_kfree_skb(skb);
 			tp->Tx_skbuff[i] = NULL;
 			tp->stats.tx_dropped++;
 		}
@@ -888,6 +894,7 @@ SiS190_start_xmit(struct sk_buff *skb, s
 	struct sis190_private *tp = dev->priv;
 	void *ioaddr = tp->mmio_addr;
 	int entry = tp->cur_tx % NUM_TX_DESC;
+	struct TxDesc *desc = tp->TxDescArray + entry;
 
 	if (skb->len < ETH_ZLEN) {
 		skb = skb_padto(skb, ETH_ZLEN);
@@ -897,23 +904,17 @@ SiS190_start_xmit(struct sk_buff *skb, s
 
 	spin_lock_irq(&tp->lock);
 
-	if ((tp->TxDescArray[entry].status & OWNbit) == 0) {
-#warning Replace virt_to_bus with DMA mapping
+	if ((desc->status & OWNbit) == 0) {
 		tp->Tx_skbuff[entry] = skb;
-		tp->TxDescArray[entry].buf_addr = virt_to_bus(skb->data);
-		tp->TxDescArray[entry].PSize =
-		    ((skb->len > ETH_ZLEN) ? skb->len : ETH_ZLEN);
-
-		if (entry != (NUM_TX_DESC - 1)) {
-			tp->TxDescArray[entry].buf_Len =
-			    tp->TxDescArray[entry].PSize;
-		} else {
-			tp->TxDescArray[entry].buf_Len =
-			    tp->TxDescArray[entry].PSize | ENDbit;
-		}
+		desc->buf_addr = pci_map_single(tp->pci_dev, skb->data,
+			desc->PSize, PCI_DMA_TODEVICE);
+		desc->PSize = ((skb->len > ETH_ZLEN) ? skb->len : ETH_ZLEN);
+
+		desc->buf_Len = desc->PSize;
+		if (entry == (NUM_TX_DESC - 1))
+			desc->buf_Len |= ENDbit;
 
-		tp->TxDescArray[entry].status |=
-		    (OWNbit | INTbit | DEFbit | CRCbit | PADbit);
+		desc->status |= (OWNbit | INTbit | DEFbit | CRCbit | PADbit);
 
 		SiS_W32(TxControl, 0x1a11);	//Start Send
 
@@ -946,10 +947,17 @@ SiS190_tx_interrupt(struct net_device *d
 	tx_left = tp->cur_tx - dirty_tx;
 
 	while (tx_left > 0) {
-		if ((tp->TxDescArray[entry].status & OWNbit) == 0) {
-			dev_kfree_skb_irq(tp->
-					  Tx_skbuff[dirty_tx % NUM_TX_DESC]);
-			tp->Tx_skbuff[dirty_tx % NUM_TX_DESC] = NULL;
+		const int dirty = dirty_tx % NUM_TX_DESC;
+		struct TxDesc *desc = tp->TxDescArray + dirty;
+
+		if ((desc->status & OWNbit) == 0) {
+			struct sk_buff *skb = tp->Tx_skbuff[dirty];
+
+			pci_unmap_single(tp->pci_dev, desc->buf_addr,
+				(skb->len > ETH_ZLEN) ? skb->len : ETH_ZLEN,
+				PCI_DMA_TODEVICE);
+			dev_kfree_skb_irq(skb);
+			tp->Tx_skbuff[dirty] = NULL;
 			tp->stats.tx_packets++;
 			dirty_tx++;
 			tx_left--;
@@ -968,29 +976,30 @@ static void
 SiS190_rx_interrupt(struct net_device *dev, struct sis190_private *tp,
 		    void *ioaddr)
 {
-	int cur_rx;
-	struct sk_buff *skb;
-	int pkt_size = 0;
+	int cur_rx = tp->cur_rx;
+	struct RxDesc *desc = tp->RxDescArray + cur_rx;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
 	assert(ioaddr != NULL);
 
-	cur_rx = tp->cur_rx;
-	while ((tp->RxDescArray[cur_rx].status & OWNbit) == 0) {
+	while ((desc->status & OWNbit) == 0) {
 
-		if (tp->RxDescArray[cur_rx].PSize & 0x0080000) {
+		if (desc->PSize & 0x0080000) {
 			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
 			tp->stats.rx_errors++;
 			tp->stats.rx_length_errors++;
-		} else if (!(tp->RxDescArray[cur_rx].PSize & 0x0010000)) {
+		} else if (!(desc->PSize & 0x0010000)) {
 			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
 			tp->stats.rx_errors++;
 			tp->stats.rx_crc_errors++;
 		} else {
-			pkt_size =
-			    (int) (tp->RxDescArray[cur_rx].
-				   PSize & 0x0000FFFF) - 4;
+			struct sk_buff *skb;
+			int pkt_size;
+
+			pkt_size = (int) (desc->PSize & 0x0000FFFF) - 4;
+			pci_dma_sync_single(tp->pci_dev, desc->buf_addr,
+				RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 			skb = dev_alloc_skb(pkt_size + 2);
 			if (skb != NULL) {
 				skb->dev = dev;
@@ -1001,24 +1010,18 @@ SiS190_rx_interrupt(struct net_device *d
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
 
-				tp->RxDescArray[cur_rx].PSize = 0x0;
+				desc->PSize = 0x0;
 
 				if (cur_rx == (NUM_RX_DESC - 1))
-					tp->RxDescArray[cur_rx].buf_Len =
-					    ENDbit + RX_BUF_SIZE;
+					desc->buf_Len = ENDbit + RX_BUF_SIZE;
 				else
-					tp->RxDescArray[cur_rx].buf_Len =
-					    RX_BUF_SIZE;
+					desc->buf_Len = RX_BUF_SIZE;
 
-#warning Replace virt_to_bus with DMA mapping
-				tp->RxDescArray[cur_rx].buf_addr =
-				    virt_to_bus(tp->RxBufferRing[cur_rx]);
 				dev->last_rx = jiffies;
 				tp->stats.rx_bytes += pkt_size;
 				tp->stats.rx_packets++;
 
-				tp->RxDescArray[cur_rx].status =
-				    OWNbit | INTbit;
+				desc->status = OWNbit | INTbit;
 			} else {
 				printk(KERN_WARNING
 				       "%s: Memory squeeze, deferring packet.\n",
@@ -1030,7 +1033,7 @@ SiS190_rx_interrupt(struct net_device *d
 		}
 
 		cur_rx = (cur_rx + 1) % NUM_RX_DESC;
-
+		desc = tp->RxDescArray + cur_rx;
 	}
 
 	tp->cur_rx = cur_rx;
@@ -1114,11 +1117,13 @@ SiS190_close(struct net_device *dev)
 	pci_free_consistent(tp->pci_dev, RX_DESC_TOTAL_SIZE, tp->RxDescArray,
 		tp->rx_dma);
 	tp->TxDescArray = NULL;
-	tp->RxDescArray = NULL;
-	kfree(tp->RxBufferRings);
 	for (i = 0; i < NUM_RX_DESC; i++) {
+		pci_unmap_single(tp->pci_dev, tp->RxDescArray[i].buf_addr,
+			RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 		tp->RxBufferRing[i] = NULL;
 	}
+	tp->RxDescArray = NULL;
+	kfree(tp->RxBufferRings);
 
 	return 0;
 }

_
