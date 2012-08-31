From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 01/12] qlcnic: Refactoring - template based hardware interface
Date: Fri, 31 Aug 2012 18:36:48 -0400
Message-ID: <1346452619-2129-2-git-send-email-sony.chacko@qlogic.com>
References: <1346452619-2129-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:51875 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755157Ab2HaWxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 18:53:54 -0400
In-Reply-To: <1346452619-2129-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Modify 82xx driver to support new adapter - Qlogic 83XX CNA
Separate adapter specific hardware accesses routines
Create template based hardware interface

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   67 ++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |    4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   32 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |   55 +---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   95 +++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |   36 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  290 +++++++++-----------
 8 files changed, 331 insertions(+), 249 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index eaa1db9..8901a4f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -439,6 +439,8 @@ struct qlcnic_fw_dump {
 	struct	qlcnic_dump_template_hdr *tmpl_hdr;
 };
 
+struct qlcnic_hardware_ops;
+
 /*
  * One hardware_context{} per adapter
  * contains interrupt info as well shared hardware info.
@@ -461,6 +463,8 @@ struct qlcnic_hardware_context {
 
 	u8 beacon_state;
 
+	u32 fw_hal_version;
+	struct qlcnic_hardware_ops *hw_ops;
 	struct qlcnic_nic_intr_coalesce coal;
 	struct qlcnic_fw_dump fw_dump;
 };
@@ -552,8 +556,9 @@ struct qlcnic_recv_context {
 /* HW context creation */
 
 #define QLCNIC_OS_CRB_RETRY_COUNT	4000
-#define QLCNIC_CDRP_SIGNATURE_MAKE(pcifn, version) \
-	(((pcifn) & 0xff) | (((version) & 0xff) << 8) | (0xcafe << 16))
+#define QLCNIC_CDRP_SIGNATURE_MAKE(ahw)					\
+	(((ahw->pci_func) & 0xff) | (((ahw->fw_hal_version) &		\
+	0xff) << 8) | (0xcafe << 16))
 
 #define QLCNIC_CDRP_CMD_BIT		0x80000000
 
@@ -573,9 +578,7 @@ struct qlcnic_recv_context {
  * the crb QLCNIC_CDRP_CRB_OFFSET.
  */
 #define QLCNIC_CDRP_FORM_CMD(cmd)	(QLCNIC_CDRP_CMD_BIT | (cmd))
-#define QLCNIC_CDRP_IS_CMD(cmd)	(((cmd) & QLCNIC_CDRP_CMD_BIT) != 0)
 
-#define QLCNIC_CDRP_CMD_SUBMIT_CAPABILITIES     0x00000001
 #define QLCNIC_CDRP_CMD_READ_MAX_RDS_PER_CTX    0x00000002
 #define QLCNIC_CDRP_CMD_READ_MAX_SDS_PER_CTX    0x00000003
 #define QLCNIC_CDRP_CMD_READ_MAX_RULES_PER_CTX  0x00000004
@@ -1022,7 +1025,6 @@ struct qlcnic_adapter {
 	u16 max_mtu;
 	u16 pvid;
 
-	u32 fw_hal_version;
 	u32 capabilities;
 	u32 irq;
 	u32 temp;
@@ -1443,9 +1445,9 @@ void qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *, u64, u64);
 	(((addr) < (high)) && ((addr) >= (low)))
 
 #define QLCRD32(adapter, off) \
-	(qlcnic_hw_read_wx_2M(adapter, off))
+	adapter->ahw->hw_ops->read_reg(adapter, off)
 #define QLCWR32(adapter, off, val) \
-	(qlcnic_hw_write_wx_2M(adapter, off, val))
+	adapter->ahw->hw_ops->write_reg(adapter, off, val)
 
 int qlcnic_pcie_sem_lock(struct qlcnic_adapter *, int, u32);
 void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
@@ -1476,10 +1478,10 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 
 int qlcnic_get_board_info(struct qlcnic_adapter *adapter);
 int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
-int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
 void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
 void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
 int qlcnic_dump_fw(struct qlcnic_adapter *);
+void qlcnic_get_ocm_win(struct qlcnic_hardware_context *);
 
 /* Functions from qlcnic_init.c */
 int qlcnic_load_firmware(struct qlcnic_adapter *adapter);
@@ -1496,7 +1498,7 @@ int qlcnic_rom_fast_read_words(struct qlcnic_adapter *adapter, int addr,
 int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter);
 void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter);
 
-void __iomem *qlcnic_get_ioaddr(struct qlcnic_adapter *, u32);
+void __iomem *qlcnic_get_ioaddr(struct qlcnic_hardware_context *, u32);
 
 int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter);
 void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter);
@@ -1528,7 +1530,6 @@ netdev_features_t qlcnic_fix_features(struct net_device *netdev,
 	netdev_features_t features);
 int qlcnic_set_features(struct net_device *netdev, netdev_features_t features);
 int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable);
-int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
 int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_tx_ring *tx_ring);
@@ -1551,6 +1552,8 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data);
 void qlcnic_dev_request_reset(struct qlcnic_adapter *);
 void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
 
+int qlcnic_setup_intr(struct qlcnic_adapter *);
+
 /* Management functions */
 int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
 int qlcnic_get_nic_info(struct qlcnic_adapter *, struct qlcnic_info *, u8);
@@ -1626,6 +1629,50 @@ struct qlcnic_nic_template {
 	int (*start_firmware) (struct qlcnic_adapter *);
 };
 
