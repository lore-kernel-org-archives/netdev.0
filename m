From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Tue, 24 Feb 2015 18:42:07 +0100
Message-ID: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jonas Gorski <jogo@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:47095 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbbBXRoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 12:44:08 -0500
Received: by wevm14 with SMTP id m14so26698121wev.13
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 09:44:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BCM53xx is series of Broadcom Ethernet switches that can be found in
various (mostly home) routers.
They are quite simple switches with mainly just support for:
1) Tagging incoming packets (PVID)
2) Untagging outgoing packets
3) Forwarding all packets across a single VLAN

This driver is split into common code (module) and bus specific code.
Right now only PHY (MDIO) support is included, other could follow after
accepting this driver. It was successfully tested on BCM4706 SoC with
BCM53125.

You could notice it's yet another try of submitting b53 driver. This
time it was modified to use recently introduced switchdev API which
hopefully make it possible to accept it mainline.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
Example usage. My BCM4706 router has switch with 6 ports:
0: WAN port
1-4: LAN ports
8: CPU connected port (on-SoC Ethernet device)

I decided to use VLAN 1 for WAN and VLAN 2 for LAN. I was able to
successfully configure it using:

bridge vlan add vid 1 dev sw0p1 pvid untagged
bridge vlan add vid 1 dev sw0p2 pvid untagged
bridge vlan add vid 1 dev sw0p3 pvid untagged
bridge vlan add vid 1 dev sw0p4 pvid untagged
bridge vlan add vid 1 dev sw0p8

bridge vlan add vid 2 dev sw0p0 pvid untagged
bridge vlan add vid 2 dev sw0p8
---
 drivers/net/phy/Kconfig          |   2 +
 drivers/net/phy/Makefile         |   1 +
 drivers/net/phy/b53/Kconfig      |  12 +
 drivers/net/phy/b53/Makefile     |   2 +
 drivers/net/phy/b53/b53_common.c | 961 +++++++++++++++++++++++++++++++=
++++++++
 drivers/net/phy/b53/b53_mdio.c   | 418 +++++++++++++++++
 drivers/net/phy/b53/b53_priv.h   | 299 ++++++++++++
 drivers/net/phy/b53/b53_regs.h   | 313 +++++++++++++
 8 files changed, 2008 insertions(+)
 create mode 100644 drivers/net/phy/b53/Kconfig
 create mode 100644 drivers/net/phy/b53/Makefile
 create mode 100644 drivers/net/phy/b53/b53_common.c
 create mode 100644 drivers/net/phy/b53/b53_mdio.c
 create mode 100644 drivers/net/phy/b53/b53_priv.h
 create mode 100644 drivers/net/phy/b53/b53_regs.h

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 16adbc4..fc8554a 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -212,6 +212,8 @@ config MDIO_BCM_UNIMAC
 	  controllers as well as some Broadcom Ethernet switches such as the
 	  Starfighter 2 switches.
=20
+source "drivers/net/phy/b53/Kconfig"
+
 endif # PHYLIB
=20
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 501ea76..3e8b3b7 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_LXT_PHY)		+=3D lxt.o
 obj-$(CONFIG_QSEMI_PHY)		+=3D qsemi.o
 obj-$(CONFIG_SMSC_PHY)		+=3D smsc.o
 obj-$(CONFIG_VITESSE_PHY)	+=3D vitesse.o
+obj-$(CONFIG_B53)		+=3D b53/
 obj-$(CONFIG_BROADCOM_PHY)	+=3D broadcom.o
 obj-$(CONFIG_BCM63XX_PHY)	+=3D bcm63xx.o
 obj-$(CONFIG_BCM7XXX_PHY)	+=3D bcm7xxx.o
