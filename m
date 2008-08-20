From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Wed, 20 Aug 2008 10:58:22 -0700
Message-ID: <86802c440808201058s5141c10fnf2b843525f8c545@mail.gmail.com>
References: <324173.33114.qm@web82106.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>, "Vivek Goyal" <vgoyal@redhat.com>,
	"Bill Fink" <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:42702 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbYHTR6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 13:58:23 -0400
Received: by gxk9 with SMTP id 9so582509gxk.13
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 10:58:22 -0700 (PDT)
In-Reply-To: <324173.33114.qm@web82106.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 20, 2008 at 10:42 AM, David Witbrodt <dawitbro@sbcglobal.net> wrote:
>
> *** FINALLY FOUND THE EXACT PROBLEM ***
>
> I woke up this morning with a new idea.  I wish I had thought of this
> TWO WEEKS AGO!
>
> Commit 3def3d6d essentially involves 2 different changes:
>
> 1.  request_resource () is replaced by insert_resource()
>
> 2.  code to add {code,data,bss}_resource to the iomem_resource tree
> is moved out of e820_reserve_resources() and into setup_arch()
> directly.  [The actual call of e820_reserve_resources() is also
> located in setup_arch().]
>
>
> Since this is 2 separate changes, I went back to 700efc1b, just
> before the commit introducing the regression (3def3d6d).
>
> When I applied change #2 alone, and GOT A WORKING KERNEL!
> ===== BEGIN DIFF ================
> diff --git a/arch/x86/kernel/e820_64.c b/arch/x86/kernel/e820_64.c
> index a8694a3..e452bea 100644
> --- a/arch/x86/kernel/e820_64.c
> +++ b/arch/x86/kernel/e820_64.c
> @@ -229,8 +229,7 @@ unsigned long __init e820_end_of_ram(void)
>  /*
>  * Mark e820 reserved areas as busy for the resource manager.
>  */
> -void __init e820_reserve_resources(struct resource *code_resource,
> -        struct resource *data_resource, struct resource *bss_resource)
> +void __init e820_reserve_resources(void)
>  {
>     int i;
>     for (i = 0; i < e820.nr_map; i++) {
> @@ -246,20 +245,6 @@ void __init e820_reserve_resources(struct resource *code_resource,
>         res->end = res->start + e820.map[i].size - 1;
>         res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
>         request_resource(&iomem_resource, res);
> -        if (e820.map[i].type == E820_RAM) {
> -            /*
> -             * We don't know which RAM region contains kernel data,
> -             * so we try it repeatedly and let the resource manager
> -             * test it.
> -             */
> -            request_resource(res, code_resource);
> -            request_resource(res, data_resource);
> -            request_resource(res, bss_resource);
> -#ifdef CONFIG_KEXEC
> -            if (crashk_res.start != crashk_res.end)
> -                request_resource(res, &crashk_res);
> -#endif
> -        }
>     }
>  }
>
> diff --git a/arch/x86/kernel/setup_64.c b/arch/x86/kernel/setup_64.c
> index 187f084..a0584ac 100644
> --- a/arch/x86/kernel/setup_64.c
> +++ b/arch/x86/kernel/setup_64.c
> @@ -322,6 +322,11 @@ void __init setup_arch(char **cmdline_p)
>
>     finish_e820_parsing();
>
> +    /* after parse_early_param, so could debug it */
> +    insert_resource(&iomem_resource, &code_resource);
> +    insert_resource(&iomem_resource, &data_resource);
> +    insert_resource(&iomem_resource, &bss_resource);
> +
>     early_gart_iommu_check();
>
>     e820_register_active_regions(0, 0, -1UL);
> @@ -454,7 +459,7 @@ void __init setup_arch(char **cmdline_p)
>     /*
>      * We trust e820 completely. No explicit ROM probing in memory.
>      */
> -    e820_reserve_resources(&code_resource, &data_resource, &bss_resource);
> +    e820_reserve_resources();
>     e820_mark_nosave_regions();
>
>     /* request I/O space for devices used on all i[345]86 PCs */
> diff --git a/include/asm-x86/e820_64.h b/include/asm-x86/e820_64.h
> index 9e06c6e..ef653a4 100644
> --- a/include/asm-x86/e820_64.h
> +++ b/include/asm-x86/e820_64.h
> @@ -23,8 +23,7 @@ extern void update_memory_range(u64 start, u64 size, unsigned old_type,
>  extern void setup_memory_region(void);
>  extern void contig_e820_setup(void);
>  extern unsigned long e820_end_of_ram(void);
> -extern void e820_reserve_resources(struct resource *code_resource,
> -        struct resource *data_resource, struct resource *bss_resource);
> +extern void e820_reserve_resources(void);
>  extern void e820_mark_nosave_regions(void);
>  extern int e820_any_mapped(unsigned long start, unsigned long end, unsigned type);
>  extern int e820_all_mapped(unsigned long start, unsigned long end, unsigned type);
> ===== END DIFF ================
>
>
> As a separate experiment, I started over with a clean version of
> 700efc1b, then introduced the change from request_resource() to
> insert_resource():
> ===== BEGIN DIFF ================
> diff --git a/arch/x86/kernel/e820_64.c b/arch/x86/kernel/e820_64.c
> index a8694a3..988195d 100644
> --- a/arch/x86/kernel/e820_64.c
> +++ b/arch/x86/kernel/e820_64.c
> @@ -245,7 +245,7 @@ void __init e820_reserve_resources(struct resource *code_resource,
>         res->start = e820.map[i].addr;
>         res->end = res->start + e820.map[i].size - 1;
>         res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> -        request_resource(&iomem_resource, res);
> +        insert_resource(&iomem_resource, res);
>         if (e820.map[i].type == E820_RAM) {
>             /*
>              * We don't know which RAM region contains kernel data,
> ===== END DIFF ================
>
> The kernel produced from the change HANGS!

because code/data/bss/crashk is inserted at first

in e820_reserve_resource if you call request_resource instead of
insert_resource. the entries from e820 tables that has conflict to
entries already added will not show in
resource list /proc/iomem.

please send out /proc/iomem when it happens to boot.

YH
