From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/39] netfilter: x_tables: move hook state into xt_action_param structure
Date: Sun, 13 Nov 2016 23:24:59 +0100
Message-ID: <1479075933-4491-6-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47650 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965000AbcKMW0O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:26:14 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 58DDCA7E98
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:06 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 22442DA853
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:06 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D707ADA80B
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:01 +0100 (CET)
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Place pointer to hook state in xt_action_param structure instead of
copying the fields that we need. After this change xt_action_param fits
into one cacheline.

This patch also adds a set of new wrapper functions to fetch relevant
hook state structure fields.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h         | 48 +++++++++++++++++++++++-------
 include/net/netfilter/nf_tables.h          | 11 +++----
 net/bridge/netfilter/ebt_arpreply.c        |  3 +-
 net/bridge/netfilter/ebt_log.c             | 11 +++----
 net/bridge/netfilter/ebt_nflog.c           |  6 ++--
 net/bridge/netfilter/ebt_redirect.c        |  6 ++--
 net/bridge/netfilter/ebtables.c            |  6 +---
 net/ipv4/netfilter/arp_tables.c            |  6 +---
 net/ipv4/netfilter/ip_tables.c             |  6 +---
 net/ipv4/netfilter/ipt_MASQUERADE.c        |  3 +-
 net/ipv4/netfilter/ipt_REJECT.c            |  4 +--
 net/ipv4/netfilter/ipt_SYNPROXY.c          |  4 +--
 net/ipv4/netfilter/ipt_rpfilter.c          |  2 +-
 net/ipv6/netfilter/ip6_tables.c            |  6 +---
 net/ipv6/netfilter/ip6t_MASQUERADE.c       |  2 +-
 net/ipv6/netfilter/ip6t_REJECT.c           | 23 ++++++++------
 net/ipv6/netfilter/ip6t_SYNPROXY.c         |  4 +--
 net/ipv6/netfilter/ip6t_rpfilter.c         |  3 +-
 net/netfilter/ipset/ip_set_core.c          |  6 ++--
 net/netfilter/ipset/ip_set_hash_netiface.c |  2 +-
 net/netfilter/xt_AUDIT.c                   | 10 +++----
 net/netfilter/xt_LOG.c                     |  6 ++--
 net/netfilter/xt_NETMAP.c                  | 20 ++++++-------
 net/netfilter/xt_NFLOG.c                   |  6 ++--
 net/netfilter/xt_NFQUEUE.c                 |  4 +--
 net/netfilter/xt_REDIRECT.c                |  4 +--
 net/netfilter/xt_TCPMSS.c                  |  4 +--
 net/netfilter/xt_TEE.c                     |  4 +--
 net/netfilter/xt_TPROXY.c                  | 16 +++++-----
 net/netfilter/xt_addrtype.c                | 10 +++----
 net/netfilter/xt_cluster.c                 |  2 +-
 net/netfilter/xt_connlimit.c               |  8 ++---
 net/netfilter/xt_conntrack.c               |  8 ++---
 net/netfilter/xt_devgroup.c                |  4 +--
 net/netfilter/xt_dscp.c                    |  2 +-
 net/netfilter/xt_ipvs.c                    |  4 +--
 net/netfilter/xt_nfacct.c                  |  2 +-
 net/netfilter/xt_osf.c                     | 10 +++----
 net/netfilter/xt_owner.c                   |  2 +-
 net/netfilter/xt_pkttype.c                 |  4 +--
 net/netfilter/xt_policy.c                  |  4 +--
 net/netfilter/xt_recent.c                  | 10 +++----
 net/netfilter/xt_set.c                     | 26 ++++++++--------
 net/netfilter/xt_socket.c                  |  4 +--
 net/sched/act_ipt.c                        | 12 ++++----
 net/sched/em_ipset.c                       | 17 ++++++-----
 46 files changed, 196 insertions(+), 169 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 2ad1a2b289b5..cd4eaf8df445 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -4,6 +4,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/static_key.h>
+#include <linux/netfilter.h>
 #include <uapi/linux/netfilter/x_tables.h>
 
 /* Test a struct->invflags and a boolean for inequality */
@@ -17,14 +18,9 @@
  * @target:	the target extension
  * @matchinfo:	per-match data
  * @targetinfo:	per-target data
- * @net		network namespace through which the action was invoked
- * @in:		input netdevice
- * @out:	output netdevice
+ * @state:	pointer to hook state this packet came from
  * @fragoff:	packet is a fragment, this is the data offset
  * @thoff:	position of transport header relative to skb->data
- * @hook:	hook number given packet came from
- * @family:	Actual NFPROTO_* through which the function is invoked
- * 		(helpful when match->family == NFPROTO_UNSPEC)
  *
  * Fields written to by extensions:
  *
@@ -38,15 +34,47 @@ struct xt_action_param {
 	union {
 		const void *matchinfo, *targinfo;
 	};
-	struct net *net;
-	const struct net_device *in, *out;
+	const struct nf_hook_state *state;
 	int fragoff;
 	unsigned int thoff;
-	unsigned int hooknum;
-	u_int8_t family;
 	bool hotdrop;
 };
 
+static inline struct net *xt_net(const struct xt_action_param *par)
+{
+	return par->state->net;
+}
+
+static inline struct net_device *xt_in(const struct xt_action_param *par)
+{
+	return par->state->in;
+}
+
+static inline const char *xt_inname(const struct xt_action_param *par)
+{
+	return par->state->in->name;
+}
+
+static inline struct net_device *xt_out(const struct xt_action_param *par)
+{
+	return par->state->out;
+}
+
+static inline const char *xt_outname(const struct xt_action_param *par)
+{
+	return par->state->out->name;
+}
+
+static inline unsigned int xt_hooknum(const struct xt_action_param *par)
+{
+	return par->state->hook;
+}
+
+static inline u_int8_t xt_family(const struct xt_action_param *par)
+{
+	return par->state->pf;
+}
+
 /**
  * struct xt_mtchk_param - parameters for match extensions'
  * checkentry functions
diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 5031e072567b..44060344f958 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -30,11 +30,12 @@ static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
 				   const struct nf_hook_state *state)
 {
 	pkt->skb = skb;
-	pkt->net = pkt->xt.net = state->net;
-	pkt->in = pkt->xt.in = state->in;
-	pkt->out = pkt->xt.out = state->out;
-	pkt->hook = pkt->xt.hooknum = state->hook;
-	pkt->pf = pkt->xt.family = state->pf;
+	pkt->net = state->net;
+	pkt->in = state->in;
+	pkt->out = state->out;
+	pkt->hook = state->hook;
+	pkt->pf = state->pf;
+	pkt->xt.state = state;
 }
 
 static inline void nft_set_pktinfo_proto_unspec(struct nft_pktinfo *pkt,
diff --git a/net/bridge/netfilter/ebt_arpreply.c b/net/bridge/netfilter/ebt_arpreply.c
index 070cf134a22f..5929309beaa1 100644
--- a/net/bridge/netfilter/ebt_arpreply.c
+++ b/net/bridge/netfilter/ebt_arpreply.c
@@ -51,7 +51,8 @@ ebt_arpreply_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	if (diptr == NULL)
 		return EBT_DROP;
 
-	arp_send(ARPOP_REPLY, ETH_P_ARP, *siptr, (struct net_device *)par->in,
+	arp_send(ARPOP_REPLY, ETH_P_ARP, *siptr,
+		 (struct net_device *)xt_in(par),
 		 *diptr, shp, info->mac, shp);
 
 	return info->target;
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 9a11086ba6ff..e88bd4827ac1 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -179,7 +179,7 @@ ebt_log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_log_info *info = par->targinfo;
 	struct nf_loginfo li;
-	struct net *net = par->net;
+	struct net *net = xt_net(par);
 
 	li.type = NF_LOG_TYPE_LOG;
 	li.u.log.level = info->loglevel;
@@ -190,11 +190,12 @@ ebt_log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	 * nf_log_packet() with NFT_LOG_TYPE_LOG here. --Pablo
 	 */
 	if (info->bitmask & EBT_LOG_NFLOG)
