From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [PATCH rdma-next v2 08/12] IB/opa-vnic: VNIC Ethernet Management Agent (VEMA) interface
Date: Wed, 12 Apr 2017 20:29:26 -0700
Message-ID: <1492054170-23577-9-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1492054170-23577-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com, ira.weiny@intel.com,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>,
        Sadanand Warrier <sadanand.warrier@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14351 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756078AbdDMD3q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 23:29:46 -0400
In-Reply-To: <1492054170-23577-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OPA VNIC EMA interface functions are the management interfaces to the OPA
VNIC netdev. Add support to add and remove VNIC ports. Implement the
required GET/SET management interface functions and processing of new
management information. Add support to send trap notifications upon various
events like interface status change, unicast/multicast mac list update and
mac address change.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
Signed-off-by: Sadanand Warrier <sadanand.warrier@intel.com>
---
 drivers/infiniband/ulp/opa_vnic/Makefile           |   3 +-
 drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h   |   4 +
 .../infiniband/ulp/opa_vnic/opa_vnic_internal.h    |  44 +++
 drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c  | 142 +++++++-
 .../infiniband/ulp/opa_vnic/opa_vnic_vema_iface.c  | 390 +++++++++++++++++++++
 5 files changed, 581 insertions(+), 2 deletions(-)
 create mode 100644 drivers/infiniband/ulp/opa_vnic/opa_vnic_vema_iface.c

diff --git a/drivers/infiniband/ulp/opa_vnic/Makefile b/drivers/infiniband/ulp/opa_vnic/Makefile
index 975c313..e8d1ea1 100644
--- a/drivers/infiniband/ulp/opa_vnic/Makefile
+++ b/drivers/infiniband/ulp/opa_vnic/Makefile
@@ -3,4 +3,5 @@
 #
 obj-$(CONFIG_INFINIBAND_OPA_VNIC) += opa_vnic.o
 
-opa_vnic-y := opa_vnic_netdev.o opa_vnic_encap.o opa_vnic_ethtool.o
+opa_vnic-y := opa_vnic_netdev.o opa_vnic_encap.o opa_vnic_ethtool.o \
+              opa_vnic_vema_iface.o
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h b/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h
index c025cde..4c434b9 100644
--- a/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h
@@ -99,6 +99,10 @@
 #define OPA_VNIC_DLID_SD_IS_SRC_MAC(dlid_sd)  (!!((dlid_sd) & 0x20))
 #define OPA_VNIC_DLID_SD_GET_DLID(dlid_sd)    ((dlid_sd) >> 8)
 
+/* VNIC Ethernet link status */
+#define OPA_VNIC_ETH_LINK_UP     1
+#define OPA_VNIC_ETH_LINK_DOWN   2
+
 /**
  * struct opa_vesw_info - OPA vnic switch information
  * @fabric_id: 10-bit fabric id
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h b/drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h
index bec4866..b49f5d7 100644
--- a/drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h
@@ -161,14 +161,28 @@ struct __opa_veswport_trap {
 } __packed;
 
 /**
+ * struct opa_vnic_ctrl_port - OPA virtual NIC control port
+ * @ibdev: pointer to ib device
+ * @ops: opa vnic control operations
+ */
+struct opa_vnic_ctrl_port {
+	struct ib_device           *ibdev;
+	struct opa_vnic_ctrl_ops   *ops;
+};
+
+/**
  * struct opa_vnic_adapter - OPA VNIC netdev private data structure
  * @netdev: pointer to associated netdev
  * @ibdev: ib device
+ * @cport: pointer to opa vnic control port
  * @rn_ops: rdma netdev's net_device_ops
  * @port_num: OPA port number
  * @vport_num: vesw port number
  * @lock: adapter lock
  * @info: virtual ethernet switch port information
+ * @vema_mac_addr: mac address configured by vema
+ * @umac_hash: unicast maclist hash
+ * @mmac_hash: multicast maclist hash
  * @mactbl: hash table of MAC entries
  * @mactbl_lock: mac table lock
  * @stats_lock: statistics lock
@@ -177,6 +191,7 @@ struct __opa_veswport_trap {
 struct opa_vnic_adapter {
 	struct net_device             *netdev;
 	struct ib_device              *ibdev;
+	struct opa_vnic_ctrl_port     *cport;
 	const struct net_device_ops   *rn_ops;
 
 	u8 port_num;
@@ -186,6 +201,9 @@ struct opa_vnic_adapter {
 	struct mutex lock;
 
 	struct __opa_veswport_info  info;
+	u8                          vema_mac_addr[ETH_ALEN];
+	u32                         umac_hash;
+	u32                         mmac_hash;
 	struct hlist_head  __rcu   *mactbl;
 
 	/* Lock used to protect updates to mac table */
