From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Fri, 23 Jun 2006 08:43:02 +1000
Message-ID: <20060622224302.GA10136@gondor.apana.org.au>
References: <20060619121519.GA16031@gondor.apana.org.au> <1150724031.5815.39.camel@jzny2> <20060619134227.GA16662@gondor.apana.org.au> <1150727009.5815.72.camel@jzny2> <20060619142928.GA17191@gondor.apana.org.au> <1150727810.5815.78.camel@jzny2> <20060619223326.GA20354@gondor.apana.org.au> <1150814526.5270.64.camel@jzny2> <20060620235207.GA31493@gondor.apana.org.au> <1151004682.5392.97.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:14603 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750769AbWFVWnX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 18:43:23 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151004682.5392.97.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 03:31:22PM -0400, jamal wrote:
> 
> Your gut feeling is for #1 and my worry is for #2 ;->
> I actually think your change is obviously valuable for scenarios where
> the bus is slower and therefore transmits take longer - my feeling is it
> may not be beneficial for fast buses like PCI-E or high speed PCI/X
> where the possibility of getting access tx collision is lower.

Sure.  However, I still don't see the point of transmitting in parallel
even there.  The reason is that there is no work being done here by the
CPU between dequeueing the packet and obtaining the TX lock.  As such
the cost of doing it in parallel is going to be dominated by the cache
bouncing.

Obviously it is a little different for lockless drivers where we do
dev_queue_xmit_nit (and now GSO) without any locks.  However, you don't
want parallelism there because it breaks packet ordering.

> The other reason I mentioned earlier as justification to leave the
> granularity at the level where it was is for good qos clocking. i.e
> to allow incoming packets to be used to clock the tx path - otherwise
> you will be dependent on HZ for your egress rate accuracy. I am not sure
> if this later point made sense - I could elaborate.

I don't understand where HZ comes in.  If you find that qdisc_run is
already running, then the packet you've just queued will most likely
be processed by that qdisc_run immediately unless the device is full.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
