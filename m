From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 09/11] tg3: Reset the phy to allow modified EEE
 settings to take effect
Date: Tue, 9 Apr 2013 11:48:09 -0700
Message-ID: <1365533291-5672-10-git-send-email-nsujir@broadcom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2279 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761262Ab3DISsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 14:48:53 -0400
In-Reply-To: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When LFA is enabled, we don't reset the phy. But EEE settings changes
don't take effect until the phy is reset. Add a phy reset when we detect
a changed EEE setting.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 38 +++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index face04f..2bd2213 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4491,6 +4491,32 @@ static int tg3_init_5401phy_dsp(struct tg3 *tp)
 	return err;
 }
 
+static bool tg3_phy_eee_config_ok(struct tg3 *tp)
+{
+	u32 val;
+	u32 tgtadv = 0;
+	u32 advertising = tp->link_config.advertising;
+
+	if (!(tp->phy_flags & TG3_PHYFLG_EEE_CAP))
+		return true;
+
+	if (tg3_phy_cl45_read(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, &val))
+		return false;
+
+	val &= (MDIO_AN_EEE_ADV_100TX | MDIO_AN_EEE_ADV_1000T);
+
+
+	if (advertising & ADVERTISED_100baseT_Full)
+		tgtadv |= MDIO_AN_EEE_ADV_100TX;
+	if (advertising & ADVERTISED_1000baseT_Full)
+		tgtadv |= MDIO_AN_EEE_ADV_1000T;
+
+	if (val != tgtadv)
+		return false;
+
+	return true;
+}
+
 static bool tg3_phy_copper_an_config_ok(struct tg3 *tp, u32 *lcladv)
 {
 	u32 advmsk, tgtadv, advertising;
@@ -4739,10 +4765,22 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 		tp->link_config.active_duplex = current_duplex;
 
 		if (tp->link_config.autoneg == AUTONEG_ENABLE) {
+			bool eee_config_ok = tg3_phy_eee_config_ok(tp);
+
 			if ((bmcr & BMCR_ANENABLE) &&
+			    eee_config_ok &&
 			    tg3_phy_copper_an_config_ok(tp, &lcl_adv) &&
 			    tg3_phy_copper_fetch_rmtadv(tp, &rmt_adv))
 				current_link_up = 1;
+
+			/* EEE settings changes take effect only after a phy
+			 * reset.  If we have skipped a reset due to Link Flap
+			 * Avoidance being enabled, do it now.
+			 */
+			if (!eee_config_ok &&
+			    (tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN) &&
+			    !force_reset)
+				tg3_phy_reset(tp);
 		} else {
 			if (!(bmcr & BMCR_ANENABLE) &&
 			    tp->link_config.speed == current_speed &&
-- 
1.8.1.4
