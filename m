From: Jesper Dangaard Brouer <netdev@brouer.com>
Subject: Re: [PATCH 1/7] net: refactor __netif_receive_skb_core
Date: Wed, 15 Apr 2015 18:09:27 +0200
Message-ID: <20150415180927.4592eb6e@brouer.com>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
	<1428668142-4006-2-git-send-email-pablo@netfilter.org>
	<5527D476.6030306@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <5527D476.6030306@iogearbox.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Apr 2015 15:47:34 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 04/10/2015 02:15 PM, Pablo Neira Ayuso wrote:
> > This patch splits __netif_receive_skb_core() in smaller functions to improve
> > maintainability.
> >
> > The function __netif_receive_skb_core() has been split in two:
> >
> > * __netif_receive_skb_ingress(), to perform all actions up to
> >    ingress filtering.
> >
> > * __netif_receive_skb_finish(), if the ingress filter accepts this
> >    packet, pass it to the corresponding packet_type function handler for further
> > processing.
> >
> > This patch also adds __NET_RX_ANOTHER_ROUND that is used when the packet is
> > stripped off from the vlan header or in case the rx_handler needs it.
> >
> > This also prepares the introduction of the netfilter ingress hook.
> 
> Out of curiosity, what is actually the performance impact on all
> of this? We were just arguing on a different matter on two more
> instructions in the fast-path, here it's refactoring the whole
> function into several ones, I presume gcc won't inline it.

Pablo asked me to performance test this change.  Full test report below.

The performance effect (of this patch) depend on the Gcc compiler
version.

Two tests:
 1. IP-forwarding (unloaded netfilter modules)
 2. Early drop in iptables "raw" table

With GCC 4.4.7, which does not inline the new functions
(__netif_receive_skb_ingress and __netif_receive_skb_finish) the
performance impact/regression is definitly measurable.

With GCC 4.4.7:
 1. IP-forwarding: +25.18 ns (slower) (-27776 pps)
 2. Early-drop   :  +7.55 ns (slower) (-66577 pps)

With GCC 4.9.1, the new functions gets inlined, thus the refactor
splitup of __netif_receive_skb_core() is basically "cancled".
Strangly there is a small improvement for forwarding, likely due to
some lucky assember reordering that give less icache/fetch-misses.
The early-drop improvement is below accuracy levels, can cannot be
trusted.

With GCC 4.9.1:
 1. IP-forwarding: -10.05ns (faster) (+17532 pps)
 2. Early-drop   :  -1.54ns (faster) (+16216 pps) below accuracy levels

I don't know what to conclude, as the result depend on the compiler
version... but these kind of change do affect performance, and should
be tested/measured.

- --
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

Quick eval of Pablo's refactor of __netif_receive_skb_core
==========================================================
:Version: 0.1
:Author:  Jesper Dangaard Brouer

Summary
=======

Pablo is refactoring __netif_receive_skb_core() into several
functions, to allow for some other upcomming changes.
Daniel Borkmann question if this will affect performance.
Jesper tests this.

The performance effect (of this patch) depend on the Gcc compiler
version.

Two tests:
 1. IP-forwarding (unloaded netfilter modules)
 2. Early drop in iptables "raw" table

With GCC 4.4.7, which does not inline the new functions
(__netif_receive_skb_ingress and __netif_receive_skb_finish) the
performance impact/regression is definitly measurable.

With GCC 4.4.7:
 1. IP-forwarding: +25.18 ns (slower) (-27776 pps)
 2. Early-drop   :  +7.55 ns (slower) (-66577 pps)

With GCC 4.9.1, the new functions gets inlined, thus the refactor
splitup of __netif_receive_skb_core() is basically "cancled".
Strangly there is a small improvement for forwarding, likely due to
some lucky assember reordering that give less icache/fetch-misses.
The early-drop improvement is below accuracy levels, can cannot be
trusted.

