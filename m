From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH v4] net: cgroup: fix access the unallocated memory in netprio cgroup
Date: Thu, 12 Jul 2012 15:50:15 +0800
Message-ID: <1342079415-9631-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Eric Dumazet <edumazet@google.com>
To: nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 net/core/netprio_cgroup.c |   71 ++++++++++++++++++++++++++++++++++-----------
 1 files changed, 54 insertions(+), 17 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index aa907ed..9b17d54 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -65,7 +65,7 @@ static void put_prioidx(u32 idx)
 	spin_unlock_irqrestore(&prioidx_map_lock, flags);
 }
 
-static void extend_netdev_table(struct net_device *dev, u32 new_len)
+static int extend_netdev_table(struct net_device *dev, u32 new_len)
 {
 	size_t new_size = sizeof(struct netprio_map) +
 			   ((sizeof(u32) * new_len));
@@ -77,7 +77,7 @@ static void extend_netdev_table(struct net_device *dev, u32 new_len)
 
 	if (!new_priomap) {
 		pr_warn("Unable to alloc new priomap!\n");
-		return;
+		return -ENOMEM;
 	}
 
 	for (i = 0;
@@ -90,46 +90,79 @@ static void extend_netdev_table(struct net_device *dev, u32 new_len)
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
 		pr_warn("No space in priority index array\n");
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
@@ -221,13 +254,17 @@ static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
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
1.7.7.6
