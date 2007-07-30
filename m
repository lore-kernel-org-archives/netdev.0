From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Mon, 30 Jul 2007 17:23:33 -0400
Message-ID: <20070730212333.GA8049@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:60554 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966359AbXG3VXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 17:23:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All are fixes except the two "S2IO: Remove ...from the driver" patches,
which remove two unused features, and a couple doc patches.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 MAINTAINERS                          |    4 +-
 drivers/net/forcedeth.c              |   36 ++-
 drivers/net/gianfar_mii.c            |    2 +-
 drivers/net/gianfar_mii.h            |    2 +-
 drivers/net/lib8390.c                |   46 +++
 drivers/net/netxen/netxen_nic_main.c |   44 ++--
 drivers/net/pcmcia/nmclan_cs.c       |    4 +-
 drivers/net/pcmcia/smc91c92_cs.c     |   23 +-
 drivers/net/s2io-regs.h              |    5 +-
 drivers/net/s2io.c                   |  542 ++++++++++------------------------
 drivers/net/s2io.h                   |   11 +-
 drivers/net/usb/pegasus.c            |    4 +-
 12 files changed, 279 insertions(+), 444 deletions(-)

Ayaz Abdulla (1):
      forcedeth: mac address correct

Dhananjay Phadke (1):
      netxen: drop redudant spinlock

Jarek Poplawski (1):
      lib8390: comment on locking by Alan Cox

Komuro (1):
      PATCH kernel 2.6.22] PCMCIA-NETDEV : modify smc91c92_cs.c to become SMP safe

Kumar Gala (1):
      gfar: Fix modpost warning

Micah Gruber (2):
      Fix a potential NULL pointer dereference in write_bulk_callback() in drivers/net/usb/pegasus.c
      Fix a potential NULL pointer dereference in mace_interrupt() in drivers/net/pcmcia/nmclan_cs.c

Ramkrishna Vepa (3):
      S2io: Mask spurious interrupts
      S2io: Fix crash when resetting adapter
      S2io: Increment received packet count correctly

Valerie Henson (1):
      tulip: Remove tulip maintainer

Veena Parat (4):
      S2IO: Removing 3 buffer mode support from the driver
      S2IO: Removing MSI support from driver
      S2IO: Checking for the return value of pci map function
      S2IO: Implementing review comments from old patches

dhananjay@netxen.com (2):
      netxen: re-init station address after h/w init
      netxen: Fix interrupt handling for multiport adapters

diff --git a/MAINTAINERS b/MAINTAINERS
index babd00b..5c784be 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3674,11 +3674,9 @@ W:	http://www.auk.cx/tms380tr/
 S:	Maintained
 
 TULIP NETWORK DRIVER
-P:	Valerie Henson
-M:	val@nmt.edu
 L:	tulip-users@lists.sourceforge.net
 W:	http://sourceforge.net/projects/tulip/
-S:	Maintained
+S:	Orphan
 
 TUN/TAP driver
 P:	Maxim Krasnyansky
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 661c747..51e1cb4 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -178,6 +178,7 @@
 #define DEV_HAS_STATISTICS_V2   0x0800  /* device supports hw statistics version 2 */
 #define DEV_HAS_TEST_EXTENDED   0x1000  /* device supports extended diagnostic test */
 #define DEV_HAS_MGMT_UNIT       0x2000  /* device supports management unit */
+#define DEV_HAS_CORRECT_MACADDR 0x4000  /* device supports correct mac address order */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -5172,7 +5173,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 
 	/* check the workaround bit for correct mac address order */
 	txreg = readl(base + NvRegTransmitPoll);
-	if (txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) {
+	if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
+	    (id->driver_data & DEV_HAS_CORRECT_MACADDR)) {
 		/* mac address is already in correct order */
 		dev->dev_addr[0] = (np->orig_mac[0] >>  0) & 0xff;
 		dev->dev_addr[1] = (np->orig_mac[0] >>  8) & 0xff;
@@ -5500,67 +5502,67 @@ static struct pci_device_id pci_tbl[] = {
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_16),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_17),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_18),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_19),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_20),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_21),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_22),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_23),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_24),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_25),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_26),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_27),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_28),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_29),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_30),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_31),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{0,},
 };
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index ac3596f..100bf41 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -245,7 +245,7 @@ int __init gfar_mdio_init(void)
 	return driver_register(&gianfar_mdio_driver);
 }
 
-void __exit gfar_mdio_exit(void)
+void gfar_mdio_exit(void)
 {
 	driver_unregister(&gianfar_mdio_driver);
 }
diff --git a/drivers/net/gianfar_mii.h b/drivers/net/gianfar_mii.h
index 5d34004..b373091 100644
--- a/drivers/net/gianfar_mii.h
+++ b/drivers/net/gianfar_mii.h
@@ -42,5 +42,5 @@ struct gfar_mii {
 int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
 int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
 int __init gfar_mdio_init(void);
-void __exit gfar_mdio_exit(void);
+void gfar_mdio_exit(void);
 #endif /* GIANFAR_PHY_H */
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 721ee38..c429a50 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -143,6 +143,52 @@ static void __NS8390_init(struct net_device *dev, int startp);
  *	annoying the transmit function is called bh atomic. That places
  *	restrictions on the user context callers as disable_irq won't save
  *	them.
+ *
+ *	Additional explanation of problems with locking by Alan Cox:
+ *
+ *	"The author (me) didn't use spin_lock_irqsave because the slowness of the
+ *	card means that approach caused horrible problems like losing serial data
+ *	at 38400 baud on some chips. Rememeber many 8390 nics on PCI were ISA
+ *	chips with FPGA front ends.
+ *	
+ *	Ok the logic behind the 8390 is very simple:
+ *	
+ *	Things to know
+ *		- IRQ delivery is asynchronous to the PCI bus
+ *		- Blocking the local CPU IRQ via spin locks was too slow
+ *		- The chip has register windows needing locking work
+ *	
+ *	So the path was once (I say once as people appear to have changed it
+ *	in the mean time and it now looks rather bogus if the changes to use
+ *	disable_irq_nosync_irqsave are disabling the local IRQ)
+ *	
+ *	
+ *		Take the page lock
+ *		Mask the IRQ on chip
+ *		Disable the IRQ (but not mask locally- someone seems to have
+ *			broken this with the lock validator stuff)
+ *			[This must be _nosync as the page lock may otherwise
+ *				deadlock us]
+ *		Drop the page lock and turn IRQs back on
+ *		
+ *		At this point an existing IRQ may still be running but we can't
+ *		get a new one
+ *	
+ *		Take the lock (so we know the IRQ has terminated) but don't mask
+ *	the IRQs on the processor
+ *		Set irqlock [for debug]
+ *	
+ *		Transmit (slow as ****)
+ *	
+ *		re-enable the IRQ
+ *	
+ *	
+ *	We have to use disable_irq because otherwise you will get delayed
+ *	interrupts on the APIC bus deadlocking the transmit path.
+ *	
+ *	Quite hairy but the chip simply wasn't designed for SMP and you can't
+ *	even ACK an interrupt without risking corrupting other parallel
+ *	activities on the chip." [lkml, 25 Jul 2007]
  */
 
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 19e2fa9..08a62ac 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -335,7 +335,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->ahw.pdev = pdev;
 	adapter->ahw.pci_func  = pci_func_id;
 	spin_lock_init(&adapter->tx_lock);
-	spin_lock_init(&adapter->lock);
 
 	/* remap phys address */
 	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
@@ -895,8 +894,6 @@ static int netxen_nic_open(struct net_device *netdev)
 
 	/* Done here again so that even if phantom sw overwrote it,
 	 * we set it */
-	if (adapter->macaddr_set)
-		adapter->macaddr_set(adapter, netdev->dev_addr);
 	if (adapter->init_port
 	    && adapter->init_port(adapter, adapter->portnum) != 0) {
 	    del_timer_sync(&adapter->watchdog_timer);
@@ -904,6 +901,8 @@ static int netxen_nic_open(struct net_device *netdev)
 				netxen_nic_driver_name, adapter->portnum);
 		return -EIO;
 	}
