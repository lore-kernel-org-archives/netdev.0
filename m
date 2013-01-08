From: George Zhang <georgezhang@vmware.com>
Subject: [PATCH 3/6] VSOCK: notification implementation.
Date: Tue, 08 Jan 2013 15:59:55 -0800
Message-ID: <20130108235948.3719.91790.stgit@promb-2n-dhcp175.eng.vmware.com>
References: <20130108235633.3719.6085.stgit@promb-2n-dhcp175.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	georgezhang@vmware.com, virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130108235633.3719.6085.stgit@promb-2n-dhcp175.eng.vmware.com>
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

VSOCK control notifications for VMCI Stream Sockets protocol.

Signed-off-by: George Zhang <georgezhang@vmware.com>
Acked-by: Andy king <acking@vmware.com>
Acked-by: Dmitry Torokhov <dtor@vmware.com>
---
 net/vmw_vsock/notify.c |  675 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/vmw_vsock/notify.h |  124 +++++++++
 2 files changed, 799 insertions(+), 0 deletions(-)
 create mode 100644 net/vmw_vsock/notify.c
 create mode 100644 net/vmw_vsock/notify.h

diff --git a/net/vmw_vsock/notify.c b/net/vmw_vsock/notify.c
new file mode 100644
index 0000000..23bad8b
--- /dev/null
+++ b/net/vmw_vsock/notify.c
@@ -0,0 +1,675 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2009-2012 VMware, Inc. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation version 2 and no later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/stddef.h>
+#include <net/sock.h>
+
+#include "notify.h"
+#include "af_vsock.h"
+
+#define PKT_FIELD(vsk, field_name) ((vsk)->notify.pkt.field_name)
+
+#define VSOCK_MAX_DGRAM_RESENDS       10
+
+static bool vsock_vmci_notify_waiting_write(struct vsock_vmci_sock *vsk)
+{
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+	bool retval;
+	u64 notify_limit;
+
+	if (!PKT_FIELD(vsk, peer_waiting_write))
+		return false;
+
+#ifdef VSOCK_OPTIMIZATION_FLOW_CONTROL
+	/* When the sender blocks, we take that as a sign that the sender is
+	 * faster than the receiver. To reduce the transmit rate of the sender,
+	 * we delay the sending of the read notification by decreasing the
+	 * write_notify_window. The notification is delayed until the number of
+	 * bytes used in the queue drops below the write_notify_window.
+	 */
+
+	if (!PKT_FIELD(vsk, peer_waiting_write_detected)) {
+		PKT_FIELD(vsk, peer_waiting_write_detected) = true;
+		if (PKT_FIELD(vsk, write_notify_window) < PAGE_SIZE) {
+			PKT_FIELD(vsk, write_notify_window) =
+			    PKT_FIELD(vsk, write_notify_min_window);
+		} else {
+			PKT_FIELD(vsk, write_notify_window) -= PAGE_SIZE;
+			if (PKT_FIELD(vsk, write_notify_window) <
+			    PKT_FIELD(vsk, write_notify_min_window))
+				PKT_FIELD(vsk, write_notify_window) =
+				    PKT_FIELD(vsk, write_notify_min_window);
+
+		}
+	}
+	notify_limit = vsk->consume_size - PKT_FIELD(vsk, write_notify_window);
+#else
+	notify_limit = 0;
+#endif
+
+	/* For now we ignore the wait information and just see if the free
+	 * space exceeds the notify limit.  Note that improving this function
+	 * to be more intelligent will not require a protocol change and will
+	 * retain compatibility between endpoints with mixed versions of this
+	 * function.
+	 *
+	 * The notify_limit is used to delay notifications in the case where
+	 * flow control is enabled. Below the test is expressed in terms of
+	 * free space in the queue: if free_space > ConsumeSize -
+	 * write_notify_window then notify An alternate way of expressing this
+	 * is to rewrite the expression to use the data ready in the receive
+	 * queue: if write_notify_window > bufferReady then notify as
+	 * free_space == ConsumeSize - bufferReady.
+	 */
+	retval = vmci_qpair_consume_free_space(vsk->qpair) > notify_limit;
+#ifdef VSOCK_OPTIMIZATION_FLOW_CONTROL
+	if (retval) {
+		/*
+		 * Once we notify the peer, we reset the detected flag so the
+		 * next wait will again cause a decrease in the window size.
+		 */
+
+		PKT_FIELD(vsk, peer_waiting_write_detected) = false;
+	}
+#endif
+	return retval;
+#else
+	return true;
+#endif
+}
+
+static bool vsock_vmci_notify_waiting_read(struct vsock_vmci_sock *vsk)
+{
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+	if (!PKT_FIELD(vsk, peer_waiting_read))
+		return false;
+
+	/* For now we ignore the wait information and just see if there is any
+	 * data for our peer to read.  Note that improving this function to be
+	 * more intelligent will not require a protocol change and will retain
+	 * compatibility between endpoints with mixed versions of this
+	 * function.
+	 */
+	return vmci_qpair_produce_buf_ready(vsk->qpair) > 0;
+#else
+	return true;
+#endif
+}
+
+static void
+vsock_vmci_handle_waiting_read(struct sock *sk,
+			       struct vsock_packet *pkt,
+			       bool bottom_half,
+			       struct sockaddr_vm *dst,
+			       struct sockaddr_vm *src)
+{
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+	struct vsock_vmci_sock *vsk;
+
+	vsk = vsock_sk(sk);
+
+	PKT_FIELD(vsk, peer_waiting_read) = true;
+	memcpy(&PKT_FIELD(vsk, peer_waiting_read_info), &pkt->u.wait,
+	       sizeof(PKT_FIELD(vsk, peer_waiting_read_info)));
+
+	if (vsock_vmci_notify_waiting_read(vsk)) {
+		bool sent;
+
+		if (bottom_half)
+			sent = VSOCK_SEND_WROTE_BH(dst, src) > 0;
+		else
+			sent = VSOCK_SEND_WROTE(sk) > 0;
+
+		if (sent)
+			PKT_FIELD(vsk, peer_waiting_read) = false;
+
+	}
+#endif
+}
+
+static void
+vsock_vmci_handle_waiting_write(struct sock *sk,
+				struct vsock_packet *pkt,
+				bool bottom_half,
+				struct sockaddr_vm *dst,
+				struct sockaddr_vm *src)
+{
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+	struct vsock_vmci_sock *vsk;
+
+	vsk = vsock_sk(sk);
+
+	PKT_FIELD(vsk, peer_waiting_write) = true;
+	memcpy(&PKT_FIELD(vsk, peer_waiting_write_info), &pkt->u.wait,
+	       sizeof(PKT_FIELD(vsk, peer_waiting_write_info)));
+
+	if (vsock_vmci_notify_waiting_write(vsk)) {
+		bool sent;
+
+		if (bottom_half)
+			sent = VSOCK_SEND_READ_BH(dst, src) > 0;
+		else
+			sent = VSOCK_SEND_READ(sk) > 0;
+
+		if (sent)
+			PKT_FIELD(vsk, peer_waiting_write) = false;
+
+	}
+#endif
+}
+
+static void
+vsock_vmci_handle_read(struct sock *sk,
+		       struct vsock_packet *pkt,
+		       bool bottom_half,
+		       struct sockaddr_vm *dst, struct sockaddr_vm *src)
+{
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+	struct vsock_vmci_sock *vsk;
+
+	vsk = vsock_sk(sk);
+	PKT_FIELD(vsk, sent_waiting_write) = false;
+#endif
+
+	sk->sk_write_space(sk);
+}
+
+static bool vsock_vmci_send_waiting_read(struct sock *sk, u64 room_needed)
+{
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+	struct vsock_vmci_sock *vsk;
+	struct vsock_waiting_info waiting_info;
+	u64 tail;
+	u64 head;
+	u64 room_left;
+	bool ret;
+
+	vsk = vsock_sk(sk);
+
+	if (PKT_FIELD(vsk, sent_waiting_read))
+		return true;
+
+	if (PKT_FIELD(vsk, write_notify_window) < vsk->consume_size)
+		PKT_FIELD(vsk, write_notify_window) =
+		    min(PKT_FIELD(vsk, write_notify_window) + PAGE_SIZE,
+			vsk->consume_size);
+
+	vmci_qpair_get_consume_indexes(vsk->qpair, &tail, &head);
+	room_left = vsk->consume_size - head;
+	if (room_needed >= room_left) {
+		waiting_info.offset = room_needed - room_left;
+		waiting_info.generation =
+		    PKT_FIELD(vsk, consume_q_generation) + 1;
+	} else {
+		waiting_info.offset = head + room_needed;
+		waiting_info.generation = PKT_FIELD(vsk, consume_q_generation);
+	}
+
+	ret = VSOCK_SEND_WAITING_READ(sk, &waiting_info) > 0;
+	if (ret)
+		PKT_FIELD(vsk, sent_waiting_read) = true;
+
+	return ret;
+#else
+	return true;
+#endif
+}
+
+static bool vsock_vmci_send_waiting_write(struct sock *sk, u64 room_needed)
+{
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+	struct vsock_vmci_sock *vsk;
+	struct vsock_waiting_info waiting_info;
+	u64 tail;
+	u64 head;
+	u64 room_left;
+	bool ret;
+
+	vsk = vsock_sk(sk);
+
+	if (PKT_FIELD(vsk, sent_waiting_write))
+		return true;
+
+	vmci_qpair_get_produce_indexes(vsk->qpair, &tail, &head);
+	room_left = vsk->produce_size - tail;
+	if (room_needed + 1 >= room_left) {
+		/* Wraps around to current generation. */
+		waiting_info.offset = room_needed + 1 - room_left;
+		waiting_info.generation = PKT_FIELD(vsk, produce_q_generation);
+	} else {
+		waiting_info.offset = tail + room_needed + 1;
+		waiting_info.generation =
+		    PKT_FIELD(vsk, produce_q_generation) - 1;
+	}
+
+	ret = VSOCK_SEND_WAITING_WRITE(sk, &waiting_info) > 0;
+	if (ret)
+		PKT_FIELD(vsk, sent_waiting_write) = true;
+
+	return ret;
+#else
+	return true;
+#endif
+}
+
+static int vsock_vmci_send_read_notification(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk;
+	bool sent_read;
+	unsigned int retries;
+	int err;
+
+	vsk = vsock_sk(sk);
+	sent_read = false;
+	retries = 0;
+	err = 0;
+
+	if (vsock_vmci_notify_waiting_write(vsk)) {
+		/* Notify the peer that we have read, retrying the send on
+		 * failure up to our maximum value.  XXX For now we just log
+		 * the failure, but later we should schedule a work item to
+		 * handle the resend until it succeeds.  That would require
+		 * keeping track of work items in the vsk and cleaning them up
+		 * upon socket close.
+		 */
+		while (!(vsk->peer_shutdown & RCV_SHUTDOWN) &&
+		       !sent_read && retries < VSOCK_MAX_DGRAM_RESENDS) {
+			err = VSOCK_SEND_READ(sk);
+			if (err >= 0)
+				sent_read = true;
+
+			retries++;
+		}
+
+		if (retries >= VSOCK_MAX_DGRAM_RESENDS)
+			pr_err("%p unable to send read notify to peer\n", sk);
+		else
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+			PKT_FIELD(vsk, peer_waiting_write) = false;
+#endif
+
+	}
+	return err;
+}
+
+static void
+vsock_vmci_handle_wrote(struct sock *sk,
+			struct vsock_packet *pkt,
+			bool bottom_half,
+			struct sockaddr_vm *dst, struct sockaddr_vm *src)
+{
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+	struct vsock_vmci_sock *vsk;
+
+	vsk = vsock_sk(sk);
+	PKT_FIELD(vsk, sent_waiting_read) = false;
+#endif
+
+	sk->sk_data_ready(sk, 0);
+}
+
+static void vsock_vmci_notify_pkt_socket_init(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk;
+	vsk = vsock_sk(sk);
+
+	PKT_FIELD(vsk, write_notify_window) = PAGE_SIZE;
+	PKT_FIELD(vsk, write_notify_min_window) = PAGE_SIZE;
+	PKT_FIELD(vsk, peer_waiting_read) = false;
+	PKT_FIELD(vsk, peer_waiting_write) = false;
+	PKT_FIELD(vsk, peer_waiting_write_detected) = false;
+	PKT_FIELD(vsk, sent_waiting_read) = false;
+	PKT_FIELD(vsk, sent_waiting_write) = false;
+	PKT_FIELD(vsk, produce_q_generation) = 0;
+	PKT_FIELD(vsk, consume_q_generation) = 0;
+
+	memset(&PKT_FIELD(vsk, peer_waiting_read_info), 0,
+	       sizeof(PKT_FIELD(vsk, peer_waiting_read_info)));
+	memset(&PKT_FIELD(vsk, peer_waiting_write_info), 0,
+	       sizeof(PKT_FIELD(vsk, peer_waiting_write_info)));
+}
+
+static void vsock_vmci_notify_pkt_socket_destruct(struct sock *sk)
+{
+	return;
+}
+
+static int
+vsock_vmci_notify_pkt_poll_in(struct sock *sk,
+			      size_t target, bool *data_ready_now)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	if (vsock_vmci_stream_has_data(vsk)) {
+		*data_ready_now = true;
+	} else {
+		/* We can't read right now because there is nothing in the
+		 * queue. Ask for notifications when there is something to
+		 * read.
+		 */
+		if (sk->sk_state == SS_CONNECTED) {
+			if (!vsock_vmci_send_waiting_read(sk, 1))
+				return -1;
+
+		}
+		*data_ready_now = false;
+	}
+
+	return 0;
+}
+
+static int
+vsock_vmci_notify_pkt_poll_out(struct sock *sk,
+			       size_t target, bool *space_avail_now)
+{
+	s64 produce_q_free_space;
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	produce_q_free_space = vsock_vmci_stream_has_space(vsk);
+	if (produce_q_free_space > 0) {
+		*space_avail_now = true;
+		return 0;
+	} else if (produce_q_free_space == 0) {
+		/* This is a connected socket but we can't currently send data.
+		 * Notify the peer that we are waiting if the queue is full. We
+		 * only send a waiting write if the queue is full because
+		 * otherwise we end up in an infinite WAITING_WRITE, READ,
+		 * WAITING_WRITE, READ, etc. loop. Treat failing to send the
+		 * notification as a socket error, passing that back through
+		 * the mask.
+		 */
+		if (!vsock_vmci_send_waiting_write(sk, 1))
+			return -1;
+
+		*space_avail_now = false;
+	}
+
+	return 0;
+}
+
+static int
+vsock_vmci_notify_pkt_recv_init(struct sock *sk,
+				size_t target,
+				struct vsock_vmci_recv_notify_data *data)
+{
+	struct vsock_vmci_sock *vsk;
+
+	vsk = vsock_sk(sk);
+
+#ifdef VSOCK_OPTIMIZATION_WAITING_NOTIFY
+	data->consume_head = 0;
+	data->produce_tail = 0;
+#ifdef VSOCK_OPTIMIZATION_FLOW_CONTROL
+	data->notify_on_block = false;
+
+	if (PKT_FIELD(vsk, write_notify_min_window) < target + 1) {
+		PKT_FIELD(vsk, write_notify_min_window) = target + 1;
+		if (PKT_FIELD(vsk, write_notify_window) <
+		    PKT_FIELD(vsk, write_notify_min_window)) {
+			/* If the current window is smaller than the new
+			 * minimal window size, we need to reevaluate whether
+			 * we need to notify the sender. If the number of ready
+			 * bytes are smaller than the new window, we need to
+			 * send a notification to the sender before we block.
+			 */
+
+			PKT_FIELD(vsk, write_notify_window) =
+			    PKT_FIELD(vsk, write_notify_min_window);
+			data->notify_on_block = true;
+		}
+	}
+#endif
+#endif
+
+	return 0;
+}
+
+static int
+vsock_vmci_notify_pkt_recv_pre_block(struct sock *sk,
+				     size_t target,
+				     struct vsock_vmci_recv_notify_data *data)
+{
+	int err = 0;
+
+	/* Notify our peer that we are waiting for data to read. */
+	if (!vsock_vmci_send_waiting_read(sk, target)) {
+		err = -EHOSTUNREACH;
+		return err;
+	}
+#ifdef VSOCK_OPTIMIZATION_FLOW_CONTROL
+	if (data->notify_on_block) {
+		err = vsock_vmci_send_read_notification(sk);
+		if (err < 0)
+			return err;
+
+		data->notify_on_block = false;
+	}
+#endif
+
+	return err;
+}
+
+static int
+vsock_vmci_notify_pkt_recv_pre_dequeue(struct sock *sk,
+				       size_t target,
+				       struct vsock_vmci_recv_notify_data *data)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	/* Now consume up to len bytes from the queue.  Note that since we have
+	 * the socket locked we should copy at least ready bytes.
+	 */
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+	vmci_qpair_get_consume_indexes(vsk->qpair,
+				       &data->produce_tail,
+				       &data->consume_head);
+#endif
+
+	return 0;
+}
+
+static int
+vsock_vmci_notify_pkt_recv_post_dequeue(struct sock *sk,
+				size_t target,
+				ssize_t copied,
+				bool data_read,
+				struct vsock_vmci_recv_notify_data *data)
+{
+	struct vsock_vmci_sock *vsk;
+	int err;
+
+	vsk = vsock_sk(sk);
+	err = 0;
+
+	if (data_read) {
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+		/* Detect a wrap-around to maintain queue generation.  Note
+		 * that this is safe since we hold the socket lock across the
+		 * two queue pair operations.
+		 */
+		if (copied >= vsk->consume_size - data->consume_head)
+			PKT_FIELD(vsk, consume_q_generation)++;
+
+#endif
+
+		err = vsock_vmci_send_read_notification(sk);
+		if (err < 0)
+			return err;
+
+	}
+	return err;
+}
+
+static int
+vsock_vmci_notify_pkt_send_init(struct sock *sk,
+				struct vsock_vmci_send_notify_data *data)
+{
+#ifdef VSOCK_OPTIMIZATION_WAITING_NOTIFY
+	data->consume_head = 0;
+	data->produce_tail = 0;
+#endif
+
+	return 0;
+}
+
+static int
+vsock_vmci_notify_pkt_send_pre_block(struct sock *sk,
+				     struct vsock_vmci_send_notify_data *data)
+{
+	/* Notify our peer that we are waiting for room to write. */
+	if (!vsock_vmci_send_waiting_write(sk, 1))
+		return -EHOSTUNREACH;
+
+	return 0;
+}
+
+static int
+vsock_vmci_notify_pkt_send_pre_enqueue(struct sock *sk,
+				       struct vsock_vmci_send_notify_data *data)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+	vmci_qpair_get_produce_indexes(vsk->qpair,
+				       &data->produce_tail,
+				       &data->consume_head);
+#endif
+
+	return 0;
+}
+
+static int
+vsock_vmci_notify_pkt_send_post_enqueue(struct sock *sk,
+				ssize_t written,
+				struct vsock_vmci_send_notify_data *data)
+{
+	int err = 0;
+	struct vsock_vmci_sock *vsk;
+	bool sent_wrote = false;
+	int retries = 0;
+
+	vsk = vsock_sk(sk);
+
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+	/* Detect a wrap-around to maintain queue generation.  Note that this
+	 * is safe since we hold the socket lock across the two queue pair
+	 * operations.
+	 */
+	if (written >= vsk->produce_size - data->produce_tail)
+		PKT_FIELD(vsk, produce_q_generation)++;
+
+#endif
+
+	if (vsock_vmci_notify_waiting_read(vsk)) {
+		/* Notify the peer that we have written, retrying the send on
+		 * failure up to our maximum value. See the XXX comment for the
+		 * corresponding piece of code in StreamRecvmsg() for potential
+		 * improvements.
+		 */
+		while (!(vsk->peer_shutdown & RCV_SHUTDOWN) &&
+		       !sent_wrote && retries < VSOCK_MAX_DGRAM_RESENDS) {
+			err = VSOCK_SEND_WROTE(sk);
+			if (err >= 0)
+				sent_wrote = true;
+
+			retries++;
+		}
+
+		if (retries >= VSOCK_MAX_DGRAM_RESENDS) {
+			pr_err("%p unable to send wrote notify to peer\n", sk);
+			return err;
+		} else {
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+			PKT_FIELD(vsk, peer_waiting_read) = false;
+#endif
+		}
+	}
+	return err;
+}
+
+static void
+vsock_vmci_notify_pkt_handle_pkt(struct sock *sk,
+				 struct vsock_packet *pkt,
+				 bool bottom_half,
+				 struct sockaddr_vm *dst,
+				 struct sockaddr_vm *src, bool *pkt_processed)
+{
+	bool processed = false;
+
+	switch (pkt->type) {
+	case VSOCK_PACKET_TYPE_WROTE:
+		vsock_vmci_handle_wrote(sk, pkt, bottom_half, dst, src);
+		processed = true;
+		break;
+	case VSOCK_PACKET_TYPE_READ:
+		vsock_vmci_handle_read(sk, pkt, bottom_half, dst, src);
+		processed = true;
+		break;
+	case VSOCK_PACKET_TYPE_WAITING_WRITE:
+		vsock_vmci_handle_waiting_write(sk, pkt, bottom_half, dst, src);
+		processed = true;
+		break;
+
+	case VSOCK_PACKET_TYPE_WAITING_READ:
+		vsock_vmci_handle_waiting_read(sk, pkt, bottom_half, dst, src);
+		processed = true;
+		break;
+	}
+
+	if (pkt_processed)
+		*pkt_processed = processed;
+
+}
+
+static void vsock_vmci_notify_pkt_process_request(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	PKT_FIELD(vsk, write_notify_window) = vsk->consume_size;
+	if (vsk->consume_size < PKT_FIELD(vsk, write_notify_min_window))
+		PKT_FIELD(vsk, write_notify_min_window) = vsk->consume_size;
+
+}
+
+static void vsock_vmci_notify_pkt_process_negotiate(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	PKT_FIELD(vsk, write_notify_window) = vsk->consume_size;
+	if (vsk->consume_size < PKT_FIELD(vsk, write_notify_min_window))
+		PKT_FIELD(vsk, write_notify_min_window) = vsk->consume_size;
+
+}
+
+/* Socket control packet based operations. */
+struct vsock_vmci_notify_ops vsock_vmci_notify_pkt_ops = {
+	vsock_vmci_notify_pkt_socket_init,
+	vsock_vmci_notify_pkt_socket_destruct,
+	vsock_vmci_notify_pkt_poll_in,
+	vsock_vmci_notify_pkt_poll_out,
+	vsock_vmci_notify_pkt_handle_pkt,
+	vsock_vmci_notify_pkt_recv_init,
+	vsock_vmci_notify_pkt_recv_pre_block,
+	vsock_vmci_notify_pkt_recv_pre_dequeue,
+	vsock_vmci_notify_pkt_recv_post_dequeue,
+	vsock_vmci_notify_pkt_send_init,
+	vsock_vmci_notify_pkt_send_pre_block,
+	vsock_vmci_notify_pkt_send_pre_enqueue,
+	vsock_vmci_notify_pkt_send_post_enqueue,
+	vsock_vmci_notify_pkt_process_request,
+	vsock_vmci_notify_pkt_process_negotiate,
+};
diff --git a/net/vmw_vsock/notify.h b/net/vmw_vsock/notify.h
new file mode 100644
index 0000000..dc52217
--- /dev/null
+++ b/net/vmw_vsock/notify.h
@@ -0,0 +1,124 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2009-2012 VMware, Inc. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation version 2 and no later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#ifndef __NOTIFY_H__
+#define __NOTIFY_H__
+
+#include <linux/types.h>
+
+#include "vsock_common.h"
+#include "vsock_packet.h"
+
+/* Comment this out to compare with old protocol. */
+#define VSOCK_OPTIMIZATION_WAITING_NOTIFY 1
+#if defined(VSOCK_OPTIMIZATION_WAITING_NOTIFY)
+/* Comment this out to remove flow control for "new" protocol */
+#define VSOCK_OPTIMIZATION_FLOW_CONTROL 1
+#endif
+
+#define VSOCK_MAX_DGRAM_RESENDS       10
+
+#define NOTIFYCALLRET(vsk, rv, mod_fn, args...)			\
+	do {							\
+		if (vsk->notify_ops &&				\
+		    vsk->notify_ops->mod_fn != NULL)		\
+			rv = (vsk->notify_ops->mod_fn)(args);	\
+		else						\
+			rv = 0;					\
+								\
+	} while (0)
+
+#define NOTIFYCALL(vsk, mod_fn, args...)			\
+	do {							\
+		if (vsk->notify_ops &&				\
+		    vsk->notify_ops->mod_fn != NULL)		\
+			(vsk->notify_ops->mod_fn)(args);	\
+								\
+	} while (0)
+
+struct vsock_vmci_notify_pkt {
+	u64 write_notify_window;
+	u64 write_notify_min_window;
+	bool peer_waiting_read;
+	bool peer_waiting_write;
+	bool peer_waiting_write_detected;
+	bool sent_waiting_read;
+	bool sent_waiting_write;
+	struct vsock_waiting_info peer_waiting_read_info;
+	struct vsock_waiting_info peer_waiting_write_info;
+	u64 produce_q_generation;
+	u64 consume_q_generation;
+};
+
+struct vsock_vmci_notify_pkt_q_state {
+	u64 write_notify_window;
+	u64 write_notify_min_window;
+	bool peer_waiting_write;
+	bool peer_waiting_write_detected;
+};
+
+union vsock_vmci_notify {
+	struct vsock_vmci_notify_pkt pkt;
+	struct vsock_vmci_notify_pkt_q_state pkt_q_state;
+};
+
+struct vsock_vmci_recv_notify_data {
+	u64 consume_head;
+	u64 produce_tail;
+	bool notify_on_block;
+};
+
+struct vsock_vmci_send_notify_data {
+	u64 consume_head;
+	u64 produce_tail;
+};
+
+/* Socket notification callbacks. */
+struct vsock_vmci_notify_ops {
+	void (*socket_init) (struct sock *sk);
+	void (*socket_destruct) (struct sock *sk);
+	int (*poll_in) (struct sock *sk, size_t target,
+			  bool *data_ready_now);
+	int (*poll_out) (struct sock *sk, size_t target,
+			   bool *space_avail_now);
+	void (*handle_notify_pkt) (struct sock *sk, struct vsock_packet *pkt,
+				   bool bottom_half, struct sockaddr_vm *dst,
+				   struct sockaddr_vm *src,
+				   bool *pkt_processed);
+	int (*recv_init) (struct sock *sk, size_t target,
+			  struct vsock_vmci_recv_notify_data *data);
+	int (*recv_pre_block) (struct sock *sk, size_t target,
+			       struct vsock_vmci_recv_notify_data *data);
+	int (*recv_pre_dequeue) (struct sock *sk, size_t target,
+				 struct vsock_vmci_recv_notify_data *data);
+	int (*recv_post_dequeue) (struct sock *sk, size_t target,
+				  ssize_t copied, bool data_read,
+				  struct vsock_vmci_recv_notify_data *data);
+	int (*send_init) (struct sock *sk,
+			  struct vsock_vmci_send_notify_data *data);
+	int (*send_pre_block) (struct sock *sk,
+			       struct vsock_vmci_send_notify_data *data);
+	int (*send_pre_enqueue) (struct sock *sk,
+				 struct vsock_vmci_send_notify_data *data);
+	int (*send_post_enqueue) (struct sock *sk, ssize_t written,
+				  struct vsock_vmci_send_notify_data *data);
+	void (*process_request) (struct sock *sk);
+	void (*process_negotiate) (struct sock *sk);
+};
+
+extern struct vsock_vmci_notify_ops vsock_vmci_notify_pkt_ops;
+extern struct vsock_vmci_notify_ops vsock_vmci_notify_pkt_q_state_ops;
+
+#endif /* __NOTIFY_H__ */
