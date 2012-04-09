From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v3 2/2] cgroup: get rid of populate for memcg
Date: Mon,  9 Apr 2012 19:36:34 -0300
Message-ID: <1334010994-23301-3-git-send-email-glommer@parallels.com>
References: <1334010994-23301-1-git-send-email-glommer@parallels.com>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334010994-23301-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The last man standing justifying the need for populate() is the
sock memcg initialization functions. Now that we are able to pass
a struct mem_cgroup instead of a struct cgroup to the socket
initialization, there is nothing that stops us from initializing
everything in create().

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
CC: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
CC: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
CC: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
---
 mm/memcontrol.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 704054d..02b01d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4640,7 +4640,7 @@ static int mem_control_numa_stat_open(struct inode *unused, struct file *file)
 #endif /* CONFIG_NUMA */
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
-static int register_kmem_files(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
+static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	return mem_cgroup_sockets_init(memcg, ss);
 };
@@ -4650,7 +4650,7 @@ static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
 	mem_cgroup_sockets_destroy(memcg);
 }
 #else
-static int register_kmem_files(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
+static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	return 0;
 }
@@ -5010,6 +5010,17 @@ mem_cgroup_create(struct cgroup *cont)
 	memcg->move_charge_at_immigrate = 0;
 	mutex_init(&memcg->thresholds_lock);
 	spin_lock_init(&memcg->move_lock);
+
+	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
+	if (error) {
+		/*
+		 * We call put now because our (and parent's) refcnts
+		 * are already in place. mem_cgroup_put() will internally
+		 * call __mem_cgroup_free, so return directly
+		 */
+		mem_cgroup_put(memcg);
+		return ERR_PTR(error);
+	}
 	return &memcg->css;
 free_out:
 	__mem_cgroup_free(memcg);
@@ -5032,13 +5043,6 @@ static void mem_cgroup_destroy(struct cgroup *cont)
 	mem_cgroup_put(memcg);
 }
 
-static int mem_cgroup_populate(struct cgroup_subsys *ss,
-				struct cgroup *cont)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-	return register_kmem_files(memcg, ss);
-}
-
 #ifdef CONFIG_MMU
 /* Handlers for move charge at task migration. */
 #define PRECHARGE_COUNT_AT_ONCE	256
@@ -5622,7 +5626,6 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.create = mem_cgroup_create,
 	.pre_destroy = mem_cgroup_pre_destroy,
 	.destroy = mem_cgroup_destroy,
-	.populate = mem_cgroup_populate,
 	.can_attach = mem_cgroup_can_attach,
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
-- 
1.7.7.6
