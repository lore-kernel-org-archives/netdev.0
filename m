From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH v2 08/10] net: sched: pfifo_fast use alf_queue
Date: Fri, 15 Jul 2016 10:29:52 -0700
Message-ID: <57891D90.5020906@gmail.com>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
 <20160714062312.8270.65942.stgit@john-Precision-Tower-5810>
 <20160714171148.3bb7b47b@redhat.com> <578829C7.8060604@gmail.com>
 <20160715120936.0b339b2a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35154 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbcGORaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 13:30:09 -0400
Received: by mail-pa0-f68.google.com with SMTP id dx3so6462161pab.2
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 10:30:08 -0700 (PDT)
In-Reply-To: <20160715120936.0b339b2a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-15 03:09 AM, Jesper Dangaard Brouer wrote:
> On Thu, 14 Jul 2016 17:09:43 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
>>>>  static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
>>>>  			      struct sk_buff **to_free)
>>>>  {
>>>> -	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
>>>> -		int band = prio2band[skb->priority & TC_PRIO_MAX];
>>>> -		struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
>>>> -		struct sk_buff_head *list = band2list(priv, band);
>>>> -
>>>> -		priv->bitmap |= (1 << band);
>>>> -		qdisc->q.qlen++;
>>>> -		return __qdisc_enqueue_tail(skb, qdisc, list);
>>>> -	}
>>>> +	int band = prio2band[skb->priority & TC_PRIO_MAX];
>>>> +	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
>>>> +	struct skb_array *q = band2list(priv, band);
>>>> +	int err;
>>>>  
>>>> -	return qdisc_drop(skb, qdisc, to_free);
>>>> +	err = skb_array_produce_bh(q, skb);  
>>>
>>> Do you need the _bh variant here?  (Doesn't the qdisc run with BH disabled?)
>>>
>>>   
>>
>> Yep its inside rcu_read_lock_bh().
> 
> The call rcu_read_lock_bh() already disabled BH (local_bh_disable()).
> Thus, you can use the normal variants of skb_array_produce(), it is
> (approx 20 cycles) faster than the _bh variant...
> 

hah I was agreeing with you as in yep no need for the _bh variant :)
I must have been low on coffee or something when I wrote that response
because when I read it now it sounds like I really think the _bh is
needed.

At any rate _bh removed thanks!
