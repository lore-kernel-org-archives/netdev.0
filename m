From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC 07/10] IB/hfi-vnic: VNIC Ethernet Management Agent (VEMA) interface
Date: Fri, 18 Nov 2016 14:42:15 -0800
Message-ID: <1479508938-63799-8-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

HFI VNIC EMA interface functions are the management interfaces to the HFI
VNIC netdev driver. Implement the required GET/SET management interface
functions and processing of new management information. Add support to
send trap notifications upon various events like interface status change,
unicast/multicast mac list update and mac address change.

Change-Id: I18ccdc0a898ecd7ddcaca795f0a3d205c24b7e6b
Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile |   3 +-
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h        |   4 +
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h     |  24 ++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c       | 159 ++++++++-
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c   | 385 +++++++++++++++++++++
 5 files changed, 572 insertions(+), 3 deletions(-)
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c

diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile b/drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile
index a05b2f5..375cd09 100644
--- a/drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile
@@ -4,4 +4,5 @@
 ccflags-y += -I$(src)/../include
 obj-$(CONFIG_HFI_VNIC) += hfi_vnic.o
 
-hfi_vnic-y := hfi_vnic_netdev.o hfi_vnic_encap.o hfi_vnic_ethtool.o
+hfi_vnic-y := hfi_vnic_netdev.o hfi_vnic_encap.o hfi_vnic_ethtool.o \
+              hfi_vnic_vema_iface.o
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h
index 9ed5221..4e6f367 100644
--- a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h
@@ -99,6 +99,10 @@
 #define HFI_VNIC_STATE_DROP_ALL        0x1
 #define HFI_VNIC_STATE_FORWARDING      0x3
 
+/* VNIC Ethernet link status */
+#define HFI_VNIC_ETH_LINK_UP     1
+#define HFI_VNIC_ETH_LINK_DOWN   2
+
 /**
  * struct hfi_vesw_info - HFI vnic switch information
  * @fabric_id: 10-bit fabric id
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
index 21a43f6..8ebed89 100644
--- a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
@@ -261,6 +261,9 @@ struct hfi_vnic_rx_queue {
  * @lock: adapter lock
  * @rxq: receive queue array
  * @info: virtual ethernet switch port information
+ * @vema_mac_addr: mac address configured by vema
+ * @umac_hash: unicast maclist hash
+ * @mmac_hash: multicast maclist hash
  * @mactbl: hash table of MAC entries
  * @mactbl_lock: mac table lock
  * @stats_lock: statistics lock
@@ -286,6 +289,9 @@ struct hfi_vnic_adapter {
 	struct hfi_vnic_rx_queue  rxq[HFI_VNIC_MAX_QUEUE];
 
 	struct __hfi_veswport_info  info;
+	u8                          vema_mac_addr[ETH_ALEN];
+	u32                         umac_hash;
+	u32                         mmac_hash;
 	struct hlist_head  __rcu   *mactbl;
 
 	/* Lock used to protect updates to mac table */
