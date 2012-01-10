From: Mike Waychison <mikew@google.com>
Subject: [PATCH v2 1/3] virtio_net: Split receive buffer alloc/add
Date: Tue, 10 Jan 2012 09:41:01 -0800
Message-ID: <20120110174100.4505.8939.stgit@mike2.sea.corp.google.com>
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

In preparation for allocating receive buffers in the slow path without
disabling NAPI, split the allocation and addition of receive buffers
apart into two separate functions (per receive buffer type).

While here, move the vi->num accounting into the add functions.

Signed-off-by: Mike Waychison <mikew@google.com>
---
 drivers/net/virtio_net.c |  150 +++++++++++++++++++++++++++++++++++-----------
 1 files changed, 113 insertions(+), 37 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 76fe14e..5531089 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -353,17 +353,35 @@ frame_err:
 	dev_kfree_skb(skb);
 }
 
-static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
+/*
+ * Allocate an skb for "small" receive buffer configurations.
+ * May return NULL if oom.
+ * No serialization required.
+ */
+static struct sk_buff *alloc_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
 {
 	struct sk_buff *skb;
-	struct skb_vnet_hdr *hdr;
-	int err;
 
 	skb = __netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN, gfp);
 	if (unlikely(!skb))
-		return -ENOMEM;
+		return NULL;
 
 	skb_put(skb, MAX_PACKET_LEN);
+	return skb;
+}
+
+/*
+ * Add a skb to the receive queue for "small" receive buffer configurations.
+ * Returns the number of virtqueue slots left free on success, negative errno
+ * otherwise.
+ * Always consumes skb.
+ * Must be serialized with the napi poll path.
+ */
+static int add_recvbuf_small(struct virtnet_info *vi, struct sk_buff *skb,
+			     gfp_t gfp)
+{
+	struct skb_vnet_hdr *hdr;
+	int err;
 
 	hdr = skb_vnet_hdr(skb);
 	sg_set_buf(vi->rx_sg, &hdr->hdr, sizeof hdr->hdr);
@@ -373,36 +391,54 @@ static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
 	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, 2, skb, gfp);
 	if (err < 0)
 		dev_kfree_skb(skb);
+	else
+		vi->num++;
 
 	return err;
 }
 
-static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
+/*
+ * Allocate an list of pages for "big" receive buffer configurations.
+ * Pages are chained through ->private.
+ * May return null if oom.
+ * No serialization required.
+ */
+static struct page *alloc_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
 {
-	struct page *first, *list = NULL;
-	char *p;
-	int i, err, offset;
+	struct page *first, *tail = NULL;
+	int i;
 
-	/* page in vi->rx_sg[MAX_SKB_FRAGS + 1] is list tail */
-	for (i = MAX_SKB_FRAGS + 1; i > 1; --i) {
+	/* Build a list of pages chained through ->private.  Built in reverse order */
+	for (i = 0; i < MAX_SKB_FRAGS + 1; ++i) {
 		first = get_a_page(vi, gfp);
 		if (!first) {
-			if (list)
-				give_pages(vi, list);
-			return -ENOMEM;
+			if (tail)
+				give_pages(vi, tail);
+			return NULL;
 		}
-		sg_set_buf(&vi->rx_sg[i], page_address(first), PAGE_SIZE);
 
-		/* chain new page in list head to match sg */
-		first->private = (unsigned long)list;
-		list = first;
+		/* chain new page in list head  */
+		first->private = (unsigned long)tail;
+		tail = first;
 	}
+	return first;
+}
+
+/*
+ * Add a chain of pages to the receive queue for "big" receive buffer
+ * configurations.
+ * Returns the number of virtqueue slots left free on success, negative errno
+ * otherwise.
+ * Always consumes the entire chain of pages.
+ * Must be serialized with the napi poll path.
+ */
+static int add_recvbuf_big(struct virtnet_info *vi, struct page *first,
+			   gfp_t gfp)
+{
+	struct page *page;
+	char *p;
+	int i, err, offset;
 
-	first = get_a_page(vi, gfp);
-	if (!first) {
-		give_pages(vi, list);
-		return -ENOMEM;
-	}
 	p = page_address(first);
 
 	/* vi->rx_sg[0], vi->rx_sg[1] share the same page */
@@ -413,30 +449,55 @@ static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
 	offset = sizeof(struct padded_vnet_hdr);
 	sg_set_buf(&vi->rx_sg[1], p + offset, PAGE_SIZE - offset);
 
-	/* chain first in list head */
-	first->private = (unsigned long)list;
+	/* Chain in the rest of the pages */
+	i = 2;  /* Offset to insert further pages into the sg */
+	page = (struct page *)first->private;
+	while (page) {
+		sg_set_buf(&vi->rx_sg[i], page_address(page), PAGE_SIZE);
+		page = (struct page *)page->private;
+		i++;
+	}
+
 	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
 				    first, gfp);
 	if (err < 0)
 		give_pages(vi, first);
+	else
+		vi->num++;
 
 	return err;
 }
 
-static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
+/*
+ * Allocate a page for "mergeable" receive buffer configurations.
+ * May return NULL if oom.
+ * No serialization required.
+ */
+static struct page *alloc_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
+{
+	return get_a_page(vi, gfp);
+}
+
+/*
+ * Add a page to the receive queue for "mergeable" receive buffer
+ * configurations.
+ * Returns the number of virtqueue slots left free on success, negative errno
+ * otherwise.
+ * Always consumes the page.
+ * Must be serialized with the napi poll path.
+ */
+static int add_recvbuf_mergeable(struct virtnet_info *vi, struct page *page,
+				 gfp_t gfp)
 {
-	struct page *page;
 	int err;
 
-	page = get_a_page(vi, gfp);
-	if (!page)
-		return -ENOMEM;
-
 	sg_init_one(vi->rx_sg, page_address(page), PAGE_SIZE);
 
 	err = virtqueue_add_buf_gfp(vi->rvq, vi->rx_sg, 0, 1, page, gfp);
 	if (err < 0)
 		give_pages(vi, page);
+	else
+		vi->num++;
 
 	return err;
 }
@@ -454,17 +515,32 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 	bool oom;
 
 	do {
-		if (vi->mergeable_rx_bufs)
-			err = add_recvbuf_mergeable(vi, gfp);
-		else if (vi->big_packets)
-			err = add_recvbuf_big(vi, gfp);
-		else
-			err = add_recvbuf_small(vi, gfp);
+		if (vi->mergeable_rx_bufs) {
+			struct page *page;
+			page = alloc_recvbuf_mergeable(vi, gfp);
+			if (!page)
+				err = -ENOMEM;
+			else
+				err = add_recvbuf_mergeable(vi, page, gfp);
+		} else if (vi->big_packets) {
+			struct page *page;
+			page = alloc_recvbuf_big(vi, gfp);
+			if (!page)
+				err = -ENOMEM;
+			else
+				err = add_recvbuf_big(vi, page, gfp);
+		} else {
+			struct sk_buff *skb;
+			skb = alloc_recvbuf_small(vi, gfp);
+			if (!skb)
+				err = -ENOMEM;
+			else
+				err = add_recvbuf_small(vi, skb, gfp);
+		}
 
 		oom = err == -ENOMEM;
 		if (err < 0)
 			break;
-		++vi->num;
 	} while (err > 0);
 	if (unlikely(vi->num > vi->max))
 		vi->max = vi->num;
