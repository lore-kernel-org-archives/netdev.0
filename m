From: George Zhang <georgezhang@vmware.com>
Subject: [PATCH 6/6] VSOCK: header and config files.
Date: Wed, 21 Nov 2012 12:40:51 -0800
Message-ID: <20121121204041.14395.23929.stgit@promb-2n-dhcp175.eng.vmware.com>
References: <20121121203715.14395.27632.stgit@promb-2n-dhcp175.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	georgezhang@vmware.com, virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121121203715.14395.27632.stgit@promb-2n-dhcp175.eng.vmware.com>
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

VSOCK header files, Makefiles and Kconfig systems for Linux VSocket module.

Signed-off-by: George Zhang <georgezhang@vmware.com>
Signed-off-by: Dmitry Torokhov <dtor@vmware.com>
Signed-off-by: Andy King <acking@vmware.com>

---
 include/linux/socket.h              |    4 
 net/Kconfig                         |    1 
 net/Makefile                        |    1 
 net/vmw_vsock/Kconfig               |   14 +
 net/vmw_vsock/Makefile              |    4 
 net/vmw_vsock/notify_qstate.c       |  625 +++++++++++++++++++++++++++++++++++
 net/vmw_vsock/vmci_sockets.h        |  517 +++++++++++++++++++++++++++++
 net/vmw_vsock/vmci_sockets_packet.h |   90 +++++
 net/vmw_vsock/vsock_common.h        |  127 +++++++
 net/vmw_vsock/vsock_packet.h        |  124 +++++++
 net/vmw_vsock/vsock_version.h       |   28 ++
 11 files changed, 1534 insertions(+), 1 deletions(-)
 create mode 100644 net/vmw_vsock/Kconfig
 create mode 100644 net/vmw_vsock/Makefile
 create mode 100644 net/vmw_vsock/notify_qstate.c
 create mode 100644 net/vmw_vsock/vmci_sockets.h
 create mode 100644 net/vmw_vsock/vmci_sockets_packet.h
 create mode 100644 net/vmw_vsock/vsock_common.h
 create mode 100644 net/vmw_vsock/vsock_packet.h
 create mode 100644 net/vmw_vsock/vsock_version.h

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 25d6322..57bc85e 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -195,7 +195,8 @@ struct ucred {
 #define AF_CAIF		37	/* CAIF sockets			*/
 #define AF_ALG		38	/* Algorithm sockets		*/
 #define AF_NFC		39	/* NFC sockets			*/
-#define AF_MAX		40	/* For now.. */
+#define AF_VSOCK	40	/* VMCI sockets			*/
+#define AF_MAX		41	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -238,6 +239,7 @@ struct ucred {
 #define PF_CAIF		AF_CAIF
 #define PF_ALG		AF_ALG
 #define PF_NFC		AF_NFC
+#define PF_VSOCK	AF_VSOCK
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/net/Kconfig b/net/Kconfig
index 245831b..75b8d5e 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -216,6 +216,7 @@ source "net/dcb/Kconfig"
 source "net/dns_resolver/Kconfig"
 source "net/batman-adv/Kconfig"
 source "net/openvswitch/Kconfig"
+source "net/vmw_vsock/Kconfig"
 
 config RPS
 	boolean
diff --git a/net/Makefile b/net/Makefile
index 4f4ee08..cae59f4 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -70,3 +70,4 @@ obj-$(CONFIG_CEPH_LIB)		+= ceph/
 obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
 obj-$(CONFIG_NFC)		+= nfc/
 obj-$(CONFIG_OPENVSWITCH)	+= openvswitch/
+obj-$(CONFIG_VMWARE_VSOCK)	+= vmw_vsock/
diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
new file mode 100644
index 0000000..95e2568
--- /dev/null
+++ b/net/vmw_vsock/Kconfig
@@ -0,0 +1,14 @@
+#
+# Vsock protocol
+#
+
+config VMWARE_VSOCK
+	tristate "Virtual Socket protocol"
+	depends on VMWARE_VMCI
+	help
+	  Virtual Socket Protocol is a socket protocol similar to TCP/IP
+	  allowing comunication between Virtual Machines and VMware
+	  hypervisor.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called vsock. If unsure, say N.
diff --git a/net/vmw_vsock/Makefile b/net/vmw_vsock/Makefile
new file mode 100644
index 0000000..4e940fe
--- /dev/null
+++ b/net/vmw_vsock/Makefile
@@ -0,0 +1,4 @@
+obj-$(CONFIG_VMWARE_VSOCK) += vmw_vsock.o
+
+vmw_vsock-y += af_vsock.o notify.o notify_qstate.o stats.o util.o \
+	vsock_addr.o
diff --git a/net/vmw_vsock/notify_qstate.c b/net/vmw_vsock/notify_qstate.c
new file mode 100644
index 0000000..5a2f066
--- /dev/null
+++ b/net/vmw_vsock/notify_qstate.c
@@ -0,0 +1,625 @@
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
+/*
+ * notifyQState.c --
+ *
+ * Linux control notifications based on Queuepair state for the VMCI Stream
+ * Sockets protocol.
+ */
+
+#include <linux/types.h>
+
+#include <linux/socket.h>
+
+#include <linux/stddef.h>	/* for NULL */
+#include <net/sock.h>
+
+#include "notify.h"
+#include "af_vsock.h"
+
+#define PKT_FIELD(vsk, field_name) ((vsk)->notify.pkt_q_state.field_name)
+
+/*
+ *
+ * vsock_vmci_notify_waiting_write --
+ *
+ * Determines if the conditions have been met to notify a waiting writer.
+ *
+ * Results: true if a notification should be sent, false otherwise.
+ *
+ * Side effects: None.
+ */
+
+static bool vsock_vmci_notify_waiting_write(struct vsock_vmci_sock *vsk)
+{
+	bool retval;
+	u64 notify_limit;
+
+	if (!PKT_FIELD(vsk, peer_waiting_write))
+		return false;
+
+	/*
+	 * When the sender blocks, we take that as a sign that the sender is
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
+
+	/*
+	 * The notify_limit is used to delay notifications in the case where
+	 * flow control is enabled. Below the test is expressed in terms of
+	 * free space in the queue: if free_space > ConsumeSize -
+	 * write_notify_window then notify An alternate way of expressing this
+	 * is to rewrite the expression to use the data ready in the receive
+	 * queue: if write_notify_window > bufferReady then notify as
+	 * free_space == ConsumeSize - bufferReady.
+	 */
+
+	retval = vmci_qpair_consume_free_space(vsk->qpair) > notify_limit;
+
+	if (retval) {
+		/*
+		 * Once we notify the peer, we reset the detected flag so the
+		 * next wait will again cause a decrease in the window size.
+		 */
+
+		PKT_FIELD(vsk, peer_waiting_write_detected) = false;
+	}
+	return retval;
+}
+
+/*
+ *
+ * vsock_vmci_handle_read --
+ *
+ * Handles an incoming read message.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
+
+static void
+vsock_vmci_handle_read(struct sock *sk,
+		       struct vsock_packet *pkt,
+		       bool bottom_half,
+		       struct sockaddr_vm *dst, struct sockaddr_vm *src)
+{
+
+	sk->sk_write_space(sk);
+}
+
+/*
+ *
+ * vsock_vmci_handle_wrote --
+ *
+ * Handles an incoming wrote message.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
+
+static void
+vsock_vmci_handle_wrote(struct sock *sk,
+			struct vsock_packet *pkt,
+			bool bottom_half,
+			struct sockaddr_vm *dst, struct sockaddr_vm *src)
+{
+	sk->sk_data_ready(sk, 0);
+}
+
+/*
+ *
+ * vsock_vmci_block_update_write_window --
+ *
+ * Updates the write window when we are blocking for data.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
+
+static void vsock_vmci_block_update_write_window(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk;
+
+	vsk = vsock_sk(sk);
+
+	if (PKT_FIELD(vsk, write_notify_window) < vsk->consume_size)
+		PKT_FIELD(vsk, write_notify_window) =
+		    min(PKT_FIELD(vsk, write_notify_window) + PAGE_SIZE,
+			vsk->consume_size);
+
+}
+
+/*
+ *
+ * vsock_vmci_send_read_notification --
+ *
+ * Sends a read notification to this socket's peer.
+ *
+ * Results: >= 0 if the datagram is sent successfully, negative error value
+ * otherwise.
+ *
+ * Side effects: None.
+ */
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
+		/*
+		 * Notify the peer that we have read, retrying the send on
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
+		if (retries >= VSOCK_MAX_DGRAM_RESENDS && !sent_read)
+			printk
+			    ("%p unable to send read notification to peer.\n",
+			     sk);
+		else
+			PKT_FIELD(vsk, peer_waiting_write) = false;
+
+	}
+	return err;
+}
+
+/*
+ *
+ * vsock_vmci_notify_pkt_socket_init --
+ *
+ * Function that is called after a socket is created and before any notify ops
+ * are used.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
+
+static void vsock_vmci_notify_pkt_socket_init(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk;
+	vsk = vsock_sk(sk);
+
+	PKT_FIELD(vsk, write_notify_window) = PAGE_SIZE;
+	PKT_FIELD(vsk, write_notify_min_window) = PAGE_SIZE;
+	PKT_FIELD(vsk, peer_waiting_write) = false;
+	PKT_FIELD(vsk, peer_waiting_write_detected) = false;
+}
+
+/*
+ *
+ * vsock_vmci_notify_pkt_socket_destruct --
+ *
+ * Function that is called when the socket is being released.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
+
+static void vsock_vmci_notify_pkt_socket_destruct(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk;
+	vsk = vsock_sk(sk);
+
+	PKT_FIELD(vsk, write_notify_window) = PAGE_SIZE;
+	PKT_FIELD(vsk, write_notify_min_window) = PAGE_SIZE;
+	PKT_FIELD(vsk, peer_waiting_write) = false;
+	PKT_FIELD(vsk, peer_waiting_write_detected) = false;
+}
+
+/*
+ *
+ * vsock_vmci_notify_pkt_poll_in --
+ *
+ * Called by the poll function to figure out if there is data to read and to
+ * setup future notifications if needed. Only called on sockets that aren't
+ * shutdown for recv.
+ *
+ * Results: 0 on success. Negative error on failure.
+ *
+ * Side effects: None.
+ */
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
+		/*
+		 * We can't read right now because there is nothing in the
+		 * queue. Ask for notifications when there is something to
+		 * read.
+		 */
+		if (sk->sk_state == SS_CONNECTED)
+			vsock_vmci_block_update_write_window(sk);
+
+		*data_ready_now = false;
+	}
+
+	return 0;
+}
+
+/*
+ *
+ * vsock_vmci_notify_pkt_poll_out
+ *
+ * Called by the poll function to figure out if there is space to write and to
+ * setup future notifications if needed. Only called on a connected socket that
+ * isn't shutdown for send.
+ *
+ * Results: 0 on success. Negative error on failure.
+ *
+ * Side effects: None.
+ */
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
+		/*
+		 * This is a connected socket but we can't currently send data.
+		 * Nothing else to do.
+		 */
+		*space_avail_now = false;
+	}
+
+	return 0;
+}
+
+/*
+ *
+ * vsock_vmci_notify_pkt_recv_init --
+ *
+ * Called at the start of a stream recv call with the socket lock held.
+ *
+ * Results: 0 on success. Negative error on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_notify_pkt_recv_init(struct sock *sk,
+				size_t target,
+				struct vsock_vmci_recv_notify_data *data)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	data->consume_head = 0;
+	data->produce_tail = 0;
+	data->notify_on_block = false;
+
+	if (PKT_FIELD(vsk, write_notify_min_window) < target + 1) {
+		PKT_FIELD(vsk, write_notify_min_window) = target + 1;
+		if (PKT_FIELD(vsk, write_notify_window) <
+		    PKT_FIELD(vsk, write_notify_min_window)) {
+			/*
+			 * If the current window is smaller than the new
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
+
+	return 0;
+}
+
+/*
+ *
+ * vsock_vmci_notify_pkt_recv_pre_block --
+ *
+ * Called right before a socket is about to block with the socket lock held.
+ * The socket lock may have been released between the entry function and the
+ * preblock call.
+ *
+ * Note: This function may be called multiple times before the post block
+ * function is called.
+ *
+ * Results: 0 on success. Negative error on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_notify_pkt_recv_pre_block(struct sock *sk,
+				     size_t target,
+				     struct vsock_vmci_recv_notify_data *data)
+{
+	int err = 0;
+
+	vsock_vmci_block_update_write_window(sk);
+
+	if (data->notify_on_block) {
+		err = vsock_vmci_send_read_notification(sk);
+		if (err < 0)
+			return err;
+
+		data->notify_on_block = false;
+	}
+
+	return err;
+}
+
+/*
+ *
+ * vsock_vmci_notify_pkt_recv_post_dequeue --
+ *
+ * Called right after we dequeue / peek data from a socket.
+ *
+ * Results: 0 on success. Negative error on failure.
+ *
+ * Side effects: None.
+ */
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
+	bool was_full = false;
+	u64 free_space;
+
+	vsk = vsock_sk(sk);
+	err = 0;
+
+	if (data_read) {
+		smp_mb();
+
+		free_space = vmci_qpair_consume_free_space(vsk->qpair);
+		was_full = free_space == copied;
+
+		if (was_full)
+			PKT_FIELD(vsk, peer_waiting_write) = true;
+
+		err = vsock_vmci_send_read_notification(sk);
+		if (err < 0)
+			return err;
+
+		/* See the comment in vsock_vmci_notify_pkt_send_post_enqueue */
+		sk->sk_data_ready(sk, 0);
+	}
+
+	return err;
+}
+
+/*
+ *
+ * vsock_vmci_notify_pkt_send_init --
+ *
+ * Called at the start of a stream send call with the socket lock held.
+ *
+ * Results: 0 on success. A negative error code on failure.
+ *
+ * Side effects:
+ */
+
+static int
+vsock_vmci_notify_pkt_send_init(struct sock *sk,
+				struct vsock_vmci_send_notify_data *data)
+{
+	data->consume_head = 0;
+	data->produce_tail = 0;
+
+	return 0;
+}
+
+/*
+ *
+ * vsock_vmci_notifySendPostEnqueue --
+ *
+ * Called right after we enqueue data to a socket.
+ *
+ * Results: 0 on success. Negative error on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_notify_pkt_send_post_enqueue(struct sock *sk,
+				ssize_t written,
+				struct vsock_vmci_send_notify_data *data)
+{
+	int err = 0;
+	struct vsock_vmci_sock *vsk;
+	bool sent_wrote = false;
+	bool was_empty;
+	int retries = 0;
+
+	vsk = vsock_sk(sk);
+
+	smp_mb();
+
+	was_empty = (vmci_qpair_produce_buf_ready(vsk->qpair) == written);
+	if (was_empty) {
+		while (!(vsk->peer_shutdown & RCV_SHUTDOWN) &&
+		       !sent_wrote && retries < VSOCK_MAX_DGRAM_RESENDS) {
+			err = VSOCK_SEND_WROTE(sk);
+			if (err >= 0)
+				sent_wrote = true;
+
+			retries++;
+		}
+	}
+
+	if (retries >= VSOCK_MAX_DGRAM_RESENDS && !sent_wrote) {
+		printk
+		    ("%p unable to send wrote notification to peer.\n",
+		     sk);
+		return err;
+	}
+
+	return err;
+}
+
+/*
+ *
+ * vsock_vmci_notify_pkt_handle_pkt
+ *
+ * Called when a notify packet is recieved for a socket in the connected state.
+ * Note this might be called from a bottom half.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
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
+	}
+
+	if (pkt_processed)
+		*pkt_processed = processed;
+
+}
+
+/*
+ *
+ * vsock_vmci_notify_pkt_process_request
+ *
+ * Called near the end of process request.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
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
+/*
+ *
+ * vsock_vmci_notify_pkt_process_negotiate
+ *
+ * Called near the end of process negotiate.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
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
+/* Socket always on control packet based operations. */
+struct vsock_vmci_notify_ops vsock_vmci_notify_pkt_q_state_ops = {
+	vsock_vmci_notify_pkt_socket_init,
+	vsock_vmci_notify_pkt_socket_destruct,
+	vsock_vmci_notify_pkt_poll_in,
+	vsock_vmci_notify_pkt_poll_out,
+	vsock_vmci_notify_pkt_handle_pkt,
+	vsock_vmci_notify_pkt_recv_init,
+	vsock_vmci_notify_pkt_recv_pre_block,
+	NULL,			/* recv_pre_dequeue */
+	vsock_vmci_notify_pkt_recv_post_dequeue,
+	vsock_vmci_notify_pkt_send_init,
+	NULL,			/* send_pre_block */
+	NULL,			/* send_pre_enqueue */
+	vsock_vmci_notify_pkt_send_post_enqueue,
+	vsock_vmci_notify_pkt_process_request,
+	vsock_vmci_notify_pkt_process_negotiate,
+};
diff --git a/net/vmw_vsock/vmci_sockets.h b/net/vmw_vsock/vmci_sockets.h
new file mode 100644
index 0000000..6e6fd98
--- /dev/null
+++ b/net/vmw_vsock/vmci_sockets.h
@@ -0,0 +1,517 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2007-2012 VMware, Inc. All rights reserved.
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
+/*
+ * vmci_sockets.h --
+ *
+ * VMCI sockets public constants and types.
+ */
+
+#ifndef _VMCI_SOCKETS_H_
+#define _VMCI_SOCKETS_H_
+
+#if !defined(__KERNEL__)
+#include <sys/socket.h>
+#endif
+
+/*
+ * \brief Option name for STREAM socket buffer size.
+ *
+ * Use as the option name in \c setsockopt(3) or \c getsockopt(3) to set or get
+ * an \c unsigned \c long \c long that specifies the size of the buffer
+ * underlying a vSockets STREAM socket.
+ *
+ * \note Value is clamped to the MIN and MAX.
+ *
+ * \see vmci_sock_get_af_value_fd() \see SO_VMCI_BUFFER_MIN_SIZE \see
+ * SO_VMCI_BUFFER_MAX_SIZE
+ *
+ * An example is given below.
+ *
+ * \code int vmciFd; int af = vmci_sock_get_af_value_fd(&vmciFd); unsigned long
+ * long val = 0x1000; int fd = socket(af, SOCK_STREAM, 0); setsockopt(fd, af,
+ * SO_VMCI_BUFFER_SIZE, &val, sizeof val); ... close(fd);
+ * vmci_sock_release_af_value_fd(vmciFd); \endcode
+ */
+
+#define SO_VMCI_BUFFER_SIZE                 0
+
+/*
+ * \brief Option name for STREAM socket minimum buffer size.
+ *
+ * Use as the option name in \c setsockopt(3) or \c getsockopt(3) to set or get
+ * an \c unsigned \c long \c long that specifies the minimum size allowed for
+ * the buffer underlying a vSockets STREAM socket.
+ *
+ * \see vmci_sock_get_af_value_fd() \see SO_VMCI_BUFFER_SIZE \see
+ * SO_VMCI_BUFFER_MAX_SIZE
+ *
+ * An example is given below.
+ *
+ * \code int vmciFd; int af = vmci_sock_get_af_value_fd(&vmciFd); unsigned long
+ * long val = 0x500; int fd = socket(af, SOCK_STREAM, 0); setsockopt(fd, af,
+ * SO_VMCI_BUFFER_MIN_SIZE, &val, sizeof val); ... close(fd);
+ * vmci_sock_release_af_value_fd(vmciFd); \endcode
+ */
+
+#define SO_VMCI_BUFFER_MIN_SIZE             1
+
+/*
+ * \brief Option name for STREAM socket maximum buffer size.
+ *
+ * Use as the option name in \c setsockopt(3) or \c getsockopt(3) to set or get
+ * an unsigned long long that specifies the maximum size allowed for the buffer
+ * underlying a vSockets STREAM socket.
+ *
+ * \see vmci_sock_get_af_value_fd() \see SO_VMCI_BUFFER_SIZE \see
+ * SO_VMCI_BUFFER_MIN_SIZE
+ *
+ * An example is given below.
+ *
+ * \code int vmciFd; int af = vmci_sock_get_af_value_fd(&vmciFd); unsigned long
+ * long val = 0x4000; int fd = socket(af, SOCK_STREAM, 0); setsockopt(fd, af,
+ * SO_VMCI_BUFFER_MAX_SIZE, &val, sizeof val); ... close(fd);
+ * vmci_sock_release_af_value_fd(vmciFd); \endcode
+ */
+
+#define SO_VMCI_BUFFER_MAX_SIZE             2
+
+/*
+ * \brief Option name for socket peer's host-specific VM ID.
+ *
+ * Use as the option name in \c getsockopt(3) to get a host-specific identifier
+ * for the peer endpoint's VM.  The identifier is a signed integer.
+ *
+ * \note Only available for ESX (VMKernel/userworld) endpoints.
+ *
+ * An example is given below.
+ *
+ * \code int vmciFd; int af = vmci_sock_get_af_value_fd(&vmciFd); int id;
+ * socklen_t len = sizeof id; int fd = socket(af, SOCK_DGRAM, 0); getsockopt(fd,
+ * af, SO_VMCI_PEER_HOST_VM_ID, &id, &len); ... close(fd);
+ * vmci_sock_release_af_value_fd(vmciFd); \endcode
+ */
+
+#define SO_VMCI_PEER_HOST_VM_ID             3
+
+/*
+ * \brief Option name for socket's service label.
+ *
+ * Use as the option name in \c setsockopt(3) or \c getsockopt(3) to set or get
+ * the service label for a socket.  The service label is a C-style
+ * NUL-terminated string.
+ *
+ * \note Only available for ESX (VMkernel/userworld) endpoints.
+ */
+
+#define SO_VMCI_SERVICE_LABEL               4
+
+/*
+ * \brief Option name for determining if a socket is trusted.
+ *
+ * Use as the option name in \c getsockopt(3) to determine if a socket is
+ * trusted.  The value is a signed integer.
+ *
+ * An example is given below.
+ *
+ * \code int vmciFd; int af = vmci_sock_get_af_value_fd(&vmciFd); int trusted;
+ * socklen_t len = sizeof trusted; int fd = socket(af, SOCK_DGRAM, 0);
+ * getsockopt(fd, af, SO_VMCI_TRUSTED, &trusted, &len); ... close(fd);
+ * vmci_sock_release_af_value_fd(vmciFd); \endcode
+ */
+
+#define SO_VMCI_TRUSTED                     5
+
+/*
+ * \brief Option name for STREAM socket connection timeout.
+ *
+ * Use as the option name in \c setsockopt(3) or \c getsockopt(3) to set or get
+ * the connection timeout for a STREAM socket.  The value is platform
+ * dependent.  On ESX, Linux and Mac OS, it is a \c struct \c timeval. On
+ * Windows, it is a \c DWORD.
+ *
+ * An example is given below.
+ *
+ * \code int vmciFd; int af = vmci_sock_get_af_value_fd(&vmciFd); struct
+ * timeval t = { 5, 100000 }; int fd = socket(af, SOCK_STREAM, 0);
+ * setsockopt(fd, af, SO_VMCI_CONNECT_TIMEOUT, &t, sizeof t); ... close(fd);
+ * vmci_sock_release_af_value_fd(vmciFd); \endcode
+ */
+
+#define SO_VMCI_CONNECT_TIMEOUT             6
+
+/*
+ * \brief Option name for using non-blocking send/receive.
+ *
+ * Use as the option name for \c setsockopt(3) or \c getsockopt(3) to set or
+ * get the non-blocking transmit/receive flag for a STREAM socket.  This flag
+ * determines whether \c send() and \c recv() can be called in non-blocking
+ * contexts for the given socket.  The value is a signed integer.
+ *
+ * This option is only relevant to kernel endpoints, where descheduling the
+ * thread of execution is not allowed, for example, while holding a spinlock.
+ * It is not to be confused with conventional non-blocking socket operations.
+ *
+ * \note Only available for VMKernel endpoints.
+ *
+ * An example is given below.
+ *
+ * \code int vmciFd; int af = vmci_sock_get_af_value_fd(&vmciFd); int nonblock;
+ * socklen_t len = sizeof nonblock; int fd = socket(af, SOCK_STREAM, 0);
+ * getsockopt(fd, af, SO_VMCI_NONBLOCK_TXRX, &nonblock, &len); ... close(fd);
+ * vmci_sock_release_af_value_fd(vmciFd); \endcode
+ */
+
+#define SO_VMCI_NONBLOCK_TXRX               7
+
+/*
+ * \brief The vSocket equivalent of INADDR_ANY.
+ *
+ * This works for the \c svm_cid field of sockaddr_vm and indicates the context
+ * ID of the current endpoint.
+ *
+ * \see sockaddr_vm
+ *
+ * An example is given below.
+ *
+ * \code int vmciFd; int af = vmci_sock_get_af_value_fd(&vmciFd); struct
+ * sockaddr_vm addr; int fd = socket(af, SOCK_DGRAM, 0); addr.svm_family = af;
+ * addr.svm_cid = VMADDR_CID_ANY; addr.svm_port = 2000; bind(fd, &addr, sizeof
+ * addr); ... close(fd); vmci_sock_release_af_value_fd(vmciFd); \endcode
+ */
+
+#define VMADDR_CID_ANY  ((unsigned int)-1)
+
+/*
+ * \brief Bind to any available port.
+ *
+ * Works for the \c svm_port field of sockaddr_vm.
+ *
+ * \see sockaddr_vm
+ *
+ * An example is given below.
+ *
+ * \code int vmciFd; int af = vmci_sock_get_af_value_fd(&vmciFd); struct
+ * sockaddr_vm addr; int fd = socket(af, SOCK_DGRAM, 0); addr.svm_family = af;
+ * addr.svm_cid = VMADDR_CID_ANY; addr.svm_port = VMADDR_PORT_ANY; bind(fd,
+ * &addr, sizeof addr); ... close(fd); vmci_sock_release_af_value_fd(vmciFd);
+ * \endcode
+ */
+
+#define VMADDR_PORT_ANY ((unsigned int)-1)
+
+/*
+ * \brief Invalid vSockets version.
+ *
+ * \see VMCISock_Version()
+ */
+
+#define VMCI_SOCKETS_INVALID_VERSION ((unsigned int)-1)
+
+/*
+ * \brief The epoch (first) component of the vSockets version.
+ *
+ * A single byte representing the epoch component of the vSockets version.
+ *
+ * \see VMCISock_Version()
+ *
+ * An example is given below.
+ *
+ * \code unsigned int ver = VMCISock_Version(); unsigned char epoch =
+ * VMCI_SOCKETS_VERSION_EPOCH(ver); \endcode
+ */
+
+#define VMCI_SOCKETS_VERSION_EPOCH(_v) (((_v) & 0xFF000000) >> 24)
+
+/*
+ * \brief The major (second) component of the vSockets version.
+ *
+ * A single byte representing the major component of the vSockets version.
+ * Typically changes for every major release of a product.
+ *
+ * \see VMCISock_Version()
+ *
+ * An example is given below.
+ *
+ * \code unsigned int ver = VMCISock_Version(); unsigned char major =
+ * VMCI_SOCKETS_VERSION_MAJOR(ver); \endcode
+ */
+
+#define VMCI_SOCKETS_VERSION_MAJOR(_v) (((_v) & 0x00FF0000) >> 16)
+
+/*
+ * \brief The minor (third) component of the vSockets version.
+ *
+ * Two bytes representing the minor component of the vSockets version.
+ *
+ * \see VMCISock_Version()
+ *
+ * An example is given below.
+ *
+ * \code unsigned int ver = VMCISock_Version(); unsigned short minor =
+ * VMCI_SOCKETS_VERSION_MINOR(ver); \endcode
+ */
+
+#define VMCI_SOCKETS_VERSION_MINOR(_v) (((_v) & 0x0000FFFF))
+
+/** \cond PRIVATE */
+
+/** \endcond */
+
+/*
+ * \brief Address structure for vSockets.
+ *
+ * The address family should be set to whatever vmci_sock_get_af_value_fd()
+ * returns.  The structure members should all align on their natural boundaries
+ * without resorting to compiler packing directives.  The total size of this
+ * structure should be exactly the same as that of \c struct \c sockaddr.
+ *
+ * \see vmci_sock_get_af_value_fd()
+ */
+
+struct sockaddr_vm {
+
+   /** \brief Address family. \see vmci_sock_get_af_value_fd() */
+	sa_family_t svm_family;
+
+   /** \cond PRIVATE */
+	unsigned short svm_reserved1;
+   /** \endcond */
+
+   /** \brief Port.  \see VMADDR_PORT_ANY */
+	unsigned int svm_port;
+
+   /** \brief Context ID.  \see VMADDR_CID_ANY */
+	unsigned int svm_cid;
+
+   /** \cond PRIVATE */
+	unsigned char svm_zero[sizeof(struct sockaddr) -
+			       sizeof(sa_family_t) -
+			       sizeof(unsigned short) -
+			       sizeof(unsigned int) - sizeof(unsigned int)];
+   /** \endcond */
+};
+
+#if defined(linux) && defined(__KERNEL__)
+int vmci_sock_get_local_c_id(void);
+#else
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <sys/ioctl.h>
+#include <unistd.h>
+
+#include <stdio.h>
+
+/** \cond PRIVATE */
+#define VMCI_SOCKETS_DEFAULT_DEVICE      "/dev/vsock"
+#define VMCI_SOCKETS_CLASSIC_ESX_DEVICE  "/vmfs/devices/char/vsock/vsock"
+#define VMCI_SOCKETS_VERSION       1972
+#define VMCI_SOCKETS_GET_AF_VALUE  1976
+#define VMCI_SOCKETS_GET_LOCAL_CID 1977
+/** \endcond */
+
+   /*
+    * VMCISock_Version
+    *
+    * \brief Retrieve the vSockets version.
+    *
+    * Returns the current version of vSockets.  The version is a 32-bit
+    * unsigned integer that consist of three components: the epoch, the major
+    * version, and the minor version.  Use the \c VMCI_SOCKETS_VERSION macros
+    * to extract the components.
+    *
+    * \see VMCI_SOCKETS_VERSION_EPOCH() \see VMCI_SOCKETS_VERSION_MAJOR() \see
+    * VMCI_SOCKETS_VERSION_MINOR()
+    *
+    * \retval VMCI_SOCKETS_INVALID_VERSION Not available. \retval other The
+    * current version.
+    *
+    * An example is given below.
+    *
+    * \code unsigned int ver = VMCISock_Version(); if (ver !=
+    * VMCI_SOCKETS_INVALID_VERSION) { printf("vSockets version=%d.%d.%d\n",
+    * VMCI_SOCKETS_VERSION_EPOCH(ver), VMCI_SOCKETS_VERSION_MAJOR(ver),
+    * VMCI_SOCKETS_VERSION_MINOR(ver)); } \endcode
+    */
+
+static inline unsigned int VMCISock_Version(void)
+{
+	int fd;
+	unsigned int version;
+
+	fd = open(VMCI_SOCKETS_DEFAULT_DEVICE, O_RDWR);
+	if (fd < 0) {
+		fd = open(VMCI_SOCKETS_CLASSIC_ESX_DEVICE, O_RDWR);
+		if (fd < 0)
+			return VMCI_SOCKETS_INVALID_VERSION;
+
+	}
+
+	if (ioctl(fd, VMCI_SOCKETS_VERSION, &version) < 0)
+		version = VMCI_SOCKETS_INVALID_VERSION;
+
+	close(fd);
+	return version;
+}
+
+   /*
+    * vmci_sock_get_af_value_fd
+    *
+    * \brief Retrieve the address family value for vSockets.
+    *
+    * Returns the value to be used for the VMCI Sockets address family. This
+    * value should be used as the domain argument to \c socket(2) (when you
+    * might otherwise use \c AF_INET).  For VMCI Socket-specific options, this
+    * value should also be used for the level argument to \c setsockopt(2)
+    * (when you might otherwise use \c SOL_TCP).
+    *
+    * \see vmci_sock_release_af_value_fd() \see sockaddr_vm
+    *
+    * \param[out] out_fd File descriptor to the VMCI device.  The address
+    * family value is valid until this descriptor is closed.  This parameter is
+    * only valid if the return value is not -1. Call
+    * vmci_sock_release_af_value_fd() to close this descriptor.
+    *
+    * \retval -1 Not available. \retval other The address family value.
+    *
+    * An example is given below.
+    *
+    * \code int vmciFd; int af = vmci_sock_get_af_value_fd(&vmciFd); if (af !=
+    * -1) { int fd = socket(af, SOCK_STREAM, 0); ... close(fd); close(vmciFd); }
+    * \endcode
+    */
+
+static inline int vmci_sock_get_af_value_fd(int *out_fd)
+{
+	int fd;
+	int family;
+
+	fd = open(VMCI_SOCKETS_DEFAULT_DEVICE, O_RDWR);
+	if (fd < 0) {
+		fd = open(VMCI_SOCKETS_CLASSIC_ESX_DEVICE, O_RDWR);
+		if (fd < 0)
+			return -1;
+
+	}
+
+	if (ioctl(fd, VMCI_SOCKETS_GET_AF_VALUE, &family) < 0)
+		family = -1;
+
+	if (family < 0)
+		close(fd);
+	else if (out_fd)
+		*out_fd = fd;
+
+	return family;
+}
+
+   /** \cond PRIVATE */
+   /*
+    * vmci_sock_get_af_value
+    *
+    * \brief Retrieve the address family value for vSockets.
+    *
+    * Returns the value to be used for the VMCI Sockets address family. This
+    * value should be used as the domain argument to \c socket(2) (when you
+    * might otherwise use \c AF_INET).  For VMCI Socket-specific options, this
+    * value should also be used for the level argument to \c setsockopt(2)
+    * (when you might otherwise use \c SOL_TCP).
+    *
+    * \note This function leaves its descriptor to the vsock device open so
+    * that the socket implementation knows that the socket family is still in
+    * use.  This is done because the address family is registered with the
+    * kernel on-demand and a notification is needed to unregister the address
+    * family.  Use of this function is thus discouraged; please use
+    * vmci_sock_get_af_value_fd() instead.
+    *
+    * \see vmci_sock_get_af_value_fd() \see sockaddr_vm
+    *
+    * \retval -1 Not available. \retval other The address family value.
+    *
+    * An example is given below.
+    *
+    * \code int af = vmci_sock_get_af_value(); if (af != -1) { int fd =
+    * socket(af, SOCK_STREAM, 0); ... close(fd); } \endcode
+    */
+
+static inline int vmci_sock_get_af_value(void)
+{
+	return vmci_sock_get_af_value_fd(NULL);
+}
+
+   /** \endcond PRIVATE */
+
+   /*
+    * vmci_sock_release_af_value_fd
+    *
+    * \brief Release the file descriptor obtained when retrieving the address
+    * family value.
+    *
+    * Use this to release the file descriptor obtained by calling
+    * vmci_sock_get_af_value_fd().
+    *
+    * \see vmci_sock_get_af_value_fd()
+    *
+    * \param[in] fd File descriptor to the VMCI device.
+    */
+
+static inline void vmci_sock_release_af_value_fd(int fd)
+{
+	if (fd >= 0)
+		close(fd);
+
+}
+
+   /*
+    * vmci_sock_get_local_c_id
+    *
+    * \brief Retrieve the current context ID.
+    *
+    * \see VMADDR_CID_ANY
+    *
+    * \retval VMADDR_CID_ANY Not available. \retval other The current context
+    * ID.
+    *
+    * An example is given below.
+    *
+    * \code int vmciFd; int af = vmci_sock_get_af_value_fd(&vmciFd); struct
+    * sockaddr_vm addr; addr.svm_family = af; addr.svm_cid =
+    * vmci_sock_get_local_c_id(); vmci_sock_release_af_value_fd(vmciFd);
+    * \endcode
+    */
+
+static inline unsigned int vmci_sock_get_local_c_id(void)
+{
+	int fd;
+	unsigned int context_id;
+
+	fd = open(VMCI_SOCKETS_DEFAULT_DEVICE, O_RDWR);
+	if (fd < 0) {
+		fd = open(VMCI_SOCKETS_CLASSIC_ESX_DEVICE, O_RDWR);
+		if (fd < 0)
+			return VMADDR_CID_ANY;
+
+	}
+
+	if (ioctl(fd, VMCI_SOCKETS_GET_LOCAL_CID, &context_id) < 0)
+		context_id = VMADDR_CID_ANY;
+
+	close(fd);
+	return context_id;
+}
+#endif
+
+#endif
diff --git a/net/vmw_vsock/vmci_sockets_packet.h b/net/vmw_vsock/vmci_sockets_packet.h
new file mode 100644
index 0000000..9e31e30
--- /dev/null
+++ b/net/vmw_vsock/vmci_sockets_packet.h
@@ -0,0 +1,90 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2012 VMware, Inc. All rights reserved.
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
+/*
+ * vmci_sockets_packet.h --
+ *
+ * Definition of VMCI Sockets packet format, constants, and types.
+ */
+
+#ifndef _VMCI_SOCKETS_PACKET_H_
+#define _VMCI_SOCKETS_PACKET_H_
+
+#include <linux/vmw_vmci_defs.h>
+#include <linux/vmw_vmci_api.h>
+
+/*
+ * STREAM control packets.
+ */
+
+/* If the packet format changes in a release then this should change too. */
+#define VSOCK_PACKET_VERSION 1
+
+/* The resource ID on which control packets are sent. */
+#define VSOCK_PACKET_RID 1
+
+enum vsock_packet_type {
+	VSOCK_PACKET_TYPE_INVALID = 0,
+	VSOCK_PACKET_TYPE_REQUEST,
+	VSOCK_PACKET_TYPE_NEGOTIATE,
+	VSOCK_PACKET_TYPE_OFFER,
+	VSOCK_PACKET_TYPE_ATTACH,
+	VSOCK_PACKET_TYPE_WROTE,
+	VSOCK_PACKET_TYPE_READ,
+	VSOCK_PACKET_TYPE_RST,
+	VSOCK_PACKET_TYPE_SHUTDOWN,
+	VSOCK_PACKET_TYPE_WAITING_WRITE,
+	VSOCK_PACKET_TYPE_WAITING_READ,
+	VSOCK_PACKET_TYPE_REQUEST2,
+	VSOCK_PACKET_TYPE_NEGOTIATE2,
+	VSOCK_PACKET_TYPE_MAX
+};
+
+typedef u16 vsock_proto_version;
+#define VSOCK_PROTO_INVALID        0
+#define VSOCK_PROTO_PKT_ON_NOTIFY (1 << 0)
+
+#define VSOCK_PROTO_ALL_SUPPORTED (VSOCK_PROTO_PKT_ON_NOTIFY)
+
+struct vsock_waiting_info {
+	u64 generation;
+	u64 offset;
+};
+
+/*
+ * Control packet type for STREAM sockets.  DGRAMs have no control packets nor
+ * special packet header for data packets, they are just raw VMCI DGRAM
+ * messages.  For STREAMs, control packets are sent over the control channel
+ * while data is written and read directly from queue pairs with no packet
+ * format.
+ */
+struct vsock_packet {
+	struct vmci_datagram dg;
+	u8 version;
+	u8 type;
+	vsock_proto_version proto;
+
+	u32 src_port;
+	u32 dst_port;
+	u32 _reserved2;
+	union {
+		u64 size;
+		u64 mode;
+		struct vmci_handle handle;
+		struct vsock_waiting_info wait;
+	} u;
+};
+
+#endif
diff --git a/net/vmw_vsock/vsock_common.h b/net/vmw_vsock/vsock_common.h
new file mode 100644
index 0000000..e902783
--- /dev/null
+++ b/net/vmw_vsock/vsock_common.h
@@ -0,0 +1,127 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2007-2012 VMware, Inc. All rights reserved.
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
+/*
+ * vsockCommon.h --
+ *
+ * VSockets common constants, types and functions.
+ */
+
+#ifndef _VSOCK_COMMON_H_
+#define _VSOCK_COMMON_H_
+
+/*
+ * vmci_sock_get_af_value_int is defined separately from vmci_sock_get_af_value
+ * because it is used in several different contexts. In particular it is called
+ * from vsock_addr.c which gets compiled into both our kernel modules as well
+ * as the user level vsock library. In the linux kernel we need different
+ * behavior than external kernel modules using VMCI Sockets api inside the
+ * kernel.  FIXME
+ */
+
+#if defined __KERNEL__
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <asm/page.h>
+#else
+/* In userland, just use the normal exported userlevel api. */
+#define vmci_sock_get_af_value_int() vmci_sock_get_af_value()
+#endif
+
+#include <linux/vmw_vmci_defs.h>
+#include <linux/vmw_vmci_api.h>
+
+#include "vmci_sockets.h"
+#include "vsock_addr.h"
+
+#ifdef __x86_64__
+#define FMT64 "ll"
+#else
+#define FMT64 "L"
+#endif
+
+#ifndef PAGE_SHIFT
+#if defined __i386__
+#define PAGE_SHIFT 12
+#elif defined __arm__
+#define PAGE_SHIFT 12
+#else
+#error
+#endif
+#endif
+
+#ifndef PAGE_SIZE
+#define PAGE_SIZE (1<<PAGE_SHIFT)
+#endif
+
+#define MAX_UINT32 ((u32)0xffffffff)
+
+#ifndef ESYSNOTREADY
+#define ESYSNOTREADY EOPNOTSUPP
+#endif
+
+#define sockerr()	errno
+#define sockerr2err(_e)	(((_e) > 0) ? -(_e) : (_e))
+#define SS_LISTEN	255
+
+extern vmci_id vmci_get_context_id(void);
+
+/*
+ * Helper function to determine if the given handle points to the local context.
+ * Returns TRUE if the given handle is for the local context, FALSE otherwise.
+ */
+
+static inline bool vsock_vmci_is_local(struct vmci_handle handle)
+{
+	return vmci_get_context_id() == VMCI_HANDLE_TO_CONTEXT_ID(handle);
+}
+
+/*
+ * Helper function to convert from a VMCI error code to a VSock error code.
+ */
+
+static inline s32 vsock_vmci_error_to_vsock_error(s32 vmci_error)
+{
+	int err;
+
+	switch (vmci_error) {
+	case VMCI_ERROR_NO_MEM:
+		err = ENOMEM;
+		break;
+	case VMCI_ERROR_DUPLICATE_ENTRY:
+	case VMCI_ERROR_ALREADY_EXISTS:
+		err = EADDRINUSE;
+		break;
+	case VMCI_ERROR_NO_ACCESS:
+		err = EPERM;
+		break;
+	case VMCI_ERROR_NO_RESOURCES:
+		err = ENOBUFS;
+		break;
+	case VMCI_ERROR_INVALID_RESOURCE:
+		err = EHOSTUNREACH;
+		break;
+	case VMCI_ERROR_MODULE_NOT_LOADED:
+		err = ESYSNOTREADY;
+		break;
+	case VMCI_ERROR_INVALID_ARGS:
+	default:
+		err = EINVAL;
+	}
+
+	return sockerr2err(err);
+}
+
+#endif
diff --git a/net/vmw_vsock/vsock_packet.h b/net/vmw_vsock/vsock_packet.h
new file mode 100644
index 0000000..85b8d4e
--- /dev/null
+++ b/net/vmw_vsock/vsock_packet.h
@@ -0,0 +1,124 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2007-2012 VMware, Inc. All rights reserved.
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
+/*
+ * vsockPacket.h --
+ *
+ * Packet constants, types and functions.
+ */
+
+#ifndef _VSOCK_PACKET_H_
+#define _VSOCK_PACKET_H_
+
+#include "vmci_sockets_packet.h"
+
+/*
+ *
+ * vsock_packet_init --
+ *
+ * Initialize the given packet.  The packet version is set and the fields are
+ * filled out.  Reserved fields are cleared.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
+
+static inline void
+vsock_packet_init(struct vsock_packet *pkt,
+		  struct sockaddr_vm *src,
+		  struct sockaddr_vm *dst,
+		  u8 type,
+		  u64 size,
+		  u64 mode,
+		  struct vsock_waiting_info *wait,
+		  vsock_proto_version proto,
+		  struct vmci_handle handle)
+{
+	/*
+	 * We register the stream control handler as an any cid handle so we
+	 * must always send from a source address of VMADDR_CID_ANY
+	 */
+	pkt->dg.src = VMCI_MAKE_HANDLE(VMADDR_CID_ANY, VSOCK_PACKET_RID);
+	pkt->dg.dst = VMCI_MAKE_HANDLE(dst->svm_cid, VSOCK_PACKET_RID);
+	pkt->dg.payload_size = sizeof *pkt - sizeof pkt->dg;
+	pkt->version = VSOCK_PACKET_VERSION;
+	pkt->type = type;
+	pkt->src_port = src->svm_port;
+	pkt->dst_port = dst->svm_port;
+	memset(&pkt->proto, 0, sizeof pkt->proto);
+	memset(&pkt->_reserved2, 0, sizeof pkt->_reserved2);
+
+	switch (pkt->type) {
+	case VSOCK_PACKET_TYPE_INVALID:
+		pkt->u.size = 0;
+		break;
+
+	case VSOCK_PACKET_TYPE_REQUEST:
+	case VSOCK_PACKET_TYPE_NEGOTIATE:
+		pkt->u.size = size;
+		break;
+
+	case VSOCK_PACKET_TYPE_OFFER:
+	case VSOCK_PACKET_TYPE_ATTACH:
+		pkt->u.handle = handle;
+		break;
+
+	case VSOCK_PACKET_TYPE_WROTE:
+	case VSOCK_PACKET_TYPE_READ:
+	case VSOCK_PACKET_TYPE_RST:
+		pkt->u.size = 0;
+		break;
+
+	case VSOCK_PACKET_TYPE_SHUTDOWN:
+		pkt->u.mode = mode;
+		break;
+
+	case VSOCK_PACKET_TYPE_WAITING_READ:
+	case VSOCK_PACKET_TYPE_WAITING_WRITE:
+		memcpy(&pkt->u.wait, wait, sizeof pkt->u.wait);
+		break;
+
+	case VSOCK_PACKET_TYPE_REQUEST2:
+	case VSOCK_PACKET_TYPE_NEGOTIATE2:
+		pkt->u.size = size;
+		pkt->proto = proto;
+		break;
+	}
+}
+
+/*
+ *
+ * vsock_packet_get_addresses --
+ *
+ * Get the local and remote addresses from the given packet.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
+
+static inline void
+vsock_packet_get_addresses(struct vsock_packet *pkt,
+			   struct sockaddr_vm *local,
+			   struct sockaddr_vm *remote)
+{
+	vsock_addr_init(local, VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.dst),
+			pkt->dst_port);
+	vsock_addr_init(remote, VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.src),
+			pkt->src_port);
+}
+
+#endif
diff --git a/net/vmw_vsock/vsock_version.h b/net/vmw_vsock/vsock_version.h
new file mode 100644
index 0000000..3a698c7
--- /dev/null
+++ b/net/vmw_vsock/vsock_version.h
@@ -0,0 +1,28 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2011-2012 VMware, Inc. All rights reserved.
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
+/*
+ * vsock_version.h --
+ *
+ * Version definitions for the Linux vsock driver.
+ */
+
+#ifndef _VSOCK_VERSION_H_
+#define _VSOCK_VERSION_H_
+
+#define VSOCK_DRIVER_VERSION_PARTS	{ 1, 0, 0, 0 }
+#define VSOCK_DRIVER_VERSION_STRING	"1.0.0.0-k"
+
+#endif /* _VSOCK_VERSION_H_ */
