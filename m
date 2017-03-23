From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 1/6] qed: Revise MFW command locking
Date: Thu, 23 Mar 2017 15:50:15 +0200
Message-ID: <1490277020-31208-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45263 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755817AbdCWNuo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:50:44 -0400
In-Reply-To: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>

Interaction of driver -> management firmware is based
on a one-pending mailbox [per interface], and various
mailbox commands need to be synchronized.

Current scheme is messy, and there's a difficulty extending
it as it deals differently with various commands as well as
making assumption on the required behavior for load/unload
requests.

Drop the current scheme into a completion-list-based approach;
Each flow would try sending the command when possible,
allowing one flow to complete another flow's completion and
relieve the mailbox before sending its own command.

Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 405 ++++++++++++++++++++----------
 drivers/net/ethernet/qlogic/qed/qed_mcp.h |  11 +-
 2 files changed, 280 insertions(+), 136 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 87fde20..0d157de 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -111,12 +111,71 @@ void qed_mcp_read_mb(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	}
 }
 
+struct qed_mcp_cmd_elem {
+	struct list_head list;
+	struct qed_mcp_mb_params *p_mb_params;
+	u16 expected_seq_num;
+	bool b_is_completed;
+};
+
+/* Must be called while cmd_lock is acquired */
+static struct qed_mcp_cmd_elem *
+qed_mcp_cmd_add_elem(struct qed_hwfn *p_hwfn,
+		     struct qed_mcp_mb_params *p_mb_params,
+		     u16 expected_seq_num)
+{
+	struct qed_mcp_cmd_elem *p_cmd_elem = NULL;
+
+	p_cmd_elem = kzalloc(sizeof(*p_cmd_elem), GFP_ATOMIC);
+	if (!p_cmd_elem)
+		goto out;
+
+	p_cmd_elem->p_mb_params = p_mb_params;
+	p_cmd_elem->expected_seq_num = expected_seq_num;
+	list_add(&p_cmd_elem->list, &p_hwfn->mcp_info->cmd_list);
+out:
+	return p_cmd_elem;
+}
+
+/* Must be called while cmd_lock is acquired */
+static void qed_mcp_cmd_del_elem(struct qed_hwfn *p_hwfn,
+				 struct qed_mcp_cmd_elem *p_cmd_elem)
+{
+	list_del(&p_cmd_elem->list);
+	kfree(p_cmd_elem);
+}
+
+/* Must be called while cmd_lock is acquired */
+static struct qed_mcp_cmd_elem *qed_mcp_cmd_get_elem(struct qed_hwfn *p_hwfn,
+						     u16 seq_num)
+{
+	struct qed_mcp_cmd_elem *p_cmd_elem = NULL;
+
+	list_for_each_entry(p_cmd_elem, &p_hwfn->mcp_info->cmd_list, list) {
+		if (p_cmd_elem->expected_seq_num == seq_num)
+			return p_cmd_elem;
+	}
+
+	return NULL;
+}
+
 int qed_mcp_free(struct qed_hwfn *p_hwfn)
 {
 	if (p_hwfn->mcp_info) {
+		struct qed_mcp_cmd_elem *p_cmd_elem, *p_tmp;
+
 		kfree(p_hwfn->mcp_info->mfw_mb_cur);
 		kfree(p_hwfn->mcp_info->mfw_mb_shadow);
+
+		spin_lock_bh(&p_hwfn->mcp_info->cmd_lock);
+		list_for_each_entry_safe(p_cmd_elem,
+					 p_tmp,
+					 &p_hwfn->mcp_info->cmd_list, list) {
+			qed_mcp_cmd_del_elem(p_hwfn, p_cmd_elem);
+		}
+		spin_unlock_bh(&p_hwfn->mcp_info->cmd_lock);
 	}
+
 	kfree(p_hwfn->mcp_info);
 
 	return 0;
@@ -160,7 +219,7 @@ static int qed_load_mcp_offsets(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	p_info->drv_pulse_seq = DRV_MB_RD(p_hwfn, p_ptt, drv_pulse_mb) &
 				DRV_PULSE_SEQ_MASK;
 
-	p_info->mcp_hist = (u16)qed_rd(p_hwfn, p_ptt, MISCS_REG_GENERIC_POR_0);
+	p_info->mcp_hist = qed_rd(p_hwfn, p_ptt, MISCS_REG_GENERIC_POR_0);
 
 	return 0;
 }
@@ -176,6 +235,12 @@ int qed_mcp_cmd_init(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 		goto err;
 	p_info = p_hwfn->mcp_info;
 
+	/* Initialize the MFW spinlock */
+	spin_lock_init(&p_info->cmd_lock);
+	spin_lock_init(&p_info->link_lock);
+
+	INIT_LIST_HEAD(&p_info->cmd_list);
+
 	if (qed_load_mcp_offsets(p_hwfn, p_ptt) != 0) {
 		DP_NOTICE(p_hwfn, "MCP is not initialized\n");
 		/* Do not free mcp_info here, since public_base indicate that
@@ -190,10 +255,6 @@ int qed_mcp_cmd_init(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	if (!p_info->mfw_mb_shadow || !p_info->mfw_mb_addr)
 		goto err;
 
-	/* Initialize the MFW spinlock */
-	spin_lock_init(&p_info->lock);
-	spin_lock_init(&p_info->link_lock);
-
 	return 0;
 
 err:
@@ -201,68 +262,39 @@ int qed_mcp_cmd_init(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	return -ENOMEM;
 }
 
-/* Locks the MFW mailbox of a PF to ensure a single access.
- * The lock is achieved in most cases by holding a spinlock, causing other
- * threads to wait till a previous access is done.
- * In some cases (currently when a [UN]LOAD_REQ commands are sent), the single
- * access is achieved by setting a blocking flag, which will fail other
- * competing contexts to send their mailboxes.
- */
-static int qed_mcp_mb_lock(struct qed_hwfn *p_hwfn, u32 cmd)
+static void qed_mcp_reread_offsets(struct qed_hwfn *p_hwfn,
+				   struct qed_ptt *p_ptt)
 {
-	spin_lock_bh(&p_hwfn->mcp_info->lock);
-
-	/* The spinlock shouldn't be acquired when the mailbox command is
-	 * [UN]LOAD_REQ, since the engine is locked by the MFW, and a parallel
-	 * pending [UN]LOAD_REQ command of another PF together with a spinlock
-	 * (i.e. interrupts are disabled) - can lead to a deadlock.
-	 * It is assumed that for a single PF, no other mailbox commands can be
-	 * sent from another context while sending LOAD_REQ, and that any
-	 * parallel commands to UNLOAD_REQ can be cancelled.
-	 */
-	if (cmd == DRV_MSG_CODE_LOAD_DONE || cmd == DRV_MSG_CODE_UNLOAD_DONE)
-		p_hwfn->mcp_info->block_mb_sending = false;
+	u32 generic_por_0 = qed_rd(p_hwfn, p_ptt, MISCS_REG_GENERIC_POR_0);
 
-	if (p_hwfn->mcp_info->block_mb_sending) {
-		DP_NOTICE(p_hwfn,
-			  "Trying to send a MFW mailbox command [0x%x] in parallel to [UN]LOAD_REQ. Aborting.\n",
-			  cmd);
-		spin_unlock_bh(&p_hwfn->mcp_info->lock);
-		return -EBUSY;
-	}
+	/* Use MCP history register to check if MCP reset occurred between init
+	 * time and now.
+	 */
+	if (p_hwfn->mcp_info->mcp_hist != generic_por_0) {
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_SP,
+			   "Rereading MCP offsets [mcp_hist 0x%08x, generic_por_0 0x%08x]\n",
+			   p_hwfn->mcp_info->mcp_hist, generic_por_0);
 
-	if (cmd == DRV_MSG_CODE_LOAD_REQ || cmd == DRV_MSG_CODE_UNLOAD_REQ) {
-		p_hwfn->mcp_info->block_mb_sending = true;
-		spin_unlock_bh(&p_hwfn->mcp_info->lock);
+		qed_load_mcp_offsets(p_hwfn, p_ptt);
+		qed_mcp_cmd_port_init(p_hwfn, p_ptt);
 	}
-
-	return 0;
-}
-
-static void qed_mcp_mb_unlock(struct qed_hwfn *p_hwfn, u32 cmd)
-{
-	if (cmd != DRV_MSG_CODE_LOAD_REQ && cmd != DRV_MSG_CODE_UNLOAD_REQ)
-		spin_unlock_bh(&p_hwfn->mcp_info->lock);
 }
 
 int qed_mcp_reset(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 {
-	u32 seq = ++p_hwfn->mcp_info->drv_mb_seq;
-	u8 delay = CHIP_MCP_RESP_ITER_US;
-	u32 org_mcp_reset_seq, cnt = 0;
+	u32 org_mcp_reset_seq, seq, delay = CHIP_MCP_RESP_ITER_US, cnt = 0;
 	int rc = 0;
 
-	/* Ensure that only a single thread is accessing the mailbox at a
-	 * certain time.
-	 */
-	rc = qed_mcp_mb_lock(p_hwfn, DRV_MSG_CODE_MCP_RESET);
-	if (rc != 0)
-		return rc;
+	/* Ensure that only a single thread is accessing the mailbox */
+	spin_lock_bh(&p_hwfn->mcp_info->cmd_lock);
 
-	/* Set drv command along with the updated sequence */
 	org_mcp_reset_seq = qed_rd(p_hwfn, p_ptt, MISCS_REG_GENERIC_POR_0);
-	DRV_MB_WR(p_hwfn, p_ptt, drv_mb_header,
-		  (DRV_MSG_CODE_MCP_RESET | seq));
+
+	/* Set drv command along with the updated sequence */
+	qed_mcp_reread_offsets(p_hwfn, p_ptt);
+	seq = ++p_hwfn->mcp_info->drv_mb_seq;
+	DRV_MB_WR(p_hwfn, p_ptt, drv_mb_header, (DRV_MSG_CODE_MCP_RESET | seq));
 
 	do {
 		/* Wait for MFW response */
@@ -281,72 +313,205 @@ int qed_mcp_reset(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 		rc = -EAGAIN;
 	}
 
-	qed_mcp_mb_unlock(p_hwfn, DRV_MSG_CODE_MCP_RESET);
+	spin_unlock_bh(&p_hwfn->mcp_info->cmd_lock);
 
 	return rc;
 }
 
-static int qed_do_mcp_cmd(struct qed_hwfn *p_hwfn,
-			  struct qed_ptt *p_ptt,
-			  u32 cmd,
-			  u32 param,
-			  u32 *o_mcp_resp,
-			  u32 *o_mcp_param)
+/* Must be called while cmd_lock is acquired */
+static bool qed_mcp_has_pending_cmd(struct qed_hwfn *p_hwfn)
 {
-	u8 delay = CHIP_MCP_RESP_ITER_US;
-	u32 seq, cnt = 1, actual_mb_seq;
-	int rc = 0;
+	struct qed_mcp_cmd_elem *p_cmd_elem;
 
-	/* Get actual driver mailbox sequence */
-	actual_mb_seq = DRV_MB_RD(p_hwfn, p_ptt, drv_mb_header) &
-			DRV_MSG_SEQ_NUMBER_MASK;
-
-	/* Use MCP history register to check if MCP reset occurred between
-	 * init time and now.
+	/* There is at most one pending command at a certain time, and if it
+	 * exists - it is placed at the HEAD of the list.
 	 */
-	if (p_hwfn->mcp_info->mcp_hist !=
-	    qed_rd(p_hwfn, p_ptt, MISCS_REG_GENERIC_POR_0)) {
-		DP_VERBOSE(p_hwfn, QED_MSG_SP, "Rereading MCP offsets\n");
-		qed_load_mcp_offsets(p_hwfn, p_ptt);
-		qed_mcp_cmd_port_init(p_hwfn, p_ptt);
+	if (!list_empty(&p_hwfn->mcp_info->cmd_list)) {
+		p_cmd_elem = list_first_entry(&p_hwfn->mcp_info->cmd_list,
+					      struct qed_mcp_cmd_elem, list);
+		return !p_cmd_elem->b_is_completed;
 	}
-	seq = ++p_hwfn->mcp_info->drv_mb_seq;
 
-	/* Set drv param */
-	DRV_MB_WR(p_hwfn, p_ptt, drv_mb_param, param);
+	return false;
+}
+
+/* Must be called while cmd_lock is acquired */
+static int
+qed_mcp_update_pending_cmd(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	struct qed_mcp_mb_params *p_mb_params;
+	struct qed_mcp_cmd_elem *p_cmd_elem;
+	u32 mcp_resp;
+	u16 seq_num;
 
-	/* Set drv command along with the updated sequence */
-	DRV_MB_WR(p_hwfn, p_ptt, drv_mb_header, (cmd | seq));
+	mcp_resp = DRV_MB_RD(p_hwfn, p_ptt, fw_mb_header);
+	seq_num = (u16)(mcp_resp & FW_MSG_SEQ_NUMBER_MASK);
+
+	/* Return if no new non-handled response has been received */
+	if (seq_num != p_hwfn->mcp_info->drv_mb_seq)
+		return -EAGAIN;
+
+	p_cmd_elem = qed_mcp_cmd_get_elem(p_hwfn, seq_num);
+	if (!p_cmd_elem) {
+		DP_ERR(p_hwfn,
+		       "Failed to find a pending mailbox cmd that expects sequence number %d\n",
+		       seq_num);
+		return -EINVAL;
+	}
+
+	p_mb_params = p_cmd_elem->p_mb_params;
+
+	/* Get the MFW response along with the sequence number */
+	p_mb_params->mcp_resp = mcp_resp;
+
+	/* Get the MFW param */
+	p_mb_params->mcp_param = DRV_MB_RD(p_hwfn, p_ptt, fw_mb_param);
+
+	/* Get the union data */
+	if (p_mb_params->p_data_dst != NULL) {
+		u32 union_data_addr = p_hwfn->mcp_info->drv_mb_addr +
+				      offsetof(struct public_drv_mb,
+					       union_data);
+		qed_memcpy_from(p_hwfn, p_ptt, p_mb_params->p_data_dst,
+				union_data_addr, sizeof(union drv_union_data));
+	}
+
+	p_cmd_elem->b_is_completed = true;
+
+	return 0;
+}
+
+/* Must be called while cmd_lock is acquired */
+static void __qed_mcp_cmd_and_union(struct qed_hwfn *p_hwfn,
+				    struct qed_ptt *p_ptt,
+				    struct qed_mcp_mb_params *p_mb_params,
+				    u16 seq_num)
+{
+	union drv_union_data union_data;
+	u32 union_data_addr;
+
+	/* Set the union data */
+	union_data_addr = p_hwfn->mcp_info->drv_mb_addr +
+			  offsetof(struct public_drv_mb, union_data);
+	memset(&union_data, 0, sizeof(union_data));
+	if (p_mb_params->p_data_src != NULL)
+		memcpy(&union_data, p_mb_params->p_data_src,
+		       sizeof(union_data));
+	qed_memcpy_to(p_hwfn, p_ptt, union_data_addr, &union_data,
+		      sizeof(union_data));
+
+	/* Set the drv param */
+	DRV_MB_WR(p_hwfn, p_ptt, drv_mb_param, p_mb_params->param);
+
+	/* Set the drv command along with the sequence number */
+	DRV_MB_WR(p_hwfn, p_ptt, drv_mb_header, (p_mb_params->cmd | seq_num));
 
 	DP_VERBOSE(p_hwfn, QED_MSG_SP,
-		   "wrote command (%x) to MFW MB param 0x%08x\n",
-		   (cmd | seq), param);
+		   "MFW mailbox: command 0x%08x param 0x%08x\n",
+		   (p_mb_params->cmd | seq_num), p_mb_params->param);
+}
 
+static int
+_qed_mcp_cmd_and_union(struct qed_hwfn *p_hwfn,
+		       struct qed_ptt *p_ptt,
+		       struct qed_mcp_mb_params *p_mb_params,
+		       u32 max_retries, u32 delay)
+{
+	struct qed_mcp_cmd_elem *p_cmd_elem;
+	u32 cnt = 0;
+	u16 seq_num;
+	int rc = 0;
+
+	/* Wait until the mailbox is non-occupied */
 	do {
-		/* Wait for MFW response */
+		/* Exit the loop if there is no pending command, or if the
+		 * pending command is completed during this iteration.
+		 * The spinlock stays locked until the command is sent.
+		 */
+
+		spin_lock_bh(&p_hwfn->mcp_info->cmd_lock);
+
+		if (!qed_mcp_has_pending_cmd(p_hwfn))
+			break;
+
+		rc = qed_mcp_update_pending_cmd(p_hwfn, p_ptt);
+		if (!rc)
+			break;
+		else if (rc != -EAGAIN)
+			goto err;
+
+		spin_unlock_bh(&p_hwfn->mcp_info->cmd_lock);
 		udelay(delay);
-		*o_mcp_resp = DRV_MB_RD(p_hwfn, p_ptt, fw_mb_header);
+	} while (++cnt < max_retries);
+
+	if (cnt >= max_retries) {
+		DP_NOTICE(p_hwfn,
+			  "The MFW mailbox is occupied by an uncompleted command. Failed to send command 0x%08x [param 0x%08x].\n",
+			  p_mb_params->cmd, p_mb_params->param);
+		return -EAGAIN;
+	}
 
-		/* Give the FW up to 5 second (500*10ms) */
-	} while ((seq != (*o_mcp_resp & FW_MSG_SEQ_NUMBER_MASK)) &&
-		 (cnt++ < QED_DRV_MB_MAX_RETRIES));
+	/* Send the mailbox command */
+	qed_mcp_reread_offsets(p_hwfn, p_ptt);
+	seq_num = ++p_hwfn->mcp_info->drv_mb_seq;
+	p_cmd_elem = qed_mcp_cmd_add_elem(p_hwfn, p_mb_params, seq_num);
+	if (!p_cmd_elem)
+		goto err;
 
-	DP_VERBOSE(p_hwfn, QED_MSG_SP,
-		   "[after %d ms] read (%x) seq is (%x) from FW MB\n",
-		   cnt * delay, *o_mcp_resp, seq);
-
-	/* Is this a reply to our command? */
-	if (seq == (*o_mcp_resp & FW_MSG_SEQ_NUMBER_MASK)) {
-		*o_mcp_resp &= FW_MSG_CODE_MASK;
-		/* Get the MCP param */
-		*o_mcp_param = DRV_MB_RD(p_hwfn, p_ptt, fw_mb_param);
-	} else {
-		/* FW BUG! */
-		DP_ERR(p_hwfn, "MFW failed to respond [cmd 0x%x param 0x%x]\n",
-		       cmd, param);
-		*o_mcp_resp = 0;
-		rc = -EAGAIN;
+	__qed_mcp_cmd_and_union(p_hwfn, p_ptt, p_mb_params, seq_num);
+	spin_unlock_bh(&p_hwfn->mcp_info->cmd_lock);
+
+	/* Wait for the MFW response */
+	do {
+		/* Exit the loop if the command is already completed, or if the
+		 * command is completed during this iteration.
+		 * The spinlock stays locked until the list element is removed.
+		 */
+
+		udelay(delay);
+		spin_lock_bh(&p_hwfn->mcp_info->cmd_lock);
+
+		if (p_cmd_elem->b_is_completed)
+			break;
+
+		rc = qed_mcp_update_pending_cmd(p_hwfn, p_ptt);
+		if (!rc)
+			break;
+		else if (rc != -EAGAIN)
+			goto err;
+
+		spin_unlock_bh(&p_hwfn->mcp_info->cmd_lock);
+	} while (++cnt < max_retries);
+
+	if (cnt >= max_retries) {
+		DP_NOTICE(p_hwfn,
+			  "The MFW failed to respond to command 0x%08x [param 0x%08x].\n",
+			  p_mb_params->cmd, p_mb_params->param);
+
+		spin_lock_bh(&p_hwfn->mcp_info->cmd_lock);
+		qed_mcp_cmd_del_elem(p_hwfn, p_cmd_elem);
+		spin_unlock_bh(&p_hwfn->mcp_info->cmd_lock);
+
+		return -EAGAIN;
 	}
+
+	qed_mcp_cmd_del_elem(p_hwfn, p_cmd_elem);
+	spin_unlock_bh(&p_hwfn->mcp_info->cmd_lock);
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_SP,
+		   "MFW mailbox: response 0x%08x param 0x%08x [after %d.%03d ms]\n",
+		   p_mb_params->mcp_resp,
+		   p_mb_params->mcp_param,
+		   (cnt * delay) / 1000, (cnt * delay) % 1000);
+
+	/* Clear the sequence number from the MFW response */
+	p_mb_params->mcp_resp &= FW_MSG_CODE_MASK;
+
+	return 0;
+
+err:
+	spin_unlock_bh(&p_hwfn->mcp_info->cmd_lock);
 	return rc;
 }
 
@@ -354,9 +519,8 @@ static int qed_mcp_cmd_and_union(struct qed_hwfn *p_hwfn,
 				 struct qed_ptt *p_ptt,
 				 struct qed_mcp_mb_params *p_mb_params)
 {
-	u32 union_data_addr;
-
-	int rc;
+	u32 max_retries = QED_DRV_MB_MAX_RETRIES;
+	u32 delay = CHIP_MCP_RESP_ITER_US;
 
 	/* MCP not initialized */
 	if (!qed_mcp_is_init(p_hwfn)) {
@@ -364,33 +528,8 @@ static int qed_mcp_cmd_and_union(struct qed_hwfn *p_hwfn,
 		return -EBUSY;
 	}
 
-	union_data_addr = p_hwfn->mcp_info->drv_mb_addr +
-			  offsetof(struct public_drv_mb, union_data);
-
-	/* Ensure that only a single thread is accessing the mailbox at a
-	 * certain time.
-	 */
-	rc = qed_mcp_mb_lock(p_hwfn, p_mb_params->cmd);
-	if (rc)
-		return rc;
-
-	if (p_mb_params->p_data_src != NULL)
-		qed_memcpy_to(p_hwfn, p_ptt, union_data_addr,
-			      p_mb_params->p_data_src,
-			      sizeof(*p_mb_params->p_data_src));
-
-	rc = qed_do_mcp_cmd(p_hwfn, p_ptt, p_mb_params->cmd,
-			    p_mb_params->param, &p_mb_params->mcp_resp,
-			    &p_mb_params->mcp_param);
-
-	if (p_mb_params->p_data_dst != NULL)
-		qed_memcpy_from(p_hwfn, p_ptt, p_mb_params->p_data_dst,
-				union_data_addr,
-				sizeof(*p_mb_params->p_data_dst));
-
-	qed_mcp_mb_unlock(p_hwfn, p_mb_params->cmd);
-
-	return rc;
+	return _qed_mcp_cmd_and_union(p_hwfn, p_ptt, p_mb_params, max_retries,
+				      delay);
 }
 
 int qed_mcp_cmd(struct qed_hwfn *p_hwfn,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index bdbfd6d..0f7b268 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -484,8 +484,13 @@ int qed_mcp_bist_nvm_test_get_image_att(struct qed_hwfn *p_hwfn,
 				  qed_device_num_engines((_p_hwfn)->cdev)))
 
 struct qed_mcp_info {
-	/* Spinlock used for protecting the access to the MFW mailbox */
-	spinlock_t				lock;
+	/* List for mailbox commands which were sent and wait for a response */
+	struct list_head			cmd_list;
+
+	/* Spinlock used for protecting the access to the mailbox commands list
+	 * and the sending of the commands.
+	 */
+	spinlock_t				cmd_lock;
 
 	/* Spinlock used for syncing SW link-changes and link-changes
 	 * originating from attention context.
@@ -505,7 +510,7 @@ struct qed_mcp_info {
 	u8					*mfw_mb_cur;
 	u8					*mfw_mb_shadow;
 	u16					mfw_mb_length;
-	u16					mcp_hist;
+	u32					mcp_hist;
 };
 
 struct qed_mcp_mb_params {
-- 
1.9.3
