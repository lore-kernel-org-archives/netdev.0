From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 06/15] qlcnic: change driver firmware interface mechanism
Date: Thu, 23 Aug 2012 21:07:10 -0400
Message-ID: <1345770439-30517-7-git-send-email-sony.chacko@qlogic.com>
References: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:65016 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755070Ab2HXBYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 21:24:08 -0400
In-Reply-To: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Modify 82xx driver to support new adapter - Qlogic 83XX CNA
Change 82xx specific firmware interface and create mailbox based interface
Modify firmware commands to use new mailbox interface

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  424 +++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |  646 ++++++-------
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  522 ++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |  101 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  344 ++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |  211 ++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |   86 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   83 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 1028 ++++++++++++--------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |  170 +++-
 10 files changed, 1971 insertions(+), 1644 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 86e6a80..29caa81 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -33,6 +33,7 @@
 #include <linux/if_vlan.h>
 
 #include "qlcnic_hdr.h"
+#include "qlcnic_hw.h"
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 1
@@ -89,6 +90,8 @@
 #define QLCNIC_CT_DEFAULT_RX_BUF_LEN	2048
 #define QLCNIC_LRO_BUFFER_EXTRA		2048
 
+#define RSS_HASHTYPE_IP_TCP     0x3
+
 /* Opcodes to be used with the commands */
 #define TX_ETHER_PKT	0x01
 #define TX_TCP_PKT	0x02
@@ -106,7 +109,7 @@
 #define TX_STOP_THRESH		((MAX_SKB_FRAGS >> 2) + MAX_TSO_HEADER_DESC \
 							+ MGMT_CMD_DESC_RESV)
 #define QLCNIC_MAX_TX_TIMEOUTS	2
-
+#define QLCNIC_MAX_TX_QUEUES	1
 /*
  * Following are the states of the Phantom. Phantom will set them and
  * Host will read to check if the fields are correct.
@@ -157,7 +160,6 @@
 	((cmd_desc)->port_ctxid |= ((var) & 0x0F))
 #define qlcnic_set_cmd_desc_ctxid(cmd_desc, var)	\
 	((cmd_desc)->port_ctxid |= ((var) << 4 & 0xF0))
-
 #define qlcnic_set_tx_port(_desc, _port) \
 	((_desc)->port_ctxid = ((_port) & 0xf) | (((_port) << 4) & 0xf0))
 
@@ -210,6 +212,8 @@ struct rcv_desc {
 #define QLCNIC_RESPONSE_DESC	0x05
 #define QLCNIC_LRO_DESC  	0x12
 
+#define QLCNIC_TX_POLL_BUDGET	128
+
 /* for status field in status_desc */
 #define STATUS_CKSUM_LOOP	0
 #define STATUS_CKSUM_OK		2
@@ -219,12 +223,10 @@ struct rcv_desc {
 #define STATUS_OWNER_PHANTOM	(0x2ULL << 56)
 
 /* Status descriptor:
-   0-3 port, 4-7 status, 8-11 type, 12-27 total_length
-   28-43 reference_handle, 44-47 protocol, 48-52 pkt_offset
+   0-3 rsvd, 4-7 status, 8-11 type, 12-27 total_length
+   28-43 reference_handle, 44-47 rsvd, 48-52 pkt_offset
    53-55 desc_cnt, 56-57 owner, 58-63 opcode
  */
-#define qlcnic_get_sts_port(sts_data)	\
-	((sts_data) & 0x0F)
 #define qlcnic_get_sts_status(sts_data)	\
 	(((sts_data) >> 4) & 0x0F)
 #define qlcnic_get_sts_type(sts_data)	\
@@ -232,9 +234,7 @@ struct rcv_desc {
 #define qlcnic_get_sts_totallength(sts_data)	\
 	(((sts_data) >> 12) & 0xFFFF)
 #define qlcnic_get_sts_refhandle(sts_data)	\
-	(((sts_data) >> 28) & 0xFFFF)
-#define qlcnic_get_sts_prot(sts_data)	\
-	(((sts_data) >> 44) & 0x0F)
+	(((sts_data) >> 28) & 0x7FFF)
 #define qlcnic_get_sts_pkt_offset(sts_data)	\
 	(((sts_data) >> 48) & 0x1F)
 #define qlcnic_get_sts_desc_cnt(sts_data)	\
@@ -243,7 +243,7 @@ struct rcv_desc {
 	(((sts_data) >> 58) & 0x03F)
 
 #define qlcnic_get_lro_sts_refhandle(sts_data) 	\
-	((sts_data) & 0x0FFFF)
+	((sts_data) & 0x07FFF)
 #define qlcnic_get_lro_sts_length(sts_data)	\
 	(((sts_data) >> 16) & 0x0FFFF)
 #define qlcnic_get_lro_sts_l2_hdr_offset(sts_data)	\
@@ -258,14 +258,13 @@ struct rcv_desc {
 	(((sts_data) >> 52) & 0x1)
 #define qlcnic_get_lro_sts_seq_number(sts_data)		\
 	((sts_data) & 0x0FFFFFFFF)
-#define qlcnic_get_lro_sts_mss(sts_data1)		\
-	((sts_data1 >> 32) & 0x0FFFF)
 
 
 struct status_desc {
 	__le64 status_desc_data[2];
 } __attribute__ ((aligned(16)));
 
+#define QLCNIC_DEV_INFO_SIZE	1
 /* UNIFIED ROMIMAGE */
 #define QLCNIC_UNI_FW_MIN_SIZE		0xc8000
 #define QLCNIC_UNI_DIR_SECT_PRODUCT_TBL	0x0
@@ -294,6 +293,7 @@ struct uni_data_desc{
 
 /* Flash Defines and Structures */
 #define QLCNIC_FLT_LOCATION	0x3F1000
+#define QLCNIC_FDT_LOCATION     0x3F0000
 #define QLCNIC_B0_FW_IMAGE_REGION 0x74
 #define QLCNIC_C0_FW_IMAGE_REGION 0x97
 #define QLCNIC_BOOTLD_REGION    0X72
@@ -331,6 +331,7 @@ struct qlcnic_flt_entry {
 #define QLCNIC_BRDTYPE_P3P_10G_CX4	0x0031
 #define QLCNIC_BRDTYPE_P3P_10G_XFP	0x0032
 #define QLCNIC_BRDTYPE_P3P_10G_TP	0x0080
+#define QLCNIC_BRDTYPE_83XX_10G	0x0083
 
 #define QLCNIC_MSIX_TABLE_OFFSET	0x44
 
@@ -357,6 +358,11 @@ struct qlcnic_flt_entry {
 #define QLCNIC_FLASH_ROMIMAGE_NAME	"flash"
 
 extern char qlcnic_driver_name[];
+extern int use_msi;
+extern int use_msi_x;
+extern int auto_fw_reset;
+extern int load_fw_file;
+extern int qlcnic_config_npars;
 
 /* Number of status descriptors to handle per interrupt */
 #define MAX_STATUS_HANDLE	(64)
@@ -428,12 +434,14 @@ struct qlcnic_dump_template_hdr {
 	__le32	sys_info[3];
 	__le32	saved_state[16];
 	__le32	cap_sizes[8];
+	__le32	ocm_wnd_reg[16];
 	__le32	rsvd[0];
 };
 
 struct qlcnic_fw_dump {
 	u8	clr;	/* flag to indicate if dump is cleared */
 	u8	enable; /* enable/disable dump */
+	u32	pos;	/* position in the dump buffer */
 	u32	size;	/* total size of the dump */
 	void	*data;	/* dump data area */
 	struct	qlcnic_dump_template_hdr *tmpl_hdr;
@@ -468,6 +476,8 @@ struct qlcnic_hardware_context {
 	u8 mc_enabled;
 	u8 max_mc_count;
 	u8 diag_test;
+	u8 num_msix;
+	u8 nic_mode;
 	char diag_cnt;
 
 	u16 port_type;
@@ -484,14 +494,20 @@ struct qlcnic_hardware_context {
 	u16 max_rx_ques;
 	u16 max_mtu;
 	u16 msg_enable;
+	u16 act_pci_func;
 
 	u32 capabilities;
 	u32 temp;
 	u32 int_vec_bit;
 	u32 fw_hal_version;
+	u32 port_config;
 	struct qlcnic_hardware_ops *hw_ops;
 	struct qlcnic_nic_intr_coalesce coal;
 	struct qlcnic_fw_dump fw_dump;
+	struct qlcnic_intrpt_config *intr_tbl;
+	u32 *reg_tbl;
+	u32 *ext_reg_tbl;
+	spinlock_t mbx_lock;
 };
 
 struct qlcnic_adapter_stats {
@@ -550,12 +566,17 @@ struct qlcnic_host_sds_ring {
 } ____cacheline_internodealigned_in_smp;
 
 struct qlcnic_host_tx_ring {
+	int irq;
+	void __iomem *crb_intr_mask;
+	char name[IFNAMSIZ+4];
 	u16 ctx_id;
 	u32 producer;
 	u32 sw_consumer;
 	u32 num_desc;
 	void __iomem *crb_cmd_producer;
 	struct cmd_desc_type0 *desc_head;
+	struct qlcnic_adapter *adapter;
+	struct napi_struct napi;
 	struct qlcnic_cmd_buffer *cmd_buf_arr;
 	__le32 *hw_consumer;
 
@@ -605,49 +626,9 @@ struct qlcnic_recv_context {
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
-#define QLCNIC_RCODE_INVALID_ARGS	6
 #define QLCNIC_RCODE_NOT_SUPPORTED	9
-#define QLCNIC_RCODE_NOT_PERMITTED	10
-#define QLCNIC_RCODE_NOT_IMPL		15
-#define QLCNIC_RCODE_INVALID		16
 #define QLCNIC_RCODE_TIMEOUT		17
-#define QLCNIC_DESTROY_CTX_RESET	0
 
 /*
  * Capabilities Announced
@@ -658,7 +639,6 @@ struct qlcnic_recv_context {
 #define QLCNIC_CAP0_JUMBO_CONTIGUOUS	(1 << 7)
 #define QLCNIC_CAP0_LRO_CONTIGUOUS	(1 << 8)
 #define QLCNIC_CAP0_VALIDOFF		(1 << 11)
-#define QLCNIC_CAP0_LRO_MSS		(1 << 21)
 
 /*
  * Context state
@@ -850,8 +830,8 @@ struct qlcnic_mac_list_s {
  * Firmware --> Driver
  */
 
-#define QLCNIC_C2H_OPCODE_CONFIG_LOOPBACK		0x8f
-#define QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	141
+#define QLCNIC_C2H_OPCODE_CONFIG_LOOPBACK		0x8F
+#define QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	0x8D
 
 #define VPORT_MISS_MODE_DROP		0 /* drop all unmatched */
 #define VPORT_MISS_MODE_ACCEPT_ALL	1 /* accept all packets */
@@ -865,9 +845,6 @@ struct qlcnic_mac_list_s {
 #define QLCNIC_FW_CAPABILITY_FVLANTX		BIT_9
 #define QLCNIC_FW_CAPABILITY_HW_LRO		BIT_10
 #define QLCNIC_FW_CAPABILITY_MULTI_LOOPBACK	BIT_27
-#define QLCNIC_FW_CAPABILITY_MORE_CAPS		BIT_31
-
-#define QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG	BIT_2
 
 /* module types */
 #define LINKEVENT_MODULE_NOT_PRESENT			1
@@ -879,19 +856,10 @@ struct qlcnic_mac_list_s {
 #define LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLELEN	7
 #define LINKEVENT_MODULE_TWINAX 			8
 
-#define LINKSPEED_10GBPS	10000
-#define LINKSPEED_1GBPS 	1000
-#define LINKSPEED_100MBPS	100
-#define LINKSPEED_10MBPS	10
-
 #define LINKSPEED_ENCODED_10MBPS	0
 #define LINKSPEED_ENCODED_100MBPS	1
 #define LINKSPEED_ENCODED_1GBPS 	2
 
-#define LINKEVENT_AUTONEG_DISABLED	0
-#define LINKEVENT_AUTONEG_ENABLED	1
-
-#define LINKEVENT_HALF_DUPLEX		0
 #define LINKEVENT_FULL_DUPLEX		1
 
 #define LINKEVENT_LINKSPEED_MBPS	0
@@ -957,7 +925,6 @@ struct qlcnic_ipaddr {
 #define QLCNIC_NEED_FLR			0x1000
 #define QLCNIC_FW_RESET_OWNER		0x2000
 #define QLCNIC_FW_HANG			0x4000
-#define QLCNIC_FW_LRO_MSS_CAP		0x8000
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
@@ -976,6 +943,7 @@ struct qlcnic_ipaddr {
 #define __QLCNIC_AER			5
 #define __QLCNIC_DIAG_RES_ALLOC		6
 #define __QLCNIC_LED_ENABLE		7
+#define __QLCNIC_ELB_INPROGRESS		8
 
 #define QLCNIC_INTERRUPT_TEST		1
 #define QLCNIC_LOOPBACK_TEST		2
@@ -1014,6 +982,7 @@ struct qlcnic_adapter {
 	unsigned long state;
 	u32 flags;
 
+	int max_drv_tx_rings;
 	u16 num_txd;
 	u16 num_rxd;
 	u16 num_jumbo_rxd;
@@ -1022,6 +991,7 @@ struct qlcnic_adapter {
 
 	u8 max_rds_rings;
 	u8 max_sds_rings;
+	u8 rx_csum;
 	u8 portnum;
 
 	u8 fw_wait_cnt;
@@ -1041,10 +1011,12 @@ struct qlcnic_adapter {
 
 	u8 mac_addr[ETH_ALEN];
 
-	u64 dev_rst_time;
 	u8 mac_learn;
 	unsigned long vlans[BITS_TO_LONGS(VLAN_N_VID)];
+	u64 dev_rst_time;
+	u8 flash_mfg_id;
 
+	struct vlan_group *vlgrp;
 	struct qlcnic_npar_info *npars;
 	struct qlcnic_eswitch *eswitch;
 	struct qlcnic_nic_template *nic_ops;
@@ -1085,7 +1057,24 @@ struct qlcnic_info {
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
@@ -1099,7 +1088,8 @@ struct qlcnic_pci_info {
 	__le16	reserved1[2];
 
 	u8	mac[ETH_ALEN];
-	u8	reserved2[106];
+	__le16	func_count;
+	u8	reserved2[104];
 } __packed;
 
 struct qlcnic_npar_info {
@@ -1116,6 +1106,7 @@ struct qlcnic_npar_info {
 	u8	mac_anti_spoof;
 	u8	promisc_mode;
 	u8	offload_flags;
+	u8	pci_func;
 };
 
 struct qlcnic_eswitch {
@@ -1208,7 +1199,7 @@ do {	\
 			(VAL1) += (VAL2); \
 } while (0)
 
-struct qlcnic_mac_statistics{
+struct qlcnic_mac_statistics {
 	__le64	mac_tx_frames;
 	__le64	mac_tx_bytes;
 	__le64	mac_tx_mcast_pkts;
@@ -1244,7 +1235,7 @@ struct qlcnic_mac_statistics{
 	__le64	mac_rx_length_large;
 	__le64	mac_rx_jabber;
 	__le64	mac_rx_dropped;
-	__le64	mac_rx_crc_error;
+	__le64	mac_FCS_error;
 	__le64	mac_align_error;
 } __packed;
 
@@ -1358,13 +1349,13 @@ struct __queue {
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
 	} region;
 } __packed;
 
@@ -1384,6 +1375,9 @@ enum op_codes {
 	QLCNIC_DUMP_L2_ITAG	= 22,
 	QLCNIC_DUMP_L2_DATA	= 23,
 	QLCNIC_DUMP_L2_INST	= 24,
+	QLCNIC_DUMP_POLL_RD	= 35,
+	QLCNIC_READ_MUX2	= 36,
+	QLCNIC_READ_POLLRDMWR	= 37,
 	QLCNIC_DUMP_READ_ROM	= 71,
 	QLCNIC_DUMP_READ_MEM	= 72,
 	QLCNIC_DUMP_READ_CTRL	= 98,
@@ -1408,8 +1402,8 @@ enum op_codes {
 #define QLCNIC_ENABLE_FW_DUMP		0xaddfeed
 #define QLCNIC_DISABLE_FW_DUMP		0xbadfeed
 #define QLCNIC_FORCE_FW_RESET		0xdeaddead
-#define QLCNIC_SET_QUIESCENT		0xadd00010
-#define QLCNIC_RESET_QUIESCENT		0xadd00020
+#define QLCNIC_SET_QUIESCENT            0xadd00010
+#define QLCNIC_RESET_QUIESCENT          0xadd00020
 
 struct qlcnic_dump_operations {
 	enum op_codes opcode;
@@ -1418,10 +1412,8 @@ struct qlcnic_dump_operations {
 };
 
 struct _cdrp_cmd {
-	u32 cmd;
-	u32 arg1;
-	u32 arg2;
-	u32 arg3;
+	u32 num;
+	u32 *arg;
 };
 
 struct qlcnic_cmd_args {
@@ -1432,7 +1424,7 @@ struct qlcnic_cmd_args {
 int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter);
 int qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config);
 
-u32 qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off);
+u32 qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off, int *);
 int qlcnic_hw_write_wx_2M(struct qlcnic_adapter *, ulong off, u32 data);
 int qlcnic_pci_mem_write_2M(struct qlcnic_adapter *, u64 off, u64 data);
 int qlcnic_pci_mem_read_2M(struct qlcnic_adapter *, u64 off, u64 *data);
@@ -1442,8 +1434,8 @@ void qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *, u64, u64);
 #define ADDR_IN_RANGE(addr, low, high)	\
 	(((addr) < (high)) && ((addr) >= (low)))
 
-#define QLCRD32(adapter, off) \
-	adapter->ahw->hw_ops->rdreg(adapter, off)
+#define QLCRD32(adapter, off, err) \
+	(adapter->ahw->hw_ops->rdreg)(adapter, off, err)
 #define QLCWR32(adapter, off, val) \
 	adapter->ahw->hw_ops->wrtreg(adapter, off, val)
 
@@ -1458,10 +1450,6 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 	qlcnic_pcie_sem_lock((a), 3, QLCNIC_PHY_LOCK_ID)
 #define qlcnic_phy_unlock(a)	\
 	qlcnic_pcie_sem_unlock((a), 3)
-#define qlcnic_api_lock(a)	\
-	qlcnic_pcie_sem_lock((a), 5, 0)
-#define qlcnic_api_unlock(a)	\
-	qlcnic_pcie_sem_unlock((a), 5)
 #define qlcnic_sw_lock(a)	\
 	qlcnic_pcie_sem_lock((a), 6, 0)
 #define qlcnic_sw_unlock(a)	\
@@ -1474,120 +1462,171 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 #define __QLCNIC_MAX_LED_RATE	0xf
 #define __QLCNIC_MAX_LED_STATE	0x2
 
-int qlcnic_get_board_info(struct qlcnic_adapter *adapter);
-int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
-int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
-void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
-void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
+#ifndef SPEED_UNKNOWN
+#define SPEED_UNKNOWN 0x0
+#endif
+
+#ifndef DUPLEX_UNKNOWN
+#define DUPLEX_UNKNOWN 0xff
+#endif
+
+int qlcnic_get_board_info(struct qlcnic_adapter *);
+int qlcnic_wol_supported(struct qlcnic_adapter *);
+int qlcnic_config_led(struct qlcnic_adapter *, u32, u32);
+void qlcnic_prune_lb_filters(struct qlcnic_adapter *);
+void qlcnic_delete_lb_filters(struct qlcnic_adapter *);
 int qlcnic_dump_fw(struct qlcnic_adapter *);
 void qlcnic_get_ocm_win(struct qlcnic_hardware_context *);
 void qlcnic_get_func_no(struct qlcnic_adapter *);
+int qlcnic_api_lock(struct qlcnic_adapter *);
+void qlcnic_api_unlock(struct qlcnic_adapter *);
 
 /* Functions from qlcnic_init.c */
-int qlcnic_load_firmware(struct qlcnic_adapter *adapter);
-int qlcnic_need_fw_reset(struct qlcnic_adapter *adapter);
-void qlcnic_request_firmware(struct qlcnic_adapter *adapter);
-void qlcnic_release_firmware(struct qlcnic_adapter *adapter);
-int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter);
-int qlcnic_setup_idc_param(struct qlcnic_adapter *adapter);
-int qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter);
-
-int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, u32 addr, u32 *valp);
-int qlcnic_rom_fast_read_words(struct qlcnic_adapter *adapter, int addr,
-				u8 *bytes, size_t size);
-int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter);
-void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter);
-
+int qlcnic_attach(struct qlcnic_adapter *);
+void qlcnic_detach(struct qlcnic_adapter *);
+void qlcnic_down(struct qlcnic_adapter *, struct net_device *);
+int qlcnic_up(struct qlcnic_adapter *, struct net_device *);
+void qlcnic_restore_indev_addr(struct net_device *, unsigned long);
+void qlcnic_idc_exit(struct qlcnic_adapter *);
+void qlcnic_schedule_work(struct qlcnic_adapter *, work_func_t, int);
+int qlcnic_load_firmware(struct qlcnic_adapter *);
+int qlcnic_need_fw_reset(struct qlcnic_adapter *);
+void qlcnic_request_firmware(struct qlcnic_adapter *);
+void qlcnic_release_firmware(struct qlcnic_adapter *);
+int qlcnic_pinit_from_rom(struct qlcnic_adapter *);
+int qlcnic_setup_idc_param(struct qlcnic_adapter *);
+int qlcnic_check_flash_fw_ver(struct qlcnic_adapter *);
+int qlcnic_rom_fast_read(struct qlcnic_adapter *, u32, u32 *);
+int qlcnic_rom_fast_read_words(struct qlcnic_adapter *, int, u8 *, size_t);
+int qlcnic_alloc_sw_resources(struct qlcnic_adapter *);
+void qlcnic_free_sw_resources(struct qlcnic_adapter *);
 void __iomem *qlcnic_get_ioaddr(struct qlcnic_hardware_context *, u32);
-
-int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter);
-void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter);
-
-int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter);
-void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter);
-
-void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *adapter);
-void qlcnic_release_rx_buffers(struct qlcnic_adapter *adapter);
-void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter);
-
-int qlcnic_check_fw_status(struct qlcnic_adapter *adapter);
-void qlcnic_watchdog_task(struct work_struct *work);
-void qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_rds_ring *rds_ring);
-int qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max);
-void qlcnic_set_multi(struct net_device *netdev);
-void qlcnic_free_mac_list(struct qlcnic_adapter *adapter);
-int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32);
-int qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter);
-int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable);
-int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd);
-int qlcnic_linkevent_request(struct qlcnic_adapter *adapter, int enable);
-
-int qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu);
+int qlcnic_alloc_hw_resources(struct qlcnic_adapter *);
+void qlcnic_free_hw_resources(struct qlcnic_adapter *);
+int qlcnic_fw_create_ctx(struct qlcnic_adapter *);
+void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *);
+void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *);
+void qlcnic_release_rx_buffers(struct qlcnic_adapter *);
+void qlcnic_release_tx_buffers(struct qlcnic_adapter *);
+struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *,
+struct qlcnic_host_rds_ring *, u16, u16);
+int qlcnic_check_fw_status(struct qlcnic_adapter *);
+void qlcnic_watchdog_task(struct work_struct *);
+void qlcnic_post_rx_buffers(struct qlcnic_adapter *,
+			struct qlcnic_host_rds_ring *, u8);
+int qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *, int);
+void qlcnic_set_multi(struct net_device *);
+void qlcnic_free_mac_list(struct qlcnic_adapter *);
+int qlcnic_nic_set_promisc(struct qlcnic_adapter *, u32);
+void qlcnic_config_intr_coalesce(struct qlcnic_adapter *);
+int qlcnic_config_rss(struct qlcnic_adapter *, int);
+void qlcnic_config_ipaddr(struct qlcnic_adapter *, __be32, int);
+int qlcnic_linkevent_request(struct qlcnic_adapter *, int);
+int qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *, int);
+int qlcnic_change_mtu(struct net_device *, int);
 int qlcnic_change_mtu(struct net_device *netdev, int new_mtu);
 netdev_features_t qlcnic_fix_features(struct net_device *netdev,
-	netdev_features_t features);
+					netdev_features_t features);
 int qlcnic_set_features(struct net_device *netdev, netdev_features_t features);
-int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable);
-int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
-int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
-void qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_tx_ring *tx_ring);
-void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);
-void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter);
-int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode);
-
-void qlcnic_82xx_write_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
-void qlcnic_82xx_read_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
-
+int qlcnic_config_hw_lro(struct qlcnic_adapter *, int);
+int qlcnic_config_bridged_mode(struct qlcnic_adapter *, u32);
+int qlcnic_send_lro_cleanup(struct qlcnic_adapter *);
+void qlcnic_update_cmd_producer(struct qlcnic_adapter *,
+				struct qlcnic_host_tx_ring *);
+void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *);
+int qlcnic_clear_lb_mode(struct qlcnic_adapter *, u8);
+int qlcnic_set_lb_mode(struct qlcnic_adapter *, u8);
+void qlcnic_write_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
+void qlcnic_read_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
+int qlcnic_set_fw_loopback(struct qlcnic_adapter *, u8);
+int qlcnic_nic_set_promisc(struct qlcnic_adapter *, u32);
+void qlcnic_change_filter(struct qlcnic_adapter *, u64 *, __le16);
 /* Functions from qlcnic_ethtool.c */
 int qlcnic_check_loopback_buff(unsigned char *data, u8 mac[]);
 
 /* Functions from qlcnic_main.c */
 int qlcnic_reset_context(struct qlcnic_adapter *);
-void qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *);
+int qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *);
 void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings);
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test);
 netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
-int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val);
-int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data);
-void qlcnic_dev_request_reset(struct qlcnic_adapter *);
 void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
-
-int qlcnic_setup_intr(struct qlcnic_adapter *);
+void qlcnic_dev_request_reset(struct qlcnic_adapter *, u32);
+int qlcnic_validate_max_rss(u8, u8);
+int qlcnic_set_max_rss(struct qlcnic_adapter *, u8);
+int qlcnic_setup_intr(struct qlcnic_adapter *, u8);
+int qlcnic_msix_tx_poll(struct napi_struct *, int);
 int qlcnic_poll(struct napi_struct *, int);
 int qlcnic_rx_poll(struct napi_struct *, int);
 void qlcnic_set_vlan_config(struct qlcnic_adapter *,
 				struct qlcnic_esw_func_cfg *);
 void qlcnic_set_eswitch_port_features(struct qlcnic_adapter *,
 		struct qlcnic_esw_func_cfg *);
+
+int qlcnic_enable_msix(struct qlcnic_adapter *, u32);
+void qlcnic_check_options(struct qlcnic_adapter *adapter);
+void qlcnic_handle_fw_message(int, int, struct qlcnic_host_sds_ring *);
+int qlcnic_alloc_rx_skb(struct qlcnic_adapter *,
+		struct qlcnic_host_rds_ring *,  struct qlcnic_rx_buffer *);
+void qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *,
+				struct qlcnic_host_rds_ring *, u8);
+int qlcnic_process_cmd_ring(struct qlcnic_adapter *,
+			struct qlcnic_host_tx_ring *, int);
+int qlcnic_alloc_sds_rings(struct qlcnic_recv_context *, int);
+int qlcnic_alloc_tx_rings(struct qlcnic_adapter *, struct net_device *);
+void qlcnic_free_sds_rings(struct qlcnic_recv_context *);
+void qlcnic_process_rcv_diag(struct qlcnic_adapter *,
+		struct qlcnic_host_sds_ring *, int, u64);
+int qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *);
+int qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *,
+		struct qlcnic_host_tx_ring *tx_ring, int);
+void qlcnic_handle_linkevent(struct qlcnic_adapter *, struct qlcnic_fw_msg *);
+void qlcnic_advert_link_change(struct qlcnic_adapter *, int);
+int qlcnic_check_rx_tagging(struct qlcnic_adapter *, struct sk_buff *, u16 *);
+int qlcnic_check_temp(struct qlcnic_adapter *adapter);
+/* Functions from qlcnic_io.c */
+void dump_skb(struct sk_buff *, struct qlcnic_adapter *);
+/* Functions from qlcnic_io.c */
+void dump_skb(struct sk_buff *, struct qlcnic_adapter *);
+
 /* functions in qlcnic_sysfs.c */
 int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *);
 void qlcnic_create_sysfs_entries(struct qlcnic_adapter *);
 void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *);
 void qlcnic_create_diag_entries(struct qlcnic_adapter *);
 void qlcnic_remove_diag_entries(struct qlcnic_adapter *);
+void qlcnic_add_sysfs(struct qlcnic_adapter *);
+void qlcnic_remove_sysfs(struct qlcnic_adapter *);
+int qlcnic_sre_macaddr_change(struct qlcnic_adapter *, u8 *, __le16, u8);
 
 /* Management functions */
 int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
 int qlcnic_get_nic_info(struct qlcnic_adapter *, struct qlcnic_info *, u8);
 int qlcnic_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
 int qlcnic_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info*);
+int qlcnic_set_mgmt_operations(struct qlcnic_adapter *adapter);
 
 /*  eSwitch management functions */
 int qlcnic_config_switch_port(struct qlcnic_adapter *,
 				struct qlcnic_esw_func_cfg *);
 int qlcnic_get_eswitch_port_config(struct qlcnic_adapter *,
 				struct qlcnic_esw_func_cfg *);
+int qlcnic_get_mac_stats(struct qlcnic_adapter *,
+			struct qlcnic_mac_statistics *);
 int qlcnic_config_port_mirroring(struct qlcnic_adapter *, u8, u8, u8);
 int qlcnic_get_port_stats(struct qlcnic_adapter *, const u8, const u8,
 					struct __qlcnic_esw_statistics *);
 int qlcnic_get_eswitch_stats(struct qlcnic_adapter *, const u8, u8,
 					struct __qlcnic_esw_statistics *);
-int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, u8, u8, u8);
-int qlcnic_get_mac_stats(struct qlcnic_adapter *, struct qlcnic_mac_statistics *);
-extern int qlcnic_config_tso;
 
+int qlcnic_clear_esw_stats(struct qlcnic_adapter *, u8, u8, u8);
+int qlcnic_check_eswitch_mode(struct qlcnic_adapter *);
+int qlcnic_init_pci_info(struct qlcnic_adapter *);
+int qlcnic_set_default_offload_settings(struct qlcnic_adapter *);
+int qlcnic_reset_npar_config(struct qlcnic_adapter *);
+int qlcnic_alloc_mbx_args(struct qlcnic_cmd_args *,
+			struct qlcnic_adapter *, u32);
+int qlcnic_is_valid_nic_func(struct qlcnic_adapter *, u8);
 /*
  * QLOGIC Board information
  */
@@ -1601,30 +1640,6 @@ struct qlcnic_brdinfo {
 	char short_name[QLCNIC_MAX_BOARD_NAME_LEN];
 };
 
