From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v6 08/10] ARM: mxs: add ocotp read function
Date: Fri, 14 Jan 2011 23:11:23 +0800
Message-ID: <1295017883-28775-1-git-send-email-shawn.guo@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shawn Guo <shawn.guo@freescale.com>
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:29404
	"EHLO VA3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752032Ab1ANPM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 10:12:28 -0500
In-Reply-To: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
 arch/arm/mach-mxs/Kconfig               |    4 ++
 arch/arm/mach-mxs/Makefile              |    2 +
 arch/arm/mach-mxs/include/mach/common.h |    1 +
 arch/arm/mach-mxs/ocotp.c               |   90 +++++++++++++++++++++++++++++++
 4 files changed, 97 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/mach-mxs/ocotp.c

diff --git a/arch/arm/mach-mxs/Kconfig b/arch/arm/mach-mxs/Kconfig
index 8bfc8df..cd2fbdf 100644
--- a/arch/arm/mach-mxs/Kconfig
+++ b/arch/arm/mach-mxs/Kconfig
@@ -2,6 +2,9 @@ if ARCH_MXS
 
 source "arch/arm/mach-mxs/devices/Kconfig"
 
+config MXS_OCOTP
+	bool
+
 config SOC_IMX23
 	bool
 	select CPU_ARM926T
@@ -26,6 +29,7 @@ config MACH_MX28EVK
 	select SOC_IMX28
 	select MXS_HAVE_AMBA_DUART
 	select MXS_HAVE_PLATFORM_FEC
+	select MXS_OCOTP
 	default y
 	help
 	  Include support for MX28EVK platform. This includes specific
diff --git a/arch/arm/mach-mxs/Makefile b/arch/arm/mach-mxs/Makefile
index 39d3f9c..df501a8 100644
--- a/arch/arm/mach-mxs/Makefile
+++ b/arch/arm/mach-mxs/Makefile
@@ -1,6 +1,8 @@
 # Common support
 obj-y := clock.o devices.o gpio.o icoll.o iomux.o system.o timer.o
 
+obj-$(CONFIG_MXS_OCOTP) += ocotp.o
+
 obj-$(CONFIG_SOC_IMX23) += clock-mx23.o mm-mx23.o
 obj-$(CONFIG_SOC_IMX28) += clock-mx28.o mm-mx28.o
 
diff --git a/arch/arm/mach-mxs/include/mach/common.h b/arch/arm/mach-mxs/include/mach/common.h
index 59133eb..635bb5d 100644
--- a/arch/arm/mach-mxs/include/mach/common.h
+++ b/arch/arm/mach-mxs/include/mach/common.h
@@ -13,6 +13,7 @@
 
 struct clk;
 
+extern const u32 *mxs_get_ocotp(void);
 extern int mxs_reset_block(void __iomem *);
 extern void mxs_timer_init(struct clk *, int);
 
diff --git a/arch/arm/mach-mxs/ocotp.c b/arch/arm/mach-mxs/ocotp.c
new file mode 100644
index 0000000..65157a3
--- /dev/null
+++ b/arch/arm/mach-mxs/ocotp.c
@@ -0,0 +1,90 @@
+/*
+ * Copyright 2010 Freescale Semiconductor, Inc. All Rights Reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/delay.h>
+#include <linux/err.h>
+#include <linux/mutex.h>
+
+#include <mach/mxs.h>
+
+#define OCOTP_WORD_OFFSET		0x20
+#define OCOTP_WORD_COUNT		0x20
+
+#define BM_OCOTP_CTRL_BUSY		(1 << 8)
+#define BM_OCOTP_CTRL_ERROR		(1 << 9)
+#define BM_OCOTP_CTRL_RD_BANK_OPEN	(1 << 12)
+
+static DEFINE_MUTEX(ocotp_mutex);
+static u32 ocotp_words[OCOTP_WORD_COUNT];
+
+const u32 *mxs_get_ocotp(void)
+{
+	void __iomem *ocotp_base = MXS_IO_ADDRESS(MXS_OCOTP_BASE_ADDR);
+	int timeout = 0x400;
+	size_t i;
+	static int once = 0;
+
+	if (once)
+		return ocotp_words;
+
+	mutex_lock(&ocotp_mutex);
+
+	/*
+	 * clk_enable(hbus_clk) for ocotp can be skipped
+	 * as it must be on when system is running.
+	 */
+
+	/* try to clear ERROR bit */
+	__mxs_clrl(BM_OCOTP_CTRL_ERROR, ocotp_base);
+
+	/* check both BUSY and ERROR cleared */
+	while ((__raw_readl(ocotp_base) &
+		(BM_OCOTP_CTRL_BUSY | BM_OCOTP_CTRL_ERROR)) && --timeout)
+		cpu_relax();
+
+	if (unlikely(!timeout))
+		goto error_unlock;
+
+	/* open OCOTP banks for read */
+	__mxs_setl(BM_OCOTP_CTRL_RD_BANK_OPEN, ocotp_base);
+
+	/* approximately wait 32 hclk cycles */
+	udelay(1);
+
+	/* poll BUSY bit becoming cleared */
+	timeout = 0x400;
+	while ((__raw_readl(ocotp_base) & BM_OCOTP_CTRL_BUSY) && --timeout)
+		cpu_relax();
+
+	if (unlikely(!timeout))
+		goto error_unlock;
+
+	for (i = 0; i < OCOTP_WORD_COUNT; i++)
+		ocotp_words[i] = __raw_readl(ocotp_base + OCOTP_WORD_OFFSET +
+						i * 0x10);
+
+	/* close banks for power saving */
+	__mxs_clrl(BM_OCOTP_CTRL_RD_BANK_OPEN, ocotp_base);
+
+	once = 1;
+
+	mutex_unlock(&ocotp_mutex);
+
+	return ocotp_words;
+
+error_unlock:
+	mutex_unlock(&ocotp_mutex);
+	pr_err("%s: timeout in reading OCOTP\n", __func__);
+	return NULL;
+}
-- 
1.7.1


