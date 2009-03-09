From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 5/5] netxen: annotate board_config and board_type
Date: Mon,  9 Mar 2009 11:50:56 -0700
Message-ID: <1236624656-2082-5-git-send-email-dhananjay@netxen.com>
References: <1236624656-2082-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:43665 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754188AbZCISvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 14:51:03 -0400
In-Reply-To: <1236624656-2082-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove huge board config structure from each instance, read
only necessary fields from flash.

Replace board_type with port_type (1G/10G), there's another
board_type field describing card type (SFP/XFP/CX4).

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   12 ++--
 drivers/net/netxen/netxen_nic_ethtool.c |   33 +++++-----
 drivers/net/netxen/netxen_nic_hw.c      |  108 +++++++++++++++---------------
 drivers/net/netxen/netxen_nic_hw.h      |    1 -
 drivers/net/netxen/netxen_nic_init.c    |    2 +-
 drivers/net/netxen/netxen_nic_main.c    |   38 +++--------
 6 files changed, 85 insertions(+), 109 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 2bb27d2..1a7f6df 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -90,7 +90,6 @@
 	(sizeof(struct netxen_rx_buffer) * rds_ring->max_rx_desc_count)
 #define find_diff_among(a,b,range) ((a)<(b)?((b)-(a)):((b)+(range)-(a)))
 
-#define NETXEN_NETDEV_STATUS		0x1
 #define NETXEN_RCV_PRODUCER_OFFSET	0
 #define NETXEN_RCV_PEG_DB_ID		2
 #define NETXEN_HOST_DUMMY_DMA_SIZE 1024
