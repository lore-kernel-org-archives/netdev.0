From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] 2.6.0-test4 - more sis190 nit I/II
Date: Wed, 27 Aug 2003 00:07:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827000736.A23532@electric-eye.fr.zoreil.com>
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
[....]
> <romieu@fr.zoreil.com> (03/08/26 1.1293)
>    [netdrvr sis190] pass irq argument to synchronize_irq()
>    
>    Looks like this driver wasn't tested on SMP :)

The following patch should apply on top of this. Compiled, untested.


Driver does not need to enforce 256 byte alignment for data returned
from pci_alloc_consistent().
- {rx/tx}_dma_aligned and {rx/td}_dma_raw are both replaced by {rx/tx}_dma;
- {rx/tx}_desc_raw is replaced by direct use of {Rx/Tx}DescArray;
- SiS190_open()
  + fixup for a lack of kmalloc() failure handling;
  + (return status) there is no need for both retval/rc: merge them;
  + anonymous printk() fixup: the name of the guilty device is printed;
- define {RX/TX}_DESC_TOTAL_SIZE because I am too lazy to read twice the
  same lengthy arithmetic expression.


 drivers/net/sis190.c |   78 ++++++++++++++++++++++-----------------------------
 1 files changed, 35 insertions(+), 43 deletions(-)

diff -puN drivers/net/sis190.c~redundant-alignment-sis190 drivers/net/sis190.c
--- linux-2.6.0-test4/drivers/net/sis190.c~redundant-alignment-sis190	Tue Aug 26 21:55:14 2003
+++ linux-2.6.0-test4-fr/drivers/net/sis190.c	Tue Aug 26 22:22:09 2003
@@ -76,6 +76,8 @@ static int multicast_filter_limit = 32;
 
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
 #define NUM_RX_DESC	64	/* Number of Rx descriptor registers */
+#define TX_DESC_TOTAL_SIZE	((NUM_TX_DESC * sizeof (struct TxDesc)) + 256)
+#define RX_DESC_TOTAL_SIZE	((NUM_RX_DESC * sizeof (struct RxDesc)) + 256)
 #define RX_BUF_SIZE	1536	/* Rx Buffer size */
 
 #define SiS190_MIN_IO_SIZE 0x80
