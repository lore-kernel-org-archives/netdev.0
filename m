From: <kamlakant.patel@broadcom.com>
Subject: [PATCH] net/smsc911x: fix irq resource allocation failure
Date: Mon, 4 May 2015 14:39:49 +0530
Message-ID: <1430730589-17378-1-git-send-email-kamlakant.patel@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kamlakant Patel <kamlakant.patel@broadcom.com>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	"David S . Miller" <davem@davemloft.net>,
	<linus.walleij@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:9538 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbbEDJKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 05:10:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamlakant Patel <kamlakant.patel@broadcom.com>

When smsc911x uses GPIO as the interrupt controller, and if both are
loaded as modules, we get following error:

"smsc911x: Could not allocate irq resource"

This issue is because of smsc911x using platform_get_resource to get
device tree based irq resource.

commit "9ec36ca (of/irq: do irq resolution in platform_get_irq)" and
commit "7085a7 (drivers: platform: parse IRQ flags from resources)" add
support in platform_get_irq to resolve irq and irq_flags respectively
for both modern device tree and legacy static platform data platforms.

Modify smsc911x driver to use platform_get_irq to pick up irq resource
correctly and use irq_get_trigger_type to get the IRQ trigger flags.

Signed-off-by: Kamlakant Patel <kamlakant.patel@broadcom.com>
---
 drivers/net/ethernet/smsc/smsc911x.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 41047c9..959aeea 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2418,9 +2418,9 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	struct net_device *dev;
 	struct smsc911x_data *pdata;
 	struct smsc911x_platform_config *config = dev_get_platdata(&pdev->dev);
-	struct resource *res, *irq_res;
+	struct resource *res;
 	unsigned int intcfg = 0;
-	int res_size, irq_flags;
+	int res_size, irq, irq_flags;
 	int retval;
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
@@ -2434,8 +2434,8 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	}
 	res_size = resource_size(res);
 
-	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (!irq_res) {
+	irq = platform_get_irq(pdev, 0);
+	if (irq <= 0) {
 		pr_warn("Could not allocate irq resource\n");
 		retval = -ENODEV;
 		goto out_0;
@@ -2455,8 +2455,8 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	pdata = netdev_priv(dev);
-	dev->irq = irq_res->start;
-	irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
+	dev->irq = irq;
+	irq_flags = irq_get_trigger_type(irq);
 	pdata->ioaddr = ioremap_nocache(res->start, res_size);
 
 	pdata->dev = dev;
-- 
1.7.1
