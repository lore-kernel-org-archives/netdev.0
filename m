From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 19:40:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16103.27039.204333.952703@robur.slu.se>
References: <Pine.LNX.4.51.0306101332300.8755@ns.istop.com>
	<20030610.103234.116374169.davem@redhat.com>
	<16102.9418.43884.336925@robur.slu.se>
	<20030610.115759.26513736.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, ralph+d@istop.com, ralph@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, sim@netnation.com,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.115759.26513736.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > Actually, that's a good idea, if someone if brave just rip out
 > fib_validate_source (just don't call it, should work for valid
 > traffic) and see what happens :)


Just about 9% better a bit of surprise...

Still 1 dst/pkt. Input rate 2*189 kpps. All slow path with fib_source_validate 
removed. Now 121 kpps. (114 kpps before)

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 3212017 9661983 9661983 6787987      8      0      0      0 BRU
eth1   1500   0      9      0      0      0 3212020      0      0      0 BRU
eth2   1500   0 3212714 9656726 9656726 6787290      4      0      0      0 BRU
eth3   1500   0      1      0      0      0 3212713      0      0      0 BRU
rt_cache_stat
00008b63  00000000 0062089f 00000000 00000000 00000000 00000000 00000000  00000000 00000001 00000000 00617a8b 00617a7f 00000005 00000000 00000000 00000002 


So I added fib_source_validat again and profiled the 1 dst/pkt case. So this 
just profile of the slow path with some different performance counters. I'll 
guess the first is most interesting.
 
Cpu type: P4 / Xeon
Cpu speed was (MHz estimation) : 1799.55
Counter 0 counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped) with a unit mask of 0x01 (count cycles when processor is active) count 180000
vma      samples  %-age       symbol name
c023c038 107340   33.143      fn_hash_lookup
c013154c 17399    5.37223     free_block
c0211364 16502    5.09527     __rt_hash_shrink
c01316e4 12854    3.96889     kmem_cache_alloc
c01b86dc 11719    3.61844     e1000_clean_rx_irq
c02033a0 11557    3.56842     alloc_skb
c0212330 11378    3.51315     ip_route_input_slow
c020cc98 9765     3.01511     eth_type_trans
c0208860 7986     2.46581     dst_alloc
c0216d98 7733     2.38769     ip_output
c021200c 6940     2.14284     rt_set_nexthop
c0213a9c 6331     1.9548      dst_free
c0126998 6272     1.93659     rcu_do_batch
c02035cc 6164     1.90324     skb_release_data
c02036c4 6068     1.8736      __kfree_skb
c01b8558 5532     1.7081      e1000_clean_tx_irq
c01b7678 4970     1.53457     e1000_xmit_frame
c020905c 4965     1.53303     neigh_lookup
c013179c 4819     1.48795     kmem_cache_free
c01317e0 4441     1.37123     kfree
c020cb30 4002     1.23568     eth_header
c0131728 3522     1.08748     kmalloc
c0131384 3434     1.06031     cache_alloc_refill
c023a5fc 3392     1.04734     fib_validate_source
c023d814 2989     0.922904    fib_lookup
c0113368 2190     0.676199    mark_offset_tsc

Cpu type: P4 / Xeon
Cpu speed was (MHz estimation) : 1799.55
Counter 7 counted MISPRED_BRANCH_RETIRED events (retired mispredicted branches) with a unit mask of 0x01 (retired instruction is non-bogus) count 18000
vma      samples  %-age       symbol name
c023c038 5246     85.0933     fn_hash_lookup
c020905c 194      3.1468      neigh_lookup
c0131384 99       1.60584     cache_alloc_refill
c02036c4 66       1.07056     __kfree_skb
c020ce70 51       0.827251    qdisc_restart
c02033a0 51       0.827251    alloc_skb
c0211364 44       0.713706    __rt_hash_shrink
c01b86dc 32       0.519059    e1000_clean_rx_irq
c023d814 28       0.454177    fib_lookup
c0213a9c 25       0.405515    dst_free
c0210ce8 25       0.405515    rt_garbage_collect
c020ef04 23       0.373074    pfifo_dequeue
c01b8558 20       0.324412    e1000_clean_tx_irq
c0206dcc 19       0.308191    netif_receive_skb
c0206880 18       0.291971    dev_queue_xmit
c01b8ab0 18       0.291971    e1000_alloc_rx_buffers
c02155e0 17       0.27575     ip_forward
c021200c 15       0.243309    rt_set_nexthop
c020cc98 13       0.210868    eth_type_trans
c01b7678 13       0.210868    e1000_xmit_frame
c0212330 12       0.194647    ip_route_input_slow
c0131728 12       0.194647    kmalloc
c010f3d0 12       0.194647    do_gettimeofday
c020a12c 9        0.145985    neigh_resolve_output
c010c350 9        0.145985    do_IRQ
c0216d98 8        0.129765    ip_output

