From: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>
Subject: [PATCH 1/4][upstream] powerpc/p1010: Rearrange header file for FlexCAN
Date: Mon, 8 Aug 2011 20:29:46 +0530
Message-ID: <1312815586-25756-1-git-send-email-bhaskar.upadhaya@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>
To: <netdev@vger.kernel.org>, <mkl@pengutronix.de>, <holt@sgi.com>,
	<wg@grandegger.com>, <davem@davemloft.net>,
	<linuxppc-release@linux.freescale.net>, <b22300@freescale.com>,
	<socketcan-
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:38177
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754000Ab1HHPAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 11:00:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Rearrange header file so that it can be used by both of_ type
  and platform_ type architecture.
- Provide a common read and write interface for of_ type and platform_
  type architecture for accessing h/w registers.
Signed-off-by: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>
---
 Based on http://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
 Branch master

 include/linux/can/platform/flexcan.h |   65 ++++++++++++++++++++++++++++++++++
 1 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/include/linux/can/platform/flexcan.h b/include/linux/can/platform/flexcan.h
index 72b713a..8458a87 100644
--- a/include/linux/can/platform/flexcan.h
+++ b/include/linux/can/platform/flexcan.h
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2010 Marc Kleine-Budde <kernel@pengutronix.de>
+ * Copyright 2011 Freescale Semiconductor, Inc.
  *
  * This file is released under the GPLv2
  *
@@ -8,6 +9,27 @@
 #ifndef __CAN_PLATFORM_FLEXCAN_H
 #define __CAN_PLATFORM_FLEXCAN_H
 
+#include <linux/clk.h>
+#include <linux/can/dev.h>
+#include <linux/io.h>
+
+#ifdef CONFIG_OF
+#include<linux/of_platform.h>
+#else
+#include <linux/platform_device.h>
+#include <mach/clock.h>
+#endif
+
+#define DRV_NAME "flexcan"
+
+#ifdef __BIG_ENDIAN
+#define flexcan_read(x)	in_be32(x)
+#define flexcan_write(x, y) out_be32(y, x)
+#else
+#define flexcan_read(x)	readl(x)
+#define flexcan_write(x, y) writel(x, y)
+#endif
+
 /**
  * struct flexcan_platform_data - flex CAN controller platform data
  * @transceiver_enable:         - called to power on/off the transceiver
@@ -17,4 +39,47 @@ struct flexcan_platform_data {
 	void (*transceiver_switch)(int enable);
 };
 
+struct flexcan_interface {
+	int (*clk_enable) (struct clk *clk);
+	void (*clk_disable) (struct clk *clk);
+	void (*clk_put) (struct clk *clk);
+	unsigned long (*clk_get_rate) (struct clk *clk);
+	struct clk *(*clk_get) (struct device *dev, const char *id);
+};
+
+struct flexcan_resource {
+	u32 irq;
+	u64 addr;
+	u64 size;
+	const char *drv_name;
+};
+
+#ifdef CONFIG_OF
+struct clk {
+	unsigned long		rate;
+	void			*data;
+};
+#endif
+
+struct flexcan_priv {
+	struct can_priv can;
+	struct net_device *dev;
+	struct napi_struct napi;
+
+	void __iomem *base;
+	u32 reg_esr;
+	u32 reg_ctrl_default;
+
+	struct clk *clk;
+	struct flexcan_interface *flexcan_ops;
+	struct flexcan_platform_data *pdata;
+};
+
+int flexcan_dev_init(struct device *pdev, struct flexcan_resource
+			flexcan_res, struct flexcan_interface *flexcan_ops);
+
+void __devexit unregister_flexcandev(struct net_device *dev);
+
+void flexcan_reg_dump(struct net_device *dev);
+
 #endif /* __CAN_PLATFORM_FLEXCAN_H */
-- 
1.5.6.5


