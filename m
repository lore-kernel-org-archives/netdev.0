From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Handle new frag_list of frags GRO packets
Date: Tue, 12 Nov 2013 18:31:58 -0800
Message-ID: <1384309918.28458.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107004339.GA28156@gondor.apana.org.au>
	 <20131107062234.GA31156@gondor.apana.org.au>
	 <20131107070335.GA31638@gondor.apana.org.au>
	 <20131107070647.GB31638@gondor.apana.org.au>
	 <20131111185207.GA12277@gondor.apana.org.au>
	 <1384305223.28458.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113012920.GA27897@gondor.apana.org.au>
	 <1384309034.28458.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113022243.GA28204@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:34812 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757925Ab3KMCcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 21:32:11 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so1586399pbb.28
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 18:32:11 -0800 (PST)
In-Reply-To: <20131113022243.GA28204@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 10:22 +0800, Herbert Xu wrote:
> On Tue, Nov 12, 2013 at 06:17:14PM -0800, Eric Dumazet wrote:
> > On Wed, 2013-11-13 at 09:29 +0800, Herbert Xu wrote:
> > 
> > > I presume this is on a NIC that produces completely linear packets?
> > 
> > Sorry : with mlx4 driver, GRO builds nice skbs with one page frag per
> > MSS, so each skb found on frag_list is fully loaded with 16 MSS
> 
> OK, so what are the numbers when GRO is off completely?

Pretty bad, as we drop many packets.

My (single) tcp flow is no longer full speed. (link speed is 10Gb)

lpaa6:~# mpstat -P 3 1 10
06:28:11 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle    intr/s
06:28:12 PM    3    2.04    0.00    7.14    0.00    5.10   73.47    0.00    0.00   12.24  28594.90
06:28:13 PM    3    3.00    0.00    3.00    0.00    5.00   74.00    0.00    0.00   15.00  28492.00
06:28:14 PM    3    0.00    0.00    0.99    0.00    5.94   93.07    0.00    0.00    0.00  35948.51
06:28:15 PM    3    5.00    0.00    4.00    0.00    5.00   74.00    0.00    0.00   12.00  28699.00
06:28:16 PM    3    3.06    0.00    5.10    0.00    5.10   75.51    0.00    0.00   11.22  30037.76
06:28:17 PM    3    0.00    0.00    0.00    0.00    6.00   92.00    0.00    0.00    2.00  36338.00
06:28:18 PM    3    1.00    0.00    2.00    0.00    5.00   73.00    0.00    0.00   19.00  28230.00
06:28:19 PM    3    0.00    0.00    2.02    0.00    6.06   86.87    0.00    0.00    5.05  33987.88
06:28:20 PM    3    0.00    0.00    0.00    0.00    6.00   81.00    0.00    0.00   13.00  32086.00
06:28:21 PM    3    1.98    0.00    1.98    0.00    4.95   73.27    0.00    0.00   17.82  28383.17
Average:       3    1.60    0.00    2.61    0.00    5.42   79.64    0.00    0.00   10.73  31086.06

perf profile (GRO off)

     6.88%  [kernel]          [k] fib_table_lookup                      
     5.97%  [kernel]          [k] _raw_spin_lock                        
     5.40%  [kernel]          [k] ipt_do_table                          
     4.79%  [mlx4_en]         [k] mlx4_en_process_rx_cq                 
     4.29%  [kernel]          [k] htb_dequeue                           
     3.65%  [mlx4_en]         [k] mlx4_en_xmit                          
     2.48%  [kernel]          [k] kmem_cache_free                       
     2.27%  [kernel]          [k] __netif_receive_skb_core              
     2.23%  [kernel]          [k] local_bh_enable                       
     2.22%  [mlx4_en]         [k] mlx4_en_tx_irq                        
     2.17%  [kernel]          [k] ip_route_input_noref                  
     2.16%  [kernel]          [k] kmem_cache_alloc                      
     2.03%  [kernel]          [k] check_leaf.isra.7                     
     1.89%  [kernel]          [k] inet_getpeer                          
     1.62%  [kernel]          [k] nf_iterate                            
     1.44%  [kernel]          [k] fib_validate_source                   
     1.42%  [kernel]          [k] dev_kfree_skb_irq                     
     1.39%  [kernel]          [k] build_skb                             
     1.38%  [kernel]          [k] ip_rcv                                
     1.26%  [kernel]          [k] htb_lookup_leaf                       
     1.23%  [kernel]          [k] dev_queue_xmit                        
     1.17%  [kernel]          [k] _raw_spin_lock_bh                     
     1.14%  [mlx4_en]         [k] mlx4_en_complete_rx_desc              
     1.08%  [unknown]         [.] 0x00000000019cdd6d                    
     1.03%  [kernel]          [k] htb_deactivate_prios                  
     0.94%  [kernel]          [k] htb_activate_prios                    
     0.91%  [kernel]          [k] htb_enqueue                           
     0.89%  [kernel]          [k] ip_forward                            
     0.87%  [mlx4_en]         [k] mlx4_en_free_tx_desc.isra.25          
     0.84%  [mlx4_en]         [k] mlx4_en_alloc_frags                   
     0.83%  [kernel]          [k] __netdev_alloc_frag                   
     0.83%  [kernel]          [k] read_tsc                              
     0.83%  [kernel]          [k] netif_receive_skb                     
     0.81%  [kernel]          [k] nf_hook_slow                          
     0.80%  [kernel]          [k] dst_alloc                             