@@ -795,21 +794,19 @@ struct netxen_hardware_context {
 	void __iomem *pci_base0;
 	void __iomem *pci_base1;
 	void __iomem *pci_base2;
-	unsigned long first_page_group_end;
-	unsigned long first_page_group_start;
 	void __iomem *db_base;
 	unsigned long db_len;
 	unsigned long pci_len0;
 
-	u8 cut_through;
 	int qdr_sn_window;
 	int ddr_mn_window;
 	unsigned long mn_win_crb;
 	unsigned long ms_win_crb;
 
+	u8 cut_through;
 	u8 revision_id;
-	u16 board_type;
-	struct netxen_board_info boardcfg;
+	u16 port_type;
+	int board_type;
 	u32 linkup;
 	/* Address of cmd ring in Phantom */
 	struct cmd_desc_type0 *cmd_desc_head;
@@ -1260,6 +1257,7 @@ struct netxen_adapter {
 	u32 temp;
 
 	u32 fw_major;
+	u32 fw_version;
 
 	u8 msix_supported;
 	u8 max_possible_rss_rings;
@@ -1272,7 +1270,6 @@ struct netxen_adapter {
 	u16 state;
 	u16 link_autoneg;
 	int rx_csum;
-	int status;
 
 	struct netxen_cmd_buffer *cmd_buf_arr;	/* Command buffers for xmit */
 
@@ -1391,6 +1388,7 @@ void netxen_nic_write_w1(struct netxen_adapter *adapter, u32 index, u32 value);
 void netxen_nic_read_w1(struct netxen_adapter *adapter, u32 index, u32 *value);
 
 int netxen_nic_get_board_info(struct netxen_adapter *adapter);
+void netxen_nic_get_firmware_info(struct netxen_adapter *adapter);
 
 int netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter,
 		ulong off, void *data, int len);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index f811880..8b4bdfd 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -115,10 +115,9 @@ static int
 netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
-	struct netxen_board_info *boardinfo = &adapter->ahw.boardcfg;
 
 	/* read which mode */
-	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		ecmd->supported = (SUPPORTED_10baseT_Half |
 				   SUPPORTED_10baseT_Full |
 				   SUPPORTED_100baseT_Half |
@@ -137,7 +136,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		ecmd->duplex = adapter->link_duplex;
 		ecmd->autoneg = adapter->link_autoneg;
 
-	} else if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
+	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 		u32 val;
 
 		adapter->hw_read_wx(adapter, NETXEN_PORT_MODE_ADDR, &val, 4);
@@ -169,7 +168,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	ecmd->phy_address = adapter->physical_port;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
-	switch ((netxen_brdtype_t) boardinfo->board_type) {
+	switch ((netxen_brdtype_t)adapter->ahw.board_type) {
 	case NETXEN_BRDTYPE_P2_SB35_4G:
 	case NETXEN_BRDTYPE_P2_SB31_2G:
 	case NETXEN_BRDTYPE_P3_REF_QG:
@@ -185,7 +184,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		ecmd->supported |= SUPPORTED_TP;
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->port = PORT_TP;
-		ecmd->autoneg = (boardinfo->board_type ==
+		ecmd->autoneg = (adapter->ahw.board_type ==
 				 NETXEN_BRDTYPE_P2_SB31_10G_CX4) ?
 		    (AUTONEG_DISABLE) : (adapter->link_autoneg);
 		break;
@@ -212,7 +211,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		ecmd->autoneg = AUTONEG_DISABLE;
 		break;
 	case NETXEN_BRDTYPE_P3_10G_TP:
-		if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
+		if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 			ecmd->autoneg = AUTONEG_DISABLE;
 			ecmd->supported |= (SUPPORTED_FIBRE | SUPPORTED_TP);
 			ecmd->advertising |=
@@ -228,7 +227,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		break;
 	default:
 		printk(KERN_ERR "netxen-nic: Unsupported board model %d\n",
-		       (netxen_brdtype_t) boardinfo->board_type);
+		       (netxen_brdtype_t)adapter->ahw.board_type);
 		return -EIO;
 	}
 
@@ -242,7 +241,7 @@ netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	__u32 status;
 
 	/* read which mode */
-	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		/* autonegotiation */
 		if (adapter->phy_write
 		    && adapter->phy_write(adapter,
@@ -430,7 +429,7 @@ static u32 netxen_nic_test_link(struct net_device *dev)
 	int val;
 
 	/* read which mode */
-	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		if (adapter->phy_read
 		    && adapter->phy_read(adapter,
 					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
@@ -440,7 +439,7 @@ static u32 netxen_nic_test_link(struct net_device *dev)
 			val = netxen_get_phy_link(status);
 			return !val;
 		}
-	} else if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
+	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
 		return (val == XG_LINK_UP) ? 0 : 1;
 	}
@@ -483,7 +482,7 @@ netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 		rds_rings[RCV_DESC_JUMBO_CTXID].max_rx_desc_count;
 	ring->tx_pending = adapter->max_tx_desc_count;
 
-	if (adapter->ahw.board_type == NETXEN_NIC_GBE)
+	if (adapter->ahw.port_type == NETXEN_NIC_GBE)
 		ring->rx_max_pending = MAX_RCV_DESCRIPTORS_1G;
 	else
 		ring->rx_max_pending = MAX_RCV_DESCRIPTORS_10G;
@@ -501,7 +500,7 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 	__u32 val;
 	int port = adapter->physical_port;
 
-	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 			return;
 		/* get flow control settings */
@@ -524,7 +523,7 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 				pause->tx_pause = !(netxen_gb_get_gb3_mask(val));
 				break;
 		}
-	} else if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
+	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 		if ((port < 0) || (port > NETXEN_NIU_MAX_XG_PORTS))
 			return;
 		pause->rx_pause = 1;
@@ -535,7 +534,7 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 			pause->tx_pause = !(netxen_xg_get_xg1_mask(val));
 	} else {
 		printk(KERN_ERR"%s: Unknown board type: %x\n",
-				netxen_nic_driver_name, adapter->ahw.board_type);
+				netxen_nic_driver_name, adapter->ahw.port_type);
 	}
 }
 
@@ -547,7 +546,7 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 	__u32 val;
 	int port = adapter->physical_port;
 	/* read mode */
-	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 			return -EIO;
 		/* set flow control */
