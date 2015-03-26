From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Thu, 26 Mar 2015 15:23:56 +0100
Message-ID: <1427379836.29436.9.camel@stressinduktion.org>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	tgraf@suug.ch, jesse@nicira.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:54431 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752511AbbCZOX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 10:23:59 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id AC91E2085C
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 10:23:55 -0400 (EDT)
In-Reply-To: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2015-03-26 at 13:53 +0100, Jiri Pirko wrote:
> This patch introduces OpenFlow-based filter. So far, the very essential
> packet fields are supported (according to OpenFlow v1.4 spec).
> 
> This patch is only the first step. There is a lot of potential performance
> improvements possible to implement. Also a lot of features are missing
> now. They will be addressed in follow-up patches.
> 
> To the name of this classifier, I believe that "cls_openflow" is pretty
> accurate. It is actually a OpenFlow classifier.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/uapi/linux/pkt_cls.h |  31 ++
>  net/sched/Kconfig            |  11 +
>  net/sched/Makefile           |   1 +
>  net/sched/cls_openflow.c     | 681 +++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 724 insertions(+)
>  create mode 100644 net/sched/cls_openflow.c
> 
> diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
> index bf08e76..910898c 100644
> --- a/include/uapi/linux/pkt_cls.h
> +++ b/include/uapi/linux/pkt_cls.h
> @@ -404,6 +404,37 @@ enum {
>  
>  #define TCA_BPF_MAX (__TCA_BPF_MAX - 1)
>  
> +/* OpenFlow classifier */
> +
> +enum {
> +	TCA_OF_UNSPEC,
> +	TCA_OF_CLASSID,
> +	TCA_OF_POLICE,
> +	TCA_OF_INDEV,
> +	TCA_OF_ACT,
> +	TCA_OF_KEY_ETH_DST,		/* ETH_ALEN */
> +	TCA_OF_KEY_ETH_DST_MASK,	/* ETH_ALEN */
> +	TCA_OF_KEY_ETH_SRC,		/* ETH_ALEN */
> +	TCA_OF_KEY_ETH_SRC_MASK,	/* ETH_ALEN */
> +	TCA_OF_KEY_ETH_TYPE,		/* be16 */
> +	TCA_OF_KEY_IP_PROTO,		/* u8 */
> +	TCA_OF_KEY_IPV4_SRC,		/* be32 */
> +	TCA_OF_KEY_IPV4_SRC_MASK,	/* be32 */
> +	TCA_OF_KEY_IPV4_DST,		/* be32 */
> +	TCA_OF_KEY_IPV4_DST_MASK,	/* be32 */
> +	TCA_OF_KEY_IPV6_SRC,		/* struct in6_addr */
> +	TCA_OF_KEY_IPV6_SRC_MASK,	/* struct in6_addr */
> +	TCA_OF_KEY_IPV6_DST,		/* struct in6_addr */
> +	TCA_OF_KEY_IPV6_DST_MASK,	/* struct in6_addr */
> +	TCA_OF_KEY_TCP_SRC,		/* be16 */
> +	TCA_OF_KEY_TCP_DST,		/* be16 */
> +	TCA_OF_KEY_UDP_SRC,		/* be16 */
> +	TCA_OF_KEY_UDP_DST,		/* be16 */
> +	__TCA_OF_MAX,
> +};
> +
> +#define TCA_OF_MAX (__TCA_OF_MAX - 1)
> +
>  /* Extended Matches */
>  
>  struct tcf_ematch_tree_hdr {
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 2274e72..32d1a7b 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -477,6 +477,17 @@ config NET_CLS_BPF
>  	  To compile this code as a module, choose M here: the module will
>  	  be called cls_bpf.
>  
> +config NET_CLS_OPENFLOW
> +	tristate "OpenFlow classifier"
> +	select NET_CLS
> +	---help---
> +	  If you say Y here, you will be able to classify packets based on
> +	  a configurable combination of packet keys and masks according to
> +	  OpenFlow standard.
> +
> +	  To compile this code as a module, choose M here: the module will
> +	  be called cls_openflow.
> +
>  config NET_EMATCH
>  	bool "Extended Matches"
>  	select NET_CLS
> diff --git a/net/sched/Makefile b/net/sched/Makefile
> index 7ca7f4c..5faa9ca 100644
> --- a/net/sched/Makefile
> +++ b/net/sched/Makefile
> @@ -56,6 +56,7 @@ obj-$(CONFIG_NET_CLS_BASIC)	+= cls_basic.o
>  obj-$(CONFIG_NET_CLS_FLOW)	+= cls_flow.o
>  obj-$(CONFIG_NET_CLS_CGROUP)	+= cls_cgroup.o
>  obj-$(CONFIG_NET_CLS_BPF)	+= cls_bpf.o
> +obj-$(CONFIG_NET_CLS_OPENFLOW)	+= cls_openflow.o
>  obj-$(CONFIG_NET_EMATCH)	+= ematch.o
>  obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
>  obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
> diff --git a/net/sched/cls_openflow.c b/net/sched/cls_openflow.c
> new file mode 100644
> index 0000000..b59311f
> --- /dev/null
> +++ b/net/sched/cls_openflow.c
> @@ -0,0 +1,681 @@
> +/*
> + * net/sched/cls_openflow.c		OpenFlow classifier
> + *
> + * Copyright (c) 2015 Jiri Pirko <jiri@resnulli.us>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/init.h>
> +#include <linux/module.h>
> +
> +#include <linux/if_ether.h>
> +#include <linux/in6.h>
> +#include <linux/ip.h>
> +
> +#include <net/sch_generic.h>
> +#include <net/pkt_cls.h>
> +#include <net/ip.h>
> +
> +struct of_flow_key {
> +	int	indev_ifindex;
> +	struct {
> +		u8	src[ETH_ALEN];
> +		u8	dst[ETH_ALEN];
> +		__be16	type;
> +	} eth;
> +	struct {
> +		u8	proto;
> +	} ip;
> +	union {
> +		struct {
> +			__be32 src;
> +			__be32 dst;
> +		} ipv4;
> +		struct {
> +			struct in6_addr src;
> +			struct in6_addr dst;
> +		} ipv6;
> +	};
> +	union {
> +		struct {
> +			__be16 src;
> +			__be16 dst;
> +		} tp;
> +	};
         __u8 end[0];
         u8 pad[DIV_ROUND_UP(offsetof(strut ..., __end), sizeof(long)];
> +} __aligned(BITS_PER_LONG / 8); /* Ensure that we can do comparisons as longs. */

BITS_PER_LONG / 8 == sizeof(long)

> +
> +struct of_flow_match {
> +	struct of_flow_key key;
> +	struct of_flow_key mask;
> +};
> +
> +struct cls_of_head {
> +	struct list_head filters;
> +	u32 hgen;
> +	struct rcu_head rcu;
> +};
> +
> +struct cls_of_filter {
> +	struct list_head list;
> +	u32 handle;
> +	struct tcf_exts exts;
> +	struct tcf_result res;
> +	struct tcf_proto *tp;
> +	struct of_flow_match match;
> +	struct rcu_head	rcu;
> +};
> +
> +static int __check_header(struct sk_buff *skb, int len)
> +{
> +	if (unlikely(skb->len < len))
> +		return -EINVAL;
> +	if (unlikely(!pskb_may_pull(skb, len)))
> +		return -ENOMEM;
> +	return 0;
> +}
> +
> +static int of_extract_ipv4(struct sk_buff *skb, struct of_flow_key *key)
> +{
> +	unsigned int iph_off = skb_network_offset(skb);
> +	struct iphdr *iph;
> +	unsigned int iph_len;
> +	int err;
> +
> +	err = __check_header(skb, iph_off + sizeof(*iph));
> +	if (unlikely(err))
> +		goto errout;
> +
> +	iph_len = ip_hdrlen(skb);
> +	if (unlikely(iph_len < sizeof(*iph) ||
> +		     skb->len < iph_off + iph_len)) {
> +		err = -EINVAL;
> +		goto errout;
> +	}
> +
> +	iph = ip_hdr(skb);
> +	key->ipv4.src = iph->saddr;
> +	key->ipv4.dst = iph->daddr;
> +	key->ip.proto = iph->protocol;
> +
> +	skb_set_transport_header(skb, iph_off + iph_len);
> +	return 0;
> +
> +errout:
> +	memset(&key->ip, 0, sizeof(key->ip));
> +	memset(&key->ipv4, 0, sizeof(key->ipv4));
> +	return err;
> +}
> +
> +static int of_extract_ipv6(struct sk_buff *skb, struct of_flow_key *key)
> +{
> +	unsigned int iph_off = skb_network_offset(skb);
> +	int payload_off;
> +	struct ipv6hdr *iph;
> +	uint8_t nexthdr;
> +	__be16 frag_off;
> +	int err;
> +
> +	err = __check_header(skb, iph_off + sizeof(*iph));
> +	if (unlikely(err))
> +		goto errout;
> +
> +	iph = ipv6_hdr(skb);
> +	nexthdr = iph->nexthdr;
> +	payload_off = (u8 *) (iph + 1) - skb->data;
> +
> +	key->ip.proto = NEXTHDR_NONE;
> +	key->ipv6.src = iph->saddr;
> +	key->ipv6.dst = iph->daddr;
> +
> +	payload_off = ipv6_skip_exthdr(skb, payload_off, &nexthdr, &frag_off);
> +	if (unlikely(payload_off < 0)) {
> +		err = -EINVAL;
> +		goto errout;
> +	}
> +
> +	key->ip.proto = nexthdr;
> +	skb_set_transport_header(skb, payload_off);
> +	return 0;
> +
> +errout:
> +	memset(&key->ip, 0, sizeof(key->ip));
> +	memset(&key->ipv6, 0, sizeof(key->ipv6));
> +	return err;
> +}
> +
> +static bool __tcphdr_ok(struct sk_buff *skb)
> +{
> +	int tcph_off = skb_transport_offset(skb);
> +	int tcph_len;
> +
> +	if (unlikely(!pskb_may_pull(skb, tcph_off + sizeof(struct tcphdr))))
> +		return false;
> +
> +	tcph_len = tcp_hdrlen(skb);
> +	if (unlikely(tcph_len < sizeof(struct tcphdr) ||
> +		     skb->len < tcph_off + tcph_len))
> +		return false;
> +
> +	return true;
> +}
> +
> +static bool __udphdr_ok(struct sk_buff *skb)
> +{
> +	return pskb_may_pull(skb, skb_transport_offset(skb) +
> +				  sizeof(struct udphdr));
> +}
> +
> +static void of_extract_tp(struct sk_buff *skb, struct of_flow_key *key)
> +{
> +	if (key->ip.proto == IPPROTO_TCP) {
> +		if (__tcphdr_ok(skb)) {
> +			struct tcphdr *tcp = tcp_hdr(skb);
> +
> +			key->tp.src = tcp->source;
> +			key->tp.dst = tcp->dest;
> +		} else {
> +			memset(&key->tp, 0, sizeof(key->tp));
> +		}
> +
> +	} else if (key->ip.proto == IPPROTO_UDP) {
> +		if (__udphdr_ok(skb)) {
> +			struct udphdr *udp = udp_hdr(skb);
> +
> +			key->tp.src = udp->source;
> +			key->tp.dst = udp->dest;
> +		} else {
> +			memset(&key->tp, 0, sizeof(key->tp));
> +		}
> +	}
> +}
> +
> +static void of_extract_key(struct sk_buff *skb, struct of_flow_key *key)
> +{
> +	struct ethhdr *eth;
> +	int err;
> +
> +	key->indev_ifindex = skb->skb_iif;
> +
> +	eth = eth_hdr(skb);
> +	ether_addr_copy(key->eth.src, eth->h_source);
> +	ether_addr_copy(key->eth.dst, eth->h_dest);
> +
> +	key->eth.type = skb->protocol;
> +	if (key->eth.type == htons(ETH_P_IP)) {
> +		err = of_extract_ipv4(skb, key);
> +		if (likely(!err))
> +			of_extract_tp(skb, key);
> +	} else if (key->eth.type == htons(ETH_P_IPV6)) {
> +		err = of_extract_ipv6(skb, key);
> +		if (likely(!err))
> +			of_extract_tp(skb, key);
> +	}
> +}
> +
> +static bool of_match(struct of_flow_key *skb_key, struct cls_of_filter *f)
> +{
> +	const long *lkey = (const long *) &f->match.key;
> +	const long *lmask = (const long *) &f->match.mask;
> +	const long *lskb_key = (const long *) skb_key;
> +	int i;
> +
> +	for (i = 0; i < sizeof(struct of_flow_key); i += sizeof(const long)) {
> +		if ((*lkey++ & *lmask) != (*lskb_key++ & *lmask))
> +			return false;
> +		lmask++;
> +	}
> +	return true;
> +}
> +
> +static int of_classify(struct sk_buff *skb, const struct tcf_proto *tp,
> +		       struct tcf_result *res)
> +{
> +	struct cls_of_head *head = rcu_dereference_bh(tp->root);
> +	struct cls_of_filter *f;
> +	struct of_flow_key skb_key;
> +	int ret;
> +
> +	of_extract_key(skb, &skb_key);
> +
> +	list_for_each_entry_rcu(f, &head->filters, list) {
> +		if (!of_match(&skb_key, f))
> +			continue;

This seems very limited to me, do you have plans to extend this?

Bye,
Hannes