With GCC 4.9.1:
 1. IP-forwarding: -10.05ns (faster) (+17532 pps)
 2. Early-drop   :  -1.54ns (faster) (+16216 pps) below accuracy levels


Setup
=====

On host: ivy
------------

Host ivy is the "sink" or DUT (Device Under Test).
 * CPU E5-2695ES @ 2.80GHz

netfilter_unload_modules.sh
netfilter_unload_modules.sh
sudo rmmod nf_reject_ipv4 nf_reject_ipv6

base_device_setup.sh eth4  # 10G sink/receiving interface (ixgbe)
base_device_setup.sh eth5
sudo ethtool --coalesce eth4 rx-usecs 30

Make a fake route to 198.18.0.0/15 out via eth5

sudo ip neigh add 192.168.21.66 dev eth5 lladdr 00:00:ba:d0:ba:d0
sudo ip route add 198.18.0.0/15 via 192.168.21.66 dev eth5

Disable power saving to get more accurate measurements (see blogpost)::

 $ sudo tuned-adm active
 Current active profile: latency-performance
 Service tuned: enabled, running
 Service ktune: enabled, running

Early drop in raw
-----------------

alias iptables='sudo iptables'
iptables -t raw -N simple || iptables -t raw -F simple
iptables -t raw -I simple -d 198.18.0.0/15 -j DROP
iptables -t raw -D PREROUTING -j simple
iptables -t raw -I PREROUTING -j simple


On host: dragon
---------------

Host dragon is the packet generator.
 * 2x CPU E5-2630 0 @ 2.30GHz

Generator NIC: eth8 - ixgbe 10G

netfilter_unload_modules.sh
netfilter_unload_modules.sh
sudo rmmod nf_reject_ipv4 nf_reject_ipv6

base_device_setup.sh eth8  # 10G generator interface (ixgbe)
sudo ethtool --coalesce eth8 rx-usecs 30

Generator
~~~~~~~~~
Generator command::

 ./pktgen02_burst.sh -d 198.18.0.2 -i eth8 -m 90:E2:BA:0A:56:B4 -b 32 -s 64 -t 4

This will gen approx 12Mpps towards single IP, thus single flow.

Notice this single flow, one activates 1-CPU on target host.  This is
on purpose.


Baseline measurements
=====================

Kernel: 4.0.0-rc7-net-next-01881-ge60a9de
 - Thus, kernel at commit e60a9de49c3 ("Merge branch ...jkirsher/next-queue")

Two compiler versions:
 * gcc version 4.4.7 20120313 (Red Hat 4.4.7-11) (GCC)
  - (This results in slower kernel)
 * gcc version 4.9.1 20140922 (Red Hat 4.9.1-10) (GCC)


Forwarding
----------

IP-forward, single flow:
 * Gcc 4.4.7
  - Run01: instant rx:0 tx:1064064 pps n:100 average: rx:0 tx:1064066 pps
    (instant variation TX -0.002 ns (min:-0.431 max:0.171) RX 0.000 ns)

IP-forward, single flow:
 * Gcc 4.9.1 <-- **NOTICE GCC version**
  - Run02: instant rx:0 tx:1312000 pps n:96 average: rx:0 tx:1311854 pps
    (instant variation TX 0.085 ns (min:-0.359 max:1.331) RX 0.000 ns)
  - Run03: instant rx:0 tx:1311168 pps n:106 average: rx:0 tx:1310818 pps
    (instant variation TX 0.203 ns (min:-0.593 max:0.512) RX 0.000 ns)


Early drop
----------

Early drop iptables raw, single flow:
 * Gcc 4.4.7
  - Run01: instant rx:3003072 tx:0 pps n:300 average: rx:3002243 tx:0 pps
    (instant variation TX 0.000 ns (min:0.000 max:0.000) RX 0.092 ns)

