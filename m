From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/6] Add qdisc->ops->peek() support.
Date: Fri, 17 Oct 2008 14:33:23 +0200
Message-ID: <48F88613.1060404@trash.net>
References: <20081016220905.GA2747@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63483 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658AbYJQMd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 08:33:29 -0400
In-Reply-To: <20081016220905.GA2747@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Patrick McHardy wrote, On 10/16/2008 02:38 PM:
> 
>> Jarek Poplawski wrote:
> ...
>>> PS: after this patchset only netem_enqueue() needs qdisc->requeue(),
>>> but I hope this won't take too long.
>> Assuming work-conserving qdiscs are used with netem, the currently
>> code will always send out a reorder packet immediately. This behaviour
>> is trivial to implement without ->requeue. The problematic case is
>> non-work-conserving inner qdiscs, but that doesn't seem important
>> at all since you'd usually add it as parent of netem, which still
>> works.
> 
> How about something like this (example only)?
> @@ -233,7 +233,9 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		 */
>  		cb->time_to_send = psched_get_time();
>  		q->counter = 0;
> -		ret = q->qdisc->ops->requeue(skb, q->qdisc);
> +		q->qdisc->flags |= TCQ_F_REQUEUE;
> +		ret = qdisc_equeue(skb, q->qdisc);
> +		q->qdisc->flags &= ~TCQ_F_REQUEUE;

Well, the inner qdisc would still need to logic to order packets
apprioriately. Its probably not that hard, but as I said, I don't
think its necessary at all. It only makes a difference with a
non-work-conserving inner qdisc, but a lot of the functionality of
netem requires the inner tfifo anyways and rate-limiting is usually
done on top of netem. So I would suggest so either hard-wire the
tfifo qdisc or at least make the assumption that inner qdiscs are
work-conserving.
