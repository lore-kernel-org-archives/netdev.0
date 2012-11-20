From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/7] netprio_cgroup: use cgroup->id instead of
	cgroup_netprio_state->prioidx
Date: Tue, 20 Nov 2012 00:30:09 -0800
Message-ID: <1353400211-5182-6-git-send-email-tj@kernel.org>
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

With priomap expansion no longer depending on knowing max id
allocated, netprio_cgroup can use cgroup->id insted of cs->prioidx.
Drop prioidx alloc/free logic and convert all uses to cgroup->id.

* In cgrp_css_alloc(), parent->id test is moved above @cs allocation
  to simplify error path.

* In cgrp_css_free(), @cs assignment is made initialization.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 include/net/netprio_cgroup.h | 11 +++-----
 net/core/netprio_cgroup.c    | 65 ++++++++------------------------------------
 2 files changed, 15 insertions(+), 61 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 2760f4f..1d04b6f 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -27,7 +27,6 @@ struct netprio_map {
 
 struct cgroup_netprio_state {
 	struct cgroup_subsys_state css;
-	u32 prioidx;
 };
 
 extern void sock_update_netprioidx(struct sock *sk, struct task_struct *task);
@@ -36,13 +35,12 @@ extern void sock_update_netprioidx(struct sock *sk, struct task_struct *task);
 
 static inline u32 task_netprioidx(struct task_struct *p)
 {
-	struct cgroup_netprio_state *state;
+	struct cgroup_subsys_state *css;
 	u32 idx;
 
 	rcu_read_lock();
-	state = container_of(task_subsys_state(p, net_prio_subsys_id),
-			     struct cgroup_netprio_state, css);
-	idx = state->prioidx;
+	css = task_subsys_state(p, net_prio_subsys_id);
+	idx = css->cgroup->id;
 	rcu_read_unlock();
 	return idx;
 }
@@ -57,8 +55,7 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	rcu_read_lock();
 	css = task_subsys_state(p, net_prio_subsys_id);
 	if (css)
-		idx = container_of(css,
-				   struct cgroup_netprio_state, css)->prioidx;
+		idx = css->cgroup->id;
 	rcu_read_unlock();
 	return idx;
 }
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 569d83d..9409cdf 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -28,10 +28,6 @@
 #include <linux/fdtable.h>
 
 #define PRIOMAP_MIN_SZ		128
-#define PRIOIDX_SZ 128
-
-static unsigned long prioidx_map[PRIOIDX_SZ];
-static DEFINE_SPINLOCK(prioidx_map_lock);
 
 static inline struct cgroup_netprio_state *cgrp_netprio_state(struct cgroup *cgrp)
 {
@@ -39,32 +35,6 @@ static inline struct cgroup_netprio_state *cgrp_netprio_state(struct cgroup *cgr
 			    struct cgroup_netprio_state, css);
 }
 
-static int get_prioidx(u32 *prio)
-{
-	unsigned long flags;
-	u32 prioidx;
-
-	spin_lock_irqsave(&prioidx_map_lock, flags);
-	prioidx = find_first_zero_bit(prioidx_map, sizeof(unsigned long) * PRIOIDX_SZ);
-	if (prioidx == sizeof(unsigned long) * PRIOIDX_SZ) {
-		spin_unlock_irqrestore(&prioidx_map_lock, flags);
-		return -ENOSPC;
-	}
-	set_bit(prioidx, prioidx_map);
-	spin_unlock_irqrestore(&prioidx_map_lock, flags);
-	*prio = prioidx;
-	return 0;
-}
-
-static void put_prioidx(u32 idx)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&prioidx_map_lock, flags);
-	clear_bit(idx, prioidx_map);
-	spin_unlock_irqrestore(&prioidx_map_lock, flags);
-}
-
 /*
  * Extend @dev->priomap so that it's large enough to accomodate
  * @target_idx.  @dev->priomap.priomap_len > @target_idx after successful
@@ -120,62 +90,50 @@ static int extend_netdev_table(struct net_device *dev, u32 target_idx)
 static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 {
 	struct cgroup_netprio_state *cs;
-	int ret = -EINVAL;
+
+	if (cgrp->parent && cgrp->parent->id)
+		return ERR_PTR(-EINVAL);
 
 	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
 	if (!cs)
 		return ERR_PTR(-ENOMEM);
 
-	if (cgrp->parent && cgrp_netprio_state(cgrp->parent)->prioidx)
-		goto out;
-
-	ret = get_prioidx(&cs->prioidx);
-	if (ret < 0) {
-		pr_warn("No space in priority index array\n");
-		goto out;
-	}
-
 	return &cs->css;
-out:
-	kfree(cs);
-	return ERR_PTR(ret);
 }
 
 static void cgrp_css_free(struct cgroup *cgrp)
 {
-	struct cgroup_netprio_state *cs;
+	struct cgroup_netprio_state *cs = cgrp_netprio_state(cgrp);
 	struct net_device *dev;
 	struct netprio_map *map;
 
-	cs = cgrp_netprio_state(cgrp);
 	rtnl_lock();
 	for_each_netdev(&init_net, dev) {
 		map = rtnl_dereference(dev->priomap);
-		if (map && cs->prioidx < map->priomap_len)
-			map->priomap[cs->prioidx] = 0;
+		if (map && cgrp->id < map->priomap_len)
+			map->priomap[cgrp->id] = 0;
 	}
 	rtnl_unlock();
-	put_prioidx(cs->prioidx);
 	kfree(cs);
 }
 
 static u64 read_prioidx(struct cgroup *cgrp, struct cftype *cft)
 {
-	return (u64)cgrp_netprio_state(cgrp)->prioidx;
+	return cgrp->id;
 }
 
 static int read_priomap(struct cgroup *cont, struct cftype *cft,
 			struct cgroup_map_cb *cb)
 {
 	struct net_device *dev;
-	u32 prioidx = cgrp_netprio_state(cont)->prioidx;
+	u32 id = cont->id;
 	u32 priority;
 	struct netprio_map *map;
 
 	rcu_read_lock();
 	for_each_netdev_rcu(&init_net, dev) {
 		map = rcu_dereference(dev->priomap);
-		priority = (map && prioidx < map->priomap_len) ? map->priomap[prioidx] : 0;
+		priority = (map && id < map->priomap_len) ? map->priomap[id] : 0;
 		cb->fill(cb, dev->name, priority);
 	}
 	rcu_read_unlock();
@@ -185,7 +143,6 @@ static int read_priomap(struct cgroup *cont, struct cftype *cft,
 static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
 			 const char *buffer)
 {
-	u32 prioidx = cgrp_netprio_state(cgrp)->prioidx;
 	char devname[IFNAMSIZ + 1];
 	struct net_device *dev;
 	struct netprio_map *map;
@@ -201,13 +158,13 @@ static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
 
 	rtnl_lock();
 
-	ret = extend_netdev_table(dev, prioidx);
+	ret = extend_netdev_table(dev, cgrp->id);
 	if (ret)
 		goto out_unlock;
 
 	map = rtnl_dereference(dev->priomap);
 	if (map)
-		map->priomap[prioidx] = prio;
+		map->priomap[cgrp->id] = prio;
 out_unlock:
 	rtnl_unlock();
 	dev_put(dev);
-- 
1.7.11.7
