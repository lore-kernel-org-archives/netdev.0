From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: [PATCH 2/2] net: smsc911x: get IRQ flags from chip if not present in IORESOURCE_IRQ
Date: Fri, 12 Apr 2013 20:05:43 +0200
Message-ID: <1365789943-3812-3-git-send-email-javier.martinez@collabora.co.uk>
References: <1365789943-3812-1-git-send-email-javier.martinez@collabora.co.uk>
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Rob Herring <robherring2@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jon Hunter <jon-hunter@ti.com>,
	devicetree-discuss@lists.ozlabs.org,
	linux-omap <linux-omap@vger.kernel.org>, netdev@vger.kernel.org,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:43028 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756181Ab3DLSGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 14:06:18 -0400
In-Reply-To: <1365789943-3812-1-git-send-email-javier.martinez@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When defining an IRQ trigger type and level flags from a Device Tree
a call to of_irq_to_resource() is made to parse the "interrupts"
property cells and return a struct resource.

But the flags are not saved on this struct resource which means that
drivers that try to obtain this information from an IORESOURCE_IRQ
will not be able to get it.

So, is more safe to fallback and query this information from the irq
chip directly if it was not found on the struct resource.

Signed-off-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
---
 drivers/net/ethernet/smsc/smsc911x.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index da5cc9a..3d535b3 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2390,6 +2390,10 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	pdata = netdev_priv(dev);
 	dev->irq = irq_res->start;
 	irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
+
+	if (!irq_flags)
+		irq_flags = irq_get_trigger_type(dev->irq);
+
 	pdata->ioaddr = ioremap_nocache(res->start, res_size);
 
 	pdata->dev = dev;
-- 
1.7.7.6
