From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 19/32] [TIPC] Stream socket send indicates partial success if data partially sent.
Date: Thu, 22 Jun 2006 15:59:32 +0200
Message-ID: <1150984786178-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:51130 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030653AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 9c834fc..8cefacb 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -601,7 +601,8 @@ exit:
  * 
  * Used for SOCK_STREAM data.
  * 
- * Returns the number of bytes sent on success, or errno otherwise
+ * Returns the number of bytes sent on success (or partial success), 
+ * or errno if no data sent
  */
 
 
@@ -615,6 +616,7 @@ static int send_stream(struct kiocb *ioc
 	char __user *curr_start;
 	int curr_left;
 	int bytes_to_send;
+	int bytes_sent;
 	int res;
 	
 	if (likely(total_len <= TIPC_MAX_USER_MSG_SIZE))
@@ -637,11 +639,11 @@ static int send_stream(struct kiocb *ioc
 	 * of small iovec entries into send_packet().
 	 */
 
-	my_msg = *m;
-	curr_iov = my_msg.msg_iov;
-	curr_iovlen = my_msg.msg_iovlen;
+	curr_iov = m->msg_iov;
+	curr_iovlen = m->msg_iovlen;
 	my_msg.msg_iov = &my_iov;
 	my_msg.msg_iovlen = 1;
+	bytes_sent = 0;
 
 	while (curr_iovlen--) {
 		curr_start = curr_iov->iov_base;
@@ -652,16 +654,18 @@ static int send_stream(struct kiocb *ioc
 				? curr_left : TIPC_MAX_USER_MSG_SIZE;
 			my_iov.iov_base = curr_start;
 			my_iov.iov_len = bytes_to_send;
-                        if ((res = send_packet(iocb, sock, &my_msg, 0)) < 0)
-                                return res;
+                        if ((res = send_packet(iocb, sock, &my_msg, 0)) < 0) {
+				return bytes_sent ? bytes_sent : res;
+			}
 			curr_left -= bytes_to_send;
 			curr_start += bytes_to_send;
+			bytes_sent += bytes_to_send;
 		}
 
 		curr_iov++;
 	}
 
-	return total_len;
+	return bytes_sent;
 }
 
 /**
-- 
1.4.0

