From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v2 net-next 4/9] tg3: Add 5720 ASIC rev
Date: Tue, 5 Apr 2011 17:22:46 -0700
Message-ID: <1302049371-13799-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4652 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255Ab1DFAQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 20:16:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the 5720 ASIC rev.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   30 ++++++++++++++++++++++--------
 drivers/net/tg3.h |    5 +++++
 2 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index dc6b60b..53a1209 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2125,7 +2125,8 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714 ||
-	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) &&
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) &&
 	    tp->pdev_peer != tp->pdev) {
 		struct net_device *dev_peer;
 
@@ -7251,6 +7252,11 @@ static int tg3_chip_reset(struct tg3 *tp)
 		tw32(0x7c00, val | (1 << 25));
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
+		val = tr32(TG3_CPMU_CLCK_ORIDE);
+		tw32(TG3_CPMU_CLCK_ORIDE, val & ~CPMU_CLCK_ORIDE_MAC_ORIDE_EN);
+	}
+
 	/* Reprobe ASF enable state.  */
 	tp->tg3_flags &= ~TG3_FLAG_ENABLE_ASF;
 	tp->tg3_flags2 &= ~TG3_FLG2_ASF_NEW_HANDSHAKE;
@@ -8214,7 +8220,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
 	    (tp->tg3_flags3 & TG3_FLG3_57765_PLUS)) {
 		val = tr32(TG3_RDMA_RSRVCTRL_REG);
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
 			val &= ~(TG3_RDMA_RSRVCTRL_TXMRGN_MASK |
 				 TG3_RDMA_RSRVCTRL_FIFO_LWM_MASK |
 				 TG3_RDMA_RSRVCTRL_FIFO_HWM_MASK);
@@ -8226,7 +8233,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		     val | TG3_RDMA_RSRVCTRL_FIFO_OFLW_FIX);
 	}
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
 		val = tr32(TG3_LSO_RD_DMA_CRPTEN_CTRL);
 		tw32(TG3_LSO_RD_DMA_CRPTEN_CTRL, val |
 		     TG3_LSO_RD_DMA_CRPTEN_CTRL_BLEN_BD_4K |
@@ -9050,7 +9058,9 @@ static bool tg3_enable_msix(struct tg3 *tp)
 
 	if (tp->irq_cnt > 1) {
 		tp->tg3_flags3 |= TG3_FLG3_ENABLE_RSS;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
 			tp->tg3_flags3 |= TG3_FLG3_ENABLE_TSS;
 			netif_set_real_num_tx_queues(tp->dev, tp->irq_cnt - 1);
 		}
@@ -13166,7 +13176,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717 ||
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 ||
-		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5719)
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5719 ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5720)
 			pci_read_config_dword(tp->pdev,
 					      TG3PCI_GEN2_PRODID_ASICREV,
 					      &prod_id_asic_rev);
@@ -13321,11 +13332,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 		tp->pdev_peer = tg3_find_peer(tp);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 		tp->tg3_flags3 |= TG3_FLG3_5717_PLUS;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 ||
@@ -13444,7 +13457,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
 
 		tp->pcie_readrq = 4096;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 			tp->pcie_readrq = 2048;
 
 		pcie_set_readrq(tp->pdev, tp->pcie_readrq);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index b8e6acc..45605f2 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -58,6 +58,7 @@
 #define  TG3PCI_DEVICE_TIGON3_57791	 0x16b2
 #define  TG3PCI_DEVICE_TIGON3_57795	 0x16b6
 #define  TG3PCI_DEVICE_TIGON3_5719	 0x1657
+#define  TG3PCI_DEVICE_TIGON3_5720	 0x165f
 /* 0x04 --> 0x2c unused */
 #define TG3PCI_SUBVENDOR_ID_BROADCOM		PCI_VENDOR_ID_BROADCOM
 #define TG3PCI_SUBDEVICE_ID_BROADCOM_95700A6	0x1644
@@ -167,6 +168,7 @@
 #define   ASIC_REV_5717			 0x5717
 #define   ASIC_REV_57765		 0x57785
 #define   ASIC_REV_5719			 0x5719
+#define   ASIC_REV_5720			 0x5720
 #define  GET_CHIP_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 8)
 #define   CHIPREV_5700_AX		 0x70
 #define   CHIPREV_5700_BX		 0x71
@@ -1083,6 +1085,9 @@
 #define  CPMU_HST_ACC_MACCLK_6_25	 0x00130000
 /* 0x3620 --> 0x3630 unused */
 
+#define TG3_CPMU_CLCK_ORIDE		0x00003624
+#define  CPMU_CLCK_ORIDE_MAC_ORIDE_EN	 0x80000000
+
 #define TG3_CPMU_CLCK_STAT		0x00003630
 #define  CPMU_CLCK_STAT_MAC_CLCK_MASK	 0x001f0000
 #define  CPMU_CLCK_STAT_MAC_CLCK_62_5	 0x00000000
-- 
1.7.3.4