-static const struct qlcnic_brdinfo qlcnic_boards[] = {
-	{0x1077, 0x8020, 0x1077, 0x203,
-		"8200 Series Single Port 10GbE Converged Network Adapter "
-		"(TCP/IP Networking)"},
-	{0x1077, 0x8020, 0x1077, 0x207,
-		"8200 Series Dual Port 10GbE Converged Network Adapter "
-		"(TCP/IP Networking)"},
-	{0x1077, 0x8020, 0x1077, 0x20b,
-		"3200 Series Dual Port 10Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x20c,
-		"3200 Series Quad Port 1Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x20f,
-		"3200 Series Single Port 10Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x103c, 0x3733,
-		"NC523SFP 10Gb 2-port Server Adapter"},
-	{0x1077, 0x8020, 0x103c, 0x3346,
-		"CN1000Q Dual Port Converged Network Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x210,
-		"QME8242-k 10GbE Dual Port Mezzanine Card"},
-	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
-};
-
-#define NUM_SUPPORTED_BOARDS ARRAY_SIZE(qlcnic_boards)
-
 static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)
 {
 	if (likely(tx_ring->producer < tx_ring->sw_consumer))
@@ -1635,30 +1650,63 @@ static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)
 }
 
 extern const struct ethtool_ops qlcnic_ethtool_ops;
-extern const struct ethtool_ops qlcnic_ethtool_failed_ops;
 
 struct qlcnic_nic_template {
 	int (*config_bridged_mode) (struct qlcnic_adapter *, u32);
 	int (*config_led) (struct qlcnic_adapter *, u32, u32);
 	int (*start_firmware) (struct qlcnic_adapter *);
+	int (*init_driver) (struct qlcnic_adapter *);
+	void (*request_reset) (struct qlcnic_adapter *, u32);
+	void (*cancel_idc_work) (struct qlcnic_adapter *);
+	int (*napi_add)(struct qlcnic_adapter *, struct net_device *);
+	void (*config_ipaddr)(struct qlcnic_adapter *, __be32, int);
+	irqreturn_t (*clear_legacy_intr)(struct qlcnic_adapter *);
 };
+
 /* function template for hardware ops based on different chip type */
 struct qlcnic_hardware_ops {
 	void (*read_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
 	void (*write_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
-	u32 (*rdreg) (struct qlcnic_adapter *, ulong);
+	u32 (*rdreg) (struct qlcnic_adapter *, ulong, int *);
 	int (*wrtreg) (struct qlcnic_adapter *, ulong, u32);
 	void (*get_ocm_win) (struct qlcnic_hardware_context *);
 	int (*get_mac_address) (struct qlcnic_adapter *, u8 *);
-	int (*setup_intr) (struct qlcnic_adapter *);
-	void (*mbx_cmd) (struct qlcnic_adapter *, struct qlcnic_cmd_args *);
+	int (*setup_intr) (struct qlcnic_adapter *, u8);
+	int (*alloc_mbx_args)(struct qlcnic_cmd_args *,
+				struct qlcnic_adapter *, u32);
+	int (*mbx_cmd) (struct qlcnic_adapter *, struct qlcnic_cmd_args *);
 	void (*get_func_no) (struct qlcnic_adapter *);
+	int (*api_lock) (struct qlcnic_adapter *);
+	void (*api_unlock) (struct qlcnic_adapter *);
+	void (*add_sysfs) (struct qlcnic_adapter *);
+	void (*remove_sysfs) (struct qlcnic_adapter *);
+	void (*process_lb_rcv_ring_diag) (struct qlcnic_host_sds_ring *);
+	int (*create_rx_ctx) (struct qlcnic_adapter *);
+	int (*create_tx_ctx) (struct qlcnic_adapter *,
+		 struct qlcnic_host_tx_ring *, int);
+	int (*setup_link_event) (struct qlcnic_adapter *, int);
+	int (*get_nic_info) (struct qlcnic_adapter *, struct qlcnic_info *, u8);
+	int (*get_pci_info) (struct qlcnic_adapter *, struct qlcnic_pci_info *);
+	int (*set_nic_info) (struct qlcnic_adapter *, struct qlcnic_info *);
+	int (*change_macvlan) (struct qlcnic_adapter *, u8*, __le16, u8);
+	void (*napi_enable) (struct qlcnic_adapter *);
+	void (*napi_disable) (struct qlcnic_adapter *);
+	void (*config_intr_coal) (struct qlcnic_adapter *);
+	int (*config_rss) (struct qlcnic_adapter *, int);
+	int (*config_hw_lro) (struct qlcnic_adapter *, int);
+	int (*config_loopback) (struct qlcnic_adapter *, u8);
+	int (*clear_loopback) (struct qlcnic_adapter *, u8);
+	int (*config_promisc_mode) (struct qlcnic_adapter *, u32);
+	void (*change_l2_filter) (struct qlcnic_adapter *, u64 *, __le16);
+	int (*get_board_info) (struct qlcnic_adapter *);
 };
 
+extern struct qlcnic_nic_template qlcnic_vf_ops;
+
 #define QLCDB(adapter, lvl, _fmt, _args...) do {	\
 	if (NETIF_MSG_##lvl & adapter->ahw->msg_enable)	\
 		printk(KERN_INFO "%s: %s: " _fmt,	\
-			 dev_name(&adapter->pdev->dev),	\
+			dev_name(&adapter->pdev->dev),	\
 			__func__, ##_args);		\
 	} while (0)
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index c79bc9a..b1f3a4a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -7,11 +7,91 @@
 
 #include "qlcnic.h"
 
+/* Array of FW control command structs with command type and required
+ * number of input and output arguments respectively.
+*/
+static const struct qlcnic_mailbox_metadata qlcnic_mbx_tbl[] = {
+	{ QLCNIC_CMD_CREATE_RX_CTX, 4, 1 },
+	{ QLCNIC_CMD_DESTROY_RX_CTX, 2, 1 },
+	{ QLCNIC_CMD_CREATE_TX_CTX, 4, 1 },
+	{ QLCNIC_CMD_DESTROY_TX_CTX, 2, 1 },
+	{ QLCNIC_CMD_INTRPT_TEST, 4, 1 },
+	{ QLCNIC_CMD_SET_MTU, 4, 1 },
+	{ QLCNIC_CMD_READ_PHY, 4, 2 },
+	{ QLCNIC_CMD_WRITE_PHY, 5, 1 },
+	{ QLCNIC_CMD_READ_HW_REG, 4, 1 },
+	{ QLCNIC_CMD_GET_FLOW_CTL, 4, 2 },
+	{ QLCNIC_CMD_SET_FLOW_CTL, 4, 1 },
+	{ QLCNIC_CMD_READ_MAX_MTU, 4, 2 },
+	{ QLCNIC_CMD_READ_MAX_LRO, 4, 2 },
+	{ QLCNIC_CMD_MAC_ADDRESS, 4, 3 },
+	{ QLCNIC_CMD_GET_PCI_INFO, 4, 1 },
+	{ QLCNIC_CMD_GET_NIC_INFO, 4, 1 },
+	{ QLCNIC_CMD_SET_NIC_INFO, 4, 1 },
+	{ QLCNIC_CMD_GET_ESWITCH_CAPABILITY, 4, 3 },
+	{ QLCNIC_CMD_TOGGLE_ESWITCH, 4, 1 },
+	{ QLCNIC_CMD_GET_ESWITCH_STATUS, 4, 3 },
+	{ QLCNIC_CMD_SET_PORTMIRRORING, 4, 1 },
+	{ QLCNIC_CMD_CONFIGURE_ESWITCH, 4, 1 },
+	{ QLCNIC_CMD_GET_MAC_STATS, 4, 1 },
+	{ QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG, 4, 3 },
+	{ QLCNIC_CMD_GET_ESWITCH_STATS, 5, 1 },
+	{ QLCNIC_CMD_CONFIG_PORT, 4, 1 },
+	{ QLCNIC_CMD_TEMP_SIZE, 4, 4 },
+	{ QLCNIC_CMD_GET_TEMP_HDR, 4, 1 },
+};
+
+/* Allocate mailbox incoming and outgoing registers. It should be used with a
+ * follow up call to qlcnic_free_mbx_args
+ */
+int qlcnic_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
+		struct qlcnic_adapter *adapter, u32 type)
+{
+	int i, size;
+	const struct qlcnic_mailbox_metadata *mbx_tbl;
+
+	mbx_tbl = qlcnic_mbx_tbl;
+	size = ARRAY_SIZE(qlcnic_mbx_tbl);
+	for (i = 0; i < size; i++) {
+		if (type == mbx_tbl[i].cmd) {
+			mbx->req.num = mbx_tbl[i].in_args;
+			mbx->rsp.num = mbx_tbl[i].out_args;
+			mbx->req.arg = kcalloc(mbx->req.num,
+				sizeof(u32), GFP_ATOMIC);
+			if (!mbx->req.arg)
+				return -ENOMEM;
+			mbx->rsp.arg = kcalloc(mbx->rsp.num,
+				sizeof(u32), GFP_ATOMIC);
+			if (!mbx->rsp.arg) {
+				kfree(mbx->req.arg);
+				mbx->req.arg = NULL;
+				return -ENOMEM;
+			}
+			memset(mbx->req.arg, 0, sizeof(u32) * mbx->req.num);
+			memset(mbx->rsp.arg, 0, sizeof(u32) * mbx->rsp.num);
+			mbx->req.arg[0] = type;
+			break;
+		}
+	}
+	return 0;
+}
+
+/* Free up mailbox registers
+ *  */
+void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd)
+{
+	kfree(cmd->req.arg);
+	cmd->req.arg = NULL;
+	kfree(cmd->rsp.arg);
+	cmd->rsp.arg = NULL;
+}
+
+
 static u32
 qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 {
 	u32 rsp;
-	int timeout = 0;
+	int err, timeout = 0;
 
 	do {
 		/* give atleast 1ms for firmware to respond */
@@ -20,15 +100,16 @@ qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 		if (++timeout > QLCNIC_OS_CRB_RETRY_COUNT)
 			return QLCNIC_CDRP_RSP_TIMEOUT;
 
-		rsp = QLCRD32(adapter, QLCNIC_CDRP_CRB_OFFSET);
+		rsp = QLCRD32(adapter, QLCNIC_CDRP_CRB_OFFSET, &err);
 	} while (!QLCNIC_CDRP_IS_RSP(rsp));
 
 	return rsp;
 }
 
-void
+int
 qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
 {
+	int i, err;
 	u32 rsp;
 	u32 signature;
 	struct pci_dev *pdev = adapter->pdev;
@@ -37,179 +118,60 @@ qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
 	signature = QLCNIC_CDRP_SIGNATURE_MAKE(ahw);
 
 	/* Acquire semaphore before accessing CRB */
-	if (qlcnic_api_lock(adapter)) {
-		cmd->rsp.cmd = QLCNIC_RCODE_TIMEOUT;
-		return;
+	if (ahw->hw_ops->api_lock(adapter)) {
+		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
+		return cmd->rsp.arg[0];
 	}
 
 	QLCWR32(adapter, QLCNIC_SIGN_CRB_OFFSET, signature);
-	QLCWR32(adapter, QLCNIC_ARG1_CRB_OFFSET, cmd->req.arg1);
-	QLCWR32(adapter, QLCNIC_ARG2_CRB_OFFSET, cmd->req.arg2);
-	QLCWR32(adapter, QLCNIC_ARG3_CRB_OFFSET, cmd->req.arg3);
+	for (i = 1; i < QLCNIC_CDRP_MAX_ARGS; i++)
+		QLCWR32(adapter, QLCNIC_CDRP_ARG(i), cmd->req.arg[i]);
 	QLCWR32(adapter, QLCNIC_CDRP_CRB_OFFSET,
-		QLCNIC_CDRP_FORM_CMD(cmd->req.cmd));
-
+		QLCNIC_CDRP_FORM_CMD(cmd->req.arg[0]));
 	rsp = qlcnic_poll_rsp(adapter);
 
 	if (rsp == QLCNIC_CDRP_RSP_TIMEOUT) {
-		dev_err(&pdev->dev, "CDRP response timeout.\n");
-		cmd->rsp.cmd = QLCNIC_RCODE_TIMEOUT;
+		dev_err(&pdev->dev, "card response timeout.\n");
+		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
 	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
-		cmd->rsp.cmd = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
-		switch (cmd->rsp.cmd) {
-		case QLCNIC_RCODE_INVALID_ARGS:
-			dev_err(&pdev->dev, "CDRP invalid args: 0x%x.\n",
-				cmd->rsp.cmd);
-			break;
-		case QLCNIC_RCODE_NOT_SUPPORTED:
-		case QLCNIC_RCODE_NOT_IMPL:
-			dev_err(&pdev->dev,
-				"CDRP command not supported: 0x%x.\n",
-				cmd->rsp.cmd);
-			break;
-		case QLCNIC_RCODE_NOT_PERMITTED:
-			dev_err(&pdev->dev,
-				"CDRP requested action not permitted: 0x%x.\n",
-				cmd->rsp.cmd);
-			break;
-		case QLCNIC_RCODE_INVALID:
-			dev_err(&pdev->dev,
-				"CDRP invalid or unknown cmd received: 0x%x.\n",
-				cmd->rsp.cmd);
-			break;
-		case QLCNIC_RCODE_TIMEOUT:
-			dev_err(&pdev->dev, "CDRP command timeout: 0x%x.\n",
-				cmd->rsp.cmd);
-			break;
-		default:
-			dev_err(&pdev->dev, "CDRP command failed: 0x%x.\n",
-				cmd->rsp.cmd);
-		}
-	} else if (rsp == QLCNIC_CDRP_RSP_OK) {
-		cmd->rsp.cmd = QLCNIC_RCODE_SUCCESS;
-		if (cmd->rsp.arg2)
-			cmd->rsp.arg2 = QLCRD32(adapter,
-				QLCNIC_ARG2_CRB_OFFSET);
-		if (cmd->rsp.arg3)
-			cmd->rsp.arg3 = QLCRD32(adapter,
-				QLCNIC_ARG3_CRB_OFFSET);
-	}
-	if (cmd->rsp.arg1)
-		cmd->rsp.arg1 = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
+		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1), &err);
+		dev_err(&pdev->dev, "failed card response code:0x%x\n",
+				cmd->rsp.arg[0]);
+	} else if (rsp == QLCNIC_CDRP_RSP_OK)
+		cmd->rsp.arg[0] = QLCNIC_RCODE_SUCCESS;
 
-	/* Release semaphore */
-	qlcnic_api_unlock(adapter);
+	for (i = 1; i < cmd->rsp.num; i++)
+		cmd->rsp.arg[i] = QLCRD32(adapter, QLCNIC_CDRP_ARG(i), &err);
 
+	/* Release semaphore */
+	ahw->hw_ops->api_unlock(adapter);
+	return cmd->rsp.arg[0];
 }
 
-static uint32_t qlcnic_temp_checksum(uint32_t *temp_buffer, u16 temp_size)
-{
-	uint64_t sum = 0;
-	int count = temp_size / sizeof(uint32_t);
-	while (count-- > 0)
-		sum += *temp_buffer++;
-	while (sum >> 32)
-		sum = (sum & 0xFFFFFFFF) + (sum >> 32);
-	return ~sum;
-}
-
-int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
+int
+qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu)
 {
-	int err, i;
-	u16 temp_size;
-	void *tmp_addr;
-	u32 version, csum, *template, *tmp_buf;
+	int err = 0;
 	struct qlcnic_cmd_args cmd;
-	struct qlcnic_hardware_context *ahw;
-	struct qlcnic_dump_template_hdr *tmpl_hdr, *tmp_tmpl;
-	dma_addr_t tmp_addr_t = 0;
-
-	ahw = adapter->ahw;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_TEMP_SIZE;
-	memset(&cmd.rsp, 1, sizeof(struct _cdrp_cmd));
-	ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	if (cmd.rsp.cmd != QLCNIC_RCODE_SUCCESS) {
-		dev_info(&adapter->pdev->dev,
-			"Can't get template size %d\n", cmd.rsp.cmd);
-		err = -EIO;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+
+	if (recv_ctx->state != QLCNIC_HOST_CTX_STATE_ACTIVE)
 		return err;
-	}
-	temp_size = cmd.rsp.arg2;
-	version = cmd.rsp.arg3;
-	if (!temp_size)
-		return -EIO;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_SET_MTU);
+	cmd.req.arg[1] = recv_ctx->context_id;
+	cmd.req.arg[2] = mtu;
 
-	tmp_addr = dma_alloc_coherent(&adapter->pdev->dev, temp_size,
-			&tmp_addr_t, GFP_KERNEL);
-	if (!tmp_addr) {
-		dev_err(&adapter->pdev->dev,
-			"Can't get memory for FW dump template\n");
-		return -ENOMEM;
-	}
-	memset(&cmd.rsp, 0, sizeof(struct _cdrp_cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_TEMP_HDR;
-	cmd.req.arg1 = LSD(tmp_addr_t);
-	cmd.req.arg2 = MSD(tmp_addr_t);
-	cmd.req.arg3 = temp_size;
-	ahw->hw_ops->mbx_cmd(adapter, &cmd);
-
-	err = cmd.rsp.cmd;
-	if (err != QLCNIC_RCODE_SUCCESS) {
-		dev_err(&adapter->pdev->dev,
-			"Failed to get mini dump template header %d\n", err);
-		err = -EIO;
-		goto error;
-	}
-	tmp_tmpl = tmp_addr;
-	csum = qlcnic_temp_checksum((uint32_t *) tmp_addr, temp_size);
-	if (csum) {
-		dev_err(&adapter->pdev->dev,
-			"Template header checksum validation failed\n");
-		err = -EIO;
-		goto error;
-	}
-	ahw->fw_dump.tmpl_hdr = vzalloc(temp_size);
-	if (!ahw->fw_dump.tmpl_hdr) {
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (err) {
+		dev_err(&adapter->pdev->dev, "Failed to set mtu\n");
 		err = -EIO;
-		goto error;
 	}
-	tmp_buf = tmp_addr;
-	template = (u32 *) ahw->fw_dump.tmpl_hdr;
-	for (i = 0; i < temp_size/sizeof(u32); i++)
-		*template++ = __le32_to_cpu(*tmp_buf++);
-
-	tmpl_hdr = ahw->fw_dump.tmpl_hdr;
-	tmpl_hdr->drv_cap_mask = QLCNIC_DUMP_MASK_DEF;
-	ahw->fw_dump.enable = 1;
-error:
-	dma_free_coherent(&adapter->pdev->dev, temp_size, tmp_addr, tmp_addr_t);
+	qlcnic_free_mbx_args(&cmd);
 	return err;
 }
 
 int
-qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu)
-{
-	struct qlcnic_cmd_args cmd;
-	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
-
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_SET_MTU;
-	cmd.req.arg1 = recv_ctx->context_id;
-	cmd.req.arg2 = mtu;
-	cmd.req.arg3 = 0;
-	if (recv_ctx->state == QLCNIC_HOST_CTX_STATE_ACTIVE) {
-		adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-		if (cmd.rsp.cmd) {
-			dev_err(&adapter->pdev->dev, "Failed to set mtu\n");
-			return -EIO;
-		}
-	}
-
-	return 0;
-}
-
-static int
 qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 {
 	void *addr;
@@ -263,9 +225,6 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 						| QLCNIC_CAP0_VALIDOFF);
 	cap |= (QLCNIC_CAP0_JUMBO_CONTIGUOUS | QLCNIC_CAP0_LRO_CONTIGUOUS);
 
-	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP)
-		cap |= QLCNIC_CAP0_LRO_MSS;
-
 	prq->valid_field_offset = offsetof(struct qlcnic_hostrq_rx_ctx,
 							 msix_handler);
 	prq->txrx_sds_binding = nsds_rings - 1;
@@ -313,20 +272,18 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 	}
 
 	phys_addr = hostrq_phys_addr;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = (u32) (phys_addr >> 32);
-	cmd.req.arg2 = (u32) (phys_addr & 0xffffffff);
-	cmd.req.arg3 = rq_size;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_CREATE_RX_CTX;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_CREATE_RX_CTX);
+	cmd.req.arg[1] = MSD(phys_addr);
+	cmd.req.arg[2] = LSD(phys_addr);
+	cmd.req.arg[3] = rq_size;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
 	if (err) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to create rx ctx in firmware%d\n", err);
 		goto out_free_rsp;
 	}
 
-
 	prsp_rds = ((struct qlcnic_cardrsp_rds_ring *)
 			 &prsp->data[le32_to_cpu(prsp->rds_ring_offset)]);
 
@@ -357,6 +314,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 out_free_rsp:
 	dma_free_coherent(&adapter->pdev->dev, rsp_size, prsp,
 		cardrsp_phys_addr);
+	qlcnic_free_mbx_args(&cmd);
 out_free_rq:
 	dma_free_coherent(&adapter->pdev->dev, rq_size, prq, hostrq_phys_addr);
 	return err;
@@ -365,24 +323,25 @@ out_free_rq:
 static void
 qlcnic_fw_cmd_destroy_rx_ctx(struct qlcnic_adapter *adapter)
 {
+	int err;
 	struct qlcnic_cmd_args cmd;
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = recv_ctx->context_id;
-	cmd.req.arg2 = QLCNIC_DESTROY_CTX_RESET;
-	cmd.req.arg3 = 0;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_DESTROY_RX_CTX;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	if (cmd.rsp.cmd)
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_DESTROY_RX_CTX);
+	cmd.req.arg[1] = recv_ctx->context_id;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (err)
 		dev_err(&adapter->pdev->dev,
 			"Failed to destroy rx ctx in firmware\n");
 
 	recv_ctx->state = QLCNIC_HOST_CTX_STATE_FREED;
+	qlcnic_free_mbx_args(&cmd);
 }
 
-static int
-qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
+int
+qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
+	struct qlcnic_host_tx_ring *tx_ring, int ring)
 {
 	struct qlcnic_hostrq_tx_ctx	*prq;
 	struct qlcnic_hostrq_cds_ring	*prq_cds;
@@ -394,7 +353,6 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 	int	err;
 	u64	phys_addr;
 	dma_addr_t	rq_phys_addr, rsp_phys_addr;
-	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
 
 	/* reset host resources */
 	tx_ring->producer = 0;
@@ -429,9 +387,9 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 
 	prq->host_int_crb_mode =
 		cpu_to_le32(QLCNIC_HOST_INT_CRB_MODE_SHARED);
+	prq->msi_index = 0;
 
 	prq->interrupt_ctl = 0;
-	prq->msi_index = 0;
 	prq->cmd_cons_dma_addr = cpu_to_le64(tx_ring->hw_cons_phys_addr);
 
 	prq_cds = &prq->cds_ring;
@@ -440,18 +398,17 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 	prq_cds->ring_size = cpu_to_le32(tx_ring->num_desc);
 
 	phys_addr = rq_phys_addr;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = (u32)(phys_addr >> 32);
-	cmd.req.arg2 = ((u32)phys_addr & 0xffffffff);
-	cmd.req.arg3 = rq_size;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_CREATE_TX_CTX;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_CREATE_TX_CTX);
+	cmd.req.arg[1] = MSD(phys_addr);
+	cmd.req.arg[2] = LSD(phys_addr);
+	cmd.req.arg[3] = rq_size;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
 		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
 		tx_ring->crb_cmd_producer = adapter->ahw->pci_base0 + temp;
-
 		tx_ring->ctx_id = le16_to_cpu(prsp->context_id);
 	} else {
 		dev_err(&adapter->pdev->dev,
@@ -464,44 +421,44 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 
 out_free_rq:
 	dma_free_coherent(&adapter->pdev->dev, rq_size, rq_addr, rq_phys_addr);
+	qlcnic_free_mbx_args(&cmd);
 
 	return err;
 }
 
 static void
-qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter)
+qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter,
+	struct qlcnic_host_tx_ring *tx_ring)
 {
 	struct qlcnic_cmd_args cmd;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = adapter->tx_ring->ctx_id;
-	cmd.req.arg2 = QLCNIC_DESTROY_CTX_RESET;
-	cmd.req.arg3 = 0;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_DESTROY_TX_CTX;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	if (cmd.rsp.cmd)
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_DESTROY_TX_CTX);
+	cmd.req.arg[1] = tx_ring->ctx_id;
+	if (adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd))
 		dev_err(&adapter->pdev->dev,
 			"Failed to destroy tx ctx in firmware\n");
+	qlcnic_free_mbx_args(&cmd);
 }
 
 int
 qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config)
 {
+	int err;
 	struct qlcnic_cmd_args cmd;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = config;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_CONFIG_PORT;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-
-	return cmd.rsp.cmd;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_CONFIG_PORT);
+	cmd.req.arg[1] = config;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	qlcnic_free_mbx_args(&cmd);
+	return err;
 }
 
 int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 {
 	void *addr;
-	int err;
-	int ring;
+	int err, ring;
 	struct qlcnic_recv_context *recv_ctx;
 	struct qlcnic_host_rds_ring *rds_ring;
 	struct qlcnic_host_sds_ring *sds_ring;
@@ -510,26 +467,28 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 
 	recv_ctx = adapter->recv_ctx;
-	tx_ring = adapter->tx_ring;
-
-	tx_ring->hw_consumer = (__le32 *) dma_alloc_coherent(&pdev->dev,
-		sizeof(u32), &tx_ring->hw_cons_phys_addr, GFP_KERNEL);
-	if (tx_ring->hw_consumer == NULL) {
-		dev_err(&pdev->dev, "failed to allocate tx consumer\n");
-		return -ENOMEM;
-	}
 
-	/* cmd desc ring */
-	addr = dma_alloc_coherent(&pdev->dev, TX_DESC_RINGSIZE(tx_ring),
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		tx_ring = &adapter->tx_ring[ring];
+		tx_ring->hw_consumer = (__le32 *) dma_alloc_coherent(&pdev->dev,
+			sizeof(u32), &tx_ring->hw_cons_phys_addr, GFP_KERNEL);
+		if (tx_ring->hw_consumer == NULL) {
+			dev_err(&pdev->dev, "failed to allocate tx consumer\n");
+			return -ENOMEM;
+		}
+		/* cmd desc ring */
+		addr = dma_alloc_coherent(&pdev->dev, TX_DESC_RINGSIZE(tx_ring),
 			&tx_ring->phys_addr, GFP_KERNEL);
 
-	if (addr == NULL) {
-		dev_err(&pdev->dev, "failed to allocate tx desc ring\n");
-		err = -ENOMEM;
-		goto err_out_free;
-	}
+		if (addr == NULL) {
+			dev_err(&pdev->dev,
+				 "failed to allocate tx desc ring\n");
+			err = -ENOMEM;
+			goto err_out_free;
+		}
 
-	tx_ring->desc_head = addr;
+		tx_ring->desc_head = addr;
+	}
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
@@ -568,24 +527,31 @@ err_out_free:
 	return err;
 }
 
-
 int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 {
-	int err;
+	int i, err, ring;
 
 	if (adapter->flags & QLCNIC_NEED_FLR) {
 		pci_reset_function(adapter->pdev);
 		adapter->flags &= ~QLCNIC_NEED_FLR;
 	}
 
-	err = qlcnic_fw_cmd_create_rx_ctx(adapter);
+	err = adapter->ahw->hw_ops->create_rx_ctx(adapter);
 	if (err)
 		return err;
 
-	err = qlcnic_fw_cmd_create_tx_ctx(adapter);
-	if (err) {
-		qlcnic_fw_cmd_destroy_rx_ctx(adapter);
-		return err;
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		err = adapter->ahw->hw_ops->create_tx_ctx(adapter,
+			 &adapter->tx_ring[ring], ring);
+		if (err) {
+			qlcnic_fw_cmd_destroy_rx_ctx(adapter);
+			if (ring == 0)
+				return err;
+			for (i = 0; i < ring; i++)
+				qlcnic_fw_cmd_destroy_tx_ctx(adapter,
+					 &adapter->tx_ring[i]);
+			return err;
+		}
 	}
 
 	set_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
@@ -594,9 +560,13 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 
 void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
 {
+	int ring;
+
 	if (test_and_clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state)) {
 		qlcnic_fw_cmd_destroy_rx_ctx(adapter);
-		qlcnic_fw_cmd_destroy_tx_ctx(adapter);
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++)
+			qlcnic_fw_cmd_destroy_tx_ctx(adapter,
+					&adapter->tx_ring[ring]);
 
 		/* Allow dma queues to drain after context reset */
 		msleep(20);
@@ -613,20 +583,22 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 
 	recv_ctx = adapter->recv_ctx;
 
-	tx_ring = adapter->tx_ring;
-	if (tx_ring->hw_consumer != NULL) {
-		dma_free_coherent(&adapter->pdev->dev,
-				sizeof(u32),
-				tx_ring->hw_consumer,
-				tx_ring->hw_cons_phys_addr);
-		tx_ring->hw_consumer = NULL;
-	}
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		tx_ring = &adapter->tx_ring[ring];
+		if (tx_ring->hw_consumer != NULL) {
+			dma_free_coherent(&adapter->pdev->dev,
+					sizeof(u32),
+					tx_ring->hw_consumer,
+					tx_ring->hw_cons_phys_addr);
+			tx_ring->hw_consumer = NULL;
+		}
 
-	if (tx_ring->desc_head != NULL) {
-		dma_free_coherent(&adapter->pdev->dev,
-				TX_DESC_RINGSIZE(tx_ring),
-				tx_ring->desc_head, tx_ring->phys_addr);
-		tx_ring->desc_head = NULL;
+		if (tx_ring->desc_head != NULL) {
+			dma_free_coherent(&adapter->pdev->dev,
+					TX_DESC_RINGSIZE(tx_ring),
+					tx_ring->desc_head, tx_ring->phys_addr);
+			tx_ring->desc_head = NULL;
+		}
 	}
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
@@ -654,25 +626,21 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 	}
 }
 
-
 /* Get MAC address of a NIC partition */
-
 int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 {
 	int err, i;
 	struct qlcnic_cmd_args cmd;
 	u32 mac_low, mac_high;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = adapter->ahw->pci_func | BIT_8;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_MAC_ADDRESS;
-	cmd.rsp.arg1 = cmd.rsp.arg2 = 1;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_MAC_ADDRESS);
+	cmd.req.arg[1] = adapter->ahw->pci_func | BIT_8;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
-		mac_low = cmd.rsp.arg1;
-		mac_high = cmd.rsp.arg2;
+		mac_low = cmd.rsp.arg[1];
+		mac_high = cmd.rsp.arg[2];
 
 		for (i = 0; i < 2; i++)
 			mac[i] = (u8) (mac_high >> ((1 - i) * 8));
@@ -683,7 +651,7 @@ int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 			"Failed to get mac address%d\n", err);
 		err = -EIO;
 	}
-
+	qlcnic_free_mbx_args(&cmd);
 	return err;
 }
 