+	if (adapter->macaddr_set)
+		adapter->macaddr_set(adapter, netdev->dev_addr);
 
 	netxen_nic_set_link_parameters(adapter);
 
@@ -930,6 +929,8 @@ static int netxen_nic_close(struct net_device *netdev)
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
+	netxen_nic_disable_int(adapter);
+
 	cmd_buff = adapter->cmd_buf_arr;
 	for (i = 0; i < adapter->max_tx_desc_count; i++) {
 		buffrag = cmd_buff->frag_array;
@@ -1226,15 +1227,12 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 {
 	struct netxen_adapter *adapter = 
 		container_of(work, struct netxen_adapter, tx_timeout_task);
-	unsigned long flags;
 
 	printk(KERN_ERR "%s %s: transmit timeout, resetting.\n",
 	       netxen_nic_driver_name, adapter->netdev->name);
 
-	spin_lock_irqsave(&adapter->lock, flags);
 	netxen_nic_close(adapter->netdev);
 	netxen_nic_open(adapter->netdev);
-	spin_unlock_irqrestore(&adapter->lock, flags);
 	adapter->netdev->trans_start = jiffies;
 	netif_wake_queue(adapter->netdev);
 }
@@ -1243,28 +1241,12 @@ static int
 netxen_handle_int(struct netxen_adapter *adapter, struct net_device *netdev)
 {
 	u32 ret = 0;
-	u32 our_int = 0;
 
 	DPRINTK(INFO, "Entered handle ISR\n");
 	adapter->stats.ints++;
 
-	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-		our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
-		/* not our interrupt */
-		if ((our_int & (0x80 << adapter->portnum)) == 0)
-			return ret;
-	}
-
 	netxen_nic_disable_int(adapter);
 
-	if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
-		/* claim interrupt */
-		if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-			writel(our_int & ~((u32)(0x80 << adapter->portnum)),
-			NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
-		}
-	}
-
 	if (netxen_nic_rx_has_work(adapter) || netxen_nic_tx_has_work(adapter)) {
 		if (netif_rx_schedule_prep(netdev)) {
 			/*
@@ -1298,6 +1280,7 @@ irqreturn_t netxen_intr(int irq, void *data)
 {
 	struct netxen_adapter *adapter;
 	struct net_device *netdev;
+	u32 our_int = 0;
 
 	if (unlikely(!irq)) {
 		return IRQ_NONE;	/* Not our interrupt */
@@ -1305,7 +1288,22 @@ irqreturn_t netxen_intr(int irq, void *data)
 
 	adapter = (struct netxen_adapter *)data;
 	netdev  = adapter->netdev;
-	/* process our status queue (for all 4 ports) */
+
+	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
+		our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+		/* not our interrupt */
+		if ((our_int & (0x80 << adapter->portnum)) == 0)
+			return IRQ_NONE;
+	}
+
+	if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
+		/* claim interrupt */
+		if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
+			writel(our_int & ~((u32)(0x80 << adapter->portnum)),
+			NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+		}
+	}
+
 	if (netif_running(netdev))
 		netxen_handle_int(adapter, netdev);
 
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 73da611..997c2d0 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -996,7 +996,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 {
   struct net_device *dev = (struct net_device *) dev_id;
   mace_private *lp = netdev_priv(dev);
-  kio_addr_t ioaddr = dev->base_addr;
+  kio_addr_t ioaddr;
   int status;
   int IntrCnt = MACE_MAX_IR_ITERATIONS;
 
@@ -1006,6 +1006,8 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
     return IRQ_NONE;
   }
 
+  ioaddr = dev->base_addr;
+
   if (lp->tx_irq_disabled) {
     printk(
       (lp->tx_irq_disabled?
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 7912dbd..af6728c 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1368,6 +1368,7 @@ static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
     kio_addr_t ioaddr = dev->base_addr;
     u_short num_pages;
     short time_out, ir;
+    unsigned long flags;
 
     netif_stop_queue(dev);
 
@@ -1395,6 +1396,7 @@ static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
     /* A packet is now waiting. */
     smc->packets_waiting++;
 
+    spin_lock_irqsave(&smc->lock, flags);
     SMC_SELECT_BANK(2);	/* Paranoia, we should always be in window 2 */
 
     /* need MC_RESET to keep the memory consistent. errata? */
@@ -1411,6 +1413,7 @@ static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	    /* Acknowledge the interrupt, send the packet. */
 	    outw((ir&0xff00) | IM_ALLOC_INT, ioaddr + INTERRUPT);
 	    smc_hardware_send_packet(dev);	/* Send the packet now.. */
+	    spin_unlock_irqrestore(&smc->lock, flags);
 	    return 0;
 	}
     }
@@ -1418,6 +1421,7 @@ static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
     /* Otherwise defer until the Tx-space-allocated interrupt. */
     DEBUG(2, "%s: memory allocation deferred.\n", dev->name);
     outw((IM_ALLOC_INT << 8) | (ir & 0xff00), ioaddr + INTERRUPT);
+    spin_unlock_irqrestore(&smc->lock, flags);
 
     return 0;
 }
@@ -1523,6 +1527,7 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
     DEBUG(3, "%s: SMC91c92 interrupt %d at %#x.\n", dev->name,
 	  irq, ioaddr);
 
+    spin_lock(&smc->lock);
     smc->watchdog = 0;
     saved_bank = inw(ioaddr + BANK_SELECT);
     if ((saved_bank & 0xff00) != 0x3300) {
@@ -1620,6 +1625,7 @@ irq_done:
 	readb(smc->base+MEGAHERTZ_ISR);
     }
 #endif
+    spin_unlock(&smc->lock);
     return IRQ_RETVAL(handled);
 }
 
@@ -1902,6 +1908,9 @@ static void media_check(u_long arg)
     kio_addr_t ioaddr = dev->base_addr;
     u_short i, media, saved_bank;
     u_short link;
+    unsigned long flags;
+
+    spin_lock_irqsave(&smc->lock, flags);
 
     saved_bank = inw(ioaddr + BANK_SELECT);
 
@@ -1934,6 +1943,7 @@ static void media_check(u_long arg)
 	smc->media.expires = jiffies + HZ/100;
 	add_timer(&smc->media);
 	SMC_SELECT_BANK(saved_bank);
+	spin_unlock_irqrestore(&smc->lock, flags);
 	return;
     }
 
@@ -2007,6 +2017,7 @@ reschedule:
     smc->media.expires = jiffies + HZ;
     add_timer(&smc->media);
     SMC_SELECT_BANK(saved_bank);
+    spin_unlock_irqrestore(&smc->lock, flags);
 }
 
 static int smc_link_ok(struct net_device *dev)
@@ -2094,14 +2105,14 @@ static int smc_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	u16 saved_bank = inw(ioaddr + BANK_SELECT);
 	int ret;
 
-	SMC_SELECT_BANK(3);
 	spin_lock_irq(&smc->lock);
+	SMC_SELECT_BANK(3);
 	if (smc->cfg & CFG_MII_SELECT)
 		ret = mii_ethtool_gset(&smc->mii_if, ecmd);
 	else
 		ret = smc_netdev_get_ecmd(dev, ecmd);
-	spin_unlock_irq(&smc->lock);
 	SMC_SELECT_BANK(saved_bank);
+	spin_unlock_irq(&smc->lock);
 	return ret;
 }
 
