From: Markus Brunner <super.firetwister@googlemail.com>
Subject: gianfar ooops after transmit timed out
Date: Thu, 2 Apr 2009 14:20:51 +0200
Message-ID: <200904021420.52241.super.firetwister@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Rini van Zetten <rini@arvoo.nl>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:64137 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbZDBMKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 08:10:14 -0400
Received: by bwz17 with SMTP id 17so476291bwz.37
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2009 05:10:10 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

my mpc8349 based board is known to have some problems with one ethernet phy 
and is producing more (< 0.001%) frame errors than it should. This is enough 
for the gianfar driver (of 2.6.27.20) to oops when I create lot's of packets 
with a ping flood. 
The oops occurs after "NETDEV WATCHDOG" reports that a "transmit timed out". 

The driver does not oops on the other phy, which does not produce frame 
errors.

Any Ideas?

Markus


ops: Kernel access of bad area, sig: 11 [#1]
PREEMPT RSBBA100
Modules linked in:
NIP: c01a10c4 LR: c013b254 CTR: c013c038
REGS: c02e7d20 TRAP: 0300   Not tainted  (2.6.27.20)
MSR: 00001032 <ME,IR,DR>  CR: 24000082  XER: 20000000
DAR: 000000a0, DSISR: 20000000
TASK = c02ce578[0] 'swapper' THREAD: c02e6000
GPR00: 000000a0 c02e7dd0 c02ce578 00000000 00000040 00000001 c02ec1c0 
00001032
GPR08: c080d1e0 df9ea800 00000000 00000000 24000082 ffffffff 0404f000 
00000000
GPR16: ffffffbf ffffffff ffffffff ffdff7ff ffffffff c02d0fd4 00100100 
00200200
GPR24: c031220c 00000001 00000001 00000000 00000000 df849800 ff109000 
df849b80
NIP [c01a10c4] dev_kfree_skb_irq+0x18/0x70
LR [c013b254] gfar_clean_tx_ring+0x70/0x11c
Call Trace:
[c02e7dd0] [c003e978] update_wall_time+0x730/0x744 (unreliable)
[c02e7df0] [c013b254] gfar_clean_tx_ring+0x70/0x11c
[c02e7e10] [c013c07c] gfar_poll+0x44/0x150
[c02e7e30] [c01a064c] net_rx_action+0xa8/0x19c
[c02e7e70] [c00251d4] __do_softirq+0x64/0xc0
[c02e7e90] [c0006384] do_softirq+0x40/0x58
[c02e7ea0] [c00250a8] irq_exit+0x40/0x9c
[c02e7eb0] [c000642c] do_IRQ+0x90/0xac
[c02e7ec0] [c0010ab4] ret_from_except+0x0/0x14
--- Exception: 501 at cpu_idle+0x9c/0xf8
    LR = cpu_idle+0x9c/0xf8
[c02e7f80] [c0009820] cpu_idle+0x58/0xf8 (unreliable)
[c02e7fa0] [c01fb8c8] __got2_end+0x7c/0x90
[c02e7fc0] [c026c794] start_kernel+0x2c0/0x2d4
[c02e7ff0] [00003438] 0x3438
Instruction dump:
7fa00124 80010024 bba10014 38210020 7c0803a6 4e800020 9421ffe0 7c0802a6
7c6b1b78 90010024 380300a0 bfa10014 <7d200028> 3129ffff 7d20012d 40a2fff4
Kernel panic - not syncing: Fatal exception in interrupt



The Trace with kgdb:


dev_kfree_skb_irq (skb=0x0)
    at 
arch/powerpc/include/asm/atomic.h:165
165             __asm__ __volatile__(
(gdb) bt
#0  dev_kfree_skb_irq (skb=0x0)
    at 
arch/powerpc/include/asm/atomic.h:165
#1  0xc013b254 in gfar_clean_tx_ring (dev=0xdf849800) at 
drivers/net/gianfar.c:1384
#2  0xc013c07c in gfar_poll (napi=0xdf849ba4, budget=<value optimized 
out>) at drivers/net/gianfar.c:1705
#3  0xc01a064c in net_rx_action (h=<value optimized out>) at 
net/core/dev.c:2384
#4  0xc00251d4 in __do_softirq () at kernel/softirq.c:208
#5  0xc0006384 in do_softirq () at arch/powerpc/kernel/irq.c:430
#6  0xc00250a8 in irq_exit () at kernel/softirq.c:284
#7  0xc000642c in do_IRQ (regs=<value optimized out>) at 
arch/powerpc/kernel/irq.c:325
#8  0xc0010ab4 in ret_from_except_full ()
#9  0xc0009820 in cpu_idle () at arch/powerpc/kernel/idle.c:59
#10 0xc01fb8c8 in rest_init () at init/main.c:481
#11 0xc026c794 in start_kernel () at init/main.c:691
#12 0x00003438 in ?? ()
Backtrace stopped: previous frame inner to this frame (corrupt stack?)
