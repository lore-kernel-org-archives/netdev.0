From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net 9/9] virtio-net: XDP support for small buffers
Date: Fri, 23 Dec 2016 22:37:32 +0800
Message-ID: <1482503852-12438-10-git-send-email-jasowang@redhat.com>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Commit f600b6905015 ("virtio_net: Add XDP support") leaves the case of
small receive buffer untouched. This will confuse the user who want to
set XDP but use small buffers. Other than forbid XDP in small buffer
mode, let's make it work. XDP then can only work at skb->data since
virtio-net create skbs during refill, this is sub optimal which could
be optimized in the future.

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 112 ++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 87 insertions(+), 25 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index e53365a8..5deeda6 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -333,9 +333,9 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 static void virtnet_xdp_xmit(struct virtnet_info *vi,
 			     struct receive_queue *rq,
 			     struct send_queue *sq,
-			     struct xdp_buff *xdp)
+			     struct xdp_buff *xdp,
+			     void *data)
 {
-	struct page *page = virt_to_head_page(xdp->data);
 	struct virtio_net_hdr_mrg_rxbuf *hdr;
 	unsigned int num_sg, len;
 	void *xdp_sent;
@@ -343,20 +343,45 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
 
 	/* Free up any pending old buffers before queueing new ones. */
 	while ((xdp_sent = virtqueue_get_buf(sq->vq, &len)) != NULL) {
-		struct page *sent_page = virt_to_head_page(xdp_sent);
-		put_page(sent_page);
+		if (vi->mergeable_rx_bufs) {
+			struct page *sent_page = virt_to_head_page(xdp_sent);
+
+			put_page(sent_page);
+		} else { /* small buffer */
+			struct sk_buff *skb = xdp_sent;
+
+			kfree_skb(skb);
+		}
 	}
 
-	/* Zero header and leave csum up to XDP layers */
-	hdr = xdp->data;
-	memset(hdr, 0, vi->hdr_len);
+	if (vi->mergeable_rx_bufs) {
+		/* Zero header and leave csum up to XDP layers */
+		hdr = xdp->data;
+		memset(hdr, 0, vi->hdr_len);
+
+		num_sg = 1;
+		sg_init_one(sq->sg, xdp->data, xdp->data_end - xdp->data);
+	} else { /* small buffer */
+		struct sk_buff *skb = data;
 
-	num_sg = 1;
-	sg_init_one(sq->sg, xdp->data, xdp->data_end - xdp->data);
+		/* Zero header and leave csum up to XDP layers */
+		hdr = skb_vnet_hdr(skb);
+		memset(hdr, 0, vi->hdr_len);
+
+		num_sg = 2;
+		sg_init_table(sq->sg, 2);
+		sg_set_buf(sq->sg, hdr, vi->hdr_len);
+		skb_to_sgvec(skb, sq->sg + 1, 0, skb->len);
+	}
 	err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
-				   xdp->data, GFP_ATOMIC);
+				   data, GFP_ATOMIC);
 	if (unlikely(err)) {
-		put_page(page);
+		if (vi->mergeable_rx_bufs) {
+			struct page *page = virt_to_head_page(xdp->data);
+
+			put_page(page);
+		} else /* small buffer */
+			kfree_skb(data);
 		return; // On error abort to avoid unnecessary kick
 	}
 
@@ -366,23 +391,26 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
 static u32 do_xdp_prog(struct virtnet_info *vi,
 		       struct receive_queue *rq,
 		       struct bpf_prog *xdp_prog,
-		       struct page *page, int offset, int len)
+		       void *data, int len)
 {
 	int hdr_padded_len;
 	struct xdp_buff xdp;
+	void *buf;
 	unsigned int qp;
 	u32 act;
-	u8 *buf;
-
-	buf = page_address(page) + offset;
 
-	if (vi->mergeable_rx_bufs)
+	if (vi->mergeable_rx_bufs) {
 		hdr_padded_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
-	else
-		hdr_padded_len = sizeof(struct padded_vnet_hdr);
+		xdp.data = data + hdr_padded_len;
+		xdp.data_end = xdp.data + (len - vi->hdr_len);
+		buf = data;
+	} else { /* small buffers */
+		struct sk_buff *skb = data;
 
-	xdp.data = buf + hdr_padded_len;
-	xdp.data_end = xdp.data + (len - vi->hdr_len);
+		xdp.data = skb->data;
+		xdp.data_end = xdp.data + len;
+		buf = skb->data;
+	}
 
 	act = bpf_prog_run_xdp(xdp_prog, &xdp);
 	switch (act) {
@@ -392,8 +420,8 @@ static u32 do_xdp_prog(struct virtnet_info *vi,
 		qp = vi->curr_queue_pairs -
 			vi->xdp_queue_pairs +
 			smp_processor_id();
-		xdp.data = buf + (vi->mergeable_rx_bufs ? 0 : 4);
-		virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp);
+		xdp.data = buf;
+		virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp, data);
 		return XDP_TX;
 	default:
 		bpf_warn_invalid_xdp_action(act);
@@ -403,14 +431,47 @@ static u32 do_xdp_prog(struct virtnet_info *vi,
 	}
 }
 
-static struct sk_buff *receive_small(struct virtnet_info *vi, void *buf, unsigned int len)
+static struct sk_buff *receive_small(struct net_device *dev,
+				     struct virtnet_info *vi,
+				     struct receive_queue *rq,
+				     void *buf, unsigned int len)
 {
 	struct sk_buff * skb = buf;
+	struct bpf_prog *xdp_prog;
 
 	len -= vi->hdr_len;
 	skb_trim(skb, len);
 
+	rcu_read_lock();
+	xdp_prog = rcu_dereference(rq->xdp_prog);
+	if (xdp_prog) {
+		struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
+		u32 act;
+
+		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
+			goto err_xdp;
+		act = do_xdp_prog(vi, rq, xdp_prog, skb, len);
+		switch (act) {
+		case XDP_PASS:
+			break;
+		case XDP_TX:
+			rcu_read_unlock();
+			goto xdp_xmit;
+		case XDP_DROP:
+		default:
+			goto err_xdp;
+		}
+	}
+	rcu_read_unlock();
+
 	return skb;
+
+err_xdp:
+	rcu_read_unlock();
+	dev->stats.rx_dropped++;
+	kfree_skb(skb);
+xdp_xmit:
+	return NULL;
 }
 
 static struct sk_buff *receive_big(struct net_device *dev,
@@ -537,7 +598,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		if (unlikely(hdr->hdr.gso_type))
 			goto err_xdp;
 
-		act = do_xdp_prog(vi, rq, xdp_prog, xdp_page, offset, len);
+		act = do_xdp_prog(vi, rq, xdp_prog,
+				  page_address(xdp_page) + offset, len);
 		switch (act) {
 		case XDP_PASS:
 			/* We can only create skb based on xdp_page. */
@@ -672,7 +734,7 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	else if (vi->big_packets)
 		skb = receive_big(dev, vi, rq, buf, len);
 	else
-		skb = receive_small(vi, buf, len);
+		skb = receive_small(dev, vi, rq, buf, len);
 
 	if (unlikely(!skb))
 		return;
-- 
2.7.4