@@ -378,12 +384,30 @@ struct hfi_vnic_mac_tbl_node {
 int hfi_vnic_encap_skb(struct hfi_vnic_adapter *adapter, struct sk_buff *skb);
 int hfi_vnic_decap_skb(struct hfi_vnic_rx_queue *rxq, struct sk_buff *skb);
 u8 hfi_vnic_calc_entropy(struct hfi_vnic_adapter *adapter, struct sk_buff *skb);
+void hfi_vnic_process_vema_config(struct hfi_vnic_adapter *adapter);
 void hfi_vnic_release_mac_tbl(struct hfi_vnic_adapter *adapter);
 void hfi_vnic_query_mac_tbl(struct hfi_vnic_adapter *adapter,
 			    struct hfi_veswport_mactable *tbl);
 int hfi_vnic_update_mac_tbl(struct hfi_vnic_adapter *adapter,
 			    struct hfi_veswport_mactable *tbl);
+void hfi_vnic_query_ucast_macs(struct hfi_vnic_adapter *adapter,
+			       struct hfi_veswport_iface_macs *macs);
+void hfi_vnic_query_mcast_macs(struct hfi_vnic_adapter *adapter,
+			       struct hfi_veswport_iface_macs *macs);
 void hfi_vnic_update_stats(struct net_device *netdev);
+void hfi_vnic_get_summary_counters(struct hfi_vnic_adapter *adapter,
+				   struct hfi_veswport_summary_counters *cntrs);
+void hfi_vnic_get_error_counters(struct hfi_vnic_adapter *adapter,
+				 struct hfi_veswport_error_counters *cntrs);
+void hfi_vnic_get_vesw_info(struct hfi_vnic_adapter *adapter,
+			    struct hfi_vesw_info *info);
+void hfi_vnic_set_vesw_info(struct hfi_vnic_adapter *adapter,
+			    struct hfi_vesw_info *info);
+void hfi_vnic_get_per_veswport_info(struct hfi_vnic_adapter *adapter,
+				    struct hfi_per_veswport_info *info);
+void hfi_vnic_set_per_veswport_info(struct hfi_vnic_adapter *adapter,
+				    struct hfi_per_veswport_info *info);
+void hfi_vnic_vema_report_event(struct hfi_vnic_adapter *adapter, u8 event);
 void hfi_vnic_set_ethtool_ops(struct net_device *ndev);
 
 #endif /* _HFI_VNIC_INTERNAL_H */
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c
index ee18610..75a3fd2 100644
--- a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c
@@ -51,6 +51,7 @@
 
 #include <linux/module.h>
 #include <linux/if_vlan.h>
+#include <linux/crc32.h>
 
 #include "hfi_vnic.h"
 #include "hfi_vnic_internal.h"
@@ -533,7 +534,96 @@ static void hfi_vnic_down(struct hfi_vnic_adapter *adapter)
 	clear_bit(HFI_VNIC_UP, &adapter->flags);
 }
 
