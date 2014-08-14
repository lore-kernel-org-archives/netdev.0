From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 11:19:23 -0700
Message-ID: <53ECFDAB.5010701@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51643 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753344AbaHNSTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 14:19:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yesterday I tripped over a bit of an issue and it seems like we are
seeing significant cache thrash on kernels 3.10 and newer when running
multiple streams of small packet stress on multiple NUMA nodes for a
single NIC.

I did some bisection and found that I was able to trace it back to
upstream commit 093162553c33e9479283e107b4431378271c735d (tcp: force a
dst refcount when prequeue packet).

Recreating this issue is pretty strait forward.  All I did was setup 2
dual socket Xeon systems connected back to back with ixgbe and ran the
following script after disabling tcp_autocork on the transmitting system:
  for i in `seq 0 19`
  do
    for j in `seq 0 2`
    do
      netperf -H 192.168.10.1 -t TCP_STREAM \
              -l 10 -c -C -T $i,$i -P 0 -- \
              -m 64 -s 64K -D
    done
  done

The current net tree as-is will give me about 2Gb/s of data w/ 100% CPU
utilization on the receiving system, and with the patch above reverted
on that system it gives me about 4Gb/s with only 21% CPU utilization.
If I set tcp_low_latency=1 I can get the CPU utilization down to about
12% on the same test with about 4Gb/s of throughput.

I'm still working on determining the exact root cause but it looks to me
like there is some significant cache thrash going on in regards to the
dst entries.

Below is a quick breakdown of the top CPU users for tcp_low_latency
on/off using perf top:

tcp_low_latency = 0
 36.49%  [kernel]                [k] ipv4_dst_check
 19.45%  [kernel]                [k] dst_release
 16.07%  [kernel]                [k] _raw_spin_lock
  9.84%  [kernel]                [k] tcp_prequeue
  2.13%  [kernel]                [k] tcp_v4_rcv
  1.38%  [kernel]                [k] memcpy
  1.04%  [ixgbe]                 [k] ixgbe_clean_rx_irq
  0.82%  [kernel]                [k] ip_rcv_finish
  0.54%  [kernel]                [k] dev_gro_receive
  0.51%  [kernel]                [k] build_skb
  0.51%  [kernel]                [k] __netif_receive_skb_core
  0.50%  [kernel]                [k] tcp_rcv_established
  0.46%  [kernel]                [k] sock_def_readable
  0.42%  [kernel]                [k] __slab_free
  0.38%  [kernel]                [k] __inet_lookup_established
  0.36%  [kernel]                [k] ip_rcv
  0.34%  [kernel]                [k] copy_user_enhanced_fast_string
  0.30%  [kernel]                [k] __netdev_alloc_frag
  0.29%  [kernel]                [k] kmem_cache_alloc
  0.27%  [kernel]                [k] inet_gro_receive
  0.25%  [kernel]                [k] put_compound_page
  0.24%  [kernel]                [k] tcp_v4_do_rcv
  0.24%  [kernel]                [k] napi_gro_receive
  0.22%  [kernel]                [k] tcp_event_data_recv
  0.20%  [kernel]                [k] tcp_gro_receive
  0.17%  [kernel]                [k] tcp_v4_early_demux
  0.16%  [kernel]                [k] kmem_cache_free
  0.14%  [ixgbe]                 [k] ixgbe_poll
  0.14%  [kernel]                [k] eth_type_trans
  0.13%  [kernel]                [k] tcp_prequeue_process
  0.13%  [kernel]                [k] tcp_send_delayed_ack
  0.13%  [kernel]                [k] mod_timer
  0.12%  [kernel]                [k] skb_copy_datagram_iovec
  0.12%  [kernel]                [k] irq_entries_start
  0.12%  [kernel]                [k] inet_ehashfn
  0.12%  [kernel]                [k] __tcp_ack_snd_check
  0.12%  [ixgbe]                 [k] ixgbe_xmit_frame_ring

tcp_low_latency = 1
  7.77%  [kernel]                 [k] memcpy
  6.13%  [ixgbe]                  [k] ixgbe_clean_rx_irq
  3.54%  [kernel]                 [k] skb_try_coalesce
  3.22%  [kernel]                 [k] dev_gro_receive
  3.21%  [kernel]                 [k] tcp_v4_rcv
  2.91%  [kernel]                 [k] __netif_receive_skb_core
  2.64%  [kernel]                 [k] build_skb
  2.59%  [kernel]                 [k] acpi_processor_ffh_cstate_enter
  2.53%  [kernel]                 [k] sock_def_readable
  2.26%  [kernel]                 [k] _raw_spin_lock
  2.20%  [kernel]                 [k] tcp_rcv_established
  2.07%  [kernel]                 [k] __inet_lookup_established
  1.95%  [kernel]                 [k] ip_rcv
  1.82%  [kernel]                 [k] kmem_cache_free
  1.76%  [kernel]                 [k] copy_user_enhanced_fast_string
  1.56%  [kernel]                 [k] tcp_try_coalesce
  1.53%  [kernel]                 [k] __netdev_alloc_frag
  1.53%  [kernel]                 [k] inet_gro_receive
  1.51%  [kernel]                 [k] napi_gro_receive
  1.29%  [kernel]                 [k] kmem_cache_alloc
  1.18%  [kernel]                 [k] tcp_gro_receive
  1.09%  [kernel]                 [k] put_compound_page
  0.98%  [kernel]                 [k] ip_local_deliver_finish
  0.97%  [kernel]                 [k] tcp_send_delayed_ack
  0.95%  [kernel]                 [k] tcp_event_data_recv
  0.90%  [kernel]                 [k] inet_ehashfn
  0.88%  [kernel]                 [k] ip_rcv_finish
  0.78%  [kernel]                 [k] tcp_v4_do_rcv
  0.77%  [kernel]                 [k] tcp_v4_early_demux
  0.76%  [kernel]                 [k] __switch_to
  0.76%  [kernel]                 [k] eth_type_trans
  0.75%  [kernel]                 [k] tcp_queue_rcv
  0.74%  [kernel]                 [k] __schedule
  0.72%  [kernel]                 [k] skb_copy_datagram_iovec
  0.71%  [ixgbe]                  [k] ixgbe_xmit_frame_ring
  0.68%  [kernel]                 [k] __tcp_ack_snd_check
  0.68%  [ixgbe]                  [k] ixgbe_poll
  0.67%  [kernel]                 [k] mod_timer
  0.64%  [kernel]                 [k] lapic_next_deadline

Any input/advice on where I should look or patches to possibly test
would be appreciated.

Thanks,

Alex
