From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 3/3] virtio-net: support XDP_REDIRECT
Date: Tue, 19 Sep 2017 17:42:43 +0800
Message-ID: <1505814163-7315-3-git-send-email-jasowang@redhat.com>
References: <1505814163-7315-1-git-send-email-jasowang@redhat.com>
Cc: John Fastabend <john.fastabend@gmail.com>
To: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505814163-7315-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch tries to add XDP_REDIRECT for virtio-net. The changes are
not complex as we could use exist XDP_TX helpers for most of the
work. The rest is passing the XDP_TX to NAPI handler for implementing
batching.

Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.  |  0
 drivers/net/virtio_net.c | 77 ++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 62 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/virtio_net.

diff --git a/drivers/net/virtio_net. b/drivers/net/virtio_net.
new file mode 100644
index 0000000..e69de29
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index db5924c..f6c1f13 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -29,6 +29,7 @@
 #include <linux/slab.h>
 #include <linux/cpu.h>
 #include <linux/average.h>
+#include <linux/filter.h>
 #include <net/route.h>
 
 static int napi_weight = NAPI_POLL_WEIGHT;
@@ -372,8 +373,20 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	return skb;
 }
 
-static bool virtnet_xdp_xmit(struct virtnet_info *vi,
-			     struct xdp_buff *xdp)
+static void virtnet_xdp_flush(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct send_queue *sq;
+	unsigned int qp;
+
+	qp = vi->curr_queue_pairs - vi->xdp_queue_pairs + smp_processor_id();
+	sq = &vi->sq[qp];
+
+	virtqueue_kick(sq->vq);
+}
+
+static bool __virtnet_xdp_xmit(struct virtnet_info *vi,
+			       struct xdp_buff *xdp)
 {
 	struct virtio_net_hdr_mrg_rxbuf *hdr;
 	unsigned int len;
@@ -407,10 +420,19 @@ static bool virtnet_xdp_xmit(struct virtnet_info *vi,
 		return false;
 	}
 
-	virtqueue_kick(sq->vq);
 	return true;
 }
 
+static int virtnet_xdp_xmit(struct net_device *dev, struct xdp_buff *xdp)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	bool sent = __virtnet_xdp_xmit(vi, xdp);
+
+	if (!sent)
+		return -ENOSPC;
+	return 0;
+}
+
 static unsigned int virtnet_get_headroom(struct virtnet_info *vi)
 {
 	return vi->xdp_queue_pairs ? VIRTIO_XDP_HEADROOM : 0;
@@ -483,7 +505,8 @@ static struct sk_buff *receive_small(struct net_device *dev,
 				     struct virtnet_info *vi,
 				     struct receive_queue *rq,
 				     void *buf, void *ctx,
-				     unsigned int len)
+				     unsigned int len,
+				     bool *xdp_xmit)
 {
 	struct sk_buff *skb;
 	struct bpf_prog *xdp_prog;
@@ -493,7 +516,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
 	unsigned int buflen = SKB_DATA_ALIGN(GOOD_PACKET_LEN + headroom) +
 			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	struct page *page = virt_to_head_page(buf);
-	unsigned int delta = 0;
+	unsigned int delta = 0, err;
 	struct page *xdp_page;
 	len -= vi->hdr_len;
 
@@ -541,8 +564,16 @@ static struct sk_buff *receive_small(struct net_device *dev,
 			delta = orig_data - xdp.data;
 			break;
 		case XDP_TX:
-			if (unlikely(!virtnet_xdp_xmit(vi, &xdp)))
+			if (unlikely(!__virtnet_xdp_xmit(vi, &xdp)))
 				trace_xdp_exception(vi->dev, xdp_prog, act);
+			else
+				*xdp_xmit = true;
+			rcu_read_unlock();
+			goto xdp_xmit;
+		case XDP_REDIRECT:
+			err = xdp_do_redirect(dev, &xdp, xdp_prog);
+			if (!err)
+				*xdp_xmit = true;
 			rcu_read_unlock();
 			goto xdp_xmit;
 		default:
@@ -603,7 +634,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 					 struct receive_queue *rq,
 					 void *buf,
 					 void *ctx,
-					 unsigned int len)
+					 unsigned int len,
+					 bool *xdp_xmit)
 {
 	struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
 	u16 num_buf = virtio16_to_cpu(vi->vdev, hdr->num_buffers);
@@ -613,6 +645,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	struct bpf_prog *xdp_prog;
 	unsigned int truesize;
 	unsigned int headroom = mergeable_ctx_to_headroom(ctx);
+	int err;
 
 	head_skb = NULL;
 
@@ -678,12 +711,20 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			}
 			break;
 		case XDP_TX:
