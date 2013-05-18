From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH v2 net-next 3/4] tg3: Simplify tg3_phy_eee_config_ok()
 by reusing tg3_eee_pull_config()
Date: Sat, 18 May 2013 09:26:54 -0700
Message-ID: <1368894415-27678-4-git-send-email-nsujir@broadcom.com>
References: <1368894415-27678-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3660 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752660Ab3ERQ1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 May 2013 12:27:23 -0400
In-Reply-To: <1368894415-27678-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eee_config_ok() was checking only for mismatch in advertised settings.
This patch expands the scope of eee_config_ok() to check for mismatch in
the other eee settings. On mismatch we will require a call to
tg3_setup_eee() to push the configured settings to the hardware.

Reviewed-by: Ben Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 8aec446..2d9b303 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4552,26 +4552,23 @@ static int tg3_init_5401phy_dsp(struct tg3 *tp)
 
 static bool tg3_phy_eee_config_ok(struct tg3 *tp)
 {
-	u32 val;
-	u32 tgtadv = 0;
-	u32 advertising = tp->link_config.advertising;
+	struct ethtool_eee eee;
 
 	if (!(tp->phy_flags & TG3_PHYFLG_EEE_CAP))
 		return true;
 
-	if (tg3_phy_cl45_read(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, &val))
-		return false;
-
-	val &= (MDIO_AN_EEE_ADV_100TX | MDIO_AN_EEE_ADV_1000T);
-
-
-	if (advertising & ADVERTISED_100baseT_Full)
-		tgtadv |= MDIO_AN_EEE_ADV_100TX;
-	if (advertising & ADVERTISED_1000baseT_Full)
-		tgtadv |= MDIO_AN_EEE_ADV_1000T;
+	tg3_eee_pull_config(tp, &eee);
 
-	if (val != tgtadv)
-		return false;
+	if (tp->eee.eee_enabled) {
+		if (tp->eee.advertised != eee.advertised ||
+		    tp->eee.tx_lpi_timer != eee.tx_lpi_timer ||
+		    tp->eee.tx_lpi_enabled != eee.tx_lpi_enabled)
+			return false;
+	} else {
+		/* EEE is disabled but we're advertising */
+		if (eee.advertised)
+			return false;
+	}
 
 	return true;
 }
@@ -4874,8 +4871,10 @@ static int tg3_setup_copper_phy(struct tg3 *tp, bool force_reset)
 			 */
 			if (!eee_config_ok &&
 			    (tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN) &&
-			    !force_reset)
+			    !force_reset) {
+				tg3_setup_eee(tp);
 				tg3_phy_reset(tp);
+			}
 		} else {
 			if (!(bmcr & BMCR_ANENABLE) &&
 			    tp->link_config.speed == current_speed &&
-- 
1.8.1.4
