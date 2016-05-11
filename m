From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v2 06/14] qed: Bulletin and Link
Date: Wed, 11 May 2016 16:36:17 +0300
Message-ID: <1462973785-32532-7-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:10614 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932669AbcEKNhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 09:37:02 -0400
In-Reply-To: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Up to this point, VF and PF communication always originates from VF.
As a result, VF cannot be notified of any async changes, and specifically
cannot be informed of the current link state.

This introduces the bulletin board, the mechanism through which the PF
is going to communicate async notifications back to the VF. basically,
it's a well-defined structure agreed by both PF and VF which the VF would
continuously poll and into which the PF would DMA messages when needed.
[Bulletin board is actually allocated and communicated in previous patches
but never before used]

Based on the bulletin infrastructure, the VF can query its link status
and receive said async carrier changes.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c  |  12 ++-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 136 +++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_sriov.h |   5 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c    | 122 ++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h    | 156 ++++++++++++++++++++++++++++
 5 files changed, 425 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index e98610e..dcb782c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1119,9 +1119,9 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
 		memcpy(&link_caps, qed_mcp_get_link_capabilities(hwfn),
 		       sizeof(link_caps));
 	} else {
-		memset(&params, 0, sizeof(params));
-		memset(&link, 0, sizeof(link));
-		memset(&link_caps, 0, sizeof(link_caps));
+		qed_vf_get_link_params(hwfn, &params);
+		qed_vf_get_link_state(hwfn, &link);
+		qed_vf_get_link_caps(hwfn, &link_caps);
 	}
 
 	/* Set the link parameters to pass to protocol driver */
@@ -1224,7 +1224,12 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
 static void qed_get_current_link(struct qed_dev *cdev,
 				 struct qed_link_output *if_link)
 {
+	int i;
+
 	qed_fill_link(&cdev->hwfns[0], if_link);
+
+	for_each_hwfn(cdev, i)
+		qed_inform_vf_link_state(&cdev->hwfns[i]);
 }
 
 void qed_link_update(struct qed_hwfn *hwfn)
@@ -1234,6 +1239,7 @@ void qed_link_update(struct qed_hwfn *hwfn)
 	struct qed_link_output if_link;
 
 	qed_fill_link(hwfn, &if_link);
+	qed_inform_vf_link_state(hwfn);
 
 	if (IS_LEAD_HWFN(hwfn) && cookie)
 		op->link_update(cookie, &if_link);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 82f1eda3..f6540c0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/etherdevice.h>
+#include <linux/crc32.h>
 #include <linux/qed/qed_iov_if.h>
 #include "qed_cxt.h"
 #include "qed_hsi.h"
@@ -116,6 +117,41 @@ static struct qed_vf_info *qed_iov_get_vf_info(struct qed_hwfn *p_hwfn,
 	return vf;
 }
 
