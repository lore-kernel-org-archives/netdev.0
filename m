From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf V2] netfilter: fix oops in nfqueue during netns error unwinding
Date: Wed, 11 May 2016 17:41:13 +0200
Message-ID: <1462981273-21676-1-git-send-email-fw@strlen.de>
Cc: dale.4d@gmail.com, <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39145 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932080AbcEKPk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 11:40:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
packets that might be queued to userspace when we unregister a
netfilter hook.

However, this assumes that the backend was initialized and
net_generic(net, nfnl_queue_net_id) returns valid memory.

This is only true if the hook unregister happens in the netns exit path.
If it happens during error unwind because a netns init hook returned
an error condition (e.g. out of memory), then the result of
net_generic(net, nfnl_queue_net_id) is undefined.

Only do the cleanup for namespaces that were on the
net_namespace_list list (i.e., all netns ->init() functions were ok).

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Reported-by: Dale Whitfield <dale.4d@gmail.com>
Fixes: 8405a8fff3f ("netfilter: nf_qeueue: Drop queue entries on nf_unregister_hook")
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 AFAICS this works fine as well -- if netns was never on the
 net_namespace_list no packets can be queued so we don't need
 to care if the nf_queue init hook got called or not.

diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 5baa8e2..9722819 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -102,6 +102,13 @@ void nf_queue_nf_hook_drop(struct net *net, struct nf_hook_ops *ops)
 {
 	const struct nf_queue_handler *qh;
 
+	/* netns wasn't initialized, error unwind in progress.
+	 * Its possible that the nfq netns init function was not even
+	 * called, in which case nfq pernetns data is in undefined state.
+	 */
+	if (!net->list.next)
+		return;
+
 	rcu_read_lock();
 	qh = rcu_dereference(queue_handler);
 	if (qh)
-- 
2.7.3
