From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates .27
Date: Fri, 30 May 2008 22:26:52 -0400
Message-ID: <20080531022651.GA3078@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:57298 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753745AbYEaC0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:26:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next

to receive the following updates:

 Documentation/powerpc/booting-without-of.txt |   21 +
 drivers/net/Kconfig                          |    4 +-
 drivers/net/forcedeth.c                      |   61 +-
 drivers/net/fs_enet/fs_enet-main.c           |   31 +-
 drivers/net/myri10ge/myri10ge.c              | 1076 ++++++++++++++++++++------
 drivers/net/ns83820.c                        |    9 +-
 drivers/net/phy/Kconfig                      |    6 +
 drivers/net/phy/Makefile                     |    1 +
 drivers/net/phy/mdio-ofgpio.c                |  205 +++++
 drivers/net/ps3_gelic_net.c                  |   10 +-
 drivers/net/ps3_gelic_net.h                  |    2 +-
 drivers/net/ps3_gelic_wireless.c             |   40 +-
 drivers/net/ps3_gelic_wireless.h             |    4 +-
 drivers/net/s2io.c                           |    2 +-
 drivers/net/sfc/Kconfig                      |    2 +
 drivers/net/sfc/Makefile                     |    2 +-
 drivers/net/sfc/boards.c                     |    2 +-
 drivers/net/sfc/boards.h                     |    3 +-
 drivers/net/sfc/efx.c                        |    2 +
 drivers/net/sfc/falcon.c                     |   74 ++-
 drivers/net/sfc/i2c-direct.c                 |  381 ---------
 drivers/net/sfc/i2c-direct.h                 |   91 ---
 drivers/net/sfc/net_driver.h                 |   11 +-
 drivers/net/sfc/sfe4001.c                    |  126 ++--
 drivers/net/sky2.c                           |  173 ++++-
 drivers/net/sky2.h                           |   23 +-
 drivers/net/tlan.c                           |  490 ++++++------
 drivers/net/tlan.h                           |   26 +-
 drivers/net/tsi108_eth.c                     |    6 +-
 29 files changed, 1749 insertions(+), 1135 deletions(-)
 create mode 100644 drivers/net/phy/mdio-ofgpio.c
 delete mode 100644 drivers/net/sfc/i2c-direct.c
 delete mode 100644 drivers/net/sfc/i2c-direct.h

Ben Hutchings (2):
      sfc: Use kernel I2C system and i2c-algo-bit driver
      sfc: Reduce I2C udelay to 5 resulting in a clock frequency of 100 kHz

Brice Goglin (3):
      myri10ge: add routines for multislices
      myri10ge: add multislices support
      myri10ge: add Direct Cache Access support

Daniel Walker (3):
      ps3: gelic: scan_lock semaphore to mutex
      ps3: gelic: assoc_stat_lock semaphore to mutex
      ps3: gelic: updown_lock semaphore to mutex

Laurent Pinchart (2):
      net: OpenFirmware GPIO based MDIO bitbang driver
      fs_enet: MDIO on GPIO support

Marcin Slusarz (1):
      net/s2io: set_rxd_buffer_pointer returns -ENOMEM, not ENOMEM

Randy Dunlap (1):
      cxgb3: fix build error when INET=n

Stephen Hemminger (12):
      tlan: get rid of padding buffer
      tlan: use netdevice stats
      tlan: remove unused devName field
      tlan: 64bit conversion
      tlan: manage rx allocation failure better
      tlan: proper shared IRQ support
      tlan: wrap source lines
      sky2: split phy power into two functions
      sky2: put PHY in sleep when down
      sky2: pci power savings
      ts108: use netdev_alloc_skb
      ns8320: use netdev_alloc_skb

Tobias Diedrich (3):
      [netdrvr] forcedeth: setup wake-on-lan before shutting down
      [netdrvr] forcedeth: save/restore device configuration space
      [netdrvr] forcedeth: reorder suspend/resume code

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index 1d2a772..46a9dba 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -58,6 +58,7 @@ Table of Contents
       o) Xilinx IP cores
       p) Freescale Synchronous Serial Interface
 	  q) USB EHCI controllers
+      r) MDIO on GPIOs
 
   VII - Marvell Discovery mv64[345]6x System Controller chips
     1) The /system-controller node
@@ -2870,6 +2871,26 @@ platforms are moved over to use the flattened-device-tree model.
 		reg = <0xe8000000 32>;
 	};
 
+   r) MDIO on GPIOs
+
+   Currently defined compatibles:
+   - virtual,gpio-mdio
+
+   MDC and MDIO lines connected to GPIO controllers are listed in the
+   gpios property as described in section VIII.1 in the following order:
+
+   MDC, MDIO.
+
+   Example:
+
+	mdio {
+		compatible = "virtual,mdio-gpio";
+		#address-cells = <1>;
+		#size-cells = <0>;
+		gpios = <&qe_pio_a 11
+			 &qe_pio_c 6>;
+	};
+
 VII - Marvell Discovery mv64[345]6x System Controller chips
 ===========================================================
 
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8178a4d..d415d81 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1670,7 +1670,7 @@ config SUNDANCE_MMIO
 
 config TLAN
 	tristate "TI ThunderLAN support"
-	depends on NET_PCI && (PCI || EISA) && !64BIT
+	depends on NET_PCI && (PCI || EISA)
 	---help---
 	  If you have a PCI Ethernet network card based on the ThunderLAN chip
 	  which is supported by this driver, say Y and read the
@@ -2408,7 +2408,7 @@ config CHELSIO_T1_NAPI
 
 config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
-	depends on PCI
+	depends on PCI && INET
 	select FW_LOADER
 	select INET_LRO
 	help
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 9eca97f..e4d6978 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -426,6 +426,7 @@ union ring_type {
 #define NV_PCI_REGSZ_VER1      	0x270
 #define NV_PCI_REGSZ_VER2      	0x2d4
 #define NV_PCI_REGSZ_VER3      	0x604
+#define NV_PCI_REGSZ_MAX       	0x604
 
 /* various timeout delays: all in usec */
 #define NV_TXRX_RESET_DELAY	4
@@ -784,6 +785,9 @@ struct fe_priv {
 
 	/* flow control */
 	u32 pause_flags;
+
+	/* power saved state */
+	u32 saved_config_space[NV_PCI_REGSZ_MAX/4];
 };
 
 /*
@@ -5785,50 +5789,66 @@ static int nv_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+	int i;
 
-	if (!netif_running(dev))
-		goto out;
-
+	if (netif_running(dev)) {
+		// Gross.
+		nv_close(dev);
+	}
 	netif_device_detach(dev);
 
-	// Gross.
-	nv_close(dev);
+	/* save non-pci configuration space */
+	for (i = 0;i <= np->register_size/sizeof(u32); i++)
+		np->saved_config_space[i] = readl(base + i*sizeof(u32));
 
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), np->wolenabled);
+	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-out:
 	return 0;
 }
 
 static int nv_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	int rc = 0;
-	u32 txreg;
-
-	if (!netif_running(dev))
-		goto out;
-
-	netif_device_attach(dev);
+	int i, rc = 0;
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	/* ack any pending wake events, disable PME */
 	pci_enable_wake(pdev, PCI_D0, 0);
 
-	/* restore mac address reverse flag */
-	txreg = readl(base + NvRegTransmitPoll);
-	txreg |= NVREG_TRANSMITPOLL_MAC_ADDR_REV;
-	writel(txreg, base + NvRegTransmitPoll);
+	/* restore non-pci configuration space */
+	for (i = 0;i <= np->register_size/sizeof(u32); i++)
+		writel(np->saved_config_space[i], base+i*sizeof(u32));
 
-	rc = nv_open(dev);
-	nv_set_multicast(dev);
-out:
+	netif_device_attach(dev);
+	if (netif_running(dev)) {
+		rc = nv_open(dev);
+		nv_set_multicast(dev);
+	}
 	return rc;
 }
+
+static void nv_shutdown(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct fe_priv *np = netdev_priv(dev);
+
+	if (netif_running(dev))
+		nv_close(dev);
+
+	pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
+	pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
+}
 #else
 #define nv_suspend NULL
+#define nv_shutdown NULL
 #define nv_resume NULL
 #endif /* CONFIG_PM */
 
@@ -5999,6 +6019,7 @@ static struct pci_driver driver = {
 	.remove		= __devexit_p(nv_remove),
 	.suspend	= nv_suspend,
 	.resume		= nv_resume,
+	.shutdown	= nv_shutdown,
 };
 
 static int __init init_nic(void)
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a5baaf5..fb7c477 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -43,6 +43,7 @@
 #include <asm/uaccess.h>
 
 #ifdef CONFIG_PPC_CPM_NEW_BINDING
+#include <linux/of_gpio.h>
 #include <asm/of_platform.h>
 #endif
 
@@ -1172,8 +1173,7 @@ static int __devinit find_phy(struct device_node *np,
                               struct fs_platform_info *fpi)
 {
 	struct device_node *phynode, *mdionode;
-	struct resource res;
-	int ret = 0, len;
+	int ret = 0, len, bus_id;
 	const u32 *data;
 
 	data  = of_get_property(np, "fixed-link", NULL);
@@ -1190,19 +1190,28 @@ static int __devinit find_phy(struct device_node *np,
 	if (!phynode)
 		return -EINVAL;
 
-	mdionode = of_get_parent(phynode);
-	if (!mdionode)
+	data = of_get_property(phynode, "reg", &len);
+	if (!data || len != 4) {
+		ret = -EINVAL;
 		goto out_put_phy;
+	}
 
-	ret = of_address_to_resource(mdionode, 0, &res);
-	if (ret)
-		goto out_put_mdio;
+	mdionode = of_get_parent(phynode);
+	if (!mdionode) {
+		ret = -EINVAL;
+		goto out_put_phy;
+	}
 
-	data = of_get_property(phynode, "reg", &len);
-	if (!data || len != 4)
-		goto out_put_mdio;
+	bus_id = of_get_gpio(mdionode, 0);
+	if (bus_id < 0) {
+		struct resource res;
+		ret = of_address_to_resource(mdionode, 0, &res);
+		if (ret)
+			goto out_put_mdio;
+		bus_id = res.start;
+	}
 
-	snprintf(fpi->bus_id, 16, "%x:%02x", res.start, *data);
+	snprintf(fpi->bus_id, 16, "%x:%02x", bus_id, *data);
 
 out_put_mdio:
 	of_node_put(mdionode);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 36be6ef..93007d3 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -49,6 +49,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
 #include <linux/inet_lro.h>
+#include <linux/dca.h>
 #include <linux/ip.h>
 #include <linux/inet.h>
 #include <linux/in.h>
@@ -185,11 +186,18 @@ struct myri10ge_slice_state {
 	dma_addr_t fw_stats_bus;
 	int watchdog_tx_done;
 	int watchdog_tx_req;
+#ifdef CONFIG_DCA
+	int cached_dca_tag;
+	int cpu;
+	__be32 __iomem *dca_tag;
+#endif
+	char irq_desc[32];
 };
 
 struct myri10ge_priv {
-	struct myri10ge_slice_state ss;
+	struct myri10ge_slice_state *ss;
 	int tx_boundary;	/* boundary transmits cannot cross */
+	int num_slices;
 	int running;		/* running?             */
 	int csum_flag;		/* rx_csums?            */
 	int small_bytes;
@@ -208,6 +216,11 @@ struct myri10ge_priv {
 	dma_addr_t cmd_bus;
 	struct pci_dev *pdev;
 	int msi_enabled;
+	int msix_enabled;
+	struct msix_entry *msix_vectors;
+#ifdef CONFIG_DCA
+	int dca_enabled;
+#endif
 	u32 link_state;
 	unsigned int rdma_tags_available;
 	int intr_coal_delay;
@@ -244,6 +257,8 @@ struct myri10ge_priv {
 
 static char *myri10ge_fw_unaligned = "myri10ge_ethp_z8e.dat";
 static char *myri10ge_fw_aligned = "myri10ge_eth_z8e.dat";
+static char *myri10ge_fw_rss_unaligned = "myri10ge_rss_ethp_z8e.dat";
+static char *myri10ge_fw_rss_aligned = "myri10ge_rss_eth_z8e.dat";
 
 static char *myri10ge_fw_name = NULL;
 module_param(myri10ge_fw_name, charp, S_IRUGO | S_IWUSR);
@@ -321,6 +336,18 @@ static int myri10ge_wcfifo = 0;
 module_param(myri10ge_wcfifo, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled");
 
+static int myri10ge_max_slices = 1;
+module_param(myri10ge_max_slices, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_max_slices, "Max tx/rx queues");
+
+static int myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_PORT;
+module_param(myri10ge_rss_hash, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_rss_hash, "Type of RSS hashing to do");
+
+static int myri10ge_dca = 1;
+module_param(myri10ge_dca, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_dca, "Enable DCA if possible");
+
 #define MYRI10GE_FW_OFFSET 1024*1024
 #define MYRI10GE_HIGHPART_TO_U32(X) \
 (sizeof (X) == 8) ? ((u32)((u64)(X) >> 32)) : (0)
@@ -657,7 +684,7 @@ static int myri10ge_get_firmware_capabilities(struct myri10ge_priv *mgp)
 	return 0;
 }
 
-static int myri10ge_load_firmware(struct myri10ge_priv *mgp)
+static int myri10ge_load_firmware(struct myri10ge_priv *mgp, int adopt)
 {
 	char __iomem *submit;
 	__be32 buf[16] __attribute__ ((__aligned__(8)));
@@ -667,6 +694,8 @@ static int myri10ge_load_firmware(struct myri10ge_priv *mgp)
 	size = 0;
 	status = myri10ge_load_hotplug_firmware(mgp, &size);
 	if (status) {
+		if (!adopt)
+			return status;
 		dev_warn(&mgp->pdev->dev, "hotplug firmware loading failed\n");
 
 		/* Do not attempt to adopt firmware if there
@@ -859,8 +888,12 @@ abort:
 static int myri10ge_reset(struct myri10ge_priv *mgp)
 {
 	struct myri10ge_cmd cmd;
-	int status;
+	struct myri10ge_slice_state *ss;
+	int i, status;
 	size_t bytes;
+#ifdef CONFIG_DCA
+	unsigned long dca_tag_off;
+#endif
 
 	/* try to send a reset command to the card to see if it
 	 * is alive */
@@ -872,20 +905,74 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	}
 
 	(void)myri10ge_dma_test(mgp, MXGEFW_DMA_TEST);
+	/*
+	 * Use non-ndis mcp_slot (eg, 4 bytes total,
+	 * no toeplitz hash value returned.  Older firmware will
+	 * not understand this command, but will use the correct
+	 * sized mcp_slot, so we ignore error returns
+	 */
+	cmd.data0 = MXGEFW_RSS_MCP_SLOT_TYPE_MIN;
+	(void)myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_RSS_MCP_SLOT_TYPE, &cmd, 0);
 
 	/* Now exchange information about interrupts  */
 
-	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
-	memset(mgp->ss.rx_done.entry, 0, bytes);
+	bytes = mgp->max_intr_slots * sizeof(*mgp->ss[0].rx_done.entry);
 	cmd.data0 = (u32) bytes;
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_SIZE, &cmd, 0);
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->ss.rx_done.bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->ss.rx_done.bus);
-	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_DMA, &cmd, 0);
+
+	/*
+	 * Even though we already know how many slices are supported
+	 * via myri10ge_probe_slices() MXGEFW_CMD_GET_MAX_RSS_QUEUES
+	 * has magic side effects, and must be called after a reset.
+	 * It must be called prior to calling any RSS related cmds,
+	 * including assigning an interrupt queue for anything but
+	 * slice 0.  It must also be called *after*
+	 * MXGEFW_CMD_SET_INTRQ_SIZE, since the intrq size is used by
+	 * the firmware to compute offsets.
+	 */
+
+	if (mgp->num_slices > 1) {
+
+		/* ask the maximum number of slices it supports */
+		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_RSS_QUEUES,
+					   &cmd, 0);
+		if (status != 0) {
+			dev_err(&mgp->pdev->dev,
+				"failed to get number of slices\n");
+		}
+
+		/*
+		 * MXGEFW_CMD_ENABLE_RSS_QUEUES must be called prior
+		 * to setting up the interrupt queue DMA
+		 */
+
+		cmd.data0 = mgp->num_slices;
+		cmd.data1 = 1;	/* use MSI-X */
+		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ENABLE_RSS_QUEUES,
+					   &cmd, 0);
+		if (status != 0) {
+			dev_err(&mgp->pdev->dev,
+				"failed to set number of slices\n");
+
+			return status;
+		}
+	}
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+		cmd.data0 = MYRI10GE_LOWPART_TO_U32(ss->rx_done.bus);
+		cmd.data1 = MYRI10GE_HIGHPART_TO_U32(ss->rx_done.bus);
+		cmd.data2 = i;
+		status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_DMA,
+					    &cmd, 0);
+	};
 
 	status |=
 	    myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_IRQ_ACK_OFFSET, &cmd, 0);
-	mgp->ss.irq_claim = (__iomem __be32 *) (mgp->sram + cmd.data0);
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+		ss->irq_claim =
+		    (__iomem __be32 *) (mgp->sram + cmd.data0 + 8 * i);
+	}
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_IRQ_DEASSERT_OFFSET,
 				    &cmd, 0);
 	mgp->irq_deassert = (__iomem __be32 *) (mgp->sram + cmd.data0);
@@ -899,24 +986,116 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	}
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
 
-	memset(mgp->ss.rx_done.entry, 0, bytes);
+#ifdef CONFIG_DCA
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_DCA_OFFSET, &cmd, 0);
+	dca_tag_off = cmd.data0;
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+		if (status == 0) {
+			ss->dca_tag = (__iomem __be32 *)
+			    (mgp->sram + dca_tag_off + 4 * i);
+		} else {
+			ss->dca_tag = NULL;
+		}
+	}
+#endif				/* CONFIG_DCA */
 
 	/* reset mcp/driver shared state back to 0 */
-	mgp->ss.tx.req = 0;
-	mgp->ss.tx.done = 0;
-	mgp->ss.tx.pkt_start = 0;
-	mgp->ss.tx.pkt_done = 0;
-	mgp->ss.rx_big.cnt = 0;
-	mgp->ss.rx_small.cnt = 0;
-	mgp->ss.rx_done.idx = 0;
-	mgp->ss.rx_done.cnt = 0;
+
 	mgp->link_changes = 0;
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+
+		memset(ss->rx_done.entry, 0, bytes);
+		ss->tx.req = 0;
+		ss->tx.done = 0;
+		ss->tx.pkt_start = 0;
+		ss->tx.pkt_done = 0;
+		ss->rx_big.cnt = 0;
+		ss->rx_small.cnt = 0;
+		ss->rx_done.idx = 0;
+		ss->rx_done.cnt = 0;
+		ss->tx.wake_queue = 0;
+		ss->tx.stop_queue = 0;
+	}
+
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
 	myri10ge_change_pause(mgp, mgp->pause);
 	myri10ge_set_multicast_list(mgp->dev);
 	return status;
 }
 
+#ifdef CONFIG_DCA
+static void
+myri10ge_write_dca(struct myri10ge_slice_state *ss, int cpu, int tag)
+{
+	ss->cpu = cpu;
+	ss->cached_dca_tag = tag;
+	put_be32(htonl(tag), ss->dca_tag);
+}
+
+static inline void myri10ge_update_dca(struct myri10ge_slice_state *ss)
+{
+	int cpu = get_cpu();
+	int tag;
+
+	if (cpu != ss->cpu) {
+		tag = dca_get_tag(cpu);
+		if (ss->cached_dca_tag != tag)
+			myri10ge_write_dca(ss, cpu, tag);
+	}
+	put_cpu();
+}
+
+static void myri10ge_setup_dca(struct myri10ge_priv *mgp)
+{
+	int err, i;
+	struct pci_dev *pdev = mgp->pdev;
+
+	if (mgp->ss[0].dca_tag == NULL || mgp->dca_enabled)
+		return;
+	if (!myri10ge_dca) {
+		dev_err(&pdev->dev, "dca disabled by administrator\n");
+		return;
+	}
+	err = dca_add_requester(&pdev->dev);
+	if (err) {
+		dev_err(&pdev->dev,
+			"dca_add_requester() failed, err=%d\n", err);
+		return;
+	}
+	mgp->dca_enabled = 1;
+	for (i = 0; i < mgp->num_slices; i++)
+		myri10ge_write_dca(&mgp->ss[i], -1, 0);
+}
+
+static void myri10ge_teardown_dca(struct myri10ge_priv *mgp)
+{
+	struct pci_dev *pdev = mgp->pdev;
+	int err;
+
+	if (!mgp->dca_enabled)
+		return;
+	mgp->dca_enabled = 0;
+	err = dca_remove_requester(&pdev->dev);
+}
+
+static int myri10ge_notify_dca_device(struct device *dev, void *data)
+{
+	struct myri10ge_priv *mgp;
+	unsigned long event;
+
+	mgp = dev_get_drvdata(dev);
+	event = *(unsigned long *)data;
+
+	if (event == DCA_PROVIDER_ADD)
+		myri10ge_setup_dca(mgp);
+	else if (event == DCA_PROVIDER_REMOVE)
+		myri10ge_teardown_dca(mgp);
+	return 0;
+}
+#endif				/* CONFIG_DCA */
+
 static inline void
 myri10ge_submit_8rx(struct mcp_kreq_ether_recv __iomem * dst,
 		    struct mcp_kreq_ether_recv *src)
@@ -1095,9 +1274,10 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, struct myri10ge_rx_buf *rx,
 		rx_frags[0].size -= MXGEFW_PAD;
 		len -= MXGEFW_PAD;
 		lro_receive_frags(&ss->rx_done.lro_mgr, rx_frags,
-				  len, len,
 				  /* opaque, will come back in get_frag_header */
+				  len, len,
 				  (void *)(__force unsigned long)csum, csum);
+
 		return 1;
 	}
 
