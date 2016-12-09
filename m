From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH V2  09/22] bnxt_re: Support for GID related verbs
Date: Thu,  8 Dec 2016 22:48:03 -0800
Message-ID: <1481266096-23331-10-git-send-email-selvin.xavier@broadcom.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp01.broadcom.com ([192.19.211.62]:45715 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753423AbcLIGsc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 01:48:32 -0500
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements add/del GID, get_netdev and pkey related verbs.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c   |   5 +
 drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h   |   3 +
 drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c    | 218 ++++++++++++++++++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h    |  11 ++
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c | 123 +++++++++++++
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h |  18 ++
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c     |   7 +
 7 files changed, 385 insertions(+)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
index 9cb1b7a..deb3b15 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
@@ -509,6 +509,11 @@ static void bnxt_qplib_cleanup_sgid_tbl(struct bnxt_qplib_res *res,
 {
 	int i;
 
+	for (i = 0; i < sgid_tbl->max; i++) {
+		if (memcmp(&sgid_tbl->tbl[i], &bnxt_qplib_gid_zero,
+			   sizeof(bnxt_qplib_gid_zero)))
+			bnxt_qplib_del_sgid(sgid_tbl, &sgid_tbl->tbl[i], true);
+	}
 	memset(sgid_tbl->tbl, 0, sizeof(struct bnxt_qplib_gid) * sgid_tbl->max);
 	memset(sgid_tbl->hw_id, -1, sizeof(u16) * sgid_tbl->max);
 	sgid_tbl->active = 0;
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
index fc9c38c..6596ee2 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
@@ -186,6 +186,9 @@ struct bnxt_qplib_res {
 	struct bnxt_qplib_dpi_tbl	dpi_tbl;
 };
 
+#define to_bnxt_qplib(ptr, type, member)	\
+	container_of(ptr, type, member)
+
 struct bnxt_qplib_pd;
 struct bnxt_qplib_dev_attr;
 
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
index b3d6b46..cf9dd40 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
@@ -46,6 +46,10 @@
 #include "bnxt_qplib_res.h"
 #include "bnxt_qplib_rcfw.h"
 #include "bnxt_qplib_sp.h"
+
+const struct bnxt_qplib_gid bnxt_qplib_gid_zero = {{ 0, 0, 0, 0, 0, 0, 0, 0,
+						     0, 0, 0, 0, 0, 0, 0, 0 } };
+
 /* Device */
 int bnxt_qplib_get_dev_attr(struct bnxt_qplib_rcfw *rcfw,
 			    struct bnxt_qplib_dev_attr *attr)
@@ -129,6 +133,220 @@ int bnxt_qplib_get_dev_attr(struct bnxt_qplib_rcfw *rcfw,
 	return 0;
 }
 
+/* SGID */
+int bnxt_qplib_get_sgid(struct bnxt_qplib_res *res,
+			struct bnxt_qplib_sgid_tbl *sgid_tbl, int index,
+			struct bnxt_qplib_gid *gid)
+{
+	if (index > sgid_tbl->max) {
+		dev_err(&res->pdev->dev,
+			"QPLIB: Index %d exceeded SGID table max (%d)",
+			index, sgid_tbl->max);
+		return -EINVAL;
+	}
+	memcpy(gid, &sgid_tbl->tbl[index], sizeof(*gid));
+	return 0;
+}
+
+int bnxt_qplib_del_sgid(struct bnxt_qplib_sgid_tbl *sgid_tbl,
+			struct bnxt_qplib_gid *gid, bool update)
+{
+	struct bnxt_qplib_res *res = to_bnxt_qplib(sgid_tbl,
+						   struct bnxt_qplib_res,
+						   sgid_tbl);
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	int index;
+
+	if (!sgid_tbl) {
+		dev_err(&res->pdev->dev, "QPLIB: SGID table not allocated");
+		return -EINVAL;
+	}
+	/* Do we need a sgid_lock here? */
+	if (!sgid_tbl->active) {
+		dev_err(&res->pdev->dev,
+			"QPLIB: SGID table has no active entries");
+		return -ENOMEM;
+	}
+	for (index = 0; index < sgid_tbl->max; index++) {
+		if (!memcmp(&sgid_tbl->tbl[index], gid, sizeof(*gid)))
+			break;
+	}
+	if (index == sgid_tbl->max) {
+		dev_warn(&res->pdev->dev, "GID not found in the SGID table");
+		return 0;
+	}
+	/* Remove GID from the SGID table */
+	if (update) {
+		struct cmdq_delete_gid req;
+		struct creq_delete_gid_resp *resp;
+		u16 cmd_flags = 0;
+
+		RCFW_CMD_PREP(req, DELETE_GID, cmd_flags);
+		if (sgid_tbl->hw_id[index] == -1) {
+			dev_err(&res->pdev->dev,
+				"QPLIB: GID entry contains an invalid HW id");
+			return -EINVAL;
+		}
+		req.gid_index = cpu_to_le16(sgid_tbl->hw_id[index]);
+		resp = (struct creq_delete_gid_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req, NULL,
+						     0);
+		if (!resp) {
+			dev_err(&res->pdev->dev,
+				"QPLIB: SP: DELETE_GID send failed");
+			return -EINVAL;
+		}
+		if (!bnxt_qplib_rcfw_wait_for_resp(rcfw,
+						   le16_to_cpu(req.cookie))) {
+			/* Cmd timed out */
+			dev_err(&res->pdev->dev,
+				"QPLIB: SP: DELETE_GID timed out");
+			return -ETIMEDOUT;
+		}
+		if (RCFW_RESP_STATUS(resp) ||
+		    RCFW_RESP_COOKIE(resp) != RCFW_CMDQ_COOKIE(req)) {
+			dev_err(&res->pdev->dev,
+				"QPLIB: SP: DELETE_GID failed ");
+			dev_err(&res->pdev->dev,
+				"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+				RCFW_RESP_STATUS(resp), RCFW_CMDQ_COOKIE(req),
+				RCFW_RESP_COOKIE(resp));
+			return -EINVAL;
+		}
+	}
+	memcpy(&sgid_tbl->tbl[index], &bnxt_qplib_gid_zero,
+	       sizeof(bnxt_qplib_gid_zero));
+	sgid_tbl->active--;
+	dev_dbg(&res->pdev->dev,
+		"QPLIB: SGID deleted hw_id[0x%x] = 0x%x active = 0x%x",
+		 index, sgid_tbl->hw_id[index], sgid_tbl->active);
+	sgid_tbl->hw_id[index] = (u16)-1;
+
+	/* unlock */
+	return 0;
+}
+
+int bnxt_qplib_add_sgid(struct bnxt_qplib_sgid_tbl *sgid_tbl,
+			struct bnxt_qplib_gid *gid, u8 *smac, u16 vlan_id,
+			bool update, u32 *index)
+{
+	struct bnxt_qplib_res *res = to_bnxt_qplib(sgid_tbl,
+						   struct bnxt_qplib_res,
+						   sgid_tbl);
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	int i, free_idx, rc = 0;
+
+	if (!sgid_tbl) {
+		dev_err(&res->pdev->dev, "QPLIB: SGID table not allocated");
+		return -EINVAL;
+	}
+	/* Do we need a sgid_lock here? */
+	if (sgid_tbl->active == sgid_tbl->max) {
+		dev_err(&res->pdev->dev, "QPLIB: SGID table is full");
+		return -ENOMEM;
+	}
+	free_idx = sgid_tbl->max;
+	for (i = 0; i < sgid_tbl->max; i++) {
+		if (!memcmp(&sgid_tbl->tbl[i], gid, sizeof(*gid))) {
+			dev_dbg(&res->pdev->dev,
+				"QPLIB: SGID entry already exist in entry %d!",
+				i);
+			*index = i;
+			return -EALREADY;
+		} else if (!memcmp(&sgid_tbl->tbl[i], &bnxt_qplib_gid_zero,
+				   sizeof(bnxt_qplib_gid_zero)) &&
+			   free_idx == sgid_tbl->max) {
+			free_idx = i;
+		}
+	}
+	if (free_idx == sgid_tbl->max) {
+		dev_err(&res->pdev->dev,
+			"QPLIB: SGID table is FULL but count is not MAX??");
+		return -ENOMEM;
+	}
+	if (update) {
+		struct cmdq_add_gid req;
+		struct creq_add_gid_resp *resp;
+		u16 cmd_flags = 0;
+		u32 temp32[4];
+		u16 temp16[3];
+
+		RCFW_CMD_PREP(req, ADD_GID, cmd_flags);
+
+		memcpy(temp32, gid->data, sizeof(struct bnxt_qplib_gid));
+		req.gid[0] = cpu_to_be32(temp32[3]);
+		req.gid[1] = cpu_to_be32(temp32[2]);
+		req.gid[2] = cpu_to_be32(temp32[1]);
+		req.gid[3] = cpu_to_be32(temp32[0]);
+		if (vlan_id != 0xFFFF)
+			req.vlan = cpu_to_le32((vlan_id &
+					CMDQ_ADD_GID_VLAN_VLAN_ID_MASK) |
+					CMDQ_ADD_GID_VLAN_TPID_TPID_8100 |
+					CMDQ_ADD_GID_VLAN_VLAN_EN);
+
+		/* MAC in network format */
+		memcpy(temp16, smac, 6);
+		req.src_mac[0] = cpu_to_be16(temp16[0]);
+		req.src_mac[1] = cpu_to_be16(temp16[1]);
+		req.src_mac[2] = cpu_to_be16(temp16[2]);
+
+		resp = (struct creq_add_gid_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 0);
+		if (!resp) {
+			dev_err(&res->pdev->dev,
+				"QPLIB: SP: ADD_GID send failed");
+			return -EINVAL;
+		}
+		if (!bnxt_qplib_rcfw_wait_for_resp(rcfw,
+						   le16_to_cpu(req.cookie))) {
+			/* Cmd timed out */
+			dev_err(&res->pdev->dev,
+				"QPIB: SP: ADD_GID timed out");
+			return -ETIMEDOUT;
+		}
+		if (RCFW_RESP_STATUS(resp) ||
+		    RCFW_RESP_COOKIE(resp) != RCFW_CMDQ_COOKIE(req)) {
+			dev_err(&res->pdev->dev, "QPLIB: SP: ADD_GID failed ");
+			dev_err(&res->pdev->dev,
+				"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+				RCFW_RESP_STATUS(resp), RCFW_CMDQ_COOKIE(req),
+				RCFW_RESP_COOKIE(resp));
+			return -EINVAL;
+		}
+		sgid_tbl->hw_id[free_idx] = le32_to_cpu(resp->xid);
+	}
+	/* Add GID to the sgid_tbl */
+	memcpy(&sgid_tbl->tbl[free_idx], gid, sizeof(*gid));
+	sgid_tbl->active++;
+	dev_dbg(&res->pdev->dev,
+		"QPLIB: SGID added hw_id[0x%x] = 0x%x active = 0x%x",
+		 free_idx, sgid_tbl->hw_id[free_idx], sgid_tbl->active);
+
+	*index = free_idx;
+	/* unlock */
+	return rc;
+}
+
+/* pkeys */
+int bnxt_qplib_get_pkey(struct bnxt_qplib_res *res,
+			struct bnxt_qplib_pkey_tbl *pkey_tbl, u16 index,
+			u16 *pkey)
+{
+	if (index == 0xFFFF) {
+		*pkey = 0xFFFF;
+		return 0;
+	}
+	if (index > pkey_tbl->max) {
+		dev_err(&res->pdev->dev,
+			"QPLIB: Index %d exceeded PKEY table max (%d)",
+			index, pkey_tbl->max);
+		return -EINVAL;
+	}
+	memcpy(pkey, &pkey_tbl->tbl[index], sizeof(*pkey));
+	return 0;
+}
+
 int bnxt_qplib_del_pkey(struct bnxt_qplib_res *res,
 			struct bnxt_qplib_pkey_tbl *pkey_tbl, u16 *pkey,
 			bool update)
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
index 7de6600..8e20924 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.h
@@ -78,6 +78,17 @@ struct bnxt_qplib_gid {
 	u8				data[16];
 };
 
+int bnxt_qplib_get_sgid(struct bnxt_qplib_res *res,
+			struct bnxt_qplib_sgid_tbl *sgid_tbl, int index,
+			struct bnxt_qplib_gid *gid);
+int bnxt_qplib_del_sgid(struct bnxt_qplib_sgid_tbl *sgid_tbl,
+			struct bnxt_qplib_gid *gid, bool update);
+int bnxt_qplib_add_sgid(struct bnxt_qplib_sgid_tbl *sgid_tbl,
+			struct bnxt_qplib_gid *gid, u8 *mac, u16 vlan_id,
+			bool update, u32 *index);
+int bnxt_qplib_get_pkey(struct bnxt_qplib_res *res,
+			struct bnxt_qplib_pkey_tbl *pkey_tbl, u16 index,
+			u16 *pkey);
 int bnxt_qplib_del_pkey(struct bnxt_qplib_res *res,
 			struct bnxt_qplib_pkey_tbl *pkey_tbl, u16 *pkey,
 			bool update);
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
index c94573b..3417829 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
@@ -60,6 +60,22 @@
 #include "bnxt_re_ib_verbs.h"
 #include <rdma/bnxt_re_uverbs_abi.h>
 
+/* Device */
+struct net_device *bnxt_re_get_netdev(struct ib_device *ibdev, u8 port_num)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
+	struct net_device *netdev = NULL;
+
+	rcu_read_lock();
+	if (rdev)
+		netdev = rdev->netdev;
+	if (netdev)
+		dev_hold(netdev);
+
+	rcu_read_unlock();
+	return netdev;
+}
+
 int bnxt_re_query_device(struct ib_device *ibdev,
 			 struct ib_device_attr *ib_attr,
 			 struct ib_udata *udata)
@@ -272,6 +288,113 @@ int bnxt_re_get_port_immutable(struct ib_device *ibdev, u8 port_num,
 	immutable->max_mad_size = IB_MGMT_MAD_SIZE;
 	return 0;
 }
+
+int bnxt_re_query_pkey(struct ib_device *ibdev, u8 port_num,
+		       u16 index, u16 *pkey)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
+
+	/* Ignore port_num */
+
+	memset(pkey, 0, sizeof(*pkey));
+	return bnxt_qplib_get_pkey(&rdev->qplib_res,
+				   &rdev->qplib_res.pkey_tbl, index, pkey);
+}
+
+int bnxt_re_query_gid(struct ib_device *ibdev, u8 port_num,
+		      int index, union ib_gid *gid)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
+	int rc = 0;
+
+	/* Ignore port_num */
+	memset(gid, 0, sizeof(*gid));
+	rc = bnxt_qplib_get_sgid(&rdev->qplib_res,
+				 &rdev->qplib_res.sgid_tbl, index,
+				 (struct bnxt_qplib_gid *)gid);
+	return rc;
+}
+
+int bnxt_re_del_gid(struct ib_device *ibdev, u8 port_num,
+		    unsigned int index, void **context)
+{
+	int rc = 0;
+	struct bnxt_re_gid_ctx *ctx, **ctx_tbl;
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
+	struct bnxt_qplib_sgid_tbl *sgid_tbl = &rdev->qplib_res.sgid_tbl;
+
+	/* Delete the entry from the hardware */
+	ctx = *context;
+	if (!ctx)
+		return -EINVAL;
+
+	if (sgid_tbl && sgid_tbl->active) {
+		if (ctx->idx >= sgid_tbl->max)
+			return -EINVAL;
+		ctx->refcnt--;
+		if (!ctx->refcnt) {
+			rc = bnxt_qplib_del_sgid
+					(sgid_tbl,
+					 &sgid_tbl->tbl[ctx->idx], true);
+			if (rc)
+				dev_err(rdev_to_dev(rdev),
+					"Failed to remove GID: %#x", rc);
+			ctx_tbl = sgid_tbl->ctx;
+			ctx_tbl[ctx->idx] = NULL;
+			kfree(ctx);
+		}
+	} else {
+		return -EINVAL;
+	}
+	return rc;
+}
+
+int bnxt_re_add_gid(struct ib_device *ibdev, u8 port_num,
+		    unsigned int index, const union ib_gid *gid,
+		    const struct ib_gid_attr *attr, void **context)
+{
+	int rc;
+	u32 tbl_idx = 0;
+	u16 vlan_id = 0xFFFF;
+	struct bnxt_re_gid_ctx *ctx, **ctx_tbl;
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
+	struct bnxt_qplib_sgid_tbl *sgid_tbl = &rdev->qplib_res.sgid_tbl;
+
+	if ((attr->ndev) && is_vlan_dev(attr->ndev))
+		vlan_id = vlan_dev_vlan_id(attr->ndev);
+
+	rc = bnxt_qplib_add_sgid(sgid_tbl, (struct bnxt_qplib_gid *)gid,
+				 rdev->qplib_res.netdev->dev_addr,
+				 vlan_id, true, &tbl_idx);
+	if (rc == -EALREADY) {
+		ctx_tbl = sgid_tbl->ctx;
+		ctx_tbl[tbl_idx]->refcnt++;
+		*context = ctx_tbl[tbl_idx];
+		return 0;
+	}
+
+	if (rc < 0) {
+		dev_err(rdev_to_dev(rdev), "Failed to add GID: %#x", rc);
+		return rc;
+	}
+
+	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
+	if (!ctx)
+		return -ENOMEM;
+	ctx_tbl = sgid_tbl->ctx;
+	ctx->idx = tbl_idx;
+	ctx->refcnt = 1;
+	ctx_tbl[tbl_idx] = ctx;
+
+	return rc;
+}
+
+enum rdma_link_layer bnxt_re_get_link_layer(struct ib_device *ibdev,
+					    u8 port_num)
+{
+	return IB_LINK_LAYER_ETHERNET;
+}
+
 /* Protection Domains */
 int bnxt_re_dealloc_pd(struct ib_pd *ib_pd)
 {
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
index 255a0ad..c10fd63 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
@@ -39,6 +39,11 @@
 #ifndef __BNXT_RE_IB_VERBS_H__
 #define __BNXT_RE_IB_VERBS_H__
 
+struct bnxt_re_gid_ctx {
+	u32			idx;
+	u32			refcnt;
+};
+
 struct bnxt_re_pd {
 	struct bnxt_re_dev	*rdev;
 	struct ib_pd		ib_pd;
@@ -54,6 +59,8 @@ struct bnxt_re_ucontext {
 	spinlock_t		sh_lock;	/* protect shpg */
 };
 
+struct net_device *bnxt_re_get_netdev(struct ib_device *ibdev, u8 port_num);
+
 int bnxt_re_query_device(struct ib_device *ibdev,
 			 struct ib_device_attr *ib_attr,
 			 struct ib_udata *udata);
@@ -67,6 +74,17 @@ int bnxt_re_modify_port(struct ib_device *ibdev, u8 port_num,
 			struct ib_port_modify *port_modify);
 int bnxt_re_get_port_immutable(struct ib_device *ibdev, u8 port_num,
 			       struct ib_port_immutable *immutable);
+int bnxt_re_query_pkey(struct ib_device *ibdev, u8 port_num,
+		       u16 index, u16 *pkey);
+int bnxt_re_del_gid(struct ib_device *ibdev, u8 port_num,
+		    unsigned int index, void **context);
+int bnxt_re_add_gid(struct ib_device *ibdev, u8 port_num,
+		    unsigned int index, const union ib_gid *gid,
+		    const struct ib_gid_attr *attr, void **context);
+int bnxt_re_query_gid(struct ib_device *ibdev, u8 port_num,
+		      int index, union ib_gid *gid);
+enum rdma_link_layer bnxt_re_get_link_layer(struct ib_device *ibdev,
+					    u8 port_num);
 struct ib_pd *bnxt_re_alloc_pd(struct ib_device *ibdev,
 			       struct ib_ucontext *context,
 			       struct ib_udata *udata);
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
index b1b5ccee..313798f 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -431,6 +431,13 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 	ibdev->query_port		= bnxt_re_query_port;
 	ibdev->modify_port		= bnxt_re_modify_port;
 	ibdev->get_port_immutable	= bnxt_re_get_port_immutable;
+	ibdev->query_pkey		= bnxt_re_query_pkey;
+	ibdev->query_gid		= bnxt_re_query_gid;
+	ibdev->get_netdev		= bnxt_re_get_netdev;
+	ibdev->add_gid			= bnxt_re_add_gid;
+	ibdev->del_gid			= bnxt_re_del_gid;
+	ibdev->get_link_layer		= bnxt_re_get_link_layer;
+
 	ibdev->alloc_pd			= bnxt_re_alloc_pd;
 	ibdev->dealloc_pd		= bnxt_re_dealloc_pd;
 	ibdev->alloc_ucontext		= bnxt_re_alloc_ucontext;
-- 
2.5.5
