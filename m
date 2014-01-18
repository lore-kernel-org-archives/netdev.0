From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kmem_cache_alloc panic in 3.10+
Date: Sat, 18 Jan 2014 08:29:36 -0800
Message-ID: <1390062576.31367.519.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.10.1401180036020.18419@dinf>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>
To: dormando <dormando@rydia.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1401180036020.18419@dinf>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-01-18 at 00:44 -0800, dormando wrote:
> Hello again!
> 
> We've had a rare crash that's existed between 3.10.0 and 3.10.15 at least
> (trying newer stables now, but I can't tell if it was fixed, and it takes
> weeks to reproduce).
> 
> Unfortunately I can only get 8k back from pstore. The panic looks a bit
> longer than that is caught in the log, but the bottom part is almost
> always this same trace as this one:
> 
> Panic#6 Part1
> <4>[1197485.199166]  [<ffffffff81611e8c>] tcp_push+0x6c/0x90
> <4>[1197485.199171]  [<ffffffff816160a9>] tcp_sendmsg+0x109/0xd40
> <4>[1197485.199179]  [<ffffffff81114b65>] ? put_page+0x35/0x40
> <4>[1197485.199185]  [<ffffffff8163bf75>] inet_sendmsg+0x45/0xb0
> <4>[1197485.199191]  [<ffffffff8159da7e>] sock_aio_write+0x11e/0x130
> <4>[1197485.199196]  [<ffffffff8163b83f>] ? inet_recvmsg+0x4f/0x80
> <4>[1197485.199203]  [<ffffffff811558ad>] do_sync_readv_writev+0x6d/0xa0
> <4>[1197485.199209]  [<ffffffff8115722b>] do_readv_writev+0xfb/0x2f0
> <4>[1197485.199215]  [<ffffffff8110fda5>] ? __free_pages+0x35/0x40
> <4>[1197485.199220]  [<ffffffff8110fe56>] ? free_pages+0x46/0x50
> <4>[1197485.199226]  [<ffffffff8112f9e2>] ? SyS_mincore+0x152/0x690
> <4>[1197485.199231]  [<ffffffff81157468>] vfs_writev+0x48/0x60
> <4>[1197485.199236]  [<ffffffff811575af>] SyS_writev+0x5f/0xd0
> <4>[1197485.199243]  [<ffffffff816cf942>] system_call_fastpath+0x16/0x1b
> <4>[1197485.199247] Code: 65 4c 03 04 25 c8 cb 00 00 49 8b 50 08 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 84 00 00 00 48 85 c0 74 7f 49 63 44 24 20 49 8b 3c 24 <49> 8b 5c 05 00 48 8d 4a 01 4c 89 e8 65 48 0f c7 0f 0f 94 c0 3c
> <1>[1197485.199290] RIP  [<ffffffff811476da>] kmem_cache_alloc+0x5a/0x130
> <4>[1197485.199296]  RSP <ffff883171211868>
> <4>[1197485.199299] CR2: 0000000100000000
> <4>[1197485.199343] ---[ end trace 90fee06aa40b7304 ]---
> <1>[1197485.263911] BUG: unable to handle kernel paging request at 0000000100000000
> <1>[1197485.263923] IP: [<ffffffff811476da>] kmem_cache_alloc+0x5a/0x130
> <4>[1197485.263932] PGD 3f43e5c067 PUD 0
> <4>[1197485.263937] Oops: 0000 [#5] SMP
> <4>[1197485.263941] Modules linked in: ntfs vfat msdos fat macvlan bridge coretemp crc32_pclmul ghash_clmulni_intel gpio_ich microcode sb_edac edac_core lpc_ich mfd_core ixgbe igb i2c_algo_bit mdio ptp pps_core
> <4>[1197485.263966] CPU: 0 PID: 233846 Comm: cache-worker Tainted: G      D      3.10.15 #1
> <4>[1197485.263972] Hardware name: Supermicro X9DR3-F/X9DR3-F, BIOS 2.0a 03/07/2013
> <4>[1197485.263976] task: ffff883427f9dc00 ti: ffff8830d4312000 task.ti: ffff8830d4312000
> <4>[1197485.263982] RIP: 0010:[<ffffffff811476da>]  [<ffffffff811476da>] kmem_cache_alloc+0x5a/0x130
> <4>[1197485.263990] RSP: 0018:ffff881fffc038c8  EFLAGS: 00010286
> <4>[1197485.263994] RAX: 0000000000000000 RBX: ffffffff81c8c740 RCX: 00000000ffffffff
> <4>[1197485.263999] RDX: 0000000029273024 RSI: 0000000000000020 RDI: 0000000000015680
> <4>[1197485.264004] RBP: ffff881fffc03908 R08: ffff881fffc15680 R09: ffffffff815bdd4b
> <4>[1197485.264009] R10: ffff881c65d21800 R11: 0000000000000000 R12: ffff881fff803800
> <4>[1197485.264014] R13: 0000000100000000 R14: 00000000ffffffff R15: 0000000000000000
> <4>[1197485.264019] FS:  00007f8d855eb700(0000) GS:ffff881fffc00000(0000) knlGS:0000000000000000
> <4>[1197485.264024] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> <4>[1197485.264028] CR2: 0000000100000000 CR3: 000000308f258000 CR4: 00000000000407f0
> <4>[1197485.264032] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> <4>[1197485.264037] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> <4>[1197485.264041] Stack:
> <4>[1197485.264044]  ffff881fffc03928 00000020815d0d95 ffff881fffc03938 ffffffff81c8c740
> <4>[1197485.264050]  ffff881fce210000 0000000000000001 00000000ffffffff 0000000000000000
> <4>[1197485.264056]  ffff881fffc03958 ffffffff815bdd4b ffff881fffc039a8 0000000000000000
> <4>[1197485.264063] Call Trace:
> <4>[1197485.264066]  <IRQ>
> <4>[1197485.264069]  [<ffffffff815bdd4b>] dst_alloc+0x5b/0x190
> <4>[1197485.264080]  [<ffffffff8160068c>] rt_dst_alloc+0x4c/0x50
> <4>[1197485.264085]  [<ffffffff81602a30>] __ip_route_output_key+0x270/0x880
> <4>[1197485.264092]  [<ffffffff8107ee7e>] ? try_to_wake_up+0x23e/0x2b0
> <4>[1197485.264097]  [<ffffffff81603067>] ip_route_output_flow+0x27/0x60
> <4>[1197485.264102]  [<ffffffff8160ab8a>] ip_queue_xmit+0x36a/0x390
> <4>[1197485.264108]  [<ffffffff816207c5>] tcp_transmit_skb+0x485/0x890
> <4>[1197485.264113]  [<ffffffff81621aa1>] tcp_send_ack+0xf1/0x130
> <4>[1197485.264118]  [<ffffffff81618d7e>] __tcp_ack_snd_check+0x5e/0xa0
> <4>[1197485.264123]  [<ffffffff8161f2c2>] tcp_rcv_state_process+0x8b2/0xb20
> <4>[1197485.264128]  [<ffffffff81627e61>] tcp_v4_do_rcv+0x191/0x4f0
> <4>[1197485.264133]  [<ffffffff8162984c>] tcp_v4_rcv+0x5fc/0x750
> <4>[1197485.264138]  [<ffffffff81604c80>] ? ip_rcv+0x350/0x350
> <4>[1197485.264143]  [<ffffffff815e45cd>] ? nf_hook_slow+0x7d/0x160
> <4>[1197485.264147]  [<ffffffff81604c80>] ? ip_rcv+0x350/0x350
> <4>[1197485.264152]  [<ffffffff81604d4e>] ip_local_deliver_finish+0xce/0x250
> <4>[1197485.264156]  [<ffffffff81604f1c>] ip_local_deliver+0x4c/0x80
> <4>[1197485.264161]  [<ffffffff816045a9>] ip_rcv_finish+0x119/0x360
> <4>[1197485.264165]  [<ffffffff81604b60>] ip_rcv+0x230/0x350
> <4>[1197485.264170]  [<ffffffff815b89f7>] __netif_receive_skb_core+0x477/0x600
> <4>[1197485.264175]  [<ffffffff815b8ba7>] __netif_receive_skb+0x27/0x70
> <4>[1197485.264180]  [<ffffffff815b8ce4>] process_backlog+0xf4/0x1e0
> <4>[1197485.264184]  [<ffffffff815b94e5>] net_rx_action+0xf5/0x250
> <4>[1197485.264190]  [<ffffffff81053b7f>] __do_softirq+0xef/0x270
> <4>[1197485.264196]  [<ffffffff816d0b7c>] call_softirq+0x1c/0x30
> <4>[1197485.264199]  <EOI>
> <4>[1197485.264201]  [<ffffffff81004495>] do_softirq+0x55/0x90
> <4>[1197485.264209]  [<ffffffff81053a84>] local_bh_enable+0x94/0xa0
> <4>[1197485.264215]  [<ffffffff8165567a>] ipt_do_table+0x22a/0x680
> <4>[1197485.264221]  [<ffffffff815d39c1>] ? skb_clone_tx_timestamp+0x31/0x110
> <4>[1197485.264231]  [<ffffffffa00ae840>] ? ixgbe_xmit_frame_ring+0x4c0/0xd40 [ixgbe]
> <4>[1197485.264239]  [<ffffffffa00af103>] ? ixgbe_xmit_frame+0x43/0x90 [ixgbe]
> <4>[1197485.264245]  [<ffffffff81657a23>] iptable_raw_hook+0x33/0x70
> <4>[1197485.264252]  [<ffffffff815e43a7>] nf_iterate+0x87/0xb0
> <4>[1197485.264256]  [<ffffffff81607e20>] ? ip_options_echo+0x420/0x420
> <4>[1197485.264261]  [<ffffffff815e45cd>] nf_hook_slow+0x7d/0x160
> <4>[1197485.264266]  [<ffffffff81607e20>] ? ip_options_echo+0x420/0x420
> <4>[1197485.264270]  [<ffffffff8160a430>] __ip_local_out+0xa0/0xb0
> <4>[1197485.264275]  [<ffffffff8160a456>] ip_local_out+0x16/0x30
> <4>[1197485.264280]  [<ffffffff8160a97a>] ip_queue_xmit+0x15a/0x390
> <4>[1197485.264286]  [<ffffffff81625e73>] ? tcp_v4_md5_lookup+0x13/0x20
> <4>[1197485.264290]  [<ffffffff816207c5>] tcp_transmit_skb+0x485/0x890
> <4>[1197485.264295]  [<ffffffff81622e08>] tcp_write_xmit+0x1b8/0xa50
> <4>[1197485.264300]  [<ffffffff815a7e28>] ? __alloc_skb+0xa8/0x1f0
> <4>[1197485.264304]  [<ffffffff816236d0>] tcp_push_one+0x30/0x40
> <4>[1197485.264309]  [<ffffffff81616b84>] tcp_sendmsg+0xbe4/0xd40
> <4>[1197485.264315]  [<ffffffff81114b65>] ? put_page+0x35/0x40
> <4>[1197485.264321]  [<ffffffff8163bf75>] inet_sendmsg+0x45/0xb0
> <4>[1197485.264326]  [<ffffffff8159da7e>] sock_aio_write+0x11e/0x130
> <4>[1197485.264331]  [<ffffffff8163b83f>] ? inet_recvmsg+0x4f/0x80
> <4>[1197485.264337]  [<ffffffff811558ad>] do_sync_readv_writev+0x6d/0xa0
> <4>[1197485.264343]  [<ffffffff8115722b>] do_readv_writev+0xfb/0x2f0
> <4>[1197485.264347]  [<ffffffff8110fda5>] ? __free_pages+0x35/0x40
> <4>[1197485.264352]  [<ffffffff8110fe56>] ? free_pages+0x46/0x50
> <4>[1197485.264357]  [<ffffffff8112f9e2>] ? SyS_mincore+0x152/0x690
> <4>[1197485.264363]  [<ffffffff81157468>] vfs_writev+0x48/0x60
> <4>[1197485.264367]  [<ffffffff811575af>] SyS_writev+0x5f/0xd0
> <4>[1197485.264373]  [<ffffffff816cf942>] system_call_fastpath+0x16/0x1b
> <4>[1197485.264377] Code: 65 4c 03 04 25 c8 cb 00 00 49 8b 50 08 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 84 00 00 00 48 85 c0 74 7f 49 63 44 24 20 49 8b 3c 24 <49> 8b 5c 05 00 48 8d 4a 01 4c 89 e8 65 48 0f c7 0f 0f 94 c0 3c
> <1>[1197485.264417] RIP  [<ffffffff811476da>] kmem_cache_alloc+0x5a/0x130
> <4>[1197485.264424]  RSP <ffff881fffc038c8>
> <4>[1197485.264427] CR2: 0000000100000000
> <4>[1197485.264431] ---[ end trace 90fee06aa40b7305 ]---
> <0>[1197485.325141] Kernel panic - not syncing: Fatal exception in interrupt
> 
> ... way down in the tcp code.
> 
> Any help would be appreciated :) I'll do what I can to help, but iterating
> this particular crash is very hard due to the amount of time it takes to
> reproduce. Since we have a large number of machines they're always
> crashing here and there, but once they do it's not going to happen again
> for a while.
> 
> Thanks!
> -Dormando
> --

