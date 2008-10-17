From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 0/6] Add qdisc->ops->peek() support.
Date: Fri, 17 Oct 2008 13:03:33 +0000
Message-ID: <20081017130333.GA8297@ff.dom.local>
References: <20081016220905.GA2747@ami.dom.local> <48F88613.1060404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.234]:4121 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238AbYJQNDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 09:03:40 -0400
Received: by qb-out-0506.google.com with SMTP id f11so250857qba.17
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2008 06:03:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F88613.1060404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2008 at 02:33:23PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> Patrick McHardy wrote, On 10/16/2008 02:38 PM:
>>
>>> Jarek Poplawski wrote:
>> ...
>>>> PS: after this patchset only netem_enqueue() needs qdisc->requeue(),
>>>> but I hope this won't take too long.
>>> Assuming work-conserving qdiscs are used with netem, the currently
>>> code will always send out a reorder packet immediately. This behaviour
>>> is trivial to implement without ->requeue. The problematic case is
>>> non-work-conserving inner qdiscs, but that doesn't seem important
>>> at all since you'd usually add it as parent of netem, which still
>>> works.
>>
>> How about something like this (example only)?
>> @@ -233,7 +233,9 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>  		 */
>>  		cb->time_to_send = psched_get_time();
>>  		q->counter = 0;
>> -		ret = q->qdisc->ops->requeue(skb, q->qdisc);
>> +		q->qdisc->flags |= TCQ_F_REQUEUE;
>> +		ret = qdisc_equeue(skb, q->qdisc);
>> +		q->qdisc->flags &= ~TCQ_F_REQUEUE;
>
> Well, the inner qdisc would still need to logic to order packets
> apprioriately.

I'm not sure I was understood: the idea is to do something like
in this example in tfifo_enqueue() in all leaf qdiscs like fifo
etc. too, so to redirect their ->enqueue() to their ->requeue()
which usually is qdisc_requeue() (or to it directly if needed).

> Its probably not that hard, but as I said, I don't
> think its necessary at all. It only makes a difference with a
> non-work-conserving inner qdisc, but a lot of the functionality of
> netem requires the inner tfifo anyways and rate-limiting is usually
> done on top of netem. So I would suggest so either hard-wire the
> tfifo qdisc or at least make the assumption that inner qdiscs are
> work-conserving.

Of course, I can do it like this, but wouldn't it break backward
compatibility for some users?

Thanks,
Jarek P.
