From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Thu, 17 Nov 2016 22:19:41 +0100
Message-ID: <20161117221941.3b525181@redhat.com>
References: <20140903165943.372b897b@redhat.com>
        <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
        <20161116131609.4e5726b4@redhat.com>
        <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
        <20161116234022.2bad179b@redhat.com>
        <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117091638.5fab8494@redhat.com>
        <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117144248.23500001@redhat.com>
        <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117155753.17b76f5a@redhat.com>
        <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117193021.580589ae@redhat.com>
        <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42586 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750751AbcKQVTq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 16:19:46 -0500
In-Reply-To: <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2016 10:51:23 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2016-11-17 at 19:30 +0100, Jesper Dangaard Brouer wrote:
> 
> > The point is I can see a socket Send-Q forming, thus we do know the
> > application have something to send. Thus, and possibility for
> > non-opportunistic bulking. Allowing/implementing bulk enqueue from
> > socket layer into qdisc layer, should be fairly simple (and rest of
> > xmit_more is already in place).    
> 
> 
> As I said, you are fooled by TX completions.
> 
> Please make sure to increase the sndbuf limits !
> 
> echo 2129920 >/proc/sys/net/core/wmem_default
> 
> lpaa23:~# sar -n DEV 1 10|grep eth1
> 10:49:25         eth1      7.00 9273283.00      0.61 2187214.90      0.00      0.00      0.00
> 10:49:26         eth1      1.00 9230795.00      0.06 2176787.57      0.00      0.00      1.00
> 10:49:27         eth1      2.00 9247906.00      0.17 2180915.45      0.00      0.00      0.00
> 10:49:28         eth1      3.00 9246542.00      0.23 2180790.38      0.00      0.00      1.00
> 10:49:29         eth1      1.00 9239218.00      0.06 2179044.83      0.00      0.00      0.00
> 10:49:30         eth1      3.00 9248775.00      0.23 2181257.84      0.00      0.00      1.00
> 10:49:31         eth1      4.00 9225471.00      0.65 2175772.75      0.00      0.00      0.00
> 10:49:32         eth1      2.00 9253536.00      0.33 2182666.44      0.00      0.00      1.00
> 10:49:33         eth1      1.00 9265900.00      0.06 2185598.40      0.00      0.00      0.00
> 10:49:34         eth1      1.00 6949031.00      0.06 1638889.63      0.00      0.00      1.00
> Average:         eth1      2.50 9018045.70      0.25 2126893.82      0.00      0.00      0.50
> 
> 
> lpaa23:~# ethtool -S eth1|grep more; sleep 1;ethtool -S eth1|grep more
>      xmit_more: 2251366909
>      xmit_more: 2256011392
> 
> lpaa23:~# echo 2256011392-2251366909 | bc
> 4644483

xmit more not happen that frequently for my setup, it does happen
sometimes. And I do monitor with "ethtool -S".

~/git/network-testing/bin/ethtool_stats.pl --sec 2 --dev mlx5p2
Show adapter(s) (mlx5p2) statistics (ONLY that changed!)
Ethtool(mlx5p2  ) stat:     92900913 (     92,900,913) <= tx0_bytes /sec
Ethtool(mlx5p2  ) stat:        36073 (         36,073) <= tx0_nop /sec
Ethtool(mlx5p2  ) stat:      1548349 (      1,548,349) <= tx0_packets /sec
Ethtool(mlx5p2  ) stat:            1 (              1) <= tx0_xmit_more /sec
Ethtool(mlx5p2  ) stat:     92884899 (     92,884,899) <= tx_bytes /sec
Ethtool(mlx5p2  ) stat:     99297696 (     99,297,696) <= tx_bytes_phy /sec
Ethtool(mlx5p2  ) stat:      1548082 (      1,548,082) <= tx_csum_partial /sec
Ethtool(mlx5p2  ) stat:      1548082 (      1,548,082) <= tx_packets /sec
Ethtool(mlx5p2  ) stat:      1551527 (      1,551,527) <= tx_packets_phy /sec
Ethtool(mlx5p2  ) stat:     99076658 (     99,076,658) <= tx_prio1_bytes /sec
Ethtool(mlx5p2  ) stat:      1548073 (      1,548,073) <= tx_prio1_packets /sec
Ethtool(mlx5p2  ) stat:     92936078 (     92,936,078) <= tx_vport_unicast_bytes /sec
Ethtool(mlx5p2  ) stat:      1548934 (      1,548,934) <= tx_vport_unicast_packets /sec
Ethtool(mlx5p2  ) stat:            1 (              1) <= tx_xmit_more /sec