@@ -225,6 +243,11 @@ struct opa_vnic_mac_tbl_node {
 #define v_warn(format, arg...) \
 	netdev_warn(adapter->netdev, format, ## arg)
 
+#define c_err(format, arg...) \
+	dev_err(&cport->ibdev->dev, format, ## arg)
+#define c_info(format, arg...) \
+	dev_info(&cport->ibdev->dev, format, ## arg)
+
 /* The maximum allowed entries in the mac table */
 #define OPA_VNIC_MAC_TBL_MAX_ENTRIES  2048
 /* Limit of smac entries in mac table */
@@ -264,11 +287,32 @@ struct opa_vnic_adapter *opa_vnic_add_netdev(struct ib_device *ibdev,
 void opa_vnic_encap_skb(struct opa_vnic_adapter *adapter, struct sk_buff *skb);
 u8 opa_vnic_get_vl(struct opa_vnic_adapter *adapter, struct sk_buff *skb);
 u8 opa_vnic_calc_entropy(struct opa_vnic_adapter *adapter, struct sk_buff *skb);
+void opa_vnic_process_vema_config(struct opa_vnic_adapter *adapter);
 void opa_vnic_release_mac_tbl(struct opa_vnic_adapter *adapter);
 void opa_vnic_query_mac_tbl(struct opa_vnic_adapter *adapter,
 			    struct opa_veswport_mactable *tbl);
 int opa_vnic_update_mac_tbl(struct opa_vnic_adapter *adapter,
 			    struct opa_veswport_mactable *tbl);
+void opa_vnic_query_ucast_macs(struct opa_vnic_adapter *adapter,
+			       struct opa_veswport_iface_macs *macs);
+void opa_vnic_query_mcast_macs(struct opa_vnic_adapter *adapter,
+			       struct opa_veswport_iface_macs *macs);
+void opa_vnic_get_summary_counters(struct opa_vnic_adapter *adapter,
+				   struct opa_veswport_summary_counters *cntrs);
+void opa_vnic_get_error_counters(struct opa_vnic_adapter *adapter,
+				 struct opa_veswport_error_counters *cntrs);
+void opa_vnic_get_vesw_info(struct opa_vnic_adapter *adapter,
+			    struct opa_vesw_info *info);
+void opa_vnic_set_vesw_info(struct opa_vnic_adapter *adapter,
+			    struct opa_vesw_info *info);
+void opa_vnic_get_per_veswport_info(struct opa_vnic_adapter *adapter,
+				    struct opa_per_veswport_info *info);
+void opa_vnic_set_per_veswport_info(struct opa_vnic_adapter *adapter,
+				    struct opa_per_veswport_info *info);
+void opa_vnic_vema_report_event(struct opa_vnic_adapter *adapter, u8 event);
+struct opa_vnic_adapter *opa_vnic_add_vport(struct opa_vnic_ctrl_port *cport,
+					    u8 port_num, u8 vport_num);
+void opa_vnic_rem_vport(struct opa_vnic_adapter *adapter);
 void opa_vnic_set_ethtool_ops(struct net_device *netdev);
 
 #endif /* _OPA_VNIC_INTERNAL_H */
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c b/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
index e0a108f..905f39d 100644
--- a/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
@@ -52,6 +52,7 @@
 
 #include <linux/module.h>
 #include <linux/if_vlan.h>
+#include <linux/crc32.h>
 
 #include "opa_vnic_internal.h"
 
@@ -111,6 +112,79 @@ static u16 opa_vnic_select_queue(struct net_device *netdev, struct sk_buff *skb,
 	return rc;
 }
 
+/* opa_vnic_process_vema_config - process vema configuration updates */
+void opa_vnic_process_vema_config(struct opa_vnic_adapter *adapter)
+{
+	struct __opa_veswport_info *info = &adapter->info;
+	struct rdma_netdev *rn = netdev_priv(adapter->netdev);
+	u8 port_num[OPA_VESW_MAX_NUM_DEF_PORT] = { 0 };
+	struct net_device *netdev = adapter->netdev;
+	u8 i, port_count = 0;
+	u16 port_mask;
+
+	/* If the base_mac_addr is changed, update the interface mac address */
+	if (memcmp(info->vport.base_mac_addr, adapter->vema_mac_addr,
+		   ARRAY_SIZE(info->vport.base_mac_addr))) {
+		struct sockaddr saddr;
+
+		memcpy(saddr.sa_data, info->vport.base_mac_addr,
+		       ARRAY_SIZE(info->vport.base_mac_addr));
+		mutex_lock(&adapter->lock);
+		eth_mac_addr(netdev, &saddr);
+		memcpy(adapter->vema_mac_addr,
+		       info->vport.base_mac_addr, ETH_ALEN);
+		mutex_unlock(&adapter->lock);
+	}
+
+	rn->set_id(netdev, info->vesw.vesw_id);
+
+	/* Handle MTU limit change */
+	rtnl_lock();
+	netdev->max_mtu = max_t(unsigned int, info->vesw.eth_mtu_non_vlan,
+				netdev->min_mtu);
+	if (netdev->mtu > netdev->max_mtu)
+		dev_set_mtu(netdev, netdev->max_mtu);
+	rtnl_unlock();
+
+	/* Update flow to default port redirection table */
+	port_mask = info->vesw.def_port_mask;
+	for (i = 0; i < OPA_VESW_MAX_NUM_DEF_PORT; i++) {
+		if (port_mask & 1)
+			port_num[port_count++] = i;
+		port_mask >>= 1;
+	}
+
+	/*
+	 * Build the flow table. Flow table is required when destination LID
+	 * is not available. Up to OPA_VNIC_FLOW_TBL_SIZE flows supported.
+	 * Each flow need a default port number to get its dlid from the
+	 * u_ucast_dlid array.
+	 */
+	for (i = 0; i < OPA_VNIC_FLOW_TBL_SIZE; i++)
+		adapter->flow_tbl[i] = port_count ? port_num[i % port_count] :
+						    OPA_VNIC_INVALID_PORT;
+
+	/* Operational state can only be DROP_ALL or FORWARDING */
+	if (info->vport.config_state == OPA_VNIC_STATE_FORWARDING) {
+		info->vport.oper_state = OPA_VNIC_STATE_FORWARDING;
+		netif_dormant_off(netdev);
+	} else {
+		info->vport.oper_state = OPA_VNIC_STATE_DROP_ALL;
+		netif_dormant_on(netdev);
+	}
+}
+
+/*
+ * Set the power on default values in adapter's vema interface structure.
+ */
+static inline void opa_vnic_set_pod_values(struct opa_vnic_adapter *adapter)
+{
+	adapter->info.vport.max_mac_tbl_ent = OPA_VNIC_MAC_TBL_MAX_ENTRIES;
+	adapter->info.vport.max_smac_ent = OPA_VNIC_MAX_SMAC_LIMIT;
+	adapter->info.vport.config_state = OPA_VNIC_STATE_DROP_ALL;
+	adapter->info.vport.eth_link_status = OPA_VNIC_ETH_LINK_DOWN;
+}
+
 /* opa_vnic_set_mac_addr - change mac address */
 static int opa_vnic_set_mac_addr(struct net_device *netdev, void *addr)
 {
@@ -124,8 +198,62 @@ static int opa_vnic_set_mac_addr(struct net_device *netdev, void *addr)
 	mutex_lock(&adapter->lock);
 	rc = eth_mac_addr(netdev, addr);
 	mutex_unlock(&adapter->lock);
+	if (rc)
+		return rc;
 
-	return rc;
+	adapter->info.vport.uc_macs_gen_count++;
+	opa_vnic_vema_report_event(adapter,
+				   OPA_VESWPORT_TRAP_IFACE_UCAST_MAC_CHANGE);
+	return 0;
+}
+
+/*
+ * opa_vnic_mac_send_event - post event on possible mac list exchange
+ *  Send trap when digest from uc/mc mac list differs from previous run.
+ *  Digest is evaluated similar to how cksum does.
+ */
+static void opa_vnic_mac_send_event(struct net_device *netdev, u8 event)
+{
+	struct opa_vnic_adapter *adapter = opa_vnic_priv(netdev);
+	struct netdev_hw_addr *ha;
+	struct netdev_hw_addr_list *hw_list;
+	u32 *ref_crc;
+	u32 l, crc = 0;
+
+	switch (event) {
+	case OPA_VESWPORT_TRAP_IFACE_UCAST_MAC_CHANGE:
+		hw_list = &netdev->uc;
+		adapter->info.vport.uc_macs_gen_count++;
+		ref_crc = &adapter->umac_hash;
+		break;
+	case OPA_VESWPORT_TRAP_IFACE_MCAST_MAC_CHANGE:
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
+		opa_vnic_vema_report_event(adapter, event);
+	}
+}
+
+/* opa_vnic_set_rx_mode - handle uc/mc mac list change */
+static void opa_vnic_set_rx_mode(struct net_device *netdev)
+{
+	opa_vnic_mac_send_event(netdev,
+				OPA_VESWPORT_TRAP_IFACE_UCAST_MAC_CHANGE);
+
+	opa_vnic_mac_send_event(netdev,
+				OPA_VESWPORT_TRAP_IFACE_MCAST_MAC_CHANGE);
 }
 
 /* opa_netdev_open - activate network interface */
@@ -140,6 +268,10 @@ static int opa_netdev_open(struct net_device *netdev)
 		return rc;
 	}
 
+	/* Update eth link status and send trap */
+	adapter->info.vport.eth_link_status = OPA_VNIC_ETH_LINK_UP;
+	opa_vnic_vema_report_event(adapter,
+				   OPA_VESWPORT_TRAP_ETH_LINK_STATUS_CHANGE);
 	return 0;
 }
 
@@ -155,6 +287,10 @@ static int opa_netdev_close(struct net_device *netdev)
 		return rc;
 	}
 
+	/* Update eth link status and send trap */
+	adapter->info.vport.eth_link_status = OPA_VNIC_ETH_LINK_DOWN;
+	opa_vnic_vema_report_event(adapter,
+				   OPA_VESWPORT_TRAP_ETH_LINK_STATUS_CHANGE);
 	return 0;
 }
 
@@ -164,6 +300,7 @@ static int opa_netdev_close(struct net_device *netdev)
 	.ndo_stop = opa_netdev_close,
 	.ndo_start_xmit = opa_netdev_start_xmit,
 	.ndo_get_stats64 = opa_vnic_get_stats64,
+	.ndo_set_rx_mode = opa_vnic_set_rx_mode,
 	.ndo_select_queue = opa_vnic_select_queue,
 	.ndo_set_mac_address = opa_vnic_set_mac_addr,
 };
