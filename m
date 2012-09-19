From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v1 09/19] qlcnic: cleanup unused register interfaces
Date: Wed, 19 Sep 2012 19:46:03 -0400
Message-ID: <1348098373-20745-10-git-send-email-sony.chacko@qlogic.com>
References: <1348098373-20745-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:13098 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753328Ab2ITAMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 20:12:35 -0400
In-Reply-To: <1348098373-20745-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Refactor 82xx driver to support new adapter - Qlogic 83XX CNA
Corrections and clean up of register maps and hardware access routines

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  105 ++-----------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    9 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |   58 +-----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   15 +---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   20 ----
 7 files changed, 18 insertions(+), 194 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 2bb91b4..900876d 100644
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
@@ -603,43 +601,6 @@ struct qlcnic_recv_context {
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
@@ -852,7 +813,7 @@ struct qlcnic_mac_list_s {
  */
 
 #define QLCNIC_C2H_OPCODE_CONFIG_LOOPBACK		0x8f
-#define QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	141
+#define QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	0x8D
 
 #define VPORT_MISS_MODE_DROP		0 /* drop all unmatched */
 #define VPORT_MISS_MODE_ACCEPT_ALL	1 /* accept all packets */
@@ -945,7 +906,7 @@ struct qlcnic_ipaddr {
 
 #define QLCNIC_MSI_ENABLED		0x02
 #define QLCNIC_MSIX_ENABLED		0x04
-#define QLCNIC_LRO_ENABLED		0x08
+#define QLCNIC_LRO_ENABLED		0x01
 #define QLCNIC_LRO_DISABLED		0x00
 #define QLCNIC_BRIDGE_ENABLED       	0X10
 #define QLCNIC_DIAG_ENABLED		0x20
@@ -1060,7 +1021,6 @@ struct qlcnic_adapter {
 	void __iomem	*isr_int_vec;
 
 	struct msix_entry *msix_entries;
-
 	struct delayed_work fw_work;
 
 	struct qlcnic_filter_hash fhash;
@@ -1247,7 +1207,7 @@ struct qlcnic_mac_statistics {
 	__le64	mac_rx_length_large;
 	__le64	mac_rx_jabber;
 	__le64	mac_rx_dropped;
-	__le64	mac_rx_crc_error;
+	__le64	mac_FCS_error;
 	__le64	mac_align_error;
 } __packed;
 
@@ -1430,9 +1390,7 @@ struct qlcnic_cmd_args {
 	struct _cdrp_cmd rsp;
 };
 
-int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter);
 int qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config);
-
 int qlcnic_pci_mem_write_2M(struct qlcnic_adapter *, u64 off, u64 data);
 int qlcnic_pci_mem_read_2M(struct qlcnic_adapter *, u64 off, u64 *data);
 void qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *, u64, u64 *);
@@ -1472,7 +1430,6 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
 void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
 void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
-int qlcnic_dump_fw(struct qlcnic_adapter *);
 
 /* Functions from qlcnic_init.c */
 int qlcnic_load_firmware(struct qlcnic_adapter *adapter);
@@ -1500,7 +1457,8 @@ void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter);
 void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *adapter);
 void qlcnic_release_rx_buffers(struct qlcnic_adapter *adapter);
 void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter);
-
+struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *,
+				      struct qlcnic_host_rds_ring *, u16, u16);
 int qlcnic_check_fw_status(struct qlcnic_adapter *adapter);
 void qlcnic_watchdog_task(struct work_struct *work);
 void qlcnic_post_rx_buffers(struct qlcnic_adapter *,
@@ -1518,7 +1476,6 @@ int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
 int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_tx_ring *tx_ring);
-
 /* Functions from qlcnic_ethtool.c */
 int qlcnic_check_loopback_buff(unsigned char *data, u8 mac[]);
 
@@ -1529,14 +1486,13 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test);
 netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data);
 int qlcnic_validate_max_rss(struct net_device *netdev, u8, u8);
+
 void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
 
-/* Management functions */
 int qlcnic_poll(struct napi_struct *, int);
 int qlcnic_rx_poll(struct napi_struct *, int);
 void qlcnic_set_vlan_config(struct qlcnic_adapter *,
 			    struct qlcnic_esw_func_cfg *);
-/* functions in qlcnic_sysfs.c */
 int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *);
 
 /*  eSwitch management functions */
@@ -1557,12 +1513,7 @@ int qlcnic_alloc_sds_rings(struct qlcnic_recv_context *, int);
 void qlcnic_free_sds_rings(struct qlcnic_recv_context *);
 void qlcnic_free_tx_rings(struct qlcnic_adapter *);
 int qlcnic_alloc_tx_rings(struct qlcnic_adapter *, struct net_device *);
-
-void qlcnic_fetch_mac(struct qlcnic_adapter *, u32, u32, u8, u8 *);
-int qlcnic_alloc_sds_rings(struct qlcnic_recv_context *, int);
 void qlcnic_free_sds_rings(struct qlcnic_recv_context *);
