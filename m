From: Reilly Grant <grantr@vmware.com>
Subject: [PATCH] VSOCK: Handle changes to the VMCI context ID.
Date: Mon,  1 Apr 2013 11:41:52 -0700
Message-ID: <1364841712-22810-1-git-send-email-grantr@vmware.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, Reilly Grant <grantr@vmware.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The VMCI context ID of a virtual machine may change at any time. There
is a VMCI event which signals this but datagrams may be processed before
this is handled. It is therefore necessary to be flexible about the
destination context ID of any datagrams received. (It can be assumed to
be correct because it is provided by the hypervisor.) The context ID on
existing sockets should be updated to reflect how the hypervisor is
currently referring to the system.

Signed-off-by: Reilly Grant <grantr@vmware.com>
Acked-by: Andy King <acking@vmware.com>
---
 net/vmw_vsock/af_vsock.c       |  6 +++---
 net/vmw_vsock/vmci_transport.c | 31 ++++++++++++++++++++-----------
 net/vmw_vsock/vsock_addr.c     | 10 ----------
 net/vmw_vsock/vsock_addr.h     |  2 --
 4 files changed, 23 insertions(+), 26 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index ca511c4..d8079da 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -207,7 +207,7 @@ static struct sock *__vsock_find_bound_socket(struct sockaddr_vm *addr)
 	struct vsock_sock *vsk;
 
 	list_for_each_entry(vsk, vsock_bound_sockets(addr), bound_table)
-		if (vsock_addr_equals_addr_any(addr, &vsk->local_addr))
+		if (addr->svm_port == vsk->local_addr.svm_port)
 			return sk_vsock(vsk);
 
 	return NULL;
@@ -220,8 +220,8 @@ static struct sock *__vsock_find_connected_socket(struct sockaddr_vm *src,
 
 	list_for_each_entry(vsk, vsock_connected_sockets(src, dst),
 			    connected_table) {
-		if (vsock_addr_equals_addr(src, &vsk->remote_addr)
-		    && vsock_addr_equals_addr(dst, &vsk->local_addr)) {
+		if (vsock_addr_equals_addr(src, &vsk->remote_addr) &&
+		    dst->svm_port == vsk->local_addr.svm_port) {
 			return sk_vsock(vsk);
 		}
 	}
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index faf81b8..9caa91c 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -472,19 +472,16 @@ static struct sock *vmci_transport_get_pending(
 	struct vsock_sock *vlistener;
 	struct vsock_sock *vpending;
 	struct sock *pending;
+	struct sockaddr_vm src;
+
+	vsock_addr_init(&src, pkt->dg.src.context, pkt->src_port);
 
 	vlistener = vsock_sk(listener);
 
 	list_for_each_entry(vpending, &vlistener->pending_links,
 			    pending_links) {
-		struct sockaddr_vm src;
-		struct sockaddr_vm dst;
-
-		vsock_addr_init(&src, pkt->dg.src.context, pkt->src_port);
-		vsock_addr_init(&dst, pkt->dg.dst.context, pkt->dst_port);
-
 		if (vsock_addr_equals_addr(&src, &vpending->remote_addr) &&
-		    vsock_addr_equals_addr(&dst, &vpending->local_addr)) {
+		    pkt->dst_port == vpending->local_addr.svm_port) {
 			pending = sk_vsock(vpending);
 			sock_hold(pending);
 			goto found;
@@ -749,10 +746,15 @@ static int vmci_transport_recv_stream_cb(void *data, struct vmci_datagram *dg)
 	 */
 	bh_lock_sock(sk);
 
-	if (!sock_owned_by_user(sk) && sk->sk_state == SS_CONNECTED)
-		vmci_trans(vsk)->notify_ops->handle_notify_pkt(
-				sk, pkt, true, &dst, &src,
-				&bh_process_pkt);
+	if (!sock_owned_by_user(sk)) {
+		/* The local context ID may be out of date, update it. */
+		vsk->local_addr.svm_cid = dst.svm_cid;
+
+		if (sk->sk_state == SS_CONNECTED)
+			vmci_trans(vsk)->notify_ops->handle_notify_pkt(
+					sk, pkt, true, &dst, &src,
+					&bh_process_pkt);
+	}
 
 	bh_unlock_sock(sk);
 
@@ -912,6 +914,9 @@ static void vmci_transport_recv_pkt_work(struct work_struct *work)
 
 	lock_sock(sk);
 
+	/* The local context ID may be out of date. */
+	vsock_sk(sk)->local_addr.svm_cid = pkt->dg.dst.context;
+
 	switch (sk->sk_state) {
 	case SS_LISTEN:
 		vmci_transport_recv_listen(sk, pkt);
@@ -968,6 +973,10 @@ static int vmci_transport_recv_listen(struct sock *sk,
 	pending = vmci_transport_get_pending(sk, pkt);
 	if (pending) {
 		lock_sock(pending);
+
+		/* The local context ID may be out of date. */
+		vsock_sk(pending)->local_addr.svm_cid = pkt->dg.dst.context;
+
 		switch (pending->sk_state) {
 		case SS_CONNECTING:
 			err = vmci_transport_recv_connecting_server(sk,
diff --git a/net/vmw_vsock/vsock_addr.c b/net/vmw_vsock/vsock_addr.c
index b7df1ae..ec2611b 100644
--- a/net/vmw_vsock/vsock_addr.c
+++ b/net/vmw_vsock/vsock_addr.c
@@ -64,16 +64,6 @@ bool vsock_addr_equals_addr(const struct sockaddr_vm *addr,
 }
 EXPORT_SYMBOL_GPL(vsock_addr_equals_addr);
 
-bool vsock_addr_equals_addr_any(const struct sockaddr_vm *addr,
-				const struct sockaddr_vm *other)
-{
-	return (addr->svm_cid == VMADDR_CID_ANY ||
-		other->svm_cid == VMADDR_CID_ANY ||
-		addr->svm_cid == other->svm_cid) &&
-	       addr->svm_port == other->svm_port;
-}
-EXPORT_SYMBOL_GPL(vsock_addr_equals_addr_any);
-
 int vsock_addr_cast(const struct sockaddr *addr,
 		    size_t len, struct sockaddr_vm **out_addr)
 {
diff --git a/net/vmw_vsock/vsock_addr.h b/net/vmw_vsock/vsock_addr.h
index cdfbcef..9ccd531 100644
--- a/net/vmw_vsock/vsock_addr.h
+++ b/net/vmw_vsock/vsock_addr.h
@@ -24,8 +24,6 @@ bool vsock_addr_bound(const struct sockaddr_vm *addr);
 void vsock_addr_unbind(struct sockaddr_vm *addr);
 bool vsock_addr_equals_addr(const struct sockaddr_vm *addr,
 			    const struct sockaddr_vm *other);
-bool vsock_addr_equals_addr_any(const struct sockaddr_vm *addr,
-				const struct sockaddr_vm *other);
 int vsock_addr_cast(const struct sockaddr *addr, size_t len,
 		    struct sockaddr_vm **out_addr);
 
-- 
1.8.1.5
