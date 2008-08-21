From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Wed, 20 Aug 2008 19:48:50 -0700 (PDT)
Message-ID: <81856.40793.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Vivek Goyal <vgoyal@redhat.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82105.mail.mud.yahoo.com ([209.191.84.218]:33983 "HELO
	web82105.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753312AbYHUCsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 22:48:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




> > As a separate experiment, I started over with a clean version of
> > 700efc1b, then introduced the change from request_resource() to
> > insert_resource():
> > ===== BEGIN DIFF ================
> > diff --git a/arch/x86/kernel/e820_64.c b/arch/x86/kernel/e820_64.c
> > index a8694a3..988195d 100644
> > --- a/arch/x86/kernel/e820_64.c
> > +++ b/arch/x86/kernel/e820_64.c
> > @@ -245,7 +245,7 @@ void __init e820_reserve_resources(struct resource 
> *code_resource,
> >         res->start = e820.map[i].addr;
> >         res->end = res->start + e820.map[i].size - 1;
> >         res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> > -        request_resource(&iomem_resource, res);
> > +        insert_resource(&iomem_resource, res);
> >         if (e820.map[i].type == E820_RAM) {
> >             /*
> >              * We don't know which RAM region contains kernel data,
> > ===== END DIFF ================
> >
> > The kernel produced from the change HANGS!
> 
> because code/data/bss/crashk is inserted at first
> 
> in e820_reserve_resource if you call request_resource instead of
> insert_resource. the entries from e820 tables that has conflict to
> entries already added will not show in
> resource list /proc/iomem.

Ahh, what an error I made!  I made at least 3 errors in that post, and
now that I am home from work I can try to correct them.


> please send out /proc/iomem when it happens to boot.

OK, this was my first error.  My first experiment -- leave 
request_resource() alone, and move the additions of the kernel memory
regions to setup_arch() -- produced a booting kernel.  When that
happened, I was already late for work... so I produced the output
of 'cat /proc/iomem' from that kernel and moved on to my second test

I simply forgot to include the output in my message because I was
rushing to get out of the house!  Here it is:

==============================
00000000-0009f3ff : System RAM
0009f400-0009ffff : reserved
000f0000-000fffff : reserved
00200000-005570e1 : Kernel code
005570e2-006b4397 : Kernel data
00736000-0077d387 : Kernel bss
77fe0000-77fe2fff : ACPI Non-volatile Storage
77fe3000-77feffff : ACPI Tables
77ff0000-77ffffff : reserved
78000000-7fffffff : pnp 00:0d
d8000000-dfffffff : PCI Bus #01
  d8000000-dfffffff : 0000:01:05.0
    d8000000-d8ffffff : uvesafb
e0000000-efffffff : PCI MMCONFIG 0
  e0000000-efffffff : reserved
fdc00000-fdcfffff : PCI Bus #02
  fdcff000-fdcff0ff : 0000:02:05.0
    fdcff000-fdcff0ff : r8169
fdd00000-fdefffff : PCI Bus #01
  fdd00000-fddfffff : 0000:01:05.0
  fdee0000-fdeeffff : 0000:01:05.0
  fdefc000-fdefffff : 0000:01:05.2
    fdefc000-fdefffff : ICH HD audio
fdf00000-fdffffff : PCI Bus #02
fe020000-fe023fff : 0000:00:14.2
  fe020000-fe023fff : ICH HD audio
fe029000-fe0290ff : 0000:00:13.5
  fe029000-fe0290ff : ehci_hcd
fe02a000-fe02afff : 0000:00:13.4
  fe02a000-fe02afff : ohci_hcd
fe02b000-fe02bfff : 0000:00:13.3
  fe02b000-fe02bfff : ohci_hcd
fe02c000-fe02cfff : 0000:00:13.2
  fe02c000-fe02cfff : ohci_hcd
fe02d000-fe02dfff : 0000:00:13.1
  fe02d000-fe02dfff : ohci_hcd
fe02e000-fe02efff : 0000:00:13.0
  fe02e000-fe02efff : ohci_hcd
fe02f000-fe02f3ff : 0000:00:12.0
  fe02f000-fe02f3ff : ahci
fec00000-fec00fff : IOAPIC 0
  fec00000-fec00fff : pnp 00:0d
fed00000-fed003ff : HPET 0
  fed00000-fed003ff : 0000:00:14.0
fee00000-fee00fff : Local APIC
fff80000-fffeffff : pnp 00:0d
ffff0000-ffffffff : pnp 00:0d
==============================


My second (huge) error was to carry out my second experiment incorrectly.
When I replaced request_resource() with insert_resource(), I positioned
it before the code that added the kernel memory regions to the resource
for the system RAM region containing them.

I actually intended the second experiment to be different, but only
realized it when Yinghai corrected me (above).  Here is the diff for
the _actual_ experiment I intended:
===== BEGIN DIFF ================
diff --git a/arch/x86/kernel/e820_64.c b/arch/x86/kernel/e820_64.c
index a8694a3..f2498ae 100644
--- a/arch/x86/kernel/e820_64.c
+++ b/arch/x86/kernel/e820_64.c
@@ -245,7 +245,6 @@ void __init e820_reserve_resources(struct resource *code_resource,
         res->start = e820.map[i].addr;
         res->end = res->start + e820.map[i].size - 1;
         res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
-        request_resource(&iomem_resource, res);
         if (e820.map[i].type == E820_RAM) {
             /*
              * We don't know which RAM region contains kernel data,
@@ -260,6 +259,7 @@ void __init e820_reserve_resources(struct resource *code_resource,
                 request_resource(res, &crashk_res);
 #endif
         }
+        insert_resource(&iomem_resource, res);
     }
 }
===== END DIFF ================

This change produces a kernel that hangs.  The difference between the
results of the two experiments was what I was trying to show.  We now
know that:

- moving the code that adds {code,data,bss}_resource to the iomem_resource
tree out of e820_reserve_resources() and into setup_arch() is NOT what
caused my problem.

- the change from using request_resource() to insert_resource() seems
to be to blame.

My purpose in those experiments was to try to present a sort of "proof",
like a mathematical proof.  But my understanding of the code is fairly
shallow, so my "proof" might not mean very much.  I was hoping to 
provide useful data here, but only kernel developers can assess whether
or not this information is useful.


My third error was my "conclusion":

> My conclusion is that, somehow, the reordering of adding 
> {code,data,bss}_resource to the iomem_resource tree is doing funky 
> things to certain people's machines!

I meant to say just the opposite:  reordering the place where adding the
kernel memory resources to the iomem_resource tree is NOT the problem;
somehow the change to insert_resource() is the problem.

My apologies to all here:  I was racing to finish up, post my results,
and get to work... and completely botched the second experiment and the
message describing them!


Dave W.
