From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 3/3] NetXen: Make driver use multi PCI functions
Date: Wed, 28 Feb 2007 05:19:02 -0800
Message-ID: <200702281319.l1SDJ2FV004424@dut39.unminc.com>
Cc: jeff@garzik.org, mithlesh@netxen.com, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:24601 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932288AbXB1NTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 08:19:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Make driver use multi PCI functions.

Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>

---

 netxen_nic.h          |  126 +++++-------
 netxen_nic_ethtool.c  |   80 +++----
 netxen_nic_hdr.h      |    8 
 netxen_nic_hw.c       |  213 +++++++++++++++-----
 netxen_nic_hw.h       |   18 -
 netxen_nic_init.c     |  115 +++-------
 netxen_nic_isr.c      |   80 +++----
 netxen_nic_main.c     |  523 +++++++++++++++++++++++++-------------------------
 netxen_nic_niu.c      |   27 +-
 netxen_nic_phan_reg.h |  125 -----------
 10 files changed, 631 insertions(+), 684 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 81742e4..64f22ef 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -219,6 +219,7 @@ #define MIN_RX_COUNT	4096
 #define NETXEN_CTX_SIGNATURE	0xdee0
 #define NETXEN_RCV_PRODUCER(ringid)	(ringid)
 #define MAX_FRAME_SIZE	0x10000	/* 64K MAX size for LSO */
+#define MAC_ADDR_LEN 	6
 
 #define PHAN_PEG_RCV_INITIALIZED	0xff01
 #define PHAN_PEG_RCV_START_INITIALIZE	0xff00
@@ -230,7 +231,9 @@ #define get_index_range(index,length,cou
 	(((index) + (count)) & ((length) - 1))
 
 #define MPORT_SINGLE_FUNCTION_MODE 0x1111
+#define MPORT_MULTI_FUNCTION_MODE 0x2222
 
+#include "netxen_nic_phan_reg.h"
 extern unsigned long long netxen_dma_mask;
 
 /*
@@ -702,10 +705,8 @@ #define DPRINTK(klevel, fmt, args...)	do
 #else
 #define DPRINTK(klevel, fmt, args...)	do { \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, __FUNCTION__,\
-		(adapter != NULL && \
-		adapter->port[0] != NULL && \
-		adapter->port[0]->netdev != NULL) ? \
-		adapter->port[0]->netdev->name : NULL, \
+		(adapter != NULL && adapter->netdev != NULL) ? \
+		adapter->netdev->name : NULL, \
 		## args); } while(0)
 #endif
 
@@ -787,17 +788,27 @@ #define MINIMUM_ETHERNET_FRAME_SIZE	64	/
 #define ETHERNET_FCS_SIZE		4
 
 struct netxen_adapter_stats {
-	u64 ints;
-	u64 hostints;
-	u64 otherints;
-	u64 process_rcv;
-	u64 process_xmit;
-	u64 noxmitdone;
-	u64 xmitcsummed;
-	u64 post_called;
-	u64 posted;
-	u64 lastposted;
-	u64 goodskbposts;
+	u64  rcvdbadskb;
+	u64  xmitcalled;
+	u64  xmitedframes;
+	u64  xmitfinished;
+	u64  badskblen;
+	u64  nocmddescriptor;
+	u64  polled;
+	u64  uphappy;
+	u64  updropped;
+	u64  uplcong;
+	u64  uphcong;
+	u64  upmcong;
+	u64  updunno;
+	u64  skbfreed;
+	u64  txdropped;
+	u64  txnullskb;
+	u64  csummed;
+	u64  no_rcv;
+	u64  rxbytes;
+	u64  txbytes;
+	u64  ints;
 };
 
 /*
@@ -845,13 +856,19 @@ struct netxen_dummy_dma {
 
 struct netxen_adapter {
 	struct netxen_hardware_context ahw;
-	int port_count;		/* Number of configured ports  */
-	int active_ports;	/* Number of open ports */
-	struct netxen_port *port[NETXEN_MAX_PORTS];	/* ptr to each port  */
+	
+	struct netxen_adapter *master;
+	struct net_device *netdev;
+	struct pci_dev *pdev;
+	unsigned char mac_addr[MAC_ADDR_LEN];
+	int mtu;
+	int portnum;
+
 	spinlock_t tx_lock;
 	spinlock_t lock;
 	struct work_struct watchdog_task;
 	struct timer_list watchdog_timer;
+	struct work_struct  tx_timeout_task;
 
 	u32 curr_window;
 
@@ -874,6 +891,15 @@ struct netxen_adapter {
 	u32 temp;
 
 	struct netxen_adapter_stats stats;
+	
+	u16 portno;
+	u16 link_speed;
+	u16 link_duplex;
+	u16 state;
+	u16 link_autoneg;
+	int rcsum;
+	int status;
+	spinlock_t stats_lock;
 
 	struct netxen_cmd_buffer *cmd_buf_arr;	/* Command buffers for xmit */
 
@@ -893,62 +919,20 @@ struct netxen_adapter {
 	int (*enable_phy_interrupts) (struct netxen_adapter *, int);
 	int (*disable_phy_interrupts) (struct netxen_adapter *, int);
 	void (*handle_phy_intr) (struct netxen_adapter *);
-	int (*macaddr_set) (struct netxen_port *, netxen_ethernet_macaddr_t);
-	int (*set_mtu) (struct netxen_port *, int);
-	int (*set_promisc) (struct netxen_adapter *, int,
-			    netxen_niu_prom_mode_t);
-	int (*unset_promisc) (struct netxen_adapter *, int,
-			      netxen_niu_prom_mode_t);
+	int (*macaddr_set) (struct netxen_adapter *, netxen_ethernet_macaddr_t);
+	int (*set_mtu) (struct netxen_adapter *, int);
+	int (*set_promisc) (struct netxen_adapter *, netxen_niu_prom_mode_t);
+	int (*unset_promisc) (struct netxen_adapter *, netxen_niu_prom_mode_t);
 	int (*phy_read) (struct netxen_adapter *, long phy, long reg, u32 *);
 	int (*phy_write) (struct netxen_adapter *, long phy, long reg, u32 val);
 	int (*init_port) (struct netxen_adapter *, int);
 	void (*init_niu) (struct netxen_adapter *);
-	int (*stop_port) (struct netxen_adapter *, int);
+	int (*stop_port) (struct netxen_adapter *);
 };				/* netxen_adapter structure */
 
 /* Max number of xmit producer threads that can run simultaneously */
 #define	MAX_XMIT_PRODUCERS		16
 
-struct netxen_port_stats {
-	u64 rcvdbadskb;
-	u64 xmitcalled;
-	u64 xmitedframes;
-	u64 xmitfinished;
-	u64 badskblen;
-	u64 nocmddescriptor;
-	u64 polled;
-	u64 uphappy;
-	u64 updropped;
-	u64 uplcong;
-	u64 uphcong;
-	u64 upmcong;
-	u64 updunno;
-	u64 skbfreed;
-	u64 txdropped;
-	u64 txnullskb;
-	u64 csummed;
-	u64 no_rcv;
-	u64 rxbytes;
-	u64 txbytes;
-};
-
-struct netxen_port {
-	struct netxen_adapter *adapter;
-
-	u16 portnum;		/* GBE port number */
-	u16 link_speed;
-	u16 link_duplex;
-	u16 link_autoneg;
-
-	int flags;
-
-	struct net_device *netdev;
-	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
-	struct netxen_port_stats stats;
-	struct work_struct tx_timeout_task;
-};
-
 #define PCI_OFFSET_FIRST_RANGE(adapter, off)    \
 	((adapter)->ahw.pci_base0 + (off))
 #define PCI_OFFSET_SECOND_RANGE(adapter, off)   \
@@ -1010,8 +994,8 @@ int netxen_niu_gbe_phy_write(struct netx
 			     long reg, __u32 val);
 
 /* Functions available from netxen_nic_hw.c */
-int netxen_nic_set_mtu_xgb(struct netxen_port *port, int new_mtu);
-int netxen_nic_set_mtu_gb(struct netxen_port *port, int new_mtu);
+int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu);
+int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu);
 void netxen_nic_init_niu_gb(struct netxen_adapter *adapter);
 void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw);
 void netxen_nic_reg_write(struct netxen_adapter *adapter, u64 off, u32 val);
