From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/8]  2.6.5-rc2 - sis190 update
Date: Sat, 27 Mar 2004 03:11:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040327031131.A31053@electric-eye.fr.zoreil.com>
References: <20040327030853.A30849@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040327030853.A30849@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Mar 27, 2004 at 03:08:54AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Endianness issues.
Use of le32_to_cpu/cpu_to_le32 in the code which handles the different
components of the Rx descriptors (PSize/status/buf_addr/buf_Len).


 drivers/net/sis190.c |   45 +++++++++++++++++++++------------------------
 1 files changed, 21 insertions(+), 24 deletions(-)

diff -puN drivers/net/sis190.c~sis190-rx-path-le32_to_cpu drivers/net/sis190.c
--- linux-2.6.5-rc2/drivers/net/sis190.c~sis190-rx-path-le32_to_cpu	2004-03-26 23:12:05.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/sis190.c	2004-03-26 23:13:10.000000000 +0100
@@ -824,18 +824,19 @@ SiS190_init_ring(struct net_device *dev)
 	}
 	for (i = 0; i < NUM_RX_DESC; i++) {
 		struct RxDesc *desc = tp->RxDescArray + i;
+		dma_addr_t mapping;
+		u32 len;
 
 		desc->PSize = 0x0;
 
-		if (i == (NUM_RX_DESC - 1))
-			desc->buf_Len = BIT_31 + RX_BUF_SIZE;	//bit 31 is End bit
-		else
-			desc->buf_Len = RX_BUF_SIZE;
+		len = RX_BUF_SIZE + ENDbit * !((i + 1) % NUM_RX_DESC);
 
 		tp->RxBufferRing[i] = tp->RxBufferRings + i * RX_BUF_SIZE;
-		desc->buf_addr = pci_map_single(tp->pci_dev,
+		mapping = pci_map_single(tp->pci_dev,
 			tp->RxBufferRing[i], RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-		desc->status = OWNbit | INTbit;
+		desc->buf_addr = cpu_to_le32(mapping);
+		desc->buf_Len = cpu_to_le32(len);
+		desc->status = cpu_to_le32(OWNbit | INTbit);
 	}
 
 }
@@ -1001,13 +1002,13 @@ SiS190_rx_interrupt(struct net_device *d
 	assert(tp != NULL);
 	assert(ioaddr != NULL);
 
-	while ((desc->status & OWNbit) == 0) {
+	while ((le32_to_cpu(desc->status) & OWNbit) == 0) {
 
-		if (desc->PSize & 0x0080000) {
+		if (cpu_to_le32(desc->PSize) & RxCRC) {
 			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
 			tp->stats.rx_errors++;
 			tp->stats.rx_length_errors++;
-		} else if (!(desc->PSize & 0x0010000)) {
+		} else if (!(cpu_to_le32(desc->PSize) & 0x0010000)) {
 			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
 			tp->stats.rx_errors++;
 			tp->stats.rx_crc_errors++;
@@ -1015,37 +1016,32 @@ SiS190_rx_interrupt(struct net_device *d
 			struct sk_buff *skb;
 			int pkt_size;
 
-			pkt_size = (int) (desc->PSize & 0x0000FFFF) - 4;
+			pkt_size = (cpu_to_le32(desc->PSize) & 0x0000FFFF) - 4;
 			skb = dev_alloc_skb(pkt_size + 2);
 			if (skb != NULL) {
 				skb->dev = dev;
 				skb_reserve(skb, 2);	// 16 byte align the IP fields. //
 				pci_dma_sync_single_for_cpu(tp->pci_dev,
-							    desc->buf_addr,
-							    RX_BUF_SIZE,
-							    PCI_DMA_FROMDEVICE);
+					le32_to_cpu(desc->buf_addr),
+					RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 				eth_copy_and_sum(skb, tp->RxBufferRing[cur_rx],
 						 pkt_size, 0);
 				pci_dma_sync_single_for_device(tp->pci_dev,
-							    desc->buf_addr,
-							    RX_BUF_SIZE,
-							    PCI_DMA_FROMDEVICE);
+					le32_to_cpu(desc->buf_addr),
+					RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 				skb_put(skb, pkt_size);
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
 
 				desc->PSize = 0x0;
 
-				if (cur_rx == (NUM_RX_DESC - 1))
-					desc->buf_Len = ENDbit + RX_BUF_SIZE;
-				else
-					desc->buf_Len = RX_BUF_SIZE;
-
+				desc->buf_Len = cpu_to_le32(RX_BUF_SIZE +
+					ENDbit * !((cur_rx + 1) % NUM_RX_DESC));
 				dev->last_rx = jiffies;
 				tp->stats.rx_bytes += pkt_size;
 				tp->stats.rx_packets++;
 
-				desc->status = OWNbit | INTbit;
+				desc->status = cpu_to_le32(OWNbit | INTbit);
 			} else {
 				printk(KERN_WARNING
 				       "%s: Memory squeeze, deferring packet.\n",
@@ -1142,8 +1138,9 @@ SiS190_close(struct net_device *dev)
 		tp->rx_dma);
 	tp->TxDescArray = NULL;
 	for (i = 0; i < NUM_RX_DESC; i++) {
-		pci_unmap_single(tp->pci_dev, tp->RxDescArray[i].buf_addr,
-			RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+		pci_unmap_single(tp->pci_dev,
+			le32_to_cpu(tp->RxDescArray[i].buf_addr), RX_BUF_SIZE,
+			PCI_DMA_FROMDEVICE);
 		tp->RxBufferRing[i] = NULL;
 	}
 	tp->RxDescArray = NULL;

_