@@ -212,6 +349,9 @@ struct opa_vnic_adapter *opa_vnic_add_netdev(struct ib_device *ibdev,
 	SET_NETDEV_DEV(netdev, ibdev->dev.parent);
 
 	opa_vnic_set_ethtool_ops(netdev);
+
+	opa_vnic_set_pod_values(adapter);
+
 	rc = register_netdev(netdev);
 	if (rc)
 		goto netdev_err;
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_vema_iface.c b/drivers/infiniband/ulp/opa_vnic/opa_vnic_vema_iface.c
new file mode 100644
index 0000000..2e01149
--- /dev/null
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_vema_iface.c
@@ -0,0 +1,390 @@
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
+ * This file contains OPA VNIC EMA Interface functions.
+ */
+
+#include "opa_vnic_internal.h"
+
+/**
+ * opa_vnic_vema_report_event - sent trap to report the specified event
+ * @adapter: vnic port adapter
+ * @event: event to be reported
+ *
+ * This function calls vema api to sent a trap for the given event.
+ */
+void opa_vnic_vema_report_event(struct opa_vnic_adapter *adapter, u8 event)
+{
+	struct __opa_veswport_info *info = &adapter->info;
+	struct __opa_veswport_trap trap_data;
+
+	trap_data.fabric_id = info->vesw.fabric_id;
+	trap_data.veswid = info->vesw.vesw_id;
+	trap_data.veswportnum = info->vport.port_num;
+	trap_data.opaportnum = adapter->port_num;
+	trap_data.veswportindex = adapter->vport_num;
+	trap_data.opcode = event;
+
+	/* Need to send trap here */
+}
+
+/**
+ * opa_vnic_get_error_counters - get summary counters
+ * @adapter: vnic port adapter
+ * @cntrs: pointer to destination summary counters structure
+ *
+ * This function populates the summary counters that is maintained by the
+ * given adapter to destination address provided.
+ */
+void opa_vnic_get_summary_counters(struct opa_vnic_adapter *adapter,
+				   struct opa_veswport_summary_counters *cntrs)
+{
+	struct opa_vnic_stats vstats;
+	__be64 *dst;
+	u64 *src;
+
+	memset(&vstats, 0, sizeof(vstats));
+	mutex_lock(&adapter->stats_lock);
+	adapter->rn_ops->ndo_get_stats64(adapter->netdev, &vstats.netstats);
+	mutex_unlock(&adapter->stats_lock);
+
+	cntrs->vp_instance = cpu_to_be16(adapter->vport_num);
+	cntrs->vesw_id = cpu_to_be16(adapter->info.vesw.vesw_id);
+	cntrs->veswport_num = cpu_to_be32(adapter->port_num);
+
+	cntrs->tx_errors = cpu_to_be64(vstats.netstats.tx_errors);
+	cntrs->rx_errors = cpu_to_be64(vstats.netstats.rx_errors);
+	cntrs->tx_packets = cpu_to_be64(vstats.netstats.tx_packets);
+	cntrs->rx_packets = cpu_to_be64(vstats.netstats.rx_packets);
+	cntrs->tx_bytes = cpu_to_be64(vstats.netstats.tx_bytes);
+	cntrs->rx_bytes = cpu_to_be64(vstats.netstats.rx_bytes);
+
+	/*
+	 * This loop depends on layout of
+	 * opa_veswport_summary_counters opa_vnic_stats structures.
+	 */
+	for (dst = &cntrs->tx_unicast, src = &vstats.tx_grp.unicast;
+	     dst < &cntrs->reserved[0]; dst++, src++) {
+		*dst = cpu_to_be64(*src);
+	}
+}
+
+/**
+ * opa_vnic_get_error_counters - get error counters
+ * @adapter: vnic port adapter
+ * @cntrs: pointer to destination error counters structure
+ *
+ * This function populates the error counters that is maintained by the
+ * given adapter to destination address provided.
+ */
+void opa_vnic_get_error_counters(struct opa_vnic_adapter *adapter,
+				 struct opa_veswport_error_counters *cntrs)
+{
+	struct opa_vnic_stats vstats;
+
+	memset(&vstats, 0, sizeof(vstats));
+	mutex_lock(&adapter->stats_lock);
+	adapter->rn_ops->ndo_get_stats64(adapter->netdev, &vstats.netstats);
+	mutex_unlock(&adapter->stats_lock);
+
+	cntrs->vp_instance = cpu_to_be16(adapter->vport_num);
+	cntrs->vesw_id = cpu_to_be16(adapter->info.vesw.vesw_id);
+	cntrs->veswport_num = cpu_to_be32(adapter->port_num);
+
+	cntrs->tx_errors = cpu_to_be64(vstats.netstats.tx_errors);
+	cntrs->rx_errors = cpu_to_be64(vstats.netstats.rx_errors);
+	cntrs->tx_dlid_zero = cpu_to_be64(vstats.tx_dlid_zero);
+	cntrs->tx_drop_state = cpu_to_be64(vstats.tx_drop_state);
+	cntrs->tx_logic = cpu_to_be64(vstats.netstats.tx_fifo_errors +
+				      vstats.netstats.tx_carrier_errors);
+
+	cntrs->rx_bad_veswid = cpu_to_be64(vstats.netstats.rx_nohandler);
+	cntrs->rx_runt = cpu_to_be64(vstats.rx_runt);
+	cntrs->rx_oversize = cpu_to_be64(vstats.rx_oversize);
+	cntrs->rx_drop_state = cpu_to_be64(vstats.rx_drop_state);
+	cntrs->rx_logic = cpu_to_be64(vstats.netstats.rx_fifo_errors);
+}
+
+/**
+ * opa_vnic_get_vesw_info -- Get the vesw information
+ * @adapter: vnic port adapter
+ * @info: pointer to destination vesw info structure
+ *
+ * This function copies the vesw info that is maintained by the
+ * given adapter to destination address provided.
+ */
+void opa_vnic_get_vesw_info(struct opa_vnic_adapter *adapter,
+			    struct opa_vesw_info *info)
+{
+	struct __opa_vesw_info *src = &adapter->info.vesw;
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
+	for (i = 0; i < OPA_VESW_MAX_NUM_DEF_PORT; i++)
+		info->u_ucast_dlid[i] = cpu_to_be32(src->u_ucast_dlid[i]);
+
+	memcpy(info->rsvd3, src->rsvd3, ARRAY_SIZE(src->rsvd3));
+	for (i = 0; i < OPA_VNIC_MAX_NUM_PCP; i++)
+		info->eth_mtu[i] = cpu_to_be16(src->eth_mtu[i]);
+
+	info->eth_mtu_non_vlan = cpu_to_be16(src->eth_mtu_non_vlan);
+	memcpy(info->rsvd4, src->rsvd4, ARRAY_SIZE(src->rsvd4));
+}
+
+/**
+ * opa_vnic_set_vesw_info -- Set the vesw information
+ * @adapter: vnic port adapter
+ * @info: pointer to vesw info structure
+ *
+ * This function updates the vesw info that is maintained by the
+ * given adapter with vesw info provided. Reserved fields are stored
+ * and returned back to EM as is.
+ */
+void opa_vnic_set_vesw_info(struct opa_vnic_adapter *adapter,
+			    struct opa_vesw_info *info)
+{
+	struct __opa_vesw_info *dst = &adapter->info.vesw;
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
+	for (i = 0; i < OPA_VESW_MAX_NUM_DEF_PORT; i++)
+		dst->u_ucast_dlid[i] = be32_to_cpu(info->u_ucast_dlid[i]);
+
+	memcpy(dst->rsvd3, info->rsvd3, ARRAY_SIZE(info->rsvd3));
+	for (i = 0; i < OPA_VNIC_MAX_NUM_PCP; i++)
+		dst->eth_mtu[i] = be16_to_cpu(info->eth_mtu[i]);
+
+	dst->eth_mtu_non_vlan = be16_to_cpu(info->eth_mtu_non_vlan);
+	memcpy(dst->rsvd4, info->rsvd4, ARRAY_SIZE(info->rsvd4));
+}
+
+/**
+ * opa_vnic_get_per_veswport_info -- Get the vesw per port information
+ * @adapter: vnic port adapter
+ * @info: pointer to destination vport info structure
+ *
+ * This function copies the vesw per port info that is maintained by the
+ * given adapter to destination address provided.
+ * Note that the read only fields are not copied.
+ */
+void opa_vnic_get_per_veswport_info(struct opa_vnic_adapter *adapter,
+				    struct opa_per_veswport_info *info)
+{
+	struct __opa_per_veswport_info *src = &adapter->info.vport;
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
+ * opa_vnic_set_per_veswport_info -- Set vesw per port information
+ * @adapter: vnic port adapter
+ * @info: pointer to vport info structure
+ *
+ * This function updates the vesw per port info that is maintained by the
+ * given adapter with vesw per port info provided. Reserved fields are
+ * stored and returned back to EM as is.
+ */
+void opa_vnic_set_per_veswport_info(struct opa_vnic_adapter *adapter,
+				    struct opa_per_veswport_info *info)
+{
+	struct __opa_per_veswport_info *dst = &adapter->info.vport;
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
+ * opa_vnic_query_mcast_macs - query multicast mac list
+ * @adapter: vnic port adapter
+ * @macs: pointer mac list
+ *
+ * This function populates the provided mac list with the configured
+ * multicast addresses in the adapter.
+ */
+void opa_vnic_query_mcast_macs(struct opa_vnic_adapter *adapter,
+			       struct opa_veswport_iface_macs *macs)
+{
+	u16 start_idx, num_macs, idx = 0, count = 0;
+	struct netdev_hw_addr *ha;
+
+	start_idx = be16_to_cpu(macs->start_idx);
+	num_macs = be16_to_cpu(macs->num_macs_in_msg);
+	netdev_for_each_mc_addr(ha, adapter->netdev) {
+		struct opa_vnic_iface_mac_entry *entry = &macs->entry[count];
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
+ * opa_vnic_query_ucast_macs - query unicast mac list
+ * @adapter: vnic port adapter
+ * @macs: pointer mac list
+ *
+ * This function populates the provided mac list with the configured
+ * unicast addresses in the adapter.
+ */
+void opa_vnic_query_ucast_macs(struct opa_vnic_adapter *adapter,
+			       struct opa_veswport_iface_macs *macs)
+{
+	u16 start_idx, tot_macs, num_macs, idx = 0, count = 0;
+	struct netdev_hw_addr *ha;
+
+	start_idx = be16_to_cpu(macs->start_idx);
+	num_macs = be16_to_cpu(macs->num_macs_in_msg);
+	/* loop through dev_addrs list first */
+	for_each_dev_addr(adapter->netdev, ha) {
+		struct opa_vnic_iface_mac_entry *entry = &macs->entry[count];
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
+		struct opa_vnic_iface_mac_entry *entry = &macs->entry[count];
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
