From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: KASAN, xt_TCPMSS  finally found nasty use-after-free bug? 4.10.8
Date: Sun, 02 Apr 2017 19:52:24 +0300
Message-ID: <f005315a672d82fae34f932f4a7f3d5f@nuclearcat.com>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
 <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170402114545.GA31804@breakpoint.cc>
 <1491134084.10124.6.camel@edumazet-glaptop3.roam.corp.google.com>
 <1491135593.10124.9.camel@edumazet-glaptop3.roam.corp.google.com>
 <4442718191e17f0ff91bf1359da6d631@nuclearcat.com>
 <1491136344.10124.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1491136344.10124.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-04-02 15:32, Eric Dumazet wrote:
> On Sun, 2017-04-02 at 15:25 +0300, Denys Fedoryshchenko wrote:
>> >  	 */
>> I will add also WARN_ON_ONCE(tcp_hdrlen >= 15 * 4) before, for
>> curiosity, if this condition are triggered. Is it fine like that?
> 
> Sure.

It didnt triggered WARN_ON, and with both patches here is one more 
KASAN.
What i noticed also after this KASAN, there is many others start to 
trigger in TCPMSS and locking up server by flood.
There is heavy netlink activity, it is pppoe server with lot of shapers.
I noticed there left sfq by mistake, usually i am removing it, because 
it may trigger kernel panic too (and hard to trace reason).
I will try with pfifo instead, after 6 hours.

Here is full log with others: https://nuclearcat.com/kasan.txt


