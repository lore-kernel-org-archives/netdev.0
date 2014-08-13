From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 01/10] IB/core: Add support for extended query device caps
Date: Wed, 13 Aug 2014 14:39:02 +0300
Message-ID: <1407929951-16362-2-git-send-email-eli@mellanox.com>
References: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, rdma@vger.kernel.org, amirv@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:41450 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbaHMLje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 07:39:34 -0400
Received: by mail-wi0-f173.google.com with SMTP id f8so7261931wiw.0
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 04:39:32 -0700 (PDT)
In-Reply-To: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add extensible query device capabilities verb to allow adding new features.
ib_uverbs_ex_query_device is added and copy_query_dev_fields is used to copy
capability fields to be used by both ib_uverbs_query_device and
ib_uverbs_ex_query_device.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/core/uverbs.h      |   1 +
 drivers/infiniband/core/uverbs_cmd.c  | 129 +++++++++++++++++++++++-----------
 drivers/infiniband/core/uverbs_main.c |   3 +-
 include/rdma/ib_verbs.h               |   3 +
 include/uapi/rdma/ib_user_verbs.h     |  54 +++++++++++++-
 5 files changed, 147 insertions(+), 43 deletions(-)

diff --git a/drivers/infiniband/core/uverbs.h b/drivers/infiniband/core/uverbs.h
index a283274a5a09..db0cf8ff808a 100644
--- a/drivers/infiniband/core/uverbs.h
+++ b/drivers/infiniband/core/uverbs.h
@@ -257,5 +257,6 @@ IB_UVERBS_DECLARE_CMD(close_xrcd);
 
 IB_UVERBS_DECLARE_EX_CMD(create_flow);
 IB_UVERBS_DECLARE_EX_CMD(destroy_flow);
+IB_UVERBS_DECLARE_EX_CMD(query_device);
 
 #endif /* UVERBS_H */
diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
index ea6203ee7bcc..87059fd93649 100644
--- a/drivers/infiniband/core/uverbs_cmd.c
+++ b/drivers/infiniband/core/uverbs_cmd.c
@@ -378,6 +378,52 @@ err:
 	return ret;
 }
 
+static void copy_query_dev_fields(struct ib_uverbs_file *file,
+				  struct ib_uverbs_query_device_resp *resp,
+				  struct ib_device_attr *attr)
+{
+	resp->fw_ver		= attr->fw_ver;
+	resp->node_guid		= file->device->ib_dev->node_guid;
+	resp->sys_image_guid	= attr->sys_image_guid;
+	resp->max_mr_size	= attr->max_mr_size;
+	resp->page_size_cap	= attr->page_size_cap;
+	resp->vendor_id		= attr->vendor_id;
+	resp->vendor_part_id	= attr->vendor_part_id;
+	resp->hw_ver		= attr->hw_ver;
+	resp->max_qp		= attr->max_qp;
+	resp->max_qp_wr		= attr->max_qp_wr;
+	resp->device_cap_flags	= attr->device_cap_flags;
+	resp->max_sge		= attr->max_sge;
+	resp->max_sge_rd	= attr->max_sge_rd;
+	resp->max_cq		= attr->max_cq;
+	resp->max_cqe		= attr->max_cqe;
+	resp->max_mr		= attr->max_mr;
+	resp->max_pd		= attr->max_pd;
+	resp->max_qp_rd_atom	= attr->max_qp_rd_atom;
+	resp->max_ee_rd_atom	= attr->max_ee_rd_atom;
+	resp->max_res_rd_atom	= attr->max_res_rd_atom;
+	resp->max_qp_init_rd_atom	= attr->max_qp_init_rd_atom;
+	resp->max_ee_init_rd_atom	= attr->max_ee_init_rd_atom;
+	resp->atomic_cap		= attr->atomic_cap;
+	resp->max_ee			= attr->max_ee;
+	resp->max_rdd			= attr->max_rdd;
+	resp->max_mw			= attr->max_mw;
+	resp->max_raw_ipv6_qp		= attr->max_raw_ipv6_qp;
+	resp->max_raw_ethy_qp		= attr->max_raw_ethy_qp;
+	resp->max_mcast_grp		= attr->max_mcast_grp;
+	resp->max_mcast_qp_attach	= attr->max_mcast_qp_attach;
+	resp->max_total_mcast_qp_attach	= attr->max_total_mcast_qp_attach;
+	resp->max_ah			= attr->max_ah;
+	resp->max_fmr			= attr->max_fmr;
+	resp->max_map_per_fmr		= attr->max_map_per_fmr;
+	resp->max_srq			= attr->max_srq;
+	resp->max_srq_wr		= attr->max_srq_wr;
+	resp->max_srq_sge		= attr->max_srq_sge;
+	resp->max_pkeys			= attr->max_pkeys;
+	resp->local_ca_ack_delay	= attr->local_ca_ack_delay;
+	resp->phys_port_cnt		= file->device->ib_dev->phys_port_cnt;
+}
+
 ssize_t ib_uverbs_query_device(struct ib_uverbs_file *file,
 			       const char __user *buf,
 			       int in_len, int out_len)