-			if (unlikely(!virtnet_xdp_xmit(vi, &xdp)))
+			if (unlikely(!__virtnet_xdp_xmit(vi, &xdp)))
 				trace_xdp_exception(vi->dev, xdp_prog, act);
+			else
+				*xdp_xmit = true;
 			if (unlikely(xdp_page != page))
 				goto err_xdp;
 			rcu_read_unlock();
 			goto xdp_xmit;
+		case XDP_REDIRECT:
+			err = xdp_do_redirect(dev, &xdp, xdp_prog);
+			if (err)
+				*xdp_xmit = true;
+			rcu_read_unlock();
+			goto xdp_xmit;
 		default:
 			bpf_warn_invalid_xdp_action(act);
 		case XDP_ABORTED:
@@ -788,7 +829,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 }
 
 static int receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
-		       void *buf, unsigned int len, void **ctx)
+		       void *buf, unsigned int len, void **ctx, bool *xdp_xmit)
 {
 	struct net_device *dev = vi->dev;
 	struct sk_buff *skb;
@@ -809,11 +850,11 @@ static int receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	}
 
 	if (vi->mergeable_rx_bufs)
-		skb = receive_mergeable(dev, vi, rq, buf, ctx, len);
+		skb = receive_mergeable(dev, vi, rq, buf, ctx, len, xdp_xmit);
 	else if (vi->big_packets)
 		skb = receive_big(dev, vi, rq, buf, len);
 	else
-		skb = receive_small(dev, vi, rq, buf, ctx, len);
+		skb = receive_small(dev, vi, rq, buf, ctx, len, xdp_xmit);
 
 	if (unlikely(!skb))
 		return 0;
@@ -1071,7 +1112,7 @@ static void refill_work(struct work_struct *work)
 	}
 }
 
-static int virtnet_receive(struct receive_queue *rq, int budget)
+static int virtnet_receive(struct receive_queue *rq, int budget, bool *xdp_xmit)
 {
 	struct virtnet_info *vi = rq->vq->vdev->priv;
 	unsigned int len, received = 0, bytes = 0;
@@ -1083,13 +1124,13 @@ static int virtnet_receive(struct receive_queue *rq, int budget)
 
 		while (received < budget &&
 		       (buf = virtqueue_get_buf_ctx(rq->vq, &len, &ctx))) {
-			bytes += receive_buf(vi, rq, buf, len, ctx);
+			bytes += receive_buf(vi, rq, buf, len, ctx, xdp_xmit);
 			received++;
 		}
 	} else {
 		while (received < budget &&
 		       (buf = virtqueue_get_buf(rq->vq, &len)) != NULL) {
-			bytes += receive_buf(vi, rq, buf, len, NULL);
+			bytes += receive_buf(vi, rq, buf, len, NULL, xdp_xmit);
 			received++;
 		}
 	}
@@ -1161,15 +1202,19 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
 	struct receive_queue *rq =
 		container_of(napi, struct receive_queue, napi);
 	unsigned int received;
+	bool xdp_xmit = false;
 
 	virtnet_poll_cleantx(rq);
 
-	received = virtnet_receive(rq, budget);
+	received = virtnet_receive(rq, budget, &xdp_xmit);
 
 	/* Out of packets? */
 	if (received < budget)
 		virtqueue_napi_complete(napi, rq->vq, received);
 
+	if (xdp_xmit)
+		xdp_do_flush_map();
+
 	return received;
 }
 
@@ -2069,6 +2114,8 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
 	.ndo_xdp		= virtnet_xdp,
+	.ndo_xdp_xmit		= virtnet_xdp_xmit,
+	.ndo_xdp_flush		= virtnet_xdp_flush,
 	.ndo_features_check	= passthru_features_check,
 };
 
-- 
2.7.4