@@ -2112,14 +2123,14 @@ static int smc_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	u16 saved_bank = inw(ioaddr + BANK_SELECT);
 	int ret;
 
-	SMC_SELECT_BANK(3);
 	spin_lock_irq(&smc->lock);
+	SMC_SELECT_BANK(3);
 	if (smc->cfg & CFG_MII_SELECT)
 		ret = mii_ethtool_sset(&smc->mii_if, ecmd);
 	else
 		ret = smc_netdev_set_ecmd(dev, ecmd);
-	spin_unlock_irq(&smc->lock);
 	SMC_SELECT_BANK(saved_bank);
+	spin_unlock_irq(&smc->lock);
 	return ret;
 }
 
@@ -2130,11 +2141,11 @@ static u32 smc_get_link(struct net_device *dev)
 	u16 saved_bank = inw(ioaddr + BANK_SELECT);
 	u32 ret;
 
-	SMC_SELECT_BANK(3);
 	spin_lock_irq(&smc->lock);
+	SMC_SELECT_BANK(3);
 	ret = smc_link_ok(dev);
-	spin_unlock_irq(&smc->lock);
 	SMC_SELECT_BANK(saved_bank);
+	spin_unlock_irq(&smc->lock);
 	return ret;
 }
 
diff --git a/drivers/net/s2io-regs.h b/drivers/net/s2io-regs.h
index 4cb710b..cfa2679 100644
--- a/drivers/net/s2io-regs.h
+++ b/drivers/net/s2io-regs.h
@@ -747,10 +747,9 @@ struct XENA_dev_config {
 #define MC_ERR_REG_MIRI_CRI_ERR_1          BIT(23)
 #define MC_ERR_REG_SM_ERR                  BIT(31)
 #define MC_ERR_REG_ECC_ALL_SNG		   (BIT(2) | BIT(3) | BIT(4) | BIT(5) |\
-					    BIT(6) | BIT(7) | BIT(17) | BIT(19))
+					BIT(17) | BIT(19))
 #define MC_ERR_REG_ECC_ALL_DBL		   (BIT(10) | BIT(11) | BIT(12) |\
-					    BIT(13) | BIT(14) | BIT(15) |\
-					    BIT(18) | BIT(20))
+					BIT(13) | BIT(18) | BIT(20))
 	u64 mc_err_mask;
 	u64 mc_err_alarm;
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index afef6c0..2be0a0f 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -32,12 +32,12 @@
  * rx_ring_sz: This defines the number of receive blocks each ring can have.
  *     This is also an array of size 8.
  * rx_ring_mode: This defines the operation mode of all 8 rings. The valid
- *		values are 1, 2 and 3.
+ *		values are 1, 2.
  * tx_fifo_num: This defines the number of Tx FIFOs thats used int the driver.
  * tx_fifo_len: This too is an array of 8. Each element defines the number of
  * Tx descriptors that can be associated with each corresponding FIFO.
  * intr_type: This defines the type of interrupt. The values can be 0(INTA),
- *     1(MSI), 2(MSI_X). Default value is '0(INTA)'
+ *     2(MSI_X). Default value is '0(INTA)'
  * lro: Specifies whether to enable Large Receive Offload (LRO) or not.
  *     Possible values '1' for enable '0' for disable. Default is '0'
  * lro_max_pkts: This parameter defines maximum number of packets can be
@@ -84,14 +84,14 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.23.1"
+#define DRV_VERSION "2.0.25.1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
 static char s2io_driver_version[] = DRV_VERSION;
 
-static int rxd_size[4] = {32,48,48,64};
-static int rxd_count[4] = {127,85,85,63};
+static int rxd_size[2] = {32,48};
+static int rxd_count[2] = {127,85};
 
 static inline int RXD_IS_UP2DT(struct RxD_t *rxdp)
 {
@@ -282,6 +282,7 @@ static char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
 	("lro_flush_due_to_max_pkts"),
 	("lro_avg_aggr_pkts"),
 	("mem_alloc_fail_cnt"),
+	("pci_map_fail_cnt"),
 	("watchdog_timer_cnt"),
 	("mem_allocated"),
 	("mem_freed"),
@@ -426,7 +427,7 @@ S2IO_PARM_INT(bimodal, 0);
 S2IO_PARM_INT(l3l4hdr_size, 128);
 /* Frequency of Rx desc syncs expressed as power of 2 */
 S2IO_PARM_INT(rxsync_frequency, 3);
-/* Interrupt type. Values can be 0(INTA), 1(MSI), 2(MSI_X) */
+/* Interrupt type. Values can be 0(INTA), 2(MSI_X) */
 S2IO_PARM_INT(intr_type, 0);
 /* Large receive offload feature */
 S2IO_PARM_INT(lro, 0);
@@ -701,7 +702,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 			    (u64) tmp_p_addr_next;
 		}
 	}
