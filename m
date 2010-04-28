From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Wed, 28 Apr 2010 19:44:53 -0400
Message-ID: <1272498293.4258.121.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272018366.7895.7930.camel@edumazet-laptop>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-T/V2GaqOd7NUGoVTMQ1h"
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:56698 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab0D1XpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 19:45:17 -0400
Received: by qyk9 with SMTP id 9so22097224qyk.1
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 16:45:16 -0700 (PDT)
In-Reply-To: <1272463605.2267.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-T/V2GaqOd7NUGoVTMQ1h
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2010-04-28 at 16:06 +0200, Eric Dumazet wrote:

> Here it is ;)

Sorry - things got a little hectic with TheMan.

I am afraid i dont have good news.
Actually, I should say i dont have good news in regards to rps.
For my sample app, two things seem to be happening:
a) The overall performance has gotten better for both rps
and non-rps.
b) non-rps is now performing relatively better

This is just what i see in net-next not related to your patch.
It seems the kernels i tested prior to April 23 showed rps better.
The one i tested on Apr23 showed rps being about the same as non-rps.
As i stated in my last result posting, I thought i didnt test properly
but i did again today and saw the same thing. And now non-rps is
_consistently_ better.
So some regression is going on...

Your patch has improved the performance of rps relative to what is in
net-next very lightly; but it has also improved the performance of
non-rps;->
My traces look different for the app cpu than yours - likely because of
the apps being different.

At the moment i dont have time to dig deeper into code, but i could
test as cycles show up.

I am attaching the profile traces and results.

cheers,
jamal

--=-T/V2GaqOd7NUGoVTMQ1h
Content-Disposition: attachment; filename="sum-apr23and28.txt"
Content-Type: text/plain; name="sum-apr23and28.txt"; charset="UTF-8"
Content-Transfer-Encoding: 7bit


April 23 net-next

kernel           sink    cpu all     cpuint       cpuapp
---------------------------------------------------------
nn              93.95%   84.5%        99.8%        79.8%
nn-rps          96.41%   85.4%        95.5%        82.5%
nn-cl           97.29%   84.0%        99.9%        79.6%
nn-cl-rps       97.76%   86.5%        96.5%        84.8%

nn: Basic net-next from Apr23
nn-rps: Basic net-next from Apr23 with rps mask ee and irq affinity to cpu0
nn-cl: Basic net-next from Apr23 + Changli patch
nn-cl-rps: Basic net-next from Apr23 + Changli patch + rps mask ee,irq aff cpu0
sink: the amount of traffic the system was able to sink in.
cpu all: avg % system cpu consumed in test
cpuint: avg %cpu consumed by the cpu where interrupts happened
cpuapp: avg %cpu consumed by a sample cpu which did app processing

Now repeat with Erics changes and kernel from Apr-28

kernel         sink      cpu all     cpuint       cpuapp
---------------------------------------------------------
nn2              98.78%   83.6%        100.0%       82.8%
nn2-rps          94.43%   84.2%        98.1%        82.0%
nn2-ed           98.74%   83.2%        99.9%        81.6%
nn2-ed-rps       95.15%   84.5%        97.3%        82.1%


nn2: Basic net-next from Apr28
nn2-rps: Basic net-next from Apr23 with rps mask ee and irq affinity to cpu0
nn2-ed: Basic net-next from Apr23 + Eric patch
nn2-ed-rps: Basic net-next from Apr23 + Eric patch + rps mask ee,irq aff cpu0

--=-T/V2GaqOd7NUGoVTMQ1h
Content-Disposition: attachment; filename="nn-apr28-summary.txt"
Content-Type: text/plain; name="nn-apr28-summary.txt"; charset="UTF-8"
Content-Transfer-Encoding: 7bit


I: net-next

Average udp sink: 98.78%

--------------------------------------------------------------------------------------------------
   PerfTop:    3632 irqs/sec  kernel:83.7% [1000Hz cycles],  (all, 8 CPUs)
--------------------------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ____________________

             2738.00  9.8% sky2_poll                   [sky2]              
             1543.00  5.5% _raw_spin_lock_irqsave      [kernel]            
             1019.00  3.7% system_call                 [kernel]            
              740.00  2.7% copy_user_generic_string    [kernel]            
              687.00  2.5% fget                        [kernel]            
              640.00  2.3% _raw_spin_unlock_irqrestore [kernel]            
              634.00  2.3% sys_epoll_ctl               [kernel]            
              613.00  2.2% datagram_poll               [kernel]            
              553.00  2.0% _raw_spin_lock_bh           [kernel]            
              530.00  1.9% kmem_cache_free             [kernel]            
              522.00  1.9% schedule                    [kernel]            
              487.00  1.7% vread_tsc                   [kernel].vsyscall_fn
              467.00  1.7% _raw_spin_lock              [kernel]            
              432.00  1.5% udp_recvmsg                 [kernel]            
              426.00  1.5% kmem_cache_alloc            [kernel]            
              418.00  1.5% __udp4_lib_lookup           [kernel]            
              417.00  1.5% sys_epoll_wait              [kernel]            
              376.00  1.3% fput                        [kernel]            
              361.00  1.3% ip_route_input              [kernel]            
              344.00  1.2% local_bh_enable_ip          [kernel]            
              326.00  1.2% ip_rcv                      [kernel]            
              321.00  1.2% first_packet_length         [kernel]            
              307.00  1.1% ep_remove                   [kernel]            
              303.00  1.1% dst_release                 [kernel]            
              301.00  1.1% skb_copy_datagram_iovec     [kernel]            
              297.00  1.1% mutex_lock                  [kernel]            



--------------------------------------------------------------------------------------------------
   PerfTop:    4018 irqs/sec  kernel:83.3% [1000Hz cycles],  (all, 8 CPUs)
--------------------------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ______________________

             4274.00  9.7% sky2_poll                   [sky2]                
             2473.00  5.6% _raw_spin_lock_irqsave      [kernel]              
             1585.00  3.6% system_call                 [kernel]              
             1179.00  2.7% copy_user_generic_string    [kernel]              
             1089.00  2.5% fget                        [kernel]              
             1019.00  2.3% _raw_spin_unlock_irqrestore [kernel]              
             1011.00  2.3% sys_epoll_ctl               [kernel]              
              965.00  2.2% datagram_poll               [kernel]              
              902.00  2.0% kmem_cache_free             [kernel]              
              841.00  1.9% _raw_spin_lock_bh           [kernel]              
              837.00  1.9% schedule                    [kernel]              
              735.00  1.7% vread_tsc                   [kernel].vsyscall_fn  
              730.00  1.7% udp_recvmsg                 [kernel]              
              729.00  1.7% _raw_spin_lock              [kernel]              
              678.00  1.5% kmem_cache_alloc            [kernel]              
              651.00  1.5% sys_epoll_wait              [kernel]              
              635.00  1.4% __udp4_lib_lookup           [kernel]              
              595.00  1.3% fput                        [kernel]              
              568.00  1.3% local_bh_enable_ip          [kernel]              
              562.00  1.3% ip_route_input              [kernel]              
              516.00  1.2% dst_release                 [kernel]              
              502.00  1.1% ep_remove                   [kernel]              
              485.00  1.1% skb_copy_datagram_iovec     [kernel]              
              484.00  1.1% first_packet_length         [kernel]              
              476.00  1.1% ip_rcv                      [kernel]              
              470.00  1.1% __alloc_skb                 [kernel]              
              459.00  1.0% epoll_ctl                   /lib/libc-2.7.so      
              458.00  1.0% mutex_lock                  [kernel]              


--------------------------------------------------------------------------------------------------
   PerfTop:    1000 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu: 0)
--------------------------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

             3534.00 34.7% sky2_poll                   [sky2]  
              545.00  5.3% __udp4_lib_lookup           [kernel]
              537.00  5.3% ip_route_input              [kernel]
              427.00  4.2% _raw_spin_lock_irqsave      [kernel]
              401.00  3.9% __alloc_skb                 [kernel]
              360.00  3.5% ip_rcv                      [kernel]
              332.00  3.3% _raw_spin_lock              [kernel]
              292.00  2.9% sock_queue_rcv_skb          [kernel]
              291.00  2.9% __udp4_lib_rcv              [kernel]
              273.00  2.7% sock_def_readable           [kernel]
              269.00  2.6% __netif_receive_skb         [kernel]
              209.00  2.1% __wake_up_common            [kernel]
              196.00  1.9% __kmalloc                   [kernel]
              164.00  1.6% _raw_read_lock              [kernel]
              157.00  1.5% kmem_cache_alloc            [kernel]
              157.00  1.5% ep_poll_callback            [kernel]
              133.00  1.3% resched_task                [kernel]
              128.00  1.3% task_rq_lock                [kernel]
              120.00  1.2% swiotlb_sync_single         [kernel]
              120.00  1.2% sky2_rx_submit              [sky2]  
              117.00  1.1% udp_queue_rcv_skb           [kernel]
              108.00  1.1% ip_local_deliver            [kernel]
              104.00  1.0% try_to_wake_up              [kernel]
              102.00  1.0% _raw_spin_unlock_irqrestore [kernel]
               98.00  1.0% select_task_rq_fair         [kernel]



