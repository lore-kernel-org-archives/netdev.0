From: Tejun Heo <tj@kernel.org>
Subject: Re: OOM when adding ipv6 route:  How to make available more per-cpu
 memory?
Date: Sat, 06 Nov 2010 10:11:44 +0100
Message-ID: <4CD51BD0.8040609@kernel.org>
References: <4CD43C87.5040403@candelatech.com>	 <1288980361.2882.1070.camel@edumazet-laptop>	 <4CD449A5.5070305@candelatech.com>	 <1288988403.2665.268.camel@edumazet-laptop> <1288995103.2665.653.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288995103.2665.653.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 11/05/2010 11:11 PM, Eric Dumazet wrote:
> Le vendredi 05 novembre 2010 =C3=A0 21:20 +0100, Eric Dumazet a =C3=A9=
crit :
>> Your vmalloc space is very fragmented. pcpu_get_vm_areas() want
>> hugepages (4MB on your machine, 2MB on mine because I have
>> CONFIG_HIGHMEM64G=3Dy)
>=20
> Well, this is wrong. We use normal (4KB) pages, unfortunately.
>
> I have a NUMA machine, with two nodes, so pcpu_get_vm_areas() allocat=
es
> two zones, one for each node, with a 'known' offset between them.
> Then, 4KB pages are allocated to populate the zone when needed.
>=20
> # grep pcpu_get_vm_areas /proc/vmallocinfo=20
> 0xffffe8ffa0400000-0xffffe8ffa0600000 2097152 pcpu_get_vm_areas+0x0/0=
x740 vmalloc
> 0xffffe8ffffc00000-0xffffe8ffffe00000 2097152 pcpu_get_vm_areas+0x0/0=
x740 vmalloc
>=20
> BTW, we dont have the number of pages currently allocated in each
> 'vmalloc' zone, and/or node information.
>=20
> Tejun, do you have plans to use hugepages eventually ?
> (and fallback to 4KB pages, but most percpu data are allocated right
> after boot)

Well, it's rather complicated.  Till now, the percpu usage hasn't
justified allocating hugepages but it might someday, but more
importantly the reason why those big chunks of address space are used
is to keep the first chunk embedded in the regular linear kernel
address space to avoid extra TLB pressure.

On configurations where vmalloc area is a scarce resource,
percpu_alloc=3Dpage can be specified to use page-mapped allocation.
This will use much smaller chunks in vmalloc area at the cost of
additional 4k page TLB pressure for percpu memory in the first chunk
(all the static percpu variables and then some).

pcpu_embed_first_chunk() contains heuristic which makes it yield to
page allocator but the parameter is pretty generous (maximum distance
between chunks > 75% of vmalloc area).  It's there just to avoid
completely crazy cases.  Also, x86 setup_per_cpu_areas() chooses page
allocator on 32bit NUMAs.  This case didn't trigger either.  We
probably need to add another condition.

That large machine on 32bit is bound to be flaky.  To be short on
virtual address space is a pretty silly and stupid thing.  Anyways,
any good idea on what criteria we could test?

Thanks.

--=20
tejun
