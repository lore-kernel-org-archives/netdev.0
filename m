From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Wed, 27 Sep 2017 11:26:04 +0200
Message-ID: <20170927112604.1284f536@redhat.com>
References: <cover.1506297988.git.daniel@iogearbox.net>
        <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net>
        <20170926211342.0c8e72b0@redhat.com>
        <59CAB17D.5090204@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.fastabend@gmail.com, peter.waskiewicz.jr@intel.com,
        jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59160 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752329AbdI0J0N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 05:26:13 -0400
In-Reply-To: <59CAB17D.5090204@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Sep 2017 21:58:53 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 09/26/2017 09:13 PM, Jesper Dangaard Brouer wrote:
> [...]
> > I'm currently implementing a cpumap type, that transfers raw XDP frames
> > to another CPU, and the SKB is allocated on the remote CPU.  (It
> > actually works extremely well).  
> 
> Meaning you let all the XDP_PASS packets get processed on a
> different CPU, so you can reserve the whole CPU just for
> prefiltering, right? 

Yes, exactly.  Except I use the XDP_REDIRECT action to steer packets.
The trick is using the map-flush point, to transfer packets in bulk to
the remote CPU (single call IPC is too slow), but at the same time
flush single packets if NAPI didn't see a bulk.

> Do you have some numbers to share at this point, just curious when
> you mention it works extremely well.

Sure... I've done a lot of benchmarking on this patchset ;-)
I have a benchmark program called xdp_redirect_cpu [1][2], that collect
stats via tracepoints (atm I'm limiting bulking 8 packets, and have
tracepoints at bulk spots, to amortize tracepoint cost 25ns/8=3.125ns)

 [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_redirect_cpu_kern.c
 [2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_redirect_cpu_user.c

Here I'm installing a DDoS program that drops UDP port 9 (pktgen
packets) on RX CPU=0.  I'm forcing my netperf to hit the same CPU, that
the 11.9Mpps DDoS attack is hitting.

Running XDP/eBPF prog_num:4
XDP-cpumap      CPU:to  pps            drop-pps    extra-info
XDP-RX          0       12,030,471     11,966,982  0          
XDP-RX          total   12,030,471     11,966,982 
cpumap-enqueue    0:2   63,488         0           0          
cpumap-enqueue  sum:2   63,488         0           0          
cpumap_kthread  2       63,488         0           3          time_exceed
cpumap_kthread  total   63,488         0           0          
redirect_err    total   0              0          

$ netperf -H 172.16.0.2 -t TCP_CRR  -l 10 -D1 -T5,5 -- -r 1024,1024
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

16384  87380  1024     1024    10.00    12735.97   
16384  87380 

The netperf TCP_CRR performance is the same, without XDP loaded.


> Another test

I've previously shown (and optimized) in commit c0303efeab73 ("net:
reduce cycles spend on ICMP replies that gets rate limited"), that my
system can handle approx 2.7Mpps for UdpNoPorts, before the network
stack chokes.

Thus it is interesting to see, when I get UDP traffic that hits the
same CPU, if I can simply round-robin distribute it other CPUs.  This
evaluate if the cross-CPU transfer mechanism is fast-enough.

I do have to increase the ixgbe RX-ring size, else the ixgbe recycle
scheme breaks down, and we stall on the page spin_lock (as Tariq have
demonstrated before).

 # ethtool -G ixgbe1 rx 1024 tx 1024

Start RR program and add some CPUs:

 # ./xdp_redirect_cpu --dev ixgbe1 --prog 2 --cpu 1 --cpu 2 --cpu 3 --cpu 4

Running XDP/eBPF prog_num:2
XDP-cpumap      CPU:to  pps            drop-pps    extra-info
XDP-RX          0       11,006,992     0           0          
XDP-RX          total   11,006,992     0          
cpumap-enqueue    0:1   2,751,744      0           0          
cpumap-enqueue  sum:1   2,751,744      0           0          
cpumap-enqueue    0:2   2,751,748      0           0          
cpumap-enqueue  sum:2   2,751,748      0           0          
cpumap-enqueue    0:3   2,751,744      35          0          
cpumap-enqueue  sum:3   2,751,744      35          0          
cpumap-enqueue    0:4   2,751,748      0           0          
cpumap-enqueue  sum:4   2,751,748      0           0          
cpumap_kthread  1       2,751,745      0           156        time_exceed
cpumap_kthread  2       2,751,749      0           142        time_exceed
cpumap_kthread  3       2,751,713      0           131        time_exceed
cpumap_kthread  4       2,751,749      0           128        time_exceed
cpumap_kthread  total   11,006,957     0           0          
redirect_err    total   0              0          

$ nstat > /dev/null && sleep 1 && nstat | grep UdpNoPorts
UdpNoPorts                      11042282           0.0

The nstat show that the Linux network stack is actually now processing,
SKB alloc + free, 11Mpps. 

The generator was sending with 14Mpps, thus the XDP-RX program is
actually a bottleneck here. And I do see some drops on the HW level.
Thus, 1-CPU was not 100% fast-enough.

Thus, lets allocate two CPUs for XDP-RX:

Running XDP/eBPF prog_num:2
XDP-cpumap      CPU:to  pps            drop-pps    extra-info
XDP-RX          0       6,352,578      0           0          
XDP-RX          1       6,352,711      0           0          
XDP-RX          total   12,705,289     0          
cpumap-enqueue    0:2   1,588,156      1,351       0          
cpumap-enqueue    1:2   1,588,174      1,330       0          
cpumap-enqueue  sum:2   3,176,331      2,682       0          
cpumap-enqueue    0:3   1,588,157      994         0          
cpumap-enqueue    1:3   1,588,170      912         0          
cpumap-enqueue  sum:3   3,176,327      1,907       0          
cpumap-enqueue    0:4   1,588,157      529         0          
cpumap-enqueue    1:4   1,588,167      514         0          
cpumap-enqueue  sum:4   3,176,324      1,044       0          
cpumap-enqueue    0:5   1,588,159      625         0          
cpumap-enqueue    1:5   1,588,166      614         0          
cpumap-enqueue  sum:5   3,176,326      1,240       0          
cpumap_kthread  2       3,173,642      0           11257      time_exceed
cpumap_kthread  3       3,174,423      0           9779       time_exceed
cpumap_kthread  4       3,175,283      0           3938       time_exceed
cpumap_kthread  5       3,175,083      0           3120       time_exceed
cpumap_kthread  total   12,698,432     0           0          (null)
redirect_err    total   0              0          

Below, I'm using ./pktgen_sample04_many_flows.sh, and my generator
machine cannot generate more that 12,682,445 tx_packets /sec.
nstat says: UdpNoPorts 12,698,001 pps.  The XDP-RX CPUs actually have
30% idle CPU cycles, as the "only" handle 6.3Mpps each ;-)

