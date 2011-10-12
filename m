From: "Reuben Dowle" <Reuben.Dowle@navico.com>
Subject: [PATCH] flexcan: fix flood of irq's after error condition triggered
Date: Wed, 12 Oct 2011 16:41:11 +1300
Message-ID: <70F6AAAFDC054F41B9994A9BCD3DF64E16D09892@exch01-aklnz.MARINE.NET.INT>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vw-hfger.navico.com ([81.89.228.210]:1931 "EHLO
	VW-HFGER.navico.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab1JLDxD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 23:53:03 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On my i.MX28 development kit board, I am able to use the flexcan module without problems, until I introduce a bus error by disconnecting the cable. As soon as this is done, the cpu usage goes to 100% percent due to the irq handler being called constantly.

It seems this error can be traced to the irq handler not clearing the irq flags. The flexcan driver is enabling several interrupts, but only clearing one of them.

>From the user manual:

25.6.8 Error and Status Register (HW_CAN_ESR)
This register reflects various error conditions, some general status of the device and it is
the source of four interrupts to the ARM. The reported error conditions are those that
occurred since the last time the ARM read this register. The ARM read action clears bits.
Bits are status bits. Most bits in this register are read-only, except TWRN_INT, RWRN_INT,
BOFF_INT, WAK_INT and ERR_INT, which are interrupt flags that can be cleared by
writing 1 to them (writing 0 has no effect).

This is ambiguous. It says that reading clears the bits, but then says that some of the bits can be cleared by writing 1 to them. In practice it seems that all the ones listed above as being able to be cleared by writing 1 to them MUST be cleared by writing 1 to them.

Signed-off-by: Reuben Dowle <reuben.dowle@navico.com>
---
 drivers/net/can/flexcan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 1767811..9bcc2e2 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -553,7 +553,7 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 
        reg_iflag1 = readl(&regs->iflag1);
        reg_esr = readl(&regs->esr);
-       writel(FLEXCAN_ESR_ERR_INT, &regs->esr);        /* ACK err IRQ */
+       writel(reg_esr & (FLEXCAN_ESR_TWRN_INT|FLEXCAN_ESR_RWRN_INT|FLEXCAN_ESR_BOFF_INT|FLEXCAN_ESR_ERR_INT), &regs->esr);     /* ACK err IRQ */
 
        /*
         * schedule NAPI in case of:
