From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] inet: fix race in reqsk_queue_unlink()
Date: Thu, 01 Oct 2015 05:39:26 -0700
Message-ID: <1443703166.32531.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33152 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575AbbJAMj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 08:39:28 -0400
Received: by pacex6 with SMTP id ex6so74015834pac.0
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 05:39:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

reqsk_timer_handler() tests if icsk_accept_queue.listen_opt
is NULL at its beginning.

By the time it calls inet_csk_reqsk_queue_drop() and
reqsk_queue_unlink(), listener might have been closed and
inet_csk_listen_stop() had called reqsk_queue_yank_acceptq()
which sets icsk_accept_queue.listen_opt to NULL

We therefore need to correctly check listen_opt being NULL
after holding syn_wait_lock for proper synchronization.

Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")
Fixes: b357a364c57c ("inet: fix possible panic in reqsk_queue_unlink()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/inet_connection_sock.c |   19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 7bb9c39e0a4d..61b45a17fc73 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -577,21 +577,22 @@ EXPORT_SYMBOL(inet_rtx_syn_ack);
 static bool reqsk_queue_unlink(struct request_sock_queue *queue,
 			       struct request_sock *req)
 {
-	struct listen_sock *lopt = queue->listen_opt;
 	struct request_sock **prev;
+	struct listen_sock *lopt;
 	bool found = false;
 
 	spin_lock(&queue->syn_wait_lock);
-
-	for (prev = &lopt->syn_table[req->rsk_hash]; *prev != NULL;
-	     prev = &(*prev)->dl_next) {
-		if (*prev == req) {
-			*prev = req->dl_next;
-			found = true;
-			break;
+	lopt = queue->listen_opt;
+	if (lopt) {
+		for (prev = &lopt->syn_table[req->rsk_hash]; *prev != NULL;
+		     prev = &(*prev)->dl_next) {
+			if (*prev == req) {
+				*prev = req->dl_next;
+				found = true;
+				break;
+			}
 		}
 	}
-
 	spin_unlock(&queue->syn_wait_lock);
 	if (timer_pending(&req->rsk_timer) && del_timer_sync(&req->rsk_timer))
 		reqsk_put(req);
