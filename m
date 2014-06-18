From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/13] netfilter: ctnetlink: fix refcnt leak in dying/unconfirmed list dumper
Date: Wed, 18 Jun 2014 11:44:29 +0200
Message-ID: <1403084679-11227-4-git-send-email-pablo@netfilter.org>
References: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41403 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965619AbaFRJow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 05:44:52 -0400
In-Reply-To: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

'last' keeps track of the ct that had its refcnt bumped during previous
dump cycle.  Thus it must not be overwritten until end-of-function.

Another (unrelated, theoretical) issue: Don't attempt to bump refcnt of a conntrack
whose reference count is already 0.  Such conntrack is being destroyed
right now, its memory is freed once we release the percpu dying spinlock.

Fixes: b7779d06 ('netfilter: conntrack: spinlock per cpu to protect special lists.')
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index ef0eedd..70123f4 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1150,7 +1150,7 @@ static int ctnetlink_done_list(struct netlink_callback *cb)
 static int
 ctnetlink_dump_list(struct sk_buff *skb, struct netlink_callback *cb, bool dying)
 {
-	struct nf_conn *ct, *last = NULL;
+	struct nf_conn *ct, *last;
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
 	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
@@ -1163,6 +1163,8 @@ ctnetlink_dump_list(struct sk_buff *skb, struct netlink_callback *cb, bool dying
 	if (cb->args[2])
 		return 0;
 
+	last = (struct nf_conn *)cb->args[1];
+
 	for (cpu = cb->args[0]; cpu < nr_cpu_ids; cpu++) {
 		struct ct_pcpu *pcpu;
 
@@ -1171,7 +1173,6 @@ ctnetlink_dump_list(struct sk_buff *skb, struct netlink_callback *cb, bool dying
 
 		pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
 		spin_lock_bh(&pcpu->lock);
-		last = (struct nf_conn *)cb->args[1];
 		list = dying ? &pcpu->dying : &pcpu->unconfirmed;
 restart:
 		hlist_nulls_for_each_entry(h, n, list, hnnode) {
@@ -1190,7 +1191,8 @@ restart:
 						  ct);
 			rcu_read_unlock();
 			if (res < 0) {
-				nf_conntrack_get(&ct->ct_general);
+				if (!atomic_inc_not_zero(&ct->ct_general.use))
+					continue;
 				cb->args[0] = cpu;
 				cb->args[1] = (unsigned long)ct;
 				spin_unlock_bh(&pcpu->lock);
-- 
1.7.10.4
