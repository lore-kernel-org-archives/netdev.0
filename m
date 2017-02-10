From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH V5 for-next 11/21] RDMA/bnxt_re: Support for AH verbs
Date: Fri, 10 Feb 2017 03:19:43 -0800
Message-ID: <1486725593-9872-12-git-send-email-selvin.xavier@broadcom.com>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:36190 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752096AbdBJLao (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 06:30:44 -0500
Received: by mail-qt0-f180.google.com with SMTP id k15so31539238qtg.3
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 03:30:11 -0800 (PST)
In-Reply-To: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements support for create_ah, destroy_ah, query_ah
and modify_ah verbs.

v3: Removes unwanted macros and does cleanup listed by checkpatch
v5: Adds ib_udata parameter to create_ah verb

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxt_re/ib_verbs.c | 148 +++++++++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/ib_verbs.h |  12 +++
 drivers/infiniband/hw/bnxt_re/main.c     |   4 +
 drivers/infiniband/hw/bnxt_re/qplib_sp.c |  94 ++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/qplib_sp.h |  18 ++++
 include/uapi/rdma/bnxt_re-abi.h          |   7 ++
 6 files changed, 283 insertions(+)

diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.c b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
index f85d4c4..18580e7 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.c
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
@@ -492,6 +492,154 @@ struct ib_pd *bnxt_re_alloc_pd(struct ib_device *ibdev,
 	return ERR_PTR(rc);
 }
 
+/* Address Handles */
+int bnxt_re_destroy_ah(struct ib_ah *ib_ah)
+{
+	struct bnxt_re_ah *ah = container_of(ib_ah, struct bnxt_re_ah, ib_ah);
+	struct bnxt_re_dev *rdev = ah->rdev;
+	int rc;
+
+	rc = bnxt_qplib_destroy_ah(&rdev->qplib_res, &ah->qplib_ah);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev), "Failed to destroy HW AH");
+		return rc;
+	}
+	kfree(ah);
+	return 0;
+}
+
+struct ib_ah *bnxt_re_create_ah(struct ib_pd *ib_pd,
+				struct ib_ah_attr *ah_attr,
+				struct ib_udata *udata)
+{
+	struct bnxt_re_pd *pd = container_of(ib_pd, struct bnxt_re_pd, ib_pd);
+	struct bnxt_re_dev *rdev = pd->rdev;
+	struct bnxt_re_ah *ah;
+	int rc;
+	u16 vlan_tag;
+	u8 nw_type;
+
+	struct ib_gid_attr sgid_attr;
+
+	if (!(ah_attr->ah_flags & IB_AH_GRH)) {
+		dev_err(rdev_to_dev(rdev), "Failed to alloc AH: GRH not set");
+		return ERR_PTR(-EINVAL);
+	}
+	ah = kzalloc(sizeof(*ah), GFP_ATOMIC);
+	if (!ah)
+		return ERR_PTR(-ENOMEM);
+
+	ah->rdev = rdev;
+	ah->qplib_ah.pd = &pd->qplib_pd;
+
+	/* Supply the configuration for the HW */
+	memcpy(ah->qplib_ah.dgid.data, ah_attr->grh.dgid.raw,
+	       sizeof(union ib_gid));
+	/*
+	 * If RoCE V2 is enabled, stack will have two entries for
+	 * each GID entry. Avoiding this duplicte entry in HW. Dividing
+	 * the GID index by 2 for RoCE V2
+	 */
+	ah->qplib_ah.sgid_index = ah_attr->grh.sgid_index / 2;
+	ah->qplib_ah.host_sgid_index = ah_attr->grh.sgid_index;
+	ah->qplib_ah.traffic_class = ah_attr->grh.traffic_class;
+	ah->qplib_ah.flow_label = ah_attr->grh.flow_label;
+	ah->qplib_ah.hop_limit = ah_attr->grh.hop_limit;
+	ah->qplib_ah.sl = ah_attr->sl;
+	if (ib_pd->uobject &&
+	    !rdma_is_multicast_addr((struct in6_addr *)
+				    ah_attr->grh.dgid.raw) &&
+	    !rdma_link_local_addr((struct in6_addr *)
+				  ah_attr->grh.dgid.raw)) {
+		union ib_gid sgid;
+
+		rc = ib_get_cached_gid(&rdev->ibdev, 1,
+				       ah_attr->grh.sgid_index, &sgid,
+				       &sgid_attr);
+		if (rc) {
+			dev_err(rdev_to_dev(rdev),
+				"Failed to query gid at index %d",
+				ah_attr->grh.sgid_index);
+			goto fail;
+		}
+		if (sgid_attr.ndev) {
+			if (is_vlan_dev(sgid_attr.ndev))
+				vlan_tag = vlan_dev_vlan_id(sgid_attr.ndev);
+			dev_put(sgid_attr.ndev);
+		}
+		/* Get network header type for this GID */
+		nw_type = ib_gid_to_network_type(sgid_attr.gid_type, &sgid);
+		switch (nw_type) {
+		case RDMA_NETWORK_IPV4:
+			ah->qplib_ah.nw_type = CMDQ_CREATE_AH_TYPE_V2IPV4;
+			break;
+		case RDMA_NETWORK_IPV6:
+			ah->qplib_ah.nw_type = CMDQ_CREATE_AH_TYPE_V2IPV6;
+			break;
+		default:
+			ah->qplib_ah.nw_type = CMDQ_CREATE_AH_TYPE_V1;
+			break;
+		}
+		rc = rdma_addr_find_l2_eth_by_grh(&sgid, &ah_attr->grh.dgid,
+						  ah_attr->dmac, &vlan_tag,
+						  &sgid_attr.ndev->ifindex,
+						  NULL);
+		if (rc) {
+			dev_err(rdev_to_dev(rdev), "Failed to get dmac\n");
+			goto fail;
+		}
+	}
+
+	memcpy(ah->qplib_ah.dmac, ah_attr->dmac, ETH_ALEN);
+	rc = bnxt_qplib_create_ah(&rdev->qplib_res, &ah->qplib_ah);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev), "Failed to allocate HW AH");
+		goto fail;
+	}
+
+	/* Write AVID to shared page. */
+	if (ib_pd->uobject) {
+		struct ib_ucontext *ib_uctx = ib_pd->uobject->context;
+		struct bnxt_re_ucontext *uctx;
+		unsigned long flag;
+		u32 *wrptr;
+
+		uctx = container_of(ib_uctx, struct bnxt_re_ucontext, ib_uctx);
+		spin_lock_irqsave(&uctx->sh_lock, flag);
+		wrptr = (u32 *)(uctx->shpg + BNXT_RE_AVID_OFFT);
+		*wrptr = ah->qplib_ah.id;
+		wmb(); /* make sure cache is updated. */
+		spin_unlock_irqrestore(&uctx->sh_lock, flag);
+	}
+
+	return &ah->ib_ah;
+
+fail:
+	kfree(ah);
+	return ERR_PTR(rc);
+}
+
+int bnxt_re_modify_ah(struct ib_ah *ib_ah, struct ib_ah_attr *ah_attr)
+{
+	return 0;
+}
+
+int bnxt_re_query_ah(struct ib_ah *ib_ah, struct ib_ah_attr *ah_attr)
+{
+	struct bnxt_re_ah *ah = container_of(ib_ah, struct bnxt_re_ah, ib_ah);
+
+	memcpy(ah_attr->grh.dgid.raw, ah->qplib_ah.dgid.data,
+	       sizeof(union ib_gid));
+	ah_attr->grh.sgid_index = ah->qplib_ah.host_sgid_index;
+	ah_attr->grh.traffic_class = ah->qplib_ah.traffic_class;
+	ah_attr->sl = ah->qplib_ah.sl;
+	memcpy(ah_attr->dmac, ah->qplib_ah.dmac, ETH_ALEN);
+	ah_attr->ah_flags = IB_AH_GRH;
+	ah_attr->port_num = 1;
+	ah_attr->static_rate = 0;
+	return 0;
+}
+
 /* Completion Queues */
 int bnxt_re_destroy_cq(struct ib_cq *ib_cq)
 {
diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.h b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
index 735be6d..1dcca49 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.h
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
@@ -51,6 +51,12 @@ struct bnxt_re_pd {
 	struct bnxt_qplib_dpi	dpi;
 };
 
+struct bnxt_re_ah {
+	struct bnxt_re_dev	*rdev;
+	struct ib_ah		ib_ah;
+	struct bnxt_qplib_ah	qplib_ah;
+};
+
 struct bnxt_re_cq {
 	struct bnxt_re_dev	*rdev;
 	spinlock_t              cq_lock;	/* protect cq */
@@ -102,6 +108,12 @@ struct ib_pd *bnxt_re_alloc_pd(struct ib_device *ibdev,
 			       struct ib_ucontext *context,
 			       struct ib_udata *udata);
 int bnxt_re_dealloc_pd(struct ib_pd *pd);
+struct ib_ah *bnxt_re_create_ah(struct ib_pd *pd,
+				struct ib_ah_attr *ah_attr,
+				struct ib_udata *udata);
+int bnxt_re_modify_ah(struct ib_ah *ah, struct ib_ah_attr *ah_attr);
+int bnxt_re_query_ah(struct ib_ah *ah, struct ib_ah_attr *ah_attr);
+int bnxt_re_destroy_ah(struct ib_ah *ah);
 struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
 				const struct ib_cq_init_attr *attr,
 				struct ib_ucontext *context,
diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index 2c5d192..bbaf35a 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -448,6 +448,10 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 	ibdev->alloc_pd			= bnxt_re_alloc_pd;
 	ibdev->dealloc_pd		= bnxt_re_dealloc_pd;
 
+	ibdev->create_ah		= bnxt_re_create_ah;
+	ibdev->modify_ah		= bnxt_re_modify_ah;
+	ibdev->query_ah			= bnxt_re_query_ah;
+	ibdev->destroy_ah		= bnxt_re_destroy_ah;
 	ibdev->create_cq		= bnxt_re_create_cq;
 	ibdev->destroy_cq		= bnxt_re_destroy_cq;
 	ibdev->req_notify_cq		= bnxt_re_req_notify_cq;
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_sp.c b/drivers/infiniband/hw/bnxt_re/qplib_sp.c
index ba16f6b..387168f 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_sp.c
+++ b/drivers/infiniband/hw/bnxt_re/qplib_sp.c
@@ -416,3 +416,97 @@ int bnxt_qplib_add_pkey(struct bnxt_qplib_res *res,
 	/* unlock */
 	return rc;
 }
+
+/* AH */
+int bnxt_qplib_create_ah(struct bnxt_qplib_res *res, struct bnxt_qplib_ah *ah)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_create_ah req;
+	struct creq_create_ah_resp *resp;
+	u16 cmd_flags = 0;
+	u32 temp32[4];
+	u16 temp16[3];
+
+	RCFW_CMD_PREP(req, CREATE_AH, cmd_flags);
+
+	memcpy(temp32, ah->dgid.data, sizeof(struct bnxt_qplib_gid));
+	req.dgid[0] = cpu_to_le32(temp32[0]);
+	req.dgid[1] = cpu_to_le32(temp32[1]);
+	req.dgid[2] = cpu_to_le32(temp32[2]);
+	req.dgid[3] = cpu_to_le32(temp32[3]);
+
+	req.type = ah->nw_type;
+	req.hop_limit = ah->hop_limit;
+	req.sgid_index = cpu_to_le16(res->sgid_tbl.hw_id[ah->sgid_index]);
+	req.dest_vlan_id_flow_label = cpu_to_le32((ah->flow_label &
+					CMDQ_CREATE_AH_FLOW_LABEL_MASK) |
+					CMDQ_CREATE_AH_DEST_VLAN_ID_MASK);
+	req.pd_id = cpu_to_le32(ah->pd->id);
+	req.traffic_class = ah->traffic_class;
+
+	/* MAC in network format */
+	memcpy(temp16, ah->dmac, 6);
+	req.dest_mac[0] = cpu_to_le16(temp16[0]);
+	req.dest_mac[1] = cpu_to_le16(temp16[1]);
+	req.dest_mac[2] = cpu_to_le16(temp16[2]);
+
+	resp = (struct creq_create_ah_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 1);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: CREATE_AH send failed");
+		return -EINVAL;
+	}
+	if (!bnxt_qplib_rcfw_block_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: CREATE_AH timed out");
+		return -ETIMEDOUT;
+	}
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: CREATE_AH failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		return -EINVAL;
+	}
+	ah->id = le32_to_cpu(resp->xid);
+	return 0;
+}
+
+int bnxt_qplib_destroy_ah(struct bnxt_qplib_res *res, struct bnxt_qplib_ah *ah)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_destroy_ah req;
+	struct creq_destroy_ah_resp *resp;
+	u16 cmd_flags = 0;
+
+	/* Clean up the AH table in the device */
+	RCFW_CMD_PREP(req, DESTROY_AH, cmd_flags);
+
+	req.ah_cid = cpu_to_le32(ah->id);
+
+	resp = (struct creq_destroy_ah_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 1);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: DESTROY_AH send failed");
+		return -EINVAL;
+	}
+	if (!bnxt_qplib_rcfw_block_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: DESTROY_AH timed out");
+		return -ETIMEDOUT;
+	}
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: DESTROY_AH failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		return -EINVAL;
+	}
+	return 0;
+}
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_sp.h b/drivers/infiniband/hw/bnxt_re/qplib_sp.h
index a3d4aab..1ef2578 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_sp.h
+++ b/drivers/infiniband/hw/bnxt_re/qplib_sp.h
@@ -78,6 +78,22 @@ struct bnxt_qplib_gid {
 	u8				data[16];
 };
 