@@ -1236,7 +1416,7 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 
 static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 {
-	struct mcp_irq_data *stats = mgp->ss.fw_stats;
+	struct mcp_irq_data *stats = mgp->ss[0].fw_stats;
 
 	if (unlikely(stats->stats_updated)) {
 		unsigned link_up = ntohl(stats->link_up);
@@ -1283,6 +1463,11 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	struct net_device *netdev = ss->mgp->dev;
 	int work_done;
 
+#ifdef CONFIG_DCA
+	if (ss->mgp->dca_enabled)
+		myri10ge_update_dca(ss);
+#endif
+
 	/* process as many rx events as NAPI will allow */
 	work_done = myri10ge_clean_rx_done(ss, budget);
 
@@ -1302,6 +1487,13 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 	u32 send_done_count;
 	int i;
 
+	/* an interrupt on a non-zero slice is implicitly valid
+	 * since MSI-X irqs are not shared */
+	if (ss != mgp->ss) {
+		netif_rx_schedule(ss->dev, &ss->napi);
+		return (IRQ_HANDLED);
+	}
+
 	/* make sure it is our IRQ, and that the DMA has finished */
 	if (unlikely(!stats->valid))
 		return (IRQ_NONE);
@@ -1311,7 +1503,7 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 	if (stats->valid & 1)
 		netif_rx_schedule(ss->dev, &ss->napi);
 
-	if (!mgp->msi_enabled) {
+	if (!mgp->msi_enabled && !mgp->msix_enabled) {
 		put_be32(0, mgp->irq_deassert);
 		if (!myri10ge_deassert_wait)
 			stats->valid = 0;
@@ -1446,10 +1638,10 @@ myri10ge_get_ringparam(struct net_device *netdev,
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
 
-	ring->rx_mini_max_pending = mgp->ss.rx_small.mask + 1;
-	ring->rx_max_pending = mgp->ss.rx_big.mask + 1;
+	ring->rx_mini_max_pending = mgp->ss[0].rx_small.mask + 1;
+	ring->rx_max_pending = mgp->ss[0].rx_big.mask + 1;
 	ring->rx_jumbo_max_pending = 0;
-	ring->tx_max_pending = mgp->ss.rx_small.mask + 1;
+	ring->tx_max_pending = mgp->ss[0].rx_small.mask + 1;
 	ring->rx_mini_pending = ring->rx_mini_max_pending;
 	ring->rx_pending = ring->rx_max_pending;
 	ring->rx_jumbo_pending = ring->rx_jumbo_max_pending;
@@ -1497,9 +1689,12 @@ static const char myri10ge_gstrings_main_stats[][ETH_GSTRING_LEN] = {
 	"tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors",
 	"tx_heartbeat_errors", "tx_window_errors",
 	/* device-specific stats */
-	"tx_boundary", "WC", "irq", "MSI",
+	"tx_boundary", "WC", "irq", "MSI", "MSIX",
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "watchdog_resets",
+#ifdef CONFIG_DCA
+	"dca_capable", "dca_enabled",
+#endif
 	"link_changes", "link_up", "dropped_link_overflow",
 	"dropped_link_error_or_filtered",
 	"dropped_pause", "dropped_bad_phy", "dropped_bad_crc32",
@@ -1524,23 +1719,31 @@ static const char myri10ge_gstrings_slice_stats[][ETH_GSTRING_LEN] = {
 static void
 myri10ge_get_strings(struct net_device *netdev, u32 stringset, u8 * data)
 {
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	int i;
+
 	switch (stringset) {
 	case ETH_SS_STATS:
 		memcpy(data, *myri10ge_gstrings_main_stats,
 		       sizeof(myri10ge_gstrings_main_stats));
 		data += sizeof(myri10ge_gstrings_main_stats);
-		memcpy(data, *myri10ge_gstrings_slice_stats,
-		       sizeof(myri10ge_gstrings_slice_stats));
-		data += sizeof(myri10ge_gstrings_slice_stats);
+		for (i = 0; i < mgp->num_slices; i++) {
+			memcpy(data, *myri10ge_gstrings_slice_stats,
+			       sizeof(myri10ge_gstrings_slice_stats));
+			data += sizeof(myri10ge_gstrings_slice_stats);
+		}
 		break;
 	}
 }
 
 static int myri10ge_get_sset_count(struct net_device *netdev, int sset)
 {
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
 	switch (sset) {
 	case ETH_SS_STATS:
-		return MYRI10GE_MAIN_STATS_LEN + MYRI10GE_SLICE_STATS_LEN;
+		return MYRI10GE_MAIN_STATS_LEN +
+		    mgp->num_slices * MYRI10GE_SLICE_STATS_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1552,6 +1755,7 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
 	struct myri10ge_slice_state *ss;
+	int slice;
 	int i;
 
 	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
@@ -1561,15 +1765,20 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 	data[i++] = (unsigned int)mgp->wc_enabled;
 	data[i++] = (unsigned int)mgp->pdev->irq;
 	data[i++] = (unsigned int)mgp->msi_enabled;
+	data[i++] = (unsigned int)mgp->msix_enabled;
 	data[i++] = (unsigned int)mgp->read_dma;
 	data[i++] = (unsigned int)mgp->write_dma;
 	data[i++] = (unsigned int)mgp->read_write_dma;
 	data[i++] = (unsigned int)mgp->serial_number;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
+#ifdef CONFIG_DCA
+	data[i++] = (unsigned int)(mgp->ss[0].dca_tag != NULL);
+	data[i++] = (unsigned int)(mgp->dca_enabled);
+#endif
 	data[i++] = (unsigned int)mgp->link_changes;
 
 	/* firmware stats are useful only in the first slice */
-	ss = &mgp->ss;
+	ss = &mgp->ss[0];
 	data[i++] = (unsigned int)ntohl(ss->fw_stats->link_up);
 	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_link_overflow);
 	data[i++] =
@@ -1585,24 +1794,27 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_small_buffer);
 	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_big_buffer);
 
-	data[i++] = 0;
-	data[i++] = (unsigned int)ss->tx.pkt_start;
-	data[i++] = (unsigned int)ss->tx.pkt_done;
-	data[i++] = (unsigned int)ss->tx.req;
-	data[i++] = (unsigned int)ss->tx.done;
-	data[i++] = (unsigned int)ss->rx_small.cnt;
-	data[i++] = (unsigned int)ss->rx_big.cnt;
-	data[i++] = (unsigned int)ss->tx.wake_queue;
-	data[i++] = (unsigned int)ss->tx.stop_queue;
-	data[i++] = (unsigned int)ss->tx.linearized;
-	data[i++] = ss->rx_done.lro_mgr.stats.aggregated;
-	data[i++] = ss->rx_done.lro_mgr.stats.flushed;
-	if (ss->rx_done.lro_mgr.stats.flushed)
-		data[i++] = ss->rx_done.lro_mgr.stats.aggregated /
-		    ss->rx_done.lro_mgr.stats.flushed;
-	else
-		data[i++] = 0;
-	data[i++] = ss->rx_done.lro_mgr.stats.no_desc;
+	for (slice = 0; slice < mgp->num_slices; slice++) {
+		ss = &mgp->ss[slice];
+		data[i++] = slice;
+		data[i++] = (unsigned int)ss->tx.pkt_start;
+		data[i++] = (unsigned int)ss->tx.pkt_done;
+		data[i++] = (unsigned int)ss->tx.req;
+		data[i++] = (unsigned int)ss->tx.done;
+		data[i++] = (unsigned int)ss->rx_small.cnt;
+		data[i++] = (unsigned int)ss->rx_big.cnt;
+		data[i++] = (unsigned int)ss->tx.wake_queue;
+		data[i++] = (unsigned int)ss->tx.stop_queue;
+		data[i++] = (unsigned int)ss->tx.linearized;
+		data[i++] = ss->rx_done.lro_mgr.stats.aggregated;
+		data[i++] = ss->rx_done.lro_mgr.stats.flushed;
+		if (ss->rx_done.lro_mgr.stats.flushed)
+			data[i++] = ss->rx_done.lro_mgr.stats.aggregated /
+			    ss->rx_done.lro_mgr.stats.flushed;
+		else
+			data[i++] = 0;
+		data[i++] = ss->rx_done.lro_mgr.stats.no_desc;
+	}
 }
 
 static void myri10ge_set_msglevel(struct net_device *netdev, u32 value)
@@ -1645,12 +1857,15 @@ static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
 	struct net_device *dev = mgp->dev;
 	int tx_ring_size, rx_ring_size;
 	int tx_ring_entries, rx_ring_entries;
-	int i, status;
+	int i, slice, status;
 	size_t bytes;
 
 	/* get ring sizes */
+	slice = ss - mgp->ss;
+	cmd.data0 = slice;
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_RING_SIZE, &cmd, 0);
 	tx_ring_size = cmd.data0;
+	cmd.data0 = slice;
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RX_RING_SIZE, &cmd, 0);
 	if (status != 0)
 		return status;
@@ -1715,15 +1930,17 @@ static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
 				mgp->small_bytes + MXGEFW_PAD, 0);
 
 	if (ss->rx_small.fill_cnt < ss->rx_small.mask + 1) {
-		printk(KERN_ERR "myri10ge: %s: alloced only %d small bufs\n",
-		       dev->name, ss->rx_small.fill_cnt);
+		printk(KERN_ERR
+		       "myri10ge: %s:slice-%d: alloced only %d small bufs\n",
+		       dev->name, slice, ss->rx_small.fill_cnt);
 		goto abort_with_rx_small_ring;
 	}
 
 	myri10ge_alloc_rx_pages(mgp, &ss->rx_big, mgp->big_bytes, 0);
 	if (ss->rx_big.fill_cnt < ss->rx_big.mask + 1) {
-		printk(KERN_ERR "myri10ge: %s: alloced only %d big bufs\n",
-		       dev->name, ss->rx_big.fill_cnt);
+		printk(KERN_ERR
+		       "myri10ge: %s:slice-%d: alloced only %d big bufs\n",
+		       dev->name, slice, ss->rx_big.fill_cnt);
 		goto abort_with_rx_big_ring;
 	}
 
@@ -1775,6 +1992,10 @@ static void myri10ge_free_rings(struct myri10ge_slice_state *ss)
 	struct myri10ge_tx_buf *tx;
 	int i, len, idx;
 
+	/* If not allocated, skip it */
+	if (ss->tx.req_list == NULL)
+		return;
+
 	for (i = ss->rx_big.cnt; i < ss->rx_big.fill_cnt; i++) {
 		idx = i & ss->rx_big.mask;
 		if (i == ss->rx_big.fill_cnt - 1)
@@ -1837,25 +2058,67 @@ static void myri10ge_free_rings(struct myri10ge_slice_state *ss)
 static int myri10ge_request_irq(struct myri10ge_priv *mgp)
 {
 	struct pci_dev *pdev = mgp->pdev;
+	struct myri10ge_slice_state *ss;
+	struct net_device *netdev = mgp->dev;
+	int i;
 	int status;
 
+	mgp->msi_enabled = 0;
+	mgp->msix_enabled = 0;
+	status = 0;
 	if (myri10ge_msi) {
-		status = pci_enable_msi(pdev);
-		if (status != 0)
-			dev_err(&pdev->dev,
-				"Error %d setting up MSI; falling back to xPIC\n",
-				status);
-		else
-			mgp->msi_enabled = 1;
-	} else {
-		mgp->msi_enabled = 0;
+		if (mgp->num_slices > 1) {
+			status =
+			    pci_enable_msix(pdev, mgp->msix_vectors,
+					    mgp->num_slices);
+			if (status == 0) {
+				mgp->msix_enabled = 1;
+			} else {
+				dev_err(&pdev->dev,
+					"Error %d setting up MSI-X\n", status);
+				return status;
+			}
+		}
+		if (mgp->msix_enabled == 0) {
+			status = pci_enable_msi(pdev);
+			if (status != 0) {
+				dev_err(&pdev->dev,
+					"Error %d setting up MSI; falling back to xPIC\n",
+					status);
+			} else {
+				mgp->msi_enabled = 1;
+			}
+		}
 	}
-	status = request_irq(pdev->irq, myri10ge_intr, IRQF_SHARED,
-			     mgp->dev->name, mgp);
-	if (status != 0) {
-		dev_err(&pdev->dev, "failed to allocate IRQ\n");
-		if (mgp->msi_enabled)
-			pci_disable_msi(pdev);
+	if (mgp->msix_enabled) {
+		for (i = 0; i < mgp->num_slices; i++) {
+			ss = &mgp->ss[i];
+			snprintf(ss->irq_desc, sizeof(ss->irq_desc),
+				 "%s:slice-%d", netdev->name, i);
+			status = request_irq(mgp->msix_vectors[i].vector,
+					     myri10ge_intr, 0, ss->irq_desc,
+					     ss);
+			if (status != 0) {
+				dev_err(&pdev->dev,
+					"slice %d failed to allocate IRQ\n", i);
+				i--;
+				while (i >= 0) {
+					free_irq(mgp->msix_vectors[i].vector,
+						 &mgp->ss[i]);
+					i--;
+				}
+				pci_disable_msix(pdev);
+				return status;
+			}
+		}
+	} else {
+		status = request_irq(pdev->irq, myri10ge_intr, IRQF_SHARED,
+				     mgp->dev->name, &mgp->ss[0]);
+		if (status != 0) {
+			dev_err(&pdev->dev, "failed to allocate IRQ\n");
+			if (mgp->msi_enabled)
+				pci_disable_msi(pdev);
+		}
 	}
 	return status;
 }
@@ -1863,10 +2126,18 @@ static int myri10ge_request_irq(struct myri10ge_priv *mgp)
 static void myri10ge_free_irq(struct myri10ge_priv *mgp)
 {
 	struct pci_dev *pdev = mgp->pdev;
+	int i;
 
-	free_irq(pdev->irq, mgp);
+	if (mgp->msix_enabled) {
+		for (i = 0; i < mgp->num_slices; i++)
+			free_irq(mgp->msix_vectors[i].vector, &mgp->ss[i]);
+	} else {
+		free_irq(pdev->irq, &mgp->ss[0]);
+	}
 	if (mgp->msi_enabled)
 		pci_disable_msi(pdev);
+	if (mgp->msix_enabled)
+		pci_disable_msix(pdev);
 }
 
 static int
@@ -1928,12 +2199,82 @@ myri10ge_get_frag_header(struct skb_frag_struct *frag, void **mac_hdr,
 	return 0;
 }
 
+static int myri10ge_get_txrx(struct myri10ge_priv *mgp, int slice)
+{
+	struct myri10ge_cmd cmd;
+	struct myri10ge_slice_state *ss;
+	int status;
+
+	ss = &mgp->ss[slice];
+	cmd.data0 = 0;		/* single slice for now */
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET, &cmd, 0);
+	ss->tx.lanai = (struct mcp_kreq_ether_send __iomem *)
+	    (mgp->sram + cmd.data0);
+
+	cmd.data0 = slice;
+	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SMALL_RX_OFFSET,
+				    &cmd, 0);
+	ss->rx_small.lanai = (struct mcp_kreq_ether_recv __iomem *)
+	    (mgp->sram + cmd.data0);
+
+	cmd.data0 = slice;
+	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_BIG_RX_OFFSET, &cmd, 0);
+	ss->rx_big.lanai = (struct mcp_kreq_ether_recv __iomem *)
+	    (mgp->sram + cmd.data0);
+
+	if (myri10ge_wcfifo && mgp->wc_enabled) {
+		ss->tx.wc_fifo = (u8 __iomem *)
+		    mgp->sram + MXGEFW_ETH_SEND_4 + 64 * slice;
+		ss->rx_small.wc_fifo = (u8 __iomem *)
+		    mgp->sram + MXGEFW_ETH_RECV_SMALL + 64 * slice;
+		ss->rx_big.wc_fifo = (u8 __iomem *)
+		    mgp->sram + MXGEFW_ETH_RECV_BIG + 64 * slice;
+	} else {
+		ss->tx.wc_fifo = NULL;
+		ss->rx_small.wc_fifo = NULL;
+		ss->rx_big.wc_fifo = NULL;
+	}
+	return status;
+
+}
+
+static int myri10ge_set_stats(struct myri10ge_priv *mgp, int slice)
+{
+	struct myri10ge_cmd cmd;
+	struct myri10ge_slice_state *ss;
+	int status;
+
+	ss = &mgp->ss[slice];
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(ss->fw_stats_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(ss->fw_stats_bus);
+	cmd.data2 = sizeof(struct mcp_irq_data);
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_STATS_DMA_V2, &cmd, 0);
+	if (status == -ENOSYS) {
+		dma_addr_t bus = ss->fw_stats_bus;
+		if (slice != 0)
+			return -EINVAL;
+		bus += offsetof(struct mcp_irq_data, send_done_count);
+		cmd.data0 = MYRI10GE_LOWPART_TO_U32(bus);
+		cmd.data1 = MYRI10GE_HIGHPART_TO_U32(bus);
+		status = myri10ge_send_cmd(mgp,
+					   MXGEFW_CMD_SET_STATS_DMA_OBSOLETE,
+					   &cmd, 0);
+		/* Firmware cannot support multicast without STATS_DMA_V2 */
+		mgp->fw_multicast_support = 0;
+	} else {
+		mgp->fw_multicast_support = 1;
+	}
+	return 0;
+}
+
 static int myri10ge_open(struct net_device *dev)
 {
+	struct myri10ge_slice_state *ss;
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
+	int i, status, big_pow2, slice;
+	u8 *itable;
 	struct net_lro_mgr *lro_mgr;
-	int status, big_pow2;
 
 	if (mgp->running != MYRI10GE_ETH_STOPPED)
 		return -EBUSY;
@@ -1945,6 +2286,48 @@ static int myri10ge_open(struct net_device *dev)
 		goto abort_with_nothing;
 	}
 
+	if (mgp->num_slices > 1) {
+		cmd.data0 = mgp->num_slices;
+		cmd.data1 = 1;	/* use MSI-X */
+		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ENABLE_RSS_QUEUES,
+					   &cmd, 0);
+		if (status != 0) {
+			printk(KERN_ERR
+			       "myri10ge: %s: failed to set number of slices\n",
+			       dev->name);
+			goto abort_with_nothing;
+		}
+		/* setup the indirection table */
+		cmd.data0 = mgp->num_slices;
+		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_RSS_TABLE_SIZE,
+					   &cmd, 0);
+
+		status |= myri10ge_send_cmd(mgp,
+					    MXGEFW_CMD_GET_RSS_TABLE_OFFSET,
+					    &cmd, 0);
+		if (status != 0) {
+			printk(KERN_ERR
+			       "myri10ge: %s: failed to setup rss tables\n",
+			       dev->name);
+		}
+
+		/* just enable an identity mapping */
+		itable = mgp->sram + cmd.data0;
+		for (i = 0; i < mgp->num_slices; i++)
+			__raw_writeb(i, &itable[i]);
+
+		cmd.data0 = 1;
+		cmd.data1 = myri10ge_rss_hash;
+		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_RSS_ENABLE,
+					   &cmd, 0);
+		if (status != 0) {
+			printk(KERN_ERR
+			       "myri10ge: %s: failed to enable slices\n",
+			       dev->name);
+			goto abort_with_nothing;
+		}
+	}
+
 	status = myri10ge_request_irq(mgp);
 	if (status != 0)
 		goto abort_with_nothing;
@@ -1968,41 +2351,6 @@ static int myri10ge_open(struct net_device *dev)
 	if (myri10ge_small_bytes > 0)
 		mgp->small_bytes = myri10ge_small_bytes;
 
-	/* get the lanai pointers to the send and receive rings */
-
-	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET, &cmd, 0);
-	mgp->ss.tx.lanai =
-	    (struct mcp_kreq_ether_send __iomem *)(mgp->sram + cmd.data0);
-
-	status |=
-	    myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SMALL_RX_OFFSET, &cmd, 0);
-	mgp->ss.rx_small.lanai =
-	    (struct mcp_kreq_ether_recv __iomem *)(mgp->sram + cmd.data0);
-
-	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_BIG_RX_OFFSET, &cmd, 0);
-	mgp->ss.rx_big.lanai =
-	    (struct mcp_kreq_ether_recv __iomem *)(mgp->sram + cmd.data0);
-
-	if (status != 0) {
-		printk(KERN_ERR
-		       "myri10ge: %s: failed to get ring sizes or locations\n",
-		       dev->name);
-		mgp->running = MYRI10GE_ETH_STOPPED;
-		goto abort_with_irq;
-	}
-
-	if (myri10ge_wcfifo && mgp->wc_enabled) {
-		mgp->ss.tx.wc_fifo = (u8 __iomem *) mgp->sram + MXGEFW_ETH_SEND_4;
-		mgp->ss.rx_small.wc_fifo =
-		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_SMALL;
-		mgp->ss.rx_big.wc_fifo =
-		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_BIG;
-	} else {
-		mgp->ss.tx.wc_fifo = NULL;
-		mgp->ss.rx_small.wc_fifo = NULL;
-		mgp->ss.rx_big.wc_fifo = NULL;
-	}
-
 	/* Firmware needs the big buff size as a power of 2.  Lie and
 	 * tell him the buffer is larger, because we only use 1
 	 * buffer/pkt, and the mtu will prevent overruns.
@@ -2017,9 +2365,44 @@ static int myri10ge_open(struct net_device *dev)
 		mgp->big_bytes = big_pow2;
 	}
 
-	status = myri10ge_allocate_rings(&mgp->ss);
-	if (status != 0)
-		goto abort_with_irq;
+	/* setup the per-slice data structures */
+	for (slice = 0; slice < mgp->num_slices; slice++) {
+		ss = &mgp->ss[slice];
+
+		status = myri10ge_get_txrx(mgp, slice);
+		if (status != 0) {
+			printk(KERN_ERR
+			       "myri10ge: %s: failed to get ring sizes or locations\n",
+			       dev->name);
+			goto abort_with_rings;
+		}
+		status = myri10ge_allocate_rings(ss);
+		if (status != 0)
+			goto abort_with_rings;
+		if (slice == 0)
+			status = myri10ge_set_stats(mgp, slice);
+		if (status) {
+			printk(KERN_ERR
+			       "myri10ge: %s: Couldn't set stats DMA\n",
+			       dev->name);
+			goto abort_with_rings;
+		}
+
+		lro_mgr = &ss->rx_done.lro_mgr;
+		lro_mgr->dev = dev;
+		lro_mgr->features = LRO_F_NAPI;
+		lro_mgr->ip_summed = CHECKSUM_COMPLETE;
+		lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
+		lro_mgr->max_desc = MYRI10GE_MAX_LRO_DESCRIPTORS;
+		lro_mgr->lro_arr = ss->rx_done.lro_desc;
+		lro_mgr->get_frag_header = myri10ge_get_frag_header;
+		lro_mgr->max_aggr = myri10ge_lro_max_pkts;
+		if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
+			lro_mgr->max_aggr = MAX_SKB_FRAGS;
+
+		/* must happen prior to any irq */
+		napi_enable(&(ss)->napi);
+	}
 
 	/* now give firmware buffers sizes, and MTU */
 	cmd.data0 = dev->mtu + ETH_HLEN + VLAN_HLEN;
@@ -2036,25 +2419,15 @@ static int myri10ge_open(struct net_device *dev)
 		goto abort_with_rings;
 	}
 
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->ss.fw_stats_bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->ss.fw_stats_bus);
-	cmd.data2 = sizeof(struct mcp_irq_data);
-	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_STATS_DMA_V2, &cmd, 0);
-	if (status == -ENOSYS) {
-		dma_addr_t bus = mgp->ss.fw_stats_bus;
-		bus += offsetof(struct mcp_irq_data, send_done_count);
-		cmd.data0 = MYRI10GE_LOWPART_TO_U32(bus);
-		cmd.data1 = MYRI10GE_HIGHPART_TO_U32(bus);
-		status = myri10ge_send_cmd(mgp,
-					   MXGEFW_CMD_SET_STATS_DMA_OBSOLETE,
-					   &cmd, 0);
-		/* Firmware cannot support multicast without STATS_DMA_V2 */
-		mgp->fw_multicast_support = 0;
-	} else {
-		mgp->fw_multicast_support = 1;
-	}
-	if (status) {
-		printk(KERN_ERR "myri10ge: %s: Couldn't set stats DMA\n",
+	/*
+	 * Set Linux style TSO mode; this is needed only on newer
+	 *  firmware versions.  Older versions default to Linux
+	 *  style TSO
+	 */
+	cmd.data0 = 0;
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_TSO_MODE, &cmd, 0);
+	if (status && status != -ENOSYS) {
+		printk(KERN_ERR "myri10ge: %s: Couldn't set TSO mode\n",
 		       dev->name);
 		goto abort_with_rings;
 	}
@@ -2062,21 +2435,6 @@ static int myri10ge_open(struct net_device *dev)
 	mgp->link_state = ~0U;
 	mgp->rdma_tags_available = 15;
 
-	lro_mgr = &mgp->ss.rx_done.lro_mgr;
-	lro_mgr->dev = dev;
-	lro_mgr->features = LRO_F_NAPI;
-	lro_mgr->ip_summed = CHECKSUM_COMPLETE;
-	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
-	lro_mgr->max_desc = MYRI10GE_MAX_LRO_DESCRIPTORS;
-	lro_mgr->lro_arr = mgp->ss.rx_done.lro_desc;
-	lro_mgr->get_frag_header = myri10ge_get_frag_header;
-	lro_mgr->max_aggr = myri10ge_lro_max_pkts;
-	lro_mgr->frag_align_pad = 2;
-	if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
-		lro_mgr->max_aggr = MAX_SKB_FRAGS;
-
-	napi_enable(&mgp->ss.napi);	/* must happen prior to any irq */
-
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_UP, &cmd, 0);
 	if (status) {
 		printk(KERN_ERR "myri10ge: %s: Couldn't bring up link\n",
@@ -2084,8 +2442,6 @@ static int myri10ge_open(struct net_device *dev)
 		goto abort_with_rings;
 	}
 
-	mgp->ss.tx.wake_queue = 0;
-	mgp->ss.tx.stop_queue = 0;
 	mgp->running = MYRI10GE_ETH_RUNNING;
 	mgp->watchdog_timer.expires = jiffies + myri10ge_watchdog_timeout * HZ;
 	add_timer(&mgp->watchdog_timer);
@@ -2093,9 +2449,9 @@ static int myri10ge_open(struct net_device *dev)
 	return 0;
 
 abort_with_rings:
-	myri10ge_free_rings(&mgp->ss);
+	for (i = 0; i < mgp->num_slices; i++)
+		myri10ge_free_rings(&mgp->ss[i]);
 
-abort_with_irq:
 	myri10ge_free_irq(mgp);
 
 abort_with_nothing:
@@ -2108,16 +2464,19 @@ static int myri10ge_close(struct net_device *dev)
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
 	int status, old_down_cnt;
+	int i;
 
 	if (mgp->running != MYRI10GE_ETH_RUNNING)
 		return 0;
 
-	if (mgp->ss.tx.req_bytes == NULL)
+	if (mgp->ss[0].tx.req_bytes == NULL)
 		return 0;
 
 	del_timer_sync(&mgp->watchdog_timer);
 	mgp->running = MYRI10GE_ETH_STOPPING;
-	napi_disable(&mgp->ss.napi);
+	for (i = 0; i < mgp->num_slices; i++) {
+		napi_disable(&mgp->ss[i].napi);
+	}
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 	old_down_cnt = mgp->down_cnt;
@@ -2133,7 +2492,8 @@ static int myri10ge_close(struct net_device *dev)
 
 	netif_tx_disable(dev);
 	myri10ge_free_irq(mgp);
-	myri10ge_free_rings(&mgp->ss);
+	for (i = 0; i < mgp->num_slices; i++)
+		myri10ge_free_rings(&mgp->ss[i]);
 
 	mgp->running = MYRI10GE_ETH_STOPPED;
 	return 0;
@@ -2254,7 +2614,7 @@ static int myri10ge_xmit(struct sk_buff *skb, struct net_device *dev)
 	u8 flags, odd_flag;
 
 	/* always transmit through slot 0 */
-	ss = &mgp->ss;
+	ss = mgp->ss;
 	tx = &ss->tx;
 again:
 	req = tx->req_list;
@@ -2559,7 +2919,21 @@ drop:
 static struct net_device_stats *myri10ge_get_stats(struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
-	return &mgp->stats;
+	struct myri10ge_slice_netstats *slice_stats;
+	struct net_device_stats *stats = &mgp->stats;
+	int i;
+
+	memset(stats, 0, sizeof(*stats));
+	for (i = 0; i < mgp->num_slices; i++) {
+		slice_stats = &mgp->ss[i].stats;
+		stats->rx_packets += slice_stats->rx_packets;
+		stats->tx_packets += slice_stats->tx_packets;
+		stats->rx_bytes += slice_stats->rx_bytes;
+		stats->tx_bytes += slice_stats->tx_bytes;
+		stats->rx_dropped += slice_stats->rx_dropped;
+		stats->tx_dropped += slice_stats->tx_dropped;
+	}
+	return stats;
 }
 
 static void myri10ge_set_multicast_list(struct net_device *dev)
@@ -2770,10 +3144,10 @@ static void myri10ge_enable_ecrc(struct myri10ge_priv *mgp)
  *
  * If the driver can neither enable ECRC nor verify that it has
  * already been enabled, then it must use a firmware image which works
- * around unaligned completion packets (myri10ge_ethp_z8e.dat), and it
+ * around unaligned completion packets (myri10ge_rss_ethp_z8e.dat), and it
  * should also ensure that it never gives the device a Read-DMA which is
  * larger than 2KB by setting the tx_boundary to 2KB.  If ECRC is
- * enabled, then the driver should use the aligned (myri10ge_eth_z8e.dat)
+ * enabled, then the driver should use the aligned (myri10ge_rss_eth_z8e.dat)
  * firmware image, and set tx_boundary to 4KB.
  */
 
@@ -2802,7 +3176,7 @@ static void myri10ge_firmware_probe(struct myri10ge_priv *mgp)
 	 * completions) in order to see if it works on this host.
 	 */
 	mgp->fw_name = myri10ge_fw_aligned;