+/* function template for hardware ops based on different chip type */
+struct qlcnic_hardware_ops {
+	void (*read_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
+	void (*write_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
+	u32 (*read_reg) (struct qlcnic_adapter *, ulong);
+	int (*write_reg) (struct qlcnic_adapter *, ulong, u32);
+	void (*get_ocm_win) (struct qlcnic_hardware_context *);
+	int (*get_mac_address) (struct qlcnic_adapter *, u8 *);
+	int (*setup_intr) (struct qlcnic_adapter *);
+	void (*mbx_cmd) (struct qlcnic_adapter *, struct qlcnic_cmd_args *);
+};
+
+static inline void
+qlcnic_read_crb(struct qlcnic_adapter *adapter, char *buf,
+						loff_t offset, size_t size)
+{
+	adapter->ahw->hw_ops->read_crb(adapter, buf, offset, size);
+}
+
+static inline void
+qlcnic_write_crb(struct qlcnic_adapter *adapter, char *buf,
+						loff_t offset, size_t size)
+{
+	adapter->ahw->hw_ops->write_crb(adapter, buf, offset, size);
+}
+
+static inline int
+qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
+{
+	return adapter->nic_ops->config_bridged_mode(adapter, enable);
+}
+
+static inline int
+qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
+{
+	return adapter->nic_ops->config_led(adapter, state, rate);
+}
+
+static inline int
+qlcnic_start_firmware(struct qlcnic_adapter *adapter)
+{
+	return adapter->nic_ops->start_firmware(adapter);
+}
+
 #define QLCDB(adapter, lvl, _fmt, _args...) do {	\
 	if (NETIF_MSG_##lvl & adapter->msg_enable)	\
 		printk(KERN_INFO "%s: %s: " _fmt,	\
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index b8ead69..77df8c7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -6,6 +6,7 @@
  */
 
 #include "qlcnic.h"
+#include "qlcnic_hw.h"
 
 static u32
 qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
@@ -34,8 +35,7 @@ qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
 	struct pci_dev *pdev = adapter->pdev;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	signature = QLCNIC_CDRP_SIGNATURE_MAKE(ahw->pci_func,
-		adapter->fw_hal_version);
+	signature = QLCNIC_CDRP_SIGNATURE_MAKE(ahw);
 
 	/* Acquire semaphore before accessing CRB */
 	if (qlcnic_api_lock(adapter)) {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 9e9e78a..c81fcf8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -13,6 +13,7 @@
 #include <linux/ethtool.h>
 
 #include "qlcnic.h"
+#include "qlcnic_hw.h"
 
 struct qlcnic_stats {
 	char stat_string[ETH_GSTRING_LEN];
@@ -192,10 +193,11 @@ static int
 qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int check_sfp_module = 0;
 
 	/* read which mode */
-	if (adapter->ahw->port_type == QLCNIC_GBE) {
+	if (ahw->port_type == QLCNIC_GBE) {
 		ecmd->supported = (SUPPORTED_10baseT_Half |
 				   SUPPORTED_10baseT_Full |
 				   SUPPORTED_100baseT_Half |
@@ -212,7 +214,7 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		ecmd->duplex = adapter->link_duplex;
 		ecmd->autoneg = adapter->link_autoneg;
 
-	} else if (adapter->ahw->port_type == QLCNIC_XGBE) {
+	} else if (ahw->port_type == QLCNIC_XGBE) {
 		u32 val;
 
 		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR);
@@ -241,7 +243,7 @@ skip:
 	ecmd->phy_address = adapter->physical_port;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
-	switch (adapter->ahw->board_type) {
+	switch (ahw->board_type) {
 	case QLCNIC_BRDTYPE_P3P_REF_QG:
 	case QLCNIC_BRDTYPE_P3P_4_GB:
 	case QLCNIC_BRDTYPE_P3P_4_GB_MM:
@@ -278,7 +280,7 @@ skip:
 		ecmd->autoneg = AUTONEG_DISABLE;
 		break;
 	case QLCNIC_BRDTYPE_P3P_10G_TP:
-		if (adapter->ahw->port_type == QLCNIC_XGBE) {
+		if (ahw->port_type == QLCNIC_XGBE) {
 			ecmd->autoneg = AUTONEG_DISABLE;
 			ecmd->supported |= (SUPPORTED_FIBRE | SUPPORTED_TP);
 			ecmd->advertising |=
@@ -296,7 +298,7 @@ skip:
 		break;
 	default:
 		dev_err(&adapter->pdev->dev, "Unsupported board model %d\n",
-			adapter->ahw->board_type);
+			ahw->board_type);
 		return -EIO;
 	}
 
@@ -376,12 +378,13 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 *regs_buff = p;
 	int ring, i = 0, j = 0;
 
 	memset(p, 0, qlcnic_get_regs_len(dev));
 	regs->version = (QLCNIC_ETHTOOL_REGS_VER << 24) |
-		(adapter->ahw->revision_id << 16) | (adapter->pdev)->device;
+		(ahw->revision_id << 16) | (adapter->pdev)->device;
 
 	regs_buff[0] = (0xcafe0000 | (QLCNIC_DEV_INFO_SIZE & 0xffff));
 	regs_buff[1] = QLCNIC_MGMT_API_VERSION;
@@ -543,10 +546,11 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 			  struct ethtool_pauseparam *pause)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int port = adapter->physical_port;
 	__u32 val;
 
-	if (adapter->ahw->port_type == QLCNIC_GBE) {
+	if (ahw->port_type == QLCNIC_GBE) {
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return;
 		/* get flow control settings */
@@ -568,7 +572,7 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 			pause->tx_pause = !(qlcnic_gb_get_gb3_mask(val));
 			break;
 		}
-	} else if (adapter->ahw->port_type == QLCNIC_XGBE) {
+	} else if (ahw->port_type == QLCNIC_XGBE) {
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_XG_PORTS))
 			return;
 		pause->rx_pause = 1;
@@ -588,11 +592,12 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 			  struct ethtool_pauseparam *pause)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int port = adapter->physical_port;
 	__u32 val;
 
 	/* read mode */
-	if (adapter->ahw->port_type == QLCNIC_GBE) {
+	if (ahw->port_type == QLCNIC_GBE) {
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return -EIO;
 		/* set flow control */
@@ -603,8 +608,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		else
 			qlcnic_gb_unset_rx_flowctl(val);
 
-		QLCWR32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port),
-				val);
+		QLCWR32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), val);
 		/* set autoneg */
 		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL);
 		switch (port) {
@@ -635,7 +639,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 			break;
 		}
 		QLCWR32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, val);
-	} else if (adapter->ahw->port_type == QLCNIC_XGBE) {
+	} else if (ahw->port_type == QLCNIC_XGBE) {
 		if (!pause->rx_pause || pause->autoneg)
 			return -EOPNOTSUPP;
 
@@ -1048,7 +1052,7 @@ static int qlcnic_set_led(struct net_device *dev,
 			set_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state);
 		}
 
-		if (adapter->nic_ops->config_led(adapter, 1, 0xf) == 0) {
+		if (qlcnic_config_led(adapter, 1, 0xf) == 0) {
 			err = 0;
 			break;
 		}
@@ -1069,7 +1073,7 @@ static int qlcnic_set_led(struct net_device *dev,
 			set_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state);
 		}
 
-		if (adapter->nic_ops->config_led(adapter, 0, 0xf))
+		if (qlcnic_config_led(adapter, 0, 0xf))
 			dev_err(&adapter->pdev->dev,
 				"Failed to reset LED blink state.\n");
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index 28a6b28..0bee9f7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -449,13 +449,10 @@ enum {
 #define ISR_INT_TARGET_STATUS_F7   (QLCNIC_PCIX_PS_REG(PCIX_TARGET_STATUS_F7))
 #define ISR_INT_TARGET_MASK_F7     (QLCNIC_PCIX_PS_REG(PCIX_TARGET_MASK_F7))
 
-#define QLCNIC_PCI_MN_2M	(0)
-#define QLCNIC_PCI_MS_2M	(0x80000)
 #define QLCNIC_PCI_OCM0_2M	(0x000c0000UL)
 #define QLCNIC_PCI_CRBSPACE	(0x06000000UL)
 #define QLCNIC_PCI_CAMQM	(0x04800000UL)
 #define QLCNIC_PCI_CAMQM_END	(0x04800800UL)
-#define QLCNIC_PCI_2MB_SIZE	(0x00200000UL)
 #define QLCNIC_PCI_CAMQM_2M_BASE	(0x000ff800UL)
 
 #define QLCNIC_CRB_CAM	QLCNIC_PCI_CRB_WINDOW(QLCNIC_HW_PX_MAP_CRB_CAM)
@@ -520,23 +517,6 @@ enum {
 #define MIU_TEST_AGT_ADDR_MASK		0xfffffff8
 #define MIU_TEST_AGT_UPPER_ADDR(off)	(0)
 
-/*
- *   Register offsets for MS
- */
-#define SIU_TEST_AGT_BASE		(0x60)
-
-#define SIU_TEST_AGT_ADDR_LO		(0x04)
-#define SIU_TEST_AGT_ADDR_HI		(0x18)
-#define SIU_TEST_AGT_WRDATA_LO		(0x08)
-#define SIU_TEST_AGT_WRDATA_HI		(0x0c)
-#define SIU_TEST_AGT_WRDATA(i)		(0x08+(4*(i)))
-#define SIU_TEST_AGT_RDDATA_LO		(0x10)
-#define SIU_TEST_AGT_RDDATA_HI		(0x14)
-#define SIU_TEST_AGT_RDDATA(i)		(0x10+(4*(i)))
-
-#define SIU_TEST_AGT_ADDR_MASK		0x3ffff8
-#define SIU_TEST_AGT_UPPER_ADDR(off)	((off)>>22)
-
 /* XG Link status */
 #define XG_LINK_UP	0x10
 #define XG_LINK_DOWN	0x20
@@ -579,17 +559,13 @@ enum {
 
 #define CRB_XG_STATE_P3P		(QLCNIC_REG(0x98))
 #define CRB_PF_LINK_SPEED_1		(QLCNIC_REG(0xe8))
-#define CRB_PF_LINK_SPEED_2		(QLCNIC_REG(0xec))
 
 #define CRB_TEMP_STATE			(QLCNIC_REG(0x1b4))
 
-#define CRB_V2P_0			(QLCNIC_REG(0x290))
-#define CRB_V2P(port)			(CRB_V2P_0+((port)*4))
 #define CRB_DRIVER_VERSION		(QLCNIC_REG(0x2a0))
 
 #define CRB_FW_CAPABILITIES_1		(QLCNIC_CAM_RAM(0x128))
 #define CRB_FW_CAPABILITIES_2		(QLCNIC_CAM_RAM(0x12c))
-#define CRB_MAC_BLOCK_START		(QLCNIC_CAM_RAM(0x1c0))
 
 /*
  * CrbPortPhanCntrHi/Lo is used to pass the address of HostPhantomIndex address
@@ -616,11 +592,6 @@ enum {
 /* Lock IDs for PHY lock */
 #define PHY_LOCK_DRIVER		0x44524956
 
-/* Used for PS PCI Memory access */
-#define PCIX_PS_OP_ADDR_LO	(0x10000)
-/*   via CRB  (PS side only)     */
-#define PCIX_PS_OP_ADDR_HI	(0x10004)
-
 #define PCIX_INT_VECTOR 	(0x10100)
 #define PCIX_INT_MASK		(0x10104)
 
@@ -763,7 +734,6 @@ struct qlcnic_legacy_intr_set {
 	u32	int_vec_bit;
 	u32	tgt_status_reg;
 	u32	tgt_mask_reg;
-	u32	pci_int_reg;
 };
 
 #define QLCNIC_FW_API		0x1b216c
@@ -837,50 +807,42 @@ enum {
 	{								\
 		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F0,		\
 		.tgt_status_reg	=	ISR_INT_TARGET_STATUS,		\
-		.tgt_mask_reg	=	ISR_INT_TARGET_MASK,		\
-		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(0) },	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK, },		\
 									\
 	{								\
 		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F1,		\
 		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F1,	\
-		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F1,		\
-		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(1) },	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F1, },	\
 									\
 	{								\
 		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F2,		\
 		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F2,	\
-		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F2,		\
-		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(2) },	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F2, },	\
 									\
 	{								\
 		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F3,		\
 		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F3,	\
-		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F3,		\
-		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(3) },	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F3, },	\
 									\
 	{								\
 		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F4,		\
 		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F4,	\
-		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F4,		\
-		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(4) },	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F4, },	\
 									\
 	{								\
 		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F5,		\
 		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F5,	\
-		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F5,		\
-		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(5) },	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F5, },	\
 									\
 	{								\
 		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F6,		\
 		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F6,	\
-		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F6,		\
-		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(6) },	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F6, },	\
 									\
 	{								\
 		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F7,		\
 		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F7,	\
-		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F7,		\
-		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(7) },	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F7, },	\
 }
 
 /* NIU REGS */
