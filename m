From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 2/4] bnx2x: Link-flap avoidance in switch
 dependent mode
Date: Wed, 22 May 2013 15:22:37 +0300
Message-ID: <1369225359-5578-3-git-send-email-yuvalmin@broadcom.com>
References: <1369225359-5578-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4375 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755642Ab3EVMUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 08:20:46 -0400
In-Reply-To: <1369225359-5578-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

As part of the previous unload flow, probed devices will reset the chip
in order to clean the remains of the UNDI driver.
As a result, it's possible for the FW to toggle the link.

This toggling can prove fatal, as long periods without link can cause the
filesystem mount to fail as the storage protocol timeouts. This has been
observed against particular switches with long link re-establishment time.

This patch informs FW during the reset period that the link should not
be toggled - the FW will keep it alive until some interface will load and claim
the link as its own.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 10 ++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |  2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 19 ++++++++++++++++---
 4 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 3f42910..946450d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1937,6 +1937,8 @@ int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 void bnx2x_update_coalesce(struct bnx2x *bp);
 int bnx2x_get_cur_phy_idx(struct bnx2x *bp);
 
+bool bnx2x_port_after_undi(struct bnx2x *bp);
+
 static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 			   int wait)
 {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index b8fbe26..925d205 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2183,6 +2183,8 @@ alloc_mem_err:
 /* send load request to mcp and analyze response */
 static int bnx2x_nic_load_request(struct bnx2x *bp, u32 *load_code)
 {
+	u32 param;
+
 	/* init fw_seq */
 	bp->fw_seq =
 		(SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_mb_header) &
@@ -2195,9 +2197,13 @@ static int bnx2x_nic_load_request(struct bnx2x *bp, u32 *load_code)
 		 DRV_PULSE_SEQ_MASK);
 	BNX2X_DEV_INFO("drv_pulse 0x%x\n", bp->fw_drv_pulse_wr_seq);
 
+	param = DRV_MSG_CODE_LOAD_REQ_WITH_LFA;
+
+	if (IS_MF_SD(bp) && bnx2x_port_after_undi(bp))
+		param |= DRV_MSG_CODE_LOAD_REQ_FORCE_LFA;
+
 	/* load request */
-	(*load_code) = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ,
-					DRV_MSG_CODE_LOAD_REQ_WITH_LFA);
+	(*load_code) = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ, param);
 
 	/* if mcp fails to respond we must abort */
 	if (!(*load_code)) {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 12f00a4..5ef3f96 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1323,6 +1323,8 @@ struct drv_func_mb {
 	#define DRV_MSG_CODE_UNLOAD_SKIP_LINK_RESET     0x00000002
 
 	#define DRV_MSG_CODE_LOAD_REQ_WITH_LFA          0x0000100a
+	#define DRV_MSG_CODE_LOAD_REQ_FORCE_LFA         0x00002000
+
 	u32 fw_mb_header;
 	#define FW_MSG_CODE_MASK                        0xffff0000
 	#define FW_MSG_CODE_DRV_LOAD_COMMON             0x10100000
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b4c9dea..649880d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9780,6 +9780,21 @@ static bool bnx2x_prev_is_path_marked(struct bnx2x *bp)
 	return rc;
 }
 
+bool bnx2x_port_after_undi(struct bnx2x *bp)
+{
+	struct bnx2x_prev_path_list *entry;
+	bool val;
+
+	down(&bnx2x_prev_sem);
+
+	entry = bnx2x_prev_path_get_entry(bp);
+	val = !!(entry && (entry->undi & (1 << BP_PORT(bp))));
+
+	up(&bnx2x_prev_sem);
+
+	return val;
+}
+
 static int bnx2x_prev_mark_path(struct bnx2x *bp, bool after_undi)
 {
 	struct bnx2x_prev_path_list *tmp_list;
@@ -10036,7 +10051,6 @@ static int bnx2x_prev_unload(struct bnx2x *bp)
 {
 	int time_counter = 10;
 	u32 rc, fw, hw_lock_reg, hw_lock_val;
-	struct bnx2x_prev_path_list *prev_list;
 	BNX2X_DEV_INFO("Entering Previous Unload Flow\n");
 
 	/* clear hw from errors which may have resulted from an interrupted
@@ -10107,8 +10121,7 @@ static int bnx2x_prev_unload(struct bnx2x *bp)
 	}
 
 	/* Mark function if its port was used to boot from SAN */
-	prev_list = bnx2x_prev_path_get_entry(bp);
-	if (prev_list && (prev_list->undi & (1 << BP_PORT(bp))))
+	if (bnx2x_port_after_undi(bp))
 		bp->link_params.feature_config_flags |=
 			FEATURE_CONFIG_BOOT_FROM_SAN;
 
-- 
1.8.1.227.g44fe835
