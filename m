From: <erik.hugne@ericsson.com>
Subject: [PATCH v2] tipc: set sk_err correctly when connection fails
Date: Wed, 28 Aug 2013 09:29:58 +0200
Message-ID: <1377674998-18872-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	<nhan.tt.vo@dektech.com.au>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <paul.gortmaker@windriver.com>,
	<ying.xue@windriver.com>, <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:61059 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897Ab3H1Hai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 03:30:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Should a connect fail, if the publication/server is unavailable or
due to some other error, a positive value will be returned and errno
is never set. If the application code checks for an explicit zero
return from connect (success) or a negative return (failure), it
will not catch the error and subsequent send() calls will fail as
shown from the strace snippet below.

socket(0x1e /* PF_??? */, SOCK_SEQPACKET, 0) = 3
connect(3, {sa_family=0x1e /* AF_??? */, sa_data="\2\1\322\4\0\0\322\4\0\0\0\0\0\0"}, 16) = 111
sendto(3, "test", 4, 0, NULL, 0)        = -1 EPIPE (Broken pipe)

The reason for this behaviour is that TIPC wrongly inverts error
codes set in sk_err.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---

[v2: add more details to commit message]

 net/tipc/socket.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ce8249c..6cc7ddd 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1257,7 +1257,7 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
 		/* Accept only ACK or NACK message */
 		if (unlikely(msg_errcode(msg))) {
 			sock->state = SS_DISCONNECTING;
-			sk->sk_err = -ECONNREFUSED;
+			sk->sk_err = ECONNREFUSED;
 			retval = TIPC_OK;
 			break;
 		}
@@ -1268,7 +1268,7 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
 		res = auto_connect(sock, msg);
 		if (res) {
 			sock->state = SS_DISCONNECTING;
-			sk->sk_err = res;
+			sk->sk_err = -res;
 			retval = TIPC_OK;
 			break;
 		}
-- 
1.7.9.5
