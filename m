From: Linus Walleij <linus.walleij@linaro.org>
Subject: [PATCH] smc91x: retrieve IRQ and trigger flags in a modern way
Date: Fri, 31 Oct 2014 21:32:06 +0100
Message-ID: <1414787526-11197-1-git-send-email-linus.walleij@linaro.org>
Cc: Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:57123 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755603AbaJaUcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 16:32:17 -0400
Received: by mail-la0-f50.google.com with SMTP id hz20so4385401lab.9
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 13:32:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SMC91x is written to explicitly look up the IRQ resource
from the platform device and extract the IRQ and flags, however
the platform_get_irq() does additional things, like call
of_irq_get() in the device tree case, which will translate
the IRQ using the irqdomain and defer the probe if the
IRQ host cannot be found.

As we're not looking up the resource, this will not retrieve
the IRQ flags, but that is better done using
irqd_get_trigger_type(), as the trigger is what the driver
wants to modify. We take care to preserve the semantics that
will make the trigger type provided from the resource
override any local specifier.

Tested on the Nomadik NHK15 which has its SMC91x IRQ line
connected to a STMPE2401 GPIO expander on I2C.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/ethernet/smsc/smc91x.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 5e94d00b96b3..7747d506646a 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2207,9 +2207,10 @@ static int smc_drv_probe(struct platform_device *pdev)
 	const struct of_device_id *match = NULL;
 	struct smc_local *lp;
 	struct net_device *ndev;
-	struct resource *res, *ires;
+	struct resource *res;
 	unsigned int __iomem *addr;
 	unsigned long irq_flags = SMC_IRQ_FLAGS;
+	unsigned long irq_resflags;
 	int ret;
 
 	ndev = alloc_etherdev(sizeof(struct smc_local));
@@ -2279,16 +2280,19 @@ static int smc_drv_probe(struct platform_device *pdev)
 		goto out_free_netdev;
 	}
 
-	ires = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (!ires) {
+	ndev->irq = platform_get_irq(pdev, 0);
+	if (ndev->irq <= 0) {
 		ret = -ENODEV;
 		goto out_release_io;
 	}
-
-	ndev->irq = ires->start;
-
-	if (irq_flags == -1 || ires->flags & IRQF_TRIGGER_MASK)
-		irq_flags = ires->flags & IRQF_TRIGGER_MASK;
+	/*
+	 * If this platform does not specify any special irqflags, or if
+	 * the resource supplies a trigger, override the irqflags with
+	 * the trigger flags from the resource.
+	 */
+	irq_resflags = irqd_get_trigger_type(irq_get_irq_data(ndev->irq));
+	if (irq_flags == -1 || irq_resflags & IRQF_TRIGGER_MASK)
+		irq_flags = irq_resflags & IRQF_TRIGGER_MASK;
 
 	ret = smc_request_attrib(pdev, ndev);
 	if (ret)
-- 
1.9.3
