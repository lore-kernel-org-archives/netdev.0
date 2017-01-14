From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: 4.9 conntrack performance issues
Date: Sun, 15 Jan 2017 01:05:58 +0200
Message-ID: <1a71d807acf63135bb037c7144fcd8d9@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Guillaume Nault <g.nault@alphalink.fr>,
        Netfilter Devel <netfilter-devel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:49812 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750721AbdANXGC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Jan 2017 18:06:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Sorry if i added someone wrongly to CC, please let me know, if i should 
remove.
I just run successfully 4.9 on my nat several days ago, and seems panic 
issue disappeared. But i started to face another issue, it seems garbage 
collector is hogging one of CPU's.

Here is my data:
2xE5-2640 v3
396G ram
2x10G (bonding) with approx 14-15G load at peak time
It was handling load very well at 4.8 and below, it might be still fine, 
but i suspect queues that belong to hogged cpu might experience issues.
Is there anything can be done to improve cpu load distribution or reduce 
single core load?

net.netfilter.nf_conntrack_buckets = 65536
net.netfilter.nf_conntrack_checksum = 1
net.netfilter.nf_conntrack_count = 1236021
net.netfilter.nf_conntrack_events = 1
net.netfilter.nf_conntrack_expect_max = 1024
net.netfilter.nf_conntrack_generic_timeout = 600
net.netfilter.nf_conntrack_helper = 0
net.netfilter.nf_conntrack_icmp_timeout = 30
net.netfilter.nf_conntrack_log_invalid = 0
net.netfilter.nf_conntrack_max = 6553600
net.netfilter.nf_conntrack_tcp_be_liberal = 0
net.netfilter.nf_conntrack_tcp_loose = 0
net.netfilter.nf_conntrack_tcp_max_retrans = 3
net.netfilter.nf_conntrack_tcp_timeout_close = 10
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 10
net.netfilter.nf_conntrack_tcp_timeout_established = 600
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 20
net.netfilter.nf_conntrack_tcp_timeout_last_ack = 20
net.netfilter.nf_conntrack_tcp_timeout_max_retrans = 60
net.netfilter.nf_conntrack_tcp_timeout_syn_recv = 10
net.netfilter.nf_conntrack_tcp_timeout_syn_sent = 20
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 20
net.netfilter.nf_conntrack_tcp_timeout_unacknowledged = 30
net.netfilter.nf_conntrack_timestamp = 0
net.netfilter.nf_conntrack_udp_timeout = 30
net.netfilter.nf_conntrack_udp_timeout_stream = 180
net.nf_conntrack_max = 6553600


it is non-peak values, as adjustments i have shorter than default 
timeouts. Changing net.netfilter.nf_conntrack_buckets to higher value 
doesn't fix issue.
I noticed that one of CPU's hogged (N24 in this case):

Linux 4.9.2-build-0127 (NAT)	01/14/17	_x86_64_	(32 CPU)

23:01:54     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal 
  %guest   %idle
23:02:04     all    0.09    0.00    1.60    0.01    0.00   28.28    0.00 
    0.00   70.01
23:02:04       0    0.11    0.00    0.00    0.00    0.00   32.38    0.00 
    0.00   67.51
23:02:04       1    0.12    0.00    0.12    0.00    0.00   29.91    0.00 
    0.00   69.86
23:02:04       2    0.23    0.00    0.11    0.00    0.00   29.57    0.00 
    0.00   70.09
23:02:04       3    0.11    0.00    0.11    0.11    0.00   28.80    0.00 
    0.00   70.86
23:02:04       4    0.23    0.00    0.11    0.11    0.00   31.41    0.00 
    0.00   68.14
23:02:04       5    0.11    0.00    0.00    0.00    0.00   29.28    0.00 
    0.00   70.61
23:02:04       6    0.11    0.00    0.11    0.00    0.00   31.81    0.00 
    0.00   67.96
23:02:04       7    0.11    0.00    0.11    0.00    0.00   32.69    0.00 
    0.00   67.08
23:02:04       8    0.00    0.00    0.23    0.00    0.00   42.12    0.00 
    0.00   57.64
23:02:04       9    0.11    0.00    0.00    0.00    0.00   30.86    0.00 
    0.00   69.02
