From: Dmitry Popov <dp@highloadlab.com>
Subject: [PATCH 4/5] tcp: syncookie stats counter
Date: Wed, 27 Oct 2010 17:30:27 +0400
Message-ID: <AANLkTik8w1ODK2dFNTsuzGJiZENHuxuJhx=Y3Etaxqkg__4233.67084372348$1288186258$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "David S. Miller" <davem@davemloft.net>,
	William.Allen.Simpson@gmail.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andreas Petlund <apetlund@simula.no>,
	Shan Wei <shanwei@cn.fujitsu.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:34127 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756723Ab0J0Nab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 09:30:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Popov <dp@highloadlab.com>

Estimation of amount of sent SYNACKs used to choose between
syn_backlog and syn_cookies added.

Estimation is made within TCP_TIMEOUT_INIT period. tcp_syncookie_stats
struct is added to tcp_sock.

Signed-off-by: Dmitry Popov <dp@highloadlab.com>
---
 include/linux/tcp.h                |   15 +++++++++++++++
 include/net/inet_connection_sock.h |    7 +++++++
 include/net/request_sock.h         |    8 ++++++++
 include/net/tcp.h                  |   29 +++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c                |   12 ++++++++++--
 net/ipv6/tcp_ipv6.c                |   16 ++++++++++++----
 6 files changed, 81 insertions(+), 6 deletions(-)
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 3436176..7445d17 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -288,6 +288,17 @@ static inline struct tcp_request_sock
*tcp_rsk(const struct request_sock *req)
 	return (struct tcp_request_sock *)req;
 }

+/* This structure is used to estimate amount of SYNs under (possible) SYNflood.
+ * @cookies_sent[@clock_hand] is incremented for each cookie sent.
+ * This counter is used while jiffies < @expires[@clock_hand],
+ * then clock_hand is switched (clock_hand ^= 1).
+ */
+struct tcp_syncookie_stats {
+	unsigned long expires[2];
+	u32 cookies_sent[2];
+	u8 clock_hand;
+};
+
 struct tcp_sock {
 	/* inet_connection_sock has to be the first member of tcp_sock */
 	struct inet_connection_sock	inet_conn;
@@ -471,6 +482,10 @@ struct tcp_sock {
 	 * So readers which hold this lock may omit rcu_reader_lock.
 	 */
 	struct tcp_cookie_values  *cookie_values;
+
+#ifdef CONFIG_SYN_COOKIES
+	struct tcp_syncookie_stats syncookie_stats;
+#endif
 };

 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff --git a/include/net/inet_connection_sock.h
b/include/net/inet_connection_sock.h
index 430b58f..7c63bb0 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -293,6 +293,13 @@ static inline int
inet_csk_reqsk_queue_young(const struct sock *sk)
 	return reqsk_queue_len_young(&inet_csk(sk)->icsk_accept_queue);
 }

+static inline int inet_csk_reqsk_queue_is_delta_full(const struct sock *sk,
+						     int delta)
+{
+	const struct request_sock_queue *aq = &inet_csk(sk)->icsk_accept_queue;
+	return reqsk_queue_is_delta_full(aq, delta);
+}
+
 static inline int inet_csk_reqsk_queue_is_full(const struct sock *sk)
 {
 	return reqsk_queue_is_full(&inet_csk(sk)->icsk_accept_queue);
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 870c46b..1154277 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -272,6 +272,14 @@ static inline int reqsk_queue_len_young(const
struct request_sock_queue *queue)
 	return queue->listen_opt->qlen_young;
 }

+static inline int
+	reqsk_queue_is_delta_full(const struct request_sock_queue *queue,
+				  int delta)
+{
+	struct listen_sock *lopt = queue->listen_opt;
+	return (lopt->qlen + delta) >> lopt->max_qlen_log;
+}
+
 static inline int reqsk_queue_is_full(const struct request_sock_queue *queue)
 {
 	return queue->listen_opt->qlen >> queue->listen_opt->max_qlen_log;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 08e6ce1..c25d4a5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1542,6 +1542,35 @@ static inline int tcp_s_data_size(const struct
tcp_sock *tp)
 		: 0;
 }

+/* Updates syn cookie statistics,
+ * should be called after new cookie(SYNACK) is sent.
+ */
+static inline void tcp_inc_syncookie_stats(struct tcp_syncookie_stats *stats)
+{
+	u8 hand = stats->clock_hand;
+
+	if (unlikely(time_after(jiffies, stats->expires[hand]))) {
+		hand ^= 1;
+		stats->expires[hand] = jiffies + TCP_TIMEOUT_INIT;
+		stats->cookies_sent[hand] = 0;
+		stats->clock_hand = hand;
+	}
+	++stats->cookies_sent[hand];
+}
+
+/* Returns previous syncookie stats(amount of cookies sent). */
+static inline u32 tcp_get_syncookie_stats(struct tcp_syncookie_stats *stats)
+{
+	u8 old_hand = stats->clock_hand ^ 1;
+
+	if (time_before(jiffies,
+			stats->expires[old_hand] + 2 * TCP_TIMEOUT_INIT))
+		/* old stats are not too old */
+		return stats->cookies_sent[old_hand];
+	else
+		return 0;
+}
+
 /**
  *	struct tcp_extend_values - tcp_ipv?.c to tcp_output.c workspace.
  *
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c7e9b2a..1e641b0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1344,13 +1344,21 @@ int tcp_v4_conn_request(struct sock *sk,
struct sk_buff *skb)
 	 * limitations, they conserve resources and peer is
 	 * evidently real one.
 	 */
-	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
+#ifdef CONFIG_SYN_COOKIES
+	if (inet_csk_reqsk_queue_is_delta_full(sk,
+		tcp_get_syncookie_stats(&tp->syncookie_stats)) &&
+		!isn)
+	{
 		if (net_ratelimit())
 			syn_flood_warning(skb);
-#ifdef CONFIG_SYN_COOKIES
 		if (sysctl_tcp_syncookies) {
+			tcp_inc_syncookie_stats(&tp->syncookie_stats);
 			want_cookie = 1;
 		} else
+#else
+	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
+		if (net_ratelimit())
+			syn_flood_warning(skb);
 #endif
 		goto drop;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a3fa1f9..767dfde 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1275,13 +1275,21 @@ static int tcp_v6_conn_request(struct sock
*sk, struct sk_buff *skb)
 	if (!ipv6_unicast_destination(skb))
 		goto drop;

-	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
+#ifdef CONFIG_SYN_COOKIES
+	if (inet_csk_reqsk_queue_is_delta_full(sk,
+		tcp_get_syncookie_stats(&tp->syncookie_stats)) &&
+		!isn)
+	{
 		if (net_ratelimit())
 			syn_flood_warning(skb);
-#ifdef CONFIG_SYN_COOKIES
-		if (sysctl_tcp_syncookies)
+		if (sysctl_tcp_syncookies) {
+			tcp_inc_syncookie_stats(&tp->syncookie_stats);
 			want_cookie = 1;
-		else
+		} else
+#else
+	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
+		if (net_ratelimit())
+			syn_flood_warning(skb);
 #endif
 		goto drop;
 	}
