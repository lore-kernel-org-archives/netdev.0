From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 10/12] qlcnic: register dump utility
Date: Fri, 31 Aug 2012 18:36:57 -0400
Message-ID: <1346452619-2129-11-git-send-email-sony.chacko@qlogic.com>
References: <1346452619-2129-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:38798 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755188Ab2HaWx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 18:53:57 -0400
In-Reply-To: <1346452619-2129-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Modify 82xx driver to support new adapter - Qlogic 83XX CNA
Common register dump utility for 82xx and 83xx adapters

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/Makefile        |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  115 ++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   10 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    4 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   14 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   16 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   26 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  230 +++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |  863 ++++++++++++++++++++
 12 files changed, 1101 insertions(+), 183 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c

diff --git a/drivers/net/ethernet/qlogic/qlcnic/Makefile b/drivers/net/ethernet/qlogic/qlcnic/Makefile
index 8de2dc7..6d60bae 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/Makefile
+++ b/drivers/net/ethernet/qlogic/qlcnic/Makefile
@@ -7,4 +7,4 @@ obj-$(CONFIG_QLCNIC) := qlcnic.o
 qlcnic-y := qlcnic_hw.o qlcnic_main.o qlcnic_init.o \
 	qlcnic_ethtool.o qlcnic_ctx.o qlcnic_io.o \
 	qlcnic_83xx_hw.o qlcnic_83xx_init.o \
