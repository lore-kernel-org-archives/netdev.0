From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 8/8]  2.6.5-rc2 - sis190 update
Date: Sat, 27 Mar 2004 03:17:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040327031705.H31053@electric-eye.fr.zoreil.com>
References: <20040327030853.A30849@electric-eye.fr.zoreil.com> <20040327031131.A31053@electric-eye.fr.zoreil.com> <20040327031219.B31053@electric-eye.fr.zoreil.com> <20040327031302.C31053@electric-eye.fr.zoreil.com> <20040327031351.D31053@electric-eye.fr.zoreil.com> <20040327031443.E31053@electric-eye.fr.zoreil.com> <20040327031526.F31053@electric-eye.fr.zoreil.com> <20040327031608.G31053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040327031608.G31053@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Mar 27, 2004 at 03:16:08AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


- sis190_rx_interrupt converted to classical Rx skb handling;
- rx_copybreak *new.

Some similarity with the r8169 driver can not be excluded.


 drivers/net/sis190.c |  116 ++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 78 insertions(+), 38 deletions(-)

diff -puN drivers/net/sis190.c~sis190-dma-api-rx-buffers-40 drivers/net/sis190.c
--- linux-2.6.5-rc2/drivers/net/sis190.c~sis190-dma-api-rx-buffers-40	2004-03-27 02:38:14.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/sis190.c	2004-03-27 02:42:39.000000000 +0100
@@ -149,6 +149,8 @@ static struct pci_device_id sis190_pci_t
 
 MODULE_DEVICE_TABLE(pci, sis190_pci_tbl);
 
