From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Thu, 29 May 2003 13:51:25 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030529205125.GA30058@netnation.com>
References: <20030522.015815.91322249.davem@redhat.com> <20030522.034058.71558626.davem@redhat.com> <20030522114438.GD2961@netnation.com> <20030522.153330.74735095.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030522.153330.74735095.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Thu, May 22, 2003 at 03:33:30PM -0700, David S. Miller wrote:

>    If you'd like I can try to regenerate a profile, but you probably
>    already know what it will look like.
> 
> I obviously know some things that will change, but I am still
> very much interested in new profiles.

Sorry for the delay -- I was away for a few days.  Here are profile
results from the same machine (still with XT-PIC), the same 300000 route
entries, and your original patch that fixes the hashing.  I should also
mention that in all of these tests I have one filter rule in the INPUT
chain (after routing) to avoid sending back zillions of ICMP packets out
to the spoofed source IPs.

...
    27 check_pgt_cache                            0.8438
  1430 ip_rcv_finish                              2.4870
   135 ipv4_dst_destroy                           2.8125
   357 cpu_idle                                   3.1875
  7714 ip_route_input_slow                        3.3481
   434 fib_rules_policy                           3.8750
  2952 ip_rcv                                     5.2714
    85 kmem_cache_alloc                           5.3125
  2188 netif_receive_skb                          5.4700
  2734 alloc_skb                                  5.6958
   822 skb_release_data                           5.7083
  2161 __kfree_skb                                5.8723
   572 ip_local_deliver                           5.9583
  1023 __constant_c_and_count_memset              6.3937
  3801 fib_validate_source                        6.7875
  6778 rt_garbage_collect                         7.1801
   497 __fib_res_prefsrc                          7.7656
  3035 inet_select_addr                           8.2473
  2717 tcp_match                                  8.4906
   552 ipt_hook                                   8.6250
   706 kmalloc                                    8.8250
  1561 kfree                                      8.8693
  1287 jhash_3words                               8.9375
  5937 nf_hook_slow                              10.9136
  2532 fib_semantic_match                        12.1731
  2356 eth_type_trans                            12.2708
  2166 nf_iterate                                12.3068
  4446 net_rx_action                             12.6307
  1622 kfree_skbmem                              12.6719
   842 rt_hash_code                              13.1562
 16030 ipt_do_table                              14.5199
  2104 tg3_recycle_rx                            14.6111
 13795 tg3_rx                                    14.6133
  5667 __kmem_cache_alloc                        17.7094
  1193 ipt_route_hook                            18.6406
  2851 do_gettimeofday                           19.7986
  7423 fib_lookup                                23.1969
  1497 fib_rule_put                              23.3906
  8803 ip_packet_match                           26.1994
  4970 dst_destroy                               28.2386
 22479 rt_intern_hash                            29.2695
  8804 kmem_cache_free                           55.0250
  8380 dst_alloc                                 58.1944
 18252 fn_hash_lookup                            63.3750
 25473 tg3_interrupt                             75.8125
 24036 do_softirq                               100.1500
 51355 ip_route_input                           118.8773
 57304 tg3_poll                                 188.5000
111691 handle_IRQ_event                         698.0688
168828 default_idle                             2637.9375

Full profile output available here:

	http://blue.netnation.com/sim/ref/
	readprofile.full_route_table_hash_fixed.*

Note that if I increase the packet rate and NAPI kicks in, all of the
handle_IRQ and similar overhead basically disappears because it no longer
uses IRQs.  Pretty spiffy.  Here is a profile of that:

...
    25 tasklet_hi_action                          0.1562
    46 timer_bh                                   0.2054
    97 net_rx_action                              0.2756
    93 tg3_vlan_rx                                0.3875
   158 tg3_poll                                   0.5197
  1630 ip_rcv_finish                              2.8348
   142 ipv4_dst_destroy                           2.9583
   429 fib_rules_policy                           3.8304
  8959 ip_route_input_slow                        3.8885
  2438 ip_rcv                                     4.3536
  2504 alloc_skb                                  5.2167
  1991 __kfree_skb                                5.4103
  2279 netif_receive_skb                          5.6975
   929 skb_release_data                           6.4514
   669 ip_local_deliver                           6.9688
  1175 __constant_c_and_count_memset              7.3438
  2367 tcp_match                                  7.3969
   124 kmem_cache_alloc                           7.7500
  4535 fib_validate_source                        8.0982
   598 __fib_res_prefsrc                          9.3438
  8896 rt_garbage_collect                         9.4237
  3582 inet_select_addr                           9.7337
  1747 kfree                                      9.9261
   717 ipt_hook                                  11.2031
   938 kmalloc                                   11.7250
  1747 jhash_3words                              12.1319
  6879 nf_hook_slow                              12.6452
  2439 eth_type_trans                            12.7031
  1695 kfree_skbmem                              13.2422
  2358 nf_iterate                                13.3977
   872 rt_hash_code                              13.6250
  2933 fib_semantic_match                        14.1010
 16553 ipt_do_table                              14.9937
 15339 tg3_rx                                    16.2489
  2482 tg3_recycle_rx                            17.2361
  5967 __kmem_cache_alloc                        18.6469
  1237 ipt_route_hook                            19.3281
  3120 do_gettimeofday                           21.6667
  8299 ip_packet_match                           24.6994
  8031 fib_lookup                                25.0969
  1877 fib_rule_put                              29.3281
  6088 dst_destroy                               34.5909
 26833 rt_intern_hash                            34.9388
 10666 kmem_cache_free                           66.6625
 20193 fn_hash_lookup                            70.1146
 10516 dst_alloc                                 73.0278
 64803 ip_route_input                           150.0069

Full profile output available as:

	readprofile.full_route_table_hash_fixed_napi.*

Hmm.. I see there is some redundant hashing going on in
ip_route_input_slow() (called only from ip_route_input() which already
calculates the hash), but my patch to fix that adds yet another argument
to ip_route_slow() which isn't that pretty.  It looks like that function
isn't using much CPU anyway.

Why is ip_route_input() so heavy still?  This kernel is compiled
CONFIG_SMP which makes the read_lock() calls actually do something, but
it looks like they should be fairly light.  Should I add an iteration
counter to the for loop, perhaps?

Simon-
