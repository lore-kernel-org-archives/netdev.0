From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next RFC 2/3] vhost: support urgent descriptors
Date: Sat, 11 Oct 2014 15:16:45 +0800
Message-ID: <1413011806-3813-3-git-send-email-jasowang@redhat.com>
References: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-api@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
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

This patches let vhost-net support urgent descriptors. For zerocopy case,
two new types of length was introduced to make it work.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c   | 43 +++++++++++++++++++++++++++++++------------
 drivers/vhost/scsi.c  | 23 +++++++++++++++--------
 drivers/vhost/test.c  |  5 +++--
 drivers/vhost/vhost.c | 44 +++++++++++++++++++++++++++++---------------
 drivers/vhost/vhost.h | 19 +++++++++++++------
 5 files changed, 91 insertions(+), 43 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 8dae2f7..37b0bb5 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -48,9 +48,13 @@ MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
  * status internally; used for zerocopy tx only.
  */
 /* Lower device DMA failed */
-#define VHOST_DMA_FAILED_LEN	3
+#define VHOST_DMA_FAILED_LEN	5
+/* Lower device DMA doen, urgent bit set */
+#define VHOST_DMA_DONE_LEN_URGENT	4
 /* Lower device DMA done */
-#define VHOST_DMA_DONE_LEN	2
+#define VHOST_DMA_DONE_LEN	3
+/* Lower device DMA in progress, urgent bit set */
+#define VHOST_DMA_URGENT	2
 /* Lower device DMA in progress */
 #define VHOST_DMA_IN_PROGRESS	1
 /* Buffer unused */
