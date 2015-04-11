From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 15/17] switch kernel_sendmsg() and kernel_recvmsg() to iov_iter_kvec()
Date: Sat, 11 Apr 2015 22:18:26 +0100
Message-ID: <1428787108-13650-15-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37886 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932631AbbDKVSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:31 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

For kernel_sendmsg() that eliminates the need to play with setfs();
for kernel_recvmsg() it does *not* - a couple of callers are using
it with non-NULL ->msg_control, which would be treated as userland
address on recvmsg side of things.

In all cases we are really setting a kvec-backed iov_iter, though.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/socket.c | 20 +++-----------------
 1 file changed, 3 insertions(+), 17 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index e5669ce..b6ceeda 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -627,18 +627,8 @@ EXPORT_SYMBOL(sock_sendmsg);
 int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size)
 {
-	mm_segment_t oldfs = get_fs();
-	int result;
-
-	set_fs(KERNEL_DS);
-	/*
-	 * the following is safe, since for compiler definitions of kvec and
-	 * iovec are identical, yielding the same in-core layout and alignment
-	 */
-	iov_iter_init(&msg->msg_iter, WRITE, (struct iovec *)vec, num, size);
-	result = sock_sendmsg(sock, msg, size);
-	set_fs(oldfs);
-	return result;
+	iov_iter_kvec(&msg->msg_iter, WRITE | ITER_KVEC, vec, num, size);
+	return sock_sendmsg(sock, msg, size);
 }
 EXPORT_SYMBOL(kernel_sendmsg);
 
@@ -755,12 +745,8 @@ int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 	mm_segment_t oldfs = get_fs();
 	int result;
 
+	iov_iter_kvec(&msg->msg_iter, READ | ITER_KVEC, vec, num, size);
 	set_fs(KERNEL_DS);
-	/*
-	 * the following is safe, since for compiler definitions of kvec and
-	 * iovec are identical, yielding the same in-core layout and alignment
-	 */
-	iov_iter_init(&msg->msg_iter, READ, (struct iovec *)vec, num, size);
 	result = sock_recvmsg(sock, msg, size, flags);
 	set_fs(oldfs);
 	return result;
-- 
2.1.4
