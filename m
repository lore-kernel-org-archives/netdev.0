From: "Linsys Contractor Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2/4] NetXen: temp monitoring, newer firmware support, mm footprint reduction
Date: Wed, 22 Nov 2006 06:20:30 -0800
Message-ID: <200611221420.kAMEKU1F010516@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:2849 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1755956AbWKVOUb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 09:20:31 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: 1G/10G Ethernet Driver updates
	- Temparature monitoring and device control
	- Memory footprint reduction
	- Driver changes to support newer version of firmware

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

 netxen_nic.h          |  165 ++++++++++++++++++++++++++++++++--
 netxen_nic_ethtool.c  |   89 ++++++++++++------
 netxen_nic_hdr.h      |   71 +++++++++++++-
 netxen_nic_hw.c       |  206 +++++++++++++++++++++++++++++--------------
 netxen_nic_hw.h       |    8 +
 netxen_nic_init.c     |  239 +++++++++++++++++++++++++++++++++++++++++---------
 netxen_nic_ioctl.h    |   12 +-
 netxen_nic_isr.c      |   54 +++++------
 netxen_nic_main.c     |  121 +++++++++++++++++--------
 netxen_nic_niu.c      |  172 +++++++++++++++++++++++++++--------
 netxen_nic_phan_reg.h |   24 ++++-
 11 files changed, 891 insertions(+), 270 deletions(-)


diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 0458db4..1bee560 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -63,12 +63,12 @@
 
 #include "netxen_nic_hw.h"
 
-#define NETXEN_NIC_BUILD_NO     "232"
+#define NETXEN_NIC_BUILD_NO     "5"
 #define _NETXEN_NIC_LINUX_MAJOR 2
 #define _NETXEN_NIC_LINUX_MINOR 3
-#define _NETXEN_NIC_LINUX_SUBVERSION 57
-#define NETXEN_NIC_LINUX_VERSIONID  "2.3.57"
-#define NETXEN_NIC_FW_VERSIONID "2.3.57"
+#define _NETXEN_NIC_LINUX_SUBVERSION 59
+#define NETXEN_NIC_LINUX_VERSIONID  "2.3.59" "-" NETXEN_NIC_BUILD_NO
+#define NETXEN_NIC_FW_VERSIONID "2.3.59"
 
 #define RCV_DESC_RINGSIZE	\
 	(sizeof(struct rcv_desc) * adapter->max_rx_desc_count)
@@ -89,9 +89,24 @@
  * normalize a 64MB crb address to 32MB PCI window 
  * To use NETXEN_CRB_NORMALIZE, window _must_ be set to 1
  */
+#define NETXEN_CRB_NORMAL(reg)        \
+	(reg) - NETXEN_CRB_PCIX_HOST2 + NETXEN_CRB_PCIX_HOST
+
 #define NETXEN_CRB_NORMALIZE(adapter, reg) \
-	((adapter)->ahw.pci_base + (reg)	\
-	- NETXEN_CRB_PCIX_HOST2 + NETXEN_CRB_PCIX_HOST)
+	pci_base_offset(adapter, NETXEN_CRB_NORMAL(reg))
+
+#define FIRST_PAGE_GROUP_START	0
+#define FIRST_PAGE_GROUP_END	0x400000
+
+#define SECOND_PAGE_GROUP_START	0x4000000
+#define SECOND_PAGE_GROUP_END	0x66BC000
+
+#define THIRD_PAGE_GROUP_START	0x70E4000
+#define THIRD_PAGE_GROUP_END	0x8000000
+
+#define FIRST_PAGE_GROUP_SIZE  FIRST_PAGE_GROUP_END - FIRST_PAGE_GROUP_START
+#define SECOND_PAGE_GROUP_SIZE SECOND_PAGE_GROUP_END - SECOND_PAGE_GROUP_START
+#define THIRD_PAGE_GROUP_SIZE  THIRD_PAGE_GROUP_END - THIRD_PAGE_GROUP_START
 
 #define MAX_RX_BUFFER_LENGTH		2000
 #define MAX_RX_JUMBO_BUFFER_LENGTH 	9046
@@ -328,6 +343,7 @@ typedef enum {
 	NETXEN_BRDTYPE_P2_SB31_10G_HMEZ = 0x000e,
 	NETXEN_BRDTYPE_P2_SB31_10G_CX4 = 0x000f
 } netxen_brdtype_t;
+#define NUM_SUPPORTED_BOARDS (sizeof(netxen_boards)/sizeof(netxen_brdinfo_t))
 
 typedef enum {
 	NETXEN_BRDMFG_INVENTEC = 1
@@ -615,15 +631,23 @@ struct netxen_rx_buffer {
  */
 struct netxen_hardware_context {
 	struct pci_dev *pdev;
-	void __iomem *pci_base;	/* base of mapped phantom memory */
+	void __iomem *pci_base0;
+	void __iomem *pci_base1;
+	void __iomem *pci_base2;
+
 	u8 revision_id;
 	u16 board_type;
 	u16 max_ports;
 	struct netxen_board_info boardcfg;
 	u32 xg_linkup;
+	u32 qg_linksup;
 	/* Address of cmd ring in Phantom */
 	struct cmd_desc_type0 *cmd_desc_head;
+	char *pauseaddr;
+	struct pci_dev *cmd_desc_pdev;
 	dma_addr_t cmd_desc_phys_addr;
+	dma_addr_t pause_physaddr;
+	struct pci_dev *pause_pdev;
 	struct netxen_adapter *adapter;
 };
 
@@ -654,6 +678,7 @@ struct netxen_rcv_desc_ctx {
 	u32 rcv_pending;	/* Num of bufs posted in phantom */
 	u32 rcv_free;		/* Num of bufs in free list */
 	dma_addr_t phys_addr;
+	struct pci_dev *phys_pdev;
 	struct rcv_desc *desc_head;	/* address of rx ring in Phantom */
 	u32 max_rx_desc_count;
 	u32 dma_size;
@@ -673,6 +698,7 @@ struct netxen_recv_context {
 	u32 status_rx_producer;
 	u32 status_rx_consumer;
 	dma_addr_t rcv_status_desc_phys_addr;
+	struct pci_dev *rcv_status_desc_pdev;
 	struct status_desc *rcv_status_desc_head;
 };
 
@@ -708,6 +734,7 @@ struct netxen_adapter {
 	u32 flags;
 	u32 irq;
 	int driver_mismatch;
+	u32 temp;
 
 	struct netxen_adapter_stats stats;
 
@@ -766,6 +793,43 @@ struct netxen_port {
 	struct netxen_port_stats stats;
 };
 
+#define PCI_OFFSET_FIRST_RANGE(adapter, off)    \
+	((adapter)->ahw.pci_base0 + (off))
+#define PCI_OFFSET_SECOND_RANGE(adapter, off)   \
+	((adapter)->ahw.pci_base1 + (off) - SECOND_PAGE_GROUP_START)
+#define PCI_OFFSET_THIRD_RANGE(adapter, off)    \
+	((adapter)->ahw.pci_base2 + (off) - THIRD_PAGE_GROUP_START)
+
+static inline void __iomem *pci_base_offset(struct netxen_adapter *adapter,
+					    unsigned long off)
+{
+	if ((off < FIRST_PAGE_GROUP_END) && (off >= FIRST_PAGE_GROUP_START)) {
+		return (adapter->ahw.pci_base0 + off);
+	} else if ((off < SECOND_PAGE_GROUP_END) &&
+		   (off >= SECOND_PAGE_GROUP_START)) {
+		return (adapter->ahw.pci_base1 + off - SECOND_PAGE_GROUP_START);
+	} else if ((off < THIRD_PAGE_GROUP_END) &&
+		   (off >= THIRD_PAGE_GROUP_START)) {
+		return (adapter->ahw.pci_base2 + off - THIRD_PAGE_GROUP_START);
+	}
+	return NULL;
+}
+
+static inline void __iomem *pci_base(struct netxen_adapter *adapter,
+				     unsigned long off)
+{
+	if ((off < FIRST_PAGE_GROUP_END) && (off >= FIRST_PAGE_GROUP_START)) {
+		return adapter->ahw.pci_base0;
+	} else if ((off < SECOND_PAGE_GROUP_END) &&
+		   (off >= SECOND_PAGE_GROUP_START)) {
+		return adapter->ahw.pci_base1;
+	} else if ((off < THIRD_PAGE_GROUP_END) &&
+		   (off >= THIRD_PAGE_GROUP_START)) {
+		return adapter->ahw.pci_base2;
+	}
+	return NULL;
+}
+
 struct netxen_drvops {
 	int (*enable_phy_interrupts) (struct netxen_adapter *, int);
 	int (*disable_phy_interrupts) (struct netxen_adapter *, int);
@@ -809,7 +873,6 @@ int netxen_niu_gbe_phy_write(struct netx
 			     long reg, __le32 val);
 
 /* Functions available from netxen_nic_hw.c */
-int netxen_niu_xginit(struct netxen_adapter *);
 int netxen_nic_set_mtu_xgb(struct netxen_port *port, int new_mtu);
 int netxen_nic_set_mtu_gb(struct netxen_port *port, int new_mtu);
 void netxen_nic_init_niu_gb(struct netxen_adapter *adapter);
@@ -828,10 +891,13 @@ void netxen_crb_writelit_adapter(struct
 				 unsigned long off, int data);
 
 /* Functions from netxen_nic_init.c */
-void netxen_phantom_init(struct netxen_adapter *adapter);
+void netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val);
 void netxen_load_firmware(struct netxen_adapter *adapter);
 int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose);
 int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp);
+int netxen_rom_fast_write(struct netxen_adapter *adapter, int addr, int data);
+int netxen_rom_se(struct netxen_adapter *adapter, int addr);
+int netxen_do_rom_se(struct netxen_adapter *adapter, int addr);
 
 /* Functions from netxen_nic_isr.c */
 void netxen_nic_isr_other(struct netxen_adapter *adapter);
@@ -842,6 +908,8 @@ void netxen_handle_port_int(struct netxe
 void netxen_nic_stop_all_ports(struct netxen_adapter *adapter);
 void netxen_initialize_adapter_sw(struct netxen_adapter *adapter);
 void netxen_initialize_adapter_hw(struct netxen_adapter *adapter);
+void *netxen_alloc(struct pci_dev *pdev, size_t sz, dma_addr_t * ptr,
+		   struct pci_dev **used_dev);
 void netxen_initialize_adapter_ops(struct netxen_adapter *adapter);
 int netxen_init_firmware(struct netxen_adapter *adapter);
 void netxen_free_hw_resources(struct netxen_adapter *adapter);
@@ -869,7 +937,10 @@ static inline void netxen_nic_disable_in
 	/*
 	 * ISR_INT_MASK: Can be read from window 0 or 1.
 	 */
-	writel(0x7ff, (void __iomem *)(adapter->ahw.pci_base + ISR_INT_MASK));
+	writel(0x7ff,
+	       (void __iomem
+		*)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
+
 }
 
 static inline void netxen_nic_enable_int(struct netxen_adapter *adapter)
@@ -888,13 +959,83 @@ static inline void netxen_nic_enable_int
 		break;
 	}
 
-	writel(mask, (void __iomem *)(adapter->ahw.pci_base + ISR_INT_MASK));
+	writel(mask,
+	       (void __iomem
+		*)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		mask = 0xbff;
 		writel(mask, (void __iomem *)
-		       (adapter->ahw.pci_base + ISR_INT_TARGET_MASK));
+		       (PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_MASK)));
+	}
+}
+
+/*
+ * NetXen Board information
+ */
+
+#define NETXEN_MAX_SHORT_NAME 16
+typedef struct {
+	netxen_brdtype_t brdtype;	/* type of board */
+	long ports;		/* max no of physical ports */
+	char short_name[NETXEN_MAX_SHORT_NAME];
+} netxen_brdinfo_t;
+
+static const netxen_brdinfo_t netxen_boards[] = {
+	{NETXEN_BRDTYPE_P2_SB31_10G_CX4, 1, "XGb CX4"},
+	{NETXEN_BRDTYPE_P2_SB31_10G_HMEZ, 1, "XGb HMEZ"},
+	{NETXEN_BRDTYPE_P2_SB31_10G_IMEZ, 2, "XGb IMEZ"},
+	{NETXEN_BRDTYPE_P2_SB31_10G, 1, "XGb XFP"},
+	{NETXEN_BRDTYPE_P2_SB35_4G, 4, "Quad Gb"},
+	{NETXEN_BRDTYPE_P2_SB31_2G, 2, "Dual Gb"},
+};
+
+#define NUM_SUPPORTED_BOARDS (sizeof(netxen_boards)/sizeof(netxen_brdinfo_t))
+
+static inline void get_brd_ports_name_by_type(u32 type, int *ports, char *name)
+{
+	int i, found = 0;
+	for (i = 0; i < NUM_SUPPORTED_BOARDS; ++i) {
+		if (netxen_boards[i].brdtype == type) {
+			*ports = netxen_boards[i].ports;
+			strcpy(name, netxen_boards[i].short_name);
+			found = 1;
+			break;
+		}
+	}
+	if (!found) {
+		*ports = 0;
+		name = "Unknown";
+	}
+}
+
+static inline void get_brd_port_by_type(u32 type, int *ports)
+{
+	int i, found = 0;
+	for (i = 0; i < NUM_SUPPORTED_BOARDS; ++i) {
+		if (netxen_boards[i].brdtype == type) {
+			*ports = netxen_boards[i].ports;
+			found = 1;
+			break;
+		}
+	}
+	if (!found)
+		*ports = 0;
+}
+
+static inline void get_brd_name_by_type(u32 type, char *name)
+{
+	int i, found = 0;
+	for (i = 0; i < NUM_SUPPORTED_BOARDS; ++i) {
+		if (netxen_boards[i].brdtype == type) {
+			strcpy(name, netxen_boards[i].short_name);
+			found = 1;
+			break;
+		}
+
 	}
+	if (!found)
+		name = "Unknown";
 }
 
 int netxen_is_flash_supported(struct netxen_adapter *adapter);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index caf6cc1..f3fc35c 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -53,6 +53,9 @@ struct netxen_nic_stats {
 #define NETXEN_NIC_STAT(m) sizeof(((struct netxen_port *)0)->m), \
 			offsetof(struct netxen_port, m)
 
+#define NETXEN_NIC_PORT_WINDOW 0x10000
+#define NETXEN_NIC_INVALID_DATA 0xDEADBEEF
+
 static const struct netxen_nic_stats netxen_nic_gstrings_stats[] = {
 	{"rcvd_bad_skb", NETXEN_NIC_STAT(stats.rcvdbadskb)},
 	{"xmit_called", NETXEN_NIC_STAT(stats.xmitcalled)},
@@ -111,9 +114,9 @@ netxen_nic_get_drvinfo(struct net_device
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
-	uint32_t fw_major = 0;
-	uint32_t fw_minor = 0;
-	uint32_t fw_build = 0;
+	u32 fw_major = 0;
+	u32 fw_minor = 0;
+	u32 fw_build = 0;
 
 	strncpy(drvinfo->driver, "netxen_nic", 32);
 	strncpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID, 32);
@@ -136,6 +139,8 @@ netxen_nic_get_settings(struct net_devic
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_board_info *boardinfo;
+	boardinfo = &adapter->ahw.boardcfg;
 
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
@@ -144,16 +149,12 @@ netxen_nic_get_settings(struct net_devic
 				   SUPPORTED_100baseT_Half |
 				   SUPPORTED_100baseT_Full |
 				   SUPPORTED_1000baseT_Half |
-				   SUPPORTED_1000baseT_Full |
-				   SUPPORTED_TP |
-				   SUPPORTED_MII | SUPPORTED_Autoneg);
+				   SUPPORTED_1000baseT_Full);
 
 		ecmd->advertising = (ADVERTISED_100baseT_Half |
 				     ADVERTISED_100baseT_Full |
 				     ADVERTISED_1000baseT_Half |
-				     ADVERTISED_1000baseT_Full |
-				     ADVERTISED_TP |
-				     ADVERTISED_MII | ADVERTISED_Autoneg);
+				     ADVERTISED_1000baseT_Full);
 
 		ecmd->port = PORT_TP;
 
@@ -162,16 +163,7 @@ netxen_nic_get_settings(struct net_devic
 			ecmd->duplex = port->link_duplex;
 		} else
 			return -EIO;	/* link absent */
-
-		ecmd->phy_address = port->portnum;
-		ecmd->transceiver = XCVR_EXTERNAL;
-
-		/* get autoneg settings */
-		ecmd->autoneg = port->link_autoneg;
-		return 0;
-	}
-
-	if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
+	} else if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
 		ecmd->supported = (SUPPORTED_TP |
 				   SUPPORTED_1000baseT_Full |
 				   SUPPORTED_10000baseT_Full);
