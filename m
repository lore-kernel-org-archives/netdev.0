From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH v2] Add Mergeable RX buffer feature to vhost_net
Date: Tue, 30 Mar 2010 19:23:48 -0600
Message-ID: <OF35D5EAC9.45A7DC5F-ON882576F7.0006F45E-882576F7.0007AB62@us.ibm.com>
References: <20100308080733.GC7482@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 0007AB60882576F7_="
Cc: kvm@vger.kernel.org, kvm-owner@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:39002 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755411Ab0CaBXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 21:23:51 -0400
In-Reply-To: <20100308080733.GC7482@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=_mixed 0007AB60882576F7_=
Content-Type: text/plain; charset="US-ASCII"

This patch adds support for the Mergeable Receive Buffers feature to
vhost_net.

Changes:
        1) generalize descriptor allocation functions to allow multiple
                descriptors per packet
        2) add socket "peek" to know datalen at buffer allocation time
        3) change notification to enable a multi-buffer max packet, rather
                than the single-buffer run until completely empty

Changes from previous revision:
1) incorporate review comments from Michael Tsirkin
2) assume use of TUNSETVNETHDRSZ ioctl by qemu, which simplifies vnet 
header
        processing
3) fixed notification code to only affect the receive side

Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

[in-line for review, attached for applying w/o whitespace mangling]

diff -ruNp net-next-p0/drivers/vhost/net.c net-next-p3/drivers/vhost/net.c
--- net-next-p0/drivers/vhost/net.c     2010-03-22 12:04:38.000000000 
-0700
+++ net-next-p3/drivers/vhost/net.c     2010-03-30 12:50:57.000000000 
-0700
@@ -54,26 +54,6 @@ struct vhost_net {
        enum vhost_net_poll_state tx_poll_state;
 };
 
