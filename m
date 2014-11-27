From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v6 24/46] virtio_net: get rid of virtio_net_hdr/skb_vnet_hdr
Date: Thu, 27 Nov 2014 22:09:50 +0200
Message-ID: <1417118789-18231-25-git-send-email-mst@redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417118789-18231-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtio 1.0 doesn't use virtio_net_hdr anymore, and in fact, it's not
really useful since virtio_net_hdr_mrg_rxbuf includes that as the first
field anyway.

Let's drop it, precalculate header len and store within vi instead.

This way we can also remove struct skb_vnet_hdr.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 drivers/net/virtio_net.c | 90 ++++++++++++++++++++++--------------------------
 1 file changed, 41 insertions(+), 49 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 1630c21..516f2cb 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -123,6 +123,9 @@ struct virtnet_info {
 	/* Host can handle any s/g split between our header and packet data */
 	bool any_header_sg;
 
+	/* Packet virtio header size */
+	u8 hdr_len;
+
 	/* Active statistics */
 	struct virtnet_stats __percpu *stats;
 
@@ -139,21 +142,14 @@ struct virtnet_info {
 	struct notifier_block nb;
 };
 
-struct skb_vnet_hdr {
-	union {
-		struct virtio_net_hdr hdr;
-		struct virtio_net_hdr_mrg_rxbuf mhdr;
-	};
-};
-
 struct padded_vnet_hdr {
-	struct virtio_net_hdr hdr;
+	struct virtio_net_hdr_mrg_rxbuf hdr;
 	/*
-	 * virtio_net_hdr should be in a separated sg buffer because of a
-	 * QEMU bug, and data sg buffer shares same page with this header sg.
-	 * This padding makes next sg 16 byte aligned after virtio_net_hdr.
+	 * hdr is in a separate sg buffer, and data sg buffer shares same page
+	 * with this header sg. This padding makes next sg 16 byte aligned
+	 * after the header.
 	 */
-	char padding[6];
+	char padding[4];
 };
 
 /* Converting between virtqueue no. and kernel tx/rx queue no.
@@ -179,9 +175,9 @@ static int rxq2vq(int rxq)
 	return rxq * 2;
 }
 
-static inline struct skb_vnet_hdr *skb_vnet_hdr(struct sk_buff *skb)
+static inline struct virtio_net_hdr_mrg_rxbuf *skb_vnet_hdr(struct sk_buff *skb)
 {
-	return (struct skb_vnet_hdr *)skb->cb;
+	return (struct virtio_net_hdr_mrg_rxbuf *)skb->cb;
 }
 
 /*
@@ -247,7 +243,7 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 				   unsigned int len, unsigned int truesize)
 {
 	struct sk_buff *skb;
-	struct skb_vnet_hdr *hdr;
+	struct virtio_net_hdr_mrg_rxbuf *hdr;
 	unsigned int copy, hdr_len, hdr_padded_len;
 	char *p;
 
@@ -260,13 +256,11 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 
 	hdr = skb_vnet_hdr(skb);
 
-	if (vi->mergeable_rx_bufs) {
-		hdr_len = sizeof hdr->mhdr;
-		hdr_padded_len = sizeof hdr->mhdr;
-	} else {
-		hdr_len = sizeof hdr->hdr;
+	hdr_len = vi->hdr_len;
+	if (vi->mergeable_rx_bufs)
+		hdr_padded_len = sizeof *hdr;
+	else
 		hdr_padded_len = sizeof(struct padded_vnet_hdr);
-	}
 
 	memcpy(hdr, p, hdr_len);
 
@@ -317,11 +311,11 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	return skb;
 }
 
-static struct sk_buff *receive_small(void *buf, unsigned int len)
+static struct sk_buff *receive_small(struct virtnet_info *vi, void *buf, unsigned int len)
 {
 	struct sk_buff * skb = buf;
 
-	len -= sizeof(struct virtio_net_hdr);
+	len -= vi->hdr_len;
 	skb_trim(skb, len);
 
 	return skb;
@@ -354,8 +348,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 					 unsigned int len)
 {
 	void *buf = mergeable_ctx_to_buf_address(ctx);
-	struct skb_vnet_hdr *hdr = buf;
-	u16 num_buf = virtio16_to_cpu(rq->vq->vdev, hdr->mhdr.num_buffers);
+	struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
+	u16 num_buf = virtio16_to_cpu(vi->vdev, hdr->num_buffers);
 	struct page *page = virt_to_head_page(buf);
 	int offset = buf - page_address(page);
 	unsigned int truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
@@ -373,8 +367,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		if (unlikely(!ctx)) {
 			pr_debug("%s: rx error: %d buffers out of %d missing\n",
 				 dev->name, num_buf,
-				 virtio16_to_cpu(rq->vq->vdev,
-						 hdr->mhdr.num_buffers));
+				 virtio16_to_cpu(vi->vdev,
+						 hdr->num_buffers));
 			dev->stats.rx_length_errors++;
 			goto err_buf;
 		}
@@ -441,7 +435,7 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	struct net_device *dev = vi->dev;
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 	struct sk_buff *skb;
-	struct skb_vnet_hdr *hdr;
+	struct virtio_net_hdr_mrg_rxbuf *hdr;
 
 	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
 		pr_debug("%s: short packet %i\n", dev->name, len);
@@ -463,7 +457,7 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	else if (vi->big_packets)
 		skb = receive_big(dev, vi, rq, buf, len);
 	else
-		skb = receive_small(buf, len);
+		skb = receive_small(vi, buf, len);
 
 	if (unlikely(!skb))
 		return;
@@ -545,7 +539,7 @@ static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
 			     gfp_t gfp)
 {
 	struct sk_buff *skb;
-	struct skb_vnet_hdr *hdr;
+	struct virtio_net_hdr_mrg_rxbuf *hdr;
 	int err;
 
 	skb = __netdev_alloc_skb_ip_align(vi->dev, GOOD_PACKET_LEN, gfp);
@@ -556,7 +550,7 @@ static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
 
 	hdr = skb_vnet_hdr(skb);
 	sg_init_table(rq->sg, MAX_SKB_FRAGS + 2);
-	sg_set_buf(rq->sg, &hdr->hdr, sizeof hdr->hdr);
+	sg_set_buf(rq->sg, hdr, vi->hdr_len);
 	skb_to_sgvec(skb, rq->sg + 1, 0, skb->len);
 
 	err = virtqueue_add_inbuf(rq->vq, rq->sg, 2, skb, gfp);
@@ -566,7 +560,8 @@ static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
 	return err;
 }
 
-static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
+static int add_recvbuf_big(struct virtnet_info *vi, struct receive_queue *rq,
+			   gfp_t gfp)
 {
 	struct page *first, *list = NULL;
 	char *p;
@@ -597,8 +592,8 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 	p = page_address(first);
 
 	/* rq->sg[0], rq->sg[1] share the same page */
-	/* a separated rq->sg[0] for virtio_net_hdr only due to QEMU bug */
-	sg_set_buf(&rq->sg[0], p, sizeof(struct virtio_net_hdr));
+	/* a separated rq->sg[0] for header - required in case !any_header_sg */
+	sg_set_buf(&rq->sg[0], p, vi->hdr_len);
 
 	/* rq->sg[1] for data packet, from offset */
 	offset = sizeof(struct padded_vnet_hdr);
@@ -677,7 +672,7 @@ static bool try_fill_recv(struct virtnet_info *vi, struct receive_queue *rq,
 		if (vi->mergeable_rx_bufs)
 			err = add_recvbuf_mergeable(rq, gfp);
 		else if (vi->big_packets)
-			err = add_recvbuf_big(rq, gfp);
+			err = add_recvbuf_big(vi, rq, gfp);
 		else
 			err = add_recvbuf_small(vi, rq, gfp);
 
@@ -857,18 +852,14 @@ static void free_old_xmit_skbs(struct send_queue *sq)
 
 static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 {
-	struct skb_vnet_hdr *hdr;
+	struct virtio_net_hdr_mrg_rxbuf *hdr;
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
 	struct virtnet_info *vi = sq->vq->vdev->priv;
 	unsigned num_sg;
-	unsigned hdr_len;
+	unsigned hdr_len = vi->hdr_len;
 	bool can_push;
 
 	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
-	if (vi->mergeable_rx_bufs)
-		hdr_len = sizeof hdr->mhdr;
-	else
-		hdr_len = sizeof hdr->hdr;
 
 	can_push = vi->any_header_sg &&
 		!((unsigned long)skb->data & (__alignof__(*hdr) - 1)) &&
@@ -876,7 +867,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 	/* Even if we can, don't push here yet as this would skew
 	 * csum_start offset below. */
 	if (can_push)
-		hdr = (struct skb_vnet_hdr *)(skb->data - hdr_len);
+		hdr = (struct virtio_net_hdr_mrg_rxbuf *)(skb->data - hdr_len);
 	else
 		hdr = skb_vnet_hdr(skb);
 
@@ -909,7 +900,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 	}
 
 	if (vi->mergeable_rx_bufs)
-		hdr->mhdr.num_buffers = 0;
+		hdr->num_buffers = 0;
 
 	sg_init_table(sq->sg, MAX_SKB_FRAGS + 2);
 	if (can_push) {
@@ -1814,18 +1805,19 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
 
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
+		vi->hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
+	else
+		vi->hdr_len = sizeof(struct virtio_net_hdr);
+
 	if (virtio_has_feature(vdev, VIRTIO_F_ANY_LAYOUT))
 		vi->any_header_sg = true;
 
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
 		vi->has_cvq = true;
 
-	if (vi->any_header_sg) {
-		if (vi->mergeable_rx_bufs)
-			dev->needed_headroom = sizeof(struct virtio_net_hdr_mrg_rxbuf);
-		else
-			dev->needed_headroom = sizeof(struct virtio_net_hdr);
-	}
+	if (vi->any_header_sg)
+		dev->needed_headroom = vi->hdr_len;
 
 	/* Use single tx/rx queue pair as default */
 	vi->curr_queue_pairs = 1;
-- 
MST