-		nf_log_packet(net, NFPROTO_BRIDGE, par->hooknum, skb,
-			      par->in, par->out, &li, "%s", info->prefix);
+		nf_log_packet(net, NFPROTO_BRIDGE, xt_hooknum(par), skb,
+			      xt_in(par), xt_out(par), &li, "%s",
+			      info->prefix);
 	else
-		ebt_log_packet(net, NFPROTO_BRIDGE, par->hooknum, skb, par->in,
-			       par->out, &li, info->prefix);
+		ebt_log_packet(net, NFPROTO_BRIDGE, xt_hooknum(par), skb,
+			       xt_in(par), xt_out(par), &li, info->prefix);
 	return EBT_CONTINUE;
 }
 
diff --git a/net/bridge/netfilter/ebt_nflog.c b/net/bridge/netfilter/ebt_nflog.c
index 54816150608e..c1dc48686200 100644
--- a/net/bridge/netfilter/ebt_nflog.c
+++ b/net/bridge/netfilter/ebt_nflog.c
@@ -23,16 +23,16 @@ static unsigned int
 ebt_nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_nflog_info *info = par->targinfo;
+	struct net *net = xt_net(par);
 	struct nf_loginfo li;
-	struct net *net = par->net;
 
 	li.type = NF_LOG_TYPE_ULOG;
 	li.u.ulog.copy_len = info->len;
 	li.u.ulog.group = info->group;
 	li.u.ulog.qthreshold = info->threshold;
 
-	nf_log_packet(net, PF_BRIDGE, par->hooknum, skb, par->in,
-		      par->out, &li, "%s", info->prefix);
+	nf_log_packet(net, PF_BRIDGE, xt_hooknum(par), skb, xt_in(par),
+		      xt_out(par), &li, "%s", info->prefix);
 	return EBT_CONTINUE;
 }
 
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index 2e7c4f974340..8d2a85e0594e 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -23,12 +23,12 @@ ebt_redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	if (!skb_make_writable(skb, 0))
 		return EBT_DROP;
 
-	if (par->hooknum != NF_BR_BROUTING)
+	if (xt_hooknum(par) != NF_BR_BROUTING)
 		/* rcu_read_lock()ed by nf_hook_thresh */
 		ether_addr_copy(eth_hdr(skb)->h_dest,
-				br_port_get_rcu(par->in)->br->dev->dev_addr);
+				br_port_get_rcu(xt_in(par))->br->dev->dev_addr);
 	else
