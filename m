From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v8 5/5] virtio_net: check return value of skb_to_sgvec always
Date: Thu, 11 May 2017 21:41:34 +0200
Message-ID: <20170511194134.31183-6-Jason@zx2c4.com>
References: <20170511194134.31183-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	davem@davemloft.net,
	kernel-hardening@lists.openwall.com
Return-path: <kernel-hardening-return-7863-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170511194134.31183-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9320d96a1632..13fbe4b349c2 100644
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
+                if (unlikely(num_sg < 0))
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
