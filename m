From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH 2/2] forcedeth: scatter gather and segmentation offload
 support
Date: Mon, 24 Oct 2005 12:48:07 -0400
Message-ID: <435D1047.2070401@nvidia.com>
References: <432D7354.8000503@colorfullife.com> <43595C42.4080201@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090709050409090706060900"
Cc: Manfred Spraul <manfred@colorfullife.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <43595C42.4080201@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090709050409090706060900
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Jeff,

I made the changes you requested. Here is the new patch.

Thanks,
Ayaz

Signed-off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------090709050409090706060900
Content-Type: text/plain;
 name="patch-forcedeth-044-sg-segmentation"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-044-sg-segmentation"

--- orig-2.6/drivers/net/forcedeth.c	2005-10-24 12:40:05.000000000 -0400
+++ new-2.6/drivers/net/forcedeth.c	2005-10-24 12:39:12.000000000 -0400
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
 
@@ -542,7 +545,7 @@
 
 static inline u8 __iomem *get_hwbase(struct net_device *dev)
 {
-	return get_nvpriv(dev)->base;
+  return ((struct fe_priv *)netdev_priv(dev))->base;
 }
 
 static inline void pci_push(u8 __iomem *base)
@@ -631,7 +634,7 @@
 
 static int phy_reset(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u32 miicontrol;
 	unsigned int tries = 0;
 
@@ -734,7 +737,7 @@
 
 static void nv_start_rx(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
 	dprintk(KERN_DEBUG "%s: nv_start_rx\n", dev->name);
@@ -790,7 +793,7 @@
 
 static void nv_txrx_reset(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
 	dprintk(KERN_DEBUG "%s: nv_txrx_reset\n", dev->name);
@@ -809,7 +812,7 @@
  */
 static struct net_device_stats *nv_get_stats(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 
 	/* It seems that the nic always generates interrupts and doesn't
 	 * accumulate errors internally. Thus the current values in np->stats
@@ -825,7 +828,7 @@
  */
 static int nv_alloc_rx(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	unsigned int refill_rx = np->refill_rx;
 	int nr;
 
@@ -869,7 +872,7 @@
 static void nv_do_rx_refill(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 
 	disable_irq(dev->irq);
 	if (nv_alloc_rx(dev)) {
@@ -883,7 +886,7 @@
 
 static void nv_init_rx(struct net_device *dev) 
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	int i;
 
 	np->cur_rx = RX_RING;
@@ -897,15 +900,17 @@
 
 static void nv_init_tx(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
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
+	struct fe_priv *np = netdev_priv(dev);
+	struct sk_buff *skb = np->tx_skbuff[skbnr];
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
-	struct fe_priv *np = get_nvpriv(dev);
-	int i;
+	struct fe_priv *np = netdev_priv(dev);
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
@@ -937,7 +965,7 @@
 
 static void nv_drain_rx(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	int i;
 	for (i = 0; i < RX_RING; i++) {
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
@@ -967,29 +995,69 @@
  */
 static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
-	int nr = np->next_tx % TX_RING;
-	u32 tx_checksum = (skb->ip_summed == CHECKSUM_HW ? (NV_TX2_CHECKSUM_L3|NV_TX2_CHECKSUM_L4) : 0);
+	struct fe_priv *np = netdev_priv(dev);
+	u32 tx_flags_extra = (np->desc_ver == DESC_VER_1 ? NV_TX_LASTPACKET : NV_TX2_LASTPACKET);
+	unsigned int fragments = skb_shinfo(skb)->nr_frags;
+	unsigned int nr = (np->next_tx + fragments) % TX_RING;
+	unsigned int i;
+
+	spin_lock_irq(&np->lock);
+
+	if ((np->next_tx - np->nic_tx + fragments) > TX_LIMIT_STOP) {
+		spin_unlock_irq(&np->lock);
+		netif_stop_queue(dev);
+		return NETDEV_TX_BUSY;
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
@@ -1000,15 +1068,13 @@
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
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
@@ -1018,9 +1084,10 @@
  */
 static void nv_tx_done(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u32 Flags;
-	int i;
+	unsigned int i;
+	struct sk_buff *skb;
 
 	while (np->nic_tx != np->next_tx) {
 		i = np->nic_tx % TX_RING;
@@ -1035,35 +1102,38 @@
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
@@ -1076,7 +1146,7 @@
  */
 static void nv_tx_timeout(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
 	printk(KERN_INFO "%s: Got tx_timeout. irq: %08x\n", dev->name,
@@ -1209,7 +1279,7 @@
 
 static void nv_rx_process(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u32 Flags;
 
 	for (;;) {
@@ -1364,7 +1434,7 @@
  */
 static int nv_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	int old_mtu;
 
 	if (new_mtu < 64 || new_mtu > np->pkt_limit)
@@ -1449,7 +1519,7 @@
  */
 static int nv_set_mac_address(struct net_device *dev, void *addr)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	struct sockaddr *macaddr = (struct sockaddr*)addr;
 
 	if(!is_valid_ether_addr(macaddr->sa_data))
@@ -1484,7 +1554,7 @@
  */
 static void nv_set_multicast(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 addr[2];
 	u32 mask[2];
@@ -1544,7 +1614,7 @@
 
 static int nv_update_linkspeed(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	int adv, lpa;
 	int newls = np->linkspeed;
@@ -1714,7 +1784,7 @@
 static irqreturn_t nv_nic_irq(int foo, void *data, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
 	int i;
@@ -1786,7 +1856,7 @@
 static void nv_do_nic_poll(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
 	disable_irq(dev->irq);
@@ -1810,7 +1880,7 @@
 
 static void nv_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	strcpy(info->driver, "forcedeth");
 	strcpy(info->version, FORCEDETH_VERSION);
 	strcpy(info->bus_info, pci_name(np->pci_dev));
@@ -1818,7 +1888,7 @@
 
 static void nv_get_wol(struct net_device *dev, struct ethtool_wolinfo *wolinfo)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	wolinfo->supported = WAKE_MAGIC;
 
 	spin_lock_irq(&np->lock);
@@ -1829,7 +1899,7 @@
 
 static int nv_set_wol(struct net_device *dev, struct ethtool_wolinfo *wolinfo)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
 	spin_lock_irq(&np->lock);
@@ -2030,7 +2100,7 @@
 
 static void nv_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *buf)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 *rbuf = buf;
 	int i;
@@ -2044,7 +2114,7 @@
 
 static int nv_nway_reset(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	int ret;
 
 	spin_lock_irq(&np->lock);
@@ -2078,7 +2148,7 @@
 
 static int nv_open(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	int ret, oom, i;
 
@@ -2214,7 +2284,7 @@
 
 static int nv_close(struct net_device *dev)
 {
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base;
 
 	spin_lock_irq(&np->lock);
@@ -2270,7 +2340,7 @@
 	if (!dev)
 		goto out;
 
-	np = get_nvpriv(dev);
+	np = netdev_priv(dev);
 	np->pci_dev = pci_dev;
 	spin_lock_init(&np->lock);
 	SET_MODULE_OWNER(dev);
@@ -2322,6 +2392,8 @@
 		if (pci_set_dma_mask(pci_dev, 0x0000007fffffffffULL)) {
 			printk(KERN_INFO "forcedeth: 64-bit DMA failed, using 32-bit addressing for device %s.\n",
 					pci_name(pci_dev));
+		} else {
+			dev->features |= NETIF_F_HIGHDMA;
 		}
 		np->txrxctl_bits = NVREG_TXRXCTL_DESC_3;
 	} else if (id->driver_data & DEV_HAS_LARGEDESC) {
@@ -2340,8 +2412,11 @@
 
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
@@ -2420,9 +2495,9 @@
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
@@ -2511,7 +2586,7 @@
 static void __devexit nv_remove(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
-	struct fe_priv *np = get_nvpriv(dev);
+	struct fe_priv *np = netdev_priv(dev);
 
 	unregister_netdev(dev);
 

--------------090709050409090706060900--
