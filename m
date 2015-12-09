From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 1/4] VSOCK: Introduce virtio-vsock-common.ko
Date: Wed,  9 Dec 2015 20:03:50 +0800
Message-ID: <1449662633-26623-2-git-send-email-stefanha@redhat.com>
References: <1449662633-26623-1-git-send-email-stefanha@redhat.com>
Cc: Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	matt.ma@linaro.org, virtualization@lists.linux-foundation.org,
	Asias He <asias@redhat.com>,
	Stefan Hajnoczi <stefanha@redhat.com>
To: kvm@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1449662633-26623-1-git-send-email-stefanha@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asias He <asias@redhat.com>

This module contains the common code and header files for the following
virtio-vsock and virtio-vhost kernel modules.

Signed-off-by: Asias He <asias@redhat.com>
Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
v3:
 * Remove unnecessary 3-way handshake, just do REQUEST/RESPONSE instead
   of REQUEST/RESPONSE/ACK
 * Remove SOCK_DGRAM support and focus on SOCK_STREAM first
 * Only allow host->guest connections (same security model as latest
   VMware)
v2:
 * Fix peer_buf_alloc inheritance on child socket
 * Notify other side of SOCK_STREAM disconnect (fixes shutdown
   semantics)
 * Avoid recursive mutex_lock(tx_lock) for write_space (fixes deadlock)
 * Define VIRTIO_VSOCK_TYPE_STREAM/DGRAM hardware interface constants
 * Define VIRTIO_VSOCK_SHUTDOWN_RCV/SEND hardware interface constants
---
 include/linux/virtio_vsock.h            | 203 ++++++++
 include/uapi/linux/virtio_ids.h         |   1 +
 include/uapi/linux/virtio_vsock.h       |  87 ++++
 net/vmw_vsock/virtio_transport_common.c | 854 ++++++++++++++++++++++++++++++++
 4 files changed, 1145 insertions(+)
 create mode 100644 include/linux/virtio_vsock.h
 create mode 100644 include/uapi/linux/virtio_vsock.h
 create mode 100644 net/vmw_vsock/virtio_transport_common.c

diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
new file mode 100644
index 0000000..e54eb45
--- /dev/null
+++ b/include/linux/virtio_vsock.h
@@ -0,0 +1,203 @@
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
+ * Copyright (C) Red Hat, Inc., 2013-2015
+ * Copyright (C) Asias He <asias@redhat.com>, 2013
+ * Copyright (C) Stefan Hajnoczi <stefanha@redhat.com>, 2015
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
+#define VIRTIO_VSOCK_MAX_BUF_SIZE		0xFFFFFFFFUL
+#define VIRTIO_VSOCK_MAX_PKT_BUF_SIZE		(1024 * 64)
+#define VIRTIO_VSOCK_MAX_TX_BUF_SIZE		(1024 * 1024 * 16)
+#define VIRTIO_VSOCK_MAX_DGRAM_SIZE		(1024 * 64)
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
+	u32 buf_size;
+	u32 buf_size_min;
+	u32 buf_size_max;
+
+	struct mutex tx_lock;
+	struct mutex rx_lock;
+
+	struct list_head rx_queue;
+	u32 rx_bytes;
+
+	/* Protected by trans->tx_lock */
+	u32 tx_cnt;
+	u32 buf_alloc;
+	u32 peer_fwd_cnt;
+	u32 peer_buf_alloc;
+	/* Protected by trans->rx_lock */
+	u32 fwd_cnt;
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
+	u32 remote_cid, remote_port;
+	struct msghdr *msg;
+	u32 pkt_len;
+	u16 type;
+	u16 op;
+	u32 flags;
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
+				struct msghdr *msg,
+				size_t len,
+				int type);
+int
+virtio_transport_dgram_dequeue(struct vsock_sock *vsk,
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
+				struct msghdr *msg,
+				size_t len);
+int
+virtio_transport_dgram_enqueue(struct vsock_sock *vsk,
+			       struct sockaddr_vm *remote_addr,
+			       struct msghdr *msg,
+			       size_t len);
+
+void virtio_transport_destruct(struct vsock_sock *vsk);
+
+void virtio_transport_recv_pkt(struct virtio_vsock_pkt *pkt);
+void virtio_transport_free_pkt(struct virtio_vsock_pkt *pkt);
+void virtio_transport_inc_tx_pkt(struct virtio_vsock_pkt *pkt);
+void virtio_transport_dec_tx_pkt(struct virtio_vsock_pkt *pkt);
+u32 virtio_transport_get_credit(struct virtio_transport *trans, u32 wanted);
+void virtio_transport_put_credit(struct virtio_transport *trans, u32 credit);
+#endif /* _LINUX_VIRTIO_VSOCK_H */
diff --git a/include/uapi/linux/virtio_ids.h b/include/uapi/linux/virtio_ids.h
index 77925f5..16dcf5d 100644
--- a/include/uapi/linux/virtio_ids.h
+++ b/include/uapi/linux/virtio_ids.h
@@ -39,6 +39,7 @@
 #define VIRTIO_ID_9P		9 /* 9p virtio console */
 #define VIRTIO_ID_RPROC_SERIAL 11 /* virtio remoteproc serial link */
 #define VIRTIO_ID_CAIF	       12 /* Virtio caif */
