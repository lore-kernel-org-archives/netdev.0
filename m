From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 3/4] netxen: cleanup debug messages
Date: Sun, 15 Jun 2008 22:59:45 -0700
Message-ID: <1213595986-1929-4-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:32890 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752418AbYFPGit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 02:38:49 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Remove unnecessary debug prints and functions.
o Explicitly specify pci class (0x020000) to avoid enabling
  management function.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   16 -----
 drivers/net/netxen/netxen_nic_hw.c   |  104 ++++++++++++++-------------------
 drivers/net/netxen/netxen_nic_init.c |   22 +-------
 drivers/net/netxen/netxen_nic_main.c |   60 ++++++++-----------
 4 files changed, 70 insertions(+), 132 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index ec2ed89..da4c4fb 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -776,7 +776,6 @@ struct netxen_hardware_context {
 
 	u8 revision_id;
 	u16 board_type;
-	u16 max_ports;
 	struct netxen_board_info boardcfg;
 	u32 xg_linkup;
 	u32 qg_linksup;
@@ -1035,7 +1034,6 @@ int netxen_rom_se(struct netxen_adapter *adapter, int addr);
 
 /* Functions from netxen_nic_isr.c */
 void netxen_initialize_adapter_sw(struct netxen_adapter *adapter);
-void netxen_initialize_adapter_hw(struct netxen_adapter *adapter);
 void *netxen_alloc(struct pci_dev *pdev, size_t sz, dma_addr_t * ptr,
 		   struct pci_dev **used_dev);
 void netxen_initialize_adapter_ops(struct netxen_adapter *adapter);
@@ -1078,20 +1076,6 @@ static const struct netxen_brdinfo netxen_boards[] = {
 
 #define NUM_SUPPORTED_BOARDS ARRAY_SIZE(netxen_boards)
 
-static inline void get_brd_port_by_type(u32 type, int *ports)
-{
-	int i, found = 0;
-	for (i = 0; i < NUM_SUPPORTED_BOARDS; ++i) {
-		if (netxen_boards[i].brdtype == type) {
-			*ports = netxen_boards[i].ports;
-			found = 1;
-			break;
-		}
-	}
-	if (!found)
-		*ports = 0;
-}
-
 static inline void get_brd_name_by_type(u32 type, char *name)
 {
 	int i, found = 0;
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 30316a8..c43d06b 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -396,11 +396,8 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 	}
 	adapter->intr_scheme = readl(
 		NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_FW));
-	printk(KERN_NOTICE "%s: FW capabilities:0x%x\n", netxen_nic_driver_name,
-			adapter->intr_scheme);
 	adapter->msi_mode = readl(
 		NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_MSI_MODE_FW));
-	DPRINTK(INFO, "Receive Peg ready too. starting stuff\n");
 
 	addr = netxen_alloc(adapter->ahw.pdev,
 			    sizeof(struct netxen_ring_ctx) +
@@ -408,8 +405,6 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 			    (dma_addr_t *) & adapter->ctx_desc_phys_addr,
 			    &adapter->ctx_desc_pdev);
 
-	printk(KERN_INFO "ctx_desc_phys_addr: 0x%llx\n",
-	       (unsigned long long) adapter->ctx_desc_phys_addr);
 	if (addr == NULL) {
 		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
 		err = -ENOMEM;
@@ -429,8 +424,6 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 			    adapter->max_tx_desc_count,
 			    (dma_addr_t *) & hw->cmd_desc_phys_addr,
 			    &adapter->ahw.cmd_desc_pdev);
