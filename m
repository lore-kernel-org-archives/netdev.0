From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/8]  2.6.5-rc2 - sis190 update
Date: Sat, 27 Mar 2004 03:13:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040327031302.C31053@electric-eye.fr.zoreil.com>
References: <20040327030853.A30849@electric-eye.fr.zoreil.com> <20040327031131.A31053@electric-eye.fr.zoreil.com> <20040327031219.B31053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040327031219.B31053@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Mar 27, 2004 at 03:12:19AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

- make sis190_open() look like r8169_open() as they do the same thing;
- ready sis190_init_ring for incoming DMA api changes;
- trade a "for" loop against a single line, idiomatic, memset().


 drivers/net/sis190.c |   57 +++++++++++++++++++++++++--------------------------
 1 files changed, 29 insertions(+), 28 deletions(-)

diff -puN drivers/net/sis190.c~sis190-rework-open drivers/net/sis190.c
--- linux-2.6.5-rc2/drivers/net/sis190.c~sis190-rework-open	2004-03-26 23:29:27.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/sis190.c	2004-03-26 23:47:11.000000000 +0100
@@ -331,7 +331,7 @@ static int SiS190_open(struct net_device
 static int SiS190_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t SiS190_interrupt(int irq, void *dev_instance,
 				    struct pt_regs *regs);
-static void SiS190_init_ring(struct net_device *dev);
+static int SiS190_init_ring(struct net_device *dev);
 static void SiS190_hw_start(struct net_device *dev);
 static int SiS190_close(struct net_device *dev);
 static void SiS190_set_rx_mode(struct net_device *dev);
@@ -720,50 +720,43 @@ SiS190_open(struct net_device *dev)
 	int rc;
 
 	rc = request_irq(dev->irq, SiS190_interrupt, SA_SHIRQ, dev->name, dev);
-	if (rc)
+	if (rc < 0)
 		goto out;
 
+	rc = -ENOMEM;
+
 	/*
 	 * Rx and Tx descriptors need 256 bytes alignment.
 	 * pci_alloc_consistent() guarantees a stronger alignment.
 	 */
 	tp->TxDescArray = pci_alloc_consistent(tp->pci_dev, TX_DESC_TOTAL_SIZE,
 		&tp->tx_dma);
-	if (!tp->TxDescArray) {
-		rc = -ENOMEM;
-		goto err_out;
-	}
+	if (!tp->TxDescArray)
+		goto err_free_irq;
 
 	tp->RxDescArray = pci_alloc_consistent(tp->pci_dev, RX_DESC_TOTAL_SIZE,
 		&tp->rx_dma);
-	if (!tp->RxDescArray) {
-		rc = -ENOMEM;
-		goto err_out_free_tx;
-	}
+	if (!tp->RxDescArray)
+		goto err_free_tx;
 
-	tp->RxBufferRings = kmalloc(RX_BUF_SIZE * NUM_RX_DESC, GFP_KERNEL);
-	if (tp->RxBufferRings == NULL) {
-		printk(KERN_INFO "%s: allocate RxBufferRing failed\n",
-			dev->name);
-		rc = -ENOMEM;
-		goto err_out_free_rx;
-	}
+	rc = SiS190_init_ring(dev);
+	if (rc < 0)
+		goto err_free_rx;
 
-	SiS190_init_ring(dev);
 	SiS190_hw_start(dev);
 
 out:
 	return rc;
 
-err_out_free_rx:
+err_free_rx:
 	pci_free_consistent(tp->pci_dev, RX_DESC_TOTAL_SIZE, tp->RxDescArray,
 		tp->rx_dma);
-err_out_free_tx:
+err_free_tx:
 	pci_free_consistent(tp->pci_dev, TX_DESC_TOTAL_SIZE, tp->TxDescArray,
 		tp->tx_dma);
-err_out:
+err_free_irq:
 	free_irq(dev->irq, dev);
-	return rc;
+	goto out;
 }
 
 static void
@@ -813,21 +806,25 @@ SiS190_hw_start(struct net_device *dev)
 
 }
 
-static void
-SiS190_init_ring(struct net_device *dev)
+static int SiS190_init_ring(struct net_device *dev)
 {
 	struct sis190_private *tp = dev->priv;
 	int i;
 
 	tp->cur_rx = 0;
-	tp->cur_tx = 0;
-	tp->dirty_tx = 0;
+	tp->cur_tx = tp->dirty_tx = 0;
 	memset(tp->TxDescArray, 0x0, NUM_TX_DESC * sizeof (struct TxDesc));
 	memset(tp->RxDescArray, 0x0, NUM_RX_DESC * sizeof (struct RxDesc));
 
-	for (i = 0; i < NUM_TX_DESC; i++) {
-		tp->Tx_skbuff[i] = NULL;
+	memset(tp->Tx_skbuff, 0x0, NUM_TX_DESC * sizeof(struct sk_buff *));
+
+	tp->RxBufferRings = kmalloc(RX_BUF_SIZE * NUM_RX_DESC, GFP_KERNEL);
+	if (tp->RxBufferRings == NULL) {
+		printk(KERN_INFO "%s: allocate RxBufferRing failed\n",
+			dev->name);
+		goto err_out;
 	}
+
 	for (i = 0; i < NUM_RX_DESC; i++) {
 		struct RxDesc *desc = tp->RxDescArray + i;
 		dma_addr_t mapping;
@@ -845,6 +842,10 @@ SiS190_init_ring(struct net_device *dev)
 		desc->status = cpu_to_le32(OWNbit | INTbit);
 	}
 
+	return 0;
+
+err_out:
+	return -ENOMEM;
 }
 
 static void

_
