From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] sky2: fixes for Yukon EC_U chip revisions
Date: Fri, 01 Dec 2006 14:29:35 -0800
Message-ID: <20061201223219.590247771@osdl.org>
References: <20061201222931.730523290@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:15801 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162127AbWLAWen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 17:34:43 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-ec-u-rev.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update workarounds for 88E803X based on the latest SysKonnect vendor
driver version (8.41). Tested on EC_U rev A1, only.
These up the receive performance.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   13 ++++++-------
 drivers/net/sky2.h |    9 +++++++--
 2 files changed, 13 insertions(+), 9 deletions(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-12-01 14:23:27.000000000 -0800
+++ netdev-2.6/drivers/net/sky2.c	2006-12-01 14:23:30.000000000 -0800
@@ -677,17 +677,15 @@
 	/* Flush Rx MAC FIFO on any flow control or error */
 	sky2_write16(hw, SK_REG(port, RX_GMF_FL_MSK), GMR_FS_ANY_ERR);
 
-	/* Set threshold to 0xa (64 bytes)
-	 *  ASF disabled so no need to do WA dev #4.30
-	 */
-	sky2_write16(hw, SK_REG(port, RX_GMF_FL_THR), RX_GMF_FL_THR_DEF);
+	/* Set threshold to 0xa (64 bytes) + 1 to workaround pause bug  */
+	sky2_write16(hw, SK_REG(port, RX_GMF_FL_THR), RX_GMF_FL_THR_DEF+1);
 
 	/* Configure Tx MAC FIFO */
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_CLR);
 	sky2_write16(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_OPER_ON);
 
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
-		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 512/8);
+		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
 		if (hw->dev[port]->mtu > ETH_DATA_LEN) {
 			/* set Tx GMAC FIFO Almost Empty Threshold */
@@ -1061,7 +1059,8 @@
 	sky2->rx_put = sky2->rx_next = 0;
 	sky2_qset(hw, rxq);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U && hw->chip_rev >= 2) {
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
+	    (hw->chip_rev == CHIP_REV_YU_EC_U_A1 || hw->chip_rev == CHIP_REV_YU_EC_U_B0)) {
 		/* MAC Rx RAM Read is controlled by hardware */
 		sky2_write32(hw, Q_ADDR(rxq, Q_F), F_M_RX_RAM_DIS);
 	}
@@ -1510,7 +1509,7 @@
 
 	/* WA for dev. #4.209 */
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U
-	    && hw->chip_rev == CHIP_REV_YU_EC_U_A1)
+	    && (hw->chip_rev == CHIP_REV_YU_EC_U_A1 || hw->chip_rev == CHIP_REV_YU_EC_U_B0))
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
 			     sky2->speed != SPEED_1000 ?
 			     TX_STFW_ENA : TX_STFW_DIS);
--- netdev-2.6.orig/drivers/net/sky2.h	2006-12-01 14:19:32.000000000 -0800
+++ netdev-2.6/drivers/net/sky2.h	2006-12-01 14:23:30.000000000 -0800
@@ -383,8 +383,13 @@
 	CHIP_REV_YU_EC_A2    = 1,  /* Chip Rev. for Yukon-EC A2 */
 	CHIP_REV_YU_EC_A3    = 2,  /* Chip Rev. for Yukon-EC A3 */
 
-	CHIP_REV_YU_EC_U_A0  = 0,
-	CHIP_REV_YU_EC_U_A1  = 1,
+	CHIP_REV_YU_EC_U_A0  = 1,
+	CHIP_REV_YU_EC_U_A1  = 2,
+	CHIP_REV_YU_EC_U_B0  = 3,
+
+	CHIP_REV_YU_FE_A1    = 1,
+	CHIP_REV_YU_FE_A2    = 2,
+
 };
 
 /*	B2_Y2_CLK_GATE	 8 bit	Clock Gating (Yukon-2 only) */

--
Stephen Hemminger <shemminger@osdl.org>

