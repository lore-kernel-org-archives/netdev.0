From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v3 0/5] virtio-net tx napi
Date: Mon, 24 Apr 2017 13:49:25 -0400
Message-ID: <20170424174930.82623-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35561 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S973094AbdDXRte (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 13:49:34 -0400
Received: by mail-qt0-f195.google.com with SMTP id o36so21520953qtb.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 10:49:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add napi for virtio-net transmit completion processing.

Changes:
  v2 -> v3:
    - convert __netif_tx_trylock to __netif_tx_lock on tx napi poll
          ensure that the handler always cleans, to avoid deadlock
    - unconditionally clean in start_xmit
          avoid adding an unnecessary "if (use_napi)" branch
    - remove virtqueue_disable_cb in patch 5/5
          a noop in the common event_idx based loop
    - document affinity_hint_set constraint

  v1 -> v2:
    - disable by default
    - disable unless affinity_hint_set
          because cache misses add up to a third higher cycle cost,
	  e.g., in TCP_RR tests. This is not limited to the patch
	  that enables tx completion cleaning in rx napi.
    - use trylock to avoid contention between tx and rx napi
    - keep interrupts masked during xmit_more (new patch 5/5)
          this improves cycles especially for multi UDP_STREAM, which
	  does not benefit from cleaning tx completions on rx napi.
    - move free_old_xmit_skbs (new patch 3/5)
          to avoid forward declaration

    not changed:
    - deduplicate virnet_poll_tx and virtnet_poll_txclean
          they look similar, but have differ too much to make it
	  worthwhile.
    - delay netif_wake_subqueue for more than 2 + MAX_SKB_FRAGS
          evaluated, but made no difference
    - patch 1/5

  RFC -> v1:
    - dropped vhost interrupt moderation patch:
          not needed and likely expensive at light load
    - remove tx napi weight
        - always clean all tx completions
        - use boolean to toggle tx-napi, instead
    - only clean tx in rx if tx-napi is enabled
        - then clean tx before rx
    - fix: add missing braces in virtnet_freeze_down
    - testing: add 4KB TCP_RR + UDP test results

Based on previous patchsets by Jason Wang:

  [RFC V7 PATCH 0/7] enable tx interrupts for virtio-net
  http://lkml.iu.edu/hypermail/linux/kernel/1505.3/00245.html


Before commit b0c39dbdc204 ("virtio_net: don't free buffers in xmit
ring") the virtio-net driver would free transmitted packets on
transmission of new packets in ndo_start_xmit and, to catch the edge
case when no new packet is sent, also in a timer at 10HZ.

A timer can cause long stalls. VIRTIO_F_NOTIFY_ON_EMPTY avoids stalls
due to low free descriptor count. It does not address a stalls due to
low socket SO_SNDBUF. Increasing timer frequency decreases that stall
time, but increases interrupt rate and, thus, cycle count.

Currently, with no timer, packets are freed only at ndo_start_xmit.
Latency of consume_skb is now unbounded. To avoid a deadlock if a sock
reaches SO_SNDBUF, packets are orphaned on tx. This breaks TCP small
queues.

Reenable TCP small queues by removing the orphan. Instead of using a
timer, convert the driver to regular tx napi. This does not have the
unresolved stall issue and does not have any frequency to tune.

By keeping interrupts enabled by default, napi increases tx
interrupt rate. VIRTIO_F_EVENT_IDX avoids sending an interrupt if
one is already unacknowledged, so makes this more feasible today.
Combine that with an optimization that brings interrupt rate
back in line with the existing version for most workloads:

Tx completion cleaning on rx interrupts elides most explicit tx
interrupts by relying on the fact that many rx interrupts fire.

Tested by running {1, 10, 100} {TCP, UDP} STREAM, RR, 4K_RR benchmarks
from a guest to a server on the host, on an x86_64 Haswell. The guest
runs 4 vCPUs pinned to 4 cores. vhost and the test server are
pinned to a core each.

All results are the median of 5 runs, with variance well < 10%.
Used neper (github.com/google/neper) as test process.

Napi increases single stream throughput, but increases cycle cost.
The optimizations bring this down. The previous patchset saw a
regression with UDP_STREAM, which does not benefit from cleaning tx
interrupts in rx napi. This regression is now gone for 10x, 100x.
Remaining difference is higher 1x TCP_STREAM, lower 1x UDP_STREAM.

The latest results are with process, rx napi and tx napi affine to
the same core. All numbers are lower than the previous patchset.


             upstream     napi
TCP_STREAM:
1x:
  Mbps          27816    39805
  Gcycles         274      285

10x:
  Mbps          42947    42531
  Gcycles         300      296

100x:
  Mbps          31830    28042
  Gcycles         279      269

TCP_RR Latency (us):
1x:
  p50              21       21
  p99              27       27
  Gcycles         180      167

10x:
  p50              40       39
  p99              52       52
  Gcycles         214      211

100x:
  p50             281      241
  p99             411      337
  Gcycles         218      226

TCP_RR 4K:
1x:
  p50              28       29
  p99              34       36
  Gcycles         177      167

10x:
  p50              70       71
  p99              85      134
  Gcycles         213      214

100x:
  p50             442      611
  p99             802      785
  Gcycles         237      216

UDP_STREAM:
1x:
  Mbps          29468    26800
  Gcycles         284      293

10x:
  Mbps          29891    29978
  Gcycles         285      312

100x:
  Mbps          30269    30304
  Gcycles         318      316

UDP_RR:
1x:
  p50              19       19
  p99              23       23
  Gcycles         180      173

10x:
  p50              35       40
  p99              54       64
  Gcycles         245      237

100x:
  p50             234      286
  p99             484      473
  Gcycles         224      214

Note that GSO is enabled, so 4K RR still translates to one packet
per request.

Lower throughput at 100x vs 10x can be (at least in part)
explained by looking at bytes per packet sent (nstat). It likely
also explains the lower throughput of 1x for some variants.

upstream:

 N=1   bytes/pkt=16581
 N=10  bytes/pkt=61513
 N=100 bytes/pkt=51558

at_rx:

 N=1   bytes/pkt=65204
 N=10  bytes/pkt=65148
 N=100 bytes/pkt=56840

Willem de Bruijn (5):
  virtio-net: napi helper functions
  virtio-net: transmit napi
  virtio-net: move free_old_xmit_skbs
  virtio-net: clean tx descriptors from rx napi
  virtio-net: keep tx interrupts disabled unless kick

 drivers/net/virtio_net.c | 193 ++++++++++++++++++++++++++++++++---------------
 1 file changed, 132 insertions(+), 61 deletions(-)

-- 
2.12.2.816.g2cccc81164-goog
