From: dormando <dormando@rydia.net>
Subject: Multitude of dst obsolescense race conditions
Date: Wed, 14 May 2014 02:57:43 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405140233210.16893@dtop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Given a machine with frequently changing routes (ie; a router with an
active internet BGP table and multiple interfaces), there're at least
several places where obsolete dst's are handled improperly. If I pause the
route changes, the crashes appear to stop. This first one has a crash
utility we've made, so I was able to more quickly find a patch and test
it. The others take time to reproduce.

I'm testing against 3.10.39, but I think if these were fixed they'd be
backported to stable? I've also had recent 3.12's running that have
crashed in the same spots. Anyway correct me if I'm wrong...

There's this crash:

<4>[  550.583536] Call Trace:
<4>[  550.583593]  [<ffffffff815b7f62>] dst_destroy+0x32/0xe0
<4>[  550.583652]  [<ffffffff815b86e6>] dst_release+0x56/0x80
<4>[  550.583713]  [<ffffffff8159d789>] sk_dst_check+0x99/0xa0
<4>[  550.583776]  [<ffffffff81629906>] udp_sendmsg+0x236/0x920
<4>[  550.583838]  [<ffffffff81080a8c>] ? update_curr+0x10c/0x1b0
<4>[  550.583898]  [<ffffffff81634fd1>] inet_sendmsg+0x61/0xb0
<4>[  550.583963]  [<ffffffff81599e8c>] sock_aio_write+0x10c/0x130
<4>[  550.584029]  [<ffffffff8115075a>] do_sync_write+0x7a/0xb0
<4>[  550.584090]  [<ffffffff811515c5>] vfs_write+0x1c5/0x1e0
<4>[  550.584149]  [<ffffffff811519b2>] SyS_write+0x52/0xa0
<4>[  550.584214]  [<ffffffff816cde42>] system_call_fastpath+0x16/0x1b
<4>[  550.584274] Code: 4a 9f e9 81 e8 53 cc 0c 00 48 8b 93 b0 00 00 00 48
bf
00 02 20 00 00 00 ad de 48 8b 83 b8 00 00 00 48 be 00 01 10 00 00 00 ad de
<48> 89 42 08 48 89 10 48 89 bb b8 00 00 00 48 c7 c7 4a 9f e9 81
<1>[  550.586632] RIP  [<ffffffff815f8c8f>] ipv4_dst_destroy+0x4f/0x80
<4>[  550.586727]  RSP <ffff88be23de9b58>
<4>[  550.586838] ---[ end trace 888f14be07a3ea77 ]---

Which appears to be fixed by this:

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd124c4..b9acfab 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -953,8 +953,12 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	} else if (!ipc.oif)
 		ipc.oif = inet->uc_index;

-	if (connected)
+	if (connected) {
+		lock_sock(sk);
 		rt = (struct rtable *)sk_dst_check(sk, 0);
+		if (rt)
+			release_sock(sk);
+	}

 	if (rt == NULL) {
 		struct net *net = sock_net(sk);
@@ -972,15 +976,22 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			rt = NULL;
 			if (err == -ENETUNREACH)
 				IP_INC_STATS(net, IPSTATS_MIB_OUTNOROUTES);
+			if (connected)
+				release_sock(sk);
 			goto out;
 		}

 		err = -EACCES;
 		if ((rt->rt_flags & RTCF_BROADCAST) &&
-		    !sock_flag(sk, SOCK_BROADCAST))
+		    !sock_flag(sk, SOCK_BROADCAST)) {
+			if (connected)
+				release_sock(sk);
 			goto out;
-		if (connected)
+		}
+		if (connected) {
 			sk_dst_set(sk, dst_clone(&rt->dst));
+			release_sock(sk);
+		}
 	}

 	if (msg->msg_flags&MSG_CONFIRM)


--------------------------------

This patch is too heavy handed, but I can't use the sk_dst_lock in that
part of the code. The utility usually causes a panic within ~2 minutes of
firing off udp packets from a "connected" socket being used from multiple
threads. With this patch it survived 30+ minutes.

