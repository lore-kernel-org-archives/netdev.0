From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Thu, 27 Mar 2008 16:41:00 +0200
Message-ID: <20080327144102.M65267@visp.net.lb>
References: <20080327062502.M51594@visp.net.lb> <20080326.234049.256533912.davem@davemloft.net> <47EB46BD.2080001@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47EB46BD.2080001@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, it seems related to routing. Before such thing was not happening (maybe 
because TRIE was operating better?).

Here is info at "peak time", i disable nmi_watchdog now, so garbage collector 
will not be triggered by nmi watchdog. 

rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
rt_cache|
 entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
out_hlis|
        |        |     tot|      mc|     ute|        |  an_dst|  
an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| 
_search|t_search|
  247011| 2255410|  162866|       0|     610|       5|       0|       0|   
33761|    8574|       0|  165475|  165307|       0|       0|10407428|  174948|
  251810|   43087|    2782|       0|       9|       0|       0|       0|     
618|     122|       0|    2912|    2909|       0|       0|  241946|    3796|
  256277|   43035|    2739|       0|       9|       0|       0|       0|     
595|     121|       0|    2867|    2864|       0|       0|  243724|    3748|
  260177|   43596|    2647|       0|       8|       0|       0|       0|     
672|     123|       0|    2778|    2776|       0|       0|  246880|    4048|
  232741|   42270|    2759|       0|      15|       0|       0|       0|     
665|     135|       0|    2910|    2907|       0|       0|  233990|    3938|
  226623|   42615|    2792|       0|      11|       0|       0|       0|     
723|     132|       0|    2935|    2932|       0|       0|  218378|    3862|
  233190|   42397|    2778|       0|       8|       0|       0|       0|     
675|     128|       0|    2913|    2909|       0|       0|  214258|    3703|
  239093|   42342|    2713|       0|       9|       0|       0|       0|     
764|     126|       0|    2847|    2845|       0|       0|  216453|    4080|
  150539|   36992|    7564|       0|      58|       0|       0|       0|     
539|     283|       0|    7902|    7900|       0|       0|   93459|    1996|
  154441|   40258|    4422|       0|      12|       0|       0|       0|     
655|     212|       0|    4644|    4640|       0|       0|   77271|    1458|

On one "crash" i got 
Mar 27 11:27:15 205.177.186.74 [ 7141.156100] dst cache overflow
Mar 27 11:27:15 205.177.186.74 [ 7141.002291] dst cache overflow
Mar 27 11:27:15 205.177.186.74 [ 7141.162756] dst cache overflow

So i increase now routes amount more than 512K to 5120K, and will see more.

