From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 4/4] tipc: Fix bugs in sending of large amounts of byte-stream data
Date: Wed, 27 Oct 2010 15:29:33 -0400
Message-ID: <1288207773-25448-5-git-send-email-paul.gortmaker@windriver.com>
References: <1288207773-25448-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	drosenberg@vsecurity.com, jon.maloy@ericsson.com,
	torvalds@linux-foundation.org, security@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43520 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755806Ab0J0Tdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:33:52 -0400
In-Reply-To: <1288207773-25448-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Enhances the routine that sends data for SOCK_STREAM sockets to
fix the following issues:

- Uses "size_t" to specify the size and number of iovec array entries
  to avoid the risk of accidentally truncating data.
- No longer uses comparisons that mix signed and unsigned size values.
- Adds check to terminate sending early if continuation would require
  returning a value too large to fit in an "int".

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
---
 net/tipc/socket.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 33217fc..081eda5 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -703,12 +703,12 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 	struct msghdr my_msg;
 	struct iovec my_iov;
 	struct iovec *curr_iov;
-	int curr_iovlen;
+	size_t curr_iovlen;
 	char __user *curr_start;
 	u32 hdr_size;
-	int curr_left;
-	int bytes_to_send;
-	int bytes_sent;
+	size_t curr_left;
+	size_t bytes_to_send;
+	size_t bytes_sent;
 	int res;
 
 	lock_sock(sk);
@@ -757,15 +757,19 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 
 		while (curr_left) {
 			bytes_to_send = tport->max_pkt - hdr_size;
-			if (bytes_to_send > TIPC_MAX_USER_MSG_SIZE)
-				bytes_to_send = TIPC_MAX_USER_MSG_SIZE;
+			if (bytes_to_send > (size_t)TIPC_MAX_USER_MSG_SIZE)
+				bytes_to_send = (size_t)TIPC_MAX_USER_MSG_SIZE;
 			if (curr_left < bytes_to_send)
 				bytes_to_send = curr_left;
+			if (bytes_to_send > (size_t)INT_MAX - bytes_sent) {
+				res = (int)bytes_sent;
+				goto exit;
+			}
 			my_iov.iov_base = curr_start;
 			my_iov.iov_len = bytes_to_send;
 			if ((res = send_packet(NULL, sock, &my_msg, 0)) < 0) {
 				if (bytes_sent)
-					res = bytes_sent;
+					res = (int)bytes_sent;
 				goto exit;
 			}
 			curr_left -= bytes_to_send;
@@ -775,7 +779,7 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 
 		curr_iov++;
 	}
-	res = bytes_sent;
+	res = (int)bytes_sent;
 exit:
 	release_sock(sk);
 	return res;
-- 
1.7.1.GIT

