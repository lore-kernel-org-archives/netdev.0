From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 1/4] net: fec: move fec_enet_private to header file
Date: Wed, 31 Oct 2012 12:24:49 +0800
Message-ID: <1351657489-24864-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <lznua@gmail.com>, <richardcochran@gmail.com>,
	<shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:36551
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750992Ab2JaFIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 01:08:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new file fec_ptp.c will use fec_enet_private to support 1588 PTP
move such structure to common header file fec.h

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |   73 ------------------------------
 drivers/net/ethernet/freescale/fec.h |   81 ++++++++++++++++++++++++++++++++++
 2 files changed, 81 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index fffd205..d0e1b33 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -140,21 +140,6 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #endif
 #endif /* CONFIG_M5272 */
 
-/* The number of Tx and Rx buffers.  These are allocated from the page
- * pool.  The code may assume these are power of two, so it it best
- * to keep them that size.
- * We don't need to allocate pages for the transmitter.  We just use
- * the skbuffer directly.
- */
-#define FEC_ENET_RX_PAGES	8
-#define FEC_ENET_RX_FRSIZE	2048
-#define FEC_ENET_RX_FRPPG	(PAGE_SIZE / FEC_ENET_RX_FRSIZE)
-#define RX_RING_SIZE		(FEC_ENET_RX_FRPPG * FEC_ENET_RX_PAGES)
-#define FEC_ENET_TX_FRSIZE	2048
-#define FEC_ENET_TX_FRPPG	(PAGE_SIZE / FEC_ENET_TX_FRSIZE)
-#define TX_RING_SIZE		16	/* Must be power of two */
-#define TX_RING_MOD_MASK	15	/*   for this to work */
-
 #if (((RX_RING_SIZE + TX_RING_SIZE) * 8) > PAGE_SIZE)
 #error "FEC: descriptor ring size constants too large"
 #endif
@@ -179,9 +164,6 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #define PKT_MINBUF_SIZE		64
 #define PKT_MAXBLR_SIZE		1520
 
