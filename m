From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/2 (net.git)] stmmac: add the experimental PCI support
Date: Wed, 21 Dec 2011 14:58:17 +0100
Message-ID: <1324475900-1470-1-git-send-email-peppe.cavallaro@st.com>
References: <4EF1E582.5050300@st.com>
Cc: davem@davemloft.net, rayagond@vayavyalabs.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:38971 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751422Ab1LUN6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 08:58:41 -0500
In-Reply-To: <4EF1E582.5050300@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the PCI support (as EXPERIMENTAL)
this has been also tested on XLINX XC2V3000 FF1152AMT0221
D1215994A VIRTEX FPGA board.
To support the PCI bus the main part has been reworked
and both the platform and the PCI specific parts have
been moved into different files.

Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   27 ++-
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    2 +
 drivers/net/ethernet/stmicro/stmmac/common.h       |    7 +
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |   13 +
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   13 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  440 ++++++--------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |    3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  221 ++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  217 ++++++++++
 9 files changed, 631 insertions(+), 312 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 22745d7..0364283 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -12,11 +12,36 @@ config STMMAC_ETH
 
 if STMMAC_ETH
 
+config STMMAC_PLATFORM
+	tristate "STMMAC platform bus support"
+	depends on STMMAC_ETH
+	default y
+	---help---
+	  This selects the platform specific bus support for
+	  the stmmac device driver. This is the driver used
+	  on many embedded STM platforms based on ARM and SuperH
+	  processors.
+	  If you have a controller with this interface, say Y or M here.
+
+	  If unsure, say N.
+
+config STMMAC_PCI
+	tristate "STMMAC support on PCI bus (EXPERIMENTAL)"
+	depends on STMMAC_ETH && PCI && EXPERIMENTAL
+	---help---
+	  This is to select the Synopsys DWMAC available on PCI devices,
+	  if you have a controller with this interface, say Y or M here.
+
+	  This PCI support is tested on XLINX XC2V3000 FF1152AMT0221
+	  D1215994A VIRTEX FPGA board.
+
+	  If unsure, say N.
+
 config STMMAC_DEBUG_FS
 	bool "Enable monitoring via sysFS "
 	default n
 	depends on STMMAC_ETH && DEBUG_FS
-	-- help
+	---help---
 	  The stmmac entry in /sys reports DMA TX/RX rings
 	  or (if supported) the HW cap register.
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index d7c4516..bc965ac 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -2,6 +2,8 @@ obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
 stmmac-$(CONFIG_STMMAC_RING) += ring_mode.o
 stmmac-$(CONFIG_STMMAC_CHAINED) += chain_mode.o
+stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
+stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
 	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 2cc1192..d0b814e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -22,7 +22,11 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
+#include <linux/etherdevice.h>
 #include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/module.h>
+#include <linux/init.h>
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #define STMMAC_VLAN_TAG_USED
 #include <linux/if_vlan.h>
@@ -315,5 +319,8 @@ extern void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 				unsigned int high, unsigned int low);
 extern void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 				unsigned int high, unsigned int low);
+
+extern void stmmac_set_mac(void __iomem *ioaddr, bool enable);
+
 extern void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
 extern const struct stmmac_ring_mode_ops ring_mode_ops;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index e250935..f20aa12 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -238,6 +238,19 @@ void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 	writel(data, ioaddr + low);
 }
 
