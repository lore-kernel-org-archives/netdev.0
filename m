From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 2/3] [IrDA] EP7211 IR driver port to the latest
	SIR API
Date: Sat, 21 Jul 2007 11:13:06 +0300
Message-ID: <20070721081906.145785934@sortiz.org>
References: <20070721081304.559769801@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline;
	filename=0001-IrDA-EP7211-IR-driver-port-to-the-latest-SIR-API.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The EP7211 SIR driver was the only one left without a new SIR API port.

Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 drivers/net/irda/Kconfig      |    9 ++++
 drivers/net/irda/Makefile     |    1 +
 drivers/net/irda/ep7211-sir.c |   89 +++++++++++++++++++++++++++++++++++++++++
 include/linux/irda.h          |    1 +
 4 files changed, 100 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/irda/ep7211-sir.c

Index: net-2.6-quilt/drivers/net/irda/Kconfig
===================================================================
--- net-2.6-quilt.orig/drivers/net/irda/Kconfig	2007-07-21 02:39:53.000000000 +0300
+++ net-2.6-quilt/drivers/net/irda/Kconfig	2007-07-21 02:39:59.000000000 +0300
@@ -155,6 +155,15 @@
 	  To compile it as a module, choose M here: the module will be called
 	  kingsun-sir.
 
+config EP7211_DONGLE
+	tristate "EP7211 I/R support"
+	depends on IRTTY_SIR && ARCH_EP7211 && IRDA && EXPERIMENTAL
+	help
+	  Say Y here if you want to build support for the Cirrus logic
+	  EP7211 chipset's infrared module.
+
+
+
 comment "Old SIR device drivers"
 
 config IRPORT_SIR
Index: net-2.6-quilt/drivers/net/irda/Makefile
===================================================================
--- net-2.6-quilt.orig/drivers/net/irda/Makefile	2007-07-21 02:39:53.000000000 +0300
+++ net-2.6-quilt/drivers/net/irda/Makefile	2007-07-21 02:39:59.000000000 +0300
@@ -45,6 +45,7 @@
 obj-$(CONFIG_ACT200L_DONGLE)	+= act200l-sir.o
 obj-$(CONFIG_MA600_DONGLE)	+= ma600-sir.o
 obj-$(CONFIG_TOIM3232_DONGLE)	+= toim3232-sir.o
+obj-$(CONFIG_EP7211_DONGLE)	+= ep7211-sir.o
 obj-$(CONFIG_KINGSUN_DONGLE)	+= kingsun-sir.o
 
 # The SIR helper module
Index: net-2.6-quilt/drivers/net/irda/ep7211-sir.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-2.6-quilt/drivers/net/irda/ep7211-sir.c	2007-07-21 02:39:59.000000000 +0300
@@ -0,0 +1,89 @@
+/*
+ * IR port driver for the Cirrus Logic EP7211 processor.
+ *
+ * Copyright 2001, Blue Mug Inc.  All rights reserved.
+ * Copyright 2007, Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
+ */
+#include <linux/module.h>
+#include <linux/delay.h>
+#include <linux/tty.h>
+#include <linux/init.h>
+#include <linux/spinlock.h>
+
+#include <net/irda/irda.h>
+#include <net/irda/irda_device.h>
+
+#include <asm/io.h>
+#include <asm/hardware.h>
+
+#include "sir-dev.h"
+
+#define MIN_DELAY 25      /* 15 us, but wait a little more to be sure */
+#define MAX_DELAY 10000   /* 1 ms */
+
+static int ep7211_open(struct sir_dev *dev);
+static int ep7211_close(struct sir_dev *dev);
+static int ep7211_change_speed(struct sir_dev *dev, unsigned speed);
+static int ep7211_reset(struct sir_dev *dev);
+
+static struct dongle_driver ep7211 = {
+	.owner		= THIS_MODULE,
+	.driver_name	= "EP7211 IR driver",
+	.type		= IRDA_EP7211_DONGLE,
+	.open		= ep7211_open,
+	.close		= ep7211_close,
+	.reset		= ep7211_reset,
+	.set_speed	= ep7211_change_speed,
+};
+
+static int __init ep7211_sir_init(void)
+{
+	return irda_register_dongle(&ep7211);
+}
+
+static void __exit ep7211_sir_cleanup(void)
+{
+	irda_unregister_dongle(&ep7211);
+}
+
+static int ep7211_open(struct sir_dev *dev)
+{
+	unsigned int syscon;
+
+	/* Turn on the SIR encoder. */
+	syscon = clps_readl(SYSCON1);
+	syscon |= SYSCON1_SIREN;
+	clps_writel(syscon, SYSCON1);
+
+	return 0;
+}
+
+static int ep7211_close(struct sir_dev *dev)
+{
+	unsigned int syscon;
+
+	/* Turn off the SIR encoder. */
+	syscon = clps_readl(SYSCON1);
+	syscon &= ~SYSCON1_SIREN;
+	clps_writel(syscon, SYSCON1);
+
+	return 0;
+}
+
+static int ep7211_change_speed(struct sir_dev *dev, unsigned speed)
+{
+	return 0;
+}
+
+static int ep7211_reset(struct sir_dev *dev)
+{
+	return 0;
+}
+
+MODULE_AUTHOR("Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>");
+MODULE_DESCRIPTION("EP7211 IR dongle driver");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("irda-dongle-13"); /* IRDA_EP7211_DONGLE */
+
+module_init(ep7211_sir_init);
+module_exit(ep7211_sir_cleanup);
Index: net-2.6-quilt/include/linux/irda.h
===================================================================
--- net-2.6-quilt.orig/include/linux/irda.h	2007-07-21 02:39:53.000000000 +0300
+++ net-2.6-quilt/include/linux/irda.h	2007-07-21 02:39:59.000000000 +0300
@@ -77,6 +77,7 @@
 	IRDA_ACT200L_DONGLE      = 10,
 	IRDA_MA600_DONGLE        = 11,
 	IRDA_TOIM3232_DONGLE     = 12,
+	IRDA_EP7211_DONGLE       = 13,
 } IRDA_DONGLE;
 
 /* Protocol types to be used for SOCK_DGRAM */

-- 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
