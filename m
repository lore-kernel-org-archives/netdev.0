From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH] NET: smc91x: Fix irq flags
Date: Sat, 28 Nov 2009 10:13:23 +0000
Message-ID: <20091128101323.GA25671@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Nicolas Pitre <nico@fluxnic.net>,
	eric miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:60166 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbZK1KN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 05:13:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smc91x.h defines SMC_IRQ_FLAGS to be -1 when it wants the interrupt
flags to be taken from the resource structure.  However, d280ead
changed this to checking for non-zero resource flags.

Unfortunately, this means that on some platforms, we end up passing
'-1' to request_irq rather than the desired result.  Combine the two
conditions into one so that the IRQ flags are taken from the resource
if either SMC_IRQ_FLAGS is -1 or the resource flags specify an
interrupt trigger.

This restores network on at least the Versatile platform.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

--
 drivers/net/smc91x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 05c91ee..a7af1f5 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2283,7 +2283,7 @@ static int __devinit smc_drv_probe(struct platform_device *pdev)
 
 	ndev->irq = ires->start;
 
-	if (ires->flags & IRQF_TRIGGER_MASK)
+	if (irq_flags == -1 || ires->flags & IRQF_TRIGGER_MASK)
 		irq_flags = ires->flags & IRQF_TRIGGER_MASK;
 
 	ret = smc_request_attrib(pdev, ndev);
