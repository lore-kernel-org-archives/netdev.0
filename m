From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/5) irlap_open should take const string
Date: Fri, 15 Aug 2003 15:55:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815155553.2f1b8735.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

irlap_open should take a constant string because it copies
its argument.  Therefore, irtty_net_open doesn't have to make
a copy!

diff -Nru a/drivers/net/irda/irtty.c b/drivers/net/irda/irtty.c
--- a/drivers/net/irda/irtty.c	Fri Aug 15 13:16:43 2003
+++ b/drivers/net/irda/irtty.c	Fri Aug 15 13:16:43 2003
@@ -907,7 +907,6 @@
 {
 	struct irtty_cb *self = (struct irtty_cb *) dev->priv;
 	struct tty_struct *tty = self->tty;
-	char hwname[16];
 
 	ASSERT(self != NULL, return -1;);
 	ASSERT(self->magic == IRTTY_MAGIC, return -1;);
@@ -920,14 +919,11 @@
 	/* Make sure we can receive more data */
 	irtty_stop_receiver(self, FALSE);
 
-	/* Give self a hardware name */
-	sprintf(hwname, "%s", tty->name);
-
 	/* 
 	 * Open new IrLAP layer instance, now that everything should be
 	 * initialized properly 
 	 */
-	self->irlap = irlap_open(dev, &self->qos, hwname);
+	self->irlap = irlap_open(dev, &self->qos, tty->name);
 
 	return 0;
 }
diff -Nru a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
--- a/include/net/irda/irda_device.h	Fri Aug 15 13:16:43 2003
+++ b/include/net/irda/irda_device.h	Fri Aug 15 13:16:43 2003
@@ -209,7 +209,7 @@
  * We declare them here to avoid the driver pulling a whole bunch stack
  * headers they don't really need - Jean II */
 struct irlap_cb *irlap_open(struct net_device *dev, struct qos_info *qos,
-			    char *	hw_name);
+			    const char *hw_name);
 void irlap_close(struct irlap_cb *self);
 
 /* Interface to be uses by IrLAP */
diff -Nru a/include/net/irda/irlap.h b/include/net/irda/irlap.h
--- a/include/net/irda/irlap.h	Fri Aug 15 13:16:43 2003
+++ b/include/net/irda/irlap.h	Fri Aug 15 13:16:43 2003
@@ -217,7 +217,7 @@
 void irlap_cleanup(void);
 
 struct irlap_cb *irlap_open(struct net_device *dev, struct qos_info *qos,
-			    char *	hw_name);
+			    const char *hw_name);
 void irlap_close(struct irlap_cb *self);
 
 void irlap_connect_request(struct irlap_cb *self, __u32 daddr, 
diff -Nru a/net/irda/irlap.c b/net/irda/irlap.c
--- a/net/irda/irlap.c	Fri Aug 15 13:16:43 2003
+++ b/net/irda/irlap.c	Fri Aug 15 13:16:43 2003
@@ -110,7 +110,7 @@
  *
  */
 struct irlap_cb *irlap_open(struct net_device *dev, struct qos_info *qos,
-			    char *	hw_name)
+			    const char *hw_name)
 {
 	struct irlap_cb *self;
 