On Thu, 27 Mar 2008 08:03:25 +0100, Eric Dumazet wrote
> David Miller:
> > From: "Denys Fedoryshchenko" <denys@visp.net.lb>
> > Date: Thu, 27 Mar 2008 08:35:06 +0200
> > 
> >> It seems i am having very bad luck with 2.6.27. As Linus told, it have 
to be 
> >> released soon, but it is crashing like hell on high network load.
> > 
> > That's amazing, you've taken a trip into the future and are running
> > 2.6.27 already, please let me borrow your time machine :-)
> > 
> > More seriously, there is obviously something very unique to your
> > setup or else everyone would be reporting this crash, and we have
> > to find out what that might be.
> > 
> > There seems to be bunch of netfilter stuff in your traces, but
> > the top of the trace is somewhere totally unrelated.  This is
> > a common reoccurance in your crash traces, making them less
> > useful than they could be.
> > 
> > I know you asked before what can be done to improve the traces,
> > but I'm not an x86 expert so I have no idea how to help you
> > in that area.
> > 
> > Patrick, could you see if you can make any sense of his log?
> > I see conttrack a lot in the backtraces.
> 
> I can see rt_garbage_collect() involved here. This one might explain 
> very long delays in softirq processing, and eventually crashes...
> 
> Denys, could you post :
> 
> grep . /proc/sys/net/ipv4/route/*
> 
> rtstat -c1 -i10
> 
> So that we can check if you should first change route cache tunables 
> :)
> 
> > 
> > Thanks.
> > 
> >> Here is a message i got over syslog on last crash (it was 2.6.25-rc6-
git6), 
> >> available also at http://www.nuclearcat.com/files/crash_2.6.25.txt
> >>
> >> Mar 26 02:27:14 ROUTER [ 4698.694693] BUG: NMI Watchdog detected LOCKUP
> >> Mar 26 02:27:14 ROUTER on CPU1, ip c02ad109, registers:
> >> Mar 26 02:27:14 ROUTER [ 4698.694693] Process snmpd (pid: 2327, 
ti=c092e000 
> >> task=f7459080 task.ti=f70b7000)
> >> Mar 26 02:27:14 ROUTER 
> >> Mar 26 02:27:14 ROUTER [ 4698.694693] Stack: 
> >> Mar 26 02:27:14 ROUTER c092eb14 
> >> Mar 26 02:27:14 ROUTER c011991e 
> >> Mar 26 02:27:14 ROUTER f750d600 
> >> Mar 26 02:27:14 ROUTER f750d600 
> >> Mar 26 02:27:14 ROUTER c0378058 
> >> Mar 26 02:27:14 ROUTER 00000001 
> >> Mar 26 02:27:14 ROUTER c092eb34 
> >> Mar 26 02:27:14 ROUTER c0119b3b 
> >> Mar 26 02:27:14 ROUTER 
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]        
> >> Mar 26 02:27:14 ROUTER 00000000 
> >> Mar 26 02:27:14 ROUTER 00000001 
> >> Mar 26 02:27:14 ROUTER 00000082 
> >> Mar 26 02:27:14 ROUTER f708af88 
> >> Mar 26 02:27:14 ROUTER c0378058 
> >> Mar 26 02:27:14 ROUTER 00000001 
> >> Mar 26 02:27:14 ROUTER c092eb3c 
> >> Mar 26 02:27:14 ROUTER c0119bfe 
> >> Mar 26 02:27:14 ROUTER 
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]        
> >> Mar 26 02:27:14 ROUTER c092eb50 
> >> Mar 26 02:27:14 ROUTER c012f19c 
> >> Mar 26 02:27:14 ROUTER 00000000 
> >> Mar 26 02:27:14 ROUTER f708af88 
> >> Mar 26 02:27:14 ROUTER c0378058 
> >> Mar 26 02:27:14 ROUTER c092eb74 
> >> Mar 26 02:27:14 ROUTER c011652a 
> >> Mar 26 02:27:14 ROUTER 00000000 
> >> Mar 26 02:27:14 ROUTER 
> >> Mar 26 02:27:14 ROUTER [ 4698.694693] Call Trace:
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011991e>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER task_rq_lock+0x31/0x58
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0119b3b>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER try_to_wake_up+0x19/0xd1
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0119bfe>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER default_wake_function+0xb/0xd
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c012f19c>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER autoremove_wake_function+0xf/0x33
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011652a>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER __wake_up_common+0x2f/0x5a
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c01189b8>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER __wake_up+0x28/0x3b
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c01201a3>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER wake_up_klogd+0x2e/0x31
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c012033d>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER release_console_sem+0x197/0x19f
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0120747>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER vprintk+0x295/0x2e5
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f899634c>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER death_by_timeout+0x8b/0xa3 [nf_conntrack]
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f8999d08>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER tcp_packet+0x931/0x9e5 [nf_conntrack]
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c01207ac>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER printk+0x15/0x17
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011fb65>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER warn_on_slowpath+0x2a/0x51
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011764a>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER __update_rq_clock+0x1c/0x126
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0116ab3>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER update_curr+0x48/0x64
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f89961ed>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER nf_ct_invert_tuple+0x63/0x6f [nf_conntrack]
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f8996cca>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER nf_conntrack_tuple_taken+0xf8/0x100 [nf_conntrack]
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f899850c>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER __nf_ct_helper_find+0x2c/0x90 [nf_conntrack]
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f8996b95>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER nf_conntrack_alter_reply+0x4a/0x87 [nf_conntrack]
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<f8974976>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER nf_nat_setup_info+0x3cc/0x55a [nf_nat]
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011701c>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER dequeue_rt_entity+0x88/0x171
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0117127>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER dequeue_rt_stack+0x22/0x27
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0117425>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER enqueue_task_rt+0x19/0x2c
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c011617f>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER enqueue_task+0xd/0x18
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c01161c0>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER activate_task+0x1e/0x2b
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0119bb1>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER try_to_wake_up+0x8f/0xd1
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0119c1b>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER wake_up_process+0xf/0x11
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c013dfa1>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER softlockup_tick+0x9d/0x10b
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0126f5c>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER run_local_timers+0x17/0x19
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c01272fa>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER update_process_times+0x24/0x49
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0135f4c>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER tick_periodic+0x62/0x6e
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0135f71>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER tick_handle_periodic+0x19/0x68
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c010e87b>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER smp_apic_timer_interrupt+0x6c/0x81
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0104344>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER apic_timer_interrupt+0x28/0x30
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c02ad202>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER _spin_lock_bh+0x20/0x22
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c02751fa>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER rt_garbage_collect+0x132/0x27a
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0262d95>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER dst_alloc+0x19/0x63
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0276eb1>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER ip_route_input+0x6b9/0xbd9
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0278898>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER ip_rcv_finish+0x2c/0x29a
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0278ef8>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER ip_rcv+0x202/0x22c
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c025ee4e>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER netif_receive_skb+0x33e/0x3a9
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c02612c2>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER process_backlog+0x62/0xb5
> >> Mar 26 02:27:14 ROUTER [ 4698.694693]  [<c0260d27>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER net_rx_action+0x8f/0x191
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c01240a7>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER __do_softirq+0x64/0xcd
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0105f0a>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER do_softirq+0x55/0x89
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0123f88>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER local_bh_enable+0x61/0x6d
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0257689>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER lock_sock_nested+0x83/0x8b
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0292e58>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER udp_destroy_sock+0xd/0x20
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0257b9e>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER sk_common_release+0x15/0x60
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c02924a4>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER udp_lib_close+0x8/0xa
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0299006>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER inet_release+0x42/0x48
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c025625b>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER sock_release+0x14/0x60
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c02565d9>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER sock_close+0x29/0x30
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c015a6a2>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER __fput+0x93/0x135
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c015a8e2>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER fput+0x17/0x19
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c01583dc>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER filp_close+0x47/0x51
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0159414>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER sys_close+0x68/0x9d
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  [<c0103876>] 
> >> Mar 26 02:27:14 ROUTER ? 
> >> Mar 26 02:27:14 ROUTER sysenter_past_esp+0x5f/0x85
> >> Mar 26 02:27:14 ROUTER [ 4698.694694]  =======================
> >> Mar 26 02:27:14 ROUTER [ 4698.694694] Code: 
> >> Mar 26 02:27:14 ROUTER 94 
> >> Mar 26 02:27:14 ROUTER c0 
> >> Mar 26 02:27:14 ROUTER 84 
> >> Mar 26 02:27:14 ROUTER c0 
> >> Mar 26 02:27:14 ROUTER b9 
> >> Mar 26 02:27:14 ROUTER 01 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 75 
> >> Mar 26 02:27:14 ROUTER 09 
> >> Mar 26 02:27:14 ROUTER f0 
> >> Mar 26 02:27:14 ROUTER 81 
> >> Mar 26 02:27:14 ROUTER 02 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 01 
> >> Mar 26 02:27:14 ROUTER 30 
> >> Mar 26 02:27:14 ROUTER c9 
> >> Mar 26 02:27:14 ROUTER 5d 
> >> Mar 26 02:27:14 ROUTER 89 
> >> Mar 26 02:27:14 ROUTER c8 
> >> Mar 26 02:27:14 ROUTER c3 
> >> Mar 26 02:27:14 ROUTER 55 
> >> Mar 26 02:27:14 ROUTER ba 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 01 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 89 
> >> Mar 26 02:27:14 ROUTER e5 
> >> Mar 26 02:27:14 ROUTER f0 
> >> Mar 26 02:27:14 ROUTER 66 
> >> Mar 26 02:27:14 ROUTER 0f 
> >> Mar 26 02:27:14 ROUTER c1 
> >> Mar 26 02:27:14 ROUTER 10 
> >> Mar 26 02:27:14 ROUTER 38 
> >> Mar 26 02:27:14 ROUTER f2 
> >> Mar 26 02:27:14 ROUTER 74 
> >> Mar 26 02:27:14 ROUTER 06 
> >> Mar 26 02:27:14 ROUTER f3 
> >> Mar 26 02:27:14 ROUTER 90 
> >> Mar 26 02:27:14 ROUTER unparseable log message: "<8a> "
> >> Mar 26 02:27:14 ROUTER 10 
> >> Mar 26 02:27:14 ROUTER eb 
> >> Mar 26 02:27:14 ROUTER f6 
> >> Mar 26 02:27:14 ROUTER 5d 
> >> Mar 26 02:27:14 ROUTER c3 
> >> Mar 26 02:27:14 ROUTER 55 
> >> Mar 26 02:27:14 ROUTER 89 
> >> Mar 26 02:27:14 ROUTER e5 
> >> Mar 26 02:27:14 ROUTER f0 
> >> Mar 26 02:27:14 ROUTER 81 
> >> Mar 26 02:27:14 ROUTER 28 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 00 
> >> Mar 26 02:27:14 ROUTER 01 
> >> Mar 26 02:27:14 ROUTER 74 
> >> Mar 26 02:27:14 ROUTER 05 
> >> Mar 26 02:27:14 ROUTER e8 
> >> Mar 26 02:27:14 ROUTER 64 
> >> Mar 26 02:27:14 ROUTER fd 
> >> Mar 26 02:27:14 ROUTER 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> >


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

