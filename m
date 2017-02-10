From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH V5 for-next 18/21] RDMA/bnxt_re: Support for DCB
Date: Fri, 10 Feb 2017 03:19:50 -0800
Message-ID: <1486725593-9872-19-git-send-email-selvin.xavier@broadcom.com>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486725593-9872-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch queries the configured RoCE APP Priority on the host
using the dcbnl API and programs the RoCE FW with the corresponding
Traffic Class(es) for the priority.

v2: Fixed some sparse warning and cleanup of function
bnxt_re_query_hwrm_pri2cos

v3: Adds bnxt_qplib_map_tc2cos as a part of this patch. Uses
    ROCE_V2_UDP_DPORT instead of BNXT_RE_ROCE_V2_PORT_NO.

v5: Uses ETH_P_IBOE macro for RoCE ethertype

Signed-off-by: Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/bnxt_re/bnxt_re.h  |   3 +
 drivers/infiniband/hw/bnxt_re/main.c     | 141 +++++++++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/qplib_sp.c |  37 ++++++++
 drivers/infiniband/hw/bnxt_re/qplib_sp.h |   1 +
 4 files changed, 182 insertions(+)

diff --git a/drivers/infiniband/hw/bnxt_re/bnxt_re.h b/drivers/infiniband/hw/bnxt_re/bnxt_re.h
index 5032ca1..ebf7be8 100644
--- a/drivers/infiniband/hw/bnxt_re/bnxt_re.h
+++ b/drivers/infiniband/hw/bnxt_re/bnxt_re.h
@@ -93,6 +93,9 @@ struct bnxt_re_dev {
 
 	int				id;
 
+	struct delayed_work		worker;
+	u8				cur_prio_map;
+
 	/* FP Notification Queue (CQ & SRQ) */
 	struct tasklet_struct		nq_task;
 
diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index c84691a..92a217b 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -44,8 +44,10 @@
 #include <linux/rculist.h>
 #include <linux/spinlock.h>
 #include <linux/pci.h>
+#include <net/dcbnl.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
+#include <linux/if_ether.h>
 
 #include <rdma/ib_verbs.h>
 #include <rdma/ib_user_verbs.h>
@@ -726,6 +728,50 @@ static void bnxt_re_dispatch_event(struct ib_device *ibdev, struct ib_qp *qp,
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
@@ -757,6 +803,80 @@ static void bnxt_re_dev_stop(struct bnxt_re_dev *rdev)
 	mutex_unlock(&rdev->qp_lock);
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
+	app.protocol = ETH_P_IBOE;
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
@@ -768,6 +888,9 @@ static void bnxt_re_ib_unreg(struct bnxt_re_dev *rdev, bool lock_wait)
 		/* Cleanup ib dev */
 		bnxt_re_unregister_ib(rdev);
 	}
+	if (test_and_clear_bit(BNXT_RE_FLAG_QOS_WORK_REG, &rdev->flags))
+		cancel_delayed_work(&rdev->worker);
+
 	bnxt_re_cleanup_res(rdev);
 	bnxt_re_free_res(rdev, lock_wait);
 
@@ -810,6 +933,16 @@ static void bnxt_re_set_resource_limits(struct bnxt_re_dev *rdev)
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
@@ -894,6 +1027,14 @@ static int bnxt_re_ib_reg(struct bnxt_re_dev *rdev)
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
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_sp.c b/drivers/infiniband/hw/bnxt_re/qplib_sp.c
index a936c48..7b31ecc 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_sp.c
+++ b/drivers/infiniband/hw/bnxt_re/qplib_sp.c
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
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_sp.h b/drivers/infiniband/hw/bnxt_re/qplib_sp.h
index 18c94c8..1442a61 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_sp.h
+++ b/drivers/infiniband/hw/bnxt_re/qplib_sp.h
@@ -156,4 +156,5 @@ int bnxt_qplib_alloc_fast_reg_page_list(struct bnxt_qplib_res *res,
 					struct bnxt_qplib_frpl *frpl, int max);
 int bnxt_qplib_free_fast_reg_page_list(struct bnxt_qplib_res *res,
 				       struct bnxt_qplib_frpl *frpl);
+int bnxt_qplib_map_tc2cos(struct bnxt_qplib_res *res, u16 *cids);
 #endif /* __BNXT_QPLIB_SP_H__*/
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