--------------------------------------------------------------------------------------------------
   PerfTop:    1000 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu: 0)
--------------------------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

             4601.00 34.0% sky2_poll                   [sky2]  
              732.00  5.4% __udp4_lib_lookup           [kernel]
              724.00  5.3% ip_route_input              [kernel]
              527.00  3.9% _raw_spin_lock_irqsave      [kernel]
              520.00  3.8% __alloc_skb                 [kernel]
              483.00  3.6% ip_rcv                      [kernel]
              441.00  3.3% _raw_spin_lock              [kernel]
              401.00  3.0% sock_queue_rcv_skb          [kernel]
              373.00  2.8% __udp4_lib_rcv              [kernel]
              365.00  2.7% sock_def_readable           [kernel]
              353.00  2.6% __netif_receive_skb         [kernel]
              285.00  2.1% __wake_up_common            [kernel]
              273.00  2.0% __kmalloc                   [kernel]
              230.00  1.7% _raw_read_lock              [kernel]
              208.00  1.5% ep_poll_callback            [kernel]
              199.00  1.5% kmem_cache_alloc            [kernel]
              180.00  1.3% task_rq_lock                [kernel]
              172.00  1.3% sky2_rx_submit              [sky2]  
              171.00  1.3% resched_task                [kernel]
              165.00  1.2% ip_local_deliver            [kernel]
              162.00  1.2% udp_queue_rcv_skb           [kernel]
              158.00  1.2% _raw_spin_unlock_irqrestore [kernel]
              148.00  1.1% select_task_rq_fair         [kernel]
              144.00  1.1% try_to_wake_up              [kernel]
              142.00  1.0% sky2_remove                 [sky2]  
              140.00  1.0% swiotlb_sync_single         [kernel]
               95.00  0.7% cache_alloc_refill          [kernel]
               92.00  0.7% dev_gro_receive             [kernel]
               82.00  0.6% is_swiotlb_buffer           [kernel]


--------------------------------------------------------------------------------------------------
   PerfTop:     622 irqs/sec  kernel:74.9% [1000Hz cycles],  (all, cpu: 2)
--------------------------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ _____________________________________

              113.00  6.5% _raw_spin_lock_irqsave      /lib/modules/2.6.34-rc5/build/vmlinux
              105.00  6.0% system_call                 /lib/modules/2.6.34-rc5/build/vmlinux
               69.00  3.9% fget                        /lib/modules/2.6.34-rc5/build/vmlinux
               64.00  3.7% datagram_poll               /lib/modules/2.6.34-rc5/build/vmlinux
               56.00  3.2% copy_user_generic_string    /lib/modules/2.6.34-rc5/build/vmlinux
               55.00  3.1% sys_epoll_ctl               /lib/modules/2.6.34-rc5/build/vmlinux
               53.00  3.0% _raw_spin_unlock_irqrestore /lib/modules/2.6.34-rc5/build/vmlinux
               46.00  2.6% _raw_spin_lock_bh           /lib/modules/2.6.34-rc5/build/vmlinux
               42.00  2.4% kmem_cache_free             /lib/modules/2.6.34-rc5/build/vmlinux
               37.00  2.1% dst_release                 /lib/modules/2.6.34-rc5/build/vmlinux
               37.00  2.1% schedule                    /lib/modules/2.6.34-rc5/build/vmlinux
               35.00  2.0% mutex_lock                  /lib/modules/2.6.34-rc5/build/vmlinux
               35.00  2.0% vread_tsc                   [kernel].vsyscall_fn                 
               35.00  2.0% udp_recvmsg                 /lib/modules/2.6.34-rc5/build/vmlinux
               34.00  1.9% sys_epoll_wait              /lib/modules/2.6.34-rc5/build/vmlinux
               31.00  1.8% local_bh_enable_ip          /lib/modules/2.6.34-rc5/build/vmlinux
               29.00  1.7% ep_remove                   /lib/modules/2.6.34-rc5/build/vmlinux
               28.00  1.6% kmem_cache_alloc            /lib/modules/2.6.34-rc5/build/vmlinux
               27.00  1.5% process_recv                /home/hadi/udp_sink/mcpudp           
               25.00  1.4% mutex_unlock                /lib/modules/2.6.34-rc5/build/vmlinux
               24.00  1.4% ep_send_events_proc         /lib/modules/2.6.34-rc5/build/vmlinux
               24.00  1.4% clock_gettime               /lib/librt-2.7.so                    
               23.00  1.3% fput                        /lib/modules/2.6.34-rc5/build/vmlinux
               23.00  1.3% skb_copy_datagram_iovec     /lib/modules/2.6.34-rc5/build/vmlinux
               20.00  1.1% sock_recv_ts_and_drops      /lib/modules/2.6.34-rc5/build/vmlinux
               20.00  1.1% inet_recvmsg                /lib/modules/2.6.34-rc5/build/vmlinux
               19.00  1.1% epoll_dispatch              /usr/lib/libevent-1.3e.so.1.0.3      
               19.00  1.1% first_packet_length         /lib/modules/2.6.34-rc5/build/vmlinux



--------------------------------------------------------------------------------------------------
   PerfTop:     625 irqs/sec  kernel:83.0% [1000Hz cycles],  (all, cpu: 2)
--------------------------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ _____________________________________

              315.00  6.8% _raw_spin_lock_irqsave      /lib/modules/2.6.34-rc5/build/vmlinux
              232.00  5.0% system_call                 /lib/modules/2.6.34-rc5/build/vmlinux
              175.00  3.8% fget                        /lib/modules/2.6.34-rc5/build/vmlinux
              174.00  3.8% datagram_poll               /lib/modules/2.6.34-rc5/build/vmlinux
              168.00  3.6% sys_epoll_ctl               /lib/modules/2.6.34-rc5/build/vmlinux
              155.00  3.4% copy_user_generic_string    /lib/modules/2.6.34-rc5/build/vmlinux
              144.00  3.1% kmem_cache_free             /lib/modules/2.6.34-rc5/build/vmlinux
              133.00  2.9% _raw_spin_lock_bh           /lib/modules/2.6.34-rc5/build/vmlinux
              126.00  2.7% _raw_spin_unlock_irqrestore /lib/modules/2.6.34-rc5/build/vmlinux
              113.00  2.4% vread_tsc                   [kernel].vsyscall_fn                 
              110.00  2.4% _raw_spin_unlock_bh         /lib/modules/2.6.34-rc5/build/vmlinux
              106.00  2.3% schedule                    /lib/modules/2.6.34-rc5/build/vmlinux
              103.00  2.2% local_bh_enable_ip          /lib/modules/2.6.34-rc5/build/vmlinux
              101.00  2.2% udp_recvmsg                 /lib/modules/2.6.34-rc5/build/vmlinux
               97.00  2.1% sys_epoll_wait              /lib/modules/2.6.34-rc5/build/vmlinux
               84.00  1.8% dst_release                 /lib/modules/2.6.34-rc5/build/vmlinux
               78.00  1.7% fput                        /lib/modules/2.6.34-rc5/build/vmlinux
               75.00  1.6% first_packet_length         /lib/modules/2.6.34-rc5/build/vmlinux
               74.00  1.6% kmem_cache_alloc            /lib/modules/2.6.34-rc5/build/vmlinux
               71.00  1.5% ep_remove                   /lib/modules/2.6.34-rc5/build/vmlinux
               69.00  1.5% epoll_ctl                   /lib/libc-2.7.so                     
               67.00  1.5% mutex_lock                  /lib/modules/2.6.34-rc5/build/vmlinux
               65.00  1.4% sock_recv_ts_and_drops      /lib/modules/2.6.34-rc5/build/vmlinux
               65.00  1.4% inet_recvmsg                /lib/modules/2.6.34-rc5/build/vmlinux
               64.00  1.4% process_recv                /home/hadi/udp_sink/mcpudp           
               62.00  1.3% skb_copy_datagram_iovec     /lib/modules/2.6.34-rc5/build/vmlinux
               60.00  1.3% clock_gettime               /lib/librt-2.7.so                    


