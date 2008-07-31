From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH] net-sched: add packet length pointer parameter for
	qdisc_enqueue
Date: Thu, 31 Jul 2008 12:04:57 +0300
Message-ID: <20080731120457.34626tsepmygd1c0@hayate.ip6>
References: <20080731070233.GA4769@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:36599 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627AbYGaJFA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 05:05:00 -0400
In-Reply-To: <20080731070233.GA4769@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Jarek Poplawski" <jarkao2@gmail.com>:

> On 30-07-2008 20:55, Jussi Kivilinna wrote:
>> Pass packet length to caller through pointer so that length is
>> available to caller even if inner qdisc frees skb.
> ...
>> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>> index b5f40d7..a428b93 100644
>> --- a/include/net/sch_generic.h
>> +++ b/include/net/sch_generic.h
>> @@ -331,19 +331,22 @@ static inline unsigned int  
>> qdisc_pkt_len(struct sk_buff *skb)
>>  	return qdisc_skb_cb(skb)->pkt_len;
>>  }
>>
>> -static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>> +static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch,
>> +				unsigned int *pkt_len)
>>  {
>>  #ifdef CONFIG_NET_SCHED
>>  	if (sch->stab)
>>  		qdisc_calculate_pkt_len(skb, sch->stab);
>>  #endif
>> +	if (likely(pkt_len != NULL))
>> +		*pkt_len = qdisc_pkt_len(skb);
>>  	return sch->enqueue(skb, sch);
>>  }
>
> As I've written before, IMHO using an skb after enqueuing should be
> avoided unless we refcounted it or the returned code is clear enough,
> so the idea of this patch could be right to me. But, I guess, you are
> changing here the way it's done: the size is calculated before the
> current enqueing instead of after the last one.

Doh, you're right. qdisc->enqueue should pass packet length too.

>
> BTW, since I don't really get this "stab" idea enough, I wonder how
> it is expected to be used: with a top qdisc, a leaf one or some
> summing?
>

With top and/or leaf qdisc, inner stab overrides upper.


