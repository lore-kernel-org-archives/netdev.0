From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patches] 2.6.0-test9 - r8169 DMA API conversion
Date: Thu, 20 Nov 2003 01:00:56 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031120010056.A19444@electric-eye.fr.zoreil.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com> <3FB9A277.70309@pobox.com> <20031118135848.A2451@electric-eye.fr.zoreil.com> <3FBBA76B.4070606@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="n8g4imXOkfNTN/H1"
Cc: Brad House <brad_mssw@gentoo.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3FBBA76B.4070606@pobox.com>; from jgarzik@pobox.com on Wed, Nov 19, 2003 at 12:24:59PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Jeff Garzik <jgarzik@pobox.com> :
[...]
> hehe.  I certainly don't object...  You probably want to look over the 
> r8169 v1.6 that Brad posted a link to, since it does have some improved 
> 8169 hardware support (modulo bugs, of course).

Ok, will do (hmmm... looks like a free ticket for "Whitespace attacks").

I have attached the usual DMA rework for:
- the Tx descriptors;
- the Rx process (with the original big Rx buffer removed).

Feel free to comment/review. Next patch tomorrow.

--
Ueimor

--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-dma-api-tx.patch"


Conversion of Rx/Tx descriptors to consistent DMA:
- use pci_alloc_consistent() for Rx/Tx descriptors in rtl8169_open()
  (balanced by pci_free_consistent() on error path as well as in
  rtl8169_close());
- removal of the fields {Rx/Tx}DescArrays in struct rtl8169_private
  as there is no need to store a non-256 bytes aligned address any more;
- fix for rtl8169_open() leak when RxBufferRings allocation fails.
  Said allocation is pushed to rtl8169_init_ring() as part of an evil
  cunning plan.


 drivers/net/r8169.c |   99 +++++++++++++++++++++++++++-------------------------
 1 files changed, 52 insertions(+), 47 deletions(-)

diff -puN drivers/net/r8169.c~r8169-dma-api-tx drivers/net/r8169.c
--- linux-2.6.0-test9/drivers/net/r8169.c~r8169-dma-api-tx	2003-11-19 20:30:09.000000000 +0100
+++ linux-2.6.0-test9-fr/drivers/net/r8169.c	2003-11-19 21:24:44.000000000 +0100
@@ -89,6 +89,8 @@ static int multicast_filter_limit = 32;
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
 #define NUM_RX_DESC	64	/* Number of Rx descriptor registers */
 #define RX_BUF_SIZE	1536	/* Rx Buffer size */
+#define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
+#define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
 
 #define RTL_MIN_IO_SIZE 0x80
 #define TX_TIMEOUT  (6*HZ)
