From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH 4/4] vsock: cancel packets when failing to connect
Date: Wed,  7 Dec 2016 18:00:21 +0800
Message-ID: <1481104821-77294-5-git-send-email-bergwolf@gmail.com>
References: <1481104821-77294-1-git-send-email-bergwolf@gmail.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, Peng Tao <bergwolf@gmail.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34964 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752248AbcLGKCv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 05:02:51 -0500
In-Reply-To: <1481104821-77294-1-git-send-email-bergwolf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise we'll leave the packets queued until releasing vsock device.
E.g., if guest is slow to start up, resulting ETIMEDOUT on connect, guest
will get the connect requests from failed host sockets.

Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 include/linux/virtio_vsock.h            | 7 +++++++
 net/vmw_vsock/af_vsock.c                | 7 +++++++
 net/vmw_vsock/virtio_transport_common.c | 7 -------
 3 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
index b92e88d..ff6850a 100644
--- a/include/linux/virtio_vsock.h
+++ b/include/linux/virtio_vsock.h
@@ -156,4 +156,11 @@ void virtio_transport_inc_tx_pkt(struct virtio_vsock_sock *vvs, struct virtio_vs
 u32 virtio_transport_get_credit(struct virtio_vsock_sock *vvs, u32 wanted);
 void virtio_transport_put_credit(struct virtio_vsock_sock *vvs, u32 credit);
 
+static inline const struct virtio_transport *virtio_transport_get_ops(void)
+{
+	const struct vsock_transport *t = vsock_core_get_transport();
+
+	return container_of(t, struct virtio_transport, transport);
+}
+
 #endif /* _LINUX_VIRTIO_VSOCK_H */
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 8a398b3..ebb50d6 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -104,6 +104,7 @@
 #include <linux/unistd.h>
 #include <linux/wait.h>
 #include <linux/workqueue.h>
+#include <linux/virtio_vsock.h>
 #include <net/sock.h>
 #include <net/af_vsock.h>
 
@@ -1105,6 +1106,7 @@ static void vsock_connect_timeout(struct work_struct *work)
 {
 	struct sock *sk;
 	struct vsock_sock *vsk;
+	int cancel = 0;
 
 	vsk = container_of(work, struct vsock_sock, dwork.work);
 	sk = sk_vsock(vsk);
@@ -1115,8 +1117,11 @@ static void vsock_connect_timeout(struct work_struct *work)
 		sk->sk_state = SS_UNCONNECTED;
 		sk->sk_err = ETIMEDOUT;
 		sk->sk_error_report(sk);
+		cancel = 1;
 	}
 	release_sock(sk);
+	if (cancel)
+		virtio_transport_get_ops()->cancel_pkt(vsk);
 
 	sock_put(sk);
 }
@@ -1223,11 +1228,13 @@ static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
 			err = sock_intr_errno(timeout);
 			sk->sk_state = SS_UNCONNECTED;
 			sock->state = SS_UNCONNECTED;
+			virtio_transport_get_ops()->cancel_pkt(vsk);
 			goto out_wait;
 		} else if (timeout == 0) {
 			err = -ETIMEDOUT;
 			sk->sk_state = SS_UNCONNECTED;
 			sock->state = SS_UNCONNECTED;
+			virtio_transport_get_ops()->cancel_pkt(vsk);
 			goto out_wait;
 		}
 
diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index cc1eeb5..72c5dff 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -25,13 +25,6 @@
 /* How long to wait for graceful shutdown of a connection */
 #define VSOCK_CLOSE_TIMEOUT (8 * HZ)
 
-static const struct virtio_transport *virtio_transport_get_ops(void)
-{
-	const struct vsock_transport *t = vsock_core_get_transport();
-
-	return container_of(t, struct virtio_transport, transport);
-}
-
 struct virtio_vsock_pkt *
 virtio_transport_alloc_pkt(struct virtio_vsock_pkt_info *info,
 			   size_t len,
-- 
2.7.4