+/* Enable disable MAC RX/TX */
+void stmmac_set_mac(void __iomem *ioaddr, bool enable)
+{
+	u32 value = readl(ioaddr + MAC_CTRL_REG);
+
+	if (enable)
+		value |= MAC_RNABLE_RX | MAC_ENABLE_TX;
+	else
+		value &= ~(MAC_ENABLE_TX | MAC_RNABLE_RX);
+
+	writel(value, ioaddr + MAC_CTRL_REG);
+}
+
 void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 			 unsigned int high, unsigned int low)
 {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index a140a8f..1207400 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -20,7 +20,8 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#define DRV_MODULE_VERSION	"Oct_2011"
+#define STMMAC_RESOURCE_NAME   "stmmaceth"
+#define DRV_MODULE_VERSION	"Dec_2011"
 #include <linux/stmmac.h>
 #include <linux/phy.h>
 #include "common.h"
@@ -82,8 +83,18 @@ struct stmmac_priv {
 	int hw_cap_support;
 };
 
+extern int phyaddr;
+
 extern int stmmac_mdio_unregister(struct net_device *ndev);
 extern int stmmac_mdio_register(struct net_device *ndev);
 extern void stmmac_set_ethtool_ops(struct net_device *netdev);
 extern const struct stmmac_desc_ops enh_desc_ops;
 extern const struct stmmac_desc_ops ndesc_ops;
+
+int stmmac_freeze(struct net_device *ndev);
+int stmmac_restore(struct net_device *ndev);
+int stmmac_resume(struct net_device *ndev);
+int stmmac_suspend(struct net_device *ndev);
+int stmmac_dvr_remove(struct net_device *ndev);
+struct stmmac_priv *stmmac_dvr_probe(struct device *device,
+				struct plat_stmmacenet_data *plat_dat);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 72cd190..1bb4e27 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -28,12 +28,8 @@
 	https://bugzilla.stlinux.com/
 *******************************************************************************/
 
-#include <linux/module.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/interrupt.h>
-#include <linux/etherdevice.h>
-#include <linux/platform_device.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/skbuff.h>
@@ -52,8 +48,6 @@
 #endif
 #include "stmmac.h"
 
-#define STMMAC_RESOURCE_NAME	"stmmaceth"
-
 #undef STMMAC_DEBUG
 /*#define STMMAC_DEBUG*/
 #ifdef STMMAC_DEBUG
@@ -93,7 +87,7 @@ static int debug = -1;		/* -1: default, 0: no output, 16:  all */
 module_param(debug, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(debug, "Message Level (0: no output, 16: all)");
 
-static int phyaddr = -1;
+int phyaddr = -1;
 module_param(phyaddr, int, S_IRUGO);
 MODULE_PARM_DESC(phyaddr, "Physical device address");
 
@@ -141,6 +135,11 @@ static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
 
 static irqreturn_t stmmac_interrupt(int irq, void *dev_id);
 
+#ifdef CONFIG_STMMAC_DEBUG_FS
+static int stmmac_init_fs(struct net_device *dev);
+static void stmmac_exit_fs(void);
+#endif
+
 /**
  * stmmac_verify_args - verify the driver parameters.
  * Description: it verifies if some wrong parameter is passed to the driver.
@@ -345,22 +344,6 @@ static int stmmac_init_phy(struct net_device *dev)
 	return 0;
 }
 
-static inline void stmmac_enable_mac(void __iomem *ioaddr)
-{
-	u32 value = readl(ioaddr + MAC_CTRL_REG);
-
-	value |= MAC_RNABLE_RX | MAC_ENABLE_TX;
-	writel(value, ioaddr + MAC_CTRL_REG);
-}
-
-static inline void stmmac_disable_mac(void __iomem *ioaddr)
-{
-	u32 value = readl(ioaddr + MAC_CTRL_REG);
-
-	value &= ~(MAC_ENABLE_TX | MAC_RNABLE_RX);
-	writel(value, ioaddr + MAC_CTRL_REG);
-}
-
 /**
  * display_ring
  * @p: pointer to the ring.
@@ -887,6 +870,53 @@ static int stmmac_get_hw_features(struct stmmac_priv *priv)
 }
 
 /**
+ * stmmac_mac_device_setup
+ * @dev : device pointer
+ * Description: this is to attach the GMAC or MAC 10/100
+ * main core structures that will be completed during the
+ * open step.
+ */
+static int stmmac_mac_device_setup(struct net_device *dev)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	struct mac_device_info *device;
+
+	if (priv->plat->has_gmac)
+		device = dwmac1000_setup(priv->ioaddr);
+	else
+		device = dwmac100_setup(priv->ioaddr);
+
+	if (!device)
+		return -ENOMEM;
+
+	priv->hw = device;
+	priv->hw->ring = &ring_mode_ops;
+
+	if (device_can_wakeup(priv->device)) {
+		priv->wolopts = WAKE_MAGIC; /* Magic Frame as default */
+		enable_irq_wake(priv->wol_irq);
+	}
+
+	return 0;
+}
+
+static void stmmac_check_ether_addr(struct stmmac_priv *priv)
+{
+	/* verify if the MAC address is valid, in case of failures it
+	 * generates a random MAC address */
+	if (!is_valid_ether_addr(priv->dev->dev_addr)) {
+		priv->hw->mac->get_umac_addr((void __iomem *)
+					     priv->dev->base_addr,
+					     priv->dev->dev_addr, 0);
+		if  (!is_valid_ether_addr(priv->dev->dev_addr))
+			random_ether_addr(priv->dev->dev_addr);
+	}
+	pr_warning("%s: device MAC address %pM\n", priv->dev->name,
+						   priv->dev->dev_addr);
+}
+
+/**
  *  stmmac_open - open entry point of the driver
  *  @dev : pointer to the device structure.
  *  Description:
@@ -900,18 +930,28 @@ static int stmmac_open(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	int ret;
 
-	/* Check that the MAC address is valid.  If its not, refuse
-	 * to bring the device up. The user must specify an
-	 * address using the following linux command:
-	 *      ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx  */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		random_ether_addr(dev->dev_addr);
-		pr_warning("%s: generated random MAC address %pM\n", dev->name,
-			dev->dev_addr);
-	}
+	/* MAC HW device setup */
+	ret = stmmac_mac_device_setup(dev);
+	if (ret < 0)
+		return ret;
+
+	stmmac_check_ether_addr(priv);
 
 	stmmac_verify_args();
 
