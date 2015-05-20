From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] net: sched: fix call_rcu() race on classifier module unloads
Date: Wed, 20 May 2015 17:13:33 +0200
Message-ID: <9f44c4c5d2ad81e7d7ef828b9e60bd308fc7caf9.1432134471.git.daniel@iogearbox.net>
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41014 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbbETPNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 11:13:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vijay reported that a loop as simple as ...

  while true; do
    tc qdisc add dev foo root handle 1: prio
    tc filter add dev foo parent 1: u32 match u32 0 0  flowid 1
    tc qdisc del dev foo root
    rmmod cls_u32
  done

... will panic the kernel. Moreover, he bisected the change
apparently introducing it to 78fd1d0ab072 ("netlink: Re-add
locking to netlink_lookup() and seq walker").

The removal of synchronize_net() from the netlink socket
triggering the qdisc to be removed, seems to have uncovered
an RCU resp. module reference count race from the tc API.
Given that RCU conversion was done after e341694e3eb5 ("netlink:
Convert netlink_lookup() to use RCU protected hash table")
which added the synchronize_net() originally, occasion of
hitting the bug was less likely (not impossible though):

When qdiscs that i) support attaching classifiers and,
ii) have at least one of them attached, get deleted, they
invoke tcf_destroy_chain(), and thus call into ->destroy()
handler from a classifier module.

After RCU conversion, all classifier that have an internal
prio list, unlink them and initiate freeing via call_rcu()
deferral.

Meanhile, tcf_destroy() releases already reference to the
tp->ops->owner module before the queued RCU callback handler
has been invoked.

Subsequent rmmod on the classifier module is then not prevented
since all module references are already dropped.

By the time, the kernel invokes the RCU callback handler from
the module, that function address is then invalid.

One way to fix it would be to add an rcu_barrier() to
unregister_tcf_proto_ops() to wait for all pending call_rcu()s
to complete.

synchronize_rcu() is not appropriate as under heavy RCU
callback load, registered call_rcu()s could be deferred
longer than a grace period. In case we don't have any pending
call_rcu()s, the barrier is allowed to return immediately.

Since we came here via unregister_tcf_proto_ops(), there
are no users of a given classifier anymore. Further nested
call_rcu()s pointing into the module space are not being
done anywhere.

Only cls_bpf_delete_prog() may schedule a work item, to
unlock pages eventually, but that is not in the range/context
of cls_bpf anymore.

Fixes: 25d8c0d55f24 ("net: rcu-ify tcf_proto")
Fixes: 9888faefe132 ("net: sched: cls_basic use RCU")
Reported-by: Vijay Subramanian <subramanian.vijay@gmail.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 (For Fixes tags, I've added the first ones that should be affected.)

 Vijay, can you give this a run on your side? This fixes the panic
 on my side, thanks!

 net/sched/cls_api.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index b6ef9a0..a75864d 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -81,6 +81,11 @@ int unregister_tcf_proto_ops(struct tcf_proto_ops *ops)
 	struct tcf_proto_ops *t;
 	int rc = -ENOENT;
 
+	/* Wait for outstanding call_rcu()s, if any, from a
+	 * tcf_proto_ops's destroy() handler.
+	 */
+	rcu_barrier();
+
 	write_lock(&cls_mod_lock);
 	list_for_each_entry(t, &tcf_proto_base, head) {
 		if (t == ops) {
-- 
1.9.3
