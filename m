From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v2 03/13] net: remove search_list from netdev_adjacent
Date: Wed, 28 Aug 2013 14:02:22 +0200
Message-ID: <1377691352-4146-4-git-send-email-vfalico@redhat.com>
References: <1377691352-4146-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753716Ab3H1MCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 08:02:23 -0400
In-Reply-To: <1377691352-4146-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already don't need it cause we see every upper/lower device in the list
already.

v2: new patch

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 net/core/dev.c |   37 +------------------------------------
 1 files changed, 1 insertions(+), 36 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5d73f9f..9853219 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4380,42 +4380,8 @@ struct netdev_adjacent {
 	u16 ref_nr;
 	struct list_head list;
 	struct rcu_head rcu;
-	struct list_head search_list;
 };
 
-static void __append_search_uppers(struct list_head *search_list,
-				   struct net_device *dev)
-{
-	struct netdev_adjacent *upper;
-
-	list_for_each_entry(upper, &dev->upper_dev_list, list) {
-		/* check if this upper is not already in search list */
-		if (list_empty(&upper->search_list))
-			list_add_tail(&upper->search_list, search_list);
-	}
-}
-
-static bool __netdev_search_upper_dev(struct net_device *dev,
-				      struct net_device *upper_dev)
-{
-	LIST_HEAD(search_list);
-	struct netdev_adjacent *upper;
-	struct netdev_adjacent *tmp;
-	bool ret = false;
-
-	__append_search_uppers(&search_list, dev);
-	list_for_each_entry(upper, &search_list, search_list) {
-		if (upper->dev == upper_dev) {
-			ret = true;
-			break;
-		}
-		__append_search_uppers(&search_list, upper->dev);
-	}
-	list_for_each_entry_safe(upper, tmp, &search_list, search_list)
-		INIT_LIST_HEAD(&upper->search_list);
-	return ret;
-}
-
 static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
 						 struct net_device *adj_dev,
 						 bool upper)
@@ -4534,7 +4500,6 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	adj->master = master;
 	adj->neighbour = neighbour;
 	adj->ref_nr = 1;
-	INIT_LIST_HEAD(&adj->search_list);
 
 	dev_hold(adj_dev);
 	pr_debug("dev_hold for %s, because of %s link added from %s to %s\n",
@@ -4638,7 +4603,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 		return -EBUSY;
 
 	/* To prevent loops, check if dev is not upper device to upper_dev. */
-	if (__netdev_search_upper_dev(upper_dev, dev))
+	if (__netdev_find_upper(upper_dev, dev))
 		return -EBUSY;
 
 	if (__netdev_find_upper(dev, upper_dev))
-- 
1.7.1