-	printk(KERN_INFO "cmd_desc_phys_addr: 0x%llx\n",
-	       (unsigned long long) hw->cmd_desc_phys_addr);
 
 	if (addr == NULL) {
 		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
@@ -1127,7 +1120,6 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 
 void netxen_nic_flash_print(struct netxen_adapter *adapter)
 {
-	int valid = 1;
 	u32 fw_major = 0;
 	u32 fw_minor = 0;
 	u32 fw_build = 0;
@@ -1137,70 +1129,62 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 	__le32 *ptr32;
 
 	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
-	if (board_info->magic != NETXEN_BDINFO_MAGIC) {
-		printk
-		    ("NetXen Unknown board config, Read 0x%x expected as 0x%x\n",
-		     board_info->magic, NETXEN_BDINFO_MAGIC);
-		valid = 0;
-	}
-	if (board_info->header_version != NETXEN_BDINFO_VERSION) {
-		printk("NetXen Unknown board config version."
-		       " Read %x, expected %x\n",
-		       board_info->header_version, NETXEN_BDINFO_VERSION);
-		valid = 0;
-	}
-	if (valid) {
-		ptr32 = (u32 *)&serial_num;
-		addr = NETXEN_USER_START +
-		       offsetof(struct netxen_new_user_info, serial_num);
-		for (i = 0; i < 8; i++) {
-			if (netxen_rom_fast_read(adapter, addr, ptr32) == -1) {
-				printk("%s: ERROR reading %s board userarea.\n",
-				       netxen_nic_driver_name,
-				       netxen_nic_driver_name);
-				return;
-			}
-			ptr32++;
-			addr += sizeof(u32);
+
+	adapter->driver_mismatch = 0;
+
+	ptr32 = (u32 *)&serial_num;
+	addr = NETXEN_USER_START +
+	       offsetof(struct netxen_new_user_info, serial_num);
+	for (i = 0; i < 8; i++) {
+		if (netxen_rom_fast_read(adapter, addr, ptr32) == -1) {
+			printk("%s: ERROR reading %s board userarea.\n",
+			       netxen_nic_driver_name,
+			       netxen_nic_driver_name);
+			adapter->driver_mismatch = 1;
+			return;
 		}
+		ptr32++;
+		addr += sizeof(u32);
+	}
+
+	fw_major = readl(NETXEN_CRB_NORMALIZE(adapter,
+					      NETXEN_FW_VERSION_MAJOR));
+	fw_minor = readl(NETXEN_CRB_NORMALIZE(adapter,
+					      NETXEN_FW_VERSION_MINOR));
+	fw_build =
+	    readl(NETXEN_CRB_NORMALIZE(adapter, NETXEN_FW_VERSION_SUB));
 
+	if (adapter->portnum == 0) {
 		get_brd_name_by_type(board_info->board_type, brd_name);
 
 		printk("NetXen %s Board S/N %s  Chip id 0x%x\n",
-		       brd_name, serial_num, board_info->chip_id);
-
-		printk("NetXen %s Board #%d, Chip id 0x%x\n",
-		       board_info->board_type == 0x0b ? "XGB" : "GBE",
-		       board_info->board_num, board_info->chip_id);
-		fw_major = readl(NETXEN_CRB_NORMALIZE(adapter,
-						      NETXEN_FW_VERSION_MAJOR));
-		fw_minor = readl(NETXEN_CRB_NORMALIZE(adapter,
-						      NETXEN_FW_VERSION_MINOR));
-		fw_build =
-		    readl(NETXEN_CRB_NORMALIZE(adapter, NETXEN_FW_VERSION_SUB));
-
-		printk("NetXen Firmware version %d.%d.%d\n", fw_major, fw_minor,
-		       fw_build);
+				brd_name, serial_num, board_info->chip_id);
+		printk("NetXen Firmware version %d.%d.%d\n", fw_major,
+				fw_minor, fw_build);
 	}
+
 	if (fw_major != _NETXEN_NIC_LINUX_MAJOR) {
-		printk(KERN_ERR "The mismatch in driver version and firmware "
-		       "version major number\n"
-		       "Driver version major number = %d \t"
-		       "Firmware version major number = %d \n",
-		       _NETXEN_NIC_LINUX_MAJOR, fw_major);
 		adapter->driver_mismatch = 1;
 	}
 	if (fw_minor != _NETXEN_NIC_LINUX_MINOR &&
 			fw_minor != (_NETXEN_NIC_LINUX_MINOR + 1)) {
-		printk(KERN_ERR "The mismatch in driver version and firmware "
-		       "version minor number\n"
-		       "Driver version minor number = %d \t"
-		       "Firmware version minor number = %d \n",
-		       _NETXEN_NIC_LINUX_MINOR, fw_minor);
 		adapter->driver_mismatch = 1;
 	}
-	if (adapter->driver_mismatch)
-		printk(KERN_INFO "Use the driver with version no %d.%d.xxx\n",
-		       fw_major, fw_minor);
+	if (adapter->driver_mismatch) {
+		printk(KERN_ERR "%s: driver and firmware version mismatch\n",
+				adapter->netdev->name);
+		return;
+	}
+
+	switch (adapter->ahw.board_type) {
+	case NETXEN_NIC_GBE:
+		dev_info(&adapter->pdev->dev, "%s: GbE port initialized\n",
+				adapter->netdev->name);
+		break;
+	case NETXEN_NIC_XGBE:
+		dev_info(&adapter->pdev->dev, "%s: XGbE port initialized\n",
+				adapter->netdev->name);
+		break;
+	}
 }
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 45fa33e..f6aeccf 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -203,21 +203,6 @@ void netxen_initialize_adapter_sw(struct netxen_adapter *adapter)
 	}
 }
 
