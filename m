From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 7/8]  2.6.5-rc2 - sis190 update
Date: Sat, 27 Mar 2004 03:16:08 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040327031608.G31053@electric-eye.fr.zoreil.com>
References: <20040327030853.A30849@electric-eye.fr.zoreil.com> <20040327031131.A31053@electric-eye.fr.zoreil.com> <20040327031219.B31053@electric-eye.fr.zoreil.com> <20040327031302.C31053@electric-eye.fr.zoreil.com> <20040327031351.D31053@electric-eye.fr.zoreil.com> <20040327031443.E31053@electric-eye.fr.zoreil.com> <20040327031526.F31053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040327031526.F31053@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Mar 27, 2004 at 03:15:26AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace the giant receive buffer with individually allocated skb.


 drivers/net/sis190.c |   86 +++++++++++++++++++++++++++++++++++----------------
 1 files changed, 60 insertions(+), 26 deletions(-)

diff -puN drivers/net/sis190.c~sis190-dma-api-rx-buffers-30 drivers/net/sis190.c
--- linux-2.6.5-rc2/drivers/net/sis190.c~sis190-dma-api-rx-buffers-30	2004-03-27 02:37:47.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/sis190.c	2004-03-27 02:37:47.000000000 +0100
@@ -290,6 +290,9 @@ enum _DescStatusBit {
 	ENDbit			= 0x80000000,
 };
 
+/* FIXME: datasheet, anyone ? */
+#define RsvdMask		0x00000000
+
 struct TxDesc {
 	u32 PSize;
 	u32 status;
@@ -318,9 +321,8 @@ struct sis190_private {
 	dma_addr_t rx_dma;
 	struct TxDesc *TxDescArray;	/* Index of 256-alignment Tx Descriptor buffer */
 	struct RxDesc *RxDescArray;	/* Index of 256-alignment Rx Descriptor buffer */
-	unsigned char *RxBufferRings;	/* Index of Rx Buffer  */
-	unsigned char *RxBufferRing[NUM_RX_DESC];	/* Index of Rx Buffer array */
-	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Index of Transmit data buffer */
+	struct sk_buff *Rx_skbuff[NUM_TX_DESC];	/* Rx data buffer */
+	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Tx data buffer */
 };
 
 MODULE_AUTHOR("K.M. Liu <kmliu@sis.com>");
@@ -812,6 +814,22 @@ static inline void sis190_mark_as_last_d
 	desc->buf_Len |= cpu_to_le32(ENDbit);
 }
 
