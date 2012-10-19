From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V2 10/20] qlcnic: cleanup unused register interfaces
Date: Fri, 19 Oct 2012 04:37:28 -0400
Message-ID: <1350635858-27549-11-git-send-email-sony.chacko@qlogic.com>
References: <1350635858-27549-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:42637 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757982Ab2JSI42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 04:56:28 -0400
In-Reply-To: <1350635858-27549-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Refactor 82xx driver to support new adapter - Qlogic 83XX CNA
Corrections and clean up of register maps and hardware access routines

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   57 ++-----------------
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    8 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |   56 +-------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |    2 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   20 -------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    6 --
 6 files changed, 10 insertions(+), 139 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 8992f88..8888696 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -33,6 +33,7 @@
 #include <linux/if_vlan.h>
 
 #include "qlcnic_hdr.h"
+#include "qlcnic_hw.h"
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
@@ -47,6 +48,7 @@
 #define _minor(v)	(((v) >> 16) & 0xff)
 #define _build(v)	((v) & 0xffff)
 
+
 /* version in image has weird encoding:
  *  7:0  - major
  * 15:8  - minor
@@ -210,6 +212,7 @@ struct rcv_desc {
 #define QLCNIC_RESPONSE_DESC	0x05
 #define QLCNIC_LRO_DESC  	0x12
 
+
 /* for status field in status_desc */
 #define STATUS_CKSUM_LOOP	0
 #define STATUS_CKSUM_OK		2
@@ -218,11 +221,6 @@ struct rcv_desc {
 #define STATUS_OWNER_HOST	(0x1ULL << 56)
 #define STATUS_OWNER_PHANTOM	(0x2ULL << 56)
 
-/* Status descriptor:
-   0-3 port, 4-7 status, 8-11 type, 12-27 total_length
-   28-43 reference_handle, 44-47 protocol, 48-52 pkt_offset
-   53-55 desc_cnt, 56-57 owner, 58-63 opcode
- */
 #define qlcnic_get_sts_port(sts_data)	\
 	((sts_data) & 0x0F)
 #define qlcnic_get_sts_status(sts_data)	\
@@ -243,7 +241,7 @@ struct rcv_desc {
 	(((sts_data) >> 58) & 0x03F)
 
 #define qlcnic_get_lro_sts_refhandle(sts_data) 	\
-	((sts_data) & 0x0FFFF)
+	((sts_data) & 0x07FFF)
 #define qlcnic_get_lro_sts_length(sts_data)	\
 	(((sts_data) >> 16) & 0x0FFFF)
 #define qlcnic_get_lro_sts_l2_hdr_offset(sts_data)	\
@@ -605,43 +603,6 @@ struct qlcnic_recv_context {
  * the crb QLCNIC_CDRP_CRB_OFFSET.
  */
 #define QLCNIC_CDRP_FORM_CMD(cmd)	(QLCNIC_CDRP_CMD_BIT | (cmd))
-#define QLCNIC_CDRP_IS_CMD(cmd)	(((cmd) & QLCNIC_CDRP_CMD_BIT) != 0)
-
-#define QLCNIC_CDRP_CMD_SUBMIT_CAPABILITIES     0x00000001
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
 
 #define QLCNIC_RCODE_SUCCESS		0
 #define QLCNIC_RCODE_INVALID_ARGS	6
@@ -854,7 +815,7 @@ struct qlcnic_mac_list_s {
  */
 
 #define QLCNIC_C2H_OPCODE_CONFIG_LOOPBACK		0x8f
-#define QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	141
+#define QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	0x8D
 
 #define VPORT_MISS_MODE_DROP		0 /* drop all unmatched */
 #define VPORT_MISS_MODE_ACCEPT_ALL	1 /* accept all packets */
@@ -947,7 +908,7 @@ struct qlcnic_ipaddr {
 
 #define QLCNIC_MSI_ENABLED		0x02
 #define QLCNIC_MSIX_ENABLED		0x04
-#define QLCNIC_LRO_ENABLED		0x08
+#define QLCNIC_LRO_ENABLED		0x01
 #define QLCNIC_LRO_DISABLED		0x00
 #define QLCNIC_BRIDGE_ENABLED       	0X10
 #define QLCNIC_DIAG_ENABLED		0x20
@@ -1063,7 +1024,6 @@ struct qlcnic_adapter {
 	void __iomem	*isr_int_vec;
 
 	struct msix_entry *msix_entries;
-
 	struct delayed_work fw_work;
 
 	struct qlcnic_filter_hash fhash;
@@ -1433,9 +1393,7 @@ struct qlcnic_cmd_args {
 	struct _cdrp_cmd rsp;
 };
 
-int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter);
 int qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config);
-
 int qlcnic_pci_mem_write_2M(struct qlcnic_adapter *, u64 off, u64 data);
 int qlcnic_pci_mem_read_2M(struct qlcnic_adapter *, u64 off, u64 *data);
 void qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *, u64, u64 *);
@@ -1476,7 +1434,6 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
 void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
 void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
-int qlcnic_dump_fw(struct qlcnic_adapter *);
 
 /* Functions from qlcnic_init.c */
 int qlcnic_load_firmware(struct qlcnic_adapter *adapter);
@@ -1504,7 +1461,6 @@ void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter);
 void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *adapter);
 void qlcnic_release_rx_buffers(struct qlcnic_adapter *adapter);
 void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter);
-
 int qlcnic_check_fw_status(struct qlcnic_adapter *adapter);
 void qlcnic_watchdog_task(struct work_struct *work);
 void qlcnic_post_rx_buffers(struct qlcnic_adapter *,
@@ -1522,7 +1478,6 @@ int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
 int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_tx_ring *tx_ring);
