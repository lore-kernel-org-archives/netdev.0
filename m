From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH for bnxt_re V3 18/21] bnxt_re: Support for DCB
Date: Tue, 20 Dec 2016 01:13:28 -0800
Message-ID: <1482225211-22423-19-git-send-email-selvin.xavier@broadcom.com>
References: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:35287 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933824AbcLTJPD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 04:15:03 -0500
Received: by mail-qk0-f176.google.com with SMTP id u25so31406761qki.2
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 01:15:03 -0800 (PST)
In-Reply-To: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch queries the configured RoCE APP Priority on the host
using the dcbnl API and programs the RoCE FW with the corresponding
Traffic Class(es) for the priority.

v2: Fixed some sparse warning and cleanup of function
bnxt_re_query_hwrm_pri2cos

v3: Adds bnxt_qplib_map_tc2cos as a part of this patch. Uses
    ROCE_V2_UDP_DPORT instead of BNXT_RE_ROCE_V2_PORT_NO.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c |  37 +++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h |   1 +
 drivers/infiniband/hw/bnxtre/bnxt_re.h       |   5 +
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c  | 140 +++++++++++++++++++++++++++
 4 files changed, 183 insertions(+)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
index 4f77af8..aaafcf99 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
@@ -799,3 +799,40 @@ int bnxt_qplib_free_fast_reg_page_list(struct bnxt_qplib_res *res,
 	bnxt_qplib_free_hwq(res->pdev, &frpl->hwq);
 	return 0;
 }
+
+int bnxt_qplib_map_tc2cos(struct bnxt_qplib_res *res, u16 *cids)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_map_tc_to_cos req;
+	struct creq_map_tc_to_cos_resp *resp;
+	u16 cmd_flags = 0;
+	int tleft;
+
+	RCFW_CMD_PREP(req, MAP_TC_TO_COS, cmd_flags);
+	req.cos0 = cpu_to_le16(cids[0]);
+	req.cos1 = cpu_to_le16(cids[1]);
+
+	resp = bnxt_qplib_rcfw_send_message(rcfw, (void *)&req, NULL, 0);
+	if (!resp) {
+		dev_err(&res->pdev->dev, "QPLIB: SP: MAP_TC2COS send failed");
+		return -EINVAL;
+	}
+
+	tleft = bnxt_qplib_rcfw_block_for_resp(rcfw, le16_to_cpu(req.cookie));
+	if (!tleft) {
+		dev_err(&res->pdev->dev, "QPLIB: SP: MAP_TC2COS timed out");
+		return -ETIMEDOUT;
+	}
+
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&res->pdev->dev, "QPLIB: SP: MAP_TC2COS failed ");
+		dev_err(&res->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		return -EINVAL;
+	}
+
+	return 0;
+}
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
index 3358f6d..96437bb 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
@@ -156,4 +156,5 @@ int bnxt_qplib_alloc_fast_reg_page_list(struct bnxt_qplib_res *res,
 					struct bnxt_qplib_frpl *frpl, int max);
 int bnxt_qplib_free_fast_reg_page_list(struct bnxt_qplib_res *res,
 				       struct bnxt_qplib_frpl *frpl);
+int bnxt_qplib_map_tc2cos(struct bnxt_qplib_res *res, u16 *cids);
 #endif /* __BNXT_QPLIB_SP_H__*/
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re.h b/drivers/infiniband/hw/bnxtre/bnxt_re.h
index 6281e23..5565be8 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re.h
@@ -45,6 +45,8 @@
 #define BNXT_RE_REF_WAIT_COUNT		10
 #define BNXT_RE_DESC	"Broadcom NetXtreme-C/E RoCE Driver"
 
+#define BNXT_RE_ROCE_V1_ETH_TYPE	0x8915
+
 #define BNXT_RE_PAGE_SIZE_4K		BIT(12)
 #define BNXT_RE_PAGE_SIZE_8K		BIT(13)
 #define BNXT_RE_PAGE_SIZE_64K		BIT(16)
