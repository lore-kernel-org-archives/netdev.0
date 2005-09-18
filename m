From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 2/2] forcedeth: scatter gather and segmentation offload support
Date: Sun, 18 Sep 2005 16:01:56 +0200
Message-ID: <432D7354.8000503@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030405010209050508090501"
Cc: Netdev <netdev@oss.sgi.com>, Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030405010209050508090501
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The attached patch adds scatter gather and segmentation offload support
into forcedeth driver.

This patch has been tested by NVIDIA and reviewed by Manfred.

Notes:
- Manfred mentioned that mapping of pages could take time and should not
be under spinlock for performance reasons
- During testing with netperf, I have noticed a connection running
segmentation offload gets "unoffloaded" by the kernel due to possible
retransmissions.

Thanks,
Ayaz

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
Signed-off-By: Manfred Spraul <manfred@colorfullife.com>


--------------030405010209050508090501
Content-Type: text/plain;
 name="patch-forcedeth-044-sg-segmentation"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-044-sg-segmentation"

--- orig-2.6/drivers/net/forcedeth.c	2005-09-06 11:54:41.000000000 -0700
+++ 2.6/drivers/net/forcedeth.c	2005-09-06 13:52:50.000000000 -0700
@@ -96,6 +96,7 @@
  *	0.42: 06 Aug 2005: Fix lack of link speed initialization
  *			   in the second (and later) nv_open call
  *      0.43: 10 Aug 2005: Add support for tx checksum.
+ *      0.44: 20 Aug 2005: Add support for scatter gather and segmentation.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -107,7 +108,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.43"
+#define FORCEDETH_VERSION		"0.44"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -340,6 +341,8 @@
 /* error and valid are the same for both */
 #define NV_TX2_ERROR		(1<<30)
 #define NV_TX2_VALID		(1<<31)
+#define NV_TX2_TSO		(1<<28)
+#define NV_TX2_TSO_SHIFT	14
 #define NV_TX2_CHECKSUM_L3	(1<<27)
 #define NV_TX2_CHECKSUM_L4	(1<<26)
 
@@ -901,11 +904,13 @@
 	int i;
 
 	np->next_tx = np->nic_tx = 0;
-	for (i = 0; i < TX_RING; i++)
+	for (i = 0; i < TX_RING; i++) {
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
 			np->tx_ring.orig[i].FlagLen = 0;
 	        else
 			np->tx_ring.ex[i].FlagLen = 0;
+		np->tx_skbuff[i] = NULL;
+	}
 }
 
 static int nv_init_ring(struct net_device *dev)
@@ -915,21 +920,44 @@
 	return nv_alloc_rx(dev);
 }
 
