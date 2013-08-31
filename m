From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net] tg3: Don't turn off led on 5719 serdes port 0
Date: Fri, 30 Aug 2013 17:01:36 -0700
Message-ID: <1377907296-25737-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2032 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751896Ab3HaABp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 20:01:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Sujir <nsujir@broadcom.com>

Turning off led on port 0 of the 5719 serdes causes all other ports to
lose power and stop functioning. Add tg3_phy_led_bug() function to check
for this condition. We use a switch() in tg3_phy_led_bug() for
consistency with the tg3_phy_power_bug() function.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 2e55ee2..5701f3d 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3030,6 +3030,19 @@ static bool tg3_phy_power_bug(struct tg3 *tp)
 	return false;
 }
 
+static bool tg3_phy_led_bug(struct tg3 *tp)
+{
+	switch (tg3_asic_rev(tp)) {
+	case ASIC_REV_5719:
+		if ((tp->phy_flags & TG3_PHYFLG_MII_SERDES) &&
+		    !tp->pci_fn)
+			return true;
+		return false;
+	}
+
+	return false;
+}
+
 static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 {
 	u32 val;
@@ -3077,8 +3090,9 @@ static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 		}
 		return;
 	} else if (do_low_power) {
-		tg3_writephy(tp, MII_TG3_EXT_CTRL,
-			     MII_TG3_EXT_CTRL_FORCE_LED_OFF);
+		if (!tg3_phy_led_bug(tp))
+			tg3_writephy(tp, MII_TG3_EXT_CTRL,
+				     MII_TG3_EXT_CTRL_FORCE_LED_OFF);
 
 		val = MII_TG3_AUXCTL_PCTL_100TX_LPWR |
 		      MII_TG3_AUXCTL_PCTL_SPR_ISOLATE |
-- 
1.8.1.4
