From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH] MIPS: lib: iomap: Use __mem_{read,write}{b,w,l} for MMIO
Date: Wed, 2 Apr 2014 09:53:24 +0100
Message-ID: <1396428804-31075-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Ben Boeckel <mathstuf@gmail.com>,
        "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Jeffrey Deans <Jeffrey.Deans@imgtec.com>,
        Ralf Baechle <ralf@linux-mips.org>
To: <linux-mips@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Using the __raw_{read,write}{b,w,l} functions to perform
repeatable MMIO could result in problems if the host bus
does not match the endianness of the PCI/ISA. This problem
is visible on big-endian SEAD3 configurations after commit
2925f6c0c7af32720dcbadc586463aeceb6baa22
"net: smc911x: use io{read,write}*_rep accessors". This effectively
moves away from using the __mem_* variants to __raw_* ones
and causes a kernel bug as follows:

Call Trace:
CPU 0 Unable to handle kernel paging request at virtual address 00000000,
epc == 00000000, ra == 8012b3b0
Oops[#1]:
Cpu 0
$ 0   : 00000000 00000065 00000000 00000004
$ 4   : 00000000 00000000 9a82dd60 00000000
$ 8   : 00000000 00000000 a00ae278 00000007
$12   : 0000000e 00000011 804c4228 ffff9411
$16   : 00000100 00000000 80560000 807fc6d0
$20   : 807fc8d0 807fcad0 807fbec0 00000100
$24   : 00009150 80109be0
$28   : 9a82c000 9a82dd28 00000001 8012b3b0
Hi    : 00000000
Lo    : 00000000
epc   : 00000000   (null)
    Not tainted
ra    : 8012b3b0 call_timer_fn.isra.39+0x24/0x84
Status: 10009503    KERNEL EXL IE
Cause : 00800808
BadVA : 00000000
PrId  : 00019c20 (MIPS M14Kc)
Modules linked in:
Process swapper (pid: 1, threadinfo=9a82c000, task=9a82ba18, tls=00000000)
Stack : 00000040 00000000 00000007 8056732c 80580000 00000001 9a82dd60 00200200
        80560000 8012b598 8056732c 80580000 00000001 00000000 9a82dd60 9a82dd60
        00000000 807fbd44 807fbd40 805664e0 0000000a 80800000 00000004 80125924
        0000fda0 000007f0 80000000 00000001 80800000 007f0000 00200140 80166338
        00000000 8100fda0 0000fda0 000007f0 80000000 00000001 80800000 007f0000
        ...
Call Trace:
[<8012b598>] run_timer_softirq+0x188/0x1f4
[<80125924>] __do_softirq+0xc4/0x18c
[<80166338>] handle_percpu_irq+0x54/0x84
[<80125aa4>] do_softirq+0x68/0x70
[<80103b50>] do_IRQ+0x18/0x28
[<80125d1c>] irq_exit+0x94/0xc0
[<80125aa4>] do_softirq+0x68/0x70
[<80102130>] ret_from_irq+0x0/0x4
[<80102130>] ret_from_irq+0x0/0x4
[<80125d1c>] irq_exit+0x94/0xc0
[<803165b0>] __bzero+0xd4/0x164
[<80346d0c>] mem32_serial_out+0x0/0x1c
[<8010d4ac>] free_init_pages+0x98/0xfc
[<80180a08>] free_hot_cold_page+0x2c/0x1c4
[<80180bd8>] __free_pages+0x38/0x98
[<8010d4a0>] free_init_pages+0x8c/0xfc
[<8010d4ac>] free_init_pages+0x98/0xfc
[<8049fb04>] kernel_init+0x28/0x15c
[<80147484>] schedule_tail+0x1c/0x60
[<8049fadc>] kernel_init+0x0/0x15c
[<80102178>] ret_from_kernel_thread+0x14/0x1c
[<8040a06f>] skb_pad+0xe7/0x13c

CC: Steve Glendinning <steve.glendinning@shawell.net>
CC: Ben Boeckel <mathstuf@gmail.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: David S. Miller <davem@davemloft.net>
CC: netdev@vger.kernel.org
CC: Jeffrey Deans <Jeffrey.Deans@imgtec.com>
CC: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
It seems there are some inconsistencies on how the readsl/writesl and the
io{read,write}*_rep functions are implemented on MIPS. The former do
byte-swapping whereas the later do not. However, the way I read the commit
message from 2925f6c0c7af32720dcbadc586463aeceb6baa22, is  that the
io{read,write}*_rep functions are drop-in replacements for the readsl/writesl
ones which is not the case here. Or maybe there is something wrong with the
driver? Or maybe the SEAD3 board needs 'SWAP_IO_SPACE if CPU_BIG_ENDIAN'?

Assuming the patch is correct, it needs to be backported to >=3.8
kernels.
---
 arch/mips/lib/iomap.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/mips/lib/iomap.c b/arch/mips/lib/iomap.c
index e3acb2d..9f4bc52 100644
--- a/arch/mips/lib/iomap.c
+++ b/arch/mips/lib/iomap.c
@@ -97,14 +97,14 @@ EXPORT_SYMBOL(iowrite32be);
 
 /*
  * These are the "repeat MMIO read/write" functions.
- * Note the "__raw" accesses, since we don't want to
- * convert to CPU byte order. We write in "IO byte
- * order" (we also don't have IO barriers).
+ * Note the "__mem" accesses, since we want to convert
+ * to CPU byte order if the host bus happens to not match the
+ * endianness of PCI/ISA (see mach-generic/mangle-port.h).
  */
 static inline void mmio_insb(void __iomem *addr, u8 *dst, int count)
 {
 	while (--count >= 0) {
-		u8 data = __raw_readb(addr);
+		u8 data = __mem_readb(addr);
 		*dst = data;
 		dst++;
 	}
@@ -113,7 +113,7 @@ static inline void mmio_insb(void __iomem *addr, u8 *dst, int count)
 static inline void mmio_insw(void __iomem *addr, u16 *dst, int count)
 {
 	while (--count >= 0) {
-		u16 data = __raw_readw(addr);
+		u16 data = __mem_readw(addr);
 		*dst = data;
 		dst++;
 	}
@@ -122,7 +122,7 @@ static inline void mmio_insw(void __iomem *addr, u16 *dst, int count)
 static inline void mmio_insl(void __iomem *addr, u32 *dst, int count)
 {
 	while (--count >= 0) {
-		u32 data = __raw_readl(addr);
+		u32 data = __mem_readl(addr);
 		*dst = data;
 		dst++;
 	}
@@ -131,7 +131,7 @@ static inline void mmio_insl(void __iomem *addr, u32 *dst, int count)
 static inline void mmio_outsb(void __iomem *addr, const u8 *src, int count)
 {
 	while (--count >= 0) {
-		__raw_writeb(*src, addr);
+		__mem_writeb(*src, addr);
 		src++;
 	}
 }
@@ -139,7 +139,7 @@ static inline void mmio_outsb(void __iomem *addr, const u8 *src, int count)
 static inline void mmio_outsw(void __iomem *addr, const u16 *src, int count)
 {
 	while (--count >= 0) {
-		__raw_writew(*src, addr);
+		__mem_writew(*src, addr);
 		src++;
 	}
 }
@@ -147,7 +147,7 @@ static inline void mmio_outsw(void __iomem *addr, const u16 *src, int count)
 static inline void mmio_outsl(void __iomem *addr, const u32 *src, int count)
 {
 	while (--count >= 0) {
-		__raw_writel(*src, addr);
+		__mem_writel(*src, addr);
 		src++;
 	}
 }
-- 
1.9.1
