From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] tc: add BPF based action
Date: Thu, 8 Jan 2015 16:01:36 +0100
Message-ID: <20150108150134.GB1898@nanopsycho.orion>
References: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
 <1420728937.5928.8.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	stephen@networkplumber.org
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:57089 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118AbbAHPBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:01:38 -0500
Received: by mail-wg0-f42.google.com with SMTP id k14so3078782wgh.1
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 07:01:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1420728937.5928.8.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 08, 2015 at 03:55:37PM CET, hannes@redhat.com wrote:
>On Mi, 2015-01-07 at 17:43 +0100, Jiri Pirko wrote:
>> +static int tcf_bpf(struct sk_buff *skb, const struct tc_action *a,
>> +		   struct tcf_result *res)
>> +{
>> +	struct tcf_bpf *b = a->priv;
>> +	int action;
>> +	int filter_res;
>> +
>> +	spin_lock(&b->tcf_lock);
>> +	b->tcf_tm.lastuse = jiffies;
>> +	bstats_update(&b->tcf_bstats, skb);
>> +	action = b->tcf_action;
>> +
>> +	filter_res = BPF_PROG_RUN(b->filter, skb);
>> +	if (filter_res == -1)
>> +		goto drop;
>> +
>> +	goto unlock;
>> +
>> +drop:
>> +	action = TC_ACT_SHOT;
>> +	b->tcf_qstats.drops++;
>> +unlock:
>> +	spin_unlock(&b->tcf_lock);
>> +	return action;
>> +}
>
>In theory this could be like:
>
>filter_res = BPF_PROG_RUN(b->filter, skb);
>
>spin_lock(&b->tcf_lock);
><update stats...>
>
>if (filter_res == -1)
>  goto drop;
>
>action = b->tcf_action;
>...
>
>to keep BPF_PROG_RUN out of the spin_lock?

Okay. That makes sense. Will include this change into v2.

Thanks.

>
>Bye,
>Hannes
>
>
