From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/5] net: dsa: b53: Add support for Broadcom RoboSwitch
Date: Thu,  9 Jun 2016 18:23:53 -0700
Message-ID: <1465521837-30193-2-git-send-email-f.fainelli@gmail.com>
References: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
	jon.mason@broadcom.com, hemal.shah@broadcom.com,
	bandaru.viswanath@broadcom.com, michael.chan@broadcom.com,
	jogo@openwrt.org, cphealy@gmail.com, ardeleanalex@gmail.com,
	jiri@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33014 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbcFJBYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 21:24:08 -0400
Received: by mail-pa0-f65.google.com with SMTP id di3so3869565pab.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 18:24:07 -0700 (PDT)
In-Reply-To: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for Broadcom's BCM53xx switch family, also known
as RoboSwitch. Some of these switches are ubiquituous, found in home
routers, Wi-Fi routers, DSL and cable modem gateways and other
networking related products.

This drivers adds the library driver (b53_common.c) as well as a few bus
glue drivers for MDIO, SPI, Switch Register Access Block (SRAB) and
memory-mapped I/O into a SoC's address space (Broadcom BCM63xx/33xx).

Basic operations are supported to bring the Layer 1/2 up and running,
but not much more at this point, subsequent patches add the remaining
features.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/devicetree/bindings/net/dsa/b53.txt |   90 ++
 MAINTAINERS                                       |    8 +
 drivers/net/dsa/Kconfig                           |    2 +
 drivers/net/dsa/Makefile                          |    2 +
 drivers/net/dsa/b53/Kconfig                       |   33 +
 drivers/net/dsa/b53/Makefile                      |    6 +
 drivers/net/dsa/b53/b53_common.c                  | 1158 +++++++++++++++++++++
 drivers/net/dsa/b53/b53_mdio.c                    |  381 +++++++
 drivers/net/dsa/b53/b53_mmap.c                    |  260 +++++
 drivers/net/dsa/b53/b53_priv.h                    |  322 ++++++
 drivers/net/dsa/b53/b53_regs.h                    |  358 +++++++
 drivers/net/dsa/b53/b53_spi.c                     |  331 ++++++
 drivers/net/dsa/b53/b53_srab.c                    |  415 ++++++++
 include/linux/platform_data/b53.h                 |   33 +
 14 files changed, 3399 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/b53.txt
 create mode 100644 drivers/net/dsa/b53/Kconfig
 create mode 100644 drivers/net/dsa/b53/Makefile
 create mode 100644 drivers/net/dsa/b53/b53_common.c
 create mode 100644 drivers/net/dsa/b53/b53_mdio.c
 create mode 100644 drivers/net/dsa/b53/b53_mmap.c
 create mode 100644 drivers/net/dsa/b53/b53_priv.h
 create mode 100644 drivers/net/dsa/b53/b53_regs.h
 create mode 100644 drivers/net/dsa/b53/b53_spi.c
 create mode 100644 drivers/net/dsa/b53/b53_srab.c
 create mode 100644 include/linux/platform_data/b53.h

diff --git a/Documentation/devicetree/bindings/net/dsa/b53.txt b/Documentation/devicetree/bindings/net/dsa/b53.txt
new file mode 100644
index 000000000000..4a5349a09655
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dsa/b53.txt
@@ -0,0 +1,90 @@
+Broadcom BCM53xx Ethernet switches
+==================================
+
+Required properties:
+
+- compatible: For external switch chips, compatible string must be exactly one
+  of: "brcm,bcm5325"
+      "brcm,bcm53115"
+      "brcm,bcm53125"
+      "brcm,bcm53128"
+      "brcm,bcm5365"
+      "brcm,bcm5395"
+      "brcm,bcm5397"
+      "brcm,bcm5398"
+
+  For the BCM5310x SoCs with an integrated switch, must be one of:
+      "brcm,bcm53010-srab"
+      "brcm,bcm53011-srab"
+      "brcm,bcm53012-srab"
+      "brcm,bcm53018-srab"
+      "brcm,bcm53019-srab" and the mandatory "brcm,bcm5301x-srab" string
+
+  For the BCM63xx/33xx SoCs with an integrated switch, must be one of:
+      "brcm,bcm3384-switch"
+      "brcm,bcm6328-switch"
+      "brcm,bcm6368-switch" and the mandatory "brcm,bcm63xx-switch"
+
+See Documentation/devicetree/bindings/dsa/dsa.txt for a list of additional
+required and optional properties.
+
+Examples:
+
+Ethernet switch connected via MDIO to the host, CPU port wired to eth0:
+
+	eth0: ethernet@10001000 {
+		compatible = "brcm,unimac";
+		reg = <0x10001000 0x1000>;
+
+		fixed-link {
+			speed = <1000>;
+			duplex-full;
+		};
+	};
+
+	mdio0: mdio@10000000 {
+		compatible = "brcm,unimac-mdio";
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		switch0: ethernet-switch@30 {
+			compatible = "brcm,bcm53125";
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			ports {
+				port0@0 {
+					reg = <0>;
+					label = "lan1";
+				};
+
+				port1@1 {
+					reg = <1>;
+					label = "lan2";
+				};
+
+				port5@5 {
+					reg = <5>;
+					label = "cable-modem";
+					fixed-link {
+						speed = <1000>;
+						duplex-full;
+					};
+					phy-mode = "rgmii-txid";
+				};
+
+				port8@8 {
+					reg = <8>;
+					label = "cpu";
+					fixed-link {
+						speed = <1000>;
+						duplex-full;
+					};
+					phy-mode = "rgmii-txid";
+					ethernet = <&eth0>;
+				};
+			};
+		};
+	};
+
+
diff --git a/MAINTAINERS b/MAINTAINERS
index 16e1500d7c52..b29a08884eed 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2454,6 +2454,14 @@ L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/broadcom/b44.*
 
