From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ircomm - set owner get rid of MOD_INC/MOD_DEC
Date: Mon, 18 Aug 2003 11:17:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818111746.34b9e52b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ircomm in 2.6.0-test3 can just set the owner field in the tty structure
like other drivers, and not mess with MOD_INC/MOD_DEC.


diff -Nru a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
--- a/net/irda/ircomm/ircomm_tty.c	Mon Aug 18 11:07:15 2003
+++ b/net/irda/ircomm/ircomm_tty.c	Mon Aug 18 11:07:15 2003
@@ -117,6 +117,7 @@
 		return -ENOMEM;
 	}
 
+	driver->owner		= THIS_MODULE;
 	driver->driver_name     = "ircomm";
 	driver->name            = "ircomm";
 	driver->devfs_name      = "ircomm";
@@ -363,10 +364,8 @@
 
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
 
-	MOD_INC_USE_COUNT;
 	line = tty->index;
 	if ((line < 0) || (line >= IRCOMM_TTY_PORTS)) {
-		MOD_DEC_USE_COUNT;
 		return -ENODEV;
 	}
 
@@ -377,7 +376,6 @@
 		self = kmalloc(sizeof(struct ircomm_tty_cb), GFP_KERNEL);
 		if (self == NULL) {
 			ERROR("%s(), kmalloc failed!\n", __FUNCTION__);
-			MOD_DEC_USE_COUNT;
 			return -ENOMEM;
 		}
 		memset(self, 0, sizeof(struct ircomm_tty_cb));
@@ -503,7 +501,6 @@
 	spin_lock_irqsave(&self->spinlock, flags);
 
 	if (tty_hung_up_p(filp)) {
-		MOD_DEC_USE_COUNT;
 		spin_unlock_irqrestore(&self->spinlock, flags);
 
 		IRDA_DEBUG(0, "%s(), returning 1\n", __FUNCTION__ );
@@ -530,7 +527,6 @@
 		self->open_count = 0;
 	}
 	if (self->open_count) {
-		MOD_DEC_USE_COUNT;
 		spin_unlock_irqrestore(&self->spinlock, flags);
 
 		IRDA_DEBUG(0, "%s(), open count > 0\n", __FUNCTION__ );
@@ -572,8 +568,6 @@
 
 	self->flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
 	wake_up_interruptible(&self->close_wait);
-
-	MOD_DEC_USE_COUNT;
 }
 
 /*
