From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/5) get rid of useless hashbin in irtty
Date: Fri, 15 Aug 2003 15:46:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815154608.56cf0551.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Working on converting IRDA to new netdevice semantics, this is the first
of some of the small things I found.

The irtty hashbin is created, maintained and never used.
Motivation for removing is that the hashbin locking has problems with
the locking assumptions in on network device removal.


diff -Nru a/drivers/net/irda/irtty.c b/drivers/net/irda/irtty.c
--- a/drivers/net/irda/irtty.c	Fri Aug 15 11:46:11 2003
+++ b/drivers/net/irda/irtty.c	Fri Aug 15 11:46:11 2003
@@ -39,7 +39,6 @@
 #include <net/irda/wrapper.h>
 #include <net/irda/irda_device.h>
 
-static hashbin_t *irtty = NULL;
 static struct tty_ldisc irda_ldisc;
 
 static int qos_mtt_bits = 0x03;      /* 5 ms or more */
@@ -75,14 +74,6 @@
 {
 	int status;
 
-	/* Probably no need to lock here because all operations done in
-	 * open()/close() which are already safe - Jean II */
-	irtty = hashbin_new( HB_NOLOCK);
-	if ( irtty == NULL) {
-		printk( KERN_WARNING "IrDA: Can't allocate irtty hashbin!\n");
-		return -ENOMEM;
-	}
-
 	/* Fill in our line protocol discipline, and register it */
 	memset(&irda_ldisc, 0, sizeof( irda_ldisc));
 
@@ -124,12 +115,6 @@
 		      __FUNCTION__, ret);
 	}
 
-	/*
-	 *  The TTY should care of deallocating the instances by using the
-	 *  callback to irtty_close(), therefore we do give any deallocation
-	 *  function to hashbin_destroy().
-	 */
-	hashbin_delete(irtty, NULL);
 }
 
 /* 
@@ -172,8 +157,6 @@
 	/* Give self a name */
 	strcpy(name, tty->name);
 
-	hashbin_insert(irtty, (irda_queue_t *) self, (int) self, NULL);
-
 	if (tty->driver->flush_buffer)
 		tty->driver->flush_buffer(tty);
 	
@@ -285,8 +268,6 @@
 	if (self->netdev)
 		unregister_netdev(self->netdev);
 	
-	self = hashbin_remove(irtty, (int) self, NULL);
-
 	/* Protect access to self->task and self->?x_buff - Jean II */
 	spin_lock_irqsave(&self->lock, flags);
 
diff -Nru a/include/net/irda/irtty.h b/include/net/irda/irtty.h
--- a/include/net/irda/irtty.h	Fri Aug 15 11:46:11 2003
+++ b/include/net/irda/irtty.h	Fri Aug 15 11:46:11 2003
@@ -31,7 +31,6 @@
 #include <linux/netdevice.h>
 
 #include <net/irda/irda.h>
-#include <net/irda/irqueue.h>
 #include <net/irda/irda_device.h>
 
 /* Used by ioctl */
@@ -45,7 +44,6 @@
 #define IRTTY_IOC_MAXNR   2
 
 struct irtty_cb {
-	irda_queue_t q;     /* Must be first */
 	magic_t magic;
 
 	struct net_device *netdev; /* Yes! we are some kind of netdevice */
