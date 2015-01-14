From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [patch net-next 1/2 v3] tc: add BPF based action
Date: Wed, 14 Jan 2015 14:28:40 +0100
Message-ID: <54B66F08.2010305@redhat.com>
References: <1421229297-14473-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	ast@plumgrid.com, hannes@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55033 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751187AbbANN2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 08:28:51 -0500
In-Reply-To: <1421229297-14473-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2015 10:54 AM, Jiri Pirko wrote:
> This action provides a possibility to exec custom BPF code.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
...
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index c54c9d9..cc311e9 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -698,6 +698,17 @@ config NET_ACT_VLAN
>   	  To compile this code as a module, choose M here: the
>   	  module will be called act_vlan.
>
> +config NET_ACT_BPF
> +        tristate "BPF based action"
> +        depends on NET_CLS_ACT
> +        ---help---
> +	  Say Y here to execute BFP code on packets.
                                 ^^^
                                (typo)

Technically correct, but I'd be a bit more precise. When we add eBPF
support one day, this description should be extended to better explain
what it can do, for now it would be good to mention that it can
filter + drop packets.

> +	  If unsure, say N.
> +
> +	  To compile this code as a module, choose M here: the
> +	  module will be called act_bpf.
> +
...
> diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
> new file mode 100644
> index 0000000..0e2a912
> --- /dev/null
> +++ b/net/sched/act_bpf.c
> @@ -0,0 +1,206 @@
...
> +static int tcf_bpf(struct sk_buff *skb, const struct tc_action *a,
> +		   struct tcf_result *res)
> +{
> +	struct tcf_bpf *b = a->priv;
> +	int action;
> +	int filter_res;
> +
> +	spin_lock(&b->tcf_lock);
> +	b->tcf_tm.lastuse = jiffies;
> +	bstats_update(&b->tcf_bstats, skb);
> +	action = b->tcf_action;
> +
> +	filter_res = BPF_PROG_RUN(b->filter, skb);
> +	if (filter_res == -1)
> +		goto drop;
> +
> +	goto unlock;
> +

Why this double goto stuff? Wouldn't it be easier to just write it as:

	filter_res = BPF_PROG_RUN(b->filter, skb);
	if (filter_res == -1) {
		/* #-1 return code from the BPF program in act_bpf
		 * is being interpreted as a drop.
		 */
		action = TC_ACT_SHOT;
		b->tcf_qstats.drops++;
	}

	spin_unlock(&b->tcf_lock);
	return action;

I'm still wondering about the drop semantics ... wouldn't it be more
intuitive to use 0 for drops in this context?

> +drop:
> +	action = TC_ACT_SHOT;
> +	b->tcf_qstats.drops++;
> +unlock:
> +	spin_unlock(&b->tcf_lock);
> +	return action;
> +}
...

Thanks,
Daniel
