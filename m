From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v3] net: don't return uninitialized addresses on concurrent socket shutdown
Date: Sat, 16 Nov 2013 20:19:16 +0100
Message-ID: <20131116191916.GC16541@order.stressinduktion.org>
References: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com> <CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com> <20131116054344.GG26901@order.stressinduktion.org> <20131116054814.GH26901@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: mpb <mpb.mail@gmail.com>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47319 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483Ab3KPTTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 14:19:17 -0500
Content-Disposition: inline
In-Reply-To: <20131116054814.GH26901@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a blocking read waits on a socket which gets concurrently shut down we
return 0 as error and so indicate success to the socket functions which
thus copies an uninitialized stack allocated address back to the user.

Fix this by introducing a new AF_INVALID sa_family marker and check if the
recvmsg function overwrote it. In case it was not overwritten, clear the
address with zeros (AF_UNSPEC) before returning it to the user. IMHO we
should only increase msg.msg_namelen (if we have to truncate the address),
so don't clear msg.msg_namelen.

This patch fixes the problem for recvfrom, recvmsg and recvmmsg.

Reported-by: mpb <mpb.mail@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/socket.h | 2 ++
 net/socket.c           | 6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 445ef75..bdf9205 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -182,6 +182,8 @@ struct ucred {
 #define AF_VSOCK	40	/* vSockets			*/
 #define AF_MAX		41	/* For now.. */
 
+#define AF_INVALID	((__kernel_sa_family_t)(~0U))
+
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
 #define PF_UNIX		AF_UNIX
diff --git a/net/socket.c b/net/socket.c
index c226ace..8361e15 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1834,6 +1834,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
 	if (!sock)
 		goto out;
 
+	address.ss_family = AF_INVALID;
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
 	msg.msg_iovlen = 1;
@@ -1847,6 +1848,8 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
 	err = sock_recvmsg(sock, &msg, size, flags);
 
 	if (err >= 0 && addr != NULL) {
+		if (unlikely(address.ss_family == AF_INVALID))
+			memset(&address, 0, sizeof(address));
 		err2 = move_addr_to_user(&address,
 					 msg.msg_namelen, addr, addr_len);
 		if (err2 < 0)
@@ -2226,6 +2229,7 @@ static int ___sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 	 *      kernel msghdr to use the kernel address space)
 	 */
 
+	addr.ss_family = AF_INVALID;
 	uaddr = (__force void __user *)msg_sys->msg_name;
 	uaddr_len = COMPAT_NAMELEN(msg);
 	if (MSG_CMSG_COMPAT & flags) {
@@ -2248,6 +2252,8 @@ static int ___sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 	len = err;
 
 	if (uaddr != NULL) {
+		if (unlikely(addr.ss_family == AF_INVALID))
+			memset(&addr, 0, sizeof(addr));
 		err = move_addr_to_user(&addr,
 					msg_sys->msg_namelen, uaddr,
 					uaddr_len);
-- 
1.8.3.1
