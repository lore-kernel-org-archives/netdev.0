From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: fix potential bug in function tipc_backlog_rcv
Date: Mon,  9 Jun 2014 11:08:18 -0500
Message-ID: <1402330098-4719-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.biz.mail.gq1.yahoo.com ([98.137.12.181]:21597 "HELO
	smtp106.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933116AbaFIQIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 12:08:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 4f4482dcd9a0606a30541ff165ddaca64748299b ("tipc: compensate
for double accounting in socket rcv buffer") we access 'truesize' of
a received buffer after it might have been released by the function
filter_rcv().

In this commit we correct this by reading the value of 'truesize' to
the stack before delivering the buffer to filter_rcv().

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 08d87fc..ef04755 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1,5 +1,5 @@
 /*
-* net/tipc/socket.c: TIPC socket API
+ * net/tipc/socket.c: TIPC socket API
  *
  * Copyright (c) 2001-2007, 2012-2014, Ericsson AB
  * Copyright (c) 2004-2008, 2010-2013, Wind River Systems
@@ -1431,13 +1431,14 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *buf)
 {
 	u32 res;
 	struct tipc_sock *tsk = tipc_sk(sk);
+	uint truesize = buf->truesize;
 
 	res = filter_rcv(sk, buf);
 	if (unlikely(res))
 		tipc_reject_msg(buf, res);
 
 	if (atomic_read(&tsk->dupl_rcvcnt) < TIPC_CONN_OVERLOAD_LIMIT)
-		atomic_add(buf->truesize, &tsk->dupl_rcvcnt);
+		atomic_add(truesize, &tsk->dupl_rcvcnt);
 
 	return 0;
 }
-- 
1.7.9.5
