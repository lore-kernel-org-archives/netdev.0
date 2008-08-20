From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Tue, 19 Aug 2008 22:21:44 -0700
Message-ID: <86802c440808192221s3ada5443qc3b9d8e26f252d03@mail.gmail.com>
References: <109483.89278.qm@web82104.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:42179 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbYHTFVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 01:21:45 -0400
Received: by rv-out-0506.google.com with SMTP id k40so306108rvb.1
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 22:21:44 -0700 (PDT)
In-Reply-To: <109483.89278.qm@web82104.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 9:51 PM, David Witbrodt <dawitbro@sbcglobal.net> wrote:
>
>
>> > $ dmesg | grep -i hpet
>> > ACPI: HPET 77FE80C0, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD       98)
>> > ACPI: HPET id: 0x10b9a201 base: 0xfed00000
>> > hpet clockevent registered
>> > hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
>> > hpet0: 4 32-bit timers, 14318180 Hz
>> > hpet_resources: 0xfed00000 is busy
>>
>> btw., you might also want to look into drivers/char/hpet.c and
>> instrument that a bit. In particular the ioremap()s done there will show
>> exactly how the hpet is mapped.
>
> Well, I exhausted about 80% of the list of experiments I put together
> on Saturday, but I still can't make a 2.6.2[67] kernel boot without
> "hpet=disable" or reverting commits 3def3d6d... and 1e934dda...
>
> I spent so many hours on this today...  My head is spinning, and I'm
> afraid springs and smoke will start emanating from my hard drive soon
> from all the recompiling and rebooting!
>
> I need to warn you all:  I discovered today, for the first time, that
> I am not the first user to report this bug.  This guy got bit by it
> back in May, at version 2.6.26-rc2:
>
> [blog] http://ciaranm.wordpress.com/tag/f-i90hd/
> [LKML] http://www.uwsg.indiana.edu/hypermail/linux/kernel/0805.2/0746.html
>
> He has different hardware from mine, so when 2.6.26 starts hitting the
> distros you may see a flood of complaints -- and I came to LKML partly
> with the purpose of providing a bug fix patch (or, less preferably, a
> reversion patch) for Debian, my distro of choice.
>
> I am not giving up.  I _did_ look at drivers/char/hpet.c as requested,
> but since this code did not change before and after 3def3d6d..., I
> was not sure what to look for that would be harmful.  The same turned out
> to be true about the "connection" I found between HPET and the calls
> of insert_resource(), though this could actually be affected if my latest
> hypothesis pans out.  (All of my ideas have failed so far, though, so it
> will not surprise me if my new idea fails as well.)
>
> I found another item in arch/x86/kernel/acpi/boot.c -- which I suspect
> _is_ a bug -- but which had no effect on my lockup issue when I "fixed"
> it.  I will let a guru decide if I have found anything important:
>
> ===== BEGIN DIFF ==========================
> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
> index 2cdc9de..d5a9d9d 100644
> --- a/arch/x86/kernel/acpi/boot.c
> +++ b/arch/x86/kernel/acpi/boot.c
> @@ -669,7 +669,7 @@ static int __init acpi_parse_hpet(struct acpi_table_header *table)
>
>     memset(hpet_res, 0, sizeof(*hpet_res));
>     hpet_res->name = (void *)&hpet_res[1];
> -    hpet_res->flags = IORESOURCE_MEM;
> +    hpet_res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
>     snprintf((char *)hpet_res->name, HPET_RESOURCE_NAME_SIZE, "HPET %u",
>          hpet_tbl->sequence);
> ===== END DIFF ==========================
>
> The dynamically-allocated structure that hpet_res points to eventually gets
> added to the resource tree by
>
> static __init int hpet_insert_resource(void);
>
> which calls insert_resource().  My thought is that we are supposed to be
> marking the memory region as unavailable, so that nothing else will touch
> it later, right?
>
>
> Anyway, what happened in 3def3d6d to cause the regression?  I have a new
> hypothesis to test, but I'm too tired to continue right now -- so I'll hit
> it again tomorrow before I go to work:
>
> Up until now, I have focused on the fact that request_resource() was
> replaced by insert_resource().  I did not pay attention to another aspect
> of that commit -- the large change in the order of execution of where the
> kernel memory regions are added to the resource list.
>
> The original (2.6.25) approach, which works on my machine, is to identify
> RAM resources as they are added to the resource list, then tack on the
> kernel memory regions to the (proper) resource as it is added to the tree:
>
>  for (...) {
>    [...]
>    if (e820.map[i].type == E820_RAM) {
>        request_resource(res, code_resource);
>        request_resource(res, data_resource);
>        request_resource(res, bss_resource);
>    [...]
>    }
>    insert_resource(&iomem_resource, res);
>  }
>
> The problem commit moves those 3 request_resource() calls out of
> e820_reserve_resources() [arch/x86/kernel/e820{,_64}.c] and into
> setup_arch() [arch/x86/kernel/setup{,_64}.c].  The original code
> would have this happen when setup_arch() directly callse
> 820_reserve_resources(), but the commit moved those lines into
> setup_arch() itself, and they run sooner now than before...
> potentially affecting any resources added afterward.
>
> I don't see what effect this reordering could possibly have, since
> insert_resource() ignores the IORESOURCE_BUSY flag.  But that
> commit changed SOMETHING... and the two most obvious changes are
> the {request,insert}_resource() switch, and the repositioning of
> the request_resource() calls for {code,data,bss}_resource.
>
>
> I did a LOT of testing of insert_resource() last weekend, and it
> completely checked out:  it was only called about a dozen times,
> and it always inserted the resource without returning errors or
> accessing code paths for special cases.  That function is not
> broken internally, though its proper functioning might have
> unintended side effects I have not understood yet.
>
> I had the idea of setting up a side-by-side test -- taking the
> two versions of e820_reserve_resources() from before and after
> 3def3d6d, renaming them, and writing a tiny replacement of
> e820_reserve_resources() which would call both versions... with
> the idea that I could recurse the resulting trees and compare
> their contents for differences.
>
> While reading drivers/char/hpet.c and looking at the functions
> used there, I discovered request_region(), and realized that it
> would be difficult to compare the entire iomem_resource tree to
> a dummy tree only containing resources added by insert_resource()
> and request_resource().  It might be simpler to have my tiny
> e820_reserve_resources() replacement add each resource to 3 trees
> -- the real iomem_resource tree, and 2 dummy trees -- which could
> then be compared for differences just before the kernel locks up.
>

with reverting patch that change insert_resource to request_resource...
2.6.26 or 2.6.27-rcX still hange somewhere.

YH
