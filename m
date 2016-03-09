From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/4] qed: Major changes to MB locking
Date: Wed, 9 Mar 2016 09:16:24 +0200
Message-ID: <1457507786-6603-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1457507786-6603-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:52070 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752583AbcCIHQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 02:16:56 -0500
In-Reply-To: <1457507786-6603-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@qlogic.com>

Driver interaction with the managemnt firmware is done via mailbox
commands which the management firmware periodically sample, as well
as placing of additional data in set places in the shared memory.
Each PF has a single designated mailbox address, and all flows that
require messaging to the management should use it.

This patch does 2 things:
 1. It re-defines the critical section surrounding the mailbox sending -
that section should include the setting of the shared memory as well as
the sending of the command [otherwise a race might send a command with
the data of a different command].
 2. It moves the locking scheme from using mutices into using spinlocks.
This lays the groundwork for sending MFW commands from non-sleepable
contexts.

Signed-off-by: Tomer Tayar <Tomer.Tayar@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 250 ++++++++++++++++++------------
 drivers/net/ethernet/qlogic/qed/qed_mcp.h |  14 +-
 2 files changed, 167 insertions(+), 97 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 2bf9824..6937c88 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -11,8 +11,8 @@
 #include <linux/delay.h>
 #include <linux/errno.h>
 #include <linux/kernel.h>
-#include <linux/mutex.h>
 #include <linux/slab.h>
+#include <linux/spinlock.h>
 #include <linux/string.h>
 #include "qed.h"
 #include "qed_hsi.h"
@@ -168,8 +168,8 @@ int qed_mcp_cmd_init(struct qed_hwfn *p_hwfn,
 	if (!p_info->mfw_mb_shadow || !p_info->mfw_mb_addr)
 		goto err;
 
-	/* Initialize the MFW mutex */
-	mutex_init(&p_info->mutex);
+	/* Initialize the MFW spinlock */
+	spin_lock_init(&p_info->lock);
 
 	return 0;
 
@@ -179,6 +179,52 @@ err:
 	return -ENOMEM;
 }
 
