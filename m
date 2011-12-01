From: Borislav Petkov <bp-HnHVZv34qLXYtjvyW6yDsg@public.gmane.org>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Thu, 1 Dec 2011 12:39:19 +0100
Message-ID: <20111201113919.GC31552@aftab>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera>
 <201111212249.31196.rjw@sisk.pl>
 <20111122135412.GA29905@phenom.dumpdata.com>
 <20111129180414.GA11459@phenom.dumpdata.com>
 <20111129183428.GE8200@aftab>
 <20111130175936.GA15168@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org,
	mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	deepthi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111130175936.GA15168-6K5HmflnPlqSPmnEAIUT9EEOCMrvLtNR@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 30, 2011 at 12:59:36PM -0500, Konrad Rzeszutek Wilk wrote:
> On Tue, Nov 29, 2011 at 07:34:28PM +0100, Borislav Petkov wrote:
> > On Tue, Nov 29, 2011 at 01:04:14PM -0500, Konrad Rzeszutek Wilk wrote:
> > > This patch:
> 
> 
> Borislav,
> 
> Thanks for your review comments. How does this patch look? I believe
> I touched upon all of the things you mentioned.
> 
> From eb6dbd80078312c428dde69e9313606b7513a2e6 Mon Sep 17 00:00:00 2001
> From: Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Date: Mon, 21 Nov 2011 18:02:02 -0500
> Subject: [PATCH] xen/pm_idle: Make pm_idle be default_idle under Xen.
> 
> This patch:
> 
> commit d91ee5863b71e8c90eaf6035bff3078a85e2e7b5
> Author: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Date:   Fri Apr 1 18:28:35 2011 -0400
> 
>     cpuidle: replace xen access to x86 pm_idle and default_idle
> 
>     ..scribble on pm_idle and access default_idle,
>    have it simply disable_cpuidle() so acpi_idle will not load and
>    architecture default HLT will be used.
> 
> idea was to have one call - disable_cpuidle() which would make
> pm_idle not be molested by other code. It disallows cpuidle_idle_call
> to be set to pm_idle (which is excellent). But in the select_idle_routine()
> and idle_setup(), the pm_idle can still be set to either:
> amd_e400_idle, mwait_idle or default_idle. This depends on some
> CPU flags (MWAIT) and in AMD case on the type of CPU.
> 
> In case of mwait_idle we can hit some instances where the hypervisor
> (Amazon EC2 specifically) sets the MWAIT and we get:
> 
> Brought up 2 CPUs
> invalid opcode: 0000 [#1] SMP
> CPU 1
> Modules linked in:
> 
> Pid: 0, comm: swapper Not tainted 3.1.0-0.rc6.git0.3.fc16.x86_64 #1
> RIP: e030:[<ffffffff81015d1d>]  [<ffffffff81015d1d>] mwait_idle+0x6f/0xb4
> RSP: e02b:ffff8801d28ddf10  EFLAGS: 00010082
> RAX: ffff8801d28dc010 RBX: ffff8801d28ddfd8 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000001
> RBP: ffff8801d28ddf10 R08: 0000000000000000 R09: 0000000000000001
> R10: 0000000000000001 R11: ffff8801d28ddfd8 R12: ffffffff81b590d0
> R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
> FS:  0000000000000000(0000) GS:ffff8801dff81000(0000) knlGS:0000000000000000
> CS:  e033 DS: 002b ES: 002b CR0: 000000008005003b
> CR2: 0000000000000000 CR3: 0000000001a05000 CR4: 0000000000002660
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000000
> Process swapper (pid: 0, threadinfo ffff8801d28dc000, task ffff8801d28cae60)
> Stack:
>  ffff8801d28ddf40 ffffffff8100e2ed ffff8801dff8e390 c136dfe72feab515
>  0000000000000000 0000000000000000 ffff8801d28ddf50 ffffffff8149ee78
>  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> Call Trace:
>  [<ffffffff8100e2ed>] cpu_idle+0xae/0xe8
>  [<ffffffff8149ee78>] cpu_bringup_and_idle+0xe/0x10
> RIP  [<ffffffff81015d1d>] mwait_idle+0x6f/0xb4
>  RSP <ffff8801d28ddf10>
> 
> In case of amd_e400_idle we don't get so spectacular crashes, but
> we do end up making an MSR which is trapped in the hypervisor,
> and then follow it up with a yield hypercall. Meaning we end up
> going to hypervisor twice instead of just once.
> 
> The previous behavior before v3.0 was that pm_idle was set
> to default_idle irregardless of select_idle_routine/idle_setup.
> 
> We want to do that, but only for one specific case: Xen.
> This patch does that.
> 
> Fixes RH BZ #739499 and Ubuntu #881076
> Reported-by: Stefan Bader <stefan.bader-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/x86/include/asm/system.h |    1 +
>  arch/x86/kernel/process.c     |    8 ++++++++
>  arch/x86/xen/setup.c          |    2 +-
>  3 files changed, 10 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/x86/include/asm/system.h b/arch/x86/include/asm/system.h
> index c2ff2a1..2d2f01c 100644
> --- a/arch/x86/include/asm/system.h
> +++ b/arch/x86/include/asm/system.h
> @@ -401,6 +401,7 @@ extern unsigned long arch_align_stack(unsigned long sp);
>  extern void free_init_pages(char *what, unsigned long begin, unsigned long end);
>  
>  void default_idle(void);
> +bool set_pm_idle_to_default(void);
>  
>  void stop_this_cpu(void *dummy);
>  
> diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
> index 1f7f8c8..31f47ba 100644
> --- a/arch/x86/kernel/process.c
> +++ b/arch/x86/kernel/process.c
> @@ -404,6 +404,14 @@ void default_idle(void)
>  EXPORT_SYMBOL(default_idle);
>  #endif
>  
> +bool set_pm_idle_to_default(void)
> +{
> +	bool ret = !!pm_idle;
> +
> +	pm_idle = default_idle;
> +
> +	return ret;
> +}
>  void stop_this_cpu(void *dummy)
>  {
>  	local_irq_disable();
> diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
> index 46d6d21..79dfb57 100644
> --- a/arch/x86/xen/setup.c
> +++ b/arch/x86/xen/setup.c
> @@ -448,6 +448,6 @@ void __init xen_arch_setup(void)
>  #endif
>  	disable_cpuidle();
>  	boot_option_idle_override = IDLE_HALT;
> -
> +	WARN_ON(set_pm_idle_to_default());
>  	fiddle_vdso();
>  }

>From what I can see, you get the following callchain:

start_kernel
|-> setup_arch
    |-> x86_init.oem.arch_setup = xen_arch_setup
    ....
    |-> check_bugs
        |-> identify_boot_cpu
	    |-> identify_cpu
	        |-> select_idle_routine


so xen_arch_setup will set pm_idle and select_idle_routine will honour
it. I'm being told this is run either in the dom0 or the paravirt guest
and if so, I don't see any issue with this for baremetal. So you can
have my ACK provided this is tested on baremetal too.

Thanks.

-- 
Regards/Gruss,
Boris.

Advanced Micro Devices GmbH
Einsteinring 24, 85609 Dornach
GM: Alberto Bozzo
Reg: Dornach, Landkreis Muenchen
HRB Nr. 43632 WEEE Registernr: 129 19551
