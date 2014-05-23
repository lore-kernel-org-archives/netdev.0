From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: Don't reset the timeout when restarting
Date: Fri, 23 May 2014 15:55:12 -0400
Message-ID: <1400874912-25653-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.gq1.yahoo.com ([98.137.12.180]:41810 "HELO
	smtp105.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751011AbaEWTzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 15:55:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@kernel.org>

As it may then take longer than what the user specified using
setsockopt(SO_RCVTIMEO).

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ac08966..08d87fc 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -985,10 +985,11 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 	return 0;
 }
 
-static int tipc_wait_for_rcvmsg(struct socket *sock, long timeo)
+static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	DEFINE_WAIT(wait);
+	long timeo = *timeop;
 	int err;
 
 	for (;;) {
@@ -1013,6 +1014,7 @@ static int tipc_wait_for_rcvmsg(struct socket *sock, long timeo)
 			break;
 	}
 	finish_wait(sk_sleep(sk), &wait);
+	*timeop = timeo;
 	return err;
 }
 
@@ -1056,7 +1058,7 @@ static int tipc_recvmsg(struct kiocb *iocb, struct socket *sock,
 restart:
 
 	/* Look for a message in receive queue; wait if necessary */
-	res = tipc_wait_for_rcvmsg(sock, timeo);
+	res = tipc_wait_for_rcvmsg(sock, &timeo);
 	if (res)
 		goto exit;
 
@@ -1154,7 +1156,7 @@ static int tipc_recv_stream(struct kiocb *iocb, struct socket *sock,
 
 restart:
 	/* Look for a message in receive queue; wait if necessary */
-	res = tipc_wait_for_rcvmsg(sock, timeo);
+	res = tipc_wait_for_rcvmsg(sock, &timeo);
 	if (res)
 		goto exit;
 
-- 
1.7.9.5