-	if (nic->rxd_mode >= RXD_MODE_3A) {
+	if (nic->rxd_mode == RXD_MODE_3B) {
 		/*
 		 * Allocation of Storages for buffer addresses in 2BUFF mode
 		 * and the buffers as well.
@@ -870,7 +871,7 @@ static void free_shared_mem(struct s2io_nic *nic)
 		}
 	}
 
-	if (nic->rxd_mode >= RXD_MODE_3A) {
+	if (nic->rxd_mode == RXD_MODE_3B) {
 		/* Freeing buffer storage addresses in 2BUFF mode. */
 		for (i = 0; i < config->rx_ring_num; i++) {
 			blk_cnt = config->rx_cfg[i].num_rxd /
@@ -2233,44 +2234,6 @@ static void stop_nic(struct s2io_nic *nic)
 	writeq(val64, &bar0->adapter_control);
 }
 
-static int fill_rxd_3buf(struct s2io_nic *nic, struct RxD_t *rxdp, struct \
-				sk_buff *skb)
-{
-	struct net_device *dev = nic->dev;
-	struct sk_buff *frag_list;
-	void *tmp;
-
-	/* Buffer-1 receives L3/L4 headers */
-	((struct RxD3*)rxdp)->Buffer1_ptr = pci_map_single
-			(nic->pdev, skb->data, l3l4hdr_size + 4,
-			PCI_DMA_FROMDEVICE);
-
-	/* skb_shinfo(skb)->frag_list will have L4 data payload */
-	skb_shinfo(skb)->frag_list = dev_alloc_skb(dev->mtu + ALIGN_SIZE);
-	if (skb_shinfo(skb)->frag_list == NULL) {
-		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
-		DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n ", dev->name);
-		return -ENOMEM ;
-	}
-	frag_list = skb_shinfo(skb)->frag_list;
-	skb->truesize += frag_list->truesize;
-	nic->mac_control.stats_info->sw_stat.mem_allocated 
-		+= frag_list->truesize;
-	frag_list->next = NULL;
-	tmp = (void *)ALIGN((long)frag_list->data, ALIGN_SIZE + 1);
-	frag_list->data = tmp;
-	skb_reset_tail_pointer(frag_list);
-
-	/* Buffer-2 receives L4 data payload */
-	((struct RxD3*)rxdp)->Buffer2_ptr = pci_map_single(nic->pdev,
-				frag_list->data, dev->mtu,
-				PCI_DMA_FROMDEVICE);
-	rxdp->Control_2 |= SET_BUFFER1_SIZE_3(l3l4hdr_size + 4);
-	rxdp->Control_2 |= SET_BUFFER2_SIZE_3(dev->mtu);
-
-	return SUCCESS;
-}
-
 /**
  *  fill_rx_buffers - Allocates the Rx side skbs
  *  @nic:  device private variable
@@ -2307,6 +2270,9 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 	unsigned long flags;
 	struct RxD_t *first_rxdp = NULL;
 	u64 Buffer0_ptr = 0, Buffer1_ptr = 0;
+	struct RxD1 *rxdp1;
+	struct RxD3 *rxdp3;
+	struct swStat *stats = &nic->mac_control.stats_info->sw_stat;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -2359,7 +2325,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 			(block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
 		}
 		if ((rxdp->Control_1 & RXD_OWN_XENA) &&
-			((nic->rxd_mode >= RXD_MODE_3A) &&
+			((nic->rxd_mode == RXD_MODE_3B) &&
 				(rxdp->Control_2 & BIT(0)))) {
 			mac_control->rings[ring_no].rx_curr_put_info.
 					offset = off;
@@ -2370,10 +2336,8 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 				HEADER_802_2_SIZE + HEADER_SNAP_SIZE;
 		if (nic->rxd_mode == RXD_MODE_1)
 			size += NET_IP_ALIGN;
-		else if (nic->rxd_mode == RXD_MODE_3B)
-			size = dev->mtu + ALIGN_SIZE + BUF0_LEN + 4;
 		else
-			size = l3l4hdr_size + ALIGN_SIZE + BUF0_LEN + 4;
+			size = dev->mtu + ALIGN_SIZE + BUF0_LEN + 4;
 
 		/* allocate skb */
 		skb = dev_alloc_skb(size);
@@ -2392,33 +2356,35 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 			+= skb->truesize;
 		if (nic->rxd_mode == RXD_MODE_1) {
 			/* 1 buffer mode - normal operation mode */
+			rxdp1 = (struct RxD1*)rxdp;
 			memset(rxdp, 0, sizeof(struct RxD1));
 			skb_reserve(skb, NET_IP_ALIGN);
-			((struct RxD1*)rxdp)->Buffer0_ptr = pci_map_single
+			rxdp1->Buffer0_ptr = pci_map_single
 			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
 				PCI_DMA_FROMDEVICE);
+			if( (rxdp1->Buffer0_ptr == 0) ||
+				(rxdp1->Buffer0_ptr ==
+				DMA_ERROR_CODE))
+				goto pci_map_failed;
+
 			rxdp->Control_2 = 
 				SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
 
-		} else if (nic->rxd_mode >= RXD_MODE_3A) {
+		} else if (nic->rxd_mode == RXD_MODE_3B) {
 			/*
-			 * 2 or 3 buffer mode -
-			 * Both 2 buffer mode and 3 buffer mode provides 128
+			 * 2 buffer mode -
+			 * 2 buffer mode provides 128
 			 * byte aligned receive buffers.
-			 *
-			 * 3 buffer mode provides header separation where in
-			 * skb->data will have L3/L4 headers where as
-			 * skb_shinfo(skb)->frag_list will have the L4 data
-			 * payload
 			 */
 
+			rxdp3 = (struct RxD3*)rxdp;
 			/* save buffer pointers to avoid frequent dma mapping */
-			Buffer0_ptr = ((struct RxD3*)rxdp)->Buffer0_ptr;
-			Buffer1_ptr = ((struct RxD3*)rxdp)->Buffer1_ptr;
+			Buffer0_ptr = rxdp3->Buffer0_ptr;
+			Buffer1_ptr = rxdp3->Buffer1_ptr;
 			memset(rxdp, 0, sizeof(struct RxD3));
 			/* restore the buffer pointers for dma sync*/
-			((struct RxD3*)rxdp)->Buffer0_ptr = Buffer0_ptr;
-			((struct RxD3*)rxdp)->Buffer1_ptr = Buffer1_ptr;
+			rxdp3->Buffer0_ptr = Buffer0_ptr;
+			rxdp3->Buffer1_ptr = Buffer1_ptr;
 
 			ba = &mac_control->rings[ring_no].ba[block_no][off];
 			skb_reserve(skb, BUF0_LEN);
@@ -2428,14 +2394,18 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 			skb->data = (void *) (unsigned long)tmp;
 			skb_reset_tail_pointer(skb);
 
-			if (!(((struct RxD3*)rxdp)->Buffer0_ptr))
-				((struct RxD3*)rxdp)->Buffer0_ptr =
+			if (!(rxdp3->Buffer0_ptr))
+				rxdp3->Buffer0_ptr =
 				   pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
 					   PCI_DMA_FROMDEVICE);
 			else
 				pci_dma_sync_single_for_device(nic->pdev,
-				(dma_addr_t) ((struct RxD3*)rxdp)->Buffer0_ptr,
+				(dma_addr_t) rxdp3->Buffer0_ptr,
 				    BUF0_LEN, PCI_DMA_FROMDEVICE);
+			if( (rxdp3->Buffer0_ptr == 0) ||
+				(rxdp3->Buffer0_ptr == DMA_ERROR_CODE))
+				goto pci_map_failed;
+
 			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 			if (nic->rxd_mode == RXD_MODE_3B) {
 				/* Two buffer mode */
@@ -2444,33 +2414,30 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 				 * Buffer2 will have L3/L4 header plus
 				 * L4 payload
 				 */
-				((struct RxD3*)rxdp)->Buffer2_ptr = pci_map_single
+				rxdp3->Buffer2_ptr = pci_map_single
 				(nic->pdev, skb->data, dev->mtu + 4,
 						PCI_DMA_FROMDEVICE);
 
-				/* Buffer-1 will be dummy buffer. Not used */
-				if (!(((struct RxD3*)rxdp)->Buffer1_ptr)) {
-					((struct RxD3*)rxdp)->Buffer1_ptr =
+				if( (rxdp3->Buffer2_ptr == 0) ||
+					(rxdp3->Buffer2_ptr == DMA_ERROR_CODE))
+					goto pci_map_failed;
+
+				rxdp3->Buffer1_ptr =
 						pci_map_single(nic->pdev,
 						ba->ba_1, BUF1_LEN,
 						PCI_DMA_FROMDEVICE);
+				if( (rxdp3->Buffer1_ptr == 0) ||
+					(rxdp3->Buffer1_ptr == DMA_ERROR_CODE)) {
+					pci_unmap_single
+						(nic->pdev,
+						(dma_addr_t)skb->data,
+						dev->mtu + 4,
+						PCI_DMA_FROMDEVICE);
+					goto pci_map_failed;
 				}
 				rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
 				rxdp->Control_2 |= SET_BUFFER2_SIZE_3
 								(dev->mtu + 4);
-			} else {
-				/* 3 buffer mode */
-				if (fill_rxd_3buf(nic, rxdp, skb) == -ENOMEM) {
-					nic->mac_control.stats_info->sw_stat.\
-					mem_freed += skb->truesize;
-					dev_kfree_skb_irq(skb);
-					if (first_rxdp) {
-						wmb();
-						first_rxdp->Control_1 |=
-							RXD_OWN_XENA;
-					}
-					return -ENOMEM ;
-				}
 			}
 			rxdp->Control_2 |= BIT(0);
 		}
@@ -2505,6 +2472,11 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 	}
 
 	return SUCCESS;
+pci_map_failed:
+	stats->pci_map_fail_cnt++;
+	stats->mem_freed += skb->truesize;
+	dev_kfree_skb_irq(skb);
+	return -ENOMEM;
 }
 
 static void free_rxd_blk(struct s2io_nic *sp, int ring_no, int blk)
@@ -2515,6 +2487,8 @@ static void free_rxd_blk(struct s2io_nic *sp, int ring_no, int blk)
 	struct RxD_t *rxdp;
 	struct mac_info *mac_control;
 	struct buffAdd *ba;