@@ -693,7 +661,7 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
 {
 	int	err;
 	dma_addr_t nic_dma_t;
-	struct qlcnic_info *nic_info;
+	const struct qlcnic_info *nic_info;
 	void *nic_info_addr;
 	struct qlcnic_cmd_args cmd;
 	size_t	nic_size = sizeof(struct qlcnic_info);
@@ -705,35 +673,14 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
 	memset(nic_info_addr, 0, nic_size);
 
 	nic_info = nic_info_addr;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_NIC_INFO;
-	cmd.req.arg1 = MSD(nic_dma_t);
-	cmd.req.arg2 = LSD(nic_dma_t);
-	cmd.req.arg3 = (func_id << 16 | nic_size);
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
-
-	if (err == QLCNIC_RCODE_SUCCESS) {
-		npar_info->pci_func = le16_to_cpu(nic_info->pci_func);
-		npar_info->op_mode = le16_to_cpu(nic_info->op_mode);
-		npar_info->phys_port = le16_to_cpu(nic_info->phys_port);
-		npar_info->switch_mode = le16_to_cpu(nic_info->switch_mode);
-		npar_info->max_tx_ques = le16_to_cpu(nic_info->max_tx_ques);
-		npar_info->max_rx_ques = le16_to_cpu(nic_info->max_rx_ques);
-		npar_info->min_tx_bw = le16_to_cpu(nic_info->min_tx_bw);
-		npar_info->max_tx_bw = le16_to_cpu(nic_info->max_tx_bw);
-		npar_info->capabilities = le32_to_cpu(nic_info->capabilities);
-		npar_info->max_mtu = le16_to_cpu(nic_info->max_mtu);
 
-		dev_info(&adapter->pdev->dev,
-			"phy port: %d switch_mode: %d,\n"
-			"\tmax_tx_q: %d max_rx_q: %d min_tx_bw: 0x%x,\n"
-			"\tmax_tx_bw: 0x%x max_mtu:0x%x, capabilities: 0x%x\n",
-			npar_info->phys_port, npar_info->switch_mode,
-			npar_info->max_tx_ques, npar_info->max_rx_ques,
-			npar_info->min_tx_bw, npar_info->max_tx_bw,
-			npar_info->max_mtu, npar_info->capabilities);
-	} else {
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_NIC_INFO);
+	cmd.req.arg[1] = MSD(nic_dma_t);
+	cmd.req.arg[2] = LSD(nic_dma_t);
+	cmd.req.arg[3] = (func_id << 16 | nic_size);
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (err != QLCNIC_RCODE_SUCCESS) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to get nic info%d\n", err);
 		err = -EIO;
@@ -741,6 +688,8 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
 
 	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
 		nic_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
@@ -776,13 +725,12 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 	nic_info->min_tx_bw = cpu_to_le16(nic->min_tx_bw);
 	nic_info->max_tx_bw = cpu_to_le16(nic->max_tx_bw);
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_SET_NIC_INFO;
-	cmd.req.arg1 = MSD(nic_dma_t);
-	cmd.req.arg2 = LSD(nic_dma_t);
-	cmd.req.arg3 = ((nic->pci_func << 16) | nic_size);
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_SET_NIC_INFO);
+	cmd.req.arg[1] = MSD(nic_dma_t);
+	cmd.req.arg[2] = LSD(nic_dma_t);
+	cmd.req.arg[3] = ((nic->pci_func << 16) | nic_size);
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
 
 	if (err != QLCNIC_RCODE_SUCCESS) {
 		dev_err(&adapter->pdev->dev,
@@ -792,6 +740,8 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 
 	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
 		nic_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
@@ -814,19 +764,21 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
 	memset(pci_info_addr, 0, pci_size);
 
 	npar = pci_info_addr;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_PCI_INFO;
-	cmd.req.arg1 = MSD(pci_info_dma_t);
-	cmd.req.arg2 = LSD(pci_info_dma_t);
-	cmd.req.arg3 = pci_size;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
-
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_GET_PCI_INFO);
+	cmd.req.arg[1] = MSD(pci_info_dma_t);
+	cmd.req.arg[2] = LSD(pci_info_dma_t);
+	cmd.req.arg[3] = pci_size;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+
+	adapter->ahw->act_pci_func = 0;
 	if (err == QLCNIC_RCODE_SUCCESS) {
 		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++, npar++, pci_info++) {
 			pci_info->id = le16_to_cpu(npar->id);
 			pci_info->active = le16_to_cpu(npar->active);
 			pci_info->type = le16_to_cpu(npar->type);
+			if (pci_info->type == QLCNIC_TYPE_NIC)
+				adapter->ahw->act_pci_func++;
 			pci_info->default_port =
 				le16_to_cpu(npar->default_port);
 			pci_info->tx_min_bw =
@@ -843,6 +795,8 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
 
 	dma_free_coherent(&adapter->pdev->dev, pci_size, pci_info_addr,
 		pci_info_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
@@ -861,21 +815,20 @@ int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
 	arg1 = id | (enable_mirroring ? BIT_4 : 0);
 	arg1 |= pci_func << 8;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_SET_PORTMIRRORING;
-	cmd.req.arg1 = arg1;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_SET_PORTMIRRORING);
+	cmd.req.arg[1] = arg1;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
 
-	if (err != QLCNIC_RCODE_SUCCESS) {
+	if (err != QLCNIC_RCODE_SUCCESS)
 		dev_err(&adapter->pdev->dev,
 			"Failed to configure port mirroring%d on eswitch:%d\n",
 			pci_func, id);
-	} else {
+	else
 		dev_info(&adapter->pdev->dev,
 			"Configured eSwitch %d for port mirroring:%d\n",
 			id, pci_func);
-	}
+	qlcnic_free_mbx_args(&cmd);
 
 	return err;
 }
@@ -912,13 +865,12 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 	arg1 = func | QLCNIC_STATS_VERSION << 8 | QLCNIC_STATS_PORT << 12;
 	arg1 |= rx_tx << 15 | stats_size << 16;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_ESWITCH_STATS;
-	cmd.req.arg1 = arg1;
-	cmd.req.arg2 = MSD(stats_dma_t);
-	cmd.req.arg3 = LSD(stats_dma_t);
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_ESWITCH_STATS);
+	cmd.req.arg[1] = arg1;
+	cmd.req.arg[2] = MSD(stats_dma_t);
+	cmd.req.arg[3] = LSD(stats_dma_t);
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
 
 	if (!err) {
 		stats = stats_addr;
@@ -938,6 +890,8 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 
 	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
 		stats_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
@@ -952,6 +906,9 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 	void *stats_addr;
 	int err;
 
+	if (mac_stats == NULL)
+		return -ENOMEM;
+
 	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
 			&stats_dma_t, GFP_KERNEL);
 	if (!stats_addr) {
@@ -960,15 +917,12 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 		return -ENOMEM;
 	}
 	memset(stats_addr, 0, stats_size);
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_MAC_STATS;
-	cmd.req.arg1 = stats_size << 16;
-	cmd.req.arg2 = MSD(stats_dma_t);
-	cmd.req.arg3 = LSD(stats_dma_t);
-
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
-
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_MAC_STATS);
+	cmd.req.arg[1] = stats_size << 16;
+	cmd.req.arg[2] = MSD(stats_dma_t);
+	cmd.req.arg[3] = LSD(stats_dma_t);
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
 	if (!err) {
 		stats = stats_addr;
 		mac_stats->mac_tx_frames = le64_to_cpu(stats->mac_tx_frames);
@@ -989,11 +943,15 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 				le64_to_cpu(stats->mac_rx_length_large);
 		mac_stats->mac_rx_jabber = le64_to_cpu(stats->mac_rx_jabber);
 		mac_stats->mac_rx_dropped = le64_to_cpu(stats->mac_rx_dropped);
-		mac_stats->mac_rx_crc_error = le64_to_cpu(stats->mac_rx_crc_error);
+		mac_stats->mac_FCS_error = le64_to_cpu(stats->mac_FCS_error);
+	} else {
+		dev_err(&adapter->pdev->dev,
+			"%s: Get mac stats failed, err=%d.\n", __func__, err);
 	}
 
 	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
 		stats_dma_t);
+	qlcnic_free_mbx_args(&cmd);
 	return err;
 }
 
@@ -1053,7 +1011,7 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
 int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
 		const u8 port, const u8 rx_tx)
 {
-
+	int err;
 	u32 arg1;
 	struct qlcnic_cmd_args cmd;
 
@@ -1076,15 +1034,17 @@ int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
 	arg1 = port | QLCNIC_STATS_VERSION << 8 | func_esw << 12;
 	arg1 |= BIT_14 | rx_tx << 15;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_ESWITCH_STATS;
-	cmd.req.arg1 = arg1;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	return cmd.rsp.cmd;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_ESWITCH_STATS);
+	cmd.req.arg[1] = arg1;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	qlcnic_free_mbx_args(&cmd);
+	return err;
 
 err_ret:
-	dev_err(&adapter->pdev->dev, "Invalid argument func_esw=%d port=%d"
-		"rx_ctx=%d\n", func_esw, port, rx_tx);
+	dev_err(&adapter->pdev->dev,
+			"Invalid args func_esw %d port %d rx_ctx %d\n",
+							func_esw, port, rx_tx);
 	return -EIO;
 }
 
@@ -1097,22 +1057,21 @@ __qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
 	u8 pci_func;
 	pci_func = (*arg1 >> 8);
 
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_ESWITCH_PORT_CONFIG;
-	cmd.req.arg1 = *arg1;
-	cmd.rsp.arg1 = cmd.rsp.arg2 = 1;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	*arg1 = cmd.rsp.arg1;
-	*arg2 = cmd.rsp.arg2;
-	err = cmd.rsp.cmd;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+		QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG);
+	cmd.req.arg[1] = *arg1;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	*arg1 = cmd.rsp.arg[1];
+	*arg2 = cmd.rsp.arg[2];
+	qlcnic_free_mbx_args(&cmd);
 
-	if (err == QLCNIC_RCODE_SUCCESS) {
+	if (err == QLCNIC_RCODE_SUCCESS)
 		dev_info(&adapter->pdev->dev,
 			"eSwitch port config for pci func %d\n", pci_func);
-	} else {
+	else
 		dev_err(&adapter->pdev->dev,
 			"Failed to get eswitch port config for pci func %d\n",
 								pci_func);
-	}
 	return err;
 }
 /* Configure eSwitch port
@@ -1174,20 +1133,19 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 		return err;
 	}
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_CONFIGURE_ESWITCH;
-	cmd.req.arg1 = arg1;
-	cmd.req.arg2 = arg2;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_CONFIGURE_ESWITCH);
+	cmd.req.arg[1] = arg1;
+	cmd.req.arg[2] = arg2;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	qlcnic_free_mbx_args(&cmd);
 
-	err = cmd.rsp.cmd;
-	if (err != QLCNIC_RCODE_SUCCESS) {
+	if (err != QLCNIC_RCODE_SUCCESS)
 		dev_err(&adapter->pdev->dev,
 			"Failed to configure eswitch pci func %d\n", pci_func);
-	} else {
+	else
 		dev_info(&adapter->pdev->dev,
 			"Configured eSwitch for pci func %d\n", pci_func);
-	}
 
 	return err;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index ec2ad45..bf6b1db 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -78,53 +78,20 @@ static const char qlcnic_device_gstrings_stats[][ETH_GSTRING_LEN] = {
 	"tx numbytes",
 };
 
-static const char qlcnic_mac_stats_strings [][ETH_GSTRING_LEN] = {
-	"mac_tx_frames",
-	"mac_tx_bytes",
-	"mac_tx_mcast_pkts",
-	"mac_tx_bcast_pkts",
-	"mac_tx_pause_cnt",
-	"mac_tx_ctrl_pkt",
-	"mac_tx_lt_64b_pkts",
-	"mac_tx_lt_127b_pkts",
-	"mac_tx_lt_255b_pkts",
-	"mac_tx_lt_511b_pkts",
-	"mac_tx_lt_1023b_pkts",
-	"mac_tx_lt_1518b_pkts",
-	"mac_tx_gt_1518b_pkts",
-	"mac_rx_frames",
-	"mac_rx_bytes",
-	"mac_rx_mcast_pkts",
-	"mac_rx_bcast_pkts",
-	"mac_rx_pause_cnt",
-	"mac_rx_ctrl_pkt",
-	"mac_rx_lt_64b_pkts",
-	"mac_rx_lt_127b_pkts",
-	"mac_rx_lt_255b_pkts",
-	"mac_rx_lt_511b_pkts",
-	"mac_rx_lt_1023b_pkts",
-	"mac_rx_lt_1518b_pkts",
-	"mac_rx_gt_1518b_pkts",
-	"mac_rx_length_error",
-	"mac_rx_length_small",
-	"mac_rx_length_large",
-	"mac_rx_jabber",
-	"mac_rx_dropped",
-	"mac_rx_crc_error",
-	"mac_align_error",
-};
 
 #define QLCNIC_STATS_LEN ARRAY_SIZE(qlcnic_gstrings_stats)
-#define QLCNIC_MAC_STATS_LEN ARRAY_SIZE(qlcnic_mac_stats_strings)
-#define QLCNIC_DEVICE_STATS_LEN	ARRAY_SIZE(qlcnic_device_gstrings_stats)
-#define QLCNIC_TOTAL_STATS_LEN QLCNIC_STATS_LEN + QLCNIC_MAC_STATS_LEN
+#define QLCNIC_82XX_STATS QLCNIC_STATS_LEN
+#define QLCNIC_DEVICE_STATS_LEN(adapter)	\
+	ARRAY_SIZE(qlcnic_device_gstrings_stats)
+
+
 
 static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register_Test_on_offline",
 	"Link_Test_on_offline",
 	"Interrupt_Test_offline",
 	"Internal_Loopback_offline",
-	"External_Loopback_offline"
+	"EEPROM_Test_offline"
 };
 
 #define QLCNIC_TEST_LEN	ARRAY_SIZE(qlcnic_gstrings_test)
@@ -134,11 +101,9 @@ static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 #define QLCNIC_MAX_EEPROM_LEN   1024
 
 static const u32 diag_registers[] = {
-	CRB_CMDPEG_STATE,
-	CRB_RCVPEG_STATE,
-	CRB_XG_STATE_P3P,
-	CRB_FW_CAPABILITIES_1,
-	ISR_INT_STATE_REG,
+	QLCNIC_CMDPEG_STATE,
+	QLCNIC_RCVPEG_STATE,
+	QLCNIC_FW_CAPABILITIES,
 	QLCNIC_CRB_DRV_ACTIVE,
 	QLCNIC_CRB_DEV_STATE,
 	QLCNIC_CRB_DRV_STATE,
@@ -148,6 +113,12 @@ static const u32 diag_registers[] = {
 	QLCNIC_PEG_ALIVE_COUNTER,
 	QLCNIC_PEG_HALT_STATUS1,
 	QLCNIC_PEG_HALT_STATUS2,
+	-1
+};
+
+static const u32 ext_diag_registers[] = {
+	CRB_XG_STATE_P3P,
+	ISR_INT_STATE_REG,
 	QLCNIC_CRB_PEG_NET_0+0x3c,
 	QLCNIC_CRB_PEG_NET_1+0x3c,
 	QLCNIC_CRB_PEG_NET_2+0x3c,
@@ -156,12 +127,15 @@ static const u32 diag_registers[] = {
 };
 
 #define QLCNIC_MGMT_API_VERSION	2
-#define QLCNIC_DEV_INFO_SIZE	1
 #define QLCNIC_ETHTOOL_REGS_VER	2
+
 static int qlcnic_get_regs_len(struct net_device *dev)
 {
-	return sizeof(diag_registers) + QLCNIC_RING_REGS_LEN +
-				QLCNIC_DEV_INFO_SIZE + 1;
+	u32 len;
+
+	len = sizeof(ext_diag_registers) + sizeof(diag_registers);
+
+	return QLCNIC_RING_REGS_LEN + len + QLCNIC_DEV_INFO_SIZE + 1;
 }
 
 static int qlcnic_get_eeprom_len(struct net_device *dev)
@@ -174,10 +148,9 @@ qlcnic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 fw_major, fw_minor, fw_build;
-
-	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
-	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
-	fw_build = QLCRD32(adapter, QLCNIC_FW_VERSION_SUB);
+	fw_major = QLCRD(adapter, QLCNIC_FW_VERSION_MAJOR);
+	fw_minor = QLCRD(adapter, QLCNIC_FW_VERSION_MINOR);
+	fw_build = QLCRD(adapter, QLCNIC_FW_VERSION_SUB);
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
 		"%d.%d.%d", fw_major, fw_minor, fw_build);
 
@@ -193,7 +166,8 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
-	int check_sfp_module = 0;
+	int err, check_sfp_module = 0;
+	u16 pcifn = ahw->pci_func;
 
 	/* read which mode */
 	if (ahw->port_type == QLCNIC_GBE) {
@@ -214,9 +188,9 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		ecmd->autoneg = ahw->link_autoneg;
 
 	} else if (ahw->port_type == QLCNIC_XGBE) {
-		u32 val;
+		u32 val = 0;
+		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR, &err);
 
-		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR);
 		if (val == QLCNIC_PORT_MODE_802_3_AP) {
 			ecmd->supported = SUPPORTED_1000baseT_Full;
 			ecmd->advertising = ADVERTISED_1000baseT_Full;
@@ -226,6 +200,10 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		}
 
 		if (netif_running(dev) && ahw->has_link_events) {
+			if (QLCNIC_IS_82XX(adapter))
+				ahw->link_speed =
+					QLCNIC_READ_LINK_SPEED(adapter,
+								pcifn, &err);
 			ethtool_cmd_speed_set(ecmd, ahw->link_speed);
 			ecmd->autoneg = ahw->link_autoneg;
 			ecmd->duplex = ahw->link_duplex;
@@ -323,15 +301,10 @@ skip:
 }
 
 static int
-qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+qlcnic_set_port_config(struct qlcnic_adapter *adapter,
+	struct ethtool_cmd *ecmd)
 {
-	u32 config = 0;
-	u32 ret = 0;
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
-
-	if (adapter->ahw->port_type != QLCNIC_GBE)
-		return -EOPNOTSUPP;
-
+	u32 ret = 0, config = 0;
 	/* read which mode */
 	if (ecmd->duplex)
 		config |= 0x1;
@@ -359,6 +332,22 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		return -EOPNOTSUPP;
 	else if (ret)
 		return -EIO;
+	return ret;
+}
+
+static int
+qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+{
+	u32 ret = 0;
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
+	if (adapter->ahw->port_type != QLCNIC_GBE)
+		return -EOPNOTSUPP;
+
+	ret = qlcnic_set_port_config(adapter, ecmd);
+
+	if (!ret)
+		return ret;
 
 	adapter->ahw->link_speed = ethtool_cmd_speed(ecmd);
 	adapter->ahw->link_duplex = ecmd->duplex;
@@ -371,6 +360,20 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	return dev->netdev_ops->ndo_open(dev);
 }
 
+static int
+qlcnic_get_registers(struct qlcnic_adapter *adapter, u32 *regs_buff)
+{
+	int err, i, j = 0;
+
+	for (i = QLCNIC_DEV_INFO_SIZE + 1; diag_registers[j] != -1; j++, i++)
+		regs_buff[i] = QLCRD(adapter, diag_registers[j]);
+	j = 0;
+	while (ext_diag_registers[j] != -1)
+		regs_buff[i++] = QLCRD32(adapter,
+					ext_diag_registers[j++], &err);
+	return i;
+}
+
 static void
 qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 {
@@ -379,17 +382,18 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 *regs_buff = p;
-	int ring, i = 0, j = 0;
+	int ring, i = 0;
 
 	memset(p, 0, qlcnic_get_regs_len(dev));
+
 	regs->version = (QLCNIC_ETHTOOL_REGS_VER << 24) |
 		(ahw->revision_id << 16) | (adapter->pdev)->device;
 
 	regs_buff[0] = (0xcafe0000 | (QLCNIC_DEV_INFO_SIZE & 0xffff));
 	regs_buff[1] = QLCNIC_MGMT_API_VERSION;
 
-	for (i = QLCNIC_DEV_INFO_SIZE + 1; diag_registers[j] != -1; j++, i++)
-		regs_buff[i] = QLCRD32(adapter, diag_registers[j]);
+	if (QLCNIC_IS_82XX(adapter))
+		i = qlcnic_get_registers(adapter, regs_buff);
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return;
@@ -414,10 +418,11 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 
 static u32 qlcnic_test_link(struct net_device *dev)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 val;
 
-	val = QLCRD32(adapter, CRB_XG_STATE_P3P);
+	val = QLCRD32(adapter, CRB_XG_STATE_P3P, &err);
 	val = XG_LINK_STATE_P3P(adapter->ahw->pci_func, val);
 	return (val == XG_LINK_UP_P3P) ? 0 : 1;
 }
@@ -428,7 +433,7 @@ qlcnic_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	int offset;
-	int ret;
+	int ret = -1;
 
 	if (eeprom->len == 0)
 		return -EINVAL;
@@ -437,7 +442,8 @@ qlcnic_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 			((adapter->pdev)->device << 16);
 	offset = eeprom->offset;
 
-	ret = qlcnic_rom_fast_read_words(adapter, offset, bytes,
+	if (QLCNIC_IS_82XX(adapter))
+		ret = qlcnic_rom_fast_read_words(adapter, offset, bytes,
 						eeprom->len);
 	if (ret < 0)
 		return ret;
@@ -507,43 +513,11 @@ qlcnic_set_ringparam(struct net_device *dev,
 	return qlcnic_reset_context(adapter);
 }
 
-static void qlcnic_get_channels(struct net_device *dev,
-		struct ethtool_channels *channel)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
-
-	channel->max_rx = rounddown_pow_of_two(min_t(int,
-			adapter->ahw->max_rx_ques, num_online_cpus()));
-	channel->max_tx = adapter->ahw->max_tx_ques;
-
-	channel->rx_count = adapter->max_sds_rings;
-	channel->tx_count = adapter->ahw->max_tx_ques;
-}
-
-static int qlcnic_set_channels(struct net_device *dev,
-		struct ethtool_channels *channel)
-{
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
-}
-
 static void
 qlcnic_get_pauseparam(struct net_device *netdev,
 			  struct ethtool_pauseparam *pause)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int port = adapter->ahw->physical_port;
@@ -553,9 +527,9 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return;
 		/* get flow control settings */
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port));
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), &err);
 		pause->rx_pause = qlcnic_gb_get_rx_flowctl(val);
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, &err);
 		switch (port) {
 		case 0:
 			pause->tx_pause = !(qlcnic_gb_get_gb0_mask(val));
@@ -575,7 +549,7 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_XG_PORTS))
 			return;
 		pause->rx_pause = 1;
-		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL, &err);
 		if (port == 0)
 			pause->tx_pause = !(qlcnic_xg_get_xg0_mask(val));
 		else
@@ -592,15 +566,16 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
-	int port = adapter->ahw->physical_port;
+	int err, port = adapter->ahw->physical_port;
 	__u32 val;
 
+
 	/* read mode */
 	if (ahw->port_type == QLCNIC_GBE) {
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return -EIO;
 		/* set flow control */
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port));
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), &err);
 
 		if (pause->rx_pause)
 			qlcnic_gb_rx_flowctl(val);
@@ -609,7 +584,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 
 		QLCWR32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), val);
 		/* set autoneg */
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, &err);
 		switch (port) {
 		case 0:
 			if (pause->tx_pause)
@@ -645,7 +620,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_XG_PORTS))
 			return -EIO;
 
-		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL, &err);
 		if (port == 0) {
 			if (pause->tx_pause)
 				qlcnic_xg_unset_xg0_mask(val);
@@ -667,26 +642,28 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 
 static int qlcnic_reg_test(struct net_device *dev)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 data_read;
 
-	data_read = QLCRD32(adapter, QLCNIC_PCIX_PH_REG(0));
+
+	data_read = QLCRD32(adapter, QLCNIC_PCIX_PH_REG(0), &err);
 	if ((data_read & 0xffff) != adapter->pdev->vendor)
 		return 1;
 
 	return 0;
 }
 
+static int qlcnic_eeprom_test(struct net_device *dev)
+{
+		return 0;
+}
+
 static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 {
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	switch (sset) {
 	case ETH_SS_TEST:
 		return QLCNIC_TEST_LEN;
-	case ETH_SS_STATS:
-		if (adapter->flags & QLCNIC_ESWITCH_ENABLED)
-			return QLCNIC_TOTAL_STATS_LEN + QLCNIC_DEVICE_STATS_LEN;
-		return QLCNIC_TOTAL_STATS_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -694,39 +671,7 @@ static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 
 static int qlcnic_irq_test(struct net_device *netdev)
 {
-	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	int max_sds_rings = adapter->max_sds_rings;
-	int ret;
-	struct qlcnic_cmd_args cmd;
-
-	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-		return -EIO;
-
-	ret = qlcnic_diag_alloc_res(netdev, QLCNIC_INTERRUPT_TEST);
-	if (ret)
-		goto clear_it;
-
-	adapter->ahw->diag_cnt = 0;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_INTRPT_TEST;
-	cmd.req.arg1 = adapter->ahw->pci_func;
-	adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	ret = cmd.rsp.cmd;
-
-	if (ret)
-		goto done;
-
-	msleep(10);
-
-	ret = !adapter->ahw->diag_cnt;
-
-done:
-	qlcnic_diag_free_res(netdev, max_sds_rings);
-
-clear_it:
-	adapter->max_sds_rings = max_sds_rings;
-	clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	return ret;
+	return 0;
 }
 
 #define QLCNIC_ILB_PKT_SIZE 64
@@ -756,28 +701,29 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 {
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct qlcnic_host_sds_ring *sds_ring = &recv_ctx->sds_rings[0];
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct sk_buff *skb;
 	int i, loop, cnt = 0;
 
 	for (i = 0; i < QLCNIC_NUM_ILB_PKT; i++) {
-		skb = netdev_alloc_skb(adapter->netdev, QLCNIC_ILB_PKT_SIZE);
+		skb = dev_alloc_skb(QLCNIC_ILB_PKT_SIZE);
 		qlcnic_create_loopback_buff(skb->data, adapter->mac_addr);
 		skb_put(skb, QLCNIC_ILB_PKT_SIZE);
 
-		adapter->ahw->diag_cnt = 0;
+		ahw->diag_cnt = 0;
 		qlcnic_xmit_frame(skb, adapter->netdev);
 
 		loop = 0;
 		do {
 			msleep(1);
-			qlcnic_process_rcv_ring_diag(sds_ring);
+			ahw->hw_ops->process_lb_rcv_ring_diag(sds_ring);
 			if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP)
 				break;
-		} while (!adapter->ahw->diag_cnt);
+		} while (!ahw->diag_cnt);
 
 		dev_kfree_skb_any(skb);
 
-		if (!adapter->ahw->diag_cnt)
+		if (!ahw->diag_cnt)
 			QLCDB(adapter, DRV,
 			"LB Test: packet #%d was not received\n", i + 1);
 		else
@@ -787,8 +733,7 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 		dev_warn(&adapter->pdev->dev, "LB Test failed\n");
 		if (mode != QLCNIC_ILB_MODE) {
 			dev_warn(&adapter->pdev->dev,
-				"WARNING: Please make sure external"
-				"loopback connector is plugged in\n");
+				"Check loopback connector\n");
 		}
 		return -1;
 	}
@@ -799,21 +744,21 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int max_sds_rings = adapter->max_sds_rings;
-	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int loop = 0;
 	int ret;
 
 	if (!(ahw->capabilities & QLCNIC_FW_CAPABILITY_MULTI_LOOPBACK)) {
-		netdev_info(netdev, "Firmware is not loopback test capable\n");
+		dev_info(&adapter->pdev->dev,
+				"Firmware is not loopback test capable\n");
 		return -EOPNOTSUPP;
 	}
-
 	QLCDB(adapter, DRV, "%s loopback test in progress\n",
-		   mode == QLCNIC_ILB_MODE ? "internal" : "external");
+		mode == QLCNIC_ILB_MODE ? "internal" : "external");
 	if (ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
-		netdev_warn(netdev, "Loopback test not supported for non "
-				"privilege function\n");
+		dev_warn(&adapter->pdev->dev,
+			"Loopback test invalid for non privileged function\n");
 		return 0;
 	}
 
@@ -825,18 +770,17 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 		goto clear_it;
 
 	sds_ring = &adapter->recv_ctx->sds_rings[0];
-
-	ret = qlcnic_set_lb_mode(adapter, mode);
+	ret = ahw->hw_ops->config_loopback(adapter, mode);
 	if (ret)
 		goto free_res;
 
 	ahw->diag_cnt = 0;
 	do {
 		msleep(500);
-		qlcnic_process_rcv_ring_diag(sds_ring);
+		ahw->hw_ops->process_lb_rcv_ring_diag(sds_ring);
 		if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP) {
-			netdev_info(netdev, "firmware didnt respond to loopback"
-				" configure request\n");
+			dev_info(&adapter->pdev->dev,
+				"No response for loopback configure request\n");
 			ret = -QLCNIC_FW_NOT_RESPOND;
 			goto free_res;
 		} else if (ahw->diag_cnt) {
@@ -844,10 +788,11 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 			goto free_res;
 		}
 	} while (!QLCNIC_IS_LB_CONFIGURED(ahw->loopback_state));
-
+	/* allowing firmware to settle before running traffic */
+	msleep(2000);
 	ret = qlcnic_do_lb_test(adapter, mode);
 
-	qlcnic_clear_lb_mode(adapter);
+	ahw->hw_ops->clear_loopback(adapter, mode);
 
  free_res:
 	qlcnic_diag_free_res(netdev, max_sds_rings);
@@ -880,149 +825,100 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 		data[3] = qlcnic_loopback_test(dev, QLCNIC_ILB_MODE);
 		if (data[3])
 			eth_test->flags |= ETH_TEST_FL_FAILED;
-		if (eth_test->flags & ETH_TEST_FL_EXTERNAL_LB) {
-			data[4] = qlcnic_loopback_test(dev, QLCNIC_ELB_MODE);
-			if (data[4])
-				eth_test->flags |= ETH_TEST_FL_FAILED;
-			eth_test->flags |= ETH_TEST_FL_EXTERNAL_LB_DONE;
-		}
+
+		data[4] = qlcnic_eeprom_test(dev);
+		if (data[4])
+			eth_test->flags |= ETH_TEST_FL_FAILED;
 	}
 }
 
 static void
-qlcnic_get_strings(struct net_device *dev, u32 stringset, u8 * data)
+qlcnic_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	int index, i, j;
 
 	switch (stringset) {
 	case ETH_SS_TEST:
 		memcpy(data, *qlcnic_gstrings_test,
 		       QLCNIC_TEST_LEN * ETH_GSTRING_LEN);
 		break;
-	case ETH_SS_STATS:
-		for (index = 0; index < QLCNIC_STATS_LEN; index++) {
-			memcpy(data + index * ETH_GSTRING_LEN,
-			       qlcnic_gstrings_stats[index].stat_string,
-			       ETH_GSTRING_LEN);
-		}
-		for (j = 0; j < QLCNIC_MAC_STATS_LEN; index++, j++) {
-			memcpy(data + index * ETH_GSTRING_LEN,
-			       qlcnic_mac_stats_strings[j],
-			       ETH_GSTRING_LEN);
-		}
-		if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
-			return;
-		for (i = 0; i < QLCNIC_DEVICE_STATS_LEN; index++, i++) {
-			memcpy(data + index * ETH_GSTRING_LEN,
-			       qlcnic_device_gstrings_stats[i],
-			       ETH_GSTRING_LEN);
-		}
 	}
 }
 