(after several attempts I got:)
$ ethtool -S mlx5p2|grep more; sleep 1;ethtool -S mlx5p2|grep more
     tx_xmit_more: 14048
     tx0_xmit_more: 14048
     tx_xmit_more: 14049
     tx0_xmit_more: 14049

This was with:
 $ grep -H . /proc/sys/net/core/wmem_default
 /proc/sys/net/core/wmem_default:2129920

>    PerfTop:   76969 irqs/sec  kernel:96.6%  exact: 100.0% [4000Hz cycles:pp],  (all, 48 CPUs)
> ---------------------------------------------------------------------------------------------
> 
>     11.64%  [kernel]  [k] skb_set_owner_w               
>      6.21%  [kernel]  [k] queued_spin_lock_slowpath     
>      4.76%  [kernel]  [k] _raw_spin_lock                
>      4.40%  [kernel]  [k] __ip_make_skb                 
>      3.10%  [kernel]  [k] sock_wfree                    
>      2.87%  [kernel]  [k] ipt_do_table                  
>      2.76%  [kernel]  [k] fq_dequeue                    
>      2.71%  [kernel]  [k] mlx4_en_xmit                  
>      2.50%  [kernel]  [k] __dev_queue_xmit              
>      2.29%  [kernel]  [k] __ip_append_data.isra.40      
>      2.28%  [kernel]  [k] udp_sendmsg                   
>      2.01%  [kernel]  [k] __alloc_skb                   
>      1.90%  [kernel]  [k] napi_consume_skb              
>      1.63%  [kernel]  [k] udp_send_skb                  
>      1.62%  [kernel]  [k] skb_release_data              
>      1.62%  [kernel]  [k] entry_SYSCALL_64_fastpath     
>      1.56%  [kernel]  [k] dev_hard_start_xmit           
>      1.55%  udpsnd    [.] __libc_send                   
>      1.48%  [kernel]  [k] netif_skb_features            
>      1.42%  [kernel]  [k] __qdisc_run                   
>      1.35%  [kernel]  [k] sk_dst_check                  
>      1.33%  [kernel]  [k] sock_def_write_space          
>      1.30%  [kernel]  [k] kmem_cache_alloc_node_trace   
>      1.29%  [kernel]  [k] __local_bh_enable_ip          
>      1.21%  [kernel]  [k] copy_user_enhanced_fast_string
>      1.08%  [kernel]  [k] __kmalloc_reserve.isra.40     
>      1.08%  [kernel]  [k] SYSC_sendto                   
>      1.07%  [kernel]  [k] kmem_cache_alloc_node         
>      0.95%  [kernel]  [k] ip_finish_output2             
>      0.95%  [kernel]  [k] ktime_get                     
>      0.91%  [kernel]  [k] validate_xmit_skb             
>      0.88%  [kernel]  [k] sock_alloc_send_pskb          
>      0.82%  [kernel]  [k] sock_sendmsg                  

I'm more interested in why I see fib_table_lookup() and
__ip_route_output_key_hash() when you don't ?!?  There must be some
mistake in my setup!

Maybe you can share your udp flood "udpsnd" program source?

Maybe I'm missing some important sysctl /proc/net/sys/ ?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

p.s. I placed my testing software here:
 https://github.com/netoptimizer/network-testing/tree/master/src
