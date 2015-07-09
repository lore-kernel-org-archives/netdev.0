From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 1/2] sctp: SCTP_SOCKOPT_PEELOFF return socket pointer for kernel users
Date: Thu,  9 Jul 2015 11:15:19 -0300
Message-ID: <4dfd0ee7ac0aac0791812217e990e2ae7ff86955.1434645734.git.marcelo.leitner@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44390 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146AbbGIOP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 10:15:29 -0400
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

This patch then updates SCTP_SOCKOPT_PEELOFF so that for kernel users of
this protocol it will not allocate a file descriptor but instead just
return the socket pointer directly.

If called by an user application it will work as before.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/uapi/linux/sctp.h |  9 ++++++---
 net/sctp/socket.c         | 13 +++++++++++++
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index ce70fe6b45df3e841c35accbdb6379c16563893c..9e15fc06ba553c7e33f729872bb2dfaa2e21b0d8 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -887,9 +887,12 @@ struct sctp_assoc_stats {
 /* This is the structure that is passed as an argument(optval) to
  * getsockopt(SCTP_SOCKOPT_PEELOFF).
  */
-typedef struct {
-	sctp_assoc_t associd;
-	int sd;
+typedef union {
+	struct {
+		sctp_assoc_t associd;
+		int sd;
+	};
+	void *sock;
 } sctp_peeloff_arg_t;
 
 /*
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f09de7fac2e6acddad8b2e046dbf626e329cb674..ff1138558687e15ee486e84c0916ad81f01ca734 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4465,6 +4465,19 @@ static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval
 	if (retval < 0)
 		goto out;
 
+	/* If the owner of parent sock is the kernel, that is, if a file
+	 * descriptor wasn't allocated to it, return the socket pointer
+	 * directly instead of allocating a file descriptor.
+	 */
+	if (!sk->sk_socket->file) {
+		peeloff.sock = newsock;
+		if (copy_to_user(optval, &peeloff, len)) {
+			sock_release(newsock);
+			return -EFAULT;
+		}
+		return retval;
+	}
+
 	/* Map the socket to an unused fd that can be returned to the user.  */
 	retval = get_unused_fd_flags(0);
 	if (retval < 0) {
-- 
2.4.1
