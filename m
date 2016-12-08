From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH v3 4/4] vsock: cancel packets when failing to connect
Date: Fri,  9 Dec 2016 01:12:36 +0800
Message-ID: <1481217156-7160-5-git-send-email-bergwolf@gmail.com>
References: <1481217156-7160-1-git-send-email-bergwolf@gmail.com>
 <1481217156-7160-2-git-send-email-bergwolf@gmail.com>
 <1481217156-7160-3-git-send-email-bergwolf@gmail.com>
 <1481217156-7160-4-git-send-email-bergwolf@gmail.com>
Cc: David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        Jorgen Hansen <jhansen@vmware.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32923 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754098AbcLHRNa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 12:13:30 -0500
In-Reply-To: <1481217156-7160-4-git-send-email-bergwolf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise we'll leave the packets queued until releasing vsock device.
E.g., if guest is slow to start up, resulting ETIMEDOUT on connect, guest
will get the connect requests from failed host sockets.

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 net/vmw_vsock/af_vsock.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 8a398b3..c73b03a 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1101,10 +1101,19 @@ static const struct proto_ops vsock_dgram_ops = {
 	.sendpage = sock_no_sendpage,
 };
 
+static int vsock_transport_cancel_pkt(struct vsock_sock *vsk)
+{
+	if (!transport->cancel_pkt)
+		return -EOPNOTSUPP;
+
+	return transport->cancel_pkt(vsk);
+}
+
 static void vsock_connect_timeout(struct work_struct *work)
 {
 	struct sock *sk;
 	struct vsock_sock *vsk;
+	int cancel = 0;
 
 	vsk = container_of(work, struct vsock_sock, dwork.work);
 	sk = sk_vsock(vsk);
@@ -1115,8 +1124,11 @@ static void vsock_connect_timeout(struct work_struct *work)
 		sk->sk_state = SS_UNCONNECTED;
 		sk->sk_err = ETIMEDOUT;
 		sk->sk_error_report(sk);
+		cancel = 1;
 	}
 	release_sock(sk);
+	if (cancel)
+		vsock_transport_cancel_pkt(vsk);
 
 	sock_put(sk);
 }
@@ -1223,11 +1235,13 @@ static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
 			err = sock_intr_errno(timeout);
 			sk->sk_state = SS_UNCONNECTED;
 			sock->state = SS_UNCONNECTED;
+			vsock_transport_cancel_pkt(vsk);
 			goto out_wait;
 		} else if (timeout == 0) {
 			err = -ETIMEDOUT;
 			sk->sk_state = SS_UNCONNECTED;
 			sock->state = SS_UNCONNECTED;
+			vsock_transport_cancel_pkt(vsk);
 			goto out_wait;
 		}
 
-- 
2.7.4
