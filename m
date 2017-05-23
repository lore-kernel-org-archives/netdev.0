From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 03/11] qed: !main_ptt for tunnel configuration
Date: Tue, 23 May 2017 09:41:20 +0300
Message-ID: <1495521688-27669-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Manish Chopra <Manish.Chopra@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0053.outbound.protection.outlook.com ([104.47.32.53]:22013
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761880AbdEWGm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 02:42:27 -0400
In-Reply-To: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <Manish.Chopra@cavium.com>

Flows configuring tunnel ports in HW use the main_ptt which should
be reserved for core-functionality.

Signed-off-by: Manish Chopra <Manish.Chopra@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |  3 ++-
 drivers/net/ethernet/qlogic/qed/qed_l2.c          | 17 +++++++++++++++--
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |  3 +++
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c | 14 +++++++++-----
 drivers/net/ethernet/qlogic/qed/qed_sriov.c       |  2 +-
 5 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 3fc3b2e..9dd28ba 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1513,7 +1513,8 @@ static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 		qed_int_igu_enable(p_hwfn, p_ptt, int_mode);
 
 		/* send function start command */
-		rc = qed_sp_pf_start(p_hwfn, p_tunn, p_hwfn->cdev->mf_mode,
+		rc = qed_sp_pf_start(p_hwfn, p_ptt, p_tunn,
+				     p_hwfn->cdev->mf_mode,
 				     allow_npar_tx_switch);
 		if (rc) {
 			DP_NOTICE(p_hwfn, "Function start ramrod failed\n");
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index fab6e69..93dd781 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -2300,14 +2300,25 @@ static int qed_tunn_configure(struct qed_dev *cdev,
 
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *hwfn = &cdev->hwfns[i];
+		struct qed_ptt *p_ptt;
 		struct qed_tunnel_info *tun;
 
 		tun = &hwfn->cdev->tunnel;
+		if (IS_PF(cdev)) {
+			p_ptt = qed_ptt_acquire(hwfn);
+			if (!p_ptt)
+				return -EAGAIN;
+		} else {
+			p_ptt = NULL;
+		}
 
-		rc = qed_sp_pf_update_tunn_cfg(hwfn, &tunn_info,
+		rc = qed_sp_pf_update_tunn_cfg(hwfn, p_ptt, &tunn_info,
 					       QED_SPQ_MODE_EBLOCK, NULL);
-		if (rc)
+		if (rc) {
+			if (IS_PF(cdev))
+				qed_ptt_release(hwfn, p_ptt);
 			return rc;
+		}
 
 		if (IS_PF_SRIOV(hwfn)) {
 			u16 vxlan_port, geneve_port;
@@ -2324,6 +2335,8 @@ static int qed_tunn_configure(struct qed_dev *cdev,
 
 			qed_schedule_iov(hwfn, QED_IOV_WQ_BULLETIN_UPDATE_FLAG);
 		}
+		if (IS_PF(cdev))
+			qed_ptt_release(hwfn, p_ptt);
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index c0b56b9..ef77de4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -391,6 +391,7 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
  * to the internal RAM of the UStorm by the Function Start Ramrod.
  *
  * @param p_hwfn
+ * @param p_ptt
  * @param p_tunn
  * @param mode
  * @param allow_npar_tx_switch
@@ -399,6 +400,7 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
  */
 
 int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
+		    struct qed_ptt *p_ptt,
 		    struct qed_tunnel_info *p_tunn,
 		    enum qed_mf_mode mode, bool allow_npar_tx_switch);
 
@@ -432,6 +434,7 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 int qed_sp_pf_stop(struct qed_hwfn *p_hwfn);
 
 int qed_sp_pf_update_tunn_cfg(struct qed_hwfn *p_hwfn,
+			      struct qed_ptt *p_ptt,
 			      struct qed_tunnel_info *p_tunn,
 			      enum spq_mode comp_mode,
 			      struct qed_spq_comp_cb *p_comp_data);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 5abcac6..ab09975 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -253,17 +253,18 @@ static void qed_set_hw_tunn_mode(struct qed_hwfn *p_hwfn,
 }
 
 static void qed_set_hw_tunn_mode_port(struct qed_hwfn *p_hwfn,
+				      struct qed_ptt *p_ptt,
 				      struct qed_tunnel_info *p_tunn)
 {
 	if (p_tunn->vxlan_port.b_update_port)
-		qed_set_vxlan_dest_port(p_hwfn, p_hwfn->p_main_ptt,
+		qed_set_vxlan_dest_port(p_hwfn, p_ptt,
 					p_tunn->vxlan_port.port);
 
 	if (p_tunn->geneve_port.b_update_port)
-		qed_set_geneve_dest_port(p_hwfn, p_hwfn->p_main_ptt,
+		qed_set_geneve_dest_port(p_hwfn, p_ptt,
 					 p_tunn->geneve_port.port);
 
-	qed_set_hw_tunn_mode(p_hwfn, p_hwfn->p_main_ptt, p_tunn);
+	qed_set_hw_tunn_mode(p_hwfn, p_ptt, p_tunn);
 }
 
 static void
@@ -303,6 +304,7 @@ static void qed_set_hw_tunn_mode_port(struct qed_hwfn *p_hwfn,
 }
 
 int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
+		    struct qed_ptt *p_ptt,
 		    struct qed_tunnel_info *p_tunn,
 		    enum qed_mf_mode mode, bool allow_npar_tx_switch)
 {
@@ -399,7 +401,8 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	rc = qed_spq_post(p_hwfn, p_ent, NULL);
 
 	if (p_tunn)
-		qed_set_hw_tunn_mode_port(p_hwfn, &p_hwfn->cdev->tunnel);
+		qed_set_hw_tunn_mode_port(p_hwfn, p_ptt,
+					  &p_hwfn->cdev->tunnel);
 
 	return rc;
 }
@@ -430,6 +433,7 @@ int qed_sp_pf_update(struct qed_hwfn *p_hwfn)
 
 /* Set pf update ramrod command params */
 int qed_sp_pf_update_tunn_cfg(struct qed_hwfn *p_hwfn,
+			      struct qed_ptt *p_ptt,
 			      struct qed_tunnel_info *p_tunn,
 			      enum spq_mode comp_mode,
 			      struct qed_spq_comp_cb *p_comp_data)
@@ -464,7 +468,7 @@ int qed_sp_pf_update_tunn_cfg(struct qed_hwfn *p_hwfn,
 	if (rc)
 		return rc;
 
-	qed_set_hw_tunn_mode_port(p_hwfn, &p_hwfn->cdev->tunnel);
+	qed_set_hw_tunn_mode_port(p_hwfn, p_ptt, &p_hwfn->cdev->tunnel);
 
 	return rc;
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index f5ed54d..71e392f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -2209,7 +2209,7 @@ static void qed_iov_vf_mbx_update_tunn_param(struct qed_hwfn *p_hwfn,
 	if (b_update_required) {
 		u16 geneve_port;
 
-		rc = qed_sp_pf_update_tunn_cfg(p_hwfn, &tunn,
+		rc = qed_sp_pf_update_tunn_cfg(p_hwfn, p_ptt, &tunn,
 					       QED_SPQ_MODE_EBLOCK, NULL);
 		if (rc)
 			status = PFVF_STATUS_FAILURE;
-- 
1.9.3
