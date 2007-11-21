From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] LRO ack aggregation
Date: Wed, 21 Nov 2007 01:15:53 -0500
Message-ID: <20071121011553.fa6fd0e8.billfink@mindspring.com>
References: <E1IuMIQ-0003gc-00@gondolin.me.apana.org.au>
	<20071119.222214.81458569.davem@davemloft.net>
	<4742C96D.3050203@myri.com>
	<20071120.035558.214794900.davem@davemloft.net>
	<4742E0A9.2070205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, ossthema@de.ibm.com
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:46909 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751955AbXKUGQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 01:16:12 -0500
In-Reply-To: <4742E0A9.2070205@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Nov 2007, Andrew Gallatin wrote:

> David Miller wrote:
>  > From: Andrew Gallatin <gallatin@myri.com>
>  > Date: Tue, 20 Nov 2007 06:47:57 -0500
>  >
>  >> David Miller wrote:
>  >>  > From: Herbert Xu <herbert@gondor.apana.org.au>
>  >>  > Date: Tue, 20 Nov 2007 14:09:18 +0800
>  >>  >
>  >>  >> David Miller <davem@davemloft.net> wrote:
>  >>  >>> Fundamentally, I really don't like this change, it batches to the
>  >>  >>> point where it begins to erode the natural ACK clocking of TCP, 
> and I
>  >>  >>> therefore am very likely to revert it before merging to Linus.

I have mixed feelings about this topic.  In general I agree with the
importance of maintaining the natural ACK clocking of TCP for normal
usage.  But there may also be some special cases that could benefit
significantly from such a new LRO pure ACK aggregation feature.  The
rest of my comments are in support of such a new feature, although
I haven't completely made up my own mind yet about the tradeoffs
involved in implementing such a new capability (good arguments are
being made on both sides).

>  >>  >> Perhaps make it a tunable that defaults to off?
>  >>  >
>  >>  > That's one idea.
>  >>
>  >> I'd certainly prefer the option to have a tunable to having our
>  >> customers see performance regressions when they switch to
>  >> the kernel's LRO.
>  >
>  > Please qualify this because by itself it's an inaccurate statement.
>  >
>  > It would cause a performance regression in situations where the is
>  > nearly no packet loss, no packet reordering, and the receiver has
>  > strong enough cpu power.

You are basically describing the HPC universe, which while not the
multitudes of the general Internet, is a very real and valid special
community of interest where maximum performance is critical.

For example, we're starting to see dynamic provisioning of dedicated
10-GigE lambda paths to meet various HPC requirements, just for the
purpose of insuring "nearly no packet loss, no packet reordering".
See for example Internet2's Dynamic Circuit Network (DCN).

In the general Internet case, many smaller flows tend to be aggregated
together up to perhaps a 10-GigE interface, while in the HPC universe,
there tend to be fewer, but much higher individual bandwidth flows.
But both are totally valid usage scenarios.  So a tunable that defaults
to off for the general case makes sense to me.

> Yes, a regression of nearly 1Gb/s in some cases as I mentioned
> when I submitted the patch.

Which is a significant performance penalty.  But the CPU savings may
be an even more important benefit.

> <....>
> 
>  > Show me something over real backbones, talking to hundres or thousands
>  > of clients scattered all over the world.  That's what people will be
>  > using these high end NICs for front facing services, and that's where
>  > loss happens and stretch ACKs hurt performance.

The HPC universe uses real backbones, just not the general Internet
backbones.  Their backbones are engineered to have the characteristics
required for enabling very high performance applications.

And if performance would take a hit in the general Internet 10-GigE
server case, and that's clearly documented and understood, I don't
see what incentive the distros would have to enable the tunable for
their normal users, since why would they want to cause poorer
performance relative to other distros that stuck with the recommended
default.  The special HPC users could easily enable the option if it
was desired and proven beneficial in their environment.

> I can't.  I think most 10GbE on endstations is used either in the
> sever room, or on dedicated links.  My experience with 10GbE users is
> limited to my interactions with people using our NICs who contact our
> support.  Of those, I can recall only a tiny handful who were using
> 10GbE on a normal internet facing connection (and the ones I dealt
> with were actually running a different OS).  The vast majority were in
> a well controlled, lossless environment.  It is quite ironic.  The
> very fact that I cannot provide you with examples of internet facing
> people using LRO (w/ack aggr) in more normal applications tends to
> support my point that most 10GbE users seem to be in lossless
> environments.

Most use of 10-GigE that I'm familiar with is related to the HPC
universe, but then that's the environment I work in.  I'm sure that
over time the use of 10-GigE in general Internet facing servers
will predominate, since that's where the great mass of users is.
But I would argue that that doesn't make it the sole usage arena
that matters.

>  > ACK stretching is bad bad bad for everything outside of some well
>  > controlled test network bubble.

It's not just for network bubbles.  That's where the technology tends
to first be shaken out, but the real goal is use in real-world,
production HPC environments.

> I just want those in the bubble to continue have the best performance
> possible in their situation.  If it is a tunable the defaults to off,
> that is great.

I totally agree, and think that the tunable (defaulting to off),
allows both the general Internet and HPC users to meet their goals.

> Hmm.. rather than a global tunable, what if it was a
> network driver managed tunable which toggled a flag in the
> lro_mgr features?  Would that be better?

I like that idea.  In some of the configurations I deal with, a system
might have a special 10-GigE interface connected to a dedicated 10-GigE
HPC network, and also a regular GigE normal Internet connection.  So
the new LRO feature could be enabled on the 10-GigE HPC interface and
left disabled on the normal GigE Internet interface.

						-Bill