-	status = myri10ge_load_firmware(mgp);
+	status = myri10ge_load_firmware(mgp, 1);
 	if (status != 0) {
 		goto abort;
 	}
@@ -2983,6 +3357,7 @@ static void myri10ge_watchdog(struct work_struct *work)
 	struct myri10ge_tx_buf *tx;
 	u32 reboot;
 	int status;
+	int i;
 	u16 cmd, vendor;
 
 	mgp->watchdog_resets++;
@@ -3030,20 +3405,26 @@ static void myri10ge_watchdog(struct work_struct *work)
 
 		printk(KERN_ERR "myri10ge: %s: device timeout, resetting\n",
 		       mgp->dev->name);
-		tx = &mgp->ss.tx;
-		printk(KERN_INFO "myri10ge: %s: %d %d %d %d %d\n",
-		       mgp->dev->name, tx->req, tx->done,
-		       tx->pkt_start, tx->pkt_done,
-		       (int)ntohl(mgp->ss.fw_stats->send_done_count));
-		msleep(2000);
-		printk(KERN_INFO "myri10ge: %s: %d %d %d %d %d\n",
-		       mgp->dev->name, tx->req, tx->done,
-		       tx->pkt_start, tx->pkt_done,
-		       (int)ntohl(mgp->ss.fw_stats->send_done_count));
+		for (i = 0; i < mgp->num_slices; i++) {
+			tx = &mgp->ss[i].tx;
+			printk(KERN_INFO
+			       "myri10ge: %s: (%d): %d %d %d %d %d\n",
+			       mgp->dev->name, i, tx->req, tx->done,
+			       tx->pkt_start, tx->pkt_done,
+			       (int)ntohl(mgp->ss[i].fw_stats->
+					  send_done_count));
+			msleep(2000);
+			printk(KERN_INFO
+			       "myri10ge: %s: (%d): %d %d %d %d %d\n",
+			       mgp->dev->name, i, tx->req, tx->done,
+			       tx->pkt_start, tx->pkt_done,
+			       (int)ntohl(mgp->ss[i].fw_stats->
+					  send_done_count));
+		}
 	}
 	rtnl_lock();
 	myri10ge_close(mgp->dev);
-	status = myri10ge_load_firmware(mgp);
+	status = myri10ge_load_firmware(mgp, 1);
 	if (status != 0)
 		printk(KERN_ERR "myri10ge: %s: failed to load firmware\n",
 		       mgp->dev->name);
@@ -3063,47 +3444,241 @@ static void myri10ge_watchdog_timer(unsigned long arg)
 {
 	struct myri10ge_priv *mgp;
 	struct myri10ge_slice_state *ss;
+	int i, reset_needed;
 	u32 rx_pause_cnt;
 
 	mgp = (struct myri10ge_priv *)arg;
 
-	rx_pause_cnt = ntohl(mgp->ss.fw_stats->dropped_pause);
+	rx_pause_cnt = ntohl(mgp->ss[0].fw_stats->dropped_pause);
+	for (i = 0, reset_needed = 0;
+	     i < mgp->num_slices && reset_needed == 0; ++i) {
+
+		ss = &mgp->ss[i];
+		if (ss->rx_small.watchdog_needed) {
+			myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
+						mgp->small_bytes + MXGEFW_PAD,
+						1);
+			if (ss->rx_small.fill_cnt - ss->rx_small.cnt >=
+			    myri10ge_fill_thresh)
+				ss->rx_small.watchdog_needed = 0;
+		}
+		if (ss->rx_big.watchdog_needed) {
+			myri10ge_alloc_rx_pages(mgp, &ss->rx_big,
+						mgp->big_bytes, 1);
+			if (ss->rx_big.fill_cnt - ss->rx_big.cnt >=
+			    myri10ge_fill_thresh)
+				ss->rx_big.watchdog_needed = 0;
+		}
 
-	ss = &mgp->ss;
-	if (ss->rx_small.watchdog_needed) {
-		myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
-					mgp->small_bytes + MXGEFW_PAD, 1);
-		if (ss->rx_small.fill_cnt - ss->rx_small.cnt >=
-		    myri10ge_fill_thresh)
-			ss->rx_small.watchdog_needed = 0;
-	}
-	if (ss->rx_big.watchdog_needed) {
-		myri10ge_alloc_rx_pages(mgp, &ss->rx_big, mgp->big_bytes, 1);
-		if (ss->rx_big.fill_cnt - ss->rx_big.cnt >=
-		    myri10ge_fill_thresh)
-			ss->rx_big.watchdog_needed = 0;
-	}
-
-	if (ss->tx.req != ss->tx.done &&
-	    ss->tx.done == ss->watchdog_tx_done &&
-	    ss->watchdog_tx_req != ss->watchdog_tx_done) {
-		/* nic seems like it might be stuck.. */
-		if (rx_pause_cnt != mgp->watchdog_pause) {
-			if (net_ratelimit())
-				printk(KERN_WARNING "myri10ge %s:"
-				       "TX paused, check link partner\n",
-				       mgp->dev->name);
-		} else {
-			schedule_work(&mgp->watchdog_work);
-			return;
+		if (ss->tx.req != ss->tx.done &&
+		    ss->tx.done == ss->watchdog_tx_done &&
+		    ss->watchdog_tx_req != ss->watchdog_tx_done) {
+			/* nic seems like it might be stuck.. */
+			if (rx_pause_cnt != mgp->watchdog_pause) {
+				if (net_ratelimit())
+					printk(KERN_WARNING "myri10ge %s:"
+					       "TX paused, check link partner\n",
+					       mgp->dev->name);
+			} else {
+				reset_needed = 1;
+			}
 		}
+		ss->watchdog_tx_done = ss->tx.done;
+		ss->watchdog_tx_req = ss->tx.req;
 	}
-	/* rearm timer */
-	mod_timer(&mgp->watchdog_timer,
-		  jiffies + myri10ge_watchdog_timeout * HZ);
-	ss->watchdog_tx_done = ss->tx.done;
-	ss->watchdog_tx_req = ss->tx.req;
 	mgp->watchdog_pause = rx_pause_cnt;
+
+	if (reset_needed) {
+		schedule_work(&mgp->watchdog_work);
+	} else {
+		/* rearm timer */
+		mod_timer(&mgp->watchdog_timer,
+			  jiffies + myri10ge_watchdog_timeout * HZ);
+	}
+}
+
+static void myri10ge_free_slices(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_slice_state *ss;
+	struct pci_dev *pdev = mgp->pdev;
+	size_t bytes;
+	int i;
+
+	if (mgp->ss == NULL)
+		return;
+
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+		if (ss->rx_done.entry != NULL) {
+			bytes = mgp->max_intr_slots *
+			    sizeof(*ss->rx_done.entry);
+			dma_free_coherent(&pdev->dev, bytes,
+					  ss->rx_done.entry, ss->rx_done.bus);
+			ss->rx_done.entry = NULL;
+		}
+		if (ss->fw_stats != NULL) {
+			bytes = sizeof(*ss->fw_stats);
+			dma_free_coherent(&pdev->dev, bytes,
+					  ss->fw_stats, ss->fw_stats_bus);
+			ss->fw_stats = NULL;
+		}
+	}
+	kfree(mgp->ss);
+	mgp->ss = NULL;
+}
+
+static int myri10ge_alloc_slices(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_slice_state *ss;
+	struct pci_dev *pdev = mgp->pdev;
+	size_t bytes;
+	int i;
+
+	bytes = sizeof(*mgp->ss) * mgp->num_slices;
+	mgp->ss = kzalloc(bytes, GFP_KERNEL);
+	if (mgp->ss == NULL) {
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+		bytes = mgp->max_intr_slots * sizeof(*ss->rx_done.entry);
+		ss->rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
+						       &ss->rx_done.bus,
+						       GFP_KERNEL);
+		if (ss->rx_done.entry == NULL)
+			goto abort;
+		memset(ss->rx_done.entry, 0, bytes);
+		bytes = sizeof(*ss->fw_stats);
+		ss->fw_stats = dma_alloc_coherent(&pdev->dev, bytes,
+						  &ss->fw_stats_bus,
+						  GFP_KERNEL);
+		if (ss->fw_stats == NULL)
+			goto abort;
+		ss->mgp = mgp;
+		ss->dev = mgp->dev;
+		netif_napi_add(ss->dev, &ss->napi, myri10ge_poll,
+			       myri10ge_napi_weight);
+	}
+	return 0;
+abort:
+	myri10ge_free_slices(mgp);
+	return -ENOMEM;
+}
+
+/*
+ * This function determines the number of slices supported.
+ * The number slices is the minumum of the number of CPUS,
+ * the number of MSI-X irqs supported, the number of slices
+ * supported by the firmware
+ */
+static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_cmd cmd;
+	struct pci_dev *pdev = mgp->pdev;
+	char *old_fw;
+	int i, status, ncpus, msix_cap;
+
+	mgp->num_slices = 1;
+	msix_cap = pci_find_capability(pdev, PCI_CAP_ID_MSIX);
+	ncpus = num_online_cpus();
+
+	if (myri10ge_max_slices == 1 || msix_cap == 0 ||
+	    (myri10ge_max_slices == -1 && ncpus < 2))
+		return;
+
+	/* try to load the slice aware rss firmware */
+	old_fw = mgp->fw_name;
+	if (old_fw == myri10ge_fw_aligned)
+		mgp->fw_name = myri10ge_fw_rss_aligned;
+	else
+		mgp->fw_name = myri10ge_fw_rss_unaligned;
+	status = myri10ge_load_firmware(mgp, 0);
+	if (status != 0) {
+		dev_info(&pdev->dev, "Rss firmware not found\n");
+		return;
+	}
+
+	/* hit the board with a reset to ensure it is alive */
+	memset(&cmd, 0, sizeof(cmd));
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_RESET, &cmd, 0);
+	if (status != 0) {
+		dev_err(&mgp->pdev->dev, "failed reset\n");
+		goto abort_with_fw;
+		return;
+	}
+
+	mgp->max_intr_slots = cmd.data0 / sizeof(struct mcp_slot);
+
+	/* tell it the size of the interrupt queues */
+	cmd.data0 = mgp->max_intr_slots * sizeof(struct mcp_slot);
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_SIZE, &cmd, 0);
+	if (status != 0) {
+		dev_err(&mgp->pdev->dev, "failed MXGEFW_CMD_SET_INTRQ_SIZE\n");
+		goto abort_with_fw;
+	}
+
+	/* ask the maximum number of slices it supports */
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_RSS_QUEUES, &cmd, 0);
+	if (status != 0)
+		goto abort_with_fw;
+	else
+		mgp->num_slices = cmd.data0;
+
+	/* Only allow multiple slices if MSI-X is usable */
+	if (!myri10ge_msi) {
+		goto abort_with_fw;
+	}
+
+	/* if the admin did not specify a limit to how many
+	 * slices we should use, cap it automatically to the
+	 * number of CPUs currently online */
+	if (myri10ge_max_slices == -1)
+		myri10ge_max_slices = ncpus;
+
+	if (mgp->num_slices > myri10ge_max_slices)
+		mgp->num_slices = myri10ge_max_slices;
+
+	/* Now try to allocate as many MSI-X vectors as we have
+	 * slices. We give up on MSI-X if we can only get a single
+	 * vector. */
+
+	mgp->msix_vectors = kzalloc(mgp->num_slices *
+				    sizeof(*mgp->msix_vectors), GFP_KERNEL);
+	if (mgp->msix_vectors == NULL)
+		goto disable_msix;
+	for (i = 0; i < mgp->num_slices; i++) {
+		mgp->msix_vectors[i].entry = i;
+	}
+
+	while (mgp->num_slices > 1) {
+		/* make sure it is a power of two */
+		while (!is_power_of_2(mgp->num_slices))
+			mgp->num_slices--;
+		if (mgp->num_slices == 1)
+			goto disable_msix;
+		status = pci_enable_msix(pdev, mgp->msix_vectors,
+					 mgp->num_slices);
+		if (status == 0) {
+			pci_disable_msix(pdev);
+			return;
+		}
+		if (status > 0)
+			mgp->num_slices = status;
+		else
+			goto disable_msix;
+	}
+
+disable_msix:
+	if (mgp->msix_vectors != NULL) {
+		kfree(mgp->msix_vectors);
+		mgp->msix_vectors = NULL;
+	}
+
+abort_with_fw:
+	mgp->num_slices = 1;
+	mgp->fw_name = old_fw;
+	myri10ge_load_firmware(mgp, 0);
 }
 
 static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
@@ -3111,7 +3686,6 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct net_device *netdev;
 	struct myri10ge_priv *mgp;
 	struct device *dev = &pdev->dev;
-	size_t bytes;
 	int i;
 	int status = -ENXIO;
 	int dac_enabled;
@@ -3126,7 +3700,6 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	mgp = netdev_priv(netdev);
 	mgp->dev = netdev;
-	netif_napi_add(netdev, &mgp->ss.napi, myri10ge_poll, myri10ge_napi_weight);
 	mgp->pdev = pdev;
 	mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
 	mgp->pause = myri10ge_flow_control;
@@ -3172,11 +3745,6 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (mgp->cmd == NULL)
 		goto abort_with_netdev;
 
-	mgp->ss.fw_stats = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
-					   &mgp->ss.fw_stats_bus, GFP_KERNEL);
-	if (mgp->ss.fw_stats == NULL)
-		goto abort_with_cmd;
-
 	mgp->board_span = pci_resource_len(pdev, 0);
 	mgp->iomem_base = pci_resource_start(pdev, 0);
 	mgp->mtrr = -1;
@@ -3213,28 +3781,28 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	for (i = 0; i < ETH_ALEN; i++)
 		netdev->dev_addr[i] = mgp->mac_addr[i];
 
-	/* allocate rx done ring */
-	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
-	mgp->ss.rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
-						&mgp->ss.rx_done.bus, GFP_KERNEL);
-	if (mgp->ss.rx_done.entry == NULL)
-		goto abort_with_ioremap;
-	memset(mgp->ss.rx_done.entry, 0, bytes);
-
 	myri10ge_select_firmware(mgp);
 
-	status = myri10ge_load_firmware(mgp);
+	status = myri10ge_load_firmware(mgp, 1);
 	if (status != 0) {
 		dev_err(&pdev->dev, "failed to load firmware\n");
-		goto abort_with_rx_done;
+		goto abort_with_ioremap;
+	}
+	myri10ge_probe_slices(mgp);
+	status = myri10ge_alloc_slices(mgp);
+	if (status != 0) {
+		dev_err(&pdev->dev, "failed to alloc slice state\n");
+		goto abort_with_firmware;
 	}
 
 	status = myri10ge_reset(mgp);
 	if (status != 0) {
 		dev_err(&pdev->dev, "failed reset\n");
-		goto abort_with_firmware;
+		goto abort_with_slices;
 	}
-
+#ifdef CONFIG_DCA
+	myri10ge_setup_dca(mgp);
+#endif
 	pci_set_drvdata(pdev, mgp);
 	if ((myri10ge_initial_mtu + ETH_HLEN) > MYRI10GE_MAX_ETHER_MTU)
 		myri10ge_initial_mtu = MYRI10GE_MAX_ETHER_MTU - ETH_HLEN;
@@ -3277,24 +3845,27 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&pdev->dev, "register_netdev failed: %d\n", status);
 		goto abort_with_state;
 	}
-	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
-		 (mgp->msi_enabled ? "MSI" : "xPIC"),
-		 netdev->irq, mgp->tx_boundary, mgp->fw_name,
-		 (mgp->wc_enabled ? "Enabled" : "Disabled"));
+	if (mgp->msix_enabled)
+		dev_info(dev, "%d MSI-X IRQs, tx bndry %d, fw %s, WC %s\n",
+			 mgp->num_slices, mgp->tx_boundary, mgp->fw_name,
+			 (mgp->wc_enabled ? "Enabled" : "Disabled"));
+	else
+		dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
+			 mgp->msi_enabled ? "MSI" : "xPIC",
+			 netdev->irq, mgp->tx_boundary, mgp->fw_name,
+			 (mgp->wc_enabled ? "Enabled" : "Disabled"));
 
 	return 0;
 
 abort_with_state:
 	pci_restore_state(pdev);
 
+abort_with_slices:
+	myri10ge_free_slices(mgp);
+
 abort_with_firmware:
 	myri10ge_dummy_rdma(mgp, 0);
 
-abort_with_rx_done:
-	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
-	dma_free_coherent(&pdev->dev, bytes,
-			  mgp->ss.rx_done.entry, mgp->ss.rx_done.bus);
-
 abort_with_ioremap:
 	iounmap(mgp->sram);
 
@@ -3303,10 +3874,6 @@ abort_with_wc:
 	if (mgp->mtrr >= 0)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
 #endif
-	dma_free_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
-			  mgp->ss.fw_stats, mgp->ss.fw_stats_bus);
-
-abort_with_cmd:
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
 			  mgp->cmd, mgp->cmd_bus);
 
@@ -3327,7 +3894,6 @@ static void myri10ge_remove(struct pci_dev *pdev)
 {
 	struct myri10ge_priv *mgp;
 	struct net_device *netdev;
-	size_t bytes;
 
 	mgp = pci_get_drvdata(pdev);
 	if (mgp == NULL)
@@ -3337,24 +3903,23 @@ static void myri10ge_remove(struct pci_dev *pdev)
 	netdev = mgp->dev;
 	unregister_netdev(netdev);
 
+#ifdef CONFIG_DCA
+	myri10ge_teardown_dca(mgp);
+#endif
 	myri10ge_dummy_rdma(mgp, 0);
 
 	/* avoid a memory leak */
 	pci_restore_state(pdev);
 
-	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
-	dma_free_coherent(&pdev->dev, bytes,
-			  mgp->ss.rx_done.entry, mgp->ss.rx_done.bus);
-
 	iounmap(mgp->sram);
 
 #ifdef CONFIG_MTRR
 	if (mgp->mtrr >= 0)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
 #endif
-	dma_free_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
-			  mgp->ss.fw_stats, mgp->ss.fw_stats_bus);
-
+	myri10ge_free_slices(mgp);
+	if (mgp->msix_vectors != NULL)
+		kfree(mgp->msix_vectors);
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
 			  mgp->cmd, mgp->cmd_bus);
 
@@ -3383,10 +3948,42 @@ static struct pci_driver myri10ge_driver = {
 #endif
 };
 