@@ -398,47 +444,7 @@ ssize_t ib_uverbs_query_device(struct ib_uverbs_file *file,
 		return ret;
 
 	memset(&resp, 0, sizeof resp);
-
-	resp.fw_ver 		       = attr.fw_ver;
-	resp.node_guid 		       = file->device->ib_dev->node_guid;
-	resp.sys_image_guid 	       = attr.sys_image_guid;
-	resp.max_mr_size 	       = attr.max_mr_size;
-	resp.page_size_cap 	       = attr.page_size_cap;
-	resp.vendor_id 		       = attr.vendor_id;
-	resp.vendor_part_id 	       = attr.vendor_part_id;
-	resp.hw_ver 		       = attr.hw_ver;
-	resp.max_qp 		       = attr.max_qp;
-	resp.max_qp_wr 		       = attr.max_qp_wr;
-	resp.device_cap_flags 	       = attr.device_cap_flags;
-	resp.max_sge 		       = attr.max_sge;
-	resp.max_sge_rd 	       = attr.max_sge_rd;
-	resp.max_cq 		       = attr.max_cq;
-	resp.max_cqe 		       = attr.max_cqe;
-	resp.max_mr 		       = attr.max_mr;
-	resp.max_pd 		       = attr.max_pd;
-	resp.max_qp_rd_atom 	       = attr.max_qp_rd_atom;
-	resp.max_ee_rd_atom 	       = attr.max_ee_rd_atom;
-	resp.max_res_rd_atom 	       = attr.max_res_rd_atom;
-	resp.max_qp_init_rd_atom       = attr.max_qp_init_rd_atom;
-	resp.max_ee_init_rd_atom       = attr.max_ee_init_rd_atom;
-	resp.atomic_cap 	       = attr.atomic_cap;
-	resp.max_ee 		       = attr.max_ee;
-	resp.max_rdd 		       = attr.max_rdd;
-	resp.max_mw 		       = attr.max_mw;
-	resp.max_raw_ipv6_qp 	       = attr.max_raw_ipv6_qp;
-	resp.max_raw_ethy_qp 	       = attr.max_raw_ethy_qp;
-	resp.max_mcast_grp 	       = attr.max_mcast_grp;
-	resp.max_mcast_qp_attach       = attr.max_mcast_qp_attach;
-	resp.max_total_mcast_qp_attach = attr.max_total_mcast_qp_attach;
-	resp.max_ah 		       = attr.max_ah;
-	resp.max_fmr 		       = attr.max_fmr;
-	resp.max_map_per_fmr 	       = attr.max_map_per_fmr;
-	resp.max_srq 		       = attr.max_srq;
-	resp.max_srq_wr 	       = attr.max_srq_wr;
-	resp.max_srq_sge 	       = attr.max_srq_sge;
-	resp.max_pkeys 		       = attr.max_pkeys;
-	resp.local_ca_ack_delay        = attr.local_ca_ack_delay;
-	resp.phys_port_cnt	       = file->device->ib_dev->phys_port_cnt;
+	copy_query_dev_fields(file, &resp, &attr);
 
 	if (copy_to_user((void __user *) (unsigned long) cmd.response,
 			 &resp, sizeof resp))
@@ -3158,3 +3164,44 @@ ssize_t ib_uverbs_destroy_srq(struct ib_uverbs_file *file,
 
 	return ret ? ret : in_len;
 }
+
+int ib_uverbs_ex_query_device(struct ib_uverbs_file *file,
+			      struct ib_udata *ucore,
+			      struct ib_udata *uhw)
+{
+	struct ib_uverbs_ex_query_device_resp resp;
+	struct ib_uverbs_ex_query_device  cmd;
+	struct ib_device_attr attr;
+	struct ib_device *device;
+	int err;
+
+	device = file->device->ib_dev;
+	if (ucore->inlen < sizeof(cmd))
+		return -EINVAL;
+
+	if (ucore->outlen < sizeof(resp))
+		return -ENOSPC;
+
+	err = ib_copy_from_udata(&cmd, ucore, sizeof(cmd));
+	if (err)
+		return err;
+
+	if (cmd.comp_mask)
+		return -EINVAL;
+
+	err = device->ex_query_device(device, &attr, uhw);
+	if (err)
+		return err;
+
+	memset(&resp, 0, sizeof(resp));
+	copy_query_dev_fields(file,
+			      (struct ib_uverbs_query_device_resp *)(&resp),
+			      (struct ib_device_attr *)&attr);
+	resp.comp_mask = 0;
+
+	err = ib_copy_to_udata(ucore, &resp, sizeof(resp));
+	if (err)
+		return err;
+
+	return 0;
+}
diff --git a/drivers/infiniband/core/uverbs_main.c b/drivers/infiniband/core/uverbs_main.c
index 08219fb3338b..1280e78f199d 100644
--- a/drivers/infiniband/core/uverbs_main.c
+++ b/drivers/infiniband/core/uverbs_main.c
@@ -121,7 +121,8 @@ static int (*uverbs_ex_cmd_table[])(struct ib_uverbs_file *file,
 				    struct ib_udata *ucore,
 				    struct ib_udata *uhw) = {
 	[IB_USER_VERBS_EX_CMD_CREATE_FLOW]	= ib_uverbs_ex_create_flow,
-	[IB_USER_VERBS_EX_CMD_DESTROY_FLOW]	= ib_uverbs_ex_destroy_flow
+	[IB_USER_VERBS_EX_CMD_DESTROY_FLOW]	= ib_uverbs_ex_destroy_flow,
+	[IB_USER_VERBS_EX_CMD_QUERY_DEVICE]	= ib_uverbs_ex_query_device
 };
 
 static void ib_uverbs_add_one(struct ib_device *device);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 7ccef342f724..ab6560fb1c9a 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1603,6 +1603,9 @@ struct ib_device {
 	int			   (*destroy_flow)(struct ib_flow *flow_id);
 	int			   (*check_mr_status)(struct ib_mr *mr, u32 check_mask,
 						      struct ib_mr_status *mr_status);
+	int		           (*ex_query_device)(struct ib_device *device,
+						      struct ib_device_attr *device_attr,
+						      struct ib_udata *uhw);
 
 	struct ib_dma_mapping_ops   *dma_ops;
 
diff --git a/include/uapi/rdma/ib_user_verbs.h b/include/uapi/rdma/ib_user_verbs.h
index cbfdd4ca9510..e005b17b84c7 100644
--- a/include/uapi/rdma/ib_user_verbs.h
+++ b/include/uapi/rdma/ib_user_verbs.h
@@ -90,8 +90,9 @@ enum {
 };
 
 enum {
+	IB_USER_VERBS_EX_CMD_QUERY_DEVICE = IB_USER_VERBS_CMD_QUERY_DEVICE,
 	IB_USER_VERBS_EX_CMD_CREATE_FLOW = IB_USER_VERBS_CMD_THRESHOLD,
-	IB_USER_VERBS_EX_CMD_DESTROY_FLOW
+	IB_USER_VERBS_EX_CMD_DESTROY_FLOW,
 };
 
 /*
@@ -201,6 +202,57 @@ struct ib_uverbs_query_device_resp {
 	__u8  reserved[4];
 };
 
+struct ib_uverbs_ex_query_device {
+	__u64 driver_data[0];
+	__u32 comp_mask;
+	__u8  reserved[4];
+};
+
+struct ib_uverbs_ex_query_device_resp {
+	__u64 fw_ver;
+	__be64 node_guid;
+	__be64 sys_image_guid;
+	__u64 max_mr_size;
+	__u64 page_size_cap;
+	__u32 vendor_id;
+	__u32 vendor_part_id;
+	__u32 hw_ver;
+	__u32 max_qp;
+	__u32 max_qp_wr;
+	__u32 device_cap_flags;
+	__u32 max_sge;
+	__u32 max_sge_rd;
+	__u32 max_cq;
+	__u32 max_cqe;
+	__u32 max_mr;
+	__u32 max_pd;
+	__u32 max_qp_rd_atom;
+	__u32 max_ee_rd_atom;
+	__u32 max_res_rd_atom;
+	__u32 max_qp_init_rd_atom;
+	__u32 max_ee_init_rd_atom;
+	__u32 atomic_cap;
+	__u32 max_ee;
+	__u32 max_rdd;
+	__u32 max_mw;
+	__u32 max_raw_ipv6_qp;
+	__u32 max_raw_ethy_qp;
+	__u32 max_mcast_grp;
+	__u32 max_mcast_qp_attach;
+	__u32 max_total_mcast_qp_attach;
+	__u32 max_ah;
+	__u32 max_fmr;
+	__u32 max_map_per_fmr;
+	__u32 max_srq;
+	__u32 max_srq_wr;
+	__u32 max_srq_sge;
+	__u16 max_pkeys;
+	__u8  local_ca_ack_delay;
+	__u8  phys_port_cnt;
+	__u8  reserved[4];
+	__u32 comp_mask;
+};
+
 struct ib_uverbs_query_port {
 	__u64 response;
 	__u8  port_num;
-- 
1.9.3
