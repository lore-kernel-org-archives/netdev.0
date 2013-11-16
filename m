From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2] socket: don't return uninitialized addresses on concurrent socket shutdown
Date: Sat, 16 Nov 2013 06:48:14 +0100
Message-ID: <20131116054814.GH26901@order.stressinduktion.org>
References: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com> <CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com> <20131116054344.GG26901@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: mpb <mpb.mail@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46456 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349Ab3KPFsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 00:48:15 -0500
Content-Disposition: inline
In-Reply-To: <20131116054344.GG26901@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a blocking read waits on a socket which gets concurrently shut down we
return 0 as error and so indicate success to the socket functions which
thus copy an uninitialized stack allocated address back to the user.
Fix this by clearing the 128 byte size (on x86-64) address first.

This patch fixes the problem for recvfrom, recvmsg and recvmmsg.

Reported-by: mpb <mpb.mail@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
Sorry, grabbed the wrong patch file.

 net/socket.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/socket.c b/net/socket.c
index c226ace..a44f29c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1834,6 +1834,8 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
 	if (!sock)
 		goto out;
 
+	if (addr != NULL)
+		memset(&address, 0, sizeof(address));
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
 	msg.msg_iovlen = 1;
@@ -2228,6 +2230,8 @@ static int ___sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 
 	uaddr = (__force void __user *)msg_sys->msg_name;
 	uaddr_len = COMPAT_NAMELEN(msg);
+	if (uaddr != NULL)
+		memset(&addr, 0, sizeof(addr));
 	if (MSG_CMSG_COMPAT & flags) {
 		err = verify_compat_iovec(msg_sys, iov, &addr, VERIFY_WRITE);
 	} else
-- 
1.8.3.1
