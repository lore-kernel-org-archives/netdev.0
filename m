From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Thu, 17 Nov 2016 19:30:21 +0100
Message-ID: <20161117193021.580589ae@redhat.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        brouer@redhat.com, Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58540 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751335AbcKQSa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 13:30:28 -0500
In-Reply-To: <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2016 08:21:19 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2016-11-17 at 15:57 +0100, Jesper Dangaard Brouer wrote:
> > On Thu, 17 Nov 2016 06:17:38 -0800
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >   
> > > On Thu, 2016-11-17 at 14:42 +0100, Jesper Dangaard Brouer wrote:
> > >   
> > > > I can see that qdisc layer does not activate xmit_more in this case.
> > > >     
> > > 
> > > Sure. Not enough pressure from the sender(s).
> > > 
> > > The bottleneck is not the NIC or qdisc in your case, meaning that BQL
> > > limit is kept at a small value.
> > > 
> > > (BTW not all NIC have expensive doorbells)  
> > 
> > I believe this NIC mlx5 (50G edition) does.
> > 
> > I'm seeing UDP TX of 1656017.55 pps, which is per packet:
> > 2414 cycles(tsc) 603.86 ns
> > 
> > Perf top shows (with my own udp_flood, that avoids __ip_select_ident):
> > 
> >  Samples: 56K of event 'cycles', Event count (approx.): 51613832267
> >    Overhead  Command        Shared Object        Symbol
> >  +    8.92%  udp_flood      [kernel.vmlinux]     [k] _raw_spin_lock
> >    - _raw_spin_lock
> >       + 90.78% __dev_queue_xmit
> >       + 7.83% dev_queue_xmit
> >       + 1.30% ___slab_alloc
> >  +    5.59%  udp_flood      [kernel.vmlinux]     [k] skb_set_owner_w  
> 
> Does TX completion happens on same cpu ?
> 
> >  +    4.77%  udp_flood      [mlx5_core]          [k] mlx5e_sq_xmit
> >  +    4.09%  udp_flood      [kernel.vmlinux]     [k] fib_table_lookup  
> 
> Why fib_table_lookup() is used with connected UDP flow ???

Don't know. I would be interested in hints howto avoid this!...

I also see it with netperf, and my udp_flood code is here:
 https://github.com/netoptimizer/network-testing/blob/master/src/udp_flood.c


> >  +    4.00%  swapper        [mlx5_core]          [k] mlx5e_poll_tx_cq
> >  +    3.11%  udp_flood      [kernel.vmlinux]     [k] __ip_route_output_key_hash  
> 
> Same here, this is suspect.

It is the function calling fib_table_lookup(), and it is called by ip_route_output_flow().
 
> >  +    2.49%  swapper        [kernel.vmlinux]     [k] __slab_free
> > 
> > In this setup the spinlock in __dev_queue_xmit should be uncongested.
> > An uncongested spin_lock+unlock cost 32 cycles(tsc) 8.198 ns on this system.
> > 
> > But 8.92% of the time is spend on it, which corresponds to a cost of 215
> > cycles (2414*0.0892).  This cost is too high, thus something else is
> > going on... I claim this mysterious extra cost is the tailptr/doorbell.  
> 
> Well, with no pressure, doorbell is triggered for each packet.
> 
> Since we can not predict that your application is going to send yet
> another packet one usec later, we can not avoid this.

The point is I can see a socket Send-Q forming, thus we do know the
application have something to send. Thus, and possibility for
non-opportunistic bulking. Allowing/implementing bulk enqueue from
socket layer into qdisc layer, should be fairly simple (and rest of
xmit_more is already in place).  


> Note that with the patches I am working on (busypolling extentions),
> we could decide to let the busypoller doing the doorbells, say one every
> 10 usec. (or after ~16 packets were queued)

Sounds interesting! but an opportunistically approach.

> But mlx4 uses two different NAPI for TX and RX, maybe mlx5 has the same
> strategy .

It is a possibility that TX completions were happening on another CPU
(but I don't think so for mlx5).

To rule that out, I reran the experiment making sure to pin everything
to CPU-0 and the results are the same.

sudo ethtool -L mlx5p2 combined 1

sudo sh -c '\                                                    
 for x in /proc/irq/*/mlx5*/../smp_affinity; do \
   echo 01 > $x; grep . -H $x; done \
'

$ taskset -c 0 ./udp_flood --sendto 198.18.50.1 --count $((10**9))

Perf report validating CPU in use:

$ perf report -g --no-children --sort cpu,comm,dso,symbol --stdio --call-graph none

# Overhead  CPU  Command         Shared Object        Symbol                                   
# ........  ...  ..............  ...................  .........................................
#
     9.97%  000  udp_flood       [kernel.vmlinux]     [k] _raw_spin_lock                       
     4.37%  000  udp_flood       [kernel.vmlinux]     [k] fib_table_lookup                     
     3.97%  000  udp_flood       [mlx5_core]          [k] mlx5e_sq_xmit                        
     3.06%  000  udp_flood       [kernel.vmlinux]     [k] __ip_route_output_key_hash           
     2.51%  000  udp_flood       [mlx5_core]          [k] mlx5e_poll_tx_cq                     
     2.48%  000  udp_flood       [kernel.vmlinux]     [k] copy_user_enhanced_fast_string       
     2.47%  000  udp_flood       [kernel.vmlinux]     [k] entry_SYSCALL_64                     
     2.42%  000  udp_flood       [kernel.vmlinux]     [k] udp_sendmsg                          
     2.39%  000  udp_flood       [kernel.vmlinux]     [k] __ip_append_data.isra.47             
     2.29%  000  udp_flood       [kernel.vmlinux]     [k] sock_def_write_space                 
     2.19%  000  udp_flood       [mlx5_core]          [k] mlx5e_get_cqe                        
     1.95%  000  udp_flood       [kernel.vmlinux]     [k] __ip_make_skb                        
     1.94%  000  udp_flood       [kernel.vmlinux]     [k] __alloc_skb                          
     1.90%  000  udp_flood       [kernel.vmlinux]     [k] sock_wfree                           
     1.85%  000  udp_flood       [kernel.vmlinux]     [k] skb_set_owner_w                      
     1.62%  000  udp_flood       [kernel.vmlinux]     [k] ip_finish_output2                    
     1.61%  000  udp_flood       [kernel.vmlinux]     [k] kfree                                
     1.54%  000  udp_flood       [kernel.vmlinux]     [k] entry_SYSCALL_64_fastpath            
     1.35%  000  udp_flood       libc-2.17.so         [.] __sendmsg_nocancel                   
     1.26%  000  udp_flood       [kernel.vmlinux]     [k] __kmalloc_node_track_caller          
     1.24%  000  udp_flood       [kernel.vmlinux]     [k] __rcu_read_unlock                    
     1.23%  000  udp_flood       [kernel.vmlinux]     [k] __local_bh_enable_ip                 
     1.22%  000  udp_flood       [kernel.vmlinux]     [k] ip_idents_reserve         

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
