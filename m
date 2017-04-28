From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: rhashtable - Cap total number of entries to 2^31
Date: Fri, 28 Apr 2017 12:23:15 +0200
Message-ID: <acb22f3f-8286-01f2-e536-0ab44eb06b34@de.ibm.com>
References: <20170427054451.GA529@gondor.apana.org.au>
 <0cd0286d-b81d-7bf4-d345-7ef098b9a998@broadcom.com>
 <56843a86-9a09-16e8-acec-05a80396f282@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <56843a86-9a09-16e8-acec-05a80396f282@gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/28/2017 12:21 AM, Florian Fainelli wrote:
> On 04/27/2017 02:16 PM, Florian Fainelli wrote:
>> Hi Herbert,
>>
>> On 04/26/2017 10:44 PM, Herbert Xu wrote:
>>> On Tue, Apr 25, 2017 at 10:48:22AM -0400, David Miller wrote:
>>>> From: Florian Westphal <fw@strlen.de>
>>>> Date: Tue, 25 Apr 2017 16:17:49 +0200
>>>>
>>>>> I'd have less of an issue with this if we'd be talking about
>>>>> something computationally expensive, but this is about storing
>>>>> an extra value inside a struct just to avoid one "shr" in insert path...
>>>>
>>>> Agreed, this shift is probably filling an available cpu cycle :-)
>>>
>>> OK, but we need to have an extra field for another reason anyway.
>>> The problem is that we're not capping the total number of elements
>>> in the hashtable when max_size is not set, this means that nelems
>>> can overflow which will cause havoc with the automatic shrinking
>>> when it tries to fit 2^32 entries into a minimum-sized table.
>>>
>>> So I'm taking that hole back for now :)
>>>
>>> ---8<---
>>> When max_size is not set or if it set to a sufficiently large
>>> value, the nelems counter can overflow.  This would cause havoc
>>> with the automatic shrinking as it would then attempt to fit a
>>> huge number of entries into a tiny hash table.
>>>
>>> This patch fixes this by adding max_elems to struct rhashtable
>>> to cap the number of elements.  This is set to 2^31 as nelems is
>>> not a precise count.  This is sufficiently smaller than UINT_MAX
>>> that it should be safe.
>>>
>>> When max_size is set max_elems will be lowered to at most twice
>>> max_size as is the status quo.
>>>
>>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>>
>> This commit:
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=6d684e54690caef45cf14051ddeb7c71beeb681b
>>
>> makes my ARMv7 (32-bit) system panic on boot with the log below. I can
>> test net-next (or net) and report back if you want me to test anything.
>> Thanks!
> 
> And another on with a QEMU guest:
> 
> [    0.389212] NET: Registered protocol family 16
> [    0.388807] Kernel panic - not syncing: rtnetlink_init: cannot
> initialize rtnetlink
> [    0.388807]
> [    0.389445] CPU: 0 PID: 1 Comm: swapper/0 Not tainted
> 4.11.0-rc8-02077-ge221c1f0fe25 #1
> [    0.389745] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS Ubuntu-1.8.2-1ubuntu2 04/01/2014
> [    0.390219] Call Trace:
> [    0.391406]  dump_stack+0x51/0x78
> [    0.391585]  panic+0xc7/0x20e
> [    0.391740]  ? register_pernet_operations+0xa1/0xd0
> [    0.392031]  rtnetlink_init+0x22/0x1a0
> [    0.392190]  netlink_proto_init+0x168/0x184
> [    0.392359]  ? ptp_classifier_init+0x26/0x30
> [    0.392528]  ? netlink_net_init+0x2e/0x2e
> [    0.392692]  do_one_initcall+0x54/0x190
> [    0.392852]  ? parse_args+0x248/0x400
> [    0.393033]  kernel_init_freeable+0x127/0x1b6
> [    0.393208]  ? kernel_init_freeable+0x1b6/0x1b6
> [    0.393389]  ? rest_init+0x70/0x70
> [    0.393533]  kernel_init+0x9/0x100
> [    0.393676]  ret_from_fork+0x29/0x40
> [    0.394555] ---[ end Kernel panic - not syncing: rtnetlink_init:
> cannot initialize rtnetlink
> [    0.394555]
> 
> I traced this down to:
> 
> rtnetlink_net_init()
>   netlink_kernel_create()
>      netlink_insert()
> 	__netlink_insert()
> 	   rhashtable_lookup_insert_key()
> 	      __rhashtable_insert_fast()
>                 rht_grow_above_max()
> 
> And indeed we have:
> 
> ht->nelemts = 0
> ht->max_elems = 0
> 
> such that rht_grow_above_max() returns true.
> 
> With your commit we actually take this branch:
> 
> if (ht->p.max_size < ht->max_elems / 2)
> 	ht->max_elems = ht->p.max_size * 2;
> 
> since max_size = 0 we have max_elems = 0 as well.
> 
> Candidate fix #1:
> 
> diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
> index 45f89369c4c8..ad9020e1609c 100644
> --- a/include/linux/rhashtable.h
> +++ b/include/linux/rhashtable.h
> @@ -329,7 +329,7 @@ static inline bool rht_grow_above_100(const struct
> rhashtable *ht,
>  static inline bool rht_grow_above_max(const struct rhashtable *ht,
>                                       const struct bucket_table *tbl)
>  {
> -       return atomic_read(&ht->nelems) >= ht->max_elems;
> +       return ht->p.max_size && atomic_read(&ht->nelems) >= ht->max_elems;
>  }
> 
> Candidate fix #2:
> 
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 751630bbe409..6b4f07760fec 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -963,7 +963,7 @@ int rhashtable_init(struct rhashtable *ht,
> 
>         /* Cap total entries at 2^31 to avoid nelems overflow. */
>         ht->max_elems = 1u << 31;
> -       if (ht->p.max_size < ht->max_elems / 2)
> +       if (ht->p.max_size && (ht->p.max_size < ht->max_elems / 2))
>                 ht->max_elems = ht->p.max_size * 2;
> 
>         ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
> 
> Number #2 does not introduce an additional conditional on the fastpath,
> so I suppose that would be what we would prefer?
> 
>>
>> [    0.158619] futex hash table entries: 1024 (order: 4, 65536 bytes)
>> [    0.166386] NET: Registered protocol family 16
>> [    0.179596] Kernel panic - not syncing: rtnetlink_init: cannot
>> initialize rtnetlink
>> [    0.179596]
>> [    0.189350] CPU: 0 PID: 1 Comm: swapper/0 Not tainted
>> 4.11.0-rc8-02028-g6d684e54690c #37
>> [    0.197908] Hardware name: Broadcom STB (Flattened Device Tree)
>> [    0.204254] [<c020fa18>] (unwind_backtrace) from [<c020b294>]
>> (show_stack+0x10/0x14)
>> [    0.212447] [<c020b294>] (show_stack) from [<c04bc454>]
>> (dump_stack+0x90/0xa4)
>> [    0.220144] [<c04bc454>] (dump_stack) from [<c02ab684>]
>> (panic+0xf0/0x270)
>> [    0.227460] [<c02ab684>] (panic) from [<c0c2705c>]
>> (rtnetlink_init+0x24/0x1d4)
>> [    0.235145] [<c0c2705c>] (rtnetlink_init) from [<c0c27630>]
>> (netlink_proto_init+0x124/0x148)
>> [    0.244124] [<c0c27630>] (netlink_proto_init) from [<c02017f8>]
>> (do_one_initcall+0x40/0x168)
>> [    0.253072] [<c02017f8>] (do_one_initcall) from [<c0c00dfc>]
>> (kernel_init_freeable+0x164/0x200)
>> [    0.262304] [<c0c00dfc>] (kernel_init_freeable) from [<c087bfd8>]
>> (kernel_init+0x8/0x110)
>> [    0.270970] [<c087bfd8>] (kernel_init) from [<c0207fa8>]
>> (ret_from_fork+0x14/0x2c)
>> [    0.279014] CPU1: stopping
>> [    0.281916] CPU: 1 PID: 0 Comm: swapper/1 Not tainted
>> 4.11.0-rc8-02028-g6d684e54690c #37
>> [    0.290499] Hardware name: Broadcom STB (Flattened Device Tree)
>> [    0.296796] [<c020fa18>] (unwind_backtrace) from [<c020b294>]
>> (show_stack+0x10/0x14)
>> [    0.305018] [<c020b294>] (show_stack) from [<c04bc454>]
>> (dump_stack+0x90/0xa4)
>> [    0.312684] [<c04bc454>] (dump_stack) from [<c020e984>]
>> (handle_IPI+0x170/0x190)
>> [    0.320531] [<c020e984>] (handle_IPI) from [<c020144c>]
>> (gic_handle_irq+0x88/0x8c)
>> [    0.328586] [<c020144c>] (gic_handle_irq) from [<c020bd78>]
>> (__irq_svc+0x58/0x74)
>> [    0.336543] Exception stack(0xee055f68 to 0xee055fb0)
>> [    0.341938] 5f60:                   00000001 00000000 ee055fc0
>> c0219b60 ee054000 c1603cc8
>> [    0.350661] 5f80: c1603c6c 00000000 00000000 c1486188 ee055fc0
>> c1603cd4 c1483408 ee055fb8
>> [    0.359323] 5fa0: c0208a40 c0208a44 60000013 ffffffff
>> [    0.364745] [<c020bd78>] (__irq_svc) from [<c0208a44>]
>> (arch_cpu_idle+0x38/0x3c)
>> [    0.372613] [<c0208a44>] (arch_cpu_idle) from [<c0255e98>]
>> (do_idle+0x168/0x204)
>> [    0.380479] [<c0255e98>] (do_idle) from [<c02561ac>]
>> (cpu_startup_entry+0x18/0x1c)
>> [    0.388493] [<c02561ac>] (cpu_startup_entry) from [<002014ec>] (0x2014ec)
>> [    0.395687] CPU3: stopping
>> [    0.398606] CPU: 3 PID: 0 Comm: swapper/3 Not tainted
>> 4.11.0-rc8-02028-g6d684e54690c #37
>> [    0.407242] Hardware name: Broadcom STB (Flattened Device Tree)
>> [    0.413564] [<c020fa18>] (unwind_backtrace) from [<c020b294>]
>> (show_stack+0x10/0x14)
>> [    0.421795] [<c020b294>] (show_stack) from [<c04bc454>]
>> (dump_stack+0x90/0xa4)
>> [    0.429495] [<c04bc454>] (dump_stack) from [<c020e984>]
>> (handle_IPI+0x170/0x190)
>> [    0.437394] [<c020e984>] (handle_IPI) from [<c020144c>]
>> (gic_handle_irq+0x88/0x8c)
>> [    0.445475] [<c020144c>] (gic_handle_irq) from [<c020bd78>]
>> (__irq_svc+0x58/0x74)
>> [    0.453406] Exception stack(0xee059f68 to 0xee059fb0)
>> [    0.458792] 9f60:                   00000001 00000000 ee059fc0
>> c0219b60 ee058000 c1603cc8
>> [    0.467489] 9f80: c1603c6c 00000000 00000000 c1486188 ee059fc0
>> c1603cd4 c1483408 ee059fb8
>> [    0.476177] 9fa0: c0208a40 c0208a44 60000013 ffffffff
>> [    0.481581] [<c020bd78>] (__irq_svc) from [<c0208a44>]
>> (arch_cpu_idle+0x38/0x3c)
>> [    0.489474] [<c0208a44>] (arch_cpu_idle) from [<c0255e98>]
>> (do_idle+0x168/0x204)
>> [    0.497331] [<c0255e98>] (do_idle) from [<c02561ac>]
>> (cpu_startup_entry+0x18/0x1c)
>> [    0.505369] [<c02561ac>] (cpu_startup_entry) from [<002014ec>] (0x2014ec)
>> [    0.512562] CPU2: stopping
>> [    0.515463] CPU: 2 PID: 0 Comm: swapper/2 Not tainted
>> 4.11.0-rc8-02028-g6d684e54690c #37
>> [    0.524047] Hardware name: Broadcom STB (Flattened Device Tree)
>> [    0.530368] [<c020fa18>] (unwind_backtrace) from [<c020b294>]
>> (show_stack+0x10/0x14)
>> [    0.538573] [<c020b294>] (show_stack) from [<c04bc454>]
>> (dump_stack+0x90/0xa4)
>> [    0.546195] [<c04bc454>] (dump_stack) from [<c020e984>]
>> (handle_IPI+0x170/0x190)
>> [    0.554050] [<c020e984>] (handle_IPI) from [<c020144c>]
>> (gic_handle_irq+0x88/0x8c)
>> [    0.562096] [<c020144c>] (gic_handle_irq) from [<c020bd78>]
>> (__irq_svc+0x58/0x74)
>> [    0.570044] Exception stack(0xee057f68 to 0xee057fb0)
>> [    0.575465] 7f60:                   00000001 00000000 ee057fc0
>> c0219b60 ee056000 c1603cc8
>> [    0.584145] 7f80: c1603c6c 00000000 00000000 c1486188 ee057fc0
>> c1603cd4 c1483408 ee057fb8
>> [    0.592806] 7fa0: c0208a40 c0208a44 60000013 ffffffff
>> [    0.598220] [<c020bd78>] (__irq_svc) from [<c0208a44>]
>> (arch_cpu_idle+0x38/0x3c)
>> [    0.606103] [<c0208a44>] (arch_cpu_idle) from [<c0255e98>]
>> (do_idle+0x168/0x204)
>> [    0.613960] [<c0255e98>] (do_idle) from [<c02561ac>]
>> (cpu_startup_entry+0x18/0x1c)
>> [    0.621990] [<c02561ac>] (cpu_startup_entry) from [<002014ec>] (0x2014ec)
>> [    0.629201] ---[ end Kernel panic - not syncing: rtnetlink_init:
>> cannot initialize rtnetlink
>> [    0.629201]
>>
> 
> 

I can reproduce this boot failure on s390 bisected to 
commit 6d684e54690caef45cf14051ddeb7c71beeb681b
   rhashtable: Cap total number of entries to 2^31
in linux-next from Apr 28

[    0.452478] NET: Registered protocol family 16
[    0.477867] Kernel panic - not syncing: rtnetlink_init: cannot initialize rtnetlink
[    0.477867] 
[    0.477869] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.11.0-rc8-02028-g6d684e5 #490
[    0.477870] Hardware name: IBM              2964 NC9              704              (KVM)
[    0.477871] Stack:
[    0.477871]        00000002743efb30 00000002743efbc0 0000000000000003 0000000000000000
[    0.477873]        00000002743efc60 00000002743efbd8 00000002743efbd8 0000000000000020
[    0.477875]        0000000000f4444e 0000000000000020 000000000000000a 000000000000000a
[    0.477877]        000000000000000c 00000002743efc28 0000000000000000 0000000000000000
[    0.477878]        0000000000958d60 00000000001125c4 00000002743efbc0 00000002743efc18
[    0.477880] Call Trace:
[    0.477882] ([<000000000011247a>] show_trace+0x62/0x78)
[    0.477883]  [<0000000000112568>] show_stack+0x68/0xe0 
[    0.477886]  [<0000000000687d46>] dump_stack+0x7e/0xb0 
[    0.477887]  [<000000000028353c>] panic+0x104/0x240 
[    0.477890]  [<0000000000ea9934>] rtnetlink_init+0x3c/0x1b8 
[    0.477951]  [<0000000000eab500>] netlink_proto_init+0x170/0x198 
[    0.477953]  [<000000000010024c>] do_one_initcall+0x4c/0x148 
[    0.477954]  [<0000000000e59d3a>] kernel_init_freeable+0x1ea/0x2a0 
[    0.477957]  [<000000000094404a>] kernel_init+0x2a/0x148 
[    0.477959]  [<000000000094e35e>] kernel_thread_starter+0x6/0xc 
[    0.477960]  [<000000000094e358>] kernel_thread_starter+0x0/0xc 
