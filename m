From: Joe Perches <joe@perches.com>
Subject: [PATCH] smsc9420: Use netif_<level>
Date: Tue, 05 Nov 2013 10:34:21 -0800
Message-ID: <1383676461.4387.28.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more standard logging style.

Convert smsc_<level> macros to use netif_<level>.
Remove unused #define PFX
Add pr_fmt and neaten pr_<level> uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/smsc/smsc9420.c | 155 +++++++++++++++++------------------
 1 file changed, 77 insertions(+), 78 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 059bcaf..f433d97 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -19,6 +19,8 @@
  ***************************************************************************
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
@@ -33,7 +35,6 @@
 #include "smsc9420.h"
 
 #define DRV_NAME		"smsc9420"
-#define PFX			DRV_NAME ": "
 #define DRV_MDIONAME		"smsc9420-mdio"
 #define DRV_DESCRIPTION		"SMSC LAN9420 driver"
 #define DRV_VERSION		"1.01"
@@ -97,21 +98,6 @@ static uint debug = -1;
 module_param(debug, uint, 0);
 MODULE_PARM_DESC(debug, "debug level");
 
-#define smsc_dbg(TYPE, f, a...) \
-do {	if ((pd)->msg_enable & NETIF_MSG_##TYPE) \
-		netdev_dbg((pd)->dev, PFX f "\n", ## a); \
-} while (0)
-
-#define smsc_info(TYPE, f, a...) \
-do {	if ((pd)->msg_enable & NETIF_MSG_##TYPE) \
-		netdev_info((pd)->dev, PFX f "\n", ## a); \
-} while (0)
-
-#define smsc_warn(TYPE, f, a...) \
-do {	if ((pd)->msg_enable & NETIF_MSG_##TYPE) \
-		netdev_warn((pd)->dev, PFX f "\n", ## a); \
-} while (0)
-
 static inline u32 smsc9420_reg_read(struct smsc9420_pdata *pd, u32 offset)
 {
 	return ioread32(pd->ioaddr + offset);
@@ -140,7 +126,7 @@ static int smsc9420_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
 
 	/*  confirm MII not busy */
 	if ((smsc9420_reg_read(pd, MII_ACCESS) & MII_ACCESS_MII_BUSY_)) {
-		smsc_warn(DRV, "MII is busy???");
+		netif_warn(pd, drv, pd->dev, "MII is busy???\n");
 		goto out;
 	}
 
@@ -159,7 +145,7 @@ static int smsc9420_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
 		udelay(10);
 	}
 
-	smsc_warn(DRV, "MII busy timeout!");
+	netif_warn(pd, drv, pd->dev, "MII busy timeout!\n");
 
 out:
 	spin_unlock_irqrestore(&pd->phy_lock, flags);
@@ -178,7 +164,7 @@ static int smsc9420_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
 
 	/* confirm MII not busy */
 	if ((smsc9420_reg_read(pd, MII_ACCESS) & MII_ACCESS_MII_BUSY_)) {
-		smsc_warn(DRV, "MII is busy???");
+		netif_warn(pd, drv, pd->dev, "MII is busy???\n");
 		goto out;
 	}
 
@@ -200,7 +186,7 @@ static int smsc9420_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
 		udelay(10);
 	}
 
-	smsc_warn(DRV, "MII busy timeout!");
+	netif_warn(pd, drv, pd->dev, "MII busy timeout!\n");
 
 out:
 	spin_unlock_irqrestore(&pd->phy_lock, flags);
@@ -222,7 +208,7 @@ static int smsc9420_eeprom_reload(struct smsc9420_pdata *pd)
 	BUG_ON(!pd);
 
 	if (smsc9420_reg_read(pd, E2P_CMD) & E2P_CMD_EPC_BUSY_) {
-		smsc_dbg(DRV, "smsc9420_eeprom_reload: Eeprom busy");
+		netif_dbg(pd, drv, pd->dev, "%s: Eeprom busy\n", __func__);
 		return -EIO;
 	}
 
@@ -235,7 +221,7 @@ static int smsc9420_eeprom_reload(struct smsc9420_pdata *pd)
 			return 0;
 	} while (timeout--);
 
-	smsc_warn(DRV, "smsc9420_eeprom_reload: Eeprom timed out");
+	netif_warn(pd, drv, pd->dev, "%s: Eeprom timed out\n", __func__);
 	return -EIO;
 }
 
@@ -347,9 +333,9 @@ static int smsc9420_eeprom_send_cmd(struct smsc9420_pdata *pd, u32 op)
 	int timeout = 100;
 	u32 e2cmd;
 
-	smsc_dbg(HW, "op 0x%08x", op);
+	netif_dbg(pd, hw, pd->dev, "op 0x%08x\n", op);
 	if (smsc9420_reg_read(pd, E2P_CMD) & E2P_CMD_EPC_BUSY_) {
-		smsc_warn(HW, "Busy at start");
+		netif_warn(pd, hw, pd->dev, "Busy at start\n");
 		return -EBUSY;
 	}
 
@@ -362,12 +348,13 @@ static int smsc9420_eeprom_send_cmd(struct smsc9420_pdata *pd, u32 op)
 	} while ((e2cmd & E2P_CMD_EPC_BUSY_) && (--timeout));
 
 	if (!timeout) {
-		smsc_info(HW, "TIMED OUT");
+		netif_info(pd, hw, pd->dev, "TIMED OUT\n");
 		return -EAGAIN;
 	}
 
 	if (e2cmd & E2P_CMD_EPC_TIMEOUT_) {
-		smsc_info(HW, "Error occurred during eeprom operation");
+		netif_info(pd, hw, pd->dev,
+			   "Error occurred during eeprom operation\n");
 		return -EINVAL;
 	}
 
@@ -380,7 +367,7 @@ static int smsc9420_eeprom_read_location(struct smsc9420_pdata *pd,
 	u32 op = E2P_CMD_EPC_CMD_READ_ | address;
 	int ret;
 
-	smsc_dbg(HW, "address 0x%x", address);
+	netif_dbg(pd, hw, pd->dev, "address 0x%x\n", address);
 	ret = smsc9420_eeprom_send_cmd(pd, op);
 
 	if (!ret)
@@ -395,7 +382,7 @@ static int smsc9420_eeprom_write_location(struct smsc9420_pdata *pd,
 	u32 op = E2P_CMD_EPC_CMD_ERASE_ | address;
 	int ret;
 
-	smsc_dbg(HW, "address 0x%x, data 0x%x", address, data);
+	netif_dbg(pd, hw, pd->dev, "address 0x%x, data 0x%x\n", address, data);
 	ret = smsc9420_eeprom_send_cmd(pd, op);
 
 	if (!ret) {
@@ -492,7 +479,8 @@ static void smsc9420_check_mac_address(struct net_device *dev)
 	/* Check if mac address has been specified when bringing interface up */
 	if (is_valid_ether_addr(dev->dev_addr)) {
 		smsc9420_set_mac_address(dev);
-		smsc_dbg(PROBE, "MAC Address is specified by configuration");
+		netif_dbg(pd, probe, pd->dev,
+			  "MAC Address is specified by configuration\n");
 	} else {
 		/* Try reading mac address from device. if EEPROM is present
 		 * it will already have been set */
@@ -507,12 +495,14 @@ static void smsc9420_check_mac_address(struct net_device *dev)
 
 		if (is_valid_ether_addr(dev->dev_addr)) {
 			/* eeprom values are valid  so use them */
-			smsc_dbg(PROBE, "Mac Address is read from EEPROM");
+			netif_dbg(pd, probe, pd->dev,
+				  "Mac Address is read from EEPROM\n");
 		} else {
 			/* eeprom values are invalid, generate random MAC */
 			eth_hw_addr_random(dev);
 			smsc9420_set_mac_address(dev);
-			smsc_dbg(PROBE, "MAC Address is set to random");
+			netif_dbg(pd, probe, pd->dev,
+				  "MAC Address is set to random\n");
 		}
 	}
 }
@@ -535,7 +525,7 @@ static void smsc9420_stop_tx(struct smsc9420_pdata *pd)
 	}
 
 	if (!timeout)
-		smsc_warn(IFDOWN, "TX DMAC failed to stop");
+		netif_warn(pd, ifdown, pd->dev, "TX DMAC failed to stop\n");
 
 	/* ACK Tx DMAC stop bit */
 	smsc9420_reg_write(pd, DMAC_STATUS, DMAC_STS_TXPS_);
@@ -646,7 +636,8 @@ static void smsc9420_stop_rx(struct smsc9420_pdata *pd)
 	}
 
 	if (!timeout)
-		smsc_warn(IFDOWN, "RX DMAC did not stop! timeout.");
+		netif_warn(pd, ifdown, pd->dev,
+			   "RX DMAC did not stop! timeout\n");
 
 	/* ACK the Rx DMAC stop bit */
 	smsc9420_reg_write(pd, DMAC_STATUS, DMAC_STS_RXPS_);
@@ -736,7 +727,7 @@ static void smsc9420_dmac_soft_reset(struct smsc9420_pdata *pd)
 	smsc9420_reg_read(pd, BUS_MODE);
 	udelay(2);
 	if (smsc9420_reg_read(pd, BUS_MODE) & BUS_MODE_SWR_)
-		smsc_warn(DRV, "Software reset not cleared");
+		netif_warn(pd, drv, pd->dev, "Software reset not cleared\n");
 }
 
 static int smsc9420_stop(struct net_device *dev)
@@ -855,7 +846,7 @@ static int smsc9420_alloc_rx_buffer(struct smsc9420_pdata *pd, int index)
 				 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
 	if (pci_dma_mapping_error(pd->pdev, mapping)) {
 		dev_kfree_skb_any(skb);
-		smsc_warn(RX_ERR, "pci_map_single failed!");
+		netif_warn(pd, rx_err, pd->dev, "pci_map_single failed!\n");
 		return -ENOMEM;
 	}
 
@@ -1004,7 +995,8 @@ static netdev_tx_t smsc9420_hard_start_xmit(struct sk_buff *skb,
 	mapping = pci_map_single(pd->pdev, skb->data,
 				 skb->len, PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(pd->pdev, mapping)) {
-		smsc_warn(TX_ERR, "pci_map_single failed, dropping packet");
+		netif_warn(pd, tx_err, pd->dev,
+			   "pci_map_single failed, dropping packet\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1056,12 +1048,12 @@ static void smsc9420_set_multicast_list(struct net_device *dev)
 	u32 mac_cr = smsc9420_reg_read(pd, MAC_CR);
 
 	if (dev->flags & IFF_PROMISC) {
-		smsc_dbg(HW, "Promiscuous Mode Enabled");
+		netif_dbg(pd, hw, pd->dev, "Promiscuous Mode Enabled\n");
 		mac_cr |= MAC_CR_PRMS_;
 		mac_cr &= (~MAC_CR_MCPAS_);
 		mac_cr &= (~MAC_CR_HPFILT_);
 	} else if (dev->flags & IFF_ALLMULTI) {
-		smsc_dbg(HW, "Receive all Multicast Enabled");
+		netif_dbg(pd, hw, pd->dev, "Receive all Multicast Enabled\n");
 		mac_cr &= (~MAC_CR_PRMS_);
 		mac_cr |= MAC_CR_MCPAS_;
 		mac_cr &= (~MAC_CR_HPFILT_);
@@ -1069,7 +1061,7 @@ static void smsc9420_set_multicast_list(struct net_device *dev)
 		struct netdev_hw_addr *ha;
 		u32 hash_lo = 0, hash_hi = 0;
 
-		smsc_dbg(HW, "Multicast filter enabled");
+		netif_dbg(pd, hw, pd->dev, "Multicast filter enabled\n");
 		netdev_for_each_mc_addr(ha, dev) {
 			u32 bit_num = smsc9420_hash(ha->addr);
 			u32 mask = 1 << (bit_num & 0x1F);
@@ -1087,7 +1079,7 @@ static void smsc9420_set_multicast_list(struct net_device *dev)
 		mac_cr &= (~MAC_CR_MCPAS_);
 		mac_cr |= MAC_CR_HPFILT_;
 	} else {
-		smsc_dbg(HW, "Receive own packets only.");
+		netif_dbg(pd, hw, pd->dev, "Receive own packets only\n");
 		smsc9420_reg_write(pd, HASHH, 0);
 		smsc9420_reg_write(pd, HASHL, 0);
 
@@ -1115,11 +1107,11 @@ static void smsc9420_phy_update_flowcontrol(struct smsc9420_pdata *pd)
 		else
 			flow = 0;
 
-		smsc_info(LINK, "rx pause %s, tx pause %s",
-			(cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
-			(cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
+		netif_info(pd, link, pd->dev, "rx pause %s, tx pause %s\n",
+			   cap & FLOW_CTRL_RX ? "enabled" : "disabled",
+			   cap & FLOW_CTRL_TX ? "enabled" : "disabled");
 	} else {
-		smsc_info(LINK, "half duplex");
+		netif_info(pd, link, pd->dev, "half duplex\n");
 		flow = 0;
 	}
 
@@ -1137,10 +1129,10 @@ static void smsc9420_phy_adjust_link(struct net_device *dev)
 	if (phy_dev->duplex != pd->last_duplex) {
 		u32 mac_cr = smsc9420_reg_read(pd, MAC_CR);
 		if (phy_dev->duplex) {
-			smsc_dbg(LINK, "full duplex mode");
+			netif_dbg(pd, link, pd->dev, "full duplex mode\n");
 			mac_cr |= MAC_CR_FDPX_;
 		} else {
-			smsc_dbg(LINK, "half duplex mode");
+			netif_dbg(pd, link, pd->dev, "half duplex mode\n");
 			mac_cr &= ~MAC_CR_FDPX_;
 		}
 		smsc9420_reg_write(pd, MAC_CR, mac_cr);
@@ -1152,9 +1144,9 @@ static void smsc9420_phy_adjust_link(struct net_device *dev)
 	carrier = netif_carrier_ok(dev);
 	if (carrier != pd->last_carrier) {
 		if (carrier)
-			smsc_dbg(LINK, "carrier OK");
+			netif_dbg(pd, link, pd->dev, "carrier OK\n");
 		else
-			smsc_dbg(LINK, "no carrier");
+			netif_dbg(pd, link, pd->dev, "no carrier\n");
 		pd->last_carrier = carrier;
 	}
 }
@@ -1173,8 +1165,8 @@ static int smsc9420_mii_probe(struct net_device *dev)
 	}
 
 	phydev = pd->mii_bus->phy_map[1];
-	smsc_info(PROBE, "PHY addr %d, phy_id 0x%08X", phydev->addr,
-		phydev->phy_id);
+	netif_info(pd, probe, pd->dev, "PHY addr %d, phy_id 0x%08X\n",
+		   phydev->addr, phydev->phy_id);
 
 	phydev = phy_connect(dev, dev_name(&phydev->dev),
 			     smsc9420_phy_adjust_link, PHY_INTERFACE_MODE_MII);
@@ -1223,12 +1215,12 @@ static int smsc9420_mii_init(struct net_device *dev)
 	pd->mii_bus->phy_mask = ~(1 << 1);
 
 	if (mdiobus_register(pd->mii_bus)) {
-		smsc_warn(PROBE, "Error registering mii bus");
+		netif_warn(pd, probe, pd->dev, "Error registering mii bus\n");
 		goto err_out_free_bus_2;
 	}
 
 	if (smsc9420_mii_probe(dev) < 0) {
-		smsc_warn(PROBE, "Error probing mii bus");
+		netif_warn(pd, probe, pd->dev, "Error probing mii bus\n");
 		goto err_out_unregister_bus_3;
 	}
 
@@ -1281,12 +1273,11 @@ static int smsc9420_alloc_rx_ring(struct smsc9420_pdata *pd)
 
 	BUG_ON(!pd->rx_ring);
 
-	pd->rx_buffers = kmalloc((sizeof(struct smsc9420_ring_info) *
-		RX_RING_SIZE), GFP_KERNEL);
-	if (pd->rx_buffers == NULL) {
-		smsc_warn(IFUP, "Failed to allocated rx_buffers");
+	pd->rx_buffers = kmalloc_array(RX_RING_SIZE,
+				       sizeof(struct smsc9420_ring_info),
+				       GFP_KERNEL);
+	if (pd->rx_buffers == NULL)
 		goto out;
-	}
 
 	/* initialize the rx ring */
 	for (i = 0; i < RX_RING_SIZE; i++) {
@@ -1301,7 +1292,8 @@ static int smsc9420_alloc_rx_ring(struct smsc9420_pdata *pd)
 	/* now allocate the entire ring of skbs */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		if (smsc9420_alloc_rx_buffer(pd, i)) {
-			smsc_warn(IFUP, "failed to allocate rx skb %d", i);
+			netif_warn(pd, ifup, pd->dev,
+				   "failed to allocate rx skb %d\n", i);
 			goto out_free_rx_skbs;
 		}
 	}
@@ -1310,13 +1302,14 @@ static int smsc9420_alloc_rx_ring(struct smsc9420_pdata *pd)
 	pd->rx_ring_tail = 0;
 
 	smsc9420_reg_write(pd, VLAN1, ETH_P_8021Q);
-	smsc_dbg(IFUP, "VLAN1 = 0x%08x", smsc9420_reg_read(pd, VLAN1));
+	netif_dbg(pd, ifup, pd->dev, "VLAN1 = 0x%08x\n",
+		  smsc9420_reg_read(pd, VLAN1));
 
 	if (pd->rx_csum) {
 		/* Enable RX COE */
 		u32 coe = smsc9420_reg_read(pd, COE_CR) | RX_COE_EN;
 		smsc9420_reg_write(pd, COE_CR, coe);
-		smsc_dbg(IFUP, "COE_CR = 0x%08x", coe);
+		netif_dbg(pd, ifup, pd->dev, "COE_CR = 0x%08x\n", coe);
 	}
 
 	smsc9420_reg_write(pd, RX_BASE_ADDR, pd->rx_dma_addr);
@@ -1339,7 +1332,8 @@ static int smsc9420_open(struct net_device *dev)
 	int result = 0, timeout;
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		smsc_warn(IFUP, "dev_addr is not a valid MAC address");
+		netif_warn(pd, ifup, pd->dev,
+			   "dev_addr is not a valid MAC address\n");
 		result = -EADDRNOTAVAIL;
 		goto out_0;
 	}
@@ -1358,7 +1352,7 @@ static int smsc9420_open(struct net_device *dev)
 
 	result = request_irq(irq, smsc9420_isr, IRQF_SHARED, DRV_NAME, pd);
 	if (result) {
-		smsc_warn(IFUP, "Unable to use IRQ = %d", irq);
+		netif_warn(pd, ifup, pd->dev, "Unable to use IRQ = %d\n", irq);
 		result = -ENODEV;
 		goto out_0;
 	}
@@ -1393,7 +1387,7 @@ static int smsc9420_open(struct net_device *dev)
 	smsc9420_pci_flush_write(pd);
 
 	/* test the IRQ connection to the ISR */
-	smsc_dbg(IFUP, "Testing ISR using IRQ %d", irq);
+	netif_dbg(pd, ifup, pd->dev, "Testing ISR using IRQ %d\n", irq);
 	pd->software_irq_signal = false;
 
 	spin_lock_irqsave(&pd->int_lock, flags);
@@ -1423,30 +1417,32 @@ static int smsc9420_open(struct net_device *dev)
 	spin_unlock_irqrestore(&pd->int_lock, flags);
 
 	if (!pd->software_irq_signal) {
-		smsc_warn(IFUP, "ISR failed signaling test");
+		netif_warn(pd, ifup, pd->dev, "ISR failed signaling test\n");
 		result = -ENODEV;
 		goto out_free_irq_1;
 	}
 
-	smsc_dbg(IFUP, "ISR passed test using IRQ %d", irq);
+	netif_dbg(pd, ifup, pd->dev, "ISR passed test using IRQ %d\n", irq);
 
 	result = smsc9420_alloc_tx_ring(pd);
 	if (result) {
-		smsc_warn(IFUP, "Failed to Initialize tx dma ring");
+		netif_warn(pd, ifup, pd->dev,
+			   "Failed to Initialize tx dma ring\n");
 		result = -ENOMEM;
 		goto out_free_irq_1;
 	}
 
 	result = smsc9420_alloc_rx_ring(pd);
 	if (result) {
-		smsc_warn(IFUP, "Failed to Initialize rx dma ring");
+		netif_warn(pd, ifup, pd->dev,
+			   "Failed to Initialize rx dma ring\n");
 		result = -ENOMEM;
 		goto out_free_tx_ring_2;
 	}
 
 	result = smsc9420_mii_init(dev);
 	if (result) {
-		smsc_warn(IFUP, "Failed to initialize Phy");
+		netif_warn(pd, ifup, pd->dev, "Failed to initialize Phy\n");
 		result = -ENODEV;
 		goto out_free_rx_ring_3;
 	}
@@ -1547,7 +1543,8 @@ static int smsc9420_resume(struct pci_dev *pdev)
 
 	err = pci_enable_wake(pdev, 0, 0);
 	if (err)
-		smsc_warn(IFUP, "pci_enable_wake failed: %d", err);
+		netif_warn(pd, ifup, pd->dev, "pci_enable_wake failed: %d\n",
+			   err);
 
 	if (netif_running(dev)) {
 		/* FIXME: gross. It looks like ancient PM relic.*/
@@ -1582,7 +1579,7 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	int result = 0;
 	u32 id_rev;
 
-	pr_info(DRV_DESCRIPTION " version " DRV_VERSION "\n");
+	pr_info("%s version %s\n", DRV_DESCRIPTION, DRV_VERSION);
 
 	/* First do the PCI initialisation */
 	result = pci_enable_device(pdev);
@@ -1605,19 +1602,19 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 	if ((pci_request_regions(pdev, DRV_NAME))) {
-		netdev_err(dev, "Cannot obtain PCI resources, aborting.\n");
+		netdev_err(dev, "Cannot obtain PCI resources, aborting\n");
 		goto out_free_netdev_2;
 	}
 
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		netdev_err(dev, "No usable DMA configuration, aborting.\n");
+		netdev_err(dev, "No usable DMA configuration, aborting\n");
 		goto out_free_regions_3;
 	}
 
 	virt_addr = ioremap(pci_resource_start(pdev, SMSC_BAR),
 		pci_resource_len(pdev, SMSC_BAR));
 	if (!virt_addr) {
-		netdev_err(dev, "Cannot map device registers, aborting.\n");
+		netdev_err(dev, "Cannot map device registers, aborting\n");
 		goto out_free_regions_3;
 	}
 
@@ -1646,16 +1643,17 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	pd->msg_enable = smsc_debug;
 	pd->rx_csum = true;
 
-	smsc_dbg(PROBE, "lan_base=0x%08lx", (ulong)virt_addr);
+	netif_dbg(pd, probe, pd->dev, "lan_base=0x%08lx\n", (ulong)virt_addr);
 
 	id_rev = smsc9420_reg_read(pd, ID_REV);
 	switch (id_rev & 0xFFFF0000) {
 	case 0x94200000:
-		smsc_info(PROBE, "LAN9420 identified, ID_REV=0x%08X", id_rev);
+		netif_info(pd, probe, pd->dev,
+			   "LAN9420 identified, ID_REV=0x%08X\n", id_rev);
 		break;
 	default:
-		smsc_warn(PROBE, "LAN9420 NOT identified");
-		smsc_warn(PROBE, "ID_REV=0x%08X", id_rev);
+		netif_warn(pd, probe, pd->dev, "LAN9420 NOT identified\n");
+		netif_warn(pd, probe, pd->dev, "ID_REV=0x%08X\n", id_rev);
 		goto out_free_dmadesc_5;
 	}
 
@@ -1670,7 +1668,8 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	result = register_netdev(dev);
 	if (result) {
-		smsc_warn(PROBE, "error %i registering device", result);
+		netif_warn(pd, probe, pd->dev, "error %i registering device\n",
+			   result);
 		goto out_free_dmadesc_5;
 	}
 
