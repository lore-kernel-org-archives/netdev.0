From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v5 4/9] atm/idt77105.c: call atm_dev_signal_change() when signal changes.
Date: Fri,  9 Jul 2010 08:55:33 +0200
Message-ID: <1278658538-6769-5-git-send-email-karl@hiramoto.org>
References: <1278658538-6769-1-git-send-email-karl@hiramoto.org>
Cc: Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcaid.dreamhost.com ([208.97.132.83]:35217 "EHLO
	homiemail-a64.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753709Ab0GIGzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:55:54 -0400
In-Reply-To: <1278658538-6769-1-git-send-email-karl@hiramoto.org>
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

