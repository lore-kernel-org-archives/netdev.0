From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 19/27] e1000e: 82571 Serdes can fail to get link
Date: Fri, 10 Dec 2010 02:03:26 -0800
Message-ID: <1291975414-30487-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:52072 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751983Ab0LJKEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 05:04:12 -0500
To: davem@davemloft.net
In-Reply-To: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When link partner is sending continuous Config symbols, the 82571 Serdes
FIFO can overflow resulting in Invalid bit getting set.  To resolve this,
if Sync and Config bits are both 1 ignore the Invalid bit and restart
auto-negotiation.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/82571.c |   35 +++++++++++++++++++++++++++--------
 1 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 280d41f..e57e409 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -52,6 +52,7 @@
 			      (ID_LED_DEF1_DEF2))
 
 #define E1000_GCR_L1_ACT_WITHOUT_L0S_RX 0x08000000
+#define AN_RETRY_COUNT          5 /* Autoneg Retry Count value */
 #define E1000_BASE1000T_STATUS          10
 #define E1000_IDLE_ERROR_COUNT_MASK     0xFF
 #define E1000_RECEIVE_ERROR_COUNTER     21
@@ -1503,6 +1504,8 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 	u32 rxcw;
 	u32 ctrl;
 	u32 status;
+	u32 txcw;
+	u32 i;
 	s32 ret_val = 0;
 
 	ctrl = er32(CTRL);
@@ -1613,16 +1616,32 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 			e_dbg("ANYSTATE  -> DOWN\n");
 		} else {
 			/*
-			 * We have sync, and can tolerate one invalid (IV)
-			 * codeword before declaring link down, so reread
-			 * to look again.
+			 * Check several times, if Sync and Config
+			 * both are consistently 1 then simply ignore
+			 * the Invalid bit and restart Autoneg
 			 */
-			udelay(10);
-			rxcw = er32(RXCW);
-			if (rxcw & E1000_RXCW_IV) {
-				mac->serdes_link_state = e1000_serdes_link_down;
+			for (i = 0; i < AN_RETRY_COUNT; i++) {
+				udelay(10);
+				rxcw = er32(RXCW);
+				if ((rxcw & E1000_RXCW_IV) &&
+				    !((rxcw & E1000_RXCW_SYNCH) &&
+				      (rxcw & E1000_RXCW_C))) {
+					mac->serdes_has_link = false;
+					mac->serdes_link_state =
+					    e1000_serdes_link_down;
+					e_dbg("ANYSTATE  -> DOWN\n");
+					break;
+				}
+			}
+
+			if (i == AN_RETRY_COUNT) {
+				txcw = er32(TXCW);
+				txcw |= E1000_TXCW_ANE;
+				ew32(TXCW, txcw);
+				mac->serdes_link_state =
+				    e1000_serdes_link_autoneg_progress;
 				mac->serdes_has_link = false;
-				e_dbg("ANYSTATE  -> DOWN\n");
+				e_dbg("ANYSTATE  -> AN_PROG\n");
 			}
 		}
 	}
-- 
1.7.3.2

