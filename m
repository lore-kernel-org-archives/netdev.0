From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 7/9] Generic bitbanged MDIO library
Date: Thu, 20 Sep 2007 17:01:23 -0500
Message-ID: <20070920220123.GG28784@loki.buserror.net>
References: <20070920220043.GA28769@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:47841 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbXITWCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 18:02:01 -0400
Content-Disposition: inline
In-Reply-To: <20070920220043.GA28769@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previously, bitbanged MDIO was only supported in individual
hardware-specific drivers.  This code factors out the higher level
protocol implementation, reducing the hardware-specific portion to
functions setting direction, data, and clock.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/phy/Kconfig        |    9 ++
 drivers/net/phy/Makefile       |    1 +
 drivers/net/phy/mdio-bitbang.c |  187 ++++++++++++++++++++++++++++++++++++++++
 include/linux/mdio-bitbang.h   |   42 +++++++++
 4 files changed, 239 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/mdio-bitbang.c
 create mode 100644 include/linux/mdio-bitbang.h

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index dd09011..72a98dd 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -76,4 +76,13 @@ config FIXED_MII_100_FDX
 	bool "Emulation for 100M Fdx fixed PHY behavior"
 	depends on FIXED_PHY
 
+config MDIO_BITBANG
+	tristate "Support for bitbanged MDIO buses"
+	help
+	  This module implements the MDIO bus protocol in software,
+	  for use by low level drivers that export the ability to
+	  drive the relevant pins.
+
+	  If in doubt, say N.
+
 endif # PHYLIB
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 8885650..3d6cc7b 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -13,3 +13,4 @@ obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
 obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed.o
+obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
new file mode 100644
index 0000000..8cd243d
--- /dev/null
+++ b/drivers/net/phy/mdio-bitbang.c
@@ -0,0 +1,187 @@
+/*
+ * Bitbanged MDIO support.
+ *
+ * Author: Scott Wood <scottwood@freescale.com>
+ * Copyright (c) 2007 Freescale Semiconductor
+ *
+ * Based on CPM2 MDIO code which is:
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
+#include <linux/mdio-bitbang.h>
+#include <linux/slab.h>
+#include <linux/types.h>
+#include <linux/delay.h>
+
+#define MDIO_READ 1
+#define MDIO_WRITE 0
+
+#define MDIO_SETUP_TIME 10
+#define MDIO_HOLD_TIME 10
+
+/* Minimum MDC period is 400 ns, plus some margin for error.  MDIO_DELAY
+ * is done twice per period.
+ */
+#define MDIO_DELAY 250
+
+/* The PHY may take up to 300 ns to produce data, plus some margin
+ * for error.
+ */
+#define MDIO_READ_DELAY 350
+
+/* MDIO must already be configured as output. */
+static void mdiobb_send_bit(struct mdiobb_ctrl *ctrl, int val)
+{
+	const struct mdiobb_ops *ops = ctrl->ops;
+
+	ops->set_mdio_data(ctrl, val);
+	ndelay(MDIO_DELAY);
+	ops->set_mdc(ctrl, 1);
+	ndelay(MDIO_DELAY);
+	ops->set_mdc(ctrl, 0);
+}
+
+/* MDIO must already be configured as input. */
+static int mdiobb_get_bit(struct mdiobb_ctrl *ctrl)
+{
+	const struct mdiobb_ops *ops = ctrl->ops;
+
+	ndelay(MDIO_DELAY);
+	ops->set_mdc(ctrl, 1);
+	ndelay(MDIO_READ_DELAY);
+	ops->set_mdc(ctrl, 0);
+
+	return ops->get_mdio_data(ctrl);
+}
+
+/* MDIO must already be configured as output. */
+static void mdiobb_send_num(struct mdiobb_ctrl *ctrl, u16 val, int bits)
+{
+	int i;
+
+	for (i = bits - 1; i >= 0; i--)
+		mdiobb_send_bit(ctrl, (val >> i) & 1);
+}
+
+/* MDIO must already be configured as input. */
+static u16 mdiobb_get_num(struct mdiobb_ctrl *ctrl, int bits)
+{
+	int i;
+	u16 ret = 0;
+
+	for (i = bits - 1; i >= 0; i--) {
+		ret <<= 1;
+		ret |= mdiobb_get_bit(ctrl);
+	}
+
+	return ret;
+}
+
+/* Utility to send the preamble, address, and
+ * register (common to read and write).
+ */
+static void mdiobb_cmd(struct mdiobb_ctrl *ctrl, int read, u8 phy, u8 reg)
+{
+	const struct mdiobb_ops *ops = ctrl->ops;
+	int i;
+
+	ops->set_mdio_dir(ctrl, 1);
+
+	/*
+	 * Send a 32 bit preamble ('1's) with an extra '1' bit for good
+	 * measure.  The IEEE spec says this is a PHY optional
+	 * requirement.  The AMD 79C874 requires one after power up and
+	 * one after a MII communications error.  This means that we are
+	 * doing more preambles than we need, but it is safer and will be
+	 * much more robust.
+	 */
+
+	for (i = 0; i < 32; i++)
+		mdiobb_send_bit(ctrl, 1);
+
+	/* send the start bit (01) and the read opcode (10) or write (10) */
+	mdiobb_send_bit(ctrl, 0);
+	mdiobb_send_bit(ctrl, 1);
+	mdiobb_send_bit(ctrl, read);
+	mdiobb_send_bit(ctrl, !read);
+
+	mdiobb_send_num(ctrl, phy, 5);
+	mdiobb_send_num(ctrl, reg, 5);
+}
+
+
+static int mdiobb_read(struct mii_bus *bus, int phy, int reg)
+{
+	struct mdiobb_ctrl *ctrl = bus->priv;
+	int ret, i;
+
+	mdiobb_cmd(ctrl, MDIO_READ, phy, reg);
+	ctrl->ops->set_mdio_dir(ctrl, 0);
+
+	/* check the turnaround bit: the PHY should be driving it to zero */
+	if (mdiobb_get_bit(ctrl) != 0) {
+		/* PHY didn't drive TA low -- flush any bits it
+		 * may be trying to send.
+		 */
+		for (i = 0; i < 32; i++)
+			mdiobb_get_bit(ctrl);
+
+		return 0xffff;
+	}
+
+	ret = mdiobb_get_num(ctrl, 16);
+	mdiobb_get_bit(ctrl);
+	return ret;
+}
+
+static int mdiobb_write(struct mii_bus *bus, int phy, int reg, u16 val)
+{
+	struct mdiobb_ctrl *ctrl = bus->priv;
+
+	mdiobb_cmd(ctrl, MDIO_WRITE, phy, reg);
+
+	/* send the turnaround (10) */
+	mdiobb_send_bit(ctrl, 1);
+	mdiobb_send_bit(ctrl, 0);
+
+	mdiobb_send_num(ctrl, val, 16);
+
+	ctrl->ops->set_mdio_dir(ctrl, 0);
+	mdiobb_get_bit(ctrl);
+	return 0;
+}
+
+struct mii_bus *alloc_mdio_bitbang(struct mdiobb_ctrl *ctrl)
+{
+	struct mii_bus *bus;
+
+	bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
+	if (!bus)
+		return NULL;
+
+	__module_get(ctrl->ops->owner);
+
+	bus->read = mdiobb_read;
+	bus->write = mdiobb_write;
+	bus->priv = ctrl;
+
+	return bus;
+}
+
+void free_mdio_bitbang(struct mii_bus *bus)
+{
+	struct mdiobb_ctrl *ctrl = bus->priv;
+
+	module_put(ctrl->ops->owner);
+	kfree(bus);
+}
diff --git a/include/linux/mdio-bitbang.h b/include/linux/mdio-bitbang.h
new file mode 100644
index 0000000..8ea9a42
--- /dev/null
+++ b/include/linux/mdio-bitbang.h
@@ -0,0 +1,42 @@
+#ifndef __LINUX_MDIO_BITBANG_H
+#define __LINUX_MDIO_BITBANG_H
+
+#include <linux/phy.h>
+#include <linux/module.h>
+
+struct mdiobb_ctrl;
+
+struct mdiobb_ops {
+	struct module *owner;
+
+	/* Set the Management Data Clock high if level is one,
+	 * low if level is zero.
+	 */
+	void (*set_mdc)(struct mdiobb_ctrl *ctrl, int level);
+
+	/* Configure the Management Data I/O pin as an input if
+	 * "output" is zero, or an output if "output" is one.
+	 */
+	void (*set_mdio_dir)(struct mdiobb_ctrl *ctrl, int output);
+
+	/* Set the Management Data I/O pin high if value is one,
+	 * low if "value" is zero.  This may only be called
+	 * when the MDIO pin is configured as an output.
+	 */
+	void (*set_mdio_data)(struct mdiobb_ctrl *ctrl, int value);
+
+	/* Retrieve the state Management Data I/O pin. */
+	int (*get_mdio_data)(struct mdiobb_ctrl *ctrl);
+};
+
+struct mdiobb_ctrl {
+	const struct mdiobb_ops *ops;
+};
+
+/* The returned bus is not yet registered with the phy layer. */
+struct mii_bus *alloc_mdio_bitbang(struct mdiobb_ctrl *ctrl);
+
+/* The bus must already have been unregistered. */
+void free_mdio_bitbang(struct mii_bus *bus);
+
+#endif
-- 
1.5.3.1