diff --git a/drivers/net/phy/b53/Kconfig b/drivers/net/phy/b53/Kconfig
new file mode 100644
index 0000000..21bf6e7
--- /dev/null
+++ b/drivers/net/phy/b53/Kconfig
@@ -0,0 +1,12 @@
+menuconfig B53
+	tristate "Broadcom bcm53xx managed switch support"
+	help
+	  This driver adds support for Broadcom managed switch chips. It supp=
orts
+	  BCM5325E, BCM5365, BCM539x, BCM53115 and BCM53125 as well as BCM63X=
X
+	  integrated switches.
+
+config B53_PHY_DRIVER
+	tristate "B53 MDIO connected switch driver"
+	depends on B53
+	help
+	  Select to enable support for registering switches configured throug=
h MDIO.
diff --git a/drivers/net/phy/b53/Makefile b/drivers/net/phy/b53/Makefil=
e
new file mode 100644
index 0000000..33d995b
--- /dev/null
+++ b/drivers/net/phy/b53/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_B53)		+=3D b53_common.o
+obj-$(CONFIG_B53_PHY_DRIVER)	+=3D b53_mdio.o
diff --git a/drivers/net/phy/b53/b53_common.c b/drivers/net/phy/b53/b53=
_common.c
new file mode 100644
index 0000000..fce6b71
--- /dev/null
+++ b/drivers/net/phy/b53/b53_common.c
@@ -0,0 +1,961 @@
+/*
+ * B53 switch driver main logic
+ *
+ * Copyright (C) 2011-2013 Jonas Gorski <jogo@openwrt.org>
+ *
+ * Permission to use, copy, modify, and/or distribute this software fo=
r any
+ * purpose with or without fee is hereby granted, provided that the ab=
ove
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRA=
NTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE=
 FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMA=
GES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN =
AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OU=
T OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/slab.h>
+
+#include <linux/delay.h>
+#include <linux/device.h>
+#include <linux/etherdevice.h>
+#include <linux/export.h>
+#include <linux/gpio.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <net/netlink.h>
+#include <uapi/linux/if_bridge.h>
+#include <uapi/linux/rtnetlink.h>
+
+#include "b53_regs.h"
+#include "b53_priv.h"
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
+};
+
+static int b53_do_vlan_op(struct b53_device *dev, u8 op)
+{
+	unsigned int i;
+
+	b53_write8(dev, B53_ARLIO_PAGE, dev->chip->vta_regs[0],
+		   VTA_START_CMD | op);
+
+	for (i =3D 0; i < 10; i++) {
+		u8 vta;
+
+		b53_read8(dev, B53_ARLIO_PAGE, dev->chip->vta_regs[0], &vta);
+		if (!(vta & VTA_START_CMD))
+			return 0;
+
+		usleep_range(100, 200);
+	}
+
+	return -EIO;
+}
+
+static void b53_set_vlan_entry(struct b53_device *dev, u16 vid, u16 me=
mbers,
+			       u16 untag)
+{
+	if (is5325(dev)) {
+		u32 entry =3D 0;
+
+		if (members) {
+			entry =3D ((untag & VA_UNTAG_MASK_25) << VA_UNTAG_S_25) |
+				members;
+			if (dev->core_rev >=3D 3)
+				entry |=3D VA_VALID_25_R4 | vid << VA_VID_HIGH_S;
+			else
+				entry |=3D VA_VALID_25;
+		}
+
+		b53_write32(dev, B53_VLAN_PAGE, B53_VLAN_WRITE_25, entry);
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_TABLE_ACCESS_25, vid |
+			    VTA_RW_STATE_WR | VTA_RW_OP_EN);
+	} else if (is5365(dev)) {
+		u16 entry =3D 0;
+
+		if (members)
+			entry =3D ((untag & VA_UNTAG_MASK_65) << VA_UNTAG_S_65) |
+				members | VA_VALID_65;
+
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_WRITE_65, entry);
+		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_TABLE_ACCESS_65, vid |
+			    VTA_RW_STATE_WR | VTA_RW_OP_EN);
+	} else {
+		b53_write16(dev, B53_ARLIO_PAGE, dev->chip->vta_regs[1], vid);
+		b53_write32(dev, B53_ARLIO_PAGE, dev->chip->vta_regs[2],
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
+		mgmt |=3D SM_SW_FWD_EN;
+	else
+		mgmt &=3D ~SM_SW_FWD_EN;
+
+	b53_write8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, mgmt);
+}
+
+static void b53_enable_vlan(struct b53_device *dev, int enable)
+{
+	u8 mgmt, vc0, vc1, vc4 =3D 0, vc5;
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
+	mgmt &=3D ~SM_SW_FWD_MODE;
+
+	if (enable) {
+		vc0 |=3D VC0_VLAN_EN | VC0_VID_CHK_EN | VC0_VID_HASH_VID;
+		vc1 |=3D VC1_RX_MCST_UNTAG_EN | VC1_RX_MCST_FWD_EN;
+		vc4 &=3D ~VC4_ING_VID_CHECK_MASK;
+		vc4 |=3D VC4_ING_VID_VIO_DROP << VC4_ING_VID_CHECK_S;
+		vc5 |=3D VC5_DROP_VTABLE_MISS;
+
+		if (is5325(dev))
+			vc0 &=3D ~VC0_RESERVED_1;
+
+		if (is5325(dev) || is5365(dev))
+			vc1 |=3D VC1_RX_MCST_TAG_EN;
+
+		if (!is5325(dev) && !is5365(dev)) {
+			if (dev->allow_vid_4095)
+				vc5 |=3D VC5_VID_FFF_EN;
+			else
+				vc5 &=3D ~VC5_VID_FFF_EN;
+		}
+	} else {
+		vc0 &=3D ~(VC0_VLAN_EN | VC0_VID_CHK_EN | VC0_VID_HASH_VID);
+		vc1 &=3D ~(VC1_RX_MCST_UNTAG_EN | VC1_RX_MCST_FWD_EN);
+		vc4 &=3D ~VC4_ING_VID_CHECK_MASK;
+		vc5 &=3D ~VC5_DROP_VTABLE_MISS;
+
+		if (is5325(dev) || is5365(dev))
+			vc4 |=3D VC4_ING_VID_VIO_FWD << VC4_ING_VID_CHECK_S;
+		else
+			vc4 |=3D VC4_ING_VID_VIO_TO_IMP << VC4_ING_VID_CHECK_S;
+
+		if (is5325(dev) || is5365(dev))
+			vc1 &=3D ~VC1_RX_MCST_TAG_EN;
+
+		if (!is5325(dev) && !is5365(dev))
+			vc5 &=3D ~VC5_VID_FFF_EN;
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
+static int b53_set_jumbo(struct b53_device *dev, int enable, int allow=
_10_100)
+{
+	u32 port_mask =3D 0;
+	u16 max_size =3D JMS_MIN_SIZE;
+
+	if (is5325(dev) || is5365(dev))
+		return -EINVAL;
+
+	if (enable) {
+		port_mask =3D dev->enabled_ports;
+		max_size =3D JMS_MAX_SIZE;
+		if (allow_10_100)
+			port_mask |=3D JPM_10_100_JUMBO_EN;
+	}
+
+	b53_write32(dev, B53_JUMBO_PAGE, dev->chip->jumbo_pm_reg, port_mask);
+	return b53_write16(dev, B53_JUMBO_PAGE, dev->chip->jumbo_size_reg,
+			   max_size);
+}
+
+static int b53_flush_arl(struct b53_device *dev)
+{
+	unsigned int i;
+
+	b53_write8(dev, B53_CTRL_PAGE, B53_FAST_AGE_CTRL,
+		   FAST_AGE_DONE | FAST_AGE_DYNAMIC | FAST_AGE_STATIC);
+
+	for (i =3D 0; i < 10; i++) {
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
+		/* prevent leaking packets between wan and lan in unmanaged
+		 * mode through port vlans.
+		 */
+		if (dev->enable_vlan || is_cpu_port(dev, i))
+			pvlan_mask =3D 0x1ff;
+		else if (is531x5(dev) || is5301x(dev))
+			/* BCM53115 may use a different port as cpu port */
+			pvlan_mask =3D BIT(dev->cpu_port);
+		else
+			pvlan_mask =3D BIT(B53_CPU_PORT);
+
+		/* BCM5325 CPU port is at 8 */
+		if ((is5325(dev) || is5365(dev)) && i =3D=3D B53_CPU_PORT_25)
+			i =3D B53_CPU_PORT;
+
+		if (dev->chip_id =3D=3D BCM5398_DEVICE_ID && (i =3D=3D 6 || i =3D=3D=
 7))
