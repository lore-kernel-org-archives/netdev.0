From: Grant Grundler <iod00d@hp.com>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: Wed, 4 Feb 2004 16:49:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040205004952.GA27510@cup.hp.com>
References: <20040123232209.2739e6aa.ak@suse.de> <004201c3eb5f$ac4e9f00$740efea9@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Andi Kleen'" <ak@suse.de>, netdev@oss.sgi.com,
        "'Ragu Vatsavayi'" <raghava.vatsavayi@s2io.com>,
        "'Grant Grundler'" <iod00d@hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
Content-Disposition: inline
In-Reply-To: <004201c3eb5f$ac4e9f00$740efea9@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Feb 04, 2004 at 12:44:21PM -0800, Leonid Grossman wrote:
> 1) We did't find quad word memory operations(writeq and readq) on PCI
> bus for PPC64 architecture.

I would consider that a bug in the PPC64 port. You can submit
a patch to add a readq/writeq implementation using 32-bit ops
if the PCI Host controller doesn't support 64-bit transactions.
This doesn't always work since two 32-bit writes to a 64-bit register
is not the same as one 64-bit write. Your HW needs to be aware
of that if you want to support that platform.


> 2) We did't had a chance to test the driver on other big endian systems
> apart from PPC64. In PPC64 architecture though,
> I write/read a value to/from ioremaped address it swaps the value and
> behaves like a little endian m/c:  
> 
> For ex: if I  do writel(0x12345678, addr) then in it writes 
> addr: 78, (addr+1):56, (addr+2):34, (addr+3):12
...
> On a little endian m/c like IA32 also writel writes same values in a
> similar manner as shown above. 
> So the question is -
> Do all big endian machines with linux OS swap the values and write in
> little endian format?? 

Yes - I believe so.
There are ways to avoid the byte swap but I'm really not keen
on advocating this path. byte swapping is so much cheaper than
the PIO Reads, it just doesn't make sense to obfuscate the
code most of the time.

> 3)In PPC64 architecture dma_addr_t is u32, unlike remaining 64 bit
> architectures where it is defined as u64. Because of this we have
> to deal separately for PP64. 

You shouldn't be using dma_addr_t for layout of data structures
shared with the card. Several architectures *only* use 32-bit
DMA addresses (IOMMU for all DMA). It makes sense on those
architectures to define dma_addr_t as u32.
Try "fgrep dma_addr_t include/asm*/* | fgrep typedef" on linux-2.6 tree.


> So any suggestions will be useful, .i.e. generally how PPC64 developers
> deal with this?

Only use dma_addr_t to map data and not to define data structures
consumed by the card.

Some history from my perspective:
Fri, 9 Feb 2001, I started a discussion on linux-mm@kvack.org mailing
list on exactly this issue for linux-2.4. At the time Dave Miller
"owned" DMA interface and insisted dma_addr_t be u32.
He offered dma64_addr_t would be introduced in linux-2.5.
So far so good.

The only problem was IA64 was already defining dma_addr_t as u64
and mips was using "unsigned long".

Issue came up again on linux-kernel/linux-ia64 Feb 6, 2002.
(Subject: Proper fix for sym53c8xx_2 driver and dma64_addr_t)
It was pretty clear pci_dac_XXX() was the "preferred" interface
to use. But it made it impossible for a driver to support multiple
chips that supported both.

Somewhere along the line, I think with more thrashing about on
pci_set_dma_mask(), it was decided it was ok for dma_addr_t to
be u64 on architectures that supported it.

Last step into this mess was "64 Bits DMA Addresses for Alloc Consistent
Interfaces" thread started by SGI. Altix box needed it in order to
support PCI-X devices in PCI-X mode. (15 May 2003)
This resulted in "pci_set_consistent_dma_mask()" interface
in order to change the dma_mask for pci_alloc_consistent() calls.
AlexW just submitted support for this a week or two ago to 2.6 kernel.

> Say if we have some structure corresponding to memory region of our 
> hardware device which should be of 16 bytes.
...
> Then above definition will not work for PPC64, we need to modify it like
> this:
> struct hw {
> dma_addr_t  phys;
> char            *virt;
> #ifdef  ARCH32 
> u64 dummy;
> #endif
> #ifdef ARCH_PPC64
> u32 dummy;
> #endif
> }

Use "u64 phys" and it will always be correct.

And "char * virt" has the same problem. "char *" will vary
in size depending arch (ILP32 vs LP64 data model) as well.
You did claim this code worked on i386, ia64 and PPC64, right?

hth,
grant