+static inline void sis190_make_unusable_by_asic(struct RxDesc *desc)
+{
+	desc->buf_addr = 0xdeadbeef;
+	desc->status &= ~cpu_to_le32(OWNbit | RsvdMask);
+}
+
+static void sis190_free_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
+			       struct RxDesc *desc)
+{
+	pci_unmap_single(pdev, le32_to_cpu(desc->buf_addr), RX_BUF_SIZE,
+			 PCI_DMA_FROMDEVICE);
+	dev_kfree_skb(*sk_buff);
+	*sk_buff = NULL;
+	sis190_make_unusable_by_asic(desc);
+}
+
 static inline void sis190_give_to_asic(struct RxDesc *desc, dma_addr_t mapping)
 {
 	desc->buf_addr = cpu_to_le32(mapping);
@@ -819,19 +837,47 @@ static inline void sis190_give_to_asic(s
 }
 
 static int sis190_alloc_rx_skb(struct pci_dev *pdev, struct net_device *dev,
-			       char *tail, struct RxDesc *desc)
+			       struct sk_buff **sk_buff, struct RxDesc *desc)
 {
+	struct sk_buff *skb;
 	dma_addr_t mapping;
 	int ret = 0;
 
-	mapping = pci_map_single(pdev, tail, RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+	skb = dev_alloc_skb(RX_BUF_SIZE + 2);
+	if (!skb)
+		goto err_out;
+
+	skb->dev = dev;
+	skb_reserve(skb, 2);
+	*sk_buff = skb;
+
+	mapping = pci_map_single(pdev, skb->tail, RX_BUF_SIZE,
+				 PCI_DMA_FROMDEVICE);
 
 	desc->PSize = 0x0;
 	desc->buf_Len |= cpu_to_le32(RX_BUF_SIZE);
 
 	sis190_give_to_asic(desc, mapping);
 
+out:
 	return ret;
+
+err_out:
+	ret = -ENOMEM;
+	sis190_make_unusable_by_asic(desc);
+	goto out;
+}
+
+static void sis190_rx_clear(struct sis190_private *tp)
+{
+	int i;
+
+	for (i = 0; i < NUM_RX_DESC; i++) {
+		if (tp->Rx_skbuff[i]) {
+			sis190_free_rx_skb(tp->pci_dev, tp->Rx_skbuff + i,
+					   tp->RxDescArray + i);
+		}
+	}
 }
 
 static u32 sis190_rx_fill(struct sis190_private *tp, struct net_device *dev,
@@ -842,8 +888,10 @@ static u32 sis190_rx_fill(struct sis190_
 	for (cur = start; end - cur > 0; cur++) {
 		int ret, i = cur % NUM_RX_DESC;
 
-		ret = sis190_alloc_rx_skb(tp->pci_dev, dev,
-					  tp->RxBufferRings + i * RX_BUF_SIZE,
+		if (tp->Rx_skbuff[i])
+			continue;
+
+		ret = sis190_alloc_rx_skb(tp->pci_dev, dev, tp->Rx_skbuff + i,
 					  tp->RxDescArray + i);
 		if (ret < 0)
 			break;
@@ -861,24 +909,17 @@ static int SiS190_init_ring(struct net_d
 	memset(tp->RxDescArray, 0x0, NUM_RX_DESC * sizeof (struct RxDesc));
 
 	memset(tp->Tx_skbuff, 0x0, NUM_TX_DESC * sizeof(struct sk_buff *));
-
-	tp->RxBufferRings = kmalloc(RX_BUF_SIZE * NUM_RX_DESC, GFP_KERNEL);
-	if (tp->RxBufferRings == NULL) {
-		printk(KERN_INFO "%s: allocate RxBufferRing failed\n",
-			dev->name);
-		goto err_out;
-	}
+	memset(tp->Rx_skbuff, 0x0, NUM_RX_DESC * sizeof(struct sk_buff *));
 
 	if (sis190_rx_fill(tp, dev, 0, NUM_RX_DESC) != NUM_RX_DESC)
-		goto err_out_free;
+		goto err_out;
 
 	sis190_mark_as_last_descriptor(tp->RxDescArray + NUM_RX_DESC - 1);
 
 	return 0;
 
-err_out_free:
-	kfree(tp->RxBufferRings);
 err_out:
+	sis190_rx_clear(tp);
 	return -ENOMEM;
 }
 
@@ -1065,7 +1106,7 @@ SiS190_rx_interrupt(struct net_device *d
 				pci_dma_sync_single_for_cpu(tp->pci_dev,
 					le32_to_cpu(desc->buf_addr),
 					RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-				eth_copy_and_sum(skb, tp->RxBufferRing[cur_rx],
+				eth_copy_and_sum(skb, tp->Rx_skbuff[cur_rx]->tail,
 						 pkt_size, 0);
 				pci_dma_sync_single_for_device(tp->pci_dev,
 					le32_to_cpu(desc->buf_addr),
@@ -1150,7 +1191,6 @@ SiS190_close(struct net_device *dev)
 {
 	struct sis190_private *tp = dev->priv;
 	void *ioaddr = tp->mmio_addr;
-	int i;
 
 	netif_stop_queue(dev);
 
@@ -1173,19 +1213,13 @@ SiS190_close(struct net_device *dev)
 	free_irq(dev->irq, dev);
 
 	SiS190_tx_clear(tp);
+	sis190_rx_clear(tp);
 	pci_free_consistent(tp->pci_dev, TX_DESC_TOTAL_SIZE, tp->TxDescArray,
 		tp->tx_dma);
 	pci_free_consistent(tp->pci_dev, RX_DESC_TOTAL_SIZE, tp->RxDescArray,
 		tp->rx_dma);
 	tp->TxDescArray = NULL;
-	for (i = 0; i < NUM_RX_DESC; i++) {
-		pci_unmap_single(tp->pci_dev,
-			le32_to_cpu(tp->RxDescArray[i].buf_addr), RX_BUF_SIZE,
-			PCI_DMA_FROMDEVICE);
-		tp->RxBufferRing[i] = NULL;
-	}
 	tp->RxDescArray = NULL;
-	kfree(tp->RxBufferRings);
 
 	return 0;
 }

_