@@ -311,12 +313,8 @@ struct sis190_private {
 	unsigned long cur_rx;	/* Index into the Rx descriptor buffer of next Rx pkt. */
 	unsigned long cur_tx;	/* Index into the Tx descriptor buffer of next Rx pkt. */
 	unsigned long dirty_tx;
-	void *tx_desc_raw;		/* Tx descriptor buffer */
-	dma_addr_t tx_dma_raw;
-	dma_addr_t tx_dma_aligned;
-	void *rx_desc_raw;		/* Rx descriptor buffer */
-	dma_addr_t rx_dma_raw;
-	dma_addr_t rx_dma_aligned;
+	dma_addr_t tx_dma;
+	dma_addr_t rx_dma;
 	struct TxDesc *TxDescArray;	/* Index of 256-alignment Tx Descriptor buffer */
 	struct RxDesc *RxDescArray;	/* Index of 256-alignment Rx Descriptor buffer */
 	unsigned char *RxBufferRings;	/* Index of Rx Buffer  */
@@ -714,54 +712,50 @@ static int
 SiS190_open(struct net_device *dev)
 {
 	struct sis190_private *tp = dev->priv;
-	int retval;
-	u8 diff;
 	int rc;
 
-	retval =
-	    request_irq(dev->irq, SiS190_interrupt, SA_SHIRQ, dev->name, dev);
-	if (retval) {
-		return retval;
-	}
+	rc = request_irq(dev->irq, SiS190_interrupt, SA_SHIRQ, dev->name, dev);
+	if (rc)
+		goto out;
 
-	tp->tx_desc_raw = pci_alloc_consistent(tp->pci_dev,
-		(NUM_TX_DESC * sizeof (struct TxDesc)) + 256,
-		&tp->tx_dma_raw);
-	if (!tp->tx_desc_raw) {
+	/*
+	 * Rx and Tx descriptors need 256 bytes alignment.
+	 * pci_alloc_consistent() guarantees a stronger alignment.
+	 */
+	tp->TxDescArray = pci_alloc_consistent(tp->pci_dev, TX_DESC_TOTAL_SIZE,
+		&tp->tx_dma);
+	if (!tp->TxDescArray) {
 		rc = -ENOMEM;
 		goto err_out;
 	}
-	// Tx Desscriptor needs 256 bytes alignment;
-	diff = 256 - (tp->tx_dma_raw - ((tp->tx_dma_raw >> 8) << 8));
-	tp->tx_dma_aligned = tp->tx_dma_raw + diff;
-	tp->TxDescArray = (struct TxDesc *) (tp->tx_desc_raw + diff);
-
-	tp->rx_desc_raw = pci_alloc_consistent(tp->pci_dev,
-		(NUM_RX_DESC * sizeof (struct RxDesc)) + 256,
-		&tp->rx_dma_raw);
-	if (!tp->rx_desc_raw) {
+
+	tp->RxDescArray = pci_alloc_consistent(tp->pci_dev, RX_DESC_TOTAL_SIZE,
+		&tp->rx_dma);
+	if (!tp->RxDescArray) {
 		rc = -ENOMEM;
 		goto err_out_free_tx;
 	}
-	// Rx Desscriptor needs 256 bytes alignment;
-	diff = 256 - (tp->rx_dma_raw - ((tp->rx_dma_raw >> 8) << 8));
-	tp->rx_dma_aligned = tp->rx_dma_raw + diff;
-	tp->RxDescArray = (struct RxDesc *) (tp->rx_desc_raw + diff);
 
 	tp->RxBufferRings = kmalloc(RX_BUF_SIZE * NUM_RX_DESC, GFP_KERNEL);
 	if (tp->RxBufferRings == NULL) {
-		printk(KERN_INFO "Allocate RxBufferRing failed\n");
+		printk(KERN_INFO "%s: allocate RxBufferRing failed\n",
+			dev->name);
+		rc = -ENOMEM;
+		goto err_out_free_rx;
 	}
 
 	SiS190_init_ring(dev);
 	SiS190_hw_start(dev);
 
-	return 0;
+out:
+	return rc;
 
+err_out_free_rx:
+	pci_free_consistent(tp->pci_dev, RX_DESC_TOTAL_SIZE, tp->RxDescArray,
+		tp->rx_dma);
 err_out_free_tx:
-	pci_free_consistent(tp->pci_dev,
-		(NUM_TX_DESC * sizeof (struct TxDesc)) + 256,
-		tp->tx_desc_raw, tp->tx_dma_raw);
+	pci_free_consistent(tp->pci_dev, TX_DESC_TOTAL_SIZE, tp->TxDescArray,
+		tp->tx_dma);
 err_out:
 	free_irq(dev->irq, dev);
 	return rc;
@@ -780,10 +774,10 @@ SiS190_hw_start(struct net_device *dev)
 	SiS_W32(IntrControl, 0x0);
 
 	SiS_W32(0x0, 0x01a00);
-	SiS_W32(0x4, tp->tx_dma_aligned);
+	SiS_W32(0x4, tp->tx_dma);
 
 	SiS_W32(0x10, 0x1a00);
-	SiS_W32(0x14, tp->rx_dma_aligned);
+	SiS_W32(0x14, tp->rx_dma);
 
 	SiS_W32(0x20, 0xffffffff);
 	SiS_W32(0x24, 0x0);
@@ -1115,12 +1109,10 @@ SiS190_close(struct net_device *dev)
 	free_irq(dev->irq, dev);
 
 	SiS190_tx_clear(tp);
-	pci_free_consistent(tp->pci_dev,
-		(NUM_TX_DESC * sizeof (struct TxDesc)) + 256,
-		tp->tx_desc_raw, tp->tx_dma_raw);
-	pci_free_consistent(tp->pci_dev,
-		(NUM_RX_DESC * sizeof (struct RxDesc)) + 256,
-		tp->rx_desc_raw, tp->rx_dma_raw);
+	pci_free_consistent(tp->pci_dev, TX_DESC_TOTAL_SIZE, tp->TxDescArray,
+		tp->tx_dma);
+	pci_free_consistent(tp->pci_dev, RX_DESC_TOTAL_SIZE, tp->RxDescArray,
+		tp->rx_dma);
 	tp->TxDescArray = NULL;
 	tp->RxDescArray = NULL;
 	kfree(tp->RxBufferRings);

_
