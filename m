From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/1] smsc9420: fix interrupt signalling test failures
Date: Thu, 29 Jan 2009 16:39:23 +0000
Message-ID: <1233247163-4317-2-git-send-email-steve.glendinning@smsc.com>
References: <1233247163-4317-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:45941 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754136AbZA2QjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 11:39:15 -0500
In-Reply-To: <1233247163-4317-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smsc9420 performs an interrupt signalling test when the interface is
brought up.  The current code mistakenly sets its test flag to false
AFTER enabling the software interrupt source, making failure quite
likely.

This patch changes the code to set the test flag BEFORE enabling
interrupts. I've also removed an smp_wmb because the following spinlock
provides an implicit memory barrier.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc9420.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index c14a4c6..d801900 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1378,6 +1378,7 @@ static int smsc9420_open(struct net_device *dev)
 
 	/* test the IRQ connection to the ISR */
 	smsc_dbg(IFUP, "Testing ISR using IRQ %d", dev->irq);
+	pd->software_irq_signal = false;
 
 	spin_lock_irqsave(&pd->int_lock, flags);
 	/* configure interrupt deassertion timer and enable interrupts */
@@ -1393,8 +1394,6 @@ static int smsc9420_open(struct net_device *dev)
 	smsc9420_pci_flush_write(pd);
 
 	timeout = 1000;
-	pd->software_irq_signal = false;
-	smp_wmb();
 	while (timeout--) {
 		if (pd->software_irq_signal)
 			break;
-- 
1.6.0.6