-
 /* Functions from qlcnic_ethtool.c */
 int qlcnic_check_loopback_buff(unsigned char *data, u8 mac[]);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 078ee48..af49af6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -134,11 +134,9 @@ static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
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
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index a2635ab..e83b71c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -389,9 +389,6 @@ enum {
 #define QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT (ROMUSB_ROM + 0x0014)
 #define QLCNIC_ROMUSB_ROM_RDATA		(ROMUSB_ROM + 0x0018)
 
-/* Lock IDs for ROM lock */
-#define ROM_LOCK_DRIVER	0x0d417340
-
 /******************************************************************************
 *
 *    Definitions specific to M25P flash
@@ -455,7 +452,6 @@ enum {
 #define QLCNIC_PCI_CRBSPACE	(0x06000000UL)
 #define QLCNIC_PCI_CAMQM	(0x04800000UL)
 #define QLCNIC_PCI_CAMQM_END	(0x04800800UL)
-#define QLCNIC_PCI_2MB_SIZE	(0x00200000UL)
 #define QLCNIC_PCI_CAMQM_2M_BASE	(0x000ff800UL)
 
 #define QLCNIC_CRB_CAM	QLCNIC_PCI_CRB_WINDOW(QLCNIC_HW_PX_MAP_CRB_CAM)
@@ -498,26 +494,6 @@ enum {
 #define TA_CTL_ENABLE	BIT_1
 #define TA_CTL_WRITE	BIT_2
 #define TA_CTL_BUSY	BIT_3
-#define MIU_TEST_AGT_BASE		(0x90)
-
-/*
- *   Register offsets for MN
- */
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
 
 #define QLCNIC_MS_CTRL			0x41000090
 #define QLCNIC_MS_ADDR_LO		0x41000094
@@ -557,9 +533,6 @@ enum {
 
 #define QLCNIC_CAM_RAM_BASE	(QLCNIC_CRB_CAM + 0x02000)
 #define QLCNIC_CAM_RAM(reg)	(QLCNIC_CAM_RAM_BASE + (reg))
-#define QLCNIC_FW_VERSION_MAJOR (QLCNIC_CAM_RAM(0x150))
-#define QLCNIC_FW_VERSION_MINOR (QLCNIC_CAM_RAM(0x154))
-#define QLCNIC_FW_VERSION_SUB	(QLCNIC_CAM_RAM(0x158))
 #define QLCNIC_ROM_LOCK_ID	(QLCNIC_CAM_RAM(0x100))
 #define QLCNIC_PHY_LOCK_ID	(QLCNIC_CAM_RAM(0x120))
 #define QLCNIC_CRB_WIN_LOCK_ID	(QLCNIC_CAM_RAM(0x124))
@@ -573,22 +546,15 @@ enum {
 #define QLCNIC_CDRP_ARG(i)	(QLCNIC_REG(0x18 + ((i) * 4)))
 
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
@@ -677,17 +643,6 @@ enum {
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
 
@@ -706,7 +661,6 @@ enum {
 #define QLCNIC_DEV_NPAR_OPER		1 /* NPAR Operational */
 #define QLCNIC_DEV_NPAR_OPER_TIMEO	30 /* Operational time out */
 
-#define QLC_DEV_CHECK_ACTIVE(VAL, FN)		((VAL) & (1 << (FN * 4)))
 #define QLC_DEV_SET_REF_CNT(VAL, FN)		((VAL) |= (1 << (FN * 4)))
 #define QLC_DEV_CLR_REF_CNT(VAL, FN)		((VAL) &= ~(1 << (FN * 4)))
 #define QLC_DEV_SET_RST_RDY(VAL, FN)		((VAL) |= (1 << (FN * 4)))
@@ -760,16 +714,11 @@ struct qlcnic_legacy_intr_set {
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
 
@@ -777,9 +726,6 @@ struct qlcnic_legacy_intr_set {
 static const u32 FW_DUMP_LEVELS[] = {
 	0x3, 0x7, 0xf, 0x1f, 0x3f, 0x7f, 0xff };
 
-static const u32 MIU_TEST_READ_DATA[] = {
-	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC, };
-
 #define QLCNIC_FW_DUMP_REG1	0x00130060
 #define QLCNIC_FW_DUMP_REG2	0x001e0000
 #define QLCNIC_FLASH_SEM2_LK	0x0013C010
@@ -790,7 +736,7 @@ static const u32 MIU_TEST_READ_DATA[] = {
 enum {
 	QLCNIC_MGMT_FUNC	= 0,
 	QLCNIC_PRIV_FUNC	= 1,
-	QLCNIC_NON_PRIV_FUNC	= 2
+	QLCNIC_NON_PRIV_FUNC    = 2
 };
 
 enum {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 7574a92..b034c91 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -733,7 +733,6 @@ int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 	return rv;
 }
 
-
 #define RSS_HASHTYPE_IP_TCP	0x3
 
 int qlcnic_82xx_config_rss(struct qlcnic_adapter *adapter, int enable)
@@ -873,7 +872,6 @@ int qlcnic_change_mtu(struct net_device *netdev, int mtu)
 	return rc;
 }
 
-
 netdev_features_t qlcnic_fix_features(struct net_device *netdev,
 	netdev_features_t features)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 18d9708..4b2a1de 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1115,26 +1115,6 @@ void qlcnic_82xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
 	writel(consumer, sds_ring->crb_sts_consumer);
 }
 
-void qlcnic_fetch_mac(struct qlcnic_adapter *adapter, u32 off1, u32 off2,
-		      u8 alt_mac, u8 *mac)
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
-
 int qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter,
 			 struct net_device *netdev)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 95b1b80..b06e00e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1941,14 +1941,8 @@ done:
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
 
 	err = qlcnic_attach(adapter);
-- 
1.7.1