23:02:04      10    0.11    0.00    0.11    0.00    0.00   30.93    0.00 
    0.00   68.84
23:02:04      11    0.00    0.00    0.11    0.00    0.00   32.73    0.00 
    0.00   67.16
23:02:04      12    0.11    0.00    0.11    0.00    0.00   29.85    0.00 
    0.00   69.92
23:02:04      13    0.00    0.00    0.00    0.00    0.00   30.96    0.00 
    0.00   69.04
23:02:04      14    0.00    0.00    0.00    0.00    0.00   30.09    0.00 
    0.00   69.91
23:02:04      15    0.00    0.00    0.11    0.00    0.00   30.63    0.00 
    0.00   69.26
23:02:04      16    0.11    0.00    0.00    0.00    0.00   25.88    0.00 
    0.00   74.01
23:02:04      17    0.11    0.00    0.00    0.00    0.00   22.82    0.00 
    0.00   77.07
23:02:04      18    0.11    0.00    0.00    0.00    0.00   23.75    0.00 
    0.00   76.14
23:02:04      19    0.11    0.00    0.11    0.00    0.00   24.86    0.00 
    0.00   74.92
23:02:04      20    0.11    0.00    0.11    0.11    0.00   24.48    0.00 
    0.00   75.19
23:02:04      21    0.22    0.00    0.11    0.00    0.00   23.43    0.00 
    0.00   76.24
23:02:04      22    0.11    0.00    0.11    0.00    0.00   25.46    0.00 
    0.00   74.32
23:02:04      23    0.00    0.00    0.11    0.00    0.00   25.47    0.00 
    0.00   74.41
23:02:04      24    0.00    0.00   45.06    0.00    0.00   42.18    0.00 
    0.00   12.76
23:02:04      25    0.11    0.00    0.11    0.11    0.00   25.22    0.00 
    0.00   74.46
23:02:04      26    0.11    0.00    0.00    0.11    0.00   23.39    0.00 
    0.00   76.39
23:02:04      27    0.22    0.00    0.11    0.00    0.00   23.83    0.00 
    0.00   75.85
23:02:04      28    0.11    0.00    0.11    0.00    0.00   24.10    0.00 
    0.00   75.68
23:02:04      29    0.11    0.00    0.11    0.00    0.00   23.80    0.00 
    0.00   75.98
23:02:04      30    0.11    0.00    0.11    0.00    0.00   23.45    0.00 
    0.00   76.33
23:02:04      31    0.11    0.00    0.11    0.00    0.00   20.37    0.00 
    0.00   79.42

And this is output of ./perf top -C 24 -e cycles

    PerfTop:     933 irqs/sec  kernel:100.0%  exact:  0.0% [1000Hz 
cycles],  (all, CPU: 24)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

     52.68%  [nf_conntrack]  [k] gc_worker
      3.88%  [ip_tables]     [k] ipt_do_table
      2.39%  [ixgbe]         [k] ixgbe_xmit_frame_ring
      2.29%  [kernel]        [k] _raw_spin_lock
      1.84%  [ixgbe]         [k] ixgbe_poll
      1.76%  [nf_conntrack]  [k] __nf_conntrack_find_get

perf report for this cpu (same, cycles)
# Children      Self  Command       Shared Object           Symbol
# ........  ........  ............  ......................  
....................................................
#
     88.98%     0.00%  kworker/24:1  [kernel.kallsyms]       [k] 
process_one_work
             |
             ---process_one_work
                |
                |--54.65%--gc_worker
                |          |
                |           --3.58%--nf_ct_gc_expired
                |                     |
                |                     |--1.90%--nf_ct_delete
                |                     |          |
                |                     |           
--1.31%--nf_ct_delete_from_lists
                |                     |
                |                      --1.61%--nf_conntrack_destroy
                |                                destroy_conntrack
                |                                |
                |                                 
--1.53%--nf_conntrack_free
                |                                           |
                |                                           
|--0.80%--kmem_cache_free
                |                                           |          |
                |                                           |           
--0.51%--__slab_free.isra.12
                |                                           |
                |                                            
--0.52%--__nf_ct_ext_destroy