@@ -1050,11 +1034,8 @@ int netxen_do_rom_se(struct netxen_adapt
 
 /* Functions from netxen_nic_isr.c */
 void netxen_nic_isr_other(struct netxen_adapter *adapter);
-void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 port,
-				 u32 link);
-void netxen_handle_port_int(struct netxen_adapter *adapter, u32 port,
-			    u32 enable);
-void netxen_nic_stop_all_ports(struct netxen_adapter *adapter);
+void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 link);
+void netxen_handle_port_int(struct netxen_adapter *adapter, u32 enable);
 void netxen_initialize_adapter_sw(struct netxen_adapter *adapter);
 void netxen_initialize_adapter_hw(struct netxen_adapter *adapter);
 void *netxen_alloc(struct pci_dev *pdev, size_t sz, dma_addr_t * ptr,
@@ -1109,6 +1090,7 @@ static inline void netxen_nic_enable_int
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		mask = 0xbff;
+		writel(0X0, NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
 		writel(mask, PCI_OFFSET_SECOND_RANGE(adapter,
 						     ISR_INT_TARGET_MASK));
 	}
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 986ef98..0ceebb7 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -50,8 +50,8 @@ struct netxen_nic_stats {
 	int stat_offset;
 };
 
-#define NETXEN_NIC_STAT(m) sizeof(((struct netxen_port *)0)->m), \
-			offsetof(struct netxen_port, m)
+#define NETXEN_NIC_STAT(m) sizeof(((struct netxen_adapter *)0)->m), \
+			offsetof(struct netxen_adapter, m)
 
 #define NETXEN_NIC_PORT_WINDOW 0x10000
 #define NETXEN_NIC_INVALID_DATA 0xDEADBEEF
@@ -100,8 +100,7 @@ static int netxen_nic_get_eeprom_len(str
 static void
 netxen_nic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	u32 fw_major = 0;
 	u32 fw_minor = 0;
 	u32 fw_build = 0;
@@ -115,7 +114,7 @@ netxen_nic_get_drvinfo(struct net_device
 	fw_build = readl(NETXEN_CRB_NORMALIZE(adapter, NETXEN_FW_VERSION_SUB));
 	sprintf(drvinfo->fw_version, "%d.%d.%d", fw_major, fw_minor, fw_build);
 
-	strncpy(drvinfo->bus_info, pci_name(port->pdev), 32);
+	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
 	drvinfo->n_stats = NETXEN_NIC_STATS_LEN;
 	drvinfo->testinfo_len = NETXEN_NIC_TEST_LEN;
 	drvinfo->regdump_len = NETXEN_NIC_REGS_LEN;
@@ -125,8 +124,7 @@ netxen_nic_get_drvinfo(struct net_device
 static int
 netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	struct netxen_board_info *boardinfo = &adapter->ahw.boardcfg;
 
 	/* read which mode */
@@ -146,8 +144,8 @@ netxen_nic_get_settings(struct net_devic
 		ecmd->port = PORT_TP;
 
 		if (netif_running(dev)) {
-			ecmd->speed = port->link_speed;
-			ecmd->duplex = port->link_duplex;
+			ecmd->speed = adapter->link_speed;
+			ecmd->duplex = adapter->link_duplex;
 		} else
 			return -EIO;	/* link absent */
 	} else if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
@@ -165,7 +163,7 @@ netxen_nic_get_settings(struct net_devic
 	} else
 		return -EIO;
 
-	ecmd->phy_address = port->portnum;
+	ecmd->phy_address = adapter->portnum;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
 	switch ((netxen_brdtype_t) boardinfo->board_type) {
@@ -179,7 +177,7 @@ netxen_nic_get_settings(struct net_devic
 		ecmd->port = PORT_TP;
 		ecmd->autoneg = (boardinfo->board_type ==
 				 NETXEN_BRDTYPE_P2_SB31_10G_CX4) ?
-		    (AUTONEG_DISABLE) : (port->link_autoneg);
+		    (AUTONEG_DISABLE) : (adapter->link_autoneg);
 		break;
 	case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
 	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
@@ -206,23 +204,22 @@ netxen_nic_get_settings(struct net_devic
 static int
 netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 status;
 
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		/* autonegotiation */
 		if (adapter->phy_write
-		    && adapter->phy_write(adapter, port->portnum,
+		    && adapter->phy_write(adapter, adapter->portnum,
 					  NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
 					  ecmd->autoneg) != 0)
 			return -EIO;
 		else
-			port->link_autoneg = ecmd->autoneg;
+			adapter->link_autoneg = ecmd->autoneg;
 
 		if (adapter->phy_read
-		    && adapter->phy_read(adapter, port->portnum,
+		    && adapter->phy_read(adapter, adapter->portnum,
 					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					 &status) != 0)
 			return -EIO;
@@ -245,13 +242,13 @@ netxen_nic_set_settings(struct net_devic
 		if (ecmd->duplex == DUPLEX_FULL)
 			netxen_set_phy_duplex(status);
 		if (adapter->phy_write
-		    && adapter->phy_write(adapter, port->portnum,
+		    && adapter->phy_write(adapter, adapter->portnum,
 					  NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					  *((int *)&status)) != 0)
 			return -EIO;
 		else {
-			port->link_speed = ecmd->speed;
-			port->link_duplex = ecmd->duplex;
+			adapter->link_speed = ecmd->speed;
+			adapter->link_duplex = ecmd->duplex;
 		}
 	} else
 		return -EOPNOTSUPP;
@@ -360,15 +357,14 @@ static struct netxen_niu_regs niu_regist
 static void
 netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 mode, *regs_buff = p;
 	void __iomem *addr;
 	int i, window;
 
 	memset(p, 0, NETXEN_NIC_REGS_LEN);
 	regs->version = (1 << 24) | (adapter->ahw.revision_id << 16) |
-	    (port->pdev)->device;
+	    (adapter->pdev)->device;
 	/* which mode */
 	NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_MODE, &regs_buff[0]);
 	mode = regs_buff[0];
@@ -383,7 +379,7 @@ netxen_nic_get_regs(struct net_device *d
 		for (i = 3; niu_registers[mode].reg[i - 3] != -1; i++) {
 			/* GB: port specific registers */
 			if (mode == 0 && i >= 19)
-				window = port->portnum * NETXEN_NIC_PORT_WINDOW;
+				window = adapter->portnum * NETXEN_NIC_PORT_WINDOW;
 
 			NETXEN_NIC_LOCKED_READ_REG(niu_registers[mode].
 						   reg[i - 3] + window,
@@ -395,15 +391,14 @@ netxen_nic_get_regs(struct net_device *d
 
 static u32 netxen_nic_test_link(struct net_device *dev)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 status;
 	int val;
 
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		if (adapter->phy_read
-		    && adapter->phy_read(adapter, port->portnum,
+		    && adapter->phy_read(adapter, adapter->portnum,
 					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					 &status) != 0)
 			return -EIO;
@@ -422,15 +417,14 @@ static int
 netxen_nic_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		      u8 * bytes)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	int offset;
 	int ret;
 
 	if (eeprom->len == 0)
 		return -EINVAL;
 
-	eeprom->magic = (port->pdev)->vendor | ((port->pdev)->device << 16);
+	eeprom->magic = (adapter->pdev)->vendor | ((adapter->pdev)->device << 16);
 	offset = eeprom->offset;
 
 	ret = netxen_rom_fast_read_words(adapter, offset, bytes, 
@@ -445,8 +439,7 @@ static int
 netxen_nic_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 			u8 * bytes)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	int offset = eeprom->offset;
 	static int flash_start;
 	static int ready_to_flash;
@@ -515,8 +508,7 @@ netxen_nic_set_eeprom(struct net_device 
 static void
 netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	int i;
 
 	ring->rx_pending = 0;
@@ -540,19 +532,18 @@ static void
 netxen_nic_get_pauseparam(struct net_device *dev,
 			  struct ethtool_pauseparam *pause)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 val;
 
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		/* get flow control settings */
 		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_MAC_CONFIG_0(port->portnum),
+				   NETXEN_NIU_GB_MAC_CONFIG_0(adapter->portnum),
 				   &val);
 		pause->rx_pause = netxen_gb_get_rx_flowctl(val);
 		pause->tx_pause = netxen_gb_get_tx_flowctl(val);
 		/* get autoneg settings */
-		pause->autoneg = port->link_autoneg;
+		pause->autoneg = adapter->link_autoneg;
 	}
 }
 
@@ -560,8 +551,7 @@ static int
 netxen_nic_set_pauseparam(struct net_device *dev,
 			  struct ethtool_pauseparam *pause)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 val;
 	unsigned int autoneg;
 
@@ -569,7 +559,7 @@ netxen_nic_set_pauseparam(struct net_dev
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		/* set flow control */
 		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_MAC_CONFIG_0(port->portnum),
+				   NETXEN_NIU_GB_MAC_CONFIG_0(adapter->portnum),
 				   (u32 *) & val);
 		if (pause->tx_pause)
 			netxen_gb_tx_flowctl(val);
@@ -581,17 +571,17 @@ netxen_nic_set_pauseparam(struct net_dev
 			netxen_gb_unset_rx_flowctl(val);
 
 		netxen_nic_write_w0(adapter,
-				    NETXEN_NIU_GB_MAC_CONFIG_0(port->portnum),
+				    NETXEN_NIU_GB_MAC_CONFIG_0(adapter->portnum),
 				    *&val);
 		/* set autoneg */
 		autoneg = pause->autoneg;
 		if (adapter->phy_write
-		    && adapter->phy_write(adapter, port->portnum,
+		    && adapter->phy_write(adapter, adapter->portnum,
 					  NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
 					  autoneg) != 0)
 			return -EIO;
 		else {
-			port->link_autoneg = pause->autoneg;
+			adapter->link_autoneg = pause->autoneg;
 			return 0;
 		}
 	} else
@@ -674,12 +664,12 @@ static void
 netxen_nic_get_ethtool_stats(struct net_device *dev,
 			     struct ethtool_stats *stats, u64 * data)
 {
-	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	int index;
 
 	for (index = 0; index < NETXEN_NIC_STATS_LEN; index++) {
 		char *p =
-		    (char *)port + netxen_nic_gstrings_stats[index].stat_offset;
+		    (char *)adapter + netxen_nic_gstrings_stats[index].stat_offset;
 		data[index] =
 		    (netxen_nic_gstrings_stats[index].sizeof_stat ==
 		     sizeof(u64)) ? *(u64 *) p : *(u32 *) p;
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index fe8b675..b67a5c3 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -649,11 +649,19 @@ #define PCIX_MN_WINDOW		(0x10200)
 #define PCIX_MS_WINDOW		(0x10204)
 #define PCIX_SN_WINDOW		(0x10208)
 #define PCIX_CRB_WINDOW		(0x10210)
+#define PCIX_CRB_WINDOW_F0	(0x10210)
+#define PCIX_CRB_WINDOW_F1	(0x10230)
+#define PCIX_CRB_WINDOW_F2	(0x10250)
+#define PCIX_CRB_WINDOW_F3	(0x10270)
 
 #define PCIX_TARGET_STATUS	(0x10118)
 #define PCIX_TARGET_MASK	(0x10128)
 
 #define PCIX_MSI_F0		(0x13000)
+#define PCIX_MSI_F1		(0x13004)
+#define PCIX_MSI_F2		(0x13008)
+#define PCIX_MSI_F3		(0x1300c)
+#define PCIX_MSI_F(i)		(0x13000+((i)*4))
 
 #define PCIX_PS_MEM_SPACE	(0x90000)
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index a2877f3..5c35db2 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -33,8 +33,126 @@
 
 #include "netxen_nic.h"
 #include "netxen_nic_hw.h"
+#define DEFINE_GLOBAL_RECV_CRB
 #include "netxen_nic_phan_reg.h"
 
+struct netxen_recv_crb recv_crb_registers[] = {
+	/*
+	 * Instance 0.
+	 */
+	{
+	 /* rcv_desc_crb: */
+	 {
+	  {
+	   /* crb_rcv_producer_offset: */
+	   NETXEN_NIC_REG(0x100),
+	   /* crb_rcv_consumer_offset: */
+	   NETXEN_NIC_REG(0x104),
+	   /* crb_gloablrcv_ring: */
+	   NETXEN_NIC_REG(0x108),
+	   /* crb_rcv_ring_size */
+	   NETXEN_NIC_REG(0x10c),
+
+	   },
+	  /* Jumbo frames */
+	  {
+	   /* crb_rcv_producer_offset: */
+	   NETXEN_NIC_REG(0x110),
+	   /* crb_rcv_consumer_offset: */
+	   NETXEN_NIC_REG(0x114),
+	   /* crb_gloablrcv_ring: */
+	   NETXEN_NIC_REG(0x118),
+	   /* crb_rcv_ring_size */
+	   NETXEN_NIC_REG(0x11c),
+	   },
+	  /* LRO */
+	  {
+	   /* crb_rcv_producer_offset: */
+	   NETXEN_NIC_REG(0x120),
+	   /* crb_rcv_consumer_offset: */
+	   NETXEN_NIC_REG(0x124),
+	   /* crb_gloablrcv_ring: */
+	   NETXEN_NIC_REG(0x128),
+	   /* crb_rcv_ring_size */
+	   NETXEN_NIC_REG(0x12c),
+	   }
+	  },
+	 /* crb_rcvstatus_ring: */
+	 NETXEN_NIC_REG(0x130),
+	 /* crb_rcv_status_producer: */
+	 NETXEN_NIC_REG(0x134),
+	 /* crb_rcv_status_consumer: */
+	 NETXEN_NIC_REG(0x138),
+	 /* crb_rcvpeg_state: */
+	 NETXEN_NIC_REG(0x13c),
+	 /* crb_status_ring_size */
+	 NETXEN_NIC_REG(0x140),
+
+	 },
+	/*
+	 * Instance 1,
+	 */
+	{
+	 /* rcv_desc_crb: */
+	 {
+	  {
+	   /* crb_rcv_producer_offset: */
+	   NETXEN_NIC_REG(0x144),
+	   /* crb_rcv_consumer_offset: */
+	   NETXEN_NIC_REG(0x148),
+	   /* crb_globalrcv_ring: */
+	   NETXEN_NIC_REG(0x14c),
+	   /* crb_rcv_ring_size */
+	   NETXEN_NIC_REG(0x150),
+
+	   },
+	  /* Jumbo frames */
+	  {
+	   /* crb_rcv_producer_offset: */
+	   NETXEN_NIC_REG(0x154),
+	   /* crb_rcv_consumer_offset: */
+	   NETXEN_NIC_REG(0x158),
+	   /* crb_globalrcv_ring: */
+	   NETXEN_NIC_REG(0x15c),
+	   /* crb_rcv_ring_size */
+	   NETXEN_NIC_REG(0x160),
+	   },
+	  /* LRO */
+	  {
+	   /* crb_rcv_producer_offset: */
+	   NETXEN_NIC_REG(0x164),
+	   /* crb_rcv_consumer_offset: */
+	   NETXEN_NIC_REG(0x168),
+	   /* crb_globalrcv_ring: */
+	   NETXEN_NIC_REG(0x16c),
+	   /* crb_rcv_ring_size */
+	   NETXEN_NIC_REG(0x170),
+	   }
+
+	  },
+	 /* crb_rcvstatus_ring: */
+	 NETXEN_NIC_REG(0x174),
+	 /* crb_rcv_status_producer: */
+	 NETXEN_NIC_REG(0x178),
+	 /* crb_rcv_status_consumer: */
+	 NETXEN_NIC_REG(0x17c),
+	 /* crb_rcvpeg_state: */
+	 NETXEN_NIC_REG(0x180),
+	 /* crb_status_ring_size */
+	 NETXEN_NIC_REG(0x184),
+
+	 },
+};
+
+u64 ctx_addr_sig_regs[][3] = {
+	{NETXEN_NIC_REG(0x188), NETXEN_NIC_REG(0x18c), NETXEN_NIC_REG(0x1c0)},
+	{NETXEN_NIC_REG(0x190), NETXEN_NIC_REG(0x194), NETXEN_NIC_REG(0x1c4)},
+	{NETXEN_NIC_REG(0x198), NETXEN_NIC_REG(0x19c), NETXEN_NIC_REG(0x1c8)},
+	{NETXEN_NIC_REG(0x1a0), NETXEN_NIC_REG(0x1a4), NETXEN_NIC_REG(0x1cc)}
+};
+
+
+
 /*  PCI Windowing for DDR regions.  */
 
 #define ADDR_IN_RANGE(addr, low, high)	\
@@ -68,8 +186,7 @@ void netxen_free_hw_resources(struct net
 
 int netxen_nic_set_mac(struct net_device *netdev, void *p)
 {
-	struct netxen_port *port = netdev_priv(netdev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
 	if (netif_running(netdev))
@@ -82,7 +199,7 @@ int netxen_nic_set_mac(struct net_device
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
 	if (adapter->macaddr_set)
-		adapter->macaddr_set(port, addr->sa_data);
+		adapter->macaddr_set(adapter, addr->sa_data);
 
 	return 0;
 }
@@ -92,8 +209,7 @@ int netxen_nic_set_mac(struct net_device
  */
 void netxen_nic_set_multi(struct net_device *netdev)
 {
-	struct netxen_port *port = netdev_priv(netdev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct dev_mc_list *mc_ptr;
 	__u32 netxen_mac_addr_cntl_data = 0;
 
@@ -101,14 +217,12 @@ void netxen_nic_set_multi(struct net_dev
 	if (netdev->flags & IFF_PROMISC) {
 		if (adapter->set_promisc)
 			adapter->set_promisc(adapter,
-					     port->portnum,
 					     NETXEN_NIU_PROMISC_MODE);
 	} else {
 		if (adapter->unset_promisc &&
 		    adapter->ahw.boardcfg.board_type
 		    != NETXEN_BRDTYPE_P2_SB31_10G_IMEZ)
 			adapter->unset_promisc(adapter,
-					       port->portnum,
 					       NETXEN_NIU_NON_PROMISC_MODE);
 	}
 	if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
@@ -150,8 +264,7 @@ void netxen_nic_set_multi(struct net_dev
  */
 int netxen_nic_change_mtu(struct net_device *netdev, int mtu)
 {
-	struct netxen_port *port = netdev_priv(netdev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(netdev);
 	int eff_mtu = mtu + NETXEN_ENET_HEADER_SIZE + NETXEN_ETH_FCS_SIZE;
 
 	if ((eff_mtu > NETXEN_MAX_MTU) || (eff_mtu < NETXEN_MIN_MTU)) {
@@ -161,7 +274,7 @@ int netxen_nic_change_mtu(struct net_dev
 	}
 
 	if (adapter->set_mtu)
-		adapter->set_mtu(port, mtu);
+		adapter->set_mtu(adapter, mtu);
 	netdev->mtu = mtu;
 
 	return 0;
@@ -383,7 +496,6 @@ void netxen_tso_check(struct netxen_adap
 			return;
 		}
 	}
-	adapter->stats.xmitcsummed++;
 	desc->tcp_hdr_offset = skb->h.raw - skb->data;
 	desc->ip_hdr_offset = skb->nh.raw - skb->data;
 }
@@ -473,7 +585,30 @@ void netxen_nic_pci_change_crbwindow(str
 
 	if (adapter->curr_window == wndw)
 		return;
-
+	switch(adapter->portnum) {
+		case 0:
+			offset = PCI_OFFSET_SECOND_RANGE(adapter,
+					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW));
+			break;
+		case 1:
+			offset = PCI_OFFSET_SECOND_RANGE(adapter,
+					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW_F1));
+			break;
+		case 2:
+			offset = PCI_OFFSET_SECOND_RANGE(adapter,
+					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW_F2));
+			break;
+		case 3:
+			offset = PCI_OFFSET_SECOND_RANGE(adapter,
+					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW_F3));
+			break;
+		default:
+			printk("Changing the window for PCI function %d\n",
+				adapter->portnum);
+			offset = PCI_OFFSET_SECOND_RANGE(adapter,
+					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW));
+			break;
+	}
 	/*
 	 * Move the CRB window.
 	 * We need to write to the "direct access" region of PCI
@@ -482,9 +617,6 @@ void netxen_nic_pci_change_crbwindow(str
 	 * register address is received by PCI. The direct region bypasses
 	 * the CRB bus.
 	 */
-	offset =
-	    PCI_OFFSET_SECOND_RANGE(adapter,
-				    NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW));
 
 	if (wndw & 0x1)
 		wndw = NETXEN_WINDOW_ONE;
@@ -808,18 +940,16 @@ int netxen_nic_get_board_info(struct net
 
 /* NIU access sections */
 
-int netxen_nic_set_mtu_gb(struct netxen_port *port, int new_mtu)
+int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu)
 {
-	struct netxen_adapter *adapter = port->adapter;
 	netxen_nic_write_w0(adapter,
-			    NETXEN_NIU_GB_MAX_FRAME_SIZE(port->portnum),
+			    NETXEN_NIU_GB_MAX_FRAME_SIZE(adapter->portnum),
 			    new_mtu);
 	return 0;
 }
 
-int netxen_nic_set_mtu_xgb(struct netxen_port *port, int new_mtu)
+int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
 {
-	struct netxen_adapter *adapter = port->adapter;
 	new_mtu += NETXEN_NIU_HDRSIZE + NETXEN_NIU_TLRSIZE;
 	netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE, new_mtu);
 	return 0;
@@ -827,21 +957,7 @@ int netxen_nic_set_mtu_xgb(struct netxen
 
 void netxen_nic_init_niu_gb(struct netxen_adapter *adapter)
 {
-	int portno;
-	for (portno = 0; portno < NETXEN_NIU_MAX_GBE_PORTS; portno++)
-		netxen_niu_gbe_init_port(adapter, portno);
-}
-
-void netxen_nic_stop_all_ports(struct netxen_adapter *adapter)
-{
-	int port_nr;
-	struct netxen_port *port;
-
-	for (port_nr = 0; port_nr < adapter->ahw.max_ports; port_nr++) {
-		port = adapter->port[port_nr];
-		if (adapter->stop_port)
-			adapter->stop_port(adapter, port->portnum);
-	}
+	netxen_niu_gbe_init_port(adapter, adapter->portnum);
 }
 
 void
@@ -860,9 +976,8 @@ netxen_crb_writelit_adapter(struct netxe
 	}
 }
 
-void netxen_nic_set_link_parameters(struct netxen_port *port)
+void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 {
-	struct netxen_adapter *adapter = port->adapter;
 	__u32 status;
 	__u32 autoneg;
 	__u32 mode;
@@ -871,47 +986,47 @@ void netxen_nic_set_link_parameters(stru
 	if (netxen_get_niu_enable_ge(mode)) {	/* Gb 10/100/1000 Mbps mode */
 		if (adapter->phy_read
 		    && adapter->
-		    phy_read(adapter, port->portnum,
+		    phy_read(adapter, adapter->portnum,
 			     NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 			     &status) == 0) {
 			if (netxen_get_phy_link(status)) {
 				switch (netxen_get_phy_speed(status)) {
 				case 0:
-					port->link_speed = SPEED_10;
+					adapter->link_speed = SPEED_10;
 					break;
 				case 1:
-					port->link_speed = SPEED_100;
+					adapter->link_speed = SPEED_100;
 					break;
 				case 2:
-					port->link_speed = SPEED_1000;
+					adapter->link_speed = SPEED_1000;
 					break;
 				default:
-					port->link_speed = -1;
+					adapter->link_speed = -1;
 					break;
 				}
 				switch (netxen_get_phy_duplex(status)) {
 				case 0:
-					port->link_duplex = DUPLEX_HALF;
+					adapter->link_duplex = DUPLEX_HALF;
 					break;
 				case 1:
-					port->link_duplex = DUPLEX_FULL;
+					adapter->link_duplex = DUPLEX_FULL;
 					break;
 				default:
-					port->link_duplex = -1;
+					adapter->link_duplex = -1;
 					break;
 				}
 				if (adapter->phy_read
 				    && adapter->
-				    phy_read(adapter, port->portnum,
+				    phy_read(adapter, adapter->portnum,
 					     NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
 					     &autoneg) != 0)
-					port->link_autoneg = autoneg;
+					adapter->link_autoneg = autoneg;
 			} else
 				goto link_down;
 		} else {
 		      link_down:
-			port->link_speed = -1;
-			port->link_duplex = -1;
+			adapter->link_speed = -1;
+			adapter->link_duplex = -1;
 		}
 	}
 }
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index ab1112e..841341d 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
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
@@ -87,7 +87,7 @@ #define NETXEN_NIC_LOCKED_READ_REG(X, Y)
 	*(u32 *)Y = readl((void __iomem*) addr);
 
 struct netxen_port;
-void netxen_nic_set_link_parameters(struct netxen_port *port);
+void netxen_nic_set_link_parameters(struct netxen_adapter *adapter);
 void netxen_nic_flash_print(struct netxen_adapter *adapter);
 int netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off,
 			   void *data, int len);
@@ -452,21 +452,21 @@ #define netxen_nic_mcr_set_enable_pool(c
 		((config) |= (((val) & 0x0f) << 28))
 
 /* Set promiscuous mode for a GbE interface */
-int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, int port,
+int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, 
 				    netxen_niu_prom_mode_t mode);
 int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
-				       int port, netxen_niu_prom_mode_t mode);
+				       netxen_niu_prom_mode_t mode);
 
 /* get/set the MAC address for a given MAC */
 int netxen_niu_macaddr_get(struct netxen_adapter *adapter, int port,
 			   netxen_ethernet_macaddr_t * addr);
-int netxen_niu_macaddr_set(struct netxen_port *port,
+int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
 			   netxen_ethernet_macaddr_t addr);
 
 /* XG versons */
 int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter, int port,
 			      netxen_ethernet_macaddr_t * addr);
-int netxen_niu_xg_macaddr_set(struct netxen_port *port,
+int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 			      netxen_ethernet_macaddr_t addr);
 
 /* Generic enable for GbE ports. Will detect the speed of the link. */
@@ -475,8 +475,8 @@ int netxen_niu_gbe_init_port(struct netx
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port);
 
 /* Disable a GbE interface */
-int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter, int port);
+int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter);
 
-int netxen_niu_disable_xg_port(struct netxen_adapter *adapter, int port);
+int netxen_niu_disable_xg_port(struct netxen_adapter *adapter);
 
 #endif				/* __NETXEN_NIC_HW_H_ */
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 586d32b..5f7151f 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -137,7 +137,7 @@ int netxen_init_firmware(struct netxen_a
 		return err;
 	}
 	/* Window 1 call */
-	writel(MPORT_SINGLE_FUNCTION_MODE,
+	writel(MPORT_MULTI_FUNCTION_MODE,
 	       NETXEN_CRB_NORMALIZE(adapter, CRB_MPORT_MODE));
 	writel(PHAN_INITIALIZE_ACK,
 	       NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
@@ -982,9 +982,7 @@ int netxen_nic_rx_has_work(struct netxen
 
 static inline int netxen_nic_check_temp(struct netxen_adapter *adapter)
 {
-	int port_num;
-	struct netxen_port *port;
-	struct net_device *netdev;
+	struct net_device *netdev = adapter->netdev;
 	uint32_t temp, temp_state, temp_val;
 	int rv = 0;
 
@@ -998,14 +996,9 @@ static inline int netxen_nic_check_temp(
 		       "%s: Device temperature %d degrees C exceeds"
 		       " maximum allowed. Hardware has been shut down.\n",
 		       netxen_nic_driver_name, temp_val);
-		for (port_num = 0; port_num < adapter->ahw.max_ports;
-		     port_num++) {
-			port = adapter->port[port_num];
-			netdev = port->netdev;
 
-			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
-		}
+		netif_carrier_off(netdev);
+		netif_stop_queue(netdev);
 		rv = 1;
 	} else if (temp_state == NX_TEMP_WARN) {
 		if (adapter->temp == NX_TEMP_NORMAL) {
@@ -1029,8 +1022,6 @@ static inline int netxen_nic_check_temp(
 
 void netxen_watchdog_task(struct work_struct *work)
 {
-	int port_num;
-	struct netxen_port *port;
 	struct net_device *netdev;
 	struct netxen_adapter *adapter =
 		container_of(work, struct netxen_adapter, watchdog_task);
@@ -1038,20 +1029,16 @@ void netxen_watchdog_task(struct work_st
 	if (netxen_nic_check_temp(adapter))
 		return;
 
-	for (port_num = 0; port_num < adapter->ahw.max_ports; port_num++) {
-		port = adapter->port[port_num];
-		netdev = port->netdev;
-
-		if ((netif_running(netdev)) && !netif_carrier_ok(netdev)) {
-			printk(KERN_INFO "%s port %d, %s carrier is now ok\n",
-			       netxen_nic_driver_name, port_num, netdev->name);
-			netif_carrier_on(netdev);
-		}
-
-		if (netif_queue_stopped(netdev))
-			netif_wake_queue(netdev);
+	netdev = adapter->netdev;
+	if ((netif_running(netdev)) && !netif_carrier_ok(netdev)) {
+		printk(KERN_INFO "%s port %d, %s carrier is now ok\n",
+		       netxen_nic_driver_name, adapter->portnum, netdev->name);
+		netif_carrier_on(netdev);
 	}
 
+	if (netif_queue_stopped(netdev))
+		netif_wake_queue(netdev);
+
 	if (adapter->handle_phy_intr)
 		adapter->handle_phy_intr(adapter);
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
@@ -1066,9 +1053,8 @@ void
 netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 		   struct status_desc *desc)
 {
-	struct netxen_port *port = adapter->port[netxen_get_sts_port(desc)];
-	struct pci_dev *pdev = port->pdev;
-	struct net_device *netdev = port->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	struct net_device *netdev = adapter->netdev;
 	int index = netxen_get_sts_refhandle(desc);
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
 	struct netxen_rx_buffer *buffer;
@@ -1118,7 +1104,7 @@ netxen_process_rcv(struct netxen_adapter
 	skb = (struct sk_buff *)buffer->skb;
 
 	if (likely(netxen_get_sts_status(desc) == STATUS_CKSUM_OK)) {
-		port->stats.csummed++;
+		adapter->stats.csummed++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 	skb->dev = netdev;
@@ -1139,27 +1125,27 @@ netxen_process_rcv(struct netxen_adapter
 	 */
 	switch (ret) {
 	case NET_RX_SUCCESS:
-		port->stats.uphappy++;
+		adapter->stats.uphappy++;
 		break;
 
 	case NET_RX_CN_LOW:
-		port->stats.uplcong++;
+		adapter->stats.uplcong++;
 		break;
 
 	case NET_RX_CN_MOD:
-		port->stats.upmcong++;
+		adapter->stats.upmcong++;
 		break;
 
 	case NET_RX_CN_HIGH:
-		port->stats.uphcong++;
+		adapter->stats.uphcong++;
 		break;
 
 	case NET_RX_DROP:
-		port->stats.updropped++;
+		adapter->stats.updropped++;
 		break;
 
 	default:
-		port->stats.updunno++;
+		adapter->stats.updunno++;
 		break;
 	}
 
@@ -1171,14 +1157,13 @@ netxen_process_rcv(struct netxen_adapter
 	/*
 	 * We just consumed one buffer so post a buffer.
 	 */
-	adapter->stats.post_called++;
 	buffer->skb = NULL;
 	buffer->state = NETXEN_BUFFER_FREE;
 	buffer->lro_current_frags = 0;
 	buffer->lro_expected_frags = 0;
 
-	port->stats.no_rcv++;
-	port->stats.rxbytes += length;
+	adapter->stats.no_rcv++;
+	adapter->stats.rxbytes += length;
 }
 
 /* Process Receive status ring */
@@ -1219,7 +1204,6 @@ u32 netxen_process_rcv_ring(struct netxe
 
 	/* update the consumer index in phantom */
 	if (count) {
-		adapter->stats.process_rcv++;
 		recv_ctx->status_rx_consumer = consumer;
 		recv_ctx->status_rx_producer = producer;
 
@@ -1242,13 +1226,10 @@ int netxen_process_cmd_ring(unsigned lon
 	int count1 = 0;
 	int count2 = 0;
 	struct netxen_cmd_buffer *buffer;
-	struct netxen_port *port;	/* port #1 */
-	struct netxen_port *nport;
 	struct pci_dev *pdev;
 	struct netxen_skb_frag *frag;
 	u32 i;
 	struct sk_buff *skb = NULL;
-	int p;
 	int done;
 
 	spin_lock(&adapter->tx_lock);
@@ -1269,7 +1250,6 @@ int netxen_process_cmd_ring(unsigned lon
 	}
 
 	adapter->proc_cmd_buf_counter++;
-	adapter->stats.process_xmit++;
 	/*
 	 * Not needed - does not seem to be used anywhere.
 	 * adapter->cmd_consumer = consumer;
@@ -1278,8 +1258,7 @@ int netxen_process_cmd_ring(unsigned lon
 
 	while ((last_consumer != consumer) && (count1 < MAX_STATUS_HANDLE)) {
 		buffer = &adapter->cmd_buf_arr[last_consumer];
-		port = adapter->port[buffer->port];
-		pdev = port->pdev;
+		pdev = adapter->pdev;
 		frag = &buffer->frag_array[0];
 		skb = buffer->skb;
 		if (skb && (cmpxchg(&buffer->skb, skb, 0) == skb)) {
@@ -1292,24 +1271,23 @@ int netxen_process_cmd_ring(unsigned lon
 					       PCI_DMA_TODEVICE);
 			}
 
-			port->stats.skbfreed++;
+			adapter->stats.skbfreed++;
 			dev_kfree_skb_any(skb);
 			skb = NULL;
 		} else if (adapter->proc_cmd_buf_counter == 1) {
-			port->stats.txnullskb++;
+			adapter->stats.txnullskb++;
 		}
-		if (unlikely(netif_queue_stopped(port->netdev)
-			     && netif_carrier_ok(port->netdev))
-		    && ((jiffies - port->netdev->trans_start) >
-			port->netdev->watchdog_timeo)) {
-			SCHEDULE_WORK(&port->tx_timeout_task);
+		if (unlikely(netif_queue_stopped(adapter->netdev)
+			     && netif_carrier_ok(adapter->netdev))
+		    && ((jiffies - adapter->netdev->trans_start) >
+			adapter->netdev->watchdog_timeo)) {
+			SCHEDULE_WORK(&adapter->tx_timeout_task);
 		}
 
 		last_consumer = get_next_index(last_consumer,
 					       adapter->max_tx_desc_count);
 		count1++;
 	}
-	adapter->stats.noxmitdone += count1;
 
 	count2 = 0;
 	spin_lock(&adapter->tx_lock);
@@ -1329,13 +1307,10 @@ int netxen_process_cmd_ring(unsigned lon
 		}
 	}
 	if (count1 || count2) {
-		for (p = 0; p < adapter->ahw.max_ports; p++) {
-			nport = adapter->port[p];
-			if (netif_queue_stopped(nport->netdev)
-			    && (nport->flags & NETXEN_NETDEV_STATUS)) {
-				netif_wake_queue(nport->netdev);
-				nport->flags &= ~NETXEN_NETDEV_STATUS;
-			}
+		if (netif_queue_stopped(adapter->netdev)
+		    && (adapter->flags & NETXEN_NETDEV_STATUS)) {
+			netif_wake_queue(adapter->netdev);
+			adapter->flags &= ~NETXEN_NETDEV_STATUS;
 		}
 	}
 	/*
@@ -1381,7 +1356,6 @@ void netxen_post_rx_buffers(struct netxe
 	netxen_ctx_msg msg = 0;
 	dma_addr_t dma;
 
-	adapter->stats.post_called++;
 	rcv_desc = &recv_ctx->rcv_desc[ringid];
 
 	producer = rcv_desc->producer;
@@ -1434,8 +1408,6 @@ #endif
 	if (count) {
 		rcv_desc->begin_alloc = index;
 		rcv_desc->rcv_pending += count;
-		adapter->stats.lastposted = count;
-		adapter->stats.posted += count;
 		rcv_desc->producer = producer;
 		if (rcv_desc->rcv_free >= 32) {
 			rcv_desc->rcv_free = 0;
@@ -1443,7 +1415,7 @@ #endif
 			writel((producer - 1) &
 			       (rcv_desc->max_rx_desc_count - 1),
 			       NETXEN_CRB_NORMALIZE(adapter,
-						    recv_crb_registers[0].
+						    recv_crb_registers[adapter->portnum].
 						    rcv_desc_crb[ringid].
 						    crb_rcv_producer_offset));
 			/*
@@ -1456,7 +1428,7 @@ #endif
 					     ((producer -
 					       1) & (rcv_desc->
 						     max_rx_desc_count - 1)));
-			netxen_set_msg_ctxid(msg, 0);
+			netxen_set_msg_ctxid(msg, adapter->portnum);
 			netxen_set_msg_opcode(msg, NETXEN_RCV_PRODUCER(ringid));
 			writel(msg,
 			       DB_NORMALIZE(adapter,
@@ -1478,7 +1450,6 @@ void netxen_post_rx_buffers_nodb(struct 
 	int count = 0;
 	int index = 0;
 
-	adapter->stats.post_called++;
 	rcv_desc = &recv_ctx->rcv_desc[ringid];
 
 	producer = rcv_desc->producer;
@@ -1525,8 +1496,6 @@ void netxen_post_rx_buffers_nodb(struct 
 	if (count) {
 		rcv_desc->begin_alloc = index;
 		rcv_desc->rcv_pending += count;
-		adapter->stats.lastposted = count;
-		adapter->stats.posted += count;
 		rcv_desc->producer = producer;
 		if (rcv_desc->rcv_free >= 32) {
 			rcv_desc->rcv_free = 0;
@@ -1534,7 +1503,7 @@ void netxen_post_rx_buffers_nodb(struct 
 			writel((producer - 1) &
 			       (rcv_desc->max_rx_desc_count - 1),
 			       NETXEN_CRB_NORMALIZE(adapter,
-						    recv_crb_registers[0].
+						    recv_crb_registers[adapter->portnum].
 						    rcv_desc_crb[ringid].
 						    crb_rcv_producer_offset));
 			wmb();
@@ -1555,13 +1524,7 @@ int netxen_nic_tx_has_work(struct netxen
 
 void netxen_nic_clear_stats(struct netxen_adapter *adapter)
 {
-	struct netxen_port *port;
-	int port_num;
-
 	memset(&adapter->stats, 0, sizeof(adapter->stats));
-	for (port_num = 0; port_num < adapter->ahw.max_ports; port_num++) {
-		port = adapter->port[port_num];
-		memset(&port->stats, 0, sizeof(port->stats));
-	}
+	return;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index be366e4..d557bb4 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
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
@@ -34,6 +34,7 @@ #include "netxen_nic.h"
 #include "netxen_nic_hw.h"
 #include "netxen_nic_phan_reg.h"
 
+#if 0
 /*
  * netxen_nic_get_stats - Get System Network Statistics
  * @netdev: network interface device structure
@@ -41,7 +42,7 @@ #include "netxen_nic_phan_reg.h"
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
 {
 	struct netxen_port *port = netdev_priv(netdev);
-	struct net_device_stats *stats = &port->net_stats;
+	struct net_device_stats *stats = &adapter->net_stats;
 
 	memset(stats, 0, sizeof(*stats));
 
@@ -64,11 +65,10 @@ struct net_device_stats *netxen_nic_get_
 
 	return stats;
 }
-
-void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 portno,
-				 u32 link)
+#endif
+void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 link)
 {
-	struct net_device *netdev = (adapter->port[portno])->netdev;
+	struct net_device *netdev = adapter->netdev;
 
 	if (link)
 		netif_carrier_on(netdev);
@@ -76,15 +76,13 @@ void netxen_indicate_link_status(struct 
 		netif_carrier_off(netdev);
 }
 
-void netxen_handle_port_int(struct netxen_adapter *adapter, u32 portno,
-			    u32 enable)
+void netxen_handle_port_int(struct netxen_adapter *adapter, u32 enable)
 {
 	__u32 int_src;
-	struct netxen_port *port;
 
 	/*  This should clear the interrupt source */
 	if (adapter->phy_read)
-		adapter->phy_read(adapter, portno,
+		adapter->phy_read(adapter, adapter->portnum,
 				  NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
 				  &int_src);
 	if (int_src == 0) {
@@ -92,9 +90,7 @@ void netxen_handle_port_int(struct netxe
 		return;
 	}
 	if (adapter->disable_phy_interrupts)
-		adapter->disable_phy_interrupts(adapter, portno);
-
-	port = adapter->port[portno];
+		adapter->disable_phy_interrupts(adapter, adapter->portnum);
 
 	if (netxen_get_phy_int_jabber(int_src))
 		DPRINTK(INFO, "Jabber interrupt \n");
@@ -115,64 +111,59 @@ void netxen_handle_port_int(struct netxe
 		DPRINTK(INFO, "SPEED CHANGED OR LINK STATUS CHANGED \n");
 
 		if (adapter->phy_read
-		    && adapter->phy_read(adapter, portno,
+		    && adapter->phy_read(adapter, adapter->portnum,
 					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					 &status) == 0) {
 			if (netxen_get_phy_int_link_status_changed(int_src)) {
 				if (netxen_get_phy_link(status)) {
 					netxen_niu_gbe_init_port(adapter,
-								 portno);
+								 adapter->portnum);
 					printk("%s: %s Link UP\n",
 					       netxen_nic_driver_name,
-					       port->netdev->name);
+					       adapter->netdev->name);
 
 				} else {
 					printk("%s: %s Link DOWN\n",
 					       netxen_nic_driver_name,
-					       port->netdev->name);
+					       adapter->netdev->name);
 				}
-				netxen_indicate_link_status(adapter, portno,
+				netxen_indicate_link_status(adapter, 
 							    netxen_get_phy_link
 							    (status));
 			}
 		}
 	}
 	if (adapter->enable_phy_interrupts)
-		adapter->enable_phy_interrupts(adapter, portno);
+		adapter->enable_phy_interrupts(adapter, adapter->portnum);
 }
 
 void netxen_nic_isr_other(struct netxen_adapter *adapter)
 {
-	u32 portno;
+	int portno = adapter->portnum;
 	u32 val, linkup, qg_linksup;
 
 	/* verify the offset */
 	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
+	val = val >> adapter->portnum;
 	if (val == adapter->ahw.qg_linksup)
 		return;
 
 	qg_linksup = adapter->ahw.qg_linksup;
 	adapter->ahw.qg_linksup = val;
 	DPRINTK(INFO, "link update 0x%08x\n", val);
-	for (portno = 0; portno < NETXEN_NIU_MAX_GBE_PORTS; portno++) {
-		linkup = val & 1;
-		if (linkup != (qg_linksup & 1)) {
-			printk(KERN_INFO "%s: %s PORT %d link %s\n",
-			       adapter->port[portno]->netdev->name,
-			       netxen_nic_driver_name, portno,
-			       ((linkup == 0) ? "down" : "up"));
-			netxen_indicate_link_status(adapter, portno, linkup);
-			if (linkup)
-				netxen_nic_set_link_parameters(adapter->
-							       port[portno]);
 
-		}
-		val = val >> 1;
-		qg_linksup = qg_linksup >> 1;
-	}
+	linkup = val & 1;
 
-	adapter->stats.otherints++;
+	if (linkup != (qg_linksup & 1)) {
+		printk(KERN_INFO "%s: %s PORT %d link %s\n",
+		       adapter->netdev->name,
+		       netxen_nic_driver_name, portno,
+		       ((linkup == 0) ? "down" : "up"));
+		netxen_indicate_link_status(adapter, linkup);
+		if (linkup)
+			netxen_nic_set_link_parameters(adapter);
 
+	}
 }
 
 void netxen_nic_gbe_handle_phy_intr(struct netxen_adapter *adapter)
@@ -182,26 +173,27 @@ void netxen_nic_gbe_handle_phy_intr(stru
 
 void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter)
 {
-	struct net_device *netdev = adapter->port[0]->netdev;
-	u32 val;
+	struct net_device *netdev = adapter->netdev;
+	u32 val, val1;
 
 	/* WINDOW = 1 */
 	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
+	val1 = val & 0xff;
 
-	if (adapter->ahw.xg_linkup == 1 && val != XG_LINK_UP) {
+	if (adapter->ahw.xg_linkup == 1 && val1 != XG_LINK_UP) {
 		printk(KERN_INFO "%s: %s NIC Link is down\n",
 		       netxen_nic_driver_name, netdev->name);
 		adapter->ahw.xg_linkup = 0;
 		/* read twice to clear sticky bits */
 		/* WINDOW = 0 */
-		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_STATUS, &val);
-		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_STATUS, &val);
+		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_STATUS, &val1);
+		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_STATUS, &val1);
 
 		if ((val & 0xffb) != 0xffb) {
 			printk(KERN_INFO "%s ISR: Sync/Align BAD: 0x%08x\n",
-			       netxen_nic_driver_name, val);
+			       netxen_nic_driver_name, val1);
 		}
-	} else if (adapter->ahw.xg_linkup == 0 && val == XG_LINK_UP) {
+	} else if (adapter->ahw.xg_linkup == 0 && val1 == XG_LINK_UP) {
 		printk(KERN_INFO "%s: %s NIC Link is up\n",
 		       netxen_nic_driver_name, netdev->name);
 		adapter->ahw.xg_linkup = 1;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 7d2525e..a1926ec 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -36,7 +36,6 @@ #include <linux/highmem.h>
 #include "netxen_nic_hw.h"
 
 #include "netxen_nic.h"
-#define DEFINE_GLOBAL_RECV_CRB
 #include "netxen_nic_phan_reg.h"
 
 #include <linux/dma-mapping.h>
@@ -93,6 +92,65 @@ MODULE_DEVICE_TABLE(pci, netxen_pci_tbl)
 struct workqueue_struct *netxen_workq;
 static void netxen_watchdog(unsigned long);
 
+static inline void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
+							uint32_t crb_producer)
+{
+	switch (adapter->portnum) {
+		case 0:
+			writel(crb_producer, NETXEN_CRB_NORMALIZE
+					(adapter, CRB_CMD_PRODUCER_OFFSET));
+			return;
+		case 1:
+			writel(crb_producer, NETXEN_CRB_NORMALIZE
+					(adapter, CRB_CMD_PRODUCER_OFFSET_1));
+			return;
+		case 2:
+			writel(crb_producer, NETXEN_CRB_NORMALIZE
+					(adapter, CRB_CMD_PRODUCER_OFFSET_2));
+			return;
+		case 3:
+			writel(crb_producer, NETXEN_CRB_NORMALIZE
+					(adapter, CRB_CMD_PRODUCER_OFFSET_3));
+			return;
+		default:
+			printk("We tried to update CRB_CMD_PRODUCER_OFFSET for"
+					"invalid PCI function id %d\n",
+					adapter->portnum);
+			return;
+	}
+}
+
+static inline void netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
+							u32 crb_consumer)
+{
+	switch (adapter->portnum) {
+		case 0:
+			writel(crb_consumer, NETXEN_CRB_NORMALIZE
+				(adapter, CRB_CMD_CONSUMER_OFFSET));
+			return;
+		case 1:
+			writel(crb_consumer, NETXEN_CRB_NORMALIZE
+				(adapter, CRB_CMD_CONSUMER_OFFSET_1));
+			return;
+		case 2:
+			writel(crb_consumer, NETXEN_CRB_NORMALIZE
+				(adapter, CRB_CMD_CONSUMER_OFFSET_2));
+			return;
+		case 3:
+			writel(crb_consumer, NETXEN_CRB_NORMALIZE
+				(adapter, CRB_CMD_CONSUMER_OFFSET_3));
+			return;
+		default:
+			printk("We tried to update CRB_CMD_PRODUCER_OFFSET for"
+					"invalid PCI function id %d\n",
+					adapter->portnum);
+			return;
+	}
+}
+
+#define	ADAPTER_LIST_SIZE 12
+int netxen_cards_found;
+
 /*
  * netxen_nic_probe()
  *
@@ -110,26 +168,26 @@ netxen_nic_probe(struct pci_dev *pdev, c
 {
 	struct net_device *netdev = NULL;
 	struct netxen_adapter *adapter = NULL;
-	struct netxen_port *port = NULL;
 	void __iomem *mem_ptr0 = NULL;
 	void __iomem *mem_ptr1 = NULL;
 	void __iomem *mem_ptr2 = NULL;
 
 	u8 __iomem *db_ptr = NULL;
 	unsigned long mem_base, mem_len, db_base, db_len;
-	int pci_using_dac, i, err;
+	int pci_using_dac, i = 0, err;
 	int ring;
 	struct netxen_recv_context *recv_ctx = NULL;
 	struct netxen_rcv_desc_ctx *rcv_desc = NULL;
 	struct netxen_cmd_buffer *cmd_buf_arr = NULL;
 	u64 mac_addr[FLASH_NUM_PORTS + 1];
-	int valid_mac = 0;
+	static int valid_mac = 0;
+	static int netxen_probe_flag;
+	int pci_func_id = PCI_FUNC(pdev->devfn);
 
 	printk(KERN_INFO "%s \n", netxen_nic_driver_string);
-	/* In current scheme, we use only PCI function 0 */
-	if (PCI_FUNC(pdev->devfn) != 0) {
-		DPRINTK(ERR, "NetXen function %d will not be enabled.\n",
-			PCI_FUNC(pdev->devfn));
+	if (pdev->class != 0x020000) {
+		printk(KERN_ERR"NetXen function %d, class %x will not"
+				"be enabled.\n",pci_func_id, pdev->class);
 		return -ENODEV;
 	}
 	if ((err = pci_enable_device(pdev)))
@@ -156,6 +214,22 @@ netxen_nic_probe(struct pci_dev *pdev, c
 		pci_using_dac = 0;
 	}
 
+
+	netdev = alloc_etherdev(sizeof(struct netxen_adapter));
+	if(!netdev) {
+		printk(KERN_ERR"%s: Failed to allocate memory for the "
+				"device block.Check system memory resource"
+				" usage.\n", netxen_nic_driver_name);
+		goto err_out_free_res;
+	}
+
+	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	adapter = netdev->priv;
+	memset(adapter, 0 , sizeof(struct netxen_adapter));
+
+	adapter->ahw.pdev = pdev;
 	/* remap phys address */
 	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
 	mem_len = pci_resource_len(pdev, 0);
@@ -197,23 +271,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	}
 	DPRINTK(INFO, "doorbell ioremaped at %p\n", db_ptr);
 
-/*
- *      Allocate a adapter structure which will manage all the initialization
- *      as well as the common resources for all ports...
- *      all the ports will have pointer to this adapter as well as Adapter
- *      will have pointers of all the ports structures.
- */
-
-	/* One adapter structure for all 4 ports....   */
-	adapter = kzalloc(sizeof(struct netxen_adapter), GFP_KERNEL);
-	if (adapter == NULL) {
-		printk(KERN_ERR "%s: Could not allocate adapter memory:%d\n",
-		       netxen_nic_driver_name,
-		       (int)sizeof(struct netxen_adapter));
-		err = -ENOMEM;
-		goto err_out_dbunmap;
-	}
-
 	adapter->max_tx_desc_count = MAX_CMD_DESCRIPTORS;
 	adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS;
 	adapter->max_jumbo_rx_desc_count = MAX_JUMBO_RCV_DESCRIPTORS;
@@ -221,6 +278,42 @@ netxen_nic_probe(struct pci_dev *pdev, c
 
 	pci_set_drvdata(pdev, adapter);
 
+	adapter->netdev  = netdev;
+	adapter->pdev    = pdev;
+	adapter->portnum = pci_func_id;
+
+	netdev->open		   = netxen_nic_open;
+	netdev->stop		   = netxen_nic_close;
+	netdev->hard_start_xmit    = netxen_nic_xmit_frame;
+	netdev->set_multicast_list = netxen_nic_set_multi;
+	netdev->set_mac_address    = netxen_nic_set_mac;
+	netdev->change_mtu	   = netxen_nic_change_mtu;
+	netdev->tx_timeout	   = netxen_tx_timeout;
+	netdev->watchdog_timeo     = HZ;
+
+	netxen_nic_change_mtu(netdev, netdev->mtu);
+
+	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
+	netdev->poll = netxen_nic_poll;
+	netdev->weight = NETXEN_NETDEV_WEIGHT;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = netxen_nic_poll_controller;
+#endif
+	/* ScatterGather support */
+	netdev->features = NETIF_F_SG;
+	netdev->features |= NETIF_F_IP_CSUM;
+	netdev->features |= NETIF_F_TSO;
+
+	if (pci_using_dac)
+		netdev->features |= NETIF_F_HIGHDMA;
+
+	if (pci_enable_msi(pdev)) {
+		adapter->flags &= ~NETXEN_NIC_MSI_ENABLED;
+		printk(KERN_WARNING "%s: unable to allocate MSI interrupt"
+		       " error\n", netxen_nic_driver_name);
+	} else
+		adapter->flags |= NETXEN_NIC_MSI_ENABLED;
+
 	cmd_buf_arr = (struct netxen_cmd_buffer *)vmalloc(TX_RINGSIZE);
 	if (cmd_buf_arr == NULL) {
 		printk(KERN_ERR
@@ -287,9 +380,11 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	spin_lock_init(&adapter->lock);
 	netxen_initialize_adapter_sw(adapter);	/* initialize the buffers in adapter */
 #ifdef CONFIG_IA64
-	netxen_pinit_from_rom(adapter, 0);
-	udelay(500);
-	netxen_load_firmware(adapter);
+	if(netxen_probe_flag == 0) {
+		netxen_pinit_from_rom(adapter, 0);
+		udelay(500);
+		netxen_load_firmware(adapter);
+	}
 #endif
 
 	/*
@@ -303,6 +398,10 @@ #endif
 	 */
 	netxen_initialize_adapter_hw(adapter);	/* initialize the adapter */
 
+	if (adapter->ahw.boardcfg.board_type == NETXEN_BRDTYPE_P2_SB31_10G_IMEZ)
+		if (pci_func_id >= 2)
+			adapter->portnum = pci_func_id - 2;
+
 	netxen_initialize_adapter_ops(adapter);
 
 	init_timer(&adapter->watchdog_timer);
@@ -314,12 +413,8 @@ #endif
 	adapter->proc_cmd_buf_counter = 0;
 	adapter->ahw.revision_id = nx_p2_id;
 
-	if (pci_enable_msi(pdev)) {
-		adapter->flags &= ~NETXEN_NIC_MSI_ENABLED;
-		printk(KERN_WARNING "%s: unable to allocate MSI interrupt"
-		       " error\n", netxen_nic_driver_name);
-	} else
-		adapter->flags |= NETXEN_NIC_MSI_ENABLED;
+	netxen_nic_update_cmd_producer(adapter, 0);
+	netxen_nic_update_cmd_consumer(adapter, 0);
 
 	if (netxen_is_flash_supported(adapter) == 0 &&
 	    netxen_get_flash_mac_addr(adapter, mac_addr) == 0)
@@ -327,6 +422,34 @@ #endif
 	else
 		valid_mac = 0;
 
+	if (valid_mac) {
+		unsigned char *p = (unsigned char *)&mac_addr[i];
+		netdev->dev_addr[0] = *(p + 5);
+		netdev->dev_addr[1] = *(p + 4);
+		netdev->dev_addr[2] = *(p + 3);
+		netdev->dev_addr[3] = *(p + 2);
+		netdev->dev_addr[4] = *(p + 1);
+		netdev->dev_addr[5] = *(p + 0);
+
+		memcpy(netdev->perm_addr, netdev->dev_addr,
+			netdev->addr_len);
+		if (!is_valid_ether_addr(netdev->perm_addr)) {
+			printk(KERN_ERR "%s: Bad MAC address "
+				"%02x:%02x:%02x:%02x:%02x:%02x.\n",
+				netxen_nic_driver_name,
+				netdev->dev_addr[0],
+				netdev->dev_addr[1],
+				netdev->dev_addr[2],
+				netdev->dev_addr[3],
+				netdev->dev_addr[4],
+				netdev->dev_addr[5]);
+		} else {
+			if (adapter->macaddr_set)
+				adapter->macaddr_set(adapter,
+							netdev->dev_addr);
+		}
+	}
+
 	/*
 	 * Initialize all the CRB registers here.
 	 */
@@ -336,140 +459,61 @@ #endif
 
 	/* do this before waking up pegs so that we have valid dummy dma addr */
 	err = netxen_initialize_adapter_offload(adapter);
-	if (err) {
+	if (err) 
 		goto err_out_free_dev;
-	}
-
-	/* Unlock the HW, prompting the boot sequence */
-	writel(1,
-	       NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
-
-	/* Handshake with the card before we register the devices. */
-	netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
-
-	/* initialize the all the ports */
-	adapter->active_ports = 0;
-
-	for (i = 0; i < adapter->ahw.max_ports; i++) {
-		netdev = alloc_etherdev(sizeof(struct netxen_port));
-		if (!netdev) {
-			printk(KERN_ERR "%s: could not allocate netdev for port"
-			       " %d\n", netxen_nic_driver_name, i + 1);
-			goto err_out_free_dev;
-		}
 
-		SET_MODULE_OWNER(netdev);
-		SET_NETDEV_DEV(netdev, &pdev->dev);
-
-		port = netdev_priv(netdev);
-		port->netdev = netdev;
-		port->pdev = pdev;
-		port->adapter = adapter;
-		port->portnum = i;	/* Gigabit port number from 0-3 */
-
-		netdev->open = netxen_nic_open;
-		netdev->stop = netxen_nic_close;
-		netdev->hard_start_xmit = netxen_nic_xmit_frame;
-		netdev->get_stats = netxen_nic_get_stats;
-		netdev->set_multicast_list = netxen_nic_set_multi;
-		netdev->set_mac_address = netxen_nic_set_mac;
-		netdev->change_mtu = netxen_nic_change_mtu;
-		netdev->tx_timeout = netxen_tx_timeout;
-		netdev->watchdog_timeo = HZ;
-
-		netxen_nic_change_mtu(netdev, netdev->mtu);
-
-		SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
-		netdev->poll = netxen_nic_poll;
-		netdev->weight = NETXEN_NETDEV_WEIGHT;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-		netdev->poll_controller = netxen_nic_poll_controller;
-#endif
-		/* ScatterGather support */
-		netdev->features = NETIF_F_SG;
-		netdev->features |= NETIF_F_IP_CSUM;
-		netdev->features |= NETIF_F_TSO;
-
-		if (pci_using_dac)
-			netdev->features |= NETIF_F_HIGHDMA;
-
-		if (valid_mac) {
-			unsigned char *p = (unsigned char *)&mac_addr[i];
-			netdev->dev_addr[0] = *(p + 5);
-			netdev->dev_addr[1] = *(p + 4);
-			netdev->dev_addr[2] = *(p + 3);
-			netdev->dev_addr[3] = *(p + 2);
-			netdev->dev_addr[4] = *(p + 1);
-			netdev->dev_addr[5] = *(p + 0);
-
-			memcpy(netdev->perm_addr, netdev->dev_addr,
-			       netdev->addr_len);
-			if (!is_valid_ether_addr(netdev->perm_addr)) {
-				printk(KERN_ERR "%s: Bad MAC address "
-				       "%02x:%02x:%02x:%02x:%02x:%02x.\n",
-				       netxen_nic_driver_name,
-				       netdev->dev_addr[0],
-				       netdev->dev_addr[1],
-				       netdev->dev_addr[2],
-				       netdev->dev_addr[3],
-				       netdev->dev_addr[4],
-				       netdev->dev_addr[5]);
-			} else {
-				if (adapter->macaddr_set)
-					adapter->macaddr_set(port,
-							     netdev->dev_addr);
-			}
-		}
-		INIT_WORK(&port->tx_timeout_task, netxen_tx_timeout_task);
-		netif_carrier_off(netdev);
-		netif_stop_queue(netdev);
+	if (netxen_probe_flag == 0) {
+		/* Unlock the HW, prompting the boot sequence */
+		writel(1,
+			NETXEN_CRB_NORMALIZE(adapter,
+				NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
+		/* Handshake with the card before we register the devices. */
+		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
+	}
 
-		if ((err = register_netdev(netdev))) {
-			printk(KERN_ERR "%s: register_netdev failed port #%d"
-			       " aborting\n", netxen_nic_driver_name, i + 1);
-			err = -EIO;
-			free_netdev(netdev);
-			goto err_out_free_dev;
-		}
-		adapter->port_count++;
-		adapter->port[i] = port;
+	if(netxen_probe_flag == 0) {
+		writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+		netxen_pinit_from_rom(adapter, 0);
+		udelay(500);
+		netxen_load_firmware(adapter);
+		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	}
-	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-	netxen_pinit_from_rom(adapter, 0);
-	udelay(500);
-	netxen_load_firmware(adapter);
-	netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	/*
 	 * delay a while to ensure that the Pegs are up & running.
 	 * Otherwise, we might see some flaky behaviour.
 	 */
 	udelay(100);
+	INIT_WORK(&adapter->tx_timeout_task, netxen_tx_timeout_task);
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
+	if((err = register_netdev(netdev)))
+		DPRINTK(1, ERR, "register_netdev failed port #%d"
+				" aborting\n", i+1);
 
 	switch (adapter->ahw.board_type) {
-	case NETXEN_NIC_GBE:
-		printk("%s: QUAD GbE board initialized\n",
-		       netxen_nic_driver_name);
-		break;
+		case NETXEN_NIC_GBE:
+			printk("%s: QUAD GbE board initialized\n",
+			       netxen_nic_driver_name);
+			break;
 
-	case NETXEN_NIC_XGBE:
-		printk("%s: XGbE board initialized\n", netxen_nic_driver_name);
-		break;
+		case NETXEN_NIC_XGBE:
+			printk("%s: XGbE board initialized\n", netxen_nic_driver_name);
+			break;
 	}
 
 	adapter->driver_mismatch = 0;
+	if(netxen_probe_flag == 0)
+		netxen_probe_flag ++;
 
 	return 0;
 
       err_out_free_dev:
 	if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
 		pci_disable_msi(pdev);
-	for (i = 0; i < adapter->port_count; i++) {
-		port = adapter->port[i];
-		if ((port) && (port->netdev)) {
-			unregister_netdev(port->netdev);
-			free_netdev(port->netdev);
-		}
-	}
+
+	unregister_netdev(adapter->netdev);
+	free_netdev(adapter->netdev);
 
 	netxen_free_adapter_offload(adapter);
 
@@ -490,7 +534,6 @@ #endif
 	pci_set_drvdata(pdev, NULL);
 	kfree(adapter);
 
-      err_out_dbunmap:
 	if (db_ptr)
 		iounmap(db_ptr);
 
@@ -512,35 +555,32 @@ #endif
 static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 {
 	struct netxen_adapter *adapter;
-	struct netxen_port *port;
+	struct net_device *netdev;
 	struct netxen_rx_buffer *buffer;
 	struct netxen_recv_context *recv_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
 	int i;
 	int ctxid, ring;
 
-	adapter = pci_get_drvdata(pdev);
+	netdev = pci_get_drvdata(pdev);
+	adapter = netdev_priv(netdev);
 	if (adapter == NULL)
 		return;
 
+	if (adapter->stop_port)
+		adapter->stop_port(adapter);
+
 	if (adapter->irq)
 		free_irq(adapter->irq, adapter);
-	netxen_nic_stop_all_ports(adapter);
 	/* leave the hw in the same state as reboot */
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
 	netxen_pinit_from_rom(adapter, 0);
-	udelay(500);
 	netxen_load_firmware(adapter);
 	netxen_free_adapter_offload(adapter);
 
-	mdelay(1000);		/* Delay for a while to drain the DMA engines */
-	for (i = 0; i < adapter->port_count; i++) {
-		port = adapter->port[i];
-		if ((port) && (port->netdev)) {
-			unregister_netdev(port->netdev);
-			free_netdev(port->netdev);
-		}
-	}
+	udelay(500);
+	unregister_netdev(netdev);
+	free_netdev(netdev);
 
 	if ((adapter->flags & NETXEN_NIC_MSI_ENABLED))
 		pci_disable_msi(pdev);
@@ -584,8 +624,7 @@ static void __devexit netxen_nic_remove(
  */
 static int netxen_nic_open(struct net_device *netdev)
 {
-	struct netxen_port *port = netdev_priv(netdev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = (struct netxen_adapter *)netdev->priv;
 	int err = 0;
 	int ctx, ring;
 
@@ -609,9 +648,9 @@ static int netxen_nic_open(struct net_de
 			return err;
 		}
 		if (adapter->init_port
-		    && adapter->init_port(adapter, port->portnum) != 0) {
+		    && adapter->init_port(adapter, adapter->portnum) != 0) {
 			printk(KERN_ERR "%s: Failed to initialize port %d\n",
-			       netxen_nic_driver_name, port->portnum);
+			       netxen_nic_driver_name, adapter->portnum);
 			netxen_free_hw_resources(adapter);
 			return -EIO;
 		}
@@ -631,23 +670,20 @@ static int netxen_nic_open(struct net_de
 
 		adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
 	}
-	adapter->active_ports++;
-	if (adapter->active_ports == 1) {
-		if (!adapter->driver_mismatch)
-			mod_timer(&adapter->watchdog_timer, jiffies);
+	if (!adapter->driver_mismatch)
+		mod_timer(&adapter->watchdog_timer, jiffies);
 
-		netxen_nic_enable_int(adapter);
-	}
+	netxen_nic_enable_int(adapter);
 
 	/* Done here again so that even if phantom sw overwrote it,
 	 * we set it */
 	if (adapter->macaddr_set)
-		adapter->macaddr_set(port, netdev->dev_addr);
-	netxen_nic_set_link_parameters(port);
+		adapter->macaddr_set(adapter, netdev->dev_addr);
+	netxen_nic_set_link_parameters(adapter);
 
 	netxen_nic_set_multi(netdev);
 	if (adapter->set_mtu)
-		adapter->set_mtu(port, netdev->mtu);
+		adapter->set_mtu(adapter, netdev->mtu);
 
 	if (!adapter->driver_mismatch)
 		netif_start_queue(netdev);
@@ -660,8 +696,7 @@ static int netxen_nic_open(struct net_de
  */
 static int netxen_nic_close(struct net_device *netdev)
 {
-	struct netxen_port *port = netdev_priv(netdev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(netdev);
 	int i, j;
 	struct netxen_cmd_buffer *cmd_buff;
 	struct netxen_skb_frag *buffrag;
@@ -669,47 +704,43 @@ static int netxen_nic_close(struct net_d
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	adapter->active_ports--;
-
-	if (!adapter->active_ports) {
-		netxen_nic_disable_int(adapter);
-		cmd_buff = adapter->cmd_buf_arr;
-		for (i = 0; i < adapter->max_tx_desc_count; i++) {
-			buffrag = cmd_buff->frag_array;
+	netxen_nic_disable_int(adapter);
+	if (adapter->irq)
+		free_irq(adapter->irq, adapter);
+	
+	cmd_buff = adapter->cmd_buf_arr;
+	for (i = 0; i < adapter->max_tx_desc_count; i++) {
+		buffrag = cmd_buff->frag_array;
+		if (buffrag->dma) {
+			pci_unmap_single(adapter->pdev, buffrag->dma,
+					 buffrag->length, PCI_DMA_TODEVICE);
+			buffrag->dma = (u64) NULL;
+		}
+		for (j = 0; j < cmd_buff->frag_count; j++) {
+			buffrag++;
 			if (buffrag->dma) {
-				pci_unmap_single(port->pdev, buffrag->dma,
-						 buffrag->length,
-						 PCI_DMA_TODEVICE);
+				pci_unmap_page(adapter->pdev, buffrag->dma,
+					       buffrag->length, 
+					       PCI_DMA_TODEVICE);
 				buffrag->dma = (u64) NULL;
 			}
-			for (j = 0; j < cmd_buff->frag_count; j++) {
-				buffrag++;
-				if (buffrag->dma) {
-					pci_unmap_page(port->pdev,
-						       buffrag->dma,
-						       buffrag->length,
-						       PCI_DMA_TODEVICE);
-					buffrag->dma = (u64) NULL;
-				}
-			}
-			/* Free the skb we received in netxen_nic_xmit_frame */
-			if (cmd_buff->skb) {
-				dev_kfree_skb_any(cmd_buff->skb);
-				cmd_buff->skb = NULL;
-			}
-			cmd_buff++;
 		}
-		FLUSH_SCHEDULED_WORK();
-		del_timer_sync(&adapter->watchdog_timer);
+		/* Free the skb we received in netxen_nic_xmit_frame */
+		if (cmd_buff->skb) {
+			dev_kfree_skb_any(cmd_buff->skb);
+			cmd_buff->skb = NULL;
+		}
+		cmd_buff++;
 	}
+	FLUSH_SCHEDULED_WORK();
+	del_timer_sync(&adapter->watchdog_timer);
 
 	return 0;
 }
 
 static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
-	struct netxen_port *port = netdev_priv(netdev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct netxen_hardware_context *hw = &adapter->ahw;
 	unsigned int first_seg_len = skb->len - skb->data_len;
 	struct netxen_skb_frag *buffrag;
@@ -727,12 +758,12 @@ static int netxen_nic_xmit_frame(struct 
 	u32 last_cmd_consumer = 0;
 	int no_of_desc;
 
-	port->stats.xmitcalled++;
+	adapter->stats.xmitcalled++;
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
 
 	if (unlikely(skb->len <= 0)) {
 		dev_kfree_skb_any(skb);
-		port->stats.badskblen++;
+		adapter->stats.badskblen++;
 		return NETDEV_TX_OK;
 	}
 
@@ -741,7 +772,7 @@ static int netxen_nic_xmit_frame(struct 
 		       "too large, can handle only %d frags\n",
 		       netxen_nic_driver_name, netdev->name,
 		       frag_count, MAX_BUFFERS_PER_CMD);
-		port->stats.txdropped++;
+		adapter->stats.txdropped++;
 		if ((++dropped_packet & 0xff) == 0xff)
 			printk("%s: %s droppped packets = %d\n",
 			       netxen_nic_driver_name, netdev->name,
@@ -758,7 +789,7 @@ static int netxen_nic_xmit_frame(struct 
 	 */
       retry_getting_window:
 	spin_lock_bh(&adapter->tx_lock);
-	if (adapter->total_threads == MAX_XMIT_PRODUCERS) {
+	if (adapter->total_threads >= MAX_XMIT_PRODUCERS) {
 		spin_unlock_bh(&adapter->tx_lock);
 		/*
 		 * Yield CPU
@@ -792,15 +823,8 @@ static int netxen_nic_xmit_frame(struct 
 	if ((k + no_of_desc) >=
 	    ((last_cmd_consumer <= k) ? last_cmd_consumer + max_tx_desc_count :
 	     last_cmd_consumer)) {
-		port->stats.nocmddescriptor++;
-		DPRINTK(ERR, "No command descriptors available,"
-			" producer = %d, consumer = %d count=%llu,"
-			" dropping packet\n", producer,
-			adapter->last_cmd_consumer,
-			port->stats.nocmddescriptor);
-
 		netif_stop_queue(netdev);
-		port->flags |= NETXEN_NETDEV_STATUS;
+		adapter->flags |= NETXEN_NETDEV_STATUS;
 		spin_unlock_bh(&adapter->tx_lock);
 		return NETDEV_TX_BUSY;
 	}
@@ -828,16 +852,16 @@ static int netxen_nic_xmit_frame(struct 
 	pbuf->skb = skb;
 	pbuf->cmd = TX_ETHER_PKT;
 	pbuf->frag_count = frag_count;
-	pbuf->port = port->portnum;
+	pbuf->port = adapter->portnum;
 	buffrag = &pbuf->frag_array[0];
-	buffrag->dma = pci_map_single(port->pdev, skb->data, first_seg_len,
+	buffrag->dma = pci_map_single(adapter->pdev, skb->data, first_seg_len,
 				      PCI_DMA_TODEVICE);
 	buffrag->length = first_seg_len;
 	netxen_set_cmd_desc_totallength(hwdesc, skb->len);
 	netxen_set_cmd_desc_num_of_buff(hwdesc, frag_count);
 	netxen_set_cmd_desc_opcode(hwdesc, TX_ETHER_PKT);
 
-	netxen_set_cmd_desc_port(hwdesc, port->portnum);
+	netxen_set_cmd_desc_port(hwdesc, adapter->portnum);
 	hwdesc->buffer1_length = cpu_to_le16(first_seg_len);
 	hwdesc->addr_buffer1 = cpu_to_le64(buffrag->dma);
 
@@ -860,7 +884,7 @@ static int netxen_nic_xmit_frame(struct 
 		offset = frag->page_offset;
 
 		temp_len = len;
-		temp_dma = pci_map_page(port->pdev, frag->page, offset,
+		temp_dma = pci_map_page(adapter->pdev, frag->page, offset,
 					len, PCI_DMA_TODEVICE);
 
 		buffrag++;
@@ -926,20 +950,19 @@ static int netxen_nic_xmit_frame(struct 
 		}
 	}
 	spin_lock_bh(&adapter->tx_lock);
-	port->stats.txbytes +=
+	adapter->stats.txbytes +=
 	    netxen_get_cmd_desc_totallength(&hw->cmd_desc_head[saved_producer]);
 	/* Code to update the adapter considering how many producer threads
 	   are currently working */
 	if ((--adapter->num_threads) == 0) {
 		/* This is the last thread */
 		u32 crb_producer = adapter->cmd_producer;
-		writel(crb_producer,
-		       NETXEN_CRB_NORMALIZE(adapter, CRB_CMD_PRODUCER_OFFSET));
+		netxen_nic_update_cmd_producer(adapter, crb_producer);
 		wmb();
 		adapter->total_threads = 0;
 	}
 
-	port->stats.xmitfinished++;
+	adapter->stats.xmitfinished++;
 	spin_unlock_bh(&adapter->tx_lock);
 
 	netdev->trans_start = jiffies;
@@ -959,25 +982,25 @@ static void netxen_watchdog(unsigned lon
 
 static void netxen_tx_timeout(struct net_device *netdev)
 {
-	struct netxen_port *port = (struct netxen_port *)netdev_priv(netdev);
-
-	SCHEDULE_WORK(&port->tx_timeout_task);
+	struct netxen_adapter *adapter = (struct netxen_adapter *)
+						netdev_priv(netdev);
+	SCHEDULE_WORK(&adapter->tx_timeout_task);
 }
 
 static void netxen_tx_timeout_task(struct work_struct *work)
 {
-	struct netxen_port *port =
-		container_of(work, struct netxen_port, tx_timeout_task);
-	struct net_device *netdev = port->netdev;
+	struct netxen_adapter *adapter = 
+		container_of(work, struct netxen_adapter, tx_timeout_task);
+	struct net_device *netdev = adapter->netdev;
 	unsigned long flags;
 
 	printk(KERN_ERR "%s %s: transmit timeout, resetting.\n",
 	       netxen_nic_driver_name, netdev->name);
 
-	spin_lock_irqsave(&port->adapter->lock, flags);
+	spin_lock_irqsave(&adapter->lock, flags);
 	netxen_nic_close(netdev);
 	netxen_nic_open(netdev);
-	spin_unlock_irqrestore(&port->adapter->lock, flags);
+	spin_unlock_irqrestore(&adapter->lock, flags);
 	netdev->trans_start = jiffies;
 	netif_wake_queue(netdev);
 }
@@ -989,16 +1012,14 @@ netxen_handle_int(struct netxen_adapter 
 
 	DPRINTK(INFO, "Entered handle ISR\n");
 
-	adapter->stats.ints++;
-
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		int count = 0;
 		u32 mask;
-		mask = readl(pci_base_offset(adapter, ISR_INT_VECTOR));
-		if ((mask & 0x80) == 0) {
-			/* not our interrupt */
+		u32 our_int = 0;
+		our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+		/* not our interrupt */
+		if ((our_int & (0x80 << adapter->portnum)) == 0)
 			return ret;
-		}
 		netxen_nic_disable_int(adapter);
 		/* Window = 0 or 1 */
 		do {
@@ -1010,7 +1031,6 @@ netxen_handle_int(struct netxen_adapter 
 			printk("Could not disable interrupt completely\n");
 
 	}
-	adapter->stats.hostints++;
 
 	if (netxen_nic_rx_has_work(adapter) || netxen_nic_tx_has_work(adapter)) {
 		if (netif_rx_schedule_prep(netdev)) {
@@ -1044,33 +1064,24 @@ netxen_handle_int(struct netxen_adapter 
 irqreturn_t netxen_intr(int irq, void *data)
 {
 	struct netxen_adapter *adapter;
-	struct netxen_port *port;
 	struct net_device *netdev;
-	int i;
 
 	if (unlikely(!irq)) {
 		return IRQ_NONE;	/* Not our interrupt */
 	}
 
 	adapter = (struct netxen_adapter *)data;
-	for (i = 0; i < adapter->ahw.max_ports; i++) {
-		port = adapter->port[i];
-		netdev = port->netdev;
-
-		/* process our status queue (for all 4 ports) */
-		if (netif_running(netdev)) {
-			netxen_handle_int(adapter, netdev);
-			break;
-		}
-	}
+	netdev  = adapter->netdev;
+	/* process our status queue (for all 4 ports) */
+	if (netif_running(netdev))
+		netxen_handle_int(adapter, netdev);
 
 	return IRQ_HANDLED;
 }
 
 static int netxen_nic_poll(struct net_device *netdev, int *budget)
 {
-	struct netxen_port *port = (struct netxen_port *)netdev_priv(netdev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(netdev);
 	int work_to_do = min(*budget, netdev->quota);
 	int done = 1;
 	int ctx;
@@ -1078,7 +1089,6 @@ static int netxen_nic_poll(struct net_de
 	int work_done = 0;
 
 	DPRINTK(INFO, "polling for %d descriptors\n", *budget);
-	port->stats.polled++;
 
 	work_done = 0;
 	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
@@ -1122,8 +1132,7 @@ static int netxen_nic_poll(struct net_de
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void netxen_nic_poll_controller(struct net_device *netdev)
 {
-	struct netxen_port *port = netdev_priv(netdev);
-	struct netxen_adapter *adapter = port->adapter;
+	struct netxen_adapter *adapter = netdev_priv(netdev);
 	disable_irq(adapter->irq);
 	netxen_intr(adapter->irq, adapter);
 	enable_irq(adapter->irq);
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index d5d9507..f6befc3 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -610,13 +610,12 @@ int netxen_niu_macaddr_get(struct netxen
  * Set the station MAC address.
  * Note that the passed-in value must already be in network byte order.
  */
-int netxen_niu_macaddr_set(struct netxen_port *port,
+int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
 			   netxen_ethernet_macaddr_t addr)
 {
 	u8 temp[4];
 	u32 val;
-	struct netxen_adapter *adapter = port->adapter;
-	int phy = port->portnum;
+	int phy = adapter->portnum;
 	unsigned char mac_addr[6];
 	int i;
 
@@ -642,7 +641,7 @@ int netxen_niu_macaddr_set(struct netxen
 
 	if (i == 10) {
 		printk(KERN_ERR "%s: cannot set Mac addr for %s\n",
-		       netxen_nic_driver_name, port->netdev->name);
+		       netxen_nic_driver_name, adapter->netdev->name);
 		printk(KERN_ERR "MAC address set: "
 		       "%02x:%02x:%02x:%02x:%02x:%02x.\n",
 		       addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
@@ -735,12 +734,10 @@ int netxen_niu_enable_gbe_port(struct ne
 }
 
 /* Disable a GbE interface */
-int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter, int port)
+int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
 {
 	__u32 mac_cfg0;
-
-	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
-		return -EINVAL;
+	int port = adapter->portnum;
 
 	mac_cfg0 = 0;
 	netxen_gb_soft_reset(mac_cfg0);
@@ -751,13 +748,10 @@ int netxen_niu_disable_gbe_port(struct n
 }
 
 /* Disable an XG interface */
-int netxen_niu_disable_xg_port(struct netxen_adapter *adapter, int port)
+int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 {
 	__u32 mac_cfg;
 
-	if (port != 0)
-		return -EINVAL;
-
 	mac_cfg = 0;
 	netxen_xg_soft_reset(mac_cfg);
 	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_CONFIG_0,
@@ -767,10 +761,11 @@ int netxen_niu_disable_xg_port(struct ne
 }
 
 /* Set promiscuous mode for a GbE interface */
-int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, int port,
+int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, 
 				    netxen_niu_prom_mode_t mode)
 {
 	__u32 reg;
+	int port = adapter->portnum;
 
 	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 		return -EINVAL;
@@ -824,12 +819,11 @@ int netxen_niu_set_promiscuous_mode(stru
  * Set the MAC address for an XG port
  * Note that the passed-in value must already be in network byte order.
  */
-int netxen_niu_xg_macaddr_set(struct netxen_port *port,
+int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 			      netxen_ethernet_macaddr_t addr)
 {
 	u8 temp[4];
 	u32 val;
-	struct netxen_adapter *adapter = port->adapter;
 
 	temp[0] = temp[1] = 0;
 	memcpy(temp + 2, addr, 2);
@@ -878,9 +872,10 @@ int netxen_niu_xg_macaddr_get(struct net
 }
 
 int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
-				       int port, netxen_niu_prom_mode_t mode)
+				       netxen_niu_prom_mode_t mode)
 {
 	__u32 reg;
+	int port = adapter->portnum;
 
 	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 		return -EINVAL;
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 0c7c943..f7eb627 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -100,6 +100,14 @@ #define CRB_JUMBO_BUFFER_CONS       NETX
 
 #define CRB_CMD_PRODUCER_OFFSET_1   NETXEN_NIC_REG(0x1ac)
 #define CRB_CMD_CONSUMER_OFFSET_1   NETXEN_NIC_REG(0x1b0)
+#define CRB_CMD_PRODUCER_OFFSET_1   NETXEN_NIC_REG(0x1ac)
+#define CRB_CMD_CONSUMER_OFFSET_1   NETXEN_NIC_REG(0x1b0)
+#define CRB_CMD_PRODUCER_OFFSET_2   NETXEN_NIC_REG(0x1b8)
+#define CRB_CMD_CONSUMER_OFFSET_2   NETXEN_NIC_REG(0x1bc)
+
+// 1c0 to 1cc used for signature reg
+#define CRB_CMD_PRODUCER_OFFSET_3   NETXEN_NIC_REG(0x1d0)
+#define CRB_CMD_CONSUMER_OFFSET_3   NETXEN_NIC_REG(0x1d4)
 #define CRB_TEMP_STATE              NETXEN_NIC_REG(0x1b4)
 
 /* used for ethtool tests */
@@ -139,128 +147,13 @@ struct netxen_recv_crb {
 };
 
 #if defined(DEFINE_GLOBAL_RECV_CRB)
-struct netxen_recv_crb recv_crb_registers[] = {
-	/*
-	 * Instance 0.
-	 */
-	{
-	 /* rcv_desc_crb: */
-	 {
-	  {
-	   /* crb_rcv_producer_offset: */
-	   NETXEN_NIC_REG(0x100),
-	   /* crb_rcv_consumer_offset: */
-	   NETXEN_NIC_REG(0x104),
-	   /* crb_gloablrcv_ring: */
-	   NETXEN_NIC_REG(0x108),
-	   /* crb_rcv_ring_size */
-	   NETXEN_NIC_REG(0x10c),
-
-	   },
-	  /* Jumbo frames */
-	  {
-	   /* crb_rcv_producer_offset: */
-	   NETXEN_NIC_REG(0x110),
-	   /* crb_rcv_consumer_offset: */
-	   NETXEN_NIC_REG(0x114),
-	   /* crb_gloablrcv_ring: */
-	   NETXEN_NIC_REG(0x118),
-	   /* crb_rcv_ring_size */
-	   NETXEN_NIC_REG(0x11c),
-	   },
-	  /* LRO */
-	  {
-	   /* crb_rcv_producer_offset: */
-	   NETXEN_NIC_REG(0x120),
-	   /* crb_rcv_consumer_offset: */
-	   NETXEN_NIC_REG(0x124),
-	   /* crb_gloablrcv_ring: */
-	   NETXEN_NIC_REG(0x128),
-	   /* crb_rcv_ring_size */
-	   NETXEN_NIC_REG(0x12c),
-	   }
-	  },
-	 /* crb_rcvstatus_ring: */
-	 NETXEN_NIC_REG(0x130),
-	 /* crb_rcv_status_producer: */
-	 NETXEN_NIC_REG(0x134),
-	 /* crb_rcv_status_consumer: */
-	 NETXEN_NIC_REG(0x138),
-	 /* crb_rcvpeg_state: */
-	 NETXEN_NIC_REG(0x13c),
-	 /* crb_status_ring_size */
-	 NETXEN_NIC_REG(0x140),
-
-	 },
-	/*
-	 * Instance 1,
-	 */
-	{
-	 /* rcv_desc_crb: */
-	 {
-	  {
-	   /* crb_rcv_producer_offset: */
-	   NETXEN_NIC_REG(0x144),
-	   /* crb_rcv_consumer_offset: */
-	   NETXEN_NIC_REG(0x148),
-	   /* crb_globalrcv_ring: */
-	   NETXEN_NIC_REG(0x14c),
-	   /* crb_rcv_ring_size */
-	   NETXEN_NIC_REG(0x150),
-
-	   },
-	  /* Jumbo frames */
-	  {
-	   /* crb_rcv_producer_offset: */
-	   NETXEN_NIC_REG(0x154),
-	   /* crb_rcv_consumer_offset: */
-	   NETXEN_NIC_REG(0x158),
-	   /* crb_globalrcv_ring: */
-	   NETXEN_NIC_REG(0x15c),
-	   /* crb_rcv_ring_size */
-	   NETXEN_NIC_REG(0x160),
-	   },
-	  /* LRO */
-	  {
-	   /* crb_rcv_producer_offset: */
-	   NETXEN_NIC_REG(0x164),
-	   /* crb_rcv_consumer_offset: */
-	   NETXEN_NIC_REG(0x168),
-	   /* crb_globalrcv_ring: */
-	   NETXEN_NIC_REG(0x16c),
-	   /* crb_rcv_ring_size */
-	   NETXEN_NIC_REG(0x170),
-	   }
-
-	  },
-	 /* crb_rcvstatus_ring: */
-	 NETXEN_NIC_REG(0x174),
-	 /* crb_rcv_status_producer: */
-	 NETXEN_NIC_REG(0x178),
-	 /* crb_rcv_status_consumer: */
-	 NETXEN_NIC_REG(0x17c),
-	 /* crb_rcvpeg_state: */
-	 NETXEN_NIC_REG(0x180),
-	 /* crb_status_ring_size */
-	 NETXEN_NIC_REG(0x184),
-
-	 },
-};
-
-u64 ctx_addr_sig_regs[][3] = {
-	{NETXEN_NIC_REG(0x188), NETXEN_NIC_REG(0x18c), NETXEN_NIC_REG(0x1c0)},
-	{NETXEN_NIC_REG(0x190), NETXEN_NIC_REG(0x194), NETXEN_NIC_REG(0x1c4)},
-	{NETXEN_NIC_REG(0x198), NETXEN_NIC_REG(0x19c), NETXEN_NIC_REG(0x1c8)},
-	{NETXEN_NIC_REG(0x1a0), NETXEN_NIC_REG(0x1a4), NETXEN_NIC_REG(0x1cc)}
-};
-
 #else
 extern struct netxen_recv_crb recv_crb_registers[];
 extern u64 ctx_addr_sig_regs[][3];
+#endif				/* DEFINE_GLOBAL_RECEIVE_CRB */
 #define CRB_CTX_ADDR_REG_LO            (ctx_addr_sig_regs[0][0])
 #define CRB_CTX_ADDR_REG_HI            (ctx_addr_sig_regs[0][2])
 #define CRB_CTX_SIGNATURE_REG       (ctx_addr_sig_regs[0][1])
-#endif				/* DEFINE_GLOBAL_RECEIVE_CRB */
 
 /*
  * Temperature control.