-	qlcnic_83xx_vnic.o
+	qlcnic_83xx_vnic.o qlcnic_minidump.o
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 5f9cae5..5ca57d7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -230,8 +230,8 @@ struct rcv_desc {
 #define STATUS_OWNER_PHANTOM	(0x2ULL << 56)
 
 /* Status descriptor:
-   0-3 port, 4-7 status, 8-11 type, 12-27 total_length
-   28-43 reference_handle, 44-47 protocol, 48-52 pkt_offset
+   0-3 rsvd, 4-7 status, 8-11 type, 12-27 total_length
+   28-43 reference_handle, 44-47 rsvd, 48-52 pkt_offset
    53-55 desc_cnt, 56-57 owner, 58-63 opcode
  */
 #define qlcnic_get_sts_port(sts_data)	\
@@ -254,7 +254,7 @@ struct rcv_desc {
 	(((sts_data) >> 58) & 0x03F)
 
 #define qlcnic_get_lro_sts_refhandle(sts_data) 	\
-	((sts_data) & 0x0FFFF)
+	((sts_data) & 0x07FFF)
 #define qlcnic_get_lro_sts_length(sts_data)	\
 	(((sts_data) >> 16) & 0x0FFFF)
 #define qlcnic_get_lro_sts_l2_hdr_offset(sts_data)	\
@@ -476,12 +476,14 @@ struct qlcnic_dump_template_hdr {
 	__le32	sys_info[3];
 	__le32	saved_state[16];
 	__le32	cap_sizes[8];
+	__le32  ocm_wnd_reg[16];
 	__le32	rsvd[0];
 };
 
 struct qlcnic_fw_dump {
 	u8	clr;	/* flag to indicate if dump is cleared */
 	u8	enable; /* enable/disable dump */
+	u32     pos;    /* position in the dump buffer */
 	u32	size;	/* total size of the dump */
 	void	*data;	/* dump data area */
 	struct	qlcnic_dump_template_hdr *tmpl_hdr;
@@ -533,7 +535,7 @@ struct qlcnic_hardware_context {
 	u16 max_tx_ques;
 	u16 max_rx_ques;
 	u16 max_mtu;
-	u16 msg_enable;
+	u32 msg_enable;
 	u16 act_pci_func;
 
 	u32 capabilities;
@@ -671,41 +673,6 @@ struct qlcnic_recv_context {
  */
 #define QLCNIC_CDRP_FORM_CMD(cmd)	(QLCNIC_CDRP_CMD_BIT | (cmd))
 
-#define QLCNIC_CDRP_CMD_READ_MAX_RDS_PER_CTX    0x00000002
-#define QLCNIC_CDRP_CMD_READ_MAX_SDS_PER_CTX    0x00000003
-#define QLCNIC_CDRP_CMD_READ_MAX_RULES_PER_CTX  0x00000004
-#define QLCNIC_CDRP_CMD_READ_MAX_RX_CTX         0x00000005
-#define QLCNIC_CDRP_CMD_READ_MAX_TX_CTX         0x00000006
-#define QLCNIC_CDRP_CMD_CREATE_RX_CTX           0x00000007
-#define QLCNIC_CDRP_CMD_DESTROY_RX_CTX          0x00000008
-#define QLCNIC_CDRP_CMD_CREATE_TX_CTX           0x00000009
-#define QLCNIC_CDRP_CMD_DESTROY_TX_CTX          0x0000000a
-#define QLCNIC_CDRP_CMD_INTRPT_TEST		0x00000011
-#define QLCNIC_CDRP_CMD_SET_MTU                 0x00000012
-#define QLCNIC_CDRP_CMD_READ_PHY		0x00000013
-#define QLCNIC_CDRP_CMD_WRITE_PHY		0x00000014
-#define QLCNIC_CDRP_CMD_READ_HW_REG		0x00000015
-#define QLCNIC_CDRP_CMD_GET_FLOW_CTL		0x00000016
-#define QLCNIC_CDRP_CMD_SET_FLOW_CTL		0x00000017
-#define QLCNIC_CDRP_CMD_READ_MAX_MTU		0x00000018
-#define QLCNIC_CDRP_CMD_READ_MAX_LRO		0x00000019
-#define QLCNIC_CDRP_CMD_MAC_ADDRESS		0x0000001f
-
-#define QLCNIC_CDRP_CMD_GET_PCI_INFO		0x00000020
-#define QLCNIC_CDRP_CMD_GET_NIC_INFO		0x00000021
-#define QLCNIC_CDRP_CMD_SET_NIC_INFO		0x00000022
-#define QLCNIC_CDRP_CMD_GET_ESWITCH_CAPABILITY	0x00000024
-#define QLCNIC_CDRP_CMD_TOGGLE_ESWITCH		0x00000025
-#define QLCNIC_CDRP_CMD_GET_ESWITCH_STATUS	0x00000026
-#define QLCNIC_CDRP_CMD_SET_PORTMIRRORING	0x00000027
-#define QLCNIC_CDRP_CMD_CONFIGURE_ESWITCH	0x00000028
-#define QLCNIC_CDRP_CMD_GET_ESWITCH_PORT_CONFIG	0x00000029
-#define QLCNIC_CDRP_CMD_GET_ESWITCH_STATS	0x0000002a
-#define QLCNIC_CDRP_CMD_CONFIG_PORT		0x0000002E
-#define QLCNIC_CDRP_CMD_TEMP_SIZE		0x0000002f
-#define QLCNIC_CDRP_CMD_GET_TEMP_HDR		0x00000030
-#define QLCNIC_CDRP_CMD_GET_MAC_STATS		0x00000037
-
 #define QLCNIC_RCODE_SUCCESS		0
 #define QLCNIC_RCODE_INVALID_ARGS	6
 #define QLCNIC_RCODE_NOT_SUPPORTED	9
@@ -917,7 +884,7 @@ struct qlcnic_mac_list_s {
  */
 
 #define QLCNIC_C2H_OPCODE_CONFIG_LOOPBACK		0x8f
-#define QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	141
+#define QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	0x8D
 
 #define VPORT_MISS_MODE_DROP		0 /* drop all unmatched */
 #define VPORT_MISS_MODE_ACCEPT_ALL	1 /* accept all packets */
@@ -1043,6 +1010,7 @@ struct qlcnic_ipaddr {
 #define __QLCNIC_AER			5
 #define __QLCNIC_DIAG_RES_ALLOC		6
 #define __QLCNIC_LED_ENABLE		7
+#define __QLCNIC_ELB_INPROGRESS         8
 
 #define QLCNIC_INTERRUPT_TEST		1
 #define QLCNIC_LOOPBACK_TEST		2
@@ -1226,7 +1194,8 @@ struct qlcnic_eswitch {
 
 
 /* Return codes for Error handling */
-#define QL_STATUS_INVALID_PARAM	-1
+#define QL_STATUS_INVALID_PARAM		-1
+#define QL_STATUS_UNSUPPORTED_CMD	-2
 
 #define MAX_BW			100	/* % of link speed */
 #define MAX_VLAN_ID		4095
@@ -1446,16 +1415,55 @@ struct __queue {
 	u8	rsvd3[2];
 } __packed;
 
+struct __pollrd {
+	__le32	sel_addr;
+	__le32	read_addr;
+	__le32	sel_val;
+	__le16	sel_val_stride;
+	__le16	no_ops;
+	__le32	poll_wait;
+	__le32	poll_mask;
+	__le32	data_size;
+	u8	rsvd[4];
+} __packed;
+
+struct __mux2 {
+	__le32	sel_addr1;
+	__le32	sel_addr2;
+	__le32	sel_val1;
+	__le32	sel_val2;
+	__le32	no_ops;
+	__le32	sel_val_mask;
+	__le32	read_addr;
+	u8	sel_val_stride;
+	u8	data_size;
+	u8	rsvd[2];
+} __packed;
+
+struct __pollrdmwr {
+	__le32	addr1;
+	__le32	addr2;
+	__le32	val1;
+	__le32	val2;
+	__le32	poll_wait;
+	__le32	poll_mask;
+	__le32	mod_mask;
+	__le32	data_size;
+} __packed;
+
 struct qlcnic_dump_entry {
 	struct qlcnic_common_entry_hdr hdr;
 	union {
-		struct __crb	crb;
-		struct __cache	cache;
-		struct __ocm	ocm;
-		struct __mem	mem;
-		struct __mux	mux;
-		struct __queue	que;
-		struct __ctrl	ctrl;
+		struct __crb		crb;
+		struct __cache		cache;
+		struct __ocm		ocm;
+		struct __mem		mem;
+		struct __mux		mux;
+		struct __queue		que;
+		struct __ctrl		ctrl;
+		struct __pollrdmwr	pollrdmwr;
+		struct __mux2		mux2;
+		struct __pollrd		pollrd;
 	} region;
 } __packed;
 
@@ -1475,6 +1483,9 @@ enum op_codes {
 	QLCNIC_DUMP_L2_ITAG	= 22,
 	QLCNIC_DUMP_L2_DATA	= 23,
 	QLCNIC_DUMP_L2_INST	= 24,
+	QLCNIC_DUMP_POLL_RD	= 35,
+	QLCNIC_READ_MUX2	= 36,
+	QLCNIC_READ_POLLRDMWR	= 37,
 	QLCNIC_DUMP_READ_ROM	= 71,
 	QLCNIC_DUMP_READ_MEM	= 72,
 	QLCNIC_DUMP_READ_CTRL	= 98,
@@ -1518,6 +1529,7 @@ struct qlcnic_cmd_args {
 	struct _cdrp_cmd rsp;
 };
 
+int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter);
 int qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config);
 int qlcnic_pci_mem_write_2M(struct qlcnic_adapter *, u64 off, u64 data);
 int qlcnic_pci_mem_read_2M(struct qlcnic_adapter *, u64 off, u64 *data);
@@ -1558,6 +1570,7 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
 void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
 void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
+int qlcnic_dump_fw(struct qlcnic_adapter *);
 void qlcnic_get_ocm_win(struct qlcnic_hardware_context *);
 
 /* Functions from qlcnic_init.c */
@@ -1604,7 +1617,9 @@ void qlcnic_set_multi(struct net_device *netdev);
 void qlcnic_free_mac_list(struct qlcnic_adapter *adapter);
 
 int qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu);
+int qlcnic_fw_cmd_set_drv_version(struct qlcnic_adapter *);
 int qlcnic_change_mtu(struct net_device *netdev, int new_mtu);
+int qlcnic_fw_cmd_set_drv_version(struct qlcnic_adapter *);
 netdev_features_t qlcnic_fix_features(struct net_device *netdev,
 	netdev_features_t features);
 int qlcnic_set_features(struct net_device *netdev, netdev_features_t features);
@@ -1620,8 +1635,8 @@ int qlcnic_reset_context(struct qlcnic_adapter *);
 void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings);
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test);
 netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
-int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data);
-int qlcnic_validate_max_rss(struct net_device *netdev, u8, u8);
+int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t);
+int qlcnic_validate_max_rss(u8, u8);
 
 void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 37ca75f..b4e8e46 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -137,6 +137,8 @@ static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 	.get_func_no = qlcnic_83xx_get_func_no,
 	.api_lock = qlcnic_83xx_cam_lock,
 	.api_unlock = qlcnic_83xx_cam_unlock,
+	.add_sysfs = qlcnic_83xx_add_sysfs,
+	.remove_sysfs = qlcnic_83xx_remove_sysfs,
 	.process_lb_rcv_ring_diag = qlcnic_83xx_process_rcv_ring_diag,
 	.create_rx_ctx = qlcnic_83xx_create_rx_ctx,
 	.create_tx_ctx = qlcnic_83xx_create_tx_ctx,
@@ -160,6 +162,8 @@ static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 static struct qlcnic_nic_template qlcnic_83xx_ops = {
 	.config_bridged_mode = qlcnic_config_bridged_mode,
 	.config_led = qlcnic_config_led,
+	.request_reset = qlcnic_83xx_idc_request_reset,
+	.cancel_idc_work = qlcnic_83xx_idc_exit,
 	.napi_add = qlcnic_83xx_napi_add,
 	.config_ipaddr = qlcnic_83xx_config_ipaddr,
 	.clear_legacy_intr = qlcnic_83xx_clear_legacy_intr,
@@ -1106,6 +1110,9 @@ qlcnic_83xx_mbx_op(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
 		dev_info(&adapter->pdev->dev,
 			"Mailbox not available, 0x%x, collect FW dump\n",
 			mbx_val);
+		/* Take FW dump */
+		qlcnic_83xx_idc_request_reset(adapter,
+			QLCNIC_FORCE_FW_DUMP_KEY);
 		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
 		spin_unlock_irqrestore(&ahw->mbx_lock, flags);
 
@@ -1182,6 +1189,9 @@ poll:
 		dev_info(&adapter->pdev->dev,
 			"MBX command 0x%x timed out\n", opcode);
 		qlcnic_dump_mbx(adapter, cmd);
+		/* Take FW dump */
+		qlcnic_83xx_idc_request_reset(adapter,
+			QLCNIC_FORCE_FW_DUMP_KEY);
 	}
 	/* clear fw mbx control register */
 	QLCWRX(ahw, QLCNIC_FW_MBX_CTRL, QLCNIC_CLR_OWNER);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 3446a46..ccd2c64 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -8,6 +8,7 @@
 #define IS_QLC_83XX_USED(a, b, c)	\
 	(((1 << a->portnum) & b) || ((c >> 6) & 0x1))
 
+#define QLC_83XX_BAR0_LENGTH    0x4000
 /* Directly mapped registers */
 #define QLC_83XX_CRB_WIN_BASE		0x3800
 #define QLC_83XX_CRB_WIN_FUNC(f)	(QLC_83XX_CRB_WIN_BASE+((f)*4))
@@ -622,4 +623,7 @@ void qlcnic_83xx_register_map(struct qlcnic_hardware_context *);
 void qlcnic_83xx_idc_aen_work(struct work_struct *);
 void qlcnic_83xx_config_ipaddr(struct qlcnic_adapter *, __be32, int);
 void qlcnic_83xx_get_minidump_template(struct qlcnic_adapter *);
+void qlcnic_83xx_idc_exit(struct qlcnic_adapter *);
+void qlcnic_83xx_idc_request_reset(struct qlcnic_adapter *, u32);
+
 #endif
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index d7031f8..4b5f584 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1785,10 +1785,16 @@ qlcnic_83xx_load_fw_image_from_host(struct qlcnic_adapter *adapter)
 
 int qlcnic_83xx_restart_hw(struct qlcnic_adapter *adapter)
 {
+	u32 val;
 	int err = -EIO;
 
 	qlcnic_83xx_stop_hw(adapter);
 
+	/* Collect FW register dump if required */
+	val = QLCRDX(adapter->ahw, QLC_83XX_IDC_CTRL);
+	if (!(val & QLC_83XX_IDC_GRACEFULL_RESET))
+		qlcnic_dump_fw(adapter);
+
 	qlcnic_83xx_init_hw(adapter);
 	if (qlcnic_83xx_copy_bootloader(adapter))
 		return err;
@@ -1820,9 +1826,8 @@ int qlcnic_83xx_restart_hw(struct qlcnic_adapter *adapter)
 int qlcnic_83xx_config_default_opmode(struct qlcnic_adapter *adapter)
 {
 	u32 op_mode;
-	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	ahw->hw_ops->get_func_no(adapter);
+	qlcnic_get_func_no(adapter);
 	op_mode = QLCRDX(adapter->ahw, QLC_83XX_DRV_OP_MODE);
 
 	if (op_mode == QLC_83XX_DEFAULT_OPMODE) {
@@ -1843,7 +1848,7 @@ int qlcnic_83xx_get_nic_configuration(struct qlcnic_adapter *adapter)
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	memset(&nic_info, 0, sizeof(struct qlcnic_info));
-	err = ahw->hw_ops->get_nic_info(adapter, &nic_info, ahw->pci_func);
+	err = qlcnic_get_nic_info(adapter, &nic_info, ahw->pci_func);
 	if (err)
 		return -EIO;
 
@@ -1909,6 +1914,7 @@ qlcnic_83xx_init_default_driver(struct qlcnic_adapter *adapter)
 {
 	int err = -EIO;
 
+	qlcnic_83xx_get_minidump_template(adapter);
 	if (qlcnic_83xx_get_port_info(adapter))
 		return err;
 
@@ -1943,7 +1949,7 @@ qlcnic_83xx_clear_function_resources(struct qlcnic_adapter *adapter)
 		qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_STOP_NIC_FUNC);
 		cmd.req.arg[1] = cpu_to_le32(0 | BIT_31);
 
-		status = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+		status = qlcnic_issue_cmd(adapter, &cmd);
 
 		if (status) {
 			dev_err(&adapter->pdev->dev,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index ab843d8..d362814 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -217,7 +217,7 @@ qlcnic_83xx_config_vnic_opmode(struct qlcnic_adapter *adapter)
 	u32 op_mode, priv_level;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	ahw->hw_ops->get_func_no(adapter);
+	qlcnic_get_func_no(adapter);
 
 	op_mode = QLCRDX(adapter->ahw, QLC_83XX_DRV_OP_MODE);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 6fc4451..76e46a5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -39,6 +39,7 @@ static const struct qlcnic_mailbox_metadata qlcnic_mbx_tbl[] = {
 	{ QLCNIC_CMD_CONFIG_PORT, 4, 1 },
 	{ QLCNIC_CMD_TEMP_SIZE, 4, 4 },
 	{ QLCNIC_CMD_GET_TEMP_HDR, 4, 1 },
+	{ QLCNIC_CMD_SET_DRV_VER, 4, 1 },
 };
 
 /* Allocate mailbox incoming and outgoing registers. It should be used with a
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 85d281e..3a0cbc6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -525,21 +525,7 @@ static void qlcnic_get_channels(struct net_device *dev,
 static int qlcnic_set_channels(struct net_device *dev,
 		struct ethtool_channels *channel)
 {
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	int err;
-
-	if (channel->other_count || channel->combined_count ||
-	    channel->tx_count != channel->max_tx)
-		return -EINVAL;
-
-	err = qlcnic_validate_max_rss(dev, channel->max_rx, channel->rx_count);
-	if (err)
-		return err;
-
-	err = qlcnic_set_max_rss(adapter, channel->rx_count);
-	netdev_info(dev, "allocated 0x%x sds rings\n",
-				 adapter->max_sds_rings);
-	return err;
+	return 0;
 }
 
 static void
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 743300b..85f1c08 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -856,6 +856,32 @@ int qlcnic_change_mtu(struct net_device *netdev, int mtu)
 	return rc;
 }
 
+int
+qlcnic_fw_cmd_set_drv_version(struct qlcnic_adapter *adapter)
+{
+	int err = 0;
+	struct qlcnic_cmd_args cmd;
+	char drv_string[12];
+
+	memset(drv_string, 0 , sizeof(drv_string));
+	snprintf(drv_string, sizeof(drv_string), "%d"".""%d"".""%d",
+		_QLCNIC_LINUX_MAJOR, _QLCNIC_LINUX_MINOR,
+			_QLCNIC_LINUX_SUBVERSION);
+
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_SET_DRV_VER);
+	memcpy(&cmd.req.arg[1], drv_string, sizeof(u32));
+	memcpy(&cmd.req.arg[2], drv_string + 4, sizeof(u32));
+	memcpy(&cmd.req.arg[3], drv_string + 8, sizeof(u32));
+
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err) {
+		dev_err(&adapter->pdev->dev, "Failed to drv ver in fw\n");
+		err = -EIO;
+	}
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
 
 netdev_features_t qlcnic_fix_features(struct net_device *netdev,
 	netdev_features_t features)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index 168df18..09689ad 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -122,6 +122,7 @@ struct qlcnic_ms_reg_ctrl {
 #define QLCNIC_CMD_TEMP_SIZE			0x2f
 #define QLCNIC_CMD_GET_TEMP_HDR			0x30
 #define QLCNIC_CMD_GET_MAC_STATS		0x37
+#define QLCNIC_CMD_SET_DRV_VER                  0x38
 #define QLCNIC_CMD_CONFIGURE_RSS		0x41
 #define QLCNIC_CMD_CONFIG_INTR_COAL		0x43
 #define QLCNIC_CMD_CONFIGURE_LED		0x44
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index afe7753..86f425b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -76,11 +76,6 @@ static void qlcnic_fw_poll_work(struct work_struct *work);
 static void qlcnic_poll_controller(struct net_device *netdev);
 #endif
 
-static void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter);
-static void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter);
-static void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter);
-static void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter);
-
 static void qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding);
 static void qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8);
 static int qlcnic_can_start_firmware(struct qlcnic_adapter *adapter);
@@ -100,6 +95,8 @@ static int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
 static int qlcnicvf_start_firmware(struct qlcnic_adapter *);
 static void qlcnic_set_netdev_features(struct qlcnic_adapter *,
 				struct qlcnic_esw_func_cfg *);
+static void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter);
+static void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter);
 
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
@@ -873,6 +870,9 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 				adapter->fw_version > prev_fw_version) {
 			if (fw_dump->tmpl_hdr)
 				vfree(fw_dump->tmpl_hdr);
+			if (!qlcnic_fw_cmd_get_minidump_temp(adapter))
+				dev_info(&pdev->dev,
+					"Supports FW dump capability\n");
 		}
 	}
 
@@ -1929,11 +1929,13 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	if ((QLCNIC_IS_82XX(adapter)) && (adapter->ahw->capabilities &
-			QLCNIC_FW_CAPABILITY_MORE_CAPS)) {
+					QLCNIC_FW_CAPABILITY_MORE_CAPS)) {
 		capab2 = QLCRD32(adapter, CRB_FW_CAPABILITIES_2, &err);
+		if (capab2 & QLCNIC_FW_CAPABILITY_2_OCBB)
+			qlcnic_fw_cmd_set_drv_version(adapter);
 	}
 
-	err = ahw->hw_ops->setup_intr(adapter, 0);
+	err = qlcnic_setup_intr(adapter, 0);
 	if (err)
 		goto err_out_disable_msi;
 
@@ -2634,7 +2636,12 @@ skip_ack_check:
 		}
 
 		qlcnic_api_unlock(adapter);
-
+		rtnl_lock();
+		if (adapter->flags & QLCNIC_FW_RESET_OWNER) {
+			qlcnic_dump_fw(adapter);
+			adapter->flags |= QLCNIC_FW_HANG;
+		}
+		rtnl_unlock();
 
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
 		if (!qlcnic_start_firmware(adapter)) {
@@ -3152,7 +3159,7 @@ qlcnicvf_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 	return -EOPNOTSUPP;
 }
 
-int qlcnic_82xx_validate_max_rss(u8 max_hw, u8 val)
+int qlcnic_validate_max_rss(u8 max_hw, u8 val)
 {
 	u32 max_allowed;
 
@@ -3173,7 +3180,7 @@ int qlcnic_82xx_validate_max_rss(u8 max_hw, u8 val)
 }
 
 int
-qlcnic_82xx_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t len)
+qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t len)
 {
 	int err;
 	struct net_device *netdev = adapter->netdev;
@@ -3260,6 +3267,7 @@ qlcnic_show_bridged_mode(struct device *dev,
 
 	return snprintf(buf, sizeof(int), "%d\n", bridged_mode);
 }
+
 static struct device_attribute dev_attr_bridged_mode = {
 	.attr = {.name = "bridged_mode", .mode = (S_IRUGO | S_IWUSR)},
 	.show = qlcnic_show_bridged_mode,
@@ -3288,7 +3296,7 @@ qlcnic_show_diag_mode(struct device *dev,
 {
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 
-	return sprintf(buf, "%d\n",
+	return snprintf(buf, sizeof(u32), "%d\n",
 			!!(adapter->flags & QLCNIC_DIAG_ENABLED));
 }
 
@@ -3298,55 +3306,6 @@ static struct device_attribute dev_attr_diag_mode = {
 	.store = qlcnic_store_diag_mode,
 };
 
-int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val)
-{
-	if (!use_msi_x && !use_msi) {
-		netdev_info(netdev, "no msix or msi support, hence no rss\n");
-		return -EINVAL;
-	}
-
-	if ((val > max_hw) || (val <  2) || !is_power_of_2(val)) {
-		netdev_info(netdev, "rss_ring valid range [2 - %x] in "
-			" powers of 2\n", max_hw);
-		return -EINVAL;
-	}
-	return 0;
-
-}
-
-int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data)
-{
-	struct net_device *netdev = adapter->netdev;
-	int err = 0;
-
-	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-		return -EBUSY;
-
-	netif_device_detach(netdev);
-	if (netif_running(netdev))
-		__qlcnic_down(adapter, netdev);
-	qlcnic_detach(adapter);
-	qlcnic_teardown_intr(adapter);
-
-	err = qlcnic_setup_intr(adapter, data);
-	if (err)
-		netdev_info(netdev, "failed setting max_rss; rss disabled\n");
-
-	if (netif_running(netdev)) {
-		err = qlcnic_attach(adapter);
-		if (err)
-			goto done;
-		err = __qlcnic_up(adapter, netdev);
-		if (err)
-			goto done;
-		qlcnic_restore_indev_addr(netdev, NETDEV_UP);
-	}
- done:
-	netif_device_attach(netdev);
-	clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	return err;
-}
-
 static int
 qlcnic_validate_beacon(struct qlcnic_adapter *adapter, u16 beacon, u8 *state,
 			u8 *rate)
@@ -3354,7 +3313,8 @@ qlcnic_validate_beacon(struct qlcnic_adapter *adapter, u16 beacon, u8 *state,
 	*rate = LSB(beacon);
 	*state = MSB(beacon);
 
-	QLCDB(adapter, DRV, "rate %x state %x\n", *rate, *state);
+	netif_info(adapter->ahw, drv, adapter->netdev,
+		"rate %x state %x\n", *rate, *state);
 
 	if (!*state) {
 		*rate = __QLCNIC_MAX_LED_RATE;
@@ -3430,7 +3390,7 @@ qlcnic_show_beacon(struct device *dev,
 {
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 
-	return sprintf(buf, "%d\n", adapter->ahw->beacon_state);
+	return snprintf(buf, sizeof(u8), "%d\n", adapter->ahw->beacon_state);
 }
 
 static struct device_attribute dev_attr_beacon = {
@@ -3579,14 +3539,11 @@ validate_pm_config(struct qlcnic_adapter *adapter,
 	for (i = 0; i < count; i++) {
 		src_pci_func = pm_cfg[i].pci_func;
 		dest_pci_func = pm_cfg[i].dest_npar;
-		if (src_pci_func >= QLCNIC_MAX_PCI_FUNC
-				|| dest_pci_func >= QLCNIC_MAX_PCI_FUNC)
-			return QL_STATUS_INVALID_PARAM;
 
-		if (adapter->npars[src_pci_func].type != QLCNIC_TYPE_NIC)
+		if (qlcnic_is_valid_nic_func(adapter, src_pci_func) < 0)
 			return QL_STATUS_INVALID_PARAM;
 
-		if (adapter->npars[dest_pci_func].type != QLCNIC_TYPE_NIC)
+		if (qlcnic_is_valid_nic_func(adapter, dest_pci_func) < 0)
 			return QL_STATUS_INVALID_PARAM;
 
 		s_esw_id = adapter->npars[src_pci_func].phy_port;
@@ -3608,7 +3565,7 @@ qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_pm_func_cfg *pm_cfg;
 	u32 id, action, pci_func;
-	int count, rem, i, ret;
+	int count, rem, i, ret, index;
 
 	count	= size / sizeof(struct qlcnic_pm_func_cfg);
 	rem	= size % sizeof(struct qlcnic_pm_func_cfg);
@@ -3622,6 +3579,7 @@ qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
 		return ret;
 	for (i = 0; i < count; i++) {
 		pci_func = pm_cfg[i].pci_func;
+
 		action = !!pm_cfg[i].action;
 		id = adapter->npars[pci_func].phy_port;
 		ret = qlcnic_config_port_mirroring(adapter, id,
@@ -3632,9 +3590,10 @@ qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
 
 	for (i = 0; i < count; i++) {
 		pci_func = pm_cfg[i].pci_func;
+		index = qlcnic_is_valid_nic_func(adapter, pci_func);
 		id = adapter->npars[pci_func].phy_port;
-		adapter->npars[pci_func].enable_pm = !!pm_cfg[i].action;
-		adapter->npars[pci_func].dest_npar = id;
+		adapter->npars[index].enable_pm = !!pm_cfg[i].action;
+		adapter->npars[index].dest_npar = id;
 	}
 	return size;
 }
@@ -3647,16 +3606,19 @@ qlcnic_sysfs_read_pm_config(struct file *filp, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_pm_func_cfg pm_cfg[QLCNIC_MAX_PCI_FUNC];
 	int i;
+	u8 pci_func;
 
 	if (size != sizeof(pm_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
-			continue;
-		pm_cfg[i].action = adapter->npars[i].enable_pm;
-		pm_cfg[i].dest_npar = 0;
-		pm_cfg[i].pci_func = i;
+	memset(&pm_cfg, 0,
+		sizeof(struct qlcnic_pm_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		pci_func = adapter->npars[i].pci_func;
+		pm_cfg[pci_func].action = adapter->npars[i].enable_pm;
+		pm_cfg[pci_func].dest_npar = 0;
+		pm_cfg[pci_func].pci_func = i;
 	}
 	memcpy(buf, &pm_cfg, size);
 
@@ -3669,9 +3631,12 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 {
 	u32 op_mode;
 	u8 pci_func;
-	int i;
+	int i, ret;
 
-	op_mode = readl(adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE);
+	if (QLCNIC_IS_82XX(adapter))
+		op_mode = readl(adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE);
+	else
+		op_mode = QLCRDX(adapter->ahw, QLC_83XX_DRV_OP_MODE);
 
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
@@ -3679,13 +3644,20 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 			return QL_STATUS_INVALID_PARAM;
 
 		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
-			if (adapter->npars[pci_func].type != QLCNIC_TYPE_NIC)
+			if (qlcnic_is_valid_nic_func(adapter, pci_func) < 0)
 				return QL_STATUS_INVALID_PARAM;
 
 		switch (esw_cfg[i].op_mode) {
 		case QLCNIC_PORT_DEFAULTS:
-			if (QLC_DEV_GET_DRV(op_mode, pci_func) !=
-						QLCNIC_NON_PRIV_FUNC) {
+			if (QLCNIC_IS_82XX(adapter)) {
+				ret = QLC_DEV_GET_DRV(op_mode, pci_func);
+			} else {
+				ret = QLC_83XX_GET_FUNC_PRIVILEGE_LEVEL(
+							op_mode, pci_func);
+				esw_cfg[i].offload_flags = 0;
+			}
+
+			if (ret !=  QLCNIC_NON_PRIV_FUNC) {
 				if (esw_cfg[i].mac_anti_spoof != 0)
 					return QL_STATUS_INVALID_PARAM;
 				if (esw_cfg[i].mac_override != 1)
@@ -3720,7 +3692,8 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 	struct qlcnic_esw_func_cfg *esw_cfg;
 	struct qlcnic_npar_info *npar;
 	int count, rem, i, ret;
-	u8 pci_func, op_mode = 0;
+	int index;
+	u8 op_mode = 0, pci_func;
 
 	count	= size / sizeof(struct qlcnic_esw_func_cfg);
 	rem	= size % sizeof(struct qlcnic_esw_func_cfg);
@@ -3764,7 +3737,8 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
-		npar = &adapter->npars[pci_func];
+		index = qlcnic_is_valid_nic_func(adapter, pci_func);
+		npar = &adapter->npars[index];
 		switch (esw_cfg[i].op_mode) {
 		case QLCNIC_PORT_DEFAULTS:
 			npar->promisc_mode = esw_cfg[i].promisc_mode;
@@ -3792,16 +3766,18 @@ qlcnic_sysfs_read_esw_config(struct file *file, struct kobject *kobj,
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_esw_func_cfg esw_cfg[QLCNIC_MAX_PCI_FUNC];
-	u8 i;
+	u8 i, pci_func;
 
 	if (size != sizeof(esw_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
-			continue;
-		esw_cfg[i].pci_func = i;
-		if (qlcnic_get_eswitch_port_config(adapter, &esw_cfg[i]))
+	memset(&esw_cfg, 0,
+		sizeof(struct qlcnic_esw_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		pci_func = adapter->npars[i].pci_func;
+		esw_cfg[pci_func].pci_func = pci_func;
+		if (qlcnic_get_eswitch_port_config(adapter, &esw_cfg[pci_func]))
 			return QL_STATUS_INVALID_PARAM;
 	}
 	memcpy(buf, &esw_cfg, size);
@@ -3817,11 +3793,8 @@ validate_npar_config(struct qlcnic_adapter *adapter,
 
 	for (i = 0; i < count; i++) {
 		pci_func = np_cfg[i].pci_func;
-		if (pci_func >= QLCNIC_MAX_PCI_FUNC)
-			return QL_STATUS_INVALID_PARAM;
-
-		if (adapter->npars[pci_func].type != QLCNIC_TYPE_NIC)
-			return QL_STATUS_INVALID_PARAM;
+		if (qlcnic_is_valid_nic_func(adapter, pci_func) < 0)
+				return QL_STATUS_INVALID_PARAM;
 
 		if (!IS_VALID_BW(np_cfg[i].min_bw) ||
 		    !IS_VALID_BW(np_cfg[i].max_bw))
@@ -3838,7 +3811,7 @@ qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_info nic_info;
 	struct qlcnic_npar_func_cfg *np_cfg;
-	int i, count, rem, ret;
+	int i, count, rem, ret, index;
 	u8 pci_func;
 
 	count	= size / sizeof(struct qlcnic_npar_func_cfg);
@@ -3853,7 +3826,9 @@ qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
 
 	for (i = 0; i < count ; i++) {
 		pci_func = np_cfg[i].pci_func;
-		ret = qlcnic_get_nic_info(adapter, &nic_info, pci_func);
+		memset(&nic_info, 0, sizeof(struct qlcnic_info));
+		ret = qlcnic_get_nic_info(adapter,
+						&nic_info, pci_func);
 		if (ret)
 			return ret;
 		nic_info.pci_func = pci_func;
@@ -3862,13 +3837,15 @@ qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
 		ret = qlcnic_set_nic_info(adapter, &nic_info);
 		if (ret)
 			return ret;
-		adapter->npars[i].min_bw = nic_info.min_tx_bw;
-		adapter->npars[i].max_bw = nic_info.max_tx_bw;
+		index = qlcnic_is_valid_nic_func(adapter, pci_func);
+		adapter->npars[index].min_bw = nic_info.min_tx_bw;
+		adapter->npars[index].max_bw = nic_info.max_tx_bw;
 	}
 
 	return size;
 
 }
+
 static ssize_t
 qlcnic_sysfs_read_npar_config(struct file *file, struct kobject *kobj,
 	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
@@ -3882,10 +3859,15 @@ qlcnic_sysfs_read_npar_config(struct file *file, struct kobject *kobj,
 	if (size != sizeof(np_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
+	memset(&nic_info, 0, sizeof(struct qlcnic_info));
+	memset(&np_cfg, 0, sizeof(struct qlcnic_npar_func_cfg) *
+			QLCNIC_MAX_PCI_FUNC);
+
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC ; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
+		if (qlcnic_is_valid_nic_func(adapter, i) < 0)
 			continue;
-		ret = qlcnic_get_nic_info(adapter, &nic_info, i);
+		ret = qlcnic_get_nic_info(adapter,
+						&nic_info, i);
 		if (ret)
 			return ret;
 
@@ -3911,6 +3893,9 @@ qlcnic_sysfs_get_port_stats(struct file *file, struct kobject *kobj,
 	struct qlcnic_esw_statistics port_stats;
 	int ret;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return QL_STATUS_UNSUPPORTED_CMD;
+
 	if (size != sizeof(struct qlcnic_esw_statistics))
 		return QL_STATUS_INVALID_PARAM;
 
@@ -3941,6 +3926,9 @@ qlcnic_sysfs_get_esw_stats(struct file *file, struct kobject *kobj,
 	struct qlcnic_esw_statistics esw_stats;
 	int ret;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return QL_STATUS_UNSUPPORTED_CMD;
+
 	if (size != sizeof(struct qlcnic_esw_statistics))
 		return QL_STATUS_INVALID_PARAM;
 
@@ -3970,6 +3958,9 @@ qlcnic_sysfs_clear_esw_stats(struct file *file, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	int ret;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return QL_STATUS_UNSUPPORTED_CMD;
+
 	if (offset >= QLCNIC_NIU_MAX_XG_PORTS)
 		return QL_STATUS_INVALID_PARAM;
 
@@ -3995,6 +3986,9 @@ qlcnic_sysfs_clear_port_stats(struct file *file, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	int ret;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return QL_STATUS_UNSUPPORTED_CMD;
+
 	if (offset >= QLCNIC_MAX_PCI_FUNC)
 		return QL_STATUS_INVALID_PARAM;
 
@@ -4024,6 +4018,9 @@ qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
 	if (size != sizeof(pci_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
+	memset(&pci_cfg, 0,
+		sizeof(struct qlcnic_pci_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
 	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
 	if (!pci_info)
 		return -ENOMEM;
@@ -4046,6 +4043,7 @@ qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
 	kfree(pci_info);
 	return size;
 }
+
 static struct bin_attribute bin_attr_npar_config = {
 	.attr = {.name = "npar_config", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
@@ -4093,7 +4091,6 @@ qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
-	qlcnic_create_diag_entries(adapter);
 	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
 		if (device_create_file(dev, &dev_attr_bridged_mode))
 			dev_warn(dev,
@@ -4105,7 +4102,6 @@ qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
-	qlcnic_remove_diag_entries(adapter);
 	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
 		device_remove_file(dev, &dev_attr_bridged_mode);
 }
@@ -4116,34 +4112,34 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 	struct device *dev = &adapter->pdev->dev;
 
 	if (device_create_bin_file(dev, &bin_attr_port_stats))
-		dev_info(dev, "failed to create port stats sysfs entry");
+		dev_err(dev, "failed to create port stats sysfs entry");
 
 	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC)
 		return;
 	if (device_create_file(dev, &dev_attr_diag_mode))
-		dev_info(dev, "failed to create diag_mode sysfs entry\n");
+		dev_err(dev, "failed to create diag_mode sysfs entry\n");
 	if (device_create_bin_file(dev, &bin_attr_crb))
-		dev_info(dev, "failed to create crb sysfs entry\n");
+		dev_err(dev, "failed to create crb sysfs entry\n");
 	if (device_create_bin_file(dev, &bin_attr_mem))
-		dev_info(dev, "failed to create mem sysfs entry\n");
+		dev_err(dev, "failed to create mem sysfs entry\n");
 
 	if (device_create_bin_file(dev, &bin_attr_pci_config))
-		dev_info(dev, "failed to create pci config sysfs entry");
+		dev_err(dev, "failed to create pci config sysfs entry");
 	if (device_create_file(dev, &dev_attr_beacon))
-		dev_info(dev, "failed to create beacon sysfs entry");
+		dev_err(dev, "failed to create beacon sysfs entry");
 
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
 		return;
 	if (device_create_bin_file(dev, &bin_attr_esw_config))
-		dev_info(dev, "failed to create esw config sysfs entry");
+		dev_err(dev, "failed to create esw config sysfs entry");
 	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return;
 	if (device_create_bin_file(dev, &bin_attr_npar_config))
-		dev_info(dev, "failed to create npar config sysfs entry");
+		dev_err(dev, "failed to create npar config sysfs entry");
 	if (device_create_bin_file(dev, &bin_attr_pm_config))
-		dev_info(dev, "failed to create pm config sysfs entry");
+		dev_err(dev, "failed to create pm config sysfs entry");
 	if (device_create_bin_file(dev, &bin_attr_esw_stats))
-		dev_info(dev, "failed to create eswitch stats sysfs entry");
+		dev_err(dev, "failed to create eswitch stats sysfs entry");
 }
 
 static void
@@ -4182,6 +4178,16 @@ qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter)
 	qlcnic_remove_diag_entries(adapter);
 }
 
+void qlcnic_83xx_add_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_create_diag_entries(adapter);
+}
+
+void qlcnic_83xx_remove_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_remove_diag_entries(adapter);
+}
+
 #ifdef CONFIG_INET
 
 #define is_qlcnic_netdev(dev) (dev->netdev_ops == &qlcnic_netdev_ops)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
new file mode 100644
index 0000000..fe41de8
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -0,0 +1,863 @@
+
+#include "qlcnic.h"
+#include "qlcnic_hdr.h"
+#include "qlcnic_83xx_hw.h"
+#include "qlcnic_hw.h"
+
+#include <net/ip.h>
+
+#define QLC_83XX_MINIDUMP_FLASH			0x520000
+#define QLC_83XX_OCM_INDEX			3
+#define QLC_83XX_PCI_INDEX			0
+
+static const u32 qlcnic_ms_read_data[] = {
+	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC, };
+
+static u32
+qlcnic_dump_crb(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
+		u32 *buffer)
+{
+	int i;
+	u32 addr, data;
+	struct __crb *crb = &entry->region.crb;
+
+	addr = crb->addr;
+
+	for (i = 0; i < crb->no_ops; i++) {
+		data = qlcnic_ind_rd(adapter, addr);
+		*buffer++ = cpu_to_le32(addr);
+		*buffer++ = cpu_to_le32(data);
+		addr += crb->stride;
+	}
+	return crb->no_ops * 2 * sizeof(u32);
+}
+
+static u32
+qlcnic_dump_ctrl(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	int i, k, timeout = 0;
+	u32 addr, data;
+	u8 opcode, no_ops;
+	struct __ctrl *ctr = &entry->region.ctrl;
+	struct qlcnic_dump_template_hdr *t_hdr = adapter->ahw->fw_dump.tmpl_hdr;
+
+	addr = ctr->addr;
+	no_ops = ctr->no_ops;
+
+	for (i = 0; i < no_ops; i++) {
+		k = 0;
+		opcode = 0;
+		for (k = 0; k < 8; k++) {
+			if (!(ctr->opcode & (1 << k)))
+				continue;
+			switch (1 << k) {
+			case QLCNIC_DUMP_WCRB:
+				qlcnic_ind_wr(adapter, addr, ctr->val1);
+				break;
+			case QLCNIC_DUMP_RWCRB:
+				data = qlcnic_ind_rd(adapter, addr);
+				qlcnic_ind_wr(adapter, addr, data);
+				break;
+			case QLCNIC_DUMP_ANDCRB:
+				data = qlcnic_ind_rd(adapter, addr);
+				qlcnic_ind_wr(adapter, addr,
+						(data & ctr->val2));
+				break;
+			case QLCNIC_DUMP_ORCRB:
+				data = qlcnic_ind_rd(adapter, addr);
+				qlcnic_ind_wr(adapter, addr,
+						(data | ctr->val3));
+				break;
+			case QLCNIC_DUMP_POLLCRB:
+				while (timeout <= ctr->timeout) {
+					data = qlcnic_ind_rd(adapter, addr);
+					if ((data & ctr->val2) == ctr->val1)
+						break;
+					usleep_range(1000, 2000);
+					timeout++;
+				}
+				if (timeout > ctr->timeout) {
+					dev_err(&adapter->pdev->dev,
+					"Timed out, aborting poll CRB\n");
+					return 0;
+				}
+				break;
+			case QLCNIC_DUMP_RD_SAVE:
+				if (ctr->index_a)
+					addr = t_hdr->saved_state[ctr->index_a];
+				data = qlcnic_ind_rd(adapter, addr);
+				t_hdr->saved_state[ctr->index_v] = data;
+				break;
+			case QLCNIC_DUMP_WRT_SAVED:
+				if (ctr->index_v)
+					data = t_hdr->saved_state[ctr->index_v];
+				else
+					data = ctr->val1;
+				if (ctr->index_a)
+					addr = t_hdr->saved_state[ctr->index_a];
+				qlcnic_ind_wr(adapter, addr, data);
+				break;
+			case QLCNIC_DUMP_MOD_SAVE_ST:
+				data = t_hdr->saved_state[ctr->index_v];
+				data <<= ctr->shl_val;
+				data >>= ctr->shr_val;
+				if (ctr->val2)
+					data &= ctr->val2;
+				data |= ctr->val3;
+				data += ctr->val1;
+				t_hdr->saved_state[ctr->index_v] = data;
+				break;
+			default:
+				dev_err(&adapter->pdev->dev,
+					"Unknown opcode\n");
+				break;
+			}
+		}
+		addr += ctr->stride;
+	}
+	return 0;
+}
+
+static u32
+qlcnic_dump_mux(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
+	u32 *buffer)
+{
+	int loop;
+	u32 val, data = 0;
+	struct __mux *mux = &entry->region.mux;
+
+	val = mux->val;
+	for (loop = 0; loop < mux->no_ops; loop++) {
+		qlcnic_ind_wr(adapter, mux->addr, val);
+		data = qlcnic_ind_rd(adapter, mux->read_addr);
+		*buffer++ = cpu_to_le32(val);
+		*buffer++ = cpu_to_le32(data);
+		val += mux->val_stride;
+	}
+	return 2 * mux->no_ops * sizeof(u32);
+}
+
+static u32
+qlcnic_dump_que(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
+	u32 *buffer)
+{
+	int i, loop;
+	u32 cnt, addr, data, que_id = 0;
+	struct __queue *que = &entry->region.que;
+
+	addr = que->read_addr;
+	cnt = que->read_addr_cnt;
+
+	for (loop = 0; loop < que->no_ops; loop++) {
+		qlcnic_ind_wr(adapter, que->sel_addr, que_id);
+		addr = que->read_addr;
+		for (i = 0; i < cnt; i++) {
+			data = qlcnic_ind_rd(adapter, addr);
+			*buffer++ = cpu_to_le32(data);
+			addr += que->read_addr_stride;
+		}
+		que_id += que->stride;
+	}
+	return que->no_ops * cnt * sizeof(u32);
+}
+
+static u32
+qlcnic_dump_ocm(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
+	u32 *buffer)
+{
+	int i;
+	u32 data;
+	void __iomem *addr;
+	struct __ocm *ocm = &entry->region.ocm;
+
+	addr = adapter->ahw->pci_base0 + ocm->read_addr;
+	for (i = 0; i < ocm->no_ops; i++) {
+		data = readl(addr);
+		*buffer++ = cpu_to_le32(data);
+		addr += ocm->read_addr_stride;
+	}
+	return ocm->no_ops * sizeof(u32);
+}
+
+static u32
+qlcnic_read_rom(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
+	u32 *buffer)
+{
+	int i, count = 0;
+	u32 fl_addr, size, val, lck_val, addr;
+	struct __mem *rom = &entry->region.mem;
+
+	fl_addr = rom->addr;
+	size = rom->size/4;
+lock_try:
+	lck_val = QLCRD(adapter, QLCNIC_FLASH_LOCK);
+	if (!lck_val && count < MAX_CTL_CHECK) {
+		usleep_range(10000, 11000);
+		count++;
+		goto lock_try;
+	}
+	QLCWR(adapter, QLCNIC_FLASH_LOCK_OWNER, adapter->ahw->pci_func);
+	for (i = 0; i < size; i++) {
+		addr = fl_addr & 0xFFFF0000;
+		qlcnic_ind_wr(adapter, FLASH_ROM_WINDOW, addr);
+		addr = LSW(fl_addr) + FLASH_ROM_DATA;
+		val = qlcnic_ind_rd(adapter, addr);
+		fl_addr += 4;
+		*buffer++ = cpu_to_le32(val);
+	}
+	QLCRD(adapter, QLCNIC_FLASH_UNLOCK);
+	return rom->size;
+}
+
+static u32
+qlcnic_dump_l1_cache(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	int i;
+	u32 cnt, val, data, addr;
+	struct __cache *l1 = &entry->region.cache;
+
+	val = l1->init_tag_val;
+
+	for (i = 0; i < l1->no_ops; i++) {
+		qlcnic_ind_wr(adapter, l1->addr, val);
+		qlcnic_ind_wr(adapter, l1->ctrl_addr, LSW(l1->ctrl_val));
+		addr = l1->read_addr;
+		cnt = l1->read_addr_num;
+		while (cnt) {
+			data = qlcnic_ind_rd(adapter, addr);
+			*buffer++ = cpu_to_le32(data);
+			addr += l1->read_addr_stride;
+			cnt--;
+		}
+		val += l1->stride;
+	}
+	return l1->no_ops * l1->read_addr_num * sizeof(u32);
+}
+
+static u32
+qlcnic_dump_l2_cache(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	int i;
+	u32 cnt, val, data, addr;
+	u8 poll_mask, poll_to, time_out = 0;
+	struct __cache *l2 = &entry->region.cache;
+
+	val = l2->init_tag_val;
+	poll_mask = LSB(MSW(l2->ctrl_val));
+	poll_to = MSB(MSW(l2->ctrl_val));
+
+	for (i = 0; i < l2->no_ops; i++) {
+		qlcnic_ind_wr(adapter, l2->addr, val);
+		if (LSW(l2->ctrl_val))
+			qlcnic_ind_wr(adapter, l2->ctrl_addr,
+						LSW(l2->ctrl_val));
+		if (!poll_mask)
+			goto skip_poll;
+		do {
+			data = qlcnic_ind_rd(adapter, l2->ctrl_addr);
+			if (!(data & poll_mask))
+				break;
+			usleep_range(1000, 2000);
+			time_out++;
+		} while (time_out <= poll_to);
+
+		if (time_out > poll_to) {
+			dev_err(&adapter->pdev->dev,
+				"Timeout exceeded in %s, aborting dump\n",
+				__func__);
+			return 0;
+		}
+skip_poll:
+		addr = l2->read_addr;
+		cnt = l2->read_addr_num;
+		while (cnt) {
+			data = qlcnic_ind_rd(adapter, addr);
+			*buffer++ = cpu_to_le32(data);
+			addr += l2->read_addr_stride;
+			cnt--;
+		}
+		val += l2->stride;
+	}
+	return l2->no_ops * l2->read_addr_num * sizeof(u32);
+}
+
+static u32
+qlcnic_read_memory(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	u32 addr, data, test, ret = 0;
+	int i, reg_read;
+	struct __mem *mem = &entry->region.mem;
+
+	reg_read = mem->size;
+	addr = mem->addr;
+	/* check for data size of multiple of 16 and 16 byte alignment */
+	if ((addr & 0xf) || (reg_read%16)) {
+		dev_err(&adapter->pdev->dev,
+			"Unaligned memory addr:0x%x size:0x%x\n",
+			addr, reg_read);
+		return 0;
+	}
+
+	mutex_lock(&adapter->ahw->mem_lock);
+
+	while (reg_read != 0) {
+		qlcnic_ind_wr(adapter, QLCNIC_MS_ADDR_LO, addr);
+		qlcnic_ind_wr(adapter, QLCNIC_MS_ADDR_HI, 0);
+		qlcnic_ind_wr(adapter, QLCNIC_MS_CTRL, QLC_TA_START_ENABLE);
+
+		for (i = 0; i < MAX_CTL_CHECK; i++) {
+			test = qlcnic_ind_rd(adapter, QLCNIC_MS_CTRL);
+			if (!(test & TA_CTL_BUSY))
+				break;
+		}
+		if (i == MAX_CTL_CHECK) {
+			printk_ratelimited(KERN_WARNING
+				"failed to read through agent\n");
+			ret = 0;
+			goto out;
+		}
+		for (i = 0; i < 4; i++) {
+			data = qlcnic_ind_rd(adapter, qlcnic_ms_read_data[i]);
+			*buffer++ = cpu_to_le32(data);
+		}
+		addr += 16;
+		reg_read -= 16;
+		ret += 16;
+	}
+out:
+	mutex_unlock(&adapter->ahw->mem_lock);
+	return mem->size;
+}
+
+static u32
+qlcnic_dump_nop(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	entry->hdr.flags |= QLCNIC_DUMP_SKIP;
+	return 0;
+}
+
+static int
+qlcnic_valid_dump_entry(struct device *dev, struct qlcnic_dump_entry *entry,
+	u32 size)
+{
+	int ret = 1;
+	if (size != entry->hdr.cap_size) {
+		dev_err(dev,
+		"Invalid entry, Type:%d\tMask:%d\tSize:%dCap_size:%d\n",
+		entry->hdr.type, entry->hdr.mask, size, entry->hdr.cap_size);
+		ret = 0;
+	}
+	return ret;
+}
+
+static u32
+qlcnic_read_pollrdmwr(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	struct __pollrdmwr *poll = &entry->region.pollrdmwr;
+	u32 data, wait_count, poll_wait, temp;
+
+	poll_wait = poll->poll_wait;
+
+	qlcnic_ind_wr(adapter, poll->addr1, poll->val1);
+	wait_count = 0;
+
+	while (wait_count < poll_wait) {
+		data = qlcnic_ind_rd(adapter, poll->addr1);
+		if ((data & poll->poll_mask) != 0)
+			break;
+		wait_count++;
+	}
+
+	if (wait_count == poll_wait) {
+		dev_err(&adapter->pdev->dev,
+			"Timeout exceeded in %s, aborting dump\n",
+			__func__);
+		return 0;
+	}
+
+	data = qlcnic_ind_rd(adapter, poll->addr2) & poll->mod_mask;
+	qlcnic_ind_wr(adapter, poll->addr2, data);
+	qlcnic_ind_wr(adapter, poll->addr1, poll->val2);
+	wait_count = 0;
+
+	while (wait_count < poll_wait) {
+		temp = qlcnic_ind_rd(adapter, poll->addr1);
+		if ((temp & poll->poll_mask) != 0)
+			break;
+		wait_count++;
+	}
+
+	*buffer++ = cpu_to_le32(poll->addr2);
+	*buffer++ = cpu_to_le32(data);
+
+	return 2 * sizeof(u32);
+
+}
+
+static u32
+qlcnic_read_pollrd(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	struct __pollrd *pollrd = &entry->region.pollrd;
+	u32 data, wait_count, poll_wait, sel_val;
+	int i;
+
+	poll_wait = pollrd->poll_wait;
+	sel_val = pollrd->sel_val;
+
+	for (i = 0; i < pollrd->no_ops; i++)  {
+		qlcnic_ind_wr(adapter, pollrd->sel_addr, sel_val);
+		wait_count = 0;
+		while (wait_count < poll_wait) {
+			data = qlcnic_ind_rd(adapter, pollrd->sel_addr);
+			if ((data & pollrd->poll_mask) != 0)
+				break;
+			wait_count++;
+		}
+
+		if (wait_count == poll_wait) {
+			dev_err(&adapter->pdev->dev,
+				"Timeout exceeded in %s, aborting dump\n",
+				__func__);
+			return 0;
+		}
+
+		data = qlcnic_ind_rd(adapter, pollrd->read_addr);
+		*buffer++ = cpu_to_le32(sel_val);
+		*buffer++ = cpu_to_le32(data);
+		sel_val += pollrd->sel_val_stride;
+	}
+	return pollrd->no_ops * (2 * sizeof(u32));
+}
+
+static u32
+qlcnic_read_mux2(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	struct __mux2 *mux2 = &entry->region.mux2;
+	u32 data;
+	u32 t_sel_val, sel_val1, sel_val2;
+	int i;
+
+	sel_val1 = mux2->sel_val1;
+	sel_val2 = mux2->sel_val2;
+
+	for (i = 0; i < mux2->no_ops; i++)  {
+		qlcnic_ind_wr(adapter, mux2->sel_addr1, sel_val1);
+		t_sel_val = sel_val1 & mux2->sel_val_mask;
+		qlcnic_ind_wr(adapter, mux2->sel_addr2, t_sel_val);
+		data = qlcnic_ind_rd(adapter, mux2->read_addr);
+		*buffer++ = cpu_to_le32(t_sel_val);
+		*buffer++ = cpu_to_le32(data);
+		qlcnic_ind_wr(adapter, mux2->sel_addr1, sel_val2);
+		t_sel_val = sel_val2 & mux2->sel_val_mask;
+		qlcnic_ind_wr(adapter, mux2->sel_addr2, t_sel_val);
+		data = qlcnic_ind_rd(adapter, mux2->read_addr);
+		*buffer++ = cpu_to_le32(t_sel_val);
+		*buffer++ = cpu_to_le32(data);
+		sel_val1 += mux2->sel_val_stride;
+		sel_val2 += mux2->sel_val_stride;
+	}
+
+	return mux2->no_ops * (4 * sizeof(u32));
+}
+
+static u32
+qlcnic_83xx_dump_rom(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	u32 fl_addr, size;
+	struct __mem *rom = &entry->region.mem;
+
+	fl_addr = rom->addr;
+	size = rom->size/4;
+
+	if (!qlcnic_83xx_lockless_flash_read32(adapter,
+					fl_addr, (u8 *)buffer, size))
+		return rom->size;
+
+	return 0;
+}
+
+static const struct qlcnic_dump_operations qlcnic_fw_dump_ops[] = {
+	{ QLCNIC_DUMP_NOP, qlcnic_dump_nop },
+	{ QLCNIC_DUMP_READ_CRB, qlcnic_dump_crb },
+	{ QLCNIC_DUMP_READ_MUX, qlcnic_dump_mux },
+	{ QLCNIC_DUMP_QUEUE, qlcnic_dump_que },
+	{ QLCNIC_DUMP_BRD_CONFIG, qlcnic_read_rom },
+	{ QLCNIC_DUMP_READ_OCM, qlcnic_dump_ocm },
+	{ QLCNIC_DUMP_PEG_REG, qlcnic_dump_ctrl },
+	{ QLCNIC_DUMP_L1_DTAG, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L1_ITAG, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L1_DATA, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L1_INST, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L2_DTAG, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_L2_ITAG, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_L2_DATA, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_L2_INST, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_READ_ROM, qlcnic_read_rom },
+	{ QLCNIC_DUMP_READ_MEM, qlcnic_read_memory },
+	{ QLCNIC_DUMP_READ_CTRL, qlcnic_dump_ctrl },
+	{ QLCNIC_DUMP_TLHDR, qlcnic_dump_nop },
+	{ QLCNIC_DUMP_RDEND, qlcnic_dump_nop },
+};
+
+static const struct qlcnic_dump_operations qlcnic_83xx_fw_dump_ops[] = {
+	{ QLCNIC_DUMP_NOP, qlcnic_dump_nop },
+	{ QLCNIC_DUMP_READ_CRB, qlcnic_dump_crb },
+	{ QLCNIC_DUMP_READ_MUX, qlcnic_dump_mux },
+	{ QLCNIC_DUMP_QUEUE, qlcnic_dump_que },
+	{ QLCNIC_DUMP_BRD_CONFIG, qlcnic_83xx_dump_rom },
+	{ QLCNIC_DUMP_READ_OCM, qlcnic_dump_ocm },
+	{ QLCNIC_DUMP_PEG_REG, qlcnic_dump_ctrl },
+	{ QLCNIC_DUMP_L1_DTAG, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L1_ITAG, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L1_DATA, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L1_INST, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L2_DTAG, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_L2_ITAG, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_L2_DATA, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_L2_INST, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_POLL_RD, qlcnic_read_pollrd },
+	{ QLCNIC_READ_MUX2, qlcnic_read_mux2 },
+	{ QLCNIC_READ_POLLRDMWR, qlcnic_read_pollrdmwr },
+	{ QLCNIC_DUMP_READ_ROM, qlcnic_83xx_dump_rom },
+	{ QLCNIC_DUMP_READ_MEM, qlcnic_read_memory },
+	{ QLCNIC_DUMP_READ_CTRL, qlcnic_dump_ctrl },
+	{ QLCNIC_DUMP_TLHDR, qlcnic_dump_nop },
+	{ QLCNIC_DUMP_RDEND, qlcnic_dump_nop },
+};
+
+static uint32_t qlcnic_temp_checksum(uint32_t *temp_buffer, u32 temp_size)
+{
+	uint64_t sum = 0;
+	int count = temp_size / sizeof(uint32_t);
+	while (count-- > 0)
+		sum += *temp_buffer++;
+	while (sum >> 32)
+		sum = (sum & 0xFFFFFFFF) + (sum >> 32);
+	return ~sum;
+}
+
+static int
+qlcnic_fw_flash_get_minidump_temp(struct qlcnic_adapter *adapter,
+					u8 *buffer, u32 size)
+{
+	int ret = 0;
+
+	if (QLCNIC_IS_82XX(adapter))
+		return -EIO;
+
+	if (qlcnic_83xx_lock_flash(adapter))
+		return -EIO;
+
+	ret = qlcnic_83xx_lockless_flash_read32(adapter,
+			QLC_83XX_MINIDUMP_FLASH, buffer, size/sizeof(u32));
+
+	qlcnic_83xx_unlock_flash(adapter);
+
+	return ret;
+}
+
+static int
+qlcnic_fw_flash_get_minidump_temp_size(struct qlcnic_adapter *adapter,
+				struct qlcnic_cmd_args *cmd)
+{
+	struct qlcnic_dump_template_hdr tmp_hdr;
+	u32 size = sizeof(struct qlcnic_dump_template_hdr) / sizeof(u32);
+	int ret = 0;
+
+	if (QLCNIC_IS_82XX(adapter))
+		return -EIO;
+
+	if (qlcnic_83xx_lock_flash(adapter))
+		return -EIO;
+
+	ret = qlcnic_83xx_lockless_flash_read32(adapter,
+			QLC_83XX_MINIDUMP_FLASH, (u8 *)&tmp_hdr, size);
+
+	qlcnic_83xx_unlock_flash(adapter);
+
+	cmd->rsp.arg[2] = tmp_hdr.size;
+	cmd->rsp.arg[3] = tmp_hdr.version;
+
+	return ret;
+}
+
+static int
+qlcnic_fw_get_minidump_temp_size(struct qlcnic_adapter *adapter,
+		u32 *version, u32 *temp_size, u8 *use_flash_temp)
+{
+	int err = 0;
+	struct qlcnic_cmd_args cmd;
+	struct qlcnic_hardware_context *ahw;
+
+	ahw = adapter->ahw;
+	if (adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_TEMP_SIZE))
+		return -ENOMEM;
+
+	err = ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (err != QLCNIC_RCODE_SUCCESS) {
+		if (qlcnic_fw_flash_get_minidump_temp_size(adapter, &cmd)) {
+			qlcnic_free_mbx_args(&cmd);
+			return -EIO;
+		}
+		*use_flash_temp = 1;
+	}
+
+	*temp_size = cmd.rsp.arg[2];
+	*version = cmd.rsp.arg[3];
+	qlcnic_free_mbx_args(&cmd);
+
+	if (!(*temp_size))
+		return -EIO;
+
+	return 0;
+}
+
+static
+int __qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter,
+				u32 *buffer, u32 temp_size)
+{
+	int err = 0, i;
+	void *tmp_addr;
+	u32 *tmp_buf;
+	struct qlcnic_cmd_args cmd;
+	dma_addr_t tmp_addr_t = 0;
+
+	tmp_addr = dma_alloc_coherent(&adapter->pdev->dev, temp_size,
+			&tmp_addr_t, GFP_KERNEL);
+	if (!tmp_addr) {
+		dev_err(&adapter->pdev->dev,
+			"Can't get memory for FW dump template\n");
+		return -ENOMEM;
+	}
+
+	if (adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_TEMP_HDR)) {
+		err = -ENOMEM;
+		goto free_mem;
+	}
+
+	cmd.req.arg[1] = LSD(tmp_addr_t);
+	cmd.req.arg[2] = MSD(tmp_addr_t);
+	cmd.req.arg[3] = temp_size;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+
+	tmp_buf = tmp_addr;
+	if (err == QLCNIC_RCODE_SUCCESS) {
+		for (i = 0; i < temp_size/sizeof(u32); i++)
+			*buffer++ = __le32_to_cpu(*tmp_buf++);
+	}
+
+	qlcnic_free_mbx_args(&cmd);
+
+free_mem:
+	dma_free_coherent(&adapter->pdev->dev, temp_size, tmp_addr, tmp_addr_t);
+
+	return err;
+}
+
+int
+qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
+{
+	int err;
+	u32 temp_size = 0;
+	u32 version, csum, *tmp_buf;
+	struct qlcnic_hardware_context *ahw;
+	struct qlcnic_dump_template_hdr *tmpl_hdr;
+	u8 use_flash_temp = 0;
+
+	ahw = adapter->ahw;
+
+	err = qlcnic_fw_get_minidump_temp_size(adapter, &version,
+					&temp_size, &use_flash_temp);
+
+	if (err) {
+		dev_err(&adapter->pdev->dev,
+			"Can't get template size %d\n", err);
+		return -EIO;
+	}
+
+	ahw->fw_dump.tmpl_hdr = vmalloc(temp_size);
+
+	if (!ahw->fw_dump.tmpl_hdr)
+		return -ENOMEM;
+
+	memset(ahw->fw_dump.tmpl_hdr, 0, temp_size);
+	tmp_buf = (u32 *)ahw->fw_dump.tmpl_hdr;
+
+	if (use_flash_temp)
+		goto flash_temp;
+
+	err = __qlcnic_fw_cmd_get_minidump_temp(adapter, tmp_buf, temp_size);
+
+	if (err) {
+flash_temp:
+		err = qlcnic_fw_flash_get_minidump_temp(adapter,
+					(u8 *)tmp_buf, temp_size);
+
+		if (err) {
+			dev_err(&adapter->pdev->dev,
+				"Failed to get minidump template header %d\n",
+									err);
+			vfree(ahw->fw_dump.tmpl_hdr);
+			ahw->fw_dump.tmpl_hdr = NULL;
+			return -EIO;
+		}
+	}
+
+	csum = qlcnic_temp_checksum((uint32_t *) tmp_buf, temp_size);
+
+	if (csum) {
+		dev_err(&adapter->pdev->dev,
+			"Template header checksum validation failed\n");
+		vfree(ahw->fw_dump.tmpl_hdr);
+		ahw->fw_dump.tmpl_hdr = NULL;
+		return -EIO;
+	}
+
+	tmpl_hdr = ahw->fw_dump.tmpl_hdr;
+	tmpl_hdr->drv_cap_mask = QLCNIC_DUMP_MASK_DEF;
+	ahw->fw_dump.enable = 1;
+
+	return 0;
+}
+
+int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
+{
+	u32 *buffer;
+	char mesg[64];
+	char *msg[] = {mesg, NULL};
+	int i, k, ops_cnt, ops_index, dump_size = 0;
+	u32 entry_offset, dump, no_entries, buf_offset = 0;
+	struct qlcnic_dump_entry *entry;
+	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+	struct qlcnic_dump_template_hdr *tmpl_hdr = fw_dump->tmpl_hdr;
+	static const struct qlcnic_dump_operations *fw_dump_ops;
+
+	if (!fw_dump->enable) {
+		dev_info(&adapter->pdev->dev,
+			"Dump not enabled\n");
+		return -EIO;
+	}
+
+	if (fw_dump->clr) {
+		dev_info(&adapter->pdev->dev,
+			"Previous dump not cleared, not capturing dump\n");
+		return -EIO;
+	}
+
+	netif_info(adapter->ahw, drv, adapter->netdev,
+		"Take FW dump\n");
+	/* Calculate the size for dump data area only */
+	for (i = 2, k = 1; (i & QLCNIC_DUMP_MASK_MAX); i <<= 1, k++)
+		if (i & tmpl_hdr->drv_cap_mask)
+			dump_size += tmpl_hdr->cap_sizes[k];
+	if (!dump_size)
+		return -EIO;
+
+	fw_dump->data = vmalloc(dump_size);
+	if (!fw_dump->data) {
+		dev_err(&adapter->pdev->dev,
+			"Unable to allocate (%d KB) for fw dump\n",
+			dump_size/1024);
+		return -ENOMEM;
+	}
+	memset(fw_dump->data, 0, dump_size);
+	buffer = fw_dump->data;
+	fw_dump->size = dump_size;
+	no_entries = tmpl_hdr->num_entries;
+	entry_offset = tmpl_hdr->offset;
+	tmpl_hdr->sys_info[0] = QLCNIC_DRIVER_VERSION;
+	tmpl_hdr->sys_info[1] = adapter->fw_version;
+
+	if (QLCNIC_IS_82XX(adapter)) {
+		ops_cnt = ARRAY_SIZE(qlcnic_fw_dump_ops);
+		fw_dump_ops = qlcnic_fw_dump_ops;
+	} else {
+		ops_cnt = ARRAY_SIZE(qlcnic_83xx_fw_dump_ops);
+		fw_dump_ops = qlcnic_83xx_fw_dump_ops;
+		tmpl_hdr->saved_state[QLC_83XX_OCM_INDEX] =
+			tmpl_hdr->ocm_wnd_reg[adapter->ahw->pci_func];
+		tmpl_hdr->saved_state[QLC_83XX_PCI_INDEX] =
+						adapter->ahw->pci_func;
+	}
+
+	for (i = 0; i < no_entries; i++) {
+		entry = (void *)tmpl_hdr + entry_offset;
+		if (!(entry->hdr.mask & tmpl_hdr->drv_cap_mask)) {
+			entry->hdr.flags |= QLCNIC_DUMP_SKIP;
+			entry_offset += entry->hdr.offset;
+			continue;
+		}
+
+		/* Find the handler for this entry */
+		ops_index = 0;
+		while (ops_index < ops_cnt) {
+			if (entry->hdr.type == fw_dump_ops[ops_index].opcode)
+				break;
+			ops_index++;
+		}
+
+		if (ops_index == ops_cnt) {
+			dev_err(&adapter->pdev->dev,
+				"Invalid entry type %d, exiting dump\n",
+				entry->hdr.type);
+			goto error;
+		}
+
+		/* Collect dump for this entry */
+		dump = fw_dump_ops[ops_index].handler(adapter, entry, buffer);
+		if (!qlcnic_valid_dump_entry(&adapter->pdev->dev, entry, dump))
+			entry->hdr.flags |= QLCNIC_DUMP_SKIP;
+		buf_offset += entry->hdr.cap_size;
+		entry_offset += entry->hdr.offset;
+		buffer = fw_dump->data + buf_offset;
+	}
+	if (dump_size != buf_offset) {
+		dev_err(&adapter->pdev->dev,
+			"Captured(%d) and expected size(%d) do not match\n",
+			buf_offset, dump_size);
+		goto error;
+	} else {
+		fw_dump->clr = 1;
+		snprintf(mesg, sizeof(mesg), "FW_DUMP=%s",
+			adapter->netdev->name);
+		dev_info(&adapter->pdev->dev, "%s: Dump data, %d bytes captured\n",
+			adapter->netdev->name, fw_dump->size);
+		/* Send a udev event to notify availability of FW dump */
+		kobject_uevent_env(&adapter->pdev->dev.kobj, KOBJ_CHANGE, msg);
+		return 0;
+	}
+error:
+	vfree(fw_dump->data);
+	return -EINVAL;
+}
+
+void
+qlcnic_83xx_get_minidump_template(struct qlcnic_adapter *adapter)
+{
+	u32 prev_version, current_version;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct qlcnic_fw_dump *fw_dump = &ahw->fw_dump;
+	struct pci_dev *pdev = adapter->pdev;
+
+	prev_version = adapter->fw_version;
+	current_version = qlcnic_83xx_get_fw_version(adapter);
+
+	if (fw_dump->tmpl_hdr == NULL || current_version > prev_version) {
+		if (fw_dump->tmpl_hdr)
+			vfree(fw_dump->tmpl_hdr);
+		if (!qlcnic_fw_cmd_get_minidump_temp(adapter))
+			dev_info(&pdev->dev,
+				"Supports FW dump capability\n");
+	}
+}
-- 
1.7.1
