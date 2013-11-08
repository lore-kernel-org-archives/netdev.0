From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 5/10] net: add and export netdev_adjacent_get_private_rcu()
Date: Fri, 8 Nov 2013 10:08:00 +0800
Message-ID: <527C4780.7010408@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:42060 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757308Ab3KHC3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:29:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bonding, the bond lock could not protect slave list any more,
the bond lock will be replace with RTNL or RCU, sometimes
bonding needs netdev_adjacent_get_private_rcu() to get a slave in
RCU protect, so add a new function and export it.

Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 include/linux/netdevice.h |  1 +
 net/core/dev.c            | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e6353ca..c27bb4a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2840,6 +2840,7 @@ void *netdev_lower_get_next_private_rcu(struct net_device *dev,
 	     priv = netdev_lower_get_next_private_rcu(dev, &(iter)))
 
 void *netdev_adjacent_get_private(struct list_head *adj_list);
+void *netdev_adjacent_get_private_rcu(struct list_head *adj_list);
 struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
 int netdev_upper_dev_link(struct net_device *dev, struct net_device *upper_dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 0e61365..92613a2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4478,6 +4478,16 @@ void *netdev_adjacent_get_private(struct list_head *adj_list)
 }
 EXPORT_SYMBOL(netdev_adjacent_get_private);
 
+void *netdev_adjacent_get_private_rcu(struct list_head *adj_list)
+{
+	struct netdev_adjacent *adj;
+
+	adj = list_entry_rcu(adj_list, struct netdev_adjacent, list);
+
+	return adj->private;
+}
+EXPORT_SYMBOL(netdev_adjacent_get_private_rcu);
+
 /**
  * netdev_all_upper_get_next_dev_rcu - Get the next dev from upper list
  * @dev: device
-- 
1.8.2.1
