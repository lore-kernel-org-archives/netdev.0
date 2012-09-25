From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: [PATCH] net: sh-eth: fix sleeping in atomic context
Date: Tue, 25 Sep 2012 12:38:59 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1209251143210.9446@axis700.grange>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Mundt <lethal@linux-sh.org>, netdev@vger.kernel.org
To: linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The .ndo_get_stats() net-device operation can sleep, which leads on sh_eth
to the following BUG on the armadillo800eva board:

BUG: sleeping function called from invalid context at drivers/base/power/runtime.c:867
in_atomic(): 1, irqs_disabled(): 0, pid: 561, name: rpc.statd
Backtrace:
[<c000bfa0>] (dump_backtrace+0x0/0x110) from [<c0276a44>] (dump_stack+0x18/0x1c)
 r6:c0294118 r5:00000004 r4:c035e898 r3:60000013
[<c0276a2c>] (dump_stack+0x0/0x1c) from [<c0035c14>] (__might_sleep+0xec/0x10c)
[<c0035b28>] (__might_sleep+0x0/0x10c) from [<c019a918>] (__pm_runtime_resume+0x3c/0xac)
[<c019a8dc>] (__pm_runtime_resume+0x0/0xac) from [<c01b5a10>] (sh_eth_get_stats+0x24/0x180)
 r6:c0294118 r5:de0c6400 r4:de0c6000 r3:c01b59ec
[<c01b59ec>] (sh_eth_get_stats+0x0/0x180) from [<c01f12e8>] (dev_get_stats+0x5c/0x84)
 r6:c0294118 r5:de0c6000 r4:de1efad0 r3:c01b59ec
[<c01f128c>] (dev_get_stats+0x0/0x84) from [<c0202044>] (rtnl_fill_ifinfo+0x354/0x76c)
 r6:00000000 r5:de0c6000 r4:de3df980 r3:00000334
[<c0201cf0>] (rtnl_fill_ifinfo+0x0/0x76c) from [<c0202554>] (rtnl_dump_ifinfo+0xf8/0x1a8)
[<c020245c>] (rtnl_dump_ifinfo+0x0/0x1a8) from [<c020a010>] (netlink_dump+0x58/0x1c0)
[<c0209fb8>] (netlink_dump+0x0/0x1c0) from [<c020a6f8>] (netlink_dump_start+0x108/0x144)
 r7:de3a9e30 r6:de3bcd80 r5:de04f200 r4:de3a9e00
[<c020a5f0>] (netlink_dump_start+0x0/0x144) from [<c02036e4>] (rtnetlink_rcv_msg+0x160/0x2a0)
 r8:c020245c r7:00000f40 r6:de1efd00 r5:de3de180 r4:de3da680
r3:de1efd00
[<c0203584>] (rtnetlink_rcv_msg+0x0/0x2a0) from [<c020b47c>] (netlink_rcv_skb+0x54/0xb8)
[<c020b428>] (netlink_rcv_skb+0x0/0xb8) from [<c0203578>] (rtnetlink_rcv+0x20/0x2c)
r6:de3a9e00 r5:de3de180 r4:de3de180 r3:c0203558
[<c0203558>] (rtnetlink_rcv+0x0/0x2c) from [<c020b1b4>] (netlink_unicast+0x14c/0x21c)
 r4:de04f200 r3:c0203558
[<c020b068>] (netlink_unicast+0x0/0x21c) from [<c020bb4c>] (netlink_sendmsg+0x210/0x288)
 r8:00000000 r7:de1efe78 r6:de1eff54 r5:de3a9e00 r4:de3de180
[<c020b93c>] (netlink_sendmsg+0x0/0x288) from [<c01e21e0>] (sock_sendmsg+0x9c/0xb8)
[<c01e2144>] (sock_sendmsg+0x0/0xb8) from [<c01e2904>] (sys_sendto+0xb8/0xdc)
 r5:00000014 r4:de1efed4
[<c01e284c>] (sys_sendto+0x0/0xdc) from [<c0009120>] (ret_fast_syscall+0x0/0x30)

Remove sleeping functions from sh_eth_get_stats() to fix it.

Signed-off-by: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
---

I'm not sure, whether this is the correct fix, i.e., whether this function 
is guaranteed to be called on a resumed device, but at least this fixes 
this specific issue in 3.6-rc7, but leaves another BUG open:

BUG: sleeping function called from invalid context at include/linux/kernel.h:207
in_atomic(): 1, irqs_disabled(): 0, pid: 0, name: swapper
Backtrace: 
[<c00114e4>] (dump_backtrace+0x0/0x110) from [<c02b687c>] (dump_stack+0x18/0x1c)
 r6:c03a7cf8 r5:00000000 r4:00000000 r3:60000113
