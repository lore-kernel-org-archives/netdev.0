From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 2/2] tc35815 driver update (part 2)
Date: Fri, 02 Mar 2007 23:24:23 +0900 (JST)
Message-ID: <20070302.232423.93208109.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org, jeff@garzik.org,
	sshtylyov@ru.mvista.com
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([210.190.142.172]:56221 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992479AbXCBOYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 09:24:25 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More updates for tc35815 driver, including:

* TX4939 support.
* NETPOLL support.
* NAPI support. (disabled by default)
* Reduce memcpy on receiving.
* PM support.
* Many cleanups and bugfixes.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c   |  827 +++++++++++++++++++++++++++++++++++-----------
 include/linux/pci_ids.h |    1 
 2 files changed, 632 insertions(+), 196 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 0cf1f87..ec888db 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -38,9 +38,33 @@
  *		Add workaround for 100MHalf HUB.
  *	1.22	Minor fix.
  *	1.23	Minor cleanup.
+ *	1.24	Remove tc35815_setup since new stype option
+ *		("tc35815.speed=10", etc.) can be used for 2.6 kernel.
+ *	1.25	TX4939 support.
+ *	1.26	Minor cleanup.
+ *	1.27	Move TX4939 PCFG.SPEEDn control code out from this driver.
+ *		Cleanup init_dev_addr. (NETDEV_REGISTER event notifier
+ *		can overwrite dev_addr)
+ *		support ETHTOOL_GPERMADDR.
+ *	1.28	Minor cleanup.
+ *	1.29	support netpoll.
+ *	1.30	Minor cleanup.
+ *	1.31	NAPI support. (disabled by default)
+ *		Use DMA_RxAlign_2 if possible.
+ *		Do not use PackedBuffer.
+ *		Cleanup.
+ *	1.32	Fix free buffer management on non-PackedBuffer mode.
+ *	1.33	Fix netpoll build.
+ *	1.34	Fix netpoll locking.  "BH rule" for NAPI is not enough with
+ *		netpoll, hard_start_xmit might be called from irq context.
+ *		PM support.
  */
 
-#define DRV_VERSION	"1.23"
+#ifdef TC35815_NAPI
+#define DRV_VERSION	"1.34-NAPI"
+#else
+#define DRV_VERSION	"1.34"
+#endif
 static const char *version = "tc35815.c:v" DRV_VERSION "\n";
 #define MODNAME			"tc35815"
 
@@ -71,23 +95,27 @@ static const char *version = "tc35815.c:
 #define GATHER_TXINT	/* On-Demand Tx Interrupt */
 #define WORKAROUND_LOSTCAR
 #define WORKAROUND_100HALF_PROMISC
+/* #define TC35815_USE_PACKEDBUFFER */
 
 typedef enum {
 	TC35815CF = 0,
 	TC35815_NWU,
+	TC35815_TX4939,
 } board_t;
 
 /* indexed by board_t, above */
-static struct {
+static const struct {
 	const char *name;
 } board_info[] __devinitdata = {
 	{ "TOSHIBA TC35815CF 10/100BaseTX" },
 	{ "TOSHIBA TC35815 with Wake on LAN" },
+	{ "TOSHIBA TC35815/TX4939" },
 };
 
-static struct pci_device_id tc35815_pci_tbl[] = {
-	{PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815CF, PCI_ANY_ID, PCI_ANY_ID, 0, 0, TC35815CF },
-	{PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_NWU, PCI_ANY_ID, PCI_ANY_ID, 0, 0, TC35815_NWU },
+static const struct pci_device_id tc35815_pci_tbl[] = {
+	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815CF), .driver_data = TC35815CF },
+	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_NWU), .driver_data = TC35815_NWU },
+	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_TX4939), .driver_data = TC35815_TX4939 },
 	{0,}
 };
 MODULE_DEVICE_TABLE (pci, tc35815_pci_tbl);
