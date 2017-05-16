From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 02/10] net: sched: introduce tcf block
 infractructure
Date: Tue, 16 May 2017 08:07:25 -0400
Message-ID: <33ea772b-d35b-ae08-4137-b63185c2f590@mojatatu.com>
References: <20170515083857.3615-1-jiri@resnulli.us>
 <20170515083857.3615-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36477 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751203AbdEPMH2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 08:07:28 -0400
Received: by mail-io0-f194.google.com with SMTP id f102so14167423ioi.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 05:07:28 -0700 (PDT)
In-Reply-To: <20170515083857.3615-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jiri,

I am sorry i am tied up elsewhere but will respond in chunks.

On 17-05-15 04:38 AM, Jiri Pirko wrote:


>  static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
>  {
>  	struct qdisc_skb_cb *qcb;


> +int tcf_block_get(struct tcf_block **p_block,
> +		  struct tcf_proto __rcu **p_filter_chain)
> +{
> +	struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
> +
> +	if (!block)
> +		return -ENOMEM;
> +	block->p_filter_chain = p_filter_chain;
> +	*p_block = block;
> +	return 0;
> +}

tcf_block_get() sounds odd. tcf_block_create()?

> +EXPORT_SYMBOL(tcf_block_get);
> +
> +void tcf_block_put(struct tcf_block *block)
> +{
> +	if (!block)
> +		return;
> +	tcf_destroy_chain(block->p_filter_chain);
> +	kfree(block);
> +}

tcf_destroy_block()?

[..]

> +	error = tcf_block_get(&flow->block, &flow->filter_list);
> +	if (error) {
> +		kfree(flow);
> +		goto err_out;
> +	}
> +
>  	flow->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
>  	if (!flow->q)
>  		flow->q = &noop_qdisc;
> @@ -346,14 +353,13 @@ static void atm_tc_walk(struct Qdisc *sch, struct qdisc_walker *walker)
>  	}
>  }
>
> -static struct tcf_proto __rcu **atm_tc_find_tcf(struct Qdisc *sch,
> -						unsigned long cl)
> +static struct tcf_block *atm_tc_tcf_block(struct Qdisc *sch, unsigned long cl)

Any reason you removed the verb "find" from all these calls?
eg above: better to have atm_tc_tcf_block_find()?

cheers,
jamal
