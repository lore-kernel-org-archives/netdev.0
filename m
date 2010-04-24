From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sat, 24 Apr 2010 10:10:52 -0400
Message-ID: <1272118252.8918.13.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272014825.7895.7851.camel@edumazet-laptop> <1272060153.8918.8.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-kO4bdsu+mPIKkbJWzVE7"
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:43552 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab0DXOK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 10:10:59 -0400
Received: by qyk9 with SMTP id 9so14668406qyk.1
        for <netdev@vger.kernel.org>; Sat, 24 Apr 2010 07:10:58 -0700 (PDT)
In-Reply-To: <1272060153.8918.8.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kO4bdsu+mPIKkbJWzVE7
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2010-04-23 at 18:02 -0400, jamal wrote:

> Ive done a setup with the last patch from Changli + net-next - I will
> post test results tomorrow AM.

ok, annotated results attached. 

cheers,
jamal

--=-kO4bdsu+mPIKkbJWzVE7
Content-Disposition: attachment; filename="summary-apr23.txt"
Content-Type: text/plain; name="summary-apr23.txt"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

		sink    cpu all     cpuint       cpuapp
nn-standalone 	93.95%   84.5%        99.8%        79.8%
nn-rps          96.41%   85.4%        95.5%        82.5%
nn-cl           97.29%   84.0%        99.9%        79.6%
nn-cl-rps       97.76%   86.5%        96.5%        84.8%

nn-standalone: Basic net-next from Apr23
nn-rps: Basic net-next from Apr23 with rps mask ee and irq affinity to cpu0
nn-cl: Basic net-next from Apr23 + Changli patch
nn-cl-rps: Basic net-next from Apr23 + Changli patch + rps mask ee,irq aff cpu0
sink: the amount of traffic the system was able to sink in.
cpu all: avg % system cpu consumed in test
cpuint: avg %cpu consumed by the cpu where interrupts happened
cpuapp: avg %cpu consumed by a sample cpu which did app processing

Testing was as previously explained..
I repeated each test 4-5 times and took averages..

