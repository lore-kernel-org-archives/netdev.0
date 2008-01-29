From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: netdev->priv and netdev_priv(dev)
Date: Tue, 29 Jan 2008 21:10:00 +0100
Message-ID: <m3tzkwv1ev.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:46709 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752888AbYA2UKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 15:10:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A commit few months ago introduced a change:

--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
 
 static inline void *netdev_priv(const struct net_device *dev)
 {
-       return (char *)dev + ((sizeof(struct net_device)
-                                       + NETDEV_ALIGN_CONST)
-                               & ~NETDEV_ALIGN_CONST);
+       return dev->priv;
 }
 
This change caused some problems for drivers which used
netdev_priv(dev) and dev->priv for different purposes.


The following patch restores previous behaviour.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -584,7 +584,10 @@ struct net_device
 
 static inline void *netdev_priv(const struct net_device *dev)
 {
-	return dev->priv;
+	return (char *)dev + ((sizeof(struct net_device) +
+			       sizeof(struct net_device_subqueue) *
+			       (dev->egress_subqueue_count - 1) +
+			       NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 }
 
 #define SET_MODULE_OWNER(dev) do { } while (0)
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3693,13 +3693,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		(((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 	dev->padded = (char *)dev - (char *)p;
 
-	if (sizeof_priv) {
-		dev->priv = ((char *)dev +
-			     ((sizeof(struct net_device) +
-			       (sizeof(struct net_device_subqueue) *
-				(queue_count - 1)) + NETDEV_ALIGN_CONST)
-			      & ~NETDEV_ALIGN_CONST));
-	}
+	if (sizeof_priv)
+		dev->priv = netdev_priv(dev);
 
 	dev->egress_subqueue_count = queue_count;
 
