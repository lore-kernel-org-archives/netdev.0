From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net 1/2] net: dev: add netdev_upper_dev_rename()
Date: Mon, 13 Jan 2014 21:08:14 +0800
Message-ID: <52D3E53E.1010402@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:2469 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaAMNIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 08:08:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function will deal with the links for dev and upper_dev
when the dev's name changed.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 include/linux/netdevice.h |  3 +++
 net/core/dev.c            | 57 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ce2a1f5..1120278 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2896,6 +2896,9 @@ void *netdev_lower_dev_get_private_rcu(struct net_device *dev,
 				       struct net_device *lower_dev);
 void *netdev_lower_dev_get_private(struct net_device *dev,
 				   struct net_device *lower_dev);
+int netdev_upper_dev_rename(struct net_device *dev,
+			    struct net_device *upper_dev,
+			    const char *old_name, const char *new_name);
 int skb_checksum_help(struct sk_buff *skb);
 struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 				  netdev_features_t features, bool tx_path);
diff --git a/net/core/dev.c b/net/core/dev.c
index 0ce469e..31bff66 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4997,6 +4997,63 @@ void *netdev_lower_dev_get_private(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_lower_dev_get_private);
 
+int netdev_upper_dev_rename(struct net_device *dev,
+			    struct net_device *upper_dev,
+			    const char *old_name, const char *new_name)
+{
+	int ret = 0;
+	struct netdev_adjacent *i, *to_i;
+
+	sysfs_remove_link(&(dev->dev.kobj), old_name);
+	ret = sysfs_create_link(&(dev->dev.kobj), &(upper_dev->dev.kobj),
+				new_name);
+	if (ret) {
+		pr_warn("%s unable to rename link %s to %s.\n",
+			dev->name, old_name, new_name);
+		goto rollback_name;
+	}
+
+	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
+		sysfs_remove_link(&(i->dev->dev.kobj), old_name);
+		ret = sysfs_create_link(&(i->dev->dev.kobj),
+					&(upper_dev->dev.kobj),
+					new_name);
+		if (ret) {
+			pr_warn("%s unable to rename link %s to %s.\n",
+				dev->name, old_name, new_name);
+			goto rollback_lower_name;
+		}
+	}
+
+	return ret;
+
+rollback_lower_name:
+	to_i = i;
+	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
+		sysfs_remove_link(&(i->dev->dev.kobj), new_name);
+		if (sysfs_create_link(&(i->dev->dev.kobj),
+				      &(upper_dev->dev.kobj),
+				      old_name)) {
+			pr_err("%s unable to rename link %s to %s.\n",
+			       i->dev->name, new_name, old_name);
+			BUG();
+		}
+		if (i == to_i)
+			break;
+	}
+rollback_name:
+	sysfs_remove_link(&(dev->dev.kobj), new_name);
+	if (sysfs_create_link(&(dev->dev.kobj), &(upper_dev->dev.kobj),
+			      old_name)) {
+		pr_err("%s unable to rename link %s to %s.\n",
+		       dev->name, new_name, old_name);
+		BUG();
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(netdev_upper_dev_rename);
+
 static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-- 
1.8.0
