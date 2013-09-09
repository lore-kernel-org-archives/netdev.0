From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 04/26] net: add netdev_adjacent->private and allow to use it
Date: Mon,  9 Sep 2013 22:16:22 +0200
Message-ID: <1378757804-3159-5-git-send-email-vfalico@redhat.com>
References: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755946Ab3IIUQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 16:16:37 -0400
In-Reply-To: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, even though we can access any linked device, we can't attach
anything to it, which is vital to properly manage them.

To fix this, add a new void *private to netdev_adjacent and functions
setting/getting it (per link), so that we can save, per example, bonding's
slave structures there, per slave device.

netdev_master_upper_dev_link_private(dev, upper_dev, private) links dev to
upper dev and populates the neighbour link only with private.

netdev_lower_dev_get_private{,_rcu}() returns the private, if found.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/linux/netdevice.h |  7 ++++
 net/core/dev.c            | 83 ++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 75 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2a944e5..eab8e36 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2839,8 +2839,15 @@ extern int netdev_upper_dev_link(struct net_device *dev,
 				 struct net_device *upper_dev);
 extern int netdev_master_upper_dev_link(struct net_device *dev,
 					struct net_device *upper_dev);
+extern int netdev_master_upper_dev_link_private(struct net_device *dev,
+						struct net_device *upper_dev,
+						void *private);
 extern void netdev_upper_dev_unlink(struct net_device *dev,
 				    struct net_device *upper_dev);
+extern void *netdev_lower_dev_get_private_rcu(struct net_device *dev,
+					      struct net_device *lower_dev);
+extern void *netdev_lower_dev_get_private(struct net_device *dev,
+					  struct net_device *lower_dev);
 extern int skb_checksum_help(struct sk_buff *skb);
 extern struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 	netdev_features_t features, bool tx_path);
diff --git a/net/core/dev.c b/net/core/dev.c
index eef99de..9528e8f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4376,6 +4376,9 @@ struct netdev_adjacent {
 	/* counter for the number of times this device was added to us */
 	u16 ref_nr;
 
+	/* private field for the users */
+	void *private;
+
 	struct list_head list;
 	struct rcu_head rcu;
 };
@@ -4556,7 +4559,7 @@ EXPORT_SYMBOL(netdev_master_upper_dev_get_rcu);
 static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					struct net_device *adj_dev,
 					bool neighbour, bool master,
-					bool upper)
+					bool upper, void *private)
 {
 	struct netdev_adjacent *adj, *neigh = NULL;
 
@@ -4599,9 +4602,15 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 			 adj_dev->name);
 
 	if (!upper) {
-		if (neigh)
+		if (neigh) {
+			/* we're backlinging the master device to its
+			 * slave, so save the private in this link.
+			 */
+			if (master)
+				neigh->private = private;
 			list_add_tail_rcu(&neigh->list,
 					  &dev->adj_list.lower);
+		}
 		list_add_tail_rcu(&adj->list, &dev->all_adj_list.lower);
 		return 0;
 	}
