From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next v2 02/13] tcp: new helper for RACK to detect loss
Date: Thu, 12 Jan 2017 22:11:31 -0800
Message-ID: <20170113061142.127344-3-ycheng@google.com>
References: <20170113061142.127344-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
        nanditad@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:32895 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdAMGMO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 01:12:14 -0500
Received: by mail-pf0-f182.google.com with SMTP id y143so26040312pfb.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 22:12:09 -0800 (PST)
In-Reply-To: <20170113061142.127344-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a new helper tcp_rack_detect_loss to prepare the upcoming
RACK reordering timer patch.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h       |  3 +--
 net/ipv4/tcp_input.c    | 12 ++++++++----
 net/ipv4/tcp_recovery.c | 22 +++++++++++++---------
 3 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1da0aa724929..51183bba3835 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1863,8 +1863,7 @@ extern int sysctl_tcp_recovery;
 /* Use TCP RACK to detect (some) tail and retransmit losses */
 #define TCP_RACK_LOST_RETRANS  0x1
 
-extern int tcp_rack_mark_lost(struct sock *sk);
-
+extern void tcp_rack_mark_lost(struct sock *sk);
 extern void tcp_rack_advance(struct tcp_sock *tp,
 			     const struct skb_mstamp *xmit_time, u8 sacked);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ec6d84363024..bb24b93e64bc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2865,10 +2865,14 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 	}
 
 	/* Use RACK to detect loss */
-	if (sysctl_tcp_recovery & TCP_RACK_LOST_RETRANS &&
-	    tcp_rack_mark_lost(sk)) {
-		flag |= FLAG_LOST_RETRANS;
-		*ack_flag |= FLAG_LOST_RETRANS;
+	if (sysctl_tcp_recovery & TCP_RACK_LOST_RETRANS) {
+		u32 prior_retrans = tp->retrans_out;
+
+		tcp_rack_mark_lost(sk);
+		if (prior_retrans > tp->retrans_out) {
+			flag |= FLAG_LOST_RETRANS;
+			*ack_flag |= FLAG_LOST_RETRANS;
+		}
 	}
 
 	/* E. Process state. */
diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
index f38dba5aed7a..7ea0377229c0 100644
--- a/net/ipv4/tcp_recovery.c
+++ b/net/ipv4/tcp_recovery.c
@@ -32,17 +32,11 @@ static void tcp_rack_mark_skb_lost(struct sock *sk, struct sk_buff *skb)
  * The current version is only used after recovery starts but can be
  * easily extended to detect the first loss.
  */
-int tcp_rack_mark_lost(struct sock *sk)
+static void tcp_rack_detect_loss(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
-	u32 reo_wnd, prior_retrans = tp->retrans_out;
-
-	if (inet_csk(sk)->icsk_ca_state < TCP_CA_Recovery || !tp->rack.advanced)
-		return 0;
-
-	/* Reset the advanced flag to avoid unnecessary queue scanning */
-	tp->rack.advanced = 0;
+	u32 reo_wnd;
 
 	/* To be more reordering resilient, allow min_rtt/4 settling delay
 	 * (lower-bounded to 1000uS). We use min_rtt instead of the smoothed
@@ -82,7 +76,17 @@ int tcp_rack_mark_lost(struct sock *sk)
 			break;
 		}
 	}
-	return prior_retrans - tp->retrans_out;
+}
+
+void tcp_rack_mark_lost(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (inet_csk(sk)->icsk_ca_state < TCP_CA_Recovery || !tp->rack.advanced)
+		return;
+	/* Reset the advanced flag to avoid unnecessary queue scanning */
+	tp->rack.advanced = 0;
+	tcp_rack_detect_loss(sk);
 }
 
 /* Record the most recently (re)sent time among the (s)acked packets */
-- 
2.11.0.483.g087da7b7c-goog
