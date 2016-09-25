From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 40/53] netfilter: Remove explicit rcu_read_lock in nf_hook_slow
Date: Mon, 26 Sep 2016 01:06:50 +0200
Message-ID: <1474844823-2026-41-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aaron Conole <aconole@bytheb.org>

All of the callers of nf_hook_slow already hold the rcu_read_lock, so this
cleanup removes the recursive call.  This is just a cleanup, as the locking
code gracefully handles this situation.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_redirect.c            | 2 +-
 net/bridge/netfilter/ebtables.c                | 2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   | 2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c | 2 +-
 net/netfilter/core.c                           | 6 +-----
 net/netfilter/nf_conntrack_core.c              | 2 +-
 net/netfilter/nf_conntrack_h323_main.c         | 2 +-
 net/netfilter/nf_conntrack_helper.c            | 2 +-
 net/netfilter/nfnetlink_cthelper.c             | 2 +-
 net/netfilter/nfnetlink_log.c                  | 8 ++++++--
 net/netfilter/nfnetlink_queue.c                | 2 +-
 net/netfilter/xt_helper.c                      | 2 +-
 14 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index 203964997a51..2e7c4f974340 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -24,7 +24,7 @@ ebt_redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		return EBT_DROP;
 
 	if (par->hooknum != NF_BR_BROUTING)
-		/* rcu_read_lock()ed by nf_hook_slow */
+		/* rcu_read_lock()ed by nf_hook_thresh */
 		ether_addr_copy(eth_hdr(skb)->h_dest,
 				br_port_get_rcu(par->in)->br->dev->dev_addr);
 	else
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index cceac5bb658f..dd7133216c9c 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -146,7 +146,7 @@ ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
 		return 1;
 	if (NF_INVF(e, EBT_IOUT, ebt_dev_check(e->out, out)))
 		return 1;
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	if (in && (p = br_port_get_rcu(in)) != NULL &&
 	    NF_INVF(e, EBT_ILOGICALIN,
 		    ebt_dev_check(e->logical_in, p->br->dev)))
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 870aebda2932..713c09a74b90 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -110,7 +110,7 @@ static unsigned int ipv4_helper(void *priv,
 	if (!help)
 		return NF_ACCEPT;
 
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	helper = rcu_dereference(help->helper);
 	if (!helper)
 		return NF_ACCEPT;
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 4b5904bc2614..d075b3cf2400 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -149,7 +149,7 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 		return -NF_ACCEPT;
 	}
 
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	innerproto = __nf_ct_l4proto_find(PF_INET, origtuple.dst.protonum);
 
 	/* Ordinarily, we'd expect the inverted tupleproto, but it's
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 1aa5848764a7..963ee3848675 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -115,7 +115,7 @@ static unsigned int ipv6_helper(void *priv,
 	help = nfct_help(ct);
 	if (!help)
 		return NF_ACCEPT;
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	helper = rcu_dereference(help->helper);
 	if (!helper)
 		return NF_ACCEPT;
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 660bc10c7a9c..f5a61bc3ec2b 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -165,7 +165,7 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 		return -NF_ACCEPT;
 	}
 
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	inproto = __nf_ct_l4proto_find(PF_INET6, origtuple.dst.protonum);
 
 	/* Ordinarily, we'd expect the inverted tupleproto, but it's
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index f39276d1c2d7..c8faf8102394 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -291,16 +291,13 @@ repeat:
 
 
 /* Returns 1 if okfn() needs to be executed by the caller,
- * -EPERM for NF_DROP, 0 otherwise. */
+ * -EPERM for NF_DROP, 0 otherwise.  Caller must hold rcu_read_lock. */
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
 {
 	struct nf_hook_ops *elem;
 	unsigned int verdict;
 	int ret = 0;
 
-	/* We may already have this, but read-locks nest anyway */
-	rcu_read_lock();
-
 	elem = list_entry_rcu(state->hook_list, struct nf_hook_ops, list);
 next_hook:
 	verdict = nf_iterate(state->hook_list, skb, state, &elem);
@@ -321,7 +318,6 @@ next_hook:
 			kfree_skb(skb);
 		}
 	}
-	rcu_read_unlock();
 	return ret;
 }
 EXPORT_SYMBOL(nf_hook_slow);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 8d1ddb9b63ed..c94ec197845c 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1275,7 +1275,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		skb->nfct = NULL;
 	}
 
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	l3proto = __nf_ct_l3proto_find(pf);
 	ret = l3proto->get_l4proto(skb, skb_network_offset(skb),
 				   &dataoff, &protonum);
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 5c0db5c64734..f65d93639d12 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -736,7 +736,7 @@ static int callforward_do_filter(struct net *net,
 	const struct nf_afinfo *afinfo;
 	int ret = 0;
 
-	/* rcu_read_lock()ed by nf_hook_slow() */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	afinfo = nf_get_afinfo(family);
 	if (!afinfo)
 		return 0;
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 4ffe388a9a1e..336e21559e01 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -346,7 +346,7 @@ void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *ct,
 	/* Called from the helper function, this call never fails */
 	help = nfct_help(ct);
 
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	helper = rcu_dereference(help->helper);
 
 	nf_log_packet(nf_ct_net(ct), nf_ct_l3num(ct), 0, skb, NULL, NULL, NULL,
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index e924e95fcc7f..3b79f34b5095 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -43,7 +43,7 @@ nfnl_userspace_cthelper(struct sk_buff *skb, unsigned int protoff,
 	if (help == NULL)
 		return NF_DROP;
 
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	helper = rcu_dereference(help->helper);
 	if (helper == NULL)
 		return NF_DROP;
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 6577db524ef6..eb086a192c5a 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -442,7 +442,9 @@ __build_packet_message(struct nfnl_log_net *log,
 			if (nla_put_be32(inst->skb, NFULA_IFINDEX_PHYSINDEV,
 					 htonl(indev->ifindex)) ||
 			/* this is the bridge group "brX" */
-			/* rcu_read_lock()ed by nf_hook_slow or nf_log_packet */
+			/* rcu_read_lock()ed by nf_hook_thresh or
+			 * nf_log_packet.
+			 */
 			    nla_put_be32(inst->skb, NFULA_IFINDEX_INDEV,
 					 htonl(br_port_get_rcu(indev)->br->dev->ifindex)))
 				goto nla_put_failure;
@@ -477,7 +479,9 @@ __build_packet_message(struct nfnl_log_net *log,
 			if (nla_put_be32(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
 					 htonl(outdev->ifindex)) ||
 			/* this is the bridge group "brX" */
-			/* rcu_read_lock()ed by nf_hook_slow or nf_log_packet */
+			/* rcu_read_lock()ed by nf_hook_thresh or
+			 * nf_log_packet.
+			 */
 			    nla_put_be32(inst->skb, NFULA_IFINDEX_OUTDEV,
 					 htonl(br_port_get_rcu(outdev)->br->dev->ifindex)))
 				goto nla_put_failure;
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 808da34f94cd..7caa8b082c41 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -740,7 +740,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	struct net *net = entry->state.net;
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 
-	/* rcu_read_lock()ed by nf_hook_slow() */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	queue = instance_lookup(q, queuenum);
 	if (!queue)
 		return -ESRCH;
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index 805c9f64a04c..f679dd4c272a 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -41,7 +41,7 @@ helper_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (!master_help)
 		return ret;
 
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	helper = rcu_dereference(master_help->helper);
 	if (!helper)
 		return ret;
-- 
2.1.4

