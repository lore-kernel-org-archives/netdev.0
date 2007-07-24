From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Tue, 24 Jul 2007 16:55:40 -0400
Message-ID: <20070724205540.GA17354@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:49456 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755341AbXGXUzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 16:55:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Mostly fixes or a few minor cleanups.  I did permit ethtool support
addition to ucc_geth, since it's nice to be able to control your own
NICs using standard software.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/82596.c                  |    1 +
 drivers/net/Makefile                 |    2 +-
 drivers/net/acenic.c                 |    6 -
 drivers/net/atl1/atl1_hw.h           |    9 +-
 drivers/net/atl1/atl1_main.c         |   28 ++-
 drivers/net/defxx.c                  |   17 +-
 drivers/net/ehea/ehea.h              |    2 +-
 drivers/net/ehea/ehea_main.c         |   22 ++-
 drivers/net/forcedeth.c              |   16 ++
 drivers/net/netxen/netxen_nic.h      |    3 +-
 drivers/net/netxen/netxen_nic_main.c |   48 ++--
 drivers/net/phy/vitesse.c            |    2 +-
 drivers/net/ps3_gelic_net.c          |  215 +++++++++++--------
 drivers/net/ps3_gelic_net.h          |   24 +--
 drivers/net/ucc_geth.c               |  334 +++++++++++++++++------------
 drivers/net/ucc_geth.h               |    6 +
 drivers/net/ucc_geth_ethtool.c       |  388 ++++++++++++++++++++++++++++++++++
 drivers/net/ucc_geth_mii.c           |    6 +-
 include/linux/pci_ids.h              |    4 +
 19 files changed, 824 insertions(+), 309 deletions(-)
 create mode 100644 drivers/net/ucc_geth_ethtool.c

Adrian Bunk (1):
      drivers/net/acenic.c: fix check-after-use

Andy Fleming (1):
      Fix error checking in Vitesse IRQ config

Ayaz Abdulla (2):
      forcedeth: new device ids in pci_ids.h
      forcedeth: mcp73 device addition

Chris Snook (1):
      atl1: make atl1_init_ring_ptrs static

Geert Uytterhoeven (1):
      netdev: i82596 Ethernet needs <asm/cacheflush.h>

Jan-Bernd Themann (1):
      eHEA: net_poll support

Jay Cliburn (5):
      atl1: change tpd_avail function name
      atl1: fix typo in DMA engine setup
      atl1: change cmb write threshold
      atl1: fix typo in dma_req_block
      atl1: use kernel provided ethernet length constants

Li Yang (2):
      ucc_geth: add ethtool support
      ucc_geth: add support to netif message level

Maciej W. Rozycki (1):
      defxx: Use __maybe_unused rather than a local hack

Masakazu Mokuno (10):
      ps3: fix wrong calculation of rx descriptor address
      ps3: some minor cleanups
      ps3: tx descriptor handling cleanup
      ps3: removed defines no longer used
      ps3: removed conditional ethtool support
      ps3: use net_device_stats of net_device structure
      ps3: use ethX as the name of irq
      ps3: removed calling netif_poll_enable() in open()
      ps3: fix rare issue that reenabling rx DMA fails
      ps3: reduce allocation size of rx skb buffers

dhananjay@netxen.com (1):
      netxen: Load firmware during probe, dma watchdog fix.

diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 3ff1155..d915837 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -57,6 +57,7 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/pgtable.h>
+#include <asm/cacheflush.h>
 
 static char version[] __initdata =
 	"82596.c $Revision: 1.5 $\n";
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 336af06..94b78cc 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -18,7 +18,7 @@ gianfar_driver-objs := gianfar.o \
 		gianfar_sysfs.o
 
 obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
-ucc_geth_driver-objs := ucc_geth.o ucc_geth_mii.o
+ucc_geth_driver-objs := ucc_geth.o ucc_geth_mii.o ucc_geth_ethtool.o
 
 #
 # link order important here
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index b78a4e5..62e660a 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -3128,12 +3128,6 @@ static int __devinit read_eeprom_byte(struct net_device *dev,
 	int result = 0;
 	short i;
 
-	if (!dev) {
-		printk(KERN_ERR "No device!\n");
-		result = -ENODEV;
-		goto out;
-	}
-
 	/*
 	 * Don't take interrupts on this CPU will bit banging
 	 * the %#%#@$ I2C device
diff --git a/drivers/net/atl1/atl1_hw.h b/drivers/net/atl1/atl1_hw.h
index 100c09c..939aa0f 100644
--- a/drivers/net/atl1/atl1_hw.h
+++ b/drivers/net/atl1/atl1_hw.h
@@ -680,11 +680,6 @@ void atl1_check_options(struct atl1_adapter *adapter);
 #define AUTONEG_ADVERTISE_10_100_ALL	0x000F	/* All 10/100 speeds */
 #define AUTONEG_ADVERTISE_10_ALL	0x0003	/* 10Mbps Full & Half speeds */
 
-/* The size (in bytes) of a ethernet packet */
-#define ENET_HEADER_SIZE		14
-#define MAXIMUM_ETHERNET_FRAME_SIZE	1518	/* with FCS */
-#define MINIMUM_ETHERNET_FRAME_SIZE	64	/* with FCS */
-#define ETHERNET_FCS_SIZE		4
 #define MAX_JUMBO_FRAME_SIZE		0x2800
 
 #define PHY_AUTO_NEG_TIME	45	/* 4.5 Seconds */
@@ -929,8 +924,8 @@ enum atl1_dma_req_block {
 	atl1_dma_req_128 = 0,
 	atl1_dma_req_256 = 1,
 	atl1_dma_req_512 = 2,
-	atl1_dam_req_1024 = 3,
-	atl1_dam_req_2048 = 4,
+	atl1_dma_req_1024 = 3,
+	atl1_dma_req_2048 = 4,
 	atl1_dma_req_4096 = 5
 };
 
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index fd1e156..56f6389 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -59,6 +59,7 @@
 #include <linux/skbuff.h>
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
+#include <linux/if_ether.h>
 #include <linux/irqreturn.h>
 #include <linux/workqueue.h>
 #include <linux/timer.h>
@@ -120,8 +121,8 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	struct atl1_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 
-	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
-	hw->min_frame_size = MINIMUM_ETHERNET_FRAME_SIZE;
+	hw->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	hw->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
 	adapter->wol = 0;
 	adapter->rx_buffer_len = (hw->max_frame_size + 7) & ~7;
@@ -314,7 +315,7 @@ err_nomem:
 	return -ENOMEM;
 }
 
