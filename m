From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: linux-next: arm allmodconfig
Date: Wed, 29 Oct 2008 09:40:55 +0000
Message-ID: <20081029094054.GA3796@flint.arm.linux.org.uk>
References: <20081028175604.81c31cea.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Moore <paul.moore@hp.com>, Takashi Iwai <tiwai@suse.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>, xfs-masters@oss.sgi.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:48929 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbYJ2JmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 05:42:13 -0400
Content-Disposition: inline
In-Reply-To: <20081028175604.81c31cea.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2008 at 05:56:04PM -0700, Andrew Morton wrote:
> > arch/arm/mm/dma-mapping.c: In function `dma_sync_sg_for_cpu':
> > arch/arm/mm/dma-mapping.c:588: warning: statement with no effect
> 
> Something in here:
> 
>                 dmabounce_sync_for_cpu(dev, sg_dma_address(s), 0,
>                                         sg_dma_len(s), dir);                    

That's because dmabounce_sync_for_xxx() functions return whether they
did anything, so in the case where the buffer isn't bounced, we fall
through to the standard DMA cache maintainence methods.

When there's no dmabounce, we define these functions to (1), which
of course causes the warning.  I'll eventually convert them to inline
functions instead.

> > kernel/sched.c: In function `add_preempt_count':
> > kernel/sched.c:4294: warning: unsupported arg to `__builtin_return_address'
> > kernel/sched.c:4296: warning: unsupported arg to `__builtin_return_address'
> > kernel/sched.c:4298: warning: unsupported arg to `__builtin_return_address'
> > kernel/sched.c: In function `sub_preempt_count':
> > kernel/sched.c:4294: warning: unsupported arg to `__builtin_return_address'
> > kernel/sched.c:4296: warning: unsupported arg to `__builtin_return_address'
> > kernel/sched.c:4298: warning: unsupported arg to `__builtin_return_address'
> 
> Related to CALLER_ADDR2, etc.

Later ARM toolchains seem to have dropped support for non-zero arguments
to __builtin_return_address() - presumably to support this new fangled
EABI stuff.  Not much can be done about that without screaming at the
toolchain people.

> > drivers/atm/zatm.c: In function `refill_pool':
> > drivers/atm/zatm.c:226: warning: `virt_to_bus' is deprecated (declared at /usr/src/devel/arch/arm/include/asm/memory.h:184)
> > 
> <50ish similar warnings snipped>

We really really want to see the end of virt_to_bus() in the kernel -
since ARM is a non-cache coherent architecture, every usage of it is
a bug since there'll be no cache maintainence.

So, essentially, these warnings are saying that this driver is buggy
on ARM.

> > drivers/atm/ambassador.h:257:1: warning: "FLASH_BASE" redefined
> > In file included from arch/arm/mach-versatile/include/mach/irqs.h:22,
> >                  from /usr/src/devel/arch/arm/include/asm/irq.h:4,
> >                  from /usr/src/devel/arch/arm/include/asm/hardirq.h:6,
> >                  from include/linux/hardirq.h:7,
> >                  from include/asm-generic/local.h:5,
> >                  from /usr/src/devel/arch/arm/include/asm/local.h:1,
> >                  from include/linux/module.h:20,
> >                  from drivers/atm/ambassador.c:25:
> > arch/arm/mach-versatile/include/mach/platform.h:443:1: warning: this is the location of the previous definition
> > In file included from drivers/atm/ambassador.c:44:
> > drivers/atm/ambassador.h:258:1: warning: "FLASH_SIZE" redefined

Here we go again...

I do wish that people wouldn't include "platform.h" headers defining lots
of generically named constants into a header file used by most of the
kernel build.  It's stupid for several reasons:

1. see the above warnings.
2. if you change anything in that header, you're going to get a needless
   full kernel rebuild
3. and that causes additional strain on kautobuild's build caches

We've had this in the past with sa1100-regs.h and similar, and we solved
it there.

Unfortunately, people persist in including their platform includes into
lots of header files rather than having just the relevent C files include
them.  Eg, arch/arm/plat-omap/include/mach/hardware.h:

/*
 * ---------------------------------------------------------------------------
 * Board specific defines
 * ---------------------------------------------------------------------------
 */

#ifdef CONFIG_MACH_OMAP_INNOVATOR
#include "board-innovator.h"
#endif

#ifdef CONFIG_MACH_OMAP_H2
#include "board-h2.h"
#endif
...
#ifdef CONFIG_MACH_SX1
#include "board-sx1.h"
#endif

which is included via asm/io.h, asm/irq.h, asm/pci.h, asm/vga.h.

As long as this idiocracy, we're going to see these kinds of clashes.
This stuff needs to die.  I've a good idea to do a sweep of all ARM
includes, and commit a patch to my devel tree for linux-next to remove
such includes as an encouragement to fixing this stuff properly.

People will then have a couple of months to sort out their mess.

> > crypto/testmgr.c: In function `alg_test_comp':
> > crypto/testmgr.c:829: warning: 'ret' might be used uninitialized in this function
> 
> There's no way for the compiler to know that this code isn't buggy.
> 
> Suggest that this be fixed via uninitialized_var() or, better, convert
> to a do{}while() loop.
> 
> I notice that test_comp() also has two locals called `ret' - one
> shadowing the other.

Here's a question: Why do we have to have the test manager built in if
we build some crypto modules?  What if you're building an embedded target
and don't want to test the crypto modules on every boot?  (Think code
size, boot time, etc.)

> > include/asm-generic/cmpxchg-local.h:15: warning: 'prev' might be used uninitialized in this function
> > drivers/gpu/drm/drm_lock.c: In function `drm_lock_free':
> > include/asm-generic/cmpxchg-local.h:15: warning: 'prev' might be used uninitialized in this function
> > include/asm-generic/cmpxchg-local.h:15: warning: 'prev' might be used uninitialized in this function
> > drivers/gpu/drm/drm_lock.c: In function `drm_notifier':
> > include/asm-generic/cmpxchg-local.h:15: warning: 'prev' might be used uninitialized in this function
> > drivers/gpu/drm/drm_lock.c: In function `drm_idlelock_release':
> > include/asm-generic/cmpxchg-local.h:15: warning: 'prev' might be used uninitialized in this function
> 
> didn't look.

No idea.

> > drivers/gpu/drm/drm_agpsupport.c:36:21: asm/agp.h: No such file or directory
> > make[3]: *** [drivers/gpu/drm/drm_agpsupport.o] Error 1
> > make[2]: *** [drivers/gpu/drm] Error 2
> > make[1]: *** [drivers/gpu] Error 2
> > make[1]: *** Waiting for unfinished jobs....
> 
> DRM has been breaking arm allmodconfig for at least a year.

I've no idea what asm/agp.h is supposed to have in it, no idea what
DRM actually is other than "Digital Rights Management" ;)

I suspect the right answer is to make DRM depend on !ARM - I know of
no ARM platform with AGP.