--------------------------------------------------------------------------------------------------
   PerfTop:     700 irqs/sec  kernel:84.3% [1000Hz cycles],  (all, cpu: 2)
--------------------------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ _____________________________________

              489.00  6.4% _raw_spin_lock_irqsave      /lib/modules/2.6.34-rc5/build/vmlinux
              376.00  4.9% system_call                 /lib/modules/2.6.34-rc5/build/vmlinux
              308.00  4.0% fget                        /lib/modules/2.6.34-rc5/build/vmlinux
              302.00  3.9% copy_user_generic_string    /lib/modules/2.6.34-rc5/build/vmlinux
              280.00  3.6% sys_epoll_ctl               /lib/modules/2.6.34-rc5/build/vmlinux
              274.00  3.6% datagram_poll               /lib/modules/2.6.34-rc5/build/vmlinux
              249.00  3.2% kmem_cache_free             /lib/modules/2.6.34-rc5/build/vmlinux
              223.00  2.9% _raw_spin_unlock_irqrestore /lib/modules/2.6.34-rc5/build/vmlinux
              221.00  2.9% _raw_spin_unlock_bh         /lib/modules/2.6.34-rc5/build/vmlinux
              221.00  2.9% local_bh_enable_ip          /lib/modules/2.6.34-rc5/build/vmlinux
              208.00  2.7% vread_tsc                   [kernel].vsyscall_fn                 
              200.00  2.6% _raw_spin_lock_bh           /lib/modules/2.6.34-rc5/build/vmlinux
              191.00  2.5% schedule                    /lib/modules/2.6.34-rc5/build/vmlinux
              188.00  2.4% sys_epoll_wait              /lib/modules/2.6.34-rc5/build/vmlinux
              177.00  2.3% udp_recvmsg                 /lib/modules/2.6.34-rc5/build/vmlinux
              141.00  1.8% fput                        /lib/modules/2.6.34-rc5/build/vmlinux
              140.00  1.8% first_packet_length         /lib/modules/2.6.34-rc5/build/vmlinux
              128.00  1.7% kmem_cache_alloc            /lib/modules/2.6.34-rc5/build/vmlinux
              119.00  1.5% dst_release                 /lib/modules/2.6.34-rc5/build/vmlinux
              105.00  1.4% ep_remove                   /lib/modules/2.6.34-rc5/build/vmlinux
              104.00  1.4% epoll_ctl                   /lib/libc-2.7.so                     
              102.00  1.3% skb_copy_datagram_iovec     /lib/modules/2.6.34-rc5/build/vmlinux
              100.00  1.3% mutex_lock                  /lib/modules/2.6.34-rc5/build/vmlinux
               95.00  1.2% mutex_unlock                /lib/modules/2.6.34-rc5/build/vmlinux
               94.00  1.2% sock_recv_ts_and_drops      /lib/modules/2.6.34-rc5/build/vmlinux
               92.00  1.2% ep_send_events_proc         /lib/modules/2.6.34-rc5/build/vmlinux
               92.00  1.2% clock_gettime               /lib/librt-2.7.so                    
               92.00  1.2% __skb_recv_datagram         /lib/modules/2.6.34-rc5/build/vmlinux
               91.00  1.2% process_recv                /home/hadi/udp_sink/mcpudp           
               88.00  1.1% kfree                       /lib/modules/2.6.34-rc5/build/vmlinux
               86.00  1.1% _raw_spin_lock              /lib/modules/2.6.34-rc5/build/vmlinux



II: net-next with rps = ee

94.43%
--------------



--------------------------------------------------------------------------------------------------
   PerfTop:    4328 irqs/sec  kernel:84.0% [1000Hz cycles],  (all, 8 CPUs)
--------------------------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ ______________________

             3908.00 17.1% sky2_poll                      [sky2]                
              694.00  3.0% _raw_spin_lock_irqsave         [kernel]              
              584.00  2.6% sky2_intr                      [sky2]                
              557.00  2.4% system_call                    [kernel]              
              490.00  2.1% _raw_spin_unlock_irqrestore    [kernel]              
              488.00  2.1% fget                           [kernel]              
              425.00  1.9% ip_rcv                         [kernel]              
              405.00  1.8% sys_epoll_ctl                  [kernel]              
              398.00  1.7% __netif_receive_skb            [kernel]              
              375.00  1.6% _raw_spin_lock                 [kernel]              
              365.00  1.6% copy_user_generic_string       [kernel]              
              363.00  1.6% ip_route_input                 [kernel]              
              350.00  1.5% kmem_cache_free                [kernel]              
              346.00  1.5% schedule                       [kernel]              
              319.00  1.4% call_function_single_interrupt [kernel]              
              295.00  1.3% vread_tsc                      [kernel].vsyscall_fn  
              270.00  1.2% __udp4_lib_lookup              [kernel]              
              264.00  1.2% kmem_cache_alloc               [kernel]              
              235.00  1.0% fput                           [kernel]              
              219.00  1.0% datagram_poll                  [kernel]              


--------------------------------------------------------------------------------------------------
   PerfTop:    3791 irqs/sec  kernel:84.4% [1000Hz cycles],  (all, 8 CPUs)
--------------------------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ ______________________

             6274.00 17.2% sky2_poll                      [sky2]                
             1139.00  3.1% _raw_spin_lock_irqsave         [kernel]              
              953.00  2.6% system_call                    [kernel]              
              942.00  2.6% sky2_intr                      [sky2]                
              785.00  2.2% _raw_spin_unlock_irqrestore    [kernel]              
              745.00  2.0% fget                           [kernel]              
              695.00  1.9% ip_rcv                         [kernel]              
              653.00  1.8% sys_epoll_ctl                  [kernel]              
              609.00  1.7% ip_route_input                 [kernel]              
              606.00  1.7% __netif_receive_skb            [kernel]              
              583.00  1.6% _raw_spin_lock                 [kernel]              
              569.00  1.6% kmem_cache_free                [kernel]              
              564.00  1.5% copy_user_generic_string       [kernel]              
              554.00  1.5% schedule                       [kernel]              
              510.00  1.4% call_function_single_interrupt [kernel]              
              488.00  1.3% vread_tsc                      [kernel].vsyscall_fn  
              459.00  1.3% kmem_cache_alloc               [kernel]              
              417.00  1.1% __udp4_lib_lookup              [kernel]              
              387.00  1.1% fput                           [kernel]              
              358.00  1.0% __udp4_lib_rcv                 [kernel]              
              347.00  1.0% event_base_loop                libevent-1.3e.so.1.0.3

-----------------------------------------------------------------------------------------------
   PerfTop:     997 irqs/sec  kernel:98.2% [1000Hz cycles],  (all, cpu: 0)
-----------------------------------------------------------------------------------------------

             samples  pcnt function                            DSO
             _______ _____ ___________________________________ ________

             3926.00 61.0% sky2_poll                           [sky2]  
              671.00 10.4% sky2_intr                           [sky2]  
              192.00  3.0% __alloc_skb                         [kernel]
              126.00  2.0% get_rps_cpu                         [kernel]
              111.00  1.7% __kmalloc                           [kernel]
               97.00  1.5% enqueue_to_backlog                  [kernel]
               95.00  1.5% _raw_spin_lock_irqsave              [kernel]
               93.00  1.4% _raw_spin_lock                      [kernel]
               79.00  1.2% kmem_cache_alloc                    [kernel]
               63.00  1.0% sky2_rx_submit                      [sky2]  

-----------------------------------------------------------------------------------------------
   PerfTop:     980 irqs/sec  kernel:98.0% [1000Hz cycles],  (all, cpu: 0)
-----------------------------------------------------------------------------------------------

             samples  pcnt function                            DSO
             _______ _____ ___________________________________ ____________________

             6945.00 61.4% sky2_poll                           [sky2]              
             1219.00 10.8% sky2_intr                           [sky2]              
              323.00  2.9% __alloc_skb                         [kernel]            
              243.00  2.1% get_rps_cpu                         [kernel]            
              195.00  1.7% __kmalloc                           [kernel]            
              161.00  1.4% _raw_spin_lock_irqsave              [kernel]            
              149.00  1.3% enqueue_to_backlog                  [kernel]            
              139.00  1.2% _raw_spin_lock                      [kernel]            
              136.00  1.2% kmem_cache_alloc                    [kernel]            
              135.00  1.2% irq_entries_start                   [kernel]            
              108.00  1.0% sky2_rx_submit                      [sky2]              


-----------------------------------------------------------------------------------------------
   PerfTop:     458 irqs/sec  kernel:80.8% [1000Hz cycles],  (all, cpu: 2)
