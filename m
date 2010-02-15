From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/7] drivers/net/tehuti.c: Use (pr|netdev|netif)_<levels> macro helpers
Date: Mon, 15 Feb 2010 10:34:22 -0800
Message-ID: <d8eb31049ee39435ce472d8b35896f0e1c564331.1266258417.git.joe@perches.com>
References: <cover.1266258417.git.joe@perches.com>
Cc: Alexander Indenbaum <baum@tehutinetworks.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266258417.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the output logging messages a bit more consistent.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tehuti.c |   88 +++++++++++++++++++++++--------------------------
 drivers/net/tehuti.h |   30 ++++++++++-------
 2 files changed, 59 insertions(+), 59 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index ab9b028..82e522a 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -62,9 +62,11 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "tehuti.h"
 
-static DEFINE_PCI_DEVICE_TABLE(bdx_pci_tbl) = {
+static struct pci_device_id __devinitdata bdx_pci_tbl[] = {
 	{0x1FC9, 0x3009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x1FC9, 0x3010, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x1FC9, 0x3014, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
@@ -105,26 +107,24 @@ static void print_hw_id(struct pci_dev *pdev)
 	pci_read_config_word(pdev, PCI_LINK_STATUS_REG, &pci_link_status);
 	pci_read_config_word(pdev, PCI_DEV_CTRL_REG, &pci_ctrl);
 
-	printk(KERN_INFO "tehuti: %s%s\n", BDX_NIC_NAME,
-	       nic->port_num == 1 ? "" : ", 2-Port");
-	printk(KERN_INFO
-	       "tehuti: srom 0x%x fpga %d build %u lane# %d"
-	       " max_pl 0x%x mrrs 0x%x\n",
-	       readl(nic->regs + SROM_VER), readl(nic->regs + FPGA_VER) & 0xFFF,
-	       readl(nic->regs + FPGA_SEED),
-	       GET_LINK_STATUS_LANES(pci_link_status),
-	       GET_DEV_CTRL_MAXPL(pci_ctrl), GET_DEV_CTRL_MRRS(pci_ctrl));
+	pr_info("%s%s\n", BDX_NIC_NAME,
+		nic->port_num == 1 ? "" : ", 2-Port");
+	pr_info("srom 0x%x fpga %d build %u lane# %d max_pl 0x%x mrrs 0x%x\n",
+		readl(nic->regs + SROM_VER), readl(nic->regs + FPGA_VER) & 0xFFF,
+		readl(nic->regs + FPGA_SEED),
+		GET_LINK_STATUS_LANES(pci_link_status),
+		GET_DEV_CTRL_MAXPL(pci_ctrl), GET_DEV_CTRL_MRRS(pci_ctrl));
 }
 
 static void print_fw_id(struct pci_nic *nic)
 {
-	printk(KERN_INFO "tehuti: fw 0x%x\n", readl(nic->regs + FW_VER));
+	pr_info("fw 0x%x\n", readl(nic->regs + FW_VER));
 }
 
 static void print_eth_id(struct net_device *ndev)
 {
-	printk(KERN_INFO "%s: %s, Port %c\n", ndev->name, BDX_NIC_NAME,
-	       (ndev->if_port == 0) ? 'A' : 'B');
+	netdev_info(ndev, "%s, Port %c\n",
+		    BDX_NIC_NAME, (ndev->if_port == 0) ? 'A' : 'B');
 
 }
 
@@ -160,7 +160,7 @@ bdx_fifo_init(struct bdx_priv *priv, struct fifo *f, int fsz_type,
 	f->va = pci_alloc_consistent(priv->pdev,
 				     memsz + FIFO_EXTRA_SPACE, &f->da);
 	if (!f->va) {
-		ERR("pci_alloc_consistent failed\n");
+		pr_err("pci_alloc_consistent failed\n");
 		RET(-ENOMEM);
 	}
 	f->reg_CFG0 = reg_CFG0;
@@ -204,13 +204,13 @@ static void bdx_link_changed(struct bdx_priv *priv)
 		if (netif_carrier_ok(priv->ndev)) {
 			netif_stop_queue(priv->ndev);
 			netif_carrier_off(priv->ndev);
-			ERR("%s: Link Down\n", priv->ndev->name);
+			netdev_err(priv->ndev, "Link Down\n");
 		}
 	} else {
 		if (!netif_carrier_ok(priv->ndev)) {
 			netif_wake_queue(priv->ndev);
 			netif_carrier_on(priv->ndev);
-			ERR("%s: Link Up\n", priv->ndev->name);
+			netdev_err(priv->ndev, "Link Up\n");
 		}
 	}
 }
@@ -226,10 +226,10 @@ static void bdx_isr_extra(struct bdx_priv *priv, u32 isr)
 		bdx_link_changed(priv);
 
 	if (isr & IR_PCIE_LINK)
-		ERR("%s: PCI-E Link Fault\n", priv->ndev->name);
+		netdev_err(priv->ndev, "PCI-E Link Fault\n");
 
 	if (isr & IR_PCIE_TOUT)
-		ERR("%s: PCI-E Time Out\n", priv->ndev->name);
+		netdev_err(priv->ndev, "PCI-E Time Out\n");
 
 }
 
