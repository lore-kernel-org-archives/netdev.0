From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/4] virtio_net: use DECLARE_EWMA
Date: Wed, 19 Aug 2015 09:48:40 +0200
Message-ID: <1439970520.2089.1.camel@sipsolutions.net>
References: <1439970382-6170-1-git-send-email-johannes@sipsolutions.net>
	 <1439970382-6170-2-git-send-email-johannes@sipsolutions.net>
	 (sfid-20150819_094648_500906_0B582087)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56391 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813AbbHSHsp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 03:48:45 -0400
In-Reply-To: <1439970382-6170-2-git-send-email-johannes@sipsolutions.net> (sfid-20150819_094648_500906_0B582087)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, forgot to Cc Michael and the virt list - patch reproduced below
in full.

johannes

>From 22500fbcf722748fe3471b2e4c6156db47aade15 Mon Sep 17 00:00:00 2001
From: Johannes Berg <johannes.berg@intel.com>
Date: Wed, 19 Aug 2015 09:25:18 +0200
Subject: [PATCH] virtio_net: use DECLARE_EWMA

Instead of using the out-of-line EWMA calculation, use DECLARE_EWMA()
to create static inlines. On x86/64 this results in no change in code
size for me, but reduces the struct receive_queue size by the two
unsigned long values that store the parameters.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/net/Kconfig      |  1 -
 drivers/net/virtio_net.c | 22 +++++++++++-----------
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e58468b02987..f50373645ab4 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -282,7 +282,6 @@ config VETH
 config VIRTIO_NET
 	tristate "Virtio network driver"
 	depends on VIRTIO
-	select AVERAGE
 	---help---
 	  This is the virtual network driver for virtio.  It can be used with
 	  lguest or QEMU based VMMs (like KVM or Xen).  Say Y or M.
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 546b669fbfdd..9b950f2db836 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -40,12 +40,12 @@ module_param(gso, bool, 0444);
 #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
 #define GOOD_COPY_LEN	128
 
-/* Weight used for the RX packet size EWMA. The average packet size is used to
- * determine the packet buffer size when refilling RX rings. As the entire RX
- * ring may be refilled at once, the weight is chosen so that the EWMA will be
- * insensitive to short-term, transient changes in packet size.
+/* RX packet size EWMA. The average packet size is used to determine the packet
+ * buffer size when refilling RX rings. As the entire RX ring may be refilled
+ * at once, the weight is chosen so that the EWMA will be insensitive to short-
+ * term, transient changes in packet size.
  */
-#define RECEIVE_AVG_WEIGHT 64
+DECLARE_EWMA(pkt_len, 1, 64)
 
 /* Minimum alignment for mergeable packet buffers. */
 #define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, 256)
@@ -85,7 +85,7 @@ struct receive_queue {
 	struct page *pages;
 
 	/* Average packet length for mergeable receive buffers. */
-	struct ewma mrg_avg_pkt_len;
+	struct ewma_pkt_len mrg_avg_pkt_len;
 
 	/* Page frag for packet buffer allocation. */
 	struct page_frag alloc_frag;
@@ -407,7 +407,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		}
 	}
 
-	ewma_add(&rq->mrg_avg_pkt_len, head_skb->len);
+	ewma_pkt_len_add(&rq->mrg_avg_pkt_len, head_skb->len);
 	return head_skb;
 
 err_skb:
@@ -600,12 +600,12 @@ static int add_recvbuf_big(struct virtnet_info *vi, struct receive_queue *rq,
 	return err;
 }
 
-static unsigned int get_mergeable_buf_len(struct ewma *avg_pkt_len)
+static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
 {
 	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
 	unsigned int len;
 
-	len = hdr_len + clamp_t(unsigned int, ewma_read(avg_pkt_len),
+	len = hdr_len + clamp_t(unsigned int, ewma_pkt_len_read(avg_pkt_len),
 			GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
 	return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
 }
@@ -1615,7 +1615,7 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 		napi_hash_add(&vi->rq[i].napi);
 
 		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
-		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
+		ewma_pkt_len_init(&vi->rq[i].mrg_avg_pkt_len);
 		sg_init_table(vi->sq[i].sg, ARRAY_SIZE(vi->sq[i].sg));
 	}
 
@@ -1658,7 +1658,7 @@ static ssize_t mergeable_rx_buffer_size_show(struct netdev_rx_queue *queue,
 {
 	struct virtnet_info *vi = netdev_priv(queue->dev);
 	unsigned int queue_index = get_netdev_rx_queue_index(queue);
-	struct ewma *avg;
+	struct ewma_pkt_len *avg;
 
 	BUG_ON(queue_index >= vi->max_queue_pairs);
 	avg = &vi->rq[queue_index].mrg_avg_pkt_len;
