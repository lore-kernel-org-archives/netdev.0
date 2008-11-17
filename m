From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 3/3] virtio_net: VIRTIO_NET_F_MSG_RXBUF (imprive rcv buffer allocation)
Date: Mon, 17 Nov 2008 13:47:42 +1030
Message-ID: <200811171347.42694.rusty@rustcorp.com.au>
References: <200811171344.57410.rusty@rustcorp.com.au> <200811171346.09039.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48442 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755237AbYKQDRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2008 22:17:53 -0500
In-Reply-To: <200811171346.09039.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>

If segmentation offload is enabled by the host, we currently allocate
maximum sized packet buffers and pass them to the host. This uses up
20 ring entries, allowing us to supply only 20 packet buffers to the
host with a 256 entry ring. This is a huge overhead when receiving
small packets, and is most keenly felt when receiving MTU sized
packets from off-host.

The VIRTIO_NET_F_MRG_RXBUF feature flag is set by hosts which support
using receive buffers which are smaller than the maximum packet size.
In order to transfer large packets to the guest, the host merges
together multiple receive buffers to form a larger logical buffer.
The number of merged buffers is returned to the guest via a field in
the virtio_net_hdr.

Make use of this support by supplying single page receive buffers to
the host. On receive, we extract the virtio_net_hdr, copy 128 bytes of
the payload to the skb's linear data buffer and adjust the fragment
offset to point to the remaining data. This ensures proper alignment
and allows us to not use any paged data for small packets. If the
payload occupies multiple pages, we simply append those pages as
fragments and free the associated skbs.

This scheme allows us to be efficient in our use of ring entries
while still supporting large packets. Benchmarking using netperf from
an external machine to a guest over a 10Gb/s network shows a 100%
improvement from ~1Gb/s to ~2Gb/s. With a local host->guest benchmark
with GSO disabled on the host side, throughput was seen to increase
from 700Mb/s to 1.7Gb/s.

Based on a patch from Herbert Xu.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (use netdev_priv)
---
 drivers/net/virtio_net.c   |  173 +++++++++++++++++++++++++++++++++++++++------
 include/linux/virtio_net.h |    9 ++
 2 files changed, 162 insertions(+), 20 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -34,6 +34,7 @@ module_param(gso, bool, 0444);
 
 /* FIXME: MTU in config. */
 #define MAX_PACKET_LEN (ETH_HLEN+ETH_DATA_LEN)
+#define GOOD_COPY_LEN	128
 
 struct virtnet_info
 {
@@ -58,6 +59,9 @@ struct virtnet_info
 	/* I like... big packets and I cannot lie! */
 	bool big_packets;
 
+	/* Host will merge rx buffers for big packets (shake it! shake it!) */
+	bool mergeable_rx_bufs;
+
 	/* Receive & send queues. */
 	struct sk_buff_head recv;
 	struct sk_buff_head send;
@@ -66,14 +70,9 @@ struct virtnet_info
 	struct page *pages;
 };
 
-static inline struct virtio_net_hdr *skb_vnet_hdr(struct sk_buff *skb)
+static inline void *skb_vnet_hdr(struct sk_buff *skb)
 {
 	return (struct virtio_net_hdr *)skb->cb;
-}
-
-static inline void vnet_hdr_to_sg(struct scatterlist *sg, struct sk_buff *skb)
-{
-	sg_init_one(sg, skb_vnet_hdr(skb), sizeof(struct virtio_net_hdr));
 }
 
 static void give_a_page(struct virtnet_info *vi, struct page *page)
@@ -121,25 +120,97 @@ static void receive_skb(struct net_devic
 static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 			unsigned len)
 {
+	struct virtnet_info *vi = netdev_priv(dev);
 	struct virtio_net_hdr *hdr = skb_vnet_hdr(skb);
 	int err;
+	int i;
 
 	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
 		pr_debug("%s: short packet %i\n", dev->name, len);
 		dev->stats.rx_length_errors++;
 		goto drop;
 	}
-	len -= sizeof(struct virtio_net_hdr);
 
