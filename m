From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 2/3] tipc: fix a potential
	deadlock when nametable is purged
Date: Wed, 18 Mar 2015 09:32:58 +0800
Message-ID: <1426642379-20503-3-git-send-email-ying.xue@windriver.com>
References: <1426642379-20503-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, cwang@twopensource.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1426642379-20503-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

[   28.531768] =============================================
[   28.532322] [ INFO: possible recursive locking detected ]
[   28.532322] 3.19.0+ #194 Not tainted
[   28.532322] ---------------------------------------------
[   28.532322] insmod/583 is trying to acquire lock:
[   28.532322]  (&(&nseq->lock)->rlock){+.....}, at: [<ffffffffa000d219>] tipc_nametbl_remove_publ+0x49/0x2e0 [tipc]
[   28.532322]
[   28.532322] but task is already holding lock:
[   28.532322]  (&(&nseq->lock)->rlock){+.....}, at: [<ffffffffa000e0dc>] tipc_nametbl_stop+0xfc/0x1f0 [tipc]
[   28.532322]
[   28.532322] other info that might help us debug this:
[   28.532322]  Possible unsafe locking scenario:
[   28.532322]
[   28.532322]        CPU0
[   28.532322]        ----
[   28.532322]   lock(&(&nseq->lock)->rlock);
[   28.532322]   lock(&(&nseq->lock)->rlock);
[   28.532322]
[   28.532322]  *** DEADLOCK ***
[   28.532322]
[   28.532322]  May be due to missing lock nesting notation
[   28.532322]
[   28.532322] 3 locks held by insmod/583:
[   28.532322]  #0:  (net_mutex){+.+.+.}, at: [<ffffffff8163e30f>] register_pernet_subsys+0x1f/0x50
[   28.532322]  #1:  (&(&tn->nametbl_lock)->rlock){+.....}, at: [<ffffffffa000e091>] tipc_nametbl_stop+0xb1/0x1f0 [tipc]
[   28.532322]  #2:  (&(&nseq->lock)->rlock){+.....}, at: [<ffffffffa000e0dc>] tipc_nametbl_stop+0xfc/0x1f0 [tipc]
[   28.532322]
[   28.532322] stack backtrace:
[   28.532322] CPU: 1 PID: 583 Comm: insmod Not tainted 3.19.0+ #194
[   28.532322] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   28.532322]  ffffffff82394460 ffff8800144cb928 ffffffff81792f3e 0000000000000007
[   28.532322]  ffffffff82394460 ffff8800144cba28 ffffffff810a8080 ffff8800144cb998
[   28.532322]  ffffffff810a4df3 ffff880013e9cb10 ffffffff82b0d330 ffff880013e9cb38
[   28.532322] Call Trace:
[   28.532322]  [<ffffffff81792f3e>] dump_stack+0x4c/0x65
[   28.532322]  [<ffffffff810a8080>] __lock_acquire+0x740/0x1ca0
[   28.532322]  [<ffffffff810a4df3>] ? __bfs+0x23/0x270
[   28.532322]  [<ffffffff810a7506>] ? check_irq_usage+0x96/0xe0
[   28.532322]  [<ffffffff810a8a73>] ? __lock_acquire+0x1133/0x1ca0
[   28.532322]  [<ffffffffa000d219>] ? tipc_nametbl_remove_publ+0x49/0x2e0 [tipc]
[   28.532322]  [<ffffffff810a9c0c>] lock_acquire+0x9c/0x140
[   28.532322]  [<ffffffffa000d219>] ? tipc_nametbl_remove_publ+0x49/0x2e0 [tipc]
[   28.532322]  [<ffffffff8179c41f>] _raw_spin_lock_bh+0x3f/0x50
[   28.532322]  [<ffffffffa000d219>] ? tipc_nametbl_remove_publ+0x49/0x2e0 [tipc]
[   28.532322]  [<ffffffffa000d219>] tipc_nametbl_remove_publ+0x49/0x2e0 [tipc]
[   28.532322]  [<ffffffffa000e11e>] tipc_nametbl_stop+0x13e/0x1f0 [tipc]
[   28.532322]  [<ffffffffa000dfe5>] ? tipc_nametbl_stop+0x5/0x1f0 [tipc]
[   28.532322]  [<ffffffffa0004bab>] tipc_init_net+0x13b/0x150 [tipc]
[   28.532322]  [<ffffffffa0004a75>] ? tipc_init_net+0x5/0x150 [tipc]
[   28.532322]  [<ffffffff8163dece>] ops_init+0x4e/0x150
[   28.532322]  [<ffffffff810aa66d>] ? trace_hardirqs_on+0xd/0x10
[   28.532322]  [<ffffffff8163e1d3>] register_pernet_operations+0xf3/0x190
[   28.532322]  [<ffffffff8163e31e>] register_pernet_subsys+0x2e/0x50
[   28.532322]  [<ffffffffa002406a>] tipc_init+0x6a/0x1000 [tipc]
[   28.532322]  [<ffffffffa0024000>] ? 0xffffffffa0024000
[   28.532322]  [<ffffffff810002d9>] do_one_initcall+0x89/0x1c0
[   28.532322]  [<ffffffff811b7cb0>] ? kmem_cache_alloc_trace+0x50/0x1b0
[   28.532322]  [<ffffffff810e725b>] ? do_init_module+0x2b/0x200
[   28.532322]  [<ffffffff810e7294>] do_init_module+0x64/0x200
[   28.532322]  [<ffffffff810e9353>] load_module+0x12f3/0x18e0
[   28.532322]  [<ffffffff810e5890>] ? show_initstate+0x50/0x50
[   28.532322]  [<ffffffff810e9a19>] SyS_init_module+0xd9/0x110
[   28.532322]  [<ffffffff8179f3b3>] sysenter_dispatch+0x7/0x1f

Before tipc_purge_publications() calls tipc_nametbl_remove_publ() to
remove a publication with a name sequence, the name sequence's lock
is held. However, when tipc_nametbl_remove_publ() calling
tipc_nameseq_remove_publ() to remove the publication, it first tries
to query name sequence instance with the publication, and then holds
the lock of the found name sequence. But as the lock may be already
taken in tipc_purge_publications(), deadlock happens like above
scenario demonstrated. As tipc_nameseq_remove_publ() doesn't grab name
sequence's lock, the deadlock can be avoided if it's directly invoked
by tipc_purge_publications().

Fixes: 97ede29e80ee ("tipc: convert name table read-write lock to RCU")
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/name_table.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 105ba7ad..ab0ac62 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -811,8 +811,8 @@ static void tipc_purge_publications(struct net *net, struct name_seq *seq)
 	sseq = seq->sseqs;
 	info = sseq->info;
 	list_for_each_entry_safe(publ, safe, &info->zone_list, zone_list) {
-		tipc_nametbl_remove_publ(net, publ->type, publ->lower,
-					 publ->node, publ->ref, publ->key);
+		tipc_nameseq_remove_publ(net, seq, publ->lower, publ->node,
+					 publ->ref, publ->key);
 		kfree_rcu(publ, rcu);
 	}
 	hlist_del_init_rcu(&seq->ns_list);
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
