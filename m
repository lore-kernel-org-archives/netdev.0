From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.1] Allow pcnet_cs to work with shared irq
Date: Tue, 20 Jan 2004 16:22:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040120162251.291a0e39.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Paul Gortmaker <p_gortmaker@yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On some laptops, the pcmcia card shares an irq with other things
like the serial or irda ports.  The pcnet_cs driver did not correctly
handle shared interrupts, this fixes it for me.

ei_interrupt now returns IRQ_HANDLED if some frames have been serviced,
and the wrapper routine propagates the error code.

diff -Nru a/drivers/net/8390.c b/drivers/net/8390.c
--- a/drivers/net/8390.c	Tue Jan 20 16:21:00 2004
+++ b/drivers/net/8390.c	Tue Jan 20 16:21:00 2004
@@ -520,7 +520,7 @@
 		}
 	}
 	spin_unlock(&ei_local->page_lock);
-	return IRQ_HANDLED;
+	return IRQ_RETVAL(nr_serviced > 0);
 }
 
 /**
diff -Nru a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
--- a/drivers/net/pcmcia/pcnet_cs.c	Tue Jan 20 16:21:00 2004
+++ b/drivers/net/pcmcia/pcnet_cs.c	Tue Jan 20 16:21:00 2004
@@ -1193,10 +1193,11 @@
 static irqreturn_t ei_irq_wrapper(int irq, void *dev_id, struct pt_regs *regs)
 {
     pcnet_dev_t *info = dev_id;
-    info->stale = 0;
-    ei_interrupt(irq, dev_id, regs);
-    /* FIXME! Was it really ours? */
-    return IRQ_HANDLED;
+    irqreturn_t ret = ei_interrupt(irq, dev_id, regs);
+
+    if (ret == IRQ_HANDLED)
+	    info->stale = 0;
+    return ret;
 }
 
 static void ei_watchdog(u_long arg)
