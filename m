From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: KASAN, xt_TCPMSS  finally found nasty use-after-free bug? 4.10.8
Date: Sun, 02 Apr 2017 10:43:40 +0300
Message-ID: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Repost, due being sleepy missed few important points.

I am searching reasons of crashes for multiple conntrack enabled 
servers, usually they point to conntrack, but i suspect use after free 
might be somewhere else,
so i tried to enable KASAN.
And seems i got something after few hours, and it looks related to all 
crashes, because on all that servers who rebooted i had MSS adjustment 
(--clamp-mss-to-pmtu or --set-mss).
Please let me know if any additional information needed.

[25181.855611] 
==================================================================
[25181.855985] BUG: KASAN: use-after-free in tcpmss_tg4+0x682/0xe9c 
[xt_TCPMSS] at addr ffff8802976000ea
[25181.856344] Read of size 1 by task swapper/1/0
[25181.856555] page:ffffea000a5d8000 count:0 mapcount:0 mapping:         
  (null) index:0x0
[25181.856909] flags: 0x1000000000000000()
[25181.857123] raw: 1000000000000000 0000000000000000 0000000000000000 
00000000ffffffff
[25181.857630] raw: ffffea000b0444a0 ffffea000a0b1f60 0000000000000000 
0000000000000000
[25181.857996] page dumped because: kasan: bad access detected
[25181.858214] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 
4.10.8-build-0133-debug #3
[25181.858571] Hardware name: HP ProLiant DL320e Gen8 v2, BIOS P80 
04/02/2015
[25181.858786] Call Trace:
[25181.859000]  <IRQ>
[25181.859215]  dump_stack+0x99/0xd4
[25181.859423]  ? _atomic_dec_and_lock+0x15d/0x15d
[25181.859644]  ? __dump_page+0x447/0x4e3
[25181.859859]  ? tcpmss_tg4+0x682/0xe9c [xt_TCPMSS]
[25181.860080]  kasan_report+0x577/0x69d
[25181.860291]  ? __ip_route_output_key_hash+0x14ce/0x1503
[25181.860512]  ? tcpmss_tg4+0x682/0xe9c [xt_TCPMSS]
[25181.860736]  __asan_report_load1_noabort+0x19/0x1b
[25181.860956]  tcpmss_tg4+0x682/0xe9c [xt_TCPMSS]
[25181.861180]  ? tcpmss_tg4_check+0x287/0x287 [xt_TCPMSS]
[25181.861407]  ? udp_mt+0x45a/0x45a [xt_tcpudp]
[25181.861634]  ? __fib_validate_source+0x46b/0xcd1
[25181.861860]  ipt_do_table+0x1432/0x1573 [ip_tables]
[25181.862088]  ? igb_msix_ring+0x2d/0x35
[25181.862318]  ? ip_tables_net_init+0x15/0x15 [ip_tables]
[25181.862537]  ? ip_route_input_slow+0xe9f/0x17e3
[25181.862759]  ? handle_irq_event_percpu+0x141/0x141
[25181.862985]  ? rt_set_nexthop+0x9a7/0x9a7
[25181.863203]  ? ip_tables_net_exit+0xe/0x15 [ip_tables]
[25181.863419]  ? tcf_action_exec+0xce/0x18c
[25181.863628]  ? iptable_mangle_net_exit+0x92/0x92 [iptable_mangle]
[25181.863856]  ? iptable_filter_net_exit+0x92/0x92 [iptable_filter]
[25181.864084]  iptable_filter_hook+0xc0/0x1c8 [iptable_filter]
[25181.864311]  nf_hook_slow+0x7d/0x121
[25181.864536]  ip_forward+0x1183/0x11c6
[25181.864752]  ? ip_forward_finish+0x168/0x168
[25181.864967]  ? ip_frag_mem+0x43/0x43
[25181.865194]  ? iptable_nat_net_exit+0x92/0x92 [iptable_nat]
[25181.865423]  ? nf_nat_ipv4_in+0xf0/0x209 [nf_nat_ipv4]
[25181.865648]  ip_rcv_finish+0xf4c/0xf5b
[25181.865861]  ip_rcv+0xb41/0xb72
[25181.866086]  ? ip_local_deliver+0x282/0x282
[25181.866308]  ? ip_local_deliver_finish+0x6e6/0x6e6
[25181.866524]  ? ip_local_deliver+0x282/0x282
[25181.866752]  __netif_receive_skb_core+0x1b27/0x21bf
[25181.866971]  ? netdev_rx_handler_register+0x1a6/0x1a6
[25181.867186]  ? enqueue_hrtimer+0x232/0x240
[25181.867401]  ? hrtimer_start_range_ns+0xd1c/0xd4b
[25181.867630]  ? __ppp_xmit_process+0x101f/0x104e [ppp_generic]
[25181.867852]  ? hrtimer_cancel+0x20/0x20
[25181.868081]  ? ppp_push+0x1402/0x1402 [ppp_generic]
[25181.868301]  ? __pskb_pull_tail+0xb0f/0xb25
[25181.868523]  ? ppp_xmit_process+0x47/0xaf [ppp_generic]
[25181.868749]  __netif_receive_skb+0x5e/0x191
[25181.868968]  process_backlog+0x295/0x573
[25181.869180]  ? __netif_receive_skb+0x191/0x191
[25181.869401]  napi_poll+0x311/0x745
[25181.869611]  ? napi_complete_done+0x3b4/0x3b4
[25181.869836]  ? __qdisc_run+0x4ec/0xb7f
[25181.870061]  ? sch_direct_xmit+0x60b/0x60b
[25181.870286]  net_rx_action+0x2e8/0x6dc
[25181.870512]  ? napi_poll+0x745/0x745
[25181.870732]  ? rps_trigger_softirq+0x181/0x1e4
[25181.870956]  ? rps_may_expire_flow+0x29b/0x29b
[25181.871184]  ? irq_work_run+0x2c/0x2e
[25181.871411]  __do_softirq+0x22b/0x5df
[25181.871629]  ? smp_call_function_single_async+0x17d/0x17d
[25181.871854]  irq_exit+0x8a/0xfe
[25181.872069]  smp_call_function_single_interrupt+0x8d/0x90
[25181.872297]  call_function_single_interrupt+0x83/0x90
[25181.872519] RIP: 0010:mwait_idle+0x15a/0x30d
[25181.872733] RSP: 0018:ffff8802d1017e78 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff04
[25181.873091] RAX: 0000000000000000 RBX: ffff8802d1000c80 RCX: 
0000000000000000
[25181.873311] RDX: 1ffff1005a200190 RSI: 0000000000000000 RDI: 
0000000000000000
[25181.873532] RBP: ffff8802d1017e98 R08: 000000000000003f R09: 
00007f75f7fff700
[25181.873751] R10: ffff8802d1017d80 R11: ffff8802c9b00000 R12: 
0000000000000001
[25181.873971] R13: 0000000000000000 R14: ffff8802d1000c80 R15: 
dffffc0000000000
[25181.874182]  </IRQ>
[25181.874393]  arch_cpu_idle+0xf/0x11
[25181.874602]  default_idle_call+0x59/0x5c
[25181.874818]  do_idle+0x11c/0x217
[25181.875039]  cpu_startup_entry+0x1f/0x21
[25181.875258]  start_secondary+0x2cc/0x2d5
[25181.875481]  start_cpu+0x14/0x14
[25181.875696] Memory state around the buggy address:
[25181.875919]  ffff8802975fff80: 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00
[25181.876275]  ffff880297600000: 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00
[25181.876628] >ffff880297600080: 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00
[25181.876984]                                                           
^
[25181.877203]  ffff880297600100: 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00
[25181.877569]  ffff880297600180: 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00
[25181.877930] 
==================================================================
[25181.878283] Disabling lock debugging due to kernel taint
[25181.878584] 
==================================================================
