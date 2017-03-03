From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next RFC 4/4] virtio-net: clean tx descriptors from rx napi
Date: Fri,  3 Mar 2017 09:39:09 -0500
Message-ID: <20170303143909.80001-5-willemdebruijn.kernel@gmail.com>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
Cc: jasowang@redhat.com, mst@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33605 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752236AbdCCOrr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 09:47:47 -0500
Received: by mail-qk0-f196.google.com with SMTP id j127so9425588qke.0
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 06:47:46 -0800 (PST)
In-Reply-To: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Amortize the cost of virtual interrupts by doing both rx and tx work
on reception of a receive interrupt. Together VIRTIO_F_EVENT_IDX and
vhost interrupt moderation, this suppresses most explicit tx
completion interrupts for bidirectional workloads.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/virtio_net.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9a9031640179..21c575127d50 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1031,6 +1031,23 @@ static int virtnet_receive(struct receive_queue *rq, int budget)
 	return received;
 }
 
+static unsigned int free_old_xmit_skbs(struct send_queue *sq, int budget);
+
+static void virtnet_poll_cleantx(struct receive_queue *rq)
+{
+	struct virtnet_info *vi = rq->vq->vdev->priv;
+	unsigned int index = vq2rxq(rq->vq);
+	struct send_queue *sq = &vi->sq[index];
+	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, index);
+
+	__netif_tx_lock(txq, smp_processor_id());
+	free_old_xmit_skbs(sq, sq->napi.weight);
+	__netif_tx_unlock(txq);
+
+	if (sq->vq->num_free >= 2 + MAX_SKB_FRAGS)
+		netif_wake_subqueue(vi->dev, vq2txq(sq->vq));
+}
+
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
 	struct receive_queue *rq =
@@ -1039,6 +1056,8 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
 
 	received = virtnet_receive(rq, budget);
 
+	virtnet_poll_cleantx(rq);
+
 	/* Out of packets? */
 	if (received < budget)
 		virtqueue_napi_complete(napi, rq->vq, received);
-- 
2.12.0.rc1.440.g5b76565f74-goog
