From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Sat, 23 Jul 2011 00:12:53 +0900
Message-ID: <201107230012.HED65612.JFVSFOOOMHtFLQ@I-love.SAKURA.ne.jp>
References: <201107191754.22391.paul.moore@hp.com>
	<201107200142.p6K1gKYg077046@www262.sakura.ne.jp>
	<201107211721.14511.paul.moore@hp.com>
	<201107222041.FGG51092.OOQFFLOtMVFJHS@I-love.SAKURA.ne.jp>
	<201107222127.GBG51007.FStQFVOHOFOLJM@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: casey@schaufler-ca.com, anton@samba.org, davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107222127.GBG51007.FStQFVOHOFOLJM@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think the regression for SMACK can be fixed with below patch.

Should I pass nosec flags down to "struct security_operations"->sendmsg()
so that SELinux checks sock_has_perm() for only once when multiple different
destination's addresses are passed to sendmmsg()?

static int selinux_socket_sendmsg(struct socket *sock, struct msghdr *msg,
				  int size, int nosec)
{
	return nosec ? 0 : sock_has_perm(current, sock->sk, SOCKET__WRITE);
}
----------------------------------------
[PATCH] net: Fix security_socket_sendmsg() bypass problem.

The sendmmsg() introduced by commit 228e548e "net: Add sendmmsg socket system
call" is capable of sending to multiple different destinations. However,
security_socket_sendmsg() is called for only once even if multiple different
destination's addresses are passed to sendmmsg().

SMACK is using destination's address for checking sendmsg() permission.
Therefore, we need to call security_socket_sendmsg() for each destination
address rather than only the first destination address.

Fix this problem by removing nosec flags.
Also, remove sock_sendmsg_nosec() because it is no longer used.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [3.0+]
---
 net/socket.c |   28 +++++++---------------------
 1 file changed, 7 insertions(+), 21 deletions(-)

--- linux-3.0.orig/net/socket.c
+++ linux-3.0/net/socket.c
@@ -580,20 +580,6 @@ int sock_sendmsg(struct socket *sock, st
 }
 EXPORT_SYMBOL(sock_sendmsg);
 
-int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg, size_t size)
-{
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
-}
-
 int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size)
 {
@@ -1872,7 +1858,7 @@ SYSCALL_DEFINE2(shutdown, int, fd, int, 
 #define COMPAT_FLAGS(msg)	COMPAT_MSG(msg, msg_flags)
 
 static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
-			 struct msghdr *msg_sys, unsigned flags, int nosec)
+			 struct msghdr *msg_sys, unsigned flags)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
@@ -1953,8 +1939,7 @@ static int __sys_sendmsg(struct socket *
 
 	if (sock->file->f_flags & O_NONBLOCK)
 		msg_sys->msg_flags |= MSG_DONTWAIT;
-	err = (nosec ? sock_sendmsg_nosec : sock_sendmsg)(sock, msg_sys,
-							  total_len);
+	err = sock_sendmsg(sock, msg_sys, total_len);
 
 out_freectl:
 	if (ctl_buf != ctl)
@@ -1979,7 +1964,7 @@ SYSCALL_DEFINE3(sendmsg, int, fd, struct
 	if (!sock)
 		goto out;
 
-	err = __sys_sendmsg(sock, msg, &msg_sys, flags, 0);
+	err = __sys_sendmsg(sock, msg, &msg_sys, flags);
 
 	fput_light(sock->file, fput_needed);
 out:
@@ -2014,18 +1999,19 @@ int __sys_sendmmsg(int fd, struct mmsghd
 
 	while (datagrams < vlen) {
 		/*
-		 * No need to ask LSM for more than the first datagram.
+		 * Need to ask LSM every time in case LSM might check
+		 * destination's address.
 		 */
 		if (MSG_CMSG_COMPAT & flags) {
 			err = __sys_sendmsg(sock, (struct msghdr __user *)compat_entry,
-					    &msg_sys, flags, datagrams);
+					    &msg_sys, flags);
 			if (err < 0)
 				break;
 			err = __put_user(err, &compat_entry->msg_len);
 			++compat_entry;
 		} else {
 			err = __sys_sendmsg(sock, (struct msghdr __user *)entry,
-					    &msg_sys, flags, datagrams);
+					    &msg_sys, flags);
 			if (err < 0)
 				break;
 			err = put_user(err, &entry->msg_len);
