From: Asias He <asias@redhat.com>
Subject: [RFC 2/5] VSOCK: Introduce virtio-vsock-common.ko
Date: Thu, 27 Jun 2013 16:00:01 +0800
Message-ID: <1372320004-20502-3-git-send-email-asias@redhat.com>
References: <1372320004-20502-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy King <acking@vmware.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	Reilly Grant <grantr@vmware.com>, Pekka Enberg <penberg@kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, Dmitry Torokhov <dtor@vmware.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1372320004-20502-1-git-send-email-asias@redhat.com>
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

This module contains the common code and header files for the following
virtio-vsock and virtio-vhost kernel modules.

Signed-off-by: Asias He <asias@redhat.com>
---
 include/linux/virtio_vsock.h            | 200 +++++++
 include/uapi/linux/virtio_ids.h         |   1 +
 include/uapi/linux/virtio_vsock.h       |  70 +++
 net/vmw_vsock/virtio_transport_common.c | 992 ++++++++++++++++++++++++++++++++
 4 files changed, 1263 insertions(+)
 create mode 100644 include/linux/virtio_vsock.h
 create mode 100644 include/uapi/linux/virtio_vsock.h
 create mode 100644 net/vmw_vsock/virtio_transport_common.c

diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
new file mode 100644
index 0000000..cd8ed95
--- /dev/null
+++ b/include/linux/virtio_vsock.h
@@ -0,0 +1,200 @@
+/*
+ * This header, excluding the #ifdef __KERNEL__ part, is BSD licensed so
+ * anyone can use the definitions to implement compatible drivers/servers:
+ *
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the name of IBM nor the names of its contributors
+ *    may be used to endorse or promote products derived from this software
+ *    without specific prior written permission.
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED.  IN NO EVENT SHALL IBM OR CONTRIBUTORS BE LIABLE
+ * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
+ * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
+ * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
+ * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
+ * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
+ * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGE.
+ *
+ * Copyright (C) Red Hat, Inc., 2013
+ * Copyright (C) Asias He <asias@redhat.com>, 2013
+ */
+
+#ifndef _LINUX_VIRTIO_VSOCK_H
+#define _LINUX_VIRTIO_VSOCK_H
+
+#include <uapi/linux/virtio_vsock.h>
+#include <linux/socket.h>
+#include <net/sock.h>
+
+#define VIRTIO_VSOCK_DEFAULT_MIN_BUF_SIZE	128
+#define VIRTIO_VSOCK_DEFAULT_BUF_SIZE		(1024 * 256)
+#define VIRTIO_VSOCK_DEFAULT_MAX_BUF_SIZE	(1024 * 256)
+#define VIRTIO_VSOCK_DEFAULT_RX_BUF_SIZE	(1024 * 4)
+#define VIRTIO_VSOCK_MAX_PKT_BUF_SIZE		(1024 * 64)
+
+struct vsock_transport_recv_notify_data;
+struct vsock_transport_send_notify_data;
+struct sockaddr_vm;
+struct vsock_sock;
+
+enum {
+	VSOCK_VQ_CTRL	= 0,
+	VSOCK_VQ_RX	= 1, /* for host to guest data */
+	VSOCK_VQ_TX	= 2, /* for guest to host data */
+	VSOCK_VQ_MAX	= 3,
+};
+
+/* virtio transport socket state */
+struct virtio_transport {
+	struct virtio_transport_pkt_ops	*ops;
+	struct vsock_sock *vsk;
+
+	u64 buf_size;
+	u64 buf_size_min;
+	u64 buf_size_max;
+
+	struct mutex tx_lock;
+	struct mutex rx_lock;
+
+	struct list_head rx_queue;
+	u64 rx_bytes;
+
+	/* Protected by trans->tx_lock */
+	u64 tx_cnt;
+	u64 buf_alloc;
+	u64 peer_fwd_cnt;
+	u64 peer_buf_alloc;
+	/* Protected by trans->rx_lock */
+	u64 fwd_cnt;
+};
+
+struct virtio_vsock_pkt {
+	struct virtio_vsock_hdr	hdr;
+	struct virtio_transport	*trans;
+	struct work_struct work;
+	struct list_head list;
+	void *buf;
+	u32 len;
+	u32 off;
+};
+
+struct virtio_vsock_pkt_info {
+	struct sockaddr_vm *src;
+	struct sockaddr_vm *dst;
+	struct iovec *iov;
+	u32 len;
+	u8 type;
+	u8 op;
+	u8 shut;
+};
+
+struct virtio_transport_pkt_ops {
+	int (*send_pkt)(struct vsock_sock *vsk,
+			struct virtio_vsock_pkt_info *info);
+};
+
+void virtio_vsock_dumppkt(const char *func,
+			  const struct virtio_vsock_pkt *pkt);
+
+struct sock *
+virtio_transport_get_pending(struct sock *listener,
+			     struct virtio_vsock_pkt *pkt);
+struct virtio_vsock_pkt *
+virtio_transport_alloc_pkt(struct vsock_sock *vsk,
+			   struct virtio_vsock_pkt_info *info,
+			   size_t len,
+			   u32 src_cid,
+			   u32 src_port,
+			   u32 dst_cid,
+			   u32 dst_port);
+ssize_t
+virtio_transport_stream_dequeue(struct vsock_sock *vsk,
+				struct iovec *iov,
+				size_t len,
+				int type);
+int
+virtio_transport_dgram_dequeue(struct kiocb *kiocb,
+			       struct vsock_sock *vsk,
+			       struct msghdr *msg,
+			       size_t len, int flags);
+
+s64 virtio_transport_stream_has_data(struct vsock_sock *vsk);
+s64 virtio_transport_stream_has_space(struct vsock_sock *vsk);
+
+int virtio_transport_do_socket_init(struct vsock_sock *vsk,
+				 struct vsock_sock *psk);
+u64 virtio_transport_get_buffer_size(struct vsock_sock *vsk);
+u64 virtio_transport_get_min_buffer_size(struct vsock_sock *vsk);
+u64 virtio_transport_get_max_buffer_size(struct vsock_sock *vsk);
+void virtio_transport_set_buffer_size(struct vsock_sock *vsk, u64 val);
+void virtio_transport_set_min_buffer_size(struct vsock_sock *vsk, u64 val);
+void virtio_transport_set_max_buffer_size(struct vsock_sock *vs, u64 val);
+int
+virtio_transport_notify_poll_in(struct vsock_sock *vsk,
+				size_t target,
+				bool *data_ready_now);
+int
+virtio_transport_notify_poll_out(struct vsock_sock *vsk,
+				 size_t target,
+				 bool *space_available_now);
+
+int virtio_transport_notify_recv_init(struct vsock_sock *vsk,
+	size_t target, struct vsock_transport_recv_notify_data *data);
+int virtio_transport_notify_recv_pre_block(struct vsock_sock *vsk,
+	size_t target, struct vsock_transport_recv_notify_data *data);
+int virtio_transport_notify_recv_pre_dequeue(struct vsock_sock *vsk,
+	size_t target, struct vsock_transport_recv_notify_data *data);
+int virtio_transport_notify_recv_post_dequeue(struct vsock_sock *vsk,
+	size_t target, ssize_t copied, bool data_read,
+	struct vsock_transport_recv_notify_data *data);
+int virtio_transport_notify_send_init(struct vsock_sock *vsk,
+	struct vsock_transport_send_notify_data *data);
+int virtio_transport_notify_send_pre_block(struct vsock_sock *vsk,
+	struct vsock_transport_send_notify_data *data);
+int virtio_transport_notify_send_pre_enqueue(struct vsock_sock *vsk,
+	struct vsock_transport_send_notify_data *data);
+int virtio_transport_notify_send_post_enqueue(struct vsock_sock *vsk,
+	ssize_t written, struct vsock_transport_send_notify_data *data);
+
+u64 virtio_transport_stream_rcvhiwat(struct vsock_sock *vsk);
+bool virtio_transport_stream_is_active(struct vsock_sock *vsk);
+bool virtio_transport_stream_allow(u32 cid, u32 port);
+int virtio_transport_dgram_bind(struct vsock_sock *vsk,
+				struct sockaddr_vm *addr);
+bool virtio_transport_dgram_allow(u32 cid, u32 port);
+
+int virtio_transport_connect(struct vsock_sock *vsk);
+
+int virtio_transport_shutdown(struct vsock_sock *vsk, int mode);
+
+void virtio_transport_release(struct vsock_sock *vsk);
+
+ssize_t
+virtio_transport_stream_enqueue(struct vsock_sock *vsk,
+				struct iovec *iov,
+				size_t len);
+int
+virtio_transport_dgram_enqueue(struct vsock_sock *vsk,
+			       struct sockaddr_vm *remote_addr,
+			       struct iovec *iov,
+			       size_t len);
+
+void virtio_transport_destruct(struct vsock_sock *vsk);
+
+void virtio_transport_recv_pkt(struct virtio_vsock_pkt *pkt);
+void virtio_transport_free_pkt(struct virtio_vsock_pkt *pkt);
+void virtio_transport_inc_tx_pkt(struct virtio_vsock_pkt *pkt);
+void virtio_transport_dec_tx_pkt(struct virtio_vsock_pkt *pkt);
+u64 virtio_transport_get_credit(struct virtio_transport *trans);
+#endif /* _LINUX_VIRTIO_VSOCK_H */
diff --git a/include/uapi/linux/virtio_ids.h b/include/uapi/linux/virtio_ids.h
index 284fc3a..8a27609 100644
--- a/include/uapi/linux/virtio_ids.h
+++ b/include/uapi/linux/virtio_ids.h
@@ -39,5 +39,6 @@
 #define VIRTIO_ID_9P		9 /* 9p virtio console */
 #define VIRTIO_ID_RPROC_SERIAL 11 /* virtio remoteproc serial link */
 #define VIRTIO_ID_CAIF	       12 /* Virtio caif */
