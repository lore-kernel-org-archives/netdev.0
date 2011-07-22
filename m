From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Sat, 23 Jul 2011 02:42:01 +0900
Message-ID: <201107230242.HJH39096.OSMOVQOLFFFHJt@I-love.SAKURA.ne.jp>
References: <201107222041.FGG51092.OOQFFLOtMVFJHS@I-love.SAKURA.ne.jp>
	<201107222127.GBG51007.FStQFVOHOFOLJM@I-love.SAKURA.ne.jp>
	<201107230012.HED65612.JFVSFOOOMHtFLQ@I-love.SAKURA.ne.jp>
	<20110722.082224.688620059032914637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: casey@schaufler-ca.com, anton@samba.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110722.082224.688620059032914637.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Ugh, this takes away a non-trivial part of the performance gain of
> sendmmsg().
> 
> I would instead rather that you check ahead of time whether this
> actually is a send to different addresses.  If they are all the
> same, keep the nosec code path.
> 
OK. Something like this? Not tested at all.
----------------------------------------
[PATCH 1/3] net: Add "static" to sock_sendmsg_nosec().

sock_sendmsg_nosec() is called from only __sys_sendmsg().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [3.0+]
---
 net/socket.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-3.0.orig/net/socket.c
+++ linux-3.0/net/socket.c
@@ -580,7 +580,8 @@ int sock_sendmsg(struct socket *sock, st
 }
 EXPORT_SYMBOL(sock_sendmsg);
 
