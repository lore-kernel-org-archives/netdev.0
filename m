From: Kyle McMartin <kyle@parisc-linux.org>
Subject: [PATCH 4/9] [TULIP] Clean tulip.h so it can be used by winbond-840.c
Date: Mon, 07 Aug 2006 20:53:27 +0000
Message-ID: <115498403384-git-send-email-kyle@parisc-linux.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org> <11549840321096-git-send-email-kyle@parisc-linux.org> <1154984032324-git-send-email-kyle@parisc-linux.org>
Reply-To: Kyle McMartin <kyle@parisc-linux.org>
Cc: grundler@parisc-linux.org, val_henson@linux.intel.com,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:9705 "EHLO hera.kernel.org")
	by vger.kernel.org with ESMTP id S932358AbWHGUx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 16:53:59 -0400
To: netdev@vger.kernel.org
In-Reply-To: <1154984032324-git-send-email-kyle@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@parisc-linux.org>

Include "tulip.h" in winbond-840.c and clean up lots of redundant
definitions.

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
---
 drivers/net/tulip/tulip.h       |   17 ++++++----
 drivers/net/tulip/tulip_core.c  |    7 +---
 drivers/net/tulip/winbond-840.c |   68 ++++++++++++++-------------------------
 3 files changed, 37 insertions(+), 55 deletions(-)

diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
index d79c7ae..951af5e 100644
--- a/drivers/net/tulip/tulip.h
+++ b/drivers/net/tulip/tulip.h
@@ -30,11 +30,10 @@ #include <asm/irq.h>
 /* undefine, or define to various debugging levels (>4 == obscene levels) */
 #define TULIP_DEBUG 1
 
-/* undefine USE_IO_OPS for MMIO, define for PIO */
 #ifdef CONFIG_TULIP_MMIO
-# undef USE_IO_OPS
+#define TULIP_BAR	1	/* CBMA */
 #else
-# define USE_IO_OPS 1
+#define TULIP_BAR	0	/* CBIO */
 #endif
 
 
