From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/5] smsc911x: add support for platform-specific irq flags
Date: Thu, 15 Jan 2009 09:07:58 +0000
Message-ID: <1232010482-3744-2-git-send-email-steve.glendinning@smsc.com>
References: <1232010482-3744-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:49019 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755317AbZAOJHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 04:07:19 -0500
In-Reply-To: <1232010482-3744-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this patch adds support for the platform_device's resources to indicate
additional flags to use when registering the irq, for example
IORESOURCE_IRQ_LOWLEVEL (which corresponds to IRQF_TRIGGER_LOW).  These
should be set in the irq resource flags field.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index f513bdf..3565df1 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1892,9 +1892,9 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	struct net_device *dev;
 	struct smsc911x_data *pdata;
 	struct smsc911x_platform_config *config = pdev->dev.platform_data;
-	struct resource *res;
+	struct resource *res, *irq_res;
 	unsigned int intcfg = 0;
-	int res_size;
+	int res_size, irq_flags;
 	int retval;
 	DECLARE_MAC_BUF(mac);
 
@@ -1919,6 +1919,14 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	}
 	res_size = res->end - res->start;
 
+	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (!irq_res) {
+		pr_warning("%s: Could not allocate irq resource.\n",
+			SMSC_CHIPNAME);
+		retval = -ENODEV;
+		goto out_0;
+	}
+
 	if (!request_mem_region(res->start, res_size, SMSC_CHIPNAME)) {
 		retval = -EBUSY;
 		goto out_0;
@@ -1935,7 +1943,8 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	pdata = netdev_priv(dev);
 
-	dev->irq = platform_get_irq(pdev, 0);
+	dev->irq = irq_res->start;
+	irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
 	pdata->ioaddr = ioremap_nocache(res->start, res_size);
 
 	/* copy config parameters across to pdata */
@@ -1968,8 +1977,8 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	smsc911x_reg_write(pdata, INT_EN, 0);
 	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
 
-	retval = request_irq(dev->irq, smsc911x_irqhandler, IRQF_DISABLED,
-			     dev->name, dev);
+	retval = request_irq(dev->irq, smsc911x_irqhandler,
+			     irq_flags | IRQF_DISABLED, dev->name, dev);
 	if (retval) {
 		SMSC_WARNING(PROBE,
 			"Unable to claim requested irq: %d", dev->irq);
-- 
1.6.0.6

