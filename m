From: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 5/7] IrDA: sti/cli removal from EP7211 IrDA driver
Date: Thu, 9 Feb 2006 23:32:24 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0602092214130.4121@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "ext David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Signed-off-by: David Chosrova <david.chosrova-TDf4sKD1mxeHlu7OokbhRg@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

diff --git a/drivers/net/irda/ep7211_ir.c b/drivers/net/irda/ep7211_ir.c
index 3189626..6edf988 100644
--- a/drivers/net/irda/ep7211_ir.c
+++ b/drivers/net/irda/ep7211_ir.c
@@ -8,6 +8,7 @@
 #include <linux/delay.h>
 #include <linux/tty.h>
 #include <linux/init.h>
+#include <linux/spinlock.h>

 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>
@@ -15,6 +16,7 @@
 #include <asm/io.h>
 #include <asm/hardware.h>

+
 #define MIN_DELAY 25      /* 15 us, but wait a little more to be sure */
 #define MAX_DELAY 10000   /* 1 ms */

@@ -23,6 +25,7 @@ static void ep7211_ir_close(dongle_t *se
 static int  ep7211_ir_change_speed(struct irda_task *task);
 static int  ep7211_ir_reset(struct irda_task *task);

+static spinlock_t ep7211_lock;
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
+	spin_lock_irqrestore(&ep7211_lock, flags);
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
+	spin_lock_irqrestore(&ep7211_lock, flags);
 }

 /*
@@ -99,6 +102,7 @@ static int ep7211_ir_reset(struct irda_t
  */
 static int __init ep7211_ir_init(void)
 {
+	spin_lock_init(&ep7211_lock);
 	return irda_device_register_dongle(&dongle);
 }




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
