From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 04/27] net: add netdev_adjacent->private and allow to use it
Date: Tue, 24 Sep 2013 13:46:44 +0200
Message-ID: <1380023227-9576-5-git-send-email-vfalico@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2267 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038Ab3IXLrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 07:47:01 -0400
In-Reply-To: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
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

Notes:
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    rename neighbour_dev_list/all_dev_list to adj_list/all_adj_list and rework
    the naming of functions - to make the use the pattern
    netdev_(all_)(lower|upper)_* .

 include/linux/netdevice.h |  7 +++++
 net/core/dev.c            | 68 +++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 64 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 514045c..75d5bea 100644
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
index 9290f09..c69ab74 100644
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
@@ -4510,7 +4513,7 @@ EXPORT_SYMBOL(netdev_master_upper_dev_get_rcu);
 static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					struct net_device *adj_dev,
 					struct list_head *dev_list,
-					bool master)
+					void *private, bool master)
 {
 	struct netdev_adjacent *adj;
 
@@ -4528,6 +4531,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	adj->dev = adj_dev;
 	adj->master = master;
 	adj->ref_nr = 1;
+	adj->private = private;
 	dev_hold(adj_dev);
 
 	pr_debug("dev_hold for %s, because of link added from %s to %s\n",
@@ -4574,15 +4578,17 @@ int __netdev_adjacent_dev_link_lists(struct net_device *dev,
 				     struct net_device *upper_dev,
 				     struct list_head *up_list,
 				     struct list_head *down_list,
-				     bool master)
+				     void *private, bool master)
 {
 	int ret;
 
-	ret = __netdev_adjacent_dev_insert(dev, upper_dev, up_list, master);
+	ret = __netdev_adjacent_dev_insert(dev, upper_dev, up_list, private,
+					   master);
 	if (ret)
 		return ret;
 
-	ret = __netdev_adjacent_dev_insert(upper_dev, dev, down_list, false);
+	ret = __netdev_adjacent_dev_insert(upper_dev, dev, down_list, private,
+					   false);
 	if (ret) {
 		__netdev_adjacent_dev_remove(dev, upper_dev, up_list);
 		return ret;
@@ -4597,7 +4603,7 @@ int __netdev_adjacent_dev_link(struct net_device *dev,
 	return __netdev_adjacent_dev_link_lists(dev, upper_dev,
 						&dev->all_adj_list.upper,
 						&upper_dev->all_adj_list.lower,
-						false);
+						NULL, false);
 }
 
 void __netdev_adjacent_dev_unlink_lists(struct net_device *dev,
@@ -4619,7 +4625,7 @@ void __netdev_adjacent_dev_unlink(struct net_device *dev,
 
 int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
 					 struct net_device *upper_dev,
-					 bool master)
+					 void *private, bool master)
 {
 	int ret = __netdev_adjacent_dev_link(dev, upper_dev);
 
@@ -4629,7 +4635,7 @@ int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
 	ret = __netdev_adjacent_dev_link_lists(dev, upper_dev,
 					       &dev->adj_list.upper,
 					       &upper_dev->adj_list.lower,
-					       master);
+					       private, master);
 	if (ret) {
 		__netdev_adjacent_dev_unlink(dev, upper_dev);
 		return ret;
@@ -4648,7 +4654,8 @@ void __netdev_adjacent_dev_unlink_neighbour(struct net_device *dev,
 }
 
 static int __netdev_upper_dev_link(struct net_device *dev,
-				   struct net_device *upper_dev, bool master)
+				   struct net_device *upper_dev, bool master,
+				   void *private)
 {
 	struct netdev_adjacent *i, *j, *to_i, *to_j;
 	int ret = 0;
@@ -4668,7 +4675,8 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	if (master && netdev_master_upper_dev_get(dev))
 		return -EBUSY;
 
-	ret = __netdev_adjacent_dev_link_neighbour(dev, upper_dev, master);
+	ret = __netdev_adjacent_dev_link_neighbour(dev, upper_dev, private,
+						   master);
 	if (ret)
 		return ret;
 
@@ -4759,7 +4767,7 @@ rollback_mesh:
 int netdev_upper_dev_link(struct net_device *dev,
 			  struct net_device *upper_dev)
 {
-	return __netdev_upper_dev_link(dev, upper_dev, false);
+	return __netdev_upper_dev_link(dev, upper_dev, false, NULL);
 }
 EXPORT_SYMBOL(netdev_upper_dev_link);
 
@@ -4777,10 +4785,18 @@ EXPORT_SYMBOL(netdev_upper_dev_link);
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
@@ -4818,6 +4834,36 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
+void *netdev_lower_dev_get_private_rcu(struct net_device *dev,
+				       struct net_device *lower_dev)
+{
+	struct netdev_adjacent *lower;
+
+	if (!lower_dev)
+		return NULL;
+	lower = __netdev_find_adj_rcu(dev, lower_dev, &dev->adj_list.lower);
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
+	lower = __netdev_find_adj(dev, lower_dev, &dev->adj_list.lower);
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
