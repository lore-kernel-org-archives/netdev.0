From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 02/21] net: add RCU variant to search for netdev_adjacent link
Date: Mon,  2 Sep 2013 23:39:06 +0200
Message-ID: <1378157965-17537-3-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759041Ab3IBVjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:39:12 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we have only the RTNL flavour, however we can traverse it while
holding only RCU, so add the RCU search.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 net/core/dev.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9e4eb40..4e67a67 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4380,6 +4380,51 @@ struct netdev_adjacent {
 	struct rcu_head rcu;
 };
 
+static struct netdev_adjacent *__netdev_find_adj_rcu(struct net_device *dev,
+						     struct net_device *adj_dev,
+						     bool upper, bool neighbour)
+{
+	struct netdev_adjacent *adj;
+	struct list_head *dev_list;
+
+	if (neighbour)
+		dev_list = upper ? &dev->neighbour_dev_list.upper :
+				   &dev->neighbour_dev_list.lower;
+	else
+		dev_list = upper ? &dev->all_dev_list.upper :
+				   &dev->all_dev_list.lower;
+
+	list_for_each_entry_rcu(adj, dev_list, list) {
+		if (adj->dev == adj_dev)
+			return adj;
+	}
+	return NULL;
+}
+
+static inline struct netdev_adjacent *__netdev_find_upper_rcu(struct net_device *dev,
+							      struct net_device *udev)
+{
+	return __netdev_find_adj_rcu(dev, udev, true, false);
+}
+
+static inline struct netdev_adjacent *__netdev_find_lower_rcu(struct net_device *dev,
+							      struct net_device *ldev)
+{
+	return __netdev_find_adj_rcu(dev, ldev, false, false);
+}
+
+static inline struct netdev_adjacent *__netdev_find_upper_neighbour_rcu(struct net_device *dev,
+									struct net_device *udev)
+{
+	return __netdev_find_adj_rcu(dev, udev, true, true);
+}
+
+static inline struct netdev_adjacent *__netdev_find_lower_neighbour_rcu(struct net_device *dev,
+									struct net_device *ldev)
+{
+	return __netdev_find_adj_rcu(dev, ldev, false, true);
+}
+
 static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
 						 struct net_device *adj_dev,
 						 bool upper, bool neighbour)
-- 
1.8.4
