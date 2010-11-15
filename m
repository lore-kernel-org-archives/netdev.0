From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Mon, 15 Nov 2010 15:17:16 +0100
Message-ID: <1289830636.2607.70.camel@edumazet-laptop>
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
In-Reply-To: <alpine.DEB.2.00.1011150756130.19175@router.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 15 novembre 2010 =C3=A0 07:57 -0600, Christoph Lameter a =C3=A9=
crit :
> On Sat, 13 Nov 2010, Paul E. McKenney wrote:
>=20
> > On Fri, Nov 12, 2010 at 01:14:12PM -0600, Christoph Lameter wrote:
> > >
> > > prefetchw() would be too much overhead?
> >
> > No idea.  Where do you believe that prefetchw() should be added?
>=20
> It is another way to get an exclusive cache line
> for situations like this. No need to give a hint.
>=20

Exclusive access ? As soon as another cpu takes it again, you lose.

Its not really the same thing... Maybe you miss the 'hint' intention at
all. We know the probable value of the counter, we dont want to read it=
=2E

In fact, prefetchw() is useful when you can assert it many cycles befor=
e
the memory read you are going to perform [before the write]. On
contended cache lines, its a waste, because by the time your cpu is
going to read memory, then perform the atomic compare_and_exchange(), a=
n
other cpu might have dirtied the location again. This is what we notice=
d
during Netfilter Workshop 2010 : A high performance cost at both
atomic_read() and atomic_cmpxchg(). We tried prefetchw() and it was a
performance drop. It was with only 16 cpus contending on neighbour
refcnt, and 5 millions frames per second (5 millions atomic increments,
5 millions atomic decrements)

prefetchw() should be used on very specific spots, when a cpu is going
to write into a private area (not potentially accessed by other cpus).
We use it for example in __alloc_skb(), a bit before memset().

By the way, atomic_inc_not_zero_hint() is less code than=20
[prefetchw(), atomic_inc_not_zero()]. Using one instruction [cmpxchg]
with the memory pointer is better than three.  [prefetchw(), read(),
cmpxchg()], particularly if you have high contention on cache line.
