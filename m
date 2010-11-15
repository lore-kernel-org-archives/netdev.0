From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Mon, 15 Nov 2010 15:47:07 +0100
Message-ID: <1289832427.2607.84.camel@edumazet-laptop>
References: <1288975980.2882.877.camel@edumazet-laptop>
	 <20101105102038.53e36f9e.akpm@linux-foundation.org>
	 <1288980046.2882.1054.camel@edumazet-laptop>
	 <20101105110828.52f061b3.akpm@linux-foundation.org>
	 <1288981224.2882.1105.camel@edumazet-laptop>
	 <20101105112821.57f80481.akpm@linux-foundation.org>
	 <1288984844.2665.52.camel@edumazet-laptop>
	 <20101105195101.GC15561@linux.vnet.ibm.com>
	 <alpine.DEB.2.00.1011121313001.16754@router.home>
	 <20101113222612.GD2825@linux.vnet.ibm.com>
	 <alpine.DEB.2.00.1011150756130.19175@router.home>
	 <1289830636.2607.70.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1011150821000.19175@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	Nick Piggin <npiggin@kernel.dk>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011150821000.19175@router.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 15 novembre 2010 =C3=A0 08:25 -0600, Christoph Lameter a =C3=A9=
crit :
> On Mon, 15 Nov 2010, Eric Dumazet wrote:
>=20
> > Exclusive access ? As soon as another cpu takes it again, you lose.
>=20
> Sure but you want to avoid the fetch in shared mode here.
>=20

Yes, this is what cmpxchg() does for sure.

> > Its not really the same thing... Maybe you miss the 'hint' intentio=
n at
> > all. We know the probable value of the counter, we dont want to rea=
d it.
>=20
> Ok may be in thise case you can predict the value but in general it i=
s
> difficult to always provide an expected value. It would be easier to =
be
> able to tell the processor that the cacheline should not be fetched a=
s
> shared but immediately in exclusive state.
>=20

Maybe its not clear, but atomic_inc_not_zero_hint() is going to be used
only in contexts we know the expected value, and not as a generic
replacement for atomic_inc_not_zero(). Even if cache line is already ho=
t
in this cpu cache, it should be faster or same speed.

Then, in high contention contexts, using atomic_inc_not_zero_hint() wit=
h
whatever initial hint might also be a win over atomic_inc_not_zero(),
but we try to remove such contexts ;)

And two atomic_cmpxchg() are probably slower in non contended contexts,
in particular is cache line is already hot in this cpu cache.

> > atomic_read() and atomic_cmpxchg(). We tried prefetchw() and it was=
 a
> > performance drop. It was with only 16 cpus contending on neighbour
>=20
> Does prefetchw work? Andi claims that prefetchw is not working on
> x86 and I doubt that you ran tests on Itanium.

In fact, in benchmarks, prefetch() or prefetchw() are a pain on x86, or
at least "perf tools" show artifact on them (high number of cycles
consumed on these instructions)

Andi had a patch to disable prefetch() in list iterators, and its a win=
=2E

I dont have Itanium platform to run tests. Is cmpxchg() that bad on
ia64 ? I also have old AMD cpus, so I cannot say if recent ones handle
prefetchw() better...
