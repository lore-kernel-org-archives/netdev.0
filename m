From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Fri, 12 Sep 2008 08:02:49 +0000
Message-ID: <20080912080249.GA3971@ff.dom.local>
References: <20080911.044255.245121628.davem@davemloft.net> <20080911114502.GA22698@gondor.apana.org.au> <20080911.044717.265303740.davem@davemloft.net> <20080911.214929.152271268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.240]:1479 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbYILIC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 04:02:56 -0400
Received: by hs-out-0708.google.com with SMTP id 4so280714hsl.5
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2008 01:02:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080911.214929.152271268.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 09:49:29PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 11 Sep 2008 04:47:17 -0700 (PDT)
> 
> > Ok, so implementing ->peek() is the first step in dealing
> > with this.
> 
> Ok, here's a first cut at this.
> 
> Most of it is simple and straightforward.
> 
> As usual, though, CBQ, HFSC, and HTB are complicated.

I guess not for Patrick... (so CCed)

> 
> Most of the peek implementations just skb_peek() in their
> downstream queue or iterate over their prio array doing
> the same looking for a non-empty list.
> 
> But CBQ, HFSC, and HTB have complicated class iterators and
> internal time state machine things.  I tried to do my best
> in these cases.
> 
> I didn't want these things firing off class watchdog timers and
> stuff like this.  Just see if there is any packet ready now
> and return it.
> 
> The one exception is that I allow CBQ to advance it's time
> state machine.

Alas I'm still not sure how this whole peek idea is going to be
implemented (dequeuing after peeking doesn't have to give us the
same skb since in the meantime e.g. in HTB some other class with
higher prio can get enough tokens etc., and if there is a break
for transmit in the meantime with possible enqueuing, or we can
deal with something like sch_multiq, which depends on the current
state of the tx_queues, this all looks even more interesting).

So, until there is some example, even in pseudocode, for qdisc_run()
vs. some_classful_sched interaction, I think, I'm not able to give
more feedback now, but mabe only one doubt if this wrapper below is
really needed, since skb_peek() is more readable and it's used
directly in a few places anyway.

> +static inline struct sk_buff *__qdisc_peek_head(struct Qdisc *sch,
> +						struct sk_buff_head *list)
> +{
> +	return skb_peek(list);
> +}

Thanks,
Jarek P.
