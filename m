From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Fri, 8 Nov 2013 15:28:56 +0100
Message-ID: <20131108142856.GA28330@order.stressinduktion.org>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com> <20131108130244.GE5876@order.stressinduktion.org> <1383919418.9412.234.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58189 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054Ab3KHO26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 09:28:58 -0500
Content-Disposition: inline
In-Reply-To: <1383919418.9412.234.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 08, 2013 at 06:03:38AM -0800, Eric Dumazet wrote:
> On Fri, 2013-11-08 at 14:02 +0100, Hannes Frederic Sowa wrote:
> 
> > If I understand the code correctly the UDP ports are fully randomized? This
> > is good as per-peer randomization and then incrementation seems to be
> > theoretically broken:
> > 
> > <https://sites.google.com/site/hayashulman/files/NIC-derandomisation.pdf>
> > 
> > Looking at the code I somehow would like to check the use of net_random there.
> > The prandom function is reseeded as late_initcall and then only seeded by some
> > network addresses.
> > 
> > At the time the late_initcall reseeds the PRNG my tests have shown that
> > the nonblockingpool was still not fully initialized where the PRNG gets
> > reseeded from.
> > 
> > Hm, I propose a patch which does reseed the pool as soon as the nonblocking
> > pool got credited enough entropy in credit_entropy_bits. This should help
> > later binds().
> 
> Or even better have a reseed every XX seconds.

Yes, that's even better.

> 
> Something like :
> 
> diff --git a/lib/random32.c b/lib/random32.c
> index 52280d5526be..4af2d72281e3 100644
> --- a/lib/random32.c
> +++ b/lib/random32.c
> @@ -60,6 +60,8 @@ u32 prandom_u32_state(struct rnd_state *state)
>  }
>  EXPORT_SYMBOL(prandom_u32_state);
>  
> +static DEFINE_PER_CPU(unsigned long, net_rand_shuffle);
> +
>  /**
>   *	prandom_u32 - pseudo random number generator
>   *
> @@ -71,6 +73,19 @@ u32 prandom_u32(void)
>  {
>  	unsigned long r;
>  	struct rnd_state *state = &get_cpu_var(net_rand_state);
> +
> +	if (unlikely(time_after(jiffies, net_rand_shuffle))) {
> +		unsigned long delay;
> +		u32 entropy;
> +
> +		get_random_bytes_arch(&entropy, sizeof(entropy));

What do you think about using a timer to keep the reseed out of fast-path
and switch to the non-arch get_random_bytes instead?

Thanks,

  Hannes
