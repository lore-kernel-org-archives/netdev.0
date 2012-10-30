From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v4 12/21] qlcnic: 83xx memory map and HW access routines
Date: Mon, 29 Oct 2012 20:14:43 -0400
Message-ID: <1351556092-16417-13-git-send-email-sony.chacko@qlogic.com>
References: <1351556092-16417-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:52011 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755818Ab2J3AeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 20:34:11 -0400
In-Reply-To: <1351556092-16417-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

83xx adapter register map and mailbox based
hardware interface routines.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/Makefile        |    3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   58 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 1654 ++++++++++++++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  347 ++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |   10 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   38 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |   17 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 8 files changed, 2099 insertions(+), 30 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
 create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h

diff --git a/drivers/net/ethernet/qlogic/qlcnic/Makefile b/drivers/net/ethernet/qlogic/qlcnic/Makefile
index a26ee17..f5a31ab 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/Makefile
+++ b/drivers/net/ethernet/qlogic/qlcnic/Makefile
@@ -5,4 +5,5 @@
 obj-$(CONFIG_QLCNIC) := qlcnic.o
 
 qlcnic-y := qlcnic_hw.o qlcnic_main.o qlcnic_init.o \
-	qlcnic_ethtool.o qlcnic_ctx.o qlcnic_io.o
+	qlcnic_ethtool.o qlcnic_ctx.o qlcnic_io.o \
+	qlcnic_83xx_hw.o
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 7837546..edd050c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -34,6 +34,7 @@
 
 #include "qlcnic_hdr.h"
 #include "qlcnic_hw.h"
+#include "qlcnic_83xx_hw.h"
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
@@ -48,7 +49,6 @@
 #define _minor(v)	(((v) >> 16) & 0xff)
 #define _build(v)	((v) & 0xffff)
 
-
 /* version in image has weird encoding:
  *  7:0  - major
  * 15:8  - minor
@@ -91,6 +91,7 @@
 #define QLCNIC_CT_DEFAULT_RX_BUF_LEN	2048
 #define QLCNIC_LRO_BUFFER_EXTRA		2048
 
+#define RSS_HASHTYPE_IP_TCP     0x3
 /* Opcodes to be used with the commands */
 #define TX_ETHER_PKT	0x01
 #define TX_TCP_PKT	0x02