@@ -182,13 +174,47 @@ netxen_nic_get_settings(struct net_devic
 
 		ecmd->speed = SPEED_10000;
 		ecmd->duplex = DUPLEX_FULL;
-		ecmd->phy_address = port->portnum;
-		ecmd->transceiver = XCVR_EXTERNAL;
 		ecmd->autoneg = AUTONEG_DISABLE;
-		return 0;
+	} else
+		return -EIO;
+
+	ecmd->phy_address = port->portnum;
+	ecmd->transceiver = XCVR_EXTERNAL;
+
+	switch ((netxen_brdtype_t) boardinfo->board_type) {
+	case NETXEN_BRDTYPE_P2_SB35_4G:
+	case NETXEN_BRDTYPE_P2_SB31_2G:
+		ecmd->supported |= SUPPORTED_Autoneg;
+		ecmd->advertising |= ADVERTISED_Autoneg;
+	case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
+		ecmd->supported |= SUPPORTED_TP;
+		ecmd->advertising |= ADVERTISED_TP;
+		ecmd->port = PORT_TP;
+		ecmd->autoneg = (boardinfo->board_type ==
+				 NETXEN_BRDTYPE_P2_SB31_10G_CX4) ?
+		    (AUTONEG_DISABLE) : (port->link_autoneg);
+		break;
+	case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
+	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
+		ecmd->supported |= SUPPORTED_MII;
+		ecmd->advertising |= ADVERTISED_MII;
+		ecmd->port = PORT_FIBRE;
+		ecmd->autoneg = AUTONEG_DISABLE;
+		break;
+	case NETXEN_BRDTYPE_P2_SB31_10G:
+		ecmd->supported |= SUPPORTED_FIBRE;
+		ecmd->advertising |= ADVERTISED_FIBRE;
+		ecmd->port = PORT_FIBRE;
+		ecmd->autoneg = AUTONEG_DISABLE;
+		break;
+	default:
+		printk("ERROR: Unsupported board model %d\n",
+		       (netxen_brdtype_t) boardinfo->board_type);
+		return -EIO;
+
 	}
 
-	return -EIO;
+	return 0;
 }
 
 static int