@@ -1031,4 +993,5 @@ struct crb_128M_2M_sub_block_map {
 struct crb_128M_2M_block_map{
 	struct crb_128M_2M_sub_block_map sub_block[16];
 };
+
 #endif				/* __QLCNIC_HDR_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index b528e52..a56621c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -6,6 +6,8 @@
  */
 
 #include "qlcnic.h"
+#include "qlcnic_hdr.h"
+#include "qlcnic_hw.h"
 
 #include <linux/slab.h>
 #include <net/ip.h>
@@ -266,6 +268,13 @@ static const unsigned crb_hub_agt[64] = {
 	0,
 };
 
+static const u32 msi_tgt_status[8] = {
+	ISR_INT_TARGET_STATUS, ISR_INT_TARGET_STATUS_F1,
+	ISR_INT_TARGET_STATUS_F2, ISR_INT_TARGET_STATUS_F3,
+	ISR_INT_TARGET_STATUS_F4, ISR_INT_TARGET_STATUS_F5,
+	ISR_INT_TARGET_STATUS_F6, ISR_INT_TARGET_STATUS_F7
+};
+
 /*  PCI Windowing for DDR regions.  */
 
 #define QLCNIC_PCIE_SEM_TIMEOUT	10000
@@ -644,7 +653,7 @@ int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
 	return rv;
 }
 
