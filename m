From: Mike Waychison <mikew@google.com>
Subject: [PATCH v2 3/3] virtio_net: Don't disable NAPI while allocating
Date: Tue, 10 Jan 2012 09:41:13 -0800
Message-ID: <20120110174112.4505.56948.stgit@mike2.sea.corp.google.com>
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

This patch changes the batch refill path so that NAPI is only disabled
when we are in the midst of enqueue available receive buffers.
allocators.

For "small" receive buffers, pushing the enabling and disabling of NAPI
is pretty straight-forward.  For the "big" and "mergeable" receive
buffers however care must be taken to avoid letting either the allocator
or the release code from touching the per-device free-page list at
vi->pages (which is only serialized by the virtue of NAPI
serialization).

To handle this case, the allocators are modified to take a
"napi_serialized" flag, which indicates whether or not they should be
touching vi->pages.  As well, for page release, __give_pages() is
introduced to free chains of pages (threaded through ->private) and is
to be used when we haven't stopped NAPI.

The failure paths in the "add" functions for the receive buffers do not
need to be updated, as they must be called serially with the NAPI poll,
and therefore are allowed to touch vi->pages (indirectly through
give_pages).

Signed-off-by: Mike Waychison <mikew@google.com>
---
 drivers/net/virtio_net.c |   67 +++++++++++++++++++++++++++++++++-------------
 1 files changed, 48 insertions(+), 19 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 10d9761..ec0e1fb 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -118,6 +118,20 @@ static void give_pages(struct virtnet_info *vi, struct page *page)
 	vi->pages = page;
 }
 
