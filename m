From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v3 net-next 10/16] tcp: allow congestion control module to request TSO skb segment count
Date: Sun, 18 Sep 2016 18:03:47 -0400
Message-ID: <1474236233-28511-11-git-send-email-ncardwell@google.com>
References: <1474236233-28511-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:35967 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936217AbcIRWET (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 18:04:19 -0400
Received: by mail-qt0-f178.google.com with SMTP id l91so64342630qte.3
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 15:04:19 -0700 (PDT)
In-Reply-To: <1474236233-28511-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the tso_segs_goal() function in tcp_congestion_ops to allow the
congestion control module to specify the number of segments that
should be in a TSO skb sent by tcp_write_xmit() and
tcp_xmit_retransmit_queue(). The congestion control module can either
request a particular number of segments in TSO skb that we transmit,
or return 0 if it doesn't care.

This allows the upcoming BBR congestion control module to select small
TSO skb sizes if the module detects that the bottleneck bandwidth is
very low, or that the connection is policed to a low rate.

Signed-off-by: Van Jacobson <vanj@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/net/tcp.h     |  2 ++
 net/ipv4/tcp_output.c | 15 +++++++++++++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index a69ed7f..f8f581f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -913,6 +913,8 @@ struct tcp_congestion_ops {
 	u32  (*undo_cwnd)(struct sock *sk);
 	/* hook for packet ack accounting (optional) */
 	void (*pkts_acked)(struct sock *sk, const struct ack_sample *sample);
+	/* suggest number of segments for each skb to transmit (optional) */
+	u32 (*tso_segs_goal)(struct sock *sk);
 	/* get info for inet_diag (optional) */
 	size_t (*get_info)(struct sock *sk, u32 ext, int *attr,
 			   union tcp_cc_info *info);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e02c8eb..0137956 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1566,6 +1566,17 @@ static u32 tcp_tso_autosize(const struct sock *sk, unsigned int mss_now)
 	return min_t(u32, segs, sk->sk_gso_max_segs);
 }
 
+/* Return the number of segments we want in the skb we are transmitting.
+ * See if congestion control module wants to decide; otherwise, autosize.
+ */
+static u32 tcp_tso_segs(struct sock *sk, unsigned int mss_now)
+{
+	const struct tcp_congestion_ops *ca_ops = inet_csk(sk)->icsk_ca_ops;
+	u32 tso_segs = ca_ops->tso_segs_goal ? ca_ops->tso_segs_goal(sk) : 0;
+
+	return tso_segs ? : tcp_tso_autosize(sk, mss_now);
+}
+
 /* Returns the portion of skb which can be sent right away */
 static unsigned int tcp_mss_split_point(const struct sock *sk,
 					const struct sk_buff *skb,
@@ -2061,7 +2072,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		}
 	}
 
-	max_segs = tcp_tso_autosize(sk, mss_now);
+	max_segs = tcp_tso_segs(sk, mss_now);
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
@@ -2778,7 +2789,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		last_lost = tp->snd_una;
 	}
 
-	max_segs = tcp_tso_autosize(sk, tcp_current_mss(sk));
+	max_segs = tcp_tso_segs(sk, tcp_current_mss(sk));
 	tcp_for_write_queue_from(skb, sk) {
 		__u8 sacked;
 		int segs;
-- 
2.8.0.rc3.226.g39d4020
