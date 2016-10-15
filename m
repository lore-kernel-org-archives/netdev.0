From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 4/6] Introduce sample tc action
Date: Sat, 15 Oct 2016 09:34:24 -0700
Message-ID: <58025A90.9010608@cumulusnetworks.com>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us> <1476276069-5315-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34532 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbcJOQey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 12:34:54 -0400
Received: by mail-pf0-f177.google.com with SMTP id r16so38745693pfg.1
        for <netdev@vger.kernel.org>; Sat, 15 Oct 2016 09:34:27 -0700 (PDT)
In-Reply-To: <1476276069-5315-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/16, 5:41 AM, Jiri Pirko wrote:
> From: Yotam Gigi <yotam.gi@gmail.com>
>
> This action allow the user to sample traffic matched by tc classifier.
> The sampling consists of choosing packets randomly, truncating them,
> adding some informative metadata regarding the interface and the original
> packet size and mark them with specific mark, to allow further tc rules to
> match and process. The marked sample packets are then injected into the
> device ingress qdisc using netif_receive_skb.
>
> The packets metadata is packed using the ife encapsulation protocol, and
> the outer packet's ethernet dest, source and eth_type, along with the
> rate, mark and the optional truncation size can be configured from
> userspace.
>
> Example:
> To sample ingress traffic from interface eth1, and redirect the sampled
> the sampled packets to interface dummy0, one may use the commands:
>
> tc qdisc add dev eth1 handle ffff: ingress
>
> tc filter add dev eth1 parent ffff: \
> 	   matchall action sample rate 12 mark 17
>
> tc filter add parent ffff: dev eth1 protocol all \
> 	   u32 match mark 172 0xff
> 	   action mirred egress redirect dev dummy0
>
> Where the first command adds an ingress qdisc and the second starts
> sampling every 12'th packet on dev eth0 and marks the sampled packets with
> 17. The command third catches the sampled packets, which are marked with
> 17, and redirects them to dev dummy0.
>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
channeling some feedback from Peter Phaal @sflow inline below:

> ---
>  
> diff --git a/include/net/tc_act/tc_sample.h b/include/net/tc_act/tc_sample.h
> new file mode 100644
> index 0000000..a2b445a
> --- /dev/null
> +++ b/include/net/tc_act/tc_sample.h
> @@ -0,0 +1,88 @@
> +#ifndef __NET_TC_SAMPLE_H
> +#define __NET_TC_SAMPLE_H
> +
> +#include <net/act_api.h>
> +#include <linux/tc_act/tc_sample.h>
> +
> +struct tcf_sample {
> +	struct tc_action	common;
> +	u32			rate;
> +	u32			mark;
> +	bool			truncate;
> +	u32			trunc_size;
> +	u32			packet_counter;
> +	u8			eth_dst[ETH_ALEN];
> +	u8			eth_src[ETH_ALEN];
> +	u16			eth_type;
> +	bool			eth_type_set;
> +	struct list_head	tcfm_list;
> +};
> +#define to_sample(a) ((struct tcf_sample *)a)
> +
> +struct sample_packet_metadata {
> +	int sample_size;
> +	int orig_size;
> +	int ifindex;
> +};
> +
This metadata does not look extensible.. can it be made to ?

With sflow in context, you need a pair of ifindex numbers to encode ingress and egress ports. Ideally you would also include a sequence number and a count of the total number of packets that were candidates for sampling. The OVS implementation is a good example, the metadata includes all the actions applied to the packet in the kernel data path.



[snip]

> diff --git a/include/uapi/linux/tc_act/tc_sample.h b/include/uapi/linux/tc_act/tc_sample.h
> new file mode 100644
> index 0000000..654945b
> --- /dev/null
> +++ b/include/uapi/linux/tc_act/tc_sample.h
> @@ -0,0 +1,31 @@
> +#ifndef __LINUX_TC_SAMPLE_H
> +#define __LINUX_TC_SAMPLE_H
> +
> +#include <linux/types.h>
> +#include <linux/pkt_cls.h>
> +#include <linux/if_ether.h>
> +
> +#define TCA_ACT_SAMPLE 26
> +
> +struct tc_sample {
> +	tc_gen;
> +	__u32		rate;		/* sample rate */
> +	__u32		mark;		/* mark to put on the sampled packets */
> +	bool		truncate;	/* whether to truncate the packets */
> +	__u32		trunc_size;	/* truncation size */
> +	__u8		eth_dst[ETH_ALEN]; /* encapsulated mac destination */
> +	__u8		eth_src[ETH_ALEN]; /* encapsulated mac source */
> +	bool		eth_type_set;	   /* whether to overrid ethtype */
> +	__u16		eth_type;	   /* encapsulated mac ethtype */
> +};
> +
this does not look extensible and is part of UAPI ..

Doing the minimum in the kernel and leaving the rest to the user space agent is much more flexible. The user space agent can attach additional metadata and offer more flexibility in forwarding (sFlow uses XDR encoding over UDP and is routable over IPv4/IPv6).



> +enum {
> +	TCA_SAMPLE_UNSPEC,
> +	TCA_SAMPLE_TM,
> +	TCA_SAMPLE_PARMS,
> +	TCA_SAMPLE_PAD,
> +	__TCA_SAMPLE_MAX
> +};
> +#define TCA_SAMPLE_MAX (__TCA_SAMPLE_MAX - 1)
> +
> +#endif
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 24f7cac..c54ea6b 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -650,6 +650,19 @@ config NET_ACT_MIRRED
>  	  To compile this code as a module, choose M here: the
>  	  module will be called act_mirred.
>  
> +config NET_ACT_SAMPLE
> +        tristate "Traffic Sampling"
> +        depends on NET_CLS_ACT
> +        select NET_IFE
> +        ---help---
> +	  Say Y here to allow packet sampling tc action. The packet sample
> +	  action consists of statistically duplicating packets, truncating them
> +	  and adding descriptive metadata to them. The duplicated packets are
> +	  then marked to allow further processing using tc.
> +
> +	  To compile this code as a module, choose M here: the
> +	  module will be called act_sample.
> +
>  config NET_ACT_IPT
>          tristate "IPtables targets"
>          depends on NET_CLS_ACT && NETFILTER && IP_NF_IPTABLES
> diff --git a/net/sched/Makefile b/net/sched/Makefile
> index 4bdda36..7b915d2 100644
> --- a/net/sched/Makefile
> +++ b/net/sched/Makefile
[snip]
> +static int tcf_sample(struct sk_buff *skb, const struct tc_action *a,
> +		      struct tcf_result *res)
> +{
> +	struct tcf_sample *s = to_sample(a);
> +	struct sample_packet_metadata metadata;
> +	static struct ethhdr *ethhdr;
> +	struct sk_buff *skb2;
> +	int retval;
> +	u32 at;
> +
> +	tcf_lastuse_update(&s->tcf_tm);
> +	bstats_cpu_update(this_cpu_ptr(s->common.cpu_bstats), skb);
> +
> +	rcu_read_lock();
> +	retval = READ_ONCE(s->tcf_action);
> +
> +	if (++s->packet_counter % s->rate == 0) {

The sampling function isn’t random

if (++s->packet_counter % s->rate == 0) {

This is unsuitable for sFlow, which is specific about the random sampling function required. BPF, OVS, and the 
ULOG statistics module include efficient kernel based random sampling functions that could be used instead.


Thanks,
Roopa
