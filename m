From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/6] net: introduce change upper device notifier change info
Date: Wed, 26 Aug 2015 18:36:33 +0200
Message-ID: <1440606998-11072-2-git-send-email-jiri@resnulli.us>
References: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, simon.horman@netronome.com,
	Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38453 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbbHZQgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 12:36:42 -0400
Received: by wicja10 with SMTP id ja10so20598734wic.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 09:36:41 -0700 (PDT)
In-Reply-To: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add info that is passed along with NETDEV_CHANGEUPPER event.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h |  7 +++++++
 net/core/dev.c            | 16 ++++++++++++++--
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6abe0d6..39f30da 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2127,6 +2127,13 @@ struct netdev_notifier_change_info {
 	unsigned int flags_changed;
 };
 
+struct netdev_notifier_changeupper_info {
+	struct netdev_notifier_info info; /* must be first */
+	struct net_device *upper_dev; /* new upper dev */
+	bool master; /* is upper dev master */
+	bool linking; /* is the nofication for link or unlink */
+};
+
 static inline void netdev_notifier_info_init(struct netdev_notifier_info *info,
 					     struct net_device *dev)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index b1f3f48..e7ef971 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5311,6 +5311,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 				   struct net_device *upper_dev, bool master,
 				   void *private)
 {
+	struct netdev_notifier_changeupper_info changeupper_info;
 	struct netdev_adjacent *i, *j, *to_i, *to_j;
 	int ret = 0;
 
@@ -5329,6 +5330,10 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	if (master && netdev_master_upper_dev_get(dev))
 		return -EBUSY;
 
+	changeupper_info.upper_dev = upper_dev;
+	changeupper_info.master = master;
+	changeupper_info.linking = true;
+
 	ret = __netdev_adjacent_dev_link_neighbour(dev, upper_dev, private,
 						   master);
 	if (ret)
@@ -5367,7 +5372,8 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 			goto rollback_lower_mesh;
 	}
 
-	call_netdevice_notifiers(NETDEV_CHANGEUPPER, dev);
+	call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
+				      &changeupper_info.info);
 	return 0;
 
 rollback_lower_mesh:
@@ -5462,9 +5468,14 @@ EXPORT_SYMBOL(netdev_master_upper_dev_link_private);
 void netdev_upper_dev_unlink(struct net_device *dev,
 			     struct net_device *upper_dev)
 {
+	struct netdev_notifier_changeupper_info changeupper_info;
 	struct netdev_adjacent *i, *j;
 	ASSERT_RTNL();
 
+	changeupper_info.upper_dev = upper_dev;
+	changeupper_info.master = netdev_master_upper_dev_get(dev) == upper_dev;
+	changeupper_info.linking = false;
+
 	__netdev_adjacent_dev_unlink_neighbour(dev, upper_dev);
 
 	/* Here is the tricky part. We must remove all dev's lower
@@ -5484,7 +5495,8 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list)
 		__netdev_adjacent_dev_unlink(dev, i->dev);
 
-	call_netdevice_notifiers(NETDEV_CHANGEUPPER, dev);
+	call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
+				      &changeupper_info.info);
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
-- 
1.9.3