-int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
+int qlcnic_82xx_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 {
 	struct qlcnic_nic_req req;
 	u64 word;
@@ -864,7 +873,7 @@ int qlcnic_set_features(struct net_device *netdev, netdev_features_t features)
  * In: 'off' is offset from base in 128M pci map
  */
 static int
-qlcnic_pci_get_crb_addr_2M(struct qlcnic_adapter *adapter,
+qlcnic_pci_get_crb_addr_2M(struct qlcnic_hardware_context *ahw,
 		ulong off, void __iomem **addr)
 {
 	const struct crb_128M_2M_sub_block_map *m;
@@ -880,7 +889,7 @@ qlcnic_pci_get_crb_addr_2M(struct qlcnic_adapter *adapter,
 	m = &crb_128M_2M_map[CRB_BLK(off)].sub_block[CRB_SUBBLK(off)];
 
 	if (m->valid && (m->start_128M <= off) && (m->end_128M > off)) {
-		*addr = adapter->ahw->pci_base0 + m->start_2M +
+		*addr = ahw->pci_base0 + m->start_2M +
 			(off - m->start_128M);
 		return 0;
 	}
@@ -888,7 +897,7 @@ qlcnic_pci_get_crb_addr_2M(struct qlcnic_adapter *adapter,
 	/*
 	 * Not in direct map, use crb window
 	 */
-	*addr = adapter->ahw->pci_base0 + CRB_INDIRECT_2M + (off & MASK(16));
+	*addr = ahw->pci_base0 + CRB_INDIRECT_2M + (off & MASK(16));
 	return 1;
 }
 
@@ -929,7 +938,7 @@ qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
 	int rv;
 	void __iomem *addr = NULL;
 
-	rv = qlcnic_pci_get_crb_addr_2M(adapter, off, &addr);
+	rv = qlcnic_pci_get_crb_addr_2M(adapter->ahw, off, &addr);
 
 	if (rv == 0) {
 		writel(data, addr);
@@ -962,7 +971,7 @@ qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
 	u32 data = -1;
 	void __iomem *addr = NULL;
 
-	rv = qlcnic_pci_get_crb_addr_2M(adapter, off, &addr);
+	rv = qlcnic_pci_get_crb_addr_2M(adapter->ahw, off, &addr);
 
 	if (rv == 0)
 		return readl(addr);
@@ -986,11 +995,11 @@ qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
 
 
 void __iomem *
-qlcnic_get_ioaddr(struct qlcnic_adapter *adapter, u32 offset)
+qlcnic_get_ioaddr(struct qlcnic_hardware_context *ahw, u32 offset)
 {
 	void __iomem *addr = NULL;
 
-	WARN_ON(qlcnic_pci_get_crb_addr_2M(adapter, offset, &addr));
+	WARN_ON(qlcnic_pci_get_crb_addr_2M(ahw, offset, &addr));
 
 	return addr;
 }
@@ -1078,13 +1087,13 @@ qlcnic_pci_mem_write_2M(struct qlcnic_adapter *adapter,
 	/* P3 onward, test agent base for MIU and SIU is same */
 	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
 				QLCNIC_ADDR_QDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter,
+		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
 				QLCNIC_CRB_QDR_NET+MIU_TEST_AGT_BASE);
 		goto correct;
 	}
 
 	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET, QLCNIC_ADDR_DDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter,
+		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
 				QLCNIC_CRB_DDR_NET+MIU_TEST_AGT_BASE);
 		goto correct;
 	}
@@ -1170,13 +1179,13 @@ qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter,
 	/* P3 onward, test agent base for MIU and SIU is same */
 	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
 				QLCNIC_ADDR_QDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter,
+		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
 				QLCNIC_CRB_QDR_NET+MIU_TEST_AGT_BASE);
 		goto correct;
 	}
 
 	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET, QLCNIC_ADDR_DDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter,
+		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
 				QLCNIC_CRB_DDR_NET+MIU_TEST_AGT_BASE);
 		goto correct;
 	}
@@ -1230,6 +1239,7 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 {
 	int offset, board_type, magic;
 	struct pci_dev *pdev = adapter->pdev;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	offset = QLCNIC_FW_MAGIC_OFFSET;
 	if (qlcnic_rom_fast_read(adapter, offset, &magic))
@@ -1245,7 +1255,7 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 	if (qlcnic_rom_fast_read(adapter, offset, &board_type))
 		return -EIO;
 
-	adapter->ahw->board_type = board_type;
+	ahw->board_type = board_type;
 
 	if (board_type == QLCNIC_BRDTYPE_P3P_4_GB_MM) {
 		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I);
@@ -1264,20 +1274,20 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 	case QLCNIC_BRDTYPE_P3P_10G_SFP_QT:
 	case QLCNIC_BRDTYPE_P3P_10G_XFP:
 	case QLCNIC_BRDTYPE_P3P_10000_BASE_T:
-		adapter->ahw->port_type = QLCNIC_XGBE;
+		ahw->port_type = QLCNIC_XGBE;
 		break;
 	case QLCNIC_BRDTYPE_P3P_REF_QG:
 	case QLCNIC_BRDTYPE_P3P_4_GB:
 	case QLCNIC_BRDTYPE_P3P_4_GB_MM:
-		adapter->ahw->port_type = QLCNIC_GBE;
+		ahw->port_type = QLCNIC_GBE;
 		break;
 	case QLCNIC_BRDTYPE_P3P_10G_TP:
-		adapter->ahw->port_type = (adapter->portnum < 2) ?
+		ahw->port_type = (adapter->portnum < 2) ?
 			QLCNIC_XGBE : QLCNIC_GBE;
 		break;
 	default:
 		dev_err(&pdev->dev, "unknown board type %x\n", board_type);
-		adapter->ahw->port_type = QLCNIC_XGBE;
+		ahw->port_type = QLCNIC_XGBE;
 		break;
 	}
 
@@ -1299,7 +1309,7 @@ qlcnic_wol_supported(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
-int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
+int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 {
 	struct qlcnic_nic_req   req;
 	int rv;
@@ -1786,3 +1796,52 @@ error:
 	vfree(fw_dump->data);
 	return -EINVAL;
 }
+
+void qlcnic_get_func_no(struct qlcnic_adapter *adapter)
+{
+	void __iomem *msix_base_addr;
+	u32 func;
+	u32 msix_base;
+
+	pci_read_config_dword(adapter->pdev, QLCNIC_MSIX_TABLE_OFFSET, &func);
+	msix_base_addr = adapter->ahw->pci_base0 + QLCNIC_MSIX_BASE;
+	msix_base = readl(msix_base_addr);
+	func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
+	adapter->ahw->pci_func = func;
+}
+
+void qlcnic_get_ocm_win(struct qlcnic_hardware_context *ahw)
+{
+	ahw->ocm_win_crb = qlcnic_get_ioaddr(ahw, QLCNIC_PCIX_PS_REG(
+				PCIX_OCM_WINDOW_REG(ahw->pci_func)));
+}
+
+void qlcnic_82xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
+	loff_t offset, size_t size)
+{
+	u32 data;
+	u64 qmdata;
+
+	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
+		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
+		memcpy(buf, &qmdata, size);
+	} else {
+		data = QLCRD32(adapter, offset);
+		memcpy(buf, &data, size);
+	}
+}
+
+void qlcnic_82xx_write_crb(struct qlcnic_adapter *adapter, char *buf,
+	loff_t offset, size_t size)
+{
+	u32 data;
+	u64 qmdata;
+
+	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
+		memcpy(&qmdata, buf, size);
+		qlcnic_pci_camqm_write_2M(adapter, offset, qmdata);
+	} else {
+		memcpy(&data, buf, size);
+		QLCWR32(adapter, offset, data);
+	}
+}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
new file mode 100644
index 0000000..7dab9e2
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -0,0 +1,36 @@
+#ifndef __QLCNIC_HW_H
+#define __QLCNIC_HW_H
+
+#include "qlcnic.h"
+
+/* List of PCI device IDs */
+#define PCI_DEVICE_ID_QLOGIC_QLE824X  0x8020
+#define QLCNIC_P3P_BAR0_LENGTH		0x00200000UL
+
+#define QLCNIC_BAR_LENGTH(dev_id, bar)			\
+do {							\
+	if (dev_id == PCI_DEVICE_ID_QLOGIC_QLE824X)\
+		*bar = QLCNIC_P3P_BAR0_LENGTH;		\
+	else						\
+		*bar = 0;				\
+} while (0)
+
+#define QLCNIC_ENABLE_INTR(adapter, crb) {		\
+	writel(1, crb);					\
+	if (!QLCNIC_IS_MSI_FAMILY(adapter))		\
+		writel(0xfbff, adapter->tgt_mask_reg);	\
+}
+
+#define QLCNIC_DISABLE_INTR(crb) {			\
+	writel(0, crb);					\
+}
+
+
+
+void qlcnic_82xx_write_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
+void qlcnic_82xx_read_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
+int qlcnic_82xx_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
+int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
+int qlcnic_82xx_start_firmware(struct qlcnic_adapter *);
+
+#endif				/* __QLCNIC_HW_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 0bcda9c..350bf79 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -10,6 +10,7 @@
 #include <linux/slab.h>
 #include <linux/if_vlan.h>
 #include "qlcnic.h"
