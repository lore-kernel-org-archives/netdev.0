From: Tushar Dave <tushar.n.dave@oracle.com>
Subject: [PATCH 2/2] sunbmac: Fix compiler warning
Date: Fri, 14 Oct 2016 17:06:06 -0700
Message-ID: <1476489966-9128-3-git-send-email-tushar.n.dave@oracle.com>
References: <1476489966-9128-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: chris.hyser@oracle.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476489966-9128-1-git-send-email-tushar.n.dave@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sunbmac uses '__u32' for dma handle while invoking kernel DMA APIs,
instead of using dma_addr_t. This hasn't caused any 'incompatible
pointer type' warning on SPARC because until now dma_addr_t is of
type u32. However, recent changes in SPARC ATU (iommu) enables 64bit
DMA and therefore dma_addr_t becomes of type u64. This makes
'incompatible pointer type' warnings inevitable.

e.g.
drivers/net/ethernet/sun/sunbmac.c: In function ‘bigmac_ether_init’:
drivers/net/ethernet/sun/sunbmac.c:1166: warning: passing argument 3 of ‘dma_alloc_coherent’ from incompatible pointer type
./include/linux/dma-mapping.h:445: note: expected ‘dma_addr_t *’ but argument is of type ‘__u32 *’

This patch resolves above compiler warning.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
Reviewed-by: chris hyser <chris.hyser@oracle.com>
---
 drivers/net/ethernet/sun/sunbmac.c | 5 +++--
 drivers/net/ethernet/sun/sunbmac.h | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index aa4f9d2..02f4527 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -623,6 +623,7 @@ static int bigmac_init_hw(struct bigmac *bp, int from_irq)
 	void __iomem *gregs        = bp->gregs;
 	void __iomem *cregs        = bp->creg;
 	void __iomem *bregs        = bp->bregs;
+	__u32 bblk_dvma = (__u32)bp->bblock_dvma;
 	unsigned char *e = &bp->dev->dev_addr[0];
 
 	/* Latch current counters into statistics. */
@@ -671,9 +672,9 @@ static int bigmac_init_hw(struct bigmac *bp, int from_irq)
 		    bregs + BMAC_XIFCFG);
 
 	/* Tell the QEC where the ring descriptors are. */
-	sbus_writel(bp->bblock_dvma + bib_offset(be_rxd, 0),
+	sbus_writel(bblk_dvma + bib_offset(be_rxd, 0),
 		    cregs + CREG_RXDS);
-	sbus_writel(bp->bblock_dvma + bib_offset(be_txd, 0),
+	sbus_writel(bblk_dvma + bib_offset(be_txd, 0),
 		    cregs + CREG_TXDS);
 
 	/* Setup the FIFO pointers into QEC local memory. */
diff --git a/drivers/net/ethernet/sun/sunbmac.h b/drivers/net/ethernet/sun/sunbmac.h
index 06dd217..532fc56 100644
--- a/drivers/net/ethernet/sun/sunbmac.h
+++ b/drivers/net/ethernet/sun/sunbmac.h
@@ -291,7 +291,7 @@ struct bigmac {
 	void __iomem	*bregs;	/* BigMAC Registers                   */
 	void __iomem	*tregs;	/* BigMAC Transceiver                 */
 	struct bmac_init_block	*bmac_block;	/* RX and TX descriptors */
-	__u32			 bblock_dvma;	/* RX and TX descriptors */
+	dma_addr_t		bblock_dvma;	/* RX and TX descriptors */
 
 	spinlock_t		lock;
 
-- 
1.9.1
