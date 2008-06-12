From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for .27
Date: Wed, 11 Jun 2008 22:30:46 -0400
Message-ID: <20080612023046.GA25958@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:53344 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752936AbYFLCas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 22:30:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


WARNING: my incoming email has been inaccessible for the past ~18 
hours, so if it appears I missed something recently, I probably did...
 ...(but have backed up on an equally inaccessible backup-MX machine)


Please pull from 'davem-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next

to receive the following updates:

 drivers/net/Kconfig            |   14 +-
 drivers/net/Makefile           |    2 +
 drivers/net/a2065.c            |    4 -
 drivers/net/atarilance.c       |    2 +-
 drivers/net/declance.c         |    4 -
 drivers/net/e1000e/netdev.c    |    5 +
 drivers/net/hplance.c          |    4 +-
 drivers/net/igb/igb_main.c     |    7 +-
 drivers/net/ixgbe/ixgbe_main.c |    7 +-
 drivers/net/lib8390.c          |    4 +
 drivers/net/mac8390.c          |    8 +-
 drivers/net/macb.c             |    6 +-
 drivers/net/macsonic.c         |   19 +-
 drivers/net/sh_eth.c           | 1174 +++++++++++++++++
 drivers/net/sh_eth.h           |  464 +++++++
 drivers/net/smc911x.c          |  423 +++----
 drivers/net/smc911x.h          |  495 ++++---
 drivers/net/sunlance.c         |    4 -
 drivers/net/usb/Kconfig        |   10 +
 drivers/net/usb/Makefile       |    1 +
 drivers/net/usb/hso.c          | 2836 ++++++++++++++++++++++++++++++++++++++++
 include/linux/smc911x.h        |   12 +
 22 files changed, 5017 insertions(+), 488 deletions(-)
 create mode 100644 drivers/net/sh_eth.c
 create mode 100644 drivers/net/sh_eth.h
 create mode 100644 drivers/net/usb/hso.c
 create mode 100644 include/linux/smc911x.h

Adrian Bunk (5):
      make drivers/net/atarilance.c:lance_addr_list[] static
      make hplance_{init,cleanup}_module() static
      drivers/net/mac8390.c: make functions static
      drivers/net/: remove write-only "last_dev"
      drivers/net/macsonic.c: make functions static

Greg Kroah-Hartman (1):
      HSO: add option hso driver

Jeff Kirsher (3):
      ixbge: allow vlan devices to use TSO and TCP CSUM offload
      igb: allow vlan devices to use TSO and TCP CSUM offload
      e1000e: allow VLAN devices to use TSO and TCP CSUM offload

Magnus Damm (5):
      smc911x: remove unused 8-bit I/O operations
      smc911x: fix 16-bit I/O operations
      smc911x: pass along private data and use iomem
      smc911x: introduce platform data flags
      smc911x: SuperH architecture support

Nobuhiro Iwamatsu (1):
      net: sh_eth: add support for Renesas SuperH Ethernet

Stephen Rothwell (1):
      [netdrvr] Fix 8390 build breakage

Sven Schnelle (1):
      macb: use random mac if stored address in EEPROM is invalid

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c537f53..40eb24d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -524,6 +524,18 @@ config STNIC
 
 	  If unsure, say N.
 
+config SH_ETH
+	tristate "Renesas SuperH Ethernet support"
+	depends on SUPERH && \
+		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712)
+	select CRC32
+	select MII
+	select MDIO_BITBANG
+	select PHYLIB
+	help
+	  Renesas SuperH Ethernet device driver.
+	  This driver support SH7710 and SH7712.
+
 config SUNLANCE
 	tristate "Sun LANCE support"
 	depends on SBUS
@@ -955,7 +967,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA || SH_MAGIC_PANEL_R2
+	depends on ARCH_PXA || SUPERH
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index dcbfe84..c96fe20 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -80,6 +80,7 @@ obj-$(CONFIG_VIA_RHINE) += via-rhine.o
 obj-$(CONFIG_VIA_VELOCITY) += via-velocity.o
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
+obj-$(CONFIG_SH_ETH) += sh_eth.o
 
 #
 # end link order section
@@ -236,6 +237,7 @@ obj-$(CONFIG_USB_CATC)          += usb/
 obj-$(CONFIG_USB_KAWETH)        += usb/
 obj-$(CONFIG_USB_PEGASUS)       += usb/
 obj-$(CONFIG_USB_RTL8150)       += usb/
