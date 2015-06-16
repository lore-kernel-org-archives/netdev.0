From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [RFC PATCH 1/2] sctp: add new getsockopt option SCTP_SOCKOPT_PEELOFF_KERNEL
Date: Tue, 16 Jun 2015 19:42:32 -0300
Message-ID: <7c625395f94fd7bdeb3b28fe74f2c6ae1a96be6b.1434492495.git.marcelo.leitner@gmail.com>
References: <cover.1434492495.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755205AbbFPWmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 18:42:42 -0400
In-Reply-To: <cover.1434492495.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP has this operation to peel off associations from a given socket and
create a new socket using this association. We currently have two ways
to use this operation:
- via getsockopt(), on which it will also create and return a file
  descriptor for this new socket
- via sctp_do_peeloff(), which is for kernel only

The caveat with using sctp_do_peeloff() directly is that it creates a
dependency to SCTP module, while all other operations are handled via
kernel_{socket,sendmsg,getsockopt...}() interface. This causes the
kernel to load SCTP module even when it's not directly used

This patch then creates a new sockopt that is to be used only by kernel
users of this protocol. This new sockopt will not allocate a file
descriptor but instead just return the socket pointer directly.

If called by an user application, it will just return -EPERM.

Even though it's not intended for user applications, it's listed under
uapi header. That's because hidding this wouldn't add any extra security
and to keep the sockopt list in one place, so it's easy to check
available numbers to use.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/uapi/linux/sctp.h | 12 ++++++++++++
 net/sctp/socket.c         | 39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+)

diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index ce70fe6b45df3e841c35accbdb6379c16563893c..b3aad3ce456ab3c1ebf4d81fdb7269ba40b3d92a 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -105,6 +105,10 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_SOCKOPT_BINDX_ADD	100	/* BINDX requests for adding addrs */
 #define SCTP_SOCKOPT_BINDX_REM	101	/* BINDX requests for removing addrs. */
 #define SCTP_SOCKOPT_PEELOFF	102	/* peel off association. */
+#define SCTP_SOCKOPT_PEELOFF_KERNEL	103	/* peel off association.
+						 * only valid for kernel
+						 * users
+						 */
 /* Options 104-106 are deprecated and removed. Do not use this space */
 #define SCTP_SOCKOPT_CONNECTX_OLD	107	/* CONNECTX old requests. */
 #define SCTP_GET_PEER_ADDRS	108		/* Get all peer address. */
@@ -892,6 +896,14 @@ typedef struct {
 	int sd;
 } sctp_peeloff_arg_t;
 
+/* This is the union that is passed as an argument(optval) to
+ * getsockopt(SCTP_SOCKOPT_PEELOFF_KERNEL).
+ */
+typedef union {
+	sctp_assoc_t associd;
+	struct socket *socket;
+} sctp_peeloff_kernel_arg_t;
+
 /*
  *  Peer Address Thresholds socket option
  */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f09de7fac2e6acddad8b2e046dbf626e329cb674..dab6f9be260229f012e10e8f67c80ce99c0d2d06 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4448,6 +4448,32 @@ int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp)
 }
 EXPORT_SYMBOL(sctp_do_peeloff);
 
+static int sctp_getsockopt_peeloff_kernel(struct sock *sk, int len,
+					  char __user *optval, int __user *optlen)
+{
+	sctp_peeloff_kernel_arg_t peeloff;
+	struct socket *newsock;
+	int retval = 0;
+
+	if (len < sizeof(sctp_peeloff_kernel_arg_t))
+		return -EINVAL;
+	len = sizeof(sctp_peeloff_kernel_arg_t);
+	if (copy_from_user(&peeloff, optval, len))
+		return -EFAULT;
+
+	retval = sctp_do_peeloff(sk, peeloff.associd, &newsock);
+	if (retval < 0)
+		goto out;
+
+	peeloff.socket = newsock;
+	if (copy_to_user(optval, &peeloff, len)) {
+		sock_release(newsock);
+		return -EFAULT;
+	}
+out:
+	return retval;
+}
+
 static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval, int __user *optlen)
 {
 	sctp_peeloff_arg_t peeloff;
@@ -5943,6 +5969,11 @@ static int sctp_getsockopt_recvnxtinfo(struct sock *sk,	int len,
 	return 0;
 }
 
+static inline bool sctp_is_kernel(void)
+{
+	return segment_eq(get_fs(), KERNEL_DS);
+}
+
 static int sctp_getsockopt(struct sock *sk, int level, int optname,
 			   char __user *optval, int __user *optlen)
 {
@@ -5986,6 +6017,14 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_SOCKOPT_PEELOFF:
 		retval = sctp_getsockopt_peeloff(sk, len, optval, optlen);
 		break;
+	case SCTP_SOCKOPT_PEELOFF_KERNEL:
+		if (!sctp_is_kernel()) {
+			retval = -EPERM;
+			break;
+		}
+		retval = sctp_getsockopt_peeloff_kernel(sk, len, optval,
+							optlen);
+		break;
 	case SCTP_PEER_ADDR_PARAMS:
 		retval = sctp_getsockopt_peer_addr_params(sk, len, optval,
 							  optlen);
-- 
2.4.1