-void netxen_initialize_adapter_hw(struct netxen_adapter *adapter)
-{
-	int ports = 0;
-	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
-
-	if (netxen_nic_get_board_info(adapter) != 0)
-		printk("%s: Error getting board config info.\n",
-		       netxen_nic_driver_name);
-	get_brd_port_by_type(board_info->board_type, &ports);
-	if (ports == 0)
-		printk(KERN_ERR "%s: Unknown board type\n",
-		       netxen_nic_driver_name);
-	adapter->ahw.max_ports = ports;
-}
-
 void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 {
 	switch (adapter->ahw.board_type) {
@@ -765,18 +750,13 @@ int netxen_flash_unlock(struct netxen_adapter *adapter)
 
 int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 {
-	int addr, val, status;
+	int addr, val;
 	int n, i;
 	int init_delay = 0;
 	struct crb_addr_pair *buf;
 	u32 off;
 
 	/* resetall */
-	status = netxen_nic_get_board_info(adapter);
-	if (status)
-		printk("%s: netxen_pinit_from_rom: Error getting board info\n",
-		       netxen_nic_driver_name);
-
 	netxen_crb_writelit_adapter(adapter, NETXEN_ROMUSB_GLB_SW_RESET,
 				    NETXEN_ROMBUS_RESET);
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f903de0..755f4ab 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -72,13 +72,13 @@ static irqreturn_t netxen_msi_intr(int irq, void *data);
 
 /*  PCI Device ID Table  */
 static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
-	{PCI_DEVICE(0x4040, 0x0001)},
-	{PCI_DEVICE(0x4040, 0x0002)},
-	{PCI_DEVICE(0x4040, 0x0003)},
-	{PCI_DEVICE(0x4040, 0x0004)},
-	{PCI_DEVICE(0x4040, 0x0005)},
-	{PCI_DEVICE(0x4040, 0x0024)},
-	{PCI_DEVICE(0x4040, 0x0025)},
+	{PCI_DEVICE(0x4040, 0x0001), PCI_DEVICE_CLASS(0x020000, ~0)},
+	{PCI_DEVICE(0x4040, 0x0002), PCI_DEVICE_CLASS(0x020000, ~0)},
+	{PCI_DEVICE(0x4040, 0x0003), PCI_DEVICE_CLASS(0x020000, ~0)},
+	{PCI_DEVICE(0x4040, 0x0004), PCI_DEVICE_CLASS(0x020000, ~0)},
+	{PCI_DEVICE(0x4040, 0x0005), PCI_DEVICE_CLASS(0x020000, ~0)},
+	{PCI_DEVICE(0x4040, 0x0024), PCI_DEVICE_CLASS(0x020000, ~0)},
+	{PCI_DEVICE(0x4040, 0x0025), PCI_DEVICE_CLASS(0x020000, ~0)},
 	{0,}
 };
 
@@ -286,10 +286,11 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int pci_func_id = PCI_FUNC(pdev->devfn);
 	DECLARE_MAC_BUF(mac);
 
-	printk(KERN_INFO "%s \n", netxen_nic_driver_string);
+	if (pci_func_id == 0)
+		printk(KERN_INFO "%s \n", netxen_nic_driver_string);
 
 	if (pdev->class != 0x020000) {
-		printk(KERN_ERR"NetXen function %d, class %x will not "
+		printk(KERN_DEBUG "NetXen function %d, class %x will not "
 				"be enabled.\n",pci_func_id, pdev->class);
 		return -ENODEV;
 	}
@@ -448,8 +449,12 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	adapter->curr_window = 255;
 
-	/* initialize the adapter */
-	netxen_initialize_adapter_hw(adapter);
+	if (netxen_nic_get_board_info(adapter) != 0) {
+		printk("%s: Error getting board config info.\n",
+		       netxen_nic_driver_name);
+		err = -EIO;
+		goto err_out_iounmap;
+	}
 
 	/*
 	 *  Adapter in our case is quad port so initialize it before
@@ -621,7 +626,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 		/* clear the register for future unloads/loads */
 		writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
-		printk(KERN_INFO "State: 0x%0x\n",
+		printk(KERN_DEBUG "State: 0x%0x\n",
 			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
 
 		/*
@@ -643,6 +648,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/*
 	 * See if the firmware gave us a virtual-physical port mapping.
 	 */
+	adapter->physical_port = adapter->portnum;
 	i = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_V2P(adapter->portnum)));
 	if (i != 0x55555555)
 		adapter->physical_port = i;
@@ -658,22 +664,9 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_dev;
 	}
 
+	netxen_nic_flash_print(adapter);
 	pci_set_drvdata(pdev, adapter);
 
-	switch (adapter->ahw.board_type) {
-		case NETXEN_NIC_GBE:
-			printk(KERN_INFO "%s: QUAD GbE board initialized\n",
-			       netxen_nic_driver_name);
-			break;
-
-		case NETXEN_NIC_XGBE:
-			printk(KERN_INFO "%s: XGbE board initialized\n",
-					netxen_nic_driver_name);
-			break;
-	}
-
-	adapter->driver_mismatch = 0;
-
 	return 0;
 
 err_out_free_dev:
@@ -781,9 +774,6 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 			/* clear the register for future unloads/loads */
 			writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
-			printk(KERN_INFO "State: 0x%0x\n",
-				readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
-
 			/* leave the hw in the same state as reboot */
 			writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
 			netxen_pinit_from_rom(adapter, 0);
@@ -794,7 +784,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 		/* clear the register for future unloads/loads */
 		writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
-		printk(KERN_INFO "State: 0x%0x\n",
+		printk(KERN_DEBUG "State: 0x%0x\n",
 			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
 
 		i = 100;
@@ -844,13 +834,15 @@ static int netxen_nic_open(struct net_device *netdev)
 	irq_handler_t handler;
 	unsigned long flags = IRQF_SAMPLE_RANDOM;
 
+	if (adapter->driver_mismatch)
+		return -EIO;
+
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC) {
 		err = netxen_init_firmware(adapter);
 		if (err != 0) {
 			printk(KERN_ERR "Failed to init firmware\n");
 			return -EIO;
 		}
-		netxen_nic_flash_print(adapter);
 
 		/* setup all the resources for the Phantom... */
 		/* this include the descriptors for rcv, tx, and status */
@@ -899,14 +891,12 @@ static int netxen_nic_open(struct net_device *netdev)
 	if (adapter->set_mtu)
 		adapter->set_mtu(adapter, netdev->mtu);
 
-	if (!adapter->driver_mismatch)
-		mod_timer(&adapter->watchdog_timer, jiffies);
+	mod_timer(&adapter->watchdog_timer, jiffies);
 
 	napi_enable(&adapter->napi);
 	netxen_nic_enable_int(adapter);
 
-	if (!adapter->driver_mismatch)
-		netif_start_queue(netdev);
+	netif_start_queue(netdev);
 
 	return 0;
 }
-- 
1.5.4.3