-----------------------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ _____________________________________

              130.00  4.7% _raw_spin_lock_irqsave         /lib/modules/2.6.34-rc5/build/vmlinux
              114.00  4.1% system_call                    /lib/modules/2.6.34-rc5/build/vmlinux
               91.00  3.3% ip_rcv                         /lib/modules/2.6.34-rc5/build/vmlinux
               82.00  3.0% _raw_spin_unlock_irqrestore    /lib/modules/2.6.34-rc5/build/vmlinux
               74.00  2.7% call_function_single_interrupt /lib/modules/2.6.34-rc5/build/vmlinux
               74.00  2.7% fget                           /lib/modules/2.6.34-rc5/build/vmlinux
               71.00  2.6% __netif_receive_skb            /lib/modules/2.6.34-rc5/build/vmlinux
               69.00  2.5% ip_route_input                 /lib/modules/2.6.34-rc5/build/vmlinux
               66.00  2.4% schedule                       /lib/modules/2.6.34-rc5/build/vmlinux
               63.00  2.3% kmem_cache_free                /lib/modules/2.6.34-rc5/build/vmlinux
               61.00  2.2% sys_epoll_ctl                  /lib/modules/2.6.34-rc5/build/vmlinux
               61.00  2.2% __udp4_lib_lookup              /lib/modules/2.6.34-rc5/build/vmlinux
               57.00  2.1% copy_user_generic_string       /lib/modules/2.6.34-rc5/build/vmlinux
               49.00  1.8% vread_tsc                      [kernel].vsyscall_fn                 
               49.00  1.8% _raw_spin_lock                 /lib/modules/2.6.34-rc5/build/vmlinux
               47.00  1.7% ep_remove                      /lib/modules/2.6.34-rc5/build/vmlinux
               45.00  1.6% fput                           /lib/modules/2.6.34-rc5/build/vmlinux
               44.00  1.6% sys_epoll_wait                 /lib/modules/2.6.34-rc5/build/vmlinux
               40.00  1.4% kmem_cache_alloc               /lib/modules/2.6.34-rc5/build/vmlinux
               40.00  1.4% local_bh_enable_ip             /lib/modules/2.6.34-rc5/build/vmlinux
               38.00  1.4% sock_recv_ts_and_drops         /lib/modules/2.6.34-rc5/build/vmlinux
               35.00  1.3% process_recv                   /home/hadi/udp_sink/mcpudp           
               34.00  1.2% mutex_unlock                   /lib/modules/2.6.34-rc5/build/vmlinux
               31.00  1.1% _raw_spin_unlock_bh            /lib/modules/2.6.34-rc5/build/vmlinux
               31.00  1.1% event_base_loop                /usr/lib/libevent-1.3e.so.1.0.3      


-----------------------------------------------------------------------------------------------
   PerfTop:     552 irqs/sec  kernel:82.4% [1000Hz cycles],  (all, cpu: 2)
-----------------------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ _____________________________________

              204.00  4.7% _raw_spin_lock_irqsave         /lib/modules/2.6.34-rc5/build/vmlinux
              169.00  3.9% system_call                    /lib/modules/2.6.34-rc5/build/vmlinux
              151.00  3.5% _raw_spin_unlock_irqrestore    /lib/modules/2.6.34-rc5/build/vmlinux
              132.00  3.0% ip_rcv                         /lib/modules/2.6.34-rc5/build/vmlinux
              129.00  3.0% fget                           /lib/modules/2.6.34-rc5/build/vmlinux
              123.00  2.8% __netif_receive_skb            /lib/modules/2.6.34-rc5/build/vmlinux
              115.00  2.6% ip_route_input                 /lib/modules/2.6.34-rc5/build/vmlinux
              112.00  2.6% call_function_single_interrupt /lib/modules/2.6.34-rc5/build/vmlinux
              112.00  2.6% sys_epoll_ctl                  /lib/modules/2.6.34-rc5/build/vmlinux
              103.00  2.4% schedule                       /lib/modules/2.6.34-rc5/build/vmlinux
               94.00  2.2% kmem_cache_free                /lib/modules/2.6.34-rc5/build/vmlinux
               89.00  2.0% copy_user_generic_string       /lib/modules/2.6.34-rc5/build/vmlinux
               86.00  2.0% _raw_spin_lock                 /lib/modules/2.6.34-rc5/build/vmlinux
               83.00  1.9% __udp4_lib_lookup              /lib/modules/2.6.34-rc5/build/vmlinux
               76.00  1.7% vread_tsc                      [kernel].vsyscall_fn                 
               68.00  1.6% ep_remove                      /lib/modules/2.6.34-rc5/build/vmlinux
               67.00  1.5% fput                           /lib/modules/2.6.34-rc5/build/vmlinux
               64.00  1.5% kmem_cache_alloc               /lib/modules/2.6.34-rc5/build/vmlinux
               62.00  1.4% sys_epoll_wait                 /lib/modules/2.6.34-rc5/build/vmlinux
               60.00  1.4% dst_release                    /lib/modules/2.6.34-rc5/build/vmlinux
               60.00  1.4% sock_recv_ts_and_drops         /lib/modules/2.6.34-rc5/build/vmlinux
               56.00  1.3% _raw_spin_lock_bh              /lib/modules/2.6.34-rc5/build/vmlinux
               53.00  1.2% event_base_loop                /usr/lib/libevent-1.3e.so.1.0.3      
               51.00  1.2% datagram_poll                  /lib/modules/2.6.34-rc5/build/vmlinux
               48.00  1.1% epoll_ctl                      /lib/libc-2.7.so                     
               48.00  1.1% kfree                          /lib/modules/2.6.34-rc5/build/vmlinux
               47.00  1.1% _raw_spin_unlock_bh            /lib/modules/2.6.34-rc5/build/vmlinux
               47.00  1.1% mutex_unlock                   /lib/modules/2.6.34-rc5/build/vmlinux
               45.00  1.0% __udp4_lib_rcv                 /lib/modules/2.6.34-rc5/build/vmlinux
               45.00  1.0% tick_nohz_stop_sched_tick      /lib/modules/2.6.34-rc5/build/vmlinux

-----------------------------------------------------------------------------------------------
   PerfTop:     408 irqs/sec  kernel:82.1% [1000Hz cycles],  (all, cpu: 2)
-----------------------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ _____________________________________

              240.00  4.8% _raw_spin_lock_irqsave         /lib/modules/2.6.34-rc5/build/vmlinux
              200.00  4.0% system_call                    /lib/modules/2.6.34-rc5/build/vmlinux
              165.00  3.3% _raw_spin_unlock_irqrestore    /lib/modules/2.6.34-rc5/build/vmlinux
              161.00  3.2% ip_rcv                         /lib/modules/2.6.34-rc5/build/vmlinux
              158.00  3.1% fget                           /lib/modules/2.6.34-rc5/build/vmlinux
              150.00  3.0% sys_epoll_ctl                  /lib/modules/2.6.34-rc5/build/vmlinux
              135.00  2.7% __netif_receive_skb            /lib/modules/2.6.34-rc5/build/vmlinux
              122.00  2.4% ip_route_input                 /lib/modules/2.6.34-rc5/build/vmlinux
              117.00  2.3% call_function_single_interrupt /lib/modules/2.6.34-rc5/build/vmlinux
              114.00  2.3% schedule                       /lib/modules/2.6.34-rc5/build/vmlinux
              110.00  2.2% _raw_spin_lock                 /lib/modules/2.6.34-rc5/build/vmlinux
              108.00  2.1% copy_user_generic_string       /lib/modules/2.6.34-rc5/build/vmlinux
              101.00  2.0% kmem_cache_free                /lib/modules/2.6.34-rc5/build/vmlinux
               94.00  1.9% vread_tsc                      [kernel].vsyscall_fn                 
               90.00  1.8% __udp4_lib_lookup              /lib/modules/2.6.34-rc5/build/vmlinux
               85.00  1.7% fput                           /lib/modules/2.6.34-rc5/build/vmlinux
               78.00  1.5% dst_release                    /lib/modules/2.6.34-rc5/build/vmlinux
               77.00  1.5% ep_remove                      /lib/modules/2.6.34-rc5/build/vmlinux
               75.00  1.5% kmem_cache_alloc               /lib/modules/2.6.34-rc5/build/vmlinux
               74.00  1.5% _raw_spin_lock_bh              /lib/modules/2.6.34-rc5/build/vmlinux
               69.00  1.4% sys_epoll_wait                 /lib/modules/2.6.34-rc5/build/vmlinux
               68.00  1.3% event_base_loop                /usr/lib/libevent-1.3e.so.1.0.3      
               68.00  1.3% sock_recv_ts_and_drops         /lib/modules/2.6.34-rc5/build/vmlinux
               62.00  1.2% _raw_spin_unlock_bh            /lib/modules/2.6.34-rc5/build/vmlinux
               62.00  1.2% datagram_poll                  /lib/modules/2.6.34-rc5/build/vmlinux
               55.00  1.1% epoll_ctl                      /lib/libc-2.7.so                     
               53.00  1.1% local_bh_enable_ip             /lib/modules/2.6.34-rc5/build/vmlinux
               53.00  1.1% tick_nohz_stop_sched_tick      /lib/modules/2.6.34-rc5/build/vmlinux
               52.00  1.0% mutex_unlock                   /lib/modules/2.6.34-rc5/build/vmlinux

