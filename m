From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: register_hdlc_device() doesn't need dev_alloc_name()
Date: Thu, 22 Jun 2006 22:20:19 +0200
Message-ID: <m3psh1vt6k.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:24022 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1030391AbWFVUUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 16:20:25 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Boggs noticed that register_hdlc_device() no longer needs
to call dev_alloc_name() as it's called by register_netdev().
register_hdlc_device() is currently equivalent to register_netdev().

hdlc_setup() is now EXPORTed as per David's request.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -188,7 +188,7 @@ int hdlc_x25_ioctl(struct net_device *de
 int hdlc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 
 /* Must be used by hardware driver on module startup/exit */
-int register_hdlc_device(struct net_device *dev);
+#define register_hdlc_device(dev)	register_netdev(dev)
 void unregister_hdlc_device(struct net_device *dev);
 
 struct net_device *alloc_hdlcdev(void *priv);
--- a/drivers/net/wan/hdlc_generic.c
+++ b/drivers/net/wan/hdlc_generic.c
@@ -259,7 +259,7 @@ int hdlc_ioctl(struct net_device *dev, s
 	}
 }
 
-static void hdlc_setup(struct net_device *dev)
+void hdlc_setup(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 
@@ -288,26 +288,6 @@ struct net_device *alloc_hdlcdev(void *p
 	return dev;
 }
 
-int register_hdlc_device(struct net_device *dev)
-{
-	int result = dev_alloc_name(dev, "hdlc%d");
-	if (result < 0)
-		return result;
-
-	result = register_netdev(dev);
-	if (result != 0)
-		return -EIO;
-
-#if 0
-	if (netif_carrier_ok(dev))
-		netif_carrier_off(dev); /* no carrier until DCD goes up */
-#endif
-
-	return 0;
-}
-
-
-
 void unregister_hdlc_device(struct net_device *dev)
 {
 	rtnl_lock();
@@ -326,8 +306,8 @@ EXPORT_SYMBOL(hdlc_open);
 EXPORT_SYMBOL(hdlc_close);
 EXPORT_SYMBOL(hdlc_set_carrier);
 EXPORT_SYMBOL(hdlc_ioctl);
+EXPORT_SYMBOL(hdlc_setup);
 EXPORT_SYMBOL(alloc_hdlcdev);
-EXPORT_SYMBOL(register_hdlc_device);
 EXPORT_SYMBOL(unregister_hdlc_device);
 
 static struct packet_type hdlc_packet_type = {
