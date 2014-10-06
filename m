From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] net: introduce netdevice gso_min_segs attribute
Date: Mon, 06 Oct 2014 05:14:50 -0700
Message-ID: <1412597690.11091.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
	 <54312F50.2060608@mellanox.com>
	 <1412524252.11091.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412529087.11091.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D174AC1A3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:54937 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbaJFMOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 08:14:53 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so3206359pdb.30
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 05:14:52 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174AC1A3@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-06 at 10:20 +0000, David Laight wrote:
> From: Eric Dumazet <edumazet@google.com>
> > Some TSO engines might have a too heavy setup cost, that impacts
> > performance on hosts sending small bursts (2 MSS per packet).
> > 
> > This patch adds a device gso_min_segs, allowing drivers to set
> > a minimum segment size for TSO packets, according to the NIC
> > performance.
> > 
> > Tested on a mlx4 NIC, this allows to get a ~110% increase of
> > throughput when sending 2 MSS per packet.
> 
> Doesn't this all depend on what you need to optimise for.
> I can think of three^Wseveral main cases:
> 1) minimising cpu use while saturating the local network.
> 2) minimising latency for single packets.
> 3) maximising throughput for a single connection.
> 4) minimising cpu use when handling a large number of connections.
> plus all the variations in packet size.
> 
> I'm not sure what you are trading for what here.
> 

I am not sure you really understood.

What's the point having a 40GB NIC and not being able to reach 18 Gb on
it, even if you are willing to spend all the cpu cycles you want ?


> Maybe gso = tx_bursting is almost always faster on some hardware?
> (Especially if an idle mac engine is 'kicked' for the first packet
> of a burst.)

This has nothing to do with xmit_more.

I start 1200 flows rate limited to 3 MBytes each.
(1000 netperf -t TCP_STREAM, nothing fancy here)

Theoretical total of 3.6 GBytes per second.

Without patch :
# sar -n DEV 5 5 | grep eth0
05:07:56 AM      eth0 555621.60 1111203.20  35813.03 1642923.46      0.00      0.00      0.60
05:08:01 AM      eth0 555591.00 1111173.80  35810.47 1642877.52      0.00      0.00      0.40
05:08:06 AM      eth0 555586.20 1111162.60  35810.06 1642861.03      0.00      0.00      0.60
05:08:11 AM      eth0 555624.40 1111235.40  35812.75 1642974.19      0.00      0.00      0.60
05:08:16 AM      eth0 555639.60 1111266.80  35813.21 1643017.83      0.00      0.00      0.60
Average:         eth0 555612.56 1111208.36  35811.90 1642930.81      0.00      0.00      0.56

With patch :

# sar -n DEV 5 5 | grep eth0
05:07:04 AM      eth0 1179478.80 2358940.40  76022.47 3487725.22      0.00      0.00      0.60
05:07:09 AM      eth0 1178913.60 2357807.40  75986.60 3486044.00      0.00      0.00      0.40
05:07:14 AM      eth0 1178957.40 2357897.60  75988.98 3486177.50      0.00      0.00      0.60
05:07:19 AM      eth0 1177556.00 2355064.60  75899.37 3481993.37      0.00      0.00      0.60
05:07:24 AM      eth0 1180321.20 2360625.20  76077.15 3490209.58      0.00      0.00      0.40
Average:         eth0 1179045.40 2358067.04  75994.92 3486429.94      0.00      0.00      0.52

Ask yourself which one we prefer.

About cpu costs, we hardly see anything caused by GSO,
now we optimized __copy_skb_header()

     6.36%        swapper  [kernel.kallsyms]   [k] _raw_spin_lock                            
     5.24%        netperf  [kernel.kallsyms]   [k] copy_user_enhanced_fast_string            
     5.03%        swapper  [kernel.kallsyms]   [k] poll_idle                                 
     3.73%        swapper  [kernel.kallsyms]   [k] tcp_ack                                   
     2.73%        swapper  [kernel.kallsyms]   [k] memcpy                                    
     2.49%        swapper  [kernel.kallsyms]   [k] __skb_clone                               
     2.41%        swapper  [kernel.kallsyms]   [k] skb_release_data                          
     2.33%        swapper  [kernel.kallsyms]   [k] intel_idle                                
     2.23%        swapper  [kernel.kallsyms]   [k] tcp_init_tso_segs                         
     1.99%        swapper  [kernel.kallsyms]   [k] fq_dequeue                                
     1.94%        netperf  [kernel.kallsyms]   [k] tcp_sendmsg                               
     1.82%        swapper  [kernel.kallsyms]   [k] tcp_write_xmit                            
     1.28%        swapper  [kernel.kallsyms]   [k] __netif_receive_skb_core                  
     1.23%        swapper  [kernel.kallsyms]   [k] __copy_skb_header                         
     1.14%        swapper  [kernel.kallsyms]   [k] kfree                                     
     1.10%        swapper  [kernel.kallsyms]   [k] kmem_cache_free                           
     1.06%        swapper  [kernel.kallsyms]   [k] mlx4_en_xmit                              
     1.05%        swapper  [kernel.kallsyms]   [k] tcp_wfree                                 
     1.02%        swapper  [kernel.kallsyms]   [k] inet_gso_segment                          
     1.01%        swapper  [kernel.kallsyms]   [k] put_compound_page                         
     0.98%        swapper  [kernel.kallsyms]   [k] _raw_spin_lock_irqsave                    
     0.96%        netperf  [kernel.kallsyms]   [k] __alloc_skb                               
     0.92%        netperf  [kernel.kallsyms]   [k] _raw_spin_lock                            
     0.89%        swapper  [kernel.kallsyms]   [k] skb_segment                               
     0.88%        swapper  [kernel.kallsyms]   [k] tcp_transmit_skb                          
     0.82%        swapper  [kernel.kallsyms]   [k] ip_queue_xmit                             
     0.81%        swapper  [kernel.kallsyms]   [k] __inet_lookup_established                 
     0.76%        swapper  [kernel.kallsyms]   [k] __kfree_skb                               
     0.73%        swapper  [kernel.kallsyms]   [k] ipv4_dst_check                            
     0.66%        netperf  [kernel.kallsyms]   [k] tcp_ack                                   
     0.60%        swapper  [kernel.kallsyms]   [k] __alloc_skb                               
     0.56%        swapper  [kernel.kallsyms]   [k] ipt_do_table                              
