From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 2/5] virtio-net: pack headroom into ctx for mergeable
	buffer
Date: Mon, 17 Jul 2017 20:43:58 +0800
Message-ID: <1500295441-19339-3-git-send-email-jasowang@redhat.com>
References: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, jasowang@redhat.com,
	virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
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

Pack headroom into ctx, then during XDP set, we could know the size of
headroom and copy if needed. This is required for avoiding reset on
XDP.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 1f8c15c..8fae9a8 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -270,6 +270,23 @@ static void skb_xmit_done(struct virtqueue *vq)
 		netif_wake_subqueue(vi->dev, vq2txq(vq));
 }
 
+#define MRG_CTX_HEADER_SHIFT 22
+static void *mergeable_len_to_ctx(unsigned int truesize,
+				  unsigned int headroom)
+{
+	return (void *)(unsigned long)((headroom << MRG_CTX_HEADER_SHIFT) | truesize);
+}
+
+static unsigned int mergeable_ctx_to_headroom(void *mrg_ctx)
+{
+	return (unsigned long)mrg_ctx >> MRG_CTX_HEADER_SHIFT;
+}
+
+static unsigned int mergeable_ctx_to_truesize(void *mrg_ctx)
+{
+	return (unsigned long)mrg_ctx & ((1 << MRG_CTX_HEADER_SHIFT) - 1);
+}
+
 /* Called from bottom half context */
 static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 				   struct receive_queue *rq,
@@ -639,13 +656,14 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	}
 	rcu_read_unlock();
 
-	if (unlikely(len > (unsigned long)ctx)) {
+	truesize = mergeable_ctx_to_truesize(ctx);
+	if (unlikely(len > truesize)) {
 		pr_debug("%s: rx error: len %u exceeds truesize %lu\n",
 			 dev->name, len, (unsigned long)ctx);
 		dev->stats.rx_length_errors++;
 		goto err_skb;
 	}
-	truesize = (unsigned long)ctx;
+
 	head_skb = page_to_skb(vi, rq, page, offset, len, truesize);
 	curr_skb = head_skb;
 
@@ -665,13 +683,14 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		}
 
 		page = virt_to_head_page(buf);
-		if (unlikely(len > (unsigned long)ctx)) {
+
+		truesize = mergeable_ctx_to_truesize(ctx);
+		if (unlikely(len > truesize)) {
 			pr_debug("%s: rx error: len %u exceeds truesize %lu\n",
 				 dev->name, len, (unsigned long)ctx);
 			dev->stats.rx_length_errors++;
 			goto err_skb;
 		}
-		truesize = (unsigned long)ctx;
 
 		num_skb_frags = skb_shinfo(curr_skb)->nr_frags;
 		if (unlikely(num_skb_frags == MAX_SKB_FRAGS)) {
@@ -889,7 +908,7 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi,
 
 	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
 	buf += headroom; /* advance address leaving hole at front of pkt */
-	ctx = (void *)(unsigned long)len;
+	ctx = mergeable_len_to_ctx(len, headroom);
 	get_page(alloc_frag->page);
 	alloc_frag->offset += len + headroom;
 	hole = alloc_frag->size - alloc_frag->offset;
-- 
2.7.4