@@ -345,7 +345,7 @@ out:
 		release_firmware(fw);
 
 	if (rc) {
-		ERR("%s: firmware loading failed\n", priv->ndev->name);
+		netdev_err(priv->ndev, "firmware loading failed\n");
 		if (rc == -EIO)
 			DBG("VPC = 0x%x VIC = 0x%x INIT_STATUS = 0x%x i=%d\n",
 			    READ_REG(priv, regVPC),
@@ -462,7 +462,7 @@ static int bdx_hw_reset_direct(void __iomem *regs)
 			readl(regs + regRXD_CFG0_0);
 			return 0;
 		}
-	ERR("tehuti: HW reset failed\n");
+	pr_err("HW reset failed\n");
 	return 1;		/* failure */
 }
 
@@ -486,7 +486,7 @@ static int bdx_hw_reset(struct bdx_priv *priv)
 			READ_REG(priv, regRXD_CFG0_0);
 			return 0;
 		}
-	ERR("tehuti: HW reset failed\n");
+	pr_err("HW reset failed\n");
 	return 1;		/* failure */
 }
 
@@ -510,8 +510,7 @@ static int bdx_sw_reset(struct bdx_priv *priv)
 		mdelay(10);
 	}
 	if (i == 50)
-		ERR("%s: SW reset timeout. continuing anyway\n",
-		    priv->ndev->name);
+		netdev_err(priv->ndev, "SW reset timeout. continuing anyway\n");
 
 	/* 6. disable intrs */
 	WRITE_REG(priv, regRDINTCM0, 0);
@@ -647,7 +646,7 @@ static int bdx_ioctl_priv(struct net_device *ndev, struct ifreq *ifr, int cmd)
 	if (cmd != SIOCDEVPRIVATE) {
 		error = copy_from_user(data, ifr->ifr_data, sizeof(data));
 		if (error) {
-			ERR("cant copy from user\n");
+			pr_err("cant copy from user\n");
 			RET(error);
 		}
 		DBG("%d 0x%x 0x%x\n", data[0], data[1], data[2]);
@@ -708,7 +707,7 @@ static void __bdx_vlan_rx_vid(struct net_device *ndev, uint16_t vid, int enable)
 	ENTER;
 	DBG2("vid=%d value=%d\n", (int)vid, enable);
 	if (unlikely(vid >= 4096)) {
-		ERR("tehuti: invalid VID: %u (> 4096)\n", vid);
+		pr_err("invalid VID: %u (> 4096)\n", vid);
 		RET();
 	}
 	reg = regVLAN_0 + (vid / 32) * 4;
@@ -776,8 +775,8 @@ static int bdx_change_mtu(struct net_device *ndev, int new_mtu)
 
 	/* enforce minimum frame size */
 	if (new_mtu < ETH_ZLEN) {
-		ERR("%s: %s mtu %d is less then minimal %d\n",
-		    BDX_DRV_NAME, ndev->name, new_mtu, ETH_ZLEN);
+		netdev_err(ndev, "mtu %d is less then minimal %d\n",
+			   new_mtu, ETH_ZLEN);
 		RET(-EINVAL);
 	}
 
@@ -1038,7 +1037,7 @@ static int bdx_rx_init(struct bdx_priv *priv)
 	return 0;
 
 err_mem:
-	ERR("%s: %s: Rx init failed\n", BDX_DRV_NAME, priv->ndev->name);
+	netdev_err(priv->ndev, "Rx init failed\n");
 	return -ENOMEM;
 }
 