+	struct RxD1 *rxdp1;
+	struct RxD3 *rxdp3;
 
 	mac_control = &sp->mac_control;
 	for (j = 0 ; j < rxd_count[sp->rxd_mode]; j++) {
@@ -2526,40 +2500,30 @@ static void free_rxd_blk(struct s2io_nic *sp, int ring_no, int blk)
 			continue;
 		}
 		if (sp->rxd_mode == RXD_MODE_1) {
+			rxdp1 = (struct RxD1*)rxdp;
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD1*)rxdp)->Buffer0_ptr,
-				 dev->mtu +
-				 HEADER_ETHERNET_II_802_3_SIZE
-				 + HEADER_802_2_SIZE +
-				 HEADER_SNAP_SIZE,
-				 PCI_DMA_FROMDEVICE);
+				rxdp1->Buffer0_ptr,
+				dev->mtu +
+				HEADER_ETHERNET_II_802_3_SIZE
+				+ HEADER_802_2_SIZE +
+				HEADER_SNAP_SIZE,
+				PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD1));
 		} else if(sp->rxd_mode == RXD_MODE_3B) {
+			rxdp3 = (struct RxD3*)rxdp;
 			ba = &mac_control->rings[ring_no].
 				ba[blk][j];
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer0_ptr,
-				 BUF0_LEN,
-				 PCI_DMA_FROMDEVICE);
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer1_ptr,
-				 BUF1_LEN,
-				 PCI_DMA_FROMDEVICE);
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer2_ptr,
-				 dev->mtu + 4,
-				 PCI_DMA_FROMDEVICE);
-			memset(rxdp, 0, sizeof(struct RxD3));
-		} else {
-			pci_unmap_single(sp->pdev, (dma_addr_t)
-				((struct RxD3*)rxdp)->Buffer0_ptr, BUF0_LEN,
+				rxdp3->Buffer0_ptr,
+				BUF0_LEN,
 				PCI_DMA_FROMDEVICE);
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				((struct RxD3*)rxdp)->Buffer1_ptr,
-				l3l4hdr_size + 4,
+				rxdp3->Buffer1_ptr,
+				BUF1_LEN,
 				PCI_DMA_FROMDEVICE);
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				((struct RxD3*)rxdp)->Buffer2_ptr, dev->mtu,
+				rxdp3->Buffer2_ptr,
+				dev->mtu + 4,
 				PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD3));
 		}
@@ -2756,6 +2720,8 @@ static void rx_intr_handler(struct ring_info *ring_data)
 	struct sk_buff *skb;
 	int pkt_cnt = 0;
 	int i;
+	struct RxD1* rxdp1;
+	struct RxD3* rxdp3;
 
 	spin_lock(&nic->rx_lock);
 	if (atomic_read(&nic->card_state) == CARD_DOWN) {
@@ -2796,32 +2762,23 @@ static void rx_intr_handler(struct ring_info *ring_data)
 			return;
 		}
 		if (nic->rxd_mode == RXD_MODE_1) {
+			rxdp1 = (struct RxD1*)rxdp;
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD1*)rxdp)->Buffer0_ptr,
-				 dev->mtu +
-				 HEADER_ETHERNET_II_802_3_SIZE +
-				 HEADER_802_2_SIZE +
-				 HEADER_SNAP_SIZE,
-				 PCI_DMA_FROMDEVICE);
+				rxdp1->Buffer0_ptr,
+				dev->mtu +
+				HEADER_ETHERNET_II_802_3_SIZE +
+				HEADER_802_2_SIZE +
+				HEADER_SNAP_SIZE,
+				PCI_DMA_FROMDEVICE);
 		} else if (nic->rxd_mode == RXD_MODE_3B) {
+			rxdp3 = (struct RxD3*)rxdp;
 			pci_dma_sync_single_for_cpu(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer0_ptr,
-				 BUF0_LEN, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer2_ptr,
-				 dev->mtu + 4,
-				 PCI_DMA_FROMDEVICE);
-		} else {
-			pci_dma_sync_single_for_cpu(nic->pdev, (dma_addr_t)
-					 ((struct RxD3*)rxdp)->Buffer0_ptr, BUF0_LEN,
-					 PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 ((struct RxD3*)rxdp)->Buffer1_ptr,
-					 l3l4hdr_size + 4,
-					 PCI_DMA_FROMDEVICE);
+				rxdp3->Buffer0_ptr,
+				BUF0_LEN, PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-					 ((struct RxD3*)rxdp)->Buffer2_ptr,
-					 dev->mtu, PCI_DMA_FROMDEVICE);
+				rxdp3->Buffer2_ptr,
+				dev->mtu + 4,
+				PCI_DMA_FROMDEVICE);
 		}
 		prefetch(skb->data);
 		rx_osm_handler(ring_data, rxdp);
@@ -3425,23 +3382,8 @@ static void s2io_reset(struct s2io_nic * sp)
 	/* Back up  the PCI-X CMD reg, dont want to lose MMRBC, OST settings */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER, &(pci_cmd));
 
-	if (sp->device_type == XFRAME_II_DEVICE) {
-		int ret;
-		ret = pci_set_power_state(sp->pdev, 3);
-		if (!ret)
-			ret = pci_set_power_state(sp->pdev, 0);
-		else {
-			DBG_PRINT(ERR_DBG,"%s PME based SW_Reset failed!\n",
-					__FUNCTION__);
-			goto old_way;
-		}
-		msleep(20);
-		goto new_way;
-	}
-old_way:
 	val64 = SW_RESET_ALL;
 	writeq(val64, &bar0->sw_reset);
-new_way:
 	if (strstr(sp->product_name, "CX4")) {
 		msleep(750);
 	}
@@ -3731,56 +3673,6 @@ static void store_xmsi_data(struct s2io_nic *nic)
 	}
 }
 
-int s2io_enable_msi(struct s2io_nic *nic)
-{
-	struct XENA_dev_config __iomem *bar0 = nic->bar0;
-	u16 msi_ctrl, msg_val;
-	struct config_param *config = &nic->config;
-	struct net_device *dev = nic->dev;
-	u64 val64, tx_mat, rx_mat;
-	int i, err;
-
-	val64 = readq(&bar0->pic_control);
-	val64 &= ~BIT(1);
-	writeq(val64, &bar0->pic_control);
-
-	err = pci_enable_msi(nic->pdev);
-	if (err) {
-		DBG_PRINT(ERR_DBG, "%s: enabling MSI failed\n",
-			  nic->dev->name);
-		return err;
-	}
-
-	/*
-	 * Enable MSI and use MSI-1 in stead of the standard MSI-0
-	 * for interrupt handling.
-	 */
-	pci_read_config_word(nic->pdev, 0x4c, &msg_val);
-	msg_val ^= 0x1;
-	pci_write_config_word(nic->pdev, 0x4c, msg_val);
-	pci_read_config_word(nic->pdev, 0x4c, &msg_val);
-
-	pci_read_config_word(nic->pdev, 0x42, &msi_ctrl);
-	msi_ctrl |= 0x10;
-	pci_write_config_word(nic->pdev, 0x42, msi_ctrl);
-
-	/* program MSI-1 into all usable Tx_Mat and Rx_Mat fields */
-	tx_mat = readq(&bar0->tx_mat0_n[0]);
-	for (i=0; i<config->tx_fifo_num; i++) {
-		tx_mat |= TX_MAT_SET(i, 1);
-	}
-	writeq(tx_mat, &bar0->tx_mat0_n[0]);
-
-	rx_mat = readq(&bar0->rx_mat);
-	for (i=0; i<config->rx_ring_num; i++) {
-		rx_mat |= RX_MAT_SET(i, 1);
-	}
-	writeq(rx_mat, &bar0->rx_mat);
-
-	dev->irq = nic->pdev->irq;
-	return 0;
-}
-
 static int s2io_enable_msi_x(struct s2io_nic *nic)
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
@@ -4001,6 +3893,7 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct mac_info *mac_control;
 	struct config_param *config;
 	int offload_type;