@@ -142,6 +141,7 @@ enum status_bits {
 	RxNoBuf = 0x80,
 	RxIntr = 0x40,
 	TxFIFOUnderflow = 0x20,
+	RxErrIntr = 0x10,
 	TxJabber = 0x08,
 	TxNoBuf = 0x04,
 	TxDied = 0x02,
@@ -192,9 +192,14 @@ struct tulip_tx_desc {
 
 
 enum desc_status_bits {
-	DescOwned = 0x80000000,
-	RxDescFatalErr = 0x8000,
-	RxWholePkt = 0x0300,
+	DescOwned    = 0x80000000,
+	DescWholePkt = 0x60000000,
+	DescEndPkt   = 0x40000000,
+	DescStartPkt = 0x20000000,
+	DescEndRing  = 0x02000000,
+	DescUseLink  = 0x01000000,
+	RxDescFatalErr = 0x008000,
+	RxWholePkt   = 0x00000300,
 };
 
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index bf93679..6b54572 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1361,11 +1361,8 @@ #endif
 	if (pci_request_regions (pdev, "tulip"))
 		goto err_out_free_netdev;
 
-#ifndef USE_IO_OPS
-	ioaddr =  pci_iomap(pdev, 1, tulip_tbl[chip_idx].io_size);
-#else
-	ioaddr =  pci_iomap(pdev, 0, tulip_tbl[chip_idx].io_size);
-#endif
+	ioaddr =  pci_iomap(pdev, TULIP_BAR, tulip_tbl[chip_idx].io_size);
+
 	if (!ioaddr)
 		goto err_out_free_res;
 
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 7f41481..fa3a7b3 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -90,10 +90,8 @@ static int full_duplex[MAX_UNITS] = {-1,
    Making the Tx ring too large decreases the effectiveness of channel
    bonding and packet priority.
    There are no ill effects from too-large receive rings. */
-#define TX_RING_SIZE	16
 #define TX_QUEUE_LEN	10		/* Limit ring entries actually used.  */
 #define TX_QUEUE_LEN_RESTART	5
-#define RX_RING_SIZE	32
 
 #define TX_BUFLIMIT	(1024-128)
 
@@ -137,6 +135,8 @@ #include <asm/processor.h>		/* Processor
 #include <asm/io.h>
 #include <asm/irq.h>
 
+#include "tulip.h"
+
 /* These identify the driver base version and may not be removed. */
 static char version[] __devinitdata =
 KERN_INFO DRV_NAME ".c:v" DRV_VERSION " (2.4 port) " DRV_RELDATE "  Donald Becker <becker@scyld.com>\n"
@@ -242,8 +242,8 @@ static const struct pci_id_info pci_id_t
 };
 
 /* This driver was written to use PCI memory space, however some x86 systems
-   work only with I/O space accesses.  Pass -DUSE_IO_OPS to use PCI I/O space
-   accesses instead of memory space. */
+   work only with I/O space accesses. See CONFIG_TULIP_MMIO in .config
+*/
 
 /* Offsets to the Command and Status Registers, "CSRs".
    While similar to the Tulip, these registers are longword aligned.
@@ -261,21 +261,11 @@ enum w840_offsets {
 	CurTxDescAddr=0x4C, CurTxBufAddr=0x50,
 };
 
-/* Bits in the interrupt status/enable registers. */
-/* The bits in the Intr Status/Enable registers, mostly interrupt sources. */
-enum intr_status_bits {
-	NormalIntr=0x10000, AbnormalIntr=0x8000,
-	IntrPCIErr=0x2000, TimerInt=0x800,
-	IntrRxDied=0x100, RxNoBuf=0x80, IntrRxDone=0x40,
-	TxFIFOUnderflow=0x20, RxErrIntr=0x10,
-	TxIdle=0x04, IntrTxStopped=0x02, IntrTxDone=0x01,
-};
-
 /* Bits in the NetworkConfig register. */
 enum rx_mode_bits {
-	AcceptErr=0x80, AcceptRunt=0x40,
-	AcceptBroadcast=0x20, AcceptMulticast=0x10,
-	AcceptAllPhys=0x08, AcceptMyPhys=0x02,
+	AcceptErr=0x80,
+	RxAcceptBroadcast=0x20, AcceptMulticast=0x10,
+	RxAcceptAllPhys=0x08, AcceptMyPhys=0x02,
 };
 
 enum mii_reg_bits {
@@ -297,13 +287,6 @@ struct w840_tx_desc {
 	u32 buffer1, buffer2;
 };
 
-/* Bits in network_desc.status */
-enum desc_status_bits {
-	DescOwn=0x80000000, DescEndRing=0x02000000, DescUseLink=0x01000000,
-	DescWholePkt=0x60000000, DescStartPkt=0x20000000, DescEndPkt=0x40000000,
-	DescIntr=0x80000000,
-};
-
 #define MII_CNT		1 /* winbond only supports one MII */
 struct netdev_private {
 	struct w840_rx_desc *rx_ring;
@@ -371,7 +354,6 @@ static int __devinit w840_probe1 (struct
 	int irq;
 	int i, option = find_cnt < MAX_UNITS ? options[find_cnt] : 0;
 	void __iomem *ioaddr;
-	int bar = 1;
 
 	i = pci_enable_device(pdev);
 	if (i) return i;
@@ -393,10 +375,8 @@ static int __devinit w840_probe1 (struct
 
 	if (pci_request_regions(pdev, DRV_NAME))
 		goto err_out_netdev;
-#ifdef USE_IO_OPS
-	bar = 0;
-#endif
-	ioaddr = pci_iomap(pdev, bar, netdev_res_size);
+
+	ioaddr = pci_iomap(pdev, TULIP_BAR, netdev_res_size);
 	if (!ioaddr)
 		goto err_out_free_res;
 
@@ -838,7 +818,7 @@ static void init_rxtx_rings(struct net_d
 					np->rx_buf_sz,PCI_DMA_FROMDEVICE);
 
 		np->rx_ring[i].buffer1 = np->rx_addr[i];
-		np->rx_ring[i].status = DescOwn;
+		np->rx_ring[i].status = DescOwned;
 	}
 
 	np->cur_rx = 0;
@@ -923,7 +903,7 @@ #if defined (__i386__) && !defined(MODUL
 	}
 #elif defined(__powerpc__) || defined(__i386__) || defined(__alpha__) || defined(__ia64__) || defined(__x86_64__)
 	i |= 0xE000;
-#elif defined(__sparc__)
+#elif defined(__sparc__) || defined (CONFIG_PARISC)
 	i |= 0x4800;
 #else
 #warning Processor architecture undefined
@@ -1043,11 +1023,11 @@ static int start_tx(struct sk_buff *skb,
 
 	/* Now acquire the irq spinlock.
 	 * The difficult race is the the ordering between
-	 * increasing np->cur_tx and setting DescOwn:
+	 * increasing np->cur_tx and setting DescOwned:
 	 * - if np->cur_tx is increased first the interrupt
 	 *   handler could consider the packet as transmitted
-	 *   since DescOwn is cleared.
-	 * - If DescOwn is set first the NIC could report the
+	 *   since DescOwned is cleared.
+	 * - If DescOwned is set first the NIC could report the
 	 *   packet as sent, but the interrupt handler would ignore it
 	 *   since the np->cur_tx was not yet increased.
 	 */
@@ -1055,7 +1035,7 @@ static int start_tx(struct sk_buff *skb,
 	np->cur_tx++;
 
 	wmb(); /* flush length, buffer1, buffer2 */
-	np->tx_ring[entry].status = DescOwn;
+	np->tx_ring[entry].status = DescOwned;
 	wmb(); /* flush status and kick the hardware */
 	iowrite32(0, np->base_addr + TxStartDemand);
 	np->tx_q_bytes += skb->len;
@@ -1155,12 +1135,12 @@ static irqreturn_t intr_handler(int irq,
 
 		handled = 1;
 
-		if (intr_status & (IntrRxDone | RxNoBuf))
+		if (intr_status & (RxIntr | RxNoBuf))
 			netdev_rx(dev);
 		if (intr_status & RxNoBuf)
 			iowrite32(0, ioaddr + RxStartDemand);
 
-		if (intr_status & (TxIdle | IntrTxDone) &&
+		if (intr_status & (TxNoBuf | TxIntr) &&
 			np->cur_tx != np->dirty_tx) {
 			spin_lock(&np->lock);
 			netdev_tx_done(dev);
@@ -1168,8 +1148,8 @@ static irqreturn_t intr_handler(int irq,
 		}
 
 		/* Abnormal error summary/uncommon events handlers. */
-		if (intr_status & (AbnormalIntr | TxFIFOUnderflow | IntrPCIErr |
-						   TimerInt | IntrTxStopped))
+		if (intr_status & (AbnormalIntr | TxFIFOUnderflow | SytemError |
+						   TimerInt | TxDied))
 			netdev_error(dev, intr_status);
 
 		if (--work_limit < 0) {
@@ -1305,7 +1285,7 @@ #endif
 			np->rx_ring[entry].buffer1 = np->rx_addr[entry];
 		}
 		wmb();
-		np->rx_ring[entry].status = DescOwn;
+		np->rx_ring[entry].status = DescOwned;
 	}
 
 	return 0;
@@ -1342,7 +1322,7 @@ #endif
 			   dev->name, new);
 		update_csr6(dev, new);
 	}
-	if (intr_status & IntrRxDied) {		/* Missed a Rx frame. */
+	if (intr_status & RxDied) {		/* Missed a Rx frame. */
 		np->stats.rx_errors++;
 	}
 	if (intr_status & TimerInt) {
@@ -1381,13 +1361,13 @@ static u32 __set_rx_mode(struct net_devi
 		/* Unconditionally log net taps. */
 		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		memset(mc_filter, 0xff, sizeof(mc_filter));
-		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptAllPhys
+		rx_mode = RxAcceptBroadcast | AcceptMulticast | RxAcceptAllPhys
 			| AcceptMyPhys;
 	} else if ((dev->mc_count > multicast_filter_limit)
 			   ||  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
-		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
+		rx_mode = RxAcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 	} else {
 		struct dev_mc_list *mclist;
 		int i;
@@ -1398,7 +1378,7 @@ static u32 __set_rx_mode(struct net_devi
 			filterbit &= 0x3f;
 			mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 		}
-		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
+		rx_mode = RxAcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 	}
 	iowrite32(mc_filter[0], ioaddr + MulticastFilter0);
 	iowrite32(mc_filter[1], ioaddr + MulticastFilter1);
-- 
1.4.1.1

