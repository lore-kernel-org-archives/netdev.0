From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 1/3] net: add inet_sk_transparent() helper
Date: Mon, 21 Dec 2015 21:29:24 +0100
Message-ID: <1450729766-14926-2-git-send-email-fw@strlen.de>
References: <1450729766-14926-1-git-send-email-fw@strlen.de>
Cc: eric.dumazet@gmail.com, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45113 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751523AbbLUUfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 15:35:18 -0500
In-Reply-To: <1450729766-14926-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoids cluttering tcp_v4_send_reset when followup patch extends
it to deal with timewait sockets.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/request_sock.h |  2 +-
 include/net/tcp.h          | 12 ++++++++++++
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index a0dde04..f49759d 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -68,7 +68,7 @@ struct request_sock {
 	u32				peer_secid;
 };
 
-static inline struct request_sock *inet_reqsk(struct sock *sk)
+static inline struct request_sock *inet_reqsk(const struct sock *sk)
 {
 	return (struct request_sock *)sk;
 }
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3077735b..f33fecf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1620,6 +1620,18 @@ static inline void tcp_highest_sack_combine(struct sock *sk,
 		tcp_sk(sk)->highest_sack = new;
 }
 
+/* This helper checks if socket has IP_TRANSPARENT set */
+static inline bool inet_sk_transparent(const struct sock *sk)
+{
+	switch (sk->sk_state) {
+	case TCP_TIME_WAIT:
+		return inet_twsk(sk)->tw_transparent;
+	case TCP_NEW_SYN_RECV:
+		return inet_rsk(inet_reqsk(sk))->no_srccheck;
+	}
+	return inet_sk(sk)->transparent;
+}
+
 /* Determines whether this is a thin stream (which may suffer from
  * increased latency). Used to trigger latency-reducing mechanisms.
  */
-- 
2.4.10
