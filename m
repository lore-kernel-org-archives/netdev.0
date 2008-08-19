From: Ingo Molnar <mingo@elte.hu>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- connection between
	HPET and lockups found
Date: Tue, 19 Aug 2008 03:14:45 +0200
Message-ID: <20080819011445.GB14821@elte.hu>
References: <887650.67133.qm@web82104.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:41424 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752780AbYHSBPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2008 21:15:17 -0400
Content-Disposition: inline
In-Reply-To: <887650.67133.qm@web82104.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Witbrodt <dawitbro@sbcglobal.net> wrote:

> The output I get when the kernel locks up looks perfectly OK, except 
> maybe for the address of hpet_res (which I am not knowledgeable enough 
> to judge):
> 
> Data from arch/x86/kernel/acpi/boot.c:
>   hpet_res = ffff88000100f000    broken_bios: 0
>   sequence = 0    insert_resource() returned: 0
> 
> 
> I see some recent (Aug. 2008) discussion of alloc_bootmem() being 
> broken, so maybe that is related to my problem.
> 
> Does this connection between HPET and insert_resource() look 
> meaningful, or is this a coincidence?

it is definitely the angle i'd suspect the most.

perhaps we stomp over some piece of memory that is "available RAM" 
according to your BIOS, but in reality is used by something. With 
previous kernels we got lucky and have put a data structure there which 
kept your hpet still working. (a bit far-fetched i think, but the best 
theory i could come up with)

the address you printed out (0xffff88000100f000), does look _somewhat_ 
suspicious. It corresponds to the physical address of 0x100f000. That is 
_just_ above the 16MB boundary. It should not be relevant normally - but 
it's still somewhat suspicious.

To test this theory, could you tweak this:

  alloc_bootmem(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE);

to be:

  alloc_bootmem_low(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE);

this will allocate the hpet resource descriptor in lower RAM.

Another idea: could you increase HPET_RESOURCE_NAME_SIZE from 9 to 
something larger (via the patch below)? Maybe the bug is that this 
overflows:

        snprintf((char *)hpet_res->name, HPET_RESOURCE_NAME_SIZE, "HPET %u",
                 hpet_tbl->sequence);

and corrupts the memory next to the hpet resource descriptor. Depending 
on random details of the kernel, this might or might not turn into some 
real problem. The way of allocating the resource and its name string 
together in a bootmem allocation is a bit quirky - but should be Ok 
otherwise.

Hm, i see you have printed out hpet_tbl->sequence, and that gives 0, 
which should be borderline OK in terms of overflow. Cannot hurt to add 
this patch to your queue of test-patches :-/

Also, you could try to increase the bootmem allocation drastically, by 
say 16*1024 bytes, via:

 	hpet_res = alloc_bootmem(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE + 16*1024);
        hpet_res = (void *)hpet_res + 15*1024;

this will pad the memory at ~16MB and not use it for any resource. 
Arguably a really weird hack, but i'm running out of ideas ...

	Ingo

------------------>
>From 6319ee82bc363e2fd356782dacc9e01e5b33694e Mon Sep 17 00:00:00 2001
From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 19 Aug 2008 03:10:51 +0200
Subject: [PATCH] hpet: increase HPET_RESOURCE_NAME_SIZE

only had enough space for a 4 digit sprintf. If the index is wider
for any reason, we'll corrupt memory ...

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 arch/x86/kernel/acpi/boot.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 9d3528c..f6350aa 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -700,7 +700,7 @@ static int __init acpi_parse_hpet(struct acpi_table_header *table)
 	 * Allocate and initialize the HPET firmware resource for adding into
 	 * the resource tree during the lateinit timeframe.
 	 */
-#define HPET_RESOURCE_NAME_SIZE 9
+#define HPET_RESOURCE_NAME_SIZE 14
 	hpet_res = alloc_bootmem(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE);
 
 	hpet_res->name = (void *)&hpet_res[1];

