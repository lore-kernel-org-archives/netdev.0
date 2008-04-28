From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] ARCH: Fix 32-bit x86 MSI-X allocation leakage
Date: Mon, 28 Apr 2008 12:09:57 -0700
Message-ID: <200804281909.m3SJ9v0k015496@frodo.ebiederm.org>
References: <20080426005850.7098.77479.stgit@scrappy.jf.intel.com>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966565AbYD1TKf@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Brandeburg, Jesse" <jesse.brandeburg@intel.com>, <linux-pci@atrey.karlin.mff.cuni.cz>,  "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,  <michael@ellerman.id.au>, Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 28 Apr 2008 12:09:57 -0700
In-Reply-To: <20080426005850.7098.77479.stgit@scrappy.jf.intel.com> (PJ
	Waskiewicz's message of "Fri, 25 Apr 2008 17:58:52 -0700")
Message-ID: <m1skx53iey.fsf@frodo.ebiederm.org>
User-Agent: Gnus/5.110006 (No Gnus v0.6) Emacs/21.4 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii


Thanks Jesse for forwarding this to me.

PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com> writes:

> This bug was introduced in the 2.6.24 i386/x86_64 tree merge, where
> MSI-X vector allocation will eventually fail.  The cause is the new
> bit array tracking used vectors is not getting cleared properly on
> IRQ destruction on the 32-bit APIC code.

In particular commit dbeb2be21d678c49a8d8bbf774903df15dd55474
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Fri Oct 19 20:35:03 2007 +0200

    i386: introduce "used_vectors" bitmap which can be used to reserve vectors.
    
    This simplifies the io_apic.c __assign_irq_vector() logic and removes
    the explicit SYSCALL_VECTOR check, and also allows for vectors to be
    reserved by other mechanisms (ie. lguest).
    
    [ tglx: arch/x86 adaptation ]
    
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
    Signed-off-by: Andi Kleen <ak@suse.de>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

> This can be seen easily using the ixgbe 10 GbE driver on multi-core
> systems by simply loading and unloading the driver a few times.
> Depending on the number of available vectors on the host system, the
> MSI-X allocation will eventually fail, and the driver will only be
> able to use legacy interrupts.
>
> I am generating the same patch for both stable trees for 2.6.24 and
> 2.6.25.

The patch below does looks ok in terms of fixing the issue with
respect to MSIs.

Unfortunately the entire used_vectors concept appears broken.  Rusty
is not taking vector_lock.  used_vectors as designed can not
work on x86_64 as vectors are allocated to interrupts in a per cpu
manner, resulting in unnecessary divergences between  
the two pieces of code.  used_vectors is an an extra data structure
that we have to keep in sync, and failing to keep that data
structure in sync is why we have a problem.

For the concept of allocating a non 0x80 vector for interrupts Rusty
was on the right track.  His implementation just appears to be 
broken in the corner cases, and has a design we can not use long
term.

To fix this my inclination is to revert:
dbeb2be21d678c49a8d8bbf774903df15dd55474 (the infracture) and
c18acd73ffc209def08003a1927473096f66c5ad (the lguest user)
as we need to rework those pieces of code anyway, and then work with
Rusty to come up with something that we can share on x86 and x86_64.

Rusty?

Eric


> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> ---
>
>  arch/x86/kernel/io_apic_32.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
>
> diff --git a/arch/x86/kernel/io_apic_32.c b/arch/x86/kernel/io_apic_32.c
> index 2e2f420..77798b1 100644
> --- a/arch/x86/kernel/io_apic_32.c
> +++ b/arch/x86/kernel/io_apic_32.c
> @@ -2444,6 +2444,7 @@ void destroy_irq(unsigned int irq)
>  	dynamic_irq_cleanup(irq);
>  
>  	spin_lock_irqsave(&vector_lock, flags);
> +	clear_bit(irq_vector[irq], used_vectors);
>  	irq_vector[irq] = 0;
>  	spin_unlock_irqrestore(&vector_lock, flags);
>  }
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