@@ -591,7 +590,7 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 				break;
 		}
 		netxen_nic_write_w0(adapter, NETXEN_NIU_GB_PAUSE_CTL, val);
-	} else if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
+	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 		if ((port < 0) || (port > NETXEN_NIU_MAX_XG_PORTS))
 			return -EIO;
 		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_PAUSE_CTL, &val);
@@ -610,7 +609,7 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 	} else {
 		printk(KERN_ERR "%s: Unknown board type: %x\n",
 				netxen_nic_driver_name,
-				adapter->ahw.board_type);
+				adapter->ahw.port_type);
 	}
 	return 0;
 }
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index bc5cce3..8d30786 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -706,9 +706,8 @@ int netxen_nic_change_mtu(struct net_device *netdev, int mtu)
 static int netxen_get_flash_block(struct netxen_adapter *adapter, int base,
 				  int size, __le32 * buf)
 {
-	int i, addr;
+	int i, v, addr;
 	__le32 *ptr32;
-	u32 v;
 
 	addr = base;
 	ptr32 = buf;
@@ -2067,47 +2066,44 @@ u32 netxen_nic_pci_read_normalize_2M(struct netxen_adapter *adapter, u64 off)
 
 int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 {
-	int rv = 0;
-	int addr = NETXEN_BRDCFG_START;
-	struct netxen_board_info *boardinfo;
-	int index;
-	int *ptr32;
+	int offset, board_type, magic, header_version;
+	struct pci_dev *pdev = adapter->pdev;
 
-	boardinfo = &adapter->ahw.boardcfg;
-	ptr32 = (int *) boardinfo;
+	offset = NETXEN_BRDCFG_START +
+		offsetof(struct netxen_board_info, magic);
+	if (netxen_rom_fast_read(adapter, offset, &magic))
+		return -EIO;
 
-	for (index = 0; index < sizeof(struct netxen_board_info) / sizeof(u32);
-	     index++) {
-		if (netxen_rom_fast_read(adapter, addr, ptr32) == -1) {
-			return -EIO;
-		}
-		ptr32++;
-		addr += sizeof(u32);
-	}
-	if (boardinfo->magic != NETXEN_BDINFO_MAGIC) {
-		printk("%s: ERROR reading %s board config."
-		       " Read %x, expected %x\n", netxen_nic_driver_name,
-		       netxen_nic_driver_name,
-		       boardinfo->magic, NETXEN_BDINFO_MAGIC);
-		rv = -1;
-	}
-	if (boardinfo->header_version != NETXEN_BDINFO_VERSION) {
-		printk("%s: Unknown board config version."
-		       " Read %x, expected %x\n", netxen_nic_driver_name,
-		       boardinfo->header_version, NETXEN_BDINFO_VERSION);
-		rv = -1;
+	offset = NETXEN_BRDCFG_START +
+		offsetof(struct netxen_board_info, header_version);
+	if (netxen_rom_fast_read(adapter, offset, &header_version))
+		return -EIO;
+
+	if (magic != NETXEN_BDINFO_MAGIC ||
+			header_version != NETXEN_BDINFO_VERSION) {
+		dev_err(&pdev->dev,
+			"invalid board config, magic=%08x, version=%08x\n",
+			magic, header_version);
+		return -EIO;
 	}
 
-	if (boardinfo->board_type == NETXEN_BRDTYPE_P3_4_GB_MM) {
+	offset = NETXEN_BRDCFG_START +
+		offsetof(struct netxen_board_info, board_type);
+	if (netxen_rom_fast_read(adapter, offset, &board_type))
+		return -EIO;
+
+	adapter->ahw.board_type = board_type;
+
+	if (board_type == NETXEN_BRDTYPE_P3_4_GB_MM) {
 		u32 gpio = netxen_nic_reg_read(adapter,
 				NETXEN_ROMUSB_GLB_PAD_GPIO_I);
 		if ((gpio & 0x8000) == 0)
-			boardinfo->board_type = NETXEN_BRDTYPE_P3_10G_TP;
+			board_type = NETXEN_BRDTYPE_P3_10G_TP;
 	}
 
-	switch ((netxen_brdtype_t) boardinfo->board_type) {
+	switch ((netxen_brdtype_t)board_type) {
 	case NETXEN_BRDTYPE_P2_SB35_4G:
-		adapter->ahw.board_type = NETXEN_NIC_GBE;
+		adapter->ahw.port_type = NETXEN_NIC_GBE;
 		break;
 	case NETXEN_BRDTYPE_P2_SB31_10G:
 	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
@@ -2123,7 +2119,7 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P3_10G_SFP_QT:
 	case NETXEN_BRDTYPE_P3_10G_XFP:
 	case NETXEN_BRDTYPE_P3_10000_BASE_T:
-		adapter->ahw.board_type = NETXEN_NIC_XGBE;
+		adapter->ahw.port_type = NETXEN_NIC_XGBE;
 		break;
 	case NETXEN_BRDTYPE_P1_BD:
 	case NETXEN_BRDTYPE_P1_SB:
@@ -2132,20 +2128,19 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P3_REF_QG:
 	case NETXEN_BRDTYPE_P3_4_GB:
 	case NETXEN_BRDTYPE_P3_4_GB_MM:
-		adapter->ahw.board_type = NETXEN_NIC_GBE;
+		adapter->ahw.port_type = NETXEN_NIC_GBE;
 		break;
 	case NETXEN_BRDTYPE_P3_10G_TP:
-		adapter->ahw.board_type = (adapter->portnum < 2) ?
+		adapter->ahw.port_type = (adapter->portnum < 2) ?
 			NETXEN_NIC_XGBE : NETXEN_NIC_GBE;
 		break;
 	default:
-		printk("%s: Unknown(%x)\n", netxen_nic_driver_name,
-		       boardinfo->board_type);
-		rv = -ENODEV;
+		dev_err(&pdev->dev, "unknown board type %x\n", board_type);
+		adapter->ahw.port_type = NETXEN_NIC_XGBE;
 		break;
 	}
 
-	return rv;
+	return 0;
 }
 
 /* NIU access sections */
@@ -2191,7 +2186,7 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 		return;
 	}
 
-	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		adapter->hw_read_wx(adapter,
 				NETXEN_PORT_MODE_ADDR, &port_mode, 4);
 		if (port_mode == NETXEN_PORT_MODE_802_3_AP) {
@@ -2246,17 +2241,14 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 	}
 }
 
-void netxen_nic_flash_print(struct netxen_adapter *adapter)
+void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 {
-	u32 fw_major = 0;
-	u32 fw_minor = 0;
-	u32 fw_build = 0;
+	u32 fw_major, fw_minor, fw_build;
 	char brd_name[NETXEN_MAX_SHORT_NAME];
 	char serial_num[32];
 	int i, addr;
 	int *ptr32;
-
-	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
+	struct pci_dev *pdev = adapter->pdev;
 
 	adapter->driver_mismatch = 0;
 
@@ -2280,23 +2272,31 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 	adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_SUB, &fw_build, 4);
 
 	adapter->fw_major = fw_major;
+	adapter->fw_version = NETXEN_VERSION_CODE(fw_major, fw_minor, fw_build);
 
 	if (adapter->portnum == 0) {
-		get_brd_name_by_type(board_info->board_type, brd_name);
+		get_brd_name_by_type(adapter->ahw.board_type, brd_name);
 
 		printk(KERN_INFO "NetXen %s Board S/N %s  Chip rev 0x%x\n",
 				brd_name, serial_num, adapter->ahw.revision_id);
-		printk(KERN_INFO "NetXen Firmware version %d.%d.%d\n",
-				fw_major, fw_minor, fw_build);
 	}
 
-	if (NETXEN_VERSION_CODE(fw_major, fw_minor, fw_build) <
-			NETXEN_VERSION_CODE(3, 4, 216)) {
+	if (adapter->fw_version < NETXEN_VERSION_CODE(3, 4, 216)) {
 		adapter->driver_mismatch = 1;
-		printk(KERN_ERR "%s: firmware version %d.%d.%d unsupported\n",
-				netxen_nic_driver_name,
+		dev_warn(&pdev->dev, "firmware version %d.%d.%d unsupported\n",
 				fw_major, fw_minor, fw_build);
 		return;
 	}
+
+	dev_info(&pdev->dev, "firmware version %d.%d.%d\n",
+			fw_major, fw_minor, fw_build);
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		adapter->hw_read_wx(adapter,
+				NETXEN_MIU_MN_CONTROL, &i, 4);
+		adapter->ahw.cut_through = (i & 0x4) ? 1 : 0;
+		dev_info(&pdev->dev, "firmware running in %s mode\n",
+		adapter->ahw.cut_through ? "cut-through" : "legacy");
+	}
 }
 
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 9fb5162..04b47a7 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -57,7 +57,6 @@ struct netxen_adapter;
 
 struct netxen_port;
 void netxen_nic_set_link_parameters(struct netxen_adapter *adapter);
-void netxen_nic_flash_print(struct netxen_adapter *adapter);
 
 typedef u8 netxen_ethernet_macaddr_t[6];
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index bd5e0d6..120b480 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -316,7 +316,7 @@ err_out:
 
 void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 {
-	switch (adapter->ahw.board_type) {
+	switch (adapter->ahw.port_type) {
 	case NETXEN_NIC_GBE:
 		adapter->enable_phy_interrupts =
 		    netxen_niu_gbe_enable_phy_interrupts;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index e81a998..16d3905 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -212,7 +212,7 @@ nx_update_dma_mask(struct netxen_adapter *adapter)
 
 static void netxen_check_options(struct netxen_adapter *adapter)
 {
-	switch (adapter->ahw.boardcfg.board_type) {
+	switch (adapter->ahw.board_type) {
 	case NETXEN_BRDTYPE_P3_HMEZ:
 	case NETXEN_BRDTYPE_P3_XG_LOM:
 	case NETXEN_BRDTYPE_P3_10G_CX4:
@@ -250,7 +250,7 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 
 	case NETXEN_BRDTYPE_P3_10G_TP:
 		adapter->msix_supported = !!use_msi_x;
-		if (adapter->ahw.board_type == NETXEN_NIC_XGBE)
+		if (adapter->ahw.port_type == NETXEN_NIC_XGBE)
 			adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
 		else
 			adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
@@ -261,7 +261,7 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
 
 		printk(KERN_WARNING "Unknown board type(0x%x)\n",
-				adapter->ahw.boardcfg.board_type);
+				adapter->ahw.board_type);
 		break;
 	}
 
@@ -330,7 +330,7 @@ static void netxen_set_port_mode(struct netxen_adapter *adapter)
 {
 	u32 val, data;
 
-	val = adapter->ahw.boardcfg.board_type;
+	val = adapter->ahw.board_type;
 	if ((val == NETXEN_BRDTYPE_P3_HMEZ) ||
 		(val == NETXEN_BRDTYPE_P3_XG_LOM)) {
 		if (port_mode == NETXEN_PORT_MODE_802_3_AP) {
@@ -520,8 +520,6 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 	void __iomem *mem_ptr2 = NULL;
 	void __iomem *db_ptr = NULL;
 
-	unsigned long first_page_group_end;
-	unsigned long first_page_group_start;
 	unsigned long mem_base, mem_len, db_base, db_len = 0, pci_len0 = 0;
 
 	struct pci_dev *pdev = adapter->pdev;
@@ -559,14 +557,10 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 				SECOND_PAGE_GROUP_SIZE);
 		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START,
 				THIRD_PAGE_GROUP_SIZE);
-		first_page_group_start = FIRST_PAGE_GROUP_START;
-		first_page_group_end   = FIRST_PAGE_GROUP_END;
 	} else if (mem_len == NETXEN_PCI_32MB_SIZE) {
 		mem_ptr1 = ioremap(mem_base, SECOND_PAGE_GROUP_SIZE);
 		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START -
 			SECOND_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
-		first_page_group_start = 0;
-		first_page_group_end   = 0;
 	} else if (mem_len == NETXEN_PCI_2MB_SIZE) {
 		adapter->hw_write_wx = netxen_nic_hw_write_wx_2M;
 		adapter->hw_read_wx = netxen_nic_hw_read_wx_2M;
@@ -586,8 +580,6 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 			return -EIO;
 		}
 		pci_len0 = mem_len;
-		first_page_group_start = 0;
-		first_page_group_end   = 0;
 
 		adapter->ahw.ddr_mn_window = 0;
 		adapter->ahw.qdr_sn_window = 0;
@@ -608,8 +600,6 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 
 	adapter->ahw.pci_base0 = mem_ptr0;
 	adapter->ahw.pci_len0 = pci_len0;
-	adapter->ahw.first_page_group_start = first_page_group_start;
-	adapter->ahw.first_page_group_end   = first_page_group_end;
 	adapter->ahw.pci_base1 = mem_ptr1;
 	adapter->ahw.pci_base2 = mem_ptr2;
 
@@ -676,7 +666,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 
 		/* Initialize multicast addr pool owners */
 		val = 0x7654;
-		if (adapter->ahw.board_type == NETXEN_NIC_XGBE)
+		if (adapter->ahw.port_type == NETXEN_NIC_XGBE)
 			val |= 0x0f000000;
 		netxen_crb_writelit_adapter(adapter,
 				NETXEN_MAC_ADDR_CNTL_REG, val);
@@ -867,7 +857,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct netxen_adapter *adapter = NULL;
 	int i = 0, err;
 	int first_driver;
-	u32 val;
 	int pci_func_id = PCI_FUNC(pdev->devfn);
 	uint8_t revision_id;
 
@@ -933,7 +922,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* This will be reset for mezz cards  */
 	adapter->portnum = pci_func_id;
-	adapter->status   &= ~NETXEN_NETDEV_STATUS;
 	adapter->rx_csum = 1;
 	adapter->mc_enabled = 0;
 	if (NX_IS_REVISION_P3(revision_id))
@@ -971,7 +959,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netxen_initialize_adapter_ops(adapter);
 
 	/* Mezz cards have PCI function 0,2,3 enabled */
-	switch (adapter->ahw.boardcfg.board_type) {
+	switch (adapter->ahw.board_type) {
 	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
 	case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
 		if (pci_func_id >= 2)
@@ -1004,15 +992,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	nx_update_dma_mask(adapter);
 
-	netxen_nic_flash_print(adapter);
-
-	if (NX_IS_REVISION_P3(revision_id)) {
-		adapter->hw_read_wx(adapter,
-				NETXEN_MIU_MN_CONTROL, &val, 4);
-		adapter->ahw.cut_through = (val & 0x4) ? 1 : 0;
-		dev_info(&pdev->dev, "firmware running in %s mode\n",
-		adapter->ahw.cut_through ? "cut through" : "legacy");
-	}
+	netxen_nic_get_firmware_info(adapter);
 
 	/*
 	 * See if the firmware gave us a virtual-physical port mapping.
@@ -1063,7 +1043,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, adapter);
 
-	switch (adapter->ahw.board_type) {
+	switch (adapter->ahw.port_type) {
 	case NETXEN_NIC_GBE:
 		dev_info(&adapter->pdev->dev, "%s: GbE port initialized\n",
 				adapter->netdev->name);
@@ -1457,7 +1437,7 @@ static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
 		linkup = (val == XG_LINK_UP_P3);
 	} else {
 		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
-		if (adapter->ahw.board_type == NETXEN_NIC_GBE)
+		if (adapter->ahw.port_type == NETXEN_NIC_GBE)
 			linkup = (val >> port) & 1;
 		else {
 			val = (val >> port*8) & 0xff;
-- 
1.6.0.2

