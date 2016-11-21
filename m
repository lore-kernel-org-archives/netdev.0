From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Mon, 21 Nov 2016 17:03:51 +0100
Message-ID: <20161121170351.50a09ee1@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:52410 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932267AbcKUQD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 11:03:56 -0500
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

Obviously TX completions play a role yes, and I bet I can adjust the
TX completion to cause xmit_more to happen, at the expense of
introducing added latency.

The point is the "bloated" spinlock in __dev_queue_xmit is still caused
by the MMIO tailptr/doorbell.  The added cost occurs when enqueueing
packets, and result in the inability to get enough packets into the
qdisc for xmit_more going (on my system).  I argue that a bulk enqueue
API would allow us to get past the hurtle of transitioning into
xmit_more mode more easily.


> Please make sure to increase the sndbuf limits !
> 
> echo 2129920 >/proc/sys/net/core/wmem_default

Testing with this makes no difference.

 $ grep -H . /proc/sys/net/core/wmem_default
 /proc/sys/net/core/wmem_default:2129920


> lpaa23:~# sar -n DEV 1 10|grep eth1
                  IFACE   rxpck/s    txpck/s    rxkB/s     txkB/s   rxcmp/s   txcmp/s  rxmcst/s
> 10:49:25         eth1      7.00 9273283.00      0.61 2187214.90      0.00      0.00      0.00
> 10:49:26         eth1      1.00 9230795.00      0.06 2176787.57      0.00      0.00      1.00
> 10:49:27         eth1      2.00 9247906.00      0.17 2180915.45      0.00      0.00      0.00
> 10:49:28         eth1      3.00 9246542.00      0.23 2180790.38      0.00      0.00      1.00
> Average:         eth1      2.50 9018045.70      0.25 2126893.82      0.00      0.00      0.50

Very impressive numbers 9.2Mpps TX.

What is this test?  What kind of traffic? Multiple CPUs?


> lpaa23:~# ethtool -S eth1|grep more; sleep 1;ethtool -S eth1|grep more
>      xmit_more: 2251366909
>      xmit_more: 2256011392
> 
> lpaa23:~# echo 2256011392-2251366909 | bc
> 4644483

The xmit_more definitely works on your system, but I cannot get it to
"kick-in" on my setup.  Once the xmit_more is active, then the
"bloated" spinlock problem should go way.


(Tests with "udp_flood --pmtu 3 --send")

Forcing TX completion to happen on the same CPU, no xmit_more:

 ~/git/network-testing/bin/ethtool_stats.pl --sec 2 --dev mlx5p2
 Show adapter(s) (mlx5p2) statistics (ONLY that changed!)
 Ethtool(mlx5p2  ) stat:    104592908 (    104,592,908) <= tx0_bytes /sec
 Ethtool(mlx5p2  ) stat:        39059 (         39,059) <= tx0_nop /sec
 Ethtool(mlx5p2  ) stat:      1743215 (      1,743,215) <= tx0_packets /sec 
 Ethtool(mlx5p2  ) stat:    104719986 (    104,719,986) <= tx_bytes /sec
 Ethtool(mlx5p2  ) stat:    111774540 (    111,774,540) <= tx_bytes_phy /sec
 Ethtool(mlx5p2  ) stat:      1745333 (      1,745,333) <= tx_csum_partial /sec
 Ethtool(mlx5p2  ) stat:      1745333 (      1,745,333) <= tx_packets /sec
 Ethtool(mlx5p2  ) stat:      1746477 (      1,746,477) <= tx_packets_phy /sec
 Ethtool(mlx5p2  ) stat:    111483434 (    111,483,434) <= tx_prio1_bytes /sec
 Ethtool(mlx5p2  ) stat:      1741928 (      1,741,928) <= tx_prio1_packets /sec

Forcing TX completion to happen on remote CPU, some xmit_more:

 Show adapter(s) (mlx5p2) statistics (ONLY that changed!)
 Ethtool(mlx5p2  ) stat:    128485892 (    128,485,892) <= tx0_bytes /sec
 Ethtool(mlx5p2  ) stat:        31840 (         31,840) <= tx0_nop /sec
 Ethtool(mlx5p2  ) stat:      2141432 (      2,141,432) <= tx0_packets /sec
 Ethtool(mlx5p2  ) stat:          350 (            350) <= tx0_xmit_more /sec
 Ethtool(mlx5p2  ) stat:    128486459 (    128,486,459) <= tx_bytes /sec
 Ethtool(mlx5p2  ) stat:    137052191 (    137,052,191) <= tx_bytes_phy /sec
 Ethtool(mlx5p2  ) stat:      2141441 (      2,141,441) <= tx_csum_partial /sec
 Ethtool(mlx5p2  ) stat:      2141441 (      2,141,441) <= tx_packets /sec
 Ethtool(mlx5p2  ) stat:      2141441 (      2,141,441) <= tx_packets_phy /sec
 Ethtool(mlx5p2  ) stat:    137051300 (    137,051,300) <= tx_prio1_bytes /sec
 Ethtool(mlx5p2  ) stat:      2141427 (      2,141,427) <= tx_prio1_packets /sec
 Ethtool(mlx5p2  ) stat:          350 (            350) <= tx_xmit_more /sec



>    PerfTop:   76969 irqs/sec  kernel:96.6%  exact: 100.0% [4000Hz cycles:pp],  (all, 48 CPUs)
>---------------------------------------------------------------------------------------------
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

My perf outputs below...

Forcing TX completion to happen on the same CPU, no xmit_more:

