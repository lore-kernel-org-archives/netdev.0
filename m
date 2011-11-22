From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/4] tg3: Add MDI-X reporting
Date: Mon, 21 Nov 2011 17:01:20 -0800
Message-ID: <1321923680-7925-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2494 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757635Ab1KVBCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 20:02:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds MDI-X state reporting.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   24 +++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/tg3.h |    5 +++++
 2 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ea3c5f0..7ff5c72 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3932,6 +3932,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 	current_link_up = 0;
 	current_speed = SPEED_INVALID;
 	current_duplex = DUPLEX_INVALID;
+	tp->phy_flags &= ~TG3_PHYFLG_MDIX_STATE;
 
 	if (tp->phy_flags & TG3_PHYFLG_CAPACITIVE_COUPLING) {
 		err = tg3_phy_auxctl_read(tp,
@@ -4004,8 +4005,22 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 		}
 
 		if (current_link_up == 1 &&
-		    tp->link_config.active_duplex == DUPLEX_FULL)
+		    tp->link_config.active_duplex == DUPLEX_FULL) {
+			u32 reg, bit;
+
+			if (tp->phy_flags & TG3_PHYFLG_IS_FET) {
+				reg = MII_TG3_FET_GEN_STAT;
+				bit = MII_TG3_FET_GEN_STAT_MDIXSTAT;
+			} else {
+				reg = MII_TG3_EXT_STAT;
+				bit = MII_TG3_EXT_STAT_MDIX;
+			}
+
+			if (!tg3_readphy(tp, reg, &val) && (val & bit))
+				tp->phy_flags |= TG3_PHYFLG_MDIX_STATE;
+
 			tg3_setup_flow_control(tp, lcl_adv, rmt_adv);
+		}
 	}
 
 relink:
@@ -10290,9 +10305,16 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (netif_running(dev)) {
 		ethtool_cmd_speed_set(cmd, tp->link_config.active_speed);
 		cmd->duplex = tp->link_config.active_duplex;
+		if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES)) {
+			if (tp->phy_flags & TG3_PHYFLG_MDIX_STATE)
+				cmd->eth_tp_mdix = ETH_TP_MDI_X;
+			else
+				cmd->eth_tp_mdix = ETH_TP_MDI;
+		}
 	} else {
 		ethtool_cmd_speed_set(cmd, SPEED_INVALID);
 		cmd->duplex = DUPLEX_INVALID;
+		cmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
 	}
 	cmd->phy_address = tp->phy_addr;
 	cmd->transceiver = XCVR_INTERNAL;
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 8e2f380..9cc10a8 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2174,6 +2174,7 @@
 #define  MII_TG3_EXT_CTRL_TBI		0x8000
 
 #define MII_TG3_EXT_STAT		0x11 /* Extended status register */
+#define  MII_TG3_EXT_STAT_MDIX		0x2000
 #define  MII_TG3_EXT_STAT_LPASS		0x0100
 
 #define MII_TG3_RXR_COUNTERS		0x14 /* Local/Remote Receiver Counts */
@@ -2277,6 +2278,9 @@
 #define  MII_TG3_FET_PTEST_FRC_TX_LINK	0x1000
 #define  MII_TG3_FET_PTEST_FRC_TX_LOCK	0x0800
 
+#define MII_TG3_FET_GEN_STAT		0x1c
+#define  MII_TG3_FET_GEN_STAT_MDIXSTAT	0x2000
+
 #define MII_TG3_FET_TEST		0x1f
 #define  MII_TG3_FET_SHADOW_EN		0x0080
 
@@ -3135,6 +3139,7 @@ struct tg3 {
 #define TG3_PHYFLG_SERDES_PREEMPHASIS	0x00010000
 #define TG3_PHYFLG_PARALLEL_DETECT	0x00020000
 #define TG3_PHYFLG_EEE_CAP		0x00040000
+#define TG3_PHYFLG_MDIX_STATE		0x00200000
 
 	u32				led_ctrl;
 	u32				phy_otp;
-- 
1.7.3.4
