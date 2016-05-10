From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf] netfilter: fix oops in nfqueue during netns error unwinding
Date: Tue, 10 May 2016 15:35:35 +0200
Message-ID: <1462887335-24632-1-git-send-email-fw@strlen.de>
Cc: <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Under full load (unshare() in loop -> OOM conditions) we can
get kernel panic:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffff81476c85>] nfqnl_nf_hook_drop+0x35/0x70
[..]
task: ffff88012dfa3840 ti: ffff88012dffc000 task.ti: ffff88012dffc000
RIP: 0010:[<ffffffff81476c85>]  [<ffffffff81476c85>] nfqnl_nf_hook_drop+0x35/0x70
RSP: 0000:ffff88012dfffd80  EFLAGS: 00010206
RAX: 0000000000000008 RBX: ffffffff81add0c0 RCX: ffff88013fd80000
[..]
Call Trace:
 [<ffffffff81474d98>] nf_queue_nf_hook_drop+0x18/0x20
 [<ffffffff814738eb>] nf_unregister_net_hook+0xdb/0x150
 [<ffffffff8147398f>] netfilter_net_exit+0x2f/0x60
 [<ffffffff8141b088>] ops_exit_list.isra.4+0x38/0x60
 [<ffffffff8141b652>] setup_net+0xc2/0x120
 [<ffffffff8141bd09>] copy_net_ns+0x79/0x120
 [<ffffffff8106965b>] create_new_namespaces+0x11b/0x1e0
 [<ffffffff810698a7>] unshare_nsproxy_namespaces+0x57/0xa0
 [<ffffffff8104baa2>] SyS_unshare+0x1b2/0x340
 [<ffffffff81608276>] entry_SYSCALL_64_fastpath+0x1e/0xa8
Code: 65 00 48 89 e5 41 56 41 55 41 54 53 83 e8 01 48 8b 97 70 12 00 00 48 98 49 89 f4 4c 8b 74 c2 18 4d 8d 6e 08 49 81 c6 88 00 00 00 <49> 8b 5d 00 48 85 db 74 1a 48 89 df 4c 89 e2 48 c7 c6 90 68 47

Problem is that we call into the nfqueue backend to zap
packets that might be queued to userspace.

However, this assumes that the backend was initialized and
net_generic(net, nfnl_queue_net_id) returns valid memory.

Unfortunately this isn't the case; its possible that we e.g. failed to
create the nfqueue proc directory.  In this case the returned memory
was already free'd and we oops when we try to grab the instance lock.

Add a marker to the netfilter pernetns data that tells nf_queue if
the backend was initialized in this namespace.

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Fixes: 8405a8fff3f ("netfilter: nf_qeueue: Drop queue entries on nf_unregister_hook")
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 I don't like this fix, but I am not sure what other (reliable!) alternatives
 exist.

 Another solution might be to alter
 net_namespace.c:ops_init so that it sets

 net_assign_generic(net, *ops->id, NULL);

 ... when the ops->init hook returns an error.

 We'd need to also add bounds check to net_generic(), or do this
 check in nfnetlink_queue to make sure ptr[id] can be accessed.

 Other ideas?

 include/net/netns/netfilter.h   | 5 +++++
 net/netfilter/nf_queue.c        | 2 +-
 net/netfilter/nfnetlink_queue.c | 1 +
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/net/netns/netfilter.h b/include/net/netns/netfilter.h
index 38aa498..de75700 100644
--- a/include/net/netns/netfilter.h
+++ b/include/net/netns/netfilter.h
@@ -15,5 +15,10 @@ struct netns_nf {
 	struct ctl_table_header *nf_log_dir_header;
 #endif
 	struct list_head hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
+
+	/* needed so nf core knows that we might need to drop
+	 * queued packets on hook unregister
+	 */
+	bool nfqueue_inited;
 };
 #endif
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 5baa8e2..b6d585d 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -104,7 +104,7 @@ void nf_queue_nf_hook_drop(struct net *net, struct nf_hook_ops *ops)
 
 	rcu_read_lock();
 	qh = rcu_dereference(queue_handler);
-	if (qh)
+	if (qh && net->nf.nfqueue_inited)
 		qh->nf_hook_drop(net, ops);
 	rcu_read_unlock();
 }
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index cb5b630..536bac7 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1377,6 +1377,7 @@ static int __net_init nfnl_queue_net_init(struct net *net)
 			 net->nf.proc_netfilter, &nfqnl_file_ops))
 		return -ENOMEM;
 #endif
+	net->nf.nfqueue_inited = true;
 	return 0;
 }
 
-- 
2.7.3

