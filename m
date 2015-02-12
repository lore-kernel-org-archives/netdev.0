From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH] Revert "smc91x: retrieve IRQ and trigger flags in a modern way"
Date: Thu, 12 Feb 2015 17:59:10 +0100
Message-ID: <1423760350-20149-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Robert Jarzmik <robert.jarzmik@free.fr>
To: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp09.smtpout.orange.fr ([80.12.242.131]:41628 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbbBLQ7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 11:59:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit breaks the legacy platforms, ie. these not using device-tree,
and setting up the interrupt resources with a flag to activate edge
detection. The issue was found on the zylonite platform.

The reason is that zylonite uses platform resources to pass the interrupt number
and the irq flags (here IORESOURCE_IRQ_HIGHEDGE). It expects the driver to
request the irq with these flags, which in turn setups the irq as high edge
triggered.

After the patch, this was supposed to be taken care of with :
  irq_resflags = irqd_get_trigger_type(irq_get_irq_data(ndev->irq));

But irq_resflags is 0 for legacy platforms, while for example in
arch/arm/mach-pxa/zylonite.c, in struct resource smc91x_resources[] the
irq flag is specified. This breaks zylonite because the interrupt is not
setup as triggered, and hardware doesn't provide interrupts.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
 drivers/net/ethernet/smsc/smc91x.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 88a55f9..5d77e6f 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2243,10 +2243,9 @@ static int smc_drv_probe(struct platform_device *pdev)
 	const struct of_device_id *match = NULL;
 	struct smc_local *lp;
 	struct net_device *ndev;
-	struct resource *res;
+	struct resource *res, *ires;
 	unsigned int __iomem *addr;
 	unsigned long irq_flags = SMC_IRQ_FLAGS;
-	unsigned long irq_resflags;
 	int ret;
 
 	ndev = alloc_etherdev(sizeof(struct smc_local));
@@ -2338,19 +2337,16 @@ static int smc_drv_probe(struct platform_device *pdev)
 		goto out_free_netdev;
 	}
 
-	ndev->irq = platform_get_irq(pdev, 0);
-	if (ndev->irq <= 0) {
+	ires = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (!ires) {
 		ret = -ENODEV;
 		goto out_release_io;
 	}
-	/*
-	 * If this platform does not specify any special irqflags, or if
-	 * the resource supplies a trigger, override the irqflags with
-	 * the trigger flags from the resource.
-	 */
-	irq_resflags = irqd_get_trigger_type(irq_get_irq_data(ndev->irq));
-	if (irq_flags == -1 || irq_resflags & IRQF_TRIGGER_MASK)
-		irq_flags = irq_resflags & IRQF_TRIGGER_MASK;
+
+	ndev->irq = ires->start;
+
+	if (irq_flags == -1 || ires->flags & IRQF_TRIGGER_MASK)
+		irq_flags = ires->flags & IRQF_TRIGGER_MASK;
 
 	ret = smc_request_attrib(pdev, ndev);
 	if (ret)
-- 
2.1.0
