From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Tue, 17 Mar 2009 20:34:54 +0100
Message-ID: <200903172034.55241.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Rafael Wysocki <rjw@sisk.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout0.freenet.de ([195.4.92.90]:44715 "EHLO mout0.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752211AbZCQTfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 15:35:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Only adjust the NAPI bits of the interruptmask, if netif_rx_schedule_prep()
returns true.
Without this, I see interrupt storms here using 2.6.29-rcx and 2.6.27.19 and
device needed rmmod r8169 + modprobe r8169 to start working.

Signed-off-by: Karsten Wiese <fzu@wemgehoertderstaat.de>
---
 drivers/net/r8169.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b347340..0c943ba 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3708,12 +3708,11 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		rtl8169_check_link_status(dev, tp, ioaddr);
 
 	if (status & tp->napi_event) {
-		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
-		tp->intr_mask = ~tp->napi_event;
-
-		if (likely(netif_rx_schedule_prep(&tp->napi)))
+		if (likely(netif_rx_schedule_prep(&tp->napi))) {
+			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+			tp->intr_mask = ~tp->napi_event;
 			__netif_rx_schedule(&tp->napi);
-		else if (netif_msg_intr(tp)) {
+		} else if (netif_msg_intr(tp)) {
 			printk(KERN_INFO "%s: interrupt %04x in poll\n",
 			       dev->name, status);
 		}
-- 
1.6.0.6