+	/* Override with kernel parameters if supplied XXX CRS XXX
+	 * this needs to have multiple instances */
+	if ((phyaddr >= 0) && (phyaddr <= 31))
+		priv->plat->phy_addr = phyaddr;
+
+	/* MDIO bus Registration */
+	ret = stmmac_mdio_register(dev);
+	if (ret < 0) {
+		pr_debug("%s: MDIO bus (id: %d) registration failed",
+			 __func__, priv->plat->bus_id);
+		return ret;
+	}
+
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
 	if (unlikely(priv->tm == NULL)) {
@@ -1008,7 +1048,7 @@ static int stmmac_open(struct net_device *dev)
 	}
 
 	/* Enable the MAC Rx/Tx */
-	stmmac_enable_mac(priv->ioaddr);
+	stmmac_set_mac(priv->ioaddr, true);
 
 	/* Set the HW DMA mode and the COE */
 	stmmac_dma_operation_mode(priv);
@@ -1019,6 +1059,11 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_mmc_setup(priv);
 
+#ifdef CONFIG_STMMAC_DEBUG_FS
+	ret = stmmac_init_fs(dev);
+	if (ret < 0)
+		pr_warning("\tFailed debugFS registration");
+#endif
 	/* Start the ball rolling... */
 	DBG(probe, DEBUG, "%s: DMA RX/TX processes started...\n", dev->name);
 	priv->hw->dma->start_tx(priv->ioaddr);
@@ -1091,10 +1136,15 @@ static int stmmac_release(struct net_device *dev)
 	free_dma_desc_resources(priv);
 
 	/* Disable the MAC Rx/Tx */
-	stmmac_disable_mac(priv->ioaddr);
+	stmmac_set_mac(priv->ioaddr, false);
 
 	netif_carrier_off(dev);
 
+#ifdef CONFIG_STMMAC_DEBUG_FS
+	stmmac_exit_fs();
+#endif
+	stmmac_mdio_unregister(dev);
+
 	return 0;
 }
 
@@ -1738,28 +1788,41 @@ static const struct net_device_ops stmmac_netdev_ops = {
 };
 
 /**
- * stmmac_probe - Initialization of the adapter .
- * @dev : device pointer
- * Description: The function initializes the network device structure for
- * the STMMAC driver. It also calls the low level routines
- * in order to init the HW (i.e. the DMA engine)
+ * stmmac_dvr_probe
+ * @device: device pointer
+ * Description: this is the main probe function used to
+ * call the alloc_etherdev, allocate the priv structure.
  */
-static int stmmac_probe(struct net_device *dev)
+struct stmmac_priv *stmmac_dvr_probe(struct device *device,
+					struct plat_stmmacenet_data *plat_dat)
 {
 	int ret = 0;
-	struct stmmac_priv *priv = netdev_priv(dev);
+	struct net_device *ndev = NULL;
+	struct stmmac_priv *priv;
+
+	ndev = alloc_etherdev(sizeof(struct stmmac_priv));
+	if (!ndev) {
+		pr_err("%s: ERROR: allocating the device\n", __func__);
+		return NULL;
+	}
+
+	SET_NETDEV_DEV(ndev, device);
 
-	ether_setup(dev);
+	priv = netdev_priv(ndev);
+	priv->device = device;
+	priv->dev = ndev;
 
-	dev->netdev_ops = &stmmac_netdev_ops;
-	stmmac_set_ethtool_ops(dev);
+	ether_setup(ndev);
 
-	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-	dev->features |= dev->hw_features | NETIF_F_HIGHDMA;
-	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
+	ndev->netdev_ops = &stmmac_netdev_ops;
+	stmmac_set_ethtool_ops(ndev);
+
+	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
+	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 #ifdef STMMAC_VLAN_TAG_USED
 	/* Both mac100 and gmac support receive VLAN tag detection */
-	dev->features |= NETIF_F_HW_VLAN_RX;
+	ndev->features |= NETIF_F_HW_VLAN_RX;
 #endif
 	priv->msg_enable = netif_msg_init(debug, default_msg_level);
 
@@ -1767,248 +1830,60 @@ static int stmmac_probe(struct net_device *dev)
 		priv->flow_ctrl = FLOW_AUTO;	/* RX/TX pause on */
 
 	priv->pause = pause;
-	netif_napi_add(dev, &priv->napi, stmmac_poll, 64);
-
-	/* Get the MAC address */
-	priv->hw->mac->get_umac_addr((void __iomem *) dev->base_addr,
-				     dev->dev_addr, 0);
-
-	if (!is_valid_ether_addr(dev->dev_addr))
-		pr_warning("\tno valid MAC address;"
-			"please, use ifconfig or nwhwconfig!\n");
+	priv->plat = plat_dat;
+	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
 
 	spin_lock_init(&priv->lock);
 	spin_lock_init(&priv->tx_lock);
 
-	ret = register_netdev(dev);
+	ret = register_netdev(ndev);
 	if (ret) {
 		pr_err("%s: ERROR %i registering the device\n",
 		       __func__, ret);
-		return -ENODEV;
+		goto error;
 	}
 
 	DBG(probe, DEBUG, "%s: Scatter/Gather: %s - HW checksums: %s\n",
-	    dev->name, (dev->features & NETIF_F_SG) ? "on" : "off",
-	    (dev->features & NETIF_F_IP_CSUM) ? "on" : "off");
-
-	return ret;
-}
-
-/**
- * stmmac_mac_device_setup
- * @dev : device pointer
- * Description: select and initialise the mac device (mac100 or Gmac).
- */
-static int stmmac_mac_device_setup(struct net_device *dev)
-{
-	struct stmmac_priv *priv = netdev_priv(dev);
-
-	struct mac_device_info *device;
-
-	if (priv->plat->has_gmac) {
-		dev->priv_flags |= IFF_UNICAST_FLT;
-		device = dwmac1000_setup(priv->ioaddr);
-	} else {
-		device = dwmac100_setup(priv->ioaddr);
-	}
+	    ndev->name, (ndev->features & NETIF_F_SG) ? "on" : "off",
+	    (ndev->features & NETIF_F_IP_CSUM) ? "on" : "off");
 
