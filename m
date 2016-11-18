From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC 08/10] IB/hfi-vnic: VNIC Ethernet Management Agent (VEMA) driver
Date: Fri, 18 Nov 2016 14:42:16 -0800
Message-ID: <1479508938-63799-9-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sudeep Dutt <sudeep.dutt-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

HFI VEMA driver interfaces with the Infiniband MAD stack to exchange the
management information packets with the Ethernet Manager (EM).
It interfaces with the HFI VNIC netdev driver to SET/GET the management
information. The information exchanged with the EM includes class port
details, encapsulation configuration, various counters, unicast and
multicast MAC list and the MAC table. It also supports sending traps
to the EM.

Change-Id: I7439f96858c9019455da1e924a0201eb27177b85
Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sudeep Dutt <sudeep.dutt-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile |    2 +-
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h     |    9 +
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c       |    9 +-
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_vema.c         | 1024 ++++++++++++++++++++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c   |    2 +-
 5 files changed, 1043 insertions(+), 3 deletions(-)
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema.c

diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile b/drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile
index 375cd09..e05b72b 100644
--- a/drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile
@@ -5,4 +5,4 @@ ccflags-y += -I$(src)/../include
 obj-$(CONFIG_HFI_VNIC) += hfi_vnic.o
 
 hfi_vnic-y := hfi_vnic_netdev.o hfi_vnic_encap.o hfi_vnic_ethtool.o \
