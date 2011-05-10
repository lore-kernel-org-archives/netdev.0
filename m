From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/21] tipc: Abort excessive send requests as early as possible
Date: Tue, 10 May 2011 16:44:31 -0400
Message-ID: <1305060277-15600-16-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52428 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701Ab1EJUpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:12 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Adds checks to TIPC's socket send routines to promptly detect and
abort attempts to send more than 66,000 bytes in a single TIPC
message or more than 2**31-1 bytes in a single TIPC byte stream request.
In addition, this ensures that the number of iovecs in a send request
does not exceed the limits of a standard integer variable.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc.h |    2 +-
 net/tipc/socket.c    |   13 +++++++++++++
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/linux/tipc.h b/include/linux/tipc.h
index a5b994a..f2d9009 100644
--- a/include/linux/tipc.h
+++ b/include/linux/tipc.h
@@ -101,7 +101,7 @@ static inline unsigned int tipc_node(__u32 addr)
  * Limiting values for messages
  */
 
-#define TIPC_MAX_USER_MSG_SIZE	66000
+#define TIPC_MAX_USER_MSG_SIZE	66000U
 
 /*
  * Message importance levels
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 29d94d5..e1c7917 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -535,6 +535,9 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 	if (unlikely((m->msg_namelen < sizeof(*dest)) ||
 		     (dest->family != AF_TIPC)))
 		return -EINVAL;
+	if ((total_len > TIPC_MAX_USER_MSG_SIZE) ||
+	    (m->msg_iovlen > (unsigned)INT_MAX))
+		return -EMSGSIZE;
 
 	if (iocb)
 		lock_sock(sk);
@@ -640,6 +643,10 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 	if (unlikely(dest))
 		return send_msg(iocb, sock, m, total_len);
 
+	if ((total_len > TIPC_MAX_USER_MSG_SIZE) ||
+	    (m->msg_iovlen > (unsigned)INT_MAX))
+		return -EMSGSIZE;
+
 	if (iocb)
 		lock_sock(sk);
 
@@ -723,6 +730,12 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 		goto exit;
 	}
 
+	if ((total_len > (unsigned)INT_MAX) ||
+	    (m->msg_iovlen > (unsigned)INT_MAX)) {
+		res = -EMSGSIZE;
+		goto exit;
+	}
+
 	/*
 	 * Send each iovec entry using one or more messages
 	 *
-- 
1.7.4.4

