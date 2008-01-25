From: Kevin Hilman <khilman@mvista.com>
Subject: [PATCH] SMC91x: don't flag spurious interrupts when polling
Date: Thu, 24 Jan 2008 18:15:43 -0800
Message-ID: <1201227343-10853-1-git-send-email-khilman@mvista.com>
Cc: Nicolas Pitre <nico@cam.org>, Kevin Hilman <khilman@mvista.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deeprooted.net ([216.254.16.51]:35141 "EHLO paris.hilman.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752176AbYAYCPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 21:15:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using polling, smc_poll_controller() can call smc_interrupt()
when there are likely to be no real interrups.  This will trigger the
"spurious interrupt" printk whenever the driver is being polled.

This adds an 'is_polling' flags, and doesn't trigger the spurious
warning when in polling mode.

Signed-off-by: Kevin Hilman <khilman@mvista.com>
Signed-off-by: Nicolas Pitre <nico@cam.org>
---
 drivers/net/smc91x.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 7da7589..64ef6c1 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1350,8 +1350,12 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
  */
 static void smc_poll_controller(struct net_device *dev)
 {
+	struct smc_local *lp = netdev_priv(dev);
+	void __iomem *ioaddr = lp->base;
+
 	disable_irq(dev->irq);
-	smc_interrupt(dev->irq, dev);
+	if (SMC_GET_INT() & SMC_GET_INT_MASK())
+		smc_interrupt(dev->irq, dev);
 	enable_irq(dev->irq);
 }
 #endif
-- 
1.5.3.7