+static void nv_release_txskb(struct net_device *dev, unsigned int skbnr)
+{
+	struct fe_priv *np = get_nvpriv(dev);
+	struct sk_buff *skb = np->tx_skbuff[skbnr];;
+	unsigned int j, entry, fragments;
+			
+	dprintk(KERN_INFO "%s: nv_release_txskb for skbnr %d, skb %p\n",
+		dev->name, skbnr, np->tx_skbuff[skbnr]);
+	
+	entry = skbnr;
+	if ((fragments = skb_shinfo(skb)->nr_frags) != 0) {
+		for (j = fragments; j >= 1; j--) {
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[j-1];
+			pci_unmap_page(np->pci_dev, np->tx_dma[entry],
+				       frag->size,
+				       PCI_DMA_TODEVICE);
+			entry = (entry - 1) % TX_RING;
+		}
+	}
+	pci_unmap_single(np->pci_dev, np->tx_dma[entry],
+			 skb->len - skb->data_len,
+			 PCI_DMA_TODEVICE);
+	dev_kfree_skb_irq(skb);
+	np->tx_skbuff[skbnr] = NULL;
+}
+
 static void nv_drain_tx(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
-	int i;
+	unsigned int i;
+	
 	for (i = 0; i < TX_RING; i++) {
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
 			np->tx_ring.orig[i].FlagLen = 0;
 		else
 			np->tx_ring.ex[i].FlagLen = 0;
 		if (np->tx_skbuff[i]) {
-			pci_unmap_single(np->pci_dev, np->tx_dma[i],
-						np->tx_skbuff[i]->len,
-						PCI_DMA_TODEVICE);
-			dev_kfree_skb(np->tx_skbuff[i]);
-			np->tx_skbuff[i] = NULL;
+			nv_release_txskb(dev, i);
 			np->stats.tx_dropped++;
 		}
 	}
@@ -968,28 +996,69 @@
 static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
-	int nr = np->next_tx % TX_RING;
-	u32 tx_checksum = (skb->ip_summed == CHECKSUM_HW ? (NV_TX2_CHECKSUM_L3|NV_TX2_CHECKSUM_L4) : 0);
+	u32 tx_flags_extra = (np->desc_ver == DESC_VER_1 ? NV_TX_LASTPACKET : NV_TX2_LASTPACKET);
+	unsigned int fragments = skb_shinfo(skb)->nr_frags;
+	unsigned int nr = (np->next_tx + fragments) % TX_RING;
+	unsigned int i;
+
+	spin_lock_irq(&np->lock);
+	wmb();
+
+	if ((np->next_tx - np->nic_tx + fragments) > TX_LIMIT_STOP) {
+		spin_unlock_irq(&np->lock);
+		netif_stop_queue(dev);
+		return 1;
+	}
 
 	np->tx_skbuff[nr] = skb;
-	np->tx_dma[nr] = pci_map_single(np->pci_dev, skb->data,skb->len,
-					PCI_DMA_TODEVICE);
+	
+	if (fragments) {
+		dprintk(KERN_DEBUG "%s: nv_start_xmit: buffer contains %d fragments\n", dev->name, fragments);
+		/* setup descriptors in reverse order */
+		for (i = fragments; i >= 1; i--) {
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i-1];
+			np->tx_dma[nr] = pci_map_page(np->pci_dev, frag->page, frag->page_offset, frag->size,
+							PCI_DMA_TODEVICE);
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+			if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+				np->tx_ring.orig[nr].PacketBuffer = cpu_to_le32(np->tx_dma[nr]);
+				np->tx_ring.orig[nr].FlagLen = cpu_to_le32( (frag->size-1) | np->tx_flags | tx_flags_extra);
+			} else {
+				np->tx_ring.ex[nr].PacketBufferHigh = cpu_to_le64(np->tx_dma[nr]) >> 32;
+				np->tx_ring.ex[nr].PacketBufferLow = cpu_to_le64(np->tx_dma[nr]) & 0x0FFFFFFFF;
+				np->tx_ring.ex[nr].FlagLen = cpu_to_le32( (frag->size-1) | np->tx_flags | tx_flags_extra);
+			}
+			
+			nr = (nr - 1) % TX_RING;
+
+			if (np->desc_ver == DESC_VER_1)
+				tx_flags_extra &= ~NV_TX_LASTPACKET;
+			else
+				tx_flags_extra &= ~NV_TX2_LASTPACKET;		
+		}
+	}
+
+#ifdef NETIF_F_TSO
+	if (skb_shinfo(skb)->tso_size)
+		tx_flags_extra |= NV_TX2_TSO | (skb_shinfo(skb)->tso_size << NV_TX2_TSO_SHIFT);
+	else
+#endif
+	tx_flags_extra |= (skb->ip_summed == CHECKSUM_HW ? (NV_TX2_CHECKSUM_L3|NV_TX2_CHECKSUM_L4) : 0);
+
+	np->tx_dma[nr] = pci_map_single(np->pci_dev, skb->data, skb->len-skb->data_len,
+					PCI_DMA_TODEVICE);
+	
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 		np->tx_ring.orig[nr].PacketBuffer = cpu_to_le32(np->tx_dma[nr]);
-	else {
+		np->tx_ring.orig[nr].FlagLen = cpu_to_le32( (skb->len-skb->data_len-1) | np->tx_flags | tx_flags_extra);
+	} else {
 		np->tx_ring.ex[nr].PacketBufferHigh = cpu_to_le64(np->tx_dma[nr]) >> 32;
 		np->tx_ring.ex[nr].PacketBufferLow = cpu_to_le64(np->tx_dma[nr]) & 0x0FFFFFFFF;
-	}
+		np->tx_ring.ex[nr].FlagLen = cpu_to_le32( (skb->len-skb->data_len-1) | np->tx_flags | tx_flags_extra);
+	}	
 
