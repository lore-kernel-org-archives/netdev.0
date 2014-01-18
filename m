From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv4_dst_destroy panic regression after 3.10.15
Date: Fri, 17 Jan 2014 22:49:18 -0800
Message-ID: <1390027758.31367.505.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.10.1401171720560.15759@dinf>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dormando <dormando@rydia.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1401171720560.15759@dinf>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-01-17 at 17:25 -0800, dormando wrote:
> Hi,
> 
> Upgraded a few kernels to the latest 3.10 stable tree while tracking down
> a rare kernel panic, seems to have introduced a much more frequent kernel
> panic. Takes anywhere from 4 hours to 2 days to trigger:
> 
> <4>[196727.311203] general protection fault: 0000 [#1] SMP
> <4>[196727.311224] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan bridge coretemp crc32_pclmul ghash_clmulni_intel gpio_ich microcode ipmi_watchdog ipmi_devintf sb_edac edac_core lpc_ich mfd_core tpm_tis tpm tpm_bios ipmi_si ipmi_msghandler isci igb libsas i2c_algo_bit ixgbe ptp pps_core mdio
> <4>[196727.311333] CPU: 17 PID: 0 Comm: swapper/17 Not tainted 3.10.26 #1
> <4>[196727.311344] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
> <4>[196727.311364] task: ffff885e6f069700 ti: ffff885e6f072000 task.ti: ffff885e6f072000
> <4>[196727.311377] RIP: 0010:[<ffffffff815f8c7f>]  [<ffffffff815f8c7f>] ipv4_dst_destroy+0x4f/0x80
> <4>[196727.311399] RSP: 0018:ffff885effd23a70  EFLAGS: 00010282
> <4>[196727.311409] RAX: dead000000200200 RBX: ffff8854c398ecc0 RCX: 0000000000000040
> <4>[196727.311423] RDX: dead000000100100 RSI: dead000000100100 RDI: dead000000200200
> <4>[196727.311437] RBP: ffff885effd23a80 R08: ffffffff815fd9e0 R09: ffff885d5a590800
> <4>[196727.311451] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> <4>[196727.311464] R13: ffffffff81c8c280 R14: 0000000000000000 R15: ffff880e85ee16ce
> <4>[196727.311510] FS:  0000000000000000(0000) GS:ffff885effd20000(0000) knlGS:0000000000000000
> <4>[196727.311554] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> <4>[196727.311581] CR2: 00007a46751eb000 CR3: 0000005e65688000 CR4: 00000000000407e0
> <4>[196727.311625] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> <4>[196727.311669] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> <4>[196727.311713] Stack:
> <4>[196727.311733]  ffff8854c398ecc0 ffff8854c398ecc0 ffff885effd23ab0 ffffffff815b7f42
> <4>[196727.311784]  ffff88be6595bc00 ffff8854c398ecc0 0000000000000000 ffff8854c398ecc0
> <4>[196727.311834]  ffff885effd23ad0 ffffffff815b86c6 ffff885d5a590800 ffff8816827821c0
> <4>[196727.311885] Call Trace:
> <4>[196727.311907]  <IRQ>
> <4>[196727.311912]  [<ffffffff815b7f42>] dst_destroy+0x32/0xe0
> <4>[196727.311959]  [<ffffffff815b86c6>] dst_release+0x56/0x80
> <4>[196727.311986]  [<ffffffff81620bd5>] tcp_v4_do_rcv+0x2a5/0x4a0
> <4>[196727.312013]  [<ffffffff81622b5a>] tcp_v4_rcv+0x7da/0x820
> <4>[196727.312041]  [<ffffffff815fd9e0>] ? ip_rcv_finish+0x360/0x360
> <4>[196727.312070]  [<ffffffff815de02d>] ? nf_hook_slow+0x7d/0x150
> <4>[196727.312097]  [<ffffffff815fd9e0>] ? ip_rcv_finish+0x360/0x360
> <4>[196727.312125]  [<ffffffff815fda92>] ip_local_deliver_finish+0xb2/0x230
> <4>[196727.312154]  [<ffffffff815fdd9a>] ip_local_deliver+0x4a/0x90
> <4>[196727.312183]  [<ffffffff815fd799>] ip_rcv_finish+0x119/0x360
> <4>[196727.312212]  [<ffffffff815fe00b>] ip_rcv+0x22b/0x340
> <4>[196727.312242]  [<ffffffffa0339680>] ? macvlan_broadcast+0x160/0x160 [macvlan]
> <4>[196727.312275]  [<ffffffff815b0c62>] __netif_receive_skb_core+0x512/0x640
> <4>[196727.312308]  [<ffffffff811427fb>] ? kmem_cache_alloc+0x13b/0x150
> <4>[196727.312338]  [<ffffffff815b0db1>] __netif_receive_skb+0x21/0x70
> <4>[196727.312368]  [<ffffffff815b0fa1>] netif_receive_skb+0x31/0xa0
> <4>[196727.312397]  [<ffffffff815b1ae8>] napi_gro_receive+0xe8/0x140
> <4>[196727.312433]  [<ffffffffa00274f1>] ixgbe_poll+0x551/0x11f0 [ixgbe]
> <4>[196727.312463]  [<ffffffff815fe00b>] ? ip_rcv+0x22b/0x340
> <4>[196727.312491]  [<ffffffff815b1691>] net_rx_action+0x111/0x210
> <4>[196727.312521]  [<ffffffff815b0db1>] ? __netif_receive_skb+0x21/0x70
> <4>[196727.312552]  [<ffffffff810519d0>] __do_softirq+0xd0/0x270
> <4>[196727.312583]  [<ffffffff816cef3c>] call_softirq+0x1c/0x30
> <4>[196727.312613]  [<ffffffff81004205>] do_softirq+0x55/0x90
> <4>[196727.312640]  [<ffffffff81051c85>] irq_exit+0x55/0x60
> <4>[196727.312668]  [<ffffffff816cf5c3>] do_IRQ+0x63/0xe0
> <4>[196727.312696]  [<ffffffff816c5aaa>] common_interrupt+0x6a/0x6a
> <4>[196727.312722]  <EOI>
> <4>[196727.312727]  [<ffffffff8100a150>] ? default_idle+0x20/0xe0
> <4>[196727.312775]  [<ffffffff8100a8ff>] arch_cpu_idle+0xf/0x20
> <4>[196727.312803]  [<ffffffff8108d330>] cpu_startup_entry+0xc0/0x270
> <4>[196727.312833]  [<ffffffff816b276e>] start_secondary+0x1f9/0x200
> <4>[196727.312860] Code: 4a 9f e9 81 e8 13 cb 0c 00 48 8b 93 b0 00 00 00 48 bf 00 02 20 00 00 00 ad de 48 8b 83 b8 00 00 00 48 be 00 01 10 00 00 00 ad de <48> 89 42 08 48 89 10 48 89 bb b8 00 00 00 48 c7 c7 4a 9f e9 81
> <1>[196727.313071] RIP  [<ffffffff815f8c7f>] ipv4_dst_destroy+0x4f/0x80
> <4>[196727.313100]  RSP <ffff885effd23a70>
> <4>[196727.313377] ---[ end trace 64b3f14fae0f2e29 ]---
> <0>[196727.380908] Kernel panic - not syncing: Fatal exception in interrupt
> 
> 
> ... bisecting it's going to be a pain... I tried eyeballing the diffs and
> am trying a revert or two.
> 
> We've hit it in .25, .26 so far. I have .27 running but not sure if it
> crashed, so the change exists between .15 and .25.

Please try following fix, thanks for the report !

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 25071b48921c..78a50a22298a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1333,7 +1333,7 @@ static void ipv4_dst_destroy(struct dst_entry
*dst)
 
 	if (!list_empty(&rt->rt_uncached)) {
 		spin_lock_bh(&rt_uncached_lock);
-		list_del(&rt->rt_uncached);
+		list_del_init(&rt->rt_uncached);
 		spin_unlock_bh(&rt_uncached_lock);
 	}
 }