-	if (!device)
-		return -ENOMEM;
-
-	priv->hw = device;
-	priv->hw->ring = &ring_mode_ops;
-
-	if (device_can_wakeup(priv->device)) {
-		priv->wolopts = WAKE_MAGIC; /* Magic Frame as default */
-		enable_irq_wake(priv->wol_irq);
-	}
-
-	return 0;
-}
-
-/**
- * stmmac_dvr_probe
- * @pdev: platform device pointer
- * Description: the driver is initialized through platform_device.
- */
-static int stmmac_dvr_probe(struct platform_device *pdev)
-{
-	int ret = 0;
-	struct resource *res;
-	void __iomem *addr = NULL;
-	struct net_device *ndev = NULL;
-	struct stmmac_priv *priv = NULL;
-	struct plat_stmmacenet_data *plat_dat;
-
-	pr_info("STMMAC driver:\n\tplatform registration... ");
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!res)
-		return -ENODEV;
-	pr_info("\tdone!\n");
-
-	if (!request_mem_region(res->start, resource_size(res),
-				pdev->name)) {
-		pr_err("%s: ERROR: memory allocation failed"
-		       "cannot get the I/O addr 0x%x\n",
-		       __func__, (unsigned int)res->start);
-		return -EBUSY;
-	}
-
-	addr = ioremap(res->start, resource_size(res));
-	if (!addr) {
-		pr_err("%s: ERROR: memory mapping failed\n", __func__);
-		ret = -ENOMEM;
-		goto out_release_region;
-	}
-
-	ndev = alloc_etherdev(sizeof(struct stmmac_priv));
-	if (!ndev) {
-		pr_err("%s: ERROR: allocating the device\n", __func__);
-		ret = -ENOMEM;
-		goto out_unmap;
-	}
-
-	SET_NETDEV_DEV(ndev, &pdev->dev);
-
-	/* Get the MAC information */
-	ndev->irq = platform_get_irq_byname(pdev, "macirq");
-	if (ndev->irq == -ENXIO) {
-		pr_err("%s: ERROR: MAC IRQ configuration "
-		       "information not found\n", __func__);
-		ret = -ENXIO;
-		goto out_free_ndev;
-	}
-
-	priv = netdev_priv(ndev);
-	priv->device = &(pdev->dev);
-	priv->dev = ndev;
-	plat_dat = pdev->dev.platform_data;
-
-	priv->plat = plat_dat;
-
-	priv->ioaddr = addr;
-
-	/*
-	 * On some platforms e.g. SPEAr the wake up irq differs from the mac irq
-	 * The external wake up irq can be passed through the platform code
-	 * named as "eth_wake_irq"
-	 *
-	 * In case the wake up interrupt is not passed from the platform
-	 * so the driver will continue to use the mac irq (ndev->irq)
-	 */
-	priv->wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
-	if (priv->wol_irq == -ENXIO)
-		priv->wol_irq = ndev->irq;
-
-	platform_set_drvdata(pdev, ndev);
-
-	/* Set the I/O base addr */
-	ndev->base_addr = (unsigned long)addr;
-
-	/* Custom initialisation */
-	if (priv->plat->init) {
-		ret = priv->plat->init(pdev);
-		if (unlikely(ret))
-			goto out_free_ndev;
-	}
-
-	/* MAC HW device detection */
-	ret = stmmac_mac_device_setup(ndev);
-	if (ret < 0)
-		goto out_plat_exit;
+	return priv;
 