Cpu type: P4 / Xeon
Cpu speed was (MHz estimation) : 1799.55
Counter 0 counted BSQ_CACHE_REFERENCE events (cache references seen by the bus unit) with a unit mask of 0x100 (Not set) count 18000
vma      samples  %-age       symbol name
c023c038 2361     31.3047     fn_hash_lookup
c013154c 686      9.09573     free_block
c0211364 507      6.72235     __rt_hash_shrink
c0208860 502      6.65606     dst_alloc
c01b86dc 433      5.74118     e1000_clean_rx_irq
c0213a9c 393      5.21082     dst_free
c0126998 378      5.01193     rcu_do_batch
c020cc98 262      3.47388     eth_type_trans
c02036c4 237      3.1424      __kfree_skb
c0126970 234      3.10263     call_rcu
c01b8558 212      2.81093     e1000_clean_tx_irq
c0216d98 208      2.75789     ip_output
c02035cc 202      2.67833     skb_release_data
c01b7678 189      2.50597     e1000_xmit_frame
c01b8ab0 141      1.86953     e1000_alloc_rx_buffers
c02033a0 118      1.56457     alloc_skb
c0131384 73       0.967913    cache_alloc_refill
c020ce70 46       0.609918    qdisc_restart
c0212330 36       0.477327    ip_route_input_slow
c01317e0 33       0.43755     kfree
c0206880 28       0.371254    dev_queue_xmit
c0210ce8 26       0.344736    rt_garbage_collect
c020ef04 17       0.225404    pfifo_dequeue
c02109d4 16       0.212145    rt_may_expire
c01316e4 16       0.212145    kmem_cache_alloc
c02155e0 12       0.159109    ip_forward

Cpu type: P4 / Xeon
Cpu speed was (MHz estimation) : 1799.55
Counter 7 counted MACHINE_CLEAR events (cycles with entire machine pipeline cleared) with a unit mask of 0x01 (count a portion of cycles the machine is cleared for any cause) count 18000
vma      samples  %-age       symbol name
c010a738 326      55.4422     irq_entries_start
c010afd8 128      21.7687     apic_timer_interrupt
c023c038 45       7.65306     fn_hash_lookup
c013154c 9        1.53061     free_block
c010b208 9        1.53061     page_fault
c01b86dc 8        1.36054     e1000_clean_rx_irq
c0131384 8        1.36054     cache_alloc_refill
c0208860 7        1.19048     dst_alloc
c0213a9c 6        1.02041     dst_free
c0126970 6        1.02041     call_rcu
c0216d98 5        0.85034     ip_output
c0126998 5        0.85034     rcu_do_batch
c0211364 4        0.680272    __rt_hash_shrink
c020cc98 4        0.680272    eth_type_trans
c02036c4 4        0.680272    __kfree_skb
c02035cc 3        0.510204    skb_release_data
c02033a0 3        0.510204    alloc_skb
c01b7678 3        0.510204    e1000_xmit_frame
c01b8ab0 2        0.340136    e1000_alloc_rx_buffers
c01b8558 2        0.340136    e1000_clean_tx_irq
c020ce70 1        0.170068    qdisc_restart
c02f940c 0        0           ipsec_pfkey_init
c02f93cc 0        0           packet_init
c02f9354 0        0           af_unix_init
c02f9320 0        0           xfrm4_input_init
c02f9304 0        0           xfrm4_state_init


Cheers.
						--ro
