From: George Zhang <georgezhang@vmware.com>
Subject: [PATCH 1/6] VSOCK: vsock protocol implementation.
Date: Wed, 07 Nov 2012 10:45:28 -0800
Message-ID: <20121107184523.10612.1.stgit@promb-2n-dhcp175.eng.vmware.com>
References: <20121107184340.10612.3372.stgit@promb-2n-dhcp175.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	georgezhang@vmware.com, virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121107184340.10612.3372.stgit@promb-2n-dhcp175.eng.vmware.com>
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

VSOCK linux socket module for VMCI Sockets protocol family.


Signed-off-by: George Zhang <georgezhang@vmware.com>
---
 net/vmw_vsock/af_vsock.c | 4135 ++++++++++++++++++++++++++++++++++++++++++++++
 net/vmw_vsock/af_vsock.h |  179 ++
 2 files changed, 4314 insertions(+), 0 deletions(-)
 create mode 100644 net/vmw_vsock/af_vsock.c
 create mode 100644 net/vmw_vsock/af_vsock.h

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
new file mode 100644
index 0000000..4d31c39
--- /dev/null
+++ b/net/vmw_vsock/af_vsock.c
@@ -0,0 +1,4135 @@
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
+ * af_vsock.c --
+ *
+ * Linux socket module for the VMCI Sockets protocol family.
+ */
+
+/*
+ * Implementation notes:
+ *
+ * - There are two kinds of sockets: those created by user action (such as
+ * calling socket(2)) and those created by incoming connection request packets.
+ *
+ * - There are two "global" tables, one for bound sockets (sockets that have
+ * specified an address that they are responsible for) and one for connected
+ * sockets (sockets that have established a connection with another socket).
+ * These tables are "global" in that all sockets on the system are placed
+ * within them. - Note, though, that the bound table contains an extra entry
+ * for a list of unbound sockets and SOCK_DGRAM sockets will always remain in
+ * that list. The bound table is used solely for lookup of sockets when packets
+ * are received and that's not necessary for SOCK_DGRAM sockets since we create
+ * a datagram handle for each and need not perform a lookup.  Keeping SOCK_DGRAM
+ * sockets out of the bound hash buckets will reduce the chance of collisions
+ * when looking for SOCK_STREAM sockets and prevents us from having to check the
+ * socket type in the hash table lookups.
+ *
+ * - Sockets created by user action will either be "client" sockets that
+ * initiate a connection or "server" sockets that listen for connections; we do
+ * not support simultaneous connects (two "client" sockets connecting).
+ *
+ * - "Server" sockets are referred to as listener sockets throughout this
+ * implementation because they are in the SS_LISTEN state.  When a connection
+ * request is received (the second kind of socket mentioned above), we create a
+ * new socket and refer to it as a pending socket.  These pending sockets are
+ * placed on the pending connection list of the listener socket.  When future
+ * packets are received for the address the listener socket is bound to, we
+ * check if the source of the packet is from one that has an existing pending
+ * connection.  If it does, we process the packet for the pending socket.  When
+ * that socket reaches the connected state, it is removed from the listener
+ * socket's pending list and enqueued in the listener socket's accept queue.
+ * Callers of accept(2) will accept connected sockets from the listener socket's
+ * accept queue.  If the socket cannot be accepted for some reason then it is
+ * marked rejected.  Once the connection is accepted, it is owned by the user
+ * process and the responsibility for cleanup falls with that user process.
+ *
+ * - It is possible that these pending sockets will never reach the connected
+ * state; in fact, we may never receive another packet after the connection
+ * request.  Because of this, we must schedule a cleanup function to run in the
+ * future, after some amount of time passes where a connection should have been
+ * established.  This function ensures that the socket is off all lists so it
+ * cannot be retrieved, then drops all references to the socket so it is cleaned
+ * up (sock_put() -> sk_free() -> our sk_destruct implementation).  Note this
+ * function will also cleanup rejected sockets, those that reach the connected
+ * state but leave it before they have been accepted.
+ *
+ * - Sockets created by user action will be cleaned up when the user process
+ * calls close(2), causing our release implementation to be called. Our release
+ * implementation will perform some cleanup then drop the last reference so our
+ * sk_destruct implementation is invoked.  Our sk_destruct implementation will
+ * perform additional cleanup that's common for both types of sockets.
+ *
+ * - A socket's reference count is what ensures that the structure won't be
+ * freed.  Each entry in a list (such as the "global" bound and connected tables
+ * and the listener socket's pending list and connected queue) ensures a
+ * reference.  When we defer work until process context and pass a socket as our
+ * argument, we must ensure the reference count is increased to ensure the
+ * socket isn't freed before the function is run; the deferred function will
+ * then drop the reference.
+ */
+
+#include <linux/types.h>
+
+#define EXPORT_SYMTAB
+#include <linux/kmod.h>
+#include <linux/socket.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/miscdevice.h>
+#include <linux/poll.h>
+#include <linux/smp.h>
+#include <linux/bitops.h>
+#include <linux/list.h>
+#include <linux/wait.h>
+#include <linux/init.h>
+#include <linux/io.h>
+
+#include <linux/module.h>
+#include <linux/unistd.h>
+#include <linux/stddef.h>	/* for NULL */
+#include <net/sock.h>
+#include <linux/kernel.h>
+#include <linux/workqueue.h>
+#include <linux/mutex.h>
+/*
+ * Include linux/cred.h via linux/sched.h - it is not nice, but as cpp does not
+ * have #ifexist...
+ */
+#include <linux/sched.h>
+
+#include "af_vsock.h"
+#include "stats.h"
+#include "util.h"
+#include "vsock_version.h"
+
+/*
+ * Prototypes
+ */
+
+/* Internal functions. */
+static bool vsock_vmci_proto_to_notify_struct(struct sock *sk,
+					      vsock_proto_version * proto,
+					      bool old_pkt_proto);
+static int vsock_vmci_recv_dgram_cb(void *data, struct vmci_datagram *dg);
+static int vsock_vmci_recv_stream_cb(void *data, struct vmci_datagram *dg);
+static void vsock_vmci_peer_attach_cb(vmci_id sub_id,
+				      const struct vmci_event_data *ed,
+				      void *client_data);
+static void vsock_vmci_peer_detach_cb(vmci_id sub_id,
+				      const struct vmci_event_data *ed,
+				      void *client_data);
+static void vsock_vmci_recv_pkt_work(struct work_struct *work);
+static int vsock_vmci_recv_listen(struct sock *sk, vsock_packet *pkt);
+static int vsock_vmci_recv_connecting_server(struct sock *sk,
+					     struct sock *pending,
+					     vsock_packet *pkt);
+static int vsock_vmci_recv_connecting_client(struct sock *sk,
+					     vsock_packet *pkt);
+static int vsock_vmci_recv_connecting_client_negotiate(struct sock *sk,
+						       vsock_packet *pkt);
+static int vsock_vmci_recv_connecting_client_invalid(struct sock *sk,
+						     vsock_packet *pkt);
+static int vsock_vmci_recv_connected(struct sock *sk, vsock_packet *pkt);
+static int __vsock_vmci_bind(struct sock *sk, struct sockaddr_vm *addr);
+static struct sock *__vsock_vmci_create(struct net *net,
+					struct socket *sock,
+					struct sock *parent, gfp_t priority,
+					unsigned short type);
+static int vsock_vmci_register_with_vmci(void);
+static void vsock_vmci_unregister_with_vmci(void);
+
+/* Socket operations. */
+static void vsock_vmci_sk_destruct(struct sock *sk);
+static int vsock_vmci_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
+static int vsock_vmci_release(struct socket *sock);
+static int vsock_vmci_bind(struct socket *sock,
+			   struct sockaddr *addr, int addr_len);
+static int vsock_vmci_dgram_connect(struct socket *sock,
+				    struct sockaddr *addr, int addr_len,
+				    int flags);
+static int vsock_vmci_stream_connect(struct socket *sock, struct sockaddr *addr,
+				     int addr_len, int flags);
+static int vsock_vmci_accept(struct socket *sock, struct socket *newsock,
+			     int flags);
+static int vsock_vmci_getname(struct socket *sock, struct sockaddr *addr,
+			      int *addr_len, int peer);
+static unsigned int vsock_vmci_poll(struct file *file, struct socket *sock,
+				    poll_table *wait);
+static int vsock_vmci_listen(struct socket *sock, int backlog);
+static int vsock_vmci_shutdown(struct socket *sock, int mode);
+
+typedef unsigned int vsock_setsockopt_len_type;
+static int vsock_vmci_stream_setsockopt(struct socket *sock, int level,
+					int optname, char __user *optval,
+					vsock_setsockopt_len_type optlen);
+
+static int vsock_vmci_stream_getsockopt(struct socket *sock, int level,
+					int optname, char __user *optval,
+					int __user *optlen);
+
+static int vsock_vmci_dgram_sendmsg(struct kiocb *kiocb,
+				    struct socket *sock, struct msghdr *msg,
+				    size_t len);
+static int vsock_vmci_dgram_recvmsg(struct kiocb *kiocb, struct socket *sock,
+				    struct msghdr *msg, size_t len, int flags);
+static int vsock_vmci_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
+				     struct msghdr *msg, size_t len);
+static int vsock_vmci_stream_recvmsg(struct kiocb *kiocb, struct socket *sock,
+				     struct msghdr *msg, size_t len, int flags);
+
+static int vsock_vmci_create(struct net *net,
+			     struct socket *sock, int protocol, int kern);
+
+/*
+ * Variables.
+ */
+
+/* Protocol family. */
+static struct proto vsock_vmci_proto = {
+	.name = "AF_VMCI",
+	.owner = THIS_MODULE,
+	.obj_size = sizeof(vsock_vmci_sock),
+};
+
+static const struct net_proto_family vsock_vmci_family_ops = {
+	.family = AF_VSOCK,
+	.create = vsock_vmci_create,
+	.owner = THIS_MODULE,
+};
+
+/* Socket operations, split for DGRAM and STREAM sockets. */
+static const struct proto_ops vsock_vmci_dgram_ops = {
+	.family = PF_VSOCK,
+	.owner = THIS_MODULE,
+	.release = vsock_vmci_release,
+	.bind = vsock_vmci_bind,
+	.connect = vsock_vmci_dgram_connect,
+	.socketpair = sock_no_socketpair,
+	.accept = sock_no_accept,
+	.getname = vsock_vmci_getname,
+	.poll = vsock_vmci_poll,
+	.ioctl = sock_no_ioctl,
+	.listen = sock_no_listen,
+	.shutdown = vsock_vmci_shutdown,
+	.setsockopt = sock_no_setsockopt,
+	.getsockopt = sock_no_getsockopt,
+	.sendmsg = vsock_vmci_dgram_sendmsg,
+	.recvmsg = vsock_vmci_dgram_recvmsg,
+	.mmap = sock_no_mmap,
+	.sendpage = sock_no_sendpage,
+};
+
+static const struct proto_ops vsock_vmci_stream_ops = {
+	.family = PF_VSOCK,
+	.owner = THIS_MODULE,
+	.release = vsock_vmci_release,
+	.bind = vsock_vmci_bind,
+	.connect = vsock_vmci_stream_connect,
+	.socketpair = sock_no_socketpair,
+	.accept = vsock_vmci_accept,
+	.getname = vsock_vmci_getname,
+	.poll = vsock_vmci_poll,
+	.ioctl = sock_no_ioctl,
+	.listen = vsock_vmci_listen,
+	.shutdown = vsock_vmci_shutdown,
+	.setsockopt = vsock_vmci_stream_setsockopt,
+	.getsockopt = vsock_vmci_stream_getsockopt,
+	.sendmsg = vsock_vmci_stream_sendmsg,
+	.recvmsg = vsock_vmci_stream_recvmsg,
+	.mmap = sock_no_mmap,
+	.sendpage = sock_no_sendpage,
+};
+
+typedef struct vsock_recv_pkt_info {
+	struct work_struct work;
+	struct sock *sk;
+	vsock_packet pkt;
+} vsock_recv_pkt_info;
+
+static struct vmci_handle vmci_stream_handle = { VMCI_INVALID_ID,
+						 VMCI_INVALID_ID };
+
+static vmci_id qp_resumed_sub_id = VMCI_INVALID_ID;
+
+static int PROTOCOL_OVERRIDE = -1;
+
+/*
+ * Netperf benchmarks have shown significant throughput improvements when the
+ * QP size is bumped from 64k to 256k. These measurements were taken during the
+ * K/L.next timeframe. Give users better performance by default.
+ */
+#define VSOCK_DEFAULT_QP_SIZE_MIN   128
+#define VSOCK_DEFAULT_QP_SIZE       262144
+#define VSOCK_DEFAULT_QP_SIZE_MAX   262144
+
+/*
+ * The default peer timeout indicates how long we will wait for a peer response
+ * to a control message.
+ */
+#define VSOCK_DEFAULT_CONNECT_TIMEOUT (2 * HZ)
+
+#define LOG_PACKET(_pkt)
+
+/**
+ * vsock_vmci_old_proto_override --
+ *
+ * Check to see if the user has asked us to override all sockets to use the
+ * vsock notify protocol.
+ *
+ * Results: true if there is a protocol override in effect. - old_pkt_proto is
+ * true the original protocol should be used. False if there is no override in
+ * effect.
+ *
+ * Side effects: None.
+ */
+
+static bool vsock_vmci_old_proto_override(bool *old_pkt_proto)
+{
+	if (PROTOCOL_OVERRIDE != -1) {
+		if (PROTOCOL_OVERRIDE == 0)
+			*old_pkt_proto = true;
+		else
+			*old_pkt_proto = false;
+
+		pr_info("Proto override in use.\n");
+		return true;
+	}
+
+	return false;
+}
+
+/*
+ * vsock_vmci_proto_to_notify_struct --
+ *
+ * Given a particular notify protocol version, setup the socket's notify struct
+ * correctly.
+ *
+ * Results: true on success, false otherwise.
+ *
+ * Side effects: None.
+ */
+
+static bool
+vsock_vmci_proto_to_notify_struct(struct sock *sk,
+				  vsock_proto_version *proto,
+				  bool old_pkt_proto)
+{
+	vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	if (old_pkt_proto) {
+		if (*proto != VSOCK_PROTO_INVALID) {
+			pr_err("Can't set both an old and new protocol\n");
+			return false;
+		}
+		vsk->notify_ops = &vsock_vmci_notify_pkt_ops;
+		goto exit;
+	}
+
+	switch (*proto) {
+	case VSOCK_PROTO_PKT_ON_NOTIFY:
+		vsk->notify_ops = &vsock_vmci_notify_pkt_q_state_ops;
+		break;
+	default:
+		pr_err("Unknown notify protocol version\n");
+		return false;
+	}
+
+exit:
+	NOTIFYCALL(vsk, socket_init, sk);
+	return true;
+}
+
+/*
+ * vsock_vmci_new_proto_supported_versions
+ *
+ * Gets the supported REQUEST2/NEGOTIATE2 vsock protocol versions.
+ *
+ * Results: Either 1 specific protocol version (override mode) or
+ * VSOCK_PROTO_ALL_SUPPORTED.
+ *
+ * Side effects: None.
+ */
+
+static vsock_proto_version vsock_vmci_new_proto_supported_versions(void)
+{
+	if (PROTOCOL_OVERRIDE != -1)
+		return PROTOCOL_OVERRIDE;
+
+	return VSOCK_PROTO_ALL_SUPPORTED;
+}
+
+/*
+ * VSockSocket_Trusted --
+ *
+ * We allow two kinds of sockets to communicate with a restricted VM: 1)
+ * trusted sockets 2) sockets from applications running as the same user as the
+ * VM (this is only true for the host side and only when using hosted products)
+ *
+ * Results: true if trusted communication is allowed to peer_cid, false
+ * otherwise.
+ *
+ * Side effects: None.
+ */
+
+static bool vsock_vmci_trusted(vsock_vmci_sock *vsock, vmci_id peer_cid)
+{
+	return vsock->trusted ||
+	       vmci_is_context_owner(peer_cid, vsock->owner->uid);
+}
+
+/*
+ * VSockSocket_AllowDgram --
+ *
+ * We allow sending datagrams to and receiving datagrams from a restricted VM
+ * only if it is trusted as described in vsock_vmci_trusted.
+ *
+ * Results: true if datagram communication is allowed to peer_cid, false
+ * otherwise.
+ *
+ * Side effects: None.
+ */
+
+static bool vsock_vmci_allow_dgram(vsock_vmci_sock *vsock, vmci_id peer_cid)
+{
+	if (vsock->cached_peer != peer_cid) {
+		vsock->cached_peer = peer_cid;
+		if (!vsock_vmci_trusted(vsock, peer_cid) &&
+		    (vmci_context_get_priv_flags(peer_cid) &
+		     VMCI_PRIVILEGE_FLAG_RESTRICTED)) {
+			vsock->cached_peer_allow_dgram = false;
+		} else {
+			vsock->cached_peer_allow_dgram = true;
+		}
+	}
+
+	return vsock->cached_peer_allow_dgram;
+}
+
+/*
+ * vmci_sock_get_local_c_id --
+ *
+ * Kernel interface that allows external kernel modules to get the current VMCI
+ * context id. This version of the function is exported to kernel clients and
+ * should not change.
+ *
+ * Results: The context id on success, a negative error on failure.
+ *
+ * Side effects: None.
+ */
+
+int vmci_sock_get_local_c_id(void)
+{
+	/* FIXME: needed? */
+	return vmci_get_context_id();
+}
+EXPORT_SYMBOL_GPL(vmci_sock_get_local_c_id);
+
+/*
+ * Helper functions.
+ */
+
+/*
+ * vsock_vmci_queue_pair_alloc --
+ *
+ * Allocates or attaches to a queue pair. Tries to register with trusted status
+ * if requested but does not fail if the queuepair could not be allocate as
+ * trusted (running in the guest)
+ *
+ * Results: 0 on success. A VSock error on error.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_queue_pair_alloc(struct vmci_qp **qpair,
+			    struct vmci_handle *handle,
+			    u64 produce_size,
+			    u64 consume_size,
+			    vmci_id peer, u32 flags, bool trusted)
+{
+	int err = 0;
+
+	if (trusted) {
+		/*
+		 * Try to allocate our queue pair as trusted. This will only
+		 * work if vsock is running in the host.
+		 */
+
+		err = vmci_qpair_alloc(qpair, handle, produce_size,
+				       consume_size,
+				       peer, flags,
+				       VMCI_PRIVILEGE_FLAG_TRUSTED);
+		if (err != VMCI_ERROR_NO_ACCESS)
+			goto out;
+
+	}
+
+	err = vmci_qpair_alloc(qpair, handle, produce_size, consume_size,
+			       peer, flags, VMCI_NO_PRIVILEGE_FLAGS);
+out:
+	if (err < 0) {
+		pr_err("Could not attach to queue pair with %d\n",
+		       err);
+		err = vsock_vmci_error_to_vsock_error(err);
+	}
+
+	return err;
+}
+
+/*
+ * vsock_vmci_datagram_create_hnd --
+ *
+ * Creates a datagram handle. Tries to register with trusted status but does
+ * not fail if the handler could not be allocated as trusted (running in the
+ * guest).
+ *
+ * Results: 0 on success. A VMCI error on error.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_datagram_create_hnd(vmci_id resource_id,
+			       u32 flags,
+			       vmci_datagram_recv_cb recv_cb,
+			       void *client_data,
+			       struct vmci_handle *out_handle)
+{
+	int err = 0;
+
+	/*
+	 * Try to allocate our datagram handler as trusted. This will only work
+	 * if vsock is running in the host.
+	 */
+
+	err = vmci_datagram_create_handle_priv(resource_id, flags,
+					       VMCI_PRIVILEGE_FLAG_TRUSTED,
+					       recv_cb,
+					       client_data, out_handle);
+
+	if (err == VMCI_ERROR_NO_ACCESS)
+		err = vmci_datagram_create_handle(resource_id, flags,
+						  recv_cb, client_data,
+						  out_handle);
+
+	return err;
+}
+
+/*
+ * vsock_vmci_recv_dgram_cb --
+ *
+ * VMCI Datagram receive callback.  This function is used specifically for
+ * SOCK_DGRAM sockets.
+ *
+ * This is invoked as part of a tasklet that's scheduled when the VMCI
+ * interrupt fires.  This is run in bottom-half context and if it ever needs to
+ * sleep it should defer that work to a work queue.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: An sk_buff is created and queued with this socket.
+ */
+
+static int vsock_vmci_recv_dgram_cb(void *data, struct vmci_datagram *dg)
+{
+	struct sock *sk;
+	size_t size;
+	struct sk_buff *skb;
+	vsock_vmci_sock *vsk;
+
+	ASSERT(dg->payload_size <= VMCI_MAX_DG_PAYLOAD_SIZE);
+
+	sk = (struct sock *)data;
+
+	/*
+	 * This handler is privileged when this module is running on the host.
+	 * We will get datagrams from all endpoints (even VMs that are in a
+	 * restricted context). If we get one from a restricted context then
+	 * the destination socket must be trusted.
+	 *
+	 * NOTE: We access the socket struct without holding the lock here.
+	 * This is ok because the field we are interested is never modified
+	 * outside of the create and destruct socket functions.
+	 */
+	vsk = vsock_sk(sk);
+	if (!vsock_vmci_allow_dgram(vsk, VMCI_HANDLE_TO_CONTEXT_ID(dg->src)))
+		return VMCI_ERROR_NO_ACCESS;
+
+	size = VMCI_DG_SIZE(dg);
+
+	/*
+	 * Attach the packet to the socket's receive queue as an sk_buff.
+	 */
+	skb = alloc_skb(size, GFP_ATOMIC);
+	if (skb) {
+		/* sk_receive_skb() will do a sock_put(), so hold here. */
+		sock_hold(sk);
+		skb_put(skb, size);
+		memcpy(skb->data, dg, size);
+		sk_receive_skb(sk, skb, 0);
+	}
+
+	return VMCI_SUCCESS;
+}
+
+/*
+ * vsock_vmci_recv_stream_cb --
+ *
+ * VMCI stream receive callback for control datagrams.  This function is used
+ * specifically for SOCK_STREAM sockets.
+ *
+ * This is invoked as part of a tasklet that's scheduled when the VMCI
+ * interrupt fires.  This is run in bottom-half context but it defers most of
+ * its work to the packet handling work queue.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int vsock_vmci_recv_stream_cb(void *data, struct vmci_datagram *dg)
+{
+	struct sock *sk;
+	struct sockaddr_vm dst;
+	struct sockaddr_vm src;
+	vsock_packet *pkt;
+	vsock_vmci_sock *vsk;
+	bool bh_process_pkt;
+	int err;
+
+	ASSERT(dg->payload_size <= VMCI_MAX_DG_PAYLOAD_SIZE);
+
+	sk = NULL;
+	err = VMCI_SUCCESS;
+	bh_process_pkt = false;
+
+	/*
+	 * Ignore incoming packets from contexts without sockets, or resources
+	 * that aren't vsock implementations.
+	 */
+
+	if (!vsock_addr_socket_context_stream
+	    (VMCI_HANDLE_TO_CONTEXT_ID(dg->src))
+	    || VSOCK_PACKET_RID != VMCI_HANDLE_TO_RESOURCE_ID(dg->src)) {
+		return VMCI_ERROR_NO_ACCESS;
+	}
+
+	if (VMCI_DG_SIZE(dg) < sizeof *pkt)
+		/* Drop datagrams that do not contain full VSock packets. */
+		return VMCI_ERROR_INVALID_ARGS;
+
+	pkt = (vsock_packet *) dg;
+
+	LOG_PACKET(pkt);
+
+	/*
+	 * Find the socket that should handle this packet.  First we look for a
+	 * connected socket and if there is none we look for a socket bound to
+	 * the destintation address.
+	 */
+	vsock_addr_init(&src, VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.src),
+			pkt->src_port);
+
+	vsock_addr_init(&dst, VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.dst),
+			pkt->dst_port);
+
+	sk = vsock_vmci_find_connected_socket(&src, &dst);
+	if (!sk) {
+		sk = vsock_vmci_find_bound_socket(&dst);
+		if (!sk) {
+			/*
+			 * We could not find a socket for this specified
+			 * address.  If this packet is a RST, we just drop it.
+			 * If it is another packet, we send a RST.  Note that
+			 * we do not send a RST reply to RSTs so that we do not
+			 * continually send RSTs between two endpoints.
+			 *
+			 * Note that since this is a reply, dst is src and src
+			 * is dst.
+			 */
+			if (VSOCK_SEND_RESET_BH(&dst, &src, pkt) < 0)
+				pr_err("unable to send reset.\n");
+
+			err = VMCI_ERROR_NOT_FOUND;
+			goto out;
+		}
+	}
+
+	/*
+	 * If the received packet type is beyond all types known to this
+	 * implementation, reply with an invalid message.  Hopefully this will
+	 * help when implementing backwards compatibility in the future.
+	 */
+	if (pkt->type >= VSOCK_PACKET_TYPE_MAX) {
+		VSOCK_SEND_INVALID_BH(&dst, &src);
+		err = VMCI_ERROR_INVALID_ARGS;
+		goto out;
+	}
+
+	/*
+	 * This handler is privileged when this module is running on the host.
+	 * We will get datagram connect requests from all endpoints (even VMs
+	 * that are in a restricted context). If we get one from a restricted
+	 * context then the destination socket must be trusted.
+	 *
+	 * NOTE: We access the socket struct without holding the lock here.
+	 * This is ok because the field we are interested is never modified
+	 * outside of the create and destruct socket functions.
+	 */
+	vsk = vsock_sk(sk);
+	if (!vsock_vmci_allow_dgram
+	    (vsk, VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.src))) {
+		err = VMCI_ERROR_NO_ACCESS;
+		goto out;
+	}
+
+	/*
+	 * We do most everything in a work queue, but let's fast path the
+	 * notification of reads and writes to help data transfer performance.
+	 * We can only do this if there is no process context code executing
+	 * for this socket since that may change the state.
+	 */
+	bh_lock_sock(sk);
+
+	if (!sock_owned_by_user(sk) && sk->sk_state == SS_CONNECTED)
+		NOTIFYCALL(vsk, handle_notify_pkt, sk, pkt, true, &dst, &src,
+			   &bh_process_pkt);
+
+	bh_unlock_sock(sk);
+
+	if (!bh_process_pkt) {
+		vsock_recv_pkt_info *recv_pkt_info;
+
+		recv_pkt_info = kmalloc(sizeof *recv_pkt_info, GFP_ATOMIC);
+		if (!recv_pkt_info) {
+			if (VSOCK_SEND_RESET_BH(&dst, &src, pkt) < 0)
+				pr_err("unable to send reset\n");
+
+			err = VMCI_ERROR_NO_MEM;
+			goto out;
+		}
+
+		recv_pkt_info->sk = sk;
+		memcpy(&recv_pkt_info->pkt, pkt, sizeof recv_pkt_info->pkt);
+		INIT_WORK(&recv_pkt_info->work, vsock_vmci_recv_pkt_work);
+
+		schedule_work(&recv_pkt_info->work);
+		/*
+		 * Clear sk so that the reference count incremented by one of
+		 * the Find functions above is not decremented below.  We need
+		 * that reference count for the packet handler we've scheduled
+		 * to run.
+		 */
+		sk = NULL;
+	}
+
+out:
+	if (sk)
+		sock_put(sk);
+
+	return err;
+}
+
+/*
+ * vsock_vmci_peer_attach_cb --
+ *
+ * Invoked when a peer attaches to a queue pair.
+ *
+ * Right now this does not do anything.
+ *
+ * Results: None.
+ *
+ * Side effects: May modify socket state and signal socket.
+ */
+
+static void vsock_vmci_peer_attach_cb(vmci_id sub_id,
+				      const struct vmci_event_data *e_data,
+				      void *client_data)
+{
+	struct sock *sk = client_data;
+	const struct vmci_event_payload_qp *e_payload;
+	vsock_vmci_sock *vsk;
+
+	e_payload = vmci_event_data_const_payload(e_data);
+
+	vsk = vsock_sk(sk);
+
+	/*
+	 * We don't ask for delayed CBs when we subscribe to this event (we
+	 * pass 0 as flags to vmci_event_subscribe()).  VMCI makes no
+	 * guarantees in that case about what context we might be running in,
+	 * so it could be BH or process, blockable or non-blockable.  So we
+	 * need to account for all possible contexts here.
+	 */
+	local_bh_disable();
+	bh_lock_sock(sk);
+
+	/*
+	 * XXX This is lame, we should provide a way to lookup sockets by
+	 * qp_handle.
+	 */
+	if (VMCI_HANDLE_EQUAL(vsk->qp_handle, e_payload->handle)) {
+		/*
+		 * XXX This doesn't do anything, but in the future we may want
+		 * to set a flag here to verify the attach really did occur and
+		 * we weren't just sent a datagram claiming it was.
+		 */
+		goto out;
+	}
+
+out:
+	bh_unlock_sock(sk);
+	local_bh_enable();
+}
+
+/*
+ *
+ * vsock_vmci_handle_detach --
+ *
+ * Perform the work necessary when the peer has detached.
+ *
+ * Note that this assumes the socket lock is held.
+ *
+ * Results: None.
+ *
+ * Side effects: The socket's and its peer's shutdown mask will be set
+ * appropriately, and any callers waiting on this socket will be awoken.
+ */
+
+static void vsock_vmci_handle_detach(struct sock *sk)
+{
+	vsock_vmci_sock *vsk;
+
+	vsk = vsock_sk(sk);
+	if (!VMCI_HANDLE_INVALID(vsk->qp_handle)) {
+		sock_set_flag(sk, SOCK_DONE);
+
+		/*
+		 * On a detach the peer will not be sending or receiving
+		 * anymore.
+		 */
+		vsk->peer_shutdown = SHUTDOWN_MASK;
+
+		/*
+		 * We should not be sending anymore since the peer won't be
+		 * there to receive, but we can still receive if there is data
+		 * left in our consume queue.
+		 */
+		if (vsock_vmci_stream_has_data(vsk) <= 0) {
+			if (sk->sk_state == SS_CONNECTING) {
+				/*
+				 * The peer may detach from a queue pair while
+				 * we are still in the connecting state, i.e.,
+				 * if the peer VM is killed after attaching to
+				 * a queue pair, but before we complete the
+				 * handshake. In that case, we treat the detach
+				 * event like a reset.
+				 */
+
+				sk->sk_state = SS_UNCONNECTED;
+				sk->sk_err = ECONNRESET;
+				sk->sk_error_report(sk);
+				return;
+			}
+			sk->sk_state = SS_UNCONNECTED;
+		}
+		sk->sk_state_change(sk);
+	}
+}
+
+/*
+ * vsock_vmci_peer_detach_cb --
+ *
+ * Invoked when a peer detaches from a queue pair.
+ *
+ * Results: None.
+ *
+ * Side effects: May modify socket state and signal socket.
+ */
+
+static void vsock_vmci_peer_detach_cb(vmci_id sub_id,
+				      const struct vmci_event_data *e_data,
+				      void *client_data)
+{
+	struct sock *sk = client_data;
+	const struct vmci_event_payload_qp *e_payload;
+	vsock_vmci_sock *vsk;
+
+	e_payload = vmci_event_data_const_payload(e_data);
+	vsk = vsock_sk(sk);
+	if (VMCI_HANDLE_INVALID(e_payload->handle))
+		return;
+
+	/* Same rules for locking as for peer_attach_cb(). */
+	local_bh_disable();
+	bh_lock_sock(sk);
+
+	/*
+	 * XXX This is lame, we should provide a way to lookup sockets by
+	 * qp_handle.
+	 */
+	if (VMCI_HANDLE_EQUAL(vsk->qp_handle, e_payload->handle))
+		vsock_vmci_handle_detach(sk);
+
+	bh_unlock_sock(sk);
+	local_bh_enable();
+}
+
+/*
+ * vsock_vmci_qp_resumed_cb --
+ *
+ * Invoked when a VM is resumed.  We must mark all connected stream sockets as
+ * detached.
+ *
+ * Results: None.
+ *
+ * Side effects: May modify socket state and signal socket.
+ */
+
+static void vsock_vmci_qp_resumed_cb(vmci_id sub_id,
+				     const struct vmci_event_data *e_data,
+				     void *client_data)
+{
+	int i;
+
+	spin_lock_bh(&vsock_table_lock);
+
+	/*
+	 * XXX This loop should probably be provided by util.{h,c}, but that's
+	 * for another day.
+	 */
+	for (i = 0; i < ARRAY_SIZE(vsock_connected_table); i++) {
+		vsock_vmci_sock *vsk;
+
+		list_for_each_entry(vsk, &vsock_connected_table[i],
+				    connected_table) {
+			struct sock *sk = sk_vsock(vsk);
+
+			/*
+			 * XXX Technically this is racy but the resulting
+			 * outcome from such a race is relatively harmless.  My
+			 * next change will be a fix to this.
+			 */
+			vsock_vmci_handle_detach(sk);
+		}
+	}
+
+	spin_unlock_bh(&vsock_table_lock);
+}
+
+/*
+ * vsock_vmci_pending_work --
+ *
+ * Releases the resources for a pending socket if it has not reached the
+ * connected state and been accepted by a user process.
+ *
+ * Results: None.
+ *
+ * Side effects: The socket may be removed from the connected list and all its
+ * resources freed.
+ */
+
+static void vsock_vmci_pending_work(struct work_struct *work)
+{
+	struct sock *sk;
+	struct sock *listener;
+	vsock_vmci_sock *vsk;
+	bool cleanup;
+
+	vsk = container_of(work, vsock_vmci_sock, dwork.work);
+	sk = sk_vsock(vsk);
+	listener = vsk->listener;
+	cleanup = true;
+
+	lock_sock(listener);
+	lock_sock(sk);
+
+	/*
+	 * The socket should be on the pending list or the accept queue, but
+	 * not both.  It's also possible that the socket isn't on either.
+	 */
+	ASSERT((vsock_vmci_is_pending(sk) && !vsock_vmci_in_accept_queue(sk))
+	       || (!vsock_vmci_is_pending(sk) && vsock_vmci_in_accept_queue(sk))
+	       || (!vsock_vmci_is_pending(sk)
+		   && !vsock_vmci_in_accept_queue(sk)));
+
+	if (vsock_vmci_is_pending(sk)) {
+		vsock_vmci_remove_pending(listener, sk);
+	} else if (!vsk->rejected) {
+		/*
+		 * We are not on the pending list and accept() did not reject
+		 * us, so we must have been accepted by our user process.  We
+		 * just need to drop our references to the sockets and be on
+		 * our way.
+		 */
+		cleanup = false;
+		goto out;
+	}
+
+	listener->sk_ack_backlog--;
+
+	/*
+	 * We need to remove ourself from the global connected sockets list so
+	 * incoming packets can't find this socket, and to reduce the reference
+	 * count.
+	 */
+	if (vsock_vmci_in_connected_table(sk))
+		vsock_vmci_remove_connected(sk);
+
+	sk->sk_state = SS_FREE;
+
+out:
+	release_sock(sk);
+	release_sock(listener);
+	if (cleanup)
+		sock_put(sk);
+
+	sock_put(sk);
+	sock_put(listener);
+}
+
+/*
+ * vsock_vmci_recv_pkt_work --
+ *
+ * Handles an incoming control packet for the provided socket.  This is the
+ * state machine for our stream sockets.
+ *
+ * Results: None.
+ *
+ * Side effects: May set state and wakeup threads waiting for socket state to
+ * change.
+ */
+
+static void vsock_vmci_recv_pkt_work(struct work_struct *work)
+{
+	vsock_recv_pkt_info *recv_pkt_info;
+	vsock_packet *pkt;
+	struct sock *sk;
+
+	recv_pkt_info = container_of(work, vsock_recv_pkt_info, work);
+	sk = recv_pkt_info->sk;
+	pkt = &recv_pkt_info->pkt;
+
+	ASSERT(pkt->type < VSOCK_PACKET_TYPE_MAX);
+
+	lock_sock(sk);
+
+	switch (sk->sk_state) {
+	case SS_LISTEN:
+		vsock_vmci_recv_listen(sk, pkt);
+		break;
+	case SS_CONNECTING:
+		/*
+		 * Processing of pending connections for servers goes through
+		 * the listening socket, so see vsock_vmci_recv_listen() for
+		 * that path.
+		 */
+		vsock_vmci_recv_connecting_client(sk, pkt);
+		break;
+	case SS_CONNECTED:
+		vsock_vmci_recv_connected(sk, pkt);
+		break;
+	default:
+		/*
+		 * Because this function does not run in the same context as
+		 * vsock_vmci_recv_stream_cb it is possible that the socket has
+		 * closed. We need to let the other side know or it could be
+		 * sitting in a connect and hang forever. Send a reset to
+		 * prevent that.
+		 */
+		VSOCK_SEND_RESET(sk, pkt);
+		goto out;
+	}
+
+out:
+	release_sock(sk);
+	kfree(recv_pkt_info);
+	/*
+	 * Release reference obtained in the stream callback when we fetched
+	 * this socket out of the bound or connected list.
+	 */
+	sock_put(sk);
+}
+
+/*
+ * vsock_vmci_recv_listen --
+ *
+ * Receives packets for sockets in the listen state.
+ *
+ * Note that this assumes the socket lock is held.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: A new socket may be created and a negotiate control packet is
+ * sent.
+ */
+
+static int vsock_vmci_recv_listen(struct sock *sk, vsock_packet *pkt)
+{
+	struct sock *pending;
+	vsock_vmci_sock *vpending;
+	int err;
+	u64 qp_size;
+	bool old_request = false;
+	bool old_pkt_proto = false;
+
+	ASSERT(sk->sk_state == SS_LISTEN);
+
+	err = 0;
+
+	/*
+	 * Because we are in the listen state, we could be receiving a packet
+	 * for ourself or any previous connection requests that we received.
+	 * If it's the latter, we try to find a socket in our list of pending
+	 * connections and, if we do, call the appropriate handler for the
+	 * state that that socket is in.  Otherwise we try to service the
+	 * connection request.
+	 */
+	pending = vsock_vmci_get_pending(sk, pkt);
+	if (pending) {
+		lock_sock(pending);
+		switch (pending->sk_state) {
+		case SS_CONNECTING:
+			err =
+			    vsock_vmci_recv_connecting_server(sk, pending, pkt);
+			break;
+		default:
+			VSOCK_SEND_RESET(pending, pkt);
+			err = -EINVAL;
+		}
+
+		if (err < 0)
+			vsock_vmci_remove_pending(sk, pending);
+
+		release_sock(pending);
+		vsock_vmci_release_pending(pending);
+
+		return err;
+	}
+
+	/*
+	 * The listen state only accepts connection requests.  Reply with a
+	 * reset unless we received a reset.
+	 */
+
+	if (!(pkt->type == VSOCK_PACKET_TYPE_REQUEST ||
+	      pkt->type == VSOCK_PACKET_TYPE_REQUEST2)) {
+		VSOCK_REPLY_RESET(pkt);
+		return -EINVAL;
+	}
+
+	if (pkt->u.size == 0) {
+		VSOCK_REPLY_RESET(pkt);
+		return -EINVAL;
+	}
+
+	/*
+	 * If this socket can't accommodate this connection request, we send a
+	 * reset.  Otherwise we create and initialize a child socket and reply
+	 * with a connection negotiation.
+	 */
+	if (sk->sk_ack_backlog >= sk->sk_max_ack_backlog) {
+		VSOCK_REPLY_RESET(pkt);
+		return -ECONNREFUSED;
+	}
+
+	pending = __vsock_vmci_create(sock_net(sk), NULL, sk, GFP_KERNEL,
+				      sk->sk_type);
+	if (!pending) {
+		VSOCK_SEND_RESET(sk, pkt);
+		return -ENOMEM;
+	}
+
+	vpending = vsock_sk(pending);
+	ASSERT(vsock_sk(sk)->local_addr.svm_port == pkt->dst_port);
+
+	vsock_addr_init(&vpending->local_addr,
+			VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.dst), pkt->dst_port);
+	vsock_addr_init(&vpending->remote_addr,
+			VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.src), pkt->src_port);
+
+	/*
+	 * If the proposed size fits within our min/max, accept it. Otherwise
+	 * propose our own size.
+	 */
+	if (pkt->u.size >= vpending->queue_pair_min_size &&
+	    pkt->u.size <= vpending->queue_pair_max_size) {
+		qp_size = pkt->u.size;
+	} else {
+		qp_size = vpending->queue_pair_size;
+	}
+
+	/*
+	 * Figure out if we are using old or new requests based on the
+	 * overrides pkt types sent by our peer.
+	 */
+	if (vsock_vmci_old_proto_override(&old_pkt_proto)) {
+		old_request = old_pkt_proto;
+	} else {
+		if (pkt->type == VSOCK_PACKET_TYPE_REQUEST)
+			old_request = true;
+		else if (pkt->type == VSOCK_PACKET_TYPE_REQUEST2)
+			old_request = false;
+
+	}
+
+	if (old_request) {
+		/* Handle a REQUEST (or override) */
+		vsock_proto_version version = VSOCK_PROTO_INVALID;
+		if (vsock_vmci_proto_to_notify_struct(pending, &version, true))
+			err = VSOCK_SEND_NEGOTIATE(pending, qp_size);
+		else
+			err = -EINVAL;
+
+	} else {
+		/* Handle a REQUEST2 (or override) */
+		int proto_int = pkt->proto;
+		int pos;
+		u16 active_proto_version = 0;
+
+		/*
+		 * The list of possible protocols is the intersection of all
+		 * protocols the client supports ... plus all the protocols we
+		 * support.
+		 */
+		proto_int &= vsock_vmci_new_proto_supported_versions();
+
+		/* We choose the highest possible protocol version and use that
+		 * one. */
+		pos = fls(proto_int);
+		if (pos) {
+			active_proto_version = (1 << (pos - 1));
+			if (vsock_vmci_proto_to_notify_struct
+			    (pending, &active_proto_version, false))
+				err =
+				    VSOCK_SEND_NEGOTIATE2(pending, qp_size,
+							  active_proto_version);
+			else
+				err = -EINVAL;
+
+		} else {
+			err = -EINVAL;
+		}
+	}
+
+	if (err < 0) {
+		VSOCK_SEND_RESET(sk, pkt);
+		sock_put(pending);
+		err = vsock_vmci_error_to_vsock_error(err);
+		goto out;
+	}
+
+	vsock_vmci_add_pending(sk, pending);
+	sk->sk_ack_backlog++;
+
+	pending->sk_state = SS_CONNECTING;
+	vpending->produce_size = vpending->consume_size = qp_size;
+	vpending->queue_pair_size = qp_size;
+
+	NOTIFYCALL(vpending, process_request, pending);
+
+	/*
+	 * We might never receive another message for this socket and it's not
+	 * connected to any process, so we have to ensure it gets cleaned up
+	 * ourself.  Our delayed work function will take care of that.  Note
+	 * that we do not ever cancel this function since we have few
+	 * guarantees about its state when calling cancel_delayed_work().
+	 * Instead we hold a reference on the socket for that function and make
+	 * it capable of handling cases where it needs to do nothing but
+	 * release that reference.
+	 */
+	vpending->listener = sk;
+	sock_hold(sk);
+	sock_hold(pending);
+	INIT_DELAYED_WORK(&vpending->dwork, vsock_vmci_pending_work);
+	schedule_delayed_work(&vpending->dwork, HZ);
+
+out:
+	return err;
+}
+
+/*
+ * vsock_vmci_recv_connecting_server --
+ *
+ * Receives packets for sockets in the connecting state on the server side.
+ *
+ * Connecting sockets on the server side can only receive queue pair offer
+ * packets.  All others should be treated as cause for closing the connection.
+ *
+ * Note that this assumes the socket lock is held for both sk and pending.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: A queue pair may be created, an attach control packet may be
+ * sent, the socket may transition to the connected state, and a pending caller
+ * in accept() may be woken up.
+ */
+
+static int
+vsock_vmci_recv_connecting_server(struct sock *listener,
+				  struct sock *pending, vsock_packet *pkt)
+{
+	vsock_vmci_sock *vpending;
+	struct vmci_handle handle;
+	struct vmci_qp *qpair;
+	bool is_local;
+	u32 flags;
+	vmci_id detach_sub_id;
+	int err;
+	int skerr;
+
+	ASSERT(listener->sk_state == SS_LISTEN);
+	ASSERT(pending->sk_state == SS_CONNECTING);
+
+	vpending = vsock_sk(pending);
+	detach_sub_id = VMCI_INVALID_ID;
+
+	switch (pkt->type) {
+	case VSOCK_PACKET_TYPE_OFFER:
+		if (VMCI_HANDLE_INVALID(pkt->u.handle)) {
+			VSOCK_SEND_RESET(pending, pkt);
+			skerr = EPROTO;
+			err = -EINVAL;
+			goto destroy;
+		}
+		break;
+	default:
+		/* Close and cleanup the connection. */
+		VSOCK_SEND_RESET(pending, pkt);
+		skerr = EPROTO;
+		err = pkt->type == VSOCK_PACKET_TYPE_RST ? 0 : -EINVAL;
+		goto destroy;
+	}
+
+	ASSERT(pkt->type == VSOCK_PACKET_TYPE_OFFER);
+
+	/*
+	 * In order to complete the connection we need to attach to the offered
+	 * queue pair and send an attach notification.  We also subscribe to the
+	 * detach event so we know when our peer goes away, and we do that
+	 * before attaching so we don't miss an event.  If all this succeeds,
+	 * we update our state and wakeup anything waiting in accept() for a
+	 * connection.
+	 */
+
+	/*
+	 * We don't care about attach since we ensure the other side has
+	 * attached by specifying the ATTACH_ONLY flag below.
+	 */
+	err = vmci_event_subscribe(VMCI_EVENT_QP_PEER_DETACH,
+				   vsock_vmci_peer_detach_cb,
+				   pending, &detach_sub_id);
+	if (err < VMCI_SUCCESS) {
+		VSOCK_SEND_RESET(pending, pkt);
+		err = vsock_vmci_error_to_vsock_error(err);
+		skerr = -err;
+		goto destroy;
+	}
+
+	vpending->detach_sub_id = detach_sub_id;
+
+	/* Now attach to the queue pair the client created. */
+	handle = pkt->u.handle;
+
+	/*
+	 * vpending->local_addr always has a context id so we do not need to
+	 * worry about VMADDR_CID_ANY in this case.
+	 */
+	is_local =
+	    vpending->remote_addr.svm_cid == vpending->local_addr.svm_cid;
+	flags = VMCI_QPFLAG_ATTACH_ONLY;
+	flags |= is_local ? VMCI_QPFLAG_LOCAL : 0;
+
+	err = vsock_vmci_queue_pair_alloc(&qpair,
+					  &handle,
+					  vpending->produce_size,
+					  vpending->consume_size,
+					  VMCI_HANDLE_TO_CONTEXT_ID(pkt->
+								    dg.src),
+					  flags,
+					  vsock_vmci_trusted(
+						vpending,
+						vpending->remote_addr.svm_cid));
+	if (err < 0) {
+		VSOCK_SEND_RESET(pending, pkt);
+		skerr = -err;
+		goto destroy;
+	}
+
+	ASSERT(VMCI_HANDLE_EQUAL(handle, pkt->u.handle));
+	vpending->qp_handle = handle;
+	vpending->qpair = qpair;
+
+	/*
+	 * When we send the attach message, we must be ready to handle incoming
+	 * control messages on the newly connected socket. So we move the
+	 * pending socket to the connected state before sending the attach
+	 * message. Otherwise, an incoming packet triggered by the attach being
+	 * received by the peer may be processed concurrently with what happens
+	 * below after sending the attach message, and that incoming packet
+	 * will find the listening socket instead of the (currently) pending
+	 * socket. Note that enqueueing the socket increments the reference
+	 * count, so even if a reset comes before the connection is accepted,
+	 * the socket will be valid until it is removed from the queue.
+	 *
+	 * If we fail sending the attach below, we remove the socket from the
+	 * connected list and move the socket to SS_UNCONNECTED before
+	 * releasing the lock, so a pending slow path processing of an incoming
+	 * packet will not see the socket in the connected state in that case.
+	 */
+	pending->sk_state = SS_CONNECTED;
+
+	vsock_vmci_insert_connected(vsock_connected_sockets_vsk(vpending),
+				    pending);
+
+	/* Notify our peer of our attach. */
+	err = VSOCK_SEND_ATTACH(pending, handle);
+	if (err < 0) {
+		vsock_vmci_remove_connected(pending);
+		pr_err("Could not send attach\n");
+		VSOCK_SEND_RESET(pending, pkt);
+		err = vsock_vmci_error_to_vsock_error(err);
+		skerr = -err;
+		goto destroy;
+	}
+
+	/*
+	 * We have a connection. Move the now connected socket from the
+	 * listener's pending list to the accept queue so callers of accept()
+	 * can find it.
+	 */
+	vsock_vmci_remove_pending(listener, pending);
+	vsock_vmci_enqueue_accept(listener, pending);
+
+	/*
+	 * Callers of accept() will be be waiting on the listening socket, not
+	 * the pending socket.
+	 */
+	listener->sk_state_change(listener);
+
+	return 0;
+
+destroy:
+	pending->sk_err = skerr;
+	pending->sk_state = SS_UNCONNECTED;
+	/*
+	 * As long as we drop our reference, all necessary cleanup will handle
+	 * when the cleanup function drops its reference and our destruct
+	 * implementation is called.  Note that since the listen handler will
+	 * remove pending from the pending list upon our failure, the cleanup
+	 * function won't drop the additional reference, which is why we do it
+	 * here.
+	 */
+	sock_put(pending);
+
+	return err;
+}
+
+/*
+ * vsock_vmci_recv_connecting_client --
+ *
+ * Receives packets for sockets in the connecting state on the client side.
+ *
+ * Connecting sockets on the client side should only receive attach packets.
+ * All others should be treated as cause for closing the connection.
+ *
+ * Note that this assumes the socket lock is held for both sk and pending.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: The socket may transition to the connected state and wakeup
+ * the pending caller of connect().
+ */
+
+static int
+vsock_vmci_recv_connecting_client(struct sock *sk, vsock_packet *pkt)
+{
+	vsock_vmci_sock *vsk;
+	int err;
+	int skerr;
+
+	ASSERT(sk->sk_state == SS_CONNECTING);
+
+	vsk = vsock_sk(sk);
+
+	switch (pkt->type) {
+	case VSOCK_PACKET_TYPE_ATTACH:
+		if (VMCI_HANDLE_INVALID(pkt->u.handle) ||
+		    !VMCI_HANDLE_EQUAL(pkt->u.handle, vsk->qp_handle)) {
+			skerr = EPROTO;
+			err = -EINVAL;
+			goto destroy;
+		}
+
+		/*
+		 * Signify the socket is connected and wakeup the waiter in
+		 * connect(). Also place the socket in the connected table for
+		 * accounting (it can already be found since it's in the bound
+		 * table).
+		 */
+		sk->sk_state = SS_CONNECTED;
+		sk->sk_socket->state = SS_CONNECTED;
+		vsock_vmci_insert_connected(vsock_connected_sockets_vsk(vsk),
+					    sk);
+		sk->sk_state_change(sk);
+
+		break;
+	case VSOCK_PACKET_TYPE_NEGOTIATE:
+	case VSOCK_PACKET_TYPE_NEGOTIATE2:
+		if (pkt->u.size == 0 ||
+		    VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.src) !=
+		    vsk->remote_addr.svm_cid
+		    || pkt->src_port != vsk->remote_addr.svm_port
+		    || !VMCI_HANDLE_INVALID(vsk->qp_handle) || vsk->qpair
+		    || vsk->produce_size != 0 || vsk->consume_size != 0
+		    || vsk->attach_sub_id != VMCI_INVALID_ID
+		    || vsk->detach_sub_id != VMCI_INVALID_ID) {
+			skerr = EPROTO;
+			err = -EINVAL;
+
+			goto destroy;
+		}
+
+		err = vsock_vmci_recv_connecting_client_negotiate(sk, pkt);
+		if (err) {
+			skerr = -err;
+			goto destroy;
+		}
+
+		break;
+	case VSOCK_PACKET_TYPE_INVALID:
+		err = vsock_vmci_recv_connecting_client_invalid(sk, pkt);
+		if (err) {
+			skerr = -err;
+			goto destroy;
+		}
+
+		break;
+	case VSOCK_PACKET_TYPE_RST:
+		/*
+		 * Older versions of the linux code (WS 6.5 / ESX 4.0) used to
+		 * continue processing here after they sent an INVALID packet.
+		 * This meant that we got a RST after the INVALID. We ignore a
+		 * RST after an INVALID. The common code doesn't send the RST
+		 * ... so we can hang if an old version of the common code
+		 * fails between getting a REQUEST and sending an OFFER back.
+		 * Not much we can do about it... except hope that it doesn't
+		 * happen.
+		 */
+		if (vsk->ignore_connecting_rst) {
+			vsk->ignore_connecting_rst = false;
+		} else {
+			skerr = ECONNRESET;
+			err = 0;
+			goto destroy;
+		}
+
+		break;
+	default:
+		/* Close and cleanup the connection. */
+		skerr = EPROTO;
+		err = -EINVAL;
+		goto destroy;
+	}
+
+	ASSERT(pkt->type == VSOCK_PACKET_TYPE_ATTACH ||
+	       pkt->type == VSOCK_PACKET_TYPE_NEGOTIATE ||
+	       pkt->type == VSOCK_PACKET_TYPE_NEGOTIATE2 ||
+	       pkt->type == VSOCK_PACKET_TYPE_INVALID ||
+	       pkt->type == VSOCK_PACKET_TYPE_RST);
+
+	return 0;
+
+destroy:
+	VSOCK_SEND_RESET(sk, pkt);
+
+	sk->sk_state = SS_UNCONNECTED;
+	sk->sk_err = skerr;
+	sk->sk_error_report(sk);
+	return err;
+}
+
+/*
+ * vsock_vmci_recv_connecting_client_negotiate --
+ *
+ * Handles a negotiate packet for a client in the connecting state.
+ *
+ * Note that this assumes the socket lock is held for both sk and pending.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: The socket may transition to the connected state and wakeup
+ * the pending caller of connect().
+ */
+
+static int
+vsock_vmci_recv_connecting_client_negotiate(struct sock *sk, vsock_packet *pkt)
+{
+	int err;
+	vsock_vmci_sock *vsk;
+	struct vmci_handle handle;
+	struct vmci_qp *qpair;
+	vmci_id attach_sub_id;
+	vmci_id detach_sub_id;
+	bool is_local;
+	u32 flags;
+	bool old_proto = true;
+	bool old_pkt_proto;
+	vsock_proto_version version;
+
+	vsk = vsock_sk(sk);
+	handle = VMCI_INVALID_HANDLE;
+	attach_sub_id = VMCI_INVALID_ID;
+	detach_sub_id = VMCI_INVALID_ID;
+
+	ASSERT(pkt->u.size > 0);
+	ASSERT(vsk->remote_addr.svm_cid ==
+	       VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.src));
+	ASSERT(vsk->remote_addr.svm_port == pkt->src_port);
+	ASSERT(VMCI_HANDLE_INVALID(vsk->qp_handle));
+	ASSERT(vsk->qpair == NULL);
+	ASSERT(vsk->produce_size == 0);
+	ASSERT(vsk->consume_size == 0);
+	ASSERT(vsk->attach_sub_id == VMCI_INVALID_ID);
+	ASSERT(vsk->detach_sub_id == VMCI_INVALID_ID);
+
+	/*
+	 * If we have gotten here then we should be past the point where old
+	 * linux vsock could have sent the bogus rst.
+	 */
+	vsk->sent_request = false;
+	vsk->ignore_connecting_rst = false;
+
+	/* Verify that we're OK with the proposed queue pair size */
+	if (pkt->u.size < vsk->queue_pair_min_size ||
+	    pkt->u.size > vsk->queue_pair_max_size) {
+		err = -EINVAL;
+		goto destroy;
+	}
+
+	/*
+	 * At this point we know the CID the peer is using to talk to us.
+	 */
+
+	if (vsk->local_addr.svm_cid == VMADDR_CID_ANY)
+		vsk->local_addr.svm_cid =
+		    VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.dst);
+
+	/*
+	 * Setup the notify ops to be the highest supported version that both
+	 * the server and the client support.
+	 */
+
+	if (vsock_vmci_old_proto_override(&old_pkt_proto)) {
+		old_proto = old_pkt_proto;
+	} else {
+		if (pkt->type == VSOCK_PACKET_TYPE_NEGOTIATE)
+			old_proto = true;
+		else if (pkt->type == VSOCK_PACKET_TYPE_NEGOTIATE2)
+			old_proto = false;
+
+	}
+
+	if (old_proto)
+		version = VSOCK_PROTO_INVALID;
+	else
+		version = pkt->proto;
+
+	if (!vsock_vmci_proto_to_notify_struct(sk, &version, old_proto)) {
+		err = -EINVAL;
+		goto destroy;
+	}
+
+	/*
+	 * Subscribe to attach and detach events first.
+	 *
+	 * XXX We attach once for each queue pair created for now so it is easy
+	 * to find the socket (it's provided), but later we should only
+	 * subscribe once and add a way to lookup sockets by queue pair handle.
+	 */
+	err = vmci_event_subscribe(VMCI_EVENT_QP_PEER_ATTACH,
+				   vsock_vmci_peer_attach_cb,
+				   sk, &attach_sub_id);
+	if (err < VMCI_SUCCESS) {
+		err = vsock_vmci_error_to_vsock_error(err);
+		goto destroy;
+	}
+
+	err = vmci_event_subscribe(VMCI_EVENT_QP_PEER_DETACH,
+				   vsock_vmci_peer_detach_cb,
+				   sk, &detach_sub_id);
+	if (err < VMCI_SUCCESS) {
+		err = vsock_vmci_error_to_vsock_error(err);
+		goto destroy;
+	}
+
+	/* Make VMCI select the handle for us. */
+	handle = VMCI_INVALID_HANDLE;
+	is_local = vsk->remote_addr.svm_cid == vsk->local_addr.svm_cid;
+	flags = is_local ? VMCI_QPFLAG_LOCAL : 0;
+
+	err = vsock_vmci_queue_pair_alloc(&qpair,
+					  &handle,
+					  pkt->u.size,
+					  pkt->u.size,
+					  vsk->remote_addr.svm_cid,
+					  flags,
+					  vsock_vmci_trusted(
+						  vsk,
+						  vsk->
+						  remote_addr.svm_cid));
+	if (err < 0)
+		goto destroy;
+
+	err = VSOCK_SEND_QP_OFFER(sk, handle);
+	if (err < 0) {
+		err = vsock_vmci_error_to_vsock_error(err);
+		goto destroy;
+	}
+
+	vsk->qp_handle = handle;
+	vsk->qpair = qpair;
+
+	vsk->produce_size = vsk->consume_size = pkt->u.size;
+
+	vsk->attach_sub_id = attach_sub_id;
+	vsk->detach_sub_id = detach_sub_id;
+
+	NOTIFYCALL(vsk, process_negotiate, sk);
+
+	return 0;
+
+destroy:
+	if (attach_sub_id != VMCI_INVALID_ID) {
+		vmci_event_unsubscribe(attach_sub_id);
+		ASSERT(vsk->attach_sub_id == VMCI_INVALID_ID);
+	}
+
+	if (detach_sub_id != VMCI_INVALID_ID) {
+		vmci_event_unsubscribe(detach_sub_id);
+		ASSERT(vsk->detach_sub_id == VMCI_INVALID_ID);
+	}
+
+	if (!VMCI_HANDLE_INVALID(handle)) {
+		vmci_qpair_detach(&qpair);
+		ASSERT(VMCI_HANDLE_INVALID(vsk->qp_handle));
+	}
+
+	return err;
+}
+
+/*
+ * vsock_vmci_recv_connecting_client_invalid --
+ *
+ * Handles an invalid packet for a client in the connecting state.
+ *
+ * Note that this assumes the socket lock is held for both sk and pending.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_recv_connecting_client_invalid(struct sock *sk, vsock_packet *pkt)
+{
+	int err = 0;
+	vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	if (vsk->sent_request) {
+		vsk->sent_request = false;
+		vsk->ignore_connecting_rst = true;
+
+		err = VSOCK_SEND_CONN_REQUEST(sk, vsk->queue_pair_size);
+		if (err < 0)
+			err = vsock_vmci_error_to_vsock_error(err);
+		else
+			err = 0;
+
+	}
+
+	return err;
+}
+
+/*
+ * vsock_vmci_recv_connected --
+ *
+ * Receives packets for sockets in the connected state.
+ *
+ * Connected sockets should only ever receive detach, wrote, read, or reset
+ * control messages.  Others are treated as errors that are ignored.
+ *
+ * Wrote and read signify that the peer has produced or consumed, respectively.
+ *
+ * Detach messages signify that the connection is being closed cleanly and
+ * reset messages signify that the connection is being closed in error.
+ *
+ * Note that this assumes the socket lock is held.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: A queue pair may be created, an offer control packet sent, and
+ * the socket may transition to the connecting state.
+ *
+ */
+
+static int vsock_vmci_recv_connected(struct sock *sk, vsock_packet *pkt)
+{
+	vsock_vmci_sock *vsk;
+	bool pkt_processed = false;
+
+	ASSERT(sk->sk_state == SS_CONNECTED);
+
+	/*
+	 * In cases where we are closing the connection, it's sufficient to
+	 * mark the state change (and maybe error) and wake up any waiting
+	 * threads. Since this is a connected socket, it's owned by a user
+	 * process and will be cleaned up when the failure is passed back on
+	 * the current or next system call.  Our system call implementations
+	 * must therefore check for error and state changes on entry and when
+	 * being awoken.
+	 */
+	switch (pkt->type) {
+	case VSOCK_PACKET_TYPE_SHUTDOWN:
+		if (pkt->u.mode) {
+			vsk = vsock_sk(sk);
+
+			vsk->peer_shutdown |= pkt->u.mode;
+			sk->sk_state_change(sk);
+		}
+		break;
+
+	case VSOCK_PACKET_TYPE_RST:
+		vsk = vsock_sk(sk);
+		/*
+		 * It is possible that we sent our peer a message (e.g a
+		 * WAITING_READ) right before we got notified that the peer had
+		 * detached. If that happens then we can get a RST pkt back
+		 * from our peer even though there is data available for us to
+		 * read. In that case, don't shutdown the socket completely but
+		 * instead allow the local client to finish reading data off
+		 * the queuepair. Always treat a RST pkt in connected mode like
+		 * a clean shutdown.
+		 */
+		sock_set_flag(sk, SOCK_DONE);
+		vsk->peer_shutdown = SHUTDOWN_MASK;
+		if (vsock_vmci_stream_has_data(vsk) <= 0)
+			sk->sk_state = SS_DISCONNECTING;
+
+		sk->sk_state_change(sk);
+		break;
+
+	default:
+		vsk = vsock_sk(sk);
+		NOTIFYCALL(vsk, handle_notify_pkt, sk, pkt, false, NULL, NULL,
+			   &pkt_processed);
+		if (!pkt_processed)
+			return -EINVAL;
+
+		break;
+	}
+
+	return 0;
+}
+
+/*
+ * __vsock_vmci_send_control_pkt --
+ *
+ * Common code to send a control packet.
+ *
+ * Results: Size of datagram sent on success, negative error code otherwise. If
+ * convert_error is true, error code is a vsock error, otherwise, result is a
+ * VMCI error code.
+ *
+ * Side effects: None.
+ */
+
+static int
+__vsock_vmci_send_control_pkt(vsock_packet *pkt,
+			      struct sockaddr_vm *src,
+			      struct sockaddr_vm *dst,
+			      vsock_packet_type type,
+			      u64 size,
+			      u64 mode,
+			      vsock_waiting_info *wait,
+			      vsock_proto_version proto,
+			      struct vmci_handle handle, bool convert_error)
+{
+	int err;
+
+	BUG_ON(vsock_addr_validate(src) != 0);
+	BUG_ON(vsock_addr_validate(dst) != 0);
+
+	vsock_packet_init(pkt, src, dst, type, size, mode, wait, proto, handle);
+	LOG_PACKET(pkt);
+	VSOCK_STATS_CTLPKT_LOG(pkt->type);
+	err = vmci_datagram_send(&pkt->dg);
+	if (convert_error && (err < 0))
+		return vsock_vmci_error_to_vsock_error(err);
+
+	return err;
+}
+
+/*
+ * vsock_vmci_reply_control_pkt_fast --
+ *
+ * Sends a control packet back to the source of an incoming packet. The control
+ * packet is allocated in the stack.
+ *
+ * Results: Size of datagram sent on success, negative error code otherwise.
+ *
+ * Side effects: None.
+ */
+
+int
+vsock_vmci_reply_control_pkt_fast(vsock_packet *pkt,
+				  vsock_packet_type type,
+				  u64 size,
+				  u64 mode,
+				  vsock_waiting_info *wait,
+				  struct vmci_handle handle)
+{
+	vsock_packet reply;
+	struct sockaddr_vm src, dst;
+
+	if (pkt->type == VSOCK_PACKET_TYPE_RST) {
+		return 0;
+	} else {
+		vsock_packet_get_addresses(pkt, &src, &dst);
+		return __vsock_vmci_send_control_pkt(&reply, &src, &dst, type,
+						     size, mode, wait,
+						     VSOCK_PROTO_INVALID,
+						     handle, true);
+	}
+}
+
+/*
+ * vsock_vmci_send_control_pkt_bh --
+ *
+ * Sends a control packet from bottom-half context. The control packet is
+ * static data to minimize the resource cost.
+ *
+ * Results: Size of datagram sent on success, negative error code otherwise.
+ * Note that we return a VMCI error message since that's what callers will need
+ * to provide.
+ *
+ * Side effects: None.
+ */
+
+int
+vsock_vmci_send_control_pkt_bh(struct sockaddr_vm *src,
+			       struct sockaddr_vm *dst,
+			       vsock_packet_type type,
+			       u64 size,
+			       u64 mode,
+			       vsock_waiting_info *wait,
+			       struct vmci_handle handle)
+{
+	/*
+	 * Note that it is safe to use a single packet across all CPUs since
+	 * two tasklets of the same type are guaranteed to not ever run
+	 * simultaneously. If that ever changes, or VMCI stops using tasklets,
+	 * we can use per-cpu packets.
+	 */
+	static vsock_packet pkt;
+
+	return __vsock_vmci_send_control_pkt(&pkt, src, dst, type,
+					     size, mode, wait,
+					     VSOCK_PROTO_INVALID, handle,
+					     false);
+}
+
+/*
+ * vsock_vmci_send_control_pkt --
+ *
+ * Sends a control packet.
+ *
+ * Results: Size of datagram sent on success, negative error on failure.
+ *
+ * Side effects: None.
+ */
+
+int
+vsock_vmci_send_control_pkt(struct sock *sk,
+			    vsock_packet_type type,
+			    u64 size,
+			    u64 mode,
+			    vsock_waiting_info *wait,
+			    vsock_proto_version proto,
+			    struct vmci_handle handle)
+{
+	vsock_packet *pkt;
+	vsock_vmci_sock *vsk;
+	int err;
+
+	vsk = vsock_sk(sk);
+
+	if (!vsock_addr_bound(&vsk->local_addr))
+		return -EINVAL;
+
+	if (!vsock_addr_bound(&vsk->remote_addr))
+		return -EINVAL;
+
+	pkt = kmalloc(sizeof *pkt, GFP_KERNEL);
+	if (!pkt)
+		return -ENOMEM;
+
+	err =
+	    __vsock_vmci_send_control_pkt(pkt, &vsk->local_addr,
+					  &vsk->remote_addr, type, size, mode,
+					  wait, proto, handle, true);
+	kfree(pkt);
+
+	return err;
+}
+
+/*
+ * __vsock_vmci_bind --
+ *
+ * Common functionality needed to bind the specified address to the VSocket.
+ * If VMADDR_CID_ANY or VMADDR_PORT_ANY are specified, the context ID or port
+ * are selected automatically.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: On success, a new datagram handle is created.
+ */
+
+static int __vsock_vmci_bind(struct sock *sk, struct sockaddr_vm *addr)
+{
+	static unsigned int port = LAST_RESERVED_PORT + 1;
+	struct sockaddr_vm new_addr;
+	vsock_vmci_sock *vsk;
+	vmci_id cid;
+	int err;
+
+	vsk = vsock_sk(sk);
+
+	/* First ensure this socket isn't already bound. */
+	if (vsock_addr_bound(&vsk->local_addr))
+		return -EINVAL;
+
+	/*
+	 * Now bind to the provided address or select appropriate values if
+	 * none are provided (VMADDR_CID_ANY and VMADDR_PORT_ANY).  Note that
+	 * like AF_INET prevents binding to a non-local IP address (in most
+	 * cases), we only allow binding to the local CID.
+	 */
+	vsock_addr_init(&new_addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
+
+	cid = vmci_get_context_id();
+	if (addr->svm_cid != cid && addr->svm_cid != VMADDR_CID_ANY)
+		return -EADDRNOTAVAIL;
+
+	new_addr.svm_cid = addr->svm_cid;
+
+	switch (sk->sk_socket->type) {
+	case SOCK_STREAM:
+		spin_lock_bh(&vsock_table_lock);
+
+		if (addr->svm_port == VMADDR_PORT_ANY) {
+			bool found = false;
+			unsigned int i;
+
+			for (i = 0; i < MAX_PORT_RETRIES; i++) {
+				if (port <= LAST_RESERVED_PORT)
+					port = LAST_RESERVED_PORT + 1;
+
+				new_addr.svm_port = port++;
+
+				if (!__vsock_vmci_find_bound_socket
+				    (&new_addr)) {
+					found = true;
+					break;
+				}
+			}
+
+			if (!found) {
+				err = -EADDRNOTAVAIL;
+				goto out;
+			}
+		} else {
+			/*
+			 * If port is in reserved range, ensure caller
+			 * has necessary privileges.
+			 */
+			if (addr->svm_port <= LAST_RESERVED_PORT &&
+			    !capable(CAP_NET_BIND_SERVICE)) {
+				err = -EACCES;
+				goto out;
+			}
+
+			new_addr.svm_port = addr->svm_port;
+			if (__vsock_vmci_find_bound_socket(&new_addr)) {
+				err = -EADDRINUSE;
+				goto out;
+			}
+
+		}
+		break;
+	case SOCK_DGRAM: {
+		u32 flags = 0;
+
+		/*
+		 * VMCI will select a resource ID for us if we provide
+		 * VMCI_INVALID_ID.i
+		 */
+		new_addr.svm_port = addr->svm_port == VMADDR_PORT_ANY ?
+		    VMCI_INVALID_ID : addr->svm_port;
+
+		if (new_addr.svm_port <= LAST_RESERVED_PORT &&
+		    !capable(CAP_NET_BIND_SERVICE)) {
+			err = -EACCES;
+			goto out;
+		}
+
+		if (new_addr.svm_cid == VMADDR_CID_ANY)
+			flags = VMCI_FLAG_ANYCID_DG_HND;
+
+		err = vsock_vmci_datagram_create_hnd(new_addr.svm_port,
+						   flags,
+						   vsock_vmci_recv_dgram_cb,
+						   sk, &vsk->dg_handle);
+		if (err < VMCI_SUCCESS) {
+			err = vsock_vmci_error_to_vsock_error(err);
+			goto out;
+		}
+
+		new_addr.svm_port = VMCI_HANDLE_TO_RESOURCE_ID(vsk->dg_handle);
+		break;
+	}
+	default:
+		err = -EINVAL;
+		goto out;
+	}
+
+	vsock_addr_init(&vsk->local_addr, new_addr.svm_cid, new_addr.svm_port);
+
+	/*
+	 * Remove stream sockets from the unbound list and add them to the hash
+	 * table for easy lookup by its address.  The unbound list is simply an
+	 * extra entry at the end of the hash table, a trick used by AF_UNIX.
+	 */
+	if (sk->sk_socket->type == SOCK_STREAM) {
+		__vsock_vmci_remove_bound(sk);
+		__vsock_vmci_insert_bound(vsock_bound_sockets(&vsk->local_addr),
+					  sk);
+		spin_unlock_bh(&vsock_table_lock);
+	}
+
+	BUG_ON(vsock_addr_validate(&vsk->local_addr) != 0);
+	return 0;
+
+out:
+	if (sk->sk_socket->type == SOCK_STREAM)
+		spin_unlock_bh(&vsock_table_lock);
+
+	return err;
+}
+
+/*
+ * __vsock_vmci_create --
+ *
+ * Does the work to create the sock structure. Note: If sock is NULL then the
+ * type field must be non-zero. Otherwise, sock is non-NULL and the type of
+ * sock is used in the newly created socket.
+ *
+ * Results: sock structure on success, NULL on failure.
+ *
+ * Side effects: Allocated sk is added to the unbound sockets list iff it is
+ * owned by a struct socket.
+ */
+
+static struct sock *__vsock_vmci_create(struct net *net,
+					struct socket *sock,
+					struct sock *parent,
+					gfp_t priority, unsigned short type)
+{
+	struct sock *sk;
+	vsock_vmci_sock *psk;
+	vsock_vmci_sock *vsk;
+
+	ASSERT((sock && !type) || (!sock && type));
+
+	vsk = NULL;
+
+	sk = sk_alloc(net, vsock_vmci_family_ops.family, priority,
+		      &vsock_vmci_proto);
+	if (!sk)
+		return NULL;
+
+	sock_init_data(sock, sk);
+
+	/*
+	 * sk->sk_type is normally set in sock_init_data, but only if sock is
+	 * non-NULL. We make sure that our sockets always have a type by
+	 * setting it here if needed.
+	 */
+	if (!sock)
+		sk->sk_type = type;
+
+	vsk = vsock_sk(sk);
+	vsock_addr_init(&vsk->local_addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
+	vsock_addr_init(&vsk->remote_addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
+
+	sk->sk_destruct = vsock_vmci_sk_destruct;
+	sk->sk_backlog_rcv = vsock_vmci_queue_rcv_skb;
+	sk->sk_state = 0;
+	sock_reset_flag(sk, SOCK_DONE);
+
+	INIT_LIST_HEAD(&vsk->bound_table);
+	INIT_LIST_HEAD(&vsk->connected_table);
+	vsk->dg_handle = VMCI_INVALID_HANDLE;
+	vsk->qp_handle = VMCI_INVALID_HANDLE;
+	vsk->qpair = NULL;
+	vsk->produce_size = vsk->consume_size = 0;
+	vsk->listener = NULL;
+	INIT_LIST_HEAD(&vsk->pending_links);
+	INIT_LIST_HEAD(&vsk->accept_queue);
+	vsk->rejected = false;
+	vsk->sent_request = false;
+	vsk->ignore_connecting_rst = false;
+	vsk->attach_sub_id = vsk->detach_sub_id = VMCI_INVALID_ID;
+	vsk->peer_shutdown = 0;
+
+	if (parent) {
+		psk = vsock_sk(parent);
+		vsk->trusted = psk->trusted;
+		vsk->owner = get_cred(psk->owner);
+		vsk->queue_pair_size = psk->queue_pair_size;
+		vsk->queue_pair_min_size = psk->queue_pair_min_size;
+		vsk->queue_pair_max_size = psk->queue_pair_max_size;
+		vsk->connect_timeout = psk->connect_timeout;
+	} else {
+		vsk->trusted = capable(CAP_NET_ADMIN);
+		vsk->owner = get_current_cred();
+		vsk->queue_pair_size = VSOCK_DEFAULT_QP_SIZE;
+		vsk->queue_pair_min_size = VSOCK_DEFAULT_QP_SIZE_MIN;
+		vsk->queue_pair_max_size = VSOCK_DEFAULT_QP_SIZE_MAX;
+		vsk->connect_timeout = VSOCK_DEFAULT_CONNECT_TIMEOUT;
+	}
+
+	vsk->notify_ops = NULL;
+
+	if (sock)
+		vsock_vmci_insert_bound(vsock_unbound_sockets, sk);
+
+	return sk;
+}
+
+/*
+ * __vsock_vmci_release --
+ *
+ * Releases the provided socket.
+ *
+ * Results: None.
+ *
+ * Side effects: Any pending sockets are also released.
+ */
+
+static void __vsock_vmci_release(struct sock *sk)
+{
+	if (sk) {
+		struct sk_buff *skb;
+		struct sock *pending;
+		struct vsock_vmci_sock *vsk;
+
+		vsk = vsock_sk(sk);
+		pending = NULL;	/* Compiler warning. */
+
+		if (vsock_vmci_in_bound_table(sk))
+			vsock_vmci_remove_bound(sk);
+
+		if (vsock_vmci_in_connected_table(sk))
+			vsock_vmci_remove_connected(sk);
+
+		if (!VMCI_HANDLE_INVALID(vsk->dg_handle)) {
+			vmci_datagram_destroy_handle(vsk->dg_handle);
+			vsk->dg_handle = VMCI_INVALID_HANDLE;
+		}
+
+		lock_sock(sk);
+		sock_orphan(sk);
+		sk->sk_shutdown = SHUTDOWN_MASK;
+
+		while ((skb = skb_dequeue(&sk->sk_receive_queue)))
+			kfree_skb(skb);
+
+		/* Clean up any sockets that never were accepted. */
+		while ((pending = vsock_vmci_dequeue_accept(sk)) != NULL) {
+			__vsock_vmci_release(pending);
+			sock_put(pending);
+		}
+
+		release_sock(sk);
+		sock_put(sk);
+	}
+}
+
+/*
+ * Sock operations.
+ */
+
+/*
+ * vsock_vmci_sk_destruct --
+ *
+ * Destroys the provided socket.  This is called by sk_free(), which is invoke
+ * when the reference count of the socket drops to zero.
+ *
+ * Results: None.
+ *
+ * Side effects: Socket count is decremented.
+ */
+
+static void vsock_vmci_sk_destruct(struct sock *sk)
+{
+	vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	if (vsk->attach_sub_id != VMCI_INVALID_ID) {
+		vmci_event_unsubscribe(vsk->attach_sub_id);
+		vsk->attach_sub_id = VMCI_INVALID_ID;
+	}
+
+	if (vsk->detach_sub_id != VMCI_INVALID_ID) {
+		vmci_event_unsubscribe(vsk->detach_sub_id);
+		vsk->detach_sub_id = VMCI_INVALID_ID;
+	}
+
+	if (!VMCI_HANDLE_INVALID(vsk->qp_handle)) {
+		vmci_qpair_detach(&vsk->qpair);
+		vsk->qp_handle = VMCI_INVALID_HANDLE;
+		vsk->produce_size = vsk->consume_size = 0;
+	}
+
+	/*
+	 * Each list entry holds a reference on the socket, so we should not
+	 * even be here if the socket is in one of our lists.  If we are we
+	 * have a stray sock_put() that needs to go away.
+	 */
+	ASSERT(!vsock_vmci_in_bound_table(sk));
+	ASSERT(!vsock_vmci_in_connected_table(sk));
+	ASSERT(!vsock_vmci_is_pending(sk));
+	ASSERT(!vsock_vmci_in_accept_queue(sk));
+
+	/*
+	 * When clearing these addresses, there's no need to set the family and
+	 * possibly register the address family with the kernel.
+	 */
+	vsock_addr_init(&vsk->local_addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
+	vsock_addr_init(&vsk->remote_addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
+
+	NOTIFYCALL(vsk, socket_destruct, sk);
+
+	put_cred(vsk->owner);
+
+	VSOCK_STATS_CTLPKT_DUMP_ALL();
+	VSOCK_STATS_HIST_DUMP_ALL();
+	VSOCK_STATS_TOTALS_DUMP_ALL();
+}
+
+/*
+ * vsock_vmci_queue_rcv_skb --
+ *
+ * Receives skb on the socket's receive queue.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int vsock_vmci_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	int err;
+
+	err = sock_queue_rcv_skb(sk, skb);
+	if (err)
+		kfree_skb(skb);
+
+	return err;
+}
+
+/*
+ * vsock_vmci_register_with_vmci --
+ *
+ * Registers with the VMCI device, and creates control message and event
+ * handlers.
+ *
+ * Results: Zero on success, error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int vsock_vmci_register_with_vmci(void)
+{
+	int err = 0;
+
+	/*
+	 * Create the datagram handle that we will use to send and receive all
+	 * VSocket control messages for this context.
+	 */
+	err = vsock_vmci_datagram_create_hnd(VSOCK_PACKET_RID,
+					     VMCI_FLAG_ANYCID_DG_HND,
+					     vsock_vmci_recv_stream_cb, NULL,
+					     &vmci_stream_handle);
+	if (err < VMCI_SUCCESS) {
+		pr_err("Unable to create datagram handle. (%d)\n",
+		       err);
+		err = vsock_vmci_error_to_vsock_error(err);
+		goto out;
+	}
+
+	err = vmci_event_subscribe(VMCI_EVENT_QP_RESUMED,
+				   vsock_vmci_qp_resumed_cb,
+				   NULL, &qp_resumed_sub_id);
+	if (err < VMCI_SUCCESS) {
+		pr_err("Unable to subscribe to resumed event. (%d)\n",
+		       err);
+		err = vsock_vmci_error_to_vsock_error(err);
+		qp_resumed_sub_id = VMCI_INVALID_ID;
+		goto out;
+	}
+
+out:
+	if (err != 0)
+		vsock_vmci_unregister_with_vmci();
+
+	return err;
+}
+
+/*
+ * vsock_vmci_unregister_with_vmci --
+ *
+ * Destroys control message and event handlers, and unregisters with the VMCI
+ * device
+ *
+ * Results: None.
+ *
+ * Side effects: Our socket implementation is no longer accessible.
+ */
+
+static void vsock_vmci_unregister_with_vmci(void)
+{
+	if (!VMCI_HANDLE_INVALID(vmci_stream_handle)) {
+		if (vmci_datagram_destroy_handle(vmci_stream_handle) !=
+		    VMCI_SUCCESS)
+			pr_err("Couldn't destroy datagram handle.\n");
+
+		vmci_stream_handle = VMCI_INVALID_HANDLE;
+	}
+
+	if (qp_resumed_sub_id != VMCI_INVALID_ID) {
+		vmci_event_unsubscribe(qp_resumed_sub_id);
+		qp_resumed_sub_id = VMCI_INVALID_ID;
+	}
+}
+
+/*
+ * vsock_vmci_stream_has_data --
+ *
+ * Gets the amount of data available for a given stream socket's consume queue.
+ *
+ * Note that this assumes the socket lock is held.
+ *
+ * Results: The amount of data available or a VMCI error code on failure.
+ *
+ * Side effects: None.
+ */
+
+s64 vsock_vmci_stream_has_data(vsock_vmci_sock *vsk)
+{
+	return vmci_qpair_consume_buf_ready(vsk->qpair);
+}
+
+/*
+ * vsock_vmci_stream_has_space --
+ *
+ * Gets the amount of space available for a give stream socket's produce queue.
+ *
+ * Note that this assumes the socket lock is held.
+ *
+ * Results: The amount of space available or a VMCI error code on failure.
+ *
+ * Side effects: None.
+ */
+
+s64 vsock_vmci_stream_has_space(vsock_vmci_sock *vsk)
+{
+	return vmci_qpair_produce_free_space(vsk->qpair);
+}
+
+/*
+ * Socket operations.
+ */
+
+/*
+ *
+ * vsock_vmci_release --
+ *
+ * Releases the provided socket by freeing the contents of its queue.  This is
+ * called when a user process calls close(2) on the socket.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int vsock_vmci_release(struct socket *sock)
+{
+	__vsock_vmci_release(sock->sk);
+	sock->sk = NULL;
+	sock->state = SS_FREE;
+
+	return 0;
+}
+
+/*
+ * vsock_vmci_bind --
+ *
+ * Binds the provided address to the provided socket.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
+{
+	int err;
+	struct sock *sk;
+	struct sockaddr_vm *vmci_addr;
+
+	sk = sock->sk;
+
+	if (vsock_addr_cast(addr, addr_len, &vmci_addr) != 0)
+		return -EINVAL;
+
+	lock_sock(sk);
+	err = __vsock_vmci_bind(sk, vmci_addr);
+	release_sock(sk);
+
+	return err;
+}
+
+/*
+ * vsock_vmci_dgram_connect --
+ *
+ * Connects a datagram socket.  This can be called multiple times to change the
+ * socket's association and can be called with a sockaddr whose family is set
+ * to AF_UNSPEC to dissolve any existing association.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_dgram_connect(struct socket *sock,
+			 struct sockaddr *addr, int addr_len, int flags)
+{
+	int err;
+	struct sock *sk;
+	vsock_vmci_sock *vsk;
+	struct sockaddr_vm *remote_addr;
+
+	sk = sock->sk;
+	vsk = vsock_sk(sk);
+
+	err = vsock_addr_cast(addr, addr_len, &remote_addr);
+	if (err == -EAFNOSUPPORT && remote_addr->svm_family == AF_UNSPEC) {
+		lock_sock(sk);
+		vsock_addr_init(&vsk->remote_addr, VMADDR_CID_ANY,
+				VMADDR_PORT_ANY);
+		sock->state = SS_UNCONNECTED;
+		release_sock(sk);
+		return 0;
+	} else if (err != 0)
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	if (!vsock_addr_bound(&vsk->local_addr)) {
+		struct sockaddr_vm local_addr;
+
+		vsock_addr_init(&local_addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
+		err = __vsock_vmci_bind(sk, &local_addr);
+		if (err != 0)
+			goto out;
+
+	}
+
+	if (!vsock_addr_socket_context_dgram(remote_addr->svm_cid,
+					     remote_addr->svm_port)) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	memcpy(&vsk->remote_addr, remote_addr, sizeof vsk->remote_addr);
+	sock->state = SS_CONNECTED;
+
+out:
+	release_sock(sk);
+	return err;
+}
+
+/*
+ * vsock_vmci_connect_timeout --
+ *
+ * Asynchronous connection attempts schedule this timeout function to notify
+ * the connector of an unsuccessfull connection attempt. If the socket is still
+ * in the connecting state and hasn't been closed, we mark the socket as timed
+ * out. Otherwise, we do nothing.
+ *
+ * Results: None.
+ *
+ * Side effects: May destroy the socket.
+ */
+
+static void vsock_vmci_connect_timeout(struct work_struct *work)
+{
+	struct sock *sk;
+	vsock_vmci_sock *vsk;
+
+	vsk = container_of(work, vsock_vmci_sock, dwork.work);
+	sk = sk_vsock(vsk);
+
+	lock_sock(sk);
+	if (sk->sk_state == SS_CONNECTING &&
+	    (sk->sk_shutdown != SHUTDOWN_MASK)) {
+		sk->sk_state = SS_UNCONNECTED;
+		sk->sk_err = ETIMEDOUT;
+		sk->sk_error_report(sk);
+	}
+	release_sock(sk);
+
+	sock_put(sk);
+}
+
+/*
+ * vsock_vmci_stream_connect --
+ *
+ * Connects a stream socket.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_stream_connect(struct socket *sock,
+			  struct sockaddr *addr, int addr_len, int flags)
+{
+	int err;
+	struct sock *sk;
+	vsock_vmci_sock *vsk;
+	struct sockaddr_vm *remote_addr;
+	long timeout;
+	bool old_pkt_proto = false;
+	DEFINE_WAIT(wait);
+
+	err = 0;
+	sk = sock->sk;
+	vsk = vsock_sk(sk);
+
+	lock_sock(sk);
+
+	/* XXX AF_UNSPEC should make us disconnect like AF_INET. */
+	switch (sock->state) {
+	case SS_CONNECTED:
+		err = -EISCONN;
+		goto out;
+	case SS_DISCONNECTING:
+		err = -EINVAL;
+		goto out;
+	case SS_CONNECTING:
+		/*
+		 * This continues on so we can move sock into the SS_CONNECTED
+		 * state once the connection has completed (at which point err
+		 * will be set to zero also).  Otherwise, we will either wait
+		 * for the connection or return -EALREADY should this be a
+		 * non-blocking call.
+		 */
+		err = -EALREADY;
+		break;
+	default:
+		ASSERT(sk->sk_state == SS_FREE ||
+		       sk->sk_state == SS_UNCONNECTED ||
+		       sk->sk_state == SS_LISTEN);
+		if ((sk->sk_state == SS_LISTEN) ||
+		    vsock_addr_cast(addr, addr_len, &remote_addr) != 0) {
+			err = -EINVAL;
+			goto out;
+		}
+
+		/*
+		 * The hypervisor and well-known contexts do not have socket
+		 * endpoints.
+		 */
+		if (!vsock_addr_socket_context_stream(remote_addr->svm_cid)) {
+			err = -ENETUNREACH;
+			goto out;
+		}
+
+		/* Set the remote address that we are connecting to. */
+		memcpy(&vsk->remote_addr, remote_addr, sizeof vsk->remote_addr);
+
+		/* Autobind this socket to the local address if necessary. */
+		if (!vsock_addr_bound(&vsk->local_addr)) {
+			struct sockaddr_vm local_addr;
+
+			vsock_addr_init(&local_addr, VMADDR_CID_ANY,
+					VMADDR_PORT_ANY);
+			err = __vsock_vmci_bind(sk, &local_addr);
+			if (err != 0)
+				goto out;
+
+		}
+
+		sk->sk_state = SS_CONNECTING;
+
+		if (vsock_vmci_old_proto_override(&old_pkt_proto)
+		    && old_pkt_proto) {
+			err = VSOCK_SEND_CONN_REQUEST(sk, vsk->queue_pair_size);
+			if (err < 0) {
+				sk->sk_state = SS_UNCONNECTED;
+				goto out;
+			}
+		} else {
+			int supported_proto_versions =
+			    vsock_vmci_new_proto_supported_versions();
+			err =
+			    VSOCK_SEND_CONN_REQUEST2(sk, vsk->queue_pair_size,
+						     supported_proto_versions);
+			if (err < 0) {
+				sk->sk_state = SS_UNCONNECTED;
+				goto out;
+			}
+
+			vsk->sent_request = true;
+		}
+
+		/*
+		 * Mark sock as connecting and set the error code to in
+		 * progress in case this is a non-blocking connect.
+		 */
+		sock->state = SS_CONNECTING;
+		err = -EINPROGRESS;
+	}
+
+	/*
+	 * The receive path will handle all communication until we are able to
+	 * enter the connected state.  Here we wait for the connection to be
+	 * completed or a notification of an error.
+	 */
+	timeout = vsk->connect_timeout;
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+
+	while (sk->sk_state != SS_CONNECTED && sk->sk_err == 0) {
+		if (flags & O_NONBLOCK) {
+			/*
+			 * If we're not going to block, we schedule a timeout
+			 * function to generate a timeout on the connection
+			 * attempt, in case the peer doesn't respond in a
+			 * timely manner. We hold on to the socket until the
+			 * timeout fires.
+			 */
+			sock_hold(sk);
+			INIT_DELAYED_WORK(&vsk->dwork,
+					  vsock_vmci_connect_timeout);
+			schedule_delayed_work(&vsk->dwork, timeout);
+
+			/* Skip ahead to preserve error code set above. */
+			goto out_wait;
+		}
+
+		release_sock(sk);
+		timeout = schedule_timeout(timeout);
+		lock_sock(sk);
+
+		if (signal_pending(current)) {
+			err = sock_intr_errno(timeout);
+			goto out_wait_error;
+		} else if (timeout == 0) {
+			err = -ETIMEDOUT;
+			goto out_wait_error;
+		}
+
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+	}
+
+	if (sk->sk_err) {
+		err = -sk->sk_err;
+		goto out_wait_error;
+	} else {
+		ASSERT(sk->sk_state == SS_CONNECTED);
+		err = 0;
+	}
+
+out_wait:
+	finish_wait(sk_sleep(sk), &wait);
+out:
+	release_sock(sk);
+	return err;
+
+out_wait_error:
+	sk->sk_state = SS_UNCONNECTED;
+	sock->state = SS_UNCONNECTED;
+	goto out_wait;
+}
+
+/*
+ * vsock_vmci_accept --
+ *
+ * Accepts next available connection request for this socket.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_accept(struct socket *sock, struct socket *newsock, int flags)
+{
+	struct sock *listener;
+	int err;
+	struct sock *connected;
+	vsock_vmci_sock *vconnected;
+	long timeout;
+	DEFINE_WAIT(wait);
+
+	err = 0;
+	listener = sock->sk;
+
+	lock_sock(listener);
+
+	if (sock->type != SOCK_STREAM) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	if (listener->sk_state != SS_LISTEN) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	/*
+	 * Wait for children sockets to appear; these are the new sockets
+	 * created upon connection establishment.
+	 */
+	timeout = sock_sndtimeo(listener, flags & O_NONBLOCK);
+	prepare_to_wait(sk_sleep(listener), &wait, TASK_INTERRUPTIBLE);
+
+	while ((connected = vsock_vmci_dequeue_accept(listener)) == NULL &&
+	       listener->sk_err == 0) {
+		release_sock(listener);
+		timeout = schedule_timeout(timeout);
+		lock_sock(listener);
+
+		if (signal_pending(current)) {
+			err = sock_intr_errno(timeout);
+			goto out_wait;
+		} else if (timeout == 0) {
+			err = -EAGAIN;
+			goto out_wait;
+		}
+
+		prepare_to_wait(sk_sleep(listener), &wait, TASK_INTERRUPTIBLE);
+	}
+
+	if (listener->sk_err)
+		err = -listener->sk_err;
+
+	if (connected) {
+		listener->sk_ack_backlog--;
+
+		lock_sock(connected);
+		vconnected = vsock_sk(connected);
+
+		/*
+		 * If the listener socket has received an error, then we should
+		 * reject this socket and return.  Note that we simply mark the
+		 * socket rejected, drop our reference, and let the cleanup
+		 * function handle the cleanup; the fact that we found it in
+		 * the listener's accept queue guarantees that the cleanup
+		 * function hasn't run yet.
+		 */
+		if (err) {
+			vconnected->rejected = true;
+			release_sock(connected);
+			sock_put(connected);
+			goto out_wait;
+		}
+
+		newsock->state = SS_CONNECTED;
+		sock_graft(connected, newsock);
+		release_sock(connected);
+		sock_put(connected);
+	}
+
+out_wait:
+	finish_wait(sk_sleep(listener), &wait);
+out:
+	release_sock(listener);
+	return err;
+}
+
+/*
+ * vsock_vmci_getname --
+ *
+ * Provides the local or remote address for the socket.
+ *
+ * Results: Zero on success, negative error code otherwise.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_getname(struct socket *sock,
+		   struct sockaddr *addr, int *addr_len, int peer)
+{
+	int err;
+	struct sock *sk;
+	vsock_vmci_sock *vsk;
+	struct sockaddr_vm *vmci_addr;
+
+	sk = sock->sk;
+	vsk = vsock_sk(sk);
+	err = 0;
+
+	lock_sock(sk);
+
+	if (peer) {
+		if (sock->state != SS_CONNECTED) {
+			err = -ENOTCONN;
+			goto out;
+		}
+		vmci_addr = &vsk->remote_addr;
+	} else {
+		vmci_addr = &vsk->local_addr;
+	}
+
+	if (!vmci_addr) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	/*
+	 * sys_getsockname() and sys_getpeername() pass us a
+	 * MAX_SOCK_ADDR-sized buffer and don't set addr_len.  Unfortunately
+	 * that macro is defined in socket.c instead of .h, so we hardcode its
+	 * value here.
+	 */
+	ASSERT_ON_COMPILE(sizeof *vmci_addr <= 128);
+	memcpy(addr, vmci_addr, sizeof *vmci_addr);
+	*addr_len = sizeof *vmci_addr;
+
+out:
+	release_sock(sk);
+	return err;
+}
+
+/*
+ * vsock_vmci_poll --
+ *
+ * Waits on file for activity then provides mask indicating state of socket.
+ *
+ * Results: Mask of flags containing socket state.
+ *
+ * Side effects: None.
+ */
+
+static unsigned int
+vsock_vmci_poll(struct file *file, struct socket *sock, poll_table *wait)
+{
+	struct sock *sk;
+	unsigned int mask;
+	vsock_vmci_sock *vsk;
+
+	sk = sock->sk;
+	vsk = vsock_sk(sk);
+
+	poll_wait(file, sk_sleep(sk), wait);
+	mask = 0;
+
+	if (sk->sk_err)
+		/* Signify that there has been an error on this socket. */
+		mask |= POLLERR;
+
+	/*
+	 * INET sockets treat local write shutdown and peer write shutdown as a
+	 * case of POLLHUP set.
+	 */
+	if ((sk->sk_shutdown == SHUTDOWN_MASK) ||
+	    ((sk->sk_shutdown & SEND_SHUTDOWN) &&
+	     (vsk->peer_shutdown & SEND_SHUTDOWN))) {
+		mask |= POLLHUP;
+	}
+
+	if (sk->sk_shutdown & RCV_SHUTDOWN ||
+	    vsk->peer_shutdown & SEND_SHUTDOWN) {
+		mask |= POLLRDHUP;
+	}
+
+	if (sock->type == SOCK_DGRAM) {
+		/*
+		 * For datagram sockets we can read if there is something in
+		 * the queue and write as long as the socket isn't shutdown for
+		 * sending.
+		 */
+		if (!skb_queue_empty(&sk->sk_receive_queue) ||
+		    (sk->sk_shutdown & RCV_SHUTDOWN)) {
+			mask |= POLLIN | POLLRDNORM;
+		}
+
+		if (!(sk->sk_shutdown & SEND_SHUTDOWN))
+			mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+
+	} else if (sock->type == SOCK_STREAM) {
+		lock_sock(sk);
+
+		/*
+		 * Listening sockets that have connections in their accept
+		 * queue can be read.
+		 */
+		if (sk->sk_state == SS_LISTEN
+		    && !vsock_vmci_is_accept_queue_empty(sk))
+			mask |= POLLIN | POLLRDNORM;
+
+		/*
+		 * If there is something in the queue then we can read.
+		 */
+		if (!VMCI_HANDLE_INVALID(vsk->qp_handle) &&
+		    !(sk->sk_shutdown & RCV_SHUTDOWN)) {
+			bool data_ready_now = false;
+			int ret = 0;
+			NOTIFYCALLRET(vsk, ret, poll_in, sk, 1,
+				      &data_ready_now);
+			if (ret < 0) {
+				mask |= POLLERR;
+			} else {
+				if (data_ready_now)
+					mask |= POLLIN | POLLRDNORM;
+
+			}
+		}
+
+		/*
+		 * Sockets whose connections have been closed, reset, or
+		 * terminated should also be considered read, and we check the
+		 * shutdown flag for that.
+		 */
+		if (sk->sk_shutdown & RCV_SHUTDOWN ||
+		    vsk->peer_shutdown & SEND_SHUTDOWN) {
+			mask |= POLLIN | POLLRDNORM;
+		}
+
+		/*
+		 * Connected sockets that can produce data can be written.
+		 */
+		if (sk->sk_state == SS_CONNECTED) {
+			if (!(sk->sk_shutdown & SEND_SHUTDOWN)) {
+				bool space_avail_now = false;
+				int ret = 0;
+
+				NOTIFYCALLRET(vsk, ret, poll_out, sk, 1,
+					      &space_avail_now);
+				if (ret < 0) {
+					mask |= POLLERR;
+				} else {
+					if (space_avail_now)
+						/*
+						 * Remove POLLWRBAND since INET
+						 * sockets are not setting it.
+						 */
+						mask |= POLLOUT | POLLWRNORM;
+
+				}
+			}
+		}
+
+		/*
+		 * Simulate INET socket poll behaviors, which sets
+		 * POLLOUT|POLLWRNORM when peer is closed and nothing to read,
+		 * but local send is not shutdown.
+		 */
+		if (sk->sk_state == SS_UNCONNECTED) {
+			if (!(sk->sk_shutdown & SEND_SHUTDOWN))
+				mask |= POLLOUT | POLLWRNORM;
+
+		}
+
+		release_sock(sk);
+	}
+
+	return mask;
+}
+
+/*
+ * vsock_vmci_listen --
+ *
+ * Signify that this socket is listening for connection requests.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int vsock_vmci_listen(struct socket *sock, int backlog)
+{
+	int err;
+	struct sock *sk;
+	vsock_vmci_sock *vsk;
+
+	sk = sock->sk;
+
+	lock_sock(sk);
+
+	if (sock->type != SOCK_STREAM) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	if (sock->state != SS_UNCONNECTED) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	vsk = vsock_sk(sk);
+
+	if (!vsock_addr_bound(&vsk->local_addr)) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	sk->sk_max_ack_backlog = backlog;
+	sk->sk_state = SS_LISTEN;
+
+	err = 0;
+
+out:
+	release_sock(sk);
+	return err;
+}
+
+/*
+ * vsock_vmci_shutdown --
+ *
+ * Shuts down the provided socket in the provided method.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int vsock_vmci_shutdown(struct socket *sock, int mode)
+{
+	int err;
+	struct sock *sk;
+
+	/*
+	 * User level uses SHUT_RD (0) and SHUT_WR (1), but the kernel uses
+	 * RCV_SHUTDOWN (1) and SEND_SHUTDOWN (2), so we must increment mode
+	 * here like the other address families do.  Note also that the
+	 * increment makes SHUT_RDWR (2) into RCV_SHUTDOWN | SEND_SHUTDOWN (3),
+	 * which is what we want.
+	 */
+	mode++;
+
+	if ((mode & ~SHUTDOWN_MASK) || !mode)
+		return -EINVAL;
+
+	/*
+	 * If this is a STREAM socket and it is not connected then bail out
+	 * immediately.  If it is a DGRAM socket then we must first kick the socket
+	 * so that it wakes up from any sleeping calls, for example recv(), and then
+	 * afterwards return the error.
+	 */
+
+	sk = sock->sk;
+	if (sock->state == SS_UNCONNECTED) {
+		err = -ENOTCONN;
+		if (sk->sk_type == SOCK_STREAM)
+			return err;
+	} else {
+		sock->state = SS_DISCONNECTING;
+		err = 0;
+	}
+
+	/* Receive and send shutdowns are treated alike. */
+	mode = mode & (RCV_SHUTDOWN | SEND_SHUTDOWN);
+	if (mode) {
+		lock_sock(sk);
+		sk->sk_shutdown |= mode;
+		sk->sk_state_change(sk);
+		release_sock(sk);
+
+		if (sk->sk_type == SOCK_STREAM) {
+			sock_reset_flag(sk, SOCK_DONE);
+			VSOCK_SEND_SHUTDOWN(sk, mode);
+		}
+	}
+
+	return err;
+}
+
+/*
+ * vsock_vmci_dgram_sendmsg --
+ *
+ * Sends a datagram.
+ *
+ * Results: Number of bytes sent on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_dgram_sendmsg(struct kiocb *kiocb,
+			 struct socket *sock, struct msghdr *msg, size_t len)
+{
+	int err;
+	struct sock *sk;
+	vsock_vmci_sock *vsk;
+	struct sockaddr_vm *remote_addr;
+	struct vmci_datagram *dg;
+
+	if (msg->msg_flags & MSG_OOB)
+		return -EOPNOTSUPP;
+
+	if (len > VMCI_MAX_DG_PAYLOAD_SIZE)
+		return -EMSGSIZE;
+
+	/* For now, MSG_DONTWAIT is always assumed... */
+	err = 0;
+	sk = sock->sk;
+	vsk = vsock_sk(sk);
+
+	lock_sock(sk);
+
+	if (!vsock_addr_bound(&vsk->local_addr)) {
+		struct sockaddr_vm local_addr;
+
+		vsock_addr_init(&local_addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
+		err = __vsock_vmci_bind(sk, &local_addr);
+		if (err != 0)
+			goto out;
+
+	}
+
+	/*
+	 * If the provided message contains an address, use that.  Otherwise
+	 * fall back on the socket's remote handle (if it has been connected).
+	 */
+	if (msg->msg_name &&
+	    vsock_addr_cast(msg->msg_name, msg->msg_namelen,
+			    &remote_addr) == 0) {
+		/* Ensure this address is of the right type and is a valid
+		 * destination. */
+
+		if (remote_addr->svm_cid == VMADDR_CID_ANY)
+			remote_addr->svm_cid = vmci_get_context_id();
+
+		if (!vsock_addr_bound(remote_addr)) {
+			err = -EINVAL;
+			goto out;
+		}
+	} else if (sock->state == SS_CONNECTED) {
+		remote_addr = &vsk->remote_addr;
+
+		if (remote_addr->svm_cid == VMADDR_CID_ANY)
+			remote_addr->svm_cid = vmci_get_context_id();
+
+		/* XXX Should connect() or this function ensure remote_addr is
+		 * bound? */
+		if (!vsock_addr_bound(&vsk->remote_addr)) {
+			err = -EINVAL;
+			goto out;
+		}
+	} else {
+		err = -EINVAL;
+		goto out;
+	}
+
+	/*
+	 * Make sure that we don't allow a userlevel app to send datagrams to
+	 * the hypervisor that modify VMCI device state.
+	 */
+	if (!vsock_addr_socket_context_dgram(remote_addr->svm_cid,
+					     remote_addr->svm_port)) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	if (!vsock_vmci_allow_dgram(vsk, remote_addr->svm_cid)) {
+		err = -EPERM;
+		goto out;
+	}
+
+	/*
+	 * Allocate a buffer for the user's message and our packet header.
+	 */
+	dg = kmalloc(len + sizeof *dg, GFP_KERNEL);
+	if (!dg) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	memcpy_fromiovec(VMCI_DG_PAYLOAD(dg), msg->msg_iov, len);
+
+	dg->dst = VMCI_MAKE_HANDLE(remote_addr->svm_cid, remote_addr->svm_port);
+	dg->src =
+	    VMCI_MAKE_HANDLE(vsk->local_addr.svm_cid, vsk->local_addr.svm_port);
+
+	dg->payload_size = len;
+
+	err = vmci_datagram_send(dg);
+	kfree(dg);
+	if (err < 0) {
+		err = vsock_vmci_error_to_vsock_error(err);
+		goto out;
+	}
+
+	err -= sizeof *dg;
+
+out:
+	release_sock(sk);
+	return err;
+}
+
+/*
+ * vsock_vmci_stream_setsockopt --
+ *
+ * Set a socket option on a stream socket
+ *
+ * Results: 0 on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int vsock_vmci_stream_setsockopt(struct socket *sock,
+					int level,
+					int optname,
+					char __user *optval,
+					vsock_setsockopt_len_type optlen)
+{
+	int err;
+	struct sock *sk;
+	vsock_vmci_sock *vsk;
+	u64 val;
+
+	if (level != AF_VSOCK)
+		return -ENOPROTOOPT;
+
+#define COPY_IN(_v)                                       \
+	do {						  \
+		if (optlen < sizeof _v) {		  \
+			err = -EINVAL;			  \
+			goto exit;			  \
+		}					  \
+		if (copy_from_user(&_v, optval, sizeof _v) != 0) {	\
+			err = -EFAULT;					\
+			goto exit;					\
+		}							\
+	} while (0)
+
+	err = 0;
+	sk = sock->sk;
+	vsk = vsock_sk(sk);
+
+	ASSERT(vsk->queue_pair_min_size <= vsk->queue_pair_size &&
+	       vsk->queue_pair_size <= vsk->queue_pair_max_size);
+
+	lock_sock(sk);
+
+	switch (optname) {
+	case SO_VMCI_BUFFER_SIZE:
+		COPY_IN(val);
+		if (val < vsk->queue_pair_min_size)
+			vsk->queue_pair_min_size = val;
+
+		if (val > vsk->queue_pair_max_size)
+			vsk->queue_pair_max_size = val;
+
+		vsk->queue_pair_size = val;
+		break;
+
+	case SO_VMCI_BUFFER_MAX_SIZE:
+		COPY_IN(val);
+		if (val < vsk->queue_pair_size)
+			vsk->queue_pair_size = val;
+
+		vsk->queue_pair_max_size = val;
+		break;
+
+	case SO_VMCI_BUFFER_MIN_SIZE:
+		COPY_IN(val);
+		if (val > vsk->queue_pair_size)
+			vsk->queue_pair_size = val;
+
+		vsk->queue_pair_min_size = val;
+		break;
+
+	case SO_VMCI_CONNECT_TIMEOUT: {
+		struct timeval tv;
+		COPY_IN(tv);
+		if (tv.tv_sec >= 0 && tv.tv_usec < USEC_PER_SEC &&
+		    tv.tv_sec < (MAX_SCHEDULE_TIMEOUT / HZ - 1)) {
+			vsk->connect_timeout = tv.tv_sec * HZ +
+			    DIV_ROUND_UP(tv.tv_usec, (1000000 / HZ));
+			if (vsk->connect_timeout == 0)
+				vsk->connect_timeout =
+				    VSOCK_DEFAULT_CONNECT_TIMEOUT;
+
+		} else {
+			err = -ERANGE;
+		}
+		break;
+	}
+
+	default:
+		err = -ENOPROTOOPT;
+		break;
+	}
+
+#undef COPY_IN
+
+	ASSERT(vsk->queue_pair_min_size <= vsk->queue_pair_size &&
+	       vsk->queue_pair_size <= vsk->queue_pair_max_size);
+exit:
+	release_sock(sk);
+	return err;
+}
+
+/*
+ * vsock_vmci_stream_getsockopt --
+ *
+ * Get a socket option for a stream socket
+ *
+ * Results: 0 on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int vsock_vmci_stream_getsockopt(struct socket *sock,
+					int level, int optname,
+					char __user *optval,
+					int __user *optlen)
+{
+	int err;
+	int len;
+	struct sock *sk;
+	vsock_vmci_sock *vsk;
+
+	if (level != AF_VSOCK)
+		return -ENOPROTOOPT;
+
+	err = get_user(len, optlen);
+	if (err != 0)
+		return err;
+
+#define COPY_OUT(_v)                            \
+	do {					\
+		if (len < sizeof _v)		\
+			return -EINVAL;		\
+						\
+		len = sizeof _v;		\
+		if (copy_to_user(optval, &_v, len) != 0)	\
+			return -EFAULT;				\
+								\
+	} while (0)
+
+	err = 0;
+	sk = sock->sk;
+	vsk = vsock_sk(sk);
+
+	switch (optname) {
+	case SO_VMCI_BUFFER_SIZE:
+		COPY_OUT(vsk->queue_pair_size);
+		break;
+
+	case SO_VMCI_BUFFER_MAX_SIZE:
+		COPY_OUT(vsk->queue_pair_max_size);
+		break;
+
+	case SO_VMCI_BUFFER_MIN_SIZE:
+		COPY_OUT(vsk->queue_pair_min_size);
+		break;
+
+	case SO_VMCI_CONNECT_TIMEOUT: {
+		struct timeval tv;
+		tv.tv_sec = vsk->connect_timeout / HZ;
+		tv.tv_usec =
+		    (vsk->connect_timeout -
+		     tv.tv_sec * HZ) * (1000000 / HZ);
+		COPY_OUT(tv);
+		break;
+	}
+	default:
+		return -ENOPROTOOPT;
+	}
+
+	err = put_user(len, optlen);
+	if (err != 0)
+		return -EFAULT;
+
+#undef COPY_OUT
+
+	return 0;
+}
+
+/*
+ * vsock_vmci_stream_sendmsg --
+ *
+ * Sends a message on the socket.
+ *
+ * Results: Number of bytes sent on success, negative error code on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_stream_sendmsg(struct kiocb *kiocb,
+			  struct socket *sock, struct msghdr *msg, size_t len)
+{
+	struct sock *sk;
+	vsock_vmci_sock *vsk;
+	ssize_t total_written;
+	long timeout;
+	int err;
+	vsock_vmci_send_notify_data send_data;
+
+	DEFINE_WAIT(wait);
+
+	sk = sock->sk;
+	vsk = vsock_sk(sk);
+	total_written = 0;
+	err = 0;
+
+	if (msg->msg_flags & MSG_OOB)
+		return -EOPNOTSUPP;
+
+	lock_sock(sk);
+
+	/* Callers should not provide a destination with stream sockets. */
+	if (msg->msg_namelen) {
+		err = sk->sk_state == SS_CONNECTED ? -EISCONN : -EOPNOTSUPP;
+		goto out;
+	}
+
+	/* Send data only if both sides are not shutdown in the direction. */
+	if (sk->sk_shutdown & SEND_SHUTDOWN ||
+	    vsk->peer_shutdown & RCV_SHUTDOWN) {
+		err = -EPIPE;
+		goto out;
+	}
+
+	if (sk->sk_state != SS_CONNECTED ||
+	    !vsock_addr_bound(&vsk->local_addr)) {
+		err = -ENOTCONN;
+		goto out;
+	}
+
+	if (!vsock_addr_bound(&vsk->remote_addr)) {
+		err = -EDESTADDRREQ;
+		goto out;
+	}
+
+	/*
+	 * Wait for room in the produce queue to enqueue our user's data.
+	 */
+	timeout = sock_sndtimeo(sk, msg->msg_flags & MSG_DONTWAIT);
+
+	NOTIFYCALLRET(vsk, err, send_init, sk, &send_data);
+	if (err < 0)
+		goto out;
+
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+
+	while (total_written < len) {
+		ssize_t written;
+
+		while (vsock_vmci_stream_has_space(vsk) == 0 &&
+		       sk->sk_err == 0 &&
+		       !(sk->sk_shutdown & SEND_SHUTDOWN) &&
+		       !(vsk->peer_shutdown & RCV_SHUTDOWN)) {
+
+			/* Don't wait for non-blocking sockets. */
+			if (timeout == 0) {
+				err = -EAGAIN;
+				goto out_wait;
+			}
+
+			NOTIFYCALLRET(vsk, err, send_pre_block, sk, &send_data);
+
+			if (err < 0)
+				goto out_wait;
+
+			release_sock(sk);
+			timeout = schedule_timeout(timeout);
+			lock_sock(sk);
+			if (signal_pending(current)) {
+				err = sock_intr_errno(timeout);
+				goto out_wait;
+			} else if (timeout == 0) {
+				err = -EAGAIN;
+				goto out_wait;
+			}
+
+			prepare_to_wait(sk_sleep(sk), &wait,
+					TASK_INTERRUPTIBLE);
+		}
+
+		/*
+		 * These checks occur both as part of and after the loop
+		 * conditional since we need to check before and after
+		 * sleeping.
+		 */
+		if (sk->sk_err) {
+			err = -sk->sk_err;
+			goto out_wait;
+		} else if ((sk->sk_shutdown & SEND_SHUTDOWN) ||
+			   (vsk->peer_shutdown & RCV_SHUTDOWN)) {
+			err = -EPIPE;
+			goto out_wait;
+		}
+
+		VSOCK_STATS_STREAM_PRODUCE_HIST(vsk);
+
+		NOTIFYCALLRET(vsk, err, send_pre_enqueue, sk, &send_data);
+		if (err < 0)
+			goto out_wait;
+
+		/*
+		 * Note that enqueue will only write as many bytes as are free
+		 * in the produce queue, so we don't need to ensure len is
+		 * smaller than the queue size.  It is the caller's
+		 * responsibility to check how many bytes we were able to send.
+		 */
+
+		written = vmci_qpair_enquev(vsk->qpair, msg->msg_iov,
+					    len - total_written, 0);
+		if (written < 0) {
+			err = -ENOMEM;
+			goto out_wait;
+		}
+
+		total_written += written;
+
+		NOTIFYCALLRET(vsk, err, send_post_enqueue, sk, written,
+			      &send_data);
+		if (err < 0)
+			goto out_wait;
+
+	}
+
+	ASSERT(total_written <= INT_MAX);
+
+out_wait:
+	if (total_written > 0) {
+		VSOCK_STATS_STREAM_PRODUCE(total_written);
+		err = total_written;
+	}
+	finish_wait(sk_sleep(sk), &wait);
+out:
+	release_sock(sk);
+	return err;
+}
+
+/*
+ * vsock_vmci_dgram_recvmsg --
+ *
+ * Receives a datagram and places it in the caller's msg.
+ *
+ * Results: The size of the payload on success, negative value on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_dgram_recvmsg(struct kiocb *kiocb,
+			 struct socket *sock,
+			 struct msghdr *msg, size_t len, int flags)
+{
+	int err;
+	int noblock;
+	struct sock *sk;
+	struct vmci_datagram *dg;
+	size_t payload_len;
+	struct sk_buff *skb;
+
+	sk = sock->sk;
+	noblock = flags & MSG_DONTWAIT;
+
+	if (flags & MSG_OOB || flags & MSG_ERRQUEUE)
+		return -EOPNOTSUPP;
+
+	/* Retrieve the head sk_buff from the socket's receive queue. */
+	err = 0;
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	if (err)
+		return err;
+
+	if (!skb)
+		return -EAGAIN;
+
+	dg = (struct vmci_datagram *) skb->data;
+	if (!dg)
+		/* err is 0, meaning we read zero bytes. */
+		goto out;
+
+	payload_len = dg->payload_size;
+	/* Ensure the sk_buff matches the payload size claimed in the packet. */
+	if (payload_len != skb->len - sizeof *dg) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	if (payload_len > len) {
+		payload_len = len;
+		msg->msg_flags |= MSG_TRUNC;
+	}
+
+	/* Place the datagram payload in the user's iovec. */
+	err =
+	    skb_copy_datagram_iovec(skb, sizeof *dg, msg->msg_iov, payload_len);
+	if (err)
+		goto out;
+
+	msg->msg_namelen = 0;
+	if (msg->msg_name) {
+		struct sockaddr_vm *vmci_addr;
+
+		/* Provide the address of the sender. */
+		vmci_addr = (struct sockaddr_vm *)msg->msg_name;
+		vsock_addr_init(vmci_addr,
+				VMCI_HANDLE_TO_CONTEXT_ID(dg->src),
+				VMCI_HANDLE_TO_RESOURCE_ID(dg->src));
+		msg->msg_namelen = sizeof *vmci_addr;
+	}
+	err = payload_len;
+
+out:
+	skb_free_datagram(sk, skb);
+	return err;
+}
+
+/*
+ * vsock_vmci_stream_recvmsg --
+ *
+ * Receives a datagram and places it in the caller's msg.
+ *
+ * Results: The size of the payload on success, negative value on failure.
+ *
+ * Side effects: None.
+ */
+
+static int
+vsock_vmci_stream_recvmsg(struct kiocb *kiocb,
+			  struct socket *sock,
+			  struct msghdr *msg, size_t len, int flags)
+{
+	struct sock *sk;
+	vsock_vmci_sock *vsk;
+	int err;
+	size_t target;
+	ssize_t copied;
+	long timeout;
+
+	vsock_vmci_recv_notify_data recv_data;
+
+	DEFINE_WAIT(wait);
+
+	sk = sock->sk;
+	vsk = vsock_sk(sk);
+	err = 0;
+
+	lock_sock(sk);
+
+	if (sk->sk_state != SS_CONNECTED) {
+		/*
+		 * Recvmsg is supposed to return 0 if a peer performs an
+		 * orderly shutdown. Differentiate between that case and when a
+		 * peer has not connected or a local shutdown occured with the
+		 * SOCK_DONE flag.
+		 */
+		if (sock_flag(sk, SOCK_DONE))
+			err = 0;
+		else
+			err = -ENOTCONN;
+
+		goto out;
+	}
+
+	if (flags & MSG_OOB) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	/*
+	 * We don't check peer_shutdown flag here since peer may actually shut
+	 * down, but there can be data in the VMCI queue that local socket can
+	 * receive.
+	 */
+	if (sk->sk_shutdown & RCV_SHUTDOWN) {
+		err = 0;
+		goto out;
+	}
+
+	/*
+	 * It is valid on Linux to pass in a zero-length receive buffer.  This
+	 * is not an error.  We may as well bail out now.  Note that if we
+	 * don't, we will fail "ASSERT(copied >= target)" after we dequeue,
+	 * because the minimum target is always 1 byte.
+	 */
+	if (!len) {
+		err = 0;
+		goto out;
+	}
+
+	/*
+	 * We must not copy less than target bytes into the user's buffer
+	 * before returning successfully, so we wait for the consume queue to
+	 * have that much data to consume before dequeueing.  Note that this
+	 * makes it impossible to handle cases where target is greater than the
+	 * queue size.
+	 */
+	target = sock_rcvlowat(sk, flags & MSG_WAITALL, len);
+	if (target >= vsk->consume_size) {
+		err = -ENOMEM;
+		goto out;
+	}
+	timeout = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+	copied = 0;
+
+	NOTIFYCALLRET(vsk, err, recv_init, sk, target, &recv_data);
+	if (err < 0)
+		goto out;
+
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+
+	while (1) {
+		s64 ready = vsock_vmci_stream_has_data(vsk);
+
+		if (ready < 0) {
+			/*
+			 * Invalid queue pair content. XXX This should be
+			 * changed to a connection reset in a later change.
+			 */
+
+			err = -ENOMEM;
+			goto out_wait;
+		} else if (ready > 0) {
+			ssize_t read;
+
+			VSOCK_STATS_STREAM_CONSUME_HIST(vsk);
+
+			NOTIFYCALLRET(vsk, err, recv_pre_dequeue, sk, target,
+				      &recv_data);
+			if (err < 0)
+				break;
+
+			if (flags & MSG_PEEK)
+				read =
+				    vmci_qpair_peekv(vsk->qpair, msg->msg_iov,
+						     len - copied, 0);
+			else
+				read =
+				    vmci_qpair_dequev(vsk->qpair, msg->msg_iov,
+						      len - copied, 0);
+
+			if (read < 0) {
+				err = -ENOMEM;
+				break;
+			}
+
+			ASSERT(read <= INT_MAX);
+			copied += read;
+
+			NOTIFYCALLRET(vsk, err, recv_post_dequeue, sk, target,
+				      read, !(flags & MSG_PEEK), &recv_data);
+			if (err < 0)
+				goto out_wait;
+
+			if (read >= target || flags & MSG_PEEK)
+				break;
+
+			target -= read;
+		} else {
+			if (sk->sk_err != 0 || (sk->sk_shutdown & RCV_SHUTDOWN)
+			    || (vsk->peer_shutdown & SEND_SHUTDOWN)) {
+				break;
+			}
+			/* Don't wait for non-blocking sockets. */
+			if (timeout == 0) {
+				err = -EAGAIN;
+				break;
+			}
+
+			NOTIFYCALLRET(vsk, err, recv_pre_block, sk, target,
+				      &recv_data);
+			if (err < 0)
+				break;
+
+			release_sock(sk);
+			timeout = schedule_timeout(timeout);
+			lock_sock(sk);
+
+			if (signal_pending(current)) {
+				err = sock_intr_errno(timeout);
+				break;
+			} else if (timeout == 0) {
+				err = -EAGAIN;
+				break;
+			}
+
+			prepare_to_wait(sk_sleep(sk), &wait,
+					TASK_INTERRUPTIBLE);
+		}
+	}
+
+	if (sk->sk_err)
+		err = -sk->sk_err;
+	else if (sk->sk_shutdown & RCV_SHUTDOWN)
+		err = 0;
+
+	if (copied > 0) {
+		/*
+		 * We only do these additional bookkeeping/notification steps
+		 * if we actually copied something out of the queue pair
+		 * instead of just peeking ahead.
+		 */
+
+		if (!(flags & MSG_PEEK)) {
+			VSOCK_STATS_STREAM_CONSUME(copied);
+
+			/*
+			 * If the other side has shutdown for sending and there
+			 * is nothing more to read, then modify the socket
+			 * state.
+			 */
+			if (vsk->peer_shutdown & SEND_SHUTDOWN) {
+				if (vsock_vmci_stream_has_data(vsk) <= 0) {
+					sk->sk_state = SS_UNCONNECTED;
+					sock_set_flag(sk, SOCK_DONE);
+					sk->sk_state_change(sk);
+				}
+			}
+		}
+		err = copied;
+	}
+
+out_wait:
+	finish_wait(sk_sleep(sk), &wait);
+out:
+	release_sock(sk);
+	return err;
+}
+
+/*
+ * Protocol operation.
+ */
+
+/*
+ * vsock_vmci_create --
+ *
+ * Creates a VSocket socket.
+ *
+ * Results: Zero on success, negative error code on failure.
+ *
+ * Side effects: Socket count is incremented.
+ */
+
+static int
+vsock_vmci_create(struct net *net, struct socket *sock, int protocol, int kern)
+{
+	if (!sock)
+		return -EINVAL;
+
+	if (protocol)
+		return -EPROTONOSUPPORT;
+
+	switch (sock->type) {
+	case SOCK_DGRAM:
+		sock->ops = &vsock_vmci_dgram_ops;
+		break;
+	case SOCK_STREAM:
+		sock->ops = &vsock_vmci_stream_ops;
+		break;
+	default:
+		return -ESOCKTNOSUPPORT;
+	}
+
+	sock->state = SS_UNCONNECTED;
+
+	return __vsock_vmci_create(net, sock, NULL, GFP_KERNEL,
+				   0) ? 0 : -ENOMEM;
+}
+
+/*
+ * Device operations.
+ */
+
+static long vsock_vmci_dev_do_ioctl(struct file *filp,
+				    unsigned int cmd, void __user *ptr)
+{
+	static const u16 parts[4] = { VSOCK_DRIVER_VERSION_COMMAS };
+	u32 __user *p = ptr;
+	int retval = 0;
+	u32 version;
+
+	switch (cmd) {
+	case IOCTL_VMCI_SOCKETS_VERSION:
+		version = VMCI_SOCKETS_MAKE_VERSION(parts);
+		if (put_user(version, p) != 0)
+			retval = -EFAULT;
+		break;
+
+	case IOCTL_VMCI_SOCKETS_GET_AF_VALUE:
+		if (put_user(AF_VSOCK, p) != 0)
+			retval = -EFAULT;
+
+		break;
+
+	case IOCTL_VMCI_SOCKETS_GET_LOCAL_CID:
+		if (put_user(vmci_get_context_id(), p) != 0)
+			retval = -EFAULT;
+
+		break;
+
+	default:
+		pr_err("Unknown ioctl %d\n", cmd);
+		retval = -EINVAL;
+	}
+
+	return retval;
+}
+
+static long vsock_vmci_dev_ioctl(struct file *filp,
+				 unsigned int cmd, unsigned long arg)
+{
+	return vsock_vmci_dev_do_ioctl(filp, cmd, (void __user *)arg);
+}
+
+#ifdef CONFIG_COMPAT
+static long vsock_vmci_dev_compat_ioctl(struct file *filp,
+					unsigned int cmd, unsigned long arg)
+{
+	return vsock_vmci_dev_do_ioctl(filp, cmd, compat_ptr(arg));
+}
+#endif
+
+static const struct file_operations vsock_vmci_device_ops = {
+	.owner		= THIS_MODULE,
+	.unlocked_ioctl	= vsock_vmci_dev_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= vsock_vmci_dev_compat_ioctl,
+#endif
+	.open		= nonseekable_open,
+};
+
+static struct miscdevice vsock_vmci_device = {
+	.name		= "vsock",
+	.minor		= MISC_DYNAMIC_MINOR,
+	.fops		= &vsock_vmci_device_ops,
+};
+
+
+/*
+ * Module operations.
+ */
+
+/*
+ * vsock_vmci_init --
+ *
+ * Initialization routine for the VSockets module.
+ *
+ * Results: Zero on success, error code on failure.
+ *
+ * Side effects: The VSocket protocol family and socket operations are
+ * registered.
+ */
+
+static int __init vsock_vmci_init(void)
+{
+	int err;
+
+	request_module("vmci");
+
+	err = misc_register(&vsock_vmci_device);
+	if (err) {
+		pr_err("Failed to register misc device\n");
+		return -ENOENT;
+	}
+
+	err = vsock_vmci_register_with_vmci();
+	if (err) {
+		pr_err("Cannot register with VMCI device.\n");
+		goto err_misc_deregister;
+	}
+
+	err = proto_register(&vsock_vmci_proto, 1);	/* we want our slab */
+	if (err) {
+		pr_err("Cannot register vsock protocol.\n");
+		goto err_unregister_with_vmci;
+	}
+
+	err = sock_register(&vsock_vmci_family_ops);
+	if (err) {
+		pr_err("could not register af_vsock (%d) address family: %d\n",
+		       AF_VSOCK, err);
+		goto err_unregister_proto;
+	}
+
+	vsock_vmci_init_tables();
+	return 0;
+
+err_unregister_proto:
+	proto_unregister(&vsock_vmci_proto);
+err_unregister_with_vmci:
+	vsock_vmci_unregister_with_vmci();
+err_misc_deregister:
+	misc_deregister(&vsock_vmci_device);
+	return err;
+}
+
+/*
+ * VSocketVmciExit --
+ *
+ * VSockets module exit routine.
+ *
+ * Results: None.
+ *
+ * Side effects: Unregisters VSocket protocol family and socket operations.
+ */
+
+static void __exit vsock_vmci_exit(void)
+{
+	misc_deregister(&vsock_vmci_device);
+	sock_unregister(AF_VSOCK);
+	proto_unregister(&vsock_vmci_proto);
+	/* Need reset ? */
+	VSOCK_STATS_RESET();
+	vsock_vmci_unregister_with_vmci();
+}
+
+module_init(vsock_vmci_init);
+module_exit(vsock_vmci_exit);
+
+MODULE_AUTHOR("VMware, Inc.");
+MODULE_DESCRIPTION("VMware Virtual Socket Family");
+MODULE_VERSION(VSOCK_DRIVER_VERSION_STRING);
+MODULE_LICENSE("GPL v2");
+MODULE_ALIAS("vmware_vsock");
diff --git a/net/vmw_vsock/af_vsock.h b/net/vmw_vsock/af_vsock.h
new file mode 100644
index 0000000..c434afc
--- /dev/null
+++ b/net/vmw_vsock/af_vsock.h
@@ -0,0 +1,179 @@
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
+ * af_vsock.h --
+ *
+ * Definitions for Linux VSockets module.
+ */
+
+#ifndef __AF_VSOCK_H__
+#define __AF_VSOCK_H__
+
+#include <linux/kernel.h>
+#include <linux/workqueue.h>
+#include <linux/vmw_vmci_defs.h>
+#include <linux/vmw_vmci_api.h>
+
+#include "vsock_common.h"
+#include "vsock_packet.h"
+#include "notify.h"
+
+#define vsock_sk(__sk)    ((vsock_vmci_sock *)__sk)
+#define sk_vsock(__vsk)   (&(__vsk)->sk)
+
+typedef struct vsock_vmci_sock {
+	/* sk must be the first member. */
+	struct sock sk;
+	struct sockaddr_vm local_addr;
+	struct sockaddr_vm remote_addr;
+	/* Links for the global tables of bound and connected sockets. */
+	struct list_head bound_table;
+	struct list_head connected_table;
+	/*
+	 * Accessed without the socket lock held. This means it can never be
+	 * modified outsided of socket create or destruct.
+	 */
+	bool trusted;
+	bool cached_peer_allow_dgram;	/* Dgram communication allowed to
+					 * cached peer? */
+	vmci_id cached_peer;  /* Context ID of last dgram destination check. */
+	const struct cred *owner;
+	struct vmci_handle dg_handle;	/* For SOCK_DGRAM only. */
+	/* Rest are SOCK_STREAM only. */
+	struct vmci_handle qp_handle;
+	struct vmci_qp *qpair;
+	u64 produce_size;
+	u64 consume_size;
+	u64 queue_pair_size;
+	u64 queue_pair_min_size;
+	u64 queue_pair_max_size;
+	long connect_timeout;
+	vsock_vmci_notify notify;
+	vsock_vmci_notify_ops *notify_ops;
+	vmci_id attach_sub_id;
+	vmci_id detach_sub_id;
+	/* Listening socket that this came from. */
+	struct sock *listener;
+	/*
+	 * Used for pending list and accept queue during connection handshake.
+	 * The listening socket is the head for both lists.  Sockets created
+	 * for connection requests are placed in the pending list until they
+	 * are connected, at which point they are put in the accept queue list
+	 * so they can be accepted in accept().  If accept() cannot accept the
+	 * connection, it is marked as rejected so the cleanup function knows
+	 * to clean up the socket.
+	 */
+	struct list_head pending_links;
+	struct list_head accept_queue;
+	bool rejected;
+	struct delayed_work dwork;
+	u32 peer_shutdown;
+	bool sent_request;
+	bool ignore_connecting_rst;
+} vsock_vmci_sock;
+
+int vsock_vmci_send_control_pkt_bh(struct sockaddr_vm *src,
+				   struct sockaddr_vm *dst,
+				   vsock_packet_type type,
+				   u64 size,
+				   u64 mode,
+				   vsock_waiting_info *wait,
+				   struct vmci_handle handle);
+int vsock_vmci_reply_control_pkt_fast(vsock_packet *pkt,
+				      vsock_packet_type type, u64 size,
+				      u64 mode, vsock_waiting_info *wait,
+				      struct vmci_handle handle);
+int vsock_vmci_send_control_pkt(struct sock *sk, vsock_packet_type type,
+				u64 size, u64 mode,
+				vsock_waiting_info *wait,
+				vsock_proto_version version,
+				struct vmci_handle handle);
+
+s64 vsock_vmci_stream_has_data(vsock_vmci_sock *vsk);
+s64 vsock_vmci_stream_has_space(vsock_vmci_sock *vsk);
+
+#define VSOCK_SEND_RESET_BH(_dst, _src, _pkt)				\
+	((_pkt)->type == VSOCK_PACKET_TYPE_RST) ?			\
+	0 :								\
+	vsock_vmci_send_control_pkt_bh(					\
+		_dst, _src,						\
+		VSOCK_PACKET_TYPE_RST, 0,				\
+		0, NULL, VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_INVALID_BH(_dst, _src)				\
+	vsock_vmci_send_control_pkt_bh(_dst, _src,			\
+				       VSOCK_PACKET_TYPE_INVALID, 0,	\
+				       0, NULL, VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_WROTE_BH(_dst, _src)					\
+	vsock_vmci_send_control_pkt_bh(_dst, _src, VSOCK_PACKET_TYPE_WROTE, 0, \
+				       0, NULL, VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_READ_BH(_dst, _src)					\
+	vsock_vmci_send_control_pkt_bh((_dst), (_src),			\
+				       VSOCK_PACKET_TYPE_READ, 0,	\
+				       0, NULL, VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_RESET(_sk, _pkt)					\
+	((_pkt)->type == VSOCK_PACKET_TYPE_RST) ?			\
+	0 :								\
+	vsock_vmci_send_control_pkt(					\
+		_sk, VSOCK_PACKET_TYPE_RST,				\
+		0, 0, NULL, VSOCK_PROTO_INVALID,			\
+		VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_NEGOTIATE(_sk, _size)				\
+	vsock_vmci_send_control_pkt(_sk, VSOCK_PACKET_TYPE_NEGOTIATE,	\
+				    _size, 0, NULL, VSOCK_PROTO_INVALID, \
+				    VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_NEGOTIATE2(_sk, _size, signal_proto)			\
+	vsock_vmci_send_control_pkt(_sk, VSOCK_PACKET_TYPE_NEGOTIATE2,	\
+				    _size, 0, NULL, signal_proto,	\
+				    VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_QP_OFFER(_sk, _handle)				\
+	vsock_vmci_send_control_pkt(_sk, VSOCK_PACKET_TYPE_OFFER,	\
+				    0, 0, NULL, VSOCK_PROTO_INVALID, _handle)
+#define VSOCK_SEND_CONN_REQUEST(_sk, _size)				\
+	vsock_vmci_send_control_pkt(_sk, VSOCK_PACKET_TYPE_REQUEST,	\
+				    _size, 0, NULL, VSOCK_PROTO_INVALID, \
+				    VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_CONN_REQUEST2(_sk, _size, signal_proto)		\
+	vsock_vmci_send_control_pkt(_sk, VSOCK_PACKET_TYPE_REQUEST2,	\
+				    _size, 0, NULL, signal_proto,	\
+				    VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_ATTACH(_sk, _handle)					\
+	vsock_vmci_send_control_pkt(_sk, VSOCK_PACKET_TYPE_ATTACH,	\
+				    0, 0, NULL, VSOCK_PROTO_INVALID, _handle)
+#define VSOCK_SEND_WROTE(_sk)						\
+	vsock_vmci_send_control_pkt(_sk, VSOCK_PACKET_TYPE_WROTE,	\
+				    0, 0, NULL, VSOCK_PROTO_INVALID,	\
+				    VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_READ(_sk)						\
+	vsock_vmci_send_control_pkt(_sk, VSOCK_PACKET_TYPE_READ,	\
+				    0, 0, NULL, VSOCK_PROTO_INVALID,	\
+				    VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_SHUTDOWN(_sk, _mode)					\
+	vsock_vmci_send_control_pkt(_sk, VSOCK_PACKET_TYPE_SHUTDOWN,	\
+				    0, _mode, NULL, VSOCK_PROTO_INVALID, \
+				    VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_WAITING_WRITE(_sk, _wait_info)			\
+	vsock_vmci_send_control_pkt(_sk, VSOCK_PACKET_TYPE_WAITING_WRITE, \
+				    0, 0, _wait_info, VSOCK_PROTO_INVALID, \
+				    VMCI_INVALID_HANDLE)
+#define VSOCK_SEND_WAITING_READ(_sk, _wait_info)			\
+	vsock_vmci_send_control_pkt(_sk, VSOCK_PACKET_TYPE_WAITING_READ, \
+				    0, 0, _wait_info, VSOCK_PROTO_INVALID, \
+				    VMCI_INVALID_HANDLE)
+#define VSOCK_REPLY_RESET(_pkt)						\
+	vsock_vmci_reply_control_pkt_fast(_pkt, VSOCK_PACKET_TYPE_RST,	\
+					  0, 0, NULL, VMCI_INVALID_HANDLE)
+
+#endif /* __AF_VSOCK_H__ */