Ideas welcome.

Then there's this crash:

<4>[196727.311959]  [<ffffffff815b86c6>] dst_release+0x56/0x80
<4>[196727.311986]  [<ffffffff81620bd5>] tcp_v4_do_rcv+0x2a5/0x4a0
<4>[196727.312013]  [<ffffffff81622b5a>] tcp_v4_rcv+0x7da/0x820
<4>[196727.312041]  [<ffffffff815fd9e0>] ? ip_rcv_finish+0x360/0x360
<4>[196727.312070]  [<ffffffff815de02d>] ? nf_hook_slow+0x7d/0x150
<4>[196727.312097]  [<ffffffff815fd9e0>] ? ip_rcv_finish+0x360/0x360
<4>[196727.312125]  [<ffffffff815fda92>]
ip_local_deliver_finish+0xb2/0x230
<4>[196727.312154]  [<ffffffff815fdd9a>] ip_local_deliver+0x4a/0x90
<4>[196727.312183]  [<ffffffff815fd799>] ip_rcv_finish+0x119/0x360
<4>[196727.312212]  [<ffffffff815fe00b>] ip_rcv+0x22b/0x340
<4>[196727.312242]  [<ffffffffa0339680>] ? macvlan_broadcast+0x160/0x160
[macvlan]
<4>[196727.312275]  [<ffffffff815b0c62>]
__netif_receive_skb_core+0x512/0x640
<4>[196727.312308]  [<ffffffff811427fb>] ? kmem_cache_alloc+0x13b/0x150
<4>[196727.312338]  [<ffffffff815b0db1>] __netif_receive_skb+0x21/0x70
<4>[196727.312368]  [<ffffffff815b0fa1>] netif_receive_skb+0x31/0xa0
<4>[196727.312397]  [<ffffffff815b1ae8>] napi_gro_receive+0xe8/0x140
<4>[196727.312433]  [<ffffffffa00274f1>] ixgbe_poll+0x551/0x11f0 [ixgbe]
<4>[196727.312463]  [<ffffffff815fe00b>] ? ip_rcv+0x22b/0x340
<4>[196727.312491]  [<ffffffff815b1691>] net_rx_action+0x111/0x210
<4>[196727.312521]  [<ffffffff815b0db1>] ? __netif_receive_skb+0x21/0x70
<4>[196727.312552]  [<ffffffff810519d0>] __do_softirq+0xd0/0x270
<4>[196727.312583]  [<ffffffff816cef3c>] call_softirq+0x1c/0x30
<4>[196727.312613]  [<ffffffff81004205>] do_softirq+0x55/0x90
<4>[196727.312640]  [<ffffffff81051c85>] irq_exit+0x55/0x60
<4>[196727.312668]  [<ffffffff816cf5c3>] do_IRQ+0x63/0xe0
<4>[196727.312696]  [<ffffffff816c5aaa>] common_interrupt+0x6a/0x6a
<4>[196727.312722]  <EOI>
<4>[196727.312727]  [<ffffffff8100a150>] ? default_idle+0x20/0xe0
<4>[196727.312775]  [<ffffffff8100a8ff>] arch_cpu_idle+0xf/0x20
<4>[196727.312803]  [<ffffffff8108d330>] cpu_startup_entry+0xc0/0x270
<4>[196727.312833]  [<ffffffff816b276e>] start_secondary+0x1f9/0x200
<4>[196727.312860] Code: 4a 9f e9 81 e8 13 cb 0c 00 48 8b 93 b0 00 00 00
48 bf 00 02 20 00 00 00 ad de 48 8b 83 b8 00 00 00 48 be 00 01 10 00 00 00
ad de <48> 89 42 08 48 89 10 48 89 bb b8 00 00 00 48 c7 c7 4a 9f e9 81
<1>[196727.313071] RIP  [<ffffffff815f8c7f>] ipv4_dst_destroy+0x4f/0x80
<4>[196727.313100]  RSP <ffff885effd23a70>
<4>[196727.313377] ---[ end trace 64b3f14fae0f2e29 ]---

