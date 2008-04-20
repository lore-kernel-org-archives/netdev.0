From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] Re: Bad network performance over 2Gbps
Date: Sun, 20 Apr 2008 15:08:43 +0300
Message-ID: <200804201508.45768.denys@visp.net.lb>
References: <1208282804.23631.27.camel@localhost> <1208426550.6049.10.camel@localhost> <48078AF6.2020003@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Anton Titov <a.titov@host.bg>, Chris Snook <csnook@redhat.com>,
	"H. Willstrand" <h.willstrand@gmail.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760885AbYDTMIP@vger.kernel.org>
In-Reply-To: <48078AF6.2020003@intel.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By default also without IRQBALANCE enabled in kernel, APIC or someone else distributing interrupts over processors too.
There is no irqbalance daemon or whatever.

For example:
Router-KARAM ~ # cat /proc/interrupts
           CPU0       CPU1
  0:   87956938 1403052485   IO-APIC-edge      timer
  1:          0          2   IO-APIC-edge      i8042
  9:          0          0   IO-APIC-fasteoi   acpi
 19:        140       5714   IO-APIC-fasteoi   ohci_hcd:usb1, ohci_hcd:usb2
 24:  675673280 1186506694   IO-APIC-fasteoi   eth2
 26:  717865662 2201633562   IO-APIC-fasteoi   eth0
 27:    1869190   23075556   IO-APIC-fasteoi   eth1
NMI:          0          0   Non-maskable interrupts
LOC: 1403052485   87956683   Local timer interrupts
RES:      75059      25408   Rescheduling interrupts
CAL:      99542         83   function call interrupts
TLB:        616        200   TLB shootdowns
TRM:          0          0   Thermal event interrupts
SPU:          0          0   Spurious interrupts
ERR:          0
MIS:          0

sunfire-1 ~ # cat config|grep -i irq
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
# CONFIG_IRQBALANCE is not set
CONFIG_HT_IRQ=y
# CONFIG_HPET_RTC_IRQ is not set
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_DEBUG_SHIRQ is not set

Is it harmful too?

On Thursday 17 April 2008 20:37, Kok, Auke wrote:
> Anton Titov wrote:
> > On Tue, 2008-04-15 at 16:59 -0400, Chris Snook wrote:
> >> Still, I think you're on to something here.  Disabling NAPI and instead 
> >> tuning the cards' interrupt coalescing settings might allow irqbalance 
> >> to do a better job than it is currently.
> > 
> > Disabling NAPI allowed me to push as much as 3.5Gbit out of the same
> > server with ~ 20% of time CPUs doing software interrupts.
> 
> yes, I really don't see this is such an amazing discovery - the in-kernel
> irqbalance code is totally wrong for network interrupts (and probably for most
> interrupts).
> 
> on your system with 6 network interrupts it blows chunks and it's not NAPI that is
> the issue - NAPI will work just fine on it's own. By disabling NAPI and reverting
> to the in-driver irq moderation code you've effectively put the in-kernel
> irqbalance code to the sideline and this is what makes it work again.
> 
> It's not the right solution.
> 
> We keep seing this exact issue pop up everywhere - especially with e1000(e)
> datacenter users - this code _has_ to go or be fixed. Since there is a perfectly
> viable solution, I strongly suggest disabling it.
> 
> This is not the first time I've sent this patch out in some form...
> 
> Auke
> 
> 
> ---
> [X86] IRQBALANCE: Mark as BROKEN and disable by default
> 
> The IRQBALANCE option causes interrupts to bounce all around on SMP systems
> quickly burying the CPU in migration cost and cache misses. Mainly affected are
> network interrupts and this results in one CPU pegged in softirqd completely.
> 
> Disable this option and provide documentation to a better solution (userspace
> irqbalance daemon does overall the best job to begin with and only manual setting
> of smp_affinity will beat it).
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> ---
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 6c70fed..956aa22 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1026,13 +1026,17 @@ config EFI
>    	platforms.
> 
>  config IRQBALANCE
> -	def_bool y
> +	def_bool n
>  	prompt "Enable kernel irq balancing"
> -	depends on X86_32 && SMP && X86_IO_APIC
> +	depends on X86_32 && SMP && X86_IO_APIC && BROKEN
>  	help
>  	  The default yes will allow the kernel to do irq load balancing.
>  	  Saying no will keep the kernel from doing irq load balancing.
> 
> +	  This option is known to cause performance issues on SMP
> +	  systems. The preferred method is to use the userspace
> +	  'irqbalance' daemon instead. See http://irqbalance.org/.
> +
>  config SECCOMP
>  	def_bool y
>  	prompt "Enable seccomp to safely compute untrusted bytecode"
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
