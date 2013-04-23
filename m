From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Tue, 23 Apr 2013 16:19:23 +0200
Message-ID: <1366726763.26911.417.camel@localhost>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <1366373950.26911.134.camel@localhost>
	 <20130419124528.GF27889@order.stressinduktion.org>
	 <1366381742.26911.166.camel@localhost>
	 <20130419194424.GI27889@order.stressinduktion.org>
	 <1366621834.26911.271.camel@localhost>
	 <20130422145431.GA26838@order.stressinduktion.org>
	 <1366652952.26911.334.camel@localhost>
	 <20130423002022.GA28991@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-2NQ8OVnXWoHlpOFajWJM"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755629Ab3DWOTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 10:19:32 -0400
In-Reply-To: <20130423002022.GA28991@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2NQ8OVnXWoHlpOFajWJM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Tue, 2013-04-23 at 02:20 +0200, Hannes Frederic Sowa wrote:
> On Mon, Apr 22, 2013 at 06:30:17PM +0200, Jesper Dangaard Brouer wrote:
> > On Mon, 2013-04-22 at 16:54 +0200, Hannes Frederic Sowa wrote:
> > > On Mon, Apr 22, 2013 at 11:10:34AM +0200, Jesper Dangaard Brouer wrote:
> > [...]
> > > > Besides, after we have implemented per hash bucket locking (in my change
> > > > commit 19952cc4 "net: frag queue per hash bucket locking").
> > > > Then, I don't think it is a big problem that a single hash bucket is
> > > > being "attacked".
> > > 
> > > I don't know, I wouldn't say so. The contention point is now the per
> > > hash bucket lock but it should show the same symptoms as before.
> > 
> > No, the contention point is the LRU list lock, not the hash bucket lock.
> > If you perf record/profile the code, you can easily miss that its the
> > LRU lock, because its inlined.  Try to rerun your tests with noinline
> > e.g.:
> 
> It depends on the test. Last time I checked with my ipv6 torture test I
> had most hits in the inet_frag_find loop (I looked at it after your per
> bucket locks landed in net-next). I think your test setup could provide
> more meaningful numbers. If you fill up the whole fragment cache it is
> plausible that the contention will shift towards the lru lock.

Yes, traffic patterns do affect the results, BUT you have to be really
careful profiling this:

Notice, that inet_frag_find() also indirectly takes the LRU lock, and
the perf tool will blame inet_frag_find().  This is very subtle and
happens with a traffic pattern that want to create new frag queues (e.g.
not found in the hash list).
The problem is that inet_frag_find() calls inet_frag_create() (if q is
not found) which calls inet_frag_intern() which calls
inet_frag_lru_add() taking the LRU lock.  All of these functions gets
inlined by the compiler, thus inet_frag_find() gets the blame.


To avoid pissing people off:
Yes, having a long list in the hash bucket is obviously also contributes
significantly.  Yes, we still should increase the hash bucket size.  I'm
just pointing out be careful about what you actually profile ;-)


Please see below, profiling of current next-next, with "noinline" added
to inet_frag_intern, inet_frag_alloc and inet_frag_create.  Run under
test 20G3F+MQ. I hope you can see my point with the LRU list lock,
please let me know if I have missed something.


--Jesper

Profile of net-next with below diff/patch, output from command:
  perf report -Mintel -C 1 --stdio --call-graph graph,2 

Cut down version (full version attached):
-----------------------------------------
# Overhead      Command      Shared Object                                   Symbol
# ........  ...........  .................  .......................................
#
    70.12%  ksoftirqd/1  [kernel.kallsyms]  [k] _raw_spin_lock                     
            |
            --- _raw_spin_lock
               |          
               |--19.70%-- ip_defrag
               |--17.36%-- inet_frag_kill
               |          |--15.04%-- inet_frag_evictor
               |           --2.32%-- ip_defrag
               |--17.15%-- inet_frag_intern
                --15.52%-- inet_frag_evictor
      
    9.61%      swapper  [kernel.kallsyms]  [k] _raw_spin_lock                     
                |
                --- _raw_spin_lock
                   |          
                   |--2.46%-- inet_frag_kill
                   |--2.44%-- ip_defrag
                   |--2.38%-- inet_frag_evictor
                    --2.28%-- inet_frag_intern 

     1.91%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_frag_find                     

     1.66%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_frag_intern                   

     1.54%  ksoftirqd/1  [kernel.kallsyms]  [k] ip_defrag                          

     1.52%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_frag_kill                     

     1.19%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_frag_evictor                  

     1.05%  ksoftirqd/1  [kernel.kallsyms]  [k] __percpu_counter_add               

     0.77%  ksoftirqd/1  [kernel.kallsyms]  [k] __list_del_entry                   

     0.53%  ksoftirqd/1  [kernel.kallsyms]  [k] _raw_read_lock                     

     0.49%  ksoftirqd/1  [kernel.kallsyms]  [k] ip4_frag_match                     

     0.44%  ksoftirqd/1  [kernel.kallsyms]  [k] __list_add                         

     0.42%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_getpeer                       