+int qed_iov_post_vf_bulletin(struct qed_hwfn *p_hwfn,
+			     int vfid, struct qed_ptt *p_ptt)
+{
+	struct qed_bulletin_content *p_bulletin;
+	int crc_size = sizeof(p_bulletin->crc);
+	struct qed_dmae_params params;
+	struct qed_vf_info *p_vf;
+
+	p_vf = qed_iov_get_vf_info(p_hwfn, (u16) vfid, true);
+	if (!p_vf)
+		return -EINVAL;
+
+	if (!p_vf->vf_bulletin)
+		return -EINVAL;
+
+	p_bulletin = p_vf->bulletin.p_virt;
+
+	/* Increment bulletin board version and compute crc */
+	p_bulletin->version++;
+	p_bulletin->crc = crc32(0, (u8 *)p_bulletin + crc_size,
+				p_vf->bulletin.size - crc_size);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+		   "Posting Bulletin 0x%08x to VF[%d] (CRC 0x%08x)\n",
+		   p_bulletin->version, p_vf->relative_vf_id, p_bulletin->crc);
+
+	/* propagate bulletin board via dmae to vm memory */
+	memset(&params, 0, sizeof(params));
+	params.flags = QED_DMAE_FLAG_VF_DST;
+	params.dst_vfid = p_vf->abs_vf_id;
+	return qed_dmae_host2host(p_hwfn, p_ptt, p_vf->bulletin.phys,
+				  p_vf->vf_bulletin, p_vf->bulletin.size / 4,
+				  &params);
+}
+
 static int qed_iov_pci_cfg_info(struct qed_dev *cdev)
 {
 	struct qed_hw_sriov_info *iov = cdev->p_iov_info;
@@ -790,6 +826,11 @@ static int qed_iov_release_hw_for_vf(struct qed_hwfn *p_hwfn,
 		return -EINVAL;
 	}
 
+	if (vf->bulletin.p_virt)
+		memset(vf->bulletin.p_virt, 0, sizeof(*vf->bulletin.p_virt));
+
+	memset(&vf->p_vf_info, 0, sizeof(vf->p_vf_info));
+
 	if (vf->state != VF_STOPPED) {
 		/* Stopping the VF */
 		rc = qed_sp_vf_stop(p_hwfn, vf->concrete_fid, vf->opaque_fid);
@@ -1159,6 +1200,7 @@ static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
 
 	/* Fill agreed size of bulletin board in response */
 	resp->bulletin_size = vf->bulletin.size;
+	qed_iov_post_vf_bulletin(p_hwfn, vf->relative_vf_id, p_ptt);
 
 	DP_VERBOSE(p_hwfn,
 		   QED_MSG_IOV,
@@ -2019,6 +2061,45 @@ int qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn, u32 *p_disabled_vfs)
 	return found;
 }
 
+void qed_iov_set_link(struct qed_hwfn *p_hwfn,
+		      u16 vfid,
+		      struct qed_mcp_link_params *params,
+		      struct qed_mcp_link_state *link,
+		      struct qed_mcp_link_capabilities *p_caps)
+{
+	struct qed_vf_info *p_vf = qed_iov_get_vf_info(p_hwfn,
+						       vfid,
+						       false);
+	struct qed_bulletin_content *p_bulletin;
+
+	if (!p_vf)
+		return;
+
+	p_bulletin = p_vf->bulletin.p_virt;
+	p_bulletin->req_autoneg = params->speed.autoneg;
+	p_bulletin->req_adv_speed = params->speed.advertised_speeds;
+	p_bulletin->req_forced_speed = params->speed.forced_speed;
+	p_bulletin->req_autoneg_pause = params->pause.autoneg;
+	p_bulletin->req_forced_rx = params->pause.forced_rx;
+	p_bulletin->req_forced_tx = params->pause.forced_tx;
+	p_bulletin->req_loopback = params->loopback_mode;
+
+	p_bulletin->link_up = link->link_up;
+	p_bulletin->speed = link->speed;
+	p_bulletin->full_duplex = link->full_duplex;
+	p_bulletin->autoneg = link->an;
+	p_bulletin->autoneg_complete = link->an_complete;
+	p_bulletin->parallel_detection = link->parallel_detection;
+	p_bulletin->pfc_enabled = link->pfc_enabled;
+	p_bulletin->partner_adv_speed = link->partner_adv_speed;
+	p_bulletin->partner_tx_flow_ctrl_en = link->partner_tx_flow_ctrl_en;
+	p_bulletin->partner_rx_flow_ctrl_en = link->partner_rx_flow_ctrl_en;
+	p_bulletin->partner_adv_pause = link->partner_adv_pause;
+	p_bulletin->sfp_tx_fault = link->sfp_tx_fault;
+
+	p_bulletin->capability_speed = p_caps->speed_capabilities;
+}
+
 static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 				    struct qed_ptt *p_ptt, int vfid)
 {
@@ -2359,6 +2440,29 @@ static int qed_sriov_configure(struct qed_dev *cdev, int num_vfs_param)
 		return qed_sriov_disable(cdev, true);
 }
 
