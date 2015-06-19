From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] netfilter: nf_qeueue: Drop queue entries on nf_unregister_hook
Date: Fri, 19 Jun 2015 14:03:39 -0500
Message-ID: <871th7frlg.fsf@x220.int.ebiederm.org>
References: <878ubffron.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <878ubffron.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 19 Jun 2015 14:01:44 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add code to nf_unregister_hook to flush the nf_queue when a hook is
unregistered.  This guarantees that the pointer that the nf_queue code
retains into the nf_hook list will remain valid while a packet is
queued.

I tested what would happen if we do not flush queued packets and was
trivially able to obtain the oops below.  All that was required was
to stop the nf_queue listening process, to delete all of the nf_tables,
and to awaken the nf_queue listening process.

> BUG: unable to handle kernel paging request at 0000000100000001
> IP: [<0000000100000001>] 0x100000001
> PGD b9c35067 PUD 0
> Oops: 0010 [#1] SMP
> Modules linked in:
> CPU: 0 PID: 519 Comm: lt-nfqnl_test Not tainted
> task: ffff8800b9c8c050 ti: ffff8800ba9d8000 task.ti: ffff8800ba9d8000
> RIP: 0010:[<0000000100000001>]  [<0000000100000001>] 0x100000001
> RSP: 0018:ffff8800ba9dba40  EFLAGS: 00010a16
> RAX: ffff8800bab48a00 RBX: ffff8800ba9dba90 RCX: ffff8800ba9dba90
> RDX: ffff8800b9c10128 RSI: ffff8800ba940900 RDI: ffff8800bab48a00
> RBP: ffff8800b9c10128 R08: ffffffff82976660 R09: ffff8800ba9dbb28
> R10: dead000000100100 R11: dead000000200200 R12: ffff8800ba940900
> R13: ffffffff8313fd50 R14: ffff8800b9c95200 R15: 0000000000000000
> FS:  00007fb91fc34700(0000) GS:ffff8800bfa00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000100000001 CR3: 00000000babfb000 CR4: 00000000000007f0
> Stack:
>  ffffffff8206ab0f ffffffff82982240 ffff8800bab48a00 ffff8800b9c100a8
>  ffff8800b9c10100 0000000000000001 ffff8800ba940900 ffff8800b9c10128
>  ffffffff8206bd65 ffff8800bfb0d5e0 ffff8800bab48a00 0000000000014dc0
> Call Trace:
>  [<ffffffff8206ab0f>] ? nf_iterate+0x4f/0xa0
>  [<ffffffff8206bd65>] ? nf_reinject+0x125/0x190
>  [<ffffffff8206dee5>] ? nfqnl_recv_verdict+0x255/0x360
>  [<ffffffff81386290>] ? nla_parse+0x80/0xf0
>  [<ffffffff8206c42c>] ? nfnetlink_rcv_msg+0x13c/0x240
>  [<ffffffff811b2fec>] ? __memcg_kmem_get_cache+0x4c/0x150
>  [<ffffffff8206c2f0>] ? nfnl_lock+0x20/0x20
>  [<ffffffff82068159>] ? netlink_rcv_skb+0xa9/0xc0
>  [<ffffffff820677bf>] ? netlink_unicast+0x12f/0x1c0
>  [<ffffffff82067ade>] ? netlink_sendmsg+0x28e/0x650
>  [<ffffffff81fdd814>] ? sock_sendmsg+0x44/0x50
>  [<ffffffff81fde07b>] ? ___sys_sendmsg+0x2ab/0x2c0
>  [<ffffffff810e8f73>] ? __wake_up+0x43/0x70
>  [<ffffffff8141a134>] ? tty_write+0x1c4/0x2a0
>  [<ffffffff81fde9f4>] ? __sys_sendmsg+0x44/0x80
>  [<ffffffff823ff8d7>] ? system_call_fastpath+0x12/0x6a
> Code:  Bad RIP value.
> RIP  [<0000000100000001>] 0x100000001
>  RSP <ffff8800ba9dba40>
> CR2: 0000000100000001
> ---[ end trace 08eb65d42362793f ]---

Cc: stable@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

Apologies for the duplicate send but I forgot to include the appropriate
mailing lists.

 include/net/netfilter/nf_queue.h     |  2 ++
 net/netfilter/core.c                 |  1 +
 net/netfilter/nf_internals.h         |  1 +
 net/netfilter/nf_queue.c             | 17 +++++++++++++++++
 net/netfilter/nfnetlink_queue_core.c | 24 +++++++++++++++++++++++-
 5 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index d81d584157e1..e8635854a55b 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -24,6 +24,8 @@ struct nf_queue_entry {
 struct nf_queue_handler {
 	int			(*outfn)(struct nf_queue_entry *entry,
 					 unsigned int queuenum);
+	void			(*nf_hook_drop)(struct net *net,
+						struct nf_hook_ops *ops);
 };
 
 void nf_register_queue_handler(const struct nf_queue_handler *qh);
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 653e32eac08c..a0e54974e2c9 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -118,6 +118,7 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
 	synchronize_net();
+	nf_queue_nf_hook_drop(reg);
 }
 EXPORT_SYMBOL(nf_unregister_hook);
 
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index ea7f36784b3d..399210693c2a 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -19,6 +19,7 @@ unsigned int nf_iterate(struct list_head *head, struct sk_buff *skb,
 /* nf_queue.c */
 int nf_queue(struct sk_buff *skb, struct nf_hook_ops *elem,
 	     struct nf_hook_state *state, unsigned int queuenum);
+void nf_queue_nf_hook_drop(struct nf_hook_ops *ops);
 int __init netfilter_queue_init(void);
 
 /* nf_log.c */
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 2e88032cd5ad..cd60d397fe05 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -105,6 +105,23 @@ bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
 }
 EXPORT_SYMBOL_GPL(nf_queue_entry_get_refs);
 
+void nf_queue_nf_hook_drop(struct nf_hook_ops *ops)
+{
+	const struct nf_queue_handler *qh;
+	struct net *net;
+
+	rtnl_lock();
+	rcu_read_lock();
+	qh = rcu_dereference(queue_handler);
+	if (qh) {
+		for_each_net(net) {
+			qh->nf_hook_drop(net, ops);
+		}
+	}
+	rcu_read_unlock();
+	rtnl_unlock();
+}
+
 /*
  * Any packet that leaves via this function must come back
  * through nf_reinject().
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 22a5ac76683e..d0479e12d977 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -824,6 +824,27 @@ static struct notifier_block nfqnl_dev_notifier = {
 	.notifier_call	= nfqnl_rcv_dev_event,
 };
 
+static int nf_hook_cmp(struct nf_queue_entry *entry, unsigned long ops_ptr)
+{
+	return entry->elem == (struct nf_hook_ops *)ops_ptr;
+}
+
+static void nfqnl_nf_hook_drop(struct net *net, struct nf_hook_ops *hook)
+{
+	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
+	int i;
+
+	rcu_read_lock();
+	for (i = 0; i < INSTANCE_BUCKETS; i++) {
+		struct nfqnl_instance *inst;
+		struct hlist_head *head = &q->instance_table[i];
+
+		hlist_for_each_entry_rcu(inst, head, hlist)
+			nfqnl_flush(inst, nf_hook_cmp, (unsigned long)hook);
+	}
+	rcu_read_unlock();
+}
+
 static int
 nfqnl_rcv_nl_event(struct notifier_block *this,
 		   unsigned long event, void *ptr)
@@ -1031,7 +1052,8 @@ static const struct nla_policy nfqa_cfg_policy[NFQA_CFG_MAX+1] = {
 };
 
 static const struct nf_queue_handler nfqh = {
-	.outfn	= &nfqnl_enqueue_packet,
+	.outfn		= &nfqnl_enqueue_packet,
+	.nf_hook_drop	= &nfqnl_nf_hook_drop,
 };
 
 static int
--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