+			/* disable unused ports 6 & 7 */
+			port_ctrl =3D PORT_CTRL_RX_DISABLE | PORT_CTRL_TX_DISABLE;
+		else if (i =3D=3D B53_CPU_PORT)
+			port_ctrl =3D PORT_CTRL_RX_BCST_EN |
+				    PORT_CTRL_RX_MCST_EN |
+				    PORT_CTRL_RX_UCST_EN;
+		else
+			port_ctrl =3D 0;
+
+		b53_write16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(i),
+			    pvlan_mask);
+
+		/* port state is handled by bcm63xx_enet driver */
+		if (!is63xx(dev) && !(is5301x(dev) && i =3D=3D 6))
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
+	gc &=3D ~(GC_RESET_MIB | GC_MIB_AC_EN);
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
+		for (i =3D 1; i < dev->chip->vlans; i++)
+			b53_set_vlan_entry(dev, i, 0, 0);
+	} else {
+		b53_do_vlan_op(dev, VTA_CMD_CLEAR);
+	}
+
+	b53_enable_vlan(dev, dev->enable_vlan);
+
+	/* fill VLAN table */
+	if (dev->enable_vlan) {
+		for (i =3D 0; i < dev->chip->vlans; i++) {
+			struct b53_vlan *vlan =3D &dev->vlans[i];
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
+				    dev->ports[i]->pvid);
+	} else {
+		b53_for_each_port(dev, i)
+			b53_write16(dev, B53_VLAN_PAGE,
+				    B53_VLAN_PORT_DEF_TAG(i), 1);
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
+static void b53_switch_reset_gpio(struct b53_device *dev)
+{
+	int gpio =3D dev->reset_gpio;
+
+	if (gpio < 0)
+		return;
+
+	/* Reset sequence: RESET low(50ms)->high(20ms) */
+
+	gpio_set_value(gpio, 0);
+	mdelay(50);
+
+	gpio_set_value(gpio, 1);
+	mdelay(20);
+
+	dev->current_page =3D 0xff;
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
+		mgmt &=3D ~SM_SW_FWD_MODE;
+		mgmt |=3D SM_SW_FWD_EN;
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
+	} else if ((is531x5(dev) || is5301x(dev)) &&
+		   dev->cpu_port =3D=3D B53_CPU_PORT) {
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
+/*****************
+ * Net device ops
+ *****************/
+
+static netdev_tx_t b53_port_xmit(struct sk_buff *skb, struct net_devic=
e *dev)
+{
+	dev_kfree_skb(skb);
+	dev->stats.tx_dropped++;
+
+	return NETDEV_TX_OK;
+}
+
+static int b53_port_vlan_rx_add_vid(struct net_device *dev,
+				    __be16 proto, u16 vid)
+{
+	struct b53_port *b53_port =3D netdev_priv(dev);
+	struct b53_device *b53 =3D b53_port->b53;
+	struct b53_vlan *vlan;
+
+	if (vid >=3D b53->chip->vlans)
+		return -EINVAL;
+
+	/* only BCM5325 and BCM5365 supports VID 0 */
+	if (vid =3D=3D 0 && !is5325(b53) && !is5365(b53))
+		return -EINVAL;
+
+	/* VLAN 4095 needs special handling */
+	if (vid =3D=3D 4095)
+		return -EINVAL;
+
+	vlan =3D &b53->vlans[vid];
+
+	vlan->members |=3D BIT(b53_port->port_number);
+
+	/* ignore disabled ports */
+	vlan->members &=3D b53->enabled_ports;
+
+	b53_apply(b53);
+
+	return 0;
+}
+
+static int b53_port_vlan_rx_kill_vid(struct net_device *dev,
+				     __be16 proto, u16 vid)
+{
+	struct b53_port *b53_port =3D netdev_priv(dev);
+	struct b53_device *b53 =3D b53_port->b53;
+	struct b53_vlan *vlan;
+
+	if (vid >=3D b53->chip->vlans)
+		return -EINVAL;
+
+	vlan =3D &b53->vlans[vid];
+
+	vlan->members &=3D ~BIT(b53_port->port_number);
+
+	b53_apply(b53);
+
+	return 0;
+}
+
+static int b53_port_switch_parent_id_get(struct net_device *dev,
+					 struct netdev_phys_item_id *psid)
+{
+	struct b53_port *b53_port =3D netdev_priv(dev);
+
+	memcpy(psid->id, b53_port->b53->dev_addr, ETH_ALEN);
+	psid->id_len =3D ETH_ALEN;
+
+	return 0;
+}
+
+static int b53_port_bridge_setlink(struct net_device *dev,
+				   struct nlmsghdr *nlh, u16 flags)
+{
+	struct b53_port *b53_port =3D netdev_priv(dev);
+	struct b53_device *b53 =3D b53_port->b53;
+	struct b53_vlan *vlan;
+	struct nlattr *afspec;
+	struct nlattr *attr;
+	struct bridge_vlan_info *vinfo;
+	int rem;
+
+	afspec =3D nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPE=
C);
+	if (!afspec)
+		return -EINVAL;
+
+	nla_for_each_nested(attr, afspec, rem) {
+		if (nla_type(attr) !=3D IFLA_BRIDGE_VLAN_INFO)
+			continue;
+		if (nla_len(attr) !=3D sizeof(struct bridge_vlan_info))
+			return -EINVAL;
+		vinfo =3D nla_data(attr);
+	}
+	if (!vinfo)
+		return -EINVAL;
+
+	if (vinfo->flags & BRIDGE_VLAN_INFO_PVID)
+		b53_port->pvid =3D vinfo->vid;
+	else
+		b53_port->pvid =3D 0;
+
+	vlan =3D &b53->vlans[vinfo->vid];
+	if (vinfo->flags & BRIDGE_VLAN_INFO_UNTAGGED)
+		vlan->untag |=3D BIT(b53_port->port_number);
+	else
+		vlan->untag &=3D ~BIT(b53_port->port_number);
+
+	b53_apply(b53);
+
+	return 0;
+}
+
+static const struct net_device_ops b53_port_netdev_ops =3D {
+	.ndo_start_xmit			=3D b53_port_xmit,
+	.ndo_vlan_rx_add_vid		=3D b53_port_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid		=3D b53_port_vlan_rx_kill_vid,
+	.ndo_switch_parent_id_get	=3D b53_port_switch_parent_id_get,
+	.ndo_bridge_setlink		=3D b53_port_bridge_setlink,
+};
+
+/*****************
+ * Common
+ *****************/
+
+static void b53_remove_ports(struct b53_device *b53)
+{
+	struct b53_port *b53_port;
+	unsigned int i;
+
+	for (i =3D 0; i < b53->port_count; i++) {
+		b53_port =3D b53->ports[i];
+		unregister_netdev(b53_port->ndev);
+	}
+	kfree(b53->ports);
+}
+
+static int b53_probe_port(struct b53_device *b53, unsigned int port_nu=
mber)
+{
+	struct b53_port *b53_port;
+	struct net_device *ndev;
+	int err;
+
+	ndev =3D alloc_etherdev(sizeof(struct b53_port));
+	if (!ndev)
+		return -ENOMEM;
+	b53_port =3D netdev_priv(ndev);
+	b53_port->ndev =3D ndev;
+	b53_port->b53 =3D b53;
+	b53_port->port_number =3D port_number;
+
+	ndev->netdev_ops =3D &b53_port_netdev_ops;
+	ndev->features |=3D NETIF_F_HW_VLAN_CTAG_FILTER |
+			  NETIF_F_HW_SWITCH_OFFLOAD;
+	netif_carrier_on(ndev);
+	memcpy(ndev->dev_addr, b53->dev_addr, ETH_ALEN);
+
+	err =3D register_netdev(ndev);
+	if (err) {
+		dev_err(b53->dev, "register_netdev failed\n");
+		goto err_free_netdev;
+	}
+	b53->ports[port_number] =3D b53_port;
+
+	return 0;
+
+err_free_netdev:
+	free_netdev(ndev);
+	return err;
+}
+
+#define B53_VTA_REGS	\
+	{ B53_VT_ACCESS, B53_VT_INDEX, B53_VT_ENTRY }
+#define B53_VTA_REGS_9798 \
+	{ B53_VT_ACCESS_9798, B53_VT_INDEX_9798, B53_VT_ENTRY_9798 }
+#define B53_VTA_REGS_63XX \
+	{ B53_VT_ACCESS_63XX, B53_VT_INDEX_63XX, B53_VT_ENTRY_63XX }
+
+static const struct b53_chip_data b53_switch_chips[] =3D {
+	{
+		.chip_id =3D BCM5325_DEVICE_ID,
+		.dev_name =3D "BCM5325",
+		.alias =3D "bcm5325",
+		.vlans =3D 16,
+		.enabled_ports =3D 0x1f,
+		.cpu_port =3D B53_CPU_PORT_25,
+		.duplex_reg =3D B53_DUPLEX_STAT_FE,
+	},
+	{
+		.chip_id =3D BCM5365_DEVICE_ID,
+		.dev_name =3D "BCM5365",
+		.alias =3D "bcm5365",
+		.vlans =3D 256,
+		.enabled_ports =3D 0x1f,
+		.cpu_port =3D B53_CPU_PORT_25,
+		.duplex_reg =3D B53_DUPLEX_STAT_FE,
+	},
+	{
+		.chip_id =3D BCM5395_DEVICE_ID,
+		.dev_name =3D "BCM5395",
+		.alias =3D "bcm5395",
+		.vlans =3D 4096,
+		.enabled_ports =3D 0x1f,
+		.cpu_port =3D B53_CPU_PORT,
+		.vta_regs =3D B53_VTA_REGS,
+		.duplex_reg =3D B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg =3D B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg =3D B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id =3D BCM5397_DEVICE_ID,
+		.dev_name =3D "BCM5397",
+		.alias =3D "bcm5397",
+		.vlans =3D 4096,
+		.enabled_ports =3D 0x1f,
+		.cpu_port =3D B53_CPU_PORT,
+		.vta_regs =3D B53_VTA_REGS_9798,
+		.duplex_reg =3D B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg =3D B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg =3D B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id =3D BCM5398_DEVICE_ID,
+		.dev_name =3D "BCM5398",
+		.alias =3D "bcm5398",
+		.vlans =3D 4096,
+		.enabled_ports =3D 0x7f,
+		.cpu_port =3D B53_CPU_PORT,
+		.vta_regs =3D B53_VTA_REGS_9798,
+		.duplex_reg =3D B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg =3D B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg =3D B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id =3D BCM53115_DEVICE_ID,
+		.dev_name =3D "BCM53115",
+		.alias =3D "bcm53115",
+		.vlans =3D 4096,
+		.enabled_ports =3D 0x1f,
+		.vta_regs =3D B53_VTA_REGS,
+		.cpu_port =3D B53_CPU_PORT,
+		.duplex_reg =3D B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg =3D B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg =3D B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id =3D BCM53125_DEVICE_ID,
+		.dev_name =3D "BCM53125",
+		.alias =3D "bcm53125",
+		.vlans =3D 4096,
+		.enabled_ports =3D 0x1f,
+		.cpu_port =3D B53_CPU_PORT,
+		.vta_regs =3D B53_VTA_REGS,
+		.duplex_reg =3D B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg =3D B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg =3D B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id =3D BCM53128_DEVICE_ID,
+		.dev_name =3D "BCM53128",
+		.alias =3D "bcm53128",
+		.vlans =3D 4096,
+		.enabled_ports =3D 0x1ff,
+		.cpu_port =3D B53_CPU_PORT,
+		.vta_regs =3D B53_VTA_REGS,
+		.duplex_reg =3D B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg =3D B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg =3D B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id =3D BCM53010_DEVICE_ID,
+		.dev_name =3D "BCM53010",
+		.alias =3D "bcm53011",
+		.vlans =3D 4096,
+		.enabled_ports =3D 0x1f,
+		.cpu_port =3D B53_CPU_PORT_25, /* TODO: auto detect */
+		.vta_regs =3D B53_VTA_REGS,
+		.duplex_reg =3D B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg =3D B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg =3D B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id =3D BCM53011_DEVICE_ID,
+		.dev_name =3D "BCM53011",
+		.alias =3D "bcm53011",
+		.vlans =3D 4096,
+		.enabled_ports =3D 0x1f,
+		.cpu_port =3D B53_CPU_PORT_25, /* TODO: auto detect */
+		.vta_regs =3D B53_VTA_REGS,
+		.duplex_reg =3D B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg =3D B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg =3D B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id =3D BCM53012_DEVICE_ID,
+		.dev_name =3D "BCM53012",
+		.alias =3D "bcm53011",
+		.vlans =3D 4096,
+		.enabled_ports =3D 0x1f,
+		.cpu_port =3D B53_CPU_PORT_25, /* TODO: auto detect */
+		.vta_regs =3D B53_VTA_REGS,
+		.duplex_reg =3D B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg =3D B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg =3D B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id =3D BCM53018_DEVICE_ID,
+		.dev_name =3D "BCM53018",
+		.alias =3D "bcm53018",
+		.vlans =3D 4096,
+		.enabled_ports =3D 0x1f,
+		.cpu_port =3D B53_CPU_PORT_25, /* TODO: auto detect */
+		.vta_regs =3D B53_VTA_REGS,
+		.duplex_reg =3D B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg =3D B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg =3D B53_JUMBO_MAX_SIZE,
+	},
+	{
+		.chip_id =3D BCM53019_DEVICE_ID,
+		.dev_name =3D "BCM53019",
+		.alias =3D "bcm53019",
+		.vlans =3D 4096,
+		.enabled_ports =3D 0x1f,
+		.cpu_port =3D B53_CPU_PORT_25, /* TODO: auto detect */
+		.vta_regs =3D B53_VTA_REGS,
+		.duplex_reg =3D B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg =3D B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg =3D B53_JUMBO_MAX_SIZE,
+	},
+};
+
+static int b53_switch_init(struct b53_device *dev)
+{
+	unsigned int i;
+	int err;
+
+	eth_random_addr(dev->dev_addr);
+
+	dev->cpu_port =3D dev->chip->cpu_port;
+	dev->enabled_ports =3D dev->chip->enabled_ports;
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
+			dev->enabled_ports &=3D ~BIT(4);
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
+	} else if (dev->chip_id =3D=3D BCM53115_DEVICE_ID) {
+		u64 strap_value;
+
+		b53_read48(dev, B53_STAT_PAGE, B53_STRAP_VALUE, &strap_value);
+		/* use second IMP port if GMII is enabled */
+		if (strap_value & SV_GMII_CTRL_115)
+			dev->cpu_port =3D 5;
+	}
+
+	/* cpu port is always last */
+	dev->port_count =3D dev->cpu_port + 1;
+	dev->enabled_ports |=3D BIT(dev->cpu_port);
+
+	dev->ports =3D devm_kzalloc(dev->dev,
+				  sizeof(struct b53_port *) * dev->port_count,
+				  GFP_KERNEL);
+	if (!dev->ports)
+		return -ENOMEM;
+
+	for (i =3D 0; i < dev->port_count; i++) {
+		err =3D b53_probe_port(dev, i);
+		if (err)
+			goto err_remove_ports;
+	}
+
+	dev->vlans =3D devm_kzalloc(dev->dev,
+				  sizeof(struct b53_vlan) * dev->chip->vlans,
+				  GFP_KERNEL);
+	if (!dev->vlans)
+		return -ENOMEM;
+
+	dev->reset_gpio =3D b53_switch_get_reset_gpio(dev);
+	if (dev->reset_gpio >=3D 0) {
+		err =3D devm_gpio_request_one(dev->dev, dev->reset_gpio,
+					    GPIOF_OUT_INIT_HIGH, "robo_reset");
+		if (err)
+			return err;
+	}
+
+	return b53_switch_reset(dev);
+
+err_remove_ports:
+	b53_remove_ports(dev);
+	return err;
+}
+
+struct b53_device *b53_switch_alloc(struct device *base, struct b53_io=
_ops *ops,
+				    void *priv)
+{
+	struct b53_device *dev;
+
+	dev =3D devm_kzalloc(base, sizeof(*dev), GFP_KERNEL);
+	if (!dev)
+		return NULL;
+
+	dev->dev =3D base;
+	dev->ops =3D ops;
+	dev->priv =3D priv;
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
+	unsigned i;
+	int ret;
+
+	ret =3D b53_read8(dev, B53_MGMT_PAGE, B53_DEVICE_ID, &id8);
+	if (ret)
+		return ret;
+
+	switch (id8) {
+	case 0:
+		/* BCM5325 and BCM5365 do not have this register so reads
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
+		if (tmp =3D=3D 0xf)
+			dev->chip_id =3D BCM5325_DEVICE_ID;
+		else
+			dev->chip_id =3D BCM5365_DEVICE_ID;
+		break;
+	case BCM5395_DEVICE_ID:
+	case BCM5397_DEVICE_ID:
+	case BCM5398_DEVICE_ID:
+		dev->chip_id =3D id8;
+		break;
+	default:
+		ret =3D b53_read32(dev, B53_MGMT_PAGE, B53_DEVICE_ID, &id32);
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
+			dev->chip_id =3D id32;
+			break;
+		default:
+			pr_err("unsupported switch detected (BCM53%02x/BCM%x)\n",
+			       id8, id32);
+			return -ENODEV;
+		}
+	}
+
+	if (dev->chip_id =3D=3D BCM5325_DEVICE_ID)
+		ret =3D b53_read8(dev, B53_STAT_PAGE, B53_REV_ID_25,
+				&dev->core_rev);
+	else
+		ret =3D b53_read8(dev, B53_MGMT_PAGE, B53_REV_ID, &dev->core_rev);
+	if (ret)
+		return ret;
+
+	for (i =3D 0; i < ARRAY_SIZE(b53_switch_chips); i++) {
+		const struct b53_chip_data *chip =3D &b53_switch_chips[i];
+
+		if (chip->chip_id =3D=3D dev->chip_id) {
+			dev->chip =3D chip;
+			return 0;
+		}
+	}
+
+	return -ENOENT;
+}
+EXPORT_SYMBOL(b53_switch_detect);
+
+int b53_switch_register(struct b53_device *dev)
+{
+	int ret;
+
+	if (!dev->chip_id && b53_switch_detect(dev))
+		return -EINVAL;
+
+	ret =3D b53_switch_init(dev);
+	if (ret)
+		return ret;
+
+	dev_info(dev->dev, "found switch: %s, rev %i\n", dev->chip->dev_name,
+		 dev->core_rev);
+
+	return 0;
+}
+EXPORT_SYMBOL(b53_switch_register);
+
+void b53_switch_exit(struct b53_device *b53)
+{
+	b53_remove_ports(b53);
+}
+EXPORT_SYMBOL(b53_switch_exit);
+
+MODULE_AUTHOR("Jonas Gorski <jogo@openwrt.org>");
+MODULE_DESCRIPTION("B53 switch library");
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/phy/b53/b53_mdio.c b/drivers/net/phy/b53/b53_m=
dio.c
new file mode 100644
index 0000000..747ef67
--- /dev/null
+++ b/drivers/net/phy/b53/b53_mdio.c
@@ -0,0 +1,418 @@
+/*
+ * B53 register access through MII registers
+ *
+ * Copyright (C) 2011-2013 Jonas Gorski <jogo@openwrt.org>
+ *
+ * Permission to use, copy, modify, and/or distribute this software fo=
r any
+ * purpose with or without fee is hereby granted, provided that the ab=
ove
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRA=
NTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE=
 FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMA=
GES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN =
AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OU=
T OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include <linux/delay.h>
+#include <linux/kernel.h>
+#include <linux/phy.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+
+#include "b53_priv.h"
+
+#define B53_PSEUDO_PHY	0x1e /* Register Access Pseudo PHY */
+
+/* MII registers */
+#define REG_MII_PAGE		0x10    /* MII Page register */
+#define REG_MII_ADDR		0x11    /* MII Address register */
+#define REG_MII_DATA0		0x18    /* MII Data register 0 */
+#define REG_MII_DATA1		0x19    /* MII Data register 1 */
+#define REG_MII_DATA2		0x1a    /* MII Data register 2 */
+#define REG_MII_DATA3		0x1b    /* MII Data register 3 */
+
+#define REG_MII_PAGE_ENABLE	BIT(0)
+#define REG_MII_ADDR_WRITE	BIT(0)
+#define REG_MII_ADDR_READ	BIT(1)
+
+static int b53_mdio_op(struct b53_device *dev, u8 page, u8 reg, u16 op=
)
+{
+	int i;
+	u16 v;
+	int ret;
+	struct mii_bus *bus =3D dev->priv;
+
+	if (dev->current_page !=3D page) {
+		/* set page number */
+		v =3D (page << 8) | REG_MII_PAGE_ENABLE;
+		ret =3D mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_PAGE, v);
+		if (ret)
+			return ret;
+		dev->current_page =3D page;
+	}
+
+	/* set register address */
+	v =3D (reg << 8) | op;
+	ret =3D mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_ADDR, v);
+	if (ret)
+		return ret;
+
+	/* check if operation completed */
+	for (i =3D 0; i < 5; ++i) {
+		v =3D mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_ADDR);
+		if (!(v & (REG_MII_ADDR_WRITE | REG_MII_ADDR_READ)))
+			break;
+		usleep_range(10, 100);
+	}
+
+	if (WARN_ON(i =3D=3D 5))
+		return -EIO;
+
+	return 0;
+}
+
+static int b53_mdio_read8(struct b53_device *dev, u8 page, u8 reg, u8 =
*val)
+{
+	struct mii_bus *bus =3D dev->priv;
+	int ret;
+
+	ret =3D b53_mdio_op(dev, page, reg, REG_MII_ADDR_READ);
+	if (ret)
+		return ret;
+
+	*val =3D mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA0) & 0xff;
+
+	return 0;
+}
+
+static int b53_mdio_read16(struct b53_device *dev, u8 page, u8 reg, u1=
6 *val)
+{
+	struct mii_bus *bus =3D dev->priv;
+	int ret;
+
+	ret =3D b53_mdio_op(dev, page, reg, REG_MII_ADDR_READ);
+	if (ret)
+		return ret;
+
+	*val =3D mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA0);
+
+	return 0;
+}
+
+static int b53_mdio_read32(struct b53_device *dev, u8 page, u8 reg, u3=
2 *val)
+{
+	struct mii_bus *bus =3D dev->priv;
+	int ret;
+
+	ret =3D b53_mdio_op(dev, page, reg, REG_MII_ADDR_READ);
+	if (ret)
+		return ret;
+
+	*val =3D mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA0);
+	*val |=3D mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA1) << 16;
+
+	return 0;
+}
+
+static int b53_mdio_read48(struct b53_device *dev, u8 page, u8 reg, u6=
4 *val)
+{
+	struct mii_bus *bus =3D dev->priv;
+	u64 temp =3D 0;
+	int i;
+	int ret;
+
+	ret =3D b53_mdio_op(dev, page, reg, REG_MII_ADDR_READ);
+	if (ret)
+		return ret;
+
+	for (i =3D 2; i >=3D 0; i--) {
+		temp <<=3D 16;
+		temp |=3D mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA0 + i);
+	}
+
+	*val =3D temp;
+
+	return 0;
+}
+
+static int b53_mdio_read64(struct b53_device *dev, u8 page, u8 reg, u6=
4 *val)
+{
+	struct mii_bus *bus =3D dev->priv;
+	u64 temp =3D 0;
+	int i;
+	int ret;
+
+	ret =3D b53_mdio_op(dev, page, reg, REG_MII_ADDR_READ);
+	if (ret)
+		return ret;
+
+	for (i =3D 3; i >=3D 0; i--) {
+		temp <<=3D 16;
+		temp |=3D mdiobus_read(bus, B53_PSEUDO_PHY, REG_MII_DATA0 + i);
+	}
+
+	*val =3D temp;
+
+	return 0;
+}
+
+static int b53_mdio_write8(struct b53_device *dev, u8 page, u8 reg, u8=
 value)
