From: Daniel Ritz <daniel.ritz@gmx.ch>
Subject: [PATCH] fix arm/etherh.c
Date: Thu, 1 Apr 2004 23:17:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404012317.23719.daniel.ritz@gmx.ch>
Reply-To: daniel.ritz@gmx.ch
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

arm/etherh.c was broken when converted to alloc_ei_dev(). fix is the same as
in pcnet_cs.c.

also kfree()ing ec->irqdata is wrong since it's already freed by free_netdev().

against 2.6.5-rc3-bk. untested.


--- 1.21/drivers/net/arm/etherh.c	Wed Mar  3 00:15:42 2004
+++ edited/drivers/net/arm/etherh.c	Sat Mar 27 21:53:49 2004
@@ -59,7 +59,6 @@
 static unsigned int net_debug = NET_DEBUG;
 
 struct etherh_priv {
-	struct ei_device eidev;
 	unsigned int	id;
 	unsigned int	ctrl_port;
 	unsigned int	ctrl;
@@ -99,6 +98,12 @@
 
 /* ------------------------------------------------------------------------ */
 
+static inline struct etherh_priv *PRIV(struct net_device *dev)
+{
+	char *p = netdev_priv(dev);
+	return (struct etherh_priv *)(p + sizeof(struct ei_device));
+}
+
 static inline void etherh_set_ctrl(struct etherh_priv *eh, unsigned int mask)
 {
 	eh->ctrl |= mask;
@@ -144,8 +149,7 @@
 static void
 etherh_setif(struct net_device *dev)
 {
-	struct etherh_priv *eh = netdev_priv(dev);
-	struct ei_device *ei_local = &eh->eidev;
+	struct etherh_priv *eh = PRIV(dev);
 	unsigned long addr, flags;
 
 	local_irq_save(flags);
@@ -188,8 +192,7 @@
 static int
 etherh_getifstat(struct net_device *dev)
 {
-	struct etherh_priv *eh = netdev_priv(dev);
-	struct ei_device *ei_local = &eh->eidev;
+	struct etherh_priv *eh = PRIV(dev);
 	int stat = 0;
 
 	switch (eh->id) {
@@ -551,13 +554,13 @@
 
 	etherh_banner();
 
-	dev = alloc_ei_netdev();
+	dev = __alloc_ei_netdev(sizeof(struct etherh_priv));
 	if (!dev) {
 		ret = -ENOMEM;
 		goto out;
 	}
 
-	eh = netdev_priv(dev);
+	eh = PRIV(dev);
 
 	spin_lock_init(&eh->eidev.page_lock);
 
@@ -712,7 +715,6 @@
 	free_netdev(dev);
 
 	ec->ops = NULL;
-	kfree(ec->irq_data);
 }
 
 static const struct ecard_id etherh_ids[] = {