+	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
 
 	mac_control = &sp->mac_control;
 	config = &sp->config;
@@ -4085,11 +3978,18 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 		txdp->Buffer_Pointer = pci_map_single(sp->pdev,
 					sp->ufo_in_band_v,
 					sizeof(u64), PCI_DMA_TODEVICE);
+		if((txdp->Buffer_Pointer == 0) ||
+			(txdp->Buffer_Pointer == DMA_ERROR_CODE))
+			goto pci_map_failed;
 		txdp++;
 	}
 
 	txdp->Buffer_Pointer = pci_map_single
 	    (sp->pdev, skb->data, frg_len, PCI_DMA_TODEVICE);
+	if((txdp->Buffer_Pointer == 0) ||
+		(txdp->Buffer_Pointer == DMA_ERROR_CODE))
+		goto pci_map_failed;
+
 	txdp->Host_Control = (unsigned long) skb;
 	txdp->Control_1 |= TXD_BUFFER0_SIZE(frg_len);
 	if (offload_type == SKB_GSO_UDP)
@@ -4146,6 +4046,13 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&sp->tx_lock, flags);
 
 	return 0;
+pci_map_failed:
+	stats->pci_map_fail_cnt++;
+	netif_stop_queue(dev);
+	stats->mem_freed += skb->truesize;
+	dev_kfree_skb(skb);
+	spin_unlock_irqrestore(&sp->tx_lock, flags);
+	return 0;
 }
 
 static void
@@ -4186,39 +4093,6 @@ static int s2io_chk_rx_buffers(struct s2io_nic *sp, int rng_n)
 	return 0;
 }
 
-static irqreturn_t s2io_msi_handle(int irq, void *dev_id)
-{
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct s2io_nic *sp = dev->priv;
-	int i;
-	struct mac_info *mac_control;
-	struct config_param *config;
-
-	atomic_inc(&sp->isr_cnt);
-	mac_control = &sp->mac_control;
-	config = &sp->config;
-	DBG_PRINT(INTR_DBG, "%s: MSI handler\n", __FUNCTION__);
-
-	/* If Intr is because of Rx Traffic */
-	for (i = 0; i < config->rx_ring_num; i++)
-		rx_intr_handler(&mac_control->rings[i]);
-
-	/* If Intr is because of Tx Traffic */
-	for (i = 0; i < config->tx_fifo_num; i++)
-		tx_intr_handler(&mac_control->fifos[i]);
-
-	/*
-	 * If the Rx buffer count is below the panic threshold then
-	 * reallocate the buffers from the interrupt handler itself,
-	 * else schedule a tasklet to reallocate the buffers.
-	 */
-	for (i = 0; i < config->rx_ring_num; i++)
-		s2io_chk_rx_buffers(sp, i);
-
-	atomic_dec(&sp->isr_cnt);
-	return IRQ_HANDLED;
-}
-
 static irqreturn_t s2io_msix_ring_handle(int irq, void *dev_id)
 {
 	struct ring_info *ring = (struct ring_info *)dev_id;
@@ -4927,19 +4801,17 @@ static void s2io_ethtool_gringparam(struct net_device *dev,
 		ering->rx_max_pending = MAX_RX_DESC_1;
 	else if (sp->rxd_mode == RXD_MODE_3B)
 		ering->rx_max_pending = MAX_RX_DESC_2;
-	else if (sp->rxd_mode == RXD_MODE_3A)
-		ering->rx_max_pending = MAX_RX_DESC_3;
 
 	ering->tx_max_pending = MAX_TX_DESC;
-	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) {
+	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) 
 		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
-	}
+	
 	DBG_PRINT(INFO_DBG,"\nmax txds : %d\n",sp->config.max_txds);
 	ering->tx_pending = tx_desc_count;
 	rx_desc_count = 0;
-	for (i = 0 ; i < sp->config.rx_ring_num ; i++) {
+	for (i = 0 ; i < sp->config.rx_ring_num ; i++) 
 		rx_desc_count += sp->config.rx_cfg[i].num_rxd;
-	}
+
 	ering->rx_pending = rx_desc_count;
 
 	ering->rx_mini_max_pending = 0;
@@ -5923,6 +5795,7 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 	else
 		tmp_stats[i++] = 0;
 	tmp_stats[i++] = stat_info->sw_stat.mem_alloc_fail_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.pci_map_fail_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.watchdog_timer_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.mem_allocated;
 	tmp_stats[i++] = stat_info->sw_stat.mem_freed;
@@ -6266,9 +6139,10 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 				u64 *temp2, int size)
 {
 	struct net_device *dev = sp->dev;
-	struct sk_buff *frag_list;
+	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
 
 	if ((sp->rxd_mode == RXD_MODE_1) && (rxdp->Host_Control == 0)) {
+		struct RxD1 *rxdp1 = (struct RxD1 *)rxdp;
 		/* allocate skb */
 		if (*skb) {
 			DBG_PRINT(INFO_DBG, "SKB is not NULL\n");
@@ -6277,7 +6151,7 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			 * using same mapped address for the Rxd
 			 * buffer pointer
 			 */
-			((struct RxD1*)rxdp)->Buffer0_ptr = *temp0;
+			rxdp1->Buffer0_ptr = *temp0;
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
@@ -6294,18 +6168,23 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			 * such it will be used for next rxd whose
 			 * Host Control is NULL
 			 */
-			((struct RxD1*)rxdp)->Buffer0_ptr = *temp0 =
+			rxdp1->Buffer0_ptr = *temp0 =
 				pci_map_single( sp->pdev, (*skb)->data,
 					size - NET_IP_ALIGN,
 					PCI_DMA_FROMDEVICE);
+			if( (rxdp1->Buffer0_ptr == 0) ||
+				(rxdp1->Buffer0_ptr == DMA_ERROR_CODE)) {
+				goto memalloc_failed;
+			}
 			rxdp->Host_Control = (unsigned long) (*skb);
 		}
 	} else if ((sp->rxd_mode == RXD_MODE_3B) && (rxdp->Host_Control == 0)) {
+		struct RxD3 *rxdp3 = (struct RxD3 *)rxdp;
 		/* Two buffer Mode */
 		if (*skb) {
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2;
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0;
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1;
+			rxdp3->Buffer2_ptr = *temp2;
+			rxdp3->Buffer0_ptr = *temp0;
+			rxdp3->Buffer1_ptr = *temp1;
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
@@ -6318,73 +6197,47 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			}
 			sp->mac_control.stats_info->sw_stat.mem_allocated 
 				+= (*skb)->truesize;
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
+			rxdp3->Buffer2_ptr = *temp2 =
 				pci_map_single(sp->pdev, (*skb)->data,
 					       dev->mtu + 4,
 					       PCI_DMA_FROMDEVICE);
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
+			if( (rxdp3->Buffer2_ptr == 0) ||
+				(rxdp3->Buffer2_ptr == DMA_ERROR_CODE)) {
+				goto memalloc_failed;
+			}
+			rxdp3->Buffer0_ptr = *temp0 =
 				pci_map_single( sp->pdev, ba->ba_0, BUF0_LEN,
 						PCI_DMA_FROMDEVICE);
+			if( (rxdp3->Buffer0_ptr == 0) ||
+				(rxdp3->Buffer0_ptr == DMA_ERROR_CODE)) {
+				pci_unmap_single (sp->pdev,
+					(dma_addr_t)(*skb)->data,
+					dev->mtu + 4, PCI_DMA_FROMDEVICE);
+				goto memalloc_failed;
+			}
 			rxdp->Host_Control = (unsigned long) (*skb);
 
 			/* Buffer-1 will be dummy buffer not used */
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
+			rxdp3->Buffer1_ptr = *temp1 =
 				pci_map_single(sp->pdev, ba->ba_1, BUF1_LEN,
-					       PCI_DMA_FROMDEVICE);
-		}
-	} else if ((rxdp->Host_Control == 0)) {
-		/* Three buffer mode */
-		if (*skb) {
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0;
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1;
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2;
-		} else {
-			*skb = dev_alloc_skb(size);
-			if (!(*skb)) {
-				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
-				DBG_PRINT(INFO_DBG, "memory to allocate ");
-				DBG_PRINT(INFO_DBG, "3 buf mode SKBs\n");
-				sp->mac_control.stats_info->sw_stat. \
-					mem_alloc_fail_cnt++;
-				return -ENOMEM;
-			}
-			sp->mac_control.stats_info->sw_stat.mem_allocated 
-				+= (*skb)->truesize;
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
-				pci_map_single(sp->pdev, ba->ba_0, BUF0_LEN,
-					       PCI_DMA_FROMDEVICE);
-			/* Buffer-1 receives L3/L4 headers */
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
-				pci_map_single( sp->pdev, (*skb)->data,
-						l3l4hdr_size + 4,
 						PCI_DMA_FROMDEVICE);
-			/*
-			 * skb_shinfo(skb)->frag_list will have L4
-			 * data payload
-			 */
-			skb_shinfo(*skb)->frag_list = dev_alloc_skb(dev->mtu +
-								   ALIGN_SIZE);
-			if (skb_shinfo(*skb)->frag_list == NULL) {
-				DBG_PRINT(ERR_DBG, "%s: dev_alloc_skb \
-					  failed\n ", dev->name);
-				sp->mac_control.stats_info->sw_stat. \
-					mem_alloc_fail_cnt++;
-				return -ENOMEM ;
+			if( (rxdp3->Buffer1_ptr == 0) ||
+				(rxdp3->Buffer1_ptr == DMA_ERROR_CODE)) {
+				pci_unmap_single (sp->pdev,
+					(dma_addr_t)(*skb)->data,
+					dev->mtu + 4, PCI_DMA_FROMDEVICE);
+				goto memalloc_failed;
 			}
-			frag_list = skb_shinfo(*skb)->frag_list;
-			frag_list->next = NULL;
-			sp->mac_control.stats_info->sw_stat.mem_allocated 
-				+= frag_list->truesize;
-			/*
-			 * Buffer-2 receives L4 data payload
-			 */
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
-				pci_map_single( sp->pdev, frag_list->data,
-						dev->mtu, PCI_DMA_FROMDEVICE);
 		}
 	}
 	return 0;
+	memalloc_failed:
+		stats->pci_map_fail_cnt++;
+		stats->mem_freed += (*skb)->truesize;
+		dev_kfree_skb(*skb);
+		return -ENOMEM;
 }
