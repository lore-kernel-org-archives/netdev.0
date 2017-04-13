From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [PATCH rdma-next v2 04/12] IB/opa-vnic: Virtual Network Interface Controller (VNIC) netdev
Date: Wed, 12 Apr 2017 20:29:22 -0700
Message-ID: <1492054170-23577-5-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1492054170-23577-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com, ira.weiny@intel.com,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>,
        Sadanand Warrier <sadanand.warrier@intel.com>,
        Sudeep Dutt <sudeep.dutt@intel.com>,
        Andrzej Kacprowski <andrzej.kacprowski@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28888 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756055AbdDMD3l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 23:29:41 -0400
In-Reply-To: <1492054170-23577-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OPA VNIC netdev function supports Ethernet functionality over Omni-Path
fabric by encapsulating Ethernet packets inside Omni-Path packet header.
It allocates a rdma netdev device and interfaces with the network stack to
provide standard Ethernet network interfaces. It overrides HFI1 device's
netdev operations where it is required.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
Signed-off-by: Sadanand Warrier <sadanand.warrier@intel.com>
Signed-off-by: Sudeep Dutt <sudeep.dutt@intel.com>
Signed-off-by: Andrzej Kacprowski <andrzej.kacprowski@intel.com>
---
 MAINTAINERS                                        |   7 +
 drivers/infiniband/Kconfig                         |   1 +
 drivers/infiniband/ulp/Makefile                    |   1 +
 drivers/infiniband/ulp/opa_vnic/Kconfig            |   8 +
 drivers/infiniband/ulp/opa_vnic/Makefile           |   6 +
 drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c   | 239 +++++++++++++++++++++
 drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h   |  62 ++++++
 drivers/infiniband/ulp/opa_vnic/opa_vnic_ethtool.c |  65 ++++++
 .../infiniband/ulp/opa_vnic/opa_vnic_internal.h    | 186 ++++++++++++++++
 drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c  | 227 +++++++++++++++++++
 10 files changed, 802 insertions(+)
 create mode 100644 drivers/infiniband/ulp/opa_vnic/Kconfig
 create mode 100644 drivers/infiniband/ulp/opa_vnic/Makefile
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_ethtool.c
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c

diff --git a/MAINTAINERS b/MAINTAINERS
index c776906..fc32256 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5843,6 +5843,13 @@ F:	drivers/block/cciss*
 F:	include/linux/cciss_ioctl.h
 F:	include/uapi/linux/cciss_ioctl.h
 
+OPA-VNIC DRIVER
+M:	Dennis Dalessandro <dennis.dalessandro@intel.com>
+M:	Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
+L:	linux-rdma@vger.kernel.org
+S:	Supported
+F:	drivers/infiniband/ulp/opa_vnic
+
 HFI1 DRIVER
 M:	Mike Marciniszyn <mike.marciniszyn@intel.com>
 M:	Dennis Dalessandro <dennis.dalessandro@intel.com>
diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index 66f8602..234fe01 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -85,6 +85,7 @@ source "drivers/infiniband/ulp/srpt/Kconfig"
 source "drivers/infiniband/ulp/iser/Kconfig"
 source "drivers/infiniband/ulp/isert/Kconfig"
 
+source "drivers/infiniband/ulp/opa_vnic/Kconfig"
 source "drivers/infiniband/sw/rdmavt/Kconfig"
 source "drivers/infiniband/sw/rxe/Kconfig"
 
diff --git a/drivers/infiniband/ulp/Makefile b/drivers/infiniband/ulp/Makefile
index f3c7dcf..c28af18 100644
--- a/drivers/infiniband/ulp/Makefile
+++ b/drivers/infiniband/ulp/Makefile
@@ -3,3 +3,4 @@ obj-$(CONFIG_INFINIBAND_SRP)		+= srp/
 obj-$(CONFIG_INFINIBAND_SRPT)		+= srpt/
 obj-$(CONFIG_INFINIBAND_ISER)		+= iser/
 obj-$(CONFIG_INFINIBAND_ISERT)		+= isert/
