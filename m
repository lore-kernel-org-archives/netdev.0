From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH V2  18/22] bnxt_re: Support for DCB
Date: Thu,  8 Dec 2016 22:48:12 -0800
Message-ID: <1481266096-23331-19-git-send-email-selvin.xavier@broadcom.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp01.broadcom.com ([192.19.211.62]:45746 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932262AbcLIGsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 01:48:38 -0500
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch queries the configured RoCE APP Priority on the host
using the dcbnl API and programs the RoCE FW with the corresponding
Traffic Class(es) for the priority.

v2: Fixed some sparse warning and cleanup of function
bnxt_re_query_hwrm_pri2cos

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h |   3 +-
 drivers/infiniband/hw/bnxtre/bnxt_re.h       |   6 ++
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c  | 140 +++++++++++++++++++++++++++
 3 files changed, 148 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
index 3358f6d..a72dfab 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
@@ -156,4 +156,5 @@ int bnxt_qplib_alloc_fast_reg_page_list(struct bnxt_qplib_res *res,
 					struct bnxt_qplib_frpl *frpl, int max);
 int bnxt_qplib_free_fast_reg_page_list(struct bnxt_qplib_res *res,
 				       struct bnxt_qplib_frpl *frpl);
-#endif /* __BNXT_QPLIB_SP_H__*/
+int bnxt_qplib_map_tc2cos(struct bnxt_qplib_res *res, u16 *cids);
+#endif
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re.h b/drivers/infiniband/hw/bnxtre/bnxt_re.h
index 30f4b30..36b1d4f 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re.h
@@ -45,6 +45,9 @@
 #define BNXT_RE_REF_WAIT_COUNT		10
 #define BNXT_RE_DESC	"Broadcom NetXtreme-C/E RoCE Driver"
 
+#define BNXT_RE_ROCE_V1_ETH_TYPE	0x8915
+#define BNXT_RE_ROCE_V2_PORT_NO		4791
+
 #define BNXT_RE_PAGE_SIZE_4K		BIT(12)
 #define BNXT_RE_PAGE_SIZE_8K		BIT(13)
 #define BNXT_RE_PAGE_SIZE_64K		BIT(16)
@@ -95,6 +98,9 @@ struct bnxt_re_dev {
 
 	int				id;
 
+	struct delayed_work		worker;
+	u8				cur_prio_map;
+
 	/* FP Notification Queue (CQ & SRQ) */
 	struct tasklet_struct		nq_task;
 
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
index 260dec1..f3ce02c 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -44,6 +44,7 @@
 #include <linux/rculist.h>
 #include <linux/spinlock.h>
 #include <linux/pci.h>
+#include <net/dcbnl.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 
@@ -734,6 +735,50 @@ static void bnxt_re_dispatch_event(struct ib_device *ibdev, struct ib_qp *qp,
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
@@ -774,6 +819,80 @@ static void bnxt_re_dev_stop(struct bnxt_re_dev *rdev, bool qp_wait)
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
+	app.protocol = BNXT_RE_ROCE_V2_PORT_NO;
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
@@ -785,6 +904,9 @@ static void bnxt_re_ib_unreg(struct bnxt_re_dev *rdev, bool lock_wait)
 		/* Cleanup ib dev */
 		bnxt_re_unregister_ib(rdev);
 	}
+	if (test_and_clear_bit(BNXT_RE_FLAG_QOS_WORK_REG, &rdev->flags))
+		cancel_delayed_work(&rdev->worker);
+
 	bnxt_re_cleanup_res(rdev);
 	bnxt_re_free_res(rdev, lock_wait);
 
@@ -827,6 +949,16 @@ static void bnxt_re_set_resource_limits(struct bnxt_re_dev *rdev)
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
@@ -911,6 +1043,14 @@ static int bnxt_re_ib_reg(struct bnxt_re_dev *rdev)
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
