From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next v6 6/6] virtio-net: initial rx sysfs support, export mergeable rx buffer size
Date: Thu, 16 Jan 2014 22:23:30 -0800
Message-ID: <1389939810-14998-7-git-send-email-mwdalton@google.com>
References: <1389939810-14998-1-git-send-email-mwdalton@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	virtualization@lists.linux-foundation.org,
	Michael Dalton <mwdalton@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:41270 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbaAQGXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 01:23:44 -0500
Received: by mail-yh0-f73.google.com with SMTP id f10so396706yha.4
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 22:23:44 -0800 (PST)
In-Reply-To: <1389939810-14998-1-git-send-email-mwdalton@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add initial support for per-rx queue sysfs attributes to virtio-net. If
mergeable packet buffers are enabled, adds a read-only mergeable packet
buffer size sysfs attribute for each RX queue.

Suggested-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Michael Dalton <mwdalton@google.com>
---
v3->v4: Remove seqcount due to EWMA changes in patch 5.
        Add missing Suggested-By. 

 drivers/net/virtio_net.c | 46 ++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 42 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index dacd43b..d75f8ed 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -600,18 +600,25 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 	return err;
 }
 
-static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
+static unsigned int get_mergeable_buf_len(struct ewma *avg_pkt_len)
 {
 	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
+	unsigned int len;
+
+	len = hdr_len + clamp_t(unsigned int, ewma_read(avg_pkt_len),
+			GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
+	return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
+}
+
+static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
+{
 	struct page_frag *alloc_frag = &rq->alloc_frag;
 	char *buf;
 	unsigned long ctx;
 	int err;
 	unsigned int len, hole;
 
-	len = hdr_len + clamp_t(unsigned int, ewma_read(&rq->mrg_avg_pkt_len),
-				GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
-	len = ALIGN(len, MERGEABLE_BUFFER_ALIGN);
+	len = get_mergeable_buf_len(&rq->mrg_avg_pkt_len);
 	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
 		return -ENOMEM;
 
@@ -1584,6 +1591,33 @@ err:
 	return ret;
 }
 
+#ifdef CONFIG_SYSFS
+static ssize_t mergeable_rx_buffer_size_show(struct netdev_rx_queue *queue,
+		struct rx_queue_attribute *attribute, char *buf)
+{
+	struct virtnet_info *vi = netdev_priv(queue->dev);
+	unsigned int queue_index = get_netdev_rx_queue_index(queue);
+	struct ewma *avg;
+
+	BUG_ON(queue_index >= vi->max_queue_pairs);
+	avg = &vi->rq[queue_index].mrg_avg_pkt_len;
+	return sprintf(buf, "%u\n", get_mergeable_buf_len(avg));
+}
+
+static struct rx_queue_attribute mergeable_rx_buffer_size_attribute =
+	__ATTR_RO(mergeable_rx_buffer_size);
+
+static struct attribute *virtio_net_mrg_rx_attrs[] = {
+	&mergeable_rx_buffer_size_attribute.attr,
+	NULL
+};
+
+static const struct attribute_group virtio_net_mrg_rx_group = {
+	.name = "virtio_net",
+	.attrs = virtio_net_mrg_rx_attrs
+};
+#endif
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int i, err;
@@ -1698,6 +1732,10 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (err)
 		goto free_stats;
 
+#ifdef CONFIG_SYSFS
+	if (vi->mergeable_rx_bufs)
+		dev->sysfs_rx_queue_group = &virtio_net_mrg_rx_group;
+#endif
 	netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
 	netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
 
-- 
1.8.5.2
