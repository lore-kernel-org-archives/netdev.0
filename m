From: Matan Barak <matanb@mellanox.com>
Subject: [PATCH for-next V7 02/10] net: Add info for NETDEV_CHANGEUPPER event
Date: Thu, 30 Jul 2015 18:33:23 +0300
Message-ID: <1438270411-17648-3-git-send-email-matanb@mellanox.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
Cc: Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	linux-rdma@vger.kernel.org, Sean Hefty <sean.hefty@intel.com>,
	Somnath Kotur <Somnath.Kotur@Avagotech.Com>,
	Moni Shoua <monis@mellanox.com>, talal@mellanox.com,
	haggaie@mellanox.com, netdev@vger.kernel.org
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45326 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751136AbbG3PfT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jul 2015 11:35:19 -0400
In-Reply-To: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some consumers of NETDEV_CHANGEUPPER event would like to know which
upper device was linked/unlinked and what operation was carried.

Add information in the notifier info block for that purpose.

Signed-off-by: Matan Barak <matanb@mellanox.com>
---
 include/linux/netdevice.h | 14 ++++++++++++++
 net/core/dev.c            | 12 ++++++++++--
 2 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e20979d..2b7fe4e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3556,6 +3556,20 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 				    netdev_features_t features);
 
+enum netdev_changeupper_event {
+	NETDEV_CHANGEUPPER_LINK,
+	NETDEV_CHANGEUPPER_UNLINK,
+};
+
+struct netdev_changeupper_info {
+	struct netdev_notifier_info	info; /* must be first */
+	enum netdev_changeupper_event	event;
+	struct net_device		*upper;
+};
+
+void netdev_changeupper_info_change(struct net_device *dev,
+				    struct netdev_changeupper_info *info);
+
 struct netdev_bonding_info {
 	ifslave	slave;
 	ifbond	master;
diff --git a/net/core/dev.c b/net/core/dev.c
index a8e4dd4..6e6f14e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5302,6 +5302,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 				   void *private)
 {
 	struct netdev_adjacent *i, *j, *to_i, *to_j;
+	struct netdev_changeupper_info changeupper_info;
 	int ret = 0;
 
 	ASSERT_RTNL();
@@ -5357,7 +5358,10 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 			goto rollback_lower_mesh;
 	}
 
-	call_netdevice_notifiers(NETDEV_CHANGEUPPER, dev);
+	changeupper_info.event = NETDEV_CHANGEUPPER_LINK;
+	changeupper_info.upper = upper_dev;
+	call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
+				      &changeupper_info.info);
 	return 0;
 
 rollback_lower_mesh:
@@ -5453,6 +5457,7 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 			     struct net_device *upper_dev)
 {
 	struct netdev_adjacent *i, *j;
+	struct netdev_changeupper_info changeupper_info;
 	ASSERT_RTNL();
 
 	__netdev_adjacent_dev_unlink_neighbour(dev, upper_dev);
@@ -5474,7 +5479,10 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list)
 		__netdev_adjacent_dev_unlink(dev, i->dev);
 
-	call_netdevice_notifiers(NETDEV_CHANGEUPPER, dev);
+	changeupper_info.event = NETDEV_CHANGEUPPER_UNLINK;
+	changeupper_info.upper = upper_dev;
+	call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
+				      &changeupper_info.info);
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
-- 
2.1.0

Cc: netdev@vger.kernel.org