+#define VIRTIO_ID_VSOCK        13 /* virtio vsock transport */
 
 #endif /* _LINUX_VIRTIO_IDS_H */
diff --git a/include/uapi/linux/virtio_vsock.h b/include/uapi/linux/virtio_vsock.h
new file mode 100644
index 0000000..0a58ac3
--- /dev/null
+++ b/include/uapi/linux/virtio_vsock.h
@@ -0,0 +1,70 @@
+/*
+ * This header, excluding the #ifdef __KERNEL__ part, is BSD licensed so
+ * anyone can use the definitions to implement compatible drivers/servers:
+ *
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the name of IBM nor the names of its contributors
+ *    may be used to endorse or promote products derived from this software
+ *    without specific prior written permission.
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED.  IN NO EVENT SHALL IBM OR CONTRIBUTORS BE LIABLE
+ * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
+ * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
+ * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
+ * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
+ * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
+ * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGE.
+ *
+ * Copyright (C) Red Hat, Inc., 2013
+ * Copyright (C) Asias He <asias@redhat.com>, 2013
+ */
+
+#ifndef _UAPI_LINUX_VIRTIO_VSOCK_H
+#define _UAPI_LINUX_VIRTIO_VOSCK_H
+
+#include <linux/types.h>
+#include <linux/virtio_ids.h>
+#include <linux/virtio_config.h>
+
+struct virtio_vsock_config {
+	__u32 guest_cid;
+	__u32 max_virtqueue_pairs;
+} __packed;
+
+struct virtio_vsock_hdr {
+	__u32	src_cid;
+	__u32	src_port;
+	__u32	dst_cid;
+	__u32	dst_port;
+	__u32	len;
+	__u8	type;
+	__u8	op;
+	__u8	shut;
+	__u64	fwd_cnt;
+	__u64	buf_alloc;
+} __packed;
+
+enum {
+	VIRTIO_VSOCK_OP_INVALID = 0,
+	VIRTIO_VSOCK_OP_REQUEST = 1,
+	VIRTIO_VSOCK_OP_NEGOTIATE = 2,
+	VIRTIO_VSOCK_OP_OFFER = 3,
+	VIRTIO_VSOCK_OP_ATTACH = 4,
+	VIRTIO_VSOCK_OP_RW = 5,
+	VIRTIO_VSOCK_OP_CREDIT = 6,
+	VIRTIO_VSOCK_OP_RST = 7,
+	VIRTIO_VSOCK_OP_SHUTDOWN = 8,
+};
+
+#endif /* _UAPI_LINUX_VIRTIO_VSOCK_H */
diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
new file mode 100644
index 0000000..0482eb1
--- /dev/null
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -0,0 +1,992 @@
+/*
+ * common code for virtio vsock
+ *
+ * Copyright (C) 2013 Red Hat, Inc.
+ * Author: Asias He <asias@redhat.com>
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2.
+ */
+#include <linux/module.h>
+#include <linux/ctype.h>
+#include <linux/list.h>
+#include <linux/virtio.h>
+#include <linux/virtio_ids.h>
+#include <linux/virtio_config.h>
+#include <linux/virtio_vsock.h>
+
+#include <net/sock.h>
+#include "af_vsock.h"
+
+#define SS_LISTEN 255
+
+void virtio_vsock_dumppkt(const char *func,  const struct virtio_vsock_pkt *pkt)
+{
+	pr_debug("%s: pkt=%p, op=%d, len=%d, %d:%d---%d:%d, len=%d\n",
+		 func, pkt, pkt->hdr.op, pkt->hdr.len,
+		 pkt->hdr.src_cid, pkt->hdr.src_port,
+		 pkt->hdr.dst_cid, pkt->hdr.dst_port, pkt->len);
+}
+EXPORT_SYMBOL_GPL(virtio_vsock_dumppkt);
+
+struct virtio_vsock_pkt *
+virtio_transport_alloc_pkt(struct vsock_sock *vsk,
+			   struct virtio_vsock_pkt_info *info,
+			   size_t len,
+			   u32 src_cid,
+			   u32 src_port,
+			   u32 dst_cid,
+			   u32 dst_port)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt *pkt;
+	int err;
+
+	BUG_ON(!trans);
+
+	pkt = kzalloc(sizeof(*pkt), GFP_KERNEL);
+	if (!pkt)
+		return NULL;
+
+	pkt->hdr.type		= info->type;
+	pkt->hdr.op		= info->op;
+	pkt->hdr.src_cid	= src_cid;
+	pkt->hdr.src_port	= src_port;
+	pkt->hdr.dst_cid	= dst_cid;
+	pkt->hdr.dst_port	= dst_port;
+	pkt->hdr.len		= len;
+	pkt->hdr.shut		= info->shut;
+	pkt->len		= len;
+	pkt->trans		= trans;
+
+	if (info->iov && len > 0) {
+		pkt->buf = kmalloc(len, GFP_KERNEL);
+		if (!pkt->buf)
+			goto out_pkt;
+		err = memcpy_fromiovec(pkt->buf, info->iov, len);
+		if (err)
+			goto out;
+	}
+
+	return pkt;
+
+out:
+	kfree(pkt->buf);
+out_pkt:
+	kfree(pkt);
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_alloc_pkt);
+
+struct sock *
+virtio_transport_get_pending(struct sock *listener,
+			     struct virtio_vsock_pkt *pkt)
+{
+	struct vsock_sock *vlistener;
+	struct vsock_sock *vpending;
+	struct sockaddr_vm src;
+	struct sockaddr_vm dst;
+	struct sock *pending;
+
+	vsock_addr_init(&src, pkt->hdr.src_cid, pkt->hdr.src_port);
+	vsock_addr_init(&dst, pkt->hdr.dst_cid, pkt->hdr.dst_port);
+
+	vlistener = vsock_sk(listener);
+	list_for_each_entry(vpending, &vlistener->pending_links,
+			    pending_links) {
+		if (vsock_addr_equals_addr(&src, &vpending->remote_addr) &&
+		    vsock_addr_equals_addr(&dst, &vpending->local_addr)) {
+			pending = sk_vsock(vpending);
+			sock_hold(pending);
+			return pending;
+		}
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_get_pending);
+
+static void virtio_transport_inc_rx_pkt(struct virtio_vsock_pkt *pkt)
+{
+	pkt->trans->rx_bytes += pkt->len;
+}
+
+static void virtio_transport_dec_rx_pkt(struct virtio_vsock_pkt *pkt)
+{
+	pkt->trans->rx_bytes -= pkt->len;
+	pkt->trans->fwd_cnt += pkt->len;
+}
+
+void virtio_transport_inc_tx_pkt(struct virtio_vsock_pkt *pkt)
+{
+	mutex_lock(&pkt->trans->tx_lock);
+	pkt->hdr.fwd_cnt = pkt->trans->fwd_cnt;
+	pkt->hdr.buf_alloc = pkt->trans->buf_alloc;
+	pkt->trans->tx_cnt += pkt->len;
+	mutex_unlock(&pkt->trans->tx_lock);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_inc_tx_pkt);
+
+void virtio_transport_dec_tx_pkt(struct virtio_vsock_pkt *pkt)
+{
+}
+EXPORT_SYMBOL_GPL(virtio_transport_dec_tx_pkt);
+
+u64 virtio_transport_get_credit(struct virtio_transport *trans)
+{
+	u64 credit;
+
+	mutex_lock(&trans->tx_lock);
+	credit = trans->peer_buf_alloc - (trans->tx_cnt - trans->peer_fwd_cnt);
+	mutex_unlock(&trans->tx_lock);
+
+	pr_debug("credit=%lld, buf_alloc=%lld, peer_buf_alloc=%lld,"
+		 "tx_cnt=%lld, fwd_cnt=%lld, peer_fwd_cnt=%lld\n",
+		 credit, trans->buf_alloc, trans->peer_buf_alloc,
+		 trans->tx_cnt, trans->fwd_cnt, trans->peer_fwd_cnt);
+
+	return credit;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_get_credit);
+
+static int virtio_transport_send_credit(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_CREDIT,
+		.type = SOCK_STREAM,
+	};
+
+	pr_debug("%s: sk=%p send_credit\n", __func__, vsk);
+	return trans->ops->send_pkt(vsk, &info);
+}
+
+static ssize_t
+virtio_transport_do_dequeue(struct vsock_sock *vsk,
+			    struct iovec *iov,
+			    size_t len,
+			    int type)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt *pkt;
+	size_t bytes, total = 0;
+	int err = -EFAULT;
+
+	mutex_lock(&trans->rx_lock);
+	while (total < len && trans->rx_bytes > 0  &&
+			!list_empty(&trans->rx_queue)) {
+		pkt = list_first_entry(&trans->rx_queue,
+				       struct virtio_vsock_pkt, list);
+
+		if (pkt->hdr.type != type)
+			continue;
+
+		bytes = len - total;
+		if (bytes > pkt->len - pkt->off)
+			bytes = pkt->len - pkt->off;
+
+		err = memcpy_toiovec(iov, pkt->buf + pkt->off, bytes);
+		if (err)
+			goto out;
+		total += bytes;
+		pkt->off += bytes;
+		if (pkt->off == pkt->len) {
+			virtio_transport_dec_rx_pkt(pkt);
+			list_del(&pkt->list);
+			virtio_transport_free_pkt(pkt);
+		}
+	}
+	mutex_unlock(&trans->rx_lock);
+
+	/* Send a credit pkt to peer */
+	if (type == SOCK_STREAM)
+		virtio_transport_send_credit(vsk);
+
+	return total;
+
+out:
+	mutex_unlock(&trans->rx_lock);
+	if (total)
+		err = total;
+	return err;
+}
+
+ssize_t
+virtio_transport_stream_dequeue(struct vsock_sock *vsk,
+				struct iovec *iov,
+				size_t len, int flags)
+{
+	if (flags & MSG_PEEK)
+		return -EOPNOTSUPP;
+
+	return virtio_transport_do_dequeue(vsk, iov, len, SOCK_STREAM);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_dequeue);
+
+static void
+virtio_transport_recv_dgram(struct sock *sk,
+			    struct virtio_vsock_pkt *pkt)
+{
+	struct sk_buff *skb;
+	struct vsock_sock *vsk;
+	size_t size;
+
+	vsk = vsock_sk(sk);
+
+	pkt->len = pkt->hdr.len;
+	pkt->off = 0;
+
+	size = sizeof(*pkt) + pkt->len;
+	/* Attach the packet to the socket's receive queue as an sk_buff. */
+	skb = alloc_skb(size, GFP_ATOMIC);
+	if (!skb)
+		goto out;
+
+	/* sk_receive_skb() will do a sock_put(), so hold here. */
+	sock_hold(sk);
+	skb_put(skb, size);
+	memcpy(skb->data, pkt, sizeof(*pkt));
+	memcpy(skb->data + sizeof(*pkt), pkt->buf, pkt->len);
+
+	sk_receive_skb(sk, skb, 0);
+out:
+	virtio_transport_free_pkt(pkt);
+}
+
+int
+virtio_transport_dgram_dequeue(struct kiocb *kiocb,
+			       struct vsock_sock *vsk,
+			       struct msghdr *msg,
+			       size_t len, int flags)
+{
+	struct virtio_vsock_pkt *pkt;
+	struct sk_buff *skb;
+	size_t payload_len;
+	int noblock;
+	int err;
+
+	noblock = flags & MSG_DONTWAIT;
+
+	if (flags & MSG_OOB || flags & MSG_ERRQUEUE)
+		return -EOPNOTSUPP;
+
+	msg->msg_namelen = 0;
+
+	/* Retrieve the head sk_buff from the socket's receive queue. */
+	err = 0;
+	skb = skb_recv_datagram(&vsk->sk, flags, noblock, &err);
+	if (err)
+		return err;
+	if (!skb)
+		return -EAGAIN;
+
+	pkt = (struct virtio_vsock_pkt *)skb->data;
+	if (!pkt)
+		goto out;
+
+	/* FIXME: check payload_len */
+	payload_len = pkt->len;
+
+	/* Place the datagram payload in the user's iovec. */
+	err = skb_copy_datagram_iovec(skb, sizeof(*pkt),
+				      msg->msg_iov, payload_len);
+	if (err)
+		goto out;
+
+	if (msg->msg_name) {
+		struct sockaddr_vm *vm_addr;
+
+		/* Provide the address of the sender. */
+		vm_addr = (struct sockaddr_vm *)msg->msg_name;
+		vsock_addr_init(vm_addr, pkt->hdr.src_cid, pkt->hdr.src_port);
+		msg->msg_namelen = sizeof(*vm_addr);
+	}
+	err = payload_len;
+
+out:
+	skb_free_datagram(&vsk->sk, skb);
+	return err;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_dgram_dequeue);
+
+s64 virtio_transport_stream_has_data(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+	size_t bytes = 0;
+
+	mutex_lock(&trans->rx_lock);
+	bytes = trans->rx_bytes;
+	mutex_unlock(&trans->rx_lock);
+
+	return bytes;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_has_data);
+
+static s64 __virtio_transport_stream_has_space(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+	size_t bytes = 0;
+
+	bytes = trans->peer_buf_alloc - (trans->tx_cnt - trans->peer_fwd_cnt);
+	if (bytes < 0)
+		bytes = 0;
+
+	return bytes;
+}
+
+s64 virtio_transport_stream_has_space(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+	size_t bytes = 0;
+
+	mutex_lock(&trans->tx_lock);
+	bytes = trans->peer_buf_alloc - (trans->tx_cnt - trans->peer_fwd_cnt);
+	if (bytes < 0)
+		bytes = 0;
+	mutex_unlock(&trans->tx_lock);
+	pr_debug("%s: bytes=%ld\n", __func__, bytes);
+
+	return bytes;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_has_space);
+
+int virtio_transport_do_socket_init(struct vsock_sock *vsk,
+				    struct vsock_sock *psk)
+{
+	struct virtio_transport *trans;
+
+	trans = kzalloc(sizeof(*trans), GFP_KERNEL);
+	if (!trans)
+		return -ENOMEM;
+
+	vsk->trans = trans;
+	trans->vsk = vsk;
+	if (psk) {
+		struct virtio_transport *ptrans = psk->trans;
+		trans->buf_size	= ptrans->buf_size;
+		trans->buf_size_min = ptrans->buf_size_min;
+		trans->buf_size_max = ptrans->buf_size_max;
+	} else {
+		trans->buf_size = VIRTIO_VSOCK_DEFAULT_BUF_SIZE;
+		trans->buf_size_min = VIRTIO_VSOCK_DEFAULT_MIN_BUF_SIZE;
+		trans->buf_size_max = VIRTIO_VSOCK_DEFAULT_MAX_BUF_SIZE;
+	}
+
+	trans->buf_alloc = trans->buf_size;
+	pr_debug("%s: trans->buf_alloc=%lld\n", __func__, trans->buf_alloc);
+
+	mutex_init(&trans->rx_lock);
+	mutex_init(&trans->tx_lock);
+	INIT_LIST_HEAD(&trans->rx_queue);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_do_socket_init);
+
+u64 virtio_transport_get_buffer_size(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+
+	return trans->buf_size;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_get_buffer_size);
+
+u64 virtio_transport_get_min_buffer_size(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+
+	return trans->buf_size_min;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_get_min_buffer_size);
+
+u64 virtio_transport_get_max_buffer_size(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+
+	return trans->buf_size_max;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_get_max_buffer_size);
+
+void virtio_transport_set_buffer_size(struct vsock_sock *vsk, u64 val)
+{
+	struct virtio_transport *trans = vsk->trans;
+
+	if (val < trans->buf_size_min)
+		trans->buf_size_min = val;
+	if (val > trans->buf_size_max)
+		trans->buf_size_max = val;
+	trans->buf_size = val;
+	trans->buf_alloc = val;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_set_buffer_size);
+
+void virtio_transport_set_min_buffer_size(struct vsock_sock *vsk, u64 val)
+{
+	struct virtio_transport *trans = vsk->trans;
+
+	if (val > trans->buf_size)
+		trans->buf_size = val;
+	trans->buf_size_min = val;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_set_min_buffer_size);
+
+void virtio_transport_set_max_buffer_size(struct vsock_sock *vsk, u64 val)
+{
+	struct virtio_transport *trans = vsk->trans;
+
+	if (val < trans->buf_size)
+		trans->buf_size = val;
+	trans->buf_size_max = val;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_set_max_buffer_size);
+
+int
+virtio_transport_notify_poll_in(struct vsock_sock *vsk,
+				size_t target,
+				bool *data_ready_now)
+{
+	if (vsock_stream_has_data(vsk))
+		*data_ready_now = true;
+	else
+		*data_ready_now = false;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_notify_poll_in);
+
+int
+virtio_transport_notify_poll_out(struct vsock_sock *vsk,
+				 size_t target,
+				 bool *space_avail_now)
+{
+	s64 free_space;
+
+	free_space = vsock_stream_has_space(vsk);
+	if (free_space > 0)
+		*space_avail_now = true;
+	else if (free_space == 0)
+		*space_avail_now = false;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_notify_poll_out);
+
+int virtio_transport_notify_recv_init(struct vsock_sock *vsk,
+	size_t target, struct vsock_transport_recv_notify_data *data)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_notify_recv_init);
+
+int virtio_transport_notify_recv_pre_block(struct vsock_sock *vsk,
+	size_t target, struct vsock_transport_recv_notify_data *data)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_notify_recv_pre_block);
+
+int virtio_transport_notify_recv_pre_dequeue(struct vsock_sock *vsk,
+	size_t target, struct vsock_transport_recv_notify_data *data)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_notify_recv_pre_dequeue);
+
+int virtio_transport_notify_recv_post_dequeue(struct vsock_sock *vsk,
+	size_t target, ssize_t copied, bool data_read,
+	struct vsock_transport_recv_notify_data *data)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_notify_recv_post_dequeue);
+
+int virtio_transport_notify_send_init(struct vsock_sock *vsk,
+	struct vsock_transport_send_notify_data *data)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_notify_send_init);
+
+int virtio_transport_notify_send_pre_block(struct vsock_sock *vsk,
+	struct vsock_transport_send_notify_data *data)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_notify_send_pre_block);
+
+int virtio_transport_notify_send_pre_enqueue(struct vsock_sock *vsk,
+	struct vsock_transport_send_notify_data *data)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_notify_send_pre_enqueue);
+
+int virtio_transport_notify_send_post_enqueue(struct vsock_sock *vsk,
+	ssize_t written, struct vsock_transport_send_notify_data *data)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_notify_send_post_enqueue);
+
+u64 virtio_transport_stream_rcvhiwat(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+
+	return trans->buf_size;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_rcvhiwat);
+
+bool virtio_transport_stream_is_active(struct vsock_sock *vsk)
+{
+	return true;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_is_active);
+
+bool virtio_transport_stream_allow(u32 cid, u32 port)
+{
+	return true;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_allow);
+
+int virtio_transport_dgram_bind(struct vsock_sock *vsk,
+				struct sockaddr_vm *addr)
+{
+	return vsock_bind_dgram_generic(vsk, addr);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_dgram_bind);
+
+bool virtio_transport_dgram_allow(u32 cid, u32 port)
+{
+	return true;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_dgram_allow);
+
+int virtio_transport_connect(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_REQUEST,
+		.type = SOCK_STREAM,
+	};
+
+	pr_debug("%s: vsk=%p send_request\n", __func__, vsk);
+	return trans->ops->send_pkt(vsk, &info);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_connect);
+
+int virtio_transport_shutdown(struct vsock_sock *vsk, int mode)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_SHUTDOWN,
+		.type = SOCK_STREAM,
+		.shut = mode,
+	};
+
+	pr_debug("%s: vsk=%p: send_shutdown\n", __func__, vsk);
+	return trans->ops->send_pkt(vsk, &info);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_shutdown);
+
+void virtio_transport_release(struct vsock_sock *vsk)
+{
+	pr_debug("%s: vsk=%p\n", __func__, vsk);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_release);
+
+int
+virtio_transport_dgram_enqueue(struct vsock_sock *vsk,
+			       struct sockaddr_vm *remote_addr,
+			       struct iovec *iov,
+			       size_t len)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_RW,
+		.type = SOCK_DGRAM,
+		.iov = iov,
+		.len = len,
+	};
+
+	vsk->remote_addr = *remote_addr;
+	return trans->ops->send_pkt(vsk, &info);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_dgram_enqueue);
+
+ssize_t
+virtio_transport_stream_enqueue(struct vsock_sock *vsk,
+				struct iovec *iov,
+				size_t len)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_RW,
+		.type = SOCK_STREAM,
+		.iov = iov,
+		.len = len,
+	};
+
+	return trans->ops->send_pkt(vsk, &info);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_enqueue);
+
+void virtio_transport_destruct(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+
+	pr_debug("%s: vsk=%p\n", __func__, vsk);
+	kfree(trans);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_destruct);
+
+static int virtio_transport_send_attach(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_ATTACH,
+		.type = SOCK_STREAM,
+	};
+
+	pr_debug("%s: vsk=%p send_attach\n", __func__, vsk);
+	return trans->ops->send_pkt(vsk, &info);
+}
+
+static int virtio_transport_send_offer(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_OFFER,
+		.type = SOCK_STREAM,
+	};
+
+	pr_debug("%s: sk=%p send_offer\n", __func__, vsk);
+	return trans->ops->send_pkt(vsk, &info);
+}
+
+static int virtio_transport_send_reset(struct vsock_sock *vsk,
+				       struct virtio_vsock_pkt *pkt)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_RST,
+		.type = SOCK_STREAM,
+	};
+
+	pr_debug("%s\n", __func__);
+
+	/* Send RST only if the original pkt is not a RST pkt */
+	if (pkt->hdr.op == VIRTIO_VSOCK_OP_RST)
+		return 0;
+
+	return trans->ops->send_pkt(vsk, &info);
+}
+
+static int
+virtio_transport_recv_connecting(struct sock *sk,
+				 struct virtio_vsock_pkt *pkt)
+{
+	struct vsock_sock *vsk = vsock_sk(sk);
+	int err;
+	int skerr;
+
+	pr_debug("%s: vsk=%p\n", __func__, vsk);
+	switch (pkt->hdr.op) {
+	case VIRTIO_VSOCK_OP_ATTACH:
+		pr_debug("%s: got attach\n", __func__);
+		sk->sk_state = SS_CONNECTED;
+		sk->sk_socket->state = SS_CONNECTED;
+		vsock_insert_connected(vsk);
+		sk->sk_state_change(sk);
+		break;
+	case VIRTIO_VSOCK_OP_NEGOTIATE:
+		pr_debug("%s: got negotiate and send_offer\n", __func__);
+		err = virtio_transport_send_offer(vsk);
+		if (err < 0) {
+			skerr = -err;
+			goto destroy;
+		}
+		break;
+	case VIRTIO_VSOCK_OP_INVALID:
+		pr_debug("%s: got invalid\n", __func__);
+		break;
+	case VIRTIO_VSOCK_OP_RST:
+		pr_debug("%s: got rst\n", __func__);
+		skerr = ECONNRESET;
+		err = 0;
+		goto destroy;
+	default:
+		pr_debug("%s: got def\n", __func__);
+		skerr = EPROTO;
+		err = -EINVAL;
+		goto destroy;
+	}
+	return 0;
+
+destroy:
+	virtio_transport_send_reset(vsk, pkt);
+	sk->sk_state = SS_UNCONNECTED;
+	sk->sk_err = skerr;
+	sk->sk_error_report(sk);
+	return err;
+}
+
+static int
+virtio_transport_recv_connected(struct sock *sk,
+				struct virtio_vsock_pkt *pkt)
+{
+	struct vsock_sock *vsk = vsock_sk(sk);
+	struct virtio_transport *trans = vsk->trans;
+	int err = 0;
+
+	switch (pkt->hdr.op) {
+	case VIRTIO_VSOCK_OP_RW:
+		pkt->len = pkt->hdr.len;
+		pkt->off = 0;
+		pkt->trans = trans;
+
+		mutex_lock(&trans->rx_lock);
+		virtio_transport_inc_rx_pkt(pkt);
+		list_add_tail(&pkt->list, &trans->rx_queue);
+		mutex_unlock(&trans->rx_lock);
+
+		sk->sk_data_ready(sk, pkt->len);
+		return err;
+	case VIRTIO_VSOCK_OP_CREDIT:
+		sk->sk_write_space(sk);
+		break;
+	case VIRTIO_VSOCK_OP_SHUTDOWN:
+		pr_debug("%s: got shutdown\n", __func__);
+		if (pkt->hdr.shut) {
+			vsk->peer_shutdown |= pkt->hdr.shut;
+			sk->sk_state_change(sk);
+		}
+		break;
+	case VIRTIO_VSOCK_OP_RST:
+		pr_debug("%s: got rst\n", __func__);
+		sock_set_flag(sk, SOCK_DONE);
+		vsk->peer_shutdown = SHUTDOWN_MASK;
+		if (vsock_stream_has_data(vsk) <= 0)
+			sk->sk_state = SS_DISCONNECTING;
+		sk->sk_state_change(sk);
+		break;
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+	virtio_transport_free_pkt(pkt);
+	return err;
+}
+
+static int
+virtio_transport_send_negotiate(struct vsock_sock *vsk,
+				struct virtio_vsock_pkt *pkt)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_NEGOTIATE,
+		.type = SOCK_STREAM,
+	};
+
+	pr_debug("%s: send_negotiate\n", __func__);
+
+	return trans->ops->send_pkt(vsk, &info);
+}
+
+/* Handle server socket */
+static int
+virtio_transport_recv_listen(struct sock *sk, struct virtio_vsock_pkt *pkt)
+{
+	struct vsock_sock *vsk = vsock_sk(sk);
+	struct vsock_sock *vpending;
+	struct sock *pending;
+	int err;
+
+	pending = virtio_transport_get_pending(sk, pkt);
+	if (pending) {
+		pr_debug("virtio_transport_recv_listen: get pending\n");
+		vpending = vsock_sk(pending);
+		lock_sock(pending);
+		switch (pending->sk_state) {
+		case SS_CONNECTING:
+			if (pkt->hdr.op != VIRTIO_VSOCK_OP_OFFER) {
+				pr_debug("%s: != OP_OFFER op=%d\n",
+					 __func__, pkt->hdr.op);
+				virtio_transport_send_reset(vpending, pkt);
+				pending->sk_err = EPROTO;
+				pending->sk_state = SS_UNCONNECTED;
+				sock_put(pending);
+			} else {
+				pending->sk_state = SS_CONNECTED;
+				vsock_insert_connected(vpending);
+
+				vsock_remove_pending(sk, pending);
+				vsock_enqueue_accept(sk, pending);
+
+				virtio_transport_send_attach(vpending);
+				sk->sk_state_change(sk);
+			}
+			err = 0;
+			break;
+		default:
+			pr_debug("%s: sk->sk_ack_backlog=%d\n", __func__,
+				 sk->sk_ack_backlog);
+			virtio_transport_send_reset(vpending, pkt);
+			err = -EINVAL;
+			break;
+		}
+		if (err < 0)
+			vsock_remove_pending(sk, pending);
+		release_sock(pending);
+
+		/* Release refcnt obtained in virtio_transport_get_pending */
+		sock_put(pending);
+
+		return err;
+	}
+
+	if (pkt->hdr.op != VIRTIO_VSOCK_OP_REQUEST) {
+		virtio_transport_send_reset(vsk, pkt);
+		pr_debug("%s:op != OP_REQUEST op = %d\n",
+			 __func__, pkt->hdr.op);
+		return -EINVAL;
+	}
+
+	if (sk->sk_ack_backlog >= sk->sk_max_ack_backlog) {
+		pr_debug("%s: sk->sk_ack_backlog=%d\n", __func__,
+			 sk->sk_ack_backlog);
+		virtio_transport_send_reset(vsk, pkt);
+		return -ECONNREFUSED;
+	}
+
+	/* So no pending socket are responsible for this pkt, create one */
+	pending = __vsock_create(sock_net(sk), NULL, sk, GFP_KERNEL,
+				 sk->sk_type);
+	if (!pending) {
+		virtio_transport_send_reset(vsk, pkt);
+		return -ENOMEM;
+	}
+	pr_debug("virtio_transport_recv_listen: create pending\n");
+
+	vpending = vsock_sk(pending);
+	vsock_addr_init(&vpending->local_addr, pkt->hdr.dst_cid,
+			pkt->hdr.dst_port);
+	vsock_addr_init(&vpending->remote_addr, pkt->hdr.src_cid,
+			pkt->hdr.src_port);
+
+	vsock_add_pending(sk, pending);
+
+	err = virtio_transport_send_negotiate(vpending, pkt);
+	if (err < 0) {
+		virtio_transport_send_reset(vsk, pkt);
+		sock_put(pending);
+		return err;
+	}
+
+	sk->sk_ack_backlog++;
+
+	pending->sk_state = SS_CONNECTING;
+
+	/* Clean up in case no further message is received for this socket */
+	vpending->listener = sk;
+	sock_hold(sk);
+	sock_hold(pending);
+	INIT_DELAYED_WORK(&vpending->dwork, vsock_pending_work);
+	schedule_delayed_work(&vpending->dwork, HZ);
+
+	return 0;
+}
+
+void virtio_transport_recv_pkt(struct virtio_vsock_pkt *pkt)
+{
+	struct virtio_transport *trans;
+	struct sockaddr_vm src, dst;
+	struct vsock_sock *vsk;
+	struct sock *sk;
+
+	vsock_addr_init(&src, pkt->hdr.src_cid, pkt->hdr.src_port);
+	vsock_addr_init(&dst, pkt->hdr.dst_cid, pkt->hdr.dst_port);
+
+	virtio_vsock_dumppkt(__func__, pkt);
+
+	if (pkt->hdr.type == SOCK_DGRAM) {
+		sk = vsock_find_unbound_socket(&dst);
+		if (!sk)
+			goto free_pkt;
+		return virtio_transport_recv_dgram(sk, pkt);
+	}
+
+	/* The socket must be in connected or bound table
+	 * otherwise send reset back
+	 */
+	sk = vsock_find_connected_socket(&src, &dst);
+	if (!sk) {
+		sk = vsock_find_bound_socket(&dst);
+		if (!sk) {
+			pr_debug("%s: can not find bound_socket\n", __func__);
+			virtio_vsock_dumppkt(__func__, pkt);
+			/* Ignore this pkt instead of sending reset back */
+			goto free_pkt;
+		}
+	}
+
+	vsk = vsock_sk(sk);
+	trans = vsk->trans;
+	BUG_ON(!trans);
+
+	mutex_lock(&trans->tx_lock);
+	trans->peer_buf_alloc = pkt->hdr.buf_alloc;
+	trans->peer_fwd_cnt = pkt->hdr.fwd_cnt;
+	if (__virtio_transport_stream_has_space(vsk))
+		sk->sk_write_space(sk);
+	mutex_unlock(&trans->tx_lock);
+
+	lock_sock(sk);
+	switch (sk->sk_state) {
+	case SS_LISTEN:
+		virtio_transport_recv_listen(sk, pkt);
+		virtio_transport_free_pkt(pkt);
+		break;
+	case SS_CONNECTING:
+		virtio_transport_recv_connecting(sk, pkt);
+		virtio_transport_free_pkt(pkt);
+		break;
+	case SS_CONNECTED:
+		virtio_transport_recv_connected(sk, pkt);
+		break;
+	default:
+		break;
+	}
+	release_sock(sk);
+
+	/* Release refcnt obtained when we fetched this socket out of the
+	 * bound or connected list.
+	 */
+	sock_put(sk);
+	return;
+
+free_pkt:
+	virtio_transport_free_pkt(pkt);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_recv_pkt);
+
+void virtio_transport_free_pkt(struct virtio_vsock_pkt *pkt)
+{
+	kfree(pkt->buf);
+	kfree(pkt);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_free_pkt);
+
+static int __init virtio_vsock_common_init(void)
+{
+	return 0;
+}
+
+static void __exit virtio_vsock_common_exit(void)
+{
+}
+
+module_init(virtio_vsock_common_init);
+module_exit(virtio_vsock_common_exit);
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Asias He");
+MODULE_DESCRIPTION("common code for virtio vsock");
-- 
1.8.1.4
