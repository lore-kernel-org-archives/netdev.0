From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH v3] Add Mergeable receive buffer support to vhost_net
Date: Tue, 06 Apr 2010 13:32:53 -0700
Message-ID: <1270585973.28407.3.camel@lab1.dls>
Reply-To: dlstevens@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:38830 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187Ab0DFUf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 16:35:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds support for the Mergeable Receive Buffers feature to
vhost_net.

						+-DLS

Changes from previous revision:
1) renamed:
	vhost_discard_vq_desc -> vhost_discard_desc
	vhost_get_heads -> vhost_get_desc_n
	vhost_get_vq_desc -> vhost_get_desc
2) added heads as argument to ghost_get_desc_n
3) changed "vq->heads" from iovec to vring_used_elem, removed casts
4) changed vhost_add_used to do multiple elements in a single
copy_to_user,
	or two when we wrap the ring.
5) removed rxmaxheadcount and available buffer checks in favor of
running until
	an allocation failure, but making sure we break the loop if we get
	two in a row, indicating we have at least 1 buffer, but not enough
	for the current receive packet
6) restore non-vnet header handling

Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

diff -ruNp net-next-p0/drivers/vhost/net.c
net-next-v3/drivers/vhost/net.c
--- net-next-p0/drivers/vhost/net.c	2010-03-22 12:04:38.000000000 -0700
+++ net-next-v3/drivers/vhost/net.c	2010-04-06 12:54:56.000000000 -0700
@@ -130,9 +130,8 @@ static void handle_tx(struct vhost_net *
 	hdr_size = vq->hdr_size;
 
 	for (;;) {
-		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
-					 ARRAY_SIZE(vq->iov),
-					 &out, &in,
+		head = vhost_get_desc(&net->dev, vq, vq->iov,
+					 ARRAY_SIZE(vq->iov), &out, &in,
 					 NULL, NULL);
 		/* Nothing new?  Wait for eventfd to tell us they refilled. */
 		if (head == vq->num) {
@@ -167,8 +166,15 @@ static void handle_tx(struct vhost_net *
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
 		err = sock->ops->sendmsg(NULL, sock, &msg, len);
 		if (unlikely(err < 0)) {
-			vhost_discard_vq_desc(vq);
-			tx_poll_start(net, sock);
+			if (err == -EAGAIN) {
+				vhost_discard_desc(vq, 1);
+				tx_poll_start(net, sock);
+			} else {
+				vq_err(vq, "sendmsg: errno %d\n", -err);
+				/* drop packet; do not discard/resend */
+				vhost_add_used_and_signal(&net->dev, vq, head,
+							  0);
+			}
 			break;
 		}
 		if (err != len)
@@ -186,12 +192,25 @@ static void handle_tx(struct vhost_net *
 	unuse_mm(net->dev.mm);
 }
 
+static int vhost_head_len(struct sock *sk)
+{
+	struct sk_buff *head;
+	int len = 0;
+
+	lock_sock(sk);
+	head = skb_peek(&sk->sk_receive_queue);
+	if (head)
+		len = head->len;
+	release_sock(sk);
+	return len;
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_rx(struct vhost_net *net)
 {
 	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
-	unsigned head, out, in, log, s;
+	unsigned in, log, s;
 	struct vhost_log *vq_log;
 	struct msghdr msg = {
 		.msg_name = NULL,
@@ -202,13 +221,14 @@ static void handle_rx(struct vhost_net *
 		.msg_flags = MSG_DONTWAIT,
 	};
 
-	struct virtio_net_hdr hdr = {
-		.flags = 0,
-		.gso_type = VIRTIO_NET_HDR_GSO_NONE
+	struct virtio_net_hdr_mrg_rxbuf hdr = {
+		.hdr.flags = 0,
+		.hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
 	};
 
+	int retries = 0;
 	size_t len, total_len = 0;
-	int err;
+	int err, headcount, datalen;
 	size_t hdr_size;
 	struct socket *sock = rcu_dereference(vq->private_data);
 	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
@@ -222,31 +242,25 @@ static void handle_rx(struct vhost_net *
 	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
 		vq->log : NULL;
 
-	for (;;) {
-		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
-					 ARRAY_SIZE(vq->iov),
-					 &out, &in,
-					 vq_log, &log);
+	while ((datalen = vhost_head_len(sock->sk))) {
+		headcount = vhost_get_desc_n(vq, vq->heads, datalen, &in,
+					     vq_log, &log);
 		/* OK, now we need to know about added descriptors. */
-		if (head == vq->num) {
-			if (unlikely(vhost_enable_notify(vq))) {
+		if (!headcount) {
+			if (retries == 0 && unlikely(vhost_enable_notify(vq))) {
 				/* They have slipped one in as we were
 				 * doing that: check again. */
 				vhost_disable_notify(vq);
+				retries++;
 				continue;
 			}
+			retries = 0;
 			/* Nothing new?  Wait for eventfd to tell us
 			 * they refilled. */
 			break;
 		}
 		/* We don't need to be notified again. */
-		if (out) {
-			vq_err(vq, "Unexpected descriptor format for RX: "
-			       "out %d, int %d\n",
-			       out, in);
-			break;
-		}
-		/* Skip header. TODO: support TSO/mergeable rx buffers. */
+		/* Skip header. TODO: support TSO. */
 		s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
 		msg.msg_iovlen = in;
 		len = iov_length(vq->iov, in);
@@ -261,14 +275,33 @@ static void handle_rx(struct vhost_net *
 					 len, MSG_DONTWAIT | MSG_TRUNC);
 		/* TODO: Check specific error and bomb out unless EAGAIN? */
 		if (err < 0) {
-			vhost_discard_vq_desc(vq);
+			vhost_discard_desc(vq, headcount);
 			break;
 		}
 		/* TODO: Should check and handle checksum. */
+		if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF)) {
+			struct virtio_net_hdr_mrg_rxbuf *vhdr =
+				(struct virtio_net_hdr_mrg_rxbuf *)
+				vq->iov[0].iov_base;
+			/* add num_buffers */
+			if (vhost_has_feature(&net->dev,
+					      VHOST_NET_F_VIRTIO_NET_HDR))
+				hdr.num_buffers = headcount;
+			else if (vq->iov[0].iov_len < sizeof(*vhdr)) {
+				vq_err(vq, "tiny buffers < %d unsupported",
+					vq->iov[0].iov_len);
+				vhost_discard_desc(vq, headcount);
+				break;
+			} else if (put_user(headcount, &vhdr->num_buffers)) {
+				vq_err(vq, "Failed num_buffers write");
+				vhost_discard_desc(vq, headcount);
+				break;
+			}
+		}
 		if (err > len) {
 			pr_err("Discarded truncated rx packet: "
 			       " len %d > %zd\n", err, len);
-			vhost_discard_vq_desc(vq);
+			vhost_discard_desc(vq, headcount);
 			continue;
 		}
 		len = err;
@@ -279,7 +312,7 @@ static void handle_rx(struct vhost_net *
 			break;
 		}
 		len += hdr_size;
-		vhost_add_used_and_signal(&net->dev, vq, head, len);
+		vhost_add_used_and_signal_n(&net->dev, vq, vq->heads, headcount);
 		if (unlikely(vq_log))
 			vhost_log_write(vq, vq_log, log, len);
 		total_len += len;
@@ -560,9 +593,14 @@ done:
 
 static int vhost_net_set_features(struct vhost_net *n, u64 features)
 {
-	size_t hdr_size = features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
-		sizeof(struct virtio_net_hdr) : 0;
+	size_t hdr_size = 0;
 	int i;
+
+	if (features & (1 << VHOST_NET_F_VIRTIO_NET_HDR)) {
+		hdr_size = sizeof(struct virtio_net_hdr);
+		if (features & (1 << VIRTIO_NET_F_MRG_RXBUF))
+			hdr_size = sizeof(struct virtio_net_hdr_mrg_rxbuf);
+	}
 	mutex_lock(&n->dev.mutex);
 	if ((features & (1 << VHOST_F_LOG_ALL)) &&
 	    !vhost_log_access_ok(&n->dev)) {
diff -ruNp net-next-p0/drivers/vhost/vhost.c
net-next-v3/drivers/vhost/vhost.c
--- net-next-p0/drivers/vhost/vhost.c	2010-03-22 12:04:38.000000000
-0700
+++ net-next-v3/drivers/vhost/vhost.c	2010-04-06 12:57:51.000000000
-0700
@@ -856,6 +856,47 @@ static unsigned get_indirect(struct vhos
 	return 0;
 }
 
+/* This is a multi-buffer version of vhost_get_vq_desc
+ * @vq		- the relevant virtqueue
+ * datalen	- data length we'll be reading
+ * @iovcount	- returned count of io vectors we fill
+ * @log		- vhost log
+ * @log_num	- log offset
+ *	returns number of buffer heads allocated, 0 on error
+ */
+int vhost_get_desc_n(struct vhost_virtqueue *vq, struct vring_used_elem
*heads,
+		     int datalen, int *iovcount, struct vhost_log *log,
+		     unsigned int *log_num)
+{
+	int out, in;
+	int seg = 0;		/* iov index */
+	int hc = 0;		/* head count */
+
+	while (datalen > 0) {
+		if (hc >= VHOST_NET_MAX_SG)
+			goto err;
+		heads[hc].id = vhost_get_desc(vq->dev, vq, vq->iov+seg,
+					      ARRAY_SIZE(vq->iov)-seg, &out,
+					      &in, log, log_num);
+		if (heads[hc].id == vq->num)
+			goto err;
+		if (out || in <= 0) {
+			vq_err(vq, "unexpected descriptor format for RX: "
+				"out %d, in %d\n", out, in);
+			goto err;
+		}
+		heads[hc].len = iov_length(vq->iov+seg, in);
+		datalen -= heads[hc].len;
+		hc++;
+		seg += in;
+	}
+	*iovcount = seg;
+	return hc;
+err:
+	vhost_discard_desc(vq, hc);
+	return 0;
+}
+
 /* This looks in the virtqueue and for the first available buffer, and
converts
  * it to an iovec for convenient access.  Since descriptors consist of
some
  * number of output then some number of input descriptors, it's
actually two
@@ -863,7 +904,7 @@ static unsigned get_indirect(struct vhos
  *
  * This function returns the descriptor number found, or vq->num (which
  * is never a valid descriptor number) if none was found. */
-unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct
vhost_virtqueue *vq,
+unsigned vhost_get_desc(struct vhost_dev *dev, struct vhost_virtqueue
*vq,
 			   struct iovec iov[], unsigned int iov_size,
 			   unsigned int *out_num, unsigned int *in_num,
 			   struct vhost_log *log, unsigned int *log_num)
@@ -981,31 +1022,42 @@ unsigned vhost_get_vq_desc(struct vhost_
 }
 
 /* Reverse the effect of vhost_get_vq_desc. Useful for error handling.
*/
-void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
+void vhost_discard_desc(struct vhost_virtqueue *vq, int n)
 {
-	vq->last_avail_idx--;
+	vq->last_avail_idx -= n;
 }
 
 /* After we've used one of their buffers, we tell them about it.  We'll
then
  * want to notify the guest, using eventfd. */
-int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int
len)
+int vhost_add_used(struct vhost_virtqueue *vq, struct vring_used_elem
*heads,
+		   int count)
 {
 	struct vring_used_elem *used;
+	int start, n;
+
+	if (count <= 0)
+		return -EINVAL;
 
-	/* The virtqueue contains a ring of used buffers.  Get a pointer to
the
-	 * next entry in that used ring. */
-	used = &vq->used->ring[vq->last_used_idx % vq->num];
-	if (put_user(head, &used->id)) {
-		vq_err(vq, "Failed to write used id");
+	start = vq->last_used_idx % vq->num;
+	if (vq->num - start < count)
+		n = vq->num - start;
+	else
+		n = count;
+	used = vq->used->ring + start;
+	if (copy_to_user(used, heads, sizeof(heads[0])*n)) {
+		vq_err(vq, "Failed to write used");
 		return -EFAULT;
 	}
-	if (put_user(len, &used->len)) {
-		vq_err(vq, "Failed to write used len");
-		return -EFAULT;
+	if (n < count) {	/* wrapped the ring */
+		used = vq->used->ring;
+		if (copy_to_user(used, heads+n, sizeof(heads[0])*(count-n))) {
+			vq_err(vq, "Failed to write used");
+			return -EFAULT;
+		}
 	}
 	/* Make sure buffer is written before we update index. */
 	smp_wmb();
-	if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
+	if (put_user(vq->last_used_idx+count, &vq->used->idx)) {
 		vq_err(vq, "Failed to increment used idx");
 		return -EFAULT;
 	}
@@ -1023,7 +1075,7 @@ int vhost_add_used(struct vhost_virtqueu
 		if (vq->log_ctx)
 			eventfd_signal(vq->log_ctx, 1);
 	}
-	vq->last_used_idx++;
+	vq->last_used_idx += count;
 	return 0;
 }
 
@@ -1049,10 +1101,23 @@ void vhost_signal(struct vhost_dev *dev,
 
 /* And here's the combo meal deal.  Supersize me! */
 void vhost_add_used_and_signal(struct vhost_dev *dev,
-			       struct vhost_virtqueue *vq,
-			       unsigned int head, int len)
+			       struct vhost_virtqueue *vq, unsigned int id,
+			       int len)
+{
+	struct vring_used_elem head;
+
+	head.id = id;
+	head.len = len;
+	vhost_add_used(vq, &head, 1);
+	vhost_signal(dev, vq);
+}
+
+/* multi-buffer version of vhost_add_used_and_signal */
+void vhost_add_used_and_signal_n(struct vhost_dev *dev,
+				 struct vhost_virtqueue *vq,
+				 struct vring_used_elem *heads, int count)
 {
-	vhost_add_used(vq, head, len);
+	vhost_add_used(vq, heads, count);
 	vhost_signal(dev, vq);
 }
 
diff -ruNp net-next-p0/drivers/vhost/vhost.h
net-next-v3/drivers/vhost/vhost.h
--- net-next-p0/drivers/vhost/vhost.h	2010-03-22 12:04:38.000000000
-0700
+++ net-next-v3/drivers/vhost/vhost.h	2010-04-05 20:33:57.000000000
-0700
@@ -85,6 +85,7 @@ struct vhost_virtqueue {
 	struct iovec iov[VHOST_NET_MAX_SG];
 	struct iovec hdr[VHOST_NET_MAX_SG];
 	size_t hdr_size;
+	struct vring_used_elem heads[VHOST_NET_MAX_SG];
 	/* We use a kind of RCU to access private pointer.
 	 * All readers access it from workqueue, which makes it possible to
 	 * flush the workqueue instead of synchronize_rcu. Therefore readers
do
@@ -120,16 +121,22 @@ long vhost_dev_ioctl(struct vhost_dev *,
 int vhost_vq_access_ok(struct vhost_virtqueue *vq);
 int vhost_log_access_ok(struct vhost_dev *);
 
-unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue
*,
+int vhost_get_desc_n(struct vhost_virtqueue *, struct vring_used_elem
*heads,
+		     int datalen, int *iovcount, struct vhost_log *log,
+		     unsigned int *log_num);
+unsigned vhost_get_desc(struct vhost_dev *, struct vhost_virtqueue *,
 			   struct iovec iov[], unsigned int iov_count,
 			   unsigned int *out_num, unsigned int *in_num,
 			   struct vhost_log *log, unsigned int *log_num);
-void vhost_discard_vq_desc(struct vhost_virtqueue *);
+void vhost_discard_desc(struct vhost_virtqueue *, int);
 
-int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int
len);
-void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
+int vhost_add_used(struct vhost_virtqueue *, struct vring_used_elem
*heads,
+		    int count);
 void vhost_add_used_and_signal(struct vhost_dev *, struct
vhost_virtqueue *,
-			       unsigned int head, int len);
+			       unsigned int id, int len);
+void vhost_add_used_and_signal_n(struct vhost_dev *, struct
vhost_virtqueue *,
+			       struct vring_used_elem *heads, int count);
+void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
 void vhost_disable_notify(struct vhost_virtqueue *);
 bool vhost_enable_notify(struct vhost_virtqueue *);
 
@@ -149,7 +156,8 @@ enum {
 	VHOST_FEATURES = (1 << VIRTIO_F_NOTIFY_ON_EMPTY) |
 			 (1 << VIRTIO_RING_F_INDIRECT_DESC) |
 			 (1 << VHOST_F_LOG_ALL) |
-			 (1 << VHOST_NET_F_VIRTIO_NET_HDR),
+			 (1 << VHOST_NET_F_VIRTIO_NET_HDR) |
+			 (1 << VIRTIO_NET_F_MRG_RXBUF),
 };
 
 static inline int vhost_has_feature(struct vhost_dev *dev, int bit)


