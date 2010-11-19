From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] netfilter: remove the duplicate tables
Date: Fri, 19 Nov 2010 12:29:40 +0100
Message-ID: <1290166180.3034.119.camel@edumazet-laptop>
References: <1290091194-1590-1-git-send-email-xiaosuo@gmail.com>
	 <1290095020.2781.203.camel@edumazet-laptop>
	 <alpine.LNX.2.01.1011191210290.29394@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1011191210290.29394@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 19 novembre 2010 =C3=A0 12:15 +0100, Jan Engelhardt a =C3=A9=
crit :

> Was it? Quoting Patrick from 24h prior to this post:
>=20
> |so patches to get rid of the table duplication are highly welcome.
>=20
> >still you post a patch that needs our review and time ? This is craz=
y.
>=20
> You do not need to do it, but I will happily look at this.
> Of course my observations are the same as yours:
>=20
> >Your way of allocating a percpu counter for each counter is a pure T=
LB
> >and cache line blower (up to two cache lines per counter), not count=
ing
> >the time needed to load a new table with 10.000 entries. Some people
> >still use scripts with hundred of calls to iptables.
>=20
> The two are statistically independent though. Even for a loaded=20
> ruleset, the TLB/DC miss accumulation will be desastrous - as I've fo=
und=20
> with linked-list rules/small allocs.
>=20
> >Allocating one contiguous percpu var for all counters is a must.
> >
> >Problem is : percpu alloc doesnt allow big allocations.
> >
> >#define PCPU_MIN_UNIT_SIZE      PFN_ALIGN(32 << 10)
> >
> >So max allocation is 32 Kbytes, thats 2048 'xt_counters' only.
> >-> cannot really use pcpu-alloc, but a kmalloc_node() or vmalloc_nod=
e()
> >per cpu
>=20
> .. as is already done for jumpstack ;-)

IMHO, the real problem is not the table duplication. We know that addin=
g
a level of indirection is going to hurt a lot because of cache misses.

Its the atomic op (spinlock) done for every packet, entering every
filter, with the conditional branch we do because of possible recursion=
=2E

per cpu variable, and spinlock... its really expensive.

Stephen tried an RCU conversion some time ago, that aborted because of
RCU drawbacks (too much memory was possibly waiting to be freed after a
grace period). Maybe RCU infrastructure is now ready to try again.

We should do what we did for u64 stats counters in network stack, using
the u64_stats_sync.h infrastructure. No more synchro between the thread=
s
running through rules, and one gathering counters. Better latencies in
particular.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