-	/* Network Device Registration */
-	ret = stmmac_probe(ndev);
-	if (ret < 0)
-		goto out_plat_exit;
-
-	/* Override with kernel parameters if supplied XXX CRS XXX
-	 * this needs to have multiple instances */
-	if ((phyaddr >= 0) && (phyaddr <= 31))
-		priv->plat->phy_addr = phyaddr;
-
-	pr_info("\t%s - (dev. name: %s - id: %d, IRQ #%d\n"
-	       "\tIO base addr: 0x%p)\n", ndev->name, pdev->name,
-	       pdev->id, ndev->irq, addr);
+error:
+	netif_napi_del(&priv->napi);
 
-	/* MDIO bus Registration */
-	pr_debug("\tMDIO bus (id: %d)...", priv->plat->bus_id);
-	ret = stmmac_mdio_register(ndev);
-	if (ret < 0)
-		goto out_unregister;
-	pr_debug("registered!\n");
-
-#ifdef CONFIG_STMMAC_DEBUG_FS
-	ret = stmmac_init_fs(ndev);
-	if (ret < 0)
-		pr_warning("\tFailed debugFS registration");
-#endif
-
-	return 0;
-
-out_unregister:
 	unregister_netdev(ndev);
-out_plat_exit:
-	if (priv->plat->exit)
-		priv->plat->exit(pdev);
-out_free_ndev:
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
-out_unmap:
-	iounmap(addr);
-out_release_region:
-	release_mem_region(res->start, resource_size(res));
 
-	return ret;
+	return NULL;
 }
 
 /**
  * stmmac_dvr_remove
- * @pdev: platform device pointer
+ * @ndev: net device pointer
  * Description: this function resets the TX/RX processes, disables the MAC RX/TX
- * changes the link status, releases the DMA descriptor rings,
- * unregisters the MDIO bus and unmaps the allocated memory.
+ * changes the link status, releases the DMA descriptor rings.
  */
-static int stmmac_dvr_remove(struct platform_device *pdev)
+int stmmac_dvr_remove(struct net_device *ndev)
 {
-	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
-	struct resource *res;
 
 	pr_info("%s:\n\tremoving driver", __func__);
 
 	priv->hw->dma->stop_rx(priv->ioaddr);
 	priv->hw->dma->stop_tx(priv->ioaddr);
 
-	stmmac_disable_mac(priv->ioaddr);
-
+	stmmac_set_mac(priv->ioaddr, false);
 	netif_carrier_off(ndev);
-
-	stmmac_mdio_unregister(ndev);
-
-	if (priv->plat->exit)
-		priv->plat->exit(pdev);
-
-	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(ndev);
-
-	iounmap((void *)priv->ioaddr);
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(res->start, resource_size(res));
-
-#ifdef CONFIG_STMMAC_DEBUG_FS
-	stmmac_exit_fs();
-#endif
-
 	free_netdev(ndev);
 
 	return 0;
 }
 
 #ifdef CONFIG_PM