-----------------------------------------------------------------------------------------------
   PerfTop:     440 irqs/sec  kernel:85.0% [1000Hz cycles],  (all, cpu: 2)
-----------------------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ _____________________________________

              226.00  4.6% _raw_spin_lock_irqsave         /lib/modules/2.6.34-rc5/build/vmlinux
              213.00  4.3% system_call                    /lib/modules/2.6.34-rc5/build/vmlinux
              154.00  3.1% _raw_spin_unlock_irqrestore    /lib/modules/2.6.34-rc5/build/vmlinux
              148.00  3.0% ip_rcv                         /lib/modules/2.6.34-rc5/build/vmlinux
              143.00  2.9% fget                           /lib/modules/2.6.34-rc5/build/vmlinux
              143.00  2.9% ip_route_input                 /lib/modules/2.6.34-rc5/build/vmlinux
              140.00  2.8% __netif_receive_skb            /lib/modules/2.6.34-rc5/build/vmlinux
              124.00  2.5% call_function_single_interrupt /lib/modules/2.6.34-rc5/build/vmlinux
              124.00  2.5% sys_epoll_ctl                  /lib/modules/2.6.34-rc5/build/vmlinux
              104.00  2.1% copy_user_generic_string       /lib/modules/2.6.34-rc5/build/vmlinux
              103.00  2.1% vread_tsc                      [kernel].vsyscall_fn                 
              101.00  2.0% schedule                       /lib/modules/2.6.34-rc5/build/vmlinux
              100.00  2.0% kmem_cache_free                /lib/modules/2.6.34-rc5/build/vmlinux
               99.00  2.0% _raw_spin_lock                 /lib/modules/2.6.34-rc5/build/vmlinux
               93.00  1.9% __udp4_lib_lookup              /lib/modules/2.6.34-rc5/build/vmlinux
               80.00  1.6% fput                           /lib/modules/2.6.34-rc5/build/vmlinux
               76.00  1.5% kmem_cache_alloc               /lib/modules/2.6.34-rc5/build/vmlinux
               75.00  1.5% sock_recv_ts_and_drops         /lib/modules/2.6.34-rc5/build/vmlinux
               73.00  1.5% dst_release                    /lib/modules/2.6.34-rc5/build/vmlinux
               70.00  1.4% sys_epoll_wait                 /lib/modules/2.6.34-rc5/build/vmlinux
               69.00  1.4% datagram_poll                  /lib/modules/2.6.34-rc5/build/vmlinux
               65.00  1.3% event_base_loop                /usr/lib/libevent-1.3e.so.1.0.3      
               65.00  1.3% ep_remove                      /lib/modules/2.6.34-rc5/build/vmlinux



III: Kernel compiled with Erics patch, rps mask 00

Avg udp packets sunk: 98.74%

-------------------------------------------------------------------------------
   PerfTop:    4202 irqs/sec  kernel:82.5% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ______________________

             1639.00  9.0% sky2_poll                   [sky2]                
             1051.00  5.8% _raw_spin_lock_irqsave      [kernel]              
              665.00  3.7% system_call                 [kernel]              
              578.00  3.2% fget                        [kernel]              
              476.00  2.6% _raw_spin_unlock_irqrestore [kernel]              
              457.00  2.5% copy_user_generic_string    [kernel]              
              427.00  2.4% sys_epoll_ctl               [kernel]              
              401.00  2.2% datagram_poll               [kernel]              
              391.00  2.2% kmem_cache_free             [kernel]              
              349.00  1.9% schedule                    [kernel]              
              339.00  1.9% vread_tsc                   [kernel].vsyscall_fn  
              323.00  1.8% udp_recvmsg                 [kernel]              
              292.00  1.6% kmem_cache_alloc            [kernel]              
              285.00  1.6% _raw_spin_lock              [kernel]              
              272.00  1.5% _raw_spin_lock_bh           [kernel]              
              268.00  1.5% sys_epoll_wait              [kernel]              
              260.00  1.4% fput                        [kernel]              
              234.00  1.3% ip_route_input              [kernel]              
              221.00  1.2% __udp4_lib_lookup           [kernel]              
              212.00  1.2% dst_release                 [kernel]              
              209.00  1.2% ip_rcv                      [kernel]              
              203.00  1.1% ep_remove                   [kernel]              
              202.00  1.1% first_packet_length         [kernel]              


-------------------------------------------------------------------------------
   PerfTop:    3999 irqs/sec  kernel:82.3% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ______________________

             3452.00  9.3% sky2_poll                   [sky2]                
             2212.00  5.9% _raw_spin_lock_irqsave      [kernel]              
             1350.00  3.6% system_call                 [kernel]              
             1187.00  3.2% fget                        [kernel]              
             1010.00  2.7% copy_user_generic_string    [kernel]              
              965.00  2.6% _raw_spin_unlock_irqrestore [kernel]              
              842.00  2.3% sys_epoll_ctl               [kernel]              
              833.00  2.2% datagram_poll               [kernel]              
              770.00  2.1% kmem_cache_free             [kernel]              
              710.00  1.9% vread_tsc                   [kernel].vsyscall_fn  
              688.00  1.8% schedule                    [kernel]              
              651.00  1.7% udp_recvmsg                 [kernel]              
              603.00  1.6% _raw_spin_lock_bh           [kernel]              
              599.00  1.6% _raw_spin_lock              [kernel]              
              597.00  1.6% sys_epoll_wait              [kernel]              
              594.00  1.6% kmem_cache_alloc            [kernel]              
              553.00  1.5% ip_route_input              [kernel]              
              528.00  1.4% fput                        [kernel]              
              496.00  1.3% __udp4_lib_lookup           [kernel]              
              444.00  1.2% dst_release                 [kernel]              
              433.00  1.2% ip_rcv                      [kernel]              
              408.00  1.1% first_packet_length         [kernel]              

-------------------------------------------------------------------------------
   PerfTop:    3765 irqs/sec  kernel:83.7% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ______________________

             4275.00  9.5% sky2_poll                   [sky2]                
             2684.00  6.0% _raw_spin_lock_irqsave      [kernel]              
             1654.00  3.7% system_call                 [kernel]              
             1447.00  3.2% fget                        [kernel]              
             1223.00  2.7% copy_user_generic_string    [kernel]              
             1146.00  2.5% _raw_spin_unlock_irqrestore [kernel]              
             1036.00  2.3% sys_epoll_ctl               [kernel]              
             1019.00  2.3% datagram_poll               [kernel]              
              974.00  2.2% kmem_cache_free             [kernel]              
              843.00  1.9% vread_tsc                   [kernel].vsyscall_fn  
              799.00  1.8% schedule                    [kernel]              
              761.00  1.7% udp_recvmsg                 [kernel]              
              736.00  1.6% kmem_cache_alloc            [kernel]              
              719.00  1.6% _raw_spin_lock_bh           [kernel]              
              716.00  1.6% _raw_spin_lock              [kernel]              
              696.00  1.5% sys_epoll_wait              [kernel]              
              680.00  1.5% ip_route_input              [kernel]              
              657.00  1.5% fput                        [kernel]              
              613.00  1.4% __udp4_lib_lookup           [kernel]              
              552.00  1.2% dst_release                 [kernel]              
              507.00  1.1% ip_rcv                      [kernel]            


-------------------------------------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:99.9% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

              669.00 32.2% sky2_poll                   [sky2]  
              128.00  6.2% ip_route_input              [kernel]
              106.00  5.1% ip_rcv                      [kernel]
              105.00  5.1% __udp4_lib_lookup           [kernel]
               86.00  4.1% _raw_spin_lock              [kernel]
               85.00  4.1% _raw_spin_lock_irqsave      [kernel]
               82.00  3.9% __alloc_skb                 [kernel]
               78.00  3.8% sock_queue_rcv_skb          [kernel]
               57.00  2.7% __netif_receive_skb         [kernel]
               53.00  2.6% __wake_up_common            [kernel]
               47.00  2.3% __udp4_lib_rcv              [kernel]
               42.00  2.0% sock_def_readable           [kernel]
               37.00  1.8% kmem_cache_alloc            [kernel]
               34.00  1.6% ep_poll_callback            [kernel]
               34.00  1.6% __kmalloc                   [kernel]
               34.00  1.6% select_task_rq_fair         [kernel]
               30.00  1.4% _raw_read_lock              [kernel]
               27.00  1.3% _raw_spin_unlock_irqrestore [kernel]
               24.00  1.2% sky2_rx_submit              [sky2]  
               22.00  1.1% udp_queue_rcv_skb           [kernel]
               21.00  1.0% try_to_wake_up              [kernel]