@@ -280,10 +282,10 @@ struct rtl8169_private {
 	unsigned long cur_rx;	/* Index into the Rx descriptor buffer of next Rx pkt. */
 	unsigned long cur_tx;	/* Index into the Tx descriptor buffer of next Rx pkt. */
 	unsigned long dirty_tx;
-	unsigned char *TxDescArrays;	/* Index of Tx Descriptor buffer */
-	unsigned char *RxDescArrays;	/* Index of Rx Descriptor buffer */
 	struct TxDesc *TxDescArray;	/* Index of 256-alignment Tx Descriptor buffer */
 	struct RxDesc *RxDescArray;	/* Index of 256-alignment Rx Descriptor buffer */
+	dma_addr_t TxPhyAddr;
+	dma_addr_t RxPhyAddr;
 	unsigned char *RxBufferRings;	/* Index of Rx Buffer  */
 	unsigned char *RxBufferRing[NUM_RX_DESC];	/* Index of Rx Buffer array */
 	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Index of Transmit data buffer */
@@ -297,7 +299,7 @@ static int rtl8169_open(struct net_devic
 static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance,
 			      struct pt_regs *regs);
-static void rtl8169_init_ring(struct net_device *dev);
+static int rtl8169_init_ring(struct net_device *dev);
 static void rtl8169_hw_start(struct net_device *dev);
 static int rtl8169_close(struct net_device *dev);
 static void rtl8169_set_rx_mode(struct net_device *dev);
@@ -654,52 +656,48 @@ static int
 rtl8169_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = dev->priv;
+	struct pci_dev *pdev = tp->pci_dev;
 	int retval;
-	u8 diff;
-	u32 TxPhyAddr, RxPhyAddr;
 
 	retval =
 	    request_irq(dev->irq, rtl8169_interrupt, SA_SHIRQ, dev->name, dev);
-	if (retval) {
-		return retval;
-	}
+	if (retval < 0)
+		goto out;
 
-	tp->TxDescArrays =
-	    kmalloc(NUM_TX_DESC * sizeof (struct TxDesc) + 256, GFP_KERNEL);
-	// Tx Desscriptor needs 256 bytes alignment;
-	TxPhyAddr = virt_to_bus(tp->TxDescArrays);
-	diff = 256 - (TxPhyAddr - ((TxPhyAddr >> 8) << 8));
-	TxPhyAddr += diff;
-	tp->TxDescArray = (struct TxDesc *) (tp->TxDescArrays + diff);
-
-	tp->RxDescArrays =
-	    kmalloc(NUM_RX_DESC * sizeof (struct RxDesc) + 256, GFP_KERNEL);
-	// Rx Desscriptor needs 256 bytes alignment;
-	RxPhyAddr = virt_to_bus(tp->RxDescArrays);
-	diff = 256 - (RxPhyAddr - ((RxPhyAddr >> 8) << 8));
-	RxPhyAddr += diff;
-	tp->RxDescArray = (struct RxDesc *) (tp->RxDescArrays + diff);
+	retval = -ENOMEM;
 
-	if (tp->TxDescArrays == NULL || tp->RxDescArrays == NULL) {
-		printk(KERN_INFO
-		       "Allocate RxDescArray or TxDescArray failed\n");
-		free_irq(dev->irq, dev);
-		if (tp->TxDescArrays)
-			kfree(tp->TxDescArrays);
-		if (tp->RxDescArrays)
-			kfree(tp->RxDescArrays);
-		return -ENOMEM;
-	}
-	tp->RxBufferRings = kmalloc(RX_BUF_SIZE * NUM_RX_DESC, GFP_KERNEL);
-	if (tp->RxBufferRings == NULL) {
-		printk(KERN_INFO "Allocate RxBufferRing failed\n");
-	}
+	/*
+	 * Rx and Tx desscriptors needs 256 bytes alignment.
+	 * pci_alloc_consistent provides more.
+	 */
+	tp->TxDescArray = pci_alloc_consistent(pdev, R8169_TX_RING_BYTES,
+					       &tp->TxPhyAddr);
+	if (!tp->TxDescArray)
+		goto err_free_irq;
+
+	tp->RxDescArray = pci_alloc_consistent(pdev, R8169_RX_RING_BYTES,
+					       &tp->RxPhyAddr);
+	if (!tp->RxDescArray)
+		goto err_free_tx;
+
+	retval = rtl8169_init_ring(dev);
+	if (retval < 0)
+		goto err_free_rx;
 
-	rtl8169_init_ring(dev);
 	rtl8169_hw_start(dev);
 
-	return 0;
+out:
+	return retval;
 
+err_free_rx:
+	pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
+			    tp->RxPhyAddr);
+err_free_tx:
+	pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDescArray,
+			    tp->TxPhyAddr);
+err_free_irq:
+	free_irq(dev->irq, dev);
+	goto out;
 }
 
 static void
@@ -739,8 +737,8 @@ rtl8169_hw_start(struct net_device *dev)
 
 	tp->cur_rx = 0;
 
-	RTL_W32(TxDescStartAddr, virt_to_bus(tp->TxDescArray));
-	RTL_W32(RxDescStartAddr, virt_to_bus(tp->RxDescArray));
+	RTL_W32(TxDescStartAddr, tp->TxPhyAddr);
+	RTL_W32(RxDescStartAddr, tp->RxPhyAddr);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 	udelay(10);
 
@@ -758,12 +756,17 @@ rtl8169_hw_start(struct net_device *dev)
 
 }
 
