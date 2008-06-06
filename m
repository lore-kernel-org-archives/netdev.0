From: Eric Miao <eric.y.miao@gmail.com>
Subject: [PATCH] smc91x: remove "irq_flags" from "struct smc91x_platdata"
Date: Fri, 06 Jun 2008 17:37:04 +0800
Message-ID: <48490540.2070909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nico@cam.org>, Magnus Damm <damm@igel.co.jp>
To: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:2228 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136AbYFFJhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 05:37:23 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1385601rvb.1
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2008 02:37:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


IRQ trigger type can be specified in the IRQ resource definition by
IORESOURCE_IRQ_*, we need only one way to specify this.

This also fixes the following small issue:

To allow dynamic support for multiple platforms, when those relevant
macros are not defined for one specific platform, the default case
will be:

	- SMC_DYNAMIC_BUS_CONFIG defined
	- and SMC_IRQ_FLAGS = IRQF_TRIGGER_RISING

However, if "irq_flags" is missing when defining the smc91x_platdata,
usually as follows:

  static struct smc91x_platdata xxxx_smc91x_data = {
	.flags	= SMC91X_USE_XXBIT,
  };

The lp->cfg.irq_flags will always be overriden by the above structure
(due to a memcpy), thus rendering lp->cfg.irq_flags to be "0" always.
(regardless of the default SMC_IRQ_FLAGS or IORESOURCE_IRQ_* flags)

Signed-off-by: Eric Miao <eric.miao@marvell.com>
---
 arch/sh/boards/renesas/migor/setup.c |    3 +--
 drivers/net/smc91x.c                 |    7 ++++---
 include/linux/smc91x.h               |    1 -
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/arch/sh/boards/renesas/migor/setup.c b/arch/sh/boards/renesas/migor/setup.c
index 01af442..963c993 100644
--- a/arch/sh/boards/renesas/migor/setup.c
+++ b/arch/sh/boards/renesas/migor/setup.c
@@ -30,7 +30,6 @@
 
 static struct smc91x_platdata smc91x_info = {
 	.flags = SMC91X_USE_16BIT,
-	.irq_flags = IRQF_TRIGGER_HIGH,
 };
 
 static struct resource smc91x_eth_resources[] = {
@@ -42,7 +41,7 @@ static struct resource smc91x_eth_resources[] = {
 	},
 	[1] = {
 		.start  = 32, /* IRQ0 */
-		.flags  = IORESOURCE_IRQ,
+		.flags  = IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHLEVEL,
 	},
 };
 
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index a188e33..46097df 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2134,6 +2134,7 @@ static int smc_drv_probe(struct platform_device *pdev)
 	struct net_device *ndev;
 	struct resource *res, *ires;
 	unsigned int __iomem *addr;
+	unsigned long irq_flags = SMC_IRQ_FLAGS;
 	int ret;
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-regs");
@@ -2163,7 +2164,6 @@ static int smc_drv_probe(struct platform_device *pdev)
 	 */
 
 	lp = netdev_priv(ndev);
-	lp->cfg.irq_flags = SMC_IRQ_FLAGS;
 
 #ifdef SMC_DYNAMIC_BUS_CONFIG
 	if (pd)
@@ -2188,8 +2188,9 @@ static int smc_drv_probe(struct platform_device *pdev)
 	}
 
 	ndev->irq = ires->start;
+
 	if (SMC_IRQ_FLAGS == -1)
-		lp->cfg.irq_flags = ires->flags & IRQF_TRIGGER_MASK;
+		irq_flags = ires->flags & IRQF_TRIGGER_MASK;
 
 	ret = smc_request_attrib(pdev);
 	if (ret)
@@ -2216,7 +2217,7 @@ static int smc_drv_probe(struct platform_device *pdev)
 	}
 #endif
 
-	ret = smc_probe(ndev, addr, lp->cfg.irq_flags);
+	ret = smc_probe(ndev, addr, irq_flags);
 	if (ret != 0)
 		goto out_iounmap;
 
diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
index 8e0556b..fc7682f 100644
--- a/include/linux/smc91x.h
+++ b/include/linux/smc91x.h
@@ -7,7 +7,6 @@
 
 struct smc91x_platdata {
 	unsigned long flags;
-	unsigned long irq_flags; /* IRQF_... */
 };
 
 #endif /* __SMC91X_H__ */
-- 
1.5.4.3

