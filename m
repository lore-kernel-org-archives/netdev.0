From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: [PATCH net-next 11/11] net: dev: Improve debug statements for adjacency tracking
Date: Wed, 12 Oct 2016 13:51:59 -0700
Message-ID: <1476305519-28833-12-git-send-email-dsa@cumulusnetworks.com>
References: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476305519-28833-1-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adjacency code only has debugs for the insert case. Add debugs for
the remove path and make both consistently worded to make it easier
to follow the insert and removal with reference counts.

In addition, change the BUG to a WARN_ON. A missing adjacency at
removal time is not cause for a panic.

Signed-off-by: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
---
 net/core/dev.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 52e70a3d61a4..ad5e7bfda403 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5700,6 +5700,9 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 
 	if (adj) {
 		adj->ref_nr += 1;
+		pr_debug("Insert adjacency: dev %s adj_dev %s adj->ref_nr %d\n",
+			 dev->name, adj_dev->name, adj->ref_nr);
+
 		return 0;
 	}
 
@@ -5713,8 +5716,8 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	adj->private = private;
 	dev_hold(adj_dev);
 
-	pr_debug("dev_hold for %s, because of link added from %s to %s\n",
-		 adj_dev->name, dev->name, adj_dev->name);
+	pr_debug("Insert adjacency: dev %s adj_dev %s adj->ref_nr %d; dev_hold on %s\n",
+		 dev->name, adj_dev->name, adj->ref_nr, adj_dev->name);
 
 	if (netdev_adjacent_is_neigh_list(dev, adj_dev, dev_list)) {
 		ret = netdev_adjacent_sysfs_add(dev, adj_dev, dev_list);
@@ -5753,17 +5756,22 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 {
 	struct netdev_adjacent *adj;
 
+	pr_debug("Remove adjacency: dev %s adj_dev %s ref_nr %d\n",
+		 dev->name, adj_dev->name, ref_nr);
+
 	adj = __netdev_find_adj(adj_dev, dev_list);
 
 	if (!adj) {
-		pr_err("tried to remove device %s from %s\n",
+		pr_err("Adjacency does not exist for device %s from %s\n",
 		       dev->name, adj_dev->name);
-		BUG();
+		WARN_ON(1);
+		return;
 	}
 
 	if (adj->ref_nr > ref_nr) {
-		pr_debug("%s to %s ref_nr-%d = %d\n", dev->name, adj_dev->name,
-			 ref_nr, adj->ref_nr-ref_nr);
+		pr_debug("adjacency: %s to %s ref_nr - %d = %d\n",
+			 dev->name, adj_dev->name, ref_nr,
+			 adj->ref_nr - ref_nr);
 		adj->ref_nr -= ref_nr;
 		return;
 	}
@@ -5775,7 +5783,7 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 		netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
 
 	list_del_rcu(&adj->list);
-	pr_debug("dev_put for %s, because link removed from %s to %s\n",
+	pr_debug("adjacency: dev_put for %s, because link removed from %s to %s\n",
 		 adj_dev->name, dev->name, adj_dev->name);
 	dev_put(adj_dev);
 	kfree_rcu(adj, rcu);
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
