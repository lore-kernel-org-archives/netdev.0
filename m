From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 3/4 net-next] net: phy: add Broadcom B53 switch driver
Date: Tue, 22 Oct 2013 11:23:48 -0700
Message-ID: <1382466229-15123-4-git-send-email-f.fainelli@gmail.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, s.hauer@pengutronix.de, nbd@openwrt.org,
	blogic@openwrt.org, jogo@openwrt.org, gary@mlbassoc.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2517 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753537Ab3JVSYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 14:24:11 -0400
In-Reply-To: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Gorski <jogo@openwrt.org>

This patch add support for the BCM53xx aka RoboSwitch managed Ethernet
switches using the proposed swconfig Generic Netlink API.

This driver supports both SPI and MDIO connected switches and in
particular the following models: BCM5325E, BCM5365, BCM539x,
BCM53115 and BCM53125.

Support for BCM63xx integrated switches as well as BCM53xxx ARM-based
platforms will be submitted as separate driver backends.

Signed-off-by: Jonas Gorski <jogo@openwrt.org>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/Kconfig             |    2 +
 drivers/net/phy/Makefile            |    1 +
 drivers/net/phy/b53/Kconfig         |   25 +
 drivers/net/phy/b53/Makefile        |    8 +
 drivers/net/phy/b53/b53_common.c    | 1336 +++++++++++++++++++++++++++++++++++
 drivers/net/phy/b53/b53_mdio.c      |  425 +++++++++++
 drivers/net/phy/b53/b53_phy_fixup.c |   55 ++
 drivers/net/phy/b53/b53_priv.h      |  282 ++++++++
 drivers/net/phy/b53/b53_regs.h      |  311 ++++++++
 drivers/net/phy/b53/b53_spi.c       |  329 +++++++++
 include/linux/platform_data/b53.h   |   32 +
 11 files changed, 2806 insertions(+)
 create mode 100644 drivers/net/phy/b53/Kconfig
 create mode 100644 drivers/net/phy/b53/Makefile
 create mode 100644 drivers/net/phy/b53/b53_common.c
 create mode 100644 drivers/net/phy/b53/b53_mdio.c
 create mode 100644 drivers/net/phy/b53/b53_phy_fixup.c
 create mode 100644 drivers/net/phy/b53/b53_priv.h
 create mode 100644 drivers/net/phy/b53/b53_regs.h
 create mode 100644 drivers/net/phy/b53/b53_spi.c
 create mode 100644 include/linux/platform_data/b53.h

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 9b3e117..d02ed5a 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -192,6 +192,8 @@ config MDIO_BUS_MUX_MMIOREG
 
 	  Currently, only 8-bit registers are supported.
 
+source "drivers/net/phy/b53/Kconfig"
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 268c7de..1998034 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -11,6 +11,7 @@ obj-$(CONFIG_LXT_PHY)		+= lxt.o
 obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
 obj-$(CONFIG_SMSC_PHY)		+= smsc.o
 obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
+obj-$(CONFIG_B53)		+= b53/
 obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_BCM63XX_PHY)	+= bcm63xx.o
 obj-$(CONFIG_BCM87XX_PHY)	+= bcm87xx.o