-void qlcnic_free_tx_rings(struct qlcnic_adapter *);
-int qlcnic_alloc_tx_rings(struct qlcnic_adapter *, struct net_device *);
 
 /*
  * QLOGIC Board information
@@ -1869,42 +1820,8 @@ static inline void qlcnic_enable_int(struct qlcnic_host_sds_ring *sds_ring)
 extern const struct ethtool_ops qlcnic_ethtool_ops;
 extern const struct ethtool_ops qlcnic_ethtool_failed_ops;
 
-#define QLC_TCP_HDR_SIZE            20
-#define QLC_TCP_TS_OPTION_SIZE      12
-#define QLC_TCP_TS_HDR_SIZE         (QLC_TCP_HDR_SIZE + QLC_TCP_TS_OPTION_SIZE)
-
-/* List of PCI device IDs */
-#define PCI_DEVICE_ID_QLOGIC_QLE824X	0x8020
-#define PCI_DEVICE_ID_QLOGIC_QLE834X	0x8030
-#define QLCNIC_82XX_BAR0_LENGTH	0x00200000UL
-#define QLCNIC_83XX_BAR0_LENGTH	0x4000
-
-#define QLCNIC_IS_83XX(adapter)	\
-	(((adapter)->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE834X) ? 1 : 0)
-
-#define QLCNIC_IS_82XX(adapter)	\
-	(((adapter)->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE824X) ? 1 : 0)
-/* Make a handle with reference handle (0:14) and RDS ring
- * number (15).
- */
-#define QLCNIC_MAKE_REF_HANDLE(adapter, handle, ring_id)		\
-	((adapter->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE834X) ?	\
-	((handle) | ((ring_id) << 15)) : handle)
-
-#define QLCNIC_FETCH_RING_ID(handle)			\
-	((handle) >> 63)
-
-#define QLCNIC_ENABLE_INTR(adapter, crb) {		\
-	writel(1, crb);					\
-	if (!QLCNIC_IS_MSI_FAMILY(adapter))		\
-		writel(0xfbff, adapter->tgt_mask_reg);	\
-}
-
-#define QLCNIC_DISABLE_INTR(crb) {			\
-	writel(0, crb);					\
-}
 #define QLCDB(adapter, lvl, _fmt, _args...) do {	\
