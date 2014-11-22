From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 14/17] vmci_transport: switch ->enqeue_dgram,
 ->enqueue_stream and ->dequeue_stream to msghdr
Date: Sat, 22 Nov 2014 04:37:59 +0000
Message-ID: <20141122043759.GN30478@ZenIV.linux.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <20141120.182339.972861702759954603.davem@davemloft.net>
 <20141121.122615.1091044030302005883.davem@davemloft.net>
 <20141122042856.GZ7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	nab@linux-iscsi.org, hch@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141122042856.GZ7996@ZenIV.linux.org.uk>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/net/af_vsock.h         |    6 +++---
 net/vmw_vsock/af_vsock.c       |    6 +++---
 net/vmw_vsock/vmci_transport.c |   14 +++++++-------
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index 4282778..0d87674 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -103,14 +103,14 @@ struct vsock_transport {
 	int (*dgram_dequeue)(struct kiocb *kiocb, struct vsock_sock *vsk,
 			     struct msghdr *msg, size_t len, int flags);
 	int (*dgram_enqueue)(struct vsock_sock *, struct sockaddr_vm *,
-			     struct iovec *, size_t len);
+			     struct msghdr *, size_t len);
 	bool (*dgram_allow)(u32 cid, u32 port);
 
 	/* STREAM. */
 	/* TODO: stream_bind() */
-	ssize_t (*stream_dequeue)(struct vsock_sock *, struct iovec *,
+	ssize_t (*stream_dequeue)(struct vsock_sock *, struct msghdr *,
 				  size_t len, int flags);
-	ssize_t (*stream_enqueue)(struct vsock_sock *, struct iovec *,
+	ssize_t (*stream_enqueue)(struct vsock_sock *, struct msghdr *,
 				  size_t len);
 	s64 (*stream_has_data)(struct vsock_sock *);
 	s64 (*stream_has_space)(struct vsock_sock *);
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 85d232b..1d0e39c 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1013,7 +1013,7 @@ static int vsock_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		goto out;
 	}
 
-	err = transport->dgram_enqueue(vsk, remote_addr, msg->msg_iov, len);
+	err = transport->dgram_enqueue(vsk, remote_addr, msg, len);
 
 out:
 	release_sock(sk);
@@ -1617,7 +1617,7 @@ static int vsock_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		 */
 
 		written = transport->stream_enqueue(
-				vsk, msg->msg_iov,
+				vsk, msg,
 				len - total_written);
 		if (written < 0) {
 			err = -ENOMEM;
@@ -1739,7 +1739,7 @@ vsock_stream_recvmsg(struct kiocb *kiocb,
 				break;
 
 			read = transport->stream_dequeue(
-					vsk, msg->msg_iov,
+					vsk, msg,
 					len - copied, flags);
 			if (read < 0) {
 				err = -ENOMEM;
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index a57ddef..c1c0389 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1697,7 +1697,7 @@ static int vmci_transport_dgram_bind(struct vsock_sock *vsk,
 static int vmci_transport_dgram_enqueue(
 	struct vsock_sock *vsk,
 	struct sockaddr_vm *remote_addr,
-	struct iovec *iov,
+	struct msghdr *msg,
 	size_t len)
 {
 	int err;
@@ -1714,7 +1714,7 @@ static int vmci_transport_dgram_enqueue(
 	if (!dg)
 		return -ENOMEM;
 
-	memcpy_fromiovec(VMCI_DG_PAYLOAD(dg), iov, len);
+	memcpy_from_msg(VMCI_DG_PAYLOAD(dg), msg, len);
 
 	dg->dst = vmci_make_handle(remote_addr->svm_cid,
 				   remote_addr->svm_port);
@@ -1835,22 +1835,22 @@ static int vmci_transport_connect(struct vsock_sock *vsk)
 
 static ssize_t vmci_transport_stream_dequeue(
 	struct vsock_sock *vsk,
-	struct iovec *iov,
+	struct msghdr *msg,
 	size_t len,
 	int flags)
 {
 	if (flags & MSG_PEEK)
-		return vmci_qpair_peekv(vmci_trans(vsk)->qpair, iov, len, 0);
+		return vmci_qpair_peekv(vmci_trans(vsk)->qpair, msg->msg_iov, len, 0);
 	else
-		return vmci_qpair_dequev(vmci_trans(vsk)->qpair, iov, len, 0);
+		return vmci_qpair_dequev(vmci_trans(vsk)->qpair, msg->msg_iov, len, 0);
 }
 
 static ssize_t vmci_transport_stream_enqueue(
 	struct vsock_sock *vsk,
-	struct iovec *iov,
+	struct msghdr *msg,
 	size_t len)
 {
-	return vmci_qpair_enquev(vmci_trans(vsk)->qpair, iov, len, 0);
+	return vmci_qpair_enquev(vmci_trans(vsk)->qpair, msg->msg_iov, len, 0);
 }
 
 static s64 vmci_transport_stream_has_data(struct vsock_sock *vsk)
-- 
1.7.10.4
