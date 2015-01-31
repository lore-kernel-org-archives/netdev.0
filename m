From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 06/18] make the users of rxrpc_kernel_send_data() set kvec-backed msg_iter properly
Date: Sat, 31 Jan 2015 03:56:32 +0000
Message-ID: <1422676604-18533-6-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54991 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756578AbbAaD4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 22:56:46 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

... which makes the games with set_fs() in rxrpc_kernel_send_data() useless.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/afs/rxrpc.c        | 14 +++++++-------
 net/rxrpc/ar-output.c |  3 ---
 2 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 06e14bf..dbc732e 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -306,8 +306,8 @@ static int afs_send_pages(struct afs_call *call, struct msghdr *msg,
 
 			_debug("- range %u-%u%s",
 			       offset, to, msg->msg_flags ? " [more]" : "");
-			iov_iter_init(&msg->msg_iter, WRITE,
-				      (struct iovec *) iov, 1, to - offset);
+			iov_iter_kvec(&msg->msg_iter, WRITE | ITER_KVEC,
+				      iov, 1, to - offset);
 
 			/* have to change the state *before* sending the last
 			 * packet as RxRPC might give us the reply before it
@@ -384,7 +384,7 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 
 	msg.msg_name		= NULL;
 	msg.msg_namelen		= 0;
-	iov_iter_init(&msg.msg_iter, WRITE, (struct iovec *)iov, 1,
+	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC, iov, 1,
 		      call->request_size);
 	msg.msg_control		= NULL;
 	msg.msg_controllen	= 0;
@@ -770,7 +770,7 @@ static int afs_deliver_cm_op_id(struct afs_call *call, struct sk_buff *skb,
 void afs_send_empty_reply(struct afs_call *call)
 {
 	struct msghdr msg;
-	struct iovec iov[1];
+	struct kvec iov[1];
 
 	_enter("");
 
@@ -778,7 +778,7 @@ void afs_send_empty_reply(struct afs_call *call)
 	iov[0].iov_len		= 0;
 	msg.msg_name		= NULL;
 	msg.msg_namelen		= 0;
-	iov_iter_init(&msg.msg_iter, WRITE, iov, 0, 0);	/* WTF? */
+	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC, iov, 0, 0);	/* WTF? */
 	msg.msg_control		= NULL;
 	msg.msg_controllen	= 0;
 	msg.msg_flags		= 0;
@@ -805,7 +805,7 @@ void afs_send_empty_reply(struct afs_call *call)
 void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
 {
 	struct msghdr msg;
-	struct iovec iov[1];
+	struct kvec iov[1];
 	int n;
 
 	_enter("");
@@ -814,7 +814,7 @@ void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
 	iov[0].iov_len		= len;
 	msg.msg_name		= NULL;
 	msg.msg_namelen		= 0;
-	iov_iter_init(&msg.msg_iter, WRITE, iov, 1, len);
+	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC, iov, 1, len);
 	msg.msg_control		= NULL;
 	msg.msg_controllen	= 0;
 	msg.msg_flags		= 0;
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 963a5b9..8331c95 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -232,10 +232,7 @@ int rxrpc_kernel_send_data(struct rxrpc_call *call, struct msghdr *msg,
 		   call->state != RXRPC_CALL_SERVER_SEND_REPLY) {
 		ret = -EPROTO; /* request phase complete for this client call */
 	} else {
-		mm_segment_t oldfs = get_fs();
-		set_fs(KERNEL_DS);
 		ret = rxrpc_send_data(NULL, call->socket, call, msg, len);
-		set_fs(oldfs);
 	}
 
 	release_sock(&call->socket->sk);
-- 
2.1.4