@@ -284,11 +288,13 @@ static void vhost_zerocopy_signal_used(struct vhost_net *net,
 		container_of(vq, struct vhost_net_virtqueue, vq);
 	int i, add;
 	int j = 0;
+	bool urgent = false;
 
 	for (i = nvq->done_idx; i != nvq->upend_idx; i = (i + 1) % UIO_MAXIOV) {
 		if (vq->heads[i].len == VHOST_DMA_FAILED_LEN)
 			vhost_net_tx_err(net);
 		if (VHOST_DMA_IS_DONE(vq->heads[i].len)) {
+			urgent = urgent || vq->heads[i].len == VHOST_DMA_DONE_LEN_URGENT;
 			vq->heads[i].len = VHOST_DMA_CLEAR_LEN;
 			++j;
 		} else
@@ -296,7 +302,7 @@ static void vhost_zerocopy_signal_used(struct vhost_net *net,
 	}
 	while (j) {
 		add = min(UIO_MAXIOV - nvq->done_idx, j);
-		vhost_add_used_and_signal_n(vq->dev, vq,
+		vhost_add_used_and_signal_n(vq->dev, vq, urgent,
 					    &vq->heads[nvq->done_idx], add);
 		nvq->done_idx = (nvq->done_idx + add) % UIO_MAXIOV;
 		j -= add;
@@ -311,9 +317,14 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
 
 	rcu_read_lock_bh();
 
-	/* set len to mark this desc buffers done DMA */
-	vq->heads[ubuf->desc].len = success ?
-		VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
+	if (success) {
+		if (vq->heads[ubuf->desc].len == VHOST_DMA_IN_PROGRESS)
+			vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
+		else
+			vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN_URGENT;
+	} else {
+		vq->heads[ubuf->desc].len = VHOST_DMA_FAILED_LEN;
+	}
 	cnt = vhost_net_ubuf_put(ubufs);
 
 	/*
@@ -363,6 +374,7 @@ static void handle_tx(struct vhost_net *net)
 	zcopy = nvq->ubufs;
 
 	for (;;) {
+		bool urgent;
 		/* Release DMAs done buffers first */
 		if (zcopy)
 			vhost_zerocopy_signal_used(net, vq);
@@ -374,7 +386,7 @@ static void handle_tx(struct vhost_net *net)
 			      % UIO_MAXIOV == nvq->done_idx))
 			break;
 
-		head = vhost_get_vq_desc(vq, vq->iov,
+		head = vhost_get_vq_desc(vq, &urgent, vq->iov,
 					 ARRAY_SIZE(vq->iov),
 					 &out, &in,
 					 NULL, NULL);
@@ -417,7 +429,8 @@ static void handle_tx(struct vhost_net *net)
 			ubuf = nvq->ubuf_info + nvq->upend_idx;
 
 			vq->heads[nvq->upend_idx].id = head;
-			vq->heads[nvq->upend_idx].len = VHOST_DMA_IN_PROGRESS;
+			vq->heads[nvq->upend_idx].len = urgent ?
+				VHOST_DMA_URGENT : VHOST_DMA_IN_PROGRESS;
 			ubuf->callback = vhost_zerocopy_callback;
 			ubuf->ctx = nvq->ubufs;
 			ubuf->desc = nvq->upend_idx;
@@ -445,7 +458,7 @@ static void handle_tx(struct vhost_net *net)
 			pr_debug("Truncated TX packet: "
 				 " len %d != %zd\n", err, len);
 		if (!zcopy_used)
-			vhost_add_used_and_signal(&net->dev, vq, head, 0);
+			vhost_add_used_and_signal(&net->dev, vq, urgent, head, 0);
 		else
 			vhost_zerocopy_signal_used(net, vq);
 		total_len += len;
@@ -488,6 +501,7 @@ static int peek_head_len(struct sock *sk)
  *	returns number of buffer heads allocated, negative on error
  */
 static int get_rx_bufs(struct vhost_virtqueue *vq,
+		       bool *urgentp,
 		       struct vring_used_elem *heads,
 		       int datalen,
 		       unsigned *iovcount,
@@ -502,11 +516,13 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 	int r, nlogs = 0;
 
 	while (datalen > 0 && headcount < quota) {
+		bool urgent = false;
+
 		if (unlikely(seg >= UIO_MAXIOV)) {
 			r = -ENOBUFS;
 			goto err;
 		}
-		r = vhost_get_vq_desc(vq, vq->iov + seg,
+		r = vhost_get_vq_desc(vq, &urgent, vq->iov + seg,
 				      ARRAY_SIZE(vq->iov) - seg, &out,
 				      &in, log, log_num);
 		if (unlikely(r < 0))
@@ -527,6 +543,7 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 			nlogs += *log_num;
 			log += *log_num;
 		}
+		*urgentp = *urgentp || urgent;
 		heads[headcount].id = d;
 		heads[headcount].len = iov_length(vq->iov + seg, in);
 		datalen -= heads[headcount].len;
@@ -590,9 +607,11 @@ static void handle_rx(struct vhost_net *net)
 	mergeable = vhost_has_feature(vq, VIRTIO_NET_F_MRG_RXBUF);
 
 	while ((sock_len = peek_head_len(sock->sk))) {
+		bool urgent = false;
+
 		sock_len += sock_hlen;
 		vhost_len = sock_len + vhost_hlen;
-		headcount = get_rx_bufs(vq, vq->heads, vhost_len,
+		headcount = get_rx_bufs(vq, &urgent, vq->heads, vhost_len,
 					&in, vq_log, &log,
 					likely(mergeable) ? UIO_MAXIOV : 1);
 		/* On error, stop handling until the next kick. */
@@ -654,7 +673,7 @@ static void handle_rx(struct vhost_net *net)
 			vhost_discard_vq_desc(vq, headcount);
 			break;
 		}
-		vhost_add_used_and_signal_n(&net->dev, vq, vq->heads,
+		vhost_add_used_and_signal_n(&net->dev, vq, urgent, vq->heads,
 					    headcount);
 		if (unlikely(vq_log))
 			vhost_log_write(vq, vq_log, log, vhost_len);
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index 69906ca..0a7e5bc 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -72,6 +72,8 @@ struct tcm_vhost_cmd {
 	int tvc_vq_desc;
 	/* virtio-scsi initiator task attribute */
 	int tvc_task_attr;
+	/* Descriptor urgent? */
+	bool tvc_vq_desc_urgent;
 	/* virtio-scsi initiator data direction */
 	enum dma_data_direction tvc_data_direction;
 	/* Expected data transfer length from virtio-scsi header */
@@ -606,6 +608,7 @@ tcm_vhost_do_evt_work(struct vhost_scsi *vs, struct tcm_vhost_evt *evt)
 	struct virtio_scsi_event __user *eventp;
 	unsigned out, in;
 	int head, ret;
+	bool urgent;
 
 	if (!vq->private_data) {
 		vs->vs_events_missed = true;
@@ -614,7 +617,7 @@ tcm_vhost_do_evt_work(struct vhost_scsi *vs, struct tcm_vhost_evt *evt)
 
 again:
 	vhost_disable_notify(&vs->dev, vq);
-	head = vhost_get_vq_desc(vq, vq->iov,
+	head = vhost_get_vq_desc(vq, &urgent, vq->iov,
 			ARRAY_SIZE(vq->iov), &out, &in,
 			NULL, NULL);
 	if (head < 0) {
@@ -643,7 +646,7 @@ again:
 	eventp = vq->iov[out].iov_base;
 	ret = __copy_to_user(eventp, event, sizeof(*event));
 	if (!ret)
-		vhost_add_used_and_signal(&vs->dev, vq, head, 0);
+		vhost_add_used_and_signal(&vs->dev, vq, urgent, head, 0);
 	else
 		vq_err(vq, "Faulted on tcm_vhost_send_event\n");
 }
@@ -704,7 +707,8 @@ static void vhost_scsi_complete_cmd_work(struct vhost_work *work)
 		ret = copy_to_user(cmd->tvc_resp, &v_rsp, sizeof(v_rsp));
 		if (likely(ret == 0)) {
 			struct vhost_scsi_virtqueue *q;
-			vhost_add_used(cmd->tvc_vq, cmd->tvc_vq_desc, 0);
+			vhost_add_used(cmd->tvc_vq, cmd->tvc_vq_desc_urgent,
+				       cmd->tvc_vq_desc, 0);
 			q = container_of(cmd->tvc_vq, struct vhost_scsi_virtqueue, vq);
 			vq = q - vs->vqs;
 			__set_bit(vq, signal);
@@ -947,6 +951,7 @@ static void tcm_vhost_submission_work(struct work_struct *work)
 static void
 vhost_scsi_send_bad_target(struct vhost_scsi *vs,
 			   struct vhost_virtqueue *vq,
+			   bool urgent,
 			   int head, unsigned out)
 {
 	struct virtio_scsi_cmd_resp __user *resp;
@@ -958,7 +963,7 @@ vhost_scsi_send_bad_target(struct vhost_scsi *vs,
 	resp = vq->iov[out].iov_base;
 	ret = __copy_to_user(resp, &rsp, sizeof(rsp));
 	if (!ret)
-		vhost_add_used_and_signal(&vs->dev, vq, head, 0);
+		vhost_add_used_and_signal(&vs->dev, vq, urgent, head, 0);
 	else
 		pr_err("Faulted on virtio_scsi_cmd_resp\n");
 }
@@ -980,6 +985,7 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 	u8 *target, *lunp, task_attr;
 	bool hdr_pi;
 	void *req, *cdb;
+	bool urgent;
 
 	mutex_lock(&vq->mutex);
 	/*
@@ -993,7 +999,7 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 	vhost_disable_notify(&vs->dev, vq);
 
 	for (;;) {
-		head = vhost_get_vq_desc(vq, vq->iov,
+		head = vhost_get_vq_desc(vq, &urgent, vq->iov,
 					ARRAY_SIZE(vq->iov), &out, &in,
 					NULL, NULL);
 		pr_debug("vhost_get_vq_desc: head: %d, out: %u in: %u\n",
@@ -1067,7 +1073,7 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 
 		/* virtio-scsi spec requires byte 0 of the lun to be 1 */
 		if (unlikely(*lunp != 1)) {
-			vhost_scsi_send_bad_target(vs, vq, head, out);
+			vhost_scsi_send_bad_target(vs, vq, urgent, head, out);
 			continue;
 		}
 
@@ -1075,7 +1081,7 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 
 		/* Target does not exist, fail the request */
 		if (unlikely(!tpg)) {
-			vhost_scsi_send_bad_target(vs, vq, head, out);
+			vhost_scsi_send_bad_target(vs, vq, urgent, head, out);
 			continue;
 		}
 
@@ -1187,6 +1193,7 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 		 * tcm_vhost_queue_data_in() and tcm_vhost_queue_status()
 		 */
 		cmd->tvc_vq_desc = head;
+		cmd->tvc_vq_desc_urgent = urgent;
 		/*
 		 * Dispatch tv_cmd descriptor for cmwq execution in process
 		 * context provided by tcm_vhost_workqueue.  This also ensures
@@ -1203,7 +1210,7 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 err_free:
 	vhost_scsi_free_cmd(cmd);
 err_cmd:
-	vhost_scsi_send_bad_target(vs, vq, head, out);
+	vhost_scsi_send_bad_target(vs, vq, urgent, head, out);
 out:
 	mutex_unlock(&vq->mutex);
 }
diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
index d9c501e..757f3a2 100644
--- a/drivers/vhost/test.c
+++ b/drivers/vhost/test.c
@@ -42,6 +42,7 @@ static void handle_vq(struct vhost_test *n)
 	int head;
 	size_t len, total_len = 0;
 	void *private;
+	bool urgent;
 
 	mutex_lock(&vq->mutex);
 	private = vq->private_data;
@@ -53,7 +54,7 @@ static void handle_vq(struct vhost_test *n)
 	vhost_disable_notify(&n->dev, vq);
 
 	for (;;) {
-		head = vhost_get_vq_desc(vq, vq->iov,
+		head = vhost_get_vq_desc(vq, &urgent, vq->iov,
 					 ARRAY_SIZE(vq->iov),
 					 &out, &in,
 					 NULL, NULL);
@@ -79,7 +80,7 @@ static void handle_vq(struct vhost_test *n)
 			vq_err(vq, "Unexpected 0 len for TX\n");
 			break;
 		}
-		vhost_add_used_and_signal(&n->dev, vq, head, 0);
+		vhost_add_used_and_signal(&n->dev, vq, urgent,  head, 0);
 		total_len += len;
 		if (unlikely(total_len >= VHOST_TEST_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c90f437..8a35e14 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -186,6 +186,7 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->last_used_idx = 0;
 	vq->signalled_used = 0;
 	vq->signalled_used_valid = false;
+	vq->urgent = false;
 	vq->used_flags = 0;
 	vq->log_used = false;
 	vq->log_addr = -1ull;
@@ -1201,7 +1202,7 @@ static int get_indirect(struct vhost_virtqueue *vq,
  * This function returns the descriptor number found, or vq->num (which is
  * never a valid descriptor number) if none was found.  A negative code is
  * returned on error. */
-int vhost_get_vq_desc(struct vhost_virtqueue *vq,
+int vhost_get_vq_desc(struct vhost_virtqueue *vq, bool *urgent,
 		      struct iovec iov[], unsigned int iov_size,
 		      unsigned int *out_num, unsigned int *in_num,
 		      struct vhost_log *log, unsigned int *log_num)
@@ -1211,6 +1212,8 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 	u16 last_avail_idx;
 	int ret;
 
+	*urgent = false;
+
 	/* Check it isn't doing very strange things with descriptor numbers. */
 	last_avail_idx = vq->last_avail_idx;
 	if (unlikely(__get_user(vq->avail_idx, &vq->avail->idx))) {
@@ -1274,6 +1277,8 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 			       i, vq->desc + i);
 			return -EFAULT;
 		}
+		if (desc.flags & VRING_DESC_F_URGENT)
+			*urgent = true;
 		if (desc.flags & VRING_DESC_F_INDIRECT) {
 			ret = get_indirect(vq, iov, iov_size,
 					   out_num, in_num,
@@ -1333,11 +1338,11 @@ EXPORT_SYMBOL_GPL(vhost_discard_vq_desc);
 
 /* After we've used one of their buffers, we tell them about it.  We'll then
  * want to notify the guest, using eventfd. */
-int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
+int vhost_add_used(struct vhost_virtqueue *vq, bool urgent, unsigned int head, int len)
 {
 	struct vring_used_elem heads = { head, len };
 
-	return vhost_add_used_n(vq, &heads, 1);
+	return vhost_add_used_n(vq, urgent, &heads, 1);
 }
 EXPORT_SYMBOL_GPL(vhost_add_used);
 
@@ -1386,7 +1391,8 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 
 /* After we've used one of their buffers, we tell them about it.  We'll then
  * want to notify the guest, using eventfd. */
-int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
+int vhost_add_used_n(struct vhost_virtqueue *vq, bool urgent,
+		     struct vring_used_elem *heads,
 		     unsigned count)
 {
 	int start, n, r;
@@ -1416,13 +1422,14 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 		if (vq->log_ctx)
 			eventfd_signal(vq->log_ctx, 1);
 	}
+	vq->urgent = vq->urgent || urgent;
 	return r;
 }
 EXPORT_SYMBOL_GPL(vhost_add_used_n);
 
 static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
-	__u16 old, new, event;
+	__u16 old, new, event, flags;
 	bool v;
 	/* Flush out used index updates. This is paired
 	 * with the barrier that the Guest executes when enabling
@@ -1433,14 +1440,17 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	    unlikely(vq->avail_idx == vq->last_avail_idx))
 		return true;
 
-	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX)) {
-		__u16 flags;
-		if (__get_user(flags, &vq->avail->flags)) {
-			vq_err(vq, "Failed to get flags");
-			return true;
-		}
-		return !(flags & VRING_AVAIL_F_NO_INTERRUPT);
+	if (__get_user(flags, &vq->avail->flags)) {
+		vq_err(vq, "Failed to get flags");
+		return true;
 	}
+
+	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX))
+		return !(flags & VRING_AVAIL_F_NO_INTERRUPT);
+
+	if (vq->urgent && !(flags & VRING_AVAIL_F_NO_URGENT_INTERRUPT))
+		return true;
+
 	old = vq->signalled_used;
 	v = vq->signalled_used_valid;
 	new = vq->signalled_used = vq->last_used_idx;
@@ -1460,17 +1470,20 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	/* Signal the Guest tell them we used something up. */
-	if (vq->call_ctx && vhost_notify(dev, vq))
+	if (vq->call_ctx && vhost_notify(dev, vq)) {
 		eventfd_signal(vq->call_ctx, 1);
+		vq->urgent = false;
+	}
 }
 EXPORT_SYMBOL_GPL(vhost_signal);
 
 /* And here's the combo meal deal.  Supersize me! */
 void vhost_add_used_and_signal(struct vhost_dev *dev,
 			       struct vhost_virtqueue *vq,
+			       bool urgent,
 			       unsigned int head, int len)
 {
-	vhost_add_used(vq, head, len);
+	vhost_add_used(vq, urgent, head, len);
 	vhost_signal(dev, vq);
 }
 EXPORT_SYMBOL_GPL(vhost_add_used_and_signal);
@@ -1478,9 +1491,10 @@ EXPORT_SYMBOL_GPL(vhost_add_used_and_signal);
 /* multi-buffer version of vhost_add_used_and_signal */
 void vhost_add_used_and_signal_n(struct vhost_dev *dev,
 				 struct vhost_virtqueue *vq,
+				 bool urgent,
 				 struct vring_used_elem *heads, unsigned count)
 {
-	vhost_add_used_n(vq, heads, count);
+	vhost_add_used_n(vq, urgent, heads, count);
 	vhost_signal(dev, vq);
 }
 EXPORT_SYMBOL_GPL(vhost_add_used_and_signal_n);
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 3eda654..61ca542 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -96,6 +96,9 @@ struct vhost_virtqueue {
 	/* Last used index value we have signalled on */
 	bool signalled_used_valid;
 
+	/* Urgent descriptor was used */
+	bool urgent;
+
 	/* Log writes to used structure. */
 	bool log_used;
 	u64 log_addr;
@@ -138,20 +141,24 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp);
 int vhost_vq_access_ok(struct vhost_virtqueue *vq);
 int vhost_log_access_ok(struct vhost_dev *);
 
-int vhost_get_vq_desc(struct vhost_virtqueue *,
+int vhost_get_vq_desc(struct vhost_virtqueue *, bool *urgent,
 		      struct iovec iov[], unsigned int iov_count,
 		      unsigned int *out_num, unsigned int *in_num,
 		      struct vhost_log *log, unsigned int *log_num);
 void vhost_discard_vq_desc(struct vhost_virtqueue *, int n);
 
 int vhost_init_used(struct vhost_virtqueue *);
-int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
-int vhost_add_used_n(struct vhost_virtqueue *, struct vring_used_elem *heads,
-		     unsigned count);
-void vhost_add_used_and_signal(struct vhost_dev *, struct vhost_virtqueue *,
+int vhost_add_used(struct vhost_virtqueue *, bool urgent,
+		   unsigned int head, int len);
+int vhost_add_used_n(struct vhost_virtqueue *, bool urgent,
+		     struct vring_used_elem *heads, unsigned count);
+void vhost_add_used_and_signal(struct vhost_dev *,
+			       struct vhost_virtqueue *,
+			       bool urgent,
 			       unsigned int id, int len);
 void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
-			       struct vring_used_elem *heads, unsigned count);
+				 bool urgent,
+				 struct vring_used_elem *heads, unsigned count);
 void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
 void vhost_disable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
-- 
1.8.3.1
