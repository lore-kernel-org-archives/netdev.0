From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [patch] net, sunrpc: suppress allocation warning in rpc_malloc()
Date: Wed, 7 May 2014 13:03:41 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405071257320.25707@chino.kir.corp.google.com>
References: <2562595.ix17LO7uqe@fb07-iapwap2> <alpine.DEB.2.02.1405050241180.11071@chino.kir.corp.google.com> <20140505070812.470c66bd@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
To: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140505070812.470c66bd-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

rpc_malloc() allocates with GFP_NOWAIT without making any attempt at 
reclaim so it easily fails when low on memory.  This ends up spamming the 
kernel log:

SLAB: Unable to allocate memory on node 0 (gfp=0x4000)
  cache: kmalloc-8192, object size: 8192, order: 1
  node 0: slabs: 207/207, objs: 207/207, free: 0
rekonq: page allocation failure: order:1, mode:0x204000
CPU: 2 PID: 14321 Comm: rekonq Tainted: G           O  3.15.0-rc3-12.gfc9498b-desktop+ #6
Hardware name: System manufacturer System Product Name/M4A785TD-V EVO, BIOS 2105    07/23/2010
 0000000000000000 ffff880010ff17d0 ffffffff815e693c 0000000000204000
 ffff880010ff1858 ffffffff81137bd2 0000000000000000 0000001000000000
 ffff88011ffebc38 0000000000000001 0000000000204000 ffff88011ffea000
Call Trace:
 [<ffffffff815e693c>] dump_stack+0x4d/0x6f
 [<ffffffff81137bd2>] warn_alloc_failed+0xd2/0x140
 [<ffffffff8113be19>] __alloc_pages_nodemask+0x7e9/0xa30
 [<ffffffff811824a8>] kmem_getpages+0x58/0x140
 [<ffffffff81183de6>] fallback_alloc+0x1d6/0x210
 [<ffffffff81183be3>] ____cache_alloc_node+0x123/0x150
 [<ffffffff81185953>] __kmalloc+0x203/0x490
 [<ffffffffa06b0ee2>] rpc_malloc+0x32/0xa0 [sunrpc]
 [<ffffffffa06a6999>] call_allocate+0xb9/0x170 [sunrpc]
 [<ffffffffa06b19d8>] __rpc_execute+0x88/0x460 [sunrpc]
 [<ffffffffa06b2da9>] rpc_execute+0x59/0xc0 [sunrpc]
 [<ffffffffa06a932b>] rpc_run_task+0x6b/0x90 [sunrpc]
 [<ffffffffa077b5c1>] nfs4_call_sync_sequence+0x51/0x80 [nfsv4]
 [<ffffffffa077d45d>] _nfs4_do_setattr+0x1ed/0x280 [nfsv4]
 [<ffffffffa0782a72>] nfs4_do_setattr+0x72/0x180 [nfsv4]
 [<ffffffffa078334c>] nfs4_proc_setattr+0xbc/0x140 [nfsv4]
 [<ffffffffa074a7e8>] nfs_setattr+0xd8/0x240 [nfs]
 [<ffffffff811baa71>] notify_change+0x231/0x380
 [<ffffffff8119cf5c>] chmod_common+0xfc/0x120
 [<ffffffff8119df80>] SyS_chmod+0x40/0x90
 [<ffffffff815f4cfd>] system_call_fastpath+0x1a/0x1f
...

If the allocation fails, simply return NULL and avoid spamming the kernel 
log.

Reported-by: Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>
Signed-off-by: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 net/sunrpc/sched.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -832,7 +832,8 @@ static void rpc_async_schedule(struct work_struct *work)
  * @size: requested byte size
  *
  * To prevent rpciod from hanging, this allocator never sleeps,
- * returning NULL if the request cannot be serviced immediately.
+ * returning NULL and suppressing warning if the request cannot be serviced
+ * immediately.
  * The caller can arrange to sleep in a way that is safe for rpciod.
  *
  * Most requests are 'small' (under 2KiB) and can be serviced from a
@@ -845,7 +846,7 @@ static void rpc_async_schedule(struct work_struct *work)
 void *rpc_malloc(struct rpc_task *task, size_t size)
 {
 	struct rpc_buffer *buf;
-	gfp_t gfp = GFP_NOWAIT;
+	gfp_t gfp = GFP_NOWAIT | __GFP_NOWARN;
 
 	if (RPC_IS_SWAPPER(task))
 		gfp |= __GFP_MEMALLOC;
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
