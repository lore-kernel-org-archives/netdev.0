From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH] tcp: make tcp_cwnd_application_limited() static
Date: Fri, 18 Apr 2014 12:27:46 +0800
Message-ID: <e41998355cfed2a278072df2c113b6f89a81dfd0.1397795231.git.wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830AbaDRE2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2014 00:28:22 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s3I4SL35015927
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 18 Apr 2014 00:28:22 -0400
Received: from localhost.localdomain.com (dhcp-17-50.nay.redhat.com [10.66.17.50])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id s3I4SKqI030425
	for <netdev@vger.kernel.org>; Fri, 18 Apr 2014 00:28:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make tcp_cwnd_application_limited() static and move it from tcp_input.c to
tcp_output.c

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 include/net/tcp.h     |    1 -
 net/ipv4/tcp_input.c  |   22 ----------------------
 net/ipv4/tcp_output.c |   22 ++++++++++++++++++++++
 3 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 87d8774..163d2b4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -558,7 +558,6 @@ void tcp_send_loss_probe(struct sock *sk);
 bool tcp_schedule_loss_probe(struct sock *sk);
 
 /* tcp_input.c */
-void tcp_cwnd_application_limited(struct sock *sk);
 void tcp_resume_early_retransmit(struct sock *sk);
 void tcp_rearm_rto(struct sock *sk);
 void tcp_reset(struct sock *sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6b46eb..6efed13 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4703,28 +4703,6 @@ static int tcp_prune_queue(struct sock *sk)
 	return -1;
 }
 
-/* RFC2861, slow part. Adjust cwnd, after it was not full during one rto.
- * As additional protections, we do not touch cwnd in retransmission phases,
- * and if application hit its sndbuf limit recently.
- */
-void tcp_cwnd_application_limited(struct sock *sk)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	if (inet_csk(sk)->icsk_ca_state == TCP_CA_Open &&
-	    sk->sk_socket && !test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
-		/* Limited by application or receiver window. */
-		u32 init_win = tcp_init_cwnd(tp, __sk_dst_get(sk));
-		u32 win_used = max(tp->snd_cwnd_used, init_win);
-		if (win_used < tp->snd_cwnd) {
-			tp->snd_ssthresh = tcp_current_ssthresh(sk);
-			tp->snd_cwnd = (tp->snd_cwnd + win_used) >> 1;
-		}
-		tp->snd_cwnd_used = 0;
-	}
-	tp->snd_cwnd_stamp = tcp_time_stamp;
-}
-
 static bool tcp_should_expand_sndbuf(const struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 025e250..29dde97 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1387,6 +1387,28 @@ unsigned int tcp_current_mss(struct sock *sk)
 	return mss_now;
 }
 
+/* RFC2861, slow part. Adjust cwnd, after it was not full during one rto.
+ * As additional protections, we do not touch cwnd in retransmission phases,
+ * and if application hit its sndbuf limit recently.
+ */
+static void tcp_cwnd_application_limited(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (inet_csk(sk)->icsk_ca_state == TCP_CA_Open &&
+	    sk->sk_socket && !test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
+		/* Limited by application or receiver window. */
+		u32 init_win = tcp_init_cwnd(tp, __sk_dst_get(sk));
+		u32 win_used = max(tp->snd_cwnd_used, init_win);
+		if (win_used < tp->snd_cwnd) {
+			tp->snd_ssthresh = tcp_current_ssthresh(sk);
+			tp->snd_cwnd = (tp->snd_cwnd + win_used) >> 1;
+		}
+		tp->snd_cwnd_used = 0;
+	}
+	tp->snd_cwnd_stamp = tcp_time_stamp;
+}
+
 /* Congestion window validation. (RFC2861) */
 static void tcp_cwnd_validate(struct sock *sk)
 {
-- 
1.7.4