[<c02b6864>] (dump_stack+0x0/0x1c) from [<c003d704>] (__might_sleep+0xec/0x10c)
[<c003d618>] (__might_sleep+0x0/0x10c) from [<c0015a84>] (do_alignment+0x29c/0x700)
[<c00157e8>] (do_alignment+0x0/0x700) from [<c00084b4>] (do_DataAbort+0x3c/0xa0)
[<c0008478>] (do_DataAbort+0x0/0xa0) from [<c000da18>] (__dabt_svc+0x38/0x60)
Exception stack(0xc03a7cf8 to 0xc03a7d40)
7ce0:                                                       dd385cc0 dd2937c2
7d00: 00000000 dd385cc0 dd385cc0 c03cf8c8 dd23c7c0 00000000 00000001 00000000
7d20: 00000001 c03a7db4 c03a7d50 c03a7d40 c027832c c0277eb8 60000113 ffffffff
 r7:c03a7d2c r6:ffffffff r5:60000113 r4:c0277eb8
[<c0277e80>] (icmp_echo+0x0/0x70) from [<c027832c>] (icmp_rcv+0x144/0x16c)
[<c02781e8>] (icmp_rcv+0x0/0x16c) from [<c024e7f4>] (ip_local_deliver+0x104/0x1b8)
 r6:c03cf8c8 r5:00000001 r4:dd385cc0 r3:c02781e8
[<c024e6f0>] (ip_local_deliver+0x0/0x1b8) from [<c024e6ac>] (ip_rcv+0x4c0/0x504)
 r7:00000000 r6:0125010d r5:dd2937ae r4:dd385cc0
[<c024e1ec>] (ip_rcv+0x0/0x504) from [<c022eb7c>] (__netif_receive_skb+0x4cc/0x560)
 r9:00200000 r8:00000000 r7:00000008 r6:c03af040 r5:dd0e2000
r4:c03ae5e0
[<c022e6b0>] (__netif_receive_skb+0x0/0x560) from [<c022ec88>] (process_backlog+0x78/0x12c)
[<c022ec10>] (process_backlog+0x0/0x12c) from [<c022efa4>] (net_rx_action+0x58/0x148)
[<c022ef4c>] (net_rx_action+0x0/0x148) from [<c00211f4>] (__do_softirq+0x88/0x140)
[<c002116c>] (__do_softirq+0x0/0x140) from [<c002144c>] (irq_exit+0x4c/0x70)
[<c0021400>] (irq_exit+0x0/0x70) from [<c000e670>] (handle_IRQ+0x6c/0x8c)
[<c000e604>] (handle_IRQ+0x0/0x8c) from [<c00081d0>] (asm_do_IRQ+0x10/0x14)
 r5:60000013 r4:c000e8c0
[<c00081c0>] (asm_do_IRQ+0x0/0x14) from [<c0016de8>] (shmobile_handle_irq_intc+0x8/0x40)
Exception stack(0xc03a7f38 to 0xc03a7f80)
7f20:                                                       00000000 00000000
7f40: 00000000 00000000 c03a6000 ffffffff c039d3d0 7fffffff 40004059 412fc093
7f60: 00000000 c03a7f8c c03a7f90 c03a7f80 c000e8bc c000e8c0 60000013 ffffffff
[<c000e894>] (default_idle+0x0/0x34) from [<c000ee78>] (cpu_idle+0x58/0x9c)
[<c000ee20>] (cpu_idle+0x0/0x9c) from [<c02b22b4>] (rest_init+0x78/0x90)
 r4:c03a6000 r3:c02bac68
[<c02b223c>] (rest_init+0x0/0x90) from [<c0383874>] (start_kernel+0x248/0x288)
 r4:c03ae0ec r3:c03bff40
[<c038362c>] (start_kernel+0x0/0x288) from [<40008040>] (0x40008040)

 drivers/net/ethernet/renesas/sh_eth.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index bad8f2e..512c7cb 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1809,8 +1809,6 @@ static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
-	pm_runtime_get_sync(&mdp->pdev->dev);
-
 	ndev->stats.tx_dropped += sh_eth_read(ndev, TROCR);
 	sh_eth_write(ndev, 0, TROCR);	/* (write clear) */
 	ndev->stats.collisions += sh_eth_read(ndev, CDCR);
@@ -1826,7 +1824,6 @@ static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
 		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CNDCR);
 		sh_eth_write(ndev, 0, CNDCR);	/* (write clear) */
 	}
-	pm_runtime_put_sync(&mdp->pdev->dev);
 
 	return &ndev->stats;
 }
-- 
1.7.2.5