+void qed_inform_vf_link_state(struct qed_hwfn *hwfn)
+{
+	struct qed_mcp_link_capabilities caps;
+	struct qed_mcp_link_params params;
+	struct qed_mcp_link_state link;
+	int i;
+
+	if (!hwfn->pf_iov_info)
+		return;
+
+	/* Update bulletin of all future possible VFs with link configuration */
+	for (i = 0; i < hwfn->cdev->p_iov_info->total_vfs; i++) {
+		memcpy(&params, qed_mcp_get_link_params(hwfn), sizeof(params));
+		memcpy(&link, qed_mcp_get_link_state(hwfn), sizeof(link));
+		memcpy(&caps, qed_mcp_get_link_capabilities(hwfn),
+		       sizeof(caps));
+
+		qed_iov_set_link(hwfn, i, &params, &link, &caps);
+	}
+
+	qed_schedule_iov(hwfn, QED_IOV_WQ_BULLETIN_UPDATE_FLAG);
+}
+
 static void qed_handle_vf_msg(struct qed_hwfn *hwfn)
 {
 	u64 events[QED_VF_ARRAY_LENGTH];
@@ -2398,6 +2502,24 @@ static void qed_handle_vf_msg(struct qed_hwfn *hwfn)
 	qed_ptt_release(hwfn, ptt);
 }
 
+static void qed_handle_bulletin_post(struct qed_hwfn *hwfn)
+{
+	struct qed_ptt *ptt;
+	int i;
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt) {
+		DP_NOTICE(hwfn, "Failed allocating a ptt entry\n");
+		qed_schedule_iov(hwfn, QED_IOV_WQ_BULLETIN_UPDATE_FLAG);
+		return;
+	}
+
+	qed_for_each_vf(hwfn, i)
+	    qed_iov_post_vf_bulletin(hwfn, i, ptt);
+
+	qed_ptt_release(hwfn, ptt);
+}
+
 void qed_iov_pf_task(struct work_struct *work)
 {
 	struct qed_hwfn *hwfn = container_of(work, struct qed_hwfn,
@@ -2424,6 +2546,9 @@ void qed_iov_pf_task(struct work_struct *work)
 
 	if (test_and_clear_bit(QED_IOV_WQ_MSG_FLAG, &hwfn->iov_task_flags))
 		qed_handle_vf_msg(hwfn);
+	if (test_and_clear_bit(QED_IOV_WQ_BULLETIN_UPDATE_FLAG,
+			       &hwfn->iov_task_flags))
+		qed_handle_bulletin_post(hwfn);
 }
 
 void qed_iov_wq_stop(struct qed_dev *cdev, bool schedule_first)
@@ -2453,8 +2578,10 @@ int qed_iov_wq_start(struct qed_dev *cdev)
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
-		/* PFs needs a dedicated workqueue only if they support IOV. */
-		if (!IS_PF_SRIOV(p_hwfn))
+		/* PFs needs a dedicated workqueue only if they support IOV.
+		 * VFs always require one.
+		 */
+		if (IS_PF(p_hwfn->cdev) && !IS_PF_SRIOV(p_hwfn))
 			continue;
 
 		snprintf(name, NAME_SIZE, "iov-%02x:%02x.%02x",
@@ -2467,7 +2594,10 @@ int qed_iov_wq_start(struct qed_dev *cdev)
 			return -ENOMEM;
 		}
 
-		INIT_DELAYED_WORK(&p_hwfn->iov_task, qed_iov_pf_task);
+		if (IS_PF(cdev))
+			INIT_DELAYED_WORK(&p_hwfn->iov_task, qed_iov_pf_task);
+		else
+			INIT_DELAYED_WORK(&p_hwfn->iov_task, qed_iov_vf_task);
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 63bce9c..0f5689b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -268,6 +268,7 @@ int qed_iov_wq_start(struct qed_dev *cdev);
 void qed_schedule_iov(struct qed_hwfn *hwfn, enum qed_iov_wq_flag flag);
 void qed_vf_start_iov_wq(struct qed_dev *cdev);
 int qed_sriov_disable(struct qed_dev *cdev, bool pci_enabled);
+void qed_inform_vf_link_state(struct qed_hwfn *hwfn);
 #else
 static inline u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn,
 					     u16 rel_vf_id)
@@ -332,6 +333,10 @@ static inline int qed_sriov_disable(struct qed_dev *cdev, bool pci_enabled)
 {
 	return 0;
 }
+
+static inline void qed_inform_vf_link_state(struct qed_hwfn *hwfn)
+{
+}
 #endif
 
 #define qed_for_each_vf(_p_hwfn, _i)			  \
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 961de77..05b3cca 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -6,6 +6,7 @@
  * this source tree.
  */
 
+#include <linux/crc32.h>
 #include "qed.h"
 #include "qed_sriov.h"
 #include "qed_vf.h"