+
 static void set_rxd_buffer_size(struct s2io_nic *sp, struct RxD_t *rxdp,
 				int size)
 {
@@ -6395,10 +6248,6 @@ static void set_rxd_buffer_size(struct s2io_nic *sp, struct RxD_t *rxdp,
 		rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 		rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
 		rxdp->Control_2 |= SET_BUFFER2_SIZE_3( dev->mtu + 4);
-	} else {
-		rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
-		rxdp->Control_2 |= SET_BUFFER1_SIZE_3(l3l4hdr_size + 4);
-		rxdp->Control_2 |= SET_BUFFER2_SIZE_3(dev->mtu);
 	}
 }
 
@@ -6420,8 +6269,6 @@ static  int rxd_owner_bit_reset(struct s2io_nic *sp)
 		size += NET_IP_ALIGN;
 	else if (sp->rxd_mode == RXD_MODE_3B)
 		size = dev->mtu + ALIGN_SIZE + BUF0_LEN + 4;
-	else
-		size = l3l4hdr_size + ALIGN_SIZE + BUF0_LEN + 4;
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		blk_cnt = config->rx_cfg[i].num_rxd /
@@ -6431,7 +6278,7 @@ static  int rxd_owner_bit_reset(struct s2io_nic *sp)
 			for (k = 0; k < rxd_count[sp->rxd_mode]; k++) {
 				rxdp = mac_control->rings[i].
 					rx_blocks[j].rxds[k].virt_addr;
-				if(sp->rxd_mode >= RXD_MODE_3A)
+				if(sp->rxd_mode == RXD_MODE_3B)
 					ba = &mac_control->rings[i].ba[j][k];
 				if (set_rxd_buffer_pointer(sp, rxdp, ba,
 						       &skb,(u64 *)&temp0_64,
@@ -6458,9 +6305,7 @@ static int s2io_add_isr(struct s2io_nic * sp)
 	struct net_device *dev = sp->dev;
 	int err = 0;
 
-	if (sp->intr_type == MSI)
-		ret = s2io_enable_msi(sp);
-	else if (sp->intr_type == MSI_X)
+	if (sp->intr_type == MSI_X)
 		ret = s2io_enable_msi_x(sp);
 	if (ret) {
 		DBG_PRINT(ERR_DBG, "%s: Defaulting to INTA\n", dev->name);
@@ -6471,16 +6316,6 @@ static int s2io_add_isr(struct s2io_nic * sp)
 	store_xmsi_data(sp);
 
 	/* After proper initialization of H/W, register ISR */
-	if (sp->intr_type == MSI) {
-		err = request_irq((int) sp->pdev->irq, s2io_msi_handle,
-			IRQF_SHARED, sp->name, dev);
-		if (err) {
-			pci_disable_msi(sp->pdev);
-			DBG_PRINT(ERR_DBG, "%s: MSI registration failed\n",
-				  dev->name);
-			return -1;
-		}
-	}
 	if (sp->intr_type == MSI_X) {
 		int i, msix_tx_cnt=0,msix_rx_cnt=0;
 
@@ -6567,14 +6402,6 @@ static void s2io_rem_isr(struct s2io_nic * sp)
 		pci_disable_msix(sp->pdev);
 	} else {
 		free_irq(sp->pdev->irq, dev);
-		if (sp->intr_type == MSI) {
-			u16 val;
-
-			pci_disable_msi(sp->pdev);
-			pci_read_config_word(sp->pdev, 0x4c, &val);
-			val ^= 0x1;
-			pci_write_config_word(sp->pdev, 0x4c, val);
-		}
 	}
 	/* Waiting till all Interrupt handlers are complete */
 	cnt = 0;
@@ -6907,6 +6734,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 	}
 
 	/* Updating statistics */
+	sp->stats.rx_packets++;
 	rxdp->Host_Control = 0;
 	if (sp->rxd_mode == RXD_MODE_1) {
 		int len = RXD_GET_BUFFER0_SIZE_1(rxdp->Control_2);
@@ -6914,7 +6742,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		sp->stats.rx_bytes += len;
 		skb_put(skb, len);
 
-	} else if (sp->rxd_mode >= RXD_MODE_3A) {
+	} else if (sp->rxd_mode == RXD_MODE_3B) {
 		int get_block = ring_data->rx_curr_get_info.block_index;
 		int get_off = ring_data->rx_curr_get_info.offset;
 		int buf0_len = RXD_GET_BUFFER0_SIZE_3(rxdp->Control_2);
@@ -6924,18 +6752,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		struct buffAdd *ba = &ring_data->ba[get_block][get_off];
 		sp->stats.rx_bytes += buf0_len + buf2_len;
 		memcpy(buff, ba->ba_0, buf0_len);
-
-		if (sp->rxd_mode == RXD_MODE_3A) {
-			int buf1_len = RXD_GET_BUFFER1_SIZE_3(rxdp->Control_2);
-
-			skb_put(skb, buf1_len);
-			skb->len += buf2_len;
-			skb->data_len += buf2_len;
-			skb_put(skb_shinfo(skb)->frag_list, buf2_len);
-			sp->stats.rx_bytes += buf1_len;
-
-		} else
-			skb_put(skb, buf2_len);
+		skb_put(skb, buf2_len);
 	}
 
 	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && ((!sp->lro) ||
@@ -7131,7 +6948,7 @@ static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type)
 		*dev_intr_type = INTA;
 	}
 #else
-	if (*dev_intr_type > MSI_X) {
+	if ((*dev_intr_type != INTA) && (*dev_intr_type != MSI_X)) {
 		DBG_PRINT(ERR_DBG, "s2io: Wrong intr_type requested. "
 			  "Defaulting to INTA\n");
 		*dev_intr_type = INTA;
@@ -7145,10 +6962,10 @@ static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type)
 		*dev_intr_type = INTA;
 	}
 
-	if (rx_ring_mode > 3) {
+	if ((rx_ring_mode != 1) && (rx_ring_mode != 2)) {
 		DBG_PRINT(ERR_DBG, "s2io: Requested ring mode not supported\n");
-		DBG_PRINT(ERR_DBG, "s2io: Defaulting to 3-buffer mode\n");
-		rx_ring_mode = 3;
+		DBG_PRINT(ERR_DBG, "s2io: Defaulting to 1-buffer mode\n");
+		rx_ring_mode = 1;
 	}
 	return SUCCESS;
 }
@@ -7240,28 +7057,10 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		pci_disable_device(pdev);
 		return -ENOMEM;
 	}
-	if (dev_intr_type != MSI_X) {
-		if (pci_request_regions(pdev, s2io_driver_name)) {
-			DBG_PRINT(ERR_DBG, "Request Regions failed\n");
-			pci_disable_device(pdev);
-			return -ENODEV;
-		}
-	}
-	else {
-		if (!(request_mem_region(pci_resource_start(pdev, 0),
-               	         pci_resource_len(pdev, 0), s2io_driver_name))) {
-			DBG_PRINT(ERR_DBG, "bar0 Request Regions failed\n");
-			pci_disable_device(pdev);
-			return -ENODEV;
-		}
-        	if (!(request_mem_region(pci_resource_start(pdev, 2),
-               	         pci_resource_len(pdev, 2), s2io_driver_name))) {
-			DBG_PRINT(ERR_DBG, "bar1 Request Regions failed\n");
-                	release_mem_region(pci_resource_start(pdev, 0),
-                                   pci_resource_len(pdev, 0));
-			pci_disable_device(pdev);
-			return -ENODEV;
-		}
+	if ((ret = pci_request_regions(pdev, s2io_driver_name))) {
+		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n", __FUNCTION__, ret);
+		pci_disable_device(pdev);
+		return -ENODEV;
 	}
 
 	dev = alloc_etherdev(sizeof(struct s2io_nic));
@@ -7288,8 +7087,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		sp->rxd_mode = RXD_MODE_1;
 	if (rx_ring_mode == 2)
 		sp->rxd_mode = RXD_MODE_3B;
-	if (rx_ring_mode == 3)
-		sp->rxd_mode = RXD_MODE_3A;
 
 	sp->intr_type = dev_intr_type;
 
@@ -7565,10 +7362,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		    DBG_PRINT(ERR_DBG, "%s: 2-Buffer receive mode enabled\n",
 						dev->name);
 		    break;
-		case RXD_MODE_3A:
-		    DBG_PRINT(ERR_DBG, "%s: 3-Buffer receive mode enabled\n",
-						dev->name);
-		    break;
 	}
 
 	if (napi)
@@ -7577,9 +7370,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		case INTA:
 		    DBG_PRINT(ERR_DBG, "%s: Interrupt type INTA\n", dev->name);
 		    break;
-		case MSI:
-		    DBG_PRINT(ERR_DBG, "%s: Interrupt type MSI\n", dev->name);
-		    break;
 		case MSI_X:
 		    DBG_PRINT(ERR_DBG, "%s: Interrupt type MSI-X\n", dev->name);
 		    break;
@@ -7619,14 +7409,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
       mem_alloc_failed:
 	free_shared_mem(sp);
 	pci_disable_device(pdev);
-	if (dev_intr_type != MSI_X)
-		pci_release_regions(pdev);
-	else {
-		release_mem_region(pci_resource_start(pdev, 0),
-			pci_resource_len(pdev, 0));
-		release_mem_region(pci_resource_start(pdev, 2),
-			pci_resource_len(pdev, 2));
-	}
+	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 
@@ -7661,14 +7444,7 @@ static void __devexit s2io_rem_nic(struct pci_dev *pdev)
 	free_shared_mem(sp);
 	iounmap(sp->bar0);
 	iounmap(sp->bar1);
-	if (sp->intr_type != MSI_X)
-		pci_release_regions(pdev);
-	else {
-		release_mem_region(pci_resource_start(pdev, 0),
-			pci_resource_len(pdev, 0));
-		release_mem_region(pci_resource_start(pdev, 2),
-			pci_resource_len(pdev, 2));
-	}
+	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 	pci_disable_device(pdev);
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 3887fe6..92983ee 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -74,6 +74,10 @@ static int debug_level = ERR_DBG;
 /* DEBUG message print. */
 #define DBG_PRINT(dbg_level, args...)  if(!(debug_level<dbg_level)) printk(args)
 
+#ifndef DMA_ERROR_CODE
+#define DMA_ERROR_CODE          (~(dma_addr_t)0x0)
+#endif
+
 /* Protocol assist features of the NIC */
 #define L3_CKSUM_OK 0xFFFF
 #define L4_CKSUM_OK 0xFFFF
@@ -97,6 +101,7 @@ struct swStat {
 	unsigned long long num_aggregations;
 	/* Other statistics */
 	unsigned long long mem_alloc_fail_cnt;
+	unsigned long long pci_map_fail_cnt;
 	unsigned long long watchdog_timer_cnt;
 	unsigned long long mem_allocated;
 	unsigned long long mem_freed;
@@ -575,8 +580,7 @@ struct RxD_block {
 #define SIZE_OF_BLOCK	4096
 
 #define RXD_MODE_1	0 /* One Buffer mode */
-#define RXD_MODE_3A	1 /* Three Buffer mode */
-#define RXD_MODE_3B	2 /* Two Buffer mode */
+#define RXD_MODE_3B	1 /* Two Buffer mode */
 
 /* Structure to hold virtual addresses of Buf0 and Buf1 in
  * 2buf mode. */
@@ -876,7 +880,6 @@ struct s2io_nic {
 	u16		lro_max_aggr_per_sess;
 
 #define INTA	0
-#define MSI	1
 #define MSI_X	2
 	u8 intr_type;
 
@@ -1020,8 +1023,6 @@ static int s2io_poll(struct net_device *dev, int *budget);
 static void s2io_init_pci(struct s2io_nic * sp);
 static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static void s2io_alarm_handle(unsigned long data);
-static int s2io_enable_msi(struct s2io_nic *nic);
-static irqreturn_t s2io_msi_handle(int irq, void *dev_id);
 static irqreturn_t
 s2io_msix_ring_handle(int irq, void *dev_id);
 static irqreturn_t
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index a05fd97..04cba6b 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -768,11 +768,13 @@ done:
 static void write_bulk_callback(struct urb *urb)
 {
 	pegasus_t *pegasus = urb->context;
-	struct net_device *net = pegasus->net;
+	struct net_device *net;
 
 	if (!pegasus)
 		return;
 
+	net = pegasus->net;
+
 	if (!netif_device_present(net) || !netif_running(net))
 		return;
 