Perf top on a CPU(3) that have to alloc and free SKBs etc.

# Overhead  CPU  Symbol                                 
# ........  ...  .......................................
#
    15.51%  003  [k] fib_table_lookup
     8.91%  003  [k] cpu_map_kthread_run
     8.04%  003  [k] build_skb
     7.88%  003  [k] page_frag_free
     5.13%  003  [k] kmem_cache_alloc
     4.76%  003  [k] ip_route_input_rcu
     4.59%  003  [k] kmem_cache_free
     4.02%  003  [k] __udp4_lib_rcv
     3.20%  003  [k] fib_validate_source
     3.02%  003  [k] __netif_receive_skb_core
     3.02%  003  [k] udp_v4_early_demux
     2.90%  003  [k] ip_rcv
     2.80%  003  [k] ip_rcv_finish
     2.26%  003  [k] eth_type_trans
     2.23%  003  [k] __build_skb
     2.00%  003  [k] icmp_send
     1.84%  003  [k] __rcu_read_unlock
     1.30%  003  [k] ip_local_deliver_finish
     1.26%  003  [k] netif_receive_skb_internal
     1.17%  003  [k] ip_route_input_noref
     1.11%  003  [k] make_kuid
     1.09%  003  [k] __udp4_lib_lookup
     1.07%  003  [k] skb_release_head_state
     1.04%  003  [k] __rcu_read_lock
     0.95%  003  [k] kfree_skb
     0.89%  003  [k] __local_bh_enable_ip
     0.88%  003  [k] skb_release_data
     0.71%  003  [k] ip_local_deliver
     0.58%  003  [k] netif_receive_skb

cmdline:
 perf report --sort cpu,symbol --kallsyms=/proc/kallsyms  --no-children  -C3 -g none --stdio

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
