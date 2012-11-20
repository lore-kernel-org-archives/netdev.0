From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/7] netprio_cgroup: implement netprio[_set]_prio() helpers
Date: Tue, 20 Nov 2012 00:30:10 -0800
Message-ID: <1353400211-5182-7-git-send-email-tj@kernel.org>
References: <1353400211-5182-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353400211-5182-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Introduce two helpers - netprio_prio() and netprio_set_prio() - which
hide the details of priomap access and expansion.  This will help
implementing hierarchy support.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 net/core/netprio_cgroup.c | 72 ++++++++++++++++++++++++++++++++---------------
 1 file changed, 50 insertions(+), 22 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 9409cdf..b2af0d0 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -87,6 +87,51 @@ static int extend_netdev_table(struct net_device *dev, u32 target_idx)
 	return 0;
 }
 
+/**
+ * netprio_prio - return the effective netprio of a cgroup-net_device pair
+ * @cgrp: cgroup part of the target pair
+ * @dev: net_device part of the target pair
+ *
+ * Should be called under RCU read or rtnl lock.
+ */
+static u32 netprio_prio(struct cgroup *cgrp, struct net_device *dev)
+{
+	struct netprio_map *map = rcu_dereference_rtnl(dev->priomap);
+
+	if (map && cgrp->id < map->priomap_len)
+		return map->priomap[cgrp->id];
+	return 0;
+}
+
+/**
+ * netprio_set_prio - set netprio on a cgroup-net_device pair
+ * @cgrp: cgroup part of the target pair
+ * @dev: net_device part of the target pair
+ * @prio: prio to set
+ *
+ * Set netprio to @prio on @cgrp-@dev pair.  Should be called under rtnl
+ * lock and may fail under memory pressure for non-zero @prio.
+ */
+static int netprio_set_prio(struct cgroup *cgrp, struct net_device *dev,
+			    u32 prio)
+{
+	struct netprio_map *map;
+	int ret;
+
+	/* avoid extending priomap for zero writes */
+	map = rtnl_dereference(dev->priomap);
+	if (!prio && (!map || map->priomap_len <= cgrp->id))
+		return 0;
+
+	ret = extend_netdev_table(dev, cgrp->id);
+	if (ret)
+		return ret;
+
+	map = rtnl_dereference(dev->priomap);
+	map->priomap[cgrp->id] = prio;
+	return 0;
+}
+
 static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 {
 	struct cgroup_netprio_state *cs;
@@ -105,14 +150,10 @@ static void cgrp_css_free(struct cgroup *cgrp)
 {
 	struct cgroup_netprio_state *cs = cgrp_netprio_state(cgrp);
 	struct net_device *dev;
-	struct netprio_map *map;
 
 	rtnl_lock();
-	for_each_netdev(&init_net, dev) {
-		map = rtnl_dereference(dev->priomap);
-		if (map && cgrp->id < map->priomap_len)
-			map->priomap[cgrp->id] = 0;
-	}
+	for_each_netdev(&init_net, dev)
+		WARN_ON_ONCE(netprio_set_prio(cgrp, dev, 0));
 	rtnl_unlock();
 	kfree(cs);
 }
@@ -126,16 +167,10 @@ static int read_priomap(struct cgroup *cont, struct cftype *cft,
 			struct cgroup_map_cb *cb)
 {
 	struct net_device *dev;
-	u32 id = cont->id;
-	u32 priority;
-	struct netprio_map *map;
 
 	rcu_read_lock();
-	for_each_netdev_rcu(&init_net, dev) {
-		map = rcu_dereference(dev->priomap);
-		priority = (map && id < map->priomap_len) ? map->priomap[id] : 0;
-		cb->fill(cb, dev->name, priority);
-	}
+	for_each_netdev_rcu(&init_net, dev)
+		cb->fill(cb, dev->name, netprio_prio(cont, dev));
 	rcu_read_unlock();
 	return 0;
 }
@@ -145,7 +180,6 @@ static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
 {
 	char devname[IFNAMSIZ + 1];
 	struct net_device *dev;
-	struct netprio_map *map;
 	u32 prio;
 	int ret;
 
@@ -158,14 +192,8 @@ static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
 
 	rtnl_lock();
 
-	ret = extend_netdev_table(dev, cgrp->id);
-	if (ret)
-		goto out_unlock;
+	ret = netprio_set_prio(cgrp, dev, prio);
 
-	map = rtnl_dereference(dev->priomap);
-	if (map)
-		map->priomap[cgrp->id] = prio;
-out_unlock:
 	rtnl_unlock();
 	dev_put(dev);
 	return ret;
-- 
1.7.11.7
