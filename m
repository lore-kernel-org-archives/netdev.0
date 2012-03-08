From: pablo@netfilter.org
Subject: [PATCH 15/23] netfilter: ctnetlink: fix lockep splats
Date: Thu,  8 Mar 2012 02:01:04 +0100
Message-ID: <1331168472-5820-16-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans Schillstrom <hans@schillstrom.com>

net/netfilter/nf_conntrack_proto.c:70 suspicious rcu_dereference_check() usage!

other info that might help us debug this:

rcu_scheduler_active = 1, debug_locks = 0
3 locks held by conntrack/3235:
nfnl_lock+0x17/0x20
netlink_dump+0x32/0x240
ctnetlink_dump_table+0x3e/0x170 [nf_conntrack_netlink]

stack backtrace:
Pid: 3235, comm: conntrack Tainted: G W  3.2.0+ #511
Call Trace:
[<ffffffff8108ce45>] lockdep_rcu_suspicious+0xe5/0x100
[<ffffffffa00ec6e1>] __nf_ct_l4proto_find+0x81/0xb0 [nf_conntrack]
[<ffffffffa0115675>] ctnetlink_fill_info+0x215/0x5f0 [nf_conntrack_netlink]
[<ffffffffa0115dc1>] ctnetlink_dump_table+0xd1/0x170 [nf_conntrack_netlink]
[<ffffffff815fbdbf>] netlink_dump+0x7f/0x240
[<ffffffff81090f9d>] ? trace_hardirqs_on+0xd/0x10
[<ffffffff815fd34f>] netlink_dump_start+0xdf/0x190
[<ffffffffa0111490>] ? ctnetlink_change_nat_seq_adj+0x160/0x160 [nf_conntrack_netlink]
[<ffffffffa0115cf0>] ? ctnetlink_get_conntrack+0x2a0/0x2a0 [nf_conntrack_netlink]
[<ffffffffa0115ad9>] ctnetlink_get_conntrack+0x89/0x2a0 [nf_conntrack_netlink]
[<ffffffff81603a47>] nfnetlink_rcv_msg+0x467/0x5f0
[<ffffffff81603a7c>] ? nfnetlink_rcv_msg+0x49c/0x5f0
[<ffffffff81603922>] ? nfnetlink_rcv_msg+0x342/0x5f0
[<ffffffff81071b21>] ? get_parent_ip+0x11/0x50
[<ffffffff816035e0>] ? nfnetlink_subsys_register+0x60/0x60
[<ffffffff815fed49>] netlink_rcv_skb+0xa9/0xd0
[<ffffffff81603475>] nfnetlink_rcv+0x15/0x20
[<ffffffff815fe70e>] netlink_unicast+0x1ae/0x1f0
[<ffffffff815fea16>] netlink_sendmsg+0x2c6/0x320
[<ffffffff815b2a87>] sock_sendmsg+0x117/0x130
[<ffffffff81125093>] ? might_fault+0x53/0xb0
[<ffffffff811250dc>] ? might_fault+0x9c/0xb0
[<ffffffff81125093>] ? might_fault+0x53/0xb0
[<ffffffff815b5991>] ? move_addr_to_kernel+0x71/0x80
[<ffffffff815b644e>] sys_sendto+0xfe/0x130
[<ffffffff815b5c94>] ? sys_bind+0xb4/0xd0
[<ffffffff817a8a0e>] ? retint_swapgs+0xe/0x13
[<ffffffff817afcd2>] system_call_fastpath+0x16/0x1b

Reported-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/nf_conntrack_netlink.c |   40 ++++++++++++++++++++-------------
 1 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index b8827e8..c1ea64c 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -110,15 +110,16 @@ ctnetlink_dump_tuples(struct sk_buff *skb,
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
 
+	rcu_read_lock();
 	l3proto = __nf_ct_l3proto_find(tuple->src.l3num);
 	ret = ctnetlink_dump_tuples_ip(skb, tuple, l3proto);
 
-	if (unlikely(ret < 0))
-		return ret;
-
-	l4proto = __nf_ct_l4proto_find(tuple->src.l3num, tuple->dst.protonum);
-	ret = ctnetlink_dump_tuples_proto(skb, tuple, l4proto);
-
+	if (ret >= 0) {
+		l4proto = __nf_ct_l4proto_find(tuple->src.l3num,
+					       tuple->dst.protonum);
+		ret = ctnetlink_dump_tuples_proto(skb, tuple, l4proto);
+	}
+	rcu_read_unlock();
 	return ret;
 }
 
@@ -712,9 +713,11 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	struct hlist_nulls_node *n;
 	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	u_int8_t l3proto = nfmsg->nfgen_family;
+	int res;
 #ifdef CONFIG_NF_CONNTRACK_MARK
 	const struct ctnetlink_dump_filter *filter = cb->data;
 #endif
+
 	spin_lock_bh(&nf_conntrack_lock);
 	last = (struct nf_conn *)cb->args[1];
 	for (; cb->args[0] < net->ct.htable_size; cb->args[0]++) {
@@ -740,11 +743,14 @@ restart:
 				continue;
 			}
 #endif
-			if (ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
-						cb->nlh->nlmsg_seq,
-						NFNL_MSG_TYPE(
-							cb->nlh->nlmsg_type),
-						ct) < 0) {
+			rcu_read_lock();
+			res =
+			ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
+					    cb->nlh->nlmsg_seq,
+					    NFNL_MSG_TYPE(cb->nlh->nlmsg_type),
+					    ct);
+			rcu_read_unlock();
+			if (res < 0) {
 				nf_conntrack_get(&ct->ct_general);
 				cb->args[1] = (unsigned long)ct;
 				goto out;
@@ -1649,14 +1655,16 @@ ctnetlink_exp_dump_mask(struct sk_buff *skb,
 	if (!nest_parms)
 		goto nla_put_failure;
 
+	rcu_read_lock();
 	l3proto = __nf_ct_l3proto_find(tuple->src.l3num);
 	ret = ctnetlink_dump_tuples_ip(skb, &m, l3proto);
-
-	if (unlikely(ret < 0))
-		goto nla_put_failure;
-
-	l4proto = __nf_ct_l4proto_find(tuple->src.l3num, tuple->dst.protonum);
+	if (ret >= 0) {
+		l4proto = __nf_ct_l4proto_find(tuple->src.l3num,
+					       tuple->dst.protonum);
 	ret = ctnetlink_dump_tuples_proto(skb, &m, l4proto);
+	}
+	rcu_read_unlock();
+
 	if (unlikely(ret < 0))
 		goto nla_put_failure;
 
-- 
1.7.7.3