-/* hfi_vnic_set_mac_addr - change mac address */
+/* hfi_vnic_process_vema_config - process vema configuration updates */
+void hfi_vnic_process_vema_config(struct hfi_vnic_adapter *adapter)
+{
+	struct __hfi_veswport_info *info = &adapter->info;
+	struct hfi_vnic_device *vdev = adapter->vdev;
+	u8 port_num[HFI_VESW_MAX_NUM_DEF_PORT] = { 0 };
+	u16 port_mask, mtu_limit = ETH_ZLEN - ETH_HLEN;
+	u8 i, port_count = 0;
+
+	/*
+	 * If the base_mac_addr is changed, update the interface mac address.
+	 * If the mac address is rejected, do not accept new base_mac_addr.
+	 */
+	if (memcmp(info->vport.base_mac_addr, adapter->vema_mac_addr,
+		   ARRAY_SIZE(info->vport.base_mac_addr))) {
+		struct sockaddr saddr;
+
+		memcpy(saddr.sa_data, info->vport.base_mac_addr,
+		       ARRAY_SIZE(info->vport.base_mac_addr));
+		mutex_lock(&adapter->lock);
+		if (!eth_mac_addr(adapter->netdev, &saddr))
+			memcpy(adapter->vema_mac_addr,
+			       info->vport.base_mac_addr, ETH_ALEN);
+		else
+			memcpy(info->vport.base_mac_addr,
+			       adapter->vema_mac_addr, ETH_ALEN);
+		mutex_unlock(&adapter->lock);
+	}
+
+	/*
+	 * If vesw_id is being changed, and if the vnic interface
+	 * is up, reset the hfi interface to ensure new vesw_id
+	 * is picked by hfi driver
+	 */
+	if (vdev->vesw_id != info->vesw.vesw_id) {
+		mutex_lock(&adapter->lock);
+		if (test_bit(HFI_VNIC_UP, &adapter->flags))
+			hfi_vnic_down(adapter);
+
+		vdev->vesw_id = info->vesw.vesw_id;
+		if (test_bit(HFI_VNIC_OPEN, &adapter->flags))
+			hfi_vnic_up(adapter);
+
+		mutex_unlock(&adapter->lock);
+	}
+
+	/* Handle MTU limit change */
+	mtu_limit = max(info->vesw.eth_mtu_non_vlan, mtu_limit);
+	rtnl_lock();
+	if (adapter->netdev->mtu > mtu_limit)
+		dev_set_mtu(adapter->netdev, mtu_limit);
+	rtnl_unlock();
+
+	/* Update flow to default port redirection table */
+	port_mask = info->vesw.def_port_mask;
+	for (i = 0; i < HFI_VESW_MAX_NUM_DEF_PORT; i++) {
+		if (port_mask & 1)
+			port_num[port_count++] = i;
+		port_mask >>= 1;
+	}
+
+	/*
+	 * Build the flow table. Flow table is required when destination LID
+	 * is not available. Up to HFI_VNIC_FLOW_TBL_SIZE flows supported.
+	 * Each flow need a default port number to get its dlid from the
+	 * u_ucast_dlid array.
+	 */
+	for (i = 0; i < HFI_VNIC_FLOW_TBL_SIZE; i++)
+		adapter->flow_tbl[i] = port_count ? port_num[i % port_count] :
+						    HFI_VNIC_INVALID_PORT;
+
+	/* Operational state can only be DROP_ALL or FORWARDING */
+	if (info->vport.config_state == HFI_VNIC_STATE_FORWARDING)
+		info->vport.oper_state = HFI_VNIC_STATE_FORWARDING;
+	else
+		info->vport.oper_state = HFI_VNIC_STATE_DROP_ALL;
+}
+
+/*
+ * Set the power on default values in adapter's vema interface structure.
+ */
+static inline void hfi_vnic_set_pod_values(struct hfi_vnic_adapter *adapter)
+{
+	adapter->info.vport.max_mac_tbl_ent = HFI_VNIC_MAC_TBL_MAX_ENTRIES;
+	adapter->info.vport.max_smac_ent = HFI_VNIC_MAX_SMAC_LIMIT;
+	adapter->info.vport.config_state = HFI_VNIC_STATE_DROP_ALL;
+	adapter->info.vport.eth_link_status = HFI_VNIC_ETH_LINK_DOWN;
+}
+
+/* hfi_vnic_set_mac_addr - change mac address and send trap */
 static int hfi_vnic_set_mac_addr(struct net_device *netdev, void *addr)
 {
 	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
@@ -542,8 +632,62 @@ static int hfi_vnic_set_mac_addr(struct net_device *netdev, void *addr)
 	mutex_lock(&adapter->lock);
 	rc = eth_mac_addr(netdev, addr);
 	mutex_unlock(&adapter->lock);
+	if (rc)
+		return rc;
 
-	return rc;
+	adapter->info.vport.uc_macs_gen_count++;
+	hfi_vnic_vema_report_event(adapter,
+				   HFI_VESWPORT_TRAP_IFACE_UCAST_MAC_CHANGE);
+	return 0;
+}
+
+/*
+ * hfi_vnic_mac_send_event - post event on possible mac list exchange
+ *  Send trap when digest from uc/mc mac list differs from previous run.
+ *  Digest is evaluated similar to how cksum does.
+ */
+static void hfi_vnic_mac_send_event(struct net_device *netdev, u8 event)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	struct netdev_hw_addr *ha;
+	struct netdev_hw_addr_list *hw_list;
+	u32 *ref_crc;
+	u32 l, crc = 0;
+
+	switch (event) {
+	case HFI_VESWPORT_TRAP_IFACE_UCAST_MAC_CHANGE:
+		hw_list = &netdev->uc;
+		adapter->info.vport.uc_macs_gen_count++;
+		ref_crc = &adapter->umac_hash;
+		break;
+	case HFI_VESWPORT_TRAP_IFACE_MCAST_MAC_CHANGE:
+		hw_list = &netdev->mc;
+		adapter->info.vport.mc_macs_gen_count++;
+		ref_crc = &adapter->mmac_hash;
+		break;
+	default:
+		return;
+	}
+	netdev_hw_addr_list_for_each(ha, hw_list) {
+		crc = crc32_le(crc, ha->addr, ETH_ALEN);
+	}
+	l = netdev_hw_addr_list_count(hw_list) * ETH_ALEN;
+	crc = ~crc32_le(crc, (void *)&l, sizeof(l));
+
+	if (crc != *ref_crc) {
+		*ref_crc = crc;
+		hfi_vnic_vema_report_event(adapter, event);
+	}
+}
+
+/* hfi_vnic_set_rx_mode - handle uc/mc mac list change */
+static void hfi_vnic_set_rx_mode(struct net_device *netdev)
+{
+	hfi_vnic_mac_send_event(netdev,
+				HFI_VESWPORT_TRAP_IFACE_UCAST_MAC_CHANGE);
+
+	hfi_vnic_mac_send_event(netdev,
+				HFI_VESWPORT_TRAP_IFACE_MCAST_MAC_CHANGE);
 }
 
 /* hfi_netdev_open - activate network interface */
