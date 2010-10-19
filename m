From: "Joshua Hoke" <Joshua.Hoke@sixnet.com>
Subject: [PATCH] macb: Don't re-enable interrupts while in polling mode
Date: Tue, 19 Oct 2010 12:48:22 -0400
Message-ID: <C8F551D39A7C724E987CF8DD11D3178304D02F88@svr3.sixnetio.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"Jiri Pirko" <jpirko@redhat.com>,
	"Peter Korsgaard" <peter.korsgaard@barco.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Haavard Skinnemoen" <haavard.skinnemoen@atmel.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Nicolas Ferre" <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-64-22-42-202.albyny.csvoip.net ([64.22.42.202]:14337
	"EHLO svr3.sixnetio.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754071Ab0JSRId convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 13:08:33 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joshua Hoke <joshua.hoke@sixnet.com>

[PATCH] macb: Don't re-enable interrupts while in polling mode

On a busy network, the macb driver could get stuck in the interrupt
handler, quickly triggering the watchdog, due to a confluence of
factors:

 1. macb_poll re-enables interrupts unconditionally, even when it will
    be called again because it exhausted its rx budget

 2. macb_interrupt only disables interrupts after scheduling
    macb_poll, but scheduling fails when macb_poll is already scheduled
    because it didn't call napi_complete

 3. macb_interrupt loops until the interrupt status register is clear,
    which will never happen in this case if the driver doesn't disable
    the RX interrupt

Since macb_interrupt runs in interrupt context, this effectively locks
up the machine, triggering the hardware watchdog.

This issue was readily reproducible on a flooded network with a
modified 2.6.27.48 kernel. The same problem appears to still be in the
2.6.36-rc8 driver code, so I am submitting this patch against that
version. I have not tested this version of the patch except to make
sure the kernel compiles.

Signed-off-by: Joshua Hoke <joshua.hoke@sixnet.com>

---

I'm submitting this at the request of Andrew Morton in this bug:

  https://bugzilla.kernel.org/show_bug.cgi?id=20732

This version of the patch applies to 2.6.36-rc8 but has not been
tested. In particular I am assuming that napi_schedule_prep() behaves
the same as netif_rx_schedule_prep() did by failing when the macb_poll
callback is already scheduled.

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index ff2f158..36cf594 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -515,14 +515,15 @@ static int macb_poll(struct napi_struct *napi, int
budget)
 		(unsigned long)status, budget);
 
 	work_done = macb_rx(bp, budget);
-	if (work_done < budget)
+	if (work_done < budget) {
 		napi_complete(napi);
 
-	/*
-	 * We've done what we can to clean the buffers. Make sure we
-	 * get notified when new packets arrive.
-	 */
-	macb_writel(bp, IER, MACB_RX_INT_FLAGS);
+		/*
+		 * We've done what we can to clean the buffers. Make
sure we
+		 * get notified when new packets arrive.
+		 */
+		macb_writel(bp, IER, MACB_RX_INT_FLAGS);
+	}
 
 	/* TODO: Handle errors */
 
@@ -550,12 +551,16 @@ static irqreturn_t macb_interrupt(int irq, void
*dev_id)
 		}
 
 		if (status & MACB_RX_INT_FLAGS) {
+			/*
+			 * There's no point taking any more interrupts
+			 * until we have processed the buffers. The
+			 * scheduling call may fail if the poll routine
+			 * is already scheduled, so disable interrupts
+			 * now.
+			 */
+			macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
+
 			if (napi_schedule_prep(&bp->napi)) {
-				/*
-				 * There's no point taking any more
interrupts
-				 * until we have processed the buffers
-				 */
-				macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
 				dev_dbg(&bp->pdev->dev,
 					"scheduling RX softirq\n");
 				__napi_schedule(&bp->napi);