@@ -95,6 +97,9 @@ struct bnxt_re_dev {
 
 	int				id;
 
+	struct delayed_work		worker;
+	u8				cur_prio_map;
+
 	/* FP Notification Queue (CQ & SRQ) */
 	struct tasklet_struct		nq_task;
 
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
index 3a45b53..ba082f1 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -44,6 +44,7 @@
 #include <linux/rculist.h>
 #include <linux/spinlock.h>
 #include <linux/pci.h>
+#include <net/dcbnl.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 
@@ -743,6 +744,50 @@ static void bnxt_re_dispatch_event(struct ib_device *ibdev, struct ib_qp *qp,
 	ib_dispatch_event(&ib_event);
 }
 
+#define HWRM_QUEUE_PRI2COS_QCFG_INPUT_FLAGS_IVLAN      0x02
+static int bnxt_re_query_hwrm_pri2cos(struct bnxt_re_dev *rdev, u8 dir,
+				      u64 *cid_map)
+{
+	struct hwrm_queue_pri2cos_qcfg_input req = {0};
+	struct bnxt *bp = netdev_priv(rdev->netdev);
+	struct hwrm_queue_pri2cos_qcfg_output resp;
+	struct bnxt_en_dev *en_dev = rdev->en_dev;
+	struct bnxt_fw_msg fw_msg;
+	u32 flags = 0;
+	u8 *qcfgmap, *tmp_map;
+	int rc = 0, i;
+
+	if (!cid_map)
+		return -EINVAL;
+
+	memset(&fw_msg, 0, sizeof(fw_msg));
+	bnxt_re_init_hwrm_hdr(rdev, (void *)&req,
+			      HWRM_QUEUE_PRI2COS_QCFG, -1, -1);
+	flags |= (dir & 0x01);
+	flags |= HWRM_QUEUE_PRI2COS_QCFG_INPUT_FLAGS_IVLAN;
+	req.flags = cpu_to_le32(flags);
+	req.port_id = bp->pf.port_id;
+
+	bnxt_re_fill_fw_msg(&fw_msg, (void *)&req, sizeof(req), (void *)&resp,
+			    sizeof(resp), DFLT_HWRM_CMD_TIMEOUT);
+	rc = en_dev->en_ops->bnxt_send_fw_msg(en_dev, BNXT_ROCE_ULP, &fw_msg);
+	if (rc)
+		return rc;
+
+	if (resp.queue_cfg_info) {
+		dev_warn(rdev_to_dev(rdev),
+			 "Asymmetric cos queue configuration detected");
+		dev_warn(rdev_to_dev(rdev),
+			 " on device, QoS may not be fully functional\n");
+	}
+	qcfgmap = &resp.pri0_cos_queue_id;
+	tmp_map = (u8 *)cid_map;
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+		tmp_map[i] = qcfgmap[i];
+
+	return rc;
+}
+
 static bool bnxt_re_is_qp1_or_shadow_qp(struct bnxt_re_dev *rdev,
 					struct bnxt_re_qp *qp)
 {
@@ -783,6 +828,80 @@ static void bnxt_re_dev_stop(struct bnxt_re_dev *rdev, bool qp_wait)
 	}
 }
 
+static u32 bnxt_re_get_priority_mask(struct bnxt_re_dev *rdev)
+{
+	u32 prio_map = 0, tmp_map = 0;
+	struct net_device *netdev;
+	struct dcb_app app;
+
+	netdev = rdev->netdev;
+
+	memset(&app, 0, sizeof(app));
+	app.selector = IEEE_8021QAZ_APP_SEL_ETHERTYPE;
+	app.protocol = BNXT_RE_ROCE_V1_ETH_TYPE;
+	tmp_map = dcb_ieee_getapp_mask(netdev, &app);
+	prio_map = tmp_map;
+
+	app.selector = IEEE_8021QAZ_APP_SEL_DGRAM;
+	app.protocol = ROCE_V2_UDP_DPORT;
+	tmp_map = dcb_ieee_getapp_mask(netdev, &app);
+	prio_map |= tmp_map;
+
+	if (!prio_map)
+		prio_map = -EFAULT;
+	return prio_map;
+}
+
+static void bnxt_re_parse_cid_map(u8 prio_map, u8 *cid_map, u16 *cosq)
+{
+	u16 prio;
+	u8 id;
+
+	for (prio = 0, id = 0; prio < 8; prio++) {
+		if (prio_map & (1 << prio)) {
+			cosq[id] = cid_map[prio];
+			id++;
+			if (id == 2) /* Max 2 tcs supported */
+				break;
+		}
+	}
+}
+
+static int bnxt_re_setup_qos(struct bnxt_re_dev *rdev)
+{
+	u8 prio_map = 0;
+	u64 cid_map;
+	int rc;
+
+	/* Get priority for roce */
+	rc = bnxt_re_get_priority_mask(rdev);
+	if (rc < 0)
+		return rc;
+	prio_map = (u8)rc;
+
+	if (prio_map == rdev->cur_prio_map)
+		return 0;
+	rdev->cur_prio_map = prio_map;
+	/* Get cosq id for this priority */
+	rc = bnxt_re_query_hwrm_pri2cos(rdev, 0, &cid_map);
+	if (rc) {
+		dev_warn(rdev_to_dev(rdev), "no cos for p_mask %x\n", prio_map);
+		return rc;
+	}
+	/* Parse CoS IDs for app priority */
+	bnxt_re_parse_cid_map(prio_map, (u8 *)&cid_map, rdev->cosq);
+
+	/* Config BONO. */
+	rc = bnxt_qplib_map_tc2cos(&rdev->qplib_res, rdev->cosq);
+	if (rc) {
+		dev_warn(rdev_to_dev(rdev), "no tc for cos{%x, %x}\n",
+			 rdev->cosq[0], rdev->cosq[1]);
+		return rc;
+	}
+
+	return 0;
+}
+
 static void bnxt_re_ib_unreg(struct bnxt_re_dev *rdev, bool lock_wait)
 {
 	int i, rc;
@@ -794,6 +913,9 @@ static void bnxt_re_ib_unreg(struct bnxt_re_dev *rdev, bool lock_wait)
 		/* Cleanup ib dev */
 		bnxt_re_unregister_ib(rdev);
 	}
+	if (test_and_clear_bit(BNXT_RE_FLAG_QOS_WORK_REG, &rdev->flags))
+		cancel_delayed_work(&rdev->worker);
+
 	bnxt_re_cleanup_res(rdev);
 	bnxt_re_free_res(rdev, lock_wait);
 
@@ -836,6 +958,16 @@ static void bnxt_re_set_resource_limits(struct bnxt_re_dev *rdev)
 		rdev->dev_attr.tqm_alloc_reqs[i];
 }
 
+/* worker thread for polling periodic events. Now used for QoS programming*/
+static void bnxt_re_worker(struct work_struct *work)
+{
+	struct bnxt_re_dev *rdev = container_of(work, struct bnxt_re_dev,
+						worker.work);
+
+	bnxt_re_setup_qos(rdev);
+	schedule_delayed_work(&rdev->worker, msecs_to_jiffies(30000));
+}
+
 static int bnxt_re_ib_reg(struct bnxt_re_dev *rdev)
 {
 	int i, j, rc;
@@ -920,6 +1052,14 @@ static int bnxt_re_ib_reg(struct bnxt_re_dev *rdev)
 		goto fail;
 	}
 
+	rc = bnxt_re_setup_qos(rdev);
+	if (rc)
+		pr_info("RoCE priority not yet configured\n");
+
+	INIT_DELAYED_WORK(&rdev->worker, bnxt_re_worker);
+	set_bit(BNXT_RE_FLAG_QOS_WORK_REG, &rdev->flags);
+	schedule_delayed_work(&rdev->worker, msecs_to_jiffies(30000));
+
 	/* Register ib dev */
 	rc = bnxt_re_register_ib(rdev);
 	if (rc) {
-- 
2.5.5