-	if (NETIF_MSG_##lvl & adapter->ahw->msg_enable)	\
+	if (NETIF_MSG_##lvl & adapter->ahw->msg_enable) \
 		printk(KERN_INFO "%s: %s: " _fmt,	\
 			 dev_name(&adapter->pdev->dev),	\
 			__func__, ##_args);		\
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index ed7ce0e..b90c7d0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -944,7 +944,7 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 				le64_to_cpu(stats->mac_rx_length_large);
 		mac_stats->mac_rx_jabber = le64_to_cpu(stats->mac_rx_jabber);
 		mac_stats->mac_rx_dropped = le64_to_cpu(stats->mac_rx_dropped);
-		mac_stats->mac_rx_crc_error = le64_to_cpu(stats->mac_rx_crc_error);
+		mac_stats->mac_FCS_error = le64_to_cpu(stats->mac_FCS_error);
 	} else {
 		dev_err(&adapter->pdev->dev,
 			"%s: Get mac stats failed, err=%d.\n", __func__, err);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 3c10c97..2ccdc2a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -137,11 +137,9 @@ static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
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
@@ -972,7 +970,6 @@ qlcnic_fill_stats(int *index, u64 *data, void *stats, int type)
 		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_length_large);
 		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_jabber);
 		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_dropped);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_crc_error);
 		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_align_error);
 	} else if (type == QLCNIC_ESW_STATS) {
 		struct __qlcnic_esw_statistics *esw_stats =
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index 85c9ce0..d0a191a 100644
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
@@ -491,33 +487,12 @@ enum {
 #define QLCNIC_NIU_GB_MAC_CONFIG_1(I)		\
 		(QLCNIC_CRB_NIU + 0x30004 + (I)*0x10000)
 
-
 #define TEST_AGT_CTRL	(0x00)
 
 #define TA_CTL_START	BIT_0
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
 
 #define QLCNIC_MS_CTRL     0x41000090
 #define QLCNIC_MS_ADDR_LO  0x41000094
@@ -537,7 +512,6 @@ enum {
 #define QLC_TA_WRITE_START (TA_CTL_START | TA_CTL_ENABLE | TA_CTL_WRITE)
 #define QLC_TA_START_ENABLE (TA_CTL_START | TA_CTL_ENABLE)
 
-
 /* XG Link status */
 #define XG_LINK_UP	0x10
 #define XG_LINK_DOWN	0x20
@@ -557,9 +531,6 @@ enum {
 
 #define QLCNIC_CAM_RAM_BASE	(QLCNIC_CRB_CAM + 0x02000)
 #define QLCNIC_CAM_RAM(reg)	(QLCNIC_CAM_RAM_BASE + (reg))
-#define QLCNIC_FW_VERSION_MAJOR (QLCNIC_CAM_RAM(0x150))
-#define QLCNIC_FW_VERSION_MINOR (QLCNIC_CAM_RAM(0x154))
-#define QLCNIC_FW_VERSION_SUB	(QLCNIC_CAM_RAM(0x158))
 #define QLCNIC_ROM_LOCK_ID	(QLCNIC_CAM_RAM(0x100))
 #define QLCNIC_PHY_LOCK_ID	(QLCNIC_CAM_RAM(0x120))
 #define QLCNIC_CRB_WIN_LOCK_ID	(QLCNIC_CAM_RAM(0x124))
@@ -573,22 +544,15 @@ enum {
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
@@ -677,17 +641,6 @@ enum {
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
 
@@ -706,7 +659,6 @@ enum {
 #define QLCNIC_DEV_NPAR_OPER		1 /* NPAR Operational */
 #define QLCNIC_DEV_NPAR_OPER_TIMEO	30 /* Operational time out */
 
-#define QLC_DEV_CHECK_ACTIVE(VAL, FN)		((VAL) & (1 << (FN * 4)))
 #define QLC_DEV_SET_REF_CNT(VAL, FN)		((VAL) |= (1 << (FN * 4)))
 #define QLC_DEV_CLR_REF_CNT(VAL, FN)		((VAL) &= ~(1 << (FN * 4)))
 #define QLC_DEV_SET_RST_RDY(VAL, FN)		((VAL) |= (1 << (FN * 4)))
@@ -760,16 +712,11 @@ struct qlcnic_legacy_intr_set {
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
 
@@ -777,9 +724,6 @@ struct qlcnic_legacy_intr_set {
 static const u32 FW_DUMP_LEVELS[] = {
 	0x3, 0x7, 0xf, 0x1f, 0x3f, 0x7f, 0xff };
 
-static const u32 MIU_TEST_READ_DATA[] = {
-	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC, };
-
 #define QLCNIC_FW_DUMP_REG1	0x00130060
 #define QLCNIC_FW_DUMP_REG2	0x001e0000
 #define QLCNIC_FLASH_SEM2_LK	0x0013C010
@@ -790,7 +734,7 @@ static const u32 MIU_TEST_READ_DATA[] = {
 enum {
 	QLCNIC_MGMT_FUNC	= 0,
 	QLCNIC_PRIV_FUNC	= 1,
-	QLCNIC_NON_PRIV_FUNC	= 2
+	QLCNIC_NON_PRIV_FUNC    = 2
 };
 
 enum {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 959eb82..ecb0821 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -13,18 +13,6 @@
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
@@ -732,7 +720,6 @@ int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 	return rv;
 }
 
-
 #define RSS_HASHTYPE_IP_TCP	0x3
 
 int qlcnic_82xx_config_rss(struct qlcnic_adapter *adapter, int enable)
@@ -872,7 +859,6 @@ int qlcnic_change_mtu(struct net_device *netdev, int mtu)
 	return rc;
 }
 
-
 netdev_features_t qlcnic_fix_features(struct net_device *netdev,
 	netdev_features_t features)
 {
@@ -1043,6 +1029,7 @@ qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off, int *err)
 	return -1;
 }
 
+
 void __iomem *
 qlcnic_get_ioaddr(struct qlcnic_hardware_context *ahw, u32 offset)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index 0720d00..43ad7bb 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -190,7 +190,6 @@ struct qlcnic_hardware_context;
 struct qlcnic_adapter;
 
 int qlcnic_82xx_start_firmware(struct qlcnic_adapter *);
-u32 qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off, int *);
 int qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *, ulong off, u32 data);
 int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int enable);
 int qlcnic_82xx_nic_set_promisc(struct qlcnic_adapter *adapter, u32);
@@ -222,6 +221,7 @@ int qlcnic_82xx_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
 int qlcnic_82xx_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info*);
 int qlcnic_82xx_alloc_mbx_args(struct qlcnic_cmd_args *,
 			       struct qlcnic_adapter *, u32);
+u32 qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *, ulong, int *);
 int qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *, ulong off, u32 data);
 int qlcnic_82xx_get_board_info(struct qlcnic_adapter *adapter);
 int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
@@ -230,5 +230,4 @@ int qlcnic_82xx_api_lock(struct qlcnic_adapter *);
 void qlcnic_82xx_api_unlock(struct qlcnic_adapter *);
 void qlcnic_82xx_napi_enable(struct qlcnic_adapter *);
 void qlcnic_82xx_napi_disable(struct qlcnic_adapter *);
-
 #endif				/* __QLCNIC_HW_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 0d92dc1..541434f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1172,26 +1172,6 @@ void qlcnic_82xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
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
-- 
1.7.1
