From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] tcp: add tcpi_bytes_acked to tcp_info
Date: Tue, 28 Apr 2015 10:32:17 -0700
Message-ID: <1430242338-23156-2-git-send-email-edumazet@google.com>
References: <1430242338-23156-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Eric Salo <salo@google.com>, Yuchung Cheng <ycheng@google.com>,
	Martin Lau <kafai@fb.com>, Chris Rapier <rapier@psc.edu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:33886 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030347AbbD1Rc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 13:32:29 -0400
Received: by obbgq1 with SMTP id gq1so121731obb.1
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 10:32:28 -0700 (PDT)
In-Reply-To: <1430242338-23156-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch tracks total number of bytes acked for a TCP socket.
This is the sum of all changes done to tp->snd_una, and allows
for precise tracking of delivered data.

RFC4898 named this : tcpEStatsAppHCThruOctetsAcked

This is a 64bit field, and can be fetched both from TCP_INFO
getsockopt() if one has a handle on a TCP socket, or from inet_diag
netlink facility (iproute2/ss patch will follow)

Note that tp->bytes_acked was placed near tp->snd_una for
best data locality and minimal performance impact.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Matt Mathis <mattmathis@google.com>
Cc: Eric Salo <salo@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Martin Lau <kafai@fb.com>
Cc: Chris Rapier <rapier@psc.edu>
---
 include/linux/tcp.h      |  4 ++++
 include/net/tcp.h        |  2 +-
 include/uapi/linux/tcp.h |  1 +
 net/ipv4/tcp.c           |  6 +++++-
 net/ipv4/tcp_input.c     | 13 +++++++++++--
 5 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 0caa3a2d4106..0f73b43171da 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -150,6 +150,10 @@ struct tcp_sock {
 	u32	rcv_wup;	/* rcv_nxt on last window update sent	*/
  	u32	snd_nxt;	/* Next sequence we send		*/
 
+	u64	bytes_acked;	/* RFC4898 tcpEStatsAppHCThruOctetsAcked
+				 * sum(delta(snd_una)), or how many bytes
+				 * were acked.
+				 */
  	u32	snd_una;	/* First byte we want an ack for	*/
  	u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
 	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 051dc5c2802d..dd7b4ea6a10c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -576,7 +576,7 @@ static inline int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsize)
 }
 
 /* tcp.c */
-void tcp_get_info(const struct sock *, struct tcp_info *);
+void tcp_get_info(struct sock *, struct tcp_info *);
 
 /* Read 'sendfile()'-style from a TCP socket */
 typedef int (*sk_read_actor_t)(read_descriptor_t *, struct sk_buff *,
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 3b9718328d8b..6666e98a0af9 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -189,6 +189,7 @@ struct tcp_info {
 
 	__u64	tcpi_pacing_rate;
 	__u64	tcpi_max_pacing_rate;
+	__u64	tcpi_bytes_acked; /* RFC4898 tcpEStatsAppHCThruOctetsAcked */
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8c5cd9efebbc..4bf0e8ca7b5b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2592,7 +2592,7 @@ EXPORT_SYMBOL(compat_tcp_setsockopt);
 #endif
 
 /* Return information about state of tcp endpoint in API format. */
-void tcp_get_info(const struct sock *sk, struct tcp_info *info)
+void tcp_get_info(struct sock *sk, struct tcp_info *info)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2663,6 +2663,10 @@ void tcp_get_info(const struct sock *sk, struct tcp_info *info)
 
 	rate = READ_ONCE(sk->sk_max_pacing_rate);
 	info->tcpi_max_pacing_rate = rate != ~0U ? rate : ~0ULL;
+
+	spin_lock_bh(&sk->sk_lock.slock);
+	info->tcpi_bytes_acked = tp->bytes_acked;
+	spin_unlock_bh(&sk->sk_lock.slock);
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3a4d9b34bed4..378d3f4d4dc3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3280,6 +3280,15 @@ static inline bool tcp_may_update_window(const struct tcp_sock *tp,
 		(ack_seq == tp->snd_wl1 && nwin > tp->snd_wnd);
 }
 
+/* If we update tp->snd_una, also update tp->bytes_acked */
+static void tcp_snd_una_update(struct tcp_sock *tp, u32 ack)
+{
+	u32 delta = ack - tp->snd_una;
+
+	tp->bytes_acked += delta;
+	tp->snd_una = ack;
+}
+
 /* Update our send window.
  *
  * Window update algorithm, described in RFC793/RFC1122 (used in linux-2.2
@@ -3315,7 +3324,7 @@ static int tcp_ack_update_window(struct sock *sk, const struct sk_buff *skb, u32
 		}
 	}
 
-	tp->snd_una = ack;
+	tcp_snd_una_update(tp, ack);
 
 	return flag;
 }
@@ -3497,7 +3506,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		 * Note, we use the fact that SND.UNA>=SND.WL2.
 		 */
 		tcp_update_wl(tp, ack_seq);
-		tp->snd_una = ack;
+		tcp_snd_una_update(tp, ack);
 		flag |= FLAG_WIN_UPDATE;
 
 		tcp_in_ack_event(sk, CA_ACK_WIN_UPDATE);
-- 
2.2.0.rc0.207.ga3a616c