+/* Locks the MFW mailbox of a PF to ensure a single access.
+ * The lock is achieved in most cases by holding a spinlock, causing other
+ * threads to wait till a previous access is done.
+ * In some cases (currently when a [UN]LOAD_REQ commands are sent), the single
+ * access is achieved by setting a blocking flag, which will fail other
+ * competing contexts to send their mailboxes.
+ */
+static int qed_mcp_mb_lock(struct qed_hwfn *p_hwfn,
+			   u32 cmd)
+{
+	spin_lock_bh(&p_hwfn->mcp_info->lock);
+
+	/* The spinlock shouldn't be acquired when the mailbox command is
+	 * [UN]LOAD_REQ, since the engine is locked by the MFW, and a parallel
+	 * pending [UN]LOAD_REQ command of another PF together with a spinlock
+	 * (i.e. interrupts are disabled) - can lead to a deadlock.
+	 * It is assumed that for a single PF, no other mailbox commands can be
+	 * sent from another context while sending LOAD_REQ, and that any
+	 * parallel commands to UNLOAD_REQ can be cancelled.
+	 */
+	if (cmd == DRV_MSG_CODE_LOAD_DONE || cmd == DRV_MSG_CODE_UNLOAD_DONE)
+		p_hwfn->mcp_info->block_mb_sending = false;
+
+	if (p_hwfn->mcp_info->block_mb_sending) {
+		DP_NOTICE(p_hwfn,
+			  "Trying to send a MFW mailbox command [0x%x] in parallel to [UN]LOAD_REQ. Aborting.\n",
+			  cmd);
+		spin_unlock_bh(&p_hwfn->mcp_info->lock);
+		return -EBUSY;
+	}
+
+	if (cmd == DRV_MSG_CODE_LOAD_REQ || cmd == DRV_MSG_CODE_UNLOAD_REQ) {
+		p_hwfn->mcp_info->block_mb_sending = true;
+		spin_unlock_bh(&p_hwfn->mcp_info->lock);
+	}
+
+	return 0;
+}
+
+static void qed_mcp_mb_unlock(struct qed_hwfn	*p_hwfn,
+			      u32		cmd)
+{
+	if (cmd != DRV_MSG_CODE_LOAD_REQ && cmd != DRV_MSG_CODE_UNLOAD_REQ)
+		spin_unlock_bh(&p_hwfn->mcp_info->lock);
+}
+
 int qed_mcp_reset(struct qed_hwfn *p_hwfn,
 		  struct qed_ptt *p_ptt)
 {
@@ -187,6 +233,13 @@ int qed_mcp_reset(struct qed_hwfn *p_hwfn,
 	u32 org_mcp_reset_seq, cnt = 0;
 	int rc = 0;
 
+	/* Ensure that only a single thread is accessing the mailbox at a
+	 * certain time.
+	 */
+	rc = qed_mcp_mb_lock(p_hwfn, DRV_MSG_CODE_MCP_RESET);
+	if (rc != 0)
+		return rc;
+
 	/* Set drv command along with the updated sequence */
 	org_mcp_reset_seq = qed_rd(p_hwfn, p_ptt, MISCS_REG_GENERIC_POR_0);
 	DRV_MB_WR(p_hwfn, p_ptt, drv_mb_header,
@@ -209,6 +262,8 @@ int qed_mcp_reset(struct qed_hwfn *p_hwfn,
 		rc = -EAGAIN;
 	}
 
+	qed_mcp_mb_unlock(p_hwfn, DRV_MSG_CODE_MCP_RESET);
+
 	return rc;
 }
 
@@ -275,14 +330,12 @@ static int qed_do_mcp_cmd(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
-int qed_mcp_cmd(struct qed_hwfn *p_hwfn,
-		struct qed_ptt *p_ptt,
-		u32 cmd,
-		u32 param,
-		u32 *o_mcp_resp,
-		u32 *o_mcp_param)
+static int qed_mcp_cmd_and_union(struct qed_hwfn *p_hwfn,
+				 struct qed_ptt *p_ptt,
+				 struct qed_mcp_mb_params *p_mb_params)
 {
-	int rc = 0;
+	u32 union_data_addr;
+	int rc;
 
 	/* MCP not initialized */
 	if (!qed_mcp_is_init(p_hwfn)) {
@@ -290,28 +343,56 @@ int qed_mcp_cmd(struct qed_hwfn *p_hwfn,
 		return -EBUSY;
 	}
 
-	/* Lock Mutex to ensure only single thread is
-	 * accessing the MCP at one time
+	union_data_addr = p_hwfn->mcp_info->drv_mb_addr +
+			  offsetof(struct public_drv_mb, union_data);
+
+	/* Ensure that only a single thread is accessing the mailbox at a
+	 * certain time.
 	 */
-	mutex_lock(&p_hwfn->mcp_info->mutex);
-	rc = qed_do_mcp_cmd(p_hwfn, p_ptt, cmd, param,
-			    o_mcp_resp, o_mcp_param);
-	/* Release Mutex */
-	mutex_unlock(&p_hwfn->mcp_info->mutex);
+	rc = qed_mcp_mb_lock(p_hwfn, p_mb_params->cmd);
+	if (rc)
+		return rc;
+
+	if (p_mb_params->p_data_src != NULL)
+		qed_memcpy_to(p_hwfn, p_ptt, union_data_addr,
+			      p_mb_params->p_data_src,
+			      sizeof(*p_mb_params->p_data_src));
+
+	rc = qed_do_mcp_cmd(p_hwfn, p_ptt, p_mb_params->cmd,
+			    p_mb_params->param, &p_mb_params->mcp_resp,
+			    &p_mb_params->mcp_param);
+
+	if (p_mb_params->p_data_dst != NULL)
+		qed_memcpy_from(p_hwfn, p_ptt, p_mb_params->p_data_dst,
+				union_data_addr,
+				sizeof(*p_mb_params->p_data_dst));
+
+	qed_mcp_mb_unlock(p_hwfn, p_mb_params->cmd);
 
 	return rc;
 }
 
-static void qed_mcp_set_drv_ver(struct qed_dev *cdev,
-				struct qed_hwfn *p_hwfn,
-				struct qed_ptt *p_ptt)
+int qed_mcp_cmd(struct qed_hwfn *p_hwfn,
+		struct qed_ptt *p_ptt,
+		u32 cmd,
+		u32 param,
+		u32 *o_mcp_resp,
+		u32 *o_mcp_param)
 {
-	u32 i;
+	struct qed_mcp_mb_params mb_params;
+	int rc;
+
+	memset(&mb_params, 0, sizeof(mb_params));
+	mb_params.cmd = cmd;
+	mb_params.param = param;
+	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
+	if (rc)
+		return rc;
+
+	*o_mcp_resp = mb_params.mcp_resp;
+	*o_mcp_param = mb_params.mcp_param;
 
-	/* Copy version string to MCP */
-	for (i = 0; i < MCP_DRV_VER_STR_SIZE_DWORD; i++)
-		DRV_MB_WR(p_hwfn, p_ptt, union_data.ver_str[i],
-			  *(u32 *)&cdev->ver_str[i * sizeof(u32)]);
+	return 0;
 }
 
 int qed_mcp_load_req(struct qed_hwfn *p_hwfn,
@@ -319,26 +400,18 @@ int qed_mcp_load_req(struct qed_hwfn *p_hwfn,
 		     u32 *p_load_code)
 {
 	struct qed_dev *cdev = p_hwfn->cdev;
-	u32 param;
+	struct qed_mcp_mb_params mb_params;
+	union drv_union_data union_data;
 	int rc;
 
-	if (!qed_mcp_is_init(p_hwfn)) {
-		DP_NOTICE(p_hwfn, "MFW is not initialized !\n");
-		return -EBUSY;
-	}
-
-	/* Save driver's version to shmem */
-	qed_mcp_set_drv_ver(cdev, p_hwfn, p_ptt);
-
-	DP_VERBOSE(p_hwfn, QED_MSG_SP, "fw_seq 0x%08x, drv_pulse 0x%x\n",
-		   p_hwfn->mcp_info->drv_mb_seq,
-		   p_hwfn->mcp_info->drv_pulse_seq);
-
+	memset(&mb_params, 0, sizeof(mb_params));
 	/* Load Request */
-	rc = qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_LOAD_REQ,
-			 (PDA_COMP | DRV_ID_MCP_HSI_VER_CURRENT |
-			  cdev->drv_type),
-			 p_load_code, &param);
+	mb_params.cmd = DRV_MSG_CODE_LOAD_REQ;
+	mb_params.param = PDA_COMP | DRV_ID_MCP_HSI_VER_CURRENT |
+			  cdev->drv_type;
+	memcpy(&union_data.ver_str, cdev->ver_str, MCP_DRV_VER_STR_SIZE);
+	mb_params.p_data_src = &union_data;
+	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 
 	/* if mcp fails to respond we must abort */
 	if (rc) {
@@ -346,6 +419,8 @@ int qed_mcp_load_req(struct qed_hwfn *p_hwfn,
 		return rc;
 	}
 
+	*p_load_code = mb_params.mcp_resp;
+
 	/* If MFW refused (e.g. other port is in diagnostic mode) we
 	 * must abort. This can happen in the following cases:
 	 * - Other port is in diagnostic mode
@@ -495,55 +570,43 @@ int qed_mcp_set_link(struct qed_hwfn *p_hwfn,
 		     bool b_up)
 {
 	struct qed_mcp_link_params *params = &p_hwfn->mcp_info->link_input;
-	u32 param = 0, reply = 0, cmd;
-	struct pmm_phy_cfg phy_cfg;
+	struct qed_mcp_mb_params mb_params;
+	union drv_union_data union_data;
+	struct pmm_phy_cfg *phy_cfg;
 	int rc = 0;
-	u32 i;
-
-	if (!qed_mcp_is_init(p_hwfn)) {
-		DP_NOTICE(p_hwfn, "MFW is not initialized !\n");
-		return -EBUSY;
-	}
+	u32 cmd;
 
 	/* Set the shmem configuration according to params */
-	memset(&phy_cfg, 0, sizeof(phy_cfg));
+	phy_cfg = &union_data.drv_phy_cfg;
+	memset(phy_cfg, 0, sizeof(*phy_cfg));
 	cmd = b_up ? DRV_MSG_CODE_INIT_PHY : DRV_MSG_CODE_LINK_RESET;
 	if (!params->speed.autoneg)
-		phy_cfg.speed = params->speed.forced_speed;
-	phy_cfg.pause |= (params->pause.autoneg) ? PMM_PAUSE_AUTONEG : 0;
-	phy_cfg.pause |= (params->pause.forced_rx) ? PMM_PAUSE_RX : 0;
-	phy_cfg.pause |= (params->pause.forced_tx) ? PMM_PAUSE_TX : 0;
-	phy_cfg.adv_speed = params->speed.advertised_speeds;
-	phy_cfg.loopback_mode = params->loopback_mode;
-
-	/* Write the requested configuration to shmem */
-	for (i = 0; i < sizeof(phy_cfg); i += 4)
-		qed_wr(p_hwfn, p_ptt,
-		       p_hwfn->mcp_info->drv_mb_addr +
-		       offsetof(struct public_drv_mb, union_data) + i,
-		       ((u32 *)&phy_cfg)[i >> 2]);
+		phy_cfg->speed = params->speed.forced_speed;
+	phy_cfg->pause |= (params->pause.autoneg) ? PMM_PAUSE_AUTONEG : 0;
+	phy_cfg->pause |= (params->pause.forced_rx) ? PMM_PAUSE_RX : 0;
+	phy_cfg->pause |= (params->pause.forced_tx) ? PMM_PAUSE_TX : 0;
+	phy_cfg->adv_speed = params->speed.advertised_speeds;
+	phy_cfg->loopback_mode = params->loopback_mode;
 
 	p_hwfn->b_drv_link_init = b_up;
 
 	if (b_up) {
 		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
 			   "Configuring Link: Speed 0x%08x, Pause 0x%08x, adv_speed 0x%08x, loopback 0x%08x, features 0x%08x\n",
-			   phy_cfg.speed,
-			   phy_cfg.pause,
-			   phy_cfg.adv_speed,
-			   phy_cfg.loopback_mode,
-			   phy_cfg.feature_config_flags);
+			   phy_cfg->speed,
+			   phy_cfg->pause,
+			   phy_cfg->adv_speed,
+			   phy_cfg->loopback_mode,
+			   phy_cfg->feature_config_flags);
 	} else {
 		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
 			   "Resetting link\n");
 	}
 
-	DP_VERBOSE(p_hwfn, QED_MSG_SP, "fw_seq 0x%08x, drv_pulse 0x%x\n",
-		   p_hwfn->mcp_info->drv_mb_seq,
-		   p_hwfn->mcp_info->drv_pulse_seq);
-
-	/* Load Request */
-	rc = qed_mcp_cmd(p_hwfn, p_ptt, cmd, 0, &reply, &param);
+	memset(&mb_params, 0, sizeof(mb_params));
+	mb_params.cmd = cmd;
+	mb_params.p_data_src = &union_data;
+	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 
 	/* if mcp fails to respond we must abort */
 	if (rc) {
@@ -836,31 +899,28 @@ qed_mcp_send_drv_version(struct qed_hwfn *p_hwfn,
 			 struct qed_ptt *p_ptt,
 			 struct qed_mcp_drv_version *p_ver)
 {
-	int rc = 0;
-	u32 param = 0, reply = 0, i;
-
-	if (!qed_mcp_is_init(p_hwfn)) {
-		DP_NOTICE(p_hwfn, "MFW is not initialized !\n");
-		return -EBUSY;
-	}
+	struct drv_version_stc *p_drv_version;
+	struct qed_mcp_mb_params mb_params;
+	union drv_union_data union_data;
+	__be32 val;
+	u32 i;
+	int rc;
 
-	DRV_MB_WR(p_hwfn, p_ptt, union_data.drv_version.version,
-		  p_ver->version);
-	/* Copy version string to shmem */
-	for (i = 0; i < (MCP_DRV_VER_STR_SIZE - 4) / 4; i++) {
-		DRV_MB_WR(p_hwfn, p_ptt,
-			  union_data.drv_version.name[i * sizeof(u32)],
-			  *(u32 *)&p_ver->name[i * sizeof(u32)]);
+	p_drv_version = &union_data.drv_version;
+	p_drv_version->version = p_ver->version;
+	for (i = 0; i < MCP_DRV_VER_STR_SIZE - 1; i += 4) {
+		val = cpu_to_be32(p_ver->name[i]);
+		*(u32 *)&p_drv_version->name[i * sizeof(u32)] = val;
 	}
 
-	rc = qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_SET_VERSION, 0, &reply,
-			 &param);
-	if (rc) {
+	memset(&mb_params, 0, sizeof(mb_params));
+	mb_params.cmd = DRV_MSG_CODE_SET_VERSION;
+	mb_params.p_data_src = &union_data;
+	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
+	if (rc)
 		DP_ERR(p_hwfn, "MCP response failure, aborting\n");
-		return rc;
-	}
 
-	return 0;
+	return rc;
 }
 
 int qed_mcp_set_led(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 506197d..50917a2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -11,8 +11,8 @@
 
 #include <linux/types.h>
 #include <linux/delay.h>
-#include <linux/mutex.h>
 #include <linux/slab.h>
+#include <linux/spinlock.h>
 #include "qed_hsi.h"
 
 struct qed_mcp_link_speed_params {
@@ -255,7 +255,8 @@ int qed_mcp_set_led(struct qed_hwfn *p_hwfn,
 #define MFW_PORT(_p_hwfn)       ((_p_hwfn)->abs_pf_id %	\
 				 ((_p_hwfn)->cdev->num_ports_in_engines * 2))
 struct qed_mcp_info {
-	struct mutex				mutex; /* MCP access lock */
+	spinlock_t				lock;
+	bool					block_mb_sending;
 	u32					public_base;
 	u32					drv_mb_addr;
 	u32					mfw_mb_addr;
@@ -272,6 +273,15 @@ struct qed_mcp_info {
 	u16					mcp_hist;
 };
 
+struct qed_mcp_mb_params {
+	u32			cmd;
+	u32			param;
+	union drv_union_data	*p_data_src;
+	union drv_union_data	*p_data_dst;
+	u32			mcp_resp;
+	u32			mcp_param;
+};
+
 /**
  * @brief Initialize the interface with the MCP
  *
-- 
1.9.3
