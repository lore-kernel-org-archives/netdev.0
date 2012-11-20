From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/7] netprio_cgroup: reimplement priomap expansion
Date: Tue, 20 Nov 2012 00:30:08 -0800
Message-ID: <1353400211-5182-5-git-send-email-tj@kernel.org>
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

netprio kept track of the highest prioidx allocated and resized
priomaps accordingly when necessary.  This makes it necessary to keep
track of prioidx allocation and may end up resizing on every new
prioidx.

Update extend_netdev_table() such that it takes @target_idx which the
priomap should be able to accomodate.  If the priomap is large enough,
nothing happens; otherwise, the size is doubled until @target_idx can
be accomodated.

This makes max_prioidx and write_update_netdev_table() unnecessary.
write_priomap() now calls extend_netdev_table() directly.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 net/core/netprio_cgroup.c | 56 ++++++++++++++++++++++++++++-------------------
 1 file changed, 33 insertions(+), 23 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 92cc54c..569d83d 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -27,11 +27,11 @@
 
 #include <linux/fdtable.h>
 
+#define PRIOMAP_MIN_SZ		128
 #define PRIOIDX_SZ 128
 
 static unsigned long prioidx_map[PRIOIDX_SZ];
 static DEFINE_SPINLOCK(prioidx_map_lock);
-static atomic_t max_prioidx = ATOMIC_INIT(0);
 
 static inline struct cgroup_netprio_state *cgrp_netprio_state(struct cgroup *cgrp)
 {
@@ -51,8 +51,6 @@ static int get_prioidx(u32 *prio)
 		return -ENOSPC;
 	}
 	set_bit(prioidx, prioidx_map);
-	if (atomic_read(&max_prioidx) < prioidx)
-		atomic_set(&max_prioidx, prioidx);
 	spin_unlock_irqrestore(&prioidx_map_lock, flags);
 	*prio = prioidx;
 	return 0;
@@ -67,15 +65,40 @@ static void put_prioidx(u32 idx)
 	spin_unlock_irqrestore(&prioidx_map_lock, flags);
 }
 
-static int extend_netdev_table(struct net_device *dev, u32 new_len)
+/*
+ * Extend @dev->priomap so that it's large enough to accomodate
+ * @target_idx.  @dev->priomap.priomap_len > @target_idx after successful
+ * return.  Must be called under rtnl lock.
+ */
+static int extend_netdev_table(struct net_device *dev, u32 target_idx)
 {
-	size_t new_size = sizeof(struct netprio_map) +
-			   ((sizeof(u32) * new_len));
-	struct netprio_map *new = kzalloc(new_size, GFP_KERNEL);
-	struct netprio_map *old;
+	struct netprio_map *old, *new;
+	size_t new_sz, new_len;
 
+	/* is the existing priomap large enough? */
 	old = rtnl_dereference(dev->priomap);
+	if (old && old->priomap_len > target_idx)
+		return 0;
+
+	/*
+	 * Determine the new size.  Let's keep it power-of-two.  We start
+	 * from PRIOMAP_MIN_SZ and double it until it's large enough to
+	 * accommodate @target_idx.
+	 */
+	new_sz = PRIOMAP_MIN_SZ;
+	while (true) {
+		new_len = (new_sz - offsetof(struct netprio_map, priomap)) /
+			sizeof(new->priomap[0]);
+		if (new_len > target_idx)
+			break;
+		new_sz *= 2;
+		/* overflowed? */
+		if (WARN_ON(new_sz < PRIOMAP_MIN_SZ))
+			return -ENOSPC;
+	}
 
+	/* allocate & copy */
+	new = kzalloc(new_sz, GFP_KERNEL);
 	if (!new) {
 		pr_warn("Unable to alloc new priomap!\n");
 		return -ENOMEM;
@@ -87,26 +110,13 @@ static int extend_netdev_table(struct net_device *dev, u32 new_len)
 
 	new->priomap_len = new_len;
 
+	/* install the new priomap */
 	rcu_assign_pointer(dev->priomap, new);
 	if (old)
 		kfree_rcu(old, rcu);
 	return 0;
 }
 
-static int write_update_netdev_table(struct net_device *dev)
-{
-	int ret = 0;
-	u32 max_len;
-	struct netprio_map *map;
-
-	max_len = atomic_read(&max_prioidx) + 1;
-	map = rtnl_dereference(dev->priomap);
-	if (!map || map->priomap_len < max_len)
-		ret = extend_netdev_table(dev, max_len);
-
-	return ret;
-}
-
 static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 {
 	struct cgroup_netprio_state *cs;
@@ -191,7 +201,7 @@ static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
 
 	rtnl_lock();
 
-	ret = write_update_netdev_table(dev);
+	ret = extend_netdev_table(dev, prioidx);
 	if (ret)
 		goto out_unlock;
 
-- 
1.7.11.7