-		ether_addr_copy(eth_hdr(skb)->h_dest, par->in->dev_addr);
+		ether_addr_copy(eth_hdr(skb)->h_dest, xt_in(par)->dev_addr);
 	skb->pkt_type = PACKET_HOST;
 	return info->target;
 }
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index f5c11bbe27db..1ab6014cf0f8 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -194,12 +194,8 @@ unsigned int ebt_do_table(struct sk_buff *skb,
 	const struct ebt_table_info *private;
 	struct xt_action_param acpar;
 
-	acpar.family  = NFPROTO_BRIDGE;
-	acpar.net     = state->net;
-	acpar.in      = state->in;
-	acpar.out     = state->out;
+	acpar.state   = state;
 	acpar.hotdrop = false;
-	acpar.hooknum = hook;
 
 	read_lock_bh(&table->lock);
 	private = table->private;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index b31df597fd37..e76ab23a2deb 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -217,11 +217,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	 */
 	e = get_entry(table_base, private->hook_entry[hook]);
 
-	acpar.net     = state->net;
-	acpar.in      = state->in;
-	acpar.out     = state->out;
-	acpar.hooknum = hook;
-	acpar.family  = NFPROTO_ARP;
+	acpar.state   = state;
 	acpar.hotdrop = false;
 
 	arp = arp_hdr(skb);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 7c00ce90adb8..de4fa03f46f3 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -261,11 +261,7 @@ ipt_do_table(struct sk_buff *skb,
 	acpar.fragoff = ntohs(ip->frag_off) & IP_OFFSET;
 	acpar.thoff   = ip_hdrlen(skb);
 	acpar.hotdrop = false;
-	acpar.net     = state->net;
-	acpar.in      = state->in;
-	acpar.out     = state->out;
-	acpar.family  = NFPROTO_IPV4;
-	acpar.hooknum = hook;
+	acpar.state   = state;
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 	local_bh_disable();
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index da7f02a0b868..34cfb9b0bc0a 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -55,7 +55,8 @@ masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	range.min_proto = mr->range[0].min;
 	range.max_proto = mr->range[0].max;
 
-	return nf_nat_masquerade_ipv4(skb, par->hooknum, &range, par->out);
+	return nf_nat_masquerade_ipv4(skb, xt_hooknum(par), &range,
+				      xt_out(par));
 }
 
 static struct xt_target masquerade_tg_reg __read_mostly = {
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 1d16c0f28df0..8bd0d7b26632 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -34,7 +34,7 @@ static unsigned int
 reject_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ipt_reject_info *reject = par->targinfo;
-	int hook = par->hooknum;
+	int hook = xt_hooknum(par);
 
 	switch (reject->with) {
 	case IPT_ICMP_NET_UNREACHABLE:
@@ -59,7 +59,7 @@ reject_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		nf_send_unreach(skb, ICMP_PKT_FILTERED, hook);
 		break;
 	case IPT_TCP_RESET:
-		nf_send_reset(par->net, skb, hook);
+		nf_send_reset(xt_net(par), skb, hook);
 	case IPT_ICMP_ECHOREPLY:
 		/* Doesn't happen. */
 		break;
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index db5b87509446..361411688221 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -263,12 +263,12 @@ static unsigned int
 synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_synproxy_info *info = par->targinfo;
-	struct net *net = par->net;
+	struct net *net = xt_net(par);
 	struct synproxy_net *snet = synproxy_pernet(net);
 	struct synproxy_options opts = {};
 	struct tcphdr *th, _th;
 
-	if (nf_ip_checksum(skb, par->hooknum, par->thoff, IPPROTO_TCP))
+	if (nf_ip_checksum(skb, xt_hooknum(par), par->thoff, IPPROTO_TCP))
 		return NF_DROP;
 
 	th = skb_header_pointer(skb, par->thoff, sizeof(_th), &_th);
diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index 78cc64eddfc1..59b49945b481 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -95,7 +95,7 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	flow.flowi4_tos = RT_TOS(iph->tos);
 	flow.flowi4_scope = RT_SCOPE_UNIVERSE;
 
-	return rpfilter_lookup_reverse(par->net, &flow, par->in, info->flags) ^ invert;
+	return rpfilter_lookup_reverse(xt_net(par), &flow, xt_in(par), info->flags) ^ invert;
 }
 
 static int rpfilter_check(const struct xt_mtchk_param *par)
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 55aacea24396..7eac01d5d621 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -291,11 +291,7 @@ ip6t_do_table(struct sk_buff *skb,
 	 * rule is also a fragment-specific rule, non-fragments won't
 	 * match it. */
 	acpar.hotdrop = false;
-	acpar.net     = state->net;
-	acpar.in      = state->in;
-	acpar.out     = state->out;
-	acpar.family  = NFPROTO_IPV6;
-	acpar.hooknum = hook;
+	acpar.state   = state;
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 
diff --git a/net/ipv6/netfilter/ip6t_MASQUERADE.c b/net/ipv6/netfilter/ip6t_MASQUERADE.c
index 7f9f45d829d2..2b1a15846f9a 100644
--- a/net/ipv6/netfilter/ip6t_MASQUERADE.c
+++ b/net/ipv6/netfilter/ip6t_MASQUERADE.c
@@ -24,7 +24,7 @@
 static unsigned int
 masquerade_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	return nf_nat_masquerade_ipv6(skb, par->targinfo, par->out);
+	return nf_nat_masquerade_ipv6(skb, par->targinfo, xt_out(par));
 }
 
 static int masquerade_tg6_checkentry(const struct xt_tgchk_param *par)
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index db29bbf41b59..fa51a205918d 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -39,35 +39,40 @@ static unsigned int
 reject_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ip6t_reject_info *reject = par->targinfo;
-	struct net *net = par->net;
+	struct net *net = xt_net(par);
 
 	switch (reject->with) {
 	case IP6T_ICMP6_NO_ROUTE:
-		nf_send_unreach6(net, skb, ICMPV6_NOROUTE, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_NOROUTE, xt_hooknum(par));
 		break;
 	case IP6T_ICMP6_ADM_PROHIBITED:
-		nf_send_unreach6(net, skb, ICMPV6_ADM_PROHIBITED, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_ADM_PROHIBITED,
+				 xt_hooknum(par));
 		break;
 	case IP6T_ICMP6_NOT_NEIGHBOUR:
-		nf_send_unreach6(net, skb, ICMPV6_NOT_NEIGHBOUR, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_NOT_NEIGHBOUR,
+				 xt_hooknum(par));
 		break;
 	case IP6T_ICMP6_ADDR_UNREACH:
-		nf_send_unreach6(net, skb, ICMPV6_ADDR_UNREACH, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_ADDR_UNREACH,
+				 xt_hooknum(par));
 		break;
 	case IP6T_ICMP6_PORT_UNREACH:
-		nf_send_unreach6(net, skb, ICMPV6_PORT_UNREACH, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_PORT_UNREACH,
+				 xt_hooknum(par));
 		break;
 	case IP6T_ICMP6_ECHOREPLY:
 		/* Do nothing */
 		break;
 	case IP6T_TCP_RESET:
-		nf_send_reset6(net, skb, par->hooknum);
+		nf_send_reset6(net, skb, xt_hooknum(par));
 		break;
 	case IP6T_ICMP6_POLICY_FAIL:
-		nf_send_unreach6(net, skb, ICMPV6_POLICY_FAIL, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_POLICY_FAIL, xt_hooknum(par));
 		break;
 	case IP6T_ICMP6_REJECT_ROUTE:
-		nf_send_unreach6(net, skb, ICMPV6_REJECT_ROUTE, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_REJECT_ROUTE,
+				 xt_hooknum(par));
 		break;
 	}
 
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 06bed74cf5ee..99a1216287c8 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -277,12 +277,12 @@ static unsigned int
 synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_synproxy_info *info = par->targinfo;
-	struct net *net = par->net;
+	struct net *net = xt_net(par);
 	struct synproxy_net *snet = synproxy_pernet(net);
 	struct synproxy_options opts = {};
 	struct tcphdr *th, _th;
 
-	if (nf_ip6_checksum(skb, par->hooknum, par->thoff, IPPROTO_TCP))
+	if (nf_ip6_checksum(skb, xt_hooknum(par), par->thoff, IPPROTO_TCP))
 		return NF_DROP;
 
 	th = skb_header_pointer(skb, par->thoff, sizeof(_th), &_th);
diff --git a/net/ipv6/netfilter/ip6t_rpfilter.c b/net/ipv6/netfilter/ip6t_rpfilter.c
index 1ee1b25df096..d5263dc364a9 100644
--- a/net/ipv6/netfilter/ip6t_rpfilter.c
+++ b/net/ipv6/netfilter/ip6t_rpfilter.c
@@ -93,7 +93,8 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (unlikely(saddrtype == IPV6_ADDR_ANY))
 		return true ^ invert; /* not routable: forward path will drop it */
 
-	return rpfilter_lookup_reverse6(par->net, skb, par->in, info->flags) ^ invert;
+	return rpfilter_lookup_reverse6(xt_net(par), skb, xt_in(par),
+					info->flags) ^ invert;
 }
 
 static int rpfilter_check(const struct xt_mtchk_param *par)
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index a748b0c2c981..3f1b945a24d5 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -541,7 +541,7 @@ int
 ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 	    const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_rcu_get(par->net, index);
+	struct ip_set *set = ip_set_rcu_get(xt_net(par), index);
 	int ret = 0;
 
 	BUG_ON(!set);
@@ -579,7 +579,7 @@ int
 ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
 	   const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_rcu_get(par->net, index);
+	struct ip_set *set = ip_set_rcu_get(xt_net(par), index);
 	int ret;
 
 	BUG_ON(!set);
@@ -601,7 +601,7 @@ int
 ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
 	   const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_rcu_get(par->net, index);
+	struct ip_set *set = ip_set_rcu_get(xt_net(par), index);
 	int ret = 0;
 
 	BUG_ON(!set);
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index f0f688db6213..aa1a776613b9 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -170,7 +170,7 @@ hash_netiface4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip);
 	e.ip &= ip_set_netmask(e.cidr);
 