RAX/RDX/RDI have LIST_POISON1 or LIST_POISON2 loaded, so it's another
double-free.

This one has me a bit vexed still, as tcp_v4_rcv() is calling
bh_lock_sock_nested(sk) before dropping into tcp_v4_do_rcv(), but within
there:

        if (dst) {
            if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
                dst->ops->check(dst, 0) == NULL) {
                dst_release(dst);
                sk->sk_rx_dst = NULL;
            }

if route is obsolete, release it. Somehow this is being run twice? This
particular crash seems to happen in the same path and is relatively
frequent. It happens moreso on hosts which have more packet loss (tcp
retries and such), if that's a hint. However those hosts may also see more
route churn, I'm not totally sure.

The least frequent crash appears to be loosely related:

<1>[7359072.999784] BUG: unable to handle kernel paging request at
0000000100000000
<1>[7359072.999928] IP: [<ffffffff811421e7>] kmem_cache_alloc+0x57/0x150
<4>[7359073.000032] PGD be41868067 PUD 0
<4>[7359073.000167] Oops: 0000 [#2] SMP
<4>[7359073.000301] Modules linked in: nls_cp437 isofs xt_TEE xt_dscp
xt_DSCP macvlan bridge coretemp crc32_pclmul ghash_
clmulni_intel gpio_ich ipmi_watchdog ipmi_devintf ixgbe microcode igb
sb_edac edac_core lpc_ich i2c_algo_bit mfd_core ptp
 tpm_tis pps_core tpm mdio tpm_bios ipmi_si ipmi_msghandler
<4>[7359073.001557] CPU: 11 PID: 72986 Comm: cache-worker Tainted: G
D W    3.10.15-fastly #1
<4>[7359073.001637] Hardware name: Supermicro
X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
<4>[7359073.001718] task: ffff8801c07a5c00 ti: ffff88016e9b8000 task.ti:
ffff88016e9b8000
<4>[7359073.001797] RIP: 0010:[<ffffffff811421e7>]  [<ffffffff811421e7>]
kmem_cache_alloc+0x57/0x150
<4>[7359073.001916] RSP: 0018:ffff88c07fc638f8  EFLAGS: 00010282
<4>[7359073.001977] RAX: 0000000000000000 RBX: ffffffff81c8c1c0 RCX:
000000016c1d572d
<4>[7359073.002055] RDX: 000000016c1d572c RSI: 0000000000000020 RDI:
00000000000156c0
<4>[7359073.002133] RBP: ffff88c07fc63948 R08: ffff88c07fc756c0 R09:
ffffffff815b672a
<4>[7359073.002211] R10: ffff88bc97207000 R11: 00000000a2d52a83 R12:
ffff885eff803800
<4>[7359073.002289] R13: 0000000100000000 R14: 00000000ffffffff R15:
0000000000000000
<4>[7359073.002367] FS:  00007f0d36755700(0000) GS:ffff88c07fc60000(0000)
knlGS:0000000000000000
<4>[7359073.002447] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[7359073.002508] CR2: 0000000100000000 CR3: 000000bc22187000 CR4:
00000000000407e0
<4>[7359073.002586] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
<4>[7359073.002664] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
<4>[7359073.002741] Stack:
<4>[7359073.002796]  ffff885e6e67ee40 ffff88c07fc63ac8 ffff88c07fc63968
00000020815c9145
<4>[7359073.003020]  c71b4c1400000001 ffffffff81c8c1c0 ffff885e6c890000
0000000000000001
<4>[7359073.003243]  00000000ffffffff 0000000000000000 ffff88c07fc63998
ffffffff815b672a
<4>[7359073.003466] Call Trace:
<4>[7359073.003522]  <IRQ>
<4>[7359073.003563]  [<ffffffff815b672a>] dst_alloc+0x5a/0x180
<4>[7359073.003720]  [<ffffffff815f78bc>] rt_dst_alloc+0x4c/0x50
<4>[7359073.003783]  [<ffffffff815f8861>]
__ip_route_output_key+0x281/0x860
<4>[7359073.003846]  [<ffffffff815f8e67>] ip_route_output_flow+0x27/0x70
<4>[7359073.003910]  [<ffffffff81606fee>] inet_csk_route_req+0xce/0x130
<4>[7359073.003974]  [<ffffffff8161fda3>] tcp_v4_conn_request+0x463/0xb10
<4>[7359073.004038]  [<ffffffff81616144>]
tcp_rcv_state_process+0x1c4/0xd10
<4>[7359073.004101]  [<ffffffff8161f457>] tcp_v4_do_rcv+0x257/0x4a0
<4>[7359073.004163]  [<ffffffff816215d6>] tcp_v4_rcv+0x6f6/0x870
<4>[7359073.004226]  [<ffffffff815fbff0>] ? ip_rcv_finish+0x360/0x360
<4>[7359073.004289]  [<ffffffff815fc0be>]
ip_local_deliver_finish+0xce/0x250
<4>[7359073.004352]  [<ffffffff815fc3ca>] ip_local_deliver+0x4a/0x90
<4>[7359073.004415]  [<ffffffff815fbda9>] ip_rcv_finish+0x119/0x360
<4>[7359073.004477]  [<ffffffff815fc63b>] ip_rcv+0x22b/0x340
<4>[7359073.004539]  [<ffffffff815af002>]
__netif_receive_skb_core+0x512/0x640
<4>[7359073.004603]  [<ffffffff815af151>] __netif_receive_skb+0x21/0x70
<4>[7359073.004666]  [<ffffffff815af23b>] process_backlog+0x9b/0x170
<4>[7359073.004729]  [<ffffffff815afa49>] net_rx_action+0x119/0x220
<4>[7359073.004794]  [<ffffffff81080f0b>] ?
check_preempt_wakeup+0x14b/0x230
<4>[7359073.004860]  [<ffffffff81051970>] __do_softirq+0xd0/0x270
<4>[7359073.004921]  [<ffffffff81051c25>] irq_exit+0x55/0x60
<4>[7359073.004983]  [<ffffffff8107a5b5>] scheduler_ipi+0x35/0x40
<4>[7359073.005049]  [<ffffffff81023bda>]
smp_reschedule_interrupt+0x2a/0x30
<4>[7359073.005115]  [<ffffffff816cd5da>] reschedule_interrupt+0x6a/0x70
<4>[7359073.005176]  <EOI>
<4>[7359073.005217]  [<ffffffff816c41f5>] ? _raw_spin_lock+0x25/0x30
<4>[7359073.005370]  [<ffffffff81098629>] futex_wait_setup+0x69/0xf0
<4>[7359073.005433]  [<ffffffff81098836>] futex_wait+0x186/0x2c0
<4>[7359073.005495]  [<ffffffff810508c6>] ? current_fs_time+0x16/0x60
<4>[7359073.005559]  [<ffffffff81159123>] ? pipe_write+0x2f3/0x590
<4>[7359073.005625]  [<ffffffff8118e8c2>] ? fsnotify+0x1d2/0x2b0
<4>[7359073.005687]  [<ffffffff81099e04>] do_futex+0x334/0xb20
<4>[7359073.005751]  [<ffffffff8115021a>] ? do_sync_write+0x7a/0xb0
<4>[7359073.005813]  [<ffffffff8118e8c2>] ? fsnotify+0x1d2/0x2b0
<4>[7359073.005875]  [<ffffffff8109a732>] SyS_futex+0x142/0x1a0
<4>[7359073.005939]  [<ffffffff8115148b>] ? SyS_write+0x6b/0xa0
<4>[7359073.006001]  [<ffffffff816cc702>] system_call_fastpath+0x16/0x1b
<4>[7359073.006063] Code: 00 49 8b 50 08 4d 8b 28 49 8b 40 10 4d 85 ed 0f
84 e7 00 00 00 48 85 c0 0f 84 de 00 00 00 49 63 44 24 20 48 8d 4a 01 49 8b
3c 24 <49> 8b 5c 05 00 4c 89 e8 65 48 0f c7 0f 0f 94 c0 84 c0 74 b5 49
<1>[7359073.008543] RIP  [<ffffffff811421e7>] kmem_cache_alloc+0x57/0x150
<4>[7359073.008642]  RSP <ffff88c07fc638f8>
<4>[7359073.008700] CR2: 0000000100000000
<4>[7359073.008767] ---[ end trace 83220393c4cb24ad ]---
<0>[7359073.072455] Kernel panic - not syncing: Fatal exception in
interrupt

(apologies for the mangling, it's getting late and I'm getting
progressively lazier)

The path for this one appears to shift a bit, but is always dying from the
kmem_cache_alloc() call withind dst_alloc().

I've also seen:

<4>[14723139.584187] Call Trace:
<4>[14723139.584241]  <IRQ>
<4>[14723139.584282]  [<ffffffff815b672a>] dst_alloc+0x5a/0x180
<4>[14723139.584433]  [<ffffffff8161c880>] ?
tcp_write_timer_handler+0x1d0/0x1d0
<4>[14723139.584497]  [<ffffffff815f78bc>] rt_dst_alloc+0x4c/0x50
<4>[14723139.584558]  [<ffffffff815f8861>]
__ip_route_output_key+0x281/0x860
<4>[14723139.584622]  [<ffffffff8161c880>] ?
tcp_write_timer_handler+0x1d0/0x1d0
<4>[14723139.584685]  [<ffffffff815f8e67>] ip_route_output_flow+0x27/0x70
<4>[14723139.584747]  [<ffffffff816329f7>]
inet_sk_rebuild_header+0x137/0x310
<4>[14723139.584810]  [<ffffffff8161c880>] ?
tcp_write_timer_handler+0x1d0/0x1d0
<4>[14723139.584874]  [<ffffffff81619c28>] __tcp_retransmit_skb+0x78/0x5a0
<4>[14723139.584938]  [<ffffffff816557f1>] ? bictcp_state+0xa1/0x100
<4>[14723139.584999]  [<ffffffff8161c880>] ?
tcp_write_timer_handler+0x1d0/0x1d0
<4>[14723139.585062]  [<ffffffff8161a354>] tcp_retransmit_skb+0x24/0x100
<4>[14723139.585124]  [<ffffffff8161c251>]
tcp_retransmit_timer+0x271/0x6d0
<4>[14723139.585187]  [<ffffffff8161c880>] ?
tcp_write_timer_handler+0x1d0/0x1d0
<4>[14723139.585250]  [<ffffffff8161c750>]
tcp_write_timer_handler+0xa0/0x1d0
<4>[14723139.585314]  [<ffffffff8161c880>] ?
tcp_write_timer_handler+0x1d0/0x1d0
<4>[14723139.585378]  [<ffffffff8161c8e0>] tcp_write_timer+0x60/0x70
<4>[14723139.585443]  [<ffffffff81057ccb>] call_timer_fn+0x3b/0x150
<4>[14723139.585507]  [<ffffffff816cdfc3>] ? do_IRQ+0x63/0xe0
<4>[14723139.585568]  [<ffffffff8161c880>] ?
tcp_write_timer_handler+0x1d0/0x1d0
<4>[14723139.585630]  [<ffffffff81059223>] run_timer_softirq+0x243/0x290
<4>[14723139.585690]  [<ffffffff81051970>] __do_softirq+0xd0/0x270
<4>[14723139.585749]  [<ffffffff81051c25>] irq_exit+0x55/0x60
<4>[14723139.585807]  [<ffffffff816ce0ae>]
smp_apic_timer_interrupt+0x6e/0x99
<4>[14723139.585868]  [<ffffffff816cd2ca>] apic_timer_interrupt+0x6a/0x70

This one's the most problematic. It's the least frequent, most difficult
to reproduce. Given how the other issues all centralize around dst's being
mishandled during route updates my wild guess would be that it's somewhere
within there.

It's probably worth auditing how dst caches are handled in all places, but
it is 3am and I have to stop for now. Anyway this sucks, please help!

thanks!
-Dormando