"noinline: changes to net-next:
-------------------------------
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index e97d66a..d899bba 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -241,7 +241,7 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 }
 EXPORT_SYMBOL(inet_frag_evictor);
 
-static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
+static noinline struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
                struct inet_frag_queue *qp_in, struct inet_frags *f,
                void *arg)
 {
@@ -289,7 +289,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
        return qp;
 }
 
-static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
+static noinline struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
                struct inet_frags *f, void *arg)
 {
        struct inet_frag_queue *q;
@@ -309,7 +309,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
        return q;
 }
 
-static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
+static noinline struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
                struct inet_frags *f, void *arg)
 {
        struct inet_frag_queue *q;



--=-2NQ8OVnXWoHlpOFajWJM
Content-Disposition: attachment; filename="perf_noinline_call_graph.out"
Content-Type: text/plain; name="perf_noinline_call_graph.out"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

# ========
# captured on: Tue Apr 23 15:46:09 2013
# hostname : dragon
# os release : 3.9.0-rc5-upstream_frag_work07-LRU-per-CPU+
# perf version : 2.6.32-358.2.1.el6.x86_64.debug
# arch : x86_64
# nrcpus online : 24
# nrcpus avail : 24
# cpudesc : Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
# cpuid : GenuineIntel,6,45,7
# total memory : 65951448 kB
# cmdline : /usr/bin/perf record -g -a 
# event : name = cycles, type = 0, config = 0x0, config1 = 0x0, config2 = 0x0, excl_usr = 0, excl_kern = 0, excl_host = 0, excl_guest = 1, precise_ip = 0, id = { 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48 }
# HEADER_CPU_TOPOLOGY info available, use -I to display
# HEADER_NUMA_TOPOLOGY info available, use -I to display
# ========
#
# Samples: 58K of event 'cycles'
# Event count (approx.): 34169718296
#
# Overhead      Command      Shared Object                                   Symbol
# ........  ...........  .................  .......................................
#
    70.12%  ksoftirqd/1  [kernel.kallsyms]  [k] _raw_spin_lock                     
            |
            --- _raw_spin_lock
               |          
               |--19.70%-- ip_defrag
               |          ip_local_deliver
               |          ip_rcv_finish
               |          ip_rcv
               |          __netif_receive_skb_core
               |          __netif_receive_skb
               |          netif_receive_skb
               |          napi_gro_receive
               |          ixgbe_poll
               |          net_rx_action
               |          __do_softirq
               |          |          
               |           --19.67%-- run_ksoftirqd
               |                     smpboot_thread_fn
               |                     kthread
               |                     ret_from_fork
               |          
               |--17.36%-- inet_frag_kill
               |          |          
               |          |--15.04%-- inet_frag_evictor
               |          |          ip_defrag
               |          |          ip_local_deliver
               |          |          ip_rcv_finish
               |          |          ip_rcv
               |          |          __netif_receive_skb_core
               |          |          __netif_receive_skb
               |          |          netif_receive_skb
               |          |          napi_gro_receive
               |          |          ixgbe_poll
               |          |          net_rx_action
               |          |          __do_softirq
               |          |          |          
               |          |           --14.91%-- run_ksoftirqd
               |          |                     smpboot_thread_fn
               |          |                     kthread
               |          |                     ret_from_fork
               |          |          
               |           --2.32%-- ip_defrag
               |                     ip_local_deliver
               |                     ip_rcv_finish
               |                     ip_rcv
               |                     __netif_receive_skb_core
               |                     __netif_receive_skb
               |                     netif_receive_skb
               |                     napi_gro_receive
               |                     ixgbe_poll
               |                     net_rx_action
               |                     __do_softirq
               |                     |          
               |                      --2.32%-- run_ksoftirqd
               |                                smpboot_thread_fn
               |                                kthread
               |                                ret_from_fork
               |          
               |--17.15%-- inet_frag_intern
               |          inet_frag_create
               |          inet_frag_find
               |          ip_defrag
               |          ip_local_deliver
               |          ip_rcv_finish
               |          ip_rcv
               |          __netif_receive_skb_core
               |          __netif_receive_skb
               |          netif_receive_skb
               |          napi_gro_receive
               |          ixgbe_poll
               |          net_rx_action
               |          __do_softirq
               |          |          
               |           --17.13%-- run_ksoftirqd
               |                     smpboot_thread_fn
               |                     kthread
               |                     ret_from_fork
               |          
                --15.52%-- inet_frag_evictor
                          ip_defrag
                          ip_local_deliver
                          ip_rcv_finish
                          ip_rcv
                          __netif_receive_skb_core
                          __netif_receive_skb
                          netif_receive_skb
                          napi_gro_receive
                          ixgbe_poll
                          net_rx_action
                          __do_softirq
                          |          
                           --15.37%-- run_ksoftirqd
                                     smpboot_thread_fn
                                     kthread
                                     ret_from_fork

     9.61%      swapper  [kernel.kallsyms]  [k] _raw_spin_lock                     
                |
                --- _raw_spin_lock
                   |          
                   |--2.46%-- inet_frag_kill
                   |          inet_frag_evictor
                   |          ip_defrag
                   |          ip_local_deliver
                   |          ip_rcv_finish
                   |          ip_rcv
                   |          __netif_receive_skb_core
                   |          __netif_receive_skb
                   |          netif_receive_skb
                   |          napi_gro_receive
                   |          ixgbe_poll
                   |          net_rx_action
                   |          __do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_enter_tk
                   |          cpuidle_enter_state
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          start_secondary
                   |          
                   |--2.44%-- ip_defrag
                   |          ip_local_deliver
                   |          ip_rcv_finish
                   |          ip_rcv
                   |          __netif_receive_skb_core
                   |          __netif_receive_skb
                   |          netif_receive_skb
                   |          napi_gro_receive
                   |          ixgbe_poll
                   |          net_rx_action
                   |          __do_softirq
                   |          irq_exit
                   |          |          
                   |           --2.42%-- do_IRQ
                   |                     common_interrupt
                   |                     |          
                   |                      --2.41%-- cpuidle_enter_tk
                   |                                cpuidle_enter_state
                   |                                cpuidle_idle_call
                   |                                cpu_idle
                   |                                start_secondary
                   |          
                   |--2.38%-- inet_frag_evictor
                   |          ip_defrag
                   |          ip_local_deliver
                   |          ip_rcv_finish
                   |          ip_rcv
                   |          __netif_receive_skb_core
                   |          __netif_receive_skb
                   |          netif_receive_skb
                   |          napi_gro_receive
                   |          ixgbe_poll
                   |          net_rx_action
                   |          __do_softirq
                   |          irq_exit
                   |          do_IRQ
                   |          common_interrupt
                   |          cpuidle_enter_tk
                   |          cpuidle_enter_state
                   |          cpuidle_idle_call
                   |          cpu_idle
                   |          start_secondary
                   |          
                    --2.28%-- inet_frag_intern
                              inet_frag_create
                              inet_frag_find
                              ip_defrag
                              ip_local_deliver
                              ip_rcv_finish
                              ip_rcv
                              __netif_receive_skb_core
                              __netif_receive_skb
                              netif_receive_skb
                              napi_gro_receive
                              ixgbe_poll
                              net_rx_action
                              __do_softirq
                              irq_exit
                              |          
                               --2.27%-- do_IRQ
                                         common_interrupt
                                         |          
                                          --2.25%-- cpuidle_enter_tk
                                                    cpuidle_enter_state
                                                    cpuidle_idle_call
                                                    cpu_idle
                                                    start_secondary

     1.91%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_frag_find                     

     1.66%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_frag_intern                   

     1.54%  ksoftirqd/1  [kernel.kallsyms]  [k] ip_defrag                          

     1.52%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_frag_kill                     

     1.19%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_frag_evictor                  

     1.05%  ksoftirqd/1  [kernel.kallsyms]  [k] __percpu_counter_add               

     0.77%  ksoftirqd/1  [kernel.kallsyms]  [k] __list_del_entry                   

     0.53%  ksoftirqd/1  [kernel.kallsyms]  [k] _raw_read_lock                     

     0.49%  ksoftirqd/1  [kernel.kallsyms]  [k] ip4_frag_match                     

     0.44%  ksoftirqd/1  [kernel.kallsyms]  [k] __list_add                         

     0.42%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_getpeer                       

     0.40%         perf  [kernel.kallsyms]  [k] _raw_spin_lock                     

     0.38%  ksoftirqd/1  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave             

     0.33%  ksoftirqd/1  [kernel.kallsyms]  [k] __slab_free                        

     0.29%  ksoftirqd/1  [ixgbe]            [k] ixgbe_poll                         

     0.26%  ksoftirqd/1  [kernel.kallsyms]  [k] fib_table_lookup                   

     0.24%      swapper  [kernel.kallsyms]  [k] inet_frag_find                     

     0.23%  ksoftirqd/1  [kernel.kallsyms]  [k] __netif_receive_skb_core           

     0.18%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_frag_destroy                  

     0.18%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_putpeer                       

     0.17%  ksoftirqd/1  [kernel.kallsyms]  [k] memcpy                             

     0.16%      swapper  [kernel.kallsyms]  [k] inet_frag_evictor                  

     0.16%      swapper  [kernel.kallsyms]  [k] inet_frag_kill                     

     0.14%      swapper  [kernel.kallsyms]  [k] inet_frag_intern                   

     0.14%      swapper  [kernel.kallsyms]  [k] ip_defrag                          

     0.13%  ksoftirqd/1  [kernel.kallsyms]  [k] build_skb                          

     0.13%  ksoftirqd/1  [kernel.kallsyms]  [k] ip_route_input_noref               

     0.13%  ksoftirqd/1  [kernel.kallsyms]  [k] __internal_add_timer               

     0.12%  ksoftirqd/1  [kernel.kallsyms]  [k] _raw_spin_unlock_irqrestore        

     0.12%  ksoftirqd/1  [kernel.kallsyms]  [k] skb_release_data                   

     0.11%  ksoftirqd/1  [kernel.kallsyms]  [k] ip_rcv                             

     0.11%  ksoftirqd/1  [kernel.kallsyms]  [k] skb_release_head_state             

     0.10%      swapper  [kernel.kallsyms]  [k] __percpu_counter_add               

     0.10%  ksoftirqd/1  [kernel.kallsyms]  [k] __netdev_alloc_frag                

     0.10%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_frag_alloc                    

     0.09%  ksoftirqd/1  [kernel.kallsyms]  [k] ip4_hashfn                         

     0.09%  ksoftirqd/1  [kernel.kallsyms]  [k] dev_gro_receive                    

     0.09%  ksoftirqd/1  [kernel.kallsyms]  [k] put_compound_page                  

     0.09%  ksoftirqd/1  [kernel.kallsyms]  [k] check_leaf                         

     0.09%  ksoftirqd/1  [kernel.kallsyms]  [k] kmem_cache_free                    

     0.08%  ksoftirqd/1  [kernel.kallsyms]  [k] kmem_cache_alloc                   

     0.08%  ksoftirqd/1  [kernel.kallsyms]  [k] put_page                           

     0.08%  ksoftirqd/1  [kernel.kallsyms]  [k] ip4_frag_free                      

     0.08%  ksoftirqd/1  [kernel.kallsyms]  [k] nf_iterate                         

     0.08%  ksoftirqd/1  [kernel.kallsyms]  [k] ip_rcv_finish                      

     0.07%      swapper  [kernel.kallsyms]  [k] __list_del_entry                   

     0.07%      swapper  [kernel.kallsyms]  [k] ip4_frag_match                     

     0.07%  ksoftirqd/1  [kernel.kallsyms]  [k] __kmalloc                          

     0.06%  kworker/1:1  [kernel.kallsyms]  [k] _raw_spin_lock                     

     0.06%  ksoftirqd/1  [kernel.kallsyms]  [k] setup_object                       

     0.06%  ksoftirqd/1  [kernel.kallsyms]  [k] swiotlb_sync_single_for_cpu        

     0.06%  ksoftirqd/1  [kernel.kallsyms]  [k] skb_free_head                      

     0.06%  ksoftirqd/1  [kernel.kallsyms]  [k] fib_validate_source                

     0.06%      swapper  [kernel.kallsyms]  [k] __list_add                         

     0.05%  ksoftirqd/1  [kernel.kallsyms]  [k] memset                             

     0.05%  ksoftirqd/1  [kernel.kallsyms]  [k] detach_if_pending                  

     0.05%      swapper  [kernel.kallsyms]  [k] _raw_read_lock                     

     0.05%  ksoftirqd/1  [kernel.kallsyms]  [k] __copy_skb_header                  

     0.05%  ksoftirqd/1  [kernel.kallsyms]  [k] try_to_wake_up                     

     0.05%      swapper  [kernel.kallsyms]  [k] __slab_free                        

     0.05%  ksoftirqd/1  [kernel.kallsyms]  [k] idle_cpu                           

     0.04%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_gro_receive                   

     0.04%      swapper  [kernel.kallsyms]  [k] inet_getpeer                       

     0.04%  ksoftirqd/1  [kernel.kallsyms]  [k] eth_type_trans                     

     0.04%  ksoftirqd/1  [kernel.kallsyms]  [k] mod_timer                          

     0.04%  ksoftirqd/1  [kernel.kallsyms]  [k] __slab_alloc                       

     0.04%  ksoftirqd/1  [kernel.kallsyms]  [k] nf_hook_slow                       

     0.04%  ksoftirqd/1  [kernel.kallsyms]  [k] ip_local_deliver                   

     0.04%  ksoftirqd/1  [kernel.kallsyms]  [k] ip4_frag_init                      

     0.04%  ksoftirqd/1  [kernel.kallsyms]  [k] __udp4_lib_rcv                     

     0.04%  ksoftirqd/1  [kernel.kallsyms]  [k] del_timer                          

     0.04%      swapper  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave             

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] __netdev_alloc_skb                 

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] netif_receive_skb                  

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] napi_gro_receive                   

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] __skb_clone                        

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] __pskb_pull_tail                   

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] sock_def_readable                  

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] new_slab                           

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] get_slab                           

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] find_last_bit                      

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] __udp4_lib_lookup                  

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] get_page_from_freelist             

     0.03%      swapper  [kernel.kallsyms]  [k] intel_idle                         

     0.03%  ksoftirqd/1  [kernel.kallsyms]  [k] init_timer_key                     

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] enqueue_task_fair                  

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] skb_try_coalesce                   

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] skb_copy_bits                      

     0.02%      swapper  [kernel.kallsyms]  [k] skb_release_head_state             

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] __kfree_skb                        

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] __netif_receive_skb                

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] ktime_get                          

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] kfree                              

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] resched_task                       

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] __sk_mem_schedule                  

     0.02%      swapper  [ixgbe]            [k] ixgbe_poll                         

     0.02%      swapper  [kernel.kallsyms]  [k] __netif_receive_skb_core           

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] lock_timer_base                    

     0.02%      swapper  [kernel.kallsyms]  [k] inet_putpeer                       

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] list_del                           

     0.02%  ksoftirqd/1  [ixgbe]            [k] ixgbe_alloc_rx_buffers             

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] rcu_check_callbacks                

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] swiotlb_sync_single                

     0.02%  ksoftirqd/1  [bridge]           [k] ip_sabotage_in                     

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] apic_timer_interrupt               

     0.02%      swapper  [kernel.kallsyms]  [k] fib_table_lookup                   

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] update_rq_clock                    

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] find_busiest_group                 

     0.02%  ksoftirqd/1  [kernel.kallsyms]  [k] internal_add_timer                 

     0.02%      swapper  [kernel.kallsyms]  [k] inet_frag_destroy                  

     0.01%      swapper  [kernel.kallsyms]  [k] ip_rcv_finish                      

     0.01%      swapper  [kernel.kallsyms]  [k] build_skb                          

     0.01%      swapper  [kernel.kallsyms]  [k] find_busiest_group                 

     0.01%      swapper  [kernel.kallsyms]  [k] idle_cpu                           

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] trigger_load_balance               

     0.01%      swapper  [kernel.kallsyms]  [k] ip4_hashfn                         

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] lapic_next_deadline                

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] hrtimer_interrupt                  

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] kfree_skb                          

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] sock_queue_rcv_skb                 

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] inet_frag_create                   

     0.01%         perf  [kernel.kallsyms]  [k] copy_user_generic_string           

     0.01%      swapper  [kernel.kallsyms]  [k] _raw_spin_unlock_irqrestore        

     0.01%         perf  [kernel.kallsyms]  [k] inet_frag_find                     

     0.01%      swapper  [kernel.kallsyms]  [k] put_compound_page                  

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] update_cfs_rq_blocked_load         

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] udp_queue_rcv_skb                  

     0.01%      swapper  [kernel.kallsyms]  [k] ip4_frag_free                      

     0.01%      swapper  [kernel.kallsyms]  [k] kmem_cache_alloc                   

     0.01%      swapper  [kernel.kallsyms]  [k] memcpy                             

     0.01%      swapper  [kernel.kallsyms]  [k] get_nohz_timer_target              

     0.01%      swapper  [kernel.kallsyms]  [k] __kmalloc                          

     0.01%      swapper  [kernel.kallsyms]  [k] ip_rcv                             

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] unfreeze_partials                  

     0.01%         perf  [kernel.kallsyms]  [k] __list_add                         

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] task_tick_fair                     

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] dma_issue_pending_all              

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] skb_add_rx_frag                    

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] skb_clone                          

     0.01%      swapper  [kernel.kallsyms]  [k] ip_route_input_noref               

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] irq_enter                          

     0.01%      swapper  [kernel.kallsyms]  [k] inet_frag_alloc                    

     0.01%      swapper  [kernel.kallsyms]  [k] detach_if_pending                  

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] scheduler_tick                     

     0.01%         perf  [kernel.kallsyms]  [k] inet_frag_evictor                  

     0.01%      swapper  [kernel.kallsyms]  [k] __slab_alloc                       

     0.01%      swapper  [kernel.kallsyms]  [k] mod_timer                          

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] __wake_up_sync_key                 

     0.01%  ksoftirqd/1  [ixgbe]            [k] ixgbe_update_dca                   

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] __udp_queue_rcv_skb                

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] run_posix_cpu_timers               

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] ip_local_deliver_finish            

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] swiotlb_sync_single_for_device     

     0.01%         perf  [kernel.kallsyms]  [k] inet_frag_kill                     

     0.01%      swapper  [kernel.kallsyms]  [k] dev_gro_receive                    

     0.01%      swapper  [kernel.kallsyms]  [k] __netdev_alloc_frag                

     0.01%      swapper  [kernel.kallsyms]  [k] ip4_frag_init                      

     0.01%      swapper  [kernel.kallsyms]  [k] update_blocked_averages            

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] get_partial_node                   

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] put_cpu_partial                    

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] __switch_to                        

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] perf_event_task_tick               

     0.01%      swapper  [kernel.kallsyms]  [k] skb_release_data                   

     0.01%      swapper  [kernel.kallsyms]  [k] del_timer                          

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] account_system_time                

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] net_rx_action                      

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] raise_softirq                      

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] __alloc_pages_nodemask             

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] next_zones_zonelist                

     0.01%      swapper  [kernel.kallsyms]  [k] put_page                           

     0.01%      swapper  [kernel.kallsyms]  [k] add_interrupt_randomness           

     0.01%      swapper  [kernel.kallsyms]  [k] swiotlb_sync_single_for_cpu        

     0.01%      swapper  [ixgbe]            [k] ixgbe_alloc_rx_buffers             

     0.01%      swapper  [kernel.kallsyms]  [k] nf_hook_slow                       

     0.01%      swapper  [kernel.kallsyms]  [k] cpumask_next_and                   

     0.01%      swapper  [kernel.kallsyms]  [k] __internal_add_timer               

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] timerqueue_add                     

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] __update_cpu_load                  

     0.01%      swapper  [kernel.kallsyms]  [k] fib_validate_source                

     0.01%         perf  [kernel.kallsyms]  [k] jbd2_journal_put_journal_head      

     0.01%         perf  [kernel.kallsyms]  [k] mark_page_accessed                 

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] rebalance_domains                  

     0.01%         perf  [kernel.kallsyms]  [k] ip_defrag                          

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] __irq_work_run                     

     0.01%      swapper  [kernel.kallsyms]  [k] sched_avg_update                   

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] profile_tick                       

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] run_ksoftirqd                      

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] update_curr                        

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] intel_pmu_disable_all              

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] check_preempt_wakeup               

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] perf_pmu_disable                   

     0.01%  ksoftirqd/1  [kernel.kallsyms]  [k] ttwu_do_wakeup                     

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] tick_sched_timer                   

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] inet_frag_find                     

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] hrtimer_run_queues                 

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] alloc_pages_current                

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] check_preempt_curr                 

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] fib_compute_spec_dst               

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] ipv4_pktinfo_prepare               

     0.00%      swapper  [kernel.kallsyms]  [k] eth_type_trans                     

     0.00%      swapper  [kernel.kallsyms]  [k] nf_iterate                         

     0.00%      swapper  [kernel.kallsyms]  [k] __netdev_alloc_skb                 

     0.00%         perf  [kernel.kallsyms]  [k] inet_getpeer                       

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] _cond_resched                      

     0.00%      swapper  [kernel.kallsyms]  [k] rcu_idle_exit                      

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] load_balance                       

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __free_pages                       

     0.00%         perf  [kernel.kallsyms]  [k] __percpu_counter_add               

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __zone_watermark_ok                

     0.00%      swapper  [kernel.kallsyms]  [k] get_slab                           

     0.00%      swapper  [kernel.kallsyms]  [k] find_last_bit                      

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] discard_slab                       

     0.00%      swapper  [kernel.kallsyms]  [k] kmem_cache_free                    

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] dequeue_task                       

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] policy_zonelist                    

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] run_rebalance_domains              

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] free_one_page                      

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] __update_entity_load_avg_contrib   

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] update_process_times               

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] update_cfs_shares                  

     0.00%      swapper  [kernel.kallsyms]  [k] cpuidle_wrap_enter                 

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] dequeue_task_fair                  

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] rb_next                            

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] native_sched_clock                 

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __inc_zone_state                   

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] __list_del_entry                   

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __schedule                         

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] run_timer_softirq                  

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] sched_clock_tick                   

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] mod_zone_page_state                

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] _raw_spin_lock_irq                 

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] udp_rcv                            

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __run_hrtimer                      

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] sched_clock_cpu                    

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] perf_adjust_freq_unthr_context     

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] skb_push                           

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] security_sock_rcv_skb              

     0.00%      swapper  [kernel.kallsyms]  [k] list_del                           

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] sk_filter                          

     0.00%         perf  [kernel.kallsyms]  [k] __block_commit_write               

     0.00%      swapper  [kernel.kallsyms]  [k] kfree_skb                          

     0.00%      swapper  [kernel.kallsyms]  [k] lock_timer_base                    

     0.00%         perf  [kernel.kallsyms]  [k] inet_frag_intern                   

     0.00%         perf  [kernel.kallsyms]  [k] ip4_frag_free                      

     0.00%         perf  [kernel.kallsyms]  [k] __kmalloc                          

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] irq_work_run                       

     0.00%      swapper  [kernel.kallsyms]  [k] irq_exit                           

     0.00%      swapper  [kernel.kallsyms]  [k] skb_free_head                      

     0.00%      swapper  [kernel.kallsyms]  [k] menu_select                        

     0.00%      swapper  [kernel.kallsyms]  [k] find_next_bit                      

     0.00%      swapper  [kernel.kallsyms]  [k] memset                             

     0.00%      swapper  [kernel.kallsyms]  [k] lapic_next_deadline                

     0.00%      swapper  [kernel.kallsyms]  [k] update_cfs_rq_blocked_load         

     0.00%      swapper  [kernel.kallsyms]  [k] rebalance_domains                  

     0.00%      swapper  [kernel.kallsyms]  [k] irq_entries_start                  

     0.00%      swapper  [kernel.kallsyms]  [k] get_pageblock_flags_group          

     0.00%         perf  [kernel.kallsyms]  [k] __slab_free                        

     0.00%      swapper  [kernel.kallsyms]  [k] __update_cpu_load                  

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] __cpufreq_driver_target            

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] find_next_bit                      

     0.00%         perf  [kernel.kallsyms]  [k] _raw_read_lock                     

     0.00%      swapper  [kernel.kallsyms]  [k] __hrtimer_start_range_ns           

     0.00%      swapper  [kernel.kallsyms]  [k] load_balance                       

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] finish_task_switch                 

     0.00%         perf  [kernel.kallsyms]  [k] net_rx_action                      

     0.00%      swapper  [kernel.kallsyms]  [k] netif_receive_skb                  

     0.00%      swapper  [kernel.kallsyms]  [k] swiotlb_sync_single_for_device     

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] ip4_frag_init                      

     0.00%         perf  [kernel.kallsyms]  [k] iov_iter_copy_from_user_atomic     

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] ns_to_timespec                     

     0.00%         perf  [kernel.kallsyms]  [k] _raw_spin_unlock_irqrestore        

     0.00%  ksoftirqd/1  [ixgbe]            [k] ixgbe_update_itr                   

     0.00%         perf  [kernel.kallsyms]  [k] __ext4_get_inode_loc               

     0.00%         perf  [kernel.kallsyms]  [k] __netdev_alloc_frag                

     0.00%         perf  [kernel.kallsyms]  [k] jbd2_journal_add_journal_head      

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __mod_zone_page_state              

     0.00%         perf  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave             

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] get_pageblock_flags_group          

     0.00%         perf  [kernel.kallsyms]  [k] check_leaf                         

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] cpuacct_charge                     

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] __internal_add_timer               

     0.00%  kworker/1:1  [ixgbe]            [k] ixgbe_poll                         

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave             

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] __compute_runnable_contrib         

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] update_curr                        

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] queue_delayed_work_on              

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] pick_next_task_fair                

     0.00%      swapper  [kernel.kallsyms]  [k] __free_pages                       

     0.00%      swapper  [kernel.kallsyms]  [k] __kfree_skb                        

     0.00%      swapper  [ixgbe]            [k] ixgbe_msix_clean_rings             

     0.00%         perf  [kernel.kallsyms]  [k] jbd2__journal_start                

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __queue_work                       

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] handle_edge_irq                    

     0.00%         perf  [kernel.kallsyms]  [k] __rmqueue                          

     0.00%         perf  [kernel.kallsyms]  [k] cpuacct_charge                     

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] intel_pmu_enable_all               

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] kthread_data                       

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] handle_irq_event_percpu            

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] handle_edge_irq                    

     0.00%         perf  [kernel.kallsyms]  [k] __lru_cache_add                    

     0.00%         perf  [kernel.kallsyms]  [k] alloc_pages_current                

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] raw_local_deliver                  

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] od_check_cpu                       

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] can_migrate_task                   

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] default_wake_function              

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] get_work_pool                      

     0.00%         perf  [kernel.kallsyms]  [k] __zone_watermark_ok                

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] rb_insert_color                    

     0.00%         perf  [kernel.kallsyms]  [k] radix_tree_lookup_slot             

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] update_ts_time_stats               

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __wake_up_common                   

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] cpuacct_charge                     

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] tick_sched_handle                  

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] smpboot_thread_fn                  

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] ktime_get_update_offsets           

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] ktime_get                          

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] read_tsc                           

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] kfree_skb_partial                  

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __rmqueue                          

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] vmstat_update                      

     0.00%         perf  [kernel.kallsyms]  [k] __find_get_block                   

     0.00%      swapper  [kernel.kallsyms]  [k] int_sqrt                           

     0.00%      swapper  [kernel.kallsyms]  [k] native_sched_clock                 

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] cpumask_next_and                   

     0.00%  ksoftirqd/1  [ioatdma]          [k] ioat2_issue_pending                

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] __queue_delayed_work               

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] restore_args                       

     0.00%         perf  [kernel.kallsyms]  [k] generic_file_buffered_write        

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] __percpu_counter_add               

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] rcu_irq_enter                      

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __free_pages_ok                    

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] tick_do_update_jiffies64           

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] do_drv_write                       

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] slab_node                          

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] _raw_read_lock                     

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] memcpy                             

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] consume_skb                        

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] native_smp_send_reschedule         

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] smp_apic_timer_interrupt           

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] do_timer                           

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] ip4_frag_match                     

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] account_process_tick               

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] default_send_IPI_mask_sequence_phys

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] free_pages_prepare                 

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] irq_exit                           

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] sched_avg_update                   

     0.00%         perf  [kernel.kallsyms]  [k] irq_enter                          

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] ttwu_stat                          

     0.00%         perf  [kernel.kallsyms]  [k] mark_buffer_dirty                  

     0.00%         perf  [kernel.kallsyms]  [k] rcu_check_callbacks                

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __skb_dst_set_noref                

     0.00%         perf  [kernel.kallsyms]  [k] skb_release_data                   

     0.00%  kworker/1:1  [kernel.kallsyms]  [k] kobject_get                        

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] rcu_irq_exit                       

     0.00%         perf  [kernel.kallsyms]  [k] inet_gro_receive                   

     0.00%         perf  [kernel.kallsyms]  [k] kmem_cache_free                    

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] __do_softirq                       

     0.00%         perf  [kernel.kallsyms]  [k] update_cfs_rq_blocked_load         

     0.00%         perf  [kernel.kallsyms]  [k] __slab_alloc                       

     0.00%         perf  [kernel.kallsyms]  [k] __pollwait                         

     0.00%         perf  [kernel.kallsyms]  [k] ext4_nonda_switch                  

     0.00%         perf  [kernel.kallsyms]  [k] __internal_add_timer               

     0.00%      swapper  [kernel.kallsyms]  [k] rcu_irq_enter                      

     0.00%         perf  [kernel.kallsyms]  [k] ext4_da_get_block_prep             

     0.00%         perf  [kernel.kallsyms]  [k] __srcu_read_unlock                 

     0.00%      swapper  [kernel.kallsyms]  [k] exit_idle                          

     0.00%      swapper  [kernel.kallsyms]  [k] __netif_receive_skb                

     0.00%      swapper  [kernel.kallsyms]  [k] tick_nohz_idle_exit                

     0.00%      swapper  [kernel.kallsyms]  [k] new_slab                           

     0.00%      swapper  [kernel.kallsyms]  [k] napi_gro_receive                   

     0.00%      swapper  [kernel.kallsyms]  [k] handle_edge_irq                    

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] update_group_power                 

     0.00%      swapper  [kernel.kallsyms]  [k] setup_object                       

     0.00%         perf  [kernel.kallsyms]  [k] perf_poll                          

     0.00%         perf  [kernel.kallsyms]  [k] __getblk                           

     0.00%  ksoftirqd/1  [kernel.kallsyms]  [k] find_next_bit                      

     0.00%      swapper  [kernel.kallsyms]  [k] __page_cache_release               

     0.00%      swapper  [kernel.kallsyms]  [k] tick_nohz_idle_enter               

     0.00%      swapper  [kernel.kallsyms]  [k] cpuidle_idle_call                  

     0.00%      swapper  [kernel.kallsyms]  [k] irq_to_desc                        

     0.00%      swapper  [kernel.kallsyms]  [k] rcu_needs_cpu                      

     0.00%      swapper  [kernel.kallsyms]  [k] alloc_pages_current                

     0.00%      swapper  [kernel.kallsyms]  [k] init_timer_key                     

     0.00%      swapper  [kernel.kallsyms]  [k] tick_check_idle                    

     0.00%      swapper  [kernel.kallsyms]  [k] napi_complete                      



#
# (For a higher level overview, try: perf report --sort comm,dso)
#

--=-2NQ8OVnXWoHlpOFajWJM--
