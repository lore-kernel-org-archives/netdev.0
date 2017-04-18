From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 4/5] virtio-net: clean tx descriptors from rx napi
Date: Tue, 18 Apr 2017 16:21:07 -0400
Message-ID: <20170418202108.61920-5-willemdebruijn.kernel@gmail.com>
References: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34018 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754281AbdDRUVO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 16:21:14 -0400
Received: by mail-qk0-f195.google.com with SMTP id p68so639131qke.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 13:21:13 -0700 (PDT)
In-Reply-To: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Amortize the cost of virtual interrupts by doing both rx and tx work
on reception of a receive interrupt if tx napi is enabled. With
VIRTIO_F_EVENT_IDX, this suppresses most explicit tx completion
interrupts for bidirectional workloads.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/virtio_net.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 81a98de864e6..b14c82ce0032 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1072,12 +1072,33 @@ static void free_old_xmit_skbs(struct send_queue *sq)
 	u64_stats_update_end(&stats->tx_syncp);
 }
 
+static void virtnet_poll_cleantx(struct receive_queue *rq)
+{
+	struct virtnet_info *vi = rq->vq->vdev->priv;
+	unsigned int index = vq2rxq(rq->vq);
+	struct send_queue *sq = &vi->sq[index];
+	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, index);
+
+	if (!sq->napi.weight)
+		return;
+
+	if (__netif_tx_trylock(txq)) {
+		free_old_xmit_skbs(sq);
+		__netif_tx_unlock(txq);
+	}
+
+	if (sq->vq->num_free >= 2 + MAX_SKB_FRAGS)
+		netif_tx_wake_queue(txq);
+}
+
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
 	struct receive_queue *rq =
 		container_of(napi, struct receive_queue, napi);
 	unsigned int received;
 
+	virtnet_poll_cleantx(rq);
+
 	received = virtnet_receive(rq, budget);
 
 	/* Out of packets? */
-- 
2.12.2.816.g2cccc81164-goog
