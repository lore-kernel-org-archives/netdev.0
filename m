From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: exploit skb->xmit_more to conditionally
 send doorbell
Date: Thu, 25 Sep 2014 08:36:20 -0700
Message-ID: <1411659380.16953.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140925164333.7cba128a@redhat.com>
	 <1411657615.16953.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:37648 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbaIYPgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 11:36:21 -0400
Received: by mail-pd0-f181.google.com with SMTP id r10so11023936pdi.40
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 08:36:21 -0700 (PDT)
In-Reply-To: <1411657615.16953.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 08:06 -0700, Eric Dumazet wrote:

> 
> But... Nothing yet in qdisc layer sets xmit_more, unless TSO is
> disabled, and a GSO packet is segmented.
> 
> So you might notice some improvement with this patch, but not if you use
> TSO, and a 40GB NIC is better with TSO on you know ;)
> 

So playing with TSO=off (but GSO=on), we see about 12 % increase of
throughput on a TCP_STREAM flow.

And kernel profile clearly shows the difference of sending or not the
doorbell, as mlx4_en_xmit() shifts. Note also mlx4_en_free_tx_desc()
disappears, this might point to some false sharing or something worth
investigating.

Before patch :

    26.36%  [kernel]  [k] __copy_skb_header             
    16.59%  [kernel]  [k] mlx4_en_xmit                  
     5.62%  [kernel]  [k] __alloc_skb                   
     5.48%  [kernel]  [k] copy_user_enhanced_fast_string
     4.48%  [kernel]  [k] skb_segment                   
     2.46%  [kernel]  [k] mlx4_en_free_tx_desc.isra.27  
     2.31%  [kernel]  [k] _raw_spin_lock                
     2.10%  [kernel]  [k] memcpy                        
     2.01%  [kernel]  [k] tcp_sendmsg                   
     1.62%  [kernel]  [k] __iowrite64_copy              


After patch :

    32.78%  [kernel]  [k] __copy_skb_header             
     8.26%  [kernel]  [k] mlx4_en_xmit                  
     7.25%  [kernel]  [k] __alloc_skb                   
     7.18%  [kernel]  [k] copy_user_enhanced_fast_string
     4.39%  [kernel]  [k] skb_segment                   
     2.87%  [kernel]  [k] memcpy                        
     2.59%  [kernel]  [k] tcp_sendmsg                   
     2.50%  [kernel]  [k] _raw_spin_lock                
     2.38%  [kernel]  [k] dev_hard_start_xmit           
     1.52%  [kernel]  [k] tcp_gso_segment               
     1.50%  [kernel]  [k] kmem_cache_alloc_node_trace   
     1.40%  [kernel]  [k] kmem_cache_alloc_node         
     1.16%  [kernel]  [k] ip_send_check                 
