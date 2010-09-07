From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH] net: remove address space warnings in net/socket.c
Date: Tue,  7 Sep 2010 22:55:00 +0900
Message-ID: <1283867700-24132-1-git-send-email-namhyung@gmail.com>
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Casts __kernel to __user pointer require __force markup, so add it. Also
sock_get/setsockopt() takes @optval and/or @optlen arguments as user pointers
but were taking kernel pointers, use new variables 'uoptval' and/or 'uoptlen'
to fix it. These remove following warnings from sparse:

 net/socket.c:1922:46: warning: cast adds address space to expression (<asn:1>)
 net/socket.c:3061:61: warning: incorrect type in argument 4 (different address spaces)
 net/socket.c:3061:61:    expected char [noderef] <asn:1>*optval
 net/socket.c:3061:61:    got char *optval
 net/socket.c:3061:69: warning: incorrect type in argument 5 (different address spaces)
 net/socket.c:3061:69:    expected int [noderef] <asn:1>*optlen
 net/socket.c:3061:69:    got int *optlen
 net/socket.c:3063:67: warning: incorrect type in argument 4 (different address spaces)
 net/socket.c:3063:67:    expected char [noderef] <asn:1>*optval
 net/socket.c:3063:67:    got char *optval
 net/socket.c:3064:45: warning: incorrect type in argument 5 (different address spaces)
 net/socket.c:3064:45:    expected int [noderef] <asn:1>*optlen
 net/socket.c:3064:45:    got int *optlen
 net/socket.c:3078:61: warning: incorrect type in argument 4 (different address spaces)
 net/socket.c:3078:61:    expected char [noderef] <asn:1>*optval
 net/socket.c:3078:61:    got char *optval
 net/socket.c:3080:67: warning: incorrect type in argument 4 (different address spaces)
 net/socket.c:3080:67:    expected char [noderef] <asn:1>*optval
 net/socket.c:3080:67:    got char *optval

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 net/socket.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 2270b94..cb43f22 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1919,7 +1919,8 @@ SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned, flags)
 		 * Afterwards, it will be a kernel pointer. Thus the compiler-assisted
 		 * checking falls down on this.
 		 */
-		if (copy_from_user(ctl_buf, (void __user *)msg_sys.msg_control,
+		if (copy_from_user(ctl_buf,
+				   (void __user __force *)msg_sys.msg_control,
 				   ctl_len))
 			goto out_freectl;
 		msg_sys.msg_control = ctl_buf;
@@ -3054,14 +3055,19 @@ int kernel_getsockopt(struct socket *sock, int level, int optname,
 			char *optval, int *optlen)
 {
 	mm_segment_t oldfs = get_fs();
+	char __user *uoptval;
+	int __user *uoptlen;
 	int err;
 
+	uoptval = (char __user __force *) optval;
+	uoptlen = (int __user __force *) optlen;
+
 	set_fs(KERNEL_DS);
 	if (level == SOL_SOCKET)
-		err = sock_getsockopt(sock, level, optname, optval, optlen);
+		err = sock_getsockopt(sock, level, optname, uoptval, uoptlen);
 	else
-		err = sock->ops->getsockopt(sock, level, optname, optval,
-					    optlen);
+		err = sock->ops->getsockopt(sock, level, optname, uoptval,
+					    uoptlen);
 	set_fs(oldfs);
 	return err;
 }
@@ -3071,13 +3077,16 @@ int kernel_setsockopt(struct socket *sock, int level, int optname,
 			char *optval, unsigned int optlen)
 {
 	mm_segment_t oldfs = get_fs();
+	char __user *uoptval;
 	int err;
 
+	uoptval = (char __user __force *) optval;
+
 	set_fs(KERNEL_DS);
 	if (level == SOL_SOCKET)
-		err = sock_setsockopt(sock, level, optname, optval, optlen);
+		err = sock_setsockopt(sock, level, optname, uoptval, optlen);
 	else
-		err = sock->ops->setsockopt(sock, level, optname, optval,
+		err = sock->ops->setsockopt(sock, level, optname, uoptval,
 					    optlen);
 	set_fs(oldfs);
 	return err;
-- 
1.7.2.2
