From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 06/11] tg3: Add SGMII phy support for 5719/5718
 serdes
Date: Tue, 9 Apr 2013 11:48:06 -0700
Message-ID: <1365533291-5672-7-git-send-email-nsujir@broadcom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2273 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761645Ab3DISsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 14:48:53 -0400
In-Reply-To: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 51 ++++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/broadcom/tg3.h |  7 +++++
 2 files changed, 51 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 568dd07..f53e309 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5465,11 +5465,50 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 
 static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 {
-	int current_link_up, err = 0;
+	int current_link_up = 0, err = 0;
 	u32 bmsr, bmcr;
-	u16 current_speed;
-	u8 current_duplex;
-	u32 local_adv, remote_adv;
+	u16 current_speed = SPEED_UNKNOWN;
+	u8 current_duplex = DUPLEX_UNKNOWN;
+	u32 local_adv, remote_adv, sgsr;
+
+	if ((tg3_asic_rev(tp) == ASIC_REV_5719 ||
+	     tg3_asic_rev(tp) == ASIC_REV_5720) &&
+	     !tg3_readphy(tp, SERDES_TG3_1000X_STATUS, &sgsr) &&
+	     (sgsr & SERDES_TG3_SGMII_MODE)) {
+
+		if (force_reset)
+			tg3_phy_reset(tp);
+
+		tp->mac_mode &= ~MAC_MODE_PORT_MODE_MASK;
+
+		if (!(sgsr & SERDES_TG3_LINK_UP)) {
+			tp->mac_mode |= MAC_MODE_PORT_MODE_GMII;
+		} else {
+			current_link_up = 1;
+			if (sgsr & SERDES_TG3_SPEED_1000) {
+				current_speed = SPEED_1000;
+				tp->mac_mode |= MAC_MODE_PORT_MODE_GMII;
+			} else if (sgsr & SERDES_TG3_SPEED_100) {
+				current_speed = SPEED_100;
+				tp->mac_mode |= MAC_MODE_PORT_MODE_MII;
+			} else {
+				current_speed = SPEED_10;
+				tp->mac_mode |= MAC_MODE_PORT_MODE_MII;
+			}
+
+			if (sgsr & SERDES_TG3_FULL_DUPLEX)
+				current_duplex = DUPLEX_FULL;
+			else
+				current_duplex = DUPLEX_HALF;
+		}
+
+		tw32_f(MAC_MODE, tp->mac_mode);
+		udelay(40);
+
+		tg3_clear_mac_status(tp);
+
+		goto fiber_setup_done;
+	}
 
 	tp->mac_mode |= MAC_MODE_PORT_MODE_GMII;
 	tw32_f(MAC_MODE, tp->mac_mode);
@@ -5480,9 +5519,6 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 	if (force_reset)
 		tg3_phy_reset(tp);
 
-	current_link_up = 0;
-	current_speed = SPEED_UNKNOWN;
-	current_duplex = DUPLEX_UNKNOWN;
 	tp->link_config.rmt_adv = 0;
 
 	err |= tg3_readphy(tp, MII_BMSR, &bmsr);
@@ -5600,6 +5636,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 		}
 	}
 
+fiber_setup_done:
 	if (current_link_up == 1 && current_duplex == DUPLEX_FULL)
 		tg3_setup_flow_control(tp, local_adv, remote_adv);
 
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 1cdc1b6..fd00a38 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2371,6 +2371,13 @@
 #define MII_TG3_FET_SHDW_AUXSTAT2	0x1b
 #define  MII_TG3_FET_SHDW_AUXSTAT2_APD	0x0020
 
+/* Serdes PHY Register Definitions */
+#define SERDES_TG3_1000X_STATUS		0x14
+#define  SERDES_TG3_SGMII_MODE		 0x0001
+#define  SERDES_TG3_LINK_UP		 0x0002
+#define  SERDES_TG3_FULL_DUPLEX		 0x0004
+#define  SERDES_TG3_SPEED_100		 0x0008
+#define  SERDES_TG3_SPEED_1000		 0x0010
 
 /* APE registers.  Accessible through BAR1 */
 #define TG3_APE_GPIO_MSG		0x0008
-- 
1.8.1.4
