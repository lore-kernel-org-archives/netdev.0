From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: [RESEND PATCH] net/socket.c : introduce helper function do_sock_sendmsg
 to replace reduplicate code
Date: Fri, 5 Dec 2014 15:14:23 +0800
Message-ID: <54815B4F.50408@cn.fujitsu.com>
References: <1416799125-13972-1-git-send-email-guz.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416799125-13972-1-git-send-email-guz.fnst@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce helper function do_sock_sendmsg() to simplify sock_sendmsg{_nosec},
and replace reduplicate code.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
---
 net/socket.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index fe20c31..2a6f3c6 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -651,7 +651,8 @@ static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	return err ?: __sock_sendmsg_nosec(iocb, sock, msg, size);
 }
 
-int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
+static int do_sock_sendmsg(struct socket *sock, struct msghdr *msg,
+			   size_t size, bool nosec)
 {
 	struct kiocb iocb;
 	struct sock_iocb siocb;
@@ -659,25 +660,22 @@ int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 
 	init_sync_kiocb(&iocb, NULL);
 	iocb.private = &siocb;
-	ret = __sock_sendmsg(&iocb, sock, msg, size);
+	ret = nosec ? __sock_sendmsg_nosec(&iocb, sock, msg, size) :
+		      __sock_sendmsg(&iocb, sock, msg, size);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
 	return ret;
 }
+
+int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
+{
+	return do_sock_sendmsg(sock, msg, size, false);
+}
 EXPORT_SYMBOL(sock_sendmsg);
 
 static int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg, size_t size)
 {
-	struct kiocb iocb;
-	struct sock_iocb siocb;
-	int ret;
-
-	init_sync_kiocb(&iocb, NULL);
-	iocb.private = &siocb;
-	ret = __sock_sendmsg_nosec(&iocb, sock, msg, size);
-	if (-EIOCBQUEUED == ret)
-		ret = wait_on_sync_kiocb(&iocb);
-	return ret;
+	return do_sock_sendmsg(sock, msg, size, true);
 }
 
 int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
-- 
1.7.7

.
