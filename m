From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG arm-soc] mvneta: tx queue done sometimes causes kernel
 panic
Date: Fri, 15 Feb 2013 08:52:12 -0800
Message-ID: <1360947132.19353.15.camel@edumazet-glaptop>
References: <511DE679.5080801@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <511DE679.5080801@hitachi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-02-15 at 16:40 +0900, Masami Hiramatsu wrote:
> Hi,
> 
> Here is a report about a suspicious bug in mvneta driver.
> 
> I'm trying to run the latest arm-soc tree (for-next branch) on
> Openblocks AX3 which runs Armada-XP SoC with 4 LAN ports, with
> attached kconfig.
> 
> When I have ran openvswitch on those LAN and tests the network
> performance by using apache bench with 64MB data file, the
> Openblocks sometimes hits kernel panic.
> 
> Curiously, when I used ping or ssh to the machine, this panic
> didn't happen. It seems that only high network load can cause
> this.
> 
> Here is the panic message.
> 
> 
> Unable to handle kernel paging request at virtual address aaaaaaaa
> pgd = c0004000
> [aaaaaaaa] *pgd=00000000
> Internal error: Oops: 15 [#1] SMP ARM
> Modules linked in: iptable_filter ip_tables openvswitch ledtrig_heartbeat
> CPU: 0    Not tainted  (3.8.0-rc7-00921-gd8be60d #16)
> PC is at put_page+0xc/0x60
> LR is at skb_release_data+0x90/0xf0
> pc : [<c00bc754>]    lr : [<c03b45ec>]    psr: 80000113
> sp : c063dd00  ip : c063dd10  fp : c063dd0c
> r10: 0000000e  r9 : c064a170  r8 : 00000000
> r7 : eba7ed00  r6 : e9701f40  r5 : 00000001  r4 : e9701f40
> r3 : e95bfd40  r2 : 000000aa  r1 : 00000000  r0 : aaaaaaaa
> Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
> Control: 10c53c7d  Table: 1d17c06a  DAC: 00000015
> Process swapper/0 (pid: 0, stack limit = 0xc063c238)
> Stack: (0xc063dd00 to 0xc063e000)
> dd00: c063dd24 c063dd10 c03b45ec c00bc754 e9701f40 0000000d c063dd3c c063dd28
> dd20: c03b4698 c03b4568 c0687a68 e9701f40 c063dd5c c063dd40 c03b47e8 c03b4688
> dd40: eba3fe00 0000000d e9701f40 eba7ed00 c063dd6c c063dd60 c03c0184 c03b4750
> dd60: c063dda4 c063dd70 c036bd2c c03c0144 00000000 00000000 00000000 eba3fe00
> dd80: 0000000e eba7ed00 0000000e eba80800 c063c000 eba80800 c063ddcc c063dda8
> dda0: c036c8b4 c036bc94 eba3fe00 00000001 eba7ed00 eba80800 eba3fe00 00000000
> ddc0: c063de0c c063ddd0 c036ca40 c036c820 00000000 00000000 eba7e800 eba7ed78
> dde0: c063ddfc 00000100 c036c95c eba7ed10 eba7e800 c06444f4 eba7e800 00000100
> de00: c063de44 c063de10 c002f4b8 c036c968 00000001 00000001 c063de44 c068d3c0
> de20: eba7ed10 c036c95c eba7e800 c06444f4 00000001 00000100 c063de94 c063de48
> de40: c0030ccc c002f444 00000000 ef061f40 c068ddd4 c068dbd4 00000000 c063de60
> de60: c063de60 c063de60 c0083690 c063e084 c063c000 00000001 00000001 c06444f4
> de80: 00000001 00000100 c063dee4 c063de98 c0029024 c0030a88 c063debc c063dea8
> dea0: c0086240 c001d7c8 00000000 c063c000 00200000 0000000a c00863e4 c063c000
> dec0: 00000000 c063df48 00000001 c06444f4 562f5842 000003ff c063defc c063dee8
> dee0: c0029434 c0028f18 0000006f 00000010 c063df14 c063df00 c000e1c8 c00293f4
> df00: c000e5c0 c0687fec c063df44 c063df18 c0008558 c000e164 c000e3f8 c000e5c0
> df20: 60000013 ffffffff c063df7c 0000406a 562f5842 00000000 c063dfac c063df48
> df40: c04af940 c0008514 ffffffed 00000000 027ab000 00000000 c063c000 c0687c08
> df60: c04b7598 c0649660 0000406a 562f5842 00000000 c063dfac c063df90 c063df90
> df80: c000e3f8 c000e5c0 60000013 ffffffff c0645118 00000000 c0625908 c2ddf1c0
> dfa0: c063dfbc c063dfb0 c04a328c c000e528 c063dff4 c063dfc0 c05fb848 c04a3234
> dfc0: ffffffff ffffffff c05fb328 00000000 00000000 c0625908 10c53c7d c06444f0
> dfe0: c0625904 c0649654 00000000 c063dff8 00008078 c05fb580 00000000 00000000
> Backtrace:
> [<c00bc748>] (put_page+0x0/0x60) from [<c03b45ec>] (skb_release_data+0x90/0xf0)
> [<c03b455c>] (skb_release_data+0x0/0xf0) from [<c03b4698>] (__kfree_skb+0x1c/0xc
> 8)
>  r5:0000000d r4:e9701f40
> [<c03b467c>] (__kfree_skb+0x0/0xc8) from [<c03b47e8>] (consume_skb+0xa4/0xac)
>  r4:e9701f40 r3:c0687a68
> [<c03b4744>] (consume_skb+0x0/0xac) from [<c03c0184>] (dev_kfree_skb_any+0x4c/0x54)
>  r7:eba7ed00 r6:e9701f40 r5:0000000d r4:eba3fe00
> [<c03c0138>] (dev_kfree_skb_any+0x0/0x54) from [<c036bd2c>]
> (mvneta_txq_bufs_free+0xa4/0xbc)
> [<c036bc88>] (mvneta_txq_bufs_free+0x0/0xbc) from [<c036c8b4>]
> (mvneta_txq_done+0xa0/0xec)
> [<c036c814>] (mvneta_txq_done+0x0/0xec) from [<c036ca40>]
> (mvneta_tx_done_timer_callback+0xe4/0x184)
> [<c036c95c>] (mvneta_tx_done_timer_callback+0x0/0x184) from [<c002f4b8>]
> (call_timer_fn+0x80/0x144)
> [<c002f438>] (call_timer_fn+0x0/0x144) from [<c0030ccc>]
> (run_timer_softirq+0x250/0x2cc)
> [<c0030a7c>] (run_timer_softirq+0x0/0x2cc) from [<c0029024>]
> (__do_softirq+0x118/0x248)
> [<c0028f0c>] (__do_softirq+0x0/0x248) from [<c0029434>] (irq_exit+0x4c/0x8c)
> [<c00293e8>] (irq_exit+0x0/0x8c) from [<c000e1c8>] (handle_IRQ+0x70/0x94)
>  r4:00000010 r3:0000006f
> [<c000e158>] (handle_IRQ+0x0/0x94) from [<c0008558>]
> (armada_370_xp_handle_irq+0x50/0xb0)
>  r5:c0687fec r4:c000e5c0
> [<c0008508>] (armada_370_xp_handle_irq+0x0/0xb0) from [<c04af940>]
> (__irq_svc+0x40/0x50)
> Exception stack(0xc063df48 to 0xc063df90)
> df40:                   ffffffed 00000000 027ab000 00000000 c063c000 c0687c08
> df60: c04b7598 c0649660 0000406a 562f5842 00000000 c063dfac c063df90 c063df90
> df80: c000e3f8 c000e5c0 60000013 ffffffff
> [<c000e51c>] (cpu_idle+0x0/0xf8) from [<c04a328c>] (rest_init+0x64/0x7c)
>  r7:c2ddf1c0 r6:c0625908 r5:00000000 r4:c0645118
> [<c04a3228>] (rest_init+0x0/0x7c) from [<c05fb848>] (start_kernel+0x2d4/0x32c)
> [<c05fb574>] (start_kernel+0x0/0x32c) from [<00008078>] (0x8078)
> Code: c00bbc74 e1a0c00d e92dd800 e24cb004 (e5902000)
> ---[ end trace 2a33dea814c6e473 ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> 
> Thank you,
> 

Driver is buggy, as TX completion can happen both from ndo_start_xmit()
and a timer, and there is no spinlock or appropriate synchro.
