From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes for .26
Date: Wed, 18 Jun 2008 00:20:22 -0400
Message-ID: <20080618042022.GA30735@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:54816 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751504AbYFREUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 00:20:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/atlx/atl1.c                 |    1 -
 drivers/net/enc28j60.c                  |   87 ++++++++++++++------
 drivers/net/ibm_newemac/Kconfig         |    1 +
 drivers/net/netxen/netxen_nic.h         |   18 +----
 drivers/net/netxen/netxen_nic_ethtool.c |    6 +-
 drivers/net/netxen/netxen_nic_hw.c      |  112 +++++++++++---------------
 drivers/net/netxen/netxen_nic_init.c    |   46 +++++------
 drivers/net/netxen/netxen_nic_isr.c     |    4 +-
 drivers/net/netxen/netxen_nic_main.c    |  133 ++++++++++---------------------
 drivers/net/netxen/netxen_nic_niu.c     |   22 +++---
 drivers/net/sky2.c                      |    1 +
 11 files changed, 189 insertions(+), 242 deletions(-)

David Brownell (2):
      net/enc28j60: section fix
      net/enc28j60: low power mode

Dhananjay Phadke (4):
      netxen: fix portnum for hp mezz cards
      netxen: remove global physical_port array
      netxen: cleanup debug messages
      netxen: download firmware in pci probe

Josh Boyer (1):
      ibm_newemac: select CRC32 in Kconfig

Radu Cristescu (1):
      atl1: relax eeprom mac address error check

Stephen Hemminger (1):
      sky2: 88E8040T pci device id

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 99e0b4c..3c798ae 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -471,7 +471,6 @@ static int atl1_get_permanent_address(struct atl1_hw *hw)
 			memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
 			return 0;
 		}
-		return 1;
 	}
 
 	/* see if SPI FLAGS exist ? */
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index 46a90e9..c05cb15 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -400,26 +400,31 @@ enc28j60_packet_write(struct enc28j60_net *priv, int len, const u8 *data)
 	mutex_unlock(&priv->lock);
 }
 
