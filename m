From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: [EXPERIMENTAL PATCH] 2.4 tulip jumbo frames
Date: Tue, 9 Dec 2003 16:06:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031209160632.D1345@sygehus.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DBIVS5p969aUjpLe"
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--DBIVS5p969aUjpLe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Attached is a patch which enables jumbo frames on tulip based boards. It  
makes it possible to set an MTU of up to 2025 bytes. However, testing
against an NE3200 board using 10base-2 shows assorted problems when going
above 2018 bytes (for frames without VLAN tags). The problems show up as
framing errors, bad CRCs and such (in both directions).

The patch is against 2.4.22-bk45.

--
Regards,
Rask Ingemann Lambertsen

--DBIVS5p969aUjpLe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tulip-mtu.patch"

--- linux-2.4.22/drivers/net/tulip/tulip.h-orig	Mon Dec  1 21:58:11 2003
+++ linux-2.4.22/drivers/net/tulip/tulip.h	Mon Dec  1 22:09:14 2003
@@ -190,6 +190,12 @@ enum desc_status_bits {
 	DescOwned = 0x80000000,
 	RxDescFatalErr = 0x8000,
 	RxWholePkt = 0x0300,
+	RxError = (1 << 15),
+	RxErrLong = (1 << 7),
+	RxErrCRC = (1 << 1),
+	RxErrFIFO = (1 << 0),
+	RxErrRunt = (1 << 11),
+	RxErrFrame = (1 << 14),
 };
 
 
