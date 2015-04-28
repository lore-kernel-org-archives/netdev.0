From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] tcp: add tcpi_bytes_received to tcp_info
Date: Tue, 28 Apr 2015 10:32:18 -0700
Message-ID: <1430242338-23156-3-git-send-email-edumazet@google.com>
References: <1430242338-23156-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Eric Salo <salo@google.com>, Yuchung Cheng <ycheng@google.com>,
	Martin Lau <kafai@fb.com>, Chris Rapier <rapier@psc.edu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f201.google.com ([209.85.220.201]:32852 "EHLO
	mail-qk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030347AbbD1Rce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 13:32:34 -0400
Received: by qkbx191 with SMTP id x191so62994qkb.0
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 10:32:33 -0700 (PDT)
In-Reply-To: <1430242338-23156-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch tracks total number of payload bytes received on a TCP socket.
This is the sum of all changes done to tp->rcv_nxt

RFC4898 named this : tcpEStatsAppHCThruOctetsReceived

This is a 64bit field, and can be fetched both from TCP_INFO
getsockopt() if one has a handle on a TCP socket, or from inet_diag
netlink facility (iproute2/ss patch will follow)

Note that tp->bytes_received was placed near tp->rcv_nxt for
best data locality and minimal performance impact.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Matt Mathis <mattmathis@google.com>
Cc: Eric Salo <salo@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Martin Lau <kafai@fb.com>
Cc: Chris Rapier <rapier@psc.edu>
---
 include/linux/tcp.h      |  4 ++++
 include/uapi/linux/tcp.h |  1 +
 net/ipv4/tcp.c           |  1 +
 net/ipv4/tcp_input.c     | 17 +++++++++++++----
 4 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 0f73b43171da..3b2911502a8c 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -145,6 +145,10 @@ struct tcp_sock {
  *	read the code and the spec side by side (and laugh ...)
  *	See RFC793 and RFC1122. The RFC writes these in capitals.
  */
+	u64	bytes_received;	/* RFC4898 tcpEStatsAppHCThruOctetsReceived
+				 * sum(delta(rcv_nxt)), or how many bytes
+				 * were acked.
+				 */
  	u32	rcv_nxt;	/* What we want to receive next 	*/
 	u32	copied_seq;	/* Head of yet unread data		*/
 	u32	rcv_wup;	/* rcv_nxt on last window update sent	*/
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 6666e98a0af9..a48f93f3207b 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -190,6 +190,7 @@ struct tcp_info {
 	__u64	tcpi_pacing_rate;
 	__u64	tcpi_max_pacing_rate;
 	__u64	tcpi_bytes_acked; /* RFC4898 tcpEStatsAppHCThruOctetsAcked */
+	__u64	tcpi_bytes_received; /* RFC4898 tcpEStatsAppHCThruOctetsReceived */
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4bf0e8ca7b5b..99fcc0b22c92 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2666,6 +2666,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 
 	spin_lock_bh(&sk->sk_lock.slock);
 	info->tcpi_bytes_acked = tp->bytes_acked;
+	info->tcpi_bytes_received = tp->bytes_received;
 	spin_unlock_bh(&sk->sk_lock.slock);
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 378d3f4d4dc3..7e6962bcfc30 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3289,6 +3289,15 @@ static void tcp_snd_una_update(struct tcp_sock *tp, u32 ack)
 	tp->snd_una = ack;
 }
 
+/* If we update tp->rcv_nxt, also update tp->bytes_received */
+static void tcp_rcv_nxt_update(struct tcp_sock *tp, u32 seq)
+{
+	u32 delta = seq - tp->rcv_nxt;
+
+	tp->bytes_received += delta;
+	tp->rcv_nxt = seq;
+}
+
 /* Update our send window.
  *
  * Window update algorithm, described in RFC793/RFC1122 (used in linux-2.2
@@ -4245,7 +4254,7 @@ static void tcp_ofo_queue(struct sock *sk)
 
 		tail = skb_peek_tail(&sk->sk_receive_queue);
 		eaten = tail && tcp_try_coalesce(sk, tail, skb, &fragstolen);
-		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+		tcp_rcv_nxt_update(tp, TCP_SKB_CB(skb)->end_seq);
 		if (!eaten)
 			__skb_queue_tail(&sk->sk_receive_queue, skb);
 		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
@@ -4413,7 +4422,7 @@ static int __must_check tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int
 	__skb_pull(skb, hdrlen);
 	eaten = (tail &&
 		 tcp_try_coalesce(sk, tail, skb, fragstolen)) ? 1 : 0;
-	tcp_sk(sk)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+	tcp_rcv_nxt_update(tcp_sk(sk), TCP_SKB_CB(skb)->end_seq);
 	if (!eaten) {
 		__skb_queue_tail(&sk->sk_receive_queue, skb);
 		skb_set_owner_r(skb, sk);
@@ -4506,7 +4515,7 @@ queue_and_out:
 
 			eaten = tcp_queue_rcv(sk, skb, 0, &fragstolen);
 		}
-		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+		tcp_rcv_nxt_update(tp, TCP_SKB_CB(skb)->end_seq);
 		if (skb->len)
 			tcp_event_data_recv(sk, skb);
 		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
@@ -5254,7 +5263,7 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 					tcp_rcv_rtt_measure_ts(sk, skb);
 
 					__skb_pull(skb, tcp_header_len);
-					tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+					tcp_rcv_nxt_update(tp, TCP_SKB_CB(skb)->end_seq);
 					NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPHITSTOUSER);
 					eaten = 1;
 				}
-- 
2.2.0.rc0.207.ga3a616c
