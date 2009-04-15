From: Markus Brunner <super.firetwister@googlemail.com>
Subject: [PATCH] stop send queue before resetting gianfar
Date: Wed, 15 Apr 2009 09:51:23 +0200
Message-ID: <200904150951.23711.super.firetwister@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rini@arvoo.nl,
	Andy Fleming <afleming@freescale.com>
To: Linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

After a transmit timed out, the reset task will be called, which will free the
allocated resources(stop_gfar). If gfar_poll will be called before the
resources get allocated again gfar_clean_tx_ring will call
dev_kfree_skb_any(NULL).
This Patch calls netif_stop_queue before calling stop_gfar.

Signed-off-by: Markus Brunner <super.firetwister@gmail.com>
---
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

--- linux-2.6.29/drivers/net/gianfar.c.orig	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/drivers/net/gianfar.c	2009-04-15 09:47:04.000000000 +0200
@@ -1534,8 +1534,10 @@ static void gfar_reset_task(struct work_
 	struct net_device *dev = priv->dev;
 
 	if (dev->flags & IFF_UP) {
+		netif_stop_queue(dev);
 		stop_gfar(dev);
 		startup_gfar(dev);
+		netif_start_queue(dev);
 	}
 
 	netif_tx_schedule_all(dev);