+struct bnxt_qplib_ah {
+	struct bnxt_qplib_gid		dgid;
+	struct bnxt_qplib_pd		*pd;
+	u32				id;
+	u8				sgid_index;
+	/* For Query AH if the hw table and SW table are differnt */
+	u8				host_sgid_index;
+	u8				traffic_class;
+	u32				flow_label;
+	u8				hop_limit;
+	u8				sl;
+	u8				dmac[6];
+	u16				vlan_id;
+	u8				nw_type;
+};
+
 int bnxt_qplib_get_sgid(struct bnxt_qplib_res *res,
 			struct bnxt_qplib_sgid_tbl *sgid_tbl, int index,
 			struct bnxt_qplib_gid *gid);
@@ -97,4 +113,6 @@ int bnxt_qplib_add_pkey(struct bnxt_qplib_res *res,
 			bool update);
 int bnxt_qplib_get_dev_attr(struct bnxt_qplib_rcfw *rcfw,
 			    struct bnxt_qplib_dev_attr *attr);
+int bnxt_qplib_create_ah(struct bnxt_qplib_res *res, struct bnxt_qplib_ah *ah);
+int bnxt_qplib_destroy_ah(struct bnxt_qplib_res *res, struct bnxt_qplib_ah *ah);
 #endif /* __BNXT_QPLIB_SP_H__*/
diff --git a/include/uapi/rdma/bnxt_re-abi.h b/include/uapi/rdma/bnxt_re-abi.h
index ecded46..a4720cf 100644
--- a/include/uapi/rdma/bnxt_re-abi.h
+++ b/include/uapi/rdma/bnxt_re-abi.h
@@ -68,4 +68,11 @@ struct bnxt_re_cq_resp {
 	__u32 rsvd;
 };
 
+enum bnxt_re_shpg_offt {
+	BNXT_RE_BEG_RESV_OFFT	= 0x00,
+	BNXT_RE_AVID_OFFT	= 0x10,
+	BNXT_RE_AVID_SIZE	= 0x04,
+	BNXT_RE_END_RESV_OFFT	= 0xFF0
+};
+
 #endif /* __BNXT_RE_UVERBS_ABI_H__*/
-- 
2.5.5
