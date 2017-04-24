From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v3 3/5] virtio-net: move free_old_xmit_skbs
Date: Mon, 24 Apr 2017 13:49:28 -0400
Message-ID: <20170424174930.82623-4-willemdebruijn.kernel@gmail.com>
References: <20170424174930.82623-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35572 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S973155AbdDXRtg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 13:49:36 -0400
Received: by mail-qt0-f194.google.com with SMTP id o36so21521056qtb.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 10:49:36 -0700 (PDT)
In-Reply-To: <20170424174930.82623-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

An upcoming patch will call free_old_xmit_skbs indirectly from
virtnet_poll. Move the function above this to avoid having to
introduce a forward declaration.

This is a pure move: no code changes.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/virtio_net.c | 60 ++++++++++++++++++++++++------------------------
 1 file changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 356d18481ee4..4ec79e5d7a86 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1045,6 +1045,36 @@ static int virtnet_receive(struct receive_queue *rq, int budget)
 	return received;
 }
 
+static void free_old_xmit_skbs(struct send_queue *sq)
+{
+	struct sk_buff *skb;
+	unsigned int len;
+	struct virtnet_info *vi = sq->vq->vdev->priv;
+	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
+	unsigned int packets = 0;
+	unsigned int bytes = 0;
+
+	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
+		pr_debug("Sent skb %p\n", skb);
+
+		bytes += skb->len;
+		packets++;
+
+		dev_kfree_skb_any(skb);
+	}
+
+	/* Avoid overhead when no packets have been processed
+	 * happens when called speculatively from start_xmit.
+	 */
+	if (!packets)
+		return;
+
+	u64_stats_update_begin(&stats->tx_syncp);
+	stats->tx_bytes += bytes;
+	stats->tx_packets += packets;
+	u64_stats_update_end(&stats->tx_syncp);
+}
+
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
 	struct receive_queue *rq =
@@ -1077,36 +1107,6 @@ static int virtnet_open(struct net_device *dev)
 	return 0;
 }
 
-static void free_old_xmit_skbs(struct send_queue *sq)
-{
-	struct sk_buff *skb;
-	unsigned int len;
-	struct virtnet_info *vi = sq->vq->vdev->priv;
-	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
-	unsigned int packets = 0;
-	unsigned int bytes = 0;
-
-	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
-		pr_debug("Sent skb %p\n", skb);
-
-		bytes += skb->len;
-		packets++;
-
-		dev_kfree_skb_any(skb);
-	}
-
-	/* Avoid overhead when no packets have been processed
-	 * happens when called speculatively from start_xmit.
-	 */
-	if (!packets)
-		return;
-
-	u64_stats_update_begin(&stats->tx_syncp);
-	stats->tx_bytes += bytes;
-	stats->tx_packets += packets;
-	u64_stats_update_end(&stats->tx_syncp);
-}
-
 static int virtnet_poll_tx(struct napi_struct *napi, int budget)
 {
 	struct send_queue *sq = container_of(napi, struct send_queue, napi);
-- 
2.12.2.816.g2cccc81164-goog
