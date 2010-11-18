From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC PATCH] netfilter: remove the duplicate tables
Date: Fri, 19 Nov 2010 07:36:51 +0800
Message-ID: <AANLkTi=w8vvVNYMa5D-_4UDoVJABbvM9CVYjABrVoWPY@mail.gmail.com>
References: <1290091194-1590-1-git-send-email-xiaosuo@gmail.com> <1290095020.2781.203.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61765 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756263Ab0KRXhO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 18:37:14 -0500
In-Reply-To: <1290095020.2781.203.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 18, 2010 at 11:43 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 18 novembre 2010 =E0 22:39 +0800, Changli Gao a =E9crit :
>> As only xt_counters are private to each CPU, we don't need to mainta=
in
>> a whole individual table for each CPU.
>>
>> In the kernel space, we use the memory of ipt_entry.counters to save=
 a
>> pointer to a percpu xt_counters. When iptables runs, it only update =
the
>> counters on its own CPU.
>>
>> On non SMP platforms, no change is made.
>>
>> Only the code of iptables is converted. Thanks for reviews.
>>
>
> Changli
>
> I answered you a (difficult) work was in progress, still you post a
> patch that needs our review and time ? This is crazy.

Sorry for interrupt, and thanks for review. I posted this patch to
check if I was in the right direction.

>
> I am tempted to stop here. Oh well...
>
> Your way of allocating a percpu counter for each counter is a pure TL=
B
> and cache line blower (up to two cache lines per counter), not counti=
ng
> the time needed to load a new table with 10.000 entries. Some people
> still use scripts with hundred of calls to iptables.
>
> percpu_alloc() is not meant to be used thousand of times per second. =
It
> is not scalable.
>
> You consume 16 bytes per counter in the main table, while 4 bytes ind=
ex
> should be enough on SMP build. Most firewalls I know use two or four
> cpus at most.

I think we can't change the structure of ipt_entry, as it is exposed
to userspace as an ABI. Though there is no need to keep the same
structure in the kernel space, converting is a big work. :)

>
> They care about speed, not really because iptables duplicates table o=
n
> each cpu. By the way, not using NUMA can definitly hurt firewalls wit=
h
> many rules, unless you make sure the main table is vmalloced() with n=
ode
> distribution, not a single node. Even with this, this can hurt
> latencies.

This is what I worry about. I think only test can verify it.

>
> Allocating one contiguous percpu var for all counters is a must.
>
> Problem is : percpu alloc doesnt allow big allocations.
>
> #define PCPU_MIN_UNIT_SIZE =A0 =A0 =A0PFN_ALIGN(32 << 10)
>
> So max allocation is 32 Kbytes, thats 2048 'xt_counters' only.
> -> cannot really use pcpu-alloc, but a kmalloc_node() or vmalloc_node=
()
> per cpu
>

Thanks. I'll try.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
