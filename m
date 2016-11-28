From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 0/5] net: add protocol level recvmmsg support
Date: Mon, 28 Nov 2016 14:52:41 +0100
Message-ID: <20161128145241.4c1b083d@redhat.com>
References: <cover.1480086321.git.pabeni@redhat.com>
        <20161125183711.675fa4a7@redhat.com>
        <1480330358.6718.13.camel@redhat.com>
        <20161128132141.217aef39@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>, brouer@redhat.com
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58136 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932283AbcK1Nwq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 08:52:46 -0500
In-Reply-To: <20161128132141.217aef39@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 28 Nov 2016 13:21:41 +0100 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> On Mon, 28 Nov 2016 11:52:38 +0100 Paolo Abeni <pabeni@redhat.com> wrote:
> >   
> > > > [2] like [1], but using the minimum number of flows to saturate the user space
> > > >  sink, that is 1 flow for the old kernel and 3 for the patched one.
> > > >  the tput increases since the contention on the rx lock is low.
> > > > [3] like [1] but using a single flow with both old and new kernel. All the
> > > >  packets land on the same rx queue and there is a single ksoftirqd instance
> > > >  running    
[...]
> > 
> > We also used connected socket for test[3], with relative little
> > difference (the tput increased for both unpatched and patched kernel, 
> > and the difference was roughly the same).  
> 
> When I use connected sockets (RX side) and ip_early_demux enabled, I do
> see a performance boost for recvmmsg.  With these patches applied,
> forced ksoftirqd on CPU0 and udp_sink on CPU2, pktgen single flow
> sending size 1472 bytes.
> 
> $ sysctl net/ipv4/ip_early_demux
> net.ipv4.ip_early_demux = 1
> 
> $ grep -H . /proc/sys/net/core/{r,w}mem_max
> /proc/sys/net/core/rmem_max:1048576
> /proc/sys/net/core/wmem_max:1048576
> 
> # taskset -c 2 ./udp_sink --count $((10**7)) --port 9 --repeat 1
> #                               ns      pps             cycles
> recvMmsg/32  	run: 0 10000000	462.51	2162095.23	1853
> recvmsg   	run: 0 10000000	536.47	1864041.75	2150
> read      	run: 0 10000000	492.01	2032460.71	1972
> recvfrom  	run: 0 10000000	553.94	1805262.84	2220
> 
> # taskset -c 2 ./udp_sink --count $((10**7)) --port 9 --repeat 1 --connect
> #                               ns      pps             cycles
> recvMmsg/32  	run: 0 10000000	405.15	2468225.03	1623
> recvmsg   	run: 0 10000000	548.23	1824049.58	2197
> read      	run: 0 10000000	489.76	2041825.27	1962
> recvfrom  	run: 0 10000000	466.18	2145091.77	1868
> 
> My theory is that by enabling connect'ed RX socket, the ksoftirqd gets
> faster (no fib_lookup) and is no-longer a bottleneck.  This is
> confirmed by nstat.

Paolo asked me to do a test with small packets with pktgen, and I was
actually surprised by the result.

# taskset -c 2 ./udp_sink --count $((10**7)) --port 9 --repeat 1 --connect
recvMmsg/32  	run: 0 10000000	426.61	2344076.59	1709	17098657328
recvmsg   	run: 0 10000000	533.49	1874449.82	2138	21382574965
read      	run: 0 10000000	470.22	2126651.13	1884	18846797802
recvfrom  	run: 0 10000000	513.74	1946499.83	2059	20591095477

Notice how recvMmsg/32, got slower with 124kpps (2468225 pps -> 2344076 pps).
I was expecting it to get faster, given we just established udp_sink
was the bottleneck, and smaller packet should mean less copy of bytes
to userspace (copy_user_enhanced_fast_string). (With nstat I observe
ksoftirq is again the bottleneck).

Looking at perf diff of CPU2 (baseline=64Bytes) we do see an increase
of copy_user_enhanced_fast_string.  More interestingly we see a
decrease in the locking cost when using big packets (see ** below)