Hmm...

Some dst seems to be destroyed twice. This likely screws slab allocator.

Please try following untested patch :
diff --git a/include/net/route.h b/include/net/route.h
index 9d1f423d5944..bb96e0873eb5 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -314,4 +314,9 @@ static inline int ip4_dst_hoplimit(const struct dst_entry *dst)
 	return hoplimit;
 }
 
+static inline void rt_free(struct rtable *rt)
+{
+	call_rcu(&rt->dst.rcu_head, dst_rcu_free);
+}
+
 #endif	/* _ROUTE_H */
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index b53f0bf84dca..97b43b09e037 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -152,7 +152,7 @@ static void rt_fibinfo_free(struct rtable __rcu **rtp)
 	 * free_fib_info_rcu()
 	 */
 
-	dst_free(&rt->dst);
+	rt_free(rt);
 }
 
 static void free_nh_exceptions(struct fib_nh *nh)
@@ -192,7 +192,7 @@ static void rt_fibinfo_free_cpus(struct rtable __rcu * __percpu *rtp)
 
 		rt = rcu_dereference_protected(*per_cpu_ptr(rtp, cpu), 1);
 		if (rt)
-			dst_free(&rt->dst);
+			rt_free(rt);
 	}
 	free_percpu(rtp);
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 25071b48921c..06f79225b7ac 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -556,11 +556,6 @@ static void ip_rt_build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 		build_sk_flow_key(fl4, sk);
 }
 
-static inline void rt_free(struct rtable *rt)
-{
-	call_rcu(&rt->dst.rcu_head, dst_rcu_free);
-}
-
 static DEFINE_SPINLOCK(fnhe_lock);
 
 static void fnhe_flush_routes(struct fib_nh_exception *fnhe)
