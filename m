From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 2/3] vhost-net: Unify the code of mergeable and big buffer
	handling
Date: Mon, 17 Jan 2011 16:11:08 +0800
Message-ID: <20110117081108.18900.60053.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
References: <20110117081058.18900.67456.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110117081058.18900.67456.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Codes duplication were found between the handling of mergeable and big
buffers, so this patch tries to unify them. This could be easily done
by adding a quota to the get_rx_bufs() which is used to limit the
number of buffers it returns (for mergeable buffer, the quota is
simply UIO_MAXIOV, for big buffers, the quota is just 1), and then the
previous handle_rx_mergeable() could be resued also for big buffers.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c |  128 +++------------------------------------------------
 1 files changed, 7 insertions(+), 121 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 95e49de..c32a2e4 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -227,6 +227,7 @@ static int peek_head_len(struct sock *sk)
  * @iovcount	- returned count of io vectors we fill
  * @log		- vhost log
  * @log_num	- log offset
+ * @quota       - headcount quota, 1 for big buffer
  *	returns number of buffer heads allocated, negative on error
  */
 static int get_rx_bufs(struct vhost_virtqueue *vq,
@@ -234,7 +235,8 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 		       int datalen,
 		       unsigned *iovcount,
 		       struct vhost_log *log,
-		       unsigned *log_num)
+		       unsigned *log_num,
+		       unsigned int quota)
 {
 	unsigned int out, in;
 	int seg = 0;
@@ -242,7 +244,7 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 	unsigned d;
 	int r, nlogs = 0;
 
-	while (datalen > 0) {
+	while (datalen > 0 && headcount < quota) {
 		if (unlikely(seg >= UIO_MAXIOV)) {
 			r = -ENOBUFS;
 			goto err;
@@ -282,116 +284,7 @@ err:
 
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
-static void handle_rx_big(struct vhost_net *net)
-{
-	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
-	unsigned out, in, log, s;
-	int head;
-	struct vhost_log *vq_log;
-	struct msghdr msg = {
-		.msg_name = NULL,
-		.msg_namelen = 0,
-		.msg_control = NULL, /* FIXME: get and handle RX aux data. */
-		.msg_controllen = 0,
-		.msg_iov = vq->iov,
-		.msg_flags = MSG_DONTWAIT,
-	};
-
-	struct virtio_net_hdr hdr = {
-		.flags = 0,
-		.gso_type = VIRTIO_NET_HDR_GSO_NONE
-	};
-
-	size_t len, total_len = 0;
-	int err;
-	size_t hdr_size;
-	struct socket *sock = rcu_dereference(vq->private_data);
-	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
-		return;
-
-	mutex_lock(&vq->mutex);
-	vhost_disable_notify(vq);
-	hdr_size = vq->vhost_hlen;
-
-	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
-		vq->log : NULL;
-
-	for (;;) {
-		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
-					 ARRAY_SIZE(vq->iov),
-					 &out, &in,
-					 vq_log, &log);
-		/* On error, stop handling until the next kick. */
-		if (unlikely(head < 0))
-			break;
-		/* OK, now we need to know about added descriptors. */
-		if (head == vq->num) {
-			if (unlikely(vhost_enable_notify(vq))) {
-				/* They have slipped one in as we were
-				 * doing that: check again. */
-				vhost_disable_notify(vq);
-				continue;
-			}
-			/* Nothing new?  Wait for eventfd to tell us
-			 * they refilled. */
-			break;
-		}
-		/* We don't need to be notified again. */
-		if (out) {
-			vq_err(vq, "Unexpected descriptor format for RX: "
-			       "out %d, int %d\n",
-			       out, in);
-			break;
-		}
-		/* Skip header. TODO: support TSO/mergeable rx buffers. */
-		s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
-		msg.msg_iovlen = in;
-		len = iov_length(vq->iov, in);
-		/* Sanity check */
-		if (!len) {
-			vq_err(vq, "Unexpected header len for RX: "
-			       "%zd expected %zd\n",
-			       iov_length(vq->hdr, s), hdr_size);
-			break;
-		}
-		err = sock->ops->recvmsg(NULL, sock, &msg,
-					 len, MSG_DONTWAIT | MSG_TRUNC);
-		/* TODO: Check specific error and bomb out unless EAGAIN? */
-		if (err < 0) {
-			vhost_discard_vq_desc(vq, 1);
-			break;
-		}
-		/* TODO: Should check and handle checksum. */
-		if (err > len) {
-			pr_debug("Discarded truncated rx packet: "
-				 " len %d > %zd\n", err, len);
-			vhost_discard_vq_desc(vq, 1);
-			continue;
-		}
-		len = err;
-		err = memcpy_toiovec(vq->hdr, (unsigned char *)&hdr, hdr_size);
-		if (err) {
-			vq_err(vq, "Unable to write vnet_hdr at addr %p: %d\n",
-			       vq->iov->iov_base, err);
-			break;
-		}
-		len += hdr_size;
-		vhost_add_used_and_signal(&net->dev, vq, head, len);
-		if (unlikely(vq_log))
-			vhost_log_write(vq, vq_log, log, len);
-		total_len += len;
-		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
-			vhost_poll_queue(&vq->poll);
-			break;
-		}
-	}
-
-	mutex_unlock(&vq->mutex);
-}
-
-/* Expects to be always run from workqueue - which acts as
- * read-size critical section for our kind of RCU. */
-static void handle_rx_mergeable(struct vhost_net *net)
+static void handle_rx(struct vhost_net *net)
 {
 	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
 	unsigned uninitialized_var(in), log;
@@ -431,7 +324,8 @@ static void handle_rx_mergeable(struct vhost_net *net)
 		sock_len += sock_hlen;
 		vhost_len = sock_len + vhost_hlen;
 		headcount = get_rx_bufs(vq, vq->heads, vhost_len,
-					&in, vq_log, &log);
+					&in, vq_log, &log,
+					likely(mergeable) ? UIO_MAXIOV : 1);
 		/* On error, stop handling until the next kick. */
 		if (unlikely(headcount < 0))
 			break;
@@ -497,14 +391,6 @@ static void handle_rx_mergeable(struct vhost_net *net)
 	mutex_unlock(&vq->mutex);
 }
 
-static void handle_rx(struct vhost_net *net)
-{
-	if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF))
-		handle_rx_mergeable(net);
-	else
-		handle_rx_big(net);
-}
-
 static void handle_tx_kick(struct vhost_work *work)
 {
 	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
