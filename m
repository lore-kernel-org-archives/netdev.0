From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] netfilter: remove the duplicate tables
Date: Thu, 18 Nov 2010 16:43:40 +0100
Message-ID: <1290095020.2781.203.camel@edumazet-laptop>
References: <1290091194-1590-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290091194-1590-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 18 novembre 2010 =C3=A0 22:39 +0800, Changli Gao a =C3=A9crit =
:
> As only xt_counters are private to each CPU, we don't need to maintai=
n
> a whole individual table for each CPU.
>=20
> In the kernel space, we use the memory of ipt_entry.counters to save =
a
> pointer to a percpu xt_counters. When iptables runs, it only update t=
he
> counters on its own CPU.
>=20
> On non SMP platforms, no change is made.
>=20
> Only the code of iptables is converted. Thanks for reviews.
>=20

Changli

I answered you a (difficult) work was in progress, still you post a
patch that needs our review and time ? This is crazy.

I am tempted to stop here. Oh well...

Your way of allocating a percpu counter for each counter is a pure TLB
and cache line blower (up to two cache lines per counter), not counting
the time needed to load a new table with 10.000 entries. Some people
still use scripts with hundred of calls to iptables.

percpu_alloc() is not meant to be used thousand of times per second. It
is not scalable.

You consume 16 bytes per counter in the main table, while 4 bytes index
should be enough on SMP build. Most firewalls I know use two or four
cpus at most.

They care about speed, not really because iptables duplicates table on
each cpu. By the way, not using NUMA can definitly hurt firewalls with
many rules, unless you make sure the main table is vmalloced() with nod=
e
distribution, not a single node. Even with this, this can hurt
latencies.

Allocating one contiguous percpu var for all counters is a must.

Problem is : percpu alloc doesnt allow big allocations.

#define PCPU_MIN_UNIT_SIZE      PFN_ALIGN(32 << 10)

So max allocation is 32 Kbytes, thats 2048 'xt_counters' only.
-> cannot really use pcpu-alloc, but a kmalloc_node() or vmalloc_node()
per cpu



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
