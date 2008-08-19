From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- connection between HPET and lockups found
Date: Mon, 18 Aug 2008 20:51:20 -0700 (PDT)
Message-ID: <310212.64521.qm@web82103.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82103.mail.mud.yahoo.com ([209.191.84.216]:28811 "HELO
	web82103.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752762AbYHSDvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 23:51:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > Does this connection between HPET and insert_resource() look 
> > meaningful, or is this a coincidence?
> 
> it is definitely the angle i'd suspect the most.
> 
> perhaps we stomp over some piece of memory that is "available RAM" 
> according to your BIOS, but in reality is used by something. With 
> previous kernels we got lucky and have put a data structure there which 
> kept your hpet still working. (a bit far-fetched i think, but the best 
> theory i could come up with)

Working... or NOT working.  Tonight I noticed something strange about 
my desktop machine, which _works_ with 2.6.2[67] tonight:  even though 
it shares the same HPET .config settings with the 2 problem machines,

CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_HPET=y
CONFIG_HPET_RTC_IRQ=y
CONFIG_HPET_MMAP=y

apparently no HPET device gets configured by the kernel:

$ dmesg | grep -i hpet
$


In contrast, I get this on the 2 "bad" machines if using the 2.6.26
kernel with the 2 problem commits reverted:

$ dmesg | grep -i hpet
ACPI: HPET 77FE80C0, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD       98)
ACPI: HPET id: 0x10b9a201 base: 0xfed00000
hpet clockevent registered
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 32-bit timers, 14318180 Hz
hpet_resources: 0xfed00000 is busy


That makes it looks like my third machine might have locked up with 
2.6.2[67] as well, but some problem configuring HPET actually prevents
it from locking up.  I wonder how widespread this badness really is 
after all?!  Are we not seeing more reports of lockups simply because 
people are getting lucky on AMD dual core machines, and having their
HPET _fail_ instead of their kernel locking up?


> the address you printed out (0xffff88000100f000), does look _somewhat_ 
> suspicious. It corresponds to the physical address of 0x100f000. That is 
> _just_ above the 16MB boundary. It should not be relevant normally - but 
> it's still somewhat suspicious.

I guess I was hitting around about the upper 32 bits -- I take it that
these pointers are virtualized, and the upper half is some sort of
descriptor?  In that pointer was in a flat memory model, then it would be
pointing _way_ past the end of my 2 GB of RAM, which would end around
0x0000000080000000.

I am not used to looking at raw pointer addresses, just pointer variable 
names.  I think I was recalling the /proc/iomem data that Yinghai asked 
for, but this stuff is just offsets stripped of descriptors, huh?:

$ cat /proc/iomem
00000000-0009f3ff : System RAM
0009f400-0009ffff : reserved
000f0000-000fffff : reserved
00100000-77fdffff : System RAM
  00200000-0056ca21 : Kernel code
  0056ca22-006ce3d7 : Kernel data
  00753000-0079a3c7 : Kernel bss
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


> To test this theory, could you tweak this:
> 
>   alloc_bootmem(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE);
> 
> to be:
> 
>   alloc_bootmem_low(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE);
> 
> this will allocate the hpet resource descriptor in lower RAM.

Results:  strange... still locked up, and more or less the same output,
especially the same address!:

Data from arch/x86/kernel/acpi/boot.c:
  hpet_res = ffff88000100f000    requested size: 65
  sequence = 0    insert_resource() returned:  0
  broken_bios: 0


Here is a section of 'git diff arch/x86/kernel/acpi/bootc' to
verify that I _did_ make the change:

===== BEGIN DIFF =============
@@ -701,13 +711,16 @@ static int __init acpi_parse_hpet(struct acpi_table_header *table)
      * the resource tree during the lateinit timeframe.
      */
 #define HPET_RESOURCE_NAME_SIZE 9
