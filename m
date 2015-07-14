From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2 1/2] sctp: add new getsockopt option SCTP_SOCKOPT_PEELOFF_KERNEL
Date: Tue, 14 Jul 2015 14:13:24 -0300
Message-ID: <6091a8542d13f43fbe1abfa25062d28d15b15e66.1436891629.git.marcelo.leitner@gmail.com>
References: <cover.1436891629.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59357 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751885AbbGNRN5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 13:13:57 -0400
In-Reply-To: <cover.1436891629.git.marcelo.leitner@gmail.com>
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
kernel to load SCTP module even when it's not really used.

This patch then creates a new sockopt that is to be used only by kernel
users of this protocol. This new sockopt will not allocate a file
descriptor but instead just return the socket pointer directly.

Kernel users are actually identified by if the parent socket has or not
a fd attached to it. If not, it's a kernel a user.

If called by an user application, it will just return -EPERM.

Even though it's not intended for user applications, it's listed under
uapi header. That's because hidding this wouldn't add any extra security
and to keep the sockopt list in one place, so it's easy to check
available numbers to use.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/uapi/linux/sctp.h | 12 ++++++++++++
 net/sctp/socket.c         | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

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
index f1a65398f3118ab5d3a884e9c875620560e6b5ef..7968de7a1aeabd5cd0a0398461dbf2081bd4c5b7 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4504,6 +4504,39 @@ out:
 	return retval;
 }
 
+static int sctp_getsockopt_peeloff_kernel(struct sock *sk, int len,
+					  char __user *optval, int __user *optlen)
+{
+	sctp_peeloff_kernel_arg_t peeloff;
+	struct socket *newsock;
+	int retval = 0;
+
+	/* We only allow this operation if parent socket also hadn't a
+	 * file descriptor allocated to it, mainly as a way to make sure
+	 * that this is really a kernel socket.
+	 */
+	if (sk->sk_socket->file)
+		return -EPERM;
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
 /* 7.1.13 Peer Address Parameters (SCTP_PEER_ADDR_PARAMS)
  *
  * Applications can enable or disable heartbeats for any peer address of
@@ -5991,6 +6024,10 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_SOCKOPT_PEELOFF:
 		retval = sctp_getsockopt_peeloff(sk, len, optval, optlen);
 		break;
+	case SCTP_SOCKOPT_PEELOFF_KERNEL:
+		retval = sctp_getsockopt_peeloff_kernel(sk, len, optval,
+							optlen);
+		break;
 	case SCTP_PEER_ADDR_PARAMS:
 		retval = sctp_getsockopt_peer_addr_params(sk, len, optval,
 							  optlen);
-- 
2.4.1
