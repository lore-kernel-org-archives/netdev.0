From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v11 14/22] IB/hns: Add operations support for IB device and port
Date: Sat, 2 Jul 2016 17:39:16 +0800
Message-ID: <1467452364-66522-15-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch mainly registered some relative verbs for the kernel.
These operation functions will be called by user. For example:
    1. modify device
    2. query device
    3. query_port
    4. modify_port
and so on.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
PATCH v11:
Deletes the props->fw_ver according to the comments given by
Leon Romanovsky over the [PATCH v10 5/22]:
  Link: https://lkml.org/lkml/2016/6/24/419

PATCH v10/v9/v8/v7/v6:
- No change over the PATCH v5

PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_common.h |   4 +
 drivers/infiniband/hw/hns/hns_roce_device.h |  21 +++
 drivers/infiniband/hw/hns/hns_roce_main.c   | 227 ++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_user.h   |  40 +++++
 4 files changed, 292 insertions(+)
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_user.h

diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
index b66e96f..ee87689 100644
--- a/drivers/infiniband/hw/hns/hns_roce_common.h
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -33,6 +33,10 @@
 #ifndef _HNS_ROCE_COMMON_H
 #define _HNS_ROCE_COMMON_H
 
+#ifndef assert
+#define assert(cond)
+#endif
+
 #define roce_write(dev, reg, val)	writel((val), (dev)->reg_base + (reg))
 #define roce_read(dev, reg)		readl((dev)->reg_base + (reg))
 #define roce_raw_write(value, addr) \
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 0c835ad..f9288ff 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -38,6 +38,7 @@
 #define DRV_NAME "hns_roce"
 
 #define MAC_ADDR_OCTET_NUM			6
+#define HNS_ROCE_MAX_MSG_LEN			0x80000000
 
 #define HNS_ROCE_BA_SIZE			(32 * 4096)
 
@@ -50,6 +51,10 @@
 
 #define HNS_ROCE_MAX_PORTS			6
 #define HNS_ROCE_MAX_GID_NUM			16
+#define HNS_ROCE_GID_SIZE			16
+
+#define PKEY_ID					0xffff
+#define NODE_DESC_SIZE				64
 
 #define PAGES_SHIFT_16				16
 
@@ -116,6 +121,11 @@ struct hns_roce_uar {
 	unsigned long	index;
 };
 