+#include "qlcnic_hw.h"
 
 struct crb_addr_pair {
 	u32 addr;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 212c121..1c0443e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -10,6 +10,7 @@
 #include <linux/interrupt.h>
 
 #include "qlcnic.h"
+#include "qlcnic_hw.h"
 
 #include <linux/swab.h>
 #include <linux/dma-mapping.h>
@@ -88,7 +89,6 @@ static irqreturn_t qlcnic_msix_intr(int irq, void *data);
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev);
 static void qlcnic_restore_indev_addr(struct net_device *dev, unsigned long);
-static int qlcnic_start_firmware(struct qlcnic_adapter *);
 
 static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter);
 static void qlcnic_dev_set_npar_ready(struct qlcnic_adapter *);
@@ -105,8 +105,6 @@ static int qlcnic_vlan_rx_del(struct net_device *, u16);
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
 	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
 
-#define PCI_DEVICE_ID_QLOGIC_QLE824X  0x8020
-
 static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE824X),
 	{0,}
@@ -240,35 +238,6 @@ qlcnic_napi_disable(struct qlcnic_adapter *adapter)
 	}
 }
 
-static void qlcnic_clear_stats(struct qlcnic_adapter *adapter)
-{
-	memset(&adapter->stats, 0, sizeof(adapter->stats));
-}
-
-static void qlcnic_set_msix_bit(struct pci_dev *pdev, int enable)
-{
-	u32 control;
-	int pos;
-
-	pos = pci_find_capability(pdev, PCI_CAP_ID_MSIX);
-	if (pos) {
-		pci_read_config_dword(pdev, pos, &control);
-		if (enable)
-			control |= PCI_MSIX_FLAGS_ENABLE;
-		else
-			control = 0;
-		pci_write_config_dword(pdev, pos, control);
-	}
-}
-
-static void qlcnic_init_msix_entries(struct qlcnic_adapter *adapter, int count)
-{
-	int i;
-
-	for (i = 0; i < count; i++)
-		adapter->msix_entries[i].entry = i;
-}
-
 static int
 qlcnic_read_mac_addr(struct qlcnic_adapter *adapter)
 {
@@ -343,9 +312,9 @@ static const struct net_device_ops qlcnic_netdev_failed_ops = {
 };
 
 static struct qlcnic_nic_template qlcnic_ops = {
-	.config_bridged_mode = qlcnic_config_bridged_mode,
-	.config_led = qlcnic_config_led,
-	.start_firmware = qlcnic_start_firmware
+	.config_bridged_mode = qlcnic_82xx_config_bridged_mode,
+	.config_led = qlcnic_82xx_config_led,
+	.start_firmware = qlcnic_82xx_start_firmware
 };
 
 static struct qlcnic_nic_template qlcnic_vf_ops = {
@@ -354,38 +323,58 @@ static struct qlcnic_nic_template qlcnic_vf_ops = {
 	.start_firmware = qlcnicvf_start_firmware
 };
 
+static struct qlcnic_hardware_ops qlcnic_82xx_ops = {
+	.read_crb = qlcnic_82xx_read_crb,
+	.write_crb = qlcnic_82xx_write_crb,
+	.read_reg = qlcnic_hw_read_wx_2M,
+	.write_reg = qlcnic_hw_write_wx_2M,
+	.get_mac_address = qlcnic_get_mac_address,
+	.setup_intr = qlcnic_setup_intr,
+	.mbx_cmd = qlcnic_issue_cmd,
+};
+
 static int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 {
 	struct pci_dev *pdev = adapter->pdev;
-	int err = -1;
+	int err = -1, i;
+
+	if (!adapter->msix_entries) {
+		adapter->msix_entries = kcalloc(num_msix,
+					sizeof(struct msix_entry), GFP_KERNEL);
+		if (!adapter->msix_entries) {
+			dev_err(&pdev->dev, "failed allocating msix_entries\n");
+			return -ENOMEM;
+		}
+	}
 
 	adapter->max_sds_rings = 1;
 	adapter->flags &= ~(QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED);
-	qlcnic_set_msix_bit(pdev, 0);
 
 	if (adapter->msix_supported) {
  enable_msix:
-		qlcnic_init_msix_entries(adapter, num_msix);
+		for (i = 0; i < num_msix; i++)
+			adapter->msix_entries[i].entry = i;
+
 		err = pci_enable_msix(pdev, adapter->msix_entries, num_msix);
 		if (err == 0) {
 			adapter->flags |= QLCNIC_MSIX_ENABLED;
-			qlcnic_set_msix_bit(pdev, 1);
-
 			adapter->max_sds_rings = num_msix;
 
 			dev_info(&pdev->dev, "using msi-x interrupts\n");
 			return err;
-		}
-		if (err > 0) {
+		} else if (err > 0) {
 			num_msix = rounddown_pow_of_two(err);
-			if (num_msix)
+			if (num_msix) {
+				dev_info(&pdev->dev,
+				"Can't get %d vectors,trying %d vectors\n",
+								err, num_msix);
 				goto enable_msix;
+			}
 		}
 	}
 	return err;
 }
 
-
 static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 {
 	const struct qlcnic_legacy_intr_set *legacy_intrp;
@@ -393,7 +382,7 @@ static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 
 	if (use_msi && !pci_enable_msi(pdev)) {
 		adapter->flags |= QLCNIC_MSI_ENABLED;
-		adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter,
+		adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter->ahw,
 				msi_tgt_status[adapter->ahw->pci_func]);
 		dev_info(&pdev->dev, "using msi interrupts\n");
 		adapter->msix_entries[0].vector = pdev->irq;
@@ -403,33 +392,35 @@ static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 	legacy_intrp = &legacy_intr[adapter->ahw->pci_func];
 
 	adapter->int_vec_bit = legacy_intrp->int_vec_bit;
-	adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter,
+	adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter->ahw,
 			legacy_intrp->tgt_status_reg);
-	adapter->tgt_mask_reg = qlcnic_get_ioaddr(adapter,
+	adapter->tgt_mask_reg = qlcnic_get_ioaddr(adapter->ahw,
 			legacy_intrp->tgt_mask_reg);
-	adapter->isr_int_vec = qlcnic_get_ioaddr(adapter, ISR_INT_VECTOR);
+	adapter->isr_int_vec = qlcnic_get_ioaddr(adapter->ahw, ISR_INT_VECTOR);
 
-	adapter->crb_int_state_reg = qlcnic_get_ioaddr(adapter,
+	adapter->crb_int_state_reg = qlcnic_get_ioaddr(adapter->ahw,
 			ISR_INT_STATE_REG);
 	dev_info(&pdev->dev, "using legacy interrupts\n");
 	adapter->msix_entries[0].vector = pdev->irq;
 }
 
-static void
+int
 qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 {
-	int num_msix;
+	int num_msix, err;
 
-	if (adapter->msix_supported) {
+	if (adapter->msix_supported)
 		num_msix = rounddown_pow_of_two(min_t(int, num_online_cpus(),
 				QLCNIC_DEF_NUM_STS_DESC_RINGS));
-	} else
+	else
 		num_msix = 1;
 
-	if (!qlcnic_enable_msix(adapter, num_msix))
-		return;
+	err = qlcnic_enable_msix(adapter, num_msix);
+	if (err == -ENOMEM || !err)
+		return err;
 
 	qlcnic_enable_msi_legacy(adapter);
+	return 0;
 }
 
 static void
@@ -442,10 +433,10 @@ qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 }
 
 static void
-qlcnic_cleanup_pci_map(struct qlcnic_adapter *adapter)
+qlcnic_cleanup_pci_map(struct qlcnic_hardware_context *ahw)
 {
-	if (adapter->ahw->pci_base0 != NULL)
-		iounmap(adapter->ahw->pci_base0);
+	if (ahw->pci_base0 != NULL)
+		iounmap(ahw->pci_base0);
 }
 
 static int
@@ -552,9 +543,10 @@ qlcnic_check_vf(struct qlcnic_adapter *adapter)
 	u32 func;
 	u32 msix_base;
 	u32 op_mode, priv_level;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	/* Determine FW API version */
-	adapter->fw_hal_version = readl(adapter->ahw->pci_base0 +
+	ahw->fw_hal_version = readl(adapter->ahw->pci_base0 +
 					QLCNIC_FW_API);
 
 	/* Find PCI function number */
@@ -562,40 +554,40 @@ qlcnic_check_vf(struct qlcnic_adapter *adapter)
 	msix_base_addr = adapter->ahw->pci_base0 + QLCNIC_MSIX_BASE;
 	msix_base = readl(msix_base_addr);
 	func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
-	adapter->ahw->pci_func = func;
+	ahw->pci_func = func;
 
 	/* Determine function privilege level */
-	priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
+	priv_op = ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
 	op_mode = readl(priv_op);
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
 		priv_level = QLCNIC_MGMT_FUNC;
 	else
-		priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw->pci_func);
+		priv_level = QLC_DEV_GET_DRV(op_mode, ahw->pci_func);
 
 	if (priv_level == QLCNIC_NON_PRIV_FUNC) {
 		adapter->op_mode = QLCNIC_NON_PRIV_FUNC;
 		dev_info(&adapter->pdev->dev,
 			"HAL Version: %d Non Privileged function\n",
-			adapter->fw_hal_version);
+			ahw->fw_hal_version);
 		adapter->nic_ops = &qlcnic_vf_ops;
 	} else
 		adapter->nic_ops = &qlcnic_ops;
 }
 
 static int