@@ -865,6 +866,103 @@ u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
 	return p_iov->acquire_resp.resc.hw_sbs[sb_id].hw_sb_id;
 }
 
+int qed_vf_read_bulletin(struct qed_hwfn *p_hwfn, u8 *p_change)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct qed_bulletin_content shadow;
+	u32 crc, crc_size;
+
+	crc_size = sizeof(p_iov->bulletin.p_virt->crc);
+	*p_change = 0;
+
+	/* Need to guarantee PF is not in the middle of writing it */
+	memcpy(&shadow, p_iov->bulletin.p_virt, p_iov->bulletin.size);
+
+	/* If version did not update, no need to do anything */
+	if (shadow.version == p_iov->bulletin_shadow.version)
+		return 0;
+
+	/* Verify the bulletin we see is valid */
+	crc = crc32(0, (u8 *)&shadow + crc_size,
+		    p_iov->bulletin.size - crc_size);
+	if (crc != shadow.crc)
+		return -EAGAIN;
+
+	/* Set the shadow bulletin and process it */
+	memcpy(&p_iov->bulletin_shadow, &shadow, p_iov->bulletin.size);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+		   "Read a bulletin update %08x\n", shadow.version);
+
+	*p_change = 1;
+
+	return 0;
+}
+
+void __qed_vf_get_link_params(struct qed_hwfn *p_hwfn,
+			      struct qed_mcp_link_params *p_params,
+			      struct qed_bulletin_content *p_bulletin)
+{
+	memset(p_params, 0, sizeof(*p_params));
+
+	p_params->speed.autoneg = p_bulletin->req_autoneg;
+	p_params->speed.advertised_speeds = p_bulletin->req_adv_speed;
+	p_params->speed.forced_speed = p_bulletin->req_forced_speed;
+	p_params->pause.autoneg = p_bulletin->req_autoneg_pause;
+	p_params->pause.forced_rx = p_bulletin->req_forced_rx;
+	p_params->pause.forced_tx = p_bulletin->req_forced_tx;
+	p_params->loopback_mode = p_bulletin->req_loopback;
+}
+
+void qed_vf_get_link_params(struct qed_hwfn *p_hwfn,
+			    struct qed_mcp_link_params *params)
+{
+	__qed_vf_get_link_params(p_hwfn, params,
+				 &(p_hwfn->vf_iov_info->bulletin_shadow));
+}
+
+void __qed_vf_get_link_state(struct qed_hwfn *p_hwfn,
+			     struct qed_mcp_link_state *p_link,
+			     struct qed_bulletin_content *p_bulletin)
+{
+	memset(p_link, 0, sizeof(*p_link));
+
+	p_link->link_up = p_bulletin->link_up;
+	p_link->speed = p_bulletin->speed;
+	p_link->full_duplex = p_bulletin->full_duplex;
+	p_link->an = p_bulletin->autoneg;
+	p_link->an_complete = p_bulletin->autoneg_complete;
+	p_link->parallel_detection = p_bulletin->parallel_detection;
+	p_link->pfc_enabled = p_bulletin->pfc_enabled;
+	p_link->partner_adv_speed = p_bulletin->partner_adv_speed;
+	p_link->partner_tx_flow_ctrl_en = p_bulletin->partner_tx_flow_ctrl_en;
+	p_link->partner_rx_flow_ctrl_en = p_bulletin->partner_rx_flow_ctrl_en;
+	p_link->partner_adv_pause = p_bulletin->partner_adv_pause;
+	p_link->sfp_tx_fault = p_bulletin->sfp_tx_fault;
+}
+
+void qed_vf_get_link_state(struct qed_hwfn *p_hwfn,
+			   struct qed_mcp_link_state *link)
+{
+	__qed_vf_get_link_state(p_hwfn, link,
+				&(p_hwfn->vf_iov_info->bulletin_shadow));
+}
+
+void __qed_vf_get_link_caps(struct qed_hwfn *p_hwfn,
+			    struct qed_mcp_link_capabilities *p_link_caps,
+			    struct qed_bulletin_content *p_bulletin)
+{
+	memset(p_link_caps, 0, sizeof(*p_link_caps));
+	p_link_caps->speed_capabilities = p_bulletin->capability_speed;
+}
+
+void qed_vf_get_link_caps(struct qed_hwfn *p_hwfn,
+			  struct qed_mcp_link_capabilities *p_link_caps)
+{
+	__qed_vf_get_link_caps(p_hwfn, p_link_caps,
+			       &(p_hwfn->vf_iov_info->bulletin_shadow));
+}
+
 void qed_vf_get_num_rxqs(struct qed_hwfn *p_hwfn, u8 *num_rxqs)
 {
 	*num_rxqs = p_hwfn->vf_iov_info->acquire_resp.resc.num_rxqs;
@@ -897,3 +995,27 @@ void qed_vf_get_fw_version(struct qed_hwfn *p_hwfn,
 	*fw_rev = info->fw_rev;
 	*fw_eng = info->fw_eng;
 }
+
+static void qed_handle_bulletin_change(struct qed_hwfn *hwfn)
+{
+	/* Always update link configuration according to bulletin */
+	qed_link_update(hwfn);
+}
+
+void qed_iov_vf_task(struct work_struct *work)
+{
+	struct qed_hwfn *hwfn = container_of(work, struct qed_hwfn,
+					     iov_task.work);
+	u8 change = 0;
+
+	if (test_and_clear_bit(QED_IOV_WQ_STOP_WQ_FLAG, &hwfn->iov_task_flags))
+		return;
+
+	/* Handle bulletin board changes */
+	qed_vf_read_bulletin(hwfn, &change);
+	if (change)
+		qed_handle_bulletin_change(hwfn);
+
+	/* As VF is polling bulletin board, need to constantly re-schedule */
+	queue_delayed_work(hwfn->iov_wq, &hwfn->iov_task, HZ);
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index 81600eb..2d24965 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -10,6 +10,7 @@
 #define _QED_VF_H
 
 #include "qed_l2.h"
+#include "qed_mcp.h"
 
 #define T_ETH_INDIRECTION_TABLE_SIZE 128
 #define T_ETH_RSS_KEY_SIZE 10
@@ -377,6 +378,46 @@ struct qed_bulletin_content {
 
 	/* bitmap indicating which fields hold valid values */
 	u64 valid_bitmap;
+
+	/* used for MAC_ADDR or MAC_ADDR_FORCED */
+	u8 mac[ETH_ALEN];
+
+	/* If valid, 1 => only untagged Rx if no vlan is configured */
+	u8 default_only_untagged;
+	u8 padding;
+
+	/* The following is a 'copy' of qed_mcp_link_state,
+	 * qed_mcp_link_params and qed_mcp_link_capabilities. Since it's
+	 * possible the structs will increase further along the road we cannot
+	 * have it here; Instead we need to have all of its fields.
+	 */
+	u8 req_autoneg;
+	u8 req_autoneg_pause;
+	u8 req_forced_rx;
+	u8 req_forced_tx;
+	u8 padding2[4];
+
+	u32 req_adv_speed;
+	u32 req_forced_speed;
+	u32 req_loopback;
+	u32 padding3;
+
+	u8 link_up;
+	u8 full_duplex;
+	u8 autoneg;
+	u8 autoneg_complete;
+	u8 parallel_detection;
+	u8 pfc_enabled;
+	u8 partner_tx_flow_ctrl_en;
+	u8 partner_rx_flow_ctrl_en;
+	u8 partner_adv_pause;
+	u8 sfp_tx_fault;
+	u8 padding4[6];
+
+	u32 speed;
+	u32 partner_adv_speed;
+
+	u32 capability_speed;
 };
 
 struct qed_bulletin {
@@ -433,6 +474,43 @@ struct qed_vf_iov {
 
 #ifdef CONFIG_QED_SRIOV
 /**
+ * @brief Read the VF bulletin and act on it if needed
+ *
+ * @param p_hwfn
+ * @param p_change - qed fills 1 iff bulletin board has changed, 0 otherwise.
+ *
+ * @return enum _qed_status
+ */
+int qed_vf_read_bulletin(struct qed_hwfn *p_hwfn, u8 *p_change);
+
+/**
+ * @brief Get link paramters for VF from qed
+ *
+ * @param p_hwfn
+ * @param params - the link params structure to be filled for the VF
+ */
+void qed_vf_get_link_params(struct qed_hwfn *p_hwfn,
+			    struct qed_mcp_link_params *params);
+
+/**
+ * @brief Get link state for VF from qed
+ *
+ * @param p_hwfn
+ * @param link - the link state structure to be filled for the VF
+ */
+void qed_vf_get_link_state(struct qed_hwfn *p_hwfn,
+			   struct qed_mcp_link_state *link);
+
+/**
+ * @brief Get link capabilities for VF from qed
+ *
+ * @param p_hwfn
+ * @param p_link_caps - the link capabilities structure to be filled for the VF
+ */
+void qed_vf_get_link_caps(struct qed_hwfn *p_hwfn,
+			  struct qed_mcp_link_capabilities *p_link_caps);
+
+/**
  * @brief Get number of Rx queues allocated for VF by qed
  *
  *  @param p_hwfn
@@ -577,6 +655,7 @@ int qed_vf_pf_reset(struct qed_hwfn *p_hwfn);
  * @return enum _qed_status
  */
 int qed_vf_pf_release(struct qed_hwfn *p_hwfn);
+
 /**
  * @brief qed_vf_get_igu_sb_id - Get the IGU SB ID for a given
  *        sb_id. For VFs igu sbs don't have to be contiguous
@@ -631,7 +710,58 @@ void qed_vf_pf_filter_mcast(struct qed_hwfn *p_hwfn,
  * @return enum _qed_status
  */
 int qed_vf_pf_int_cleanup(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief - return the link params in a given bulletin board
+ *
+ * @param p_hwfn
+ * @param p_params - pointer to a struct to fill with link params
+ * @param p_bulletin
+ */
+void __qed_vf_get_link_params(struct qed_hwfn *p_hwfn,
+			      struct qed_mcp_link_params *p_params,
+			      struct qed_bulletin_content *p_bulletin);
+
+/**
+ * @brief - return the link state in a given bulletin board
+ *
+ * @param p_hwfn
+ * @param p_link - pointer to a struct to fill with link state
+ * @param p_bulletin
+ */
+void __qed_vf_get_link_state(struct qed_hwfn *p_hwfn,
+			     struct qed_mcp_link_state *p_link,
+			     struct qed_bulletin_content *p_bulletin);
+
+/**
+ * @brief - return the link capabilities in a given bulletin board
+ *
+ * @param p_hwfn
+ * @param p_link - pointer to a struct to fill with link capabilities
+ * @param p_bulletin
+ */
+void __qed_vf_get_link_caps(struct qed_hwfn *p_hwfn,
+			    struct qed_mcp_link_capabilities *p_link_caps,
+			    struct qed_bulletin_content *p_bulletin);
+
+void qed_iov_vf_task(struct work_struct *work);
 #else
+static inline void qed_vf_get_link_params(struct qed_hwfn *p_hwfn,
+					  struct qed_mcp_link_params *params)
+{
+}
+
+static inline void qed_vf_get_link_state(struct qed_hwfn *p_hwfn,
+					 struct qed_mcp_link_state *link)
+{
+}
+
+static inline void
+qed_vf_get_link_caps(struct qed_hwfn *p_hwfn,
+		     struct qed_mcp_link_capabilities *p_link_caps)
+{
+}
+
 static inline void qed_vf_get_num_rxqs(struct qed_hwfn *p_hwfn, u8 *num_rxqs)
 {
 }
@@ -741,6 +871,32 @@ static inline int qed_vf_pf_int_cleanup(struct qed_hwfn *p_hwfn)
 {
 	return -EINVAL;
 }
+
+static inline void __qed_vf_get_link_params(struct qed_hwfn *p_hwfn,
+					    struct qed_mcp_link_params
+					    *p_params,
+					    struct qed_bulletin_content
+					    *p_bulletin)
+{
+}
+
+static inline void __qed_vf_get_link_state(struct qed_hwfn *p_hwfn,
+					   struct qed_mcp_link_state *p_link,
+					   struct qed_bulletin_content
+					   *p_bulletin)
+{
+}
+
+static inline void
+__qed_vf_get_link_caps(struct qed_hwfn *p_hwfn,
+		       struct qed_mcp_link_capabilities *p_link_caps,
+		       struct qed_bulletin_content *p_bulletin)
+{
+}
+
+static inline void qed_iov_vf_task(struct work_struct *work)
+{
+}
 #endif
 
 #endif
-- 
1.9.3