+obj-$(CONFIG_INFINIBAND_OPA_VNIC)	+= opa_vnic/
diff --git a/drivers/infiniband/ulp/opa_vnic/Kconfig b/drivers/infiniband/ulp/opa_vnic/Kconfig
new file mode 100644
index 0000000..48132ab
--- /dev/null
+++ b/drivers/infiniband/ulp/opa_vnic/Kconfig
@@ -0,0 +1,8 @@
+config INFINIBAND_OPA_VNIC
+	tristate "Intel OPA VNIC support"
+	depends on X86_64 && INFINIBAND
+	---help---
+	This is Omni-Path (OPA) Virtual Network Interface Controller (VNIC)
+	driver for Ethernet over Omni-Path feature. It implements the HW
+	independent VNIC functionality. It interfaces with Linux stack for
+	data path and IB MAD for the control path.
diff --git a/drivers/infiniband/ulp/opa_vnic/Makefile b/drivers/infiniband/ulp/opa_vnic/Makefile
new file mode 100644
index 0000000..975c313
--- /dev/null
+++ b/drivers/infiniband/ulp/opa_vnic/Makefile
@@ -0,0 +1,6 @@
+# Makefile - Intel Omni-Path Virtual Network Controller driver
+# Copyright(c) 2017, Intel Corporation.
+#
+obj-$(CONFIG_INFINIBAND_OPA_VNIC) += opa_vnic.o
+
+opa_vnic-y := opa_vnic_netdev.o opa_vnic_encap.o opa_vnic_ethtool.o
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c b/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c
new file mode 100644
index 0000000..c74d02a
--- /dev/null
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c
@@ -0,0 +1,239 @@
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
+ * This file contains OPA VNIC encapsulation/decapsulation function.
+ */
+
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+
+#include "opa_vnic_internal.h"
+
+/* OPA 16B Header fields */
+#define OPA_16B_LID_MASK        0xFFFFFull
+#define OPA_16B_SLID_HIGH_SHFT  8
+#define OPA_16B_SLID_MASK       0xF00ull
+#define OPA_16B_DLID_MASK       0xF000ull
+#define OPA_16B_DLID_HIGH_SHFT  12
+#define OPA_16B_LEN_SHFT        20
+#define OPA_16B_SC_SHFT         20
+#define OPA_16B_RC_SHFT         25
+#define OPA_16B_PKEY_SHFT       16
+
+#define OPA_VNIC_L4_HDR_SHFT    16
+
+/* L2+L4 hdr len is 20 bytes (5 quad words) */
+#define OPA_VNIC_HDR_QW_LEN   5
+
+static inline void opa_vnic_make_header(u8 *hdr, u32 slid, u32 dlid, u16 len,
+					u16 pkey, u16 entropy, u8 sc, u8 rc,
+					u8 l4_type, u16 l4_hdr)
+{
+	/* h[1]: LT=1, 16B L2=10 */
+	u32 h[OPA_VNIC_HDR_QW_LEN] = {0, 0xc0000000, 0, 0, 0};
+
+	h[2] = l4_type;
+	h[3] = entropy;
+	h[4] = l4_hdr << OPA_VNIC_L4_HDR_SHFT;
+
+	/* Extract and set 4 upper bits and 20 lower bits of the lids */
+	h[0] |= (slid & OPA_16B_LID_MASK);
+	h[2] |= ((slid >> (20 - OPA_16B_SLID_HIGH_SHFT)) & OPA_16B_SLID_MASK);
+
+	h[1] |= (dlid & OPA_16B_LID_MASK);
+	h[2] |= ((dlid >> (20 - OPA_16B_DLID_HIGH_SHFT)) & OPA_16B_DLID_MASK);
+
+	h[0] |= (len << OPA_16B_LEN_SHFT);
+	h[1] |= (rc << OPA_16B_RC_SHFT);
+	h[1] |= (sc << OPA_16B_SC_SHFT);
+	h[2] |= ((u32)pkey << OPA_16B_PKEY_SHFT);
+
+	memcpy(hdr, h, OPA_VNIC_HDR_LEN);
+}
+
+/* opa_vnic_get_dlid - find and return the DLID */
+static uint32_t opa_vnic_get_dlid(struct opa_vnic_adapter *adapter,
+				  struct sk_buff *skb, u8 def_port)
+{
+	struct __opa_veswport_info *info = &adapter->info;
+	struct ethhdr *mac_hdr = (struct ethhdr *)skb_mac_header(skb);
+	u32 dlid;
+
+	if (is_multicast_ether_addr(mac_hdr->h_dest)) {
+		dlid = info->vesw.u_mcast_dlid;
+	} else {
+		if (is_local_ether_addr(mac_hdr->h_dest)) {
+			dlid = ((uint32_t)mac_hdr->h_dest[5] << 16) |
+				((uint32_t)mac_hdr->h_dest[4] << 8)  |
+				mac_hdr->h_dest[3];
+			if (unlikely(!dlid))
+				v_warn("Null dlid in MAC address\n");
+		} else if (def_port != OPA_VNIC_INVALID_PORT) {
+			dlid = info->vesw.u_ucast_dlid[def_port];
+		}
+	}
+
+	return dlid;
+}
+
+/* opa_vnic_get_sc - return the service class */
+static u8 opa_vnic_get_sc(struct __opa_veswport_info *info,
+			  struct sk_buff *skb)
+{
+	struct ethhdr *mac_hdr = (struct ethhdr *)skb_mac_header(skb);
+	u16 vlan_tci;
+	u8 sc;
+
+	if (!__vlan_get_tag(skb, &vlan_tci)) {
+		u8 pcp = OPA_VNIC_VLAN_PCP(vlan_tci);
+
+		if (is_multicast_ether_addr(mac_hdr->h_dest))
+			sc = info->vport.pcp_to_sc_mc[pcp];
+		else
+			sc = info->vport.pcp_to_sc_uc[pcp];
+	} else {
+		if (is_multicast_ether_addr(mac_hdr->h_dest))
+			sc = info->vport.non_vlan_sc_mc;
+		else
+			sc = info->vport.non_vlan_sc_uc;
+	}
+
+	return sc;
+}
+
+u8 opa_vnic_get_vl(struct opa_vnic_adapter *adapter, struct sk_buff *skb)
+{
+	struct ethhdr *mac_hdr = (struct ethhdr *)skb_mac_header(skb);
+	struct __opa_veswport_info *info = &adapter->info;
+	u8 vl;
+
+	if (skb_vlan_tag_present(skb)) {
+		u8 pcp = skb_vlan_tag_get(skb) >> VLAN_PRIO_SHIFT;
+
+		if (is_multicast_ether_addr(mac_hdr->h_dest))
+			vl = info->vport.pcp_to_vl_mc[pcp];
+		else
+			vl = info->vport.pcp_to_vl_uc[pcp];
+	} else {
+		if (is_multicast_ether_addr(mac_hdr->h_dest))
+			vl = info->vport.non_vlan_vl_mc;
+		else
+			vl = info->vport.non_vlan_vl_uc;
+	}
+
+	return vl;
+}
+
+/* opa_vnic_calc_entropy - calculate the packet entropy */
+u8 opa_vnic_calc_entropy(struct opa_vnic_adapter *adapter, struct sk_buff *skb)
+{
+	u16 hash16;
+
+	/*
+	 * Get flow based 16-bit hash and then XOR the upper and lower bytes
+	 * to get the entropy.
+	 * __skb_tx_hash limits qcount to 16 bits. Hence, get 15-bit hash.
+	 */
+	hash16 = __skb_tx_hash(adapter->netdev, skb, BIT(15));
+	return (u8)((hash16 >> 8) ^ (hash16 & 0xff));
+}
+
+/* opa_vnic_get_def_port - get default port based on entropy */
+static inline u8 opa_vnic_get_def_port(struct opa_vnic_adapter *adapter,
+				       u8 entropy)
+{
+	u8 flow_id;
+
+	/* Add the upper and lower 4-bits of entropy to get the flow id */
+	flow_id = ((entropy & 0xf) + (entropy >> 4));
+	return adapter->flow_tbl[flow_id & (OPA_VNIC_FLOW_TBL_SIZE - 1)];
+}
+
+/* Calculate packet length including OPA header, crc and padding */
+static inline int opa_vnic_wire_length(struct sk_buff *skb)
+{
+	u32 pad_len;
+
+	/* padding for 8 bytes size alignment */
+	pad_len = -(skb->len + OPA_VNIC_ICRC_TAIL_LEN) & 0x7;
+	pad_len += OPA_VNIC_ICRC_TAIL_LEN;
+
+	return (skb->len + pad_len) >> 3;
+}
+
+/* opa_vnic_encap_skb - encapsulate skb packet with OPA header and meta data */
+void opa_vnic_encap_skb(struct opa_vnic_adapter *adapter, struct sk_buff *skb)
+{
+	struct __opa_veswport_info *info = &adapter->info;
+	struct opa_vnic_skb_mdata *mdata;
+	u8 def_port, sc, entropy, *hdr;
+	u16 len, l4_hdr;
+	u32 dlid;
+
+	hdr = skb_push(skb, OPA_VNIC_HDR_LEN);
+
+	entropy = opa_vnic_calc_entropy(adapter, skb);
+	def_port = opa_vnic_get_def_port(adapter, entropy);
+	len = opa_vnic_wire_length(skb);
+	dlid = opa_vnic_get_dlid(adapter, skb, def_port);
+	sc = opa_vnic_get_sc(info, skb);
+	l4_hdr = info->vesw.vesw_id;
+
+	mdata = (struct opa_vnic_skb_mdata *)skb_push(skb, sizeof(*mdata));
+	mdata->vl = opa_vnic_get_vl(adapter, skb);
+	mdata->entropy = entropy;
+	mdata->flags = 0;
+	if (unlikely(!dlid)) {
+		mdata->flags = OPA_VNIC_SKB_MDATA_ENCAP_ERR;
+		return;
+	}
+
+	opa_vnic_make_header(hdr, info->vport.encap_slid, dlid, len,
+			     info->vesw.pkey, entropy, sc, 0,
+			     OPA_VNIC_L4_ETHR, l4_hdr);
+}
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h b/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h
new file mode 100644
index 0000000..176fca9
--- /dev/null
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h
@@ -0,0 +1,62 @@
+#ifndef _OPA_VNIC_ENCAP_H
+#define _OPA_VNIC_ENCAP_H
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
+ * This file contains all OPA VNIC declaration required for encapsulation
+ * and decapsulation of Ethernet packets
+ */
+
+/* VNIC configured and operational state values */
+#define OPA_VNIC_STATE_DROP_ALL        0x1
+#define OPA_VNIC_STATE_FORWARDING      0x3
+
+#define OPA_VESW_MAX_NUM_DEF_PORT   16
+#define OPA_VNIC_MAX_NUM_PCP        8
+
+#endif /* _OPA_VNIC_ENCAP_H */
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_ethtool.c b/drivers/infiniband/ulp/opa_vnic/opa_vnic_ethtool.c
new file mode 100644
index 0000000..b74f6ad
--- /dev/null
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_ethtool.c
@@ -0,0 +1,65 @@
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
+ * This file contains OPA VNIC ethtool functions
+ */
+
+#include <linux/ethtool.h>
+
+#include "opa_vnic_internal.h"
+
+/* ethtool ops */
+static const struct ethtool_ops opa_vnic_ethtool_ops = {
+	.get_link = ethtool_op_get_link,
+};
+
+/* opa_vnic_set_ethtool_ops - set ethtool ops */
+void opa_vnic_set_ethtool_ops(struct net_device *netdev)
+{
+	netdev->ethtool_ops = &opa_vnic_ethtool_ops;
+}
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h b/drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h
new file mode 100644
index 0000000..83ffa91
--- /dev/null
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h
@@ -0,0 +1,186 @@
+#ifndef _OPA_VNIC_INTERNAL_H
+#define _OPA_VNIC_INTERNAL_H
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
+ * This file contains OPA VNIC driver internal declarations
+ */
+
+#include <linux/bitops.h>
+#include <linux/etherdevice.h>
+#include <linux/hashtable.h>
+#include <linux/sizes.h>
+#include <rdma/opa_vnic.h>
+
+#include "opa_vnic_encap.h"
+
+#define OPA_VNIC_VLAN_PCP(vlan_tci)  \
+			(((vlan_tci) & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT)
+
+/* Flow to default port redirection table size */
+#define OPA_VNIC_FLOW_TBL_SIZE    32
+
+/* Invalid port number */
+#define OPA_VNIC_INVALID_PORT     0xff
+
+struct opa_vnic_adapter;
+
+/**
+ * struct __opa_vesw_info - OPA vnic virtual switch info
+ */
+struct __opa_vesw_info {
+	u16  fabric_id;
+	u16  vesw_id;
+
+	u8   rsvd0[6];
+	u16  def_port_mask;
+
+	u8   rsvd1[2];
+	u16  pkey;
+
+	u8   rsvd2[4];
+	u32  u_mcast_dlid;
+	u32  u_ucast_dlid[OPA_VESW_MAX_NUM_DEF_PORT];
+
+	u8   rsvd3[44];
+	u16  eth_mtu[OPA_VNIC_MAX_NUM_PCP];
+	u16  eth_mtu_non_vlan;
+	u8   rsvd4[2];
+} __packed;
+
+/**
+ * struct __opa_per_veswport_info - OPA vnic per port info
+ */
+struct __opa_per_veswport_info {
+	u32  port_num;
+
+	u8   eth_link_status;
+	u8   rsvd0[3];
+
+	u8   base_mac_addr[ETH_ALEN];
+	u8   config_state;
+	u8   oper_state;
+
+	u16  max_mac_tbl_ent;
+	u16  max_smac_ent;
+	u32  mac_tbl_digest;
+	u8   rsvd1[4];
+
+	u32  encap_slid;
+
+	u8   pcp_to_sc_uc[OPA_VNIC_MAX_NUM_PCP];
+	u8   pcp_to_vl_uc[OPA_VNIC_MAX_NUM_PCP];
+	u8   pcp_to_sc_mc[OPA_VNIC_MAX_NUM_PCP];
+	u8   pcp_to_vl_mc[OPA_VNIC_MAX_NUM_PCP];
+
+	u8   non_vlan_sc_uc;
+	u8   non_vlan_vl_uc;
+	u8   non_vlan_sc_mc;
+	u8   non_vlan_vl_mc;
+
+	u8   rsvd2[48];
+
+	u16  uc_macs_gen_count;
+	u16  mc_macs_gen_count;
+
+	u8   rsvd3[8];
+} __packed;
+
+/**
+ * struct __opa_veswport_info - OPA vnic port info
+ */
+struct __opa_veswport_info {
+	struct __opa_vesw_info            vesw;
+	struct __opa_per_veswport_info    vport;
+};
+
+/**
+ * struct opa_vnic_adapter - OPA VNIC netdev private data structure
+ * @netdev: pointer to associated netdev
+ * @ibdev: ib device
+ * @rn_ops: rdma netdev's net_device_ops
+ * @port_num: OPA port number
+ * @vport_num: vesw port number
+ * @lock: adapter lock
+ * @info: virtual ethernet switch port information
+ * @flow_tbl: flow to default port redirection table
+ */
+struct opa_vnic_adapter {
+	struct net_device             *netdev;
+	struct ib_device              *ibdev;
+	const struct net_device_ops   *rn_ops;
+
+	u8 port_num;
+	u8 vport_num;
+
+	/* Lock used around concurrent updates to netdev */
+	struct mutex lock;
+
+	struct __opa_veswport_info  info;
+
+	u8 flow_tbl[OPA_VNIC_FLOW_TBL_SIZE];
+};
+
+#define v_dbg(format, arg...) \
+	netdev_dbg(adapter->netdev, format, ## arg)
+#define v_err(format, arg...) \
+	netdev_err(adapter->netdev, format, ## arg)
+#define v_info(format, arg...) \
+	netdev_info(adapter->netdev, format, ## arg)
+#define v_warn(format, arg...) \
+	netdev_warn(adapter->netdev, format, ## arg)
+
+struct opa_vnic_adapter *opa_vnic_add_netdev(struct ib_device *ibdev,
+					     u8 port_num, u8 vport_num);
+void opa_vnic_rem_netdev(struct opa_vnic_adapter *adapter);
+void opa_vnic_encap_skb(struct opa_vnic_adapter *adapter, struct sk_buff *skb);
+u8 opa_vnic_get_vl(struct opa_vnic_adapter *adapter, struct sk_buff *skb);
+u8 opa_vnic_calc_entropy(struct opa_vnic_adapter *adapter, struct sk_buff *skb);
+void opa_vnic_set_ethtool_ops(struct net_device *netdev);
+
+#endif /* _OPA_VNIC_INTERNAL_H */
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c b/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
new file mode 100644
index 0000000..1e237b6
--- /dev/null
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
@@ -0,0 +1,227 @@
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
+ * This file contains OPA Virtual Network Interface Controller (VNIC) driver
+ * netdev functionality.
+ */
+
+#include <linux/module.h>
+#include <linux/if_vlan.h>
+
+#include "opa_vnic_internal.h"
+
+#define OPA_TX_TIMEOUT_MS 1000
+
+#define OPA_VNIC_SKB_HEADROOM  \
+			ALIGN((OPA_VNIC_HDR_LEN + OPA_VNIC_SKB_MDATA_LEN), 8)
+
+/* opa_netdev_start_xmit - transmit function */
+static netdev_tx_t opa_netdev_start_xmit(struct sk_buff *skb,
+					 struct net_device *netdev)
+{
+	struct opa_vnic_adapter *adapter = opa_vnic_priv(netdev);
+
+	v_dbg("xmit: queue %d skb len %d\n", skb->queue_mapping, skb->len);
+	/* pad to ensure mininum ethernet packet length */
+	if (unlikely(skb->len < ETH_ZLEN)) {
+		if (skb_padto(skb, ETH_ZLEN))
+			return NETDEV_TX_OK;
+
+		skb_put(skb, ETH_ZLEN - skb->len);
+	}
+
+	opa_vnic_encap_skb(adapter, skb);
+	return adapter->rn_ops->ndo_start_xmit(skb, netdev);
+}
+
+static u16 opa_vnic_select_queue(struct net_device *netdev, struct sk_buff *skb,
+				 void *accel_priv,
+				 select_queue_fallback_t fallback)
+{
+	struct opa_vnic_adapter *adapter = opa_vnic_priv(netdev);
+	struct opa_vnic_skb_mdata *mdata;
+	int rc;
+
+	/* pass entropy and vl as metadata in skb */
+	mdata = (struct opa_vnic_skb_mdata *)skb_push(skb, sizeof(*mdata));
+	mdata->entropy =  opa_vnic_calc_entropy(adapter, skb);
+	mdata->vl = opa_vnic_get_vl(adapter, skb);
+	rc = adapter->rn_ops->ndo_select_queue(netdev, skb,
+					       accel_priv, fallback);
+	skb_pull(skb, sizeof(*mdata));
+	return rc;
+}
+
+/* opa_vnic_set_mac_addr - change mac address */
+static int opa_vnic_set_mac_addr(struct net_device *netdev, void *addr)
+{
+	struct opa_vnic_adapter *adapter = opa_vnic_priv(netdev);
+	struct sockaddr *sa = addr;
+	int rc;
+
+	if (!memcmp(netdev->dev_addr, sa->sa_data, ETH_ALEN))
+		return 0;
+
+	mutex_lock(&adapter->lock);
+	rc = eth_mac_addr(netdev, addr);
+	mutex_unlock(&adapter->lock);
+
+	return rc;
+}
+
+/* opa_netdev_open - activate network interface */
+static int opa_netdev_open(struct net_device *netdev)
+{
+	struct opa_vnic_adapter *adapter = opa_vnic_priv(netdev);
+	int rc;
+
+	rc = adapter->rn_ops->ndo_open(adapter->netdev);
+	if (rc) {
+		v_dbg("open failed %d\n", rc);
+		return rc;
+	}
+
+	return 0;
+}
+
+/* opa_netdev_close - disable network interface */
+static int opa_netdev_close(struct net_device *netdev)
+{
+	struct opa_vnic_adapter *adapter = opa_vnic_priv(netdev);
+	int rc;
+
+	rc = adapter->rn_ops->ndo_stop(adapter->netdev);
+	if (rc) {
+		v_dbg("close failed %d\n", rc);
+		return rc;
+	}
+
+	return 0;
+}
+
+/* netdev ops */
+static const struct net_device_ops opa_netdev_ops = {
+	.ndo_open = opa_netdev_open,
+	.ndo_stop = opa_netdev_close,
+	.ndo_start_xmit = opa_netdev_start_xmit,
+	.ndo_select_queue = opa_vnic_select_queue,
+	.ndo_set_mac_address = opa_vnic_set_mac_addr,
+};
+
+/* opa_vnic_add_netdev - create vnic netdev interface */
+struct opa_vnic_adapter *opa_vnic_add_netdev(struct ib_device *ibdev,
+					     u8 port_num, u8 vport_num)
+{
+	struct opa_vnic_adapter *adapter;
+	struct net_device *netdev;
+	struct rdma_netdev *rn;
+	int rc;
+
+	netdev = ibdev->alloc_rdma_netdev(ibdev, port_num,
+					  RDMA_NETDEV_OPA_VNIC,
+					  "veth%d", NET_NAME_UNKNOWN,
+					  ether_setup);
+	if (!netdev)
+		return ERR_PTR(-ENOMEM);
+	else if (IS_ERR(netdev))
+		return ERR_CAST(netdev);
+
+	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
+	if (!adapter) {
+		rc = -ENOMEM;
+		goto adapter_err;
+	}
+
+	rn = netdev_priv(netdev);
+	rn->clnt_priv = adapter;
+	rn->hca = ibdev;
+	rn->port_num = port_num;
+	adapter->netdev = netdev;
+	adapter->ibdev = ibdev;
+	adapter->port_num = port_num;
+	adapter->vport_num = vport_num;
+	adapter->rn_ops = netdev->netdev_ops;
+
+	netdev->netdev_ops = &opa_netdev_ops;
+	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	netdev->hard_header_len += OPA_VNIC_SKB_HEADROOM;
+	mutex_init(&adapter->lock);
+
+	SET_NETDEV_DEV(netdev, ibdev->dev.parent);
+
+	opa_vnic_set_ethtool_ops(netdev);
+	rc = register_netdev(netdev);
+	if (rc)
+		goto netdev_err;
+
+	netif_carrier_off(netdev);
+	netif_dormant_on(netdev);
+	v_info("initialized\n");
+
+	return adapter;
+netdev_err:
+	mutex_destroy(&adapter->lock);
+	kfree(adapter);
+adapter_err:
+	ibdev->free_rdma_netdev(netdev);
+
+	return ERR_PTR(rc);
+}
+
+/* opa_vnic_rem_netdev - remove vnic netdev interface */
+void opa_vnic_rem_netdev(struct opa_vnic_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct ib_device *ibdev = adapter->ibdev;
+
+	v_info("removing\n");
+	unregister_netdev(netdev);
+	mutex_destroy(&adapter->lock);
+	kfree(adapter);
+	ibdev->free_rdma_netdev(netdev);
+}
-- 
1.8.3.1