-#define IFACE(dir)	(par->dir ? par->dir->name : "")
+#define IFACE(dir)	(par->state->dir ? par->state->dir->name : "")
 #define SRCDIR		(opt->flags & IPSET_DIM_TWO_SRC)
 
 	if (opt->cmdflags & IPSET_FLAG_PHYSDEV) {
diff --git a/net/netfilter/xt_AUDIT.c b/net/netfilter/xt_AUDIT.c
index 4973cbddc446..19247a17e511 100644
--- a/net/netfilter/xt_AUDIT.c
+++ b/net/netfilter/xt_AUDIT.c
@@ -132,9 +132,9 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		goto errout;
 
 	audit_log_format(ab, "action=%hhu hook=%u len=%u inif=%s outif=%s",
-			 info->type, par->hooknum, skb->len,
-			 par->in ? par->in->name : "?",
-			 par->out ? par->out->name : "?");
+			 info->type, xt_hooknum(par), skb->len,
+			 xt_in(par) ? xt_inname(par) : "?",
+			 xt_out(par) ? xt_outname(par) : "?");
 
 	if (skb->mark)
 		audit_log_format(ab, " mark=%#x", skb->mark);
@@ -144,7 +144,7 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 				 eth_hdr(skb)->h_source, eth_hdr(skb)->h_dest,
 				 ntohs(eth_hdr(skb)->h_proto));
 
-		if (par->family == NFPROTO_BRIDGE) {
+		if (xt_family(par) == NFPROTO_BRIDGE) {
 			switch (eth_hdr(skb)->h_proto) {
 			case htons(ETH_P_IP):
 				audit_ip4(ab, skb);
@@ -157,7 +157,7 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		}
 	}
 
-	switch (par->family) {
+	switch (xt_family(par)) {
 	case NFPROTO_IPV4:
 		audit_ip4(ab, skb);
 		break;
diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index 1763ab82bcd7..c3b2017ebe41 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -32,15 +32,15 @@ static unsigned int
 log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_log_info *loginfo = par->targinfo;
+	struct net *net = xt_net(par);
 	struct nf_loginfo li;
-	struct net *net = par->net;
 
 	li.type = NF_LOG_TYPE_LOG;
 	li.u.log.level = loginfo->level;
 	li.u.log.logflags = loginfo->logflags;
 
-	nf_log_packet(net, par->family, par->hooknum, skb, par->in, par->out,
-		      &li, "%s", loginfo->prefix);
+	nf_log_packet(net, xt_family(par), xt_hooknum(par), skb, xt_in(par),
+		      xt_out(par), &li, "%s", loginfo->prefix);
 	return XT_CONTINUE;
 }
 
diff --git a/net/netfilter/xt_NETMAP.c b/net/netfilter/xt_NETMAP.c
index b253e07cb1c5..94d0b5411192 100644
--- a/net/netfilter/xt_NETMAP.c
+++ b/net/netfilter/xt_NETMAP.c
@@ -33,8 +33,8 @@ netmap_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 		netmask.ip6[i] = ~(range->min_addr.ip6[i] ^
 				   range->max_addr.ip6[i]);
 
-	if (par->hooknum == NF_INET_PRE_ROUTING ||
-	    par->hooknum == NF_INET_LOCAL_OUT)
+	if (xt_hooknum(par) == NF_INET_PRE_ROUTING ||
+	    xt_hooknum(par) == NF_INET_LOCAL_OUT)
 		new_addr.in6 = ipv6_hdr(skb)->daddr;
 	else
 		new_addr.in6 = ipv6_hdr(skb)->saddr;
@@ -51,7 +51,7 @@ netmap_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	newrange.min_proto	= range->min_proto;
 	newrange.max_proto	= range->max_proto;
 
-	return nf_nat_setup_info(ct, &newrange, HOOK2MANIP(par->hooknum));
+	return nf_nat_setup_info(ct, &newrange, HOOK2MANIP(xt_hooknum(par)));
 }
 
 static int netmap_tg6_checkentry(const struct xt_tgchk_param *par)
@@ -72,16 +72,16 @@ netmap_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
 	struct nf_nat_range newrange;
 
-	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
-		     par->hooknum == NF_INET_POST_ROUTING ||
-		     par->hooknum == NF_INET_LOCAL_OUT ||
-		     par->hooknum == NF_INET_LOCAL_IN);
+	NF_CT_ASSERT(xt_hooknum(par) == NF_INET_PRE_ROUTING ||
+		     xt_hooknum(par) == NF_INET_POST_ROUTING ||
+		     xt_hooknum(par) == NF_INET_LOCAL_OUT ||
+		     xt_hooknum(par) == NF_INET_LOCAL_IN);
 	ct = nf_ct_get(skb, &ctinfo);
 
 	netmask = ~(mr->range[0].min_ip ^ mr->range[0].max_ip);
 
-	if (par->hooknum == NF_INET_PRE_ROUTING ||
-	    par->hooknum == NF_INET_LOCAL_OUT)
+	if (xt_hooknum(par) == NF_INET_PRE_ROUTING ||
+	    xt_hooknum(par) == NF_INET_LOCAL_OUT)
 		new_ip = ip_hdr(skb)->daddr & ~netmask;
 	else
 		new_ip = ip_hdr(skb)->saddr & ~netmask;
@@ -96,7 +96,7 @@ netmap_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	newrange.max_proto   = mr->range[0].max;
 
 	/* Hand modified range to generic setup. */
-	return nf_nat_setup_info(ct, &newrange, HOOK2MANIP(par->hooknum));
+	return nf_nat_setup_info(ct, &newrange, HOOK2MANIP(xt_hooknum(par)));
 }
 
 static int netmap_tg4_check(const struct xt_tgchk_param *par)
diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index 8668a5c18dc3..c7f8958cea4a 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -25,8 +25,8 @@ static unsigned int
 nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_nflog_info *info = par->targinfo;
+	struct net *net = xt_net(par);
 	struct nf_loginfo li;
-	struct net *net = par->net;
 
 	li.type		     = NF_LOG_TYPE_ULOG;
 	li.u.ulog.copy_len   = info->len;
@@ -37,8 +37,8 @@ nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	if (info->flags & XT_NFLOG_F_COPY_LEN)
 		li.u.ulog.flags |= NF_LOG_F_COPY_LEN;
 
-	nfulnl_log_packet(net, par->family, par->hooknum, skb, par->in,
-			  par->out, &li, info->prefix);
+	nfulnl_log_packet(net, xt_family(par), xt_hooknum(par), skb,
+			  xt_in(par), xt_out(par), &li, info->prefix);
 	return XT_CONTINUE;
 }
 
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 8f1779ff7e30..a360b99a958a 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -43,7 +43,7 @@ nfqueue_tg_v1(struct sk_buff *skb, const struct xt_action_param *par)
 
 	if (info->queues_total > 1) {
 		queue = nfqueue_hash(skb, queue, info->queues_total,
-				     par->family, jhash_initval);
+				     xt_family(par), jhash_initval);
 	}
 	return NF_QUEUE_NR(queue);
 }
