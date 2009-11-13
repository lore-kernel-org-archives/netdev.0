From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 08/20] tg3: Allow DMAs to cross cacheline boundaries
Date: Fri, 13 Nov 2009 15:03:40 -0800
Message-ID: <1258153432-7036-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3252 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932458AbZKMXER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, the 5717 (and future chips) break up PCIe DMA packets across
cacheline boundaries.  This isn't necessary on x86.  This patch
selectively loosens the restriction.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   20 +++++++++++++++-----
 drivers/net/tg3.h |    3 +--
 2 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2d58406..1c1cf68 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7294,9 +7294,12 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (err)
 		return err;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+		val = tr32(TG3PCI_DMA_RW_CTRL) &
+		      ~DMA_RWCTRL_DIS_CACHE_ALIGNMENT;
+		tw32(TG3PCI_DMA_RW_CTRL, val | tp->dma_rwctrl);
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
+		   GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761) {
 		/* This value is determined during the probe time DMA
 		 * engine test, tg3_test_dma.
 		 */
@@ -13329,6 +13332,11 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
 #endif
 #endif
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+		val = goal ? 0 : DMA_RWCTRL_DIS_CACHE_ALIGNMENT;
+		goto out;
+	}
+
 	if (!goal)
 		goto out;
 
@@ -13523,7 +13531,7 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 {
 	dma_addr_t buf_dma;
 	u32 *buf, saved_dma_rwctrl;
-	int ret;
+	int ret = 0;
 
 	buf = pci_alloc_consistent(tp->pdev, TEST_BUFFER_SIZE, &buf_dma);
 	if (!buf) {
@@ -13536,6 +13544,9 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 
 	tp->dma_rwctrl = tg3_calc_dma_bndry(tp, tp->dma_rwctrl);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+		goto out;
+
 	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
 		/* DMA read watermark not used on PCIE */
 		tp->dma_rwctrl |= 0x00180000;
@@ -13608,7 +13619,6 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 	tg3_switch_clocks(tp);
 #endif
 
-	ret = 0;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701)
 		goto out;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index e7916bd..42fefa1 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -142,8 +142,7 @@
 #define   METAL_REV_B1			 0x01
 #define   METAL_REV_B2			 0x02
 #define TG3PCI_DMA_RW_CTRL		0x0000006c
-#define  DMA_RWCTRL_MIN_DMA		 0x000000ff
-#define  DMA_RWCTRL_MIN_DMA_SHIFT	 0
+#define  DMA_RWCTRL_DIS_CACHE_ALIGNMENT  0x00000001
 #define  DMA_RWCTRL_READ_BNDRY_MASK	 0x00000700
 #define  DMA_RWCTRL_READ_BNDRY_DISAB	 0x00000000
 #define  DMA_RWCTRL_READ_BNDRY_16	 0x00000100
-- 
1.6.4.4


