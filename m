From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [patch net-next] tc: add BPF based action
Date: Thu, 08 Jan 2015 15:55:37 +0100
Message-ID: <1420728937.5928.8.camel@redhat.com>
References: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756479AbbAHOz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 09:55:57 -0500
In-Reply-To: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2015-01-07 at 17:43 +0100, Jiri Pirko wrote:
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
> +drop:
> +	action = TC_ACT_SHOT;
> +	b->tcf_qstats.drops++;
> +unlock:
> +	spin_unlock(&b->tcf_lock);
> +	return action;
> +}

In theory this could be like:

filter_res = BPF_PROG_RUN(b->filter, skb);

spin_lock(&b->tcf_lock);
<update stats...>

if (filter_res == -1)
  goto drop;

action = b->tcf_action;
...

to keep BPF_PROG_RUN out of the spin_lock?

Bye,
Hannes
