From: xiaohui.xin@intel.com
Subject: Re:[PATCH v1 2/3] Provides multiple submits and asynchronous notifications.
Date: Thu,  8 Apr 2010 17:07:55 +0800
Message-ID: <1270717675-5041-1-git-send-email-xiaohui.xin@intel.com>
References: <20100407081800.GC9550@redhat.com>
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, jdike@linux.intel.com,
	Xin Xiaohui <xiaohui.xin@intel.com>
To: mst@mst.redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100407081800.GC9550@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

---
Michael,
This is a small patch for the write logging issue with async queue.
I have made a __vhost_get_vq_desc() func which may compute the log
info with any valid buffer index. The __vhost_get_vq_desc() is 
coming from the code in vq_get_vq_desc().
And I use it to recompute the log info when logging is enabled.

Thanks
Xiaohui

 drivers/vhost/net.c   |   27 ++++++++---
 drivers/vhost/vhost.c |  115 ++++++++++++++++++++++++++++---------------------
 drivers/vhost/vhost.h |    5 ++
 3 files changed, 90 insertions(+), 57 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 2aafd90..00a45ef 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -115,7 +115,8 @@ static void handle_async_rx_events_notify(struct vhost_net *net,
 	struct kiocb *iocb = NULL;
 	struct vhost_log *vq_log = NULL;
 	int rx_total_len = 0;
-	int log, size;
+	unsigned int head, log, in, out;
+	int size;
 
 	if (vq->link_state != VHOST_VQ_LINK_ASYNC)
 		return;
@@ -130,14 +131,25 @@ static void handle_async_rx_events_notify(struct vhost_net *net,
 				iocb->ki_pos, iocb->ki_nbytes);
 		log = (int)iocb->ki_user_data;
 		size = iocb->ki_nbytes;
+		head = iocb->ki_pos;
 		rx_total_len += iocb->ki_nbytes;
 
 		if (iocb->ki_dtor)
 			iocb->ki_dtor(iocb);
 		kmem_cache_free(net->cache, iocb);
 
-		if (unlikely(vq_log))
+		/* when log is enabled, recomputing the log info is needed,
+		 * since these buffers are in async queue, and may not get
+		 * the log info before.
+		 */
+		if (unlikely(vq_log)) {
+			if (!log)
+				__vhost_get_vq_desc(&net->dev, vq, vq->iov,
+						    ARRAY_SIZE(vq->iov),
+						    &out, &in, vq_log,
+						    &log, head);
 			vhost_log_write(vq, vq_log, log, size);
+		}
 		if (unlikely(rx_total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
 			break;
@@ -313,14 +325,13 @@ static void handle_rx(struct vhost_net *net)
 	vhost_disable_notify(vq);
 	hdr_size = vq->hdr_size;
 
-	/* In async cases, for write logging, the simple way is to get
-	 * the log info always, and really logging is decided later.
-	 * Thus, when logging enabled, we can get log, and when logging
-	 * disabled, we can get log disabled accordingly.
+	/* In async cases, when write log is enabled, in case the submitted
+	 * buffers did not get log info before the log enabling, so we'd
+	 * better recompute the log info when needed. We do this in
+	 * handle_async_rx_events_notify().
 	 */
 
-	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) |
-		(vq->link_state == VHOST_VQ_LINK_ASYNC) ?
+	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
 		vq->log : NULL;
 
 	handle_async_rx_events_notify(net, vq);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 97233d5..53dab80 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -715,66 +715,21 @@ static unsigned get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 	return 0;
 }
 
-/* This looks in the virtqueue and for the first available buffer, and converts
- * it to an iovec for convenient access.  Since descriptors consist of some
- * number of output then some number of input descriptors, it's actually two
- * iovecs, but we pack them into one and note how many of each there were.
- *
- * This function returns the descriptor number found, or vq->num (which
- * is never a valid descriptor number) if none was found. */
-unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
+unsigned __vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 			   struct iovec iov[], unsigned int iov_size,
 			   unsigned int *out_num, unsigned int *in_num,
-			   struct vhost_log *log, unsigned int *log_num)
+			   struct vhost_log *log, unsigned int *log_num,
+			   unsigned int head)
 {
 	struct vring_desc desc;
-	unsigned int i, head, found = 0;
-	u16 last_avail_idx;
+	unsigned int i = head, found = 0;
 	int ret;
 
-	/* Check it isn't doing very strange things with descriptor numbers. */
-	last_avail_idx = vq->last_avail_idx;
-	if (get_user(vq->avail_idx, &vq->avail->idx)) {
-		vq_err(vq, "Failed to access avail idx at %p\n",
-		       &vq->avail->idx);
-		return vq->num;
-	}
-
-	if ((u16)(vq->avail_idx - last_avail_idx) > vq->num) {
-		vq_err(vq, "Guest moved used index from %u to %u",
-		       last_avail_idx, vq->avail_idx);
-		return vq->num;
-	}
-
-	/* If there's nothing new since last we looked, return invalid. */
-	if (vq->avail_idx == last_avail_idx)
-		return vq->num;
-
-	/* Only get avail ring entries after they have been exposed by guest. */
-	rmb();
-
-	/* Grab the next descriptor number they're advertising, and increment
-	 * the index we've seen. */
-	if (get_user(head, &vq->avail->ring[last_avail_idx % vq->num])) {
-		vq_err(vq, "Failed to read head: idx %d address %p\n",
-		       last_avail_idx,
-		       &vq->avail->ring[last_avail_idx % vq->num]);
-		return vq->num;
-	}
-
-	/* If their number is silly, that's an error. */
-	if (head >= vq->num) {
-		vq_err(vq, "Guest says index %u > %u is available",
-		       head, vq->num);
-		return vq->num;
-	}
-
 	/* When we start there are none of either input nor output. */
 	*out_num = *in_num = 0;
 	if (unlikely(log))
 		*log_num = 0;
 
-	i = head;
 	do {
 		unsigned iov_count = *in_num + *out_num;
 		if (i >= vq->num) {
@@ -833,8 +788,70 @@ unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 			*out_num += ret;
 		}
 	} while ((i = next_desc(&desc)) != -1);
+	return head;
+}
+
+/* This looks in the virtqueue and for the first available buffer, and converts
+ * it to an iovec for convenient access.  Since descriptors consist of some
+ * number of output then some number of input descriptors, it's actually two
+ * iovecs, but we pack them into one and note how many of each there were.
+ *
+ * This function returns the descriptor number found, or vq->num (which
+ * is never a valid descriptor number) if none was found. */
+unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
+			   struct iovec iov[], unsigned int iov_size,
+			   unsigned int *out_num, unsigned int *in_num,
+			   struct vhost_log *log, unsigned int *log_num)
+{
+	struct vring_desc desc;
+	unsigned int i, head, found = 0;
+	u16 last_avail_idx;
+	unsigned int ret;
+
+	/* Check it isn't doing very strange things with descriptor numbers. */
+	last_avail_idx = vq->last_avail_idx;
+	if (get_user(vq->avail_idx, &vq->avail->idx)) {
+		vq_err(vq, "Failed to access avail idx at %p\n",
+		       &vq->avail->idx);
+		return vq->num;
+	}
+
+	if ((u16)(vq->avail_idx - last_avail_idx) > vq->num) {
+		vq_err(vq, "Guest moved used index from %u to %u",
+		       last_avail_idx, vq->avail_idx);
+		return vq->num;
+	}
+
+	/* If there's nothing new since last we looked, return invalid. */
+	if (vq->avail_idx == last_avail_idx)
+		return vq->num;
+
+	/* Only get avail ring entries after they have been exposed by guest. */
+	rmb();
+
+	/* Grab the next descriptor number they're advertising, and increment
+	 * the index we've seen. */
+	if (get_user(head, &vq->avail->ring[last_avail_idx % vq->num])) {
+		vq_err(vq, "Failed to read head: idx %d address %p\n",
+		       last_avail_idx,
+		       &vq->avail->ring[last_avail_idx % vq->num]);
+		return vq->num;
+	}
+
+	/* If their number is silly, that's an error. */
+	if (head >= vq->num) {
+		vq_err(vq, "Guest says index %u > %u is available",
+		       head, vq->num);
+		return vq->num;
+	}
+
+	ret = __vhost_get_vq_desc(dev, vq, iov, iov_size,
+				  out_num, in_num,
+				  log, log_num, head);
 
 	/* On success, increment avail index. */
+	if (ret == vq->num)
+		return ret;
 	vq->last_avail_idx++;
 	return head;
 }
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index cffe39a..a74a6d4 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -132,6 +132,11 @@ unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
 			   struct iovec iov[], unsigned int iov_count,
 			   unsigned int *out_num, unsigned int *in_num,
 			   struct vhost_log *log, unsigned int *log_num);
+unsigned __vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
+			   struct iovec iov[], unsigned int iov_count,
+			   unsigned int *out_num, unsigned int *in_num,
+			   struct vhost_log *log, unsigned int *log_num,
+			   unsigned int head);
 void vhost_discard_vq_desc(struct vhost_virtqueue *);
 
 int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
-- 
1.5.4.4