@@ -371,7 +397,7 @@ netxen_nic_get_regs(struct net_device *d
 		for (i = 3; niu_registers[mode].reg[i - 3] != -1; i++) {
 			/* GB: port specific registers */
 			if (mode == 0 && i >= 19)
-				window = port->portnum * 0x10000;
+				window = port->portnum * NETXEN_NIC_PORT_WINDOW;
 
 			NETXEN_NIC_LOCKED_READ_REG(niu_registers[mode].
 						   reg[i - 3] + window,
@@ -385,7 +411,8 @@ static void
 netxen_nic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	wol->supported = WAKE_UCAST | WAKE_MCAST | WAKE_BCAST | WAKE_MAGIC;
-	wol->wolopts = 0;	/* options can be added depending upon the mode */
+	/* options can be added depending upon the mode */
+	wol->wolopts = 0;
 }
 
 static u32 netxen_nic_get_link(struct net_device *dev)
@@ -531,9 +558,9 @@ static int netxen_nic_reg_test(struct ne
 
 		save = data_read;
 		if (data_read)
-			data_written = data_read & 0xDEADBEEF;
+			data_written = data_read & NETXEN_NIC_INVALID_DATA;
 		else
-			data_written = 0xDEADBEEF;
+			data_written = NETXEN_NIC_INVALID_DATA;
 		netxen_nic_write_w0(adapter,
 				    NETXEN_NIU_GB_MII_MGMT_STATUS(port->
 								  portnum),
@@ -559,9 +586,9 @@ static int netxen_nic_reg_test(struct ne
 
 		save = data_read;
 		if (data_read)
-			data_written = data_read & 0xDEADBEEF;
+			data_written = data_read & NETXEN_NIC_INVALID_DATA;
 		else
-			data_written = 0xDEADBEEF;
+			data_written = NETXEN_NIC_INVALID_DATA;
 		netxen_nic_write_w0(adapter,
 				    NETXEN_NIU_GB_MII_MGMT_INDICATE(port->
 								    portnum),
@@ -587,9 +614,9 @@ static int netxen_nic_reg_test(struct ne
 
 		save = data_read;
 		if (data_read)
-			data_written = data_read & 0xDEADBEEF;
+			data_written = data_read & NETXEN_NIC_INVALID_DATA;
 		else
-			data_written = 0xDEADBEEF;
+			data_written = NETXEN_NIC_INVALID_DATA;
 		netxen_nic_write_w0(adapter,
 				    NETXEN_NIU_GB_INTERFACE_STATUS(port->
 								   portnum),
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 83bf28b..72c6ec4 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -6,12 +6,12 @@
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
@@ -397,6 +397,7 @@ enum {
 
 #define NETXEN_ROMUSB_ROM_INSTR_OPCODE	(ROMUSB_ROM + 0x0004)
 #define NETXEN_ROMUSB_ROM_ADDRESS	(ROMUSB_ROM + 0x0008)
+#define NETXEN_ROMUSB_ROM_WDATA		(ROMUSB_ROM + 0x000c)
 #define NETXEN_ROMUSB_ROM_ABYTE_CNT	(ROMUSB_ROM + 0x0010)
 #define NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT (ROMUSB_ROM + 0x0014)
 #define NETXEN_ROMUSB_ROM_RDATA		(ROMUSB_ROM + 0x0018)
@@ -404,7 +405,29 @@ enum {
 /* Lock IDs for ROM lock */
 #define ROM_LOCK_DRIVER	0x0d417340
 
-#define NETXEN_PCI_CRB_WINDOWSIZE	0x00100000	/* all are 1MB windows */
+/******************************************************************************
+*
+*    Definitions specific to M25P flash
+*
+*******************************************************************************
+*   Instructions
+*/
+#define M25P_INSTR_WREN		0x06
+#define M25P_INSTR_WRDI		0x04
+#define M25P_INSTR_RDID		0x9f
+#define M25P_INSTR_RDSR		0x05
+#define M25P_INSTR_WRSR		0x01
+#define M25P_INSTR_READ		0x03
+#define M25P_INSTR_FAST_READ	0x0b
+#define M25P_INSTR_PP		0x02
+#define M25P_INSTR_SE		0xd8
+#define M25P_INSTR_BE		0xc7
+#define M25P_INSTR_DP		0xb9
+#define M25P_INSTR_RES		0xab
+
+/* all are 1MB windows */
+
+#define NETXEN_PCI_CRB_WINDOWSIZE	0x00100000
 #define NETXEN_PCI_CRB_WINDOW(A)	\
 	(NETXEN_PCI_CRBSPACE + (A)*NETXEN_PCI_CRB_WINDOWSIZE)
 
@@ -505,6 +528,12 @@ enum {
 #define	NETXEN_NIU_XG_PAUSE_LEVEL	(NETXEN_CRB_NIU + 0x000dc)
 #define	NETXEN_NIU_XG_SEL		(NETXEN_CRB_NIU + 0x00128)
 
+#define NETXEN_NIU_FULL_LEVEL_XG	(NETXEN_CRB_NIU + 0x00450)
+
+#define NETXEN_NIU_XG1_RESET	    	(NETXEN_CRB_NIU + 0x0011c)
+#define NETXEN_NIU_XG1_POWER_DOWN	(NETXEN_CRB_NIU + 0x00120)
+#define NETXEN_NIU_XG1_RESET_PLL	(NETXEN_CRB_NIU + 0x00124)
+
 #define NETXEN_MAC_ADDR_CNTL_REG	(NETXEN_CRB_NIU + 0x1000)
 
 #define	NETXEN_MULTICAST_ADDR_HI_0	(NETXEN_CRB_NIU + 0x1010)
@@ -568,6 +597,29 @@ enum {
 #define	NETXEN_NIU_XGE_REMOTE_ERROR_CNT		(NETXEN_CRB_NIU + 0x70050)
 #define	NETXEN_NIU_XGE_CONTROL_CHAR_CNT		(NETXEN_CRB_NIU + 0x70054)
 #define	NETXEN_NIU_XGE_PAUSE_FRAME_CNT		(NETXEN_CRB_NIU + 0x70058)
+#define NETXEN_NIU_XG1_CONFIG_0			(NETXEN_CRB_NIU + 0x80000)
+#define NETXEN_NIU_XG1_CONFIG_1			(NETXEN_CRB_NIU + 0x80004)
+#define NETXEN_NIU_XG1_IPG			(NETXEN_CRB_NIU + 0x80008)
+#define NETXEN_NIU_XG1_STATION_ADDR_0_HI	(NETXEN_CRB_NIU + 0x8000c)
+#define NETXEN_NIU_XG1_STATION_ADDR_0_1		(NETXEN_CRB_NIU + 0x80010)
+#define NETXEN_NIU_XG1_STATION_ADDR_1_LO	(NETXEN_CRB_NIU + 0x80014)
+#define NETXEN_NIU_XG1_STATUS		    	(NETXEN_CRB_NIU + 0x80018)
+#define NETXEN_NIU_XG1_MAX_FRAME_SIZE	   	(NETXEN_CRB_NIU + 0x8001c)
+#define NETXEN_NIU_XG1_PAUSE_FRAME_VALUE	(NETXEN_CRB_NIU + 0x80020)
+#define NETXEN_NIU_XG1_TX_BYTE_CNT		(NETXEN_CRB_NIU + 0x80024)
+#define NETXEN_NIU_XG1_TX_FRAME_CNT	 	(NETXEN_CRB_NIU + 0x80028)
+#define NETXEN_NIU_XG1_RX_BYTE_CNT	  	(NETXEN_CRB_NIU + 0x8002c)
+#define NETXEN_NIU_XG1_RX_FRAME_CNT	 	(NETXEN_CRB_NIU + 0x80030)
+#define NETXEN_NIU_XG1_AGGR_ERROR_CNT	   	(NETXEN_CRB_NIU + 0x80034)
+#define NETXEN_NIU_XG1_MULTICAST_FRAME_CNT	(NETXEN_CRB_NIU + 0x80038)
+#define NETXEN_NIU_XG1_UNICAST_FRAME_CNT	(NETXEN_CRB_NIU + 0x8003c)
+#define NETXEN_NIU_XG1_CRC_ERROR_CNT		(NETXEN_CRB_NIU + 0x80040)
+#define NETXEN_NIU_XG1_OVERSIZE_FRAME_ERR	(NETXEN_CRB_NIU + 0x80044)
+#define NETXEN_NIU_XG1_UNDERSIZE_FRAME_ERR	(NETXEN_CRB_NIU + 0x80048)
+#define NETXEN_NIU_XG1_LOCAL_ERROR_CNT		(NETXEN_CRB_NIU + 0x8004c)
+#define NETXEN_NIU_XG1_REMOTE_ERROR_CNT		(NETXEN_CRB_NIU + 0x80050)
+#define NETXEN_NIU_XG1_CONTROL_CHAR_CNT		(NETXEN_CRB_NIU + 0x80054)
+#define NETXEN_NIU_XG1_PAUSE_FRAME_CNT		(NETXEN_CRB_NIU + 0x80058)
 
 /* XG Link status */
 #define XG_LINK_UP	0x10
@@ -580,8 +632,15 @@ enum {
 #define NETXEN_FW_VERSION_SUB	(NETXEN_CAM_RAM(0x158))
 #define NETXEN_ROM_LOCK_ID	(NETXEN_CAM_RAM(0x100))
 
-#define PCIX_PS_OP_ADDR_LO	(0x10000)	/* Used for PS PCI Memory access */
-#define PCIX_PS_OP_ADDR_HI	(0x10004)	/*   via CRB  (PS side only)     */
+#define NETXEN_PHY_LOCK_ID	(NETXEN_CAM_RAM(0x120))
+
+/* Lock IDs for PHY lock */
+#define PHY_LOCK_DRIVER		0x44524956
+
+/* Used for PS PCI Memory access */
+#define PCIX_PS_OP_ADDR_LO	(0x10000)
+/*   via CRB  (PS side only)     */
+#define PCIX_PS_OP_ADDR_HI	(0x10004)
 
 #define PCIX_INT_VECTOR		(0x10100)
 #define PCIX_INT_MASK		(0x10104)
@@ -609,6 +668,8 @@ enum {
 
 #define PCIE_SEM2_LOCK		(0x1c010)	/* Flash lock   */
 #define PCIE_SEM2_UNLOCK	(0x1c014)	/* Flash unlock */
+#define PCIE_SEM3_LOCK	  	(0x1c018)	/* Phy lock     */
+#define PCIE_SEM3_UNLOCK	(0x1c01c)	/* Phy unlock   */
 
 #define PCIE_TGT_SPLIT_CHICKEN	(0x12080)
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 9603c63..99e647a 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -6,12 +6,12 @@
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
@@ -43,15 +43,26 @@
 #define NETXEN_FLASH_BASE	(BOOTLD_START)
 #define NETXEN_PHANTOM_MEM_BASE	(NETXEN_FLASH_BASE)
 #define NETXEN_MAX_MTU		8000
-#define NETXEN_MIN_MTU          64
+#define NETXEN_MIN_MTU		64
 #define NETXEN_ETH_FCS_SIZE     4
 #define NETXEN_ENET_HEADER_SIZE 14
-#define NETXEN_WINDOW_ONE 0x2000000	/* CRB Window: bit 25 of CRB address */
+#define NETXEN_WINDOW_ONE 	0x2000000	/*CRB Window: bit 25 of CRB address */
 #define NETXEN_FIRMWARE_LEN 	((16 * 1024) / 4)
 #define NETXEN_NIU_HDRSIZE	(0x1 << 6)
 #define NETXEN_NIU_TLRSIZE	(0x1 << 5)
 
-unsigned long netxen_nic_pci_set_window(void __iomem * pci_base,
+#define lower32(x)		((u32)((x) & 0xffffffff))
+#define upper32(x)			\
+	((u32)(((unsigned long long)(x) >> 32) & 0xffffffff))
+
+#define NETXEN_NIC_ZERO_PAUSE_ADDR     0ULL
+#define NETXEN_NIC_UNIT_PAUSE_ADDR     0x200ULL
+#define NETXEN_NIC_EPG_PAUSE_ADDR1     0x2200010000c28001ULL
+#define NETXEN_NIC_EPG_PAUSE_ADDR2     0x0100088866554433ULL
+
+#define NETXEN_NIC_WINDOW_MARGIN 0x100000
+
+unsigned long netxen_nic_pci_set_window(struct netxen_adapter *adapter,
 					unsigned long long addr);
 void netxen_free_hw_resources(struct netxen_adapter *adapter);
 
@@ -93,7 +104,9 @@ void netxen_nic_set_multi(struct net_dev
 						  port->portnum,
 						  NETXEN_NIU_PROMISC_MODE);
 	} else {
-		if (adapter->ops->unset_promisc)
+		if (adapter->ops->unset_promisc &&
+		    adapter->ahw.boardcfg.board_type
+		    != NETXEN_BRDTYPE_P2_SB31_10G_IMEZ)
 			adapter->ops->unset_promisc(adapter,
 						    port->portnum,
 						    NETXEN_NIU_NON_PROMISC_MODE);
@@ -161,26 +174,24 @@ int netxen_nic_change_mtu(struct net_dev
 int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 {
 	struct netxen_hardware_context *hw = &adapter->ahw;
-	int i;
 	u32 state = 0;
 	void *addr;
+	void *pause_addr;
 	int loops = 0, err = 0;
 	int ctx, ring;
 	u32 card_cmdring = 0;
 	struct netxen_rcv_desc_crb *rcv_desc_crb = NULL;
 	struct netxen_recv_context *recv_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
-	struct cmd_desc_type0 *pcmd;
 
-	DPRINTK(INFO, "pci_base: %lx\n", adapter->ahw.pci_base);
 	DPRINTK(INFO, "crb_base: %lx %lx", NETXEN_PCI_CRBSPACE,
-		adapter->ahw.pci_base + NETXEN_PCI_CRBSPACE);
+		PCI_OFFSET_SECOND_RANGE(adapter, NETXEN_PCI_CRBSPACE));
 	DPRINTK(INFO, "cam base: %lx %lx", NETXEN_CRB_CAM,
-		adapter->ahw.pci_base + NETXEN_CRB_CAM);
+		pci_base_offset(adapter, NETXEN_CRB_CAM));
 	DPRINTK(INFO, "cam RAM: %lx %lx", NETXEN_CAM_RAM_BASE,
-		adapter->ahw.pci_base + NETXEN_CAM_RAM_BASE);
+		pci_base_offset(adapter, NETXEN_CAM_RAM_BASE));
 	DPRINTK(INFO, "NIC base:%lx %lx\n", NIC_CRB_BASE_PORT1,
-		adapter->ahw.pci_base + NIC_CRB_BASE_PORT1);
+		pci_base_offset(adapter, NIC_CRB_BASE_PORT1));
 
 	/* Window 1 call */
 	card_cmdring = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_CMDRING));
@@ -214,25 +225,34 @@ int netxen_nic_hw_resources(struct netxe
 	}
 	DPRINTK(INFO, "Recieve Peg ready too. starting stuff\n");
 
-	addr = pci_alloc_consistent(adapter->ahw.pdev,
-				    sizeof(struct cmd_desc_type0) *
-				    adapter->max_tx_desc_count,
-				    &hw->cmd_desc_phys_addr);
+	addr = netxen_alloc(adapter->ahw.pdev,
+			    sizeof(struct cmd_desc_type0) *
+			    adapter->max_tx_desc_count,
+			    &hw->cmd_desc_phys_addr, &hw->cmd_desc_pdev);
+
 	if (addr == NULL) {
 		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
-		err = -ENOMEM;
-		return err;
+		return -ENOMEM;
+	}
+
+	pause_addr = netxen_alloc(adapter->ahw.pdev, 512,
+				  (dma_addr_t *) & hw->pause_physaddr,
+				  &hw->pause_pdev);
+	if (pause_addr == NULL) {
+		DPRINTK(1, ERR, "bad return from pci_alloc_consistent\n");
+		return -ENOMEM;
 	}
 
-	/* we need to prelink all of the cmd descriptors */
-	pcmd = (struct cmd_desc_type0 *)addr;
-	for (i = 1; i < adapter->max_tx_desc_count; i++) {
-		pcmd->netxen_next =
-		    (card_cmdring + i * sizeof(struct cmd_desc_type0));
-		pcmd++;
+	hw->pauseaddr = (char *)pause_addr;
+	{
+		u64 *ptr = (u64 *) pause_addr;
+		*ptr++ = NETXEN_NIC_ZERO_PAUSE_ADDR;
+		*ptr++ = NETXEN_NIC_ZERO_PAUSE_ADDR;
+		*ptr++ = NETXEN_NIC_UNIT_PAUSE_ADDR;
+		*ptr++ = NETXEN_NIC_ZERO_PAUSE_ADDR;
+		*ptr++ = NETXEN_NIC_EPG_PAUSE_ADDR1;
+		*ptr++ = NETXEN_NIC_EPG_PAUSE_ADDR2;
 	}
-	/* fill in last link (point to first) */
-	pcmd->netxen_next = card_cmdring;
 
 	hw->cmd_desc_head = (struct cmd_desc_type0 *)addr;
 
@@ -241,9 +261,10 @@ int netxen_nic_hw_resources(struct netxe
 
 		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
 			rcv_desc = &recv_ctx->rcv_desc[ring];
-			addr = pci_alloc_consistent(adapter->ahw.pdev,
-						    RCV_DESC_RINGSIZE,
-						    &rcv_desc->phys_addr);
+			addr = netxen_alloc(adapter->ahw.pdev,
+					    RCV_DESC_RINGSIZE,
+					    &rcv_desc->phys_addr,
+					    &rcv_desc->phys_pdev);
 			if (addr == NULL) {
 				DPRINTK(ERR, "bad return from "
 					"pci_alloc_consistent\n");
@@ -254,10 +275,11 @@ int netxen_nic_hw_resources(struct netxe
 			rcv_desc->desc_head = (struct rcv_desc *)addr;
 		}
 
-		addr = pci_alloc_consistent(adapter->ahw.pdev,
-					    STATUS_DESC_RINGSIZE,
-					    &recv_ctx->
-					    rcv_status_desc_phys_addr);
+		addr = netxen_alloc(adapter->ahw.pdev,
+				    STATUS_DESC_RINGSIZE,
+				    &recv_ctx->
+				    rcv_status_desc_phys_addr,
+				    &recv_ctx->rcv_status_desc_pdev);
 		if (addr == NULL) {
 			DPRINTK(ERR, "bad return from"
 				" pci_alloc_consistent\n");
@@ -273,19 +295,20 @@ int netxen_nic_hw_resources(struct netxe
 			DPRINTK(INFO, "ring #%d crb global ring reg 0x%x\n",
 				ring, rcv_desc_crb->crb_globalrcv_ring);
 			/* Window = 1 */
-			writel(rcv_desc->phys_addr,
+			writel(lower32(rcv_desc->phys_addr),
 			       NETXEN_CRB_NORMALIZE(adapter,
 						    rcv_desc_crb->
 						    crb_globalrcv_ring));
 			DPRINTK(INFO, "GLOBAL_RCV_RING ctx %d, addr 0x%x"
-				" val 0x%x,"
+				" val 0x%llx,"
 				" virt %p\n", ctx,
 				rcv_desc_crb->crb_globalrcv_ring,
-				rcv_desc->phys_addr, rcv_desc->desc_head);
+				(unsigned long long)rcv_desc->phys_addr,
+				+rcv_desc->desc_head);
 		}
 
 		/* Window = 1 */
-		writel(recv_ctx->rcv_status_desc_phys_addr,
+		writel(lower32(recv_ctx->rcv_status_desc_phys_addr),
 		       NETXEN_CRB_NORMALIZE(adapter,
 					    recv_crb_registers[ctx].
 					    crb_rcvstatus_ring));
@@ -293,13 +316,19 @@ int netxen_nic_hw_resources(struct netxe
 			" val 0x%x,virt%p\n",
 			ctx,
 			recv_crb_registers[ctx].crb_rcvstatus_ring,
-			recv_ctx->rcv_status_desc_phys_addr,
+			(unsigned long long)recv_ctx->rcv_status_desc_phys_addr,
 			recv_ctx->rcv_status_desc_head);
 	}
 	/* Window = 1 */
-	writel(hw->cmd_desc_phys_addr,
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_LO));
+	writel(lower32(hw->pause_physaddr),
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_PAUSE_ADDR_LO));
+	writel(upper32(hw->pause_physaddr),
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_PAUSE_ADDR_HI));
 
+	writel(lower32(hw->cmd_desc_phys_addr),
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_LO));
+	writel(upper32(hw->cmd_desc_phys_addr),
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_HI));
 	return err;
 }
 
@@ -310,13 +339,19 @@ void netxen_free_hw_resources(struct net
 	int ctx, ring;
 
 	if (adapter->ahw.cmd_desc_head != NULL) {
-		pci_free_consistent(adapter->ahw.pdev,
+		pci_free_consistent(adapter->ahw.cmd_desc_pdev,
 				    sizeof(struct cmd_desc_type0) *
 				    adapter->max_tx_desc_count,
 				    adapter->ahw.cmd_desc_head,
 				    adapter->ahw.cmd_desc_phys_addr);
 		adapter->ahw.cmd_desc_head = NULL;
 	}
+	if (adapter->ahw.pauseaddr != NULL) {
+		pci_free_consistent(adapter->ahw.pause_pdev, 512,
+				    adapter->ahw.pauseaddr,
+				    adapter->ahw.pause_physaddr);
+		adapter->ahw.pauseaddr = NULL;
+	}
 
 	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
 		recv_ctx = &adapter->recv_ctx[ctx];
@@ -324,7 +359,7 @@ void netxen_free_hw_resources(struct net
 			rcv_desc = &recv_ctx->rcv_desc[ring];
 
 			if (rcv_desc->desc_head != NULL) {
-				pci_free_consistent(adapter->ahw.pdev,
+				pci_free_consistent(rcv_desc->phys_pdev,
 						    RCV_DESC_RINGSIZE,
 						    rcv_desc->desc_head,
 						    rcv_desc->phys_addr);
@@ -333,7 +368,7 @@ void netxen_free_hw_resources(struct net
 		}
 
 		if (recv_ctx->rcv_status_desc_head != NULL) {
-			pci_free_consistent(adapter->ahw.pdev,
+			pci_free_consistent(recv_ctx->rcv_status_desc_pdev,
 					    STATUS_DESC_RINGSIZE,
 					    recv_ctx->rcv_status_desc_head,
 					    recv_ctx->
@@ -360,10 +395,10 @@ void netxen_tso_check(struct netxen_adap
 			return;
 		}
 	}
+	adapter->stats.xmitcsummed++;
 	CMD_DESC_TCP_HDR_OFFSET_WRT(desc, skb->h.raw - skb->data);
 	desc->length_tcp_hdr = cpu_to_le32(desc->length_tcp_hdr);
 	desc->ip_hdr_offset = skb->nh.raw - skb->data;
-	adapter->stats.xmitcsummed++;
 }
 
 int netxen_is_flash_supported(struct netxen_adapter *adapter)
@@ -373,7 +408,7 @@ int netxen_is_flash_supported(struct net
 
 	/* if the flash size less than 4Mb, make huge war cry and die */
 	for (j = 1; j < 4; j++) {
-		addr = j * 0x100000;
+		addr = j * NETXEN_NIC_WINDOW_MARGIN;
 		for (i = 0; i < (sizeof(locs) / sizeof(locs[0])); i++) {
 			if (netxen_rom_fast_read(adapter, locs[i], &val01) == 0
 			    && netxen_rom_fast_read(adapter, (addr + locs[i]),
@@ -458,7 +493,9 @@ void netxen_nic_pci_change_crbwindow(str
 	 * register address is received by PCI. The direct region bypasses
 	 * the CRB bus.
 	 */
-	offset = adapter->ahw.pci_base + NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW);
+	offset =
+	    PCI_OFFSET_SECOND_RANGE(adapter,
+				    NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW));
 
 	if (wndw & 0x1)
 		wndw = NETXEN_WINDOW_ONE;
@@ -497,8 +534,8 @@ void netxen_load_firmware(struct netxen_
 				"loading flash image\n");
 			return;
 		}
-		off = netxen_nic_pci_set_window(adapter->ahw.pci_base, memaddr);
-		addr = (adapter->ahw.pci_base + off);
+		off = netxen_nic_pci_set_window(adapter, memaddr);
+		addr = pci_base_offset(adapter, off);
 		writel(data, addr);
 		flashaddr += 4;
 		memaddr += 4;
@@ -521,14 +558,19 @@ netxen_nic_hw_write_wx(struct netxen_ada
 	if (ADDR_IN_WINDOW1(off)) {
 		addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	} else {		/* Window 0 */
-		addr = adapter->ahw.pci_base + off;
+		addr = pci_base_offset(adapter, off);
 		netxen_nic_pci_change_crbwindow(adapter, 0);
 	}
 
 	DPRINTK(INFO, "writing to base %lx offset %llx addr %p"
 		" data %llx len %d\n",
-		adapter->ahw.pci_base, off, addr,
+		pci_base(adapter, off), off, addr,
 		*(unsigned long long *)data, len);
+	if (!addr) {
+		netxen_nic_pci_change_crbwindow(adapter, 1);
+		return 1;
+	}
+
 	switch (len) {
 	case 1:
 		writeb(*(u8 *) data, addr);
@@ -566,12 +608,16 @@ netxen_nic_hw_read_wx(struct netxen_adap
 	if (ADDR_IN_WINDOW1(off)) {	/* Window 1 */
 		addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	} else {		/* Window 0 */
-		addr = adapter->ahw.pci_base + off;
+		addr = pci_base_offset(adapter, off);
 		netxen_nic_pci_change_crbwindow(adapter, 0);
 	}
 
 	DPRINTK(INFO, "reading from base %lx offset %llx addr %p\n",
-		adapter->ahw.pci_base, off, addr);
+		pci_base(adapter, off), off, addr);
+	if (!addr) {
+		netxen_nic_pci_change_crbwindow(adapter, 1);
+		return 1;
+	}
 	switch (len) {
 	case 1:
 		*(u8 *) data = readb(addr);
@@ -604,7 +650,7 @@ void netxen_nic_reg_write(struct netxen_
 
 	addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	DPRINTK(INFO, "writing to base %lx offset %llx addr %p data %x\n",
-		adapter->ahw.pci_base, off, addr, val);
+		pci_base(adapter, off), off, addr);
 	writel(val, addr);
 
 }
@@ -629,7 +675,7 @@ void netxen_nic_write_w0(struct netxen_a
 	void __iomem *addr;
 
 	netxen_nic_pci_change_crbwindow(adapter, 0);
-	addr = (void __iomem *)(adapter->ahw.pci_base + index);
+	addr = (void __iomem *)(pci_base_offset(adapter, index));
 	writel(value, addr);
 	netxen_nic_pci_change_crbwindow(adapter, 1);
 }
@@ -639,7 +685,7 @@ void netxen_nic_read_w0(struct netxen_ad
 {
 	void __iomem *addr;
 
-	addr = (void __iomem *)(adapter->ahw.pci_base + index);
+	addr = (void __iomem *)(pci_base_offset(adapter, index));
 
 	netxen_nic_pci_change_crbwindow(adapter, 0);
 	*value = readl(addr);
@@ -649,7 +695,8 @@ void netxen_nic_read_w0(struct netxen_ad
 int netxen_pci_set_window_warning_count = 0;
 
 unsigned long
-netxen_nic_pci_set_window(void __iomem * pci_base, unsigned long long addr)
+netxen_nic_pci_set_window(struct netxen_adapter *adapter,
+			  unsigned long long addr)
 {
 	static int ddr_mn_window = -1;
 	static int qdr_sn_window = -1;
@@ -661,12 +708,15 @@ netxen_nic_pci_set_window(void __iomem *
 		window = (addr >> 25) & 0x3ff;
 		if (ddr_mn_window != window) {
 			ddr_mn_window = window;
-			writel(window, pci_base +
-			       NETXEN_PCIX_PH_REG(PCIX_MN_WINDOW));
+			writel(window, PCI_OFFSET_SECOND_RANGE(adapter,
+							       NETXEN_PCIX_PH_REG
+							       (PCIX_MN_WINDOW)));
 			/* MUST make sure window is set before we forge on... */
-			readl(pci_base + NETXEN_PCIX_PH_REG(PCIX_MN_WINDOW));
+			readl(PCI_OFFSET_SECOND_RANGE(adapter,
+						      NETXEN_PCIX_PH_REG
+						      (PCIX_MN_WINDOW)));
 		}
-		addr -= (window * 0x2000000);
+		addr -= (window * NETXEN_WINDOW_ONE);
 		addr += NETXEN_PCI_DDR_NET;
 	} else if (ADDR_IN_RANGE(addr, NETXEN_ADDR_OCM0, NETXEN_ADDR_OCM0_MAX)) {
 		addr -= NETXEN_ADDR_OCM0;
@@ -682,10 +732,14 @@ netxen_nic_pci_set_window(void __iomem *
 		window = (addr >> 22) & 0x3f;
 		if (qdr_sn_window != window) {
 			qdr_sn_window = window;
-			writel((window << 22), pci_base +
-			       NETXEN_PCIX_PH_REG(PCIX_SN_WINDOW));
+			writel((window << 22),
+			       PCI_OFFSET_SECOND_RANGE(adapter,
+						       NETXEN_PCIX_PH_REG
+						       (PCIX_SN_WINDOW)));
 			/* MUST make sure window is set before we forge on... */
-			readl(pci_base + NETXEN_PCIX_PH_REG(PCIX_SN_WINDOW));
+			readl(PCI_OFFSET_SECOND_RANGE(adapter,
+						      NETXEN_PCIX_PH_REG
+						      (PCIX_SN_WINDOW)));
 		}
 		addr -= (window * 0x400000);
 		addr += NETXEN_PCI_QDR_NET;
@@ -811,7 +865,7 @@ netxen_crb_writelit_adapter(struct netxe
 		writel(data, NETXEN_CRB_NORMALIZE(adapter, off));
 	} else {
 		netxen_nic_pci_change_crbwindow(adapter, 0);
-		addr = (void __iomem *)(adapter->ahw.pci_base + off);
+		addr = (void __iomem *)(pci_base_offset(adapter, off));
 		writel(data, addr);
 		netxen_nic_pci_change_crbwindow(adapter, 1);
 	}
@@ -879,6 +933,10 @@ void netxen_nic_flash_print(struct netxe
 	u32 fw_major = 0;
 	u32 fw_minor = 0;
 	u32 fw_build = 0;
+	char brd_name[NETXEN_MAX_SHORT_NAME];
+	struct netxen_new_user_info user_info;
+	int i, addr = USER_START;
+	u32 *ptr32;
 
 	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
 	if (board_info->magic != NETXEN_BDINFO_MAGIC) {
@@ -894,6 +952,24 @@ void netxen_nic_flash_print(struct netxe
 		valid = 0;
 	}
 	if (valid) {
+		ptr32 = (u32 *) & user_info;
+		for (i = 0;
+		     i < sizeof(struct netxen_new_user_info) / sizeof(u32);
+		     i++) {
+			if (netxen_rom_fast_read(adapter, addr, ptr32) == -1) {
+				printk("%s: ERROR reading %s board userarea.\n",
+				       netxen_nic_driver_name,
+				       netxen_nic_driver_name);
+				return;
+			}
+			ptr32++;
+			addr += sizeof(u32);
+		}
+		get_brd_name_by_type(board_info->board_type, brd_name);
+
+		printk("NetXen %s Board S/N %s  Chip id 0x%x\n",
+		       brd_name, user_info.serial_num, board_info->chip_id);
+
 		printk("NetXen %s Board #%d, Chip id 0x%x\n",
 		       board_info->board_type == 0x0b ? "XGB" : "GBE",
 		       board_info->board_num, board_info->chip_id);
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index fb1a025..201a636 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -82,9 +82,9 @@ struct netxen_adapter;
 
 #define NETXEN_PCI_MAPSIZE_BYTES  (NETXEN_PCI_MAPSIZE << 20)
 
-#define NETXEN_NIC_LOCKED_READ_REG(X, Y)   			\
-	addr = (adapter->ahw.pci_base + X);     \
-	*(u32 *)Y = readl((void __iomem*) addr);
+#define NETXEN_NIC_LOCKED_READ_REG(X, Y)	\
+	addr = pci_base_offset(adapter, (X));	\
+	*(u32 *)Y = readl(addr);
 
 struct netxen_port;
 void netxen_nic_set_link_parameters(struct netxen_port *port);
@@ -472,6 +472,8 @@ int netxen_niu_xg_macaddr_set(struct net
 /* Generic enable for GbE ports. Will detect the speed of the link. */
 int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port);
 
+int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port);
+
 /* Disable a GbE interface */
 int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter, int port);
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index d122e51..0dca029 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -51,11 +51,13 @@ static unsigned int crb_addr_xform[NETXE
 	crb_addr_xform[NETXEN_HW_PX_MAP_CRB_##name] = \
 	NETXEN_HW_CRB_HUB_AGT_ADR_##name << 20
 
+#define NETXEN_NIC_XDMA_RESET 0x8000ff
+
 static inline void
 netxen_nic_locked_write_reg(struct netxen_adapter *adapter,
 			    unsigned long off, int *data)
 {
-	void __iomem *addr = (adapter->ahw.pci_base + off);
+	void __iomem *addr = pci_base_offset(adapter, off);
 	writel(*data, addr);
 }
 
@@ -141,6 +143,24 @@ int netxen_init_firmware(struct netxen_a
 	return err;
 }
 
+#define NETXEN_ADDR_LIMIT 0xffffffffULL
+
+void *netxen_alloc(struct pci_dev *pdev, size_t sz, dma_addr_t * ptr,
+		   struct pci_dev **used_dev)
+{
+	void *addr;
+
+	addr = pci_alloc_consistent(pdev, sz, ptr);
+	if ((unsigned long long)(*ptr) < NETXEN_ADDR_LIMIT) {
+		*used_dev = pdev;
+		return addr;
+	}
+	pci_free_consistent(pdev, sz, addr, *ptr);
+	addr = pci_alloc_consistent(NULL, sz, ptr);
+	*used_dev = NULL;
+	return addr;
+}
+
 void netxen_initialize_adapter_sw(struct netxen_adapter *adapter)
 {
 	int ctxid, ring;
@@ -177,23 +197,17 @@ void netxen_initialize_adapter_sw(struct
 
 void netxen_initialize_adapter_hw(struct netxen_adapter *adapter)
 {
+	int ports = 0;
+	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
+
 	if (netxen_nic_get_board_info(adapter) != 0)
 		printk("%s: Error getting board config info.\n",
 		       netxen_nic_driver_name);
-
-	switch (adapter->ahw.board_type) {
-	case NETXEN_NIC_GBE:
-		adapter->ahw.max_ports = 4;
-		break;
-
-	case NETXEN_NIC_XGBE:
-		adapter->ahw.max_ports = 1;
-		break;
-
-	default:
+	get_brd_port_by_type(board_info->board_type, &ports);
+	if (ports == 0)
 		printk(KERN_ERR "%s: Unknown board type\n",
 		       netxen_nic_driver_name);
-	}
+	adapter->ahw.max_ports = ports;
 }
 
 void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
@@ -225,6 +239,7 @@ void netxen_initialize_adapter_ops(struc
 		ops->handle_phy_intr = netxen_nic_xgbe_handle_phy_intr;
 		ops->macaddr_set = netxen_niu_xg_macaddr_set;
 		ops->set_mtu = netxen_nic_set_mtu_xgb;
+		ops->init_port = netxen_niu_xg_init_port;
 		ops->set_promisc = netxen_niu_xg_set_promiscuous_mode;
 		ops->unset_promisc = netxen_niu_xg_set_promiscuous_mode;
 		ops->stop_port = netxen_niu_disable_xg_port;
@@ -295,15 +310,6 @@ static inline int rom_lock(struct netxen
 	return 0;
 }
 
-static inline void rom_unlock(struct netxen_adapter *adapter)
-{
-	u32 val;
-
-	/* release semaphore2 */
-	netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(PCIE_SEM2_UNLOCK), &val);
-
-}
-
 int netxen_wait_rom_done(struct netxen_adapter *adapter)
 {
 	long timeout = 0;
@@ -321,6 +327,81 @@ int netxen_wait_rom_done(struct netxen_a
 	return 0;
 }
 
+static inline int netxen_rom_wren(struct netxen_adapter *adapter)
+{
+	/* Set write enable latch in ROM status register */
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE,
+			     M25P_INSTR_WREN);
+	if (netxen_wait_rom_done(adapter)) {
+		return -1;
+	}
+	return 0;
+}
+
+static inline unsigned int netxen_rdcrbreg(struct netxen_adapter *adapter,
+					   unsigned int addr)
+{
+	unsigned int data = 0xdeaddead;
+	data = netxen_nic_reg_read(adapter, addr);
+	return data;
+}
+
+static inline int netxen_do_rom_rdsr(struct netxen_adapter *adapter)
+{
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE,
+			     M25P_INSTR_RDSR);
+	if (netxen_wait_rom_done(adapter)) {
+		return -1;
+	}
+	return netxen_rdcrbreg(adapter, NETXEN_ROMUSB_ROM_RDATA);
+}
+
+static inline void netxen_rom_unlock(struct netxen_adapter *adapter)
+{
+	u32 val;
+
+	/* release semaphore2 */
+	netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(PCIE_SEM2_UNLOCK), &val);
+
+}
+
+int netxen_rom_wip_poll(struct netxen_adapter *adapter)
+{
+	long timeout = 0;
+	long wip = 1;
+	int val;
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
+	while (wip != 0) {
+		val = netxen_do_rom_rdsr(adapter);
+		wip = val & 1;
+		timeout++;
+		if (timeout > rom_max_timeout) {
+			return -1;
+		}
+	}
+	return 0;
+}
+
+static inline int do_rom_fast_write(struct netxen_adapter *adapter,
+				    int addr, int data)
+{
+	if (netxen_rom_wren(adapter)) {
+		return -1;
+	}
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_WDATA, data);
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE,
+			     M25P_INSTR_PP);
+	if (netxen_wait_rom_done(adapter)) {
+		netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
+		return -1;
+	}
+
+	return netxen_rom_wip_poll(adapter);
+}
+
 static inline int
 do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
 {
@@ -350,7 +431,43 @@ int netxen_rom_fast_read(struct netxen_a
 		return -EIO;
 
 	ret = do_rom_fast_read(adapter, addr, valp);
-	rom_unlock(adapter);
+	netxen_rom_unlock(adapter);
+	return ret;
+}
+
+int netxen_rom_fast_write(struct netxen_adapter *adapter, int addr, int data)
+{
+	int ret = 0;
+
+	if (rom_lock(adapter) != 0) {
+		return -1;
+	}
+	ret = do_rom_fast_write(adapter, addr, data);
+	netxen_rom_unlock(adapter);
+	return ret;
+}
+int netxen_do_rom_se(struct netxen_adapter *adapter, int addr)
+{
+	netxen_rom_wren(adapter);
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
+	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE,
+			     M25P_INSTR_SE);
+	if (netxen_wait_rom_done(adapter)) {
+		netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
+		return -1;
+	}
+	return netxen_rom_wip_poll(adapter);
+}
+
+int netxen_rom_se(struct netxen_adapter *adapter, int addr)
+{
+	int ret = 0;
+	if (rom_lock(adapter) != 0) {
+		return -1;
+	}
+	ret = netxen_do_rom_se(adapter, addr);
+	netxen_rom_unlock(adapter);
 	return ret;
 }
 
@@ -372,7 +489,7 @@ int netxen_pinit_from_rom(struct netxen_
 	/* resetall */
 	status = netxen_nic_get_board_info(adapter);
 	if (status)
-		printk("%s: pinit_from_rom: Error getting board info\n",
+		printk("%s: netxen_pinit_from_rom: Error getting board info\n",
 		       netxen_nic_driver_name);
 
 	netxen_crb_writelit_adapter(adapter, NETXEN_ROMUSB_GLB_SW_RESET,
@@ -408,8 +525,8 @@ int netxen_pinit_from_rom(struct netxen_
 		}
 		buf = kcalloc(n, sizeof(struct crb_addr_pair), GFP_KERNEL);
 		if (buf == NULL) {
-			printk("%s: pinit_from_rom: Unable to calloc memory.\n",
-			       netxen_nic_driver_name);
+			printk("%s: netxen_pinit_from_rom: Unable to calloc "
+			       "memory.\n", netxen_nic_driver_name);
 			return -ENOMEM;
 		}
 		for (i = 0; i < n; i++) {
@@ -441,7 +558,7 @@ int netxen_pinit_from_rom(struct netxen_
 			if (off == NETXEN_ROMUSB_GLB_SW_RESET) {
 				init_delay = 1;
 				/* hold xdma in reset also */
-				buf[i].data = 0x8000ff;
+				buf[i].data = NETXEN_NIC_XDMA_RESET;
 			}
 
 			if (ADDR_IN_WINDOW1(off)) {
@@ -450,7 +567,7 @@ int netxen_pinit_from_rom(struct netxen_
 			} else {
 				netxen_nic_pci_change_crbwindow(adapter, 0);
 				writel(buf[i].data,
-				       adapter->ahw.pci_base + off);
+				       pci_base_offset(adapter, off));
 
 				netxen_nic_pci_change_crbwindow(adapter, 1);
 			}
@@ -505,18 +622,15 @@ int netxen_pinit_from_rom(struct netxen_
 	return 0;
 }
 
-void netxen_phantom_init(struct netxen_adapter *adapter)
+void netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 {
 	u32 val = 0;
 	int loops = 0;
 
-	netxen_nic_hw_read_wx(adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE, &val, 4);
-	writel(1,
-	       NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
-
-	if (0 == val) {
+	if (!pegtune_val) {
 		while (val != PHAN_INITIALIZE_COMPLETE && loops < 200000) {
 			udelay(100);
+			schedule();
 			val =
 			    readl(NETXEN_CRB_NORMALIZE
 				  (adapter, CRB_CMDPEG_STATE));
@@ -536,7 +650,7 @@ int netxen_nic_rx_has_work(struct netxen
 		    &(adapter->recv_ctx[ctx]);
 		u32 consumer;
 		struct status_desc *desc_head;
-		struct status_desc *desc;	/* used to read status desc here */
+		struct status_desc *desc;
 
 		consumer = recv_ctx->status_rx_consumer;
 		desc_head = recv_ctx->rcv_status_desc_head;
@@ -549,6 +663,53 @@ int netxen_nic_rx_has_work(struct netxen
 	return 0;
 }
 
+static inline int netxen_nic_check_temp(struct netxen_adapter *adapter)
+{
+	int port_num;
+	struct netxen_port *port;
+	struct net_device *netdev;
+	uint32_t temp, temp_state, temp_val;
+	int rv = 0;
+
+	temp = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_TEMP_STATE));
+
+	temp_state = nx_get_temp_state(temp);
+	temp_val = nx_get_temp_val(temp);
+
+	if (temp_state == NX_TEMP_PANIC) {
+		printk(KERN_ALERT
+		       "%s: Device temperature %d degrees C exceeds"
+		       " maximum allowed. Hardware has been shut down.\n",
+		       netxen_nic_driver_name, temp_val);
+		for (port_num = 0; port_num < adapter->ahw.max_ports;
+		     port_num++) {
+			port = adapter->port[port_num];
+			netdev = port->netdev;
+
+			netif_carrier_off(netdev);
+			netif_stop_queue(netdev);
+		}
+		rv = 1;
+	} else if (temp_state == NX_TEMP_WARN) {
+		if (adapter->temp == NX_TEMP_NORMAL) {
+			printk(KERN_ALERT
+			       "%s: Device temperature %d degrees C "
+			       "exceeds operating range."
+			       " Immediate action needed.\n",
+			       netxen_nic_driver_name, temp_val);
+		}
+	} else {
+		if (adapter->temp == NX_TEMP_WARN) {
+			printk(KERN_INFO
+			       "%s: Device temperature is now %d degrees C"
+			       " in normal range.\n", netxen_nic_driver_name,
+			       temp_val);
+		}
+	}
+	adapter->temp = temp_state;
+	return rv;
+}
+
 void netxen_watchdog_task(unsigned long v)
 {
 	int port_num;
@@ -556,6 +717,9 @@ void netxen_watchdog_task(unsigned long
 	struct net_device *netdev;
 	struct netxen_adapter *adapter = (struct netxen_adapter *)v;
 
+	if (netxen_nic_check_temp(adapter))
+		return;
+
 	for (port_num = 0; port_num < adapter->ahw.max_ports; port_num++) {
 		port = adapter->port[port_num];
 		netdev = port->netdev;
@@ -570,8 +734,6 @@ void netxen_watchdog_task(unsigned long
 			netif_wake_queue(netdev);
 	}
 
-	netxen_nic_pci_change_crbwindow(adapter, 1);
-
 	if (adapter->ops->handle_phy_intr)
 		adapter->ops->handle_phy_intr(adapter);
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
@@ -742,7 +904,6 @@ void netxen_process_cmd_ring(unsigned lo
 	 * number as part of the descriptor. This way we will be able to get
 	 * the netdev which is associated with that device.
 	 */
-	/* Window = 1 */
 	consumer =
 	    readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMD_CONSUMER_OFFSET));
 
@@ -861,7 +1022,7 @@ void netxen_post_rx_buffers(struct netxe
 			 * We need to schedule the posting of buffers to the pegs.
 			 */
 			rcv_desc->begin_alloc = index;
-			DPRINTK(ERR, "unm_post_rx_buffers: "
+			DPRINTK(ERR, "netxen_post_rx_buffers: "
 				" allocated only %d buffers\n", count);
 			break;
 		}
diff --git a/drivers/net/netxen/netxen_nic_ioctl.h b/drivers/net/netxen/netxen_nic_ioctl.h
index 806818e..23e53ad 100644
--- a/drivers/net/netxen/netxen_nic_ioctl.h
+++ b/drivers/net/netxen/netxen_nic_ioctl.h
@@ -6,12 +6,12 @@
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
@@ -32,9 +32,11 @@
 
 #include <linux/sockios.h>
 
-#define NETXEN_CMD_START        SIOCDEVPRIVATE
-#define NETXEN_NIC_CMD          (NETXEN_CMD_START + 1)
-#define NETXEN_NIC_NAME         (NETXEN_CMD_START + 2)
+#define NETXEN_CMD_START	SIOCDEVPRIVATE
+#define NETXEN_NIC_CMD		(NETXEN_CMD_START + 1)
+#define NETXEN_NIC_NAME		(NETXEN_CMD_START + 2)
+#define NETXEN_NIC_NAME_LEN	16
+#define NETXEN_NIC_NAME_RSP	"NETXEN"
 
 typedef enum {
 	netxen_nic_cmd_none = 0,
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index f1c3e5a..ae180fe 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -149,47 +149,41 @@ void netxen_handle_port_int(struct netxe
 
 void netxen_nic_isr_other(struct netxen_adapter *adapter)
 {
-	u32 enable, portno;
-	u32 i2qhi;
-
-	/*
-	 * bit 3 is for i2qInt, if high its enabled
-	 * check for phy interrupts
-	 * read vector and check for bit 45 for phy
-	 * clear int by writing the same value into ISR_INT_VECTOR REG
-	 */
-
-	DPRINTK(INFO, "I2Q is the source of INT \n");
+	u32 portno;
+	u32 val, linkup, qg_linksup;
 
 	/* verify the offset */
-	i2qhi = readl(NETXEN_CRB_NORMALIZE(adapter, NETXEN_I2Q_CLR_PCI_HI));
-
-	DPRINTK(INFO, "isr NETXEN_I2Q_CLR_PCI_HI = 0x%x \n", i2qhi);
+	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
+	if (val == adapter->ahw.qg_linksup)
+		return;
 
-	if (i2qhi & 0x4000) {
-		for (portno = 0; portno < NETXEN_NIU_MAX_GBE_PORTS; portno++) {
-			DPRINTK(INFO, "External PHY interrupt ON PORT %d\n",
-				portno);
+	qg_linksup = adapter->ahw.qg_linksup;
+	adapter->ahw.qg_linksup = val;
+	DPRINTK(1, INFO, "%s: link update 0x%08x\n", netxen_nic_driver_name,
+		val);
+	for (portno = 0; portno < NETXEN_NIU_MAX_GBE_PORTS; portno++) {
+		linkup = val & 1;
+		if (linkup != (qg_linksup & 1)) {
+			printk(KERN_INFO "%s: PORT %d link %s\n",
+			       netxen_nic_driver_name, portno,
+			       ((linkup == 0) ? "down" : "up"));
+			netxen_indicate_link_status(adapter, portno, linkup);
+			if (linkup)
+				netxen_nic_set_link_parameters(adapter->
+							       port[portno]);
 
-			enable = 1;
-			netxen_handle_port_int(adapter, portno, enable);
 		}
+		val = val >> 1;
+		qg_linksup = qg_linksup >> 1;
+	}
 
-		/* Clear the interrupt on I2Q */
-		writel((u32) i2qhi,
-		       NETXEN_CRB_NORMALIZE(adapter, NETXEN_I2Q_CLR_PCI_HI));
+	adapter->stats.otherints++;
 
-	}
 }
 
 void netxen_nic_gbe_handle_phy_intr(struct netxen_adapter *adapter)
 {
-	u32 val;
-	val = readl(NETXEN_CRB_NORMALIZE(adapter, ISR_INT_VECTOR));
-	if (val & 0x4) {
-		adapter->stats.otherints++;
-		netxen_nic_isr_other(adapter);
-	}
+	netxen_nic_isr_other(adapter);
 }
 
 void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter)
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index a055208..7f6d154 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -31,6 +31,7 @@
  *
  */
 
+#include <linux/vmalloc.h>
 #include "netxen_nic_hw.h"
 
 #include "netxen_nic.h"
@@ -41,16 +42,19 @@
 #include <linux/dma-mapping.h>
 #include <linux/vmalloc.h>
 
+#define PHAN_VENDOR_ID 0x4040
+
 MODULE_DESCRIPTION("NetXen Multi port (1/10) Gigabit Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(NETXEN_NIC_LINUX_VERSIONID);
 
 char netxen_nic_driver_name[] = "netxen";
 static char netxen_nic_driver_string[] = "NetXen Network Driver version "
-    NETXEN_NIC_LINUX_VERSIONID "-" NETXEN_NIC_BUILD_NO;
+    NETXEN_NIC_LINUX_VERSIONID;
 
 #define NETXEN_NETDEV_WEIGHT 120
 #define NETXEN_ADAPTER_UP_MAGIC 777
+#define NETXEN_NIC_PEG_TUNE 0
 
 /* Local functions to NetXen NIC driver */
 static int __devinit netxen_nic_probe(struct pci_dev *pdev,
@@ -101,7 +105,10 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	struct net_device *netdev = NULL;
 	struct netxen_adapter *adapter = NULL;
 	struct netxen_port *port = NULL;
-	u8 __iomem *mem_ptr = NULL;
+	u8 *mem_ptr0 = NULL;
+	u8 *mem_ptr1 = NULL;
+	u8 *mem_ptr2 = NULL;
+
 	unsigned long mem_base, mem_len;
 	int pci_using_dac, i, err;
 	int ring;
@@ -111,6 +118,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	u64 mac_addr[FLASH_NUM_PORTS + 1];
 	int valid_mac;
 
+	printk(KERN_INFO "%s \n", netxen_nic_driver_string);
 	if ((err = pci_enable_device(pdev)))
 		return err;
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
@@ -138,11 +146,26 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	mem_len = pci_resource_len(pdev, 0);
 
 	/* 128 Meg of memory */
-	mem_ptr = ioremap(mem_base, NETXEN_PCI_MAPSIZE_BYTES);
-	if (mem_ptr == 0UL) {
-		printk(KERN_ERR "%s: Cannot ioremap adapter memory aborting."
-		       ":%p\n", netxen_nic_driver_name, mem_ptr);
+	mem_ptr0 = ioremap(mem_base, FIRST_PAGE_GROUP_SIZE);
+	mem_ptr1 =
+	    ioremap(mem_base + SECOND_PAGE_GROUP_START, SECOND_PAGE_GROUP_SIZE);
+	mem_ptr2 =
+	    ioremap(mem_base + THIRD_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
+
+	if ((mem_ptr0 == 0UL) || (mem_ptr1 == 0UL) || (mem_ptr2 == 0UL)) {
+		DPRINTK(1, ERR,
+			"Cannot remap adapter memory aborting.:"
+			"0 -> %p, 1 -> %p, 2 -> %p\n",
+			mem_ptr0, mem_ptr1, mem_ptr2);
+
 		err = -EIO;
+		if (mem_ptr0)
+			iounmap(mem_ptr0);
+		if (mem_ptr1)
+			iounmap(mem_ptr1);
+		if (mem_ptr2)
+			iounmap(mem_ptr2);
+
 		goto err_out_free_res;
 	}
 
@@ -221,9 +244,17 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	}
 
 	adapter->cmd_buf_arr = cmd_buf_arr;
-	adapter->ahw.pci_base = mem_ptr;
+	adapter->ahw.pci_base0 = mem_ptr0;
+	adapter->ahw.pci_base1 = mem_ptr1;
+	adapter->ahw.pci_base2 = mem_ptr2;
 	spin_lock_init(&adapter->tx_lock);
 	spin_lock_init(&adapter->lock);
+#ifdef CONFIG_IA64
+	netxen_pinit_from_rom(adapter, 0);
+	udelay(500);
+	netxen_load_firmware(adapter);
+#endif
+
 	/* initialize the buffers in adapter */
 	netxen_initialize_adapter_sw(adapter);
 	/*
@@ -262,6 +293,20 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	else
 		valid_mac = 0;
 
+	/*
+	 * Initialize all the CRB registers here.
+	 */
+	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMD_PRODUCER_OFFSET));
+	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMD_CONSUMER_OFFSET));
+	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_LO));
+
+	/* Unlock the HW, prompting the boot sequence */
+	writel(1,
+	       NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
+
+	/* Handshake with the card before we register the devices. */
+	netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
+
 	/* initialize the all the ports */
 
 	for (i = 0; i < adapter->ahw.max_ports; i++) {
@@ -352,15 +397,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	}
 
 	/*
-	 * Initialize all the CRB registers here.
-	 */
-	/* Window = 1 */
-	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMD_PRODUCER_OFFSET));
-	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMD_CONSUMER_OFFSET));
-	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_LO));
-
-	netxen_phantom_init(adapter);
-	/*
 	 * delay a while to ensure that the Pegs are up & running.
 	 * Otherwise, we might see some flaky behaviour.
 	 */
@@ -414,7 +450,10 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	kfree(adapter);
 
       err_out_iounmap:
-	iounmap(mem_ptr);
+	iounmap(mem_ptr0);
+	iounmap(mem_ptr1);
+	iounmap(mem_ptr2);
+
       err_out_free_res:
 	pci_release_regions(pdev);
       err_out_disable_pdev:
@@ -460,7 +499,9 @@ static void __devexit netxen_nic_remove(
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC)
 		netxen_free_hw_resources(adapter);
 
-	iounmap(adapter->ahw.pci_base);
+	iounmap(adapter->ahw.pci_base0);
+	iounmap(adapter->ahw.pci_base1);
+	iounmap(adapter->ahw.pci_base2);
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
@@ -496,7 +537,6 @@ static int netxen_nic_open(struct net_de
 {
 	struct netxen_port *port = netdev_priv(netdev);
 	struct netxen_adapter *adapter = port->adapter;
-	struct netxen_rcv_desc_ctx *rcv_desc;
 	int err = 0;
 	int ctx, ring;
 
@@ -527,11 +567,8 @@ static int netxen_nic_open(struct net_de
 		if (adapter->ops->init_niu)
 			adapter->ops->init_niu(adapter);
 		for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-			for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
-				rcv_desc =
-				    &adapter->recv_ctx[ctx].rcv_desc[ring];
+			for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++)
 				netxen_post_rx_buffers(adapter, ctx, ring);
-			}
 		}
 		adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
 	}
@@ -579,10 +616,6 @@ static int netxen_nic_close(struct net_d
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	/* disable phy_ints */
-	if (adapter->ops->disable_phy_interrupts)
-		adapter->ops->disable_phy_interrupts(adapter, port->portnum);
-
 	adapter->active_ports--;
 
 	if (!adapter->active_ports) {
@@ -690,13 +723,16 @@ static int netxen_nic_xmit_frame(struct
 	local_producer = adapter->cmd_producer;
 	/* There 4 fragments per descriptor */
 	no_of_desc = (frag_count + 3) >> 2;
-	if (skb_shinfo(skb)->gso_size > 0) {
-		no_of_desc++;
-		if (((skb->nh.iph)->ihl * sizeof(u32)) +
-		    ((skb->h.th)->doff * sizeof(u32)) +
-		    sizeof(struct ethhdr) >
-		    (sizeof(struct cmd_desc_type0) - NET_IP_ALIGN)) {
+	if (netdev->features & NETIF_F_TSO) {
+		if (skb_shinfo(skb)->gso_size > 0) {
+
 			no_of_desc++;
+			if (((skb->nh.iph)->ihl * sizeof(u32)) +
+			    ((skb->h.th)->doff * sizeof(u32)) +
+			    sizeof(struct ethhdr) >
+			    (sizeof(struct cmd_desc_type0) - NET_IP_ALIGN)) {
+				no_of_desc++;
+			}
 		}
 	}
 	k = adapter->cmd_producer;
@@ -740,7 +776,7 @@ static int netxen_nic_xmit_frame(struct
 	memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
 	/* Take skb->data itself */
 	pbuf = &adapter->cmd_buf_arr[producer];
-	if (skb_shinfo(skb)->gso_size > 0) {
+	if ((netdev->features & NETIF_F_TSO) && skb_shinfo(skb)->gso_size > 0) {
 		pbuf->mss = skb_shinfo(skb)->gso_size;
 		hwdesc->mss = skb_shinfo(skb)->gso_size;
 	} else {
@@ -934,9 +970,10 @@ netxen_handle_int(struct netxen_adapter
 		/* Window = 0 or 1 */
 		do {
 			writel(0xffffffff, (void __iomem *)
-			       (adapter->ahw.pci_base + ISR_INT_TARGET_STATUS));
+			       (PCI_OFFSET_SECOND_RANGE
+				(adapter, ISR_INT_TARGET_STATUS)));
 			mask = readl((void __iomem *)
-				     (adapter->ahw.pci_base + ISR_INT_VECTOR));
+				     pci_base_offset(adapter, ISR_INT_VECTOR));
 		} while (((mask & 0x80) != 0) && (++count < 32));
 		if ((mask & 0x80) != 0)
 			printk("Could not disable interrupt completely\n");
@@ -1065,8 +1102,10 @@ static int
 netxen_nic_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	int err = 0;
+	unsigned long nr_bytes = 0;
 	struct netxen_port *port = netdev_priv(netdev);
 	struct netxen_adapter *adapter = port->adapter;
+	char dev_name[NETXEN_NIC_NAME_LEN];
 
 	DPRINTK(INFO, "doing ioctl for %s\n", netdev->name);
 	switch (cmd) {
@@ -1077,7 +1116,13 @@ netxen_nic_ioctl(struct net_device *netd
 	case NETXEN_NIC_NAME:
 		DPRINTK(INFO, "ioctl cmd for NetXen\n");
 		if (ifr->ifr_data) {
-			put_user(port->portnum, (u16 __user *) ifr->ifr_data);
+			sprintf(dev_name, "%s-%d", NETXEN_NIC_NAME_RSP,
+				port->portnum);
+			nr_bytes = copy_to_user((char *)ifr->ifr_data, dev_name,
+						NETXEN_NIC_NAME_LEN);
+			if (nr_bytes)
+				err = -EIO;
+
 		}
 		break;
 
@@ -1101,8 +1146,6 @@ static struct pci_driver netxen_driver =
 
 static int __init netxen_init_module(void)
 {
-	printk(KERN_INFO "%s \n", netxen_nic_driver_string);
-
 	return pci_module_init(&netxen_driver);
 }
 
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 6e421c8..7950a04 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -6,12 +6,12 @@
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
@@ -32,19 +32,56 @@
  */
 
 #include "netxen_nic.h"
-#include <linux/delay.h>
+
+#define NETXEN_GB_MAC_SOFT_RESET	0x80000000
+#define NETXEN_GB_MAC_RESET_PROT_BLK   0x000F0000
+#define NETXEN_GB_MAC_ENABLE_TX_RX     0x00000005
+#define NETXEN_GB_MAC_PAUSED_FRMS      0x00000020
+
+static long phy_lock_timeout = 100000000;
+
+static inline int phy_lock(void)
+{
+	int i;
+	int done = 0, timeout = 0;
+
+	while (!done) {
+		done = readl((void __iomem *)NETXEN_PCIE_REG(PCIE_SEM3_LOCK));
+		if (done == 1)
+			break;
+		if (timeout >= phy_lock_timeout) {
+			return -1;
+		}
+		timeout++;
+		if (!in_atomic())
+			schedule();
+		else {
+			for (i = 0; i < 20; i++)
+				cpu_relax();
+		}
+	}
+
+	writel(NETXEN_PHY_LOCK_ID, (void __iomem *)PHY_LOCK_DRIVER);
+	return 0;
+}
+
+static inline int phy_unlock(void)
+{
+	readl((void __iomem *)NETXEN_PCIE_REG(PCIE_SEM3_UNLOCK));
+	return 0;
+}
 
 /* 
  * netxen_niu_gbe_phy_read - read a register from the GbE PHY via
  * mii management interface.
  *
  * Note: The MII management interface goes through port 0.
- *       Individual phys are addressed as follows:
+ *	Individual phys are addressed as follows:
  * @param phy  [15:8]  phy id
  * @param reg  [7:0]   register number
  *
  * @returns  0 on success
- *          -1 on error
+ *	  -1 on error
  *
  */
 int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long phy,
@@ -56,10 +93,17 @@ int netxen_niu_gbe_phy_read(struct netxe
 	__le32 address;
 	__le32 command;
 	__le32 status;
-	__le32 mii_cfg;
 	__le32 mac_cfg0;
 
-	/* MII mgmt all goes through port 0 MAC interface, so it cannot be in reset */
+	if (phy_lock() != 0) {
+		return -1;
+	}
+
+	/*
+	 * MII mgmt all goes through port 0 MAC interface,
+	 * so it cannot be in reset
+	 */
+
 	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
 				  &mac_cfg0, 4))
 		return -EIO;
@@ -77,18 +121,6 @@ int netxen_niu_gbe_phy_read(struct netxe
 		restore = 1;
 	}
 
-	/* reset MII management interface */
-	mii_cfg = 0;
-	netxen_gb_set_mii_mgmt_clockselect(mii_cfg, 7);
-	netxen_gb_mii_mgmt_reset(mii_cfg);
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(0),
-				   &mii_cfg, 4))
-		return -EIO;
-	netxen_gb_mii_mgmt_unset(mii_cfg);
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(0),
-				   &mii_cfg, 4))
-		return -EIO;
-
 	address = 0;
 	netxen_gb_mii_mgmt_reg_addr(address, reg);
 	netxen_gb_mii_mgmt_phy_addr(address, phy);
@@ -130,7 +162,7 @@ int netxen_niu_gbe_phy_read(struct netxe
 					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
 					   &mac_cfg0, 4))
 			return -EIO;
-
+	phy_unlock();
 	return result;
 }
 
@@ -139,12 +171,12 @@ int netxen_niu_gbe_phy_read(struct netxe
  * mii management interface.
  *
  * Note: The MII management interface goes through port 0.
- *       Individual phys are addressed as follows:
+ *	Individual phys are addressed as follows:
  * @param phy      [15:8]  phy id
  * @param reg      [7:0]   register number
  *
  * @returns  0 on success
- *          -1 on error
+ *	  -1 on error
  *
  */
 int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
@@ -158,7 +190,11 @@ int netxen_niu_gbe_phy_write(struct netx
 	__le32 status;
 	__le32 mac_cfg0;
 
-	/* MII mgmt all goes through port 0 MAC interface, so it cannot be in reset */
+	/*
+	 * MII mgmt all goes through port 0 MAC interface, so it
+	 * cannot be in reset
+	 */
+
 	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
 				  &mac_cfg0, 4))
 		return -EIO;
@@ -382,14 +418,23 @@ int netxen_niu_gbe_init_port(struct netx
 			}
 
 		} else {
-			/* We don't have link. Cable  must be unconnected. */
-			/* Enable phy interrupts so we take action when plugged in */
+			/*
+			 * We don't have link. Cable  must be unconnected.
+			 * Enable phy interrupts so we take action when
+			 * plugged in.
+			 */
+
 			netxen_crb_writelit_adapter(adapter,
 						    NETXEN_NIU_GB_MAC_CONFIG_0
-						    (port), 0x80000000);
+						    (port),
+						    NETXEN_GB_MAC_SOFT_RESET);
 			netxen_crb_writelit_adapter(adapter,
 						    NETXEN_NIU_GB_MAC_CONFIG_0
-						    (port), 0x0000f0025);
+						    (port),
+						    NETXEN_GB_MAC_RESET_PROT_BLK
+						    | NETXEN_GB_MAC_ENABLE_TX_RX
+						    |
+						    NETXEN_GB_MAC_PAUSED_FRMS);
 			if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
 				printk(KERN_ERR PFX
 				       "ERROR clearing PHY interrupts\n");
@@ -407,10 +452,34 @@ int netxen_niu_gbe_init_port(struct netx
 	return result;
 }
 
+int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
+{
+	long reg = 0, ret = 0;
+
+	if (adapter->ahw.boardcfg.board_type == NETXEN_BRDTYPE_P2_SB31_10G_IMEZ) {
+		netxen_crb_writelit_adapter(adapter,
+					    NETXEN_NIU_XG1_CONFIG_0, 0x5);
+		/* XXX hack for Mez cards: both ports in promisc mode */
+		netxen_nic_hw_read_wx(adapter,
+				      NETXEN_NIU_XGE_CONFIG_1, &reg, 4);
+		reg = (reg | 0x2000UL);
+		netxen_crb_writelit_adapter(adapter,
+					    NETXEN_NIU_XGE_CONFIG_1, reg);
+		reg = 0;
+		netxen_nic_hw_read_wx(adapter,
+				      NETXEN_NIU_XG1_CONFIG_1, &reg, 4);
+		reg = (reg | 0x2000UL);
+		netxen_crb_writelit_adapter(adapter,
+					    NETXEN_NIU_XG1_CONFIG_1, reg);
+	}
+
+	return ret;
+}
+
 /* 
  * netxen_niu_gbe_handle_phy_interrupt - Handles GbE PHY interrupts
  * @param enable 0 means don't enable the port
- *               1 means enable (or re-enable) the port
+ *		 1 means enable (or re-enable) the port
  */
 int netxen_niu_gbe_handle_phy_interrupt(struct netxen_adapter *adapter,
 					int port, long enable)
@@ -421,7 +490,10 @@ int netxen_niu_gbe_handle_phy_interrupt(
 	printk(KERN_INFO PFX "NETXEN: Handling PHY interrupt on port %d"
 	       " (device enable = %d)\n", (int)port, (int)enable);
 
-	/* The read of the PHY INT status will clear the pending interrupt status */
+	/*
+	 * The read of the PHY INT status will clear the pending
+	 * interrupt status
+	 */
 	if (netxen_niu_gbe_phy_read(adapter, port,
 				    NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
 				    &int_src) != 0)
@@ -540,20 +612,42 @@ int netxen_niu_macaddr_set(struct netxen
 	__le32 temp = 0;
 	struct netxen_adapter *adapter = port->adapter;
 	int phy = port->portnum;
+	unsigned char mac_addr[MAX_ADDR_LEN];
+	int i;
+
+	for (i = 0; i < 10; i++) {
+		memcpy(&temp, addr, 2);
+		temp <<= 16;
+		if (netxen_nic_hw_write_wx
+		    (adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy), &temp, 4))
+			return -EIO;
 
-	memcpy(&temp, addr, 2);
-	temp <<= 16;
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy),
-				   &temp, 4))
-		return -EIO;
+		temp = 0;
 
-	temp = 0;
+		memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
+		if (netxen_nic_hw_write_wx
+		    (adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy), &temp, 4))
+			return -2;
 
-	memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy),
-				   &temp, 4))
-		return -2;
+		netxen_niu_macaddr_get(adapter, phy,
+				       (netxen_ethernet_macaddr_t *) mac_addr);
+		if (memcmp(mac_addr, addr, MAX_ADDR_LEN == 0))
+			break;
+	}
 
+	if (i == 10) {
+		printk(KERN_ERR "%s: cannot set Mac addr for %s\n",
+		       netxen_nic_driver_name, port->netdev->name);
+		printk(KERN_ERR "MAC address set: "
+		       "%02x:%02x:%02x:%02x:%02x:%02x.\n",
+		       addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
+
+		printk(KERN_ERR "MAC address get: "
+		       "%02x:%02x:%02x:%02x:%02x:%02x.\n",
+		       mac_addr[0],
+		       mac_addr[1],
+		       mac_addr[2], mac_addr[3], mac_addr[4], mac_addr[5]);
+	}
 	return 0;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 863645e..8181d43 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -6,12 +6,12 @@
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
@@ -58,6 +58,9 @@
 #define CRB_CMD_PRODUCER_OFFSET		NETXEN_NIC_REG(0x08)
 #define CRB_CMD_CONSUMER_OFFSET		NETXEN_NIC_REG(0x0c)
 
+#define CRB_PAUSE_ADDR_LO		NETXEN_NIC_REG(0x10)
+#define CRB_PAUSE_ADDR_HI		NETXEN_NIC_REG(0x14)
+
 /* address of command descriptors in the host memory */
 #define CRB_HOST_CMD_ADDR_HI		NETXEN_NIC_REG(0x30)
 #define CRB_HOST_CMD_ADDR_LO		NETXEN_NIC_REG(0x34)
@@ -82,10 +85,18 @@
 #define CRB_TX_PKT_TIMER		NETXEN_NIC_REG(0x94)
 #define CRB_RX_PKT_CNT			NETXEN_NIC_REG(0x98)
 #define CRB_RX_TMR_CNT			NETXEN_NIC_REG(0x9c)
+#define CRB_INT_THRESH		 NETXEN_NIC_REG(0xa4)
 
 /* Register for communicating XG link status */
 #define CRB_XG_STATE			NETXEN_NIC_REG(0xa0)
 
+/* Register for communicating card temperature */
+/* Upper 16 bits are temperature value. Lower 16 bits are the state */
+#define CRB_TEMP_STATE		 NETXEN_NIC_REG(0xa8)
+#define nx_get_temp_val(x)	     ((x) >> 16)
+#define nx_get_temp_state(x)	   ((x) & 0xffff)
+#define nx_encode_temp(val, state)     (((val) << 16) | (state))
+
 /* Debug registers for controlling NIC pkt gen agent */
 #define CRB_AGENT_GO			NETXEN_NIC_REG(0xb0)
 #define CRB_AGENT_TX_SIZE		NETXEN_NIC_REG(0xb4)
@@ -192,4 +203,13 @@ struct netxen_recv_crb recv_crb_register
 extern struct netxen_recv_crb recv_crb_registers[];
 #endif				/* DEFINE_GLOBAL_RECEIVE_CRB */
 
+/*
+ * Temperature control.
+ */
+enum {
+	NX_TEMP_NORMAL = 0x1,	/* Normal operating range */
+	NX_TEMP_WARN,		/* Sound alert, temperature getting high */
+	NX_TEMP_PANIC		/* Fatal error, hardware has shut down. */
+};
+
 #endif				/* __NIC_PHAN_REG_H_ */
