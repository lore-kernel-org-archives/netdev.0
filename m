From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 03/14] tg3: Create TG3_FLG3_5717_PLUS flag
Date: Mon, 2 Aug 2010 14:25:57 -0700
Message-ID: <1280784368-4226-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2884 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755450Ab0HBV0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 17:26:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates a TG3_FLG3_5717_PLUS flag to collectively describe
the set of changes in the ASIC that will apply to all future chip
revisions.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   72 ++++++++++++++++------------------------------------
 drivers/net/tg3.h |    1 +
 2 files changed, 23 insertions(+), 50 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 12a2dd7..7892b00 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7075,9 +7075,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 	if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
 	    tp->pci_chip_rev_id != CHIPREV_ID_5750_A0 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57765) {
+	    !(tp->tg3_flags3 & TG3_FLG3_5717_PLUS)) {
 		val = tr32(0x7c00);
 
 		tw32(0x7c00, val | (1 << 25));
@@ -7750,9 +7748,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (err)
 		return err;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) {
+	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
 		val = tr32(TG3PCI_DMA_RW_CTRL) &
 		      ~DMA_RWCTRL_DIS_CACHE_ALIGNMENT;
 		if (tp->pci_chip_rev_id == CHIPREV_ID_57765_A0)
@@ -7915,9 +7911,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			     BDINFO_FLAGS_DISABLED);
 		}
 
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
+		if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
 			val = (RX_STD_MAX_SIZE_5705 << BDINFO_FLAGS_MAXLEN_SHIFT) |
 			      (TG3_RX_STD_DMA_SZ << 2);
 		else
@@ -7934,9 +7928,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			  tp->rx_jumbo_pending : 0;
 	tw32_rx_mbox(TG3_RX_JMB_PROD_IDX_REG, tpr->rx_jmb_prod_idx);
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) {
+	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
 		tw32(STD_REPLENISH_LWM, 32);
 		tw32(JMB_REPLENISH_LWM, 16);
 	}
@@ -8626,9 +8618,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	 * Turn off MSI one shot mode.  Otherwise this test has no
 	 * observable way to know whether the interrupt was delivered.
 	 */
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) &&
+	if ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
 	    (tp->tg3_flags2 & TG3_FLG2_USING_MSI)) {
 		val = tr32(MSGINT_MODE) | MSGINT_MODE_ONE_SHOT_DISABLE;
 		tw32(MSGINT_MODE, val);
@@ -8671,9 +8661,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 
 	if (intr_ok) {
 		/* Reenable MSI one shot mode. */
-		if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-		     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-		     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) &&
+		if ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
 		    (tp->tg3_flags2 & TG3_FLG2_USING_MSI)) {
 			val = tr32(MSGINT_MODE) & ~MSGINT_MODE_ONE_SHOT_DISABLE;
 			tw32(MSGINT_MODE, val);
@@ -8968,11 +8956,8 @@ static int tg3_open(struct net_device *dev)
 			goto err_out2;
 		}
 
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
-		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719 &&
-		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57765 &&
-		    (tp->tg3_flags2 & TG3_FLG2_USING_MSI) &&
-		    (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)) {
+		if (!(tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
+		    (tp->tg3_flags2 & TG3_FLG2_USING_MSI)) {
 			u32 val = tr32(PCIE_TRANSACTION_CFG);
 
 			tw32(PCIE_TRANSACTION_CFG,
@@ -12987,6 +12972,11 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
 		tp->pdev_peer = tg3_find_peer(tp);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
+		tp->tg3_flags3 |= TG3_FLG3_5717_PLUS;
+
 	/* Intentionally exclude ASIC_REV_5906 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
@@ -12994,9 +12984,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
+	    (tp->tg3_flags3 & TG3_FLG3_5717_PLUS))
 		tp->tg3_flags3 |= TG3_FLG3_5755_PLUS;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
@@ -13026,9 +13014,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	}
 
 	/* Determine TSO capabilities */
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
+	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
 		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_3;
 	else if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
 		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
@@ -13064,9 +13050,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
 		}
 
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) {
+		if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
 			tp->tg3_flags |= TG3_FLAG_SUPPORT_MSIX;
 			tp->irq_max = TG3_IRQ_MAX_VECS;
 		}
@@ -13081,9 +13065,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags3 |= TG3_FLG3_40BIT_DMA_LIMIT_BUG;
 	}
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
+	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
 		tp->tg3_flags3 |= TG3_FLG3_USE_JUMBO_BDFLAG;
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
@@ -13284,9 +13266,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
+	    (tp->tg3_flags3 & TG3_FLG3_5717_PLUS))
 		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
 
 	/* Set up tp->grc_local_ctrl before calling tg3_set_power_state().
@@ -13365,9 +13345,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    !(tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57780 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57765) {
+	    !(tp->tg3_flags3 & TG3_FLG3_5717_PLUS)) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
@@ -13704,9 +13682,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
 #endif
 #endif
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) {
+	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
 		val = goal ? 0 : DMA_RWCTRL_DIS_CACHE_ALIGNMENT;
 		goto out;
 	}
@@ -13917,9 +13893,7 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 
 	tp->dma_rwctrl = tg3_calc_dma_bndry(tp, tp->dma_rwctrl);
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
+	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
 		goto out;
 
 	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
@@ -14117,9 +14091,7 @@ static void __devinit tg3_init_link_config(struct tg3 *tp)
 
 static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
 {
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) {
+	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
 		tp->bufmgr_config.mbuf_read_dma_low_water =
 			DEFAULT_MB_RDMA_LOW_WATER_5705;
 		tp->bufmgr_config.mbuf_mac_rx_low_water =
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 0432399..a544045 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2860,6 +2860,7 @@ struct tg3 {
 #define TG3_FLG3_SHORT_DMA_BUG		0x00200000
 #define TG3_FLG3_USE_JUMBO_BDFLAG	0x00400000
 #define TG3_FLG3_L1PLLPD_EN		0x00800000
+#define TG3_FLG3_5717_PLUS		0x01000000
 
 	struct timer_list		timer;
 	u16				timer_counter;
-- 
1.7.1