-qlcnic_setup_pci_map(struct qlcnic_adapter *adapter)
+qlcnic_setup_pci_map(struct pci_dev *pdev,
+		struct qlcnic_hardware_context *ahw)
 {
 	void __iomem *mem_ptr0 = NULL;
 	resource_size_t mem_base;
-	unsigned long mem_len, pci_len0 = 0;
-
-	struct pci_dev *pdev = adapter->pdev;
+	unsigned long mem_len, pci_len0 = 0, bar0_len;
 
 	/* remap phys address */
 	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
 	mem_len = pci_resource_len(pdev, 0);
 
-	if (mem_len == QLCNIC_PCI_2MB_SIZE) {
+	QLCNIC_BAR_LENGTH(pdev->device, &bar0_len);
+	if (mem_len == bar0_len) {
 
 		mem_ptr0 = pci_ioremap_bar(pdev, 0);
 		if (mem_ptr0 == NULL) {
@@ -609,19 +601,16 @@ qlcnic_setup_pci_map(struct qlcnic_adapter *adapter)
 
 	dev_info(&pdev->dev, "%dMB memory map\n", (int)(mem_len>>20));
 
-	adapter->ahw->pci_base0 = mem_ptr0;
-	adapter->ahw->pci_len0 = pci_len0;
-
-	qlcnic_check_vf(adapter);
+	ahw->pci_base0 = mem_ptr0;
+	ahw->pci_len0 = pci_len0;
 
-	adapter->ahw->ocm_win_crb = qlcnic_get_ioaddr(adapter,
-		QLCNIC_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(
-			adapter->ahw->pci_func)));
+	qlcnic_get_ioaddr(ahw,
+		QLCNIC_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(ahw->pci_func)));
 
 	return 0;
 }
 
-static void get_brd_name(struct qlcnic_adapter *adapter, char *name)
+static void qlcnic_get_brd_name(struct qlcnic_adapter *adapter, char *name)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int i, found = 0;
@@ -649,7 +638,8 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 {
 	u32 fw_major, fw_minor, fw_build, prev_fw_version;
 	struct pci_dev *pdev = adapter->pdev;
-	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct qlcnic_fw_dump *fw_dump = &ahw->fw_dump;
 
 	prev_fw_version = adapter->fw_version;
 
@@ -672,7 +662,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	dev_info(&pdev->dev, "firmware v%d.%d.%d\n",
 			fw_major, fw_minor, fw_build);
-	if (adapter->ahw->port_type == QLCNIC_XGBE) {
+	if (ahw->port_type == QLCNIC_XGBE) {
 		if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
 			adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_VF;
 			adapter->max_rxd = MAX_RCV_DESCRIPTORS_VF;
@@ -684,7 +674,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
 		adapter->max_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
 
-	} else if (adapter->ahw->port_type == QLCNIC_GBE) {
+	} else if (ahw->port_type == QLCNIC_GBE) {
 		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_1G;
 		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
 		adapter->max_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
@@ -832,6 +822,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 	void __iomem *priv_op;
 	u32 op_mode, priv_level;
 	int err = 0;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	err = qlcnic_initialize_nic(adapter);
 	if (err)
@@ -840,14 +831,14 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 	if (adapter->flags & QLCNIC_ADAPTER_INITIALIZED)
 		return 0;
 
-	priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
+	priv_op = ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
 	op_mode = readl(priv_op);
-	priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw->pci_func);
+	priv_level = QLC_DEV_GET_DRV(op_mode, ahw->pci_func);
 
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
 		priv_level = QLCNIC_MGMT_FUNC;
 	else
-		priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw->pci_func);
+		priv_level = QLC_DEV_GET_DRV(op_mode, ahw->pci_func);
 
 	if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
 		if (priv_level == QLCNIC_MGMT_FUNC) {
@@ -859,12 +850,12 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 			qlcnic_set_function_modes(adapter);
 			dev_info(&adapter->pdev->dev,
 				"HAL Version: %d, Management function\n",
-				adapter->fw_hal_version);
+				adapter->ahw->fw_hal_version);
 		} else if (priv_level == QLCNIC_PRIV_FUNC) {
 			adapter->op_mode = QLCNIC_PRIV_FUNC;
 			dev_info(&adapter->pdev->dev,
 				"HAL Version: %d, Privileged function\n",
-				adapter->fw_hal_version);
+				adapter->ahw->fw_hal_version);
 		}
 	}
 
