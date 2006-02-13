From: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/5] IrDA: sti/cli removal from EP7211 IrDA driver
Date: Tue, 14 Feb 2006 00:15:38 +0200
Message-ID: <20060213221538.GE31091@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	IrDA users <irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "ext David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

This patch replaces the deprecated sti/cli routines with the corresponding
spin_lock ones.

Signed-off-by: David chosrova <david.chosrova-TDf4sKD1mxeHlu7OokbhRg@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

diff --git a/drivers/net/irda/ep7211_ir.c b/drivers/net/irda/ep7211_ir.c
index 3189626..4cba38f 100644
--- a/drivers/net/irda/ep7211_ir.c
+++ b/drivers/net/irda/ep7211_ir.c
@@ -8,6 +8,7 @@
 #include <linux/delay.h>
 #include <linux/tty.h>
 #include <linux/init.h>
+#include <linux/spinlock.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>
@@ -23,6 +24,8 @@ static void ep7211_ir_close(dongle_t *se
 static int  ep7211_ir_change_speed(struct irda_task *task);
 static int  ep7211_ir_reset(struct irda_task *task);
 
+static DEFINE_SPINLOCK(ep7211_lock);
+
 static struct dongle_reg dongle = {
 	.type = IRDA_EP7211_IR,
 	.open = ep7211_ir_open,
@@ -36,7 +39,7 @@ static void ep7211_ir_open(dongle_t *sel
 {
 	unsigned int syscon1, flags;
 
-	save_flags(flags); cli();
+	spin_lock_irqsave(&ep7211_lock, flags);
 
 	/* Turn on the SIR encoder. */
 	syscon1 = clps_readl(SYSCON1);
@@ -46,14 +49,14 @@ static void ep7211_ir_open(dongle_t *sel
 	/* XXX: We should disable modem status interrupts on the first
 		UART (interrupt #14). */
 
-	restore_flags(flags);
+	spin_unlock_irqrestore(&ep7211_lock, flags);
 }
 
 static void ep7211_ir_close(dongle_t *self)
 {
 	unsigned int syscon1, flags;
 
-	save_flags(flags); cli();
+	spin_lock_irqsave(&ep7211_lock, flags);
 
 	/* Turn off the SIR encoder. */
 	syscon1 = clps_readl(SYSCON1);
@@ -63,7 +66,7 @@ static void ep7211_ir_close(dongle_t *se
 	/* XXX: If we've disabled the modem status interrupts, we should
 		reset them back to their original state. */
 
-	restore_flags(flags);
+	spin_unlock_irqrestore(&ep7211_lock, flags);
 }
 
 /*


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
