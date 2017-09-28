From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next] vhost_net: do not stall on zerocopy depletion
Date: Wed, 27 Sep 2017 20:25:56 -0400
Message-ID: <20170928002556.41240-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, mst@redhat.com, jasowang@redhat.com,
        den@klaipeden.com, virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:51793 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752402AbdI1A04 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 20:26:56 -0400
Received: by mail-qk0-f173.google.com with SMTP id 18so3998366qkt.8
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 17:26:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Vhost-net has a hard limit on the number of zerocopy skbs in flight.
When reached, transmission stalls. Stalls cause latency, as well as
head-of-line blocking of other flows that do not use zerocopy.

Instead of stalling, revert to copy-based transmission.

Tested by sending two udp flows from guest to host, one with payload
of VHOST_GOODCOPY_LEN, the other too small for zerocopy (1B). The
large flow is redirected to a netem instance with 1MBps rate limit
and deep 1000 entry queue.

  modprobe ifb
  ip link set dev ifb0 up
  tc qdisc add dev ifb0 root netem limit 1000 rate 1MBit

  tc qdisc add dev tap0 ingress
  tc filter add dev tap0 parent ffff: protocol ip \
      u32 match ip dport 8000 0xffff \
      action mirred egress redirect dev ifb0

Before the delay, both flows process around 80K pps. With the delay,
before this patch, both process around 400. After this patch, the
large flow is still rate limited, while the small reverts to its
original rate. See also discussion in the first link, below.

The limit in vhost_exceeds_maxpend must be carefully chosen. When
vq->num >> 1, the flows remain correlated. This value happens to
correspond to VHOST_MAX_PENDING for vq->num == 256. Allow smaller
fractions and ensure correctness also for much smaller values of
vq->num, by testing the min() of both explicitly. See also the
discussion in the second link below.

Link:http://lkml.kernel.org/r/CAF=yD-+Wk9sc9dXMUq1+x_hh=3ThTXa6BnZkygP3tgVpjbp93g@mail.gmail.com
Link:http://lkml.kernel.org/r/20170819064129.27272-1-den@klaipeden.com
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/vhost/net.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 58585ec8699e..50758602ae9d 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -436,8 +436,8 @@ static bool vhost_exceeds_maxpend(struct vhost_net *net)
 	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
 	struct vhost_virtqueue *vq = &nvq->vq;
 
-	return (nvq->upend_idx + vq->num - VHOST_MAX_PEND) % UIO_MAXIOV
-		== nvq->done_idx;
+	return (nvq->upend_idx + UIO_MAXIOV - nvq->done_idx) % UIO_MAXIOV >
+	       min(VHOST_MAX_PEND, vq->num >> 2);
 }
 
 /* Expects to be always run from workqueue - which acts as
@@ -480,12 +480,6 @@ static void handle_tx(struct vhost_net *net)
 		if (zcopy)
 			vhost_zerocopy_signal_used(net, vq);
 
-		/* If more outstanding DMAs, queue the work.
-		 * Handle upend_idx wrap around
-		 */
-		if (unlikely(vhost_exceeds_maxpend(net)))
-			break;
-
 		head = vhost_net_tx_get_vq_desc(net, vq, vq->iov,
 						ARRAY_SIZE(vq->iov),
 						&out, &in);
@@ -509,6 +503,7 @@ static void handle_tx(struct vhost_net *net)
 		len = iov_length(vq->iov, out);
 		iov_iter_init(&msg.msg_iter, WRITE, vq->iov, out, len);
 		iov_iter_advance(&msg.msg_iter, hdr_size);
+
 		/* Sanity check */
 		if (!msg_data_left(&msg)) {
 			vq_err(vq, "Unexpected header len for TX: "
@@ -519,8 +514,7 @@ static void handle_tx(struct vhost_net *net)
 		len = msg_data_left(&msg);
 
 		zcopy_used = zcopy && len >= VHOST_GOODCOPY_LEN
-				   && (nvq->upend_idx + 1) % UIO_MAXIOV !=
-				      nvq->done_idx
+				   && !vhost_exceeds_maxpend(net)
 				   && vhost_net_tx_select_zcopy(net);
 
 		/* use msg_control to pass vhost zerocopy ubuf info to skb */
-- 
2.14.2.822.g60be5d43e6-goog