+obj-$(CONFIG_USB_HSO)		+= usb/
 obj-$(CONFIG_USB_USBNET)        += usb/
 obj-$(CONFIG_USB_ZD1201)        += usb/
 
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index 6c5719a..9c08374 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -475,16 +475,12 @@ static irqreturn_t lance_interrupt (int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-struct net_device *last_dev;
-
 static int lance_open (struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	int ret;
 
-	last_dev = dev;
-
 	/* Stop the Lance */
 	ll->rap = LE_CSR0;
 	ll->rdp = LE_C0_STOP;
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 4cceaac..0860cc2 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -243,7 +243,7 @@ struct lance_private {
 
 /* Possible memory/IO addresses for probing */
 
-struct lance_addr {
+static struct lance_addr {
 	unsigned long	memaddr;
 	unsigned long	ioaddr;
 	int				slow_flag;
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 6b1e77c..3e35064 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -773,8 +773,6 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-struct net_device *last_dev = 0;
-
 static int lance_open(struct net_device *dev)
 {
 	volatile u16 *ib = (volatile u16 *)dev->mem_start;
@@ -782,8 +780,6 @@ static int lance_open(struct net_device *dev)
 	volatile struct lance_regs *ll = lp->ll;
 	int status = 0;
 
-	last_dev = dev;
-
 	/* Stop the Lance */
 	writereg(&ll->rap, LE_CSR0);
 	writereg(&ll->rdp, LE_C0_STOP);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index cab1835..ccb8ca2 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4343,6 +4343,11 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
 
+	netdev->vlan_features |= NETIF_F_TSO;
+	netdev->vlan_features |= NETIF_F_TSO6;
+	netdev->vlan_features |= NETIF_F_HW_CSUM;
+	netdev->vlan_features |= NETIF_F_SG;
+
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/hplance.c b/drivers/net/hplance.c
index be6e5bc..2e80263 100644
--- a/drivers/net/hplance.c
+++ b/drivers/net/hplance.c
@@ -220,12 +220,12 @@ static int hplance_close(struct net_device *dev)
         return 0;
 }
 
-int __init hplance_init_module(void)
+static int __init hplance_init_module(void)
 {
 	return dio_register_driver(&hplance_driver);
 }
 
-void __exit hplance_cleanup_module(void)
+static void __exit hplance_cleanup_module(void)
 {
         dio_unregister_driver(&hplance_driver);
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ae398f0..7b6b780 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -967,8 +967,13 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 			   NETIF_F_HW_VLAN_FILTER;
 
 	netdev->features |= NETIF_F_TSO;
-
 	netdev->features |= NETIF_F_TSO6;
+
+	netdev->vlan_features |= NETIF_F_TSO;
+	netdev->vlan_features |= NETIF_F_TSO6;
+	netdev->vlan_features |= NETIF_F_HW_CSUM;
+	netdev->vlan_features |= NETIF_F_SG;
+
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7b85922..0d37c90 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3518,8 +3518,13 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 			   NETIF_F_HW_VLAN_FILTER;
 
 	netdev->features |= NETIF_F_TSO;
-
 	netdev->features |= NETIF_F_TSO6;
+
+	netdev->vlan_features |= NETIF_F_TSO;
+	netdev->vlan_features |= NETIF_F_TSO6;
+	netdev->vlan_features |= NETIF_F_HW_CSUM;
+	netdev->vlan_features |= NETIF_F_SG;
+
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index ed49527..00d59ab 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -553,6 +553,8 @@ static void __ei_poll(struct net_device *dev)
 static void ei_tx_err(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
+	/* ei_local is used on some platforms via the EI_SHIFT macro */
+	struct ei_device *ei_local __maybe_unused = netdev_priv(dev);
 	unsigned char txsr = ei_inb_p(e8390_base+EN0_TSR);
 	unsigned char tx_was_aborted = txsr & (ENTSR_ABT+ENTSR_FU);
 
@@ -815,6 +817,8 @@ static void ei_rx_overrun(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	unsigned char was_txing, must_resend = 0;
+	/* ei_local is used on some platforms via the EI_SHIFT macro */
+	struct ei_device *ei_local __maybe_unused = netdev_priv(dev);
 
 	/*
 	 * Record whether a Tx was in progress and then issue the
diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index 9e70074..98e3eb2 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -117,8 +117,6 @@ enum mac8390_access {
 	ACCESS_16,
 };
 
-extern enum mac8390_type mac8390_ident(struct nubus_dev * dev);
-extern int mac8390_memsize(unsigned long membase);
 extern int mac8390_memtest(struct net_device * dev);
 static int mac8390_initdev(struct net_device * dev, struct nubus_dev * ndev,
 			   enum mac8390_type type);
@@ -163,7 +161,7 @@ static void slow_sane_block_output(struct net_device *dev, int count,
 static void word_memcpy_tocard(void *tp, const void *fp, int count);
 static void word_memcpy_fromcard(void *tp, const void *fp, int count);
 
-enum mac8390_type __init mac8390_ident(struct nubus_dev * dev)
+static enum mac8390_type __init mac8390_ident(struct nubus_dev *dev)
 {
 	switch (dev->dr_sw) {
 		case NUBUS_DRSW_3COM:
@@ -234,7 +232,7 @@ enum mac8390_type __init mac8390_ident(struct nubus_dev * dev)
 	return MAC8390_NONE;
 }
 
-enum mac8390_access __init mac8390_testio(volatile unsigned long membase)
+static enum mac8390_access __init mac8390_testio(volatile unsigned long membase)
 {
 	unsigned long outdata = 0xA5A0B5B0;
 	unsigned long indata =  0x00000000;
@@ -252,7 +250,7 @@ enum mac8390_access __init mac8390_testio(volatile unsigned long membase)
 	return ACCESS_UNKNOWN;
 }
 
-int __init mac8390_memsize(unsigned long membase)
+static int __init mac8390_memsize(unsigned long membase)
 {
 	unsigned long flags;
 	int i, j;
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 92dccd4..e346302 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -80,8 +80,12 @@ static void __init macb_get_hwaddr(struct macb *bp)
 	addr[4] = top & 0xff;
 	addr[5] = (top >> 8) & 0xff;
 
-	if (is_valid_ether_addr(addr))
+	if (is_valid_ether_addr(addr)) {
 		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
+	} else {
+		dev_info(&bp->pdev->dev, "invalid hw address, using random\n");
+		random_ether_addr(bp->dev->dev_addr);
+	}
 }
 
 static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
diff --git a/drivers/net/macsonic.c b/drivers/net/macsonic.c
index b267161..e64c208 100644
--- a/drivers/net/macsonic.c
+++ b/drivers/net/macsonic.c
@@ -83,9 +83,6 @@ static unsigned int sonic_debug = 1;
 
 static int sonic_version_printed;
 
-extern int mac_onboard_sonic_probe(struct net_device* dev);
-extern int mac_nubus_sonic_probe(struct net_device* dev);
-
 /* For onboard SONIC */
 #define ONBOARD_SONIC_REGISTERS	0x50F0A000
 #define ONBOARD_SONIC_PROM_BASE	0x50f08000
@@ -170,7 +167,7 @@ static int macsonic_close(struct net_device* dev)
 	return err;
 }
 
-int __init macsonic_init(struct net_device* dev)
+static int __init macsonic_init(struct net_device *dev)
 {
 	struct sonic_local* lp = netdev_priv(dev);
 
@@ -218,7 +215,7 @@ int __init macsonic_init(struct net_device* dev)
 	return 0;
 }
 
-int __init mac_onboard_sonic_ethernet_addr(struct net_device* dev)
+static int __init mac_onboard_sonic_ethernet_addr(struct net_device *dev)
 {
 	struct sonic_local *lp = netdev_priv(dev);
 	const int prom_addr = ONBOARD_SONIC_PROM_BASE;
@@ -284,7 +281,7 @@ int __init mac_onboard_sonic_ethernet_addr(struct net_device* dev)
 	} else return 0;
 }
 
-int __init mac_onboard_sonic_probe(struct net_device* dev)
+static int __init mac_onboard_sonic_probe(struct net_device *dev)
 {
 	/* Bwahahaha */
 	static int once_is_more_than_enough;
@@ -405,9 +402,9 @@ int __init mac_onboard_sonic_probe(struct net_device* dev)
 	return macsonic_init(dev);
 }
 
-int __init mac_nubus_sonic_ethernet_addr(struct net_device* dev,
-					 unsigned long prom_addr,
-					 int id)
+static int __init mac_nubus_sonic_ethernet_addr(struct net_device *dev,
+						unsigned long prom_addr,
+						int id)
 {
 	int i;
 	for(i = 0; i < 6; i++)
@@ -420,7 +417,7 @@ int __init mac_nubus_sonic_ethernet_addr(struct net_device* dev,
 	return 0;
 }
 
-int __init macsonic_ident(struct nubus_dev* ndev)
+static int __init macsonic_ident(struct nubus_dev *ndev)
 {
 	if (ndev->dr_hw == NUBUS_DRHW_ASANTE_LC &&
 	    ndev->dr_sw == NUBUS_DRSW_SONIC_LC)
@@ -445,7 +442,7 @@ int __init macsonic_ident(struct nubus_dev* ndev)
 	return -1;
 }
 
-int __init mac_nubus_sonic_probe(struct net_device* dev)
+static int __init mac_nubus_sonic_probe(struct net_device *dev)
 {
 	static int slots;
 	struct nubus_dev* ndev = NULL;
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
new file mode 100644
index 0000000..f64d987
--- /dev/null
+++ b/drivers/net/sh_eth.c
@@ -0,0 +1,1174 @@
+/*
+ *  SuperH Ethernet device driver
+ *
+ *  Copyright (C) 2006,2007 Nobuhiro Iwamatsu
+ *  Copyright (C) 2008 Renesas Solutions Corp.
+ *
+ *  This program is free software; you can redistribute it and/or modify it
+ *  under the terms and conditions of the GNU General Public License,
+ *  version 2, as published by the Free Software Foundation.
+ *
+ *  This program is distributed in the hope it will be useful, but WITHOUT
+ *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ *  more details.
+ *  You should have received a copy of the GNU General Public License along with
+ *  this program; if not, write to the Free Software Foundation, Inc.,
+ *  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ *  The full GNU General Public License is included in this distribution in
+ *  the file called "COPYING".
+ */
+
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/dma-mapping.h>
+#include <linux/etherdevice.h>
+#include <linux/delay.h>
+#include <linux/platform_device.h>
+#include <linux/mdio-bitbang.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/cache.h>
+#include <linux/io.h>
+
+#include "sh_eth.h"
+
+/*
+ * Program the hardware MAC address from dev->dev_addr.
+ */
+static void update_mac_address(struct net_device *ndev)
+{
+	u32 ioaddr = ndev->base_addr;
+
+	ctrl_outl((ndev->dev_addr[0] << 24) | (ndev->dev_addr[1] << 16) |
+		  (ndev->dev_addr[2] << 8) | (ndev->dev_addr[3]),
+		  ioaddr + MAHR);
+	ctrl_outl((ndev->dev_addr[4] << 8) | (ndev->dev_addr[5]),
+		  ioaddr + MALR);
+}
+
+/*
+ * Get MAC address from SuperH MAC address register
+ *
+ * SuperH's Ethernet device doesn't have 'ROM' to MAC address.
+ * This driver get MAC address that use by bootloader(U-boot or sh-ipl+g).
+ * When you want use this device, you must set MAC address in bootloader.
+ *
+ */
+static void read_mac_address(struct net_device *ndev)
+{
+	u32 ioaddr = ndev->base_addr;
+
+	ndev->dev_addr[0] = (ctrl_inl(ioaddr + MAHR) >> 24);
+	ndev->dev_addr[1] = (ctrl_inl(ioaddr + MAHR) >> 16) & 0xFF;
+	ndev->dev_addr[2] = (ctrl_inl(ioaddr + MAHR) >> 8) & 0xFF;
+	ndev->dev_addr[3] = (ctrl_inl(ioaddr + MAHR) & 0xFF);
+	ndev->dev_addr[4] = (ctrl_inl(ioaddr + MALR) >> 8) & 0xFF;
+	ndev->dev_addr[5] = (ctrl_inl(ioaddr + MALR) & 0xFF);
+}
+
+struct bb_info {
+	struct mdiobb_ctrl ctrl;
+	u32 addr;
+	u32 mmd_msk;/* MMD */
+	u32 mdo_msk;
+	u32 mdi_msk;
+	u32 mdc_msk;
+};
+
+/* PHY bit set */
+static void bb_set(u32 addr, u32 msk)
+{
+	ctrl_outl(ctrl_inl(addr) | msk, addr);
+}
+
+/* PHY bit clear */
+static void bb_clr(u32 addr, u32 msk)
+{
+	ctrl_outl((ctrl_inl(addr) & ~msk), addr);
+}
+
+/* PHY bit read */
+static int bb_read(u32 addr, u32 msk)
+{
+	return (ctrl_inl(addr) & msk) != 0;
+}
+
+/* Data I/O pin control */
+static void sh_mmd_ctrl(struct mdiobb_ctrl *ctrl, int bit)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+	if (bit)
+		bb_set(bitbang->addr, bitbang->mmd_msk);
+	else
+		bb_clr(bitbang->addr, bitbang->mmd_msk);
+}
+
+/* Set bit data*/
+static void sh_set_mdio(struct mdiobb_ctrl *ctrl, int bit)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+
+	if (bit)
+		bb_set(bitbang->addr, bitbang->mdo_msk);
+	else
+		bb_clr(bitbang->addr, bitbang->mdo_msk);
+}
+
+/* Get bit data*/
+static int sh_get_mdio(struct mdiobb_ctrl *ctrl)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+	return bb_read(bitbang->addr, bitbang->mdi_msk);
+}
+
+/* MDC pin control */
+static void sh_mdc_ctrl(struct mdiobb_ctrl *ctrl, int bit)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+
+	if (bit)
+		bb_set(bitbang->addr, bitbang->mdc_msk);
+	else
+		bb_clr(bitbang->addr, bitbang->mdc_msk);
+}
+
+/* mdio bus control struct */
+static struct mdiobb_ops bb_ops = {
+	.owner = THIS_MODULE,
+	.set_mdc = sh_mdc_ctrl,
+	.set_mdio_dir = sh_mmd_ctrl,
+	.set_mdio_data = sh_set_mdio,
+	.get_mdio_data = sh_get_mdio,
+};
+
+static void sh_eth_reset(struct net_device *ndev)
+{
+	u32 ioaddr = ndev->base_addr;
+
+	ctrl_outl(ctrl_inl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
+	mdelay(3);
+	ctrl_outl(ctrl_inl(ioaddr + EDMR) & ~EDMR_SRST, ioaddr + EDMR);
+}
+
+/* free skb and descriptor buffer */
+static void sh_eth_ring_free(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int i;
+
+	/* Free Rx skb ringbuffer */
+	if (mdp->rx_skbuff) {
+		for (i = 0; i < RX_RING_SIZE; i++) {
+			if (mdp->rx_skbuff[i])
+				dev_kfree_skb(mdp->rx_skbuff[i]);
+		}
+	}
+	kfree(mdp->rx_skbuff);
+
+	/* Free Tx skb ringbuffer */
+	if (mdp->tx_skbuff) {
+		for (i = 0; i < TX_RING_SIZE; i++) {
+			if (mdp->tx_skbuff[i])
+				dev_kfree_skb(mdp->tx_skbuff[i]);
+		}
+	}
+	kfree(mdp->tx_skbuff);
+}
+
+/* format skb and descriptor buffer */
+static void sh_eth_ring_format(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int i;
+	struct sk_buff *skb;
+	struct sh_eth_rxdesc *rxdesc = NULL;
+	struct sh_eth_txdesc *txdesc = NULL;
+	int rx_ringsize = sizeof(*rxdesc) * RX_RING_SIZE;
+	int tx_ringsize = sizeof(*txdesc) * TX_RING_SIZE;
+
+	mdp->cur_rx = mdp->cur_tx = 0;
+	mdp->dirty_rx = mdp->dirty_tx = 0;
+
+	memset(mdp->rx_ring, 0, rx_ringsize);
+
+	/* build Rx ring buffer */
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		/* skb */
+		mdp->rx_skbuff[i] = NULL;
+		skb = dev_alloc_skb(mdp->rx_buf_sz);
+		mdp->rx_skbuff[i] = skb;
+		if (skb == NULL)
+			break;
+		skb->dev = ndev;	/* Mark as being used by this device. */
+		skb_reserve(skb, RX_OFFSET);
+
+		/* RX descriptor */
+		rxdesc = &mdp->rx_ring[i];
+		rxdesc->addr = (u32)skb->data & ~0x3UL;
+		rxdesc->status = cpu_to_le32(RD_RACT | RD_RFP);
+
+		/* The size of the buffer is 16 byte boundary. */
+		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
+	}
+
+	mdp->dirty_rx = (u32) (i - RX_RING_SIZE);
+
+	/* Mark the last entry as wrapping the ring. */
+	rxdesc->status |= cpu_to_le32(RC_RDEL);
+
+	memset(mdp->tx_ring, 0, tx_ringsize);
+
+	/* build Tx ring buffer */
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		mdp->tx_skbuff[i] = NULL;
+		txdesc = &mdp->tx_ring[i];
+		txdesc->status = cpu_to_le32(TD_TFP);
+		txdesc->buffer_length = 0;
+	}
+
+	txdesc->status |= cpu_to_le32(TD_TDLE);
+}
+
+/* Get skb and descriptor buffer */
+static int sh_eth_ring_init(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int rx_ringsize, tx_ringsize, ret = 0;
+
+	/*
+	 * +26 gets the maximum ethernet encapsulation, +7 & ~7 because the
+	 * card needs room to do 8 byte alignment, +2 so we can reserve
+	 * the first 2 bytes, and +16 gets room for the status word from the
+	 * card.
+	 */
+	mdp->rx_buf_sz = (ndev->mtu <= 1492 ? PKT_BUF_SZ :
+			  (((ndev->mtu + 26 + 7) & ~7) + 2 + 16));
+
+	/* Allocate RX and TX skb rings */
+	mdp->rx_skbuff = kmalloc(sizeof(*mdp->rx_skbuff) * RX_RING_SIZE,
+				GFP_KERNEL);
+	if (!mdp->rx_skbuff) {
+		printk(KERN_ERR "%s: Cannot allocate Rx skb\n", ndev->name);
+		ret = -ENOMEM;
+		return ret;
+	}
+
+	mdp->tx_skbuff = kmalloc(sizeof(*mdp->tx_skbuff) * TX_RING_SIZE,
+				GFP_KERNEL);
+	if (!mdp->tx_skbuff) {
+		printk(KERN_ERR "%s: Cannot allocate Tx skb\n", ndev->name);
+		ret = -ENOMEM;
+		goto skb_ring_free;
+	}
+
+	/* Allocate all Rx descriptors. */
+	rx_ringsize = sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
+	mdp->rx_ring = dma_alloc_coherent(NULL, rx_ringsize, &mdp->rx_desc_dma,
+			GFP_KERNEL);
+
+	if (!mdp->rx_ring) {
+		printk(KERN_ERR "%s: Cannot allocate Rx Ring (size %d bytes)\n",
+			ndev->name, rx_ringsize);
+		ret = -ENOMEM;
+		goto desc_ring_free;
+	}
+
+	mdp->dirty_rx = 0;
+
+	/* Allocate all Tx descriptors. */
+	tx_ringsize = sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
+	mdp->tx_ring = dma_alloc_coherent(NULL, tx_ringsize, &mdp->tx_desc_dma,
+			GFP_KERNEL);
+	if (!mdp->tx_ring) {
+		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
+			ndev->name, tx_ringsize);
+		ret = -ENOMEM;
+		goto desc_ring_free;
+	}
+	return ret;
+
+desc_ring_free:
+	/* free DMA buffer */
+	dma_free_coherent(NULL, rx_ringsize, mdp->rx_ring, mdp->rx_desc_dma);
+
+skb_ring_free:
+	/* Free Rx and Tx skb ring buffer */
+	sh_eth_ring_free(ndev);
+
+	return ret;
+}
+
+static int sh_eth_dev_init(struct net_device *ndev)
+{
+	int ret = 0;
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+	u_int32_t rx_int_var, tx_int_var;
+	u32 val;
+
+	/* Soft Reset */
+	sh_eth_reset(ndev);
+
+	ctrl_outl(RPADIR_PADS1, ioaddr + RPADIR);	/* SH7712-DMA-RX-PAD2 */
+
+	/* all sh_eth int mask */
+	ctrl_outl(0, ioaddr + EESIPR);
+
+	/* FIFO size set */
+	ctrl_outl(0, ioaddr + EDMR);	/* Endian change */
+
+	ctrl_outl((FIFO_SIZE_T | FIFO_SIZE_R), ioaddr + FDR);
+	ctrl_outl(0, ioaddr + TFTR);
+
+	ctrl_outl(RMCR_RST, ioaddr + RMCR);
+
+	rx_int_var = mdp->rx_int_var = DESC_I_RINT8 | DESC_I_RINT5;
+	tx_int_var = mdp->tx_int_var = DESC_I_TINT2;
+	ctrl_outl(rx_int_var | tx_int_var, ioaddr + TRSCER);
+
+	ctrl_outl((FIFO_F_D_RFF | FIFO_F_D_RFD), ioaddr + FCFTR);
+	ctrl_outl(0, ioaddr + TRIMD);
+
+	/* Descriptor format */
+	sh_eth_ring_format(ndev);
+
+	ctrl_outl((u32)mdp->rx_ring, ioaddr + RDLAR);
+	ctrl_outl((u32)mdp->tx_ring, ioaddr + TDLAR);
+
+	ctrl_outl(ctrl_inl(ioaddr + EESR), ioaddr + EESR);
+	ctrl_outl((DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff), ioaddr + EESIPR);
+
+	/* PAUSE Prohibition */
+	val = (ctrl_inl(ioaddr + ECMR) & ECMR_DM) |
+		ECMR_ZPF | (mdp->duplex ? ECMR_DM : 0) | ECMR_TE | ECMR_RE;
+
+	ctrl_outl(val, ioaddr + ECMR);
+	ctrl_outl(ECSR_BRCRX | ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD |
+		  ECSIPR_MPDIP, ioaddr + ECSR);
+	ctrl_outl(ECSIPR_BRCRXIP | ECSIPR_PSRTOIP | ECSIPR_LCHNGIP |
+		  ECSIPR_ICDIP | ECSIPR_MPDIP, ioaddr + ECSIPR);
+
+	/* Set MAC address */
+	update_mac_address(ndev);
+
+	/* mask reset */
+#if defined(CONFIG_CPU_SUBTYPE_SH7710)
+	ctrl_outl(APR_AP, ioaddr + APR);
+	ctrl_outl(MPR_MP, ioaddr + MPR);
+	ctrl_outl(TPAUSER_UNLIMITED, ioaddr + TPAUSER);
+	ctrl_outl(BCFR_UNLIMITED, ioaddr + BCFR);
+#endif
+	/* Setting the Rx mode will start the Rx process. */
+	ctrl_outl(EDRRR_R, ioaddr + EDRRR);
+
+	netif_start_queue(ndev);
+
+	return ret;
+}
+
+/* free Tx skb function */
+static int sh_eth_txfree(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct sh_eth_txdesc *txdesc;
+	int freeNum = 0;
+	int entry = 0;
+
+	for (; mdp->cur_tx - mdp->dirty_tx > 0; mdp->dirty_tx++) {
+		entry = mdp->dirty_tx % TX_RING_SIZE;
+		txdesc = &mdp->tx_ring[entry];
+		if (txdesc->status & cpu_to_le32(TD_TACT))
+			break;
+		/* Free the original skb. */
+		if (mdp->tx_skbuff[entry]) {
+			dev_kfree_skb_irq(mdp->tx_skbuff[entry]);
+			mdp->tx_skbuff[entry] = NULL;
+			freeNum++;
+		}
+		txdesc->status = cpu_to_le32(TD_TFP);
+		if (entry >= TX_RING_SIZE - 1)
+			txdesc->status |= cpu_to_le32(TD_TDLE);
+
+		mdp->stats.tx_packets++;
+		mdp->stats.tx_bytes += txdesc->buffer_length;
+	}
+	return freeNum;
+}
+
+/* Packet receive function */
+static int sh_eth_rx(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct sh_eth_rxdesc *rxdesc;
+
+	int entry = mdp->cur_rx % RX_RING_SIZE;
+	int boguscnt = (mdp->dirty_rx + RX_RING_SIZE) - mdp->cur_rx;
+	struct sk_buff *skb;
+	u16 pkt_len = 0;
+	u32 desc_status;
+
+	rxdesc = &mdp->rx_ring[entry];
+	while (!(rxdesc->status & cpu_to_le32(RD_RACT))) {
+		desc_status = le32_to_cpu(rxdesc->status);
+		pkt_len = rxdesc->frame_length;
+
+		if (--boguscnt < 0)
+			break;
+
+		if (!(desc_status & RDFEND))
+			mdp->stats.rx_length_errors++;
+
+		if (desc_status & (RD_RFS1 | RD_RFS2 | RD_RFS3 | RD_RFS4 |
+				   RD_RFS5 | RD_RFS6 | RD_RFS10)) {
+			mdp->stats.rx_errors++;
+			if (desc_status & RD_RFS1)
+				mdp->stats.rx_crc_errors++;
+			if (desc_status & RD_RFS2)
+				mdp->stats.rx_frame_errors++;
+			if (desc_status & RD_RFS3)
+				mdp->stats.rx_length_errors++;
+			if (desc_status & RD_RFS4)
+				mdp->stats.rx_length_errors++;
+			if (desc_status & RD_RFS6)
+				mdp->stats.rx_missed_errors++;
+			if (desc_status & RD_RFS10)
+				mdp->stats.rx_over_errors++;
+		} else {
+			swaps((char *)(rxdesc->addr & ~0x3), pkt_len + 2);
+			skb = mdp->rx_skbuff[entry];
+			mdp->rx_skbuff[entry] = NULL;
+			skb_put(skb, pkt_len);
+			skb->protocol = eth_type_trans(skb, ndev);
+			netif_rx(skb);
+			ndev->last_rx = jiffies;
+			mdp->stats.rx_packets++;
+			mdp->stats.rx_bytes += pkt_len;
+		}
+		rxdesc->status |= cpu_to_le32(RD_RACT);
+		entry = (++mdp->cur_rx) % RX_RING_SIZE;
+	}
+
+	/* Refill the Rx ring buffers. */
+	for (; mdp->cur_rx - mdp->dirty_rx > 0; mdp->dirty_rx++) {
+		entry = mdp->dirty_rx % RX_RING_SIZE;
+		rxdesc = &mdp->rx_ring[entry];
+		if (mdp->rx_skbuff[entry] == NULL) {
+			skb = dev_alloc_skb(mdp->rx_buf_sz);
+			mdp->rx_skbuff[entry] = skb;
+			if (skb == NULL)
+				break;	/* Better luck next round. */
+			skb->dev = ndev;
+			skb_reserve(skb, RX_OFFSET);
+			rxdesc->addr = (u32)skb->data & ~0x3UL;
+		}
+		/* The size of the buffer is 16 byte boundary. */
+		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
+		if (entry >= RX_RING_SIZE - 1)
+			rxdesc->status |=
+			cpu_to_le32(RD_RACT | RD_RFP | RC_RDEL);
+		else
+			rxdesc->status |=
+			cpu_to_le32(RD_RACT | RD_RFP);
+	}
+
+	/* Restart Rx engine if stopped. */
+	/* If we don't need to check status, don't. -KDU */
+	ctrl_outl(EDRRR_R, ndev->base_addr + EDRRR);
+
+	return 0;
+}
+
+/* error control function */
+static void sh_eth_error(struct net_device *ndev, int intr_status)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+	u32 felic_stat;
+
+	if (intr_status & EESR_ECI) {
+		felic_stat = ctrl_inl(ioaddr + ECSR);
+		ctrl_outl(felic_stat, ioaddr + ECSR);	/* clear int */
+		if (felic_stat & ECSR_ICD)
+			mdp->stats.tx_carrier_errors++;
+		if (felic_stat & ECSR_LCHNG) {
+			/* Link Changed */
+			u32 link_stat = (ctrl_inl(ioaddr + PSR));
+			if (!(link_stat & PHY_ST_LINK)) {
+				/* Link Down : disable tx and rx */
+				ctrl_outl(ctrl_inl(ioaddr + ECMR) &
+					  ~(ECMR_RE | ECMR_TE), ioaddr + ECMR);
+			} else {
+				/* Link Up */
+				ctrl_outl(ctrl_inl(ioaddr + EESIPR) &
+					  ~DMAC_M_ECI, ioaddr + EESIPR);
+				/*clear int */
+				ctrl_outl(ctrl_inl(ioaddr + ECSR),
+					  ioaddr + ECSR);
+				ctrl_outl(ctrl_inl(ioaddr + EESIPR) |
+					  DMAC_M_ECI, ioaddr + EESIPR);
+				/* enable tx and rx */
+				ctrl_outl(ctrl_inl(ioaddr + ECMR) |
+					  (ECMR_RE | ECMR_TE), ioaddr + ECMR);
+			}
+		}
+	}
+
+	if (intr_status & EESR_TWB) {
+		/* Write buck end. unused write back interrupt */
+		if (intr_status & EESR_TABT)	/* Transmit Abort int */
+			mdp->stats.tx_aborted_errors++;
+	}
+
+	if (intr_status & EESR_RABT) {
+		/* Receive Abort int */
+		if (intr_status & EESR_RFRMER) {
+			/* Receive Frame Overflow int */
+			mdp->stats.rx_frame_errors++;
+			printk(KERN_ERR "Receive Frame Overflow\n");
+		}
+	}
+
+	if (intr_status & EESR_ADE) {
+		if (intr_status & EESR_TDE) {
+			if (intr_status & EESR_TFE)
+				mdp->stats.tx_fifo_errors++;
+		}
+	}
+
+	if (intr_status & EESR_RDE) {
+		/* Receive Descriptor Empty int */
+		mdp->stats.rx_over_errors++;
+
+		if (ctrl_inl(ioaddr + EDRRR) ^ EDRRR_R)
+			ctrl_outl(EDRRR_R, ioaddr + EDRRR);
+		printk(KERN_ERR "Receive Descriptor Empty\n");
+	}
+	if (intr_status & EESR_RFE) {
+		/* Receive FIFO Overflow int */
+		mdp->stats.rx_fifo_errors++;
+		printk(KERN_ERR "Receive FIFO Overflow\n");
+	}
+	if (intr_status &
+	    (EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE)) {
+		/* Tx error */
+		u32 edtrr = ctrl_inl(ndev->base_addr + EDTRR);
+		/* dmesg */
+		printk(KERN_ERR "%s:TX error. status=%8.8x cur_tx=%8.8x ",
+				ndev->name, intr_status, mdp->cur_tx);
+		printk(KERN_ERR "dirty_tx=%8.8x state=%8.8x EDTRR=%8.8x.\n",
+				mdp->dirty_tx, (u32) ndev->state, edtrr);
+		/* dirty buffer free */
+		sh_eth_txfree(ndev);
+
+		/* SH7712 BUG */
+		if (edtrr ^ EDTRR_TRNS) {
+			/* tx dma start */
+			ctrl_outl(EDTRR_TRNS, ndev->base_addr + EDTRR);
+		}
+		/* wakeup */
+		netif_wake_queue(ndev);
+	}
+}
+
+static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
+{
+	struct net_device *ndev = netdev;
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr, boguscnt = RX_RING_SIZE;
+	u32 intr_status = 0;
+
+	ioaddr = ndev->base_addr;
+	spin_lock(&mdp->lock);
+
+	intr_status = ctrl_inl(ioaddr + EESR);
+	/* Clear interrupt */
+	ctrl_outl(intr_status, ioaddr + EESR);
+
+	if (intr_status & (EESR_FRC | EESR_RINT8 |
+			   EESR_RINT5 | EESR_RINT4 | EESR_RINT3 | EESR_RINT2 |
+			   EESR_RINT1))
+		sh_eth_rx(ndev);
+	if (intr_status & (EESR_FTC |
+			   EESR_TINT4 | EESR_TINT3 | EESR_TINT2 | EESR_TINT1)) {
+
+		sh_eth_txfree(ndev);
+		netif_wake_queue(ndev);
+	}
+
+	if (intr_status & EESR_ERR_CHECK)
+		sh_eth_error(ndev, intr_status);
+
+	if (--boguscnt < 0) {
+		printk(KERN_WARNING
+		       "%s: Too much work at interrupt, status=0x%4.4x.\n",
+		       ndev->name, intr_status);
+	}
+
+	spin_unlock(&mdp->lock);
+
+	return IRQ_HANDLED;
+}
+
+static void sh_eth_timer(unsigned long data)
+{
+	struct net_device *ndev = (struct net_device *)data;
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	mod_timer(&mdp->timer, jiffies + (10 * HZ));
+}
+
+/* PHY state control function */
+static void sh_eth_adjust_link(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct phy_device *phydev = mdp->phydev;
+	u32 ioaddr = ndev->base_addr;
+	int new_state = 0;
+
+	if (phydev->link != PHY_DOWN) {
+		if (phydev->duplex != mdp->duplex) {
+			new_state = 1;
+			mdp->duplex = phydev->duplex;
+		}
+
+		if (phydev->speed != mdp->speed) {
+			new_state = 1;
+			mdp->speed = phydev->speed;
+		}
+		if (mdp->link == PHY_DOWN) {
+			ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_TXF)
+					| ECMR_DM, ioaddr + ECMR);
+			new_state = 1;
+			mdp->link = phydev->link;
+			netif_schedule(ndev);
+			netif_carrier_on(ndev);
+			netif_start_queue(ndev);
+		}
+	} else if (mdp->link) {
+		new_state = 1;
+		mdp->link = PHY_DOWN;
+		mdp->speed = 0;
+		mdp->duplex = -1;
+		netif_stop_queue(ndev);
+		netif_carrier_off(ndev);
+	}
+
+	if (new_state)
+		phy_print_status(phydev);
+}
+
+/* PHY init function */
+static int sh_eth_phy_init(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	char phy_id[BUS_ID_SIZE];
+	struct phy_device *phydev = NULL;
+
+	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT,
+		mdp->mii_bus->id , mdp->phy_id);
+
+	mdp->link = PHY_DOWN;
+	mdp->speed = 0;
+	mdp->duplex = -1;
+
+	/* Try connect to PHY */
+	phydev = phy_connect(ndev, phy_id, &sh_eth_adjust_link,
+				0, PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(phydev)) {
+		dev_err(&ndev->dev, "phy_connect failed\n");
+		return PTR_ERR(phydev);
+	}
+	dev_info(&ndev->dev, "attached phy %i to driver %s\n",
+	phydev->addr, phydev->drv->name);
+
+	mdp->phydev = phydev;
+
+	return 0;
+}
+
+/* PHY control start function */
+static int sh_eth_phy_start(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int ret;
+
+	ret = sh_eth_phy_init(ndev);
+	if (ret)
+		return ret;
+
+	/* reset phy - this also wakes it from PDOWN */
+	phy_write(mdp->phydev, MII_BMCR, BMCR_RESET);
+	phy_start(mdp->phydev);
+
+	return 0;
+}
+
+/* network device open function */
+static int sh_eth_open(struct net_device *ndev)
+{
+	int ret = 0;
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	ret = request_irq(ndev->irq, &sh_eth_interrupt, 0, ndev->name, ndev);
+	if (ret) {
+		printk(KERN_ERR "Can not assign IRQ number to %s\n", CARDNAME);
+		return ret;
+	}
+
+	/* Descriptor set */
+	ret = sh_eth_ring_init(ndev);
+	if (ret)
+		goto out_free_irq;
+
+	/* device init */
+	ret = sh_eth_dev_init(ndev);
+	if (ret)
+		goto out_free_irq;
+
+	/* PHY control start*/
+	ret = sh_eth_phy_start(ndev);
+	if (ret)
+		goto out_free_irq;
+
+	/* Set the timer to check for link beat. */
+	init_timer(&mdp->timer);
+	mdp->timer.expires = (jiffies + (24 * HZ)) / 10;/* 2.4 sec. */
+	setup_timer(&mdp->timer, sh_eth_timer, ndev);
+
+	return ret;
+
+out_free_irq:
+	free_irq(ndev->irq, ndev);
+	return ret;
+}
+
+/* Timeout function */
+static void sh_eth_tx_timeout(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+	struct sh_eth_rxdesc *rxdesc;
+	int i;
+
+	netif_stop_queue(ndev);
+
+	/* worning message out. */
+	printk(KERN_WARNING "%s: transmit timed out, status %8.8x,"
+	       " resetting...\n", ndev->name, (int)ctrl_inl(ioaddr + EESR));
+
+	/* tx_errors count up */
+	mdp->stats.tx_errors++;
+
+	/* timer off */
+	del_timer_sync(&mdp->timer);
+
+	/* Free all the skbuffs in the Rx queue. */
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		rxdesc = &mdp->rx_ring[i];
+		rxdesc->status = 0;
+		rxdesc->addr = 0xBADF00D0;
+		if (mdp->rx_skbuff[i])
+			dev_kfree_skb(mdp->rx_skbuff[i]);
+		mdp->rx_skbuff[i] = NULL;
+	}
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		if (mdp->tx_skbuff[i])
+			dev_kfree_skb(mdp->tx_skbuff[i]);
+		mdp->tx_skbuff[i] = NULL;
+	}
+
+	/* device init */
+	sh_eth_dev_init(ndev);
+
+	/* timer on */
+	mdp->timer.expires = (jiffies + (24 * HZ)) / 10;/* 2.4 sec. */
+	add_timer(&mdp->timer);
+}
+
+/* Packet transmit function */
+static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct sh_eth_txdesc *txdesc;
+	u32 entry;
+	int flags;
+
+	spin_lock_irqsave(&mdp->lock, flags);
+	if ((mdp->cur_tx - mdp->dirty_tx) >= (TX_RING_SIZE - 4)) {
+		if (!sh_eth_txfree(ndev)) {
+			netif_stop_queue(ndev);
+			spin_unlock_irqrestore(&mdp->lock, flags);
+			return 1;
+		}
+	}
+	spin_unlock_irqrestore(&mdp->lock, flags);
+
+	entry = mdp->cur_tx % TX_RING_SIZE;
+	mdp->tx_skbuff[entry] = skb;
+	txdesc = &mdp->tx_ring[entry];
+	txdesc->addr = (u32)(skb->data);
+	/* soft swap. */
+	swaps((char *)(txdesc->addr & ~0x3), skb->len + 2);
+	/* write back */
+	__flush_purge_region(skb->data, skb->len);
+	if (skb->len < ETHERSMALL)
+		txdesc->buffer_length = ETHERSMALL;
+	else
+		txdesc->buffer_length = skb->len;
+
+	if (entry >= TX_RING_SIZE - 1)
+		txdesc->status |= cpu_to_le32(TD_TACT | TD_TDLE);
+	else
+		txdesc->status |= cpu_to_le32(TD_TACT);
+
+	mdp->cur_tx++;
+
+	ctrl_outl(EDTRR_TRNS, ndev->base_addr + EDTRR);
+	ndev->trans_start = jiffies;
+
+	return 0;
+}
+
+/* device close function */
+static int sh_eth_close(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+	int ringsize;
+
+	netif_stop_queue(ndev);
+
+	/* Disable interrupts by clearing the interrupt mask. */
+	ctrl_outl(0x0000, ioaddr + EESIPR);
+
+	/* Stop the chip's Tx and Rx processes. */
+	ctrl_outl(0, ioaddr + EDTRR);
+	ctrl_outl(0, ioaddr + EDRRR);
+
+	/* PHY Disconnect */
+	if (mdp->phydev) {
+		phy_stop(mdp->phydev);
+		phy_disconnect(mdp->phydev);
+	}
+
+	free_irq(ndev->irq, ndev);
+
+	del_timer_sync(&mdp->timer);
+
+	/* Free all the skbuffs in the Rx queue. */
+	sh_eth_ring_free(ndev);
+
+	/* free DMA buffer */
+	ringsize = sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
+	dma_free_coherent(NULL, ringsize, mdp->rx_ring, mdp->rx_desc_dma);
+
+	/* free DMA buffer */
+	ringsize = sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
+	dma_free_coherent(NULL, ringsize, mdp->tx_ring, mdp->tx_desc_dma);
+
+	return 0;
+}
+
+static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+
+	mdp->stats.tx_dropped += ctrl_inl(ioaddr + TROCR);
+	ctrl_outl(0, ioaddr + TROCR);	/* (write clear) */
+	mdp->stats.collisions += ctrl_inl(ioaddr + CDCR);
+	ctrl_outl(0, ioaddr + CDCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + LCCR);
+	ctrl_outl(0, ioaddr + LCCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CNDCR);
+	ctrl_outl(0, ioaddr + CNDCR);	/* (write clear) */
+
+	return &mdp->stats;
+}
+
+/* ioctl to device funciotn*/
+static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq,
+				int cmd)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct phy_device *phydev = mdp->phydev;
+
+	if (!netif_running(ndev))
+		return -EINVAL;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
+}
+
+
+/* Multicast reception directions set */
+static void sh_eth_set_multicast_list(struct net_device *ndev)
+{
+	u32 ioaddr = ndev->base_addr;
+
+	if (ndev->flags & IFF_PROMISC) {
+		/* Set promiscuous. */
+		ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_MCT) | ECMR_PRM,
+			  ioaddr + ECMR);
+	} else {
+		/* Normal, unicast/broadcast-only mode. */
+		ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_PRM) | ECMR_MCT,
+			  ioaddr + ECMR);
+	}
+}
+
+/* SuperH's TSU register init function */
+static void sh_eth_tsu_init(u32 ioaddr)
+{
+	ctrl_outl(0, ioaddr + TSU_FWEN0);	/* Disable forward(0->1) */
+	ctrl_outl(0, ioaddr + TSU_FWEN1);	/* Disable forward(1->0) */
+	ctrl_outl(0, ioaddr + TSU_FCM);	/* forward fifo 3k-3k */
+	ctrl_outl(0xc, ioaddr + TSU_BSYSL0);
+	ctrl_outl(0xc, ioaddr + TSU_BSYSL1);
+	ctrl_outl(0, ioaddr + TSU_PRISL0);
+	ctrl_outl(0, ioaddr + TSU_PRISL1);
+	ctrl_outl(0, ioaddr + TSU_FWSL0);
+	ctrl_outl(0, ioaddr + TSU_FWSL1);
+	ctrl_outl(TSU_FWSLC_POSTENU | TSU_FWSLC_POSTENL, ioaddr + TSU_FWSLC);
+	ctrl_outl(0, ioaddr + TSU_QTAGM0);	/* Disable QTAG(0->1) */
+	ctrl_outl(0, ioaddr + TSU_QTAGM1);	/* Disable QTAG(1->0) */
+	ctrl_outl(0, ioaddr + TSU_FWSR);	/* all interrupt status clear */
+	ctrl_outl(0, ioaddr + TSU_FWINMK);	/* Disable all interrupt */
+	ctrl_outl(0, ioaddr + TSU_TEN);	/* Disable all CAM entry */
+	ctrl_outl(0, ioaddr + TSU_POST1);	/* Disable CAM entry [ 0- 7] */
+	ctrl_outl(0, ioaddr + TSU_POST2);	/* Disable CAM entry [ 8-15] */
+	ctrl_outl(0, ioaddr + TSU_POST3);	/* Disable CAM entry [16-23] */
+	ctrl_outl(0, ioaddr + TSU_POST4);	/* Disable CAM entry [24-31] */
+}
+
+/* MDIO bus release function */
+static int sh_mdio_release(struct net_device *ndev)
+{
+	struct mii_bus *bus = dev_get_drvdata(&ndev->dev);
+
+	/* unregister mdio bus */
+	mdiobus_unregister(bus);
+
+	/* remove mdio bus info from net_device */
+	dev_set_drvdata(&ndev->dev, NULL);
+
+	/* free bitbang info */
+	free_mdio_bitbang(bus);
+
+	return 0;
+}
+
+/* MDIO bus init function */
+static int sh_mdio_init(struct net_device *ndev, int id)
+{
+	int ret, i;
+	struct bb_info *bitbang;
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	/* create bit control struct for PHY */
+	bitbang = kzalloc(sizeof(struct bb_info), GFP_KERNEL);
+	if (!bitbang) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	/* bitbang init */
+	bitbang->addr = ndev->base_addr + PIR;
+	bitbang->mdi_msk = 0x08;
+	bitbang->mdo_msk = 0x04;
+	bitbang->mmd_msk = 0x02;/* MMD */
+	bitbang->mdc_msk = 0x01;
+	bitbang->ctrl.ops = &bb_ops;
+
+	/* MII contorller setting */
+	mdp->mii_bus = alloc_mdio_bitbang(&bitbang->ctrl);
+	if (!mdp->mii_bus) {
+		ret = -ENOMEM;
+		goto out_free_bitbang;
+	}
+
+	/* Hook up MII support for ethtool */
+	mdp->mii_bus->name = "sh_mii";
+	mdp->mii_bus->dev = &ndev->dev;
+	mdp->mii_bus->id = id;
+
+	/* PHY IRQ */
+	mdp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	if (!mdp->mii_bus->irq) {
+		ret = -ENOMEM;
+		goto out_free_bus;
+	}
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		mdp->mii_bus->irq[i] = PHY_POLL;
+
+	/* regist mdio bus */
+	ret = mdiobus_register(mdp->mii_bus);
+	if (ret)
+		goto out_free_irq;
+
+	dev_set_drvdata(&ndev->dev, mdp->mii_bus);
+
+	return 0;
+
+out_free_irq:
+	kfree(mdp->mii_bus->irq);
+
+out_free_bus:
+	kfree(mdp->mii_bus);
+
+out_free_bitbang:
+	kfree(bitbang);
+
+out:
+	return ret;
+}
+
+static int sh_eth_drv_probe(struct platform_device *pdev)
+{
+	int ret, i, devno = 0;
+	struct resource *res;
+	struct net_device *ndev = NULL;
+	struct sh_eth_private *mdp;
+
+	/* get base addr */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (unlikely(res == NULL)) {
+		dev_err(&pdev->dev, "invalid resource\n");
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
+	if (!ndev) {
+		printk(KERN_ERR "%s: could not allocate device.\n", CARDNAME);
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	/* The sh Ether-specific entries in the device structure. */
+	ndev->base_addr = res->start;
+	devno = pdev->id;
+	if (devno < 0)
+		devno = 0;
+
+	ndev->dma = -1;
+	ndev->irq = platform_get_irq(pdev, 0);
+	if (ndev->irq < 0) {
+		ret = -ENODEV;
+		goto out_release;
+	}
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	/* Fill in the fields of the device structure with ethernet values. */
+	ether_setup(ndev);
+
+	mdp = netdev_priv(ndev);
+	spin_lock_init(&mdp->lock);
+
+	/* get PHY ID */
+	mdp->phy_id = (int)pdev->dev.platform_data;
+
+	/* set function */
+	ndev->open = sh_eth_open;
+	ndev->hard_start_xmit = sh_eth_start_xmit;
+	ndev->stop = sh_eth_close;
+	ndev->get_stats = sh_eth_get_stats;
+	ndev->set_multicast_list = sh_eth_set_multicast_list;
+	ndev->do_ioctl = sh_eth_do_ioctl;
+	ndev->tx_timeout = sh_eth_tx_timeout;
+	ndev->watchdog_timeo = TX_TIMEOUT;
+
+	mdp->post_rx = POST_RX >> (devno << 1);
+	mdp->post_fw = POST_FW >> (devno << 1);
+
+	/* read and set MAC address */
+	read_mac_address(ndev);
+
+	/* First device only init */
+	if (!devno) {
+		/* reset device */
+		ctrl_outl(ARSTR_ARSTR, ndev->base_addr + ARSTR);
+		mdelay(1);
+
+		/* TSU init (Init only)*/
+		sh_eth_tsu_init(SH_TSU_ADDR);
+	}
+
+	/* network device register */
+	ret = register_netdev(ndev);
+	if (ret)
+		goto out_release;
+
+	/* mdio bus init */
+	ret = sh_mdio_init(ndev, pdev->id);
+	if (ret)
+		goto out_unregister;
+
+	/* pritnt device infomation */
+	printk(KERN_INFO "%s: %s at 0x%x, ",
+	       ndev->name, CARDNAME, (u32) ndev->base_addr);
+
+	for (i = 0; i < 5; i++)
+		printk(KERN_INFO "%2.2x:", ndev->dev_addr[i]);
+	printk(KERN_INFO "%2.2x, IRQ %d.\n", ndev->dev_addr[i], ndev->irq);
+
+	platform_set_drvdata(pdev, ndev);
+
+	return ret;
+
+out_unregister:
+	unregister_netdev(ndev);
+
+out_release:
+	/* net_dev free */
+	if (ndev)
+		free_netdev(ndev);
+
+out:
+	return ret;
+}
+
+static int sh_eth_drv_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+
+	sh_mdio_release(ndev);
+	unregister_netdev(ndev);
+	flush_scheduled_work();
+
+	free_netdev(ndev);
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+static struct platform_driver sh_eth_driver = {
+	.probe = sh_eth_drv_probe,
+	.remove = sh_eth_drv_remove,
+	.driver = {
+		   .name = CARDNAME,
+	},
+};
+
+static int __init sh_eth_init(void)
+{
+	return platform_driver_register(&sh_eth_driver);
+}
+
+static void __exit sh_eth_cleanup(void)
+{
+	platform_driver_unregister(&sh_eth_driver);
+}
+
+module_init(sh_eth_init);
+module_exit(sh_eth_cleanup);
+
+MODULE_AUTHOR("Nobuhiro Iwamatsu, Yoshihiro Shimoda");
+MODULE_DESCRIPTION("Renesas SuperH Ethernet driver");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
new file mode 100644
index 0000000..ca2db6b
--- /dev/null
+++ b/drivers/net/sh_eth.h
@@ -0,0 +1,464 @@
+/*
+ *  SuperH Ethernet device driver
+ *
+ *  Copyright (C) 2006-2008 Nobuhiro Iwamatsu
+ *  Copyright (C) 2008 Renesas Solutions Corp.
+ *
+ *  This program is free software; you can redistribute it and/or modify it
+ *  under the terms and conditions of the GNU General Public License,
+ *  version 2, as published by the Free Software Foundation.
+ *
+ *  This program is distributed in the hope it will be useful, but WITHOUT
+ *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ *  more details.
+ *  You should have received a copy of the GNU General Public License along with
+ *  this program; if not, write to the Free Software Foundation, Inc.,
+ *  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ *  The full GNU General Public License is included in this distribution in
+ *  the file called "COPYING".
+ */
+
+#ifndef __SH_ETH_H__
+#define __SH_ETH_H__
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/spinlock.h>
+#include <linux/workqueue.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#define CARDNAME	"sh-eth"
+#define TX_TIMEOUT	(5*HZ)
+
+#define TX_RING_SIZE	128	/* Tx ring size */
+#define RX_RING_SIZE	128	/* Rx ring size */
+#define RX_OFFSET		2	/* skb offset */
+#define ETHERSMALL		60
+#define PKT_BUF_SZ		1538
+
+/* Chip Base Address */
+#define SH_ETH0_BASE 0xA7000000
+#define SH_ETH1_BASE 0xA7000400
+#define SH_TSU_ADDR 0xA7000804
+
+/* Chip Registers */
+/* E-DMAC */
+#define EDMR	0x0000
+#define EDTRR	0x0004
+#define EDRRR	0x0008
+#define TDLAR	0x000C
+#define RDLAR	0x0010
+#define EESR	0x0014
+#define EESIPR	0x0018
+#define TRSCER	0x001C
+#define RMFCR	0x0020
+#define TFTR	0x0024
+#define FDR		0x0028
+#define RMCR	0x002C
+#define EDOCR	0x0030
+#define FCFTR	0x0034
+#define RPADIR	0x0038
+#define TRIMD	0x003C
+#define RBWAR	0x0040
+#define RDFAR	0x0044
+#define TBRAR	0x004C
+#define TDFAR	0x0050
+/* Ether Register */
+#define ECMR	0x0160
+#define ECSR	0x0164
+#define ECSIPR	0x0168
+#define PIR		0x016C
+#define MAHR	0x0170
+#define MALR	0x0174
+#define RFLR	0x0178
+#define PSR		0x017C
+#define TROCR	0x0180
+#define CDCR	0x0184
+#define LCCR	0x0188
+#define CNDCR	0x018C
+#define CEFCR	0x0194
+#define FRECR	0x0198
+#define TSFRCR	0x019C
+#define TLFRCR	0x01A0
+#define RFCR	0x01A4
+#define MAFCR	0x01A8
+#define IPGR	0x01B4
+#if defined(CONFIG_CPU_SUBTYPE_SH7710)
+#define APR		0x01B8
+#define MPR 	0x01BC
+#define TPAUSER 0x1C4
+#define BCFR	0x1CC
+#endif /* CONFIG_CPU_SH7710 */
+
+#define ARSTR	0x0800
+
+/* TSU */
+#define TSU_CTRST	0x004
+#define TSU_FWEN0	0x010
+#define TSU_FWEN1	0x014
+#define TSU_FCM		0x018
+#define TSU_BSYSL0	0x020
+#define TSU_BSYSL1	0x024
+#define TSU_PRISL0	0x028
+#define TSU_PRISL1	0x02C
+#define TSU_FWSL0	0x030
+#define TSU_FWSL1	0x034
+#define TSU_FWSLC	0x038
+#define TSU_QTAGM0	0x040
+#define TSU_QTAGM1	0x044
+#define TSU_ADQT0 	0x048
+#define TSU_ADQT1	0x04C
+#define TSU_FWSR	0x050
+#define TSU_FWINMK	0x054
+#define TSU_ADSBSY	0x060
+#define TSU_TEN		0x064
+#define TSU_POST1	0x070
+#define TSU_POST2	0x074
+#define TSU_POST3	0x078
+#define TSU_POST4	0x07C
+#define TXNLCR0		0x080
+#define TXALCR0		0x084
+#define RXNLCR0		0x088
+#define RXALCR0		0x08C
+#define FWNLCR0		0x090
+#define FWALCR0		0x094
+#define TXNLCR1		0x0A0
+#define TXALCR1		0x0A4
+#define RXNLCR1		0x0A8
+#define RXALCR1		0x0AC
+#define FWNLCR1		0x0B0
+#define FWALCR1		0x0B4
+
+#define TSU_ADRH0	0x0100
+#define TSU_ADRL0	0x0104
+#define TSU_ADRL31	0x01FC
+
+/* Register's bits */
+
+/* EDMR */
+enum DMAC_M_BIT {
+	EDMR_DL1 = 0x20, EDMR_DL0 = 0x10, EDMR_SRST = 0x01,
+};
+
+/* EDTRR */
+enum DMAC_T_BIT {
+	EDTRR_TRNS = 0x01,
+};
+
+/* EDRRR*/
+enum EDRRR_R_BIT {
+	EDRRR_R = 0x01,
+};
+
+/* TPAUSER */
+enum TPAUSER_BIT {
+	TPAUSER_TPAUSE = 0x0000ffff,
+	TPAUSER_UNLIMITED = 0,
+};
+
+/* BCFR */
+enum BCFR_BIT {
+	BCFR_RPAUSE = 0x0000ffff,
+	BCFR_UNLIMITED = 0,
+};
+
+/* PIR */
+enum PIR_BIT {
+	PIR_MDI = 0x08, PIR_MDO = 0x04, PIR_MMD = 0x02, PIR_MDC = 0x01,
+};
+
+/* PSR */
+enum PHY_STATUS_BIT { PHY_ST_LINK = 0x01, };
+
+/* EESR */
+enum EESR_BIT {
+	EESR_TWB = 0x40000000, EESR_TABT = 0x04000000,
+	EESR_RABT = 0x02000000, EESR_RFRMER = 0x01000000,
+	EESR_ADE = 0x00800000, EESR_ECI = 0x00400000,
+	EESR_FTC = 0x00200000, EESR_TDE = 0x00100000,
+	EESR_TFE = 0x00080000, EESR_FRC = 0x00040000,
+	EESR_RDE = 0x00020000, EESR_RFE = 0x00010000,
+	EESR_TINT4 = 0x00000800, EESR_TINT3 = 0x00000400,
+	EESR_TINT2 = 0x00000200, EESR_TINT1 = 0x00000100,
+	EESR_RINT8 = 0x00000080, EESR_RINT5 = 0x00000010,
+	EESR_RINT4 = 0x00000008, EESR_RINT3 = 0x00000004,
+	EESR_RINT2 = 0x00000002, EESR_RINT1 = 0x00000001,
+};
+
+#define EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE \
+		| EESR_RFRMER | EESR_ADE | EESR_TFE | EESR_TDE | EESR_ECI)
+
+/* EESIPR */
+enum DMAC_IM_BIT {
+	DMAC_M_TWB = 0x40000000, DMAC_M_TABT = 0x04000000,
+	DMAC_M_RABT = 0x02000000,
+	DMAC_M_RFRMER = 0x01000000, DMAC_M_ADF = 0x00800000,
+	DMAC_M_ECI = 0x00400000, DMAC_M_FTC = 0x00200000,
+	DMAC_M_TDE = 0x00100000, DMAC_M_TFE = 0x00080000,
+	DMAC_M_FRC = 0x00040000, DMAC_M_RDE = 0x00020000,
+	DMAC_M_RFE = 0x00010000, DMAC_M_TINT4 = 0x00000800,
+	DMAC_M_TINT3 = 0x00000400, DMAC_M_TINT2 = 0x00000200,
+	DMAC_M_TINT1 = 0x00000100, DMAC_M_RINT8 = 0x00000080,
+	DMAC_M_RINT5 = 0x00000010, DMAC_M_RINT4 = 0x00000008,
+	DMAC_M_RINT3 = 0x00000004, DMAC_M_RINT2 = 0x00000002,
+	DMAC_M_RINT1 = 0x00000001,
+};
+
+/* Receive descriptor bit */
+enum RD_STS_BIT {
+	RD_RACT = 0x80000000, RC_RDEL = 0x40000000,
+	RC_RFP1 = 0x20000000, RC_RFP0 = 0x10000000,
+	RD_RFE = 0x08000000, RD_RFS10 = 0x00000200,
+	RD_RFS9 = 0x00000100, RD_RFS8 = 0x00000080,
+	RD_RFS7 = 0x00000040, RD_RFS6 = 0x00000020,
+	RD_RFS5 = 0x00000010, RD_RFS4 = 0x00000008,
+	RD_RFS3 = 0x00000004, RD_RFS2 = 0x00000002,
+	RD_RFS1 = 0x00000001,
+};
+#define RDF1ST	RC_RFP1
+#define RDFEND	RC_RFP0
+#define RD_RFP	(RC_RFP1|RC_RFP0)
+
+/* FCFTR */
+enum FCFTR_BIT {
+	FCFTR_RFF2 = 0x00040000, FCFTR_RFF1 = 0x00020000,
+	FCFTR_RFF0 = 0x00010000, FCFTR_RFD2 = 0x00000004,
+	FCFTR_RFD1 = 0x00000002, FCFTR_RFD0 = 0x00000001,
+};
+#define FIFO_F_D_RFF	(FCFTR_RFF2|FCFTR_RFF1|FCFTR_RFF0)
+#define FIFO_F_D_RFD	(FCFTR_RFD2|FCFTR_RFD1|FCFTR_RFD0)
+
+/* Transfer descriptor bit */
+enum TD_STS_BIT {
+	TD_TACT = 0x80000000, TD_TDLE = 0x40000000, TD_TFP1 = 0x20000000,
+	TD_TFP0 = 0x10000000,
+};
+#define TDF1ST	TD_TFP1
+#define TDFEND	TD_TFP0
+#define TD_TFP	(TD_TFP1|TD_TFP0)
+
+/* RMCR */
+enum RECV_RST_BIT { RMCR_RST = 0x01, };
+/* ECMR */
+enum FELIC_MODE_BIT {
+	ECMR_ZPF = 0x00080000, ECMR_PFR = 0x00040000, ECMR_RXF = 0x00020000,
+	ECMR_TXF = 0x00010000, ECMR_MCT = 0x00002000, ECMR_PRCEF = 0x00001000,
+	ECMR_PMDE = 0x00000200, ECMR_RE = 0x00000040, ECMR_TE = 0x00000020,
+	ECMR_ILB = 0x00000008, ECMR_ELB = 0x00000004, ECMR_DM = 0x00000002,
+	ECMR_PRM = 0x00000001,
+};
+
+/* ECSR */
+enum ECSR_STATUS_BIT {
+	ECSR_BRCRX = 0x20, ECSR_PSRTO = 0x10, ECSR_LCHNG = 0x04,
+	ECSR_MPD = 0x02, ECSR_ICD = 0x01,
+};
+
+/* ECSIPR */
+enum ECSIPR_STATUS_MASK_BIT {
+	ECSIPR_BRCRXIP = 0x20, ECSIPR_PSRTOIP = 0x10, ECSIPR_LCHNGIP = 0x04,
+	ECSIPR_MPDIP = 0x02, ECSIPR_ICDIP = 0x01,
+};
+
+/* APR */
+enum APR_BIT {
+	APR_AP = 0x00000001,
+};
+
+/* MPR */
+enum MPR_BIT {
+	MPR_MP = 0x00000001,
+};
+
+/* TRSCER */
+enum DESC_I_BIT {
+	DESC_I_TINT4 = 0x0800, DESC_I_TINT3 = 0x0400, DESC_I_TINT2 = 0x0200,
+	DESC_I_TINT1 = 0x0100, DESC_I_RINT8 = 0x0080, DESC_I_RINT5 = 0x0010,
+	DESC_I_RINT4 = 0x0008, DESC_I_RINT3 = 0x0004, DESC_I_RINT2 = 0x0002,
+	DESC_I_RINT1 = 0x0001,
+};
+
+/* RPADIR */
+enum RPADIR_BIT {
+	RPADIR_PADS1 = 0x20000, RPADIR_PADS0 = 0x10000,
+	RPADIR_PADR = 0x0003f,
+};
+
+/* FDR */
+enum FIFO_SIZE_BIT {
+	FIFO_SIZE_T = 0x00000700, FIFO_SIZE_R = 0x00000007,
+};
+enum phy_offsets {
+	PHY_CTRL = 0, PHY_STAT = 1, PHY_IDT1 = 2, PHY_IDT2 = 3,
+	PHY_ANA = 4, PHY_ANL = 5, PHY_ANE = 6,
+	PHY_16 = 16,
+};
+
+/* PHY_CTRL */
+enum PHY_CTRL_BIT {
+	PHY_C_RESET = 0x8000, PHY_C_LOOPBK = 0x4000, PHY_C_SPEEDSL = 0x2000,
+	PHY_C_ANEGEN = 0x1000, PHY_C_PWRDN = 0x0800, PHY_C_ISO = 0x0400,
+	PHY_C_RANEG = 0x0200, PHY_C_DUPLEX = 0x0100, PHY_C_COLT = 0x0080,
+};
+#define DM9161_PHY_C_ANEGEN 0	/* auto nego special */
+
+/* PHY_STAT */
+enum PHY_STAT_BIT {
+	PHY_S_100T4 = 0x8000, PHY_S_100X_F = 0x4000, PHY_S_100X_H = 0x2000,
+	PHY_S_10T_F = 0x1000, PHY_S_10T_H = 0x0800, PHY_S_ANEGC = 0x0020,
+	PHY_S_RFAULT = 0x0010, PHY_S_ANEGA = 0x0008, PHY_S_LINK = 0x0004,
+	PHY_S_JAB = 0x0002, PHY_S_EXTD = 0x0001,
+};
+
+/* PHY_ANA */
+enum PHY_ANA_BIT {
+	PHY_A_NP = 0x8000, PHY_A_ACK = 0x4000, PHY_A_RF = 0x2000,
+	PHY_A_FCS = 0x0400, PHY_A_T4 = 0x0200, PHY_A_FDX = 0x0100,
+	PHY_A_HDX = 0x0080, PHY_A_10FDX = 0x0040, PHY_A_10HDX = 0x0020,
+	PHY_A_SEL = 0x001f,
+};
+/* PHY_ANL */
+enum PHY_ANL_BIT {
+	PHY_L_NP = 0x8000, PHY_L_ACK = 0x4000, PHY_L_RF = 0x2000,
+	PHY_L_FCS = 0x0400, PHY_L_T4 = 0x0200, PHY_L_FDX = 0x0100,
+	PHY_L_HDX = 0x0080, PHY_L_10FDX = 0x0040, PHY_L_10HDX = 0x0020,
+	PHY_L_SEL = 0x001f,
+};
+
+/* PHY_ANE */
+enum PHY_ANE_BIT {
+	PHY_E_PDF = 0x0010, PHY_E_LPNPA = 0x0008, PHY_E_NPA = 0x0004,
+	PHY_E_PRX = 0x0002, PHY_E_LPANEGA = 0x0001,
+};
+
+/* DM9161 */
+enum PHY_16_BIT {
+	PHY_16_BP4B45 = 0x8000, PHY_16_BPSCR = 0x4000, PHY_16_BPALIGN = 0x2000,
+	PHY_16_BP_ADPOK = 0x1000, PHY_16_Repeatmode = 0x0800,
+	PHY_16_TXselect = 0x0400,
+	PHY_16_Rsvd = 0x0200, PHY_16_RMIIEnable = 0x0100,
+	PHY_16_Force100LNK = 0x0080,
+	PHY_16_APDLED_CTL = 0x0040, PHY_16_COLLED_CTL = 0x0020,
+	PHY_16_RPDCTR_EN = 0x0010,
+	PHY_16_ResetStMch = 0x0008, PHY_16_PreamSupr = 0x0004,
+	PHY_16_Sleepmode = 0x0002,
+	PHY_16_RemoteLoopOut = 0x0001,
+};
+
+#define POST_RX		0x08
+#define POST_FW		0x04
+#define POST0_RX	(POST_RX)
+#define POST0_FW	(POST_FW)
+#define POST1_RX	(POST_RX >> 2)
+#define POST1_FW	(POST_FW >> 2)
+#define POST_ALL	(POST0_RX | POST0_FW | POST1_RX | POST1_FW)
+
+/* ARSTR */
+enum ARSTR_BIT { ARSTR_ARSTR = 0x00000001, };
+
+/* TSU_FWEN0 */
+enum TSU_FWEN0_BIT {
+	TSU_FWEN0_0 = 0x00000001,
+};
+
+/* TSU_ADSBSY */
+enum TSU_ADSBSY_BIT {
+	TSU_ADSBSY_0 = 0x00000001,
+};
+
+/* TSU_TEN */
+enum TSU_TEN_BIT {
+	TSU_TEN_0 = 0x80000000,
+};
+
+/* TSU_FWSL0 */
+enum TSU_FWSL0_BIT {
+	TSU_FWSL0_FW50 = 0x1000, TSU_FWSL0_FW40 = 0x0800,
+	TSU_FWSL0_FW30 = 0x0400, TSU_FWSL0_FW20 = 0x0200,
+	TSU_FWSL0_FW10 = 0x0100, TSU_FWSL0_RMSA0 = 0x0010,
+};
+
+/* TSU_FWSLC */
+enum TSU_FWSLC_BIT {
+	TSU_FWSLC_POSTENU = 0x2000, TSU_FWSLC_POSTENL = 0x1000,
+	TSU_FWSLC_CAMSEL03 = 0x0080, TSU_FWSLC_CAMSEL02 = 0x0040,
+	TSU_FWSLC_CAMSEL01 = 0x0020, TSU_FWSLC_CAMSEL00 = 0x0010,
+	TSU_FWSLC_CAMSEL13 = 0x0008, TSU_FWSLC_CAMSEL12 = 0x0004,
+	TSU_FWSLC_CAMSEL11 = 0x0002, TSU_FWSLC_CAMSEL10 = 0x0001,
+};
+
+/*
+ * The sh ether Tx buffer descriptors.
+ * This structure should be 20 bytes.
+ */
+struct sh_eth_txdesc {
+	u32 status;		/* TD0 */
+#if defined(CONFIG_CPU_LITTLE_ENDIAN)
+	u16 pad0;		/* TD1 */
+	u16 buffer_length;	/* TD1 */
+#else
+	u16 buffer_length;	/* TD1 */
+	u16 pad0;		/* TD1 */
+#endif
+	u32 addr;		/* TD2 */
+	u32 pad1;		/* padding data */
+};
+
+/*
+ * The sh ether Rx buffer descriptors.
+ * This structure should be 20 bytes.
+ */
+struct sh_eth_rxdesc {
+	u32 status;		/* RD0 */
+#if defined(CONFIG_CPU_LITTLE_ENDIAN)
+	u16 frame_length;	/* RD1 */
+	u16 buffer_length;	/* RD1 */
+#else
+	u16 buffer_length;	/* RD1 */
+	u16 frame_length;	/* RD1 */
+#endif
+	u32 addr;		/* RD2 */
+	u32 pad0;		/* padding data */
+};
+
+struct sh_eth_private {
+	dma_addr_t rx_desc_dma;
+	dma_addr_t tx_desc_dma;
+	struct sh_eth_rxdesc *rx_ring;
+	struct sh_eth_txdesc *tx_ring;
+	struct sk_buff **rx_skbuff;
+	struct sk_buff **tx_skbuff;
+	struct net_device_stats stats;
+	struct timer_list timer;
+	spinlock_t lock;
+	u32 cur_rx, dirty_rx;	/* Producer/consumer ring indices */
+	u32 cur_tx, dirty_tx;
+	u32 rx_buf_sz;		/* Based on MTU+slack. */
+	/* MII transceiver section. */
+	u32 phy_id;					/* PHY ID */
+	struct mii_bus *mii_bus;	/* MDIO bus control */
+	struct phy_device *phydev;	/* PHY device control */
+	enum phy_state link;
+	int msg_enable;
+	int speed;
+	int duplex;
+	u32 rx_int_var, tx_int_var;	/* interrupt control variables */
+	char post_rx;		/* POST receive */
+	char post_fw;		/* POST forward */
+	struct net_device_stats tsu_stats;	/* TSU forward status */
+};
+
+static void swaps(char *src, int len)
+{
+#ifdef __LITTLE_ENDIAN__
+	u32 *p = (u32 *)src;
+	u32 *maxp;
+	maxp = p + ((len + sizeof(u32) - 1) / sizeof(u32));
+
+	for (; p < maxp; p++)
+		*p = swab32(*p);
+#endif
+}
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 4e28002..fc605f2 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -106,56 +106,6 @@ MODULE_ALIAS("platform:smc911x");
  */
 #define POWER_DOWN		 1
 
-
-/* store this information for the driver.. */
-struct smc911x_local {
-	/*
-	 * If I have to wait until the DMA is finished and ready to reload a
-	 * packet, I will store the skbuff here. Then, the DMA will send it
-	 * out and free it.
-	 */
-	struct sk_buff *pending_tx_skb;
-
-	/* version/revision of the SMC911x chip */
-	u16 version;
-	u16 revision;
-
-	/* FIFO sizes */
-	int tx_fifo_kb;
-	int tx_fifo_size;
-	int rx_fifo_size;
-	int afc_cfg;
-
-	/* Contains the current active receive/phy mode */
-	int ctl_rfduplx;
-	int ctl_rspeed;
-
-	u32 msg_enable;
-	u32 phy_type;
-	struct mii_if_info mii;
-
-	/* work queue */
-	struct work_struct phy_configure;
-	int work_pending;
-
-	int tx_throttle;
-	spinlock_t lock;
-
-	struct net_device *netdev;
-
-#ifdef SMC_USE_DMA
-	/* DMA needs the physical address of the chip */
-	u_long physaddr;
-	int rxdma;
-	int txdma;
-	int rxdma_active;
-	int txdma_active;
-	struct sk_buff *current_rx_skb;
-	struct sk_buff *current_tx_skb;
-	struct device *dev;
-#endif
-};
-
 #if SMC_DEBUG > 0
 #define DBG(n, args...)				 \
 	do {					 \
@@ -203,24 +153,24 @@ static void PRINT_PKT(u_char *buf, int length)
 
 
 /* this enables an interrupt in the interrupt mask register */
-#define SMC_ENABLE_INT(x) do {				\
+#define SMC_ENABLE_INT(lp, x) do {			\
 	unsigned int  __mask;				\
 	unsigned long __flags;				\
 	spin_lock_irqsave(&lp->lock, __flags);		\
-	__mask = SMC_GET_INT_EN();			\
+	__mask = SMC_GET_INT_EN((lp));			\
 	__mask |= (x);					\
-	SMC_SET_INT_EN(__mask);				\
+	SMC_SET_INT_EN((lp), __mask);			\
 	spin_unlock_irqrestore(&lp->lock, __flags);	\
 } while (0)
 
 /* this disables an interrupt from the interrupt mask register */
-#define SMC_DISABLE_INT(x) do {				\
+#define SMC_DISABLE_INT(lp, x) do {			\
 	unsigned int  __mask;				\
 	unsigned long __flags;				\
 	spin_lock_irqsave(&lp->lock, __flags);		\
-	__mask = SMC_GET_INT_EN();			\
+	__mask = SMC_GET_INT_EN((lp));			\
 	__mask &= ~(x);					\
-	SMC_SET_INT_EN(__mask);				\
+	SMC_SET_INT_EN((lp), __mask);			\
 	spin_unlock_irqrestore(&lp->lock, __flags);	\
 } while (0)
 