@@ -557,6 +701,10 @@ static int hfi_netdev_open(struct net_device *netdev)
 	if (rc)
 		goto open_done;
 
+	/* Update eth link status and send trap */
+	adapter->info.vport.eth_link_status = HFI_VNIC_ETH_LINK_UP;
+	hfi_vnic_vema_report_event(adapter,
+				   HFI_VESWPORT_TRAP_ETH_LINK_STATUS_CHANGE);
 	set_bit(HFI_VNIC_OPEN, &adapter->flags);
 	v_info("opened\n");
 open_done:
@@ -573,6 +721,10 @@ static int hfi_netdev_close(struct net_device *netdev)
 	if (test_bit(HFI_VNIC_UP, &adapter->flags))
 		hfi_vnic_down(adapter);
 
+	/* Update eth link status and send trap */
+	adapter->info.vport.eth_link_status = HFI_VNIC_ETH_LINK_DOWN;
+	hfi_vnic_vema_report_event(adapter,
+				   HFI_VESWPORT_TRAP_ETH_LINK_STATUS_CHANGE);
 	clear_bit(HFI_VNIC_OPEN, &adapter->flags);
 	mutex_unlock(&adapter->lock);
 	v_info("closed\n");
@@ -586,6 +738,7 @@ static int hfi_netdev_close(struct net_device *netdev)
 	.ndo_start_xmit = hfi_netdev_start_xmit,
 	.ndo_change_mtu = hfi_netdev_change_mtu,
 	.ndo_get_stats64 = hfi_vnic_get_stats64,
+	.ndo_set_rx_mode = hfi_vnic_set_rx_mode,
 	.ndo_select_queue = hfi_vnic_select_queue,
 	.ndo_set_mac_address = hfi_vnic_set_mac_addr,
 };
@@ -636,6 +789,8 @@ static int hfi_vnic_drv_probe(struct device *dev)
 		netif_napi_add(netdev, &adapter->rxq[i].napi, vnic_napi, 64);
 	}
 