-void atl1_init_ring_ptrs(struct atl1_adapter *adapter)
+static void atl1_init_ring_ptrs(struct atl1_adapter *adapter)
 {
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
@@ -688,9 +689,9 @@ static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	int old_mtu = netdev->mtu;
-	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
-	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
+	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
 		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
 		return -EINVAL;
@@ -908,8 +909,8 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	/* config DMA Engine */
 	value = ((((u32) hw->dmar_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
 		<< DMA_CTRL_DMAR_BURST_LEN_SHIFT) |
-		((((u32) hw->dmaw_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
-		<< DMA_CTRL_DMAR_BURST_LEN_SHIFT) | DMA_CTRL_DMAR_EN |
+		((((u32) hw->dmaw_block) & DMA_CTRL_DMAW_BURST_LEN_MASK)
+		<< DMA_CTRL_DMAW_BURST_LEN_SHIFT) | DMA_CTRL_DMAR_EN |
 		DMA_CTRL_DMAW_EN;
 	value |= (u32) hw->dma_ord;
 	if (atl1_rcb_128 == hw->rcb_value)
@@ -917,7 +918,10 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	iowrite32(value, hw->hw_addr + REG_DMA_CTRL);
 
 	/* config CMB / SMB */
-	value = hw->cmb_rrd | ((u32) hw->cmb_tpd << 16);
+	value = (hw->cmb_tpd > adapter->tpd_ring.count) ?
+		hw->cmb_tpd : adapter->tpd_ring.count;
+	value <<= 16;
+	value |= hw->cmb_rrd;
 	iowrite32(value, hw->hw_addr + REG_CMB_WRITE_TH);
 	value = hw->cmb_rx_timer | ((u32) hw->cmb_tx_timer << 16);
 	iowrite32(value, hw->hw_addr + REG_CMB_WRITE_TIMER);
@@ -1334,7 +1338,7 @@ rrd_ok:
 		skb = buffer_info->skb;
 		length = le16_to_cpu(rrd->xsz.xsum_sz.pkt_size);
 
-		skb_put(skb, length - ETHERNET_FCS_SIZE);
+		skb_put(skb, length - ETH_FCS_LEN);
 
 		/* Receive Checksum Offload */
 		atl1_rx_checksum(adapter, rrd, skb);
@@ -1422,7 +1426,7 @@ static void atl1_intr_tx(struct atl1_adapter *adapter)
 		netif_wake_queue(adapter->netdev);
 }
 
-static u16 tpd_avail(struct atl1_tpd_ring *tpd_ring)
+static u16 atl1_tpd_avail(struct atl1_tpd_ring *tpd_ring)
 {
 	u16 next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	u16 next_to_use = atomic_read(&tpd_ring->next_to_use);
@@ -1453,7 +1457,7 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
 				iph->daddr, 0, IPPROTO_TCP, 0);
 			ipofst = skb_network_offset(skb);
-			if (ipofst != ENET_HEADER_SIZE) /* 802.3 frame */
+			if (ipofst != ETH_HLEN) /* 802.3 frame */
 				tso->tsopl |= 1 << TSO_PARAM_ETHTYPE_SHIFT;
 
 			tso->tsopl |= (iph->ihl &
@@ -1708,7 +1712,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_LOCKED;
 	}
 
-	if (tpd_avail(&adapter->tpd_ring) < count) {
+	if (atl1_tpd_avail(&adapter->tpd_ring) < count) {
 		/* not enough descriptors */
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->lock, flags);
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 7df23dc..9c8e3f9 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -200,6 +200,7 @@
 
 /* Include files */
 #include <linux/bitops.h>
+#include <linux/compiler.h>
 #include <linux/delay.h>
 #include <linux/dma-mapping.h>
 #include <linux/eisa.h>
@@ -240,8 +241,6 @@ static char version[] __devinitdata =
  */
 #define NEW_SKB_SIZE (PI_RCV_DATA_K_SIZE_MAX+128)
 
-#define __unused __attribute__ ((unused))
-
 #ifdef CONFIG_PCI
 #define DFX_BUS_PCI(dev) (dev->bus == &pci_bus_type)
 #else
@@ -375,7 +374,7 @@ static inline void dfx_outl(DFX_board_t *bp, int offset, u32 data)
 
 static void dfx_port_write_long(DFX_board_t *bp, int offset, u32 data)
 {
-	struct device __unused *bdev = bp->bus_dev;
+	struct device __maybe_unused *bdev = bp->bus_dev;
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
 
@@ -399,7 +398,7 @@ static inline void dfx_inl(DFX_board_t *bp, int offset, u32 *data)
 
 static void dfx_port_read_long(DFX_board_t *bp, int offset, u32 *data)
 {
-	struct device __unused *bdev = bp->bus_dev;
+	struct device __maybe_unused *bdev = bp->bus_dev;
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
 
@@ -866,7 +865,7 @@ static void __devinit dfx_bus_uninit(struct net_device *dev)
 
 static void __devinit dfx_bus_config_check(DFX_board_t *bp)
 {
-	struct device __unused *bdev = bp->bus_dev;
+	struct device __maybe_unused *bdev = bp->bus_dev;
 	int dfx_bus_eisa = DFX_BUS_EISA(bdev);
 	int	status;				/* return code from adapter port control call */
 	u32	host_data;			/* LW data returned from port control call */
@@ -3624,8 +3623,8 @@ static void __devexit dfx_unregister(struct device *bdev)
 }
 
 
-static int __devinit __unused dfx_dev_register(struct device *);
-static int __devexit __unused dfx_dev_unregister(struct device *);
+static int __devinit __maybe_unused dfx_dev_register(struct device *);
+static int __devexit __maybe_unused dfx_dev_unregister(struct device *);
 
 #ifdef CONFIG_PCI
 static int __devinit dfx_pci_register(struct pci_dev *,
@@ -3699,7 +3698,7 @@ static struct tc_driver dfx_tc_driver = {
 };
 #endif /* CONFIG_TC */
 
-static int __devinit __unused dfx_dev_register(struct device *dev)
+static int __devinit __maybe_unused dfx_dev_register(struct device *dev)
 {
 	int status;
 
@@ -3709,7 +3708,7 @@ static int __devinit __unused dfx_dev_register(struct device *dev)
 	return status;
 }
 
-static int __devexit __unused dfx_dev_unregister(struct device *dev)
+static int __devexit __maybe_unused dfx_dev_unregister(struct device *dev)
 {
 	put_device(dev);
 	dfx_unregister(dev);
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 489c8b2..8ee2c2c 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0071"
+#define DRV_VERSION	"EHEA_0072"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 4c70a93..58702f5 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -589,6 +589,23 @@ static int ehea_poll(struct net_device *dev, int *budget)
 	return 1;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void ehea_netpoll(struct net_device *dev)
+{
+	struct ehea_port *port = netdev_priv(dev);
+
+	netif_rx_schedule(port->port_res[0].d_netdev);
+}
+#endif
+
+static int ehea_poll_firstqueue(struct net_device *dev, int *budget)
+{
+	struct ehea_port *port = netdev_priv(dev);
+	struct net_device *d_dev = port->port_res[0].d_netdev;
+
+	return ehea_poll(d_dev, budget);
+}
+
 static irqreturn_t ehea_recv_irq_handler(int irq, void *param)
 {
 	struct ehea_port_res *pr = param;
@@ -2626,7 +2643,10 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	memcpy(dev->dev_addr, &port->mac_addr, ETH_ALEN);
 
 	dev->open = ehea_open;
-	dev->poll = ehea_poll;
+	dev->poll = ehea_poll_firstqueue;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = ehea_netpoll;
+#endif
 	dev->weight = 64;
 	dev->stop = ehea_stop;
 	dev->hard_start_xmit = ehea_start_xmit;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 6d1d50a..661c747 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5546,6 +5546,22 @@ static struct pci_device_id pci_tbl[] = {
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_27),
 		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
+	{	/* MCP73 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_28),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP73 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_29),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP73 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_30),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP73 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_31),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
 	{0,},
 };
 
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 325269d..d4c92cc 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1179,8 +1179,7 @@ dma_watchdog_shutdown_poll_result(struct netxen_adapter *adapter)
 	    NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), &ctrl, 4))
 		printk(KERN_ERR "failed to read dma watchdog status\n");
 
-	return ((netxen_get_dma_watchdog_enabled(ctrl) == 0) &&
-		(netxen_get_dma_watchdog_disabled(ctrl) == 0));
+	return (netxen_get_dma_watchdog_enabled(ctrl) == 0);
 }
 
 static inline int
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b703ccf..19e2fa9 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -46,7 +46,7 @@ MODULE_DESCRIPTION("NetXen Multi port (1/10) Gigabit Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(NETXEN_NIC_LINUX_VERSIONID);
 
-char netxen_nic_driver_name[] = "netxen-nic";
+char netxen_nic_driver_name[] = "netxen_nic";
 static char netxen_nic_driver_string[] = "NetXen Network Driver version "
     NETXEN_NIC_LINUX_VERSIONID;
 
@@ -640,6 +640,10 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			NETXEN_CRB_NORMALIZE(adapter,
 				NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
 		/* Handshake with the card before we register the devices. */
+		writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+		netxen_pinit_from_rom(adapter, 0);
+		msleep(1);
+		netxen_load_firmware(adapter);
 		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	}
 
@@ -782,19 +786,18 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	if (adapter->portnum == 0) {
 		if (init_firmware_done) {
-			dma_watchdog_shutdown_request(adapter);
-			msleep(100);
 			i = 100;
-			while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
-				printk(KERN_INFO "dma_watchdog_shutdown_poll still in progress\n");
+			do {
+				if (dma_watchdog_shutdown_request(adapter) == 1)
+					break;
 				msleep(100);
-				i--;
-			}
+				if (dma_watchdog_shutdown_poll_result(adapter) == 1)
+					break;
+			} while (--i);
 
-			if (i == 0) {
-				printk(KERN_ERR "dma_watchdog_shutdown_request failed\n");
-				return;
-			}
+			if (i == 0)
+				printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
+						netdev->name);
 
 			/* clear the register for future unloads/loads */
 			writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
@@ -803,11 +806,9 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 			/* leave the hw in the same state as reboot */
 			writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-			if (netxen_pinit_from_rom(adapter, 0))
-				return;
+			netxen_pinit_from_rom(adapter, 0);
 			msleep(1);
-			if (netxen_load_firmware(adapter))
-				return;
+			netxen_load_firmware(adapter);
 			netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 		}
 
@@ -816,22 +817,21 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 		printk(KERN_INFO "State: 0x%0x\n",
 			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
 
-		dma_watchdog_shutdown_request(adapter);
-		msleep(100);
 		i = 100;
-		while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
-			printk(KERN_INFO "dma_watchdog_shutdown_poll still in progress\n");
+		do {
+			if (dma_watchdog_shutdown_request(adapter) == 1)
+				break;
 			msleep(100);
-			i--;
-		}
+			if (dma_watchdog_shutdown_poll_result(adapter) == 1)
+				break;
+		} while (--i);
 
 		if (i) {
 			netxen_free_adapter_offload(adapter);
 		} else {
-			printk(KERN_ERR "failed to dma shutdown\n");
-			return;
+			printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
+					netdev->name);
 		}
-
 	}
 
 	iounmap(adapter->ahw.db_base);
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 6a53856..8874497 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -109,7 +109,7 @@ static int vsc824x_config_intr(struct phy_device *phydev)
 		 */
 		err = phy_read(phydev, MII_VSC8244_ISTAT);
 
-		if (err)
+		if (err < 0)
 			return err;
 
 		err = phy_write(phydev, MII_VSC8244_IMASK, 0);
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 08d2506..13d1c0a 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -290,7 +290,8 @@ static void gelic_net_release_rx_chain(struct gelic_net_card *card)
 			descr->buf_addr = 0;
 			dev_kfree_skb_any(descr->skb);
 			descr->skb = NULL;
-			descr->dmac_cmd_status = GELIC_NET_DESCR_NOT_IN_USE;
+			gelic_net_set_descr_status(descr,
+						   GELIC_NET_DESCR_NOT_IN_USE);
 		}
 		descr = descr->next;
 	} while (descr != card->rx_chain.head);
@@ -374,7 +375,7 @@ static void gelic_net_release_tx_descr(struct gelic_net_card *card,
 	descr->skb = NULL;
 
 	/* set descr status */
-	descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_NOT_IN_USE;
+	gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
 }
 
 /**
@@ -403,26 +404,29 @@ static void gelic_net_release_tx_chain(struct gelic_net_card *card, int stop)
 					 "%s: forcing end of tx descriptor " \
 					 "with status %x\n",
 					 __func__, status);
-			card->netdev_stats.tx_dropped++;
+			card->netdev->stats.tx_dropped++;
 			break;
 
 		case GELIC_NET_DESCR_COMPLETE:
-			card->netdev_stats.tx_packets++;
-			card->netdev_stats.tx_bytes +=
-				tx_chain->tail->skb->len;
+			if (tx_chain->tail->skb) {
+				card->netdev->stats.tx_packets++;
+				card->netdev->stats.tx_bytes +=
+					tx_chain->tail->skb->len;
+			}
 			break;
 
 		case GELIC_NET_DESCR_CARDOWNED:
 			/* pending tx request */
 		default:
 			/* any other value (== GELIC_NET_DESCR_NOT_IN_USE) */
-			goto out;
+			if (!stop)
+				goto out;
 		}
 		gelic_net_release_tx_descr(card, tx_chain->tail);
-		release = 1;
+		release ++;
 	}
 out:
-	if (!stop && release)
+	if (!stop && (2 < release))
 		netif_wake_queue(card->netdev);
 }
 
@@ -659,19 +663,21 @@ static int gelic_net_prepare_tx_descr_v(struct gelic_net_card *card,
 {
 	dma_addr_t buf[2];
 	unsigned int vlan_len;
+	struct gelic_net_descr *sec_descr = descr->next;
 
 	if (skb->len < GELIC_NET_VLAN_POS)
 		return -EINVAL;
 
-	memcpy(&descr->vlan, skb->data, GELIC_NET_VLAN_POS);
+	vlan_len = GELIC_NET_VLAN_POS;
+	memcpy(&descr->vlan, skb->data, vlan_len);
 	if (card->vlan_index != -1) {
+		/* internal vlan tag used */
 		descr->vlan.h_vlan_proto = htons(ETH_P_8021Q); /* vlan 0x8100*/
 		descr->vlan.h_vlan_TCI = htons(card->vlan_id[card->vlan_index]);
-		vlan_len = GELIC_NET_VLAN_POS + VLAN_HLEN; /* VLAN_HLEN=4 */
-	} else
-		vlan_len = GELIC_NET_VLAN_POS; /* no vlan tag */
+		vlan_len += VLAN_HLEN; /* added for above two lines */
+	}
 
-	/* first descr */
+	/* map data area */
 	buf[0] = dma_map_single(ctodev(card), &descr->vlan,
 			     vlan_len, DMA_TO_DEVICE);
 
@@ -682,20 +688,6 @@ static int gelic_net_prepare_tx_descr_v(struct gelic_net_card *card,
 		return -ENOMEM;
 	}
 
-	descr->buf_addr = buf[0];
-	descr->buf_size = vlan_len;
-	descr->skb = skb; /* not used */
-	descr->data_status = 0;
-	gelic_net_set_txdescr_cmdstat(descr, skb, 1); /* not the frame end */
-
-	/* second descr */
-	card->tx_chain.head = card->tx_chain.head->next;
-	descr->next_descr_addr = descr->next->bus_addr;
-	descr = descr->next;
-	if (gelic_net_get_descr_status(descr) != GELIC_NET_DESCR_NOT_IN_USE)
-		/* XXX will be removed */
-		dev_err(ctodev(card), "descr is not free!\n");
-
 	buf[1] = dma_map_single(ctodev(card), skb->data + GELIC_NET_VLAN_POS,
 			     skb->len - GELIC_NET_VLAN_POS,
 			     DMA_TO_DEVICE);
@@ -710,13 +702,24 @@ static int gelic_net_prepare_tx_descr_v(struct gelic_net_card *card,
 		return -ENOMEM;
 	}
 
-	descr->buf_addr = buf[1];
-	descr->buf_size = skb->len - GELIC_NET_VLAN_POS;
-	descr->skb = skb;
+	/* first descr */
+	descr->buf_addr = buf[0];
+	descr->buf_size = vlan_len;
+	descr->skb = NULL; /* not used */
 	descr->data_status = 0;
-	descr->next_descr_addr = 0; /* terminate hw descr */
-	gelic_net_set_txdescr_cmdstat(descr, skb, 0);
+	descr->next_descr_addr = descr->next->bus_addr;
+	gelic_net_set_txdescr_cmdstat(descr, skb, 1); /* not the frame end */
 
+	/* second descr */
+	sec_descr->buf_addr = buf[1];
+	sec_descr->buf_size = skb->len - GELIC_NET_VLAN_POS;
+	sec_descr->skb = skb;
+	sec_descr->data_status = 0;
+	sec_descr->next_descr_addr = 0; /* terminate hw descr */
+	gelic_net_set_txdescr_cmdstat(sec_descr, skb, 0);
+
+	/* bump free descriptor pointer */
+	card->tx_chain.head = sec_descr->next;
 	return 0;
 }
 
@@ -729,7 +732,7 @@ static int gelic_net_prepare_tx_descr_v(struct gelic_net_card *card,
 static int gelic_net_kick_txdma(struct gelic_net_card *card,
 				struct gelic_net_descr *descr)
 {
-	int status = -ENXIO;
+	int status = 0;
 	int count = 10;
 
 	if (card->tx_dma_progress)
@@ -763,47 +766,62 @@ static int gelic_net_kick_txdma(struct gelic_net_card *card,
 static int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct gelic_net_card *card = netdev_priv(netdev);
-	struct gelic_net_descr *descr = NULL;
+	struct gelic_net_descr *descr;
 	int result;
 	unsigned long flags;
 
 	spin_lock_irqsave(&card->tx_dma_lock, flags);
 
 	gelic_net_release_tx_chain(card, 0);
-	if (!skb)
-		goto kick;
+
 	descr = gelic_net_get_next_tx_descr(card);
 	if (!descr) {
+		/*
+		 * no more descriptors free
+		 */
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
-	result = gelic_net_prepare_tx_descr_v(card, descr, skb);
-
-	if (result)
-		goto error;
 
-	card->tx_chain.head = card->tx_chain.head->next;
-
-	if (descr->prev)
-		descr->prev->next_descr_addr = descr->bus_addr;
-kick:
+	result = gelic_net_prepare_tx_descr_v(card, descr, skb);
+	if (result) {
+		/*
+		 * DMA map failed.  As chanses are that failure
+		 * would continue, just release skb and return
+		 */
+		card->netdev->stats.tx_dropped++;
+		dev_kfree_skb_any(skb);
+		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
+		return NETDEV_TX_OK;
+	}
+	/*
+	 * link this prepared descriptor to previous one
+	 * to achieve high performance
+	 */
+	descr->prev->next_descr_addr = descr->bus_addr;
 	/*
 	 * as hardware descriptor is modified in the above lines,
 	 * ensure that the hardware sees it
 	 */
 	wmb();
-	if (gelic_net_kick_txdma(card, card->tx_chain.tail))
-		goto error;
+	if (gelic_net_kick_txdma(card, descr)) {
+		/*
+		 * kick failed.
+		 * release descriptors which were just prepared
+		 */
+		card->netdev->stats.tx_dropped++;
+		gelic_net_release_tx_descr(card, descr);
+		gelic_net_release_tx_descr(card, descr->next);
+		card->tx_chain.tail = descr->next->next;
+		dev_info(ctodev(card), "%s: kick failure\n", __func__);
+	} else {
+		/* OK, DMA started/reserved */
+		netdev->trans_start = jiffies;
+	}
 
-	netdev->trans_start = jiffies;
 	spin_unlock_irqrestore(&card->tx_dma_lock, flags);
 	return NETDEV_TX_OK;
-
-error:
-	card->netdev_stats.tx_dropped++;
-	spin_unlock_irqrestore(&card->tx_dma_lock, flags);
-	return NETDEV_TX_LOCKED;
 }
 
 /**
@@ -854,8 +872,8 @@ static void gelic_net_pass_skb_up(struct gelic_net_descr *descr,
 		skb->ip_summed = CHECKSUM_NONE;
 
 	/* update netdevice statistics */
-	card->netdev_stats.rx_packets++;
-	card->netdev_stats.rx_bytes += skb->len;
+	card->netdev->stats.rx_packets++;
+	card->netdev->stats.rx_bytes += skb->len;
 
 	/* pass skb up to stack */
 	netif_receive_skb(skb);
@@ -895,38 +913,67 @@ static int gelic_net_decode_one_descr(struct gelic_net_card *card)
 	    (status == GELIC_NET_DESCR_FORCE_END)) {
 		dev_info(ctodev(card), "dropping RX descriptor with state %x\n",
 			 status);
-		card->netdev_stats.rx_dropped++;
+		card->netdev->stats.rx_dropped++;
 		goto refill;
 	}
 
-	if ((status != GELIC_NET_DESCR_COMPLETE) &&
-	    (status != GELIC_NET_DESCR_FRAME_END)) {
+	if (status == GELIC_NET_DESCR_BUFFER_FULL) {
+		/*
+		 * Buffer full would occur if and only if
+		 * the frame length was longer than the size of this
+		 * descriptor's buffer.  If the frame length was equal
+		 * to or shorter than buffer'size, FRAME_END condition
+		 * would occur.
+		 * Anyway this frame was longer than the MTU,
+		 * just drop it.
+		 */
+		dev_info(ctodev(card), "overlength frame\n");
+		goto refill;
+	}
+	/*
+	 * descriptoers any other than FRAME_END here should
+	 * be treated as error.
+	 */
+	if (status != GELIC_NET_DESCR_FRAME_END) {
 		dev_dbg(ctodev(card), "RX descriptor with state %x\n",
 			status);
 		goto refill;
 	}
 
 	/* ok, we've got a packet in descr */
-	gelic_net_pass_skb_up(descr, card); /* 1: skb_up sccess */
-
+	gelic_net_pass_skb_up(descr, card);
 refill:
-	descr->next_descr_addr = 0; /* unlink the descr */
+	/*
+	 * So that always DMAC can see the end
+	 * of the descriptor chain to avoid
+	 * from unwanted DMAC overrun.
+	 */
+	descr->next_descr_addr = 0;
 
 	/* change the descriptor state: */
 	gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
 
-	/* refill one desc
-	 * FIXME: this can fail, but for now, just leave this
-	 * descriptor without skb
+	/*
+	 * this call can fail, but for now, just leave this
+	 * decriptor without skb
 	 */
 	gelic_net_prepare_rx_descr(card, descr);
+
 	chain->head = descr;
 	chain->tail = descr->next;
+
+	/*
+	 * Set this descriptor the end of the chain.
+	 */
 	descr->prev->next_descr_addr = descr->bus_addr;
 
+	/*
+	 * If dmac chain was met, DMAC stopped.
+	 * thus re-enable it
+	 */
 	if (dmac_chain_ended) {
-		gelic_net_enable_rxdmac(card);
-		dev_dbg(ctodev(card), "reenable rx dma\n");
+		card->rx_dma_restart_required = 1;
+		dev_dbg(ctodev(card), "reenable rx dma scheduled\n");
 	}
 
 	return 1;
@@ -968,20 +1015,6 @@ static int gelic_net_poll(struct net_device *netdev, int *budget)
 	} else
 		return 1;
 }
-
-/**
- * gelic_net_get_stats - get interface statistics
- * @netdev: interface device structure
- *
- * returns the interface statistics residing in the gelic_net_card struct
- */
-static struct net_device_stats *gelic_net_get_stats(struct net_device *netdev)
-{
-	struct gelic_net_card *card = netdev_priv(netdev);
-
-	return &card->netdev_stats;
-}
-
 /**
  * gelic_net_change_mtu - changes the MTU of an interface
  * @netdev: interface device structure
@@ -1016,6 +1049,11 @@ static irqreturn_t gelic_net_interrupt(int irq, void *ptr)
 	if (!status)
 		return IRQ_NONE;
 
+	if (card->rx_dma_restart_required) {
+		card->rx_dma_restart_required = 0;
+		gelic_net_enable_rxdmac(card);
+	}
+
 	if (status & GELIC_NET_RXINT) {
 		gelic_net_rx_irq_off(card);
 		netif_rx_schedule(netdev);
@@ -1024,9 +1062,10 @@ static irqreturn_t gelic_net_interrupt(int irq, void *ptr)
 	if (status & GELIC_NET_TXINT) {
 		spin_lock_irqsave(&card->tx_dma_lock, flags);
 		card->tx_dma_progress = 0;
+		gelic_net_release_tx_chain(card, 0);
+		/* kick outstanding tx descriptor if any */
+		gelic_net_kick_txdma(card, card->tx_chain.tail);
 		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
-		/* start pending DMA */
-		gelic_net_xmit(NULL, netdev);
 	}
 	return IRQ_HANDLED;
 }
@@ -1068,7 +1107,7 @@ static int gelic_net_open_device(struct gelic_net_card *card)
 	}
 
 	result = request_irq(card->netdev->irq, gelic_net_interrupt,
-			     IRQF_DISABLED, "gelic network", card->netdev);
+			     IRQF_DISABLED, card->netdev->name, card->netdev);
 
 	if (result) {
 		dev_info(ctodev(card), "%s:%d: request_irq failed (%d)\n",
@@ -1107,7 +1146,7 @@ static int gelic_net_open(struct net_device *netdev)
 			card->descr, GELIC_NET_TX_DESCRIPTORS))
 		goto alloc_tx_failed;
 	if (gelic_net_init_chain(card, &card->rx_chain,
-				 card->descr + GELIC_NET_RX_DESCRIPTORS,
+				 card->descr + GELIC_NET_TX_DESCRIPTORS,
 				 GELIC_NET_RX_DESCRIPTORS))
 		goto alloc_rx_failed;
 
