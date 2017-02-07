From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC v3 02/11] IB/hfi-vnic: Virtual Network Interface Controller (VNIC) interface
Date: Tue,  7 Feb 2017 12:23:01 -0800
Message-ID: <1486498990-76562-3-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add rdma netdev interface to ib device structure allowing rdma netdev
devices to be allocated by ib clients.
Define HFI VNIC interface between hardware independent VNIC
functionality and the hardware dependent VNIC functionality.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Reviewed-by: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/rdma/ib_verbs.h |  27 +++++++++
 include/rdma/opa_hfi.h  | 147 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 174 insertions(+)
 create mode 100644 include/rdma/opa_hfi.h

diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index b1ac973..b9897d9d 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -55,6 +55,7 @@
 #include <net/ip.h>
 #include <linux/string.h>
 #include <linux/slab.h>
+#include <linux/netdevice.h>
 
 #include <linux/if_link.h>
 #include <linux/atomic.h>
@@ -221,6 +222,7 @@ enum ib_device_cap_flags {
 	IB_DEVICE_SG_GAPS_REG			= (1ULL << 32),
 	IB_DEVICE_VIRTUAL_FUNCTION		= (1ULL << 33),
 	IB_DEVICE_RAW_SCATTER_FCS		= (1ULL << 34),
+	IB_DEVICE_RDMA_NETDEV_HFI_VNIC		= (1ULL << 35),
 };
 
 enum ib_signature_prot_cap {
@@ -1844,6 +1846,22 @@ struct ib_port_immutable {
 	u32                           max_mad_size;
 };
 
+/* rdma netdev type - specifies protocol type */
+enum rdma_netdev_t {
+	RDMA_NETDEV_HFI_VNIC
+};
+
+/**
+ * struct rdma_netdev - rdma netdev
+ * For cases where netstack interfacing is required.
+ */
+struct rdma_netdev {
+	void *clnt_priv;
+
+	/* control functions */
+	void (*set_id)(struct net_device *netdev, int id);
+};
+
 struct ib_device {
 	struct device                *dma_device;
 
@@ -2096,6 +2114,15 @@ struct ib_device {
 							   struct ib_rwq_ind_table_init_attr *init_attr,
 							   struct ib_udata *udata);
 	int                        (*destroy_rwq_ind_table)(struct ib_rwq_ind_table *wq_ind_table);
+	/* rdma netdev operations */
+	struct net_device *(*alloc_rdma_netdev)(
+					struct ib_device *device,
+					u8 port_num,
+					enum rdma_netdev_t type,
+					const char *name,
+					unsigned char name_assign_type,
+					void (*setup)(struct net_device *));
+	void (*free_rdma_netdev)(struct net_device *netdev);
 	struct ib_dma_mapping_ops   *dma_ops;
 
 	struct module               *owner;
diff --git a/include/rdma/opa_hfi.h b/include/rdma/opa_hfi.h
new file mode 100644
index 0000000..f357d04
--- /dev/null
+++ b/include/rdma/opa_hfi.h
@@ -0,0 +1,147 @@
+#ifndef _OPA_HFI_H
+#define _OPA_HFI_H
+/*
+ * Copyright(c) 2017 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+/*
+ * This file contains Intel Omni-Path (OPA) Host Fabric Interface (HFI)
+ * specific declarations.
+ */
+
+#include <rdma/ib_verbs.h>
+
+#define HFI_MAX_NUM_VNICS  255
+
+/* VNIC uses 16B header format */
+#define HFI_VNIC_L2_TYPE    0x2
+
+/* 16 header bytes + 2 reserved bytes */
+#define HFI_VNIC_L2_HDR_LEN   (16 + 2)
+
+#define HFI_VNIC_L4_HDR_LEN   2
+
+#define HFI_VNIC_HDR_LEN      (HFI_VNIC_L2_HDR_LEN + \
+			       HFI_VNIC_L4_HDR_LEN)
+
+#define HFI_VNIC_L4_ETHR  0x78
+
+#define HFI_VNIC_ICRC_LEN   4
+#define HFI_VNIC_TAIL_LEN   1
+#define HFI_VNIC_ICRC_TAIL_LEN  (HFI_VNIC_ICRC_LEN + HFI_VNIC_TAIL_LEN)
+
+/* VNIC configured and operational state values */
+#define HFI_VNIC_STATE_DROP_ALL        0x1
+#define HFI_VNIC_STATE_FORWARDING      0x3
+
+#define HFI_VNIC_SKB_MDATA_LEN         4
+#define HFI_VNIC_SKB_MDATA_ENCAP_ERR   0x1
+
+/* hfi vnic rdma netdev's private data structure */
+struct hfi_vnic_rdma_netdev {
+	struct rdma_netdev rn;  /* keep this first */
+	/* followed by device private data */
+	char *dev_priv[0];
+};
+
+static inline void *hfi_vnic_priv(const struct net_device *dev)
+{
+	struct rdma_netdev *rn = netdev_priv(dev);
+
+	return rn->clnt_priv;
+}
+
+static inline void *hfi_vnic_dev_priv(const struct net_device *dev)
+{
+	struct rdma_netdev *rn = netdev_priv(dev);
+
+	return rn + 1;
+}
+
+/* hfi_vnic skb meta data structrue */
+struct hfi_vnic_skb_mdata {
+	u8 vl;
+	u8 entropy;
+	u8 flags;
+	u8 rsvd;
+} __packed;
+
+/* HFI VNIC group statistics */
+struct hfi_vnic_grp_stats {
+	u64 unicast;
+	u64 mcastbcast;
+	u64 untagged;
+	u64 vlan;
+	u64 s_64;
+	u64 s_65_127;
+	u64 s_128_255;
+	u64 s_256_511;
+	u64 s_512_1023;
+	u64 s_1024_1518;
+	u64 s_1519_max;
+};
+
+struct hfi_vnic_stats {
+	/* standard netdev statistics */
+	struct rtnl_link_stats64 netstats;
+
+	/* HFI VNIC statistics */
+	struct hfi_vnic_grp_stats tx_grp;
+	struct hfi_vnic_grp_stats rx_grp;
+	u64 tx_dlid_zero;
+	u64 tx_drop_state;
+	u64 rx_drop_state;
+	u64 rx_runt;
+	u64 rx_oversize;
+};
+
+static inline bool rdma_cap_hfi_vnic(struct ib_device *device)
+{
+	return !!(device->attrs.device_cap_flags &
+		  IB_DEVICE_RDMA_NETDEV_HFI_VNIC);
+}
+
+#endif /* _OPA_HFI_H */
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
