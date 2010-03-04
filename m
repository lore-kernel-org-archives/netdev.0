From: Kenan Kalajdzic <kenan@unix.ba>
Subject: [PATCH] socket: Merge getsockname and getpeername into a single
 function
Date: Thu, 4 Mar 2010 04:26:13 +0100
Message-ID: <20100304032612.GB9016@home.unix.ba>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-359.bluehost.com ([66.147.249.253]:50819 "HELO
	outbound-mail-359.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754083Ab0CDD3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 22:29:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code of getsockname is almost identical to getpeername. This patch removes
duplicate code and merges both functions into a single common function.

Signed-off-by: Kenan Kalajdzic <kenan@unix.ba>
---
 net/socket.c |   50 +++++++++++++++++---------------------------------
 1 files changed, 17 insertions(+), 33 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 769c386..526e1f5 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1593,12 +1593,12 @@ out:
 }
 
 /*
- *	Get the local address ('name') of a socket object. Move the obtained
- *	name to user space.
+ *  Common code for getsockname and getpeername system calls
+ *  Get local or remote address ('name') of a socket object.
+ *  Move the obtained name to user space.
  */
-
-SYSCALL_DEFINE3(getsockname, int, fd, struct sockaddr __user *, usockaddr,
-		int __user *, usockaddr_len)
+static int common_getsockpeername(int fd, struct sockaddr __user *usockaddr,
+				int __user * usockaddr_len, int remote)
 {
 	struct socket *sock;
 	struct sockaddr_storage address;
@@ -1608,50 +1608,34 @@ SYSCALL_DEFINE3(getsockname, int, fd, struct sockaddr __user *, usockaddr,
 	if (!sock)
 		goto out;
 
-	err = security_socket_getsockname(sock);
+	if (remote)
+		err = security_socket_getpeername(sock);
+	else
+		err = security_socket_getsockname(sock);
 	if (err)
 		goto out_put;
 
-	err = sock->ops->getname(sock, (struct sockaddr *)&address, &len, 0);
+	err = sock->ops->getname(sock, (struct sockaddr *)&address, &len, remote);
 	if (err)
 		goto out_put;
-	err = move_addr_to_user((struct sockaddr *)&address, len, usockaddr, usockaddr_len);
 
+	err = move_addr_to_user((struct sockaddr *)&address, len, usockaddr, usockaddr_len);
 out_put:
 	fput_light(sock->file, fput_needed);
 out:
 	return err;
 }
 
-/*
- *	Get the remote address ('name') of a socket object. Move the obtained
- *	name to user space.
- */
+SYSCALL_DEFINE3(getsockname, int, fd, struct sockaddr __user *, usockaddr,
+		int __user *, usockaddr_len)
+{
+	return common_getsockpeername(fd, usockaddr, usockaddr_len, 0);
+}
 
 SYSCALL_DEFINE3(getpeername, int, fd, struct sockaddr __user *, usockaddr,
 		int __user *, usockaddr_len)
 {
-	struct socket *sock;
-	struct sockaddr_storage address;
-	int len, err, fput_needed;
-
-	sock = sockfd_lookup_light(fd, &err, &fput_needed);
-	if (sock != NULL) {
-		err = security_socket_getpeername(sock);
-		if (err) {
-			fput_light(sock->file, fput_needed);
-			return err;
-		}
-
-		err =
-		    sock->ops->getname(sock, (struct sockaddr *)&address, &len,
-				       1);
-		if (!err)
-			err = move_addr_to_user((struct sockaddr *)&address, len, usockaddr,
-						usockaddr_len);
-		fput_light(sock->file, fput_needed);
-	}
-	return err;
+	return common_getsockpeername(fd, usockaddr, usockaddr_len, 1);
 }
 
 /*
-- 
1.6.4
