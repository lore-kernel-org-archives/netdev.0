From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.1] Allow pcnet_cs to work with shared irq
Date: Thu, 19 Feb 2004 10:30:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219103042.7ad1e4e1@dell_ss3.pdx.osdl.net>
References: <20040120162251.291a0e39.shemminger@osdl.org>
	<403405EE.4020503@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <403405EE.4020503@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a rediff'd version of the patch to fix shared irq handling in pcnet_cs
and generic 8390 drivers.

--- linux-2.6/drivers/net/pcmcia/pcnet_cs.c	2004-02-09 10:06:49.000000000 -0800
+++ laptop-2.6/drivers/net/pcmcia/pcnet_cs.c	2004-02-09 16:54:48.000000000 -0800
@@ -1163,10 +1163,11 @@ static irqreturn_t ei_irq_wrapper(int ir
 {
     struct net_device *dev = dev_id;
     pcnet_dev_t *info = PRIV(dev);
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
--- linux-2.6/drivers/net/8390.c	2004-02-09 10:06:49.000000000 -0800
+++ laptop-2.6/drivers/net/8390.c	2004-02-09 16:54:47.000000000 -0800
@@ -513,7 +513,7 @@ irqreturn_t ei_interrupt(int irq, void *
 		}
 	}
 	spin_unlock(&ei_local->page_lock);
-	return IRQ_HANDLED;
+	return IRQ_RETVAL(nr_serviced > 0);
 }
 
 /**
