From: Eran Mann <emann@mrv.com>
Subject: e100 driver oopses on non-cache-coherent archs
Date: Tue, 08 Oct 2002 17:25:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA2F8F7.905@mrv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, Eran Mann <emann@mrv.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The e100 driver in recent 2.4.20pre kernels contains several instances 
of pci_alloc_consistent and pci_free_consistent called with some 
_lock_bh() taken, which causes an oops in non cache-coherent systems 
(currently PPC 8XX/4XX and ARM cpus apparently).

In a discussion on linux-kernel a couple of months ago the bottom line 
seemed to be that calling pci_free_consistent is forbidden in interrupt 
context, while calling pci_alloc_consistent SHOULD be ok in interrupt 
context (this is actually documented in Documentation/dma-mapping.txt), 
but is broken on non coherent CPUs
The thread starts here:
http://www.van-dijk.net/linuxkernel/200203/1644.html.gz

In contrast with the e100 module, the eepro100 module seems to work fine.

A sample of decoded oops, occurring on the insmod of e100.o on a Walnut 
(ppc405) board follows. The kernel is linuxppc_2_4_devel which already 
has 2.4.20-pre9 merged in:
ksymoops 2.4.4 on i686 2.4.20-pre9.  Options used
      -v vmlinux (specified)
      -k /tmp/k (specified)
      -L (specified)
      -o /tmp/lib/modules/2.4.20-pre9/ (specified)
      -m System.map (specified)

Warning (read_ksyms): no kernel symbols in ksyms, is /tmp/k a valid 
ksyms file?
No modules in ksyms, skipping objects
kernel BUG at cachemap.c:127!
Oops: Exception in kernel mode, sig: 4
NIP: C00105DC XER: 00000000 LR: C00105DC SP: C1B13D70 REGS: c1b13cc0 
TRAP: 0700
Using defaults from ksymoops -t elf32-i386 -a i386
MSR: 00009030 EE: 1 PR: 0 FP: 0 ME: 1 IR/DR: 11
TASK = c1b12000[90] 'insmod' Last syscall: 128
last math 00000000 last altivec 00000000
GPR00: C00105DC C1B13D70 C1B12000 0000001E 00001030 00000001 00000020 
C0180000
GPR08: 00000000 00000000 0000001F C1B13C90 82042882 1001F9E0 00000000 
00000000
GPR16: 00000000 00000000 00000001 00000000 00009032 01B13F40 C1B13EA8 
C02D17C0
GPR24: 00000001 C0180000 00004FC9 C02D1880 C0190000 C02D1880 C1E22960 
C301F000
Call backtrace:
C00105DC C000BFB8 C300F9FC C300D7FC C300DB50 C300B270 C300B158
C300A384 C00A4508 C00A459C C300A6C4 C001663C C000477C 1004F6A0
10003954 10004B04 10004DB4 0FED5DBC 00000000
Kernel panic: Aiee, killing interrupt handler!
Warning (Oops_read): Code line not seen, dumping what data is available

 >>EIP; c00105dc <consistent_free+48/68>   <=====
Trace; c00105dc <consistent_free+48/68>
Trace; c000bfb8 <pci_free_consistent+14/24>
Trace; c300f9fc <END_OF_CODE+2e65b64/????> e100_free_non_tx_cmd
Trace; c300d7fc <END_OF_CODE+2e63964/????> e100_exec_non_cu_cmd
Trace; c300db50 <END_OF_CODE+2e63cb8/????> e100_load_microcode
Trace; c300b270 <END_OF_CODE+2e613d8/????> e100_hw_init
Trace; c300b158 <END_OF_CODE+2e612c0/????> e100_init
Trace; c300a384 <END_OF_CODE+2e604ec/????> e100_found1
Trace; c00a4508 <pci_announce_device+54/80>
Trace; c00a459c <pci_register_driver+68/90>
Trace; c300a6c4 <END_OF_CODE+2e6082c/????> e100_init_module
Trace; c001663c <sys_init_module+7cc/8a8>
Trace; c000477c <ret_from_syscall_1+0/b4>
Trace; 1004f6a0 Before first symbol
Trace; 10003954 Before first symbol
Trace; 10004b04 Before first symbol
Trace; 10004db4 Before first symbol

The BUGging code is in arch/ppc/mm/cachemap.c (ARM code is similar):
...
/* This function will allocate the requested contiguous pages and
  * map them into the kernel's vmalloc() space.  This is done so we
  * get unique mapping for these pages, outside of the kernel's 1:1
  * virtual:physical mapping.  This is necessary so we can cover large
  * portions of the kernel with single large page TLB entries, and
  * still get unique uncached pages for consistent DMA.
  */
void *consistent_alloc(int gfp, size_t size, dma_addr_t *dma_handle)
{
	int order, err, i;
	unsigned long page, va, flags;
	phys_addr_t pa;
	struct vm_struct *area;
	void	 *ret;

	if (in_interrupt())
---->		BUG();

	/* Only allocate page size areas.
	*/
	size = PAGE_ALIGN(size);
	order = get_order(size);

....
-- 
Eran Mann
Senior Software Engineer
MRV International
Tel: 972-4-9936297
Fax: 972-4-9890430
www.mrv.com
