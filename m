From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 01:18:03 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609081803.GF20613@netnation.com>
References: <001501c32e4b$35d67d60$4a00000a@badass> <20030608.230332.48514434.davem@redhat.com> <20030609065211.GB20613@netnation.com> <20030608.235622.38700262.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030608.235622.38700262.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Sun, Jun 08, 2003 at 11:56:22PM -0700, David S. Miller wrote:

> +	if (cand) {
> +		*candp = cand->u.rt_next;
> +		rt_free(cand);
>  	}

Hmm...It looks like this is still freeing the entry.. Is it possible to
recycle the dst without reallocating it?

This is the end of the time-sorted profile output of the test box
saturated by incoming juno packets (firewalled in INPUT chain to avoid
responses to spoofed src IPs), NAPI 100% of the time, tg3:

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

This is with a routing table of 300,000 entries (though only one prefix)
and with your hash fix patch.  ip_route_input is still highest, but
dst_alloc is an obvious second.  ip_route_input is actually always the
highest (excluding the IRQ handling stuff), and doesn't seem to change at
all based on routing table size.

	http://blue.netnation.com/sim/ref/

Simon-

[        Simon Kirby        ][        Network Operations        ]
[     sim@netnation.com     ][   NetNation Communications Inc.  ]
[  Opinions expressed are not necessarily those of my employer. ]
