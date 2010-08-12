From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH net-next-2.6] bridge: 64bit rx/tx counters
Date: Thu, 12 Aug 2010 08:07:31 -0700
Message-ID: <20100812080731.c9456ef9.akpm@linux-foundation.org>
References: <1276531162.2478.121.camel@edumazet-laptop>
	<20100614.231412.39191304.davem@davemloft.net>
	<1276596856.2541.84.camel@edumazet-laptop>
	<1276598376.2541.93.camel@edumazet-laptop>
	<20100809214740.c5d186d2.akpm@linux-foundation.org>
	<1281615375.2494.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	Nick Piggin <npiggin@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54830 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759790Ab0HLPGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 11:06:13 -0400
In-Reply-To: <1281615375.2494.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Aug 2010 14:16:15 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > And all this open-coded per-cpu counter stuff added all over the place.
> > Were percpu_counters tested or reviewed and found inadequate and unfixable?
> > If so, please do tell.
> > 
> 
> percpu_counters tries hard to maintain a view of the current value of
> the (global) counter. This adds a cost because of a shared cache line
> and locking. (__percpu_counter_sum() is not very scalable on big hosts,
> it locks the percpu_counter lock for a possibly long iteration)

Could be.  Is percpu_counter_read_positive() unsuitable?

> 
> For network stats we dont want to maintain this central value, we do the
> folding only when necessary.

hm.  Well, why?  That big walk across all possible CPUs could be really
expensive for some applications.  Especially if num_possible_cpus is
much larger than num_online_cpus, which iirc can happen in
virtualisation setups; probably it can happen in non-virtualised
machines too.

> And this folding has zero effect on
> concurrent writers (counter updates)

The fastpath looks a little expensive in the code you've added.  The
write_seqlock() does an rmw and a wmb() and the stats inc is a 64-bit
rmw whereas percpu_counters do a simple 32-bit add.  So I'd expect that
at some suitable batch value, percpu-counters are faster on 32-bit. 

They'll usually be slower on 64-bit, until that num_possible_cpus walk
bites you.

percpu_counters might need some work to make them irq-friendly.  That
bare spin_lock().

btw, I worry a bit about seqlocks in the presence of interrupts:

static inline void write_seqcount_begin(seqcount_t *s)
{
	s->sequence++;
	smp_wmb();
}

are we assuming that the ++ there is atomic wrt interrupts?  I think
so.  Is that always true for all architectures, compiler versions, etc?

> For network stack, we also need to update two values, a packet counter
> and a bytes counter. percpu_counter is not very good for the 'bytes
> counter', since we would have to use a arbitrary big bias value.

OK, that's a nasty problem for percpu-counters.

> Using several percpu_counter would also probably use more cache lines.
> 
> Also please note this stuff is only needed for 32bit arches. 
> 
> Using percpu_counter would slow down network stack on modern arches.

Was this ever quantified?

> 
> I am very well aware of the percpu_counter stuff, I believe I tried to
> optimize it a bit in the past.