@@ -1129,7 +1168,6 @@ static int gelic_net_open(struct net_device *netdev)
 
 	netif_start_queue(netdev);
 	netif_carrier_on(netdev);
-	netif_poll_enable(netdev);
 
 	return 0;
 
@@ -1141,7 +1179,6 @@ alloc_tx_failed:
 	return -ENOMEM;
 }
 
-#ifdef GELIC_NET_ETHTOOL
 static void gelic_net_get_drvinfo (struct net_device *netdev,
 				   struct ethtool_drvinfo *info)
 {
@@ -1261,7 +1298,6 @@ static struct ethtool_ops gelic_net_ethtool_ops = {
 	.get_rx_csum	= gelic_net_get_rx_csum,
 	.set_rx_csum	= gelic_net_set_rx_csum,
 };
-#endif
 
 /**
  * gelic_net_tx_timeout_task - task scheduled by the watchdog timeout
@@ -1320,7 +1356,6 @@ static void gelic_net_setup_netdev_ops(struct net_device *netdev)
 	netdev->open = &gelic_net_open;
 	netdev->stop = &gelic_net_stop;
 	netdev->hard_start_xmit = &gelic_net_xmit;
-	netdev->get_stats = &gelic_net_get_stats;
 	netdev->set_multicast_list = &gelic_net_set_multi;
 	netdev->change_mtu = &gelic_net_change_mtu;
 	/* tx watchdog */
@@ -1329,9 +1364,7 @@ static void gelic_net_setup_netdev_ops(struct net_device *netdev)
 	/* NAPI */
 	netdev->poll = &gelic_net_poll;
 	netdev->weight = GELIC_NET_NAPI_WEIGHT;
-#ifdef GELIC_NET_ETHTOOL
 	netdev->ethtool_ops = &gelic_net_ethtool_ops;
-#endif
 }
 
 /**
diff --git a/drivers/net/ps3_gelic_net.h b/drivers/net/ps3_gelic_net.h
index 5e1c286..a9c4c4f 100644
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -28,21 +28,12 @@
 #ifndef _GELIC_NET_H
 #define _GELIC_NET_H
 
-#define GELIC_NET_DRV_NAME "Gelic Network Driver"
-#define GELIC_NET_DRV_VERSION "1.0"
-
-#define GELIC_NET_ETHTOOL               /* use ethtool */
-
-/* ioctl */
-#define GELIC_NET_GET_MODE              (SIOCDEVPRIVATE + 0)
-#define GELIC_NET_SET_MODE              (SIOCDEVPRIVATE + 1)
-
 /* descriptors */
 #define GELIC_NET_RX_DESCRIPTORS        128 /* num of descriptors */
 #define GELIC_NET_TX_DESCRIPTORS        128 /* num of descriptors */
 
