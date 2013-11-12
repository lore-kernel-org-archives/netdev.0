From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] random32: use msecs_to_jiffies for reseed timer
Date: Wed, 13 Nov 2013 00:47:10 +0100
Message-ID: <20131112234710.GI14929@order.stressinduktion.org>
References: <1384296342-3348-1-git-send-email-dborkman@redhat.com> <1384296342-3348-2-git-send-email-dborkman@redhat.com> <20131112153512.68520cca@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39364 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757460Ab3KLXrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 18:47:12 -0500
Content-Disposition: inline
In-Reply-To: <20131112153512.68520cca@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 12, 2013 at 03:35:12PM -0800, Stephen Hemminger wrote:
> On Tue, 12 Nov 2013 23:45:42 +0100
> Daniel Borkmann <dborkman@redhat.com> wrote:
> 
> > Use msecs_to_jiffies, for these calculations as different HZ
> > considerations are taken into account for conversion of the timer
> > shot, and also it makes the code more readable.
> > 
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  lib/random32.c | 8 ++++++--
> >  1 file changed, 6 insertions(+), 2 deletions(-)
> > 
> > diff --git a/lib/random32.c b/lib/random32.c
> > index 4f9d5df..1e5b2df 100644
> > --- a/lib/random32.c
> > +++ b/lib/random32.c
> > @@ -214,18 +214,22 @@ static DEFINE_TIMER(seed_timer, __prandom_timer, 0, 0);
> >  static void __prandom_timer(unsigned long dontcare)
> >  {
> >  	u32 entropy;
> > +	unsigned long expires;
> >  
> >  	get_random_bytes(&entropy, sizeof(entropy));
> >  	prandom_seed(entropy);
> > +
> >  	/* reseed every ~60 seconds, in [40 .. 80) interval with slack */
> > -	seed_timer.expires = jiffies + (40 * HZ + (prandom_u32() % (40 * HZ)));
> > +	expires = 40 + (prandom_u32() % 40);
> > +	seed_timer.expires = jiffies + msecs_to_jiffies(expires * MSEC_PER_SEC);
> > +
> >  	add_timer(&seed_timer);
> >  }
> >  
> >  static void __init __prandom_start_seed_timer(void)
> >  {
> >  	set_timer_slack(&seed_timer, HZ);
> > -	seed_timer.expires = jiffies + 40 * HZ;
> > +	seed_timer.expires = jiffies + msecs_to_jiffies(40 * MSEC_PER_SEC);
> >  	add_timer(&seed_timer);
> >  }
> >  
> 
> Some questions:
>  1. What is the point of using msecs_to_jiffies? the older code already handled
>     differing HZ?

The change is not that important. It seemed a bit more readable. We could
certainly drop that.

>  2. Why the magic 40-80 sec range? What about platforms with very low entropy
>     you will end up draining it faster.

Daniel and me had a discussion about that. I originally had it even lower and
Daniel warned about that. The current window seemd fine to me as we don't want
to have a too big window where one could probe ports if an attacker could find
a bias in the PRNG. Do you have a suggestion?

>  3. I prefer using mod_timer rather than setting expires and call add_timer

I wanted the BUG_ON in add_timer in the code path so we can make sure no
two timers are running concurrently. Would be no problem to change that.

>  4. You should also use round_jiffies to save power by making the wakeup on a second
>     boundary.

We already apply slack when initializing the timer:

static void prandom_start_seed_timer(void)
{
        set_timer_slack(&seed_timer, HZ);
        seed_timer.expires = jiffies + 40 * HZ;
        add_timer(&seed_timer);
}

It thus does get rounded by apply_slack in mod_timer.

Greetings,

  Hannes