@@ -1116,7 +1115,7 @@ static void bdx_rx_alloc_skbs(struct bdx_priv *priv, struct rxf_fifo *f)
 	dno = bdx_rxdb_available(db) - 1;
 	while (dno > 0) {
 		if (!(skb = dev_alloc_skb(f->m.pktsz + NET_IP_ALIGN))) {
-			ERR("NO MEM: dev_alloc_skb failed\n");
+			pr_err("NO MEM: dev_alloc_skb failed\n");
 			break;
 		}
 		skb->dev = priv->ndev;
@@ -1337,9 +1336,7 @@ static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, int budget)
 static void print_rxdd(struct rxd_desc *rxdd, u32 rxd_val1, u16 len,
 		       u16 rxd_vlan)
 {
-	DBG("ERROR: rxdd bc %d rxfq %d to %d type %d err %d rxp %d "
-	    "pkt_id %d vtag %d len %d vlan_id %d cfi %d prio %d "
-	    "va_lo %d va_hi %d\n",
+	DBG("ERROR: rxdd bc %d rxfq %d to %d type %d err %d rxp %d pkt_id %d vtag %d len %d vlan_id %d cfi %d prio %d va_lo %d va_hi %d\n",
 	    GET_RXD_BC(rxd_val1), GET_RXD_RXFQ(rxd_val1), GET_RXD_TO(rxd_val1),
 	    GET_RXD_TYPE(rxd_val1), GET_RXD_ERR(rxd_val1),
 	    GET_RXD_RXP(rxd_val1), GET_RXD_PKT_ID(rxd_val1),
@@ -1591,7 +1588,7 @@ static int bdx_tx_init(struct bdx_priv *priv)
 	return 0;
 
 err_mem:
-	ERR("tehuti: %s: Tx init failed\n", priv->ndev->name);
+	netdev_err(priv->ndev, "Tx init failed\n");
 	return -ENOMEM;
 }
 
@@ -1946,8 +1943,7 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	} else {
 		if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) ||
 		    (err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))) {
-			printk(KERN_ERR "tehuti: No usable DMA configuration"
-					", aborting\n");
+			pr_err("No usable DMA configuration, aborting\n");
 			goto err_dma;
 		}
 		pci_using_dac = 0;
@@ -1961,25 +1957,25 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pciaddr = pci_resource_start(pdev, 0);
 	if (!pciaddr) {
 		err = -EIO;
-		ERR("tehuti: no MMIO resource\n");
+		pr_err("no MMIO resource\n");
 		goto err_out_res;
 	}
 	if ((regionSize = pci_resource_len(pdev, 0)) < BDX_REGS_SIZE) {
 		err = -EIO;
-		ERR("tehuti: MMIO resource (%x) too small\n", regionSize);
+		pr_err("MMIO resource (%x) too small\n", regionSize);
 		goto err_out_res;
 	}
 
 	nic->regs = ioremap(pciaddr, regionSize);
 	if (!nic->regs) {
 		err = -EIO;
-		ERR("tehuti: ioremap failed\n");
+		pr_err("ioremap failed\n");
 		goto err_out_res;
 	}
 
 	if (pdev->irq < 2) {
 		err = -EIO;
-		ERR("tehuti: invalid irq (%d)\n", pdev->irq);
+		pr_err("invalid irq (%d)\n", pdev->irq);
 		goto err_out_iomap;
 	}
 	pci_set_drvdata(pdev, nic);
@@ -1997,7 +1993,7 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifdef BDX_MSI
 	if ((readl(nic->regs + FPGA_VER) & 0xFFF) >= 378) {
 		if ((err = pci_enable_msi(pdev)))
-			ERR("Tehuti: Can't eneble msi. error is %d\n", err);
+			pr_err("Can't eneble msi. error is %d\n", err);
 		else
 			nic->irq_type = IRQ_MSI;
 	} else
@@ -2008,7 +2004,7 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	for (port = 0; port < nic->port_num; port++) {
 		if (!(ndev = alloc_etherdev(sizeof(struct bdx_priv)))) {
 			err = -ENOMEM;
-			printk(KERN_ERR "tehuti: alloc_etherdev failed\n");
+			pr_err("alloc_etherdev failed\n");
 			goto err_out_iomap;
 		}
 
@@ -2075,12 +2071,12 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 		/*bdx_hw_reset(priv); */
 		if (bdx_read_mac(priv)) {
-			printk(KERN_ERR "tehuti: load MAC address failed\n");
+			pr_err("load MAC address failed\n");
 			goto err_out_iomap;
 		}
 		SET_NETDEV_DEV(ndev, &pdev->dev);
 		if ((err = register_netdev(ndev))) {
-			printk(KERN_ERR "tehuti: register_netdev failed\n");
+			pr_err("register_netdev failed\n");
 			goto err_out_free;
 		}
 		netif_carrier_off(ndev);
@@ -2493,10 +2489,8 @@ static struct pci_driver bdx_pci_driver = {
  */
 static void __init print_driver_id(void)
 {
-	printk(KERN_INFO "%s: %s, %s\n", BDX_DRV_NAME, BDX_DRV_DESC,
-	       BDX_DRV_VERSION);
-	printk(KERN_INFO "%s: Options: hw_csum %s\n", BDX_DRV_NAME,
-	       BDX_MSI_STRING);
+	pr_info("%s, %s\n", BDX_DRV_DESC, BDX_DRV_VERSION);
+	pr_info("Options: hw_csum %s\n", BDX_MSI_STRING);
 }
 
 static int __init bdx_module_init(void)
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index 1241419..a19dcf8 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -529,28 +529,34 @@ struct txd_desc {
 
 /* Debugging Macros */
 
-#define ERR(fmt, args...) printk(KERN_ERR fmt, ## args)
-#define DBG2(fmt, args...)	\
-	printk(KERN_ERR  "%s:%-5d: " fmt, __func__, __LINE__, ## args)
+#define DBG2(fmt, args...)					\
+	pr_err("%s:%-5d: " fmt, __func__, __LINE__, ## args)
 
 #define BDX_ASSERT(x) BUG_ON(x)
 
 #ifdef DEBUG
 
-#define ENTER          do { \
-	printk(KERN_ERR  "%s:%-5d: ENTER\n", __func__, __LINE__); \
+#define ENTER						\
+do {							\
+	pr_err("%s:%-5d: ENTER\n", __func__, __LINE__); \
 } while (0)
 
-#define RET(args...)   do { \
-	printk(KERN_ERR  "%s:%-5d: RETURN\n", __func__, __LINE__); \
-return args; } while (0)
+#define RET(args...)					 \
+do {							 \
+	pr_err("%s:%-5d: RETURN\n", __func__, __LINE__); \
+	return args;					 \
+} while (0)
 
-#define DBG(fmt, args...)	\
-	printk(KERN_ERR  "%s:%-5d: " fmt, __func__, __LINE__, ## args)
+#define DBG(fmt, args...)					\
+	pr_err("%s:%-5d: " fmt, __func__, __LINE__, ## args)
 #else
-#define ENTER         do {  } while (0)
+#define ENTER do {  } while (0)
 #define RET(args...)   return args
-#define DBG(fmt, args...)   do {  } while (0)
+#define DBG(fmt, args...)			\
+do {						\
+	if (0)					\
+		pr_err(fmt, ##args);		\
+} while (0)
 #endif
 
 #endif /* _BDX__H */
-- 
1.7.0.14.g7e948
