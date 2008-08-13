From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 01/25] bnx2x: FW (bootcode) interface fixes
Date: Wed, 13 Aug 2008 17:11:50 +0300
Message-ID: <1218636710.547.75.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3540 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751468AbYHMOML (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:12:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FW (bootcode) interface fixes
- Making sure that the device will not cause kernel panic of the
  bootcode is corrupted or missing
- Removing module debug parameter "nomcp" since no one should work 
  without the bootcode (this is a left over from the chip bring up days)
- Instead of waiting fix amount of time for bootcode response, sample it 
  every 10ms (usually the answer is ready after less than 10ms)

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   74 ++++++++++++++++++++++++++--------------------
 1 files changed, 42 insertions(+), 32 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 272a4bd..9eb8a3e 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -76,23 +76,21 @@ MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
+static int disable_tpa;
 static int use_inta;
 static int poll;
 static int debug;
-static int disable_tpa;
-static int nomcp;
 static int load_count[3]; /* 0-common, 1-port0, 2-port1 */
 static int use_multi;
 
+module_param(disable_tpa, int, 0);
 module_param(use_inta, int, 0);
 module_param(poll, int, 0);
 module_param(debug, int, 0);
-module_param(disable_tpa, int, 0);
-module_param(nomcp, int, 0);
+MODULE_PARM_DESC(disable_tpa, "disable the TPA (LRO) feature");
 MODULE_PARM_DESC(use_inta, "use INT#A instead of MSI-X");
 MODULE_PARM_DESC(poll, "use polling (for debug)");
 MODULE_PARM_DESC(debug, "default debug msglevel");
-MODULE_PARM_DESC(nomcp, "ignore management CPU");
 
 #ifdef BNX2X_MULTI
 module_param(use_multi, int, 0);
@@ -1940,37 +1938,47 @@ static void bnx2x_link_report(struct bnx2x *bp)
 
 static u8 bnx2x_initial_phy_init(struct bnx2x *bp)
 {
-	u8 rc;
+	if (!BP_NOMCP(bp)) {
+		u8 rc;
 
-	/* Initialize link parameters structure variables */
-	bp->link_params.mtu = bp->dev->mtu;
+		/* Initialize link parameters structure variables */
+		bp->link_params.mtu = bp->dev->mtu;
 
-	bnx2x_phy_hw_lock(bp);
-	rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
-	bnx2x_phy_hw_unlock(bp);
+		bnx2x_phy_hw_lock(bp);
+		rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
+		bnx2x_phy_hw_unlock(bp);
 
-	if (bp->link_vars.link_up)
-		bnx2x_link_report(bp);
+		if (bp->link_vars.link_up)
+			bnx2x_link_report(bp);
 
-	bnx2x_calc_fc_adv(bp);
+		bnx2x_calc_fc_adv(bp);
 
-	return rc;
+		return rc;
+	}
+	BNX2X_ERR("Bootcode is missing -not initializing link\n");
+	return -EINVAL;
 }
 
 static void bnx2x_link_set(struct bnx2x *bp)
 {
-	bnx2x_phy_hw_lock(bp);
-	bnx2x_phy_init(&bp->link_params, &bp->link_vars);
-	bnx2x_phy_hw_unlock(bp);
+	if (!BP_NOMCP(bp)) {
+		bnx2x_phy_hw_lock(bp);
+		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
+		bnx2x_phy_hw_unlock(bp);
 
-	bnx2x_calc_fc_adv(bp);
+		bnx2x_calc_fc_adv(bp);
+	} else
+		BNX2X_ERR("Bootcode is missing -not setting link\n");
 }
 
 static void bnx2x__link_reset(struct bnx2x *bp)
 {
-	bnx2x_phy_hw_lock(bp);
-	bnx2x_link_reset(&bp->link_params, &bp->link_vars);
-	bnx2x_phy_hw_unlock(bp);
+	if (!BP_NOMCP(bp)) {
+		bnx2x_phy_hw_lock(bp);
+		bnx2x_link_reset(&bp->link_params, &bp->link_vars);
+		bnx2x_phy_hw_unlock(bp);
+	} else
+		BNX2X_ERR("Bootcode is missing -not resetting link\n");
 }
 
 static u8 bnx2x_link_test(struct bnx2x *bp)
@@ -2374,7 +2382,7 @@ static int bnx2x_lock_alr(struct bnx2x *bp)
 		msleep(5);
 	}
 	if (!(val & (1L << 31))) {
-		BNX2X_ERR("Cannot acquire nvram interface\n");
+		BNX2X_ERR("Cannot acquire MCP access lock register\n");
 		rc = -EBUSY;
 	}
 
@@ -5638,18 +5646,23 @@ static u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 	int func = BP_FUNC(bp);
 	u32 seq = ++bp->fw_seq;
 	u32 rc = 0;
+	u32 cnt = 1;
+	u8 delay = CHIP_REV_IS_SLOW(bp) ? 100 : 10;
 
 	SHMEM_WR(bp, func_mb[func].drv_mb_header, (command | seq));
 	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB\n", (command | seq));
 
-	/* let the FW do it's magic ... */
-	msleep(100); /* TBD */
+	do {
+		/* let the FW do it's magic ... */
+		msleep(delay);
+
+		rc = SHMEM_RD(bp, func_mb[func].fw_mb_header);
 
-	if (CHIP_REV_IS_SLOW(bp))
-		msleep(900);
+		/* Give the FW up to 2 second (200*10ms) */
+	} while ((seq != (rc & FW_MSG_SEQ_NUMBER_MASK)) && (cnt++ < 200));
 
-	rc = SHMEM_RD(bp, func_mb[func].fw_mb_header);
-	DP(BNX2X_MSG_MCP, "read (%x) seq is (%x) from FW MB\n", rc, seq);
+	DP(BNX2X_MSG_MCP, "[after %d ms] read (%x) seq is (%x) from FW MB\n",
+	   cnt*delay, rc, seq);
 
 	/* is this a reply to our command? */
 	if (seq == (rc & FW_MSG_SEQ_NUMBER_MASK)) {
@@ -7337,9 +7350,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	int func = BP_FUNC(bp);
 	int rc;
 
-	if (nomcp)
-		bp->flags |= NO_MCP_FLAG;
-
 	mutex_init(&bp->port.phy_mutex);
 
 	INIT_WORK(&bp->sp_task, bnx2x_sp_task);
-- 
1.5.3.2




