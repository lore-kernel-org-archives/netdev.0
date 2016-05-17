From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 1/1] qed: add support for dcbx.
Date: Tue, 17 May 2016 06:44:26 -0400
Message-ID: <1463481866-4007-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39868 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751717AbcEQL1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 07:27:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary driver support for Management Firmware to
configure the device/firmware with the dcbx results. Management Firmware
is responsible for communicating the DCBX and driving the negotiation,
but the driver has responsibility of receiving async notification and
configuring the results in hw/fw. This patch also adds the dcbx support for
future protocols (e.g., FCoE) as preparation to their imminent submission.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/Makefile          |   2 +-
 drivers/net/ethernet/qlogic/qed/qed.h             |   2 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.h         |  10 +
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c        | 562 ++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h        |  80 +++
 drivers/net/ethernet/qlogic/qed/qed_dev.c         | 105 +++-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         |  21 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         |  13 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |  13 +
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |  25 +
 include/linux/qed/qed_if.h                        |   9 +
 11 files changed, 834 insertions(+), 8 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_dcbx.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_dcbx.h

diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
index a448745..d1f157e 100644
--- a/drivers/net/ethernet/qlogic/qed/Makefile
+++ b/drivers/net/ethernet/qlogic/qed/Makefile
@@ -2,5 +2,5 @@ obj-$(CONFIG_QED) := qed.o
 
 qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o \
 	 qed_int.o qed_main.o qed_mcp.o qed_sp_commands.o qed_spq.o qed_l2.o \
-	 qed_selftest.o
+	 qed_selftest.o qed_dcbx.o
 qed-$(CONFIG_QED_SRIOV) += qed_sriov.o qed_vf.o
diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 77323fc..1042f2a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -367,6 +367,8 @@ struct qed_hwfn {
 	struct qed_pf_iov		*pf_iov_info;
 	struct qed_mcp_info		*mcp_info;
 
+	struct qed_dcbx_info		*p_dcbx_info;
+
 	struct qed_hw_cid_data		*p_tx_cids;
 	struct qed_hw_cid_data		*p_rx_cids;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.h b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
index 078ff3f..234c0fa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
@@ -131,6 +131,16 @@ void qed_cxt_hw_init_pf(struct qed_hwfn *p_hwfn);
 void qed_qm_init_pf(struct qed_hwfn *p_hwfn);
 
 /**
+ * @brief Reconfigures QM pf on the fly
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ *
+ * @return int
+ */
+int qed_qm_reconf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
+
+/**
  * @brief qed_cxt_release - Release a cid
  *
  * @param p_hwfn
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
new file mode 100644
index 0000000..cbf58e1
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -0,0 +1,562 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <linux/bitops.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include "qed.h"
+#include "qed_cxt.h"
+#include "qed_dcbx.h"
+#include "qed_hsi.h"
+#include "qed_sp.h"
+
+#define QED_DCBX_MAX_MIB_READ_TRY       (100)
+#define QED_ETH_TYPE_DEFAULT            (0)
+#define QED_ETH_TYPE_ROCE               (0x8915)
+#define QED_UDP_PORT_TYPE_ROCE_V2       (0x12B7)
+#define QED_ETH_TYPE_FCOE               (0x8906)
+#define QED_TCP_PORT_ISCSI              (0xCBC)
+
+#define QED_DCBX_INVALID_PRIORITY       0xFF
+
+/* Get Traffic Class from priority traffic class table, 4 bits represent
+ * the traffic class corresponding to the priority.
+ */
+#define QED_DCBX_PRIO2TC(prio_tc_tbl, prio) \
+	((u32)(prio_tc_tbl >> ((7 - prio) * 4)) & 0x7)
+
+static const struct qed_dcbx_app_metadata qed_dcbx_app_update[] = {
+	{DCBX_PROTOCOL_ISCSI, "ISCSI", QED_PCI_DEFAULT},
+	{DCBX_PROTOCOL_FCOE, "FCOE", QED_PCI_DEFAULT},
+	{DCBX_PROTOCOL_ROCE, "ROCE", QED_PCI_DEFAULT},
+	{DCBX_PROTOCOL_ROCE_V2, "ROCE_V2", QED_PCI_DEFAULT},
+	{DCBX_PROTOCOL_ETH, "ETH", QED_PCI_ETH}
+};
+
+static bool qed_dcbx_app_ethtype(u32 app_info_bitmap)
+{
+	return !!(QED_MFW_GET_FIELD(app_info_bitmap, DCBX_APP_SF) ==
+		  DCBX_APP_SF_ETHTYPE);
+}
+
+static bool qed_dcbx_app_port(u32 app_info_bitmap)
+{
+	return !!(QED_MFW_GET_FIELD(app_info_bitmap, DCBX_APP_SF) ==
+		  DCBX_APP_SF_PORT);
+}
+
+static bool qed_dcbx_default_tlv(u32 app_info_bitmap, u16 proto_id)
+{
+	return !!(qed_dcbx_app_ethtype(app_info_bitmap) &&
+		  proto_id == QED_ETH_TYPE_DEFAULT);
+}
+
+static bool qed_dcbx_iscsi_tlv(u32 app_info_bitmap, u16 proto_id)
+{
+	return !!(qed_dcbx_app_port(app_info_bitmap) &&
+		  proto_id == QED_TCP_PORT_ISCSI);
+}
+
+static bool qed_dcbx_fcoe_tlv(u32 app_info_bitmap, u16 proto_id)
+{
+	return !!(qed_dcbx_app_ethtype(app_info_bitmap) &&
+		  proto_id == QED_ETH_TYPE_FCOE);
+}
+
+static bool qed_dcbx_roce_tlv(u32 app_info_bitmap, u16 proto_id)
+{
+	return !!(qed_dcbx_app_ethtype(app_info_bitmap) &&
+		  proto_id == QED_ETH_TYPE_ROCE);
+}
+
+static bool qed_dcbx_roce_v2_tlv(u32 app_info_bitmap, u16 proto_id)
+{
+	return !!(qed_dcbx_app_port(app_info_bitmap) &&
+		  proto_id == QED_UDP_PORT_TYPE_ROCE_V2);
+}
+
+static void
+qed_dcbx_dp_protocol(struct qed_hwfn *p_hwfn, struct qed_dcbx_results *p_data)
+{
+	enum dcbx_protocol_type id;
+	int i;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_DCB, "DCBX negotiated: %d\n",
+		   p_data->dcbx_enabled);
+
+	for (i = 0; i < ARRAY_SIZE(qed_dcbx_app_update); i++) {
+		id = qed_dcbx_app_update[i].id;
+
+		DP_VERBOSE(p_hwfn, QED_MSG_DCB,
+			   "%s info: update %d, enable %d, prio %d, tc %d, num_tc %d\n",
+			   qed_dcbx_app_update[i].name, p_data->arr[id].update,
+			   p_data->arr[id].enable, p_data->arr[id].priority,
+			   p_data->arr[id].tc, p_hwfn->hw_info.num_tc);
+	}
+}
+
+static void
+qed_dcbx_set_params(struct qed_dcbx_results *p_data,
+		    struct qed_hw_info *p_info,
+		    bool enable,
+		    bool update,
+		    u8 prio,
+		    u8 tc,
+		    enum dcbx_protocol_type type,
+		    enum qed_pci_personality personality)
+{
+	/* PF update ramrod data */
+	p_data->arr[type].update = update;
+	p_data->arr[type].enable = enable;
+	p_data->arr[type].priority = prio;
+	p_data->arr[type].tc = tc;
+
+	/* QM reconf data */
+	if (p_info->personality == personality) {
+		if (personality == QED_PCI_ETH)
+			p_info->non_offload_tc = tc;
+		else
+			p_info->offload_tc = tc;
+	}
+}
+
+/* Update app protocol data and hw_info fields with the TLV info */
+static void
+qed_dcbx_update_app_info(struct qed_dcbx_results *p_data,
+			 struct qed_hwfn *p_hwfn,
+			 bool enable,
+			 bool update,
+			 u8 prio, u8 tc, enum dcbx_protocol_type type)
+{
+	struct qed_hw_info *p_info = &p_hwfn->hw_info;
+	enum qed_pci_personality personality;
+	enum dcbx_protocol_type id;
+	char *name;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(qed_dcbx_app_update); i++) {
+		id = qed_dcbx_app_update[i].id;
+
+		if (type != id)
+			continue;
+
+		personality = qed_dcbx_app_update[i].personality;
+		name = qed_dcbx_app_update[i].name;
+
+		qed_dcbx_set_params(p_data, p_info, enable, update,
+				    prio, tc, type, personality);
+	}
+}
+
+static bool
+qed_dcbx_get_app_protocol_type(struct qed_hwfn *p_hwfn,
+			       u32 app_prio_bitmap,
+			       u16 id, enum dcbx_protocol_type *type)
+{
+	if (qed_dcbx_fcoe_tlv(app_prio_bitmap, id)) {
+		*type = DCBX_PROTOCOL_FCOE;
+	} else if (qed_dcbx_roce_tlv(app_prio_bitmap, id)) {
+		*type = DCBX_PROTOCOL_ROCE;
+	} else if (qed_dcbx_iscsi_tlv(app_prio_bitmap, id)) {
+		*type = DCBX_PROTOCOL_ISCSI;
+	} else if (qed_dcbx_default_tlv(app_prio_bitmap, id)) {
+		*type = DCBX_PROTOCOL_ETH;
+	} else if (qed_dcbx_roce_v2_tlv(app_prio_bitmap, id)) {
+		*type = DCBX_PROTOCOL_ROCE_V2;
+	} else {
+		*type = DCBX_MAX_PROTOCOL_TYPE;
+		DP_ERR(p_hwfn,
+		       "No action required, App TLV id = 0x%x app_prio_bitmap = 0x%x\n",
+		       id, app_prio_bitmap);
+		return false;
+	}
+
+	return true;
+}
+
+/* Parse app TLV's to update TC information in hw_info structure for
+ * reconfiguring QM. Get protocol specific data for PF update ramrod command.
+ */
+static int
+qed_dcbx_process_tlv(struct qed_hwfn *p_hwfn,
+		     struct qed_dcbx_results *p_data,
+		     struct dcbx_app_priority_entry *p_tbl,
+		     u32 pri_tc_tbl, int count, bool dcbx_enabled)
+{
+	u8 tc, priority, priority_map;
+	enum dcbx_protocol_type type;
+	u16 protocol_id;
+	bool enable;
+	int i;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_DCB, "Num APP entries = %d\n", count);
+
+	/* Parse APP TLV */
+	for (i = 0; i < count; i++) {
+		protocol_id = QED_MFW_GET_FIELD(p_tbl[i].entry,
+						DCBX_APP_PROTOCOL_ID);
+		priority_map = QED_MFW_GET_FIELD(p_tbl[i].entry,
+						 DCBX_APP_PRI_MAP);
+		priority = ffs(priority_map) - 1;
+		if (priority < 0) {
+			DP_ERR(p_hwfn, "Invalid priority\n");
+			return -EINVAL;
+		}
+
+		tc = QED_DCBX_PRIO2TC(pri_tc_tbl, priority);
+		if (qed_dcbx_get_app_protocol_type(p_hwfn, p_tbl[i].entry,
+						   protocol_id, &type)) {
+			/* ETH always have the enable bit reset, as it gets
+			 * vlan information per packet. For other protocols,
+			 * should be set according to the dcbx_enabled
+			 * indication, but we only got here if there was an
+			 * app tlv for the protocol, so dcbx must be enabled.
+			 */
+			enable = !!(type == DCBX_PROTOCOL_ETH);
+
+			qed_dcbx_update_app_info(p_data, p_hwfn, enable, true,
+						 priority, tc, type);
+		}
+	}
+
+	/* If RoCE-V2 TLV is not detected, driver need to use RoCE app
+	 * data for RoCE-v2 not the default app data.
+	 */
+	if (!p_data->arr[DCBX_PROTOCOL_ROCE_V2].update &&
+	    p_data->arr[DCBX_PROTOCOL_ROCE].update) {
+		tc = p_data->arr[DCBX_PROTOCOL_ROCE].tc;
+		priority = p_data->arr[DCBX_PROTOCOL_ROCE].priority;
+		qed_dcbx_update_app_info(p_data, p_hwfn, true, true,
+					 priority, tc, DCBX_PROTOCOL_ROCE_V2);
+	}
+
+	/* Update ramrod protocol data and hw_info fields
+	 * with default info when corresponding APP TLV's are not detected.
+	 * The enabled field has a different logic for ethernet as only for
+	 * ethernet dcb should disabled by default, as the information arrives
+	 * from the OS (unless an explicit app tlv was present).
+	 */
+	tc = p_data->arr[DCBX_PROTOCOL_ETH].tc;
+	priority = p_data->arr[DCBX_PROTOCOL_ETH].priority;
+	for (type = 0; type < DCBX_MAX_PROTOCOL_TYPE; type++) {
+		if (p_data->arr[type].update)
+			continue;
+
+		enable = (type == DCBX_PROTOCOL_ETH) ? false : dcbx_enabled;
+		qed_dcbx_update_app_info(p_data, p_hwfn, enable, true,
+					 priority, tc, type);
+	}
+
+	return 0;
+}
+
+/* Parse app TLV's to update TC information in hw_info structure for
+ * reconfiguring QM. Get protocol specific data for PF update ramrod command.
+ */
+static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
+{
+	struct dcbx_app_priority_feature *p_app;
+	struct dcbx_app_priority_entry *p_tbl;
+	struct qed_dcbx_results data = { 0 };
+	struct dcbx_ets_feature *p_ets;
+	struct qed_hw_info *p_info;
+	u32 pri_tc_tbl, flags;
+	bool dcbx_enabled;
+	int num_entries;
+	int rc = 0;
+
+	/* If DCBx version is non zero, then negotiation was
+	 * successfuly performed
+	 */
+	flags = p_hwfn->p_dcbx_info->operational.flags;
+	dcbx_enabled = !!QED_MFW_GET_FIELD(flags, DCBX_CONFIG_VERSION);
+
+	p_app = &p_hwfn->p_dcbx_info->operational.features.app;
+	p_tbl = p_app->app_pri_tbl;
+
+	p_ets = &p_hwfn->p_dcbx_info->operational.features.ets;
+	pri_tc_tbl = p_ets->pri_tc_tbl[0];
+
+	p_info = &p_hwfn->hw_info;
+	num_entries = QED_MFW_GET_FIELD(p_app->flags, DCBX_APP_NUM_ENTRIES);
+
+	rc = qed_dcbx_process_tlv(p_hwfn, &data, p_tbl, pri_tc_tbl,
+				  num_entries, dcbx_enabled);
+	if (rc)
+		return rc;
+
+	p_info->num_tc = QED_MFW_GET_FIELD(p_ets->flags, DCBX_ETS_MAX_TCS);
+	data.pf_id = p_hwfn->rel_pf_id;
+	data.dcbx_enabled = dcbx_enabled;
+
+	qed_dcbx_dp_protocol(p_hwfn, &data);
+
+	memcpy(&p_hwfn->p_dcbx_info->results, &data,
+	       sizeof(struct qed_dcbx_results));
+
+	return 0;
+}
+
+static int
+qed_dcbx_copy_mib(struct qed_hwfn *p_hwfn,
+		  struct qed_ptt *p_ptt,
+		  struct qed_dcbx_mib_meta_data *p_data,
+		  enum qed_mib_read_type type)
+{
+	u32 prefix_seq_num, suffix_seq_num;
+	int read_count = 0;
+	int rc = 0;
+
+	/* The data is considered to be valid only if both sequence numbers are
+	 * the same.
+	 */
+	do {
+		if (type == QED_DCBX_REMOTE_LLDP_MIB) {
+			qed_memcpy_from(p_hwfn, p_ptt, p_data->lldp_remote,
+					p_data->addr, p_data->size);
+			prefix_seq_num = p_data->lldp_remote->prefix_seq_num;
+			suffix_seq_num = p_data->lldp_remote->suffix_seq_num;
+		} else {
+			qed_memcpy_from(p_hwfn, p_ptt, p_data->mib,
+					p_data->addr, p_data->size);
+			prefix_seq_num = p_data->mib->prefix_seq_num;
+			suffix_seq_num = p_data->mib->suffix_seq_num;
+		}
+		read_count++;
+
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_DCB,
+			   "mib type = %d, try count = %d prefix seq num  = %d suffix seq num = %d\n",
+			   type, read_count, prefix_seq_num, suffix_seq_num);
+	} while ((prefix_seq_num != suffix_seq_num) &&
+		 (read_count < QED_DCBX_MAX_MIB_READ_TRY));
+
+	if (read_count >= QED_DCBX_MAX_MIB_READ_TRY) {
+		DP_ERR(p_hwfn,
+		       "MIB read err, mib type = %d, try count = %d prefix seq num = %d suffix seq num = %d\n",
+		       type, read_count, prefix_seq_num, suffix_seq_num);
+		rc = -EIO;
+	}
+
+	return rc;
+}
+
+static int
+qed_dcbx_read_local_lldp_mib(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	struct qed_dcbx_mib_meta_data data;
+	int rc = 0;
+
+	memset(&data, 0, sizeof(data));
+	data.addr = p_hwfn->mcp_info->port_addr + offsetof(struct public_port,
+							   lldp_config_params);
+	data.lldp_local = p_hwfn->p_dcbx_info->lldp_local;
+	data.size = sizeof(struct lldp_config_params_s);
+	qed_memcpy_from(p_hwfn, p_ptt, data.lldp_local, data.addr, data.size);
+
+	return rc;
+}
+
+static int
+qed_dcbx_read_remote_lldp_mib(struct qed_hwfn *p_hwfn,
+			      struct qed_ptt *p_ptt,
+			      enum qed_mib_read_type type)
+{
+	struct qed_dcbx_mib_meta_data data;
+	int rc = 0;
+
+	memset(&data, 0, sizeof(data));
+	data.addr = p_hwfn->mcp_info->port_addr + offsetof(struct public_port,
+							   lldp_status_params);
+	data.lldp_remote = p_hwfn->p_dcbx_info->lldp_remote;
+	data.size = sizeof(struct lldp_status_params_s);
+	rc = qed_dcbx_copy_mib(p_hwfn, p_ptt, &data, type);
+
+	return rc;
+}
+
+static int
+qed_dcbx_read_operational_mib(struct qed_hwfn *p_hwfn,
+			      struct qed_ptt *p_ptt,
+			      enum qed_mib_read_type type)
+{
+	struct qed_dcbx_mib_meta_data data;
+	int rc = 0;
+
+	memset(&data, 0, sizeof(data));
+	data.addr = p_hwfn->mcp_info->port_addr +
+		    offsetof(struct public_port, operational_dcbx_mib);
+	data.mib = &p_hwfn->p_dcbx_info->operational;
+	data.size = sizeof(struct dcbx_mib);
+	rc = qed_dcbx_copy_mib(p_hwfn, p_ptt, &data, type);
+
+	return rc;
+}
+
+static int
+qed_dcbx_read_remote_mib(struct qed_hwfn *p_hwfn,
+			 struct qed_ptt *p_ptt, enum qed_mib_read_type type)
+{
+	struct qed_dcbx_mib_meta_data data;
+	int rc = 0;
+
+	memset(&data, 0, sizeof(data));
+	data.addr = p_hwfn->mcp_info->port_addr +
+		    offsetof(struct public_port, remote_dcbx_mib);
+	data.mib = &p_hwfn->p_dcbx_info->remote;
+	data.size = sizeof(struct dcbx_mib);
+	rc = qed_dcbx_copy_mib(p_hwfn, p_ptt, &data, type);
+
+	return rc;
+}
+
+static int
+qed_dcbx_read_local_mib(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	struct qed_dcbx_mib_meta_data data;
+	int rc = 0;
+
+	memset(&data, 0, sizeof(data));
+	data.addr = p_hwfn->mcp_info->port_addr +
+		    offsetof(struct public_port, local_admin_dcbx_mib);
+	data.local_admin = &p_hwfn->p_dcbx_info->local_admin;
+	data.size = sizeof(struct dcbx_local_params);
+	qed_memcpy_from(p_hwfn, p_ptt, data.local_admin, data.addr, data.size);
+
+	return rc;
+}
+
+static int qed_dcbx_read_mib(struct qed_hwfn *p_hwfn,
+			     struct qed_ptt *p_ptt, enum qed_mib_read_type type)
+{
+	int rc = -EINVAL;
+
+	switch (type) {
+	case QED_DCBX_OPERATIONAL_MIB:
+		rc = qed_dcbx_read_operational_mib(p_hwfn, p_ptt, type);
+		break;
+	case QED_DCBX_REMOTE_MIB:
+		rc = qed_dcbx_read_remote_mib(p_hwfn, p_ptt, type);
+		break;
+	case QED_DCBX_LOCAL_MIB:
+		rc = qed_dcbx_read_local_mib(p_hwfn, p_ptt);
+		break;
+	case QED_DCBX_REMOTE_LLDP_MIB:
+		rc = qed_dcbx_read_remote_lldp_mib(p_hwfn, p_ptt, type);
+		break;
+	case QED_DCBX_LOCAL_LLDP_MIB:
+		rc = qed_dcbx_read_local_lldp_mib(p_hwfn, p_ptt);
+		break;
+	default:
+		DP_ERR(p_hwfn, "MIB read err, unknown mib type %d\n", type);
+	}
+
+	return rc;
+}
+
+/* Read updated MIB.
+ * Reconfigure QM and invoke PF update ramrod command if operational MIB
+ * change is detected.
+ */
+int
+qed_dcbx_mib_update_event(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt, enum qed_mib_read_type type)
+{
+	int rc = 0;
+
+	rc = qed_dcbx_read_mib(p_hwfn, p_ptt, type);
+	if (rc)
+		return rc;
+
+	if (type == QED_DCBX_OPERATIONAL_MIB) {
+		rc = qed_dcbx_process_mib_info(p_hwfn);
+		if (!rc) {
+			/* reconfigure tcs of QM queues according
+			 * to negotiation results
+			 */
+			qed_qm_reconf(p_hwfn, p_ptt);
+
+			/* update storm FW with negotiation results */
+			qed_sp_pf_update(p_hwfn);
+		}
+	}
+
+	return rc;
+}
+
+int qed_dcbx_info_alloc(struct qed_hwfn *p_hwfn)
+{
+	int rc = 0;
+
+	p_hwfn->p_dcbx_info = kzalloc(sizeof(*p_hwfn->p_dcbx_info), GFP_KERNEL);
+	if (!p_hwfn->p_dcbx_info) {
+		DP_NOTICE(p_hwfn,
+			  "Failed to allocate 'struct qed_dcbx_info'\n");
+		rc = -ENOMEM;
+	}
+
+	return rc;
+}
+
+void qed_dcbx_info_free(struct qed_hwfn *p_hwfn,
+			struct qed_dcbx_info *p_dcbx_info)
+{
+	kfree(p_hwfn->p_dcbx_info);
+}
+
+static void qed_dcbx_update_protocol_data(struct protocol_dcb_data *p_data,
+					  struct qed_dcbx_results *p_src,
+					  enum dcbx_protocol_type type)
+{
+	p_data->dcb_enable_flag = p_src->arr[type].enable;
+	p_data->dcb_priority = p_src->arr[type].priority;
+	p_data->dcb_tc = p_src->arr[type].tc;
+}
+
+/* Set pf update ramrod command params */
+void qed_dcbx_set_pf_update_params(struct qed_dcbx_results *p_src,
+				   struct pf_update_ramrod_data *p_dest)
+{
+	struct protocol_dcb_data *p_dcb_data;
+	bool update_flag = false;
+
+	p_dest->pf_id = p_src->pf_id;
+
+	update_flag = p_src->arr[DCBX_PROTOCOL_FCOE].update;
+	p_dest->update_fcoe_dcb_data_flag = update_flag;
+
+	update_flag = p_src->arr[DCBX_PROTOCOL_ROCE].update;
+	p_dest->update_roce_dcb_data_flag = update_flag;
+	update_flag = p_src->arr[DCBX_PROTOCOL_ROCE_V2].update;
+	p_dest->update_roce_dcb_data_flag = update_flag;
+
+	update_flag = p_src->arr[DCBX_PROTOCOL_ISCSI].update;
+	p_dest->update_iscsi_dcb_data_flag = update_flag;
+	update_flag = p_src->arr[DCBX_PROTOCOL_ETH].update;
+	p_dest->update_eth_dcb_data_flag = update_flag;
+
+	p_dcb_data = &p_dest->fcoe_dcb_data;
+	qed_dcbx_update_protocol_data(p_dcb_data, p_src, DCBX_PROTOCOL_FCOE);
+	p_dcb_data = &p_dest->roce_dcb_data;
+
+	if (p_src->arr[DCBX_PROTOCOL_ROCE].update)
+		qed_dcbx_update_protocol_data(p_dcb_data, p_src,
+					      DCBX_PROTOCOL_ROCE);
+	if (p_src->arr[DCBX_PROTOCOL_ROCE_V2].update)
+		qed_dcbx_update_protocol_data(p_dcb_data, p_src,
+					      DCBX_PROTOCOL_ROCE_V2);
+
+	p_dcb_data = &p_dest->iscsi_dcb_data;
+	qed_dcbx_update_protocol_data(p_dcb_data, p_src, DCBX_PROTOCOL_ISCSI);
+	p_dcb_data = &p_dest->eth_dcb_data;
+	qed_dcbx_update_protocol_data(p_dcb_data, p_src, DCBX_PROTOCOL_ETH);
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.h b/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
new file mode 100644
index 0000000..e7f834d
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
@@ -0,0 +1,80 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_DCBX_H
+#define _QED_DCBX_H
+#include <linux/types.h>
+#include <linux/slab.h>
+#include "qed.h"
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_mcp.h"
+#include "qed_reg_addr.h"
+
+#define DCBX_CONFIG_MAX_APP_PROTOCOL    4
+
+enum qed_mib_read_type {
+	QED_DCBX_OPERATIONAL_MIB,
+	QED_DCBX_REMOTE_MIB,
+	QED_DCBX_LOCAL_MIB,
+	QED_DCBX_REMOTE_LLDP_MIB,
+	QED_DCBX_LOCAL_LLDP_MIB
+};
+
+struct qed_dcbx_app_data {
+	bool enable;		/* DCB enabled */
+	bool update;		/* Update indication */
+	u8 priority;		/* Priority */
+	u8 tc;			/* Traffic Class */
+};
+
+struct qed_dcbx_results {
+	bool dcbx_enabled;
+	u8 pf_id;
+	struct qed_dcbx_app_data arr[DCBX_MAX_PROTOCOL_TYPE];
+};
+
+struct qed_dcbx_app_metadata {
+	enum dcbx_protocol_type id;
+	char *name;
+	enum qed_pci_personality personality;
+};
+
+#define QED_MFW_GET_FIELD(name, field) \
+	(((name) & (field ## _MASK)) >> (field ## _SHIFT))
+
+struct qed_dcbx_info {
+	struct lldp_status_params_s lldp_remote[LLDP_MAX_LLDP_AGENTS];
+	struct lldp_config_params_s lldp_local[LLDP_MAX_LLDP_AGENTS];
+	struct dcbx_local_params local_admin;
+	struct qed_dcbx_results results;
+	struct dcbx_mib operational;
+	struct dcbx_mib remote;
+	u8 dcbx_cap;
+};
+
+struct qed_dcbx_mib_meta_data {
+	struct lldp_config_params_s *lldp_local;
+	struct lldp_status_params_s *lldp_remote;
+	struct dcbx_local_params *local_admin;
+	struct dcbx_mib *mib;
+	size_t size;
+	u32 addr;
+};
+
+/* QED local interface routines */
+int
+qed_dcbx_mib_update_event(struct qed_hwfn *,
+			  struct qed_ptt *, enum qed_mib_read_type);
+
+int qed_dcbx_info_alloc(struct qed_hwfn *p_hwfn);
+void qed_dcbx_info_free(struct qed_hwfn *, struct qed_dcbx_info *);
+void qed_dcbx_set_pf_update_params(struct qed_dcbx_results *p_src,
+				   struct pf_update_ramrod_data *p_dest);
+
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 6fb6016..089016f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -22,6 +22,7 @@
 #include <linux/qed/qed_if.h>
 #include "qed.h"
 #include "qed_cxt.h"
+#include "qed_dcbx.h"
 #include "qed_dev_api.h"
 #include "qed_hsi.h"
 #include "qed_hw.h"
@@ -33,6 +34,9 @@
 #include "qed_sriov.h"
 #include "qed_vf.h"
 
+static spinlock_t qm_lock;
+static bool qm_lock_init = false;
+
 /* API common to all protocols */
 enum BAR_ID {
 	BAR_ID_0,       /* used for GRC */
@@ -147,6 +151,7 @@ void qed_resc_free(struct qed_dev *cdev)
 		qed_int_free(p_hwfn);
 		qed_iov_free(p_hwfn);
 		qed_dmae_info_free(p_hwfn);
+		qed_dcbx_info_free(p_hwfn, p_hwfn->p_dcbx_info);
 	}
 }
 
@@ -200,13 +205,19 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
 	vport_id = (u8)RESC_START(p_hwfn, QED_VPORT);
 
 	/* First init per-TC PQs */
-	for (i = 0; i < multi_cos_tcs; i++, curr_queue++) {
+	for (i = 0; i < multi_cos_tcs; i++) {
 		struct init_qm_pq_params *params =
-		    &qm_info->qm_pq_params[curr_queue];
+		    &qm_info->qm_pq_params[curr_queue++];
 
-		params->vport_id = vport_id;
-		params->tc_id = p_hwfn->hw_info.non_offload_tc;
-		params->wrr_group = 1;
+		if (p_hwfn->hw_info.personality == QED_PCI_ETH) {
+			params->vport_id = vport_id;
+			params->tc_id = p_hwfn->hw_info.non_offload_tc;
+			params->wrr_group = 1;
+		} else {
+			params->vport_id = vport_id;
+			params->tc_id = p_hwfn->hw_info.offload_tc;
+			params->wrr_group = 1;
+		}
 	}
 
 	/* Then init pure-LB PQ */
@@ -266,6 +277,63 @@ alloc_err:
 	return -ENOMEM;
 }
 
+/* This function reconfigures the QM pf on the fly.
+ * For this purpose we:
+ * 1. reconfigure the QM database
+ * 2. set new values to runtime arrat
+ * 3. send an sdm_qm_cmd through the rbc interface to stop the QM
+ * 4. activate init tool in QM_PF stage
+ * 5. send an sdm_qm_cmd through rbc interface to release the QM
+ */
+int qed_qm_reconf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
+	bool b_rc;
+	int rc;
+
+	/* qm_info is allocated in qed_init_qm_info() which is already called
+	 * from qed_resc_alloc() or previous call of qed_qm_reconf().
+	 * The allocated size may change each init, so we free it before next
+	 * allocation.
+	 */
+	qed_qm_info_free(p_hwfn);
+
+	/* initialize qed's qm data structure */
+	rc = qed_init_qm_info(p_hwfn);
+	if (rc)
+		return rc;
+
+	/* stop PF's qm queues */
+	spin_lock_bh(&qm_lock);
+	b_rc = qed_send_qm_stop_cmd(p_hwfn, p_ptt, false, true,
+				    qm_info->start_pq, qm_info->num_pqs);
+	spin_unlock_bh(&qm_lock);
+	if (!b_rc)
+		return -EINVAL;
+
+	/* clear the QM_PF runtime phase leftovers from previous init */
+	qed_init_clear_rt_data(p_hwfn);
+
+	/* prepare QM portion of runtime array */
+	qed_qm_init_pf(p_hwfn);
+
+	/* activate init tool on runtime array */
+	rc = qed_init_run(p_hwfn, p_ptt, PHASE_QM_PF, p_hwfn->rel_pf_id,
+			  p_hwfn->hw_info.hw_mode);
+	if (rc)
+		return rc;
+
+	/* start PF's qm queues */
+	spin_lock_bh(&qm_lock);
+	b_rc = qed_send_qm_stop_cmd(p_hwfn, p_ptt, true, true,
+				    qm_info->start_pq, qm_info->num_pqs);
+	spin_unlock_bh(&qm_lock);
+	if (!b_rc)
+		return -EINVAL;
+
+	return 0;
+}
+
 int qed_resc_alloc(struct qed_dev *cdev)
 {
 	struct qed_consq *p_consq;
@@ -375,6 +443,14 @@ int qed_resc_alloc(struct qed_dev *cdev)
 				  "Failed to allocate memory for dmae_info structure\n");
 			goto alloc_err;
 		}
+
+		/* DCBX initialization */
+		rc = qed_dcbx_info_alloc(p_hwfn);
+		if (rc) {
+			DP_NOTICE(p_hwfn,
+				  "Failed to allocate memory for dcbx structure\n");
+			goto alloc_err;
+		}
 	}
 
 	cdev->reset_stats = kzalloc(sizeof(*cdev->reset_stats), GFP_KERNEL);
