From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] bridge: 64bit rx/tx counters
Date: Thu, 12 Aug 2010 23:47:37 +0200
Message-ID: <1281649657.2305.38.camel@edumazet-laptop>
References: <1276531162.2478.121.camel@edumazet-laptop>
	 <20100614.231412.39191304.davem@davemloft.net>
	 <1276596856.2541.84.camel@edumazet-laptop>
	 <1276598376.2541.93.camel@edumazet-laptop>
	 <20100809214740.c5d186d2.akpm@linux-foundation.org>
	 <1281615375.2494.20.camel@edumazet-laptop>
	 <20100812080731.c9456ef9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	Nick Piggin <npiggin@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59331 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754711Ab0HLVrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 17:47:42 -0400
Received: by wwj40 with SMTP id 40so2117659wwj.1
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 14:47:41 -0700 (PDT)
In-Reply-To: <20100812080731.c9456ef9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 12 ao=C3=BBt 2010 =C3=A0 08:07 -0700, Andrew Morton a =C3=A9cr=
it :=20
> On Thu, 12 Aug 2010 14:16:15 +0200 Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
>=20
> > > And all this open-coded per-cpu counter stuff added all over the =
place.
> > > Were percpu_counters tested or reviewed and found inadequate and =
unfixable?
> > > If so, please do tell.
> > >=20
> >=20
> > percpu_counters tries hard to maintain a view of the current value =
of
> > the (global) counter. This adds a cost because of a shared cache li=
ne
> > and locking. (__percpu_counter_sum() is not very scalable on big ho=
sts,
> > it locks the percpu_counter lock for a possibly long iteration)
>=20
> Could be.  Is percpu_counter_read_positive() unsuitable?
>=20

I bet most people want precise counters when doing 'ifconfig lo'

SNMP applications would be very surprised to get non increasing values
between two samples, or inexact values.

> >=20
> > For network stats we dont want to maintain this central value, we d=
o the
> > folding only when necessary.
>=20
> hm.  Well, why?  That big walk across all possible CPUs could be real=
ly
> expensive for some applications.  Especially if num_possible_cpus is
> much larger than num_online_cpus, which iirc can happen in
> virtualisation setups; probably it can happen in non-virtualised
> machines too.
>=20

Agreed.

> > And this folding has zero effect on
> > concurrent writers (counter updates)
>=20
> The fastpath looks a little expensive in the code you've added.  The
> write_seqlock() does an rmw and a wmb() and the stats inc is a 64-bit
> rmw whereas percpu_counters do a simple 32-bit add.  So I'd expect th=
at
> at some suitable batch value, percpu-counters are faster on 32-bit.=20
>=20

Hmm... 6 instructions (16 bytes of text) are a "little expensive" versu=
s
120 instructions if we use percpu_counter ?

=46ollowing code from drivers/net/loopback.c

	u64_stats_update_begin(&lb_stats->syncp);
	lb_stats->bytes +=3D len;
	lb_stats->packets++;
	u64_stats_update_end(&lb_stats->syncp);

maps on i386 to :

	ff 46 10             	incl   0x10(%esi)  // u64_stats_update_begin(&lb=
_stats->syncp);
	89 f8                	mov    %edi,%eax
	99                   	cltd  =20
	01 7e 08             	add    %edi,0x8(%esi)
	11 56 0c             	adc    %edx,0xc(%esi)
	83 06 01             	addl   $0x1,(%esi)
	83 56 04 00          	adcl   $0x0,0x4(%esi)
	ff 46 10             	incl   0x10(%esi) // u64_stats_update_end(&lb_st=
ats->syncp);


Exactly 6 added instructions compared to previous kernel (32bit
counters), only on 32bit hosts. These instructions are not expensive (n=
o
conditional branches, no extra register pressure) and access private cp=
u
data.

While two calls to __percpu_counter_add() add about 120 instructions,
even on 64bit hosts, wasting precious cpu cycles.



> They'll usually be slower on 64-bit, until that num_possible_cpus wal=
k
> bites you.
>=20

But are you aware we already fold SNMP values using for_each_possible()
macros, before adding 64bit counters ? Not related to 64bit stuff
really...

> percpu_counters might need some work to make them irq-friendly.  That
> bare spin_lock().
>=20
> btw, I worry a bit about seqlocks in the presence of interrupts:
>=20

Please note that nothing is assumed about interrupts and seqcounts

Both readers and writers must mask them if necessary.

In most situations, masking softirq is enough for networking cases
(updates are performed from softirq handler, reads from process context=
)

> static inline void write_seqcount_begin(seqcount_t *s)
> {
> 	s->sequence++;
> 	smp_wmb();
> }
>=20
> are we assuming that the ++ there is atomic wrt interrupts?  I think
> so.  Is that always true for all architectures, compiler versions, et=
c?
>=20

s->sequence++ is certainly not atomic wrt interrupts on RISC arches

> > For network stack, we also need to update two values, a packet coun=
ter
> > and a bytes counter. percpu_counter is not very good for the 'bytes
> > counter', since we would have to use a arbitrary big bias value.
>=20
> OK, that's a nasty problem for percpu-counters.
>=20
> > Using several percpu_counter would also probably use more cache lin=
es.
> >=20
> > Also please note this stuff is only needed for 32bit arches.=20
> >=20
> > Using percpu_counter would slow down network stack on modern arches=
=2E
>=20
> Was this ever quantified?

A single misplacement of dst refcount was responsible for a 25% tbench
slowdown on a small machine (8 cores). Without any lock, only atomic
operations on a shared cache line...

So I think we could easily quantify a big slow down adding two
percpu_counters add() in a driver fastpath and a 16 or 32 cores machine=
=2E
(It would be a revert of percpu stuff we added last years)

Improvements would be

0) Just forget about 64bit stuff on 32bit arches as we did from linux
0.99. People should not run 40Gb links on 32bit kernels :)

1) If we really want percpu_counter() stuff, find a way to make it
hierarchical or use a a very big BIAS (2^30 ?). And/Or reduce
percpu_counter_add() complexity for increasing unsigned counters.

2) Avoid the write_seqcount_begin()/end() stuff when a writer changes
only the low order parts of the 64bit counter.

   (ie maintain a 32bit percpu value, and only atomicaly touch the
shared upper 32bits (and the seqcount) when overflowing this 32bit
percpu value.

Not sure its worth the added conditional branch.

Thanks