diff --git a/drivers/net/phy/b53/Kconfig b/drivers/net/phy/b53/Kconfig
new file mode 100644
index 0000000..4cbcd7e
--- /dev/null
+++ b/drivers/net/phy/b53/Kconfig
@@ -0,0 +1,25 @@
+menuconfig B53
+	tristate "Broadcom bcm53xx managed switch support"
+	depends on SWCONFIG
+	help
+	  This driver adds support for Broadcom managed switch chips. It supports
+	  BCM5325E, BCM5365, BCM539x, BCM53115 and BCM53125 as well as BCM63XX
+	  integrated switches.
+
+config B53_SPI_DRIVER
+	tristate "B53 SPI connected switch driver"
+	depends on B53 && SPI
+	help
+	  Select to enable support for registering switches configured
+	  through SPI.
+
+config B53_PHY_DRIVER
+	tristate "B53 MDIO connected switch driver"
+	depends on B53
+	select B53_PHY_FIXUP
+	help
+	  Select to enable support for registering switches configured
+	  through MDIO.
+
+config B53_PHY_FIXUP
+	bool
diff --git a/drivers/net/phy/b53/Makefile b/drivers/net/phy/b53/Makefile
new file mode 100644
index 0000000..ceb21d4
--- /dev/null
+++ b/drivers/net/phy/b53/Makefile
@@ -0,0 +1,8 @@
+obj-$(CONFIG_B53)		+= b53_common.o
+
+obj-$(CONFIG_B53_PHY_FIXUP)	+= b53_phy_fixup.o
+
+obj-$(CONFIG_B53_PHY_DRIVER)	+= b53_mdio.o
+obj-$(CONFIG_B53_SPI_DRIVER)	+= b53_spi.o
+
+ccflags-y			+= -Werror
diff --git a/drivers/net/phy/b53/b53_common.c b/drivers/net/phy/b53/b53_common.c
new file mode 100644
index 0000000..1f14ab4
--- /dev/null
+++ b/drivers/net/phy/b53/b53_common.c
@@ -0,0 +1,1336 @@
+/*
+ * B53 switch driver main logic
+ *
+ * Copyright (C) 2011-2013 Jonas Gorski <jogo@openwrt.org>
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/delay.h>
+#include <linux/export.h>
+#include <linux/gpio.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/swconfig.h>
+#include <linux/platform_data/b53.h>
+
+#include "b53_regs.h"
+#include "b53_priv.h"
+
+/* buffer size needed for displaying all MIBs with max'd values */
+#define B53_BUF_SIZE	1188
+
+struct b53_mib_desc {
+	u8 size;
+	u8 offset;
+	const char *name;
+};
+
+
+/* BCM5365 MIB counters */
+static const struct b53_mib_desc b53_mibs_65[] = {
+	{ 8, 0x00, "TxOctets" },
+	{ 4, 0x08, "TxDropPkts" },
+	{ 4, 0x10, "TxBroadcastPkts" },
+	{ 4, 0x14, "TxMulticastPkts" },
+	{ 4, 0x18, "TxUnicastPkts" },
+	{ 4, 0x1c, "TxCollisions" },
+	{ 4, 0x20, "TxSingleCollision" },
+	{ 4, 0x24, "TxMultipleCollision" },
+	{ 4, 0x28, "TxDeferredTransmit" },
+	{ 4, 0x2c, "TxLateCollision" },
+	{ 4, 0x30, "TxExcessiveCollision" },
+	{ 4, 0x38, "TxPausePkts" },
+	{ 8, 0x44, "RxOctets" },
+	{ 4, 0x4c, "RxUndersizePkts" },
+	{ 4, 0x50, "RxPausePkts" },
+	{ 4, 0x54, "Pkts64Octets" },
+	{ 4, 0x58, "Pkts65to127Octets" },
+	{ 4, 0x5c, "Pkts128to255Octets" },
+	{ 4, 0x60, "Pkts256to511Octets" },
+	{ 4, 0x64, "Pkts512to1023Octets" },
+	{ 4, 0x68, "Pkts1024to1522Octets" },
+	{ 4, 0x6c, "RxOversizePkts" },
+	{ 4, 0x70, "RxJabbers" },
+	{ 4, 0x74, "RxAlignmentErrors" },
+	{ 4, 0x78, "RxFCSErrors" },
+	{ 8, 0x7c, "RxGoodOctets" },
+	{ 4, 0x84, "RxDropPkts" },
+	{ 4, 0x88, "RxUnicastPkts" },
+	{ 4, 0x8c, "RxMulticastPkts" },
+	{ 4, 0x90, "RxBroadcastPkts" },
+	{ 4, 0x94, "RxSAChanges" },
+	{ 4, 0x98, "RxFragments" },
+	{ },
+};
+
+/* BCM63xx MIB counters */
+static const struct b53_mib_desc b53_mibs_63xx[] = {
+	{ 8, 0x00, "TxOctets" },
+	{ 4, 0x08, "TxDropPkts" },
+	{ 4, 0x0c, "TxQoSPkts" },
+	{ 4, 0x10, "TxBroadcastPkts" },
+	{ 4, 0x14, "TxMulticastPkts" },
+	{ 4, 0x18, "TxUnicastPkts" },
+	{ 4, 0x1c, "TxCollisions" },
+	{ 4, 0x20, "TxSingleCollision" },
+	{ 4, 0x24, "TxMultipleCollision" },
+	{ 4, 0x28, "TxDeferredTransmit" },
+	{ 4, 0x2c, "TxLateCollision" },
+	{ 4, 0x30, "TxExcessiveCollision" },
+	{ 4, 0x38, "TxPausePkts" },
+	{ 8, 0x3c, "TxQoSOctets" },
+	{ 8, 0x44, "RxOctets" },
+	{ 4, 0x4c, "RxUndersizePkts" },
+	{ 4, 0x50, "RxPausePkts" },
+	{ 4, 0x54, "Pkts64Octets" },
+	{ 4, 0x58, "Pkts65to127Octets" },
+	{ 4, 0x5c, "Pkts128to255Octets" },
+	{ 4, 0x60, "Pkts256to511Octets" },
+	{ 4, 0x64, "Pkts512to1023Octets" },
+	{ 4, 0x68, "Pkts1024to1522Octets" },
+	{ 4, 0x6c, "RxOversizePkts" },
+	{ 4, 0x70, "RxJabbers" },
+	{ 4, 0x74, "RxAlignmentErrors" },
+	{ 4, 0x78, "RxFCSErrors" },
+	{ 8, 0x7c, "RxGoodOctets" },
+	{ 4, 0x84, "RxDropPkts" },
+	{ 4, 0x88, "RxUnicastPkts" },
+	{ 4, 0x8c, "RxMulticastPkts" },
+	{ 4, 0x90, "RxBroadcastPkts" },
+	{ 4, 0x94, "RxSAChanges" },
+	{ 4, 0x98, "RxFragments" },
+	{ 4, 0xa0, "RxSymbolErrors" },
+	{ 4, 0xa4, "RxQoSPkts" },
+	{ 8, 0xa8, "RxQoSOctets" },
+	{ 4, 0xb0, "Pkts1523to2047Octets" },
+	{ 4, 0xb4, "Pkts2048to4095Octets" },
+	{ 4, 0xb8, "Pkts4096to8191Octets" },
+	{ 4, 0xbc, "Pkts8192to9728Octets" },
+	{ 4, 0xc0, "RxDiscarded" },
+	{ }
+};
+
+/* MIB counters */
+static const struct b53_mib_desc b53_mibs[] = {
+	{ 8, 0x00, "TxOctets" },
+	{ 4, 0x08, "TxDropPkts" },
+	{ 4, 0x10, "TxBroadcastPkts" },
+	{ 4, 0x14, "TxMulticastPkts" },
+	{ 4, 0x18, "TxUnicastPkts" },
+	{ 4, 0x1c, "TxCollisions" },
+	{ 4, 0x20, "TxSingleCollision" },
+	{ 4, 0x24, "TxMultipleCollision" },
+	{ 4, 0x28, "TxDeferredTransmit" },
+	{ 4, 0x2c, "TxLateCollision" },
+	{ 4, 0x30, "TxExcessiveCollision" },
+	{ 4, 0x38, "TxPausePkts" },
+	{ 8, 0x50, "RxOctets" },
+	{ 4, 0x58, "RxUndersizePkts" },
+	{ 4, 0x5c, "RxPausePkts" },
+	{ 4, 0x60, "Pkts64Octets" },
+	{ 4, 0x64, "Pkts65to127Octets" },
+	{ 4, 0x68, "Pkts128to255Octets" },
+	{ 4, 0x6c, "Pkts256to511Octets" },
+	{ 4, 0x70, "Pkts512to1023Octets" },
+	{ 4, 0x74, "Pkts1024to1522Octets" },
+	{ 4, 0x78, "RxOversizePkts" },
+	{ 4, 0x7c, "RxJabbers" },
+	{ 4, 0x80, "RxAlignmentErrors" },
+	{ 4, 0x84, "RxFCSErrors" },
+	{ 8, 0x88, "RxGoodOctets" },
+	{ 4, 0x90, "RxDropPkts" },
+	{ 4, 0x94, "RxUnicastPkts" },
+	{ 4, 0x98, "RxMulticastPkts" },
+	{ 4, 0x9c, "RxBroadcastPkts" },
+	{ 4, 0xa0, "RxSAChanges" },
+	{ 4, 0xa4, "RxFragments" },
+	{ 4, 0xa8, "RxJumboPkts" },
+	{ 4, 0xac, "RxSymbolErrors" },
+	{ 4, 0xc0, "RxDiscarded" },
+	{ }
+};
+
+static int b53_do_vlan_op(struct b53_device *dev, u8 op)
+{
+	unsigned int i;
+
+	b53_write8(dev, B53_ARLIO_PAGE, dev->vta_regs[0], VTA_START_CMD | op);
+
+	for (i = 0; i < 10; i++) {
+		u8 vta;
+
+		b53_read8(dev, B53_ARLIO_PAGE, dev->vta_regs[0], &vta);
+		if (!(vta & VTA_START_CMD))
+			return 0;
+
+		usleep_range(100, 200);
+	}
+
+	return -EIO;
+}
+
+static void b53_set_vlan_entry(struct b53_device *dev, u16 vid, u16 members,
+			       u16 untag)
+{
+	if (is5325(dev)) {
+		u32 entry = 0;
+
+		if (members) {
+			entry = (untag << VA_UNTAG_S) | members;
+			if (dev->core_rev >= 3)
+				entry |= VA_VALID_25_R4 | vid << VA_VID_HIGH_S;
+			else
+				entry |= VA_VALID_25;
+		}
+
+		b53_write32(dev, B53_VLAN_PAGE, B53_VLAN_WRITE_25, entry);
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_TABLE_ACCESS_25, vid |
+			    VTA_RW_STATE_WR | VTA_RW_OP_EN);
+	} else if (is5365(dev)) {
+		u16 entry = 0;
+
+		if (members)
+			entry = (untag << VA_UNTAG_S) | members | VA_VALID_65;
+
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_WRITE_65, entry);
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_TABLE_ACCESS_65, vid |
+			    VTA_RW_STATE_WR | VTA_RW_OP_EN);
+	} else {
+		b53_write16(dev, B53_ARLIO_PAGE, dev->vta_regs[1], vid);
+		b53_write32(dev, B53_ARLIO_PAGE, dev->vta_regs[2],
+			    (untag << VTE_UNTAG_S) | members);
+
+		b53_do_vlan_op(dev, VTA_CMD_WRITE);
+	}
+}
+
+void b53_set_forwarding(struct b53_device *dev, int enable)
+{
+	u8 mgmt;
+
+	b53_read8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, &mgmt);
+
+	if (enable)
+		mgmt |= SM_SW_FWD_EN;
+	else
+		mgmt &= ~SM_SW_FWD_EN;
+
+	b53_write8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, mgmt);
+}
+
+static void b53_enable_vlan(struct b53_device *dev, int enable)
+{
+	u8 mgmt, vc0, vc1, vc4 = 0, vc5;
+
+	b53_read8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, &mgmt);
+	b53_read8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL0, &vc0);
+	b53_read8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL1, &vc1);
+
+	if (is5325(dev) || is5365(dev)) {
+		b53_read8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL4_25, &vc4);
+		b53_read8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL5_25, &vc5);
+	} else if (is63xx(dev)) {
+		b53_read8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL4_63XX, &vc4);
+		b53_read8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL5_63XX, &vc5);
+	} else {
+		b53_read8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL4, &vc4);
+		b53_read8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL5, &vc5);
+	}
+
+	mgmt &= ~SM_SW_FWD_MODE;
+
+	if (enable) {
+		vc0 |= VC0_VLAN_EN | VC0_VID_CHK_EN | VC0_VID_HASH_VID;
+		vc1 |= VC1_RX_MCST_UNTAG_EN | VC1_RX_MCST_FWD_EN;
+		vc4 &= ~VC4_ING_VID_CHECK_MASK;
+		vc4 |= VC4_ING_VID_VIO_DROP << VC4_ING_VID_CHECK_S;
+		vc5 |= VC5_DROP_VTABLE_MISS;
+
+		if (is5325(dev))
+			vc0 &= ~VC0_RESERVED_1;
+
+		if (is5325(dev) || is5365(dev))
+			vc1 |= VC1_RX_MCST_TAG_EN;
+
+		if (!is5325(dev) && !is5365(dev)) {
+			if (dev->allow_vid_4095)
+				vc5 |= VC5_VID_FFF_EN;
+			else
+				vc5 &= ~VC5_VID_FFF_EN;
+		}
+	} else {
+		vc0 &= ~(VC0_VLAN_EN | VC0_VID_CHK_EN | VC0_VID_HASH_VID);
+		vc1 &= ~(VC1_RX_MCST_UNTAG_EN | VC1_RX_MCST_FWD_EN);
+		vc4 &= ~VC4_ING_VID_CHECK_MASK;
+		vc5 &= ~VC5_DROP_VTABLE_MISS;
+
+		if (is5325(dev) || is5365(dev))
+			vc4 |= VC4_ING_VID_VIO_FWD << VC4_ING_VID_CHECK_S;
+		else
+			vc4 |= VC4_ING_VID_VIO_TO_IMP << VC4_ING_VID_CHECK_S;
+
+		if (is5325(dev) || is5365(dev))
+			vc1 &= ~VC1_RX_MCST_TAG_EN;
+
+		if (!is5325(dev) && !is5365(dev))
+			vc5 &= ~VC5_VID_FFF_EN;
+	}
+
+	b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL0, vc0);
+	b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL1, vc1);
+
+	if (is5325(dev) || is5365(dev)) {
+		/* enable the high 8 bit vid check on 5325 */
+		if (is5325(dev) && enable)
+			b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL3,
+				   VC3_HIGH_8BIT_EN);
+		else
+			b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL3, 0);
+
+		b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL4_25, vc4);
+		b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL5_25, vc5);
+	} else if (is63xx(dev)) {
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_CTRL3_63XX, 0);
+		b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL4_63XX, vc4);
+		b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL5_63XX, vc5);
+	} else {
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_CTRL3, 0);
+		b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL4, vc4);
+		b53_write8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL5, vc5);
+	}
+
+	b53_write8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, mgmt);
+}
+
+static int b53_set_jumbo(struct b53_device *dev, int enable, int allow_10_100)
+{
+	u32 port_mask = 0;
+	u16 max_size = JMS_MIN_SIZE;
+
+	if (is5325(dev) || is5365(dev))
+		return -EINVAL;
+
+	if (enable) {
+		port_mask = dev->enabled_ports;
+		max_size = JMS_MAX_SIZE;
+		if (allow_10_100)
+			port_mask |= JPM_10_100_JUMBO_EN;
+	}
+
+	b53_write32(dev, B53_JUMBO_PAGE, dev->jumbo_pm_reg, port_mask);
+	return b53_write16(dev, B53_JUMBO_PAGE, dev->jumbo_size_reg, max_size);
+}
+
+static int b53_flush_arl(struct b53_device *dev)
+{
+	unsigned int i;
+
+	b53_write8(dev, B53_CTRL_PAGE, B53_FAST_AGE_CTRL,
+		   FAST_AGE_DONE | FAST_AGE_DYNAMIC | FAST_AGE_STATIC);
+
+	for (i = 0; i < 10; i++) {
+		u8 fast_age_ctrl;
+
+		b53_read8(dev, B53_CTRL_PAGE, B53_FAST_AGE_CTRL,
+			  &fast_age_ctrl);
+
+		if (!(fast_age_ctrl & FAST_AGE_DONE))
+			return 0;
+
+		mdelay(1);
+	}
+
+	pr_warn("time out while flushing ARL\n");
+
+	return -EINVAL;
+}
+
+static void b53_enable_ports(struct b53_device *dev)
+{
+	unsigned i;
+
+	b53_for_each_port(dev, i) {
+		u8 port_ctrl;
+		u16 pvlan_mask;
+
+		/*
+		 * prevent leaking packets between wan and lan in unmanaged
+		 * mode through port vlans.
+		 */
+		if (dev->enable_vlan || is_cpu_port(dev, i))
+			pvlan_mask = 0x1ff;
+		else if (is531x5(dev))
+			/* BCM53115 may use a different port as cpu port */
+			pvlan_mask = BIT(dev->sw_dev.cpu_port);
+		else
+			pvlan_mask = BIT(B53_CPU_PORT);
+
+		/* BCM5325 CPU port is at 8 */
+		if ((is5325(dev) || is5365(dev)) && i == B53_CPU_PORT_25)
+			i = B53_CPU_PORT;
+
+		if (dev->chip_id == BCM5398_DEVICE_ID && (i == 6 || i == 7))
+			/* disable unused ports 6 & 7 */
+			port_ctrl = PORT_CTRL_RX_DISABLE | PORT_CTRL_TX_DISABLE;
+		else if (i == B53_CPU_PORT)
+			port_ctrl = PORT_CTRL_RX_BCST_EN |
+				    PORT_CTRL_RX_MCST_EN |
+				    PORT_CTRL_RX_UCST_EN;
+		else
+			port_ctrl = 0;
+
+		b53_write16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(i),
+			    pvlan_mask);
+
+		/* port state is handled by bcm63xx_enet driver */
+		if (!is63xx(dev))
+			b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(i),
+				   port_ctrl);
+	}
+}
+
+static void b53_enable_mib(struct b53_device *dev)
+{
+	u8 gc;
+
+	b53_read8(dev, B53_CTRL_PAGE, B53_GLOBAL_CONFIG, &gc);
+
+	gc &= ~(GC_RESET_MIB | GC_MIB_AC_EN);
+
+	b53_write8(dev, B53_CTRL_PAGE, B53_GLOBAL_CONFIG, gc);
+}
+
+static int b53_apply(struct b53_device *dev)
+{
+	int i;
+
+	/* clear all vlan entries */
+	if (is5325(dev) || is5365(dev)) {
+		for (i = 1; i < dev->sw_dev.vlans; i++)
+			b53_set_vlan_entry(dev, i, 0, 0);
+	} else {
+		b53_do_vlan_op(dev, VTA_CMD_CLEAR);
+	}
+
+	b53_enable_vlan(dev, dev->enable_vlan);
+
+	/* fill VLAN table */
+	if (dev->enable_vlan) {
+		for (i = 0; i < dev->sw_dev.vlans; i++) {
+			struct b53_vlan *vlan = &dev->vlans[i];
+
+			if (!vlan->members)
+				continue;
+
+			b53_set_vlan_entry(dev, i, vlan->members, vlan->untag);
+		}
+
+		b53_for_each_port(dev, i)
+			b53_write16(dev, B53_VLAN_PAGE,
+				    B53_VLAN_PORT_DEF_TAG(i),
+				    dev->ports[i].pvid);
+	} else {
+		b53_for_each_port(dev, i)
+			b53_write16(dev, B53_VLAN_PAGE,
+				    B53_VLAN_PORT_DEF_TAG(i), 1);
+
+	}
+
+	b53_enable_ports(dev);
+
+	if (!is5325(dev) && !is5365(dev))
+		b53_set_jumbo(dev, dev->enable_jumbo, 1);
+
+	return 0;
+}
+
+void b53_switch_reset_gpio(struct b53_device *dev)
+{
+	int gpio = dev->reset_gpio;
+
+	if (gpio < 0)
+		return;
+
+	/*
+	 * Reset sequence: RESET low(50ms)->high(20ms)
+	 */
+	gpio_set_value(gpio, 0);
+	mdelay(50);
+
+	gpio_set_value(gpio, 1);
+	mdelay(20);
+
+	dev->current_page = 0xff;
+}
+
+static int b53_switch_reset(struct b53_device *dev)
+{
+	u8 mgmt;
+
+	b53_switch_reset_gpio(dev);
+
+	if (is539x(dev)) {
+		b53_write8(dev, B53_CTRL_PAGE, B53_SOFTRESET, 0x83);
+		b53_write8(dev, B53_CTRL_PAGE, B53_SOFTRESET, 0x00);
+	}
+
+	b53_read8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, &mgmt);
+
+	if (!(mgmt & SM_SW_FWD_EN)) {
+		mgmt &= ~SM_SW_FWD_MODE;
+		mgmt |= SM_SW_FWD_EN;
+
+		b53_write8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, mgmt);
+		b53_read8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, &mgmt);
+
+		if (!(mgmt & SM_SW_FWD_EN)) {
+			pr_err("Failed to enable switch!\n");
+			return -EINVAL;
+		}
+	}
+
+	/* enable all ports */
+	b53_enable_ports(dev);
+
+	/* configure MII port if necessary */
+	if (is5325(dev)) {
+		u8 mii_port_override;
+
+		b53_read8(dev, B53_CTRL_PAGE, B53_PORT_OVERRIDE_CTRL,
+			  &mii_port_override);
+		/* reverse mii needs to be enabled */
+		if (!(mii_port_override & PORT_OVERRIDE_RV_MII_25)) {
+			b53_write8(dev, B53_CTRL_PAGE, B53_PORT_OVERRIDE_CTRL,
+				   mii_port_override | PORT_OVERRIDE_RV_MII_25);
+			b53_read8(dev, B53_CTRL_PAGE, B53_PORT_OVERRIDE_CTRL,
+				  &mii_port_override);
+
+			if (!(mii_port_override & PORT_OVERRIDE_RV_MII_25)) {
+				pr_err("Failed to enable reverse MII mode\n");
+				return -EINVAL;
+			}
+		}
+	} else if (is531x5(dev) && dev->sw_dev.cpu_port == B53_CPU_PORT) {
+		u8 mii_port_override;
+
+		b53_read8(dev, B53_CTRL_PAGE, B53_PORT_OVERRIDE_CTRL,
+			  &mii_port_override);
+		b53_write8(dev, B53_CTRL_PAGE, B53_PORT_OVERRIDE_CTRL,
+			   mii_port_override | PORT_OVERRIDE_EN |
+			   PORT_OVERRIDE_LINK);
+	}
+
+	b53_enable_mib(dev);
+
+	return b53_flush_arl(dev);
+}
+
+/*
+ * Swconfig glue functions
+ */
+
+static int b53_global_get_vlan_enable(struct switch_dev *dev,
+				      const struct switch_attr *attr,
+				      struct switch_val *val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	val->value.i = priv->enable_vlan;
+
+	return 0;
+}
+
+static int b53_global_set_vlan_enable(struct switch_dev *dev,
+				      const struct switch_attr *attr,
+				      struct switch_val *val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	priv->enable_vlan = val->value.i;
+
+	return 0;
+}
+
+static int b53_global_get_jumbo_enable(struct switch_dev *dev,
+				       const struct switch_attr *attr,
+				       struct switch_val *val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	val->value.i = priv->enable_jumbo;
+
+	return 0;
+}
+
+static int b53_global_set_jumbo_enable(struct switch_dev *dev,
+				       const struct switch_attr *attr,
+				       struct switch_val *val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	priv->enable_jumbo = val->value.i;
+
+	return 0;
+}
+
+static int b53_global_get_4095_enable(struct switch_dev *dev,
+				      const struct switch_attr *attr,
+				      struct switch_val *val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	val->value.i = priv->allow_vid_4095;
+
+	return 0;
+}
+
+static int b53_global_set_4095_enable(struct switch_dev *dev,
+				      const struct switch_attr *attr,
+				      struct switch_val *val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	priv->allow_vid_4095 = val->value.i;
+
+	return 0;
+}
+
+static int b53_global_get_ports(struct switch_dev *dev,
+				const struct switch_attr *attr,
+				struct switch_val *val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	val->len = snprintf(priv->buf, B53_BUF_SIZE, "0x%04x",
+			    priv->enabled_ports);
+	val->value.s = priv->buf;
+
+	return 0;
+}
+
+static int b53_port_get_pvid(struct switch_dev *dev, int port, int *val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	*val = priv->ports[port].pvid;
+
+	return 0;
+}
+
+static int b53_port_set_pvid(struct switch_dev *dev, int port, int val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	if (val > 15 && is5325(priv))
+		return -EINVAL;
+	if (val == 4095 && !priv->allow_vid_4095)
+		return -EINVAL;
+
+	priv->ports[port].pvid = val;
+
+	return 0;
+}
+
+static int b53_vlan_get_ports(struct switch_dev *dev, struct switch_val *val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+	struct switch_port *port = &val->value.ports[0];
+	struct b53_vlan *vlan = &priv->vlans[val->port_vlan];
+	int i;
+
+	val->len = 0;
+
+	if (!vlan->members)
+		return 0;
+
+	for (i = 0; i < dev->ports; i++) {
+		if (!(vlan->members & BIT(i)))
+			continue;
+
+
+		if (!(vlan->untag & BIT(i)))
+			port->flags = BIT(SWITCH_PORT_FLAG_TAGGED);
+		else
+			port->flags = 0;
+
+		port->id = i;
+		val->len++;
+		port++;
+	}
+
+	return 0;
+}
+
+static int b53_vlan_set_ports(struct switch_dev *dev, struct switch_val *val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+	struct switch_port *port;
+	struct b53_vlan *vlan = &priv->vlans[val->port_vlan];
+	int i;
+
+	/* only BCM5325 and BCM5365 supports VID 0 */
+	if (val->port_vlan == 0 && !is5325(priv) && !is5365(priv))
+		return -EINVAL;
+
+	/* VLAN 4095 needs special handling */
+	if (val->port_vlan == 4095 && !priv->allow_vid_4095)
+		return -EINVAL;
+
+	port = &val->value.ports[0];
+	vlan->members = 0;
+	vlan->untag = 0;
+	for (i = 0; i < val->len; i++, port++) {
+		vlan->members |= BIT(port->id);
+
+		if (!(port->flags & BIT(SWITCH_PORT_FLAG_TAGGED))) {
+			vlan->untag |= BIT(port->id);
+			priv->ports[port->id].pvid = val->port_vlan;
+		};
+	}
+
+	/* ignore disabled ports */
+	vlan->members &= priv->enabled_ports;
+	vlan->untag &= priv->enabled_ports;
+
+	return 0;
+}
+
+static int b53_port_get_link(struct switch_dev *dev, int port,
+			     struct switch_port_link *link)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	if (is_cpu_port(priv, port)) {
+		link->link = 1;
+		link->duplex = 1;
+		link->speed = is5325(priv) || is5365(priv) ?
+				SWITCH_PORT_SPEED_100 : SWITCH_PORT_SPEED_1000;
+		link->aneg = 0;
+	} else if (priv->enabled_ports & BIT(port)) {
+		u32 speed;
+		u16 lnk, duplex;
+
+		b53_read16(priv, B53_STAT_PAGE, B53_LINK_STAT, &lnk);
+		b53_read16(priv, B53_STAT_PAGE, priv->duplex_reg, &duplex);
+
+		lnk = (lnk >> port) & 1;
+		duplex = (duplex >> port) & 1;
+
+		if (is5325(priv) || is5365(priv)) {
+			u16 tmp;
+
+			b53_read16(priv, B53_STAT_PAGE, B53_SPEED_STAT, &tmp);
+			speed = SPEED_PORT_FE(tmp, port);
+		} else {
+			b53_read32(priv, B53_STAT_PAGE, B53_SPEED_STAT, &speed);
+			speed = SPEED_PORT_GE(speed, port);
+		}
+
+		link->link = lnk;
+		if (lnk) {
+			link->duplex = duplex;
+			switch (speed) {
+			case SPEED_STAT_10M:
+				link->speed = SWITCH_PORT_SPEED_10;
+				break;
+			case SPEED_STAT_100M:
+				link->speed = SWITCH_PORT_SPEED_100;
+				break;
+			case SPEED_STAT_1000M:
+				link->speed = SWITCH_PORT_SPEED_1000;
+				break;
+			}
+		}
+
+		link->aneg = 1;
+	} else {
+		link->link = 0;
+	}
+
+	return 0;
+
+}
+
+static int b53_global_reset_switch(struct switch_dev *dev)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	/* reset vlans */
+	priv->enable_vlan = 0;
+	priv->enable_jumbo = 0;
+	priv->allow_vid_4095 = 0;
+
+	memset(priv->vlans, 0, sizeof(priv->vlans) * dev->vlans);
+	memset(priv->ports, 0, sizeof(priv->ports) * dev->ports);
+
+	return b53_switch_reset(priv);
+}
+
+static int b53_global_apply_config(struct switch_dev *dev)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+
+	/* disable switching */
+	b53_set_forwarding(priv, 0);
+
+	b53_apply(priv);
+
+	/* enable switching */
+	b53_set_forwarding(priv, 1);
+
+	return 0;
+}
+
+
+static int b53_global_reset_mib(struct switch_dev *dev,
+				const struct switch_attr *attr,
+				struct switch_val *val)
+{
+	struct b53_device *priv = sw_to_b53(dev);
+	u8 gc;
+
+	b53_read8(priv, B53_MGMT_PAGE, B53_GLOBAL_CONFIG, &gc);
+
+	b53_write8(priv, B53_MGMT_PAGE, B53_GLOBAL_CONFIG, gc | GC_RESET_MIB);
+	mdelay(1);
+	b53_write8(priv, B53_MGMT_PAGE, B53_GLOBAL_CONFIG, gc & ~GC_RESET_MIB);
+	mdelay(1);
+
+	return 0;
+}
+
+static int b53_port_get_mib(struct switch_dev *sw_dev,
+			    const struct switch_attr *attr,
+			    struct switch_val *val)
+{
+	struct b53_device *dev = sw_to_b53(sw_dev);
+	const struct b53_mib_desc *mibs;
+	int port = val->port_vlan;
+	int len = 0;
+
+	if (!(BIT(port) & dev->enabled_ports))
+		return -1;
+
+	if (is5365(dev)) {
+		if (port == 5)
+			port = 8;
+
+		mibs = b53_mibs_65;
+	} else if (is63xx(dev)) {
+		mibs = b53_mibs_63xx;
+	} else {
+		mibs = b53_mibs;
+	}
+
+	dev->buf[0] = 0;
+
+	for (; mibs->size > 0; mibs++) {
+		u64 val;
+
+		if (mibs->size == 8) {
+			b53_read64(dev, B53_MIB_PAGE(port), mibs->offset, &val);
+		} else {
+			u32 val32;
+
+			b53_read32(dev, B53_MIB_PAGE(port), mibs->offset,
+				   &val32);
+			val = val32;
+		}
+
+		len += snprintf(dev->buf + len, B53_BUF_SIZE - len,
+				"%-20s: %llu\n", mibs->name, val);
+	}
+
+	val->len = len;
+	val->value.s = dev->buf;
+
+	return 0;
+}
+
+static struct switch_attr b53_global_ops_25[] = {
+	{
+		.type = SWITCH_TYPE_INT,
+		.name = "enable_vlan",
+		.description = "Enable VLAN mode",
+		.set = b53_global_set_vlan_enable,
+		.get = b53_global_get_vlan_enable,
+		.max = 1,
+	},
+	{
+		.type = SWITCH_TYPE_STRING,
+		.name = "ports",
+		.description = "Available ports (as bitmask)",
+		.get = b53_global_get_ports,
+	},
+};
+
+static struct switch_attr b53_global_ops_65[] = {
+	{
+		.type = SWITCH_TYPE_INT,
+		.name = "enable_vlan",
+		.description = "Enable VLAN mode",
+		.set = b53_global_set_vlan_enable,
+		.get = b53_global_get_vlan_enable,
+		.max = 1,
+	},
+	{
+		.type = SWITCH_TYPE_STRING,
+		.name = "ports",
+		.description = "Available ports (as bitmask)",
+		.get = b53_global_get_ports,
+	},
+	{
+		.type = SWITCH_TYPE_INT,
+		.name = "reset_mib",
+		.description = "Reset MIB counters",
+		.set = b53_global_reset_mib,
+	},
+};
+
+static struct switch_attr b53_global_ops[] = {
+	{
+		.type = SWITCH_TYPE_INT,
+		.name = "enable_vlan",
+		.description = "Enable VLAN mode",
+		.set = b53_global_set_vlan_enable,
+		.get = b53_global_get_vlan_enable,
+		.max = 1,
+	},
+	{
+		.type = SWITCH_TYPE_STRING,
+		.name = "ports",
+		.description = "Available Ports (as bitmask)",
+		.get = b53_global_get_ports,
+	},
+	{
+		.type = SWITCH_TYPE_INT,
+		.name = "reset_mib",
+		.description = "Reset MIB counters",
+		.set = b53_global_reset_mib,
+	},
+	{
+		.type = SWITCH_TYPE_INT,
+		.name = "enable_jumbo",
+		.description = "Enable Jumbo Frames",
+		.set = b53_global_set_jumbo_enable,
+		.get = b53_global_get_jumbo_enable,
+		.max = 1,
+	},
+	{
+		.type = SWITCH_TYPE_INT,
+		.name = "allow_vid_4095",
+		.description = "Allow VID 4095",
+		.set = b53_global_set_4095_enable,
+		.get = b53_global_get_4095_enable,
+		.max = 1,
+	},
+};
+
+static struct switch_attr b53_port_ops[] = {
+	{
+		.type = SWITCH_TYPE_STRING,
+		.name = "mib",
+		.description = "Get port's MIB counters",
+		.get = b53_port_get_mib,
+	},
+};
+
+static struct switch_attr b53_no_ops[] = {
+};
+
+static const struct switch_dev_ops b53_switch_ops_25 = {
+	.attr_global = {
+		.attr = b53_global_ops_25,
+		.n_attr = ARRAY_SIZE(b53_global_ops_25),
+	},
+	.attr_port = {
+		.attr = b53_no_ops,
+		.n_attr = ARRAY_SIZE(b53_no_ops),
+	},
+	.attr_vlan = {
+		.attr = b53_no_ops,
+		.n_attr = ARRAY_SIZE(b53_no_ops),
+	},
+
+	.get_vlan_ports = b53_vlan_get_ports,
+	.set_vlan_ports = b53_vlan_set_ports,
+	.get_port_pvid = b53_port_get_pvid,
+	.set_port_pvid = b53_port_set_pvid,
+	.apply_config = b53_global_apply_config,
+	.reset_switch = b53_global_reset_switch,
+	.get_port_link = b53_port_get_link,
+};
+
+static const struct switch_dev_ops b53_switch_ops_65 = {
+	.attr_global = {
+		.attr = b53_global_ops_65,
+		.n_attr = ARRAY_SIZE(b53_global_ops_65),
+	},
+	.attr_port = {
+		.attr = b53_port_ops,
+		.n_attr = ARRAY_SIZE(b53_port_ops),
+	},
+	.attr_vlan = {
+		.attr = b53_no_ops,
+		.n_attr = ARRAY_SIZE(b53_no_ops),
+	},
+
+	.get_vlan_ports = b53_vlan_get_ports,
+	.set_vlan_ports = b53_vlan_set_ports,
+	.get_port_pvid = b53_port_get_pvid,
+	.set_port_pvid = b53_port_set_pvid,
+	.apply_config = b53_global_apply_config,
+	.reset_switch = b53_global_reset_switch,
+	.get_port_link = b53_port_get_link,
+};
+
+static const struct switch_dev_ops b53_switch_ops = {
+	.attr_global = {
+		.attr = b53_global_ops,
+		.n_attr = ARRAY_SIZE(b53_global_ops),
+	},
+	.attr_port = {
+		.attr = b53_port_ops,
+		.n_attr = ARRAY_SIZE(b53_port_ops),
+	},
+	.attr_vlan = {
+		.attr = b53_no_ops,
+		.n_attr = ARRAY_SIZE(b53_no_ops),
+	},
+
+	.get_vlan_ports = b53_vlan_get_ports,
+	.set_vlan_ports = b53_vlan_set_ports,
+	.get_port_pvid = b53_port_get_pvid,
+	.set_port_pvid = b53_port_set_pvid,
+	.apply_config = b53_global_apply_config,
+	.reset_switch = b53_global_reset_switch,
+	.get_port_link = b53_port_get_link,
+};
+
+struct b53_chip_data {
+	u32 chip_id;
+	const char *dev_name;
+	const char *alias;
+	u16 vlans;
+	u16 enabled_ports;
+	u8 cpu_port;
+	u8 vta_regs[3];
+	u8 duplex_reg;
+	u8 jumbo_pm_reg;
+	u8 jumbo_size_reg;
+	const struct switch_dev_ops *sw_ops;
+};
+
+#define B53_VTA_REGS	\
+	{ B53_VT_ACCESS, B53_VT_INDEX, B53_VT_ENTRY }
+#define B53_VTA_REGS_9798 \
+	{ B53_VT_ACCESS_9798, B53_VT_INDEX_9798, B53_VT_ENTRY_9798 }
+#define B53_VTA_REGS_63XX \
+	{ B53_VT_ACCESS_63XX, B53_VT_INDEX_63XX, B53_VT_ENTRY_63XX }
+
+static const struct b53_chip_data b53_switch_chips[] = {
+	{
+		.chip_id = BCM5325_DEVICE_ID,
+		.dev_name = "BCM5325",
+		.alias = "bcm5325",
+		.vlans = 16,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT_25,
+		.duplex_reg = B53_DUPLEX_STAT_FE,
+		.sw_ops = &b53_switch_ops_25,
+	},
+	{
+		.chip_id = BCM5365_DEVICE_ID,
+		.dev_name = "BCM5365",
+		.alias = "bcm5365",
+		.vlans = 256,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT_25,
+		.duplex_reg = B53_DUPLEX_STAT_FE,
+		.sw_ops = &b53_switch_ops_65,
+	},
+	{
+		.chip_id = BCM5395_DEVICE_ID,
+		.dev_name = "BCM5395",
+		.alias = "bcm5395",
+		.vlans = 4096,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.sw_ops = &b53_switch_ops,
+	},
+	{
+		.chip_id = BCM5397_DEVICE_ID,
+		.dev_name = "BCM5397",
+		.alias = "bcm5397",
+		.vlans = 4096,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS_9798,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.sw_ops = &b53_switch_ops,
+	},
+	{
+		.chip_id = BCM5398_DEVICE_ID,
+		.dev_name = "BCM5398",
+		.alias = "bcm5398",
+		.vlans = 4096,
+		.enabled_ports = 0x7f,
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS_9798,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.sw_ops = &b53_switch_ops,
+	},
+	{
+		.chip_id = BCM53115_DEVICE_ID,
+		.dev_name = "BCM53115",
+		.alias = "bcm53115",
+		.vlans = 4096,
+		.enabled_ports = 0x1f,
+		.vta_regs = B53_VTA_REGS,
+		.cpu_port = B53_CPU_PORT,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.sw_ops = &b53_switch_ops,
+	},
+	{
+		.chip_id = BCM53125_DEVICE_ID,
+		.dev_name = "BCM53125",
+		.alias = "bcm53125",
+		.vlans = 4096,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+		.sw_ops = &b53_switch_ops,
+	},
+	{
+		.chip_id = BCM63XX_DEVICE_ID,
+		.dev_name = "BCM63xx",
+		.alias = "bcm63xx",
+		.vlans = 4096,
+		.enabled_ports = 0, /* pdata must provide them */
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS_63XX,
+		.duplex_reg = B53_DUPLEX_STAT_63XX,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK_63XX,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE_63XX,
+		.sw_ops = &b53_switch_ops,
+	},
+};
+
+int b53_switch_init(struct b53_device *dev)
+{
+	struct switch_dev *sw_dev = &dev->sw_dev;
+	unsigned i;
+	int ret;
+
+	for (i = 0; i < ARRAY_SIZE(b53_switch_chips); i++) {
+		const struct b53_chip_data *chip = &b53_switch_chips[i];
+
+		if (chip->chip_id == dev->chip_id) {
+			sw_dev->name = chip->dev_name;
+			if (!sw_dev->alias)
+				sw_dev->alias = chip->alias;
+			if (!dev->enabled_ports)
+				dev->enabled_ports = chip->enabled_ports;
+			dev->duplex_reg = chip->duplex_reg;
+			dev->vta_regs[0] = chip->vta_regs[0];
+			dev->vta_regs[1] = chip->vta_regs[1];
+			dev->vta_regs[2] = chip->vta_regs[2];
+			dev->jumbo_pm_reg = chip->jumbo_pm_reg;
+			sw_dev->ops = chip->sw_ops;
+			sw_dev->cpu_port = chip->cpu_port;
+			sw_dev->vlans = chip->vlans;
+			break;
+		}
+	}
+
+	if (!sw_dev->name)
+		return -EINVAL;
+
+	/* check which BCM5325x version we have */
+	if (is5325(dev)) {
+		u8 vc4;
+
+		b53_read8(dev, B53_VLAN_PAGE, B53_VLAN_CTRL4_25, &vc4);
+
+		/* check reserved bits */
+		switch (vc4 & 3) {
+		case 1:
+			/* BCM5325E */
+			break;
+		case 3:
+			/* BCM5325F - do not use port 4 */
+			dev->enabled_ports &= ~BIT(4);
+			break;
+		default:
+			break;
+		}
+	} else if (dev->chip_id == BCM53115_DEVICE_ID) {
+		u64 strap_value;
+
+		b53_read48(dev, B53_STAT_PAGE, B53_STRAP_VALUE, &strap_value);
+		/* use second IMP port if GMII is enabled */
+		if (strap_value & SV_GMII_CTRL_115)
+			sw_dev->cpu_port = 5;
+	}
+
+	/* cpu port is always last */
+	sw_dev->ports = sw_dev->cpu_port + 1;
+	dev->enabled_ports |= BIT(sw_dev->cpu_port);
+
+	dev->ports = devm_kzalloc(dev->dev,
+				  sizeof(struct b53_port) * sw_dev->ports,
+				  GFP_KERNEL);
+	if (!dev->ports)
+		return -ENOMEM;
+
+	dev->vlans = devm_kzalloc(dev->dev,
+				  sizeof(struct b53_vlan) * sw_dev->vlans,
+				  GFP_KERNEL);
+	if (!dev->vlans)
+		return -ENOMEM;
+
+	dev->buf = devm_kzalloc(dev->dev, B53_BUF_SIZE, GFP_KERNEL);
+	if (!dev->buf)
+		return -ENOMEM;
+
+	dev->reset_gpio = b53_switch_get_reset_gpio(dev);
+	if (dev->reset_gpio >= 0) {
+		ret = devm_gpio_request_one(dev->dev, dev->reset_gpio, GPIOF_OUT_INIT_HIGH, "robo_reset");
+		if (ret)
+			return ret;
+	}
+
+	return b53_switch_reset(dev);
+}
+
+struct b53_device *b53_switch_alloc(struct device *base, struct b53_io_ops *ops,
+				    void *priv)
+{
+	struct b53_device *dev;
+
+	dev = devm_kzalloc(base, sizeof(*dev), GFP_KERNEL);
+	if (!dev)
+		return NULL;
+
+	dev->dev = base;
+	dev->ops = ops;
+	dev->priv = priv;
+	mutex_init(&dev->reg_mutex);
+
+	return dev;
+}
+EXPORT_SYMBOL(b53_switch_alloc);
+
+int b53_switch_detect(struct b53_device *dev)
+{
+	u32 id32;
+	u16 tmp;
+	u8 id8;
+	int ret;
+
+	ret = b53_read8(dev, B53_MGMT_PAGE, B53_DEVICE_ID, &id8);
+	if (ret)
+		return ret;
+
+	switch (id8) {
+	case 0:
+		/*
+		 * BCM5325 and BCM5365 do not have this register so reads
+		 * return 0. But the read operation did succeed, so assume
+		 * this is one of them.
+		 *
+		 * Next check if we can write to the 5325's VTA register; for
+		 * 5365 it is read only.
+		 */
+
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_TABLE_ACCESS_25, 0xf);
+		b53_read16(dev, B53_VLAN_PAGE, B53_VLAN_TABLE_ACCESS_25, &tmp);
+
+		if (tmp == 0xf)
+			dev->chip_id = BCM5325_DEVICE_ID;
+		else
+			dev->chip_id = BCM5365_DEVICE_ID;
+		break;
+	case BCM5395_DEVICE_ID:
+	case BCM5397_DEVICE_ID:
+	case BCM5398_DEVICE_ID:
+		dev->chip_id = id8;
+		break;
+	default:
+		ret = b53_read32(dev, B53_MGMT_PAGE, B53_DEVICE_ID, &id32);
+		if (ret)
+			return ret;
+
+		switch (id32) {
+		case BCM53115_DEVICE_ID:
+		case BCM53125_DEVICE_ID:
+			dev->chip_id = id32;
+			break;
+		default:
+			pr_err("unsupported switch detected (BCM53%02x/BCM%x)\n",
+			       id8, id32);
+			return -ENODEV;
+		}
+	}
+
+	if (dev->chip_id == BCM5325_DEVICE_ID)
+		return b53_read8(dev, B53_STAT_PAGE, B53_REV_ID_25,
+				 &dev->core_rev);
+	else
+		return b53_read8(dev, B53_MGMT_PAGE, B53_REV_ID,
+				 &dev->core_rev);
+}
+EXPORT_SYMBOL(b53_switch_detect);
+
+int b53_switch_register(struct b53_device *dev)
+{
+	int ret;
+
+	if (dev->pdata) {
+		dev->chip_id = dev->pdata->chip_id;
+		dev->enabled_ports = dev->pdata->enabled_ports;
+		dev->sw_dev.alias = dev->pdata->alias;
+	}
+
+	if (!dev->chip_id && b53_switch_detect(dev))
+		return -EINVAL;
+
+	ret = b53_switch_init(dev);
+	if (ret)
+		return ret;
+
+	pr_info("found switch: %s, rev %i\n", dev->sw_dev.name, dev->core_rev);
+
+	return register_switch(&dev->sw_dev, NULL);
+}
+EXPORT_SYMBOL(b53_switch_register);
+
+MODULE_AUTHOR("Jonas Gorski <jogo@openwrt.org>");
+MODULE_DESCRIPTION("B53 switch library");
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/phy/b53/b53_mdio.c b/drivers/net/phy/b53/b53_mdio.c
new file mode 100644
index 0000000..6403cc6
--- /dev/null
+++ b/drivers/net/phy/b53/b53_mdio.c
@@ -0,0 +1,425 @@
+/*
+ * B53 register access through MII registers
+ *
+ * Copyright (C) 2011-2013 Jonas Gorski <jogo@openwrt.org>
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include <linux/kernel.h>
+#include <linux/phy.h>
+#include <linux/module.h>
+
+#include "b53_priv.h"
+
+#define B53_PSEUDO_PHY	0x1e /* Register Access Pseudo PHY */
+
+/* MII registers */
+#define REG_MII_PAGE    0x10    /* MII Page register */
+#define REG_MII_ADDR    0x11    /* MII Address register */
+#define REG_MII_DATA0   0x18    /* MII Data register 0 */
+#define REG_MII_DATA1   0x19    /* MII Data register 1 */
+#define REG_MII_DATA2   0x1a    /* MII Data register 2 */
+#define REG_MII_DATA3   0x1b    /* MII Data register 3 */
+
+#define REG_MII_PAGE_ENABLE     BIT(0)
+#define REG_MII_ADDR_WRITE      BIT(0)
+#define REG_MII_ADDR_READ       BIT(1)
+
+static int b53_mdio_op(struct b53_device *dev, u8 page, u8 reg, u16 op)
+{
+	int i;
+	u16 v;
+	int ret;
+	struct mii_bus *bus = dev->priv;
+
+	if (dev->current_page != page) {
+		/* set page number */
+		v = (page << 8) | REG_MII_PAGE_ENABLE;
+		ret = mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_PAGE, v);
+		if (ret)
+			return ret;
+		dev->current_page = page;
+	}
+
+	/* set register address */
+	v = (reg << 8) | op;
+	ret = mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_ADDR, v);
+	if (ret)
+		return ret;
+
+	/* check if operation completed */
+	for (i = 0; i < 5; ++i) {
+		v = mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_ADDR);
+		if (!(v & (REG_MII_ADDR_WRITE | REG_MII_ADDR_READ)))
+			break;
+		usleep_range(10, 100);
+	}
+
+	if (WARN_ON(i == 5))
+		return -EIO;
+
+	return 0;
+}
+
+static int b53_mdio_read8(struct b53_device *dev, u8 page, u8 reg, u8 *val)
+{
+	struct mii_bus *bus = dev->priv;
+	int ret;
+
+	ret = b53_mdio_op(dev, page, reg, REG_MII_ADDR_READ);
+	if (ret)
+		return ret;
+
+	*val = mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA0) & 0xff;
+
+	return 0;
+}
+
+static int b53_mdio_read16(struct b53_device *dev, u8 page, u8 reg, u16 *val)
+{
+	struct mii_bus *bus = dev->priv;
+	int ret;
+
+	ret = b53_mdio_op(dev, page, reg, REG_MII_ADDR_READ);
+	if (ret)
+		return ret;
+
+	*val = mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA0);
+
+	return 0;
+}
+
+static int b53_mdio_read32(struct b53_device *dev, u8 page, u8 reg, u32 *val)
+{
+	struct mii_bus *bus = dev->priv;
+	int ret;
+
+	ret = b53_mdio_op(dev, page, reg, REG_MII_ADDR_READ);
+	if (ret)
+		return ret;
+
+	*val = mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA0);
+	*val |= mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA1) << 16;
+
+	return 0;
+}
+
+static int b53_mdio_read48(struct b53_device *dev, u8 page, u8 reg, u64 *val)
+{
+	struct mii_bus *bus = dev->priv;
+	u64 temp = 0;
+	int i;
+	int ret;
+
+	ret = b53_mdio_op(dev, page, reg, REG_MII_ADDR_READ);
+	if (ret)
+		return ret;
+
+	for (i = 2; i >= 0; i--) {
+		temp <<= 16;
+		temp |= mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA0 + i);
+	}
+
+	*val = temp;
+
+	return 0;
+}
+
+static int b53_mdio_read64(struct b53_device *dev, u8 page, u8 reg, u64 *val)
+{
+	struct mii_bus *bus = dev->priv;
+	u64 temp = 0;
+	int i;
+	int ret;
+
+	ret = b53_mdio_op(dev, page, reg, REG_MII_ADDR_READ);
+	if (ret)
+		return ret;
+
+	for (i = 3; i >= 0; i--) {
+		temp <<= 16;
+		temp |= mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA0 + i);
+	}
+
+	*val = temp;
+
+	return 0;
+}
+
+static int b53_mdio_write8(struct b53_device *dev, u8 page, u8 reg, u8 value)
+{
+	struct mii_bus *bus = dev->priv;
+	int ret;
+
+	ret = mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_DATA0, value);
+	if (ret)
+		return ret;
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static int b53_mdio_write16(struct b53_device *dev, u8 page, u8 reg,
+			     u16 value)
+{
+	struct mii_bus *bus = dev->priv;
+	int ret;
+
+	ret = mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_DATA0, value);
+	if (ret)
+		return ret;
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static int b53_mdio_write32(struct b53_device *dev, u8 page, u8 reg,
+				    u32 value)
+{
+	struct mii_bus *bus = dev->priv;
+	unsigned int i;
+	u32 temp = value;
+
+	for (i = 0; i < 2; i++) {
+		int ret = mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_DATA0 + i,
+				    temp & 0xffff);
+		if (ret)
+			return ret;
+		temp >>= 16;
+	}
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+
+}
+
+static int b53_mdio_write48(struct b53_device *dev, u8 page, u8 reg,
+				    u64 value)
+{
+	struct mii_bus *bus = dev->priv;
+	unsigned i;
+	u64 temp = value;
+
+	for (i = 0; i < 3; i++) {
+		int ret = mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_DATA0 + i,
+				    temp & 0xffff);
+		if (ret)
+			return ret;
+		temp >>= 16;
+	}
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+
+}
+
+static int b53_mdio_write64(struct b53_device *dev, u8 page, u8 reg,
+			     u64 value)
+{
+	struct mii_bus *bus = dev->priv;
+	unsigned i;
+	u64 temp = value;
+
+	for (i = 0; i < 4; i++) {
+		int ret = mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_DATA0 + i,
+				    temp & 0xffff);
+		if (ret)
+			return ret;
+		temp >>= 16;
+	}
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static struct b53_io_ops b53_mdio_ops = {
+	.read8 = b53_mdio_read8,
+	.read16 = b53_mdio_read16,
+	.read32 = b53_mdio_read32,
+	.read48 = b53_mdio_read48,
+	.read64 = b53_mdio_read64,
+	.write8 = b53_mdio_write8,
+	.write16 = b53_mdio_write16,
+	.write32 = b53_mdio_write32,
+	.write48 = b53_mdio_write48,
+	.write64 = b53_mdio_write64,
+};
+
+static int b53_phy_probe(struct phy_device *phydev)
+{
+	struct b53_device dev;
+	int ret;
+
+	/* allow the generic phy driver to take over */
+	if (phydev->addr != B53_PSEUDO_PHY && phydev->addr != 0)
+		return -ENODEV;
+
+	dev.current_page = 0xff;
+	dev.priv = phydev->bus;
+	dev.ops = &b53_mdio_ops;
+	dev.pdata = NULL;
+	mutex_init(&dev.reg_mutex);
+
+	ret = b53_switch_detect(&dev);
+	if (ret)
+		return ret;
+
+	if (is5325(&dev) || is5365(&dev))
+		phydev->supported = SUPPORTED_100baseT_Full;
+	else
+		phydev->supported = SUPPORTED_1000baseT_Full;
+
+	phydev->advertising = phydev->supported;
+
+	return 0;
+}
+
+static int b53_phy_config_init(struct phy_device *phydev)
+{
+	struct b53_device *dev;
+	int ret;
+
+	dev = b53_switch_alloc(&phydev->dev, &b53_mdio_ops, phydev->bus);
+	if (!dev)
+		return -ENOMEM;
+
+	/* we don't use page 0xff, so force a page set */
+	dev->current_page = 0xff;
+	/* force the ethX as alias */
+	dev->sw_dev.alias = phydev->attached_dev->name;
+
+	ret = b53_switch_register(dev);
+	if (ret) {
+		pr_info("failed to register switch: %i\n", ret);
+		return ret;
+	}
+
+	phydev->priv = dev;
+
+	return 0;
+}
+
+static void b53_phy_remove(struct phy_device *phydev)
+{
+	struct b53_device *priv = phydev->priv;
+
+	if (!priv)
+		return;
+
+	b53_switch_remove(priv);
+
+	phydev->priv = NULL;
+}
+
+static int b53_phy_config_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static int b53_phy_read_status(struct phy_device *phydev)
+{
+	struct b53_device *priv = phydev->priv;
+
+	if (is5325(priv) || is5365(priv))
+		phydev->speed = 100;
+	else
+		phydev->speed = 1000;
+
+	phydev->duplex = DUPLEX_FULL;
+	phydev->link = 1;
+	phydev->state = PHY_RUNNING;
+
+	netif_carrier_on(phydev->attached_dev);
+	phydev->adjust_link(phydev->attached_dev);
+
+	return 0;
+}
+
+/* BCM5325, BCM539x */
+static struct phy_driver b53_phy_driver_id1 = {
+	.phy_id		= 0x0143bc00,
+	.name		= "Broadcom B53 (1)",
+	.phy_id_mask	= 0x1ffffc00,
+	.features	= 0,
+	.probe		= b53_phy_probe,
+	.remove		= b53_phy_remove,
+	.config_aneg	= b53_phy_config_aneg,
+	.config_init	= b53_phy_config_init,
+	.read_status	= b53_phy_read_status,
+	.driver = {
+		.owner = THIS_MODULE,
+	},
+};
+
+/* BCM53125 */
+static struct phy_driver b53_phy_driver_id2 = {
+	.phy_id		= 0x03625c00,
+	.name		= "Broadcom B53 (2)",
+	.phy_id_mask	= 0x1ffffc00,
+	.features	= 0,
+	.probe		= b53_phy_probe,
+	.remove		= b53_phy_remove,
+	.config_aneg	= b53_phy_config_aneg,
+	.config_init	= b53_phy_config_init,
+	.read_status	= b53_phy_read_status,
+	.driver = {
+		.owner = THIS_MODULE,
+	},
+};
+
+/* BCM5365 */
+static struct phy_driver b53_phy_driver_id3 = {
+	.phy_id		= 0x00406000,
+	.name		= "Broadcom B53 (3)",
+	.phy_id_mask	= 0x1ffffc00,
+	.features	= 0,
+	.probe		= b53_phy_probe,
+	.remove		= b53_phy_remove,
+	.config_aneg	= b53_phy_config_aneg,
+	.config_init	= b53_phy_config_init,
+	.read_status	= b53_phy_read_status,
+	.driver = {
+		.owner = THIS_MODULE,
+	},
+};
+
+int __init b53_phy_driver_register(void)
+{
+	int ret;
+
+	ret = phy_driver_register(&b53_phy_driver_id1);
+	if (ret)
+		return ret;
+
+	ret = phy_driver_register(&b53_phy_driver_id2);
+	if (ret)
+		goto err1;
+
+	ret = phy_driver_register(&b53_phy_driver_id3);
+	if (!ret)
+		return 0;
+
+	phy_driver_unregister(&b53_phy_driver_id2);
+err1:
+	phy_driver_unregister(&b53_phy_driver_id1);
+	return ret;
+}
+
+void __exit b53_phy_driver_unregister(void)
+{
+	phy_driver_unregister(&b53_phy_driver_id3);
+	phy_driver_unregister(&b53_phy_driver_id2);
+	phy_driver_unregister(&b53_phy_driver_id1);
+}
+
+module_init(b53_phy_driver_register);
+module_exit(b53_phy_driver_unregister);
+
+MODULE_DESCRIPTION("B53 MDIO access driver");
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/phy/b53/b53_phy_fixup.c b/drivers/net/phy/b53/b53_phy_fixup.c
new file mode 100644
index 0000000..72d1373
--- /dev/null
+++ b/drivers/net/phy/b53/b53_phy_fixup.c
@@ -0,0 +1,55 @@
+/*
+ * B53 PHY Fixup call
+ *
+ * Copyright (C) 2013 Jonas Gorski <jogo@openwrt.org>
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/phy.h>
+
+#define B53_PSEUDO_PHY	0x1e /* Register Access Pseudo PHY */
+
+#define B53_BRCM_OUI_1	0x0143bc00
+#define B53_BRCM_OUI_2	0x03625c00
+#define B53_BRCM_OUI_3	0x00406000
+
+static int b53_phy_fixup(struct phy_device *dev)
+{
+	u32 phy_id;
+	struct mii_bus *bus = dev->bus;
+
+	if (dev->addr != B53_PSEUDO_PHY)
+		return 0;
+
+	/* read the first port's id */
+	phy_id = mdiobus_read(bus, 0, 2) << 16;
+	phy_id |= mdiobus_read(bus, 0, 3);
+
+	if ((phy_id & 0xfffffc00) == B53_BRCM_OUI_1 ||
+	    (phy_id & 0xfffffc00) == B53_BRCM_OUI_2 ||
+	    (phy_id & 0xfffffc00) == B53_BRCM_OUI_3) {
+		dev->phy_id = phy_id;
+	}
+
+	return 0;
+}
+
+int __init b53_phy_fixup_register(void)
+{
+	return phy_register_fixup_for_id(PHY_ANY_ID, b53_phy_fixup);
+}
+
+subsys_initcall(b53_phy_fixup_register);
diff --git a/drivers/net/phy/b53/b53_priv.h b/drivers/net/phy/b53/b53_priv.h
new file mode 100644
index 0000000..94eaa89
--- /dev/null
+++ b/drivers/net/phy/b53/b53_priv.h
@@ -0,0 +1,282 @@
+/*
+ * B53 common definitions
+ *
+ * Copyright (C) 2011-2013 Jonas Gorski <jogo@openwrt.org>
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef __B53_PRIV_H
+#define __B53_PRIV_H
+
+#include <linux/kernel.h>
+#include <linux/mutex.h>
+#include <linux/swconfig.h>
+
+struct b53_device;
+
+struct b53_io_ops {
+	int (*read8)(struct b53_device *dev, u8 page, u8 reg, u8 *value);
+	int (*read16)(struct b53_device *dev, u8 page, u8 reg, u16 *value);
+	int (*read32)(struct b53_device *dev, u8 page, u8 reg, u32 *value);
+	int (*read48)(struct b53_device *dev, u8 page, u8 reg, u64 *value);
+	int (*read64)(struct b53_device *dev, u8 page, u8 reg, u64 *value);
+	int (*write8)(struct b53_device *dev, u8 page, u8 reg, u8 value);
+	int (*write16)(struct b53_device *dev, u8 page, u8 reg, u16 value);
+	int (*write32)(struct b53_device *dev, u8 page, u8 reg, u32 value);
+	int (*write48)(struct b53_device *dev, u8 page, u8 reg, u64 value);
+	int (*write64)(struct b53_device *dev, u8 page, u8 reg, u64 value);
+};
+
+enum {
+	BCM5325_DEVICE_ID = 0x25,
+	BCM5365_DEVICE_ID = 0x65,
+	BCM5395_DEVICE_ID = 0x95,
+	BCM5397_DEVICE_ID = 0x97,
+	BCM5398_DEVICE_ID = 0x98,
+	BCM53115_DEVICE_ID = 0x53115,
+	BCM53125_DEVICE_ID = 0x53125,
+	BCM63XX_DEVICE_ID = 0x6300,
+};
+
+#define B53_N_PORTS	9
+#define B53_N_PORTS_25	6
+
+struct b53_vlan {
+	unsigned int	members:B53_N_PORTS;
+	unsigned int	untag:B53_N_PORTS;
+};
+
+struct b53_port {
+	unsigned int	pvid:12;
+};
+
+struct b53_device {
+	struct switch_dev sw_dev;
+	struct b53_platform_data *pdata;
+
+	struct mutex reg_mutex;
+	const struct b53_io_ops *ops;
+
+	/* chip specific data */
+	u32 chip_id;
+	u8 core_rev;
+	u8 vta_regs[3];
+	u8 duplex_reg;
+	u8 jumbo_pm_reg;
+	u8 jumbo_size_reg;
+	int reset_gpio;
+
+	/* used ports mask */
+	u16 enabled_ports;
+
+	/* connect specific data */
+	u8 current_page;
+	struct device *dev;
+	void *priv;
+
+	/* run time configuration */
+	unsigned enable_vlan:1;
+	unsigned enable_jumbo:1;
+	unsigned allow_vid_4095:1;
+
+	struct b53_port *ports;
+	struct b53_vlan *vlans;
+
+	char *buf;
+};
+
+#define b53_for_each_port(dev, i) \
+	for (i = 0; i < B53_N_PORTS; i++) \
+		if (dev->enabled_ports & BIT(i))
+
+
+
+static inline int is5325(struct b53_device *dev)
+{
+	return dev->chip_id == BCM5325_DEVICE_ID;
+}
+
+static inline int is5365(struct b53_device *dev)
+{
+	return 0;
+}
+
+static inline int is5397_98(struct b53_device *dev)
+{
+	return dev->chip_id == BCM5397_DEVICE_ID ||
+		dev->chip_id == BCM5398_DEVICE_ID;
+}
+
+static inline int is539x(struct b53_device *dev)
+{
+	return dev->chip_id == BCM5395_DEVICE_ID ||
+		dev->chip_id == BCM5397_DEVICE_ID ||
+		dev->chip_id == BCM5398_DEVICE_ID;
+}
+
+static inline int is531x5(struct b53_device *dev)
+{
+	return dev->chip_id == BCM53115_DEVICE_ID ||
+		dev->chip_id == BCM53125_DEVICE_ID;
+}
+
+static inline int is63xx(struct b53_device *dev)
+{
+	return 0;
+}
+
+#define B53_CPU_PORT_25	5
+#define B53_CPU_PORT	8
+
+static inline int is_cpu_port(struct b53_device *dev, int port)
+{
+	return dev->sw_dev.cpu_port == port;
+}
+
+static inline struct b53_device *sw_to_b53(struct switch_dev *sw)
+{
+	return container_of(sw, struct b53_device, sw_dev);
+}
+
+struct b53_device *b53_switch_alloc(struct device *base, struct b53_io_ops *ops,
+				    void *priv);
+
+int b53_switch_detect(struct b53_device *dev);
+
+int b53_switch_register(struct b53_device *dev);
+
+static inline void b53_switch_remove(struct b53_device *dev)
+{
+	unregister_switch(&dev->sw_dev);
+}
+
+static inline int b53_read8(struct b53_device *dev, u8 page, u8 reg, u8 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read8(dev, page, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_read16(struct b53_device *dev, u8 page, u8 reg, u16 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read16(dev, page, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_read32(struct b53_device *dev, u8 page, u8 reg, u32 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read32(dev, page, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_read48(struct b53_device *dev, u8 page, u8 reg, u64 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read48(dev, page, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_read64(struct b53_device *dev, u8 page, u8 reg, u64 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read64(dev, page, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_write8(struct b53_device *dev, u8 page, u8 reg, u8 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write8(dev, page, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_write16(struct b53_device *dev, u8 page, u8 reg,
+			      u16 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write16(dev, page, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_write32(struct b53_device *dev, u8 page, u8 reg,
+			      u32 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write32(dev, page, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_write48(struct b53_device *dev, u8 page, u8 reg,
+			      u64 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write48(dev, page, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_write64(struct b53_device *dev, u8 page, u8 reg,
+			       u64 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write64(dev, page, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_switch_get_reset_gpio(struct b53_device *dev)
+{
+	return -ENOENT;
+}
+#endif
diff --git a/drivers/net/phy/b53/b53_regs.h b/drivers/net/phy/b53/b53_regs.h
new file mode 100644
index 0000000..7018ff4
--- /dev/null
+++ b/drivers/net/phy/b53/b53_regs.h
@@ -0,0 +1,311 @@
+/*
+ * B53 register definitions
+ *
+ * Copyright (C) 2004 Broadcom Corporation
+ * Copyright (C) 2011-2013 Jonas Gorski <jogo@openwrt.org>
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef __B53_REGS_H
+#define __B53_REGS_H
+
+/* Management Port (SMP) Page offsets */
+#define B53_CTRL_PAGE			0x00 /* Control */
+#define B53_STAT_PAGE			0x01 /* Status */
+#define B53_MGMT_PAGE			0x02 /* Management Mode */
+#define B53_MIB_AC_PAGE			0x03 /* MIB Autocast */
+#define B53_ARLCTRL_PAGE		0x04 /* ARL Control */
+#define B53_ARLIO_PAGE			0x05 /* ARL Access */
+#define B53_FRAMEBUF_PAGE		0x06 /* Management frame access */
+#define B53_MEM_ACCESS_PAGE		0x08 /* Memory access */
+
+/* PHY Registers */
+#define B53_PORT_MII_PAGE(i)		(0x10 + i) /* Port i MII Registers */
+#define B53_IM_PORT_PAGE		0x18 /* Inverse MII Port (to EMAC) */
+#define B53_ALL_PORT_PAGE		0x19 /* All ports MII (broadcast) */
+
+/* MIB registers */
+#define B53_MIB_PAGE(i)			(0x20 + i)
+
+/* Quality of Service (QoS) Registers */
+#define B53_QOS_PAGE			0x30
+
+/* Port VLAN Page */
+#define B53_PVLAN_PAGE			0x31
+
+/* VLAN Registers */
+#define B53_VLAN_PAGE			0x34
+
+/* Jumbo Frame Registers */
+#define B53_JUMBO_PAGE			0x40
+
+/*************************************************************************
+ * Control Page registers
+ *************************************************************************/
+
+/* Port Control Register (8 bit) */
+#define B53_PORT_CTRL(i)		(0x00 + i)
+#define   PORT_CTRL_RX_DISABLE		BIT(0)
+#define   PORT_CTRL_TX_DISABLE		BIT(1)
+#define   PORT_CTRL_RX_BCST_EN		BIT(2) /* Broadcast RX (P8 only) */
+#define   PORT_CTRL_RX_MCST_EN		BIT(3) /* Multicast RX (P8 only) */
+#define   PORT_CTRL_RX_UCST_EN		BIT(4) /* Unicast RX (P8 only) */
+#define	  PORT_CTRL_STP_STATE_S		5
+#define   PORT_CTRL_STP_STATE_MASK	(0x3 << PORT_CTRL_STP_STATE_S)
+
+/* SMP Control Register (8 bit) */
+#define B53_SMP_CTRL			0x0a
+
+/* Switch Mode Control Register (8 bit) */
+#define B53_SWITCH_MODE			0x0b
+#define   SM_SW_FWD_MODE		BIT(0)	/* 1 = Managed Mode */
+#define   SM_SW_FWD_EN			BIT(1)	/* Forwarding Enable */
+
+/* IMP Port state override register (8 bit) */
+#define B53_PORT_OVERRIDE_CTRL		0x0e
+#define   PORT_OVERRIDE_LINK		BIT(0)
+#define   PORT_OVERRIDE_HALF_DUPLEX	BIT(1) /* 0 = Full Duplex */
+#define   PORT_OVERRIDE_SPEED_S		2
+#define   PORT_OVERRIDE_SPEED_10M	(0 << PORT_OVERRIDE_SPEED_S)
+#define   PORT_OVERRIDE_SPEED_100M	(1 << PORT_OVERRIDE_SPEED_S)
+#define   PORT_OVERRIDE_SPEED_1000M	(2 << PORT_OVERRIDE_SPEED_S)
+#define   PORT_OVERRIDE_RV_MII_25	BIT(4) /* BCM5325 only */
+#define   PORT_OVERRIDE_RX_FLOW		BIT(4)
+#define   PORT_OVERRIDE_TX_FLOW		BIT(5)
+#define   PORT_OVERRIDE_EN		BIT(7) /* Use the register contents */
+
+/* Power-down mode control */
+#define B53_PD_MODE_CTRL_25		0x0f
+
+/* IP Multicast control (8 bit) */
+#define B53_IP_MULTICAST_CTRL		0x21
+#define  B53_IPMC_FWD_EN		BIT(1)
+#define  B53_UC_FWD_EN			BIT(6)
+#define  B53_MC_FWD_EN			BIT(7)
+
+/* (16 bit) */
+#define B53_UC_FLOOD_MASK		0x32
+#define B53_MC_FLOOD_MASK		0x34
+#define B53_IPMC_FLOOD_MASK		0x36
+
+/* Software reset register (8 bit) */
+#define B53_SOFTRESET			0x79
+
+/* Fast Aging Control register (8 bit) */
+#define B53_FAST_AGE_CTRL		0x88
+#define   FAST_AGE_STATIC		BIT(0)
+#define   FAST_AGE_DYNAMIC		BIT(1)
+#define   FAST_AGE_PORT			BIT(2)
+#define   FAST_AGE_VLAN			BIT(3)
+#define   FAST_AGE_STP			BIT(4)
+#define   FAST_AGE_MC			BIT(5)
+#define   FAST_AGE_DONE			BIT(7)
+
+/*************************************************************************
+ * Status Page registers
+ *************************************************************************/
+
+/* Link Status Summary Register (16bit) */
+#define B53_LINK_STAT			0x00
+
+/* Link Status Change Register (16 bit) */
+#define B53_LINK_STAT_CHANGE		0x02
+
+/* Port Speed Summary Register (16 bit for FE, 32 bit for GE) */
+#define B53_SPEED_STAT			0x04
+#define  SPEED_PORT_FE(reg, port)	(((reg) >> (port)) & 1)
+#define  SPEED_PORT_GE(reg, port)	(((reg) >> 2 * (port)) & 3)
+#define  SPEED_STAT_10M			0
+#define  SPEED_STAT_100M		1
+#define  SPEED_STAT_1000M		2
+
+/* Duplex Status Summary (16 bit) */
+#define B53_DUPLEX_STAT_FE		0x06
+#define B53_DUPLEX_STAT_GE		0x08
+#define B53_DUPLEX_STAT_63XX		0x0c
+
+/* Revision ID register for BCM5325 */
+#define B53_REV_ID_25			0x50
+
+/* Strap Value (48 bit) */
+#define B53_STRAP_VALUE			0x70
+#define   SV_GMII_CTRL_115		BIT(27)
+
+/*************************************************************************
+ * Management Mode Page Registers
+ *************************************************************************/
+
+/* Global Management Config Register (8 bit) */
+#define B53_GLOBAL_CONFIG		0x00
+#define   GC_RESET_MIB			0x01
+#define   GC_RX_BPDU_EN			0x02
+#define   GC_MIB_AC_HDR_EN		0x10
+#define   GC_MIB_AC_EN			0x20
+#define   GC_FRM_MGMT_PORT_M		0xC0
+#define   GC_FRM_MGMT_PORT_04		0x00
+#define   GC_FRM_MGMT_PORT_MII		0x80
+
+/* Device ID register (8 or 32 bit) */
+#define B53_DEVICE_ID			0x30
+
+/* Revision ID register (8 bit) */
+#define B53_REV_ID			0x40
+
+/*************************************************************************
+ * ARL Access Page Registers
+ *************************************************************************/
+
+/* VLAN Table Access Register (8 bit) */
+#define B53_VT_ACCESS			0x80
+#define B53_VT_ACCESS_9798		0x60 /* for BCM5397/BCM5398 */
+#define B53_VT_ACCESS_63XX		0x60 /* for BCM6328/62/68 */
+#define   VTA_CMD_WRITE			0
+#define   VTA_CMD_READ			1
+#define   VTA_CMD_CLEAR			2
+#define   VTA_START_CMD			BIT(7)
+
+/* VLAN Table Index Register (16 bit) */
+#define B53_VT_INDEX			0x81
+#define B53_VT_INDEX_9798		0x61
+#define B53_VT_INDEX_63XX		0x62
+
+/* VLAN Table Entry Register (32 bit) */
+#define B53_VT_ENTRY			0x83
+#define B53_VT_ENTRY_9798		0x63
+#define B53_VT_ENTRY_63XX		0x64
+#define   VTE_MEMBERS			0x1ff
+#define   VTE_UNTAG_S			9
+#define   VTE_UNTAG			(0x1ff << 9)
+
+/*************************************************************************
+ * Port VLAN Registers
+ *************************************************************************/
+
+/* Port VLAN mask (16 bit) IMP port is always 8, also on 5325 & co */
+#define B53_PVLAN_PORT_MASK(i)		((i) * 2)
+
+/*************************************************************************
+ * 802.1Q Page Registers
+ *************************************************************************/
+
+/* Global QoS Control (8 bit) */
+#define B53_QOS_GLOBAL_CTL		0x00
+
+/* Enable 802.1Q for individual Ports (16 bit) */
+#define B53_802_1P_EN			0x04
+
+/*************************************************************************
+ * VLAN Page Registers
+ *************************************************************************/
+
+/* VLAN Control 0 (8 bit) */
+#define B53_VLAN_CTRL0			0x00
+#define   VC0_8021PF_CTRL_MASK		0x3
+#define   VC0_8021PF_CTRL_NONE		0x0
+#define   VC0_8021PF_CTRL_CHANGE_PRI	0x1
+#define   VC0_8021PF_CTRL_CHANGE_VID	0x2
+#define   VC0_8021PF_CTRL_CHANGE_BOTH	0x3
+#define   VC0_8021QF_CTRL_MASK		0xc
+#define   VC0_8021QF_CTRL_CHANGE_PRI	0x1
+#define   VC0_8021QF_CTRL_CHANGE_VID	0x2
+#define   VC0_8021QF_CTRL_CHANGE_BOTH	0x3
+#define   VC0_RESERVED_1		BIT(1)
+#define   VC0_DROP_VID_MISS		BIT(4)
+#define   VC0_VID_HASH_VID		BIT(5)
+#define   VC0_VID_CHK_EN		BIT(6)	/* Use VID,DA or VID,SA */
+#define   VC0_VLAN_EN			BIT(7)	/* 802.1Q VLAN Enabled */
+
+/* VLAN Control 1 (8 bit) */
+#define B53_VLAN_CTRL1			0x01
+#define   VC1_RX_MCST_TAG_EN		BIT(1)
+#define   VC1_RX_MCST_FWD_EN		BIT(2)
+#define   VC1_RX_MCST_UNTAG_EN		BIT(3)
+
+/* VLAN Control 2 (8 bit) */
+#define B53_VLAN_CTRL2			0x02
+
+/* VLAN Control 3 (8 bit when BCM5325, 16 bit else) */
+#define B53_VLAN_CTRL3			0x03
+#define B53_VLAN_CTRL3_63XX		0x04
+#define   VC3_MAXSIZE_1532		BIT(6) /* 5325 only */
+#define   VC3_HIGH_8BIT_EN		BIT(7) /* 5325 only */
+
+/* VLAN Control 4 (8 bit) */
+#define B53_VLAN_CTRL4			0x05
+#define B53_VLAN_CTRL4_25		0x04
+#define B53_VLAN_CTRL4_63XX		0x06
+#define   VC4_ING_VID_CHECK_S		6
+#define   VC4_ING_VID_CHECK_MASK	(0x3 << VC4_ING_VID_CHECK_S)
+#define   VC4_ING_VID_VIO_FWD		0 /* forward, but do not learn */
+#define   VC4_ING_VID_VIO_DROP		1 /* drop VID violations */
+#define   VC4_NO_ING_VID_CHK		2 /* do not check */
+#define   VC4_ING_VID_VIO_TO_IMP	3 /* redirect to MII port */
+
+/* VLAN Control 5 (8 bit) */
+#define B53_VLAN_CTRL5			0x06
+#define B53_VLAN_CTRL5_25		0x05
+#define B53_VLAN_CTRL5_63XX		0x07
+#define   VC5_VID_FFF_EN		BIT(2)
+#define   VC5_DROP_VTABLE_MISS		BIT(3)
+
+/* VLAN Control 6 (8 bit) */
+#define B53_VLAN_CTRL6			0x07
+#define B53_VLAN_CTRL6_63XX		0x08
+
+/* VLAN Table Access Register (16 bit) */
+#define B53_VLAN_TABLE_ACCESS_25	0x06	/* BCM5325E/5350 */
+#define B53_VLAN_TABLE_ACCESS_65	0x08	/* BCM5365 */
+#define   VTA_VID_LOW_MASK_25		0xf
+#define   VTA_VID_LOW_MASK_65		0xff
+#define   VTA_VID_HIGH_S_25		4
+#define   VTA_VID_HIGH_S_65		8
+#define   VTA_VID_HIGH_MASK_25		(0xff << VTA_VID_HIGH_S_25E)
+#define   VTA_VID_HIGH_MASK_65		(0xf << VTA_VID_HIGH_S_65)
+#define   VTA_RW_STATE			BIT(12)
+#define   VTA_RW_STATE_RD		0
+#define   VTA_RW_STATE_WR		BIT(12)
+#define   VTA_RW_OP_EN			BIT(13)
+
+/* VLAN Read/Write Registers for (16/32 bit) */
+#define B53_VLAN_WRITE_25		0x08
+#define B53_VLAN_WRITE_65		0x0a
+#define B53_VLAN_READ			0x0c
+#define   VA_MEMBER_MASK		0x3f
+#define   VA_UNTAG_S			6
+#define   VA_UNTAG_MASK			(0x3f << VA_UNTAG_S)
+#define   VA_VID_HIGH_S			12
+#define   VA_VID_HIGH_MASK		(0xffff << VA_VID_HIGH_S)
+#define   VA_VALID_25			BIT(20)
+#define   VA_VALID_25_R4		BIT(24)
+#define   VA_VALID_65			BIT(14)
+
+/* VLAN Port Default Tag (16 bit) */
+#define B53_VLAN_PORT_DEF_TAG(i)	(0x10 + 2 * (i))
+
+/*************************************************************************
+ * Jumbo Frame Page Registers
+ *************************************************************************/
+
+/* Jumbo Enable Port Mask (bit i == port i enabled) (32 bit) */
+#define B53_JUMBO_PORT_MASK		0x01
+#define B53_JUMBO_PORT_MASK_63XX	0x04
+#define   JPM_10_100_JUMBO_EN		BIT(24) /* GigE always enabled */
+
+/* Good Frame Max Size without 802.1Q TAG (16 bit) */
+#define B53_JUMBO_MAX_SIZE		0x05
+#define B53_JUMBO_MAX_SIZE_63XX		0x08
+#define   JMS_MIN_SIZE			1518
+#define   JMS_MAX_SIZE			9724
+
+#endif /* !__B53_REGS_H */
diff --git a/drivers/net/phy/b53/b53_spi.c b/drivers/net/phy/b53/b53_spi.c
new file mode 100644
index 0000000..6050fea
--- /dev/null
+++ b/drivers/net/phy/b53/b53_spi.c
@@ -0,0 +1,329 @@
+/*
+ * B53 register access through SPI
+ *
+ * Copyright (C) 2011-2013 Jonas Gorski <jogo@openwrt.org>
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include <asm/unaligned.h>
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/spi/spi.h>
+#include <linux/platform_data/b53.h>
+
+#include "b53_priv.h"
+
+#define B53_SPI_DATA		0xf0
+
+#define B53_SPI_STATUS		0xfe
+#define B53_SPI_CMD_SPIF	BIT(7)
+#define B53_SPI_CMD_RACK	BIT(5)
+
+#define B53_SPI_CMD_READ	0x00
+#define B53_SPI_CMD_WRITE	0x01
+#define B53_SPI_CMD_NORMAL	0x60
+#define B53_SPI_CMD_FAST	0x10
+
+#define B53_SPI_PAGE_SELECT	0xff
+
+static inline int b53_spi_read_reg(struct spi_device *spi, u8 reg, u8 *val,
+				     unsigned len)
+{
+	u8 txbuf[2];
+
+	txbuf[0] = B53_SPI_CMD_NORMAL | B53_SPI_CMD_READ;
+	txbuf[1] = reg;
+
+	return spi_write_then_read(spi, txbuf, 2, val, len);
+}
+
+static inline int b53_spi_clear_status(struct spi_device *spi)
+{
+	unsigned int i;
+	u8 rxbuf;
+	int ret;
+
+	for (i = 0; i < 10; i++) {
+		ret = b53_spi_read_reg(spi, B53_SPI_STATUS, &rxbuf, 1);
+		if (ret)
+			return ret;
+
+		if (!(rxbuf & B53_SPI_CMD_SPIF))
+			break;
+
+		mdelay(1);
+	}
+
+	if (i == 10)
+		return -EIO;
+
+	return 0;
+}
+
+static inline int b53_spi_set_page(struct spi_device *spi, u8 page)
+{
+	u8 txbuf[3];
+
+	txbuf[0] = B53_SPI_CMD_NORMAL | B53_SPI_CMD_WRITE;
+	txbuf[1] = B53_SPI_PAGE_SELECT;
+	txbuf[2] = page;
+
+	return spi_write(spi, txbuf, sizeof(txbuf));
+}
+
+static inline int b53_prepare_reg_access(struct spi_device *spi, u8 page)
+{
+	int ret = b53_spi_clear_status(spi);
+	if (ret)
+		return ret;
+
+	return b53_spi_set_page(spi, page);
+}
+
+static int b53_spi_prepare_reg_read(struct spi_device *spi, u8 reg)
+{
+	u8 rxbuf;
+	int retry_count;
+	int ret;
+
+	ret = b53_spi_read_reg(spi, reg, &rxbuf, 1);
+	if (ret)
+		return ret;
+
+	for (retry_count = 0; retry_count < 10; retry_count++) {
+		ret = b53_spi_read_reg(spi, B53_SPI_STATUS, &rxbuf, 1);
+		if (ret)
+			return ret;
+
+		if (rxbuf & B53_SPI_CMD_RACK)
+			break;
+
+		mdelay(1);
+	}
+
+	if (retry_count == 10)
+		return -EIO;
+
+	return 0;
+}
+
+static int b53_spi_read(struct b53_device *dev, u8 page, u8 reg, u8 *data,
+			unsigned len)
+{
+	struct spi_device *spi = dev->priv;
+	int ret;
+
+	ret = b53_prepare_reg_access(spi, page);
+	if (ret)
+		return ret;
+
+	ret = b53_spi_prepare_reg_read(spi, reg);
+	if (ret)
+		return ret;
+
+	return b53_spi_read_reg(spi, B53_SPI_DATA, data, len);
+}
+
+static int b53_spi_read8(struct b53_device *dev, u8 page, u8 reg, u8 *val)
+{
+	return b53_spi_read(dev, page, reg, val, 1);
+}
+
+static int b53_spi_read16(struct b53_device *dev, u8 page, u8 reg, u16 *val)
+{
+	int ret = b53_spi_read(dev, page, reg, (u8 *)val, 2);
+	if (!ret)
+		*val = le16_to_cpu(*val);
+
+	return ret;
+}
+
+static int b53_spi_read32(struct b53_device *dev, u8 page, u8 reg, u32 *val)
+{
+	int ret = b53_spi_read(dev, page, reg, (u8 *)val, 4);
+	if (!ret)
+		*val = le32_to_cpu(*val);
+
+	return ret;
+}
+
+static int b53_spi_read48(struct b53_device *dev, u8 page, u8 reg, u64 *val)
+{
+	int ret;
+
+	*val = 0;
+	ret = b53_spi_read(dev, page, reg, (u8 *)val, 6);
+	if (!ret)
+		*val = le64_to_cpu(*val);
+
+	return ret;
+}
+
+static int b53_spi_read64(struct b53_device *dev, u8 page, u8 reg, u64 *val)
+{
+	int ret = b53_spi_read(dev, page, reg, (u8 *)val, 8);
+	if (!ret)
+		*val = le64_to_cpu(*val);
+
+	return ret;
+}
+
+static int b53_spi_write8(struct b53_device *dev, u8 page, u8 reg, u8 value)
+{
+	struct spi_device *spi = dev->priv;
+	int ret;
+	u8 txbuf[3];
+
+	ret = b53_prepare_reg_access(spi, page);
+	if (ret)
+		return ret;
+
+	txbuf[0] = B53_SPI_CMD_NORMAL | B53_SPI_CMD_WRITE;
+	txbuf[1] = reg;
+	txbuf[2] = value;
+
+	return spi_write(spi, txbuf, sizeof(txbuf));
+}
+
+static int b53_spi_write16(struct b53_device *dev, u8 page, u8 reg, u16 value)
+{
+	struct spi_device *spi = dev->priv;
+	int ret;
+	u8 txbuf[4];
+
+	ret = b53_prepare_reg_access(spi, page);
+	if (ret)
+		return ret;
+
+	txbuf[0] = B53_SPI_CMD_NORMAL | B53_SPI_CMD_WRITE;
+	txbuf[1] = reg;
+	put_unaligned_le16(value, &txbuf[2]);
+
+	return spi_write(spi, txbuf, sizeof(txbuf));
+}
+
+static int b53_spi_write32(struct b53_device *dev, u8 page, u8 reg, u32 value)
+{
+	struct spi_device *spi = dev->priv;
+	int ret;
+	u8 txbuf[6];
+
+	ret = b53_prepare_reg_access(spi, page);
+	if (ret)
+		return ret;
+
+	txbuf[0] = B53_SPI_CMD_NORMAL | B53_SPI_CMD_WRITE;
+	txbuf[1] = reg;
+	put_unaligned_le32(value, &txbuf[2]);
+
+	return spi_write(spi, txbuf, sizeof(txbuf));
+}
+
+static int b53_spi_write48(struct b53_device *dev, u8 page, u8 reg, u64 value)
+{
+	struct spi_device *spi = dev->priv;
+	int ret;
+	u8 txbuf[10];
+
+	ret = b53_prepare_reg_access(spi, page);
+	if (ret)
+		return ret;
+
+	txbuf[0] = B53_SPI_CMD_NORMAL | B53_SPI_CMD_WRITE;
+	txbuf[1] = reg;
+	put_unaligned_le64(value, &txbuf[2]);
+
+	return spi_write(spi, txbuf, sizeof(txbuf) - 2);
+}
+
+static int b53_spi_write64(struct b53_device *dev, u8 page, u8 reg, u64 value)
+{
+	struct spi_device *spi = dev->priv;
+	int ret;
+	u8 txbuf[10];
+
+	ret = b53_prepare_reg_access(spi, page);
+	if (ret)
+		return ret;
+
+	txbuf[0] = B53_SPI_CMD_NORMAL | B53_SPI_CMD_WRITE;
+	txbuf[1] = reg;
+	put_unaligned_le64(value, &txbuf[2]);
+
+	return spi_write(spi, txbuf, sizeof(txbuf));
+}
+
+static struct b53_io_ops b53_spi_ops = {
+	.read8 = b53_spi_read8,
+	.read16 = b53_spi_read16,
+	.read32 = b53_spi_read32,
+	.read48 = b53_spi_read48,
+	.read64 = b53_spi_read64,
+	.write8 = b53_spi_write8,
+	.write16 = b53_spi_write16,
+	.write32 = b53_spi_write32,
+	.write48 = b53_spi_write48,
+	.write64 = b53_spi_write64,
+};
+
+static int b53_spi_probe(struct spi_device *spi)
+{
+	struct b53_device *dev;
+	int ret;
+
+	dev = b53_switch_alloc(&spi->dev, &b53_spi_ops, spi);
+	if (!dev)
+		return -ENOMEM;
+
+	if (spi->dev.platform_data)
+		dev->pdata = spi->dev.platform_data;
+
+	ret = b53_switch_register(dev);
+	if (ret)
+		return ret;
+
+	spi->dev.platform_data = dev;
+
+	return 0;
+}
+
+static int b53_spi_remove(struct spi_device *spi)
+{
+	struct b53_device *dev = spi->dev.platform_data;
+
+	if (dev) {
+		struct b53_platform_data *pdata = dev->pdata;
+		b53_switch_remove(dev);
+		spi->dev.platform_data = pdata;
+	}
+
+	return 0;
+}
+
+static struct spi_driver b53_spi_driver = {
+	.driver = {
+		.name	= "b53-switch",
+		.bus	= &spi_bus_type,
+		.owner	= THIS_MODULE,
+	},
+	.probe	= b53_spi_probe,
+	.remove	= b53_spi_remove,
+};
+
+module_spi_driver(b53_spi_driver);
+
+MODULE_AUTHOR("Jonas Gorski <jogo@openwrt.org>");
+MODULE_DESCRIPTION("B53 SPI access driver");
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/include/linux/platform_data/b53.h b/include/linux/platform_data/b53.h
new file mode 100644
index 0000000..5367b4e
--- /dev/null
+++ b/include/linux/platform_data/b53.h
@@ -0,0 +1,32 @@
+/*
+ * B53 platform data
+ *
+ * Copyright (C) 2013 Jonas Gorski <jogo@openwrt.org>
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef __B53_H
+#define __B53_H
+
+#include <linux/kernel.h>
+
+struct b53_platform_data {
+	u32 chip_id;
+	u16 enabled_ports;
+
+	/* allow to specify an ethX alias */
+	const char *alias;
+};
+
+#endif
-- 
1.8.3.2
