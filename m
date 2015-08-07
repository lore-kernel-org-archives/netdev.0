From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 2/6] qlcnic: Add support to enable capability to extend minidump for iSCSI
Date: Fri, 7 Aug 2015 07:17:03 -0400
Message-ID: <1438946227-11426-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:24097 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752900AbbHGMCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 08:02:55 -0400
In-Reply-To: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

In some cases it is required to capture minidump for iSCSI functions
as part of default minidump collection process. To enable this, firmware
exports it's capability and driver need to enable that capability
by issuing a mailbox command.

With this feature, firmware can provide additional iSCSI function's
minidump with smaller minidump capture mask (0x1f).

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   26 ++++++++++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |   32 ++++++++++++++++++++
 5 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index c6dca5d..a861592 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -924,6 +924,7 @@ struct qlcnic_mac_vlan_list {
 #define QLCNIC_FW_CAPABILITY_SET_DRV_VER	BIT_5
 #define QLCNIC_FW_CAPABILITY_2_BEACON		BIT_7
 #define QLCNIC_FW_CAPABILITY_2_PER_PORT_ESWITCH_CFG	BIT_9
+#define QLCNIC_FW_CAPABILITY_2_EXT_ISCSI_DUMP	BIT_13
 
 #define QLCNIC_83XX_FW_CAPAB_ENCAP_RX_OFFLOAD	BIT_0
 #define QLCNIC_83XX_FW_CAPAB_ENCAP_TX_OFFLOAD	BIT_1
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 172192d..5ab3adf 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -119,6 +119,7 @@ static const struct qlcnic_mailbox_metadata qlcnic_83xx_mbx_tbl[] = {
 	{QLCNIC_CMD_DCB_QUERY_CAP, 1, 2},
 	{QLCNIC_CMD_DCB_QUERY_PARAM, 1, 50},
 	{QLCNIC_CMD_SET_INGRESS_ENCAP, 2, 1},
+	{QLCNIC_CMD_83XX_EXTEND_ISCSI_DUMP_CAP, 4, 1},
 };
 
 const u32 qlcnic_83xx_ext_reg_tbl[] = {
@@ -3514,6 +3515,31 @@ out:
 	qlcnic_free_mbx_args(&cmd);
 }
 
+#define QLCNIC_83XX_ADD_PORT0		BIT_0
+#define QLCNIC_83XX_ADD_PORT1		BIT_1
+#define QLCNIC_83XX_EXTENDED_MEM_SIZE	13 /* In MB */
+int qlcnic_83xx_extend_md_capab(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_cmd_args cmd;
+	int err;
+
+	err = qlcnic_alloc_mbx_args(&cmd, adapter,
+				    QLCNIC_CMD_83XX_EXTEND_ISCSI_DUMP_CAP);
+	if (err)
+		return err;
+
+	cmd.req.arg[1] = (QLCNIC_83XX_ADD_PORT0 | QLCNIC_83XX_ADD_PORT1);
+	cmd.req.arg[2] = QLCNIC_83XX_EXTENDED_MEM_SIZE;
+	cmd.req.arg[3] = QLCNIC_83XX_EXTENDED_MEM_SIZE;
+
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err)
+		dev_err(&adapter->pdev->dev,
+			"failed to issue extend iSCSI minidump capability\n");
+
+	return err;
+}
+
 int qlcnic_83xx_reg_test(struct qlcnic_adapter *adapter)
 {
 	u32 major, minor, sub;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 999a90e..331ae2c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -627,6 +627,7 @@ int qlcnic_83xx_set_port_eswitch_status(struct qlcnic_adapter *, int, int *);
 
 void qlcnic_83xx_get_minidump_template(struct qlcnic_adapter *);
 void qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter, u64 *data);
+int qlcnic_83xx_extend_md_capab(struct qlcnic_adapter *);
 int qlcnic_83xx_get_settings(struct qlcnic_adapter *, struct ethtool_cmd *);
 int qlcnic_83xx_set_settings(struct qlcnic_adapter *, struct ethtool_cmd *);
 void qlcnic_83xx_get_pauseparam(struct qlcnic_adapter *,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index cbe2399..4bb33af 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -109,6 +109,7 @@ enum qlcnic_regs {
 #define QLCNIC_CMD_GET_LED_CONFIG		0x6A
 #define QLCNIC_CMD_83XX_SET_DRV_VER		0x6F
 #define QLCNIC_CMD_ADD_RCV_RINGS		0x0B
+#define QLCNIC_CMD_83XX_EXTEND_ISCSI_DUMP_CAP	0x37
 
 #define QLCNIC_INTRPT_INTX			1
 #define QLCNIC_INTRPT_MSIX			3
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index 6f33e2d..aca47fd 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -1396,19 +1396,51 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
+static inline bool
+qlcnic_83xx_md_check_extended_dump_capability(struct qlcnic_adapter *adapter)
+{
+	/* For special adapters (with 0x8830 device ID), where iSCSI firmware
+	 * dump needs to be captured as part of regular firmware dump
+	 * collection process, firmware exports it's capability through
+	 * capability registers
+	 */
+	return ((adapter->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE8830) &&
+		(adapter->ahw->extra_capability[0] &
+		 QLCNIC_FW_CAPABILITY_2_EXT_ISCSI_DUMP));
+}
+
 void qlcnic_83xx_get_minidump_template(struct qlcnic_adapter *adapter)
 {
 	u32 prev_version, current_version;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_fw_dump *fw_dump = &ahw->fw_dump;
 	struct pci_dev *pdev = adapter->pdev;
+	bool extended = false;
 
 	prev_version = adapter->fw_version;
 	current_version = qlcnic_83xx_get_fw_version(adapter);
 
 	if (fw_dump->tmpl_hdr == NULL || current_version > prev_version) {
 		vfree(fw_dump->tmpl_hdr);
+
+		if (qlcnic_83xx_md_check_extended_dump_capability(adapter))
+			extended = !qlcnic_83xx_extend_md_capab(adapter);
+
 		if (!qlcnic_fw_cmd_get_minidump_temp(adapter))
 			dev_info(&pdev->dev, "Supports FW dump capability\n");
+
+		/* Once we have minidump template with extended iSCSI dump
+		 * capability, update the minidump capture mask to 0x1f as
+		 * per FW requirement
+		 */
+		if (extended) {
+			struct qlcnic_83xx_dump_template_hdr *hdr;
+
+			hdr = fw_dump->tmpl_hdr;
+			hdr->drv_cap_mask = 0x1f;
+			fw_dump->cap_mask = 0x1f;
+			dev_info(&pdev->dev,
+				 "Extended iSCSI dump capability and updated capture mask to 0x1f\n");
+		}
 	}
 }
-- 
1.5.6
