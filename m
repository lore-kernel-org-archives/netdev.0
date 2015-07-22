From: Peter Chen <peter.chen@freescale.com>
Subject: A Regression between v4.2-rc2 and v4.2-rc3
Date: Wed, 22 Jul 2015 13:44:46 +0800
Message-ID: <20150722054445.GA3651@shlinux2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Lunn <andrew@lunn.ch>, Fugang Duan <B38611@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0112.outbound.protection.outlook.com ([157.56.110.112]:47946
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755720AbbGVGyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 02:54:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi List,

I run out a kernel oops [2] for nfsroot at several imx6 boards
when rebase to v4.2-rc3, after revert below patch [1], it is ok.
This patch is just adding runtime pm for ipg clock, I am wonder
why it takes as a bug fix.

[1]
commit 6c3e921b18edca290099adfddde8a50236bf2d80
Author: Andrew Lunn <andrew@lunn.ch>
Date:   Mon Jul 6 20:34:55 2015 +0200

    net: fec: Ensure clocks are enabled while using mdio bus
    
    When a switch is attached to the mdio bus, the mdio bus can be used
    while the interface is not open. If the IPG clock is not enabled, MDIO
    reads/writes will simply time out.
    
    Add support for runtime PM to control this clock. Enable/disable this
    clock using runtime PM, with open()/close() and mdio read()/write()
    function triggering runtime PM operations. Since PM is optional, the
    IPG clock is enabled at probe and is no longer modified by
    fec_enet_clk_enable(), thus if PM is not enabled in the kernel, it is
    guaranteed the clock is running when MDIO operations are performed.
    
    Signed-off-by: Andrew Lunn <andrew@lunn.ch>
    Acked-by: Fugang Duan <B38611@freescale.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

[2]
[    2.534260] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.2.0-rc3 #387
[    2.540618] Hardware name: Freescale i.MX6 SoloX (Device Tree)
[    2.546455] Backtrace: 
[    2.548933] [<80014e00>] (dump_backtrace) from [<80015048>] (show_stack+0x20/0x24)
[    2.556506]  r6:80cd9db0 r5:00000000 r4:00000000 r3:00000000
[    2.562234] [<80015028>] (show_stack) from [<808b0094>] (dump_stack+0x8c/0xa4)
[    2.569467] [<808b0008>] (dump_stack) from [<80077b58>] (__lock_acquire+0x1d24/0x1ecc)
[    2.577385]  r6:00000000 r5:00000000 r4:80e7d900 r3:00000001
[    2.583107] [<80075e34>] (__lock_acquire) from [<80078608>] (lock_acquire+0xa4/0x124)
[    2.590937]  r10:60000193 r9:80d3e5c0 r8:00000000 r7:00000000 r6:00000000 r5:be0bdae0
[    2.598839]  r4:00000000
[    2.601400] [<80078564>] (lock_acquire) from [<80095870>] (call_timer_fn+0x78/0x1a0)
[    2.609144]  r10:00000001 r9:00200000 r8:bd8cd830 r7:00000100 r6:80d3e610 r5:be0bdae0
[    2.617045]  r4:bd8cd854
[    2.619600] [<800957f8>] (call_timer_fn) from [<80095a84>] (run_timer_softirq+0xec/0x2a4)
[    2.627777]  r10:bd8cd854 r9:00200000 r8:bd8cd830 r7:00200000 r6:80d3e610 r5:000000c9
[    2.635679]  r4:be7be440
[    2.638238] [<80095998>] (run_timer_softirq) from [<80033cbc>] (__do_softirq+0xdc/0x364)
[    2.646329]  r10:00000100 r9:00000004 r8:00000001 r7:80d3e32c r6:00000202 r5:00000001
[    2.654230]  r4:80c92084
[    2.656785] [<80033be0>] (__do_softirq) from [<800342b4>] (irq_exit+0xcc/0x140)
[    2.664094]  r10:00000001 r9:be01e000 r8:00000001 r7:00000000 r6:80c932d4 r5:00000000
[    2.671995]  r4:80c8d654
[    2.674549] [<800341e8>] (irq_exit) from [<80084254>] (__handle_domain_irq+0x7c/0xf0)
[    2.682380]  r4:80c8d654 r3:00000125
[    2.685990] [<800841d8>] (__handle_domain_irq) from [<800095a8>] (gic_handle_irq+0x30/0x70)
[    2.694342]  r9:00000000 r8:000007c1 r7:c080e100 r6:80c934bc r5:c080e10c r4:be0bdc18
[    2.702163] [<80009578>] (gic_handle_irq) from [<80015c24>] (__irq_svc+0x44/0x5c)
[    2.709647] Exception stack(0xbe0bdc18 to 0xbe0bdc60)
[    2.714702] dc00:                                                       00000001 be1103f8
[    2.722887] dc20: 00000000 60000193 20000113 80cda1a4 20000113 20000113 000007c1 00000000
[    2.731068] dc40: 00000001 be0bdc74 80e8ecc0 be0bdc60 800758d8 808ba154 20000113 ffffffff
[    2.739245]  r7:be0bdc4c r6:ffffffff r5:20000113 r4:808ba154
[    2.744976] [<808ba110>] (_raw_spin_unlock_irqrestore) from [<80385dd0>] (add_dma_entry+0xa4/0x164)
[    2.754023]  r5:02f4f305 r4:00000000
[    2.757633] [<80385d2c>] (add_dma_entry) from [<803861e0>] (debug_dma_map_page+0x108/0x120)
[    2.765984]  r7:be1e4010 r6:bef98980 r5:bd3cc140 r4:be280c00
[    2.771714] [<803860d8>] (debug_dma_map_page) from [<8051b604>] (fec_enet_new_rxbdp.isra.36+0xe4/0x148)
[    2.781107]  r10:be1e4010 r9:00000002 r8:bd8c9000 r7:bd3cc140 r6:007a7980 r5:000007c1
[    2.789008]  r4:00000140 r3:000007c1
[    2.792619] [<8051b520>] (fec_enet_new_rxbdp.isra.36) from [<8051c558>] (fec_enet_open+0x98/0x570)
[    2.801578]  r10:bd8cc0f0 r9:0000003c r8:bd8c9640 r7:bd8cc000 r6:bd254480 r5:bd8c9000
[    2.809481]  r4:bf088780
[    2.812043] [<8051c4c0>] (fec_enet_open) from [<806873a4>] (__dev_open+0xb8/0x120)
[    2.819613]  r10:80d20f00 r9:bd8c9000 r8:00000000 r7:bd8c9030 r6:809194c4 r5:00000000
[    2.827515]  r4:bd8c9000
[    2.830069] [<806872ec>] (__dev_open) from [<80687680>] (__dev_change_flags+0x98/0x158)
[    2.838073]  r7:00001002 r6:00001003 r5:00000001 r4:bd8c9000
[    2.843797] [<806875e8>] (__dev_change_flags) from [<80687768>] (dev_change_flags+0x28/0x58)
[    2.852235]  r8:00000000 r7:80d20ff0 r6:00001002 r5:bd8c9138 r4:bd8c9000 r3:80c678b4
[    2.860060] [<80687740>] (dev_change_flags) from [<80c43ed8>] (ip_auto_config.part.14+0x184/0x1020)
[    2.869106]  r8:80d20f00 r7:80d20ff0 r6:80d20ff0 r5:00001002 r4:00000001 r3:80c678b4
[    2.876927] [<80c43d54>] (ip_auto_config.part.14) from [<80c44db8>] (ip_auto_config+0x44/0x5c)
[    2.885539]  r10:00000000 r9:80c5d060 r8:80c5d05c r7:80c44d74 r6:bd121a00 r5:80c967e0
[    2.893444]  r4:80c967e0
[    2.895998] [<80c44d74>] (ip_auto_config) from [<800098dc>] (do_one_initcall+0xb8/0x208)
[    2.904098] [<80009824>] (do_one_initcall) from [<80be2e74>] (kernel_init_freeable+0x12c/0x1f4)
[    2.912797]  r10:80be2604 r9:80c5d060 r8:80c5d05c r7:80d58000 r6:80c8af34 r5:80d58000
[    2.920700]  r4:00000007
[    2.923263] [<80be2d48>] (kernel_init_freeable) from [<808aa4bc>] (kernel_init+0x18/0xfc)
[    2.931441]  r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:808aa4a4
[    2.939342]  r4:00000000
[    2.941899] [<808aa4a4>] (kernel_init) from [<80010a98>] (ret_from_fork+0x14/0x3c)
[    2.949469]  r4:00000000 r3:00000000
[    2.953083] Unable to handle kernel paging request at virtual address bd8cd830
[    2.960307] pgd = 80004000
[    2.963016] [bd8cd830] *pgd=bd81141e(bad)
[    2.967058] Internal error: Oops: 8000000d [#1] SMP ARM
[    2.972288] Modules linked in:
[    2.975361] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.2.0-rc3 #387
[    2.981716] Hardware name: Freescale i.MX6 SoloX (Device Tree)
[    2.987552] task: be110000 ti: be0bc000 task.ti: be0bc000
[    2.992954] PC is at 0xbd8cd830
[    2.996102] LR is at call_timer_fn+0x98/0x1a0
[    3.000463] pc : [<bd8cd830>]    lr : [<80095890>]    psr: 60000193
[    3.000463] sp : be0bdad0  ip : be0bdad0  fp : be0bdb1c
[    3.011942] r10: 80d3e610  r9 : 00200000  r8 : bd8cd830
[    3.017169] r7 : 00000100  r6 : 80d3e610  r5 : be0bdae0  r4 : bd8cd854
[    3.023697] r3 : 80cd9e90  r2 : be110000  r1 : be110000  r0 : 00200000
[    3.030228] Flags: nZCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
[    3.037626] Control: 10c5387d  Table: 8000404a  DAC: 00000015
[    3.043374] Process swapper/0 (pid: 1, stack limit = 0xbe0bc210)
[    3.049383] Stack: (0xbe0bdad0 to 0xbe0be000)
[    3.053744] dac0:                                     00000001 00000000 800957f8 be7be440
[    3.061926] dae0: be0bdae0 00000000 00000000 be08e400 60000193 be7be440 000000c9 80d3e610
[    3.070107] db00: 00200000 bd8cd830 00200000 bd8cd854 be0bdb64 be0bdb20 80095a84 80095804
[    3.078288] db20: 80d3e32c be7be97c be7be87c 00000000 800759a8 be7be4b0 00000000 80c92084
[    3.086470] db40: 00000001 00000202 80d3e32c 00000001 00000004 00000100 be0bdbb4 be0bdb68
[    3.094651] db60: 80033cbc 800959a4 60000193 be01a264 be0bdb94 00000001 00204140 ffff8bca
[    3.102832] db80: 0000000a 00000002 be0bdbb4 80c8d654 00000000 80c932d4 00000000 00000001
[    3.111013] dba0: be01e000 00000001 be0bdbcc be0bdbb8 800342b4 80033bec 00000125 80c8d654
[    3.119194] dbc0: be0bdbf4 be0bdbd0 80084254 800341f4 be0bdc18 c080e10c 80c934bc c080e100
[    3.127375] dbe0: 000007c1 00000000 be0bdc14 be0bdbf8 800095a8 800841e4 808ba154 20000113
[    3.135557] dc00: ffffffff be0bdc4c be0bdc74 be0bdc18 80015c24 80009584 00000001 be1103f8
[    3.143739] dc20: 00000000 60000193 20000113 80cda1a4 20000113 20000113 000007c1 00000000
[    3.151920] dc40: 00000001 be0bdc74 80e8ecc0 be0bdc60 800758d8 808ba154 20000113 ffffffff
[    3.160101] dc60: 00000000 02f4f305 be0bdca4 be0bdc78 80385dd0 808ba11c be0bdca4 803861b8
[    3.168282] dc80: 80d38800 be280c00 be280c00 bd3cc140 bef98980 be1e4010 be0bdcd4 be0bdca8
[    3.176464] dca0: 803861e0 80385d38 000007c1 00000140 000007c1 007a7980 bd3cc140 bd8c9000
[    3.184645] dcc0: 00000002 be1e4010 be0bdd1c be0bdcd8 8051b604 803860e4 00000002 bd3cc140
[    3.192826] dce0: 00000001 bd3cc100 81552b80 bf088784 80674c40 bf088780 bd8c9000 bd254480
[    3.201007] dd00: bd8cc000 bd8c9640 0000003c bd8cc0f0 be0bdd84 be0bdd20 8051c558 8051b52c
[    3.209189] dd20: ffffffff be0bdd8c 0000000d 00000002 00001002 00000000 bd8c9000 80d20f00
[    3.217369] dd40: be0bdd64 be0bdd50 80051678 8005157c 00000000 8067ce90 be0bdd84 bd8c9000
[    3.225552] dd60: 00000000 809194c4 bd8c9030 00000000 bd8c9000 80d20f00 be0bddac be0bdd88
[    3.233733] dd80: 806873a4 8051c4cc be0bddac bd8c9000 bd8c9000 00000001 00001003 00001002
[    3.241914] dda0: be0bddd4 be0bddb0 80687680 806872f8 80c678b4 bd8c9000 bd8c9138 00001002
[    3.250095] ddc0: 80d20ff0 00000000 be0bddfc be0bddd8 80687768 806875f4 80c678b4 00000001
[    3.258277] dde0: 00001002 80d20ff0 80d20ff0 80d20f00 be0bdeb4 be0bde00 80c43ed8 8068774c
[    3.266457] de00: 00000000 80cb4d74 bd11f780 bd121a00 be0bde2c 808b9e00 00000000 60000113
[    3.274640] de20: be03392c 80cb4d18 00000002 80c678c4 bd11f780 808ba0c8 60000113 80cb4d18
[    3.282822] de40: be0bde64 be0bde50 808ba0c8 8007c0f4 be227e31 00000000 be0bde94 be0bde68
[    3.291003] de60: 801aa300 808ba0a4 80075a2c 80b84338 80c967e0 bd11f780 80947ac4 bd121a00
[    3.299184] de80: 80c44d74 80c5d05c be0bdeb4 80c967e0 80c967e0 bd121a00 80c44d74 80c5d05c
[    3.307366] dea0: 80c5d060 00000000 be0bdecc be0bdeb8 80c44db8 80c43d60 00000000 00000000
[    3.315547] dec0: be0bdf4c be0bded0 800098dc 80c44d80 be0bdefc be0bdee0 80be2620 80360324
[    3.323727] dee0: 00000000 00000000 befffac5 808dd7e8 be0bdf4c be0bdf00 8004fb34 80be2610
[    3.331908] df00: 00000000 00000000 00000000 00000007 00000007 befffad3 80bde400 80b265c0
[    3.340089] df20: 600001d3 00000007 80d58000 80c8af34 80d58000 80c5d05c 80c5d060 80be2604
[    3.348270] df40: be0bdf94 be0bdf50 80be2e74 80009830 00000007 00000007 00000000 80be2604
[    3.356451] df60: be110000 000000d6 bf1bfffd 00000000 808aa4a4 00000000 00000000 00000000
[    3.364632] df80: 00000000 00000000 be0bdfac be0bdf98 808aa4bc 80be2d54 00000000 00000000
[    3.372813] dfa0: 00000000 be0bdfb0 80010a98 808aa4b0 00000000 00000000 00000000 00000000
[    3.380993] dfc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    3.389174] dfe0: 00000000 00000000 00000000 00000000 00000013 00000000 bdeb777b 77ddf377
[    3.397350] Backtrace: 
[    3.399821] [<800957f8>] (call_timer_fn) from [<80095a84>] (run_timer_softirq+0xec/0x2a4)
[    3.407999]  r10:bd8cd854 r9:00200000 r8:bd8cd830 r7:00200000 r6:80d3e610 r5:000000c9
[    3.415902]  r4:be7be440
[    3.418457] [<80095998>] (run_timer_softirq) from [<80033cbc>] (__do_softirq+0xdc/0x364)
[    3.426549]  r10:00000100 r9:00000004 r8:00000001 r7:80d3e32c r6:00000202 r5:00000001
[    3.434450]  r4:80c92084
[    3.437006] [<80033be0>] (__do_softirq) from [<800342b4>] (irq_exit+0xcc/0x140)
[    3.444315]  r10:00000001 r9:be01e000 r8:00000001 r7:00000000 r6:80c932d4 r5:00000000
[    3.452216]  r4:80c8d654
[    3.454769] [<800341e8>] (irq_exit) from [<80084254>] (__handle_domain_irq+0x7c/0xf0)
[    3.462600]  r4:80c8d654 r3:00000125
[    3.466208] [<800841d8>] (__handle_domain_irq) from [<800095a8>] (gic_handle_irq+0x30/0x70)
[    3.474558]  r9:00000000 r8:000007c1 r7:c080e100 r6:80c934bc r5:c080e10c r4:be0bdc18
[    3.482379] [<80009578>] (gic_handle_irq) from [<80015c24>] (__irq_svc+0x44/0x5c)
[    3.489864] Exception stack(0xbe0bdc18 to 0xbe0bdc60)
[    3.494920] dc00:                                                       00000001 be1103f8
[    3.503101] dc20: 00000000 60000193 20000113 80cda1a4 20000113 20000113 000007c1 00000000
[    3.511282] dc40: 00000001 be0bdc74 80e8ecc0 be0bdc60 800758d8 808ba154 20000113 ffffffff
[    3.519459]  r7:be0bdc4c r6:ffffffff r5:20000113 r4:808ba154
[    3.525187] [<808ba110>] (_raw_spin_unlock_irqrestore) from [<80385dd0>] (add_dma_entry+0xa4/0x164)
[    3.534233]  r5:02f4f305 r4:00000000
[    3.537841] [<80385d2c>] (add_dma_entry) from [<803861e0>] (debug_dma_map_page+0x108/0x120)
[    3.546192]  r7:be1e4010 r6:bef98980 r5:bd3cc140 r4:be280c00
[    3.551918] [<803860d8>] (debug_dma_map_page) from [<8051b604>] (fec_enet_new_rxbdp.isra.36+0xe4/0x148)
[    3.561311]  r10:be1e4010 r9:00000002 r8:bd8c9000 r7:bd3cc140 r6:007a7980 r5:000007c1
[    3.569212]  r4:00000140 r3:000007c1
[    3.572823] [<8051b520>] (fec_enet_new_rxbdp.isra.36) from [<8051c558>] (fec_enet_open+0x98/0x570)
[    3.581782]  r10:bd8cc0f0 r9:0000003c r8:bd8c9640 r7:bd8cc000 r6:bd254480 r5:bd8c9000
[    3.589685]  r4:bf088780
[    3.592245] [<8051c4c0>] (fec_enet_open) from [<806873a4>] (__dev_open+0xb8/0x120)
[    3.599816]  r10:80d20f00 r9:bd8c9000 r8:00000000 r7:bd8c9030 r6:809194c4 r5:00000000
[    3.607717]  r4:bd8c9000
[    3.610271] [<806872ec>] (__dev_open) from [<80687680>] (__dev_change_flags+0x98/0x158)
[    3.618276]  r7:00001002 r6:00001003 r5:00000001 r4:bd8c9000
[    3.623999] [<806875e8>] (__dev_change_flags) from [<80687768>] (dev_change_flags+0x28/0x58)
[    3.632437]  r8:00000000 r7:80d20ff0 r6:00001002 r5:bd8c9138 r4:bd8c9000 r3:80c678b4
[    3.640259] [<80687740>] (dev_change_flags) from [<80c43ed8>] (ip_auto_config.part.14+0x184/0x1020)
[    3.649304]  r8:80d20f00 r7:80d20ff0 r6:80d20ff0 r5:00001002 r4:00000001 r3:80c678b4
[    3.657125] [<80c43d54>] (ip_auto_config.part.14) from [<80c44db8>] (ip_auto_config+0x44/0x5c)
[    3.665736]  r10:00000000 r9:80c5d060 r8:80c5d05c r7:80c44d74 r6:bd121a00 r5:80c967e0
[    3.673639]  r4:80c967e0
[    3.676191] [<80c44d74>] (ip_auto_config) from [<800098dc>] (do_one_initcall+0xb8/0x208)
[    3.684291] [<80009824>] (do_one_initcall) from [<80be2e74>] (kernel_init_freeable+0x12c/0x1f4)
[    3.692990]  r10:80be2604 r9:80c5d060 r8:80c5d05c r7:80d58000 r6:80c8af34 r5:80d58000
[    3.700891]  r4:00000007
[    3.703448] [<80be2d48>] (kernel_init_freeable) from [<808aa4bc>] (kernel_init+0x18/0xfc)
[    3.711626]  r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:808aa4a4
[    3.719528]  r4:00000000
[    3.722083] [<808aa4a4>] (kernel_init) from [<80010a98>] (ret_from_fork+0x14/0x3c)
[    3.729654]  r4:00000000 r3:00000000
[    3.733261] Code: 00000000 80b4e09c bd8cd828 bd8cd828 (ffffffe1) 
[    3.739363] ---[ end trace 2fc1c25aaad4e6a0 ]---
[    3.743985] Kernel panic - not syncing: Fatal exception in interrupt
[    3.750346] ---[ end Kernel panic - not syncing: Fatal exception in interrupt
[   80.548178] random: nonblocking pool is initialized

-- 

Best Regards,
Peter Chen
