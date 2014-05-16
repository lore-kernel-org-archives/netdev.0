From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 2/4] net: Allow for more then a single subclass for netif_addr_lock
Date: Fri, 16 May 2014 13:18:15 -0400
Message-ID: <1400260697-32601-3-git-send-email-vyasevic@redhat.com>
References: <1400260697-32601-1-git-send-email-vyasevic@redhat.com>
Cc: dingtianhong@huawei.com, kaber@trash.net, vfalico@gmail.com,
	jiri@resnulli.us, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35001 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756924AbaEPRSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 13:18:45 -0400
In-Reply-To: <1400260697-32601-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently netif_addr_lock_nested assumes that there can be only
a single nesting level between 2 devices.  However, if we
have multiple devices of the same type stacked, this fails.
For example:
 eth0 <-- vlan0.10 <-- vlan0.10.20

A more complicated configuration may stack more then one type of
device in different order.
Ex:
  eth0 <-- vlan0.10 <-- macvlan0 <-- vlan1.10.20 <-- macvlan1

This patch adds an ndo_* function that allows each stackable
device to report its nesting level.  If the device doesn't
provide this function default subclass of 1 is used.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/netdevice.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e32d313..edafa7d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1144,6 +1144,7 @@ struct net_device_ops {
 	netdev_tx_t		(*ndo_dfwd_start_xmit) (struct sk_buff *skb,
 							struct net_device *dev,
 							void *priv);
+	int			(*ndo_get_lock_subclass)(struct net_device *dev);
 };
 
 /**
@@ -2950,7 +2951,12 @@ static inline void netif_addr_lock(struct net_device *dev)
 
 static inline void netif_addr_lock_nested(struct net_device *dev)
 {
-	spin_lock_nested(&dev->addr_list_lock, SINGLE_DEPTH_NESTING);
+	int subclass = SINGLE_DEPTH_NESTING;
+
+	if (dev->netdev_ops->ndo_get_lock_subclass)
+		subclass = dev->netdev_ops->ndo_get_lock_subclass(dev);
+
+	spin_lock_nested(&dev->addr_list_lock, subclass);
 }
 
 static inline void netif_addr_lock_bh(struct net_device *dev)
-- 
1.9.0
