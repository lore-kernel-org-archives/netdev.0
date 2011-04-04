From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/7] tg3: Add 5720 H2BMC support
Date: Mon, 4 Apr 2011 11:24:51 -0700
Message-ID: <1301941495-8069-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1609 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755176Ab1DDSTV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:19:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the new Host to BMC feature.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   59 +++++++++++++++++++++++++++++++++++++++-------------
 drivers/net/tg3.h |    9 ++++++++
 2 files changed, 53 insertions(+), 15 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f9bf9e8..fa40632 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4400,6 +4400,7 @@ static void tg3_serdes_parallel_detect(struct tg3 *tp)
 
 static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 {
+	u32 val;
 	int err;
 
 	if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)
@@ -4410,7 +4411,7 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 		err = tg3_setup_copper_phy(tp, force_reset);
 
 	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5784_AX) {
-		u32 val, scale;
+		u32 scale;
 
 		val = tr32(TG3_CPMU_CLCK_STAT) & CPMU_CLCK_STAT_MAC_CLCK_MASK;
 		if (val == CPMU_CLCK_STAT_MAC_CLCK_62_5)
@@ -4425,17 +4426,20 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 		tw32(GRC_MISC_CFG, val);
 	}
 
+	val = (2 << TX_LENGTHS_IPG_CRS_SHIFT) |
+	      (6 << TX_LENGTHS_IPG_SHIFT);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
+		val |= tr32(MAC_TX_LENGTHS) &
+		       (TX_LENGTHS_JMB_FRM_LEN_MSK |
+			TX_LENGTHS_CNT_DWN_VAL_MSK);
+
 	if (tp->link_config.active_speed == SPEED_1000 &&
 	    tp->link_config.active_duplex == DUPLEX_HALF)
-		tw32(MAC_TX_LENGTHS,
-		     ((2 << TX_LENGTHS_IPG_CRS_SHIFT) |
-		      (6 << TX_LENGTHS_IPG_SHIFT) |
-		      (0xff << TX_LENGTHS_SLOT_TIME_SHIFT)));
+		tw32(MAC_TX_LENGTHS, val |
+		     (0xff << TX_LENGTHS_SLOT_TIME_SHIFT));
 	else
-		tw32(MAC_TX_LENGTHS,
-		     ((2 << TX_LENGTHS_IPG_CRS_SHIFT) |
-		      (6 << TX_LENGTHS_IPG_SHIFT) |
-		      (32 << TX_LENGTHS_SLOT_TIME_SHIFT)));
+		tw32(MAC_TX_LENGTHS, val |
+		     (32 << TX_LENGTHS_SLOT_TIME_SHIFT));
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
 		if (netif_carrier_ok(tp->dev)) {
@@ -4447,7 +4451,7 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 	}
 
 	if (tp->tg3_flags & TG3_FLAG_ASPM_WORKAROUND) {
-		u32 val = tr32(PCIE_PWR_MGMT_THRESH);
+		val = tr32(PCIE_PWR_MGMT_THRESH);
 		if (!netif_carrier_ok(tp->dev))
 			val = (val & ~PCIE_PWR_MGMT_L1_THRESH_MSK) |
 			      tp->pwrmgmt_thresh;
@@ -8179,10 +8183,16 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	/* The slot time is changed by tg3_setup_phy if we
 	 * run at gigabit with half duplex.
 	 */
-	tw32(MAC_TX_LENGTHS,
-	     (2 << TX_LENGTHS_IPG_CRS_SHIFT) |
-	     (6 << TX_LENGTHS_IPG_SHIFT) |
-	     (32 << TX_LENGTHS_SLOT_TIME_SHIFT));
+	val = (2 << TX_LENGTHS_IPG_CRS_SHIFT) |
+	      (6 << TX_LENGTHS_IPG_SHIFT) |
+	      (32 << TX_LENGTHS_SLOT_TIME_SHIFT);
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
+		val |= tr32(MAC_TX_LENGTHS) &
+		       (TX_LENGTHS_JMB_FRM_LEN_MSK |
+			TX_LENGTHS_CNT_DWN_VAL_MSK);
+
+	tw32(MAC_TX_LENGTHS, val);
 
 	/* Receive rules. */
 	tw32(MAC_RCV_RULE_CFG, RCV_RULE_CFG_DEFAULT_CLASS);
@@ -8229,6 +8239,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		rdmac_mode |= RDMAC_MODE_IPV6_LSO_EN;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
+		rdmac_mode |= tr32(RDMAC_MODE) & RDMAC_MODE_H2BNC_VLAN_DET;
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
@@ -8464,9 +8477,17 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	}
 
 	tp->tx_mode = TX_MODE_ENABLE;
