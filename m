From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH v2] xen-apic: Enable on domU as well
Date: Fri, 7 Aug 2015 10:23:29 -0400
Message-ID: <20150807142329.GC29527@l.oracle.com>
References: <1438878579-26856-1-git-send-email-Jason@zx2c4.com>
 <1438879025-27362-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xen.org,
	stable@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438879025-27362-1-git-send-email-Jason@zx2c4.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 06, 2015 at 06:37:05PM +0200, Jason A. Donenfeld wrote:
> It turns out that domU also requires the Xen APIC driver. Otherwise we
> get stuck in busy loops that never exit, such as in this stack trace:
> 
> (gdb) target remote localhost:9999
> Remote debugging using localhost:9999
> __xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56
> 56              while (native_apic_mem_read(APIC_ICR) & APIC_ICR_BUSY)
> (gdb) bt
>  #0  __xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56
>  #1  __default_send_IPI_shortcut (shortcut=<optimized out>,
> dest=<optimized out>, vector=<optimized out>) at
> ./arch/x86/include/asm/ipi.h:75
>  #2  apic_send_IPI_self (vector=246) at arch/x86/kernel/apic/probe_64.c:54
>  #3  0xffffffff81011336 in arch_irq_work_raise () at
> arch/x86/kernel/irq_work.c:47
>  #4  0xffffffff8114990c in irq_work_queue (work=0xffff88000fc0e400) at
> kernel/irq_work.c:100
>  #5  0xffffffff8110c29d in wake_up_klogd () at kernel/printk/printk.c:2633
>  #6  0xffffffff8110ca60 in vprintk_emit (facility=0, level=<optimized
> out>, dict=0x0 <irq_stack_union>, dictlen=<optimized out>,
> fmt=<optimized out>, args=<optimized out>)
>     at kernel/printk/printk.c:1778
>  #7  0xffffffff816010c8 in printk (fmt=<optimized out>) at
> kernel/printk/printk.c:1868
>  #8  0xffffffffc00013ea in ?? ()
>  #9  0x0000000000000000 in ?? ()
> 
> Mailing-list-thread: https://lkml.org/lkml/2015/8/4/755
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: <stable@vger.kernel.org>

While this patch is OK for the trees that implement the PV APIC
driver it won't apply to older ones (and it does not need to).

In the older ones this was working with f447d56d36af18c5104ff29dcb1327c0c0ac3634
"xen: implement apic ipi interface", which should have worked for
your case.

And would have made the arch_irq_work_raise and such use the 
Xen code paths:
 952                                                                                 
 953 #ifdef CONFIG_SMP                                                               
 954     apic->send_IPI_allbutself = xen_send_IPI_allbutself;                        
 955     apic->send_IPI_mask_allbutself = xen_send_IPI_mask_allbutself;              
 956     apic->send_IPI_mask = xen_send_IPI_mask;                                    
 957     apic->send_IPI_all = xen_send_IPI_all;                                      
 958     apic->send_IPI_self = xen_send_IPI_self;                                    
 959 #endif        

Anyhow, your patch seems to fix a regression my patch 
feb44f1f7a4ac299d1ab1c3606860e70b9b89d69
"x86/xen: Provide a "Xen PV" APIC driver to support >255 VCPUs"
introduced.

I would to the stable.vger.kernel.org:
# apply only to v4.1

As the earlier ones will work fine.

Thank you!

Oh, and Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>


> ---
>  arch/x86/xen/Makefile  |  4 ++--
>  arch/x86/xen/xen-ops.h | 11 ++++-------
>  2 files changed, 6 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/x86/xen/Makefile b/arch/x86/xen/Makefile
> index 7322755..4b6e29a 100644
> --- a/arch/x86/xen/Makefile
> +++ b/arch/x86/xen/Makefile
> @@ -13,13 +13,13 @@ CFLAGS_mmu.o			:= $(nostackp)
>  obj-y		:= enlighten.o setup.o multicalls.o mmu.o irq.o \
>  			time.o xen-asm.o xen-asm_$(BITS).o \
>  			grant-table.o suspend.o platform-pci-unplug.o \
> -			p2m.o
> +			p2m.o apic.o
>  
>  obj-$(CONFIG_EVENT_TRACING) += trace.o
>  
>  obj-$(CONFIG_SMP)		+= smp.o
>  obj-$(CONFIG_PARAVIRT_SPINLOCKS)+= spinlock.o
>  obj-$(CONFIG_XEN_DEBUG_FS)	+= debugfs.o
> -obj-$(CONFIG_XEN_DOM0)		+= apic.o vga.o
> +obj-$(CONFIG_XEN_DOM0)		+= vga.o
>  obj-$(CONFIG_SWIOTLB_XEN)	+= pci-swiotlb-xen.o
>  obj-$(CONFIG_XEN_EFI)		+= efi.o
> diff --git a/arch/x86/xen/xen-ops.h b/arch/x86/xen/xen-ops.h
> index c20fe29..cd248ff 100644
> --- a/arch/x86/xen/xen-ops.h
> +++ b/arch/x86/xen/xen-ops.h
> @@ -98,20 +98,17 @@ static inline void xen_uninit_lock_cpu(int cpu)
>  #endif
>  
>  struct dom0_vga_console_info;
> -
>  #ifdef CONFIG_XEN_DOM0
>  void __init xen_init_vga(const struct dom0_vga_console_info *, size_t size);
> -void __init xen_init_apic(void);
>  #else
> -static inline void __init xen_init_vga(const struct dom0_vga_console_info *info,
> -				       size_t size)
> -{
> -}
> -static inline void __init xen_init_apic(void)
> +void __init xen_init_vga(const struct dom0_vga_console_info *info,
> +			size_t size);
>  {
>  }
>  #endif
>  
> +void __init xen_init_apic(void);
> +
>  #ifdef CONFIG_XEN_EFI
>  extern void xen_efi_init(void);
>  #else
> -- 
> 2.5.0
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