[ 2033.914478] 
==================================================================
[ 2033.914855] BUG: KASAN: slab-out-of-bounds in tcpmss_tg4+0x6cc/0xee4 
[xt_TCPMSS] at addr ffff8802bfe18140
[ 2033.915218] Read of size 1 by task swapper/1/0
[ 2033.915437] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 
4.10.8-build-0136-debug #7
[ 2033.915787] Hardware name: HP ProLiant DL320e Gen8 v2, BIOS P80 
04/02/2015
[ 2033.916010] Call Trace:
[ 2033.916229]  <IRQ>
[ 2033.916449]  dump_stack+0x99/0xd4
[ 2033.916662]  ? _atomic_dec_and_lock+0x15d/0x15d
[ 2033.916886]  ? tcpmss_tg4+0x6cc/0xee4 [xt_TCPMSS]
[ 2033.917110]  kasan_object_err+0x21/0x81
[ 2033.917335]  kasan_report+0x527/0x69d
[ 2033.917557]  ? tcpmss_tg4+0x6cc/0xee4 [xt_TCPMSS]
[ 2033.917772]  __asan_report_load1_noabort+0x19/0x1b
[ 2033.917995]  tcpmss_tg4+0x6cc/0xee4 [xt_TCPMSS]
[ 2033.918222]  ? tcpmss_tg4_check+0x287/0x287 [xt_TCPMSS]
[ 2033.918451]  ? udp_mt+0x45a/0x45a [xt_tcpudp]
[ 2033.918669]  ? __fib_validate_source+0x46b/0xcd1
[ 2033.918895]  ipt_do_table+0x1432/0x1573 [ip_tables]
[ 2033.919114]  ? ip_tables_net_init+0x15/0x15 [ip_tables]
[ 2033.919338]  ? ip_route_input_slow+0xe9f/0x17e3
[ 2033.919562]  ? rt_set_nexthop+0x9a7/0x9a7
[ 2033.919790]  ? ip_tables_net_exit+0xe/0x15 [ip_tables]
[ 2033.920008]  ? tcf_action_exec+0x14a/0x18c
[ 2033.920227]  ? iptable_mangle_net_exit+0x92/0x92 [iptable_mangle]
[ 2033.920451]  ? iptable_filter_net_exit+0x92/0x92 [iptable_filter]
[ 2033.920667]  iptable_filter_hook+0xc0/0x1c8 [iptable_filter]
[ 2033.920882]  nf_hook_slow+0x7d/0x121
[ 2033.921105]  ip_forward+0x1183/0x11c6
[ 2033.921321]  ? ip_forward_finish+0x168/0x168
[ 2033.921542]  ? ip_frag_mem+0x43/0x43
[ 2033.921755]  ? iptable_nat_net_exit+0x92/0x92 [iptable_nat]
[ 2033.921981]  ? nf_nat_ipv4_in+0xf0/0x209 [nf_nat_ipv4]
[ 2033.922199]  ip_rcv_finish+0xf4c/0xf5b
[ 2033.922420]  ip_rcv+0xb41/0xb72
[ 2033.922635]  ? ip_local_deliver+0x282/0x282
[ 2033.922847]  ? ip_local_deliver_finish+0x6e6/0x6e6
[ 2033.923073]  ? ip_local_deliver+0x282/0x282
[ 2033.923291]  __netif_receive_skb_core+0x1b27/0x21bf
[ 2033.923510]  ? netdev_rx_handler_register+0x1a6/0x1a6
[ 2033.923736]  ? kasan_slab_free+0x137/0x154
[ 2033.923954]  ? save_stack_trace+0x1b/0x1d
[ 2033.924170]  ? kasan_slab_free+0xaa/0x154
[ 2033.924387]  ? net_rx_action+0x6ad/0x6dc
[ 2033.924611]  ? __do_softirq+0x22b/0x5df
[ 2033.924826]  ? irq_exit+0x8a/0xfe
[ 2033.925048]  ? do_IRQ+0x13d/0x155
[ 2033.925269]  ? common_interrupt+0x83/0x83
[ 2033.925483]  ? mwait_idle+0x15a/0x30d
[ 2033.925704]  ? napi_gro_flush+0x1d0/0x1d0
[ 2033.925928]  ? start_secondary+0x2cc/0x2d5
[ 2033.926142]  ? start_cpu+0x14/0x14
[ 2033.926354]  __netif_receive_skb+0x5e/0x191
[ 2033.926576]  process_backlog+0x295/0x573
[ 2033.926799]  ? __netif_receive_skb+0x191/0x191
[ 2033.927022]  napi_poll+0x311/0x745
[ 2033.927245]  ? napi_complete_done+0x3b4/0x3b4
[ 2033.927460]  ? igb_msix_ring+0x2d/0x35
[ 2033.927679]  net_rx_action+0x2e8/0x6dc
[ 2033.927903]  ? napi_poll+0x745/0x745
[ 2033.928133]  ? sched_clock_cpu+0x1f/0x18c
[ 2033.928360]  ? rps_trigger_softirq+0x181/0x1e4
[ 2033.928592]  ? __tick_nohz_idle_enter+0x465/0xa6d
[ 2033.928817]  ? rps_may_expire_flow+0x29b/0x29b
[ 2033.929038]  ? irq_work_run+0x2c/0x2e
[ 2033.929253]  __do_softirq+0x22b/0x5df
[ 2033.929464]  ? smp_call_function_single_async+0x17d/0x17d
[ 2033.929680]  irq_exit+0x8a/0xfe
[ 2033.929905]  smp_call_function_single_interrupt+0x8d/0x90
[ 2033.930136]  call_function_single_interrupt+0x83/0x90
[ 2033.930365] RIP: 0010:mwait_idle+0x15a/0x30d
[ 2033.930581] RSP: 0018:ffff8802d1017e78 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff04
[ 2033.930934] RAX: 0000000000000000 RBX: ffff8802d1000c80 RCX: 
0000000000000000
[ 2033.931160] RDX: 1ffff1005a200190 RSI: 0000000000000000 RDI: 
0000000000000000
[ 2033.931383] RBP: ffff8802d1017e98 R08: ffffed00583c4fc1 R09: 
0000000000000080
[ 2033.931596] R10: ffff8802d1017d80 R11: ffffed00583c4fc1 R12: 
0000000000000001
[ 2033.931808] R13: 0000000000000000 R14: ffff8802d1000c80 R15: 
dffffc0000000000
[ 2033.932031]  </IRQ>
[ 2033.932247]  arch_cpu_idle+0xf/0x11
[ 2033.932472]  default_idle_call+0x59/0x5c
[ 2033.932686]  do_idle+0x11c/0x217
[ 2033.932906]  cpu_startup_entry+0x1f/0x21
[ 2033.933128]  start_secondary+0x2cc/0x2d5
[ 2033.933351]  start_cpu+0x14/0x14
[ 2033.933574] Object at ffff8802bfe18000, in cache kmalloc-512 size: 
512
[ 2033.933792] Allocated:
[ 2033.934004] PID = 3885
[ 2033.934213]  save_stack_trace+0x1b/0x1d
[ 2033.934424]  kasan_kmalloc.part.1+0x65/0xf1
[ 2033.934648]  kasan_kmalloc+0x81/0x8d
[ 2033.934868]  __kmalloc_node+0x18d/0x34a
[ 2033.935090]  qdisc_alloc+0x126/0x51d
[ 2033.935306]  qdisc_create+0x1a0/0xb1e
[ 2033.935531]  tc_modify_qdisc+0xc65/0xd47
[ 2033.935747]  rtnetlink_rcv_msg+0x697/0x6c8
[ 2033.935970]  netlink_rcv_skb+0x14d/0x1d6
[ 2033.936186]  rtnetlink_rcv+0x23/0x2a
[ 2033.936407]  netlink_unicast+0x40c/0x532
[ 2033.936628]  netlink_sendmsg+0xa91/0xac9
[ 2033.936845]  sock_sendmsg+0xcd/0xeb
[ 2033.937066]  ___sys_sendmsg+0x582/0x6f1
[ 2033.937290]  __sys_sendmsg+0xc2/0x130
[ 2033.937508]  SyS_sendmsg+0x12/0x1c
[ 2033.937729]  entry_SYSCALL_64_fastpath+0x17/0x98
[ 2033.937950] Freed:
[ 2033.938168] PID = 3462
[ 2033.938387]  save_stack_trace+0x1b/0x1d
[ 2033.938610]  kasan_slab_free+0xaa/0x154
[ 2033.938830]  kfree+0x18c/0x2b3
[ 2033.939054]  skb_free_head+0x92/0x97
[ 2033.939278]  skb_release_data+0x2d7/0x2f3
[ 2033.939494]  skb_release_all+0x5a/0x5d
[ 2033.939718]  __kfree_skb+0x14/0xed
[ 2033.939942]  consume_skb+0xfe/0x18c
[ 2033.940153]  skb_free_datagram+0x17/0xd5
[ 2033.940373]  netlink_recvmsg+0x733/0xb96
[ 2033.940585]  sock_recvmsg+0xd5/0xe0
[ 2033.940805]  ___sys_recvmsg+0x290/0x405
[ 2033.941025]  __sys_recvmsg+0xbf/0x12d
[ 2033.941237]  SyS_recvmsg+0x12/0x1c
[ 2033.941448]  entry_SYSCALL_64_fastpath+0x17/0x98
[ 2033.941661] Memory state around the buggy address:
[ 2033.945246]  ffff8802bfe18000: 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00
[ 2033.945604]  ffff8802bfe18080: 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00
[ 2033.945965] >ffff8802bfe18100: 00 00 00 00 00 00 00 00 fc fc fc fc fc 
fc fc fc
[ 2033.946318]                                            ^
[ 2033.946535]  ffff8802bfe18180: fc fc fc fc fc fc fc fc fc fc fc fc fc 
fc fc fc
[ 2033.946886]  ffff8802bfe18200: fc fc fc fc fc fc fc fc fc fc fc fc fc 
fc fc fc
[ 2033.947247] 
==================================================================
[ 2033.947603] Disabling lock debugging due to kernel taint
[ 2033.947845] 
==================================================================


(gdb) list *(tcpmss_tg4+0x6cc)
0x977 is in tcpmss_tg4 (net/netfilter/xt_TCPMSS.c:131).
126		} else
127			newmss = info->mss;
128
129		opt = (u_int8_t *)tcph;
130		for (i = sizeof(struct tcphdr); i < tcp_hdrlen - TCPOLEN_MSS; i += 
optlen(opt, i)) {
131			if (opt[i] == TCPOPT_MSS && opt[i+1] == TCPOLEN_MSS) {
132				u_int16_t oldmss;
133
134				oldmss = (opt[i+2] << 8) | opt[i+3];
135
