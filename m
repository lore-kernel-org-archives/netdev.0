From: Li Zefan <lizefan@huawei.com>
Subject: [PATCH 3.4.y 2/3] net: cgroup: fix access the unallocated memory
 in netprio cgroup
Date: Sat, 26 Jan 2013 12:41:39 +0800
Message-ID: <51035E83.3000909@huawei.com>
References: <51035E4F.6030508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Gao feng <gaofeng@cn.fujitsu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:38829 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725Ab3AZElq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 23:41:46 -0500
In-Reply-To: <51035E4F.6030508@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

commit ef209f15980360f6945873df3cd710c5f62f2a3e upstream.

(Note: commit 91c68ce2b26319248a32d7baa1226f819d283758 fixes the
same bug but it ended up both two patches were merged, which is
unnecessary. Therefore we only need to backport one of them, and
we chose the one that doesn't add extra overhead to the fast path.)

there are some out of bound accesses in netprio cgroup.

now before accessing the dev->priomap.priomap array,we only check
if the dev->priomap exist.and because we don't want to see
additional bound checkings in fast path, so we should make sure
that dev->priomap is null or array size of dev->priomap.priomap
is equal to max_prioidx + 1;

so in write_priomap logic,we should call extend_netdev_table when
dev->priomap is null and dev->priomap.priomap_len < max_len.
and in cgrp_create->update_netdev_tables logic,we should call
extend_netdev_table only when dev->priomap exist and
dev->priomap.priomap_len < max_len.

and it's not needed to call update_netdev_tables in write_priomap,
we can only allocate the net device's priomap which we change through
net_prio.ifpriomap.

this patch also add a return value for update_netdev_tables &
extend_netdev_table, so when new_priomap is allocated failed,
write_priomap will stop to access the priomap,and return -ENOMEM
back to the userspace to tell the user what happend.

Change From v3:
1. add rtnl protect when reading max_prioidx in write_priomap.

2. only call extend_netdev_table when map->priomap_len < max_len,
   this will make sure array size of dev->map->priomap always
   bigger than any prioidx.

3. add a function write_update_netdev_table to make codes clear.

Change From v2:
1. protect extend_netdev_table by RTNL.
2. when extend_netdev_table failed,call dev_put to reduce device's refcount.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Eric Dumazet <edumazet@google.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 net/core/netprio_cgroup.c | 71 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 54 insertions(+), 17 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 4435296..dca347e 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -78,7 +78,7 @@ static void put_prioidx(u32 idx)
 	spin_unlock_irqrestore(&prioidx_map_lock, flags);
 }
 
-static void extend_netdev_table(struct net_device *dev, u32 new_len)
+static int extend_netdev_table(struct net_device *dev, u32 new_len)
 {
 	size_t new_size = sizeof(struct netprio_map) +
 			   ((sizeof(u32) * new_len));
@@ -90,7 +90,7 @@ static void extend_netdev_table(struct net_device *dev, u32 new_len)
 
 	if (!new_priomap) {
 		printk(KERN_WARNING "Unable to alloc new priomap!\n");
-		return;
+		return -ENOMEM;
 	}
 
 	for (i = 0;
@@ -103,46 +103,79 @@ static void extend_netdev_table(struct net_device *dev, u32 new_len)
 	rcu_assign_pointer(dev->priomap, new_priomap);
 	if (old_priomap)
 		kfree_rcu(old_priomap, rcu);
+	return 0;
 }
 
-static void update_netdev_tables(void)
+static int write_update_netdev_table(struct net_device *dev)
 {
+	int ret = 0;
+	u32 max_len;
+	struct netprio_map *map;
+
+	rtnl_lock();
+	max_len = atomic_read(&max_prioidx) + 1;
+	map = rtnl_dereference(dev->priomap);
+	if (!map || map->priomap_len < max_len)
+		ret = extend_netdev_table(dev, max_len);
+	rtnl_unlock();
+
+	return ret;
+}
+
+static int update_netdev_tables(void)
+{
+	int ret = 0;
 	struct net_device *dev;
-	u32 max_len = atomic_read(&max_prioidx) + 1;
+	u32 max_len;
 	struct netprio_map *map;
 
 	rtnl_lock();
+	max_len = atomic_read(&max_prioidx) + 1;
 	for_each_netdev(&init_net, dev) {
 		map = rtnl_dereference(dev->priomap);
-		if ((!map) ||
-		    (map->priomap_len < max_len))
-			extend_netdev_table(dev, max_len);
+		/*
+		 * don't allocate priomap if we didn't
+		 * change net_prio.ifpriomap (map == NULL),
+		 * this will speed up skb_update_prio.
+		 */
+		if (map && map->priomap_len < max_len) {
+			ret = extend_netdev_table(dev, max_len);
+			if (ret < 0)
+				break;
+		}
 	}
 	rtnl_unlock();
+	return ret;
 }
 
 static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
 {
 	struct cgroup_netprio_state *cs;
-	int ret;
+	int ret = -EINVAL;
 
 	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
 	if (!cs)
 		return ERR_PTR(-ENOMEM);
 
-	if (cgrp->parent && cgrp_netprio_state(cgrp->parent)->prioidx) {
-		kfree(cs);
-		return ERR_PTR(-EINVAL);
-	}
+	if (cgrp->parent && cgrp_netprio_state(cgrp->parent)->prioidx)
+		goto out;
 
 	ret = get_prioidx(&cs->prioidx);
-	if (ret != 0) {
+	if (ret < 0) {
 		printk(KERN_WARNING "No space in priority index array\n");
-		kfree(cs);
-		return ERR_PTR(ret);
+		goto out;
+	}
+
+	ret = update_netdev_tables();
+	if (ret < 0) {
+		put_prioidx(cs->prioidx);
+		goto out;
 	}
 
 	return &cs->css;
+out:
+	kfree(cs);
+	return ERR_PTR(ret);
 }
 
 static void cgrp_destroy(struct cgroup *cgrp)
@@ -234,13 +267,17 @@ static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
 	if (!dev)
 		goto out_free_devname;
 
-	update_netdev_tables();
-	ret = 0;
+	ret = write_update_netdev_table(dev);
+	if (ret < 0)
+		goto out_put_dev;
+
 	rcu_read_lock();
 	map = rcu_dereference(dev->priomap);
 	if (map)
 		map->priomap[prioidx] = priority;
 	rcu_read_unlock();
+
+out_put_dev:
 	dev_put(dev);
 
 out_free_devname:
-- 
1.8.0.2
