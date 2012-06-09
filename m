From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: avoid NAPI scheduling delay.
Date: Sat, 9 Jun 2012 22:53:16 +0200
Message-ID: <20120609205316.GA5915@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	Marc Dionne <marc.c.dionne@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Johannes Stezenbach <js@sig21.net>,
	Nikos Chantziaras <realnc@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49287 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999Ab2FIVCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 17:02:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While reworking the r8169 driver a few months ago to perform the
smallest amount of work in the irq handler, I took care of avoiding
any irq mask register operation in the slow work dedicated user
context thread. The slow work thread scheduled an extra round of NAPI
work which would ultimately set the irq mask register as required,
thus keeping such irq mask operations in the NAPI handler.
It would eventually race with the irq handler and delay NAPI execution
for - assuming no further irq - a whole ksoftirqd period. Mildly a
problem for rare link changes or corner case PCI events.

The race was always lost after the last bh disabling lock had been
removed from the work thread and people started wondering where those
pesky "NOHZ: local_softirq_pending 08" messages came from.

Actually the irq mask register _can_ be set up directly in the slow
work thread.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Reported-by: Dave Jones <davej@redhat.com>
Tested-by: Marc Dionne <marc.c.dionne@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 9757ce3..7260aa7 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5889,11 +5889,7 @@ static void rtl_slow_event_work(struct rtl8169_private *tp)
 	if (status & LinkChg)
 		__rtl8169_check_link_status(dev, tp, tp->mmio_addr, true);
 
-	napi_disable(&tp->napi);
-	rtl_irq_disable(tp);
-
-	napi_enable(&tp->napi);
-	napi_schedule(&tp->napi);
+	rtl_irq_enable_all(tp);
 }
 
 static void rtl_task(struct work_struct *work)
-- 
1.7.10.2
