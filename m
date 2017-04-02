From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 0/3] virtio-net tx napi
Date: Sun,  2 Apr 2017 16:10:09 -0400
Message-ID: <20170402201012.76473-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33976 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751642AbdDBUKQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 16:10:16 -0400
Received: by mail-qt0-f196.google.com with SMTP id x35so16535539qtc.1
        for <netdev@vger.kernel.org>; Sun, 02 Apr 2017 13:10:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add napi for virtio-net transmit completion processing.

Based on previous patchsets by Jason Wang:

  [RFC V7 PATCH 0/7] enable tx interrupts for virtio-net
  http://lkml.iu.edu/hypermail/linux/kernel/1505.3/00245.html

Changes:
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
Processing completions on rx interrupts optimization brings this down,
especially for bi-directional workloads. UDP_STREAM is unidirectional
and continues to see a ~10% lower throughput.

Not showing number for only the optimization patch. That showed no
significant difference with upstream.

             upstream     napi   +at-rx
TCP_STREAM:
1x:
  Mbps          30537    37666    37910
  Gcycles         400      540      405

10x:
  Mbps          41012    39954    40245
  Gcycles         434      546      421

100x:
  Mbps          34088    34172    34245
  Gcycles         435      546      418

TCP_RR Latency (us):
1x:
  p50              24       24       21
  p99              27       27       27
  Gcycles         299      432      308

10x:
  p50              31       31       41
  p99              40       46       52
  Gcycles         346      428      322

100x:
  p50             155      151      310
  p99             334      329      362
  Gcycles         336      421      308

TCP_RR 4K:
1x:
  p50              30       30       27
  p99              34       33       34
  Gcycles         307      437      305

10x:
  p50              63       67       65
  p99              76       77       87
  Gcycles         334      425      315

100x:
  p50             421      497      511
  p99             510      571      773
  Gcycles         350      430      321

UDP_STREAM:
1x:
  Mbps          29802    26360    26608
  Gcycles         305      363      362

10x:
  Mbps          29901    26801    27078
  Gcycles         287      363      360

100x:
  Mbps          29952    26822    27054
  Gcycles         336      351      354

UDP_RR:
1x:
  p50              24       21       19
  p99              27       24       23
  Gcycles         299      431      309

10x:
  p50              31       27       35
  p99              40       35       54
  Gcycles         346      421      325

100x:
  p50             155      153      240
  p99             334      323      462
  Gcycles         336      421      311

UDP_RR 4K:
1x:
  p50              24       25       23
  p99              27       28       30
  Gcycles         299      435      321

10x:
  p50              31       35       48
  p99              40       54       66
  Gcycles         346      451      308

100x:
  p50             155      210      307
  p99             334      451      519
  Gcycles         336      440      297

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

Willem de Bruijn (3):
  virtio-net: napi helper functions
  virtio-net: transmit napi
  virtio-net: clean tx descriptors from rx napi

 drivers/net/virtio_net.c | 150 ++++++++++++++++++++++++++++++++++-------------
 1 file changed, 110 insertions(+), 40 deletions(-)

-- 
2.12.2.564.g063fe858b8-goog
