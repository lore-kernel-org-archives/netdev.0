From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 07/12] l2tp: don't BUG_ON sk_socket being NULL
Date: Tue, 19 Mar 2013 16:11:18 +0000
Message-ID: <1363709483-24021-8-git-send-email-tparkin@katalix.com>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36147 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932842Ab3CSQLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:32 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is valid for an existing struct sock object to have a NULL sk_socket
pointer, so don't BUG_ON in l2tp_tunnel_del_work if that should occur.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 45373fe..e841ef2 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1412,19 +1412,21 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
 		return;
 
 	sock = sk->sk_socket;
-	BUG_ON(!sock);
 
-	/* If the tunnel socket was created directly by the kernel, use the
-	 * sk_* API to release the socket now.  Otherwise go through the
-	 * inet_* layer to shut the socket down, and let userspace close it.
+	/* If the tunnel socket was created by userspace, then go through the
+	 * inet layer to shut the socket down, and let userspace close it.
+	 * Otherwise, if we created the socket directly within the kernel, use
+	 * the sk API to release it here.
 	 * In either case the tunnel resources are freed in the socket
 	 * destructor when the tunnel socket goes away.
 	 */
-	if (sock->file == NULL) {
-		kernel_sock_shutdown(sock, SHUT_RDWR);
-		sk_release_kernel(sk);
+	if (tunnel->fd >= 0) {
+		if (sock)
+			inet_shutdown(sock, 2);
 	} else {
-		inet_shutdown(sock, 2);
+		if (sock)
+			kernel_sock_shutdown(sock, SHUT_RDWR);
+		sk_release_kernel(sk);
 	}
 
 	l2tp_tunnel_sock_put(sk);
-- 
1.7.9.5