-#define GELIC_NET_MAX_MTU               2308
-#define GELIC_NET_MIN_MTU               64
+#define GELIC_NET_MAX_MTU               VLAN_ETH_FRAME_LEN
+#define GELIC_NET_MIN_MTU               VLAN_ETH_ZLEN
 #define GELIC_NET_RXBUF_ALIGN           128
 #define GELIC_NET_RX_CSUM_DEFAULT       1 /* hw chksum */
 #define GELIC_NET_WATCHDOG_TIMEOUT      5*HZ
@@ -90,7 +81,8 @@ enum gelic_net_int1_status {
 					    */
 #define GELIC_NET_RXVLNPKT	0x00200000 /* VLAN packet */
 /* bit 20..16 reserved */
-#define GELIC_NET_RXRECNUM	0x0000ff00 /* reception receipt number */
+#define GELIC_NET_RXRRECNUM	0x0000ff00 /* reception receipt number */
+#define GELIC_NET_RXRRECNUM_SHIFT	8
 /* bit 7..0 reserved */
 
 #define GELIC_NET_TXDESC_TAIL		0
@@ -133,19 +125,19 @@ enum gelic_net_int1_status {
 						      * interrupt status */
 
 #define GELIC_NET_DMAC_CMDSTAT_CHAIN_END  0x00000002 /* RXDCEIS:DMA stopped */
-#define GELIC_NET_DMAC_CMDSTAT_NOT_IN_USE 0xb0000000
 #define GELIC_NET_DESCR_IND_PROC_SHIFT    28
 #define GELIC_NET_DESCR_IND_PROC_MASKO    0x0fffffff
 
 
 enum gelic_net_descr_status {
-	GELIC_NET_DESCR_COMPLETE            = 0x00, /* used in rx and tx */
+	GELIC_NET_DESCR_COMPLETE            = 0x00, /* used in tx */
+	GELIC_NET_DESCR_BUFFER_FULL         = 0x00, /* used in rx */
 	GELIC_NET_DESCR_RESPONSE_ERROR      = 0x01, /* used in rx and tx */
 	GELIC_NET_DESCR_PROTECTION_ERROR    = 0x02, /* used in rx and tx */
 	GELIC_NET_DESCR_FRAME_END           = 0x04, /* used in rx */
 	GELIC_NET_DESCR_FORCE_END           = 0x05, /* used in rx and tx */
 	GELIC_NET_DESCR_CARDOWNED           = 0x0a, /* used in rx and tx */
-	GELIC_NET_DESCR_NOT_IN_USE                  /* any other value */
+	GELIC_NET_DESCR_NOT_IN_USE          = 0x0b  /* any other value */
 };
 /* for lv1_net_control */
 #define GELIC_NET_GET_MAC_ADDRESS               0x0000000000000001
@@ -216,10 +208,10 @@ struct gelic_net_card {
 
 	struct gelic_net_descr_chain tx_chain;
 	struct gelic_net_descr_chain rx_chain;
+	int rx_dma_restart_required;
 	/* gurad dmac descriptor chain*/
 	spinlock_t chain_lock;
 
-	struct net_device_stats netdev_stats;
 	int rx_csum;
 	/* guard tx_dma_progress */
 	spinlock_t tx_dma_lock;
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e4736a3..12e01b2 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -43,10 +43,6 @@
 
 #undef DEBUG
 
-#define DRV_DESC "QE UCC Gigabit Ethernet Controller"
-#define DRV_NAME "ucc_geth"
-#define DRV_VERSION "1.1"
-
 #define ugeth_printk(level, format, arg...)  \
         printk(level format "\n", ## arg)
 
@@ -64,9 +60,19 @@
 #else
 #define ugeth_vdbg(fmt, args...) do { } while (0)
 #endif				/* UGETH_VERBOSE_DEBUG */
+#define UGETH_MSG_DEFAULT	(NETIF_MSG_IFUP << 1 ) - 1
 
+void uec_set_ethtool_ops(struct net_device *netdev);
+	
 static DEFINE_SPINLOCK(ugeth_lock);
 
+static struct {
+	u32 msg_enable;
+} debug = { -1 };
+
+module_param_named(debug, debug.msg_enable, int, 0);
+MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 0xffff=all)");
+
 static struct ucc_geth_info ugeth_primary_info = {
 	.uf_info = {
 		    .bd_mem_part = MEM_PART_SYSTEM,
@@ -104,6 +110,7 @@ static struct ucc_geth_info ugeth_primary_info = {
 	.maxRetransmission = 0xf,
 	.collisionWindow = 0x37,
 	.receiveFlowControl = 1,
+	.transmitFlowControl = 1,
 	.maxGroupAddrInHash = 4,
 	.maxIndAddrInHash = 4,
 	.prel = 7,
@@ -139,7 +146,9 @@ static struct ucc_geth_info ugeth_primary_info = {
 	.numStationAddresses = UCC_GETH_NUM_OF_STATION_ADDRESSES_1,
 	.largestexternallookupkeysize =
 	    QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_NONE,
-	.statisticsMode = UCC_GETH_STATISTICS_GATHERING_MODE_NONE,
+	.statisticsMode = UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE |
+		UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX |
+		UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX,
 	.vlanOperationTagged = UCC_GETH_VLAN_OPERATION_TAGGED_NOP,
 	.vlanOperationNonTagged = UCC_GETH_VLAN_OPERATION_NON_TAGGED_NOP,
 	.rxQoSMode = UCC_GETH_QOS_MODE_DEFAULT,
@@ -281,7 +290,8 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 
 	for (i = 0; i < num_entries; i++) {
 		if ((snum = qe_get_snum()) < 0) {
-			ugeth_err("fill_init_enet_entries: Can not get SNUM.");
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("fill_init_enet_entries: Can not get SNUM.");
 			return snum;
 		}
 		if ((i == 0) && skip_page_for_first_entry)
@@ -291,8 +301,8 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 			init_enet_offset =
 			    qe_muram_alloc(thread_size, thread_alignment);
 			if (IS_ERR_VALUE(init_enet_offset)) {
-				ugeth_err
-		("fill_init_enet_entries: Can not allocate DPRAM memory.");
+				if (netif_msg_ifup(ugeth))
+					ugeth_err("fill_init_enet_entries: Can not allocate DPRAM memory.");
 				qe_put_snum((u8) snum);
 				return -ENOMEM;
 			}
@@ -1200,7 +1210,7 @@ static int init_inter_frame_gap_params(u8 non_btb_cs_ipg,
 	return 0;
 }
 
-static int init_flow_control_params(u32 automatic_flow_control_mode,
+int init_flow_control_params(u32 automatic_flow_control_mode,
 				    int rx_flow_control_enable,
 				    int tx_flow_control_enable,
 				    u16 pause_period,
@@ -1486,9 +1496,9 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 
 	ret_val = init_preamble_length(ug_info->prel, &ug_regs->maccfg2);
 	if (ret_val != 0) {
-		ugeth_err
-		    ("%s: Preamble length must be between 3 and 7 inclusive.",
-		     __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: Preamble length must be between 3 and 7 inclusive.",
+			     __FUNCTION__);
 		return ret_val;
 	}
 
@@ -1726,7 +1736,8 @@ static int ugeth_enable(struct ucc_geth_private *ugeth, enum comm_dir mode)
 
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
-		ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
 		return -EINVAL;
 	}
 
@@ -1754,7 +1765,8 @@ static int ugeth_disable(struct ucc_geth_private * ugeth, enum comm_dir mode)
 
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
-		ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
 		return -EINVAL;
 	}
 
@@ -2306,7 +2318,9 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 
 	if (!((uf_info->bd_mem_part == MEM_PART_SYSTEM) ||
 	      (uf_info->bd_mem_part == MEM_PART_MURAM))) {
-		ugeth_err("%s: Bad memory partition value.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: Bad memory partition value.",
+					__FUNCTION__);
 		return -EINVAL;
 	}
 
@@ -2315,9 +2329,10 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		if ((ug_info->bdRingLenRx[i] < UCC_GETH_RX_BD_RING_SIZE_MIN) ||
 		    (ug_info->bdRingLenRx[i] %
 		     UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT)) {
-			ugeth_err
-			    ("%s: Rx BD ring length must be multiple of 4,"
-				" no smaller than 8.", __FUNCTION__);
+			if (netif_msg_probe(ugeth))
+				ugeth_err
+				    ("%s: Rx BD ring length must be multiple of 4, no smaller than 8.",
+					__FUNCTION__);
 			return -EINVAL;
 		}
 	}
@@ -2325,9 +2340,10 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	/* Tx BD lengths */
 	for (i = 0; i < ug_info->numQueuesTx; i++) {
 		if (ug_info->bdRingLenTx[i] < UCC_GETH_TX_BD_RING_SIZE_MIN) {
-			ugeth_err
-			    ("%s: Tx BD ring length must be no smaller than 2.",
-			     __FUNCTION__);
+			if (netif_msg_probe(ugeth))
+				ugeth_err
+				    ("%s: Tx BD ring length must be no smaller than 2.",
+				     __FUNCTION__);
 			return -EINVAL;
 		}
 	}
@@ -2335,31 +2351,35 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	/* mrblr */
 	if ((uf_info->max_rx_buf_length == 0) ||
 	    (uf_info->max_rx_buf_length % UCC_GETH_MRBLR_ALIGNMENT)) {
-		ugeth_err
-		    ("%s: max_rx_buf_length must be non-zero multiple of 128.",
-		     __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err
+			    ("%s: max_rx_buf_length must be non-zero multiple of 128.",
+			     __FUNCTION__);
 		return -EINVAL;
 	}
 
 	/* num Tx queues */
 	if (ug_info->numQueuesTx > NUM_TX_QUEUES) {
-		ugeth_err("%s: number of tx queues too large.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: number of tx queues too large.", __FUNCTION__);
 		return -EINVAL;
 	}
 
 	/* num Rx queues */
 	if (ug_info->numQueuesRx > NUM_RX_QUEUES) {
-		ugeth_err("%s: number of rx queues too large.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: number of rx queues too large.", __FUNCTION__);
 		return -EINVAL;
 	}
 
 	/* l2qt */
 	for (i = 0; i < UCC_GETH_VLAN_PRIORITY_MAX; i++) {
 		if (ug_info->l2qt[i] >= ug_info->numQueuesRx) {
-			ugeth_err
-			    ("%s: VLAN priority table entry must not be"
-				" larger than number of Rx queues.",
-			     __FUNCTION__);
+			if (netif_msg_probe(ugeth))
+				ugeth_err
+				    ("%s: VLAN priority table entry must not be"
+					" larger than number of Rx queues.",
+				     __FUNCTION__);
 			return -EINVAL;
 		}
 	}
@@ -2367,26 +2387,29 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	/* l3qt */
 	for (i = 0; i < UCC_GETH_IP_PRIORITY_MAX; i++) {
 		if (ug_info->l3qt[i] >= ug_info->numQueuesRx) {
-			ugeth_err
-			    ("%s: IP priority table entry must not be"
-				" larger than number of Rx queues.",
-			     __FUNCTION__);
+			if (netif_msg_probe(ugeth))
+				ugeth_err
+				    ("%s: IP priority table entry must not be"
+					" larger than number of Rx queues.",
+				     __FUNCTION__);
 			return -EINVAL;
 		}
 	}
 
 	if (ug_info->cam && !ug_info->ecamptr) {
-		ugeth_err("%s: If cam mode is chosen, must supply cam ptr.",
-			  __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: If cam mode is chosen, must supply cam ptr.",
+				  __FUNCTION__);
 		return -EINVAL;
 	}
 
 	if ((ug_info->numStationAddresses !=
 	     UCC_GETH_NUM_OF_STATION_ADDRESSES_1)
 	    && ug_info->rxExtendedFiltering) {
-		ugeth_err("%s: Number of station addresses greater than 1 "
-			  "not allowed in extended parsing mode.",
-			  __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: Number of station addresses greater than 1 "
+				  "not allowed in extended parsing mode.",
+				  __FUNCTION__);
 		return -EINVAL;
 	}
 
@@ -2399,7 +2422,8 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		uf_info->uccm_mask |= (UCCE_TXBF_SINGLE_MASK << i);
 	/* Initialize the general fast UCC block. */
 	if (ucc_fast_init(uf_info, &ugeth->uccf)) {
-		ugeth_err("%s: Failed to init uccf.", __FUNCTION__);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: Failed to init uccf.", __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2452,7 +2476,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		numThreadsRxNumerical = 8;
 		break;
 	default:
-		ugeth_err("%s: Bad number of Rx threads value.", __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Bad number of Rx threads value.",
+				       	__FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
@@ -2475,7 +2501,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		numThreadsTxNumerical = 8;
 		break;
 	default:
-		ugeth_err("%s: Bad number of Tx threads value.", __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Bad number of Tx threads value.",
+				       	__FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
@@ -2507,7 +2535,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* For more details see the hardware spec.           */
 	init_flow_control_params(ug_info->aufc,
 				 ug_info->receiveFlowControl,
-				 1,
+				 ug_info->transmitFlowControl,
 				 ug_info->pausePeriod,
 				 ug_info->extensionField,
 				 &uf_regs->upsmr,
@@ -2527,8 +2555,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					      ug_info->backToBackInterFrameGap,
 					      &ug_regs->ipgifg);
 	if (ret_val != 0) {
-		ugeth_err("%s: IPGIFG initialization parameter too large.",
-			  __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: IPGIFG initialization parameter too large.",
+				  __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -2544,7 +2573,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					  ug_info->collisionWindow,
 					  &ug_regs->hafdup);
 	if (ret_val != 0) {
-		ugeth_err("%s: Half Duplex initialization parameter too large.",
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Half Duplex initialization parameter too large.",
 			  __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
@@ -2597,9 +2627,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 							 tx_bd_ring_offset[j]);
 		}
 		if (!ugeth->p_tx_bd_ring[j]) {
-			ugeth_err
-			    ("%s: Can not allocate memory for Tx bd rings.",
-			     __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+				    ("%s: Can not allocate memory for Tx bd rings.",
+				     __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2632,9 +2663,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 							 rx_bd_ring_offset[j]);
 		}
 		if (!ugeth->p_rx_bd_ring[j]) {
-			ugeth_err
-			    ("%s: Can not allocate memory for Rx bd rings.",
-			     __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+				    ("%s: Can not allocate memory for Rx bd rings.",
+				     __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2648,8 +2680,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					      GFP_KERNEL);
 
 		if (ugeth->tx_skbuff[j] == NULL) {
-			ugeth_err("%s: Could not allocate tx_skbuff",
-				  __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Could not allocate tx_skbuff",
+					  __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2679,8 +2712,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					      GFP_KERNEL);
 
 		if (ugeth->rx_skbuff[j] == NULL) {
-			ugeth_err("%s: Could not allocate rx_skbuff",
-				  __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Could not allocate rx_skbuff",
+					  __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2711,9 +2745,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(sizeof(struct ucc_geth_tx_global_pram),
 			   UCC_GETH_TX_GLOBAL_PRAM_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->tx_glbl_pram_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_tx_glbl_pram.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_tx_glbl_pram.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2733,9 +2768,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   32 * (numThreadsTxNumerical == 1),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->thread_dat_tx_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_thread_data_tx.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_thread_data_tx.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2761,9 +2797,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   sizeof(struct ucc_geth_send_queue_qd),
 			   UCC_GETH_SEND_QUEUE_QUEUE_DESCRIPTOR_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->send_q_mem_reg_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_send_q_mem_reg.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_send_q_mem_reg.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2804,9 +2841,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		    qe_muram_alloc(sizeof(struct ucc_geth_scheduler),
 				   UCC_GETH_SCHEDULER_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->scheduler_offset)) {
-			ugeth_err
-			 ("%s: Can not allocate DPRAM memory for p_scheduler.",
-			     __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+				 ("%s: Can not allocate DPRAM memory for p_scheduler.",
+				     __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2852,9 +2890,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				   (struct ucc_geth_tx_firmware_statistics_pram),
 				   UCC_GETH_TX_STATISTICS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->tx_fw_statistics_pram_offset)) {
-			ugeth_err
-			    ("%s: Can not allocate DPRAM memory for"
-				" p_tx_fw_statistics_pram.", __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+				    ("%s: Can not allocate DPRAM memory for"
+					" p_tx_fw_statistics_pram.",
+				       	__FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2891,9 +2931,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(sizeof(struct ucc_geth_rx_global_pram),
 			   UCC_GETH_RX_GLOBAL_PRAM_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->rx_glbl_pram_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_rx_glbl_pram.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_rx_glbl_pram.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2912,9 +2953,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   sizeof(struct ucc_geth_thread_data_rx),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->thread_dat_rx_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_thread_data_rx.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_thread_data_rx.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2935,9 +2977,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				   (struct ucc_geth_rx_firmware_statistics_pram),
 				   UCC_GETH_RX_STATISTICS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->rx_fw_statistics_pram_offset)) {
-			ugeth_err
-				("%s: Can not allocate DPRAM memory for"
-				" p_rx_fw_statistics_pram.", __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+					("%s: Can not allocate DPRAM memory for"
+					" p_rx_fw_statistics_pram.", __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2957,9 +3000,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   sizeof(struct ucc_geth_rx_interrupt_coalescing_entry)
 			   + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->rx_irq_coalescing_tbl_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for"
-			" p_rx_irq_coalescing_tbl.", __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for"
+				" p_rx_irq_coalescing_tbl.", __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3025,9 +3069,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			    sizeof(struct ucc_geth_rx_prefetched_bds)),
 			   UCC_GETH_RX_BD_QUEUES_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->rx_bd_qs_tbl_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_rx_bd_qs_tbl.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_rx_bd_qs_tbl.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3102,8 +3147,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* initialize extended filtering */
 	if (ug_info->rxExtendedFiltering) {
 		if (!ug_info->extendedFilteringChainPointer) {
-			ugeth_err("%s: Null Extended Filtering Chain Pointer.",
-				  __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Null Extended Filtering Chain Pointer.",
+					  __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -EINVAL;
 		}
@@ -3114,9 +3160,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		    qe_muram_alloc(sizeof(struct ucc_geth_exf_global_pram),
 		UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->exf_glbl_param_offset)) {
-			ugeth_err
-				("%s: Can not allocate DPRAM memory for"
-				" p_exf_glbl_param.", __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err
+					("%s: Can not allocate DPRAM memory for"
+					" p_exf_glbl_param.", __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -3161,9 +3208,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	 */
 	if (!(ugeth->p_init_enet_param_shadow =
 	      kmalloc(sizeof(struct ucc_geth_init_pram), GFP_KERNEL))) {
-		ugeth_err
-		    ("%s: Can not allocate memory for"
-			" p_UccInitEnetParamShadows.", __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate memory for"
+				" p_UccInitEnetParamShadows.", __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3196,8 +3244,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_8_BYTES)
 	    && (ug_info->largestexternallookupkeysize !=
 		QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)) {
-		ugeth_err("%s: Invalid largest External Lookup Key Size.",
-			  __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Invalid largest External Lookup Key Size.",
+				  __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 	}
@@ -3222,8 +3271,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		/* Rx needs one extra for terminator */
 		, size, UCC_GETH_THREAD_RX_PRAM_ALIGNMENT,
 		ug_info->riscRx, 1)) != 0) {
-			ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-				__FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
+					__FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -3237,8 +3287,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				    sizeof(struct ucc_geth_thread_tx_pram),
 				    UCC_GETH_THREAD_TX_PRAM_ALIGNMENT,
 				    ug_info->riscTx, 0)) != 0) {
-		ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-			  __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
+				  __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -3246,8 +3297,9 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* Load Rx bds with buffers */
 	for (i = 0; i < ug_info->numQueuesRx; i++) {
 		if ((ret_val = rx_bd_buffer_set(ugeth, (u8) i)) != 0) {
-			ugeth_err("%s: Can not fill Rx bds with buffers.",
-				  __FUNCTION__);
+			if (netif_msg_ifup(ugeth))
+				ugeth_err("%s: Can not fill Rx bds with buffers.",
+					  __FUNCTION__);
 			ucc_geth_memclean(ugeth);
 			return ret_val;
 		}
@@ -3256,9 +3308,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* Allocate InitEnet command parameter structure */
 	init_enet_pram_offset = qe_muram_alloc(sizeof(struct ucc_geth_init_pram), 4);
 	if (IS_ERR_VALUE(init_enet_pram_offset)) {
-		ugeth_err
-		    ("%s: Can not allocate DPRAM memory for p_init_enet_pram.",
-		     __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err
+			    ("%s: Can not allocate DPRAM memory for p_init_enet_pram.",
+			     __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3428,8 +3481,9 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		if (!skb ||
 		    (!(bd_status & (R_F | R_L))) ||
 		    (bd_status & R_ERRORS_FATAL)) {
-			ugeth_vdbg("%s, %d: ERROR!!! skb - 0x%08x",
-				   __FUNCTION__, __LINE__, (u32) skb);
+			if (netif_msg_rx_err(ugeth))
+				ugeth_err("%s, %d: ERROR!!! skb - 0x%08x",
+					   __FUNCTION__, __LINE__, (u32) skb);
 			if (skb)
 				dev_kfree_skb_any(skb);
 
@@ -3458,7 +3512,8 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 
 		skb = get_new_skb(ugeth, bd);
 		if (!skb) {
-			ugeth_warn("%s: No Rx Data Buffer", __FUNCTION__);
+			if (netif_msg_rx_err(ugeth))
+				ugeth_warn("%s: No Rx Data Buffer", __FUNCTION__);
 			ugeth->stats.rx_dropped++;
 			break;
 		}
@@ -3649,28 +3704,32 @@ static int ucc_geth_open(struct net_device *dev)
 
 	/* Test station address */
 	if (dev->dev_addr[0] & ENET_GROUP_ADDR) {
-		ugeth_err("%s: Multicast address used for station address"
-			  " - is this what you wanted?", __FUNCTION__);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Multicast address used for station address"
+				  " - is this what you wanted?", __FUNCTION__);
 		return -EINVAL;
 	}
 
 	err = ucc_struct_init(ugeth);
 	if (err) {
-		ugeth_err("%s: Cannot configure internal struct, aborting.", dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot configure internal struct, aborting.", dev->name);
 		return err;
 	}
 
 	err = ucc_geth_startup(ugeth);
 	if (err) {
-		ugeth_err("%s: Cannot configure net device, aborting.",
-			  dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot configure net device, aborting.",
+				  dev->name);
 		return err;
 	}
 
 	err = adjust_enet_interface(ugeth);
 	if (err) {
-		ugeth_err("%s: Cannot configure net device, aborting.",
-			  dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot configure net device, aborting.",
+				  dev->name);
 		return err;
 	}
 
@@ -3687,7 +3746,8 @@ static int ucc_geth_open(struct net_device *dev)
 
 	err = init_phy(dev);
 	if (err) {
-		ugeth_err("%s: Cannot initialize PHY, aborting.", dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot initialize PHY, aborting.", dev->name);
 		return err;
 	}
 
@@ -3697,15 +3757,17 @@ static int ucc_geth_open(struct net_device *dev)
 	    request_irq(ugeth->ug_info->uf_info.irq, ucc_geth_irq_handler, 0,
 			"UCC Geth", dev);
 	if (err) {
-		ugeth_err("%s: Cannot get IRQ for net device, aborting.",
-			  dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot get IRQ for net device, aborting.",
+				  dev->name);
 		ucc_geth_stop(ugeth);
 		return err;
 	}
 
 	err = ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
 	if (err) {
-		ugeth_err("%s: Cannot enable net device, aborting.", dev->name);
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot enable net device, aborting.", dev->name);
 		ucc_geth_stop(ugeth);
 		return err;
 	}
@@ -3732,8 +3794,6 @@ static int ucc_geth_close(struct net_device *dev)
 	return 0;
 }
 
-const struct ethtool_ops ucc_geth_ethtool_ops = { };
-
 static phy_interface_t to_phy_interface(const char *phy_connection_type)
 {
 	if (strcasecmp(phy_connection_type, "mii") == 0)
@@ -3790,6 +3850,13 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		return -ENODEV;
 
 	ug_info = &ugeth_info[ucc_num];
+	if (ug_info == NULL) {
+		if (netif_msg_probe(&debug))
+			ugeth_err("%s: [%d] Missing additional data!",
+				       	__FUNCTION__, ucc_num);
+		return -ENODEV;
+	}
+
 	ug_info->uf_info.ucc_num = ucc_num;
 
 	prop = of_get_property(np, "rx-clock", NULL);
@@ -3868,15 +3935,10 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
 	ug_info->mdio_bus = res.start;
 
-	printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d) \n",
-		ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
-		ug_info->uf_info.irq);
-
-	if (ug_info == NULL) {
-		ugeth_err("%s: [%d] Missing additional data!", __FUNCTION__,
-			  ucc_num);
-		return -ENODEV;
-	}
+	if (netif_msg_probe(&debug))
+		printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d) \n",
+			ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
+			ug_info->uf_info.irq);
 
 	/* Create an ethernet device instance */
 	dev = alloc_etherdev(sizeof(*ugeth));
@@ -3896,6 +3958,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	SET_NETDEV_DEV(dev, device);
 
 	/* Fill in the dev structure */
+	uec_set_ethtool_ops(dev);
 	dev->open = ucc_geth_open;
 	dev->hard_start_xmit = ucc_geth_start_xmit;
 	dev->tx_timeout = ucc_geth_timeout;
@@ -3909,16 +3972,16 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 //    dev->change_mtu = ucc_geth_change_mtu;
 	dev->mtu = 1500;
 	dev->set_multicast_list = ucc_geth_set_multi;
-	dev->ethtool_ops = &ucc_geth_ethtool_ops;
 
-	ugeth->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
+	ugeth->msg_enable = netif_msg_init(debug.msg_enable, UGETH_MSG_DEFAULT);
 	ugeth->phy_interface = phy_interface;
 	ugeth->max_speed = max_speed;
 
 	err = register_netdev(dev);
 	if (err) {
-		ugeth_err("%s: Cannot register net device, aborting.",
-			  dev->name);
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: Cannot register net device, aborting.",
+				  dev->name);
 		free_netdev(dev);
 		return err;
 	}
@@ -3972,7 +4035,8 @@ static int __init ucc_geth_init(void)
 	if (ret)
 		return ret;
 
-	printk(KERN_INFO "ucc_geth: " DRV_DESC "\n");
+	if (netif_msg_drv(&debug))
+		printk(KERN_INFO "ucc_geth: " DRV_DESC "\n");
 	for (i = 0; i < 8; i++)
 		memcpy(&(ugeth_info[i]), &ugeth_primary_info,
 		       sizeof(ugeth_primary_info));
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index a29e1c3..bb4dac8 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -30,6 +30,10 @@
 
 #include "ucc_geth_mii.h"
 
+#define DRV_DESC "QE UCC Gigabit Ethernet Controller"
+#define DRV_NAME "ucc_geth"
+#define DRV_VERSION "1.1"
+
 #define NUM_TX_QUEUES                   8
 #define NUM_RX_QUEUES                   8
 #define NUM_BDS_IN_PREFETCHED_BDS       4
@@ -896,6 +900,7 @@ struct ucc_geth_hardware_statistics {
 #define UCC_GETH_TX_VTAG_TABLE_ENTRY_MAX        8
 #define UCC_GETH_RX_BD_RING_SIZE_MIN            8
 #define UCC_GETH_TX_BD_RING_SIZE_MIN            2
+#define UCC_GETH_BD_RING_SIZE_MAX		0xffff
 
 #define UCC_GETH_SIZE_OF_BD                     QE_SIZEOF_BD
 
@@ -1135,6 +1140,7 @@ struct ucc_geth_info {
 	int bro;
 	int ecm;
 	int receiveFlowControl;
+	int transmitFlowControl;
 	u8 maxGroupAddrInHash;
 	u8 maxIndAddrInHash;
 	u8 prel;
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
new file mode 100644
index 0000000..a8994c7
--- /dev/null
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -0,0 +1,388 @@
+/*
+ * Copyright (c) 2007 Freescale Semiconductor, Inc. All rights reserved.
+ *
+ * Description: QE UCC Gigabit Ethernet Ethtool API Set
+ *
+ * Author: Li Yang <leoli@freescale.com>
+ *
+ * Limitation: 
+ * Can only get/set setttings of the first queue.
+ * Need to re-open the interface manually after changing some paramters.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/stddef.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/fsl_devices.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+#include <asm/types.h>
+#include <asm/uaccess.h>
+
+#include "ucc_geth.h"
+#include "ucc_geth_mii.h"
+
+static char hw_stat_gstrings[][ETH_GSTRING_LEN] = {
+	"tx-64-frames",
+	"tx-65-127-frames",
+	"tx-128-255-frames",
+	"rx-64-frames",
+	"rx-65-127-frames",
+	"rx-128-255-frames",
+	"tx-bytes-ok",
+	"tx-pause-frames",
+	"tx-multicast-frames",
+	"tx-broadcast-frames",
+	"rx-frames",
+	"rx-bytes-ok",
+	"rx-bytes-all",
+	"rx-multicast-frames",
+	"rx-broadcast-frames",
+	"stats-counter-carry",
+	"stats-counter-mask",
+	"rx-dropped-frames",
+};
+
+static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
+	"tx-single-collision",
+	"tx-multiple-collision",
+	"tx-late-collsion",
+	"tx-aborted-frames",
+	"tx-lost-frames",
+	"tx-carrier-sense-errors",
+	"tx-frames-ok",
+	"tx-excessive-differ-frames",
+	"tx-256-511-frames",
+	"tx-1024-1518-frames",
+	"tx-jumbo-frames",
+};
+
+static char rx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
+	"rx-crc-errors",
+	"rx-alignment-errors",
+	"rx-in-range-length-errors",
+	"rx-out-of-range-length-errors",
+	"rx-too-long-frames",
+	"rx-runt",
+	"rx-very-long-event",
+	"rx-symbol-errors",
+	"rx-busy-drop-frames",
+	"reserved",
+	"reserved",
+	"rx-mismatch-drop-frames",
+	"rx-small-than-64",
+	"rx-256-511-frames",
+	"rx-512-1023-frames",
+	"rx-1024-1518-frames",
+	"rx-jumbo-frames",
+	"rx-mac-error-loss",
+	"rx-pause-frames",
+	"reserved",
+	"rx-vlan-removed",
+	"rx-vlan-replaced",
+	"rx-vlan-inserted",
+	"rx-ip-checksum-errors",
+};
+
+#define UEC_HW_STATS_LEN ARRAY_SIZE(hw_stat_gstrings)
+#define UEC_TX_FW_STATS_LEN ARRAY_SIZE(tx_fw_stat_gstrings)
+#define UEC_RX_FW_STATS_LEN ARRAY_SIZE(rx_fw_stat_gstrings)
+
+extern int init_flow_control_params(u32 automatic_flow_control_mode,
+		int rx_flow_control_enable,
+		int tx_flow_control_enable, u16 pause_period,
+		u16 extension_field, volatile u32 *upsmr_register,
+		volatile u32 *uempr_register, volatile u32 *maccfg1_register);
+
+static int
+uec_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	struct phy_device *phydev = ugeth->phydev;
+	struct ucc_geth_info *ug_info = ugeth->ug_info;
+
+	if (!phydev)
+		return -ENODEV;
+
+	ecmd->maxtxpkt = 1;
+	ecmd->maxrxpkt = ug_info->interruptcoalescingmaxvalue[0];
+
+	return phy_ethtool_gset(phydev, ecmd);
+}
+
+static int
+uec_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	struct phy_device *phydev = ugeth->phydev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(phydev, ecmd);
+}
+
+static void
+uec_get_pauseparam(struct net_device *netdev,
+                     struct ethtool_pauseparam *pause)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+
+	pause->autoneg = ugeth->phydev->autoneg;
+
+	if (ugeth->ug_info->receiveFlowControl)
+		pause->rx_pause = 1;
+	if (ugeth->ug_info->transmitFlowControl)
+		pause->tx_pause = 1;
+}
+
+static int
+uec_set_pauseparam(struct net_device *netdev,
+                     struct ethtool_pauseparam *pause)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	int ret = 0;
+
+	ugeth->ug_info->receiveFlowControl = pause->rx_pause;
+	ugeth->ug_info->transmitFlowControl = pause->tx_pause;
+	
+	if (ugeth->phydev->autoneg) {
+		if (netif_running(netdev)) {
+			/* FIXME: automatically restart */
+			printk(KERN_INFO
+				"Please re-open the interface.\n");
+		}
+	} else {
+		struct ucc_geth_info *ug_info = ugeth->ug_info;
+
+		ret = init_flow_control_params(ug_info->aufc,
+					ug_info->receiveFlowControl,
+					ug_info->transmitFlowControl,
+					ug_info->pausePeriod,
+					ug_info->extensionField,
+					&ugeth->uccf->uf_regs->upsmr,
+					&ugeth->ug_regs->uempr,
+					&ugeth->ug_regs->maccfg1);
+	}
+
+	return ret;
+}
+
+static uint32_t
+uec_get_msglevel(struct net_device *netdev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	return ugeth->msg_enable;
+}
+
+static void
+uec_set_msglevel(struct net_device *netdev, uint32_t data)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	ugeth->msg_enable = data;
+}
+
+static int
+uec_get_regs_len(struct net_device *netdev)
+{
+	return sizeof(struct ucc_geth);
+}
+
+static void
+uec_get_regs(struct net_device *netdev,
+               struct ethtool_regs *regs, void *p)
+{
+	int i;
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	u32 __iomem *ug_regs = (u32 __iomem *)ugeth->ug_regs;
+	u32 *buff = p;
+
+	for (i = 0; i < sizeof(struct ucc_geth) / sizeof(u32); i++)
+		buff[i] = in_be32(&ug_regs[i]);
+}
+
+static void
+uec_get_ringparam(struct net_device *netdev,
+                    struct ethtool_ringparam *ring)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	struct ucc_geth_info *ug_info = ugeth->ug_info;
+	int queue = 0;
+
+	ring->rx_max_pending = UCC_GETH_BD_RING_SIZE_MAX;
+	ring->rx_mini_max_pending = UCC_GETH_BD_RING_SIZE_MAX;
+	ring->rx_jumbo_max_pending = UCC_GETH_BD_RING_SIZE_MAX;
+	ring->tx_max_pending = UCC_GETH_BD_RING_SIZE_MAX;
+
+	ring->rx_pending = ug_info->bdRingLenRx[queue];
+	ring->rx_mini_pending = ug_info->bdRingLenRx[queue];
+	ring->rx_jumbo_pending = ug_info->bdRingLenRx[queue];
+	ring->tx_pending = ug_info->bdRingLenTx[queue];
+}
+
+static int
+uec_set_ringparam(struct net_device *netdev,
+                    struct ethtool_ringparam *ring)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	struct ucc_geth_info *ug_info = ugeth->ug_info;
+	int queue = 0, ret = 0;
+
+	if (ring->rx_pending < UCC_GETH_RX_BD_RING_SIZE_MIN) {
+		printk("%s: RxBD ring size must be no smaller than %d.\n",
+			       	netdev->name, UCC_GETH_RX_BD_RING_SIZE_MIN);
+		return -EINVAL;
+	}
+	if (ring->rx_pending % UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT) {
+		printk("%s: RxBD ring size must be multiple of %d.\n",
+			netdev->name, UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT);
+		return -EINVAL;
+	}
+	if (ring->tx_pending < UCC_GETH_TX_BD_RING_SIZE_MIN) {
+		printk("%s: TxBD ring size must be no smaller than %d.\n",
+				netdev->name, UCC_GETH_TX_BD_RING_SIZE_MIN);
+		return -EINVAL;
+	}
+
+	ug_info->bdRingLenRx[queue] = ring->rx_pending;
+	ug_info->bdRingLenTx[queue] = ring->tx_pending;
+
+	if (netif_running(netdev)) {
+		/* FIXME: restart automatically */
+		printk(KERN_INFO
+			"Please re-open the interface.\n");
+	}
+
+	return ret;
+}
+
+static int uec_get_stats_count(struct net_device *netdev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	u32 stats_mode = ugeth->ug_info->statisticsMode;
+	int len = 0;
+
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE)
+		len += UEC_HW_STATS_LEN;
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX)
+		len += UEC_TX_FW_STATS_LEN;
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
+		len += UEC_RX_FW_STATS_LEN;
+
+	return len;
+}
+
+static void uec_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	u32 stats_mode = ugeth->ug_info->statisticsMode;
+
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE) {
+		memcpy(buf, hw_stat_gstrings, UEC_HW_STATS_LEN *
+			       	ETH_GSTRING_LEN);
+		buf += UEC_HW_STATS_LEN * ETH_GSTRING_LEN;
+	}
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX) {
+		memcpy(buf, tx_fw_stat_gstrings, UEC_TX_FW_STATS_LEN *
+			       	ETH_GSTRING_LEN);
+		buf += UEC_TX_FW_STATS_LEN * ETH_GSTRING_LEN;
+	}
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
+		memcpy(buf, tx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
+			       	ETH_GSTRING_LEN);
+}
+
+static void uec_get_ethtool_stats(struct net_device *netdev,
+		struct ethtool_stats *stats, uint64_t *data)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	u32 stats_mode = ugeth->ug_info->statisticsMode;
+	u32 __iomem *base;
+	int i, j = 0;
+
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE) {
+		base = (u32 __iomem *)&ugeth->ug_regs->tx64;
+		for (i = 0; i < UEC_HW_STATS_LEN; i++)
+			data[j++] = (u64)in_be32(&base[i]);
+	}
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX) {
+		base = (u32 __iomem *)ugeth->p_tx_fw_statistics_pram;
+		for (i = 0; i < UEC_TX_FW_STATS_LEN; i++)
+			data[j++] = (u64)in_be32(&base[i]);
+	}
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX) {
+		base = (u32 __iomem *)ugeth->p_rx_fw_statistics_pram;
+		for (i = 0; i < UEC_RX_FW_STATS_LEN; i++)
+			data[j++] = (u64)in_be32(&base[i]);
+	}
+}
+
+static int uec_nway_reset(struct net_device *netdev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+
+	return phy_start_aneg(ugeth->phydev);
+}
+
+/* Report driver information */
+static void
+uec_get_drvinfo(struct net_device *netdev,
+                       struct ethtool_drvinfo *drvinfo)
+{
+	strncpy(drvinfo->driver, DRV_NAME, 32);
+	strncpy(drvinfo->version, DRV_VERSION, 32);
+	strncpy(drvinfo->fw_version, "N/A", 32);
+	strncpy(drvinfo->bus_info, "QUICC ENGINE", 32);
+	drvinfo->n_stats = uec_get_stats_count(netdev);
+	drvinfo->testinfo_len = 0;
+	drvinfo->eedump_len = 0;
+	drvinfo->regdump_len = uec_get_regs_len(netdev);
+}
+
+static const struct ethtool_ops uec_ethtool_ops = {
+	.get_settings           = uec_get_settings,
+	.set_settings           = uec_set_settings,
+	.get_drvinfo            = uec_get_drvinfo,
+	.get_regs_len           = uec_get_regs_len,
+	.get_regs               = uec_get_regs,
+	.get_msglevel           = uec_get_msglevel,
+	.set_msglevel           = uec_set_msglevel,
+	.nway_reset             = uec_nway_reset,
+	.get_link               = ethtool_op_get_link,
+	.get_ringparam          = uec_get_ringparam,
+	.set_ringparam          = uec_set_ringparam,
+	.get_pauseparam         = uec_get_pauseparam,
+	.set_pauseparam         = uec_set_pauseparam,
+	.get_sg                 = ethtool_op_get_sg,
+	.set_sg                 = ethtool_op_set_sg,
+	.get_tso                = ethtool_op_get_tso,
+	.get_stats_count        = uec_get_stats_count,
+	.get_strings            = uec_get_strings,
+	.get_ethtool_stats      = uec_get_ethtool_stats,
+	.get_perm_addr          = ethtool_op_get_perm_addr,
+};
+
+void uec_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &uec_ethtool_ops);
+}
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 7bcb82f..5f8c2d3 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -54,8 +54,8 @@
 #define vdbg(format, arg...) do {} while(0)
 #endif
 
-#define DRV_DESC "QE UCC Ethernet Controller MII Bus"
-#define DRV_NAME "fsl-uec_mdio"
+#define MII_DRV_DESC "QE UCC Ethernet Controller MII Bus"
+#define MII_DRV_NAME "fsl-uec_mdio"
 
 /* Write value to the PHY for this device to the register at regnum, */
 /* waiting until the write is done before it returns.  All PHY */
@@ -261,7 +261,7 @@ static struct of_device_id uec_mdio_match[] = {
 };
 
 static struct of_platform_driver uec_mdio_driver = {
-	.name	= DRV_NAME,
+	.name	= MII_DRV_NAME,
 	.probe	= uec_mdio_probe,
 	.remove	= uec_mdio_remove,
 	.match_table	= uec_mdio_match,
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index cbabb9c..42d3278 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1225,6 +1225,10 @@
 #define PCI_DEVICE_ID_NVIDIA_NVENET_25              0x054D
 #define PCI_DEVICE_ID_NVIDIA_NVENET_26              0x054E
 #define PCI_DEVICE_ID_NVIDIA_NVENET_27              0x054F
+#define PCI_DEVICE_ID_NVIDIA_NVENET_28              0x07DC
+#define PCI_DEVICE_ID_NVIDIA_NVENET_29              0x07DD
+#define PCI_DEVICE_ID_NVIDIA_NVENET_30              0x07DE
+#define PCI_DEVICE_ID_NVIDIA_NVENET_31              0x07DF
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP67_IDE       0x0560
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP73_IDE       0x056C
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP77_IDE       0x0759
