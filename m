From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 2/7] NetXen: removal of redundant argument passing
Date: Fri, 13 Apr 2007 08:38:30 -0700
Message-ID: <200704131538.l3DFcUJ7002546@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:10469 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754052AbXDMPib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 11:38:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Removal of redundant function call parameters and bug fixes.
This patch will remove the redundant paramters which were being passed to
many functions since now adapter->portnum can be used.

Signed-off-by: Mithlesh Thukral <mithlesh@netxen.com>

---

 drivers/net/netxen/netxen_nic.h         |   33 +++----
 drivers/net/netxen/netxen_nic_ethtool.c |   10 +-
 drivers/net/netxen/netxen_nic_hdr.h     |    1 
 drivers/net/netxen/netxen_nic_hw.c      |   23 +++--
 drivers/net/netxen/netxen_nic_hw.h      |    4 
 drivers/net/netxen/netxen_nic_init.c    |    7 -
 drivers/net/netxen/netxen_nic_isr.c     |    9 +-
 drivers/net/netxen/netxen_nic_main.c    |   32 +++++--
 drivers/net/netxen/netxen_nic_niu.c     |   96 +++++++++-------------
 9 files changed, 114 insertions(+), 101 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 7a5a95e..c85c2cb 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -205,6 +205,7 @@ #define RCV_DESC_TYPE(ID) \
 
 #define MAX_CMD_DESCRIPTORS		1024
 #define MAX_RCV_DESCRIPTORS		16384
+#define MAX_RCV_DESCRIPTORS_1G		(MAX_RCV_DESCRIPTORS / 4)
 #define MAX_JUMBO_RCV_DESCRIPTORS	1024
 #define MAX_LRO_RCV_DESCRIPTORS		64
 #define MAX_RCVSTATUS_DESCRIPTORS	MAX_RCV_DESCRIPTORS
@@ -781,6 +782,7 @@ struct netxen_hardware_context {
 	struct pci_dev *cmd_desc_pdev;
 	dma_addr_t cmd_desc_phys_addr;
 	struct netxen_adapter *adapter;
+	int pci_func;
 };
 
 #define RCV_RING_LRO	RCV_DESC_LRO
@@ -917,15 +919,15 @@ struct netxen_adapter {
 	struct netxen_ring_ctx *ctx_desc;
 	struct pci_dev *ctx_desc_pdev;
 	dma_addr_t ctx_desc_phys_addr;
-	int (*enable_phy_interrupts) (struct netxen_adapter *, int);
-	int (*disable_phy_interrupts) (struct netxen_adapter *, int);
+	int (*enable_phy_interrupts) (struct netxen_adapter *);
+	int (*disable_phy_interrupts) (struct netxen_adapter *);
 	void (*handle_phy_intr) (struct netxen_adapter *);
 	int (*macaddr_set) (struct netxen_adapter *, netxen_ethernet_macaddr_t);
 	int (*set_mtu) (struct netxen_adapter *, int);
 	int (*set_promisc) (struct netxen_adapter *, netxen_niu_prom_mode_t);
 	int (*unset_promisc) (struct netxen_adapter *, netxen_niu_prom_mode_t);
-	int (*phy_read) (struct netxen_adapter *, long phy, long reg, u32 *);
-	int (*phy_write) (struct netxen_adapter *, long phy, long reg, u32 val);
+	int (*phy_read) (struct netxen_adapter *, long reg, u32 *);
+	int (*phy_write) (struct netxen_adapter *, long reg, u32 val);
 	int (*init_port) (struct netxen_adapter *, int);
 	void (*init_niu) (struct netxen_adapter *);
 	int (*stop_port) (struct netxen_adapter *);
@@ -971,27 +973,21 @@ static inline void __iomem *pci_base(str
 	return NULL;
 }
 
-int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter,
-					  int port);
-int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter,
-					 int port);
-int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter,
-					   int port);
-int netxen_niu_gbe_disable_phy_interrupts(struct netxen_adapter *adapter,
-					  int port);
-int netxen_niu_xgbe_clear_phy_interrupts(struct netxen_adapter *adapter,
-					 int port);
-int netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter,
-					int port);
+int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter);
+int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter);
+int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter);
+int netxen_niu_gbe_disable_phy_interrupts(struct netxen_adapter *adapter);
+int netxen_niu_xgbe_clear_phy_interrupts(struct netxen_adapter *adapter);
+int netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter);
 void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter);
 void netxen_nic_gbe_handle_phy_intr(struct netxen_adapter *adapter);
 void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter, int port,
 				 long enable);
 void netxen_niu_gbe_set_gmii_mode(struct netxen_adapter *adapter, int port,
 				  long enable);
