From: Asias He <asias@redhat.com>
Subject: [PATCH 1/4] VSOCK: Introduce vsock_auto_bind helper
Date: Thu, 20 Jun 2013 17:20:30 +0800
Message-ID: <1371720033-19714-2-git-send-email-asias@redhat.com>
References: <1371720033-19714-1-git-send-email-asias@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andy King <acking@vmware.com>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>, Asias He <asias@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755535Ab3FTJUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 05:20:53 -0400
In-Reply-To: <1371720033-19714-1-git-send-email-asias@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This peace of code is called tree times, let's have a helper for it.

Signed-off-by: Asias He <asias@redhat.com>
---
 net/vmw_vsock/af_vsock.c | 49 +++++++++++++++++++++---------------------------
 1 file changed, 21 insertions(+), 28 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 3f77f42..b0b362a 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -165,6 +165,18 @@ static struct list_head vsock_bind_table[VSOCK_HASH_SIZE + 1];
 static struct list_head vsock_connected_table[VSOCK_HASH_SIZE];
 static DEFINE_SPINLOCK(vsock_table_lock);
 
+/* Autobind this socket to the local address if necessary. */
+static int vsock_auto_bind(struct vsock_sock *vsk)
+{
+	struct sock *sk = sk_vsock(vsk);
+	struct sockaddr_vm local_addr;
+
+	if (vsock_addr_bound(&vsk->local_addr))
+		return 0;
+	vsock_addr_init(&local_addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
+	return __vsock_bind(sk, &local_addr);
+}
+
 static void vsock_init_tables(void)
 {
 	int i;
@@ -956,15 +968,10 @@ static int vsock_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 	lock_sock(sk);
 
-	if (!vsock_addr_bound(&vsk->local_addr)) {
-		struct sockaddr_vm local_addr;
-
-		vsock_addr_init(&local_addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
-		err = __vsock_bind(sk, &local_addr);
-		if (err != 0)
-			goto out;
+	err = vsock_auto_bind(vsk);
+	if (err)
+		goto out;
 
-	}
 
 	/* If the provided message contains an address, use that.  Otherwise
 	 * fall back on the socket's remote handle (if it has been connected).
@@ -1038,15 +1045,9 @@ static int vsock_dgram_connect(struct socket *sock,
 
 	lock_sock(sk);
 
-	if (!vsock_addr_bound(&vsk->local_addr)) {
-		struct sockaddr_vm local_addr;
-
-		vsock_addr_init(&local_addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
-		err = __vsock_bind(sk, &local_addr);
-		if (err != 0)
-			goto out;
-
-	}
+	err = vsock_auto_bind(vsk);
+	if (err)
+		goto out;
 
 	if (!transport->dgram_allow(remote_addr->svm_cid,
 				    remote_addr->svm_port)) {
@@ -1163,17 +1164,9 @@ static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
 		memcpy(&vsk->remote_addr, remote_addr,
 		       sizeof(vsk->remote_addr));
 
-		/* Autobind this socket to the local address if necessary. */
-		if (!vsock_addr_bound(&vsk->local_addr)) {
-			struct sockaddr_vm local_addr;
-
-			vsock_addr_init(&local_addr, VMADDR_CID_ANY,
-					VMADDR_PORT_ANY);
-			err = __vsock_bind(sk, &local_addr);
-			if (err != 0)
-				goto out;
-
-		}
+		err = vsock_auto_bind(vsk);
+		if (err)
+			goto out;
 
 		sk->sk_state = SS_CONNECTING;
 
-- 
1.8.1.4