-static void
-rtl8169_init_ring(struct net_device *dev)
+static int rtl8169_init_ring(struct net_device *dev)
 {
 	struct rtl8169_private *tp = dev->priv;
 	int i;
 
+	tp->RxBufferRings = kmalloc(RX_BUF_SIZE * NUM_RX_DESC, GFP_KERNEL);
+	if (tp->RxBufferRings == NULL) {
+		printk(KERN_INFO "Allocate RxBufferRing failed\n");
+		return -ENOMEM;
+	}
+
 	tp->cur_rx = 0;
 	tp->cur_tx = 0;
 	tp->dirty_tx = 0;
@@ -783,6 +786,7 @@ rtl8169_init_ring(struct net_device *dev
 		tp->RxBufferRing[i] = &(tp->RxBufferRings[i * RX_BUF_SIZE]);
 		tp->RxDescArray[i].buf_addr = virt_to_bus(tp->RxBufferRing[i]);
 	}
+	return 0;
 }
 
 static void
@@ -1026,6 +1030,7 @@ static int
 rtl8169_close(struct net_device *dev)
 {
 	struct rtl8169_private *tp = dev->priv;
+	struct pci_dev *pdev = tp->pci_dev;
 	void *ioaddr = tp->mmio_addr;
 	int i;
 
@@ -1049,10 +1054,10 @@ rtl8169_close(struct net_device *dev)
 	free_irq(dev->irq, dev);
 
 	rtl8169_tx_clear(tp);
-	kfree(tp->TxDescArrays);
-	kfree(tp->RxDescArrays);
-	tp->TxDescArrays = NULL;
-	tp->RxDescArrays = NULL;
+	pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
+			    tp->RxPhyAddr);
+	pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDescArray,
+			    tp->TxPhyAddr);
 	tp->TxDescArray = NULL;
 	tp->RxDescArray = NULL;
 	kfree(tp->RxBufferRings);

_

--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-dma-api-data-buffers.patch"


Conversion of Rx data buffers to PCI DMA
- endianness is kept in a fscked state as it is in the original code
  (will be adressed in a later patch);
- rtl8169_rx_clear() walks the buffer ring and releases the allocated
  data buffers. It needs to be used in two places: 
  - rtl8169_init_ring() failure path;
  - normal device release (i.e. rtl8169_close);
- rtl8169_free_rx_skb() releases a Rx data buffer. Mostly an helper
  for rtl8169_rx_clear(). As such it must:
  - unmap the memory area;
  - release the skb;
  - prevent the ring descriptor from being used again;
- rtl8169_alloc_rx_skb() prepares a Rx data buffer for use.
  As such it must:
  - allocate an skb;
  - map the memory area;
  - reflect the changes in the ring descriptor.
  This function is balanced by rtl8169_free_rx_skb().
- rtl8169_unmap_rx() simply helps with the 80-columns limit.
- rtl8169_rx_fill() walks a given range of the buffer ring and
  try to turn any descriptor into a ready to use one. It returns the
  count of modified descriptors and exits if an allocation fails.
  It can be seen as balanced by rtl8169_rx_clear(). Motivation:
  - partially abstract the (usually big) piece of code for the refill
    logic at the end of the Rx interrupt;
  - factorize the refill logic and the initial ring setup.
- simple conversion of rtl8169_rx_interrupt() without rx_copybreak
  (will be adressed in a later patch).


 drivers/net/r8169.c |  235 +++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 161 insertions(+), 74 deletions(-)

