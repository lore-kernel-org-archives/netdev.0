From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 3/5] virtio-net: switch to use new ctx API for small buffer
Date: Mon, 17 Jul 2017 20:43:59 +0800
Message-ID: <1500295441-19339-4-git-send-email-jasowang@redhat.com>
References: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
To: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch to use ctx API for small buffer, this is need for avoiding
reset on XDP.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 8fae9a8..e31b5b2 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -410,7 +410,8 @@ static unsigned int virtnet_get_headroom(struct virtnet_info *vi)
 static struct sk_buff *receive_small(struct net_device *dev,
 				     struct virtnet_info *vi,
 				     struct receive_queue *rq,
-				     void *buf, unsigned int len)
+				     void *buf, void *ctx,
+				     unsigned int len)
 {
 	struct sk_buff *skb;
 	struct bpf_prog *xdp_prog;
@@ -773,7 +774,7 @@ static int receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	else if (vi->big_packets)
 		skb = receive_big(dev, vi, rq, buf, len);
 	else
-		skb = receive_small(dev, vi, rq, buf, len);
+		skb = receive_small(dev, vi, rq, buf, ctx, len);
 
 	if (unlikely(!skb))
 		return 0;
@@ -812,6 +813,7 @@ static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
 	struct page_frag *alloc_frag = &rq->alloc_frag;
 	char *buf;
 	unsigned int xdp_headroom = virtnet_get_headroom(vi);
+	void *ctx = (void *)(unsigned long)xdp_headroom;
 	int len = vi->hdr_len + VIRTNET_RX_PAD + GOOD_PACKET_LEN + xdp_headroom;
 	int err;
 
@@ -825,7 +827,7 @@ static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
 	alloc_frag->offset += len;
 	sg_init_one(rq->sg, buf + VIRTNET_RX_PAD + xdp_headroom,
 		    vi->hdr_len + GOOD_PACKET_LEN);
-	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, buf, gfp);
+	err = virtqueue_add_inbuf_ctx(rq->vq, rq->sg, 1, buf, ctx, gfp);
 	if (err < 0)
 		put_page(virt_to_head_page(buf));
 
@@ -1034,7 +1036,7 @@ static int virtnet_receive(struct receive_queue *rq, int budget)
 	void *buf;
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 
-	if (vi->mergeable_rx_bufs) {
+	if (!vi->big_packets || vi->mergeable_rx_bufs) {
 		void *ctx;
 
 		while (received < budget &&
@@ -2198,7 +2200,7 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
 	names = kmalloc(total_vqs * sizeof(*names), GFP_KERNEL);
 	if (!names)
 		goto err_names;
-	if (vi->mergeable_rx_bufs) {
+	if (!vi->big_packets || vi->mergeable_rx_bufs) {
 		ctx = kzalloc(total_vqs * sizeof(*ctx), GFP_KERNEL);
 		if (!ctx)
 			goto err_ctx;
-- 
2.7.4
