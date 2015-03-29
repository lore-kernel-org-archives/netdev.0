From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/3] bnx2x: Count number of link changes
Date: Sun, 29 Mar 2015 10:05:00 +0300
Message-ID: <1427612701-13469-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1427612701-13469-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yaniv Rosner <Yaniv.Rosner@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:24764 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751057AbbC2HGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 03:06:04 -0400
In-Reply-To: <1427612701-13469-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <Yaniv.Rosner@qlogic.com>

Number of link changes are now being stored in shared memory [by all possible
link owners], for management use [as well as possible debug information for
dumps].

Signed-off-by: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |  4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 25 ++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 06df560..058bc73 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -2258,8 +2258,8 @@ struct shmem2_region {
 	#define LINK_SFP_EEPROM_COMP_CODE_LRM	0x00004000
 
 	u32 reserved5[2];
-	u32 reserved6[PORT_MAX];
-
+	u32 link_change_count[PORT_MAX];        /* Offset 0x160-0x164 */
+	#define LINK_CHANGE_COUNT_MASK 0xff     /* Offset 0x168 */
 	/* driver version for each personality */
 	struct os_drv_ver func_os_drv_ver[E2_FUNC_MAX]; /* Offset 0x16c */
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index a5b1743..f770de8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -6758,6 +6758,25 @@ static int bnx2x_update_link_up(struct link_params *params,
 	msleep(20);
 	return rc;
 }
+
+static void bnx2x_chng_link_count(struct link_params *params, bool clear)
+{
+	struct bnx2x *bp = params->bp;
+	u32 addr, val;
+
+	/* Verify the link_change_count is supported by the MFW */
+	if (!(SHMEM2_HAS(bp, link_change_count)))
+		return;
+
+	addr = params->shmem2_base +
+		offsetof(struct shmem2_region, link_change_count[params->port]);
+	if (clear)
+		val = 0;
+	else
+		val = REG_RD(bp, addr) + 1;
+	REG_WR(bp, addr, val);
+}
+
 /* The bnx2x_link_update function should be called upon link
  * interrupt.
  * Link is considered up as follows:
@@ -6776,6 +6795,7 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	struct link_vars phy_vars[MAX_PHYS];
 	u8 port = params->port;
 	u8 link_10g_plus, phy_index;
+	u32 prev_link_status = vars->link_status;
 	u8 ext_phy_link_up = 0, cur_link_up;
 	int rc = 0;
 	u8 is_mi_int = 0;
@@ -7015,6 +7035,9 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	else
 		rc = bnx2x_update_link_down(params, vars);
 
+	if ((prev_link_status ^ vars->link_status) & LINK_STATUS_LINK_UP)
+		bnx2x_chng_link_count(params, false);
+
 	/* Update MCP link status was changed */
 	if (params->feature_config_flags & FEATURE_CONFIG_BC_SUPPORTS_AFEX)
 		bnx2x_fw_command(bp, DRV_MSG_CODE_LINK_STATUS_CHANGED, 0);
@@ -12658,6 +12681,7 @@ int bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	params->link_flags = PHY_INITIALIZED;
 	/* Driver opens NIG-BRB filters */
 	bnx2x_set_rx_filter(params, 1);
+	bnx2x_chng_link_count(params, true);
 	/* Check if link flap can be avoided */
 	lfa_status = bnx2x_check_lfa(params);
 
@@ -12732,6 +12756,7 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	DP(NETIF_MSG_LINK, "Resetting the link of port %d\n", port);
 	/* Disable attentions */
 	vars->link_status = 0;
+	bnx2x_chng_link_count(params, true);
 	bnx2x_update_mng(params, vars->link_status);
 	vars->eee_status &= ~(SHMEM_EEE_LP_ADV_STATUS_MASK |
 			      SHMEM_EEE_ACTIVE_BIT);
-- 
1.9.3
