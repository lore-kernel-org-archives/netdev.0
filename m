From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 5/5] netfilter: add IPv6 SYNPROXY target
Date: Wed,  7 Aug 2013 19:42:51 +0200
Message-ID: <1375897371-18430-6-git-send-email-kaber@trash.net>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, jesper.brouer@gmail.com, as@one.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46905 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932126Ab3HGRnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 13:43:03 -0400
In-Reply-To: <1375897371-18430-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an IPv6 version of the SYNPROXY target. The main differences to the
IPv4 version is routing and IP header construction.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/Kconfig         |  13 ++
 net/ipv6/netfilter/Makefile        |   1 +
 net/ipv6/netfilter/ip6t_SYNPROXY.c | 451 +++++++++++++++++++++++++++++++++++++
 3 files changed, 465 insertions(+)
 create mode 100644 net/ipv6/netfilter/ip6t_SYNPROXY.c

diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 4433ab40..a7f842b 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -153,6 +153,19 @@ config IP6_NF_TARGET_REJECT
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP6_NF_TARGET_SYNPROXY
+	tristate "SYNPROXY target support"
+	depends on NF_CONNTRACK && NETFILTER_ADVANCED
+	select NETFILTER_SYNPROXY
+	select SYN_COOKIES
+	help
+	  The SYNPROXY target allows you to intercept TCP connections and
+	  establish them using syncookies before they are passed on to the
+	  server. This allows to avoid conntrack and server resource usage
+	  during SYN-flood attacks.
+
+	  To compile it as a module, choose M here. If unsure, say N.
+
 config IP6_NF_MANGLE
 	tristate "Packet mangling"
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 2d11fcc..58f031b 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -37,3 +37,4 @@ obj-$(CONFIG_IP6_NF_MATCH_RT) += ip6t_rt.o
 obj-$(CONFIG_IP6_NF_TARGET_MASQUERADE) += ip6t_MASQUERADE.o
 obj-$(CONFIG_IP6_NF_TARGET_NPT) += ip6t_NPT.o
 obj-$(CONFIG_IP6_NF_TARGET_REJECT) += ip6t_REJECT.o
