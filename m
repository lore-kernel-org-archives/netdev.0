From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 05/14] x_tables: Pass struct net in xt_action_param
Date: Fri, 18 Sep 2015 11:05:51 -0500
Message-ID: <1442592360-2575-5-git-send-email-ebiederm@xmission.com>
References: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:39813 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbbIRQN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 12:13:29 -0400
In-Reply-To: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As xt_action_param lives on the stack this does not bloat any
persistent data structures.

This is a first step in making netfilter code that needs to know
which network namespace it is executing in simpler.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter/x_tables.h | 3 ++-
 include/net/netfilter/nf_tables.h  | 1 +
 net/bridge/netfilter/ebtables.c    | 1 +
 net/ipv4/netfilter/arp_tables.c    | 1 +
 net/ipv4/netfilter/ip_tables.c     | 1 +
 net/ipv6/netfilter/ip6_tables.c    | 1 +
 net/sched/act_ipt.c                | 1 +
 net/sched/em_ipset.c               | 1 +
 8 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index b006b719183f..c5577410c25d 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -13,6 +13,7 @@
  * @target:	the target extension
  * @matchinfo:	per-match data
  * @targetinfo:	per-target data
+ * @net		network namespace through which the action was invoked
  * @in:		input netdevice
  * @out:	output netdevice
  * @fragoff:	packet is a fragment, this is the data offset
@@ -24,7 +25,6 @@
  * Fields written to by extensions:
  *
  * @hotdrop:	drop packet if we had inspection problems
- * Network namespace obtainable using dev_net(in/out)
  */
 struct xt_action_param {
 	union {
@@ -34,6 +34,7 @@ struct xt_action_param {
 	union {
 		const void *matchinfo, *targinfo;
 	};
+	struct net *net;
 	const struct net_device *in, *out;
 	int fragoff;
 	unsigned int thoff;
diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index c0899f97ff8d..c0516529e8a0 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -30,6 +30,7 @@ static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
 				   const struct nf_hook_state *state)
 {
 	pkt->skb = skb;
+	pkt->xt.net = state->net;
 	pkt->in = pkt->xt.in = state->in;
 	pkt->out = pkt->xt.out = state->out;
 	pkt->hook = pkt->xt.hooknum = state->hook;
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 8d5a3975b963..f46ca417bf2d 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -200,6 +200,7 @@ unsigned int ebt_do_table(struct sk_buff *skb,
 	struct xt_action_param acpar;
 
 	acpar.family  = NFPROTO_BRIDGE;
+	acpar.net     = state->net;
 	acpar.in      = state->in;
 	acpar.out     = state->out;
 	acpar.hotdrop = false;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 10eb2b297450..2dad3e1c5f11 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -285,6 +285,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	 */
 	e = get_entry(table_base, private->hook_entry[hook]);
 
+	acpar.net     = state->net;
 	acpar.in      = state->in;
 	acpar.out     = state->out;
 	acpar.hooknum = hook;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 2b049e135de8..42d0946956db 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -315,6 +315,7 @@ ipt_do_table(struct sk_buff *skb,
 	acpar.fragoff = ntohs(ip->frag_off) & IP_OFFSET;
 	acpar.thoff   = ip_hdrlen(skb);
 	acpar.hotdrop = false;
+	acpar.net     = state->net;
 	acpar.in      = state->in;
 	acpar.out     = state->out;
 	acpar.family  = NFPROTO_IPV4;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index da6446b6e3f9..80e3bd72b715 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -340,6 +340,7 @@ ip6t_do_table(struct sk_buff *skb,
 	 * rule is also a fragment-specific rule, non-fragments won't
 	 * match it. */
 	acpar.hotdrop = false;
+	acpar.net     = state->net;
 	acpar.in      = state->in;
 	acpar.out     = state->out;
 	acpar.family  = NFPROTO_IPV6;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 99c9cc1c7af9..d05869646515 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -189,6 +189,7 @@ static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 	 * worry later - danger - this API seems to have changed
 	 * from earlier kernels
 	 */
+	par.net	     = dev_net(skb->dev);
 	par.in       = skb->dev;
 	par.out      = NULL;
 	par.hooknum  = ipt->tcfi_hook;
diff --git a/net/sched/em_ipset.c b/net/sched/em_ipset.c
index df0328ba6a48..c66ca9400ab4 100644
--- a/net/sched/em_ipset.c
+++ b/net/sched/em_ipset.c
@@ -95,6 +95,7 @@ static int em_ipset_match(struct sk_buff *skb, struct tcf_ematch *em,
 	if (skb->skb_iif)
 		indev = dev_get_by_index_rcu(em->net, skb->skb_iif);
 
+	acpar.net     = em->net;
 	acpar.in      = indev ? indev : dev;
 	acpar.out     = dev;
 
-- 
2.2.1
