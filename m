From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TSO trimming question
Date: Fri, 21 Dec 2007 11:26:12 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712211055550.31652@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
 <20071219.235450.170670042.davem@davemloft.net>
 <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
 <20071220.035621.147230372.davem@davemloft.net> <20071221030648.389669c4.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	John Heffner <jheffner@psc.edu>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50865 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbXLUJ0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:26:16 -0500
In-Reply-To: <20071221030648.389669c4.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Dec 2007, Bill Fink wrote:

> I meant to ask about this a while back but then got distracted by
> other things.  But now since the subject has come up, I had a couple
> of more questions about this code.
> 
> What's with all the shifting back and forth?  Here with:
> 
> 	((jiffies<<1)>>1) - (tp->tso_deferred>>1)
> 
> and later with:
> 
> 	/* Ok, it looks like it is advisable to defer.  */
> 	tp->tso_deferred = 1 | (jiffies<<1);
> 
> Is this just done to try and avoid the special case of jiffies==0 
> when the jiffies wrap? 

I thought that it must be the reason. I couldn't figure out any other 
explination while thinking the same thing but since I saw no problem in 
that rather weird approach, I didn't want to touch that in a patch which 
had net-2.6 (or stable) potential.

> If so it seems like a lot of unnecessary
> work just to avoid a 1 in 4 billion event, since it's my understanding
> that the whole tcp_tso_should_defer function is just an optimization
> and not a criticality to the proper functioning of TCP, especially
> considering it hasn't even been executing at all up to now.

It would still be good to not return 1 in that case we didn't flag the 
deferral, how about adding one additional tick (+comment) in the zero 
case making tso_deferred == 0 again unambiguously defined, e.g.:

	tp->tso_deferred = min_t(u32, jiffies, 1);

...I'm relatively sure that nobody would ever notice that tick :-) and we 
kept return value consistent with tso_deferred state invariant.

> My second question is more basic and if I'm not mistaken actually
> relates to a remaining bug in the (corrected) test:
> 
> 	/* Defer for less than two clock ticks. */
> 	if (tp->tso_deferred &&
> 	    ((jiffies << 1) >> 1) - (tp->tso_deferred >> 1) > 1)
> 
> Since jiffies is an unsigned long, which is 64-bits on a 64-bit system,
> whereas tp->tso_deferred is a u32, once jiffies exceeds 31-bits, which
> will happen in about 25 days if HZ=1000, won't the second part of the
> test always be true after that?  Or am I missing something obvious?

I didn't notice that earlier but I think you're right though my knowledge 
about jiffies and such is quite limited.

...Feel free to submit a patch to correct these.


-- 
 i.