-/* This device has up to three irqs on some platforms */
-#define FEC_IRQ_NUM		3
-
 /*
  * The 5270/5271/5280/5282/532x RX control register also contains maximum frame
  * size bits. Other FEC hardware does not, so we need to take that into
@@ -194,61 +176,6 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #define	OPT_FRAME_SIZE	0
 #endif
 
-/* The FEC buffer descriptors track the ring buffers.  The rx_bd_base and
- * tx_bd_base always point to the base of the buffer descriptors.  The
- * cur_rx and cur_tx point to the currently available buffer.
- * The dirty_tx tracks the current buffer that is being sent by the
- * controller.  The cur_tx and dirty_tx are equal under both completely
- * empty and completely full conditions.  The empty/ready indicator in
- * the buffer descriptor determines the actual condition.
- */
-struct fec_enet_private {
-	/* Hardware registers of the FEC device */
-	void __iomem *hwp;
-
-	struct net_device *netdev;
-
-	struct clk *clk_ipg;
-	struct clk *clk_ahb;
-
-	/* The saved address of a sent-in-place packet/buffer, for skfree(). */
-	unsigned char *tx_bounce[TX_RING_SIZE];
-	struct	sk_buff* tx_skbuff[TX_RING_SIZE];
-	struct	sk_buff* rx_skbuff[RX_RING_SIZE];
-	ushort	skb_cur;
-	ushort	skb_dirty;
-
-	/* CPM dual port RAM relative addresses */
-	dma_addr_t	bd_dma;
-	/* Address of Rx and Tx buffers */
-	struct bufdesc	*rx_bd_base;
-	struct bufdesc	*tx_bd_base;
-	/* The next free ring entry */
-	struct bufdesc	*cur_rx, *cur_tx;
-	/* The ring entries to be free()ed */
-	struct bufdesc	*dirty_tx;
-
-	uint	tx_full;
-	/* hold while accessing the HW like ringbuffer for tx/rx but not MAC */
-	spinlock_t hw_lock;
-
-	struct	platform_device *pdev;
-
-	int	opened;
-	int	dev_id;
-
-	/* Phylib and MDIO interface */
-	struct	mii_bus *mii_bus;
-	struct	phy_device *phy_dev;
-	int	mii_timeout;
-	uint	phy_speed;
-	phy_interface_t	phy_interface;
-	int	link;
-	int	full_duplex;
-	struct	completion mdio_done;
-	int	irq[FEC_IRQ_NUM];
-};
-
 /* FEC MII MMFR bits definition */
 #define FEC_MMFR_ST		(1 << 30)
 #define FEC_MMFR_OP_READ	(2 << 28)
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 8408c62..e803812 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -147,6 +147,87 @@ struct bufdesc {
 #define BD_ENET_TX_CSL          ((ushort)0x0001)
 #define BD_ENET_TX_STATS        ((ushort)0x03ff)        /* All status bits */
 
+/*enhanced buffer desciptor control/status used by Ethernet transmit*/
+#define BD_ENET_TX_INT          0x40000000
+#define BD_ENET_TX_TS           0x20000000
+
+
+/* This device has up to three irqs on some platforms */
+#define FEC_IRQ_NUM		3
+
+/* The number of Tx and Rx buffers.  These are allocated from the page
+ * pool.  The code may assume these are power of two, so it it best
+ * to keep them that size.
+ * We don't need to allocate pages for the transmitter.  We just use
+ * the skbuffer directly.
+ */
+
+#define FEC_ENET_RX_PAGES	8
+#define FEC_ENET_RX_FRSIZE	2048
+#define FEC_ENET_RX_FRPPG	(PAGE_SIZE / FEC_ENET_RX_FRSIZE)
+#define RX_RING_SIZE		(FEC_ENET_RX_FRPPG * FEC_ENET_RX_PAGES)
+#define FEC_ENET_TX_FRSIZE	2048
+#define FEC_ENET_TX_FRPPG	(PAGE_SIZE / FEC_ENET_TX_FRSIZE)
+#define TX_RING_SIZE		16	/* Must be power of two */
+#define TX_RING_MOD_MASK	15	/*   for this to work */
+
+#define BD_ENET_RX_INT          0x00800000
+#define BD_ENET_RX_PTP          ((ushort)0x0400)
+
+/* The FEC buffer descriptors track the ring buffers.  The rx_bd_base and
+ * tx_bd_base always point to the base of the buffer descriptors.  The
+ * cur_rx and cur_tx point to the currently available buffer.
+ * The dirty_tx tracks the current buffer that is being sent by the
+ * controller.  The cur_tx and dirty_tx are equal under both completely
+ * empty and completely full conditions.  The empty/ready indicator in
+ * the buffer descriptor determines the actual condition.
+ */
+struct fec_enet_private {
+	/* Hardware registers of the FEC device */
+	void __iomem *hwp;
+
+	struct net_device *netdev;
+
+	struct clk *clk_ipg;
+	struct clk *clk_ahb;
+
+	/* The saved address of a sent-in-place packet/buffer, for skfree(). */
+	unsigned char *tx_bounce[TX_RING_SIZE];
+	struct	sk_buff *tx_skbuff[TX_RING_SIZE];
+	struct	sk_buff *rx_skbuff[RX_RING_SIZE];
+	ushort	skb_cur;
+	ushort	skb_dirty;
+
+	/* CPM dual port RAM relative addresses */
+	dma_addr_t	bd_dma;
+	/* Address of Rx and Tx buffers */
+	struct bufdesc	*rx_bd_base;
+	struct bufdesc	*tx_bd_base;
+	/* The next free ring entry */
+	struct bufdesc	*cur_rx, *cur_tx;
+	/* The ring entries to be free()ed */
+	struct bufdesc	*dirty_tx;
+
+	uint	tx_full;
+	/* hold while accessing the HW like ringbuffer for tx/rx but not MAC */
+	spinlock_t hw_lock;
+
+	struct	platform_device *pdev;
+
+	int	opened;
+	int	dev_id;
+
+	/* Phylib and MDIO interface */
+	struct	mii_bus *mii_bus;
+	struct	phy_device *phy_dev;
+	int	mii_timeout;
+	uint	phy_speed;
+	phy_interface_t	phy_interface;
+	int	link;
+	int	full_duplex;
+	struct	completion mdio_done;
+	int	irq[FEC_IRQ_NUM];
+};
 
 /****************************************************************************/
 #endif /* FEC_H */
-- 
1.7.1
