From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Extensible hashing and RCU
Date: Mon, 19 Feb 2007 13:35:18 +0100
Message-ID: <17881.39302.481412.948375@robur.slu.se>
References: <20070204074143.26312.qmail@science.horizon.com>
	<Pine.LNX.4.61.0702050952590.26852@localhost.localdomain>
	<20070217131302.GA22732@2ka.mipt.ru>
	<45D89EFE.4080103@cosmosbay.com>
	<20070218191009.GA28216@2ka.mipt.ru>
	<45D8B54A.70903@cosmosbay.com>
	<p734ppifj8b.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org,
	bcrl@linux.intel.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:47905 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932206AbXBSMf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 07:35:28 -0500
In-Reply-To: <p734ppifj8b.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andi Kleen writes:

 > > If not, you loose.
 > 
 > It all depends on if the higher levels on the trie are small
 > enough to be kept in cache. Even with two cache misses it might
 > still break even, but have better scalability.

 Yes the trick to keep root large to allow a very flat tree and few 
 cache misses. Stefan Nilsson (author of LC-trie) and were able to 
 improve the the LC-trie quite a bit we called this trie+hash ->trash

 The paper discusses trie/hash... (you've seen it)

 http://www.nada.kth.se/~snilsson/public/papers/trash/

 > Another advantage would be to eliminate the need for large memory
 > blocks, which cause problems too e.g. on NUMA. It certainly would
 > save quite some memory if the tree levels are allocated on demand
 > only. However breaking it up might also cost more TLB misses, 
 > but those could be eliminated by preallocating the tree in
 > the same way as the hash today. Don't know if it's needed or not.
 > 
 > I guess someone needs to code it up and try it.
 
 I've implemented trie/trash as replacement for the dst hash to full
 key lookup for ipv4 (unicache) to start with. And is still is focusing 
 on the nasty parts, packet forwarding, as we don't want break this.... 
 So the benfits of full flow lookup is not accounted. I.e the full flow
 lookup could give socket at no cost and do some conntrack support
 like Evgeniy did in netchannels pathes.

 Below, some recent comparisions and profiles for the packet forwardning
 
Input 2 * 65k concurrent flows eth0->eth1, eth2->eth3 in forwarding
On separate CPU Opteron 2218 (2.6 GHZ)  net-2.6.21 git. Numbers are very 
approximative but should still be representative. Profiles are 
collected. 

Performance comparison
----------------------
Table below holds: dst-entries in use, lookup hits, slow path and total pps

Flowlen 40

250k 1020 + 21 = 1041 pps  Vanilla rt_hash=32k
1M    950 + 29 =  979 pps  Vanilla rt_hash=131k
260k  980 + 24 = 1004 pps  Unicache

Flowlen 4 (rdos)

290k 560 + 162 = 722 kpps  Vanilla  rt_hash=32k
1M   400 + 165 = 565 kpps  Vanilla  rt_hash=131k
230k 570 + 170 = 740 kpps  Unicache 


unicache flen=4 pkts
--------------------
c02df84f 5257     7.72078     tkey_extract_bits
c023151a 5230     7.68112     e1000_clean_rx_irq
c02df908 3306     4.85541     tkey_equals
c014cf31 3296     4.84072     kfree
c02f8c3b 3067     4.5044      ip_route_input
c02fbdf0 2948     4.32963     ip_forward
c023024e 2809     4.12548     e1000_xmit_frame
c02e06f1 2792     4.10052     trie_lookup
c02fd764 2159     3.17085     ip_output
c032591c 1965     2.88593     fn_trie_lookup
c014cd82 1456     2.13838     kmem_cache_alloc
c02fa941 1337     1.96361     ip_rcv
c014ced0 1334     1.9592      kmem_cache_free
c02e1538 1289     1.89311     unicache_tcp_establish
c02e2d70 1218     1.78884     dev_queue_xmit
c02e31af 1074     1.57735     netif_receive_skb
c02f8484 1053     1.54651     ip_route_input_slow
c02db552 987      1.44957     __alloc_skb
c02e626f 913      1.34089     dst_alloc
c02edaad 828      1.21606     __qdisc_run
c0321ccf 810      1.18962     fib_get_table
c02e14c1 782      1.1485      match_pktgen
c02e6375 766      1.125       dst_destroy
c02e10e8 728      1.06919     unicache_hash_code
c0231242 647      0.950227    e1000_clean_tx_irq
c02f7d23 625      0.917916    ipv4_dst_destroy

unicache flen=40 pkts
---------------------
c023151a 6742     10.3704     e1000_clean_rx_irq
c02df908 4553     7.00332     tkey_equals
c02fbdf0 4455     6.85258     ip_forward
c02e06f1 4067     6.25577     trie_lookup
c02f8c3b 3951     6.07734     ip_route_input
c02df84f 3929     6.0435      tkey_extract_bits
c023024e 3538     5.44207     e1000_xmit_frame
c014cf31 3152     4.84834     kfree
c02fd764 2711     4.17        ip_output
c02e1538 1930     2.96868     unicache_tcp_establish
c02fa941 1696     2.60875     ip_rcv
c02e31af 1466     2.25497     netif_receive_skb
c02e2d70 1412     2.17191     dev_queue_xmit
c014cd82 1397     2.14883     kmem_cache_alloc
c02db552 1394     2.14422     __alloc_skb
c02edaad 1032     1.5874      __qdisc_run
c02ed6b8 957      1.47204     eth_header
c02e15dd 904      1.39051     unicache_garbage_collect_active
c02db94e 861      1.32437     kfree_skb
c0231242 794      1.22131     e1000_clean_tx_irq
c022fd58 778      1.1967      e1000_tx_map
c014ce73 756      1.16286     __kmalloc
c014ced0 740      1.13825     kmem_cache_free
c02e14c1 701      1.07826     match_pktgen
c023002c 621      0.955208    e1000_tx_queue
c02e78fa 519      0.798314    neigh_resolve_output

Vanilla w. flen=4 pkts rt_hash=32k
----------------------------------
c02f6852 15704    22.9102     ip_route_input
c023151a 5324     7.76705     e1000_clean_rx_irq
c02f84a1 4457     6.5022      ip_rcv
c02f9950 3065     4.47145     ip_forward
c023024e 2630     3.83684     e1000_xmit_frame
c0323380 2343     3.41814     fn_trie_lookup
c02fb2c4 2181     3.1818      ip_output
c02f4a3b 1839     2.68287     rt_intern_hash
c02f4480 1762     2.57054     rt_may_expire
c02f6046 1697     2.47571     ip_route_input_slow
c014ced0 1615     2.35608     kmem_cache_free
c014cf31 1522     2.22041     kfree
c02e0bcb 1321     1.92717     netif_receive_skb
c02e078c 1251     1.82505     dev_queue_xmit
c02e3c8b 1089     1.58871     dst_alloc
c02eb0d4 1010     1.47346     eth_header
c02e3d91 973      1.41948     dst_destroy
c02db552 972      1.41803     __alloc_skb
c02eb4c9 883      1.28819     __qdisc_run
c031f733 798      1.16418     fib_get_table
c01c0fa2 749      1.0927      memcmp
c02f59a5 703      1.02559     ipv4_dst_destroy
c014cd82 673      0.981822    kmem_cache_alloc
c0324fb1 670      0.977446    fib_lookup
c02db94e 670      0.977446    kfree_skb
c022fd58 631      0.92055     e1000_tx_map

Vanilla w. flen=40 pkts rt_hash=32k
-----------------------------------
c02f6852 17445    25.507      ip_route_input
c023151a 7657     11.1956     e1000_clean_rx_irq
c02f84a1 7004     10.2408     ip_rcv
c02f9950 4851     7.09283     ip_forward
c023024e 3874     5.66432     e1000_xmit_frame
c02fb2c4 2905     4.24751     ip_output
c014cf31 2065     3.01931     kfree
c02e078c 1874     2.74005     dev_queue_xmit
c02e0bcb 1712     2.50318     netif_receive_skb
c02db552 1352     1.97681     __alloc_skb
c02eb4c9 1204     1.76041     __qdisc_run
c02eb0d4 980      1.4329      eth_header
c02db94e 846      1.23697     kfree_skb
c022fd58 833      1.21796     e1000_tx_map
c014ced0 819      1.19749     kmem_cache_free
c014cd82 806      1.17848     kmem_cache_alloc
c014ce73 761      1.11269     __kmalloc
c0231242 717      1.04835     e1000_clean_tx_irq
c023002c 595      0.869972    e1000_tx_queue
c02e5316 563      0.823184    neigh_resolve_output
c02eb221 498      0.728145    eth_type_trans
c0231ea2 471      0.688667    e1000_alloc_rx_buffers
c0323380 459      0.671121    fn_trie_lookup
c02ef8fd 456      0.666735    qdisc_dequeue_head
c02e06dd 422      0.617022    dev_hard_start_xmit
c02f4074 404      0.590704    rt_hash_code

Vanilla w. flen=4 pkts rt_hash=131k
------------------------------------
c02f6852 9679     17.3758     ip_route_input
c023151a 3895     6.99232     e1000_clean_rx_irq
c02f84a1 2858     5.13069     ip_rcv
c0323380 2507     4.50057     fn_trie_lookup
c023024e 2233     4.00869     e1000_xmit_frame
c02f4480 2075     3.72505     rt_may_expire
c02f9950 1966     3.52937     ip_forward
c014ced0 1659     2.97824     kmem_cache_free
c02f4a3b 1654     2.96927     rt_intern_hash
c02f6046 1523     2.73409     ip_route_input_slow
c02fb2c4 1500     2.6928      ip_output
c014cf31 1375     2.4684      kfree
c02e078c 1098     1.97113     dev_queue_xmit
c02e3c8b 1081     1.94061     dst_alloc
c02e3d91 947      1.70006     dst_destroy
c014cc12 890      1.59773     free_block
c02e0bcb 874      1.56901     netif_receive_skb
c02eb4c9 861      1.54567     __qdisc_run
c02db552 777      1.39487     __alloc_skb
c02f59a5 705      1.26562     ipv4_dst_destroy
c031f733 689      1.2369      fib_get_table
c02ef8fd 669      1.20099     qdisc_dequeue_head
c01c0fa2 665      1.19381     memcmp
c0231242 642      1.15252     e1000_clean_tx_irq
c0324fb1 636      1.14175     fib_lookup
c014c8f1 620      1.11303     slab_put_obj

Vanilla w. flen=40 pkts rt_hash=131k
------------------------------------
c02f6852 9647     16.9913     ip_route_input
c023151a 6879     12.116      e1000_clean_rx_irq
c02f84a1 6102     10.7475     ip_rcv
c02f9950 4248     7.48203     ip_forward
c023024e 3625     6.38474     e1000_xmit_frame
c02fb2c4 2501     4.40503     ip_output
c014cf31 2349     4.13731     kfree
c02e078c 1714     3.01888     dev_queue_xmit
c02e0bcb 1461     2.57327     netif_receive_skb
c02eb4c9 1286     2.26504     __qdisc_run
c02db552 1239     2.18226     __alloc_skb
c0231242 1034     1.82119     e1000_clean_tx_irq
c02ef8fd 936      1.64858     qdisc_dequeue_head
c014ced0 888      1.56404     kmem_cache_free
c014cd82 877      1.54467     kmem_cache_alloc
c022fd58 828      1.45836     e1000_tx_map
c014ce73 789      1.38967     __kmalloc
c02db94e 741      1.30513     kfree_skb
c023002c 622      1.09553     e1000_tx_queue
c02eb221 524      0.922925    eth_type_trans
c0323380 473      0.833098    fn_trie_lookup
c02e039b 449      0.790827    dev_kfree_skb_any
c0231ea2 442      0.778498    e1000_alloc_rx_buffers
c02e06dd 420      0.739749    dev_hard_start_xmit
c0230227 391      0.688671    e1000_maybe_stop_tx
c02f4074 336      0.591799    rt_hash_code


Some comments:

To some extent we compare apples and bananas but still interesting 
uniccahe does the full key lookup and we see the lookup cost itself 
is not expensive (trie_lookup) but we see  key handling costs a bit. 
tkey_extract_bits is when me make the key. The corresponding 
for the hash would be when we create the actual hash.

tkey_equals is to verify the lookup also this we do with hash
maybe it should be possible i case of routing to optimize a bit.
Only if packet is for localhost we would need to do the full
tkey_equals - this could possible save some cache misses.


Cheers.
					--ro


 
 
