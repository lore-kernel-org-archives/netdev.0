From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: [PATCH net-next 01/11] net: Remove refnr arg when inserting link adjacencies
Date: Mon, 17 Oct 2016 19:15:43 -0700
Message-ID: <1476756953-30923-2-git-send-email-dsa@cumulusnetworks.com>
References: <1476756953-30923-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476756953-30923-1-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 93409033ae65 ("net: Add netdev all_adj_list refcnt propagation to
fix panic") propagated the refnr to insert and remove functions tracking
the netdev adjacency graph. However, for the insert path the refnr can
only be 1. Accordingly, remove the refnr argument to make that clear.
ie., the refnr arg in 93409033ae65 was only needed for the remove path.

Signed-off-by: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
---
 net/core/dev.c | 27 ++++++++++++---------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 352e98129601..f67fd16615bb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5453,7 +5453,6 @@ static inline bool netdev_adjacent_is_neigh_list(struct net_device *dev,
 
 static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					struct net_device *adj_dev,
-					u16 ref_nr,
 					struct list_head *dev_list,
 					void *private, bool master)
 {
@@ -5463,7 +5462,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	adj = __netdev_find_adj(adj_dev, dev_list);
 
 	if (adj) {
-		adj->ref_nr += ref_nr;
+		adj->ref_nr += 1;
 		return 0;
 	}
 
@@ -5473,7 +5472,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 
 	adj->dev = adj_dev;
 	adj->master = master;
-	adj->ref_nr = ref_nr;
+	adj->ref_nr = 1;
 	adj->private = private;
 	dev_hold(adj_dev);
 
@@ -5547,22 +5546,21 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 
 static int __netdev_adjacent_dev_link_lists(struct net_device *dev,
 					    struct net_device *upper_dev,
-					    u16 ref_nr,
 					    struct list_head *up_list,
 					    struct list_head *down_list,
 					    void *private, bool master)
 {
 	int ret;
 
-	ret = __netdev_adjacent_dev_insert(dev, upper_dev, ref_nr, up_list,
+	ret = __netdev_adjacent_dev_insert(dev, upper_dev, up_list,
 					   private, master);
 	if (ret)
 		return ret;
 
-	ret = __netdev_adjacent_dev_insert(upper_dev, dev, ref_nr, down_list,
+	ret = __netdev_adjacent_dev_insert(upper_dev, dev, down_list,
 					   private, false);
 	if (ret) {
-		__netdev_adjacent_dev_remove(dev, upper_dev, ref_nr, up_list);
+		__netdev_adjacent_dev_remove(dev, upper_dev, 1, up_list);
 		return ret;
 	}
 
@@ -5570,10 +5568,9 @@ static int __netdev_adjacent_dev_link_lists(struct net_device *dev,
 }
 
 static int __netdev_adjacent_dev_link(struct net_device *dev,
-				      struct net_device *upper_dev,
-				      u16 ref_nr)
+				      struct net_device *upper_dev)
 {
-	return __netdev_adjacent_dev_link_lists(dev, upper_dev, ref_nr,
+	return __netdev_adjacent_dev_link_lists(dev, upper_dev,
 						&dev->all_adj_list.upper,
 						&upper_dev->all_adj_list.lower,
 						NULL, false);
@@ -5602,12 +5599,12 @@ static int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
 						struct net_device *upper_dev,
 						void *private, bool master)
 {
-	int ret = __netdev_adjacent_dev_link(dev, upper_dev, 1);
+	int ret = __netdev_adjacent_dev_link(dev, upper_dev);
 
 	if (ret)
 		return ret;
 
-	ret = __netdev_adjacent_dev_link_lists(dev, upper_dev, 1,
+	ret = __netdev_adjacent_dev_link_lists(dev, upper_dev,
 					       &dev->adj_list.upper,
 					       &upper_dev->adj_list.lower,
 					       private, master);
@@ -5676,7 +5673,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 		list_for_each_entry(j, &upper_dev->all_adj_list.upper, list) {
 			pr_debug("Interlinking %s with %s, non-neighbour\n",
 				 i->dev->name, j->dev->name);
-			ret = __netdev_adjacent_dev_link(i->dev, j->dev, i->ref_nr);
+			ret = __netdev_adjacent_dev_link(i->dev, j->dev);
 			if (ret)
 				goto rollback_mesh;
 		}
@@ -5686,7 +5683,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	list_for_each_entry(i, &upper_dev->all_adj_list.upper, list) {
 		pr_debug("linking %s's upper device %s with %s\n",
 			 upper_dev->name, i->dev->name, dev->name);
-		ret = __netdev_adjacent_dev_link(dev, i->dev, i->ref_nr);
+		ret = __netdev_adjacent_dev_link(dev, i->dev);
 		if (ret)
 			goto rollback_upper_mesh;
 	}
@@ -5695,7 +5692,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	list_for_each_entry(i, &dev->all_adj_list.lower, list) {
 		pr_debug("linking %s's lower device %s with %s\n", dev->name,
 			 i->dev->name, upper_dev->name);
-		ret = __netdev_adjacent_dev_link(i->dev, upper_dev, i->ref_nr);
+		ret = __netdev_adjacent_dev_link(i->dev, upper_dev);
 		if (ret)
 			goto rollback_lower_mesh;
 	}
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
