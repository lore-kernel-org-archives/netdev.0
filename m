From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] netem: add ECN capability
Date: Tue, 1 May 2012 09:59:14 -0700
Message-ID: <20120501095914.0e60ff6a@s6510.linuxnetplumber.net>
References: <1335863465.11396.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55748 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752561Ab2EAQ7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 12:59:23 -0400
In-Reply-To: <1335863465.11396.45.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 May 2012 11:11:05 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Add ECN (Explicit Congestion Notification) marking capability to netem
> 
> tc qdisc add dev eth0 root netem drop 0.5 ecn
> 
> Instead of dropping packets, try to ECN mark them.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Hagen Paul Pfeifer <hagen@jauu.net>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> ---
>  include/linux/pkt_sched.h |    1 +
>  net/sched/sch_netem.c     |   18 +++++++++++++++---
>  2 files changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index 410b33d..ffe975c 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -509,6 +509,7 @@ enum {
>  	TCA_NETEM_CORRUPT,
>  	TCA_NETEM_LOSS,
>  	TCA_NETEM_RATE,
> +	TCA_NETEM_ECN,
>  	__TCA_NETEM_MAX,
>  };
>  
> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index 1109731..231cd11 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -26,6 +26,7 @@
>  
>  #include <net/netlink.h>
>  #include <net/pkt_sched.h>
> +#include <net/inet_ecn.h>
>  
>  #define VERSION "1.3"
>  
> @@ -78,6 +79,7 @@ struct netem_sched_data {
>  	psched_tdiff_t jitter;
>  
>  	u32 loss;
> +	u32 ecn;
>  	u32 limit;
>  	u32 counter;
>  	u32 gap;
> @@ -374,9 +376,12 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		++count;
>  
>  	/* Drop packet? */
> -	if (loss_event(q))
> -		--count;
> -
> +	if (loss_event(q)) {
> +		if (q->ecn && INET_ECN_set_ce(skb))
> +			sch->qstats.drops++; /* mark packet */
> +		else
> +			--count;
> +	}
>  	if (count == 0) {
>  		sch->qstats.drops++;
>  		kfree_skb(skb);
> @@ -706,6 +711,7 @@ static const struct nla_policy netem_policy[TCA_NETEM_MAX + 1] = {
>  	[TCA_NETEM_CORRUPT]	= { .len = sizeof(struct tc_netem_corrupt) },
>  	[TCA_NETEM_RATE]	= { .len = sizeof(struct tc_netem_rate) },
>  	[TCA_NETEM_LOSS]	= { .type = NLA_NESTED },
> +	[TCA_NETEM_ECN]		= { .type = NLA_U32 },
>  };
>  
>  static int parse_attr(struct nlattr *tb[], int maxtype, struct nlattr *nla,
> @@ -776,6 +782,9 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
>  	if (tb[TCA_NETEM_RATE])
>  		get_rate(sch, tb[TCA_NETEM_RATE]);
>  
> +	if (tb[TCA_NETEM_ECN])
> +		q->ecn = nla_get_u32(tb[TCA_NETEM_ECN]);
> +
>  	q->loss_model = CLG_RANDOM;
>  	if (tb[TCA_NETEM_LOSS])
>  		ret = get_loss_clg(sch, tb[TCA_NETEM_LOSS]);
> @@ -902,6 +911,9 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
>  	if (nla_put(skb, TCA_NETEM_RATE, sizeof(rate), &rate))
>  		goto nla_put_failure;
>  
> +	if (q->ecn && nla_put_u32(skb, TCA_NETEM_ECN, q->ecn))
> +		goto nla_put_failure;
> +
>  	if (dump_loss_model(q, skb) != 0)
>  		goto nla_put_failure;

The concept is fine, but a couple of questions.
 1. Why a whole u32 for boolean?
 2. The logic in this part of netem is setup to handle case of random duplication
    combined with random loss. With ecn option set, will this code correctly
    handled a duplication combined with a loss and send one packet?
    It looks like the new code would change that behaviour.