@@ -780,6 +856,11 @@ int qed_hw_init(struct qed_dev *cdev,
 		p_hwfn->first_on_engine = (load_code ==
 					   FW_MSG_CODE_DRV_LOAD_ENGINE);
 
+		if (!qm_lock_init) {
+			spin_lock_init(&qm_lock);
+			qm_lock_init = true;
+		}
+
 		switch (load_code) {
 		case FW_MSG_CODE_DRV_LOAD_ENGINE:
 			rc = qed_hw_init_common(p_hwfn, p_hwfn->p_main_ptt,
@@ -821,6 +902,20 @@ int qed_hw_init(struct qed_dev *cdev,
 			return mfw_rc;
 		}
 
+		/* send DCBX attention request command */
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_DCB,
+			   "sending phony dcbx set command to trigger DCBx attention handling\n");
+		mfw_rc = qed_mcp_cmd(p_hwfn, p_hwfn->p_main_ptt,
+				     DRV_MSG_CODE_SET_DCBX,
+				     1 << DRV_MB_PARAM_DCBX_NOTIFY_SHIFT,
+				     &load_code, &param);
+		if (mfw_rc) {
+			DP_NOTICE(p_hwfn,
+				  "Failed to send DCBX attention request\n");
+			return mfw_rc;
+		}
+
 		p_hwfn->hw_init_done = true;
 	}
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 82b7727..9afc15f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -634,6 +634,14 @@ struct pf_start_ramrod_data {
 	u8				reserved0[4];
 };
 
+/* Data for port update ramrod */
+struct protocol_dcb_data {
+	u8 dcb_enable_flag;
+	u8 dcb_priority;
+	u8 dcb_tc;
+	u8 reserved;
+};
+
 /* tunnel configuration */
 struct pf_update_tunnel_config {
 	u8	update_rx_pf_clss;
@@ -656,8 +664,17 @@ struct pf_update_tunnel_config {
 };
 
 struct pf_update_ramrod_data {
-	u32				reserved[2];
-	u32				reserved_1[6];
+	u8 pf_id;
+	u8 update_eth_dcb_data_flag;
+	u8 update_fcoe_dcb_data_flag;
+	u8 update_iscsi_dcb_data_flag;
+	u8 update_roce_dcb_data_flag;
+	u8 update_mf_vlan_flag;
+	__le16 mf_vlan;
+	struct protocol_dcb_data eth_dcb_data;
+	struct protocol_dcb_data fcoe_dcb_data;
+	struct protocol_dcb_data iscsi_dcb_data;
+	struct protocol_dcb_data roce_dcb_data;
 	struct pf_update_tunnel_config	tunnel_config;
 };
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 2be943b..1182361 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -15,6 +15,7 @@
 #include <linux/spinlock.h>
 #include <linux/string.h>
 #include "qed.h"
+#include "qed_dcbx.h"
 #include "qed_hsi.h"
 #include "qed_hw.h"
 #include "qed_mcp.h"
@@ -825,6 +826,18 @@ int qed_mcp_handle_events(struct qed_hwfn *p_hwfn,
 		case MFW_DRV_MSG_VF_DISABLED:
 			qed_mcp_handle_vf_flr(p_hwfn, p_ptt);
 			break;
+		case MFW_DRV_MSG_LLDP_DATA_UPDATED:
+			qed_dcbx_mib_update_event(p_hwfn, p_ptt,
+						  QED_DCBX_REMOTE_LLDP_MIB);
+			break;
+		case MFW_DRV_MSG_DCBX_REMOTE_MIB_UPDATED:
+			qed_dcbx_mib_update_event(p_hwfn, p_ptt,
+						  QED_DCBX_REMOTE_MIB);
+			break;
+		case MFW_DRV_MSG_DCBX_OPERATIONAL_MIB_UPDATED:
+			qed_dcbx_mib_update_event(p_hwfn, p_ptt,
+						  QED_DCBX_OPERATIONAL_MIB);
+			break;
 		case MFW_DRV_MSG_TRANSCEIVER_STATE_CHANGE:
 			qed_mcp_handle_transceiver_change(p_hwfn, p_ptt);
 			break;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index ab5549f..ea4e9ce 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -354,6 +354,19 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 		    enum qed_mf_mode mode, bool allow_npar_tx_switch);
 
 /**
+ * @brief qed_sp_pf_update - PF Function Update Ramrod
+ *
+ * This ramrod updates function-related parameters. Every parameter can be
+ * updated independently, according to configuration flags.
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+
+int qed_sp_pf_update(struct qed_hwfn *p_hwfn);
+
+/**
  * @brief qed_sp_pf_stop - PF Function Stop Ramrod
  *
  * This ramrod is sent to close a Physical Function (PF). It is the last ramrod
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 8c555ed..67f6ce3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -15,6 +15,7 @@
 #include "qed.h"
 #include <linux/qed/qed_chain.h>
 #include "qed_cxt.h"
+#include "qed_dcbx.h"
 #include "qed_hsi.h"
 #include "qed_hw.h"
 #include "qed_int.h"
@@ -384,6 +385,30 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+int qed_sp_pf_update(struct qed_hwfn *p_hwfn)
+{
+	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
+	int rc = -EINVAL;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_CB;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 COMMON_RAMROD_PF_UPDATE, PROTOCOLID_COMMON,
+				 &init_data);
+	if (rc)
+		return rc;
+
+	qed_dcbx_set_pf_update_params(&p_hwfn->p_dcbx_info->results,
+				      &p_ent->ramrod.pf_update);
+
+	return qed_spq_post(p_hwfn, p_ent, NULL);
+}
+
 /* Set pf update ramrod command params */
 int qed_sp_pf_update_tunn_cfg(struct qed_hwfn *p_hwfn,
 			      struct qed_tunn_update_params *p_tunn,
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 0fd8f24..4c29439 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -25,6 +25,15 @@
 #include <linux/qed/common_hsi.h>
 #include <linux/qed/qed_chain.h>
 
+enum dcbx_protocol_type {
+	DCBX_PROTOCOL_ISCSI,
+	DCBX_PROTOCOL_FCOE,
+	DCBX_PROTOCOL_ROCE,
+	DCBX_PROTOCOL_ROCE_V2,
+	DCBX_PROTOCOL_ETH,
+	DCBX_MAX_PROTOCOL_TYPE
+};
+
 enum qed_led_mode {
 	QED_LED_MODE_OFF,
 	QED_LED_MODE_ON,
-- 
1.8.3.1
