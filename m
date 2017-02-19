From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 10/10] qed*: Fix link indication race
Date: Sun, 19 Feb 2017 15:26:23 +0200
Message-ID: <1487510783-19919-11-git-send-email-Yuval.Mintz@cavium.com>
References: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:54375 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752066AbdBSN1R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 08:27:17 -0500
In-Reply-To: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver changes the link properties via communication with
the management firmware, and re-reads the resulting link status
when it receives an indication that the link has changed.
However, there are certain scenarios where such indications
might be missing, and so driver also re-reads the current link
results without attention in several places. Specifically, it
does so during load and when resetting the link.

This creates a race where driver might reflect incorrect
link status - e.g., when explicit reading of the link status is
switched by attention with the changed configuration.

Correct this flow by a lock syncronizing the handling of the
link indications [both explicit requests and attention].

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c   | 12 +++++++++---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c    | 18 ++++++++++++++----
 drivers/net/ethernet/qlogic/qed/qed_mcp.h    |  6 ++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h  |  1 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c     |  3 +++
 drivers/net/ethernet/qlogic/qede/qede_main.c |  5 -----
 6 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index b43b0e3..756209e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1094,12 +1094,18 @@ static int qed_set_link(struct qed_dev *cdev, struct qed_link_params *params)
 	if (!cdev)
 		return -ENODEV;
 
-	if (IS_VF(cdev))
-		return 0;
-
 	/* The link should be set only once per PF */
 	hwfn = &cdev->hwfns[0];
 
+	/* When VF wants to set link, force it to read the bulletin instead.
+	 * This mimics the PF behavior, where a noitification [both immediate
+	 * and possible later] would be generated when changing properties.
+	 */
+	if (IS_VF(cdev)) {
+		qed_schedule_iov(hwfn, QED_IOV_WQ_VF_FORCE_LINK_QUERY_FLAG);
+		return 0;
+	}
+
 	ptt = qed_ptt_acquire(hwfn);
 	if (!ptt)
 		return -EBUSY;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 6dd3ce4..5d8d0c2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -168,6 +168,7 @@ int qed_mcp_cmd_init(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 
 	/* Initialize the MFW spinlock */
 	spin_lock_init(&p_info->lock);
+	spin_lock_init(&p_info->link_lock);
 
 	return 0;
 
@@ -586,6 +587,9 @@ static void qed_mcp_handle_link_change(struct qed_hwfn *p_hwfn,
 	u8 max_bw, min_bw;
 	u32 status = 0;
 
+	/* Prevent SW/attentions from doing this at the same time */
+	spin_lock_bh(&p_hwfn->mcp_info->link_lock);
+
 	p_link = &p_hwfn->mcp_info->link_output;
 	memset(p_link, 0, sizeof(*p_link));
 	if (!b_reset) {
@@ -600,7 +604,7 @@ static void qed_mcp_handle_link_change(struct qed_hwfn *p_hwfn,
 	} else {
 		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
 			   "Resetting link indications\n");
-		return;
+		goto out;
 	}
 
 	if (p_hwfn->b_drv_link_init)
@@ -707,6 +711,8 @@ static void qed_mcp_handle_link_change(struct qed_hwfn *p_hwfn,
 	p_link->sfp_tx_fault = !!(status & LINK_STATUS_SFP_TX_FAULT);
 
 	qed_link_update(p_hwfn);
+out:
+	spin_unlock_bh(&p_hwfn->mcp_info->link_lock);
 }
 
 int qed_mcp_set_link(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt, bool b_up)
@@ -756,9 +762,13 @@ int qed_mcp_set_link(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt, bool b_up)
 		return rc;
 	}
 
-	/* Reset the link status if needed */
-	if (!b_up)
-		qed_mcp_handle_link_change(p_hwfn, p_ptt, true);
+	/* Mimic link-change attention, done for several reasons:
+	 *  - On reset, there's no guarantee MFW would trigger
+	 *    an attention.
+	 *  - On initialization, older MFWs might not indicate link change
+	 *    during LFA, so we'll never get an UP indication.
+	 */
+	qed_mcp_handle_link_change(p_hwfn, p_ptt, !b_up);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 407a2c1..b7dc40c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -460,7 +460,13 @@ int qed_mcp_bist_nvm_test_get_image_att(struct qed_hwfn *p_hwfn,
 #define MFW_PORT(_p_hwfn)       ((_p_hwfn)->abs_pf_id %	\
 				 ((_p_hwfn)->cdev->num_ports_in_engines * 2))
 struct qed_mcp_info {
+	/* Spinlock used for protecting the access to the MFW mailbox */
 	spinlock_t				lock;
+
+	/* Spinlock used for syncing SW link-changes and link-changes
+	 * originating from attention context.
+	 */
+	spinlock_t				link_lock;
 	bool					block_mb_sending;
 	u32					public_base;
 	u32					drv_mb_addr;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 509c02b..e0c04e9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -221,6 +221,7 @@ enum qed_iov_wq_flag {
 	QED_IOV_WQ_BULLETIN_UPDATE_FLAG,
 	QED_IOV_WQ_STOP_WQ_FLAG,
 	QED_IOV_WQ_FLR_FLAG,
+	QED_IOV_WQ_VF_FORCE_LINK_QUERY_FLAG,
 };
 
 #ifdef CONFIG_QED_SRIOV
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 60b31a8..40f2752 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -1253,6 +1253,9 @@ void qed_iov_vf_task(struct work_struct *work)
 
 	/* Handle bulletin board changes */
 	qed_vf_read_bulletin(hwfn, &change);
+	if (test_and_clear_bit(QED_IOV_WQ_VF_FORCE_LINK_QUERY_FLAG,
+			       &hwfn->iov_task_flags))
+		change = 1;
 	if (change)
 		qed_handle_bulletin_change(hwfn);
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 9c9f50c..d36f570 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -3940,7 +3940,6 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode,
 		     bool is_locked)
 {
 	struct qed_link_params link_params;
-	struct qed_link_output link_output;
 	int rc;
 
 	DP_INFO(edev, "Starting qede load\n");
@@ -3992,11 +3991,7 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode,
 	link_params.link_up = true;
 	edev->ops->common->set_link(edev->cdev, &link_params);
 
-	/* Query whether link is already-up */
-	memset(&link_output, 0, sizeof(link_output));
-	edev->ops->common->get_link(edev->cdev, &link_output);
 	qede_roce_dev_event_open(edev);
-	qede_link_update(edev, &link_output);
 
 	edev->state = QEDE_STATE_OPEN;
 
-- 
1.9.3
