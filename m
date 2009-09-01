From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH net-next] can: add can_free_echo_skb() for upcoming drivers
Date: Tue, 01 Sep 2009 17:26:12 +0200
Message-ID: <4A9D3D14.90201@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:47577 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497AbZIAP0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 11:26:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the function can_free_echo_skb to the CAN
device interface to allow upcoming drivers to release echo
skb's in case of error.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/dev.c   |   18 +++++++++++++++++-
 include/linux/can/dev.h |    1 +
 2 files changed, 18 insertions(+), 1 deletion(-)

Index: net-next-2.6/drivers/net/can/dev.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/dev.c
+++ net-next-2.6/drivers/net/can/dev.c
@@ -315,7 +315,7 @@ void can_get_echo_skb(struct net_device 
 {
 	struct can_priv *priv = netdev_priv(dev);
 
-	if ((dev->flags & IFF_ECHO) && priv->echo_skb[idx]) {
+	if (priv->echo_skb[idx]) {
 		netif_rx(priv->echo_skb[idx]);
 		priv->echo_skb[idx] = NULL;
 	}
@@ -323,6 +323,22 @@ void can_get_echo_skb(struct net_device 
 EXPORT_SYMBOL_GPL(can_get_echo_skb);
 
 /*
+  * Remove the skb from the stack and free it.
+  *
+  * The function is typically called when TX failed.
+  */
+void can_free_echo_skb(struct net_device *dev, int idx)
+{
+	struct can_priv *priv = netdev_priv(dev);
+
+	if (priv->echo_skb[idx]) {
+		kfree_skb(priv->echo_skb[idx]);
+		priv->echo_skb[idx] = NULL;
+	}
+}
+EXPORT_SYMBOL_GPL(can_free_echo_skb);
+
+/*
  * CAN device restart for bus-off recovery
  */
 void can_restart(unsigned long data)
Index: net-next-2.6/include/linux/can/dev.h
===================================================================
--- net-next-2.6.orig/include/linux/can/dev.h
+++ net-next-2.6/include/linux/can/dev.h
@@ -66,5 +66,6 @@ void can_bus_off(struct net_device *dev)
 
 void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev, int idx);
 void can_get_echo_skb(struct net_device *dev, int idx);
+void can_free_echo_skb(struct net_device *dev, int idx);
 
 #endif /* CAN_DEV_H */