-------------------------------------------------------------------------------
   PerfTop:    1000 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

             3061.00 31.9% sky2_poll                   [sky2]  
              529.00  5.5% ip_route_input              [kernel]
              518.00  5.4% __udp4_lib_lookup           [kernel]
              424.00  4.4% ip_rcv                      [kernel]
              390.00  4.1% _raw_spin_lock_irqsave      [kernel]
              389.00  4.1% __alloc_skb                 [kernel]
              365.00  3.8% _raw_spin_lock              [kernel]
              326.00  3.4% sock_queue_rcv_skb          [kernel]
              297.00  3.1% __netif_receive_skb         [kernel]
              273.00  2.8% __udp4_lib_rcv              [kernel]
              223.00  2.3% sock_def_readable           [kernel]
              205.00  2.1% __wake_up_common            [kernel]
              181.00  1.9% __kmalloc                   [kernel]
              151.00  1.6% kmem_cache_alloc            [kernel]
              147.00  1.5% _raw_read_lock              [kernel]
              143.00  1.5% ep_poll_callback            [kernel]
              136.00  1.4% sky2_rx_submit              [sky2]  
              123.00  1.3% task_rq_lock                [kernel]
              118.00  1.2% _raw_spin_unlock_irqrestore [kernel]
              114.00  1.2% select_task_rq_fair         [kernel]
              104.00  1.1% resched_task                [kernel]
              104.00  1.1% sky2_remove                 [sky2]  
              102.00  1.1% udp_queue_rcv_skb           [kernel]


-------------------------------------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

             3898.00 31.0% sky2_poll                   [sky2]  
              715.00  5.7% ip_route_input              [kernel]
              651.00  5.2% __udp4_lib_lookup           [kernel]
              576.00  4.6% ip_rcv                      [kernel]
              534.00  4.2% __alloc_skb                 [kernel]
              518.00  4.1% _raw_spin_lock_irqsave      [kernel]
              441.00  3.5% sock_queue_rcv_skb          [kernel]
              439.00  3.5% _raw_spin_lock              [kernel]
              396.00  3.1% __netif_receive_skb         [kernel]
              351.00  2.8% __udp4_lib_rcv              [kernel]
              300.00  2.4% sock_def_readable           [kernel]
              264.00  2.1% __wake_up_common            [kernel]
              260.00  2.1% __kmalloc                   [kernel]
              198.00  1.6% kmem_cache_alloc            [kernel]
              193.00  1.5% ep_poll_callback            [kernel]
              192.00  1.5% _raw_read_lock              [kernel]
              168.00  1.3% sky2_rx_submit              [sky2]  
              167.00  1.3% task_rq_lock                [kernel]
              153.00  1.2% udp_queue_rcv_skb           [kernel]
              149.00  1.2% _raw_spin_unlock_irqrestore [kernel]
              147.00  1.2% ip_local_deliver            [kernel]
              144.00  1.1% resched_task                [kernel]
              137.00  1.1% sky2_remove                 [sky2]  


-------------------------------------------------------------------------------
   PerfTop:     663 irqs/sec  kernel:81.9% [1000Hz cycles],  (all, cpu: 2)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ____________________

              129.00  7.0% _raw_spin_lock_irqsave      [kernel]            
               84.00  4.5% fget                        [kernel]            
               83.00  4.5% system_call                 [kernel]            
               82.00  4.4% copy_user_generic_string    [kernel]            
               67.00  3.6% _raw_spin_unlock_irqrestore [kernel]            
               63.00  3.4% datagram_poll               [kernel]            
               57.00  3.1% udp_recvmsg                 [kernel]            
               55.00  3.0% sys_epoll_ctl               [kernel]            
               55.00  3.0% vread_tsc                   [kernel].vsyscall_fn
               43.00  2.3% sys_epoll_wait              [kernel]            
               43.00  2.3% _raw_spin_lock_bh           [kernel]            
               41.00  2.2% first_packet_length         [kernel]            
               40.00  2.2% dst_release                 [kernel]            
               37.00  2.0% fput                        [kernel]            
               37.00  2.0% kmem_cache_free             [kernel]            
               36.00  1.9% mutex_unlock                [kernel]            
               35.00  1.9% schedule                    [kernel]            
               34.00  1.8% skb_copy_datagram_iovec     [kernel]            
               34.00  1.8% ep_remove                   [kernel]            
               29.00  1.6% mutex_lock                  [kernel]            
               29.00  1.6% _raw_spin_lock              [kernel]            
               28.00  1.5% __skb_recv_datagram         [kernel]            
               25.00  1.4% epoll_ctl                   /lib/libc-2.7.so    
               25.00  1.4% tick_nohz_stop_sched_tick   [kernel]            


-------------------------------------------------------------------------------
   PerfTop:     629 irqs/sec  kernel:81.1% [1000Hz cycles],  (all, cpu: 2)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ______________________

              351.00  7.9% _raw_spin_lock_irqsave      [kernel]              
              248.00  5.6% system_call                 [kernel]              
              219.00  5.0% fget                        [kernel]              
              194.00  4.4% copy_user_generic_string    [kernel]              
              184.00  4.2% datagram_poll               [kernel]              
              162.00  3.7% sys_epoll_ctl               [kernel]              
              159.00  3.6% _raw_spin_unlock_irqrestore [kernel]              
              129.00  2.9% udp_recvmsg                 [kernel]              
              129.00  2.9% kmem_cache_free             [kernel]              
              123.00  2.8% vread_tsc                   [kernel].vsyscall_fn  
              108.00  2.4% schedule                    [kernel]              
              107.00  2.4% _raw_spin_lock_bh           [kernel]              
              104.00  2.4% sys_epoll_wait              [kernel]              
              100.00  2.3% fput                        [kernel]              
               94.00  2.1% dst_release                 [kernel]              
               78.00  1.8% first_packet_length         [kernel]              
               73.00  1.7% ep_remove                   [kernel]              
               69.00  1.6% epoll_ctl                   /lib/libc-2.7.so      
               66.00  1.5% skb_copy_datagram_iovec     [kernel]              
               66.00  1.5% mutex_unlock                [kernel]              
               64.00  1.4% __skb_recv_datagram         [kernel]              
               64.00  1.4% mutex_lock                  [kernel]              
               57.00  1.3% sock_recv_ts_and_drops      [kernel]              
               51.00  1.2% kmem_cache_alloc            [kernel]              
               49.00  1.1% ep_send_events_proc         [kernel]              

-------------------------------------------------------------------------------
   PerfTop:     457 irqs/sec  kernel:72.0% [1000Hz cycles],  (all, cpu: 2)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ______________________

              411.00  7.8% _raw_spin_lock_irqsave      [kernel]              
              280.00  5.3% system_call                 [kernel]              
              269.00  5.1% fget                        [kernel]              
              239.00  4.5% copy_user_generic_string    [kernel]              
              232.00  4.4% datagram_poll               [kernel]              
              175.00  3.3% _raw_spin_unlock_irqrestore [kernel]              
              170.00  3.2% sys_epoll_ctl               [kernel]              
              169.00  3.2% kmem_cache_free             [kernel]              
              149.00  2.8% udp_recvmsg                 [kernel]              
              144.00  2.7% vread_tsc                   [kernel].vsyscall_fn  
              129.00  2.4% sys_epoll_wait              [kernel]              
              128.00  2.4% _raw_spin_lock_bh           [kernel]              
              115.00  2.2% fput                        [kernel]              
              112.00  2.1% schedule                    [kernel]              
              108.00  2.0% dst_release                 [kernel]              
               88.00  1.7% first_packet_length         [kernel]              
               86.00  1.6% ep_remove                   [kernel]              
               83.00  1.6% mutex_lock                  [kernel]              
               79.00  1.5% skb_copy_datagram_iovec     [kernel]              
               76.00  1.4% mutex_unlock                [kernel]              
               75.00  1.4% epoll_ctl                   /lib/libc-2.7.so      
               73.00  1.4% sock_recv_ts_and_drops      [kernel]              
               67.00  1.3% __skb_recv_datagram         [kernel]              
               65.00  1.2% tick_nohz_stop_sched_tick   [kernel]              


