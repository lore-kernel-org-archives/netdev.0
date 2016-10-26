From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp/dccp: drop SYN packets if accept queue is full
Date: Wed, 26 Oct 2016 09:27:57 -0700
Message-ID: <1477499277.7065.193.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34983 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932632AbcJZQ2A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 12:28:00 -0400
Received: by mail-pf0-f195.google.com with SMTP id s8so23163846pfj.2
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 09:28:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Per listen(fd, backlog) rules, there is really no point accepting a SYN,
sending a SYNACK, and dropping the following ACK packet if accept queue
is full, because application is not draining accept queue fast enough.

This behavior is fooling TCP clients that believe they established a
flow, while there is nothing at server side. They might then send about
10 MSS (if using IW10) that will be dropped anyway while server is under
stress.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h |    5 -----
 net/dccp/ipv4.c                    |    8 +-------
 net/dccp/ipv6.c                    |    2 +-
 net/ipv4/tcp_input.c               |    8 +-------
 4 files changed, 3 insertions(+), 20 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 197a30d221e92b839e2e96fa37f4a796514ea461..146054ceea8e0566f79739b1ed115dea53423258 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -289,11 +289,6 @@ static inline int inet_csk_reqsk_queue_len(const struct sock *sk)
 	return reqsk_queue_len(&inet_csk(sk)->icsk_accept_queue);
 }
 
-static inline int inet_csk_reqsk_queue_young(const struct sock *sk)
-{
-	return reqsk_queue_len_young(&inet_csk(sk)->icsk_accept_queue);
-}
-
 static inline int inet_csk_reqsk_queue_is_full(const struct sock *sk)
 {
 	return inet_csk_reqsk_queue_len(sk) >= sk->sk_max_ack_backlog;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 345a3aeb8c7e36449a765298cd6512eab8cfef4b..a957acac2337680f619fef09f19660a3b4c309d3 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -588,13 +588,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (inet_csk_reqsk_queue_is_full(sk))
 		goto drop;
 
-	/*
-	 * Accept backlog is full. If we have already queued enough
-	 * of warm entries in syn queue, drop request. It is better than
-	 * clogging syn queue with openreqs with exponentially increasing
-	 * timeout.
-	 */
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+	if (sk_acceptq_is_full(sk))
 		goto drop;
 
 	req = inet_reqsk_alloc(&dccp_request_sock_ops, sk, true);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 3828f94b234c1104a3e745b3c0a76ab343aed4b6..32f9f1a189f8b8082bfdebd97baa04045562a3c6 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -325,7 +325,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (inet_csk_reqsk_queue_is_full(sk))
 		goto drop;
 
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+	if (sk_acceptq_is_full(sk))
 		goto drop;
 
 	req = inet_reqsk_alloc(&dccp6_request_sock_ops, sk, true);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a27b9c0e27c08b4e4aeaff3d0bfdf3ae561ba4d8..f2c59c8e57ff195c803ac05e6897242a6b097d00 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6298,13 +6298,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 			goto drop;
 	}
 
-
-	/* Accept backlog is full. If we have already queued enough
-	 * of warm entries in syn queue, drop request. It is better than
-	 * clogging syn queue with openreqs with exponentially increasing
-	 * timeout.
-	 */
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
+	if (sk_acceptq_is_full(sk)) {
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 		goto drop;
 	}
 