+BROADCOM B53 ETHERNET SWITCH DRIVER
+M:	Florian Fainelli <f.fainelli@gmail.com>
+L:	netdev@vger.kernel.org
+L:	openwrt-devel@lists.openwrt.org (subscribers-only)
+S:	Supported
+F:	drivers/net/dsa/b53/*
+F:	include/linux/platform_data/b53.h
+
 BROADCOM GENET ETHERNET DRIVER
 M:	Florian Fainelli <f.fainelli@gmail.com>
 L:	netdev@vger.kernel.org
diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 200663c43ce9..be481e15ec9b 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -28,4 +28,6 @@ config NET_DSA_BCM_SF2
 	  This enables support for the Broadcom Starfighter 2 Ethernet
 	  switch chips.
 
+source "drivers/net/dsa/b53/Kconfig"
+
 endmenu
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index 76b751dd9efd..97bc70a7f3c7 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -1,3 +1,5 @@
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
 obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm_sf2.o
+
+obj-y				+= b53/
diff --git a/drivers/net/dsa/b53/Kconfig b/drivers/net/dsa/b53/Kconfig
new file mode 100644
index 000000000000..27f32a50df57
--- /dev/null
+++ b/drivers/net/dsa/b53/Kconfig
@@ -0,0 +1,33 @@
+menuconfig B53
+	tristate "Broadcom BCM53xx managed switch support"
+	depends on NET_DSA
+	help
+	  This driver adds support for Broadcom managed switch chips. It supports
+	  BCM5325E, BCM5365, BCM539x, BCM53115 and BCM53125 as well as BCM63XX
+	  integrated switches.
+
+config B53_SPI_DRIVER
+	tristate "B53 SPI connected switch driver"
+	depends on B53 && SPI
+	help
+	  Select to enable support for registering switches configured through SPI.
+
+config B53_MDIO_DRIVER
+	tristate "B53 MDIO connected switch driver"
+	depends on B53
+	help
+	  Select to enable support for registering switches configured through MDIO.
+
+config B53_MMAP_DRIVER
+	tristate "B53 MMAP connected switch driver"
+	depends on B53 && HAS_IOMEM
+	help
+	  Select to enable support for memory-mapped switches like the BCM63XX
+	  integrated switches.
+
+config B53_SRAB_DRIVER
+	tristate "B53 SRAB connected switch driver"
+	depends on B53 && HAS_IOMEM
+	help
+	  Select to enable support for memory-mapped Switch Register Access
+	  Bridge Registers (SRAB) like it is found on the BCM53010
diff --git a/drivers/net/dsa/b53/Makefile b/drivers/net/dsa/b53/Makefile
new file mode 100644
index 000000000000..7e6f9a8bfd75
--- /dev/null
+++ b/drivers/net/dsa/b53/Makefile
@@ -0,0 +1,6 @@
+obj-$(CONFIG_B53)		+= b53_common.o
+
+obj-$(CONFIG_B53_SPI_DRIVER)	+= b53_spi.o
+obj-$(CONFIG_B53_MDIO_DRIVER)	+= b53_mdio.o
+obj-$(CONFIG_B53_MMAP_DRIVER)	+= b53_mmap.o
+obj-$(CONFIG_B53_SRAB_DRIVER)	+= b53_srab.o
diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
new file mode 100644
index 000000000000..6f0337d6dfa4
--- /dev/null
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -0,0 +1,1158 @@
+/*
+ * B53 switch driver main logic
+ *
+ * Copyright (C) 2011-2013 Jonas Gorski <jogo@openwrt.org>
+ * Copyright (C) 2016 Florian Fainelli <f.fainelli@gmail.com>
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
+#include <linux/platform_data/b53.h>
+#include <linux/phy.h>
+#include <net/dsa.h>
+
+#include "b53_regs.h"
+#include "b53_priv.h"
+
+struct b53_mib_desc {
+	u8 size;
+	u8 offset;
+	const char *name;
+};
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
+};
+
+#define B53_MIBS_65_SIZE	ARRAY_SIZE(b53_mibs_65)
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
+};
+
+#define B53_MIBS_63XX_SIZE	ARRAY_SIZE(b53_mibs_63xx)
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
+};
+
+#define B53_MIBS_SIZE	ARRAY_SIZE(b53_mibs)
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
+			entry = ((untag & VA_UNTAG_MASK_25) << VA_UNTAG_S_25) |
+				members;
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
+			entry = ((untag & VA_UNTAG_MASK_65) << VA_UNTAG_S_65) |
+				members | VA_VALID_65;
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
+static int b53_set_jumbo(struct b53_device *dev, bool enable, bool allow_10_100)
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
+			goto out;
+
+		msleep(1);
+	}
+
+	return -ETIMEDOUT;
+out:
+	/* Only age dynamic entries (default behavior) */
+	b53_write8(dev, B53_CTRL_PAGE, B53_FAST_AGE_CTRL, FAST_AGE_DYNAMIC);
+	return 0;
+}
+
+static int b53_enable_port(struct dsa_switch *ds, int port,
+			   struct phy_device *phy)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+
+	/* Clear the Rx and Tx disable bits and set to no spanning tree */
+	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), 0);
+
+	return 0;
+}
+
+static void b53_disable_port(struct dsa_switch *ds, int port,
+			     struct phy_device *phy)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	u8 reg;
+
+	/* Disable Tx/Rx for the port */
+	b53_read8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), &reg);
+	reg |= PORT_CTRL_RX_DISABLE | PORT_CTRL_TX_DISABLE;
+	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), reg);
+}
+
+static void b53_enable_cpu_port(struct b53_device *dev)
+{
+	unsigned int cpu_port = dev->cpu_port;
+	u8 port_ctrl;
+
+	/* BCM5325 CPU port is at 8 */
+	if ((is5325(dev) || is5365(dev)) && cpu_port == B53_CPU_PORT_25)
+		cpu_port = B53_CPU_PORT;
+
+	port_ctrl = PORT_CTRL_RX_BCST_EN |
+		    PORT_CTRL_RX_MCST_EN |
+		    PORT_CTRL_RX_UCST_EN;
+	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(cpu_port), port_ctrl);
+}
+
+static void b53_enable_mib(struct b53_device *dev)
+{
+	u8 gc;
+
+	b53_read8(dev, B53_MGMT_PAGE, B53_GLOBAL_CONFIG, &gc);
+	gc &= ~(GC_RESET_MIB | GC_MIB_AC_EN);
+	b53_write8(dev, B53_MGMT_PAGE, B53_GLOBAL_CONFIG, gc);
+}
+
+static int b53_configure_vlan(struct b53_device *dev)
+{
+	int i;
+
+	/* clear all vlan entries */
+	if (is5325(dev) || is5365(dev)) {
+		for (i = 1; i < dev->num_vlans; i++)
+			b53_set_vlan_entry(dev, i, 0, 0);
+	} else {
+		b53_do_vlan_op(dev, VTA_CMD_CLEAR);
+	}
+
+	b53_enable_vlan(dev, false);
+
+	b53_for_each_port(dev, i)
+		b53_write16(dev, B53_VLAN_PAGE,
+			    B53_VLAN_PORT_DEF_TAG(i), 1);
+
+	if (!is5325(dev) && !is5365(dev))
+		b53_set_jumbo(dev, dev->enable_jumbo, false);
+
+	return 0;
+}
+
+static void b53_switch_reset_gpio(struct b53_device *dev)
+{
+	int gpio = dev->reset_gpio;
+
+	if (gpio < 0)
+		return;
+
+	/* Reset sequence: RESET low(50ms)->high(20ms)
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
+			dev_err(dev->dev, "Failed to enable switch!\n");
+			return -EINVAL;
+		}
+	}
+
+	b53_enable_mib(dev);
+
+	return b53_flush_arl(dev);
+}
+
+static int b53_phy_read16(struct dsa_switch *ds, int addr, int reg)
+{
+	struct b53_device *priv = ds_to_priv(ds);
+	u16 value = 0;
+	int ret;
+
+	if (priv->ops->phy_read16)
+		ret = priv->ops->phy_read16(priv, addr, reg, &value);
+	else
+		ret = b53_read16(priv, B53_PORT_MII_PAGE(addr),
+				 reg * 2, &value);
+
+	return ret ? ret : value;
+}
+
+static int b53_phy_write16(struct dsa_switch *ds, int addr, int reg, u16 val)
+{
+	struct b53_device *priv = ds_to_priv(ds);
+
+	if (priv->ops->phy_write16)
+		return priv->ops->phy_write16(priv, addr, reg, val);
+
+	return b53_write16(priv, B53_PORT_MII_PAGE(addr), reg * 2, val);
+}
+
+static int b53_reset_switch(struct b53_device *priv)
+{
+	/* reset vlans */
+	priv->enable_jumbo = false;
+
+	memset(priv->ports, 0, sizeof(*priv->ports) * priv->num_ports);
+
+	return b53_switch_reset(priv);
+}
+
+static int b53_apply_config(struct b53_device *priv)
+{
+	/* disable switching */
+	b53_set_forwarding(priv, 0);
+
+	b53_configure_vlan(priv);
+
+	/* enable switching */
+	b53_set_forwarding(priv, 1);
+
+	return 0;
+}
+
+static void b53_reset_mib(struct b53_device *priv)
+{
+	u8 gc;
+
+	b53_read8(priv, B53_MGMT_PAGE, B53_GLOBAL_CONFIG, &gc);
+
+	b53_write8(priv, B53_MGMT_PAGE, B53_GLOBAL_CONFIG, gc | GC_RESET_MIB);
+	msleep(1);
+	b53_write8(priv, B53_MGMT_PAGE, B53_GLOBAL_CONFIG, gc & ~GC_RESET_MIB);
+	msleep(1);
+}
+
+static const struct b53_mib_desc *b53_get_mib(struct b53_device *dev)
+{
+	if (is5365(dev))
+		return b53_mibs_65;
+	else if (is63xx(dev))
+		return b53_mibs_63xx;
+	else
+		return b53_mibs;
+}
+
+static unsigned int b53_get_mib_size(struct b53_device *dev)
+{
+	if (is5365(dev))
+		return B53_MIBS_65_SIZE;
+	else if (is63xx(dev))
+		return B53_MIBS_63XX_SIZE;
+	else
+		return B53_MIBS_SIZE;
+}
+
+static void b53_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	const struct b53_mib_desc *mibs = b53_get_mib(dev);
+	unsigned int mib_size = b53_get_mib_size(dev);
+	unsigned int i;
+
+	for (i = 0; i < mib_size; i++)
+		memcpy(data + i * ETH_GSTRING_LEN,
+		       mibs[i].name, ETH_GSTRING_LEN);
+}
+
+static void b53_get_ethtool_stats(struct dsa_switch *ds, int port,
+				  uint64_t *data)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	const struct b53_mib_desc *mibs = b53_get_mib(dev);
+	unsigned int mib_size = b53_get_mib_size(dev);
+	const struct b53_mib_desc *s;
+	unsigned int i;
+	u64 val = 0;
+
+	if (is5365(dev) && port == 5)
+		port = 8;
+
+	mutex_lock(&dev->stats_mutex);
+
+	for (i = 0; i < mib_size; i++) {
+		s = &mibs[i];
+
+		if (mibs->size == 8) {
+			b53_read64(dev, B53_MIB_PAGE(port), s->offset, &val);
+		} else {
+			u32 val32;
+
+			b53_read32(dev, B53_MIB_PAGE(port), s->offset,
+				   &val32);
+			val = val32;
+		}
+		data[i] = (u64)val;
+	}
+
+	mutex_unlock(&dev->stats_mutex);
+}
+
+static int b53_get_sset_count(struct dsa_switch *ds)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+
+	return b53_get_mib_size(dev);
+}
+
+static int b53_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	return 0;
+}
+
+static int b53_setup(struct dsa_switch *ds)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	unsigned int port;
+	int ret;
+
+	ret = b53_reset_switch(dev);
+	if (ret) {
+		dev_err(ds->dev, "failed to reset switch\n");
+		return ret;
+	}
+
+	b53_reset_mib(dev);
+
+	ret = b53_apply_config(dev);
+	if (ret)
+		dev_err(ds->dev, "failed to apply configuration\n");
+
+	for (port = 0; port < dev->num_ports; port++) {
+		if (BIT(port) & ds->enabled_port_mask)
+			b53_enable_port(ds, port, NULL);
+		else if (dsa_is_cpu_port(ds, port))
+			b53_enable_cpu_port(dev);
+		else
+			b53_disable_port(ds, port, NULL);
+	}
+
+	return ret;
+}
+
+static void b53_adjust_link(struct dsa_switch *ds, int port,
+			    struct phy_device *phydev)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	u8 rgmii_ctrl = 0, reg = 0, off;
+
+	if (!phy_is_pseudo_fixed_link(phydev))
+		return;
+
+	/* Override the port settings */
+	if (port == dev->cpu_port) {
+		off = B53_PORT_OVERRIDE_CTRL;
+		reg = PORT_OVERRIDE_EN;
+	} else {
+		off = B53_GMII_PORT_OVERRIDE_CTRL(port);
+		reg = GMII_PO_EN;
+	}
+
+	/* Set the link UP */
+	if (phydev->link)
+		reg |= PORT_OVERRIDE_LINK;
+
+	if (phydev->duplex == DUPLEX_FULL)
+		reg |= PORT_OVERRIDE_FULL_DUPLEX;
+
+	switch (phydev->speed) {
+	case 2000:
+		reg |= PORT_OVERRIDE_SPEED_2000M;
+		/* fallthrough */
+	case SPEED_1000:
+		reg |= PORT_OVERRIDE_SPEED_1000M;
+		break;
+	case SPEED_100:
+		reg |= PORT_OVERRIDE_SPEED_100M;
+		break;
+	case SPEED_10:
+		reg |= PORT_OVERRIDE_SPEED_10M;
+		break;
+	default:
+		dev_err(ds->dev, "unknown speed: %d\n", phydev->speed);
+		return;
+	}
+
+	/* Enable flow control on BCM5301x's CPU port */
+	if (is5301x(dev) && port == dev->cpu_port)
+		reg |= PORT_OVERRIDE_RX_FLOW | PORT_OVERRIDE_TX_FLOW;
+
+	if (phydev->pause) {
+		if (phydev->asym_pause)
+			reg |= PORT_OVERRIDE_TX_FLOW;
+		reg |= PORT_OVERRIDE_RX_FLOW;
+	}
+
+	b53_write8(dev, B53_CTRL_PAGE, off, reg);
+
+	if (is531x5(dev) && phy_interface_is_rgmii(phydev)) {
+		if (port == 8)
+			off = B53_RGMII_CTRL_IMP;
+		else
+			off = B53_RGMII_CTRL_P(port);
+
+		/* Configure the port RGMII clock delay by DLL disabled and
+		 * tx_clk aligned timing (restoring to reset defaults)
+		 */
+		b53_read8(dev, B53_CTRL_PAGE, off, &rgmii_ctrl);
+		rgmii_ctrl &= ~(RGMII_CTRL_DLL_RXC | RGMII_CTRL_DLL_TXC |
+				RGMII_CTRL_TIMING_SEL);
+
+		/* PHY_INTERFACE_MODE_RGMII_TXID means TX internal delay, make
+		 * sure that we enable the port TX clock internal delay to
+		 * account for this internal delay that is inserted, otherwise
+		 * the switch won't be able to receive correctly.
+		 *
+		 * PHY_INTERFACE_MODE_RGMII means that we are not introducing
+		 * any delay neither on transmission nor reception, so the
+		 * BCM53125 must also be configured accordingly to account for
+		 * the lack of delay and introduce
+		 *
+		 * The BCM53125 switch has its RX clock and TX clock control
+		 * swapped, hence the reason why we modify the TX clock path in
+		 * the "RGMII" case
+		 */
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
+			rgmii_ctrl |= RGMII_CTRL_DLL_TXC;
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII)
+			rgmii_ctrl |= RGMII_CTRL_DLL_TXC | RGMII_CTRL_DLL_RXC;
+		rgmii_ctrl |= RGMII_CTRL_TIMING_SEL;
+		b53_write8(dev, B53_CTRL_PAGE, off, rgmii_ctrl);
+
+		dev_info(ds->dev, "Configured port %d for %s\n", port,
+			 phy_modes(phydev->interface));
+	}
+
+	/* configure MII port if necessary */
+	if (is5325(dev)) {
+		b53_read8(dev, B53_CTRL_PAGE, B53_PORT_OVERRIDE_CTRL,
+			  &reg);
+
+		/* reverse mii needs to be enabled */
+		if (!(reg & PORT_OVERRIDE_RV_MII_25)) {
+			b53_write8(dev, B53_CTRL_PAGE, B53_PORT_OVERRIDE_CTRL,
+				   reg | PORT_OVERRIDE_RV_MII_25);
+			b53_read8(dev, B53_CTRL_PAGE, B53_PORT_OVERRIDE_CTRL,
+				  &reg);
+
+			if (!(reg & PORT_OVERRIDE_RV_MII_25)) {
+				dev_err(ds->dev,
+					"Failed to enable reverse MII mode\n");
+				return;
+			}
+		}
+	} else if (is5301x(dev)) {
+		if (port != dev->cpu_port) {
+			u8 po_reg = B53_GMII_PORT_OVERRIDE_CTRL(dev->cpu_port);
+			u8 gmii_po;
+
+			b53_read8(dev, B53_CTRL_PAGE, po_reg, &gmii_po);
+			gmii_po |= GMII_PO_LINK |
+				   GMII_PO_RX_FLOW |
+				   GMII_PO_TX_FLOW |
+				   GMII_PO_EN |
+				   GMII_PO_SPEED_2000M;
+			b53_write8(dev, B53_CTRL_PAGE, po_reg, gmii_po);
+		}
+	}
+}
+
+static struct dsa_switch_driver b53_switch_ops = {
+	.tag_protocol		= DSA_TAG_PROTO_NONE,
+	.setup			= b53_setup,
+	.set_addr		= b53_set_addr,
+	.get_strings		= b53_get_strings,
+	.get_ethtool_stats	= b53_get_ethtool_stats,
+	.get_sset_count		= b53_get_sset_count,
+	.phy_read		= b53_phy_read16,
+	.phy_write		= b53_phy_write16,
+	.adjust_link		= b53_adjust_link,
+	.port_enable		= b53_enable_port,
+	.port_disable		= b53_disable_port,
+};
+
+struct b53_chip_data {
+	u32 chip_id;
+	const char *dev_name;
+	u16 vlans;
+	u16 enabled_ports;
+	u8 cpu_port;
+	u8 vta_regs[3];
+	u8 duplex_reg;
+	u8 jumbo_pm_reg;
+	u8 jumbo_size_reg;
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
+		.vlans = 16,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT_25,
+		.duplex_reg = B53_DUPLEX_STAT_FE,
+	},
+	{
+		.chip_id = BCM5365_DEVICE_ID,
+		.dev_name = "BCM5365",
+		.vlans = 256,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT_25,
+		.duplex_reg = B53_DUPLEX_STAT_FE,
+	},
+	{
+		.chip_id = BCM5395_DEVICE_ID,
+		.dev_name = "BCM5395",
+		.vlans = 4096,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id = BCM5397_DEVICE_ID,
+		.dev_name = "BCM5397",
+		.vlans = 4096,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS_9798,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id = BCM5398_DEVICE_ID,
+		.dev_name = "BCM5398",
+		.vlans = 4096,
+		.enabled_ports = 0x7f,
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS_9798,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id = BCM53115_DEVICE_ID,
+		.dev_name = "BCM53115",
+		.vlans = 4096,
+		.enabled_ports = 0x1f,
+		.vta_regs = B53_VTA_REGS,
+		.cpu_port = B53_CPU_PORT,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id = BCM53125_DEVICE_ID,
+		.dev_name = "BCM53125",
+		.vlans = 4096,
+		.enabled_ports = 0xff,
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id = BCM53128_DEVICE_ID,
+		.dev_name = "BCM53128",
+		.vlans = 4096,
+		.enabled_ports = 0x1ff,
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id = BCM63XX_DEVICE_ID,
+		.dev_name = "BCM63xx",
+		.vlans = 4096,
+		.enabled_ports = 0, /* pdata must provide them */
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS_63XX,
+		.duplex_reg = B53_DUPLEX_STAT_63XX,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK_63XX,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE_63XX,
+	},
+	{
+		.chip_id = BCM53010_DEVICE_ID,
+		.dev_name = "BCM53010",
+		.vlans = 4096,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT_25, /* TODO: auto detect */
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id = BCM53011_DEVICE_ID,
+		.dev_name = "BCM53011",
+		.vlans = 4096,
+		.enabled_ports = 0x1bf,
+		.cpu_port = B53_CPU_PORT_25, /* TODO: auto detect */
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id = BCM53012_DEVICE_ID,
+		.dev_name = "BCM53012",
+		.vlans = 4096,
+		.enabled_ports = 0x1bf,
+		.cpu_port = B53_CPU_PORT_25, /* TODO: auto detect */
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id = BCM53018_DEVICE_ID,
+		.dev_name = "BCM53018",
+		.vlans = 4096,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT_25, /* TODO: auto detect */
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id = BCM53019_DEVICE_ID,
+		.dev_name = "BCM53019",
+		.vlans = 4096,
+		.enabled_ports = 0x1f,
+		.cpu_port = B53_CPU_PORT_25, /* TODO: auto detect */
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
+};
+
+static int b53_switch_init(struct b53_device *dev)
+{
+	struct dsa_switch *ds = dev->ds;
+	unsigned int i;
+	int ret;
+
+	for (i = 0; i < ARRAY_SIZE(b53_switch_chips); i++) {
+		const struct b53_chip_data *chip = &b53_switch_chips[i];
+
+		if (chip->chip_id == dev->chip_id) {
+			if (!dev->enabled_ports)
+				dev->enabled_ports = chip->enabled_ports;
+			dev->name = chip->dev_name;
+			dev->duplex_reg = chip->duplex_reg;
+			dev->vta_regs[0] = chip->vta_regs[0];
+			dev->vta_regs[1] = chip->vta_regs[1];
+			dev->vta_regs[2] = chip->vta_regs[2];
+			dev->jumbo_pm_reg = chip->jumbo_pm_reg;
+			ds->drv = &b53_switch_ops;
+			dev->cpu_port = chip->cpu_port;
+			dev->num_vlans = chip->vlans;
+			break;
+		}
+	}
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
+/* On the BCM47XX SoCs this is the supported internal switch.*/
+#ifndef CONFIG_BCM47XX
+			/* BCM5325M */
+			return -EINVAL;
+#else
+			break;
+#endif
+		}
+	} else if (dev->chip_id == BCM53115_DEVICE_ID) {
+		u64 strap_value;
+
+		b53_read48(dev, B53_STAT_PAGE, B53_STRAP_VALUE, &strap_value);
+		/* use second IMP port if GMII is enabled */
+		if (strap_value & SV_GMII_CTRL_115)
+			dev->cpu_port = 5;
+	}
+
+	/* cpu port is always last */
+	dev->num_ports = dev->cpu_port + 1;
+	dev->enabled_ports |= BIT(dev->cpu_port);
+
+	dev->ports = devm_kzalloc(dev->dev,
+				  sizeof(struct b53_port) * dev->num_ports,
+				  GFP_KERNEL);
+	if (!dev->ports)
+		return -ENOMEM;
+
+	dev->reset_gpio = b53_switch_get_reset_gpio(dev);
+	if (dev->reset_gpio >= 0) {
+		ret = devm_gpio_request_one(dev->dev, dev->reset_gpio,
+					    GPIOF_OUT_INIT_HIGH, "robo_reset");
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+struct b53_device *b53_switch_alloc(struct device *base, struct b53_io_ops *ops,
+				    void *priv)
+{
+	struct dsa_switch *ds;
+	struct b53_device *dev;
+
+	ds = devm_kzalloc(base, sizeof(*ds) + sizeof(*dev), GFP_KERNEL);
+	if (!ds)
+		return NULL;
+
+	dev = (struct b53_device *)(ds + 1);
+
+	ds->priv = dev;
+	ds->dev = base;
+	dev->dev = base;
+
+	dev->ds = ds;
+	dev->priv = priv;
+	dev->ops = ops;
+	mutex_init(&dev->reg_mutex);
+	mutex_init(&dev->stats_mutex);
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
+		/* BCM5325 and BCM5365 do not have this register so reads
+		 * return 0. But the read operation did succeed, so assume this
+		 * is one of them.
+		 *
+		 * Next check if we can write to the 5325's VTA register; for
+		 * 5365 it is read only.
+		 */
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
+		case BCM53128_DEVICE_ID:
+		case BCM53010_DEVICE_ID:
+		case BCM53011_DEVICE_ID:
+		case BCM53012_DEVICE_ID:
+		case BCM53018_DEVICE_ID:
+		case BCM53019_DEVICE_ID:
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
+	}
+
+	if (!dev->chip_id && b53_switch_detect(dev))
+		return -EINVAL;
+
+	ret = b53_switch_init(dev);
+	if (ret)
+		return ret;
+
+	pr_info("found switch: %s, rev %i\n", dev->name, dev->core_rev);
+
+	return dsa_register_switch(dev->ds, dev->ds->dev->of_node);
+}
+EXPORT_SYMBOL(b53_switch_register);
+
+MODULE_AUTHOR("Jonas Gorski <jogo@openwrt.org>");
+MODULE_DESCRIPTION("B53 switch library");
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/dsa/b53/b53_mdio.c b/drivers/net/dsa/b53/b53_mdio.c
new file mode 100644
index 000000000000..c6cf7cf57cc3
--- /dev/null
+++ b/drivers/net/dsa/b53/b53_mdio.c
@@ -0,0 +1,381 @@
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
+#include <linux/delay.h>
+#include <linux/brcmphy.h>
+#include <linux/rtnetlink.h>
+#include <net/dsa.h>
+
+#include "b53_priv.h"
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
+		ret = mdiobus_write_nested(bus, BRCM_PSEUDO_PHY_ADDR,
+					   REG_MII_PAGE, v);
+		if (ret)
+			return ret;
+		dev->current_page = page;
+	}
+
+	/* set register address */
+	v = (reg << 8) | op;
+	ret = mdiobus_write_nested(bus, BRCM_PSEUDO_PHY_ADDR, REG_MII_ADDR, v);
+	if (ret)
+		return ret;
+
+	/* check if operation completed */
+	for (i = 0; i < 5; ++i) {
+		v = mdiobus_read_nested(bus, BRCM_PSEUDO_PHY_ADDR,
+					REG_MII_ADDR);
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
+	*val = mdiobus_read_nested(bus, BRCM_PSEUDO_PHY_ADDR,
+				   REG_MII_DATA0) & 0xff;
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
+	*val = mdiobus_read_nested(bus, BRCM_PSEUDO_PHY_ADDR, REG_MII_DATA0);
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
+	*val = mdiobus_read_nested(bus, BRCM_PSEUDO_PHY_ADDR, REG_MII_DATA0);
+	*val |= mdiobus_read_nested(bus, BRCM_PSEUDO_PHY_ADDR,
+				    REG_MII_DATA1) << 16;
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
+		temp |= mdiobus_read_nested(bus, BRCM_PSEUDO_PHY_ADDR,
+				     REG_MII_DATA0 + i);
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
+		temp |= mdiobus_read_nested(bus, BRCM_PSEUDO_PHY_ADDR,
+					    REG_MII_DATA0 + i);
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
+	ret = mdiobus_write_nested(bus, BRCM_PSEUDO_PHY_ADDR,
+				   REG_MII_DATA0, value);
+	if (ret)
+		return ret;
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static int b53_mdio_write16(struct b53_device *dev, u8 page, u8 reg,
+			    u16 value)
+{
+	struct mii_bus *bus = dev->priv;
+	int ret;
+
+	ret = mdiobus_write_nested(bus, BRCM_PSEUDO_PHY_ADDR,
+				   REG_MII_DATA0, value);
+	if (ret)
+		return ret;
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static int b53_mdio_write32(struct b53_device *dev, u8 page, u8 reg,
+			    u32 value)
+{
+	struct mii_bus *bus = dev->priv;
+	unsigned int i;
+	u32 temp = value;
+
+	for (i = 0; i < 2; i++) {
+		int ret = mdiobus_write_nested(bus, BRCM_PSEUDO_PHY_ADDR,
+					       REG_MII_DATA0 + i,
+					       temp & 0xffff);
+		if (ret)
+			return ret;
+		temp >>= 16;
+	}
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static int b53_mdio_write48(struct b53_device *dev, u8 page, u8 reg,
+			    u64 value)
+{
+	struct mii_bus *bus = dev->priv;
+	unsigned int i;
+	u64 temp = value;
+
+	for (i = 0; i < 3; i++) {
+		int ret = mdiobus_write_nested(bus, BRCM_PSEUDO_PHY_ADDR,
+					       REG_MII_DATA0 + i,
+					       temp & 0xffff);
+		if (ret)
+			return ret;
+		temp >>= 16;
+	}
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static int b53_mdio_write64(struct b53_device *dev, u8 page, u8 reg,
+			    u64 value)
+{
+	struct mii_bus *bus = dev->priv;
+	unsigned int i;
+	u64 temp = value;
+
+	for (i = 0; i < 4; i++) {
+		int ret = mdiobus_write_nested(bus, BRCM_PSEUDO_PHY_ADDR,
+					       REG_MII_DATA0 + i,
+					       temp & 0xffff);
+		if (ret)
+			return ret;
+		temp >>= 16;
+	}
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static int b53_mdio_phy_read16(struct b53_device *dev, int addr, int reg,
+			       u16 *value)
+{
+	struct mii_bus *bus = dev->priv;
+
+	*value = mdiobus_read_nested(bus, addr, reg);
+
+	return 0;
+}
+
+static int b53_mdio_phy_write16(struct b53_device *dev, int addr, int reg,
+				u16 value)
+{
+	struct mii_bus *bus = dev->bus;
+
+	return mdiobus_write_nested(bus, addr, reg, value);
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
+	.phy_read16 = b53_mdio_phy_read16,
+	.phy_write16 = b53_mdio_phy_write16,
+};
+
+#define B53_BRCM_OUI_1	0x0143bc00
+#define B53_BRCM_OUI_2	0x03625c00
+#define B53_BRCM_OUI_3	0x00406000
+
+static int b53_mdio_probe(struct mdio_device *mdiodev)
+{
+	struct b53_device *dev;
+	u32 phy_id;
+	int ret;
+
+	/* allow the generic PHY driver to take over the non-management MDIO
+	 * addresses
+	 */
+	if (mdiodev->addr != BRCM_PSEUDO_PHY_ADDR && mdiodev->addr != 0) {
+		dev_err(&mdiodev->dev, "leaving address %d to PHY\n",
+			mdiodev->addr);
+		return -ENODEV;
+	}
+
+	/* read the first port's id */
+	phy_id = mdiobus_read(mdiodev->bus, 0, 2) << 16;
+	phy_id |= mdiobus_read(mdiodev->bus, 0, 3);
+
+	/* BCM5325, BCM539x (OUI_1)
+	 * BCM53125, BCM53128 (OUI_2)
+	 * BCM5365 (OUI_3)
+	 */
+	if ((phy_id & 0xfffffc00) != B53_BRCM_OUI_1 &&
+	    (phy_id & 0xfffffc00) != B53_BRCM_OUI_2 &&
+	    (phy_id & 0xfffffc00) != B53_BRCM_OUI_3) {
+		dev_err(&mdiodev->dev, "Unsupported device: 0x%08x\n", phy_id);
+		return -ENODEV;
+	}
+
+	dev = b53_switch_alloc(&mdiodev->dev, &b53_mdio_ops, mdiodev->bus);
+	if (!dev)
+		return -ENOMEM;
+
+	/* we don't use page 0xff, so force a page set */
+	dev->current_page = 0xff;
+	dev->bus = mdiodev->bus;
+
+	dev_set_drvdata(&mdiodev->dev, dev);
+
+	ret = b53_switch_register(dev);
+	if (ret) {
+		dev_err(&mdiodev->dev, "failed to register switch: %i\n", ret);
+		return ret;
+	}
+
+	return ret;
+}
+
+static void b53_mdio_remove(struct mdio_device *mdiodev)
+{
+	struct b53_device *dev = dev_get_drvdata(&mdiodev->dev);
+	struct dsa_switch *ds = dev->ds;
+
+	dsa_unregister_switch(ds);
+}
+
+static const struct of_device_id b53_of_match[] = {
+	{ .compatible = "brcm,bcm5325" },
+	{ .compatible = "brcm,bcm53115" },
+	{ .compatible = "brcm,bcm53125" },
+	{ .compatible = "brcm,bcm53128" },
+	{ .compatible = "brcm,bcm5365" },
+	{ .compatible = "brcm,bcm5395" },
+	{ .compatible = "brcm,bcm5397" },
+	{ .compatible = "brcm,bcm5398" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, b53_of_match);
+
+static struct mdio_driver b53_mdio_driver = {
+	.probe	= b53_mdio_probe,
+	.remove	= b53_mdio_remove,
+	.mdiodrv.driver = {
+		.name = "bcm53xx",
+		.of_match_table = b53_of_match,
+	},
+};
+
+static int __init b53_mdio_driver_register(void)
+{
+	return mdio_driver_register(&b53_mdio_driver);
+}
+module_init(b53_mdio_driver_register);
+
+static void __exit b53_mdio_driver_unregister(void)
+{
+	mdio_driver_unregister(&b53_mdio_driver);
+}
+module_exit(b53_mdio_driver_unregister);
+
+MODULE_DESCRIPTION("B53 MDIO access driver");
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/dsa/b53/b53_mmap.c b/drivers/net/dsa/b53/b53_mmap.c
new file mode 100644
index 000000000000..f115ee25c0e8
--- /dev/null
+++ b/drivers/net/dsa/b53/b53_mmap.c
@@ -0,0 +1,260 @@
+/*
+ * B53 register access through memory mapped registers
+ *
+ * Copyright (C) 2012-2013 Jonas Gorski <jogo@openwrt.org>
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
+#include <linux/kconfig.h>
+#include <linux/module.h>
+#include <linux/io.h>
+#include <linux/platform_device.h>
+#include <linux/platform_data/b53.h>
+
+#include "b53_priv.h"
+
+struct b53_mmap_priv {
+	void __iomem *regs;
+};
+
+static int b53_mmap_read8(struct b53_device *dev, u8 page, u8 reg, u8 *val)
+{
+	u8 __iomem *regs = dev->priv;
+
+	*val = readb(regs + (page << 8) + reg);
+
+	return 0;
+}
+
+static int b53_mmap_read16(struct b53_device *dev, u8 page, u8 reg, u16 *val)
+{
+	u8 __iomem *regs = dev->priv;
+
+	if (WARN_ON(reg % 2))
+		return -EINVAL;
+
+	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN) && dev->pdata &&
+	    dev->pdata->big_endian)
+		*val = __raw_readw(regs + (page << 8) + reg);
+	else
+		*val = readw(regs + (page << 8) + reg);
+
+	return 0;
+}
+
+static int b53_mmap_read32(struct b53_device *dev, u8 page, u8 reg, u32 *val)
+{
+	u8 __iomem *regs = dev->priv;
+
+	if (WARN_ON(reg % 4))
+		return -EINVAL;
+
+	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN) && dev->pdata &&
+	    dev->pdata->big_endian)
+		*val = __raw_readl(regs + (page << 8) + reg);
+	else
+		*val = readl(regs + (page << 8) + reg);
+
+	return 0;
+}
+
+static int b53_mmap_read48(struct b53_device *dev, u8 page, u8 reg, u64 *val)
+{
+	if (WARN_ON(reg % 2))
+		return -EINVAL;
+
+	if (reg % 4) {
+		u16 lo;
+		u32 hi;
+
+		b53_mmap_read16(dev, page, reg, &lo);
+		b53_mmap_read32(dev, page, reg + 2, &hi);
+
+		*val = ((u64)hi << 16) | lo;
+	} else {
+		u32 lo;
+		u16 hi;
+
+		b53_mmap_read32(dev, page, reg, &lo);
+		b53_mmap_read16(dev, page, reg + 4, &hi);
+
+		*val = ((u64)hi << 32) | lo;
+	}
+
+	return 0;
+}
+
+static int b53_mmap_read64(struct b53_device *dev, u8 page, u8 reg, u64 *val)
+{
+	u32 hi, lo;
+
+	if (WARN_ON(reg % 4))
+		return -EINVAL;
+
+	b53_mmap_read32(dev, page, reg, &lo);
+	b53_mmap_read32(dev, page, reg + 4, &hi);
+
+	*val = ((u64)hi << 32) | lo;
+
+	return 0;
+}
+
+static int b53_mmap_write8(struct b53_device *dev, u8 page, u8 reg, u8 value)
+{
+	u8 __iomem *regs = dev->priv;
+
+	writeb(value, regs + (page << 8) + reg);
+
+	return 0;
+}
+
+static int b53_mmap_write16(struct b53_device *dev, u8 page, u8 reg,
+			    u16 value)
+{
+	u8 __iomem *regs = dev->priv;
+
+	if (WARN_ON(reg % 2))
+		return -EINVAL;
+
+	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN) && dev->pdata &&
+	    dev->pdata->big_endian)
+		__raw_writew(value, regs + (page << 8) + reg);
+	else
+		writew(value, regs + (page << 8) + reg);
+
+	return 0;
+}
+
+static int b53_mmap_write32(struct b53_device *dev, u8 page, u8 reg,
+			    u32 value)
+{
+	u8 __iomem *regs = dev->priv;
+
+	if (WARN_ON(reg % 4))
+		return -EINVAL;
+
+	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN) && dev->pdata &&
+	    dev->pdata->big_endian)
+		__raw_writel(value, regs + (page << 8) + reg);
+	else
+		writel(value, regs + (page << 8) + reg);
+
+	return 0;
+}
+
+static int b53_mmap_write48(struct b53_device *dev, u8 page, u8 reg,
+			    u64 value)
+{
+	if (WARN_ON(reg % 2))
+		return -EINVAL;
+
+	if (reg % 4) {
+		u32 hi = (u32)(value >> 16);
+		u16 lo = (u16)value;
+
+		b53_mmap_write16(dev, page, reg, lo);
+		b53_mmap_write32(dev, page, reg + 2, hi);
+	} else {
+		u16 hi = (u16)(value >> 32);
+		u32 lo = (u32)value;
+
+		b53_mmap_write32(dev, page, reg, lo);
+		b53_mmap_write16(dev, page, reg + 4, hi);
+	}
+
+	return 0;
+}
+
+static int b53_mmap_write64(struct b53_device *dev, u8 page, u8 reg,
+			    u64 value)
+{
+	u32 hi, lo;
+
+	hi = upper_32_bits(value);
+	lo = lower_32_bits(value);
+
+	if (WARN_ON(reg % 4))
+		return -EINVAL;
+
+	b53_mmap_write32(dev, page, reg, lo);
+	b53_mmap_write32(dev, page, reg + 4, hi);
+
+	return 0;
+}
+
+static struct b53_io_ops b53_mmap_ops = {
+	.read8 = b53_mmap_read8,
+	.read16 = b53_mmap_read16,
+	.read32 = b53_mmap_read32,
+	.read48 = b53_mmap_read48,
+	.read64 = b53_mmap_read64,
+	.write8 = b53_mmap_write8,
+	.write16 = b53_mmap_write16,
+	.write32 = b53_mmap_write32,
+	.write48 = b53_mmap_write48,
+	.write64 = b53_mmap_write64,
+};
+
+static int b53_mmap_probe(struct platform_device *pdev)
+{
+	struct b53_platform_data *pdata = pdev->dev.platform_data;
+	struct b53_device *dev;
+
+	if (!pdata)
+		return -EINVAL;
+
+	dev = b53_switch_alloc(&pdev->dev, &b53_mmap_ops, pdata->regs);
+	if (!dev)
+		return -ENOMEM;
+
+	if (pdata)
+		dev->pdata = pdata;
+
+	platform_set_drvdata(pdev, dev);
+
+	return b53_switch_register(dev);
+}
+
+static int b53_mmap_remove(struct platform_device *pdev)
+{
+	struct b53_device *dev = platform_get_drvdata(pdev);
+
+	if (dev)
+		b53_switch_remove(dev);
+
+	return 0;
+}
+
+static const struct of_device_id b53_mmap_of_table[] = {
+	{ .compatible = "brcm,bcm3384-switch" },
+	{ .compatible = "brcm,bcm6328-switch" },
+	{ .compatible = "brcm,bcm6368-switch" },
+	{ .compatible = "brcm,bcm63xx-switch" },
+	{ /* sentinel */ },
+};
+
+static struct platform_driver b53_mmap_driver = {
+	.probe = b53_mmap_probe,
+	.remove = b53_mmap_remove,
+	.driver = {
+		.name = "b53-switch",
+		.of_match_table = b53_mmap_of_table,
+	},
+};
+
+module_platform_driver(b53_mmap_driver);
+MODULE_AUTHOR("Jonas Gorski <jogo@openwrt.org>");
+MODULE_DESCRIPTION("B53 MMAP access driver");
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
new file mode 100644
index 000000000000..c4844155546b
--- /dev/null
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -0,0 +1,322 @@
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
+#include <linux/phy.h>
+#include <net/dsa.h>
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
+	int (*phy_read16)(struct b53_device *dev, int addr, int reg, u16 *value);
+	int (*phy_write16)(struct b53_device *dev, int addr, int reg, u16 value);
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
+	BCM53128_DEVICE_ID = 0x53128,
+	BCM63XX_DEVICE_ID = 0x6300,
+	BCM53010_DEVICE_ID = 0x53010,
+	BCM53011_DEVICE_ID = 0x53011,
+	BCM53012_DEVICE_ID = 0x53012,
+	BCM53018_DEVICE_ID = 0x53018,
+	BCM53019_DEVICE_ID = 0x53019,
+};
+
+#define B53_N_PORTS	9
+#define B53_N_PORTS_25	6
+
+struct b53_port {
+};
+
+struct b53_device {
+	struct dsa_switch *ds;
+	struct b53_platform_data *pdata;
+	const char *name;
+
+	struct mutex reg_mutex;
+	struct mutex stats_mutex;
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
+	unsigned int cpu_port;
+
+	/* connect specific data */
+	u8 current_page;
+	struct device *dev;
+
+	/* Master MDIO bus we got probed from */
+	struct mii_bus *bus;
+
+	/* Slave MDIO bus we created */
+	struct mii_bus *slave_bus;
+	void *priv;
+
+	/* run time configuration */
+	unsigned enable_jumbo:1;
+	unsigned allow_vid_4095:1;
+	unsigned int num_vlans;
+	unsigned int num_ports;
+	struct b53_port *ports;
+};
+
+#define b53_for_each_port(dev, i) \
+	for (i = 0; i < B53_N_PORTS; i++) \
+		if (dev->enabled_ports & BIT(i))
+
+
+static inline int is5325(struct b53_device *dev)
+{
+	return dev->chip_id == BCM5325_DEVICE_ID;
+}
+
+static inline int is5365(struct b53_device *dev)
+{
+#ifdef CONFIG_BCM47XX
+	return dev->chip_id == BCM5365_DEVICE_ID;
+#else
+	return 0;
+#endif
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
+		dev->chip_id == BCM53125_DEVICE_ID ||
+		dev->chip_id == BCM53128_DEVICE_ID;
+}
+
+static inline int is63xx(struct b53_device *dev)
+{
+#ifdef CONFIG_BCM63XX
+	return dev->chip_id == BCM63XX_DEVICE_ID;
+#else
+	return 0;
+#endif
+}
+
+static inline int is5301x(struct b53_device *dev)
+{
+	return dev->chip_id == BCM53010_DEVICE_ID ||
+		dev->chip_id == BCM53011_DEVICE_ID ||
+		dev->chip_id == BCM53012_DEVICE_ID ||
+		dev->chip_id == BCM53018_DEVICE_ID ||
+		dev->chip_id == BCM53019_DEVICE_ID;
+}
+
+#define B53_CPU_PORT_25	5
+#define B53_CPU_PORT	8
+
+static inline int is_cpu_port(struct b53_device *dev, int port)
+{
+	return dev->cpu_port;
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
+	dsa_unregister_switch(dev->ds);
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
+#ifdef CONFIG_BCM47XX
+
+#include <linux/version.h>
+#include <linux/bcm47xx_nvram.h>
+#include <bcm47xx_board.h>
+static inline int b53_switch_get_reset_gpio(struct b53_device *dev)
+{
+	enum bcm47xx_board board = bcm47xx_board_get();
+
+	switch (board) {
+	case BCM47XX_BOARD_LINKSYS_WRT300NV11:
+	case BCM47XX_BOARD_LINKSYS_WRT310NV1:
+		return 8;
+	default:
+		return bcm47xx_nvram_gpio_pin("robo_reset");
+	}
+}
+#else
+static inline int b53_switch_get_reset_gpio(struct b53_device *dev)
+{
+	return -ENOENT;
+}
+#endif
+#endif
diff --git a/drivers/net/dsa/b53/b53_regs.h b/drivers/net/dsa/b53/b53_regs.h
new file mode 100644
index 000000000000..ccf8af7717d3
--- /dev/null
+++ b/drivers/net/dsa/b53/b53_regs.h
@@ -0,0 +1,358 @@
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
+#define B53_PORT_MII_PAGE(i)		(0x10 + (i)) /* Port i MII Registers */
+#define B53_IM_PORT_PAGE		0x18 /* Inverse MII Port (to EMAC) */
+#define B53_ALL_PORT_PAGE		0x19 /* All ports MII (broadcast) */
+
+/* MIB registers */
+#define B53_MIB_PAGE(i)			(0x20 + (i))
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
+/* CFP Configuration Registers Page */
+#define B53_CFP_PAGE			0xa1
+
+/*************************************************************************
+ * Control Page registers
+ *************************************************************************/
+
+/* Port Control Register (8 bit) */
+#define B53_PORT_CTRL(i)		(0x00 + (i))
+#define   PORT_CTRL_RX_DISABLE		BIT(0)
+#define   PORT_CTRL_TX_DISABLE		BIT(1)
+#define   PORT_CTRL_RX_BCST_EN		BIT(2) /* Broadcast RX (P8 only) */
+#define   PORT_CTRL_RX_MCST_EN		BIT(3) /* Multicast RX (P8 only) */
+#define   PORT_CTRL_RX_UCST_EN		BIT(4) /* Unicast RX (P8 only) */
+#define	  PORT_CTRL_STP_STATE_S		5
+#define   PORT_CTRL_STP_STATE_MASK	(0x7 << PORT_CTRL_STP_STATE_S)
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
+#define   PORT_OVERRIDE_FULL_DUPLEX	BIT(1) /* 0 = Half Duplex */
+#define   PORT_OVERRIDE_SPEED_S		2
+#define   PORT_OVERRIDE_SPEED_10M	(0 << PORT_OVERRIDE_SPEED_S)
+#define   PORT_OVERRIDE_SPEED_100M	(1 << PORT_OVERRIDE_SPEED_S)
+#define   PORT_OVERRIDE_SPEED_1000M	(2 << PORT_OVERRIDE_SPEED_S)
+#define   PORT_OVERRIDE_RV_MII_25	BIT(4) /* BCM5325 only */
+#define   PORT_OVERRIDE_RX_FLOW		BIT(4)
+#define   PORT_OVERRIDE_TX_FLOW		BIT(5)
+#define   PORT_OVERRIDE_SPEED_2000M	BIT(6) /* BCM5301X only, requires setting 1000M */
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
+/*
+ * Override Ports 0-7 State on devices with xMII interfaces (8 bit)
+ *
+ * For port 8 still use B53_PORT_OVERRIDE_CTRL
+ * Please note that not all ports are available on every hardware, e.g. BCM5301X
+ * don't include overriding port 6, BCM63xx also have some limitations.
+ */
+#define B53_GMII_PORT_OVERRIDE_CTRL(i)	(0x58 + (i))
+#define   GMII_PO_LINK			BIT(0)
+#define   GMII_PO_FULL_DUPLEX		BIT(1) /* 0 = Half Duplex */
+#define   GMII_PO_SPEED_S		2
+#define   GMII_PO_SPEED_10M		(0 << GMII_PO_SPEED_S)
+#define   GMII_PO_SPEED_100M		(1 << GMII_PO_SPEED_S)
+#define   GMII_PO_SPEED_1000M		(2 << GMII_PO_SPEED_S)
+#define   GMII_PO_RX_FLOW		BIT(4)
+#define   GMII_PO_TX_FLOW		BIT(5)
+#define   GMII_PO_EN			BIT(6) /* Use the register contents */
+#define   GMII_PO_SPEED_2000M		BIT(7) /* BCM5301X only, requires setting 1000M */
+
+#define B53_RGMII_CTRL_IMP		0x60
+#define   RGMII_CTRL_ENABLE_GMII	BIT(7)
+#define   RGMII_CTRL_TIMING_SEL		BIT(2)
+#define   RGMII_CTRL_DLL_RXC		BIT(1)
+#define   RGMII_CTRL_DLL_TXC		BIT(0)
+
+#define B53_RGMII_CTRL_P(i)		(B53_RGMII_CTRL_IMP + (i))
+
+/* Software reset register (8 bit) */
+#define B53_SOFTRESET			0x79
+#define   SW_RST			BIT(7)
+#define   EN_SW_RST			BIT(4)
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
+/* Broadcom Header control register (8 bit) */
+#define B53_BRCM_HDR			0x03
+#define   BRCM_HDR_P8_EN		BIT(0) /* Enable tagging on port 8 */
+#define   BRCM_HDR_P5_EN		BIT(1) /* Enable tagging on port 5 */
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
+#define   VA_UNTAG_S_25			6
+#define   VA_UNTAG_MASK_25		0x3f
+#define   VA_UNTAG_S_65			7
+#define   VA_UNTAG_MASK_65		0x1f
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
+/*************************************************************************
+ * CFP Configuration Page Registers
+ *************************************************************************/
+
+/* CFP Control Register with ports map (8 bit) */
+#define B53_CFP_CTRL			0x00
+
+#endif /* !__B53_REGS_H */
diff --git a/drivers/net/dsa/b53/b53_spi.c b/drivers/net/dsa/b53/b53_spi.c
new file mode 100644
index 000000000000..2bda0b5f1578
--- /dev/null
+++ b/drivers/net/dsa/b53/b53_spi.c
@@ -0,0 +1,331 @@
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
+#include <linux/delay.h>
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
+				   unsigned int len)
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
+
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
+			unsigned int len)
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
+
+	if (!ret)
+		*val = le16_to_cpu(*val);
+
+	return ret;
+}
+
+static int b53_spi_read32(struct b53_device *dev, u8 page, u8 reg, u32 *val)
+{
+	int ret = b53_spi_read(dev, page, reg, (u8 *)val, 4);
+
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
+
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
+	spi_set_drvdata(spi, dev);
+
+	return 0;
+}
+
+static int b53_spi_remove(struct spi_device *spi)
+{
+	struct b53_device *dev = spi_get_drvdata(spi);
+
+	if (dev)
+		b53_switch_remove(dev);
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
diff --git a/drivers/net/dsa/b53/b53_srab.c b/drivers/net/dsa/b53/b53_srab.c
new file mode 100644
index 000000000000..70fd47284535
--- /dev/null
+++ b/drivers/net/dsa/b53/b53_srab.c
@@ -0,0 +1,415 @@
+/*
+ * B53 register access through Switch Register Access Bridge Registers
+ *
+ * Copyright (C) 2013 Hauke Mehrtens <hauke@hauke-m.de>
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
+#include <linux/module.h>
+#include <linux/delay.h>
+#include <linux/platform_device.h>
+#include <linux/platform_data/b53.h>
+
+#include "b53_priv.h"
+
+/* command and status register of the SRAB */
+#define B53_SRAB_CMDSTAT		0x2c
+#define  B53_SRAB_CMDSTAT_RST		BIT(2)
+#define  B53_SRAB_CMDSTAT_WRITE		BIT(1)
+#define  B53_SRAB_CMDSTAT_GORDYN	BIT(0)
+#define  B53_SRAB_CMDSTAT_PAGE		24
+#define  B53_SRAB_CMDSTAT_REG		16
+
+/* high order word of write data to switch registe */
+#define B53_SRAB_WD_H			0x30
+
+/* low order word of write data to switch registe */
+#define B53_SRAB_WD_L			0x34
+
+/* high order word of read data from switch register */
+#define B53_SRAB_RD_H			0x38
+
+/* low order word of read data from switch register */
+#define B53_SRAB_RD_L			0x3c
+
+/* command and status register of the SRAB */
+#define B53_SRAB_CTRLS			0x40
+#define  B53_SRAB_CTRLS_RCAREQ		BIT(3)
+#define  B53_SRAB_CTRLS_RCAGNT		BIT(4)
+#define  B53_SRAB_CTRLS_SW_INIT_DONE	BIT(6)
+
+/* the register captures interrupt pulses from the switch */
+#define B53_SRAB_INTR			0x44
+#define  B53_SRAB_INTR_P(x)		BIT(x)
+#define  B53_SRAB_SWITCH_PHY		BIT(8)
+#define  B53_SRAB_1588_SYNC		BIT(9)
+#define  B53_SRAB_IMP1_SLEEP_TIMER	BIT(10)
+#define  B53_SRAB_P7_SLEEP_TIMER	BIT(11)
+#define  B53_SRAB_IMP0_SLEEP_TIMER	BIT(12)
+
+struct b53_srab_priv {
+	void __iomem *regs;
+};
+
+static int b53_srab_request_grant(struct b53_device *dev)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	u32 ctrls;
+	int i;
+
+	ctrls = readl(regs + B53_SRAB_CTRLS);
+	ctrls |= B53_SRAB_CTRLS_RCAREQ;
+	writel(ctrls, regs + B53_SRAB_CTRLS);
+
+	for (i = 0; i < 20; i++) {
+		ctrls = readl(regs + B53_SRAB_CTRLS);
+		if (ctrls & B53_SRAB_CTRLS_RCAGNT)
+			break;
+		usleep_range(10, 100);
+	}
+	if (WARN_ON(i == 5))
+		return -EIO;
+
+	return 0;
+}
+
+static void b53_srab_release_grant(struct b53_device *dev)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	u32 ctrls;
+
+	ctrls = readl(regs + B53_SRAB_CTRLS);
+	ctrls &= ~B53_SRAB_CTRLS_RCAREQ;
+	writel(ctrls, regs + B53_SRAB_CTRLS);
+}
+
+static int b53_srab_op(struct b53_device *dev, u8 page, u8 reg, u32 op)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	int i;
+	u32 cmdstat;
+
+	/* set register address */
+	cmdstat = (page << B53_SRAB_CMDSTAT_PAGE) |
+		  (reg << B53_SRAB_CMDSTAT_REG) |
+		  B53_SRAB_CMDSTAT_GORDYN |
+		  op;
+	writel(cmdstat, regs + B53_SRAB_CMDSTAT);
+
+	/* check if operation completed */
+	for (i = 0; i < 5; ++i) {
+		cmdstat = readl(regs + B53_SRAB_CMDSTAT);
+		if (!(cmdstat & B53_SRAB_CMDSTAT_GORDYN))
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
+static int b53_srab_read8(struct b53_device *dev, u8 page, u8 reg, u8 *val)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	int ret = 0;
+
+	ret = b53_srab_request_grant(dev);
+	if (ret)
+		goto err;
+
+	ret = b53_srab_op(dev, page, reg, 0);
+	if (ret)
+		goto err;
+
+	*val = readl(regs + B53_SRAB_RD_L) & 0xff;
+
+err:
+	b53_srab_release_grant(dev);
+
+	return ret;
+}
+
+static int b53_srab_read16(struct b53_device *dev, u8 page, u8 reg, u16 *val)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	int ret = 0;
+
+	ret = b53_srab_request_grant(dev);
+	if (ret)
+		goto err;
+
+	ret = b53_srab_op(dev, page, reg, 0);
+	if (ret)
+		goto err;
+
+	*val = readl(regs + B53_SRAB_RD_L) & 0xffff;
+
+err:
+	b53_srab_release_grant(dev);
+
+	return ret;
+}
+
+static int b53_srab_read32(struct b53_device *dev, u8 page, u8 reg, u32 *val)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	int ret = 0;
+
+	ret = b53_srab_request_grant(dev);
+	if (ret)
+		goto err;
+
+	ret = b53_srab_op(dev, page, reg, 0);
+	if (ret)
+		goto err;
+
+	*val = readl(regs + B53_SRAB_RD_L);
+
+err:
+	b53_srab_release_grant(dev);
+
+	return ret;
+}
+
+static int b53_srab_read48(struct b53_device *dev, u8 page, u8 reg, u64 *val)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	int ret = 0;
+
+	ret = b53_srab_request_grant(dev);
+	if (ret)
+		goto err;
+
+	ret = b53_srab_op(dev, page, reg, 0);
+	if (ret)
+		goto err;
+
+	*val = readl(regs + B53_SRAB_RD_L);
+	*val += ((u64)readl(regs + B53_SRAB_RD_H) & 0xffff) << 32;
+
+err:
+	b53_srab_release_grant(dev);
+
+	return ret;
+}
+
+static int b53_srab_read64(struct b53_device *dev, u8 page, u8 reg, u64 *val)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	int ret = 0;
+
+	ret = b53_srab_request_grant(dev);
+	if (ret)
+		goto err;
+
+	ret = b53_srab_op(dev, page, reg, 0);
+	if (ret)
+		goto err;
+
+	*val = readl(regs + B53_SRAB_RD_L);
+	*val += (u64)readl(regs + B53_SRAB_RD_H) << 32;
+
+err:
+	b53_srab_release_grant(dev);
+
+	return ret;
+}
+
+static int b53_srab_write8(struct b53_device *dev, u8 page, u8 reg, u8 value)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	int ret = 0;
+
+	ret = b53_srab_request_grant(dev);
+	if (ret)
+		goto err;
+
+	writel(value, regs + B53_SRAB_WD_L);
+
+	ret = b53_srab_op(dev, page, reg, B53_SRAB_CMDSTAT_WRITE);
+
+err:
+	b53_srab_release_grant(dev);
+
+	return ret;
+}
+
+static int b53_srab_write16(struct b53_device *dev, u8 page, u8 reg,
+			    u16 value)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	int ret = 0;
+
+	ret = b53_srab_request_grant(dev);
+	if (ret)
+		goto err;
+
+	writel(value, regs + B53_SRAB_WD_L);
+
+	ret = b53_srab_op(dev, page, reg, B53_SRAB_CMDSTAT_WRITE);
+
+err:
+	b53_srab_release_grant(dev);
+
+	return ret;
+}
+
+static int b53_srab_write32(struct b53_device *dev, u8 page, u8 reg,
+			    u32 value)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	int ret = 0;
+
+	ret = b53_srab_request_grant(dev);
+	if (ret)
+		goto err;
+
+	writel(value, regs + B53_SRAB_WD_L);
+
+	ret = b53_srab_op(dev, page, reg, B53_SRAB_CMDSTAT_WRITE);
+
+err:
+	b53_srab_release_grant(dev);
+
+	return ret;
+}
+
+static int b53_srab_write48(struct b53_device *dev, u8 page, u8 reg,
+			    u64 value)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	int ret = 0;
+
+	ret = b53_srab_request_grant(dev);
+	if (ret)
+		goto err;
+
+	writel((u32)value, regs + B53_SRAB_WD_L);
+	writel((u16)(value >> 32), regs + B53_SRAB_WD_H);
+
+	ret = b53_srab_op(dev, page, reg, B53_SRAB_CMDSTAT_WRITE);
+
+err:
+	b53_srab_release_grant(dev);
+
+	return ret;
+}
+
+static int b53_srab_write64(struct b53_device *dev, u8 page, u8 reg,
+			    u64 value)
+{
+	struct b53_srab_priv *priv = dev->priv;
+	u8 __iomem *regs = priv->regs;
+	int ret = 0;
+
+	ret = b53_srab_request_grant(dev);
+	if (ret)
+		goto err;
+
+	writel((u32)value, regs + B53_SRAB_WD_L);
+	writel((u32)(value >> 32), regs + B53_SRAB_WD_H);
+
+	ret = b53_srab_op(dev, page, reg, B53_SRAB_CMDSTAT_WRITE);
+
+err:
+	b53_srab_release_grant(dev);
+
+	return ret;
+}
+
+static struct b53_io_ops b53_srab_ops = {
+	.read8 = b53_srab_read8,
+	.read16 = b53_srab_read16,
+	.read32 = b53_srab_read32,
+	.read48 = b53_srab_read48,
+	.read64 = b53_srab_read64,
+	.write8 = b53_srab_write8,
+	.write16 = b53_srab_write16,
+	.write32 = b53_srab_write32,
+	.write48 = b53_srab_write48,
+	.write64 = b53_srab_write64,
+};
+
+static int b53_srab_probe(struct platform_device *pdev)
+{
+	struct b53_srab_priv *priv;
+	struct b53_device *dev;
+	struct resource *r;
+
+	priv = devm_kzalloc(&pdev->dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	priv->regs = devm_ioremap_resource(&pdev->dev, r);
+	if (IS_ERR(priv->regs))
+		return -ENOMEM;
+
+	dev = b53_switch_alloc(&pdev->dev, &b53_srab_ops, priv);
+	if (!dev)
+		return -ENOMEM;
+
+	platform_set_drvdata(pdev, dev);
+
+	return b53_switch_register(dev);
+}
+
+static int b53_srab_remove(struct platform_device *pdev)
+{
+	struct b53_device *dev = platform_get_drvdata(pdev);
+
+	if (dev)
+		b53_switch_remove(dev);
+
+	return 0;
+}
+
+static const struct of_device_id b53_srab_of_match[] = {
+	{ .compatible = "brcm,bcm53010-srab" },
+	{ .compatible = "brcm,bcm53011-srab" },
+	{ .compatible = "brcm,bcm53012-srab" },
+	{ .compatible = "brcm,bcm53018-srab" },
+	{ .compatible = "brcm,bcm53019-srab" },
+	{ .compatible = "brcm,bcm5301x-srab" },
+	{ /* sentinel */ },
+};
+
+static struct platform_driver b53_srab_driver = {
+	.probe = b53_srab_probe,
+	.remove = b53_srab_remove,
+	.driver = {
+		.name = "b53-srab-switch",
+		.of_match_table = b53_srab_of_match,
+	},
+};
+
+module_platform_driver(b53_srab_driver);
+MODULE_AUTHOR("Hauke Mehrtens <hauke@hauke-m.de>");
+MODULE_DESCRIPTION("B53 Switch Register Access Bridge Registers (SRAB) access driver");
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/include/linux/platform_data/b53.h b/include/linux/platform_data/b53.h
new file mode 100644
index 000000000000..69d279c0da96
--- /dev/null
+++ b/include/linux/platform_data/b53.h
@@ -0,0 +1,33 @@
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
+	/* only used by MMAP'd driver */
+	unsigned big_endian:1;
+	void __iomem *regs;
+};
+
+#endif
-- 
2.7.4