@@ -4627,15 +4636,16 @@ static int __netdev_upper_dev_insert(struct net_device *dev,
 				     bool master, bool neighbour)
 {
 	return __netdev_adjacent_dev_insert(dev, udev, neighbour, master,
-					    true);
+					    true, NULL);
 }
 
 static int __netdev_lower_dev_insert(struct net_device *dev,
 				     struct net_device *ldev,
-				     bool neighbour)
+				     bool master, bool neighbour,
+				     void *private)
 {
-	return __netdev_adjacent_dev_insert(dev, ldev, neighbour, false,
-					    false);
+	return __netdev_adjacent_dev_insert(dev, ldev, neighbour, master,
+					    false, private);
 }
 
 void __netdev_adjacent_dev_remove(struct net_device *dev,
@@ -4703,7 +4713,8 @@ static void __netdev_lower_dev_remove(struct net_device *dev,
 
 int __netdev_adjacent_dev_insert_link(struct net_device *dev,
 				      struct net_device *upper_dev,
-				      bool master, bool neighbour)
+				      bool master, bool neighbour,
+				      void *private)
 {
 	int ret;
 
@@ -4711,7 +4722,8 @@ int __netdev_adjacent_dev_insert_link(struct net_device *dev,
 	if (ret)
 		return ret;
 
-	ret = __netdev_lower_dev_insert(upper_dev, dev, neighbour);
+	ret = __netdev_lower_dev_insert(upper_dev, dev, master, neighbour,
+					private);
 	if (ret) {
 		__netdev_upper_dev_remove(dev, upper_dev);
 		return ret;
@@ -4723,14 +4735,15 @@ int __netdev_adjacent_dev_insert_link(struct net_device *dev,
 static int __netdev_adjacent_dev_link(struct net_device *dev,
 				      struct net_device *udev)
 {
-	return __netdev_adjacent_dev_insert_link(dev, udev, false, false);
+	return __netdev_adjacent_dev_insert_link(dev, udev, false, false, NULL);
 }
 
 static int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
 						struct net_device *udev,
-						bool master)
+						bool master, void *priv)
 {
-	return __netdev_adjacent_dev_insert_link(dev, udev, master, true);
+	return __netdev_adjacent_dev_insert_link(dev, udev, master, true,
+						 priv);
 }
 
 void __netdev_adjacent_dev_unlink(struct net_device *dev,
@@ -4742,7 +4755,8 @@ void __netdev_adjacent_dev_unlink(struct net_device *dev,
 
 
 static int __netdev_upper_dev_link(struct net_device *dev,
-				   struct net_device *upper_dev, bool master)
+				   struct net_device *upper_dev, bool master,
+				   void *private)
 {
 	struct netdev_adjacent *i, *j, *to_i, *to_j;
 	int ret = 0;
@@ -4762,7 +4776,8 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	if (master && netdev_master_upper_dev_get(dev))
 		return -EBUSY;
 
-	ret = __netdev_adjacent_dev_link_neighbour(dev, upper_dev, master);
+	ret = __netdev_adjacent_dev_link_neighbour(dev, upper_dev, master,
+						   private);
 	if (ret)
 		return ret;
 
@@ -4853,7 +4868,7 @@ rollback_mesh:
 int netdev_upper_dev_link(struct net_device *dev,
 			  struct net_device *upper_dev)
 {
-	return __netdev_upper_dev_link(dev, upper_dev, false);
+	return __netdev_upper_dev_link(dev, upper_dev, false, NULL);
 }
 EXPORT_SYMBOL(netdev_upper_dev_link);
 
@@ -4871,10 +4886,18 @@ EXPORT_SYMBOL(netdev_upper_dev_link);
 int netdev_master_upper_dev_link(struct net_device *dev,
 				 struct net_device *upper_dev)
 {
-	return __netdev_upper_dev_link(dev, upper_dev, true);
+	return __netdev_upper_dev_link(dev, upper_dev, true, NULL);
 }
 EXPORT_SYMBOL(netdev_master_upper_dev_link);
 
+int netdev_master_upper_dev_link_private(struct net_device *dev,
+					 struct net_device *upper_dev,
+					 void *private)
+{
+	return __netdev_upper_dev_link(dev, upper_dev, true, private);
+}
+EXPORT_SYMBOL(netdev_master_upper_dev_link_private);
+
 /**
  * netdev_upper_dev_unlink - Removes a link to upper device
  * @dev: device
@@ -4912,6 +4935,36 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
+void *netdev_lower_dev_get_private_rcu(struct net_device *dev,
+				       struct net_device *lower_dev)
+{
+	struct netdev_adjacent *lower;
+
+	if (!lower_dev)
+		return NULL;
+	lower = __netdev_lower_find_rcu(dev, lower_dev);
+	if (!lower)
+		return NULL;
+
+	return lower->private;
+}
+EXPORT_SYMBOL(netdev_lower_dev_get_private_rcu);
+
+void *netdev_lower_dev_get_private(struct net_device *dev,
+				   struct net_device *lower_dev)
+{
+	struct netdev_adjacent *lower;
+
+	if (!lower_dev)
+		return NULL;
+	lower = __netdev_lower_find(dev, lower_dev);
+	if (!lower)
+		return NULL;
+
+	return lower->private;
+}
+EXPORT_SYMBOL(netdev_lower_dev_get_private);
+
 static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-- 
1.8.4