-	spin_lock_irq(&np->lock);
-	wmb();
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-		np->tx_ring.orig[nr].FlagLen = cpu_to_le32( (skb->len-1) | np->tx_flags | tx_checksum);
-	else
-		np->tx_ring.ex[nr].FlagLen = cpu_to_le32( (skb->len-1) | np->tx_flags | tx_checksum);
-	dprintk(KERN_DEBUG "%s: nv_start_xmit: packet packet %d queued for transmission\n",
-				dev->name, np->next_tx);
+	dprintk(KERN_DEBUG "%s: nv_start_xmit: packet packet %d queued for transmission. tx_flags_extra: %x\n",
+				dev->name, np->next_tx, tx_flags_extra);
 	{
 		int j;
 		for (j=0; j<64; j++) {
@@ -1000,11 +1069,9 @@
 		dprintk("\n");
 	}
 
-	np->next_tx++;
+	np->next_tx += 1 + fragments;
 
 	dev->trans_start = jiffies;
-	if (np->next_tx - np->nic_tx >= TX_LIMIT_STOP)
-		netif_stop_queue(dev);
 	spin_unlock_irq(&np->lock);
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 	pci_push(get_hwbase(dev));
@@ -1020,7 +1087,8 @@
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	u32 Flags;
-	int i;
+	unsigned int i;
+	struct sk_buff *skb;
 
 	while (np->nic_tx != np->next_tx) {
 		i = np->nic_tx % TX_RING;
@@ -1035,35 +1103,38 @@
 		if (Flags & NV_TX_VALID)
 			break;
 		if (np->desc_ver == DESC_VER_1) {
-			if (Flags & (NV_TX_RETRYERROR|NV_TX_CARRIERLOST|NV_TX_LATECOLLISION|
-							NV_TX_UNDERFLOW|NV_TX_ERROR)) {
-				if (Flags & NV_TX_UNDERFLOW)
-					np->stats.tx_fifo_errors++;
-				if (Flags & NV_TX_CARRIERLOST)
-					np->stats.tx_carrier_errors++;
-				np->stats.tx_errors++;
-			} else {
-				np->stats.tx_packets++;
-				np->stats.tx_bytes += np->tx_skbuff[i]->len;
+			if (Flags & NV_TX_LASTPACKET) {
+				skb = np->tx_skbuff[i];
+				if (Flags & (NV_TX_RETRYERROR|NV_TX_CARRIERLOST|NV_TX_LATECOLLISION|
+					     NV_TX_UNDERFLOW|NV_TX_ERROR)) {
+					if (Flags & NV_TX_UNDERFLOW)
+						np->stats.tx_fifo_errors++;
+					if (Flags & NV_TX_CARRIERLOST)
+						np->stats.tx_carrier_errors++;
+					np->stats.tx_errors++;
+				} else {
+					np->stats.tx_packets++;
+					np->stats.tx_bytes += skb->len;
+				}
+				nv_release_txskb(dev, i);
 			}
 		} else {
-			if (Flags & (NV_TX2_RETRYERROR|NV_TX2_CARRIERLOST|NV_TX2_LATECOLLISION|
-							NV_TX2_UNDERFLOW|NV_TX2_ERROR)) {
-				if (Flags & NV_TX2_UNDERFLOW)
-					np->stats.tx_fifo_errors++;
-				if (Flags & NV_TX2_CARRIERLOST)
-					np->stats.tx_carrier_errors++;
-				np->stats.tx_errors++;
-			} else {
-				np->stats.tx_packets++;
-				np->stats.tx_bytes += np->tx_skbuff[i]->len;
+			if (Flags & NV_TX2_LASTPACKET) {
+				skb = np->tx_skbuff[i];
+				if (Flags & (NV_TX2_RETRYERROR|NV_TX2_CARRIERLOST|NV_TX2_LATECOLLISION|
+					     NV_TX2_UNDERFLOW|NV_TX2_ERROR)) {
+					if (Flags & NV_TX2_UNDERFLOW)
+						np->stats.tx_fifo_errors++;
+					if (Flags & NV_TX2_CARRIERLOST)
+						np->stats.tx_carrier_errors++;
+					np->stats.tx_errors++;
+				} else {
+					np->stats.tx_packets++;
+					np->stats.tx_bytes += skb->len;
+				}				
+				nv_release_txskb(dev, i);
 			}
 		}
-		pci_unmap_single(np->pci_dev, np->tx_dma[i],
-					np->tx_skbuff[i]->len,
-					PCI_DMA_TODEVICE);
-		dev_kfree_skb_irq(np->tx_skbuff[i]);
-		np->tx_skbuff[i] = NULL;
 		np->nic_tx++;
 	}
 	if (np->next_tx - np->nic_tx < TX_LIMIT_START)
@@ -2322,6 +2393,8 @@
 		if (pci_set_dma_mask(pci_dev, 0x0000007fffffffffULL)) {
 			printk(KERN_INFO "forcedeth: 64-bit DMA failed, using 32-bit addressing for device %s.\n",
 					pci_name(pci_dev));
+		} else {
+			dev->features |= NETIF_F_HIGHDMA;
 		}
 		np->txrxctl_bits = NVREG_TXRXCTL_DESC_3;
 	} else if (id->driver_data & DEV_HAS_LARGEDESC) {
@@ -2340,8 +2413,11 @@
 
 	if (id->driver_data & DEV_HAS_CHECKSUM) {
 		np->txrxctl_bits |= NVREG_TXRXCTL_RXCHECK;
-		dev->features |= NETIF_F_HW_CSUM;
-	}
+		dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
+#ifdef NETIF_F_TSO
+		dev->features |= NETIF_F_TSO;
+#endif
+ 	}
 
 	err = -ENOMEM;
 	np->base = ioremap(addr, NV_PCI_REGSZ);
@@ -2420,9 +2496,9 @@
 	np->wolenabled = 0;
 
 	if (np->desc_ver == DESC_VER_1) {
-		np->tx_flags = NV_TX_LASTPACKET|NV_TX_VALID;
+		np->tx_flags = NV_TX_VALID;
 	} else {
-		np->tx_flags = NV_TX2_LASTPACKET|NV_TX2_VALID;
+		np->tx_flags = NV_TX2_VALID;
 	}
 	np->irqmask = NVREG_IRQMASK_WANTED;
 	if (id->driver_data & DEV_NEED_TIMERIRQ)

--------------030405010209050508090501--
