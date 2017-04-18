From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 0/5] virtio-net tx napi
Date: Tue, 18 Apr 2017 16:21:03 -0400
Message-ID: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34966 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752809AbdDRUVL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 16:21:11 -0400
Received: by mail-qk0-f195.google.com with SMTP id k139so637475qke.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 13:21:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add napi for virtio-net transmit completion processing.

Changes:
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
  Mbps          28985    34492
  Gcycles         278      269

10x:
  Mbps          42267    42420
  Gcycles         301      303

100x:
  Mbps          29710    31131
  Gcycles         286      282

TCP_RR Latency (us):
1x:
  p50              22       21
  p99              27       26
  Gcycles         176      171

10x:
  p50              40       40
  p99              51       51
  Gcycles         215      211

100x:
  p50             272      235
  p99             414      360
  Gcycles         228      233

TCP_RR 4K:
1x:
  p50              27       29
  p99              34       36
  Gcycles         184      170

10x:
  p50              67       66
  p99              82       82
  Gcycles         217      218

100x:
  p50             435      485
  p99             813      626
  Gcycles         242      226

UDP_STREAM:
1x:
  Mbps          29802    25600
  Gcycles         305      295

10x:
  Mbps          29901    29684
  Gcycles         287      295

100x:
  Mbps          29952    29863
  Gcycles         336      325

UDP_RR:
1x:
  p50              18       18
  p99              23       22
  Gcycles         183      181

10x:
  p50              35       38
  p99              54       62
  Gcycles         252      236

100x:
  p50             240      279
  p99             462      519
  Gcycles         228      219

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

 drivers/net/virtio_net.c | 211 +++++++++++++++++++++++++++++++++--------------
 1 file changed, 150 insertions(+), 61 deletions(-)

-- 
2.12.2.816.g2cccc81164-goog