-static void
-qlcnic_fill_stats(int *index, u64 *data, void *stats, int type)
+static void qlcnic_get_channels(struct net_device *dev,
+		struct ethtool_channels *channel)
 {
-	int ind = *index;
-
-	if (type == QLCNIC_MAC_STATS) {
-		struct qlcnic_mac_statistics *mac_stats =
-					(struct qlcnic_mac_statistics *)stats;
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_frames);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_bytes);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_mcast_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_bcast_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_pause_cnt);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_ctrl_pkt);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_64b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_127b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_255b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_511b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_1023b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_1518b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_tx_gt_1518b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_frames);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_bytes);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_mcast_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_bcast_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_pause_cnt);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_ctrl_pkt);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_64b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_127b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_255b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_511b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_1023b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_1518b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_rx_gt_1518b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_length_error);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_length_small);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_length_large);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_jabber);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_dropped);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_crc_error);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_align_error);
-	} else if (type == QLCNIC_ESW_STATS) {
-		struct __qlcnic_esw_statistics *esw_stats =
-				(struct __qlcnic_esw_statistics *)stats;
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->unicast_frames);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->multicast_frames);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->broadcast_frames);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->dropped_frames);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->errors);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->local_frames);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->numbytes);
-	}
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
+	channel->max_rx = rounddown_pow_of_two(min_t(int,
+			adapter->ahw->max_rx_ques, num_online_cpus()));
+	channel->max_tx = adapter->ahw->max_tx_ques;
+
+	channel->rx_count = adapter->max_sds_rings;
+	channel->tx_count = adapter->ahw->max_tx_ques;
+}
+
+static int qlcnic_set_channels(struct net_device *dev,
+		struct ethtool_channels *channel)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	int err;
+
+	if (channel->other_count || channel->combined_count ||
+	    channel->tx_count != channel->max_tx)
+		return -EINVAL;
+
+	err = qlcnic_validate_max_rss(channel->max_rx, channel->rx_count);
+	if (err)
+		return err;
 
-	*index = ind;
+	err = qlcnic_set_max_rss(adapter, channel->rx_count);
+	netdev_info(dev, "allocated 0x%x sds rings\n",
+				 adapter->max_sds_rings);
+	return err;
 }
 
 static void
-qlcnic_get_ethtool_stats(struct net_device *dev,
-			     struct ethtool_stats *stats, u64 * data)
+qlcnic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	struct qlcnic_esw_statistics port_stats;
-	struct qlcnic_mac_statistics mac_stats;
-	int index, ret;
-
-	for (index = 0; index < QLCNIC_STATS_LEN; index++) {
-		char *p =
-		    (char *)adapter +
-		    qlcnic_gstrings_stats[index].stat_offset;
-		data[index] =
-		    (qlcnic_gstrings_stats[index].sizeof_stat ==
-		     sizeof(u64)) ? *(u64 *)p:(*(u32 *)p);
-	}
+	u32 wol_cfg;
 
-	/* Retrieve MAC statistics from firmware */
-	memset(&mac_stats, 0, sizeof(struct qlcnic_mac_statistics));
-	qlcnic_get_mac_stats(adapter, &mac_stats);
-	qlcnic_fill_stats(&index, data, &mac_stats, QLCNIC_MAC_STATS);
+	wol->supported = 0;
+	wol->wolopts = 0;
 
-	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
-		return;
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
+	if (wol_cfg & (1UL << adapter->portnum))
+		wol->supported |= WAKE_MAGIC;
 
-	memset(&port_stats, 0, sizeof(struct qlcnic_esw_statistics));
-	ret = qlcnic_get_port_stats(adapter, adapter->ahw->pci_func,
-			QLCNIC_QUERY_RX_COUNTER, &port_stats.rx);
-	if (ret)
-		return;
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
+	if (wol_cfg & (1UL << adapter->portnum))
+		wol->wolopts |= WAKE_MAGIC;
+}
 
-	qlcnic_fill_stats(&index, data, &port_stats.rx, QLCNIC_ESW_STATS);
+static int
+qlcnic_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	int err;
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	u32 wol_cfg;
 
-	ret = qlcnic_get_port_stats(adapter, adapter->ahw->pci_func,
-			QLCNIC_QUERY_TX_COUNTER, &port_stats.tx);
-	if (ret)
-		return;
+	if (wol->wolopts & ~WAKE_MAGIC)
+		return -EOPNOTSUPP;
+
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
+	if (!(wol_cfg & (1 << adapter->portnum)))
+		return -EOPNOTSUPP;
 
-	qlcnic_fill_stats(&index, data, &port_stats.tx, QLCNIC_ESW_STATS);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
+	if (wol->wolopts & WAKE_MAGIC)
+		wol_cfg |= 1UL << adapter->portnum;
+	else
+		wol_cfg &= ~(1UL << adapter->portnum);
+
+	QLCWR32(adapter, QLCNIC_WOL_CONFIG, wol_cfg);
+
+	return 0;
 }
 
 static int qlcnic_set_led(struct net_device *dev,
@@ -1092,48 +988,6 @@ static int qlcnic_set_led(struct net_device *dev,
 	return err;
 }
 
-static void
-qlcnic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	u32 wol_cfg;
-
-	wol->supported = 0;
-	wol->wolopts = 0;
-
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV);
-	if (wol_cfg & (1UL << adapter->portnum))
-		wol->supported |= WAKE_MAGIC;
-
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG);
-	if (wol_cfg & (1UL << adapter->portnum))
-		wol->wolopts |= WAKE_MAGIC;
-}
-
-static int
-qlcnic_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	u32 wol_cfg;
-
-	if (wol->wolopts & ~WAKE_MAGIC)
-		return -EOPNOTSUPP;
-
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV);
-	if (!(wol_cfg & (1 << adapter->portnum)))
-		return -EOPNOTSUPP;
-
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG);
-	if (wol->wolopts & WAKE_MAGIC)
-		wol_cfg |= 1UL << adapter->portnum;
-	else
-		wol_cfg &= ~(1UL << adapter->portnum);
-
-	QLCWR32(adapter, QLCNIC_WOL_CONFIG, wol_cfg);
-
-	return 0;
-}
-
 /*
  * Set the coalescing parameters. Currently only normal is supported.
  * If rx_coalesce_usecs == 0 or rx_max_coalesced_frames == 0 then set the
@@ -1188,7 +1042,7 @@ static int qlcnic_set_intr_coalesce(struct net_device *netdev,
 			ethcoal->rx_max_coalesced_frames;
 	}
 
-	qlcnic_config_intr_coalesce(adapter);
+	adapter->ahw->hw_ops->config_intr_coal(adapter);
 
 	return 0;
 }
@@ -1287,7 +1141,7 @@ qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 static int
 qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 {
-	int i;
+	int i, err;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
 	u32 state;
@@ -1308,7 +1162,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 			return 0;
 		}
 		netdev_info(netdev, "Forcing a FW dump\n");
-		qlcnic_dev_request_reset(adapter);
+		adapter->nic_ops->request_reset(adapter, val->flag);
 		break;
 	case QLCNIC_DISABLE_FW_DUMP:
 		if (fw_dump->enable && fw_dump->tmpl_hdr) {
@@ -1328,12 +1182,12 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 		return 0;
 	case QLCNIC_FORCE_FW_RESET:
 		netdev_info(netdev, "Forcing a FW reset\n");
-		qlcnic_dev_request_reset(adapter);
+		adapter->nic_ops->request_reset(adapter, val->flag);
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
 		return 0;
 	case QLCNIC_SET_QUIESCENT:
 	case QLCNIC_RESET_QUIESCENT:
-		state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE, &err);
 		if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
 			netdev_info(netdev, "Device in FAILED state\n");
 		return 0;
@@ -1376,7 +1230,6 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
 	.set_wol = qlcnic_set_wol,
 	.self_test = qlcnic_diag_test,
 	.get_strings = qlcnic_get_strings,
-	.get_ethtool_stats = qlcnic_get_ethtool_stats,
 	.get_sset_count = qlcnic_get_sset_count,
 	.get_coalesce = qlcnic_get_intr_coalesce,
 	.set_coalesce = qlcnic_set_intr_coalesce,
@@ -1387,10 +1240,3 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
 	.get_dump_data = qlcnic_get_dump_data,
 	.set_dump = qlcnic_set_dump,
 };
-
-const struct ethtool_ops qlcnic_ethtool_failed_ops = {
-	.get_settings = qlcnic_get_settings,
-	.get_drvinfo = qlcnic_get_drvinfo,
-	.set_msglevel = qlcnic_set_msglevel,
-	.get_msglevel = qlcnic_get_msglevel,
-};
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index 92cd3c3..72615d1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -11,6 +11,8 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 
+#include "qlcnic_hw.h"
+
 /*
  * The basic unit of access when reading/writing control registers.
  */
@@ -387,9 +389,6 @@ enum {
 #define QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT (ROMUSB_ROM + 0x0014)
 #define QLCNIC_ROMUSB_ROM_RDATA		(ROMUSB_ROM + 0x0018)
 
-/* Lock IDs for ROM lock */
-#define ROM_LOCK_DRIVER	0x0d417340
-
 /******************************************************************************
 *
 *    Definitions specific to M25P flash
@@ -488,7 +487,7 @@ enum {
 #define QLCNIC_NIU_GB_MAC_CONFIG_1(I)		\
 		(QLCNIC_CRB_NIU + 0x30004 + (I)*0x10000)
 
-
+#define MAX_CTL_CHECK   1000
 #define TEST_AGT_CTRL	(0x00)
 
 #define TA_CTL_START	BIT_0
@@ -496,26 +495,26 @@ enum {
 #define TA_CTL_WRITE	BIT_2
 #define TA_CTL_BUSY	BIT_3
 
-/*
- *   Register offsets for MN
- */
-#define MIU_TEST_AGT_BASE		(0x90)
-
-#define MIU_TEST_AGT_ADDR_LO		(0x04)
-#define MIU_TEST_AGT_ADDR_HI		(0x08)
-#define MIU_TEST_AGT_WRDATA_LO		(0x10)
-#define MIU_TEST_AGT_WRDATA_HI		(0x14)
-#define MIU_TEST_AGT_WRDATA_UPPER_LO	(0x20)
-#define MIU_TEST_AGT_WRDATA_UPPER_HI	(0x24)
-#define MIU_TEST_AGT_WRDATA(i)		(0x10+(0x10*((i)>>1))+(4*((i)&1)))
-#define MIU_TEST_AGT_RDDATA_LO		(0x18)
-#define MIU_TEST_AGT_RDDATA_HI		(0x1c)
-#define MIU_TEST_AGT_RDDATA_UPPER_LO	(0x28)
-#define MIU_TEST_AGT_RDDATA_UPPER_HI	(0x2c)
-#define MIU_TEST_AGT_RDDATA(i)		(0x18+(0x10*((i)>>1))+(4*((i)&1)))
-
-#define MIU_TEST_AGT_ADDR_MASK		0xfffffff8
-#define MIU_TEST_AGT_UPPER_ADDR(off)	(0)
+#define QLCNIC_MS_CTRL     0x41000090
+#define QLCNIC_MS_ADDR_LO  0x41000094
+#define QLCNIC_MS_ADDR_HI  0x41000098
+
+#define QLCNIC_MS_WRTDATA_LO       0x410000A0
+#define QLCNIC_MS_WRTDATA_HI       0x410000A4
+#define QLCNIC_MS_WRTDATA_ULO      0x410000B0
+#define QLCNIC_MS_WRTDATA_UHI      0x410000B4
+
+#define QLCNIC_MS_RDDATA_LO        0x410000A8
+#define QLCNIC_MS_RDDATA_HI        0x410000AC
+#define QLCNIC_MS_RDDATA_ULO       0x410000B8
+#define QLCNIC_MS_RDDATA_UHI       0x410000BC
+
+static const u32 QLCNIC_MS_READ_DATA[] = {
+	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC, };
+
+#define QLC_TA_WRITE_ENABLE (TA_CTL_ENABLE | TA_CTL_WRITE)
+#define QLC_TA_WRITE_START (TA_CTL_START | TA_CTL_ENABLE | TA_CTL_WRITE)
+#define QLC_TA_START_ENABLE (TA_CTL_START | TA_CTL_ENABLE)
 
 /* XG Link status */
 #define XG_LINK_UP	0x10
@@ -536,9 +535,6 @@ enum {
 
 #define QLCNIC_CAM_RAM_BASE	(QLCNIC_CRB_CAM + 0x02000)
 #define QLCNIC_CAM_RAM(reg)	(QLCNIC_CAM_RAM_BASE + (reg))
-#define QLCNIC_FW_VERSION_MAJOR (QLCNIC_CAM_RAM(0x150))
-#define QLCNIC_FW_VERSION_MINOR (QLCNIC_CAM_RAM(0x154))
-#define QLCNIC_FW_VERSION_SUB	(QLCNIC_CAM_RAM(0x158))
 #define QLCNIC_ROM_LOCK_ID	(QLCNIC_CAM_RAM(0x100))
 #define QLCNIC_PHY_LOCK_ID	(QLCNIC_CAM_RAM(0x120))
 #define QLCNIC_CRB_WIN_LOCK_ID	(QLCNIC_CAM_RAM(0x124))
@@ -548,23 +544,19 @@ enum {
 #define QLCNIC_REG(X)		(NIC_CRB_BASE+(X))
 #define QLCNIC_REG_2(X) 	(NIC_CRB_BASE_2+(X))
 
+#define QLCNIC_CDRP_MAX_ARGS   4
+#define QLCNIC_CDRP_ARG(i)             (QLCNIC_REG(0x18 + ((i) * 4)))
+
 #define QLCNIC_CDRP_CRB_OFFSET		(QLCNIC_REG(0x18))
-#define QLCNIC_ARG1_CRB_OFFSET		(QLCNIC_REG(0x1c))
-#define QLCNIC_ARG2_CRB_OFFSET		(QLCNIC_REG(0x20))
-#define QLCNIC_ARG3_CRB_OFFSET		(QLCNIC_REG(0x24))
 #define QLCNIC_SIGN_CRB_OFFSET		(QLCNIC_REG(0x28))
 
-#define CRB_CMDPEG_STATE		(QLCNIC_REG(0x50))
-#define CRB_RCVPEG_STATE		(QLCNIC_REG(0x13c))
 
 #define CRB_XG_STATE_P3P		(QLCNIC_REG(0x98))
 #define CRB_PF_LINK_SPEED_1		(QLCNIC_REG(0xe8))
 
-#define CRB_TEMP_STATE			(QLCNIC_REG(0x1b4))
 
 #define CRB_DRIVER_VERSION		(QLCNIC_REG(0x2a0))
 
-#define CRB_FW_CAPABILITIES_1		(QLCNIC_CAM_RAM(0x128))
 #define CRB_FW_CAPABILITIES_2		(QLCNIC_CAM_RAM(0x12c))
 
 /*
@@ -653,17 +645,6 @@ enum {
 #define QLCNIC_PEG_TUNE_CAPABILITY	(QLCNIC_CAM_RAM(0x02c))
 
 #define QLCNIC_DMA_WATCHDOG_CTRL	(QLCNIC_CAM_RAM(0x14))
-#define QLCNIC_PEG_ALIVE_COUNTER	(QLCNIC_CAM_RAM(0xb0))
-#define QLCNIC_PEG_HALT_STATUS1 	(QLCNIC_CAM_RAM(0xa8))
-#define QLCNIC_PEG_HALT_STATUS2 	(QLCNIC_CAM_RAM(0xac))
-#define QLCNIC_CRB_DRV_ACTIVE	(QLCNIC_CAM_RAM(0x138))
-#define QLCNIC_CRB_DEV_STATE		(QLCNIC_CAM_RAM(0x140))
-
-#define QLCNIC_CRB_DRV_STATE		(QLCNIC_CAM_RAM(0x144))
-#define QLCNIC_CRB_DRV_SCRATCH		(QLCNIC_CAM_RAM(0x148))
-#define QLCNIC_CRB_DEV_PARTITION_INFO	(QLCNIC_CAM_RAM(0x14c))
-#define QLCNIC_CRB_DRV_IDC_VER		(QLCNIC_CAM_RAM(0x174))
-#define QLCNIC_CRB_DEV_NPAR_STATE	(QLCNIC_CAM_RAM(0x19c))
 #define QLCNIC_ROM_DEV_INIT_TIMEOUT	(0x3e885c)
 #define QLCNIC_ROM_DRV_RESET_TIMEOUT	(0x3e8860)
 
@@ -682,7 +663,6 @@ enum {
 #define QLCNIC_DEV_NPAR_OPER		1 /* NPAR Operational */
 #define QLCNIC_DEV_NPAR_OPER_TIMEO	30 /* Operational time out */
 
-#define QLC_DEV_CHECK_ACTIVE(VAL, FN)		((VAL) & (1 << (FN * 4)))
 #define QLC_DEV_SET_REF_CNT(VAL, FN)		((VAL) |= (1 << (FN * 4)))
 #define QLC_DEV_CLR_REF_CNT(VAL, FN)		((VAL) &= ~(1 << (FN * 4)))
 #define QLC_DEV_SET_RST_RDY(VAL, FN)		((VAL) |= (1 << (FN * 4)))
@@ -739,16 +719,11 @@ struct qlcnic_legacy_intr_set {
 	u32	tgt_mask_reg;
 };
 
-#define QLCNIC_FW_API		0x1b216c
-#define QLCNIC_DRV_OP_MODE	0x1b2170
 #define QLCNIC_MSIX_BASE	0x132110
 #define QLCNIC_MAX_PCI_FUNC	8
 #define QLCNIC_MAX_VLAN_FILTERS	64
 
 /* FW dump defines */
-#define MIU_TEST_CTR		0x41000090
-#define MIU_TEST_ADDR_LO	0x41000094
-#define MIU_TEST_ADDR_HI	0x41000098
 #define FLASH_ROM_WINDOW	0x42110030
 #define FLASH_ROM_DATA		0x42150000
 
@@ -756,36 +731,18 @@ struct qlcnic_legacy_intr_set {
 static const u32 FW_DUMP_LEVELS[] = {
 	0x3, 0x7, 0xf, 0x1f, 0x3f, 0x7f, 0xff };
 
-static const u32 MIU_TEST_READ_DATA[] = {
-	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC, };
-
 #define QLCNIC_FW_DUMP_REG1	0x00130060
 #define QLCNIC_FW_DUMP_REG2	0x001e0000
 #define QLCNIC_FLASH_SEM2_LK	0x0013C010
 #define QLCNIC_FLASH_SEM2_ULK	0x0013C014
 #define QLCNIC_FLASH_LOCK_ID	0x001B2100
 
-#define QLCNIC_RD_DUMP_REG(addr, bar0, data) do {			\
-	writel((addr & 0xFFFF0000), (void *) (bar0 +			\
-		QLCNIC_FW_DUMP_REG1));					\
-	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG1));			\
-	*data = readl((void *) (bar0 + QLCNIC_FW_DUMP_REG2 +		\
-		LSW(addr)));						\
-} while (0)
-
-#define QLCNIC_WR_DUMP_REG(addr, bar0, data) do {			\
-	writel((addr & 0xFFFF0000), (void *) (bar0 +			\
-		QLCNIC_FW_DUMP_REG1));					\
-	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG1));			\
-	writel(data, (void *) (bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr)));\
-	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr)));	\
-} while (0)
-
 /* PCI function operational mode */
 enum {
 	QLCNIC_MGMT_FUNC	= 0,
 	QLCNIC_PRIV_FUNC	= 1,
-	QLCNIC_NON_PRIV_FUNC	= 2
+	QLCNIC_NON_PRIV_FUNC	= 2,
+	QLCNIC_UNKNOWN_FUNC_MODE = 3
 };
 
 enum {
@@ -986,6 +943,8 @@ enum {
 #define QLCNIC_NIU_PROMISC_MODE		1
 #define QLCNIC_NIU_ALLMULTI_MODE	2
 
+#define QLCNIC_PCIE_SEM_TIMEOUT	10000
+
 struct crb_128M_2M_sub_block_map {
 	unsigned valid;
 	unsigned start_128M;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 3ec03e1..fb7a0b7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -7,23 +7,12 @@
 
 #include "qlcnic.h"
 #include "qlcnic_hdr.h"
+#include "qlcnic_hw.h"
 
 #include <linux/slab.h>
 #include <net/ip.h>
 #include <linux/bitops.h>
 
-#define MASK(n) ((1ULL<<(n))-1)
-#define OCM_WIN_P3P(addr) (addr & 0xffc0000)
-
-#define GET_MEM_OFFS_2M(addr) (addr & MASK(18))
-
-#define CRB_BLK(off)	((off >> 20) & 0x3f)
-#define CRB_SUBBLK(off)	((off >> 16) & 0xf)
-#define CRB_WINDOW_2M	(0x130060)
-#define CRB_HI(off)	((crb_hub_agt[CRB_BLK(off)] << 20) | ((off) & 0xf0000))
-#define CRB_INDIRECT_2M	(0x1e0000UL)
-
-
 #ifndef readq
 static inline u64 readq(void __iomem *addr)
 {
@@ -276,21 +265,50 @@ static const u32 msi_tgt_status[8] = {
 
 /*  PCI Windowing for DDR regions.  */
 
-#define QLCNIC_PCIE_SEM_TIMEOUT	10000
+static void
+qlcnic_read_dump_reg(u32 addr, void __iomem *bar0, u32 *data)
+{
+	u32 dest;
+	void __iomem *val;
+
+	dest = addr & 0xFFFF0000;
+	val = bar0 + QLCNIC_FW_DUMP_REG1;
+	writel(dest, val);
+	readl(val);
+	val = bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr);
+	*data = readl(val);
+}
+
+static void
+qlcnic_write_dump_reg(u32 addr, void __iomem *bar0, u32 data)
+{
+	u32 dest;
+	void __iomem *val;
+
+	dest = addr & 0xFFFF0000;
+	val = bar0 + QLCNIC_FW_DUMP_REG1;
+	writel(dest, val);
+	readl(val);
+	val = bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr);
+	writel(data, val);
+	readl(val);
+}
 
 int
 qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 {
-	int done = 0, timeout = 0;
+	int err, done = 0, timeout = 0;
 
 	while (!done) {
-		done = QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)));
+		done = QLCRD32(adapter,
+			QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)), &err);
 		if (done == 1)
 			break;
 		if (++timeout >= QLCNIC_PCIE_SEM_TIMEOUT) {
 			dev_err(&adapter->pdev->dev,
-				"Failed to acquire sem=%d lock; holdby=%d\n",
-				sem, id_reg ? QLCRD32(adapter, id_reg) : -1);
+				"Failed to acquire sem=%d lock; held by=%d\n",
+				sem,
+				id_reg ? QLCRD32(adapter, id_reg, &err) : -1);
 			return -EIO;
 		}
 		msleep(1);
@@ -302,10 +320,28 @@ qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 	return 0;
 }
 
+u32 qlcnic_ind_rd(struct qlcnic_adapter *adapter, u32 addr)
+{
+	u32 data;
+
+	if (QLCNIC_IS_82XX(adapter))
+		qlcnic_read_dump_reg(addr, adapter->ahw->pci_base0, &data);
+	else
+		return -EIO;
+	return data;
+}
+
+void qlcnic_ind_wr(struct qlcnic_adapter *adapter, u32 addr, u32 data)
+{
+	if (QLCNIC_IS_82XX(adapter))
+		qlcnic_write_dump_reg(addr, adapter->ahw->pci_base0, data);
+}
+
 void
 qlcnic_pcie_sem_unlock(struct qlcnic_adapter *adapter, int sem)
 {
-	QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_UNLOCK(sem)));
+	int err;
+	QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_UNLOCK(sem)), &err);
 }
 
 static int
@@ -365,9 +401,9 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static int
+int
 qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
-				__le16 vlan_id, unsigned op)
+				__le16 vlan_id, u8 op)
 {
 	struct qlcnic_nic_req req;
 	struct qlcnic_mac_req *mac_req;
@@ -410,7 +446,7 @@ static int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, const u8 *addr)
 	}
 	memcpy(cur->mac_addr, addr, ETH_ALEN);
 
-	if (qlcnic_sre_macaddr_change(adapter,
+	if (adapter->ahw->hw_ops->change_macvlan(adapter,
 				cur->mac_addr, 0, QLCNIC_MAC_ADD)) {
 		kfree(cur);
 		return -EIO;
@@ -461,7 +497,7 @@ send_fw_cmd:
 		adapter->mac_learn = 0;
 	}
 
-	qlcnic_nic_set_promisc(adapter, mode);
+	adapter->ahw->hw_ops->config_promisc_mode(adapter, mode);
 }
 
 int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
@@ -490,7 +526,7 @@ void qlcnic_free_mac_list(struct qlcnic_adapter *adapter)
 
 	while (!list_empty(head)) {
 		cur = list_entry(head->next, struct qlcnic_mac_list_s, list);
-		qlcnic_sre_macaddr_change(adapter,
+		adapter->ahw->hw_ops->change_macvlan(adapter,
 				cur->mac_addr, 0, QLCNIC_MAC_DEL);
 		list_del(&cur->list);
 		kfree(cur);
@@ -511,7 +547,7 @@ void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter)
 		{
 			if (jiffies >
 				(QLCNIC_FILTER_AGE * HZ + tmp_fil->ftime)) {
-				qlcnic_sre_macaddr_change(adapter,
+				adapter->ahw->hw_ops->change_macvlan(adapter,
 					tmp_fil->faddr, tmp_fil->vlan_id,
 					tmp_fil->vlan_id ? QLCNIC_MAC_VLAN_DEL :
 					QLCNIC_MAC_DEL);
@@ -536,9 +572,10 @@ void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
 		head = &(adapter->fhash.fhead[i]);
 
 		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
-			qlcnic_sre_macaddr_change(adapter, tmp_fil->faddr,
-				tmp_fil->vlan_id, tmp_fil->vlan_id ?
-				QLCNIC_MAC_VLAN_DEL :  QLCNIC_MAC_DEL);
+			adapter->ahw->hw_ops->change_macvlan(adapter,
+				tmp_fil->faddr, tmp_fil->vlan_id,
+				tmp_fil->vlan_id ?  QLCNIC_MAC_VLAN_DEL :
+				QLCNIC_MAC_DEL);
 			spin_lock_bh(&adapter->mac_learn_lock);
 			adapter->fhash.fnum--;
 			hlist_del(&tmp_fil->fnode);
@@ -573,7 +610,8 @@ int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 	if (qlcnic_set_fw_loopback(adapter, mode))
 		return -EIO;
 
-	if (qlcnic_nic_set_promisc(adapter, VPORT_MISS_MODE_ACCEPT_ALL)) {
+	if (adapter->ahw->hw_ops->config_promisc_mode(adapter,
+		VPORT_MISS_MODE_ACCEPT_ALL)) {
 		qlcnic_set_fw_loopback(adapter, 0);
 		return -EIO;
 	}
@@ -582,11 +620,11 @@ int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 	return 0;
 }
 
-void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter)
+int qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 {
-	int mode = VPORT_MISS_MODE_DROP;
 	struct net_device *netdev = adapter->netdev;
 
+	mode = VPORT_MISS_MODE_DROP;
 	qlcnic_set_fw_loopback(adapter, 0);
 
 	if (netdev->flags & IFF_PROMISC)
@@ -594,14 +632,15 @@ void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter)
 	else if (netdev->flags & IFF_ALLMULTI)
 		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
 
-	qlcnic_nic_set_promisc(adapter, mode);
+	adapter->ahw->hw_ops->config_promisc_mode(adapter, mode);
 	msleep(1000);
+	return 0;
 }
 
 /*
  * Send the interrupt coalescing parameter set by ethtool to the card.
  */
-int qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
+void qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_nic_req req;
 	int rv;
@@ -623,7 +662,6 @@ int qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
 	if (rv != 0)
 		dev_err(&adapter->netdev->dev,
 			"Could not send interrupt coalescing parameters\n");
-	return rv;
 }
 
 int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
@@ -681,9 +719,6 @@ int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 	return rv;
 }
 
-
-#define RSS_HASHTYPE_IP_TCP	0x3
-
 int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
 {
 	struct qlcnic_nic_req req;
@@ -727,7 +762,7 @@ int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
 	return rv;
 }
 
-int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
+void qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
 {
 	struct qlcnic_nic_req req;
 	struct qlcnic_ipaddr *ipa;
@@ -747,10 +782,8 @@ int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
 	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 	if (rv != 0)
 		dev_err(&adapter->netdev->dev,
-				"could not notify %s IP 0x%x reuqest\n",
+				"could not notify %s IP 0x%x request\n",
 				(cmd == QLCNIC_IP_UP) ? "Add" : "Remove", ip);
-
-	return rv;
 }
 
 int qlcnic_linkevent_request(struct qlcnic_adapter *adapter, int enable)
@@ -758,14 +791,12 @@ int qlcnic_linkevent_request(struct qlcnic_adapter *adapter, int enable)
 	struct qlcnic_nic_req req;
 	u64 word;
 	int rv;
-
 	memset(&req, 0, sizeof(struct qlcnic_nic_req));
 	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
 
 	word = QLCNIC_H2C_OPCODE_GET_LINKEVENT | ((u64)adapter->portnum << 16);
 	req.req_hdr = cpu_to_le64(word);
 	req.words[0] = cpu_to_le64(enable | (enable << 8));
-
 	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 	if (rv != 0)
 		dev_err(&adapter->netdev->dev,
@@ -963,7 +994,7 @@ qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
 }
 
 u32
-qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
+qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off, int *err)
 {
 	unsigned long flags;
 	int rv;
@@ -989,6 +1020,9 @@ qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
 	dev_err(&adapter->pdev->dev,
 			"%s: invalid offset: 0x%016lx\n", __func__, off);
 	dump_stack();
+	if (err)
+		*err = -1;
+
 	return -1;
 }
 
@@ -1003,36 +1037,19 @@ qlcnic_get_ioaddr(struct qlcnic_hardware_context *ahw, u32 offset)
 	return addr;
 }
 
-
-static int
-qlcnic_pci_set_window_2M(struct qlcnic_adapter *adapter,
-		u64 addr, u32 *start)
-{
-	u32 window;
-
-	window = OCM_WIN_P3P(addr);
-
-	writel(window, adapter->ahw->ocm_win_crb);
-	/* read back to flush */
-	readl(adapter->ahw->ocm_win_crb);
-
-	*start = QLCNIC_PCI_OCM0_2M + GET_MEM_OFFS_2M(addr);
-	return 0;
-}
-
 static int
-qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u64 off,
-		u64 *data, int op)
+qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u32 window,
+	u64 off, u64 *data, int op)
 {
 	void __iomem *addr;
-	int ret;
 	u32 start;
 
 	mutex_lock(&adapter->ahw->mem_lock);
 
-	ret = qlcnic_pci_set_window_2M(adapter, off, &start);
-	if (ret != 0)
-		goto unlock;
+	writel(window, adapter->ahw->ocm_win_crb);
+	/* read back to flush */
+	readl(adapter->ahw->ocm_win_crb);
+	start = QLCNIC_PCI_OCM0_2M + off;
 
 	addr = adapter->ahw->pci_base0 + start;
 
@@ -1041,10 +1058,12 @@ qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u64 off,
 	else		/* write */
 		writeq(*data, addr);
 
-unlock:
-	mutex_unlock(&adapter->ahw->mem_lock);
+	/* Set window to 0 */
+	writel(0, adapter->ahw->ocm_win_crb);
+	readl(adapter->ahw->ocm_win_crb);
 
-	return ret;
+	mutex_unlock(&adapter->ahw->mem_lock);
+	return 0;
 }
 
 void
@@ -1071,52 +1090,79 @@ qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *adapter, u64 off, u64 data)
 
 #define MAX_CTL_CHECK   1000
 