# Overhead  CPU  Command     Shared Object     Symbol                         
# ........  ...  ..........  ................. ...............................
#
    12.17%  000  udp_flood   [kernel.vmlinux]  [k] _raw_spin_lock             
     5.03%  000  udp_flood   [mlx5_core]       [k] mlx5e_sq_xmit              
     3.13%  000  udp_flood   [kernel.vmlinux]  [k] __ip_append_data.isra.47   
     2.85%  000  udp_flood   [kernel.vmlinux]  [k] entry_SYSCALL_64           
     2.75%  000  udp_flood   [mlx5_core]       [k] mlx5e_poll_tx_cq           
     2.61%  000  udp_flood   [kernel.vmlinux]  [k] sock_def_write_space       
     2.48%  000  udp_flood   [kernel.vmlinux]  [k] skb_set_owner_w            
     2.25%  000  udp_flood   [kernel.vmlinux]  [k] __alloc_skb                
     2.21%  000  udp_flood   [kernel.vmlinux]  [k] udp_sendmsg                
     2.19%  000  udp_flood   [kernel.vmlinux]  [k] __slab_free                
     2.08%  000  udp_flood   [kernel.vmlinux]  [k] sock_wfree                 
     2.06%  000  udp_flood   [kernel.vmlinux]  [k] __ip_make_skb              
     1.93%  000  udp_flood   [mlx5_core]       [k] mlx5e_get_cqe              
     1.93%  000  udp_flood   libc-2.17.so      [.] __libc_send                
     1.80%  000  udp_flood   [kernel.vmlinux]  [k] entry_SYSCALL_64_fastpath  
     1.64%  000  udp_flood   [kernel.vmlinux]  [k] kfree                      
     1.61%  000  udp_flood   [kernel.vmlinux]  [k] ip_finish_output2          
     1.59%  000  udp_flood   [kernel.vmlinux]  [k] __local_bh_enable_ip       
     1.57%  000  udp_flood   [kernel.vmlinux]  [k] __dev_queue_xmit           
     1.49%  000  udp_flood   [kernel.vmlinux]  [k] __kmalloc_node_track_caller
     1.38%  000  udp_flood   [kernel.vmlinux]  [k] kmem_cache_alloc_node      
     1.30%  000  udp_flood   [kernel.vmlinux]  [k] dst_release                
     1.26%  000  udp_flood   [kernel.vmlinux]  [k] ksize                      
     1.26%  000  udp_flood   [kernel.vmlinux]  [k] sk_dst_check               
     1.22%  000  udp_flood   [kernel.vmlinux]  [k] SYSC_sendto                
     1.22%  000  udp_flood   [kernel.vmlinux]  [k] ip_send_check              


Forcing TX completion to happen on remote CPU, some xmit_more:

# Overhead  CPU  Command      Shared Object     Symbol                        
# ........  ...  ............ ................  ..............................
#
    11.67%  002  udp_flood   [kernel.vmlinux]  [k] _raw_spin_lock             
     7.61%  002  udp_flood   [kernel.vmlinux]  [k] skb_set_owner_w            
     6.15%  002  udp_flood   [mlx5_core]       [k] mlx5e_sq_xmit              
     3.05%  002  udp_flood   [kernel.vmlinux]  [k] entry_SYSCALL_64           
     2.89%  002  udp_flood   [kernel.vmlinux]  [k] __ip_append_data.isra.47   
     2.78%  000  swapper     [mlx5_core]       [k] mlx5e_poll_tx_cq           
     2.65%  002  udp_flood   [kernel.vmlinux]  [k] sk_dst_check               
     2.36%  002  udp_flood   [kernel.vmlinux]  [k] __alloc_skb                
     2.22%  002  udp_flood   [kernel.vmlinux]  [k] ip_finish_output2          
     2.07%  000  swapper     [kernel.vmlinux]  [k] __slab_free                
     2.06%  002  udp_flood   [kernel.vmlinux]  [k] udp_sendmsg                
     1.97%  002  udp_flood   [kernel.vmlinux]  [k] ksize                      
     1.92%  002  udp_flood   [kernel.vmlinux]  [k] entry_SYSCALL_64_fastpath  
     1.82%  002  udp_flood   [kernel.vmlinux]  [k] __ip_make_skb              
     1.79%  002  udp_flood   libc-2.17.so      [.] __libc_send                
     1.62%  002  udp_flood   [kernel.vmlinux]  [k] __kmalloc_node_track_caller
     1.53%  002  udp_flood   [kernel.vmlinux]  [k] __local_bh_enable_ip       
     1.48%  002  udp_flood   [kernel.vmlinux]  [k] sock_alloc_send_pskb       
     1.43%  002  udp_flood   [kernel.vmlinux]  [k] __dev_queue_xmit           
     1.39%  002  udp_flood   [kernel.vmlinux]  [k] ip_send_check              
     1.39%  002  udp_flood   [kernel.vmlinux]  [k] kmem_cache_alloc_node      
     1.37%  002  udp_flood   [kernel.vmlinux]  [k] dst_release                
     1.21%  002  udp_flood   [kernel.vmlinux]  [k] udp_send_skb               
     1.18%  002  udp_flood   [kernel.vmlinux]  [k] __fget_light               
     1.16%  002  udp_flood   [kernel.vmlinux]  [k] kfree                      
     1.15%  000  swapper     [kernel.vmlinux]  [k] sock_wfree                 
     1.14%  002  udp_flood   [kernel.vmlinux]  [k] SYSC_sendto                

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
