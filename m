From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/6] Add qdisc->ops->peek() support.
Date: Fri, 17 Oct 2008 16:12:03 +0200
Message-ID: <48F89D33.9090809@trash.net>
References: <20081016220905.GA2747@ami.dom.local> <48F88613.1060404@trash.net> <20081017130333.GA8297@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33329 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754326AbYJQOMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 10:12:10 -0400
In-Reply-To: <20081017130333.GA8297@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Fri, Oct 17, 2008 at 02:33:23PM +0200, Patrick McHardy wrote:
>>> @@ -233,7 +233,9 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>>  		 */
>>>  		cb->time_to_send = psched_get_time();
>>>  		q->counter = 0;
>>> -		ret = q->qdisc->ops->requeue(skb, q->qdisc);
>>> +		q->qdisc->flags |= TCQ_F_REQUEUE;
>>> +		ret = qdisc_equeue(skb, q->qdisc);
>>> +		q->qdisc->flags &= ~TCQ_F_REQUEUE;
>> Well, the inner qdisc would still need to logic to order packets
>> apprioriately.
> 
> I'm not sure I was understood: the idea is to do something like
> in this example in tfifo_enqueue() in all leaf qdiscs like fifo
> etc. too, so to redirect their ->enqueue() to their ->requeue()
> which usually is qdisc_requeue() (or to it directly if needed).

Yes, I misunderstood this, I though the intention was to get
rid of requeue entirely.

>> Its probably not that hard, but as I said, I don't
>> think its necessary at all. It only makes a difference with a
>> non-work-conserving inner qdisc, but a lot of the functionality of
>> netem requires the inner tfifo anyways and rate-limiting is usually
>> done on top of netem. So I would suggest so either hard-wire the
>> tfifo qdisc or at least make the assumption that inner qdiscs are
>> work-conserving.
> 
> Of course, I can do it like this, but wouldn't it break backward
> compatibility for some users?

Some general thoughts ...

We've never had any systematic checks for useful and non-useful
combination of qdiscs, which is causing a lot of these complications.
Think of all the multiq work that was required to make it work
properly with non-work-conserving qdiscs - while at the same time,
using a non-work-conserving qdisc (which require a global view)
defeats basically all of the benefits.

So it would be really useful to come up with a systematic definition
of valid combinations instead of trying handling lots of purely
theoretical case that don't make sense. One more example - all the
qdiscs implement ->drop(), yet its only needed by CBQ and it doesn't
make any sense at all to use lets say HFSC as child of CBQ.

About this specific case - yes, it would break compatibility for
users using f.i. TBF as child of netem. But if you look at the
netem_enqueue() function, it in fact assumes that the inner qdisc
is a tfifo, so we'd be breaking an already broken case. We can
of course be nice and warn about it for a few releases, but I believe
there is some real potential for simplification that makes it
worth it.