@@ -212,7 +213,6 @@ struct rcv_desc {
 #define QLCNIC_RESPONSE_DESC	0x05
 #define QLCNIC_LRO_DESC  	0x12
 
-
 /* for status field in status_desc */
 #define STATUS_CKSUM_LOOP	0
 #define STATUS_CKSUM_OK		2
@@ -241,7 +241,7 @@ struct rcv_desc {
 	(((sts_data) >> 58) & 0x03F)
 
 #define qlcnic_get_lro_sts_refhandle(sts_data) 	\
-	((sts_data) & 0x0FFFF)
+	((sts_data) & 0x07FFF)
 #define qlcnic_get_lro_sts_length(sts_data)	\
 	(((sts_data) >> 16) & 0x0FFFF)
 #define qlcnic_get_lro_sts_l2_hdr_offset(sts_data)	\
@@ -468,6 +468,8 @@ struct qlcnic_hardware_context {
 	u8 mc_enabled;
 	u8 max_mc_count;
 	u8 diag_test;
+	u8 num_msix;
+	u8 nic_mode;
 	char diag_cnt;
 
 	u16 port_type;
@@ -490,10 +492,16 @@ struct qlcnic_hardware_context {
 	u32 temp;
 	u32 int_vec_bit;
 	u32 fw_hal_version;
+	u32 port_config;
 	struct qlcnic_hardware_ops *hw_ops;
 	struct qlcnic_nic_intr_coalesce coal;
 	struct qlcnic_fw_dump fw_dump;
+	struct qlcnic_intrpt_config *intr_tbl;
 	u32 *reg_tbl;
+	u32 *ext_reg_tbl;
+	u32 mbox_aen[QLC_83XX_MBX_AEN_CNT];
+	u32 mbox_reg[4];
+	spinlock_t mbx_lock;
 };
 
 struct qlcnic_adapter_stats {
@@ -555,6 +563,8 @@ struct qlcnic_host_sds_ring {
 
 struct qlcnic_host_tx_ring {
 	int irq;
+	void __iomem *crb_intr_mask;
+	char name[IFNAMSIZ+4];
 	u16 ctx_id;
 	u32 producer;
 	u32 sw_consumer;
@@ -819,7 +829,7 @@ struct qlcnic_mac_list_s {
  */
 
 #define QLCNIC_C2H_OPCODE_CONFIG_LOOPBACK		0x8f
-#define QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	141
+#define QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	0x8D
 
 #define VPORT_MISS_MODE_DROP		0 /* drop all unmatched */
 #define VPORT_MISS_MODE_ACCEPT_ALL	1 /* accept all packets */
@@ -912,7 +922,7 @@ struct qlcnic_ipaddr {
 
 #define QLCNIC_MSI_ENABLED		0x02
 #define QLCNIC_MSIX_ENABLED		0x04
-#define QLCNIC_LRO_ENABLED		0x08
+#define QLCNIC_LRO_ENABLED		0x01
 #define QLCNIC_LRO_DISABLED		0x00
 #define QLCNIC_BRIDGE_ENABLED       	0X10
 #define QLCNIC_DIAG_ENABLED		0x20
@@ -952,6 +962,7 @@ struct qlcnic_ipaddr {
 #define QLCNIC_FILTER_AGE	80
 #define QLCNIC_READD_AGE	20
 #define QLCNIC_LB_MAX_FILTERS	64
+#define QLCNIC_LB_BUCKET_SIZE	32
 
 /* QLCNIC Driver Error Code */
 #define QLCNIC_FW_NOT_RESPOND		51
@@ -992,6 +1003,7 @@ struct qlcnic_adapter {
 
 	u8 max_rds_rings;
 	u8 max_sds_rings;
+	u8 rx_csum;
 	u8 portnum;
 
 	u8 fw_wait_cnt;
@@ -1014,7 +1026,9 @@ struct qlcnic_adapter {
 	u64 dev_rst_time;
 	u8 mac_learn;
 	unsigned long vlans[BITS_TO_LONGS(VLAN_N_VID)];
+	u8 flash_mfg_id;
 
+	struct vlan_group *vlgrp;
 	struct qlcnic_npar_info *npars;
 	struct qlcnic_eswitch *eswitch;
 	struct qlcnic_nic_template *nic_ops;
@@ -1028,7 +1042,9 @@ struct qlcnic_adapter {
 	void __iomem	*isr_int_vec;
 
 	struct msix_entry *msix_entries;
+	struct workqueue_struct *qlcnic_wq;
 	struct delayed_work fw_work;
+	struct delayed_work idc_aen_work;
 
 	struct qlcnic_filter_hash fhash;
 
@@ -1054,7 +1070,24 @@ struct qlcnic_info {
 	__le16	max_rx_ques;
 	__le16	min_tx_bw;
 	__le16	max_tx_bw;
-	u8	reserved2[104];
+	__le32	op_type;
+	__le16	max_bw_reg_offset;
+	__le16	max_linkspeed_reg_offset;
+	__le32	capability1;
+	__le32  capability2;
+	__le32  capability3;
+	__le16	max_tx_mac_filters;
+	__le16	max_rx_mcast_mac_filters;
+	__le16	max_rx_ucast_mac_filters;
+	__le16	max_rx_ip_addr;
+	__le16	max_rx_lro_flow;
+	__le16	max_rx_status_rings;
+	__le16	max_rx_buf_rings;
+	__le16	max_tx_vlan_keys;
+	u8	total_pf;
+	u8	total_rss_engines;
+	__le16	max_vports;
+	u8	reserved2[64];
 } __packed;
 
 struct qlcnic_pci_info {
@@ -1068,7 +1101,8 @@ struct qlcnic_pci_info {
 	__le16	reserved1[2];
 
 	u8	mac[ETH_ALEN];
-	u8	reserved2[106];
+	__le16  func_count;
+	u8      reserved2[104];
 } __packed;
 
 struct qlcnic_npar_info {
@@ -1497,6 +1531,7 @@ void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
 /* Management functions */
 int qlcnic_poll(struct napi_struct *, int);
 int qlcnic_rx_poll(struct napi_struct *, int);
+int qlcnic_enable_msix(struct qlcnic_adapter *, u32);
 
 /*  eSwitch management functions */
 int qlcnic_config_switch_port(struct qlcnic_adapter *,
@@ -1515,6 +1550,7 @@ void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd);
 void qlcnic_napi_del(struct qlcnic_adapter *);
 int qlcnic_alloc_sds_rings(struct qlcnic_recv_context *, int);
 void qlcnic_free_sds_rings(struct qlcnic_recv_context *);
+void qlcnic_advert_link_change(struct qlcnic_adapter *, int);
 void qlcnic_free_tx_rings(struct qlcnic_adapter *);
 int qlcnic_alloc_tx_rings(struct qlcnic_adapter *, struct net_device *);
 
@@ -1609,7 +1645,7 @@ static inline void qlcnic_write_crb(struct qlcnic_adapter *adapter, char *buf,
 	adapter->ahw->hw_ops->write_crb(adapter, buf, offset, size);
 }
 
-static inline u32 qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter,
+static inline int qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter,
 				       ulong off)
 {
 	return adapter->ahw->hw_ops->read_reg(adapter, off);
@@ -1832,6 +1868,12 @@ static inline bool qlcnic_82xx_check(struct qlcnic_adapter *adapter)
 	return (device == PCI_DEVICE_ID_QLOGIC_QLE824X) ? true : false;
 }
 
+static inline bool qlcnic_83xx_check(struct qlcnic_adapter *adapter)
+{
+	unsigned short device = adapter->pdev->device;
+	return (device == PCI_DEVICE_ID_QLOGIC_QLE834X) ? true : false;
+}
+
 #define QLCDB(adapter, lvl, _fmt, _args...) do {	\
 	if (NETIF_MSG_##lvl & adapter->ahw->msg_enable)	\
 		printk(KERN_INFO "%s: %s: " _fmt,	\
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
new file mode 100644
index 0000000..2f29dbb
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -0,0 +1,1654 @@
+#include "qlcnic.h"
+#include <linux/if_vlan.h>
+#include <linux/ipv6.h>
+#include <linux/ethtool.h>
+#include <linux/interrupt.h>
+
+#define QLCNIC_MAX_TX_QUEUES    1
+
+#define QLCNIC_MBX_RSP(reg)		LSW(reg)
+#define QLCNIC_MBX_NUM_REGS(reg)	(MSW(reg) & 0x1FF)
+#define QLCNIC_MBX_STATUS(reg)		(((reg) >> 25) & 0x7F)
+#define QLCNIC_MBX_HOST(ahw, i)	((ahw)->pci_base0 + ((i) * 4))
+#define QLCNIC_MBX_FW(ahw, i)		((ahw)->pci_base0 + 0x800 + ((i) * 4))
+
+static const struct qlcnic_mailbox_metadata qlcnic_83xx_mbx_tbl[] = {
+	{QLCNIC_CMD_CONFIGURE_IP_ADDR, 6, 1},
+	{QLCNIC_CMD_CONFIG_INTRPT, 18, 34},
+	{QLCNIC_CMD_CREATE_RX_CTX, 136, 27},
+	{QLCNIC_CMD_DESTROY_RX_CTX, 2, 1},
+	{QLCNIC_CMD_CREATE_TX_CTX, 54, 18},
+	{QLCNIC_CMD_DESTROY_TX_CTX, 2, 1},
+	{QLCNIC_CMD_CONFIGURE_MAC_LEARNING, 2, 1},
+	{QLCNIC_CMD_INTRPT_TEST, 22, 12},
+	{QLCNIC_CMD_SET_MTU, 3, 1},
+	{QLCNIC_CMD_READ_PHY, 4, 2},
+	{QLCNIC_CMD_WRITE_PHY, 5, 1},
+	{QLCNIC_CMD_READ_HW_REG, 4, 1},
+	{QLCNIC_CMD_GET_FLOW_CTL, 4, 2},
+	{QLCNIC_CMD_SET_FLOW_CTL, 4, 1},
+	{QLCNIC_CMD_READ_MAX_MTU, 4, 2},
+	{QLCNIC_CMD_READ_MAX_LRO, 4, 2},
+	{QLCNIC_CMD_MAC_ADDRESS, 4, 3},
+	{QLCNIC_CMD_GET_PCI_INFO, 1, 66},
+	{QLCNIC_CMD_GET_NIC_INFO, 2, 19},
+	{QLCNIC_CMD_SET_NIC_INFO, 32, 1},
+	{QLCNIC_CMD_GET_ESWITCH_CAPABILITY, 4, 3},
+	{QLCNIC_CMD_TOGGLE_ESWITCH, 4, 1},
+	{QLCNIC_CMD_GET_ESWITCH_STATUS, 4, 3},
+	{QLCNIC_CMD_SET_PORTMIRRORING, 4, 1},
+	{QLCNIC_CMD_CONFIGURE_ESWITCH, 4, 1},
+	{QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG, 4, 3},
+	{QLCNIC_CMD_GET_ESWITCH_STATS, 5, 1},
+	{QLCNIC_CMD_CONFIG_PORT, 4, 1},
+	{QLCNIC_CMD_TEMP_SIZE, 1, 4},
+	{QLCNIC_CMD_GET_TEMP_HDR, 5, 5},
+	{QLCNIC_CMD_GET_LINK_EVENT, 2, 1},
+	{QLCNIC_CMD_CONFIG_MAC_VLAN, 4, 3},
+	{QLCNIC_CMD_CONFIG_INTR_COAL, 6, 1},
+	{QLCNIC_CMD_CONFIGURE_RSS, 14, 1},
+	{QLCNIC_CMD_CONFIGURE_LED, 2, 1},
+	{QLCNIC_CMD_CONFIGURE_MAC_RX_MODE, 2, 1},
+	{QLCNIC_CMD_CONFIGURE_HW_LRO, 2, 1},
+	{QLCNIC_CMD_GET_STATISTICS, 2, 80},
+	{QLCNIC_CMD_SET_PORT_CONFIG, 2, 1},
+	{QLCNIC_CMD_GET_PORT_CONFIG, 2, 2},
+	{QLCNIC_CMD_GET_LINK_STATUS, 2, 4},
+	{QLCNIC_CMD_IDC_ACK, 5, 1},
+	{QLCNIC_CMD_INIT_NIC_FUNC, 2, 1},
+	{QLCNIC_CMD_STOP_NIC_FUNC, 2, 1},
+	{QLCNIC_CMD_SET_LED_CONFIG, 5, 1},
+	{QLCNIC_CMD_GET_LED_CONFIG, 1, 5},
+	{QLCNIC_CMD_ADD_RCV_RINGS, 130, 26},
+};
+
+static const u32 qlcnic_83xx_ext_reg_tbl[] = {
+	0x38CC,		/* Global Reset */
+	0x38F0,		/* Wildcard */
+	0x38FC,		/* Informant */
+	0x3038,		/* Host MBX ctrl */
+	0x303C,		/* FW MBX ctrl */
+	0x355C,		/* BOOT LOADER ADDRESS REG */
+	0x3560,		/* BOOT LOADER SIZE REG */
+	0x3564,		/* FW IMAGE ADDR REG */
+	0x1000,		/* MBX intr enable */
+	0x1200,		/* Default Intr mask */
+	0x1204,		/* Default Interrupt ID */
+	0x3780,		/* QLC_83XX_IDC_MAJ_VERSION */
+	0x3784,		/* QLC_83XX_IDC_DEV_STATE */
+	0x3788,		/* QLC_83XX_IDC_DRV_PRESENCE */
+	0x378C,		/* QLC_83XX_IDC_DRV_ACK */
+	0x3790,		/* QLC_83XX_IDC_CTRL */
+	0x3794,		/* QLC_83XX_IDC_DRV_AUDIT */
+	0x3798,		/* QLC_83XX_IDC_MIN_VERSION */
+	0x379C,		/* QLC_83XX_RECOVER_DRV_LOCK */
+	0x37A0,		/* QLC_83XX_IDC_PF_0 */
+	0x37A4,		/* QLC_83XX_IDC_PF_1 */
+	0x37A8,		/* QLC_83XX_IDC_PF_2 */
+	0x37AC,		/* QLC_83XX_IDC_PF_3 */
+	0x37B0,		/* QLC_83XX_IDC_PF_4 */
+	0x37B4,		/* QLC_83XX_IDC_PF_5 */
+	0x37B8,		/* QLC_83XX_IDC_PF_6 */
+	0x37BC,		/* QLC_83XX_IDC_PF_7 */
+	0x37C0,		/* QLC_83XX_IDC_PF_8 */
+	0x37C4,		/* QLC_83XX_IDC_PF_9 */
+	0x37C8,		/* QLC_83XX_IDC_PF_10 */
+	0x37CC,		/* QLC_83XX_IDC_PF_11 */
+	0x37D0,		/* QLC_83XX_IDC_PF_12 */
+	0x37D4,		/* QLC_83XX_IDC_PF_13 */
+	0x37D8,		/* QLC_83XX_IDC_PF_14 */
+	0x37DC,		/* QLC_83XX_IDC_PF_15 */
+	0x37E0,		/* QLC_83XX_IDC_DEV_PARTITION_INFO_1 */
+	0x37E4,		/* QLC_83XX_IDC_DEV_PARTITION_INFO_2 */
+	0x37F0,		/* QLC_83XX_DRV_OP_MODE */
+	0x37F4,		/* QLC_83XX_VNIC_STATE */
+	0x3868,		/* QLC_83XX_DRV_LOCK */
+	0x386C,		/* QLC_83XX_DRV_UNLOCK */
+	0x3504,		/* QLC_83XX_DRV_LOCK_ID */
+	0x34A4,		/* QLC_83XX_ASIC_TEMP */
+};
+
+static const u32 qlcnic_83xx_reg_tbl[] = {
+	0x34A8,		/* PEG_HALT_STAT1 */
+	0x34AC,		/* PEG_HALT_STAT2 */
+	0x34B0,		/* FW_HEARTBEAT */
+	0x3500,		/* FLASH LOCK_ID */
+	0x3528,		/* FW_CAPABILITIES */
+	0x3538,		/* Driver active, DRV_REG0 */
+	0x3540,		/* Device state, DRV_REG1 */
+	0x3544,		/* Driver state, DRV_REG2 */
+	0x3548,		/* Driver scratch, DRV_REG3 */
+	0x354C,		/* Device partiton info, DRV_REG4 */
+	0x3524,		/* Driver IDC ver, DRV_REG5 */
+	0x3550,		/* FW_VER_MAJOR */
+	0x3554,		/* FW_VER_MINOR */
+	0x3558,		/* FW_VER_SUB */
+	0x359C,		/* NPAR STATE */
+	0x35FC,		/* FW_IMG_VALID */
+	0x3650,		/* CMD_PEG_STATE */
+	0x373C,		/* RCV_PEG_STATE */
+	0x37B4,		/* ASIC TEMP */
+	0x356C,		/* FW API */
+	0x3570,		/* DRV OP MODE */
+	0x3850,		/* FLASH LOCK */
+	0x3854,		/* FLASH UNLOCK */
+};
+
+static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
+	.read_crb			= qlcnic_83xx_read_crb,
+	.write_crb			= qlcnic_83xx_write_crb,
+	.read_reg			= qlcnic_83xx_rd_reg_indirect,
+	.write_reg			= qlcnic_83xx_wrt_reg_indirect,
+	.get_mac_address		= qlcnic_83xx_get_mac_address,
+	.setup_intr			= qlcnic_83xx_setup_intr,
+	.alloc_mbx_args			= qlcnic_83xx_alloc_mbx_args,
+	.mbx_cmd			= qlcnic_83xx_mbx_op,
+	.get_func_no			= qlcnic_83xx_get_func_no,
+	.api_lock			= qlcnic_83xx_cam_lock,
+	.api_unlock			= qlcnic_83xx_cam_unlock,
+	.create_rx_ctx			= qlcnic_83xx_create_rx_ctx,
+	.create_tx_ctx			= qlcnic_83xx_create_tx_ctx,
+	.setup_link_event		= qlcnic_83xx_setup_link_event,
+	.get_nic_info			= qlcnic_83xx_get_nic_info,
+	.get_pci_info			= qlcnic_83xx_get_pci_info,
+	.set_nic_info			= qlcnic_83xx_set_nic_info,
+	.change_macvlan			= qlcnic_83xx_sre_macaddr_change,
+	.config_intr_coal		= qlcnic_83xx_config_intr_coal,
+	.config_rss			= qlcnic_83xx_config_rss,
+	.config_hw_lro			= qlcnic_83xx_config_hw_lro,
+	.config_loopback		= qlcnic_83xx_set_lb_mode,
+	.clear_loopback			= qlcnic_83xx_clear_lb_mode,
+	.config_promisc_mode		= qlcnic_83xx_nic_set_promisc,
+	.change_l2_filter		= qlcnic_83xx_change_l2_filter,
+	.get_board_info			= qlcnic_83xx_get_port_info,
+};
+
+static struct qlcnic_nic_template qlcnic_83xx_ops = {
+	.config_bridged_mode	= qlcnic_config_bridged_mode,
+	.config_led		= qlcnic_config_led,
+	.config_ipaddr		= qlcnic_83xx_config_ipaddr,
+	.clear_legacy_intr	= qlcnic_83xx_clear_legacy_intr,
+};
+
+void qlcnic_83xx_register_map(struct qlcnic_hardware_context *ahw)
+{
+	ahw->hw_ops		= &qlcnic_83xx_hw_ops;
+	ahw->reg_tbl		= (u32 *)qlcnic_83xx_reg_tbl;
+	ahw->ext_reg_tbl	= (u32 *)qlcnic_83xx_ext_reg_tbl;
+}
+
+int qlcnic_83xx_get_fw_version(struct qlcnic_adapter *adapter)
+{
+	u32 fw_major, fw_minor, fw_build;
+	struct pci_dev *pdev = adapter->pdev;
+
+	fw_major = QLCRD(adapter, QLCNIC_FW_VERSION_MAJOR);
+	fw_minor = QLCRD(adapter, QLCNIC_FW_VERSION_MINOR);
+	fw_build = QLCRD(adapter, QLCNIC_FW_VERSION_SUB);
+	adapter->fw_version = QLCNIC_VERSION_CODE(fw_major, fw_minor, fw_build);
+
+	dev_info(&pdev->dev, "Driver v%s, firmware version %d.%d.%d\n",
+		 QLCNIC_LINUX_VERSIONID, fw_major, fw_minor, fw_build);
+
+	return adapter->fw_version;
+}
+
+static int __qlcnic_set_win_base(struct qlcnic_adapter *adapter, u32 addr)
+{
+	void __iomem *base;
+	u32 val;
+
+	base = adapter->ahw->pci_base0 +
+	       QLC_83XX_CRB_WIN_FUNC(adapter->ahw->pci_func);
+	writel(addr, base);
+	val = readl(base);
+	if (val != addr)
+		return -EIO;
+
+	return 0;
+}
+
+int qlcnic_83xx_rd_reg_indirect(struct qlcnic_adapter *adapter, ulong addr)
+{
+	int ret;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	ret = __qlcnic_set_win_base(adapter, (u32) addr);
+	if (!ret) {
+		return QLCRDX(ahw, QLCNIC_WILDCARD);
+	} else {
+		dev_err(&adapter->pdev->dev,
+			"%s failed, addr = 0x%x\n", __func__, (int)addr);
+		return -EIO;
+	}
+}
+
+int qlcnic_83xx_wrt_reg_indirect(struct qlcnic_adapter *adapter, ulong addr,
+				 u32 data)
+{
+	int err;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	err = __qlcnic_set_win_base(adapter, (u32) addr);
+	if (!err) {
+		QLCWRX(ahw, QLCNIC_WILDCARD, data);
+		return 0;
+	} else {
+		dev_err(&adapter->pdev->dev,
+			"%s failed, addr = 0x%x data = 0x%x\n",
+			__func__, (int)addr, data);
+		return err;
+	}
+}
+
+int qlcnic_83xx_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
+{
+	int err, i, num_msix;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	if (!num_intr)
+		num_intr = QLCNIC_DEF_NUM_STS_DESC_RINGS;
+	num_msix = rounddown_pow_of_two(min_t(int, num_online_cpus(),
+					      num_intr));
+	/* account for AEN interrupt MSI-X based interrupts */
+	num_msix += 1;
+	num_msix += adapter->max_drv_tx_rings;
+	err = qlcnic_enable_msix(adapter, num_msix);
+	if (err == -ENOMEM)
+		return err;
+	if (adapter->flags & QLCNIC_MSIX_ENABLED)
+		num_msix = adapter->ahw->num_msix;
+	else
+		num_msix = 1;
+	/* setup interrupt mapping table for fw */
+	ahw->intr_tbl = vzalloc(num_msix *
+				sizeof(struct qlcnic_intrpt_config));
+	if (!ahw->intr_tbl)
+		return -ENOMEM;
+	if (!(adapter->flags & QLCNIC_MSIX_ENABLED)) {
+		/* MSI-X enablement failed, use legacy interrupt */
+		adapter->tgt_status_reg = ahw->pci_base0 + QLC_83XX_INTX_PTR;
+		adapter->tgt_mask_reg = ahw->pci_base0 + QLC_83XX_INTX_MASK;
+		adapter->isr_int_vec = ahw->pci_base0 + QLC_83XX_INTX_TRGR;
+		adapter->msix_entries[0].vector = adapter->pdev->irq;
+		dev_info(&adapter->pdev->dev, "using legacy interrupt\n");
+	}
+
+	for (i = 0; i < num_msix; i++) {
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			ahw->intr_tbl[i].type = QLCNIC_INTRPT_MSIX;
+		else
+			ahw->intr_tbl[i].type = QLCNIC_INTRPT_INTX;
+		ahw->intr_tbl[i].id = i;
+		ahw->intr_tbl[i].src = 0;
+	}
+	return 0;
+}
+
+inline void qlcnic_83xx_enable_intr(struct qlcnic_adapter *adapter,
+				    struct qlcnic_host_sds_ring *sds_ring)
+{
+	writel(0, sds_ring->crb_intr_mask);
+	if (!QLCNIC_IS_MSI_FAMILY(adapter))
+		writel(0, adapter->tgt_mask_reg);
+}
+
+inline void qlcnic_83xx_enable_tx_intr(struct qlcnic_adapter *adapter,
+				       struct qlcnic_host_tx_ring *tx_ring)
+{
+	writel(0, tx_ring->crb_intr_mask);
+}
+
+inline void qlcnic_83xx_disable_tx_intr(struct qlcnic_adapter *adapter,
+					struct qlcnic_host_tx_ring *tx_ring)
+{
+	writel(1, tx_ring->crb_intr_mask);
+}
+
+inline void qlcnic_83xx_get_mbx_data(struct qlcnic_adapter *adapter,
+				     struct qlcnic_cmd_args *cmd)
+{
+	int i;
+	for (i = 0; i < cmd->rsp.num; i++)
+		cmd->rsp.arg[i] = readl(QLCNIC_MBX_FW(adapter->ahw, i));
+}
+
+irqreturn_t qlcnic_83xx_clear_legacy_intr(struct qlcnic_adapter *adapter)
+{
+	u32 intr_val;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	int retries = 0;
+
+	intr_val = readl(adapter->tgt_status_reg);
+
+	if (!QLC_83XX_VALID_INTX_BIT31(intr_val))
+		return IRQ_NONE;
+
+	if (QLC_83XX_INTX_FUNC(intr_val) != adapter->ahw->pci_func) {
+		adapter->stats.spurious_intr++;
+		return IRQ_NONE;
+	}
+	/* clear the interrupt trigger control register */
+	writel(0, adapter->isr_int_vec);
+	do {
+		intr_val = readl(adapter->tgt_status_reg);
+		if (QLC_83XX_INTX_FUNC(intr_val) != ahw->pci_func)
+			break;
+		retries++;
+	} while (QLC_83XX_VALID_INTX_BIT30(intr_val) &&
+		 (retries < QLC_83XX_LEGACY_INTX_MAX_RETRY));
+
+	if (retries == QLC_83XX_LEGACY_INTX_MAX_RETRY) {
+		dev_info(&adapter->pdev->dev,
+			 "Reached maximum retries to clear legacy interrupt\n");
+		return IRQ_NONE;
+	}
+
+	mdelay(QLC_83XX_LEGACY_INTX_DELAY);
+
+	return IRQ_HANDLED;
+}
+
+irqreturn_t qlcnic_83xx_tmp_intr(int irq, void *data)
+{
+	struct qlcnic_host_sds_ring *sds_ring = data;
+	struct qlcnic_adapter *adapter = sds_ring->adapter;
+
+	if (adapter->flags & QLCNIC_MSIX_ENABLED)
+		goto done;
+
+	if (adapter->nic_ops->clear_legacy_intr(adapter) == IRQ_NONE)
+		return IRQ_NONE;
+
+done:
+	adapter->ahw->diag_cnt++;
+	qlcnic_83xx_enable_intr(adapter, sds_ring);
+
+	return IRQ_HANDLED;
+}
+
+void qlcnic_83xx_free_mbx_intr(struct qlcnic_adapter *adapter)
+{
+	u32 val = 0;
+	u32 num_msix = adapter->ahw->num_msix - 1;
+
+	val = (num_msix << 8);
+
+	QLCWRX(adapter->ahw, QLCNIC_MBX_INTR_ENBL, val);
+	if (adapter->flags & QLCNIC_MSIX_ENABLED)
+		free_irq(adapter->msix_entries[num_msix].vector, adapter);
+}
+
+int qlcnic_83xx_setup_mbx_intr(struct qlcnic_adapter *adapter)
+{
+	irq_handler_t handler;
+	u32 val;
+	char name[32];
+	int err = 0;
+	unsigned long flags = 0;
+
+	if (!(adapter->flags & QLCNIC_MSI_ENABLED) &&
+	    !(adapter->flags & QLCNIC_MSIX_ENABLED))
+		flags |= IRQF_SHARED;
+
+	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
+		handler = qlcnic_83xx_handle_aen;
+		val = adapter->msix_entries[adapter->ahw->num_msix - 1].vector;
+		snprintf(name, (IFNAMSIZ + 4),
+			 "%s[%s]", adapter->netdev->name, "aen");
+		err = request_irq(val, handler, flags, name, adapter);
+		if (err) {
+			dev_err(&adapter->pdev->dev,
+				"failed to register MBX interrupt\n");
+			return err;
+		}
+	}
+
+	/* Enable mailbox interrupt */
+	qlcnic_83xx_enable_mbx_intrpt(adapter);
+	if (adapter->flags & QLCNIC_MSIX_ENABLED)
+		err = qlcnic_83xx_config_intrpt(adapter, 1);
+
+	return err;
+}
+
+void qlcnic_83xx_get_func_no(struct qlcnic_adapter *adapter)
+{
+	u32 val = QLCRDX(adapter->ahw, QLCNIC_INFORMANT);
+	adapter->ahw->pci_func = val & 0xf;
+}
+
+int qlcnic_83xx_cam_lock(struct qlcnic_adapter *adapter)
+{
+	void __iomem *addr;
+	u32 val;
+	u32 timeo = 0;
+
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	addr = ahw->pci_base0 + QLC_83XX_SEM_LOCK_FUNC(ahw->pci_func);
+	do {
+		val = readl(addr);
+		if (val) {
+			/* write the function number to register */
+			QLCWR(adapter, QLCNIC_FLASH_LOCK_OWNER, ahw->pci_func);
+			return 0;
+		}
+		usleep_range(1000, 2000);
+	} while (++timeo <= QLCNIC_PCIE_SEM_TIMEOUT);
+
+	return -EIO;
+}
+
+void qlcnic_83xx_cam_unlock(struct qlcnic_adapter *adapter)
+{
+	void __iomem *addr;
+	u32 val;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	addr = ahw->pci_base0 + QLC_83XX_SEM_UNLOCK_FUNC(ahw->pci_func);
+	val = readl(addr);
+}
+
+void qlcnic_83xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
+			  loff_t offset, size_t size)
+{
+	int ret;
+	u32 data;
+
+	if (qlcnic_api_lock(adapter)) {
+		dev_err(&adapter->pdev->dev,
+			"%s: failed to acquire lock. addr offset 0x%x\n",
+			__func__, (u32)offset);
+		return;
+	}
+
+	ret = qlcnic_83xx_rd_reg_indirect(adapter, (u32) offset);
+	qlcnic_api_unlock(adapter);
+
+	if (ret == -EIO) {
+		dev_err(&adapter->pdev->dev,
+			"%s: failed. addr offset 0x%x\n",
+			__func__, (u32)offset);
+		return;
+	}
+	data = ret;
+	memcpy(buf, &data, size);
+}
+
+void qlcnic_83xx_write_crb(struct qlcnic_adapter *adapter, char *buf,
+			   loff_t offset, size_t size)
+{
+	u32 data;
+
+	memcpy(&data, buf, size);
+	qlcnic_83xx_wrt_reg_indirect(adapter, (u32) offset, data);
+}
+
+int qlcnic_83xx_get_port_info(struct qlcnic_adapter *adapter)
+{
+	int status;
+
+	status = qlcnic_83xx_get_port_config(adapter);
+	if (status) {
+		dev_err(&adapter->pdev->dev,
+			"Get Port Info failed\n");
+	} else {
+		if (QLC_83XX_SFP_10G_CAPABLE(adapter->ahw->port_config))
+			adapter->ahw->port_type = QLCNIC_XGBE;
+		else
+			adapter->ahw->port_type = QLCNIC_GBE;
+		if (QLC_83XX_AUTONEG(adapter->ahw->port_config))
+			adapter->ahw->link_autoneg = AUTONEG_ENABLE;
+	}
+	return status;
+}
+
+void qlcnic_83xx_enable_mbx_intrpt(struct qlcnic_adapter *adapter)
+{
+	u32 val;
+
+	if (adapter->flags & QLCNIC_MSIX_ENABLED)
+		val = BIT_2 | ((adapter->ahw->num_msix - 1) << 8);
+	else
+		val = BIT_2;
+	QLCWRX(adapter->ahw, QLCNIC_MBX_INTR_ENBL, val);
+}
+
+void qlcnic_set_npar_data(struct qlcnic_adapter *adapter,
+			  const struct qlcnic_info *nic_info,
+			  struct qlcnic_info *npar_info)
+{
+	npar_info->pci_func = (le16_to_cpu(nic_info->pci_func)) & 0xF;
+	npar_info->op_mode = le16_to_cpu(nic_info->op_mode);
+	npar_info->phys_port = le16_to_cpu(nic_info->phys_port);
+	npar_info->switch_mode = le16_to_cpu(nic_info->switch_mode);
+	npar_info->max_tx_ques = le16_to_cpu(nic_info->max_tx_ques);
+	npar_info->max_rx_ques = le16_to_cpu(nic_info->max_rx_ques);
+	npar_info->min_tx_bw = le16_to_cpu(nic_info->min_tx_bw);
+	npar_info->max_tx_bw = le16_to_cpu(nic_info->max_tx_bw);
+	npar_info->capabilities = le32_to_cpu(nic_info->capabilities);
+	npar_info->max_mtu = le16_to_cpu(nic_info->max_mtu);
+
+}
+
+void qlcnic_83xx_check_vf(struct qlcnic_adapter *adapter,
+			  const struct pci_device_id *ent)
+{
+	u32 op_mode, priv_level;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	/* Determine FW API version */
+	ahw->fw_hal_version = 2;
+	/* Find PCI function number */
+	qlcnic_get_func_no(adapter);
+
+	/* Determine function privilege level */
+	op_mode = QLCRDX(adapter->ahw, QLC_83XX_DRV_OP_MODE);
+	if (op_mode == QLC_83XX_DEFAULT_OPMODE)
+		priv_level = QLCNIC_MGMT_FUNC;
+	else
+		priv_level = QLC_83XX_GET_FUNC_PRIVILEGE(op_mode,
+							 ahw->pci_func);
+
+	if (priv_level == QLCNIC_NON_PRIV_FUNC) {
+		ahw->op_mode = QLCNIC_NON_PRIV_FUNC;
+		dev_info(&adapter->pdev->dev,
+			 "HAL Version: %d Non Privileged function\n",
+			 ahw->fw_hal_version);
+		adapter->nic_ops = &qlcnic_vf_ops;
+	} else {
+		adapter->nic_ops = &qlcnic_83xx_ops;
+	}
+}
+
+static void qlcnic_83xx_handle_link_aen(struct qlcnic_adapter *adapter,
+					u32 data[]);
+static void qlcnic_83xx_handle_idc_comp_aen(struct qlcnic_adapter *adapter,
+					    u32 data[]);
+
+static void qlcnic_dump_mbx(struct qlcnic_adapter *adapter,
+			    struct qlcnic_cmd_args *cmd)
+{
+	int i;
+
+	dev_info(&adapter->pdev->dev,
+		 "Host MBX regs(%d)\n", cmd->req.num);
+	for (i = 0; i < cmd->req.num; i++) {
+		if (i && !(i % 8))
+			pr_info("\n");
+		pr_info("%08x ", le32_to_cpu(cmd->req.arg[i]));
+	}
+	pr_info("\n");
+	dev_info(&adapter->pdev->dev,
+		 "FW MBX regs(%d)\n", cmd->rsp.num);
+	for (i = 0; i < cmd->rsp.num; i++) {
+		if (i && !(i % 8))
+			pr_info("\n");
+		pr_info("%08x ", le32_to_cpu(cmd->rsp.arg[i]));
+	}
+	pr_info("\n");
+}
+
+static u32 qlcnic_83xx_mbx_poll(struct qlcnic_adapter *adapter)
+{
+	u32 data;
+	unsigned long wait_time = 0;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	/* wait for mailbox completion */
+	do {
+		data = QLCRDX(ahw, QLCNIC_FW_MBX_CTRL);
+		if (++wait_time > QLCNIC_MBX_TIMEOUT) {
+			data = QLCNIC_RCODE_TIMEOUT;
+			break;
+		}
+		mdelay(1);
+	} while (!data);
+	return data;
+}
+
+int qlcnic_83xx_mbx_op(struct qlcnic_adapter *adapter,
+		       struct qlcnic_cmd_args *cmd)
+{
+	int i;
+	u16 opcode;
+	u8 mbx_err_code, mac_cmd_rcode;
+	u32 rsp, mbx_val, fw_data, rsp_num, mbx_cmd, temp, fw[8];
+	unsigned long flags;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	opcode = LSW(le32_to_cpu(cmd->req.arg[0]));
+	spin_lock_irqsave(&ahw->mbx_lock, flags);
+	mbx_val = QLCRDX(ahw, QLCNIC_HOST_MBX_CTRL);
+
+	if (mbx_val) {
+		QLCDB(adapter, DRV,
+		      "Mailbox cmd attempted, 0x%x\n", opcode);
+		QLCDB(adapter, DRV,
+		      "Mailbox not available, 0x%x, collect FW dump\n",
+		      mbx_val);
+		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
+		spin_unlock_irqrestore(&ahw->mbx_lock, flags);
+		return cmd->rsp.arg[0];
+	}
+
+	/* Fill in mailbox registers */
+	mbx_cmd = cpu_to_le32(cmd->req.arg[0]);
+	writel(mbx_cmd, QLCNIC_MBX_HOST(ahw, 0));
+	for (i = 1; i < cmd->req.num; i++)
+		writel(cmd->req.arg[i], QLCNIC_MBX_HOST(ahw, i));
+
+	/* Signal FW about the impending command */
+	QLCWRX(ahw, QLCNIC_HOST_MBX_CTRL, QLCNIC_SET_OWNER);
+poll:
+	rsp = qlcnic_83xx_mbx_poll(adapter);
+	/* Get the FW response data */
+	fw_data = readl(QLCNIC_MBX_FW(ahw, 0));
+	mbx_err_code = QLCNIC_MBX_STATUS(fw_data);
+	rsp_num = QLCNIC_MBX_NUM_REGS(fw_data);
+	opcode = QLCNIC_MBX_RSP(fw_data);
+
+	if (rsp != QLCNIC_RCODE_TIMEOUT) {
+		if (opcode == QLCNIC_MBX_LINK_EVENT) {
+			for (i = 0; i < rsp_num; i++) {
+				temp = readl(QLCNIC_MBX_FW(ahw, i));
+				fw[i] = temp;
+			}
+			qlcnic_83xx_handle_link_aen(adapter, fw);
+			/* clear fw mbx control register */
+			QLCWRX(ahw, QLCNIC_FW_MBX_CTRL, QLCNIC_CLR_OWNER);
+			mbx_val = QLCRDX(ahw, QLCNIC_HOST_MBX_CTRL);
+			if (mbx_val)
+				goto poll;
+		} else if (opcode == QLCNIC_MBX_COMP_EVENT) {
+			for (i = 0; i < rsp_num; i++) {
+				temp = readl(QLCNIC_MBX_FW(ahw, i));
+				fw[i] = temp;
+			}
+			qlcnic_83xx_handle_idc_comp_aen(adapter, fw);
+			/* clear fw mbx control register */
+			QLCWRX(ahw, QLCNIC_FW_MBX_CTRL, QLCNIC_CLR_OWNER);
+			mbx_val = QLCRDX(ahw, QLCNIC_HOST_MBX_CTRL);
+			if (mbx_val)
+				goto poll;
+		} else if (opcode == QLCNIC_MBX_REQUEST_EVENT) {
+			/* IDC Request Notification */
+			for (i = 0; i < rsp_num; i++) {
+				temp = readl(QLCNIC_MBX_FW(ahw, i));
+				fw[i] = temp;
+			}
+			for (i = 0; i < QLC_83XX_MBX_AEN_CNT; i++) {
+				temp = QLCNIC_MBX_RSP(fw[i]);
+				adapter->ahw->mbox_aen[i] = temp;
+			}
+			queue_delayed_work(adapter->qlcnic_wq,
+					   &adapter->idc_aen_work, 0);
+			/* clear fw mbx control register */
+			QLCWRX(ahw, QLCNIC_FW_MBX_CTRL, QLCNIC_CLR_OWNER);
+			mbx_val = QLCRDX(ahw, QLCNIC_HOST_MBX_CTRL);
+			if (mbx_val)
+				goto poll;
+		} else if ((mbx_err_code == QLCNIC_MBX_RSP_OK) ||
+			   (mbx_err_code == QLCNIC_MBX_PORT_RSP_OK)) {
+			qlcnic_83xx_get_mbx_data(adapter, cmd);
+			rsp = QLCNIC_RCODE_SUCCESS;
+		} else {
+			qlcnic_83xx_get_mbx_data(adapter, cmd);
+			if (opcode == QLCNIC_CMD_CONFIG_MAC_VLAN) {
+				fw_data = readl(QLCNIC_MBX_FW(ahw, 2));
+				mac_cmd_rcode = (u8)fw_data;
+				if (mac_cmd_rcode == QLCNIC_NO_CARD_RESOURCE ||
+				    mac_cmd_rcode == QLCNIC_MAC_PRESENT ||
+				    mac_cmd_rcode == QLCNIC_MAC_NOT_PRESENT) {
+					rsp = QLCNIC_RCODE_SUCCESS;
+					goto out;
+				}
+			}
+			dev_info(&adapter->pdev->dev,
+				 "MBX command 0x%x failed with err:0x%x\n",
+				 opcode, mbx_err_code);
+			rsp = mbx_err_code;
+			qlcnic_dump_mbx(adapter, cmd);
+		}
+	} else {
+		dev_info(&adapter->pdev->dev,
+			 "MBX command 0x%x timed out\n", opcode);
+		qlcnic_dump_mbx(adapter, cmd);
+	}
+out:
+	/* clear fw mbx control register */
+	QLCWRX(ahw, QLCNIC_FW_MBX_CTRL, QLCNIC_CLR_OWNER);
+	spin_unlock_irqrestore(&ahw->mbx_lock, flags);
+	return rsp;
+}
+
+int qlcnic_83xx_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
+			       struct qlcnic_adapter *adapter, u32 type)
+{
+	int i, size;
+	u32 temp;
+	const struct qlcnic_mailbox_metadata *mbx_tbl;
+
+	mbx_tbl = qlcnic_83xx_mbx_tbl;
+	size = ARRAY_SIZE(qlcnic_83xx_mbx_tbl);
+	for (i = 0; i < size; i++) {
+		if (type == mbx_tbl[i].cmd) {
+			mbx->req.num = mbx_tbl[i].in_args;
+			mbx->rsp.num = mbx_tbl[i].out_args;
+			mbx->req.arg = kcalloc(mbx->req.num, sizeof(u32),
+					       GFP_ATOMIC);
+			if (!mbx->req.arg)
+				return -ENOMEM;
+			mbx->rsp.arg = kcalloc(mbx->rsp.num, sizeof(u32),
+					       GFP_ATOMIC);
+			if (!mbx->rsp.arg) {
+				kfree(mbx->req.arg);
+				mbx->req.arg = NULL;
+				return -ENOMEM;
+			}
+			memset(mbx->req.arg, 0, sizeof(u32) * mbx->req.num);
+			memset(mbx->rsp.arg, 0, sizeof(u32) * mbx->rsp.num);
+			temp = adapter->ahw->fw_hal_version << 29;
+			mbx->req.arg[0] = (type | (mbx->req.num << 16) | temp);
+			break;
+		}
+	}
+	return 0;
+}
+
+void qlcnic_83xx_idc_aen_work(struct work_struct *work)
+{
+	struct qlcnic_adapter *adapter;
+	struct qlcnic_cmd_args cmd;
+	int i, err = 0;
+
+	adapter = container_of(work, struct qlcnic_adapter, idc_aen_work.work);
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_IDC_ACK);
+
+	for (i = 1; i < QLC_83XX_MBX_AEN_CNT; i++)
+		cmd.req.arg[i] = adapter->ahw->mbox_aen[i];
+
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err)
+		dev_info(&adapter->pdev->dev,
+			 "%s: Mailbox IDC ACK failed.\n", __func__);
+	qlcnic_free_mbx_args(&cmd);
+}
+
+static void qlcnic_83xx_handle_idc_comp_aen(struct qlcnic_adapter *adapter,
+					    u32 data[])
+{
+	dev_dbg(&adapter->pdev->dev, "Completion AEN:0x%x.\n",
+		QLCNIC_MBX_RSP(data[0]));
+	return;
+}
+
+void qlcnic_83xx_process_aen(struct qlcnic_adapter *adapter)
+{
+	unsigned long flags;
+	u32 mask, resp, event[QLC_83XX_MBX_AEN_CNT];
+	int i;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	spin_lock_irqsave(&ahw->mbx_lock, flags);
+	resp = QLCRDX(ahw, QLCNIC_FW_MBX_CTRL);
+
+	if (!(resp & QLCNIC_SET_OWNER))
+		goto out;
+
+	for (i = 0; i < QLC_83XX_MBX_AEN_CNT; i++)
+		event[i] = readl(QLCNIC_MBX_FW(ahw, i));
+
+	switch (QLCNIC_MBX_RSP(event[0])) {
+
+	case QLCNIC_MBX_LINK_EVENT:
+		qlcnic_83xx_handle_link_aen(adapter, event);
+		break;
+	case QLCNIC_MBX_COMP_EVENT:
+		qlcnic_83xx_handle_idc_comp_aen(adapter, event);
+		break;
+	case QLCNIC_MBX_REQUEST_EVENT:
+		for (i = 0; i < QLC_83XX_MBX_AEN_CNT; i++)
+			adapter->ahw->mbox_aen[i] = QLCNIC_MBX_RSP(event[i]);
+		queue_delayed_work(adapter->qlcnic_wq,
+				   &adapter->idc_aen_work, 0);
+		break;
+	case QLCNIC_MBX_TIME_EXTEND_EVENT:
+		break;
+	case QLCNIC_MBX_SFP_INSERT_EVENT:
+		dev_info(&adapter->pdev->dev, "SFP+ Insert AEN:0x%x.\n",
+			 QLCNIC_MBX_RSP(event[0]));
+		break;
+	case QLCNIC_MBX_SFP_REMOVE_EVENT:
+		dev_info(&adapter->pdev->dev, "SFP Removed AEN:0x%x.\n",
+			 QLCNIC_MBX_RSP(event[0]));
+		break;
+	default:
+		dev_dbg(&adapter->pdev->dev, "Unsupported AEN:0x%x.\n",
+			QLCNIC_MBX_RSP(event[0]));
+		break;
+	}
+
+	QLCWRX(ahw, QLCNIC_FW_MBX_CTRL, QLCNIC_CLR_OWNER);
+out:
+	mask = QLCRDX(adapter->ahw, QLCNIC_DEF_INT_MASK);
+	writel(0, adapter->ahw->pci_base0 + mask);
+	spin_unlock_irqrestore(&ahw->mbx_lock, flags);
+}
+
+static int qlcnic_83xx_add_rings(struct qlcnic_adapter *adapter)
+{
+	int index, i, err, sds_mbx_size;
+	u32 *buf, intrpt_id, intr_mask;
+	u16 context_id;
+	u8 num_sds;
+	struct qlcnic_cmd_args cmd;
+	struct qlcnic_host_sds_ring *sds;
+	struct qlcnic_sds_mbx sds_mbx;
+	struct qlcnic_add_rings_mbx_out *mbx_out;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	sds_mbx_size = sizeof(struct qlcnic_sds_mbx);
+	context_id = recv_ctx->context_id;
+	num_sds = (adapter->max_sds_rings - QLCNIC_MAX_RING_SETS);
+	ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+				    QLCNIC_CMD_ADD_RCV_RINGS);
+	cmd.req.arg[1] = cpu_to_le32(0 | (num_sds << 8) | (context_id << 16));
+
+	/* set up status rings, mbx 2-81 */
+	index = 2;
+	for (i = 8; i < adapter->max_sds_rings; i++) {
+		memset(&sds_mbx, 0, sds_mbx_size);
+		sds = &recv_ctx->sds_rings[i];
+		sds->consumer = 0;
+		memset(sds->desc_head, 0, STATUS_DESC_RINGSIZE(sds));
+		sds_mbx.phy_addr = cpu_to_le64(sds->phys_addr);
+		sds_mbx.sds_ring_size = cpu_to_le16(sds->num_desc);
+
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			intrpt_id = ahw->intr_tbl[i].id;
+		else
+			intrpt_id = QLCRDX(ahw, QLCNIC_DEF_INT_ID);
+
+		if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST)
+			sds_mbx.intrpt_id = cpu_to_le32(intrpt_id);
+		else
+			sds_mbx.intrpt_id = 0xffff;
+		sds_mbx.intrpt_val = 0;
+		buf = &cmd.req.arg[index];
+		memcpy(buf, &sds_mbx, sds_mbx_size);
+		index += sds_mbx_size / sizeof(u32);
+	}
+
+	/* send the mailbox command */
+	err = ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (err) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to add rings %d\n", err);
+		goto out;
+	}
+
+	mbx_out = (struct qlcnic_add_rings_mbx_out *)&cmd.rsp.arg[1];
+	index = 0;
+	/* status descriptor ring */
+	for (i = 8; i < adapter->max_sds_rings; i++) {
+		sds = &recv_ctx->sds_rings[i];
+		sds->crb_sts_consumer = ahw->pci_base0 +
+					le32_to_cpu(mbx_out->host_csmr[index]);
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			intr_mask = ahw->intr_tbl[i].src;
+		else
+			intr_mask = QLCRDX(ahw, QLCNIC_DEF_INT_MASK);
+
+		sds->crb_intr_mask = ahw->pci_base0 + intr_mask;
+		index++;
+	}
+out:
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+int qlcnic_83xx_create_rx_ctx(struct qlcnic_adapter *adapter)
+{
+	int i, err, index, sds_mbx_size, rds_mbx_size;
+	u8 num_sds, num_rds;
+	u32 *buf, intrpt_id, intr_mask, cap = 0;
+	struct qlcnic_host_sds_ring *sds;
+	struct qlcnic_host_rds_ring *rds;
+	struct qlcnic_sds_mbx sds_mbx;
+	struct qlcnic_rds_mbx rds_mbx;
+	struct qlcnic_cmd_args cmd;
+	struct qlcnic_rcv_mbx_out *mbx_out;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	num_rds = adapter->max_rds_rings;
+
+	if (adapter->max_sds_rings <= QLCNIC_MAX_RING_SETS)
+		num_sds = adapter->max_sds_rings;
+	else
+		num_sds = QLCNIC_MAX_RING_SETS;
+
+	sds_mbx_size = sizeof(struct qlcnic_sds_mbx);
+	rds_mbx_size = sizeof(struct qlcnic_rds_mbx);
+	cap = QLCNIC_CAP0_LEGACY_CONTEXT;
+
+	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP)
+		cap |= QLCNIC_FW_83XX_CAP_LRO_MSS;
+
+	/* set mailbox hdr and capabilities */
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+			      QLCNIC_CMD_CREATE_RX_CTX);
+	cmd.req.arg[1] = cpu_to_le32(cap);
+	cmd.req.arg[5] = cpu_to_le32(1 | (num_rds << 5) | (num_sds << 8) |
+				     (QLCNIC_HOST_83XX_RDS_MODE_UNIQUE << 16));
+	/* set up status rings, mbx 8-57/87 */
+	index = QLCNIC_HOST_SDS_MBX_IDX;
+	for (i = 0; i < num_sds; i++) {
+		memset(&sds_mbx, 0, sds_mbx_size);
+		sds = &recv_ctx->sds_rings[i];
+		sds->consumer = 0;
+		memset(sds->desc_head, 0, STATUS_DESC_RINGSIZE(sds));
+		sds_mbx.phy_addr = cpu_to_le64(sds->phys_addr);
+		sds_mbx.sds_ring_size = cpu_to_le16(sds->num_desc);
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			intrpt_id = ahw->intr_tbl[i].id;
+		else
+			intrpt_id = QLCRDX(ahw, QLCNIC_DEF_INT_ID);
+		if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST)
+			sds_mbx.intrpt_id = cpu_to_le32(intrpt_id);
+		else
+			sds_mbx.intrpt_id = 0xffff;
+		sds_mbx.intrpt_val = 0;
+		buf = &cmd.req.arg[index];
+		memcpy(buf, &sds_mbx, sds_mbx_size);
+		index += sds_mbx_size / sizeof(u32);
+	}
+	/* set up receive rings, mbx 88-111/135 */
+	index = QLCNIC_HOST_RDS_MBX_IDX;
+	rds = &recv_ctx->rds_rings[0];
+	rds->producer = 0;
+	memset(&rds_mbx, 0, rds_mbx_size);
+	rds_mbx.phy_addr_reg = cpu_to_le64(rds->phys_addr);
+	rds_mbx.reg_ring_sz = cpu_to_le16(rds->dma_size);
+	rds_mbx.reg_ring_len = cpu_to_le16(rds->num_desc);
+	/* Jumbo ring */
+	rds = &recv_ctx->rds_rings[1];
+	rds->producer = 0;
+	rds_mbx.phy_addr_jmb = cpu_to_le64(rds->phys_addr);
+	rds_mbx.jmb_ring_sz = cpu_to_le16(rds->dma_size);
+	rds_mbx.jmb_ring_len = cpu_to_le16(rds->num_desc);
+	buf = &cmd.req.arg[index];
+	memcpy(buf, &rds_mbx, rds_mbx_size);
+
+	/* send the mailbox command */
+	err = ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (err) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to create Rx ctx in firmware%d\n", err);
+		goto out;
+	}
+	mbx_out = (struct qlcnic_rcv_mbx_out *)&cmd.rsp.arg[1];
+	recv_ctx->context_id = le16_to_cpu(mbx_out->ctx_id);
+	recv_ctx->state = le32_to_cpu(mbx_out->state);
+	recv_ctx->virt_port = le16_to_cpu(mbx_out->vport_id);
+	dev_info(&adapter->pdev->dev, "Rx Context[%d] Created, state:0x%x\n",
+		 recv_ctx->context_id, recv_ctx->state);
+	/* Receive descriptor ring */
+	/* Standard ring */
+	rds = &recv_ctx->rds_rings[0];
+	rds->crb_rcv_producer = ahw->pci_base0 +
+				le32_to_cpu(mbx_out->host_prod[0].reg_buf);
+	/* Jumbo ring */
+	rds = &recv_ctx->rds_rings[1];
+	rds->crb_rcv_producer = ahw->pci_base0 +
+				le32_to_cpu(mbx_out->host_prod[0].jmb_buf);
+	/* status descriptor ring */
+	for (i = 0; i < num_sds; i++) {
+		sds = &recv_ctx->sds_rings[i];
+		sds->crb_sts_consumer = ahw->pci_base0 +
+					le32_to_cpu(mbx_out->host_csmr[i]);
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			intr_mask = ahw->intr_tbl[i].src;
+		else
+			intr_mask = QLCRDX(ahw, QLCNIC_DEF_INT_MASK);
+		sds->crb_intr_mask = ahw->pci_base0 + intr_mask;
+	}
+
+	if (adapter->max_sds_rings > QLCNIC_MAX_RING_SETS)
+		err = qlcnic_83xx_add_rings(adapter);
+out:
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+int qlcnic_83xx_create_tx_ctx(struct qlcnic_adapter *adapter,
+			      struct qlcnic_host_tx_ring *tx, int ring)
+{
+	int err;
+	u16 msix_id;
+	u32 *buf, intr_mask;
+	struct qlcnic_cmd_args cmd;
+	struct qlcnic_tx_mbx mbx;
+	struct qlcnic_tx_mbx_out *mbx_out;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	/* Reset host resources */
+	tx->producer = 0;
+	tx->sw_consumer = 0;
+	*(tx->hw_consumer) = 0;
+
+	memset(&mbx, 0, sizeof(struct qlcnic_tx_mbx));
+
+	/* setup mailbox inbox registerss */
+	mbx.phys_addr = cpu_to_le64(tx->phys_addr);
+	mbx.cnsmr_index = cpu_to_le64(tx->hw_cons_phys_addr);
+	mbx.size = cpu_to_le16(tx->num_desc);
+	if (adapter->flags & QLCNIC_MSIX_ENABLED)
+		msix_id = ahw->intr_tbl[adapter->max_sds_rings + ring].id;
+	else
+		msix_id = QLCRDX(ahw, QLCNIC_DEF_INT_ID);
+	if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST)
+		mbx.intr_id = cpu_to_le16(msix_id);
+	else
+		mbx.intr_id = 0xffff;
+	mbx.src = 0;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CREATE_TX_CTX);
+	cmd.req.arg[1] = cpu_to_le32(QLCNIC_CAP0_LEGACY_CONTEXT);
+	cmd.req.arg[5] = cpu_to_le32(QLCNIC_MAX_TX_QUEUES);
+	buf = &cmd.req.arg[6];
+	memcpy(buf, &mbx, sizeof(struct qlcnic_tx_mbx));
+	/* send the mailbox command*/
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to create Tx ctx in firmware 0x%x\n", err);
+		goto out;
+	}
+	mbx_out = (struct qlcnic_tx_mbx_out *)&cmd.rsp.arg[2];
+	tx->crb_cmd_producer = ahw->pci_base0 + le32_to_cpu(mbx_out->host_prod);
+	tx->ctx_id = le16_to_cpu(mbx_out->ctx_id);
+	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
+		intr_mask = ahw->intr_tbl[adapter->max_sds_rings + ring].src;
+		tx->crb_intr_mask = ahw->pci_base0 + intr_mask;
+	}
+	dev_info(&adapter->pdev->dev, "Tx Context[0x%x] Created, state:0x%x\n",
+		 tx->ctx_id, mbx_out->state);
+out:
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+void qlcnic_83xx_register_nic_idc_func(struct qlcnic_adapter *adapter,
+				       int enable)
+{
+	struct qlcnic_cmd_args cmd;
+	int status;
+
+	if (enable) {
+		qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_INIT_NIC_FUNC);
+		cmd.req.arg[1] = cpu_to_le32(1 | BIT_0);
+	} else {
+		qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_STOP_NIC_FUNC);
+		cmd.req.arg[1] = cpu_to_le32(0 | BIT_0);
+	}
+	status = qlcnic_issue_cmd(adapter, &cmd);
+	if (status)
+		dev_err(&adapter->pdev->dev,
+			"Failed to %s in NIC IDC function event.\n",
+			(enable ? "register" : "unregister"));
+
+	qlcnic_free_mbx_args(&cmd);
+}
+
+int qlcnic_83xx_set_port_config(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_cmd_args cmd;
+	int err;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_SET_PORT_CONFIG);
+	cmd.req.arg[1] = cpu_to_le32(adapter->ahw->port_config);
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err)
+		dev_info(&adapter->pdev->dev, "Set Port Config failed.\n");
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+int qlcnic_83xx_get_port_config(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_cmd_args cmd;
+	int err;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_PORT_CONFIG);
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err)
+		dev_info(&adapter->pdev->dev, "Get Port config failed\n");
+	else
+		adapter->ahw->port_config = le32_to_cpu(cmd.rsp.arg[1]);
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+int qlcnic_83xx_setup_link_event(struct qlcnic_adapter *adapter, int enable)
+{
+	int err;
+	u32 temp;
+	struct qlcnic_cmd_args cmd;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_LINK_EVENT);
+	temp = adapter->recv_ctx->context_id << 16;
+	cmd.req.arg[1] = cpu_to_le32((enable ? 1 : 0) | BIT_8 | temp);
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err)
+		dev_info(&adapter->pdev->dev,
+			 "Setup linkevent mailbox failed\n");
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+int qlcnic_83xx_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
+{
+	int err;
+	u32 temp;
+	struct qlcnic_cmd_args cmd;
+
+	if (adapter->recv_ctx->state == QLCNIC_HOST_CTX_STATE_FREED)
+		return -EIO;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIGURE_MAC_RX_MODE);
+	temp = adapter->recv_ctx->context_id << 16;
+	cmd.req.arg[1] = cpu_to_le32((mode ? 1 : 0) | temp);
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err)
+		dev_info(&adapter->pdev->dev,
+			 "Promiscous mode config failed\n");
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+}
+
+int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	int status = 0;
+	u32 config;
+
+	status = qlcnic_83xx_get_port_config(adapter);
+	if (status)
+		return status;
+
+	config = ahw->port_config;
+
+	if (mode == QLCNIC_ILB_MODE)
+		ahw->port_config |= QLC_83XX_CFG_LOOPBACK_HSS;
+	if (mode == QLCNIC_ELB_MODE)
+		ahw->port_config |= QLC_83XX_CFG_LOOPBACK_EXT;
+
+	status = qlcnic_83xx_set_port_config(adapter);
+	if (status) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to Set Loopback Mode = 0x%x.\n",
+			ahw->port_config);
+		ahw->port_config = config;
+		return status;
+	}
+
+	qlcnic_sre_macaddr_change(adapter, adapter->mac_addr, 0,
+				  QLCNIC_MAC_ADD);
+	return status;
+}
+
+int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	int status = 0;
+	u32 config = ahw->port_config;
+
+	if (mode == QLCNIC_ILB_MODE)
+		ahw->port_config &= ~QLC_83XX_CFG_LOOPBACK_HSS;
+	if (mode == QLCNIC_ELB_MODE)
+		ahw->port_config &= ~QLC_83XX_CFG_LOOPBACK_EXT;
+
+	status = qlcnic_83xx_set_port_config(adapter);
+	if (status) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to Clear Loopback Mode = 0x%x.\n",
+			ahw->port_config);
+		ahw->port_config = config;
+		return status;
+	}
+
+	qlcnic_sre_macaddr_change(adapter, adapter->mac_addr, 0,
+				  QLCNIC_MAC_DEL);
+	return status;
+}
+
+void qlcnic_83xx_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip,
+			       int mode)
+{
+	int err;
+	u32 temp;
+	struct qlcnic_cmd_args cmd;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIGURE_IP_ADDR);
+	if (mode == QLCNIC_IP_UP) {
+		temp = adapter->recv_ctx->context_id << 16;
+		cmd.req.arg[1] = cpu_to_le32(1 | temp);
+	} else {
+		temp = adapter->recv_ctx->context_id << 16;
+		cmd.req.arg[1] = cpu_to_le32(2 | temp);
+	}
+	cmd.req.arg[2] = cpu_to_le32(ip);
+
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err != QLCNIC_RCODE_SUCCESS)
+		dev_err(&adapter->netdev->dev,
+			"could not notify %s IP 0x%x request\n",
+			(mode == QLCNIC_IP_UP) ? "Add" : "Remove", ip);
+	qlcnic_free_mbx_args(&cmd);
+}
+
+int qlcnic_83xx_config_hw_lro(struct qlcnic_adapter *adapter, int mode)
+{
+	int err;
+	u32 temp, arg1;
+	struct qlcnic_cmd_args cmd;
+
+	if (adapter->recv_ctx->state == QLCNIC_HOST_CTX_STATE_FREED)
+		return 0;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIGURE_HW_LRO);
+	temp = adapter->recv_ctx->context_id << 16;
+	arg1 = cpu_to_le32((mode ? (BIT_0 | BIT_1 | BIT_3) : 0) | temp);
+	cmd.req.arg[1] = arg1;
+
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err)
+		dev_info(&adapter->pdev->dev, "LRO config failed\n");
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+}
+
+int qlcnic_83xx_config_rss(struct qlcnic_adapter *adapter, int enable)
+{
+	int err;
+	u32 word;
+	struct qlcnic_cmd_args cmd;
+
+
+	const u64 key[] = { 0xbeac01fa6a42b73bULL, 0x8030f20c77cb2da3ULL,
+			    0xae7b30b4d0ca2bcbULL, 0x43a38fb04167253dULL,
+			    0x255b0ec26d5a56daULL };
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIGURE_RSS);
+
+	/*
+	 * RSS request:
+	 * bits 3-0: Rsvd
+	 *      5-4: hash_type_ipv4
+	 *	7-6: hash_type_ipv6
+	 *	  8: enable
+	 *        9: use indirection table
+	 *    16-31: indirection table mask
+	 */
+	word =  ((u32)(RSS_HASHTYPE_IP_TCP & 0x3) << 4) |
+		((u32)(RSS_HASHTYPE_IP_TCP & 0x3) << 6) |
+		((u32)(enable & 0x1) << 8) |
+		((0x7ULL) << 16);
+	cmd.req.arg[1] = (adapter->recv_ctx->context_id);
+	cmd.req.arg[2] = cpu_to_le32(word);
+	memcpy(&cmd.req.arg[4], key, sizeof(key));
+
+	err = qlcnic_issue_cmd(adapter, &cmd);
+
+	if (err)
+		dev_info(&adapter->pdev->dev, "RSS config failed\n");
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+
+}
+
+int qlcnic_83xx_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
+				   __le16 vlan_id, u8 op)
+{
+	int err;
+	u32 *buf;
+	struct qlcnic_cmd_args cmd;
+	struct qlcnic_macvlan_mbx mv;
+
+	if (adapter->recv_ctx->state == QLCNIC_HOST_CTX_STATE_FREED)
+		return -EIO;
+
+	err = qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIG_MAC_VLAN);
+	if (err)
+		return err;
+	cmd.req.arg[1] = cpu_to_le32(op | (1 << 8) |
+				     (adapter->recv_ctx->context_id << 16));
+
+	mv.vlan = cpu_to_le16(vlan_id);
+	memcpy(&mv.mac, addr, ETH_ALEN);
+	buf = &cmd.req.arg[2];
+	memcpy(buf, &mv, sizeof(struct qlcnic_macvlan_mbx));
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err)
+		dev_err(&adapter->pdev->dev,
+			"MAC-VLAN %s to CAM failed, err=%d.\n",
+			((op == 1) ? "add " : "delete "), err);
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+void qlcnic_83xx_change_l2_filter(struct qlcnic_adapter *adapter, u64 *addr,
+				  __le16 vlan_id)
+{
+	u8 mac[ETH_ALEN];
+	memcpy(&mac, addr, ETH_ALEN);
+	qlcnic_83xx_sre_macaddr_change(adapter, mac, vlan_id, QLCNIC_MAC_ADD);
+}
+
+void qlcnic_83xx_configure_mac(struct qlcnic_adapter *adapter, u8 *mac,
+			       u8 type, struct qlcnic_cmd_args *cmd)
+{
+	switch (type) {
+	case QLCNIC_SET_STATION_MAC:
+	case QLCNIC_SET_FAC_DEF_MAC:
+		memcpy(&cmd->req.arg[2], mac, sizeof(u32));
+		memcpy(&cmd->req.arg[3], &mac[4], sizeof(u16));
+		break;
+	}
+	cmd->req.arg[1] = cpu_to_le32(type);
+}
+
+int qlcnic_83xx_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
+{
+	int err, i;
+	struct qlcnic_cmd_args cmd;
+	u32 mac_low, mac_high;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_MAC_ADDRESS);
+	qlcnic_83xx_configure_mac(adapter, mac, QLCNIC_GET_CURRENT_MAC, &cmd);
+	err = qlcnic_issue_cmd(adapter, &cmd);
+
+	if (err == QLCNIC_RCODE_SUCCESS) {
+		mac_low = cmd.rsp.arg[1];
+		mac_high = cmd.rsp.arg[2];
+
+		for (i = 0; i < 2; i++)
+			mac[i] = (u8) (mac_high >> ((1 - i) * 8));
+		for (i = 2; i < 6; i++)
+			mac[i] = (u8) (mac_low >> ((5 - i) * 8));
+	} else {
+		dev_err(&adapter->pdev->dev, "Failed to get mac address%d\n",
+			err);
+		err = -EIO;
+	}
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+void qlcnic_83xx_config_intr_coal(struct qlcnic_adapter *adapter)
+{
+	int err;
+	u32 temp;
+	struct qlcnic_cmd_args cmd;
+	struct qlcnic_nic_intr_coalesce *coal = &adapter->ahw->coal;
+
+	if (adapter->recv_ctx->state == QLCNIC_HOST_CTX_STATE_FREED)
+		return;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIG_INTR_COAL);
+	cmd.req.arg[1] = cpu_to_le32(1 | (adapter->recv_ctx->context_id << 16));
+	cmd.req.arg[3] = cpu_to_le32(coal->flag);
+	temp = coal->rx_time_us << 16;
+	cmd.req.arg[2] = cpu_to_le32(coal->rx_packets | temp);
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err != QLCNIC_RCODE_SUCCESS)
+		dev_info(&adapter->pdev->dev,
+			 "Failed to send interrupt coalescence parameters\n");
+	qlcnic_free_mbx_args(&cmd);
+}
+
+static void qlcnic_83xx_handle_link_aen(struct qlcnic_adapter *adapter,
+					u32 data[])
+{
+	u8 link_status, duplex;
+	/* link speed */
+	link_status = LSB(data[3]) & 1;
+	adapter->ahw->link_speed = MSW(data[2]);
+	adapter->ahw->link_autoneg = MSB(MSW(data[3]));
+	adapter->ahw->module_type = MSB(LSW(data[3]));
+	duplex = LSB(MSW(data[3]));
+	if (duplex)
+		adapter->ahw->link_duplex = DUPLEX_FULL;
+	else
+		adapter->ahw->link_duplex = DUPLEX_HALF;
+	adapter->ahw->has_link_events = 1;
+	qlcnic_advert_link_change(adapter, link_status);
+}
+
+irqreturn_t qlcnic_83xx_handle_aen(int irq, void *data)
+{
+	struct qlcnic_adapter *adapter = data;
+	qlcnic_83xx_process_aen(adapter);
+	return IRQ_HANDLED;
+}
+
+int qlcnic_enable_eswitch(struct qlcnic_adapter *adapter, u8 port, u8 enable)
+{
+	int err = -EIO;
+	struct qlcnic_cmd_args cmd;
+
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC) {
+		dev_err(&adapter->pdev->dev,
+			"%s: Error, invoked by non management func\n",
+			__func__);
+		return err;
+	}
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_TOGGLE_ESWITCH);
+	cmd.req.arg[1] = (port & 0xf) | BIT_4;
+	err = qlcnic_issue_cmd(adapter, &cmd);
+
+	if (err != QLCNIC_RCODE_SUCCESS) {
+		dev_err(&adapter->pdev->dev, "Failed to enable eswitch%d\n",
+			err);
+		err = -EIO;
+	}
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+
+}
+
+int qlcnic_83xx_set_nic_info(struct qlcnic_adapter *adapter,
+			     struct qlcnic_info *nic)
+{
+	int i, err = -EIO;
+	struct qlcnic_cmd_args cmd;
+
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC) {
+		dev_err(&adapter->pdev->dev,
+			"%s: Error, invoked by non management func\n",
+			__func__);
+		return err;
+	}
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_SET_NIC_INFO);
+
+	cmd.req.arg[1] = (nic->pci_func << 16);
+	cmd.req.arg[2] = 0x1 << 16;
+	cmd.req.arg[3] = nic->phys_port | (nic->switch_mode << 16);
+	cmd.req.arg[4] = nic->capabilities;
+	cmd.req.arg[5] = (nic->max_mac_filters & 0xFF) | ((nic->max_mtu) << 16);
+	cmd.req.arg[6] = (nic->max_tx_ques) | ((nic->max_rx_ques) << 16);
+	cmd.req.arg[7] = (nic->min_tx_bw) | ((nic->max_tx_bw) << 16);
+	for (i = 8; i < 32; i++)
+		cmd.req.arg[i] = 0;
+
+	err = qlcnic_issue_cmd(adapter, &cmd);
+
+	if (err != QLCNIC_RCODE_SUCCESS) {
+		dev_err(&adapter->pdev->dev, "Failed to set nic info%d\n",
+			err);
+		err = -EIO;
+	}
+
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+}
+
+int qlcnic_83xx_get_nic_info(struct qlcnic_adapter *adapter,
+			     struct qlcnic_info *npar_info, u8 func_id)
+{
+	int err;
+	u32 temp;
+	u8 op = 0;
+	struct qlcnic_cmd_args cmd;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_NIC_INFO);
+	if (func_id != adapter->ahw->pci_func) {
+		temp = func_id << 16;
+		cmd.req.arg[1] = cpu_to_le32(op | BIT_31 | temp);
+	} else {
+		cmd.req.arg[1] = cpu_to_le32(adapter->ahw->pci_func << 16);
+	}
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err) {
+		dev_info(&adapter->pdev->dev,
+			 "Failed to get nic info %d\n", err);
+		goto out;
+	}
+
+	npar_info->op_type = cmd.rsp.arg[1];
+	npar_info->pci_func = cmd.rsp.arg[2] & 0xFFFF;
+	npar_info->op_mode = (cmd.rsp.arg[2] & 0xFFFF0000) >> 16;
+	npar_info->phys_port = cmd.rsp.arg[3] & 0xFFFF;
+	npar_info->switch_mode = (cmd.rsp.arg[3] & 0xFFFF0000) >> 16;
+	npar_info->capabilities = cmd.rsp.arg[4];
+	npar_info->max_mac_filters = cmd.rsp.arg[5] & 0xFF;
+	npar_info->max_mtu = (cmd.rsp.arg[5] & 0xFFFF0000) >> 16;
+	npar_info->max_tx_ques = cmd.rsp.arg[6] & 0xFFFF;
+	npar_info->max_rx_ques = (cmd.rsp.arg[6] & 0xFFFF0000) >> 16;
+	npar_info->min_tx_bw = cmd.rsp.arg[7] & 0xFFFF;
+	npar_info->max_tx_bw = (cmd.rsp.arg[7] & 0xFFFF0000) >> 16;
+	if (cmd.rsp.arg[8] & 0x1)
+		npar_info->max_bw_reg_offset = (cmd.rsp.arg[8] & 0x7FFE) >> 1;
+	if (cmd.rsp.arg[8] & 0x10000) {
+		temp = (cmd.rsp.arg[8] & 0x7FFE0000) >> 17;
+		npar_info->max_linkspeed_reg_offset = temp;
+	}
+
+out:
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+int qlcnic_83xx_get_pci_info(struct qlcnic_adapter *adapter,
+			     struct qlcnic_pci_info *pci_info)
+{
+	int i, err = 0, j = 0;
+	u32 temp;
+	struct qlcnic_cmd_args cmd;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_PCI_INFO);
+	err = qlcnic_issue_cmd(adapter, &cmd);
+
+	adapter->ahw->act_pci_func = 0;
+	if (err == QLCNIC_RCODE_SUCCESS) {
+		pci_info->func_count = cmd.rsp.arg[1] & 0xFF;
+		dev_info(&adapter->pdev->dev,
+			 "%s: total functions = %d\n",
+			 __func__, pci_info->func_count);
+		for (i = 2, j = 0; j < QLCNIC_MAX_PCI_FUNC; j++, pci_info++) {
+			pci_info->id = cmd.rsp.arg[i] & 0xFFFF;
+			pci_info->active = (cmd.rsp.arg[i] & 0xFFFF0000) >> 16;
+			i++;
+			pci_info->type = cmd.rsp.arg[i] & 0xFFFF;
+			if (pci_info->type == QLCNIC_TYPE_NIC)
+				adapter->ahw->act_pci_func++;
+			temp = (cmd.rsp.arg[i] & 0xFFFF0000) >> 16;
+			pci_info->default_port = temp;
+			i++;
+			pci_info->tx_min_bw = cmd.rsp.arg[i] & 0xFFFF;
+			temp = (cmd.rsp.arg[i] & 0xFFFF0000) >> 16;
+			pci_info->tx_max_bw = temp;
+			i = i + 2;
+			memcpy(pci_info->mac, &cmd.rsp.arg[i], ETH_ALEN - 2);
+			i++;
+			memcpy(pci_info->mac + sizeof(u32), &cmd.rsp.arg[i], 2);
+			i = i + 3;
+
+			dev_info(&adapter->pdev->dev, "%s:\n"
+				 "\tid = %d active = %d type = %d\n"
+				 "\tport = %d min bw = %d max bw = %d\n"
+				 "\tmac_addr =  %pM\n", __func__,
+				 pci_info->id, pci_info->active, pci_info->type,
+				 pci_info->default_port, pci_info->tx_min_bw,
+				 pci_info->tx_max_bw, pci_info->mac);
+		}
+	} else {
+		dev_err(&adapter->pdev->dev, "Failed to get PCI Info%d\n",
+			err);
+		err = -EIO;
+	}
+
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+}
+
+int qlcnic_83xx_config_intrpt(struct qlcnic_adapter *adapter, bool op_type)
+{
+	int i, index, err;
+	bool type;
+	u8 max_ints;
+	u32 val, temp;
+	struct qlcnic_cmd_args cmd;
+
+	max_ints = adapter->ahw->num_msix;
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIG_INTRPT);
+	cmd.req.arg[1] = cpu_to_le32(max_ints);
+	for (i = 0, index = 2; i < max_ints; i++) {
+		type = op_type ? QLCNIC_INTRPT_ADD : QLCNIC_INTRPT_DEL;
+		val = type | (adapter->ahw->intr_tbl[i].type << 4);
+		if (adapter->ahw->intr_tbl[i].type == QLCNIC_INTRPT_MSIX)
+			val |= (adapter->ahw->intr_tbl[i].id << 16);
+		cmd.req.arg[index++] = cpu_to_le32(val);
+	}
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to configure interrupts 0x%x\n", err);
+		goto out;
+	}
+
+	max_ints = le32_to_cpu(cmd.rsp.arg[1]);
+	for (i = 0, index = 2; i < max_ints; i++, index += 2) {
+
+		val = le32_to_cpu(cmd.rsp.arg[index]);
+		if (LSB(val)) {
+			dev_info(&adapter->pdev->dev,
+				 "Can't configure interrupt %d\n",
+				 adapter->ahw->intr_tbl[i].id);
+			continue;
+		}
+		if (op_type) {
+			adapter->ahw->intr_tbl[i].id = MSW(val);
+			adapter->ahw->intr_tbl[i].enabled = 1;
+			temp = cmd.rsp.arg[index + 1];
+			adapter->ahw->intr_tbl[i].src = le32_to_cpu(temp);
+		} else {
+			adapter->ahw->intr_tbl[i].id = i;
+			adapter->ahw->intr_tbl[i].enabled = 0;
+			adapter->ahw->intr_tbl[i].src = 0;
+		}
+	}
+out:
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
new file mode 100644
index 0000000..1112042
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -0,0 +1,347 @@
+#ifndef __QLCNIC_83XX_HW_H
+#define __QLCNIC_83XX_HW_H
+
+#include <linux/types.h>
+#include <linux/etherdevice.h>
+#include "qlcnic_hw.h"
+
+/* Directly mapped registers */
+#define QLC_83XX_CRB_WIN_BASE		0x3800
+#define QLC_83XX_CRB_WIN_FUNC(f)	(QLC_83XX_CRB_WIN_BASE+((f)*4))
+#define QLC_83XX_SEM_LOCK_BASE		0x3840
+#define QLC_83XX_SEM_UNLOCK_BASE	0x3844
+#define QLC_83XX_SEM_LOCK_FUNC(f)	(QLC_83XX_SEM_LOCK_BASE+((f)*8))
+#define QLC_83XX_SEM_UNLOCK_FUNC(f)	(QLC_83XX_SEM_UNLOCK_BASE+((f)*8))
+#define QLC_83XX_LINK_STATE(f)		(0x3698+((f) > 7 ? 4 : 0))
+#define QLC_83XX_LINK_SPEED(f)		(0x36E0+(((f) >> 2) * 4))
+#define QLC_83XX_LINK_SPEED_FACTOR	10
+#define QLC_83xx_FUNC_VAL(v, f)	((v) & (1 << (f * 4)))
+#define QLC_83XX_INTX_PTR		0x38C0
+#define QLC_83XX_INTX_TRGR		0x38C4
+#define QLC_83XX_INTX_MASK		0x38C8
+
+#define QLC_83XX_DRV_LOCK_WAIT_COUNTER			100
+#define QLC_83XX_DRV_LOCK_WAIT_DELAY			20
+#define QLC_83XX_NEED_DRV_LOCK_RECOVERY		1
+#define QLC_83XX_DRV_LOCK_RECOVERY_IN_PROGRESS		2
+#define QLC_83XX_MAX_DRV_LOCK_RECOVERY_ATTEMPT		3
+#define QLC_83XX_DRV_LOCK_RECOVERY_DELAY		200
+#define QLC_83XX_DRV_LOCK_RECOVERY_STATUS_MASK		0x3
+
+#define QLCNIC_NO_CARD_RESOURCE	0x5
+#define QLCNIC_MAC_PRESENT		0xC
+#define QLCNIC_MAC_NOT_PRESENT		0xD
+
+
+#define QLC_83XX_FLASH_SECTOR_SIZE		(64 * 1024)
+
+/* PEG status definitions */
+#define QLC_83XX_CMDPEG_COMPLETE		0xff01
+#define QLC_83XX_VALID_INTX_BIT30(val)		((val) & BIT_30)
+#define QLC_83XX_VALID_INTX_BIT31(val)		((val) & BIT_31)
+#define QLC_83XX_INTX_FUNC(val)		((val) & 0xFF)
+#define QLC_83XX_LEGACY_INTX_MAX_RETRY		100
+#define QLC_83XX_LEGACY_INTX_DELAY		4
+#define QLC_83XX_REG_DESC			1
+#define QLC_83XX_LRO_DESC			2
+#define QLC_83XX_CTRL_DESC			3
+#define QLCNIC_FW_83XX_CAPABILITY_TSO		BIT_6
+#define QLCNIC_FW_83XX_CAP_LRO_MSS		BIT_17
+#define QLCNIC_HOST_83XX_RDS_MODE_UNIQUE	0
+#define QLCNIC_HOST_SDS_MBX_IDX			8
+
+/* status descriptor mailbox data
+ * @phy_addr: physical address of buffer
+ * @sds_ring_size: buffer size
+ * @intrpt_id: interrupt id
+ * @intrpt_val: source of interrupt
+ */
+struct qlcnic_sds_mbx {
+	__le64	phy_addr;
+	u8	rsvd1[16];
+	__le16	sds_ring_size;
+	__le16	rsvd2[3];
+	__le16	intrpt_id;
+	u8	intrpt_val;
+	u8	rsvd3[5];
+} __packed;
+
+#define QLCNIC_HOST_RDS_MBX_IDX	88
+/* receive descriptor buffer data
+ * phy_addr_reg: physical address of regular buffer
+ * phy_addr_jmb: physical address of jumbo buffer
+ * reg_ring_sz: size of regular buffer
+ * reg_ring_len: no. of entries in regular buffer
+ * jmb_ring_len: no. of entries in jumbo buffer
+ * jmb_ring_sz: size of jumbo buffer
+ */
+struct qlcnic_rds_mbx {
+	__le64	phy_addr_reg;
+	__le64	phy_addr_jmb;
+	__le16	reg_ring_sz;
+	__le16	reg_ring_len;
+	__le16	jmb_ring_sz;
+	__le16	jmb_ring_len;
+} __packed;
+
+/* host producers for regular and jumbo rings */
+struct __host_producer_mbx {
+	__le32	reg_buf;
+	__le32	jmb_buf;
+} __packed;
+
+#define QLCNIC_MAX_RING_SETS	8
+/* Receive context mailbox data outbox registers
+ * @state: state of the context
+ * @vport_id: virtual port id
+ * @context_id: receive context id
+ * @num_pci_func: number of pci functions of the port
+ * @phy_port: physical port id
+ */
+struct qlcnic_rcv_mbx_out {
+	u8	rcv_num;
+	u8	sts_num;
+	__le16	ctx_id;
+	u8	state;
+	u8	num_pci_func;
+	u8	phy_port;
+	u8	vport_id;
+	__le32	host_csmr[QLCNIC_MAX_RING_SETS];
+	struct __host_producer_mbx host_prod[QLCNIC_MAX_RING_SETS];
+} __packed;
+
+struct qlcnic_add_rings_mbx_out {
+	u8      rcv_num;
+	u8      sts_num;
+	__le16  ctx_id;
+	__le32  host_csmr[QLCNIC_MAX_RING_SETS];
+	struct __host_producer_mbx host_prod[QLCNIC_MAX_RING_SETS];
+} __packed;
+
+/* Transmit context mailbox inbox registers
+ * @phys_addr: DMA address of the transmit buffer
+ * @cnsmr_index: host consumer index
+ * @size: legth of transmit buffer ring
+ * @intr_id: interrput id
+ * @src: src of interrupt
+ */
+struct qlcnic_tx_mbx {
+	__le64	phys_addr;
+	__le64	cnsmr_index;
+	__le16	size;
+	__le16	intr_id;
+	u8	src;
+	u8	rsvd[3];
+} __packed;
+
+/* Transmit context mailbox outbox registers
+ * @host_prod: host producer index
+ * @ctx_id: transmit context id
+ * @state: state of the transmit context
+ */
+struct qlcnic_tx_mbx_out {
+	__le32	host_prod;
+	__le16	ctx_id;
+	u8	state;
+	u8	rsvd;
+} __packed;
+
+struct qlcnic_intrpt_config {
+	u8	type;
+	u8	enabled;
+	u16	id;
+	u32	src;
+};
+
+struct qlcnic_macvlan_mbx {
+	u8	mac[ETH_ALEN];
+	__le16	vlan;
+};
+
+
+/* Mailbox process AEN count */
+#define QLC_83XX_IDC_COMP_AEN			3
+#define QLC_83XX_MBX_AEN_CNT			5
+#define QLC_83XX_MODULE_LOADED			1
+#define QLC_83XX_MBX_READY			2
+#define QLC_83XX_MBX_AEN_ACK			3
+#define QLC_83XX_SFP_PRESENT(data)		((data) & 3)
+#define QLC_83XX_SFP_ERR(data)			(((data) >> 2) & 3)
+#define QLC_83XX_SFP_MODULE_TYPE(data)		(((data) >> 4) & 0x1F)
+#define QLC_83XX_SFP_CU_LENGTH(data)		(LSB((data) >> 16))
+#define QLC_83XX_SFP_TX_FAULT(data)		((data) & BIT_10)
+#define QLC_83XX_SFP_10G_CAPABLE(data)		((data) & BIT_11)
+#define QLC_83XX_LINK_STATS(data)		((data) & BIT_0)
+#define QLC_83XX_CURRENT_LINK_SPEED(data)	(((data) >> 3) & 7)
+#define QLC_83XX_LINK_PAUSE(data)		(((data) >> 6) & 3)
+#define QLC_83XX_LINK_LB(data)			(((data) >> 8) & 7)
+#define QLC_83XX_LINK_FEC(data)		((data) & BIT_12)
+#define QLC_83XX_LINK_EEE(data)		((data) & BIT_13)
+#define QLC_83XX_DCBX(data)			(((data) >> 28) & 7)
+#define QLC_83XX_AUTONEG(data)			((data) & BIT_15)
+#define QLC_83XX_CFG_STD_PAUSE			(1 << 5)
+#define QLC_83XX_CFG_STD_TX_PAUSE		(1 << 20)
+#define QLC_83XX_CFG_STD_RX_PAUSE		(2 << 20)
+#define QLC_83XX_CFG_STD_TX_RX_PAUSE		(3 << 20)
+#define QLC_83XX_ENABLE_AUTONEG		(1 << 15)
+#define QLC_83XX_CFG_LOOPBACK_HSS		(2 << 1)
+#define QLC_83XX_CFG_LOOPBACK_PHY		(3 << 1)
+#define QLC_83XX_CFG_LOOPBACK_EXT		(4 << 1)
+
+/* LED configuration settings */
+#define QLC_83XX_ENABLE_BEACON		0xe
+#define QLC_83XX_LED_RATE		0xff
+#define QLC_83XX_LED_ACT		(1 << 10)
+#define QLC_83XX_LED_MOD		(0 << 13)
+#define QLC_83XX_LED_CONFIG	(QLC_83XX_LED_RATE | QLC_83XX_LED_ACT |	\
+				 QLC_83XX_LED_MOD)
+
+#define QLC_83XX_10M_LINK	1
+#define QLC_83XX_100M_LINK	2
+#define QLC_83XX_1G_LINK	3
+#define QLC_83XX_10G_LINK	4
+#define QLC_83XX_STAT_TX	3
+#define QLC_83XX_STAT_RX	2
+#define QLC_83XX_STAT_MAC	1
+#define QLC_83XX_TX_STAT_REGS	14
+#define QLC_83XX_RX_STAT_REGS	40
+#define QLC_83XX_MAC_STAT_REGS	80
+
+#define QLC_83XX_GET_FUNC_PRIVILEGE(VAL, FN)	(0x3 & ((VAL) >> (FN * 2)))
+#define QLC_83XX_SET_FUNC_OPMODE(VAL, FN)	((VAL) << (FN * 2))
+#define QLC_83XX_DEFAULT_OPMODE			0x55555555
+#define QLC_83XX_PRIVLEGED_FUNC			0x1
+#define QLC_83XX_VIRTUAL_FUNC				0x2
+
+#define QLC_83XX_LB_MAX_FILTERS			2048
+#define QLC_83XX_LB_BUCKET_SIZE			256
+#define QLC_83XX_MINIMUM_VECTOR			3
+
+#define QLC_83XX_GET_FUNC_MODE_FROM_NPAR_INFO(val)	(val & 0x80000000)
+#define QLC_83XX_GET_LRO_CAPABILITY(val)		(val & 0x20)
+#define QLC_83XX_GET_LSO_CAPABILITY(val)		(val & 0x40)
+#define QLC_83XX_GET_LSO_CAPABILITY(val)		(val & 0x40)
+#define QLC_83XX_GET_HW_LRO_CAPABILITY(val)		(val & 0x400)
+#define QLC_83XX_GET_VLAN_ALIGN_CAPABILITY(val)	(val & 0x4000)
+#define QLC_83XX_VIRTUAL_NIC_MODE			0xFF
+#define QLC_83XX_DEFAULT_MODE				0x0
+#define QLCNIC_BRDTYPE_83XX_10G			0x0083
+
+/* Additional registers in 83xx */
+enum qlc_83xx_ext_regs {
+	QLCNIC_GLOBAL_RESET = 0,
+	QLCNIC_WILDCARD,
+	QLCNIC_INFORMANT,
+	QLCNIC_HOST_MBX_CTRL,
+	QLCNIC_FW_MBX_CTRL,
+	QLCNIC_BOOTLOADER_ADDR,
+	QLCNIC_BOOTLOADER_SIZE,
+	QLCNIC_FW_IMAGE_ADDR,
+	QLCNIC_MBX_INTR_ENBL,
+	QLCNIC_DEF_INT_MASK,
+	QLCNIC_DEF_INT_ID,
+	QLC_83XX_IDC_MAJ_VERSION,
+	QLC_83XX_IDC_DEV_STATE,
+	QLC_83XX_IDC_DRV_PRESENCE,
+	QLC_83XX_IDC_DRV_ACK,
+	QLC_83XX_IDC_CTRL,
+	QLC_83XX_IDC_DRV_AUDIT,
+	QLC_83XX_IDC_MIN_VERSION,
+	QLC_83XX_RECOVER_DRV_LOCK,
+	QLC_83XX_IDC_PF_0,
+	QLC_83XX_IDC_PF_1,
+	QLC_83XX_IDC_PF_2,
+	QLC_83XX_IDC_PF_3,
+	QLC_83XX_IDC_PF_4,
+	QLC_83XX_IDC_PF_5,
+	QLC_83XX_IDC_PF_6,
+	QLC_83XX_IDC_PF_7,
+	QLC_83XX_IDC_PF_8,
+	QLC_83XX_IDC_PF_9,
+	QLC_83XX_IDC_PF_10,
+	QLC_83XX_IDC_PF_11,
+	QLC_83XX_IDC_PF_12,
+	QLC_83XX_IDC_PF_13,
+	QLC_83XX_IDC_PF_14,
+	QLC_83XX_IDC_PF_15,
+	QLC_83XX_IDC_DEV_PARTITION_INFO_1,
+	QLC_83XX_IDC_DEV_PARTITION_INFO_2,
+	QLC_83XX_DRV_OP_MODE,
+	QLC_83XX_VNIC_STATE,
+	QLC_83XX_DRV_LOCK,
+	QLC_83XX_DRV_UNLOCK,
+	QLC_83XX_DRV_LOCK_ID,
+	QLC_83XX_ASIC_TEMP,
+};
+
+/* 83xx funcitons */
+int qlcnic_83xx_get_fw_version(struct qlcnic_adapter *);
+int qlcnic_83xx_mbx_op(struct qlcnic_adapter *, struct qlcnic_cmd_args *);
+int qlcnic_83xx_setup_intr(struct qlcnic_adapter *, u8);
+void qlcnic_83xx_get_func_no(struct qlcnic_adapter *);
+int qlcnic_83xx_cam_lock(struct qlcnic_adapter *);
+void qlcnic_83xx_cam_unlock(struct qlcnic_adapter *);
+int qlcnic_send_ctrl_op(struct qlcnic_adapter *, struct qlcnic_cmd_args *, u32);
+void qlcnic_83xx_write_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
+void qlcnic_83xx_read_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
+int qlcnic_83xx_rd_reg_indirect(struct qlcnic_adapter *, ulong);
+int qlcnic_83xx_wrt_reg_indirect(struct qlcnic_adapter *, ulong, u32);
+void qlcnic_83xx_process_rcv_diag(struct qlcnic_adapter *,
+				  struct qlcnic_host_sds_ring *, int, u64 []);
+int qlcnic_83xx_nic_set_promisc(struct qlcnic_adapter *, u32);
+int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *, u8);
+int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *, u8);
+int qlcnic_83xx_config_hw_lro(struct qlcnic_adapter *, int);
+int qlcnic_83xx_config_rss(struct qlcnic_adapter *, int);
+int qlcnic_83xx_config_intr_coalesce(struct qlcnic_adapter *);
+void qlcnic_83xx_change_l2_filter(struct qlcnic_adapter *, u64 *, __le16);
+int qlcnic_83xx_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info *);
+int qlcnic_83xx_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
+void qlcnic_83xx_register_nic_idc_func(struct qlcnic_adapter *, int);
+
+void qlcnic_ind_wr(struct qlcnic_adapter *, u32, u32);
+int qlcnic_ind_rd(struct qlcnic_adapter *, u32);
+void qlcnic_83xx_get_stats(struct qlcnic_adapter *,
+			   struct ethtool_stats *, u64 *);
+int qlcnic_83xx_create_rx_ctx(struct qlcnic_adapter *);
+int qlcnic_83xx_create_tx_ctx(struct qlcnic_adapter *,
+			      struct qlcnic_host_tx_ring *, int);
+int qlcnic_83xx_get_nic_info(struct qlcnic_adapter *, struct qlcnic_info *, u8);
+int qlcnic_83xx_setup_link_event(struct qlcnic_adapter *, int);
+void qlcnic_83xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *);
+int qlcnic_83xx_config_intrpt(struct qlcnic_adapter *, bool);
+int qlcnic_83xx_sre_macaddr_change(struct qlcnic_adapter *, u8 *, __le16, u8);
+int qlcnic_83xx_get_mac_address(struct qlcnic_adapter *, u8 *);
+void qlcnic_83xx_configure_mac(struct qlcnic_adapter *, u8 *, u8,
+			       struct qlcnic_cmd_args *);
+int qlcnic_83xx_alloc_mbx_args(struct qlcnic_cmd_args *,
+			       struct qlcnic_adapter *, u32);
+void qlcnic_free_mbx_args(struct qlcnic_cmd_args *);
+void qlcnic_set_npar_data(struct qlcnic_adapter *, const struct qlcnic_info *,
+			  struct qlcnic_info *);
+void qlcnic_83xx_config_intr_coal(struct qlcnic_adapter *);
+irqreturn_t qlcnic_83xx_handle_aen(int, void *);
+int qlcnic_83xx_get_port_info(struct qlcnic_adapter *);
+void qlcnic_83xx_enable_mbx_intrpt(struct qlcnic_adapter *);
+irqreturn_t qlcnic_83xx_clear_legacy_intr(struct qlcnic_adapter *);
+irqreturn_t qlcnic_83xx_tmp_intr(int, void *);
+void qlcnic_83xx_enable_intr(struct qlcnic_adapter *,
+			     struct qlcnic_host_sds_ring *);
+void qlcnic_83xx_enable_tx_intr(struct qlcnic_adapter *,
+				struct qlcnic_host_tx_ring *);
+void qlcnic_83xx_disable_tx_intr(struct qlcnic_adapter *,
+				 struct qlcnic_host_tx_ring *);
+void qlcnic_83xx_check_vf(struct qlcnic_adapter *,
+			  const struct pci_device_id *);
+void qlcnic_83xx_process_aen(struct qlcnic_adapter *);
+int qlcnic_83xx_get_port_config(struct qlcnic_adapter *);
+int qlcnic_83xx_set_port_config(struct qlcnic_adapter *);
+int qlcnic_enable_eswitch(struct qlcnic_adapter *, u8, u8);
+int qlcnic_83xx_get_nic_configuration(struct qlcnic_adapter *);
+int qlcnic_83xx_config_default_opmode(struct qlcnic_adapter *);
+int qlcnic_83xx_setup_mbx_intr(struct qlcnic_adapter *);
+void qlcnic_83xx_free_mbx_intr(struct qlcnic_adapter *);
+void qlcnic_83xx_register_map(struct qlcnic_hardware_context *);
+void qlcnic_83xx_idc_aen_work(struct work_struct *);
+void qlcnic_83xx_config_ipaddr(struct qlcnic_adapter *, __be32, int);
+#endif
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index a950e4d..f9bcae3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -487,7 +487,7 @@ enum {
 #define QLCNIC_NIU_GB_MAC_CONFIG_1(I)		\
 		(QLCNIC_CRB_NIU + 0x30004 + (I)*0x10000)
 
-
+#define MAX_CTL_CHECK	1000
 #define TEST_AGT_CTRL	(0x00)
 
 #define TA_CTL_START	BIT_0
@@ -671,6 +671,9 @@ enum {
 #define QLCNIC_HEARTBEAT_PERIOD_MSECS	200
 #define QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT	45
 
+#define QLCNIC_MAX_MC_COUNT		38
+#define QLCNIC_WATCHDOG_TIMEOUTVALUE	5
+
 #define	ISR_MSI_INT_TRIGGER(FUNC) (QLCNIC_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
 #define ISR_LEGACY_INT_TRIGGERED(VAL)	(((VAL) & 0x300) == 0x200)
 
@@ -715,7 +718,8 @@ static const u32 FW_DUMP_LEVELS[] = {
 enum {
 	QLCNIC_MGMT_FUNC	= 0,
 	QLCNIC_PRIV_FUNC	= 1,
-	QLCNIC_NON_PRIV_FUNC    = 2
+	QLCNIC_NON_PRIV_FUNC	= 2,
+	QLCNIC_UNKNOWN_FUNC_MODE = 3
 };
 
 enum {
@@ -931,6 +935,8 @@ enum {
 #define QLCNIC_NIU_PROMISC_MODE		1
 #define QLCNIC_NIU_ALLMULTI_MODE	2
 
+#define QLCNIC_PCIE_SEM_TIMEOUT	10000
+
 struct crb_128M_2M_sub_block_map {
 	unsigned valid;
 	unsigned start_128M;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index b034c91..2f24a0f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -553,19 +553,20 @@ void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter)
 	struct qlcnic_filter *tmp_fil;
 	struct hlist_node *tmp_hnode, *n;
 	struct hlist_head *head;
-	int i;
+	int i, time;
+	u8 cmd;
 
-	for (i = 0; i < adapter->fhash.fmax; i++) {
+	for (i = 0; i < adapter->fhash.fbucket_size; i++) {
 		head = &(adapter->fhash.fhead[i]);
-
-		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode)
-		{
-			if (jiffies >
-				(QLCNIC_FILTER_AGE * HZ + tmp_fil->ftime)) {
+		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
+			cmd =  tmp_fil->vlan_id ? QLCNIC_MAC_VLAN_DEL :
+						  QLCNIC_MAC_DEL;
+			time = tmp_fil->ftime;
+			if (jiffies > (QLCNIC_FILTER_AGE * HZ + time)) {
 				qlcnic_sre_macaddr_change(adapter,
-					tmp_fil->faddr, tmp_fil->vlan_id,
-					tmp_fil->vlan_id ? QLCNIC_MAC_VLAN_DEL :
-					QLCNIC_MAC_DEL);
+							  tmp_fil->faddr,
+							  tmp_fil->vlan_id,
+							  cmd);
 				spin_lock_bh(&adapter->mac_learn_lock);
 				adapter->fhash.fnum--;
 				hlist_del(&tmp_fil->fnode);
@@ -582,14 +583,17 @@ void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
 	struct hlist_node *tmp_hnode, *n;
 	struct hlist_head *head;
 	int i;
+	u8 cmd;
 
-	for (i = 0; i < adapter->fhash.fmax; i++) {
+	for (i = 0; i < adapter->fhash.fbucket_size; i++) {
 		head = &(adapter->fhash.fhead[i]);
-
 		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
-			qlcnic_sre_macaddr_change(adapter, tmp_fil->faddr,
-				tmp_fil->vlan_id, tmp_fil->vlan_id ?
-				QLCNIC_MAC_VLAN_DEL :  QLCNIC_MAC_DEL);
+			cmd =  tmp_fil->vlan_id ? QLCNIC_MAC_VLAN_DEL :
+						  QLCNIC_MAC_DEL;
+			qlcnic_sre_macaddr_change(adapter,
+						  tmp_fil->faddr,
+						  tmp_fil->vlan_id,
+						  cmd);
 			spin_lock_bh(&adapter->mac_learn_lock);
 			adapter->fhash.fnum--;
 			hlist_del(&tmp_fil->fnode);
@@ -599,7 +603,7 @@ void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
 	}
 }
 
-int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u8 flag)
+static int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u8 flag)
 {
 	struct qlcnic_nic_req req;
 	int rv;
@@ -733,8 +737,6 @@ int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 	return rv;
 }
 
-#define RSS_HASHTYPE_IP_TCP	0x3
-
 int qlcnic_82xx_config_rss(struct qlcnic_adapter *adapter, int enable)
 {
 	struct qlcnic_nic_req req;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index d88baed..6be7f7b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -36,6 +36,14 @@ enum qlcnic_regs {
 #define QLCWR(a, addr, value)		\
 	writel(value, ((a)->ahw->pci_base0) + ((a)->ahw->reg_tbl[addr]))
 
+/* Read from a direct address offset from BAR0, additional registers */
+#define QLCRDX(ahw, addr)	\
+	readl(((ahw)->pci_base0) + ((ahw)->ext_reg_tbl[addr]))
+
+/* Write to a direct address offset from BAR0, additional registers */
+#define QLCWRX(ahw, addr, value)	\
+	writel(value, (((ahw)->pci_base0) + ((ahw)->ext_reg_tbl[addr])))
+
 #define QLCNIC_CMD_CONFIGURE_IP_ADDR		0x1
 #define QLCNIC_CMD_CONFIG_INTRPT		0x2
 #define QLCNIC_CMD_CREATE_RX_CTX		0x7
@@ -85,6 +93,7 @@ enum qlcnic_regs {
 #define QLCNIC_CMD_GET_LINK_STATUS		0x68
 #define QLCNIC_CMD_SET_LED_CONFIG		0x69
 #define QLCNIC_CMD_GET_LED_CONFIG		0x6A
+#define QLCNIC_CMD_ADD_RCV_RINGS		0x0B
 
 #define QLCNIC_INTRPT_INTX			1
 #define QLCNIC_INTRPT_MSIX			3
@@ -110,6 +119,13 @@ struct qlcnic_mailbox_metadata {
 	u32 out_args;
 };
 
+/* Mailbox ownership */
+#define QLCNIC_GET_OWNER(val)	((val) & (BIT_0 | BIT_1))
+
+#define QLCNIC_SET_OWNER        1
+#define QLCNIC_CLR_OWNER        0
+#define QLCNIC_MBX_TIMEOUT      10000
+
 #define QLCNIC_MBX_RSP_OK	1
 #define QLCNIC_MBX_PORT_RSP_OK	0x1a
 
@@ -165,4 +181,5 @@ int qlcnic_82xx_api_lock(struct qlcnic_adapter *);
 void qlcnic_82xx_api_unlock(struct qlcnic_adapter *);
 void qlcnic_82xx_napi_enable(struct qlcnic_adapter *);
 void qlcnic_82xx_napi_disable(struct qlcnic_adapter *);
+void qlcnic_82xx_napi_del(struct qlcnic_adapter *);
 #endif				/* __QLCNIC_HW_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 4e274b5..03b0e11 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -359,7 +359,7 @@ static struct qlcnic_hardware_ops qlcnic_hw_ops = {
 	.get_board_info			= qlcnic_82xx_get_board_info,
 };
 
-static int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
+int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int err = -1;
-- 
1.7.1
