From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] ipg: add IP1000A driver to kernel tree
Date: Fri, 14 Sep 2007 23:21:05 +0200
Message-ID: <20070914212105.GA28233@electric-eye.fr.zoreil.com>
References: <1189774938.3353.1.camel@localhost.localdomain> <20070914211108.GB22975@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Huang <jesse@icplus.com.tw>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	s.l-h@gmx.de
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51201 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757540AbXINVXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 17:23:25 -0400
Content-Disposition: inline
In-Reply-To: <20070914211108.GB22975@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Stefan Lippers-Hollmann <s.l-h@gmx.de>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

---
 MAINTAINERS             |   10 +
 drivers/net/Kconfig     |    9 +
 drivers/net/Makefile    |    1 +
 drivers/net/ipg.c       | 2329 +++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ipg.h       |  856 +++++++++++++++++
 include/linux/pci_ids.h |    2 +
 6 files changed, 3207 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ipg.c
 create mode 100644 drivers/net/ipg.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 9c54a5e..1ad90e8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2075,6 +2075,16 @@ P:	Juanjo Ciarlante
 M:	jjciarla@raiz.uncu.edu.ar
 S:	Maintained
 
+IP1000A 10/100/1000 GIGABIT ETHERNET DRIVER
+P:	Francois Romieu
+M:	romieu@fr.zoreil.com
+P:	Sorbica Shieh
+M:	sorbica@icplus.com.tw
+P:	Jesse Huang
+M:	jesse@icplus.com.tw
+L:	netdev@vger.kernel.org
+S:	Maintained
+
 IPATH DRIVER:
 P:	Arthur Jones
 M:	infinipath@qlogic.com
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5b9e17b..3462d07 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -159,6 +159,15 @@ config NET_SB1000
 
 	  If you don't have this card, of course say N.
 
+config IP1000
+       tristate "IP1000 Gigabit Ethernet support"
+       depends on PCI && EXPERIMENTAL
+       ---help---
+         This driver supports IP1000 gigabit Ethernet cards.
+
+         To compile this driver as a module, choose M here: the module
+         will be called ipg.  This is recommended.
+
 source "drivers/net/arcnet/Kconfig"
 
 source "drivers/net/phy/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index e684212..eccd0eb 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_E1000) += e1000/
 obj-$(CONFIG_IBM_EMAC) += ibm_emac/
+obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_IXGB) += ixgb/
 obj-$(CONFIG_CHELSIO_T1) += chelsio/
 obj-$(CONFIG_CHELSIO_T3) += cxgb3/
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
new file mode 100644
index 0000000..aaccf36
--- /dev/null
+++ b/drivers/net/ipg.c
@@ -0,0 +1,2327 @@
+/*
+ * ipg.c: Device Driver for the IP1000 Gigabit Ethernet Adapter
+ *
+ * Copyright (C) 2003, 2007  IC Plus Corp
+ *
+ * Original Author:
+ *
+ *   Craig Rich
+ *   Sundance Technology, Inc.
+ *   www.sundanceti.com
+ *   craig_rich@sundanceti.com
+ *
+ * Current Maintainer:
+ *
+ *   Sorbica Shieh.
+ *   http://www.icplus.com.tw
+ *   sorbica@icplus.com.tw
+ *
+ *   Jesse Huang
+ *   http://www.icplus.com.tw
+ *   jesse@icplus.com.tw
+ */
+#include <linux/crc32.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/mutex.h>
+
+#define IPG_RX_RING_BYTES	(sizeof(struct ipg_rx) * IPG_RFDLIST_LENGTH)
+#define IPG_TX_RING_BYTES	(sizeof(struct ipg_tx) * IPG_TFDLIST_LENGTH)
+#define IPG_RESET_MASK \
+	(IPG_AC_GLOBAL_RESET | IPG_AC_RX_RESET | IPG_AC_TX_RESET | \
+	 IPG_AC_DMA | IPG_AC_FIFO | IPG_AC_NETWORK | IPG_AC_HOST | \
+	 IPG_AC_AUTO_INIT)
+
+#define ipg_w32(val32,reg)	iowrite32((val32), ioaddr + (reg))
+#define ipg_w16(val16,reg)	iowrite16((val16), ioaddr + (reg))
+#define ipg_w8(val8,reg)	iowrite8((val8), ioaddr + (reg))
+
+#define ipg_r32(reg)		ioread32(ioaddr + (reg))
+#define ipg_r16(reg)		ioread16(ioaddr + (reg))
+#define ipg_r8(reg)		ioread8(ioaddr + (reg))
+
+#define JUMBO_FRAME_4k_ONLY
+enum {
+	netdev_io_size = 128
+};
+
+#include "ipg.h"
+#define DRV_NAME	"ipg"
+
+MODULE_AUTHOR("IC Plus Corp. 2003");
+MODULE_DESCRIPTION("IC Plus IP1000 Gigabit Ethernet Adapter Linux Driver "
+		   DrvVer);
+MODULE_LICENSE("GPL");
+
+static const char *ipg_brand_name[] = {
+	"IC PLUS IP1000 1000/100/10 based NIC",
+	"Sundance Technology ST2021 based NIC",
+	"Tamarack Microelectronics TC9020/9021 based NIC",
+	"Tamarack Microelectronics TC9020/9021 based NIC",
+	"D-Link NIC",
+	"D-Link NIC IP1000A"
+};
+
+static struct pci_device_id ipg_pci_tbl[] __devinitdata = {
+	{ PCI_VDEVICE(SUNDANCE,	0x1023), 0 },
+	{ PCI_VDEVICE(SUNDANCE,	0x2021), 1 },
+	{ PCI_VDEVICE(SUNDANCE,	0x1021), 2 },
+	{ PCI_VDEVICE(DLINK,	0x9021), 3 },
+	{ PCI_VDEVICE(DLINK,	0x4000), 4 },
+	{ PCI_VDEVICE(DLINK,	0x4020), 5 },
+	{ 0, }
+};
+
+MODULE_DEVICE_TABLE(pci, ipg_pci_tbl);
+
+static inline void __iomem *ipg_ioaddr(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	return sp->ioaddr;
+}
+
+#ifdef IPG_DEBUG
+static void ipg_dump_rfdlist(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	unsigned int i;
+	u32 offset;
+
+	IPG_DEBUG_MSG("_dump_rfdlist\n");
+
+	printk(KERN_INFO "rx_current = %2.2x\n", sp->rx_current);
+	printk(KERN_INFO "rx_dirty   = %2.2x\n", sp->rx_dirty);
+	printk(KERN_INFO "RFDList start address = %16.16lx\n",
+	       (unsigned long) sp->rxd_map);
+	printk(KERN_INFO "RFDListPtr register   = %8.8x%8.8x\n",
+	       ipg_r32(IPG_RFDLISTPTR1), ipg_r32(IPG_RFDLISTPTR0));
+
+	for (i = 0; i < IPG_RFDLIST_LENGTH; i++) {
+		offset = (u32) &sp->rxd[i].next_desc - (u32) sp->rxd;
+		printk(KERN_INFO "%2.2x %4.4x RFDNextPtr = %16.16lx\n", i,
+		       offset, (unsigned long) sp->rxd[i].next_desc);
+		offset = (u32) &sp->rxd[i].rfs - (u32) sp->rxd;
+		printk(KERN_INFO "%2.2x %4.4x RFS        = %16.16lx\n", i,
+		       offset, (unsigned long) sp->rxd[i].rfs);
+		offset = (u32) &sp->rxd[i].frag_info - (u32) sp->rxd;
+		printk(KERN_INFO "%2.2x %4.4x frag_info   = %16.16lx\n", i,
+		       offset, (unsigned long) sp->rxd[i].frag_info);
+	}
+}
+
+static void ipg_dump_tfdlist(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	unsigned int i;
+	u32 offset;
+
+	IPG_DEBUG_MSG("_dump_tfdlist\n");
+
+	printk(KERN_INFO "tx_current         = %2.2x\n", sp->tx_current);
+	printk(KERN_INFO "tx_dirty = %2.2x\n", sp->tx_dirty);
+	printk(KERN_INFO "TFDList start address = %16.16lx\n",
+	       (unsigned long) sp->txd_map);
+	printk(KERN_INFO "TFDListPtr register   = %8.8x%8.8x\n",
+	       ipg_r32(IPG_TFDLISTPTR1), ipg_r32(IPG_TFDLISTPTR0));
+
+	for (i = 0; i < IPG_TFDLIST_LENGTH; i++) {
+		offset = (u32) &sp->txd[i].next_desc - (u32) sp->txd;
+		printk(KERN_INFO "%2.2x %4.4x TFDNextPtr = %16.16lx\n", i,
+		       offset, (unsigned long) sp->txd[i].next_desc);
+
+		offset = (u32) &sp->txd[i].tfc - (u32) sp->txd;
+		printk(KERN_INFO "%2.2x %4.4x TFC        = %16.16lx\n", i,
+		       offset, (unsigned long) sp->txd[i].tfc);
+		offset = (u32) &sp->txd[i].frag_info - (u32) sp->txd;
+		printk(KERN_INFO "%2.2x %4.4x frag_info   = %16.16lx\n", i,
+		       offset, (unsigned long) sp->txd[i].frag_info);
+	}
+}
+#endif
+
+static void ipg_write_phy_ctl(void __iomem *ioaddr, u8 data)
+{
+	ipg_w8(IPG_PC_RSVD_MASK & data, PHY_CTRL);
+	ndelay(IPG_PC_PHYCTRLWAIT_NS);
+}
+
+static void ipg_drive_phy_ctl_low_high(void __iomem *ioaddr, u8 data)
+{
+	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | data);
+	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | data);
+}
+
+static void send_three_state(void __iomem *ioaddr, u8 phyctrlpolarity)
+{
+	phyctrlpolarity |= (IPG_PC_MGMTDATA & 0) | IPG_PC_MGMTDIR;
+
+	ipg_drive_phy_ctl_low_high(ioaddr, phyctrlpolarity);
+}
+
+static void send_end(void __iomem *ioaddr, u8 phyctrlpolarity)
+{
+	ipg_w8((IPG_PC_MGMTCLK_LO | (IPG_PC_MGMTDATA & 0) | IPG_PC_MGMTDIR |
+		phyctrlpolarity) & IPG_PC_RSVD_MASK, PHY_CTRL);
+}
+
+static u16 read_phy_bit(void __iomem * ioaddr, u8 phyctrlpolarity)
+{
+	u16 bit_data;
+
+	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | phyctrlpolarity);
+
+	bit_data = ((ipg_r8(PHY_CTRL) & IPG_PC_MGMTDATA) >> 1) & 1;
+
+	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | phyctrlpolarity);
+
+	return bit_data;
+}
+
+/*
+ * Read a register from the Physical Layer device located
+ * on the IPG NIC, using the IPG PHYCTRL register.
+ */
+static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
+{
+	void __iomem *ioaddr = ipg_ioaddr(dev);
+	/*
+	 * The GMII mangement frame structure for a read is as follows:
+	 *
+	 * |Preamble|st|op|phyad|regad|ta|      data      |idle|
+	 * |< 32 1s>|01|10|AAAAA|RRRRR|z0|DDDDDDDDDDDDDDDD|z   |
+	 *
+	 * <32 1s> = 32 consecutive logic 1 values
+	 * A = bit of Physical Layer device address (MSB first)
+	 * R = bit of register address (MSB first)
+	 * z = High impedance state
+	 * D = bit of read data (MSB first)
+	 *
+	 * Transmission order is 'Preamble' field first, bits transmitted
+	 * left to right (first to last).
+	 */
+	struct {
+		u32 field;
+		unsigned int len;
+	} p[] = {
+		{ GMII_PREAMBLE,	32 },	/* Preamble */
+		{ GMII_ST,		2  },	/* ST */
+		{ GMII_READ,		2  },	/* OP */
+		{ phy_id,		5  },	/* PHYAD */
+		{ phy_reg,		5  },	/* REGAD */
+		{ 0x0000,		2  },	/* TA */
+		{ 0x0000,		16 },	/* DATA */
+		{ 0x0000,		1  }	/* IDLE */
+	};
+	unsigned int i, j;
+	u8 polarity, data;
+
+	polarity  = ipg_r8(PHY_CTRL);
+	polarity &= (IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
+
+	/* Create the Preamble, ST, OP, PHYAD, and REGAD field. */
+	for (j = 0; j < 5; j++) {
+		for (i = 0; i < p[j].len; i++) {
+			/* For each variable length field, the MSB must be
+			 * transmitted first. Rotate through the field bits,
+			 * starting with the MSB, and move each bit into the
+			 * the 1st (2^1) bit position (this is the bit position
+			 * corresponding to the MgmtData bit of the PhyCtrl
+			 * register for the IPG).
+			 *
+			 * Example: ST = 01;
+			 *
+			 *          First write a '0' to bit 1 of the PhyCtrl
+			 *          register, then write a '1' to bit 1 of the
+			 *          PhyCtrl register.
+			 *
+			 * To do this, right shift the MSB of ST by the value:
+			 * [field length - 1 - #ST bits already written]
+			 * then left shift this result by 1.
+			 */
+			data  = (p[j].field >> (p[j].len - 1 - i)) << 1;
+			data &= IPG_PC_MGMTDATA;
+			data |= polarity | IPG_PC_MGMTDIR;
+
+			ipg_drive_phy_ctl_low_high(ioaddr, data);
+		}
+	}
+
+	send_three_state(ioaddr, polarity);
+
+	read_phy_bit(ioaddr, polarity);
+
+	/*
+	 * For a read cycle, the bits for the next two fields (TA and
+	 * DATA) are driven by the PHY (the IPG reads these bits).
+	 */
+	for (i = 0; i < p[6].len; i++) {
+		p[6].field |=
+		    (read_phy_bit(ioaddr, polarity) << (p[6].len - 1 - i));
+	}
+
+	send_three_state(ioaddr, polarity);
+	send_three_state(ioaddr, polarity);
+	send_three_state(ioaddr, polarity);
+	send_end(ioaddr, polarity);
+
+	/* Return the value of the DATA field. */
+	return p[6].field;
+}
+
+/*
+ * Write to a register from the Physical Layer device located
+ * on the IPG NIC, using the IPG PHYCTRL register.
+ */
+static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
+{
+	void __iomem *ioaddr = ipg_ioaddr(dev);
+	/*
+	 * The GMII mangement frame structure for a read is as follows:
+	 *
+	 * |Preamble|st|op|phyad|regad|ta|      data      |idle|
+	 * |< 32 1s>|01|10|AAAAA|RRRRR|z0|DDDDDDDDDDDDDDDD|z   |
+	 *
+	 * <32 1s> = 32 consecutive logic 1 values
+	 * A = bit of Physical Layer device address (MSB first)
+	 * R = bit of register address (MSB first)
+	 * z = High impedance state
+	 * D = bit of write data (MSB first)
+	 *
+	 * Transmission order is 'Preamble' field first, bits transmitted
+	 * left to right (first to last).
+	 */
+	struct {
+		u32 field;
+		unsigned int len;
+	} p[] = {
+		{ GMII_PREAMBLE,	32 },	/* Preamble */
+		{ GMII_ST,		2  },	/* ST */
+		{ GMII_WRITE,		2  },	/* OP */
+		{ phy_id,		5  },	/* PHYAD */
+		{ phy_reg,		5  },	/* REGAD */
+		{ 0x0002,		2  },	/* TA */
+		{ val & 0xffff,		16 },	/* DATA */
+		{ 0x0000,		1  }	/* IDLE */
+	};
+	unsigned int i, j;
+	u8 polarity, data;
+
+	polarity  = ipg_r8(PHY_CTRL);
+	polarity &= (IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
+
+	/* Create the Preamble, ST, OP, PHYAD, and REGAD field. */
+	for (j = 0; j < 7; j++) {
+		for (i = 0; i < p[j].len; i++) {
+			/* For each variable length field, the MSB must be
+			 * transmitted first. Rotate through the field bits,
+			 * starting with the MSB, and move each bit into the
+			 * the 1st (2^1) bit position (this is the bit position
+			 * corresponding to the MgmtData bit of the PhyCtrl
+			 * register for the IPG).
+			 *
+			 * Example: ST = 01;
+			 *
+			 *          First write a '0' to bit 1 of the PhyCtrl
+			 *          register, then write a '1' to bit 1 of the
+			 *          PhyCtrl register.
+			 *
+			 * To do this, right shift the MSB of ST by the value:
+			 * [field length - 1 - #ST bits already written]
+			 * then left shift this result by 1.
+			 */
+			data  = (p[j].field >> (p[j].len - 1 - i)) << 1;
+			data &= IPG_PC_MGMTDATA;
+			data |= polarity | IPG_PC_MGMTDIR;
+
+			ipg_drive_phy_ctl_low_high(ioaddr, data);
+		}
+	}
+
+	/* The last cycle is a tri-state, so read from the PHY. */
+	for (j = 7; j < 8; j++) {
+		for (i = 0; i < p[j].len; i++) {
+			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | polarity);
+
+			p[j].field |= ((ipg_r8(PHY_CTRL) &
+				IPG_PC_MGMTDATA) >> 1) << (p[j].len - 1 - i);
+
+			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | polarity);
+		}
+	}
+}
+
+/* Set LED_Mode JES20040127EEPROM */
+static void ipg_set_led_mode(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	u32 mode;
+
+	mode = ipg_r32(ASIC_CTRL);
+	mode &= ~(IPG_AC_LED_MODE_BIT_1 | IPG_AC_LED_MODE | IPG_AC_LED_SPEED);
+
+	if ((sp->LED_Mode & 0x03) > 1)
+		mode |= IPG_AC_LED_MODE_BIT_1;	/* Write Asic Control Bit 29 */
+
+	if ((sp->LED_Mode & 0x01) == 1)
+		mode |= IPG_AC_LED_MODE;	/* Write Asic Control Bit 14 */
+
+	if ((sp->LED_Mode & 0x08) == 8)
+		mode |= IPG_AC_LED_SPEED;	/* Write Asic Control Bit 27 */
+
+	ipg_w32(mode, ASIC_CTRL);
+}
+
+/* Set PHYSet JES20040127EEPROM */
+static void ipg_set_phy_set(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	int physet;
+
+	physet = ipg_r8(PHY_SET);
+	physet &= ~(IPG_PS_MEM_LENB9B | IPG_PS_MEM_LEN9 | IPG_PS_NON_COMPDET);
+	physet |= ((sp->LED_Mode & 0x70) >> 4);
+	ipg_w8(physet, PHY_SET);
+}
+
+static int ipg_reset(struct net_device *dev, u32 resetflags)
+{
+	/* Assert functional resets via the IPG AsicCtrl
+	 * register as specified by the 'resetflags' input
+	 * parameter.
+	 */
+	void __iomem *ioaddr = ipg_ioaddr(dev);	//JES20040127EEPROM:
+	unsigned int timeout_count = 0;
+
+	IPG_DEBUG_MSG("_reset\n");
+
+	ipg_w32(ipg_r32(ASIC_CTRL) | resetflags, ASIC_CTRL);
+
+	/* Delay added to account for problem with 10Mbps reset. */
+	mdelay(IPG_AC_RESETWAIT);
+
+	while (IPG_AC_RESET_BUSY & ipg_r32(ASIC_CTRL)) {
+		mdelay(IPG_AC_RESETWAIT);
+		if (++timeout_count > IPG_AC_RESET_TIMEOUT)
+			return -ETIME;
+	}
+	/* Set LED Mode in Asic Control JES20040127EEPROM */
+	ipg_set_led_mode(dev);
+
+	/* Set PHYSet Register Value JES20040127EEPROM */
+	ipg_set_phy_set(dev);
+	return 0;
+}
+
+/* Find the GMII PHY address. */
+static int ipg_find_phyaddr(struct net_device *dev)
+{
+	unsigned int phyaddr, i;
+
+	for (i = 0; i < 32; i++) {
+		u32 status;
+
+		/* Search for the correct PHY address among 32 possible. */
+		phyaddr = (IPG_NIC_PHY_ADDRESS + i) % 32;
+
+		/* 10/22/03 Grace change verify from GMII_PHY_STATUS to
+		   GMII_PHY_ID1
+		 */
+
+		status = mdio_read(dev, phyaddr, MII_BMSR);
+
+		if ((status != 0xFFFF) && (status != 0))
+			return phyaddr;
+	}
+
+	return 0x1f;
+}
+
+/*
+ * Configure IPG based on result of IEEE 802.3 PHY
+ * auto-negotiation.
+ */
+static int ipg_config_autoneg(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	unsigned int txflowcontrol;
+	unsigned int rxflowcontrol;
+	unsigned int fullduplex;
+	unsigned int gig;
+	u32 mac_ctrl_val;
+	u32 asicctrl;
+	u8 phyctrl;
+
+	IPG_DEBUG_MSG("_config_autoneg\n");
+
+	asicctrl = ipg_r32(ASIC_CTRL);
+	phyctrl = ipg_r8(PHY_CTRL);
+	mac_ctrl_val = ipg_r32(MAC_CTRL);
+
+	/* Set flags for use in resolving auto-negotation, assuming
+	 * non-1000Mbps, half duplex, no flow control.
+	 */
+	fullduplex = 0;
+	txflowcontrol = 0;
+	rxflowcontrol = 0;
+	gig = 0;
+
+	/* To accomodate a problem in 10Mbps operation,
+	 * set a global flag if PHY running in 10Mbps mode.
+	 */
+	sp->tenmbpsmode = 0;
+
+	printk(KERN_INFO "%s: Link speed = ", dev->name);
+
+	/* Determine actual speed of operation. */
+	switch (phyctrl & IPG_PC_LINK_SPEED) {
+	case IPG_PC_LINK_SPEED_10MBPS:
+		printk("10Mbps.\n");
+		printk(KERN_INFO "%s: 10Mbps operational mode enabled.\n",
+		       dev->name);
+		sp->tenmbpsmode = 1;
+		break;
+	case IPG_PC_LINK_SPEED_100MBPS:
+		printk("100Mbps.\n");
+		break;
+	case IPG_PC_LINK_SPEED_1000MBPS:
+		printk("1000Mbps.\n");
+		gig = 1;
+		break;
+	default:
+		printk("undefined!\n");
+		return 0;
+	}
+
+	if (phyctrl & IPG_PC_DUPLEX_STATUS) {
+		fullduplex = 1;
+		txflowcontrol = 1;
+		rxflowcontrol = 1;
+	}
+
+	/* Configure full duplex, and flow control. */
+	if (fullduplex == 1) {
+		/* Configure IPG for full duplex operation. */
+		printk(KERN_INFO "%s: setting full duplex, ", dev->name);
+
+		mac_ctrl_val |= IPG_MC_DUPLEX_SELECT_FD;
+
+		if (txflowcontrol == 1) {
+			printk("TX flow control");
+			mac_ctrl_val |= IPG_MC_TX_FLOW_CONTROL_ENABLE;
+		} else {
+			printk("no TX flow control");
+			mac_ctrl_val &= ~IPG_MC_TX_FLOW_CONTROL_ENABLE;
+		}
+
+		if (rxflowcontrol == 1) {
+			printk(", RX flow control.");
+			mac_ctrl_val |= IPG_MC_RX_FLOW_CONTROL_ENABLE;
+		} else {
+			printk(", no RX flow control.");
+			mac_ctrl_val &= ~IPG_MC_RX_FLOW_CONTROL_ENABLE;
+		}
+
+		printk("\n");
+	} else {
+		/* Configure IPG for half duplex operation. */
+	        printk(KERN_INFO "%s: setting half duplex, "
+		       "no TX flow control, no RX flow control.\n", dev->name);
+
+		mac_ctrl_val &= ~IPG_MC_DUPLEX_SELECT_FD &
+			~IPG_MC_TX_FLOW_CONTROL_ENABLE &
+			~IPG_MC_RX_FLOW_CONTROL_ENABLE;
+	}
+	ipg_w32(mac_ctrl_val, MAC_CTRL);
+	return 0;
+}
+
+/* Determine and configure multicast operation and set
+ * receive mode for IPG.
+ */
+static void ipg_nic_set_multicast_list(struct net_device *dev)
+{
+	void __iomem *ioaddr = ipg_ioaddr(dev);
+	struct dev_mc_list *mc_list_ptr;
+	unsigned int hashindex;
+	u32 hashtable[2];
+	u8 receivemode;
+
+	IPG_DEBUG_MSG("_nic_set_multicast_list\n");
+
+	receivemode = IPG_RM_RECEIVEUNICAST | IPG_RM_RECEIVEBROADCAST;
+
+	if (dev->flags & IFF_PROMISC) {
+		/* NIC to be configured in promiscuous mode. */
+		receivemode = IPG_RM_RECEIVEALLFRAMES;
+	} else if ((dev->flags & IFF_ALLMULTI) ||
+		   (dev->flags & IFF_MULTICAST &
+		    (dev->mc_count > IPG_MULTICAST_HASHTABLE_SIZE))) {
+		/* NIC to be configured to receive all multicast
+		 * frames. */
+		receivemode |= IPG_RM_RECEIVEMULTICAST;
+	} else if (dev->flags & IFF_MULTICAST & (dev->mc_count > 0)) {
+		/* NIC to be configured to receive selected
+		 * multicast addresses. */
+		receivemode |= IPG_RM_RECEIVEMULTICASTHASH;
+	}
+
+	/* Calculate the bits to set for the 64 bit, IPG HASHTABLE.
+	 * The IPG applies a cyclic-redundancy-check (the same CRC
+	 * used to calculate the frame data FCS) to the destination
+	 * address all incoming multicast frames whose destination
+	 * address has the multicast bit set. The least significant
+	 * 6 bits of the CRC result are used as an addressing index
+	 * into the hash table. If the value of the bit addressed by
+	 * this index is a 1, the frame is passed to the host system.
+	 */
+
+	/* Clear hashtable. */
+	hashtable[0] = 0x00000000;
+	hashtable[1] = 0x00000000;
+
+	/* Cycle through all multicast addresses to filter. */
+	for (mc_list_ptr = dev->mc_list;
+	     mc_list_ptr != NULL; mc_list_ptr = mc_list_ptr->next) {
+		/* Calculate CRC result for each multicast address. */
+		hashindex = crc32_le(0xffffffff, mc_list_ptr->dmi_addr,
+				     ETH_ALEN);
+
+		/* Use only the least significant 6 bits. */
+		hashindex = hashindex & 0x3F;
+
+		/* Within "hashtable", set bit number "hashindex"
+		 * to a logic 1.
+		 */
+		set_bit(hashindex, (void *)hashtable);
+	}
+
+	/* Write the value of the hashtable, to the 4, 16 bit
+	 * HASHTABLE IPG registers.
+	 */
+	ipg_w32(hashtable[0], HASHTABLE_0);
+	ipg_w32(hashtable[1], HASHTABLE_1);
+
+	ipg_w8(IPG_RM_RSVD_MASK & receivemode, RECEIVE_MODE);
+
+	IPG_DEBUG_MSG("ReceiveMode = %x\n", ipg_r8(RECEIVE_MODE));
+}
+
+static int ipg_io_config(struct net_device *dev)
+{
+	void __iomem *ioaddr = ipg_ioaddr(dev);
+	u32 origmacctrl;
+	u32 restoremacctrl;
+
+	IPG_DEBUG_MSG("_io_config\n");
+
+	origmacctrl = ipg_r32(MAC_CTRL);
+
+	restoremacctrl = origmacctrl | IPG_MC_STATISTICS_ENABLE;
+
+	/* Based on compilation option, determine if FCS is to be
+	 * stripped on receive frames by IPG.
+	 */
+	if (!IPG_STRIP_FCS_ON_RX)
+		restoremacctrl |= IPG_MC_RCV_FCS;
+
+	/* Determine if transmitter and/or receiver are
+	 * enabled so we may restore MACCTRL correctly.
+	 */
+	if (origmacctrl & IPG_MC_TX_ENABLED)
+		restoremacctrl |= IPG_MC_TX_ENABLE;
+
+	if (origmacctrl & IPG_MC_RX_ENABLED)
+		restoremacctrl |= IPG_MC_RX_ENABLE;
+
+	/* Transmitter and receiver must be disabled before setting
+	 * IFSSelect.
+	 */
+	ipg_w32((origmacctrl & (IPG_MC_RX_DISABLE | IPG_MC_TX_DISABLE)) &
+		IPG_MC_RSVD_MASK, MAC_CTRL);
+
+	/* Now that transmitter and receiver are disabled, write
+	 * to IFSSelect.
+	 */
+	ipg_w32((origmacctrl & IPG_MC_IFS_96BIT) & IPG_MC_RSVD_MASK, MAC_CTRL);
+
+	/* Set RECEIVEMODE register. */
+	ipg_nic_set_multicast_list(dev);
+
+	ipg_w16(IPG_MAX_RXFRAME_SIZE, MAX_FRAME_SIZE);
+
+	ipg_w8(IPG_RXDMAPOLLPERIOD_VALUE,   RX_DMA_POLL_PERIOD);
+	ipg_w8(IPG_RXDMAURGENTTHRESH_VALUE, RX_DMA_URGENT_THRESH);
+	ipg_w8(IPG_RXDMABURSTTHRESH_VALUE,  RX_DMA_BURST_THRESH);
+	ipg_w8(IPG_TXDMAPOLLPERIOD_VALUE,   TX_DMA_POLL_PERIOD);
+	ipg_w8(IPG_TXDMAURGENTTHRESH_VALUE, TX_DMA_URGENT_THRESH);
+	ipg_w8(IPG_TXDMABURSTTHRESH_VALUE,  TX_DMA_BURST_THRESH);
+	ipg_w16((IPG_IE_HOST_ERROR | IPG_IE_TX_DMA_COMPLETE |
+		 IPG_IE_TX_COMPLETE | IPG_IE_INT_REQUESTED |
+		 IPG_IE_UPDATE_STATS | IPG_IE_LINK_EVENT |
+		 IPG_IE_RX_DMA_COMPLETE | IPG_IE_RX_DMA_PRIORITY), INT_ENABLE);
+	ipg_w16(IPG_FLOWONTHRESH_VALUE,  FLOW_ON_THRESH);
+	ipg_w16(IPG_FLOWOFFTHRESH_VALUE, FLOW_OFF_THRESH);
+
+	/* IPG multi-frag frame bug workaround.
+	 * Per silicon revision B3 eratta.
+	 */
+	ipg_w16(ipg_r16(DEBUG_CTRL) | 0x0200, DEBUG_CTRL);
+
+	/* IPG TX poll now bug workaround.
+	 * Per silicon revision B3 eratta.
+	 */
+	ipg_w16(ipg_r16(DEBUG_CTRL) | 0x0010, DEBUG_CTRL);
+
+	/* IPG RX poll now bug workaround.
+	 * Per silicon revision B3 eratta.
+	 */
+	ipg_w16(ipg_r16(DEBUG_CTRL) | 0x0020, DEBUG_CTRL);
+
+	/* Now restore MACCTRL to original setting. */
+	ipg_w32(IPG_MC_RSVD_MASK & restoremacctrl, MAC_CTRL);
+
+	/* Disable unused RMON statistics. */
+	ipg_w32(IPG_RZ_ALL, RMON_STATISTICS_MASK);
+
+	/* Disable unused MIB statistics. */
+	ipg_w32(IPG_SM_MACCONTROLFRAMESXMTD | IPG_SM_MACCONTROLFRAMESRCVD |
+		IPG_SM_BCSTOCTETXMTOK_BCSTFRAMESXMTDOK | IPG_SM_TXJUMBOFRAMES |
+		IPG_SM_MCSTOCTETXMTOK_MCSTFRAMESXMTDOK | IPG_SM_RXJUMBOFRAMES |
+		IPG_SM_BCSTOCTETRCVDOK_BCSTFRAMESRCVDOK |
+		IPG_SM_UDPCHECKSUMERRORS | IPG_SM_TCPCHECKSUMERRORS |
+		IPG_SM_IPCHECKSUMERRORS, STATISTICS_MASK);
+
+	return 0;
+}
+
+/*
+ * Create a receive buffer within system memory and update
+ * NIC private structure appropriately.
+ */
+static int ipg_get_rxbuff(struct net_device *dev, int entry)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	struct ipg_rx *rxfd = sp->rxd + entry;
+	struct sk_buff *skb;
+	u64 rxfragsize;
+
+	IPG_DEBUG_MSG("_get_rxbuff\n");
+
+	skb = netdev_alloc_skb(dev, IPG_RXSUPPORT_SIZE + NET_IP_ALIGN);
+	if (!skb) {
+		sp->RxBuff[entry] = NULL;
+		return -ENOMEM;
+	}
+
+	/* Adjust the data start location within the buffer to
+	 * align IP address field to a 16 byte boundary.
+	 */
+	skb_reserve(skb, NET_IP_ALIGN);
+
+	/* Associate the receive buffer with the IPG NIC. */
+	skb->dev = dev;
+
+	/* Save the address of the sk_buff structure. */
+	sp->RxBuff[entry] = skb;
+
+	rxfd->frag_info = cpu_to_le64(pci_map_single(sp->pdev, skb->data,
+		sp->rx_buf_sz, PCI_DMA_FROMDEVICE));
+
+	/* Set the RFD fragment length. */
+	rxfragsize = IPG_RXFRAG_SIZE;
+	rxfd->frag_info |= cpu_to_le64((rxfragsize << 48) & IPG_RFI_FRAGLEN);
+
+	return 0;
+}
+
+static int init_rfdlist(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	unsigned int i;
+
+	IPG_DEBUG_MSG("_init_rfdlist\n");
+
+	for (i = 0; i < IPG_RFDLIST_LENGTH; i++) {
+		struct ipg_rx *rxfd = sp->rxd + i;
+
+		if (sp->RxBuff[i]) {
+			pci_unmap_single(sp->pdev,
+				le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
+				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+			IPG_DEV_KFREE_SKB(sp->RxBuff[i]);
+			sp->RxBuff[i] = NULL;
+		}
+
+		/* Clear out the RFS field. */
+		rxfd->rfs = 0x0000000000000000;
+
+		if (ipg_get_rxbuff(dev, i) < 0) {
+			/*
+			 * A receive buffer was not ready, break the
+			 * RFD list here.
+			 */
+			IPG_DEBUG_MSG("Cannot allocate Rx buffer.\n");
+
+			/* Just in case we cannot allocate a single RFD.
+			 * Should not occur.
+			 */
+			if (i == 0) {
+				printk(KERN_ERR "%s: No memory available"
+					" for RFD list.\n", dev->name);
+				return -ENOMEM;
+			}
+		}
+
+		rxfd->next_desc = cpu_to_le64(sp->rxd_map +
+			sizeof(struct ipg_rx)*(i + 1));
+	}
+	sp->rxd[i - 1].next_desc = cpu_to_le64(sp->rxd_map);
+
+	sp->rx_current = 0;
+	sp->rx_dirty = 0;
+
+	/* Write the location of the RFDList to the IPG. */
+	ipg_w32((u32) sp->rxd_map, RFD_LIST_PTR_0);
+	ipg_w32(0x00000000, RFD_LIST_PTR_1);
+
+	return 0;
+}
+
+static void init_tfdlist(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	unsigned int i;
+
+	IPG_DEBUG_MSG("_init_tfdlist\n");
+
+	for (i = 0; i < IPG_TFDLIST_LENGTH; i++) {
+		struct ipg_tx *txfd = sp->txd + i;
+
+		txfd->tfc = cpu_to_le64(IPG_TFC_TFDDONE);
+
+		if (sp->TxBuff[i]) {
+			IPG_DEV_KFREE_SKB(sp->TxBuff[i]);
+			sp->TxBuff[i] = NULL;
+		}
+
+		txfd->next_desc = cpu_to_le64(sp->txd_map +
+			sizeof(struct ipg_tx)*(i + 1));
+	}
+	sp->txd[i - 1].next_desc = cpu_to_le64(sp->txd_map);
+
+	sp->tx_current = 0;
+	sp->tx_dirty = 0;
+
+	/* Write the location of the TFDList to the IPG. */
+	IPG_DDEBUG_MSG("Starting TFDListPtr = %8.8x\n",
+		       (u32) sp->txd_map);
+	ipg_w32((u32) sp->txd_map, TFD_LIST_PTR_0);
+	ipg_w32(0x00000000, TFD_LIST_PTR_1);
+
+	sp->ResetCurrentTFD = 1;
+}
+
+/*
+ * Free all transmit buffers which have already been transfered
+ * via DMA to the IPG.
+ */
+static void ipg_nic_txfree(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	const unsigned int curr = ipg_r32(TFD_LIST_PTR_0) -
+		(sp->txd_map / sizeof(struct ipg_tx)) - 1;
+	unsigned int released, pending;
+
+	IPG_DEBUG_MSG("_nic_txfree\n");
+
+	pending = sp->tx_current - sp->tx_dirty;
+
+	for (released = 0; released < pending; released++) {
+		unsigned int dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
+		struct sk_buff *skb = sp->TxBuff[dirty];
+		struct ipg_tx *txfd = sp->txd + dirty;
+
+		IPG_DEBUG_MSG("TFC = %16.16lx\n", (unsigned long) txfd->tfc);
+
+		/* Look at each TFD's TFC field beginning
+		 * at the last freed TFD up to the current TFD.
+		 * If the TFDDone bit is set, free the associated
+		 * buffer.
+		 */
+		if (dirty == curr)
+			break;
+
+		/* Setup TFDDONE for compatible issue. */
+		txfd->tfc |= cpu_to_le64(IPG_TFC_TFDDONE);
+
+		/* Free the transmit buffer. */
+		if (skb) {
+			pci_unmap_single(sp->pdev,
+				le64_to_cpu(txfd->frag_info & ~IPG_TFI_FRAGLEN),
+				skb->len, PCI_DMA_TODEVICE);
+
+			IPG_DEV_KFREE_SKB(skb);
+
+			sp->TxBuff[dirty] = NULL;
+		}
+	}
+
+	sp->tx_dirty += released;
+
+	if (netif_queue_stopped(dev) &&
+	    (sp->tx_current != (sp->tx_dirty + IPG_TFDLIST_LENGTH))) {
+		netif_wake_queue(dev);
+	}
+}
+
+static void ipg_tx_timeout(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+
+	ipg_reset(dev, IPG_AC_TX_RESET | IPG_AC_DMA | IPG_AC_NETWORK |
+		  IPG_AC_FIFO);
+
+	spin_lock_irq(&sp->lock);
+
+	/* Re-configure after DMA reset. */
+	if (ipg_io_config(dev) < 0) {
+		printk(KERN_INFO "%s: Error during re-configuration.\n",
+		       dev->name);
+	}
+
+	init_tfdlist(dev);
+
+	spin_unlock_irq(&sp->lock);
+
+	ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_TX_ENABLE) & IPG_MC_RSVD_MASK,
+		MAC_CTRL);
+}
+
+/*
+ * For TxComplete interrupts, free all transmit
+ * buffers which have already been transfered via DMA
+ * to the IPG.
+ */
+static void ipg_nic_txcleanup(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	unsigned int i;
+
+	IPG_DEBUG_MSG("_nic_txcleanup\n");
+
+	for (i = 0; i < IPG_TFDLIST_LENGTH; i++) {
+		/* Reading the TXSTATUS register clears the
+		 * TX_COMPLETE interrupt.
+		 */
+		u32 txstatusdword = ipg_r32(TX_STATUS);
+
+		IPG_DEBUG_MSG("TxStatus = %8.8x\n", txstatusdword);
+
+		/* Check for Transmit errors. Error bits only valid if
+		 * TX_COMPLETE bit in the TXSTATUS register is a 1.
+		 */
+		if (!(txstatusdword & IPG_TS_TX_COMPLETE))
+			break;
+
+		/* If in 10Mbps mode, indicate transmit is ready. */
+		if (sp->tenmbpsmode) {
+			netif_wake_queue(dev);
+		}
+
+		/* Transmit error, increment stat counters. */
+		if (txstatusdword & IPG_TS_TX_ERROR) {
+			IPG_DEBUG_MSG("Transmit error.\n");
+			sp->stats.tx_errors++;
+		}
+
+		/* Late collision, re-enable transmitter. */
+		if (txstatusdword & IPG_TS_LATE_COLLISION) {
+			IPG_DEBUG_MSG("Late collision on transmit.\n");
+			ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_TX_ENABLE) &
+				IPG_MC_RSVD_MASK, MAC_CTRL);
+		}
+
+		/* Maximum collisions, re-enable transmitter. */
+		if (txstatusdword & IPG_TS_TX_MAX_COLL) {
+			IPG_DEBUG_MSG("Maximum collisions on transmit.\n");
+			ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_TX_ENABLE) &
+				IPG_MC_RSVD_MASK, MAC_CTRL);
+		}
+
+		/* Transmit underrun, reset and re-enable
+		 * transmitter.
+		 */
+		if (txstatusdword & IPG_TS_TX_UNDERRUN) {
+			IPG_DEBUG_MSG("Transmitter underrun.\n");
+			sp->stats.tx_fifo_errors++;
+			ipg_reset(dev, IPG_AC_TX_RESET | IPG_AC_DMA |
+				  IPG_AC_NETWORK | IPG_AC_FIFO);
+
+			/* Re-configure after DMA reset. */
+			if (ipg_io_config(dev) < 0) {
+				printk(KERN_INFO
+				       "%s: Error during re-configuration.\n",
+				       dev->name);
+			}
+			init_tfdlist(dev);
+
+			ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_TX_ENABLE) &
+				IPG_MC_RSVD_MASK, MAC_CTRL);
+		}
+	}
+
+	ipg_nic_txfree(dev);
+}
+
+/* Provides statistical information about the IPG NIC. */
+struct net_device_stats *ipg_nic_get_stats(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	u16 temp1;
+	u16 temp2;
+
+	IPG_DEBUG_MSG("_nic_get_stats\n");
+
+	/* Check to see if the NIC has been initialized via nic_open,
+	 * before trying to read statistic registers.
+	 */
+	if (!test_bit(__LINK_STATE_START, &dev->state))
+		return &sp->stats;
+
+	sp->stats.rx_packets += ipg_r32(IPG_FRAMESRCVDOK);
+	sp->stats.tx_packets += ipg_r32(IPG_FRAMESXMTDOK);
+	sp->stats.rx_bytes += ipg_r32(IPG_OCTETRCVOK);
+	sp->stats.tx_bytes += ipg_r32(IPG_OCTETXMTOK);
+	temp1 = ipg_r16(IPG_FRAMESLOSTRXERRORS);
+	sp->stats.rx_errors += temp1;
+	sp->stats.rx_missed_errors += temp1;
+	temp1 = ipg_r32(IPG_SINGLECOLFRAMES) + ipg_r32(IPG_MULTICOLFRAMES) +
+		ipg_r32(IPG_LATECOLLISIONS);
+	temp2 = ipg_r16(IPG_CARRIERSENSEERRORS);
+	sp->stats.collisions += temp1;
+	sp->stats.tx_dropped += ipg_r16(IPG_FRAMESABORTXSCOLLS);
+	sp->stats.tx_errors += ipg_r16(IPG_FRAMESWEXDEFERRAL) +
+		ipg_r32(IPG_FRAMESWDEFERREDXMT) + temp1 + temp2;
+	sp->stats.multicast += ipg_r32(IPG_MCSTOCTETRCVDOK);
+
+	/* detailed tx_errors */
+	sp->stats.tx_carrier_errors += temp2;
+
+	/* detailed rx_errors */
+	sp->stats.rx_length_errors += ipg_r16(IPG_INRANGELENGTHERRORS) +
+		ipg_r16(IPG_FRAMETOOLONGERRRORS);
+	sp->stats.rx_crc_errors += ipg_r16(IPG_FRAMECHECKSEQERRORS);
+
+	/* Unutilized IPG statistic registers. */
+	ipg_r32(IPG_MCSTFRAMESRCVDOK);
+
+	return &sp->stats;
+}
+
+/* Restore used receive buffers. */
+static int ipg_nic_rxrestore(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	const unsigned int curr = sp->rx_current;
+	unsigned int dirty = sp->rx_dirty;
+
+	IPG_DEBUG_MSG("_nic_rxrestore\n");
+
+	for (dirty = sp->rx_dirty; curr - dirty > 0; dirty++) {
+		unsigned int entry = dirty % IPG_RFDLIST_LENGTH;
+
+		/* rx_copybreak may poke hole here and there. */
+		if (sp->RxBuff[entry])
+			continue;
+
+		/* Generate a new receive buffer to replace the
+		 * current buffer (which will be released by the
+		 * Linux system).
+		 */
+		if (ipg_get_rxbuff(dev, entry) < 0) {
+			IPG_DEBUG_MSG("Cannot allocate new Rx buffer.\n");
+
+			break;
+		}
+
+		/* Reset the RFS field. */
+		sp->rxd[entry].rfs = 0x0000000000000000;
+	}
+	sp->rx_dirty = dirty;
+
+	return 0;
+}
+
+#ifdef JUMBO_FRAME
+
+/* use jumboindex and jumbosize to control jumbo frame status
+   initial status is jumboindex=-1 and jumbosize=0
+   1. jumboindex = -1 and jumbosize=0 : previous jumbo frame has been done.
+   2. jumboindex != -1 and jumbosize != 0 : jumbo frame is not over size and receiving
+   3. jumboindex = -1 and jumbosize != 0 : jumbo frame is over size, already dump
+                previous receiving and need to continue dumping the current one
+*/
+enum {
+	NormalPacket,
+	ErrorPacket
+};
+
+enum {
+	Frame_NoStart_NoEnd	= 0,
+	Frame_WithStart		= 1,
+	Frame_WithEnd		= 10,
+	Frame_WithStart_WithEnd = 11
+};
+
+inline void ipg_nic_rx_free_skb(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	unsigned int entry = sp->rx_current % IPG_RFDLIST_LENGTH;
+
+	if (sp->RxBuff[entry]) {
+		struct ipg_rx *rxfd = sp->rxd + entry;
+
+		pci_unmap_single(sp->pdev,
+			le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
+			sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+		IPG_DEV_KFREE_SKB(sp->RxBuff[entry]);
+		sp->RxBuff[entry] = NULL;
+	}
+}
+
+inline int ipg_nic_rx_check_frame_type(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	struct ipg_rx *rxfd = sp->rxd + (sp->rx_current % IPG_RFDLIST_LENGTH);
+	int type = Frame_NoStart_NoEnd;
+
+	if (le64_to_cpu(rxfd->rfs) & IPG_RFS_FRAMESTART)
+		type += Frame_WithStart;
+	if (le64_to_cpu(rxfd->rfs) & IPG_RFS_FRAMEEND)
+		type += Frame_WithEnd;
+	return type;
+}
+
+inline int ipg_nic_rx_check_error(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	unsigned int entry = sp->rx_current % IPG_RFDLIST_LENGTH;
+	struct ipg_rx *rxfd = sp->rxd + entry;
+
+	if (IPG_DROP_ON_RX_ETH_ERRORS && (le64_to_cpu(rxfd->rfs) &
+	     (IPG_RFS_RXFIFOOVERRUN | IPG_RFS_RXRUNTFRAME |
+	      IPG_RFS_RXALIGNMENTERROR | IPG_RFS_RXFCSERROR |
+	      IPG_RFS_RXOVERSIZEDFRAME | IPG_RFS_RXLENGTHERROR))) {
+		IPG_DEBUG_MSG("Rx error, RFS = %16.16lx\n",
+			      (unsigned long) rxfd->rfs);
+
+		/* Increment general receive error statistic. */
+		sp->stats.rx_errors++;
+
+		/* Increment detailed receive error statistics. */
+		if (le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFIFOOVERRUN) {
+			IPG_DEBUG_MSG("RX FIFO overrun occured.\n");
+
+			sp->stats.rx_fifo_errors++;
+		}
+
+		if (le64_to_cpu(rxfd->rfs) & IPG_RFS_RXRUNTFRAME) {
+			IPG_DEBUG_MSG("RX runt occured.\n");
+			sp->stats.rx_length_errors++;
+		}
+
+		/* Do nothing for IPG_RFS_RXOVERSIZEDFRAME,
+		 * error count handled by a IPG statistic register.
+		 */
+
+		if (le64_to_cpu(rxfd->rfs) & IPG_RFS_RXALIGNMENTERROR) {
+			IPG_DEBUG_MSG("RX alignment error occured.\n");
+			sp->stats.rx_frame_errors++;
+		}
+
+		/* Do nothing for IPG_RFS_RXFCSERROR, error count
+		 * handled by a IPG statistic register.
+		 */
+
+		/* Free the memory associated with the RX
+		 * buffer since it is erroneous and we will
+		 * not pass it to higher layer processes.
+		 */
+		if (sp->RxBuff[entry]) {
+			pci_unmap_single(sp->pdev,
+				le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
+				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+
+			IPG_DEV_KFREE_SKB(sp->RxBuff[entry]);
+			sp->RxBuff[entry] = NULL;
+		}
+		return ErrorPacket;
+	}
+	return NormalPacket;
+}
+
+static void ipg_nic_rx_with_start_and_end(struct net_device *dev,
+					  struct ipg_nic_private *sp,
+					  struct ipg_rx *rxfd, unsigned entry)
+{
+	struct SJumbo *jumbo = &sp->Jumbo;
+	struct sk_buff *skb;
+	int framelen;
+
+	if (jumbo->FoundStart) {
+		IPG_DEV_KFREE_SKB(jumbo->skb);
+		jumbo->FoundStart = 0;
+		jumbo->CurrentSize = 0;
+		jumbo->skb = NULL;
+	}
+
+	// 1: found error, 0 no error
+	if (ipg_nic_rx_check_error(dev) != NormalPacket)
+		return;
+
+	skb = sp->RxBuff[entry];
+	if (!skb)
+		return;
+
+	// accept this frame and send to upper layer
+	framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
+	if (framelen > IPG_RXFRAG_SIZE)
+		framelen = IPG_RXFRAG_SIZE;
+
+	skb_put(skb, framelen);
+	skb->protocol = eth_type_trans(skb, dev);
+	skb->ip_summed = CHECKSUM_NONE;
+	netif_rx(skb);
+	dev->last_rx = jiffies;
+	sp->RxBuff[entry] = NULL;
+}
+
+static void ipg_nic_rx_with_start(struct net_device *dev,
+				  struct ipg_nic_private *sp,
+				  struct ipg_rx *rxfd, unsigned entry)
+{
+	struct SJumbo *jumbo = &sp->Jumbo;
+	struct pci_dev *pdev = sp->pdev;
+	struct sk_buff *skb;
+
+	// 1: found error, 0 no error
+	if (ipg_nic_rx_check_error(dev) != NormalPacket)
+		return;
+
+	// accept this frame and send to upper layer
+	skb = sp->RxBuff[entry];
+	if (!skb)
+		return;
+
+	if (jumbo->FoundStart)
+		IPG_DEV_KFREE_SKB(jumbo->skb);
+
+	pci_unmap_single(pdev, le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
+			 sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+
+	skb_put(skb, IPG_RXFRAG_SIZE);
+
+	jumbo->FoundStart = 1;
+	jumbo->CurrentSize = IPG_RXFRAG_SIZE;
+	jumbo->skb = skb;
+
+	sp->RxBuff[entry] = NULL;
+	dev->last_rx = jiffies;
+}
+
+static void ipg_nic_rx_with_end(struct net_device *dev,
+				struct ipg_nic_private *sp,
+				struct ipg_rx *rxfd, unsigned entry)
+{
+	struct SJumbo *jumbo = &sp->Jumbo;
+
+	//1: found error, 0 no error
+	if (ipg_nic_rx_check_error(dev) == NormalPacket) {
+		struct sk_buff *skb = sp->RxBuff[entry];
+
+		if (!skb)
+			return;
+
+		if (jumbo->FoundStart) {
+			int framelen, endframelen;
+
+			framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
+
+			endframeLen = framelen - jumbo->CurrentSize;
+			/*
+			if (framelen > IPG_RXFRAG_SIZE)
+				framelen=IPG_RXFRAG_SIZE;
+			 */
+			if (framelen > IPG_RXSUPPORT_SIZE)
+				IPG_DEV_KFREE_SKB(jumbo->skb);
+			else {
+				memcpy(skb_put(jumbo->skb, endframeLen),
+				       skb->data, endframeLen);
+
+				jumbo->skb->protocol =
+				    eth_type_trans(jumbo->skb, dev);
+
+				jumbo->skb->ip_summed = CHECKSUM_NONE;
+				netif_rx(jumbo->skb);
+			}
+		}
+
+		dev->last_rx = jiffies;
+		jumbo->FoundStart = 0;
+		jumbo->CurrentSize = 0;
+		jumbo->skb = NULL;
+
+		ipg_nic_rx_free_skb(dev);
+	} else {
+		IPG_DEV_KFREE_SKB(jumbo->skb);
+		jumbo->FoundStart = 0;
+		jumbo->CurrentSize = 0;
+		jumbo->skb = NULL;
+	}
+}
+
+static void ipg_nic_rx_no_start_no_end(struct net_device *dev,
+				       struct ipg_nic_private *sp,
+				       struct ipg_rx *rxfd, unsigned entry)
+{
+	struct SJumbo *jumbo = &sp->Jumbo;
+
+	//1: found error, 0 no error
+	if (ipg_nic_rx_check_error(dev) == NormalPacket) {
+		struct sk_buff *skb = sp->RxBuff[entry];
+
+		if (skb) {
+			if (jumbo->FoundStart) {
+				jumbo->CurrentSize += IPG_RXFRAG_SIZE;
+				if (jumbo->CurrentSize <= IPG_RXSUPPORT_SIZE) {
+					memcpy(skb_put(jumbo->skb,
+						       IPG_RXFRAG_SIZE),
+					       skb->data, IPG_RXFRAG_SIZE);
+				}
+			}
+			dev->last_rx = jiffies;
+			ipg_nic_rx_free_skb(dev);
+		}
+	} else {
+		IPG_DEV_KFREE_SKB(jumbo->skb);
+		jumbo->FoundStart = 0;
+		jumbo->CurrentSize = 0;
+		jumbo->skb = NULL;
+	}
+}
+
+static int ipg_nic_rx(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	unsigned int curr = sp->rx_current;
+	void __iomem *ioaddr = sp->ioaddr;
+	unsigned int i;
+
+	IPG_DEBUG_MSG("_nic_rx\n");
+
+	for (i = 0; i < IPG_MAXRFDPROCESS_COUNT; i++, curr++) {
+		unsigned int entry = curr % IPG_RFDLIST_LENGTH;
+		struct ipg_rx *rxfd = sp->rxd + entry;
+
+		if (!(rxfd->rfs & le64_to_cpu(IPG_RFS_RFDDONE)))
+			break;
+
+		switch (ipg_nic_rx_check_frame_type(dev)) {
+		case Frame_WithStart_WithEnd:
+			ipg_nic_rx_with_start_and_end(dev, tp, rxfd, entry);
+			break;
+		case Frame_WithStart:
+			ipg_nic_rx_with_start(dev, tp, rxfd, entry);
+			break;
+		case Frame_WithEnd:
+			ipg_nic_rx_with_end(dev, tp, rxfd, entry);
+			break;
+		case Frame_NoStart_NoEnd:
+			ipg_nic_rx_no_start_no_end(dev, tp, rxfd, entry);
+			break;
+		}
+	}
+
+	sp->rx_current = curr;
+
+	if (i == IPG_MAXRFDPROCESS_COUNT) {
+		/* There are more RFDs to process, however the
+		 * allocated amount of RFD processing time has
+		 * expired. Assert Interrupt Requested to make
+		 * sure we come back to process the remaining RFDs.
+		 */
+		ipg_w32(ipg_r32(ASIC_CTRL) | IPG_AC_INT_REQUEST, ASIC_CTRL);
+	}
+
+	ipg_nic_rxrestore(dev);
+
+	return 0;
+}
+
+#else
+static int ipg_nic_rx(struct net_device *dev)
+{
+	/* Transfer received Ethernet frames to higher network layers. */
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	unsigned int curr = sp->rx_current;
+	void __iomem *ioaddr = sp->ioaddr;
+	struct ipg_rx *rxfd;
+	unsigned int i;
+
+	IPG_DEBUG_MSG("_nic_rx\n");
+
+#define __RFS_MASK \
+	cpu_to_le64(IPG_RFS_RFDDONE | IPG_RFS_FRAMESTART | IPG_RFS_FRAMEEND)
+
+	for (i = 0; i < IPG_MAXRFDPROCESS_COUNT; i++, curr++) {
+		unsigned int entry = curr % IPG_RFDLIST_LENGTH;
+		struct sk_buff *skb = sp->RxBuff[entry];
+		unsigned int framelen;
+
+		rxfd = sp->rxd + entry;
+
+		if (((rxfd->rfs & __RFS_MASK) != __RFS_MASK) || !skb)
+			break;
+
+		/* Get received frame length. */
+		framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
+
+		/* Check for jumbo frame arrival with too small
+		 * RXFRAG_SIZE.
+		 */
+		if (framelen > IPG_RXFRAG_SIZE) {
+			IPG_DEBUG_MSG
+			    ("RFS FrameLen > allocated fragment size.\n");
+
+			framelen = IPG_RXFRAG_SIZE;
+		}
+
+		if ((IPG_DROP_ON_RX_ETH_ERRORS && (le64_to_cpu(rxfd->rfs &
+		       (IPG_RFS_RXFIFOOVERRUN | IPG_RFS_RXRUNTFRAME |
+			IPG_RFS_RXALIGNMENTERROR | IPG_RFS_RXFCSERROR |
+			IPG_RFS_RXOVERSIZEDFRAME | IPG_RFS_RXLENGTHERROR))))) {
+
+			IPG_DEBUG_MSG("Rx error, RFS = %16.16lx\n",
+				      (unsigned long int) rxfd->rfs);
+
+			/* Increment general receive error statistic. */
+			sp->stats.rx_errors++;
+
+			/* Increment detailed receive error statistics. */
+			if (le64_to_cpu(rxfd->rfs & IPG_RFS_RXFIFOOVERRUN)) {
+				IPG_DEBUG_MSG("RX FIFO overrun occured.\n");
+				sp->stats.rx_fifo_errors++;
+			}
+
+			if (le64_to_cpu(rxfd->rfs & IPG_RFS_RXRUNTFRAME)) {
+				IPG_DEBUG_MSG("RX runt occured.\n");
+				sp->stats.rx_length_errors++;
+			}
+
+			if (le64_to_cpu(rxfd->rfs & IPG_RFS_RXOVERSIZEDFRAME)) ;
+			/* Do nothing, error count handled by a IPG
+			 * statistic register.
+			 */
+
+			if (le64_to_cpu(rxfd->rfs & IPG_RFS_RXALIGNMENTERROR)) {
+				IPG_DEBUG_MSG("RX alignment error occured.\n");
+				sp->stats.rx_frame_errors++;
+			}
+
+			if (le64_to_cpu(rxfd->rfs & IPG_RFS_RXFCSERROR)) ;
+			/* Do nothing, error count handled by a IPG
+			 * statistic register.
+			 */
+
+			/* Free the memory associated with the RX
+			 * buffer since it is erroneous and we will
+			 * not pass it to higher layer processes.
+			 */
+			if (skb) {
+				u64 info = rxfd->frag_info;
+
+				pci_unmap_single(sp->pdev,
+					le64_to_cpu(info & ~IPG_RFI_FRAGLEN),
+					sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+
+				IPG_DEV_KFREE_SKB(skb);
+			}
+		} else {
+
+			/* Adjust the new buffer length to accomodate the size
+			 * of the received frame.
+			 */
+			skb_put(skb, framelen);
+
+			/* Set the buffer's protocol field to Ethernet. */
+			skb->protocol = eth_type_trans(skb, dev);
+
+			/* If the frame contains an IP/TCP/UDP frame,
+			 * determine if upper layer must check IP/TCP/UDP
+			 * checksums.
+			 *
+			 * NOTE: DO NOT RELY ON THE TCP/UDP CHECKSUM
+			 *       VERIFICATION FOR SILICON REVISIONS B3
+			 *       AND EARLIER!
+			 *
+			 if ((le64_to_cpu(rxfd->rfs &
+			     (IPG_RFS_TCPDETECTED | IPG_RFS_UDPDETECTED |
+			      IPG_RFS_IPDETECTED))) &&
+			    !(le64_to_cpu(rxfd->rfs &
+			      (IPG_RFS_TCPERROR | IPG_RFS_UDPERROR |
+			       IPG_RFS_IPERROR)))) {
+				 * Indicate IP checksums were performed
+				 * by the IPG.
+				 *
+			 	skb->ip_summed = CHECKSUM_UNNECESSARY;
+			 } else
+			 */
+			 {
+				/* The IPG encountered an error with (or
+				 * there were no) IP/TCP/UDP checksums.
+				 * This may or may not indicate an invalid
+				 * IP/TCP/UDP frame was received. Let the
+				 * upper layer decide.
+				 */
+				skb->ip_summed = CHECKSUM_NONE;
+			}
+
+			/* Hand off frame for higher layer processing.
+			 * The function netif_rx() releases the sk_buff
+			 * when processing completes.
+			 */
+			netif_rx(skb);
+
+			/* Record frame receive time (jiffies = Linux
+			 * kernel current time stamp).
+			 */
+			dev->last_rx = jiffies;
+		}
+
+		/* Assure RX buffer is not reused by IPG. */
+		sp->RxBuff[entry] = NULL;
+	}
+
+	/*
+	 * If there are more RFDs to proces and the allocated amount of RFD
+	 * processing time has expired, assert Interrupt Requested to make
+	 * sure we come back to process the remaining RFDs.
+	 */
+	if (i == IPG_MAXRFDPROCESS_COUNT)
+		ipg_w32(ipg_r32(ASIC_CTRL) | IPG_AC_INT_REQUEST, ASIC_CTRL);
+
+#ifdef IPG_DEBUG
+	/* Check if the RFD list contained no receive frame data. */
+	if (!i)
+		sp->EmptyRFDListCount++;
+#endif
+	while ((le64_to_cpu(rxfd->rfs & IPG_RFS_RFDDONE)) &&
+	       !((le64_to_cpu(rxfd->rfs & IPG_RFS_FRAMESTART)) &&
+		 (le64_to_cpu(rxfd->rfs & IPG_RFS_FRAMEEND)))) {
+		unsigned int entry = curr++ % IPG_RFDLIST_LENGTH;
+
+		rxfd = sp->rxd + entry;
+
+		IPG_DEBUG_MSG("Frame requires multiple RFDs.\n");
+
+		/* An unexpected event, additional code needed to handle
+		 * properly. So for the time being, just disregard the
+		 * frame.
+		 */
+
+		/* Free the memory associated with the RX
+		 * buffer since it is erroneous and we will
+		 * not pass it to higher layer processes.
+		 */
+		if (sp->RxBuff[entry]) {
+			pci_unmap_single(sp->pdev,
+				le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
+				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+			IPG_DEV_KFREE_SKB(sp->RxBuff[entry]);
+		}
+
+		/* Assure RX buffer is not reused by IPG. */
+		sp->RxBuff[entry] = NULL;
+	}
+
+	sp->rx_current = curr;
+
+	/* Check to see if there are a minimum number of used
+	 * RFDs before restoring any (should improve performance.)
+	 */
+	if ((curr - sp->rx_dirty) >= IPG_MINUSEDRFDSTOFREE)
+		ipg_nic_rxrestore(dev);
+
+	return 0;
+}
+#endif
+
+static void ipg_reset_after_host_error(struct work_struct *work)
+{
+	struct ipg_nic_private *sp =
+		container_of(work, struct ipg_nic_private, task.work);
+	struct net_device *dev = sp->dev;
+
+	IPG_DDEBUG_MSG("DMACtrl = %8.8x\n", ioread32(sp->ioaddr + IPG_DMACTRL));
+
+	/*
+	 * Acknowledge HostError interrupt by resetting
+	 * IPG DMA and HOST.
+	 */
+	ipg_reset(dev, IPG_AC_GLOBAL_RESET | IPG_AC_HOST | IPG_AC_DMA);
+
+	init_rfdlist(dev);
+	init_tfdlist(dev);
+
+	if (ipg_io_config(dev) < 0) {
+		printk(KERN_INFO "%s: Cannot recover from PCI error.\n",
+		       dev->name);
+		schedule_delayed_work(&sp->task, HZ);
+	}
+}
+
+static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
+{
+	struct net_device *dev = dev_inst;
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	unsigned int handled = 0;
+	u16 status;
+
+	IPG_DEBUG_MSG("_interrupt_handler\n");
+
+#ifdef JUMBO_FRAME
+	ipg_nic_rxrestore(dev);
+#endif
+	/* Get interrupt source information, and acknowledge
+	 * some (i.e. TxDMAComplete, RxDMAComplete, RxEarly,
+	 * IntRequested, MacControlFrame, LinkEvent) interrupts
+	 * if issued. Also, all IPG interrupts are disabled by
+	 * reading IntStatusAck.
+	 */
+	status = ipg_r16(INT_STATUS_ACK);
+
+	IPG_DEBUG_MSG("IntStatusAck = %4.4x\n", status);
+
+	/* Shared IRQ of remove event. */
+	if (!(status & IPG_IS_RSVD_MASK))
+		goto out_enable;
+
+	handled = 1;
+
+	if (unlikely(!netif_running(dev)))
+		goto out;
+
+	spin_lock(&sp->lock);
+
+	/* If RFDListEnd interrupt, restore all used RFDs. */
+	if (status & IPG_IS_RFD_LIST_END) {
+		IPG_DEBUG_MSG("RFDListEnd Interrupt.\n");
+
+		/* The RFD list end indicates an RFD was encountered
+		 * with a 0 NextPtr, or with an RFDDone bit set to 1
+		 * (indicating the RFD is not read for use by the
+		 * IPG.) Try to restore all RFDs.
+		 */
+		ipg_nic_rxrestore(dev);
+
+#ifdef IPG_DEBUG
+		/* Increment the RFDlistendCount counter. */
+		sp->RFDlistendCount++;
+#endif
+	}
+
+	/* If RFDListEnd, RxDMAPriority, RxDMAComplete, or
+	 * IntRequested interrupt, process received frames. */
+	if ((status & IPG_IS_RX_DMA_PRIORITY) ||
+	    (status & IPG_IS_RFD_LIST_END) ||
+	    (status & IPG_IS_RX_DMA_COMPLETE) ||
+	    (status & IPG_IS_INT_REQUESTED)) {
+#ifdef IPG_DEBUG
+		/* Increment the RFD list checked counter if interrupted
+		 * only to check the RFD list. */
+		if (status & (~(IPG_IS_RX_DMA_PRIORITY | IPG_IS_RFD_LIST_END |
+				IPG_IS_RX_DMA_COMPLETE | IPG_IS_INT_REQUESTED) &
+			       (IPG_IS_HOST_ERROR | IPG_IS_TX_DMA_COMPLETE |
+				IPG_IS_LINK_EVENT | IPG_IS_TX_COMPLETE |
+				IPG_IS_UPDATE_STATS)))
+			sp->RFDListCheckedCount++;
+#endif
+
+		ipg_nic_rx(dev);
+	}
+
+	/* If TxDMAComplete interrupt, free used TFDs. */
+	if (status & IPG_IS_TX_DMA_COMPLETE)
+		ipg_nic_txfree(dev);
+
+	/* TxComplete interrupts indicate one of numerous actions.
+	 * Determine what action to take based on TXSTATUS register.
+	 */
+	if (status & IPG_IS_TX_COMPLETE)
+		ipg_nic_txcleanup(dev);
+
+	/* If UpdateStats interrupt, update Linux Ethernet statistics */
+	if (status & IPG_IS_UPDATE_STATS)
+		ipg_nic_get_stats(dev);
+
+	/* If HostError interrupt, reset IPG. */
+	if (status & IPG_IS_HOST_ERROR) {
+		IPG_DDEBUG_MSG("HostError Interrupt\n");
+
+		schedule_delayed_work(&sp->task, 0);
+	}
+
+	/* If LinkEvent interrupt, resolve autonegotiation. */
+	if (status & IPG_IS_LINK_EVENT) {
+		if (ipg_config_autoneg(dev) < 0)
+			printk(KERN_INFO "%s: Auto-negotiation error.\n",
+			       dev->name);
+	}
+
+	/* If MACCtrlFrame interrupt, do nothing. */
+	if (status & IPG_IS_MAC_CTRL_FRAME)
+		IPG_DEBUG_MSG("MACCtrlFrame interrupt.\n");
+
+	/* If RxComplete interrupt, do nothing. */
+	if (status & IPG_IS_RX_COMPLETE)
+		IPG_DEBUG_MSG("RxComplete interrupt.\n");
+
+	/* If RxEarly interrupt, do nothing. */
+	if (status & IPG_IS_RX_EARLY)
+		IPG_DEBUG_MSG("RxEarly interrupt.\n");
+
+out_enable:
+	/* Re-enable IPG interrupts. */
+	ipg_w16(IPG_IE_TX_DMA_COMPLETE | IPG_IE_RX_DMA_COMPLETE |
+		IPG_IE_HOST_ERROR | IPG_IE_INT_REQUESTED | IPG_IE_TX_COMPLETE |
+		IPG_IE_LINK_EVENT | IPG_IE_UPDATE_STATS, INT_ENABLE);
+
+	spin_unlock(&sp->lock);
+out:
+	return IRQ_RETVAL(handled);
+}
+
+static void ipg_rx_clear(struct ipg_nic_private *sp)
+{
+	unsigned int i;
+
+	for (i = 0; i < IPG_RFDLIST_LENGTH; i++) {
+		if (sp->RxBuff[i]) {
+			struct ipg_rx *rxfd = sp->rxd + i;
+
+			IPG_DEV_KFREE_SKB(sp->RxBuff[i]);
+			sp->RxBuff[i] = NULL;
+			pci_unmap_single(sp->pdev,
+				le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
+				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+		}
+	}
+}
+
+static void ipg_tx_clear(struct ipg_nic_private *sp)
+{
+	unsigned int i;
+
+	for (i = 0; i < IPG_TFDLIST_LENGTH; i++) {
+		if (sp->TxBuff[i]) {
+			struct ipg_tx *txfd = sp->txd + i;
+
+			pci_unmap_single(sp->pdev,
+				le64_to_cpu(txfd->frag_info & ~IPG_TFI_FRAGLEN),
+				sp->TxBuff[i]->len, PCI_DMA_TODEVICE);
+
+			IPG_DEV_KFREE_SKB(sp->TxBuff[i]);
+
+			sp->TxBuff[i] = NULL;
+		}
+	}
+}
+
+static int ipg_nic_open(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	struct pci_dev *pdev = sp->pdev;
+	int rc;
+
+	IPG_DEBUG_MSG("_nic_open\n");
+
+	sp->rx_buf_sz = IPG_RXSUPPORT_SIZE;
+
+	/* Check for interrupt line conflicts, and request interrupt
+	 * line for IPG.
+	 *
+	 * IMPORTANT: Disable IPG interrupts prior to registering
+	 *            IRQ.
+	 */
+	ipg_w16(0x0000, INT_ENABLE);
+
+	/* Register the interrupt line to be used by the IPG within
+	 * the Linux system.
+	 */
+	rc = request_irq(pdev->irq, &ipg_interrupt_handler, IRQF_SHARED,
+			 dev->name, dev);
+	if (rc < 0) {
+		printk(KERN_INFO "%s: Error when requesting interrupt.\n",
+		       dev->name);
+		goto out;
+	}
+
+	dev->irq = pdev->irq;
+
+	rc = -ENOMEM;
+
+	sp->rxd = dma_alloc_coherent(&pdev->dev, IPG_RX_RING_BYTES,
+				     &sp->rxd_map, GFP_KERNEL);
+	if (!sp->rxd)
+		goto err_free_irq_0;
+
+	sp->txd = dma_alloc_coherent(&pdev->dev, IPG_TX_RING_BYTES,
+				     &sp->txd_map, GFP_KERNEL);
+	if (!sp->txd)
+		goto err_free_rx_1;
+
+	rc = init_rfdlist(dev);
+	if (rc < 0) {
+		printk(KERN_INFO "%s: Error during configuration.\n",
+		       dev->name);
+		goto err_free_tx_2;
+	}
+
+	init_tfdlist(dev);
+
+	rc = ipg_io_config(dev);
+	if (rc < 0) {
+		printk(KERN_INFO "%s: Error during configuration.\n",
+		       dev->name);
+		goto err_release_tfdlist_3;
+	}
+
+	/* Resolve autonegotiation. */
+	if (ipg_config_autoneg(dev) < 0)
+		printk(KERN_INFO "%s: Auto-negotiation error.\n", dev->name);
+
+#ifdef JUMBO_FRAME
+	/* initialize JUMBO Frame control variable */
+	sp->Jumbo.FoundStart = 0;
+	sp->Jumbo.CurrentSize = 0;
+	sp->Jumbo.skb = 0;
+	dev->mtu = IPG_TXFRAG_SIZE;
+#endif
+
+	/* Enable transmit and receive operation of the IPG. */
+	ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_RX_ENABLE | IPG_MC_TX_ENABLE) &
+		 IPG_MC_RSVD_MASK, MAC_CTRL);
+
+	netif_start_queue(dev);
+out:
+	return rc;
+
+err_release_tfdlist_3:
+	ipg_tx_clear(sp);
+	ipg_rx_clear(sp);
+err_free_tx_2:
+	dma_free_coherent(&pdev->dev, IPG_TX_RING_BYTES, sp->txd, sp->txd_map);
+err_free_rx_1:
+	dma_free_coherent(&pdev->dev, IPG_RX_RING_BYTES, sp->rxd, sp->rxd_map);
+err_free_irq_0:
+	free_irq(pdev->irq, dev);
+	goto out;
+}
+
+static int ipg_nic_stop(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	struct pci_dev *pdev = sp->pdev;
+
+	IPG_DEBUG_MSG("_nic_stop\n");
+
+	netif_stop_queue(dev);
+
+	IPG_DDEBUG_MSG("RFDlistendCount = %i\n", sp->RFDlistendCount);
+	IPG_DDEBUG_MSG("RFDListCheckedCount = %i\n", sp->rxdCheckedCount);
+	IPG_DDEBUG_MSG("EmptyRFDListCount = %i\n", sp->EmptyRFDListCount);
+	IPG_DUMPTFDLIST(dev);
+
+	do {
+		(void) ipg_r16(INT_STATUS_ACK);
+
+		ipg_reset(dev, IPG_AC_GLOBAL_RESET | IPG_AC_HOST | IPG_AC_DMA);
+
+		synchronize_irq(pdev->irq);
+	} while (ipg_r16(INT_ENABLE) & IPG_IE_RSVD_MASK);
+
+	ipg_rx_clear(sp);
+
+	ipg_tx_clear(sp);
+
+	pci_free_consistent(pdev, IPG_RX_RING_BYTES, sp->rxd, sp->rxd_map);
+	pci_free_consistent(pdev, IPG_TX_RING_BYTES, sp->txd, sp->txd_map);
+
+	free_irq(pdev->irq, dev);
+
+	return 0;
+}
+
+static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	unsigned int entry = sp->tx_current % IPG_TFDLIST_LENGTH;
+	unsigned long flags;
+	struct ipg_tx *txfd;
+
+	IPG_DDEBUG_MSG("_nic_hard_start_xmit\n");
+
+	/* If in 10Mbps mode, stop the transmit queue so
+	 * no more transmit frames are accepted.
+	 */
+	if (sp->tenmbpsmode)
+		netif_stop_queue(dev);
+
+	if (sp->ResetCurrentTFD) {
+		sp->ResetCurrentTFD = 0;
+		entry = 0;
+	}
+
+	txfd = sp->txd + entry;
+
+	sp->TxBuff[entry] = skb;
+
+	/* Clear all TFC fields, except TFDDONE. */
+	txfd->tfc = cpu_to_le64(IPG_TFC_TFDDONE);
+
+	/* Specify the TFC field within the TFD. */
+	txfd->tfc |= cpu_to_le64(IPG_TFC_WORDALIGNDISABLED |
+		(IPG_TFC_FRAMEID & cpu_to_le64(sp->tx_current)) |
+		(IPG_TFC_FRAGCOUNT & (1 << 24)));
+
+	/* Request TxComplete interrupts at an interval defined
+	 * by the constant IPG_FRAMESBETWEENTXCOMPLETES.
+	 * Request TxComplete interrupt for every frame
+	 * if in 10Mbps mode to accomodate problem with 10Mbps
+	 * processing.
+	 */
+	if (sp->tenmbpsmode)
+		txfd->tfc |= cpu_to_le64(IPG_TFC_TXINDICATE);
+	else if (!((sp->tx_current - sp->tx_dirty + 1) >
+	    IPG_FRAMESBETWEENTXDMACOMPLETES)) {
+		txfd->tfc |= cpu_to_le64(IPG_TFC_TXDMAINDICATE);
+	}
+	/* Based on compilation option, determine if FCS is to be
+	 * appended to transmit frame by IPG.
+	 */
+	if (!(IPG_APPEND_FCS_ON_TX))
+		txfd->tfc |= cpu_to_le64(IPG_TFC_FCSAPPENDDISABLE);
+
+	/* Based on compilation option, determine if IP, TCP and/or
+	 * UDP checksums are to be added to transmit frame by IPG.
+	 */
+	if (IPG_ADD_IPCHECKSUM_ON_TX)
+		txfd->tfc |= cpu_to_le64(IPG_TFC_IPCHECKSUMENABLE);
+
+	if (IPG_ADD_TCPCHECKSUM_ON_TX)
+		txfd->tfc |= cpu_to_le64(IPG_TFC_TCPCHECKSUMENABLE);
+
+	if (IPG_ADD_UDPCHECKSUM_ON_TX)
+		txfd->tfc |= cpu_to_le64(IPG_TFC_UDPCHECKSUMENABLE);
+
+	/* Based on compilation option, determine if VLAN tag info is to be
+	 * inserted into transmit frame by IPG.
+	 */
+	if (IPG_INSERT_MANUAL_VLAN_TAG) {
+		txfd->tfc |= cpu_to_le64(IPG_TFC_VLANTAGINSERT |
+			((u64) IPG_MANUAL_VLAN_VID << 32) |
+			((u64) IPG_MANUAL_VLAN_CFI << 44) |
+			((u64) IPG_MANUAL_VLAN_USERPRIORITY << 45));
+	}
+
+	/* The fragment start location within system memory is defined
+	 * by the sk_buff structure's data field. The physical address
+	 * of this location within the system's virtual memory space
+	 * is determined using the IPG_HOST2BUS_MAP function.
+	 */
+	txfd->frag_info = cpu_to_le64(pci_map_single(sp->pdev, skb->data,
+		skb->len, PCI_DMA_TODEVICE));
+
+	/* The length of the fragment within system memory is defined by
+	 * the sk_buff structure's len field.
+	 */
+	txfd->frag_info |= cpu_to_le64(IPG_TFI_FRAGLEN &
+		((u64) (skb->len & 0xffff) << 48));
+
+	/* Clear the TFDDone bit last to indicate the TFD is ready
+	 * for transfer to the IPG.
+	 */
+	txfd->tfc &= cpu_to_le64(~IPG_TFC_TFDDONE);
+
+	spin_lock_irqsave(&sp->lock, flags);
+
+	sp->tx_current++;
+
+	mmiowb();
+
+	ipg_w32(IPG_DC_TX_DMA_POLL_NOW, DMA_CTRL);
+
+	if (sp->tx_current == (sp->tx_dirty + IPG_TFDLIST_LENGTH))
+		netif_wake_queue(dev);
+
+	spin_unlock_irqrestore(&sp->lock, flags);
+
+	return NETDEV_TX_OK;
+}
+
+static void ipg_set_phy_default_param(unsigned char rev,
+				      struct net_device *dev, int phy_address)
+{
+	unsigned short length;
+	unsigned char revision;
+	unsigned short *phy_param;
+	unsigned short address, value;
+
+	phy_param = &DefaultPhyParam[0];
+	length = *phy_param & 0x00FF;
+	revision = (unsigned char)((*phy_param) >> 8);
+	phy_param++;
+	while (length != 0) {
+		if (rev == revision) {
+			while (length > 1) {
+				address = *phy_param;
+				value = *(phy_param + 1);
+				phy_param += 2;
+				mdio_write(dev, phy_address, address, value);
+				length -= 4;
+			}
+			break;
+		} else {
+			phy_param += length / 2;
+			length = *phy_param & 0x00FF;
+			revision = (unsigned char)((*phy_param) >> 8);
+			phy_param++;
+		}
+	}
+}
+
+/* JES20040127EEPROM */
+static int read_eeprom(struct net_device *dev, int eep_addr)
+{
+	void __iomem *ioaddr = ipg_ioaddr(dev);
+	unsigned int i;
+	int ret = 0;
+	u16 value;
+
+	value = IPG_EC_EEPROM_READOPCODE | (eep_addr & 0xff);
+	ipg_w16(value, EEPROM_CTRL);
+
+	for (i = 0; i < 1000; i++) {
+		u16 data;
+
+		mdelay(10);
+		data = ipg_r16(EEPROM_CTRL);
+		if (!(data & IPG_EC_EEPROM_BUSY)) {
+			ret = ipg_r16(EEPROM_DATA);
+			break;
+		}
+	}
+	return ret;
+}
+
+static void ipg_init_mii(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	struct mii_if_info *mii_if = &sp->mii_if;
+	int phyaddr;
+
+	mii_if->dev          = dev;
+	mii_if->mdio_read    = mdio_read;
+	mii_if->mdio_write   = mdio_write;
+	mii_if->phy_id_mask  = 0x1f;
+	mii_if->reg_num_mask = 0x1f;
+
+	mii_if->phy_id = phyaddr = ipg_find_phyaddr(dev);
+
+	if (phyaddr != 0x1f) {
+		u16 mii_phyctrl, mii_1000cr;
+		u8 revisionid = 0;
+
+		mii_1000cr  = mdio_read(dev, phyaddr, MII_CTRL1000);
+		mii_1000cr |= ADVERTISE_1000FULL | ADVERTISE_1000HALF |
+			GMII_PHY_1000BASETCONTROL_PreferMaster;
+		mdio_write(dev, phyaddr, MII_CTRL1000, mii_1000cr);
+
+		mii_phyctrl = mdio_read(dev, phyaddr, MII_BMCR);
+
+		/* Set default phyparam */
+		pci_read_config_byte(sp->pdev, PCI_REVISION_ID, &revisionid);
+		ipg_set_phy_default_param(revisionid, dev, phyaddr);
+
+		/* Reset PHY */
+		mii_phyctrl |= BMCR_RESET | BMCR_ANRESTART;
+		mdio_write(dev, phyaddr, MII_BMCR, mii_phyctrl);
+
+	}
+}
+
+static int ipg_hw_init(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	void __iomem *ioaddr = sp->ioaddr;
+	unsigned int i;
+	int rc;
+
+	/* Read/Write and Reset EEPROM Value Jesse20040128EEPROM_VALUE */
+	/* Read LED Mode Configuration from EEPROM */
+	sp->LED_Mode = read_eeprom(dev, 6);
+
+	/* Reset all functions within the IPG. Do not assert
+	 * RST_OUT as not compatible with some PHYs.
+	 */
+	rc = ipg_reset(dev, IPG_RESET_MASK);
+	if (rc < 0)
+		goto out;
+
+	ipg_init_mii(dev);
+
+	/* Read MAC Address from EEPROM */
+	for (i = 0; i < 3; i++)
+		sp->station_addr[i] = read_eeprom(dev, 16 + i);
+
+	for (i = 0; i < 3; i++)
+		ipg_w16(sp->station_addr[i], STATION_ADDRESS_0 + 2*i);
+
+	/* Set station address in ethernet_device structure. */
+	dev->dev_addr[0] =  ipg_r16(STATION_ADDRESS_0) & 0x00ff;
+	dev->dev_addr[1] = (ipg_r16(STATION_ADDRESS_0) & 0xff00) >> 8;
+	dev->dev_addr[2] =  ipg_r16(STATION_ADDRESS_1) & 0x00ff;
+	dev->dev_addr[3] = (ipg_r16(STATION_ADDRESS_1) & 0xff00) >> 8;
+	dev->dev_addr[4] =  ipg_r16(STATION_ADDRESS_2) & 0x00ff;
+	dev->dev_addr[5] = (ipg_r16(STATION_ADDRESS_2) & 0xff00) >> 8;
+out:
+	return rc;
+}
+
+static int ipg_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	int rc;
+
+	mutex_lock(&sp->mii_mutex);
+	rc = generic_mii_ioctl(&sp->mii_if, if_mii(ifr), cmd, NULL);
+	mutex_unlock(&sp->mii_mutex);
+
+	return rc;
+}
+
+static int ipg_nic_change_mtu(struct net_device *dev, int new_mtu)
+{
+	/* Function to accomodate changes to Maximum Transfer Unit
+	 * (or MTU) of IPG NIC. Cannot use default function since
+	 * the default will not allow for MTU > 1500 bytes.
+	 */
+
+	IPG_DEBUG_MSG("_nic_change_mtu\n");
+
+	/* Check that the new MTU value is between 68 (14 byte header, 46
+	 * byte payload, 4 byte FCS) and IPG_MAX_RXFRAME_SIZE, which
+	 * corresponds to the MAXFRAMESIZE register in the IPG.
+	 */
+	if ((new_mtu < 68) || (new_mtu > IPG_MAX_RXFRAME_SIZE))
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+
+	return 0;
+}
+
+static int ipg_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	int rc;
+
+	mutex_lock(&sp->mii_mutex);
+	rc = mii_ethtool_gset(&sp->mii_if, cmd);
+	mutex_unlock(&sp->mii_mutex);
+
+	return rc;
+}
+
+static int ipg_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	int rc;
+
+	mutex_lock(&sp->mii_mutex);
+	rc = mii_ethtool_sset(&sp->mii_if, cmd);
+	mutex_unlock(&sp->mii_mutex);
+
+	return rc;
+}
+
+static int ipg_nway_reset(struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	int rc;
+
+	mutex_lock(&sp->mii_mutex);
+	rc = mii_nway_restart(&sp->mii_if);
+	mutex_unlock(&sp->mii_mutex);
+
+	return rc;
+}
+
+static struct ethtool_ops ipg_ethtool_ops = {
+	.get_settings = ipg_get_settings,
+	.set_settings = ipg_set_settings,
+	.nway_reset   = ipg_nway_reset,
+};
+
+static void ipg_remove(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct ipg_nic_private *sp = netdev_priv(dev);
+
+	IPG_DEBUG_MSG("_remove\n");
+
+	/* Un-register Ethernet device. */
+	unregister_netdev(dev);
+
+	pci_iounmap(pdev, sp->ioaddr);
+
+	pci_release_regions(pdev);
+
+	free_netdev(dev);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
+}
+
+static int __devinit ipg_probe(struct pci_dev *pdev,
+			       const struct pci_device_id *id)
+{
+	unsigned int i = id->driver_data;
+	struct ipg_nic_private *sp;
+	struct net_device *dev;
+	void __iomem *ioaddr;
+	int rc;
+
+	rc = pci_enable_device(pdev);
+	if (rc < 0)
+		goto out;
+
+	printk(KERN_INFO "%s: %s\n", pci_name(pdev), ipg_brand_name[i]);
+
+	pci_set_master(pdev);
+
+	rc = pci_set_dma_mask(pdev, DMA_40BIT_MASK);
+	if (rc < 0) {
+		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		if (rc < 0) {
+			printk(KERN_ERR "%s: DMA config failed.\n",
+			       pci_name(pdev));
+			goto err_disable_0;
+		}
+	}
+
+	/*
+	 * Initialize net device.
+	 */
+	dev = alloc_etherdev(sizeof(struct ipg_nic_private));
+	if (!dev) {
+		printk(KERN_ERR "%s: alloc_etherdev failed\n", pci_name(pdev));
+		rc = -ENOMEM;
+		goto err_disable_0;
+	}
+
+	sp = netdev_priv(dev);
+	spin_lock_init(&sp->lock);
+	mutex_init(&sp->mii_mutex);
+
+	/* Declare IPG NIC functions for Ethernet device methods.
+	 */
+	dev->open = &ipg_nic_open;
+	dev->stop = &ipg_nic_stop;
+	dev->hard_start_xmit = &ipg_nic_hard_start_xmit;
+	dev->get_stats = &ipg_nic_get_stats;
+	dev->set_multicast_list = &ipg_nic_set_multicast_list;
+	dev->do_ioctl = ipg_ioctl;
+	dev->tx_timeout = ipg_tx_timeout;
+	dev->change_mtu = &ipg_nic_change_mtu;
+
+	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	SET_ETHTOOL_OPS(dev, &ipg_ethtool_ops);
+
+	rc = pci_request_regions(pdev, DRV_NAME);
+	if (rc)
+		goto err_free_dev_1;
+
+	ioaddr = pci_iomap(pdev, 1, pci_resource_len(pdev, 1));
+	if (!ioaddr) {
+		printk(KERN_ERR "%s cannot map MMIO\n", pci_name(pdev));
+		rc = -EIO;
+		goto err_release_regions_2;
+	}
+
+	/* Save the pointer to the PCI device information. */
+	sp->ioaddr = ioaddr;
+	sp->pdev = pdev;
+	sp->dev = dev;
+
+	INIT_DELAYED_WORK(&sp->task, ipg_reset_after_host_error);
+
+	pci_set_drvdata(pdev, dev);
+
+	rc = ipg_hw_init(dev);
+	if (rc < 0)
+		goto err_unmap_3;
+
+	rc = register_netdev(dev);
+	if (rc < 0)
+		goto err_unmap_3;
+
+	printk(KERN_INFO "Ethernet device registered as: %s\n", dev->name);
+out:
+	return rc;
+
+err_unmap_3:
+	pci_iounmap(pdev, ioaddr);
+err_release_regions_2:
+	pci_release_regions(pdev);
+err_free_dev_1:
+	free_netdev(dev);
+err_disable_0:
+	pci_disable_device(pdev);
+	goto out;
+}
+
+static struct pci_driver ipg_pci_driver = {
+	.name		= IPG_DRIVER_NAME,
+	.id_table	= ipg_pci_tbl,
+	.probe		= ipg_probe,
+	.remove		= __devexit_p(ipg_remove),
+};
+
+static int __init ipg_init_module(void)
+{
+	return pci_register_driver(&ipg_pci_driver);
+}
+
+static void __exit ipg_exit_module(void)
+{
+	pci_unregister_driver(&ipg_pci_driver);
+}
+
+module_init(ipg_init_module);
+module_exit(ipg_exit_module);
diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
new file mode 100644
index 0000000..1952d0d
--- /dev/null
+++ b/drivers/net/ipg.h
@@ -0,0 +1,856 @@
+/*
+ *
+ * ipg.h
+ *
+ * Include file for Gigabit Ethernet device driver for Network
+ * Interface Cards (NICs) utilizing the Tamarack Microelectronics
+ * Inc. IPG Gigabit or Triple Speed Ethernet Media Access
+ * Controller.
+ *
+ * Craig Rich
+ * Sundance Technology, Inc.
+ * 1485 Saratoga Avenue
+ * Suite 200
+ * San Jose, CA 95129
+ * 408 873 4117
+ * www.sundanceti.com
+ * craig_rich@sundanceti.com
+ */
+#ifndef __LINUX_IPG_H
+#define __LINUX_IPG_H
+
+#include <linux/version.h>
+#include <linux/module.h>
+
+#include <linux/kernel.h>
+#include <linux/pci.h>
+#include <linux/ioport.h>
+#include <linux/errno.h>
+#include <asm/io.h>
+#include <linux/delay.h>
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/init.h>
+#include <linux/skbuff.h>
+#include <linux/version.h>
+#include <asm/bitops.h>
+/*#include <asm/spinlock.h>*/
+
+#define DrvVer "2.09d"
+
+#define IPG_DEV_KFREE_SKB(skb) dev_kfree_skb_irq(skb)
+
+/*
+ *	Constants
+ */
+
+/* GMII based PHY IDs */
+#define		NS				0x2000
+#define		MARVELL				0x0141
+#define		ICPLUS_PHY		0x243
+
+/* NIC Physical Layer Device MII register fields. */
+#define         MII_PHY_SELECTOR_IEEE8023       0x0001
+#define         MII_PHY_TECHABILITYFIELD        0x1FE0
+
+/* GMII_PHY_1000 need to set to prefer master */
+#define         GMII_PHY_1000BASETCONTROL_PreferMaster 0x0400
+
+/* NIC Physical Layer Device GMII constants. */
+#define         GMII_PREAMBLE                    0xFFFFFFFF
+#define         GMII_ST                          0x1
+#define         GMII_READ                        0x2
+#define         GMII_WRITE                       0x1
+#define         GMII_TA_READ_MASK                0x1
+#define         GMII_TA_WRITE                    0x2
+
+/* I/O register offsets. */
+enum ipg_regs {
+	DMA_CTRL		= 0x00,
+	RX_DMA_STATUS		= 0x08, // Unused + reserved
+	TFD_LIST_PTR_0		= 0x10,
+	TFD_LIST_PTR_1		= 0x14,
+	TX_DMA_BURST_THRESH	= 0x18,
+	TX_DMA_URGENT_THRESH	= 0x19,
+	TX_DMA_POLL_PERIOD	= 0x1a,
+	RFD_LIST_PTR_0		= 0x1c,
+	RFD_LIST_PTR_1		= 0x20,
+	RX_DMA_BURST_THRESH	= 0x24,
+	RX_DMA_URGENT_THRESH	= 0x25,
+	RX_DMA_POLL_PERIOD	= 0x26,
+	DEBUG_CTRL		= 0x2c,
+	ASIC_CTRL		= 0x30,
+	FIFO_CTRL		= 0x38, // Unused
+	FLOW_OFF_THRESH		= 0x3c,
+	FLOW_ON_THRESH		= 0x3e,
+	EEPROM_DATA		= 0x48,
+	EEPROM_CTRL		= 0x4a,
+	EXPROM_ADDR		= 0x4c, // Unused
+	EXPROM_DATA		= 0x50, // Unused
+	WAKE_EVENT		= 0x51, // Unused
+	COUNTDOWN		= 0x54, // Unused
+	INT_STATUS_ACK		= 0x5a,
+	INT_ENABLE		= 0x5c,
+	INT_STATUS		= 0x5e, // Unused
+	TX_STATUS		= 0x60,
+	MAC_CTRL		= 0x6c,
+	VLAN_TAG		= 0x70, // Unused
+	PHY_SET			= 0x75,	// JES20040127EEPROM
+	PHY_CTRL		= 0x76,
+	STATION_ADDRESS_0	= 0x78,
+	STATION_ADDRESS_1	= 0x7a,
+	STATION_ADDRESS_2	= 0x7c,
+	MAX_FRAME_SIZE		= 0x86,
+	RECEIVE_MODE		= 0x88,
+	HASHTABLE_0		= 0x8c,
+	HASHTABLE_1		= 0x90,
+	RMON_STATISTICS_MASK	= 0x98,
+	STATISTICS_MASK		= 0x9c,
+	RX_JUMBO_FRAMES		= 0xbc, // Unused
+	TCP_CHECKSUM_ERRORS	= 0xc0, // Unused
+	IP_CHECKSUM_ERRORS	= 0xc2, // Unused
+	UDP_CHECKSUM_ERRORS	= 0xc4, // Unused
+	TX_JUMBO_FRAMES		= 0xf4  // Unused
+};
+
+/* Ethernet MIB statistic register offsets. */
+#define	IPG_OCTETRCVOK		0xA8
+#define	IPG_MCSTOCTETRCVDOK		0xAC
+#define	IPG_BCSTOCTETRCVOK		0xB0
+#define	IPG_FRAMESRCVDOK		0xB4
+#define	IPG_MCSTFRAMESRCVDOK		0xB8
+#define	IPG_BCSTFRAMESRCVDOK		0xBE
+#define	IPG_MACCONTROLFRAMESRCVD	0xC6
+#define	IPG_FRAMETOOLONGERRRORS	0xC8
+#define	IPG_INRANGELENGTHERRORS	0xCA
+#define	IPG_FRAMECHECKSEQERRORS	0xCC
+#define	IPG_FRAMESLOSTRXERRORS	0xCE
+#define	IPG_OCTETXMTOK		0xD0
+#define	IPG_MCSTOCTETXMTOK		0xD4
+#define	IPG_BCSTOCTETXMTOK		0xD8
+#define	IPG_FRAMESXMTDOK		0xDC
+#define	IPG_MCSTFRAMESXMTDOK		0xE0
+#define	IPG_FRAMESWDEFERREDXMT	0xE4
+#define	IPG_LATECOLLISIONS		0xE8
+#define	IPG_MULTICOLFRAMES		0xEC
+#define	IPG_SINGLECOLFRAMES		0xF0
+#define	IPG_BCSTFRAMESXMTDOK		0xF6
+#define	IPG_CARRIERSENSEERRORS	0xF8
+#define	IPG_MACCONTROLFRAMESXMTDOK	0xFA
+#define	IPG_FRAMESABORTXSCOLLS	0xFC
+#define	IPG_FRAMESWEXDEFERRAL	0xFE
+
+/* RMON statistic register offsets. */
+#define	IPG_ETHERSTATSCOLLISIONS			0x100
+#define	IPG_ETHERSTATSOCTETSTRANSMIT			0x104
+#define	IPG_ETHERSTATSPKTSTRANSMIT			0x108
+#define	IPG_ETHERSTATSPKTS64OCTESTSTRANSMIT		0x10C
+#define	IPG_ETHERSTATSPKTS65TO127OCTESTSTRANSMIT	0x110
+#define	IPG_ETHERSTATSPKTS128TO255OCTESTSTRANSMIT	0x114
+#define	IPG_ETHERSTATSPKTS256TO511OCTESTSTRANSMIT	0x118
+#define	IPG_ETHERSTATSPKTS512TO1023OCTESTSTRANSMIT	0x11C
+#define	IPG_ETHERSTATSPKTS1024TO1518OCTESTSTRANSMIT	0x120
+#define	IPG_ETHERSTATSCRCALIGNERRORS			0x124
+#define	IPG_ETHERSTATSUNDERSIZEPKTS			0x128
+#define	IPG_ETHERSTATSFRAGMENTS			0x12C
+#define	IPG_ETHERSTATSJABBERS			0x130
+#define	IPG_ETHERSTATSOCTETS				0x134
+#define	IPG_ETHERSTATSPKTS				0x138
+#define	IPG_ETHERSTATSPKTS64OCTESTS			0x13C
+#define	IPG_ETHERSTATSPKTS65TO127OCTESTS		0x140
+#define	IPG_ETHERSTATSPKTS128TO255OCTESTS		0x144
+#define	IPG_ETHERSTATSPKTS256TO511OCTESTS		0x148
+#define	IPG_ETHERSTATSPKTS512TO1023OCTESTS		0x14C
+#define	IPG_ETHERSTATSPKTS1024TO1518OCTESTS		0x150
+
+/* RMON statistic register equivalents. */
+#define	IPG_ETHERSTATSMULTICASTPKTSTRANSMIT		0xE0
+#define	IPG_ETHERSTATSBROADCASTPKTSTRANSMIT		0xF6
+#define	IPG_ETHERSTATSMULTICASTPKTS			0xB8
+#define	IPG_ETHERSTATSBROADCASTPKTS			0xBE
+#define	IPG_ETHERSTATSOVERSIZEPKTS			0xC8
+#define	IPG_ETHERSTATSDROPEVENTS			0xCE
+
+/* Serial EEPROM offsets */
+#define	IPG_EEPROM_CONFIGPARAM	0x00
+#define	IPG_EEPROM_ASICCTRL		0x01
+#define	IPG_EEPROM_SUBSYSTEMVENDORID	0x02
+#define	IPG_EEPROM_SUBSYSTEMID	0x03
+#define	IPG_EEPROM_STATIONADDRESS0	0x10
+#define	IPG_EEPROM_STATIONADDRESS1	0x11
+#define	IPG_EEPROM_STATIONADDRESS2	0x12
+
+/* Register & data structure bit masks */
+
+/* PCI register masks. */
+
+/* IOBaseAddress */
+#define         IPG_PIB_RSVD_MASK		0xFFFFFE01
+#define         IPG_PIB_IOBASEADDRESS	0xFFFFFF00
+#define         IPG_PIB_IOBASEADDRIND	0x00000001
+
+/* MemBaseAddress */
+#define         IPG_PMB_RSVD_MASK		0xFFFFFE07
+#define         IPG_PMB_MEMBASEADDRIND	0x00000001
+#define         IPG_PMB_MEMMAPTYPE		0x00000006
+#define         IPG_PMB_MEMMAPTYPE0		0x00000002
+#define         IPG_PMB_MEMMAPTYPE1		0x00000004
+#define         IPG_PMB_MEMBASEADDRESS	0xFFFFFE00
+
+/* ConfigStatus */
+#define IPG_CS_RSVD_MASK                0xFFB0
+#define IPG_CS_CAPABILITIES             0x0010
+#define IPG_CS_66MHZCAPABLE             0x0020
+#define IPG_CS_FASTBACK2BACK            0x0080
+#define IPG_CS_DATAPARITYREPORTED       0x0100
+#define IPG_CS_DEVSELTIMING             0x0600
+#define IPG_CS_SIGNALEDTARGETABORT      0x0800
+#define IPG_CS_RECEIVEDTARGETABORT      0x1000
+#define IPG_CS_RECEIVEDMASTERABORT      0x2000
+#define IPG_CS_SIGNALEDSYSTEMERROR      0x4000
+#define IPG_CS_DETECTEDPARITYERROR      0x8000
+
+/* TFD data structure masks. */
+
+/* TFDList, TFC */
+#define	IPG_TFC_RSVD_MASK			0x0000FFFF9FFFFFFF
+#define	IPG_TFC_FRAMEID			0x000000000000FFFF
+#define	IPG_TFC_WORDALIGN			0x0000000000030000
+#define	IPG_TFC_WORDALIGNTODWORD		0x0000000000000000
+#define	IPG_TFC_WORDALIGNTOWORD		0x0000000000020000
+#define	IPG_TFC_WORDALIGNDISABLED		0x0000000000030000
+#define	IPG_TFC_TCPCHECKSUMENABLE		0x0000000000040000
+#define	IPG_TFC_UDPCHECKSUMENABLE		0x0000000000080000
+#define	IPG_TFC_IPCHECKSUMENABLE		0x0000000000100000
+#define	IPG_TFC_FCSAPPENDDISABLE		0x0000000000200000
+#define	IPG_TFC_TXINDICATE			0x0000000000400000
+#define	IPG_TFC_TXDMAINDICATE		0x0000000000800000
+#define	IPG_TFC_FRAGCOUNT			0x000000000F000000
+#define	IPG_TFC_VLANTAGINSERT		0x0000000010000000
+#define	IPG_TFC_TFDDONE			0x0000000080000000
+#define	IPG_TFC_VID				0x00000FFF00000000
+#define	IPG_TFC_CFI				0x0000100000000000
+#define	IPG_TFC_USERPRIORITY			0x0000E00000000000
+
+/* TFDList, FragInfo */
+#define	IPG_TFI_RSVD_MASK			0xFFFF00FFFFFFFFFF
+#define	IPG_TFI_FRAGADDR			0x000000FFFFFFFFFF
+#define	IPG_TFI_FRAGLEN			0xFFFF000000000000LL
+
+/* RFD data structure masks. */
+
+/* RFDList, RFS */
+#define	IPG_RFS_RSVD_MASK			0x0000FFFFFFFFFFFF
+#define	IPG_RFS_RXFRAMELEN			0x000000000000FFFF
+#define	IPG_RFS_RXFIFOOVERRUN		0x0000000000010000
+#define	IPG_RFS_RXRUNTFRAME			0x0000000000020000
+#define	IPG_RFS_RXALIGNMENTERROR		0x0000000000040000
+#define	IPG_RFS_RXFCSERROR			0x0000000000080000
+#define	IPG_RFS_RXOVERSIZEDFRAME		0x0000000000100000
+#define	IPG_RFS_RXLENGTHERROR		0x0000000000200000
+#define	IPG_RFS_VLANDETECTED			0x0000000000400000
+#define	IPG_RFS_TCPDETECTED			0x0000000000800000
+#define	IPG_RFS_TCPERROR			0x0000000001000000
+#define	IPG_RFS_UDPDETECTED			0x0000000002000000
+#define	IPG_RFS_UDPERROR			0x0000000004000000
+#define	IPG_RFS_IPDETECTED			0x0000000008000000
+#define	IPG_RFS_IPERROR			0x0000000010000000
+#define	IPG_RFS_FRAMESTART			0x0000000020000000
+#define	IPG_RFS_FRAMEEND			0x0000000040000000
+#define	IPG_RFS_RFDDONE			0x0000000080000000
+#define	IPG_RFS_TCI				0x0000FFFF00000000
+
+/* RFDList, FragInfo */
+#define	IPG_RFI_RSVD_MASK			0xFFFF00FFFFFFFFFF
+#define	IPG_RFI_FRAGADDR			0x000000FFFFFFFFFF
+#define	IPG_RFI_FRAGLEN			0xFFFF000000000000LL
+
+/* I/O Register masks. */
+
+/* RMON Statistics Mask */
+#define	IPG_RZ_ALL					0x0FFFFFFF
+
+/* Statistics Mask */
+#define	IPG_SM_ALL					0x0FFFFFFF
+#define	IPG_SM_OCTETRCVOK_FRAMESRCVDOK		0x00000001
+#define	IPG_SM_MCSTOCTETRCVDOK_MCSTFRAMESRCVDOK	0x00000002
+#define	IPG_SM_BCSTOCTETRCVDOK_BCSTFRAMESRCVDOK	0x00000004
+#define	IPG_SM_RXJUMBOFRAMES				0x00000008
+#define	IPG_SM_TCPCHECKSUMERRORS			0x00000010
+#define	IPG_SM_IPCHECKSUMERRORS			0x00000020
+#define	IPG_SM_UDPCHECKSUMERRORS			0x00000040
+#define	IPG_SM_MACCONTROLFRAMESRCVD			0x00000080
+#define	IPG_SM_FRAMESTOOLONGERRORS			0x00000100
+#define	IPG_SM_INRANGELENGTHERRORS			0x00000200
+#define	IPG_SM_FRAMECHECKSEQERRORS			0x00000400
+#define	IPG_SM_FRAMESLOSTRXERRORS			0x00000800
+#define	IPG_SM_OCTETXMTOK_FRAMESXMTOK		0x00001000
+#define	IPG_SM_MCSTOCTETXMTOK_MCSTFRAMESXMTDOK	0x00002000
+#define	IPG_SM_BCSTOCTETXMTOK_BCSTFRAMESXMTDOK	0x00004000
+#define	IPG_SM_FRAMESWDEFERREDXMT			0x00008000
+#define	IPG_SM_LATECOLLISIONS			0x00010000
+#define	IPG_SM_MULTICOLFRAMES			0x00020000
+#define	IPG_SM_SINGLECOLFRAMES			0x00040000
+#define	IPG_SM_TXJUMBOFRAMES				0x00080000
+#define	IPG_SM_CARRIERSENSEERRORS			0x00100000
+#define	IPG_SM_MACCONTROLFRAMESXMTD			0x00200000
+#define	IPG_SM_FRAMESABORTXSCOLLS			0x00400000
+#define	IPG_SM_FRAMESWEXDEFERAL			0x00800000
+
+/* Countdown */
+#define	IPG_CD_RSVD_MASK		0x0700FFFF
+#define	IPG_CD_COUNT			0x0000FFFF
+#define	IPG_CD_COUNTDOWNSPEED	0x01000000
+#define	IPG_CD_COUNTDOWNMODE		0x02000000
+#define	IPG_CD_COUNTINTENABLED	0x04000000
+
+/* TxDMABurstThresh */
+#define IPG_TB_RSVD_MASK                0xFF
+
+/* TxDMAUrgentThresh */
+#define IPG_TU_RSVD_MASK                0xFF
+
+/* TxDMAPollPeriod */
+#define IPG_TP_RSVD_MASK                0xFF
+
+/* RxDMAUrgentThresh */
+#define IPG_RU_RSVD_MASK                0xFF
+
+/* RxDMAPollPeriod */
+#define IPG_RP_RSVD_MASK                0xFF
+
+/* ReceiveMode */
+#define IPG_RM_RSVD_MASK                0x3F
+#define IPG_RM_RECEIVEUNICAST           0x01
+#define IPG_RM_RECEIVEMULTICAST         0x02
+#define IPG_RM_RECEIVEBROADCAST         0x04
+#define IPG_RM_RECEIVEALLFRAMES         0x08
+#define IPG_RM_RECEIVEMULTICASTHASH     0x10
+#define IPG_RM_RECEIVEIPMULTICAST       0x20
+
+/* PhySet JES20040127EEPROM*/
+#define IPG_PS_MEM_LENB9B               0x01
+#define IPG_PS_MEM_LEN9                 0x02
+#define IPG_PS_NON_COMPDET              0x04
+
+/* PhyCtrl */
+#define IPG_PC_RSVD_MASK                0xFF
+#define IPG_PC_MGMTCLK_LO               0x00
+#define IPG_PC_MGMTCLK_HI               0x01
+#define IPG_PC_MGMTCLK                  0x01
+#define IPG_PC_MGMTDATA                 0x02
+#define IPG_PC_MGMTDIR                  0x04
+#define IPG_PC_DUPLEX_POLARITY          0x08
+#define IPG_PC_DUPLEX_STATUS            0x10
+#define IPG_PC_LINK_POLARITY            0x20
+#define IPG_PC_LINK_SPEED               0xC0
+#define IPG_PC_LINK_SPEED_10MBPS        0x40
+#define IPG_PC_LINK_SPEED_100MBPS       0x80
+#define IPG_PC_LINK_SPEED_1000MBPS      0xC0
+
+/* DMACtrl */
+#define IPG_DC_RSVD_MASK                0xC07D9818
+#define IPG_DC_RX_DMA_COMPLETE          0x00000008
+#define IPG_DC_RX_DMA_POLL_NOW          0x00000010
+#define IPG_DC_TX_DMA_COMPLETE          0x00000800
+#define IPG_DC_TX_DMA_POLL_NOW          0x00001000
+#define IPG_DC_TX_DMA_IN_PROG           0x00008000
+#define IPG_DC_RX_EARLY_DISABLE         0x00010000
+#define IPG_DC_MWI_DISABLE              0x00040000
+#define IPG_DC_TX_WRITE_BACK_DISABLE    0x00080000
+#define IPG_DC_TX_BURST_LIMIT           0x00700000
+#define IPG_DC_TARGET_ABORT             0x40000000
+#define IPG_DC_MASTER_ABORT             0x80000000
+
+/* ASICCtrl */
+#define IPG_AC_RSVD_MASK                0x07FFEFF2
+#define IPG_AC_EXP_ROM_SIZE             0x00000002
+#define IPG_AC_PHY_SPEED10              0x00000010
+#define IPG_AC_PHY_SPEED100             0x00000020
+#define IPG_AC_PHY_SPEED1000            0x00000040
+#define IPG_AC_PHY_MEDIA                0x00000080
+#define IPG_AC_FORCED_CFG               0x00000700
+#define IPG_AC_D3RESETDISABLE           0x00000800
+#define IPG_AC_SPEED_UP_MODE            0x00002000
+#define IPG_AC_LED_MODE                 0x00004000
+#define IPG_AC_RST_OUT_POLARITY         0x00008000
+#define IPG_AC_GLOBAL_RESET             0x00010000
+#define IPG_AC_RX_RESET                 0x00020000
+#define IPG_AC_TX_RESET                 0x00040000
+#define IPG_AC_DMA                      0x00080000
+#define IPG_AC_FIFO                     0x00100000
+#define IPG_AC_NETWORK                  0x00200000
+#define IPG_AC_HOST                     0x00400000
+#define IPG_AC_AUTO_INIT                0x00800000
+#define IPG_AC_RST_OUT                  0x01000000
+#define IPG_AC_INT_REQUEST              0x02000000
+#define IPG_AC_RESET_BUSY               0x04000000
+#define IPG_AC_LED_SPEED                0x08000000	//JES20040127EEPROM
+#define IPG_AC_LED_MODE_BIT_1           0x20000000	//JES20040127EEPROM
+
+/* EepromCtrl */
+#define IPG_EC_RSVD_MASK                0x83FF
+#define IPG_EC_EEPROM_ADDR              0x00FF
+#define IPG_EC_EEPROM_OPCODE            0x0300
+#define IPG_EC_EEPROM_SUBCOMMAD         0x0000
+#define IPG_EC_EEPROM_WRITEOPCODE       0x0100
+#define IPG_EC_EEPROM_READOPCODE        0x0200
+#define IPG_EC_EEPROM_ERASEOPCODE       0x0300
+#define IPG_EC_EEPROM_BUSY              0x8000
+
+/* FIFOCtrl */
+#define IPG_FC_RSVD_MASK                0xC001
+#define IPG_FC_RAM_TEST_MODE            0x0001
+#define IPG_FC_TRANSMITTING             0x4000
+#define IPG_FC_RECEIVING                0x8000
+
+/* TxStatus */
+#define IPG_TS_RSVD_MASK                0xFFFF00DD
+#define IPG_TS_TX_ERROR                 0x00000001
+#define IPG_TS_LATE_COLLISION           0x00000004
+#define IPG_TS_TX_MAX_COLL              0x00000008
+#define IPG_TS_TX_UNDERRUN              0x00000010
+#define IPG_TS_TX_IND_REQD              0x00000040
+#define IPG_TS_TX_COMPLETE              0x00000080
+#define IPG_TS_TX_FRAMEID               0xFFFF0000
+
+/* WakeEvent */
+#define IPG_WE_WAKE_PKT_ENABLE          0x01
+#define IPG_WE_MAGIC_PKT_ENABLE         0x02
+#define IPG_WE_LINK_EVT_ENABLE          0x04
+#define IPG_WE_WAKE_POLARITY            0x08
+#define IPG_WE_WAKE_PKT_EVT             0x10
+#define IPG_WE_MAGIC_PKT_EVT            0x20
+#define IPG_WE_LINK_EVT                 0x40
+#define IPG_WE_WOL_ENABLE               0x80
+
+/* IntEnable */
+#define IPG_IE_RSVD_MASK                0x1FFE
+#define IPG_IE_HOST_ERROR               0x0002
+#define IPG_IE_TX_COMPLETE              0x0004
+#define IPG_IE_MAC_CTRL_FRAME           0x0008
+#define IPG_IE_RX_COMPLETE              0x0010
+#define IPG_IE_RX_EARLY                 0x0020
+#define IPG_IE_INT_REQUESTED            0x0040
+#define IPG_IE_UPDATE_STATS             0x0080
+#define IPG_IE_LINK_EVENT               0x0100
+#define IPG_IE_TX_DMA_COMPLETE          0x0200
+#define IPG_IE_RX_DMA_COMPLETE          0x0400
+#define IPG_IE_RFD_LIST_END             0x0800
+#define IPG_IE_RX_DMA_PRIORITY          0x1000
+
+/* IntStatus */
+#define IPG_IS_RSVD_MASK                0x1FFF
+#define IPG_IS_INTERRUPT_STATUS         0x0001
+#define IPG_IS_HOST_ERROR               0x0002
+#define IPG_IS_TX_COMPLETE              0x0004
+#define IPG_IS_MAC_CTRL_FRAME           0x0008
+#define IPG_IS_RX_COMPLETE              0x0010
+#define IPG_IS_RX_EARLY                 0x0020
+#define IPG_IS_INT_REQUESTED            0x0040
+#define IPG_IS_UPDATE_STATS             0x0080
+#define IPG_IS_LINK_EVENT               0x0100
+#define IPG_IS_TX_DMA_COMPLETE          0x0200
+#define IPG_IS_RX_DMA_COMPLETE          0x0400
+#define IPG_IS_RFD_LIST_END             0x0800
+#define IPG_IS_RX_DMA_PRIORITY          0x1000
+
+/* MACCtrl */
+#define IPG_MC_RSVD_MASK                0x7FE33FA3
+#define IPG_MC_IFS_SELECT               0x00000003
+#define IPG_MC_IFS_4352BIT              0x00000003
+#define IPG_MC_IFS_1792BIT              0x00000002
+#define IPG_MC_IFS_1024BIT              0x00000001
+#define IPG_MC_IFS_96BIT                0x00000000
+#define IPG_MC_DUPLEX_SELECT            0x00000020
+#define IPG_MC_DUPLEX_SELECT_FD         0x00000020
+#define IPG_MC_DUPLEX_SELECT_HD         0x00000000
+#define IPG_MC_TX_FLOW_CONTROL_ENABLE   0x00000080
+#define IPG_MC_RX_FLOW_CONTROL_ENABLE   0x00000100
+#define IPG_MC_RCV_FCS                  0x00000200
+#define IPG_MC_FIFO_LOOPBACK            0x00000400
+#define IPG_MC_MAC_LOOPBACK             0x00000800
+#define IPG_MC_AUTO_VLAN_TAGGING        0x00001000
+#define IPG_MC_AUTO_VLAN_UNTAGGING      0x00002000
+#define IPG_MC_COLLISION_DETECT         0x00010000
+#define IPG_MC_CARRIER_SENSE            0x00020000
+#define IPG_MC_STATISTICS_ENABLE        0x00200000
+#define IPG_MC_STATISTICS_DISABLE       0x00400000
+#define IPG_MC_STATISTICS_ENABLED       0x00800000
+#define IPG_MC_TX_ENABLE                0x01000000
+#define IPG_MC_TX_DISABLE               0x02000000
+#define IPG_MC_TX_ENABLED               0x04000000
+#define IPG_MC_RX_ENABLE                0x08000000
+#define IPG_MC_RX_DISABLE               0x10000000
+#define IPG_MC_RX_ENABLED               0x20000000
+#define IPG_MC_PAUSED                   0x40000000
+
+/*
+ *	Tune
+ */
+
+/* Miscellaneous Constants. */
+#define   TRUE  1
+#define   FALSE 0
+
+/* Assign IPG_APPEND_FCS_ON_TX > 0 for auto FCS append on TX. */
+#define         IPG_APPEND_FCS_ON_TX         TRUE
+
+/* Assign IPG_APPEND_FCS_ON_TX > 0 for auto FCS strip on RX. */
+#define         IPG_STRIP_FCS_ON_RX          TRUE
+
+/* Assign IPG_DROP_ON_RX_ETH_ERRORS > 0 to drop RX frames with
+ * Ethernet errors.
+ */
+#define         IPG_DROP_ON_RX_ETH_ERRORS    TRUE
+
+/* Assign IPG_INSERT_MANUAL_VLAN_TAG > 0 to insert VLAN tags manually
+ * (via TFC).
+ */
+#define		IPG_INSERT_MANUAL_VLAN_TAG   FALSE
+
+/* Assign IPG_ADD_IPCHECKSUM_ON_TX > 0 for auto IP checksum on TX. */
+#define         IPG_ADD_IPCHECKSUM_ON_TX     FALSE
+
+/* Assign IPG_ADD_TCPCHECKSUM_ON_TX > 0 for auto TCP checksum on TX.
+ * DO NOT USE FOR SILICON REVISIONS B3 AND EARLIER.
+ */
+#define         IPG_ADD_TCPCHECKSUM_ON_TX    FALSE
+
+/* Assign IPG_ADD_UDPCHECKSUM_ON_TX > 0 for auto UDP checksum on TX.
+ * DO NOT USE FOR SILICON REVISIONS B3 AND EARLIER.
+ */
+#define         IPG_ADD_UDPCHECKSUM_ON_TX    FALSE
+
+/* If inserting VLAN tags manually, assign the IPG_MANUAL_VLAN_xx
+ * constants as desired.
+ */
+#define		IPG_MANUAL_VLAN_VID		0xABC
+#define		IPG_MANUAL_VLAN_CFI		0x1
+#define		IPG_MANUAL_VLAN_USERPRIORITY 0x5
+
+#define         IPG_IO_REG_RANGE		0xFF
+#define         IPG_MEM_REG_RANGE		0x154
+#define         IPG_DRIVER_NAME		"Sundance Technology IPG Triple-Speed Ethernet"
+#define         IPG_NIC_PHY_ADDRESS          0x01
+#define		IPG_DMALIST_ALIGN_PAD	0x07
+#define		IPG_MULTICAST_HASHTABLE_SIZE	0x40
+
+/* Number of miliseconds to wait after issuing a software reset.
+ * 0x05 <= IPG_AC_RESETWAIT to account for proper 10Mbps operation.
+ */
+#define         IPG_AC_RESETWAIT             0x05
+
+/* Number of IPG_AC_RESETWAIT timeperiods before declaring timeout. */
+#define         IPG_AC_RESET_TIMEOUT         0x0A
+
+/* Minimum number of nanoseconds used to toggle MDC clock during
+ * MII/GMII register access.
+ */
+#define		IPG_PC_PHYCTRLWAIT_NS		200
+
+#define		IPG_TFDLIST_LENGTH		0x100
+
+/* Number of frames between TxDMAComplete interrupt.
+ * 0 < IPG_FRAMESBETWEENTXDMACOMPLETES <= IPG_TFDLIST_LENGTH
+ */
+#define		IPG_FRAMESBETWEENTXDMACOMPLETES 0x1
+
+#ifdef JUMBO_FRAME
+
+# ifdef JUMBO_FRAME_SIZE_2K
+# define JUMBO_FRAME_SIZE 2048
+# define __IPG_RXFRAG_SIZE 2048
+# else
+#  ifdef JUMBO_FRAME_SIZE_3K
+#  define JUMBO_FRAME_SIZE 3072
+#  define __IPG_RXFRAG_SIZE 3072
+#  else
+#   ifdef JUMBO_FRAME_SIZE_4K
+#   define JUMBO_FRAME_SIZE 4096
+#   define __IPG_RXFRAG_SIZE 4088
+#   else
+#    ifdef JUMBO_FRAME_SIZE_5K
+#    define JUMBO_FRAME_SIZE 5120
+#    define __IPG_RXFRAG_SIZE 4088
+#    else
+#     ifdef JUMBO_FRAME_SIZE_6K
+#     define JUMBO_FRAME_SIZE 6144
+#     define __IPG_RXFRAG_SIZE 4088
+#     else
+#      ifdef JUMBO_FRAME_SIZE_7K
+#      define JUMBO_FRAME_SIZE 7168
+#      define __IPG_RXFRAG_SIZE 4088
+#      else
+#       ifdef JUMBO_FRAME_SIZE_8K
+#       define JUMBO_FRAME_SIZE 8192
+#       define __IPG_RXFRAG_SIZE 4088
+#       else
+#        ifdef JUMBO_FRAME_SIZE_9K
+#        define JUMBO_FRAME_SIZE 9216
+#        define __IPG_RXFRAG_SIZE 4088
+#        else
+#         ifdef JUMBO_FRAME_SIZE_10K
+#         define JUMBO_FRAME_SIZE 10240
+#         define __IPG_RXFRAG_SIZE 4088
+#         else
+#         define JUMBO_FRAME_SIZE 4096
+#         endif
+#        endif
+#       endif
+#      endif
+#     endif
+#    endif
+#   endif
+#  endif
+# endif
+#endif
+
+/* Size of allocated received buffers. Nominally 0x0600.
+ * Define larger if expecting jumbo frames.
+ */
+#ifdef JUMBO_FRAME
+//IPG_TXFRAG_SIZE must <= 0x2b00, or TX will crash
+#define		IPG_TXFRAG_SIZE		JUMBO_FRAME_SIZE
+#endif
+
+/* Size of allocated received buffers. Nominally 0x0600.
+ * Define larger if expecting jumbo frames.
+ */
+#ifdef JUMBO_FRAME
+//4088=4096-8
+#define		IPG_RXFRAG_SIZE		__IPG_RXFRAG_SIZE
+#define     IPG_RXSUPPORT_SIZE   IPG_MAX_RXFRAME_SIZE
+#else
+#define		IPG_RXFRAG_SIZE		0x0600
+#define     IPG_RXSUPPORT_SIZE   IPG_RXFRAG_SIZE
+#endif
+
+/* IPG_MAX_RXFRAME_SIZE <= IPG_RXFRAG_SIZE */
+#ifdef JUMBO_FRAME
+#define		IPG_MAX_RXFRAME_SIZE		JUMBO_FRAME_SIZE
+#else
+#define		IPG_MAX_RXFRAME_SIZE		0x0600
+#endif
+
+#define		IPG_RFDLIST_LENGTH		0x100
+
+/* Maximum number of RFDs to process per interrupt.
+ * 1 < IPG_MAXRFDPROCESS_COUNT < IPG_RFDLIST_LENGTH
+ */
+#define		IPG_MAXRFDPROCESS_COUNT	0x80
+
+/* Minimum margin between last freed RFD, and current RFD.
+ * 1 < IPG_MINUSEDRFDSTOFREE < IPG_RFDLIST_LENGTH
+ */
+#define		IPG_MINUSEDRFDSTOFREE	0x80
+
+/* specify the jumbo frame maximum size
+ * per unit is 0x600 (the RxBuffer size that one RFD can carry)
+ */
+#define     MAX_JUMBOSIZE	        0x8	// max is 12K
+
+/* Key register values loaded at driver start up. */
+
+/* TXDMAPollPeriod is specified in 320ns increments.
+ *
+ * Value	Time
+ * ---------------------
+ * 0x00-0x01	320ns
+ * 0x03		~1us
+ * 0x1F		~10us
+ * 0xFF		~82us
+ */
+#define		IPG_TXDMAPOLLPERIOD_VALUE	0x26
+
+/* TxDMAUrgentThresh specifies the minimum amount of
+ * data in the transmit FIFO before asserting an
+ * urgent transmit DMA request.
+ *
+ * Value	Min TxFIFO occupied space before urgent TX request
+ * ---------------------------------------------------------------
+ * 0x00-0x04	128 bytes (1024 bits)
+ * 0x27		1248 bytes (~10000 bits)
+ * 0x30		1536 bytes (12288 bits)
+ * 0xFF		8192 bytes (65535 bits)
+ */
+#define		IPG_TXDMAURGENTTHRESH_VALUE	0x04
+
+/* TxDMABurstThresh specifies the minimum amount of
+ * free space in the transmit FIFO before asserting an
+ * transmit DMA request.
+ *
+ * Value	Min TxFIFO free space before TX request
+ * ----------------------------------------------------
+ * 0x00-0x08	256 bytes
+ * 0x30		1536 bytes
+ * 0xFF		8192 bytes
+ */
+#define		IPG_TXDMABURSTTHRESH_VALUE	0x30
+
+/* RXDMAPollPeriod is specified in 320ns increments.
+ *
+ * Value	Time
+ * ---------------------
+ * 0x00-0x01	320ns
+ * 0x03		~1us
+ * 0x1F		~10us
+ * 0xFF		~82us
+ */
+#define		IPG_RXDMAPOLLPERIOD_VALUE	0x01
+
+/* RxDMAUrgentThresh specifies the minimum amount of
+ * free space within the receive FIFO before asserting
+ * a urgent receive DMA request.
+ *
+ * Value	Min RxFIFO free space before urgent RX request
+ * ---------------------------------------------------------------
+ * 0x00-0x04	128 bytes (1024 bits)
+ * 0x27		1248 bytes (~10000 bits)
+ * 0x30		1536 bytes (12288 bits)
+ * 0xFF		8192 bytes (65535 bits)
+ */
+#define		IPG_RXDMAURGENTTHRESH_VALUE	0x30
+
+/* RxDMABurstThresh specifies the minimum amount of
+ * occupied space within the receive FIFO before asserting
+ * a receive DMA request.
+ *
+ * Value	Min TxFIFO free space before TX request
+ * ----------------------------------------------------
+ * 0x00-0x08	256 bytes
+ * 0x30		1536 bytes
+ * 0xFF		8192 bytes
+ */
+#define		IPG_RXDMABURSTTHRESH_VALUE	0x30
+
+/* FlowOnThresh specifies the maximum amount of occupied
+ * space in the receive FIFO before a PAUSE frame with
+ * maximum pause time transmitted.
+ *
+ * Value	Max RxFIFO occupied space before PAUSE
+ * ---------------------------------------------------
+ * 0x0000	0 bytes
+ * 0x0740	29,696 bytes
+ * 0x07FF	32,752 bytes
+ */
+#define		IPG_FLOWONTHRESH_VALUE	0x0740
+
+/* FlowOffThresh specifies the minimum amount of occupied
+ * space in the receive FIFO before a PAUSE frame with
+ * zero pause time is transmitted.
+ *
+ * Value	Max RxFIFO occupied space before PAUSE
+ * ---------------------------------------------------
+ * 0x0000	0 bytes
+ * 0x00BF	3056 bytes
+ * 0x07FF	32,752 bytes
+ */
+#define		IPG_FLOWOFFTHRESH_VALUE	0x00BF
+
+/*
+ * Miscellaneous macros.
+ */
+
+/* Marco for printing debug statements.
+#  define IPG_DDEBUG_MSG(args...) printk(KERN_DEBUG "IPG: " ## args) */
+#ifdef IPG_DEBUG
+#  define IPG_DEBUG_MSG(args...)
+#  define IPG_DDEBUG_MSG(args...) printk(KERN_DEBUG "IPG: " args)
+#  define IPG_DUMPRFDLIST(args) ipg_dump_rfdlist(args)
+#  define IPG_DUMPTFDLIST(args) ipg_dump_tfdlist(args)
+#else
+#  define IPG_DEBUG_MSG(args...)
+#  define IPG_DDEBUG_MSG(args...)
+#  define IPG_DUMPRFDLIST(args)
+#  define IPG_DUMPTFDLIST(args)
+#endif
+
+/*
+ * End miscellaneous macros.
+ */
+
+/* Transmit Frame Descriptor. The IPG supports 15 fragments,
+ * however Linux requires only a single fragment. Note, each
+ * TFD field is 64 bits wide.
+ */
+struct ipg_tx {
+	u64 next_desc;
+	u64 tfc;
+	u64 frag_info;
+};
+
+/* Receive Frame Descriptor. Note, each RFD field is 64 bits wide.
+ */
+struct ipg_rx {
+	u64 next_desc;
+	u64 rfs;
+	u64 frag_info;
+};
+
+struct SJumbo {
+	int FoundStart;
+	int CurrentSize;
+	struct sk_buff *skb;
+};
+/* Structure of IPG NIC specific data. */
+struct ipg_nic_private {
+	void __iomem *ioaddr;
+	struct ipg_tx *txd;
+	struct ipg_rx *rxd;
+	dma_addr_t txd_map;
+	dma_addr_t rxd_map;
+	struct sk_buff *TxBuff[IPG_TFDLIST_LENGTH];
+	struct sk_buff *RxBuff[IPG_RFDLIST_LENGTH];
+	unsigned int tx_current;
+	unsigned int tx_dirty;
+	unsigned int rx_current;
+	unsigned int rx_dirty;
+// Add by Grace 2005/05/19
+#ifdef JUMBO_FRAME
+	struct SJumbo Jumbo;
+#endif
+	unsigned int rx_buf_sz;
+	struct pci_dev *pdev;
+	struct net_device *dev;
+	struct net_device_stats stats;
+	spinlock_t lock;
+	int tenmbpsmode;
+
+	/*Jesse20040128EEPROM_VALUE */
+	u16 LED_Mode;
+	u16 station_addr[3];	/* Station Address in EEPROM Reg 0x10..0x12 */
+
+	struct mutex		mii_mutex;
+	struct mii_if_info	mii_if;
+	int ResetCurrentTFD;
+#ifdef IPG_DEBUG
+	int RFDlistendCount;
+	int RFDListCheckedCount;
+	int EmptyRFDListCount;
+#endif
+	struct delayed_work task;
+};
+
+//variable record -- index by leading revision/length
+//Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
+unsigned short DefaultPhyParam[] = {
+	// 11/12/03 IP1000A v1-3 rev=0x40
+	/*--------------------------------------------------------------------------
+	(0x4000|(15*4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 22, 0x85bd, 24, 0xfff2,
+				 27, 0x0c10, 28, 0x0c10, 29, 0x2c10, 31, 0x0003, 23, 0x92f6,
+				 31, 0x0000, 23, 0x003d, 30, 0x00de, 20, 0x20e7,  9, 0x0700,
+	  --------------------------------------------------------------------------*/
+	// 12/17/03 IP1000A v1-4 rev=0x40
+	(0x4000 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
+	    0x0000,
+	30, 0x005e, 9, 0x0700,
+	// 01/09/04 IP1000A v1-5 rev=0x41
+	(0x4100 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
+	    0x0000,
+	30, 0x005e, 9, 0x0700,
+	0x0000
+};
+
+#endif				/* __LINUX_IPG_H */
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 55f307f..c9c24dd 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1841,6 +1841,8 @@
 #define PCI_VENDOR_ID_ABOCOM		0x13D1
 #define PCI_DEVICE_ID_ABOCOM_2BD1       0x2BD1
 
+#define PCI_VENDOR_ID_SUNDANCE		0x13f0
+
 #define PCI_VENDOR_ID_CMEDIA		0x13f6
 #define PCI_DEVICE_ID_CMEDIA_CM8338A	0x0100
 #define PCI_DEVICE_ID_CMEDIA_CM8338B	0x0101
-- 
1.5.2.4

