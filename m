From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 09/15] x_tables: Pass struct net in xt_action_param
Date: Sun, 14 Jun 2015 22:13:07 -0500
Message-ID: <1434337993-6248-9-git-send-email-ebiederm@xmission.com>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87616ppt3h.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As xt_action_param lives on the stack this does not bloat any
persistent data structures.

This is a first step in making netfilter code that needs to know
which network namespace it is executing in simpler.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter/x_tables.h | 2 ++
 include/net/netfilter/nf_tables.h  | 1 +
 net/bridge/netfilter/ebtables.c    | 1 +
 net/ipv4/netfilter/arp_tables.c    | 1 +
 net/ipv4/netfilter/ip_tables.c     | 1 +
 net/ipv6/netfilter/ip6_tables.c    | 1 +
 net/sched/act_ipt.c                | 1 +
 net/sched/em_ipset.c               | 1 +
 8 files changed, 9 insertions(+)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 09f38206c18f..1499520f2ee0 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -12,6 +12,7 @@
  * @target:	the target extension
  * @matchinfo:	per-match data
  * @targetinfo:	per-target data
+ * @net		network namespace of through which the action was invoked
  * @in:		input netdevice
  * @out:	output netdevice
  * @fragoff:	packet is a fragment, this is the data offset
@@ -33,6 +34,7 @@ struct xt_action_param {
 	union {
 		const void *matchinfo, *targinfo;
 	};
+	struct net *net;
 	const struct net_device *in, *out;
 	int fragoff;
 	unsigned int thoff;
diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index dd20bbdcdf6f..7b3d7c79ecdc 100644
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
index 9c0230583e90..21e869b09c2b 100644
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
index 97ab571e4325..401628da5168 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -280,6 +280,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
 
+	acpar.net     = state->net;
 	acpar.in      = state->in;
 	acpar.out     = state->out;
 	acpar.hooknum = hook;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index b2958fe20255..c3564b934f92 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -316,6 +316,7 @@ ipt_do_table(struct sk_buff *skb,
 	acpar.fragoff = ntohs(ip->frag_off) & IP_OFFSET;
 	acpar.thoff   = ip_hdrlen(skb);
 	acpar.hotdrop = false;
+	acpar.net     = state->net;
 	acpar.in      = state->in;
 	acpar.out     = state->out;
 	acpar.family  = NFPROTO_IPV4;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 37b6f0a48deb..bed8f68a6eac 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -341,6 +341,7 @@ ip6t_do_table(struct sk_buff *skb,
 	 * rule is also a fragment-specific rule, non-fragments won't
 	 * match it. */
 	acpar.hotdrop = false;
+	acpar.net     = state->net;
 	acpar.in      = state->in;
 	acpar.out     = state->out;
 	acpar.family  = NFPROTO_IPV6;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index cbc8dd7dd48a..b08faaa7161a 100644
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