Early drop iptables raw, single flow:
 * Gcc 4.9.1 <-- **NOTICE GCC version**
  - Run02: instant rx:3233600 tx:0 pps n:83 average: rx:3233151 tx:0 pps
    (instant variation TX 0.000 ns (min:0.000 max:0.000) RX 0.043 ns)

Change measurement
==================

Performance test for Pablo of patch:
 * http://patchwork.ozlabs.org/patch/460069/

Pablo is refactoring __netif_receive_skb_core() into several
functions, to allow for some other upcomming changes.

Daniel Borkmann question if this will affect performance.

Kernel: 4.0.0-rc7-pablo01-refactor--netif_receive_skb_core+
 * on top of commit e60a9de49c3 ("Merge branch ...jkirsher/next-queue")

Forwarding
----------

IP-forward, single flow:
 * Gcc 4.4.7
  - Run01: instant rx:0 tx:1034236 pps n:74 average: rx:0 tx:1034824 pps
    (instant variation TX -0.550 ns (min:-1.577 max:0.224) RX 0.000 ns)
  - Run02: instant rx:0 tx:1036292 pps n:60 average: rx:0 tx:1036290 pps
    (instant variation TX 0.001 ns (min:-0.271 max:0.259) RX 0.000 ns)
 * (Gcc 4.4.7) compare against baseline (run01 vs run02)
  - 1036290 - 1064066 = -27776 pps (slower)
  - (1/1036290*10^9)-(1/1064066*10^9) = +25.18 ns (slower)

IP-forward, single flow:
 * Gcc 4.9.1  <-- **NOTICE GCC version**
  - Run01: instant rx:0 tx:1335676 pps n:60 average: rx:0 tx:1335773 pps
    (instant variation TX -0.055 ns (min:-0.163 max:0.126) RX 0.000 ns)
  - Run02: instant rx:0 tx:1328708 pps n:80 average: rx:0 tx:1329386 pps
    (instant variation TX -0.384 ns (min:-1.298 max:0.316) RX 0.000 ns)
   * run01 vs run02 variance:
    - (1/1335773*10^9) - (1/1329386*10^9) = -3.5967 ns
 * (Gcc 4.9.1) compare against baseline(Run02) vs this Run02
  - 1329386 - 1311854 = +17532 pps (faster)
  - (1/1329386*10^9) - (1/1311854*10^9) = -10.05ns (faster)


Early drop
----------

Early drop iptables raw, single flow:
 * Gcc 4.4.7
  - Run01: instant rx:2942528 tx:0 pps n:91 average: rx:2940013 tx:0 pps
    (instant variation TX 0.000 ns (min:0.000 max:0.000) RX 0.291 ns)
  - Run02: instant rx:2929280 tx:0 pps n:120 average: rx:2935666 tx:0 pps
    (instant variation TX 0.000 ns (min:0.000 max:0.000) RX -0.743 ns)
 * (Gcc 4.4.7) compare against baseline (run01 vs run02)
  - 2935666 - 3002243 = -66577 pps (slower)
  - (1/2935666*10^9) - (1/3002243*10^9) = +7.55 ns (slower)

My theory behind why IP-forwarding shows larger impact/regression is
that IP-forwarding cause more icache misses, and these function splits
is also more expensive instruction icache fetch wise.

Early drop iptables raw, single flow:
 * Gcc 4.9.1 <-- **NOTICE GCC version**
  - Run01: instant rx:3249280 tx:0 pps n:140 average: rx:3249367 tx:0 pps
    (instant variation TX 0.000 ns (min:0.000 max:0.000) RX -0.008 ns)
 * (Gcc 4.9.1) compare against baseline(Run02) vs this Run02
  - 3249367 - 3233151 = +16216 pps (faster)
  - (1/3249367*10^9) - (1/3233151*10^9) = -1.54ns (faster)


In perf top below, notice __netif_receive_skb_finish,
__netif_receive_skb_ingress and __netif_receive_skb_core, are seperate
functions, thus not inlined by Gcc 4.4.7. (early-drop test)

