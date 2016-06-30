From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next 2/3] netfilter: call nf_hook_state_init with rcu_read_lock held
Date: Thu, 30 Jun 2016 17:19:34 -0400
Message-ID: <1467321575-6107-3-git-send-email-aconole@bytheb.org>
References: <1467321575-6107-1-git-send-email-aconole@bytheb.org>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467321575-6107-1-git-send-email-aconole@bytheb.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

This makes things simpler because we can store the head of the list
in the nf_state structure without worrying about concurrent add/delete
of hook elements from the list.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 include/linux/netfilter.h                      | 8 +++++++-
 include/linux/netfilter_ingress.h              | 1 +
 net/bridge/netfilter/ebt_redirect.c            | 2 +-
 net/bridge/netfilter/ebtables.c                | 2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   | 2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c | 2 +-
 net/netfilter/core.c                           | 5 +----
 net/netfilter/nf_conntrack_core.c              | 2 +-
 net/netfilter/nf_conntrack_h323_main.c         | 2 +-
 net/netfilter/nf_conntrack_helper.c            | 2 +-
 net/netfilter/nfnetlink_cthelper.c             | 2 +-
 net/netfilter/nfnetlink_log.c                  | 8 ++++++--
 net/netfilter/nfnetlink_queue.c                | 2 +-
 net/netfilter/xt_helper.c                      | 2 +-
 16 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 9230f9a..ad444f0 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -174,10 +174,16 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 
 	if (!list_empty(hook_list)) {
 		struct nf_hook_state state;
+		int ret;
 
+		/* We may already have this, but read-locks nest anyway */
+		rcu_read_lock();
 		nf_hook_state_init(&state, hook_list, hook, thresh,
 				   pf, indev, outdev, sk, net, okfn);
-		return nf_hook_slow(skb, &state);
+
+		ret = nf_hook_slow(skb, &state);
+		rcu_read_unlock();
+		return ret;
 	}
 	return 1;
 }
diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
index 5fcd375..6965ba0 100644
--- a/include/linux/netfilter_ingress.h
+++ b/include/linux/netfilter_ingress.h
@@ -14,6 +14,7 @@ static inline bool nf_hook_ingress_active(const struct sk_buff *skb)
 	return !list_empty(&skb->dev->nf_hooks_ingress);
 }
 
+/* caller must hold rcu_read_lock */
 static inline int nf_hook_ingress(struct sk_buff *skb)
 {
 	struct nf_hook_state state;
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index 20396499..2e7c4f9 100644
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
index 5a61f35..6faa2c3 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -148,7 +148,7 @@ ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
 		return 1;
 	if (FWINV2(ebt_dev_check(e->out, out), EBT_IOUT))
 		return 1;
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	if (in && (p = br_port_get_rcu(in)) != NULL &&
 	    FWINV2(ebt_dev_check(e->logical_in, p->br->dev), EBT_ILOGICALIN))
 		return 1;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index ae1a71a..eab0239 100644
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
index c567e1b..2c08d6a 100644
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
index 1aa5848..963ee38 100644
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
index 660bc10..f5a61bc 100644
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
index f39276d..6561d5c 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -291,6 +291,7 @@ repeat:
 
 
 /* Returns 1 if okfn() needs to be executed by the caller,
+ * Must be called with rcu_read_lock held.
  * -EPERM for NF_DROP, 0 otherwise. */
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
 {
@@ -298,9 +299,6 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
 	unsigned int verdict;
 	int ret = 0;
 
-	/* We may already have this, but read-locks nest anyway */
-	rcu_read_lock();
-
 	elem = list_entry_rcu(state->hook_list, struct nf_hook_ops, list);
 next_hook:
 	verdict = nf_iterate(state->hook_list, skb, state, &elem);
@@ -321,7 +319,6 @@ next_hook:
 			kfree_skb(skb);
 		}
 	}
-	rcu_read_unlock();
 	return ret;
 }
 EXPORT_SYMBOL(nf_hook_slow);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index db2312e..b85521a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1172,7 +1172,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		skb->nfct = NULL;
 	}
 
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	l3proto = __nf_ct_l3proto_find(pf);
 	ret = l3proto->get_l4proto(skb, skb_network_offset(skb),
 				   &dataoff, &protonum);
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 9511af0..4c426c6 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -736,7 +736,7 @@ static int callforward_do_filter(struct net *net,
 	const struct nf_afinfo *afinfo;
 	int ret = 0;
 
-	/* rcu_read_lock()ed by nf_hook_slow() */
+	/* rcu_read_lock()ed by nf_hook_thresh() */
 	afinfo = nf_get_afinfo(family);
 	if (!afinfo)
 		return 0;
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 196cb39..5f127e7 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -349,7 +349,7 @@ void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *ct,
 	/* Called from the helper function, this call never fails */
 	help = nfct_help(ct);
 
-	/* rcu_read_lock()ed by nf_hook_slow */
+	/* rcu_read_lock()ed by nf_hook_thresh */
 	helper = rcu_dereference(help->helper);
 
 	nf_log_packet(nf_ct_net(ct), nf_ct_l3num(ct), 0, skb, NULL, NULL, NULL,
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index e924e95..3b79f34 100644
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
index 11f81c8..b219741 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -442,7 +442,9 @@ __build_packet_message(struct nfnl_log_net *log,
 			if (nla_put_be32(inst->skb, NFULA_IFINDEX_PHYSINDEV,
 					 htonl(indev->ifindex)) ||
 			/* this is the bridge group "brX" */
-			/* rcu_read_lock()ed by nf_hook_slow or nf_log_packet */
+			/* rcu_read_lock()ed by nf_hook_thresh or
+			 * nf_log_packet
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
+			 * nf_log_packet
+			 */
 			    nla_put_be32(inst->skb, NFULA_IFINDEX_OUTDEV,
 					 htonl(br_port_get_rcu(outdev)->br->dev->ifindex)))
 				goto nla_put_failure;
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 5d36a09..216bf69 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -740,7 +740,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	struct net *net = entry->state.net;
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 
-	/* rcu_read_lock()ed by nf_hook_slow() */
+	/* rcu_read_lock()ed by nf_hook_thresh() */
 	queue = instance_lookup(q, queuenum);
 	if (!queue)
 		return -ESRCH;
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index 9f4ab00..a883edb 100644
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
2.5.5

