From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 1/4] tg3: Add ethtool_eee struct and
 tg3_setup_eee()
Date: Fri, 17 May 2013 08:19:47 -0700
Message-ID: <1368803990-10098-2-git-send-email-nsujir@broadcom.com>
References: <1368803990-10098-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4469 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004Ab3EQPUA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 May 2013 11:20:00 -0400
In-Reply-To: <1368803990-10098-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an eee structure and update it with eee settings. This will be used
for set/get_eee operations. Add common function tg3_setup_eee() that
will be used in the subsequent patches.

Reviewed-by: Ben Li <benli@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 91 +++++++++++++++++++++++--------------
 drivers/net/ethernet/broadcom/tg3.h |  1 +
 2 files changed, 59 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 77f1fd3..91efe64 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4261,6 +4261,16 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 		/* Advertise 1000-BaseT EEE ability */
 		if (advertise & ADVERTISED_1000baseT_Full)
 			val |= MDIO_AN_EEE_ADV_1000T;
+
+		if (!tp->eee.eee_enabled) {
+			val = 0;
+			tp->eee.advertised = 0;
+		} else {
+			tp->eee.advertised = advertise &
+					     (ADVERTISED_100baseT_Full |
+					      ADVERTISED_1000baseT_Full);
+		}
+
 		err = tg3_phy_cl45_write(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, val);
 		if (err)
 			val = 0;
@@ -4625,6 +4635,42 @@ static void tg3_clear_mac_status(struct tg3 *tp)
 	udelay(40);
 }
 
+static void tg3_setup_eee(struct tg3 *tp)
+{
+	u32 val;
+
+	val = TG3_CPMU_EEE_LNKIDL_PCIE_NL0 |
+	      TG3_CPMU_EEE_LNKIDL_UART_IDL;
+	if (tg3_chip_rev_id(tp) == CHIPREV_ID_57765_A0)
+		val |= TG3_CPMU_EEE_LNKIDL_APE_TX_MT;
+
+	tw32_f(TG3_CPMU_EEE_LNKIDL_CTRL, val);
+
+	tw32_f(TG3_CPMU_EEE_CTRL,
+	       TG3_CPMU_EEE_CTRL_EXIT_20_1_US);
+
+	val = TG3_CPMU_EEEMD_ERLY_L1_XIT_DET |
+	      (tp->eee.tx_lpi_enabled ? TG3_CPMU_EEEMD_LPI_IN_TX : 0) |
+	      TG3_CPMU_EEEMD_LPI_IN_RX |
+	      TG3_CPMU_EEEMD_EEE_ENABLE;
+
+	if (tg3_asic_rev(tp) != ASIC_REV_5717)
+		val |= TG3_CPMU_EEEMD_SND_IDX_DET_EN;
+
+	if (tg3_flag(tp, ENABLE_APE))
+		val |= TG3_CPMU_EEEMD_APE_TX_DET_EN;
+
+	tw32_f(TG3_CPMU_EEE_MODE, tp->eee.eee_enabled ? val : 0);
+
+	tw32_f(TG3_CPMU_EEE_DBTMR1,
+	       TG3_CPMU_DBTMR1_PCIEXIT_2047US |
+	       (tp->eee.tx_lpi_timer & 0xffff));
+
+	tw32_f(TG3_CPMU_EEE_DBTMR2,
+	       TG3_CPMU_DBTMR2_APE_TX_2047US |
+	       TG3_CPMU_DBTMR2_TXIDXEQ_2047US);
+}
+
 static int tg3_setup_copper_phy(struct tg3 *tp, bool force_reset)
 {
 	bool current_link_up;
@@ -9477,38 +9523,8 @@ static int tg3_reset_hw(struct tg3 *tp, bool reset_phy)
 		tg3_abort_hw(tp, 1);
 
 	/* Enable MAC control of LPI */
-	if (tp->phy_flags & TG3_PHYFLG_EEE_CAP) {
-		val = TG3_CPMU_EEE_LNKIDL_PCIE_NL0 |
-		      TG3_CPMU_EEE_LNKIDL_UART_IDL;
-		if (tg3_chip_rev_id(tp) == CHIPREV_ID_57765_A0)
-			val |= TG3_CPMU_EEE_LNKIDL_APE_TX_MT;
-
-		tw32_f(TG3_CPMU_EEE_LNKIDL_CTRL, val);
-
-		tw32_f(TG3_CPMU_EEE_CTRL,
-		       TG3_CPMU_EEE_CTRL_EXIT_20_1_US);
-
-		val = TG3_CPMU_EEEMD_ERLY_L1_XIT_DET |
-		      TG3_CPMU_EEEMD_LPI_IN_TX |
-		      TG3_CPMU_EEEMD_LPI_IN_RX |
-		      TG3_CPMU_EEEMD_EEE_ENABLE;
-
-		if (tg3_asic_rev(tp) != ASIC_REV_5717)
-			val |= TG3_CPMU_EEEMD_SND_IDX_DET_EN;
-
-		if (tg3_flag(tp, ENABLE_APE))
-			val |= TG3_CPMU_EEEMD_APE_TX_DET_EN;
-
-		tw32_f(TG3_CPMU_EEE_MODE, val);
-
-		tw32_f(TG3_CPMU_EEE_DBTMR1,
-		       TG3_CPMU_DBTMR1_PCIEXIT_2047US |
-		       TG3_CPMU_DBTMR1_LNKIDLE_2047US);
-
-		tw32_f(TG3_CPMU_EEE_DBTMR2,
-		       TG3_CPMU_DBTMR2_APE_TX_2047US |
-		       TG3_CPMU_DBTMR2_TXIDXEQ_2047US);
-	}
+	if (tp->phy_flags & TG3_PHYFLG_EEE_CAP)
+		tg3_setup_eee(tp);
 
 	if ((tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN) &&
 	    !(tp->phy_flags & TG3_PHYFLG_USER_CONFIGURED)) {
@@ -14975,9 +14991,18 @@ static int tg3_phy_probe(struct tg3 *tp)
 	     (tg3_asic_rev(tp) == ASIC_REV_5717 &&
 	      tg3_chip_rev_id(tp) != CHIPREV_ID_5717_A0) ||
 	     (tg3_asic_rev(tp) == ASIC_REV_57765 &&
-	      tg3_chip_rev_id(tp) != CHIPREV_ID_57765_A0)))
+	      tg3_chip_rev_id(tp) != CHIPREV_ID_57765_A0))) {
 		tp->phy_flags |= TG3_PHYFLG_EEE_CAP;
 
+		tp->eee.supported = SUPPORTED_100baseT_Full |
+				    SUPPORTED_1000baseT_Full;
+		tp->eee.advertised = ADVERTISED_100baseT_Full |
+				     ADVERTISED_1000baseT_Full;
+		tp->eee.eee_enabled = 1;
+		tp->eee.tx_lpi_enabled = 1;
+		tp->eee.tx_lpi_timer = TG3_CPMU_DBTMR1_LNKIDLE_2047US;
+	}
+
 	tg3_phy_init_link_config(tp);
 
 	if (!(tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN) &&
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 9b2d3ac..057532c 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3371,6 +3371,7 @@ struct tg3 {
 	unsigned int			irq_cnt;
 
 	struct ethtool_coalesce		coal;
+	struct ethtool_eee		eee;
 
 	/* firmware info */
 	const char			*fw_needed;
-- 
1.8.1.4
