From: Kees Cook <keescook@chromium.org>
Subject: Re: tip -ENOBOOT - bisected to locking/refcounts, x86/asm: Implement
 fast refcount overflow protection
Date: Thu, 31 Aug 2017 10:00:58 -0700
Message-ID: <CAGXu5jL8Ueuw-DLY+Hz8Jd7NgqgyaaN8OVDicFxmcjBhScebOA@mail.gmail.com>
References: <1503996623.8323.20.camel@gmx.de> <CAGXu5jLYHy6Damtg_Pc4=G76OUiMV3fcY9+Ru1-Lmiq6VWEgsw@mail.gmail.com>
 <1504025721.6024.25.camel@gmx.de> <1504030207.6560.0.camel@gmx.de>
 <CAGXu5jKSWiZ8NkgUqO6G8fs5R06bMtdFBmZz9MMX-HAk8nXXNw@mail.gmail.com>
 <1504069332.8352.3.camel@gmx.de> <CAGXu5jJim=r8b+y1qQXtuzm9fPyv1tp9ANebxbCc9ic2c83_Mg@mail.gmail.com>
 <1504113212.5852.6.camel@gmx.de> <CAGXu5jJd80-0PJvB51x9ZDETPSoAtRVQ7dQ6HWwd0DYpKBgPFA@mail.gmail.com>
 <1504115735.5852.11.camel@gmx.de> <CAGXu5j+BLj6_LPfKs-vts-mbyJHu8D--WrmWbiT8Zbt-iD65KA@mail.gmail.com>
 <CAGXu5j+neSYAqb8=r42=jQ0LsJTGjCSdpgc9Hv+ipyAFURbCdw@mail.gmail.com>
 <1504145389.23109.4.camel@gmx.de> <CAGXu5jLKXEDdSpxxVM5oHHUWKbSTozx4FZRn70bQm4tQAhMqUQ@mail.gmail.com>
 <1504149176.23109.9.camel@gmx.de> <CAGXu5j+uNU+wqWoCV+Kpdp+DQer4E3VuwO0mtXiW3Dtw_61QKA@mail.gmail.com>
 <CAGXu5jKYPp5D+YxtqrJXsi48UUbjfeREngsys-dU1eP4RnnL+w@mail.gmail.com> <1504187918.27500.16.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Peter Zijlstra <peterz@infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Network Development <netdev@vger.kernel.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504187918.27500.16.camel@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 6:58 AM, Mike Galbraith <efault@gmx.de> wrote:
> On Wed, 2017-08-30 at 21:10 -0700, Kees Cook wrote:
>> On Wed, Aug 30, 2017 at 9:01 PM, Kees Cook <keescook@chromium.org> wrote:
>> > On Wed, Aug 30, 2017 at 8:12 PM, Mike Galbraith <efault@gmx.de> wrote:
>> >> On Wed, 2017-08-30 at 19:27 -0700, Kees Cook wrote:
>> >>
>> >>> Interesting! Can you try with 633547973ffc3 ("net: convert
>> >>> sk_buff.users from atomic_t to refcount_t") reverted? I'll see if
>> >>> running haveged will help me trigger this on my system...
>> >>
>> >> With that (plus 230cd1279d001 fix to it) reverted, vbox boots.
>> >
>> > Wonderful! Thank you so much for helping track this down.
>> >
>> > So, it seems that sk_buff.users will need some more special attention
>> > before we can convert it to refcount.
>> >
>> > x86-refcount will saturate with refcount_dec_and_test() if the result
>> > is negative. But that would mean at least starting at 0. FULL should
>> > have WARNed in this case, so I remain slightly confused why it was
>> > missed by FULL.
>>
>> Actually, if this is a race condition it's possible that FULL is slow
>> enough to miss it...
>>
>> I bet something briefly takes the refcount negative, and with
>> unchecked atomics, it come back up positive again during the race.
>> FULL may miss the race, and x86-refcount will catch it and saturate...
>
> (gdb) list *in6_dev_get+0x1e
> 0xffffffff8166d3de is in in6_dev_get (./arch/x86/include/asm/refcount.h:52).
> 47                      : "cc", "cx");
> 48      }
> 49
> 50      static __always_inline void refcount_inc(refcount_t *r)
> 51      {
> 52              asm volatile(LOCK_PREFIX "incl %0\n\t"
> 53                      REFCOUNT_CHECK_LT_ZERO
> 54                      : [counter] "+m" (r->refs.counter)
> 55                      : : "cc", "cx");
> 56
>
> gdb) list *in6_dev_get+0x10
> 0xffffffff8166d3d0 is in in6_dev_get (./include/net/addrconf.h:318).
> 313     {
> 314             struct inet6_dev *idev;
> 315
> 316             rcu_read_lock();
> 317             idev = rcu_dereference(dev->ip6_ptr);
> 318             if (idev)
> 319                     refcount_inc(&idev->refcnt);
> 320             rcu_read_unlock();
> 321             return idev;
> 322
>
> That's from kernel with no revert, but your silent saturation patch
> still applied, AND built with gcc-6.3.1.  Kernel traps, but it boots
> and works, as does kernel built with gcc-7.0.1.  Remove your silent
> saturation patch, kernel doesn't notice a thing, just works.
>
> With gcc-4.8.5, trap means you're as good as dead, with the other two,
> trap means the intended.  Compiler, constraints, dark elves.. pick one.

Oh! So it's gcc-version sensitive? That's alarming. Is this mapping correct:

4.8.5: WARN, eventual kernel hang
6.3.1, 7.0.1: WARN, but continues working

> Full first splat from bootable gcc-6.3.1 built kernel.
>
> [    1.293962] NET: Registered protocol family 10
> [    1.294635] refcount_t silent saturation at in6_dev_get+0x25/0x104 in swapper/0[1], uid/euid: 0/0

That's an _increment_ saturation? Which means the result must be
negative, so it started from least -2.

> [    1.295616] ------------[ cut here ]------------
> [    1.296120] WARNING: CPU: 0 PID: 1 at kernel/panic.c:612 refcount_error_report+0x94/0x9e
> [    1.296950] Modules linked in:
> [    1.297276] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.13.0.g152d54a-tip-default #53
> [    1.299179] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
> [    1.300743] task: ffff88013ab84040 task.stack: ffffc9000062c000
> [    1.301825] RIP: 0010:refcount_error_report+0x94/0x9e
> [    1.302804] RSP: 0018:ffffc9000062fc10 EFLAGS: 00010282
> [    1.303791] RAX: 0000000000000055 RBX: ffffffff81a34274 RCX: ffffffff81c605e8
> [    1.304991] RDX: 0000000000000001 RSI: 0000000000000096 RDI: 0000000000000246
> [    1.306189] RBP: ffffc9000062fd58 R08: 0000000000000000 R09: 0000000000000175
> [    1.307392] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88013ab84040
> [    1.308583] R13: 0000000000000000 R14: 0000000000000004 R15: ffffffff81a256c8
> [    1.309768] FS:  0000000000000000(0000) GS:ffff88013fc00000(0000) knlGS:0000000000000000
> [    1.311052] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    1.312100] CR2: 00007f4631fe8df0 CR3: 0000000137d09003 CR4: 00000000001606f0
> [    1.313301] Call Trace:
> [    1.314012]  ex_handler_refcount+0x63/0x70
> [    1.314893]  fixup_exception+0x32/0x40
> [    1.315737]  do_trap+0x8c/0x170
> [    1.316519]  do_error_trap+0x70/0xd0
> [    1.317340]  ? in6_dev_get+0x23/0x104
> [    1.318172]  ? netlink_broadcast_filtered+0x2bd/0x430
> [    1.319156]  ? kmem_cache_alloc_trace+0xce/0x5d0
> [    1.320098]  ? set_debug_rodata+0x11/0x11
> [    1.320964]  invalid_op+0x1e/0x30
> [    1.322520] RIP: 0010:in6_dev_get+0x25/0x104
> [    1.323631] RSP: 0018:ffffc9000062fe00 EFLAGS: 00010202
> [    1.324614] RAX: ffff880137de2400 RBX: ffff880137df4600 RCX: ffff880137de24f0
> [    1.325793] RDX: ffff88013a5e4000 RSI: 00000000fffffe00 RDI: ffff88013a5e4000
> [    1.326964] RBP: 00000000000000d1 R08: 0000000000000000 R09: ffff880137de7600
> [    1.328150] R10: 0000000000000000 R11: ffff8801398a4df8 R12: 0000000000000000
> [    1.329374] R13: ffffffff82137872 R14: 014200ca00000000 R15: 0000000000000000
> [    1.330547]  ? set_debug_rodata+0x11/0x11
> [    1.331392]  ip6_route_init_special_entries+0x2a/0x89
> [    1.332369]  addrconf_init+0x9e/0x203
> [    1.333173]  inet6_init+0x1af/0x365
> [    1.333956]  ? af_unix_init+0x4e/0x4e
> [    1.334753]  do_one_initcall+0x4e/0x190
> [    1.335555]  ? set_debug_rodata+0x11/0x11
> [    1.336369]  kernel_init_freeable+0x189/0x20e
> [    1.337230]  ? rest_init+0xd0/0xd0
> [    1.337999]  kernel_init+0xa/0xf7
> [    1.338744]  ret_from_fork+0x25/0x30
> [    1.339500] Code: 48 8b 95 80 00 00 00 41 55 49 8d 8c 24 f0 0a 00 00 45 8b 84 24 10 09 00 00 41 89 c1 48 89 de 48 c7 c7 60 7a a3 81 e8 07 de 05 00 <0f> ff 58 5b 5d 41 5c 41 5d c3 0f 1f 44 00 00 55 48 89 e5 41 56
> [    1.342243] ---[ end trace b5d40c0fccce776c ]---

-Kees

-- 
Kees Cook
Pixel Security