-	if (len <= MAX_PACKET_LEN)
-		trim_pages(netdev_priv(dev), skb);
+	if (vi->mergeable_rx_bufs) {
+		struct virtio_net_hdr_mrg_rxbuf *mhdr = skb_vnet_hdr(skb);
+		unsigned int copy;
+		char *p = page_address(skb_shinfo(skb)->frags[0].page);
 
-	err = pskb_trim(skb, len);
-	if (err) {
-		pr_debug("%s: pskb_trim failed %i %d\n", dev->name, len, err);
-		dev->stats.rx_dropped++;
-		goto drop;
+		if (len > PAGE_SIZE)
+			len = PAGE_SIZE;
+		len -= sizeof(struct virtio_net_hdr_mrg_rxbuf);
+
+		memcpy(hdr, p, sizeof(*mhdr));
+		p += sizeof(*mhdr);
+
+		copy = len;
+		if (copy > skb_tailroom(skb))
+			copy = skb_tailroom(skb);
+
+		memcpy(skb_put(skb, copy), p, copy);
+
+		len -= copy;
+
+		if (!len) {
+			give_a_page(vi, skb_shinfo(skb)->frags[0].page);
+			skb_shinfo(skb)->nr_frags--;
+		} else {
+			skb_shinfo(skb)->frags[0].page_offset +=
+				sizeof(*mhdr) + copy;
+			skb_shinfo(skb)->frags[0].size = len;
+			skb->data_len += len;
+			skb->len += len;
+		}
+
+		while (--mhdr->num_buffers) {
+			struct sk_buff *nskb;
+
+			i = skb_shinfo(skb)->nr_frags;
+			if (i >= MAX_SKB_FRAGS) {
+				pr_debug("%s: packet too long %d\n", dev->name,
+					 len);
+				dev->stats.rx_length_errors++;
+				goto drop;
+			}
+
+			nskb = vi->rvq->vq_ops->get_buf(vi->rvq, &len);
+			if (!nskb) {
+				pr_debug("%s: rx error: %d buffers missing\n",
+					 dev->name, mhdr->num_buffers);
+				dev->stats.rx_length_errors++;
+				goto drop;
+			}
+
+			__skb_unlink(nskb, &vi->recv);
+			vi->num--;
+
+			skb_shinfo(skb)->frags[i] = skb_shinfo(nskb)->frags[0];
+			skb_shinfo(nskb)->nr_frags = 0;
+			kfree_skb(nskb);
+
+			if (len > PAGE_SIZE)
+				len = PAGE_SIZE;
+
+			skb_shinfo(skb)->frags[i].size = len;
+			skb_shinfo(skb)->nr_frags++;
+			skb->data_len += len;
+			skb->len += len;
+		}
+	} else {
+		len -= sizeof(struct virtio_net_hdr);
+
+		if (len <= MAX_PACKET_LEN)
+			trim_pages(vi, skb);
+
+		err = pskb_trim(skb, len);
+		if (err) {
+			pr_debug("%s: pskb_trim failed %i %d\n", dev->name,
+				 len, err);
+			dev->stats.rx_dropped++;
+			goto drop;
+		}
 	}
+
 	skb->truesize += skb->data_len;
 	dev->stats.rx_bytes += skb->len;
 	dev->stats.rx_packets++;
@@ -198,7 +269,7 @@ drop:
 	dev_kfree_skb(skb);
 }
 
