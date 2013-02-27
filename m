From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 1/3] bnx2x: Fix port identification for the 84834
Date: Thu, 28 Feb 2013 01:06:44 +0200
Message-ID: <1362006406-2489-2-git-send-email-yanivr@broadcom.com>
References: <1362006406-2489-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2378 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752556Ab3B0VLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 16:11:21 -0500
In-Reply-To: <1362006406-2489-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the "ethtool -p" for boards with BCM84834, by using LED4 of the PHY 
to toggle the link LED while keeping interrupt disabled to avoid NIG attentions,
and at the end restore NIG to previous state.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   60 ++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    3 +-
 2 files changed, 62 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 1663e0b..4719ab1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10422,6 +10422,28 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 					 MDIO_PMA_DEVAD,
 					 MDIO_PMA_REG_8481_LED1_MASK,
 					 0x0);
+			if (phy->type ==
+			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834) {
+				/* Disable MI_INT interrupt before setting LED4
+				 * source to constant off.
+				 */
+				if (REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 +
+					   params->port*4) &
+				    NIG_MASK_MI_INT) {
+					params->link_flags |=
+					LINK_FLAGS_INT_DISABLED;
+
+					bnx2x_bits_dis(
+						bp,
+						NIG_REG_MASK_INTERRUPT_PORT0 +
+						params->port*4,
+						NIG_MASK_MI_INT);
+				}
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_SIGNAL_MASK,
+						 0x0);
+			}
 		}
 		break;
 	case LED_MODE_ON:
@@ -10468,6 +10490,28 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 					 MDIO_PMA_DEVAD,
 					 MDIO_PMA_REG_8481_LED1_MASK,
 					 0x20);
+			if (phy->type ==
+			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834) {
+				/* Disable MI_INT interrupt before setting LED4
+				 * source to constant on.
+				 */
+				if (REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 +
+					   params->port*4) &
+				    NIG_MASK_MI_INT) {
+					params->link_flags |=
+					LINK_FLAGS_INT_DISABLED;
+
+					bnx2x_bits_dis(
+						bp,
+						NIG_REG_MASK_INTERRUPT_PORT0 +
+						params->port*4,
+						NIG_MASK_MI_INT);
+				}
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_SIGNAL_MASK,
+						 0x20);
+			}
 		}
 		break;
 
@@ -10532,6 +10576,22 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 					 MDIO_PMA_DEVAD,
 					 MDIO_PMA_REG_8481_LINK_SIGNAL,
 					 val);
+			if (phy->type ==
+			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834) {
+				/* Restore LED4 source to external link,
+				 * and re-enable interrupts.
+				 */
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_SIGNAL_MASK,
+						 0x40);
+				if (params->link_flags &
+				    LINK_FLAGS_INT_DISABLED) {
+					bnx2x_link_int_enable(params);
+					params->link_flags &=
+						~LINK_FLAGS_INT_DISABLED;
+				}
+			}
 		}
 		break;
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index d25c7d7..be5c195 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -307,7 +307,8 @@ struct link_params {
 	struct bnx2x *bp;
 	u16 req_fc_auto_adv; /* Should be set to TX / BOTH when
 				req_flow_ctrl is set to AUTO */
-	u16 rsrv1;
+	u16 link_flags;
+#define LINK_FLAGS_INT_DISABLED		(1<<0)
 	u32 lfa_base;
 };
 
-- 
1.7.7.1
