From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] sctp: Add peeloff-flags socket option
Date: Thu, 29 Jun 2017 14:13:40 -0400
Message-ID: <20170629181340.12423-1-nhorman@tuxdriver.com>
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andreas Steinmetz <ast@domdv.de>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48919 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752136AbdF2SOL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 14:14:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on a request raised on the sctp devel list, there is a need to
augment the sctp_peeloff operation while specifying the O_CLOEXEC and
O_NONBLOCK flags (simmilar to the socket syscall).  Since modifying the
SCTP_SOCKOPT_PEELOFF socket option would break user space ABI for existing
programs, this patch creates a new socket option
SCTP_SOCKOPT_PEELOFF_FLAGS, which accepts a third flags parameter to
allow atomic assignment of the socket descriptor flags.

Tested successfully by myself and the requestor

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Andreas Steinmetz <ast@domdv.de>
CC: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 fs/file.c                 |  1 +
 include/uapi/linux/sctp.h |  6 ++++
 net/sctp/socket.c         | 92 ++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 83 insertions(+), 16 deletions(-)

diff --git a/fs/file.c b/fs/file.c
index 1c2972e..a4521da 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -807,6 +807,7 @@ void set_close_on_exec(unsigned int fd, int flag)
 		__clear_close_on_exec(fd, fdt);
 	spin_unlock(&files->file_lock);
 }
+EXPORT_SYMBOL(set_close_on_exec);
 
 bool get_close_on_exec(unsigned int fd)
 {
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index ced9d8b..6217ff8 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -121,6 +121,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_RESET_STREAMS	119
 #define SCTP_RESET_ASSOC	120
 #define SCTP_ADD_STREAMS	121
+#define SCTP_SOCKOPT_PEELOFF_FLAGS 122
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
@@ -978,6 +979,11 @@ typedef struct {
 	int sd;
 } sctp_peeloff_arg_t;
 
+typedef struct {
+	sctp_peeloff_arg_t p_arg;
+	unsigned flags;
+} sctp_peeloff_flags_arg_t;
+
 /*
  *  Peer Address Thresholds socket option
  */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 7b6e20e..7341053 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4933,20 +4933,12 @@ int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp)
 }
 EXPORT_SYMBOL(sctp_do_peeloff);
 
-static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval, int __user *optlen)
+static int sctp_getsockopt_peeloff_common(struct sock *sk, sctp_peeloff_arg_t *peeloff, struct file **newfile, unsigned flags)
 {
-	sctp_peeloff_arg_t peeloff;
 	struct socket *newsock;
-	struct file *newfile;
 	int retval = 0;
 
-	if (len < sizeof(sctp_peeloff_arg_t))
-		return -EINVAL;
-	len = sizeof(sctp_peeloff_arg_t);
-	if (copy_from_user(&peeloff, optval, len))
-		return -EFAULT;
-
-	retval = sctp_do_peeloff(sk, peeloff.associd, &newsock);
+	retval = sctp_do_peeloff(sk, peeloff->associd, &newsock);
 	if (retval < 0)
 		goto out;
 
@@ -4957,25 +4949,90 @@ static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval
 		goto out;
 	}
 
-	newfile = sock_alloc_file(newsock, 0, NULL);
-	if (IS_ERR(newfile)) {
+	*newfile = sock_alloc_file(newsock, 0, NULL);
+	if (IS_ERR(*newfile)) {
 		put_unused_fd(retval);
 		sock_release(newsock);
-		return PTR_ERR(newfile);
+		retval = PTR_ERR(*newfile);
+		*newfile = NULL;
+		return retval;
 	}
 
 	pr_debug("%s: sk:%p, newsk:%p, sd:%d\n", __func__, sk, newsock->sk,
 		 retval);
+	
+	peeloff->sd = retval;
+
+	set_close_on_exec(peeloff->sd, !!(flags & SOCK_CLOEXEC));
+
+	if (flags & SOCK_NONBLOCK)
+		(*newfile)->f_flags |= O_NONBLOCK;
+out:
+	return retval;
+}
+
+static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval, int __user *optlen)
+{
+	sctp_peeloff_arg_t peeloff;
+	struct file *newfile = NULL;
+	int retval = 0;
+
+	if (len < sizeof(sctp_peeloff_arg_t))
+		return -EINVAL;
+	len = sizeof(sctp_peeloff_arg_t);
+	if (copy_from_user(&peeloff, optval, len))
+		return -EFAULT;
+
+	retval = sctp_getsockopt_peeloff_common(sk, &peeloff, &newfile, 0);
+	if (retval < 0)
+		goto out;
 
 	/* Return the fd mapped to the new socket.  */
 	if (put_user(len, optlen)) {
-		fput(newfile);
+		if (newfile)
+			fput(newfile);
 		put_unused_fd(retval);
 		return -EFAULT;
 	}
-	peeloff.sd = retval;
+
 	if (copy_to_user(optval, &peeloff, len)) {
-		fput(newfile);
+		if (newfile)
+			fput(newfile);
+		put_unused_fd(retval);
+		return -EFAULT;
+	}
+	fd_install(retval, newfile);
+out:
+	return retval;
+}
+
+static int sctp_getsockopt_peeloff_flags(struct sock *sk, int len, char __user *optval, int __user *optlen)
+{
+	sctp_peeloff_flags_arg_t peeloff;
+	struct file *newfile = NULL;
+	int retval = 0;
+
+	if (len < sizeof(sctp_peeloff_flags_arg_t))
+		return -EINVAL;
+	len = sizeof(sctp_peeloff_flags_arg_t);
+	if (copy_from_user(&peeloff, optval, len))
+		return -EFAULT;
+
+	retval = sctp_getsockopt_peeloff_common(sk, &peeloff.p_arg, &newfile, peeloff.flags);
+	if (retval < 0)
+		goto out;
+
+	/* Return the fd mapped to the new socket.  */
+	if (put_user(len, optlen)) {
+		if (newfile)
+			fput(newfile);
+		put_unused_fd(retval);
+		return -EFAULT;
+	}
+
+	if (copy_to_user(optval, &peeloff, len)) {
+		if (newfile)
+			fput(newfile);
 		put_unused_fd(retval);
 		return -EFAULT;
 	}
@@ -6758,6 +6815,9 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_SOCKOPT_PEELOFF:
 		retval = sctp_getsockopt_peeloff(sk, len, optval, optlen);
 		break;
+	case SCTP_SOCKOPT_PEELOFF_FLAGS:
+		retval = sctp_getsockopt_peeloff_flags(sk, len, optval, optlen);
+		break;
 	case SCTP_PEER_ADDR_PARAMS:
 		retval = sctp_getsockopt_peer_addr_params(sk, len, optval,
 							  optlen);
-- 
2.9.4
