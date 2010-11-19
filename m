From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC PATCH] netfilter: remove the duplicate tables
Date: Fri, 19 Nov 2010 12:15:06 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011191210290.29394@obet.zrqbmnf.qr>
References: <1290091194-1590-1-git-send-email-xiaosuo@gmail.com> <1290095020.2781.203.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290095020.2781.203.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2010-11-18 16:43, Eric Dumazet wrote:

>Le jeudi 18 novembre 2010 =C3=A0 22:39 +0800, Changli Gao a =C3=A9crit=
 :
>> As only xt_counters are private to each CPU, we don't need to mainta=
in
>> a whole individual table for each CPU.
>>=20
>> In the kernel space, we use the memory of ipt_entry.counters to save=
 a
>> pointer to a percpu xt_counters. When iptables runs, it only update =
the
>> counters on its own CPU.
>>=20
>> On non SMP platforms, no change is made.
>>=20
>> Only the code of iptables is converted. Thanks for reviews.
>>=20
>
>Changli
>
>I answered you a (difficult) work was in progress

Was it? Quoting Patrick from 24h prior to this post:

|so patches to get rid of the table duplication are highly welcome.

>still you post a patch that needs our review and time ? This is crazy.

You do not need to do it, but I will happily look at this.
Of course my observations are the same as yours:

>Your way of allocating a percpu counter for each counter is a pure TLB
>and cache line blower (up to two cache lines per counter), not countin=
g
>the time needed to load a new table with 10.000 entries. Some people
>still use scripts with hundred of calls to iptables.

The two are statistically independent though. Even for a loaded=20
ruleset, the TLB/DC miss accumulation will be desastrous - as I've foun=
d=20
with linked-list rules/small allocs.

>Allocating one contiguous percpu var for all counters is a must.
>
>Problem is : percpu alloc doesnt allow big allocations.
>
>#define PCPU_MIN_UNIT_SIZE      PFN_ALIGN(32 << 10)
>
>So max allocation is 32 Kbytes, thats 2048 'xt_counters' only.
>-> cannot really use pcpu-alloc, but a kmalloc_node() or vmalloc_node(=
)
>per cpu

=2E. as is already done for jumpstack ;-)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
