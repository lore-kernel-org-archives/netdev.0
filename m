From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH 3/6] atm/idt77105.c: call atm_dev_signal_change() when signal changes.
Date: Fri,  2 Jul 2010 19:47:07 +0200
Message-ID: <1278092830-10473-4-git-send-email-karl@hiramoto.org>
References: <1278092830-10473-1-git-send-email-karl@hiramoto.org>
Cc: nathan@traverse.com.au, Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:36887 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756671Ab0GBRsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 13:48:05 -0400
Received: from homiemail-a32.g.dreamhost.com (caiajhbdcagg.dreamhost.com [208.97.132.66])
	by hapkido.dreamhost.com (Postfix) with ESMTP id A9CB8179504
	for <netdev@vger.kernel.org>; Fri,  2 Jul 2010 10:48:05 -0700 (PDT)
In-Reply-To: <1278092830-10473-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Propagate changes to upper atm layer.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 drivers/atm/idt77105.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/atm/idt77105.c b/drivers/atm/idt77105.c
index dab5cf5..bca9cb8 100644
--- a/drivers/atm/idt77105.c
+++ b/drivers/atm/idt77105.c
@@ -126,7 +126,7 @@ static void idt77105_restart_timer_func(unsigned long dummy)
                 istat = GET(ISTAT); /* side effect: clears all interrupt status bits */
                 if (istat & IDT77105_ISTAT_GOODSIG) {
                     /* Found signal again */
-                    dev->signal = ATM_PHY_SIG_FOUND;
+                    atm_dev_signal_change(dev, ATM_PHY_SIG_FOUND);
 	            printk(KERN_NOTICE "%s(itf %d): signal detected again\n",
                         dev->type,dev->number);
                     /* flush the receive FIFO */
@@ -222,7 +222,7 @@ static void idt77105_int(struct atm_dev *dev)
             /* Rx Signal Condition Change - line went up or down */
             if (istat & IDT77105_ISTAT_GOODSIG) {   /* signal detected again */
                 /* This should not happen (restart timer does it) but JIC */
-                dev->signal = ATM_PHY_SIG_FOUND;
+		atm_dev_signal_change(dev, ATM_PHY_SIG_FOUND);
             } else {    /* signal lost */
                 /*
                  * Disable interrupts and stop all transmission and
@@ -235,7 +235,7 @@ static void idt77105_int(struct atm_dev *dev)
                     IDT77105_MCR_DRIC|
                     IDT77105_MCR_HALTTX
                     ) & ~IDT77105_MCR_EIP, MCR);
-                dev->signal = ATM_PHY_SIG_LOST;
+		atm_dev_signal_change(dev, ATM_PHY_SIG_LOST);
 	        printk(KERN_NOTICE "%s(itf %d): signal lost\n",
                     dev->type,dev->number);
             }
@@ -272,8 +272,9 @@ static int idt77105_start(struct atm_dev *dev)
 	memset(&PRIV(dev)->stats,0,sizeof(struct idt77105_stats));
         
         /* initialise dev->signal from Good Signal Bit */
-        dev->signal = GET(ISTAT) & IDT77105_ISTAT_GOODSIG ? ATM_PHY_SIG_FOUND :
-	  ATM_PHY_SIG_LOST;
+	atm_dev_signal_change(dev,
+		GET(ISTAT) & IDT77105_ISTAT_GOODSIG ?
+		ATM_PHY_SIG_FOUND : ATM_PHY_SIG_LOST);
 	if (dev->signal == ATM_PHY_SIG_LOST)
 		printk(KERN_WARNING "%s(itf %d): no signal\n",dev->type,
 		    dev->number);
-- 
1.7.1