+#define VIRTIO_ID_VSOCK        13 /* virtio vsock transport */
 #define VIRTIO_ID_GPU          16 /* virtio GPU */
 #define VIRTIO_ID_INPUT        18 /* virtio input */
 
diff --git a/include/uapi/linux/virtio_vsock.h b/include/uapi/linux/virtio_vsock.h
new file mode 100644
index 0000000..ac6483d
--- /dev/null
+++ b/include/uapi/linux/virtio_vsock.h
@@ -0,0 +1,87 @@
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
+ * Copyright (C) Red Hat, Inc., 2013-2015
+ * Copyright (C) Asias He <asias@redhat.com>, 2013
+ * Copyright (C) Stefan Hajnoczi <stefanha@redhat.com>, 2015
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
+	__le32 guest_cid;
+	__le32 max_virtqueue_pairs;
+};
+
+struct virtio_vsock_hdr {
+	__le32	src_cid;
+	__le32	src_port;
+	__le32	dst_cid;
+	__le32	dst_port;
+	__le32	len;
+	__le16	type;		/* enum virtio_vsock_type */
+	__le16	op;		/* enum virtio_vsock_op */
+	__le32	flags;
+	__le32	buf_alloc;
+	__le32	fwd_cnt;
+};
+
+enum virtio_vsock_type {
+	VIRTIO_VSOCK_TYPE_STREAM = 1,
+};
+
+enum virtio_vsock_op {
+	VIRTIO_VSOCK_OP_INVALID = 0,
+
+	/* Connect operations */
+	VIRTIO_VSOCK_OP_REQUEST = 1,
+	VIRTIO_VSOCK_OP_RESPONSE = 2,
+	VIRTIO_VSOCK_OP_RST = 3,
+	VIRTIO_VSOCK_OP_SHUTDOWN = 4,
+
+	/* To send payload */
+	VIRTIO_VSOCK_OP_RW = 5,
+
+	/* Tell the peer our credit info */
+	VIRTIO_VSOCK_OP_CREDIT_UPDATE = 6,
+	/* Request the peer to send the credit info to us */
+	VIRTIO_VSOCK_OP_CREDIT_REQUEST = 7,
+};
+
+/* VIRTIO_VSOCK_OP_SHUTDOWN flags values */
+enum virtio_vsock_shutdown {
+	VIRTIO_VSOCK_SHUTDOWN_RCV = 1,
+	VIRTIO_VSOCK_SHUTDOWN_SEND = 2,
+};
+
+#endif /* _UAPI_LINUX_VIRTIO_VSOCK_H */
diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
new file mode 100644
index 0000000..025a323
--- /dev/null
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -0,0 +1,854 @@
+/*
+ * common code for virtio vsock
+ *
+ * Copyright (C) 2013-2015 Red Hat, Inc.
+ * Author: Asias He <asias@redhat.com>
+ *         Stefan Hajnoczi <stefanha@redhat.com>
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
+#include <net/af_vsock.h>
+
+void virtio_vsock_dumppkt(const char *func,  const struct virtio_vsock_pkt *pkt)
+{
+	pr_debug("%s: pkt=%p, op=%d, len=%d, %d:%d---%d:%d, len=%d\n",
+		 func, pkt,
+		 le16_to_cpu(pkt->hdr.op),
+		 le32_to_cpu(pkt->hdr.len),
+		 le32_to_cpu(pkt->hdr.src_cid),
+		 le32_to_cpu(pkt->hdr.src_port),
+		 le32_to_cpu(pkt->hdr.dst_cid),
+		 le32_to_cpu(pkt->hdr.dst_port),
+		 pkt->len);
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
+	pkt->hdr.type		= cpu_to_le16(info->type);
+	pkt->hdr.op		= cpu_to_le16(info->op);
+	pkt->hdr.src_cid	= cpu_to_le32(src_cid);
+	pkt->hdr.src_port	= cpu_to_le32(src_port);
+	pkt->hdr.dst_cid	= cpu_to_le32(dst_cid);
+	pkt->hdr.dst_port	= cpu_to_le32(dst_port);
+	pkt->hdr.flags		= cpu_to_le32(info->flags);
+	pkt->len		= len;
+	pkt->trans		= trans;
+	pkt->hdr.len		= cpu_to_le32(len);
+
+	if (info->msg && len > 0) {
+		pkt->buf = kmalloc(len, GFP_KERNEL);
+		if (!pkt->buf)
+			goto out_pkt;
+		err = memcpy_from_msg(pkt->buf, info->msg, len);
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
+	vsock_addr_init(&src, le32_to_cpu(pkt->hdr.src_cid), le32_to_cpu(pkt->hdr.src_port));
+	vsock_addr_init(&dst, le32_to_cpu(pkt->hdr.dst_cid), le32_to_cpu(pkt->hdr.dst_port));
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
+	pkt->hdr.fwd_cnt = cpu_to_le32(pkt->trans->fwd_cnt);
+	pkt->hdr.buf_alloc = cpu_to_le32(pkt->trans->buf_alloc);
+	mutex_unlock(&pkt->trans->tx_lock);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_inc_tx_pkt);
+
+void virtio_transport_dec_tx_pkt(struct virtio_vsock_pkt *pkt)
+{
+}
+EXPORT_SYMBOL_GPL(virtio_transport_dec_tx_pkt);
+
+u32 virtio_transport_get_credit(struct virtio_transport *trans, u32 credit)
+{
+	u32 ret;
+
+	mutex_lock(&trans->tx_lock);
+	ret = trans->peer_buf_alloc - (trans->tx_cnt - trans->peer_fwd_cnt);
+	if (ret > credit)
+		ret = credit;
+	trans->tx_cnt += ret;
+	mutex_unlock(&trans->tx_lock);
+
+	pr_debug("%s: ret=%d, buf_alloc=%d, peer_buf_alloc=%d,"
+		 "tx_cnt=%d, fwd_cnt=%d, peer_fwd_cnt=%d\n", __func__,
+		 ret, trans->buf_alloc, trans->peer_buf_alloc,
+		 trans->tx_cnt, trans->fwd_cnt, trans->peer_fwd_cnt);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_get_credit);
+
+void virtio_transport_put_credit(struct virtio_transport *trans, u32 credit)
+{
+	mutex_lock(&trans->tx_lock);
+	trans->tx_cnt -= credit;
+	mutex_unlock(&trans->tx_lock);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_put_credit);
+
+static int virtio_transport_send_credit_update(struct vsock_sock *vsk, int type, struct virtio_vsock_hdr *hdr)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_CREDIT_UPDATE,
+		.type = type,
+	};
+
+	pr_debug("%s: sk=%p send_credit_update\n", __func__, vsk);
+	return trans->ops->send_pkt(vsk, &info);
+}
+
+static ssize_t
+virtio_transport_stream_do_dequeue(struct vsock_sock *vsk,
+				   struct msghdr *msg,
+				   size_t len)
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
+		bytes = len - total;
+		if (bytes > pkt->len - pkt->off)
+			bytes = pkt->len - pkt->off;
+
+		err = memcpy_to_msg(msg, pkt->buf + pkt->off, bytes);
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
+	virtio_transport_send_credit_update(vsk, VIRTIO_VSOCK_TYPE_STREAM,
+					    NULL);
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
+				struct msghdr *msg,
+				size_t len, int flags)
+{
+	if (flags & MSG_PEEK)
+		return -EOPNOTSUPP;
+
+	return virtio_transport_stream_do_dequeue(vsk, msg, len);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_dequeue);
+
+int
+virtio_transport_dgram_dequeue(struct vsock_sock *vsk,
+			       struct msghdr *msg,
+			       size_t len, int flags)
+{
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_dgram_dequeue);
+
+s64 virtio_transport_stream_has_data(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+	s64 bytes;
+
+	mutex_lock(&trans->rx_lock);
+	bytes = trans->rx_bytes;
+	mutex_unlock(&trans->rx_lock);
+
+	return bytes;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_has_data);
+
+static s64 virtio_transport_has_space(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+	s64 bytes;
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
+	s64 bytes;
+
+	mutex_lock(&trans->tx_lock);
+	bytes = virtio_transport_has_space(vsk);
+	mutex_unlock(&trans->tx_lock);
+
+	pr_debug("%s: bytes=%lld\n", __func__, bytes);
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
+		trans->peer_buf_alloc = ptrans->peer_buf_alloc;
+	} else {
+		trans->buf_size = VIRTIO_VSOCK_DEFAULT_BUF_SIZE;
+		trans->buf_size_min = VIRTIO_VSOCK_DEFAULT_MIN_BUF_SIZE;
+		trans->buf_size_max = VIRTIO_VSOCK_DEFAULT_MAX_BUF_SIZE;
+	}
+
+	trans->buf_alloc = trans->buf_size;
+
+	pr_debug("%s: trans->buf_alloc=%d\n", __func__, trans->buf_alloc);
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
+	if (val > VIRTIO_VSOCK_MAX_BUF_SIZE)
+		val = VIRTIO_VSOCK_MAX_BUF_SIZE;
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
+	if (val > VIRTIO_VSOCK_MAX_BUF_SIZE)
+		val = VIRTIO_VSOCK_MAX_BUF_SIZE;
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
+	if (val > VIRTIO_VSOCK_MAX_BUF_SIZE)
+		val = VIRTIO_VSOCK_MAX_BUF_SIZE;
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
+	/* Only allow guest->host connections */
+	return cid != VMADDR_CID_HOST;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_allow);
+
+int virtio_transport_dgram_bind(struct vsock_sock *vsk,
+				struct sockaddr_vm *addr)
+{
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_dgram_bind);
+
+bool virtio_transport_dgram_allow(u32 cid, u32 port)
+{
+	return false;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_dgram_allow);
+
+int virtio_transport_connect(struct vsock_sock *vsk)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_REQUEST,
+		.type = VIRTIO_VSOCK_TYPE_STREAM,
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
+		.type = VIRTIO_VSOCK_TYPE_STREAM,
+		.flags = (mode & RCV_SHUTDOWN ?
+			  VIRTIO_VSOCK_SHUTDOWN_RCV : 0) |
+			 (mode & SEND_SHUTDOWN ?
+			  VIRTIO_VSOCK_SHUTDOWN_SEND : 0),
+	};
+
+	pr_debug("%s: vsk=%p: send_shutdown\n", __func__, vsk);
+	return trans->ops->send_pkt(vsk, &info);
+}
+EXPORT_SYMBOL_GPL(virtio_transport_shutdown);
+
+void virtio_transport_release(struct vsock_sock *vsk)
+{
+	struct sock *sk = &vsk->sk;
+
+	pr_debug("%s: vsk=%p\n", __func__, vsk);
+
+	/* Tell other side to terminate connection */
+	if (sk->sk_type == SOCK_STREAM && sk->sk_state == SS_CONNECTED) {
+		virtio_transport_shutdown(vsk, SHUTDOWN_MASK);
+	}
+}
+EXPORT_SYMBOL_GPL(virtio_transport_release);
+
+int
+virtio_transport_dgram_enqueue(struct vsock_sock *vsk,
+			       struct sockaddr_vm *remote_addr,
+			       struct msghdr *msg,
+			       size_t dgram_len)
+{
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_dgram_enqueue);
+
+ssize_t
+virtio_transport_stream_enqueue(struct vsock_sock *vsk,
+				struct msghdr *msg,
+				size_t len)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_RW,
+		.type = VIRTIO_VSOCK_TYPE_STREAM,
+		.msg = msg,
+		.pkt_len = len,
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
+static int virtio_transport_send_reset(struct vsock_sock *vsk,
+				       struct virtio_vsock_pkt *pkt)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_RST,
+		.type = VIRTIO_VSOCK_TYPE_STREAM,
+	};
+
+	pr_debug("%s\n", __func__);
+
+	/* Send RST only if the original pkt is not a RST pkt */
+	if (le16_to_cpu(pkt->hdr.op) == VIRTIO_VSOCK_OP_RST)
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
+	switch (le16_to_cpu(pkt->hdr.op)) {
+	case VIRTIO_VSOCK_OP_RESPONSE:
+		pr_debug("%s: got RESPONSE\n", __func__);
+		sk->sk_state = SS_CONNECTED;
+		sk->sk_socket->state = SS_CONNECTED;
+		vsock_insert_connected(vsk);
+		sk->sk_state_change(sk);
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
+	switch (le16_to_cpu(pkt->hdr.op)) {
+	case VIRTIO_VSOCK_OP_RW:
+		pkt->len = le32_to_cpu(pkt->hdr.len);
+		pkt->off = 0;
+		pkt->trans = trans;
+
+		mutex_lock(&trans->rx_lock);
+		virtio_transport_inc_rx_pkt(pkt);
+		list_add_tail(&pkt->list, &trans->rx_queue);
+		mutex_unlock(&trans->rx_lock);
+
+		sk->sk_data_ready(sk);
+		return err;
+	case VIRTIO_VSOCK_OP_CREDIT_UPDATE:
+		sk->sk_write_space(sk);
+		break;
+	case VIRTIO_VSOCK_OP_SHUTDOWN:
+		pr_debug("%s: got shutdown\n", __func__);
+		if (le32_to_cpu(pkt->hdr.flags) & VIRTIO_VSOCK_SHUTDOWN_RCV)
+			vsk->peer_shutdown |= RCV_SHUTDOWN;
+		if (le32_to_cpu(pkt->hdr.flags) & VIRTIO_VSOCK_SHUTDOWN_SEND)
+			vsk->peer_shutdown |= SEND_SHUTDOWN;
+		if (le32_to_cpu(pkt->hdr.flags))
+			sk->sk_state_change(sk);
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
+virtio_transport_send_response(struct vsock_sock *vsk,
+			       struct virtio_vsock_pkt *pkt)
+{
+	struct virtio_transport *trans = vsk->trans;
+	struct virtio_vsock_pkt_info info = {
+		.op = VIRTIO_VSOCK_OP_RESPONSE,
+		.type = VIRTIO_VSOCK_TYPE_STREAM,
+		.remote_cid = le32_to_cpu(pkt->hdr.src_cid),
+		.remote_port = le32_to_cpu(pkt->hdr.src_port),
+	};
+
+	pr_debug("%s: send_response\n", __func__);
+
+	return trans->ops->send_pkt(vsk, &info);
+}
+
+/* Handle server socket */
+static int
+virtio_transport_recv_listen(struct sock *sk, struct virtio_vsock_pkt *pkt)
+{
+	struct vsock_sock *vsk = vsock_sk(sk);
+	struct vsock_sock *vchild;
+	struct sock *child;
+
+	if (le16_to_cpu(pkt->hdr.op) != VIRTIO_VSOCK_OP_REQUEST) {
+		virtio_transport_send_reset(vsk, pkt);
+		return -EINVAL;
+	}
+
+	if (sk_acceptq_is_full(sk)) {
+		virtio_transport_send_reset(vsk, pkt);
+		return -ENOMEM;
+	}
+
+	pr_debug("%s: create pending\n", __func__);
+	child = __vsock_create(sock_net(sk), NULL, sk, GFP_KERNEL,
+			       sk->sk_type, 0);
+	if (!child) {
+		virtio_transport_send_reset(vsk, pkt);
+		return -ENOMEM;
+	}
+
+	sk->sk_ack_backlog++;
+
+	lock_sock(child);
+
+	child->sk_state = SS_CONNECTED;
+
+	vchild = vsock_sk(child);
+	vsock_addr_init(&vchild->local_addr, le32_to_cpu(pkt->hdr.dst_cid),
+			le32_to_cpu(pkt->hdr.dst_port));
+	vsock_addr_init(&vchild->remote_addr, le32_to_cpu(pkt->hdr.src_cid),
+			le32_to_cpu(pkt->hdr.src_port));
+
+	vsock_insert_connected(vchild);
+	vsock_enqueue_accept(sk, child);
+	virtio_transport_send_response(vchild, pkt);
+
+	release_sock(child);
+
+	sk->sk_data_ready(sk);
+	return 0;
+}
+
+static void virtio_transport_space_update(struct sock *sk,
+					  struct virtio_vsock_pkt *pkt)
+{
+	struct vsock_sock *vsk = vsock_sk(sk);
+	struct virtio_transport *trans = vsk->trans;
+	bool space_available;
+
+	/* buf_alloc and fwd_cnt is always included in the hdr */
+	mutex_lock(&trans->tx_lock);
+	trans->peer_buf_alloc = le32_to_cpu(pkt->hdr.buf_alloc);
+	trans->peer_fwd_cnt = le32_to_cpu(pkt->hdr.fwd_cnt);
+	space_available = virtio_transport_has_space(vsk);
+	mutex_unlock(&trans->tx_lock);
+
+	if (space_available)
+		sk->sk_write_space(sk);
+}
+
+/* We are under the virtio-vsock's vsock->rx_lock or
+ * vhost-vsock's vq->mutex lock */
+void virtio_transport_recv_pkt(struct virtio_vsock_pkt *pkt)
+{
+	struct virtio_transport *trans;
+	struct sockaddr_vm src, dst;
+	struct vsock_sock *vsk;
+	struct sock *sk;
+
+	vsock_addr_init(&src, le32_to_cpu(pkt->hdr.src_cid), le32_to_cpu(pkt->hdr.src_port));
+	vsock_addr_init(&dst, le32_to_cpu(pkt->hdr.dst_cid), le32_to_cpu(pkt->hdr.dst_port));
+
+	virtio_vsock_dumppkt(__func__, pkt);
+
+	if (le16_to_cpu(pkt->hdr.type) != VIRTIO_VSOCK_TYPE_STREAM) {
+		/* TODO send RST */
+		goto free_pkt;
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
+			/* TODO send a RST unless this packet is a RST (to avoid infinite loops) */
+			goto free_pkt;
+		}
+	}
+
+	vsk = vsock_sk(sk);
+	trans = vsk->trans;
+	BUG_ON(!trans);
+
+	virtio_transport_space_update(sk, pkt);
+
+	lock_sock(sk);
+	switch (sk->sk_state) {
+	case VSOCK_SS_LISTEN:
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
+		virtio_transport_free_pkt(pkt);
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
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Asias He");
+MODULE_DESCRIPTION("common code for virtio vsock");
-- 
2.5.0

