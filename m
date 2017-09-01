From: Mike Galbraith <efault@gmx.de>
Subject: Re: tip -ENOBOOT - bisected to locking/refcounts, x86/asm:
 Implement fast refcount overflow protection
Date: Fri, 01 Sep 2017 15:09:29 +0200
Message-ID: <1504271369.332.29.camel@gmx.de>
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
         <1504249070.17604.20.camel@gmx.de>
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
In-Reply-To: <1504249070.17604.20.camel@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-09-01 at 08:57 +0200, Mike Galbraith wrote:
> On Thu, 2017-08-31 at 11:45 -0700, Kees Cook wrote:
> > On Thu, Aug 31, 2017 at 10:19 AM, Mike Galbraith <efault@gmx.de> wrote:
> > > On Thu, 2017-08-31 at 10:00 -0700, Kees Cook wrote:
> > >>
> > >> Oh! So it's gcc-version sensitive? That's alarming. Is this mapping correct:
> > >>
> > >> 4.8.5: WARN, eventual kernel hang
> > >> 6.3.1, 7.0.1: WARN, but continues working
> > >
> > > Yeah, that's correct.  I find that troubling, simply because this gcc
> > > version has been through one hell of a lot of kernels with me.  Yeah, I
> > > know, that doesn't exempt it from having bugs, but color me suspicious.
> > 
> > I still can't hit this with a 4.8.5 build. :(
> > 
> > With _RATELIMIT removed, this should, in theory, report whatever goes
> > negative first...
> 
> I applied the other patch you posted, and built with gcc-6.3.1 to
> remove the gcc-4.8.5 aspect.  Look below the resulting splat.

Grr, that one has a in6_dev_getx() line missing for the first
increment, where things go pear shaped.

With that added, looking at counter both before, and after incl, with a
trace_printk() in the exception handler showing it doing its saturate
thing, irqs disabled across the whole damn refcount_inc(), and even
booting box nr_cpus=1 for extra credit...

HTH can that first refcount_inc() get there?

# tracer: nop
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
         systemd-1     [000] d..1     1.937284: in6_dev_getx: PRE refs.counter:3
         systemd-1     [000] d..1     1.937295: ex_handler_refcount: *(int *)regs->cx = -1073741824
         systemd-1     [000] d..1     1.937296: in6_dev_getx: POST refs.counter:-1073741824
         systemd-1     [000] d..1     1.937296: in6_dev_getx: PRE refs.counter:-1073741824
         systemd-1     [000] d..1     1.937297: ex_handler_refcount: *(int *)regs->cx = -1073741824
         systemd-1     [000] d..1     1.937297: in6_dev_getx: POST refs.counter:-1073741824
         systemd-1     [000] d..1     1.937297: in6_dev_getx: PRE refs.counter:-1073741824
         systemd-1     [000] d..1     1.937298: ex_handler_refcount: *(int *)regs->cx = -1073741824
         systemd-1     [000] d..1     1.937299: in6_dev_getx: POST refs.counter:-1073741824

---
 arch/x86/include/asm/refcount.h |   14 ++++++++++++++
 arch/x86/mm/extable.c           |    1 +
 include/net/addrconf.h          |   12 ++++++++++++
 net/ipv6/route.c                |    6 +++---
 4 files changed, 30 insertions(+), 3 deletions(-)

--- a/arch/x86/include/asm/refcount.h
+++ b/arch/x86/include/asm/refcount.h
@@ -55,6 +55,20 @@ static __always_inline void refcount_inc
 		: : "cc", "cx");
 }
 
+static __always_inline void refcount_inc_x(refcount_t *r)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	trace_printk("PRE refs.counter:%d\n", r->refs.counter);
+	asm volatile(LOCK_PREFIX "incl %0\n\t"
+		REFCOUNT_CHECK_LT_ZERO
+		: [counter] "+m" (r->refs.counter)
+		: : "cc", "cx");
+	trace_printk("POST refs.counter:%d\n", r->refs.counter);
+	local_irq_restore(flags);
+}
+
 static __always_inline void refcount_dec(refcount_t *r)
 {
 	asm volatile(LOCK_PREFIX "decl %0\n\t"
--- a/arch/x86/mm/extable.c
+++ b/arch/x86/mm/extable.c
@@ -45,6 +45,7 @@ bool ex_handler_refcount(const struct ex
 {
 	/* First unconditionally saturate the refcount. */
 	*(int *)regs->cx = INT_MIN / 2;
+	trace_printk("*(int *)regs->cx = %d\n", *(int *)regs->cx);
 
 	/*
 	 * Strictly speaking, this reports the fixup destination, not
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
@@ -4041,12 +4041,12 @@ void __init ip6_route_init_special_entri
 	 * the loopback reference in rt6_info will not be taken, do it
 	 * manually for init_net */
 	init_net.ipv6.ip6_null_entry->dst.dev = init_net.loopback_dev;
-	init_net.ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+	init_net.ipv6.ip6_null_entry->rt6i_idev = in6_dev_getx(init_net.loopback_dev);
   #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	init_net.ipv6.ip6_prohibit_entry->dst.dev = init_net.loopback_dev;
-	init_net.ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+	init_net.ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_getx(init_net.loopback_dev);
 	init_net.ipv6.ip6_blk_hole_entry->dst.dev = init_net.loopback_dev;
-	init_net.ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+	init_net.ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_getx(init_net.loopback_dev);
   #endif
 }
 