@@ -347,6 +353,7 @@ struct tulip_private {
 	struct ring_info tx_buffers[TX_RING_SIZE];
 	/* The addresses of receive-in-place skbuffs. */
 	struct ring_info rx_buffers[RX_RING_SIZE];
+	uint rx_buf_sz;
 	u16 setup_frame[96];	/* Pseudo-Tx frame to init address table. */
 	int chip_id;
 	int revision;
--- linux-2.4.22/drivers/net/tulip/interrupt.c-orig	Mon Dec  1 21:52:10 2003
+++ linux-2.4.22/drivers/net/tulip/interrupt.c	Mon Dec  1 22:03:50 2003
@@ -74,11 +74,11 @@ int tulip_refill_rx(struct net_device *d
 			struct sk_buff *skb;
 			dma_addr_t mapping;
 
-			skb = tp->rx_buffers[entry].skb = dev_alloc_skb(PKT_BUF_SZ);
+			skb = tp->rx_buffers[entry].skb = dev_alloc_skb(tp->rx_buf_sz);
 			if (skb == NULL)
 				break;
 
-			mapping = pci_map_single(tp->pdev, skb->tail, PKT_BUF_SZ,
+			mapping = pci_map_single(tp->pdev, skb->tail, tp->rx_buf_sz,
 						 PCI_DMA_FROMDEVICE);
 			tp->rx_buffers[entry].mapping = mapping;
 
@@ -122,13 +122,21 @@ static int tulip_rx(struct net_device *d
 	/* If we own the next entry, it is a new packet. Send it up. */
 	while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
 		s32 status = le32_to_cpu(tp->rx_ring[entry].status);
+		s32 status_hacked;
 
 		if (tulip_debug > 5)
 			printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
 				   dev->name, entry, status);
 		if (--rx_work_limit < 0)
 			break;
-		if ((status & 0x38008300) != 0x0300) {
+
+		/* Ugly Jumbo frame hack. Remove error flag on long frames. */
+		if ((status & (RxErrLong | RxErrCRC | RxErrFIFO | RxErrRunt | RxErrFrame)) == RxErrLong)
+			status_hacked = status & ~(RxError | RxErrLong);
+		else
+			status_hacked = status;
+
+		if (unlikely((status_hacked & 0x38008300) != 0x0300)) {
 			if ((status & 0x38000300) != 0x0300) {
 				/* Ingore earlier buffers. */
 				if ((status & 0xffff) != 0x7fff) {
@@ -154,15 +162,6 @@ static int tulip_rx(struct net_device *d
 			short pkt_len = ((status >> 16) & 0x7ff) - 4;
 			struct sk_buff *skb;
 
-#ifndef final_version
-			if (pkt_len > 1518) {
-				printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\n",
-					   dev->name, pkt_len, pkt_len);
-				pkt_len = 1518;
-				tp->stats.rx_length_errors++;
-			}
-#endif
-
 #ifdef CONFIG_NET_HW_FLOWCONTROL
                         drop = atomic_read(&netdev_dropping);
                         if (drop)
@@ -203,7 +202,7 @@ static int tulip_rx(struct net_device *d
 #endif
 
 				pci_unmap_single(tp->pdev, tp->rx_buffers[entry].mapping,
-						 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
+						 tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
 				tp->rx_buffers[entry].skb = NULL;
 				tp->rx_buffers[entry].mapping = 0;
--- linux-2.4.22/drivers/net/tulip/tulip_core.c-orig	Mon Dec  1 21:34:32 2003
+++ linux-2.4.22/drivers/net/tulip/tulip_core.c	Mon Dec  1 22:10:53 2003
@@ -24,6 +24,7 @@
 #include <linux/pci.h>
 #include <linux/init.h>
 #include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
 #include <linux/delay.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
@@ -60,11 +61,13 @@ const char * const medianame[32] = {
 	"","","","", "","","","",  "","","","Transceiver reset",
 };
 
+#define PKT_BUF_SZ_MAX		2047	/* Maximum Rx buffer size. */
+
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx structure. */
 #if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
 	|| defined(__sparc_) || defined(__ia64__) \
 	|| defined(__sh__) || defined(__mips__) || defined(__SH5__)
-static int rx_copybreak = 1518;
+static int rx_copybreak = PKT_BUF_SZ_MAX;
 #else
 static int rx_copybreak = 100;
 #endif
@@ -518,9 +521,7 @@ void tulip_xon(struct net_device *dev)
 static int
 tulip_open(struct net_device *dev)
 {
-#ifdef CONFIG_NET_HW_FLOWCONTROL
         struct tulip_private *tp = (struct tulip_private *)dev->priv;
-#endif
 	int retval;
 	MOD_INC_USE_COUNT;
 
@@ -529,6 +530,10 @@ tulip_open(struct net_device *dev)
 		return retval;
 	}
 
+ 	tp->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
+	if (tp->rx_buf_sz > PKT_BUF_SZ_MAX)
+		tp->rx_buf_sz = PKT_BUF_SZ_MAX;
+
 	tulip_init_ring (dev);
 
 	tulip_up (dev);
@@ -673,13 +678,13 @@ static void tulip_init_ring(struct net_d
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		tp->rx_ring[i].status = 0x00000000;
-		tp->rx_ring[i].length = cpu_to_le32(PKT_BUF_SZ);
+		tp->rx_ring[i].length = cpu_to_le32(tp->rx_buf_sz);
 		tp->rx_ring[i].buffer2 = cpu_to_le32(tp->rx_ring_dma + sizeof(struct tulip_rx_desc) * (i + 1));
 		tp->rx_buffers[i].skb = NULL;
 		tp->rx_buffers[i].mapping = 0;
 	}
 	/* Mark the last entry as wrapping the ring. */
-	tp->rx_ring[i-1].length = cpu_to_le32(PKT_BUF_SZ | DESC_RING_WRAP);
+	tp->rx_ring[i-1].length = cpu_to_le32(tp->rx_buf_sz | DESC_RING_WRAP);
 	tp->rx_ring[i-1].buffer2 = cpu_to_le32(tp->rx_ring_dma);
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
@@ -688,12 +693,12 @@ static void tulip_init_ring(struct net_d
 		/* Note the receive buffer must be longword aligned.
 		   dev_alloc_skb() provides 16 byte alignment.  But do *not*
 		   use skb_reserve() to align the IP header! */
-		struct sk_buff *skb = dev_alloc_skb(PKT_BUF_SZ);
+		struct sk_buff *skb = dev_alloc_skb(tp->rx_buf_sz);
 		tp->rx_buffers[i].skb = skb;
 		if (skb == NULL)
 			break;
 		mapping = pci_map_single(tp->pdev, skb->tail,
-					 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
+					 tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 		tp->rx_buffers[i].mapping = mapping;
 		skb->dev = dev;			/* Mark as being used by this device. */
 		tp->rx_ring[i].status = cpu_to_le32(DescOwned);	/* Owned by Tulip chip */
@@ -876,7 +881,7 @@ static int tulip_close (struct net_devic
 		tp->rx_ring[i].length = 0;
 		tp->rx_ring[i].buffer1 = 0xBADF00D0;	/* An invalid address. */
 		if (skb) {
-			pci_unmap_single(tp->pdev, mapping, PKT_BUF_SZ,
+			pci_unmap_single(tp->pdev, mapping, tp->rx_buf_sz,
 					 PCI_DMA_FROMDEVICE);
 			dev_kfree_skb (skb);
 		}
@@ -1321,6 +1326,18 @@ out:
 }
 #endif
 
+static int tulip_change_mtu (struct net_device *dev, int mtu)
+{
+	if (netif_running (dev))
+		return (-EBUSY);
+
+	if (mtu < 0 || mtu > PKT_BUF_SZ_MAX - VLAN_ETH_HLEN - 4)
+		return (-EINVAL);
+
+	dev->mtu = mtu;
+	return (0);
+}
+
 static int __devinit tulip_init_one (struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
 {
@@ -1727,6 +1744,7 @@ static int __devinit tulip_init_one (str
 	dev->get_stats = tulip_get_stats;
 	dev->do_ioctl = private_ioctl;
 	dev->set_multicast_list = set_rx_mode;
+	dev->change_mtu = tulip_change_mtu;
 
 	if (register_netdev(dev))
 		goto err_out_free_ring;

--DBIVS5p969aUjpLe--