-int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long phy, long reg,
+int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 			    __u32 * readval);
-int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long phy,
+int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
 			     long reg, __u32 val);
 
 /* Functions available from netxen_nic_hw.c */
@@ -1011,6 +1007,7 @@ int netxen_nic_hw_write_wx(struct netxen
 			   int len);
 void netxen_crb_writelit_adapter(struct netxen_adapter *adapter,
 				 unsigned long off, int data);
+int netxen_nic_erase_pxe(struct netxen_adapter *adapter);
 
 /* Functions from netxen_nic_init.c */
 void netxen_free_adapter_offload(struct netxen_adapter *adapter);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 7f9aaae..d49a7d8 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -211,7 +211,7 @@ netxen_nic_set_settings(struct net_devic
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		/* autonegotiation */
 		if (adapter->phy_write
-		    && adapter->phy_write(adapter, adapter->portnum,
+		    && adapter->phy_write(adapter,
 					  NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
 					  ecmd->autoneg) != 0)
 			return -EIO;
@@ -219,7 +219,7 @@ netxen_nic_set_settings(struct net_devic
 			adapter->link_autoneg = ecmd->autoneg;
 
 		if (adapter->phy_read
-		    && adapter->phy_read(adapter, adapter->portnum,
+		    && adapter->phy_read(adapter,
 					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					 &status) != 0)
 			return -EIO;
@@ -242,7 +242,7 @@ netxen_nic_set_settings(struct net_devic
 		if (ecmd->duplex == DUPLEX_FULL)
 			netxen_set_phy_duplex(status);
 		if (adapter->phy_write
-		    && adapter->phy_write(adapter, adapter->portnum,
+		    && adapter->phy_write(adapter,
 					  NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					  *((int *)&status)) != 0)
 			return -EIO;
@@ -398,7 +398,7 @@ static u32 netxen_nic_test_link(struct n
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		if (adapter->phy_read
-		    && adapter->phy_read(adapter, adapter->portnum,
+		    && adapter->phy_read(adapter,
 					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					 &status) != 0)
 			return -EIO;
@@ -577,7 +577,7 @@ netxen_nic_set_pauseparam(struct net_dev
 		/* set autoneg */
 		autoneg = pause->autoneg;
 		if (adapter->phy_write
-		    && adapter->phy_write(adapter, adapter->portnum,
+		    && adapter->phy_write(adapter,
 					  NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
 					  autoneg) != 0)
 			return -EIO;
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index b67a5c3..b826bca 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -484,6 +484,7 @@ #define	NETXEN_NIU_PHY_WAITLEN		200000
 	/* 10 seconds before we give up */
 #define	NETXEN_NIU_PHY_WAITMAX		50
 #define	NETXEN_NIU_MAX_GBE_PORTS	4
+#define	NETXEN_NIU_MAX_XG_PORTS		2
 
 #define	NETXEN_NIU_MODE			(NETXEN_CRB_NIU + 0x00000)
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index bc23db0..a066208 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -586,7 +586,7 @@ void netxen_nic_pci_change_crbwindow(str
 
 	if (adapter->curr_window == wndw)
 		return;
-	switch(adapter->portnum) {
+	switch(adapter->ahw.pci_func) {
 		case 0:
 			offset = PCI_OFFSET_SECOND_RANGE(adapter,
 					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW));
@@ -605,7 +605,7 @@ void netxen_nic_pci_change_crbwindow(str
 			break;
 		default:
 			printk(KERN_INFO "Changing the window for PCI function"
-					"%d\n",	adapter->portnum);
+					"%d\n",	adapter->ahw.pci_func);
 			offset = PCI_OFFSET_SECOND_RANGE(adapter,
 					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW));
 			break;
@@ -880,6 +880,17 @@ netxen_nic_pci_set_window(struct netxen_
 	return addr;
 }
 
+int
+netxen_nic_erase_pxe(struct netxen_adapter *adapter)
+{
+	if (netxen_rom_fast_write(adapter, PXE_START, 0) == -1) {
+		printk(KERN_ERR "%s: erase pxe failed\n", 
+			netxen_nic_driver_name);
+		return -1;
+	}
+	return 0;
+}
+
 int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 {
 	int rv = 0;
@@ -952,9 +963,9 @@ int netxen_nic_set_mtu_gb(struct netxen_
 int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
 {
 	new_mtu += NETXEN_NIU_HDRSIZE + NETXEN_NIU_TLRSIZE;
-	if (port->portnum == 0)
+	if (adapter->portnum == 0)
 	    netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE, new_mtu);
-	else if (port->portnum == 1)
+	else if (adapter->portnum == 1)
 	    netxen_nic_write_w0(adapter, NETXEN_NIU_XG1_MAX_FRAME_SIZE, new_mtu);
 	return 0;
 }
@@ -990,7 +1001,7 @@ void netxen_nic_set_link_parameters(stru
 	if (netxen_get_niu_enable_ge(mode)) {	/* Gb 10/100/1000 Mbps mode */
 		if (adapter->phy_read
 		    && adapter->
-		    phy_read(adapter, adapter->portnum,
+		    phy_read(adapter,
 			     NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 			     &status) == 0) {
 			if (netxen_get_phy_link(status)) {
@@ -1021,7 +1032,7 @@ void netxen_nic_set_link_parameters(stru
 				}
 				if (adapter->phy_read
 				    && adapter->
-				    phy_read(adapter, adapter->portnum,
+				    phy_read(adapter,
 					     NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
 					     &autoneg) != 0)
 					adapter->link_autoneg = autoneg;
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 841341d..94459cf 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -458,13 +458,13 @@ int netxen_niu_xg_set_promiscuous_mode(s
 				       netxen_niu_prom_mode_t mode);
 
 /* get/set the MAC address for a given MAC */
-int netxen_niu_macaddr_get(struct netxen_adapter *adapter, int port,
+int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
 			   netxen_ethernet_macaddr_t * addr);
 int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
 			   netxen_ethernet_macaddr_t addr);
 
 /* XG versons */
-int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter, int port,
+int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter,
 			      netxen_ethernet_macaddr_t * addr);
 int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 			      netxen_ethernet_macaddr_t addr);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 8866a8c..3987464 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -277,8 +277,8 @@ u32 netxen_decode_crb_addr(u32 addr)
 		return (pci_base + offset);
 }
 
-static long rom_max_timeout = 10000;
-static long rom_lock_timeout = 1000000;
+static long rom_max_timeout = 100;
+static long rom_lock_timeout = 10000;
 static long rom_write_timeout = 700;
 
 static inline int rom_lock(struct netxen_adapter *adapter)
@@ -953,7 +953,8 @@ void netxen_phantom_init(struct netxen_a
 
 	if (!pegtune_val) {
 		val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-		while (val != PHAN_INITIALIZE_COMPLETE && loops < 200000) {
+		while (val != PHAN_INITIALIZE_COMPLETE && 
+			val != PHAN_INITIALIZE_ACK && loops < 200000) {
 			udelay(100);
 			schedule();
 			val =
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index f60c969..8510216 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -82,7 +82,7 @@ void netxen_handle_port_int(struct netxe
 
 	/*  This should clear the interrupt source */
 	if (adapter->phy_read)
-		adapter->phy_read(adapter, adapter->portnum,
+		adapter->phy_read(adapter, 
 				  NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
 				  &int_src);
 	if (int_src == 0) {
@@ -90,7 +90,7 @@ void netxen_handle_port_int(struct netxe
 		return;
 	}
 	if (adapter->disable_phy_interrupts)
-		adapter->disable_phy_interrupts(adapter, adapter->portnum);
+		adapter->disable_phy_interrupts(adapter);
 
 	if (netxen_get_phy_int_jabber(int_src))
 		DPRINTK(INFO, "Jabber interrupt \n");
@@ -111,7 +111,7 @@ void netxen_handle_port_int(struct netxe
 		DPRINTK(INFO, "SPEED CHANGED OR LINK STATUS CHANGED \n");
 
 		if (adapter->phy_read
-		    && adapter->phy_read(adapter, adapter->portnum,
+		    && adapter->phy_read(adapter, 
 					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					 &status) == 0) {
 			if (netxen_get_phy_int_link_status_changed(int_src)) {
@@ -135,7 +135,7 @@ void netxen_handle_port_int(struct netxe
 		}
 	}
 	if (adapter->enable_phy_interrupts)
-		adapter->enable_phy_interrupts(adapter, adapter->portnum);
+		adapter->enable_phy_interrupts(adapter);
 }
 
 void netxen_nic_isr_other(struct netxen_adapter *adapter)
@@ -179,6 +179,7 @@ void netxen_nic_xgbe_handle_phy_intr(str
 
 	/* WINDOW = 1 */
 	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
+	val >>= (adapter->portnum * 8);
 	val1 = val & 0xff;
 
 	if (adapter->ahw.xg_linkup == 1 && val1 != XG_LINK_UP) {
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2cfdb10..07faea9 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -232,6 +232,8 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	memset(adapter, 0 , sizeof(struct netxen_adapter));
 
 	adapter->ahw.pdev = pdev;
+	adapter->ahw.pci_func  = pci_func_id;
+
 	/* remap phys address */
 	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
 	mem_len = pci_resource_len(pdev, 0);
@@ -274,7 +276,12 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	DPRINTK(INFO, "doorbell ioremaped at %p\n", db_ptr);
 
 	adapter->max_tx_desc_count = MAX_CMD_DESCRIPTORS;
-	adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS;
+	if ((adapter->ahw.boardcfg.board_type == NETXEN_BRDTYPE_P2_SB35_4G) ||
+			(adapter->ahw.boardcfg.board_type == 
+			 NETXEN_BRDTYPE_P2_SB31_2G)) 
+		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
+	else
+		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS;
 	adapter->max_jumbo_rx_desc_count = MAX_JUMBO_RCV_DESCRIPTORS;
 	adapter->max_lro_rx_desc_count = MAX_LRO_RCV_DESCRIPTORS;
 
@@ -381,8 +388,13 @@ #endif
 	spin_lock_init(&adapter->tx_lock);
 	spin_lock_init(&adapter->lock);
 	netxen_initialize_adapter_sw(adapter);	/* initialize the buffers in adapter */
+	/* Mezz cards have PCI function 0,2,3 enabled */
+	if (adapter->ahw.boardcfg.board_type == NETXEN_BRDTYPE_P2_SB31_10G_IMEZ)
+		if (pci_func_id >= 2)
+			adapter->portnum = pci_func_id - 2;
+
 #ifdef CONFIG_IA64
-	if(netxen_probe_flag == 0) {
+	if(adapter->portnum == 0) {
 		netxen_pinit_from_rom(adapter, 0);
 		udelay(500);
 		netxen_load_firmware(adapter);
@@ -398,11 +410,9 @@ #endif
 	 *  Adapter in our case is quad port so initialize it before
 	 *  initializing the ports
 	 */
-	netxen_initialize_adapter_hw(adapter);	/* initialize the adapter */
 
-	if (adapter->ahw.boardcfg.board_type == NETXEN_BRDTYPE_P2_SB31_10G_IMEZ)
-		if (pci_func_id >= 2)
-			adapter->portnum = pci_func_id - 2;
+	/* initialize the adapter */
+	netxen_initialize_adapter_hw(adapter);
 
 	netxen_initialize_adapter_ops(adapter);
 
@@ -425,7 +435,7 @@ #endif
 		valid_mac = 0;
 
 	if (valid_mac) {
-		unsigned char *p = (unsigned char *)&mac_addr[i];
+		unsigned char *p = (unsigned char *)&mac_addr[adapter->portnum];
 		netdev->dev_addr[0] = *(p + 5);
 		netdev->dev_addr[1] = *(p + 4);
 		netdev->dev_addr[2] = *(p + 3);
@@ -460,7 +470,8 @@ #endif
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_LO));
 
 	/* do this before waking up pegs so that we have valid dummy dma addr */
-	err = netxen_initialize_adapter_offload(adapter);
+	if (adapter->portnum == 0)
+		err = netxen_initialize_adapter_offload(adapter);
 	if (err) 
 		goto err_out_free_dev;
 
@@ -486,6 +497,7 @@ #endif
 	 */
 	udelay(100);
 	INIT_WORK(&adapter->tx_timeout_task, netxen_tx_timeout_task);
+	netxen_nic_erase_pxe(adapter);
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
@@ -565,8 +577,8 @@ static void __devexit netxen_nic_remove(
 	int i;
 	int ctxid, ring;
 
-	netdev = pci_get_drvdata(pdev);
-	adapter = netdev_priv(netdev);
+	adapter = pci_get_drvdata(pdev);
+	netdev = adapter->netdev;
 	if (adapter == NULL)
 		return;
 
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index f6befc3..ad2486f 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -88,12 +88,13 @@ static inline int phy_unlock(struct netx
  *	  -1 on error
  *
  */
-int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long phy,
-			    long reg, __u32 * readval)
+int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg, 
+				__u32 * readval)
 {
 	long timeout = 0;
 	long result = 0;
 	long restore = 0;
+	long phy = adapter->portnum;
 	__u32 address;
 	__u32 command;
 	__u32 status;
@@ -183,12 +184,13 @@ int netxen_niu_gbe_phy_read(struct netxe
  *	  -1 on error
  *
  */
-int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
-			     long phy, long reg, __u32 val)
+int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg, 
+				__u32 val)
 {
 	long timeout = 0;
 	long result = 0;
 	long restore = 0;
+	long phy = adapter->portnum;
 	__u32 address;
 	__u32 command;
 	__u32 status;
@@ -258,15 +260,13 @@ int netxen_niu_gbe_phy_write(struct netx
 	return result;
 }
 
-int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter,
-					  int port)
+int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter)
 {
 	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_INT_MASK, 0x3f);
 	return 0;
 }
 
-int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter,
-					 int port)
+int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter)
 {
 	int result = 0;
 	__u32 enable = 0;
@@ -275,7 +275,7 @@ int netxen_niu_gbe_enable_phy_interrupts
 	netxen_set_phy_int_speed_changed(enable);
 
 	if (0 !=
-	    netxen_niu_gbe_phy_write(adapter, port,
+	    netxen_niu_gbe_phy_write(adapter, 
 				     NETXEN_NIU_GB_MII_MGMT_ADDR_INT_ENABLE,
 				     enable))
 		result = -EIO;
@@ -283,38 +283,34 @@ int netxen_niu_gbe_enable_phy_interrupts
 	return result;
 }
 
-int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter,
-					   int port)
+int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter)
 {
 	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_INT_MASK, 0x7f);
 	return 0;
 }
 
-int netxen_niu_gbe_disable_phy_interrupts(struct netxen_adapter *adapter,
-					  int port)
+int netxen_niu_gbe_disable_phy_interrupts(struct netxen_adapter *adapter)
 {
 	int result = 0;
 	if (0 !=
-	    netxen_niu_gbe_phy_write(adapter, port,
+	    netxen_niu_gbe_phy_write(adapter,
 				     NETXEN_NIU_GB_MII_MGMT_ADDR_INT_ENABLE, 0))
 		result = -EIO;
 
 	return result;
 }
 
-int netxen_niu_xgbe_clear_phy_interrupts(struct netxen_adapter *adapter,
-					 int port)
+int netxen_niu_xgbe_clear_phy_interrupts(struct netxen_adapter *adapter)
 {
 	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_ACTIVE_INT, -1);
 	return 0;
 }
 
-int netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter,
-					int port)
+int netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter)
 {
 	int result = 0;
 	if (0 !=
-	    netxen_niu_gbe_phy_write(adapter, port,
+	    netxen_niu_gbe_phy_write(adapter, 
 				     NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
 				     -EIO))
 		result = -EIO;
@@ -355,9 +351,9 @@ void netxen_niu_gbe_set_mii_mode(struct 
 					    0x5);
 	}
 
-	if (netxen_niu_gbe_enable_phy_interrupts(adapter, port))
+	if (netxen_niu_gbe_enable_phy_interrupts(adapter))
 		printk(KERN_ERR PFX "ERROR enabling PHY interrupts\n");
-	if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
+	if (netxen_niu_gbe_clear_phy_interrupts(adapter))
 		printk(KERN_ERR PFX "ERROR clearing PHY interrupts\n");
 }
 
@@ -393,9 +389,9 @@ void netxen_niu_gbe_set_gmii_mode(struct
 					    0x5);
 	}
 
-	if (netxen_niu_gbe_enable_phy_interrupts(adapter, port))
+	if (netxen_niu_gbe_enable_phy_interrupts(adapter))
 		printk(KERN_ERR PFX "ERROR enabling PHY interrupts\n");
-	if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
+	if (netxen_niu_gbe_clear_phy_interrupts(adapter))
 		printk(KERN_ERR PFX "ERROR clearing PHY interrupts\n");
 }
 
@@ -404,11 +400,11 @@ int netxen_niu_gbe_init_port(struct netx
 	int result = 0;
 	__u32 status;
 	if (adapter->disable_phy_interrupts)
-		adapter->disable_phy_interrupts(adapter, port);
+		adapter->disable_phy_interrupts(adapter);
 	mdelay(2);
 
 	if (0 ==
-	    netxen_niu_gbe_phy_read(adapter, port,
+	    netxen_niu_gbe_phy_read(adapter,
 				    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 				    &status)) {
 		if (netxen_get_phy_link(status)) {
@@ -439,13 +435,13 @@ int netxen_niu_gbe_init_port(struct netx
 						    | NETXEN_GB_MAC_ENABLE_TX_RX
 						    |
 						    NETXEN_GB_MAC_PAUSED_FRMS);
-			if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
+			if (netxen_niu_gbe_clear_phy_interrupts(adapter))
 				printk(KERN_ERR PFX
 				       "ERROR clearing PHY interrupts\n");
-			if (netxen_niu_gbe_enable_phy_interrupts(adapter, port))
+			if (netxen_niu_gbe_enable_phy_interrupts(adapter))
 				printk(KERN_ERR PFX
 				       "ERROR enabling PHY interrupts\n");
-			if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
+			if (netxen_niu_gbe_clear_phy_interrupts(adapter))
 				printk(KERN_ERR PFX
 				       "ERROR clearing PHY interrupts\n");
 			result = -1;
@@ -458,24 +454,14 @@ int netxen_niu_gbe_init_port(struct netx
 
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 {
-	u32 reg = 0, ret = 0;
-
-	if (adapter->ahw.boardcfg.board_type == NETXEN_BRDTYPE_P2_SB31_10G_IMEZ) {
-		netxen_crb_writelit_adapter(adapter,
-					    NETXEN_NIU_XG1_CONFIG_0, 0x5);
-		/* XXX hack for Mez cards: both ports in promisc mode */
-		netxen_nic_hw_read_wx(adapter,
-				      NETXEN_NIU_XGE_CONFIG_1, &reg, 4);
-		reg = (reg | 0x2000UL);
-		netxen_crb_writelit_adapter(adapter,
-					    NETXEN_NIU_XGE_CONFIG_1, reg);
-		reg = 0;
-		netxen_nic_hw_read_wx(adapter,
-				      NETXEN_NIU_XG1_CONFIG_1, &reg, 4);
-		reg = (reg | 0x2000UL);
+	u32 ret = 0;
+	int portnum = adapter->portnum;
+		netxen_crb_writelit_adapter(adapter, 
+				NETXEN_NIU_XGE_CONFIG_1 +(0x10000 * portnum),
+				0x1447);
 		netxen_crb_writelit_adapter(adapter,
-					    NETXEN_NIU_XG1_CONFIG_1, reg);
-	}
+			    NETXEN_NIU_XG1_CONFIG_1 + 
+			    (0x10000 * portnum), 0x5);
 
 	return ret;
 }
@@ -498,7 +484,7 @@ int netxen_niu_gbe_handle_phy_interrupt(
 	 * The read of the PHY INT status will clear the pending
 	 * interrupt status
 	 */
-	if (netxen_niu_gbe_phy_read(adapter, port,
+	if (netxen_niu_gbe_phy_read(adapter,
 				    NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
 				    &int_src) != 0)
 		result = -EINVAL;
@@ -535,7 +521,7 @@ int netxen_niu_gbe_handle_phy_interrupt(
 			printk(KERN_INFO PFX
 			       "speed_changed or link status changed");
 			if (netxen_niu_gbe_phy_read
-			    (adapter, port,
+			    (adapter,
 			     NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 			     &status) == 0) {
 				if (netxen_get_phy_speed(status) == 2) {
@@ -581,10 +567,11 @@ int netxen_niu_gbe_handle_phy_interrupt(
  * Note that the passed-in value must already be in network byte order.
  */
 int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
-			   int phy, netxen_ethernet_macaddr_t * addr)
+			   netxen_ethernet_macaddr_t * addr)
 {
 	u32 stationhigh;
 	u32 stationlow;
+	int phy = adapter->portnum;
 	u8 val[8];
 
 	if (addr == NULL)
@@ -633,7 +620,7 @@ int netxen_niu_macaddr_set(struct netxen
 		    (adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy), &val, 4))
 			return -2;
 
-		netxen_niu_macaddr_get(adapter, phy,
+		netxen_niu_macaddr_get(adapter, 
 				       (netxen_ethernet_macaddr_t *) mac_addr);
 		if (memcmp(mac_addr, addr, 6) == 0)
 			break;
@@ -845,9 +832,10 @@ int netxen_niu_xg_macaddr_set(struct net
  * Return the current station MAC address.
  * Note that the passed-in value must already be in network byte order.
  */
-int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter, int phy,
+int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter,
 			      netxen_ethernet_macaddr_t * addr)
 {
+	int phy = adapter->portnum;
 	u32 stationhigh;
 	u32 stationlow;
 	u8 val[8];
@@ -877,17 +865,19 @@ int netxen_niu_xg_set_promiscuous_mode(s
 	__u32 reg;
 	int port = adapter->portnum;
 
-	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
+	if ((port < 0) || (port > NETXEN_NIU_MAX_XG_PORTS))
 		return -EINVAL;
 
-	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_CONFIG_1, &reg, 4))
+	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_CONFIG_1 + 
+					(0x10000 * port), &reg, 4))
 		return -EIO;
 	if (mode == NETXEN_NIU_PROMISC_MODE)
 		reg = (reg | 0x2000UL);
 	else
 		reg = (reg & ~0x2000UL);
 
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_XGE_CONFIG_1, reg);
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_XGE_CONFIG_1 +
+					(0x10000 * port), reg);
 
 	return 0;
 }
