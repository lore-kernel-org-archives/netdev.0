From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 3/4] tg3: Simplify tg3_phy_eee_config_ok() by
 reusing tg3_eee_pull_config()
Date: Fri, 17 May 2013 08:19:49 -0700
Message-ID: <1368803990-10098-4-git-send-email-nsujir@broadcom.com>
References: <1368803990-10098-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2640 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755218Ab3EQPUF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 May 2013 11:20:05 -0400
In-Reply-To: <1368803990-10098-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eee_config_ok() was checking only for mismatch in advertised settings.
This patch expands the scope of eee_config_ok() to check for mismatch in
the other eee settings. On mismatch we will require a call setup_eee()
to push the configured settings to the hardware.

Reviewed-by: Ben Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 75b38c4..3aeb98f 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4558,26 +4558,27 @@ static int tg3_init_5401phy_dsp(struct tg3 *tp)
 
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
+	tg3_eee_pull_config(tp, &eee);
 
+	if (tp->eee.eee_enabled) {
+		if (tp->eee.advertised != eee.advertised)
+			return false;
 
-	if (advertising & ADVERTISED_100baseT_Full)
-		tgtadv |= MDIO_AN_EEE_ADV_100TX;
-	if (advertising & ADVERTISED_1000baseT_Full)
-		tgtadv |= MDIO_AN_EEE_ADV_1000T;
+		if (tp->eee.tx_lpi_timer != eee.tx_lpi_timer)
+			return false;
 
-	if (val != tgtadv)
-		return false;
+		if (tp->eee.tx_lpi_enabled != eee.tx_lpi_enabled)
+			return false;
+	} else {
+		/* EEE is disabled but we're advertising */
+		if (eee.advertised)
+			return false;
+	}
 
 	return true;
 }
@@ -4880,8 +4881,10 @@ static int tg3_setup_copper_phy(struct tg3 *tp, bool force_reset)
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