-              hfi_vnic_vema_iface.o
+              hfi_vnic_vema.o hfi_vnic_vema_iface.o
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
index 8ebed89..fbebf68 100644
--- a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
@@ -268,6 +268,8 @@ struct hfi_vnic_rx_queue {
  * @mactbl_lock: mac table lock
  * @stats_lock: statistics lock
  * @flow_tbl: flow to default port redirection table
+ * @trap_timeout: trap timeout
+ * @trap_count: no. of traps allowed within timeout period
  * @q_sum_cntrs: per queue EM summary counters
  * @q_err_cntrs: per queue EM error counters
  * @q_rx_logic_errors: per queue rx logic (default) errors
@@ -301,6 +303,8 @@ struct hfi_vnic_adapter {
 	struct mutex stats_lock;
 
 	u8 flow_tbl[HFI_VNIC_FLOW_TBL_SIZE];
+	unsigned long trap_timeout;
+	u8            trap_count;
 
 	struct __hfi_vnic_summary_counters  q_sum_cntrs[HFI_VNIC_MAX_QUEUE];
 	struct __hfi_vnic_error_counters    q_err_cntrs[HFI_VNIC_MAX_QUEUE];
@@ -410,4 +414,9 @@ void hfi_vnic_set_per_veswport_info(struct hfi_vnic_adapter *adapter,
 void hfi_vnic_vema_report_event(struct hfi_vnic_adapter *adapter, u8 event);
 void hfi_vnic_set_ethtool_ops(struct net_device *ndev);
 
+int hfi_vnic_vema_init(void);
+void hfi_vnic_vema_deinit(void);
+void hfi_vnic_vema_send_trap(struct hfi_vnic_adapter *adapter,
+			     struct __hfi_veswport_trap *data, u32 lid);
+
 #endif /* _HFI_VNIC_INTERNAL_H */
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c
index 75a3fd2..4ee5bb6 100644
--- a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c
@@ -855,9 +855,15 @@ static int __init hfi_vnic_init_module(void)
 	pr_info("HFI Virtual Network Driver - %s\n",
 		hfi_vnic_driver_version);
 
-	rc = hfi_vnic_driver_register(&hfi_vnic_drv);
+	rc = hfi_vnic_vema_init();
 	if (rc)
+		return rc;
+
+	rc = hfi_vnic_driver_register(&hfi_vnic_drv);
+	if (rc) {
 		pr_err("VNIC driver register failed %d\n", rc);
+		hfi_vnic_vema_deinit();
+	}
 
 	return rc;
 }
@@ -867,6 +873,7 @@ static int __init hfi_vnic_init_module(void)
 static void __exit hfi_vnic_exit_module(void)
 {
 	hfi_vnic_driver_unregister(&hfi_vnic_drv);
+	hfi_vnic_vema_deinit();
 }
 module_exit(hfi_vnic_exit_module);
 
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema.c b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema.c
new file mode 100644
index 0000000..b947cdf
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema.c
@@ -0,0 +1,1024 @@
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
+ * This file contains HFI Virtual Network Interface Controller (VNIC)
+ * Ethernet Management Agent (EMA) driver
+ */
+
+#include <rdma/ib_addr.h>
+#include <rdma/ib_smi.h>
+
+#include "hfi_vnic.h"
+#include "hfi_vnic_internal.h"
+
+/*
+ * The trap service level is kept in bits 3 to 7 in the trap_sl_rsvd
+ * field in the class port info MAD.
+ */
+#define GET_TRAP_SL_FROM_CLASS_PORT_INFO(x)  (((x) >> 3) & 0x1f)
+
+/* Cap trap bursts to a reasonable limit good for normal cases */
+#define HFI_VNIC_TRAP_BURST_LIMIT 4
+
+/*
+ * VNIC trap limit timeout.
+ * Inverse of cap2_mask response time out (1.0737 secs) = 0.9
+ * secs approx IB spec 13.4.6.2.1 PortInfoSubnetTimeout and
+ * 13.4.9 Traps.
+ */
+#define HFI_VNIC_TRAP_TIMEOUT  ((4096 * (1UL << 18)) / 1000)
+
+#define HFI_VNIC_UNSUP_ATTR  \
+		cpu_to_be16(IB_MGMT_MAD_STATUS_UNSUPPORTED_METHOD_ATTRIB)
+
+#define HFI_VNIC_INVAL_ATTR  \
+		cpu_to_be16(IB_MGMT_MAD_STATUS_INVALID_ATTRIB_VALUE)
+
+#define HFI_VNIC_CLASS_CAP_TRAP  cpu_to_be16(1 << 8)
+
+struct hfi_class_port_info {
+	u8 base_version;
+	u8 class_version;
+	__be16 cap_mask;
+	__be32 cap_mask2_resp_time;
+
+	u8 redirect_gid[16];
+	__be32 redirect_tc_fl;
+	__be32 redirect_lid;
+	__be32 redirect_sl_qp;
+	__be32 redirect_qkey;
+
+	u8 trap_gid[16];
+	__be32 trap_tc_fl;
+	__be32 trap_lid;
+	__be32 trap_hl_qp;
+	__be32 trap_qkey;
+
+	__be16 trap_pkey;
+	__be16 redirect_pkey;
+
+	u8 trap_sl_rsvd;
+	u8 reserved[3];
+} __packed;
+
+/**
+ * struct hfi_vnic_vema_port -- VNIC VEMA port details
+ * @cdev:     pointer to device
+ * @mad_agent: pointer to mad agent for port
+ * @class_port_info: Class port info information.
+ * @tid: Transaction id
+ * @port_num:  port number on HFI device
+ * @lock: adapter interface lock
+ * @vnic_mask: Bit mask for vnic presence
+ */
+struct hfi_vnic_vema_port {
+	struct hfi_vnic_ctrl_device    *cdev;
+	struct ib_mad_agent            *mad_agent;
+	struct hfi_class_port_info      class_port_info;
+	u64                             tid;
+	u8                              port_num;
+
+	/* Lock to query/update network adapter */
+	struct mutex                    lock;
+	DECLARE_BITMAP(vnic_mask, HFI_MAX_VPORTS_SUPPORTED);
+};
+
+static const char hfi_vnic_ctrl_driver_name[] = "hfi_vnic_ctrl";
+
+/**
+ * vema_get_vport_num -- Get the vnic from the mad
+ * @recvd_mad:  Received mad
+ *
+ * Return: returns value of the vnic port number
+ */
+static inline u8 vema_get_vport_num(struct hfi_vnic_vema_mad *recvd_mad)
+{
+	return be32_to_cpu(recvd_mad->mad_hdr.attr_mod) >> 16 & 0xff;
+}
+
+/**
+ * vema_mac_tbl_req_ok -- Check if mac request has correct values
+ * @mac_tbl: mac table
+ *
+ * This function checks for the validity of the offset and number of
+ * entries required.
+ *
+ * Return: true if offset and num_entries are valid
+ */
+static inline bool vema_mac_tbl_req_ok(struct hfi_veswport_mactable *mac_tbl)
+{
+	u16 offset, num_entries;
+	u16 req_entries = ((HFI_VNIC_EMA_DATA - sizeof(*mac_tbl)) /
+			   sizeof(mac_tbl->tbl_entries[0]));
+
+	offset = be16_to_cpu(mac_tbl->offset);
+	num_entries = be16_to_cpu(mac_tbl->num_entries);
+
+	return ((num_entries <= req_entries) &&
+		(offset + num_entries <= HFI_VNIC_MAC_TBL_MAX_ENTRIES));
+}
+
+/**
+ * vema_parms_from_recv_mad -- Get req params from recvd mad
+ * @recvd_mad: received mad
+ * @port: ptr to port struct on which MAD was recvd
+ * @adapter: ptr to ptr to adapter to be filled in
+ *
+ * Return: 0 if success, else non-zero.
+ */
+static int vema_parms_from_recv_mad(struct hfi_vnic_vema_mad *recvd_mad,
+				    struct hfi_vnic_vema_port *port,
+				    struct hfi_vnic_adapter **adapter)
+{
+	struct hfi_vnic_device *vdev;
+	u8 vport_num;
+
+	vport_num = vema_get_vport_num(recvd_mad);
+	vdev = hfi_vnic_get_dev(port->cdev, port->port_num, vport_num);
+	if (!vdev) {
+		dev_err(&port->cdev->dev,
+			"%s:vnic_num %d vdev access err\n", __func__,
+			vport_num);
+		return -EINVAL;
+	}
+	*adapter = netdev_priv(vdev->netdev);
+
+	return 0;
+}
+
+/*
+ * Return the power on default values in the port info structure
+ * in big endian format as required by MAD.
+ */
+static inline void vema_get_pod_values(struct hfi_veswport_info *port_info)
+{
+	memset(port_info, 0, sizeof(*port_info));
+	port_info->vport.max_mac_tbl_ent =
+		cpu_to_be16(HFI_VNIC_MAC_TBL_MAX_ENTRIES);
+	port_info->vport.max_smac_ent =
+		cpu_to_be16(HFI_VNIC_MAX_SMAC_LIMIT);
+	port_info->vport.oper_state = HFI_VNIC_STATE_DROP_ALL;
+	port_info->vport.config_state = HFI_VNIC_STATE_DROP_ALL;
+}
+
+/**
+ * vema_create_vnic -- Create a new vnic device
+ * @port: ptr to hfi_vnic_vema_port struct
+ * @vport_num: Vnic number (to be created)
+ * @adapter: Prt to ptr to adapter associated with vnic
+ *
+ * Create the new vnic device.
+ * Return a pointer to the adapter structure within the new vnic in
+ * the third variable.
+ */
+static int vema_create_vnic(struct hfi_vnic_vema_port *port, u8 vport_num,
+			    struct hfi_vnic_adapter **adapter)
+{
+	struct hfi_vnic_device *vdev;
+	int ret;
+
+	ret = port->cdev->ctrl_ops->add_vport(port->cdev, port->port_num,
+					      vport_num);
+	if (ret) {
+		dev_err(&port->cdev->dev,
+			"%s:vnic %d not created\n", __func__, vport_num);
+	} else {
+		vdev = hfi_vnic_get_dev(port->cdev, port->port_num, vport_num);
+		if (!vdev) {
+			dev_err(&port->cdev->dev,
+				"%s:vnic_num %d vdev access err\n", __func__,
+				vport_num);
+			ret = -ENODEV;
+		} else {
+			*adapter = netdev_priv(vdev->netdev);
+			set_bit(vport_num, port->vnic_mask);
+		}
+	}
+
+	return ret;
+}
+
+/**
+ * vema_get_class_port_info -- Get class info for port
+ * @port:  Port on whic MAD was received
+ * @recvd_mad: pointer to the received mad
+ * @rsp_mad:   pointer to respose mad
+ *
+ * This function copies the latest class port info value set for the
+ * port and stores it for generating traps
+ */
+static void vema_get_class_port_info(struct hfi_vnic_vema_port *port,
+				     struct hfi_vnic_vema_mad *recvd_mad,
+				     struct hfi_vnic_vema_mad *rsp_mad)
+{
+	struct hfi_class_port_info *port_info;
+
+	port_info = (struct hfi_class_port_info *)rsp_mad->data;
+	memcpy(port_info, &port->class_port_info, sizeof(*port_info));
+	port_info->base_version = OPA_MGMT_BASE_VERSION,
+	port_info->class_version = HFI_EMA_CLASS_VERSION;
+
+	/* Agent generates traps */
+	port_info->cap_mask = HFI_VNIC_CLASS_CAP_TRAP;
+
+	/*
+	 * Since a get routine is always sent by the EM first we
+	 * set the expected response time to
+	 * 4.096 usec * 2^18 == 1.0737 sec here.
+	 */
+	port_info->cap_mask2_resp_time = cpu_to_be32(18);
+}
+
+/**
+ * vema_set_class_port_info -- Get class info for port
+ * @port:  Port on whic MAD was received
+ * @recvd_mad: pointer to the received mad
+ * @rsp_mad:   pointer to respose mad
+ *
+ * This function updates the port class info for the specific vnic
+ * and sets up the response mad data
+ */
+static void vema_set_class_port_info(struct hfi_vnic_vema_port *port,
+				     struct hfi_vnic_vema_mad *recvd_mad,
+				     struct hfi_vnic_vema_mad *rsp_mad)
+{
+	memcpy(&port->class_port_info, recvd_mad->data,
+	       sizeof(port->class_port_info));
+
+	vema_get_class_port_info(port, recvd_mad, rsp_mad);
+}
+
+/**
+ * vema_get_veswport_info -- Get veswport info
+ * @port:      source port on which MAD was received
+ * @recvd_mad: pointer to the received mad
+ * @rsp_mad:   pointer to respose mad
+ */
+static void vema_get_veswport_info(struct hfi_vnic_vema_port *port,
+				   struct hfi_vnic_vema_mad *recvd_mad,
+				   struct hfi_vnic_vema_mad *rsp_mad)
+{
+	struct hfi_veswport_info *port_info =
+				  (struct hfi_veswport_info *)rsp_mad->data;
+	struct hfi_vnic_adapter *adapter;
+	u8 vport_num;
+
+	vport_num = vema_get_vport_num(recvd_mad);
+
+	if (test_bit(vport_num, port->vnic_mask)) {
+		if (vema_parms_from_recv_mad(recvd_mad, port, &adapter)) {
+			dev_err(&port->cdev->dev,
+				"%s:vnic adapter not found\n", __func__);
+			goto err_exit;
+		} else {
+			memset(port_info, 0, sizeof(*port_info));
+			hfi_vnic_get_vesw_info(adapter, &port_info->vesw);
+			hfi_vnic_get_per_veswport_info(adapter,
+						       &port_info->vport);
+		}
+	} else {
+		vema_get_pod_values(port_info);
+	}
+	return;
+
+err_exit:
+	rsp_mad->mad_hdr.status = HFI_VNIC_INVAL_ATTR;
+}
+
+/**
+ * vema_set_veswport_info -- Set veswport info
+ * @port:      source port on which MAD was received
+ * @recvd_mad: pointer to the received mad
+ * @rsp_mad:   pointer to respose mad
+ *
+ * This function gets the port class infor for vnic
+ */
+static void vema_set_veswport_info(struct hfi_vnic_vema_port *port,
+				   struct hfi_vnic_vema_mad *recvd_mad,
+				   struct hfi_vnic_vema_mad *rsp_mad)
+{
+	struct hfi_veswport_info *port_info;
+	struct hfi_vnic_adapter *adapter;
+	u8 vport_num;
+
+	vport_num = vema_get_vport_num(recvd_mad);
+
+	if (test_bit(vport_num, port->vnic_mask)) {
+		if (vema_parms_from_recv_mad(recvd_mad, port, &adapter))
+			goto err_exit;
+	} else if (vema_create_vnic(port, vport_num, &adapter)) {
+		dev_err(&port->cdev->dev,
+			"%s:vnic %d not created\n", __func__, vport_num);
+		goto err_exit;
+	}
+
+	port_info = (struct hfi_veswport_info *)recvd_mad->data;
+	hfi_vnic_set_vesw_info(adapter, &port_info->vesw);
+	hfi_vnic_set_per_veswport_info(adapter, &port_info->vport);
+
+	/* Process the new config settings */
+	hfi_vnic_process_vema_config(adapter);
+
+	vema_get_veswport_info(port, recvd_mad, rsp_mad);
+	return;
+
+err_exit:
+	rsp_mad->mad_hdr.status = HFI_VNIC_INVAL_ATTR;
+}
+
+/**
+ * vema_get_mac_entries -- Get MAC entries in VNIC MAC table
+ * @port:      source port on which MAD was received
+ * @recvd_mad: pointer to the received mad
+ * @rsp_mad:   pointer to respose mad
+ *
+ * This function gets the MAC entries that are programmed into
+ * the VNIC MAC forwarding table. It checks for the validity of
+ * the index into the MAC table and the number of entries that
+ * are to be retrieved.
+ */
+static void vema_get_mac_entries(struct hfi_vnic_vema_port *port,
+				 struct hfi_vnic_vema_mad *recvd_mad,
+				 struct hfi_vnic_vema_mad *rsp_mad)
+{
+	struct hfi_veswport_mactable *mac_tbl_in, *mac_tbl_out;
+	struct hfi_vnic_adapter *adapter;
+
+	if (vema_parms_from_recv_mad(recvd_mad, port, &adapter)) {
+		rsp_mad->mad_hdr.status = HFI_VNIC_INVAL_ATTR;
+		return;
+	}
+
+	mac_tbl_in = (struct hfi_veswport_mactable *)recvd_mad->data;
+	mac_tbl_out = (struct hfi_veswport_mactable *)rsp_mad->data;
+
+	if (vema_mac_tbl_req_ok(mac_tbl_in)) {
+		mac_tbl_out->offset = mac_tbl_in->offset;
+		mac_tbl_out->num_entries = mac_tbl_in->num_entries;
+		hfi_vnic_query_mac_tbl(adapter, mac_tbl_out);
+	} else {
+		rsp_mad->mad_hdr.status = HFI_VNIC_INVAL_ATTR;
+	}
+}
+
+/**
+ * vema_set_mac_entries -- Set MAC entries in VNIC MAC table
+ * @port:      source port on which MAD was received
+ * @recvd_mad: pointer to the received mad
+ * @rsp_mad:   pointer to respose mad
+ *
+ * This function sets the MAC entries in the VNIC forwarding table
+ * It checks for the validity of the index and the number of forwarding
+ * table entries to be programmed.
+ */
+static void vema_set_mac_entries(struct hfi_vnic_vema_port *port,
+				 struct hfi_vnic_vema_mad *recvd_mad,
+				 struct hfi_vnic_vema_mad *rsp_mad)
+{
+	struct hfi_veswport_mactable *mac_tbl;
+	struct hfi_vnic_adapter *adapter;
+
+	if (vema_parms_from_recv_mad(recvd_mad, port, &adapter)) {
+		rsp_mad->mad_hdr.status = HFI_VNIC_INVAL_ATTR;
+		return;
+	}
+
+	mac_tbl = (struct hfi_veswport_mactable *)recvd_mad->data;
+	if (vema_mac_tbl_req_ok(mac_tbl)) {
+		if (hfi_vnic_update_mac_tbl(adapter, mac_tbl))
+			rsp_mad->mad_hdr.status = HFI_VNIC_UNSUP_ATTR;
+	} else {
+		rsp_mad->mad_hdr.status = HFI_VNIC_UNSUP_ATTR;
+	}
+	vema_get_mac_entries(port, recvd_mad, rsp_mad);
+}
+
+/**
+ * vema_set_delete_vesw -- Reset VESW info to POD values
+ * @port:      source port on which MAD was received
+ * @recvd_mad: pointer to the received mad
+ * @rsp_mad:   pointer to respose mad
+ *
+ * This function clears all the fields of veswport info for the requested vesw
+ * and sets them back to the power-on default values. It does not delete the
+ * vesw.
+ */
+static void vema_set_delete_vesw(struct hfi_vnic_vema_port *port,
+				 struct hfi_vnic_vema_mad *recvd_mad,
+				 struct hfi_vnic_vema_mad *rsp_mad)
+{
+	struct hfi_veswport_info *port_info =
+				  (struct hfi_veswport_info *)rsp_mad->data;
+	struct hfi_vnic_adapter *adapter;
+
+	if (vema_parms_from_recv_mad(recvd_mad, port, &adapter)) {
+		rsp_mad->mad_hdr.status = HFI_VNIC_INVAL_ATTR;
+		return;
+	}
+
+	vema_get_pod_values(port_info);
+	hfi_vnic_set_vesw_info(adapter, &port_info->vesw);
+	hfi_vnic_set_per_veswport_info(adapter, &port_info->vport);
+
+	/* Process the new config settings */
+	hfi_vnic_process_vema_config(adapter);
+
+	hfi_vnic_release_mac_tbl(adapter);
+
+	vema_get_veswport_info(port, recvd_mad, rsp_mad);
+}
+
+/**
+ * vema_get_mac_list -- Get the unicast/multicast macs.
+ * @port:      source port on which MAD was received
+ * @recvd_mad: Received mad contains fields to set vnic parameters
+ * @rsp_mad:   Response mad to be built
+ * @attr_id:   Attribute ID indicating multicast or unicast mac list
+ */
+static void vema_get_mac_list(struct hfi_vnic_vema_port *port,
+			      struct hfi_vnic_vema_mad *recvd_mad,
+			      struct hfi_vnic_vema_mad *rsp_mad,
+			      u16 attr_id)
+{
+	struct hfi_veswport_iface_macs *macs_in, *macs_out;
+	int max_entries = (HFI_VNIC_EMA_DATA - sizeof(*macs_out)) / ETH_ALEN;
+	struct hfi_vnic_adapter *adapter;
+
+	if (vema_parms_from_recv_mad(recvd_mad, port, &adapter)) {
+		rsp_mad->mad_hdr.status = HFI_VNIC_INVAL_ATTR;
+		return;
+	}
+
+	macs_in = (struct hfi_veswport_iface_macs *)recvd_mad->data;
+	macs_out = (struct hfi_veswport_iface_macs *)rsp_mad->data;
+
+	macs_out->start_idx = macs_in->start_idx;
+	if (macs_in->num_macs_in_msg)
+		macs_out->num_macs_in_msg = macs_in->num_macs_in_msg;
+	else
+		macs_out->num_macs_in_msg = cpu_to_be16(max_entries);
+
+	if (attr_id == HFI_EM_ATTR_IFACE_MCAST_MACS)
+		hfi_vnic_query_mcast_macs(adapter, macs_out);
+	else
+		hfi_vnic_query_ucast_macs(adapter, macs_out);
+}
+
+/**
+ * vema_get_summary_counters -- Gets summary counters.
+ * @port:      source port on which MAD was received
+ * @recvd_mad: Received mad contains fields to set vnic parameters
+ * @rsp_mad:   Response mad to be built
+ */
+static void vema_get_summary_counters(struct hfi_vnic_vema_port *port,
+				      struct hfi_vnic_vema_mad *recvd_mad,
+				      struct hfi_vnic_vema_mad *rsp_mad)
+{
+	struct hfi_veswport_summary_counters *cntrs;
+	struct hfi_vnic_adapter *adapter;
+
+	if (vema_parms_from_recv_mad(recvd_mad, port, &adapter)) {
+		rsp_mad->mad_hdr.status = HFI_VNIC_INVAL_ATTR;
+		return;
+	}
+	cntrs = (struct hfi_veswport_summary_counters *)rsp_mad->data;
+	hfi_vnic_get_summary_counters(adapter, cntrs);
+}
+
+/**
+ * vema_get_error_counters -- Gets summary counters.
+ * @port:      source port on which MAD was received
+ * @recvd_mad: Received mad contains fields to set vnic parameters
+ * @rsp_mad:   Response mad to be built
+ */
+static void vema_get_error_counters(struct hfi_vnic_vema_port *port,
+				    struct hfi_vnic_vema_mad *recvd_mad,
+				    struct hfi_vnic_vema_mad *rsp_mad)
+{
+	struct hfi_veswport_error_counters *cntrs;
+	struct hfi_vnic_adapter *adapter;
+
+	if (vema_parms_from_recv_mad(recvd_mad, port, &adapter)) {
+		rsp_mad->mad_hdr.status = HFI_VNIC_INVAL_ATTR;
+		return;
+	}
+	cntrs = (struct hfi_veswport_error_counters *)rsp_mad->data;
+	hfi_vnic_get_error_counters(adapter, cntrs);
+}
+
+/**
+ * vema_get -- Process received get MAD
+ * @port:      source port on which MAD was received
+ * @recvd_mad: Received mad
+ * @rsp_mad:   Response mad to be built
+ */
+static void vema_get(struct hfi_vnic_vema_port *port,
+		     struct hfi_vnic_vema_mad *recvd_mad,
+		     struct hfi_vnic_vema_mad *rsp_mad)
+{
+	u16 attr_id = be16_to_cpu(recvd_mad->mad_hdr.attr_id);
+
+	switch (attr_id) {
+	case HFI_EM_ATTR_CLASS_PORT_INFO:
+		vema_get_class_port_info(port, recvd_mad, rsp_mad);
+		break;
+	case HFI_EM_ATTR_VESWPORT_INFO:
+		vema_get_veswport_info(port, recvd_mad, rsp_mad);
+		break;
+	case HFI_EM_ATTR_VESWPORT_MAC_ENTRIES:
+		vema_get_mac_entries(port, recvd_mad, rsp_mad);
+		break;
+	case HFI_EM_ATTR_IFACE_UCAST_MACS:
+		/* fall through */
+	case HFI_EM_ATTR_IFACE_MCAST_MACS:
+		vema_get_mac_list(port, recvd_mad, rsp_mad, attr_id);
+		break;
+	case HFI_EM_ATTR_VESWPORT_SUMMARY_COUNTERS:
+		vema_get_summary_counters(port, recvd_mad, rsp_mad);
+		break;
+	case HFI_EM_ATTR_VESWPORT_ERROR_COUNTERS:
+		vema_get_error_counters(port, recvd_mad, rsp_mad);
+		break;
+	default:
+		rsp_mad->mad_hdr.status = HFI_VNIC_UNSUP_ATTR;
+		break;
+	}
+}
+
+/**
+ * vema_set -- Process received set MAD
+ * @port:      source port on which MAD was received
+ * @recvd_mad: Received mad contains fields to set vnic parameters
+ * @rsp_mad:   Response mad to be built
+ */
+static void vema_set(struct hfi_vnic_vema_port *port,
+		     struct hfi_vnic_vema_mad *recvd_mad,
+		     struct hfi_vnic_vema_mad *rsp_mad)
+{
+	u16 attr_id = be16_to_cpu(recvd_mad->mad_hdr.attr_id);
+
+	switch (attr_id) {
+	case HFI_EM_ATTR_CLASS_PORT_INFO:
+		vema_set_class_port_info(port, recvd_mad, rsp_mad);
+		break;
+	case HFI_EM_ATTR_VESWPORT_INFO:
+		vema_set_veswport_info(port, recvd_mad, rsp_mad);
+		break;
+	case HFI_EM_ATTR_VESWPORT_MAC_ENTRIES:
+		vema_set_mac_entries(port, recvd_mad, rsp_mad);
+		break;
+	case HFI_EM_ATTR_DELETE_VESW:
+		vema_set_delete_vesw(port, recvd_mad, rsp_mad);
+		break;
+	default:
+		rsp_mad->mad_hdr.status = HFI_VNIC_UNSUP_ATTR;
+		break;
+	}
+}
+
+/**
+ * vema_send -- Send handler for VEMA MAD agent
+ * @mad_agent: pointer to the mad agent
+ * @mad_wc:    pointer to mad send work completion information
+ *
+ * Free all the data structures associated with the sent MAD
+ */
+static void vema_send(struct ib_mad_agent *mad_agent,
+		      struct ib_mad_send_wc *mad_wc)
+{
+	ib_destroy_ah(mad_wc->send_buf->ah);
+	ib_free_send_mad(mad_wc->send_buf);
+}
+
+/**
+ * vema_recv -- Recv handler for VEMA MAD agent
+ * @mad_agent: pointer to the mad agent
+ * @send_buf: Send buffer if found, else NULL
+ * @mad_wc:    pointer to mad send work completion information
+ *
+ * Handle only set and get methods and respond to other methods
+ * as unsupported. Allocate response buffer and address handle
+ * for the response MAD.
+ */
+static void vema_recv(struct ib_mad_agent *mad_agent,
+		      struct ib_mad_send_buf *send_buf,
+		      struct ib_mad_recv_wc *mad_wc)
+{
+	struct hfi_vnic_vema_port *port;
+	struct ib_ah              *ah;
+	struct ib_mad_send_buf    *rsp;
+	struct hfi_vnic_vema_mad  *vema_mad;
+
+	if (!mad_wc || !mad_wc->recv_buf.mad)
+		return;
+
+	port = mad_agent->context;
+	ah = ib_create_ah_from_wc(mad_agent->qp->pd, mad_wc->wc,
+				  mad_wc->recv_buf.grh, mad_agent->port_num);
+	if (IS_ERR(ah))
+		goto free_recv_mad;
+
+	rsp = ib_create_send_mad(mad_agent, mad_wc->wc->src_qp,
+				 mad_wc->wc->pkey_index, 0,
+				 IB_MGMT_VENDOR_HDR, HFI_VNIC_EMA_DATA,
+				 GFP_KERNEL, OPA_MGMT_BASE_VERSION);
+	if (IS_ERR(rsp))
+		goto err_rsp;
+
+	rsp->ah = ah;
+	vema_mad = rsp->mad;
+	memcpy(vema_mad, mad_wc->recv_buf.mad, IB_MGMT_VENDOR_HDR);
+	vema_mad->mad_hdr.method = IB_MGMT_METHOD_GET_RESP;
+	vema_mad->mad_hdr.status = 0;
+
+	/* Lock ensures network adapter is not removed */
+	mutex_lock(&port->lock);
+
+	switch (mad_wc->recv_buf.mad->mad_hdr.method) {
+	case IB_MGMT_METHOD_GET:
+		vema_get(port, (struct hfi_vnic_vema_mad *)mad_wc->recv_buf.mad,
+			 vema_mad);
+		break;
+	case IB_MGMT_METHOD_SET:
+		vema_set(port, (struct hfi_vnic_vema_mad *)mad_wc->recv_buf.mad,
+			 vema_mad);
+		break;
+	default:
+		vema_mad->mad_hdr.status = HFI_VNIC_UNSUP_ATTR;
+		break;
+	}
+	mutex_unlock(&port->lock);
+
+	if (!ib_post_send_mad(rsp, NULL)) {
+		/*
+		 * with post send successful ah and send mad
+		 * will be destroyed in send handler
+		 */
+		goto free_recv_mad;
+	}
+
+	ib_free_send_mad(rsp);
+
+err_rsp:
+	ib_destroy_ah(ah);
+free_recv_mad:
+	ib_free_recv_mad(mad_wc);
+}
+
+/**
+ * vema_get_port -- Gets the hfi_vnic_vema_port
+ * @cdev: pointer to control dev
+ * @port_num: Port number
+ *
+ * This function loops through the ports and returns
+ * the hfi_vnic_vema port structure that is associated
+ * with the HFI port number
+ *
+ * Return: ptr to requested hfi_vnic_vema_port strucure
+ *         if success, NULL if not
+ */
+static struct hfi_vnic_vema_port *
+vema_get_port(struct hfi_vnic_ctrl_device *cdev, u16 port_num)
+{
+	struct hfi_vnic_vema_port *port_base;
+
+	if (port_num > cdev->num_ports)
+		return NULL;
+
+	port_base = (struct hfi_vnic_vema_port *)dev_get_drvdata(&cdev->dev);
+	return port_base + (port_num - 1);
+}
+
+/**
+ * vema_unregister -- Unregisters agent
+ * @cdev: pointer to control device
+ *
+ * This deletes the registration by VEMA for MADs
+ */
+static void vema_unregister(struct hfi_vnic_ctrl_device *cdev)
+{
+	struct hfi_vnic_vema_port *port, *port_base;
+	int i, j;
+
+	port_base = (struct hfi_vnic_vema_port *)dev_get_drvdata(&cdev->dev);
+	for (i = 0, port = port_base; i < cdev->num_ports; i++, port++) {
+		/* Lock ensures no MAD is being processed */
+		mutex_lock(&port->lock);
+		for (j = 0; j <  HFI_MAX_VPORTS_SUPPORTED; j++) {
+			if (test_bit(j, port->vnic_mask)) {
+				port->cdev->ctrl_ops->rem_vport(cdev,
+								port->port_num,
+								j);
+				clear_bit(j, port->vnic_mask);
+			}
+		}
+		mutex_unlock(&port->lock);
+		if (port->mad_agent)
+			ib_unregister_mad_agent(port->mad_agent);
+
+		mutex_destroy(&port->lock);
+	}
+
+	kfree(port_base);
+}
+
+/**
+ * vema_register -- Registers agent
+ * @cdev: pointer to control device
+ *
+ * This function registers the handlers for the VEMA MADs
+ *
+ * Return: returns 0 on success. non zero otherwise
+ */
+static int vema_register(struct hfi_vnic_ctrl_device *cdev)
+{
+	struct hfi_vnic_vema_port *port, *port_base;
+
+	struct ib_mad_reg_req reg_req = {
+		.mgmt_class = HFI_MGMT_CLASS_INTEL_EMA,
+		.mgmt_class_version = OPA_MGMT_BASE_VERSION,
+		.oui = { INTEL_OUI_1, INTEL_OUI_2, INTEL_OUI_3 }
+	};
+	int i;
+
+	port_base = kcalloc(cdev->num_ports, sizeof(*port), GFP_KERNEL);
+	if (!port_base)
+		return -ENOMEM;
+
+	dev_set_drvdata(&cdev->dev, port_base);
+
+	set_bit(IB_MGMT_METHOD_GET, reg_req.method_mask);
+	set_bit(IB_MGMT_METHOD_SET, reg_req.method_mask);
+
+	/* register mad agent for each port on dev */
+	for (i = 0, port = port_base; i < cdev->num_ports; i++, port++) {
+		port->cdev = cdev;
+		port->port_num = i + 1;
+		mutex_init(&port->lock);
+		port->mad_agent = ib_register_mad_agent(cdev->ibdev, i + 1,
+							IB_QPT_GSI,
+							&reg_req,
+							IB_MGMT_RMPP_VERSION,
+							vema_send,
+							vema_recv,
+							port,
+							0);
+		if (IS_ERR(port->mad_agent)) {
+			int ret = PTR_ERR(port->mad_agent);
+
+			port->mad_agent = NULL;
+			vema_unregister(cdev);
+			return ret;
+		}
+	}
+
+	return 0;
+}
+
+/**
+ * hfi_vnic_vema_send_trap -- This function sends a trap to the EM
+ * @cdev: pointer to vnic control device
+ * @data: pointer to trap data filled by calling function
+ * @lid:  issuers lid (encap_slid from vesw_port_info)
+ *
+ * This function is called from the VNIC driver to send a trap if there
+ * is somethng the EM should be notified about. These events currently
+ * are
+ * 1) UNICAST INTERFACE MACADDRESS changes
+ * 2) MULTICAST INTERFACE MACADDRESS changes
+ * 3) ETHERNET LINK STATUS changes
+ * While allocating the send mad the remote site qpn used is 1
+ * as this is the well known QP.
+ *
+ */
+void hfi_vnic_vema_send_trap(struct hfi_vnic_adapter *adapter,
+			     struct __hfi_veswport_trap *data, u32 lid)
+{
+	struct hfi_vnic_ctrl_device *cdev = adapter->vdev->cdev;
+	struct ib_mad_send_buf *send_buf;
+	struct hfi_vnic_vema_port *port;
+	struct ib_device *ibp;
+	struct hfi_vnic_vema_mad_trap *trap_mad;
+	struct hfi_class_port_info *class;
+	struct ib_ah_attr ah_attr;
+	struct ib_ah *ah;
+	struct hfi_veswport_trap *trap;
+	u32 trap_lid;
+	u16 pkey_idx;
+
+	if (!cdev)
+		goto err_exit;
+	ibp = cdev->ibdev;
+	port = vema_get_port(cdev, data->hfiportnum);
+	if (!port || !port->mad_agent)
+		goto err_exit;
+
+	if (time_before(jiffies, adapter->trap_timeout)) {
+		if (adapter->trap_count == HFI_VNIC_TRAP_BURST_LIMIT) {
+			v_warn("Trap rate exceeded\n");
+			goto err_exit;
+		} else {
+			adapter->trap_count++;
+		}
+	} else {
+		adapter->trap_count = 0;
+	}
+
+	class = &port->class_port_info;
+	/* Set up address handle */
+	memset(&ah_attr, 0, sizeof(ah_attr));
+	ah_attr.sl = GET_TRAP_SL_FROM_CLASS_PORT_INFO(class->trap_sl_rsvd);
+	ah_attr.port_num = port->port_num;
+	trap_lid = be32_to_cpu(class->trap_lid);
+	/*
+	 * check for trap lid validity, must not be zero
+	 * The trap sink could change after we fashion the MAD but since traps
+	 * are not guaranteed we won't use a lock as anyway the change will take
+	 * place even with locking.
+	 */
+	if (!trap_lid) {
+		dev_err(&cdev->dev, "%s: Invalid dlid\n", __func__);
+		goto err_exit;
+	}
+
+	ah_attr.dlid = trap_lid;
+	ah = ib_create_ah(port->mad_agent->qp->pd, &ah_attr);
+	if (IS_ERR(ah)) {
+		dev_err(&cdev->dev,
+			"%s:Couldn't create new AH = %p\n", __func__, ah);
+		dev_err(&cdev->dev,
+			"%s:dlid = %d, sl = %d, port = %d\n", __func__,
+			ah_attr.dlid, ah_attr.sl, ah_attr.port_num);
+		goto err_exit;
+	}
+
+	if (ib_find_pkey(ibp, data->hfiportnum, IB_DEFAULT_PKEY_FULL,
+			 &pkey_idx) < 0) {
+		dev_err(&cdev->dev,
+			"%s:full key not found, defaulting to partial\n",
+			__func__);
+		if (ib_find_pkey(ibp, data->hfiportnum, IB_DEFAULT_PKEY_PARTIAL,
+				 &pkey_idx) < 0)
+			pkey_idx = 1;
+	}
+
+	send_buf = ib_create_send_mad(port->mad_agent, 1, pkey_idx, 0,
+				      IB_MGMT_VENDOR_HDR, IB_MGMT_MAD_DATA,
+				      GFP_KERNEL, OPA_MGMT_BASE_VERSION);
+	if (IS_ERR(send_buf)) {
+		dev_err(&cdev->dev, "%s:Couldn't allocate send buf\n",
+			__func__);
+		goto err_sndbuf;
+	}
+
+	send_buf->ah = ah;
+
+	/* Set up common MAD hdr */
+	trap_mad = send_buf->mad;
+	trap_mad->mad_hdr.base_version = OPA_MGMT_BASE_VERSION;
+	trap_mad->mad_hdr.mgmt_class = HFI_MGMT_CLASS_INTEL_EMA;
+	trap_mad->mad_hdr.class_version = HFI_EMA_CLASS_VERSION;
+	trap_mad->mad_hdr.method = IB_MGMT_METHOD_TRAP;
+	port->tid++;
+	trap_mad->mad_hdr.tid = cpu_to_be64(port->tid);
+	trap_mad->mad_hdr.attr_id = IB_SMP_ATTR_NOTICE;
+
+	/* Set up vendor OUI */
+	trap_mad->oui[0] = INTEL_OUI_1;
+	trap_mad->oui[1] = INTEL_OUI_2;
+	trap_mad->oui[2] = INTEL_OUI_3;
+
+	/* Setup notice attribute portion */
+	trap_mad->notice.gen_type = HFI_INTEL_EMA_NOTICE_TYPE_INFO << 1;
+	trap_mad->notice.oui_1 = INTEL_OUI_1;
+	trap_mad->notice.oui_2 = INTEL_OUI_2;
+	trap_mad->notice.oui_3 = INTEL_OUI_3;
+	trap_mad->notice.issuer_lid = cpu_to_be32(lid);
+
+	/* copy the actual trap data */
+	trap = (struct hfi_veswport_trap *)trap_mad->notice.raw_data;
+	trap->fabric_id = cpu_to_be16(data->fabric_id);
+	trap->veswid = cpu_to_be16(data->veswid);
+	trap->veswportnum = cpu_to_be32(data->veswportnum);
+	trap->hfiportnum = cpu_to_be16(data->hfiportnum);
+	trap->veswportindex = data->veswportindex;
+	trap->opcode = data->opcode;
+
+	/* If successful send set up rate limit timeout else bail */
+	if (ib_post_send_mad(send_buf, NULL)) {
+		ib_free_send_mad(send_buf);
+	} else {
+		if (adapter->trap_count)
+			return;
+		adapter->trap_timeout = jiffies +
+					usecs_to_jiffies(HFI_VNIC_TRAP_TIMEOUT);
+		return;
+	}
+
+err_sndbuf:
+	ib_destroy_ah(ah);
+err_exit:
+	v_err("%s: Aborting trap\n", __func__);
+}
+
+/* hfi_vnic_ctrl_drv_probe - control device initialization routine */
+static int hfi_vnic_ctrl_drv_probe(struct device *dev)
+{
+	struct hfi_vnic_ctrl_device *cdev = container_of(dev,
+					 struct hfi_vnic_ctrl_device, dev);
+	int rc;
+
+	/* Initialize hfi vnic management agent (vema) */
+	rc = vema_register(cdev);
+	if (!rc)
+		dev_info(dev, "initialized\n");
+
+	return rc;
+}
+
+/* hfi_vnic_ctrl_drv_remove - control device removal routine */
+static int hfi_vnic_ctrl_drv_remove(struct device *dev)
+{
+	struct hfi_vnic_ctrl_device *cdev = container_of(dev,
+					 struct hfi_vnic_ctrl_device, dev);
+
+	vema_unregister(cdev);
+
+	dev_info(dev, "removed\n");
+	return 0;
+}
+
+/* HFI Virtual Network Control Driver */
+static struct hfi_vnic_ctrl_driver hfi_vnic_ctrl_drv = {
+	.drvwrap = {
+		.type = HFI_VNIC_CTRL_DRV,
+		.driver = {
+			.name   = hfi_vnic_ctrl_driver_name,
+			.probe  = hfi_vnic_ctrl_drv_probe,
+			.remove = hfi_vnic_ctrl_drv_remove
+		}
+	}
+};
+
+/* hfi_vnic_vema_init - initialize vema */
+int __init hfi_vnic_vema_init(void)
+{
+	int rc;
+
+	rc = hfi_vnic_ctrl_driver_register(&hfi_vnic_ctrl_drv);
+	if (rc)
+		pr_err("VNIC ctrl driver register failed %d\n", rc);
+
+	return rc;
+}
+
+/* hfi_vnic_vema_deinit - deinitialize vema */
+void hfi_vnic_vema_deinit(void)
+{
+	hfi_vnic_ctrl_driver_unregister(&hfi_vnic_ctrl_drv);
+}
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c
index 4a87826..98ddaaf 100644
--- a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_vema_iface.c
@@ -72,7 +72,7 @@ void hfi_vnic_vema_report_event(struct hfi_vnic_adapter *adapter, u8 event)
 	trap_data.veswportindex = vdev->vport_num;
 	trap_data.opcode = event;
 
-	/* Need to send trap here */
+	hfi_vnic_vema_send_trap(adapter, &trap_data, info->vport.encap_slid);
 }
 
 /**
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