# Event 'cycles:ppp'
#
# Baseline    Delta  Shared Object     Symbol                                   
# ........  .......  ................  .........................................
#
    15.09%   +0.33%  [kernel.vmlinux]  [k] copy_msghdr_from_user
    12.36%  +21.89%  [kernel.vmlinux]  [k] copy_user_enhanced_fast_string
     8.65%   -0.63%  [kernel.vmlinux]  [k] udp_process_skb
     7.33%   -1.88%  [kernel.vmlinux]  [k] __skb_try_recv_datagram_batch
 **  7.12%   -6.66%  [kernel.vmlinux]  [k] udp_rmem_release **
 **  6.71%   -6.52%  [kernel.vmlinux]  [k] _raw_spin_lock_bh **
     6.35%   +1.36%  [kernel.vmlinux]  [k] __free_page_frag
     4.39%   +0.29%  [kernel.vmlinux]  [k] copy_msghdr_to_user_gen
     2.87%   -1.52%  [kernel.vmlinux]  [k] skb_release_data
     2.60%   +0.14%  [kernel.vmlinux]  [k] __put_user_4
     2.27%   -2.18%  [kernel.vmlinux]  [k] __sk_mem_reduce_allocated
     2.11%   +0.08%  [kernel.vmlinux]  [k] cmpxchg_double_slab.isra.68
     1.90%   +2.40%  [kernel.vmlinux]  [k] __slab_free
     1.73%   +0.20%  [kernel.vmlinux]  [k] __udp_recvmmsg
     1.62%   -1.62%  [kernel.vmlinux]  [k] intel_idle
     1.52%   +0.22%  [kernel.vmlinux]  [k] copy_to_iter
     1.20%   -0.03%  [kernel.vmlinux]  [k] import_iovec
     1.14%   +0.05%  [kernel.vmlinux]  [k] rw_copy_check_uvector
     0.80%   -0.04%  [kernel.vmlinux]  [k] recvmmsg_ctx_to_user
     0.75%   -0.69%  [kernel.vmlinux]  [k] __local_bh_enable_ip
     0.71%   +0.18%  [kernel.vmlinux]  [k] skb_copy_datagram_iter
     0.70%   -0.07%  [kernel.vmlinux]  [k] recvmmsg_ctx_from_user
     0.67%   +0.08%  [kernel.vmlinux]  [k] kmem_cache_free
     0.56%   +0.42%  [kernel.vmlinux]  [k] udp_process_msg
     0.48%   +0.05%  [kernel.vmlinux]  [k] skb_release_head_state
     0.46%           [kernel.vmlinux]  [k] lapic_next_deadline
     0.36%           [kernel.vmlinux]  [k] __switch_to
     0.34%   -0.03%  [kernel.vmlinux]  [k] consume_skb
     0.32%   -0.05%  [kernel.vmlinux]  [k] skb_consume_udp


The perf diff from CPU0, also show less lock congestion:

# Event 'cycles:ppp'
#
# Baseline    Delta  Shared Object     Symbol                                   
# ........  .......  ................  .........................................
#
    11.04%   -3.02%  [kernel.vmlinux]  [k] __udp_enqueue_schedule_skb
     9.98%   +2.16%  [mlx5_core]       [k] mlx5e_handle_rx_cqe
     7.23%   -1.85%  [kernel.vmlinux]  [k] udp_v4_early_demux
     3.90%   +0.73%  [kernel.vmlinux]  [k] build_skb
     3.85%   -1.77%  [kernel.vmlinux]  [k] udp_queue_rcv_skb
     3.83%   +0.02%  [kernel.vmlinux]  [k] sock_def_readable
 **  3.26%   -3.19%  [kernel.vmlinux]  [k] queued_spin_lock_slowpath **
     2.99%   +0.55%  [kernel.vmlinux]  [k] __build_skb
     2.97%   +0.11%  [kernel.vmlinux]  [k] __udp4_lib_rcv
 **  2.87%   -1.39%  [kernel.vmlinux]  [k] _raw_spin_lock **
     2.67%   +0.60%  [kernel.vmlinux]  [k] ip_rcv
     2.65%   +0.61%  [kernel.vmlinux]  [k] __netif_receive_skb_core
     2.64%   +0.79%  [ip_tables]       [k] ipt_do_table
     2.37%   +0.37%  [kernel.vmlinux]  [k] read_tsc
     2.26%   +0.52%  [mlx5_core]       [k] mlx5e_get_cqe
     2.11%   -1.15%  [kernel.vmlinux]  [k] __sk_mem_raise_allocated
     2.10%   +0.37%  [kernel.vmlinux]  [k] __rcu_read_unlock
     2.04%   +0.67%  [mlx5_core]       [k] mlx5e_alloc_rx_wqe
     1.86%   +0.40%  [kernel.vmlinux]  [k] inet_gro_receive
     1.57%   +0.11%  [kernel.vmlinux]  [k] kmem_cache_alloc
     1.53%   +0.28%  [kernel.vmlinux]  [k] _raw_read_lock
     1.53%   +0.25%  [kernel.vmlinux]  [k] dev_gro_receive
     1.38%   -0.18%  [kernel.vmlinux]  [k] udp_gro_receive
     1.19%   +0.37%  [kernel.vmlinux]  [k] __rcu_read_lock
     1.14%   +0.31%  [kernel.vmlinux]  [k] _raw_read_unlock
     1.14%   +0.12%  [kernel.vmlinux]  [k] ip_rcv_finish
     1.13%   +0.20%  [kernel.vmlinux]  [k] __udp4_lib_lookup
     1.05%   +0.16%  [kernel.vmlinux]  [k] ktime_get_with_offset
     0.94%   +0.38%  [kernel.vmlinux]  [k] ip_local_deliver_finish
     0.91%   +0.22%  [kernel.vmlinux]  [k] do_csum
     0.86%   -0.04%  [kernel.vmlinux]  [k] ipv4_pktinfo_prepare
     0.84%   +0.05%  [kernel.vmlinux]  [k] sk_filter_trim_cap
     0.84%   +0.20%  [kernel.vmlinux]  [k] ip_local_deliver
     0.84%   +0.19%  [kernel.vmlinux]  [k] udp4_gro_receive

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