+static int rx_copybreak = 200;
+
 enum SiS190_registers {
 	TxControl		= 0x0,
 	TxDescStartAddr		= 0x4,
@@ -329,6 +331,7 @@ MODULE_AUTHOR("K.M. Liu <kmliu@sis.com>"
 MODULE_DESCRIPTION("SiS SiS190 Gigabit Ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_PARM(media, "1-" __MODULE_STRING(MAX_UNITS) "i");
+MODULE_PARM(rx_copybreak, "i");
 
 static int SiS190_open(struct net_device *dev);
 static int SiS190_start_xmit(struct sk_buff *skb, struct net_device *dev);
@@ -830,6 +833,13 @@ static void sis190_free_rx_skb(struct pc
 	sis190_make_unusable_by_asic(desc);
 }
 
+
+static inline void sis190_return_to_asic(struct RxDesc *desc)
+{
+	desc->PSize = 0x0;
+	desc->status |= cpu_to_le32(OWNbit | INTbit);
+}
+
 static inline void sis190_give_to_asic(struct RxDesc *desc, dma_addr_t mapping)
 {
 	desc->buf_addr = cpu_to_le32(mapping);
@@ -1073,18 +1083,49 @@ SiS190_tx_interrupt(struct net_device *d
 	}
 }
 
+static inline int sis190_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
+				     struct RxDesc *desc,
+				     struct net_device *dev)
+{
+	int ret = -1;
+
+	if (pkt_size < rx_copybreak) {
+		struct sk_buff *skb;
+
+		skb = dev_alloc_skb(pkt_size + 2);
+		if (skb) {
+			skb->dev = dev;
+			skb_reserve(skb, 2);
+			eth_copy_and_sum(skb, sk_buff[0]->tail, pkt_size, 0);
+			*sk_buff = skb;
+			sis190_return_to_asic(desc);
+			ret = 0;
+		}
+	}
+	return ret;
+}
+
 static void
 SiS190_rx_interrupt(struct net_device *dev, struct sis190_private *tp,
 		    void *ioaddr)
 {
-	int cur_rx = tp->cur_rx;
-	struct RxDesc *desc = tp->RxDescArray + cur_rx;
+	unsigned long cur_rx, rx_left;
+	int delta;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
 	assert(ioaddr != NULL);
 
-	while ((le32_to_cpu(desc->status) & OWNbit) == 0) {
+	cur_rx = tp->cur_rx;
+	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
+
+	while (rx_left > 0) {
+		int entry = cur_rx % NUM_RX_DESC;
+		struct RxDesc *desc = tp->RxDescArray + entry;
+		u32 status = le32_to_cpu(desc->status);
+		
+		if (status & OWNbit)
+			break;
 
 		if (cpu_to_le32(desc->PSize) & RxCRC) {
 			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
@@ -1095,43 +1136,33 @@ SiS190_rx_interrupt(struct net_device *d
 			tp->stats.rx_errors++;
 			tp->stats.rx_crc_errors++;
 		} else {
-			struct sk_buff *skb;
-			int pkt_size;
+			struct sk_buff *skb = tp->Rx_skbuff[entry];
+			void (*dma_op)(struct pci_dev *, dma_addr_t, size_t,
+				       int);
+			int pkt_size; 
 
 			pkt_size = (cpu_to_le32(desc->PSize) & 0x0000FFFF) - 4;
-			skb = dev_alloc_skb(pkt_size + 2);
-			if (skb != NULL) {
-				skb->dev = dev;
-				skb_reserve(skb, 2);	// 16 byte align the IP fields. //
-				pci_dma_sync_single_for_cpu(tp->pci_dev,
-					le32_to_cpu(desc->buf_addr),
-					RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-				eth_copy_and_sum(skb, tp->Rx_skbuff[cur_rx]->tail,
-						 pkt_size, 0);
-				pci_dma_sync_single_for_device(tp->pci_dev,
-					le32_to_cpu(desc->buf_addr),
-					RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-				skb_put(skb, pkt_size);
-				skb->protocol = eth_type_trans(skb, dev);
-				netif_rx(skb);
-
-				desc->PSize = 0x0;
-
-				desc->buf_Len = cpu_to_le32(RX_BUF_SIZE +
-					ENDbit * !((cur_rx + 1) % NUM_RX_DESC));
-				dev->last_rx = jiffies;
-				tp->stats.rx_bytes += pkt_size;
-				tp->stats.rx_packets++;
-
-				desc->status = cpu_to_le32(OWNbit | INTbit);
-			} else {
-				printk(KERN_WARNING
-				       "%s: Memory squeeze, deferring packet.\n",
-				       dev->name);
-				/* We should check that some rx space is free.
-				   If not, free one and mark stats->rx_dropped++. */
-				tp->stats.rx_dropped++;
-			}
+
+			dma_op = pci_dma_sync_single_for_cpu;
+			dma_op(tp->pci_dev, le32_to_cpu(desc->buf_addr),
+			       RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+
+			if (sis190_try_rx_copy(&skb, pkt_size, desc, dev) < 0) {
+				tp->Rx_skbuff[entry] = NULL;
+				dma_op = pci_unmap_single;
+			} else
+				dma_op = pci_dma_sync_single_for_device;
+
+			dma_op(tp->pci_dev, le32_to_cpu(desc->buf_addr),
+			       RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+
+			skb_put(skb, pkt_size);
+			skb->protocol = eth_type_trans(skb, dev);
+			netif_rx(skb);
+
+			dev->last_rx = jiffies;
+			tp->stats.rx_bytes += pkt_size;
+			tp->stats.rx_packets++;
 		}
 
 		cur_rx = (cur_rx + 1) % NUM_RX_DESC;
@@ -1139,6 +1170,15 @@ SiS190_rx_interrupt(struct net_device *d
 	}
 
 	tp->cur_rx = cur_rx;
+
+	delta = sis190_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
+	if (delta > 0)
+		tp->dirty_rx += delta;
+	else if (delta < 0)
+		printk(KERN_INFO "%s: no Rx buffer allocated\n", dev->name);
+
+	if (tp->dirty_rx + NUM_RX_DESC == tp->cur_rx)
+		printk(KERN_EMERG "%s: Rx buffers exhausted\n", dev->name);
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up after the Tx thread. */

_