@@ -98,7 +98,7 @@ nfqueue_tg_v3(struct sk_buff *skb, const struct xt_action_param *par)
 			queue = info->queuenum + cpu % info->queues_total;
 		} else {
 			queue = nfqueue_hash(skb, queue, info->queues_total,
-					     par->family, jhash_initval);
+					     xt_family(par), jhash_initval);
 		}
 	}
 
diff --git a/net/netfilter/xt_REDIRECT.c b/net/netfilter/xt_REDIRECT.c
index 03f0b370e178..651dce65a30b 100644
--- a/net/netfilter/xt_REDIRECT.c
+++ b/net/netfilter/xt_REDIRECT.c
@@ -31,7 +31,7 @@
 static unsigned int
 redirect_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	return nf_nat_redirect_ipv6(skb, par->targinfo, par->hooknum);
+	return nf_nat_redirect_ipv6(skb, par->targinfo, xt_hooknum(par));
 }
 
 static int redirect_tg6_checkentry(const struct xt_tgchk_param *par)
@@ -62,7 +62,7 @@ static int redirect_tg4_check(const struct xt_tgchk_param *par)
 static unsigned int
 redirect_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	return nf_nat_redirect_ipv4(skb, par->targinfo, par->hooknum);
+	return nf_nat_redirect_ipv4(skb, par->targinfo, xt_hooknum(par));
 }
 
 static struct xt_target redirect_tg_reg[] __read_mostly = {
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 872db2d0e2a9..27241a767f17 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -108,7 +108,7 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 		return -1;
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
-		struct net *net = par->net;
+		struct net *net = xt_net(par);
 		unsigned int in_mtu = tcpmss_reverse_mtu(net, skb, family);
 		unsigned int min_mtu = min(dst_mtu(skb_dst(skb)), in_mtu);
 
@@ -172,7 +172,7 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	 * length IPv6 header of 60, ergo the default MSS value is 1220
 	 * Since no MSS was provided, we must use the default values
 	 */
-	if (par->family == NFPROTO_IPV4)
+	if (xt_family(par) == NFPROTO_IPV4)
 		newmss = min(newmss, (u16)536);
 	else
 		newmss = min(newmss, (u16)1220);
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 0471db4032c5..1c57ace75ae6 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -33,7 +33,7 @@ tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	const struct xt_tee_tginfo *info = par->targinfo;
 	int oif = info->priv ? info->priv->oif : 0;
 
-	nf_dup_ipv4(par->net, skb, par->hooknum, &info->gw.in, oif);
+	nf_dup_ipv4(xt_net(par), skb, xt_hooknum(par), &info->gw.in, oif);
 
 	return XT_CONTINUE;
 }
@@ -45,7 +45,7 @@ tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	const struct xt_tee_tginfo *info = par->targinfo;
 	int oif = info->priv ? info->priv->oif : 0;
 
-	nf_dup_ipv6(par->net, skb, par->hooknum, &info->gw.in6, oif);
+	nf_dup_ipv6(xt_net(par), skb, xt_hooknum(par), &info->gw.in6, oif);
 
 	return XT_CONTINUE;
 }
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 663c4c3c9072..dbd72cc40e42 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -364,7 +364,8 @@ tproxy_tg4_v0(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tproxy_target_info *tgi = par->targinfo;
 
-	return tproxy_tg4(par->net, skb, tgi->laddr, tgi->lport, tgi->mark_mask, tgi->mark_value);
+	return tproxy_tg4(xt_net(par), skb, tgi->laddr, tgi->lport,
+			  tgi->mark_mask, tgi->mark_value);
 }
 
 static unsigned int
@@ -372,7 +373,8 @@ tproxy_tg4_v1(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tproxy_target_info_v1 *tgi = par->targinfo;
 
-	return tproxy_tg4(par->net, skb, tgi->laddr.ip, tgi->lport, tgi->mark_mask, tgi->mark_value);
+	return tproxy_tg4(xt_net(par), skb, tgi->laddr.ip, tgi->lport,
+			  tgi->mark_mask, tgi->mark_value);
 }
 
 #ifdef XT_TPROXY_HAVE_IPV6