@@ -1010,8 +1001,8 @@ qlcnic_set_mgmt_operations(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-static int
-qlcnic_start_firmware(struct qlcnic_adapter *adapter)
+int
+qlcnic_82xx_start_firmware(struct qlcnic_adapter *adapter)
 {
 	int err;
 
@@ -1338,21 +1329,11 @@ out:
 static int qlcnic_alloc_adapter_resources(struct qlcnic_adapter *adapter)
 {
 	int err = 0;
-	adapter->ahw = kzalloc(sizeof(struct qlcnic_hardware_context),
-				GFP_KERNEL);
-	if (!adapter->ahw) {
-		dev_err(&adapter->pdev->dev,
-			"Failed to allocate recv ctx resources for adapter\n");
-		err = -ENOMEM;
-		goto err_out;
-	}
 	adapter->recv_ctx = kzalloc(sizeof(struct qlcnic_recv_context),
 				GFP_KERNEL);
 	if (!adapter->recv_ctx) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to allocate recv ctx resources for adapter\n");
-		kfree(adapter->ahw);
-		adapter->ahw = NULL;
 		err = -ENOMEM;
 		goto err_out;
 	}
@@ -1360,6 +1341,8 @@ static int qlcnic_alloc_adapter_resources(struct qlcnic_adapter *adapter)
 	adapter->ahw->coal.flag = QLCNIC_INTR_DEFAULT;
 	adapter->ahw->coal.rx_time_us = QLCNIC_DEFAULT_INTR_COALESCE_RX_TIME_US;
 	adapter->ahw->coal.rx_packets = QLCNIC_DEFAULT_INTR_COALESCE_RX_PACKETS;
+	/* clear stats */
+	memset(&adapter->stats, 0, sizeof(adapter->stats));
 err_out:
 	return err;
 }
@@ -1373,8 +1356,6 @@ static void qlcnic_free_adapter_resources(struct qlcnic_adapter *adapter)
 		vfree(adapter->ahw->fw_dump.tmpl_hdr);
 		adapter->ahw->fw_dump.tmpl_hdr = NULL;
 	}
-	kfree(adapter->ahw);
-	adapter->ahw = NULL;
 }
 
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
@@ -1546,26 +1527,13 @@ static int qlcnic_set_dma_mask(struct pci_dev *pdev, u8 *pci_using_dac)
 	return 0;
 }
 
-static int
-qlcnic_alloc_msix_entries(struct qlcnic_adapter *adapter, u16 count)
-{
-	adapter->msix_entries = kcalloc(count, sizeof(struct msix_entry),
-					GFP_KERNEL);
-
-	if (adapter->msix_entries)
-		return 0;
-
-	dev_err(&adapter->pdev->dev, "failed allocating msix_entries\n");
-	return -ENOMEM;
-}
-
 static int __devinit
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
 	struct qlcnic_adapter *adapter = NULL;
+	struct qlcnic_hardware_context *ahw;
 	int err;
-	uint8_t revision_id;
 	uint8_t pci_using_dac;
 	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
 
@@ -1589,10 +1557,23 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_master(pdev);
 	pci_enable_pcie_error_reporting(pdev);
 
+	ahw = kzalloc(sizeof(struct qlcnic_hardware_context), GFP_KERNEL);
+	if (!ahw)
+		goto err_out_free_res;
+
+	if (ent->device == PCI_DEVICE_ID_QLOGIC_QLE824X)
+		ahw->hw_ops = &qlcnic_82xx_ops;
+	else
+		goto err_out_free_hw_res;
+
+	err = qlcnic_setup_pci_map(pdev, ahw);
+	if (err)
+		goto err_out_free_hw_res;
+
 	netdev = alloc_etherdev(sizeof(struct qlcnic_adapter));
 	if (!netdev) {
 		err = -ENOMEM;
-		goto err_out_free_res;
+		goto err_out_iounmap;
 	}
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
@@ -1600,13 +1581,13 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter = netdev_priv(netdev);
 	adapter->netdev  = netdev;
 	adapter->pdev    = pdev;
+	adapter->ahw = ahw;
 
 	if (qlcnic_alloc_adapter_resources(adapter))
 		goto err_out_free_netdev;
 
 	adapter->dev_rst_time = jiffies;
-	revision_id = pdev->revision;
-	adapter->ahw->revision_id = revision_id;
+	adapter->ahw->revision_id = pdev->revision;
 	adapter->mac_learn = qlcnic_mac_learn;
 
 	rwlock_init(&adapter->ahw->crb_lock);
@@ -1615,9 +1596,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	spin_lock_init(&adapter->tx_clean_lock);
 	INIT_LIST_HEAD(&adapter->mac_list);
 
-	err = qlcnic_setup_pci_map(adapter);
-	if (err)
-		goto err_out_free_hw;
+	qlcnic_check_vf(adapter);
 
 	/* This will be reset for mezz cards  */
 	adapter->portnum = adapter->ahw->pci_func;
@@ -1625,16 +1604,16 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	err = qlcnic_get_board_info(adapter);
 	if (err) {
 		dev_err(&pdev->dev, "Error getting board config info.\n");
-		goto err_out_iounmap;
+		goto err_out_free_hw;
 	}
 
 	err = qlcnic_setup_idc_param(adapter);
 	if (err)
-		goto err_out_iounmap;
+		goto err_out_free_hw;
 
 	adapter->flags |= QLCNIC_NEED_FLR;
 