+	hfi_vnic_set_pod_values(adapter);
+
 	rc = vdev->bus_ops->init(vdev);
 	if (rc)
 		goto hw_err;
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c
new file mode 100644
index 0000000..4a87826
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c
@@ -0,0 +1,385 @@
+/*
+ * Copyright(c) 2016 Intel Corporation.
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
+ * This file contains HFI VNIC EMA Interface functions.
+ */
+
+#include "hfi_vnic.h"
+#include "hfi_vnic_internal.h"
+
+/**
+ * hfi_vnic_vema_report_event - sent trap to report the specified event
+ * @adapter: vnic port adapter
+ * @event: event to be reported
+ *
+ * This function calls vema api to sent a trap for the given event.
+ */
+void hfi_vnic_vema_report_event(struct hfi_vnic_adapter *adapter, u8 event)
+{
+	struct __hfi_veswport_info *info = &adapter->info;
+	struct hfi_vnic_device *vdev = adapter->vdev;
+	struct __hfi_veswport_trap trap_data;
+
+	trap_data.fabric_id = info->vesw.fabric_id;
+	trap_data.veswid = info->vesw.vesw_id;
+	trap_data.veswportnum = info->vport.port_num;
+	trap_data.hfiportnum = vdev->port_num;
+	trap_data.veswportindex = vdev->vport_num;
+	trap_data.opcode = event;
+
+	/* Need to send trap here */
+}
+
+/**
+ * hfi_vnic_get_error_counters - get summary counters
+ * @adapter: vnic port adapter
+ * @cntrs: pointer to destination summary counters structure
+ *
+ * This function populates the summary counters that is maintained by the
+ * given adapter to destination address provided.
+ */
+void hfi_vnic_get_summary_counters(struct hfi_vnic_adapter *adapter,
+				   struct hfi_veswport_summary_counters *cntrs)
+{
+	__be64 *dst;
+	u64 *src;
+
+	mutex_lock(&adapter->stats_lock);
+	/* update stats */
+	hfi_vnic_update_stats(adapter->netdev);
+
+	cntrs->vp_instance = cpu_to_be16(adapter->vdev->vport_num);
+	cntrs->vesw_id = cpu_to_be16(adapter->vdev->vesw_id);
+	cntrs->veswport_num = cpu_to_be32(adapter->info.vport.port_num);
+
+	/*
+	 * This loop depends on layout of
+	 * struct hfi_veswport_summary_counters and
+	 * struct __hfi_vnic_summary_counter
+	 */
+	for (dst = &cntrs->tx_errors, src = &adapter->sum_cntrs.tx_errors;
+	     dst < &cntrs->reserved[0]; dst++, src++) {
+		*dst = cpu_to_be64(*src);
+	}
+
+	mutex_unlock(&adapter->stats_lock);
+}
+
+/**
+ * hfi_vnic_get_error_counters - get error counters
+ * @adapter: vnic port adapter
+ * @cntrs: pointer to destination error counters structure
+ *
+ * This function populates the error counters that is maintained by the
+ * given adapter to destination address provided.
+ */
+void hfi_vnic_get_error_counters(struct hfi_vnic_adapter *adapter,
+				 struct hfi_veswport_error_counters *cntrs)
+{
+	mutex_lock(&adapter->stats_lock);
+	/* update stats */
+	hfi_vnic_update_stats(adapter->netdev);
+
+	cntrs->vp_instance = cpu_to_be16(adapter->vdev->vport_num);
+	cntrs->vesw_id = cpu_to_be16(adapter->vdev->vesw_id);
+	cntrs->veswport_num = cpu_to_be32(adapter->info.vport.port_num);
+
+	cntrs->tx_errors = cpu_to_be64(adapter->err_cntrs.tx_errors);
+	cntrs->rx_errors = cpu_to_be64(adapter->err_cntrs.rx_errors);
+	cntrs->tx_smac_filt = cpu_to_be64(adapter->err_cntrs.tx_smac_filt);
+	cntrs->tx_dlid_zero = cpu_to_be64(adapter->err_cntrs.tx_dlid_zero);
+	cntrs->tx_logic = cpu_to_be64(adapter->err_cntrs.tx_logic);
+	cntrs->tx_drop_state = cpu_to_be64(adapter->err_cntrs.tx_drop_state);
+
+	cntrs->rx_bad_veswid = cpu_to_be64(adapter->err_cntrs.rx_bad_veswid);
+	cntrs->rx_runt = cpu_to_be64(adapter->err_cntrs.rx_runt);
+	cntrs->rx_oversize = cpu_to_be64(adapter->err_cntrs.rx_oversize);
+	cntrs->rx_eth_down = cpu_to_be64(adapter->err_cntrs.rx_eth_down);
+	cntrs->rx_drop_state = cpu_to_be64(adapter->err_cntrs.rx_drop_state);
+	cntrs->rx_logic = cpu_to_be64(adapter->err_cntrs.rx_logic);
+	mutex_unlock(&adapter->stats_lock);
+}
+
+/**
+ * hfi_vnic_get_vesw_info -- Get the vesw information
+ * @adapter: vnic port adapter
+ * @info: pointer to destination vesw info structure
+ *
+ * This function copies the vesw info that is maintained by the
+ * given adapter to destination address provided.
+ */
+void hfi_vnic_get_vesw_info(struct hfi_vnic_adapter *adapter,
+			    struct hfi_vesw_info *info)
+{
+	struct __hfi_vesw_info *src = &adapter->info.vesw;
+	int i;
+
+	info->fabric_id = cpu_to_be16(src->fabric_id);
+	info->vesw_id = cpu_to_be16(src->vesw_id);
+	memcpy(info->rsvd0, src->rsvd0, ARRAY_SIZE(src->rsvd0));
+	info->def_port_mask = cpu_to_be16(src->def_port_mask);
+	memcpy(info->rsvd1, src->rsvd1, ARRAY_SIZE(src->rsvd1));
+	info->pkey = cpu_to_be16(src->pkey);
+
+	memcpy(info->rsvd2, src->rsvd2, ARRAY_SIZE(src->rsvd2));
+	info->u_mcast_dlid = cpu_to_be32(src->u_mcast_dlid);
+	for (i = 0; i < HFI_VESW_MAX_NUM_DEF_PORT; i++)
+		info->u_ucast_dlid[i] = cpu_to_be32(src->u_ucast_dlid[i]);
+
+	memcpy(info->rsvd3, src->rsvd3, ARRAY_SIZE(src->rsvd3));
+	for (i = 0; i < HFI_VNIC_MAX_NUM_PCP; i++)
+		info->eth_mtu[i] = cpu_to_be16(src->eth_mtu[i]);
+
+	info->eth_mtu_non_vlan = cpu_to_be16(src->eth_mtu_non_vlan);
+	memcpy(info->rsvd4, src->rsvd4, ARRAY_SIZE(src->rsvd4));
+}
+
+/**
+ * hfi_vnic_set_vesw_info -- Set the vesw information
+ * @adapter: vnic port adapter
+ * @info: pointer to vesw info structure
+ *
+ * This function updates the vesw info that is maintained by the
+ * given adapter with vesw info provided. Reserved fields are stored
+ * and returned back to EM as is.
+ */
+void hfi_vnic_set_vesw_info(struct hfi_vnic_adapter *adapter,
+			    struct hfi_vesw_info *info)
+{
+	struct __hfi_vesw_info *dst = &adapter->info.vesw;
+	int i;
+
+	dst->fabric_id = be16_to_cpu(info->fabric_id);
+	dst->vesw_id = be16_to_cpu(info->vesw_id);
+	memcpy(dst->rsvd0, info->rsvd0, ARRAY_SIZE(info->rsvd0));
+	dst->def_port_mask = be16_to_cpu(info->def_port_mask);
+	memcpy(dst->rsvd1, info->rsvd1, ARRAY_SIZE(info->rsvd1));
+	dst->pkey = be16_to_cpu(info->pkey);
+
+	memcpy(dst->rsvd2, info->rsvd2, ARRAY_SIZE(info->rsvd2));
+	dst->u_mcast_dlid = be32_to_cpu(info->u_mcast_dlid);
+	for (i = 0; i < HFI_VESW_MAX_NUM_DEF_PORT; i++)
+		dst->u_ucast_dlid[i] = be32_to_cpu(info->u_ucast_dlid[i]);
+
+	memcpy(dst->rsvd3, info->rsvd3, ARRAY_SIZE(info->rsvd3));
+	for (i = 0; i < HFI_VNIC_MAX_NUM_PCP; i++)
+		dst->eth_mtu[i] = be16_to_cpu(info->eth_mtu[i]);
+
+	dst->eth_mtu_non_vlan = be16_to_cpu(info->eth_mtu_non_vlan);
+	memcpy(dst->rsvd4, info->rsvd4, ARRAY_SIZE(info->rsvd4));
+}
+
+/**
+ * hfi_vnic_get_per_veswport_info -- Get the vesw per port information
+ * @adapter: vnic port adapter
+ * @info: pointer to destination vport info structure
+ *
+ * This function copies the vesw per port info that is maintained by the
+ * given adapter to destination address provided.
+ * Note that the read only fields are not copied.
+ */
+void hfi_vnic_get_per_veswport_info(struct hfi_vnic_adapter *adapter,
+				    struct hfi_per_veswport_info *info)
+{
+	struct __hfi_per_veswport_info *src = &adapter->info.vport;
+
+	info->port_num = cpu_to_be32(src->port_num);
+	info->eth_link_status = src->eth_link_status;
+	memcpy(info->rsvd0, src->rsvd0, ARRAY_SIZE(src->rsvd0));
+
+	memcpy(info->base_mac_addr, src->base_mac_addr,
+	       ARRAY_SIZE(info->base_mac_addr));
+	info->config_state = src->config_state;
+	info->oper_state = src->oper_state;
+	info->max_mac_tbl_ent = cpu_to_be16(src->max_mac_tbl_ent);
+	info->max_smac_ent = cpu_to_be16(src->max_smac_ent);
+	info->mac_tbl_digest = cpu_to_be32(src->mac_tbl_digest);
+	memcpy(info->rsvd1, src->rsvd1, ARRAY_SIZE(src->rsvd1));
+
+	info->encap_slid = cpu_to_be32(src->encap_slid);
+	memcpy(info->pcp_to_sc_uc, src->pcp_to_sc_uc,
+	       ARRAY_SIZE(info->pcp_to_sc_uc));
+	memcpy(info->pcp_to_vl_uc, src->pcp_to_vl_uc,
+	       ARRAY_SIZE(info->pcp_to_vl_uc));
+	memcpy(info->pcp_to_sc_mc, src->pcp_to_sc_mc,
+	       ARRAY_SIZE(info->pcp_to_sc_mc));
+	memcpy(info->pcp_to_vl_mc, src->pcp_to_vl_mc,
+	       ARRAY_SIZE(info->pcp_to_vl_mc));
+	info->non_vlan_sc_uc = src->non_vlan_sc_uc;
+	info->non_vlan_vl_uc = src->non_vlan_vl_uc;
+	info->non_vlan_sc_mc = src->non_vlan_sc_mc;
+	info->non_vlan_vl_mc = src->non_vlan_vl_mc;
+	memcpy(info->rsvd2, src->rsvd2, ARRAY_SIZE(src->rsvd2));
+
+	info->uc_macs_gen_count = cpu_to_be16(src->uc_macs_gen_count);
+	info->mc_macs_gen_count = cpu_to_be16(src->mc_macs_gen_count);
+	memcpy(info->rsvd3, src->rsvd3, ARRAY_SIZE(src->rsvd3));
+}
+
+/**
+ * hfi_vnic_set_per_veswport_info -- Set vesw per port information
+ * @adapter: vnic port adapter
+ * @info: pointer to vport info structure
+ *
+ * This function updates the vesw per port info that is maintained by the
+ * given adapter with vesw per port info provided. Reserved fields are
+ * stored and returned back to EM as is.
+ */
+void hfi_vnic_set_per_veswport_info(struct hfi_vnic_adapter *adapter,
+				    struct hfi_per_veswport_info *info)
+{
+	struct __hfi_per_veswport_info *dst = &adapter->info.vport;
+
+	dst->port_num = be32_to_cpu(info->port_num);
+	memcpy(dst->rsvd0, info->rsvd0, ARRAY_SIZE(info->rsvd0));
+
+	memcpy(dst->base_mac_addr, info->base_mac_addr,
+	       ARRAY_SIZE(dst->base_mac_addr));
+	dst->config_state = info->config_state;
+	memcpy(dst->rsvd1, info->rsvd1, ARRAY_SIZE(info->rsvd1));
+
+	dst->encap_slid = be32_to_cpu(info->encap_slid);
+	memcpy(dst->pcp_to_sc_uc, info->pcp_to_sc_uc,
+	       ARRAY_SIZE(dst->pcp_to_sc_uc));
+	memcpy(dst->pcp_to_vl_uc, info->pcp_to_vl_uc,
+	       ARRAY_SIZE(dst->pcp_to_vl_uc));
+	memcpy(dst->pcp_to_sc_mc, info->pcp_to_sc_mc,
+	       ARRAY_SIZE(dst->pcp_to_sc_mc));
+	memcpy(dst->pcp_to_vl_mc, info->pcp_to_vl_mc,
+	       ARRAY_SIZE(dst->pcp_to_vl_mc));
+	dst->non_vlan_sc_uc = info->non_vlan_sc_uc;
+	dst->non_vlan_vl_uc = info->non_vlan_vl_uc;
+	dst->non_vlan_sc_mc = info->non_vlan_sc_mc;
+	dst->non_vlan_vl_mc = info->non_vlan_vl_mc;
+	memcpy(dst->rsvd2, info->rsvd2, ARRAY_SIZE(info->rsvd2));
+	memcpy(dst->rsvd3, info->rsvd3, ARRAY_SIZE(info->rsvd3));
+}
+
+/**
+ * hfi_vnic_query_mcast_macs - query multicast mac list
+ * @adapter: vnic port adapter
+ * @macs: pointer mac list
+ *
+ * This function populates the provided mac list with the configured
+ * multicast addresses in the adapter.
+ */
+void hfi_vnic_query_mcast_macs(struct hfi_vnic_adapter *adapter,
+			       struct hfi_veswport_iface_macs *macs)
+{
+	u16 start_idx, num_macs, idx = 0, count = 0;
+	struct netdev_hw_addr *ha;
+
+	start_idx = be16_to_cpu(macs->start_idx);
+	num_macs = be16_to_cpu(macs->num_macs_in_msg);
+	netdev_for_each_mc_addr(ha, adapter->netdev) {
+		struct hfi_vnic_iface_mac_entry *entry = &macs->entry[count];
+
+		if (start_idx > idx++)
+			continue;
+		else if (num_macs == count)
+			break;
+		memcpy(entry, ha->addr, sizeof(*entry));
+		count++;
+	}
+
+	macs->tot_macs_in_lst = cpu_to_be16(netdev_mc_count(adapter->netdev));
+	macs->num_macs_in_msg = cpu_to_be16(count);
+	macs->gen_count = cpu_to_be16(adapter->info.vport.mc_macs_gen_count);
+}
+
+/**
+ * hfi_vnic_query_ucast_macs - query unicast mac list
+ * @adapter: vnic port adapter
+ * @macs: pointer mac list
+ *
+ * This function populates the provided mac list with the configured
+ * unicast addresses in the adapter.
+ */
+void hfi_vnic_query_ucast_macs(struct hfi_vnic_adapter *adapter,
+			       struct hfi_veswport_iface_macs *macs)
+{
+	u16 start_idx, tot_macs, num_macs, idx = 0, count = 0;
+	struct netdev_hw_addr *ha;
+
+	start_idx = be16_to_cpu(macs->start_idx);
+	num_macs = be16_to_cpu(macs->num_macs_in_msg);
+	/* loop through dev_addrs list first */
+	for_each_dev_addr(adapter->netdev, ha) {
+		struct hfi_vnic_iface_mac_entry *entry = &macs->entry[count];
+
+		/* Do not include EM specified MAC address */
+		if (!memcmp(adapter->info.vport.base_mac_addr, ha->addr,
+			    ARRAY_SIZE(adapter->info.vport.base_mac_addr)))
+			continue;
+
+		if (start_idx > idx++)
+			continue;
+		else if (num_macs == count)
+			break;
+		memcpy(entry, ha->addr, sizeof(*entry));
+		count++;
+	}
+
+	/* loop through uc list */
+	netdev_for_each_uc_addr(ha, adapter->netdev) {
+		struct hfi_vnic_iface_mac_entry *entry = &macs->entry[count];
+
+		if (start_idx > idx++)
+			continue;
+		else if (num_macs == count)
+			break;
+		memcpy(entry, ha->addr, sizeof(*entry));
+		count++;
+	}
+
+	tot_macs = netdev_hw_addr_list_count(&adapter->netdev->dev_addrs) +
+		   netdev_uc_count(adapter->netdev);
+	macs->tot_macs_in_lst = cpu_to_be16(tot_macs);
+	macs->num_macs_in_msg = cpu_to_be16(count);
+	macs->gen_count = cpu_to_be16(adapter->info.vport.uc_macs_gen_count);
+}
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
