From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/8) hdlc wan device disembedding
Date: Tue, 2 Dec 2003 14:01:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202140103.6bb2deb4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Krzysztof Halas <khc@pm.waw.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change the hdlc wan device's to not have the net_device structure embedded
inside the hdlc_device structure.  This won't work on 2.6 where the net_device
structure may need to live after module unload due to sysfs.
Instead, use alloc_netdev and setup so that netdev->priv = hdlc 
and have hdlc->dev_data for device private data.

Patch is against net-drivers-2.5-exp tree.  This portion breaks the actual
hardware drivers but that is fixed in parts 2-5. I don't have any of this hardware
so the code has only been tested by compiling and loading the modules.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1502  -> 1.1503 
#	drivers/net/wan/hdlc_generic.c	1.14    -> 1.15   
#	drivers/net/wan/hdlc_cisco.c	1.9     -> 1.10   
#	drivers/net/wan/hdlc_fr.c	1.9     -> 1.10   
#	include/linux/hdlc.h	1.10    -> 1.11   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/12/01	shemminger@osdl.org	1.1503
# 1-hdlc_device
# --------------------------------------------
#
diff -Nru a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
--- a/drivers/net/wan/hdlc_cisco.c	Mon Dec  1 14:45:08 2003
+++ b/drivers/net/wan/hdlc_cisco.c	Mon Dec  1 14:45:08 2003
@@ -222,8 +222,8 @@
 	    hdlc->state.cisco.settings.timeout * HZ) {
 		hdlc->state.cisco.up = 0;
 		printk(KERN_INFO "%s: Link down\n", hdlc_to_name(hdlc));
-		if (netif_carrier_ok(&hdlc->netdev))
-			netif_carrier_off(&hdlc->netdev);
+		if (netif_carrier_ok(hdlc->netdev))
+			netif_carrier_off(hdlc->netdev);
 	}
 
 	cisco_keepalive_send(hdlc, CISCO_KEEPALIVE_REQ,
@@ -256,8 +256,8 @@
 static void cisco_stop(hdlc_device *hdlc)
 {
 	del_timer_sync(&hdlc->state.cisco.timer);
-	if (netif_carrier_ok(&hdlc->netdev))
-		netif_carrier_off(&hdlc->netdev);
+	if (netif_carrier_ok(hdlc->netdev))
+		netif_carrier_off(hdlc->netdev);
 }
 
 
diff -Nru a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
--- a/drivers/net/wan/hdlc_fr.c	Mon Dec  1 14:45:08 2003
+++ b/drivers/net/wan/hdlc_fr.c	Mon Dec  1 14:45:08 2003
@@ -543,8 +543,8 @@
 
 	hdlc->state.fr.reliable = reliable;
 	if (reliable) {
-		if (!netif_carrier_ok(&hdlc->netdev))
-			netif_carrier_on(&hdlc->netdev);
+		if (!netif_carrier_ok(hdlc->netdev))
+			netif_carrier_on(hdlc->netdev);
 
 		hdlc->state.fr.n391cnt = 0; /* Request full status */
 		hdlc->state.fr.dce_changed = 1;
@@ -558,8 +558,8 @@
 			}
 		}
 	} else {
-		if (netif_carrier_ok(&hdlc->netdev))
-			netif_carrier_off(&hdlc->netdev);
+		if (netif_carrier_ok(hdlc->netdev))
+			netif_carrier_off(hdlc->netdev);
 
 		while (pvc) {		/* Deactivate all PVCs */
 			pvc_carrier(0, pvc);
@@ -938,8 +938,8 @@
 	printk(KERN_DEBUG "fr_start\n");
 #endif
 	if (hdlc->state.fr.settings.lmi != LMI_NONE) {
-		if (netif_carrier_ok(&hdlc->netdev))
-			netif_carrier_off(&hdlc->netdev);
+		if (netif_carrier_ok(hdlc->netdev))
+			netif_carrier_off(hdlc->netdev);
 		hdlc->state.fr.last_poll = 0;
 		hdlc->state.fr.reliable = 0;
 		hdlc->state.fr.dce_changed = 1;
diff -Nru a/drivers/net/wan/hdlc_generic.c b/drivers/net/wan/hdlc_generic.c
--- a/drivers/net/wan/hdlc_generic.c	Mon Dec  1 14:45:08 2003
+++ b/drivers/net/wan/hdlc_generic.c	Mon Dec  1 14:45:08 2003
@@ -71,6 +71,7 @@
 
 void hdlc_set_carrier(int on, hdlc_device *hdlc)
 {
+	struct net_device *dev = hdlc_to_dev(hdlc);
 	on = on ? 1 : 0;
 
 #ifdef DEBUG_LINK
@@ -92,14 +93,14 @@
 	if (hdlc->carrier) {
 		if (hdlc->proto.start)
 			hdlc->proto.start(hdlc);
-		else if (!netif_carrier_ok(&hdlc->netdev))
-			netif_carrier_on(&hdlc->netdev);
+		else if (!netif_carrier_ok(dev))
+			netif_carrier_on(dev);
 
 	} else { /* no carrier */
 		if (hdlc->proto.stop)
 			hdlc->proto.stop(hdlc);
-		else if (netif_carrier_ok(&hdlc->netdev))
-			netif_carrier_off(&hdlc->netdev);
+		else if (netif_carrier_ok(dev))
+			netif_carrier_off(dev);
 	}
 
  carrier_exit:
@@ -110,6 +111,8 @@
 /* Must be called by hardware driver when HDLC device is being opened */
 int hdlc_open(hdlc_device *hdlc)
 {
+	struct net_device *dev = hdlc_to_dev(hdlc);
+
 #ifdef DEBUG_LINK
 	printk(KERN_DEBUG "hdlc_open carrier %i open %i\n",
 	       hdlc->carrier, hdlc->open);
@@ -129,11 +132,11 @@
 	if (hdlc->carrier) {
 		if (hdlc->proto.start)
 			hdlc->proto.start(hdlc);
-		else if (!netif_carrier_ok(&hdlc->netdev))
-			netif_carrier_on(&hdlc->netdev);
+		else if (!netif_carrier_ok(dev))
+			netif_carrier_on(dev);
 
-	} else if (netif_carrier_ok(&hdlc->netdev))
-		netif_carrier_off(&hdlc->netdev);
+	} else if (netif_carrier_ok(dev))
+		netif_carrier_off(dev);
 
 	hdlc->open = 1;
 
@@ -224,11 +227,9 @@
 }
 
 
-
-int register_hdlc_device(hdlc_device *hdlc)
+static void hdlc_setup(struct net_device *dev)
 {
-	int result;
-	struct net_device *dev = hdlc_to_dev(hdlc);
+	hdlc_device *hdlc = dev->priv;
 
 	dev->get_stats = hdlc_get_stats;
 	dev->change_mtu = hdlc_change_mtu;
@@ -245,17 +246,13 @@
 	hdlc->open = 0;
 	spin_lock_init(&hdlc->state_lock);
 
-	result = dev_alloc_name(dev, "hdlc%d");
-	if (result < 0)
-		return result;
-
-	result = register_netdev(dev);
-	if (result != 0)
-		return -EIO;
-
-	return 0;
+	hdlc->dev_data = (hdlc + 1);
 }
 
+int register_hdlc_device(hdlc_device *hdlc)
+{
+	return register_netdev(hdlc_to_dev(hdlc));
+}
 
 
 void unregister_hdlc_device(hdlc_device *hdlc)
@@ -266,7 +263,17 @@
 	rtnl_unlock();
 }
 
+hdlc_device *alloc_hdlc_device(int sizeof_priv)
+{
+	struct net_device *dev = alloc_netdev(sizeof_priv + sizeof(hdlc_device),
+					      "hdlc%d", hdlc_setup);
+	return dev ? dev_to_hdlc(dev) : NULL;
+}
 
+void free_hdlc_device(hdlc_device *hdlc)
+{
+	free_netdev(hdlc_to_dev(hdlc));
+}
 
 MODULE_AUTHOR("Krzysztof Halasa <khc@pm.waw.pl>");
 MODULE_DESCRIPTION("HDLC support module");
@@ -278,6 +285,8 @@
 EXPORT_SYMBOL(hdlc_ioctl);
 EXPORT_SYMBOL(register_hdlc_device);
 EXPORT_SYMBOL(unregister_hdlc_device);
+EXPORT_SYMBOL(alloc_hdlc_device);
+EXPORT_SYMBOL(free_hdlc_device);
 
 static struct packet_type hdlc_packet_type = {
 	.type = __constant_htons(ETH_P_HDLC),
diff -Nru a/include/linux/hdlc.h b/include/linux/hdlc.h
--- a/include/linux/hdlc.h	Mon Dec  1 14:45:08 2003
+++ b/include/linux/hdlc.h	Mon Dec  1 14:45:08 2003
@@ -96,7 +96,9 @@
 
 typedef struct hdlc_device_struct {
 	/* To be initialized by hardware driver */
-	struct net_device netdev; /* master net device - must be first */
+	struct net_device *netdev; 	/* master net device */
+	void  *dev_data;
+
 	struct net_device_stats stats;
 
 	/* used by HDLC layer to take control over HDLC device from hw driver*/
@@ -180,6 +182,8 @@
 
 
 /* Exported from hdlc.o */
+hdlc_device *alloc_hdlc_device(int sizeof_priv);
+void free_hdlc_device(hdlc_device *hdlc);
 
 /* Called by hardware driver when a user requests HDLC service */
 int hdlc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
@@ -188,18 +192,15 @@
 int register_hdlc_device(hdlc_device *hdlc);
 void unregister_hdlc_device(hdlc_device *hdlc);
 
-
 static __inline__ struct net_device* hdlc_to_dev(hdlc_device *hdlc)
 {
-	return &hdlc->netdev;
+	return hdlc->netdev;
 }
 
-
-static __inline__ hdlc_device* dev_to_hdlc(struct net_device *dev)
+static __inline__ hdlc_device *dev_to_hdlc(struct net_device *dev)
 {
-	return (hdlc_device*)dev;
+	return dev->priv;
 }
-
 
 static __inline__ pvc_device* dev_to_pvc(struct net_device *dev)
 {
