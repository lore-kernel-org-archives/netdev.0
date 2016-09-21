From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next v3 4/7] nf_hook_slow: Remove explicit rcu_read_lock
Date: Wed, 21 Sep 2016 11:35:04 -0400
Message-ID: <1474472107-12992-5-git-send-email-aconole@bytheb.org>
References: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:35986 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933140AbcIUPfr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:35:47 -0400
Received: by mail-yw0-f193.google.com with SMTP id v2so3078634ywg.3
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 08:35:47 -0700 (PDT)
In-Reply-To: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All of the callers of nf_hook_slow already hold the rcu_read_lock, so this
cleanup removes the recursive call.  This is just a cleanup, as the locking
code gracefully handles this situation.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
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
 net/netfilter/nfnetlink_log.c                  | 6 ++++--
 net/netfilter/nfnetlink_queue.c                | 2 +-
 net/netfilter/xt_helper.c                      | 2 +-
 14 files changed, 17 insertions(+), 19 deletions(-)

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
index cceac5b..dd71332 100644
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
index 870aebd..713c09a 100644
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
index 4b5904b..d075b3c 100644
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
index f39276d..c8faf81 100644
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
index 8d1ddb9..c94ec19 100644
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
index 5c0db5c..f65d936 100644
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
index 4ffe388..336e215 100644
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
index 6577db5..f2446e7 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -442,7 +442,8 @@ __build_packet_message(struct nfnl_log_net *log,
 			if (nla_put_be32(inst->skb, NFULA_IFINDEX_PHYSINDEV,
 					 htonl(indev->ifindex)) ||
 			/* this is the bridge group "brX" */
-			/* rcu_read_lock()ed by nf_hook_slow or nf_log_packet */
+			/* rcu_read_lock()ed by nf_hook_thresh or
+			 * nf_log_packet */
 			    nla_put_be32(inst->skb, NFULA_IFINDEX_INDEV,
 					 htonl(br_port_get_rcu(indev)->br->dev->ifindex)))
 				goto nla_put_failure;
@@ -477,7 +478,8 @@ __build_packet_message(struct nfnl_log_net *log,
 			if (nla_put_be32(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
 					 htonl(outdev->ifindex)) ||
 			/* this is the bridge group "brX" */
-			/* rcu_read_lock()ed by nf_hook_slow or nf_log_packet */
+			/* rcu_read_lock()ed by nf_hook_thresh or
+			 * nf_log_packet */
 			    nla_put_be32(inst->skb, NFULA_IFINDEX_OUTDEV,
 					 htonl(br_port_get_rcu(outdev)->br->dev->ifindex)))
 				goto nla_put_failure;
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 808da34..7caa8b0 100644
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
2.7.4