+/* Set MS memory control data for different chip type*/
+static void
+qlcnic_set_ms_controls(struct qlcnic_adapter *adapter, u64 off,
+	struct qlcnic_ms_reg_ctrl *ms)
+{
+	ms->control = QLCNIC_MS_CTRL;
+	ms->low = QLCNIC_MS_ADDR_LO;
+	ms->hi = QLCNIC_MS_ADDR_HI;
+	if (off & 0xf) {
+		ms->wd[0] = QLCNIC_MS_WRTDATA_LO;
+		ms->rd[0] = QLCNIC_MS_RDDATA_LO;
+		ms->wd[1] = QLCNIC_MS_WRTDATA_HI;
+		ms->rd[1] = QLCNIC_MS_RDDATA_HI;
+		ms->wd[2] = QLCNIC_MS_WRTDATA_ULO;
+		ms->wd[3] = QLCNIC_MS_WRTDATA_UHI;
+		ms->rd[2] = QLCNIC_MS_RDDATA_ULO;
+		ms->rd[3] = QLCNIC_MS_RDDATA_UHI;
+	} else {
+		ms->wd[0] = QLCNIC_MS_WRTDATA_ULO;
+		ms->rd[0] = QLCNIC_MS_RDDATA_ULO;
+		ms->wd[1] = QLCNIC_MS_WRTDATA_UHI;
+		ms->rd[1] = QLCNIC_MS_RDDATA_UHI;
+		ms->wd[2] = QLCNIC_MS_WRTDATA_LO;
+		ms->wd[3] = QLCNIC_MS_WRTDATA_HI;
+		ms->rd[2] = QLCNIC_MS_RDDATA_LO;
+		ms->rd[3] = QLCNIC_MS_RDDATA_HI;
+	}
+	if (QLCNIC_IS_83XX(adapter)) {
+		ms->ocm_window = OCM_WIN_83XX(off);
+		ms->off = GET_83XX_OCM_OFFSET(off);
+	} else {
+		ms->ocm_window = OCM_WIN_P3P(off);
+		ms->off = GET_MEM_OFFS_2M(off);
+	}
+}
+
 int
 qlcnic_pci_mem_write_2M(struct qlcnic_adapter *adapter,
 		u64 off, u64 data)
 {
-	int i, j, ret;
+	int j, ret = 0;
 	u32 temp, off8;
-	void __iomem *mem_crb;
+	struct qlcnic_ms_reg_ctrl ms;
 
 	/* Only 64-bit aligned access */
 	if (off & 7)
 		return -EIO;
 
-	/* P3 onward, test agent base for MIU and SIU is same */
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
-				QLCNIC_ADDR_QDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
-				QLCNIC_CRB_QDR_NET+MIU_TEST_AGT_BASE);
-		goto correct;
-	}
+	memset(&ms, 0, sizeof(struct qlcnic_ms_reg_ctrl));
+	if (!((ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
+		QLCNIC_ADDR_QDR_NET_MAX)) ||
+			(ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET,
+				QLCNIC_ADDR_DDR_NET_MAX))))
+		return -EIO;
 
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET, QLCNIC_ADDR_DDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
-				QLCNIC_CRB_DDR_NET+MIU_TEST_AGT_BASE);
-		goto correct;
-	}
+	qlcnic_set_ms_controls(adapter, off, &ms);
 
 	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_OCM0, QLCNIC_ADDR_OCM0_MAX))
-		return qlcnic_pci_mem_access_direct(adapter, off, &data, 1);
+		return qlcnic_pci_mem_access_direct(adapter, ms.ocm_window,
+			ms.off, &data, 1);
 
-	return -EIO;
-
-correct:
 	off8 = off & ~0xf;
 
 	mutex_lock(&adapter->ahw->mem_lock);
 
-	writel(off8, (mem_crb + MIU_TEST_AGT_ADDR_LO));
-	writel(0, (mem_crb + MIU_TEST_AGT_ADDR_HI));
+	qlcnic_ind_wr(adapter, ms.low, off8);
+	qlcnic_ind_wr(adapter, ms.hi, 0);
 
-	i = 0;
-	writel(TA_CTL_ENABLE, (mem_crb + TEST_AGT_CTRL));
-	writel((TA_CTL_START | TA_CTL_ENABLE),
-			(mem_crb + TEST_AGT_CTRL));
+	qlcnic_ind_wr(adapter, ms.control, TA_CTL_ENABLE);
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_START_ENABLE);
 
 	for (j = 0; j < MAX_CTL_CHECK; j++) {
-		temp = readl(mem_crb + TEST_AGT_CTRL);
+		temp = qlcnic_ind_rd(adapter, ms.control);
 		if ((temp & TA_CTL_BUSY) == 0)
 			break;
 	}
@@ -1126,24 +1172,18 @@ correct:
 		goto done;
 	}
 
-	i = (off & 0xf) ? 0 : 2;
-	writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i)),
-			mem_crb + MIU_TEST_AGT_WRDATA(i));
-	writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i+1)),
-			mem_crb + MIU_TEST_AGT_WRDATA(i+1));
-	i = (off & 0xf) ? 2 : 0;
+	/* This is the modify part of read-modify-write */
+	qlcnic_ind_wr(adapter, ms.wd[0], qlcnic_ind_rd(adapter, ms.rd[0]));
+	qlcnic_ind_wr(adapter, ms.wd[1], qlcnic_ind_rd(adapter, ms.rd[1]));
+	/* This is the write part of read-modify-write */
+	qlcnic_ind_wr(adapter, ms.wd[2], data & 0xffffffff);
+	qlcnic_ind_wr(adapter, ms.wd[3], (data >> 32) & 0xffffffff);
 
-	writel(data & 0xffffffff,
-			mem_crb + MIU_TEST_AGT_WRDATA(i));
-	writel((data >> 32) & 0xffffffff,
-			mem_crb + MIU_TEST_AGT_WRDATA(i+1));
-
-	writel((TA_CTL_ENABLE | TA_CTL_WRITE), (mem_crb + TEST_AGT_CTRL));
-	writel((TA_CTL_START | TA_CTL_ENABLE | TA_CTL_WRITE),
-			(mem_crb + TEST_AGT_CTRL));
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_WRITE_ENABLE);
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_WRITE_START);
 
 	for (j = 0; j < MAX_CTL_CHECK; j++) {
-		temp = readl(mem_crb + TEST_AGT_CTRL);
+		temp = qlcnic_ind_rd(adapter, ms.control);
 		if ((temp & TA_CTL_BUSY) == 0)
 			break;
 	}
@@ -1169,45 +1209,36 @@ qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter,
 	int j, ret;
 	u32 temp, off8;
 	u64 val;
-	void __iomem *mem_crb;
+	struct qlcnic_ms_reg_ctrl ms;
 
 	/* Only 64-bit aligned access */
 	if (off & 7)
 		return -EIO;
+	if (!((ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
+		QLCNIC_ADDR_QDR_NET_MAX)) ||
+			(ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET,
+				QLCNIC_ADDR_DDR_NET_MAX))))
+		return -EIO ;
 
-	/* P3 onward, test agent base for MIU and SIU is same */
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
-				QLCNIC_ADDR_QDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
-				QLCNIC_CRB_QDR_NET+MIU_TEST_AGT_BASE);
-		goto correct;
-	}
-
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET, QLCNIC_ADDR_DDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
-				QLCNIC_CRB_DDR_NET+MIU_TEST_AGT_BASE);
-		goto correct;
-	}
+	memset(&ms, 0, sizeof(struct qlcnic_ms_reg_ctrl));
+	qlcnic_set_ms_controls(adapter, off, &ms);
 
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_OCM0, QLCNIC_ADDR_OCM0_MAX)) {
-		return qlcnic_pci_mem_access_direct(adapter,
-				off, data, 0);
-	}
+	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_OCM0, QLCNIC_ADDR_OCM0_MAX))
+		return qlcnic_pci_mem_access_direct(adapter, ms.ocm_window,
+			ms.off, data, 0);
 
-	return -EIO;
+	mutex_lock(&adapter->ahw->mem_lock);
 
-correct:
 	off8 = off & ~0xf;
 
-	mutex_lock(&adapter->ahw->mem_lock);
+	qlcnic_ind_wr(adapter, ms.low, off8);
+	qlcnic_ind_wr(adapter, ms.hi, 0);
 
-	writel(off8, (mem_crb + MIU_TEST_AGT_ADDR_LO));
-	writel(0, (mem_crb + MIU_TEST_AGT_ADDR_HI));
-	writel(TA_CTL_ENABLE, (mem_crb + TEST_AGT_CTRL));
-	writel((TA_CTL_START | TA_CTL_ENABLE), (mem_crb + TEST_AGT_CTRL));
+	qlcnic_ind_wr(adapter, ms.control, TA_CTL_ENABLE);
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_START_ENABLE);
 
 	for (j = 0; j < MAX_CTL_CHECK; j++) {
-		temp = readl(mem_crb + TEST_AGT_CTRL);
+		temp = qlcnic_ind_rd(adapter, ms.control);
 		if ((temp & TA_CTL_BUSY) == 0)
 			break;
 	}
@@ -1218,13 +1249,10 @@ correct:
 					"failed to read through agent\n");
 		ret = -EIO;
 	} else {
-		off8 = MIU_TEST_AGT_RDDATA_LO;
-		if (off & 0xf)
-			off8 = MIU_TEST_AGT_RDDATA_UPPER_LO;
 
-		temp = readl(mem_crb + off8 + 4);
+		temp = qlcnic_ind_rd(adapter, ms.rd[3]);
 		val = (u64)temp << 32;
-		val |= readl(mem_crb + off8);
+		val |= qlcnic_ind_rd(adapter, ms.rd[2]);
 		*data = val;
 		ret = 0;
 	}
@@ -1236,7 +1264,7 @@ correct:
 
 int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 {
-	int offset, board_type, magic;
+	int offset, board_type, magic, err;
 	struct pci_dev *pdev = adapter->pdev;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
@@ -1257,7 +1285,7 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 	ahw->board_type = board_type;
 
 	if (board_type == QLCNIC_BRDTYPE_P3P_4_GB_MM) {
-		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I);
+		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I, &err);
 		if ((gpio & 0x8000) == 0)
 			board_type = QLCNIC_BRDTYPE_P3P_10G_TP;
 	}
@@ -1296,11 +1324,12 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 int
 qlcnic_wol_supported(struct qlcnic_adapter *adapter)
 {
+	int err;
 	u32 wol_cfg;
 
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
 	if (wol_cfg & (1UL << adapter->portnum)) {
-		wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG);
+		wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
 		if (wol_cfg & (1 << adapter->portnum))
 			return 1;
 	}
@@ -1349,9 +1378,10 @@ void qlcnic_get_ocm_win(struct qlcnic_hardware_context *ahw)
 				PCIX_OCM_WINDOW_REG(ahw->pci_func)));
 }
 
-void qlcnic_82xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
+void qlcnic_read_crb(struct qlcnic_adapter *adapter, char *buf,
 	loff_t offset, size_t size)
 {
+	int err;
 	u32 data;
 	u64 qmdata;
 
@@ -1359,12 +1389,12 @@ void qlcnic_82xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
 		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
 		memcpy(buf, &qmdata, size);
 	} else {
-		data = QLCRD32(adapter, offset);
+		data = QLCRD32(adapter, offset, &err);
 		memcpy(buf, &data, size);
 	}
 }
 
-void qlcnic_82xx_write_crb(struct qlcnic_adapter *adapter, char *buf,
+void qlcnic_write_crb(struct qlcnic_adapter *adapter, char *buf,
 	loff_t offset, size_t size)
 {
 	u32 data;
@@ -1378,3 +1408,23 @@ void qlcnic_82xx_write_crb(struct qlcnic_adapter *adapter, char *buf,
 		QLCWR32(adapter, offset, data);
 	}
 }
+
+int qlcnic_api_lock(struct qlcnic_adapter *adapter)
+{
+	return qlcnic_pcie_sem_lock(adapter, 5, 0);
+}
+
+void qlcnic_api_unlock(struct qlcnic_adapter *adapter)
+{
+	qlcnic_pcie_sem_unlock(adapter, 5);
+}
+
+void qlcnic_add_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_create_diag_entries(adapter);
+}
+
+void qlcnic_remove_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_remove_diag_entries(adapter);
+}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index 82c466c..2f3966e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -3,18 +3,195 @@
 
 #include "qlcnic.h"
 
+#define MASK(n) ((1ULL<<(n))-1)
+#define OCM_WIN_P3P(addr) (addr & 0xffc0000)
+#define OCM_WIN_83XX(addr)	(addr & 0xFFE0000)
+
+#define GET_MEM_OFFS_2M(addr) (addr & MASK(18))
+#define GET_83XX_OCM_OFFSET(addr)	(addr & MASK(17))
+
+#define CRB_BLK(off)	((off >> 20) & 0x3f)
+#define CRB_SUBBLK(off)	((off >> 16) & 0xf)
+#define CRB_WINDOW_2M	(0x130060)
+#define CRB_HI(off)	((crb_hub_agt[CRB_BLK(off)] << 20) | ((off) & 0xf0000))
+#define CRB_INDIRECT_2M	(0x1e0000UL)
+
+
+
 /* List of PCI device IDs */
-#define PCI_DEVICE_ID_QLOGIC_QLE824X  0x8020
-#define QLCNIC_P3P_BAR0_LENGTH		0x00200000UL
+#define PCI_DEVICE_ID_QLOGIC_QLE824X	0x8020
+#define PCI_DEVICE_ID_QLOGIC_QLE834X	0x8030
+#define QLCNIC_82XX_BAR0_LENGTH	0x00200000UL
+#define QLCNIC_83XX_BAR0_LENGTH	0x4000
+
+#define QLCNIC_IS_83XX(adapter)	\
+	(((adapter)->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE834X) ? 1 : 0)
+
+#define QLCNIC_IS_82XX(adapter)	\
+	(((adapter)->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE824X) ? 1 : 0)
+
+/* Existing registers in 83xx and 82xx */
+enum qlcnic_regs {
+	QLCNIC_PEG_HALT_STATUS1 = 0,
+	QLCNIC_PEG_HALT_STATUS2,
+	QLCNIC_PEG_ALIVE_COUNTER,
+	QLCNIC_FLASH_LOCK_OWNER,
+	QLCNIC_FW_CAPABILITIES,
+	QLCNIC_CRB_DRV_ACTIVE,
+	QLCNIC_CRB_DEV_STATE,
+	QLCNIC_CRB_DRV_STATE,
+	QLCNIC_CRB_DRV_SCRATCH,
+	QLCNIC_CRB_DEV_PARTITION_INFO,
+	QLCNIC_CRB_DRV_IDC_VER,
+	QLCNIC_FW_VERSION_MAJOR,
+	QLCNIC_FW_VERSION_MINOR,
+	QLCNIC_FW_VERSION_SUB,
+	QLCNIC_CRB_DEV_NPAR_STATE,
+	QLCNIC_FW_IMG_VALID,
+	QLCNIC_CMDPEG_STATE,
+	QLCNIC_RCVPEG_STATE,
+	QLCNIC_ASIC_TEMP,
+	QLCNIC_FW_API,
+	QLCNIC_DRV_OP_MODE,
+	QLCNIC_FLASH_LOCK,
+	QLCNIC_FLASH_UNLOCK,
+};
+
+struct qlcnic_ms_reg_ctrl {
+	u32 ocm_window;
+	u32 control;
+	u32 hi;
+	u32 low;
+	u32 rd[4];
+	u32 wd[4];
+	u64 off;
+};
+
+/* Read from an address offset from BAR0, existing registers */
+#define QLCRD(a, addr)			\
+	readl(((a)->ahw->pci_base0) + ((a)->ahw->reg_tbl[addr]))
+/* Write to an address offset from BAR0, existing registers */
+#define QLCWR(a, addr, value)		\
+	writel(value, ((a)->ahw->pci_base0) + ((a)->ahw->reg_tbl[addr]))
+
+/* Read from a direct address offset from BAR0, additional registers */
+#define QLCRDX(ahw, addr)			\
+	readl(((ahw)->pci_base0) + ((ahw)->ext_reg_tbl[addr]))
+/* Write to a direct address offset from BAR0, additional registers */
+#define QLCWRX(ahw, addr, value)		\
+	writel(value, (((ahw)->pci_base0) + ((ahw)->ext_reg_tbl[addr])))
+
+#define QLCNIC_READ_LINK_SPEED(adapter, pcifn, err)\
+	QLCRD32(adapter, P3P_LINK_SPEED_REG(pcifn), err)
+
+/* Mailbox ownership */
+#define QLCNIC_GET_OWNER(val)	\
+	((val) & (BIT_0 | BIT_1))
+#define QLCNIC_SET_OWNER	1
+#define QLCNIC_CLR_OWNER	0
+#define QLCNIC_MBX_TIMEOUT	10000
+
+#define QLCNIC_CMD_CONFIGURE_IP_ADDR		0x1
+#define QLCNIC_CMD_CONFIG_INTRPT		0x2
+#define QLCNIC_CMD_CREATE_RX_CTX		0x7
+#define QLCNIC_CMD_DESTROY_RX_CTX		0x8
+#define QLCNIC_CMD_CREATE_TX_CTX		0x9
+#define QLCNIC_CMD_DESTROY_TX_CTX		0xa
+#define QLCNIC_CMD_CONFIGURE_LRO		0xC
+#define QLCNIC_CMD_CONFIGURE_MAC_LEARNING	0xD
+#define QLCNIC_CMD_GET_STATISTICS		0xF
+#define QLCNIC_CMD_INTRPT_TEST			0x11
+#define QLCNIC_CMD_SET_MTU			0x12
+#define QLCNIC_CMD_READ_PHY			0x13
+#define QLCNIC_CMD_WRITE_PHY			0x14
+#define QLCNIC_CMD_READ_HW_REG			0x15
+#define QLCNIC_CMD_GET_FLOW_CTL			0x16
+#define QLCNIC_CMD_SET_FLOW_CTL			0x17
+#define QLCNIC_CMD_READ_MAX_MTU			0x18
+#define QLCNIC_CMD_READ_MAX_LRO			0x19
+#define QLCNIC_CMD_MAC_ADDRESS			0x1f
+#define QLCNIC_CMD_GET_PCI_INFO			0x20
+#define QLCNIC_CMD_GET_NIC_INFO			0x21
+#define QLCNIC_CMD_SET_NIC_INFO			0x22
+#define QLCNIC_CMD_GET_ESWITCH_CAPABILITY	0x24
+#define QLCNIC_CMD_TOGGLE_ESWITCH		0x25
+#define QLCNIC_CMD_GET_ESWITCH_STATUS		0x26
+#define QLCNIC_CMD_SET_PORTMIRRORING		0x27
+#define QLCNIC_CMD_CONFIGURE_ESWITCH		0x28
+#define QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG	0x29
+#define QLCNIC_CMD_GET_ESWITCH_STATS		0x2a
+#define QLCNIC_CMD_CONFIG_PORT			0x2e
+#define QLCNIC_CMD_TEMP_SIZE			0x2f
+#define QLCNIC_CMD_GET_TEMP_HDR			0x30
+#define QLCNIC_CMD_GET_MAC_STATS		0x37
+#define QLCNIC_CMD_CONFIGURE_RSS		0x41
+#define QLCNIC_CMD_CONFIG_INTR_COAL		0x43
+#define QLCNIC_CMD_CONFIGURE_LED		0x44
+#define QLCNIC_CMD_CONFIG_MAC_VLAN		0x45
+#define QLCNIC_CMD_GET_LINK_EVENT		0x48
+#define QLCNIC_CMD_CONFIGURE_MAC_RX_MODE	0x49
+#define QLCNIC_CMD_CONFIGURE_HW_LRO		0x4A
+#define QLCNIC_CMD_INIT_NIC_FUNC		0x60
+#define QLCNIC_CMD_STOP_NIC_FUNC		0x61
+#define QLCNIC_CMD_IDC_ACK			0x63
+#define QLCNIC_CMD_SET_PORT_CONFIG		0x66
+#define QLCNIC_CMD_GET_PORT_CONFIG		0x67
+#define QLCNIC_CMD_GET_LINK_STATUS		0x68
+#define QLCNIC_CMD_SET_LED_CONFIG		0x69
+#define QLCNIC_CMD_GET_LED_CONFIG		0x6A
+
+#define QLC_TCP_HDR_SIZE            20
+#define QLC_TCP_TS_OPTION_SIZE      12
+#define QLC_TCP_TS_HDR_SIZE         (QLC_TCP_HDR_SIZE + QLC_TCP_TS_OPTION_SIZE)
+
+#define QLCNIC_INTRPT_INTX	1
+#define QLCNIC_INTRPT_MSIX	3
+#define QLCNIC_INTRPT_ADD	1
+#define QLCNIC_INTRPT_DEL	2
+
+#define QLCNIC_GET_CURRENT_MAC	1
+#define QLCNIC_SET_STATION_MAC	2
+#define QLCNIC_GET_DEFAULT_MAC	3
+#define QLCNIC_GET_FAC_DEF_MAC	4
+#define QLCNIC_SET_FAC_DEF_MAC	5
+
+#define QLCNIC_MBX_LINK_EVENT		0x8001
+#define QLCNIC_MBX_COMP_EVENT		0x8100
+#define QLCNIC_MBX_REQUEST_EVENT	0x8101
+#define QLCNIC_MBX_TIME_EXTEND_EVENT	0x8102
+#define QLCNIC_MBX_SFP_INSERT_EVENT	0x8130
+#define QLCNIC_MBX_SFP_REMOVE_EVENT	0x8131
+
+struct qlcnic_mailbox_metadata {
+	u32 cmd;
+	u32 in_args;
+	u32 out_args;
+};
 
 #define QLCNIC_BAR_LENGTH(dev_id, bar)			\
 do {							\
-	if (dev_id == PCI_DEVICE_ID_QLOGIC_QLE824X)\
-		*bar = QLCNIC_P3P_BAR0_LENGTH;		\
-	else						\
+	switch (dev_id) {				\
+	case PCI_DEVICE_ID_QLOGIC_QLE824X:		\
+		*bar = QLCNIC_82XX_BAR0_LENGTH;		\
+		break;					\
+	case PCI_DEVICE_ID_QLOGIC_QLE834X:		\
+		*bar = QLCNIC_83XX_BAR0_LENGTH;	\
+		break;					\
+	default:					\
 		*bar = 0;				\
+	}						\
 } while (0)
 
+/* Make a handle with reference handle (0:14) and RDS ring
+ * number (15).
+ */
+#define QLCNIC_MAKE_REF_HANDLE(adapter, handle, ring_id)		\
+	((adapter->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE834X) ?	\
+	((handle) | ((ring_id) << 15)) : handle)
+
+#define QLCNIC_FETCH_RING_ID(handle)			\
+	((handle) >> 63)
+
 #define QLCNIC_ENABLE_INTR(adapter, crb) {		\
 	writel(1, crb);					\
 	if (!QLCNIC_IS_MSI_FAMILY(adapter))		\
@@ -25,4 +202,28 @@ do {							\
 	writel(0, crb);					\
 }
 
+#define QLCNIC_MBX_RSP_OK	1
+#define QLCNIC_MBX_PORT_RSP_OK	0x1a
+
+#define QLCNIC_MBX_RSP(reg)\
+	LSW(reg)
+#define QLCNIC_MBX_NUM_REGS(reg)\
+	(MSW(reg) & 0x1FF)
+#define QLCNIC_MBX_STATUS(reg)	\
+	(((reg) >> 25) & 0x7F)
+
+/* Mailbox registers*/
+#define QLCNIC_MBX_HOST(ahw, i)	\
+	((ahw)->pci_base0 + ((i) * 4))
+#define QLCNIC_MBX_FW(ahw, i)	\
+	((ahw)->pci_base0 + 0x800 + ((i) * 4))
+
+#define QLCNIC_IS_TSO_CAPABLE(adapter)\
+	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
+
+#define QLCNIC_IS_VLAN_TX_CAPABLE(adapter) \
+	((QLCNIC_IS_82XX(adapter)) ?\
+	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX) :\
+	1)
+
 #endif				/* __QLCNIC_HDR_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 5a1704e..737adea 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -6,6 +6,7 @@
  */
 
 #include "qlcnic.h"
+#include "qlcnic_hw.h"
 
 struct crb_addr_pair {
 	u32 addr;
@@ -162,13 +163,12 @@ void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_recv_context *recv_ctx;
 	struct qlcnic_host_rds_ring *rds_ring;
-	struct qlcnic_host_tx_ring *tx_ring;
 	int ring;
 
 	recv_ctx = adapter->recv_ctx;
 
 	if (recv_ctx->rds_rings == NULL)
-		goto skip_rds;
+		return;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
@@ -176,16 +176,6 @@ void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter)
 		rds_ring->rx_buf_arr = NULL;
 	}
 	kfree(recv_ctx->rds_rings);
-
-skip_rds:
-	if (adapter->tx_ring == NULL)
-		return;
-
-	tx_ring = adapter->tx_ring;
-	vfree(tx_ring->cmd_buf_arr);
-	tx_ring->cmd_buf_arr = NULL;
-	kfree(adapter->tx_ring);
-	adapter->tx_ring = NULL;
 }
 
 int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
@@ -193,32 +183,12 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 	struct qlcnic_recv_context *recv_ctx;
 	struct qlcnic_host_rds_ring *rds_ring;
 	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_host_tx_ring *tx_ring;
 	struct qlcnic_rx_buffer *rx_buf;
 	int ring, i, size;
 
-	struct qlcnic_cmd_buffer *cmd_buf_arr;
 	struct net_device *netdev = adapter->netdev;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	size = sizeof(struct qlcnic_host_tx_ring);
-	tx_ring = kzalloc(size, GFP_KERNEL);
-	if (tx_ring == NULL) {
-		dev_err(&netdev->dev, "failed to allocate tx ring struct\n");
-		return -ENOMEM;
-	}
-	adapter->tx_ring = tx_ring;
-
-	tx_ring->num_desc = adapter->num_txd;
-	tx_ring->txq = netdev_get_tx_queue(netdev, 0);
-
-	cmd_buf_arr = vzalloc(TX_BUFF_RINGSIZE(tx_ring));
-	if (cmd_buf_arr == NULL) {
-		dev_err(&netdev->dev, "failed to allocate cmd buffer ring\n");
-		goto err_out;
-	}
-	tx_ring->cmd_buf_arr = cmd_buf_arr;
-
 	recv_ctx = adapter->recv_ctx;
 
 	size = adapter->max_rds_rings * sizeof(struct qlcnic_host_rds_ring);
@@ -250,12 +220,14 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 				rds_ring->dma_size + NET_IP_ALIGN;
 			break;
 		}
-		rds_ring->rx_buf_arr = vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
+		rds_ring->rx_buf_arr = (struct qlcnic_rx_buffer *)
+			vmalloc(RCV_BUFF_RINGSIZE(rds_ring));
 		if (rds_ring->rx_buf_arr == NULL) {
-			dev_err(&netdev->dev, "Failed to allocate "
-				"rx buffer ring %d\n", ring);
+			dev_err(&netdev->dev,
+				"Failed to allocate rx buffer ring %d\n", ring);
 			goto err_out;
 		}
+		memset(rds_ring->rx_buf_arr, 0, RCV_BUFF_RINGSIZE(rds_ring));
 		INIT_LIST_HEAD(&rds_ring->free_list);
 		/*
 		 * Now go through all of them, set reference handles
@@ -321,11 +293,12 @@ static int qlcnic_wait_rom_done(struct qlcnic_adapter *adapter)
 {
 	long timeout = 0;
 	long done = 0;
+	int err;
 
 	cond_resched();
 
 	while (done == 0) {
-		done = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_STATUS);
+		done = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_STATUS, &err);
 		done &= 2;
 		if (++timeout >= QLCNIC_MAX_ROM_WAIT_USEC) {
 			dev_err(&adapter->pdev->dev,
@@ -340,6 +313,8 @@ static int qlcnic_wait_rom_done(struct qlcnic_adapter *adapter)
 static int do_rom_fast_read(struct qlcnic_adapter *adapter,
 			    u32 addr, u32 *valp)
 {
+	int err;
+
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ADDRESS, addr);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ABYTE_CNT, 3);
@@ -353,7 +328,7 @@ static int do_rom_fast_read(struct qlcnic_adapter *adapter,
 	udelay(10);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 
-	*valp = QLCRD32(adapter, QLCNIC_ROMUSB_ROM_RDATA);
+	*valp = QLCRD32(adapter, QLCNIC_ROMUSB_ROM_RDATA, &err);
 	return 0;
 }
 
@@ -405,15 +380,15 @@ int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, u32 addr, u32 *valp)
 
 int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 {
-	int addr, val;
+	int addr, val, err;
 	int i, n, init_delay;
 	struct crb_addr_pair *buf;
 	unsigned offset;
 	u32 off;
 	struct pci_dev *pdev = adapter->pdev;
 
-	QLCWR32(adapter, CRB_CMDPEG_STATE, 0);
-	QLCWR32(adapter, CRB_RCVPEG_STATE, 0);
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, 0);
+	QLCWR(adapter, QLCNIC_RCVPEG_STATE, 0);
 
 	/* Halt all the indiviual PEGs and other blocks */
 	/* disable all I2Q */
@@ -438,7 +413,7 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, QLCNIC_CRB_NIU + 0xb0000, 0x00);
 
 	/* halt sre */
-	val = QLCRD32(adapter, QLCNIC_CRB_SRE + 0x1000);
+	val = QLCRD32(adapter, QLCNIC_CRB_SRE + 0x1000, &err);
 	QLCWR32(adapter, QLCNIC_CRB_SRE + 0x1000, val & (~(0x1)));
 
 	/* halt epg */
@@ -560,8 +535,8 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0xc, 0);
 	msleep(1);
 
-	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
-	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
+	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
+	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
 
 	return 0;
 }