+#ifdef CONFIG_DCA
+static int
+myri10ge_notify_dca(struct notifier_block *nb, unsigned long event, void *p)
+{
+	int err = driver_for_each_device(&myri10ge_driver.driver,
+					 NULL, &event,
+					 myri10ge_notify_dca_device);
+
+	if (err)
+		return NOTIFY_BAD;
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block myri10ge_dca_notifier = {
+	.notifier_call = myri10ge_notify_dca,
+	.next = NULL,
+	.priority = 0,
+};
+#endif				/* CONFIG_DCA */
+
 static __init int myri10ge_init_module(void)
 {
 	printk(KERN_INFO "%s: Version %s\n", myri10ge_driver.name,
 	       MYRI10GE_VERSION_STR);
+
+	if (myri10ge_rss_hash > MXGEFW_RSS_HASH_TYPE_SRC_PORT ||
+	    myri10ge_rss_hash < MXGEFW_RSS_HASH_TYPE_IPV4) {
+		printk(KERN_ERR
+		       "%s: Illegal rssh hash type %d, defaulting to source port\n",
+		       myri10ge_driver.name, myri10ge_rss_hash);
+		myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_PORT;
+	}
+#ifdef CONFIG_DCA
+	dca_register_notify(&myri10ge_dca_notifier);
+#endif
+
 	return pci_register_driver(&myri10ge_driver);
 }
 
@@ -3394,6 +3991,9 @@ module_init(myri10ge_init_module);
 
 static __exit void myri10ge_cleanup_module(void)
 {
+#ifdef CONFIG_DCA
+	dca_unregister_notify(&myri10ge_dca_notifier);
+#endif
 	pci_unregister_driver(&myri10ge_driver);
 }
 
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index b42c05f..ff44961 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -585,16 +585,13 @@ static inline int rx_refill(struct net_device *ndev, gfp_t gfp)
 	for (i=0; i<NR_RX_DESC; i++) {
 		struct sk_buff *skb;
 		long res;
+
 		/* extra 16 bytes for alignment */
-		skb = __dev_alloc_skb(REAL_RX_BUF_SIZE+16, gfp);
+		skb = __netdev_alloc_skb(ndev, REAL_RX_BUF_SIZE+16, gfp);
 		if (unlikely(!skb))
 			break;
 
-		res = (long)skb->data & 0xf;
-		res = 0x10 - res;
-		res &= 0xf;
-		skb_reserve(skb, res);
-
+		skb_reserve(skb, skb->data - PTR_ALIGN(skb->data, 16));
 		if (gfp != GFP_ATOMIC)
 			spin_lock_irqsave(&dev->rx_info.lock, flags);
 		res = ns83820_add_rx_skb(dev, skb);
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 284217c..d55932a 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -84,4 +84,10 @@ config MDIO_BITBANG
 
 	  If in doubt, say N.
 
+config MDIO_OF_GPIO
+	tristate "Support for GPIO lib-based bitbanged MDIO buses"
+	depends on MDIO_BITBANG && OF_GPIO
+	---help---
+	  Supports GPIO lib-based MDIO busses.
+
 endif # PHYLIB
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 5997d6e..eee329f 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -15,3 +15,4 @@ obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
+obj-$(CONFIG_MDIO_OF_GPIO)	+= mdio-ofgpio.o
diff --git a/drivers/net/phy/mdio-ofgpio.c b/drivers/net/phy/mdio-ofgpio.c
new file mode 100644
index 0000000..7edfc0c
--- /dev/null
+++ b/drivers/net/phy/mdio-ofgpio.c
@@ -0,0 +1,205 @@
+/*
+ * OpenFirmware GPIO based MDIO bitbang driver.
+ *
+ * Copyright (c) 2008 CSE Semaphore Belgium.
+ *  by Laurent Pinchart <laurentp@cse-semaphore.com>
+ *
+ * Based on earlier work by
+ *
+ * Copyright (c) 2003 Intracom S.A.
+ *  by Pantelis Antoniou <panto@intracom.gr>
+ *
+ * 2005 (c) MontaVista Software, Inc.
+ * Vitaly Bordug <vbordug@ru.mvista.com>
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/mdio-bitbang.h>
+#include <linux/of_gpio.h>
+#include <linux/of_platform.h>
+
+struct mdio_gpio_info {
+	struct mdiobb_ctrl ctrl;
+	int mdc, mdio;
+};
+
+static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
+{
+	struct mdio_gpio_info *bitbang =
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	if (dir)
+		gpio_direction_output(bitbang->mdio, 1);
+	else
+		gpio_direction_input(bitbang->mdio);
+}
+
+static int mdio_read(struct mdiobb_ctrl *ctrl)
+{
+	struct mdio_gpio_info *bitbang =
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	return gpio_get_value(bitbang->mdio);
+}
+
+static void mdio(struct mdiobb_ctrl *ctrl, int what)
+{
+	struct mdio_gpio_info *bitbang =
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	gpio_set_value(bitbang->mdio, what);
+}
+
+static void mdc(struct mdiobb_ctrl *ctrl, int what)
+{
+	struct mdio_gpio_info *bitbang =
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	gpio_set_value(bitbang->mdc, what);
+}
+
+static struct mdiobb_ops mdio_gpio_ops = {
+	.owner = THIS_MODULE,
+	.set_mdc = mdc,
+	.set_mdio_dir = mdio_dir,
+	.set_mdio_data = mdio,
+	.get_mdio_data = mdio_read,
+};
+
+static int __devinit mdio_ofgpio_bitbang_init(struct mii_bus *bus,
+                                         struct device_node *np)
+{
+	struct mdio_gpio_info *bitbang = bus->priv;
+
+	bitbang->mdc = of_get_gpio(np, 0);
+	bitbang->mdio = of_get_gpio(np, 1);
+
+	if (bitbang->mdc < 0 || bitbang->mdio < 0)
+		return -ENODEV;
+
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", bitbang->mdc);
+	return 0;
+}
+
+static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
+{
+	const u32 *data;
+	int len, id, irq;
+
+	data = of_get_property(np, "reg", &len);
+	if (!data || len != 4)
+		return;
+
+	id = *data;
+	bus->phy_mask &= ~(1 << id);
+
+	irq = of_irq_to_resource(np, 0, NULL);
+	if (irq != NO_IRQ)
+		bus->irq[id] = irq;
+}
+
+static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
+                                        const struct of_device_id *match)
+{
+	struct device_node *np = NULL;
+	struct mii_bus *new_bus;
+	struct mdio_gpio_info *bitbang;
+	int ret = -ENOMEM;
+	int i;
+
+	bitbang = kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);
+	if (!bitbang)
+		goto out;
+
+	bitbang->ctrl.ops = &mdio_gpio_ops;
+
+	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
+	if (!new_bus)
+		goto out_free_priv;
+
+	new_bus->name = "GPIO Bitbanged MII",
+
+	ret = mdio_ofgpio_bitbang_init(new_bus, ofdev->node);
+	if (ret)
+		goto out_free_bus;
+
+	new_bus->phy_mask = ~0;
+	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!new_bus->irq)
+		goto out_free_bus;
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		new_bus->irq[i] = -1;
+
+	while ((np = of_get_next_child(ofdev->node, np)))
+		if (!strcmp(np->type, "ethernet-phy"))
+			add_phy(new_bus, np);
+
+	new_bus->dev = &ofdev->dev;
+	dev_set_drvdata(&ofdev->dev, new_bus);
+
+	ret = mdiobus_register(new_bus);
+	if (ret)
+		goto out_free_irqs;
+
+	return 0;
+
+out_free_irqs:
+	dev_set_drvdata(&ofdev->dev, NULL);
+	kfree(new_bus->irq);
+out_free_bus:
+	kfree(new_bus);
+out_free_priv:
+	free_mdio_bitbang(new_bus);
+out:
+	return ret;
+}
+
+static int mdio_ofgpio_remove(struct of_device *ofdev)
+{
+	struct mii_bus *bus = dev_get_drvdata(&ofdev->dev);
+	struct mdio_gpio_info *bitbang = bus->priv;
+
+	mdiobus_unregister(bus);
+	free_mdio_bitbang(bus);
+	dev_set_drvdata(&ofdev->dev, NULL);
+	kfree(bus->irq);
+	kfree(bitbang);
+	kfree(bus);
+
+	return 0;
+}
+
+static struct of_device_id mdio_ofgpio_match[] = {
+	{
+		.compatible = "virtual,mdio-gpio",
+	},
+	{},
+};
+
+static struct of_platform_driver mdio_ofgpio_driver = {
+	.name = "mdio-gpio",
+	.match_table = mdio_ofgpio_match,
+	.probe = mdio_ofgpio_probe,
+	.remove = mdio_ofgpio_remove,
+};
+
+static int mdio_ofgpio_init(void)
+{
+	return of_register_platform_driver(&mdio_ofgpio_driver);
+}
+
+static void mdio_ofgpio_exit(void)
+{
+	of_unregister_platform_driver(&mdio_ofgpio_driver);
+}
+
+module_init(mdio_ofgpio_init);
+module_exit(mdio_ofgpio_exit);
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index e365efb..2eb54fd 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -110,7 +110,7 @@ static void gelic_card_get_ether_port_status(struct gelic_card *card,
 void gelic_card_up(struct gelic_card *card)
 {
 	pr_debug("%s: called\n", __func__);
-	down(&card->updown_lock);
+	mutex_lock(&card->updown_lock);
 	if (atomic_inc_return(&card->users) == 1) {
 		pr_debug("%s: real do\n", __func__);
 		/* enable irq */
@@ -120,7 +120,7 @@ void gelic_card_up(struct gelic_card *card)
 
 		napi_enable(&card->napi);
 	}
-	up(&card->updown_lock);
+	mutex_unlock(&card->updown_lock);
 	pr_debug("%s: done\n", __func__);
 }
 
@@ -128,7 +128,7 @@ void gelic_card_down(struct gelic_card *card)
 {
 	u64 mask;
 	pr_debug("%s: called\n", __func__);
-	down(&card->updown_lock);
+	mutex_lock(&card->updown_lock);
 	if (atomic_dec_if_positive(&card->users) == 0) {
 		pr_debug("%s: real do\n", __func__);
 		napi_disable(&card->napi);
@@ -146,7 +146,7 @@ void gelic_card_down(struct gelic_card *card)
 		/* stop tx */
 		gelic_card_disable_txdmac(card);
 	}
-	up(&card->updown_lock);
+	mutex_unlock(&card->updown_lock);
 	pr_debug("%s: done\n", __func__);
 }
 
@@ -1534,7 +1534,7 @@ static struct gelic_card *gelic_alloc_card_net(struct net_device **netdev)
 	INIT_WORK(&card->tx_timeout_task, gelic_net_tx_timeout_task);
 	init_waitqueue_head(&card->waitq);
 	atomic_set(&card->tx_timeout_task_counter, 0);
-	init_MUTEX(&card->updown_lock);
+	mutex_init(&card->updown_lock);
 	atomic_set(&card->users, 0);
 
 	return card;
diff --git a/drivers/net/ps3_gelic_net.h b/drivers/net/ps3_gelic_net.h
index 520f143..8b41386 100644
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -298,7 +298,7 @@ struct gelic_card {
 	wait_queue_head_t waitq;
 
 	/* only first user should up the card */
-	struct semaphore updown_lock;
+	struct mutex updown_lock;
 	atomic_t users;
 
 	u64 ether_port_status;
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index 1dae1f2..e5e0233 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -240,12 +240,12 @@ static u32 gelic_wl_get_link(struct net_device *netdev)
 	u32 ret;
 
 	pr_debug("%s: <-\n", __func__);
-	down(&wl->assoc_stat_lock);
+	mutex_lock(&wl->assoc_stat_lock);
 	if (wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED)
 		ret = 1;
 	else
 		ret = 0;
-	up(&wl->assoc_stat_lock);
+	mutex_unlock(&wl->assoc_stat_lock);
 	pr_debug("%s: ->\n", __func__);
 	return ret;
 }
