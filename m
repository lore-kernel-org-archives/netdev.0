From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: move ndo_features_check() close to
 ndo_start_xmit()
Date: Wed, 06 Jan 2016 06:53:50 -0800
Message-ID: <1452092030.8255.178.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34297 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbcAFOxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 09:53:52 -0500
Received: by mail-pa0-f50.google.com with SMTP id uo6so216058556pac.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 06:53:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TX fast path uses ndo_start_xmit(), ndo_features_check() and
ndo_select_queue().

Move ndo_features_check() close to ndo_start_xmit() to increase
data locality.

All "struct net_device_ops" should now be using C99 initializers.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c20b814e46a0..8d8e5ca951b4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -812,6 +812,12 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *        (can also return NETDEV_TX_LOCKED iff NETIF_F_LLTX)
  *	Required can not be NULL.
  *
+ * netdev_features_t (*ndo_fix_features)(struct net_device *dev,
+ *		netdev_features_t features);
+ *	Adjusts the requested feature flags according to device-specific
+ *	constraints, and returns the resulting flags. Must not modify
+ *	the device state.
+ *
  * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb,
  *                         void *accel_priv, select_queue_fallback_t fallback);
  *	Called to decide which queue to when device supports multiple
@@ -959,12 +965,6 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Called to release previously enslaved netdev.
  *
  *      Feature/offload setting functions.
- * netdev_features_t (*ndo_fix_features)(struct net_device *dev,
- *		netdev_features_t features);
- *	Adjusts the requested feature flags according to device-specific
- *	constraints, and returns the resulting flags. Must not modify
- *	the device state.
- *
  * int (*ndo_set_features)(struct net_device *dev, netdev_features_t features);
  *	Called to update device configuration to new features. Passed
  *	feature set might be less than what was returned by ndo_fix_features()).
@@ -1081,8 +1081,11 @@ struct net_device_ops {
 	void			(*ndo_uninit)(struct net_device *dev);
 	int			(*ndo_open)(struct net_device *dev);
 	int			(*ndo_stop)(struct net_device *dev);
-	netdev_tx_t		(*ndo_start_xmit) (struct sk_buff *skb,
-						   struct net_device *dev);
+	netdev_tx_t		(*ndo_start_xmit)(struct sk_buff *skb,
+						  struct net_device *dev);
+	netdev_features_t	(*ndo_features_check)(struct sk_buff *skb,
+						      struct net_device *dev,
+						      netdev_features_t features);
 	u16			(*ndo_select_queue)(struct net_device *dev,
 						    struct sk_buff *skb,
 						    void *accel_priv,
@@ -1245,9 +1248,6 @@ struct net_device_ops {
 							struct net_device *dev,
 							void *priv);
 	int			(*ndo_get_lock_subclass)(struct net_device *dev);
-	netdev_features_t	(*ndo_features_check) (struct sk_buff *skb,
-						       struct net_device *dev,
-						       netdev_features_t features);
 	int			(*ndo_set_tx_maxrate)(struct net_device *dev,
 						      int queue_index,
 						      u32 maxrate);