-	err = adapter->nic_ops->start_firmware(adapter);
+	err = qlcnic_start_firmware(adapter);
 	if (err) {
 		dev_err(&pdev->dev, "Loading fw failed. Please Reboot\n"
 			"\t\tIf reboot doesn't help, try flashing the card\n");
@@ -1645,21 +1624,17 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_warn(&pdev->dev, "failed to read mac addr\n");
 
 	if (adapter->portnum == 0) {
-		get_brd_name(adapter, brd_name);
+		qlcnic_get_brd_name(adapter, brd_name);
 
 		pr_info("%s: %s Board Chip rev 0x%x\n",
 				module_name(THIS_MODULE),
 				brd_name, adapter->ahw->revision_id);
 	}
 
-	qlcnic_clear_stats(adapter);
-
-	err = qlcnic_alloc_msix_entries(adapter, adapter->max_rx_ques);
-	if (err)
+	err = qlcnic_setup_intr(adapter);
+	if (err == -ENOMEM)
 		goto err_out_decr_ref;
 
-	qlcnic_setup_intr(adapter);
-
 	err = qlcnic_setup_netdev(adapter, netdev, pci_using_dac);
 	if (err)
 		goto err_out_disable_msi;
@@ -1693,15 +1668,18 @@ err_out_disable_msi:
 err_out_decr_ref:
 	qlcnic_clr_all_drv_state(adapter, 0);
 
-err_out_iounmap:
-	qlcnic_cleanup_pci_map(adapter);
-
 err_out_free_hw:
 	qlcnic_free_adapter_resources(adapter);
 
 err_out_free_netdev:
 	free_netdev(netdev);
 
+err_out_iounmap:
+	qlcnic_cleanup_pci_map(ahw);
+
+err_out_free_hw_res:
+	kfree(ahw);
+
 err_out_free_res:
 	pci_release_regions(pdev);
 
@@ -1727,12 +1705,14 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 {
 	struct qlcnic_adapter *adapter;
 	struct net_device *netdev;
+	struct qlcnic_hardware_context *ahw;
 
 	adapter = pci_get_drvdata(pdev);
 	if (adapter == NULL)
 		return;
 
 	netdev = adapter->netdev;
+	ahw = adapter->ahw;
 
 	qlcnic_cancel_fw_work(adapter);
 
@@ -1756,7 +1736,7 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 
 	qlcnic_remove_diag_entries(adapter);
 
-	qlcnic_cleanup_pci_map(adapter);
+	qlcnic_cleanup_pci_map(ahw);
 
 	qlcnic_release_firmware(adapter);
 
@@ -1766,6 +1746,7 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 
 	qlcnic_free_adapter_resources(adapter);
+	kfree(ahw);
 	free_netdev(netdev);
 }
 static int __qlcnic_shutdown(struct pci_dev *pdev)
@@ -1834,7 +1815,7 @@ qlcnic_resume(struct pci_dev *pdev)
 	pci_set_master(pdev);
 	pci_restore_state(pdev);
 
-	err = adapter->nic_ops->start_firmware(adapter);
+	err = qlcnic_start_firmware(adapter);
 	if (err) {
 		dev_err(&pdev->dev, "failed to start firmware\n");
 		return err;
@@ -2735,12 +2716,13 @@ static int
 qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 {
 	int act, state, active_mask;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	state = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
 	act = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
 
 	if (adapter->flags & QLCNIC_FW_RESET_OWNER) {
-		active_mask = (~(1 << (adapter->ahw->pci_func * 4)));
+		active_mask = (~(1 << (ahw->pci_func * 4)));
 		act = act & active_mask;
 	}
 
@@ -2857,6 +2839,7 @@ qlcnic_fwinit_work(struct work_struct *work)
 			struct qlcnic_adapter, fw_work.work);
 	u32 dev_state = 0xf;
 	u32 val;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	if (qlcnic_api_lock(adapter))
 		goto err_ret;
@@ -2906,7 +2889,7 @@ skip_ack_check:
 		qlcnic_api_unlock(adapter);
 
 		rtnl_lock();
-		if (adapter->ahw->fw_dump.enable &&
+		if (ahw->fw_dump.enable &&
 		    (adapter->flags & QLCNIC_FW_RESET_OWNER)) {
 			QLCDB(adapter, DRV, "Take FW dump\n");
 			qlcnic_dump_fw(adapter);
@@ -2915,7 +2898,7 @@ skip_ack_check:
 		rtnl_unlock();
 
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
-		if (!adapter->nic_ops->start_firmware(adapter)) {
+		if (!qlcnic_start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			adapter->fw_wait_cnt = 0;
 			return;
@@ -2931,7 +2914,7 @@ wait_npar:
 
 	switch (dev_state) {
 	case QLCNIC_DEV_READY:
-		if (!adapter->nic_ops->start_firmware(adapter)) {
+		if (!qlcnic_start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			adapter->fw_wait_cnt = 0;
 			return;
@@ -3064,7 +3047,8 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 		qlcnic_idc_debug_info(adapter, 0);
 	}
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_NON_OPER);
+	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE,
+		QLCNIC_DEV_NPAR_NON_OPER);
 	qlcnic_api_unlock(adapter);
 }
 
@@ -3290,12 +3274,14 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	}
 	qlcnic_api_unlock(adapter);
 
-	err = adapter->nic_ops->start_firmware(adapter);
+	err = qlcnic_start_firmware(adapter);
 	if (err)
 		return err;
 
 	qlcnic_clr_drv_state(adapter);
-	qlcnic_setup_intr(adapter);
+	kfree(adapter->msix_entries);
+	adapter->msix_entries = NULL;
+	err = qlcnic_setup_intr(adapter);
 
 	if (netif_running(netdev)) {
 		err = qlcnic_attach(adapter);
@@ -3423,7 +3409,7 @@ qlcnic_store_bridged_mode(struct device *dev,
 	if (strict_strtoul(buf, 2, &new))
 		goto err_out;
 
-	if (!adapter->nic_ops->config_bridged_mode(adapter, !!new))
+	if (!qlcnic_config_bridged_mode(adapter, !!new))
 		ret = len;
 
 err_out:
@@ -3510,6 +3496,8 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data)
 		__qlcnic_down(adapter, netdev);
 	qlcnic_detach(adapter);
 	qlcnic_teardown_intr(adapter);
+	kfree(adapter->msix_entries);
+	adapter->msix_entries = NULL;
 
 	if (qlcnic_enable_msix(adapter, data)) {
 		netdev_info(netdev, "failed setting max_rss; rss disabled\n");
@@ -3662,21 +3650,13 @@ qlcnic_sysfs_read_crb(struct file *filp, struct kobject *kobj,
 {
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	u32 data;
-	u64 qmdata;
 	int ret;
 
 	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
 	if (ret != 0)
 		return ret;
 
-	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
-		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
-		memcpy(buf, &qmdata, size);
-	} else {
-		data = QLCRD32(adapter, offset);
-		memcpy(buf, &data, size);
-	}
+	qlcnic_read_crb(adapter, buf, offset, size);
 	return size;
 }
 
@@ -3687,21 +3667,13 @@ qlcnic_sysfs_write_crb(struct file *filp, struct kobject *kobj,
 {
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	u32 data;
-	u64 qmdata;
 	int ret;
 
 	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
 	if (ret != 0)
 		return ret;
 
-	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
-		memcpy(&qmdata, buf, size);
-		qlcnic_pci_camqm_write_2M(adapter, offset, qmdata);
-	} else {
-		memcpy(&data, buf, size);
-		QLCWR32(adapter, offset, data);
-	}
+	qlcnic_write_crb(adapter, buf, offset, size);
 	return size;
 }
 
-- 
1.7.1