Interesting stuff; check cache miss contributions - wow, how low is eth_type_trans..
and yet we keep optimizing that!

-------------------------------------------------------------------------------
   PerfTop:    1021 irqs/sec  kernel:98.8% [1000Hz cache-misses],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                        DSO
             _______ _____ _______________________________ ________

             5271.00 77.8% sky2_poll                       [sky2]  
              706.00 10.4% kmem_cache_alloc                [kernel]
              154.00  2.3% dev_gro_receive                 [kernel]
              149.00  2.2% __napi_gro_receive              [kernel]
              128.00  1.9% napi_gro_receive                [kernel]
              106.00  1.6% __alloc_skb                     [kernel]
               57.00  0.8% eth_type_trans                  [kernel]
               45.00  0.7% skb_gro_reset_offset            [kernel]
               26.00  0.4% drain_array                     [kernel]
               23.00  0.3% perf_session__mmap_read_counter perf    
               10.00  0.1% cache_alloc_refill              [kernel]
                9.00  0.1% __netdev_alloc_skb              [kernel]
                9.00  0.1% event__preprocess_sample        perf    


-------------------------------------------------------------------------------
   PerfTop:     997 irqs/sec  kernel:100.0% [1000Hz cache-misses],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function             DSO
             _______ _____ ____________________ ________

             3019.00 79.4% sky2_poll            [sky2]  
              360.00  9.5% kmem_cache_alloc     [kernel]
               91.00  2.4% dev_gro_receive      [kernel]
               86.00  2.3% __alloc_skb          [kernel]
               83.00  2.2% __napi_gro_receive   [kernel]
               69.00  1.8% napi_gro_receive     [kernel]
               45.00  1.2% eth_type_trans       [kernel]
               25.00  0.7% skb_gro_reset_offset [kernel]
                9.00  0.2% __netdev_alloc_skb   [kernel]
                5.00  0.1% cache_alloc_refill   [kernel]
                5.00  0.1% skb_pull             [kernel]


-------------------------------------------------------------------------------
   PerfTop:     997 irqs/sec  kernel:100.0% [1000Hz cache-misses],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function             DSO
             _______ _____ ____________________ ________

             8887.00 79.8% sky2_poll            [sky2]  
             1138.00 10.2% kmem_cache_alloc     [kernel]
              273.00  2.5% __napi_gro_receive   [kernel]
              246.00  2.2% dev_gro_receive      [kernel]
              189.00  1.7% napi_gro_receive     [kernel]
              159.00  1.4% __alloc_skb          [kernel]
              119.00  1.1% eth_type_trans       [kernel]
               86.00  0.8% skb_gro_reset_offset [kernel]
               13.00  0.1% __netdev_alloc_skb   [kernel]
                8.00  0.1% skb_pull             [kernel]
                7.00  0.1% cache_alloc_refill   [kernel]


Not much going on in other cpus .. i.e hardly anything shows up in
the profile ..

IV: rps with ee and irq affinity to cpu0

Avg udp packets sunk: 95.15%


-------------------------------------------------------------------------------
   PerfTop:    3558 irqs/sec  kernel:84.6% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ______________________

             3096.00 17.1% sky2_poll                     [sky2]                
              645.00  3.6% _raw_spin_lock_irqsave        [kernel]              
              493.00  2.7% system_call                   [kernel]              
              462.00  2.6% sky2_intr                     [sky2]                
              416.00  2.3% _raw_spin_unlock_irqrestore   [kernel]              
              382.00  2.1% fget                          [kernel]              
              361.00  2.0% __netif_receive_skb           [kernel]              
              342.00  1.9% ip_rcv                        [kernel]              
              334.00  1.8% _raw_spin_lock                [kernel]              
              320.00  1.8% sys_epoll_ctl                 [kernel]              
              298.00  1.6% copy_user_generic_string      [kernel]              
              288.00  1.6% call_function_single_interrup [kernel]              
              277.00  1.5% load_balance                  [kernel]              
              271.00  1.5% ip_route_input                [kernel]              
              270.00  1.5% vread_tsc                     [kernel].vsyscall_fn  
              256.00  1.4% kmem_cache_free               [kernel]              
              222.00  1.2% __udp4_lib_lookup             [kernel]              
              222.00  1.2% schedule                      [kernel]              
              194.00  1.1% fput                          [kernel]              
              189.00  1.0% kmem_cache_alloc              [kernel]              
              171.00  0.9% sys_epoll_wait                [kernel]              
              164.00  0.9% ep_remove                     [kernel]          

-------------------------------------------------------------------------------
   PerfTop:    3452 irqs/sec  kernel:84.3% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ______________________

             5033.00 16.2% sky2_poll                     [sky2]                
             1147.00  3.7% _raw_spin_lock_irqsave        [kernel]              
              888.00  2.9% system_call                   [kernel]              
              774.00  2.5% sky2_intr                     [sky2]                
              757.00  2.4% _raw_spin_unlock_irqrestore   [kernel]              
              702.00  2.3% fget                          [kernel]              
              630.00  2.0% __netif_receive_skb           [kernel]              
              609.00  2.0% _raw_spin_lock                [kernel]              
              607.00  2.0% ip_rcv                        [kernel]              
              553.00  1.8% sys_epoll_ctl                 [kernel]              
              514.00  1.7% ip_route_input                [kernel]              
              508.00  1.6% call_function_single_interrup [kernel]              
              504.00  1.6% copy_user_generic_string      [kernel]              
              466.00  1.5% kmem_cache_free               [kernel]              
              452.00  1.5% schedule                      [kernel]              
              450.00  1.4% vread_tsc                     [kernel].vsyscall_fn  
              390.00  1.3% load_balance                  [kernel]              
              377.00  1.2% fput                          [kernel]              
              364.00  1.2% __udp4_lib_lookup             [kernel]              
              329.00  1.1% kmem_cache_alloc              [kernel]              
              314.00  1.0% ep_remove                     [kernel]              
              289.00  0.9% dst_release                   [kernel]              
              276.00  0.9% sys_epoll_wait                [kernel]              
              265.00  0.9% datagram_poll                 [kernel]              

-------------------------------------------------------------------------------
   PerfTop:    3328 irqs/sec  kernel:85.7% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ______________________

             6788.00 17.5% sky2_poll                     [sky2]                
             1413.00  3.6% _raw_spin_lock_irqsave        [kernel]              
             1042.00  2.7% system_call                   [kernel]              
              997.00  2.6% sky2_intr                     [sky2]                
              903.00  2.3% _raw_spin_unlock_irqrestore   [kernel]              
              837.00  2.2% fget                          [kernel]              
              740.00  1.9% _raw_spin_lock                [kernel]              
              725.00  1.9% __netif_receive_skb           [kernel]              
              722.00  1.9% ip_rcv                        [kernel]              
              651.00  1.7% sys_epoll_ctl                 [kernel]              
              609.00  1.6% call_function_single_interrup [kernel]              
              604.00  1.6% ip_route_input                [kernel]              
              601.00  1.5% copy_user_generic_string      [kernel]              
              573.00  1.5% schedule                      [kernel]              
              561.00  1.4% kmem_cache_free               [kernel]              
              538.00  1.4% load_balance                  [kernel]              
              515.00  1.3% vread_tsc                     [kernel].vsyscall_fn  
              480.00  1.2% fput                          [kernel]              
              421.00  1.1% kmem_cache_alloc              [kernel]              
              418.00  1.1% __udp4_lib_lookup             [kernel]              
              377.00  1.0% ep_remove                     [kernel]              
              347.00  0.9% datagram_poll                 [kernel]              
              335.00  0.9% dst_release                   [kernel]              

-------------------------------------------------------------------------------
   PerfTop:    1000 irqs/sec  kernel:96.2% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ______________________

             2109.00 61.3% sky2_poll                     [sky2]                
              366.00 10.6% sky2_intr                     [sky2]                
               84.00  2.4% __alloc_skb                   [kernel]              
               57.00  1.7% _raw_spin_lock_irqsave        [kernel]              
               56.00  1.6% get_rps_cpu                   [kernel]              
               52.00  1.5% __kmalloc                     [kernel]              
               39.00  1.1% irq_entries_start             [kernel]              
               39.00  1.1% enqueue_to_backlog            [kernel]              
               34.00  1.0% kmem_cache_alloc              [kernel]              
               33.00  1.0% default_send_IPI_mask_sequenc [kernel]              
               32.00  0.9% sky2_rx_submit                [sky2]                
               30.00  0.9% swiotlb_sync_single           [kernel]              
               28.00  0.8% _raw_spin_lock                [kernel]              
               23.00  0.7% sky2_remove                   [sky2]                
               22.00  0.6% __smp_call_function_single    [kernel]              
               19.00  0.6% system_call                   [kernel]              
               18.00  0.5% sys_epoll_ctl                 [kernel]              
               18.00  0.5% fget                          [kernel]              
               17.00  0.5% cache_alloc_refill            [kernel]              
               16.00  0.5% copy_user_generic_string      [kernel]              
               16.00  0.5% _raw_spin_unlock_irqrestore   [kernel]              
               15.00  0.4% dev_gro_receive               [kernel]              
               14.00  0.4% net_rx_action                 [kernel]             

