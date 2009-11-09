From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: SAD entries do not expire correctly after
	suspend-resume
Date: Mon, 9 Nov 2009 10:39:10 -0500
Message-ID: <20091109153910.GA8039@gondor.apana.org.au>
References: <20091108211249.2ecdfd38@penta.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, peterz@infradead.org,
	yoshfuji@linux-ipv6.org, tglx@linutronix.de, mingo@elte.hu
To: Yury Polyanskiy <ypolyans@princeton.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43252 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755571AbZKIPjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 10:39:13 -0500
Content-Disposition: inline
In-Reply-To: <20091108211249.2ecdfd38@penta.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yury Polyanskiy <ypolyans@princeton.edu> wrote:
> 
>  This fixes the following bug in the current implementation of
> net/xfrm: SAD entries timeouts do not count the time spent by the machine 
> in the suspended state. This leads to the connectivity problems because 
> after resuming local machine thinks that the SAD entry is still valid, while 
> it has already been expired on the remote server.
> 
>  The cause of this is very simple: the timeouts in the net/xfrm are bound to 
> the old mod_timer() timers. This patch reassigns them to the
> CLOCK_REALTIME hrtimer.
> 
>  I have been using this version of the patch for a few months on my
> machines without any problems. Also run a few stress tests w/o any
> issues.
> 
>  This version of the patch uses tasklet_hrtimer by Peter Zijlstra
> (commit 9ba5f0).
> 
>  This patch is against 2.6.31.4. Please CC me.
> 
> Signed-off-by: Yury Polyanskiy <polyanskiy@gmail.com>

Thanks for the patch.

However, I have some reservations as to whether this is the ideal
situation.  Unless I'm mistaken, this patch may cause IPsec SAs
to expire if the system clock was out of sync prior to IPsec startup
and is subsequently resynced by ntpdate or similar.

For example, it's quite common for clocks to be out-of-sync by
10 hours in Australia due to time zone issues with BIOS clocks.
So potentially ntpdate could move the clock forward by 10 hours
or more on bootup thus causing IPsec SAs to expire prematurely
with this patch.

This shouldn't really be a problem in itself except that there
are some dodgy IPsec gateways out there that refuse to reestablish
IPsec SAs if the interval between two successive connections is
too small.  This could render the SA inoperable for hours.

So the upshot of all this is that we definitely want the effect
of this patch for suspend/resume, but it would be great if we can
avoid it for settimeofday(2).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