Perf top::

 Samples:: 218K of event 'cycles', Event count (approx.): 43758793383
 Overhead  Shared Object        Symbol
   8.59%  [ip_tables]          [k] ipt_do_table
   6.45%  [kernel]             [k] build_skb
   5.62%  [ixgbe]              [k] ixgbe_fetch_rx_buffer
   5.55%  [kernel]             [k] ip_rcv
   5.31%  [ixgbe]              [k] ixgbe_clean_rx_irq
   4.64%  [kernel]             [k] __netif_receive_skb_finish
   4.28%  [kernel]             [k] dev_gro_receive
   3.76%  [kernel]             [k] inet_gro_receive
   3.30%  [kernel]             [k] kmem_cache_alloc
   3.09%  [kernel]             [k] __rcu_read_unlock
   2.85%  [kernel]             [k] put_compound_page
   2.80%  [kernel]             [k] __memcpy
   2.67%  [kernel]             [k] nf_iterate
   2.49%  [kernel]             [k] nf_hook_slow
   2.43%  [kernel]             [k] __netif_receive_skb_ingress
   2.09%  [kernel]             [k] udp4_gro_receive
   2.04%  [kernel]             [k] kmem_cache_free
   2.03%  [ixgbe]              [k] ixgbe_process_skb_fields
   1.99%  [kernel]             [k] __local_bh_enable_ip
   1.99%  [kernel]             [k] __rcu_read_lock
   1.82%  [kernel]             [k] __netif_receive_skb_core


Total usage of modified functions::

   4.64%  [kernel]             [k] __netif_receive_skb_finish
   2.43%  [kernel]             [k] __netif_receive_skb_ingress
   1.82%  [kernel]             [k] __netif_receive_skb_core
   ---------------
   8.89%

Perf top of same early-drop workload with Gcc 4.9.1. Notice
__netif_receive_skb_core(8.16%) have other functions inlined.

Samples: 221K of event 'cycles', Event count (approx.): 44134618001
Overhead  Shared Object        Symbol
  11.45%  [ixgbe]              [k] ixgbe_clean_rx_irq
   9.55%  [ip_tables]          [k] ipt_do_table
   8.35%  [kernel]             [k] build_skb
   8.16%  [kernel]             [k] __netif_receive_skb_core
   7.44%  [kernel]             [k] ip_rcv
   6.69%  [kernel]             [k] dev_gro_receive
   3.38%  [kernel]             [k] __memcpy
   3.37%  [kernel]             [k] put_compound_page
   3.33%  [kernel]             [k] inet_gro_receive
   2.84%  [kernel]             [k] __rcu_read_unlock
   2.66%  [kernel]             [k] udp4_gro_receive
   2.47%  [kernel]             [k] kmem_cache_alloc
   2.41%  [kernel]             [k] nf_iterate
   2.19%  [kernel]             [k] eth_type_trans
   2.15%  [kernel]             [k] nf_hook_slow
   2.09%  [kernel]             [k] kmem_cache_free
   1.94%  [kernel]             [k] skb_free_head
   1.82%  [kernel]             [k] __local_bh_enable_ip
   1.78%  [kernel]             [k] __rcu_read_lock
   1.70%  [kernel]             [k] udp_gro_receive
   1.59%  [kernel]             [k] skb_release_data
   1.08%  [kernel]             [k] __alloc_page_frag
   1.06%  [kernel]             [k] __alloc_rx_skb
   0.91%  [kernel]             [k] __napi_alloc_skb
   0.83%  [kernel]             [k] skb_release_head_state
   0.75%  [kernel]             [k] napi_gro_receive
   0.66%  [kernel]             [k] skb_release_all
   0.64%  [kernel]             [k] kfree_skb
   0.63%  [ixgbe]              [k] ixgbe_alloc_rx_buffers
   0.55%  [kernel]             [k] __netif_receive_skb