@@ -229,7 +179,6 @@ static void PRINT_PKT(u_char *buf, int length)
  */
 static void smc911x_reset(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int reg, timeout=0, resets=1;
 	unsigned long flags;
@@ -237,13 +186,13 @@ static void smc911x_reset(struct net_device *dev)
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	/*	 Take out of PM setting first */
-	if ((SMC_GET_PMT_CTRL() & PMT_CTRL_READY_) == 0) {
+	if ((SMC_GET_PMT_CTRL(lp) & PMT_CTRL_READY_) == 0) {
 		/* Write to the bytetest will take out of powerdown */
-		SMC_SET_BYTE_TEST(0);
+		SMC_SET_BYTE_TEST(lp, 0);
 		timeout=10;
 		do {
 			udelay(10);
-			reg = SMC_GET_PMT_CTRL() & PMT_CTRL_READY_;
+			reg = SMC_GET_PMT_CTRL(lp) & PMT_CTRL_READY_;
 		} while (--timeout && !reg);
 		if (timeout == 0) {
 			PRINTK("%s: smc911x_reset timeout waiting for PM restore\n", dev->name);
@@ -253,15 +202,15 @@ static void smc911x_reset(struct net_device *dev)
 
 	/* Disable all interrupts */
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_SET_INT_EN(0);
+	SMC_SET_INT_EN(lp, 0);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	while (resets--) {
-		SMC_SET_HW_CFG(HW_CFG_SRST_);
+		SMC_SET_HW_CFG(lp, HW_CFG_SRST_);
 		timeout=10;
 		do {
 			udelay(10);
-			reg = SMC_GET_HW_CFG();
+			reg = SMC_GET_HW_CFG(lp);
 			/* If chip indicates reset timeout then try again */
 			if (reg & HW_CFG_SRST_TO_) {
 				PRINTK("%s: chip reset timeout, retrying...\n", dev->name);
@@ -277,7 +226,7 @@ static void smc911x_reset(struct net_device *dev)
 
 	/* make sure EEPROM has finished loading before setting GPIO_CFG */
 	timeout=1000;
-	while ( timeout-- && (SMC_GET_E2P_CMD() & E2P_CMD_EPC_BUSY_)) {
+	while ( timeout-- && (SMC_GET_E2P_CMD(lp) & E2P_CMD_EPC_BUSY_)) {
 		udelay(10);
 	}
 	if (timeout == 0){
@@ -286,24 +235,24 @@ static void smc911x_reset(struct net_device *dev)
 	}
 
 	/* Initialize interrupts */
-	SMC_SET_INT_EN(0);
-	SMC_ACK_INT(-1);
+	SMC_SET_INT_EN(lp, 0);
+	SMC_ACK_INT(lp, -1);
 
 	/* Reset the FIFO level and flow control settings */
-	SMC_SET_HW_CFG((lp->tx_fifo_kb & 0xF) << 16);
+	SMC_SET_HW_CFG(lp, (lp->tx_fifo_kb & 0xF) << 16);
 //TODO: Figure out what appropriate pause time is
-	SMC_SET_FLOW(FLOW_FCPT_ | FLOW_FCEN_);
-	SMC_SET_AFC_CFG(lp->afc_cfg);
+	SMC_SET_FLOW(lp, FLOW_FCPT_ | FLOW_FCEN_);
+	SMC_SET_AFC_CFG(lp, lp->afc_cfg);
 
 
 	/* Set to LED outputs */
-	SMC_SET_GPIO_CFG(0x70070000);
+	SMC_SET_GPIO_CFG(lp, 0x70070000);
 
 	/*
 	 * Deassert IRQ for 1*10us for edge type interrupts
 	 * and drive IRQ pin push-pull
 	 */
-	SMC_SET_IRQ_CFG( (1 << 24) | INT_CFG_IRQ_EN_ | INT_CFG_IRQ_TYPE_ );
+	SMC_SET_IRQ_CFG(lp, (1 << 24) | INT_CFG_IRQ_EN_ | INT_CFG_IRQ_TYPE_);
 
 	/* clear anything saved */
 	if (lp->pending_tx_skb != NULL) {
@@ -319,46 +268,45 @@ static void smc911x_reset(struct net_device *dev)
  */
 static void smc911x_enable(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned mask, cfg, cr;
 	unsigned long flags;
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
-	SMC_SET_MAC_ADDR(dev->dev_addr);
+	SMC_SET_MAC_ADDR(lp, dev->dev_addr);
 
 	/* Enable TX */
-	cfg = SMC_GET_HW_CFG();
+	cfg = SMC_GET_HW_CFG(lp);
 	cfg &= HW_CFG_TX_FIF_SZ_ | 0xFFF;
 	cfg |= HW_CFG_SF_;
-	SMC_SET_HW_CFG(cfg);
-	SMC_SET_FIFO_TDA(0xFF);
+	SMC_SET_HW_CFG(lp, cfg);
+	SMC_SET_FIFO_TDA(lp, 0xFF);
 	/* Update TX stats on every 64 packets received or every 1 sec */
-	SMC_SET_FIFO_TSL(64);
-	SMC_SET_GPT_CFG(GPT_CFG_TIMER_EN_ | 10000);
+	SMC_SET_FIFO_TSL(lp, 64);
+	SMC_SET_GPT_CFG(lp, GPT_CFG_TIMER_EN_ | 10000);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_GET_MAC_CR(cr);
+	SMC_GET_MAC_CR(lp, cr);
 	cr |= MAC_CR_TXEN_ | MAC_CR_HBDIS_;
-	SMC_SET_MAC_CR(cr);
-	SMC_SET_TX_CFG(TX_CFG_TX_ON_);
+	SMC_SET_MAC_CR(lp, cr);
+	SMC_SET_TX_CFG(lp, TX_CFG_TX_ON_);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* Add 2 byte padding to start of packets */
-	SMC_SET_RX_CFG((2<<8) & RX_CFG_RXDOFF_);
+	SMC_SET_RX_CFG(lp, (2<<8) & RX_CFG_RXDOFF_);
 
 	/* Turn on receiver and enable RX */
 	if (cr & MAC_CR_RXEN_)
 		DBG(SMC_DEBUG_RX, "%s: Receiver already enabled\n", dev->name);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_SET_MAC_CR( cr | MAC_CR_RXEN_ );
+	SMC_SET_MAC_CR(lp, cr | MAC_CR_RXEN_);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* Interrupt on every received packet */
-	SMC_SET_FIFO_RSA(0x01);
-	SMC_SET_FIFO_RSL(0x00);
+	SMC_SET_FIFO_RSA(lp, 0x01);
+	SMC_SET_FIFO_RSL(lp, 0x00);
 
 	/* now, enable interrupts */
 	mask = INT_EN_TDFA_EN_ | INT_EN_TSFL_EN_ | INT_EN_RSFL_EN_ |
@@ -369,7 +317,7 @@ static void smc911x_enable(struct net_device *dev)
 	else {
 		mask|=INT_EN_RDFO_EN_;
 	}
-	SMC_ENABLE_INT(mask);
+	SMC_ENABLE_INT(lp, mask);
 }
 
 /*
@@ -377,7 +325,6 @@ static void smc911x_enable(struct net_device *dev)
  */
 static void smc911x_shutdown(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned cr;
 	unsigned long flags;
@@ -385,35 +332,35 @@ static void smc911x_shutdown(struct net_device *dev)
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", CARDNAME, __FUNCTION__);
 
 	/* Disable IRQ's */
-	SMC_SET_INT_EN(0);
+	SMC_SET_INT_EN(lp, 0);
 
 	/* Turn of Rx and TX */
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_GET_MAC_CR(cr);
+	SMC_GET_MAC_CR(lp, cr);
 	cr &= ~(MAC_CR_TXEN_ | MAC_CR_RXEN_ | MAC_CR_HBDIS_);
-	SMC_SET_MAC_CR(cr);
-	SMC_SET_TX_CFG(TX_CFG_STOP_TX_);
+	SMC_SET_MAC_CR(lp, cr);
+	SMC_SET_TX_CFG(lp, TX_CFG_STOP_TX_);
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
 static inline void smc911x_drop_pkt(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int fifo_count, timeout, reg;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n", CARDNAME, __FUNCTION__);
-	fifo_count = SMC_GET_RX_FIFO_INF() & 0xFFFF;
+	fifo_count = SMC_GET_RX_FIFO_INF(lp) & 0xFFFF;
 	if (fifo_count <= 4) {
 		/* Manually dump the packet data */
 		while (fifo_count--)
-			SMC_GET_RX_FIFO();
+			SMC_GET_RX_FIFO(lp);
 	} else	 {
 		/* Fast forward through the bad packet */
-		SMC_SET_RX_DP_CTRL(RX_DP_CTRL_FFWD_BUSY_);
+		SMC_SET_RX_DP_CTRL(lp, RX_DP_CTRL_FFWD_BUSY_);
 		timeout=50;
 		do {
 			udelay(10);
-			reg = SMC_GET_RX_DP_CTRL() & RX_DP_CTRL_FFWD_BUSY_;
+			reg = SMC_GET_RX_DP_CTRL(lp) & RX_DP_CTRL_FFWD_BUSY_;
 		} while (--timeout && reg);
 		if (timeout == 0) {
 			PRINTK("%s: timeout waiting for RX fast forward\n", dev->name);
@@ -429,14 +376,14 @@ static inline void smc911x_drop_pkt(struct net_device *dev)
  */
 static inline void	 smc911x_rcv(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int pkt_len, status;
 	struct sk_buff *skb;
 	unsigned char *data;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n",
 		dev->name, __FUNCTION__);
-	status = SMC_GET_RX_STS_FIFO();
+	status = SMC_GET_RX_STS_FIFO(lp);
 	DBG(SMC_DEBUG_RX, "%s: Rx pkt len %d status 0x%08x \n",
 		dev->name, (status & 0x3fff0000) >> 16, status & 0xc000ffff);
 	pkt_len = (status & RX_STS_PKT_LEN_) >> 16;
@@ -473,24 +420,23 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 		skb_put(skb,pkt_len-4);
 #ifdef SMC_USE_DMA
 		{
-		struct smc911x_local *lp = netdev_priv(dev);
 		unsigned int fifo;
 		/* Lower the FIFO threshold if possible */
-		fifo = SMC_GET_FIFO_INT();
+		fifo = SMC_GET_FIFO_INT(lp);
 		if (fifo & 0xFF) fifo--;
 		DBG(SMC_DEBUG_RX, "%s: Setting RX stat FIFO threshold to %d\n",
 			dev->name, fifo & 0xff);
-		SMC_SET_FIFO_INT(fifo);
+		SMC_SET_FIFO_INT(lp, fifo);
 		/* Setup RX DMA */
-		SMC_SET_RX_CFG(RX_CFG_RX_END_ALGN16_ | ((2<<8) & RX_CFG_RXDOFF_));
+		SMC_SET_RX_CFG(lp, RX_CFG_RX_END_ALGN16_ | ((2<<8) & RX_CFG_RXDOFF_));
 		lp->rxdma_active = 1;
 		lp->current_rx_skb = skb;
-		SMC_PULL_DATA(data, (pkt_len+2+15) & ~15);
+		SMC_PULL_DATA(lp, data, (pkt_len+2+15) & ~15);
 		/* Packet processing deferred to DMA RX interrupt */
 		}
 #else
-		SMC_SET_RX_CFG(RX_CFG_RX_END_ALGN4_ | ((2<<8) & RX_CFG_RXDOFF_));
-		SMC_PULL_DATA(data, pkt_len+2+3);
+		SMC_SET_RX_CFG(lp, RX_CFG_RX_END_ALGN4_ | ((2<<8) & RX_CFG_RXDOFF_));
+		SMC_PULL_DATA(lp, data, pkt_len+2+3);
 
 		DBG(SMC_DEBUG_PKTS, "%s: Received packet\n", dev->name);
 		PRINT_PKT(data, ((pkt_len - 4) <= 64) ? pkt_len - 4 : 64);
@@ -509,7 +455,6 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 static void smc911x_hardware_send_pkt(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	struct sk_buff *skb;
 	unsigned int cmdA, cmdB, len;
 	unsigned char *buf;
@@ -542,8 +487,8 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
 
 	DBG(SMC_DEBUG_TX, "%s: TX PKT LENGTH 0x%04x (%d) BUF 0x%p CMDA 0x%08x CMDB 0x%08x\n",
 		 dev->name, len, len, buf, cmdA, cmdB);
-	SMC_SET_TX_FIFO(cmdA);
-	SMC_SET_TX_FIFO(cmdB);
+	SMC_SET_TX_FIFO(lp, cmdA);
+	SMC_SET_TX_FIFO(lp, cmdB);
 
 	DBG(SMC_DEBUG_PKTS, "%s: Transmitted packet\n", dev->name);
 	PRINT_PKT(buf, len <= 64 ? len : 64);
@@ -551,10 +496,10 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
 	/* Send pkt via PIO or DMA */
 #ifdef SMC_USE_DMA
 	lp->current_tx_skb = skb;
-	SMC_PUSH_DATA(buf, len);
+	SMC_PUSH_DATA(lp, buf, len);
 	/* DMA complete IRQ will free buffer and set jiffies */
 #else
-	SMC_PUSH_DATA(buf, len);
+	SMC_PUSH_DATA(lp, buf, len);
 	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 #endif
@@ -563,7 +508,7 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
 		netif_wake_queue(dev);
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
-	SMC_ENABLE_INT(INT_EN_TDFA_EN_ | INT_EN_TSFL_EN_);
+	SMC_ENABLE_INT(lp, INT_EN_TDFA_EN_ | INT_EN_TSFL_EN_);
 }
 
 /*
@@ -575,7 +520,6 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
 static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	unsigned int free;
 	unsigned long flags;
 
@@ -584,7 +528,7 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	BUG_ON(lp->pending_tx_skb != NULL);
 
-	free = SMC_GET_TX_FIFO_INF() & TX_FIFO_INF_TDFREE_;
+	free = SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TDFREE_;
 	DBG(SMC_DEBUG_TX, "%s: TX free space %d\n", dev->name, free);
 
 	/* Turn off the flow when running out of space in FIFO */
@@ -593,7 +537,7 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev->name, free);
 		spin_lock_irqsave(&lp->lock, flags);
 		/* Reenable when at least 1 packet of size MTU present */
-		SMC_SET_FIFO_TDA((SMC911X_TX_FIFO_LOW_THRESHOLD)/64);
+		SMC_SET_FIFO_TDA(lp, (SMC911X_TX_FIFO_LOW_THRESHOLD)/64);
 		lp->tx_throttle = 1;
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&lp->lock, flags);
@@ -648,7 +592,6 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
  */
 static void smc911x_tx(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int tx_status;
 
@@ -656,11 +599,11 @@ static void smc911x_tx(struct net_device *dev)
 		dev->name, __FUNCTION__);
 
 	/* Collect the TX status */
-	while (((SMC_GET_TX_FIFO_INF() & TX_FIFO_INF_TSUSED_) >> 16) != 0) {
+	while (((SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TSUSED_) >> 16) != 0) {
 		DBG(SMC_DEBUG_TX, "%s: Tx stat FIFO used 0x%04x\n",
 			dev->name,
-			(SMC_GET_TX_FIFO_INF() & TX_FIFO_INF_TSUSED_) >> 16);
-		tx_status = SMC_GET_TX_STS_FIFO();
+			(SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TSUSED_) >> 16);
+		tx_status = SMC_GET_TX_STS_FIFO(lp);
 		dev->stats.tx_packets++;
 		dev->stats.tx_bytes+=tx_status>>16;
 		DBG(SMC_DEBUG_TX, "%s: Tx FIFO tag 0x%04x status 0x%04x\n",
@@ -698,10 +641,10 @@ static void smc911x_tx(struct net_device *dev)
 
 static int smc911x_phy_read(struct net_device *dev, int phyaddr, int phyreg)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int phydata;
 
-	SMC_GET_MII(phyreg, phyaddr, phydata);
+	SMC_GET_MII(lp, phyreg, phyaddr, phydata);
 
 	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%02x, phydata=0x%04x\n",
 		__FUNCTION__, phyaddr, phyreg, phydata);
@@ -715,12 +658,12 @@ static int smc911x_phy_read(struct net_device *dev, int phyaddr, int phyreg)
 static void smc911x_phy_write(struct net_device *dev, int phyaddr, int phyreg,
 			int phydata)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 
 	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
 		__FUNCTION__, phyaddr, phyreg, phydata);
 
-	SMC_SET_MII(phyreg, phyaddr, phydata);
+	SMC_SET_MII(lp, phyreg, phyaddr, phydata);
 }
 
 /*
@@ -729,7 +672,6 @@ static void smc911x_phy_write(struct net_device *dev, int phyaddr, int phyreg,
  */
 static void smc911x_phy_detect(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	int phyaddr;
 	unsigned int cfg, id1, id2;
@@ -745,30 +687,30 @@ static void smc911x_phy_detect(struct net_device *dev)
 	switch(lp->version) {
 		case 0x115:
 		case 0x117:
-			cfg = SMC_GET_HW_CFG();
+			cfg = SMC_GET_HW_CFG(lp);
 			if (cfg & HW_CFG_EXT_PHY_DET_) {
 				cfg &= ~HW_CFG_PHY_CLK_SEL_;
 				cfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
-				SMC_SET_HW_CFG(cfg);
+				SMC_SET_HW_CFG(lp, cfg);
 				udelay(10); /* Wait for clocks to stop */
 
 				cfg |= HW_CFG_EXT_PHY_EN_;
-				SMC_SET_HW_CFG(cfg);
+				SMC_SET_HW_CFG(lp, cfg);
 				udelay(10); /* Wait for clocks to stop */
 
 				cfg &= ~HW_CFG_PHY_CLK_SEL_;
 				cfg |= HW_CFG_PHY_CLK_SEL_EXT_PHY_;
-				SMC_SET_HW_CFG(cfg);
+				SMC_SET_HW_CFG(lp, cfg);
 				udelay(10); /* Wait for clocks to stop */
 
 				cfg |= HW_CFG_SMI_SEL_;
-				SMC_SET_HW_CFG(cfg);
+				SMC_SET_HW_CFG(lp, cfg);
 
 				for (phyaddr = 1; phyaddr < 32; ++phyaddr) {
 
 					/* Read the PHY identifiers */
-					SMC_GET_PHY_ID1(phyaddr & 31, id1);
-					SMC_GET_PHY_ID2(phyaddr & 31, id2);
+					SMC_GET_PHY_ID1(lp, phyaddr & 31, id1);
+					SMC_GET_PHY_ID2(lp, phyaddr & 31, id2);
 
 					/* Make sure it is a valid identifier */
 					if (id1 != 0x0000 && id1 != 0xffff &&
@@ -783,8 +725,8 @@ static void smc911x_phy_detect(struct net_device *dev)
 			}
 		default:
 			/* Internal media only */
-			SMC_GET_PHY_ID1(1, id1);
-			SMC_GET_PHY_ID2(1, id2);
+			SMC_GET_PHY_ID1(lp, 1, id1);
+			SMC_GET_PHY_ID2(lp, 1, id2);
 			/* Save the PHY's address */
 			lp->mii.phy_id = 1;
 			lp->phy_type = id1 << 16 | id2;
@@ -801,16 +743,15 @@ static void smc911x_phy_detect(struct net_device *dev)
 static int smc911x_phy_fixed(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int phyaddr = lp->mii.phy_id;
 	int bmcr;
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	/* Enter Link Disable state */
-	SMC_GET_PHY_BMCR(phyaddr, bmcr);
+	SMC_GET_PHY_BMCR(lp, phyaddr, bmcr);
 	bmcr |= BMCR_PDOWN;
-	SMC_SET_PHY_BMCR(phyaddr, bmcr);
+	SMC_SET_PHY_BMCR(lp, phyaddr, bmcr);
 
 	/*
 	 * Set our fixed capabilities
@@ -824,11 +765,11 @@ static int smc911x_phy_fixed(struct net_device *dev)
 		bmcr |= BMCR_SPEED100;
 
 	/* Write our capabilities to the phy control register */
-	SMC_SET_PHY_BMCR(phyaddr, bmcr);
+	SMC_SET_PHY_BMCR(lp, phyaddr, bmcr);
 
 	/* Re-Configure the Receive/Phy Control register */
 	bmcr &= ~BMCR_PDOWN;
-	SMC_SET_PHY_BMCR(phyaddr, bmcr);
+	SMC_SET_PHY_BMCR(lp, phyaddr, bmcr);
 
 	return 1;
 }
@@ -848,7 +789,6 @@ static int smc911x_phy_fixed(struct net_device *dev)
 static int smc911x_phy_reset(struct net_device *dev, int phy)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int timeout;
 	unsigned long flags;
 	unsigned int reg;
@@ -856,15 +796,15 @@ static int smc911x_phy_reset(struct net_device *dev, int phy)
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __FUNCTION__);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	reg = SMC_GET_PMT_CTRL();
+	reg = SMC_GET_PMT_CTRL(lp);
 	reg &= ~0xfffff030;
 	reg |= PMT_CTRL_PHY_RST_;
-	SMC_SET_PMT_CTRL(reg);
+	SMC_SET_PMT_CTRL(lp, reg);
 	spin_unlock_irqrestore(&lp->lock, flags);
 	for (timeout = 2; timeout; timeout--) {
 		msleep(50);
 		spin_lock_irqsave(&lp->lock, flags);
-		reg = SMC_GET_PMT_CTRL();
+		reg = SMC_GET_PMT_CTRL(lp);
 		spin_unlock_irqrestore(&lp->lock, flags);
 		if (!(reg & PMT_CTRL_PHY_RST_)) {
 			/* extra delay required because the phy may
@@ -889,13 +829,13 @@ static int smc911x_phy_reset(struct net_device *dev, int phy)
  */
 static void smc911x_phy_powerdown(struct net_device *dev, int phy)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int bmcr;
 
 	/* Enter Link Disable state */
-	SMC_GET_PHY_BMCR(phy, bmcr);
+	SMC_GET_PHY_BMCR(lp, phy, bmcr);
 	bmcr |= BMCR_PDOWN;
-	SMC_SET_PHY_BMCR(phy, bmcr);
+	SMC_SET_PHY_BMCR(lp, phy, bmcr);
 }
 
 /*
@@ -909,7 +849,6 @@ static void smc911x_phy_powerdown(struct net_device *dev, int phy)
 static void smc911x_phy_check_media(struct net_device *dev, int init)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int phyaddr = lp->mii.phy_id;
 	unsigned int bmcr, cr;
 
@@ -917,8 +856,8 @@ static void smc911x_phy_check_media(struct net_device *dev, int init)
 
 	if (mii_check_media(&lp->mii, netif_msg_link(lp), init)) {
 		/* duplex state has changed */
-		SMC_GET_PHY_BMCR(phyaddr, bmcr);
-		SMC_GET_MAC_CR(cr);
+		SMC_GET_PHY_BMCR(lp, phyaddr, bmcr);
+		SMC_GET_MAC_CR(lp, cr);
 		if (lp->mii.full_duplex) {
 			DBG(SMC_DEBUG_MISC, "%s: Configuring for full-duplex mode\n", dev->name);
 			bmcr |= BMCR_FULLDPLX;
@@ -928,8 +867,8 @@ static void smc911x_phy_check_media(struct net_device *dev, int init)
 			bmcr &= ~BMCR_FULLDPLX;
 			cr &= ~MAC_CR_RCVOWN_;
 		}
-		SMC_SET_PHY_BMCR(phyaddr, bmcr);
-		SMC_SET_MAC_CR(cr);
+		SMC_SET_PHY_BMCR(lp, phyaddr, bmcr);
+		SMC_SET_MAC_CR(lp, cr);
 	}
 }
 
@@ -947,7 +886,6 @@ static void smc911x_phy_configure(struct work_struct *work)
 	struct smc911x_local *lp = container_of(work, struct smc911x_local,
 						phy_configure);
 	struct net_device *dev = lp->netdev;
-	unsigned long ioaddr = dev->base_addr;
 	int phyaddr = lp->mii.phy_id;
 	int my_phy_caps; /* My PHY capabilities */
 	int my_ad_caps; /* My Advertised capabilities */
@@ -972,7 +910,7 @@ static void smc911x_phy_configure(struct work_struct *work)
 	 * Enable PHY Interrupts (for register 18)
 	 * Interrupts listed here are enabled
 	 */
-	SMC_SET_PHY_INT_MASK(phyaddr, PHY_INT_MASK_ENERGY_ON_ |
+	SMC_SET_PHY_INT_MASK(lp, phyaddr, PHY_INT_MASK_ENERGY_ON_ |
 		 PHY_INT_MASK_ANEG_COMP_ | PHY_INT_MASK_REMOTE_FAULT_ |
 		 PHY_INT_MASK_LINK_DOWN_);
 
@@ -983,7 +921,7 @@ static void smc911x_phy_configure(struct work_struct *work)
 	}
 
 	/* Copy our capabilities from MII_BMSR to MII_ADVERTISE */
-	SMC_GET_PHY_BMSR(phyaddr, my_phy_caps);
+	SMC_GET_PHY_BMSR(lp, phyaddr, my_phy_caps);
 	if (!(my_phy_caps & BMSR_ANEGCAPABLE)) {
 		printk(KERN_INFO "Auto negotiation NOT supported\n");
 		smc911x_phy_fixed(dev);
@@ -1012,7 +950,7 @@ static void smc911x_phy_configure(struct work_struct *work)
 		my_ad_caps &= ~(ADVERTISE_100FULL|ADVERTISE_10FULL);
 
 	/* Update our Auto-Neg Advertisement Register */
-	SMC_SET_PHY_MII_ADV(phyaddr, my_ad_caps);
+	SMC_SET_PHY_MII_ADV(lp, phyaddr, my_ad_caps);
 	lp->mii.advertising = my_ad_caps;
 
 	/*
@@ -1021,13 +959,13 @@ static void smc911x_phy_configure(struct work_struct *work)
 	 * the link does not come up.
 	 */
 	udelay(10);
-	SMC_GET_PHY_MII_ADV(phyaddr, status);
+	SMC_GET_PHY_MII_ADV(lp, phyaddr, status);
 
 	DBG(SMC_DEBUG_MISC, "%s: phy caps=0x%04x\n", dev->name, my_phy_caps);
 	DBG(SMC_DEBUG_MISC, "%s: phy advertised caps=0x%04x\n", dev->name, my_ad_caps);
 
 	/* Restart auto-negotiation process in order to advertise my caps */
-	SMC_SET_PHY_BMCR(phyaddr, BMCR_ANENABLE | BMCR_ANRESTART);
+	SMC_SET_PHY_BMCR(lp, phyaddr, BMCR_ANENABLE | BMCR_ANRESTART);
 
 	smc911x_phy_check_media(dev, 1);
 
@@ -1046,7 +984,6 @@ smc911x_phy_configure_exit_nolock:
 static void smc911x_phy_interrupt(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int phyaddr = lp->mii.phy_id;
 	int status;
 
@@ -1057,11 +994,11 @@ static void smc911x_phy_interrupt(struct net_device *dev)
 
 	smc911x_phy_check_media(dev, 0);
 	/* read to clear status bits */
-	SMC_GET_PHY_INT_SRC(phyaddr,status);
+	SMC_GET_PHY_INT_SRC(lp, phyaddr,status);
 	DBG(SMC_DEBUG_MISC, "%s: PHY interrupt status 0x%04x\n",
 		dev->name, status & 0xffff);
 	DBG(SMC_DEBUG_MISC, "%s: AFC_CFG 0x%08x\n",
-		dev->name, SMC_GET_AFC_CFG());
+		dev->name, SMC_GET_AFC_CFG(lp));
 }
 
 /*--- END PHY CONTROL AND CONFIGURATION-------------------------------------*/
@@ -1073,7 +1010,6 @@ static void smc911x_phy_interrupt(struct net_device *dev)
 static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int status, mask, timeout;
 	unsigned int rx_overrun=0, cr, pkts;
@@ -1084,21 +1020,21 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 	spin_lock_irqsave(&lp->lock, flags);
 
 	/* Spurious interrupt check */
-	if ((SMC_GET_IRQ_CFG() & (INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) !=
+	if ((SMC_GET_IRQ_CFG(lp) & (INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) !=
 		(INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) {
 		spin_unlock_irqrestore(&lp->lock, flags);
 		return IRQ_NONE;
 	}
 
-	mask = SMC_GET_INT_EN();
-	SMC_SET_INT_EN(0);
+	mask = SMC_GET_INT_EN(lp);
+	SMC_SET_INT_EN(lp, 0);
 
 	/* set a timeout value, so I don't stay here forever */
 	timeout = 8;
 
 
 	do {
-		status = SMC_GET_INT();
+		status = SMC_GET_INT(lp);
 
 		DBG(SMC_DEBUG_MISC, "%s: INT 0x%08x MASK 0x%08x OUTSIDE MASK 0x%08x\n",
 			dev->name, status, mask, status & ~mask);
@@ -1109,53 +1045,53 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 
 		/* Handle SW interrupt condition */
 		if (status & INT_STS_SW_INT_) {
-			SMC_ACK_INT(INT_STS_SW_INT_);
+			SMC_ACK_INT(lp, INT_STS_SW_INT_);
 			mask &= ~INT_EN_SW_INT_EN_;
 		}
 		/* Handle various error conditions */
 		if (status & INT_STS_RXE_) {
-			SMC_ACK_INT(INT_STS_RXE_);
+			SMC_ACK_INT(lp, INT_STS_RXE_);
 			dev->stats.rx_errors++;
 		}
 		if (status & INT_STS_RXDFH_INT_) {
-			SMC_ACK_INT(INT_STS_RXDFH_INT_);
-			dev->stats.rx_dropped+=SMC_GET_RX_DROP();
+			SMC_ACK_INT(lp, INT_STS_RXDFH_INT_);
+			dev->stats.rx_dropped+=SMC_GET_RX_DROP(lp);
 		 }
 		/* Undocumented interrupt-what is the right thing to do here? */
 		if (status & INT_STS_RXDF_INT_) {
-			SMC_ACK_INT(INT_STS_RXDF_INT_);
+			SMC_ACK_INT(lp, INT_STS_RXDF_INT_);
 		}
 
 		/* Rx Data FIFO exceeds set level */
 		if (status & INT_STS_RDFL_) {
 			if (IS_REV_A(lp->revision)) {
 				rx_overrun=1;
-				SMC_GET_MAC_CR(cr);
+				SMC_GET_MAC_CR(lp, cr);
 				cr &= ~MAC_CR_RXEN_;
-				SMC_SET_MAC_CR(cr);
+				SMC_SET_MAC_CR(lp, cr);
 				DBG(SMC_DEBUG_RX, "%s: RX overrun\n", dev->name);
 				dev->stats.rx_errors++;
 				dev->stats.rx_fifo_errors++;
 			}
-			SMC_ACK_INT(INT_STS_RDFL_);
+			SMC_ACK_INT(lp, INT_STS_RDFL_);
 		}
 		if (status & INT_STS_RDFO_) {
 			if (!IS_REV_A(lp->revision)) {
-				SMC_GET_MAC_CR(cr);
+				SMC_GET_MAC_CR(lp, cr);
 				cr &= ~MAC_CR_RXEN_;
-				SMC_SET_MAC_CR(cr);
+				SMC_SET_MAC_CR(lp, cr);
 				rx_overrun=1;
 				DBG(SMC_DEBUG_RX, "%s: RX overrun\n", dev->name);
 				dev->stats.rx_errors++;
 				dev->stats.rx_fifo_errors++;
 			}
-			SMC_ACK_INT(INT_STS_RDFO_);
+			SMC_ACK_INT(lp, INT_STS_RDFO_);
 		}
 		/* Handle receive condition */
 		if ((status & INT_STS_RSFL_) || rx_overrun) {
 			unsigned int fifo;
 			DBG(SMC_DEBUG_RX, "%s: RX irq\n", dev->name);
-			fifo = SMC_GET_RX_FIFO_INF();
+			fifo = SMC_GET_RX_FIFO_INF(lp);
 			pkts = (fifo & RX_FIFO_INF_RXSUSED_) >> 16;
 			DBG(SMC_DEBUG_RX, "%s: Rx FIFO pkts %d, bytes %d\n",
 				dev->name, pkts, fifo & 0xFFFF );
@@ -1166,61 +1102,61 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 					DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA,
 						"%s: RX DMA active\n", dev->name);
 					/* The DMA is already running so up the IRQ threshold */
-					fifo = SMC_GET_FIFO_INT() & ~0xFF;
+					fifo = SMC_GET_FIFO_INT(lp) & ~0xFF;
 					fifo |= pkts & 0xFF;
 					DBG(SMC_DEBUG_RX,
 						"%s: Setting RX stat FIFO threshold to %d\n",
 						dev->name, fifo & 0xff);
-					SMC_SET_FIFO_INT(fifo);
+					SMC_SET_FIFO_INT(lp, fifo);
 				} else
 #endif
 				smc911x_rcv(dev);
 			}
-			SMC_ACK_INT(INT_STS_RSFL_);
+			SMC_ACK_INT(lp, INT_STS_RSFL_);
 		}
 		/* Handle transmit FIFO available */
 		if (status & INT_STS_TDFA_) {
 			DBG(SMC_DEBUG_TX, "%s: TX data FIFO space available irq\n", dev->name);
-			SMC_SET_FIFO_TDA(0xFF);
+			SMC_SET_FIFO_TDA(lp, 0xFF);
 			lp->tx_throttle = 0;
 #ifdef SMC_USE_DMA
 			if (!lp->txdma_active)
 #endif
 				netif_wake_queue(dev);
-			SMC_ACK_INT(INT_STS_TDFA_);
+			SMC_ACK_INT(lp, INT_STS_TDFA_);
 		}
 		/* Handle transmit done condition */
 #if 1
 		if (status & (INT_STS_TSFL_ | INT_STS_GPT_INT_)) {
 			DBG(SMC_DEBUG_TX | SMC_DEBUG_MISC,
 				"%s: Tx stat FIFO limit (%d) /GPT irq\n",
-				dev->name, (SMC_GET_FIFO_INT() & 0x00ff0000) >> 16);
+				dev->name, (SMC_GET_FIFO_INT(lp) & 0x00ff0000) >> 16);
 			smc911x_tx(dev);
-			SMC_SET_GPT_CFG(GPT_CFG_TIMER_EN_ | 10000);
-			SMC_ACK_INT(INT_STS_TSFL_);
-			SMC_ACK_INT(INT_STS_TSFL_ | INT_STS_GPT_INT_);
+			SMC_SET_GPT_CFG(lp, GPT_CFG_TIMER_EN_ | 10000);
+			SMC_ACK_INT(lp, INT_STS_TSFL_);
+			SMC_ACK_INT(lp, INT_STS_TSFL_ | INT_STS_GPT_INT_);
 		}
 #else
 		if (status & INT_STS_TSFL_) {
 			DBG(SMC_DEBUG_TX, "%s: TX status FIFO limit (%d) irq \n", dev->name, );
 			smc911x_tx(dev);
-			SMC_ACK_INT(INT_STS_TSFL_);
+			SMC_ACK_INT(lp, INT_STS_TSFL_);
 		}
 
 		if (status & INT_STS_GPT_INT_) {
 			DBG(SMC_DEBUG_RX, "%s: IRQ_CFG 0x%08x FIFO_INT 0x%08x RX_CFG 0x%08x\n",
 				dev->name,
-				SMC_GET_IRQ_CFG(),
-				SMC_GET_FIFO_INT(),
-				SMC_GET_RX_CFG());
+				SMC_GET_IRQ_CFG(lp),
+				SMC_GET_FIFO_INT(lp),
+				SMC_GET_RX_CFG(lp));
 			DBG(SMC_DEBUG_RX, "%s: Rx Stat FIFO Used 0x%02x "
 				"Data FIFO Used 0x%04x Stat FIFO 0x%08x\n",
 				dev->name,
-				(SMC_GET_RX_FIFO_INF() & 0x00ff0000) >> 16,
-				SMC_GET_RX_FIFO_INF() & 0xffff,
-				SMC_GET_RX_STS_FIFO_PEEK());
-			SMC_SET_GPT_CFG(GPT_CFG_TIMER_EN_ | 10000);
-			SMC_ACK_INT(INT_STS_GPT_INT_);
+				(SMC_GET_RX_FIFO_INF(lp) & 0x00ff0000) >> 16,
+				SMC_GET_RX_FIFO_INF(lp) & 0xffff,
+				SMC_GET_RX_STS_FIFO_PEEK(lp));
+			SMC_SET_GPT_CFG(lp, GPT_CFG_TIMER_EN_ | 10000);
+			SMC_ACK_INT(lp, INT_STS_GPT_INT_);
 		}
 #endif
 
@@ -1228,12 +1164,12 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 		if (status & INT_STS_PHY_INT_) {
 			DBG(SMC_DEBUG_MISC, "%s: PHY irq\n", dev->name);
 			smc911x_phy_interrupt(dev);
-			SMC_ACK_INT(INT_STS_PHY_INT_);
+			SMC_ACK_INT(lp, INT_STS_PHY_INT_);
 		}
 	} while (--timeout);
 
 	/* restore mask state */
-	SMC_SET_INT_EN(mask);
+	SMC_SET_INT_EN(lp, mask);
 
 	DBG(SMC_DEBUG_MISC, "%s: Interrupt done (%d loops)\n",
 		dev->name, 8-timeout);
@@ -1335,22 +1271,21 @@ static void smc911x_poll_controller(struct net_device *dev)
 static void smc911x_timeout(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int status, mask;
 	unsigned long flags;
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	status = SMC_GET_INT();
-	mask = SMC_GET_INT_EN();
+	status = SMC_GET_INT(lp);
+	mask = SMC_GET_INT_EN(lp);
 	spin_unlock_irqrestore(&lp->lock, flags);
 	DBG(SMC_DEBUG_MISC, "%s: INT 0x%02x MASK 0x%02x \n",
 		dev->name, status, mask);
 
 	/* Dump the current TX FIFO contents and restart */
-	mask = SMC_GET_TX_CFG();
-	SMC_SET_TX_CFG(mask | TX_CFG_TXS_DUMP_ | TX_CFG_TXD_DUMP_);
+	mask = SMC_GET_TX_CFG(lp);
+	SMC_SET_TX_CFG(lp, mask | TX_CFG_TXS_DUMP_ | TX_CFG_TXD_DUMP_);
 	/*
 	 * Reconfiguring the PHY doesn't seem like a bad idea here, but
 	 * smc911x_phy_configure() calls msleep() which calls schedule_timeout()
@@ -1376,7 +1311,6 @@ static void smc911x_timeout(struct net_device *dev)
 static void smc911x_set_multicast_list(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	unsigned int multicast_table[2];
 	unsigned int mcr, update_multicast = 0;
 	unsigned long flags;
@@ -1384,7 +1318,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_GET_MAC_CR(mcr);
+	SMC_GET_MAC_CR(lp, mcr);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	if (dev->flags & IFF_PROMISC) {
@@ -1461,13 +1395,13 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	}
 
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_SET_MAC_CR(mcr);
+	SMC_SET_MAC_CR(lp, mcr);
 	if (update_multicast) {
 		DBG(SMC_DEBUG_MISC,
 			"%s: update mcast hash table 0x%08x 0x%08x\n",
 			dev->name, multicast_table[0], multicast_table[1]);
-		SMC_SET_HASHL(multicast_table[0]);
-		SMC_SET_HASHH(multicast_table[1]);
+		SMC_SET_HASHL(lp, multicast_table[0]);
+		SMC_SET_HASHH(lp, multicast_table[1]);
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
@@ -1559,7 +1493,6 @@ static int
 smc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int ret, status;
 	unsigned long flags;
 
@@ -1587,7 +1520,7 @@ smc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 		else
 			cmd->transceiver = XCVR_EXTERNAL;
 		cmd->port = 0;
-		SMC_GET_PHY_SPECIAL(lp->mii.phy_id, status);
+		SMC_GET_PHY_SPECIAL(lp, lp->mii.phy_id, status);
 		cmd->duplex =
 			(status & (PHY_SPECIAL_SPD_10FULL_ | PHY_SPECIAL_SPD_100FULL_)) ?
 				DUPLEX_FULL : DUPLEX_HALF;
@@ -1668,7 +1601,6 @@ static int smc911x_ethtool_getregslen(struct net_device *dev)
 static void smc911x_ethtool_getregs(struct net_device *dev,
 										 struct ethtool_regs* regs, void *buf)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned long flags;
 	u32 reg,i,j=0;
@@ -1676,17 +1608,17 @@ static void smc911x_ethtool_getregs(struct net_device *dev,
 
 	regs->version = lp->version;
 	for(i=ID_REV;i<=E2P_CMD;i+=4) {
-		data[j++] = SMC_inl(ioaddr,i);
+		data[j++] = SMC_inl(lp, i);
 	}
 	for(i=MAC_CR;i<=WUCSR;i++) {
 		spin_lock_irqsave(&lp->lock, flags);
-		SMC_GET_MAC_CSR(i, reg);
+		SMC_GET_MAC_CSR(lp, i, reg);
 		spin_unlock_irqrestore(&lp->lock, flags);
 		data[j++] = reg;
 	}
 	for(i=0;i<=31;i++) {
 		spin_lock_irqsave(&lp->lock, flags);
-		SMC_GET_MII(i, lp->mii.phy_id, reg);
+		SMC_GET_MII(lp, i, lp->mii.phy_id, reg);
 		spin_unlock_irqrestore(&lp->lock, flags);
 		data[j++] = reg & 0xFFFF;
 	}
@@ -1694,11 +1626,11 @@ static void smc911x_ethtool_getregs(struct net_device *dev,
 
 static int smc911x_ethtool_wait_eeprom_ready(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int timeout;
 	int e2p_cmd;
 
-	e2p_cmd = SMC_GET_E2P_CMD();
+	e2p_cmd = SMC_GET_E2P_CMD(lp);
 	for(timeout=10;(e2p_cmd & E2P_CMD_EPC_BUSY_) && timeout; timeout--) {
 		if (e2p_cmd & E2P_CMD_EPC_TIMEOUT_) {
 			PRINTK("%s: %s timeout waiting for EEPROM to respond\n",
@@ -1706,7 +1638,7 @@ static int smc911x_ethtool_wait_eeprom_ready(struct net_device *dev)
 			return -EFAULT;
 		}
 		mdelay(1);
-		e2p_cmd = SMC_GET_E2P_CMD();
+		e2p_cmd = SMC_GET_E2P_CMD(lp);
 	}
 	if (timeout == 0) {
 		PRINTK("%s: %s timeout waiting for EEPROM CMD not busy\n",
@@ -1719,12 +1651,12 @@ static int smc911x_ethtool_wait_eeprom_ready(struct net_device *dev)
 static inline int smc911x_ethtool_write_eeprom_cmd(struct net_device *dev,
 													int cmd, int addr)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	int ret;
 
 	if ((ret = smc911x_ethtool_wait_eeprom_ready(dev))!=0)
 		return ret;
-	SMC_SET_E2P_CMD(E2P_CMD_EPC_BUSY_ |
+	SMC_SET_E2P_CMD(lp, E2P_CMD_EPC_BUSY_ |
 		((cmd) & (0x7<<28)) |
 		((addr) & 0xFF));
 	return 0;
@@ -1733,24 +1665,24 @@ static inline int smc911x_ethtool_write_eeprom_cmd(struct net_device *dev,
 static inline int smc911x_ethtool_read_eeprom_byte(struct net_device *dev,
 													u8 *data)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	int ret;
 
 	if ((ret = smc911x_ethtool_wait_eeprom_ready(dev))!=0)
 		return ret;
-	*data = SMC_GET_E2P_DATA();
+	*data = SMC_GET_E2P_DATA(lp);
 	return 0;
 }
 
 static inline int smc911x_ethtool_write_eeprom_byte(struct net_device *dev,
 													 u8 data)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	int ret;
 
 	if ((ret = smc911x_ethtool_wait_eeprom_ready(dev))!=0)
 		return ret;
-	SMC_SET_E2P_DATA(data);
+	SMC_SET_E2P_DATA(lp, data);
 	return 0;
 }
 
@@ -1817,8 +1749,9 @@ static const struct ethtool_ops smc911x_ethtool_ops = {
  * This routine has a simple purpose -- make the SMC chip generate an
  * interrupt, so an auto-detect routine can detect it, and find the IRQ,
  */
-static int __init smc911x_findirq(unsigned long ioaddr)
+static int __init smc911x_findirq(struct net_device *dev)
 {
+	struct smc911x_local *lp = netdev_priv(dev);
 	int timeout = 20;
 	unsigned long cookie;
 
@@ -1830,7 +1763,7 @@ static int __init smc911x_findirq(unsigned long ioaddr)
 	 * Force a SW interrupt
 	 */
 
-	SMC_SET_INT_EN(INT_EN_SW_INT_EN_);
+	SMC_SET_INT_EN(lp, INT_EN_SW_INT_EN_);
 
 	/*
 	 * Wait until positive that the interrupt has been generated
@@ -1838,7 +1771,7 @@ static int __init smc911x_findirq(unsigned long ioaddr)
 	do {
 		int int_status;
 		udelay(10);
-		int_status = SMC_GET_INT_EN();
+		int_status = SMC_GET_INT_EN(lp);
 		if (int_status & INT_EN_SW_INT_EN_)
 			 break;		/* got the interrupt */
 	} while (--timeout);
@@ -1851,7 +1784,7 @@ static int __init smc911x_findirq(unsigned long ioaddr)
 	 */
 
 	/* and disable all interrupts again */
-	SMC_SET_INT_EN(0);
+	SMC_SET_INT_EN(lp, 0);
 
 	/* and return what I found */
 	return probe_irq_off(cookie);
@@ -1880,17 +1813,18 @@ static int __init smc911x_findirq(unsigned long ioaddr)
  * o  actually GRAB the irq.
  * o  GRAB the region
  */
-static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
+static int __init smc911x_probe(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 	int i, retval;
 	unsigned int val, chip_id, revision;
 	const char *version_string;
+	unsigned long irq_flags;
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	/* First, see if the endian word is recognized */
-	val = SMC_GET_BYTE_TEST();
+	val = SMC_GET_BYTE_TEST(lp);
 	DBG(SMC_DEBUG_MISC, "%s: endian probe returned 0x%04x\n", CARDNAME, val);
 	if (val != 0x87654321) {
 		printk(KERN_ERR "Invalid chip endian 0x08%x\n",val);
@@ -1903,7 +1837,7 @@ static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
 	 * recognize.	These might need to be added to later,
 	 * as future revisions could be added.
 	 */
-	chip_id = SMC_GET_PN();
+	chip_id = SMC_GET_PN(lp);
 	DBG(SMC_DEBUG_MISC, "%s: id probe returned 0x%04x\n", CARDNAME, chip_id);
 	for(i=0;chip_ids[i].id != 0; i++) {
 		if (chip_ids[i].id == chip_id) break;
@@ -1915,7 +1849,7 @@ static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
 	}
 	version_string = chip_ids[i].name;
 
-	revision = SMC_GET_REV();
+	revision = SMC_GET_REV(lp);
 	DBG(SMC_DEBUG_MISC, "%s: revision = 0x%04x\n", CARDNAME, revision);
 
 	/* At this point I'll assume that the chip is an SMC911x. */
@@ -1929,7 +1863,6 @@ static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
 	}
 
 	/* fill in some of the fields */
-	dev->base_addr = ioaddr;
 	lp->version = chip_ids[i].id;
 	lp->revision = revision;
 	lp->tx_fifo_kb = tx_fifo_kb;
@@ -1988,7 +1921,7 @@ static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
 	spin_lock_init(&lp->lock);
 
 	/* Get the MAC address */
-	SMC_GET_MAC_ADDR(dev->dev_addr);
+	SMC_GET_MAC_ADDR(lp, dev->dev_addr);
 
 	/* now, reset the chip, and put it into a known state */
 	smc911x_reset(dev);
@@ -2005,7 +1938,7 @@ static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
 
 		trials = 3;
 		while (trials--) {
-			dev->irq = smc911x_findirq(ioaddr);
+			dev->irq = smc911x_findirq(dev);
 			if (dev->irq)
 				break;
 			/* kick the card and try again */
@@ -2053,9 +1986,15 @@ static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
 	lp->ctl_rfduplx = 1;
 	lp->ctl_rspeed = 100;
 
+#ifdef SMC_DYNAMIC_BUS_CONFIG
+	irq_flags = lp->cfg.irq_flags;
+#else
+	irq_flags = IRQF_SHARED | SMC_IRQ_SENSE;
+#endif
+
 	/* Grab the IRQ */
 	retval = request_irq(dev->irq, &smc911x_interrupt,
-			IRQF_SHARED | SMC_IRQ_SENSE, dev->name, dev);
+			     irq_flags, dev->name, dev);
 	if (retval)
 		goto err_out;
 
@@ -2125,6 +2064,7 @@ err_out:
  */
 static int smc911x_drv_probe(struct platform_device *pdev)
 {
+	struct smc91x_platdata *pd = pdev->dev.platform_data;
 	struct net_device *ndev;
 	struct resource *res;
 	struct smc911x_local *lp;
@@ -2158,6 +2098,13 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 	ndev->irq = platform_get_irq(pdev, 0);
 	lp = netdev_priv(ndev);
 	lp->netdev = ndev;
+#ifdef SMC_DYNAMIC_BUS_CONFIG
+	if (!pd) {
+		ret = -EINVAL;
+		goto release_both;
+	}
+	memcpy(&lp->cfg, pd, sizeof(lp->cfg));
+#endif
 
 	addr = ioremap(res->start, SMC911X_IO_EXTENT);
 	if (!addr) {
@@ -2166,7 +2113,9 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 	}
 
 	platform_set_drvdata(pdev, ndev);
-	ret = smc911x_probe(ndev, (unsigned long)addr);
+	lp->base = addr;
+	ndev->base_addr = res->start;
+	ret = smc911x_probe(ndev);
 	if (ret != 0) {
 		platform_set_drvdata(pdev, NULL);
 		iounmap(addr);
@@ -2190,6 +2139,7 @@ out:
 static int smc911x_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct smc911x_local *lp = netdev_priv(ndev);
 	struct resource *res;
 
 	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
@@ -2201,7 +2151,6 @@ static int smc911x_drv_remove(struct platform_device *pdev)
 
 #ifdef SMC_USE_DMA
 	{
-		struct smc911x_local *lp = netdev_priv(ndev);
 		if (lp->rxdma != -1) {
 			SMC_DMA_FREE(dev, lp->rxdma);
 		}
@@ -2210,7 +2159,7 @@ static int smc911x_drv_remove(struct platform_device *pdev)
 		}
 	}
 #endif
-	iounmap((void *)ndev->base_addr);
+	iounmap(lp->base);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, SMC911X_IO_EXTENT);
 
@@ -2221,7 +2170,7 @@ static int smc911x_drv_remove(struct platform_device *pdev)
 static int smc911x_drv_suspend(struct platform_device *dev, pm_message_t state)
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
-	unsigned long ioaddr = ndev->base_addr;
+	struct smc911x_local *lp = netdev_priv(ndev);
 
 	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
 	if (ndev) {
@@ -2230,7 +2179,7 @@ static int smc911x_drv_suspend(struct platform_device *dev, pm_message_t state)
 			smc911x_shutdown(ndev);
 #if POWER_DOWN
 			/* Set D2 - Energy detect only setting */
-			SMC_SET_PMT_CTRL(2<<12);
+			SMC_SET_PMT_CTRL(lp, 2<<12);
 #endif
 		}
 	}
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 7defa63..7cc7cd7 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -29,6 +29,7 @@
 #ifndef _SMC911X_H_
 #define _SMC911X_H_
 
+#include <linux/smc911x.h>
 /*
  * Use the DMA feature on PXA chips
  */
@@ -38,42 +39,161 @@
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_FALLING
 #elif defined(CONFIG_SH_MAGIC_PANEL_R2)
-  #define SMC_USE_SH_DMA	0
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
+#else
+/*
+ * Default configuration
+ */
+
+#define SMC_DYNAMIC_BUS_CONFIG
 #endif
 
+/* store this information for the driver.. */
+struct smc911x_local {
+	/*
+	 * If I have to wait until the DMA is finished and ready to reload a
+	 * packet, I will store the skbuff here. Then, the DMA will send it
+	 * out and free it.
+	 */
+	struct sk_buff *pending_tx_skb;
+
+	/* version/revision of the SMC911x chip */
+	u16 version;
+	u16 revision;
+
+	/* FIFO sizes */
+	int tx_fifo_kb;
+	int tx_fifo_size;
+	int rx_fifo_size;
+	int afc_cfg;
+
+	/* Contains the current active receive/phy mode */
+	int ctl_rfduplx;
+	int ctl_rspeed;
+
+	u32 msg_enable;
+	u32 phy_type;
+	struct mii_if_info mii;
+
+	/* work queue */
+	struct work_struct phy_configure;
+	int work_pending;
+
+	int tx_throttle;
+	spinlock_t lock;
+
+	struct net_device *netdev;
+
+#ifdef SMC_USE_DMA
+	/* DMA needs the physical address of the chip */
+	u_long physaddr;
+	int rxdma;
+	int txdma;
+	int rxdma_active;
+	int txdma_active;
+	struct sk_buff *current_rx_skb;
+	struct sk_buff *current_tx_skb;
+	struct device *dev;
+#endif
+	void __iomem *base;
+#ifdef SMC_DYNAMIC_BUS_CONFIG
+	struct smc911x_platdata cfg;
+#endif
+};
 
 /*
  * Define the bus width specific IO macros
  */
 
+#ifdef SMC_DYNAMIC_BUS_CONFIG
+static inline unsigned int SMC_inl(struct smc911x_local *lp, int reg)
+{
+	void __iomem *ioaddr = lp->base + reg;
+
+	if (lp->cfg.flags & SMC911X_USE_32BIT)
+		return readl(ioaddr);
+
+	if (lp->cfg.flags & SMC911X_USE_16BIT)
+		return readw(ioaddr) | (readw(ioaddr + 2) << 16);
+
+	BUG();
+}
+
+static inline void SMC_outl(unsigned int value, struct smc911x_local *lp,
+			    int reg)
+{
+	void __iomem *ioaddr = lp->base + reg;
+
+	if (lp->cfg.flags & SMC911X_USE_32BIT) {
+		writel(value, ioaddr);
+		return;
+	}
+
+	if (lp->cfg.flags & SMC911X_USE_16BIT) {
+		writew(value & 0xffff, ioaddr);
+		writew(value >> 16, ioaddr + 2);
+		return;
+	}
+
+	BUG();
+}
+
+static inline void SMC_insl(struct smc911x_local *lp, int reg,
+			      void *addr, unsigned int count)
+{
+	void __iomem *ioaddr = lp->base + reg;
+
+	if (lp->cfg.flags & SMC911X_USE_32BIT) {
+		readsl(ioaddr, addr, count);
+		return;
+	}
+
+	if (lp->cfg.flags & SMC911X_USE_16BIT) {
+		readsw(ioaddr, addr, count * 2);
+		return;
+	}
+
+	BUG();
+}
+
+static inline void SMC_outsl(struct smc911x_local *lp, int reg,
+			     void *addr, unsigned int count)
+{
+	void __iomem *ioaddr = lp->base + reg;
+
+	if (lp->cfg.flags & SMC911X_USE_32BIT) {
+		writesl(ioaddr, addr, count);
+		return;
+	}
+
+	if (lp->cfg.flags & SMC911X_USE_16BIT) {
+		writesw(ioaddr, addr, count * 2);
+		return;
+	}
+
+	BUG();
+}
+#else
 #if	SMC_USE_16BIT
-#define SMC_inb(a, r)			 readb((a) + (r))
-#define SMC_inw(a, r)			 readw((a) + (r))
-#define SMC_inl(a, r)			 ((SMC_inw(a, r) & 0xFFFF)+(SMC_inw(a+2, r)<<16))
-#define SMC_outb(v, a, r)		 writeb(v, (a) + (r))
-#define SMC_outw(v, a, r)		 writew(v, (a) + (r))
-#define SMC_outl(v, a, r) 			 \
+#define SMC_inl(lp, r)		 ((readw((lp)->base + (r)) & 0xFFFF) + (readw((lp)->base + (r) + 2) << 16))
+#define SMC_outl(v, lp, r) 			 \
 	do{					 \
-		 writel(v & 0xFFFF, (a) + (r));	 \
-		 writel(v >> 16, (a) + (r) + 2); \
+		 writew(v & 0xFFFF, (lp)->base + (r));	 \
+		 writew(v >> 16, (lp)->base + (r) + 2); \
 	 } while (0)
-#define SMC_insl(a, r, p, l)	 readsw((short*)((a) + (r)), p, l*2)
-#define SMC_outsl(a, r, p, l)	 writesw((short*)((a) + (r)), p, l*2)
+#define SMC_insl(lp, r, p, l)	 readsw((short*)((lp)->base + (r)), p, l*2)
+#define SMC_outsl(lp, r, p, l)	 writesw((short*)((lp)->base + (r)), p, l*2)
 
 #elif	SMC_USE_32BIT
-#define SMC_inb(a, r)		 readb((a) + (r))
-#define SMC_inw(a, r)		 readw((a) + (r))
-#define SMC_inl(a, r)		 readl((a) + (r))
-#define SMC_outb(v, a, r)	 writeb(v, (a) + (r))
-#define SMC_outl(v, a, r)	 writel(v, (a) + (r))
-#define SMC_insl(a, r, p, l)	 readsl((int*)((a) + (r)), p, l)
-#define SMC_outsl(a, r, p, l)	 writesl((int*)((a) + (r)), p, l)
+#define SMC_inl(lp, r)		 readl((lp)->base + (r))
+#define SMC_outl(v, lp, r)	 writel(v, (lp)->base + (r))
+#define SMC_insl(lp, r, p, l)	 readsl((int*)((lp)->base + (r)), p, l)
+#define SMC_outsl(lp, r, p, l)	 writesl((int*)((lp)->base + (r)), p, l)
 
 #endif /* SMC_USE_16BIT */
-
+#endif /* SMC_DYNAMIC_BUS_CONFIG */
 
 
 #ifdef SMC_USE_PXA_DMA
@@ -110,22 +230,22 @@ static int rx_dmalen, tx_dmalen;
 
 #ifdef SMC_insl
 #undef SMC_insl
-#define SMC_insl(a, r, p, l) \
-	smc_pxa_dma_insl(lp->dev, a, lp->physaddr, r, lp->rxdma, p, l)
+#define SMC_insl(lp, r, p, l) \
+	smc_pxa_dma_insl(lp, lp->physaddr, r, lp->rxdma, p, l)
 
 static inline void
-smc_pxa_dma_insl(struct device *dev, u_long ioaddr, u_long physaddr,
+smc_pxa_dma_insl(struct smc911x_local *lp, u_long physaddr,
 		int reg, int dma, u_char *buf, int len)
 {
 	/* 64 bit alignment is required for memory to memory DMA */
 	if ((long)buf & 4) {
-		*((u32 *)buf) = SMC_inl(ioaddr, reg);
+		*((u32 *)buf) = SMC_inl(lp, reg);
 		buf += 4;
 		len--;
 	}
 
 	len *= 4;
-	rx_dmabuf = dma_map_single(dev, buf, len, DMA_FROM_DEVICE);
+	rx_dmabuf = dma_map_single(lp->dev, buf, len, DMA_FROM_DEVICE);
 	rx_dmalen = len;
 	DCSR(dma) = DCSR_NODESC;
 	DTADR(dma) = rx_dmabuf;
@@ -136,52 +256,24 @@ smc_pxa_dma_insl(struct device *dev, u_long ioaddr, u_long physaddr,
 }
 #endif
 
-#ifdef SMC_insw
-#undef SMC_insw
-#define SMC_insw(a, r, p, l) \
-	smc_pxa_dma_insw(lp->dev, a, lp->physaddr, r, lp->rxdma, p, l)
-
-static inline void
-smc_pxa_dma_insw(struct device *dev, u_long ioaddr, u_long physaddr,
-		int reg, int dma, u_char *buf, int len)
-{
-	/* 64 bit alignment is required for memory to memory DMA */
-	while ((long)buf & 6) {
-		*((u16 *)buf) = SMC_inw(ioaddr, reg);
-		buf += 2;
-		len--;
-	}
-
-	len *= 2;
-	rx_dmabuf = dma_map_single(dev, buf, len, DMA_FROM_DEVICE);
-	rx_dmalen = len;
-	DCSR(dma) = DCSR_NODESC;
-	DTADR(dma) = rx_dmabuf;
-	DSADR(dma) = physaddr + reg;
-	DCMD(dma) = (DCMD_INCTRGADDR | DCMD_BURST32 |
-		DCMD_WIDTH2 | DCMD_ENDIRQEN | (DCMD_LENGTH & rx_dmalen));
-	DCSR(dma) = DCSR_NODESC | DCSR_RUN;
-}
-#endif
-
 #ifdef SMC_outsl
 #undef SMC_outsl
-#define SMC_outsl(a, r, p, l) \
-	 smc_pxa_dma_outsl(lp->dev, a, lp->physaddr, r, lp->txdma, p, l)
+#define SMC_outsl(lp, r, p, l) \
+	 smc_pxa_dma_outsl(lp, lp->physaddr, r, lp->txdma, p, l)
 
 static inline void
-smc_pxa_dma_outsl(struct device *dev, u_long ioaddr, u_long physaddr,
+smc_pxa_dma_outsl(struct smc911x_local *lp, u_long physaddr,
 		int reg, int dma, u_char *buf, int len)
 {
 	/* 64 bit alignment is required for memory to memory DMA */
 	if ((long)buf & 4) {
-		SMC_outl(*((u32 *)buf), ioaddr, reg);
+		SMC_outl(*((u32 *)buf), lp, reg);
 		buf += 4;
 		len--;
 	}
 
 	len *= 4;
-	tx_dmabuf = dma_map_single(dev, buf, len, DMA_TO_DEVICE);
+	tx_dmabuf = dma_map_single(lp->dev, buf, len, DMA_TO_DEVICE);
 	tx_dmalen = len;
 	DCSR(dma) = DCSR_NODESC;
 	DSADR(dma) = tx_dmabuf;
@@ -191,35 +283,6 @@ smc_pxa_dma_outsl(struct device *dev, u_long ioaddr, u_long physaddr,
 	DCSR(dma) = DCSR_NODESC | DCSR_RUN;
 }
 #endif
-
-#ifdef SMC_outsw
-#undef SMC_outsw
-#define SMC_outsw(a, r, p, l) \
-	smc_pxa_dma_outsw(lp->dev, a, lp->physaddr, r, lp->txdma, p, l)
-
-static inline void
-smc_pxa_dma_outsw(struct device *dev, u_long ioaddr, u_long physaddr,
-		  int reg, int dma, u_char *buf, int len)
-{
-	/* 64 bit alignment is required for memory to memory DMA */
-	while ((long)buf & 6) {
-		SMC_outw(*((u16 *)buf), ioaddr, reg);
-		buf += 2;
-		len--;
-	}
-
-	len *= 2;
-	tx_dmabuf = dma_map_single(dev, buf, len, DMA_TO_DEVICE);
-	tx_dmalen = len;
-	DCSR(dma) = DCSR_NODESC;
-	DSADR(dma) = tx_dmabuf;
-	DTADR(dma) = physaddr + reg;
-	DCMD(dma) = (DCMD_INCSRCADDR | DCMD_BURST32 |
-		DCMD_WIDTH2 | DCMD_ENDIRQEN | (DCMD_LENGTH & tx_dmalen));
-	DCSR(dma) = DCSR_NODESC | DCSR_RUN;
-}
-#endif
-
 #endif	 /* SMC_USE_PXA_DMA */
 
 
@@ -629,213 +692,213 @@ static const struct chip_id chip_ids[] =  {
  * capabilities.  Please use those and not the in/out primitives.
  */
 /* FIFO read/write macros */
-#define SMC_PUSH_DATA(p, l)	SMC_outsl( ioaddr, TX_DATA_FIFO, p, (l) >> 2 )
-#define SMC_PULL_DATA(p, l)	SMC_insl ( ioaddr, RX_DATA_FIFO, p, (l) >> 2 )
-#define SMC_SET_TX_FIFO(x) 	SMC_outl( x, ioaddr, TX_DATA_FIFO )
-#define SMC_GET_RX_FIFO()	SMC_inl( ioaddr, RX_DATA_FIFO )
+#define SMC_PUSH_DATA(lp, p, l)	SMC_outsl( lp, TX_DATA_FIFO, p, (l) >> 2 )
+#define SMC_PULL_DATA(lp, p, l)	SMC_insl ( lp, RX_DATA_FIFO, p, (l) >> 2 )
+#define SMC_SET_TX_FIFO(lp, x) 	SMC_outl( x, lp, TX_DATA_FIFO )
+#define SMC_GET_RX_FIFO(lp)	SMC_inl( lp, RX_DATA_FIFO )
 
 
 /* I/O mapped register read/write macros */
-#define SMC_GET_TX_STS_FIFO()		SMC_inl( ioaddr, TX_STATUS_FIFO )
-#define SMC_GET_RX_STS_FIFO()		SMC_inl( ioaddr, RX_STATUS_FIFO )
-#define SMC_GET_RX_STS_FIFO_PEEK()	SMC_inl( ioaddr, RX_STATUS_FIFO_PEEK )
-#define SMC_GET_PN()			(SMC_inl( ioaddr, ID_REV ) >> 16)
-#define SMC_GET_REV()			(SMC_inl( ioaddr, ID_REV ) & 0xFFFF)
-#define SMC_GET_IRQ_CFG()		SMC_inl( ioaddr, INT_CFG )
-#define SMC_SET_IRQ_CFG(x)		SMC_outl( x, ioaddr, INT_CFG )
-#define SMC_GET_INT()			SMC_inl( ioaddr, INT_STS )
-#define SMC_ACK_INT(x)			SMC_outl( x, ioaddr, INT_STS )
-#define SMC_GET_INT_EN()		SMC_inl( ioaddr, INT_EN )
-#define SMC_SET_INT_EN(x)		SMC_outl( x, ioaddr, INT_EN )
-#define SMC_GET_BYTE_TEST()		SMC_inl( ioaddr, BYTE_TEST )
-#define SMC_SET_BYTE_TEST(x)		SMC_outl( x, ioaddr, BYTE_TEST )
-#define SMC_GET_FIFO_INT()		SMC_inl( ioaddr, FIFO_INT )
-#define SMC_SET_FIFO_INT(x)		SMC_outl( x, ioaddr, FIFO_INT )
-#define SMC_SET_FIFO_TDA(x)					\
+#define SMC_GET_TX_STS_FIFO(lp)		SMC_inl( lp, TX_STATUS_FIFO )
+#define SMC_GET_RX_STS_FIFO(lp)		SMC_inl( lp, RX_STATUS_FIFO )
+#define SMC_GET_RX_STS_FIFO_PEEK(lp)	SMC_inl( lp, RX_STATUS_FIFO_PEEK )
+#define SMC_GET_PN(lp)			(SMC_inl( lp, ID_REV ) >> 16)
+#define SMC_GET_REV(lp)			(SMC_inl( lp, ID_REV ) & 0xFFFF)
+#define SMC_GET_IRQ_CFG(lp)		SMC_inl( lp, INT_CFG )
+#define SMC_SET_IRQ_CFG(lp, x)		SMC_outl( x, lp, INT_CFG )
+#define SMC_GET_INT(lp)			SMC_inl( lp, INT_STS )
+#define SMC_ACK_INT(lp, x)			SMC_outl( x, lp, INT_STS )
+#define SMC_GET_INT_EN(lp)		SMC_inl( lp, INT_EN )
+#define SMC_SET_INT_EN(lp, x)		SMC_outl( x, lp, INT_EN )
+#define SMC_GET_BYTE_TEST(lp)		SMC_inl( lp, BYTE_TEST )
+#define SMC_SET_BYTE_TEST(lp, x)		SMC_outl( x, lp, BYTE_TEST )
+#define SMC_GET_FIFO_INT(lp)		SMC_inl( lp, FIFO_INT )
+#define SMC_SET_FIFO_INT(lp, x)		SMC_outl( x, lp, FIFO_INT )
+#define SMC_SET_FIFO_TDA(lp, x)					\
 	do {							\
 		unsigned long __flags;				\
 		int __mask;					\
 		local_irq_save(__flags);			\
-		__mask = SMC_GET_FIFO_INT() & ~(0xFF<<24);	\
-		SMC_SET_FIFO_INT( __mask | (x)<<24 );		\
+		__mask = SMC_GET_FIFO_INT((lp)) & ~(0xFF<<24);	\
+		SMC_SET_FIFO_INT( (lp), __mask | (x)<<24 );	\
 		local_irq_restore(__flags);			\
 	} while (0)
-#define SMC_SET_FIFO_TSL(x)					\
+#define SMC_SET_FIFO_TSL(lp, x)					\
 	do {							\
 		unsigned long __flags;				\
 		int __mask;					\
 		local_irq_save(__flags);			\
-		__mask = SMC_GET_FIFO_INT() & ~(0xFF<<16);	\
-		SMC_SET_FIFO_INT( __mask | (((x) & 0xFF)<<16));	\
+		__mask = SMC_GET_FIFO_INT((lp)) & ~(0xFF<<16);	\
+		SMC_SET_FIFO_INT( (lp), __mask | (((x) & 0xFF)<<16));	\
 		local_irq_restore(__flags);			\
 	} while (0)
-#define SMC_SET_FIFO_RSA(x)					\
+#define SMC_SET_FIFO_RSA(lp, x)					\
 	do {							\
 		unsigned long __flags;				\
 		int __mask;					\
 		local_irq_save(__flags);			\
-		__mask = SMC_GET_FIFO_INT() & ~(0xFF<<8);	\
-		SMC_SET_FIFO_INT( __mask | (((x) & 0xFF)<<8));	\
+		__mask = SMC_GET_FIFO_INT((lp)) & ~(0xFF<<8);	\
+		SMC_SET_FIFO_INT( (lp), __mask | (((x) & 0xFF)<<8));	\
 		local_irq_restore(__flags);			\
 	} while (0)
-#define SMC_SET_FIFO_RSL(x)					\
+#define SMC_SET_FIFO_RSL(lp, x)					\
 	do {							\
 		unsigned long __flags;				\
 		int __mask;					\
 		local_irq_save(__flags);			\
-		__mask = SMC_GET_FIFO_INT() & ~0xFF;		\
-		SMC_SET_FIFO_INT( __mask | ((x) & 0xFF));	\
+		__mask = SMC_GET_FIFO_INT((lp)) & ~0xFF;	\
+		SMC_SET_FIFO_INT( (lp),__mask | ((x) & 0xFF));	\
 		local_irq_restore(__flags);			\
 	} while (0)
-#define SMC_GET_RX_CFG()		SMC_inl( ioaddr, RX_CFG )
-#define SMC_SET_RX_CFG(x)		SMC_outl( x, ioaddr, RX_CFG )
-#define SMC_GET_TX_CFG()		SMC_inl( ioaddr, TX_CFG )
-#define SMC_SET_TX_CFG(x)		SMC_outl( x, ioaddr, TX_CFG )
-#define SMC_GET_HW_CFG()		SMC_inl( ioaddr, HW_CFG )
-#define SMC_SET_HW_CFG(x)		SMC_outl( x, ioaddr, HW_CFG )
-#define SMC_GET_RX_DP_CTRL()		SMC_inl( ioaddr, RX_DP_CTRL )
-#define SMC_SET_RX_DP_CTRL(x)		SMC_outl( x, ioaddr, RX_DP_CTRL )
-#define SMC_GET_PMT_CTRL()		SMC_inl( ioaddr, PMT_CTRL )
-#define SMC_SET_PMT_CTRL(x)		SMC_outl( x, ioaddr, PMT_CTRL )
-#define SMC_GET_GPIO_CFG()		SMC_inl( ioaddr, GPIO_CFG )
-#define SMC_SET_GPIO_CFG(x)		SMC_outl( x, ioaddr, GPIO_CFG )
-#define SMC_GET_RX_FIFO_INF()		SMC_inl( ioaddr, RX_FIFO_INF )
-#define SMC_SET_RX_FIFO_INF(x)		SMC_outl( x, ioaddr, RX_FIFO_INF )
-#define SMC_GET_TX_FIFO_INF()		SMC_inl( ioaddr, TX_FIFO_INF )
-#define SMC_SET_TX_FIFO_INF(x)		SMC_outl( x, ioaddr, TX_FIFO_INF )
-#define SMC_GET_GPT_CFG()		SMC_inl( ioaddr, GPT_CFG )
-#define SMC_SET_GPT_CFG(x)		SMC_outl( x, ioaddr, GPT_CFG )
-#define SMC_GET_RX_DROP()		SMC_inl( ioaddr, RX_DROP )
-#define SMC_SET_RX_DROP(x)		SMC_outl( x, ioaddr, RX_DROP )
-#define SMC_GET_MAC_CMD()		SMC_inl( ioaddr, MAC_CSR_CMD )
-#define SMC_SET_MAC_CMD(x)		SMC_outl( x, ioaddr, MAC_CSR_CMD )
-#define SMC_GET_MAC_DATA()		SMC_inl( ioaddr, MAC_CSR_DATA )
-#define SMC_SET_MAC_DATA(x)		SMC_outl( x, ioaddr, MAC_CSR_DATA )
-#define SMC_GET_AFC_CFG()		SMC_inl( ioaddr, AFC_CFG )
-#define SMC_SET_AFC_CFG(x)		SMC_outl( x, ioaddr, AFC_CFG )
-#define SMC_GET_E2P_CMD()		SMC_inl( ioaddr, E2P_CMD )
-#define SMC_SET_E2P_CMD(x)		SMC_outl( x, ioaddr, E2P_CMD )
-#define SMC_GET_E2P_DATA()		SMC_inl( ioaddr, E2P_DATA )
-#define SMC_SET_E2P_DATA(x)		SMC_outl( x, ioaddr, E2P_DATA )
+#define SMC_GET_RX_CFG(lp)		SMC_inl( lp, RX_CFG )
+#define SMC_SET_RX_CFG(lp, x)		SMC_outl( x, lp, RX_CFG )
+#define SMC_GET_TX_CFG(lp)		SMC_inl( lp, TX_CFG )
+#define SMC_SET_TX_CFG(lp, x)		SMC_outl( x, lp, TX_CFG )
+#define SMC_GET_HW_CFG(lp)		SMC_inl( lp, HW_CFG )
+#define SMC_SET_HW_CFG(lp, x)		SMC_outl( x, lp, HW_CFG )
+#define SMC_GET_RX_DP_CTRL(lp)		SMC_inl( lp, RX_DP_CTRL )
+#define SMC_SET_RX_DP_CTRL(lp, x)		SMC_outl( x, lp, RX_DP_CTRL )
+#define SMC_GET_PMT_CTRL(lp)		SMC_inl( lp, PMT_CTRL )
+#define SMC_SET_PMT_CTRL(lp, x)		SMC_outl( x, lp, PMT_CTRL )
+#define SMC_GET_GPIO_CFG(lp)		SMC_inl( lp, GPIO_CFG )
+#define SMC_SET_GPIO_CFG(lp, x)		SMC_outl( x, lp, GPIO_CFG )
+#define SMC_GET_RX_FIFO_INF(lp)		SMC_inl( lp, RX_FIFO_INF )
+#define SMC_SET_RX_FIFO_INF(lp, x)		SMC_outl( x, lp, RX_FIFO_INF )
+#define SMC_GET_TX_FIFO_INF(lp)		SMC_inl( lp, TX_FIFO_INF )
+#define SMC_SET_TX_FIFO_INF(lp, x)		SMC_outl( x, lp, TX_FIFO_INF )
+#define SMC_GET_GPT_CFG(lp)		SMC_inl( lp, GPT_CFG )
+#define SMC_SET_GPT_CFG(lp, x)		SMC_outl( x, lp, GPT_CFG )
+#define SMC_GET_RX_DROP(lp)		SMC_inl( lp, RX_DROP )
+#define SMC_SET_RX_DROP(lp, x)		SMC_outl( x, lp, RX_DROP )
+#define SMC_GET_MAC_CMD(lp)		SMC_inl( lp, MAC_CSR_CMD )
+#define SMC_SET_MAC_CMD(lp, x)		SMC_outl( x, lp, MAC_CSR_CMD )
+#define SMC_GET_MAC_DATA(lp)		SMC_inl( lp, MAC_CSR_DATA )
+#define SMC_SET_MAC_DATA(lp, x)		SMC_outl( x, lp, MAC_CSR_DATA )
+#define SMC_GET_AFC_CFG(lp)		SMC_inl( lp, AFC_CFG )
+#define SMC_SET_AFC_CFG(lp, x)		SMC_outl( x, lp, AFC_CFG )
+#define SMC_GET_E2P_CMD(lp)		SMC_inl( lp, E2P_CMD )
+#define SMC_SET_E2P_CMD(lp, x)		SMC_outl( x, lp, E2P_CMD )
+#define SMC_GET_E2P_DATA(lp)		SMC_inl( lp, E2P_DATA )
+#define SMC_SET_E2P_DATA(lp, x)		SMC_outl( x, lp, E2P_DATA )
 
 /* MAC register read/write macros */
-#define SMC_GET_MAC_CSR(a,v)						\
+#define SMC_GET_MAC_CSR(lp,a,v)						\
 	do {								\
-		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
-		SMC_SET_MAC_CMD(MAC_CSR_CMD_CSR_BUSY_ |			\
+		while (SMC_GET_MAC_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
+		SMC_SET_MAC_CMD((lp),MAC_CSR_CMD_CSR_BUSY_ |		\
 			MAC_CSR_CMD_R_NOT_W_ | (a) );			\
-		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
-		v = SMC_GET_MAC_DATA();					\
+		while (SMC_GET_MAC_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
+		v = SMC_GET_MAC_DATA((lp));			       	\
 	} while (0)
-#define SMC_SET_MAC_CSR(a,v)						\
+#define SMC_SET_MAC_CSR(lp,a,v)						\
 	do {								\
-		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
-		SMC_SET_MAC_DATA(v);					\
-		SMC_SET_MAC_CMD(MAC_CSR_CMD_CSR_BUSY_ | (a) );		\
-		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
+		while (SMC_GET_MAC_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
+		SMC_SET_MAC_DATA((lp), v);				\
+		SMC_SET_MAC_CMD((lp), MAC_CSR_CMD_CSR_BUSY_ | (a) );	\
+		while (SMC_GET_MAC_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
 	} while (0)
-#define SMC_GET_MAC_CR(x)	SMC_GET_MAC_CSR( MAC_CR, x )
-#define SMC_SET_MAC_CR(x)	SMC_SET_MAC_CSR( MAC_CR, x )
-#define SMC_GET_ADDRH(x)	SMC_GET_MAC_CSR( ADDRH, x )
-#define SMC_SET_ADDRH(x)	SMC_SET_MAC_CSR( ADDRH, x )
-#define SMC_GET_ADDRL(x)	SMC_GET_MAC_CSR( ADDRL, x )
-#define SMC_SET_ADDRL(x)	SMC_SET_MAC_CSR( ADDRL, x )
-#define SMC_GET_HASHH(x)	SMC_GET_MAC_CSR( HASHH, x )
-#define SMC_SET_HASHH(x)	SMC_SET_MAC_CSR( HASHH, x )
-#define SMC_GET_HASHL(x)	SMC_GET_MAC_CSR( HASHL, x )
-#define SMC_SET_HASHL(x)	SMC_SET_MAC_CSR( HASHL, x )
-#define SMC_GET_MII_ACC(x)	SMC_GET_MAC_CSR( MII_ACC, x )
-#define SMC_SET_MII_ACC(x)	SMC_SET_MAC_CSR( MII_ACC, x )
-#define SMC_GET_MII_DATA(x)	SMC_GET_MAC_CSR( MII_DATA, x )
-#define SMC_SET_MII_DATA(x)	SMC_SET_MAC_CSR( MII_DATA, x )
-#define SMC_GET_FLOW(x)		SMC_GET_MAC_CSR( FLOW, x )
-#define SMC_SET_FLOW(x)		SMC_SET_MAC_CSR( FLOW, x )
-#define SMC_GET_VLAN1(x)	SMC_GET_MAC_CSR( VLAN1, x )
-#define SMC_SET_VLAN1(x)	SMC_SET_MAC_CSR( VLAN1, x )
-#define SMC_GET_VLAN2(x)	SMC_GET_MAC_CSR( VLAN2, x )
-#define SMC_SET_VLAN2(x)	SMC_SET_MAC_CSR( VLAN2, x )
-#define SMC_SET_WUFF(x)		SMC_SET_MAC_CSR( WUFF, x )
-#define SMC_GET_WUCSR(x)	SMC_GET_MAC_CSR( WUCSR, x )
-#define SMC_SET_WUCSR(x)	SMC_SET_MAC_CSR( WUCSR, x )
+#define SMC_GET_MAC_CR(lp, x)	SMC_GET_MAC_CSR( (lp), MAC_CR, x )
+#define SMC_SET_MAC_CR(lp, x)	SMC_SET_MAC_CSR( (lp), MAC_CR, x )
+#define SMC_GET_ADDRH(lp, x)	SMC_GET_MAC_CSR( (lp), ADDRH, x )
+#define SMC_SET_ADDRH(lp, x)	SMC_SET_MAC_CSR( (lp), ADDRH, x )
+#define SMC_GET_ADDRL(lp, x)	SMC_GET_MAC_CSR( (lp), ADDRL, x )
+#define SMC_SET_ADDRL(lp, x)	SMC_SET_MAC_CSR( (lp), ADDRL, x )
+#define SMC_GET_HASHH(lp, x)	SMC_GET_MAC_CSR( (lp), HASHH, x )
+#define SMC_SET_HASHH(lp, x)	SMC_SET_MAC_CSR( (lp), HASHH, x )
+#define SMC_GET_HASHL(lp, x)	SMC_GET_MAC_CSR( (lp), HASHL, x )
+#define SMC_SET_HASHL(lp, x)	SMC_SET_MAC_CSR( (lp), HASHL, x )
+#define SMC_GET_MII_ACC(lp, x)	SMC_GET_MAC_CSR( (lp), MII_ACC, x )
+#define SMC_SET_MII_ACC(lp, x)	SMC_SET_MAC_CSR( (lp), MII_ACC, x )
+#define SMC_GET_MII_DATA(lp, x)	SMC_GET_MAC_CSR( (lp), MII_DATA, x )
+#define SMC_SET_MII_DATA(lp, x)	SMC_SET_MAC_CSR( (lp), MII_DATA, x )
+#define SMC_GET_FLOW(lp, x)		SMC_GET_MAC_CSR( (lp), FLOW, x )
+#define SMC_SET_FLOW(lp, x)		SMC_SET_MAC_CSR( (lp), FLOW, x )
+#define SMC_GET_VLAN1(lp, x)	SMC_GET_MAC_CSR( (lp), VLAN1, x )
+#define SMC_SET_VLAN1(lp, x)	SMC_SET_MAC_CSR( (lp), VLAN1, x )
+#define SMC_GET_VLAN2(lp, x)	SMC_GET_MAC_CSR( (lp), VLAN2, x )
+#define SMC_SET_VLAN2(lp, x)	SMC_SET_MAC_CSR( (lp), VLAN2, x )
+#define SMC_SET_WUFF(lp, x)		SMC_SET_MAC_CSR( (lp), WUFF, x )
+#define SMC_GET_WUCSR(lp, x)	SMC_GET_MAC_CSR( (lp), WUCSR, x )
+#define SMC_SET_WUCSR(lp, x)	SMC_SET_MAC_CSR( (lp), WUCSR, x )
 
 /* PHY register read/write macros */
-#define SMC_GET_MII(a,phy,v)					\
+#define SMC_GET_MII(lp,a,phy,v)					\
 	do {							\
 		u32 __v;					\
 		do {						\
-			SMC_GET_MII_ACC(__v);			\
+			SMC_GET_MII_ACC((lp), __v);			\
 		} while ( __v & MII_ACC_MII_BUSY_ );		\
-		SMC_SET_MII_ACC( ((phy)<<11) | ((a)<<6) |	\
+		SMC_SET_MII_ACC( (lp), ((phy)<<11) | ((a)<<6) |	\
 			MII_ACC_MII_BUSY_);			\
 		do {						\
-			SMC_GET_MII_ACC(__v);			\
+			SMC_GET_MII_ACC( (lp), __v);			\
 		} while ( __v & MII_ACC_MII_BUSY_ );		\
-		SMC_GET_MII_DATA(v);				\
+		SMC_GET_MII_DATA((lp), v);				\
 	} while (0)
-#define SMC_SET_MII(a,phy,v)					\
+#define SMC_SET_MII(lp,a,phy,v)					\
 	do {							\
 		u32 __v;					\
 		do {						\
-			SMC_GET_MII_ACC(__v);			\
+			SMC_GET_MII_ACC((lp), __v);			\
 		} while ( __v & MII_ACC_MII_BUSY_ );		\
-		SMC_SET_MII_DATA(v);				\
-		SMC_SET_MII_ACC( ((phy)<<11) | ((a)<<6) |	\
+		SMC_SET_MII_DATA((lp), v);				\
+		SMC_SET_MII_ACC( (lp), ((phy)<<11) | ((a)<<6) |	\
 			MII_ACC_MII_BUSY_	 |		\
 			MII_ACC_MII_WRITE_  );			\
 		do {						\
-			SMC_GET_MII_ACC(__v);			\
+			SMC_GET_MII_ACC((lp), __v);			\
 		} while ( __v & MII_ACC_MII_BUSY_ );		\
 	} while (0)
-#define SMC_GET_PHY_BMCR(phy,x)		SMC_GET_MII( MII_BMCR, phy, x )
-#define SMC_SET_PHY_BMCR(phy,x)		SMC_SET_MII( MII_BMCR, phy, x )
-#define SMC_GET_PHY_BMSR(phy,x)		SMC_GET_MII( MII_BMSR, phy, x )
-#define SMC_GET_PHY_ID1(phy,x)		SMC_GET_MII( MII_PHYSID1, phy, x )
-#define SMC_GET_PHY_ID2(phy,x)		SMC_GET_MII( MII_PHYSID2, phy, x )
-#define SMC_GET_PHY_MII_ADV(phy,x)	SMC_GET_MII( MII_ADVERTISE, phy, x )
-#define SMC_SET_PHY_MII_ADV(phy,x)	SMC_SET_MII( MII_ADVERTISE, phy, x )
-#define SMC_GET_PHY_MII_LPA(phy,x)	SMC_GET_MII( MII_LPA, phy, x )
-#define SMC_SET_PHY_MII_LPA(phy,x)	SMC_SET_MII( MII_LPA, phy, x )
-#define SMC_GET_PHY_CTRL_STS(phy,x)	SMC_GET_MII( PHY_MODE_CTRL_STS, phy, x )
-#define SMC_SET_PHY_CTRL_STS(phy,x)	SMC_SET_MII( PHY_MODE_CTRL_STS, phy, x )
-#define SMC_GET_PHY_INT_SRC(phy,x)	SMC_GET_MII( PHY_INT_SRC, phy, x )
-#define SMC_SET_PHY_INT_SRC(phy,x)	SMC_SET_MII( PHY_INT_SRC, phy, x )
-#define SMC_GET_PHY_INT_MASK(phy,x)	SMC_GET_MII( PHY_INT_MASK, phy, x )
-#define SMC_SET_PHY_INT_MASK(phy,x)	SMC_SET_MII( PHY_INT_MASK, phy, x )
-#define SMC_GET_PHY_SPECIAL(phy,x)	SMC_GET_MII( PHY_SPECIAL, phy, x )
+#define SMC_GET_PHY_BMCR(lp,phy,x)		SMC_GET_MII( (lp), MII_BMCR, phy, x )
+#define SMC_SET_PHY_BMCR(lp,phy,x)		SMC_SET_MII( (lp), MII_BMCR, phy, x )
+#define SMC_GET_PHY_BMSR(lp,phy,x)		SMC_GET_MII( (lp), MII_BMSR, phy, x )
+#define SMC_GET_PHY_ID1(lp,phy,x)		SMC_GET_MII( (lp), MII_PHYSID1, phy, x )
+#define SMC_GET_PHY_ID2(lp,phy,x)		SMC_GET_MII( (lp), MII_PHYSID2, phy, x )
+#define SMC_GET_PHY_MII_ADV(lp,phy,x)	SMC_GET_MII( (lp), MII_ADVERTISE, phy, x )
+#define SMC_SET_PHY_MII_ADV(lp,phy,x)	SMC_SET_MII( (lp), MII_ADVERTISE, phy, x )
+#define SMC_GET_PHY_MII_LPA(lp,phy,x)	SMC_GET_MII( (lp), MII_LPA, phy, x )
+#define SMC_SET_PHY_MII_LPA(lp,phy,x)	SMC_SET_MII( (lp), MII_LPA, phy, x )
+#define SMC_GET_PHY_CTRL_STS(lp,phy,x)	SMC_GET_MII( (lp), PHY_MODE_CTRL_STS, phy, x )
+#define SMC_SET_PHY_CTRL_STS(lp,phy,x)	SMC_SET_MII( (lp), PHY_MODE_CTRL_STS, phy, x )
+#define SMC_GET_PHY_INT_SRC(lp,phy,x)	SMC_GET_MII( (lp), PHY_INT_SRC, phy, x )
+#define SMC_SET_PHY_INT_SRC(lp,phy,x)	SMC_SET_MII( (lp), PHY_INT_SRC, phy, x )
+#define SMC_GET_PHY_INT_MASK(lp,phy,x)	SMC_GET_MII( (lp), PHY_INT_MASK, phy, x )
+#define SMC_SET_PHY_INT_MASK(lp,phy,x)	SMC_SET_MII( (lp), PHY_INT_MASK, phy, x )
+#define SMC_GET_PHY_SPECIAL(lp,phy,x)	SMC_GET_MII( (lp), PHY_SPECIAL, phy, x )
 
 
 
 /* Misc read/write macros */
 
 #ifndef SMC_GET_MAC_ADDR
-#define SMC_GET_MAC_ADDR(addr)					\
+#define SMC_GET_MAC_ADDR(lp, addr)				\
 	do {							\
 		unsigned int __v;				\
 								\
-		SMC_GET_MAC_CSR(ADDRL, __v);			\
+		SMC_GET_MAC_CSR((lp), ADDRL, __v);			\
 		addr[0] = __v; addr[1] = __v >> 8;		\
 		addr[2] = __v >> 16; addr[3] = __v >> 24;	\
-		SMC_GET_MAC_CSR(ADDRH, __v);			\
+		SMC_GET_MAC_CSR((lp), ADDRH, __v);			\
 		addr[4] = __v; addr[5] = __v >> 8;		\
 	} while (0)
 #endif
 
-#define SMC_SET_MAC_ADDR(addr)					\
+#define SMC_SET_MAC_ADDR(lp, addr)				\
 	do {							\
-		 SMC_SET_MAC_CSR(ADDRL,				\
+		 SMC_SET_MAC_CSR((lp), ADDRL,				\
 				 addr[0] |			\
 				(addr[1] << 8) |		\
 				(addr[2] << 16) |		\
 				(addr[3] << 24));		\
-		 SMC_SET_MAC_CSR(ADDRH, addr[4]|(addr[5] << 8));\
+		 SMC_SET_MAC_CSR((lp), ADDRH, addr[4]|(addr[5] << 8));\
 	} while (0)
 
 
-#define SMC_WRITE_EEPROM_CMD(cmd, addr)					\
+#define SMC_WRITE_EEPROM_CMD(lp, cmd, addr)				\
 	do {								\
-		while (SMC_GET_E2P_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
-		SMC_SET_MAC_CMD(MAC_CSR_CMD_R_NOT_W_ | a );		\
-		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
+		while (SMC_GET_E2P_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
+		SMC_SET_MAC_CMD((lp), MAC_CSR_CMD_R_NOT_W_ | a );		\
+		while (SMC_GET_MAC_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
 	} while (0)
 
 #endif	 /* _SMC911X_H_ */
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 26ade68..4e994f8 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -915,15 +915,11 @@ static void build_fake_packet(struct lance_private *lp)
 	lp->tx_new = TX_NEXT(entry);
 }
 
-struct net_device *last_dev;
-
 static int lance_open(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	int status = 0;
 
-	last_dev = dev;
-
 	STOP_LANCE(lp);
 
 	if (request_irq(dev->irq, &lance_interrupt, IRQF_SHARED,
diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 0604f3f..68e198b 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -154,6 +154,16 @@ config USB_NET_AX8817X
 	  This driver creates an interface named "ethX", where X depends on
 	  what other networking devices you have in use.
 
+config USB_HSO
+	tristate "Option USB High Speed Mobile Devices"
+	depends on USB && RFKILL
+	default n
+	help
+	  Choose this option if you have an Option HSDPA/HSUPA card.
+	  These cards support downlink speeds of 7.2Mbps or greater.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called hso.
 
 config USB_NET_CDCETHER
 	tristate "CDC Ethernet support (smart devices such as cable modems)"
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 595a539..24800c1 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_USB_CATC)		+= catc.o
 obj-$(CONFIG_USB_KAWETH)	+= kaweth.o
 obj-$(CONFIG_USB_PEGASUS)	+= pegasus.o
 obj-$(CONFIG_USB_RTL8150)	+= rtl8150.o
+obj-$(CONFIG_USB_HSO)		+= hso.o
 obj-$(CONFIG_USB_NET_AX8817X)	+= asix.o
 obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o
 obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
new file mode 100644
index 0000000..031d07b
--- /dev/null
+++ b/drivers/net/usb/hso.c
@@ -0,0 +1,2836 @@
+/******************************************************************************
+ *
+ * Driver for Option High Speed Mobile Devices.
+ *
+ *  Copyright (C) 2008 Option International
+ *  Copyright (C) 2007 Andrew Bird (Sphere Systems Ltd)
+ *  			<ajb@spheresystems.co.uk>
+ *  Copyright (C) 2008 Greg Kroah-Hartman <gregkh@suse.de>
+ *  Copyright (C) 2008 Novell, Inc.
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
+ *  USA
+ *
+ *
+ *****************************************************************************/
+
+/******************************************************************************
+ *
+ * Description of the device:
+ *
+ * Interface 0:	Contains the IP network interface on the bulk end points.
+ *		The multiplexed serial ports are using the interrupt and
+ *		control endpoints.
+ *		Interrupt contains a bitmap telling which multiplexed
+ *		serialport needs servicing.
+ *
+ * Interface 1:	Diagnostics port, uses bulk only, do not submit urbs until the
+ *		port is opened, as this have a huge impact on the network port
+ *		throughput.
+ *
+ * Interface 2:	Standard modem interface - circuit switched interface, should
+ *		not be used.
+ *
+ *****************************************************************************/
+
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/module.h>
+#include <linux/ethtool.h>
+#include <linux/usb.h>
+#include <linux/timer.h>
+#include <linux/tty.h>
+#include <linux/tty_driver.h>
+#include <linux/tty_flip.h>
+#include <linux/kmod.h>
+#include <linux/rfkill.h>
+#include <linux/ip.h>
+#include <linux/uaccess.h>
+#include <linux/usb/cdc.h>
+#include <net/arp.h>
+#include <asm/byteorder.h>
+
+
+#define DRIVER_VERSION			"1.2"
+#define MOD_AUTHOR			"Option Wireless"
+#define MOD_DESCRIPTION			"USB High Speed Option driver"
+#define MOD_LICENSE			"GPL"
+
+#define HSO_MAX_NET_DEVICES		10
+#define HSO__MAX_MTU			2048
+#define DEFAULT_MTU			1500
+#define DEFAULT_MRU			1500
+
+#define CTRL_URB_RX_SIZE		1024
+#define CTRL_URB_TX_SIZE		64
+
+#define BULK_URB_RX_SIZE		4096
+#define BULK_URB_TX_SIZE		8192
+
+#define MUX_BULK_RX_BUF_SIZE		HSO__MAX_MTU
+#define MUX_BULK_TX_BUF_SIZE		HSO__MAX_MTU
+#define MUX_BULK_RX_BUF_COUNT		4
+#define USB_TYPE_OPTION_VENDOR		0x20
+
+/* These definitions are used with the struct hso_net flags element */
+/* - use *_bit operations on it. (bit indices not values.) */
+#define HSO_NET_RUNNING			0
+
+#define	HSO_NET_TX_TIMEOUT		(HZ*10)
+
+/* Serial port defines and structs. */
+#define HSO_SERIAL_FLAG_RX_SENT		0
+
+#define HSO_SERIAL_MAGIC		0x48534f31
+
+/* Number of ttys to handle */
+#define HSO_SERIAL_TTY_MINORS		256
+
+#define MAX_RX_URBS			2
+
+#define get_serial_by_tty(x)	\
+	(x ? (struct hso_serial *)x->driver_data : NULL)
+
+/*****************************************************************************/
+/* Debugging functions                                                       */
+/*****************************************************************************/
+#define D__(lvl_, fmt, arg...)				\
+	do {						\
+		printk(lvl_ "[%d:%s]: " fmt "\n",	\
+		       __LINE__, __func__, ## arg);	\
+	} while (0)
+
+#define D_(lvl, args...)				\
+	do {						\
+		if (lvl & debug)			\
+			D__(KERN_INFO, args);		\
+	} while (0)
+
+#define D1(args...)	D_(0x01, ##args)
+#define D2(args...)	D_(0x02, ##args)
+#define D3(args...)	D_(0x04, ##args)
+#define D4(args...)	D_(0x08, ##args)
+#define D5(args...)	D_(0x10, ##args)
+
+/*****************************************************************************/
+/* Enumerators                                                               */
+/*****************************************************************************/
+enum pkt_parse_state {
+	WAIT_IP,
+	WAIT_DATA,
+	WAIT_SYNC
+};
+
+/*****************************************************************************/
+/* Structs                                                                   */
+/*****************************************************************************/
+
+struct hso_shared_int {
+	struct usb_endpoint_descriptor *intr_endp;
+	void *shared_intr_buf;
+	struct urb *shared_intr_urb;
+	struct usb_device *usb;
+	int use_count;
+	int ref_count;
+	struct mutex shared_int_lock;
+};
+
+struct hso_net {
+	struct hso_device *parent;
+	struct net_device *net;
+	struct rfkill *rfkill;
+
+	struct usb_endpoint_descriptor *in_endp;
+	struct usb_endpoint_descriptor *out_endp;
+
+	struct urb *mux_bulk_rx_urb_pool[MUX_BULK_RX_BUF_COUNT];
+	struct urb *mux_bulk_tx_urb;
+	void *mux_bulk_rx_buf_pool[MUX_BULK_RX_BUF_COUNT];
+	void *mux_bulk_tx_buf;
+
+	struct sk_buff *skb_rx_buf;
+	struct sk_buff *skb_tx_buf;
+
+	enum pkt_parse_state rx_parse_state;
+	spinlock_t net_lock;
+
+	unsigned short rx_buf_size;
+	unsigned short rx_buf_missing;
+	struct iphdr rx_ip_hdr;
+
+	unsigned long flags;
+};
+
+struct hso_serial {
+	struct hso_device *parent;
+	int magic;
+	u8 minor;
+
+	struct hso_shared_int *shared_int;
+
+	/* rx/tx urb could be either a bulk urb or a control urb depending
+	   on which serial port it is used on. */
+	struct urb *rx_urb[MAX_RX_URBS];
+	u8 num_rx_urbs;
+	u8 *rx_data[MAX_RX_URBS];
+	u16 rx_data_length;	/* should contain allocated length */
+
+	struct urb *tx_urb;
+	u8 *tx_data;
+	u8 *tx_buffer;
+	u16 tx_data_length;	/* should contain allocated length */
+	u16 tx_data_count;
+	u16 tx_buffer_count;
+	struct usb_ctrlrequest ctrl_req_tx;
+	struct usb_ctrlrequest ctrl_req_rx;
+
+	struct usb_endpoint_descriptor *in_endp;
+	struct usb_endpoint_descriptor *out_endp;
+
+	unsigned long flags;
+	u8 rts_state;
+	u8 dtr_state;
+	unsigned tx_urb_used:1;
+
+	/* from usb_serial_port */
+	struct tty_struct *tty;
+	int open_count;
+	spinlock_t serial_lock;
+
+	int (*write_data) (struct hso_serial *serial);
+};
+
+struct hso_device {
+	union {
+		struct hso_serial *dev_serial;
+		struct hso_net *dev_net;
+	} port_data;
+
+	u32 port_spec;
+
+	u8 is_active;
+	u8 usb_gone;
+	struct work_struct async_get_intf;
+	struct work_struct async_put_intf;
+
+	struct usb_device *usb;
+	struct usb_interface *interface;
+
+	struct device *dev;
+	struct kref ref;
+	struct mutex mutex;
+};
+
+/* Type of interface */
+#define HSO_INTF_MASK		0xFF00
+#define	HSO_INTF_MUX		0x0100
+#define	HSO_INTF_BULK   	0x0200
+
+/* Type of port */
+#define HSO_PORT_MASK		0xFF
+#define HSO_PORT_NO_PORT	0x0
+#define	HSO_PORT_CONTROL	0x1
+#define	HSO_PORT_APP		0x2
+#define	HSO_PORT_GPS		0x3
+#define	HSO_PORT_PCSC		0x4
+#define	HSO_PORT_APP2		0x5
+#define HSO_PORT_GPS_CONTROL	0x6
+#define HSO_PORT_MSD		0x7
+#define HSO_PORT_VOICE		0x8
+#define HSO_PORT_DIAG2		0x9
+#define	HSO_PORT_DIAG		0x10
+#define	HSO_PORT_MODEM		0x11
+#define	HSO_PORT_NETWORK	0x12
+
+/* Additional device info */
+#define HSO_INFO_MASK		0xFF000000
+#define HSO_INFO_CRC_BUG	0x01000000
+
+/*****************************************************************************/
+/* Prototypes                                                                */
+/*****************************************************************************/
+/* Serial driver functions */
+static int hso_serial_tiocmset(struct tty_struct *tty, struct file *file,
+			       unsigned int set, unsigned int clear);
+static void ctrl_callback(struct urb *urb);
+static void put_rxbuf_data(struct urb *urb, struct hso_serial *serial);
+static void hso_kick_transmit(struct hso_serial *serial);
+/* Helper functions */
+static int hso_mux_submit_intr_urb(struct hso_shared_int *mux_int,
+				   struct usb_device *usb, gfp_t gfp);
+static void log_usb_status(int status, const char *function);
+static struct usb_endpoint_descriptor *hso_get_ep(struct usb_interface *intf,
+						  int type, int dir);
+static int hso_get_mux_ports(struct usb_interface *intf, unsigned char *ports);
+static void hso_free_interface(struct usb_interface *intf);
+static int hso_start_serial_device(struct hso_device *hso_dev, gfp_t flags);
+static int hso_stop_serial_device(struct hso_device *hso_dev);
+static int hso_start_net_device(struct hso_device *hso_dev);
+static void hso_free_shared_int(struct hso_shared_int *shared_int);
+static int hso_stop_net_device(struct hso_device *hso_dev);
+static void hso_serial_ref_free(struct kref *ref);
+static void async_get_intf(struct work_struct *data);
+static void async_put_intf(struct work_struct *data);
+static int hso_put_activity(struct hso_device *hso_dev);
+static int hso_get_activity(struct hso_device *hso_dev);
+
+/*****************************************************************************/
+/* Helping functions                                                         */
+/*****************************************************************************/
+
+/* #define DEBUG */
+
+#define dev2net(x) (x->port_data.dev_net)
+#define dev2ser(x) (x->port_data.dev_serial)
+
+/* Debugging functions */
+#ifdef DEBUG
+static void dbg_dump(int line_count, const char *func_name, unsigned char *buf,
+		     unsigned int len)
+{
+	u8 i = 0;
+
+	printk(KERN_DEBUG "[%d:%s]: len %d", line_count, func_name, len);
+
+	for (i = 0; i < len; i++) {
+		if (!(i % 16))
+			printk("\n    0x%03x:  ", i);
+		printk("%02x ", (unsigned char)buf[i]);
+	}
+	printk("\n");
+}
+
+#define DUMP(buf_, len_)	\
+	dbg_dump(__LINE__, __func__, buf_, len_)
+
+#define DUMP1(buf_, len_)			\
+	do {					\
+		if (0x01 & debug)		\
+			DUMP(buf_, len_);	\
+	} while (0)
+#else
+#define DUMP(buf_, len_)
+#define DUMP1(buf_, len_)
+#endif
+
+/* module parameters */
+static int debug;
+static int tty_major;
+static int disable_net;
+
+/* driver info */
+static const char driver_name[] = "hso";
+static const char tty_filename[] = "ttyHS";
+static const char *version = __FILE__ ": " DRIVER_VERSION " " MOD_AUTHOR;
+/* the usb driver itself (registered in hso_init) */
+static struct usb_driver hso_driver;
+/* serial structures */
+static struct tty_driver *tty_drv;
+static struct hso_device *serial_table[HSO_SERIAL_TTY_MINORS];
+static struct hso_device *network_table[HSO_MAX_NET_DEVICES];
+static spinlock_t serial_table_lock;
+static struct ktermios *hso_serial_termios[HSO_SERIAL_TTY_MINORS];
+static struct ktermios *hso_serial_termios_locked[HSO_SERIAL_TTY_MINORS];
+
+static const s32 default_port_spec[] = {
+	HSO_INTF_MUX | HSO_PORT_NETWORK,
+	HSO_INTF_BULK | HSO_PORT_DIAG,
+	HSO_INTF_BULK | HSO_PORT_MODEM,
+	0
+};
+
+static const s32 icon321_port_spec[] = {
+	HSO_INTF_MUX | HSO_PORT_NETWORK,
+	HSO_INTF_BULK | HSO_PORT_DIAG2,
+	HSO_INTF_BULK | HSO_PORT_MODEM,
+	HSO_INTF_BULK | HSO_PORT_DIAG,
+	0
+};
+
+#define default_port_device(vendor, product)	\
+	USB_DEVICE(vendor, product),	\
+		.driver_info = (kernel_ulong_t)default_port_spec
+
+#define icon321_port_device(vendor, product)	\
+	USB_DEVICE(vendor, product),	\
+		.driver_info = (kernel_ulong_t)icon321_port_spec
+
+/* list of devices we support */
+static const struct usb_device_id hso_ids[] = {
+	{default_port_device(0x0af0, 0x6711)},
+	{default_port_device(0x0af0, 0x6731)},
+	{default_port_device(0x0af0, 0x6751)},
+	{default_port_device(0x0af0, 0x6771)},
+	{default_port_device(0x0af0, 0x6791)},
+	{default_port_device(0x0af0, 0x6811)},
+	{default_port_device(0x0af0, 0x6911)},
+	{default_port_device(0x0af0, 0x6951)},
+	{default_port_device(0x0af0, 0x6971)},
+	{default_port_device(0x0af0, 0x7011)},
+	{default_port_device(0x0af0, 0x7031)},
+	{default_port_device(0x0af0, 0x7051)},
+	{default_port_device(0x0af0, 0x7071)},
+	{default_port_device(0x0af0, 0x7111)},
+	{default_port_device(0x0af0, 0x7211)},
+	{default_port_device(0x0af0, 0x7251)},
+	{default_port_device(0x0af0, 0x7271)},
+	{default_port_device(0x0af0, 0x7311)},
+	{default_port_device(0x0af0, 0xc031)},	/* Icon-Edge */
+	{icon321_port_device(0x0af0, 0xd013)},	/* Module HSxPA */
+	{icon321_port_device(0x0af0, 0xd031)},	/* Icon-321 */
+	{default_port_device(0x0af0, 0xd033)},	/* Icon-322 */
+	{USB_DEVICE(0x0af0, 0x7301)},		/* GE40x */
+	{USB_DEVICE(0x0af0, 0x7361)},		/* GE40x */
+	{USB_DEVICE(0x0af0, 0x7401)},		/* GI 0401 */
+	{USB_DEVICE(0x0af0, 0x7501)},		/* GTM 382 */
+	{USB_DEVICE(0x0af0, 0x7601)},		/* GE40x */
+	{}
+};
+MODULE_DEVICE_TABLE(usb, hso_ids);
+
+/* Sysfs attribute */
+static ssize_t hso_sysfs_show_porttype(struct device *dev,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct hso_device *hso_dev = dev->driver_data;
+	char *port_name;
+
+	if (!hso_dev)
+		return 0;
+
+	switch (hso_dev->port_spec & HSO_PORT_MASK) {
+	case HSO_PORT_CONTROL:
+		port_name = "Control";
+		break;
+	case HSO_PORT_APP:
+		port_name = "Application";
+		break;
+	case HSO_PORT_APP2:
+		port_name = "Application2";
+		break;
+	case HSO_PORT_GPS:
+		port_name = "GPS";
+		break;
+	case HSO_PORT_GPS_CONTROL:
+		port_name = "GPS Control";
+		break;
+	case HSO_PORT_PCSC:
+		port_name = "PCSC";
+		break;
+	case HSO_PORT_DIAG:
+		port_name = "Diagnostic";
+		break;
+	case HSO_PORT_DIAG2:
+		port_name = "Diagnostic2";
+		break;
+	case HSO_PORT_MODEM:
+		port_name = "Modem";
+		break;
+	case HSO_PORT_NETWORK:
+		port_name = "Network";
+		break;
+	default:
+		port_name = "Unknown";
+		break;
+	}
+
+	return sprintf(buf, "%s\n", port_name);
+}
+static DEVICE_ATTR(hsotype, S_IRUGO, hso_sysfs_show_porttype, NULL);
+
+/* converts mux value to a port spec value */
+static u32 hso_mux_to_port(int mux)
+{
+	u32 result;
+
+	switch (mux) {
+	case 0x1:
+		result = HSO_PORT_CONTROL;
+		break;
+	case 0x2:
+		result = HSO_PORT_APP;
+		break;
+	case 0x4:
+		result = HSO_PORT_PCSC;
+		break;
+	case 0x8:
+		result = HSO_PORT_GPS;
+		break;
+	case 0x10:
+		result = HSO_PORT_APP2;
+		break;
+	default:
+		result = HSO_PORT_NO_PORT;
+	}
+	return result;
+}
+
+/* converts port spec value to a mux value */
+static u32 hso_port_to_mux(int port)
+{
+	u32 result;
+
+	switch (port & HSO_PORT_MASK) {
+	case HSO_PORT_CONTROL:
+		result = 0x0;
+		break;
+	case HSO_PORT_APP:
+		result = 0x1;
+		break;
+	case HSO_PORT_PCSC:
+		result = 0x2;
+		break;
+	case HSO_PORT_GPS:
+		result = 0x3;
+		break;
+	case HSO_PORT_APP2:
+		result = 0x4;
+		break;
+	default:
+		result = 0x0;
+	}
+	return result;
+}
+
+static struct hso_serial *get_serial_by_shared_int_and_type(
+					struct hso_shared_int *shared_int,
+					int mux)
+{
+	int i, port;
+
+	port = hso_mux_to_port(mux);
+
+	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
+		if (serial_table[i]
+		    && (dev2ser(serial_table[i])->shared_int == shared_int)
+		    && ((serial_table[i]->port_spec & HSO_PORT_MASK) == port)) {
+			return dev2ser(serial_table[i]);
+		}
+	}
+
+	return NULL;
+}
+
+static struct hso_serial *get_serial_by_index(unsigned index)
+{
+	struct hso_serial *serial;
+	unsigned long flags;
+
+	if (!serial_table[index])
+		return NULL;
+	spin_lock_irqsave(&serial_table_lock, flags);
+	serial = dev2ser(serial_table[index]);
+	spin_unlock_irqrestore(&serial_table_lock, flags);
+
+	return serial;
+}
+
+static int get_free_serial_index(void)
+{
+	int index;
+	unsigned long flags;
+
+	spin_lock_irqsave(&serial_table_lock, flags);
+	for (index = 0; index < HSO_SERIAL_TTY_MINORS; index++) {
+		if (serial_table[index] == NULL) {
+			spin_unlock_irqrestore(&serial_table_lock, flags);
+			return index;
+		}
+	}
+	spin_unlock_irqrestore(&serial_table_lock, flags);
+
+	printk(KERN_ERR "%s: no free serial devices in table\n", __func__);
+	return -1;
+}
+
+static void set_serial_by_index(unsigned index, struct hso_serial *serial)
+{
+	unsigned long flags;
+	spin_lock_irqsave(&serial_table_lock, flags);
+	if (serial)
+		serial_table[index] = serial->parent;
+	else
+		serial_table[index] = NULL;
+	spin_unlock_irqrestore(&serial_table_lock, flags);
+}
+
+/* log a meaningfull explanation of an USB status */
+static void log_usb_status(int status, const char *function)
+{
+	char *explanation;
+
+	switch (status) {
+	case -ENODEV:
+		explanation = "no device";
+		break;
+	case -ENOENT:
+		explanation = "endpoint not enabled";
+		break;
+	case -EPIPE:
+		explanation = "endpoint stalled";
+		break;
+	case -ENOSPC:
+		explanation = "not enough bandwidth";
+		break;
+	case -ESHUTDOWN:
+		explanation = "device disabled";
+		break;
+	case -EHOSTUNREACH:
+		explanation = "device suspended";
+		break;
+	case -EINVAL:
+	case -EAGAIN:
+	case -EFBIG:
+	case -EMSGSIZE:
+		explanation = "internal error";
+		break;
+	default:
+		explanation = "unknown status";
+		break;
+	}
+	D1("%s: received USB status - %s (%d)", function, explanation, status);
+}
+
+/* Network interface functions */
+
+/* called when net interface is brought up by ifconfig */
+static int hso_net_open(struct net_device *net)
+{
+	struct hso_net *odev = netdev_priv(net);
+	unsigned long flags = 0;
+
+	if (!odev) {
+		dev_err(&net->dev, "No net device !\n");
+		return -ENODEV;
+	}
+
+	odev->skb_tx_buf = NULL;
+
+	/* setup environment */
+	spin_lock_irqsave(&odev->net_lock, flags);
+	odev->rx_parse_state = WAIT_IP;
+	odev->rx_buf_size = 0;
+	odev->rx_buf_missing = sizeof(struct iphdr);
+	spin_unlock_irqrestore(&odev->net_lock, flags);
+
+	hso_start_net_device(odev->parent);
+
+	/* We are up and running. */
+	set_bit(HSO_NET_RUNNING, &odev->flags);
+
+	/* Tell the kernel we are ready to start receiving from it */
+	netif_start_queue(net);
+
+	return 0;
+}
+
+/* called when interface is brought down by ifconfig */
+static int hso_net_close(struct net_device *net)
+{
+	struct hso_net *odev = netdev_priv(net);
+
+	/* we don't need the queue anymore */
+	netif_stop_queue(net);
+	/* no longer running */
+	clear_bit(HSO_NET_RUNNING, &odev->flags);
+
+	hso_stop_net_device(odev->parent);
+
+	/* done */
+	return 0;
+}
+
+/* USB tells is xmit done, we should start the netqueue again */
+static void write_bulk_callback(struct urb *urb)
+{
+	struct hso_net *odev = urb->context;
+	int status = urb->status;
+
+	/* Sanity check */
+	if (!odev || !test_bit(HSO_NET_RUNNING, &odev->flags)) {
+		dev_err(&urb->dev->dev, "%s: device not running\n", __func__);
+		return;
+	}
+
+	/* Do we still have a valid kernel network device? */
+	if (!netif_device_present(odev->net)) {
+		dev_err(&urb->dev->dev, "%s: net device not present\n",
+			__func__);
+		return;
+	}
+
+	/* log status, but don't act on it, we don't need to resubmit anything
+	 * anyhow */
+	if (status)
+		log_usb_status(status, __func__);
+
+	hso_put_activity(odev->parent);
+
+	/* Tell the network interface we are ready for another frame */
+	netif_wake_queue(odev->net);
+}
+
+/* called by kernel when we need to transmit a packet */
+static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
+{
+	struct hso_net *odev = netdev_priv(net);
+	int result;
+
+	/* Tell the kernel, "No more frames 'til we are done with this one." */
+	netif_stop_queue(net);
+	if (hso_get_activity(odev->parent) == -EAGAIN) {
+		odev->skb_tx_buf = skb;
+		return 0;
+	}
+
+	/* log if asked */
+	DUMP1(skb->data, skb->len);
+	/* Copy it from kernel memory to OUR memory */
+	memcpy(odev->mux_bulk_tx_buf, skb->data, skb->len);
+	D1("len: %d/%d", skb->len, MUX_BULK_TX_BUF_SIZE);
+
+	/* Fill in the URB for shipping it out. */
+	usb_fill_bulk_urb(odev->mux_bulk_tx_urb,
+			  odev->parent->usb,
+			  usb_sndbulkpipe(odev->parent->usb,
+					  odev->out_endp->
+					  bEndpointAddress & 0x7F),
+			  odev->mux_bulk_tx_buf, skb->len, write_bulk_callback,
+			  odev);
+
+	/* Deal with the Zero Length packet problem, I hope */
+	odev->mux_bulk_tx_urb->transfer_flags |= URB_ZERO_PACKET;
+
+	/* Send the URB on its merry way. */
+	result = usb_submit_urb(odev->mux_bulk_tx_urb, GFP_ATOMIC);
+	if (result) {
+		dev_warn(&odev->parent->interface->dev,
+			"failed mux_bulk_tx_urb %d", result);
+		net->stats.tx_errors++;
+		netif_start_queue(net);
+	} else {
+		net->stats.tx_packets++;
+		net->stats.tx_bytes += skb->len;
+		/* And tell the kernel when the last transmit started. */
+		net->trans_start = jiffies;
+	}
+	dev_kfree_skb(skb);
+	/* we're done */
+	return result;
+}
+
+static void hso_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
+{
+	struct hso_net *odev = netdev_priv(net);
+
+	strncpy(info->driver, driver_name, ETHTOOL_BUSINFO_LEN);
+	strncpy(info->version, DRIVER_VERSION, ETHTOOL_BUSINFO_LEN);
+	usb_make_path(odev->parent->usb, info->bus_info, sizeof info->bus_info);
+}
+
+static struct ethtool_ops ops = {
+	.get_drvinfo = hso_get_drvinfo,
+	.get_link = ethtool_op_get_link
+};
+
+/* called when a packet did not ack after watchdogtimeout */
+static void hso_net_tx_timeout(struct net_device *net)
+{
+	struct hso_net *odev = netdev_priv(net);
+
+	if (!odev)
+		return;
+
+	/* Tell syslog we are hosed. */
+	dev_warn(&net->dev, "Tx timed out.\n");
+
+	/* Tear the waiting frame off the list */
+	if (odev->mux_bulk_tx_urb
+	    && (odev->mux_bulk_tx_urb->status == -EINPROGRESS))
+		usb_unlink_urb(odev->mux_bulk_tx_urb);
+
+	/* Update statistics */
+	net->stats.tx_errors++;
+}
+
+/* make a real packet from the received USB buffer */
+static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
+			unsigned int count, unsigned char is_eop)
+{
+	unsigned short temp_bytes;
+	unsigned short buffer_offset = 0;
+	unsigned short frame_len;
+	unsigned char *tmp_rx_buf;
+
+	/* log if needed */
+	D1("Rx %d bytes", count);
+	DUMP(ip_pkt, min(128, (int)count));
+
+	while (count) {
+		switch (odev->rx_parse_state) {
+		case WAIT_IP:
+			/* waiting for IP header. */
+			/* wanted bytes - size of ip header */
+			temp_bytes =
+			    (count <
+			     odev->rx_buf_missing) ? count : odev->
+			    rx_buf_missing;
+
+			memcpy(((unsigned char *)(&odev->rx_ip_hdr)) +
+			       odev->rx_buf_size, ip_pkt + buffer_offset,
+			       temp_bytes);
+
+			odev->rx_buf_size += temp_bytes;
+			buffer_offset += temp_bytes;
+			odev->rx_buf_missing -= temp_bytes;
+			count -= temp_bytes;
+
+			if (!odev->rx_buf_missing) {
+				/* header is complete allocate an sk_buffer and
+				 * continue to WAIT_DATA */
+				frame_len = ntohs(odev->rx_ip_hdr.tot_len);
+
+				if ((frame_len > DEFAULT_MRU) ||
+				    (frame_len < sizeof(struct iphdr))) {
+					dev_err(&odev->net->dev,
+						"Invalid frame (%d) length\n",
+						frame_len);
+					odev->rx_parse_state = WAIT_SYNC;
+					continue;
+				}
+				/* Allocate an sk_buff */
+				odev->skb_rx_buf = dev_alloc_skb(frame_len);
+				if (!odev->skb_rx_buf) {
+					/* We got no receive buffer. */
+					D1("could not allocate memory");
+					odev->rx_parse_state = WAIT_SYNC;
+					return;
+				}
+				/* Here's where it came from */
+				odev->skb_rx_buf->dev = odev->net;
+
+				/* Copy what we got so far. make room for iphdr
+				 * after tail. */
+				tmp_rx_buf =
+				    skb_put(odev->skb_rx_buf,
+					    sizeof(struct iphdr));
+				memcpy(tmp_rx_buf, (char *)&(odev->rx_ip_hdr),
+				       sizeof(struct iphdr));
+
+				/* ETH_HLEN */
+				odev->rx_buf_size = sizeof(struct iphdr);
+
+				/* Filip actually use .tot_len */
+				odev->rx_buf_missing =
+				    frame_len - sizeof(struct iphdr);
+				odev->rx_parse_state = WAIT_DATA;
+			}
+			break;
+
+		case WAIT_DATA:
+			temp_bytes = (count < odev->rx_buf_missing)
+					? count : odev->rx_buf_missing;
+
+			/* Copy the rest of the bytes that are left in the
+			 * buffer into the waiting sk_buf. */
+			/* Make room for temp_bytes after tail. */
+			tmp_rx_buf = skb_put(odev->skb_rx_buf, temp_bytes);
+			memcpy(tmp_rx_buf, ip_pkt + buffer_offset, temp_bytes);
+
+			odev->rx_buf_missing -= temp_bytes;
+			count -= temp_bytes;
+			buffer_offset += temp_bytes;
+			odev->rx_buf_size += temp_bytes;
+			if (!odev->rx_buf_missing) {
+				/* Packet is complete. Inject into stack. */
+				/* We have IP packet here */
+				odev->skb_rx_buf->protocol =
+						__constant_htons(ETH_P_IP);
+				/* don't check it */
+				odev->skb_rx_buf->ip_summed =
+					CHECKSUM_UNNECESSARY;
+
+				skb_reset_mac_header(odev->skb_rx_buf);
+
+				/* Ship it off to the kernel */
+				netif_rx(odev->skb_rx_buf);
+				/* No longer our buffer. */
+				odev->skb_rx_buf = NULL;
+
+				/* update out statistics */
+				odev->net->stats.rx_packets++;
+
+				odev->net->stats.rx_bytes += odev->rx_buf_size;
+
+				odev->rx_buf_size = 0;
+				odev->rx_buf_missing = sizeof(struct iphdr);
+				odev->rx_parse_state = WAIT_IP;
+			}
+			break;
+
+		case WAIT_SYNC:
+			D1(" W_S");
+			count = 0;
+			break;
+		default:
+			D1(" ");
+			count--;
+			break;
+		}
+	}
+
+	/* Recovery mechanism for WAIT_SYNC state. */
+	if (is_eop) {
+		if (odev->rx_parse_state == WAIT_SYNC) {
+			odev->rx_parse_state = WAIT_IP;
+			odev->rx_buf_size = 0;
+			odev->rx_buf_missing = sizeof(struct iphdr);
+		}
+	}
+}
+
+/* Moving data from usb to kernel (in interrupt state) */
+static void read_bulk_callback(struct urb *urb)
+{
+	struct hso_net *odev = urb->context;
+	struct net_device *net;
+	int result;
+	int status = urb->status;
+
+	/* is al ok?  (Filip: Who's Al ?) */
+	if (status) {
+		log_usb_status(status, __func__);
+		return;
+	}
+
+	/* Sanity check */
+	if (!odev || !test_bit(HSO_NET_RUNNING, &odev->flags)) {
+		D1("BULK IN callback but driver is not active!");
+		return;
+	}
+	usb_mark_last_busy(urb->dev);
+
+	net = odev->net;
+
+	if (!netif_device_present(net)) {
+		/* Somebody killed our network interface... */
+		return;
+	}
+
+	if (odev->parent->port_spec & HSO_INFO_CRC_BUG) {
+		u32 rest;
+		u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
+		rest = urb->actual_length % odev->in_endp->wMaxPacketSize;
+		if (((rest == 5) || (rest == 6))
+		    && !memcmp(((u8 *) urb->transfer_buffer) +
+			       urb->actual_length - 4, crc_check, 4)) {
+			urb->actual_length -= 4;
+		}
+	}
+
+	/* do we even have a packet? */
+	if (urb->actual_length) {
+		/* Handle the IP stream, add header and push it onto network
+		 * stack if the packet is complete. */
+		spin_lock(&odev->net_lock);
+		packetizeRx(odev, urb->transfer_buffer, urb->actual_length,
+			    (urb->transfer_buffer_length >
+			     urb->actual_length) ? 1 : 0);
+		spin_unlock(&odev->net_lock);
+	}
+
+	/* We are done with this URB, resubmit it. Prep the USB to wait for
+	 * another frame. Reuse same as received. */
+	usb_fill_bulk_urb(urb,
+			  odev->parent->usb,
+			  usb_rcvbulkpipe(odev->parent->usb,
+					  odev->in_endp->
+					  bEndpointAddress & 0x7F),
+			  urb->transfer_buffer, MUX_BULK_RX_BUF_SIZE,
+			  read_bulk_callback, odev);
+
+	/* Give this to the USB subsystem so it can tell us when more data
+	 * arrives. */
+	result = usb_submit_urb(urb, GFP_ATOMIC);
+	if (result)
+		dev_warn(&odev->parent->interface->dev,
+			 "%s failed submit mux_bulk_rx_urb %d", __func__,
+			 result);
+}
+
+/* Serial driver functions */
+
+static void _hso_serial_set_termios(struct tty_struct *tty,
+				    struct ktermios *old)
+{
+	struct hso_serial *serial = get_serial_by_tty(tty);
+	struct ktermios *termios;
+
+	if ((!tty) || (!tty->termios) || (!serial)) {
+		printk(KERN_ERR "%s: no tty structures", __func__);
+		return;
+	}
+
+	D4("port %d", serial->minor);
+
+	/*
+	 * The default requirements for this device are:
+	 */
+	termios = tty->termios;
+	termios->c_iflag &=
+		~(IGNBRK	/* disable ignore break */
+		| BRKINT	/* disable break causes interrupt */
+		| PARMRK	/* disable mark parity errors */
+		| ISTRIP	/* disable clear high bit of input characters */
+		| INLCR		/* disable translate NL to CR */
+		| IGNCR		/* disable ignore CR */
+		| ICRNL		/* disable translate CR to NL */
+		| IXON);	/* disable enable XON/XOFF flow control */
+
+	/* disable postprocess output characters */
+	termios->c_oflag &= ~OPOST;
+
+	termios->c_lflag &=
+		~(ECHO		/* disable echo input characters */
+		| ECHONL	/* disable echo new line */
+		| ICANON	/* disable erase, kill, werase, and rprnt
+				   special characters */
+		| ISIG		/* disable interrupt, quit, and suspend special
+				   characters */
+		| IEXTEN);	/* disable non-POSIX special characters */
+
+	termios->c_cflag &=
+		~(CSIZE		/* no size */
+		| PARENB	/* disable parity bit */
+		| CBAUD		/* clear current baud rate */
+		| CBAUDEX);	/* clear current buad rate */
+
+	termios->c_cflag |= CS8;	/* character size 8 bits */
+
+	/* baud rate 115200 */
+	tty_encode_baud_rate(serial->tty, 115200, 115200);
+
+	/*
+	 * Force low_latency on; otherwise the pushes are scheduled;
+	 * this is bad as it opens up the possibility of dropping bytes
+	 * on the floor.  We don't want to drop bytes on the floor. :)
+	 */
+	serial->tty->low_latency = 1;
+	return;
+}
+
+/* open the requested serial port */
+static int hso_serial_open(struct tty_struct *tty, struct file *filp)
+{
+	struct hso_serial *serial = get_serial_by_index(tty->index);
+	int result;
+
+	/* sanity check */
+	if (serial == NULL || serial->magic != HSO_SERIAL_MAGIC) {
+		tty->driver_data = NULL;
+		D1("Failed to open port");
+		return -ENODEV;
+	}
+
+	mutex_lock(&serial->parent->mutex);
+	result = usb_autopm_get_interface(serial->parent->interface);
+	if (result < 0)
+		goto err_out;
+
+	D1("Opening %d", serial->minor);
+	kref_get(&serial->parent->ref);
+
+	/* setup */
+	tty->driver_data = serial;
+	serial->tty = tty;
+
+	/* check for port allready opened, if not set the termios */
+	serial->open_count++;
+	if (serial->open_count == 1) {
+		tty->low_latency = 1;
+		serial->flags = 0;
+		/* Force default termio settings */
+		_hso_serial_set_termios(tty, NULL);
+		result = hso_start_serial_device(serial->parent, GFP_KERNEL);
+		if (result) {
+			hso_stop_serial_device(serial->parent);
+			serial->open_count--;
+			kref_put(&serial->parent->ref, hso_serial_ref_free);
+		}
+	} else {
+		D1("Port was already open");
+	}
+
+	usb_autopm_put_interface(serial->parent->interface);
+
+	/* done */
+	if (result)
+		hso_serial_tiocmset(tty, NULL, TIOCM_RTS | TIOCM_DTR, 0);
+err_out:
+	mutex_unlock(&serial->parent->mutex);
+	return result;
+}
+
+/* close the requested serial port */
+static void hso_serial_close(struct tty_struct *tty, struct file *filp)
+{
+	struct hso_serial *serial = tty->driver_data;
+	u8 usb_gone;
+
+	D1("Closing serial port");
+
+	mutex_lock(&serial->parent->mutex);
+	usb_gone = serial->parent->usb_gone;
+
+	if (!usb_gone)
+		usb_autopm_get_interface(serial->parent->interface);
+
+	/* reset the rts and dtr */
+	/* do the actual close */
+	serial->open_count--;
+	if (serial->open_count <= 0) {
+		kref_put(&serial->parent->ref, hso_serial_ref_free);
+		serial->open_count = 0;
+		if (serial->tty) {
+			serial->tty->driver_data = NULL;
+			serial->tty = NULL;
+		}
+		if (!usb_gone)
+			hso_stop_serial_device(serial->parent);
+	}
+	if (!usb_gone)
+		usb_autopm_put_interface(serial->parent->interface);
+	mutex_unlock(&serial->parent->mutex);
+}
+
+/* close the requested serial port */
+static int hso_serial_write(struct tty_struct *tty, const unsigned char *buf,
+			    int count)
+{
+	struct hso_serial *serial = get_serial_by_tty(tty);
+	int space, tx_bytes;
+	unsigned long flags;
+
+	/* sanity check */
+	if (serial == NULL) {
+		printk(KERN_ERR "%s: serial is NULL\n", __func__);
+		return -ENODEV;
+	}
+
+	spin_lock_irqsave(&serial->serial_lock, flags);
+
+	space = serial->tx_data_length - serial->tx_buffer_count;
+	tx_bytes = (count < space) ? count : space;
+
+	if (!tx_bytes)
+		goto out;
+
+	memcpy(serial->tx_buffer + serial->tx_buffer_count, buf, tx_bytes);
+	serial->tx_buffer_count += tx_bytes;
+
+out:
+	spin_unlock_irqrestore(&serial->serial_lock, flags);
+
+	hso_kick_transmit(serial);
+	/* done */
+	return tx_bytes;
+}
+
+/* how much room is there for writing */
+static int hso_serial_write_room(struct tty_struct *tty)
+{
+	struct hso_serial *serial = get_serial_by_tty(tty);
+	int room;
+	unsigned long flags;
+
+	spin_lock_irqsave(&serial->serial_lock, flags);
+	room = serial->tx_data_length - serial->tx_buffer_count;
+	spin_unlock_irqrestore(&serial->serial_lock, flags);
+
+	/* return free room */
+	return room;
+}
+
+/* setup the term */
+static void hso_serial_set_termios(struct tty_struct *tty, struct ktermios *old)
+{
+	struct hso_serial *serial = get_serial_by_tty(tty);
+	unsigned long flags;
+
+	if (old)
+		D5("Termios called with: cflags new[%d] - old[%d]",
+		   tty->termios->c_cflag, old->c_cflag);
+
+	/* the actual setup */
+	spin_lock_irqsave(&serial->serial_lock, flags);
+	if (serial->open_count)
+		_hso_serial_set_termios(tty, old);
+	else
+		tty->termios = old;
+	spin_unlock_irqrestore(&serial->serial_lock, flags);
+
+	/* done */
+	return;
+}
+
+/* how many characters in the buffer */
+static int hso_serial_chars_in_buffer(struct tty_struct *tty)
+{
+	struct hso_serial *serial = get_serial_by_tty(tty);
+	int chars;
+	unsigned long flags;
+
+	/* sanity check */
+	if (serial == NULL)
+		return 0;
+
+	spin_lock_irqsave(&serial->serial_lock, flags);
+	chars = serial->tx_buffer_count;
+	spin_unlock_irqrestore(&serial->serial_lock, flags);
+
+	return chars;
+}
+
+static int hso_serial_tiocmget(struct tty_struct *tty, struct file *file)
+{
+	unsigned int value;
+	struct hso_serial *serial = get_serial_by_tty(tty);
+	unsigned long flags;
+
+	/* sanity check */
+	if (!serial) {
+		D1("no tty structures");
+		return -EINVAL;
+	}
+
+	spin_lock_irqsave(&serial->serial_lock, flags);
+	value = ((serial->rts_state) ? TIOCM_RTS : 0) |
+	    ((serial->dtr_state) ? TIOCM_DTR : 0);
+	spin_unlock_irqrestore(&serial->serial_lock, flags);
+
+	return value;
+}
+
+static int hso_serial_tiocmset(struct tty_struct *tty, struct file *file,
+			       unsigned int set, unsigned int clear)
+{
+	int val = 0;
+	unsigned long flags;
+	int if_num;
+	struct hso_serial *serial = get_serial_by_tty(tty);
+
+	/* sanity check */
+	if (!serial) {
+		D1("no tty structures");
+		return -EINVAL;
+	}
+	if_num = serial->parent->interface->altsetting->desc.bInterfaceNumber;
+
+	spin_lock_irqsave(&serial->serial_lock, flags);
+	if (set & TIOCM_RTS)
+		serial->rts_state = 1;
+	if (set & TIOCM_DTR)
+		serial->dtr_state = 1;
+
+	if (clear & TIOCM_RTS)
+		serial->rts_state = 0;
+	if (clear & TIOCM_DTR)
+		serial->dtr_state = 0;
+
+	if (serial->dtr_state)
+		val |= 0x01;
+	if (serial->rts_state)
+		val |= 0x02;
+
+	spin_unlock_irqrestore(&serial->serial_lock, flags);
+
+	return usb_control_msg(serial->parent->usb,
+			       usb_rcvctrlpipe(serial->parent->usb, 0), 0x22,
+			       0x21, val, if_num, NULL, 0,
+			       USB_CTRL_SET_TIMEOUT);
+}
+
+/* starts a transmit */
+static void hso_kick_transmit(struct hso_serial *serial)
+{
+	u8 *temp;
+	unsigned long flags;
+	int res;
+
+	spin_lock_irqsave(&serial->serial_lock, flags);
+	if (!serial->tx_buffer_count)
+		goto out;
+
+	if (serial->tx_urb_used)
+		goto out;
+
+	/* Wakeup USB interface if necessary */
+	if (hso_get_activity(serial->parent) == -EAGAIN)
+		goto out;
+
+	/* Switch pointers around to avoid memcpy */
+	temp = serial->tx_buffer;
+	serial->tx_buffer = serial->tx_data;
+	serial->tx_data = temp;
+	serial->tx_data_count = serial->tx_buffer_count;
+	serial->tx_buffer_count = 0;
+
+	/* If temp is set, it means we switched buffers */
+	if (temp && serial->write_data) {
+		res = serial->write_data(serial);
+		if (res >= 0)
+			serial->tx_urb_used = 1;
+	}
+out:
+	spin_unlock_irqrestore(&serial->serial_lock, flags);
+}
+
+/* make a request (for reading and writing data to muxed serial port) */
+static int mux_device_request(struct hso_serial *serial, u8 type, u16 port,
+			      struct urb *ctrl_urb,
+			      struct usb_ctrlrequest *ctrl_req,
+			      u8 *ctrl_urb_data, u32 size)
+{
+	int result;
+	int pipe;
+
+	/* Sanity check */
+	if (!serial || !ctrl_urb || !ctrl_req) {
+		printk(KERN_ERR "%s: Wrong arguments\n", __func__);
+		return -EINVAL;
+	}
+
+	/* initialize */
+	ctrl_req->wValue = 0;
+	ctrl_req->wIndex = hso_port_to_mux(port);
+	ctrl_req->wLength = size;
+
+	if (type == USB_CDC_GET_ENCAPSULATED_RESPONSE) {
+		/* Reading command */
+		ctrl_req->bRequestType = USB_DIR_IN |
+					 USB_TYPE_OPTION_VENDOR |
+					 USB_RECIP_INTERFACE;
+		ctrl_req->bRequest = USB_CDC_GET_ENCAPSULATED_RESPONSE;
+		pipe = usb_rcvctrlpipe(serial->parent->usb, 0);
+	} else {
+		/* Writing command */
+		ctrl_req->bRequestType = USB_DIR_OUT |
+					 USB_TYPE_OPTION_VENDOR |
+					 USB_RECIP_INTERFACE;
+		ctrl_req->bRequest = USB_CDC_SEND_ENCAPSULATED_COMMAND;
+		pipe = usb_sndctrlpipe(serial->parent->usb, 0);
+	}
+	/* syslog */
+	D2("%s command (%02x) len: %d, port: %d",
+	   type == USB_CDC_GET_ENCAPSULATED_RESPONSE ? "Read" : "Write",
+	   ctrl_req->bRequestType, ctrl_req->wLength, port);
+
+	/* Load ctrl urb */
+	ctrl_urb->transfer_flags = 0;
+	usb_fill_control_urb(ctrl_urb,
+			     serial->parent->usb,
+			     pipe,
+			     (u8 *) ctrl_req,
+			     ctrl_urb_data, size, ctrl_callback, serial);
+	/* Send it on merry way */
+	result = usb_submit_urb(ctrl_urb, GFP_ATOMIC);
+	if (result) {
+		dev_err(&ctrl_urb->dev->dev,
+			"%s failed submit ctrl_urb %d type %d", __func__,
+			result, type);
+		return result;
+	}
+
+	/* done */
+	return size;
+}
+
+/* called by intr_callback when read occurs */
+static int hso_mux_serial_read(struct hso_serial *serial)
+{
+	if (!serial)
+		return -EINVAL;
+
+	/* clean data */
+	memset(serial->rx_data[0], 0, CTRL_URB_RX_SIZE);
+	/* make the request */
+
+	if (serial->num_rx_urbs != 1) {
+		dev_err(&serial->parent->interface->dev,
+			"ERROR: mux'd reads with multiple buffers "
+			"not possible\n");
+		return 0;
+	}
+	return mux_device_request(serial,
+				  USB_CDC_GET_ENCAPSULATED_RESPONSE,
+				  serial->parent->port_spec & HSO_PORT_MASK,
+				  serial->rx_urb[0],
+				  &serial->ctrl_req_rx,
+				  serial->rx_data[0], serial->rx_data_length);
+}
+
+/* used for muxed serial port callback (muxed serial read) */
+static void intr_callback(struct urb *urb)
+{
+	struct hso_shared_int *shared_int = urb->context;
+	struct hso_serial *serial;
+	unsigned char *port_req;
+	int status = urb->status;
+	int i;
+
+	usb_mark_last_busy(urb->dev);
+
+	/* sanity check */
+	if (!shared_int)
+		return;
+
+	/* status check */
+	if (status) {
+		log_usb_status(status, __func__);
+		return;
+	}
+	D4("\n--- Got intr callback 0x%02X ---", status);
+
+	/* what request? */
+	port_req = urb->transfer_buffer;
+	D4(" port_req = 0x%.2X\n", *port_req);
+	/* loop over all muxed ports to find the one sending this */
+	for (i = 0; i < 8; i++) {
+		/* max 8 channels on MUX */
+		if (*port_req & (1 << i)) {
+			serial = get_serial_by_shared_int_and_type(shared_int,
+								   (1 << i));
+			if (serial != NULL) {
+				D1("Pending read interrupt on port %d\n", i);
+				if (!test_and_set_bit(HSO_SERIAL_FLAG_RX_SENT,
+						      &serial->flags)) {
+					/* Setup and send a ctrl req read on
+					 * port i */
+					hso_mux_serial_read(serial);
+				} else {
+					D1("Already pending a read on "
+					   "port %d\n", i);
+				}
+			}
+		}
+	}
+	/* Resubmit interrupt urb */
+	hso_mux_submit_intr_urb(shared_int, urb->dev, GFP_ATOMIC);
+}
+
+/* called for writing to muxed serial port */
+static int hso_mux_serial_write_data(struct hso_serial *serial)
+{
+	if (NULL == serial)
+		return -EINVAL;
+
+	return mux_device_request(serial,
+				  USB_CDC_SEND_ENCAPSULATED_COMMAND,
+				  serial->parent->port_spec & HSO_PORT_MASK,
+				  serial->tx_urb,
+				  &serial->ctrl_req_tx,
+				  serial->tx_data, serial->tx_data_count);
+}
+
+/* write callback for Diag and CS port */
+static void hso_std_serial_write_bulk_callback(struct urb *urb)
+{
+	struct hso_serial *serial = urb->context;
+	int status = urb->status;
+
+	/* sanity check */
+	if (!serial) {
+		D1("serial == NULL");
+		return;
+	}
+
+	spin_lock(&serial->serial_lock);
+	serial->tx_urb_used = 0;
+	spin_unlock(&serial->serial_lock);
+	if (status) {
+		log_usb_status(status, __func__);
+		return;
+	}
+	hso_put_activity(serial->parent);
+	tty_wakeup(serial->tty);
+	hso_kick_transmit(serial);
+
+	D1(" ");
+	return;
+}
+
+/* called for writing diag or CS serial port */
+static int hso_std_serial_write_data(struct hso_serial *serial)
+{
+	int count = serial->tx_data_count;
+	int result;
+
+	usb_fill_bulk_urb(serial->tx_urb,
+			  serial->parent->usb,
+			  usb_sndbulkpipe(serial->parent->usb,
+					  serial->out_endp->
+					  bEndpointAddress & 0x7F),
+			  serial->tx_data, serial->tx_data_count,
+			  hso_std_serial_write_bulk_callback, serial);
+
+	result = usb_submit_urb(serial->tx_urb, GFP_ATOMIC);
+	if (result) {
+		dev_warn(&serial->parent->usb->dev,
+			 "Failed to submit urb - res %d\n", result);
+		return result;
+	}
+
+	return count;
+}
+
+/* callback after read or write on muxed serial port */
+static void ctrl_callback(struct urb *urb)
+{
+	struct hso_serial *serial = urb->context;
+	struct usb_ctrlrequest *req;
+	int status = urb->status;
+
+	/* sanity check */
+	if (!serial)
+		return;
+
+	spin_lock(&serial->serial_lock);
+	serial->tx_urb_used = 0;
+	spin_unlock(&serial->serial_lock);
+	if (status) {
+		log_usb_status(status, __func__);
+		return;
+	}
+
+	/* what request? */
+	req = (struct usb_ctrlrequest *)(urb->setup_packet);
+	D4("\n--- Got muxed ctrl callback 0x%02X ---", status);
+	D4("Actual length of urb = %d\n", urb->actual_length);
+	DUMP1(urb->transfer_buffer, urb->actual_length);
+
+	if (req->bRequestType ==
+	    (USB_DIR_IN | USB_TYPE_OPTION_VENDOR | USB_RECIP_INTERFACE)) {
+		/* response to a read command */
+		if (serial->open_count > 0) {
+			/* handle RX data the normal way */
+			put_rxbuf_data(urb, serial);
+		}
+
+		/* Re issue a read as long as we receive data. */
+		if (urb->actual_length != 0)
+			hso_mux_serial_read(serial);
+		else
+			clear_bit(HSO_SERIAL_FLAG_RX_SENT, &serial->flags);
+	} else {
+		hso_put_activity(serial->parent);
+		tty_wakeup(serial->tty);
+		/* response to a write command */
+		hso_kick_transmit(serial);
+	}
+}
+
+/* handle RX data for serial port */
+static void put_rxbuf_data(struct urb *urb, struct hso_serial *serial)
+{
+	struct tty_struct *tty = serial->tty;
+
+	/* Sanity check */
+	if (urb == NULL || serial == NULL) {
+		D1("serial = NULL");
+		return;
+	}
+
+	/* Push data to tty */
+	if (tty && urb->actual_length) {
+		D1("data to push to tty");
+		tty_insert_flip_string(tty, urb->transfer_buffer,
+				       urb->actual_length);
+		tty_flip_buffer_push(tty);
+	}
+}
+
+/* read callback for Diag and CS port */
+static void hso_std_serial_read_bulk_callback(struct urb *urb)
+{
+	struct hso_serial *serial = urb->context;
+	int result;
+	int status = urb->status;
+
+	/* sanity check */
+	if (!serial) {
+		D1("serial == NULL");
+		return;
+	} else if (status) {
+		log_usb_status(status, __func__);
+		return;
+	}
+
+	D4("\n--- Got serial_read_bulk callback %02x ---", status);
+	D1("Actual length = %d\n", urb->actual_length);
+	DUMP1(urb->transfer_buffer, urb->actual_length);
+
+	/* Anyone listening? */
+	if (serial->open_count == 0)
+		return;
+
+	if (status == 0) {
+		if (serial->parent->port_spec & HSO_INFO_CRC_BUG) {
+			u32 rest;
+			u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
+			rest =
+			    urb->actual_length %
+			    serial->in_endp->wMaxPacketSize;
+			if (((rest == 5) || (rest == 6))
+			    && !memcmp(((u8 *) urb->transfer_buffer) +
+				       urb->actual_length - 4, crc_check, 4)) {
+				urb->actual_length -= 4;
+			}
+		}
+		/* Valid data, handle RX data */
+		put_rxbuf_data(urb, serial);
+	} else if (status == -ENOENT || status == -ECONNRESET) {
+		/* Unlinked - check for throttled port. */
+		D2("Port %d, successfully unlinked urb", serial->minor);
+	} else {
+		D2("Port %d, status = %d for read urb", serial->minor, status);
+		return;
+	}
+
+	usb_mark_last_busy(urb->dev);
+
+	/* We are done with this URB, resubmit it. Prep the USB to wait for
+	 * another frame */
+	usb_fill_bulk_urb(urb, serial->parent->usb,
+			  usb_rcvbulkpipe(serial->parent->usb,
+					  serial->in_endp->
+					  bEndpointAddress & 0x7F),
+			  urb->transfer_buffer, serial->rx_data_length,
+			  hso_std_serial_read_bulk_callback, serial);
+	/* Give this to the USB subsystem so it can tell us when more data
+	 * arrives. */
+	result = usb_submit_urb(urb, GFP_ATOMIC);
+	if (result) {
+		dev_err(&urb->dev->dev, "%s failed submit serial rx_urb %d",
+			__func__, result);
+	}
+}
+
+/* Base driver functions */
+
+static void hso_log_port(struct hso_device *hso_dev)
+{
+	char *port_type;
+	char port_dev[20];
+
+	switch (hso_dev->port_spec & HSO_PORT_MASK) {
+	case HSO_PORT_CONTROL:
+		port_type = "Control";
+		break;
+	case HSO_PORT_APP:
+		port_type = "Application";
+		break;
+	case HSO_PORT_GPS:
+		port_type = "GPS";
+		break;
+	case HSO_PORT_GPS_CONTROL:
+		port_type = "GPS control";
+		break;
+	case HSO_PORT_APP2:
+		port_type = "Application2";
+		break;
+	case HSO_PORT_PCSC:
+		port_type = "PCSC";
+		break;
+	case HSO_PORT_DIAG:
+		port_type = "Diagnostic";
+		break;
+	case HSO_PORT_DIAG2:
+		port_type = "Diagnostic2";
+		break;
+	case HSO_PORT_MODEM:
+		port_type = "Modem";
+		break;
+	case HSO_PORT_NETWORK:
+		port_type = "Network";
+		break;
+	default:
+		port_type = "Unknown";
+		break;
+	}
+	if ((hso_dev->port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK) {
+		sprintf(port_dev, "%s", dev2net(hso_dev)->net->name);
+	} else
+		sprintf(port_dev, "/dev/%s%d", tty_filename,
+			dev2ser(hso_dev)->minor);
+
+	dev_dbg(&hso_dev->interface->dev, "HSO: Found %s port %s\n",
+		port_type, port_dev);
+}
+
+static int hso_start_net_device(struct hso_device *hso_dev)
+{
+	int i, result = 0;
+	struct hso_net *hso_net = dev2net(hso_dev);
+
+	if (!hso_net)
+		return -ENODEV;
+
+	/* send URBs for all read buffers */
+	for (i = 0; i < MUX_BULK_RX_BUF_COUNT; i++) {
+
+		/* Prep a receive URB */
+		usb_fill_bulk_urb(hso_net->mux_bulk_rx_urb_pool[i],
+				  hso_dev->usb,
+				  usb_rcvbulkpipe(hso_dev->usb,
+						  hso_net->in_endp->
+						  bEndpointAddress & 0x7F),
+				  hso_net->mux_bulk_rx_buf_pool[i],
+				  MUX_BULK_RX_BUF_SIZE, read_bulk_callback,
+				  hso_net);
+
+		/* Put it out there so the device can send us stuff */
+		result = usb_submit_urb(hso_net->mux_bulk_rx_urb_pool[i],
+					GFP_NOIO);
+		if (result)
+			dev_warn(&hso_dev->usb->dev,
+				"%s failed mux_bulk_rx_urb[%d] %d\n", __func__,
+				i, result);
+	}
+
+	return result;
+}
+
+static int hso_stop_net_device(struct hso_device *hso_dev)
+{
+	int i;
+	struct hso_net *hso_net = dev2net(hso_dev);
+
+	if (!hso_net)
+		return -ENODEV;
+
+	for (i = 0; i < MUX_BULK_RX_BUF_COUNT; i++) {
+		if (hso_net->mux_bulk_rx_urb_pool[i])
+			usb_kill_urb(hso_net->mux_bulk_rx_urb_pool[i]);
+
+	}
+	if (hso_net->mux_bulk_tx_urb)
+		usb_kill_urb(hso_net->mux_bulk_tx_urb);
+
+	return 0;
+}
+
+static int hso_start_serial_device(struct hso_device *hso_dev, gfp_t flags)
+{
+	int i, result = 0;
+	struct hso_serial *serial = dev2ser(hso_dev);
+
+	if (!serial)
+		return -ENODEV;
+
+	/* If it is not the MUX port fill in and submit a bulk urb (already
+	 * allocated in hso_serial_start) */
+	if (!(serial->parent->port_spec & HSO_INTF_MUX)) {
+		for (i = 0; i < serial->num_rx_urbs; i++) {
+			usb_fill_bulk_urb(serial->rx_urb[i],
+					  serial->parent->usb,
+					  usb_rcvbulkpipe(serial->parent->usb,
+							  serial->in_endp->
+							  bEndpointAddress &
+							  0x7F),
+					  serial->rx_data[i],
+					  serial->rx_data_length,
+					  hso_std_serial_read_bulk_callback,
+					  serial);
+			result = usb_submit_urb(serial->rx_urb[i], flags);
+			if (result) {
+				dev_warn(&serial->parent->usb->dev,
+					 "Failed to submit urb - res %d\n",
+					 result);
+				break;
+			}
+		}
+	} else {
+		mutex_lock(&serial->shared_int->shared_int_lock);
+		if (!serial->shared_int->use_count) {
+			result =
+			    hso_mux_submit_intr_urb(serial->shared_int,
+						    hso_dev->usb, flags);
+		}
+		serial->shared_int->use_count++;
+		mutex_unlock(&serial->shared_int->shared_int_lock);
+	}
+
+	return result;
+}
+
+static int hso_stop_serial_device(struct hso_device *hso_dev)
+{
+	int i;
+	struct hso_serial *serial = dev2ser(hso_dev);
+
+	if (!serial)
+		return -ENODEV;
+
+	for (i = 0; i < serial->num_rx_urbs; i++) {
+		if (serial->rx_urb[i])
+				usb_kill_urb(serial->rx_urb[i]);
+	}
+
+	if (serial->tx_urb)
+		usb_kill_urb(serial->tx_urb);
+
+	if (serial->shared_int) {
+		mutex_lock(&serial->shared_int->shared_int_lock);
+		if (serial->shared_int->use_count &&
+		    (--serial->shared_int->use_count == 0)) {
+			struct urb *urb;
+
+			urb = serial->shared_int->shared_intr_urb;
+			if (urb)
+				usb_kill_urb(urb);
+		}
+		mutex_unlock(&serial->shared_int->shared_int_lock);
+	}
+
+	return 0;
+}
+
+static void hso_serial_common_free(struct hso_serial *serial)
+{
+	int i;
+
+	if (serial->parent->dev)
+		device_remove_file(serial->parent->dev, &dev_attr_hsotype);
+
+	tty_unregister_device(tty_drv, serial->minor);
+
+	for (i = 0; i < serial->num_rx_urbs; i++) {
+		/* unlink and free RX URB */
+		usb_free_urb(serial->rx_urb[i]);
+		/* free the RX buffer */
+		kfree(serial->rx_data[i]);
+	}
+
+	/* unlink and free TX URB */
+	usb_free_urb(serial->tx_urb);
+	kfree(serial->tx_data);
+}
+
+static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
+				    int rx_size, int tx_size)
+{
+	struct device *dev;
+	int minor;
+	int i;
+
+	minor = get_free_serial_index();
+	if (minor < 0)
+		goto exit;
+
+	/* register our minor number */
+	serial->parent->dev = tty_register_device(tty_drv, minor,
+					&serial->parent->interface->dev);
+	dev = serial->parent->dev;
+	dev->driver_data = serial->parent;
+	i = device_create_file(dev, &dev_attr_hsotype);
+
+	/* fill in specific data for later use */
+	serial->minor = minor;
+	serial->magic = HSO_SERIAL_MAGIC;
+	spin_lock_init(&serial->serial_lock);
+	serial->num_rx_urbs = num_urbs;
+
+	/* RX, allocate urb and initialize */
+
+	/* prepare our RX buffer */
+	serial->rx_data_length = rx_size;
+	for (i = 0; i < serial->num_rx_urbs; i++) {
+		serial->rx_urb[i] = usb_alloc_urb(0, GFP_KERNEL);
+		if (!serial->rx_urb[i]) {
+			dev_err(dev, "Could not allocate urb?\n");
+			goto exit;
+		}
+		serial->rx_urb[i]->transfer_buffer = NULL;
+		serial->rx_urb[i]->transfer_buffer_length = 0;
+		serial->rx_data[i] = kzalloc(serial->rx_data_length,
+					     GFP_KERNEL);
+		if (!serial->rx_data[i]) {
+			dev_err(dev, "%s - Out of memory\n", __func__);
+			goto exit;
+		}
+	}
+
+	/* TX, allocate urb and initialize */
+	serial->tx_urb = usb_alloc_urb(0, GFP_KERNEL);
+	if (!serial->tx_urb) {
+		dev_err(dev, "Could not allocate urb?\n");
+		goto exit;
+	}
+	serial->tx_urb->transfer_buffer = NULL;
+	serial->tx_urb->transfer_buffer_length = 0;
+	/* prepare our TX buffer */
+	serial->tx_data_count = 0;
+	serial->tx_buffer_count = 0;
+	serial->tx_data_length = tx_size;
+	serial->tx_data = kzalloc(serial->tx_data_length, GFP_KERNEL);
+	if (!serial->tx_data) {
+		dev_err(dev, "%s - Out of memory", __func__);
+		goto exit;
+	}
+	serial->tx_buffer = kzalloc(serial->tx_data_length, GFP_KERNEL);
+	if (!serial->tx_buffer) {
+		dev_err(dev, "%s - Out of memory", __func__);
+		goto exit;
+	}
+
+	return 0;
+exit:
+	hso_serial_common_free(serial);
+	return -1;
+}
+
+/* Frees a general hso device */
+static void hso_free_device(struct hso_device *hso_dev)
+{
+	kfree(hso_dev);
+}
+
+/* Creates a general hso device */
+static struct hso_device *hso_create_device(struct usb_interface *intf,
+					    int port_spec)
+{
+	struct hso_device *hso_dev;
+
+	hso_dev = kzalloc(sizeof(*hso_dev), GFP_ATOMIC);
+	if (!hso_dev)
+		return NULL;
+
+	hso_dev->port_spec = port_spec;
+	hso_dev->usb = interface_to_usbdev(intf);
+	hso_dev->interface = intf;
+	kref_init(&hso_dev->ref);
+	mutex_init(&hso_dev->mutex);
+
+	INIT_WORK(&hso_dev->async_get_intf, async_get_intf);
+	INIT_WORK(&hso_dev->async_put_intf, async_put_intf);
+
+	return hso_dev;
+}
+
+/* Removes a network device in the network device table */
+static int remove_net_device(struct hso_device *hso_dev)
+{
+	int i;
+
+	for (i = 0; i < HSO_MAX_NET_DEVICES; i++) {
+		if (network_table[i] == hso_dev) {
+			network_table[i] = NULL;
+			break;
+		}
+	}
+	if (i == HSO_MAX_NET_DEVICES)
+		return -1;
+	return 0;
+}
+
+/* Frees our network device */
+static void hso_free_net_device(struct hso_device *hso_dev)
+{
+	int i;
+	struct hso_net *hso_net = dev2net(hso_dev);
+
+	if (!hso_net)
+		return;
+
+	/* start freeing */
+	for (i = 0; i < MUX_BULK_RX_BUF_COUNT; i++) {
+		usb_free_urb(hso_net->mux_bulk_rx_urb_pool[i]);
+		kfree(hso_net->mux_bulk_rx_buf_pool[i]);
+	}
+	usb_free_urb(hso_net->mux_bulk_tx_urb);
+	kfree(hso_net->mux_bulk_tx_buf);
+
+	remove_net_device(hso_net->parent);
+
+	if (hso_net->net) {
+		unregister_netdev(hso_net->net);
+		free_netdev(hso_net->net);
+	}
+
+	hso_free_device(hso_dev);
+}
+
+/* initialize the network interface */
+static void hso_net_init(struct net_device *net)
+{
+	struct hso_net *hso_net = netdev_priv(net);
+
+	D1("sizeof hso_net is %d", (int)sizeof(*hso_net));
+
+	/* fill in the other fields */
+	net->open = hso_net_open;
+	net->stop = hso_net_close;
+	net->hard_start_xmit = hso_net_start_xmit;
+	net->tx_timeout = hso_net_tx_timeout;
+	net->watchdog_timeo = HSO_NET_TX_TIMEOUT;
+	net->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
+	net->type = ARPHRD_NONE;
+	net->mtu = DEFAULT_MTU - 14;
+	net->tx_queue_len = 10;
+	SET_ETHTOOL_OPS(net, &ops);
+
+	/* and initialize the semaphore */
+	spin_lock_init(&hso_net->net_lock);
+}
+
+/* Adds a network device in the network device table */
+static int add_net_device(struct hso_device *hso_dev)
+{
+	int i;
+
+	for (i = 0; i < HSO_MAX_NET_DEVICES; i++) {
+		if (network_table[i] == NULL) {
+			network_table[i] = hso_dev;
+			break;
+		}
+	}
+	if (i == HSO_MAX_NET_DEVICES)
+		return -1;
+	return 0;
+}
+
+static int hso_radio_toggle(void *data, enum rfkill_state state)
+{
+	struct hso_device *hso_dev = data;
+	int enabled = (state == RFKILL_STATE_ON);
+	int rv;
+
+	mutex_lock(&hso_dev->mutex);
+	if (hso_dev->usb_gone)
+		rv = 0;
+	else
+		rv = usb_control_msg(hso_dev->usb, usb_rcvctrlpipe(hso_dev->usb, 0),
+				       enabled ? 0x82 : 0x81, 0x40, 0, 0, NULL, 0,
+				       USB_CTRL_SET_TIMEOUT);
+	mutex_unlock(&hso_dev->mutex);
+	return rv;
+}
+
+/* Creates and sets up everything for rfkill */
+static void hso_create_rfkill(struct hso_device *hso_dev,
+			     struct usb_interface *interface)
+{
+	struct hso_net *hso_net = dev2net(hso_dev);
+	struct device *dev = hso_dev->dev;
+	char *rfkn;
+
+	hso_net->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
+				 RFKILL_TYPE_WLAN);
+	if (!hso_net->rfkill) {
+		dev_err(dev, "%s - Out of memory", __func__);
+		return;
+	}
+	rfkn = kzalloc(20, GFP_KERNEL);
+	if (!rfkn) {
+		rfkill_free(hso_net->rfkill);
+		dev_err(dev, "%s - Out of memory", __func__);
+		return;
+	}
+	snprintf(rfkn, 20, "hso-%d",
+		 interface->altsetting->desc.bInterfaceNumber);
+	hso_net->rfkill->name = rfkn;
+	hso_net->rfkill->state = RFKILL_STATE_ON;
+	hso_net->rfkill->data = hso_dev;
+	hso_net->rfkill->toggle_radio = hso_radio_toggle;
+	if (rfkill_register(hso_net->rfkill) < 0) {
+		kfree(rfkn);
+		hso_net->rfkill->name = NULL;
+		rfkill_free(hso_net->rfkill);
+		dev_err(dev, "%s - Failed to register rfkill", __func__);
+		return;
+	}
+}
+
+/* Creates our network device */
+static struct hso_device *hso_create_net_device(struct usb_interface *interface)
+{
+	int result, i;
+	struct net_device *net;
+	struct hso_net *hso_net;
+	struct hso_device *hso_dev;
+
+	hso_dev = hso_create_device(interface, HSO_INTF_MUX | HSO_PORT_NETWORK);
+	if (!hso_dev)
+		return NULL;
+
+	/* allocate our network device, then we can put in our private data */
+	/* call hso_net_init to do the basic initialization */
+	net = alloc_netdev(sizeof(struct hso_net), "hso%d", hso_net_init);
+	if (!net) {
+		dev_err(&interface->dev, "Unable to create ethernet device\n");
+		goto exit;
+	}
+
+	hso_net = netdev_priv(net);
+
+	hso_dev->port_data.dev_net = hso_net;
+	hso_net->net = net;
+	hso_net->parent = hso_dev;
+
+	hso_net->in_endp = hso_get_ep(interface, USB_ENDPOINT_XFER_BULK,
+				      USB_DIR_IN);
+	if (!hso_net->in_endp) {
+		dev_err(&interface->dev, "Can't find BULK IN endpoint\n");
+		goto exit;
+	}
+	hso_net->out_endp = hso_get_ep(interface, USB_ENDPOINT_XFER_BULK,
+				       USB_DIR_OUT);
+	if (!hso_net->out_endp) {
+		dev_err(&interface->dev, "Can't find BULK OUT endpoint\n");
+		goto exit;
+	}
+	SET_NETDEV_DEV(net, &interface->dev);
+
+	/* registering our net device */
+	result = register_netdev(net);
+	if (result) {
+		dev_err(&interface->dev, "Failed to register device\n");
+		goto exit;
+	}
+
+	/* start allocating */
+	for (i = 0; i < MUX_BULK_RX_BUF_COUNT; i++) {
+		hso_net->mux_bulk_rx_urb_pool[i] = usb_alloc_urb(0, GFP_KERNEL);
+		if (!hso_net->mux_bulk_rx_urb_pool[i]) {
+			dev_err(&interface->dev, "Could not allocate rx urb\n");
+			goto exit;
+		}
+		hso_net->mux_bulk_rx_buf_pool[i] = kzalloc(MUX_BULK_RX_BUF_SIZE,
+							   GFP_KERNEL);
+		if (!hso_net->mux_bulk_rx_buf_pool[i]) {
+			dev_err(&interface->dev, "Could not allocate rx buf\n");
+			goto exit;
+		}
+	}
+	hso_net->mux_bulk_tx_urb = usb_alloc_urb(0, GFP_KERNEL);
+	if (!hso_net->mux_bulk_tx_urb) {
+		dev_err(&interface->dev, "Could not allocate tx urb\n");
+		goto exit;
+	}
+	hso_net->mux_bulk_tx_buf = kzalloc(MUX_BULK_TX_BUF_SIZE, GFP_KERNEL);
+	if (!hso_net->mux_bulk_tx_buf) {
+		dev_err(&interface->dev, "Could not allocate tx buf\n");
+		goto exit;
+	}
+
+	add_net_device(hso_dev);
+
+	hso_log_port(hso_dev);
+
+	hso_create_rfkill(hso_dev, interface);
+
+	return hso_dev;
+exit:
+	hso_free_net_device(hso_dev);
+	return NULL;
+}
+
+/* Frees an AT channel ( goes for both mux and non-mux ) */
+static void hso_free_serial_device(struct hso_device *hso_dev)
+{
+	struct hso_serial *serial = dev2ser(hso_dev);
+
+	if (!serial)
+		return;
+	set_serial_by_index(serial->minor, NULL);
+
+	hso_serial_common_free(serial);
+
+	if (serial->shared_int) {
+		mutex_lock(&serial->shared_int->shared_int_lock);
+		if (--serial->shared_int->ref_count == 0)
+			hso_free_shared_int(serial->shared_int);
+		else
+			mutex_unlock(&serial->shared_int->shared_int_lock);
+	}
+	kfree(serial);
+	hso_free_device(hso_dev);
+}
+
+/* Creates a bulk AT channel */
+static struct hso_device *hso_create_bulk_serial_device(
+			struct usb_interface *interface, int port)
+{
+	struct hso_device *hso_dev;
+	struct hso_serial *serial;
+	int num_urbs;
+
+	hso_dev = hso_create_device(interface, port);
+	if (!hso_dev)
+		return NULL;
+
+	serial = kzalloc(sizeof(*serial), GFP_KERNEL);
+	if (!serial)
+		goto exit;
+
+	serial->parent = hso_dev;
+	hso_dev->port_data.dev_serial = serial;
+
+	if (port & HSO_PORT_MODEM)
+		num_urbs = 2;
+	else
+		num_urbs = 1;
+
+	if (hso_serial_common_create(serial, num_urbs, BULK_URB_RX_SIZE,
+				     BULK_URB_TX_SIZE))
+		goto exit;
+
+	serial->in_endp = hso_get_ep(interface, USB_ENDPOINT_XFER_BULK,
+				     USB_DIR_IN);
+	if (!serial->in_endp) {
+		dev_err(&interface->dev, "Failed to find BULK IN ep\n");
+		goto exit;
+	}
+
+	if (!
+	    (serial->out_endp =
+	     hso_get_ep(interface, USB_ENDPOINT_XFER_BULK, USB_DIR_OUT))) {
+		dev_err(&interface->dev, "Failed to find BULK IN ep\n");
+		goto exit;
+	}
+
+	serial->write_data = hso_std_serial_write_data;
+
+	/* and record this serial */
+	set_serial_by_index(serial->minor, serial);
+
+	/* setup the proc dirs and files if needed */
+	hso_log_port(hso_dev);
+
+	/* done, return it */
+	return hso_dev;
+exit:
+	if (hso_dev && serial)
+		hso_serial_common_free(serial);
+	kfree(serial);
+	hso_free_device(hso_dev);
+	return NULL;
+}
+
+/* Creates a multiplexed AT channel */
+static
+struct hso_device *hso_create_mux_serial_device(struct usb_interface *interface,
+						int port,
+						struct hso_shared_int *mux)
+{
+	struct hso_device *hso_dev;
+	struct hso_serial *serial;
+	int port_spec;
+
+	port_spec = HSO_INTF_MUX;
+	port_spec &= ~HSO_PORT_MASK;
+
+	port_spec |= hso_mux_to_port(port);
+	if ((port_spec & HSO_PORT_MASK) == HSO_PORT_NO_PORT)
+		return NULL;
+
+	hso_dev = hso_create_device(interface, port_spec);
+	if (!hso_dev)
+		return NULL;
+
+	serial = kzalloc(sizeof(*serial), GFP_KERNEL);
+	if (!serial)
+		goto exit;
+
+	hso_dev->port_data.dev_serial = serial;
+	serial->parent = hso_dev;
+
+	if (hso_serial_common_create
+	    (serial, 1, CTRL_URB_RX_SIZE, CTRL_URB_TX_SIZE))
+		goto exit;
+
+	serial->tx_data_length--;
+	serial->write_data = hso_mux_serial_write_data;
+
+	serial->shared_int = mux;
+	mutex_lock(&serial->shared_int->shared_int_lock);
+	serial->shared_int->ref_count++;
+	mutex_unlock(&serial->shared_int->shared_int_lock);
+
+	/* and record this serial */
+	set_serial_by_index(serial->minor, serial);
+
+	/* setup the proc dirs and files if needed */
+	hso_log_port(hso_dev);
+
+	/* done, return it */
+	return hso_dev;
+
+exit:
+	if (serial) {
+		tty_unregister_device(tty_drv, serial->minor);
+		kfree(serial);
+	}
+	if (hso_dev)
+		hso_free_device(hso_dev);
+	return NULL;
+
+}
+
+static void hso_free_shared_int(struct hso_shared_int *mux)
+{
+	usb_free_urb(mux->shared_intr_urb);
+	kfree(mux->shared_intr_buf);
+	mutex_unlock(&mux->shared_int_lock);
+	kfree(mux);
+}
+
+static
+struct hso_shared_int *hso_create_shared_int(struct usb_interface *interface)
+{
+	struct hso_shared_int *mux = kzalloc(sizeof(*mux), GFP_KERNEL);
+
+	if (!mux)
+		return NULL;
+
+	mux->intr_endp = hso_get_ep(interface, USB_ENDPOINT_XFER_INT,
+				    USB_DIR_IN);
+	if (!mux->intr_endp) {
+		dev_err(&interface->dev, "Can't find INT IN endpoint\n");
+		goto exit;
+	}
+
+	mux->shared_intr_urb = usb_alloc_urb(0, GFP_KERNEL);
+	if (!mux->shared_intr_urb) {
+		dev_err(&interface->dev, "Could not allocate intr urb?");
+		goto exit;
+	}
+	mux->shared_intr_buf = kzalloc(mux->intr_endp->wMaxPacketSize,
+				       GFP_KERNEL);
+	if (!mux->shared_intr_buf) {
+		dev_err(&interface->dev, "Could not allocate intr buf?");
+		goto exit;
+	}
+
+	mutex_init(&mux->shared_int_lock);
+
+	return mux;
+
+exit:
+	kfree(mux->shared_intr_buf);
+	usb_free_urb(mux->shared_intr_urb);
+	kfree(mux);
+	return NULL;
+}
+
+/* Gets the port spec for a certain interface */
+static int hso_get_config_data(struct usb_interface *interface)
+{
+	struct usb_device *usbdev = interface_to_usbdev(interface);
+	u8 config_data[17];
+	u32 if_num = interface->altsetting->desc.bInterfaceNumber;
+	s32 result;
+
+	if (usb_control_msg(usbdev, usb_rcvctrlpipe(usbdev, 0),
+			    0x86, 0xC0, 0, 0, config_data, 17,
+			    USB_CTRL_SET_TIMEOUT) != 0x11) {
+		return -EIO;
+	}
+
+	switch (config_data[if_num]) {
+	case 0x0:
+		result = 0;
+		break;
+	case 0x1:
+		result = HSO_PORT_DIAG;
+		break;
+	case 0x2:
+		result = HSO_PORT_GPS;
+		break;
+	case 0x3:
+		result = HSO_PORT_GPS_CONTROL;
+		break;
+	case 0x4:
+		result = HSO_PORT_APP;
+		break;
+	case 0x5:
+		result = HSO_PORT_APP2;
+		break;
+	case 0x6:
+		result = HSO_PORT_CONTROL;
+		break;
+	case 0x7:
+		result = HSO_PORT_NETWORK;
+		break;
+	case 0x8:
+		result = HSO_PORT_MODEM;
+		break;
+	case 0x9:
+		result = HSO_PORT_MSD;
+		break;
+	case 0xa:
+		result = HSO_PORT_PCSC;
+		break;
+	case 0xb:
+		result = HSO_PORT_VOICE;
+		break;
+	default:
+		result = 0;
+	}
+
+	if (result)
+		result |= HSO_INTF_BULK;
+
+	if (config_data[16] & 0x1)
+		result |= HSO_INFO_CRC_BUG;
+
+	return result;
+}
+
+/* called once for each interface upon device insertion */
+static int hso_probe(struct usb_interface *interface,
+		     const struct usb_device_id *id)
+{
+	int mux, i, if_num, port_spec;
+	unsigned char port_mask;
+	struct hso_device *hso_dev = NULL;
+	struct hso_shared_int *shared_int;
+	struct hso_device *tmp_dev = NULL;
+
+	if_num = interface->altsetting->desc.bInterfaceNumber;
+
+	/* Get the interface/port specification from either driver_info or from
+	 * the device itself */
+	if (id->driver_info)
+		port_spec = ((u32 *)(id->driver_info))[if_num];
+	else
+		port_spec = hso_get_config_data(interface);
+
+	if (interface->cur_altsetting->desc.bInterfaceClass != 0xFF) {
+		dev_err(&interface->dev, "Not our interface\n");
+		return -ENODEV;
+	}
+	/* Check if we need to switch to alt interfaces prior to port
+	 * configuration */
+	if (interface->num_altsetting > 1)
+		usb_set_interface(interface_to_usbdev(interface), if_num, 1);
+	interface->needs_remote_wakeup = 1;
+
+	/* Allocate new hso device(s) */
+	switch (port_spec & HSO_INTF_MASK) {
+	case HSO_INTF_MUX:
+		if ((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK) {
+			/* Create the network device */
+			if (!disable_net) {
+				hso_dev = hso_create_net_device(interface);
+				if (!hso_dev)
+					goto exit;
+				tmp_dev = hso_dev;
+			}
+		}
+
+		if (hso_get_mux_ports(interface, &port_mask))
+			/* TODO: de-allocate everything */
+			goto exit;
+
+		shared_int = hso_create_shared_int(interface);
+		if (!shared_int)
+			goto exit;
+
+		for (i = 1, mux = 0; i < 0x100; i = i << 1, mux++) {
+			if (port_mask & i) {
+				hso_dev = hso_create_mux_serial_device(
+						interface, i, shared_int);
+				if (!hso_dev)
+					goto exit;
+			}
+		}
+
+		if (tmp_dev)
+			hso_dev = tmp_dev;
+		break;
+
+	case HSO_INTF_BULK:
+		/* It's a regular bulk interface */
+		if (((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK)
+		    && !disable_net)
+			hso_dev = hso_create_net_device(interface);
+		else
+			hso_dev =
+			    hso_create_bulk_serial_device(interface, port_spec);
+		if (!hso_dev)
+			goto exit;
+		break;
+	default:
+		goto exit;
+	}
+
+	usb_driver_claim_interface(&hso_driver, interface, hso_dev);
+
+	/* save our data pointer in this device */
+	usb_set_intfdata(interface, hso_dev);
+
+	/* done */
+	return 0;
+exit:
+	hso_free_interface(interface);
+	return -ENODEV;
+}
+
+/* device removed, cleaning up */
+static void hso_disconnect(struct usb_interface *interface)
+{
+	hso_free_interface(interface);
+
+	/* remove reference of our private data */
+	usb_set_intfdata(interface, NULL);
+
+	usb_driver_release_interface(&hso_driver, interface);
+}
+
+static void async_get_intf(struct work_struct *data)
+{
+	struct hso_device *hso_dev =
+	    container_of(data, struct hso_device, async_get_intf);
+	usb_autopm_get_interface(hso_dev->interface);
+}
+
+static void async_put_intf(struct work_struct *data)
+{
+	struct hso_device *hso_dev =
+	    container_of(data, struct hso_device, async_put_intf);
+	usb_autopm_put_interface(hso_dev->interface);
+}
+
+static int hso_get_activity(struct hso_device *hso_dev)
+{
+	if (hso_dev->usb->state == USB_STATE_SUSPENDED) {
+		if (!hso_dev->is_active) {
+			hso_dev->is_active = 1;
+			schedule_work(&hso_dev->async_get_intf);
+		}
+	}
+
+	if (hso_dev->usb->state != USB_STATE_CONFIGURED)
+		return -EAGAIN;
+
+	usb_mark_last_busy(hso_dev->usb);
+
+	return 0;
+}
+
+static int hso_put_activity(struct hso_device *hso_dev)
+{
+	if (hso_dev->usb->state != USB_STATE_SUSPENDED) {
+		if (hso_dev->is_active) {
+			hso_dev->is_active = 0;
+			schedule_work(&hso_dev->async_put_intf);
+			return -EAGAIN;
+		}
+	}
+	hso_dev->is_active = 0;
+	return 0;
+}
+
+/* called by kernel when we need to suspend device */
+static int hso_suspend(struct usb_interface *iface, pm_message_t message)
+{
+	int i, result;
+
+	/* Stop all serial ports */
+	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
+		if (serial_table[i] && (serial_table[i]->interface == iface)) {
+			result = hso_stop_serial_device(serial_table[i]);
+			if (result)
+				goto out;
+		}
+	}
+
+	/* Stop all network ports */
+	for (i = 0; i < HSO_MAX_NET_DEVICES; i++) {
+		if (network_table[i] &&
+		    (network_table[i]->interface == iface)) {
+			result = hso_stop_net_device(network_table[i]);
+			if (result)
+				goto out;
+		}
+	}
+
+out:
+	return 0;
+}
+
+/* called by kernel when we need to resume device */
+static int hso_resume(struct usb_interface *iface)
+{
+	int i, result = 0;
+	struct hso_net *hso_net;
+
+	/* Start all serial ports */
+	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
+		if (serial_table[i] && (serial_table[i]->interface == iface)) {
+			if (dev2ser(serial_table[i])->open_count) {
+				result =
+				    hso_start_serial_device(serial_table[i], GFP_NOIO);
+				hso_kick_transmit(dev2ser(serial_table[i]));
+				if (result)
+					goto out;
+			}
+		}
+	}
+
+	/* Start all network ports */
+	for (i = 0; i < HSO_MAX_NET_DEVICES; i++) {
+		if (network_table[i] &&
+		    (network_table[i]->interface == iface)) {
+			hso_net = dev2net(network_table[i]);
+			/* First transmit any lingering data, then restart the
+			 * device. */
+			if (hso_net->skb_tx_buf) {
+				dev_dbg(&iface->dev,
+					"Transmitting lingering data\n");
+				hso_net_start_xmit(hso_net->skb_tx_buf,
+						   hso_net->net);
+			}
+			result = hso_start_net_device(network_table[i]);
+			if (result)
+				goto out;
+		}
+	}
+
+out:
+	return result;
+}
+
+static void hso_serial_ref_free(struct kref *ref)
+{
+	struct hso_device *hso_dev = container_of(ref, struct hso_device, ref);
+
+	hso_free_serial_device(hso_dev);
+}
+
+static void hso_free_interface(struct usb_interface *interface)
+{
+	struct hso_serial *hso_dev;
+	int i;
+
+	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
+		if (serial_table[i]
+		    && (serial_table[i]->interface == interface)) {
+			hso_dev = dev2ser(serial_table[i]);
+			if (hso_dev->tty)
+				tty_hangup(hso_dev->tty);
+			mutex_lock(&hso_dev->parent->mutex);
+			hso_dev->parent->usb_gone = 1;
+			mutex_unlock(&hso_dev->parent->mutex);
+			kref_put(&serial_table[i]->ref, hso_serial_ref_free);
+		}
+	}
+
+	for (i = 0; i < HSO_MAX_NET_DEVICES; i++) {
+		if (network_table[i]
+		    && (network_table[i]->interface == interface)) {
+			struct rfkill *rfk = dev2net(network_table[i])->rfkill;
+			/* hso_stop_net_device doesn't stop the net queue since
+			 * traffic needs to start it again when suspended */
+			netif_stop_queue(dev2net(network_table[i])->net);
+			hso_stop_net_device(network_table[i]);
+			cancel_work_sync(&network_table[i]->async_put_intf);
+			cancel_work_sync(&network_table[i]->async_get_intf);
+			if(rfk)
+				rfkill_unregister(rfk);
+			hso_free_net_device(network_table[i]);
+		}
+	}
+}
+
+/* Helper functions */
+
+/* Get the endpoint ! */
+static struct usb_endpoint_descriptor *hso_get_ep(struct usb_interface *intf,
+						  int type, int dir)
+{
+	int i;
+	struct usb_host_interface *iface = intf->cur_altsetting;
+	struct usb_endpoint_descriptor *endp;
+
+	for (i = 0; i < iface->desc.bNumEndpoints; i++) {
+		endp = &iface->endpoint[i].desc;
+		if (((endp->bEndpointAddress & USB_ENDPOINT_DIR_MASK) == dir) &&
+		    ((endp->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) == type))
+			return endp;
+	}
+
+	return NULL;
+}
+
+/* Get the byte that describes which ports are enabled */
+static int hso_get_mux_ports(struct usb_interface *intf, unsigned char *ports)
+{
+	int i;
+	struct usb_host_interface *iface = intf->cur_altsetting;
+
+	if (iface->extralen == 3) {
+		*ports = iface->extra[2];
+		return 0;
+	}
+
+	for (i = 0; i < iface->desc.bNumEndpoints; i++) {
+		if (iface->endpoint[i].extralen == 3) {
+			*ports = iface->endpoint[i].extra[2];
+			return 0;
+		}
+	}
+
+	return -1;
+}
+
+/* interrupt urb needs to be submitted, used for serial read of muxed port */
+static int hso_mux_submit_intr_urb(struct hso_shared_int *shared_int,
+				   struct usb_device *usb, gfp_t gfp)
+{
+	int result;
+
+	usb_fill_int_urb(shared_int->shared_intr_urb, usb,
+			 usb_rcvintpipe(usb,
+				shared_int->intr_endp->bEndpointAddress & 0x7F),
+			 shared_int->shared_intr_buf,
+			 shared_int->intr_endp->wMaxPacketSize,
+			 intr_callback, shared_int,
+			 shared_int->intr_endp->bInterval);
+
+	result = usb_submit_urb(shared_int->shared_intr_urb, gfp);
+	if (result)
+		dev_warn(&usb->dev, "%s failed mux_intr_urb %d", __func__,
+			result);
+
+	return result;
+}
+
+/* operations setup of the serial interface */
+static struct tty_operations hso_serial_ops = {
+	.open = hso_serial_open,
+	.close = hso_serial_close,
+	.write = hso_serial_write,
+	.write_room = hso_serial_write_room,
+	.set_termios = hso_serial_set_termios,
+	.chars_in_buffer = hso_serial_chars_in_buffer,
+	.tiocmget = hso_serial_tiocmget,
+	.tiocmset = hso_serial_tiocmset,
+};
+
+static struct usb_driver hso_driver = {
+	.name = driver_name,
+	.probe = hso_probe,
+	.disconnect = hso_disconnect,
+	.id_table = hso_ids,
+	.suspend = hso_suspend,
+	.resume = hso_resume,
+	.supports_autosuspend = 1,
+};
+
+static int __init hso_init(void)
+{
+	int i;
+	int result;
+
+	/* put it in the log */
+	printk(KERN_INFO "hso: %s\n", version);
+
+	/* Initialise the serial table semaphore and table */
+	spin_lock_init(&serial_table_lock);
+	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++)
+		serial_table[i] = NULL;
+
+	/* allocate our driver using the proper amount of supported minors */
+	tty_drv = alloc_tty_driver(HSO_SERIAL_TTY_MINORS);
+	if (!tty_drv)
+		return -ENOMEM;
+
+	/* fill in all needed values */
+	tty_drv->magic = TTY_DRIVER_MAGIC;
+	tty_drv->owner = THIS_MODULE;
+	tty_drv->driver_name = driver_name;
+	tty_drv->name = tty_filename;
+
+	/* if major number is provided as parameter, use that one */
+	if (tty_major)
+		tty_drv->major = tty_major;
+
+	tty_drv->minor_start = 0;
+	tty_drv->num = HSO_SERIAL_TTY_MINORS;
+	tty_drv->type = TTY_DRIVER_TYPE_SERIAL;
+	tty_drv->subtype = SERIAL_TYPE_NORMAL;
+	tty_drv->flags = TTY_DRIVER_REAL_RAW | TTY_DRIVER_DYNAMIC_DEV;
+	tty_drv->init_termios = tty_std_termios;
+	tty_drv->init_termios.c_cflag = B9600 | CS8 | CREAD | HUPCL | CLOCAL;
+	tty_drv->termios = hso_serial_termios;
+	tty_drv->termios_locked = hso_serial_termios_locked;
+	tty_set_operations(tty_drv, &hso_serial_ops);
+
+	/* register the tty driver */
+	result = tty_register_driver(tty_drv);
+	if (result) {
+		printk(KERN_ERR "%s - tty_register_driver failed(%d)\n",
+			__func__, result);
+		return result;
+	}
+
+	/* register this module as an usb driver */
+	result = usb_register(&hso_driver);
+	if (result) {
+		printk(KERN_ERR "Could not register hso driver? error: %d\n",
+			result);
+		/* cleanup serial interface */
+		tty_unregister_driver(tty_drv);
+		return result;
+	}
+
+	/* done */
+	return 0;
+}
+
+static void __exit hso_exit(void)
+{
+	printk(KERN_INFO "hso: unloaded\n");
+
+	tty_unregister_driver(tty_drv);
+	/* deregister the usb driver */
+	usb_deregister(&hso_driver);
+}
+
+/* Module definitions */
+module_init(hso_init);
+module_exit(hso_exit);
+
+MODULE_AUTHOR(MOD_AUTHOR);
+MODULE_DESCRIPTION(MOD_DESCRIPTION);
+MODULE_LICENSE(MOD_LICENSE);
+MODULE_INFO(Version, DRIVER_VERSION);
+
+/* change the debug level (eg: insmod hso.ko debug=0x04) */
+MODULE_PARM_DESC(debug, "Level of debug [0x01 | 0x02 | 0x04 | 0x08 | 0x10]");
+module_param(debug, int, S_IRUGO | S_IWUSR);
+
+/* set the major tty number (eg: insmod hso.ko tty_major=245) */
+MODULE_PARM_DESC(tty_major, "Set the major tty number");
+module_param(tty_major, int, S_IRUGO | S_IWUSR);
+
+/* disable network interface (eg: insmod hso.ko disable_net=1) */
+MODULE_PARM_DESC(disable_net, "Disable the network interface");
+module_param(disable_net, int, S_IRUGO | S_IWUSR);
diff --git a/include/linux/smc911x.h b/include/linux/smc911x.h
new file mode 100644
index 0000000..b58f54c
--- /dev/null
+++ b/include/linux/smc911x.h
@@ -0,0 +1,12 @@
+#ifndef __SMC911X_H__
+#define __SMC911X_H__
+
+#define SMC911X_USE_16BIT (1 << 0)
+#define SMC911X_USE_32BIT (1 << 1)
+
+struct smc911x_platdata {
+	unsigned long flags;
+	unsigned long irq_flags; /* IRQF_... */
+};
+
+#endif /* __SMC911X_H__ */
