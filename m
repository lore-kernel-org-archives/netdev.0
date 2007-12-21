From: Bill Fink <billfink@mindspring.com>
Subject: Re: TSO trimming question
Date: Fri, 21 Dec 2007 05:58:22 -0500
Message-ID: <20071221055822.8d977800.billfink@mindspring.com>
References: <20071221030648.389669c4.billfink@mindspring.com>
	<20071221.012720.67812056.davem@davemloft.net>
	<20071221092927.GA32434@gondor.apana.org.au>
	<20071221.013642.29817274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, jheffner@psc.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:41590 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751575AbXLUK6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 05:58:35 -0500
In-Reply-To: <20071221.013642.29817274.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Dec 2007, David Miller wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 21 Dec 2007 17:29:27 +0800
> 
> > On Fri, Dec 21, 2007 at 01:27:20AM -0800, David Miller wrote:
> > >
> > > It's two shifts, and this gets scheduled along with the other
> > > instructions on many cpus so it's effectively free.
> > > 
> > > I don't see why this is even worth mentioning and discussing.
> > 
> > I totally agree.  Two shifts are way better than a branch.
> 
> We take probably a thousand+ 100+ cycle cache misses in the TCP stack
> on big window openning ACKs.
> 
> Instead of discussing ways to solve that huge performance killer we're
> wanking about two friggin' integer shifts.
> 
> It's hilarious isn't it? :-)

I don't think obfuscated code is hilarious.  Instead of the convoluted
and dense code:

	/* Defer for less than two clock ticks. */
	if (tp->tso_deferred &&
	    ((jiffies << 1) >> 1) - (tp->tso_deferred >> 1) > 1)

You can have the much simpler and more easily understandable:

	/* Defer for less than two clock ticks. */
	if (tp->tso_deferred && (jiffies - tp->tso_deferred) > 1)

And instead of:

	/* Ok, it looks like it is advisable to defer.  */
        tp->tso_deferred = 1 | (jiffies<<1);

        return 1;

You could do as Ilpo suggested:

	/* Ok, it looks like it is advisable to defer.  */
	tp->tso_deferred = max_t(u32, jiffies, 1);

        return 1;

Or perhaps more efficiently:

	/* Ok, it looks like it is advisable to defer.  */
	tp->tso_deferred = jiffies;
	if (unlikely(jiffies == 0))
		tp->tso_deferred = 1;

        return 1;

Or perhaps even:

	/* Ok, it looks like it is advisable to defer.  */
	tp->tso_deferred = jiffies;

	/* need to return a non-zero value to defer, which means won't
	 * defer if jiffies == 0 but it's only a 1 in 4 billion event
	 * (and avoids a compare/branch by not checking jiffies)
	 /
        return jiffies;

Since it really only needs a non-zero return value to defer.

See, no branches needed and much clearer code.  That seems worthwhile
to me from a code maintenance standpoint, even if it isn't any speed
improvement.

And what about the 64-bit jiffies versus 32-bit tp->tso_deferred issue?
Should tso_deferred be made unsigned long to match jiffies?

						-Bill
