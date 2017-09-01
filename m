From: Mike Galbraith <efault@gmx.de>
Subject: Re: tip -ENOBOOT - bisected to locking/refcounts, x86/asm:
 Implement fast refcount overflow protection
Date: Fri, 01 Sep 2017 08:57:50 +0200
Message-ID: <1504249070.17604.20.camel@gmx.de>
References: <1503996623.8323.20.camel@gmx.de>
         <CAGXu5jLYHy6Damtg_Pc4=G76OUiMV3fcY9+Ru1-Lmiq6VWEgsw@mail.gmail.com>
         <1504025721.6024.25.camel@gmx.de> <1504030207.6560.0.camel@gmx.de>
         <CAGXu5jKSWiZ8NkgUqO6G8fs5R06bMtdFBmZz9MMX-HAk8nXXNw@mail.gmail.com>
         <1504069332.8352.3.camel@gmx.de>
         <CAGXu5jJim=r8b+y1qQXtuzm9fPyv1tp9ANebxbCc9ic2c83_Mg@mail.gmail.com>
         <1504113212.5852.6.camel@gmx.de>
         <CAGXu5jJd80-0PJvB51x9ZDETPSoAtRVQ7dQ6HWwd0DYpKBgPFA@mail.gmail.com>
         <1504115735.5852.11.camel@gmx.de>
         <CAGXu5j+BLj6_LPfKs-vts-mbyJHu8D--WrmWbiT8Zbt-iD65KA@mail.gmail.com>
         <CAGXu5j+neSYAqb8=r42=jQ0LsJTGjCSdpgc9Hv+ipyAFURbCdw@mail.gmail.com>
         <1504145389.23109.4.camel@gmx.de>
         <CAGXu5jLKXEDdSpxxVM5oHHUWKbSTozx4FZRn70bQm4tQAhMqUQ@mail.gmail.com>
         <1504149176.23109.9.camel@gmx.de>
         <CAGXu5j+uNU+wqWoCV+Kpdp+DQer4E3VuwO0mtXiW3Dtw_61QKA@mail.gmail.com>
         <CAGXu5jKYPp5D+YxtqrJXsi48UUbjfeREngsys-dU1eP4RnnL+w@mail.gmail.com>
         <1504187918.27500.16.camel@gmx.de>
         <CAGXu5jL8Ueuw-DLY+Hz8Jd7NgqgyaaN8OVDicFxmcjBhScebOA@mail.gmail.com>
         <1504199967.666.16.camel@gmx.de>
         <CAGXu5j+RPDAP-dK+dizQV4prmWBhqU_G1PccWpME=924-2985w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        Peter Zijlstra <peterz@infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5j+RPDAP-dK+dizQV4prmWBhqU_G1PccWpME=924-2985w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-08-31 at 11:45 -0700, Kees Cook wrote:
> On Thu, Aug 31, 2017 at 10:19 AM, Mike Galbraith <efault@gmx.de> wrote:
> > On Thu, 2017-08-31 at 10:00 -0700, Kees Cook wrote:
> >>
> >> Oh! So it's gcc-version sensitive? That's alarming. Is this mapping correct:
> >>
> >> 4.8.5: WARN, eventual kernel hang
> >> 6.3.1, 7.0.1: WARN, but continues working
> >
> > Yeah, that's correct.  I find that troubling, simply because this gcc
> > version has been through one hell of a lot of kernels with me.  Yeah, I
> > know, that doesn't exempt it from having bugs, but color me suspicious.
> 
> I still can't hit this with a 4.8.5 build. :(
> 
> With _RATELIMIT removed, this should, in theory, report whatever goes
> negative first...

I applied the other patch you posted, and built with gcc-6.3.1 to
remove the gcc-4.8.5 aspect.  Look below the resulting splat.

