From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH net-next v10 5/5] virtio_net: check return value of skb_to_sgvec always
Date: Sun,  4 Jun 2017 04:16:26 +0200
Message-ID: <20170604021626.11968-6-Jason@zx2c4.com>
References: <20170604021626.11968-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, kernel-hardening@lists.openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170604021626.11968-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 3e9246cc49c3..57763d30cabb 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1150,7 +1150,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 	struct virtio_net_hdr_mrg_rxbuf *hdr;
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
 	struct virtnet_info *vi = sq->vq->vdev->priv;
-	unsigned num_sg;
+	int num_sg;
 	unsigned hdr_len = vi->hdr_len;
 	bool can_push;
 
@@ -1177,11 +1177,16 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 	if (can_push) {
 		__skb_push(skb, hdr_len);
 		num_sg = skb_to_sgvec(skb, sq->sg, 0, skb->len);
+		if (unlikely(num_sg < 0))
+			return num_sg;
 		/* Pull header back to avoid skew in tx bytes calculations. */
 		__skb_pull(skb, hdr_len);
 	} else {
 		sg_set_buf(sq->sg, hdr, hdr_len);
-		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
+		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len);
+		if (unlikely(num_sg < 0))
+			return num_sg;
+		num_sg++;
 	}
 	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb, GFP_ATOMIC);
 }
-- 
2.13.0