+/*
+ * Give a list of pages threaded through the ->private field back to the page
+ * allocator.  To be used by paths that aren't serialized with napi.
+ */
+static void __give_pages(struct page *page)
+{
+	struct page *nextpage;
+	do {
+		nextpage = (struct page *)page->private;
+		__free_page(page);
+		page = nextpage;
+	} while (page);
+}
+
 static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
 {
 	struct page *p = vi->pages;
@@ -402,19 +416,24 @@ static int add_recvbuf_small(struct virtnet_info *vi, struct sk_buff *skb,
  * Allocate an list of pages for "big" receive buffer configurations.
  * Pages are chained through ->private.
  * May return null if oom.
- * No serialization required.
+ * napi_serialized must be false if we aren't serialized with the napi path.
  */
-static struct page *alloc_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
+static struct page *alloc_recvbuf_big(struct virtnet_info *vi,
+				      bool napi_serialized, gfp_t gfp)
 {
 	struct page *first, *tail = NULL;
 	int i;
 
 	/* Build a list of pages chained through ->private.  Built in reverse order */
 	for (i = 0; i < MAX_SKB_FRAGS + 1; ++i) {
-		first = get_a_page(vi, gfp);
+		first = napi_serialized ? get_a_page(vi, gfp) : alloc_page(gfp);
 		if (!first) {
-			if (tail)
-				give_pages(vi, tail);
+			if (tail) {
+				if (napi_serialized)
+					give_pages(vi, tail);
+				else
+					__give_pages(tail);
+			}
 			return NULL;
 		}
 
@@ -472,11 +491,18 @@ static int add_recvbuf_big(struct virtnet_info *vi, struct page *first,
 /*
  * Allocate a page for "mergeable" receive buffer configurations.
  * May return NULL if oom.
- * No serialization required.
+ * @napi_serialized must be false if we aren't serialized with the napi path.
  */
-static struct page *alloc_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
+static struct page *alloc_recvbuf_mergeable(struct virtnet_info *vi,
+					    bool napi_serialized, gfp_t gfp)
 {
-	return get_a_page(vi, gfp);
+	struct page *page;
+	if (napi_serialized)
+		return get_a_page(vi, gfp);
+	page = alloc_page(gfp);
+	if (page)
+		page->private = 0;
+	return page;
 }
 
 /*
@@ -518,14 +544,14 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 	do {
 		if (vi->mergeable_rx_bufs) {
 			struct page *page;
-			page = alloc_recvbuf_mergeable(vi, gfp);
+			page = alloc_recvbuf_mergeable(vi, true, gfp);
 			if (!page)
 				err = -ENOMEM;
 			else
 				err = add_recvbuf_mergeable(vi, page, gfp);
 		} else if (vi->big_packets) {
 			struct page *page;
-			page = alloc_recvbuf_big(vi, gfp);
+			page = alloc_recvbuf_big(vi, true, gfp);
 			if (!page)
 				err = -ENOMEM;
 			else
@@ -575,7 +601,7 @@ static void virtnet_napi_enable(struct virtnet_info *vi)
 
 /*
  * Try to fill a "big" or "mergeable" receive queue using batching.
- * Caller must serialize against NAPI.
+ * This call will serialize itself against NAPI.
  * Returns false if we failed to finish due to oom.
  */
 static bool fill_recvbatch_pages(struct virtnet_info *vi)
@@ -591,9 +617,9 @@ fill_more:
 	/* Allocate a batch. */
 	for (i = 0; i < MAX_RX_ALLOCATE_BATCH; i++) {
 		if (vi->mergeable_rx_bufs)
-			page = alloc_recvbuf_mergeable(vi, GFP_KERNEL);
+			page = alloc_recvbuf_mergeable(vi, false, GFP_KERNEL);
 		else  /* vi->big_packets */
-			page = alloc_recvbuf_big(vi, GFP_KERNEL);
+			page = alloc_recvbuf_big(vi, false, GFP_KERNEL);
 		if (!page) {
 			oom =  true;
 			break;
@@ -602,6 +628,7 @@ fill_more:
 	}
 
 	/* Enqueue batch as available. */
+	napi_disable(&vi->napi);
 	list_for_each_entry_safe(page, npage, &local_list, lru) {
 		int err;
 
@@ -622,12 +649,14 @@ fill_more:
 	}
 	if (unlikely(vi->num > vi->max))
 		vi->max = vi->num;
+	virtqueue_kick(vi->rvq);
+	virtnet_napi_enable(vi);
 
 	/* Cleanup any remaining entries on the list */
 	if (unlikely(!list_empty(&local_list))) {
 		list_for_each_entry_safe(page, npage, &local_list, lru) {
 			list_del(&page->lru);
-			give_pages(vi, page);
+			__give_pages(page);
 		}
 	}
 
@@ -639,7 +668,7 @@ fill_more:
 
 /*
  * Try to fill a "small" receive queue using batching.
- * Caller must serialize against NAPI.
+ * This call will serialize itself against NAPI.
  * Returns false if we failed to finish due to oom.
  */
 static bool fill_recvbatch_small(struct virtnet_info *vi)
@@ -663,6 +692,7 @@ fill_more:
 	}
 
 	/* Enqueue batch as available. */
+	napi_disable(&vi->napi);
 	list_for_each_safe(pos, npos, &local_list) {
 		int err;
 
@@ -682,6 +712,8 @@ fill_more:
 	}
 	if (unlikely(vi->num > vi->max))
 		vi->max = vi->num;
+	virtqueue_kick(vi->rvq);
+	virtnet_napi_enable(vi);
 
 	/* Cleanup any remaining entries on the list */
 	if (unlikely(!list_empty(&local_list))) {
@@ -700,7 +732,7 @@ fill_more:
 
 /*
  * Refill the receive queues from process context.
- * Caller must serialize against NAPI.
+ * Callee will serialize against NAPI itself.
  * Returns false if we failed to allocate due to memory pressure.
  */
 static bool try_fill_recvbatch(struct virtnet_info *vi)
@@ -717,10 +749,7 @@ static void refill_work(struct work_struct *work)
 	bool still_empty;
 
 	vi = container_of(work, struct virtnet_info, refill.work);
-	napi_disable(&vi->napi);
 	still_empty = !try_fill_recvbatch(vi);
-	virtqueue_kick(vi->rvq);
-	virtnet_napi_enable(vi);
 
 	/* In theory, this can happen: if we don't get any buffers in
 	 * we will *never* try to fill again. */
