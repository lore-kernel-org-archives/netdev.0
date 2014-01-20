From: dormando <dormando@rydia.net>
Subject: Re: ipv4_dst_destroy panic regression after 3.10.15
Date: Sun, 19 Jan 2014 18:56:01 -0800 (PST)
Message-ID: <alpine.DEB.2.10.1401191854140.22661@dinf>
References: <alpine.DEB.2.10.1401171720560.15759@dinf> <1390027758.31367.505.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([69.46.88.68]:56790 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641AbaATC4K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jan 2014 21:56:10 -0500
In-Reply-To: <1390027758.31367.505.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Fri, 2014-01-17 at 17:25 -0800, dormando wrote:
> > Hi,
> >
> > Upgraded a few kernels to the latest 3.10 stable tree while tracking down
> > a rare kernel panic, seems to have introduced a much more frequent kernel
> > panic. Takes anywhere from 4 hours to 2 days to trigger:
> >
> > <4>[196727.311203] general protection fault: 0000 [#1] SMP
> > <4>[196727.311224] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan bridge coretemp crc32_pclmul ghash_clmulni_intel gpio_ich microcode ipmi_watchdog ipmi_devintf sb_edac edac_core lpc_ich mfd_core tpm_tis tpm tpm_bios ipmi_si ipmi_msghandler isci igb libsas i2c_algo_bit ixgbe ptp pps_core mdio
> > <4>[196727.311333] CPU: 17 PID: 0 Comm: swapper/17 Not tainted 3.10.26 #1
> > <4>[196727.311344] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
> > <4>[196727.311364] task: ffff885e6f069700 ti: ffff885e6f072000 task.ti: ffff885e6f072000
> > <4>[196727.311377] RIP: 0010:[<ffffffff815f8c7f>]  [<ffffffff815f8c7f>] ipv4_dst_destroy+0x4f/0x80
> > <4>[196727.311399] RSP: 0018:ffff885effd23a70  EFLAGS: 00010282
> > <4>[196727.311409] RAX: dead000000200200 RBX: ffff8854c398ecc0 RCX: 0000000000000040
> > <4>[196727.311423] RDX: dead000000100100 RSI: dead000000100100 RDI: dead000000200200
> > <4>[196727.311437] RBP: ffff885effd23a80 R08: ffffffff815fd9e0 R09: ffff885d5a590800
> > <4>[196727.311451] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> > <4>[196727.311464] R13: ffffffff81c8c280 R14: 0000000000000000 R15: ffff880e85ee16ce
> > <4>[196727.311510] FS:  0000000000000000(0000) GS:ffff885effd20000(0000) knlGS:0000000000000000
> > <4>[196727.311554] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > <4>[196727.311581] CR2: 00007a46751eb000 CR3: 0000005e65688000 CR4: 00000000000407e0
> > <4>[196727.311625] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > <4>[196727.311669] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > <4>[196727.311713] Stack:
> > <4>[196727.311733]  ffff8854c398ecc0 ffff8854c398ecc0 ffff885effd23ab0 ffffffff815b7f42
> > <4>[196727.311784]  ffff88be6595bc00 ffff8854c398ecc0 0000000000000000 ffff8854c398ecc0
> > <4>[196727.311834]  ffff885effd23ad0 ffffffff815b86c6 ffff885d5a590800 ffff8816827821c0
> > <4>[196727.311885] Call Trace:
> > <4>[196727.311907]  <IRQ>
> > <4>[196727.311912]  [<ffffffff815b7f42>] dst_destroy+0x32/0xe0
> > <4>[196727.311959]  [<ffffffff815b86c6>] dst_release+0x56/0x80
> > <4>[196727.311986]  [<ffffffff81620bd5>] tcp_v4_do_rcv+0x2a5/0x4a0
> > <4>[196727.312013]  [<ffffffff81622b5a>] tcp_v4_rcv+0x7da/0x820
> > <4>[196727.312041]  [<ffffffff815fd9e0>] ? ip_rcv_finish+0x360/0x360
> > <4>[196727.312070]  [<ffffffff815de02d>] ? nf_hook_slow+0x7d/0x150
> > <4>[196727.312097]  [<ffffffff815fd9e0>] ? ip_rcv_finish+0x360/0x360
> > <4>[196727.312125]  [<ffffffff815fda92>] ip_local_deliver_finish+0xb2/0x230
> > <4>[196727.312154]  [<ffffffff815fdd9a>] ip_local_deliver+0x4a/0x90
> > <4>[196727.312183]  [<ffffffff815fd799>] ip_rcv_finish+0x119/0x360
> > <4>[196727.312212]  [<ffffffff815fe00b>] ip_rcv+0x22b/0x340
> > <4>[196727.312242]  [<ffffffffa0339680>] ? macvlan_broadcast+0x160/0x160 [macvlan]
> > <4>[196727.312275]  [<ffffffff815b0c62>] __netif_receive_skb_core+0x512/0x640
> > <4>[196727.312308]  [<ffffffff811427fb>] ? kmem_cache_alloc+0x13b/0x150
> > <4>[196727.312338]  [<ffffffff815b0db1>] __netif_receive_skb+0x21/0x70
> > <4>[196727.312368]  [<ffffffff815b0fa1>] netif_receive_skb+0x31/0xa0
> > <4>[196727.312397]  [<ffffffff815b1ae8>] napi_gro_receive+0xe8/0x140
> > <4>[196727.312433]  [<ffffffffa00274f1>] ixgbe_poll+0x551/0x11f0 [ixgbe]
> > <4>[196727.312463]  [<ffffffff815fe00b>] ? ip_rcv+0x22b/0x340
> > <4>[196727.312491]  [<ffffffff815b1691>] net_rx_action+0x111/0x210
> > <4>[196727.312521]  [<ffffffff815b0db1>] ? __netif_receive_skb+0x21/0x70
> > <4>[196727.312552]  [<ffffffff810519d0>] __do_softirq+0xd0/0x270
> > <4>[196727.312583]  [<ffffffff816cef3c>] call_softirq+0x1c/0x30
> > <4>[196727.312613]  [<ffffffff81004205>] do_softirq+0x55/0x90
> > <4>[196727.312640]  [<ffffffff81051c85>] irq_exit+0x55/0x60
> > <4>[196727.312668]  [<ffffffff816cf5c3>] do_IRQ+0x63/0xe0
> > <4>[196727.312696]  [<ffffffff816c5aaa>] common_interrupt+0x6a/0x6a
> > <4>[196727.312722]  <EOI>
> > <4>[196727.312727]  [<ffffffff8100a150>] ? default_idle+0x20/0xe0
> > <4>[196727.312775]  [<ffffffff8100a8ff>] arch_cpu_idle+0xf/0x20
> > <4>[196727.312803]  [<ffffffff8108d330>] cpu_startup_entry+0xc0/0x270
> > <4>[196727.312833]  [<ffffffff816b276e>] start_secondary+0x1f9/0x200
> > <4>[196727.312860] Code: 4a 9f e9 81 e8 13 cb 0c 00 48 8b 93 b0 00 00 00 48 bf 00 02 20 00 00 00 ad de 48 8b 83 b8 00 00 00 48 be 00 01 10 00 00 00 ad de <48> 89 42 08 48 89 10 48 89 bb b8 00 00 00 48 c7 c7 4a 9f e9 81
> > <1>[196727.313071] RIP  [<ffffffff815f8c7f>] ipv4_dst_destroy+0x4f/0x80
> > <4>[196727.313100]  RSP <ffff885effd23a70>
> > <4>[196727.313377] ---[ end trace 64b3f14fae0f2e29 ]---
> > <0>[196727.380908] Kernel panic - not syncing: Fatal exception in interrupt
> >
> >
> > ... bisecting it's going to be a pain... I tried eyeballing the diffs and
> > am trying a revert or two.
> >
> > We've hit it in .25, .26 so far. I have .27 running but not sure if it
> > crashed, so the change exists between .15 and .25.
>
> Please try following fix, thanks for the report !
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 25071b48921c..78a50a22298a 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1333,7 +1333,7 @@ static void ipv4_dst_destroy(struct dst_entry
> *dst)
>
>  	if (!list_empty(&rt->rt_uncached)) {
>  		spin_lock_bh(&rt_uncached_lock);
> -		list_del(&rt->rt_uncached);
> +		list_del_init(&rt->rt_uncached);
>  		spin_unlock_bh(&rt_uncached_lock);
>  	}
>  }

This one crashed after a day and a half with a new-to-me trace. The other
machine running 3.10.27 + the reversion of the other patch is still going.
I now have two machines on that kernel to see if they're stable for more
than two days.

Panic#2 Part1
<4>[116124.368440] ------------[ cut here ]------------
<4>[116124.368450] WARNING: at net/core/dst.c:276 dst_release+0x7e/0x80()
<4>[116124.368451] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan bridge coretemp crc32_pclmul ghash_clmulni_intel gpio_ich isci ipmi_watchdog ipmi_devintf ixgbe microcode igb sb_edac edac_core libsas lpc_ich i2c_algo_bit mfd_core ptp pps_core tpm_tis mdio tpm tpm_bios ipmi_si ipmi_msghandler
<4>[116124.368470] CPU: 1 PID: 166084 Comm: cache-worker Tainted: G        W    3.10.27 #1
<4>[116124.368471] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
<4>[116124.368473]  ffffffff81a86f96 ffff885effc23b30 ffffffff816c045e ffff885effc23b70
<4>[116124.368475]  ffffffff81049930 ffff88be64ed4000 ffff88531e227980 00000000fffffff9
<4>[116124.368477]  ffffffff81c876c0 ffff8852ef21ec00 ffff882dffaaa5e2 ffff885effc23b80
<4>[116124.368479] Call Trace:
<4>[116124.368480]  <IRQ>  [<ffffffff816c045e>] dump_stack+0x19/0x1b
<4>[116124.368490]  [<ffffffff81049930>] warn_slowpath_common+0x70/0xa0
<4>[116124.368492]  [<ffffffff8104997a>] warn_slowpath_null+0x1a/0x20
<4>[116124.368494]  [<ffffffff815b870e>] dst_release+0x7e/0x80
<4>[116124.368497]  [<ffffffff816351f9>] inet_sock_destruct+0x129/0x1d0
<4>[116124.368500]  [<ffffffff8159d4bd>] __sk_free+0x1d/0x140
<4>[116124.368502]  [<ffffffff8159d675>] sk_free+0x25/0x30
<4>[116124.368506]  [<ffffffff8161e3fd>] sock_put+0x1d/0x30
<4>[116124.368508]  [<ffffffff81622afb>] tcp_v4_rcv+0x77b/0x820
<4>[116124.368511]  [<ffffffff815fd9e0>] ? ip_rcv_finish+0x360/0x360
<4>[116124.368515]  [<ffffffff815de03d>] ? nf_hook_slow+0x7d/0x150
<4>[116124.368517]  [<ffffffff815fd9e0>] ? ip_rcv_finish+0x360/0x360
<4>[116124.368519]  [<ffffffff815fda92>] ip_local_deliver_finish+0xb2/0x230
<4>[116124.368521]  [<ffffffff815fdd9a>] ip_local_deliver+0x4a/0x90
<4>[116124.368523]  [<ffffffff815fd799>] ip_rcv_finish+0x119/0x360
<4>[116124.368526]  [<ffffffff815fe00b>] ip_rcv+0x22b/0x340
<4>[116124.368529]  [<ffffffff815b0c82>] __netif_receive_skb_core+0x512/0x640
<4>[116124.368531]  [<ffffffff815b0dd1>] __netif_receive_skb+0x21/0x70
<4>[116124.368533]  [<ffffffff815b0ebb>] process_backlog+0x9b/0x170
<4>[116124.368535]  [<ffffffff815b16b1>] net_rx_action+0x111/0x210
<4>[116124.368538]  [<ffffffff810519d0>] __do_softirq+0xd0/0x270
<4>[116124.368542]  [<ffffffff816cf03c>] call_softirq+0x1c/0x30
<4>[116124.368546]  [<ffffffff81004215>] do_softirq+0x55/0x90
<4>[116124.368548]  [<ffffffff81051c85>] irq_exit+0x55/0x60
<4>[116124.368550]  [<ffffffff816cf6c3>] do_IRQ+0x63/0xe0
<4>[116124.368553]  [<ffffffff816c5baa>] common_interrupt+0x6a/0x6a
<4>[116124.368554]  <EOI>  [<ffffffff816cde02>] ? system_call_fastpath+0x16/0x1b
<4>[116124.368558] ---[ end trace 3ed2370f32f77a53 ]---
<7>[116125.177470] Peer 88.153.144.82:50962/80 unexpectedly shrunk window 2770172661:2770430920 (repaired)
<7>[116127.452869] Peer 88.153.144.82:50962/80 unexpectedly shrunk window 2770172661:2770430920 (repaired)
<7>[116132.003660] Peer 88.153.144.82:50962/80 unexpectedly shrunk window 2770172661:2770430920 (repaired)
<4>[116133.987013] general protection fault: 0000 [#1] SMP
<4>[116133.987033] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan bridge coretemp crc32_pclmul ghash_clmulni_intel gpio_ich isci ipmi_watchdog ipmi_devintf ixgbe microcode igb sb_edac edac_core libsas lpc_ich i2c_algo_bit mfd_core ptp pps_core tpm_tis mdio tpm tpm_bios ipmi_si ipmi_msghandler
<4>[116133.987137] CPU: 5 PID: 0 Comm: swapper/5 Tainted: G        W    3.10.27 #1
<4>[116133.987150] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
<4>[116133.987168] task: ffff885e6f7edc00 ti: ffff885e6f7f4000 task.ti: ffff885e6f7f4000
<4>[116133.987182] RIP: 0010:[<ffffffff8164f120>]  [<ffffffff8164f120>] iptable_raw_hook+0x20/0x70
<4>[116133.987202] RSP: 0018:ffff885effca38f0  EFLAGS: 00010246
<4>[116133.987212] RAX: ffca3aa0ffff885e RBX: ffca3aa0ffff885e RCX: ffca3aa0ffff885e
<4>[116133.987226] RDX: 0000000000000000 RSI: 0000000000000003 RDI: ffff885e3b447100
<4>[116133.987240] RBP: ffff885effca38f0 R08: ffff884b3183fc00 R09: ffff885e3b447100
<4>[116133.987254] R10: ffff88be6df7be80 R11: 0000000000000013 R12: ffff885effca3990
<4>[116133.987285] R13: 0000000000000000 R14: 0000000000000003 R15: ffff885e3b447100
<4>[116133.987328] FS:  0000000000000000(0000) GS:ffff885effca0000(0000) knlGS:0000000000000000
<4>[116133.987372] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[116133.987399] CR2: 00007a306991d000 CR3: 0000005e0e44f000 CR4: 00000000000407e0
<4>[116133.987441] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[116133.987484] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[116133.987526] Stack:
<4>[116133.987546]  ffff885effca3950 ffffffff815ddf7f ffff885effca3910 ffffffff81cb4c90
<4>[116133.987596]  ffff885effca3930 ffff885e66024f30 0000000000000020 ffff885e3b447100
<4>[116133.987645]  ffffffff81600e90 0000000000000003 ffff885e3b447100 0000000000000000
<4>[116133.987695] Call Trace:
<4>[116133.987716]  <IRQ>
<4>[116133.987721]  [<ffffffff815ddf7f>] nf_iterate+0x8f/0xd0
<4>[116133.987770]  [<ffffffff81600e90>] ? ip_forward_options+0x200/0x200
<4>[116133.987798]  [<ffffffff815de03d>] nf_hook_slow+0x7d/0x150
<4>[116133.987825]  [<ffffffff81600e90>] ? ip_forward_options+0x200/0x200
<4>[116133.987853]  [<ffffffff81602c22>] __ip_local_out+0x72/0x80
<4>[116133.987880]  [<ffffffff81602c46>] ip_local_out+0x16/0x30
<4>[116133.987906]  [<ffffffff81603f39>] ip_send_skb+0x19/0x50
<4>[116133.987932]  [<ffffffff81603fa7>] ip_push_pending_frames+0x37/0x40
<4>[116133.987960]  [<ffffffff8160438f>] ip_send_unicast_reply+0x29f/0x2f0
<4>[116133.987989]  [<ffffffff8161a5b6>] ? tcp_write_xmit+0x2b6/0xa90
<4>[116133.988019]  [<ffffffff8161e2ba>] tcp_v4_send_ack+0x1ba/0x210
<4>[116133.988048]  [<ffffffff816226f5>] tcp_v4_rcv+0x375/0x820
<4>[116133.988075]  [<ffffffff815de03d>] ? nf_hook_slow+0x7d/0x150
<4>[116133.988103]  [<ffffffff815fd9e0>] ? ip_rcv_finish+0x360/0x360
<4>[116133.988131]  [<ffffffff815fda92>] ip_local_deliver_finish+0xb2/0x230
<4>[116133.988159]  [<ffffffff815fdd9a>] ip_local_deliver+0x4a/0x90
<4>[116133.988187]  [<ffffffff815fd799>] ip_rcv_finish+0x119/0x360
<4>[116133.988214]  [<ffffffff815fe00b>] ip_rcv+0x22b/0x340
<4>[116133.988242]  [<ffffffff815b0c82>] __netif_receive_skb_core+0x512/0x640
<4>[116133.988272]  [<ffffffff81079b00>] ? resched_task+0x60/0x70
<4>[116133.988299]  [<ffffffff815b0dd1>] __netif_receive_skb+0x21/0x70
<4>[116133.988326]  [<ffffffff815b0ebb>] process_backlog+0x9b/0x170
<4>[116133.988354]  [<ffffffff8107a1a6>] ? ttwu_do_activate.constprop.91+0x66/0x70
<4>[116133.988384]  [<ffffffff815b16b1>] net_rx_action+0x111/0x210
<4>[116133.988412]  [<ffffffff810519d0>] __do_softirq+0xd0/0x270
<4>[116133.988441]  [<ffffffff816cf03c>] call_softirq+0x1c/0x30
<4>[116133.988470]  [<ffffffff81004215>] do_softirq+0x55/0x90
<4>[116133.988495]  [<ffffffff81051c85>] irq_exit+0x55/0x60
<4>[116133.988521]  [<ffffffff816cf6c3>] do_IRQ+0x63/0xe0
<4>[116133.988548]  [<ffffffff816c5baa>] common_interrupt+0x6a/0x6a
<4>[116133.988574]  <EOI>
<4>[116133.988578]  [<ffffffff8100a160>] ? default_idle+0x20/0xe0
<4>[116133.988624]  [<ffffffff8100a90f>] arch_cpu_idle+0xf/0x20
<4>[116133.988652]  [<ffffffff8108d330>] cpu_startup_entry+0xc0/0x270
<4>[116133.988681]  [<ffffffff816b288e>] start_secondary+0x1f9/0x200
<4>[116133.988708] Code: eb f2 66 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 83 ff 03 49 89 f1 48 89 e5 74 27 48 85 d2 48 89 d0 89 fe 48 0f 44 c1 4c 89 cf <48> 8b 80 e8 03 00 00 4c 8b 80 50 03 00 00 e8 6d d8 ff ff 5d c3
<1>[116133.988905] RIP  [<ffffffff8164f120>] iptable_raw_hook+0x20/0x70
<4>[116133.988934]  RSP <ffff885effca38f0>
<4>[116133.989217] ---[ end trace 3ed2370f32f77a54 ]---
<0>[116134.851050] Kernel panic - not syncing: Fatal exception in interrupt