-------------------------------------------------------------------------------
   PerfTop:    1000 irqs/sec  kernel:97.9% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function                        DSO
             _______ _____ _______________________________ ____________________

             4479.00 60.9% sky2_poll                       [sky2]              
              849.00 11.5% sky2_intr                       [sky2]              
              163.00  2.2% __alloc_skb                     [kernel]            
              155.00  2.1% get_rps_cpu                     [kernel]            
              121.00  1.6% _raw_spin_lock_irqsave          [kernel]            
               92.00  1.3% __kmalloc                       [kernel]            
               89.00  1.2% _raw_spin_lock                  [kernel]            
               83.00  1.1% enqueue_to_backlog              [kernel]            
               79.00  1.1% irq_entries_start               [kernel]            
               78.00  1.1% kmem_cache_alloc                [kernel]            
               69.00  0.9% sky2_rx_submit                  [sky2]              
               65.00  0.9% swiotlb_sync_single             [kernel]            
               58.00  0.8% default_send_IPI_mask_sequence_ [kernel]            
               50.00  0.7% system_call                     [kernel]            
               45.00  0.6% fget                            [kernel]            
               40.00  0.5% sky2_remove                     [sky2]              
               37.00  0.5% __smp_call_function_single      [kernel]            
               36.00  0.5% datagram_poll                   [kernel]            
               36.00  0.5% _raw_spin_unlock_irqrestore     [kernel]            
               34.00  0.5% cache_alloc_refill              [kernel]            
               31.00  0.4% net_rx_action                   [kernel]            
               28.00  0.4% kmem_cache_free                 [kernel]            
               27.00  0.4% _raw_spin_lock_bh               [kernel]            
               27.00  0.4% copy_user_generic_string        [kernel]            
               25.00  0.3% dev_gro_receive                 [kernel]            


-------------------------------------------------------------------------------
   PerfTop:     980 irqs/sec  kernel:97.3% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function                        DSO
             _______ _____ _______________________________ ____________________

             6544.00 61.6% sky2_poll                       [sky2]              
             1098.00 10.3% sky2_intr                       [sky2]              
              248.00  2.3% __alloc_skb                     [kernel]            
              198.00  1.9% get_rps_cpu                     [kernel]            
              182.00  1.7% _raw_spin_lock_irqsave          [kernel]            
              144.00  1.4% __kmalloc                       [kernel]            
              138.00  1.3% _raw_spin_lock                  [kernel]            
              127.00  1.2% kmem_cache_alloc                [kernel]            
              125.00  1.2% irq_entries_start               [kernel]            
              119.00  1.1% enqueue_to_backlog              [kernel]            
               93.00  0.9% sky2_rx_submit                  [sky2]              
               91.00  0.9% swiotlb_sync_single             [kernel]            
               83.00  0.8% default_send_IPI_mask_sequence_ [kernel]            
               82.00  0.8% system_call                     [kernel]            
               64.00  0.6% sky2_remove                     [sky2]              
               60.00  0.6% fget                            [kernel]            
               58.00  0.5% cache_alloc_refill              [kernel]            
               57.00  0.5% _raw_spin_unlock_irqrestore     [kernel]            
               51.00  0.5% datagram_poll                   [kernel]            
               47.00  0.4% copy_user_generic_string        [kernel]            


-------------------------------------------------------------------------------
   PerfTop:     315 irqs/sec  kernel:81.0% [1000Hz cycles],  (all, cpu: 2)
-------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ______________________

              114.00  4.5% system_call                   [kernel]              
               98.00  3.9% _raw_spin_lock_irqsave        [kernel]              
               89.00  3.5% _raw_spin_unlock_irqrestore   [kernel]              
               89.00  3.5% ip_rcv                        [kernel]              
               83.00  3.3% call_function_single_interrup [kernel]              
               76.00  3.0% __netif_receive_skb           [kernel]              
               67.00  2.6% fget                          [kernel]              
               62.00  2.4% ip_route_input                [kernel]              
               59.00  2.3% vread_tsc                     [kernel].vsyscall_fn  
               54.00  2.1% kmem_cache_free               [kernel]              
               54.00  2.1% sys_epoll_ctl                 [kernel]              
               51.00  2.0% schedule                      [kernel]              
               49.00  1.9% _raw_spin_lock                [kernel]              
               49.00  1.9% __udp4_lib_lookup             [kernel]              
               44.00  1.7% ep_remove                     [kernel]              
               44.00  1.7% copy_user_generic_string      [kernel]              
               41.00  1.6% fput                          [kernel]              
               38.00  1.5% sys_epoll_wait                [kernel]              
               37.00  1.5% tick_nohz_stop_sched_tick     [kernel]              
               36.00  1.4% kmem_cache_alloc              [kernel]              
               34.00  1.3% datagram_poll                 [kernel]              
               33.00  1.3% __udp4_lib_rcv                [kernel]              
               31.00  1.2% process_recv                  mcpudp               

-------------------------------------------------------------------------------
   PerfTop:     292 irqs/sec  kernel:82.9% [1000Hz cycles],  (all, cpu: 2)
-------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ______________________

              154.00  4.7% _raw_spin_lock_irqsave        [kernel]              
              140.00  4.2% system_call                   [kernel]              
              111.00  3.4% ip_rcv                        [kernel]              
              106.00  3.2% _raw_spin_unlock_irqrestore   [kernel]              
               96.00  2.9% call_function_single_interrup [kernel]              
               95.00  2.9% fget                          [kernel]              
               90.00  2.7% __netif_receive_skb           [kernel]              
               89.00  2.7% sys_epoll_ctl                 [kernel]              
               77.00  2.3% copy_user_generic_string      [kernel]              
               77.00  2.3% ip_route_input                [kernel]              
               76.00  2.3% kmem_cache_free               [kernel]              
               74.00  2.2% _raw_spin_lock                [kernel]              
               71.00  2.1% schedule                      [kernel]              
               69.00  2.1% vread_tsc                     [kernel].vsyscall_fn  
               58.00  1.8% __udp4_lib_lookup             [kernel]              
               52.00  1.6% __udp4_lib_rcv                [kernel]              
               51.00  1.5% fput                          [kernel]              
               47.00  1.4% ep_remove                     [kernel]              
               47.00  1.4% event_base_loop               libevent-1.3e.so.1.0.3
               39.00  1.2% process_recv                  mcpudp                
               39.00  1.2% sys_epoll_wait                [kernel]              
               38.00  1.2% udp_recvmsg                   [kernel]              
               38.00  1.2% sock_recv_ts_and_drops        [kernel]              
               37.00  1.1% __switch_to                   [kernel]              

-------------------------------------------------------------------------------
   PerfTop:     290 irqs/sec  kernel:82.1% [1000Hz cycles],  (all, cpu: 2)
-------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ______________________

              175.00  4.7% _raw_spin_lock_irqsave        [kernel]              
              153.00  4.2% system_call                   [kernel]              
              122.00  3.3% ip_rcv                        [kernel]              
              114.00  3.1% _raw_spin_unlock_irqrestore   [kernel]              
              114.00  3.1% fget                          [kernel]              
              105.00  2.8% __netif_receive_skb           [kernel]              
              101.00  2.7% sys_epoll_ctl                 [kernel]              
              100.00  2.7% call_function_single_interrup [kernel]              
               90.00  2.4% copy_user_generic_string      [kernel]              
               84.00  2.3% schedule                      [kernel]              
               76.00  2.1% kmem_cache_free               [kernel]              
               76.00  2.1% _raw_spin_lock                [kernel]              
               72.00  2.0% ip_route_input                [kernel]              
               70.00  1.9% vread_tsc                     [kernel].vsyscall_fn  
               68.00  1.8% __udp4_lib_lookup             [kernel]              
               68.00  1.8% __udp4_lib_rcv                [kernel]              
               57.00  1.5% ep_remove                     [kernel]              
               57.00  1.5% fput                          [kernel]              
               55.00  1.5% kmem_cache_alloc              [kernel]              
               51.00  1.4% process_recv                  mcpudp           




--=-T/V2GaqOd7NUGoVTMQ1h--