@@ -572,7 +547,7 @@ static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
 	int retries = QLCNIC_CMDPEG_CHECK_RETRY_COUNT;
 
 	do {
-		val = QLCRD32(adapter, CRB_CMDPEG_STATE);
+		val = QLCRD(adapter, QLCNIC_CMDPEG_STATE);
 
 		switch (val) {
 		case PHAN_INITIALIZE_COMPLETE:
@@ -588,7 +563,7 @@ static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
 
 	} while (--retries);
 
-	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
 
 out_err:
 	dev_err(&adapter->pdev->dev, "Command Peg initialization not "
@@ -603,7 +578,7 @@ qlcnic_receive_peg_ready(struct qlcnic_adapter *adapter)
 	int retries = QLCNIC_RCVPEG_CHECK_RETRY_COUNT;
 
 	do {
-		val = QLCRD32(adapter, CRB_RCVPEG_STATE);
+		val = QLCRD(adapter, QLCNIC_RCVPEG_STATE);
 
 		if (val == PHAN_PEG_RCV_INITIALIZED)
 			return 0;
@@ -634,7 +609,7 @@ qlcnic_check_fw_status(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
-	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
 	return err;
 }
@@ -645,7 +620,7 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 	int timeo;
 	u32 val;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
+	val = QLCRD(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
 	val = QLC_DEV_GET_DRV(val, adapter->portnum);
 	if ((val & 0x3) != QLCNIC_TYPE_NIC) {
 		dev_err(&adapter->pdev->dev,
@@ -685,11 +660,12 @@ static int qlcnic_get_flt_entry(struct qlcnic_adapter *adapter, u8 region,
 	}
 
 	entry_size = flt_hdr.len - sizeof(struct qlcnic_flt_header);
-	flt_entry = (struct qlcnic_flt_entry *)vzalloc(entry_size);
+	flt_entry = vmalloc(entry_size);
 	if (flt_entry == NULL) {
 		dev_warn(&adapter->pdev->dev, "error allocating memory\n");
 		return -EIO;
 	}
+	memset(flt_entry, 0, entry_size);
 
 	ret = qlcnic_rom_fast_read_words(adapter, QLCNIC_FLT_LOCATION +
 					 sizeof(struct qlcnic_flt_header),
@@ -758,10 +734,11 @@ qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter)
 static int
 qlcnic_has_mn(struct qlcnic_adapter *adapter)
 {
+	int err;
 	u32 capability;
 	capability = 0;
 
-	capability = QLCRD32(adapter, QLCNIC_PEG_TUNE_CAPABILITY);
+	capability = QLCRD32(adapter, QLCNIC_PEG_TUNE_CAPABILITY, &err);
 	if (capability & QLCNIC_PEG_TUNE_MN_PRESENT)
 		return 1;
 
@@ -1084,11 +1061,11 @@ qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter)
 	u32 heartbeat, ret = -EIO;
 	int retries = QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT;
 
-	adapter->heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+	adapter->heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 
 	do {
 		msleep(QLCNIC_HEARTBEAT_PERIOD_MSECS);
-		heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+		heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 		if (heartbeat != adapter->heartbeat) {
 			ret = QLCNIC_RCODE_SUCCESS;
 			break;
@@ -1258,7 +1235,7 @@ qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
 		return -EINVAL;
 	}
 
-	QLCWR32(adapter, QLCNIC_CAM_RAM(0x1fc), QLCNIC_BDINFO_MAGIC);
+	QLCWR(adapter, QLCNIC_FW_IMG_VALID, QLCNIC_BDINFO_MAGIC);
 	return 0;
 }
 
@@ -1314,6 +1291,7 @@ next:
 void
 qlcnic_release_firmware(struct qlcnic_adapter *adapter)
 {
-	release_firmware(adapter->fw);
+	if (adapter->fw)
+		release_firmware(adapter->fw);
 	adapter->fw = NULL;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 03b5e3e..1c384f1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -6,17 +6,14 @@
 #include "qlcnic.h"
 #include "qlcnic_hw.h"
 
-static void
-qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
-	struct qlcnic_host_rds_ring *rds_ring);
-
-static void qlcnic_change_filter(struct qlcnic_adapter *adapter,
-		u64 uaddr, __le16 vlan_id, struct qlcnic_host_tx_ring *tx_ring)
+void qlcnic_change_filter(struct qlcnic_adapter *adapter,
+		u64 *uaddr, __le16 vlan_id)
 {
 	struct cmd_desc_type0 *hwdesc;
 	struct qlcnic_nic_req *req;
 	struct qlcnic_mac_req *mac_req;
 	struct qlcnic_vlan_req *vlan_req;
+	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
 	u32 producer;
 	u64 word;
 
@@ -54,6 +51,7 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	struct qlcnic_filter *fil, *tmp_fil;
 	struct hlist_node *tmp_hnode, *n;
 	struct hlist_head *head;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u64 src_addr = 0;
 	__le16 vlan_id = 0;
 	u8 hindex;
@@ -77,8 +75,8 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
 
 			if (jiffies >
 			    (QLCNIC_READD_AGE * HZ + tmp_fil->ftime))
-				qlcnic_change_filter(adapter, src_addr, vlan_id,
-								tx_ring);
+				ahw->hw_ops->change_l2_filter(adapter,
+							&src_addr, vlan_id);
 			tmp_fil->ftime = jiffies;
 			return;
 		}
@@ -88,7 +86,7 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	if (!fil)
 		return;
 
-	qlcnic_change_filter(adapter, src_addr, vlan_id, tx_ring);
+	ahw->hw_ops->change_l2_filter(adapter, &src_addr, vlan_id);
 
 	fil->ftime = jiffies;
 	fil->vlan_id = vlan_id;
@@ -435,7 +433,6 @@ drop_packet:
 void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup)
 {
 	struct net_device *netdev = adapter->netdev;
-
 	if (adapter->ahw->linkup && !linkup) {
 		netdev_info(netdev, "NIC Link is down\n");
 		adapter->ahw->linkup = 0;
@@ -453,7 +450,8 @@ void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup)
 	}
 }
 
-static int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter)
+int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter,
+		struct qlcnic_host_tx_ring *tx_ring, int budget)
 {
 	u32 sw_consumer, hw_consumer;
 	int count = 0, i;
@@ -462,7 +460,6 @@ static int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct qlcnic_skb_frag *frag;
 	int done;
-	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
 
 	if (!spin_trylock(&adapter->tx_clean_lock))
 		return 1;
@@ -490,7 +487,7 @@ static int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter)
 		}
 
 		sw_consumer = get_next_index(sw_consumer, tx_ring->num_desc);
-		if (++count >= MAX_STATUS_HANDLE)
+		if (++count >= budget)
 			break;
 	}
 
@@ -537,7 +534,8 @@ int qlcnic_poll(struct napi_struct *napi, int budget)
 	int tx_complete;
 	int work_done;
 
-	tx_complete = qlcnic_process_cmd_ring(adapter);
+	tx_complete = qlcnic_process_cmd_ring(adapter, adapter->tx_ring,
+						budget);
 
 	work_done = qlcnic_process_rcv_ring(sds_ring, budget);
 
@@ -569,7 +567,7 @@ int qlcnic_rx_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-static void
+void
 qlcnic_handle_linkevent(struct qlcnic_adapter *adapter,
 				struct qlcnic_fw_msg *msg)
 {
@@ -581,7 +579,6 @@ qlcnic_handle_linkevent(struct qlcnic_adapter *adapter,
 	struct net_device *netdev = adapter->netdev;
 
 	adapter->ahw->has_link_events = 1;
-
 	cable_OUI = msg->body[1] & 0xffffffff;
 	cable_len = (msg->body[1] >> 32) & 0xffff;
 	link_speed = (msg->body[1] >> 48) & 0xffff;
@@ -616,7 +613,7 @@ qlcnic_handle_linkevent(struct qlcnic_adapter *adapter,
 	adapter->ahw->link_speed = link_speed;
 }
 
-static void
+void
 qlcnic_handle_fw_message(int desc_cnt, int index,
 		struct qlcnic_host_sds_ring *sds_ring)
 {
@@ -638,7 +635,6 @@ qlcnic_handle_fw_message(int desc_cnt, int index,
 	adapter = sds_ring->adapter;
 	dev = &adapter->pdev->dev;
 	opcode = qlcnic_get_nic_msg_opcode(msg.body[0]);
-
 	switch (opcode) {
 	case QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE:
 		qlcnic_handle_linkevent(adapter, &msg);
@@ -670,7 +666,7 @@ qlcnic_handle_fw_message(int desc_cnt, int index,
 	}
 }
 
-static int
+int
 qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_rds_ring *rds_ring,
 		struct qlcnic_rx_buffer *buffer)
@@ -702,7 +698,7 @@ qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
+struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_rds_ring *rds_ring, u16 index, u16 cksum)
 {
 	struct qlcnic_rx_buffer *buffer;
@@ -735,7 +731,7 @@ static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 	return skb;
 }
 
-static inline int
+inline int
 qlcnic_check_rx_tagging(struct qlcnic_adapter *adapter, struct sk_buff *skb,
 			u16 *vlan_tag)
 {
@@ -819,10 +815,6 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 	return buffer;
 }
 
-#define QLC_TCP_HDR_SIZE            20
-#define QLC_TCP_TS_OPTION_SIZE      12
-#define QLC_TCP_TS_HDR_SIZE         (QLC_TCP_HDR_SIZE + QLC_TCP_TS_OPTION_SIZE)
-
 static struct qlcnic_rx_buffer *
 qlcnic_process_lro(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_sds_ring *sds_ring,
@@ -913,7 +905,8 @@ qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max)
 	u64 sts_data0, sts_data1;
 
 	int count = 0;
-	int opcode, ring, desc_cnt;
+	int opcode, desc_cnt;
+	u8 ring;
 	u32 consumer = sds_ring->consumer;
 
 	while (count < max) {
@@ -979,7 +972,6 @@ skip:
 			spin_unlock(&rds_ring->lock);
 		}
 
-		qlcnic_post_rx_buffers_nodb(adapter, rds_ring);
 	}
 
 	if (count) {
@@ -992,7 +984,7 @@ skip:
 
 void
 qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
-	struct qlcnic_host_rds_ring *rds_ring)
+	struct qlcnic_host_rds_ring *rds_ring, u8 ring_id)
 {
 	struct rcv_desc *pdesc;
 	struct qlcnic_rx_buffer *buffer;
@@ -1018,9 +1010,9 @@ qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
 		/* make a rcv descriptor  */
 		pdesc = &rds_ring->desc_head[producer];
 		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
-		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
+		pdesc->reference_handle = cpu_to_le16(QLCNIC_MAKE_REF_HANDLE(
+			adapter, buffer->ref_handle, ring_id));
 		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
-
 		producer = get_next_index(producer, rds_ring->num_desc);
 	}
 
@@ -1031,9 +1023,9 @@ qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
 	}
 }
 
-static void
+void
 qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_rds_ring *rds_ring)
+		struct qlcnic_host_rds_ring *rds_ring, u8 ring_id)
 {
 	struct rcv_desc *pdesc;
 	struct qlcnic_rx_buffer *buffer;
@@ -1061,10 +1053,10 @@ qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
 
 		/* make a rcv descriptor  */
 		pdesc = &rds_ring->desc_head[producer];
-		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
+		pdesc->reference_handle = cpu_to_le16(QLCNIC_MAKE_REF_HANDLE(
+			adapter, buffer->ref_handle, ring_id));
 		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
 		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
-
 		producer = get_next_index(producer, rds_ring->num_desc);
 	}
 
@@ -1076,7 +1068,7 @@ qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
 	spin_unlock(&rds_ring->lock);
 }
 
-static void dump_skb(struct sk_buff *skb, struct qlcnic_adapter *adapter)
+void dump_skb(struct sk_buff *skb, struct qlcnic_adapter *adapter)
 {
 	int i;
 	unsigned char *data = skb->data;
@@ -1172,24 +1164,3 @@ qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
 	sds_ring->consumer = consumer;
 	writel(consumer, sds_ring->crb_sts_consumer);
 }
-
-void
-qlcnic_fetch_mac(struct qlcnic_adapter *adapter, u32 off1, u32 off2,
-			u8 alt_mac, u8 *mac)
-{
-	u32 mac_low, mac_high;
-	int i;
-
-	mac_low = off1;
-	mac_high = off2;
-
-	if (alt_mac) {
-		mac_low |= (mac_low >> 16) | (mac_high << 16);
-		mac_high >>= 16;
-	}
-
-	for (i = 0; i < 2; i++)
-		mac[i] = (u8)(mac_high >> ((1 - i) * 8));
-	for (i = 2; i < 6; i++)
-		mac[i] = (u8)(mac_low >> ((5 - i) * 8));
-}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 56c03f5..829dfa5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2,10 +2,15 @@
  * QLogic qlcnic NIC Driver
  * Copyright (c)  2009-2010 QLogic Corporation
  *
+ * PCI searching functions pci_get_domain_bus_and_slot & pci_channel_offline
+ * Copyright (C) 1993 -- 1997 Drew Eckhardt, Frederic Potter,
+ *					David Mosberger-Tang
+ * Copyright (C) 1997 -- 2000 Martin Mares <mj@ucw.cz>
+ * Copyright (C) 2003 -- 2004 Greg Kroah-Hartman <greg@kroah.com>.
+ *
  * See LICENSE.qlcnic for copyright and licensing details.
  */
 
-#include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 
@@ -14,6 +19,7 @@
 
 #include <linux/swab.h>
 #include <linux/dma-mapping.h>
+#include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <linux/ipv6.h>
 #include <linux/inetdevice.h>
@@ -34,23 +40,23 @@ static int qlcnic_mac_learn;
 module_param(qlcnic_mac_learn, int, 0444);
 MODULE_PARM_DESC(qlcnic_mac_learn, "Mac Filter (0=disabled, 1=enabled)");
 
-static int use_msi = 1;
+int use_msi = 1;
 module_param(use_msi, int, 0444);
 MODULE_PARM_DESC(use_msi, "MSI interrupt (0=disabled, 1=enabled");
 
-static int use_msi_x = 1;
+int use_msi_x = 1;
 module_param(use_msi_x, int, 0444);
 MODULE_PARM_DESC(use_msi_x, "MSI-X interrupt (0=disabled, 1=enabled");
 
-static int auto_fw_reset = 1;
+int auto_fw_reset = 1;
 module_param(auto_fw_reset, int, 0644);
 MODULE_PARM_DESC(auto_fw_reset, "Auto firmware reset (0=disabled, 1=enabled");
 
-static int load_fw_file;
+int load_fw_file;
 module_param(load_fw_file, int, 0444);
 MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file");
 
-static int qlcnic_config_npars;
+int qlcnic_config_npars;
 module_param(qlcnic_config_npars, int, 0444);
 MODULE_PARM_DESC(qlcnic_config_npars, "Configure NPARs (0=disabled, 1=enabled");
 
@@ -63,9 +69,6 @@ static void qlcnic_tx_timeout(struct net_device *netdev);
 static void qlcnic_attach_work(struct work_struct *work);
 static void qlcnic_fwinit_work(struct work_struct *work);
 static void qlcnic_fw_poll_work(struct work_struct *work);
-static void qlcnic_schedule_work(struct qlcnic_adapter *adapter,
-		work_func_t func, int delay);
-static void qlcnic_cancel_fw_work(struct qlcnic_adapter *adapter);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void qlcnic_poll_controller(struct net_device *netdev);
 #endif
@@ -78,9 +81,10 @@ static irqreturn_t qlcnic_tmp_intr(int irq, void *data);
 static irqreturn_t qlcnic_intr(int irq, void *data);
 static irqreturn_t qlcnic_msi_intr(int irq, void *data);
 static irqreturn_t qlcnic_msix_intr(int irq, void *data);
+static irqreturn_t qlcnic_msix_tx_intr(int irq, void *data);
+static irqreturn_t qlcnic_clear_legacy_intr(struct qlcnic_adapter *);
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev);
-static void qlcnic_restore_indev_addr(struct net_device *dev, unsigned long);
 static int qlcnic_start_firmware(struct qlcnic_adapter *);
 
 static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter);
@@ -90,9 +94,6 @@ static int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
 static int qlcnicvf_start_firmware(struct qlcnic_adapter *);
 static void qlcnic_set_netdev_features(struct qlcnic_adapter *,
 				struct qlcnic_esw_func_cfg *);
-static int qlcnic_vlan_rx_add(struct net_device *, u16);
-static int qlcnic_vlan_rx_del(struct net_device *, u16);
-
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
@@ -100,6 +101,7 @@ static int qlcnic_vlan_rx_del(struct net_device *, u16);
 
 static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE824X),
+	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE834X),
 	{0,}
 };
 
@@ -120,10 +122,60 @@ static const u32 msi_tgt_status[8] = {
 	ISR_INT_TARGET_STATUS_F6, ISR_INT_TARGET_STATUS_F7
 };
 
+static const u32 qlcnic_reg_tbl[] = {
+	0x1B20A8, /* PEG_HALT_STAT1 */
+	0x1B20AC, /* PEG_HALT_STAT2 */
+	0x1B20B0, /* FW_HEARTBEAT */
+	0x1B2100, /* LOCK ID */
+	0x1B2128, /* FW_CAPABILITIES */
+	0x1B2138, /* drv active */
+	0x1B2140, /* dev state */
+	0x1B2144, /* drv state */
+	0x1B2148, /* drv scratch */
+	0x1B214C, /* dev partition info */
+	0x1B2174, /* drv idc ver */
+	0x1B2150, /* fw version major */
+	0x1B2154, /* fw version minor */
+	0x1B2158, /* fw version sub */
+	0x1B019C, /* npar state */
+	0x1B21FC, /* FW_IMG_VALID */
+	0x1B2250, /* CMD_PEG_STATE */
+	0x1B233C, /* RCV_PEG_STATE */
+	0x1B23B4, /* ASIC TEMP */
+	0x1B216C, /* FW api */
+	0x1B2170, /* drv op mode */
+	0x13C010, /* flash lock */
+	0x13C014, /* flash unlock */
+};
+
+static const struct qlcnic_brdinfo qlcnic_boards[] = {
+	{0x1077, 0x8020, 0x1077, 0x203,
+		"8200 Series Single Port 10GbE Converged Network Adapter "
+		"(TCP/IP Networking)"},
+	{0x1077, 0x8020, 0x1077, 0x207,
+		"8200 Series Dual Port 10GbE Converged Network Adapter "
+		"(TCP/IP Networking)"},
+	{0x1077, 0x8020, 0x1077, 0x20b,
+		"3200 Series Dual Port 10Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x20c,
+		"3200 Series Quad Port 1Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x20f,
+		"3200 Series Single Port 10Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x103c, 0x3733,
+		"NC523SFP 10Gb 2-port Server Adapter"},
+	{0x1077, 0x8020, 0x103c, 0x3346,
+		"CN1000Q Dual Port Converged Network Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x210,
+		"QME8242-k 10GbE Dual Port Mezzanine Card"},
+	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
+};
+
+#define NUM_SUPPORTED_BOARDS ARRAY_SIZE(qlcnic_boards)
+
 static const
 struct qlcnic_legacy_intr_set legacy_intr[] = QLCNIC_LEGACY_INTR_CONFIG;
 
-static int
+int
 qlcnic_alloc_sds_rings(struct qlcnic_recv_context *recv_ctx, int count)
 {
 	int size = sizeof(struct qlcnic_host_sds_ring) * count;
@@ -133,7 +185,7 @@ qlcnic_alloc_sds_rings(struct qlcnic_recv_context *recv_ctx, int count)
 	return recv_ctx->sds_rings == NULL;
 }
 
-static void
+void
 qlcnic_free_sds_rings(struct qlcnic_recv_context *recv_ctx)
 {
 	if (recv_ctx->sds_rings != NULL)
@@ -142,6 +194,65 @@ qlcnic_free_sds_rings(struct qlcnic_recv_context *recv_ctx)
 	recv_ctx->sds_rings = NULL;
 }
 
+static void
+qlcnic_free_tx_rings(struct qlcnic_adapter *adapter)
+{
+	int ring;
+	struct qlcnic_host_tx_ring *tx_ring;
+
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		tx_ring = &adapter->tx_ring[ring];
+		if (tx_ring && tx_ring->cmd_buf_arr != NULL) {
+			vfree(tx_ring->cmd_buf_arr);
+			tx_ring->cmd_buf_arr = NULL;
+		}
+	}
+	if (adapter->tx_ring != NULL)
+		kfree(adapter->tx_ring);
+}
+
+int
+qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter, struct net_device *netdev)
+{
+	int ring, size;
+	struct qlcnic_host_tx_ring *tx_ring;
+	struct qlcnic_cmd_buffer *cmd_buf_arr;
+
+	size = adapter->max_drv_tx_rings * sizeof(struct qlcnic_host_tx_ring);
+	tx_ring = kzalloc(size, GFP_KERNEL);
+	if (tx_ring == NULL) {
+		dev_err(&netdev->dev, "failed to allocate tx rings\n");
+		return -ENOMEM;
+	}
+	adapter->tx_ring = tx_ring;
+
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		tx_ring = &adapter->tx_ring[ring];
+		tx_ring->num_desc = adapter->num_txd;
+		tx_ring->txq = netdev_get_tx_queue(netdev, ring);
+		cmd_buf_arr = vzalloc(TX_BUFF_RINGSIZE(tx_ring));
+		if (cmd_buf_arr == NULL) {
+			dev_err(&netdev->dev,
+				 "failed to allocate cmd buffer ring\n");
+			qlcnic_free_tx_rings(adapter);
+			return -ENOMEM;
+		}
+		memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(tx_ring));
+		tx_ring->cmd_buf_arr = cmd_buf_arr;
+	}
+
+	if (QLCNIC_IS_83XX(adapter)) {
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+			tx_ring = &adapter->tx_ring[ring];
+			tx_ring->adapter = adapter;
+			if (adapter->flags & QLCNIC_MSIX_ENABLED)
+				tx_ring->irq = adapter->msix_entries[adapter->
+					max_sds_rings + ring].vector;
+		}
+	}
+	return 0;
+}
+
 static int
 qlcnic_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
@@ -154,13 +265,17 @@ qlcnic_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
-
 		if (ring == adapter->max_sds_rings - 1)
 			netif_napi_add(netdev, &sds_ring->napi, qlcnic_poll,
-				QLCNIC_NETDEV_WEIGHT/adapter->max_sds_rings);
+				 QLCNIC_NETDEV_WEIGHT/adapter->max_sds_rings);
 		else
-			netif_napi_add(netdev, &sds_ring->napi,
-				qlcnic_rx_poll, QLCNIC_NETDEV_WEIGHT*2);
+			netif_napi_add(netdev, &sds_ring->napi, qlcnic_rx_poll,
+				QLCNIC_NETDEV_WEIGHT*2);
+	}
+
+	if (qlcnic_alloc_tx_rings(adapter, netdev)) {
+		qlcnic_free_sds_rings(recv_ctx);
+		return -ENOMEM;
 	}
 
 	return 0;
@@ -172,6 +287,7 @@ qlcnic_napi_del(struct qlcnic_adapter *adapter)
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct qlcnic_host_tx_ring *tx_ring;
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
@@ -179,6 +295,16 @@ qlcnic_napi_del(struct qlcnic_adapter *adapter)
 	}
 
 	qlcnic_free_sds_rings(adapter->recv_ctx);
+
+	if (QLCNIC_IS_83XX(adapter) &&
+			 (adapter->flags & QLCNIC_MSIX_ENABLED)) {
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+			tx_ring = &adapter->tx_ring[ring];
+			netif_napi_del(&tx_ring->napi);
+		}
+	}
+
+	qlcnic_free_tx_rings(adapter);
 }
 
 static void
@@ -248,11 +374,11 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 		return -EOPNOTSUPP;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
+		return -EINVAL;
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 		netif_device_detach(netdev);
-		qlcnic_napi_disable(adapter);
+		adapter->ahw->hw_ops->napi_disable(adapter);
 	}
 
 	memcpy(adapter->mac_addr, addr->sa_data, netdev->addr_len);
@@ -261,11 +387,38 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 		netif_device_attach(netdev);
-		qlcnic_napi_enable(adapter);
+		adapter->ahw->hw_ops->napi_enable(adapter);
 	}
 	return 0;
 }
 
+static int
+qlcnic_vlan_rx_add(struct net_device *netdev, u16 vid)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	set_bit(vid, adapter->vlans);
+	return 0;
+}
+
+static int
+qlcnic_vlan_rx_del(struct net_device *netdev, u16 vid)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+
+	qlcnic_restore_indev_addr(netdev, NETDEV_DOWN);
+	clear_bit(vid, adapter->vlans);
+	return 0;
+}
+
+static void
+qlcnic_cancel_idc_work(struct qlcnic_adapter *adapter)
+{
+	while (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+		usleep_range(10000, 11000);
+
+	cancel_delayed_work_sync(&adapter->fw_work);
+}
+
 static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_open	   = qlcnic_open,
 	.ndo_stop	   = qlcnic_close,
@@ -278,41 +431,65 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_fix_features  = qlcnic_fix_features,
 	.ndo_set_features  = qlcnic_set_features,
 	.ndo_tx_timeout	   = qlcnic_tx_timeout,
-	.ndo_vlan_rx_add_vid	= qlcnic_vlan_rx_add,
-	.ndo_vlan_rx_kill_vid	= qlcnic_vlan_rx_del,
+	.ndo_vlan_rx_add_vid    = qlcnic_vlan_rx_add,
+	.ndo_vlan_rx_kill_vid   = qlcnic_vlan_rx_del,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = qlcnic_poll_controller,
 #endif
 };
 
-static const struct net_device_ops qlcnic_netdev_failed_ops = {
-	.ndo_open	   = qlcnic_open,
-};
-
 static struct qlcnic_nic_template qlcnic_ops = {
 	.config_bridged_mode = qlcnic_config_bridged_mode,
 	.config_led = qlcnic_config_led,
-	.start_firmware = qlcnic_start_firmware
+	.start_firmware = qlcnic_start_firmware,
+	.request_reset = qlcnic_dev_request_reset,
+	.cancel_idc_work = qlcnic_cancel_idc_work,
+	.napi_add = qlcnic_napi_add,
+	.config_ipaddr = qlcnic_config_ipaddr,
+	.clear_legacy_intr = qlcnic_clear_legacy_intr,
 };
 
-static struct qlcnic_nic_template qlcnic_vf_ops = {
+struct qlcnic_nic_template qlcnic_vf_ops = {
 	.config_bridged_mode = qlcnicvf_config_bridged_mode,
 	.config_led = qlcnicvf_config_led,
 	.start_firmware = qlcnicvf_start_firmware
 };
 
-static struct qlcnic_hardware_ops qlcnic_82xx_ops = {
-	.read_crb = qlcnic_82xx_read_crb,
-	.write_crb = qlcnic_82xx_write_crb,
+static struct qlcnic_hardware_ops qlcnic_hw_ops = {
+	.read_crb = qlcnic_read_crb,
+	.write_crb = qlcnic_write_crb,
 	.rdreg = qlcnic_hw_read_wx_2M,
 	.wrtreg = qlcnic_hw_write_wx_2M,
 	.get_mac_address = qlcnic_get_mac_address,
 	.setup_intr = qlcnic_setup_intr,
+	.alloc_mbx_args = qlcnic_alloc_mbx_args,
 	.mbx_cmd = qlcnic_issue_cmd,
 	.get_func_no = qlcnic_get_func_no,
+	.api_lock = qlcnic_api_lock,
+	.api_unlock = qlcnic_api_unlock,
+	.add_sysfs = qlcnic_add_sysfs,
+	.remove_sysfs = qlcnic_remove_sysfs,
+	.process_lb_rcv_ring_diag = qlcnic_process_rcv_ring_diag,
+	.create_rx_ctx = qlcnic_fw_cmd_create_rx_ctx,
+	.create_tx_ctx = qlcnic_fw_cmd_create_tx_ctx,
+	.setup_link_event = qlcnic_linkevent_request,
+	.get_nic_info = qlcnic_get_nic_info,
+	.get_pci_info = qlcnic_get_pci_info,
+	.set_nic_info = qlcnic_set_nic_info,
+	.change_macvlan = qlcnic_sre_macaddr_change,
+	.napi_enable = qlcnic_napi_enable,
+	.napi_disable = qlcnic_napi_disable,
+	.config_intr_coal = qlcnic_config_intr_coalesce,
+	.config_rss = qlcnic_config_rss,
+	.config_hw_lro = qlcnic_config_hw_lro,
+	.config_loopback = qlcnic_set_lb_mode,
+	.clear_loopback = qlcnic_clear_lb_mode,
+	.config_promisc_mode = qlcnic_nic_set_promisc,
+	.change_l2_filter = qlcnic_change_filter,
+	.get_board_info = qlcnic_get_board_info,
 };
 
-static int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
+int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int err = -1, i;
@@ -333,24 +510,34 @@ static int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
  enable_msix:
 		for (i = 0; i < num_msix; i++)
 			adapter->msix_entries[i].entry = i;
-
 		err = pci_enable_msix(pdev, adapter->msix_entries, num_msix);
 		if (err == 0) {
 			adapter->flags |= QLCNIC_MSIX_ENABLED;
-			adapter->max_sds_rings = num_msix;
-
+			if (QLCNIC_IS_83XX(adapter)) {
+				adapter->ahw->num_msix = num_msix;
+				/* subtract 2 as 2 vectors are required for
+				 mail box and tx ring */
+				adapter->max_sds_rings = num_msix - 2;
+			} else
+				adapter->max_sds_rings = num_msix;
 			dev_info(&pdev->dev, "using msi-x interrupts\n");
 			return err;
 		} else if (err > 0) {
+			dev_info(&pdev->dev, "Didn't get %d vectors\n",
+					num_msix);
 			num_msix = rounddown_pow_of_two(err);
 			if (num_msix) {
-				dev_info(&pdev->dev,
-				"Can't get %d vectors,trying %d vectors\n",
-								err, num_msix);
+				if (QLCNIC_IS_83XX(adapter))
+					num_msix += 1;
+				dev_info(&pdev->dev, "Trying %d vectors\n",
+					num_msix);
 				goto enable_msix;
 			}
-		}
+		} else
+			dev_info(&pdev->dev, "Failed to get %d vectors\n",
+				num_msix);
 	}
+
 	return err;
 }
 
@@ -379,18 +566,22 @@ static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 
 	adapter->crb_int_state_reg = qlcnic_get_ioaddr(adapter->ahw,
 			ISR_INT_STATE_REG);
+
 	dev_info(&pdev->dev, "using legacy interrupts\n");
 	adapter->msix_entries[0].vector = pdev->irq;
 }
 
 int
-qlcnic_setup_intr(struct qlcnic_adapter *adapter)
+qlcnic_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
 {
 	int num_msix, err;
 
+	if (!num_intr)
+		num_intr = QLCNIC_DEF_NUM_STS_DESC_RINGS;
+
 	if (adapter->ahw->msix_supported)
 		num_msix = rounddown_pow_of_two(min_t(int, num_online_cpus(),
-				QLCNIC_DEF_NUM_STS_DESC_RINGS));
+				num_intr));
 	else
 		num_msix = 1;
 
@@ -409,6 +600,13 @@ qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 		pci_disable_msix(adapter->pdev);
 	if (adapter->flags & QLCNIC_MSI_ENABLED)
 		pci_disable_msi(adapter->pdev);
+	kfree(adapter->msix_entries);
+	adapter->msix_entries = NULL;
+
+	if (adapter->ahw->intr_tbl) {
+		vfree(adapter->ahw->intr_tbl);
+		adapter->ahw->intr_tbl = NULL;
+	}
 }
 
 static void
@@ -418,19 +616,27 @@ qlcnic_cleanup_pci_map(struct qlcnic_hardware_context *ahw)
 		iounmap(ahw->pci_base0);
 }
 
-static int
+int
 qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_pci_info *pci_info;
-	int i, ret = 0;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	int i, ret = 0, j = 0;
+	u16 act_pci_func;
 	u8 pfn;
 
 	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
 	if (!pci_info)
 		return -ENOMEM;
 
+	ret = ahw->hw_ops->get_pci_info(adapter, pci_info);
+	if (ret)
+		goto err_pci_info;
+
+	act_pci_func = adapter->ahw->act_pci_func;
+
 	adapter->npars = kzalloc(sizeof(struct qlcnic_npar_info) *
-				QLCNIC_MAX_PCI_FUNC, GFP_KERNEL);
+				act_pci_func, GFP_KERNEL);
 	if (!adapter->npars) {
 		ret = -ENOMEM;
 		goto err_pci_info;
@@ -443,21 +649,25 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 		goto err_npars;
 	}
 
-	ret = qlcnic_get_pci_info(adapter, pci_info);
-	if (ret)
-		goto err_eswitch;
-
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
 		pfn = pci_info[i].id;