-    hpet_res = alloc_bootmem(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE);
+    hpet_res = alloc_bootmem_low (sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE);
+    dw_hpet_res = hpet_res;
+    dw_req_size = sizeof (*hpet_res) + HPET_RESOURCE_NAME_SIZE;
 
     hpet_res->name = (void *)&hpet_res[1];
     hpet_res->flags = IORESOURCE_MEM;
     snprintf((char *)hpet_res->name, HPET_RESOURCE_NAME_SIZE, "HPET %u",
          hpet_tbl->sequence);
===== END DIFF =============

It's like the change to alloc_bootmem_low made no difference at all!

The Aug. 12 messages I saw about alloc_bootmem() had to do with alignment
issues on 1 GB boundaries on x86_64 NUMA machines.  I certainly do have
x86_64 NUMA machines, but the behavior above seems to have nothing to do
with alignment issues.


> Another idea: could you increase HPET_RESOURCE_NAME_SIZE from 9 to 
> something larger (via the patch below)? Maybe the bug is that this 
> overflows:
> 
>         snprintf((char *)hpet_res->name, HPET_RESOURCE_NAME_SIZE, "HPET %u",
>                  hpet_tbl->sequence);
> 
> and corrupts the memory next to the hpet resource descriptor.

I noticed the potential for sequence to overflow the 9 byte buffer size
right away.  I got my hopes up... until I looked in include/acpi/actbl1.h:

struct acpi_table_hpet {
        struct acpi_table_header  header;
        u32  id;
        struct acpi_generic_address  address;
        u8  sequence;
        u16  minimum_tick;
        u8  flags;
};

The original programmer set HPET_RESOURCE_NAME_SIZE to 9 because the
combined length of "HPET " and a u8 is guaranteed to be <= 8.  I have
applied the change, nevertheless:


> @@ -700,7 +700,7 @@ static int __init acpi_parse_hpet(struct acpi_table_header 
> *table)
>      * Allocate and initialize the HPET firmware resource for adding into
>      * the resource tree during the lateinit timeframe.
>      */
> -#define HPET_RESOURCE_NAME_SIZE 9
> +#define HPET_RESOURCE_NAME_SIZE 14
>     hpet_res = alloc_bootmem(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE);

Results:  locked up

Data from arch/x86/kernel/acpi/boot.c:
  hpet_res = ffff88000100f000    requested size: 70
  sequence = 0    insert_resource() returned:  0
  broken_bios: 0


> Also, you could try to increase the bootmem allocation drastically, by 
> say 16*1024 bytes, via:
> 
>     hpet_res = alloc_bootmem(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE + 
> 16*1024);
>         hpet_res = (void *)hpet_res + 15*1024;
> 
> this will pad the memory at ~16MB and not use it for any resource. 
> Arguably a really weird hack, but i'm running out of ideas ...

I tried this:

-    hpet_res = alloc_bootmem(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE);
+    hpet_res = alloc_bootmem(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE + 16*1024);
+    hpet_res = (void*) hpet_res + 1024;

Results:  locked up

Data from arch/x86/kernel/acpi/boot.c:
  hpet_res = ffff88000100f400    requested size: 70
  sequence = 0    insert_resource() returned:  0
  broken_bios: 0

It looks like this resource does not get mangled, but maybe others are.

In a weekend experiment (for which I didn't post results), I recursed the
iomem_resource tree -- struggling to get all of the output to fit on one
80x25 screen.  Everything there seemed to be intact, with the addresses
matching the output of 'cat /proc/iomem' on a working kernel... except
(naturally) for some missing resources because the kernel locks before
getting to them.

But what does any of this have to do with the fact that the lockup occurs
in synchronize_rcu()?????  Madness... MADNESS!!!!!


[Old issue]  No one responded when I asked for some help with 'git' to
move my reverts up from "v2.6.26" to the HEAD of origin/master (or
tip/master).  Did you see that question, and do you have any advice?


Thanks Ingo,
Dave W.
