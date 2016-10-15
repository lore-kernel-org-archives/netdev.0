From: Tushar Dave <tushar.n.dave@oracle.com>
Subject: [PATCH 1/2] sunqe: Fix compiler warnings
Date: Fri, 14 Oct 2016 17:06:05 -0700
Message-ID: <1476489966-9128-2-git-send-email-tushar.n.dave@oracle.com>
References: <1476489966-9128-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: chris.hyser@oracle.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37671 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbcJOAHT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 20:07:19 -0400
In-Reply-To: <1476489966-9128-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sunqe uses '__u32' for dma handle while invoking kernel DMA APIs,
instead of using dma_addr_t. This hasn't caused any 'incompatible
pointer type' warning on SPARC because until now dma_addr_t is of
type u32. However, recent changes in SPARC ATU (iommu) enables 64bit
DMA and therefore dma_addr_t becomes of type u64. This makes
'incompatible pointer type' warnings inevitable.

e.g.
drivers/net/ethernet/sun/sunqe.c: In function ‘qec_ether_init’:
drivers/net/ethernet/sun/sunqe.c:883: warning: passing argument 3 of ‘dma_alloc_coherent’ from incompatible pointer type
./include/linux/dma-mapping.h:445: note: expected ‘dma_addr_t *’ but argument is of type ‘__u32 *’
drivers/net/ethernet/sun/sunqe.c:885: warning: passing argument 3 of ‘dma_alloc_coherent’ from incompatible pointer type
./include/linux/dma-mapping.h:445: note: expected ‘dma_addr_t *’ but argument is of type ‘__u32 *’

This patch resolves above compiler warnings.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
Reviewed-by: chris hyser <chris.hyser@oracle.com>
---
 drivers/net/ethernet/sun/sunqe.c | 11 ++++++-----
 drivers/net/ethernet/sun/sunqe.h |  4 ++--
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index 9b825780..9582948 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -124,7 +124,7 @@ static void qe_init_rings(struct sunqe *qep)
 {
 	struct qe_init_block *qb = qep->qe_block;
 	struct sunqe_buffers *qbufs = qep->buffers;
-	__u32 qbufs_dvma = qep->buffers_dvma;
+	__u32 qbufs_dvma = (__u32)qep->buffers_dvma;
 	int i;
 
 	qep->rx_new = qep->rx_old = qep->tx_new = qep->tx_old = 0;
@@ -144,6 +144,7 @@ static int qe_init(struct sunqe *qep, int from_irq)
 	void __iomem *mregs = qep->mregs;
 	void __iomem *gregs = qecp->gregs;
 	unsigned char *e = &qep->dev->dev_addr[0];
+	__u32 qblk_dvma = (__u32)qep->qblock_dvma;
 	u32 tmp;
 	int i;
 
@@ -152,8 +153,8 @@ static int qe_init(struct sunqe *qep, int from_irq)
 		return -EAGAIN;
 
 	/* Setup initial rx/tx init block pointers. */
-	sbus_writel(qep->qblock_dvma + qib_offset(qe_rxd, 0), cregs + CREG_RXDS);
-	sbus_writel(qep->qblock_dvma + qib_offset(qe_txd, 0), cregs + CREG_TXDS);
+	sbus_writel(qblk_dvma + qib_offset(qe_rxd, 0), cregs + CREG_RXDS);
+	sbus_writel(qblk_dvma + qib_offset(qe_txd, 0), cregs + CREG_TXDS);
 
 	/* Enable/mask the various irq's. */
 	sbus_writel(0, cregs + CREG_RIMASK);
@@ -413,7 +414,7 @@ static void qe_rx(struct sunqe *qep)
 	struct net_device *dev = qep->dev;
 	struct qe_rxd *this;
 	struct sunqe_buffers *qbufs = qep->buffers;
-	__u32 qbufs_dvma = qep->buffers_dvma;
+	__u32 qbufs_dvma = (__u32)qep->buffers_dvma;
 	int elem = qep->rx_new;
 	u32 flags;
 
@@ -572,7 +573,7 @@ static int qe_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sunqe *qep = netdev_priv(dev);
 	struct sunqe_buffers *qbufs = qep->buffers;
-	__u32 txbuf_dvma, qbufs_dvma = qep->buffers_dvma;
+	__u32 txbuf_dvma, qbufs_dvma = (__u32)qep->buffers_dvma;
 	unsigned char *txbuf;
 	int len, entry;
 
diff --git a/drivers/net/ethernet/sun/sunqe.h b/drivers/net/ethernet/sun/sunqe.h
index 581781b..ae190b7 100644
--- a/drivers/net/ethernet/sun/sunqe.h
+++ b/drivers/net/ethernet/sun/sunqe.h
@@ -334,12 +334,12 @@ struct sunqe {
 	void __iomem			*qcregs;		/* QEC per-channel Registers   */
 	void __iomem			*mregs;		/* Per-channel MACE Registers  */
 	struct qe_init_block      	*qe_block;	/* RX and TX descriptors       */
-	__u32                      	qblock_dvma;	/* RX and TX descriptors       */
+	dma_addr_t			qblock_dvma;	/* RX and TX descriptors       */
 	spinlock_t			lock;		/* Protects txfull state       */
 	int                        	rx_new, rx_old;	/* RX ring extents	       */
 	int			   	tx_new, tx_old;	/* TX ring extents	       */
 	struct sunqe_buffers		*buffers;	/* CPU visible address.        */
-	__u32				buffers_dvma;	/* DVMA visible address.       */
+	dma_addr_t			buffers_dvma;	/* DVMA visible address.       */
 	struct sunqec			*parent;
 	u8				mconfig;	/* Base MACE mconfig value     */
 	struct platform_device		*op;		/* QE's OF device struct       */
-- 
1.9.1