+{
+	struct mii_bus *bus =3D dev->priv;
+	int ret;
+
+	ret =3D mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_DATA0, value);
+	if (ret)
+		return ret;
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static int b53_mdio_write16(struct b53_device *dev, u8 page, u8 reg, u=
16 value)
+{
+	struct mii_bus *bus =3D dev->priv;
+	int ret;
+
+	ret =3D mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_DATA0, value);
+	if (ret)
+		return ret;
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static int b53_mdio_write32(struct b53_device *dev, u8 page, u8 reg, u=
32 value)
+{
+	struct mii_bus *bus =3D dev->priv;
+	unsigned int i;
+	u32 temp =3D value;
+
+	for (i =3D 0; i < 2; i++) {
+		int ret =3D mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_DATA0 + i,
+				    temp & 0xffff);
+		if (ret)
+			return ret;
+		temp >>=3D 16;
+	}
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static int b53_mdio_write48(struct b53_device *dev, u8 page, u8 reg, u=
64 value)
+{
+	struct mii_bus *bus =3D dev->priv;
+	unsigned i;
+	u64 temp =3D value;
+
+	for (i =3D 0; i < 3; i++) {
+		int ret =3D mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_DATA0 + i,
+				    temp & 0xffff);
+		if (ret)
+			return ret;
+		temp >>=3D 16;
+	}
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static int b53_mdio_write64(struct b53_device *dev, u8 page, u8 reg, u=
64 value)
+{
+	struct mii_bus *bus =3D dev->priv;
+	unsigned i;
+	u64 temp =3D value;
+
+	for (i =3D 0; i < 4; i++) {
+		int ret =3D mdiobus_write(bus, B53_PSEUDO_PHY, REG_MII_DATA0 + i,
+				    temp & 0xffff);
+		if (ret)
+			return ret;
+		temp >>=3D 16;
+	}
+
+	return b53_mdio_op(dev, page, reg, REG_MII_ADDR_WRITE);
+}
+
+static struct b53_io_ops b53_mdio_ops =3D {
+	.read8 =3D b53_mdio_read8,
+	.read16 =3D b53_mdio_read16,
+	.read32 =3D b53_mdio_read32,
+	.read48 =3D b53_mdio_read48,
+	.read64 =3D b53_mdio_read64,
+	.write8 =3D b53_mdio_write8,
+	.write16 =3D b53_mdio_write16,
+	.write32 =3D b53_mdio_write32,
+	.write48 =3D b53_mdio_write48,
+	.write64 =3D b53_mdio_write64,
+};
+
+static int b53_phy_probe(struct phy_device *phydev)
+{
+	struct b53_device dev;
+	int ret;
+
+	/* allow the generic phy driver to take over */
+	if (phydev->addr !=3D B53_PSEUDO_PHY && phydev->addr !=3D 0)
+		return -ENODEV;
+
+	dev.current_page =3D 0xff;
+	dev.priv =3D phydev->bus;
+	dev.ops =3D &b53_mdio_ops;
+	mutex_init(&dev.reg_mutex);
+
+	ret =3D b53_switch_detect(&dev);
+	if (ret)
+		return ret;
+
+	if (is5325(&dev) || is5365(&dev))
+		phydev->supported =3D SUPPORTED_100baseT_Full;
+	else
+		phydev->supported =3D SUPPORTED_1000baseT_Full;
+
+	phydev->advertising =3D phydev->supported;
+
+	return 0;
+}
+
+static int b53_phy_config_init(struct phy_device *phydev)
+{
+	struct b53_device *dev;
+	int ret;
+
+	dev =3D b53_switch_alloc(&phydev->dev, &b53_mdio_ops, phydev->bus);
+	if (!dev)
+		return -ENOMEM;
+
+	/* we don't use page 0xff, so force a page set */
+	dev->current_page =3D 0xff;
+
+	ret =3D b53_switch_register(dev);
+	if (ret) {
+		dev_err(dev->dev, "failed to register switch: %i\n", ret);
+		return ret;
+	}
+
+	phydev->priv =3D dev;
+
+	return 0;
+}
+
+static void b53_phy_remove(struct phy_device *phydev)
+{
+	struct b53_device *priv =3D phydev->priv;
+
+	if (!priv)
+		return;
+
+	b53_switch_exit(priv);
+
+	phydev->priv =3D NULL;
+}
+
+static int b53_phy_config_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static int b53_phy_read_status(struct phy_device *phydev)
+{
+	struct b53_device *priv =3D phydev->priv;
+
+	if (is5325(priv) || is5365(priv))
+		phydev->speed =3D 100;
+	else
+		phydev->speed =3D 1000;
+
+	phydev->duplex =3D DUPLEX_FULL;
+	phydev->link =3D 1;
+	phydev->state =3D PHY_RUNNING;
+
+	netif_carrier_on(phydev->attached_dev);
+	phydev->adjust_link(phydev->attached_dev);
+
+	return 0;
+}
+
+/* BCM5325, BCM539x */
+static struct phy_driver b53_phy_driver_id1 =3D {
+	.phy_id		=3D 0x0143bc00,
+	.name		=3D "Broadcom B53 (1)",
+	.phy_id_mask	=3D 0x1ffffc00,
+	.features	=3D 0,
+	.probe		=3D b53_phy_probe,
+	.remove		=3D b53_phy_remove,
+	.config_aneg	=3D b53_phy_config_aneg,
+	.config_init	=3D b53_phy_config_init,
+	.read_status	=3D b53_phy_read_status,
+	.driver =3D {
+		.owner =3D THIS_MODULE,
+	},
+};
+
+/* BCM53125, BCM53128 */
+static struct phy_driver b53_phy_driver_id2 =3D {
+	.phy_id		=3D 0x03625c00,
+	.name		=3D "Broadcom B53 (2)",
+	.phy_id_mask	=3D 0x1ffffc00,
+	.features	=3D 0,
+	.probe		=3D b53_phy_probe,
+	.remove		=3D b53_phy_remove,
+	.config_aneg	=3D b53_phy_config_aneg,
+	.config_init	=3D b53_phy_config_init,
+	.read_status	=3D b53_phy_read_status,
+	.driver =3D {
+		.owner =3D THIS_MODULE,
+	},
+};
+
+/* BCM5365 */
+static struct phy_driver b53_phy_driver_id3 =3D {
+	.phy_id		=3D 0x00406000,
+	.name		=3D "Broadcom B53 (3)",
+	.phy_id_mask	=3D 0x1ffffc00,
+	.features	=3D 0,
+	.probe		=3D b53_phy_probe,
+	.remove		=3D b53_phy_remove,
+	.config_aneg	=3D b53_phy_config_aneg,
+	.config_init	=3D b53_phy_config_init,
+	.read_status	=3D b53_phy_read_status,
+	.driver =3D {
+		.owner =3D THIS_MODULE,
+	},
+};
+
+int __init b53_phy_driver_register(void)
+{
+	int ret;
+
+	ret =3D phy_driver_register(&b53_phy_driver_id1);
+	if (ret)
+		return ret;
+
+	ret =3D phy_driver_register(&b53_phy_driver_id2);
+	if (ret)
+		goto err1;
+
+	ret =3D phy_driver_register(&b53_phy_driver_id3);
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
diff --git a/drivers/net/phy/b53/b53_priv.h b/drivers/net/phy/b53/b53_p=
riv.h
new file mode 100644
index 0000000..03ebaf0
--- /dev/null
+++ b/drivers/net/phy/b53/b53_priv.h
@@ -0,0 +1,299 @@
+/*
+ * B53 common definitions
+ *
+ * Copyright (C) 2011-2013 Jonas Gorski <jogo@openwrt.org>
+ *
+ * Permission to use, copy, modify, and/or distribute this software fo=
r any
+ * purpose with or without fee is hereby granted, provided that the ab=
ove
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRA=
NTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE=
 FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMA=
GES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN =
AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OU=
T OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef __B53_PRIV_H
+#define __B53_PRIV_H
+
+#include <linux/kernel.h>
+#include <linux/mutex.h>
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
+	BCM5325_DEVICE_ID =3D 0x25,
+	BCM5365_DEVICE_ID =3D 0x65,
+	BCM5395_DEVICE_ID =3D 0x95,
+	BCM5397_DEVICE_ID =3D 0x97,
+	BCM5398_DEVICE_ID =3D 0x98,
+	BCM53115_DEVICE_ID =3D 0x53115,
+	BCM53125_DEVICE_ID =3D 0x53125,
+	BCM53128_DEVICE_ID =3D 0x53128,
+	BCM63XX_DEVICE_ID =3D 0x6300,
+	BCM53010_DEVICE_ID =3D 0x53010,
+	BCM53011_DEVICE_ID =3D 0x53011,
+	BCM53012_DEVICE_ID =3D 0x53012,
+	BCM53018_DEVICE_ID =3D 0x53018,
+	BCM53019_DEVICE_ID =3D 0x53019,
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
+	struct b53_device *b53;
+	struct net_device *ndev;
+
+	unsigned int port_number;
+	unsigned int pvid:12;
+};
+
+struct b53_chip_data;
+
+struct b53_device {
+	/* registers access */
+	struct mutex reg_mutex;
+	const struct b53_io_ops *ops;
+
+	unsigned char dev_addr[ETH_ALEN];
+	int port_count;
+
+	/* chip specific data */
+	u32 chip_id;
+	u8 core_rev;
+	const struct b53_chip_data *chip;
+	u8 cpu_port;
+	u16 enabled_ports;
+	int reset_gpio;
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
+	struct b53_port **ports;
+	struct b53_vlan *vlans;
+
+	char *buf;
+};
+
+#define b53_for_each_port(dev, i) \
+	for (i =3D 0; i < B53_N_PORTS; i++) \
+		if (dev->enabled_ports & BIT(i))
+
+static inline int is5325(struct b53_device *dev)
+{
+	return dev->chip_id =3D=3D BCM5325_DEVICE_ID;
+}
+
+static inline int is5365(struct b53_device *dev)
+{
+#ifdef CONFIG_BCM47XX
+	return dev->chip_id =3D=3D BCM5365_DEVICE_ID;
+#else
+	return 0;
+#endif
+}
+
+static inline int is5397_98(struct b53_device *dev)
+{
+	return dev->chip_id =3D=3D BCM5397_DEVICE_ID ||
+	       dev->chip_id =3D=3D BCM5398_DEVICE_ID;
+}
+
+static inline int is539x(struct b53_device *dev)
+{
+	return dev->chip_id =3D=3D BCM5395_DEVICE_ID ||
+	       dev->chip_id =3D=3D BCM5397_DEVICE_ID ||
+	       dev->chip_id =3D=3D BCM5398_DEVICE_ID;
+}
+
+static inline int is531x5(struct b53_device *dev)
+{
+	return dev->chip_id =3D=3D BCM53115_DEVICE_ID ||
+		dev->chip_id =3D=3D BCM53125_DEVICE_ID ||
+		dev->chip_id =3D=3D BCM53128_DEVICE_ID;
+}
+
+static inline int is63xx(struct b53_device *dev)
+{
+#ifdef CONFIG_BCM63XX
+	return dev->chip_id =3D=3D BCM63XX_DEVICE_ID;
+#else
+	return 0;
+#endif
+}
+
+static inline int is5301x(struct b53_device *dev)
+{
+	return dev->chip_id =3D=3D BCM53010_DEVICE_ID ||
+		dev->chip_id =3D=3D BCM53011_DEVICE_ID ||
+		dev->chip_id =3D=3D BCM53012_DEVICE_ID ||
+		dev->chip_id =3D=3D BCM53018_DEVICE_ID ||
+		dev->chip_id =3D=3D BCM53019_DEVICE_ID;
+}
+
+#define B53_CPU_PORT_25	5
+#define B53_CPU_PORT	8
+
+static inline int is_cpu_port(struct b53_device *dev, int port)
+{
+	return dev->cpu_port =3D=3D port;
+}
+
+struct b53_device *b53_switch_alloc(struct device *base, struct b53_io=
_ops *ops,
+				    void *priv);
+
+int b53_switch_detect(struct b53_device *dev);
+
+int b53_switch_register(struct b53_device *dev);
+
+void b53_switch_exit(struct b53_device *b53);
+
+static inline int b53_read8(struct b53_device *dev, u8 page, u8 reg, u=
8 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret =3D dev->ops->read8(dev, page, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_read16(struct b53_device *dev, u8 page, u8 reg, =
u16 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret =3D dev->ops->read16(dev, page, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_read32(struct b53_device *dev, u8 page, u8 reg, =
u32 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret =3D dev->ops->read32(dev, page, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_read48(struct b53_device *dev, u8 page, u8 reg, =
u64 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret =3D dev->ops->read48(dev, page, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_read64(struct b53_device *dev, u8 page, u8 reg, =
u64 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret =3D dev->ops->read64(dev, page, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_write8(struct b53_device *dev, u8 page, u8 reg, =
u8 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret =3D dev->ops->write8(dev, page, reg, value);
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
+	ret =3D dev->ops->write16(dev, page, reg, value);
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
+	ret =3D dev->ops->write32(dev, page, reg, value);
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
+	ret =3D dev->ops->write48(dev, page, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_write64(struct b53_device *dev, u8 page, u8 reg,
+			      u64 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret =3D dev->ops->write64(dev, page, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int b53_switch_get_reset_gpio(struct b53_device *dev)
+{
+	return -ENOENT;
+}
+
+#endif
diff --git a/drivers/net/phy/b53/b53_regs.h b/drivers/net/phy/b53/b53_r=
egs.h
new file mode 100644
index 0000000..ba50915
--- /dev/null
+++ b/drivers/net/phy/b53/b53_regs.h
@@ -0,0 +1,313 @@
+/*
+ * B53 register definitions
+ *
+ * Copyright (C) 2004 Broadcom Corporation
+ * Copyright (C) 2011-2013 Jonas Gorski <jogo@openwrt.org>
+ *
+ * Permission to use, copy, modify, and/or distribute this software fo=
r any
+ * purpose with or without fee is hereby granted, provided that the ab=
ove
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRA=
NTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE=
 FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMA=
GES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN =
AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OU=
T OF
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
+/*********************************************************************=
****
+ * Control Page registers
+ *********************************************************************=
****/
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
+#define   SM_SW_FWD_MODE		BIT(0)	/* 1 =3D Managed Mode */
+#define   SM_SW_FWD_EN			BIT(1)	/* Forwarding Enable */
+
+/* IMP Port state override register (8 bit) */
+#define B53_PORT_OVERRIDE_CTRL		0x0e
+#define   PORT_OVERRIDE_LINK		BIT(0)
+#define   PORT_OVERRIDE_HALF_DUPLEX	BIT(1) /* 0 =3D Full Duplex */
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
+/*********************************************************************=
****
+ * Status Page registers
+ *********************************************************************=
****/
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
+/*********************************************************************=
****
+ * Management Mode Page Registers
+ *********************************************************************=
****/
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
+/*********************************************************************=
****
+ * ARL Access Page Registers
+ *********************************************************************=
****/
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
+/*********************************************************************=
****
+ * Port VLAN Registers
+ *********************************************************************=
****/
+
+/* Port VLAN mask (16 bit) IMP port is always 8, also on 5325 & co */
+#define B53_PVLAN_PORT_MASK(i)		((i) * 2)
+
+/*********************************************************************=
****
+ * 802.1Q Page Registers
+ *********************************************************************=
****/
+
+/* Global QoS Control (8 bit) */
+#define B53_QOS_GLOBAL_CTL		0x00
+
+/* Enable 802.1Q for individual Ports (16 bit) */
+#define B53_802_1P_EN			0x04
+
+/*********************************************************************=
****
+ * VLAN Page Registers
+ *********************************************************************=
****/
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
+/*********************************************************************=
****
+ * Jumbo Frame Page Registers
+ *********************************************************************=
****/
+
+/* Jumbo Enable Port Mask (bit i =3D=3D port i enabled) (32 bit) */
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
--=20
1.8.4.5
