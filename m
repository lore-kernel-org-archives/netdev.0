From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next-2.6 4/11] bnx2x: Protect code with NOMCP
Date: Mon, 19 Apr 2010 14:13:49 +0300
Message-ID: <1271675629.6900.269.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2048 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706Ab0DSLNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 07:13:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't run code that can't be run if MCP is not present.
This will prevent NULL pointer dereferencing.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   44 ++++++++++++++++++++++++++++++++------------
 1 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 298d3e5..4861ee3 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -513,6 +513,10 @@ static void bnx2x_fw_dump(struct bnx2x *bp)
 	__be32 data[9];
 	int word;
 
+	if (BP_NOMCP(bp)) {
+		BNX2X_ERR("NO MCP - can not dump\n");
+		return;
+	}
 	mark = REG_RD(bp, MCP_REG_MCPR_SCRATCH + 0xf104);
 	mark = ((mark + 0x3) & ~0x3);
 	pr_err("begin fw dump (mark 0x%x)\n", mark);
@@ -2279,11 +2283,14 @@ static void bnx2x__link_reset(struct bnx2x *bp)
 
 static u8 bnx2x_link_test(struct bnx2x *bp)
 {
-	u8 rc;
+	u8 rc = 0;
 
-	bnx2x_acquire_phy_lock(bp);
-	rc = bnx2x_test_link(&bp->link_params, &bp->link_vars);
-	bnx2x_release_phy_lock(bp);
+	if (!BP_NOMCP(bp)) {
+		bnx2x_acquire_phy_lock(bp);
+		rc = bnx2x_test_link(&bp->link_params, &bp->link_vars);
+		bnx2x_release_phy_lock(bp);
+	} else
+		BNX2X_ERR("Bootcode is missing - can not test link\n");
 
 	return rc;
 }
@@ -4275,7 +4282,6 @@ static int bnx2x_hw_stats_update(struct bnx2x *bp)
 		u32 lo;
 		u32 hi;
 	} diff;
-	u32 nig_timer_max;
 
 	if (bp->link_vars.mac_type == MAC_TYPE_BMAC)
 		bnx2x_bmac_stats_update(bp);
@@ -4306,10 +4312,14 @@ static int bnx2x_hw_stats_update(struct bnx2x *bp)
 
 	pstats->host_port_stats_start = ++pstats->host_port_stats_end;
 
-	nig_timer_max = SHMEM_RD(bp, port_mb[BP_PORT(bp)].stat_nig_timer);
-	if (nig_timer_max != estats->nig_timer_max) {
-		estats->nig_timer_max = nig_timer_max;
-		BNX2X_ERR("NIG timer max (%u)\n", estats->nig_timer_max);
+	if (!BP_NOMCP(bp)) {
+		u32 nig_timer_max =
+			SHMEM_RD(bp, port_mb[BP_PORT(bp)].stat_nig_timer);
+		if (nig_timer_max != estats->nig_timer_max) {
+			estats->nig_timer_max = nig_timer_max;
+			BNX2X_ERR("NIG timer max (%u)\n",
+				  estats->nig_timer_max);
+		}
 	}
 
 	return 0;
@@ -6376,10 +6386,14 @@ static void bnx2x_init_pxp(struct bnx2x *bp)
 
 static void bnx2x_setup_fan_failure_detection(struct bnx2x *bp)
 {
+	int is_required;
 	u32 val;
-	u8 port;
-	u8 is_required = 0;
+	int port;
 
+	if (BP_NOMCP(bp))
+		return;
+
+	is_required = 0;
 	val = SHMEM_RD(bp, dev_info.shared_hw_config.config2) &
 	      SHARED_HW_CFG_FAN_FAILURE_MASK;
 
@@ -9687,7 +9701,7 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 
 	bp->e1hov = 0;
 	bp->e1hmf = 0;
-	if (CHIP_IS_E1H(bp)) {
+	if (CHIP_IS_E1H(bp) && !BP_NOMCP(bp)) {
 		bp->mf_config =
 			SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
 
@@ -11362,6 +11376,9 @@ static int bnx2x_test_loopback(struct bnx2x *bp, u8 link_up)
 {
 	int rc = 0, res;
 
+	if (BP_NOMCP(bp))
+		return rc;
+
 	if (!netif_running(bp->dev))
 		return BNX2X_LOOPBACK_FAILED;
 
@@ -11409,6 +11426,9 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 	int i, rc;
 	u32 magic, crc;
 
+	if (BP_NOMCP(bp))
+		return 0;
+
 	rc = bnx2x_nvram_read(bp, 0, data, 4);
 	if (rc) {
 		DP(NETIF_MSG_PROBE, "magic value read (rc %d)\n", rc);
-- 
1.6.3.3