-		if (pfn >= QLCNIC_MAX_PCI_FUNC) {
+
+		if (pfn > QLCNIC_MAX_PCI_FUNC) {
 			ret = QL_STATUS_INVALID_PARAM;
 			goto err_eswitch;
 		}
-		adapter->npars[pfn].active = (u8)pci_info[i].active;
-		adapter->npars[pfn].type = (u8)pci_info[i].type;
-		adapter->npars[pfn].phy_port = (u8)pci_info[i].default_port;
-		adapter->npars[pfn].min_bw = pci_info[i].tx_min_bw;
-		adapter->npars[pfn].max_bw = pci_info[i].tx_max_bw;
+
+		if (!pci_info[i].active ||
+				(pci_info[i].type != QLCNIC_TYPE_NIC))
+			continue;
+
+		adapter->npars[j].pci_func = pfn;
+		adapter->npars[j].active = (u8)pci_info[i].active;
+		adapter->npars[j].type = (u8)pci_info[i].type;
+		adapter->npars[j].phy_port = (u8)pci_info[i].default_port;
+		adapter->npars[j].min_bw = pci_info[i].tx_min_bw;
+		adapter->npars[j].max_bw = pci_info[i].tx_max_bw;
+		j++;
 	}
 
 	for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++)
@@ -485,52 +695,49 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 	u32 ref_count;
 	int i, ret = 1;
 	u32 data = QLCNIC_MGMT_FUNC;
-	void __iomem *priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	/* If other drivers are not in use set their privilege level */
-	ref_count = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
-	ret = qlcnic_api_lock(adapter);
+	ref_count = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	ret = ahw->hw_ops->api_lock(adapter);
 	if (ret)
 		goto err_lock;
 
 	if (qlcnic_config_npars) {
-		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-			id = i;
-			if (adapter->npars[i].type != QLCNIC_TYPE_NIC ||
-				id == adapter->ahw->pci_func)
+		for (i = 0; i < ahw->act_pci_func; i++) {
+			id = adapter->npars[i].pci_func;
+			if (id == ahw->pci_func)
 				continue;
 			data |= (qlcnic_config_npars &
 					QLC_DEV_SET_DRV(0xf, id));
 		}
 	} else {
-		data = readl(priv_op);
-		data = (data & ~QLC_DEV_SET_DRV(0xf, adapter->ahw->pci_func)) |
+		data = QLCRD(adapter, QLCNIC_DRV_OP_MODE);
+		data = (data & ~QLC_DEV_SET_DRV(0xf, ahw->pci_func)) |
 			(QLC_DEV_SET_DRV(QLCNIC_MGMT_FUNC,
-			adapter->ahw->pci_func));
+			ahw->pci_func));
 	}
-	writel(data, priv_op);
-	qlcnic_api_unlock(adapter);
+	QLCWR(adapter, QLCNIC_DRV_OP_MODE, data);
+	ahw->hw_ops->api_unlock(adapter);
 err_lock:
 	return ret;
 }
 
 static void
-qlcnic_check_vf(struct qlcnic_adapter *adapter)
+qlcnic_check_vf(struct qlcnic_adapter *adapter, const struct pci_device_id *ent)
 {
 	void __iomem *priv_op;
 	u32 op_mode, priv_level;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	/* Determine FW API version */
-	ahw->fw_hal_version = readl(adapter->ahw->pci_base0 +
-					QLCNIC_FW_API);
-
+	ahw->fw_hal_version = QLCRD(adapter, QLCNIC_FW_API);
 	/* Find PCI function number */
 	ahw->hw_ops->get_func_no(adapter);
 
 	/* Determine function privilege level */
 	priv_op = ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
-	op_mode = readl(priv_op);
+	op_mode = QLCRD(adapter, QLCNIC_DRV_OP_MODE);
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
 		priv_level = QLCNIC_MGMT_FUNC;
 	else
@@ -542,8 +749,9 @@ qlcnic_check_vf(struct qlcnic_adapter *adapter)
 			"HAL Version: %d Non Privileged function\n",
 			ahw->fw_hal_version);
 		adapter->nic_ops = &qlcnic_vf_ops;
-	} else
+	} else {
 		adapter->nic_ops = &qlcnic_ops;
+	}
 }
 
 static int
@@ -559,7 +767,7 @@ qlcnic_setup_pci_map(struct pci_dev *pdev,
 	mem_len = pci_resource_len(pdev, 0);
 
 	QLCNIC_BAR_LENGTH(pdev->device, &bar0_len);
-	if (mem_len == bar0_len) {
+	if (mem_len >= bar0_len) {
 
 		mem_ptr0 = pci_ioremap_bar(pdev, 0);
 		if (mem_ptr0 == NULL) {
@@ -570,7 +778,6 @@ qlcnic_setup_pci_map(struct pci_dev *pdev,
 	} else {
 		return -EIO;
 	}
-
 	dev_info(&pdev->dev, "%dMB memory map\n", (int)(mem_len>>20));
 
 	ahw->pci_base0 = mem_ptr0;
@@ -605,9 +812,10 @@ static void qlcnic_get_brd_name(struct qlcnic_adapter *adapter, char *name)
 		sprintf(name, "%pM Gigabit Ethernet", adapter->mac_addr);
 }
 
-static void
+void
 qlcnic_check_options(struct qlcnic_adapter *adapter)
 {
+	int err;
 	u32 fw_major, fw_minor, fw_build, prev_fw_version;
 	struct pci_dev *pdev = adapter->pdev;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -615,20 +823,22 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	prev_fw_version = adapter->fw_version;
 
-	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
-	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
-	fw_build = QLCRD32(adapter, QLCNIC_FW_VERSION_SUB);
+	fw_major = QLCRD(adapter, QLCNIC_FW_VERSION_MAJOR);
+	fw_minor = QLCRD(adapter, QLCNIC_FW_VERSION_MINOR);
+	fw_build = QLCRD(adapter, QLCNIC_FW_VERSION_SUB);
 
 	adapter->fw_version = QLCNIC_VERSION_CODE(fw_major, fw_minor, fw_build);
 
+	err = adapter->ahw->hw_ops->get_board_info(adapter);
+	if (err) {
+		dev_err(&pdev->dev, "Error getting board config info.\n");
+		return;
+	}
 	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC) {
 		if (fw_dump->tmpl_hdr == NULL ||
 				adapter->fw_version > prev_fw_version) {
 			if (fw_dump->tmpl_hdr)
 				vfree(fw_dump->tmpl_hdr);
-			if (!qlcnic_fw_cmd_get_minidump_temp(adapter))
-				dev_info(&pdev->dev,
-					"Supports FW dump capability\n");
 		}
 	}
 
@@ -665,20 +875,25 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 {
 	int err;
 	struct qlcnic_info nic_info;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	err = qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw->pci_func);
+	err = ahw->hw_ops->get_nic_info(adapter, &nic_info, ahw->pci_func);
 	if (err)
 		return err;
 
-	adapter->ahw->physical_port = (u8)nic_info.phys_port;
-	adapter->ahw->switch_mode = nic_info.switch_mode;
-	adapter->ahw->max_tx_ques = nic_info.max_tx_ques;
-	adapter->ahw->max_rx_ques = nic_info.max_rx_ques;
-	adapter->ahw->capabilities = nic_info.capabilities;
-	adapter->ahw->max_mac_filters = nic_info.max_mac_filters;
-	adapter->ahw->max_mtu = nic_info.max_mtu;
+	ahw->physical_port = (u8) nic_info.phys_port;
+	ahw->switch_mode = nic_info.switch_mode;
+	ahw->max_tx_ques = nic_info.max_tx_ques;
+	ahw->max_rx_ques = nic_info.max_rx_ques;
+	ahw->capabilities = nic_info.capabilities;
+	ahw->max_mac_filters = nic_info.max_mac_filters;
+	ahw->max_mtu = nic_info.max_mtu;
+
+	/* Disable NPAR for 83XX */
+	if (QLCNIC_IS_83XX(adapter))
+		return err;
 
-	if (adapter->ahw->capabilities & BIT_6)
+	if (ahw->capabilities & BIT_6)
 		adapter->flags |= QLCNIC_ESWITCH_ENABLED;
 	else
 		adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
@@ -701,24 +916,6 @@ qlcnic_set_vlan_config(struct qlcnic_adapter *adapter,
 		adapter->pvid = 0;
 }
 
-static int
-qlcnic_vlan_rx_add(struct net_device *netdev, u16 vid)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	set_bit(vid, adapter->vlans);
-	return 0;
-}
-
-static int
-qlcnic_vlan_rx_del(struct net_device *netdev, u16 vid)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-
-	qlcnic_restore_indev_addr(netdev, NETDEV_DOWN);
-	clear_bit(vid, adapter->vlans);
-	return 0;
-}
-
 void qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
@@ -758,14 +955,17 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	struct net_device *netdev = adapter->netdev;
-	netdev_features_t features, vlan_features;
+	unsigned long features, vlan_features;
 
-	features = (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+	if (QLCNIC_IS_83XX(adapter))
+		return;
+
+	features = (NETIF_F_SG | NETIF_F_IP_CSUM |
 			NETIF_F_IPV6_CSUM | NETIF_F_GRO);
 	vlan_features = (NETIF_F_SG | NETIF_F_IP_CSUM |
-			NETIF_F_IPV6_CSUM | NETIF_F_HW_VLAN_FILTER);
+			NETIF_F_IPV6_CSUM);
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
+	if (QLCNIC_IS_TSO_CAPABLE(adapter)) {
 		features |= (NETIF_F_TSO | NETIF_F_TSO6);
 		vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
 	}
@@ -775,18 +975,20 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 
 	if (esw_cfg->offload_flags & BIT_0) {
 		netdev->features |= features;
+		adapter->rx_csum = 1;
 		if (!(esw_cfg->offload_flags & BIT_1))
 			netdev->features &= ~NETIF_F_TSO;
 		if (!(esw_cfg->offload_flags & BIT_2))
 			netdev->features &= ~NETIF_F_TSO6;
 	} else {
 		netdev->features &= ~features;
+		adapter->rx_csum = 0;
 	}
 
 	netdev->vlan_features = (features & vlan_features);
 }
 
-static int
+int
 qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 {
 	void __iomem *priv_op;
@@ -802,7 +1004,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 		return 0;
 
 	priv_op = ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
-	op_mode = readl(priv_op);
+	op_mode = QLCRD(adapter, QLCNIC_DRV_OP_MODE);
 	priv_level = QLC_DEV_GET_DRV(op_mode, ahw->pci_func);
 
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
@@ -834,7 +1036,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-static int
+int
 qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_esw_func_cfg esw_cfg;
@@ -844,16 +1046,16 @@ qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 	if (adapter->need_fw_reset)
 		return 0;
 
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
-			continue;
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
 		memset(&esw_cfg, 0, sizeof(struct qlcnic_esw_func_cfg));
-		esw_cfg.pci_func = i;
-		esw_cfg.offload_flags = BIT_0;
+		esw_cfg.pci_func = adapter->npars[i].pci_func;
 		esw_cfg.mac_override = BIT_0;
 		esw_cfg.promisc_mode = BIT_0;
-		if (adapter->ahw->capabilities  & QLCNIC_FW_CAPABILITY_TSO)
-			esw_cfg.offload_flags |= (BIT_1 | BIT_2);
+		if (QLCNIC_IS_82XX(adapter)) {
+			esw_cfg.offload_flags = BIT_0;
+			if (QLCNIC_IS_TSO_CAPABLE(adapter))
+				esw_cfg.offload_flags |= (BIT_1 | BIT_2);
+		}
 		if (qlcnic_config_switch_port(adapter, &esw_cfg))
 			return -EIO;
 		npar = &adapter->npars[i];
@@ -868,6 +1070,7 @@ qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
+
 static int
 qlcnic_reset_eswitch_config(struct qlcnic_adapter *adapter,
 			struct qlcnic_npar_info *npar, int pci_func)
@@ -891,37 +1094,39 @@ qlcnic_reset_eswitch_config(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static int
+int
 qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 {
 	int i, err;
 	struct qlcnic_npar_info *npar;
 	struct qlcnic_info nic_info;
+	u8 pci_func;
 
-	if (!adapter->need_fw_reset)
-		return 0;
+	if (QLCNIC_IS_82XX(adapter))
+		if (!adapter->need_fw_reset)
+			return 0;
 
 	/* Set the NPAR config data after FW reset */
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
 		npar = &adapter->npars[i];
-		if (npar->type != QLCNIC_TYPE_NIC)
-			continue;
-		err = qlcnic_get_nic_info(adapter, &nic_info, i);
+		pci_func = npar->pci_func;
+		err = adapter->ahw->hw_ops->get_nic_info(adapter,
+						&nic_info, pci_func);
 		if (err)
 			return err;
 		nic_info.min_tx_bw = npar->min_bw;
 		nic_info.max_tx_bw = npar->max_bw;
-		err = qlcnic_set_nic_info(adapter, &nic_info);
+		err = adapter->ahw->hw_ops->set_nic_info(adapter, &nic_info);
 		if (err)
 			return err;
 
 		if (npar->enable_pm) {
 			err = qlcnic_config_port_mirroring(adapter,
-							npar->dest_npar, 1, i);
+						npar->dest_npar, 1, pci_func);
 			if (err)
 				return err;
 		}
-		err = qlcnic_reset_eswitch_config(adapter, npar, i);
+		err = qlcnic_reset_eswitch_config(adapter, npar, pci_func);
 		if (err)
 			return err;
 	}
@@ -936,10 +1141,10 @@ static int qlcnic_check_npar_opertional(struct qlcnic_adapter *adapter)
 	if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
 		return 0;
 
-	npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+	npar_state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 	while (npar_state != QLCNIC_DEV_NPAR_OPER && --npar_opt_timeo) {
 		msleep(1000);
-		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+		npar_state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 	}
 	if (!npar_opt_timeo) {
 		dev_err(&adapter->pdev->dev,
@@ -949,7 +1154,7 @@ static int qlcnic_check_npar_opertional(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
-static int
+int
 qlcnic_set_mgmt_operations(struct qlcnic_adapter *adapter)
 {
 	int err;
@@ -1012,9 +1217,8 @@ check_fw_status:
 	if (err)
 		goto err_out;
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
+	QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
-
 	err = qlcnic_check_eswitch_mode(adapter);
 	if (err) {
 		dev_err(&adapter->pdev->dev,
@@ -1032,7 +1236,7 @@ check_fw_status:
 	return 0;
 
 err_out:
-	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
+	QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
 	dev_err(&adapter->pdev->dev, "Device state set to failed\n");
 
 	qlcnic_release_firmware(adapter);
@@ -1044,6 +1248,7 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 {
 	irq_handler_t handler;
 	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
 	int err, ring;
 
 	unsigned long flags = 0;
@@ -1051,7 +1256,8 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
-		handler = qlcnic_tmp_intr;
+		if (QLCNIC_IS_82XX(adapter))
+			handler = qlcnic_tmp_intr;
 		if (!QLCNIC_IS_MSI_FAMILY(adapter))
 			flags |= IRQF_SHARED;
 
@@ -1067,15 +1273,32 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	}
 	adapter->irq = netdev->irq;
 
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		sprintf(sds_ring->name, "%s[%d]", netdev->name, ring);
-		err = request_irq(sds_ring->irq, handler,
-				  flags, sds_ring->name, sds_ring);
-		if (err)
-			return err;
-	}
+	if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST) {
+		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+			sds_ring = &recv_ctx->sds_rings[ring];
+			sprintf(sds_ring->name, "%s[%d]",
+						netdev->name, ring);
+			err = request_irq(sds_ring->irq, handler, flags,
+					sds_ring->name, sds_ring);
+			if (err)
+				return err;
+		}
+		if (QLCNIC_IS_83XX(adapter) &&
+				 adapter->flags & QLCNIC_MSIX_ENABLED) {
+			handler = qlcnic_msix_tx_intr;
+			for (ring = 0; ring < adapter->max_drv_tx_rings;
+								ring++) {
+				tx_ring = &adapter->tx_ring[ring];
+				sprintf(tx_ring->name, "%s[%d]", netdev->name,
+					adapter->max_sds_rings + ring);
+				err = request_irq(tx_ring->irq, handler, flags,
+					tx_ring->name, tx_ring);
+				if (err)
+					return err;
+			}
+		}
 
+	}
 	return 0;
 }
 
@@ -1084,70 +1307,75 @@ qlcnic_free_irq(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
 
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		free_irq(sds_ring->irq, sds_ring);
+	if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST) {
+		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+			sds_ring = &recv_ctx->sds_rings[ring];
+			free_irq(sds_ring->irq, sds_ring);
+		}
+		if (QLCNIC_IS_83XX(adapter)) {
+			for (ring = 0; ring < adapter->max_drv_tx_rings;
+				 ring++) {
+				tx_ring = &adapter->tx_ring[ring];
+				if (tx_ring->irq)
+					free_irq(tx_ring->irq, tx_ring);
+			}
+		}
 	}
 }
 
 static int
 __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
-	int ring;
-	u32 capab2;
-
+	u8 ring;
 	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
 		return -EIO;
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return 0;
+
 	if (qlcnic_set_eswitch_port_config(adapter))
 		return -EIO;
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
-		capab2 = QLCRD32(adapter, CRB_FW_CAPABILITIES_2);
-		if (capab2 & QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG)
-			adapter->flags |= QLCNIC_FW_LRO_MSS_CAP;
-	}
-
 	if (qlcnic_fw_create_ctx(adapter))
 		return -EIO;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &adapter->recv_ctx->rds_rings[ring];
-		qlcnic_post_rx_buffers(adapter, rds_ring);
+		qlcnic_post_rx_buffers(adapter, rds_ring, ring);
 	}
 
 	qlcnic_set_multi(netdev);
 	qlcnic_fw_cmd_set_mtu(adapter, netdev->mtu);
 
-	adapter->ahw->linkup = 0;
+	ahw->linkup = 0;
 
 	if (adapter->max_sds_rings > 1)
-		qlcnic_config_rss(adapter, 1);
+		ahw->hw_ops->config_rss(adapter, 1);
 
-	qlcnic_config_intr_coalesce(adapter);
+	ahw->hw_ops->config_intr_coal(adapter);
 
 	if (netdev->features & NETIF_F_LRO)
-		qlcnic_config_hw_lro(adapter, QLCNIC_LRO_ENABLED);
+		ahw->hw_ops->config_hw_lro(adapter, QLCNIC_LRO_ENABLED);
 
-	qlcnic_napi_enable(adapter);
+	ahw->hw_ops->napi_enable(adapter);
 
-	qlcnic_linkevent_request(adapter, 1);
-
-	adapter->ahw->reset_context = 0;
+	ahw->reset_context = 0;
 	set_bit(__QLCNIC_DEV_UP, &adapter->state);
+
+	ahw->hw_ops->setup_link_event(adapter, 1);
 	return 0;
 }
 
 /* Usage: During resume and firmware recovery module.*/
 
-static int
+int
 qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
 	int err = 0;
@@ -1179,12 +1407,12 @@ __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	if (adapter->fhash.fnum)
 		qlcnic_delete_lb_filters(adapter);
 
-	qlcnic_nic_set_promisc(adapter, QLCNIC_NIU_NON_PROMISC_MODE);
+	adapter->ahw->hw_ops->config_promisc_mode(adapter,
+		QLCNIC_NIU_NON_PROMISC_MODE);
 
-	qlcnic_napi_disable(adapter);
+	adapter->ahw->hw_ops->napi_disable(adapter);
 
 	qlcnic_fw_destroy_ctx(adapter);
-	adapter->flags &= ~QLCNIC_FW_LRO_MSS_CAP;
 
 	qlcnic_reset_rx_buffers_list(adapter);
 	qlcnic_release_tx_buffers(adapter);
@@ -1193,27 +1421,26 @@ __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 /* Usage: During suspend and firmware recovery module */
 
-static void
+void
 qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
 	rtnl_lock();
 	if (netif_running(netdev))
 		__qlcnic_down(adapter, netdev);
 	rtnl_unlock();
-
 }
 
-static int
+int
 qlcnic_attach(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
-	int err;
+	int err = -1;
 
 	if (adapter->is_up == QLCNIC_ADAPTER_UP_MAGIC)
 		return 0;
 
-	err = qlcnic_napi_add(adapter, netdev);
+	err = adapter->nic_ops->napi_add(adapter, netdev);
 	if (err)
 		return err;
 
@@ -1249,7 +1476,7 @@ err_out_napi_del:
 	return err;
 }
 
-static void
+void
 qlcnic_detach(struct qlcnic_adapter *adapter)
 {
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
@@ -1276,7 +1503,10 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 			sds_ring = &adapter->recv_ctx->sds_rings[ring];
-			QLCNIC_DISABLE_INTR(sds_ring->crb_intr_mask);
+			if (QLCNIC_IS_83XX(adapter))
+				writel(1, sds_ring->crb_intr_mask);
+			else
+				QLCNIC_DISABLE_INTR(sds_ring->crb_intr_mask);
 		}
 	}
 
@@ -1326,6 +1556,8 @@ static void qlcnic_free_adapter_resources(struct qlcnic_adapter *adapter)
 		vfree(adapter->ahw->fw_dump.tmpl_hdr);
 		adapter->ahw->fw_dump.tmpl_hdr = NULL;
 	}
+
+	adapter->ahw->fw_dump.tmpl_hdr = NULL;
 }
 
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
@@ -1333,7 +1565,7 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_host_rds_ring *rds_ring;
-	int ring;
+	u8 ring;
 	int ret;
 
 	netif_device_detach(netdev);
@@ -1361,19 +1593,22 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &adapter->recv_ctx->rds_rings[ring];
-		qlcnic_post_rx_buffers(adapter, rds_ring);
+		qlcnic_post_rx_buffers(adapter, rds_ring, ring);
 	}
 
 	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 			sds_ring = &adapter->recv_ctx->sds_rings[ring];
-			QLCNIC_ENABLE_INTR(adapter, sds_ring->crb_intr_mask);
+			if (QLCNIC_IS_82XX(adapter)) {
+				QLCNIC_ENABLE_INTR(adapter,
+					sds_ring->crb_intr_mask);
+			}
 		}
 	}
 
 	if (adapter->ahw->diag_test == QLCNIC_LOOPBACK_TEST) {
 		adapter->ahw->loopback_state = 0;
-		qlcnic_linkevent_request(adapter, 1);
+		adapter->ahw->hw_ops->setup_link_event(adapter, 1);
 	}
 
 	set_bit(__QLCNIC_DEV_UP, &adapter->state);
@@ -1399,6 +1634,7 @@ qlcnic_reset_hw_context(struct qlcnic_adapter *adapter)
 	netif_device_attach(netdev);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	dev_err(&adapter->pdev->dev, "%s:\n", __func__);
 	return 0;
 }
 
@@ -1442,33 +1678,37 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	int err;
 	struct pci_dev *pdev = adapter->pdev;
 
+	adapter->rx_csum = 1;
 	adapter->ahw->mc_enabled = 0;
 	adapter->ahw->max_mc_count = QLCNIC_MAX_MC_COUNT;
 
 	netdev->netdev_ops	   = &qlcnic_netdev_ops;
-	netdev->watchdog_timeo     = QLCNIC_WATCHDOG_TIMEOUTVALUE*HZ;
+	netdev->watchdog_timeo     = QLCNIC_WATCHDOG_TIMEOUTVALUE * HZ;
 
 	qlcnic_change_mtu(netdev, netdev->mtu);
 
 	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_ops);
 
-	netdev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
+	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
+		NETIF_F_IPV6_CSUM | NETIF_F_GRO | NETIF_F_HW_VLAN_RX);
+	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
+		NETIF_F_IPV6_CSUM);
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
-		netdev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
-	if (pci_using_dac)
-		netdev->hw_features |= NETIF_F_HIGHDMA;
+	if (QLCNIC_IS_TSO_CAPABLE(adapter)) {
+		netdev->features |= (NETIF_F_TSO | NETIF_F_TSO6);
+		netdev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
+	}
 
-	netdev->vlan_features = netdev->hw_features;
+	if (pci_using_dac) {
+		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->vlan_features |= NETIF_F_HIGHDMA;
+	}
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX)
-		netdev->hw_features |= NETIF_F_HW_VLAN_TX;
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
-		netdev->hw_features |= NETIF_F_LRO;
+	if (QLCNIC_IS_VLAN_TX_CAPABLE(adapter))
+		netdev->features |= (NETIF_F_HW_VLAN_TX);
 
-	netdev->features |= netdev->hw_features |
-		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
+		netdev->features |= NETIF_F_LRO;
 
 	netdev->irq = adapter->msix_entries[0].vector;
 
@@ -1497,6 +1737,17 @@ static int qlcnic_set_dma_mask(struct pci_dev *pdev, u8 *pci_using_dac)
 	return 0;
 }
 
+int qlcnic_is_valid_nic_func(struct qlcnic_adapter *adapter, u8 pci_func)
+{
+	int i;
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		if (adapter->npars[i].pci_func == pci_func)
+			return i;
+	}
+
+	return -1;
+}
+
 static int __devinit
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1531,10 +1782,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!ahw)
 		goto err_out_free_res;
 
-	if (ent->device == PCI_DEVICE_ID_QLOGIC_QLE824X)
-		ahw->hw_ops = &qlcnic_82xx_ops;
-	else
-		goto err_out_free_hw_res;
+	if (ent->device == PCI_DEVICE_ID_QLOGIC_QLE824X) {
+		ahw->hw_ops = &qlcnic_hw_ops;
+		ahw->reg_tbl = (u32 *) qlcnic_reg_tbl;
+	}
 
 	err = qlcnic_setup_pci_map(pdev, ahw);
 	if (err)
@@ -1559,6 +1810,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->dev_rst_time = jiffies;
 	adapter->ahw->revision_id = pdev->revision;
 	adapter->mac_learn = qlcnic_mac_learn;
+	adapter->max_drv_tx_rings = 1;
 
 	rwlock_init(&adapter->ahw->crb_lock);
 	mutex_init(&adapter->ahw->mem_lock);
@@ -1566,28 +1818,21 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	spin_lock_init(&adapter->tx_clean_lock);
 	INIT_LIST_HEAD(&adapter->mac_list);
 
-	qlcnic_check_vf(adapter);
-
-	/* This will be reset for mezz cards  */
-	adapter->portnum = adapter->ahw->pci_func;
-
-	err = qlcnic_get_board_info(adapter);
-	if (err) {
-		dev_err(&pdev->dev, "Error getting board config info.\n");
-		goto err_out_free_hw;
-	}
-
-	err = qlcnic_setup_idc_param(adapter);
-	if (err)
-		goto err_out_free_hw;
+	/* hilda workaorund */
+	if (QLCNIC_IS_82XX(adapter)) {
+		qlcnic_check_vf(adapter, ent);
+		adapter->portnum = adapter->ahw->pci_func;
+		err = adapter->nic_ops->start_firmware(adapter);
+		if (err) {
+			dev_err(&pdev->dev, "FW load failed. Please Reboot\n");
+			goto err_out_free_hw;
+		}
 
-	adapter->flags |= QLCNIC_NEED_FLR;
+		err = qlcnic_setup_idc_param(adapter);
+		if (err)
+			goto err_out_free_hw;
 
-	err = adapter->nic_ops->start_firmware(adapter);
-	if (err) {
-		dev_err(&pdev->dev, "Loading fw failed. Please Reboot\n"
-			"\t\tIf reboot doesn't help, try flashing the card\n");
-		goto err_out_maintenance_mode;
+		adapter->flags |= QLCNIC_NEED_FLR;
 	}
 
 	if (qlcnic_read_mac_addr(adapter))
@@ -1600,18 +1845,21 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 				module_name(THIS_MODULE),
 				brd_name, adapter->ahw->revision_id);
 	}
+	err = ahw->hw_ops->setup_intr(adapter, 0);
+	if (err)
+		goto err_out_disable_msi;
 
-	err = ahw->hw_ops->setup_intr(adapter);
-	if (err == -ENOMEM)
-		goto err_out_decr_ref;
 
 	err = qlcnic_setup_netdev(adapter, netdev, pci_using_dac);
 	if (err)
-		goto err_out_disable_msi;
+		goto err_out_disable_mbx_intr;
 
 	pci_set_drvdata(pdev, adapter);
 
-	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
+	if (QLCNIC_IS_82XX(adapter)) {
+		qlcnic_schedule_work(adapter,
+			qlcnic_fw_poll_work, FW_POLL_DELAY);
+	}
 
 	switch (adapter->ahw->port_type) {
 	case QLCNIC_GBE:
@@ -1627,15 +1875,15 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (adapter->mac_learn)
 		qlcnic_alloc_lb_filters_mem(adapter);
 
-	qlcnic_create_diag_entries(adapter);
+	adapter->ahw->hw_ops->add_sysfs(adapter);
 
 	return 0;
 
+err_out_disable_mbx_intr:
+
 err_out_disable_msi:
 	qlcnic_teardown_intr(adapter);
-	kfree(adapter->msix_entries);
-
-err_out_decr_ref:
+	adapter->nic_ops->cancel_idc_work(adapter);
 	qlcnic_clr_all_drv_state(adapter, 0);
 
 err_out_free_hw:
@@ -1657,18 +1905,6 @@ err_out_disable_pdev:
 	pci_set_drvdata(pdev, NULL);
 	pci_disable_device(pdev);
 	return err;
-
-err_out_maintenance_mode:
-	netdev->netdev_ops = &qlcnic_netdev_failed_ops;
-	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_failed_ops);
-	err = register_netdev(netdev);
-	if (err) {
-		dev_err(&pdev->dev, "failed to register net device\n");
-		goto err_out_decr_ref;
-	}
-	pci_set_drvdata(pdev, adapter);
-	qlcnic_create_diag_entries(adapter);
-	return 0;
 }
 
 static void __devexit qlcnic_remove(struct pci_dev *pdev)
@@ -1683,28 +1919,27 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 
 	netdev = adapter->netdev;
 	ahw = adapter->ahw;
-
-	qlcnic_cancel_fw_work(adapter);
+	adapter->nic_ops->cancel_idc_work(adapter);
 
 	unregister_netdev(netdev);
 
-	qlcnic_detach(adapter);
 
+	qlcnic_detach(adapter);
 	if (adapter->npars != NULL)
 		kfree(adapter->npars);
 	if (adapter->eswitch != NULL)
 		kfree(adapter->eswitch);
 
-	qlcnic_clr_all_drv_state(adapter, 0);
+	if (QLCNIC_IS_82XX(adapter))
+		qlcnic_clr_all_drv_state(adapter, 0);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
 	qlcnic_free_lb_filters_mem(adapter);
 
 	qlcnic_teardown_intr(adapter);
-	kfree(adapter->msix_entries);
 
-	qlcnic_remove_diag_entries(adapter);
+	adapter->ahw->hw_ops->remove_sysfs(adapter);
 
 	qlcnic_cleanup_pci_map(ahw);
 
@@ -1726,13 +1961,13 @@ static int __qlcnic_shutdown(struct pci_dev *pdev)
 	int retval;
 
 	netif_device_detach(netdev);
-
-	qlcnic_cancel_fw_work(adapter);
+	adapter->nic_ops->cancel_idc_work(adapter);
 
 	if (netif_running(netdev))
 		qlcnic_down(adapter, netdev);
 
-	qlcnic_clr_all_drv_state(adapter, 0);
+	if (QLCNIC_IS_82XX(adapter))
+		qlcnic_clr_all_drv_state(adapter, 0);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
@@ -1740,9 +1975,11 @@ static int __qlcnic_shutdown(struct pci_dev *pdev)
 	if (retval)
 		return retval;
 
-	if (qlcnic_wol_supported(adapter)) {
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
+	if (QLCNIC_IS_82XX(adapter)) {
+		if (qlcnic_wol_supported(adapter)) {
+			pci_enable_wake(pdev, PCI_D3cold, 1);
+			pci_enable_wake(pdev, PCI_D3hot, 1);
+		}
 	}
 
 	return 0;
@@ -1808,16 +2045,9 @@ done:
 static int qlcnic_open(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 	int err;
 
-	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD)) {
-		netdev_err(netdev, "Device in FAILED state\n");
-		return -EIO;
-	}
-
 	netif_carrier_off(netdev);
