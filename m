From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/8] inet: cache listen_sock_qlen() and read rskq_defer_accept once
Date: Sun, 22 Mar 2015 10:22:18 -0700
Message-ID: <1427044945-32608-2-git-send-email-edumazet@google.com>
References: <1427044945-32608-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:32811 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbbCVRWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 13:22:36 -0400
Received: by pdbfl12 with SMTP id fl12so10052780pdb.0
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 10:22:36 -0700 (PDT)
In-Reply-To: <1427044945-32608-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cache listen_sock_qlen() to limit false sharing, and read
rskq_defer_accept once as it might change under us.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_connection_sock.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 844808d9337b..7d011e825c48 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -571,8 +571,9 @@ static void reqsk_timer_handler(unsigned long data)
 	struct inet_connection_sock *icsk = inet_csk(sk_listener);
 	struct request_sock_queue *queue = &icsk->icsk_accept_queue;
 	struct listen_sock *lopt = queue->listen_opt;
-	int expire = 0, resend = 0;
+	int qlen, expire = 0, resend = 0;
 	int max_retries, thresh;
+	u8 defer_accept;
 
 	if (sk_listener->sk_state != TCP_LISTEN || !lopt) {
 		reqsk_put(req);
@@ -598,19 +599,21 @@ static void reqsk_timer_handler(unsigned long data)
 	 * embrions; and abort old ones without pity, if old
 	 * ones are about to clog our table.
 	 */
-	if (listen_sock_qlen(lopt) >> (lopt->max_qlen_log - 1)) {
+	qlen = listen_sock_qlen(lopt);
+	if (qlen >> (lopt->max_qlen_log - 1)) {
 		int young = listen_sock_young(lopt) << 1;
 
 		while (thresh > 2) {
-			if (listen_sock_qlen(lopt) < young)
+			if (qlen < young)
 				break;
 			thresh--;
 			young <<= 1;
 		}
 	}
-	if (queue->rskq_defer_accept)
-		max_retries = queue->rskq_defer_accept;
-	syn_ack_recalc(req, thresh, max_retries, queue->rskq_defer_accept,
+	defer_accept = READ_ONCE(queue->rskq_defer_accept);
+	if (defer_accept)
+		max_retries = defer_accept;
+	syn_ack_recalc(req, thresh, max_retries, defer_accept,
 		       &expire, &resend);
 	req->rsk_ops->syn_ack_timeout(sk_listener, req);
 	if (!expire &&
-- 
2.2.0.rc0.207.ga3a616c