@@ -140,6 +168,11 @@ struct tc35815_regs {
  * Bit assignments
  */
 /* DMA_Ctl bit asign ------------------------------------------------------- */
+#define DMA_RxAlign            0x00c00000 /* 1:Reception Alignment           */
+#define DMA_RxAlign_1          0x00400000
+#define DMA_RxAlign_2          0x00800000
+#define DMA_RxAlign_3          0x00c00000
+#define DMA_M66EnStat          0x00080000 /* 1:66MHz Enable State            */
 #define DMA_IntMask            0x00040000 /* 1:Interupt mask                 */
 #define DMA_SWIntReq           0x00020000 /* 1:Software Interrupt request    */
 #define DMA_TxWakeUp           0x00010000 /* 1:Transmit Wake Up              */
@@ -351,6 +384,8 @@ struct BDesc {
 	Int_SSysErrEn  | Int_RMasAbtEn | Int_RTargAbtEn | \
 	Int_STargAbtEn | \
 	Int_BLExEn  | Int_FDAExEn) /* maybe 0xb7f*/
+#define DMA_CTL_CMD	DMA_BURST_SIZE
+#define HAVE_DMA_RXALIGN(lp)	likely((lp)->boardtype != TC35815CF)
 
 /* Tuning parameters */
 #define DMA_BURST_SIZE	32
@@ -358,12 +393,28 @@ struct BDesc {
 #define TX_THRESHOLD_MAX 1536       /* used threshold with packet max byte for low pci transfer ability.*/
 #define TX_THRESHOLD_KEEP_LIMIT 10  /* setting threshold max value when overrun error occured this count. */
 
+/* 16 + RX_BUF_NUM * 8 + RX_FD_NUM * 16 + TX_FD_NUM * 32 <= PAGE_SIZE*FD_PAGE_NUM */
+#ifdef TC35815_USE_PACKEDBUFFER
 #define FD_PAGE_NUM 2
-#define FD_PAGE_ORDER 1
-/* 16 + RX_BUF_PAGES * 8 + RX_FD_NUM * 16 + TX_FD_NUM * 32 <= PAGE_SIZE*2 */
-#define RX_BUF_PAGES	8	/* >= 2 */
+#define RX_BUF_NUM	8	/* >= 2 */
 #define RX_FD_NUM	250	/* >= 32 */
 #define TX_FD_NUM	128
+#define RX_BUF_SIZE	PAGE_SIZE
+#else /* TC35815_USE_PACKEDBUFFER */
+#define FD_PAGE_NUM 4
+#define RX_BUF_NUM	128	/* < 256 */
+#define RX_FD_NUM	256	/* >= 32 */
+#define TX_FD_NUM	128
+#if RX_CTL_CMD & Rx_LongEn
+#define RX_BUF_SIZE	PAGE_SIZE
+#elif RX_CTL_CMD & Rx_StripCRC
+#define RX_BUF_SIZE	ALIGN(ETH_FRAME_LEN + 4 + 2, 32) /* +2: reserve */
+#else
+#define RX_BUF_SIZE	ALIGN(ETH_FRAME_LEN + 2, 32) /* +2: reserve */
+#endif
+#endif /* TC35815_USE_PACKEDBUFFER */
+#define RX_FD_RESERVE	(2 / 2)	/* max 2 BD per RxFD */
+#define NAPI_WEIGHT	16
 
 struct TxFD {
 	struct FDesc fd;
@@ -378,14 +429,14 @@ struct RxFD {
 
 struct FrFD {
 	struct FDesc fd;
-	struct BDesc bd[RX_BUF_PAGES];
+	struct BDesc bd[RX_BUF_NUM];
 };
 
 
 #define tc_readl(addr)	readl(addr)
 #define tc_writel(d, addr)	writel(d, addr)
 
-#define TC35815_TX_TIMEOUT  ((400*HZ)/1000)
+#define TC35815_TX_TIMEOUT  msecs_to_jiffies(400)
 
 /* Timer state engine. */
 enum tc35815_timer_state {
@@ -426,10 +477,14 @@ struct tc35815_local {
 	/*
 	 * Transmitting: Batch Mode.
 	 *	1 BD in 1 TxFD.
-	 * Receiving: Packing Mode.
+	 * Receiving: Packing Mode. (TC35815_USE_PACKEDBUFFER)
 	 *	1 circular FD for Free Buffer List.
-	 *	RX_BUF_PAGES BD in Free Buffer FD.
+	 *	RX_BUF_NUM BD in Free Buffer FD.
 	 *	One Free Buffer BD has PAGE_SIZE data buffer.
+	 * Or Non-Packing Mode.
+	 *	1 circular FD for Free Buffer List.
+	 *	RX_BUF_NUM BD in Free Buffer FD.
+	 *	One Free Buffer BD has ETH_FRAME_LEN data buffer.
 	 */
 	void * fd_buf;	/* for TxFD, RxFD, FrFD */
 	dma_addr_t fd_buf_dma;
@@ -440,41 +495,42 @@ struct tc35815_local {
 	struct RxFD *rfd_limit;
 	struct RxFD *rfd_cur;
 	struct FrFD *fbl_ptr;
+#ifdef TC35815_USE_PACKEDBUFFER
 	unsigned char fbl_curid;
-	void * data_buf[RX_BUF_PAGES];		/* packing */
-	dma_addr_t data_buf_dma[RX_BUF_PAGES];		/* packing */
-
+	void * data_buf[RX_BUF_NUM];		/* packing */
+	dma_addr_t data_buf_dma[RX_BUF_NUM];
 	struct {
 		struct sk_buff *skb;
 		dma_addr_t skb_dma;
 	} tx_skbs[TX_FD_NUM];
+#else
+	unsigned int fbl_count;
+	struct {
+		struct sk_buff *skb;
+		dma_addr_t skb_dma;
+	} tx_skbs[TX_FD_NUM], rx_skbs[RX_BUF_NUM];
+#endif
 	struct mii_if_info mii;
 	unsigned short mii_id[2];
 	u32 msg_enable;
+	board_t boardtype;
 };
 
 static inline dma_addr_t fd_virt_to_bus(struct tc35815_local *lp, void *virt)
 {
 	return lp->fd_buf_dma + ((u8 *)virt - (u8 *)lp->fd_buf);
 }
+#ifdef DEBUG
 static inline void *fd_bus_to_virt(struct tc35815_local *lp, dma_addr_t bus)
 {
 	return (void *)((u8 *)lp->fd_buf + (bus - lp->fd_buf_dma));
 }
-static inline dma_addr_t rxbuf_virt_to_bus(struct tc35815_local *lp, void *virt)
-{
-	int i;
-	for (i = 0; i < RX_BUF_PAGES; i++) {
-		if ((u8 *)virt >= (u8 *)lp->data_buf[i] &&
-		    (u8 *)virt < (u8 *)lp->data_buf[i] + PAGE_SIZE)
-			return lp->data_buf_dma[i] + ((u8 *)virt - (u8 *)lp->data_buf[i]);
-	}
-	return 0;
-}
+#endif
+#ifdef TC35815_USE_PACKEDBUFFER
 static inline void *rxbuf_bus_to_virt(struct tc35815_local *lp, dma_addr_t bus)
 {
 	int i;
-	for (i = 0; i < RX_BUF_PAGES; i++) {
+	for (i = 0; i < RX_BUF_NUM; i++) {
 		if (bus >= lp->data_buf_dma[i] &&
 		    bus < lp->data_buf_dma[i] + PAGE_SIZE)
 			return (void *)((u8 *)lp->data_buf[i] +
@@ -513,29 +569,67 @@ static void free_rxbuf_page(struct pci_d
 	pci_free_consistent(hwdev, PAGE_SIZE, buf, dma_handle);
 #endif
 }
+#else /* TC35815_USE_PACKEDBUFFER */
+static struct sk_buff *alloc_rxbuf_skb(struct net_device *dev,
+				       struct pci_dev *hwdev,
+				       dma_addr_t *dma_handle)
+{
+	struct sk_buff *skb;
+	skb = dev_alloc_skb(RX_BUF_SIZE);
+	if (!skb)
+		return NULL;
+	skb->dev = dev;
+	*dma_handle = pci_map_single(hwdev, skb->data, RX_BUF_SIZE,
+				     PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(*dma_handle)) {
+		dev_kfree_skb_any(skb);
+		return NULL;
+	}
+	skb_reserve(skb, 2);	/* make IP header 4byte aligned */
+	return skb;
+}
+
+static void free_rxbuf_skb(struct pci_dev *hwdev, struct sk_buff *skb, dma_addr_t dma_handle)
+{
+	pci_unmap_single(hwdev, dma_handle, RX_BUF_SIZE,
+			 PCI_DMA_FROMDEVICE);
+	dev_kfree_skb_any(skb);
+}
+#endif /* TC35815_USE_PACKEDBUFFER */
 
 /* Index to functions, as function prototypes. */
 
 static int	tc35815_open(struct net_device *dev);
 static int	tc35815_send_packet(struct sk_buff *skb, struct net_device *dev);
-static irqreturn_t tc35815_interrupt(int irq, void *dev_id);
+static irqreturn_t	tc35815_interrupt(int irq, void *dev_id);
+#ifdef TC35815_NAPI
+static int	tc35815_rx(struct net_device *dev, int limit);
+static int	tc35815_poll(struct net_device *dev, int *budget);
+#else
 static void	tc35815_rx(struct net_device *dev);
+#endif
 static void	tc35815_txdone(struct net_device *dev);
 static int	tc35815_close(struct net_device *dev);
 static struct	net_device_stats *tc35815_get_stats(struct net_device *dev);
 static void	tc35815_set_multicast_list(struct net_device *dev);
 static void     tc35815_tx_timeout(struct net_device *dev);
 static int	tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-static struct ethtool_ops tc35815_ethtool_ops;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void	tc35815_poll_controller(struct net_device *dev);
+#endif
+static const struct ethtool_ops tc35815_ethtool_ops;
 
 /* Example routines you must write ;->. */
-static void 	tc35815_chip_reset(struct tc35815_regs *tr);
+static void 	tc35815_chip_reset(struct net_device *dev);
 static void 	tc35815_chip_init(struct net_device *dev);
 static void	tc35815_find_phy(struct net_device *dev);
 static void 	tc35815_phy_chip_init(struct net_device *dev);
 
+#ifdef DEBUG
 static void	panic_queues(struct net_device *dev);
+#endif
 
+static void tc35815_timer(unsigned long data);
 static void tc35815_start_auto_negotiation(struct net_device *dev,
 					   struct ethtool_cmd *ep);
 static int tc_mdio_read(struct net_device *dev, int phy_id, int location);
@@ -544,9 +638,11 @@ static void tc_mdio_write(struct net_dev
 
 static void __devinit tc35815_init_dev_addr (struct net_device *dev)
 {
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 	int i;
 
+	/* dev_addr will be overwritten on NETDEV_REGISTER event */
 	while (tc_readl(&tr->PROM_Ctl) & PROM_Busy)
 		;
 	for (i = 0; i < 6; i += 2) {
@@ -563,7 +659,7 @@ static void __devinit tc35815_init_dev_a
 static int __devinit tc35815_init_one (struct pci_dev *pdev,
 				       const struct pci_device_id *ent)
 {
-	void *ioaddr = NULL;
+	void __iomem *ioaddr = NULL;
 	struct net_device *dev;
 	struct tc35815_local *lp;
 	int rc;
@@ -572,20 +668,20 @@ static int __devinit tc35815_init_one (s
 	static int printed_version;
 	if (!printed_version++) {
 		printk(version);
-		printk(KERN_DEBUG MODNAME ": speed:%d duplex:%d doforce:%d\n",
-		       options.speed, options.duplex, options.doforce);
+		dev_printk(KERN_DEBUG, &pdev->dev,
+			   "speed:%d duplex:%d doforce:%d\n",
+			   options.speed, options.duplex, options.doforce);
 	}
 
 	if (!pdev->irq) {
-		printk (KERN_WARNING MODNAME ": no IRQ assigned (%s).\n",
-			pci_name(pdev));
+		dev_warn(&pdev->dev, "no IRQ assigned.\n");
 		return -ENODEV;
 	}
 
 	/* dev zeroed in alloc_etherdev */
 	dev = alloc_etherdev (sizeof (*lp));
 	if (dev == NULL) {
-		printk (KERN_ERR MODNAME ": unable to alloc new ethernet\n");
+		dev_err(&pdev->dev, "unable to alloc new ethernet\n");
 		return -ENOMEM;
 	}
 	SET_MODULE_OWNER(dev);
@@ -607,14 +703,14 @@ static int __devinit tc35815_init_one (s
 
 	/* make sure PCI base addr 1 is MMIO */
 	if (!(mmio_flags & IORESOURCE_MEM)) {
-		printk (KERN_ERR MODNAME ": region #1 not an MMIO resource, aborting\n");
+		dev_err(&pdev->dev, "region #1 not an MMIO resource, aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
 
 	/* check for weird/broken PCI region reporting */
 	if ((mmio_len < sizeof(struct tc35815_regs))) {
-		printk (KERN_ERR MODNAME ": Invalid PCI region size(s), aborting\n");
+		dev_err(&pdev->dev, "Invalid PCI region size(s), aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
@@ -628,7 +724,7 @@ static int __devinit tc35815_init_one (s
 	/* ioremap MMIO region */
 	ioaddr = ioremap (mmio_start, mmio_len);
 	if (ioaddr == NULL) {
-		printk (KERN_ERR MODNAME ": cannot remap MMIO, aborting\n");
+		dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
 		rc = -EIO;
 		goto err_out_free_res;
 	}
@@ -643,6 +739,13 @@ static int __devinit tc35815_init_one (s
 	dev->ethtool_ops = &tc35815_ethtool_ops;
 	dev->tx_timeout = tc35815_tx_timeout;
 	dev->watchdog_timeo = TC35815_TX_TIMEOUT;
+#ifdef TC35815_NAPI
+	dev->poll = tc35815_poll;
+	dev->weight = NAPI_WEIGHT;
+#endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = tc35815_poll_controller;
+#endif
 
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
@@ -651,12 +754,13 @@ static int __devinit tc35815_init_one (s
 	lp = dev->priv;
 	spin_lock_init(&lp->lock);
 	lp->pci_dev = pdev;
+	lp->boardtype = ent->driver_data;
 
 	lp->msg_enable = NETIF_MSG_TX_ERR | NETIF_MSG_HW | NETIF_MSG_DRV | NETIF_MSG_LINK;
 	pci_set_drvdata(pdev, dev);
 
 	/* Soft reset the chip. */
-	tc35815_chip_reset((struct tc35815_regs*)ioaddr);
+	tc35815_chip_reset(dev);
 
 	/* Retrieve the ethernet address. */
 	tc35815_init_dev_addr(dev);
@@ -665,7 +769,8 @@ static int __devinit tc35815_init_one (s
 	if (rc)
 		goto err_out_unmap;
 
-	printk (KERN_INFO "%s: %s at 0x%lx, "
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
+	printk(KERN_INFO "%s: %s at 0x%lx, "
 		"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
 		"IRQ %d\n",
 		dev->name,
@@ -676,7 +781,7 @@ static int __devinit tc35815_init_one (s
 		dev->dev_addr[4], dev->dev_addr[5],
 		dev->irq);
 
-	init_timer(&lp->timer);
+	setup_timer(&lp->timer, tc35815_timer, (unsigned long) dev);
 	lp->mii.dev = dev;
 	lp->mii.mdio_read = tc_mdio_read;
 	lp->mii.mdio_write = tc_mdio_write;
@@ -726,17 +831,16 @@ tc35815_init_queues(struct net_device *d
 	unsigned long fd_addr;
 
 	if (!lp->fd_buf) {
-		if (sizeof(struct FDesc) +
-		    sizeof(struct BDesc) * RX_BUF_PAGES +
-		    sizeof(struct FDesc) * RX_FD_NUM +
-		    sizeof(struct TxFD) * TX_FD_NUM > PAGE_SIZE * FD_PAGE_NUM) {
-			printk("%s: Invalid Queue Size.\n", dev->name);
-			return -ENOMEM;
-		}
+		BUG_ON(sizeof(struct FDesc) +
+		       sizeof(struct BDesc) * RX_BUF_NUM +
+		       sizeof(struct FDesc) * RX_FD_NUM +
+		       sizeof(struct TxFD) * TX_FD_NUM >
+		       PAGE_SIZE * FD_PAGE_NUM);
 
 		if ((lp->fd_buf = pci_alloc_consistent(lp->pci_dev, PAGE_SIZE * FD_PAGE_NUM, &lp->fd_buf_dma)) == 0)
 			return -ENOMEM;
-		for (i = 0; i < RX_BUF_PAGES; i++) {
+		for (i = 0; i < RX_BUF_NUM; i++) {
+#ifdef TC35815_USE_PACKEDBUFFER
 			if ((lp->data_buf[i] = alloc_rxbuf_page(lp->pci_dev, &lp->data_buf_dma[i])) == NULL) {
 				while (--i >= 0) {
 					free_rxbuf_page(lp->pci_dev,
@@ -744,15 +848,40 @@ tc35815_init_queues(struct net_device *d
 							lp->data_buf_dma[i]);
 					lp->data_buf[i] = NULL;
 				}
-				pci_free_consistent(lp->pci_dev, PAGE_SIZE * FD_PAGE_NUM, lp->fd_buf, lp->fd_buf_dma);
+				pci_free_consistent(lp->pci_dev,
+						    PAGE_SIZE * FD_PAGE_NUM,
+						    lp->fd_buf,
+						    lp->fd_buf_dma);
+				lp->fd_buf = NULL;
+				return -ENOMEM;
+			}
+#else
+			lp->rx_skbs[i].skb =
+				alloc_rxbuf_skb(dev, lp->pci_dev,
+						&lp->rx_skbs[i].skb_dma);
+			if (!lp->rx_skbs[i].skb) {
+				while (--i >= 0) {
+					free_rxbuf_skb(lp->pci_dev,
+						       lp->rx_skbs[i].skb,
+						       lp->rx_skbs[i].skb_dma);
+					lp->rx_skbs[i].skb = NULL;
+				}
+				pci_free_consistent(lp->pci_dev,
+						    PAGE_SIZE * FD_PAGE_NUM,
+						    lp->fd_buf,
+						    lp->fd_buf_dma);
 				lp->fd_buf = NULL;
 				return -ENOMEM;
 			}
+#endif
 		}
-		printk(KERN_DEBUG "%s: FD buf %p DataBuf", dev->name, lp->fd_buf);
-		for (i = 0; i < RX_BUF_PAGES; i++) {
+		printk(KERN_DEBUG "%s: FD buf %p DataBuf",
+		       dev->name, lp->fd_buf);
+#ifdef TC35815_USE_PACKEDBUFFER
+		printk(" DataBuf");
+		for (i = 0; i < RX_BUF_NUM; i++)
 			printk(" %p", lp->data_buf[i]);
-		}
+#endif
 		printk("\n");
 	} else {
 		for (i = 0; i < FD_PAGE_NUM; i++) {
@@ -768,9 +897,7 @@ tc35815_init_queues(struct net_device *d
 		lp->rfd_base[i].fd.FDCtl = cpu_to_le32(FD_CownsFD);
 	}
 	lp->rfd_cur = lp->rfd_base;
-	lp->rfd_limit = (struct RxFD *)(fd_addr -
-					sizeof(struct FDesc) -
-					sizeof(struct BDesc) * 30);
+	lp->rfd_limit = (struct RxFD *)fd_addr - (RX_FD_RESERVE + 1);
 
 	/* Transmit Descriptors */
 	lp->tfd_base = (struct TxFD *)fd_addr;
@@ -787,14 +914,46 @@ tc35815_init_queues(struct net_device *d
 	/* Buffer List (for Receive) */
 	lp->fbl_ptr = (struct FrFD *)fd_addr;
 	lp->fbl_ptr->fd.FDNext = cpu_to_le32(fd_virt_to_bus(lp, lp->fbl_ptr));
-	lp->fbl_ptr->fd.FDCtl = cpu_to_le32(RX_BUF_PAGES | FD_CownsFD);
-	for (i = 0; i < RX_BUF_PAGES; i++) {
+	lp->fbl_ptr->fd.FDCtl = cpu_to_le32(RX_BUF_NUM | FD_CownsFD);
+#ifndef TC35815_USE_PACKEDBUFFER
+	/*
+	 * move all allocated skbs to head of rx_skbs[] array.
+	 * fbl_count mighe not be RX_BUF_NUM if alloc_rxbuf_skb() in
+	 * tc35815_rx() had failed.
+	 */
+	lp->fbl_count = 0;
+	for (i = 0; i < RX_BUF_NUM; i++) {
+		if (lp->rx_skbs[i].skb) {
+			if (i != lp->fbl_count) {
+				lp->rx_skbs[lp->fbl_count].skb =
+					lp->rx_skbs[i].skb;
+				lp->rx_skbs[lp->fbl_count].skb_dma =
+					lp->rx_skbs[i].skb_dma;
+			}
+			lp->fbl_count++;
+		}
+	}
+#endif
+	for (i = 0; i < RX_BUF_NUM; i++) {
+#ifdef TC35815_USE_PACKEDBUFFER
 		lp->fbl_ptr->bd[i].BuffData = cpu_to_le32(lp->data_buf_dma[i]);
+#else
+		if (i >= lp->fbl_count) {
+			lp->fbl_ptr->bd[i].BuffData = 0;
+			lp->fbl_ptr->bd[i].BDCtl = 0;
+			continue;
+		}
+		lp->fbl_ptr->bd[i].BuffData =
+			cpu_to_le32(lp->rx_skbs[i].skb_dma);
+#endif
 		/* BDID is index of FrFD.bd[] */
 		lp->fbl_ptr->bd[i].BDCtl =
-			cpu_to_le32(BD_CownsBD | (i << BD_RxBDID_SHIFT) | PAGE_SIZE);
+			cpu_to_le32(BD_CownsBD | (i << BD_RxBDID_SHIFT) |
+				    RX_BUF_SIZE);
 	}
+#ifdef TC35815_USE_PACKEDBUFFER
 	lp->fbl_curid = 0;
+#endif
 
 	printk(KERN_DEBUG "%s: TxFD %p RxFD %p FrFD %p\n",
 	       dev->name, lp->tfd_base, lp->rfd_base, lp->fbl_ptr);
@@ -808,13 +967,18 @@ tc35815_clear_queues(struct net_device *
 	int i;
 
 	for (i = 0; i < TX_FD_NUM; i++) {
+		u32 fdsystem = le32_to_cpu(lp->tfd_base[i].fd.FDSystem);
 		struct sk_buff *skb =
-			lp->tfd_base[i].fd.FDSystem != cpu_to_le32(0xffffffff) ?
-			lp->tx_skbs[le32_to_cpu(lp->tfd_base[i].fd.FDSystem)].skb : NULL;
+			fdsystem != 0xffffffff ?
+			lp->tx_skbs[fdsystem].skb : NULL;
+#ifdef DEBUG
 		if (lp->tx_skbs[i].skb != skb) {
 			printk("%s: tx_skbs mismatch(%d).\n", dev->name, i);
 			panic_queues(dev);
 		}
+#else
+		BUG_ON(lp->tx_skbs[i].skb != skb);
+#endif
 		if (skb) {
 			pci_unmap_single(lp->pci_dev, lp->tx_skbs[i].skb_dma, skb->len, PCI_DMA_TODEVICE);
 			lp->tx_skbs[i].skb = NULL;
@@ -835,13 +999,18 @@ tc35815_free_queues(struct net_device *d
 
 	if (lp->tfd_base) {
 		for (i = 0; i < TX_FD_NUM; i++) {
+			u32 fdsystem = le32_to_cpu(lp->tfd_base[i].fd.FDSystem);
 			struct sk_buff *skb =
-				lp->tfd_base[i].fd.FDSystem != cpu_to_le32(0xffffffff) ?
-				lp->tx_skbs[le32_to_cpu(lp->tfd_base[i].fd.FDSystem)].skb : NULL;
+				fdsystem != 0xffffffff ?
+				lp->tx_skbs[fdsystem].skb : NULL;
+#ifdef DEBUG
 			if (lp->tx_skbs[i].skb != skb) {
 				printk("%s: tx_skbs mismatch(%d).\n", dev->name, i);
 				panic_queues(dev);
 			}
+#else
+			BUG_ON(lp->tx_skbs[i].skb != skb);
+#endif
 			if (skb) {
 				dev_kfree_skb(skb);
 				pci_unmap_single(lp->pci_dev, lp->tx_skbs[i].skb_dma, skb->len, PCI_DMA_TODEVICE);
@@ -857,12 +1026,20 @@ tc35815_free_queues(struct net_device *d
 	lp->rfd_cur = NULL;
 	lp->fbl_ptr = NULL;
 
-	for (i = 0; i < RX_BUF_PAGES; i++) {
+	for (i = 0; i < RX_BUF_NUM; i++) {
+#ifdef TC35815_USE_PACKEDBUFFER
 		if (lp->data_buf[i]) {
 			free_rxbuf_page(lp->pci_dev,
 					lp->data_buf[i], lp->data_buf_dma[i]);
 			lp->data_buf[i] = NULL;
 		}
+#else
+		if (lp->rx_skbs[i].skb) {
+			free_rxbuf_skb(lp->pci_dev, lp->rx_skbs[i].skb,
+				       lp->rx_skbs[i].skb_dma);
+			lp->rx_skbs[i].skb = NULL;
+		}
+#endif
 	}
 	if (lp->fd_buf) {
 		pci_free_consistent(lp->pci_dev, PAGE_SIZE * FD_PAGE_NUM,
@@ -908,6 +1085,7 @@ dump_rxfd(struct RxFD *fd)
 	return bd_count;
 }
 
+#if defined(DEBUG) || defined(TC35815_USE_PACKEDBUFFER)
 static void
 dump_frfd(struct FrFD *fd)
 {
@@ -918,13 +1096,15 @@ dump_frfd(struct FrFD *fd)
 	       le32_to_cpu(fd->fd.FDStat),
 	       le32_to_cpu(fd->fd.FDCtl));
 	printk("BD: ");
-	for (i = 0; i < RX_BUF_PAGES; i++)
+	for (i = 0; i < RX_BUF_NUM; i++)
 		printk(" %08x %08x",
 		       le32_to_cpu(fd->bd[i].BuffData),
 		       le32_to_cpu(fd->bd[i].BDCtl));
 	printk("\n");
 }
+#endif
 
+#ifdef DEBUG
 static void
 panic_queues(struct net_device *dev)
 {
@@ -945,6 +1125,7 @@ panic_queues(struct net_device *dev)
 	dump_frfd(lp->fbl_ptr);
 	panic("%s: Illegal queue state.", dev->name);
 }
+#endif
 
 static void print_eth(char *add)
 {
@@ -969,7 +1150,6 @@ static void tc35815_restart(struct net_d
 {
 	struct tc35815_local *lp = dev->priv;
 	int pid = lp->phy_addr;
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
 	int do_phy_reset = 1;
 	del_timer(&lp->timer);		/* Kill if running	*/
 
@@ -990,7 +1170,7 @@ static void tc35815_restart(struct net_d
 			printk(KERN_ERR "%s: BMCR reset failed.\n", dev->name);
 	}
 
-	tc35815_chip_reset(tr);
+	tc35815_chip_reset(dev);
 	tc35815_clear_queues(dev);
 	tc35815_chip_init(dev);
 	/* Reconfigure CAM again since tc35815_chip_init() initialize it. */
@@ -1000,7 +1180,8 @@ static void tc35815_restart(struct net_d
 static void tc35815_tx_timeout(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 
 	printk(KERN_WARNING "%s: transmit timed out, status %#x\n",
 	       dev->name, tc_readl(&tr->Tx_Stat));
@@ -1048,7 +1229,7 @@ tc35815_open(struct net_device *dev)
 	}
 
 	del_timer(&lp->timer);		/* Kill if running	*/
-	tc35815_chip_reset((struct tc35815_regs*)dev->base_addr);
+	tc35815_chip_reset(dev);
 
 	if (tc35815_init_queues(dev) != 0) {
 		free_irq(dev->irq, dev);
@@ -1076,9 +1257,8 @@ tc35815_open(struct net_device *dev)
 static int tc35815_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
-	short length = skb->len;
 	struct TxFD *txfd;
+	unsigned long flags;
 
 	/* If some error occurs while trying to transmit this
 	 * packet, you should return '1' from this function.
@@ -1094,29 +1274,36 @@ static int tc35815_send_packet(struct sk
 	 * hardware interrupt handler.  Queue flow control is
 	 * thus managed under this lock as well.
 	 */
-	spin_lock_irq(&lp->lock);
+	spin_lock_irqsave(&lp->lock, flags);
 
-	/*add to ring */
-	txfd = &lp->tfd_base[lp->tfd_start];
-
-	/* failsafe... */
-	if (lp->tfd_start != lp->tfd_end)
+	/* failsafe... (handle txdone now if half of FDs are used) */
+	if ((lp->tfd_start + TX_FD_NUM - lp->tfd_end) % TX_FD_NUM >
+	    TX_FD_NUM / 2)
 		tc35815_txdone(dev);
 
 	if (netif_msg_pktdata(lp))
 		print_eth(skb->data);
+#ifdef DEBUG
 	if (lp->tx_skbs[lp->tfd_start].skb) {
 		printk("%s: tx_skbs conflict.\n", dev->name);
 		panic_queues(dev);
 	}
+#else
+	BUG_ON(lp->tx_skbs[lp->tfd_start].skb);
+#endif
 	lp->tx_skbs[lp->tfd_start].skb = skb;
 	lp->tx_skbs[lp->tfd_start].skb_dma = pci_map_single(lp->pci_dev, skb->data, skb->len, PCI_DMA_TODEVICE);
+
+	/*add to ring */
+	txfd = &lp->tfd_base[lp->tfd_start];
 	txfd->bd.BuffData = cpu_to_le32(lp->tx_skbs[lp->tfd_start].skb_dma);
-	txfd->bd.BDCtl = cpu_to_le32(length);
+	txfd->bd.BDCtl = cpu_to_le32(skb->len);
 	txfd->fd.FDSystem = cpu_to_le32(lp->tfd_start);
 	txfd->fd.FDCtl = cpu_to_le32(FD_CownsFD | (1 << FD_BDCnt_SHIFT));
 
 	if (lp->tfd_start == lp->tfd_end) {
+		struct tc35815_regs __iomem *tr =
+			(struct tc35815_regs __iomem *)dev->base_addr;
 		/* Start DMA Transmitter. */
 		txfd->fd.FDNext |= cpu_to_le32(FD_Next_EOL);
 #ifdef GATHER_TXINT
@@ -1152,13 +1339,13 @@ static int tc35815_send_packet(struct sk
 	 * is when the transmit statistics are updated.
 	 */
 
-	spin_unlock_irq(&lp->lock);
+	spin_unlock_irqrestore(&lp->lock, flags);
 	return 0;
 }
 
 #define FATAL_ERROR_INT \
 	(Int_IntPCI | Int_DmParErr | Int_IntNRAbt)
-static void tc35815_fatal_error_interrupt(struct net_device *dev, int status)
+static void tc35815_fatal_error_interrupt(struct net_device *dev, u32 status)
 {
 	static int count;
 	printk(KERN_WARNING "%s: Fatal Error Intterrupt (%#x):",
@@ -1175,32 +1362,23 @@ static void tc35815_fatal_error_interrup
 	printk(KERN_WARNING "%s: Resetting ...\n", dev->name);
 	/* Try to restart the adaptor. */
 	tc35815_restart(dev);
-	return;
 }
 
-/*
- * The typical workload of the driver:
- * Handle the network interface interrupts.
- */
-static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
+#ifdef TC35815_NAPI
+static int tc35815_do_interrupt(struct net_device *dev, u32 status, int limit)
+#else
+static int tc35815_do_interrupt(struct net_device *dev, u32 status)
+#endif
 {
-	struct net_device *dev = dev_id;
-	struct tc35815_regs *tr;
-	struct tc35815_local *lp;
-	int status, handled = 0;
-
-	tr = (struct tc35815_regs *)dev->base_addr;
-	lp = dev->priv;
-
-	spin_lock(&lp->lock);
-	status = tc_readl(&tr->Int_Src);
-	tc_writel(status, &tr->Int_Src);	/* write to clear */
+	struct tc35815_local *lp = dev->priv;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	int ret = -1;
 
 	/* Fatal errors... */
 	if (status & FATAL_ERROR_INT) {
 		tc35815_fatal_error_interrupt(dev, status);
-		spin_unlock(&lp->lock);
-		return IRQ_HANDLED;
+		return 0;
 	}
 	/* recoverable errors */
 	if (status & Int_IntFDAEx) {
@@ -1210,7 +1388,7 @@ static irqreturn_t tc35815_interrupt(int
 		       "%s: Free Descriptor Area Exhausted (%#x).\n",
 		       dev->name, status);
 		lp->stats.rx_dropped++;
-		handled = 1;
+		ret = 0;
 	}
 	if (status & Int_IntBLEx) {
 		/* disable BLEx int. (until we make rooms...) */
@@ -1219,51 +1397,112 @@ static irqreturn_t tc35815_interrupt(int
 		       "%s: Buffer List Exhausted (%#x).\n",
 		       dev->name, status);
 		lp->stats.rx_dropped++;
-		handled = 1;
+		ret = 0;
 	}
 	if (status & Int_IntExBD) {
 		printk(KERN_WARNING
 		       "%s: Excessive Buffer Descriptiors (%#x).\n",
 		       dev->name, status);
 		lp->stats.rx_length_errors++;
-		handled = 1;
+		ret = 0;
 	}
 
 	/* normal notification */
 	if (status & Int_IntMacRx) {
 		/* Got a packet(s). */
-		lp->lstats.rx_ints++;
+#ifdef TC35815_NAPI
+		ret = tc35815_rx(dev, limit);
+#else
 		tc35815_rx(dev);
-		handled = 1;
+		ret = 0;
+#endif
+		lp->lstats.rx_ints++;
 	}
 	if (status & Int_IntMacTx) {
 		/* Transmit complete. */
 		lp->lstats.tx_ints++;
 		tc35815_txdone(dev);
 		netif_wake_queue(dev);
-		handled = 1;
+		ret = 0;
+	}
+	return ret;
+}
+
+/*
+ * The typical workload of the driver:
+ * Handle the network interface interrupts.
+ */
+static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+#ifdef TC35815_NAPI
+	u32 dmactl = tc_readl(&tr->DMA_Ctl);
+
+	if (!(dmactl & DMA_IntMask)) {
+		/* disable interrupts */
+		tc_writel(dmactl | DMA_IntMask, &tr->DMA_Ctl);
+		if (netif_rx_schedule_prep(dev))
+			__netif_rx_schedule(dev);
+		else {
+			printk(KERN_ERR "%s: interrupt taken in poll\n",
+			       dev->name);
+			BUG();
+		}
+		(void)tc_readl(&tr->Int_Src);	/* flush */
+		return IRQ_HANDLED;
 	}
+	return IRQ_NONE;
+#else
+	struct tc35815_local *lp = dev->priv;
+	int handled;
+	u32 status;
+
+	spin_lock(&lp->lock);
+	status = tc_readl(&tr->Int_Src);
+	tc_writel(status, &tr->Int_Src);	/* write to clear */
+	handled = tc35815_do_interrupt(dev, status);
 	(void)tc_readl(&tr->Int_Src);	/* flush */
 	spin_unlock(&lp->lock);
-	return IRQ_RETVAL(handled);
+	return IRQ_RETVAL(handled >= 0);
+#endif /* TC35815_NAPI */
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void tc35815_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	tc35815_interrupt(dev->irq, dev);
+	enable_irq(dev->irq);
+}
+#endif
+
 /* We have a good packet(s), get it/them out of the buffers. */
+#ifdef TC35815_NAPI
+static int
+tc35815_rx(struct net_device *dev, int limit)
+#else
 static void
 tc35815_rx(struct net_device *dev)
+#endif
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
 	unsigned int fdctl;
 	int i;
 	int buf_free_count = 0;
 	int fd_free_count = 0;
+#ifdef TC35815_NAPI
+	int received = 0;
+#endif
 
 	while (!((fdctl = le32_to_cpu(lp->rfd_cur->fd.FDCtl)) & FD_CownsFD)) {
 		int status = le32_to_cpu(lp->rfd_cur->fd.FDStat);
 		int pkt_len = fdctl & FD_FDLength_MASK;
-		struct RxFD *next_rfd;
 		int bd_count = (fdctl & FD_BDCnt_MASK) >> FD_BDCnt_SHIFT;
+#ifdef DEBUG
+		struct RxFD *next_rfd;
+#endif
 #if (RX_CTL_CMD & Rx_StripCRC) == 0
 		pkt_len -= 4;
 #endif
@@ -1271,11 +1510,19 @@ tc35815_rx(struct net_device *dev)
 		if (netif_msg_rx_status(lp))
 			dump_rxfd(lp->rfd_cur);
 		if (status & Rx_Good) {
-			/* Malloc up new buffer. */
 			struct sk_buff *skb;
 			unsigned char *data;
-			int cur_bd, offset;
+			int cur_bd;
+#ifdef TC35815_USE_PACKEDBUFFER
+			int offset;
+#endif
 
+#ifdef TC35815_NAPI
+			if (--limit < 0)
+				break;
+#endif
+#ifdef TC35815_USE_PACKEDBUFFER
+			BUG_ON(bd_count > 2);
 			skb = dev_alloc_skb(pkt_len + 2); /* +2: for reserve */
 			if (skb == NULL) {
 				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n",
@@ -1307,10 +1554,44 @@ tc35815_rx(struct net_device *dev)
 				offset += len;
 				cur_bd++;
 			}
+#else /* TC35815_USE_PACKEDBUFFER */
+			BUG_ON(bd_count > 1);
+			cur_bd = (le32_to_cpu(lp->rfd_cur->bd[0].BDCtl)
+				  & BD_RxBDID_MASK) >> BD_RxBDID_SHIFT;
+#ifdef DEBUG
+			if (cur_bd >= RX_BUF_NUM) {
+				printk("%s: invalid BDID.\n", dev->name);
+				panic_queues(dev);
+			}
+			BUG_ON(lp->rx_skbs[cur_bd].skb_dma !=
+			       (le32_to_cpu(lp->rfd_cur->bd[0].BuffData) & ~3));
+			if (!lp->rx_skbs[cur_bd].skb) {
+				printk("%s: NULL skb.\n", dev->name);
+				panic_queues(dev);
+			}
+#else
+			BUG_ON(cur_bd >= RX_BUF_NUM);
+#endif
+			skb = lp->rx_skbs[cur_bd].skb;
+			prefetch(skb->data);
+			lp->rx_skbs[cur_bd].skb = NULL;
+			lp->fbl_count--;
+			pci_unmap_single(lp->pci_dev,
+					 lp->rx_skbs[cur_bd].skb_dma,
+					 RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			if (!HAVE_DMA_RXALIGN(lp))
+				memmove(skb->data, skb->data - 2, pkt_len);
+			data = skb_put(skb, pkt_len);
+#endif /* TC35815_USE_PACKEDBUFFER */
 			if (netif_msg_pktdata(lp))
 				print_eth(data);
 			skb->protocol = eth_type_trans(skb, dev);
+#ifdef TC35815_NAPI
+			netif_receive_skb(skb);
+			received++;
+#else
 			netif_rx(skb);
+#endif
 			dev->last_rx = jiffies;
 			lp->stats.rx_packets++;
 			lp->stats.rx_bytes += pkt_len;
@@ -1334,59 +1615,149 @@ tc35815_rx(struct net_device *dev)
 			int bdctl = le32_to_cpu(lp->rfd_cur->bd[bd_count - 1].BDCtl);
 			unsigned char id =
 				(bdctl & BD_RxBDID_MASK) >> BD_RxBDID_SHIFT;
-			if (id >= RX_BUF_PAGES) {
+#ifdef DEBUG
+			if (id >= RX_BUF_NUM) {
 				printk("%s: invalid BDID.\n", dev->name);
 				panic_queues(dev);
 			}
+#else
+			BUG_ON(id >= RX_BUF_NUM);
+#endif
 			/* free old buffers */
-			while (lp->fbl_curid != id) {
-				bdctl = le32_to_cpu(lp->fbl_ptr->bd[lp->fbl_curid].BDCtl);
+#ifdef TC35815_USE_PACKEDBUFFER
+			while (lp->fbl_curid != id)
+#else
+			while (lp->fbl_count < RX_BUF_NUM)
+#endif
+			{
+#ifdef TC35815_USE_PACKEDBUFFER
+				unsigned char curid = lp->fbl_curid;
+#else
+				unsigned char curid =
+					(id + 1 + lp->fbl_count) % RX_BUF_NUM;
+#endif
+				struct BDesc *bd = &lp->fbl_ptr->bd[curid];
+#ifdef DEBUG
+				bdctl = le32_to_cpu(bd->BDCtl);
 				if (bdctl & BD_CownsBD) {
 					printk("%s: Freeing invalid BD.\n",
 					       dev->name);
 					panic_queues(dev);
 				}
+#endif
 				/* pass BD to controler */
+#ifndef TC35815_USE_PACKEDBUFFER
+				if (!lp->rx_skbs[curid].skb) {
+					lp->rx_skbs[curid].skb =
+						alloc_rxbuf_skb(dev,
+								lp->pci_dev,
+								&lp->rx_skbs[curid].skb_dma);
+					if (!lp->rx_skbs[curid].skb)
+						break; /* try on next reception */
+					bd->BuffData = cpu_to_le32(lp->rx_skbs[curid].skb_dma);
+				}
+#endif /* TC35815_USE_PACKEDBUFFER */
 				/* Note: BDLength was modified by chip. */
-				lp->fbl_ptr->bd[lp->fbl_curid].BDCtl =
-					cpu_to_le32(BD_CownsBD |
-						    (lp->fbl_curid << BD_RxBDID_SHIFT) |
-						    PAGE_SIZE);
-				lp->fbl_curid =
-					(lp->fbl_curid + 1) % RX_BUF_PAGES;
+				bd->BDCtl = cpu_to_le32(BD_CownsBD |
+							(curid << BD_RxBDID_SHIFT) |
+							RX_BUF_SIZE);
+#ifdef TC35815_USE_PACKEDBUFFER
+				lp->fbl_curid = (curid + 1) % RX_BUF_NUM;
 				if (netif_msg_rx_status(lp)) {
 					printk("%s: Entering new FBD %d\n",
 					       dev->name, lp->fbl_curid);
 					dump_frfd(lp->fbl_ptr);
 				}
+#else
+				lp->fbl_count++;
+#endif
 				buf_free_count++;
 			}
 		}
 
 		/* put RxFD back to controller */
-		next_rfd = fd_bus_to_virt(lp, le32_to_cpu(lp->rfd_cur->fd.FDNext));
+#ifdef DEBUG
+		next_rfd = fd_bus_to_virt(lp,
+					  le32_to_cpu(lp->rfd_cur->fd.FDNext));
 		if (next_rfd < lp->rfd_base || next_rfd > lp->rfd_limit) {
 			printk("%s: RxFD FDNext invalid.\n", dev->name);
 			panic_queues(dev);
 		}
+#endif
 		for (i = 0; i < (bd_count + 1) / 2 + 1; i++) {
 			/* pass FD to controler */
-			lp->rfd_cur->fd.FDNext = cpu_to_le32(0xdeaddead);	/* for debug */
+#ifdef DEBUG
+			lp->rfd_cur->fd.FDNext = cpu_to_le32(0xdeaddead);
+#else
+			lp->rfd_cur->fd.FDNext = cpu_to_le32(FD_Next_EOL);
+#endif
 			lp->rfd_cur->fd.FDCtl = cpu_to_le32(FD_CownsFD);
 			lp->rfd_cur++;
 			fd_free_count++;
 		}
-
-		lp->rfd_cur = next_rfd;
+		if (lp->rfd_cur > lp->rfd_limit)
+			lp->rfd_cur = lp->rfd_base;
+#ifdef DEBUG
+		if (lp->rfd_cur != next_rfd)
+			printk("rfd_cur = %p, next_rfd %p\n",
+			       lp->rfd_cur, next_rfd);
+#endif
 	}
 
 	/* re-enable BL/FDA Exhaust interrupts. */
 	if (fd_free_count) {
-		tc_writel(tc_readl(&tr->Int_En) | Int_FDAExEn, &tr->Int_En);
+		struct tc35815_regs __iomem *tr =
+			(struct tc35815_regs __iomem *)dev->base_addr;
+		u32 en, en_old = tc_readl(&tr->Int_En);
+		en = en_old | Int_FDAExEn;
 		if (buf_free_count)
-			tc_writel(tc_readl(&tr->Int_En) | Int_BLExEn, &tr->Int_En);
+			en |= Int_BLExEn;
+		if (en != en_old)
+			tc_writel(en, &tr->Int_En);
 	}
+#ifdef TC35815_NAPI
+	return received;
+#endif
+}
+
+#ifdef TC35815_NAPI
+static int
+tc35815_poll(struct net_device *dev, int *budget)
+{
+	struct tc35815_local *lp = dev->priv;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	int limit = min(*budget, dev->quota);
+	int received = 0, handled;
+	u32 status;
+
+	spin_lock(&lp->lock);
+	status = tc_readl(&tr->Int_Src);
+	do {
+		tc_writel(status, &tr->Int_Src);	/* write to clear */
+
+		handled = tc35815_do_interrupt(dev, status, limit);
+		if (handled >= 0) {
+			received += handled;
+			limit -= handled;
+			if (limit <= 0)
+				break;
+		}
+		status = tc_readl(&tr->Int_Src);
+	} while (status);
+	spin_unlock(&lp->lock);
+
+	dev->quota -= received;
+	*budget -= received;
+	if (limit <= 0)
+		return 1;
+
+	netif_rx_complete(dev);
+	/* enable interrupts */
+	tc_writel(tc_readl(&tr->DMA_Ctl) & ~DMA_IntMask, &tr->DMA_Ctl);
+	return 0;
 }
+#endif
 
 #ifdef NO_CHECK_CARRIER
 #define TX_STA_ERR	(Tx_ExColl|Tx_Under|Tx_Defer|Tx_LateColl|Tx_TxPar|Tx_SQErr)
@@ -1406,12 +1777,17 @@ tc35815_check_tx_stat(struct net_device
 	if (status & Tx_TxColl_MASK)
 		lp->stats.collisions += status & Tx_TxColl_MASK;
 
+#ifndef NO_CHECK_CARRIER
+	/* TX4939 does not have NCarr */
+	if (lp->boardtype == TC35815_TX4939)
+		status &= ~Tx_NCarr;
 #ifdef WORKAROUND_LOSTCAR
 	/* WORKAROUND: ignore LostCrS in full duplex operation */
 	if ((lp->timer_state != asleep && lp->timer_state != lcheck)
 	    || lp->fullduplex)
 		status &= ~Tx_NCarr;
 #endif
+#endif
 
 	if (!(status & TX_STA_ERR)) {
 		/* no error. */
@@ -1428,13 +1804,13 @@ tc35815_check_tx_stat(struct net_device
 		lp->stats.tx_fifo_errors++;
 		msg = "Tx FIFO Underrun.";
 		if (lp->lstats.tx_underrun < TX_THRESHOLD_KEEP_LIMIT) {
-		  lp->lstats.tx_underrun++;
-		  if (lp->lstats.tx_underrun >= TX_THRESHOLD_KEEP_LIMIT) {
-		    struct tc35815_regs *tr =
-		      (struct tc35815_regs *)dev->base_addr;
-		    tc_writel(TX_THRESHOLD_MAX, &tr->TxThrsh);
-		    msg = "Tx FIFO Underrun.Change Tx threshold to max.";
-		  }
+			lp->lstats.tx_underrun++;
+			if (lp->lstats.tx_underrun >= TX_THRESHOLD_KEEP_LIMIT) {
+				struct tc35815_regs __iomem *tr =
+					(struct tc35815_regs __iomem *)dev->base_addr;
+				tc_writel(TX_THRESHOLD_MAX, &tr->TxThrsh);
+				msg = "Tx FIFO Underrun.Change Tx threshold to max.";
+			}
 		}
 	}
 	if (status & Tx_Defer) {
@@ -1470,7 +1846,6 @@ static void
 tc35815_txdone(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
 	struct TxFD *txfd;
 	unsigned int fdctl;
 
@@ -1480,6 +1855,7 @@ tc35815_txdone(struct net_device *dev)
 		int status = le32_to_cpu(txfd->fd.FDStat);
 		struct sk_buff *skb;
 		unsigned long fdnext = le32_to_cpu(txfd->fd.FDNext);
+		u32 fdsystem = le32_to_cpu(txfd->fd.FDSystem);
 
 		if (netif_msg_tx_done(lp)) {
 			printk("%s: complete TxFD.\n", dev->name);
@@ -1487,39 +1863,53 @@ tc35815_txdone(struct net_device *dev)
 		}
 		tc35815_check_tx_stat(dev, status);
 
-		skb = le32_to_cpu(txfd->fd.FDSystem) != cpu_to_le32(0xffffffff) ?
-			lp->tx_skbs[le32_to_cpu(txfd->fd.FDSystem)].skb : NULL;
+		skb = fdsystem != 0xffffffff ?
+			lp->tx_skbs[fdsystem].skb : NULL;
+#ifdef DEBUG
 		if (lp->tx_skbs[lp->tfd_end].skb != skb) {
 			printk("%s: tx_skbs mismatch.\n", dev->name);
 			panic_queues(dev);
 		}
+#else
+		BUG_ON(lp->tx_skbs[lp->tfd_end].skb != skb);
+#endif
 		if (skb) {
 			lp->stats.tx_bytes += skb->len;
 			pci_unmap_single(lp->pci_dev, lp->tx_skbs[lp->tfd_end].skb_dma, skb->len, PCI_DMA_TODEVICE);
 			lp->tx_skbs[lp->tfd_end].skb = NULL;
 			lp->tx_skbs[lp->tfd_end].skb_dma = 0;
+#ifdef TC35815_NAPI
+			dev_kfree_skb_any(skb);
+#else
 			dev_kfree_skb_irq(skb);
+#endif
 		}
 		txfd->fd.FDSystem = cpu_to_le32(0xffffffff);
 
 		lp->tfd_end = (lp->tfd_end + 1) % TX_FD_NUM;
 		txfd = &lp->tfd_base[lp->tfd_end];
+#ifdef DEBUG
 		if ((fdnext & ~FD_Next_EOL) != fd_virt_to_bus(lp, txfd)) {
 			printk("%s: TxFD FDNext invalid.\n", dev->name);
 			panic_queues(dev);
 		}
+#endif
 		if (fdnext & FD_Next_EOL) {
 			/* DMA Transmitter has been stopping... */
 			if (lp->tfd_end != lp->tfd_start) {
+				struct tc35815_regs __iomem *tr =
+					(struct tc35815_regs __iomem *)dev->base_addr;
 				int head = (lp->tfd_start + TX_FD_NUM - 1) % TX_FD_NUM;
 				struct TxFD* txhead = &lp->tfd_base[head];
 				int qlen = (lp->tfd_start + TX_FD_NUM
 					    - lp->tfd_end) % TX_FD_NUM;
 
+#ifdef DEBUG
 				if (!(le32_to_cpu(txfd->fd.FDCtl) & FD_CownsFD)) {
 					printk("%s: TxFD FDCtl invalid.\n", dev->name);
 					panic_queues(dev);
 				}
+#endif
 				/* log max queue length */
 				if (lp->lstats.max_tx_qlen < qlen)
 					lp->lstats.max_tx_qlen = qlen;
@@ -1559,7 +1949,7 @@ tc35815_close(struct net_device *dev)
 	/* Flush the Tx and disable Rx here. */
 
 	del_timer(&lp->timer);		/* Kill if running	*/
-	tc35815_chip_reset((struct tc35815_regs*)dev->base_addr);
+	tc35815_chip_reset(dev);
 	free_irq(dev->irq, dev);
 
 	tc35815_free_queues(dev);
@@ -1575,7 +1965,8 @@ tc35815_close(struct net_device *dev)
 static struct net_device_stats *tc35815_get_stats(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 	if (netif_running(dev)) {
 		/* Update the statistics from the device registers. */
 		lp->stats.rx_missed_errors = tc_readl(&tr->Miss_Cnt);
@@ -1587,15 +1978,16 @@ static struct net_device_stats *tc35815_
 static void tc35815_set_cam_entry(struct net_device *dev, int index, unsigned char *addr)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 	int cam_index = index * 6;
-	unsigned long cam_data;
-	unsigned long saved_addr;
+	u32 cam_data;
+	u32 saved_addr;
 	saved_addr = tc_readl(&tr->CAM_Adr);
 
 	if (netif_msg_hw(lp)) {
 		int i;
-		printk(KERN_DEBUG "%s: CAM %d:", MODNAME, index);
+		printk(KERN_DEBUG "%s: CAM %d:", dev->name, index);
 		for (i = 0; i < 6; i++)
 			printk(" %02x", addr[i]);
 		printk("\n");
@@ -1636,7 +2028,8 @@ static void tc35815_set_cam_entry(struct
 static void
 tc35815_set_multicast_list(struct net_device *dev)
 {
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 
 	if (dev->flags&IFF_PROMISC)
 	{
@@ -1789,7 +2182,7 @@ static void tc35815_get_strings(struct n
 	memcpy(data, ethtool_stats_keys, sizeof(ethtool_stats_keys));
 }
 
-static struct ethtool_ops tc35815_ethtool_ops = {
+static const struct ethtool_ops tc35815_ethtool_ops = {
 	.get_drvinfo		= tc35815_get_drvinfo,
 	.get_settings		= tc35815_get_settings,
 	.set_settings		= tc35815_set_settings,
@@ -1800,6 +2193,7 @@ static struct ethtool_ops tc35815_ethtoo
 	.get_strings		= tc35815_get_strings,
 	.get_stats_count	= tc35815_get_stats_count,
 	.get_ethtool_stats	= tc35815_get_ethtool_stats,
+	.get_perm_addr		= ethtool_op_get_perm_addr,
 };
 
 static int tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
@@ -1819,8 +2213,9 @@ static int tc35815_ioctl(struct net_devi
 
 static int tc_mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
-	unsigned long data;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
+	u32 data;
 	tc_writel(MD_CA_Busy | (phy_id << 5) | location, &tr->MD_CA);
 	while (tc_readl(&tr->MD_CA) & MD_CA_Busy)
 		;
@@ -1831,7 +2226,8 @@ static int tc_mdio_read(struct net_devic
 static void tc_mdio_write(struct net_device *dev, int phy_id, int location,
 			  int val)
 {
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 	tc_writel(val, &tr->MD_Data);
 	tc_writel(MD_CA_Busy | MD_CA_Wr | (phy_id << 5) | location, &tr->MD_CA);
 	while (tc_readl(&tr->MD_CA) & MD_CA_Busy)
@@ -1952,17 +2348,18 @@ static void tc35815_display_forced_link_
 static void tc35815_set_link_modes(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 	int pid = lp->phy_addr;
 	unsigned short bmcr, lpa;
+	int speed;
 
 	if (lp->timer_state == arbwait) {
+		lpa = tc_mdio_read(dev, pid, MII_LPA);
+		bmcr = tc_mdio_read(dev, pid, MII_BMCR);
 		printk(KERN_DEBUG "%s: MII BMCR %04x BMSR %04x LPA %04x\n",
 		       dev->name,
-		       tc_mdio_read(dev, pid, MII_BMCR),
-		       tc_mdio_read(dev, pid, MII_BMSR),
-		       tc_mdio_read(dev, pid, MII_LPA));
-		lpa = tc_mdio_read(dev, pid, MII_LPA);
+		       bmcr, tc_mdio_read(dev, pid, MII_BMSR), lpa);
 		if (!(lpa & (LPA_10HALF | LPA_10FULL |
 			     LPA_100HALF | LPA_100FULL))) {
 			/* fall back to 10HALF */
@@ -1970,11 +2367,14 @@ static void tc35815_set_link_modes(struc
 			       dev->name, lpa);
 			lpa = LPA_10HALF;
 		}
-		bmcr = tc_mdio_read(dev, pid, MII_BMCR);
 		if (options.duplex ? (bmcr & BMCR_FULLDPLX) : (lpa & (LPA_100FULL | LPA_10FULL)))
 			lp->fullduplex = 1;
 		else
 			lp->fullduplex = 0;
+		if (options.speed ? (bmcr & BMCR_SPEED100) : (lpa & (LPA_100HALF | LPA_100FULL)))
+			speed = 100;
+		else
+			speed = 10;
 	} else {
 		/* Forcing a link mode. */
 		bmcr = tc_mdio_read(dev, pid, MII_BMCR);
@@ -1982,6 +2382,10 @@ static void tc35815_set_link_modes(struc
 			lp->fullduplex = 1;
 		else
 			lp->fullduplex = 0;
+		if (bmcr & BMCR_SPEED100)
+			speed = 100;
+		else
+			speed = 10;
 	}
 
 	tc_writel(tc_readl(&tr->MAC_Ctl) | MAC_HaltReq, &tr->MAC_Ctl);
@@ -1992,10 +2396,17 @@ static void tc35815_set_link_modes(struc
 	}
 	tc_writel(tc_readl(&tr->MAC_Ctl) & ~MAC_HaltReq, &tr->MAC_Ctl);
 
+	/* TX4939 PCFG.SPEEDn bit will be changed on NETDEV_CHANGE event. */
+
+#ifndef NO_CHECK_CARRIER
+	/* TX4939 does not have EnLCarr */
+	if (lp->boardtype != TC35815_TX4939) {
 #ifdef WORKAROUND_LOSTCAR
-	/* WORKAROUND: enable LostCrS only if half duplex operation */
-	if (!lp->fullduplex)
-		tc_writel(tc_readl(&tr->Tx_Ctl) | Tx_EnLCarr, &tr->Tx_Ctl);
+		/* WORKAROUND: enable LostCrS only if half duplex operation */
+		if (!lp->fullduplex && lp->boardtype != TC35815_TX4939)
+			tc_writel(tc_readl(&tr->Tx_Ctl) | Tx_EnLCarr, &tr->Tx_Ctl);
+#endif
+	}
 #endif
 	lp->mii.full_duplex = lp->fullduplex;
 }
@@ -2201,7 +2612,7 @@ static void tc35815_timer(unsigned long
 	}
 
 	if (restart_timer) {
-		lp->timer.expires = jiffies + ((12 * HZ)/10); /* 1.2s */
+		lp->timer.expires = jiffies + msecs_to_jiffies(1200);
 		add_timer(&lp->timer);
 	}
 out:
@@ -2329,9 +2740,7 @@ force_link:
 
 	del_timer(&lp->timer);
 	lp->timer_ticks = 0;
-	lp->timer.expires = jiffies + (12 * HZ)/10;  /* 1.2 sec. */
-	lp->timer.data = (unsigned long) dev;
-	lp->timer.function = &tc35815_timer;
+	lp->timer.expires = jiffies + msecs_to_jiffies(1200);
 	add_timer(&lp->timer);
 }
 
@@ -2396,8 +2805,10 @@ static void tc35815_phy_chip_init(struct
 	tc35815_start_auto_negotiation(dev, ep);
 }
 
-static void tc35815_chip_reset(struct tc35815_regs *tr)
+static void tc35815_chip_reset(struct net_device *dev)
 {
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 	int i;
 	/* reset the controller */
 	tc_writel(MAC_Reset, &tr->MAC_Ctl);
@@ -2405,7 +2816,7 @@ static void tc35815_chip_reset(struct tc
 	i = 0;
 	while (tc_readl(&tr->MAC_Ctl) & MAC_Reset) {
 		if (i++ > 100) {
-			printk(KERN_ERR "%s: MAC reset failed.\n", MODNAME);
+			printk(KERN_ERR "%s: MAC reset failed.\n", dev->name);
 			break;
 		}
 		mdelay(1);
@@ -2439,7 +2850,8 @@ static void tc35815_chip_reset(struct tc
 static void tc35815_chip_init(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
-	struct tc35815_regs *tr = (struct tc35815_regs *)dev->base_addr;
+	struct tc35815_regs __iomem *tr =
+		(struct tc35815_regs __iomem *)dev->base_addr;
 	unsigned long txctl = TX_CTL_CMD;
 
 	tc35815_phy_chip_init(dev);
@@ -2451,8 +2863,16 @@ static void tc35815_chip_init(struct net
 	tc_writel(CAM_Ena_Bit(CAM_ENTRY_SOURCE), &tr->CAM_Ena);
 	tc_writel(CAM_CompEn | CAM_BroadAcc, &tr->CAM_Ctl);
 
-	tc_writel(DMA_BURST_SIZE, &tr->DMA_Ctl);
+	/* Use DMA_RxAlign_2 to make IP header 4-byte aligned. */
+	if (HAVE_DMA_RXALIGN(lp))
+		tc_writel(DMA_BURST_SIZE | DMA_RxAlign_2, &tr->DMA_Ctl);
+	else
+		tc_writel(DMA_BURST_SIZE, &tr->DMA_Ctl);
+#ifdef TC35815_USE_PACKEDBUFFER
 	tc_writel(RxFrag_EnPack | ETH_ZLEN, &tr->RxFragSize);	/* Packing */
+#else
+	tc_writel(ETH_ZLEN, &tr->RxFragSize);
+#endif
 	tc_writel(0, &tr->TxPollCtr);	/* Batch mode */
 	tc_writel(TX_THRESHOLD, &tr->TxThrsh);
 	tc_writel(INT_EN_CMD, &tr->Int_En);
@@ -2470,23 +2890,69 @@ static void tc35815_chip_init(struct net
 	tc_writel(RX_CTL_CMD, &tr->Rx_Ctl);	/* start MAC receiver */
 
 	/* start MAC transmitter */
+#ifndef NO_CHECK_CARRIER
+	/* TX4939 does not have EnLCarr */
+	if (lp->boardtype == TC35815_TX4939)
+		txctl &= ~Tx_EnLCarr;
 #ifdef WORKAROUND_LOSTCAR
 	/* WORKAROUND: ignore LostCrS in full duplex operation */
 	if ((lp->timer_state != asleep && lp->timer_state != lcheck) ||
 	    lp->fullduplex)
-		txctl = TX_CTL_CMD & ~Tx_EnLCarr;
+		txctl &= ~Tx_EnLCarr;
 #endif
+#endif /* !NO_CHECK_CARRIER */
 #ifdef GATHER_TXINT
 	txctl &= ~Tx_EnComp;	/* disable global tx completion int. */
 #endif
 	tc_writel(txctl, &tr->Tx_Ctl);
 }
 
+#ifdef CONFIG_PM
+static int tc35815_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct tc35815_local *lp = dev->priv;
+	unsigned long flags;
+
+	pci_save_state(pdev);
+	if (!netif_running(dev))
+		return 0;
+	netif_device_detach(dev);
+	spin_lock_irqsave(&lp->lock, flags);
+	del_timer(&lp->timer);		/* Kill if running	*/
+	tc35815_chip_reset(dev);
+	spin_unlock_irqrestore(&lp->lock, flags);
+	pci_set_power_state(pdev, PCI_D3hot);
+	return 0;
+}
+
+static int tc35815_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct tc35815_local *lp = dev->priv;
+	unsigned long flags;
+
+	pci_restore_state(pdev);
+	if (!netif_running(dev))
+		return 0;
+	pci_set_power_state(pdev, PCI_D0);
+	spin_lock_irqsave(&lp->lock, flags);
+	tc35815_restart(dev);
+	spin_unlock_irqrestore(&lp->lock, flags);
+	netif_device_attach(dev);
+	return 0;
+}
+#endif /* CONFIG_PM */
+
 static struct pci_driver tc35815_pci_driver = {
 	.name		= MODNAME,
 	.id_table	= tc35815_pci_tbl,
 	.probe		= tc35815_init_one,
 	.remove		= __devexit_p(tc35815_remove_one),
+#ifdef CONFIG_PM
+	.suspend	= tc35815_suspend,
+	.resume		= tc35815_resume,
+#endif
 };
 
 module_param_named(speed, options.speed, int, 0);
@@ -2496,37 +2962,6 @@ MODULE_PARM_DESC(duplex, "0:auto, 1:half
 module_param_named(doforce, options.doforce, int, 0);
 MODULE_PARM_DESC(doforce, "try force link mode if auto-negotiation failed");
 
-#ifndef MODULE
-static int __init tc35815_setup(char *str)
-{
-	static struct {
-		char *name;
-		int *val;
-	} opts[] = {
-		{ "speed:", &options.speed },
-		{ "duplex:", &options.duplex },
-		{ "doforce:", &options.doforce },
-	};
-	int i;
-	char *p;
-	p = str;
-	while (p) {
-		for (i = 0; i < ARRAY_SIZE(opts); i++) {
-			int optlen = strlen(opts[i].name);
-			if (strncmp(p, opts[i].name, optlen) == 0) {
-				*opts[i].val = simple_strtol(p + optlen, NULL, 0);
-				break;
-			}
-		}
-		p = strchr(p, ',');
-		if (p)
-			p++;
-	}
-	return 1;
-}
-__setup("tc35815=", tc35815_setup);
-#endif
-
 static int __init tc35815_init_module(void)
 {
 	return pci_register_driver(&tc35815_pci_driver);
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 6a58784..d87226b 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1460,6 +1460,7 @@
 #define PCI_VENDOR_ID_TOSHIBA_2		0x102f
 #define PCI_DEVICE_ID_TOSHIBA_TC35815CF	0x0030
 #define PCI_DEVICE_ID_TOSHIBA_TC35815_NWU	0x0031
+#define PCI_DEVICE_ID_TOSHIBA_TC35815_TX4939	0x0032
 #define PCI_DEVICE_ID_TOSHIBA_TC86C001_IDE	0x0105
 #define PCI_DEVICE_ID_TOSHIBA_TC86C001_MISC	0x0108
 #define PCI_DEVICE_ID_TOSHIBA_SPIDER_NET 0x01b3
