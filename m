From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Wed, 27 Sep 2017 16:54:57 +0200
Message-ID: <20170927165457.4265bfc3@redhat.com>
References: <cover.1506297988.git.daniel@iogearbox.net>
        <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net>
        <20170926211342.0c8e72b0@redhat.com>
        <59CAB17D.5090204@iogearbox.net>
        <20170927112604.1284f536@redhat.com>
        <645e7a39-c172-5882-5dd9-f038430114d1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
        alexei.starovoitov@gmail.com, peter.waskiewicz.jr@intel.com,
        jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40926 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751907AbdI0OzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 10:55:09 -0400
In-Reply-To: <645e7a39-c172-5882-5dd9-f038430114d1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Sep 2017 06:35:40 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> On 09/27/2017 02:26 AM, Jesper Dangaard Brouer wrote:
> > On Tue, 26 Sep 2017 21:58:53 +0200
> > Daniel Borkmann <daniel@iogearbox.net> wrote:
> >   
> >> On 09/26/2017 09:13 PM, Jesper Dangaard Brouer wrote:
> >> [...]  
> >>> I'm currently implementing a cpumap type, that transfers raw XDP frames
> >>> to another CPU, and the SKB is allocated on the remote CPU.  (It
> >>> actually works extremely well).    
> >>
> >> Meaning you let all the XDP_PASS packets get processed on a
> >> different CPU, so you can reserve the whole CPU just for
> >> prefiltering, right?   
> > 
> > Yes, exactly.  Except I use the XDP_REDIRECT action to steer packets.
> > The trick is using the map-flush point, to transfer packets in bulk to
> > the remote CPU (single call IPC is too slow), but at the same time
> > flush single packets if NAPI didn't see a bulk.
> >   
> >> Do you have some numbers to share at this point, just curious when
> >> you mention it works extremely well.  
> > 
> > Sure... I've done a lot of benchmarking on this patchset ;-)
> > I have a benchmark program called xdp_redirect_cpu [1][2], that collect
> > stats via tracepoints (atm I'm limiting bulking 8 packets, and have
> > tracepoints at bulk spots, to amortize tracepoint cost 25ns/8=3.125ns)
> > 
> >  [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_redirect_cpu_kern.c
> >  [2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_redirect_cpu_user.c
> > 
> > Here I'm installing a DDoS program that drops UDP port 9 (pktgen
> > packets) on RX CPU=0.  I'm forcing my netperf to hit the same CPU, that
> > the 11.9Mpps DDoS attack is hitting.
> > 
> > Running XDP/eBPF prog_num:4
> > XDP-cpumap      CPU:to  pps            drop-pps    extra-info
> > XDP-RX          0       12,030,471     11,966,982  0          
> > XDP-RX          total   12,030,471     11,966,982 
> > cpumap-enqueue    0:2   63,488         0           0          
> > cpumap-enqueue  sum:2   63,488         0           0          
> > cpumap_kthread  2       63,488         0           3          time_exceed
> > cpumap_kthread  total   63,488         0           0          
> > redirect_err    total   0              0          
> > 
> > $ netperf -H 172.16.0.2 -t TCP_CRR  -l 10 -D1 -T5,5 -- -r 1024,1024
> > Local /Remote
> > Socket Size   Request  Resp.   Elapsed  Trans.
> > Send   Recv   Size     Size    Time     Rate         
> > bytes  Bytes  bytes    bytes   secs.    per sec   
> > 
> > 16384  87380  1024     1024    10.00    12735.97   
> > 16384  87380 
> > 
> > The netperf TCP_CRR performance is the same, without XDP loaded.
> >   
> 
> Just curious could you also try this with RPS enabled (or does this have
> RPS enabled). RPS should effectively do the same thing but higher in the
> stack. I'm curious what the delta would be. Might be another interesting
> case and fairly easy to setup if you already have the above scripts.

Yes, I'm essentially competing with RSP, thus such a comparison is very
relevant...

This is only a 6 CPUs system. Allocate 2 CPUs to RPS receive and let
other 4 CPUS process packet.

Summary of RPS (Receive Packet Steering) performance:
 * End result is 6.3 Mpps max performance
 * netperf TCP_CRR is 1 trans/sec.
 * Each RX-RPS CPU stall at ~3.2Mpps.

The full test report below with setup:

The mask needed::

 perl -e 'printf "%b\n",0x3C'
 111100

RPS setup::

 sudo sh -c 'echo 32768 > /proc/sys/net/core/rps_sock_flow_entries'

 for N in $(seq 0 5) ; do \
   sudo sh -c "echo 8192 > /sys/class/net/ixgbe1/queues/rx-$N/rps_flow_cnt" ; \
   sudo sh -c "echo 3c > /sys/class/net/ixgbe1/queues/rx-$N/rps_cpus" ; \
   grep -H . /sys/class/net/ixgbe1/queues/rx-$N/rps_cpus ; \
 done

Reduce RX queues to two ::

 ethtool -L ixgbe1 combined 2

IRQ align to CPU numbers::

 $ ~/setup01.sh
 Not root, running with sudo
  --- Disable Ethernet flow-control ---
 rx unmodified, ignoring
 tx unmodified, ignoring
 no pause parameters changed, aborting
 rx unmodified, ignoring
 tx unmodified, ignoring
 no pause parameters changed, aborting
  --- Align IRQs ---
 /proc/irq/54/ixgbe1-TxRx-0/../smp_affinity_list:0
 /proc/irq/55/ixgbe1-TxRx-1/../smp_affinity_list:1
 /proc/irq/56/ixgbe1/../smp_affinity_list:0-5

$ grep -H . /sys/class/net/ixgbe1/queues/rx-*/rps_cpus
/sys/class/net/ixgbe1/queues/rx-0/rps_cpus:3c
/sys/class/net/ixgbe1/queues/rx-1/rps_cpus:3c

Generator is sending: 12,715,782 tx_packets /sec

 ./pktgen_sample04_many_flows.sh -vi ixgbe2 -m 00:1b:21:bb:9a:84 \
    -d 172.16.0.2 -t8

$ nstat > /dev/null && sleep 1 && nstat
#kernel
IpInReceives                    6346544            0.0
IpInDelivers                    6346544            0.0
IpOutRequests                   1020               0.0
IcmpOutMsgs                     1020               0.0
IcmpOutDestUnreachs             1020               0.0
IcmpMsgOutType3                 1020               0.0
UdpNoPorts                      6346898            0.0
IpExtInOctets                   291964714          0.0
IpExtOutOctets                  73440              0.0
IpExtInNoECTPkts                6347063            0.0

$ mpstat -P ALL -u -I SCPU -I SUM

Average:     CPU    %usr   %nice    %sys   %irq   %soft  %idle
Average:     all    0.00    0.00    0.00   0.42   72.97  26.61
Average:       0    0.00    0.00    0.00   0.17   99.83   0.00
Average:       1    0.00    0.00    0.00   0.17   99.83   0.00
Average:       2    0.00    0.00    0.00   0.67   60.37  38.96
Average:       3    0.00    0.00    0.00   0.67   58.70  40.64
Average:       4    0.00    0.00    0.00   0.67   59.53  39.80
Average:       5    0.00    0.00    0.00   0.67   58.93  40.40

Average:     CPU    intr/s
Average:     all 152067.22
Average:       0  50064.73
Average:       1  50089.35
Average:       2  45095.17
Average:       3  44875.04
Average:       4  44906.32
Average:       5  45152.08

Average:     CPU     TIMER/s   NET_TX/s   NET_RX/s TASKLET/s  SCHED/s     RCU/s
Average:       0      609.48       0.17   49431.28      0.00     2.66     21.13
Average:       1      567.55       0.00   49498.00      0.00     2.66     21.13
Average:       2      998.34       0.00   43941.60      4.16    82.86     68.22
Average:       3      540.60       0.17   44140.27      0.00    85.52    108.49
Average:       4      537.27       0.00   44219.63      0.00    84.53     64.89
Average:       5      530.78       0.17   44445.59      0.00    85.02     90.52

>From mpstat it looks like it is the RX-RPS CPUs that are the bottleneck.

Show adapter(s) (ixgbe1) statistics (ONLY that changed!)
Ethtool(ixgbe1) stat:     11109531 (   11,109,531) <= fdir_miss /sec
Ethtool(ixgbe1) stat:    380632356 (  380,632,356) <= rx_bytes /sec
Ethtool(ixgbe1) stat:    812792611 (  812,792,611) <= rx_bytes_nic /sec
Ethtool(ixgbe1) stat:      1753550 (    1,753,550) <= rx_missed_errors /sec
Ethtool(ixgbe1) stat:      4602487 (    4,602,487) <= rx_no_dma_resources /sec
Ethtool(ixgbe1) stat:      6343873 (    6,343,873) <= rx_packets /sec
Ethtool(ixgbe1) stat:     10946441 (   10,946,441) <= rx_pkts_nic /sec
Ethtool(ixgbe1) stat:    190287853 (  190,287,853) <= rx_queue_0_bytes /sec
Ethtool(ixgbe1) stat:      3171464 (    3,171,464) <= rx_queue_0_packets /sec
Ethtool(ixgbe1) stat:    190344503 (  190,344,503) <= rx_queue_1_bytes /sec
Ethtool(ixgbe1) stat:      3172408 (    3,172,408) <= rx_queue_1_packets /sec

Notice, each RX-CPU can only process 3.1Mpps.

RPS RX-CPU(0):

 # Overhead  CPU  Symbol
 # ........  ...  .......................................
 #
    11.72%  000  [k] ixgbe_poll
    11.29%  000  [k] _raw_spin_lock
    10.35%  000  [k] dev_gro_receive
     8.36%  000  [k] __build_skb
     7.35%  000  [k] __skb_get_hash
     6.22%  000  [k] enqueue_to_backlog
     5.89%  000  [k] __skb_flow_dissect
     4.43%  000  [k] inet_gro_receive
     4.19%  000  [k] ___slab_alloc
     3.90%  000  [k] queued_spin_lock_slowpath
     3.85%  000  [k] kmem_cache_alloc
     3.06%  000  [k] build_skb
     2.66%  000  [k] get_rps_cpu
     2.57%  000  [k] napi_gro_receive
     2.34%  000  [k] eth_type_trans
     1.81%  000  [k] __cmpxchg_double_slab.isra.61
     1.47%  000  [k] ixgbe_alloc_rx_buffers
     1.43%  000  [k] get_partial_node.isra.81
     0.84%  000  [k] swiotlb_sync_single
     0.74%  000  [k] udp4_gro_receive
     0.73%  000  [k] netif_receive_skb_internal
     0.72%  000  [k] udp_gro_receive
     0.63%  000  [k] skb_gro_reset_offset
     0.49%  000  [k] __skb_flow_get_ports
     0.48%  000  [k] llist_add_batch
     0.36%  000  [k] swiotlb_sync_single_for_cpu
     0.34%  000  [k] __slab_alloc


Remote RPS-CPU(3) getting packets::

 # Overhead  CPU  Symbol
 # ........  ...  ..............................................
 #
    33.02%  003  [k] poll_idle
    10.99%  003  [k] __netif_receive_skb_core
    10.45%  003  [k] page_frag_free
     8.49%  003  [k] ip_rcv
     4.19%  003  [k] fib_table_lookup
     2.84%  003  [k] __udp4_lib_rcv
     2.81%  003  [k] __slab_free
     2.23%  003  [k] __udp4_lib_lookup
     2.09%  003  [k] ip_route_input_rcu
     2.07%  003  [k] kmem_cache_free
     2.06%  003  [k] udp_v4_early_demux
     1.73%  003  [k] ip_rcv_finish
     1.44%  003  [k] process_backlog
     1.32%  003  [k] icmp_send
     1.30%  003  [k] cmpxchg_double_slab.isra.73
     0.95%  003  [k] intel_idle
     0.88%  003  [k] _raw_spin_lock
     0.84%  003  [k] fib_validate_source
     0.79%  003  [k] ip_local_deliver_finish
     0.67%  003  [k] ip_local_deliver
     0.56%  003  [k] skb_release_data
     0.53%  003  [k] unfreeze_partials.isra.80
     0.51%  003  [k] skb_release_head_state
     0.44%  003  [k] kfree_skb
     0.44%  003  [k] queued_spin_lock_slowpath
     0.44%  003  [k] __cmpxchg_double_slab.isra.61

$ netperf -H 172.16.0.2 -t TCP_CRR  -l 10 -T5,5 -- -r 1024,1024
MIGRATED TCP Connect/Request/Response TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.16.0.2 () port 0 AF_INET : histogram : demo : cpu bind
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

16384  87380  1024     1024    10.00       1.10   
16384  87380 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