-/*
- * Wait until the PHY operation is complete.
- */
-static int wait_phy_ready(struct enc28j60_net *priv)
+static unsigned long msec20_to_jiffies;
+
+static int poll_ready(struct enc28j60_net *priv, u8 reg, u8 mask, u8 val)
 {
-	unsigned long timeout = jiffies + 20 * HZ / 1000;
-	int ret = 1;
+	unsigned long timeout = jiffies + msec20_to_jiffies;
 
 	/* 20 msec timeout read */
-	while (nolock_regb_read(priv, MISTAT) & MISTAT_BUSY) {
+	while ((nolock_regb_read(priv, reg) & mask) != val) {
 		if (time_after(jiffies, timeout)) {
 			if (netif_msg_drv(priv))
-				printk(KERN_DEBUG DRV_NAME
-					": PHY ready timeout!\n");
-			ret = 0;
-			break;
+				dev_dbg(&priv->spi->dev,
+					"reg %02x ready timeout!\n", reg);
+			return -ETIMEDOUT;
 		}
 		cpu_relax();
 	}
-	return ret;
+	return 0;
+}
+
+/*
+ * Wait until the PHY operation is complete.
+ */
+static int wait_phy_ready(struct enc28j60_net *priv)
+{
+	return poll_ready(priv, MISTAT, MISTAT_BUSY, 0) ? 0 : 1;
 }
 
 /*
@@ -594,6 +599,32 @@ static void nolock_txfifo_init(struct enc28j60_net *priv, u16 start, u16 end)
 	nolock_regw_write(priv, ETXNDL, end);
 }
 
+/*
+ * Low power mode shrinks power consumption about 100x, so we'd like
+ * the chip to be in that mode whenever it's inactive.  (However, we
+ * can't stay in lowpower mode during suspend with WOL active.)
+ */
+static void enc28j60_lowpower(struct enc28j60_net *priv, bool is_low)
+{
+	if (netif_msg_drv(priv))
+		dev_dbg(&priv->spi->dev, "%s power...\n",
+				is_low ? "low" : "high");
+
+	mutex_lock(&priv->lock);
+	if (is_low) {
+		nolock_reg_bfclr(priv, ECON1, ECON1_RXEN);
+		poll_ready(priv, ESTAT, ESTAT_RXBUSY, 0);
+		poll_ready(priv, ECON1, ECON1_TXRTS, 0);
+		/* ECON2_VRPS was set during initialization */
+		nolock_reg_bfset(priv, ECON2, ECON2_PWRSV);
+	} else {
+		nolock_reg_bfclr(priv, ECON2, ECON2_PWRSV);
+		poll_ready(priv, ESTAT, ESTAT_CLKRDY, ESTAT_CLKRDY);
+		/* caller sets ECON1_RXEN */
+	}
+	mutex_unlock(&priv->lock);
+}
+
 static int enc28j60_hw_init(struct enc28j60_net *priv)
 {
 	u8 reg;
@@ -612,8 +643,8 @@ static int enc28j60_hw_init(struct enc28j60_net *priv)
 	priv->tx_retry_count = 0;
 	priv->max_pk_counter = 0;
 	priv->rxfilter = RXFILTER_NORMAL;
-	/* enable address auto increment */
-	nolock_regb_write(priv, ECON2, ECON2_AUTOINC);
+	/* enable address auto increment and voltage regulator powersave */
+	nolock_regb_write(priv, ECON2, ECON2_AUTOINC | ECON2_VRPS);
 
 	nolock_rxfifo_init(priv, RXSTART_INIT, RXEND_INIT);
 	nolock_txfifo_init(priv, TXSTART_INIT, TXEND_INIT);
@@ -690,7 +721,7 @@ static int enc28j60_hw_init(struct enc28j60_net *priv)
 
 static void enc28j60_hw_enable(struct enc28j60_net *priv)
 {
-	/* enable interrutps */
+	/* enable interrupts */
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() enabling interrupts.\n",
 			__FUNCTION__);
@@ -726,15 +757,12 @@ enc28j60_setlink(struct net_device *ndev, u8 autoneg, u16 speed, u8 duplex)
 	int ret = 0;
 
 	if (!priv->hw_enable) {
-		if (autoneg == AUTONEG_DISABLE && speed == SPEED_10) {
+		/* link is in low power mode now; duplex setting
+		 * will take effect on next enc28j60_hw_init().
+		 */
+		if (autoneg == AUTONEG_DISABLE && speed == SPEED_10)
 			priv->full_duplex = (duplex == DUPLEX_FULL);
-			if (!enc28j60_hw_init(priv)) {
-				if (netif_msg_drv(priv))
-					dev_err(&ndev->dev,
-						"hw_reset() failed\n");
-				ret = -EINVAL;
-			}
-		} else {
+		else {
 			if (netif_msg_link(priv))
 				dev_warn(&ndev->dev,
 					"unsupported link setting\n");
@@ -1307,7 +1335,8 @@ static int enc28j60_net_open(struct net_device *dev)
 		}
 		return -EADDRNOTAVAIL;
 	}
-	/* Reset the hardware here */
+	/* Reset the hardware here (and take it out of low power mode) */
+	enc28j60_lowpower(priv, false);
 	enc28j60_hw_disable(priv);
 	if (!enc28j60_hw_init(priv)) {
 		if (netif_msg_ifup(priv))
@@ -1337,6 +1366,7 @@ static int enc28j60_net_close(struct net_device *dev)
 		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
 
 	enc28j60_hw_disable(priv);
+	enc28j60_lowpower(priv, true);
 	netif_stop_queue(dev);
 
 	return 0;
@@ -1537,6 +1567,8 @@ static int __devinit enc28j60_probe(struct spi_device *spi)
 	dev->watchdog_timeo = TX_TIMEOUT;
 	SET_ETHTOOL_OPS(dev, &enc28j60_ethtool_ops);
 
+	enc28j60_lowpower(priv, true);
+
 	ret = register_netdev(dev);
 	if (ret) {
 		if (netif_msg_probe(priv))
@@ -1556,7 +1588,7 @@ error_alloc:
 	return ret;
 }
 
-static int enc28j60_remove(struct spi_device *spi)
+static int __devexit enc28j60_remove(struct spi_device *spi)
 {
 	struct enc28j60_net *priv = dev_get_drvdata(&spi->dev);
 
@@ -1573,15 +1605,16 @@ static int enc28j60_remove(struct spi_device *spi)
 static struct spi_driver enc28j60_driver = {
 	.driver = {
 		   .name = DRV_NAME,
-		   .bus = &spi_bus_type,
 		   .owner = THIS_MODULE,
-		   },
+	 },
 	.probe = enc28j60_probe,
 	.remove = __devexit_p(enc28j60_remove),
 };
 
 static int __init enc28j60_init(void)
 {
+	msec20_to_jiffies = msecs_to_jiffies(20);
+
 	return spi_register_driver(&enc28j60_driver);
 }
 
diff --git a/drivers/net/ibm_newemac/Kconfig b/drivers/net/ibm_newemac/Kconfig
index 0d3e738..70a3272 100644
--- a/drivers/net/ibm_newemac/Kconfig
+++ b/drivers/net/ibm_newemac/Kconfig
@@ -1,6 +1,7 @@
 config IBM_NEW_EMAC
 	tristate "IBM EMAC Ethernet support"
 	depends on PPC_DCR && PPC_MERGE
+	select CRC32
 	help
 	  This driver supports the IBM EMAC family of Ethernet controllers
 	  typically found on 4xx embedded PowerPC chips, but also on the
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 8cb29f5..da4c4fb 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -776,7 +776,6 @@ struct netxen_hardware_context {
 
 	u8 revision_id;
 	u16 board_type;
-	u16 max_ports;
 	struct netxen_board_info boardcfg;
 	u32 xg_linkup;
 	u32 qg_linksup;
@@ -863,6 +862,7 @@ struct netxen_adapter {
 	unsigned char mac_addr[ETH_ALEN];
 	int mtu;
 	int portnum;
+	u8 physical_port;
 
 	struct work_struct watchdog_task;
 	struct timer_list watchdog_timer;
@@ -1034,7 +1034,6 @@ int netxen_rom_se(struct netxen_adapter *adapter, int addr);
 
 /* Functions from netxen_nic_isr.c */
 void netxen_initialize_adapter_sw(struct netxen_adapter *adapter);
-void netxen_initialize_adapter_hw(struct netxen_adapter *adapter);
 void *netxen_alloc(struct pci_dev *pdev, size_t sz, dma_addr_t * ptr,
 		   struct pci_dev **used_dev);
 void netxen_initialize_adapter_ops(struct netxen_adapter *adapter);
@@ -1077,20 +1076,6 @@ static const struct netxen_brdinfo netxen_boards[] = {
 
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
@@ -1169,5 +1154,4 @@ extern int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr,
 
 extern struct ethtool_ops netxen_nic_ethtool_ops;
 
-extern int physical_port[];	/* physical port # from virtual port.*/
 #endif				/* __NETXEN_NIC_H_ */
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 6e98d83..723487b 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -369,7 +369,7 @@ netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 		for (i = 3; niu_registers[mode].reg[i - 3] != -1; i++) {
 			/* GB: port specific registers */
 			if (mode == 0 && i >= 19)
-				window = physical_port[adapter->portnum] *
+				window = adapter->physical_port *
 					NETXEN_NIC_PORT_WINDOW;
 
 			NETXEN_NIC_LOCKED_READ_REG(niu_registers[mode].
@@ -527,7 +527,7 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 val;
-	int port = physical_port[adapter->portnum];
+	int port = adapter->physical_port;
 
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
@@ -573,7 +573,7 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 val;
-	int port = physical_port[adapter->portnum];
+	int port = adapter->physical_port;
 	/* read mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index af73564..c43d06b 100644
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
@@ -1032,15 +1025,15 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu)
 {
 	netxen_nic_write_w0(adapter,
-			NETXEN_NIU_GB_MAX_FRAME_SIZE(
-				physical_port[adapter->portnum]), new_mtu);
+		NETXEN_NIU_GB_MAX_FRAME_SIZE(adapter->physical_port),
+		new_mtu);
 	return 0;
 }
 
 int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
 {
 	new_mtu += NETXEN_NIU_HDRSIZE + NETXEN_NIU_TLRSIZE;
-	if (physical_port[adapter->portnum] == 0)
+	if (adapter->physical_port == 0)
 		netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE,
 				new_mtu);
 	else
@@ -1051,7 +1044,7 @@ int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
 
 void netxen_nic_init_niu_gb(struct netxen_adapter *adapter)
 {
-	netxen_niu_gbe_init_port(adapter, physical_port[adapter->portnum]);
+	netxen_niu_gbe_init_port(adapter, adapter->physical_port);
 }
 
 void
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
index 45fa33e..70d1b22 100644
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
 
@@ -860,10 +840,10 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 				netxen_nic_pci_change_crbwindow(adapter, 1);
 			}
 			if (init_delay == 1) {
-				msleep(2000);
+				msleep(1000);
 				init_delay = 0;
 			}
-			msleep(20);
+			msleep(1);
 		}
 		kfree(buf);
 
@@ -938,12 +918,28 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
 
 void netxen_free_adapter_offload(struct netxen_adapter *adapter)
 {
+	int i;
+
 	if (adapter->dummy_dma.addr) {
-		pci_free_consistent(adapter->ahw.pdev,
+		i = 100;
+		do {
+			if (dma_watchdog_shutdown_request(adapter) == 1)
+				break;
+			msleep(50);
+			if (dma_watchdog_shutdown_poll_result(adapter) == 1)
+				break;
+		} while (--i);
+
+		if (i) {
+			pci_free_consistent(adapter->ahw.pdev,
 				    NETXEN_HOST_DUMMY_DMA_SIZE,
 				    adapter->dummy_dma.addr,
 				    adapter->dummy_dma.phys_addr);
-		adapter->dummy_dma.addr = NULL;
+			adapter->dummy_dma.addr = NULL;
+		} else {
+			printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
+					adapter->netdev->name);
+		}
 	}
 }
 
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index f487615..96cec41 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -145,7 +145,7 @@ static void netxen_nic_isr_other(struct netxen_adapter *adapter)
 
 	/* verify the offset */
 	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
-	val = val >> physical_port[adapter->portnum];
+	val = val >> adapter->physical_port;
 	if (val == adapter->ahw.qg_linksup)
 		return;
 
@@ -199,7 +199,7 @@ void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter)
 
 	/* WINDOW = 1 */
 	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
-	val >>= (physical_port[adapter->portnum] * 8);
+	val >>= (adapter->physical_port * 8);
 	val &= 0xff;
 
 	if (adapter->ahw.xg_linkup == 1 && val != XG_LINK_UP) {
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 7144c25..6797ed0 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -70,17 +70,15 @@ static void netxen_nic_poll_controller(struct net_device *netdev);
 static irqreturn_t netxen_intr(int irq, void *data);
 static irqreturn_t netxen_msi_intr(int irq, void *data);
 
-int physical_port[] = {0, 1, 2, 3};
-
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
 
@@ -288,10 +286,11 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -450,8 +449,12 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -530,17 +533,15 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netxen_initialize_adapter_sw(adapter);	/* initialize the buffers in adapter */
 
 	/* Mezz cards have PCI function 0,2,3 enabled */
-	if ((adapter->ahw.boardcfg.board_type == NETXEN_BRDTYPE_P2_SB31_10G_IMEZ)
-		&& (pci_func_id >= 2))
+	switch (adapter->ahw.boardcfg.board_type) {
+	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
+	case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
+		if (pci_func_id >= 2)
 			adapter->portnum = pci_func_id - 2;
-
-#ifdef CONFIG_IA64
-	if(adapter->portnum == 0) {
-		netxen_pinit_from_rom(adapter, 0);
-		udelay(500);
-		netxen_load_firmware(adapter);
+		break;
+	default:
+		break;
 	}
-#endif
 
 	init_timer(&adapter->watchdog_timer);
 	adapter->ahw.xg_linkup = 0;
@@ -613,11 +614,18 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 				err = -ENODEV;
 				goto err_out_free_dev;
 		    }
+		} else {
+			writel(0, NETXEN_CRB_NORMALIZE(adapter,
+						CRB_CMDPEG_STATE));
+			netxen_pinit_from_rom(adapter, 0);
+			msleep(1);
+			netxen_load_firmware(adapter);
+			netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 		}
 
 		/* clear the register for future unloads/loads */
 		writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
-		printk(KERN_INFO "State: 0x%0x\n",
+		dev_info(&pdev->dev, "cmdpeg state: 0x%0x\n",
 			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
 
 		/*
@@ -639,9 +647,10 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/*
 	 * See if the firmware gave us a virtual-physical port mapping.
 	 */
+	adapter->physical_port = adapter->portnum;
 	i = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_V2P(adapter->portnum)));
 	if (i != 0x55555555)
-		physical_port[adapter->portnum] = i;
+		adapter->physical_port = i;
 
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
@@ -654,22 +663,9 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -760,55 +756,8 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	vfree(adapter->cmd_buf_arr);
 
-	if (adapter->portnum == 0) {
-		if (init_firmware_done) {
-			i = 100;
-			do {
-				if (dma_watchdog_shutdown_request(adapter) == 1)
-					break;
-				msleep(100);
-				if (dma_watchdog_shutdown_poll_result(adapter) == 1)
-					break;
-			} while (--i);
-
-			if (i == 0)
-				printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
-						netdev->name);
-
-			/* clear the register for future unloads/loads */
-			writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
-			printk(KERN_INFO "State: 0x%0x\n",
-				readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
-
-			/* leave the hw in the same state as reboot */
-			writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-			netxen_pinit_from_rom(adapter, 0);
-			msleep(1);
-			netxen_load_firmware(adapter);
-			netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
-		}
-
-		/* clear the register for future unloads/loads */
-		writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
-		printk(KERN_INFO "State: 0x%0x\n",
-			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
-
-		i = 100;
-		do {
-			if (dma_watchdog_shutdown_request(adapter) == 1)
-				break;
-			msleep(100);
-			if (dma_watchdog_shutdown_poll_result(adapter) == 1)
-				break;
-		} while (--i);
-
-		if (i) {
-			netxen_free_adapter_offload(adapter);
-		} else {
-			printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
-					netdev->name);
-		}
-	}
+	if (adapter->portnum == 0)
+		netxen_free_adapter_offload(adapter);
 
 	if (adapter->irq)
 		free_irq(adapter->irq, adapter);
@@ -840,13 +789,15 @@ static int netxen_nic_open(struct net_device *netdev)
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
@@ -895,14 +846,12 @@ static int netxen_nic_open(struct net_device *netdev)
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
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 1c852a7..a3bc7cc 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -94,7 +94,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 	long timeout = 0;
 	long result = 0;
 	long restore = 0;
-	long phy = physical_port[adapter->portnum];
+	long phy = adapter->physical_port;
 	__u32 address;
 	__u32 command;
 	__u32 status;
@@ -190,7 +190,7 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 	long timeout = 0;
 	long result = 0;
 	long restore = 0;
-	long phy = physical_port[adapter->portnum];
+	long phy = adapter->physical_port;
 	__u32 address;
 	__u32 command;
 	__u32 status;
@@ -456,7 +456,7 @@ int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port)
 
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 {
-	u32 portnum = physical_port[adapter->portnum];
+	u32 portnum = adapter->physical_port;
 
 	netxen_crb_writelit_adapter(adapter,
 		NETXEN_NIU_XGE_CONFIG_1+(0x10000*portnum), 0x1447);
@@ -573,7 +573,7 @@ static int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
 {
 	u32 stationhigh;
 	u32 stationlow;
-	int phy = physical_port[adapter->portnum];
+	int phy = adapter->physical_port;
 	u8 val[8];
 
 	if (addr == NULL)
@@ -604,7 +604,7 @@ int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
 {
 	u8 temp[4];
 	u32 val;
-	int phy = physical_port[adapter->portnum];
+	int phy = adapter->physical_port;
 	unsigned char mac_addr[6];
 	int i;
 	DECLARE_MAC_BUF(mac);
@@ -724,7 +724,7 @@ int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
 int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
 {
 	__u32 mac_cfg0;
-	u32 port = physical_port[adapter->portnum];
+	u32 port = adapter->physical_port;
 
 	if (port > NETXEN_NIU_MAX_GBE_PORTS)
 		return -EINVAL;
@@ -740,7 +740,7 @@ int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
 int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 {
 	__u32 mac_cfg;
-	u32 port = physical_port[adapter->portnum];
+	u32 port = adapter->physical_port;
 
 	if (port > NETXEN_NIU_MAX_XG_PORTS)
 		return -EINVAL;
@@ -757,7 +757,7 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 				    netxen_niu_prom_mode_t mode)
 {
 	__u32 reg;
-	u32 port = physical_port[adapter->portnum];
+	u32 port = adapter->physical_port;
 
 	if (port > NETXEN_NIU_MAX_GBE_PORTS)
 		return -EINVAL;
@@ -814,7 +814,7 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 			      netxen_ethernet_macaddr_t addr)
 {
-	int phy = physical_port[adapter->portnum];
+	int phy = adapter->physical_port;
 	u8 temp[4];
 	u32 val;
 
@@ -867,7 +867,7 @@ int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter,
 			      netxen_ethernet_macaddr_t * addr)
 {
-	int phy = physical_port[adapter->portnum];
+	int phy = adapter->physical_port;
 	u32 stationhigh;
 	u32 stationlow;
 	u8 val[8];
@@ -896,7 +896,7 @@ int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 				       netxen_niu_prom_mode_t mode)
 {
 	__u32 reg;
-	u32 port = physical_port[adapter->portnum];
+	u32 port = adapter->physical_port;
 
 	if (port > NETXEN_NIU_MAX_XG_PORTS)
 		return -EINVAL;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 62436b3..c8a5ef2 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -118,6 +118,7 @@ static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4352) }, /* 88E8038 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4353) }, /* 88E8039 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4354) }, /* 88E8040 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4355) }, /* 88E8040T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4356) }, /* 88EC033 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4357) }, /* 88E8042 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x435A) }, /* 88E8048 */