It seems the non-rps case has improved drammatically since the last 
net-next i tested. The rps case has also improved but the gap between 
rps and non-rps is smaller.
[There are just too many variables for me to pinpoint
to one item as being the contributor. For example sky2 driver may
have become worse (consumes more cycles) but i cant quantify it yet
(i just see sky2_rx_submit showing up higher in profiles than before).
Also call_function_single_interrupt shows up prominently on application
processing CPUs but improved by Changli's changes].
After doing the math, I dont trust my results after applying Changlis patch. 
It seems both the rps and non-rps case have gotten better (and i dont 
see Changlis contribution to non-rps). It also seems that the gap between 
rps and non-rps is non-existent now. In other words, there is no benefit to
using rps (it consumes more cpu for the same throughput). So it is likely 
that i need to repeat these tests; maybe i did something wrong in my setup...

And here are the profiles:
--------------------------

cpu0 always received all the interrupts regardless of the tests.
cpu1, 7 etc were processing apps..
I could not spot much difference between before and after Changli's


I: Test setup : nn-standalone: Basic net-next from Apr23

All cpus

-------------------------------------------------------------------------------
   PerfTop:    3784 irqs/sec  kernel:84.2% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

             3254.00 10.3% sky2_poll                   [sky2]  
             1853.00  5.9% _raw_spin_lock_irqsave      [kernel]
              872.00  2.8% fget                        [kernel]
              870.00  2.8% copy_user_generic_string    [kernel]
              819.00  2.6% _raw_spin_unlock_irqrestore [kernel]
              729.00  2.3% sys_epoll_ctl               [kernel]
              701.00  2.2% datagram_poll               [kernel]
              615.00  2.0% udp_recvmsg                 [kernel]
              602.00  1.9% _raw_spin_lock_bh           [kernel]
              595.00  1.9% system_call                 [kernel]
              592.00  1.9% kmem_cache_free             [kernel]
              574.00  1.8% schedule                    [kernel]
              568.00  1.8% _raw_spin_lock              [kernel]


-------------------------------------------------------------------------------
   PerfTop:    3574 irqs/sec  kernel:85.1% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

             5023.00 10.9% sky2_poll                   [sky2]  
             2762.00  6.0% _raw_spin_lock_irqsave      [kernel]
             1319.00  2.9% copy_user_generic_string    [kernel]
             1306.00  2.8% fget                        [kernel]
             1198.00  2.6% _raw_spin_unlock_irqrestore [kernel]
             1071.00  2.3% datagram_poll               [kernel]
             1061.00  2.3% sys_epoll_ctl               [kernel]
              927.00  2.0% _raw_spin_lock_bh           [kernel]
              917.00  2.0% system_call                 [kernel]
              901.00  1.9% udp_recvmsg                 [kernel]
              895.00  1.9% kmem_cache_free             [kernel]
              819.00  1.8% _raw_spin_lock              [kernel]
              802.00  1.7% schedule                    [kernel]
              774.00  1.7% sys_epoll_wait              [kernel]
              720.00  1.6% kmem_cache_alloc            [kernel]


-------------------------------------------------------------------------------
   PerfTop:    1000 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function               DSO
             _______ _____ ______________________ ________

              751.00 36.1% sky2_poll              [sky2]  
              108.00  5.2% __udp4_lib_lookup      [kernel]
               95.00  4.6% ip_route_input         [kernel]
               83.00  4.0% _raw_spin_lock         [kernel]
               79.00  3.8% _raw_spin_lock_irqsave [kernel]
               77.00  3.7% __netif_receive_skb    [kernel]
               77.00  3.7% __alloc_skb            [kernel]
               66.00  3.2% ip_rcv                 [kernel]
               60.00  2.9% __udp4_lib_rcv         [kernel]
               54.00  2.6% sock_queue_rcv_skb     [kernel]
               45.00  2.2% sky2_rx_submit         [sky2]  
               42.00  2.0% __wake_up_common       [kernel]
               40.00  1.9% __kmalloc              [kernel]
               39.00  1.9% sock_def_readable      [kernel]
               30.00  1.4% ep_poll_callback       [kernel]


-------------------------------------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:99.8% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function               DSO
             _______ _____ ______________________ ________

             3511.00 36.7% sky2_poll              [sky2]  
              519.00  5.4% __udp4_lib_lookup      [kernel]
              431.00  4.5% ip_route_input         [kernel]
              353.00  3.7% _raw_spin_lock_irqsave [kernel]
              351.00  3.7% __alloc_skb            [kernel]
              338.00  3.5% __netif_receive_skb    [kernel]
              337.00  3.5% _raw_spin_lock         [kernel]
              307.00  3.2% ip_rcv                 [kernel]
              264.00  2.8% sky2_rx_submit         [sky2]  
              254.00  2.7% sock_queue_rcv_skb     [kernel]
              246.00  2.6% __udp4_lib_rcv         [kernel]
              206.00  2.2% sock_def_readable      [kernel]
              177.00  1.9% __wake_up_common       [kernel]
              168.00  1.8% __kmalloc              [kernel]


-------------------------------------------------------------------------------
   PerfTop:     908 irqs/sec  kernel:80.0% [1000Hz cycles],  (all, cpu: 1)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

              177.00  6.7% _raw_spin_lock_irqsave      [kernel]
              120.00  4.5% copy_user_generic_string    [kernel]
              110.00  4.2% fget                        [kernel]
              108.00  4.1% datagram_poll               [kernel]
               98.00  3.7% _raw_spin_lock_bh           [kernel]
               91.00  3.4% sys_epoll_ctl               [kernel]
               89.00  3.4% kmem_cache_free             [kernel]
               77.00  2.9% system_call                 [kernel]
               76.00  2.9% schedule                    [kernel]
               76.00  2.9% _raw_spin_unlock_irqrestore [kernel]
               63.00  2.4% fput                        [kernel]
               61.00  2.3% sys_epoll_wait              [kernel]
               61.00  2.3% udp_recvmsg                 [kernel]
               49.00  1.8% process_recv                mcpudp  


-------------------------------------------------------------------------------
   PerfTop:     815 irqs/sec  kernel:79.8% [1000Hz cycles],  (all, cpu: 1)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ _________________

              491.00  8.0% _raw_spin_lock_irqsave      [kernel.kallsyms]
              285.00  4.7% copy_user_generic_string    [kernel.kallsyms]
              252.00  4.1% fget                        [kernel.kallsyms]
              215.00  3.5% datagram_poll               [kernel.kallsyms]
              206.00  3.4% _raw_spin_unlock_irqrestore [kernel.kallsyms]
              204.00  3.3% sys_epoll_ctl               [kernel.kallsyms]
              196.00  3.2% _raw_spin_lock_bh           [kernel.kallsyms]
              184.00  3.0% udp_recvmsg                 [kernel.kallsyms]
              184.00  3.0% kmem_cache_free             [kernel.kallsyms]
              180.00  2.9% system_call                 [kernel.kallsyms]
              168.00  2.7% sys_epoll_wait              [kernel.kallsyms]
              159.00  2.6% schedule                    [kernel.kallsyms]
              144.00  2.4% fput                        [kernel.kallsyms]


II: Test setup 
nn-rps: Basic net-next from Apr23 with rps mask ee and irq affinity to cpu0

-------------------------------------------------------------------------------
   PerfTop:    3558 irqs/sec  kernel:85.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ ________

             3519.00 15.9% sky2_poll                      [sky2]  
              865.00  3.9% _raw_spin_lock_irqsave         [kernel]
              568.00  2.6% _raw_spin_unlock_irqrestore    [kernel]
              526.00  2.4% sky2_intr                      [sky2]  
              493.00  2.2% __netif_receive_skb            [kernel]
              477.00  2.2% _raw_spin_lock                 [kernel]
              470.00  2.1% ip_rcv                         [kernel]
              456.00  2.1% fget                           [kernel]
              447.00  2.0% sys_epoll_ctl                  [kernel]
              420.00  1.9% copy_user_generic_string       [kernel]
              387.00  1.8% ip_route_input                 [kernel]
              359.00  1.6% system_call                    [kernel]
              334.00  1.5% kmem_cache_free                [kernel]
              310.00  1.4% kmem_cache_alloc               [kernel]
              302.00  1.4% call_function_single_interrupt [kernel]


-------------------------------------------------------------------------------
   PerfTop:    3546 irqs/sec  kernel:85.8% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ ________

             6592.00 16.2% sky2_poll                      [sky2]  
             1540.00  3.8% _raw_spin_lock_irqsave         [kernel]
             1014.00  2.5% _raw_spin_unlock_irqrestore    [kernel]
              885.00  2.2% fget                           [kernel]
              881.00  2.2% _raw_spin_lock                 [kernel]
              880.00  2.2% sky2_intr                      [sky2]  
              872.00  2.1% __netif_receive_skb            [kernel]
              858.00  2.1% ip_rcv                         [kernel]
              802.00  2.0% sys_epoll_ctl                  [kernel]
              710.00  1.7% copy_user_generic_string       [kernel]
              696.00  1.7% system_call                    [kernel]
              692.00  1.7% ip_route_input                 [kernel]
              634.00  1.6% schedule                       [kernel]
              618.00  1.5% kmem_cache_free                [kernel]
              605.00  1.5% call_function_single_interrupt [kernel]


cpu0

-------------------------------------------------------------------------------
   PerfTop:     971 irqs/sec  kernel:96.5% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

             4222.00 58.2% sky2_poll                   [sky2]  
              668.00  9.2% sky2_intr                   [sky2]  
              228.00  3.1% __alloc_skb                 [kernel]
              183.00  2.5% get_rps_cpu                 [kernel]
              138.00  1.9% sky2_rx_submit              [sky2]  
              124.00  1.7% enqueue_to_backlog          [kernel]
              119.00  1.6% __kmalloc                   [kernel]
              103.00  1.4% kmem_cache_alloc            [kernel]
               91.00  1.3% _raw_spin_lock              [kernel]
               90.00  1.2% _raw_spin_lock_irqsave      [kernel]
               73.00  1.0% swiotlb_sync_single         [kernel]
               72.00  1.0% irq_entries_start           [kernel]
               55.00  0.8% copy_user_generic_string    [kernel]
               53.00  0.7% _raw_spin_unlock_irqrestore [kernel]
               48.00  0.7% fget                        [kernel]


-------------------------------------------------------------------------------
   PerfTop:     998 irqs/sec  kernel:94.8% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

             6745.00 58.5% sky2_poll                   [sky2]  
              831.00  7.2% sky2_intr                   [sky2]  
              352.00  3.1% __alloc_skb                 [kernel]
              281.00  2.4% get_rps_cpu                 [kernel]
              226.00  2.0% sky2_rx_submit              [sky2]  
              186.00  1.6% __kmalloc                   [kernel]
              181.00  1.6% enqueue_to_backlog          [kernel]
              173.00  1.5% _raw_spin_lock_irqsave      [kernel]
              166.00  1.4% kmem_cache_alloc            [kernel]
              162.00  1.4% _raw_spin_lock              [kernel]
               99.00  0.9% swiotlb_sync_single         [kernel]
               98.00  0.9% irq_entries_start           [kernel]
               94.00  0.8% fget                        [kernel]
               92.00  0.8% _raw_spin_unlock_irqrestore [kernel]
               80.00  0.7% system_call                 [kernel]


cpu1


-------------------------------------------------------------------------------
   PerfTop:     724 irqs/sec  kernel:82.0% [1000Hz cycles],  (all, cpu: 1)
-------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ _________________

              204.00  5.3% _raw_spin_lock_irqsave         [kernel.kallsyms]
              153.00  4.0% _raw_spin_unlock_irqrestore    [kernel.kallsyms]
              147.00  3.8% call_function_single_interrupt [kernel.kallsyms]
              139.00  3.6% __netif_receive_skb            [kernel.kallsyms]
              135.00  3.5% sys_epoll_ctl                  [kernel.kallsyms]
              132.00  3.4% ip_rcv                         [kernel.kallsyms]
              129.00  3.3% fget                           [kernel.kallsyms]
              128.00  3.3% _raw_spin_lock                 [kernel.kallsyms]
              122.00  3.2% system_call                    [kernel.kallsyms]
              118.00  3.1% ip_route_input                 [kernel.kallsyms]
              109.00  2.8% kmem_cache_free                [kernel.kallsyms]
              108.00  2.8% copy_user_generic_string       [kernel.kallsyms]
               90.00  2.3% schedule                       [kernel.kallsyms]
               85.00  2.2% fput                           [kernel.kallsyms]



-------------------------------------------------------------------------------
   PerfTop:     763 irqs/sec  kernel:83.0% [1000Hz cycles],  (all, cpu: 1)
-------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ _________________

              428.00  6.2% _raw_spin_lock_irqsave         [kernel.kallsyms]
              302.00  4.4% _raw_spin_unlock_irqrestore    [kernel.kallsyms]
              269.00  3.9% __netif_receive_skb            [kernel.kallsyms]
              258.00  3.7% call_function_single_interrupt [kernel.kallsyms]
              254.00  3.7% fget                           [kernel.kallsyms]
              238.00  3.4% ip_rcv                         [kernel.kallsyms]
              230.00  3.3% sys_epoll_ctl                  [kernel.kallsyms]
              222.00  3.2% _raw_spin_lock                 [kernel.kallsyms]
              220.00  3.2% ip_route_input                 [kernel.kallsyms]
              197.00  2.9% system_call                    [kernel.kallsyms]
              189.00  2.7% kmem_cache_free                [kernel.kallsyms]
              184.00  2.7% copy_user_generic_string       [kernel.kallsyms]
              144.00  2.1% ep_remove                      [kernel.kallsyms]
              140.00  2.0% schedule                       [kernel.kallsyms]


-------------------------------------------------------------------------------
   PerfTop:     546 irqs/sec  kernel:83.3% [1000Hz cycles],  (all, cpu: 1)
-------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ _________________

              346.00  5.7% _raw_spin_lock_irqsave         [kernel.kallsyms]
              275.00  4.6% _raw_spin_unlock_irqrestore    [kernel.kallsyms]
              238.00  3.9% call_function_single_interrupt [kernel.kallsyms]
              228.00  3.8% fget                           [kernel.kallsyms]
              222.00  3.7% __netif_receive_skb            [kernel.kallsyms]
              219.00  3.6% sys_epoll_ctl                  [kernel.kallsyms]
              209.00  3.5% _raw_spin_lock                 [kernel.kallsyms]
              205.00  3.4% ip_rcv                         [kernel.kallsyms]
              199.00  3.3% ip_route_input                 [kernel.kallsyms]
              173.00  2.9% system_call                    [kernel.kallsyms]
              170.00  2.8% copy_user_generic_string       [kernel.kallsyms]
              167.00  2.8% kmem_cache_free                [kernel.kallsyms]
              127.00  2.1% ep_remove                      [kernel.kallsyms]
              123.00  2.0% dst_release                    [kernel.kalls



III: Test setup 
nn-cl: Basic net-next from Apr23 + Changli patch

-------------------------------------------------------------------------------
   PerfTop:    3789 irqs/sec  kernel:84.1% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ____________________

             3514.00 10.2% sky2_poll                   [sky2]              
             1862.00  5.4% _raw_spin_lock_irqsave      [kernel]            
             1274.00  3.7% system_call                 [kernel]            
              926.00  2.7% fget                        [kernel]            
              872.00  2.5% _raw_spin_unlock_irqrestore [kernel]            
              862.00  2.5% copy_user_generic_string    [kernel]            
              766.00  2.2% sys_epoll_ctl               [kernel]            
              765.00  2.2% datagram_poll               [kernel]            
              671.00  2.0% _raw_spin_lock_bh           [kernel]            
              668.00  1.9% kmem_cache_free             [kernel]            
              602.00  1.8% udp_recvmsg                 [kernel]            
              586.00  1.7% _raw_spin_lock              [kernel]            
              585.00  1.7% vread_tsc                   [kernel].vsyscall_fn



-------------------------------------------------------------------------------
   PerfTop:    3794 irqs/sec  kernel:83.6% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ____________________

             4756.00  9.8% sky2_poll                   [sky2]              
             2742.00  5.7% _raw_spin_lock_irqsave      [kernel]            
             1826.00  3.8% system_call                 [kernel]            
             1285.00  2.7% fget                        [kernel]            
             1284.00  2.7% copy_user_generic_string    [kernel]            
             1235.00  2.6% _raw_spin_unlock_irqrestore [kernel]            
             1096.00  2.3% sys_epoll_ctl               [kernel]            
             1071.00  2.2% datagram_poll               [kernel]            
              954.00  2.0% kmem_cache_free             [kernel]            
              925.00  1.9% _raw_spin_lock_bh           [kernel]            
              888.00  1.8% vread_tsc                   [kernel].vsyscall_fn
              880.00  1.8% udp_recvmsg                 [kernel]            
              793.00  1.6% _raw_spin_lock              [kernel]            
              790.00  1.6% schedule                    [kernel]   

-------------------------------------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:99.9% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function               DSO
             _______ _____ ______________________ ________

              675.00 32.6% sky2_poll              [sky2]  
              116.00  5.6% __udp4_lib_lookup      [kernel]
              111.00  5.4% ip_route_input         [kernel]
               81.00  3.9% _raw_spin_lock_irqsave [kernel]
               81.00  3.9% _raw_spin_lock         [kernel]
               70.00  3.4% __alloc_skb            [kernel]
               67.00  3.2% ip_rcv                 [kernel]
               66.00  3.2% __netif_receive_skb    [kernel]
               61.00  2.9% __udp4_lib_rcv         [kernel]
               57.00  2.8% sock_queue_rcv_skb     [kernel]
               47.00  2.3% sock_def_readable      [kernel]
               42.00  2.0% __kmalloc              [kernel]
               42.00  2.0% __wake_up_common       [kernel]
               38.00  1.8% sky2_rx_submit         [sky2]  

-------------------------------------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function               DSO
             _______ _____ ______________________ ________

             2526.00 32.8% sky2_poll              [sky2]  
              406.00  5.3% ip_route_input         [kernel]
              399.00  5.2% __udp4_lib_lookup      [kernel]
              328.00  4.3% _raw_spin_lock_irqsave [kernel]
              307.00  4.0% _raw_spin_lock         [kernel]
              296.00  3.8% ip_rcv                 [kernel]
              287.00  3.7% __alloc_skb            [kernel]
              272.00  3.5% sock_queue_rcv_skb     [kernel]
              224.00  2.9% __udp4_lib_rcv         [kernel]
              224.00  2.9% __netif_receive_skb    [kernel]
              182.00  2.4% sock_def_readable      [kernel]
              163.00  2.1% __wake_up_common       [kernel]
              140.00  1.8% sky2_rx_submit         [sky2]  

-------------------------------------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function               DSO
             _______ _____ ______________________ ________

             4445.00 33.4% sky2_poll              [sky2]  
              707.00  5.3% __udp4_lib_lookup      [kernel]
              662.00  5.0% ip_route_input         [kernel]
              567.00  4.3% _raw_spin_lock_irqsave [kernel]
              512.00  3.8% __alloc_skb            [kernel]
              506.00  3.8% ip_rcv                 [kernel]
              476.00  3.6% sock_queue_rcv_skb     [kernel]
              473.00  3.6% _raw_spin_lock         [kernel]
              415.00  3.1% __udp4_lib_rcv         [kernel]
              408.00  3.1% __netif_receive_skb    [kernel]
              306.00  2.3% sock_def_readable      [kernel]
              272.00  2.0% __wake_up_common       [kernel]
              260.00  2.0% __kmalloc              [kernel]
              216.00  1.6% _raw_read_lock         [kernel]
              214.00  1.6% sky2_rx_submit         [sky2]  


-------------------------------------------------------------------------------
   PerfTop:     748 irqs/sec  kernel:80.9% [1000Hz cycles],  (all, cpu: 1)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ____________________

              244.00  7.4% _raw_spin_lock_irqsave      [kernel]            
              207.00  6.2% system_call                 [kernel]            
              127.00  3.8% _raw_spin_unlock_irqrestore [kernel]            
              124.00  3.7% copy_user_generic_string    [kernel]            
              122.00  3.7% sys_epoll_ctl               [kernel]            
              120.00  3.6% fget                        [kernel]            
              118.00  3.6% datagram_poll               [kernel]            
               96.00  2.9% schedule                    [kernel]            
               94.00  2.8% _raw_spin_lock_bh           [kernel]            
               86.00  2.6% vread_tsc                   [kernel].vsyscall_fn
               82.00  2.5% udp_recvmsg                 [kernel]            
               76.00  2.3% fput                        [kernel]            
               73.00  2.2% kmem_cache_free             [kernel]            
               67.00  2.0% sys_epoll_wait              [kernel]         

-------------------------------------------------------------------------------
   PerfTop:     625 irqs/sec  kernel:78.6% [1000Hz cycles],  (all, cpu: 1)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ____________________

              488.00  7.5% _raw_spin_lock_irqsave      [kernel]            
              380.00  5.9% system_call                 [kernel]            
              274.00  4.2% copy_user_generic_string    [kernel]            
              252.00  3.9% fget                        [kernel]            
              244.00  3.8% datagram_poll               [kernel]            
              217.00  3.3% _raw_spin_unlock_irqrestore [kernel]            
              211.00  3.3% sys_epoll_ctl               [kernel]            
              186.00  2.9% schedule                    [kernel]            
              185.00  2.9% _raw_spin_lock_bh           [kernel]            
              173.00  2.7% udp_recvmsg                 [kernel]            
              169.00  2.6% vread_tsc                   [kernel].vsyscall_fn
              164.00  2.5% kmem_cache_free             [kernel]            
              143.00  2.2% fput                        [kernel]            
              133.00  2.1% sys_epoll_wait              [kernel]        


IV: Test setup 
nn-cl-rps: Basic net-next from Apr23 + Changli patch + rps mask ee,irq aff

--------------------------------------------------------------------------
   PerfTop:    3043 irqs/sec  kernel:87.5% [1000Hz cycles],  (all, 8 CPUs)
--------------------------------------------------------------------------

             samples  pcnt function                   DSO
             _______ _____ __________________________ ____________________

             2240.00 20.4% sky2_poll                  [sky2]              
              375.00  3.4% _raw_spin_lock_irqsave     [kernel]            
              335.00  3.0% sky2_intr                  [sky2]              
              326.00  3.0% system_call                [kernel]            
              239.00  2.2% _raw_spin_unlock_irqrestor [kernel]            
              224.00  2.0% ip_rcv                     [kernel]            
              201.00  1.8% __netif_receive_skb        [kernel]            
              198.00  1.8% sys_epoll_ctl              [kernel]            
              190.00  1.7% _raw_spin_lock             [kernel]            
              182.00  1.7% fget                       [kernel]            
              169.00  1.5% copy_user_generic_string   [kernel]            
              165.00  1.5% kmem_cache_free            [kernel]            
              149.00  1.4% load_balance               [kernel]            
              146.00  1.3% ip_route_input             [kernel]           


--------------------------------------------------------------------------
   PerfTop:    3210 irqs/sec  kernel:85.8% [1000Hz cycles],  (all, 8 CPUs)
--------------------------------------------------------------------------

             samples  pcnt function                   DSO
             _______ _____ __________________________ ____________________

             6539.00 20.4% sky2_poll                  [sky2]              
             1106.00  3.4% _raw_spin_lock_irqsave     [kernel]            
             1014.00  3.2% sky2_intr                  [sky2]              
              976.00  3.0% system_call                [kernel]            
              684.00  2.1% _raw_spin_unlock_irqrestor [kernel]            
              611.00  1.9% ip_rcv                     [kernel]            
              601.00  1.9% fget                       [kernel]            
              593.00  1.8% _raw_spin_lock             [kernel]            
              592.00  1.8% sys_epoll_ctl              [kernel]            
              574.00  1.8% __netif_receive_skb        [kernel]            
              526.00  1.6% copy_user_generic_string   [kernel]            
              482.00  1.5% kmem_cache_free            [kernel]            
              480.00  1.5% ip_route_input             [kernel]            
              425.00  1.3% vread_tsc                  [kernel].vsyscall_fn
              410.00  1.3% kmem_cache_alloc           [kernel]            


--------------------------------------------------------------------------
   PerfTop:     999 irqs/sec  kernel:97.2% [1000Hz cycles],  (all, cpu: 0)
--------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

             2035.00 60.5% sky2_poll                   [sky2]  
              302.00  9.0% sky2_intr                   [sky2]  
              109.00  3.2% __alloc_skb                 [kernel]
               57.00  1.7% _raw_spin_lock              [kernel]
               57.00  1.7% get_rps_cpu                 [kernel]
               52.00  1.5% __kmalloc                   [kernel]
               51.00  1.5% enqueue_to_backlog          [kernel]
               49.00  1.5% _raw_spin_lock_irqsave      [kernel]
               44.00  1.3% kmem_cache_alloc            [kernel]
               34.00  1.0% sky2_rx_submit              [sky2]  
               33.00  1.0% swiotlb_sync_single         [kernel]
               31.00  0.9% system_call                 [kernel]
               28.00  0.8% irq_entries_start           [kernel]
               22.00  0.7% _raw_spin_unlock_irqrestore [kernel]
               21.00  0.6% sky2_remove                 [sky2]  

--------------------------------------------------------------------------
   PerfTop:    1000 irqs/sec  kernel:96.2% [1000Hz cycles],  (all, cpu: 0)
--------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

             5493.00 60.1% sky2_poll                   [sky2]  
              803.00  8.8% sky2_intr                   [sky2]  
              281.00  3.1% __alloc_skb                 [kernel]
              233.00  2.6% get_rps_cpu                 [kernel]
              136.00  1.5% enqueue_to_backlog          [kernel]
              132.00  1.4% __kmalloc                   [kernel]
              126.00  1.4% _raw_spin_lock              [kernel]
              122.00  1.3% kmem_cache_alloc            [kernel]
              122.00  1.3% _raw_spin_lock_irqsave      [kernel]
              102.00  1.1% swiotlb_sync_single         [kernel]
               88.00  1.0% sky2_rx_submit              [sky2]  
               77.00  0.8% system_call                 [kernel]
               69.00  0.8% irq_entries_start           [kernel]
               55.00  0.6% _raw_spin_unlock_irqrestore [kernel]
               54.00  0.6% copy_user_generic_string    [kernel]

--------------------------------------------------------------------------
   PerfTop:     999 irqs/sec  kernel:97.5% [1000Hz cycles],  (all, cpu: 0)
--------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________

             6699.00 60.1% sky2_poll                   [sky2]  
              988.00  8.9% sky2_intr                   [sky2]  
              327.00  2.9% __alloc_skb                 [kernel]
              261.00  2.3% get_rps_cpu                 [kernel]
              168.00  1.5% __kmalloc                   [kernel]
              161.00  1.4% kmem_cache_alloc            [kernel]
              160.00  1.4% enqueue_to_backlog          [kernel]
              157.00  1.4% _raw_spin_lock              [kernel]
              125.00  1.1% _raw_spin_lock_irqsave      [kernel]
              122.00  1.1% swiotlb_sync_single         [kernel]
              114.00  1.0% sky2_rx_submit              [sky2]  
               96.00  0.9% system_call                 [kernel]
               85.00  0.8% irq_entries_start           [kernel]
               66.00  0.6% sky2_remove                 [sky2]  
               64.00  0.6% _raw_spin_unlock_irqrestore [kernel]

--------------------------------------------------------------------------
   PerfTop:     420 irqs/sec  kernel:84.8% [1000Hz cycles],  (all, cpu: 2)
--------------------------------------------------------------------------

             samples  pcnt function                   DSO
             _______ _____ __________________________ ____________________

              188.00  4.8% _raw_spin_lock_irqsave     [kernel]            
              175.00  4.5% system_call                [kernel]            
              155.00  4.0% _raw_spin_unlock_irqrestor [kernel]            
              143.00  3.7% __netif_receive_skb        [kernel]            
              124.00  3.2% ip_route_input             [kernel]            
              122.00  3.1% fget                       [kernel]            
              118.00  3.0% ip_rcv                     [kernel]            
              115.00  2.9% sys_epoll_ctl              [kernel]            
              107.00  2.7% call_function_single_inter [kernel]            
               98.00  2.5% vread_tsc                  [kernel].vsyscall_fn
               97.00  2.5% _raw_spin_lock             [kernel]            
               89.00  2.3% copy_user_generic_string   [kernel]        

--------------------------------------------------------------------------
   PerfTop:     372 irqs/sec  kernel:87.9% [1000Hz cycles],  (all, cpu: 2)
--------------------------------------------------------------------------

             samples  pcnt function                   DSO
             _______ _____ __________________________ ____________________

              212.00  4.6% _raw_spin_lock_irqsave     [kernel]            
              192.00  4.2% system_call                [kernel]            
              187.00  4.1% __netif_receive_skb        [kernel]            
              184.00  4.0% ip_rcv                     [kernel]            
              174.00  3.8% ip_route_input             [kernel]            
              165.00  3.6% _raw_spin_unlock_irqrestor [kernel]            
              143.00  3.1% call_function_single_inter [kernel]            
              135.00  3.0% fget                       [kernel]            
              133.00  2.9% sys_epoll_ctl              [kernel]            
              122.00  2.7% _raw_spin_lock             [kernel]            
              112.00  2.5% __udp4_lib_lookup          [kernel]            
               99.00  2.2% copy_user_generic_string   [kernel]            
               93.00  2.0% vread_tsc                  [kernel].vsyscall_fn
               90.00  2.0% kmem_cache_free            [kernel]            
               89.00  1.9% ep_remove                  [kernel]        
o
--------------------------------------------------------------------------
   PerfTop:     269 irqs/sec  kernel:85.1% [1000Hz cycles],  (all, cpu: 7)
--------------------------------------------------------------------------

             samples  pcnt function                   DSO
             _______ _____ __________________________ ____________________

               23.00  4.6% _raw_spin_lock_irqsave     [kernel]            
               21.00  4.2% system_call                [kernel]            
               19.00  3.8% _raw_spin_unlock_irqrestor [kernel]            
               17.00  3.4% fget                       [kernel]            
               15.00  3.0% __netif_receive_skb        [kernel]            
               14.00  2.8% dst_release                [kernel]            
               13.00  2.6% call_function_single_inter [kernel]            
               11.00  2.2% kmem_cache_free            [kernel]            
               10.00  2.0% vread_tsc                  [kernel].vsyscall_fn
               10.00  2.0% copy_user_generic_string   [kernel]            
               10.00  2.0% ktime_get                  [kernel]            
               10.00  2.0% ip_route_input             [kernel]            
               10.00  2.0% schedule                   [kernel]            


--------------------------------------------------------------------------
   PerfTop:     253 irqs/sec  kernel:84.6% [1000Hz cycles],  (all, cpu: 7)
--------------------------------------------------------------------------

             samples  pcnt function                   DSO
             _______ _____ __________________________ ____________________

              109.00  4.9% system_call                [kernel]            
              104.00  4.6% _raw_spin_lock_irqsave     [kernel]            
               79.00  3.5% ip_rcv                     [kernel]            
               74.00  3.3% _raw_spin_unlock_irqrestor [kernel]            
               71.00  3.2% fget                       [kernel]            
               68.00  3.0% sys_epoll_ctl              [kernel]            
               66.00  2.9% ip_route_input             [kernel]            
               58.00  2.6% call_function_single_inter [kernel]            
               55.00  2.4% _raw_spin_lock             [kernel]            
               54.00  2.4% copy_user_generic_string   [kernel]            
               53.00  2.4% __netif_receive_skb        [kernel]            
               51.00  2.3% schedule                   [kernel]            
               51.00  2.3% kmem_cache_free            [kernel]            
               43.00  1.9% vread_tsc                  [kernel].vsyscall_fn
               38.00  1.7% __udp4_lib_lookup          [kernel]  

--------------------------------------------------------------------------
   PerfTop:     236 irqs/sec  kernel:84.3% [1000Hz cycles],  (all, cpu: 7)
--------------------------------------------------------------------------

             samples  pcnt function                   DSO
             _______ _____ __________________________ ____________________

              131.00  4.9% _raw_spin_lock_irqsave     [kernel]            
              128.00  4.8% system_call                [kernel]            
              101.00  3.8% _raw_spin_unlock_irqrestor [kernel]            
               89.00  3.3% fget                       [kernel]            
               85.00  3.2% sys_epoll_ctl              [kernel]            
               81.00  3.0% ip_rcv                     [kernel]            
               76.00  2.8% ip_route_input             [kernel]            
               66.00  2.5% call_function_single_inter [kernel]            
               65.00  2.4% _raw_spin_lock             [kernel]            
               65.00  2.4% kmem_cache_free            [kernel]            
               64.00  2.4% copy_user_generic_string   [kernel]            
               57.00  2.1% __netif_receive_skb        [kernel]            
               47.00  1.8% schedule                   [kernel]            
               45.00  1.7% vread_tsc                  [kernel].vsyscall_fn


--------------------------------------------------------------------------
   PerfTop:     478 irqs/sec  kernel:82.2% [1000Hz cycles],  (all, cpu: 2)
--------------------------------------------------------------------------

             samples  pcnt function                   DSO
             _______ _____ __________________________ ____________________

              319.00  5.2% _raw_spin_lock_irqsave     [kernel]            
              289.00  4.7% system_call                [kernel]            
              246.00  4.0% _raw_spin_unlock_irqrestor [kernel]            
              199.00  3.2% ip_route_input             [kernel]            
              198.00  3.2% __netif_receive_skb        [kernel]            
              197.00  3.2% sys_epoll_ctl              [kernel]            
              183.00  3.0% ip_rcv                     [kernel]            
              182.00  2.9% fget                       [kernel]            
              166.00  2.7% call_function_single_inter [kernel]            
              157.00  2.5% copy_user_generic_string   [kernel]            
              149.00  2.4% kmem_cache_free            [kernel]            
              146.00  2.4% vread_tsc                  [kernel].vsyscall_fn
              133.00  2.1% _raw_spin_lock             [kernel]            
              118.00  1.9% schedule                   [kernel]            
              112.00  1.8% __udp4_lib_lookup          [kernel]            



--------------------------------------------------------------------------
   PerfTop:     535 irqs/sec  kernel:83.0% [1000Hz cycles],  (all, cpu: 2)
--------------------------------------------------------------------------

             samples  pcnt function                   DSO
             _______ _____ __________________________ ____________________

              345.00  5.2% _raw_spin_lock_irqsave     [kernel]            
              291.00  4.4% system_call                [kernel]            
              255.00  3.9% _raw_spin_unlock_irqrestor [kernel]            
              218.00  3.3% fget                       [kernel]            
              201.00  3.0% ip_route_input             [kernel]            
              193.00  2.9% __netif_receive_skb        [kernel]            
              193.00  2.9% sys_epoll_ctl              [kernel]            
              180.00  2.7% ip_rcv                     [kernel]            
              173.00  2.6% call_function_single_inter [kernel]            
              163.00  2.5% copy_user_generic_string   [kernel]            
              152.00  2.3% kmem_cache_free            [kernel]            
              151.00  2.3% vread_tsc                  [kernel].vsyscall_fn
              142.00  2.1% _raw_spin_lock             [kernel]            
              131.00  2.0% schedule                   [kernel]            



--=-kO4bdsu+mPIKkbJWzVE7--