-static void try_fill_recv(struct virtnet_info *vi)
+static void try_fill_recv_maxbufs(struct virtnet_info *vi)
 {
 	struct sk_buff *skb;
 	struct scatterlist sg[2+MAX_SKB_FRAGS];
@@ -206,12 +277,16 @@ static void try_fill_recv(struct virtnet
 
 	sg_init_table(sg, 2+MAX_SKB_FRAGS);
 	for (;;) {
+		struct virtio_net_hdr *hdr;
+
 		skb = netdev_alloc_skb(vi->dev, MAX_PACKET_LEN);
 		if (unlikely(!skb))
 			break;
 
 		skb_put(skb, MAX_PACKET_LEN);
-		vnet_hdr_to_sg(sg, skb);
+
+		hdr = skb_vnet_hdr(skb);
+		sg_init_one(sg, hdr, sizeof(*hdr));
 
 		if (vi->big_packets) {
 			for (i = 0; i < MAX_SKB_FRAGS; i++) {
@@ -237,6 +312,54 @@ static void try_fill_recv(struct virtnet
 		if (err) {
 			skb_unlink(skb, &vi->recv);
 			trim_pages(vi, skb);
+			kfree_skb(skb);
+			break;
+		}
+		vi->num++;
+	}
+	if (unlikely(vi->num > vi->max))
+		vi->max = vi->num;
+	vi->rvq->vq_ops->kick(vi->rvq);
+}
+
+static void try_fill_recv(struct virtnet_info *vi)
+{
+	struct sk_buff *skb;
+	struct scatterlist sg[1];
+	int err;
+
+	if (!vi->mergeable_rx_bufs) {
+		try_fill_recv_maxbufs(vi);
+		return;
+	}
+
+	for (;;) {
+		skb_frag_t *f;
+
+		skb = netdev_alloc_skb(vi->dev, GOOD_COPY_LEN + NET_IP_ALIGN);
+		if (unlikely(!skb))
+			break;
+
+		skb_reserve(skb, NET_IP_ALIGN);
+
+		f = &skb_shinfo(skb)->frags[0];
+		f->page = get_a_page(vi, GFP_ATOMIC);
+		if (!f->page) {
+			kfree_skb(skb);
+			break;
+		}
+
+		f->page_offset = 0;
+		f->size = PAGE_SIZE;
+
+		skb_shinfo(skb)->nr_frags++;
+
+		sg_init_one(sg, page_address(f->page), PAGE_SIZE);
+		skb_queue_head(&vi->recv, skb);
+
+		err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, 1, skb);
+		if (err) {
+			skb_unlink(skb, &vi->recv);
 			kfree_skb(skb);
 			break;
 		}
@@ -325,7 +448,8 @@ static int xmit_skb(struct virtnet_info 
 {
 	int num, err;
 	struct scatterlist sg[2+MAX_SKB_FRAGS];
-	struct virtio_net_hdr *hdr;
+	struct virtio_net_hdr_mrg_rxbuf *mhdr = skb_vnet_hdr(skb);
+	struct virtio_net_hdr *hdr = skb_vnet_hdr(skb);
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
 
 	sg_init_table(sg, 2+MAX_SKB_FRAGS);
@@ -334,8 +458,6 @@ static int xmit_skb(struct virtnet_info 
 		 dest[0], dest[1], dest[2],
 		 dest[3], dest[4], dest[5]);
 
-	/* Encode metadata header at front. */
-	hdr = skb_vnet_hdr(skb);
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		hdr->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
 		hdr->csum_start = skb->csum_start - skb_headroom(skb);
@@ -363,7 +485,14 @@ static int xmit_skb(struct virtnet_info 
 		hdr->gso_size = hdr->hdr_len = 0;
 	}
 
-	vnet_hdr_to_sg(sg, skb);
+	mhdr->num_buffers = 0;
+
+	/* Encode metadata header at front. */
+	if (vi->mergeable_rx_bufs)
+		sg_init_one(sg, mhdr, sizeof(*mhdr));
+	else
+		sg_init_one(sg, hdr, sizeof(*hdr));
+
 	num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 
 	err = vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
@@ -552,6 +681,9 @@ static int virtnet_probe(struct virtio_d
 	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
 		vi->big_packets = true;
 
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
+		vi->mergeable_rx_bufs = true;
+
 	/* We expect two virtqueues, receive then send. */
 	vi->rvq = vdev->config->find_vq(vdev, 0, skb_recv_done);
 	if (IS_ERR(vi->rvq)) {
@@ -644,6 +776,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
+	VIRTIO_NET_F_MRG_RXBUF,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -20,6 +20,7 @@
 #define VIRTIO_NET_F_HOST_TSO6	12	/* Host can handle TSOv6 in. */
 #define VIRTIO_NET_F_HOST_ECN	13	/* Host can handle TSO[6] w/ ECN in. */
 #define VIRTIO_NET_F_HOST_UFO	14	/* Host can handle UFO in. */
+#define VIRTIO_NET_F_MRG_RXBUF	15	/* Host can merge receive buffers. */
 
 struct virtio_net_config
 {
@@ -44,4 +45,12 @@ struct virtio_net_hdr
 	__u16 csum_start;	/* Position to start checksumming from */
 	__u16 csum_offset;	/* Offset after that to place checksum */
 };
+
+/* This is the version of the header to use when the MRG_RXBUF
+ * feature has been negotiated. */
+struct virtio_net_hdr_mrg_rxbuf {
+	struct virtio_net_hdr hdr;
+	__u16 num_buffers;	/* Number of merged rx buffers */
+};
+
 #endif /* _LINUX_VIRTIO_NET_H */

