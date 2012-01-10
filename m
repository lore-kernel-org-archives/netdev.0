From: Mike Waychison <mikew@google.com>
Subject: [PATCH v2 2/3] virtio_net: Batch receive buffer filling
Date: Tue, 10 Jan 2012 09:41:07 -0800
Message-ID: <20120110174106.4505.95254.stgit@mike2.sea.corp.google.com>
References: <20120110174052.4505.66514.stgit@mike2.sea.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, earhart@google.com, digitaleric@google.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120110174052.4505.66514.stgit@mike2.sea.corp.google.com>
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

In preparation of moving the allocation of receive buffers on the slow
path outside of the NAPI disable block in refill_work(), introduce a new
method, try_fill_recvbatch(), which fill the receive buffers in a
batched mode.  Although their algorithms are similar, the list enqeueing
and cleanup are different enough that duplicating the overall algorithm
resulted in cleaner code.

This new function is implemented either by fill_recvbatch_pages() in the
case of "big" or "mergeable" receive buffers, or fill_recvbatch_small()
for the small buffer fallback case.

The batched operation allows us to later push the disabling of napi on
the virtio_net device down to only cover the bits that manipulate the
virtio queue, letting the bulk of the allocations operate while the nic
can still process received packets.

Signed-off-by: Mike Waychison <mikew@google.com>
---
 drivers/net/virtio_net.c |  142 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 141 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 5531089..10d9761 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -37,6 +37,7 @@ module_param(gso, bool, 0444);
 /* FIXME: MTU in config. */
 #define MAX_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
 #define GOOD_COPY_LEN	128
+#define MAX_RX_ALLOCATE_BATCH	32
 
 #define VIRTNET_SEND_COMMAND_SG_MAX    2
 #define VIRTNET_DRIVER_VERSION "1.0.0"
@@ -572,6 +573,144 @@ static void virtnet_napi_enable(struct virtnet_info *vi)
 	}
 }
 
+/*
+ * Try to fill a "big" or "mergeable" receive queue using batching.
+ * Caller must serialize against NAPI.
+ * Returns false if we failed to finish due to oom.
+ */
+static bool fill_recvbatch_pages(struct virtnet_info *vi)
+{
+	bool oom = false;
+	bool full = false;
+	LIST_HEAD(local_list);
+	struct page *page, *npage;
+	int i;
+
+	BUG_ON(!vi->big_packets && !vi->mergeable_rx_bufs);
+fill_more:
+	/* Allocate a batch. */
+	for (i = 0; i < MAX_RX_ALLOCATE_BATCH; i++) {
+		if (vi->mergeable_rx_bufs)
+			page = alloc_recvbuf_mergeable(vi, GFP_KERNEL);
+		else  /* vi->big_packets */
+			page = alloc_recvbuf_big(vi, GFP_KERNEL);
+		if (!page) {
+			oom =  true;
+			break;
+		}
+		list_add_tail(&page->lru, &local_list);
+	}
+
+	/* Enqueue batch as available. */
+	list_for_each_entry_safe(page, npage, &local_list, lru) {
+		int err;
+
+		list_del(&page->lru);
+		if (vi->mergeable_rx_bufs)
+			err = add_recvbuf_mergeable(vi, page, GFP_KERNEL);
+		else  /* vi->big_packets */
+			err = add_recvbuf_big(vi, page, GFP_KERNEL);
+		if (err > 0)
+			continue;
+		if (err == -ENOSPC || err == 0)
+			full = true;
+		else if (err == -ENOMEM)
+			oom = true;
+		else
+			BUG();
+		break;
+	}
+	if (unlikely(vi->num > vi->max))
+		vi->max = vi->num;
+
+	/* Cleanup any remaining entries on the list */
+	if (unlikely(!list_empty(&local_list))) {
+		list_for_each_entry_safe(page, npage, &local_list, lru) {
+			list_del(&page->lru);
+			give_pages(vi, page);
+		}
+	}
+
+	if (!oom && !full)
+		goto fill_more;
+
+	return !oom;
+}
+
+/*
+ * Try to fill a "small" receive queue using batching.
+ * Caller must serialize against NAPI.
+ * Returns false if we failed to finish due to oom.
+ */
+static bool fill_recvbatch_small(struct virtnet_info *vi)
+{
+	bool oom = false;
+	bool full = false;
+	LIST_HEAD(local_list);
+	struct list_head *pos, *npos;
+	struct sk_buff *skb;
+	int i;
+
+fill_more:
+	/* Allocate a batch. */
+	for (i = 0; i < MAX_RX_ALLOCATE_BATCH; i++) {
+		skb = alloc_recvbuf_small(vi, GFP_KERNEL);
+		if (!skb) {
+			oom =  true;
+			break;
+		}
+		list_add_tail((struct list_head *)skb, &local_list);
+	}
+
+	/* Enqueue batch as available. */
+	list_for_each_safe(pos, npos, &local_list) {
+		int err;
+
+		list_del(pos);
+		skb = (struct sk_buff *)pos;
+
+		err = add_recvbuf_small(vi, skb, GFP_KERNEL);
+		if (err > 0)
+			continue;
+		if (err == -ENOSPC || err == 0)
+			full = true;
+		else if (err == -ENOMEM)
+			oom = true;
+		else
+			BUG();
+		break;
+	}
+	if (unlikely(vi->num > vi->max))
+		vi->max = vi->num;
+
+	/* Cleanup any remaining entries on the list */
+	if (unlikely(!list_empty(&local_list))) {
+		list_for_each_safe(pos, npos, &local_list) {
+			skb = (struct sk_buff *)pos;
+			list_del(pos);
+			dev_kfree_skb(skb);
+		}
+	}
+
+	if (!oom && !full)
+		goto fill_more;
+
+	return !oom;
+}
+
+/*
+ * Refill the receive queues from process context.
+ * Caller must serialize against NAPI.
+ * Returns false if we failed to allocate due to memory pressure.
+ */
+static bool try_fill_recvbatch(struct virtnet_info *vi)
+{
+	if (vi->mergeable_rx_bufs || vi->big_packets)
+		return fill_recvbatch_pages(vi);
+	else
+		return fill_recvbatch_small(vi);
+}
+
 static void refill_work(struct work_struct *work)
 {
 	struct virtnet_info *vi;
@@ -579,7 +718,8 @@ static void refill_work(struct work_struct *work)
 
 	vi = container_of(work, struct virtnet_info, refill.work);
 	napi_disable(&vi->napi);
-	still_empty = !try_fill_recv(vi, GFP_KERNEL);
+	still_empty = !try_fill_recvbatch(vi);
+	virtqueue_kick(vi->rvq);
 	virtnet_napi_enable(vi);
 
 	/* In theory, this can happen: if we don't get any buffers in
