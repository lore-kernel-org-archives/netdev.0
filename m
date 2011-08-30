From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Tue, 30 Aug 2011 16:46:47 +0200
Message-ID: <1314715608-978-2-git-send-email-jpirko@redhat.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754280Ab1H3Oq4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 10:46:56 -0400
In-Reply-To: <1314715608-978-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow to write to "carrier" attribute. Devices may implement ndo_change_carrier
callback to allow changing carrier from userspace.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/netdevice.h |    4 ++++
 net/core/dev.c            |   19 +++++++++++++++++++
 net/core/net-sysfs.c      |   26 +++++++++++++++++++++++++-
 3 files changed, 48 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0a7f619..6bca5b7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -945,6 +945,8 @@ struct net_device_ops {
 						    u32 features);
 	int			(*ndo_set_features)(struct net_device *dev,
 						    u32 features);
+	int			(*ndo_change_carrier)(struct net_device *dev,
+						      bool new_carrier);
 };
 
 /*
@@ -2093,6 +2095,8 @@ extern int		dev_set_mtu(struct net_device *, int);
 extern void		dev_set_group(struct net_device *, int);
 extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
+extern int		dev_change_carrier(struct net_device *,
+					   bool new_carrier);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev,
 					    struct netdev_queue *txq);
diff --git a/net/core/dev.c b/net/core/dev.c
index b2e262e..11b0fc7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4793,6 +4793,25 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
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
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 56e42ab..c8f2ca4 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -126,6 +126,30 @@ static ssize_t show_broadcast(struct device *dev,
 	return -EINVAL;
 }
 
+static ssize_t store_carrier(struct device *dev, struct device_attribute *attr,
+			     const char *buf, size_t len)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	ssize_t ret;
+	int new_value;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!netif_running(netdev))
+		return -EINVAL;
+
+	if (sscanf(buf, "%d", &new_value) != 1)
+		return -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+	ret = dev_change_carrier(netdev, new_value ? true: false);
+	rtnl_unlock();
+
+	return ret < 0 ? ret : len;
+}
+
 static ssize_t show_carrier(struct device *dev,
 			    struct device_attribute *attr, char *buf)
 {
@@ -315,7 +339,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(link_mode, S_IRUGO, show_link_mode, NULL),
 	__ATTR(address, S_IRUGO, show_address, NULL),
 	__ATTR(broadcast, S_IRUGO, show_broadcast, NULL),
-	__ATTR(carrier, S_IRUGO, show_carrier, NULL),
+	__ATTR(carrier, S_IRUGO | S_IWUSR, show_carrier, store_carrier),
 	__ATTR(speed, S_IRUGO, show_speed, NULL),
 	__ATTR(duplex, S_IRUGO, show_duplex, NULL),
 	__ATTR(dormant, S_IRUGO, show_dormant, NULL),
-- 
1.7.6
