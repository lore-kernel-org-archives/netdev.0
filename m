From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v6 15/46] virtio_net: v1.0 endianness
Date: Thu, 27 Nov 2014 22:09:02 +0200
Message-ID: <1417118789-18231-16-git-send-email-mst@redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417118789-18231-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on patches by Rusty Russell, Cornelia Huck.
Note: more code changes are needed for 1.0 support
(due to different header size).
So we don't advertize support for 1.0 yet.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Cornelia Huck <cornelia.huck@de.ibm.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/uapi/linux/virtio_net.h | 15 ++++++++-------
 drivers/net/virtio_net.c        | 33 ++++++++++++++++++++-------------
 2 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index 172a7f0..b5f1677 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -28,6 +28,7 @@
 #include <linux/types.h>
 #include <linux/virtio_ids.h>
 #include <linux/virtio_config.h>
+#include <linux/virtio_types.h>
 #include <linux/if_ether.h>
 
 /* The feature bitmap for virtio net */
@@ -84,17 +85,17 @@ struct virtio_net_hdr {
 #define VIRTIO_NET_HDR_GSO_TCPV6	4	// GSO frame, IPv6 TCP
 #define VIRTIO_NET_HDR_GSO_ECN		0x80	// TCP has ECN set
 	__u8 gso_type;
-	__u16 hdr_len;		/* Ethernet + IP + tcp/udp hdrs */
-	__u16 gso_size;		/* Bytes to append to hdr_len per frame */
-	__u16 csum_start;	/* Position to start checksumming from */
-	__u16 csum_offset;	/* Offset after that to place checksum */
+	__virtio16 hdr_len;		/* Ethernet + IP + tcp/udp hdrs */
+	__virtio16 gso_size;		/* Bytes to append to hdr_len per frame */
+	__virtio16 csum_start;	/* Position to start checksumming from */
+	__virtio16 csum_offset;	/* Offset after that to place checksum */
 };
 
 /* This is the version of the header to use when the MRG_RXBUF
  * feature has been negotiated. */
 struct virtio_net_hdr_mrg_rxbuf {
 	struct virtio_net_hdr hdr;
-	__u16 num_buffers;	/* Number of merged rx buffers */
+	__virtio16 num_buffers;	/* Number of merged rx buffers */
 };
 
 /*
@@ -149,7 +150,7 @@ typedef __u8 virtio_net_ctrl_ack;
  * VIRTIO_NET_F_CTRL_MAC_ADDR feature is available.
  */
 struct virtio_net_ctrl_mac {
-	__u32 entries;
+	__virtio32 entries;
 	__u8 macs[][ETH_ALEN];
 } __attribute__((packed));
 
@@ -193,7 +194,7 @@ struct virtio_net_ctrl_mac {
  * specified.
  */
 struct virtio_net_ctrl_mq {
-	__u16 virtqueue_pairs;
+	__virtio16 virtqueue_pairs;
 };
 
 #define VIRTIO_NET_CTRL_MQ   4
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b0bc8ea..c07e030 100644
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
@@ -514,7 +517,8 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		if (hdr->hdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
 			skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
 
-		skb_shinfo(skb)->gso_size = hdr->hdr.gso_size;
+		skb_shinfo(skb)->gso_size = virtio16_to_cpu(vi->vdev,
+							    hdr->hdr.gso_size);
 		if (skb_shinfo(skb)->gso_size == 0) {
 			net_warn_ratelimited("%s: zero gso size.\n", dev->name);
 			goto frame_err;
@@ -876,16 +880,19 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 
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
@@ -1112,7 +1119,7 @@ static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
 	if (!vi->has_cvq || !virtio_has_feature(vi->vdev, VIRTIO_NET_F_MQ))
 		return 0;
 
-	s.virtqueue_pairs = queue_pairs;
+	s.virtqueue_pairs = cpu_to_virtio16(vi->vdev, queue_pairs);
 	sg_init_one(&sg, &s, sizeof(s));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MQ,
@@ -1189,7 +1196,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	sg_init_table(sg, 2);
 
 	/* Store the unicast list and count in the front of the buffer */
-	mac_data->entries = uc_count;
+	mac_data->entries = cpu_to_virtio32(vi->vdev, uc_count);
 	i = 0;
 	netdev_for_each_uc_addr(ha, dev)
 		memcpy(&mac_data->macs[i++][0], ha->addr, ETH_ALEN);
@@ -1200,7 +1207,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	/* multicast list and count fill the end */
 	mac_data = (void *)&mac_data->macs[uc_count][0];
 
-	mac_data->entries = mc_count;
+	mac_data->entries = cpu_to_virtio32(vi->vdev, mc_count);
 	i = 0;
 	netdev_for_each_mc_addr(ha, dev)
 		memcpy(&mac_data->macs[i++][0], ha->addr, ETH_ALEN);
-- 
MST