-
 	err = qlcnic_attach(adapter);
 	if (err)
 		return err;
@@ -1877,13 +2107,16 @@ static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter)
 	adapter->fhash.fmax = 0;
 }
 
-static int qlcnic_check_temp(struct qlcnic_adapter *adapter)
+int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	u32 temp, temp_state, temp_val;
 	int rv = 0;
 
-	temp = QLCRD32(adapter, CRB_TEMP_STATE);
+	temp = 0;
+
+	if (QLCNIC_IS_82XX(adapter))
+		temp = QLCRD(adapter, QLCNIC_ASIC_TEMP);
 
 	temp_state = qlcnic_get_temp_state(temp);
 	temp_val = qlcnic_get_temp_val(temp);
@@ -1977,7 +2210,7 @@ static irqreturn_t qlcnic_tmp_intr(int irq, void *data)
 		goto done;
 	}
 
-	if (qlcnic_clear_legacy_intr(adapter) == IRQ_NONE)
+	if (adapter->nic_ops->clear_legacy_intr(adapter) == IRQ_NONE)
 		return IRQ_NONE;
 
 done:
@@ -1991,7 +2224,7 @@ static irqreturn_t qlcnic_intr(int irq, void *data)
 	struct qlcnic_host_sds_ring *sds_ring = data;
 	struct qlcnic_adapter *adapter = sds_ring->adapter;
 
-	if (qlcnic_clear_legacy_intr(adapter) == IRQ_NONE)
+	if (adapter->nic_ops->clear_legacy_intr(adapter) == IRQ_NONE)
 		return IRQ_NONE;
 
 	napi_schedule(&sds_ring->napi);
@@ -2019,6 +2252,14 @@ static irqreturn_t qlcnic_msix_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t qlcnic_msix_tx_intr(int irq, void *data)
+{
+	struct qlcnic_host_tx_ring *tx_ring = data;
+
+	napi_schedule(&tx_ring->napi);
+	return IRQ_HANDLED;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void qlcnic_poll_controller(struct net_device *netdev)
 {
@@ -2045,7 +2286,7 @@ qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding)
 	val |= encoding << 7;
 	val |= (jiffies - adapter->dev_rst_time) << 8;
 
-	QLCWR32(adapter, QLCNIC_CRB_DRV_SCRATCH, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_SCRATCH, val);
 	adapter->dev_rst_time = jiffies;
 }
 
@@ -2057,19 +2298,19 @@ qlcnic_set_drv_state(struct qlcnic_adapter *adapter, u8 state)
 	WARN_ON(state != QLCNIC_DEV_NEED_RESET &&
 			state != QLCNIC_DEV_NEED_QUISCENT);
 
-	if (qlcnic_api_lock(adapter))
+	if (adapter->ahw->hw_ops->api_lock(adapter))
 		return -EIO;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 
 	if (state == QLCNIC_DEV_NEED_RESET)
 		QLC_DEV_SET_RST_RDY(val, adapter->portnum);
 	else if (state == QLCNIC_DEV_NEED_QUISCENT)
 		QLC_DEV_SET_QSCNT_RDY(val, adapter->portnum);
 
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
-	qlcnic_api_unlock(adapter);
+	adapter->ahw->hw_ops->api_unlock(adapter);
 
 	return 0;
 }
@@ -2079,14 +2320,14 @@ qlcnic_clr_drv_state(struct qlcnic_adapter *adapter)
 {
 	u32  val;
 
-	if (qlcnic_api_lock(adapter))
+	if (adapter->ahw->hw_ops->api_lock(adapter))
 		return -EBUSY;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 	QLC_DEV_CLR_RST_QSCNT(val, adapter->portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
-	qlcnic_api_unlock(adapter);
+	adapter->ahw->hw_ops->api_unlock(adapter);
 
 	return 0;
 }
@@ -2096,25 +2337,25 @@ qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8 failed)
 {
 	u32  val;
 
-	if (qlcnic_api_lock(adapter))
+	if (adapter->ahw->hw_ops->api_lock(adapter))
 		goto err;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	QLC_DEV_CLR_REF_CNT(val, adapter->portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
 
 	if (failed) {
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
 		dev_info(&adapter->pdev->dev,
 				"Device state set to Failed. Please Reboot\n");
 	} else if (!(val & 0x11111111))
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_COLD);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_COLD);
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 	QLC_DEV_CLR_RST_QSCNT(val, adapter->portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
-	qlcnic_api_unlock(adapter);
+	adapter->ahw->hw_ops->api_unlock(adapter);
 err:
 	adapter->fw_fail_cnt = 0;
 	adapter->flags &= ~QLCNIC_FW_HANG;
@@ -2129,8 +2370,8 @@ qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 	int act, state, active_mask;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
-	act = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	state = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
+	act = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 
 	if (adapter->flags & QLCNIC_FW_RESET_OWNER) {
 		active_mask = (~(1 << (ahw->pci_func * 4)));
@@ -2146,7 +2387,7 @@ qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 
 static int qlcnic_check_idc_ver(struct qlcnic_adapter *adapter)
 {
-	u32 val = QLCRD32(adapter, QLCNIC_CRB_DRV_IDC_VER);
+	u32 val = QLCRD(adapter, QLCNIC_CRB_DRV_IDC_VER);
 
 	if (val != QLCNIC_DRV_IDC_VER) {
 		dev_warn(&adapter->pdev->dev, "IDC Version mismatch, driver's"
@@ -2163,50 +2404,51 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	u8 dev_init_timeo = adapter->dev_init_timeo;
 	u8 portnum = adapter->portnum;
 	u8 ret;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	if (test_and_clear_bit(__QLCNIC_START_FW, &adapter->state))
 		return 1;
 
-	if (qlcnic_api_lock(adapter))
+	if (ahw->hw_ops->api_lock(adapter))
 		return -1;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	if (!(val & (1 << (portnum * 4)))) {
 		QLC_DEV_SET_REF_CNT(val, portnum);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
+		QLCWR(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
 	}
 
-	prev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	prev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	QLCDB(adapter, HW, "Device state = %u\n", prev_state);
 
 	switch (prev_state) {
 	case QLCNIC_DEV_COLD:
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_IDC_VER, QLCNIC_DRV_IDC_VER);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
+		QLCWR(adapter, QLCNIC_CRB_DRV_IDC_VER, QLCNIC_DRV_IDC_VER);
 		qlcnic_idc_debug_info(adapter, 0);
-		qlcnic_api_unlock(adapter);
+		ahw->hw_ops->api_unlock(adapter);
 		return 1;
 
 	case QLCNIC_DEV_READY:
 		ret = qlcnic_check_idc_ver(adapter);
-		qlcnic_api_unlock(adapter);
+		ahw->hw_ops->api_unlock(adapter);
 		return ret;
 
 	case QLCNIC_DEV_NEED_RESET:
-		val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+		val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 		QLC_DEV_SET_RST_RDY(val, portnum);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+		QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 		break;
 
 	case QLCNIC_DEV_NEED_QUISCENT:
-		val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+		val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 		QLC_DEV_SET_QSCNT_RDY(val, portnum);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+		QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 		break;
 
 	case QLCNIC_DEV_FAILED:
 		dev_err(&adapter->pdev->dev, "Device in failed state.\n");
-		qlcnic_api_unlock(adapter);
+		ahw->hw_ops->api_unlock(adapter);
 		return -1;
 
 	case QLCNIC_DEV_INITIALIZING:
@@ -2214,11 +2456,11 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 		break;
 	}
 
-	qlcnic_api_unlock(adapter);
+	ahw->hw_ops->api_unlock(adapter);
 
 	do {
 		msleep(1000);
-		prev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		prev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 
 		if (prev_state == QLCNIC_DEV_QUISCENT)
 			continue;
@@ -2230,15 +2472,15 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 		return -1;
 	}
 
-	if (qlcnic_api_lock(adapter))
+	if (ahw->hw_ops->api_lock(adapter))
 		return -1;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 	QLC_DEV_CLR_RST_QSCNT(val, portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	ret = qlcnic_check_idc_ver(adapter);
-	qlcnic_api_unlock(adapter);
+	ahw->hw_ops->api_unlock(adapter);
 
 	return ret;
 }
@@ -2252,20 +2494,20 @@ qlcnic_fwinit_work(struct work_struct *work)
 	u32 val;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	if (qlcnic_api_lock(adapter))
+	if (ahw->hw_ops->api_lock(adapter))
 		goto err_ret;
 
-	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	if (dev_state == QLCNIC_DEV_QUISCENT ||
 	    dev_state == QLCNIC_DEV_NEED_QUISCENT) {
-		qlcnic_api_unlock(adapter);
+		ahw->hw_ops->api_unlock(adapter);
 		qlcnic_schedule_work(adapter, qlcnic_fwinit_work,
 						FW_POLL_DELAY * 2);
 		return;
 	}
 
 	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
-		qlcnic_api_unlock(adapter);
+		ahw->hw_ops->api_unlock(adapter);
 		goto wait_npar;
 	}
 
@@ -2284,28 +2526,21 @@ qlcnic_fwinit_work(struct work_struct *work)
 
 	if (!qlcnic_check_drv_state(adapter)) {
 skip_ack_check:
-		dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 
 		if (dev_state == QLCNIC_DEV_NEED_RESET) {
-			QLCWR32(adapter, QLCNIC_CRB_DEV_STATE,
+			QLCWR(adapter, QLCNIC_CRB_DEV_STATE,
 						QLCNIC_DEV_INITIALIZING);
 			set_bit(__QLCNIC_START_FW, &adapter->state);
 			QLCDB(adapter, DRV, "Restarting fw\n");
 			qlcnic_idc_debug_info(adapter, 0);
-			val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+			val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 			QLC_DEV_SET_RST_RDY(val, adapter->portnum);
-			QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+			QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 		}
 
-		qlcnic_api_unlock(adapter);
+		ahw->hw_ops->api_unlock(adapter);
 
-		rtnl_lock();
-		if (ahw->fw_dump.enable &&
-		    (adapter->flags & QLCNIC_FW_RESET_OWNER)) {
-			QLCDB(adapter, DRV, "Take FW dump\n");
-			adapter->flags |= QLCNIC_FW_HANG;
-		}
-		rtnl_unlock();
 
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
 		if (!adapter->nic_ops->start_firmware(adapter)) {
@@ -2316,10 +2551,10 @@ skip_ack_check:
 		goto err_ret;
 	}
 
-	qlcnic_api_unlock(adapter);
+	ahw->hw_ops->api_unlock(adapter);
 
 wait_npar:
-	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	QLCDB(adapter, HW, "Func waiting: Device state=%u\n", dev_state);
 
 	switch (dev_state) {
@@ -2361,7 +2596,7 @@ qlcnic_detach_work(struct work_struct *work)
 	} else
 		qlcnic_down(adapter, netdev);
 
-	status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
+	status = QLCRD(adapter, QLCNIC_PEG_HALT_STATUS1);
 
 	if (status & QLCNIC_RCODE_FATAL_ERROR) {
 		dev_err(&adapter->pdev->dev,
@@ -2412,19 +2647,19 @@ qlcnic_set_npar_non_operational(struct qlcnic_adapter *adapter)
 {
 	u32 state;
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+	state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 	if (state == QLCNIC_DEV_NPAR_NON_OPER)
 		return;
 
-	if (qlcnic_api_lock(adapter))
+	if (adapter->ahw->hw_ops->api_lock(adapter))
 		return;
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_NON_OPER);
-	qlcnic_api_unlock(adapter);
+	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_NON_OPER);
+	adapter->ahw->hw_ops->api_unlock(adapter);
 }
 
 /*Transit to RESET state from READY state only */
 void
-qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
+qlcnic_dev_request_reset(struct qlcnic_adapter *adapter, u32 key)
 {
 	u32 state, xg_val = 0, gb_val = 0;
 
@@ -2436,46 +2671,41 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 	qlcnic_gb_set_gb2_mask(gb_val);
 	qlcnic_gb_set_gb3_mask(gb_val);
 	QLCWR32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, gb_val);
-	dev_info(&adapter->pdev->dev, "Pause control frames disabled"
-				" on all ports\n");
+	dev_info(&adapter->pdev->dev,
+			"Pause control frames disabled on all ports\n");
 	adapter->need_fw_reset = 1;
-	if (qlcnic_api_lock(adapter))
-		return;
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-	if (state  == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD)) {
-		netdev_err(adapter->netdev,
-				"Device is in FAILED state, Please Reboot\n");
-		qlcnic_api_unlock(adapter);
+	if (adapter->ahw->hw_ops->api_lock(adapter))
 		return;
-	}
+
+	state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 
 	if (state == QLCNIC_DEV_READY) {
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
 		adapter->flags |= QLCNIC_FW_RESET_OWNER;
 		QLCDB(adapter, DRV, "NEED_RESET state set\n");
 		qlcnic_idc_debug_info(adapter, 0);
 	}
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE,
+	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE,
 		QLCNIC_DEV_NPAR_NON_OPER);
-	qlcnic_api_unlock(adapter);
+	adapter->ahw->hw_ops->api_unlock(adapter);
 }
 
 /* Transit to NPAR READY state from NPAR NOT READY state */
 static void
 qlcnic_dev_set_npar_ready(struct qlcnic_adapter *adapter)
 {
-	if (qlcnic_api_lock(adapter))
+	if (adapter->ahw->hw_ops->api_lock(adapter))
 		return;
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_OPER);
+	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_OPER);
 	QLCDB(adapter, DRV, "NPAR operational state set\n");
 
-	qlcnic_api_unlock(adapter);
+	adapter->ahw->hw_ops->api_unlock(adapter);
 }
 
-static void
+void
 qlcnic_schedule_work(struct qlcnic_adapter *adapter,
 		work_func_t func, int delay)
 {
@@ -2484,19 +2714,7 @@ qlcnic_schedule_work(struct qlcnic_adapter *adapter,
 
 	INIT_DELAYED_WORK(&adapter->fw_work, func);
 	queue_delayed_work(qlcnic_wq, &adapter->fw_work,
-					round_jiffies_relative(delay));
-}
-
-static void
-qlcnic_cancel_fw_work(struct qlcnic_adapter *adapter)
-{
-	while (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-		msleep(10);
-
-	if (!adapter->fw_work.work.func)
-		return;
-
-	cancel_delayed_work_sync(&adapter->fw_work);
+				round_jiffies_relative(delay));
 }
 
 static void
@@ -2508,7 +2726,7 @@ qlcnic_attach_work(struct work_struct *work)
 	u32 npar_state;
 
 	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC) {
-		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+		npar_state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 		if (adapter->fw_wait_cnt++ > QLCNIC_DEV_NPAR_OPER_TIMEO)
 			qlcnic_clr_all_drv_state(adapter, 0);
 		else if (npar_state != QLCNIC_DEV_NPAR_OPER)
@@ -2541,6 +2759,7 @@ done:
 static int
 qlcnic_check_health(struct qlcnic_adapter *adapter)
 {
+	int err;
 	u32 state = 0, heartbeat;
 	u32 peg_status;
 
@@ -2548,16 +2767,16 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		goto detach;
 
 	if (adapter->need_fw_reset)
-		qlcnic_dev_request_reset(adapter);
+		adapter->nic_ops->request_reset(adapter, 0);
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	if (state == QLCNIC_DEV_NEED_RESET) {
 		qlcnic_set_npar_non_operational(adapter);
 		adapter->need_fw_reset = 1;
 	} else if (state == QLCNIC_DEV_NEED_QUISCENT)
 		goto detach;
 
-	heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+	heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 	if (heartbeat != adapter->heartbeat) {
 		adapter->heartbeat = heartbeat;
 		adapter->fw_fail_cnt = 0;
@@ -2577,25 +2796,25 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 
 	adapter->flags |= QLCNIC_FW_HANG;
 
-	qlcnic_dev_request_reset(adapter);
+	adapter->nic_ops->request_reset(adapter, 0);
 
 	if (auto_fw_reset)
 		clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
 
 	dev_err(&adapter->pdev->dev, "firmware hang detected\n");
+	peg_status = QLCRD(adapter, QLCNIC_PEG_HALT_STATUS1);
 	dev_err(&adapter->pdev->dev, "Dumping hw/fw registers\n"
 			"PEG_HALT_STATUS1: 0x%x, PEG_HALT_STATUS2: 0x%x,\n"
 			"PEG_NET_0_PC: 0x%x, PEG_NET_1_PC: 0x%x,\n"
 			"PEG_NET_2_PC: 0x%x, PEG_NET_3_PC: 0x%x,\n"
 			"PEG_NET_4_PC: 0x%x\n",
-			QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1),
-			QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS2),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c));
-	peg_status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
+			peg_status,
+			QLCRD(adapter, QLCNIC_PEG_HALT_STATUS2),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c, &err));
 	if (QLCNIC_FWERROR_CODE(peg_status) == 0x67)
 		dev_err(&adapter->pdev->dev,
 			"Firmware aborted with error code 0x00006700. "
@@ -2634,6 +2853,19 @@ reschedule:
 	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
 }
 
+struct pci_dev *pci_get_domain_bus_and_slot(int domain, unsigned int bus,
+					    unsigned int devfn)
+{
+	struct pci_dev *dev = NULL;
+
+	while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL) {
+		if (pci_domain_nr(dev->bus) == domain &&
+		    (dev->bus->number == bus && dev->devfn == devfn))
+			return dev;
+	}
+	return NULL;
+}
+
 static int qlcnic_is_first_func(struct pci_dev *pdev)
 {
 	struct pci_dev *oth_pdev;
@@ -2674,16 +2906,16 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 
 	first_func = qlcnic_is_first_func(pdev);
 
-	if (qlcnic_api_lock(adapter))
+	if (ahw->hw_ops->api_lock(adapter))
 		return -EINVAL;
 
 	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC && first_func) {
 		adapter->need_fw_reset = 1;
 		set_bit(__QLCNIC_START_FW, &adapter->state);
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
 		QLCDB(adapter, DRV, "Restarting fw\n");
 	}
-	qlcnic_api_unlock(adapter);
+	ahw->hw_ops->api_unlock(adapter);
 
 	err = adapter->nic_ops->start_firmware(adapter);
 	if (err)
@@ -2692,7 +2924,7 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	qlcnic_clr_drv_state(adapter);
 	kfree(adapter->msix_entries);
 	adapter->msix_entries = NULL;
-	err = ahw->hw_ops->setup_intr(adapter);
+	err = ahw->hw_ops->setup_intr(adapter, 0);
 
 	if (netif_running(netdev)) {
 		err = qlcnic_attach(adapter);
@@ -2757,7 +2989,7 @@ static void qlcnic_io_resume(struct pci_dev *pdev)
 
 	pci_cleanup_aer_uncorrect_error_status(pdev);
 
-	if (QLCRD32(adapter, QLCNIC_CRB_DEV_STATE) == QLCNIC_DEV_READY &&
+	if (QLCRD(adapter, QLCNIC_CRB_DEV_STATE) == QLCNIC_DEV_READY &&
 	    test_and_clear_bit(__QLCNIC_AER, &adapter->state))
 		qlcnic_schedule_work(adapter, qlcnic_fw_poll_work,
 						FW_POLL_DELAY);
@@ -2803,20 +3035,17 @@ qlcnicvf_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 	return -EOPNOTSUPP;
 }
 
-int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val)
+int qlcnic_validate_max_rss(u8 max_hw, u8 val)
 {
-	if (!use_msi_x && !use_msi) {
-		netdev_info(netdev, "no msix or msi support, hence no rss\n");
-		return -EINVAL;
-	}
+	u32 max_allowed = rounddown_pow_of_two(
+				min_t(int, max_hw, num_online_cpus()));
 
-	if ((val > max_hw) || (val <  2) || !is_power_of_2(val)) {
-		netdev_info(netdev, "rss_ring valid range [2 - %x] in "
-			" powers of 2\n", max_hw);
+	if ((val > max_allowed) || (val <  2) || !is_power_of_2(val)) {
+		pr_info("rss_ring valid range [2 - %x] in powers of 2\n",
+								max_allowed);
 		return -EINVAL;
 	}
 	return 0;
-
 }
 
 int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data)
@@ -2832,13 +3061,10 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data)
 		__qlcnic_down(adapter, netdev);
 	qlcnic_detach(adapter);
 	qlcnic_teardown_intr(adapter);
-	kfree(adapter->msix_entries);
-	adapter->msix_entries = NULL;
 
-	if (qlcnic_enable_msix(adapter, data)) {
+	err = adapter->ahw->hw_ops->setup_intr(adapter, data);
+	if (err)
 		netdev_info(netdev, "failed setting max_rss; rss disabled\n");
-		qlcnic_enable_msi_legacy(adapter);
-	}
 
 	if (netif_running(netdev)) {
 		err = qlcnic_attach(adapter);
@@ -2872,12 +3098,12 @@ qlcnic_config_indev_addr(struct qlcnic_adapter *adapter,
 	for_ifa(indev) {
 		switch (event) {
 		case NETDEV_UP:
-			qlcnic_config_ipaddr(adapter,
-					ifa->ifa_address, QLCNIC_IP_UP);
+			adapter->nic_ops->config_ipaddr(adapter,
+				 ifa->ifa_address, QLCNIC_IP_UP);
 			break;
 		case NETDEV_DOWN:
-			qlcnic_config_ipaddr(adapter,
-					ifa->ifa_address, QLCNIC_IP_DOWN);
+			adapter->nic_ops->config_ipaddr(adapter,
+				 ifa->ifa_address, QLCNIC_IP_DOWN);
 			break;
 		default:
 			break;
@@ -2887,7 +3113,7 @@ qlcnic_config_indev_addr(struct qlcnic_adapter *adapter,
 	in_dev_put(indev);
 }
 
-static void
+void
 qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
@@ -2968,10 +3194,12 @@ recheck:
 
 	switch (event) {
 	case NETDEV_UP:
-		qlcnic_config_ipaddr(adapter, ifa->ifa_address, QLCNIC_IP_UP);
+		adapter->nic_ops->config_ipaddr(adapter, ifa->ifa_address,
+						 QLCNIC_IP_UP);
 		break;
 	case NETDEV_DOWN:
-		qlcnic_config_ipaddr(adapter, ifa->ifa_address, QLCNIC_IP_DOWN);
+		adapter->nic_ops->config_ipaddr(adapter, ifa->ifa_address,
+						 QLCNIC_IP_DOWN);
 		break;
 	default:
 		break;
@@ -2989,7 +3217,7 @@ static struct notifier_block qlcnic_inetaddr_cb = {
 	.notifier_call = qlcnic_inetaddr_event,
 };
 #else
-static void
+void
 qlcnic_restore_indev_addr(struct net_device *dev, unsigned long event)
 { }
 #endif
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index a9f8836..c77a016 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -1,5 +1,5 @@
-#include <linux/sysfs.h>
 #include "qlcnic.h"
+#include <linux/sysfs.h>
 
 static ssize_t
 qlcnic_store_bridged_mode(struct device *dev,
@@ -308,14 +308,11 @@ validate_pm_config(struct qlcnic_adapter *adapter,
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
@@ -337,7 +334,7 @@ qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_pm_func_cfg *pm_cfg;
 	u32 id, action, pci_func;
-	int count, rem, i, ret;
+	int count, rem, i, ret, index;
 
 	count	= size / sizeof(struct qlcnic_pm_func_cfg);
 	rem	= size % sizeof(struct qlcnic_pm_func_cfg);
@@ -351,6 +348,7 @@ qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
 		return ret;
 	for (i = 0; i < count; i++) {
 		pci_func = pm_cfg[i].pci_func;
+
 		action = !!pm_cfg[i].action;
 		id = adapter->npars[pci_func].phy_port;
 		ret = qlcnic_config_port_mirroring(adapter, id,
@@ -361,9 +359,10 @@ qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
 
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
@@ -376,16 +375,16 @@ qlcnic_sysfs_read_pm_config(struct file *filp, struct kobject *kobj,
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
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		pci_func = adapter->npars[i].pci_func;
+		pm_cfg[pci_func].action = adapter->npars[i].enable_pm;
+		pm_cfg[pci_func].dest_npar = 0;
+		pm_cfg[pci_func].pci_func = i;
 	}
 	memcpy(buf, &pm_cfg, size);
 
@@ -398,9 +397,10 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 {
 	u32 op_mode;
 	u8 pci_func;
-	int i;
+	int i, ret;
 
-	op_mode = readl(adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE);
+	if (QLCNIC_IS_82XX(adapter))
+		op_mode = readl(adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE);
 
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
@@ -408,13 +408,16 @@ validate_esw_config(struct qlcnic_adapter *adapter,
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
+			}
+
+			if (ret !=  QLCNIC_NON_PRIV_FUNC) {
 				if (esw_cfg[i].mac_anti_spoof != 0)
 					return QL_STATUS_INVALID_PARAM;
 				if (esw_cfg[i].mac_override != 1)
@@ -449,7 +452,8 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 	struct qlcnic_esw_func_cfg *esw_cfg;
 	struct qlcnic_npar_info *npar;
 	int count, rem, i, ret;
-	u8 pci_func, op_mode = 0;
+	int index;
+	u8 op_mode = 0, pci_func;
 
 	count	= size / sizeof(struct qlcnic_esw_func_cfg);
 	rem	= size % sizeof(struct qlcnic_esw_func_cfg);
@@ -493,7 +497,8 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
-		npar = &adapter->npars[pci_func];
+		index = qlcnic_is_valid_nic_func(adapter, pci_func);
+		npar = &adapter->npars[index];
 		switch (esw_cfg[i].op_mode) {
 		case QLCNIC_PORT_DEFAULTS:
 			npar->promisc_mode = esw_cfg[i].promisc_mode;
@@ -521,16 +526,15 @@ qlcnic_sysfs_read_esw_config(struct file *file, struct kobject *kobj,
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
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		pci_func = adapter->npars[i].pci_func;
+		esw_cfg[pci_func].pci_func = pci_func;
+		if (qlcnic_get_eswitch_port_config(adapter, &esw_cfg[pci_func]))
 			return QL_STATUS_INVALID_PARAM;
 	}
 	memcpy(buf, &esw_cfg, size);
@@ -546,11 +550,8 @@ validate_npar_config(struct qlcnic_adapter *adapter,
 
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
@@ -567,7 +568,7 @@ qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_info nic_info;
 	struct qlcnic_npar_func_cfg *np_cfg;
-	int i, count, rem, ret;
+	int i, count, rem, ret, index;
 	u8 pci_func;
 
 	count	= size / sizeof(struct qlcnic_npar_func_cfg);
@@ -582,22 +583,25 @@ qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
 
 	for (i = 0; i < count ; i++) {
 		pci_func = np_cfg[i].pci_func;
-		ret = qlcnic_get_nic_info(adapter, &nic_info, pci_func);
+		ret = adapter->ahw->hw_ops->get_nic_info(adapter,
+						&nic_info, pci_func);
 		if (ret)
 			return ret;
 		nic_info.pci_func = pci_func;
 		nic_info.min_tx_bw = np_cfg[i].min_bw;
 		nic_info.max_tx_bw = np_cfg[i].max_bw;
-		ret = qlcnic_set_nic_info(adapter, &nic_info);
+		ret = adapter->ahw->hw_ops->set_nic_info(adapter, &nic_info);
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
@@ -612,9 +616,10 @@ qlcnic_sysfs_read_npar_config(struct file *file, struct kobject *kobj,
 		return QL_STATUS_INVALID_PARAM;
 
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC ; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
+		if (qlcnic_is_valid_nic_func(adapter, i) < 0)
 			continue;
-		ret = qlcnic_get_nic_info(adapter, &nic_info, i);
+		ret = adapter->ahw->hw_ops->get_nic_info(adapter,
+						&nic_info, i);
 		if (ret)
 			return ret;
 
@@ -748,6 +753,7 @@ qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_pci_func_cfg pci_cfg[QLCNIC_MAX_PCI_FUNC];
 	struct qlcnic_pci_info *pci_info;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int i, ret;
 
 	if (size != sizeof(pci_cfg))
@@ -757,7 +763,7 @@ qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
 	if (!pci_info)
 		return -ENOMEM;
 
-	ret = qlcnic_get_pci_info(adapter, pci_info);
+	ret = ahw->hw_ops->get_pci_info(adapter, pci_info);
 	if (ret) {
 		kfree(pci_info);
 		return ret;
@@ -775,6 +781,7 @@ qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
 	kfree(pci_info);
 	return size;
 }
+
 static struct bin_attribute bin_attr_npar_config = {
 	.attr = {.name = "npar_config", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
@@ -894,3 +901,84 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 	device_remove_bin_file(dev, &bin_attr_pm_config);
 	device_remove_bin_file(dev, &bin_attr_esw_stats);
 }
+
+static int
+qlcnic_sysfs_validate_bar(struct qlcnic_adapter *adapter, loff_t offset,
+	size_t size)
+{
+	size_t bar = 4;
+
+	if (!(adapter->flags & QLCNIC_DIAG_ENABLED))
+		return -EIO;
+
+	if (offset >= QLCNIC_83XX_BAR0_LENGTH || (offset & (bar - 1)) ||
+		(size != bar))
+		return -EINVAL;
+	return 0;
+}
+
+static ssize_t
+qlcnic_sysfs_read_bar(struct file *filp, struct kobject *kobj,
+		struct bin_attribute *attr,
+		char *buf, loff_t offset, size_t size)
+{
+	u32 data;
+	int ret;
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+
+	ret = qlcnic_sysfs_validate_bar(adapter, offset, size);
+	if (ret != 0)
+		return ret;
+
+	mutex_lock(&adapter->ahw->mem_lock);
+	data = readl(adapter->ahw->pci_base0 + offset);
+	mutex_unlock(&adapter->ahw->mem_lock);
+
+	memcpy(buf, &data, size);
+	return size;
+}
+
+static ssize_t
+qlcnic_sysfs_write_bar(struct file *filp, struct kobject *kobj,
+		struct bin_attribute *attr,
+		char *buf, loff_t offset, size_t size)
+{
+	u32 data;
+	int ret;
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+
+	ret = qlcnic_sysfs_validate_bar(adapter, offset, size);
+	if (ret != 0)
+		return ret;
+
+	memcpy(&data, buf, size);
+	mutex_lock(&adapter->ahw->mem_lock);
+	writel(data, adapter->ahw->pci_base0 + offset);
+	mutex_unlock(&adapter->ahw->mem_lock);
+
+	return size;
+}
+
+static struct bin_attribute bin_attr_bar = {
+	.attr = {.name = "membar", .mode = (S_IRUGO | S_IWUSR)},
+	.size = 0,
+	.read = qlcnic_sysfs_read_bar,
+	.write = qlcnic_sysfs_write_bar,
+};
+
+void qlcnic_83xx_add_sysfs(struct qlcnic_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+	qlcnic_create_diag_entries(adapter);
+	if (sysfs_create_bin_file(&dev->kobj, &bin_attr_bar))
+		dev_info(dev, "failed to create mem bar sysfs entry\n");
+}
+
+void qlcnic_83xx_remove_sysfs(struct qlcnic_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+	qlcnic_remove_diag_entries(adapter);
+	sysfs_remove_bin_file(&dev->kobj, &bin_attr_bar);
+}
-- 
1.7.1