[    1.293962] NET: Registered protocol family 10
[    1.294635] refcount_t silent saturation at in6_dev_get+0x25/0x104 in swapper/0[1], uid/euid: 0/0
[    1.295616] ------------[ cut here ]------------
[    1.296120] WARNING: CPU: 0 PID: 1 at kernel/panic.c:612 refcount_error_report+0x94/0x9e
[    1.296950] Modules linked in:
[    1.297276] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.13.0.g152d54a-tip-default #53
[    1.299179] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
[    1.300743] task: ffff88013ab84040 task.stack: ffffc9000062c000
[    1.301825] RIP: 0010:refcount_error_report+0x94/0x9e
[    1.302804] RSP: 0018:ffffc9000062fc10 EFLAGS: 00010282
[    1.303791] RAX: 0000000000000055 RBX: ffffffff81a34274 RCX: ffffffff81c605e8
[    1.304991] RDX: 0000000000000001 RSI: 0000000000000096 RDI: 0000000000000246
[    1.306189] RBP: ffffc9000062fd58 R08: 0000000000000000 R09: 0000000000000175
[    1.307392] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88013ab84040
[    1.308583] R13: 0000000000000000 R14: 0000000000000004 R15: ffffffff81a256c8
[    1.309768] FS:  0000000000000000(0000) GS:ffff88013fc00000(0000) knlGS:0000000000000000
[    1.311052] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    1.312100] CR2: 00007f4631fe8df0 CR3: 0000000137d09003 CR4: 00000000001606f0
[    1.313301] Call Trace:
[    1.314012]  ex_handler_refcount+0x63/0x70
[    1.314893]  fixup_exception+0x32/0x40
[    1.315737]  do_trap+0x8c/0x170
[    1.316519]  do_error_trap+0x70/0xd0
[    1.317340]  ? in6_dev_get+0x23/0x104
[    1.318172]  ? netlink_broadcast_filtered+0x2bd/0x430
[    1.319156]  ? kmem_cache_alloc_trace+0xce/0x5d0
[    1.320098]  ? set_debug_rodata+0x11/0x11
[    1.320964]  invalid_op+0x1e/0x30
[    1.322520] RIP: 0010:in6_dev_get+0x25/0x104
[    1.323631] RSP: 0018:ffffc9000062fe00 EFLAGS: 00010202
[    1.324614] RAX: ffff880137de2400 RBX: ffff880137df4600 RCX: ffff880137de24f0
[    1.325793] RDX: ffff88013a5e4000 RSI: 00000000fffffe00 RDI: ffff88013a5e4000
[    1.326964] RBP: 00000000000000d1 R08: 0000000000000000 R09: ffff880137de7600
[    1.328150] R10: 0000000000000000 R11: ffff8801398a4df8 R12: 0000000000000000
[    1.329374] R13: ffffffff82137872 R14: 014200ca00000000 R15: 0000000000000000
[    1.330547]  ? set_debug_rodata+0x11/0x11
[    1.331392]  ip6_route_init_special_entries+0x2a/0x89
[    1.332369]  addrconf_init+0x9e/0x203
[    1.333173]  inet6_init+0x1af/0x365
[    1.333956]  ? af_unix_init+0x4e/0x4e
[    1.334753]  do_one_initcall+0x4e/0x190
[    1.335555]  ? set_debug_rodata+0x11/0x11
[    1.336369]  kernel_init_freeable+0x189/0x20e
[    1.337230]  ? rest_init+0xd0/0xd0
[    1.337999]  kernel_init+0xa/0xf7
[    1.338744]  ret_from_fork+0x25/0x30
[    1.339500] Code: 48 8b 95 80 00 00 00 41 55 49 8d 8c 24 f0 0a 00 00 45 8b 84 24 10 09 00 00 41 89 c1 48 89 de 48 c7 c7 60 7a a3 81 e8 07 de 05 00 <0f> ff 58 5b 5d 41 5c 41 5d c3 0f 1f 44 00 00 55 48 89 e5 41 56 
[    1.342243] ---[ end trace b5d40c0fccce776c ]---

Back yours out, and...

# tracer: nop
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
       swapper/0-1     [000] ...1     1.974114: in6_dev_getx: refs.counter:-1073741824
       swapper/0-1     [000] ...1     1.974116: in6_dev_getx: refs.counter:-1073741824

---
 arch/x86/include/asm/refcount.h |    9 +++++++++
 include/net/addrconf.h          |   12 ++++++++++++
 net/ipv6/route.c                |    4 ++--
 3 files changed, 23 insertions(+), 2 deletions(-)

--- a/arch/x86/include/asm/refcount.h
+++ b/arch/x86/include/asm/refcount.h
@@ -55,6 +55,15 @@ static __always_inline void refcount_inc
 		: : "cc", "cx");
 }
 
+static __always_inline void refcount_inc_x(refcount_t *r)
+{
+	trace_printk("refs.counter:%d\n", r->refs.counter);
+	asm volatile(LOCK_PREFIX "incl %0\n\t"
+		REFCOUNT_CHECK_LT_ZERO
+		: [counter] "+m" (r->refs.counter)
+		: : "cc", "cx");
+}
+
 static __always_inline void refcount_dec(refcount_t *r)
 {
 	asm volatile(LOCK_PREFIX "decl %0\n\t"
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -321,6 +321,18 @@ static inline struct inet6_dev *in6_dev_
 	return idev;
 }
 
+static inline struct inet6_dev *in6_dev_getx(const struct net_device *dev)
+{
+	struct inet6_dev *idev;
+
+	rcu_read_lock();
+	idev = rcu_dereference(dev->ip6_ptr);
+	if (idev)
+		refcount_inc_x(&idev->refcnt);
+	rcu_read_unlock();
+	return idev;
+}
+
 static inline struct neigh_parms *__in6_dev_nd_parms_get_rcu(const struct net_device *dev)
 {
 	struct inet6_dev *idev = __in6_dev_get(dev);
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -4044,9 +4044,9 @@ void __init ip6_route_init_special_entri
 	init_net.ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
   #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	init_net.ipv6.ip6_prohibit_entry->dst.dev = init_net.loopback_dev;
-	init_net.ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+	init_net.ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_getx(init_net.loopback_dev);
 	init_net.ipv6.ip6_blk_hole_entry->dst.dev = init_net.loopback_dev;
-	init_net.ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+	init_net.ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_getx(init_net.loopback_dev);
   #endif
 }
 