-int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg, size_t size)
+static int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg,
+			      size_t size)
 {
 	struct kiocb iocb;
 	struct sock_iocb siocb;

----------------------------------------
[PATCH 2/3] net: Introduce helper for copying msghdr struct.

This patch introduces copy_msghdr_to_kenrel().
This helper is used for avoiding race condition when comparing destination's
addresses passed to sendmmsg().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [3.0+]
---
 net/socket.c |   50 ++++++++++++++++++++++++++++++++++----------------
 1 file changed, 34 insertions(+), 16 deletions(-)

--- linux-3.0.orig/net/socket.c
+++ linux-3.0/net/socket.c
@@ -1872,11 +1872,29 @@ SYSCALL_DEFINE2(shutdown, int, fd, int, 
 #define COMPAT_NAMELEN(msg)	COMPAT_MSG(msg, msg_namelen)
 #define COMPAT_FLAGS(msg)	COMPAT_MSG(msg, msg_flags)
 
-static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
-			 struct msghdr *msg_sys, unsigned flags, int nosec)
+/**
+ * move_msghdr_to_kernel - copy a "struct msghdr" into kernel space
+ *
+ * @msg:     "struct msghdr" in user space
+ * @msg_sys: "struct msghdr" in kernel space
+ * @flags:   sendmsg() flags.
+ */
+static int copy_msghdr_to_kernel(struct msghdr __user *msg,
+				 struct msghdr *msg_sys, unsigned flags)
+{
+	if (MSG_CMSG_COMPAT & flags) {
+		struct compat_msghdr __user *msg_compat =
+			(struct compat_msghdr __user *) msg;
+		if (get_compat_msghdr(msg_sys, msg_compat))
+			return -EFAULT;
+	} else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
+		return -EFAULT;
+	return 0;
+}
+
+static int __sys_sendmsg(struct socket *sock, struct msghdr *msg_sys,
+			 unsigned flags, int nosec)
 {
-	struct compat_msghdr __user *msg_compat =
-	    (struct compat_msghdr __user *)msg;
 	struct sockaddr_storage address;
 	struct iovec iovstack[UIO_FASTIOV], *iov = iovstack;
 	unsigned char ctl[sizeof(struct cmsghdr) + 20]
@@ -1885,13 +1903,6 @@ static int __sys_sendmsg(struct socket *
 	unsigned char *ctl_buf = ctl;
 	int err, ctl_len, iov_size, total_len;
 
-	err = -EFAULT;
-	if (MSG_CMSG_COMPAT & flags) {
-		if (get_compat_msghdr(msg_sys, msg_compat))
-			return -EFAULT;
-	} else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
-		return -EFAULT;
-
 	/* do not move before msg_sys is valid */
 	err = -EMSGSIZE;
 	if (msg_sys->msg_iovlen > UIO_MAXIOV)
@@ -1980,7 +1991,9 @@ SYSCALL_DEFINE3(sendmsg, int, fd, struct
 	if (!sock)
 		goto out;
 
-	err = __sys_sendmsg(sock, msg, &msg_sys, flags, 0);
+	err = copy_msghdr_to_kernel(msg, &msg_sys, flags);
+	if (!err)
+		err = __sys_sendmsg(sock, &msg_sys, flags, 0);
 
 	fput_light(sock->file, fput_needed);
 out:
@@ -2018,15 +2031,20 @@ int __sys_sendmmsg(int fd, struct mmsghd
 		 * No need to ask LSM for more than the first datagram.
 		 */
 		if (MSG_CMSG_COMPAT & flags) {
-			err = __sys_sendmsg(sock, (struct msghdr __user *)compat_entry,
-					    &msg_sys, flags, datagrams);
+			err = copy_msghdr_to_kernel((struct msghdr __user *)
+						    compat_entry, &msg_sys,
+						    flags);
+			if (err)
+				break;
+			err = __sys_sendmsg(sock, &msg_sys, flags, datagrams);
 			if (err < 0)
 				break;
 			err = __put_user(err, &compat_entry->msg_len);
 			++compat_entry;
 		} else {
-			err = __sys_sendmsg(sock, (struct msghdr __user *)entry,
-					    &msg_sys, flags, datagrams);
+			err = copy_msghdr_to_kernel((struct msghdr __user *)
+						    entry, &msg_sys, flags);
+			err = __sys_sendmsg(sock, &msg_sys, flags, datagrams);
 			if (err < 0)
 				break;
 			err = put_user(err, &entry->msg_len);

----------------------------------------
[PATCH 3/3] net: Fix security_socket_sendmsg() bypass problem.

The sendmmsg() introduced by commit 228e548e "net: Add sendmmsg socket system
call" is capable of sending to multiple different destinations. However,
security_socket_sendmsg() is called for only once even if multiple different
destination's addresses are passed to sendmmsg().

SMACK is using destination's address for checking sendmsg() permission.
Therefore, we need to call security_socket_sendmsg() for each destination
address rather than the first destination address.

Fix this problem by calling security_socket_sendmsg() for each destination
address.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [3.0+]
---
 net/socket.c |   52 +++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 35 insertions(+), 17 deletions(-)

--- linux-3.0.orig/net/socket.c
+++ linux-3.0/net/socket.c
@@ -2011,7 +2011,7 @@ int __sys_sendmmsg(int fd, struct mmsghd
 	struct socket *sock;
 	struct mmsghdr __user *entry;
 	struct compat_mmsghdr __user *compat_entry;
-	struct msghdr msg_sys;
+	struct msghdr *msg_tmp = NULL;
 
 	datagrams = 0;
 
@@ -2026,27 +2026,44 @@ int __sys_sendmmsg(int fd, struct mmsghd
 	entry = mmsg;
 	compat_entry = (struct compat_mmsghdr __user *)mmsg;
 
+	/*
+	 * Remember all destination addresses to kernel memory because LSM
+	 * might check destination addresses.
+	 */
+	err = -ENOMEM;
+	msg_tmp = kmalloc(vlen * sizeof(*msg_tmp), GFP_KERNEL);
+	if (!msg_tmp || msg_tmp == ZERO_SIZE_PTR)
+		goto out_put;
 	while (datagrams < vlen) {
-		/*
-		 * No need to ask LSM for more than the first datagram.
-		 */
+		struct msghdr *msg_sys = &msg_tmp[datagrams];
+		err = copy_msghdr_to_kernel((MSG_CMSG_COMPAT & flags) ?
+					    (struct msghdr __user *)
+					    compat_entry :
+					    (struct msghdr __user *) entry,
+					    &msg_tmp[datagrams], flags);
+		if (err)
+			goto out_put;
+		/* Ask LSM only once for each destination address. */
+		if (msg_sys->msg_namelen && msg_sys->msg_name)
+			for (err = 0; err < datagrams; err++) {
+				if (msg_tmp[err].msg_namelen ==
+				    msg_sys->msg_namelen &&
+				    msg_tmp[err].msg_name &&
+				    !memcmp(msg_tmp[err].msg_name,
+					    msg_sys->msg_name,
+					    msg_sys->msg_namelen))
+					break;
+			}
+		/* Ask LSM every time if destination address is not passed. */
+		else
+			err = datagrams;
+		err = __sys_sendmsg(sock, msg_sys, flags, err < datagrams);
+		if (err < 0)
+			break;
 		if (MSG_CMSG_COMPAT & flags) {
-			err = copy_msghdr_to_kernel((struct msghdr __user *)
-						    compat_entry, &msg_sys,
-						    flags);
-			if (err)
-				break;
-			err = __sys_sendmsg(sock, &msg_sys, flags, datagrams);
-			if (err < 0)
-				break;
 			err = __put_user(err, &compat_entry->msg_len);
 			++compat_entry;
 		} else {
-			err = copy_msghdr_to_kernel((struct msghdr __user *)
-						    entry, &msg_sys, flags);
-			err = __sys_sendmsg(sock, &msg_sys, flags, datagrams);
-			if (err < 0)
-				break;
 			err = put_user(err, &entry->msg_len);
 			++entry;
 		}
@@ -2058,6 +2075,7 @@ int __sys_sendmmsg(int fd, struct mmsghd
 
 out_put:
 	fput_light(sock->file, fput_needed);
+	kfree(msg_tmp);
 
 	if (err == 0)
 		return datagrams;
