From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC 0/4] virtio-net tx napi
Date: Mon, 6 Mar 2017 21:44:01 +0200
Message-ID: <20170306213857-mutt-send-email-mst@kernel.org>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jasowang@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41884 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932676AbdCFToP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 14:44:15 -0500
Content-Disposition: inline
In-Reply-To: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 03, 2017 at 09:39:05AM -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Add napi for virtio-net transmit completion processing. Based on
> previous patchsets by Jason Wang:
> 
>   [RFC V7 PATCH 0/7] enable tx interrupts for virtio-net
>   http://lkml.iu.edu/hypermail/linux/kernel/1505.3/00245.html
> 
> This patchset is not ready for submission yet, but it is time for
> another checkpoint. Among others, it requires more testing with
> more diverse workloads.
> 
> 
> Before commit b0c39dbdc204 ("virtio_net: don't free buffers in xmit
> ring") the virtio-net driver would free transmitted packets on
> transmission of new packets in ndo_start_xmit and, to catch the edge
> case when no new packet is sent, also in a timer at 10HZ.
> 
> A timer can cause long stalls. VIRTIO_F_NOTIFY_ON_EMPTY avoids stalls
> due to low free descriptor count. It does not address a stalls due to
> low socket SO_SNDBUF. Increasing timer frequency decreases that stall
> time, but increases interrupt rate and, thus, cycle count.
> 
> Currently, with no timer, packets are freed only at ndo_start_xmit.
> Latency of consume_skb is now unbounded. To avoid a deadlock if a sock
> reaches SO_SNDBUF, packets are orphaned on tx. This breaks TCP small
> queues.
> 
> Reenable TCP small queues by removing the orphan. Instead of using a
> timer, convert the driver to regular tx napi. This does not have the
> unresolved stall issue and does not have any frequency to tune.
> 
> By keeping interrupts enabled by default, napi increases tx
> interrupt rate. VIRTIO_F_EVENT_IDX avoids sending an interrupt if
> one is already unacknowledged, so makes this more feasible today.
> Combine that with two optimizations that bring interrupt rate
> back in line with the existing code:
> 
> Interrupt coalescing delays interrupts until a number of events
> accrue or a timer fires.
> 
> Tx completion cleaning on rx interrupts elides most explicit tx
> interrupts by relying on the fact that many rx interrupts fire.
> 
> Tested by running {1, 10, 100} TCP_STREAM and TCP_RR tests from a
> guest to a server on the host, on an x86_64 Haswell. The guest
> runs 4 vCPUs pinned to 4 cores. vhost and the test server are
> pinned to a core each.
> 
> All results are the median of 5 runs, with variance well < 10%.
> Used neper (github.com/google/neper) as test process. Tests used
> experimental_zcopy=0. This is likely no longer needed.
> 
> Napi increases single stream throughput, but increases cycle cost
> across the board. Interrupt moderation ("+vhost") reverts both, if
> not fully. For this workload with ACKs in the return path, the
> last optimization ("at-rx") is more effective. For UDP this is
> likely not true.

I am inclined to say coalescing is more problematic because under light
load it causes timers to fire on host, causing exits if any VM is
running on the same core. Some people might have spare cores, etc,
but generally I think at-rx might be less disruptive.

UDP testing would be required to determine how effective it is,
current numbers look nice.

>              upstream     napi   +vhost   +at-rx +v+at-rx
> Stream:
>   1x:
>   Mbps          30182    38782    30106    38002    32842
>   Gcycles         405      499      386      403      417        
> 
>   10x:
>   Mbps          40441    40575    41638    40260    41299
>   Gcycles         438      545      430      416      416
> 
>   100x:
>   Mbps          34049    34697    34763    34637    34259
>   Gcycles         441      545      433      415      422
> 
> Latency (us):
>   1x:
>   p50              24       24       24       21       24
>   p99              27       27       27       26       27
>   Gcycles         299      430      432      312      297
> 
> 10x:
>   p50              30       31       31       42       31
>   p99              40       46       48       52       42
>   Gcycles         347      423      471      322      463
> 
> 100x:
>   p50             155      151      163      306      161
>   p99             337      329      352      361      349
>   Gcycles         340      421      463      306      441
> 
> 
> Lower throughput at 100x vs 10x can be (at least in part)
> explained by looking at bytes per packet sent (nstat). It likely
> also explains the lower throughput of 1x for some variants.
> 
> upstream:
> 
>  N=1   bytes/pkt=16581
>  N=10  bytes/pkt=61513
>  N=100 bytes/pkt=51558
> 
> at_rx:
> 
>  N=1   bytes/pkt=65204
>  N=10  bytes/pkt=65148
>  N=100 bytes/pkt=56840
> 
> For this experiment, vhost has 64 frames and usecs thresholds.
> Configuring this from the guest requires additional patches to qemu.
> Temporary patch:
> 
>   @@ -846,9 +845,6 @@ static int vhost_net_open(struct inode *inode, struct file *f)
>           vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
>           vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
>  
>   -       vqs[VHOST_NET_VQ_TX]->max_coalesce_ktime = ktime_set(0, 64 * NSEC_PER_USEC);
>   -       vqs[VHOST_NET_VQ_TX]->max_coalesce_frames = 64;
>   -
>           f->private_data = n;
> 
> TODO
>  - restart timer if trylock failed and lock not held by hande_tx
>    - start timer only at end of handle_tx and kill at start
>  - make napi_tx configurable
>  - increase test coverage
>    - 4KB TCP_RR
>    - UDP
>    - multithreaded sender
>    - with experimental_zcopytx
> 
> 
> Willem de Bruijn (4):
>   virtio-net: napi helper functions
>   virtio-net: transmit napi
>   vhost: interrupt coalescing support
>   virtio-net: clean tx descriptors from rx napi
> 
>  drivers/net/virtio_net.c   | 157 +++++++++++++++++++++++++++++++++------------
>  drivers/vhost/vhost.c      |  74 ++++++++++++++++++++-
>  drivers/vhost/vhost.h      |  12 ++++
>  include/uapi/linux/vhost.h |  11 ++++
>  4 files changed, 211 insertions(+), 43 deletions(-)
> 
> -- 
> 2.12.0.rc1.440.g5b76565f74-goog