diff -puN drivers/net/r8169.c~r8169-dma-api-data-buffers drivers/net/r8169.c
--- linux-2.6.0-test9/drivers/net/r8169.c~r8169-dma-api-data-buffers	2003-11-19 21:26:45.000000000 +0100
+++ linux-2.6.0-test9-fr/drivers/net/r8169.c	2003-11-20 00:45:00.000000000 +0100
@@ -279,15 +279,15 @@ struct rtl8169_private {
 	struct net_device_stats stats;	/* statistics of net device */
 	spinlock_t lock;	/* spin lock flag */
 	int chipset;
-	unsigned long cur_rx;	/* Index into the Rx descriptor buffer of next Rx pkt. */
-	unsigned long cur_tx;	/* Index into the Tx descriptor buffer of next Rx pkt. */
-	unsigned long dirty_tx;
+	u32 cur_rx; /* Index into the Rx descriptor buffer of next Rx pkt. */
+	u32 cur_tx; /* Index into the Tx descriptor buffer of next Rx pkt. */
+	u32 dirty_rx;
+	u32 dirty_tx;
 	struct TxDesc *TxDescArray;	/* Index of 256-alignment Tx Descriptor buffer */
 	struct RxDesc *RxDescArray;	/* Index of 256-alignment Rx Descriptor buffer */
 	dma_addr_t TxPhyAddr;
 	dma_addr_t RxPhyAddr;
-	unsigned char *RxBufferRings;	/* Index of Rx Buffer  */
-	unsigned char *RxBufferRing[NUM_RX_DESC];	/* Index of Rx Buffer array */
+	struct sk_buff *Rx_skbuff[NUM_RX_DESC];	/* Rx data buffers */
 	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Index of Transmit data buffer */
 };
 
@@ -756,37 +756,119 @@ rtl8169_hw_start(struct net_device *dev)
 
 }
 