+obj-$(CONFIG_IP6_NF_TARGET_SYNPROXY) += ip6t_SYNPROXY.o
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
new file mode 100644
index 0000000..ee773da
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -0,0 +1,451 @@
+/*
+ * Copyright (c) 2013 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/ip6_checksum.h>
+#include <net/ip6_route.h>
+#include <net/tcp.h>
+
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_SYNPROXY.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_seqadj.h>
+#include <net/netfilter/nf_conntrack_synproxy.h>
+
+static struct ipv6hdr *
+synproxy_build_ip(struct sk_buff *skb, const struct in6_addr *saddr,
+				       const struct in6_addr *daddr)
+{
+	struct ipv6hdr *iph;
+
+	skb_reset_network_header(skb);
+	iph = (struct ipv6hdr *)skb_put(skb, sizeof(*iph));
+	ip6_flow_hdr(iph, 0, 0);
+	iph->hop_limit	= 64;
+	iph->nexthdr	= IPPROTO_TCP;
+	iph->saddr	= *saddr;
+	iph->daddr	= *daddr;
+
+	return iph;
+}
+
+static void
+synproxy_send_tcp(const struct sk_buff *skb, struct sk_buff *nskb,
+		  struct nf_conntrack *nfct, enum ip_conntrack_info ctinfo,
+		  struct ipv6hdr *niph, struct tcphdr *nth,
+		  unsigned int tcp_hdr_size)
+{
+	struct net *net = nf_ct_net((struct nf_conn *)nfct);
+	struct dst_entry *dst;
+	struct flowi6 fl6;
+
+	nth->check = ~tcp_v6_check(tcp_hdr_size, &niph->saddr, &niph->daddr, 0);
+	nskb->ip_summed   = CHECKSUM_PARTIAL;
+	nskb->csum_start  = (unsigned char *)nth - nskb->head;
+	nskb->csum_offset = offsetof(struct tcphdr, check);
+
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_TCP;
+	fl6.saddr = niph->saddr;
+	fl6.daddr = niph->daddr;
+	fl6.fl6_sport = nth->source;
+	fl6.fl6_dport = nth->dest;
+	security_skb_classify_flow((struct sk_buff *)skb, flowi6_to_flowi(&fl6));
+	dst = ip6_route_output(net, NULL, &fl6);
+	if (dst == NULL || dst->error) {
+		dst_release(dst);
+		goto free_nskb;
+	}
+	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
+	if (IS_ERR(dst))
+		goto free_nskb;
+
+	skb_dst_set(nskb, dst);
+
+	nskb->nfct = nfct;
+	nskb->nfctinfo = ctinfo;
+	nf_conntrack_get(nfct);
+
+	ip6_local_out(nskb);
+	return;
+
+free_nskb:
+	kfree_skb(nskb);
+}
+
+static void
+synproxy_send_client_synack(const struct sk_buff *skb, const struct tcphdr *th,
+			    const struct synproxy_options *opts)
+{
+	struct sk_buff *nskb;
+	struct ipv6hdr *iph, *niph;
+	struct tcphdr *nth;
+	unsigned int tcp_hdr_size;
+	u16 mss = opts->mss;
+
+	iph = ipv6_hdr(skb);
+
+	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
+	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + LL_MAX_HEADER,
+			 GFP_ATOMIC);
+	if (nskb == NULL)
+		return;
+	skb_reserve(nskb, LL_MAX_HEADER);
+
+	niph = synproxy_build_ip(nskb, &iph->daddr, &iph->saddr);
+
+	skb_reset_transport_header(nskb);
+	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth->source	= th->dest;
+	nth->dest	= th->source;
+	nth->seq	= htonl(__cookie_v6_init_sequence(iph, th, &mss));
+	nth->ack_seq	= htonl(ntohl(th->seq) + 1);
+	tcp_flag_word(nth) = TCP_FLAG_SYN | TCP_FLAG_ACK;
+	if (opts->options & XT_SYNPROXY_OPT_ECN)
+		tcp_flag_word(nth) |= TCP_FLAG_ECE;
+	nth->doff	= tcp_hdr_size / 4;
+	nth->window	= 0;
+	nth->check	= 0;
+	nth->urg_ptr	= 0;
+
+	synproxy_build_options(nth, opts);
+
+	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+			  niph, nth, tcp_hdr_size);
+}
+
+static void
+synproxy_send_server_syn(const struct synproxy_net *snet,
+			 const struct sk_buff *skb, const struct tcphdr *th,
+			 const struct synproxy_options *opts)
+{
+	struct sk_buff *nskb;
+	struct ipv6hdr *iph, *niph;
+	struct tcphdr *nth;
+	unsigned int tcp_hdr_size;
+
+	iph = ipv6_hdr(skb);
+
+	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
+	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + LL_MAX_HEADER,
+			 GFP_ATOMIC);
+	if (nskb == NULL)
+		return;
+	skb_reserve(nskb, LL_MAX_HEADER);
+
+	niph = synproxy_build_ip(nskb, &iph->saddr, &iph->daddr);
+
+	skb_reset_transport_header(nskb);
+	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth->source	= th->source;
+	nth->dest	= th->dest;
+	nth->seq	= htonl(ntohl(th->seq) - 1);
+	nth->ack_seq	= htonl(ntohl(th->ack_seq) - 1);;
+	tcp_flag_word(nth) = TCP_FLAG_SYN;
+	if (opts->options & XT_SYNPROXY_OPT_ECN)
+		tcp_flag_word(nth) |= TCP_FLAG_ECE | TCP_FLAG_CWR;
+	nth->doff	= tcp_hdr_size / 4;
+	nth->window	= th->window;
+	nth->check	= 0;
+	nth->urg_ptr	= 0;
+
+	synproxy_build_options(nth, opts);
+
+	synproxy_send_tcp(skb, nskb, &snet->tmpl->ct_general, IP_CT_NEW,
+			  niph, nth, tcp_hdr_size);
+}
+
+static void
+synproxy_send_server_ack(const struct synproxy_net *snet,
+			 const struct ip_ct_tcp *state,
+			 const struct sk_buff *skb, const struct tcphdr *th,
+			 const struct synproxy_options *opts)
+{
+	struct sk_buff *nskb;
+	struct ipv6hdr *iph, *niph;
+	struct tcphdr *nth;
+	unsigned int tcp_hdr_size;
+
+	iph = ipv6_hdr(skb);
+
+	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
+	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + LL_MAX_HEADER,
+			 GFP_ATOMIC);
+	if (nskb == NULL)
+		return;
+	skb_reserve(nskb, LL_MAX_HEADER);
+
+	niph = synproxy_build_ip(nskb, &iph->daddr, &iph->saddr);
+
+	skb_reset_transport_header(nskb);
+	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth->source	= th->dest;
+	nth->dest	= th->source;
+	nth->seq	= htonl(ntohl(th->ack_seq));
+	nth->ack_seq	= htonl(ntohl(th->seq) + 1);;
+	tcp_flag_word(nth) = TCP_FLAG_ACK;
+	nth->doff	= tcp_hdr_size / 4;
+	nth->window	= htons(state->seen[IP_CT_DIR_ORIGINAL].td_maxwin);
+	nth->check	= 0;
+	nth->urg_ptr	= 0;
+
+	synproxy_build_options(nth, opts);
+
+	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED,
+			  niph, nth, tcp_hdr_size);
+}
+
+static void
+synproxy_send_client_ack(const struct synproxy_net *snet,
+			 const struct sk_buff *skb, const struct tcphdr *th,
+			 const struct synproxy_options *opts)
+{
+	struct sk_buff *nskb;
+	struct ipv6hdr *iph, *niph;
+	struct tcphdr *nth;
+	unsigned int tcp_hdr_size;
+
+	iph = ipv6_hdr(skb);
+
+	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
+	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + LL_MAX_HEADER,
+			 GFP_ATOMIC);
+	if (nskb == NULL)
+		return;
+	skb_reserve(nskb, LL_MAX_HEADER);
+
+	niph = synproxy_build_ip(nskb, &iph->saddr, &iph->daddr);
+
+	skb_reset_transport_header(nskb);
+	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth->source	= th->source;
+	nth->dest	= th->dest;
+	nth->seq	= htonl(ntohl(th->seq) + 1);
+	nth->ack_seq	= th->ack_seq;
+	tcp_flag_word(nth) = TCP_FLAG_ACK;
+	nth->doff	= tcp_hdr_size / 4;
+	nth->window	= th->window;
+	nth->check	= 0;
+	nth->urg_ptr	= 0;
+
+	synproxy_build_options(nth, opts);
+
+	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+			  niph, nth, tcp_hdr_size);
+}
+
+static unsigned int
+synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_synproxy_info *info = par->targinfo;
+	struct synproxy_net *snet = synproxy_pernet(dev_net(par->in));
+	struct synproxy_options opts = {};
+	struct tcphdr *th, _th;
+
+	if (nf_ip6_checksum(skb, par->hooknum, par->thoff, IPPROTO_TCP))
+		return NF_DROP;
+
+	th = skb_header_pointer(skb, par->thoff, sizeof(_th), &_th);
+	if (th == NULL)
+		return NF_DROP;
+
+	synproxy_parse_options(skb, par->thoff, th, &opts);
+
+	if (th->syn) {
+		/* Initial SYN from client */
+		this_cpu_inc(snet->stats->syn_received);
+
+		if (th->ece && th->cwr)
+			opts.options |= XT_SYNPROXY_OPT_ECN;
+
+		opts.options &= info->options;
+		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
+			synproxy_init_timestamp_cookie(info, &opts);
+		else
+			opts.options &= ~(XT_SYNPROXY_OPT_WSCALE |
+					  XT_SYNPROXY_OPT_SACK_PERM |
+					  XT_SYNPROXY_OPT_ECN);
+
+		synproxy_send_client_synack(skb, th, &opts);
+	} else if (th->ack && !(th->fin || th->rst)) {
+		/* ACK from client */
+		int mss = __cookie_v6_check(ipv6_hdr(skb), th,
+					    ntohl(th->ack_seq) - 1);
+		if (mss == 0) {
+			this_cpu_inc(snet->stats->cookie_invalid);
+			return NF_DROP;
+		}
+
+		this_cpu_inc(snet->stats->cookie_valid);
+		opts.mss = mss;
+
+		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
+			synproxy_check_timestamp_cookie(&opts);
+
+		synproxy_send_server_syn(snet, skb, th, &opts);
+	}
+
+	return NF_DROP;
+}
+
+static unsigned int ipv6_synproxy_hook(unsigned int hooknum,
+				       struct sk_buff *skb,
+				       const struct net_device *in,
+				       const struct net_device *out,
+				       int (*okfn)(struct sk_buff *))
+{
+	struct synproxy_net *snet = synproxy_pernet(dev_net(in ? : out));
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+	struct nf_conn_synproxy *synproxy;
+	struct synproxy_options opts = {};
+	const struct ip_ct_tcp *state;
+	struct tcphdr *th, _th;
+	__be16 frag_off;
+	u8 nexthdr;
+	int thoff;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct == NULL)
+		return NF_ACCEPT;
+
+	synproxy = nfct_synproxy(ct);
+	if (synproxy == NULL)
+		return NF_ACCEPT;
+
+	if (nf_is_loopback_packet(skb))
+		return NF_ACCEPT;
+
+	nexthdr = ipv6_hdr(skb)->nexthdr;
+	thoff = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr), &nexthdr,
+				 &frag_off);
+	if (thoff < 0)
+		return NF_ACCEPT;
+
+	th = skb_header_pointer(skb, thoff, sizeof(_th), &_th);
+	if (th == NULL)
+		return NF_DROP;
+
+	state = &ct->proto.tcp;
+	switch (state->state) {
+	case TCP_CONNTRACK_SYN_SENT:
+		synproxy_parse_options(skb, thoff, th, &opts);
+
+		synproxy->isn = ntohl(th->ack_seq);
+		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
+			synproxy->tsoff = -opts.tsecr;
+		break;
+	case TCP_CONNTRACK_SYN_RECV:
+		if (!th->syn)
+			break;
+
+		synproxy_parse_options(skb, thoff, th, &opts);
+		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
+			synproxy->tsoff += opts.tsval;
+
+		opts.options &= ~(XT_SYNPROXY_OPT_MSS |
+				  XT_SYNPROXY_OPT_WSCALE |
+				  XT_SYNPROXY_OPT_SACK_PERM);
+
+		swap(opts.tsval, opts.tsecr);
+		synproxy_send_server_ack(snet, state, skb, th, &opts);
+
+		nf_ct_seqadj_init(ct, ctinfo, synproxy->isn - ntohl(th->seq));
+
+		swap(opts.tsval, opts.tsecr);
+		synproxy_send_client_ack(snet, skb, th, &opts);
+
+		kfree_skb(skb);
+		return NF_STOLEN;
+	case TCP_CONNTRACK_CLOSE:
+		if (!th->rst)
+			break;
+
+		nf_ct_seqadj_init(ct, ctinfo, synproxy->isn -
+					      ntohl(th->seq) + 1);
+		break;
+	default:
+		break;
+	}
+
+	synproxy_tstamp_adjust(skb, thoff, th, ct, ctinfo, synproxy);
+	return NF_ACCEPT;
+}
+
+static int synproxy_tg6_check(const struct xt_tgchk_param *par)
+{
+	/// XXX PROTO match TCP
+	return nf_ct_l3proto_try_module_get(par->family);
+}
+
+static void synproxy_tg6_destroy(const struct xt_tgdtor_param *par)
+{
+	nf_ct_l3proto_module_put(par->family);
+}
+
+static struct xt_target synproxy_tg6_reg __read_mostly = {
+	.name		= "SYNPROXY",
+	.family		= NFPROTO_IPV6,
+	.target		= synproxy_tg6,
+	.targetsize	= sizeof(struct xt_synproxy_info),
+	.checkentry	= synproxy_tg6_check,
+	.destroy	= synproxy_tg6_destroy,
+	.me		= THIS_MODULE,
+};
+
+static struct nf_hook_ops ipv6_synproxy_ops[] __read_mostly = {
+	{
+		.hook		= ipv6_synproxy_hook,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_LOCAL_IN,
+		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
+	},
+	{
+		.hook		= ipv6_synproxy_hook,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_POST_ROUTING,
+		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
+	},
+};
+
+static int __init synproxy_tg6_init(void)
+{
+	int err;
+
+	err = nf_register_hooks(ipv6_synproxy_ops,
+				ARRAY_SIZE(ipv6_synproxy_ops));
+	if (err < 0)
+		goto err1;
+
+	err = xt_register_target(&synproxy_tg6_reg);
+	if (err < 0)
+		goto err2;
+
+	return 0;
+
+err2:
+	nf_unregister_hooks(ipv6_synproxy_ops, ARRAY_SIZE(ipv6_synproxy_ops));
+err1:
+	return err;
+}
+
+static void __exit synproxy_tg6_exit(void)
+{
+	xt_unregister_target(&synproxy_tg6_reg);
+	nf_unregister_hooks(ipv6_synproxy_ops, ARRAY_SIZE(ipv6_synproxy_ops));
+}
+
+module_init(synproxy_tg6_init);
+module_exit(synproxy_tg6_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-- 
1.8.1.4
