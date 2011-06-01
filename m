From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: [PATCH] net: dm9000: Get the chip in a known good state before enabling interrupts
Date: Wed,  1 Jun 2011 21:18:09 +0100
Message-ID: <1306959489-28865-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Cc: netdev@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:51862 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752607Ab1FAUSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 16:18:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the DM9000 driver requests the primary interrupt before it
resets the chip and puts it into a known good state. This means that if
the chip is asserting interrupt for some reason we can end up with a
screaming IRQ that the interrupt handler is unable to deal with. Avoid
this by only requesting the interrupt after we've reset the chip so we
know what state it's in.

This started manifesting itself on one of my boards in the past month or
so, I suspect as a result of some core infrastructure changes removing
some form of mitigation against bad behaviour here, even when things boot
it seems that the new code brings the interface up more quickly.

Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
---
 drivers/net/dm9000.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index fbaff35..ee597e6 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1157,9 +1157,6 @@ dm9000_open(struct net_device *dev)
 
 	irqflags |= IRQF_SHARED;
 
-	if (request_irq(dev->irq, dm9000_interrupt, irqflags, dev->name, dev))
-		return -EAGAIN;
-
 	/* GPIO0 on pre-activate PHY, Reg 1F is not set by reset */
 	iow(db, DM9000_GPR, 0);	/* REG_1F bit0 activate phyxcer */
 	mdelay(1); /* delay needs by DM9000B */
@@ -1168,6 +1165,9 @@ dm9000_open(struct net_device *dev)
 	dm9000_reset(db);
 	dm9000_init_dm9000(dev);
 
+	if (request_irq(dev->irq, dm9000_interrupt, irqflags, dev->name, dev))
+		return -EAGAIN;
+
 	/* Init driver variable */
 	db->dbug_cnt = 0;
 
-- 
1.7.5.3

