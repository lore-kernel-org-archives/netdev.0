From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/6] tcp: uninline tcp_oow_rate_limited()
Date: Mon, 16 Mar 2015 21:06:20 -0700
Message-ID: <1426565180-26844-7-git-send-email-edumazet@google.com>
References: <1426565180-26844-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:33418 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbbCQEHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 00:07:04 -0400
Received: by pablj1 with SMTP id lj1so12493658pab.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 21:07:03 -0700 (PDT)
In-Reply-To: <1426565180-26844-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_oow_rate_limited() is hardly used in fast path, there is
no point inlining it.

Signed-of-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h    | 32 ++------------------------------
 net/ipv4/tcp_input.c | 30 ++++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+), 30 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9fe1d535cd6c..5b29835b81d8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1216,36 +1216,8 @@ static inline bool tcp_paws_reject(const struct tcp_options_received *rx_opt,
 	return true;
 }
 
-/* Return true if we're currently rate-limiting out-of-window ACKs and
- * thus shouldn't send a dupack right now. We rate-limit dupacks in
- * response to out-of-window SYNs or ACKs to mitigate ACK loops or DoS
- * attacks that send repeated SYNs or ACKs for the same connection. To
- * do this, we do not send a duplicate SYNACK or ACK if the remote
- * endpoint is sending out-of-window SYNs or pure ACKs at a high rate.
- */
-static inline bool tcp_oow_rate_limited(struct net *net,
-					const struct sk_buff *skb,
-					int mib_idx, u32 *last_oow_ack_time)
-{
-	/* Data packets without SYNs are not likely part of an ACK loop. */
-	if ((TCP_SKB_CB(skb)->seq != TCP_SKB_CB(skb)->end_seq) &&
-	    !tcp_hdr(skb)->syn)
-		goto not_rate_limited;
-
-	if (*last_oow_ack_time) {
-		s32 elapsed = (s32)(tcp_time_stamp - *last_oow_ack_time);
-
-		if (0 <= elapsed && elapsed < sysctl_tcp_invalid_ratelimit) {
-			NET_INC_STATS_BH(net, mib_idx);
-			return true;	/* rate-limited: don't send yet! */
-		}
-	}
-
-	*last_oow_ack_time = tcp_time_stamp;
-
-not_rate_limited:
-	return false;	/* not rate-limited: go ahead, send dupack now! */
-}
+bool tcp_oow_rate_limited(struct net *net, const struct sk_buff *skb,
+			  int mib_idx, u32 *last_oow_ack_time);
 
 static inline void tcp_mib_init(struct net *net)
 {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 10d6bd93f229..7257eb206c07 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3321,6 +3321,36 @@ static int tcp_ack_update_window(struct sock *sk, const struct sk_buff *skb, u32
 	return flag;
 }
 
+/* Return true if we're currently rate-limiting out-of-window ACKs and
+ * thus shouldn't send a dupack right now. We rate-limit dupacks in
+ * response to out-of-window SYNs or ACKs to mitigate ACK loops or DoS
+ * attacks that send repeated SYNs or ACKs for the same connection. To
+ * do this, we do not send a duplicate SYNACK or ACK if the remote
+ * endpoint is sending out-of-window SYNs or pure ACKs at a high rate.
+ */
+bool tcp_oow_rate_limited(struct net *net, const struct sk_buff *skb,
+			  int mib_idx, u32 *last_oow_ack_time)
+{
+	/* Data packets without SYNs are not likely part of an ACK loop. */
+	if ((TCP_SKB_CB(skb)->seq != TCP_SKB_CB(skb)->end_seq) &&
+	    !tcp_hdr(skb)->syn)
+		goto not_rate_limited;
+
+	if (*last_oow_ack_time) {
+		s32 elapsed = (s32)(tcp_time_stamp - *last_oow_ack_time);
+
+		if (0 <= elapsed && elapsed < sysctl_tcp_invalid_ratelimit) {
+			NET_INC_STATS_BH(net, mib_idx);
+			return true;	/* rate-limited: don't send yet! */
+		}
+	}
+
+	*last_oow_ack_time = tcp_time_stamp;
+
+not_rate_limited:
+	return false;	/* not rate-limited: go ahead, send dupack now! */
+}
+
 /* RFC 5961 7 [ACK Throttling] */
 static void tcp_send_challenge_ack(struct sock *sk, const struct sk_buff *skb)
 {
-- 
2.2.0.rc0.207.ga3a616c
