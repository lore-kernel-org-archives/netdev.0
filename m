From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 1/3] net/tcp-fastopen: refactor cookie check logic
Date: Mon, 23 Jan 2017 10:59:20 -0800
Message-ID: <20170123185922.48046-2-tracywwnj@gmail.com>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33315 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdAWTAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 14:00:20 -0500
Received: by mail-pf0-f196.google.com with SMTP id e4so10494315pfg.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 11:00:20 -0800 (PST)
In-Reply-To: <20170123185922.48046-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Refactor the cookie check logic in tcp_send_syn_data() into a function.
This function will be called else where in later changes.

Signed-off-by: Wei Wang <weiwan@google.com>
---
 include/net/tcp.h       |  2 ++
 net/ipv4/tcp_fastopen.c | 21 +++++++++++++++++++++
 net/ipv4/tcp_output.c   | 16 ++--------------
 3 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c55d65f74f7f..de67541d7adf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1493,6 +1493,8 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 			      struct tcp_fastopen_cookie *foc,
 			      struct dst_entry *dst);
 void tcp_fastopen_init_key_once(bool publish);
+bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
+			     struct tcp_fastopen_cookie *cookie);
 #define TCP_FASTOPEN_KEY_LENGTH 16
 
 /* Fastopen key context */
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index f51919535ca7..f90e09e1ff4c 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -325,3 +325,24 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 	*foc = valid_foc;
 	return NULL;
 }
+
+bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
+			       struct tcp_fastopen_cookie *cookie)
+{
+	unsigned long last_syn_loss = 0;
+	int syn_loss = 0;
+
+	tcp_fastopen_cache_get(sk, mss, cookie, &syn_loss, &last_syn_loss);
+
+	/* Recurring FO SYN losses: no cookie or data in SYN */
+	if (syn_loss > 1 &&
+	    time_before(jiffies, last_syn_loss + (60*HZ << syn_loss))) {
+		cookie->len = -1;
+		return false;
+	}
+	if (sysctl_tcp_fastopen & TFO_CLIENT_NO_COOKIE) {
+		cookie->len = -1;
+		return true;
+	}
+	return cookie->len > 0;
+}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9a1a1494b9dd..671c69535671 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3267,23 +3267,11 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_fastopen_request *fo = tp->fastopen_req;
-	int syn_loss = 0, space, err = 0;
-	unsigned long last_syn_loss = 0;
+	int space, err = 0;
 	struct sk_buff *syn_data;
 
 	tp->rx_opt.mss_clamp = tp->advmss;  /* If MSS is not cached */
-	tcp_fastopen_cache_get(sk, &tp->rx_opt.mss_clamp, &fo->cookie,
-			       &syn_loss, &last_syn_loss);
-	/* Recurring FO SYN losses: revert to regular handshake temporarily */
-	if (syn_loss > 1 &&
-	    time_before(jiffies, last_syn_loss + (60*HZ << syn_loss))) {
-		fo->cookie.len = -1;
-		goto fallback;
-	}
-
-	if (sysctl_tcp_fastopen & TFO_CLIENT_NO_COOKIE)
-		fo->cookie.len = -1;
-	else if (fo->cookie.len <= 0)
+	if (!tcp_fastopen_cookie_check(sk, &tp->rx_opt.mss_clamp, &fo->cookie))
 		goto fallback;
 
 	/* MSS for SYN-data is based on cached MSS and bounded by PMTU and
-- 
2.11.0.483.g087da7b7c-goog
