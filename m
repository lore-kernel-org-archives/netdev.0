From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v4 08/10] ARM: mxs: add ocotp read function
Date: Thu, 6 Jan 2011 15:13:16 +0800
Message-ID: <1294297998-26930-9-git-send-email-shawn.guo@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:28541
	"EHLO VA3EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754030Ab1AFHMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 02:12:06 -0500
In-Reply-To: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
Changes for v4:
 - Call cpu_relax() during polling

Changes for v2:
 - Add mutex locking for mxs_read_ocotp()
 - Use type size_t for count and i
 - Add comment for clk_enable/disable skipping
 - Add ERROR bit clearing and polling step

 arch/arm/mach-mxs/Makefile              |    2 +-
 arch/arm/mach-mxs/include/mach/common.h |    1 +
 arch/arm/mach-mxs/ocotp.c               |   79 +++++++++++++++++++++++++++++++
 3 files changed, 81 insertions(+), 1 deletions(-)
 create mode 100644 arch/arm/mach-mxs/ocotp.c

diff --git a/arch/arm/mach-mxs/Makefile b/arch/arm/mach-mxs/Makefile
index 39d3f9c..f23ebbd 100644
--- a/arch/arm/mach-mxs/Makefile
+++ b/arch/arm/mach-mxs/Makefile
@@ -1,5 +1,5 @@
 # Common support
-obj-y := clock.o devices.o gpio.o icoll.o iomux.o system.o timer.o
+obj-y := clock.o devices.o gpio.o icoll.o iomux.o ocotp.o system.o timer.o
 
 obj-$(CONFIG_SOC_IMX23) += clock-mx23.o mm-mx23.o
 obj-$(CONFIG_SOC_IMX28) += clock-mx28.o mm-mx28.o
diff --git a/arch/arm/mach-mxs/include/mach/common.h b/arch/arm/mach-mxs/include/mach/common.h
index 59133eb..cf02552 100644
--- a/arch/arm/mach-mxs/include/mach/common.h
+++ b/arch/arm/mach-mxs/include/mach/common.h
@@ -13,6 +13,7 @@
 
 struct clk;
 
+extern int mxs_read_ocotp(int offset, int count, u32 *values);
 extern int mxs_reset_block(void __iomem *);
 extern void mxs_timer_init(struct clk *, int);
 
diff --git a/arch/arm/mach-mxs/ocotp.c b/arch/arm/mach-mxs/ocotp.c
new file mode 100644
index 0000000..e2d39aa
--- /dev/null
+++ b/arch/arm/mach-mxs/ocotp.c
@@ -0,0 +1,79 @@
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
+#define BM_OCOTP_CTRL_BUSY		(1 << 8)
+#define BM_OCOTP_CTRL_ERROR		(1 << 9)
+#define BM_OCOTP_CTRL_RD_BANK_OPEN	(1 << 12)
+
+static DEFINE_MUTEX(ocotp_mutex);
+
+int mxs_read_ocotp(unsigned offset, size_t count, u32 *values)
+{
+	void __iomem *ocotp_base = MXS_IO_ADDRESS(MXS_OCOTP_BASE_ADDR);
+	int timeout = 0x400;
+	size_t i;
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
+	for (i = 0; i < count; i++, offset += 4)
+		*values++ = __raw_readl(ocotp_base + offset);
+
+	/* close banks for power saving */
+	__mxs_clrl(BM_OCOTP_CTRL_RD_BANK_OPEN, ocotp_base);
+
+	mutex_unlock(&ocotp_mutex);
+
+	return 0;
+
+error_unlock:
+	mutex_unlock(&ocotp_mutex);
+	pr_err("%s: timeout in reading OCOTP\n", __func__);
+	return -ETIMEDOUT;
+}
-- 
1.7.1