-static int stmmac_suspend(struct device *dev)
+int stmmac_suspend(struct net_device *ndev)
 {
-	struct net_device *ndev = dev_get_drvdata(dev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	int dis_ic = 0;
 
@@ -2042,15 +1917,14 @@ static int stmmac_suspend(struct device *dev)
 	if (device_may_wakeup(priv->device))
 		priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
 	else
-		stmmac_disable_mac(priv->ioaddr);
+		stmmac_set_mac(priv->ioaddr, false);
 
 	spin_unlock(&priv->lock);
 	return 0;
 }
 
-static int stmmac_resume(struct device *dev)
+int stmmac_resume(struct net_device *ndev)
 {
-	struct net_device *ndev = dev_get_drvdata(dev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
 
 	if (!netif_running(ndev))
@@ -2069,7 +1943,7 @@ static int stmmac_resume(struct device *dev)
 	netif_device_attach(ndev);
 
 	/* Enable the MAC and DMA */
-	stmmac_enable_mac(priv->ioaddr);
+	stmmac_set_mac(priv->ioaddr, true);
 	priv->hw->dma->start_tx(priv->ioaddr);
 	priv->hw->dma->start_rx(priv->ioaddr);
 
@@ -2089,68 +1963,23 @@ static int stmmac_resume(struct device *dev)
 	return 0;
 }
 
-static int stmmac_freeze(struct device *dev)
+int stmmac_freeze(struct net_device *ndev)
 {
-	struct net_device *ndev = dev_get_drvdata(dev);
-
 	if (!ndev || !netif_running(ndev))
 		return 0;
 
 	return stmmac_release(ndev);
 }
 
-static int stmmac_restore(struct device *dev)
+int stmmac_restore(struct net_device *ndev)
 {
-	struct net_device *ndev = dev_get_drvdata(dev);
-
 	if (!ndev || !netif_running(ndev))
 		return 0;
 
 	return stmmac_open(ndev);
 }
-
-static const struct dev_pm_ops stmmac_pm_ops = {
-	.suspend = stmmac_suspend,
-	.resume = stmmac_resume,
-	.freeze = stmmac_freeze,
-	.thaw = stmmac_restore,
-	.restore = stmmac_restore,
-};
-#else
-static const struct dev_pm_ops stmmac_pm_ops;
 #endif /* CONFIG_PM */
 
-static struct platform_driver stmmac_driver = {
-	.probe = stmmac_dvr_probe,
-	.remove = stmmac_dvr_remove,
-	.driver = {
-		.name = STMMAC_RESOURCE_NAME,
-		.owner = THIS_MODULE,
-		.pm = &stmmac_pm_ops,
-	},
-};
-
-/**
- * stmmac_init_module - Entry point for the driver
- * Description: This function is the entry point for the driver.
- */
-static int __init stmmac_init_module(void)
-{
-	int ret;
-
-	ret = platform_driver_register(&stmmac_driver);
-	return ret;
-}
-
-/**
- * stmmac_cleanup_module - Cleanup routine for the driver
- * Description: This function is the cleanup routine for the driver.
- */
-static void __exit stmmac_cleanup_module(void)
-{
-	platform_driver_unregister(&stmmac_driver);
-}
-
 #ifndef MODULE
 static int __init stmmac_cmdline_opt(char *str)
 {
@@ -2209,10 +2038,3 @@ err:
 
 __setup("stmmaceth=", stmmac_cmdline_opt);
 #endif
-
-module_init(stmmac_init_module);
-module_exit(stmmac_cleanup_module);
-
-MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet driver");
-MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
-MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 9c3b9d5..51f4412 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -109,6 +109,7 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
  */
 static int stmmac_mdio_reset(struct mii_bus *bus)
 {
+#if defined(CONFIG_STMMAC_PLATFORM)
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned int mii_address = priv->hw->mii.addr;
@@ -123,7 +124,7 @@ static int stmmac_mdio_reset(struct mii_bus *bus)
 	 * on MDC, so perform a dummy mdio read.
 	 */
 	writel(0, priv->ioaddr + mii_address);
-
+#endif
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
new file mode 100644
index 0000000..54a819a
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -0,0 +1,221 @@
+/*******************************************************************************
+  This contains the functions to handle the pci driver.
+
+  Copyright (C) 2011-2012  Vayavya Labs Pvt Ltd
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Author: Rayagond Kokatanur <rayagond@vayavyalabs.com>
+  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+*******************************************************************************/
+
+#include <linux/pci.h>
+#include "stmmac.h"
+
+struct plat_stmmacenet_data plat_dat;
+struct stmmac_mdio_bus_data mdio_data;
+
+static void stmmac_default_data(void)
+{
+	memset(&plat_dat, 0, sizeof(struct plat_stmmacenet_data));
+	plat_dat.bus_id = 1;
+	plat_dat.phy_addr = 0;
+	plat_dat.interface = PHY_INTERFACE_MODE_GMII;
+	plat_dat.pbl = 32;
+	plat_dat.clk_csr = 2;	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
+	plat_dat.has_gmac = 1;
+	plat_dat.force_sf_dma_mode = 1;
+
+	mdio_data.bus_id = 1;
+	mdio_data.phy_reset = NULL;
+	mdio_data.phy_mask = 0;
+	plat_dat.mdio_bus_data = &mdio_data;
+}
+
+/**
+ * stmmac_pci_probe
+ *
+ * @pdev: pci device pointer
+ * @id: pointer to table of device id/id's.
+ *
+ * Description: This probing function gets called for all PCI devices which
+ * match the ID table and are not "owned" by other driver yet. This function
+ * gets passed a "struct pci_dev *" for each device whose entry in the ID table
+ * matches the device. The probe functions returns zero when the driver choose
+ * to take "ownership" of the device or an error code(-ve no) otherwise.
+ */
+static int __devinit stmmac_pci_probe(struct pci_dev *pdev,
+				      const struct pci_device_id *id)
+{
+	int ret = 0;
+	void __iomem *addr = NULL;
+	struct stmmac_priv *priv = NULL;
+	int i;
+
+	/* Enable pci device */
+	ret = pci_enable_device(pdev);
+	if (ret) {
+		pr_err("%s : ERROR: failed to enable %s device\n", __func__,
+		       pci_name(pdev));
+		return ret;
+	}
+	if (pci_request_regions(pdev, STMMAC_RESOURCE_NAME)) {
+		pr_err("%s: ERROR: failed to get PCI region\n", __func__);
+		ret = -ENODEV;
+		goto err_out_req_reg_failed;
+	}
+
+	/* Get the base address of device */
+	for (i = 0; i <= 5; i++) {
+		if (pci_resource_len(pdev, i) == 0)
+			continue;
+		addr = pci_iomap(pdev, i, 0);
+		if (addr == NULL) {
+			pr_err("%s: ERROR: cannot map regiser memory, aborting",
+			       __func__);
+			ret = -EIO;
+			goto err_out_map_failed;
+		}
+		break;
+	}
+	pci_set_master(pdev);
+
+	stmmac_default_data();
+
+	priv = stmmac_dvr_probe(&(pdev->dev), &plat_dat);
+	if (!priv) {
+		pr_err("%s: main drivr probe failed", __func__);
+		goto err_out;
+	}
+	priv->ioaddr = addr;
+	priv->dev->base_addr = (unsigned long)addr;
+	priv->dev->irq = pdev->irq;
+	priv->wol_irq = pdev->irq;
+
+	pci_set_drvdata(pdev, priv->dev);
+
+	pr_debug("STMMAC platform driver registration completed");
+
+	return 0;
+
+err_out:
+	pci_clear_master(pdev);
+err_out_map_failed:
+	pci_release_regions(pdev);
+err_out_req_reg_failed:
+	pci_disable_device(pdev);
+
+	return ret;
+}
+
+/**
+ * stmmac_dvr_remove
+ *
+ * @pdev: platform device pointer
+ * Description: this function calls the main to free the net resources
+ * and releases the PCI resources.
+ */
+static void __devexit stmmac_pci_remove(struct pci_dev *pdev)
+{
+	struct net_device *ndev = pci_get_drvdata(pdev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+
+	stmmac_dvr_remove(ndev);
+
+	pci_set_drvdata(pdev, NULL);
+	pci_iounmap(pdev, priv->ioaddr);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+}
+
+#ifdef CONFIG_PM
+static int stmmac_pci_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *ndev = pci_get_drvdata(pdev);
+	int ret;
+
+	ret = stmmac_suspend(ndev);
+	pci_save_state(pdev);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+
+	return ret;
+}
+
+static int stmmac_pci_resume(struct pci_dev *pdev)
+{
+	struct net_device *ndev = pci_get_drvdata(pdev);
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+
+	return stmmac_resume(ndev);
+}
+#endif
+
+#define STMMAC_VENDOR_ID 0x700
+#define STMMAC_DEVICE_ID 0x1108
+
+static DEFINE_PCI_DEVICE_TABLE(stmmac_id_table) = {
+	{
+	PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID)}, {
+	}
+};
+
+MODULE_DEVICE_TABLE(pci, stmmac_id_table);
+
+static struct pci_driver stmmac_driver = {
+	.name = STMMAC_RESOURCE_NAME,
+	.id_table = stmmac_id_table,
+	.probe = stmmac_pci_probe,
+	.remove = __devexit_p(stmmac_pci_remove),
+#ifdef CONFIG_PM
+	.suspend = stmmac_pci_suspend,
+	.resume = stmmac_pci_resume,
+#endif
+};
+
+/**
+ * stmmac_init_module - Entry point for the driver
+ * Description: This function is the entry point for the driver.
+ */
+static int __init stmmac_init_module(void)
+{
+	int ret;
+
+	ret = pci_register_driver(&stmmac_driver);
+	if (ret < 0)
+		pr_err("%s: ERROR: driver registration failed\n", __func__);
+
+	return ret;
+}
+
+/**
+ * stmmac_cleanup_module - Cleanup routine for the driver
+ * Description: This function is the cleanup routine for the driver.
+ */
+static void __exit stmmac_cleanup_module(void)
+{
+	pci_unregister_driver(&stmmac_driver);
+}
+
+module_init(stmmac_init_module);
+module_exit(stmmac_cleanup_module);
+
+MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet PCI driver");
+MODULE_AUTHOR("Rayagond Kokatanur <rayagond.kokatanur@vayavyalabs.com>");
+MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
new file mode 100644
index 0000000..54d391c
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -0,0 +1,217 @@
+/*******************************************************************************
+  This contains the functions to handle the platform driver.
+
+  Copyright (C) 2007-2011  STMicroelectronics Ltd
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+*******************************************************************************/
+
+#include <linux/platform_device.h>
+#include <linux/io.h>
+#include "stmmac.h"
+
+/**
+ * stmmac_pltfr_probe
+ * @pdev: platform device pointer
+ * Description: platform_device probe function. It allocates
+ * the necessary resources and invokes the main to init
+ * the net device, register the mdio bus etc.
+ */
+static int stmmac_pltfr_probe(struct platform_device *pdev)
+{
+	int ret = 0;
+	struct resource *res;
+	void __iomem *addr = NULL;
+	struct stmmac_priv *priv = NULL;
+	struct plat_stmmacenet_data *plat_dat;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res)
+		return -ENODEV;
+
+	if (!request_mem_region(res->start, resource_size(res), pdev->name)) {
+		pr_err("%s: ERROR: memory allocation failed"
+		       "cannot get the I/O addr 0x%x\n",
+		       __func__, (unsigned int)res->start);
+		return -EBUSY;
+	}
+
+	addr = ioremap(res->start, resource_size(res));
+	if (!addr) {
+		pr_err("%s: ERROR: memory mapping failed", __func__);
+		ret = -ENOMEM;
+		goto out_release_region;
+	}
+	plat_dat = pdev->dev.platform_data;
+	priv = stmmac_dvr_probe(&(pdev->dev), plat_dat);
+	if (!priv) {
+		pr_err("%s: main drivr probe failed", __func__);
+		goto out_release_region;
+	}
+
+	priv->ioaddr = addr;
+	/* Set the I/O base addr */
+	priv->dev->base_addr = (unsigned long)addr;
+
+	/* Get the MAC information */
+	priv->dev->irq = platform_get_irq_byname(pdev, "macirq");
+	if (priv->dev->irq == -ENXIO) {
+		pr_err("%s: ERROR: MAC IRQ configuration "
+		       "information not found\n", __func__);
+		ret = -ENXIO;
+		goto out_unmap;
+	}
+
+	/*
+	 * On some platforms e.g. SPEAr the wake up irq differs from the mac irq
+	 * The external wake up irq can be passed through the platform code
+	 * named as "eth_wake_irq"
+	 *
+	 * In case the wake up interrupt is not passed from the platform
+	 * so the driver will continue to use the mac irq (ndev->irq)
+	 */
+	priv->wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
+	if (priv->wol_irq == -ENXIO)
+		priv->wol_irq = priv->dev->irq;
+
+	platform_set_drvdata(pdev, priv->dev);
+
+	/* Custom initialisation */
+	if (priv->plat->init) {
+		ret = priv->plat->init(pdev);
+		if (unlikely(ret))
+			goto out_unmap;
+	}
+
+	pr_debug("STMMAC platform driver registration completed");
+
+	return 0;
+
+out_unmap:
+	iounmap(addr);
+	platform_set_drvdata(pdev, NULL);
+
+out_release_region:
+	release_mem_region(res->start, resource_size(res));
+
+	return ret;
+}
+
+/**
+ * stmmac_pltfr_remove
+ * @pdev: platform device pointer
+ * Description: this function calls the main to free the net resources
+ * and calls the platforms hook and release the resources (e.g. mem).
+ */
+static int stmmac_pltfr_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	struct resource *res;
+	int ret = stmmac_dvr_remove(ndev);
+
+	if (priv->plat->exit)
+		priv->plat->exit(pdev);
+
+	if (priv->plat->exit)
+		priv->plat->exit(pdev);
+
+	platform_set_drvdata(pdev, NULL);
+
+	iounmap((void *)priv->ioaddr);
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	release_mem_region(res->start, resource_size(res));
+
+	return ret;
+}
+
+#ifdef CONFIG_PM
+static int stmmac_pltfr_suspend(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	return stmmac_suspend(ndev);
+}
+
+static int stmmac_pltfr_resume(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	return stmmac_resume(ndev);
+}
+
+int stmmac_pltfr_freeze(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	return stmmac_freeze(ndev);
+}
+
+int stmmac_pltfr_restore(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	return stmmac_restore(ndev);
+}
+
+static const struct dev_pm_ops stmmac_pltfr_pm_ops = {
+	.suspend = stmmac_pltfr_suspend,
+	.resume = stmmac_pltfr_resume,
+	.freeze = stmmac_pltfr_freeze,
+	.thaw = stmmac_pltfr_restore,
+	.restore = stmmac_pltfr_restore,
+};
+#else
+static const struct dev_pm_ops stmmac_pltfr_pm_ops;
+#endif /* CONFIG_PM */
+
+static struct platform_driver stmmac_driver = {
+	.probe = stmmac_pltfr_probe,
+	.remove = stmmac_pltfr_remove,
+	.driver = {
+		   .name = STMMAC_RESOURCE_NAME,
+		   .owner = THIS_MODULE,
+		   .pm = &stmmac_pltfr_pm_ops,
+		   },
+};
+
+/**
+ * stmmac_init_module - Entry point for the driver
+ * Description: This function is the entry point for the driver.
+ */
+static int __init stmmac_init_module(void)
+{
+	return platform_driver_register(&stmmac_driver);
+}
+
+/**
+ * stmmac_cleanup_module - Cleanup routine for the driver
+ * Description: This function is the cleanup routine for the driver.
+ */
+static void __exit stmmac_cleanup_module(void)
+{
+	platform_driver_unregister(&stmmac_driver);
+}
+
+module_init(stmmac_init_module);
+module_exit(stmmac_cleanup_module);
+
+MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet PLATFORM driver");
+MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
+MODULE_LICENSE("GPL");
-- 
1.7.4.4
