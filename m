From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next V3 1/4] net: add change_carrier netdev op
Date: Wed, 19 Dec 2012 10:00:52 +0100
Message-ID: <20121219090052.GC1637@minipsycho.orion>
References: <1355868858-1713-1-git-send-email-jiri@resnulli.us>
 <1355868858-1713-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, fbl@redhat.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:53668 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab2LSJA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 04:00:57 -0500
Received: by mail-ea0-f173.google.com with SMTP id i13so665558eaa.18
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 01:00:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1355868858-1713-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows a driver to register change_carrier callback which will be
called whenever user will like to change carrier state. This is useful
for devices like dummy, gre, team and so on.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h | 12 ++++++++++++
 net/core/dev.c            | 19 +++++++++++++++++++
 2 files changed, 31 insertions(+)

V2->V3: updated comment by Dan Williams

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 02e0f6b..22ca4a8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -891,6 +891,14 @@ struct netdev_fcoe_hbainfo {
  * int (*ndo_bridge_setlink)(struct net_device *dev, struct nlmsghdr *nlh)
  * int (*ndo_bridge_getlink)(struct sk_buff *skb, u32 pid, u32 seq,
  *			     struct net_device *dev)
+ *
+ * int (*ndo_change_carrier)(struct net_device *dev, bool new_carrier);
+ *	Called to change device carrier. Soft-devices (like dummy, team, etc)
+ *	which do not represent real hardware may define this to allow their
+ *	userspace components to manage their virtual carrier state. Devices
+ *	that determine carrier state from physical hardware properties (eg
+ *	network cables) or protocol-dependent mechanisms (eg
+ *	USB_CDC_NOTIFY_NETWORK_CONNECTION) should NOT implement this function.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1008,6 +1016,8 @@ struct net_device_ops {
 	int			(*ndo_bridge_getlink)(struct sk_buff *skb,
 						      u32 pid, u32 seq,
 						      struct net_device *dev);
+	int			(*ndo_change_carrier)(struct net_device *dev,
+						      bool new_carrier);
 };
 
 /*
@@ -2194,6 +2204,8 @@ extern int		dev_set_mtu(struct net_device *, int);
 extern void		dev_set_group(struct net_device *, int);
 extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
+extern int		dev_change_carrier(struct net_device *,
+					   bool new_carrier);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev,
 					    struct netdev_queue *txq);
diff --git a/net/core/dev.c b/net/core/dev.c
index d0cbc93..268a714 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5027,6 +5027,25 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 }
 EXPORT_SYMBOL(dev_set_mac_address);
 
+/**
+ *	dev_change_carrier - Change device carrier
+ *	@dev: device
+ *	@new_carries: new value
+ *
+ *	Change device carrier
+ */
+int dev_change_carrier(struct net_device *dev, bool new_carrier)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_change_carrier)
+		return -EOPNOTSUPP;
+	if (!netif_device_present(dev))
+		return -ENODEV;
+	return ops->ndo_change_carrier(dev, new_carrier);
+}
+EXPORT_SYMBOL(dev_change_carrier);
+
 /*
  *	Perform the SIOCxIFxxx calls, inside rcu_read_lock()
  */
-- 
1.8.0