-static int rtl8169_init_ring(struct net_device *dev)
+static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
+{
+	desc->buf_addr = 0xdeadbeef;
+	desc->status = EORbit; 
+}
+
+static void rtl8169_free_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
+				struct RxDesc *desc)
+{
+	pci_unmap_single(pdev, desc->buf_addr, RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+	dev_kfree_skb(*sk_buff);
+	*sk_buff = NULL;
+	rtl8169_make_unusable_by_asic(desc);
+}
+
+static inline void rtl8169_give_to_asic(struct RxDesc *desc, dma_addr_t mapping)
+{
+	desc->buf_addr = mapping;
+	desc->status = OWNbit + RX_BUF_SIZE;
+}
+
+static int rtl8169_alloc_rx_skb(struct pci_dev *pdev, struct net_device *dev,
+				struct sk_buff **sk_buff, struct RxDesc *desc)
+{
+	struct sk_buff *skb;
+	dma_addr_t mapping;
+	int ret = 0;
+
+	skb = dev_alloc_skb(RX_BUF_SIZE);
+	if (!skb)
+		goto err_out;
+
+	skb->dev = dev;
+	skb_reserve(skb, 2);
+	*sk_buff = skb;
+
+	mapping = pci_map_single(pdev, skb->tail, RX_BUF_SIZE,
+				 PCI_DMA_FROMDEVICE);
+
+	rtl8169_give_to_asic(desc, mapping);
+
+out:
+	return ret;
+
+err_out:
+	ret = -ENOMEM;
+	rtl8169_make_unusable_by_asic(desc);
+	goto out;
+}
+
+static void rtl8169_rx_clear(struct rtl8169_private *tp)
 {
-	struct rtl8169_private *tp = dev->priv;
 	int i;
 
-	tp->RxBufferRings = kmalloc(RX_BUF_SIZE * NUM_RX_DESC, GFP_KERNEL);
-	if (tp->RxBufferRings == NULL) {
-		printk(KERN_INFO "Allocate RxBufferRing failed\n");
-		return -ENOMEM;
+	for (i = 0; i < NUM_RX_DESC; i++) {
+		if (tp->Rx_skbuff[i]) {
+			rtl8169_free_rx_skb(tp->pci_dev, tp->Rx_skbuff + i,
+					    tp->RxDescArray + i);
+		}
 	}
+}
 
-	tp->cur_rx = 0;
-	tp->cur_tx = 0;
-	tp->dirty_tx = 0;
+static u32 rtl8169_rx_fill(struct rtl8169_private *tp, struct net_device *dev,
+			   u32 start, u32 end)
+{
+	u32 cur;
+	
+	for (cur = start; end - start > 0; cur++) {
+		int ret, i = cur % NUM_RX_DESC;
+
+		if (tp->Rx_skbuff[i])
+			continue;
+			
+		ret = rtl8169_alloc_rx_skb(tp->pci_dev, dev, tp->Rx_skbuff + i,
+					   tp->RxDescArray + i);
+		if (ret < 0)
+			break;
+	}
+	return cur - start;
+}
+
+static inline void rtl8169_mark_as_last_descriptor(struct RxDesc *desc)
+{
+	desc->status |= EORbit;
+}
+
+static inline void rtl8169_unmark_as_last_descriptor(struct RxDesc *desc)
+{
+	desc->status &= ~EORbit;
+}
+
+static int rtl8169_init_ring(struct net_device *dev)
+{
+	struct rtl8169_private *tp = dev->priv;
+
+	tp->cur_rx = tp->dirty_rx = 0;
+	tp->cur_tx = tp->dirty_tx = 0;
 	memset(tp->TxDescArray, 0x0, NUM_TX_DESC * sizeof (struct TxDesc));
 	memset(tp->RxDescArray, 0x0, NUM_RX_DESC * sizeof (struct RxDesc));
 
-	for (i = 0; i < NUM_TX_DESC; i++) {
-		tp->Tx_skbuff[i] = NULL;
-	}
-	for (i = 0; i < NUM_RX_DESC; i++) {
-		if (i == (NUM_RX_DESC - 1))
-			tp->RxDescArray[i].status =
-			    (OWNbit | EORbit) + RX_BUF_SIZE;
-		else
-			tp->RxDescArray[i].status = OWNbit + RX_BUF_SIZE;
+	memset(tp->Tx_skbuff, 0x0, NUM_TX_DESC * sizeof(struct sk_buff *));
+	memset(tp->Rx_skbuff, 0x0, NUM_RX_DESC * sizeof(struct sk_buff *));
+
+	if (rtl8169_rx_fill(tp, dev, 0, NUM_RX_DESC) != NUM_RX_DESC)
+		goto err_out;
+
+	rtl8169_mark_as_last_descriptor(tp->RxDescArray + NUM_RX_DESC - 1);
 
-		tp->RxBufferRing[i] = &(tp->RxBufferRings[i * RX_BUF_SIZE]);
-		tp->RxDescArray[i].buf_addr = virt_to_bus(tp->RxBufferRing[i]);
-	}
 	return 0;
+
+err_out:
+	rtl8169_rx_clear(tp);
+	return -ENOMEM;
 }
 
 static void
@@ -906,70 +988,77 @@ rtl8169_tx_interrupt(struct net_device *
 	}
 }
 
+static inline void rtl8169_unmap_rx(struct pci_dev *pdev, struct RxDesc *desc)
+{
+	pci_dma_sync_single(pdev, le32_to_cpu(desc->buf_addr), RX_BUF_SIZE,
+			    PCI_DMA_FROMDEVICE);
+	pci_unmap_single(pdev, le32_to_cpu(desc->buf_addr), RX_BUF_SIZE,
+			 PCI_DMA_FROMDEVICE);
+}
+
 static void
 rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 		     void *ioaddr)
 {
-	int cur_rx;
-	struct sk_buff *skb;
-	int pkt_size = 0;
+	int cur_rx, delta;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
 	assert(ioaddr != NULL);
 
-	cur_rx = tp->cur_rx;
+	cur_rx = tp->cur_rx % RX_BUF_SIZE;
 
 	while ((tp->RxDescArray[cur_rx].status & OWNbit) == 0) {
+		u32 status = tp->RxDescArray[cur_rx].status;
 
-		if (tp->RxDescArray[cur_rx].status & RxRES) {
+		if (status & RxRES) {
 			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
 			tp->stats.rx_errors++;
-			if (tp->RxDescArray[cur_rx].status & (RxRWT | RxRUNT))
+			if (status & (RxRWT | RxRUNT))
 				tp->stats.rx_length_errors++;
-			if (tp->RxDescArray[cur_rx].status & RxCRC)
+			if (status & RxCRC)
 				tp->stats.rx_crc_errors++;
 		} else {
-			pkt_size =
-			    (int) (tp->RxDescArray[cur_rx].
-				   status & 0x00001FFF) - 4;
-			skb = dev_alloc_skb(pkt_size + 2);
-			if (skb != NULL) {
-				skb->dev = dev;
-				skb_reserve(skb, 2);	// 16 byte align the IP fields. //
-				eth_copy_and_sum(skb, tp->RxBufferRing[cur_rx],
-						 pkt_size, 0);
-				skb_put(skb, pkt_size);
-				skb->protocol = eth_type_trans(skb, dev);
-				netif_rx(skb);
-
-				if (cur_rx == (NUM_RX_DESC - 1))
-					tp->RxDescArray[cur_rx].status =
-					    (OWNbit | EORbit) + RX_BUF_SIZE;
-				else
-					tp->RxDescArray[cur_rx].status =
-					    OWNbit + RX_BUF_SIZE;
-
-				tp->RxDescArray[cur_rx].buf_addr =
-				    virt_to_bus(tp->RxBufferRing[cur_rx]);
-				dev->last_rx = jiffies;
-				tp->stats.rx_bytes += pkt_size;
-				tp->stats.rx_packets++;
-			} else {
-				printk(KERN_WARNING
-				       "%s: Memory squeeze, deferring packet.\n",
-				       dev->name);
-				/* We should check that some rx space is free.
-				   If not, free one and mark stats->rx_dropped++. */
-				tp->stats.rx_dropped++;
-			}
-		}
+			struct sk_buff *skb = tp->Rx_skbuff[cur_rx];
+			int pkt_size = (status & 0x00001FFF) - 4;
+
+			rtl8169_unmap_rx(tp->pci_dev, tp->RxDescArray + cur_rx);
+
+			skb_put(skb, pkt_size);
+			skb->protocol = eth_type_trans(skb, dev);
+			netif_rx(skb);
 
-		cur_rx = (cur_rx + 1) % NUM_RX_DESC;
+			tp->Rx_skbuff[cur_rx] = NULL;
 
+			dev->last_rx = jiffies;
+			tp->stats.rx_bytes += pkt_size;
+			tp->stats.rx_packets++;
+		}
+		
+		tp->cur_rx++; 
+		cur_rx = tp->cur_rx % NUM_RX_DESC;
 	}
 
-	tp->cur_rx = cur_rx;
+	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
+	if (delta > 0) {
+		u32 old_last = (tp->dirty_rx - 1) % NUM_RX_DESC;
+
+		tp->dirty_rx += delta;
+		rtl8169_mark_as_last_descriptor(tp->RxDescArray +
+						(tp->dirty_rx - 1)%NUM_RX_DESC);
+		rtl8169_unmark_as_last_descriptor(tp->RxDescArray + old_last);
+	} else if (delta < 0)
+		printk(KERN_INFO "%s: no Rx buffer allocated\n", dev->name);
+
+	/*
+	 * FIXME: until there is periodic timer to try and refill the ring,
+	 * a temporary shortage may definitely kill the Rx process.
+	 * - disable the asic to try and avoid an overflow and kick it again
+	 *   after refill ?
+	 * - how do others driver handle this condition (Uh oh...).
+	 */
+	if (tp->dirty_rx + NUM_RX_DESC == tp->cur_rx)
+		printk(KERN_EMERG "%s: Rx buffers exhausted\n", dev->name);
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up after the Tx thread. */
@@ -1032,7 +1121,6 @@ rtl8169_close(struct net_device *dev)
 	struct rtl8169_private *tp = dev->priv;
 	struct pci_dev *pdev = tp->pci_dev;
 	void *ioaddr = tp->mmio_addr;
-	int i;
 
 	netif_stop_queue(dev);
 
@@ -1054,16 +1142,15 @@ rtl8169_close(struct net_device *dev)
 	free_irq(dev->irq, dev);
 
 	rtl8169_tx_clear(tp);
+
+	rtl8169_rx_clear(tp);
+
 	pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			    tp->RxPhyAddr);
 	pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDescArray,
 			    tp->TxPhyAddr);
 	tp->TxDescArray = NULL;
 	tp->RxDescArray = NULL;
-	kfree(tp->RxBufferRings);
-	for (i = 0; i < NUM_RX_DESC; i++) {
-		tp->RxBufferRing[i] = NULL;
-	}
 
 	return 0;
 }

_

--n8g4imXOkfNTN/H1--
