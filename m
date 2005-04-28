From: "Mark Broadbent" <markb@wetlettuce.com>
Subject: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Thu, 28 Apr 2005 21:42:32 +0100
Message-ID: <E1DRFqC-00028H-Qi@tigger>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The interrupt handling code in the tulip network driver appears to use a non 
IRQ safe spinlock in an interrupt context.  The following patch should correct 
this.

Signed-off-by: Mark Broadbent <markb@wetlettuce.com>

Index: linux-2.6.11/drivers/net/tulip/interrupt.c
===================================================================
--- linux-2.6.11.orig/drivers/net/tulip/interrupt.c	2005-03-07 18:11:23.000000000 +0000
+++ linux-2.6.11/drivers/net/tulip/interrupt.c	2005-04-28 16:16:23.000000000 +0100
@@ -567,8 +567,9 @@
 
 		if (csr5 & (TxNoBuf | TxDied | TxIntr | TimerInt)) {
 			unsigned int dirty_tx;
+			unsigned long flags;
 
-			spin_lock(&tp->lock);
+			spin_lock_irqsave(&tp->lock, flags);
 
 			for (dirty_tx = tp->dirty_tx; tp->cur_tx - dirty_tx > 0;
 				 dirty_tx++) {
@@ -640,7 +641,7 @@
 						   dev->name, csr5, ioread32(ioaddr + CSR6), tp->csr6);
 				tulip_restart_rxtx(tp);
 			}
-			spin_unlock(&tp->lock);
+			spin_unlock_irqrestore(&tp->lock, flags);
 		}
 
 		/* Log errors. */