@@ -442,7 +444,7 @@ tproxy_handle_time_wait6(struct sk_buff *skb, int tproto, int thoff,
 		 * to a listener socket if there's one */
 		struct sock *sk2;
 
-		sk2 = nf_tproxy_get_sock_v6(par->net, skb, thoff, hp, tproto,
+		sk2 = nf_tproxy_get_sock_v6(xt_net(par), skb, thoff, hp, tproto,
 					    &iph->saddr,
 					    tproxy_laddr6(skb, &tgi->laddr.in6, &iph->daddr),
 					    hp->source,
@@ -485,10 +487,10 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 	 * addresses, this happens if the redirect already happened
 	 * and the current packet belongs to an already established
 	 * connection */
-	sk = nf_tproxy_get_sock_v6(par->net, skb, thoff, hp, tproto,
+	sk = nf_tproxy_get_sock_v6(xt_net(par), skb, thoff, hp, tproto,
 				   &iph->saddr, &iph->daddr,
 				   hp->source, hp->dest,
-				   par->in, NFT_LOOKUP_ESTABLISHED);
+				   xt_in(par), NFT_LOOKUP_ESTABLISHED);
 
 	laddr = tproxy_laddr6(skb, &tgi->laddr.in6, &iph->daddr);
 	lport = tgi->lport ? tgi->lport : hp->dest;
@@ -500,10 +502,10 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 	else if (!sk)
 		/* no there's no established connection, check if
 		 * there's a listener on the redirected addr/port */
-		sk = nf_tproxy_get_sock_v6(par->net, skb, thoff, hp,
+		sk = nf_tproxy_get_sock_v6(xt_net(par), skb, thoff, hp,
 					   tproto, &iph->saddr, laddr,
 					   hp->source, lport,
-					   par->in, NFT_LOOKUP_LISTENER);
+					   xt_in(par), NFT_LOOKUP_LISTENER);
 
 	/* NOTE: assign_sock consumes our sk reference */
 	if (sk && tproxy_sk_is_transparent(sk)) {
diff --git a/net/netfilter/xt_addrtype.c b/net/netfilter/xt_addrtype.c
index 11d6091991a4..e329dabde35f 100644
--- a/net/netfilter/xt_addrtype.c
+++ b/net/netfilter/xt_addrtype.c
@@ -125,7 +125,7 @@ static inline bool match_type(struct net *net, const struct net_device *dev,
 static bool
 addrtype_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct net *net = par->net;
+	struct net *net = xt_net(par);
 	const struct xt_addrtype_info *info = par->matchinfo;
 	const struct iphdr *iph = ip_hdr(skb);
 	bool ret = true;
@@ -143,19 +143,19 @@ addrtype_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
 static bool
 addrtype_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct net *net = par->net;
+	struct net *net = xt_net(par);
 	const struct xt_addrtype_info_v1 *info = par->matchinfo;
 	const struct iphdr *iph;
 	const struct net_device *dev = NULL;
 	bool ret = true;
 
 	if (info->flags & XT_ADDRTYPE_LIMIT_IFACE_IN)
-		dev = par->in;
+		dev = xt_in(par);
 	else if (info->flags & XT_ADDRTYPE_LIMIT_IFACE_OUT)
-		dev = par->out;
+		dev = xt_out(par);
 
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
-	if (par->family == NFPROTO_IPV6)
+	if (xt_family(par) == NFPROTO_IPV6)
 		return addrtype_mt6(net, dev, skb, info);
 #endif
 	iph = ip_hdr(skb);
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 96fa26b20b67..9a9884a39c0e 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -112,7 +112,7 @@ xt_cluster_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	 * know, matches should not alter packets, but we are doing this here
 	 * because we would need to add a PKTTYPE target for this sole purpose.
 	 */
-	if (!xt_cluster_is_multicast_addr(skb, par->family) &&
+	if (!xt_cluster_is_multicast_addr(skb, xt_family(par)) &&
 	    skb->pkt_type == PACKET_MULTICAST) {
 	    	pskb->pkt_type = PACKET_HOST;
 	}
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index b6dc322593a3..bb3845339efd 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -317,7 +317,7 @@ static int count_them(struct net *net,
 static bool
 connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct net *net = par->net;
+	struct net *net = xt_net(par);
 	const struct xt_connlimit_info *info = par->matchinfo;
 	union nf_inet_addr addr;
 	struct nf_conntrack_tuple tuple;
@@ -332,11 +332,11 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		tuple_ptr = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
 		zone = nf_ct_zone(ct);
 	} else if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),
-				      par->family, net, &tuple)) {
+				      xt_family(par), net, &tuple)) {
 		goto hotdrop;
 	}
 
-	if (par->family == NFPROTO_IPV6) {
+	if (xt_family(par) == NFPROTO_IPV6) {
 		const struct ipv6hdr *iph = ipv6_hdr(skb);
 		memcpy(&addr.ip6, (info->flags & XT_CONNLIMIT_DADDR) ?
 		       &iph->daddr : &iph->saddr, sizeof(addr.ip6));
@@ -347,7 +347,7 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 
 	connections = count_them(net, info->data, tuple_ptr, &addr,
-	                         &info->mask, par->family, zone);
+	                         &info->mask, xt_family(par), zone);
 	if (connections == 0)
 		/* kmalloc failed, drop it entirely */
 		goto hotdrop;
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index a3b8f697cfc5..2dea15ebc55b 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -200,22 +200,22 @@ conntrack_mt(const struct sk_buff *skb, struct xt_action_param *par,
 		return false;
 
 	if (info->match_flags & XT_CONNTRACK_ORIGSRC)
-		if (conntrack_mt_origsrc(ct, info, par->family) ^
+		if (conntrack_mt_origsrc(ct, info, xt_family(par)) ^
 		    !(info->invert_flags & XT_CONNTRACK_ORIGSRC))
 			return false;
 
 	if (info->match_flags & XT_CONNTRACK_ORIGDST)
-		if (conntrack_mt_origdst(ct, info, par->family) ^
+		if (conntrack_mt_origdst(ct, info, xt_family(par)) ^
 		    !(info->invert_flags & XT_CONNTRACK_ORIGDST))
 			return false;
 
 	if (info->match_flags & XT_CONNTRACK_REPLSRC)
-		if (conntrack_mt_replsrc(ct, info, par->family) ^
+		if (conntrack_mt_replsrc(ct, info, xt_family(par)) ^
 		    !(info->invert_flags & XT_CONNTRACK_REPLSRC))
 			return false;
 
 	if (info->match_flags & XT_CONNTRACK_REPLDST)
-		if (conntrack_mt_repldst(ct, info, par->family) ^
+		if (conntrack_mt_repldst(ct, info, xt_family(par)) ^
 		    !(info->invert_flags & XT_CONNTRACK_REPLDST))
 			return false;
 
diff --git a/net/netfilter/xt_devgroup.c b/net/netfilter/xt_devgroup.c
index d9202cdd25c9..96ebe1cdefec 100644
--- a/net/netfilter/xt_devgroup.c
+++ b/net/netfilter/xt_devgroup.c
@@ -24,12 +24,12 @@ static bool devgroup_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct xt_devgroup_info *info = par->matchinfo;
 
 	if (info->flags & XT_DEVGROUP_MATCH_SRC &&
-	    (((info->src_group ^ par->in->group) & info->src_mask ? 1 : 0) ^
+	    (((info->src_group ^ xt_in(par)->group) & info->src_mask ? 1 : 0) ^
 	     ((info->flags & XT_DEVGROUP_INVERT_SRC) ? 1 : 0)))
 		return false;
 
 	if (info->flags & XT_DEVGROUP_MATCH_DST &&
-	    (((info->dst_group ^ par->out->group) & info->dst_mask ? 1 : 0) ^
+	    (((info->dst_group ^ xt_out(par)->group) & info->dst_mask ? 1 : 0) ^
 	     ((info->flags & XT_DEVGROUP_INVERT_DST) ? 1 : 0)))
 		return false;
 
diff --git a/net/netfilter/xt_dscp.c b/net/netfilter/xt_dscp.c
index 64670fc5d0e1..236ac8008909 100644
--- a/net/netfilter/xt_dscp.c
+++ b/net/netfilter/xt_dscp.c
@@ -58,7 +58,7 @@ static bool tos_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_tos_match_info *info = par->matchinfo;
 
-	if (par->family == NFPROTO_IPV4)
+	if (xt_family(par) == NFPROTO_IPV4)
 		return ((ip_hdr(skb)->tos & info->tos_mask) ==
 		       info->tos_value) ^ !!info->invert;
 	else
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
index 71a9d95e0a81..0fdc89064488 100644
--- a/net/netfilter/xt_ipvs.c
+++ b/net/netfilter/xt_ipvs.c
@@ -48,9 +48,9 @@ static bool
 ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_ipvs_mtinfo *data = par->matchinfo;
-	struct netns_ipvs *ipvs = net_ipvs(par->net);
+	struct netns_ipvs *ipvs = net_ipvs(xt_net(par));
 	/* ipvs_mt_check ensures that family is only NFPROTO_IPV[46]. */
-	const u_int8_t family = par->family;
+	const u_int8_t family = xt_family(par);
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
diff --git a/net/netfilter/xt_nfacct.c b/net/netfilter/xt_nfacct.c
index cf327593852a..cc0518fe598e 100644
--- a/net/netfilter/xt_nfacct.c
+++ b/net/netfilter/xt_nfacct.c
@@ -26,7 +26,7 @@ static bool nfacct_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	nfnl_acct_update(skb, info->nfacct);
 
-	overquota = nfnl_acct_overquota(par->net, skb, info->nfacct);
+	overquota = nfnl_acct_overquota(xt_net(par), skb, info->nfacct);
 
 	return overquota == NFACCT_UNDERQUOTA ? false : true;
 }
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 2455b69b5810..c05fefcec238 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -201,7 +201,7 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 	unsigned char opts[MAX_IPOPTLEN];
 	const struct xt_osf_finger *kf;
 	const struct xt_osf_user_finger *f;
-	struct net *net = p->net;
+	struct net *net = xt_net(p);
 
 	if (!info)
 		return false;
@@ -326,8 +326,8 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 		fcount++;
 
 		if (info->flags & XT_OSF_LOG)
-			nf_log_packet(net, p->family, p->hooknum, skb,
-				      p->in, p->out, NULL,
+			nf_log_packet(net, xt_family(p), xt_hooknum(p), skb,
+				      xt_in(p), xt_out(p), NULL,
 				      "%s [%s:%s] : %pI4:%d -> %pI4:%d hops=%d\n",
 				      f->genre, f->version, f->subtype,
 				      &ip->saddr, ntohs(tcp->source),
@@ -341,8 +341,8 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 	rcu_read_unlock();
 
 	if (!fcount && (info->flags & XT_OSF_LOG))
-		nf_log_packet(net, p->family, p->hooknum, skb, p->in,
-			      p->out, NULL,
+		nf_log_packet(net, xt_family(p), xt_hooknum(p), skb, xt_in(p),
+			      xt_out(p), NULL,
 			"Remote OS is not known: %pI4:%u -> %pI4:%u\n",
 				&ip->saddr, ntohs(tcp->source),
 				&ip->daddr, ntohs(tcp->dest));
diff --git a/net/netfilter/xt_owner.c b/net/netfilter/xt_owner.c
index a20e731b5b6c..16477df45b3b 100644
--- a/net/netfilter/xt_owner.c
+++ b/net/netfilter/xt_owner.c
@@ -63,7 +63,7 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct xt_owner_match_info *info = par->matchinfo;
 	const struct file *filp;
 	struct sock *sk = skb_to_full_sk(skb);
-	struct net *net = par->net;
+	struct net *net = xt_net(par);
 
 	if (sk == NULL || sk->sk_socket == NULL)
 		return (info->match ^ info->invert) == 0;
diff --git a/net/netfilter/xt_pkttype.c b/net/netfilter/xt_pkttype.c
index 5b645cb598fc..57efb703ff18 100644
--- a/net/netfilter/xt_pkttype.c
+++ b/net/netfilter/xt_pkttype.c
@@ -30,10 +30,10 @@ pkttype_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	if (skb->pkt_type != PACKET_LOOPBACK)
 		type = skb->pkt_type;
-	else if (par->family == NFPROTO_IPV4 &&
+	else if (xt_family(par) == NFPROTO_IPV4 &&
 	    ipv4_is_multicast(ip_hdr(skb)->daddr))
 		type = PACKET_MULTICAST;
-	else if (par->family == NFPROTO_IPV6 &&
+	else if (xt_family(par) == NFPROTO_IPV6 &&
 	    ipv6_hdr(skb)->daddr.s6_addr[0] == 0xFF)
 		type = PACKET_MULTICAST;
 	else
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index f23e97bb42d7..2b4ab189bba7 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -116,9 +116,9 @@ policy_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	int ret;
 
 	if (info->flags & XT_POLICY_MATCH_IN)
-		ret = match_policy_in(skb, info, par->family);
+		ret = match_policy_in(skb, info, xt_family(par));
 	else
-		ret = match_policy_out(skb, info, par->family);
+		ret = match_policy_out(skb, info, xt_family(par));
 
 	if (ret < 0)
 		ret = info->flags & XT_POLICY_MATCH_NONE ? true : false;
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index e3b7a09b103e..bf250000e084 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -236,7 +236,7 @@ static void recent_table_flush(struct recent_table *t)
 static bool
 recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct net *net = par->net;
+	struct net *net = xt_net(par);
 	struct recent_net *recent_net = recent_pernet(net);
 	const struct xt_recent_mtinfo_v1 *info = par->matchinfo;
 	struct recent_table *t;
@@ -245,7 +245,7 @@ recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	u_int8_t ttl;
 	bool ret = info->invert;
 
-	if (par->family == NFPROTO_IPV4) {
+	if (xt_family(par) == NFPROTO_IPV4) {
 		const struct iphdr *iph = ip_hdr(skb);
 
 		if (info->side == XT_RECENT_DEST)
@@ -266,7 +266,7 @@ recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 
 	/* use TTL as seen before forwarding */
-	if (par->out != NULL && skb->sk == NULL)
+	if (xt_out(par) != NULL && skb->sk == NULL)
 		ttl++;
 
 	spin_lock_bh(&recent_lock);
@@ -274,12 +274,12 @@ recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	nf_inet_addr_mask(&addr, &addr_mask, &t->mask);
 
-	e = recent_entry_lookup(t, &addr_mask, par->family,
+	e = recent_entry_lookup(t, &addr_mask, xt_family(par),
 				(info->check_set & XT_RECENT_TTL) ? ttl : 0);
 	if (e == NULL) {
 		if (!(info->check_set & XT_RECENT_SET))
 			goto out;
-		e = recent_entry_init(t, &addr_mask, par->family, ttl);
+		e = recent_entry_init(t, &addr_mask, xt_family(par), ttl);
 		if (e == NULL)
 			par->hotdrop = true;
 		ret = !ret;
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 5669e5b453f4..1bfede7be418 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -55,7 +55,7 @@ set_match_v0(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_set_info_match_v0 *info = par->matchinfo;
 
-	ADT_OPT(opt, par->family, info->match_set.u.compat.dim,
+	ADT_OPT(opt, xt_family(par), info->match_set.u.compat.dim,
 		info->match_set.u.compat.flags, 0, UINT_MAX);
 
 	return match_set(info->match_set.index, skb, par, &opt,
@@ -118,7 +118,7 @@ set_match_v1(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_set_info_match_v1 *info = par->matchinfo;
 
-	ADT_OPT(opt, par->family, info->match_set.dim,
+	ADT_OPT(opt, xt_family(par), info->match_set.dim,
 		info->match_set.flags, 0, UINT_MAX);
 
 	if (opt.flags & IPSET_RETURN_NOMATCH)
@@ -184,7 +184,7 @@ set_match_v3(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct xt_set_info_match_v3 *info = par->matchinfo;
 	int ret;
 
-	ADT_OPT(opt, par->family, info->match_set.dim,
+	ADT_OPT(opt, xt_family(par), info->match_set.dim,
 		info->match_set.flags, info->flags, UINT_MAX);
 
 	if (info->packets.op != IPSET_COUNTER_NONE ||
@@ -231,7 +231,7 @@ set_match_v4(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct xt_set_info_match_v4 *info = par->matchinfo;
 	int ret;
 
-	ADT_OPT(opt, par->family, info->match_set.dim,
+	ADT_OPT(opt, xt_family(par), info->match_set.dim,
 		info->match_set.flags, info->flags, UINT_MAX);
 
 	if (info->packets.op != IPSET_COUNTER_NONE ||
@@ -259,9 +259,9 @@ set_target_v0(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_set_info_target_v0 *info = par->targinfo;
 
-	ADT_OPT(add_opt, par->family, info->add_set.u.compat.dim,
+	ADT_OPT(add_opt, xt_family(par), info->add_set.u.compat.dim,
 		info->add_set.u.compat.flags, 0, UINT_MAX);
-	ADT_OPT(del_opt, par->family, info->del_set.u.compat.dim,
+	ADT_OPT(del_opt, xt_family(par), info->del_set.u.compat.dim,
 		info->del_set.u.compat.flags, 0, UINT_MAX);
 
 	if (info->add_set.index != IPSET_INVALID_ID)
@@ -332,9 +332,9 @@ set_target_v1(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_set_info_target_v1 *info = par->targinfo;
 
-	ADT_OPT(add_opt, par->family, info->add_set.dim,
+	ADT_OPT(add_opt, xt_family(par), info->add_set.dim,
 		info->add_set.flags, 0, UINT_MAX);
-	ADT_OPT(del_opt, par->family, info->del_set.dim,
+	ADT_OPT(del_opt, xt_family(par), info->del_set.dim,
 		info->del_set.flags, 0, UINT_MAX);
 
 	if (info->add_set.index != IPSET_INVALID_ID)
@@ -401,9 +401,9 @@ set_target_v2(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_set_info_target_v2 *info = par->targinfo;
 
-	ADT_OPT(add_opt, par->family, info->add_set.dim,
+	ADT_OPT(add_opt, xt_family(par), info->add_set.dim,
 		info->add_set.flags, info->flags, info->timeout);
-	ADT_OPT(del_opt, par->family, info->del_set.dim,
+	ADT_OPT(del_opt, xt_family(par), info->del_set.dim,
 		info->del_set.flags, 0, UINT_MAX);
 
 	/* Normalize to fit into jiffies */
@@ -429,11 +429,11 @@ set_target_v3(struct sk_buff *skb, const struct xt_action_param *par)
 	const struct xt_set_info_target_v3 *info = par->targinfo;
 	int ret;
 
-	ADT_OPT(add_opt, par->family, info->add_set.dim,
+	ADT_OPT(add_opt, xt_family(par), info->add_set.dim,
 		info->add_set.flags, info->flags, info->timeout);
-	ADT_OPT(del_opt, par->family, info->del_set.dim,
+	ADT_OPT(del_opt, xt_family(par), info->del_set.dim,
 		info->del_set.flags, 0, UINT_MAX);
-	ADT_OPT(map_opt, par->family, info->map_set.dim,
+	ADT_OPT(map_opt, xt_family(par), info->map_set.dim,
 		info->map_set.flags, 0, UINT_MAX);
 
 	/* Normalize to fit into jiffies */
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 018c369c9f0d..2198914707f5 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -57,7 +57,7 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	struct sock *sk = skb->sk;
 
 	if (!sk)
-		sk = nf_sk_lookup_slow_v4(par->net, skb, par->in);
+		sk = nf_sk_lookup_slow_v4(xt_net(par), skb, xt_in(par));
 	if (sk) {
 		bool wildcard;
 		bool transparent = true;
@@ -114,7 +114,7 @@ socket_mt6_v1_v2_v3(const struct sk_buff *skb, struct xt_action_param *par)
 	struct sock *sk = skb->sk;
 
 	if (!sk)
-		sk = nf_sk_lookup_slow_v6(par->net, skb, par->in);
+		sk = nf_sk_lookup_slow_v6(xt_net(par), skb, xt_in(par));
 	if (sk) {
 		bool wildcard;
 		bool transparent = true;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 378c1c976058..ce7ea6c1c50d 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -213,6 +213,12 @@ static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 	int ret = 0, result = 0;
 	struct tcf_ipt *ipt = to_ipt(a);
 	struct xt_action_param par;
+	struct nf_hook_state state = {
+		.net	= dev_net(skb->dev),
+		.in	= skb->dev,
+		.hook	= ipt->tcfi_hook,
+		.pf	= NFPROTO_IPV4,
+	};
 
 	if (skb_unclone(skb, GFP_ATOMIC))
 		return TC_ACT_UNSPEC;
@@ -226,13 +232,9 @@ static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 	 * worry later - danger - this API seems to have changed
 	 * from earlier kernels
 	 */
-	par.net	     = dev_net(skb->dev);
-	par.in       = skb->dev;
-	par.out      = NULL;
-	par.hooknum  = ipt->tcfi_hook;
+	par.state    = &state;
 	par.target   = ipt->tcfi_t->u.kernel.target;
 	par.targinfo = ipt->tcfi_t->data;
-	par.family   = NFPROTO_IPV4;
 	ret = par.target->target(skb, &par);
 
 	switch (ret) {
diff --git a/net/sched/em_ipset.c b/net/sched/em_ipset.c
index c66ca9400ab4..c1b23e3060b8 100644
--- a/net/sched/em_ipset.c
+++ b/net/sched/em_ipset.c
@@ -57,17 +57,20 @@ static int em_ipset_match(struct sk_buff *skb, struct tcf_ematch *em,
 	struct xt_action_param acpar;
 	const struct xt_set_info *set = (const void *) em->data;
 	struct net_device *dev, *indev = NULL;
+	struct nf_hook_state state = {
+		.net	= em->net,
+	};
 	int ret, network_offset;
 
 	switch (tc_skb_protocol(skb)) {
 	case htons(ETH_P_IP):
-		acpar.family = NFPROTO_IPV4;
+		state.pf = NFPROTO_IPV4;
 		if (!pskb_network_may_pull(skb, sizeof(struct iphdr)))
 			return 0;
 		acpar.thoff = ip_hdrlen(skb);
 		break;
 	case htons(ETH_P_IPV6):
-		acpar.family = NFPROTO_IPV6;
+		state.pf = NFPROTO_IPV6;
 		if (!pskb_network_may_pull(skb, sizeof(struct ipv6hdr)))
 			return 0;
 		/* doesn't call ipv6_find_hdr() because ipset doesn't use thoff, yet */
@@ -77,9 +80,7 @@ static int em_ipset_match(struct sk_buff *skb, struct tcf_ematch *em,
 		return 0;
 	}
 
-	acpar.hooknum = 0;
-
-	opt.family = acpar.family;
+	opt.family = state.pf;
 	opt.dim = set->dim;
 	opt.flags = set->flags;
 	opt.cmdflags = 0;
@@ -95,9 +96,9 @@ static int em_ipset_match(struct sk_buff *skb, struct tcf_ematch *em,
 	if (skb->skb_iif)
 		indev = dev_get_by_index_rcu(em->net, skb->skb_iif);
 
-	acpar.net     = em->net;
-	acpar.in      = indev ? indev : dev;
-	acpar.out     = dev;
+	state.in      = indev ? indev : dev;
+	state.out     = dev;
+	acpar.state   = &state;
 
 	ret = ip_set_test(set->index, skb, &acpar, &opt);
 
-- 
2.1.4