@@ -695,7 +695,7 @@ static int gelic_wl_get_scan(struct net_device *netdev,
 	unsigned long this_time = jiffies;
 
 	pr_debug("%s: <-\n", __func__);
-	if (down_interruptible(&wl->scan_lock))
+	if (mutex_lock_interruptible(&wl->scan_lock))
 		return -EAGAIN;
 
 	switch (wl->scan_stat) {
@@ -733,7 +733,7 @@ static int gelic_wl_get_scan(struct net_device *netdev,
 	wrqu->data.length = ev - extra;
 	wrqu->data.flags = 0;
 out:
-	up(&wl->scan_lock);
+	mutex_unlock(&wl->scan_lock);
 	pr_debug("%s: -> %d %d\n", __func__, ret, wrqu->data.length);
 	return ret;
 }
@@ -979,7 +979,7 @@ static int gelic_wl_get_essid(struct net_device *netdev,
 	unsigned long irqflag;
 
 	pr_debug("%s: <- \n", __func__);
-	down(&wl->assoc_stat_lock);
+	mutex_lock(&wl->assoc_stat_lock);
 	spin_lock_irqsave(&wl->lock, irqflag);
 	if (test_bit(GELIC_WL_STAT_ESSID_SET, &wl->stat) ||
 	    wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED) {
@@ -989,7 +989,7 @@ static int gelic_wl_get_essid(struct net_device *netdev,
 	} else
 		data->essid.flags = 0;
 
-	up(&wl->assoc_stat_lock);
+	mutex_unlock(&wl->assoc_stat_lock);
 	spin_unlock_irqrestore(&wl->lock, irqflag);
 	pr_debug("%s: -> len=%d \n", __func__, data->essid.length);
 
@@ -1170,7 +1170,7 @@ static int gelic_wl_get_ap(struct net_device *netdev,
 	unsigned long irqflag;
 
 	pr_debug("%s: <-\n", __func__);
-	down(&wl->assoc_stat_lock);
+	mutex_lock(&wl->assoc_stat_lock);
 	spin_lock_irqsave(&wl->lock, irqflag);
 	if (wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED) {
 		data->ap_addr.sa_family = ARPHRD_ETHER;
@@ -1180,7 +1180,7 @@ static int gelic_wl_get_ap(struct net_device *netdev,
 		memset(data->ap_addr.sa_data, 0, ETH_ALEN);
 
 	spin_unlock_irqrestore(&wl->lock, irqflag);
-	up(&wl->assoc_stat_lock);
+	mutex_unlock(&wl->assoc_stat_lock);
 	pr_debug("%s: ->\n", __func__);
 	return 0;
 }
@@ -1554,7 +1554,7 @@ static int gelic_wl_start_scan(struct gelic_wl_info *wl, int always_scan)
 	int ret = 0;
 
 	pr_debug("%s: <- always=%d\n", __func__, always_scan);
-	if (down_interruptible(&wl->scan_lock))
+	if (mutex_lock_interruptible(&wl->scan_lock))
 		return -ERESTARTSYS;
 
 	/*
@@ -1588,7 +1588,7 @@ static int gelic_wl_start_scan(struct gelic_wl_info *wl, int always_scan)
 	}
 	kfree(cmd);
 out:
-	up(&wl->scan_lock);
+	mutex_unlock(&wl->scan_lock);
 	pr_debug("%s: ->\n", __func__);
 	return ret;
 }
@@ -1610,7 +1610,7 @@ static void gelic_wl_scan_complete_event(struct gelic_wl_info *wl)
 	DECLARE_MAC_BUF(mac);
 
 	pr_debug("%s:start\n", __func__);
-	down(&wl->scan_lock);
+	mutex_lock(&wl->scan_lock);
 
 	if (wl->scan_stat != GELIC_WL_SCAN_STAT_SCANNING) {
 		/*
@@ -1727,7 +1727,7 @@ static void gelic_wl_scan_complete_event(struct gelic_wl_info *wl)
 			    NULL);
 out:
 	complete(&wl->scan_done);
-	up(&wl->scan_lock);
+	mutex_unlock(&wl->scan_lock);
 	pr_debug("%s:end\n", __func__);
 }
 
@@ -2151,7 +2151,7 @@ static void gelic_wl_disconnect_event(struct gelic_wl_info *wl,
 	 * As it waits with timeout, just leave assoc_done
 	 * uncompleted, then it terminates with timeout
 	 */
-	if (down_trylock(&wl->assoc_stat_lock)) {
+	if (!mutex_trylock(&wl->assoc_stat_lock)) {
 		pr_debug("%s: already locked\n", __func__);
 		lock = 0;
 	} else {
@@ -2170,7 +2170,7 @@ static void gelic_wl_disconnect_event(struct gelic_wl_info *wl,
 	netif_carrier_off(port_to_netdev(wl_port(wl)));
 
 	if (lock)
-		up(&wl->assoc_stat_lock);
+		mutex_unlock(&wl->assoc_stat_lock);
 }
 /*
  * event worker
@@ -2258,7 +2258,7 @@ static void gelic_wl_assoc_worker(struct work_struct *work)
 
 	wl = container_of(work, struct gelic_wl_info, assoc_work.work);
 
-	down(&wl->assoc_stat_lock);
+	mutex_lock(&wl->assoc_stat_lock);
 
 	if (wl->assoc_stat != GELIC_WL_ASSOC_STAT_DISCONN)
 		goto out;
@@ -2282,7 +2282,7 @@ static void gelic_wl_assoc_worker(struct work_struct *work)
 	wait_for_completion(&wl->scan_done);
 
 	pr_debug("%s: scan done\n", __func__);
-	down(&wl->scan_lock);
+	mutex_lock(&wl->scan_lock);
 	if (wl->scan_stat != GELIC_WL_SCAN_STAT_GOT_LIST) {
 		gelic_wl_send_iwap_event(wl, NULL);
 		pr_info("%s: no scan list. association failed\n", __func__);
@@ -2302,9 +2302,9 @@ static void gelic_wl_assoc_worker(struct work_struct *work)
 	if (ret)
 		pr_info("%s: association failed %d\n", __func__, ret);
 scan_lock_out:
-	up(&wl->scan_lock);
+	mutex_unlock(&wl->scan_lock);
 out:
-	up(&wl->assoc_stat_lock);
+	mutex_unlock(&wl->assoc_stat_lock);
 }
 /*
  * Interrupt handler
@@ -2431,8 +2431,8 @@ static struct net_device *gelic_wl_alloc(struct gelic_card *card)
 
 	INIT_DELAYED_WORK(&wl->event_work, gelic_wl_event_worker);
 	INIT_DELAYED_WORK(&wl->assoc_work, gelic_wl_assoc_worker);
-	init_MUTEX(&wl->scan_lock);
-	init_MUTEX(&wl->assoc_stat_lock);
+	mutex_init(&wl->scan_lock);
+	mutex_init(&wl->assoc_stat_lock);
 
 	init_completion(&wl->scan_done);
 	/* for the case that no scan request is issued and stop() is called */
diff --git a/drivers/net/ps3_gelic_wireless.h b/drivers/net/ps3_gelic_wireless.h
index 1036971..bc73063 100644
--- a/drivers/net/ps3_gelic_wireless.h
+++ b/drivers/net/ps3_gelic_wireless.h
@@ -241,7 +241,7 @@ enum gelic_wl_assoc_state {
 #define GELIC_WEP_KEYS 4
 struct gelic_wl_info {
 	/* bss list */
-	struct semaphore scan_lock;
+	struct mutex scan_lock;
 	struct list_head network_list;
 	struct list_head network_free_list;
 	struct gelic_wl_scan_info *networks;
@@ -266,7 +266,7 @@ struct gelic_wl_info {
 	enum gelic_wl_wpa_level wpa_level; /* wpa/wpa2 */
 
 	/* association handling */
-	struct semaphore assoc_stat_lock;
+	struct mutex assoc_stat_lock;
 	struct delayed_work assoc_work;
 	enum gelic_wl_assoc_state assoc_stat;
 	struct completion assoc_done;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 326c941..dcc953e 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -6997,7 +6997,7 @@ static  int rxd_owner_bit_reset(struct s2io_nic *sp)
 						       &skb,(u64 *)&temp0_64,
 						       (u64 *)&temp1_64,
 						       (u64 *)&temp2_64,
-							size) == ENOMEM) {
+							size) == -ENOMEM) {
 					return 0;
 				}
 
diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index dbad95c..3be13b5 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -4,6 +4,8 @@ config SFC
 	select MII
 	select INET_LRO
 	select CRC32
+	select I2C
+	select I2C_ALGOBIT
 	help
 	  This driver supports 10-gigabit Ethernet cards based on
 	  the Solarflare Communications Solarstorm SFC4000 controller.
diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index 1d2daee..c8f5704 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,5 +1,5 @@
 sfc-y			+= efx.o falcon.o tx.o rx.o falcon_xmac.o \
-			   i2c-direct.o selftest.o ethtool.o xfp_phy.o \
+			   selftest.o ethtool.o xfp_phy.o \
 			   mdio_10g.o tenxpress.o boards.o sfe4001.o
 
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index 7fc0328..d3d3dd0 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -109,7 +109,7 @@ static struct efx_board_data board_data[] = {
 	[EFX_BOARD_INVALID] =
 	{NULL,	    NULL,                  dummy_init},
 	[EFX_BOARD_SFE4001] =
-	{"SFE4001", "10GBASE-T adapter",   sfe4001_poweron},
+	{"SFE4001", "10GBASE-T adapter",   sfe4001_init},
 	[EFX_BOARD_SFE4002] =
 	{"SFE4002", "XFP adapter",         sfe4002_init},
 };
diff --git a/drivers/net/sfc/boards.h b/drivers/net/sfc/boards.h
index 695764d..e5e8443 100644
--- a/drivers/net/sfc/boards.h
+++ b/drivers/net/sfc/boards.h
@@ -20,8 +20,7 @@ enum efx_board_type {
 };
 
 extern int efx_set_board_info(struct efx_nic *efx, u16 revision_info);
-extern int sfe4001_poweron(struct efx_nic *efx);
-extern void sfe4001_poweroff(struct efx_nic *efx);
+extern int sfe4001_init(struct efx_nic *efx);
 /* Are we putting the PHY into flash config mode */
 extern unsigned int sfe4001_phy_flash_cfg;
 
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 4497606..74265d8 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1815,6 +1815,7 @@ static struct efx_board efx_dummy_board_info = {
 	.init    = efx_nic_dummy_op_int,
 	.init_leds = efx_port_dummy_op_int,
 	.set_fault_led = efx_port_dummy_op_blink,
+	.fini	= efx_port_dummy_op_void,
 };
 
 /**************************************************************************
@@ -1941,6 +1942,7 @@ static void efx_pci_remove_main(struct efx_nic *efx)
 	efx_fini_port(efx);
 
 	/* Shutdown the board, then the NIC and board state */
+	efx->board_info.fini(efx);
 	falcon_fini_interrupt(efx);
 
 	efx_fini_napi(efx);
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index d3f749c..8cb5798 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -13,6 +13,8 @@
 #include <linux/pci.h>
 #include <linux/module.h>
 #include <linux/seq_file.h>
+#include <linux/i2c.h>
+#include <linux/i2c-algo-bit.h>
 #include "net_driver.h"
 #include "bitfield.h"
 #include "efx.h"
@@ -36,10 +38,12 @@
  * struct falcon_nic_data - Falcon NIC state
  * @next_buffer_table: First available buffer table id
  * @pci_dev2: The secondary PCI device if present
+ * @i2c_data: Operations and state for I2C bit-bashing algorithm
  */
 struct falcon_nic_data {
 	unsigned next_buffer_table;
 	struct pci_dev *pci_dev2;
+	struct i2c_algo_bit_data i2c_data;
 };
 
 /**************************************************************************
@@ -175,39 +179,57 @@ static inline int falcon_event_present(efx_qword_t *event)
  *
  **************************************************************************
  */
-static void falcon_setsdascl(struct efx_i2c_interface *i2c)
+static void falcon_setsda(void *data, int state)
 {
+	struct efx_nic *efx = (struct efx_nic *)data;
 	efx_oword_t reg;
 
-	falcon_read(i2c->efx, &reg, GPIO_CTL_REG_KER);
-	EFX_SET_OWORD_FIELD(reg, GPIO0_OEN, (i2c->scl ? 0 : 1));
-	EFX_SET_OWORD_FIELD(reg, GPIO3_OEN, (i2c->sda ? 0 : 1));
-	falcon_write(i2c->efx, &reg, GPIO_CTL_REG_KER);
+	falcon_read(efx, &reg, GPIO_CTL_REG_KER);
+	EFX_SET_OWORD_FIELD(reg, GPIO3_OEN, !state);
+	falcon_write(efx, &reg, GPIO_CTL_REG_KER);
 }
 
-static int falcon_getsda(struct efx_i2c_interface *i2c)
+static void falcon_setscl(void *data, int state)
 {
+	struct efx_nic *efx = (struct efx_nic *)data;
 	efx_oword_t reg;
 
-	falcon_read(i2c->efx, &reg, GPIO_CTL_REG_KER);
+	falcon_read(efx, &reg, GPIO_CTL_REG_KER);
+	EFX_SET_OWORD_FIELD(reg, GPIO0_OEN, !state);
+	falcon_write(efx, &reg, GPIO_CTL_REG_KER);
+}
+
+static int falcon_getsda(void *data)
+{
+	struct efx_nic *efx = (struct efx_nic *)data;
+	efx_oword_t reg;
+
+	falcon_read(efx, &reg, GPIO_CTL_REG_KER);
 	return EFX_OWORD_FIELD(reg, GPIO3_IN);
 }
 
-static int falcon_getscl(struct efx_i2c_interface *i2c)
+static int falcon_getscl(void *data)
 {
+	struct efx_nic *efx = (struct efx_nic *)data;
 	efx_oword_t reg;
 
-	falcon_read(i2c->efx, &reg, GPIO_CTL_REG_KER);
-	return EFX_DWORD_FIELD(reg, GPIO0_IN);
+	falcon_read(efx, &reg, GPIO_CTL_REG_KER);
+	return EFX_OWORD_FIELD(reg, GPIO0_IN);
 }
 
-static struct efx_i2c_bit_operations falcon_i2c_bit_operations = {
-	.setsda		= falcon_setsdascl,
-	.setscl		= falcon_setsdascl,
+static struct i2c_algo_bit_data falcon_i2c_bit_operations = {
+	.setsda		= falcon_setsda,
+	.setscl		= falcon_setscl,
 	.getsda		= falcon_getsda,
 	.getscl		= falcon_getscl,
-	.udelay		= 100,
-	.mdelay		= 10,
+	.udelay		= 5,
+	/*
+	 * This is the number of system clock ticks after which
+	 * i2c-algo-bit gives up waiting for SCL to become high.
+	 * It must be at least 2 since the first tick can happen
+	 * immediately after it starts waiting.
+	 */
+	.timeout	= 2,
 };
 
 /**************************************************************************
@@ -2403,12 +2425,6 @@ int falcon_probe_nic(struct efx_nic *efx)
 	struct falcon_nic_data *nic_data;
 	int rc;
 
-	/* Initialise I2C interface state */
-	efx->i2c.efx = efx;
-	efx->i2c.op = &falcon_i2c_bit_operations;
-	efx->i2c.sda = 1;
-	efx->i2c.scl = 1;
-
 	/* Allocate storage for hardware specific data */
 	nic_data = kzalloc(sizeof(*nic_data), GFP_KERNEL);
 	efx->nic_data = nic_data;
@@ -2459,6 +2475,18 @@ int falcon_probe_nic(struct efx_nic *efx)
 	if (rc)
 		goto fail5;
 
+	/* Initialise I2C adapter */
+ 	efx->i2c_adap.owner = THIS_MODULE;
+ 	efx->i2c_adap.class = I2C_CLASS_HWMON;
+	nic_data->i2c_data = falcon_i2c_bit_operations;
+	nic_data->i2c_data.data = efx;
+ 	efx->i2c_adap.algo_data = &nic_data->i2c_data;
+	efx->i2c_adap.dev.parent = &efx->pci_dev->dev;
+	strcpy(efx->i2c_adap.name, "SFC4000 GPIO");
+	rc = i2c_bit_add_bus(&efx->i2c_adap);
+	if (rc)
+		goto fail5;
+
 	return 0;
 
  fail5:
@@ -2633,6 +2661,10 @@ int falcon_init_nic(struct efx_nic *efx)
 void falcon_remove_nic(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	rc = i2c_del_adapter(&efx->i2c_adap);
+	BUG_ON(rc);
 
 	falcon_free_buffer(efx, &efx->irq_status);
 
diff --git a/drivers/net/sfc/i2c-direct.c b/drivers/net/sfc/i2c-direct.c
deleted file mode 100644
index b6c62d0..0000000
--- a/drivers/net/sfc/i2c-direct.c
+++ /dev/null
@@ -1,381 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2005 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#include <linux/delay.h>
-#include "net_driver.h"
-#include "i2c-direct.h"
-
-/*
- * I2C data (SDA) and clock (SCL) line read/writes with appropriate
- * delays.
- */
-
-static inline void setsda(struct efx_i2c_interface *i2c, int state)
-{
-	udelay(i2c->op->udelay);
-	i2c->sda = state;
-	i2c->op->setsda(i2c);
-	udelay(i2c->op->udelay);
-}
-
-static inline void setscl(struct efx_i2c_interface *i2c, int state)
-{
-	udelay(i2c->op->udelay);
-	i2c->scl = state;
-	i2c->op->setscl(i2c);
-	udelay(i2c->op->udelay);
-}
-
-static inline int getsda(struct efx_i2c_interface *i2c)
-{
-	int sda;
-
-	udelay(i2c->op->udelay);
-	sda = i2c->op->getsda(i2c);
-	udelay(i2c->op->udelay);
-	return sda;
-}
-
-static inline int getscl(struct efx_i2c_interface *i2c)
-{
-	int scl;
-
-	udelay(i2c->op->udelay);
-	scl = i2c->op->getscl(i2c);
-	udelay(i2c->op->udelay);
-	return scl;
-}
-
-/*
- * I2C low-level protocol operations
- *
- */
-
-static inline void i2c_release(struct efx_i2c_interface *i2c)
-{
-	EFX_WARN_ON_PARANOID(!i2c->scl);
-	EFX_WARN_ON_PARANOID(!i2c->sda);
-	/* Devices may time out if operations do not end */
-	setscl(i2c, 1);
-	setsda(i2c, 1);
-	EFX_BUG_ON_PARANOID(getsda(i2c) != 1);
-	EFX_BUG_ON_PARANOID(getscl(i2c) != 1);
-}
-
-static inline void i2c_start(struct efx_i2c_interface *i2c)
-{
-	/* We may be restarting immediately after a {send,recv}_bit,
-	 * so SCL will not necessarily already be high.
-	 */
-	EFX_WARN_ON_PARANOID(!i2c->sda);
-	setscl(i2c, 1);
-	setsda(i2c, 0);
-	setscl(i2c, 0);
-	setsda(i2c, 1);
-}
-
-static inline void i2c_send_bit(struct efx_i2c_interface *i2c, int bit)
-{
-	EFX_WARN_ON_PARANOID(i2c->scl != 0);
-	setsda(i2c, bit);
-	setscl(i2c, 1);
-	setscl(i2c, 0);
-	setsda(i2c, 1);
-}
-
-static inline int i2c_recv_bit(struct efx_i2c_interface *i2c)
-{
-	int bit;
-
-	EFX_WARN_ON_PARANOID(i2c->scl != 0);
-	EFX_WARN_ON_PARANOID(!i2c->sda);
-	setscl(i2c, 1);
-	bit = getsda(i2c);
-	setscl(i2c, 0);
-	return bit;
-}
-
-static inline void i2c_stop(struct efx_i2c_interface *i2c)
-{
-	EFX_WARN_ON_PARANOID(i2c->scl != 0);
-	setsda(i2c, 0);
-	setscl(i2c, 1);
-	setsda(i2c, 1);
-}
-
-/*
- * I2C mid-level protocol operations
- *
- */
-
-/* Sends a byte via the I2C bus and checks for an acknowledgement from
- * the slave device.
- */
-static int i2c_send_byte(struct efx_i2c_interface *i2c, u8 byte)
-{
-	int i;
-
-	/* Send byte */
-	for (i = 0; i < 8; i++) {
-		i2c_send_bit(i2c, !!(byte & 0x80));
-		byte <<= 1;
-	}
-
-	/* Check for acknowledgement from slave */
-	return (i2c_recv_bit(i2c) == 0 ? 0 : -EIO);
-}
-
-/* Receives a byte via the I2C bus and sends ACK/NACK to the slave device. */
-static u8 i2c_recv_byte(struct efx_i2c_interface *i2c, int ack)
-{
-	u8 value = 0;
-	int i;
-
-	/* Receive byte */
-	for (i = 0; i < 8; i++)
-		value = (value << 1) | i2c_recv_bit(i2c);
-
-	/* Send ACK/NACK */
-	i2c_send_bit(i2c, (ack ? 0 : 1));
-
-	return value;
-}
-
-/* Calculate command byte for a read operation */
-static inline u8 i2c_read_cmd(u8 device_id)
-{
-	return ((device_id << 1) | 1);
-}
-
-/* Calculate command byte for a write operation */
-static inline u8 i2c_write_cmd(u8 device_id)
-{
-	return ((device_id << 1) | 0);
-}
-
-int efx_i2c_check_presence(struct efx_i2c_interface *i2c, u8 device_id)
-{
-	int rc;
-
-	/* If someone is driving the bus low we just give up. */
-	if (getsda(i2c) == 0 || getscl(i2c) == 0) {
-		EFX_ERR(i2c->efx, "%s someone is holding the I2C bus low."
-			" Giving up.\n", __func__);
-		return -EFAULT;
-	}
-
-	/* Pretend to initiate a device write */
-	i2c_start(i2c);
-	rc = i2c_send_byte(i2c, i2c_write_cmd(device_id));
-	if (rc)
-		goto out;
-
- out:
-	i2c_stop(i2c);
-	i2c_release(i2c);
-
-	return rc;
-}
-
-/* This performs a fast read of one or more consecutive bytes from an
- * I2C device.  Not all devices support consecutive reads of more than
- * one byte; for these devices use efx_i2c_read() instead.
- */
-int efx_i2c_fast_read(struct efx_i2c_interface *i2c,
-		      u8 device_id, u8 offset, u8 *data, unsigned int len)
-{
-	int i;
-	int rc;
-
-	EFX_WARN_ON_PARANOID(getsda(i2c) != 1);
-	EFX_WARN_ON_PARANOID(getscl(i2c) != 1);
-	EFX_WARN_ON_PARANOID(data == NULL);
-	EFX_WARN_ON_PARANOID(len < 1);
-
-	/* Select device and starting offset */
-	i2c_start(i2c);
-	rc = i2c_send_byte(i2c, i2c_write_cmd(device_id));
-	if (rc)
-		goto out;
-	rc = i2c_send_byte(i2c, offset);
-	if (rc)
-		goto out;
-
-	/* Read data from device */
-	i2c_start(i2c);
-	rc = i2c_send_byte(i2c, i2c_read_cmd(device_id));
-	if (rc)
-		goto out;
-	for (i = 0; i < (len - 1); i++)
-		/* Read and acknowledge all but the last byte */
-		data[i] = i2c_recv_byte(i2c, 1);
-	/* Read last byte with no acknowledgement */
-	data[i] = i2c_recv_byte(i2c, 0);
-
- out:
-	i2c_stop(i2c);
-	i2c_release(i2c);
-
-	return rc;
-}
-
-/* This performs a fast write of one or more consecutive bytes to an
- * I2C device.  Not all devices support consecutive writes of more
- * than one byte; for these devices use efx_i2c_write() instead.
- */
-int efx_i2c_fast_write(struct efx_i2c_interface *i2c,
-		       u8 device_id, u8 offset,
-		       const u8 *data, unsigned int len)
-{
-	int i;
-	int rc;
-
-	EFX_WARN_ON_PARANOID(getsda(i2c) != 1);
-	EFX_WARN_ON_PARANOID(getscl(i2c) != 1);
-	EFX_WARN_ON_PARANOID(len < 1);
-
-	/* Select device and starting offset */
-	i2c_start(i2c);
-	rc = i2c_send_byte(i2c, i2c_write_cmd(device_id));
-	if (rc)
-		goto out;
-	rc = i2c_send_byte(i2c, offset);
-	if (rc)
-		goto out;
-
-	/* Write data to device */
-	for (i = 0; i < len; i++) {
-		rc = i2c_send_byte(i2c, data[i]);
-		if (rc)
-			goto out;
-	}
-
- out:
-	i2c_stop(i2c);
-	i2c_release(i2c);
-
-	return rc;
-}
-
-/* I2C byte-by-byte read */
-int efx_i2c_read(struct efx_i2c_interface *i2c,
-		 u8 device_id, u8 offset, u8 *data, unsigned int len)
-{
-	int rc;
-
-	/* i2c_fast_read with length 1 is a single byte read */
-	for (; len > 0; offset++, data++, len--) {
-		rc = efx_i2c_fast_read(i2c, device_id, offset, data, 1);
-		if (rc)
-			return rc;
-	}
-
-	return 0;
-}
-
-/* I2C byte-by-byte write */
-int efx_i2c_write(struct efx_i2c_interface *i2c,
-		  u8 device_id, u8 offset, const u8 *data, unsigned int len)
-{
-	int rc;
-
-	/* i2c_fast_write with length 1 is a single byte write */
-	for (; len > 0; offset++, data++, len--) {
-		rc = efx_i2c_fast_write(i2c, device_id, offset, data, 1);
-		if (rc)
-			return rc;
-		mdelay(i2c->op->mdelay);
-	}
-
-	return 0;
-}
-
-
-/* This is just a slightly neater wrapper round efx_i2c_fast_write
- * in the case where the target doesn't take an offset
- */
-int efx_i2c_send_bytes(struct efx_i2c_interface *i2c,
-		       u8 device_id, const u8 *data, unsigned int len)
-{
-	return efx_i2c_fast_write(i2c, device_id, data[0], data + 1, len - 1);
-}
-
-/* I2C receiving of bytes - does not send an offset byte */
-int efx_i2c_recv_bytes(struct efx_i2c_interface *i2c, u8 device_id,
-		       u8 *bytes, unsigned int len)
-{
-	int i;
-	int rc;
-
-	EFX_WARN_ON_PARANOID(getsda(i2c) != 1);
-	EFX_WARN_ON_PARANOID(getscl(i2c) != 1);
-	EFX_WARN_ON_PARANOID(len < 1);
-
-	/* Select device */
-	i2c_start(i2c);
-
-	/* Read data from device */
-	rc = i2c_send_byte(i2c, i2c_read_cmd(device_id));
-	if (rc)
-		goto out;
-
-	for (i = 0; i < (len - 1); i++)
-		/* Read and acknowledge all but the last byte */
-		bytes[i] = i2c_recv_byte(i2c, 1);
-	/* Read last byte with no acknowledgement */
-	bytes[i] = i2c_recv_byte(i2c, 0);
-
- out:
-	i2c_stop(i2c);
-	i2c_release(i2c);
-
-	return rc;
-}
-
-/* SMBus and some I2C devices will time out if the I2C clock is
- * held low for too long. This is most likely to happen in virtualised
- * systems (when the entire domain is descheduled) but could in
- * principle happen due to preemption on any busy system (and given the
- * potential length of an I2C operation turning preemption off is not
- * a sensible option). The following functions deal with the failure by
- * retrying up to a fixed number of times.
-  */
-
-#define I2C_MAX_RETRIES	(10)
-
-/* The timeout problem will result in -EIO. If the wrapped function
- * returns any other error, pass this up and do not retry. */
-#define RETRY_WRAPPER(_f) \
-	int retries = I2C_MAX_RETRIES; \
-	int rc; \
-	while (retries) { \
-		rc = _f; \
-		if (rc != -EIO) \
-			return rc; \
-		retries--; \
-	} \
-	return rc; \
-
-int efx_i2c_check_presence_retry(struct efx_i2c_interface *i2c, u8 device_id)
-{
-	RETRY_WRAPPER(efx_i2c_check_presence(i2c, device_id))
-}
-
-int efx_i2c_read_retry(struct efx_i2c_interface *i2c,
-		 u8 device_id, u8 offset, u8 *data, unsigned int len)
-{
-	RETRY_WRAPPER(efx_i2c_read(i2c, device_id, offset, data, len))
-}
-
-int efx_i2c_write_retry(struct efx_i2c_interface *i2c,
-		  u8 device_id, u8 offset, const u8 *data, unsigned int len)
-{
-	RETRY_WRAPPER(efx_i2c_write(i2c, device_id, offset, data, len))
-}
diff --git a/drivers/net/sfc/i2c-direct.h b/drivers/net/sfc/i2c-direct.h
deleted file mode 100644
index 291e561..0000000
--- a/drivers/net/sfc/i2c-direct.h
+++ /dev/null
@@ -1,91 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2005 Fen Systems Ltd.
- * Copyright 2006 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#ifndef EFX_I2C_DIRECT_H
-#define EFX_I2C_DIRECT_H
-
-#include "net_driver.h"
-
-/*
- * Direct control of an I2C bus
- */
-
-struct efx_i2c_interface;
-
-/**
- * struct efx_i2c_bit_operations - I2C bus direct control methods
- *
- * I2C bus direct control methods.
- *
- * @setsda: Set state of SDA line
- * @setscl: Set state of SCL line
- * @getsda: Get state of SDA line
- * @getscl: Get state of SCL line
- * @udelay: Delay between each bit operation
- * @mdelay: Delay between each byte write
- */
-struct efx_i2c_bit_operations {
-	void (*setsda) (struct efx_i2c_interface *i2c);
-	void (*setscl) (struct efx_i2c_interface *i2c);
-	int (*getsda) (struct efx_i2c_interface *i2c);
-	int (*getscl) (struct efx_i2c_interface *i2c);
-	unsigned int udelay;
-	unsigned int mdelay;
-};
-
-/**
- * struct efx_i2c_interface - an I2C interface
- *
- * An I2C interface.
- *
- * @efx: Attached Efx NIC
- * @op: I2C bus control methods
- * @sda: Current output state of SDA line
- * @scl: Current output state of SCL line
- */
-struct efx_i2c_interface {
-	struct efx_nic *efx;
-	struct efx_i2c_bit_operations *op;
-	unsigned int sda:1;
-	unsigned int scl:1;
-};
-
-extern int efx_i2c_check_presence(struct efx_i2c_interface *i2c, u8 device_id);
-extern int efx_i2c_fast_read(struct efx_i2c_interface *i2c,
-			     u8 device_id, u8 offset,
-			     u8 *data, unsigned int len);
-extern int efx_i2c_fast_write(struct efx_i2c_interface *i2c,
-			      u8 device_id, u8 offset,
-			      const u8 *data, unsigned int len);
-extern int efx_i2c_read(struct efx_i2c_interface *i2c,
-			u8 device_id, u8 offset, u8 *data, unsigned int len);
-extern int efx_i2c_write(struct efx_i2c_interface *i2c,
-			 u8 device_id, u8 offset,
-			 const u8 *data, unsigned int len);
-
-extern int efx_i2c_send_bytes(struct efx_i2c_interface *i2c, u8 device_id,
-			      const u8 *bytes, unsigned int len);
-
-extern int efx_i2c_recv_bytes(struct efx_i2c_interface *i2c, u8 device_id,
-			      u8 *bytes, unsigned int len);
-
-
-/* Versions of the API that retry on failure. */
-extern int efx_i2c_check_presence_retry(struct efx_i2c_interface *i2c,
-					u8 device_id);
-
-extern int efx_i2c_read_retry(struct efx_i2c_interface *i2c,
-			u8 device_id, u8 offset, u8 *data, unsigned int len);
-
-extern int efx_i2c_write_retry(struct efx_i2c_interface *i2c,
-			 u8 device_id, u8 offset,
-			 const u8 *data, unsigned int len);
-
-#endif /* EFX_I2C_DIRECT_H */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 5e20e75..d803b86 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -26,10 +26,10 @@
 #include <linux/highmem.h>
 #include <linux/workqueue.h>
 #include <linux/inet_lro.h>
+#include <linux/i2c.h>
 
 #include "enum.h"
 #include "bitfield.h"
-#include "i2c-direct.h"
 
 #define EFX_MAX_LRO_DESCRIPTORS 8
 #define EFX_MAX_LRO_AGGR MAX_SKB_FRAGS
@@ -418,7 +418,10 @@ struct efx_blinker {
  * @init_leds: Sets up board LEDs
  * @set_fault_led: Turns the fault LED on or off
  * @blink: Starts/stops blinking
+ * @fini: Cleanup function
  * @blinker: used to blink LEDs in software
+ * @hwmon_client: I2C client for hardware monitor
+ * @ioexp_client: I2C client for power/port control
  */
 struct efx_board {
 	int type;
@@ -431,7 +434,9 @@ struct efx_board {
 	int (*init_leds)(struct efx_nic *efx);
 	void (*set_fault_led) (struct efx_nic *efx, int state);
 	void (*blink) (struct efx_nic *efx, int start);
+	void (*fini) (struct efx_nic *nic);
 	struct efx_blinker blinker;
+	struct i2c_client *hwmon_client, *ioexp_client;
 };
 
 #define STRING_TABLE_LOOKUP(val, member)	\
@@ -618,7 +623,7 @@ union efx_multicast_hash {
  * @membase: Memory BAR value
  * @biu_lock: BIU (bus interface unit) lock
  * @interrupt_mode: Interrupt mode
- * @i2c: I2C interface
+ * @i2c_adap: I2C adapter
  * @board_info: Board-level information
  * @state: Device state flag. Serialised by the rtnl_lock.
  * @reset_pending: Pending reset method (normally RESET_TYPE_NONE)
@@ -686,7 +691,7 @@ struct efx_nic {
 	spinlock_t biu_lock;
 	enum efx_int_mode interrupt_mode;
 
-	struct efx_i2c_interface i2c;
+	struct i2c_adapter i2c_adap;
 	struct efx_board board_info;
 
 	enum nic_state state;
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index 66a0d14..b278495 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -106,28 +106,27 @@
 
 static const u8 xgphy_max_temperature = 90;
 
-void sfe4001_poweroff(struct efx_nic *efx)
+static void sfe4001_poweroff(struct efx_nic *efx)
 {
-	struct efx_i2c_interface *i2c = &efx->i2c;
+	struct i2c_client *ioexp_client = efx->board_info.ioexp_client;
+	struct i2c_client *hwmon_client = efx->board_info.hwmon_client;
 
-	u8 cfg, out, in;
+	/* Turn off all power rails and disable outputs */
+	i2c_smbus_write_byte_data(ioexp_client, P0_OUT, 0xff);
+	i2c_smbus_write_byte_data(ioexp_client, P1_CONFIG, 0xff);
+	i2c_smbus_write_byte_data(ioexp_client, P0_CONFIG, 0xff);
 
-	EFX_INFO(efx, "%s\n", __func__);
-
-	/* Turn off all power rails */
-	out = 0xff;
-	efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
-
-	/* Disable port 1 outputs on IO expander */
-	cfg = 0xff;
-	efx_i2c_write(i2c, PCA9539, P1_CONFIG, &cfg, 1);
+	/* Clear any over-temperature alert */
+	i2c_smbus_read_byte_data(hwmon_client, RSL);
+}
 
-	/* Disable port 0 outputs on IO expander */
-	cfg = 0xff;
-	efx_i2c_write(i2c, PCA9539, P0_CONFIG, &cfg, 1);
+static void sfe4001_fini(struct efx_nic *efx)
+{
+	EFX_INFO(efx, "%s\n", __func__);
 
-	/* Clear any over-temperature alert */
-	efx_i2c_read(i2c, MAX6647, RSL, &in, 1);
+	sfe4001_poweroff(efx);
+ 	i2c_unregister_device(efx->board_info.ioexp_client);
+ 	i2c_unregister_device(efx->board_info.hwmon_client);
 }
 
 /* The P0_EN_3V3X line on SFE4001 boards (from A2 onward) is connected
@@ -143,14 +142,26 @@ MODULE_PARM_DESC(phy_flash_cfg,
  * be turned on before the PHY can be used.
  * Context: Process context, rtnl lock held
  */
-int sfe4001_poweron(struct efx_nic *efx)
+int sfe4001_init(struct efx_nic *efx)
 {
-	struct efx_i2c_interface *i2c = &efx->i2c;
+	struct i2c_client *hwmon_client, *ioexp_client;
 	unsigned int count;
 	int rc;
-	u8 out, in, cfg;
+	u8 out;
 	efx_dword_t reg;
 
+	hwmon_client = i2c_new_dummy(&efx->i2c_adap, MAX6647);
+	if (!hwmon_client)
+		return -EIO;
+	efx->board_info.hwmon_client = hwmon_client;
+
+	ioexp_client = i2c_new_dummy(&efx->i2c_adap, PCA9539);
+	if (!ioexp_client) {
+		rc = -EIO;
+		goto fail_hwmon;
+	}
+	efx->board_info.ioexp_client = ioexp_client;
+
 	/* 10Xpress has fixed-function LED pins, so there is no board-specific
 	 * blink code. */
 	efx->board_info.blink = tenxpress_phy_blink;
@@ -166,44 +177,45 @@ int sfe4001_poweron(struct efx_nic *efx)
 	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
 	udelay(10);
 
+	efx->board_info.fini = sfe4001_fini;
+
 	/* Set DSP over-temperature alert threshold */
 	EFX_INFO(efx, "DSP cut-out at %dC\n", xgphy_max_temperature);
-	rc = efx_i2c_write(i2c, MAX6647, WLHO,
-			   &xgphy_max_temperature, 1);
+	rc = i2c_smbus_write_byte_data(hwmon_client, WLHO,
+				       xgphy_max_temperature);
 	if (rc)
-		goto fail1;
+		goto fail_ioexp;
 
 	/* Read it back and verify */
-	rc = efx_i2c_read(i2c, MAX6647, RLHN, &in, 1);
-	if (rc)
-		goto fail1;
-	if (in != xgphy_max_temperature) {
+	rc = i2c_smbus_read_byte_data(hwmon_client, RLHN);
+	if (rc < 0)
+		goto fail_ioexp;
+	if (rc != xgphy_max_temperature) {
 		rc = -EFAULT;
-		goto fail1;
+		goto fail_ioexp;
 	}
 
 	/* Clear any previous over-temperature alert */
-	rc = efx_i2c_read(i2c, MAX6647, RSL, &in, 1);
-	if (rc)
-		goto fail1;
+	rc = i2c_smbus_read_byte_data(hwmon_client, RSL);
+	if (rc < 0)
+		goto fail_ioexp;
 
 	/* Enable port 0 and port 1 outputs on IO expander */
-	cfg = 0x00;
-	rc = efx_i2c_write(i2c, PCA9539, P0_CONFIG, &cfg, 1);
+	rc = i2c_smbus_write_byte_data(ioexp_client, P0_CONFIG, 0x00);
 	if (rc)
-		goto fail1;
-	cfg = 0xff & ~(1 << P1_SPARE_LBN);
-	rc = efx_i2c_write(i2c, PCA9539, P1_CONFIG, &cfg, 1);
+		goto fail_ioexp;
+	rc = i2c_smbus_write_byte_data(ioexp_client, P1_CONFIG,
+				       0xff & ~(1 << P1_SPARE_LBN));
 	if (rc)
-		goto fail2;
+		goto fail_on;
 
 	/* Turn all power off then wait 1 sec. This ensures PHY is reset */
 	out = 0xff & ~((0 << P0_EN_1V2_LBN) | (0 << P0_EN_2V5_LBN) |
 		       (0 << P0_EN_3V3X_LBN) | (0 << P0_EN_5V_LBN) |
 		       (0 << P0_EN_1V0X_LBN));
-	rc = efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+	rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
 	if (rc)
-		goto fail3;
+		goto fail_on;
 
 	schedule_timeout_uninterruptible(HZ);
 	count = 0;
@@ -215,26 +227,26 @@ int sfe4001_poweron(struct efx_nic *efx)
 		if (sfe4001_phy_flash_cfg)
 			out |= 1 << P0_EN_3V3X_LBN;
 
-		rc = efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+		rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
 		if (rc)
-			goto fail3;
+			goto fail_on;
 		msleep(10);
 
 		/* Turn on 1V power rail */
 		out &= ~(1 << P0_EN_1V0X_LBN);
-		rc = efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+		rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
 		if (rc)
-			goto fail3;
+			goto fail_on;
 
 		EFX_INFO(efx, "waiting for power (attempt %d)...\n", count);
 
 		schedule_timeout_uninterruptible(HZ);
 
 		/* Check DSP is powered */
-		rc = efx_i2c_read(i2c, PCA9539, P1_IN, &in, 1);
-		if (rc)
-			goto fail3;
-		if (in & (1 << P1_AFE_PWD_LBN))
+		rc = i2c_smbus_read_byte_data(ioexp_client, P1_IN);
+		if (rc < 0)
+			goto fail_on;
+		if (rc & (1 << P1_AFE_PWD_LBN))
 			goto done;
 
 		/* DSP doesn't look powered in flash config mode */
@@ -244,23 +256,17 @@ int sfe4001_poweron(struct efx_nic *efx)
 
 	EFX_INFO(efx, "timed out waiting for power\n");
 	rc = -ETIMEDOUT;
-	goto fail3;
+	goto fail_on;
 
 done:
 	EFX_INFO(efx, "PHY is powered on\n");
 	return 0;
 
-fail3:
-	/* Turn off all power rails */
-	out = 0xff;
-	efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
-	/* Disable port 1 outputs on IO expander */
-	out = 0xff;
-	efx_i2c_write(i2c, PCA9539, P1_CONFIG, &out, 1);
-fail2:
-	/* Disable port 0 outputs on IO expander */
-	out = 0xff;
-	efx_i2c_write(i2c, PCA9539, P0_CONFIG, &out, 1);
-fail1:
+fail_on:
+	sfe4001_poweroff(efx);
+fail_ioexp:
+ 	i2c_unregister_device(ioexp_client);
+fail_hwmon:
+ 	i2c_unregister_device(hwmon_client);
 	return rc;
 }
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 535f6cc..c83406f 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -284,6 +284,86 @@ static void sky2_power_aux(struct sky2_hw *hw)
 			     PC_VAUX_ON | PC_VCC_OFF));
 }
 
+static void sky2_power_state(struct sky2_hw *hw, pci_power_t state)
+{
+	u16 power_control = sky2_pci_read16(hw, hw->pm_cap + PCI_PM_CTRL);
+	int pex = pci_find_capability(hw->pdev, PCI_CAP_ID_EXP);
+	u32 reg;
+
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
+
+	switch (state) {
+	case PCI_D0:
+		break;
+
+	case PCI_D1:
+		power_control |= 1;
+		break;
+
+	case PCI_D2:
+		power_control |= 2;
+		break;
+
+	case PCI_D3hot:
+	case PCI_D3cold:
+		power_control |= 3;
+		if (hw->flags & SKY2_HW_ADV_POWER_CTL) {
+			/* additional power saving measurements */
+			reg = sky2_pci_read32(hw, PCI_DEV_REG4);
+
+			/* set gating core clock for LTSSM in L1 state */
+			reg |= P_PEX_LTSSM_STAT(P_PEX_LTSSM_L1_STAT) |
+				/* auto clock gated scheme controlled by CLKREQ */
+				P_ASPM_A1_MODE_SELECT |
+				/* enable Gate Root Core Clock */
+				P_CLK_GATE_ROOT_COR_ENA;
+
+			if (pex && (hw->flags & SKY2_HW_CLK_POWER)) {
+				/* enable Clock Power Management (CLKREQ) */
+				u16 ctrl = sky2_pci_read16(hw, pex + PCI_EXP_DEVCTL);
+
+				ctrl |= PCI_EXP_DEVCTL_AUX_PME;
+				sky2_pci_write16(hw, pex + PCI_EXP_DEVCTL, ctrl);
+			} else
+				/* force CLKREQ Enable in Our4 (A1b only) */
+				reg |= P_ASPM_FORCE_CLKREQ_ENA;
+
+			/* set Mask Register for Release/Gate Clock */
+			sky2_pci_write32(hw, PCI_DEV_REG5,
+					 P_REL_PCIE_EXIT_L1_ST | P_GAT_PCIE_ENTER_L1_ST |
+					 P_REL_PCIE_RX_EX_IDLE | P_GAT_PCIE_RX_EL_IDLE |
+					 P_REL_GPHY_LINK_UP | P_GAT_GPHY_LINK_DOWN);
+		} else
+			sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_CLK_HALT);
+
+		/* put CPU into reset state */
+		sky2_write8(hw,  B28_Y2_ASF_STAT_CMD, HCU_CCSR_ASF_RESET);
+		if (hw->chip_id == CHIP_ID_YUKON_SUPR && hw->chip_rev == CHIP_REV_YU_SU_A0)
+			/* put CPU into halt state */
+			sky2_write8(hw, B28_Y2_ASF_STAT_CMD, HCU_CCSR_ASF_HALTED);
+
+		if (pex && !(hw->flags & SKY2_HW_RAM_BUFFER)) {
+			reg = sky2_pci_read32(hw, PCI_DEV_REG1);
+			/* force to PCIe L1 */
+			reg |= PCI_FORCE_PEX_L1;
+			sky2_pci_write32(hw, PCI_DEV_REG1, reg);
+		}
+		break;
+
+	default:
+		dev_warn(&hw->pdev->dev, PFX "Invalid power state (%d) ",
+		       state);
+		return;
+	}
+
+	power_control |= PCI_PM_CTRL_PME_ENABLE;
+	/* Finally, set the new power state. */
+	sky2_pci_write32(hw, hw->pm_cap + PCI_PM_CTRL, power_control);
+
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
+	sky2_pci_read32(hw, B0_CTST);
+}
+
 static void sky2_gmac_reset(struct sky2_hw *hw, unsigned port)
 {
 	u16 reg;
@@ -619,28 +699,71 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 		gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
 }
 
-static void sky2_phy_power(struct sky2_hw *hw, unsigned port, int onoff)
+static const u32 phy_power[] = { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
+static const u32 coma_mode[] = { PCI_Y2_PHY1_COMA, PCI_Y2_PHY2_COMA };
+
+static void sky2_phy_power_up(struct sky2_hw *hw, unsigned port)
 {
 	u32 reg1;
-	static const u32 phy_power[] = { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
-	static const u32 coma_mode[] = { PCI_Y2_PHY1_COMA, PCI_Y2_PHY2_COMA };
 
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
-	/* Turn on/off phy power saving */
-	if (onoff)
-		reg1 &= ~phy_power[port];
-	else
-		reg1 |= phy_power[port];
+	reg1 &= ~phy_power[port];
 
-	if (onoff && hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
+	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
 		reg1 |= coma_mode[port];
 
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	sky2_pci_read32(hw, PCI_DEV_REG1);
+}
+
+static void sky2_phy_power_down(struct sky2_hw *hw, unsigned port)
+{
+	u32 reg1;
+	u16 ctrl;
+
+	/* release GPHY Control reset */
+	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
 
-	udelay(100);
+	/* release GMAC reset */
+	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
+
+	if (hw->flags & SKY2_HW_NEWER_PHY) {
+		/* select page 2 to access MAC control register */
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 2);
+
+		ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
+		/* allow GMII Power Down */
+		ctrl &= ~PHY_M_MAC_GMIF_PUP;
+		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
+
+		/* set page register back to 0 */
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
+	}
+
+	/* setup General Purpose Control Register */
+	gma_write16(hw, port, GM_GP_CTRL,
+		    GM_GPCR_FL_PASS | GM_GPCR_SPEED_100 | GM_GPCR_AU_ALL_DIS);
+
+	if (hw->chip_id != CHIP_ID_YUKON_EC) {
+		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
+			ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
+
+			/* enable Power Down */
+			ctrl |= PHY_M_PC_POW_D_ENA;
+			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
+		}
+
+		/* set IEEE compatible Power Down Mode (dev. #4.99) */
+		gm_phy_write(hw, port, PHY_MARV_CTRL, PHY_CT_PDOWN);
+	}
+
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
+	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
+	reg1 |= phy_power[port];		/* set PHY to PowerDown/COMA Mode */
+	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 }
 
 /* Force a renegotiation */
@@ -675,8 +798,11 @@ static void sky2_wol_init(struct sky2_port *sky2)
 
 	sky2->advertising &= ~(ADVERTISED_1000baseT_Half|ADVERTISED_1000baseT_Full);
 	sky2->flow_mode = FC_NONE;
-	sky2_phy_power(hw, port, 1);
-	sky2_phy_reinit(sky2);
+
+	spin_lock_bh(&sky2->phy_lock);
+	sky2_phy_power_up(hw, port);
+	sky2_phy_init(hw, port);
+	spin_unlock_bh(&sky2->phy_lock);
 
 	sky2->flow_mode = save_mode;
 	sky2->advertising = ctrl;
@@ -781,6 +907,7 @@ static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 	sky2_write8(hw, SK_REG(port, GMAC_IRQ_MSK), GMAC_DEF_MSK);
 
 	spin_lock_bh(&sky2->phy_lock);
+	sky2_phy_power_up(hw, port);
 	sky2_phy_init(hw, port);
 	spin_unlock_bh(&sky2->phy_lock);
 
@@ -1385,8 +1512,6 @@ static int sky2_up(struct net_device *dev)
 	if (!sky2->rx_ring)
 		goto err_out;
 
-	sky2_phy_power(hw, port, 1);
-
 	sky2_mac_init(hw, port);
 
 	/* Register is number of 4K blocks on internal RAM buffer. */
@@ -1767,7 +1892,7 @@ static int sky2_down(struct net_device *dev)
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
 
-	sky2_phy_power(hw, port, 0);
+	sky2_phy_power_down(hw, port);
 
 	netif_carrier_off(dev);
 
@@ -2741,6 +2866,10 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 		hw->flags = SKY2_HW_GIGABIT
 			| SKY2_HW_NEWER_PHY
 			| SKY2_HW_ADV_POWER_CTL;
+
+		/* check for Rev. A1 dev 4200 */
+		if (sky2_read16(hw, Q_ADDR(Q_XA1, Q_WM)) == 0)
+			hw->flags |= SKY2_HW_CLK_POWER;
 		break;
 
 	case CHIP_ID_YUKON_EX:
@@ -2791,6 +2920,11 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 	if (hw->pmd_type == 'L' || hw->pmd_type == 'S' || hw->pmd_type == 'P')
 		hw->flags |= SKY2_HW_FIBRE_PHY;
 
+	hw->pm_cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PM);
+	if (hw->pm_cap == 0) {
+		dev_err(&hw->pdev->dev, "cannot find PowerManagement capability\n");
+		return -EIO;
+	}
 
 	hw->ports = 1;
 	t8 = sky2_read8(hw, B2_Y2_HW_RES);
@@ -4362,7 +4496,7 @@ static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	sky2_power_state(hw, pci_choose_state(pdev, state));
 
 	return 0;
 }
@@ -4375,9 +4509,7 @@ static int sky2_resume(struct pci_dev *pdev)
 	if (!hw)
 		return 0;
 
-	err = pci_set_power_state(pdev, PCI_D0);
-	if (err)
-		goto out;
+	sky2_power_state(hw, PCI_D0);
 
 	err = pci_restore_state(pdev);
 	if (err)
@@ -4445,8 +4577,7 @@ static void sky2_shutdown(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3cold, wol);
 
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
-
+	sky2_power_state(hw, PCI_D3hot);
 }
 
 static struct pci_driver sky2_driver = {
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index c0a5eea..1fa82bf 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -28,6 +28,11 @@ enum pci_dev_reg_1 {
 	PCI_Y2_PHY2_POWD = 1<<27, /* Set PHY 2 to Power Down (YUKON-2) */
 	PCI_Y2_PHY1_POWD = 1<<26, /* Set PHY 1 to Power Down (YUKON-2) */
 	PCI_Y2_PME_LEGACY= 1<<15, /* PCI Express legacy power management mode */
+
+	PCI_PHY_LNK_TIM_MSK= 3L<<8,/* Bit  9.. 8:	GPHY Link Trigger Timer */
+	PCI_ENA_L1_EVENT = 1<<7, /* Enable PEX L1 Event */
+	PCI_ENA_GPHY_LNK = 1<<6, /* Enable PEX L1 on GPHY Link down */
+	PCI_FORCE_PEX_L1 = 1<<5, /* Force to PEX L1 */
 };
 
 enum pci_dev_reg_2 {
@@ -45,7 +50,11 @@ enum pci_dev_reg_2 {
 
 /*	PCI_OUR_REG_4		32 bit	Our Register 4 (Yukon-ECU only) */
 enum pci_dev_reg_4 {
-					/* (Link Training & Status State Machine) */
+				/* (Link Training & Status State Machine) */
+	P_PEX_LTSSM_STAT_MSK	= 0x7fL<<25,	/* Bit 31..25:	PEX LTSSM Mask */
+#define P_PEX_LTSSM_STAT(x)	((x << 25) & P_PEX_LTSSM_STAT_MSK)
+	P_PEX_LTSSM_L1_STAT	= 0x34,
+	P_PEX_LTSSM_DET_STAT	= 0x01,
 	P_TIMER_VALUE_MSK	= 0xffL<<16,	/* Bit 23..16:	Timer Value Mask */
 					/* (Active State Power Management) */
 	P_FORCE_ASPM_REQUEST	= 1<<15, /* Force ASPM Request (A1 only) */
@@ -454,6 +463,9 @@ enum yukon_ex_rev {
 	CHIP_REV_YU_EX_A0    = 1,
 	CHIP_REV_YU_EX_B0    = 2,
 };
+enum yukon_supr_rev {
+	CHIP_REV_YU_SU_A0    = 0,
+};
 
 
 /*	B2_Y2_CLK_GATE	 8 bit	Clock Gating (Yukon-2 only) */
@@ -1143,6 +1155,12 @@ enum {
 	PHY_M_PC_ENA_AUTO	= 3, /* 11 = Enable Automatic Crossover */
 };
 
+/* for Yukon-EC Ultra Gigabit Ethernet PHY (88E1149 only) */
+enum {
+	PHY_M_PC_COP_TX_DIS	= 1<<3, /* Copper Transmitter Disable */
+	PHY_M_PC_POW_D_ENA	= 1<<2,	/* Power Down Enable */
+};
+
 /* for 10/100 Fast Ethernet PHY (88E3082 only) */
 enum {
 	PHY_M_PC_ENA_DTE_DT	= 1<<15, /* Enable Data Terminal Equ. (DTE) Detect */
@@ -1411,6 +1429,7 @@ enum {
 /*****  PHY_MARV_PHY_CTRL (page 2)		16 bit r/w	MAC Specific Ctrl *****/
 enum {
 	PHY_M_MAC_MD_MSK	= 7<<7, /* Bit  9.. 7: Mode Select Mask */
+	PHY_M_MAC_GMIF_PUP	= 1<<3,	/* GMII Power Up (88E1149 only) */
 	PHY_M_MAC_MD_AUTO	= 3,/* Auto Copper/1000Base-X */
 	PHY_M_MAC_MD_COPPER	= 5,/* Copper only */
 	PHY_M_MAC_MD_1000BX	= 7,/* 1000Base-X only */
@@ -2052,7 +2071,9 @@ struct sky2_hw {
 #define SKY2_HW_NEW_LE		0x00000020	/* new LSOv2 format */
 #define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
+#define SKY2_HW_CLK_POWER	0x00000100	/* clock power management */
 
+	int		     pm_cap;
 	u8	     	     chip_id;
 	u8		     chip_rev;
 	u8		     pmd_type;
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 0166407..85246ed 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -13,8 +13,6 @@
  *  This software may be used and distributed according to the terms
  *  of the GNU General Public License, incorporated herein by reference.
  *
- ** This file is best viewed/edited with columns>=132.
- *
  ** Useful (if not required) reading:
  *
  *		Texas Instruments, ThunderLAN Programmer's Guide,
@@ -218,9 +216,7 @@ static	int		bbuf;
 module_param(bbuf, int, 0);
 MODULE_PARM_DESC(bbuf, "ThunderLAN use big buffer (0-1)");
 
-static	u8		*TLanPadBuffer;
-static  dma_addr_t	TLanPadBufferDMA;
-static	char		TLanSignature[] = "TLAN";
+static	const char TLanSignature[] = "TLAN";
 static  const char tlan_banner[] = "ThunderLAN driver v1.15\n";
 static  int tlan_have_pci;
 static  int tlan_have_eisa;
@@ -238,9 +234,11 @@ static struct board {
 	{ "Compaq Netelligent 10 T PCI UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Netelligent 10/100 TX PCI UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Integrated NetFlex-3/P", TLAN_ADAPTER_NONE, 0x83 },
-	{ "Compaq NetFlex-3/P", TLAN_ADAPTER_UNMANAGED_PHY | TLAN_ADAPTER_BIT_RATE_PHY, 0x83 },
+	{ "Compaq NetFlex-3/P",
+	  TLAN_ADAPTER_UNMANAGED_PHY | TLAN_ADAPTER_BIT_RATE_PHY, 0x83 },
 	{ "Compaq NetFlex-3/P", TLAN_ADAPTER_NONE, 0x83 },
-	{ "Compaq Netelligent Integrated 10/100 TX UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
+	{ "Compaq Netelligent Integrated 10/100 TX UTP",
+	  TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Netelligent Dual 10/100 TX PCI UTP", TLAN_ADAPTER_NONE, 0x83 },
 	{ "Compaq Netelligent 10/100 TX Embedded UTP", TLAN_ADAPTER_NONE, 0x83 },
 	{ "Olicom OC-2183/2185", TLAN_ADAPTER_USE_INTERN_10, 0x83 },
@@ -248,8 +246,9 @@ static struct board {
 	{ "Olicom OC-2326", TLAN_ADAPTER_USE_INTERN_10, 0xF8 },
 	{ "Compaq Netelligent 10/100 TX UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Netelligent 10 T/2 PCI UTP/Coax", TLAN_ADAPTER_NONE, 0x83 },
-	{ "Compaq NetFlex-3/E", TLAN_ADAPTER_ACTIVITY_LED | 	/* EISA card */
-	                        TLAN_ADAPTER_UNMANAGED_PHY | TLAN_ADAPTER_BIT_RATE_PHY, 0x83 },
+	{ "Compaq NetFlex-3/E",
+	  TLAN_ADAPTER_ACTIVITY_LED | 	/* EISA card */
+	  TLAN_ADAPTER_UNMANAGED_PHY | TLAN_ADAPTER_BIT_RATE_PHY, 0x83 },
 	{ "Compaq NetFlex-3/E", TLAN_ADAPTER_ACTIVITY_LED, 0x83 }, /* EISA card */
 };
 
@@ -294,12 +293,12 @@ static int	TLan_Close( struct net_device *);
 static struct	net_device_stats *TLan_GetStats( struct net_device *);
 static void	TLan_SetMulticastList( struct net_device *);
 static int	TLan_ioctl( struct net_device *dev, struct ifreq *rq, int cmd);
-static int      TLan_probe1( struct pci_dev *pdev, long ioaddr, int irq, int rev, const struct pci_device_id *ent);
+static int      TLan_probe1( struct pci_dev *pdev, long ioaddr,
+			     int irq, int rev, const struct pci_device_id *ent);
 static void	TLan_tx_timeout( struct net_device *dev);
 static void	TLan_tx_timeout_work(struct work_struct *work);
 static int 	tlan_init_one( struct pci_dev *pdev, const struct pci_device_id *ent);
 
-static u32	TLan_HandleInvalid( struct net_device *, u16 );
 static u32	TLan_HandleTxEOF( struct net_device *, u16 );
 static u32	TLan_HandleStatOverflow( struct net_device *, u16 );
 static u32	TLan_HandleRxEOF( struct net_device *, u16 );
@@ -348,29 +347,27 @@ static void	TLan_EeReceiveByte( u16, u8 *, int );
 static int	TLan_EeReadByte( struct net_device *, u8, u8 * );
 
 
-static void
+static inline void
 TLan_StoreSKB( struct tlan_list_tag *tag, struct sk_buff *skb)
 {
 	unsigned long addr = (unsigned long)skb;
-	tag->buffer[9].address = (u32)addr;
-	addr >>= 31;	/* >>= 32 is undefined for 32bit arch, stupid C */
-	addr >>= 1;
-	tag->buffer[8].address = (u32)addr;
+	tag->buffer[9].address = addr;
+	tag->buffer[8].address = upper_32_bits(addr);
 }
 
-static struct sk_buff *
-TLan_GetSKB( struct tlan_list_tag *tag)
+static inline struct sk_buff *
+TLan_GetSKB( const struct tlan_list_tag *tag)
 {
-	unsigned long addr = tag->buffer[8].address;
-	addr <<= 31;
-	addr <<= 1;
-	addr |= tag->buffer[9].address;
+	unsigned long addr;
+
+	addr = tag->buffer[8].address;
+	addr |= (tag->buffer[9].address << 16) << 16;
 	return (struct sk_buff *) addr;
 }
 
 
 static TLanIntVectorFunc *TLanIntVector[TLAN_INT_NUMBER_OF_INTS] = {
-	TLan_HandleInvalid,
+	NULL,
 	TLan_HandleTxEOF,
 	TLan_HandleStatOverflow,
 	TLan_HandleRxEOF,
@@ -444,7 +441,9 @@ static void __devexit tlan_remove_one( struct pci_dev *pdev)
 	unregister_netdev( dev );
 
 	if ( priv->dmaStorage ) {
-		pci_free_consistent(priv->pciDev, priv->dmaSize, priv->dmaStorage, priv->dmaStorageDMA );
+		pci_free_consistent(priv->pciDev,
+				    priv->dmaSize, priv->dmaStorage,
+				    priv->dmaStorageDMA );
 	}
 
 #ifdef CONFIG_PCI
@@ -469,16 +468,6 @@ static int __init tlan_probe(void)
 
 	printk(KERN_INFO "%s", tlan_banner);
 
-	TLanPadBuffer = (u8 *) pci_alloc_consistent(NULL, TLAN_MIN_FRAME_SIZE, &TLanPadBufferDMA);
-
-	if (TLanPadBuffer == NULL) {
-		printk(KERN_ERR "TLAN: Could not allocate memory for pad buffer.\n");
-		rc = -ENOMEM;
-		goto err_out;
-	}
-
-	memset(TLanPadBuffer, 0, TLAN_MIN_FRAME_SIZE);
-
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting PCI Probe....\n");
 
 	/* Use new style PCI probing. Now the kernel will
@@ -506,8 +495,6 @@ static int __init tlan_probe(void)
 err_out_pci_unreg:
 	pci_unregister_driver(&tlan_driver);
 err_out_pci_free:
-	pci_free_consistent(NULL, TLAN_MIN_FRAME_SIZE, TLanPadBuffer, TLanPadBufferDMA);
-err_out:
 	return rc;
 }
 
@@ -539,7 +526,8 @@ static int __devinit tlan_init_one( struct pci_dev *pdev,
 	 **************************************************************/
 
 static int __devinit TLan_probe1(struct pci_dev *pdev,
-				long ioaddr, int irq, int rev, const struct pci_device_id *ent )
+				 long ioaddr, int irq, int rev,
+				 const struct pci_device_id *ent )
 {
 
 	struct net_device  *dev;
@@ -625,8 +613,10 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 	/* Kernel parameters */
 	if (dev->mem_start) {
 		priv->aui    = dev->mem_start & 0x01;
-		priv->duplex = ((dev->mem_start & 0x06) == 0x06) ? 0 : (dev->mem_start & 0x06) >> 1;
-		priv->speed  = ((dev->mem_start & 0x18) == 0x18) ? 0 : (dev->mem_start & 0x18) >> 3;
+		priv->duplex = ((dev->mem_start & 0x06) == 0x06) ? 0
+			: (dev->mem_start & 0x06) >> 1;
+		priv->speed  = ((dev->mem_start & 0x18) == 0x18) ? 0
+			: (dev->mem_start & 0x18) >> 3;
 
 		if (priv->speed == 0x1) {
 			priv->speed = TLAN_SPEED_10;
@@ -706,7 +696,8 @@ static void TLan_Eisa_Cleanup(void)
 		dev = TLan_Eisa_Devices;
 		priv = netdev_priv(dev);
 		if (priv->dmaStorage) {
-			pci_free_consistent(priv->pciDev, priv->dmaSize, priv->dmaStorage, priv->dmaStorageDMA );
+			pci_free_consistent(priv->pciDev, priv->dmaSize,
+					    priv->dmaStorage, priv->dmaStorageDMA );
 		}
 		release_region( dev->base_addr, 0x10);
 		unregister_netdev( dev );
@@ -724,8 +715,6 @@ static void __exit tlan_exit(void)
 	if (tlan_have_eisa)
 		TLan_Eisa_Cleanup();
 
-	pci_free_consistent(NULL, TLAN_MIN_FRAME_SIZE, TLanPadBuffer, TLanPadBufferDMA);
-
 }
 
 
@@ -763,8 +752,10 @@ static void  __init TLan_EisaProbe (void)
 	/* Loop through all slots of the EISA bus */
 	for (ioaddr = 0x1000; ioaddr < 0x9000; ioaddr += 0x1000) {
 
-	TLAN_DBG(TLAN_DEBUG_PROBE,"EISA_ID 0x%4x: 0x%4x\n", (int) ioaddr + 0xC80, inw(ioaddr + EISA_ID));
-	TLAN_DBG(TLAN_DEBUG_PROBE,"EISA_ID 0x%4x: 0x%4x\n", (int) ioaddr + 0xC82, inw(ioaddr + EISA_ID2));
+	TLAN_DBG(TLAN_DEBUG_PROBE,"EISA_ID 0x%4x: 0x%4x\n",
+		 (int) ioaddr + 0xC80, inw(ioaddr + EISA_ID));
+	TLAN_DBG(TLAN_DEBUG_PROBE,"EISA_ID 0x%4x: 0x%4x\n",
+		 (int) ioaddr + 0xC82, inw(ioaddr + EISA_ID2));
 
 
 		TLAN_DBG(TLAN_DEBUG_PROBE, "Probing for EISA adapter at IO: 0x%4x : ",
@@ -874,7 +865,8 @@ static int TLan_Init( struct net_device *dev )
 		dma_size = ( TLAN_NUM_RX_LISTS + TLAN_NUM_TX_LISTS )
 	           * ( sizeof(TLanList) );
 	}
-	priv->dmaStorage = pci_alloc_consistent(priv->pciDev, dma_size, &priv->dmaStorageDMA);
+	priv->dmaStorage = pci_alloc_consistent(priv->pciDev,
+						dma_size, &priv->dmaStorageDMA);
 	priv->dmaSize = dma_size;
 
 	if ( priv->dmaStorage == NULL ) {
@@ -883,16 +875,19 @@ static int TLan_Init( struct net_device *dev )
 		return -ENOMEM;
 	}
 	memset( priv->dmaStorage, 0, dma_size );
-	priv->rxList = (TLanList *)
-		       ( ( ( (u32) priv->dmaStorage ) + 7 ) & 0xFFFFFFF8 );
-	priv->rxListDMA = ( ( ( (u32) priv->dmaStorageDMA ) + 7 ) & 0xFFFFFFF8 );
+	priv->rxList = (TLanList *) ALIGN((unsigned long)priv->dmaStorage, 8);
+	priv->rxListDMA = ALIGN(priv->dmaStorageDMA, 8);
 	priv->txList = priv->rxList + TLAN_NUM_RX_LISTS;
 	priv->txListDMA = priv->rxListDMA + sizeof(TLanList) * TLAN_NUM_RX_LISTS;
+
 	if ( bbuf ) {
 		priv->rxBuffer = (u8 *) ( priv->txList + TLAN_NUM_TX_LISTS );
-		priv->rxBufferDMA =priv->txListDMA + sizeof(TLanList) * TLAN_NUM_TX_LISTS;
-		priv->txBuffer = priv->rxBuffer + ( TLAN_NUM_RX_LISTS * TLAN_MAX_FRAME_SIZE );
-		priv->txBufferDMA = priv->rxBufferDMA + ( TLAN_NUM_RX_LISTS * TLAN_MAX_FRAME_SIZE );
+		priv->rxBufferDMA =priv->txListDMA
+			+ sizeof(TLanList) * TLAN_NUM_TX_LISTS;
+		priv->txBuffer = priv->rxBuffer
+			+ ( TLAN_NUM_RX_LISTS * TLAN_MAX_FRAME_SIZE );
+		priv->txBufferDMA = priv->rxBufferDMA
+			+ ( TLAN_NUM_RX_LISTS * TLAN_MAX_FRAME_SIZE );
 	}
 
 	err = 0;
@@ -952,10 +947,12 @@ static int TLan_Open( struct net_device *dev )
 	int		err;
 
 	priv->tlanRev = TLan_DioRead8( dev->base_addr, TLAN_DEF_REVISION );
-	err = request_irq( dev->irq, TLan_HandleInterrupt, IRQF_SHARED, TLanSignature, dev );
+	err = request_irq( dev->irq, TLan_HandleInterrupt, IRQF_SHARED,
+			   dev->name, dev );
 
 	if ( err ) {
-		printk(KERN_ERR "TLAN:  Cannot open %s because IRQ %d is already in use.\n", dev->name, dev->irq );
+		pr_err("TLAN:  Cannot open %s because IRQ %d is already in use.\n",
+		       dev->name, dev->irq );
 		return err;
 	}
 
@@ -969,7 +966,8 @@ static int TLan_Open( struct net_device *dev )
 	TLan_ReadAndClearStats( dev, TLAN_IGNORE );
 	TLan_ResetAdapter( dev );
 
-	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Opened.  TLAN Chip Rev: %x\n", dev->name, priv->tlanRev );
+	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Opened.  TLAN Chip Rev: %x\n",
+		  dev->name, priv->tlanRev );
 
 	return 0;
 
@@ -1007,14 +1005,16 @@ static int TLan_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 
 	case SIOCGMIIREG:		/* Read MII PHY register. */
-			TLan_MiiReadReg(dev, data->phy_id & 0x1f, data->reg_num & 0x1f, &data->val_out);
+			TLan_MiiReadReg(dev, data->phy_id & 0x1f,
+					data->reg_num & 0x1f, &data->val_out);
 			return 0;
 
 
 	case SIOCSMIIREG:		/* Write MII PHY register. */
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
-			TLan_MiiWriteReg(dev, data->phy_id & 0x1f, data->reg_num & 0x1f, data->val_in);
+			TLan_MiiWriteReg(dev, data->phy_id & 0x1f,
+					 data->reg_num & 0x1f, data->val_in);
 			return 0;
 		default:
 			return -EOPNOTSUPP;
@@ -1096,20 +1096,25 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 	TLanList	*tail_list;
 	dma_addr_t	tail_list_phys;
 	u8		*tail_buffer;
-	int		pad;
 	unsigned long	flags;
 
 	if ( ! priv->phyOnline ) {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s PHY is not ready\n", dev->name );
+		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s PHY is not ready\n",
+			  dev->name );
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
 
+	if (skb_padto(skb, TLAN_MIN_FRAME_SIZE))
+		return 0;
+
 	tail_list = priv->txList + priv->txTail;
 	tail_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txTail;
 
 	if ( tail_list->cStat != TLAN_CSTAT_UNUSED ) {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s is busy (Head=%d Tail=%d)\n", dev->name, priv->txHead, priv->txTail );
+		TLAN_DBG( TLAN_DEBUG_TX,
+			  "TRANSMIT:  %s is busy (Head=%d Tail=%d)\n",
+			  dev->name, priv->txHead, priv->txTail );
 		netif_stop_queue(dev);
 		priv->txBusyCount++;
 		return 1;
@@ -1121,37 +1126,34 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 		tail_buffer = priv->txBuffer + ( priv->txTail * TLAN_MAX_FRAME_SIZE );
 		skb_copy_from_linear_data(skb, tail_buffer, skb->len);
 	} else {
-		tail_list->buffer[0].address = pci_map_single(priv->pciDev, skb->data, skb->len, PCI_DMA_TODEVICE);
+		tail_list->buffer[0].address = pci_map_single(priv->pciDev,
+							      skb->data, skb->len,
+							      PCI_DMA_TODEVICE);
 		TLan_StoreSKB(tail_list, skb);
 	}
 
-	pad = TLAN_MIN_FRAME_SIZE - skb->len;
-
-	if ( pad > 0 ) {
-		tail_list->frameSize = (u16) skb->len + pad;
-		tail_list->buffer[0].count = (u32) skb->len;
-		tail_list->buffer[1].count = TLAN_LAST_BUFFER | (u32) pad;
-		tail_list->buffer[1].address = TLanPadBufferDMA;
-	} else {
-		tail_list->frameSize = (u16) skb->len;
-		tail_list->buffer[0].count = TLAN_LAST_BUFFER | (u32) skb->len;
-		tail_list->buffer[1].count = 0;
-		tail_list->buffer[1].address = 0;
-	}
+	tail_list->frameSize = (u16) skb->len;
+	tail_list->buffer[0].count = TLAN_LAST_BUFFER | (u32) skb->len;
+	tail_list->buffer[1].count = 0;
+	tail_list->buffer[1].address = 0;
 
 	spin_lock_irqsave(&priv->lock, flags);
 	tail_list->cStat = TLAN_CSTAT_READY;
 	if ( ! priv->txInProgress ) {
 		priv->txInProgress = 1;
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Starting TX on buffer %d\n", priv->txTail );
+		TLAN_DBG( TLAN_DEBUG_TX,
+			  "TRANSMIT:  Starting TX on buffer %d\n", priv->txTail );
 		outl( tail_list_phys, dev->base_addr + TLAN_CH_PARM );
 		outl( TLAN_HC_GO, dev->base_addr + TLAN_HOST_CMD );
 	} else {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Adding buffer %d to TX channel\n", priv->txTail );
+		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Adding buffer %d to TX channel\n",
+			  priv->txTail );
 		if ( priv->txTail == 0 ) {
-			( priv->txList + ( TLAN_NUM_TX_LISTS - 1 ) )->forward = tail_list_phys;
+			( priv->txList + ( TLAN_NUM_TX_LISTS - 1 ) )->forward
+				= tail_list_phys;
 		} else {
-			( priv->txList + ( priv->txTail - 1 ) )->forward = tail_list_phys;
+			( priv->txList + ( priv->txTail - 1 ) )->forward
+				= tail_list_phys;
 		}
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
@@ -1191,33 +1193,31 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 
 static irqreturn_t TLan_HandleInterrupt(int irq, void *dev_id)
 {
-	u32		ack;
-	struct net_device	*dev;
-	u32		host_cmd;
+	struct net_device	*dev = dev_id;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	u16		host_int;
-	int		type;
-	TLanPrivateInfo *priv;
-
-	dev = dev_id;
-	priv = netdev_priv(dev);
+	u16		type;
 
 	spin_lock(&priv->lock);
 
 	host_int = inw( dev->base_addr + TLAN_HOST_INT );
-	outw( host_int, dev->base_addr + TLAN_HOST_INT );
-
 	type = ( host_int & TLAN_HI_IT_MASK ) >> 2;
+	if ( type ) {
+		u32	ack;
+		u32	host_cmd;
 
-	ack = TLanIntVector[type]( dev, host_int );
+		outw( host_int, dev->base_addr + TLAN_HOST_INT );
+		ack = TLanIntVector[type]( dev, host_int );
 
-	if ( ack ) {
-		host_cmd = TLAN_HC_ACK | ack | ( type << 18 );
-		outl( host_cmd, dev->base_addr + TLAN_HOST_CMD );
+		if ( ack ) {
+			host_cmd = TLAN_HC_ACK | ack | ( type << 18 );
+			outl( host_cmd, dev->base_addr + TLAN_HOST_CMD );
+		}
 	}
 
 	spin_unlock(&priv->lock);
 
-	return IRQ_HANDLED;
+	return IRQ_RETVAL(type);
 } /* TLan_HandleInterrupts */
 
 
@@ -1286,8 +1286,10 @@ static struct net_device_stats *TLan_GetStats( struct net_device *dev )
 	/* Should only read stats if open ? */
 	TLan_ReadAndClearStats( dev, TLAN_RECORD );
 
-	TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  %s EOC count = %d\n", dev->name, priv->rxEocCount );
-	TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s Busy count = %d\n", dev->name, priv->txBusyCount );
+	TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  %s EOC count = %d\n", dev->name,
+		  priv->rxEocCount );
+	TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s Busy count = %d\n", dev->name,
+		  priv->txBusyCount );
 	if ( debug & TLAN_DEBUG_GNRL ) {
 		TLan_PrintDio( dev->base_addr );
 		TLan_PhyPrint( dev );
@@ -1299,7 +1301,7 @@ static struct net_device_stats *TLan_GetStats( struct net_device *dev )
 			TLan_PrintList( priv->txList + i, "TX", i );
 	}
 
-	return ( &( (TLanPrivateInfo *) netdev_priv(dev) )->stats );
+	return &dev->stats;
 
 } /* TLan_GetStats */
 
@@ -1337,10 +1339,12 @@ static void TLan_SetMulticastList( struct net_device *dev )
 
 	if ( dev->flags & IFF_PROMISC ) {
 		tmp = TLan_DioRead8( dev->base_addr, TLAN_NET_CMD );
-		TLan_DioWrite8( dev->base_addr, TLAN_NET_CMD, tmp | TLAN_NET_CMD_CAF );
+		TLan_DioWrite8( dev->base_addr,
+				TLAN_NET_CMD, tmp | TLAN_NET_CMD_CAF );
 	} else {
 		tmp = TLan_DioRead8( dev->base_addr, TLAN_NET_CMD );
-		TLan_DioWrite8( dev->base_addr, TLAN_NET_CMD, tmp & ~TLAN_NET_CMD_CAF );
+		TLan_DioWrite8( dev->base_addr,
+				TLAN_NET_CMD, tmp & ~TLAN_NET_CMD_CAF );
 		if ( dev->flags & IFF_ALLMULTI ) {
 			for ( i = 0; i < 3; i++ )
 				TLan_SetMac( dev, i + 1, NULL );
@@ -1349,7 +1353,8 @@ static void TLan_SetMulticastList( struct net_device *dev )
 		} else {
 			for ( i = 0; i < dev->mc_count; i++ ) {
 				if ( i < 3 ) {
-					TLan_SetMac( dev, i + 1, (char *) &dmi->dmi_addr );
+					TLan_SetMac( dev, i + 1,
+						     (char *) &dmi->dmi_addr );
 				} else {
 					offset = TLan_HashFunc( (u8 *) &dmi->dmi_addr );
 					if ( offset < 32 )
@@ -1383,31 +1388,6 @@ static void TLan_SetMulticastList( struct net_device *dev )
 *****************************************************************************/
 
 
-	/***************************************************************
-	 *	TLan_HandleInvalid
-	 *
-	 *	Returns:
-	 *		0
-	 *	Parms:
-	 *		dev		Device assigned the IRQ that was
-	 *				raised.
-	 *		host_int	The contents of the HOST_INT
-	 *				port.
-	 *
-	 *	This function handles invalid interrupts.  This should
-	 *	never happen unless some other adapter is trying to use
-	 *	the IRQ line assigned to the device.
-	 *
-	 **************************************************************/
-
-static u32 TLan_HandleInvalid( struct net_device *dev, u16 host_int )
-{
-	/* printk( "TLAN:  Invalid interrupt on %s.\n", dev->name ); */
-	return 0;
-
-} /* TLan_HandleInvalid */
-
-
 
 
 	/***************************************************************
@@ -1441,14 +1421,16 @@ static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 	u32		ack = 0;
 	u16		tmpCStat;
 
-	TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Handling TX EOF (Head=%d Tail=%d)\n", priv->txHead, priv->txTail );
+	TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Handling TX EOF (Head=%d Tail=%d)\n",
+		  priv->txHead, priv->txTail );
 	head_list = priv->txList + priv->txHead;
 
 	while (((tmpCStat = head_list->cStat ) & TLAN_CSTAT_FRM_CMP) && (ack < 255)) {
 		ack++;
 		if ( ! bbuf ) {
 			struct sk_buff *skb = TLan_GetSKB(head_list);
-			pci_unmap_single(priv->pciDev, head_list->buffer[0].address, skb->len, PCI_DMA_TODEVICE);
+			pci_unmap_single(priv->pciDev, head_list->buffer[0].address,
+					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb_any(skb);
 			head_list->buffer[8].address = 0;
 			head_list->buffer[9].address = 0;
@@ -1457,7 +1439,7 @@ static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 		if ( tmpCStat & TLAN_CSTAT_EOC )
 			eoc = 1;
 
-		priv->stats.tx_bytes += head_list->frameSize;
+		dev->stats.tx_bytes += head_list->frameSize;
 
 		head_list->cStat = TLAN_CSTAT_UNUSED;
 		netif_start_queue(dev);
@@ -1469,7 +1451,9 @@ static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 		printk(KERN_INFO "TLAN: Received interrupt for uncompleted TX frame.\n");
 
 	if ( eoc ) {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Handling TX EOC (Head=%d Tail=%d)\n", priv->txHead, priv->txTail );
+		TLAN_DBG( TLAN_DEBUG_TX,
+			  "TRANSMIT:  Handling TX EOC (Head=%d Tail=%d)\n",
+			  priv->txHead, priv->txTail );
 		head_list = priv->txList + priv->txHead;
 		head_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txHead;
 		if ( ( head_list->cStat & TLAN_CSTAT_READY ) == TLAN_CSTAT_READY ) {
@@ -1481,7 +1465,8 @@ static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 	}
 
 	if ( priv->adapter->flags & TLAN_ADAPTER_ACTIVITY_LED ) {
-		TLan_DioWrite8( dev->base_addr, TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
+		TLan_DioWrite8( dev->base_addr,
+				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
 		if ( priv->timer.function == NULL ) {
 			 priv->timer.function = &TLan_Timer;
 			 priv->timer.data = (unsigned long) dev;
@@ -1563,66 +1548,65 @@ static u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 	TLanList	*head_list;
 	struct sk_buff	*skb;
 	TLanList	*tail_list;
-	void		*t;
-	u32		frameSize;
 	u16		tmpCStat;
 	dma_addr_t	head_list_phys;
 
-	TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  Handling RX EOF (Head=%d Tail=%d)\n", priv->rxHead, priv->rxTail );
+	TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  Handling RX EOF (Head=%d Tail=%d)\n",
+		  priv->rxHead, priv->rxTail );
 	head_list = priv->rxList + priv->rxHead;
 	head_list_phys = priv->rxListDMA + sizeof(TLanList) * priv->rxHead;
 
 	while (((tmpCStat = head_list->cStat) & TLAN_CSTAT_FRM_CMP) && (ack < 255)) {
-		frameSize = head_list->frameSize;
+		dma_addr_t frameDma = head_list->buffer[0].address;
+		u32 frameSize = head_list->frameSize;
 		ack++;
 		if (tmpCStat & TLAN_CSTAT_EOC)
 			eoc = 1;
 
 		if (bbuf) {
-			skb = dev_alloc_skb(frameSize + 7);
-			if (skb == NULL)
-				printk(KERN_INFO "TLAN: Couldn't allocate memory for received data.\n");
-			else {
-				head_buffer = priv->rxBuffer + (priv->rxHead * TLAN_MAX_FRAME_SIZE);
-				skb_reserve(skb, 2);
-				t = (void *) skb_put(skb, frameSize);
-
-				priv->stats.rx_bytes += head_list->frameSize;
-
-				memcpy( t, head_buffer, frameSize );
-				skb->protocol = eth_type_trans( skb, dev );
-				netif_rx( skb );
-			}
+			skb = netdev_alloc_skb(dev, frameSize + 7);
+			if ( !skb )
+				goto drop_and_reuse;
+
+			head_buffer = priv->rxBuffer
+				+ (priv->rxHead * TLAN_MAX_FRAME_SIZE);
+			skb_reserve(skb, 2);
+			pci_dma_sync_single_for_cpu(priv->pciDev,
+						    frameDma, frameSize,
+						    PCI_DMA_FROMDEVICE);
+			skb_copy_from_linear_data(skb, head_buffer, frameSize);
+			skb_put(skb, frameSize);
+			dev->stats.rx_bytes += frameSize;
+
+			skb->protocol = eth_type_trans( skb, dev );
+			netif_rx( skb );
 		} else {
 			struct sk_buff *new_skb;
 
-			/*
-		 	 *	I changed the algorithm here. What we now do
-		 	 *	is allocate the new frame. If this fails we
-		 	 *	simply recycle the frame.
-		 	 */
+			new_skb = netdev_alloc_skb(dev, TLAN_MAX_FRAME_SIZE + 7 );
+			if ( !new_skb )
+				goto drop_and_reuse;
 
-			new_skb = dev_alloc_skb( TLAN_MAX_FRAME_SIZE + 7 );
+			skb = TLan_GetSKB(head_list);
+			pci_unmap_single(priv->pciDev, frameDma,
+					 TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
+			skb_put( skb, frameSize );
 
-			if ( new_skb != NULL ) {
-				skb = TLan_GetSKB(head_list);
-				pci_unmap_single(priv->pciDev, head_list->buffer[0].address, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
-				skb_trim( skb, frameSize );
+			dev->stats.rx_bytes += frameSize;
 
-				priv->stats.rx_bytes += frameSize;
+			skb->protocol = eth_type_trans( skb, dev );
+			netif_rx( skb );
 
-				skb->protocol = eth_type_trans( skb, dev );
-				netif_rx( skb );
+			skb_reserve( new_skb, NET_IP_ALIGN );
+			head_list->buffer[0].address = pci_map_single(priv->pciDev,
+								      new_skb->data,
+								      TLAN_MAX_FRAME_SIZE,
+								      PCI_DMA_FROMDEVICE);
 
-				skb_reserve( new_skb, 2 );
-				t = (void *) skb_put( new_skb, TLAN_MAX_FRAME_SIZE );
-				head_list->buffer[0].address = pci_map_single(priv->pciDev, new_skb->data, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
-				head_list->buffer[8].address = (u32) t;
-				TLan_StoreSKB(head_list, new_skb);
-			} else
-				printk(KERN_WARNING "TLAN:  Couldn't allocate memory for received data.\n" );
-		}
+			TLan_StoreSKB(head_list, new_skb);
 
+		}
+drop_and_reuse:
 		head_list->forward = 0;
 		head_list->cStat = 0;
 		tail_list = priv->rxList + priv->rxTail;
@@ -1638,10 +1622,10 @@ static u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 		printk(KERN_INFO "TLAN: Received interrupt for uncompleted RX frame.\n");
 
 
-
-
 	if ( eoc ) {
-		TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  Handling RX EOC (Head=%d Tail=%d)\n", priv->rxHead, priv->rxTail );
+		TLAN_DBG( TLAN_DEBUG_RX,
+			  "RECEIVE:  Handling RX EOC (Head=%d Tail=%d)\n",
+			  priv->rxHead, priv->rxTail );
 		head_list = priv->rxList + priv->rxHead;
 		head_list_phys = priv->rxListDMA + sizeof(TLanList) * priv->rxHead;
 		outl(head_list_phys, dev->base_addr + TLAN_CH_PARM );
@@ -1650,7 +1634,8 @@ static u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 	}
 
 	if ( priv->adapter->flags & TLAN_ADAPTER_ACTIVITY_LED ) {
-		TLan_DioWrite8( dev->base_addr, TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
+		TLan_DioWrite8( dev->base_addr,
+				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
 		if ( priv->timer.function == NULL )  {
 			priv->timer.function = &TLan_Timer;
 			priv->timer.data = (unsigned long) dev;
@@ -1728,7 +1713,9 @@ static u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
 
 	host_int = 0;
 	if ( priv->tlanRev < 0x30 ) {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Handling TX EOC (Head=%d Tail=%d) -- IRQ\n", priv->txHead, priv->txTail );
+		TLAN_DBG( TLAN_DEBUG_TX,
+			  "TRANSMIT:  Handling TX EOC (Head=%d Tail=%d) -- IRQ\n",
+			  priv->txHead, priv->txTail );
 		head_list = priv->txList + priv->txHead;
 		head_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txHead;
 		if ( ( head_list->cStat & TLAN_CSTAT_READY ) == TLAN_CSTAT_READY ) {
@@ -1796,15 +1783,18 @@ static u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
 		net_sts = TLan_DioRead8( dev->base_addr, TLAN_NET_STS );
 		if ( net_sts ) {
 			TLan_DioWrite8( dev->base_addr, TLAN_NET_STS, net_sts );
-			TLAN_DBG( TLAN_DEBUG_GNRL, "%s:    Net_Sts = %x\n", dev->name, (unsigned) net_sts );
+			TLAN_DBG( TLAN_DEBUG_GNRL, "%s:    Net_Sts = %x\n",
+				  dev->name, (unsigned) net_sts );
 		}
 		if ( ( net_sts & TLAN_NET_STS_MIRQ ) &&  ( priv->phyNum == 0 ) ) {
 			TLan_MiiReadReg( dev, phy, TLAN_TLPHY_STS, &tlphy_sts );
 			TLan_MiiReadReg( dev, phy, TLAN_TLPHY_CTL, &tlphy_ctl );
-        		if ( ! ( tlphy_sts & TLAN_TS_POLOK ) && ! ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
+        		if ( ! ( tlphy_sts & TLAN_TS_POLOK ) &&
+			     ! ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
                 		tlphy_ctl |= TLAN_TC_SWAPOL;
                 		TLan_MiiWriteReg( dev, phy, TLAN_TLPHY_CTL, tlphy_ctl);
-        		} else if ( ( tlphy_sts & TLAN_TS_POLOK ) && ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
+        		} else if ( ( tlphy_sts & TLAN_TS_POLOK )
+				    && ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
                 		tlphy_ctl &= ~TLAN_TC_SWAPOL;
                 		TLan_MiiWriteReg( dev, phy, TLAN_TLPHY_CTL, tlphy_ctl);
         		}
@@ -1849,7 +1839,9 @@ static u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
 	u32		ack = 1;
 
 	if (  priv->tlanRev < 0x30 ) {
-		TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  Handling RX EOC (Head=%d Tail=%d) -- IRQ\n", priv->rxHead, priv->rxTail );
+		TLAN_DBG( TLAN_DEBUG_RX,
+			  "RECEIVE:  Handling RX EOC (Head=%d Tail=%d) -- IRQ\n",
+			  priv->rxHead, priv->rxTail );
 		head_list_phys = priv->rxListDMA + sizeof(TLanList) * priv->rxHead;
 		outl( head_list_phys, dev->base_addr + TLAN_CH_PARM );
 		ack |= TLAN_HC_GO | TLAN_HC_RT;
@@ -1940,10 +1932,12 @@ static void TLan_Timer( unsigned long data )
 			if ( priv->timer.function == NULL ) {
 				elapsed = jiffies - priv->timerSetAt;
 				if ( elapsed >= TLAN_TIMER_ACT_DELAY ) {
-					TLan_DioWrite8( dev->base_addr, TLAN_LED_REG, TLAN_LED_LINK );
+					TLan_DioWrite8( dev->base_addr,
+							TLAN_LED_REG, TLAN_LED_LINK );
 				} else  {
 					priv->timer.function = &TLan_Timer;
-					priv->timer.expires = priv->timerSetAt + TLAN_TIMER_ACT_DELAY;
+					priv->timer.expires = priv->timerSetAt
+						+ TLAN_TIMER_ACT_DELAY;
 					spin_unlock_irqrestore(&priv->lock, flags);
 					add_timer( &priv->timer );
 					break;
@@ -1998,7 +1992,8 @@ static void TLan_ResetLists( struct net_device *dev )
 		list = priv->txList + i;
 		list->cStat = TLAN_CSTAT_UNUSED;
 		if ( bbuf ) {
-			list->buffer[0].address = priv->txBufferDMA + ( i * TLAN_MAX_FRAME_SIZE );
+			list->buffer[0].address = priv->txBufferDMA
+				+ ( i * TLAN_MAX_FRAME_SIZE );
 		} else {
 			list->buffer[0].address = 0;
 		}
@@ -2017,28 +2012,32 @@ static void TLan_ResetLists( struct net_device *dev )
 		list->frameSize = TLAN_MAX_FRAME_SIZE;
 		list->buffer[0].count = TLAN_MAX_FRAME_SIZE | TLAN_LAST_BUFFER;
 		if ( bbuf ) {
-			list->buffer[0].address = priv->rxBufferDMA + ( i * TLAN_MAX_FRAME_SIZE );
+			list->buffer[0].address = priv->rxBufferDMA
+				+ ( i * TLAN_MAX_FRAME_SIZE );
 		} else {
-			skb = dev_alloc_skb( TLAN_MAX_FRAME_SIZE + 7 );
-			if ( skb == NULL ) {
-				printk( "TLAN:  Couldn't allocate memory for received data.\n" );
-				/* If this ever happened it would be a problem */
-			} else {
-				skb->dev = dev;
-				skb_reserve( skb, 2 );
-				t = (void *) skb_put( skb, TLAN_MAX_FRAME_SIZE );
+			skb = netdev_alloc_skb(dev, TLAN_MAX_FRAME_SIZE + 7 );
+			if ( !skb ) {
+				pr_err("TLAN: out of memory for received data.\n" );
+				break;
 			}
-			list->buffer[0].address = pci_map_single(priv->pciDev, t, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
-			list->buffer[8].address = (u32) t;
+
+			skb_reserve( skb, NET_IP_ALIGN );
+			list->buffer[0].address = pci_map_single(priv->pciDev, t,
+								 TLAN_MAX_FRAME_SIZE,
+								 PCI_DMA_FROMDEVICE);
 			TLan_StoreSKB(list, skb);
 		}
 		list->buffer[1].count = 0;
 		list->buffer[1].address = 0;
-		if ( i < TLAN_NUM_RX_LISTS - 1 )
-			list->forward = list_phys + sizeof(TLanList);
-		else
-			list->forward = 0;
+		list->forward = list_phys + sizeof(TLanList);
+	}
+
+	/* in case ran out of memory early, clear bits */
+	while (i < TLAN_NUM_RX_LISTS) {
+		TLan_StoreSKB(priv->rxList + i, NULL);
+		++i;
 	}
+	list->forward = 0;
 
 } /* TLan_ResetLists */
 
@@ -2055,7 +2054,9 @@ static void TLan_FreeLists( struct net_device *dev )
 			list = priv->txList + i;
 			skb = TLan_GetSKB(list);
 			if ( skb ) {
-				pci_unmap_single(priv->pciDev, list->buffer[0].address, skb->len, PCI_DMA_TODEVICE);
+				pci_unmap_single(priv->pciDev,
+						 list->buffer[0].address, skb->len,
+						 PCI_DMA_TODEVICE);
 				dev_kfree_skb_any( skb );
 				list->buffer[8].address = 0;
 				list->buffer[9].address = 0;
@@ -2066,7 +2067,10 @@ static void TLan_FreeLists( struct net_device *dev )
 			list = priv->rxList + i;
 			skb = TLan_GetSKB(list);
 			if ( skb ) {
-				pci_unmap_single(priv->pciDev, list->buffer[0].address, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
+				pci_unmap_single(priv->pciDev,
+						 list->buffer[0].address,
+						 TLAN_MAX_FRAME_SIZE,
+						 PCI_DMA_FROMDEVICE);
 				dev_kfree_skb_any( skb );
 				list->buffer[8].address = 0;
 				list->buffer[9].address = 0;
@@ -2097,7 +2101,8 @@ static void TLan_PrintDio( u16 io_base )
 	u32 data0, data1;
 	int	i;
 
-	printk( "TLAN:   Contents of internal registers for io base 0x%04hx.\n", io_base );
+	printk( "TLAN:   Contents of internal registers for io base 0x%04hx.\n",
+		io_base );
 	printk( "TLAN:      Off.  +0         +4\n" );
 	for ( i = 0; i < 0x4C; i+= 8 ) {
 		data0 = TLan_DioRead32( io_base, i );
@@ -2131,13 +2136,14 @@ static void TLan_PrintList( TLanList *list, char *type, int num)
 {
 	int i;
 
-	printk( "TLAN:   %s List %d at 0x%08x\n", type, num, (u32) list );
+	printk( "TLAN:   %s List %d at %p\n", type, num, list );
 	printk( "TLAN:      Forward    = 0x%08x\n",  list->forward );
 	printk( "TLAN:      CSTAT      = 0x%04hx\n", list->cStat );
 	printk( "TLAN:      Frame Size = 0x%04hx\n", list->frameSize );
 	/* for ( i = 0; i < 10; i++ ) { */
 	for ( i = 0; i < 2; i++ ) {
-		printk( "TLAN:      Buffer[%d].count, addr = 0x%08x, 0x%08x\n", i, list->buffer[i].count, list->buffer[i].address );
+		printk( "TLAN:      Buffer[%d].count, addr = 0x%08x, 0x%08x\n",
+			i, list->buffer[i].count, list->buffer[i].address );
 	}
 
 } /* TLan_PrintList */
@@ -2165,7 +2171,6 @@ static void TLan_PrintList( TLanList *list, char *type, int num)
 
 static void TLan_ReadAndClearStats( struct net_device *dev, int record )
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		tx_good, tx_under;
 	u32		rx_good, rx_over;
 	u32		def_tx, crc, code;
@@ -2202,18 +2207,18 @@ static void TLan_ReadAndClearStats( struct net_device *dev, int record )
 	loss       = inb( dev->base_addr + TLAN_DIO_DATA + 2 );
 
 	if ( record ) {
-		priv->stats.rx_packets += rx_good;
-		priv->stats.rx_errors  += rx_over + crc + code;
-		priv->stats.tx_packets += tx_good;
-		priv->stats.tx_errors  += tx_under + loss;
-		priv->stats.collisions += multi_col + single_col + excess_col + late_col;
+		dev->stats.rx_packets += rx_good;
+		dev->stats.rx_errors  += rx_over + crc + code;
+		dev->stats.tx_packets += tx_good;
+		dev->stats.tx_errors  += tx_under + loss;
+		dev->stats.collisions += multi_col + single_col + excess_col + late_col;
 
-		priv->stats.rx_over_errors    += rx_over;
-		priv->stats.rx_crc_errors     += crc;
-		priv->stats.rx_frame_errors   += code;
+		dev->stats.rx_over_errors    += rx_over;
+		dev->stats.rx_crc_errors     += crc;
+		dev->stats.rx_frame_errors   += code;
 
-		priv->stats.tx_aborted_errors += tx_under;
-		priv->stats.tx_carrier_errors += loss;
+		dev->stats.tx_aborted_errors += tx_under;
+		dev->stats.tx_carrier_errors += loss;
 	}
 
 } /* TLan_ReadAndClearStats */
@@ -2354,14 +2359,16 @@ TLan_FinishReset( struct net_device *dev )
 	TLan_MiiReadReg( dev, phy, MII_GEN_ID_HI, &tlphy_id1 );
 	TLan_MiiReadReg( dev, phy, MII_GEN_ID_LO, &tlphy_id2 );
 
-	if ( ( priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY ) || ( priv->aui ) ) {
+	if ( ( priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY ) ||
+	     ( priv->aui ) ) {
 		status = MII_GS_LINK;
 		printk( "TLAN:  %s: Link forced.\n", dev->name );
 	} else {
 		TLan_MiiReadReg( dev, phy, MII_GEN_STS, &status );
 		udelay( 1000 );
 		TLan_MiiReadReg( dev, phy, MII_GEN_STS, &status );
-		if ( (status & MII_GS_LINK) &&	 /* We only support link info on Nat.Sem. PHY's */
+		if ( (status & MII_GS_LINK) &&
+		     /* We only support link info on Nat.Sem. PHY's */
 			(tlphy_id1 == NAT_SEM_ID1) &&
 			(tlphy_id2 == NAT_SEM_ID2) ) {
 			TLan_MiiReadReg( dev, phy, MII_AN_LPA, &partner );
@@ -2370,12 +2377,12 @@ TLan_FinishReset( struct net_device *dev )
 			printk( "TLAN: %s: Link active with ", dev->name );
 			if (!(tlphy_par & TLAN_PHY_AN_EN_STAT)) {
 			      	 printk( "forced 10%sMbps %s-Duplex\n",
-						tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
-						tlphy_par & TLAN_PHY_DUPLEX_FULL ? "Full" : "Half");
+					 tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
+					 tlphy_par & TLAN_PHY_DUPLEX_FULL ? "Full" : "Half");
 			} else {
 				printk( "AutoNegotiation enabled, at 10%sMbps %s-Duplex\n",
-						tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
-						tlphy_par & TLAN_PHY_DUPLEX_FULL ? "Full" : "Half");
+					tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
+					tlphy_par & TLAN_PHY_DUPLEX_FULL ? "Full" : "Half");
 				printk("TLAN: Partner capability: ");
 					for (i = 5; i <= 10; i++)
 						if (partner & (1<<i))
@@ -2416,7 +2423,8 @@ TLan_FinishReset( struct net_device *dev )
 		outl( TLAN_HC_GO | TLAN_HC_RT, dev->base_addr + TLAN_HOST_CMD );
 		netif_carrier_on(dev);
 	} else {
-		printk( "TLAN: %s: Link inactive, will retry in 10 secs...\n", dev->name );
+		printk( "TLAN: %s: Link inactive, will retry in 10 secs...\n",
+			dev->name );
 		TLan_SetTimer( dev, (10*HZ), TLAN_TIMER_FINISH_RESET );
 		return;
 	}
@@ -2456,10 +2464,12 @@ static void TLan_SetMac( struct net_device *dev, int areg, char *mac )
 
 	if ( mac != NULL ) {
 		for ( i = 0; i < 6; i++ )
-			TLan_DioWrite8( dev->base_addr, TLAN_AREG_0 + areg + i, mac[i] );
+			TLan_DioWrite8( dev->base_addr,
+					TLAN_AREG_0 + areg + i, mac[i] );
 	} else {
 		for ( i = 0; i < 6; i++ )
-			TLan_DioWrite8( dev->base_addr, TLAN_AREG_0 + areg + i, 0 );
+			TLan_DioWrite8( dev->base_addr,
+					TLAN_AREG_0 + areg + i, 0 );
 	}
 
 } /* TLan_SetMac */
@@ -2565,9 +2575,13 @@ static void TLan_PhyDetect( struct net_device *dev )
 		TLan_MiiReadReg( dev, phy, MII_GEN_CTL, &control );
 		TLan_MiiReadReg( dev, phy, MII_GEN_ID_HI, &hi );
 		TLan_MiiReadReg( dev, phy, MII_GEN_ID_LO, &lo );
-		if ( ( control != 0xFFFF ) || ( hi != 0xFFFF ) || ( lo != 0xFFFF ) ) {
-			TLAN_DBG( TLAN_DEBUG_GNRL, "PHY found at %02x %04x %04x %04x\n", phy, control, hi, lo );
-			if ( ( priv->phy[1] == TLAN_PHY_NONE ) && ( phy != TLAN_PHY_MAX_ADDR ) ) {
+		if ( ( control != 0xFFFF ) ||
+		     ( hi != 0xFFFF ) || ( lo != 0xFFFF ) ) {
+			TLAN_DBG( TLAN_DEBUG_GNRL,
+				  "PHY found at %02x %04x %04x %04x\n",
+				  phy, control, hi, lo );
+			if ( ( priv->phy[1] == TLAN_PHY_NONE ) &&
+			     ( phy != TLAN_PHY_MAX_ADDR ) ) {
 				priv->phy[1] = phy;
 			}
 		}
@@ -2595,7 +2609,9 @@ static void TLan_PhyPowerDown( struct net_device *dev )
 	value = MII_GC_PDOWN | MII_GC_LOOPBK | MII_GC_ISOLATE;
 	TLan_MiiSync( dev->base_addr );
 	TLan_MiiWriteReg( dev, priv->phy[priv->phyNum], MII_GEN_CTL, value );
-	if ( ( priv->phyNum == 0 ) && ( priv->phy[1] != TLAN_PHY_NONE ) && ( ! ( priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10 ) ) ) {
+	if ( ( priv->phyNum == 0 ) &&
+	     ( priv->phy[1] != TLAN_PHY_NONE ) &&
+	     ( ! ( priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10 ) ) ) {
 		TLan_MiiSync( dev->base_addr );
 		TLan_MiiWriteReg( dev, priv->phy[1], MII_GEN_CTL, value );
 	}
@@ -2768,10 +2784,10 @@ static void TLan_PhyFinishAutoNeg( struct net_device *dev )
 		 * more time.  Perhaps we should fail after a while.
 		 */
 		 if (!priv->neg_be_verbose++) {
-			 printk(KERN_INFO "TLAN:  Giving autonegotiation more time.\n");
-		 	 printk(KERN_INFO "TLAN:  Please check that your adapter has\n");
-		 	 printk(KERN_INFO "TLAN:  been properly connected to a HUB or Switch.\n");
-			 printk(KERN_INFO "TLAN:  Trying to establish link in the background...\n");
+			 pr_info("TLAN:  Giving autonegotiation more time.\n");
+		 	 pr_info("TLAN:  Please check that your adapter has\n");
+		 	 pr_info("TLAN:  been properly connected to a HUB or Switch.\n");
+			 pr_info("TLAN:  Trying to establish link in the background...\n");
 		 }
 		TLan_SetTimer( dev, (8*HZ), TLAN_TIMER_PHY_FINISH_AN );
 		return;
@@ -2787,7 +2803,9 @@ static void TLan_PhyFinishAutoNeg( struct net_device *dev )
 		priv->tlanFullDuplex = TRUE;
 	}
 
-	if ( ( ! ( mode & 0x0180 ) ) && ( priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10 ) && ( priv->phyNum != 0 ) ) {
+	if ( ( ! ( mode & 0x0180 ) ) &&
+	     ( priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10 ) &&
+	     ( priv->phyNum != 0 ) ) {
 		priv->phyNum = 0;
 		data = TLAN_NET_CFG_1FRAG | TLAN_NET_CFG_1CHAN | TLAN_NET_CFG_PHY_EN;
 		TLan_DioWrite16( dev->base_addr, TLAN_NET_CONFIG, data );
@@ -2796,12 +2814,14 @@ static void TLan_PhyFinishAutoNeg( struct net_device *dev )
 	}
 
 	if ( priv->phyNum == 0 ) {
-		if ( ( priv->duplex == TLAN_DUPLEX_FULL ) || ( an_adv & an_lpa & 0x0040 ) ) {
-			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, MII_GC_AUTOENB | MII_GC_DUPLEX );
-			printk( "TLAN:  Starting internal PHY with FULL-DUPLEX\n" );
+		if ( ( priv->duplex == TLAN_DUPLEX_FULL ) ||
+		     ( an_adv & an_lpa & 0x0040 ) ) {
+			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL,
+					  MII_GC_AUTOENB | MII_GC_DUPLEX );
+			pr_info("TLAN:  Starting internal PHY with FULL-DUPLEX\n" );
 		} else {
 			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, MII_GC_AUTOENB );
-			printk( "TLAN:  Starting internal PHY with HALF-DUPLEX\n" );
+			pr_info( "TLAN:  Starting internal PHY with HALF-DUPLEX\n" );
 		}
 	}
 
@@ -3209,7 +3229,8 @@ static int TLan_EeSendByte( u16 io_base, u8 data, int stop )
 	TLan_SetBit( TLAN_NET_SIO_ETXEN, sio );
 
 	if ( ( ! err ) && stop ) {
-		TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );	/* STOP, raise data while clock is high */
+		/* STOP, raise data while clock is high */
+		TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );
 		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
 		TLan_SetBit( TLAN_NET_SIO_EDATA, sio );
 	}
@@ -3272,7 +3293,8 @@ static void TLan_EeReceiveByte( u16 io_base, u8 *data, int stop )
 		TLan_SetBit( TLAN_NET_SIO_EDATA, sio );		/* No ack = 1 (?) */
 		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
 		TLan_ClearBit( TLAN_NET_SIO_ECLOK, sio );
-		TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );	/* STOP, raise data while clock is high */
+		/* STOP, raise data while clock is high */
+		TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );
 		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
 		TLan_SetBit( TLAN_NET_SIO_EDATA, sio );
 	}
diff --git a/drivers/net/tlan.h b/drivers/net/tlan.h
index 41ce0b6..4b82f28 100644
--- a/drivers/net/tlan.h
+++ b/drivers/net/tlan.h
@@ -13,8 +13,6 @@
  *  This software may be used and distributed according to the terms
  *  of the GNU General Public License, incorporated herein by reference.
  *
- ** This file is best viewed/edited with tabstop=4, colums>=132
- *
  *
  *  Dec 10, 1999	Torben Mathiasen <torben.mathiasen@compaq.com>
  *			New Maintainer
@@ -45,7 +43,9 @@
 #define TLAN_IGNORE		0
 #define TLAN_RECORD		1
 
-#define TLAN_DBG(lvl, format, args...)	if (debug&lvl) printk(KERN_DEBUG "TLAN: " format, ##args );
+#define TLAN_DBG(lvl, format, args...)	\
+	do { if (debug&lvl) printk(KERN_DEBUG "TLAN: " format, ##args ); } while(0)
+
 #define TLAN_DEBUG_GNRL		0x0001
 #define TLAN_DEBUG_TX		0x0002
 #define TLAN_DEBUG_RX		0x0004
@@ -194,7 +194,6 @@ typedef struct tlan_private_tag {
 	u32			timerSetAt;
 	u32			timerType;
 	struct timer_list	timer;
-	struct net_device_stats	stats;
 	struct board		*adapter;
 	u32			adapterRev;
 	u32			aui;
@@ -205,7 +204,6 @@ typedef struct tlan_private_tag {
 	u32			speed;
 	u8			tlanRev;
 	u8			tlanFullDuplex;
-	char                    devName[8];
 	spinlock_t		lock;
 	u8			link;
 	u8			is_eisa;
@@ -517,12 +515,18 @@ static inline void TLan_DioWrite32(u16 base_addr, u16 internal_addr, u32 data)
  * 	xor( a, xor( b, xor( c, xor( d, xor( e, xor( f, xor( g, h ) ) ) ) ) ) )
  * #define DA( a, bit )		( ( (u8) a[bit/8] ) & ( (u8) ( 1 << bit%8 ) ) )
  *
- * 	hash  = XOR8( DA(a,0), DA(a, 6), DA(a,12), DA(a,18), DA(a,24), DA(a,30), DA(a,36), DA(a,42) );
- * 	hash |= XOR8( DA(a,1), DA(a, 7), DA(a,13), DA(a,19), DA(a,25), DA(a,31), DA(a,37), DA(a,43) ) << 1;
- * 	hash |= XOR8( DA(a,2), DA(a, 8), DA(a,14), DA(a,20), DA(a,26), DA(a,32), DA(a,38), DA(a,44) ) << 2;
- * 	hash |= XOR8( DA(a,3), DA(a, 9), DA(a,15), DA(a,21), DA(a,27), DA(a,33), DA(a,39), DA(a,45) ) << 3;
- * 	hash |= XOR8( DA(a,4), DA(a,10), DA(a,16), DA(a,22), DA(a,28), DA(a,34), DA(a,40), DA(a,46) ) << 4;
- * 	hash |= XOR8( DA(a,5), DA(a,11), DA(a,17), DA(a,23), DA(a,29), DA(a,35), DA(a,41), DA(a,47) ) << 5;
+ * 	hash  = XOR8( DA(a,0), DA(a, 6), DA(a,12), DA(a,18), DA(a,24),
+ * 	              DA(a,30), DA(a,36), DA(a,42) );
+ * 	hash |= XOR8( DA(a,1), DA(a, 7), DA(a,13), DA(a,19), DA(a,25),
+ * 		      DA(a,31), DA(a,37), DA(a,43) ) << 1;
+ * 	hash |= XOR8( DA(a,2), DA(a, 8), DA(a,14), DA(a,20), DA(a,26),
+ * 		      DA(a,32), DA(a,38), DA(a,44) ) << 2;
+ * 	hash |= XOR8( DA(a,3), DA(a, 9), DA(a,15), DA(a,21), DA(a,27),
+ * 		      DA(a,33), DA(a,39), DA(a,45) ) << 3;
+ * 	hash |= XOR8( DA(a,4), DA(a,10), DA(a,16), DA(a,22), DA(a,28),
+ * 	              DA(a,34), DA(a,40), DA(a,46) ) << 4;
+ * 	hash |= XOR8( DA(a,5), DA(a,11), DA(a,17), DA(a,23), DA(a,29),
+ * 	              DA(a,35), DA(a,41), DA(a,47) ) << 5;
  *
  */
 static inline u32 TLan_HashFunc( const u8 *a )
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index c028fac..febfaee 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -803,7 +803,8 @@ static int tsi108_refill_rx(struct net_device *dev, int budget)
 		int rx = data->rxhead;
 		struct sk_buff *skb;
 
-		data->rxskbs[rx] = skb = dev_alloc_skb(TSI108_RXBUF_SIZE + 2);
+		data->rxskbs[rx] = skb = netdev_alloc_skb(dev,
+							  TSI108_RXBUF_SIZE + 2);
 		if (!skb)
 			break;
 
@@ -1352,8 +1353,9 @@ static int tsi108_open(struct net_device *dev)
 	data->rxhead = 0;
 
 	for (i = 0; i < TSI108_RXRING_LEN; i++) {
-		struct sk_buff *skb = dev_alloc_skb(TSI108_RXBUF_SIZE + NET_IP_ALIGN);
+		struct sk_buff *skb;
 
+		skb = netdev_alloc_skb(dev, TSI108_RXBUF_SIZE + NET_IP_ALIGN);
 		if (!skb) {
 			/* Bah.  No memory for now, but maybe we'll get
 			 * some more later.
