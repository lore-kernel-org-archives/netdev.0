From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC v3 10/16] virtio_net: use v1.0 endian.
Date: Wed, 22 Oct 2014 21:44:48 +0300
Message-ID: <1414003404-505-11-git-send-email-mst@redhat.com>
References: <1414003404-505-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1414003404-505-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>

[Cornelia Huck: converted some missed fields]
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Cornelia Huck <cornelia.huck@de.ibm.com>

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d75256bd..2e6561e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -347,13 +347,14 @@ err:
 }
 
 static struct sk_buff *receive_mergeable(struct net_device *dev,
+					 struct virtnet_info *vi,
 					 struct receive_queue *rq,
 					 unsigned long ctx,
 					 unsigned int len)
 {
 	void *buf = mergeable_ctx_to_buf_address(ctx);
 	struct skb_vnet_hdr *hdr = buf;
-	int num_buf = hdr->mhdr.num_buffers;
+	u16 num_buf = virtio16_to_cpu(rq->vq->vdev, hdr->mhdr.num_buffers);
 	struct page *page = virt_to_head_page(buf);
 	int offset = buf - page_address(page);
 	unsigned int truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
@@ -369,7 +370,9 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		ctx = (unsigned long)virtqueue_get_buf(rq->vq, &len);
 		if (unlikely(!ctx)) {
 			pr_debug("%s: rx error: %d buffers out of %d missing\n",
-				 dev->name, num_buf, hdr->mhdr.num_buffers);
+				 dev->name, num_buf,
+				 virtio16_to_cpu(rq->vq->vdev,
+						 hdr->mhdr.num_buffers));
 			dev->stats.rx_length_errors++;
 			goto err_buf;
 		}
@@ -454,7 +457,7 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 	}
 
 	if (vi->mergeable_rx_bufs)
-		skb = receive_mergeable(dev, rq, (unsigned long)buf, len);
+		skb = receive_mergeable(dev, vi, rq, (unsigned long)buf, len);
 	else if (vi->big_packets)
 		skb = receive_big(dev, rq, buf, len);
 	else
@@ -473,8 +476,8 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 	if (hdr->hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
 		pr_debug("Needs csum!\n");
 		if (!skb_partial_csum_set(skb,
-					  hdr->hdr.csum_start,
-					  hdr->hdr.csum_offset))
+			  virtio16_to_cpu(vi->vdev, hdr->hdr.csum_start),
+			  virtio16_to_cpu(vi->vdev, hdr->hdr.csum_offset)))
 			goto frame_err;
 	} else if (hdr->hdr.flags & VIRTIO_NET_HDR_F_DATA_VALID) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -505,7 +508,8 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		if (hdr->hdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
 			skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
 
-		skb_shinfo(skb)->gso_size = hdr->hdr.gso_size;
+		skb_shinfo(skb)->gso_size = virtio16_to_cpu(vi->vdev,
+							    hdr->hdr.gso_size);
 		if (skb_shinfo(skb)->gso_size == 0) {
 			net_warn_ratelimited("%s: zero gso size.\n", dev->name);
 			goto frame_err;
@@ -867,16 +871,19 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		hdr->hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
-		hdr->hdr.csum_start = skb_checksum_start_offset(skb);
-		hdr->hdr.csum_offset = skb->csum_offset;
+		hdr->hdr.csum_start = cpu_to_virtio16(vi->vdev,
+						skb_checksum_start_offset(skb));
+		hdr->hdr.csum_offset = cpu_to_virtio16(vi->vdev,
+							 skb->csum_offset);
 	} else {
 		hdr->hdr.flags = 0;
 		hdr->hdr.csum_offset = hdr->hdr.csum_start = 0;
 	}
 
 	if (skb_is_gso(skb)) {
-		hdr->hdr.hdr_len = skb_headlen(skb);
-		hdr->hdr.gso_size = skb_shinfo(skb)->gso_size;
+		hdr->hdr.hdr_len = cpu_to_virtio16(vi->vdev, skb_headlen(skb));
+		hdr->hdr.gso_size = cpu_to_virtio16(vi->vdev,
+						    skb_shinfo(skb)->gso_size);
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
 			hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
@@ -1182,7 +1189,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	sg_init_table(sg, 2);
 
 	/* Store the unicast list and count in the front of the buffer */
-	mac_data->entries = uc_count;
+	mac_data->entries = cpu_to_virtio32(vi->vdev, uc_count);
 	i = 0;
 	netdev_for_each_uc_addr(ha, dev)
 		memcpy(&mac_data->macs[i++][0], ha->addr, ETH_ALEN);
@@ -1193,7 +1200,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	/* multicast list and count fill the end */
 	mac_data = (void *)&mac_data->macs[uc_count][0];
 
-	mac_data->entries = mc_count;
+	mac_data->entries = cpu_to_virtio32(vi->vdev, mc_count);
 	i = 0;
 	netdev_for_each_mc_addr(ha, dev)
 		memcpy(&mac_data->macs[i++][0], ha->addr, ETH_ALEN);
-- 
MST
