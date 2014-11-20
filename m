From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/2] net/am2150: fix nmclan_cs.c shared interrupt handling
Date: Thu, 20 Nov 2014 16:11:14 +0100
Message-ID: <4353896.15JnC91eLO@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Roger Pao <rpao@paonet.org>, linux-kernel@vger.kernel.org,
	linux-pcmcia@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A recent patch tried to work around a valid warning for the use of a
deprecated interface by blindly changing from the old
pcmcia_request_exclusive_irq() interface to pcmcia_request_irq().

This driver has an interrupt handler that is not currently aware
of shared interrupts, but can be easily converted to be.
At the moment, the driver reads the interrupt status register
repeatedly until it contains only zeroes in the interesting bits,
and handles each bit individually.

This patch adds the missing part of returning IRQ_NONE in case none
of the bits are set to start with, so we can move on to the next
interrupt source.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 5f5316fcd08ef7 ("am2150: Update nmclan_cs.c to use update PCMCIA API")
---
I had this patch in my queue of things to submit and noticed that
the warning had gone away upstream but my patch was still there.

For all I can tell, the driver is broken without this, although it
would rarely be a problem.

diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
index 5b22764ba88d..27245efe9f50 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -952,6 +952,8 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
   do {
     /* WARNING: MACE_IR is a READ/CLEAR port! */
     status = inb(ioaddr + AM2150_MACE_BASE + MACE_IR);
+    if (!(status & ~MACE_IMR_DEFAULT) && IntrCnt == MACE_MAX_IR_ITERATIONS)
+      return IRQ_NONE;
 
     pr_debug("mace_interrupt: irq 0x%X status 0x%X.\n", irq, status);
 
