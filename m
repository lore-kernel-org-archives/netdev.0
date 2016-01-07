From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net, sched: add clsact qdisc
Date: Thu, 07 Jan 2016 17:52:54 +0100
Message-ID: <568E97E6.1000701@iogearbox.net>
References: <d091709bf1a93c65cdadc9a990c9065e065840b8.1452041153.git.daniel@iogearbox.net> <1452184195.8255.215.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56167 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbcAGQw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 11:52:58 -0500
In-Reply-To: <1452184195.8255.215.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2016 05:29 PM, Eric Dumazet wrote:
> On Wed, 2016-01-06 at 02:00 +0100, Daniel Borkmann wrote:
>> This work adds a generalization of the ingress qdisc as a qdisc holding
>> only classifiers. The clsact qdisc works on ingress, but also on egress.
>> In both cases, it's execution happens without taking the qdisc lock, and
>> the main difference for the egress part compared to prior version of [1]
>> is that this can be applied with _any_ underlying real egress qdisc (also
>> classless ones).
>
>> +void net_dec_egress_queue(void)
>> +{
>> +	static_key_slow_dec(&egress_needed);
>> +}
>> +EXPORT_SYMBOL_GPL(net_dec_egress_queue);
>> +#endif
>> +
>>   static struct static_key netstamp_needed __read_mostly;
>>   #ifdef HAVE_JUMP_LABEL
>>   /* We are not allowed to call static_key_slow_dec() from irq context
>> @@ -3100,6 +3116,48 @@ int dev_loopback_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
>>   }
>>   EXPORT_SYMBOL(dev_loopback_xmit);
>>
>> +#ifdef CONFIG_NET_EGRESS
>> +static struct sk_buff *
>> +sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
>> +{
>> +	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
>> +	struct tcf_result cl_res;
>> +
>> +	if (!cl)
>> +		return skb;
>> +
>> +	qdisc_skb_cb(skb)->pkt_len = skb->len;
>
> You probably should move qdisc_pkt_len_init() out of __dev_xmit_skb()
> and call it earlier. Then this pkt_len partial init is no longer needed.

Agreed, will change it for v2.

Thanks,
Daniel