+
 	if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tp->tx_mode |= TX_MODE_MBUF_LOCKUP_FIX;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
+		val = TX_MODE_JMB_FRM_LEN | TX_MODE_CNT_DN_MODE;
+		tp->tx_mode &= ~val;
+		tp->tx_mode |= tr32(MAC_TX_MODE) & val;
+	}
+
 	tw32_f(MAC_TX_MODE, tp->tx_mode);
 	udelay(100);
 
@@ -13895,7 +13916,15 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	/* Initialize data/descriptor byte/word swapping. */
 	val = tr32(GRC_MODE);
-	val &= GRC_MODE_HOST_STACKUP;
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
+		val &= (GRC_MODE_BYTE_SWAP_B2HRX_DATA |
+			GRC_MODE_WORD_SWAP_B2HRX_DATA |
+			GRC_MODE_B2HRX_ENABLE |
+			GRC_MODE_HTX2B_ENABLE |
+			GRC_MODE_HOST_STACKUP);
+	else
+		val &= GRC_MODE_HOST_STACKUP;
+
 	tw32(GRC_MODE, val | tp->grc_mode);
 
 	tg3_switch_clocks(tp);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 43776fe..39375ed 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -475,6 +475,8 @@
 #define  TX_MODE_BIG_BCKOFF_ENABLE	 0x00000020
 #define  TX_MODE_LONG_PAUSE_ENABLE	 0x00000040
 #define  TX_MODE_MBUF_LOCKUP_FIX	 0x00000100
+#define  TX_MODE_JMB_FRM_LEN		 0x00400000
+#define  TX_MODE_CNT_DN_MODE		 0x00800000
 #define MAC_TX_STATUS			0x00000460
 #define  TX_STATUS_XOFFED		 0x00000001
 #define  TX_STATUS_SENT_XOFF		 0x00000002
@@ -489,6 +491,8 @@
 #define  TX_LENGTHS_IPG_SHIFT		 8
 #define  TX_LENGTHS_IPG_CRS_MASK	 0x00003000
 #define  TX_LENGTHS_IPG_CRS_SHIFT	 12
+#define  TX_LENGTHS_JMB_FRM_LEN_MSK	 0x00ff0000
+#define  TX_LENGTHS_CNT_DWN_VAL_MSK	 0xff000000
 #define MAC_RX_MODE			0x00000468
 #define  RX_MODE_RESET			 0x00000001
 #define  RX_MODE_ENABLE			 0x00000002
@@ -1326,6 +1330,7 @@
 #define  RDMAC_MODE_MULT_DMA_RD_DIS	 0x01000000
 #define  RDMAC_MODE_IPV4_LSO_EN		 0x08000000
 #define  RDMAC_MODE_IPV6_LSO_EN		 0x10000000
+#define  RDMAC_MODE_H2BNC_VLAN_DET	 0x20000000
 #define RDMAC_STATUS			0x00004804
 #define  RDMAC_STATUS_TGTABORT		 0x00000004
 #define  RDMAC_STATUS_MSTABORT		 0x00000008
@@ -1618,6 +1623,8 @@
 #define  GRC_MODE_WSWAP_NONFRM_DATA	0x00000004
 #define  GRC_MODE_BSWAP_DATA		0x00000010
 #define  GRC_MODE_WSWAP_DATA		0x00000020
+#define  GRC_MODE_BYTE_SWAP_B2HRX_DATA	0x00000040
+#define  GRC_MODE_WORD_SWAP_B2HRX_DATA	0x00000080
 #define  GRC_MODE_SPLITHDR		0x00000100
 #define  GRC_MODE_NOFRM_CRACKING	0x00000200
 #define  GRC_MODE_INCL_CRC		0x00000400
@@ -1625,8 +1632,10 @@
 #define  GRC_MODE_NOIRQ_ON_SENDS	0x00002000
 #define  GRC_MODE_NOIRQ_ON_RCV		0x00004000
 #define  GRC_MODE_FORCE_PCI32BIT	0x00008000
+#define  GRC_MODE_B2HRX_ENABLE		0x00008000
 #define  GRC_MODE_HOST_STACKUP		0x00010000
 #define  GRC_MODE_HOST_SENDBDS		0x00020000
+#define  GRC_MODE_HTX2B_ENABLE		0x00040000
 #define  GRC_MODE_NO_TX_PHDR_CSUM	0x00100000
 #define  GRC_MODE_NVRAM_WR_ENABLE	0x00200000
 #define  GRC_MODE_PCIE_TL_SEL		0x00000000
-- 
1.7.3.4


