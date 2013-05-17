From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 2/4] tg3: Add tg3_eee_pull_config() function
Date: Fri, 17 May 2013 08:19:48 -0700
Message-ID: <1368803990-10098-3-git-send-email-nsujir@broadcom.com>
References: <1368803990-10098-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2637 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032Ab3EQPUF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 May 2013 11:20:05 -0400
In-Reply-To: <1368803990-10098-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add tg3_eee_pull_config() to pull the settings from the hardware and
populate the eee structure.

If Link Flap Avoidance is enabled, we pull the eee settings from the hw
so as not to cause a phy reset on eee config mismatch later. This
requires moving down tg3_setup_eee() below the tg3_pull_config() to not
trample existing settings.

Reviewed-by: Ben Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 62 +++++++++++++++++++++++++++++++------
 1 file changed, 53 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 91efe64..75b38c4 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -2320,6 +2320,52 @@ static void tg3_phy_apply_otp(struct tg3 *tp)
 	tg3_phy_toggle_auxctl_smdsp(tp, false);
 }
 
+static void tg3_eee_pull_config(struct tg3 *tp, struct ethtool_eee *eee)
+{
+	u32 val;
+	struct ethtool_eee *dest = &tp->eee;
+
+	if (!(tp->phy_flags & TG3_PHYFLG_EEE_CAP))
+		return;
+
+	if (eee)
+		dest = eee;
+
+	if (tg3_phy_cl45_read(tp, MDIO_MMD_AN, TG3_CL45_D7_EEERES_STAT, &val))
+		return;
+
+	/* Pull eee_active and lp_advertised. */
+	if (val == TG3_CL45_D7_EEERES_STAT_LP_1000T ||
+	    val == TG3_CL45_D7_EEERES_STAT_LP_100TX) {
+		dest->eee_active = 1;
+	} else
+		dest->eee_active = 0;
+
+	if (val == TG3_CL45_D7_EEERES_STAT_LP_1000T)
+		dest->lp_advertised = ADVERTISED_1000baseT_Full;
+	else
+		dest->lp_advertised = ADVERTISED_100baseT_Full;
+
+	/* Pull advertised and eee_enabled settings */
+	if (tg3_phy_cl45_read(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, &val))
+		return;
+
+	dest->eee_enabled = !!val;
+
+	dest->advertised = 0;
+	if (val & MDIO_AN_EEE_ADV_100TX)
+		dest->advertised = ADVERTISED_100baseT_Full;
+	if (val & MDIO_AN_EEE_ADV_1000T)
+		dest->advertised |= ADVERTISED_1000baseT_Full;
+
+	/* Pull tx_lpi_enabled */
+	val = tr32(TG3_CPMU_EEE_MODE);
+	dest->tx_lpi_enabled = !!(val & TG3_CPMU_EEEMD_LPI_IN_TX);
+
+	/* Pull lpi timer value */
+	dest->tx_lpi_timer = tr32(TG3_CPMU_EEE_DBTMR1) & 0xffff;
+}
+
 static void tg3_phy_eee_adjust(struct tg3 *tp, bool current_link_up)
 {
 	u32 val;
@@ -2343,11 +2389,8 @@ static void tg3_phy_eee_adjust(struct tg3 *tp, bool current_link_up)
 
 		tw32(TG3_CPMU_EEE_CTRL, eeectl);
 
-		tg3_phy_cl45_read(tp, MDIO_MMD_AN,
-				  TG3_CL45_D7_EEERES_STAT, &val);
-
-		if (val == TG3_CL45_D7_EEERES_STAT_LP_1000T ||
-		    val == TG3_CL45_D7_EEERES_STAT_LP_100TX)
+		tg3_eee_pull_config(tp, NULL);
+		if (tp->eee.eee_active)
 			tp->setlpicnt = 2;
 	}
 
@@ -9522,16 +9565,17 @@ static int tg3_reset_hw(struct tg3 *tp, bool reset_phy)
 	if (tg3_flag(tp, INIT_COMPLETE))
 		tg3_abort_hw(tp, 1);
 
-	/* Enable MAC control of LPI */
-	if (tp->phy_flags & TG3_PHYFLG_EEE_CAP)
-		tg3_setup_eee(tp);
-
 	if ((tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN) &&
 	    !(tp->phy_flags & TG3_PHYFLG_USER_CONFIGURED)) {
 		tg3_phy_pull_config(tp);
+		tg3_eee_pull_config(tp, NULL);
 		tp->phy_flags |= TG3_PHYFLG_USER_CONFIGURED;
 	}
 
+	/* Enable MAC control of LPI */
+	if (tp->phy_flags & TG3_PHYFLG_EEE_CAP)
+		tg3_setup_eee(tp);
+
 	if (reset_phy)
 		tg3_phy_reset(tp);
 
-- 
1.8.1.4
