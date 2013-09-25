From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 01/27] net: use lists as arguments instead of bool upper
Date: Wed, 25 Sep 2013 09:20:06 +0200
Message-ID: <1380093632-1842-2-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5680 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949Ab3IYHU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:20:28 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we make use of bool upper when we want to specify if we want to
work with upper/lower list. It's, however, harder to read, debug and
occupies a lot more code.

Fix this by just passing the correct upper/lower_dev_list list_head pointer
instead of bool upper, and work internally with it.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v4  -> v5
    No change.
    
    RFC -> v4:
    New patch.

 net/core/dev.c | 54 ++++++++++++++++++++++--------------------------------
 1 file changed, 22 insertions(+), 32 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5c713f2..9be7937 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4385,12 +4385,9 @@ struct netdev_adjacent {
 
 static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
 						 struct net_device *adj_dev,
-						 bool upper)
+						 struct list_head *dev_list)
 {
 	struct netdev_adjacent *adj;
-	struct list_head *dev_list;
-
-	dev_list = upper ? &dev->upper_dev_list : &dev->lower_dev_list;
 
 	list_for_each_entry(adj, dev_list, list) {
 		if (adj->dev == adj_dev)
@@ -4402,13 +4399,13 @@ static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
 static inline struct netdev_adjacent *__netdev_find_upper(struct net_device *dev,
 							  struct net_device *udev)
 {
-	return __netdev_find_adj(dev, udev, true);
+	return __netdev_find_adj(dev, udev, &dev->upper_dev_list);
 }
 
 static inline struct netdev_adjacent *__netdev_find_lower(struct net_device *dev,
 							  struct net_device *ldev)
 {
-	return __netdev_find_adj(dev, ldev, false);
+	return __netdev_find_adj(dev, ldev, &dev->lower_dev_list);
 }
 
 /**
@@ -4514,12 +4511,12 @@ EXPORT_SYMBOL(netdev_master_upper_dev_get_rcu);
 
 static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					struct net_device *adj_dev,
-					bool neighbour, bool master,
-					bool upper)
+					struct list_head *dev_list,
+					bool neighbour, bool master)
 {
 	struct netdev_adjacent *adj;
 
-	adj = __netdev_find_adj(dev, adj_dev, upper);
+	adj = __netdev_find_adj(dev, adj_dev, dev_list);
 
 	if (adj) {
 		BUG_ON(neighbour);
@@ -4538,19 +4535,14 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 
 	dev_hold(adj_dev);
 	pr_debug("dev_hold for %s, because of %s link added from %s to %s\n",
-		 adj_dev->name, upper ? "upper" : "lower", dev->name,
-		 adj_dev->name);
+		 adj_dev->name, dev_list == &dev->upper_dev_list ?
+		 "upper" : "lower", dev->name, adj_dev->name);
 
-	if (!upper) {
-		list_add_tail_rcu(&adj->list, &dev->lower_dev_list);
-		return 0;
-	}
-
-	/* Ensure that master upper link is always the first item in list. */
+	/* Ensure that master link is always the first item in list. */
 	if (master)
-		list_add_rcu(&adj->list, &dev->upper_dev_list);
+		list_add_rcu(&adj->list, dev_list);
 	else
-		list_add_tail_rcu(&adj->list, &dev->upper_dev_list);
+		list_add_tail_rcu(&adj->list, dev_list);
 
 	return 0;
 }
@@ -4559,27 +4551,25 @@ static inline int __netdev_upper_dev_insert(struct net_device *dev,
 					    struct net_device *udev,
 					    bool master, bool neighbour)
 {
-	return __netdev_adjacent_dev_insert(dev, udev, neighbour, master,
-					    true);
+	return __netdev_adjacent_dev_insert(dev, udev, &dev->upper_dev_list,
+					    neighbour, master);
 }
 
 static inline int __netdev_lower_dev_insert(struct net_device *dev,
 					    struct net_device *ldev,
 					    bool neighbour)
 {
-	return __netdev_adjacent_dev_insert(dev, ldev, neighbour, false,
-					    false);
+	return __netdev_adjacent_dev_insert(dev, ldev, &dev->lower_dev_list,
+					    neighbour, false);
 }
 
 void __netdev_adjacent_dev_remove(struct net_device *dev,
-				  struct net_device *adj_dev, bool upper)
+				  struct net_device *adj_dev,
+				  struct list_head *dev_list)
 {
 	struct netdev_adjacent *adj;
 
-	if (upper)
-		adj = __netdev_find_upper(dev, adj_dev);
-	else
-		adj = __netdev_find_lower(dev, adj_dev);
+	adj = __netdev_find_adj(dev, adj_dev, dev_list);
 
 	if (!adj)
 		BUG();
@@ -4591,8 +4581,8 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 
 	list_del_rcu(&adj->list);
 	pr_debug("dev_put for %s, because of %s link removed from %s to %s\n",
-		 adj_dev->name, upper ? "upper" : "lower", dev->name,
-		 adj_dev->name);
+		 adj_dev->name, dev_list == &dev->upper_dev_list ?
+		 "upper" : "lower", dev->name, adj_dev->name);
 	dev_put(adj_dev);
 	kfree_rcu(adj, rcu);
 }
@@ -4600,13 +4590,13 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 static inline void __netdev_upper_dev_remove(struct net_device *dev,
 					     struct net_device *udev)
 {
-	return __netdev_adjacent_dev_remove(dev, udev, true);
+	return __netdev_adjacent_dev_remove(dev, udev, &dev->upper_dev_list);
 }
 
 static inline void __netdev_lower_dev_remove(struct net_device *dev,
 					     struct net_device *ldev)
 {
-	return __netdev_adjacent_dev_remove(dev, ldev, false);
+	return __netdev_adjacent_dev_remove(dev, ldev, &dev->lower_dev_list);
 }
 
 int __netdev_adjacent_dev_insert_link(struct net_device *dev,
-- 
1.8.4