+struct hns_roce_ucontext {
+	struct ib_ucontext	ibucontext;
+	struct hns_roce_uar	uar;
+};
+
 struct hns_roce_bitmap {
 	/* Bitmap Traversal last a bit which is 1 */
 	unsigned long		last;
@@ -366,6 +376,17 @@ struct hns_roce_dev {
 	struct hns_roce_hw	*hw;
 };
 
+static inline struct hns_roce_dev *to_hr_dev(struct ib_device *ib_dev)
+{
+	return container_of(ib_dev, struct hns_roce_dev, ib_dev);
+}
+
+static inline struct hns_roce_ucontext
+			*to_hr_ucontext(struct ib_ucontext *ibucontext)
+{
+	return container_of(ibucontext, struct hns_roce_ucontext, ibucontext);
+}
+
 static inline void hns_roce_write64_k(__be32 val[2], void __iomem *dest)
 {
 	__raw_writeq(*(u64 *) val, dest);
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 4348669..5dfab0b 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -37,6 +37,7 @@
 #include <rdma/ib_user_verbs.h>
 #include "hns_roce_common.h"
 #include "hns_roce_device.h"
+#include "hns_roce_user.h"
 #include "hns_roce_hem.h"
 
 /**
@@ -337,6 +338,216 @@ static int hns_roce_setup_mtu_gids(struct hns_roce_dev *hr_dev)
 	return ret;
 }
 
+static int hns_roce_query_device(struct ib_device *ib_dev,
+				 struct ib_device_attr *props,
+				 struct ib_udata *uhw)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+
+	memset(props, 0, sizeof(*props));
+
+	props->sys_image_guid = hr_dev->sys_image_guid;
+	props->max_mr_size = (u64)(~(0ULL));
+	props->page_size_cap = hr_dev->caps.page_size_cap;
+	props->vendor_id = hr_dev->vendor_id;
+	props->vendor_part_id = hr_dev->vendor_part_id;
+	props->hw_ver = hr_dev->hw_rev;
+	props->max_qp = hr_dev->caps.num_qps;
+	props->max_qp_wr = hr_dev->caps.max_wqes;
+	props->device_cap_flags = IB_DEVICE_PORT_ACTIVE_EVENT |
+				  IB_DEVICE_RC_RNR_NAK_GEN |
+				  IB_DEVICE_LOCAL_DMA_LKEY;
+	props->max_sge = hr_dev->caps.max_sq_sg;
+	props->max_sge_rd = 1;
+	props->max_cq = hr_dev->caps.num_cqs;
+	props->max_cqe = hr_dev->caps.max_cqes;
+	props->max_mr = hr_dev->caps.num_mtpts;
+	props->max_pd = hr_dev->caps.num_pds;
+	props->max_qp_rd_atom = hr_dev->caps.max_qp_dest_rdma;
+	props->max_qp_init_rd_atom = hr_dev->caps.max_qp_init_rdma;
+	props->atomic_cap = IB_ATOMIC_NONE;
+	props->max_pkeys = 1;
+	props->local_ca_ack_delay = hr_dev->caps.local_ca_ack_delay;
+
+	return 0;
+}
+
+static int hns_roce_query_port(struct ib_device *ib_dev, u8 port_num,
+			       struct ib_port_attr *props)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct net_device *net_dev;
+	unsigned long flags;
+	enum ib_mtu mtu;
+	u8 port;
+
+	assert(port_num > 0);
+	port = port_num - 1;
+
+	memset(props, 0, sizeof(*props));
+
+	props->max_mtu = hr_dev->caps.max_mtu;
+	props->gid_tbl_len = hr_dev->caps.gid_table_len[port];
+	props->port_cap_flags = IB_PORT_CM_SUP | IB_PORT_REINIT_SUP |
+				IB_PORT_VENDOR_CLASS_SUP |
+				IB_PORT_BOOT_MGMT_SUP;
+	props->max_msg_sz = HNS_ROCE_MAX_MSG_LEN;
+	props->pkey_tbl_len = 1;
+	props->active_width = IB_WIDTH_4X;
+	props->active_speed = 1;
+
+	spin_lock_irqsave(&hr_dev->iboe.lock, flags);
+
+	net_dev = hr_dev->iboe.netdevs[port];
+	if (!net_dev) {
+		spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+		dev_err(dev, "find netdev %d failed!\r\n", port);
+		return -EINVAL;
+	}
+
+	mtu = iboe_get_mtu(net_dev->mtu);
+	props->active_mtu = mtu ? min(props->max_mtu, mtu) : IB_MTU_256;
+	props->state = (netif_running(net_dev) && netif_carrier_ok(net_dev)) ?
+			IB_PORT_ACTIVE : IB_PORT_DOWN;
+	props->phys_state = (props->state == IB_PORT_ACTIVE) ? 5 : 3;
+
+	spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+
+	return 0;
+}
+
+static enum rdma_link_layer hns_roce_get_link_layer(struct ib_device *device,
+						    u8 port_num)
+{
+	return IB_LINK_LAYER_ETHERNET;
+}
+
+static int hns_roce_query_gid(struct ib_device *ib_dev, u8 port_num, int index,
+			      union ib_gid *gid)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+	struct device *dev = &hr_dev->pdev->dev;
+	u8 gid_idx = 0;
+	u8 port;
+
+	if (port_num < 1 || port_num > hr_dev->caps.num_ports ||
+	    index >= hr_dev->caps.gid_table_len[port_num - 1]) {
+		dev_err(dev,
+			"port_num %d index %d illegal! correct range: port_num 1~%d index 0~%d!\n",
+			port_num, index, hr_dev->caps.num_ports,
+			hr_dev->caps.gid_table_len[port_num - 1] - 1);
+		return -EINVAL;
+	}
+
+	port = port_num - 1;
+	gid_idx = hns_get_gid_index(hr_dev, port, index);
+	if (gid_idx >= HNS_ROCE_MAX_GID_NUM) {
+		dev_err(dev, "port_num %d index %d illegal! total gid num %d!\n",
+			port_num, index, HNS_ROCE_MAX_GID_NUM);
+		return -EINVAL;
+	}
+
+	memcpy(gid->raw, hr_dev->iboe.gid_table[gid_idx].raw,
+	       HNS_ROCE_GID_SIZE);
+
+	return 0;
+}
+
+static int hns_roce_query_pkey(struct ib_device *ib_dev, u8 port, u16 index,
+			       u16 *pkey)
+{
+	*pkey = PKEY_ID;
+
+	return 0;
+}
+
+static int hns_roce_modify_device(struct ib_device *ib_dev, int mask,
+				  struct ib_device_modify *props)
+{
+	unsigned long flags;
+
+	if (mask & ~IB_DEVICE_MODIFY_NODE_DESC)
+		return -EOPNOTSUPP;
+
+	if (mask & IB_DEVICE_MODIFY_NODE_DESC) {
+		spin_lock_irqsave(&to_hr_dev(ib_dev)->sm_lock, flags);
+		memcpy(ib_dev->node_desc, props->node_desc, NODE_DESC_SIZE);
+		spin_unlock_irqrestore(&to_hr_dev(ib_dev)->sm_lock, flags);
+	}
+
+	return 0;
+}
+
+static int hns_roce_modify_port(struct ib_device *ib_dev, u8 port_num, int mask,
+				struct ib_port_modify *props)
+{
+	return 0;
+}
+
+static struct ib_ucontext *hns_roce_alloc_ucontext(struct ib_device *ib_dev,
+						   struct ib_udata *udata)
+{
+	int ret = 0;
+	struct hns_roce_ucontext *context;
+	struct hns_roce_ib_alloc_ucontext_resp resp;
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+
+	resp.qp_tab_size = hr_dev->caps.num_qps;
+
+	context = kmalloc(sizeof(*context), GFP_KERNEL);
+	if (!context)
+		return ERR_PTR(-ENOMEM);
+
+	ret = hns_roce_uar_alloc(hr_dev, &context->uar);
+	if (ret)
+		goto error_fail_uar_alloc;
+
+	ret = ib_copy_to_udata(udata, &resp, sizeof(resp));
+	if (ret)
+		goto error_fail_copy_to_udata;
+
+	return &context->ibucontext;
+
+error_fail_copy_to_udata:
+	hns_roce_uar_free(hr_dev, &context->uar);
+
+error_fail_uar_alloc:
+	kfree(context);
+
+	return ERR_PTR(ret);
+}
+
+static int hns_roce_dealloc_ucontext(struct ib_ucontext *ibcontext)
+{
+	struct hns_roce_ucontext *context = to_hr_ucontext(ibcontext);
+
+	hns_roce_uar_free(to_hr_dev(ibcontext->device), &context->uar);
+	kfree(context);
+
+	return 0;
+}
+
+static int hns_roce_mmap(struct ib_ucontext *context,
+			 struct vm_area_struct *vma)
+{
+	if (((vma->vm_end - vma->vm_start) % PAGE_SIZE) != 0)
+		return -EINVAL;
+
+	if (vma->vm_pgoff == 0) {
+		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+		if (io_remap_pfn_range(vma, vma->vm_start,
+				       to_hr_ucontext(context)->uar.pfn,
+				       PAGE_SIZE, vma->vm_page_prot))
+			return -EAGAIN;
+
+	} else {
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static void hns_roce_unregister_device(struct hns_roce_dev *hr_dev)
 {
 	struct hns_roce_ib_iboe *iboe = &hr_dev->iboe;
@@ -366,6 +577,22 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 	ib_dev->local_dma_lkey		= hr_dev->caps.reserved_lkey;
 	ib_dev->num_comp_vectors	= hr_dev->caps.num_comp_vectors;
 	ib_dev->uverbs_abi_ver		= 1;
+	ib_dev->uverbs_cmd_mask		=
+		(1ULL << IB_USER_VERBS_CMD_GET_CONTEXT) |
+		(1ULL << IB_USER_VERBS_CMD_QUERY_DEVICE) |
+		(1ULL << IB_USER_VERBS_CMD_QUERY_PORT);
+
+	/* HCA||device||port */
+	ib_dev->modify_device		= hns_roce_modify_device;
+	ib_dev->query_device		= hns_roce_query_device;
+	ib_dev->query_port		= hns_roce_query_port;
+	ib_dev->modify_port		= hns_roce_modify_port;
+	ib_dev->get_link_layer		= hns_roce_get_link_layer;
+	ib_dev->query_gid		= hns_roce_query_gid;
+	ib_dev->query_pkey		= hns_roce_query_pkey;
+	ib_dev->alloc_ucontext		= hns_roce_alloc_ucontext;
+	ib_dev->dealloc_ucontext	= hns_roce_dealloc_ucontext;
+	ib_dev->mmap			= hns_roce_mmap;
 
 	ret = ib_register_device(ib_dev, NULL);
 	if (ret) {
diff --git a/drivers/infiniband/hw/hns/hns_roce_user.h b/drivers/infiniband/hw/hns/hns_roce_user.h
new file mode 100644
index 0000000..3b33ce4
--- /dev/null
+++ b/drivers/infiniband/hw/hns/hns_roce_user.h
@@ -0,0 +1,40 @@
+/*
+ * Copyright (c) 2016 Hisilicon Limited.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef _HNS_ROCE_USER_H
+#define _HNS_ROCE_USER_H
+
+struct hns_roce_ib_alloc_ucontext_resp {
+	__u32	qp_tab_size;
+};
+
+#endif /*_HNS_ROCE_USER_H */
-- 
1.9.1