-/* Pop first len bytes from iovec. Return number of segments used. */
-static int move_iovec_hdr(struct iovec *from, struct iovec *to,
-                         size_t len, int iov_count)
-{
-       int seg = 0;
-       size_t size;
-       while (len && seg < iov_count) {
-               size = min(from->iov_len, len);
-               to->iov_base = from->iov_base;
-               to->iov_len = size;
-               from->iov_len -= size;
-               from->iov_base += size;
-               len -= size;
-               ++from;
-               ++to;
-               ++seg;
-       }
-       return seg;
-}
-
 /* Caller must have TX VQ lock */
 static void tx_poll_stop(struct vhost_net *net)
 {
@@ -97,7 +77,8 @@ static void tx_poll_start(struct vhost_n
 static void handle_tx(struct vhost_net *net)
 {
        struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
-       unsigned head, out, in, s;
+       unsigned out, in;
+       struct iovec head;
        struct msghdr msg = {
                .msg_name = NULL,
                .msg_namelen = 0,
@@ -108,8 +89,8 @@ static void handle_tx(struct vhost_net *
        };
        size_t len, total_len = 0;
        int err, wmem;
-       size_t hdr_size;
        struct socket *sock = rcu_dereference(vq->private_data);
+
        if (!sock)
                return;
 
@@ -127,22 +108,19 @@ static void handle_tx(struct vhost_net *
 
        if (wmem < sock->sk->sk_sndbuf / 2)
                tx_poll_stop(net);
-       hdr_size = vq->hdr_size;
 
        for (;;) {
-               head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
-                                        ARRAY_SIZE(vq->iov),
-                                        &out, &in,
-                                        NULL, NULL);
+               head.iov_base = (void *)vhost_get_vq_desc(&net->dev, vq,
+                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, NULL, 
NULL);
                /* Nothing new?  Wait for eventfd to tell us they 
refilled. */
-               if (head == vq->num) {
+               if (head.iov_base == (void *)vq->num) {
                        wmem = atomic_read(&sock->sk->sk_wmem_alloc);
                        if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
                                tx_poll_start(net, sock);
                                set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
                                break;
                        }
-                       if (unlikely(vhost_enable_notify(vq))) {
+                       if (unlikely(vhost_enable_notify(vq, 0))) {
                                vhost_disable_notify(vq);
                                continue;
                        }
@@ -154,27 +132,30 @@ static void handle_tx(struct vhost_net *
                        break;
                }
                /* Skip header. TODO: support TSO. */
-               s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
                msg.msg_iovlen = out;
-               len = iov_length(vq->iov, out);
+               head.iov_len = len = iov_length(vq->iov, out);
+
                /* Sanity check */
                if (!len) {
-                       vq_err(vq, "Unexpected header len for TX: "
-                              "%zd expected %zd\n",
-                              iov_length(vq->hdr, s), hdr_size);
+                       vq_err(vq, "Unexpected buffer len for TX: %zd ", 
len);
                        break;
                }
-               /* TODO: Check specific error and bomb out unless ENOBUFS? 
*/
                err = sock->ops->sendmsg(NULL, sock, &msg, len);
                if (unlikely(err < 0)) {
-                       vhost_discard_vq_desc(vq);
-                       tx_poll_start(net, sock);
+                       if (err == -EAGAIN) {
+                               vhost_discard_vq_desc(vq, 1);
+                               tx_poll_start(net, sock);
+                       } else {
+                               vq_err(vq, "sendmsg: errno %d\n", -err);
+                               /* drop packet; do not discard/resend */
+                               vhost_add_used_and_signal(&net->dev, vq, 
&head,
+                                                         1, 0);
+                       }
                        break;
                }
                if (err != len)
-                       pr_err("Truncated TX packet: "
-                              " len %d != %zd\n", err, len);
-               vhost_add_used_and_signal(&net->dev, vq, head, 0);
+                       pr_err("Truncated TX packet: len %d != %zd\n", 
err, len);
+               vhost_add_used_and_signal(&net->dev, vq, &head, 1, 0);
                total_len += len;
                if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
                        vhost_poll_queue(&vq->poll);
@@ -186,12 +167,25 @@ static void handle_tx(struct vhost_net *
        unuse_mm(net->dev.mm);
 }
 
+static int vhost_head_len(struct sock *sk)
+{
+       struct sk_buff *head;
+       int len = 0;
+
+       lock_sock(sk);
+       head = skb_peek(&sk->sk_receive_queue);
+       if (head)
+               len = head->len;
+       release_sock(sk);
+       return len;
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_rx(struct vhost_net *net)
 {
        struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
-       unsigned head, out, in, log, s;
+       unsigned in, log;
        struct vhost_log *vq_log;
        struct msghdr msg = {
                .msg_name = NULL,
@@ -202,34 +196,25 @@ static void handle_rx(struct vhost_net *
                .msg_flags = MSG_DONTWAIT,
        };
 
-       struct virtio_net_hdr hdr = {
-               .flags = 0,
-               .gso_type = VIRTIO_NET_HDR_GSO_NONE
-       };
-
        size_t len, total_len = 0;
-       int err;
-       size_t hdr_size;
+       int err, headcount, datalen;
        struct socket *sock = rcu_dereference(vq->private_data);
+
        if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
                return;
 
        use_mm(net->dev.mm);
        mutex_lock(&vq->mutex);
        vhost_disable_notify(vq);
-       hdr_size = vq->hdr_size;
 
        vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
                vq->log : NULL;
 
-       for (;;) {
-               head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
-                                        ARRAY_SIZE(vq->iov),
-                                        &out, &in,
-                                        vq_log, &log);
+       while ((datalen = vhost_head_len(sock->sk))) {
+               headcount = vhost_get_heads(vq, datalen, &in, vq_log, 
&log);
                /* OK, now we need to know about added descriptors. */
-               if (head == vq->num) {
-                       if (unlikely(vhost_enable_notify(vq))) {
+               if (!headcount) {
+                       if (unlikely(vhost_enable_notify(vq, 1))) {
                                /* They have slipped one in as we were
                                 * doing that: check again. */
                                vhost_disable_notify(vq);
@@ -240,46 +225,42 @@ static void handle_rx(struct vhost_net *
                        break;
                }
                /* We don't need to be notified again. */
-               if (out) {
-                       vq_err(vq, "Unexpected descriptor format for RX: "
-                              "out %d, int %d\n",
-                              out, in);
-                       break;
-               }
-               /* Skip header. TODO: support TSO/mergeable rx buffers. */
-               s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
+               if (vq->rxmaxheadcount < headcount)
+                       vq->rxmaxheadcount = headcount;
+               /* Skip header. TODO: support TSO. */
                msg.msg_iovlen = in;
                len = iov_length(vq->iov, in);
                /* Sanity check */
                if (!len) {
-                       vq_err(vq, "Unexpected header len for RX: "
-                              "%zd expected %zd\n",
-                              iov_length(vq->hdr, s), hdr_size);
+                       vq_err(vq, "Unexpected buffer len for RX: %zd\n", 
len);
                        break;
                }
                err = sock->ops->recvmsg(NULL, sock, &msg,
                                         len, MSG_DONTWAIT | MSG_TRUNC);
-               /* TODO: Check specific error and bomb out unless EAGAIN? 
*/
                if (err < 0) {
-                       vhost_discard_vq_desc(vq);
+                       vhost_discard_vq_desc(vq, headcount);
                        break;
                }
                /* TODO: Should check and handle checksum. */
+               if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF)) 
{
+                       struct virtio_net_hdr_mrg_rxbuf *vhdr =
+                               (struct virtio_net_hdr_mrg_rxbuf *)
+                               vq->iov[0].iov_base;
+                       /* add num_bufs */
+                       if (put_user(headcount, &vhdr->num_buffers)) {
+                               vq_err(vq, "Failed to write num_buffers");
+                               vhost_discard_vq_desc(vq, headcount);
+                               break;
+                       }
+               }
                if (err > len) {
                        pr_err("Discarded truncated rx packet: "
                               " len %d > %zd\n", err, len);
-                       vhost_discard_vq_desc(vq);
+                       vhost_discard_vq_desc(vq, headcount);
                        continue;
                }
                len = err;
-               err = memcpy_toiovec(vq->hdr, (unsigned char *)&hdr, 
hdr_size);
-               if (err) {
-                       vq_err(vq, "Unable to write vnet_hdr at addr %p: 
%d\n",
-                              vq->iov->iov_base, err);
-                       break;
-               }
-               len += hdr_size;
-               vhost_add_used_and_signal(&net->dev, vq, head, len);
+ vhost_add_used_and_signal(&net->dev,vq,vq->heads,headcount,1);
                if (unlikely(vq_log))
                        vhost_log_write(vq, vq_log, log, len);
                total_len += len;
@@ -560,9 +541,6 @@ done:
 
 static int vhost_net_set_features(struct vhost_net *n, u64 features)
 {
-       size_t hdr_size = features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
-               sizeof(struct virtio_net_hdr) : 0;
-       int i;
        mutex_lock(&n->dev.mutex);
        if ((features & (1 << VHOST_F_LOG_ALL)) &&
            !vhost_log_access_ok(&n->dev)) {
@@ -571,11 +549,6 @@ static int vhost_net_set_features(struct
        }
        n->dev.acked_features = features;
        smp_wmb();
-       for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
-               mutex_lock(&n->vqs[i].mutex);
-               n->vqs[i].hdr_size = hdr_size;
-               mutex_unlock(&n->vqs[i].mutex);
-       }
        vhost_net_flush(n);
        mutex_unlock(&n->dev.mutex);
        return 0;
diff -ruNp net-next-p0/drivers/vhost/vhost.c 
net-next-p3/drivers/vhost/vhost.c
--- net-next-p0/drivers/vhost/vhost.c   2010-03-22 12:04:38.000000000 
-0700
+++ net-next-p3/drivers/vhost/vhost.c   2010-03-29 20:12:42.000000000 
-0700
@@ -113,7 +113,7 @@ static void vhost_vq_reset(struct vhost_
        vq->used_flags = 0;
        vq->log_used = false;
        vq->log_addr = -1ull;
-       vq->hdr_size = 0;
+       vq->rxmaxheadcount = 0;
        vq->private_data = NULL;
        vq->log_base = NULL;
        vq->error_ctx = NULL;
@@ -410,6 +410,7 @@ static long vhost_set_vring(struct vhost
                vq->last_avail_idx = s.num;
                /* Forget the cached index value. */
                vq->avail_idx = vq->last_avail_idx;
+               vq->rxmaxheadcount = 0;
                break;
        case VHOST_GET_VRING_BASE:
                s.index = idx;
@@ -856,6 +857,48 @@ static unsigned get_indirect(struct vhos
        return 0;
 }
 
+/* This is a multi-head version of vhost_get_vq_desc
+ * @vq         - the relevant virtqueue
+ * datalen     - data length we'll be reading
+ * @iovcount   - returned count of io vectors we fill
+ * @log                - vhost log
+ * @log_num    - log offset
+ */
+unsigned vhost_get_heads(struct vhost_virtqueue *vq, int datalen, int 
*iovcount,
+       struct vhost_log *log, unsigned int *log_num)
+{
+       struct iovec *heads = vq->heads;
+       int out, in = 0;
+       int seg = 0;            /* iov index */
+       int hc = 0;             /* head count */
+
+       while (datalen > 0) {
+               if (hc >= VHOST_NET_MAX_SG) {
+                       vhost_discard_vq_desc(vq, hc);
+                       return 0;
+               }
+               heads[hc].iov_base = (void *)vhost_get_vq_desc(vq->dev, 
vq,
+                       vq->iov+seg, ARRAY_SIZE(vq->iov)-seg, &out, &in, 
log,
+                       log_num);
+               if (heads[hc].iov_base == (void *)vq->num) {
+                       vhost_discard_vq_desc(vq, hc);
+                       return 0;
+               }
+               if (out || in <= 0) {
+                       vq_err(vq, "unexpected descriptor format for RX: "
+                               "out %d, in %d\n", out, in);
+                       vhost_discard_vq_desc(vq, hc);
+                       return 0;
+               }
+               heads[hc].iov_len = iov_length(vq->iov+seg, in);
+               datalen -= heads[hc].iov_len;
+               hc++;
+               seg += in;
+       }
+       *iovcount = seg;
+       return hc;
+}
+
 /* This looks in the virtqueue and for the first available buffer, and 
converts
  * it to an iovec for convenient access.  Since descriptors consist of 
some
  * number of output then some number of input descriptors, it's actually 
two
@@ -981,31 +1024,36 @@ unsigned vhost_get_vq_desc(struct vhost_
 }
 
 /* Reverse the effect of vhost_get_vq_desc. Useful for error handling. */
-void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
+void vhost_discard_vq_desc(struct vhost_virtqueue *vq, int n)
 {
-       vq->last_avail_idx--;
+       vq->last_avail_idx -= n;
 }
 
 /* After we've used one of their buffers, we tell them about it.  We'll 
then
  * want to notify the guest, using eventfd. */
-int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int 
len)
+int vhost_add_used(struct vhost_virtqueue *vq, struct iovec *heads, int 
count)
 {
-       struct vring_used_elem *used;
+       struct vring_used_elem *used = 0;
+       int i;
 
-       /* The virtqueue contains a ring of used buffers.  Get a pointer 
to the
-        * next entry in that used ring. */
-       used = &vq->used->ring[vq->last_used_idx % vq->num];
-       if (put_user(head, &used->id)) {
-               vq_err(vq, "Failed to write used id");
-               return -EFAULT;
-       }
-       if (put_user(len, &used->len)) {
-               vq_err(vq, "Failed to write used len");
-               return -EFAULT;
+       if (count <= 0)
+               return -EINVAL;
+
+       for (i = 0; i < count; ++i) {
+               used = &vq->used->ring[vq->last_used_idx % vq->num];
+               if (put_user((unsigned)heads[i].iov_base, &used->id)) {
+                       vq_err(vq, "Failed to write used id");
+                       return -EFAULT;
+               }
+               if (put_user(heads[i].iov_len, &used->len)) {
+                       vq_err(vq, "Failed to write used len");
+                       return -EFAULT;
+               }
+               vq->last_used_idx++;
        }
        /* Make sure buffer is written before we update index. */
        smp_wmb();
-       if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
+       if (put_user(vq->last_used_idx, &vq->used->idx)) {
                vq_err(vq, "Failed to increment used idx");
                return -EFAULT;
        }
@@ -1023,22 +1071,35 @@ int vhost_add_used(struct vhost_virtqueu
                if (vq->log_ctx)
                        eventfd_signal(vq->log_ctx, 1);
        }
-       vq->last_used_idx++;
        return 0;
 }
 
+int vhost_available(struct vhost_virtqueue *vq)
+{
+       int avail;
+
+       if (!vq->rxmaxheadcount)        /* haven't got any yet */
+               return 1;
+       avail = vq->avail_idx - vq->last_avail_idx;
+       if (avail < 0)
+               avail += 0x10000; /* wrapped */
+       return avail;
+}
+
 /* This actually signals the guest, using eventfd. */
-void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
+void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq, bool 
recvr)
 {
        __u16 flags = 0;
+
        if (get_user(flags, &vq->avail->flags)) {
                vq_err(vq, "Failed to get flags");
                return;
        }
 
-       /* If they don't want an interrupt, don't signal, unless empty. */
+       /* If they don't want an interrupt, don't signal, unless
+        * empty or receiver can't get a max-sized packet. */
        if ((flags & VRING_AVAIL_F_NO_INTERRUPT) &&
-           (vq->avail_idx != vq->last_avail_idx ||
+           (!recvr || vhost_available(vq) >= vq->rxmaxheadcount ||
             !vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY)))
                return;
 
@@ -1050,14 +1111,14 @@ void vhost_signal(struct vhost_dev *dev,
 /* And here's the combo meal deal.  Supersize me! */
 void vhost_add_used_and_signal(struct vhost_dev *dev,
                               struct vhost_virtqueue *vq,
-                              unsigned int head, int len)
+                              struct iovec *heads, int count, bool recvr)
 {
-       vhost_add_used(vq, head, len);
-       vhost_signal(dev, vq);
+       vhost_add_used(vq, heads, count);
+       vhost_signal(dev, vq, recvr);
 }
 
 /* OK, now we need to know about added descriptors. */
-bool vhost_enable_notify(struct vhost_virtqueue *vq)
+bool vhost_enable_notify(struct vhost_virtqueue *vq, bool recvr)
 {
        u16 avail_idx;
        int r;
@@ -1080,6 +1141,8 @@ bool vhost_enable_notify(struct vhost_vi
                return false;
        }
 
+       if (recvr && vq->rxmaxheadcount)
+               return (avail_idx - vq->last_avail_idx) >= 
vq->rxmaxheadcount;
        return avail_idx != vq->last_avail_idx;
 }
 
diff -ruNp net-next-p0/drivers/vhost/vhost.h 
net-next-p3/drivers/vhost/vhost.h
--- net-next-p0/drivers/vhost/vhost.h   2010-03-22 12:04:38.000000000 
-0700
+++ net-next-p3/drivers/vhost/vhost.h   2010-03-29 20:07:17.000000000 
-0700
@@ -82,9 +82,9 @@ struct vhost_virtqueue {
        u64 log_addr;
 
        struct iovec indirect[VHOST_NET_MAX_SG];
-       struct iovec iov[VHOST_NET_MAX_SG];
-       struct iovec hdr[VHOST_NET_MAX_SG];
-       size_t hdr_size;
+       struct iovec iov[VHOST_NET_MAX_SG+1]; /* an extra for vnet hdr */
+       struct iovec heads[VHOST_NET_MAX_SG];
+       int rxmaxheadcount;
        /* We use a kind of RCU to access private pointer.
         * All readers access it from workqueue, which makes it possible 
to
         * flush the workqueue instead of synchronize_rcu. Therefore 
readers do
@@ -120,18 +120,20 @@ long vhost_dev_ioctl(struct vhost_dev *,
 int vhost_vq_access_ok(struct vhost_virtqueue *vq);
 int vhost_log_access_ok(struct vhost_dev *);
 
+unsigned vhost_get_heads(struct vhost_virtqueue *, int datalen, int 
*iovcount,
+                       struct vhost_log *log, unsigned int *log_num);
 unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
                           struct iovec iov[], unsigned int iov_count,
                           unsigned int *out_num, unsigned int *in_num,
                           struct vhost_log *log, unsigned int *log_num);
-void vhost_discard_vq_desc(struct vhost_virtqueue *);
+void vhost_discard_vq_desc(struct vhost_virtqueue *, int);
 
-int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
-void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
+int vhost_add_used(struct vhost_virtqueue *, struct iovec *heads, int 
count);
 void vhost_add_used_and_signal(struct vhost_dev *, struct vhost_virtqueue 
*,
-                              unsigned int head, int len);
+                              struct iovec *heads, int count, bool 
recvr);
+void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *, bool);
 void vhost_disable_notify(struct vhost_virtqueue *);
-bool vhost_enable_notify(struct vhost_virtqueue *);
+bool vhost_enable_notify(struct vhost_virtqueue *, bool);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
                    unsigned int log_num, u64 len);
@@ -149,7 +151,8 @@ enum {
        VHOST_FEATURES = (1 << VIRTIO_F_NOTIFY_ON_EMPTY) |
                         (1 << VIRTIO_RING_F_INDIRECT_DESC) |
                         (1 << VHOST_F_LOG_ALL) |
-                        (1 << VHOST_NET_F_VIRTIO_NET_HDR),
+                        (1 << VHOST_NET_F_VIRTIO_NET_HDR) |
+                        (1 << VIRTIO_NET_F_MRG_RXBUF),
 };
 
 static inline int vhost_has_feature(struct vhost_dev *dev, int bit)


--=_mixed 0007AB60882576F7_=
Content-Type: application/octet-stream; name="MRXB-3.patch"
Content-Disposition: attachment; filename="MRXB-3.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOcCBuZXQtbmV4dC1wMC9kcml2ZXJzL3Zob3N0L25ldC5jIG5ldC1uZXh0LXAzL2Ry
aXZlcnMvdmhvc3QvbmV0LmMKLS0tIG5ldC1uZXh0LXAwL2RyaXZlcnMvdmhvc3QvbmV0LmMJMjAx
MC0wMy0yMiAxMjowNDozOC4wMDAwMDAwMDAgLTA3MDAKKysrIG5ldC1uZXh0LXAzL2RyaXZlcnMv
dmhvc3QvbmV0LmMJMjAxMC0wMy0zMCAxMjo1MDo1Ny4wMDAwMDAwMDAgLTA3MDAKQEAgLTU0LDI2
ICs1NCw2IEBAIHN0cnVjdCB2aG9zdF9uZXQgewogCWVudW0gdmhvc3RfbmV0X3BvbGxfc3RhdGUg
dHhfcG9sbF9zdGF0ZTsKIH07CiAKLS8qIFBvcCBmaXJzdCBsZW4gYnl0ZXMgZnJvbSBpb3ZlYy4g
UmV0dXJuIG51bWJlciBvZiBzZWdtZW50cyB1c2VkLiAqLwotc3RhdGljIGludCBtb3ZlX2lvdmVj
X2hkcihzdHJ1Y3QgaW92ZWMgKmZyb20sIHN0cnVjdCBpb3ZlYyAqdG8sCi0JCQkgIHNpemVfdCBs
ZW4sIGludCBpb3ZfY291bnQpCi17Ci0JaW50IHNlZyA9IDA7Ci0Jc2l6ZV90IHNpemU7Ci0Jd2hp
bGUgKGxlbiAmJiBzZWcgPCBpb3ZfY291bnQpIHsKLQkJc2l6ZSA9IG1pbihmcm9tLT5pb3ZfbGVu
LCBsZW4pOwotCQl0by0+aW92X2Jhc2UgPSBmcm9tLT5pb3ZfYmFzZTsKLQkJdG8tPmlvdl9sZW4g
PSBzaXplOwotCQlmcm9tLT5pb3ZfbGVuIC09IHNpemU7Ci0JCWZyb20tPmlvdl9iYXNlICs9IHNp
emU7Ci0JCWxlbiAtPSBzaXplOwotCQkrK2Zyb207Ci0JCSsrdG87Ci0JCSsrc2VnOwotCX0KLQly
ZXR1cm4gc2VnOwotfQotCiAvKiBDYWxsZXIgbXVzdCBoYXZlIFRYIFZRIGxvY2sgKi8KIHN0YXRp
YyB2b2lkIHR4X3BvbGxfc3RvcChzdHJ1Y3Qgdmhvc3RfbmV0ICpuZXQpCiB7CkBAIC05Nyw3ICs3
Nyw4IEBAIHN0YXRpYyB2b2lkIHR4X3BvbGxfc3RhcnQoc3RydWN0IHZob3N0X24KIHN0YXRpYyB2
b2lkIGhhbmRsZV90eChzdHJ1Y3Qgdmhvc3RfbmV0ICpuZXQpCiB7CiAJc3RydWN0IHZob3N0X3Zp
cnRxdWV1ZSAqdnEgPSAmbmV0LT5kZXYudnFzW1ZIT1NUX05FVF9WUV9UWF07Ci0JdW5zaWduZWQg
aGVhZCwgb3V0LCBpbiwgczsKKwl1bnNpZ25lZCBvdXQsIGluOworCXN0cnVjdCBpb3ZlYyBoZWFk
OwogCXN0cnVjdCBtc2doZHIgbXNnID0gewogCQkubXNnX25hbWUgPSBOVUxMLAogCQkubXNnX25h
bWVsZW4gPSAwLApAQCAtMTA4LDggKzg5LDggQEAgc3RhdGljIHZvaWQgaGFuZGxlX3R4KHN0cnVj
dCB2aG9zdF9uZXQgKgogCX07CiAJc2l6ZV90IGxlbiwgdG90YWxfbGVuID0gMDsKIAlpbnQgZXJy
LCB3bWVtOwotCXNpemVfdCBoZHJfc2l6ZTsKIAlzdHJ1Y3Qgc29ja2V0ICpzb2NrID0gcmN1X2Rl
cmVmZXJlbmNlKHZxLT5wcml2YXRlX2RhdGEpOworCiAJaWYgKCFzb2NrKQogCQlyZXR1cm47CiAK
QEAgLTEyNywyMiArMTA4LDE5IEBAIHN0YXRpYyB2b2lkIGhhbmRsZV90eChzdHJ1Y3Qgdmhvc3Rf
bmV0ICoKIAogCWlmICh3bWVtIDwgc29jay0+c2stPnNrX3NuZGJ1ZiAvIDIpCiAJCXR4X3BvbGxf
c3RvcChuZXQpOwotCWhkcl9zaXplID0gdnEtPmhkcl9zaXplOwogCiAJZm9yICg7OykgewotCQlo
ZWFkID0gdmhvc3RfZ2V0X3ZxX2Rlc2MoJm5ldC0+ZGV2LCB2cSwgdnEtPmlvdiwKLQkJCQkJIEFS
UkFZX1NJWkUodnEtPmlvdiksCi0JCQkJCSAmb3V0LCAmaW4sCi0JCQkJCSBOVUxMLCBOVUxMKTsK
KwkJaGVhZC5pb3ZfYmFzZSA9ICh2b2lkICopdmhvc3RfZ2V0X3ZxX2Rlc2MoJm5ldC0+ZGV2LCB2
cSwKKwkJCXZxLT5pb3YsIEFSUkFZX1NJWkUodnEtPmlvdiksICZvdXQsICZpbiwgTlVMTCwgTlVM
TCk7CiAJCS8qIE5vdGhpbmcgbmV3PyAgV2FpdCBmb3IgZXZlbnRmZCB0byB0ZWxsIHVzIHRoZXkg
cmVmaWxsZWQuICovCi0JCWlmIChoZWFkID09IHZxLT5udW0pIHsKKwkJaWYgKGhlYWQuaW92X2Jh
c2UgPT0gKHZvaWQgKil2cS0+bnVtKSB7CiAJCQl3bWVtID0gYXRvbWljX3JlYWQoJnNvY2stPnNr
LT5za193bWVtX2FsbG9jKTsKIAkJCWlmICh3bWVtID49IHNvY2stPnNrLT5za19zbmRidWYgKiAz
IC8gNCkgewogCQkJCXR4X3BvbGxfc3RhcnQobmV0LCBzb2NrKTsKIAkJCQlzZXRfYml0KFNPQ0tf
QVNZTkNfTk9TUEFDRSwgJnNvY2stPmZsYWdzKTsKIAkJCQlicmVhazsKIAkJCX0KLQkJCWlmICh1
bmxpa2VseSh2aG9zdF9lbmFibGVfbm90aWZ5KHZxKSkpIHsKKwkJCWlmICh1bmxpa2VseSh2aG9z
dF9lbmFibGVfbm90aWZ5KHZxLCAwKSkpIHsKIAkJCQl2aG9zdF9kaXNhYmxlX25vdGlmeSh2cSk7
CiAJCQkJY29udGludWU7CiAJCQl9CkBAIC0xNTQsMjcgKzEzMiwzMCBAQCBzdGF0aWMgdm9pZCBo
YW5kbGVfdHgoc3RydWN0IHZob3N0X25ldCAqCiAJCQlicmVhazsKIAkJfQogCQkvKiBTa2lwIGhl
YWRlci4gVE9ETzogc3VwcG9ydCBUU08uICovCi0JCXMgPSBtb3ZlX2lvdmVjX2hkcih2cS0+aW92
LCB2cS0+aGRyLCBoZHJfc2l6ZSwgb3V0KTsKIAkJbXNnLm1zZ19pb3ZsZW4gPSBvdXQ7Ci0JCWxl
biA9IGlvdl9sZW5ndGgodnEtPmlvdiwgb3V0KTsKKwkJaGVhZC5pb3ZfbGVuID0gbGVuID0gaW92
X2xlbmd0aCh2cS0+aW92LCBvdXQpOworCiAJCS8qIFNhbml0eSBjaGVjayAqLwogCQlpZiAoIWxl
bikgewotCQkJdnFfZXJyKHZxLCAiVW5leHBlY3RlZCBoZWFkZXIgbGVuIGZvciBUWDogIgotCQkJ
ICAgICAgICIlemQgZXhwZWN0ZWQgJXpkXG4iLAotCQkJICAgICAgIGlvdl9sZW5ndGgodnEtPmhk
ciwgcyksIGhkcl9zaXplKTsKKwkJCXZxX2Vycih2cSwgIlVuZXhwZWN0ZWQgYnVmZmVyIGxlbiBm
b3IgVFg6ICV6ZCAiLCBsZW4pOwogCQkJYnJlYWs7CiAJCX0KLQkJLyogVE9ETzogQ2hlY2sgc3Bl
Y2lmaWMgZXJyb3IgYW5kIGJvbWIgb3V0IHVubGVzcyBFTk9CVUZTPyAqLwogCQllcnIgPSBzb2Nr
LT5vcHMtPnNlbmRtc2coTlVMTCwgc29jaywgJm1zZywgbGVuKTsKIAkJaWYgKHVubGlrZWx5KGVy
ciA8IDApKSB7Ci0JCQl2aG9zdF9kaXNjYXJkX3ZxX2Rlc2ModnEpOwotCQkJdHhfcG9sbF9zdGFy
dChuZXQsIHNvY2spOworCQkJaWYgKGVyciA9PSAtRUFHQUlOKSB7CisJCQkJdmhvc3RfZGlzY2Fy
ZF92cV9kZXNjKHZxLCAxKTsKKwkJCQl0eF9wb2xsX3N0YXJ0KG5ldCwgc29jayk7CisJCQl9IGVs
c2UgeworCQkJCXZxX2Vycih2cSwgInNlbmRtc2c6IGVycm5vICVkXG4iLCAtZXJyKTsKKwkJCQkv
KiBkcm9wIHBhY2tldDsgZG8gbm90IGRpc2NhcmQvcmVzZW5kICovCisJCQkJdmhvc3RfYWRkX3Vz
ZWRfYW5kX3NpZ25hbCgmbmV0LT5kZXYsIHZxLCAmaGVhZCwKKwkJCQkJCQkgIDEsIDApOworCQkJ
fQogCQkJYnJlYWs7CiAJCX0KIAkJaWYgKGVyciAhPSBsZW4pCi0JCQlwcl9lcnIoIlRydW5jYXRl
ZCBUWCBwYWNrZXQ6ICIKLQkJCSAgICAgICAiIGxlbiAlZCAhPSAlemRcbiIsIGVyciwgbGVuKTsK
LQkJdmhvc3RfYWRkX3VzZWRfYW5kX3NpZ25hbCgmbmV0LT5kZXYsIHZxLCBoZWFkLCAwKTsKKwkJ
CXByX2VycigiVHJ1bmNhdGVkIFRYIHBhY2tldDogbGVuICVkICE9ICV6ZFxuIiwgZXJyLCBsZW4p
OworCQl2aG9zdF9hZGRfdXNlZF9hbmRfc2lnbmFsKCZuZXQtPmRldiwgdnEsICZoZWFkLCAxLCAw
KTsKIAkJdG90YWxfbGVuICs9IGxlbjsKIAkJaWYgKHVubGlrZWx5KHRvdGFsX2xlbiA+PSBWSE9T
VF9ORVRfV0VJR0hUKSkgewogCQkJdmhvc3RfcG9sbF9xdWV1ZSgmdnEtPnBvbGwpOwpAQCAtMTg2
LDEyICsxNjcsMjUgQEAgc3RhdGljIHZvaWQgaGFuZGxlX3R4KHN0cnVjdCB2aG9zdF9uZXQgKgog
CXVudXNlX21tKG5ldC0+ZGV2Lm1tKTsKIH0KIAorc3RhdGljIGludCB2aG9zdF9oZWFkX2xlbihz
dHJ1Y3Qgc29jayAqc2spCit7CisJc3RydWN0IHNrX2J1ZmYgKmhlYWQ7CisJaW50IGxlbiA9IDA7
CisKKwlsb2NrX3NvY2soc2spOworCWhlYWQgPSBza2JfcGVlaygmc2stPnNrX3JlY2VpdmVfcXVl
dWUpOworCWlmIChoZWFkKQorCQlsZW4gPSBoZWFkLT5sZW47CisJcmVsZWFzZV9zb2NrKHNrKTsK
KwlyZXR1cm4gbGVuOworfQorCiAvKiBFeHBlY3RzIHRvIGJlIGFsd2F5cyBydW4gZnJvbSB3b3Jr
cXVldWUgLSB3aGljaCBhY3RzIGFzCiAgKiByZWFkLXNpemUgY3JpdGljYWwgc2VjdGlvbiBmb3Ig
b3VyIGtpbmQgb2YgUkNVLiAqLwogc3RhdGljIHZvaWQgaGFuZGxlX3J4KHN0cnVjdCB2aG9zdF9u
ZXQgKm5ldCkKIHsKIAlzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSA9ICZuZXQtPmRldi52cXNb
VkhPU1RfTkVUX1ZRX1JYXTsKLQl1bnNpZ25lZCBoZWFkLCBvdXQsIGluLCBsb2csIHM7CisJdW5z
aWduZWQgaW4sIGxvZzsKIAlzdHJ1Y3Qgdmhvc3RfbG9nICp2cV9sb2c7CiAJc3RydWN0IG1zZ2hk
ciBtc2cgPSB7CiAJCS5tc2dfbmFtZSA9IE5VTEwsCkBAIC0yMDIsMzQgKzE5NiwyNSBAQCBzdGF0
aWMgdm9pZCBoYW5kbGVfcngoc3RydWN0IHZob3N0X25ldCAqCiAJCS5tc2dfZmxhZ3MgPSBNU0df
RE9OVFdBSVQsCiAJfTsKIAotCXN0cnVjdCB2aXJ0aW9fbmV0X2hkciBoZHIgPSB7Ci0JCS5mbGFn
cyA9IDAsCi0JCS5nc29fdHlwZSA9IFZJUlRJT19ORVRfSERSX0dTT19OT05FCi0JfTsKLQogCXNp
emVfdCBsZW4sIHRvdGFsX2xlbiA9IDA7Ci0JaW50IGVycjsKLQlzaXplX3QgaGRyX3NpemU7CisJ
aW50IGVyciwgaGVhZGNvdW50LCBkYXRhbGVuOwogCXN0cnVjdCBzb2NrZXQgKnNvY2sgPSByY3Vf
ZGVyZWZlcmVuY2UodnEtPnByaXZhdGVfZGF0YSk7CisKIAlpZiAoIXNvY2sgfHwgc2tiX3F1ZXVl
X2VtcHR5KCZzb2NrLT5zay0+c2tfcmVjZWl2ZV9xdWV1ZSkpCiAJCXJldHVybjsKIAogCXVzZV9t
bShuZXQtPmRldi5tbSk7CiAJbXV0ZXhfbG9jaygmdnEtPm11dGV4KTsKIAl2aG9zdF9kaXNhYmxl
X25vdGlmeSh2cSk7Ci0JaGRyX3NpemUgPSB2cS0+aGRyX3NpemU7CiAKIAl2cV9sb2cgPSB1bmxp
a2VseSh2aG9zdF9oYXNfZmVhdHVyZSgmbmV0LT5kZXYsIFZIT1NUX0ZfTE9HX0FMTCkpID8KIAkJ
dnEtPmxvZyA6IE5VTEw7CiAKLQlmb3IgKDs7KSB7Ci0JCWhlYWQgPSB2aG9zdF9nZXRfdnFfZGVz
YygmbmV0LT5kZXYsIHZxLCB2cS0+aW92LAotCQkJCQkgQVJSQVlfU0laRSh2cS0+aW92KSwKLQkJ
CQkJICZvdXQsICZpbiwKLQkJCQkJIHZxX2xvZywgJmxvZyk7CisJd2hpbGUgKChkYXRhbGVuID0g
dmhvc3RfaGVhZF9sZW4oc29jay0+c2spKSkgeworCQloZWFkY291bnQgPSB2aG9zdF9nZXRfaGVh
ZHModnEsIGRhdGFsZW4sICZpbiwgdnFfbG9nLCAmbG9nKTsKIAkJLyogT0ssIG5vdyB3ZSBuZWVk
IHRvIGtub3cgYWJvdXQgYWRkZWQgZGVzY3JpcHRvcnMuICovCi0JCWlmIChoZWFkID09IHZxLT5u
dW0pIHsKLQkJCWlmICh1bmxpa2VseSh2aG9zdF9lbmFibGVfbm90aWZ5KHZxKSkpIHsKKwkJaWYg
KCFoZWFkY291bnQpIHsKKwkJCWlmICh1bmxpa2VseSh2aG9zdF9lbmFibGVfbm90aWZ5KHZxLCAx
KSkpIHsKIAkJCQkvKiBUaGV5IGhhdmUgc2xpcHBlZCBvbmUgaW4gYXMgd2Ugd2VyZQogCQkJCSAq
IGRvaW5nIHRoYXQ6IGNoZWNrIGFnYWluLiAqLwogCQkJCXZob3N0X2Rpc2FibGVfbm90aWZ5KHZx
KTsKQEAgLTI0MCw0NiArMjI1LDQyIEBAIHN0YXRpYyB2b2lkIGhhbmRsZV9yeChzdHJ1Y3Qgdmhv
c3RfbmV0ICoKIAkJCWJyZWFrOwogCQl9CiAJCS8qIFdlIGRvbid0IG5lZWQgdG8gYmUgbm90aWZp
ZWQgYWdhaW4uICovCi0JCWlmIChvdXQpIHsKLQkJCXZxX2Vycih2cSwgIlVuZXhwZWN0ZWQgZGVz
Y3JpcHRvciBmb3JtYXQgZm9yIFJYOiAiCi0JCQkgICAgICAgIm91dCAlZCwgaW50ICVkXG4iLAot
CQkJICAgICAgIG91dCwgaW4pOwotCQkJYnJlYWs7Ci0JCX0KLQkJLyogU2tpcCBoZWFkZXIuIFRP
RE86IHN1cHBvcnQgVFNPL21lcmdlYWJsZSByeCBidWZmZXJzLiAqLwotCQlzID0gbW92ZV9pb3Zl
Y19oZHIodnEtPmlvdiwgdnEtPmhkciwgaGRyX3NpemUsIGluKTsKKwkJaWYgKHZxLT5yeG1heGhl
YWRjb3VudCA8IGhlYWRjb3VudCkKKwkJCXZxLT5yeG1heGhlYWRjb3VudCA9IGhlYWRjb3VudDsK
KwkJLyogU2tpcCBoZWFkZXIuIFRPRE86IHN1cHBvcnQgVFNPLiAqLwogCQltc2cubXNnX2lvdmxl
biA9IGluOwogCQlsZW4gPSBpb3ZfbGVuZ3RoKHZxLT5pb3YsIGluKTsKIAkJLyogU2FuaXR5IGNo
ZWNrICovCiAJCWlmICghbGVuKSB7Ci0JCQl2cV9lcnIodnEsICJVbmV4cGVjdGVkIGhlYWRlciBs
ZW4gZm9yIFJYOiAiCi0JCQkgICAgICAgIiV6ZCBleHBlY3RlZCAlemRcbiIsCi0JCQkgICAgICAg
aW92X2xlbmd0aCh2cS0+aGRyLCBzKSwgaGRyX3NpemUpOworCQkJdnFfZXJyKHZxLCAiVW5leHBl
Y3RlZCBidWZmZXIgbGVuIGZvciBSWDogJXpkXG4iLCBsZW4pOwogCQkJYnJlYWs7CiAJCX0KIAkJ
ZXJyID0gc29jay0+b3BzLT5yZWN2bXNnKE5VTEwsIHNvY2ssICZtc2csCiAJCQkJCSBsZW4sIE1T
R19ET05UV0FJVCB8IE1TR19UUlVOQyk7Ci0JCS8qIFRPRE86IENoZWNrIHNwZWNpZmljIGVycm9y
IGFuZCBib21iIG91dCB1bmxlc3MgRUFHQUlOPyAqLwogCQlpZiAoZXJyIDwgMCkgewotCQkJdmhv
c3RfZGlzY2FyZF92cV9kZXNjKHZxKTsKKwkJCXZob3N0X2Rpc2NhcmRfdnFfZGVzYyh2cSwgaGVh
ZGNvdW50KTsKIAkJCWJyZWFrOwogCQl9CiAJCS8qIFRPRE86IFNob3VsZCBjaGVjayBhbmQgaGFu
ZGxlIGNoZWNrc3VtLiAqLworCQlpZiAodmhvc3RfaGFzX2ZlYXR1cmUoJm5ldC0+ZGV2LCBWSVJU
SU9fTkVUX0ZfTVJHX1JYQlVGKSkgeworCQkJc3RydWN0IHZpcnRpb19uZXRfaGRyX21yZ19yeGJ1
ZiAqdmhkciA9CisJCQkJKHN0cnVjdCB2aXJ0aW9fbmV0X2hkcl9tcmdfcnhidWYgKikKKwkJCQl2
cS0+aW92WzBdLmlvdl9iYXNlOworCQkJLyogYWRkIG51bV9idWZzICovCisJCQlpZiAocHV0X3Vz
ZXIoaGVhZGNvdW50LCAmdmhkci0+bnVtX2J1ZmZlcnMpKSB7CisJCQkJdnFfZXJyKHZxLCAiRmFp
bGVkIHRvIHdyaXRlIG51bV9idWZmZXJzIik7CisJCQkJdmhvc3RfZGlzY2FyZF92cV9kZXNjKHZx
LCBoZWFkY291bnQpOworCQkJCWJyZWFrOworCQkJfQorCQl9CiAJCWlmIChlcnIgPiBsZW4pIHsK
IAkJCXByX2VycigiRGlzY2FyZGVkIHRydW5jYXRlZCByeCBwYWNrZXQ6ICIKIAkJCSAgICAgICAi
IGxlbiAlZCA+ICV6ZFxuIiwgZXJyLCBsZW4pOwotCQkJdmhvc3RfZGlzY2FyZF92cV9kZXNjKHZx
KTsKKwkJCXZob3N0X2Rpc2NhcmRfdnFfZGVzYyh2cSwgaGVhZGNvdW50KTsKIAkJCWNvbnRpbnVl
OwogCQl9CiAJCWxlbiA9IGVycjsKLQkJZXJyID0gbWVtY3B5X3RvaW92ZWModnEtPmhkciwgKHVu
c2lnbmVkIGNoYXIgKikmaGRyLCBoZHJfc2l6ZSk7Ci0JCWlmIChlcnIpIHsKLQkJCXZxX2Vycih2
cSwgIlVuYWJsZSB0byB3cml0ZSB2bmV0X2hkciBhdCBhZGRyICVwOiAlZFxuIiwKLQkJCSAgICAg
ICB2cS0+aW92LT5pb3ZfYmFzZSwgZXJyKTsKLQkJCWJyZWFrOwotCQl9Ci0JCWxlbiArPSBoZHJf
c2l6ZTsKLQkJdmhvc3RfYWRkX3VzZWRfYW5kX3NpZ25hbCgmbmV0LT5kZXYsIHZxLCBoZWFkLCBs
ZW4pOworCQl2aG9zdF9hZGRfdXNlZF9hbmRfc2lnbmFsKCZuZXQtPmRldix2cSx2cS0+aGVhZHMs
aGVhZGNvdW50LDEpOwogCQlpZiAodW5saWtlbHkodnFfbG9nKSkKIAkJCXZob3N0X2xvZ193cml0
ZSh2cSwgdnFfbG9nLCBsb2csIGxlbik7CiAJCXRvdGFsX2xlbiArPSBsZW47CkBAIC01NjAsOSAr
NTQxLDYgQEAgZG9uZToKIAogc3RhdGljIGludCB2aG9zdF9uZXRfc2V0X2ZlYXR1cmVzKHN0cnVj
dCB2aG9zdF9uZXQgKm4sIHU2NCBmZWF0dXJlcykKIHsKLQlzaXplX3QgaGRyX3NpemUgPSBmZWF0
dXJlcyAmICgxIDw8IFZIT1NUX05FVF9GX1ZJUlRJT19ORVRfSERSKSA/Ci0JCXNpemVvZihzdHJ1
Y3QgdmlydGlvX25ldF9oZHIpIDogMDsKLQlpbnQgaTsKIAltdXRleF9sb2NrKCZuLT5kZXYubXV0
ZXgpOwogCWlmICgoZmVhdHVyZXMgJiAoMSA8PCBWSE9TVF9GX0xPR19BTEwpKSAmJgogCSAgICAh
dmhvc3RfbG9nX2FjY2Vzc19vaygmbi0+ZGV2KSkgewpAQCAtNTcxLDExICs1NDksNiBAQCBzdGF0
aWMgaW50IHZob3N0X25ldF9zZXRfZmVhdHVyZXMoc3RydWN0CiAJfQogCW4tPmRldi5hY2tlZF9m
ZWF0dXJlcyA9IGZlYXR1cmVzOwogCXNtcF93bWIoKTsKLQlmb3IgKGkgPSAwOyBpIDwgVkhPU1Rf
TkVUX1ZRX01BWDsgKytpKSB7Ci0JCW11dGV4X2xvY2soJm4tPnZxc1tpXS5tdXRleCk7Ci0JCW4t
PnZxc1tpXS5oZHJfc2l6ZSA9IGhkcl9zaXplOwotCQltdXRleF91bmxvY2soJm4tPnZxc1tpXS5t
dXRleCk7Ci0JfQogCXZob3N0X25ldF9mbHVzaChuKTsKIAltdXRleF91bmxvY2soJm4tPmRldi5t
dXRleCk7CiAJcmV0dXJuIDA7CmRpZmYgLXJ1TnAgbmV0LW5leHQtcDAvZHJpdmVycy92aG9zdC92
aG9zdC5jIG5ldC1uZXh0LXAzL2RyaXZlcnMvdmhvc3Qvdmhvc3QuYwotLS0gbmV0LW5leHQtcDAv
ZHJpdmVycy92aG9zdC92aG9zdC5jCTIwMTAtMDMtMjIgMTI6MDQ6MzguMDAwMDAwMDAwIC0wNzAw
CisrKyBuZXQtbmV4dC1wMy9kcml2ZXJzL3Zob3N0L3Zob3N0LmMJMjAxMC0wMy0yOSAyMDoxMjo0
Mi4wMDAwMDAwMDAgLTA3MDAKQEAgLTExMyw3ICsxMTMsNyBAQCBzdGF0aWMgdm9pZCB2aG9zdF92
cV9yZXNldChzdHJ1Y3Qgdmhvc3RfCiAJdnEtPnVzZWRfZmxhZ3MgPSAwOwogCXZxLT5sb2dfdXNl
ZCA9IGZhbHNlOwogCXZxLT5sb2dfYWRkciA9IC0xdWxsOwotCXZxLT5oZHJfc2l6ZSA9IDA7CisJ
dnEtPnJ4bWF4aGVhZGNvdW50ID0gMDsKIAl2cS0+cHJpdmF0ZV9kYXRhID0gTlVMTDsKIAl2cS0+
bG9nX2Jhc2UgPSBOVUxMOwogCXZxLT5lcnJvcl9jdHggPSBOVUxMOwpAQCAtNDEwLDYgKzQxMCw3
IEBAIHN0YXRpYyBsb25nIHZob3N0X3NldF92cmluZyhzdHJ1Y3Qgdmhvc3QKIAkJdnEtPmxhc3Rf
YXZhaWxfaWR4ID0gcy5udW07CiAJCS8qIEZvcmdldCB0aGUgY2FjaGVkIGluZGV4IHZhbHVlLiAq
LwogCQl2cS0+YXZhaWxfaWR4ID0gdnEtPmxhc3RfYXZhaWxfaWR4OworCQl2cS0+cnhtYXhoZWFk
Y291bnQgPSAwOwogCQlicmVhazsKIAljYXNlIFZIT1NUX0dFVF9WUklOR19CQVNFOgogCQlzLmlu
ZGV4ID0gaWR4OwpAQCAtODU2LDYgKzg1Nyw0OCBAQCBzdGF0aWMgdW5zaWduZWQgZ2V0X2luZGly
ZWN0KHN0cnVjdCB2aG9zCiAJcmV0dXJuIDA7CiB9CiAKKy8qIFRoaXMgaXMgYSBtdWx0aS1oZWFk
IHZlcnNpb24gb2Ygdmhvc3RfZ2V0X3ZxX2Rlc2MKKyAqIEB2cQkJLSB0aGUgcmVsZXZhbnQgdmly
dHF1ZXVlCisgKiBkYXRhbGVuCS0gZGF0YSBsZW5ndGggd2UnbGwgYmUgcmVhZGluZworICogQGlv
dmNvdW50CS0gcmV0dXJuZWQgY291bnQgb2YgaW8gdmVjdG9ycyB3ZSBmaWxsCisgKiBAbG9nCQkt
IHZob3N0IGxvZworICogQGxvZ19udW0JLSBsb2cgb2Zmc2V0CisgKi8KK3Vuc2lnbmVkIHZob3N0
X2dldF9oZWFkcyhzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSwgaW50IGRhdGFsZW4sIGludCAq
aW92Y291bnQsCisJc3RydWN0IHZob3N0X2xvZyAqbG9nLCB1bnNpZ25lZCBpbnQgKmxvZ19udW0p
Cit7CisJc3RydWN0IGlvdmVjICpoZWFkcyA9IHZxLT5oZWFkczsKKwlpbnQgb3V0LCBpbiA9IDA7
CisJaW50IHNlZyA9IDA7CQkvKiBpb3YgaW5kZXggKi8KKwlpbnQgaGMgPSAwOwkJLyogaGVhZCBj
b3VudCAqLworCisJd2hpbGUgKGRhdGFsZW4gPiAwKSB7CisJCWlmIChoYyA+PSBWSE9TVF9ORVRf
TUFYX1NHKSB7CisJCQl2aG9zdF9kaXNjYXJkX3ZxX2Rlc2ModnEsIGhjKTsKKwkJCXJldHVybiAw
OworCQl9CisJCWhlYWRzW2hjXS5pb3ZfYmFzZSA9ICh2b2lkICopdmhvc3RfZ2V0X3ZxX2Rlc2Mo
dnEtPmRldiwgdnEsCisJCQl2cS0+aW92K3NlZywgQVJSQVlfU0laRSh2cS0+aW92KS1zZWcsICZv
dXQsICZpbiwgbG9nLAorCQkJbG9nX251bSk7CisJCWlmIChoZWFkc1toY10uaW92X2Jhc2UgPT0g
KHZvaWQgKil2cS0+bnVtKSB7CisJCQl2aG9zdF9kaXNjYXJkX3ZxX2Rlc2ModnEsIGhjKTsKKwkJ
CXJldHVybiAwOworCQl9CisJCWlmIChvdXQgfHwgaW4gPD0gMCkgeworCQkJdnFfZXJyKHZxLCAi
dW5leHBlY3RlZCBkZXNjcmlwdG9yIGZvcm1hdCBmb3IgUlg6ICIKKwkJCQkib3V0ICVkLCBpbiAl
ZFxuIiwgb3V0LCBpbik7CisJCQl2aG9zdF9kaXNjYXJkX3ZxX2Rlc2ModnEsIGhjKTsKKwkJCXJl
dHVybiAwOworCQl9CisJCWhlYWRzW2hjXS5pb3ZfbGVuID0gaW92X2xlbmd0aCh2cS0+aW92K3Nl
ZywgaW4pOworCQlkYXRhbGVuIC09IGhlYWRzW2hjXS5pb3ZfbGVuOworCQloYysrOworCQlzZWcg
Kz0gaW47CisJfQorCSppb3Zjb3VudCA9IHNlZzsKKwlyZXR1cm4gaGM7Cit9CisKIC8qIFRoaXMg
bG9va3MgaW4gdGhlIHZpcnRxdWV1ZSBhbmQgZm9yIHRoZSBmaXJzdCBhdmFpbGFibGUgYnVmZmVy
LCBhbmQgY29udmVydHMKICAqIGl0IHRvIGFuIGlvdmVjIGZvciBjb252ZW5pZW50IGFjY2Vzcy4g
IFNpbmNlIGRlc2NyaXB0b3JzIGNvbnNpc3Qgb2Ygc29tZQogICogbnVtYmVyIG9mIG91dHB1dCB0
aGVuIHNvbWUgbnVtYmVyIG9mIGlucHV0IGRlc2NyaXB0b3JzLCBpdCdzIGFjdHVhbGx5IHR3bwpA
QCAtOTgxLDMxICsxMDI0LDM2IEBAIHVuc2lnbmVkIHZob3N0X2dldF92cV9kZXNjKHN0cnVjdCB2
aG9zdF8KIH0KIAogLyogUmV2ZXJzZSB0aGUgZWZmZWN0IG9mIHZob3N0X2dldF92cV9kZXNjLiBV
c2VmdWwgZm9yIGVycm9yIGhhbmRsaW5nLiAqLwotdm9pZCB2aG9zdF9kaXNjYXJkX3ZxX2Rlc2Mo
c3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAqdnEpCit2b2lkIHZob3N0X2Rpc2NhcmRfdnFfZGVzYyhz
dHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSwgaW50IG4pCiB7Ci0JdnEtPmxhc3RfYXZhaWxfaWR4
LS07CisJdnEtPmxhc3RfYXZhaWxfaWR4IC09IG47CiB9CiAKIC8qIEFmdGVyIHdlJ3ZlIHVzZWQg
b25lIG9mIHRoZWlyIGJ1ZmZlcnMsIHdlIHRlbGwgdGhlbSBhYm91dCBpdC4gIFdlJ2xsIHRoZW4K
ICAqIHdhbnQgdG8gbm90aWZ5IHRoZSBndWVzdCwgdXNpbmcgZXZlbnRmZC4gKi8KLWludCB2aG9z
dF9hZGRfdXNlZChzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSwgdW5zaWduZWQgaW50IGhlYWQs
IGludCBsZW4pCitpbnQgdmhvc3RfYWRkX3VzZWQoc3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAqdnEs
IHN0cnVjdCBpb3ZlYyAqaGVhZHMsIGludCBjb3VudCkKIHsKLQlzdHJ1Y3QgdnJpbmdfdXNlZF9l
bGVtICp1c2VkOworCXN0cnVjdCB2cmluZ191c2VkX2VsZW0gKnVzZWQgPSAwOworCWludCBpOwog
Ci0JLyogVGhlIHZpcnRxdWV1ZSBjb250YWlucyBhIHJpbmcgb2YgdXNlZCBidWZmZXJzLiAgR2V0
IGEgcG9pbnRlciB0byB0aGUKLQkgKiBuZXh0IGVudHJ5IGluIHRoYXQgdXNlZCByaW5nLiAqLwot
CXVzZWQgPSAmdnEtPnVzZWQtPnJpbmdbdnEtPmxhc3RfdXNlZF9pZHggJSB2cS0+bnVtXTsKLQlp
ZiAocHV0X3VzZXIoaGVhZCwgJnVzZWQtPmlkKSkgewotCQl2cV9lcnIodnEsICJGYWlsZWQgdG8g
d3JpdGUgdXNlZCBpZCIpOwotCQlyZXR1cm4gLUVGQVVMVDsKLQl9Ci0JaWYgKHB1dF91c2VyKGxl
biwgJnVzZWQtPmxlbikpIHsKLQkJdnFfZXJyKHZxLCAiRmFpbGVkIHRvIHdyaXRlIHVzZWQgbGVu
Iik7Ci0JCXJldHVybiAtRUZBVUxUOworCWlmIChjb3VudCA8PSAwKQorCQlyZXR1cm4gLUVJTlZB
TDsKKworCWZvciAoaSA9IDA7IGkgPCBjb3VudDsgKytpKSB7CisJCXVzZWQgPSAmdnEtPnVzZWQt
PnJpbmdbdnEtPmxhc3RfdXNlZF9pZHggJSB2cS0+bnVtXTsKKwkJaWYgKHB1dF91c2VyKCh1bnNp
Z25lZCloZWFkc1tpXS5pb3ZfYmFzZSwgJnVzZWQtPmlkKSkgeworCQkJdnFfZXJyKHZxLCAiRmFp
bGVkIHRvIHdyaXRlIHVzZWQgaWQiKTsKKwkJCXJldHVybiAtRUZBVUxUOworCQl9CisJCWlmIChw
dXRfdXNlcihoZWFkc1tpXS5pb3ZfbGVuLCAmdXNlZC0+bGVuKSkgeworCQkJdnFfZXJyKHZxLCAi
RmFpbGVkIHRvIHdyaXRlIHVzZWQgbGVuIik7CisJCQlyZXR1cm4gLUVGQVVMVDsKKwkJfQorCQl2
cS0+bGFzdF91c2VkX2lkeCsrOwogCX0KIAkvKiBNYWtlIHN1cmUgYnVmZmVyIGlzIHdyaXR0ZW4g
YmVmb3JlIHdlIHVwZGF0ZSBpbmRleC4gKi8KIAlzbXBfd21iKCk7Ci0JaWYgKHB1dF91c2VyKHZx
LT5sYXN0X3VzZWRfaWR4ICsgMSwgJnZxLT51c2VkLT5pZHgpKSB7CisJaWYgKHB1dF91c2VyKHZx
LT5sYXN0X3VzZWRfaWR4LCAmdnEtPnVzZWQtPmlkeCkpIHsKIAkJdnFfZXJyKHZxLCAiRmFpbGVk
IHRvIGluY3JlbWVudCB1c2VkIGlkeCIpOwogCQlyZXR1cm4gLUVGQVVMVDsKIAl9CkBAIC0xMDIz
LDIyICsxMDcxLDM1IEBAIGludCB2aG9zdF9hZGRfdXNlZChzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXUK
IAkJaWYgKHZxLT5sb2dfY3R4KQogCQkJZXZlbnRmZF9zaWduYWwodnEtPmxvZ19jdHgsIDEpOwog
CX0KLQl2cS0+bGFzdF91c2VkX2lkeCsrOwogCXJldHVybiAwOwogfQogCitpbnQgdmhvc3RfYXZh
aWxhYmxlKHN0cnVjdCB2aG9zdF92aXJ0cXVldWUgKnZxKQoreworCWludCBhdmFpbDsKKworCWlm
ICghdnEtPnJ4bWF4aGVhZGNvdW50KQkvKiBoYXZlbid0IGdvdCBhbnkgeWV0ICovCisJCXJldHVy
biAxOworCWF2YWlsID0gdnEtPmF2YWlsX2lkeCAtIHZxLT5sYXN0X2F2YWlsX2lkeDsKKwlpZiAo
YXZhaWwgPCAwKQorCQlhdmFpbCArPSAweDEwMDAwOyAvKiB3cmFwcGVkICovCisJcmV0dXJuIGF2
YWlsOworfQorCiAvKiBUaGlzIGFjdHVhbGx5IHNpZ25hbHMgdGhlIGd1ZXN0LCB1c2luZyBldmVu
dGZkLiAqLwotdm9pZCB2aG9zdF9zaWduYWwoc3RydWN0IHZob3N0X2RldiAqZGV2LCBzdHJ1Y3Qg
dmhvc3RfdmlydHF1ZXVlICp2cSkKK3ZvaWQgdmhvc3Rfc2lnbmFsKHN0cnVjdCB2aG9zdF9kZXYg
KmRldiwgc3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAqdnEsIGJvb2wgcmVjdnIpCiB7CiAJX191MTYg
ZmxhZ3MgPSAwOworCiAJaWYgKGdldF91c2VyKGZsYWdzLCAmdnEtPmF2YWlsLT5mbGFncykpIHsK
IAkJdnFfZXJyKHZxLCAiRmFpbGVkIHRvIGdldCBmbGFncyIpOwogCQlyZXR1cm47CiAJfQogCi0J
LyogSWYgdGhleSBkb24ndCB3YW50IGFuIGludGVycnVwdCwgZG9uJ3Qgc2lnbmFsLCB1bmxlc3Mg
ZW1wdHkuICovCisJLyogSWYgdGhleSBkb24ndCB3YW50IGFuIGludGVycnVwdCwgZG9uJ3Qgc2ln
bmFsLCB1bmxlc3MKKwkgKiBlbXB0eSBvciByZWNlaXZlciBjYW4ndCBnZXQgYSBtYXgtc2l6ZWQg
cGFja2V0LiAqLwogCWlmICgoZmxhZ3MgJiBWUklOR19BVkFJTF9GX05PX0lOVEVSUlVQVCkgJiYK
LQkgICAgKHZxLT5hdmFpbF9pZHggIT0gdnEtPmxhc3RfYXZhaWxfaWR4IHx8CisJICAgICghcmVj
dnIgfHwgdmhvc3RfYXZhaWxhYmxlKHZxKSA+PSB2cS0+cnhtYXhoZWFkY291bnQgfHwKIAkgICAg
ICF2aG9zdF9oYXNfZmVhdHVyZShkZXYsIFZJUlRJT19GX05PVElGWV9PTl9FTVBUWSkpKQogCQly
ZXR1cm47CiAKQEAgLTEwNTAsMTQgKzExMTEsMTQgQEAgdm9pZCB2aG9zdF9zaWduYWwoc3RydWN0
IHZob3N0X2RldiAqZGV2LAogLyogQW5kIGhlcmUncyB0aGUgY29tYm8gbWVhbCBkZWFsLiAgU3Vw
ZXJzaXplIG1lISAqLwogdm9pZCB2aG9zdF9hZGRfdXNlZF9hbmRfc2lnbmFsKHN0cnVjdCB2aG9z
dF9kZXYgKmRldiwKIAkJCSAgICAgICBzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSwKLQkJCSAg
ICAgICB1bnNpZ25lZCBpbnQgaGVhZCwgaW50IGxlbikKKwkJCSAgICAgICBzdHJ1Y3QgaW92ZWMg
KmhlYWRzLCBpbnQgY291bnQsIGJvb2wgcmVjdnIpCiB7Ci0Jdmhvc3RfYWRkX3VzZWQodnEsIGhl
YWQsIGxlbik7Ci0Jdmhvc3Rfc2lnbmFsKGRldiwgdnEpOworCXZob3N0X2FkZF91c2VkKHZxLCBo
ZWFkcywgY291bnQpOworCXZob3N0X3NpZ25hbChkZXYsIHZxLCByZWN2cik7CiB9CiAKIC8qIE9L
LCBub3cgd2UgbmVlZCB0byBrbm93IGFib3V0IGFkZGVkIGRlc2NyaXB0b3JzLiAqLwotYm9vbCB2
aG9zdF9lbmFibGVfbm90aWZ5KHN0cnVjdCB2aG9zdF92aXJ0cXVldWUgKnZxKQorYm9vbCB2aG9z
dF9lbmFibGVfbm90aWZ5KHN0cnVjdCB2aG9zdF92aXJ0cXVldWUgKnZxLCBib29sIHJlY3ZyKQog
ewogCXUxNiBhdmFpbF9pZHg7CiAJaW50IHI7CkBAIC0xMDgwLDYgKzExNDEsOCBAQCBib29sIHZo
b3N0X2VuYWJsZV9ub3RpZnkoc3RydWN0IHZob3N0X3ZpCiAJCXJldHVybiBmYWxzZTsKIAl9CiAK
KwlpZiAocmVjdnIgJiYgdnEtPnJ4bWF4aGVhZGNvdW50KQorCQlyZXR1cm4gKGF2YWlsX2lkeCAt
IHZxLT5sYXN0X2F2YWlsX2lkeCkgPj0gdnEtPnJ4bWF4aGVhZGNvdW50OwogCXJldHVybiBhdmFp
bF9pZHggIT0gdnEtPmxhc3RfYXZhaWxfaWR4OwogfQogCmRpZmYgLXJ1TnAgbmV0LW5leHQtcDAv
ZHJpdmVycy92aG9zdC92aG9zdC5oIG5ldC1uZXh0LXAzL2RyaXZlcnMvdmhvc3Qvdmhvc3QuaAot
LS0gbmV0LW5leHQtcDAvZHJpdmVycy92aG9zdC92aG9zdC5oCTIwMTAtMDMtMjIgMTI6MDQ6Mzgu
MDAwMDAwMDAwIC0wNzAwCisrKyBuZXQtbmV4dC1wMy9kcml2ZXJzL3Zob3N0L3Zob3N0LmgJMjAx
MC0wMy0yOSAyMDowNzoxNy4wMDAwMDAwMDAgLTA3MDAKQEAgLTgyLDkgKzgyLDkgQEAgc3RydWN0
IHZob3N0X3ZpcnRxdWV1ZSB7CiAJdTY0IGxvZ19hZGRyOwogCiAJc3RydWN0IGlvdmVjIGluZGly
ZWN0W1ZIT1NUX05FVF9NQVhfU0ddOwotCXN0cnVjdCBpb3ZlYyBpb3ZbVkhPU1RfTkVUX01BWF9T
R107Ci0Jc3RydWN0IGlvdmVjIGhkcltWSE9TVF9ORVRfTUFYX1NHXTsKLQlzaXplX3QgaGRyX3Np
emU7CisJc3RydWN0IGlvdmVjIGlvdltWSE9TVF9ORVRfTUFYX1NHKzFdOyAvKiBhbiBleHRyYSBm
b3Igdm5ldCBoZHIgKi8KKwlzdHJ1Y3QgaW92ZWMgaGVhZHNbVkhPU1RfTkVUX01BWF9TR107CisJ
aW50IHJ4bWF4aGVhZGNvdW50OwogCS8qIFdlIHVzZSBhIGtpbmQgb2YgUkNVIHRvIGFjY2VzcyBw
cml2YXRlIHBvaW50ZXIuCiAJICogQWxsIHJlYWRlcnMgYWNjZXNzIGl0IGZyb20gd29ya3F1ZXVl
LCB3aGljaCBtYWtlcyBpdCBwb3NzaWJsZSB0bwogCSAqIGZsdXNoIHRoZSB3b3JrcXVldWUgaW5z
dGVhZCBvZiBzeW5jaHJvbml6ZV9yY3UuIFRoZXJlZm9yZSByZWFkZXJzIGRvCkBAIC0xMjAsMTgg
KzEyMCwyMCBAQCBsb25nIHZob3N0X2Rldl9pb2N0bChzdHJ1Y3Qgdmhvc3RfZGV2ICosCiBpbnQg
dmhvc3RfdnFfYWNjZXNzX29rKHN0cnVjdCB2aG9zdF92aXJ0cXVldWUgKnZxKTsKIGludCB2aG9z
dF9sb2dfYWNjZXNzX29rKHN0cnVjdCB2aG9zdF9kZXYgKik7CiAKK3Vuc2lnbmVkIHZob3N0X2dl
dF9oZWFkcyhzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICosIGludCBkYXRhbGVuLCBpbnQgKmlvdmNv
dW50LAorCQkJc3RydWN0IHZob3N0X2xvZyAqbG9nLCB1bnNpZ25lZCBpbnQgKmxvZ19udW0pOwog
dW5zaWduZWQgdmhvc3RfZ2V0X3ZxX2Rlc2Moc3RydWN0IHZob3N0X2RldiAqLCBzdHJ1Y3Qgdmhv
c3RfdmlydHF1ZXVlICosCiAJCQkgICBzdHJ1Y3QgaW92ZWMgaW92W10sIHVuc2lnbmVkIGludCBp
b3ZfY291bnQsCiAJCQkgICB1bnNpZ25lZCBpbnQgKm91dF9udW0sIHVuc2lnbmVkIGludCAqaW5f
bnVtLAogCQkJICAgc3RydWN0IHZob3N0X2xvZyAqbG9nLCB1bnNpZ25lZCBpbnQgKmxvZ19udW0p
Owotdm9pZCB2aG9zdF9kaXNjYXJkX3ZxX2Rlc2Moc3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAqKTsK
K3ZvaWQgdmhvc3RfZGlzY2FyZF92cV9kZXNjKHN0cnVjdCB2aG9zdF92aXJ0cXVldWUgKiwgaW50
KTsKIAotaW50IHZob3N0X2FkZF91c2VkKHN0cnVjdCB2aG9zdF92aXJ0cXVldWUgKiwgdW5zaWdu
ZWQgaW50IGhlYWQsIGludCBsZW4pOwotdm9pZCB2aG9zdF9zaWduYWwoc3RydWN0IHZob3N0X2Rl
diAqLCBzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICopOworaW50IHZob3N0X2FkZF91c2VkKHN0cnVj
dCB2aG9zdF92aXJ0cXVldWUgKiwgc3RydWN0IGlvdmVjICpoZWFkcywgaW50IGNvdW50KTsKIHZv
aWQgdmhvc3RfYWRkX3VzZWRfYW5kX3NpZ25hbChzdHJ1Y3Qgdmhvc3RfZGV2ICosIHN0cnVjdCB2
aG9zdF92aXJ0cXVldWUgKiwKLQkJCSAgICAgICB1bnNpZ25lZCBpbnQgaGVhZCwgaW50IGxlbik7
CisJCQkgICAgICAgc3RydWN0IGlvdmVjICpoZWFkcywgaW50IGNvdW50LCBib29sIHJlY3ZyKTsK
K3ZvaWQgdmhvc3Rfc2lnbmFsKHN0cnVjdCB2aG9zdF9kZXYgKiwgc3RydWN0IHZob3N0X3ZpcnRx
dWV1ZSAqLCBib29sKTsKIHZvaWQgdmhvc3RfZGlzYWJsZV9ub3RpZnkoc3RydWN0IHZob3N0X3Zp
cnRxdWV1ZSAqKTsKLWJvb2wgdmhvc3RfZW5hYmxlX25vdGlmeShzdHJ1Y3Qgdmhvc3RfdmlydHF1
ZXVlICopOworYm9vbCB2aG9zdF9lbmFibGVfbm90aWZ5KHN0cnVjdCB2aG9zdF92aXJ0cXVldWUg
KiwgYm9vbCk7CiAKIGludCB2aG9zdF9sb2dfd3JpdGUoc3RydWN0IHZob3N0X3ZpcnRxdWV1ZSAq
dnEsIHN0cnVjdCB2aG9zdF9sb2cgKmxvZywKIAkJICAgIHVuc2lnbmVkIGludCBsb2dfbnVtLCB1
NjQgbGVuKTsKQEAgLTE0OSw3ICsxNTEsOCBAQCBlbnVtIHsKIAlWSE9TVF9GRUFUVVJFUyA9ICgx
IDw8IFZJUlRJT19GX05PVElGWV9PTl9FTVBUWSkgfAogCQkJICgxIDw8IFZJUlRJT19SSU5HX0Zf
SU5ESVJFQ1RfREVTQykgfAogCQkJICgxIDw8IFZIT1NUX0ZfTE9HX0FMTCkgfAotCQkJICgxIDw8
IFZIT1NUX05FVF9GX1ZJUlRJT19ORVRfSERSKSwKKwkJCSAoMSA8PCBWSE9TVF9ORVRfRl9WSVJU
SU9fTkVUX0hEUikgfAorCQkJICgxIDw8IFZJUlRJT19ORVRfRl9NUkdfUlhCVUYpLAogfTsKIAog
c3RhdGljIGlubGluZSBpbnQgdmhvc3RfaGFzX2ZlYXR1cmUoc3RydWN0IHZob3N0X2RldiAqZGV2
LCBpbnQgYml0KQo=

--=_mixed 0007AB60882576F7_=--
