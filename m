From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 02/10] net: sched: introduce tcf block
 infractructure
Date: Tue, 16 May 2017 14:23:26 +0200
Message-ID: <20170516122326.GK1939@nanopsycho.orion>
References: <20170515083857.3615-1-jiri@resnulli.us>
 <20170515083857.3615-3-jiri@resnulli.us>
 <33ea772b-d35b-ae08-4137-b63185c2f590@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35490 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751634AbdEPMXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 08:23:30 -0400
Received: by mail-wm0-f65.google.com with SMTP id v4so37867737wmb.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 05:23:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <33ea772b-d35b-ae08-4137-b63185c2f590@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 16, 2017 at 02:07:25PM CEST, jhs@mojatatu.com wrote:
>
>Jiri,
>
>I am sorry i am tied up elsewhere but will respond in chunks.
>
>On 17-05-15 04:38 AM, Jiri Pirko wrote:
>
>
>>  static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
>>  {
>>  	struct qdisc_skb_cb *qcb;
>
>
>> +int tcf_block_get(struct tcf_block **p_block,
>> +		  struct tcf_proto __rcu **p_filter_chain)
>> +{
>> +	struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
>> +
>> +	if (!block)
>> +		return -ENOMEM;
>> +	block->p_filter_chain = p_filter_chain;
>> +	*p_block = block;
>> +	return 0;
>> +}
>
>tcf_block_get() sounds odd. tcf_block_create()?

I used get/put because I plan to allow sharing of block between qdiscs
in future. Then there will be a refcount.


>
>> +EXPORT_SYMBOL(tcf_block_get);
>> +
>> +void tcf_block_put(struct tcf_block *block)
>> +{
>> +	if (!block)
>> +		return;
>> +	tcf_destroy_chain(block->p_filter_chain);
>> +	kfree(block);
>> +}
>
>tcf_destroy_block()?
>
>[..]
>
>> +	error = tcf_block_get(&flow->block, &flow->filter_list);
>> +	if (error) {
>> +		kfree(flow);
>> +		goto err_out;
>> +	}
>> +
>>  	flow->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
>>  	if (!flow->q)
>>  		flow->q = &noop_qdisc;
>> @@ -346,14 +353,13 @@ static void atm_tc_walk(struct Qdisc *sch, struct qdisc_walker *walker)
>>  	}
>>  }
>> 
>> -static struct tcf_proto __rcu **atm_tc_find_tcf(struct Qdisc *sch,
>> -						unsigned long cl)
>> +static struct tcf_block *atm_tc_tcf_block(struct Qdisc *sch, unsigned long cl)
>
>Any reason you removed the verb "find" from all these calls?
>eg above: better to have atm_tc_tcf_block_find()?

Yeah, I was thinking about it. The thing is, the callback does not do
any lookup so "find" is not accurate. Also without "find" this is
shorter so I decided for this naming variant.



>
>cheers,
>jamal
