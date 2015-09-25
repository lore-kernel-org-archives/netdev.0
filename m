From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 11/17] tcp: remove tcp_ecn_make_synack() socket argument
Date: Fri, 25 Sep 2015 07:39:18 -0700
Message-ID: <1443191964-923-12-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34286 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932405AbbIYOkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:19 -0400
Received: by padhy16 with SMTP id hy16so107771568pad.1
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:19 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SYNACK packets might be sent without holding socket lock.

For DCTCP/ECN sake, we should call INET_ECN_xmit() while
socket lock is owned, and only when we init/change congestion control.

This also fixies a bug if congestion module is changed from
dctcp to another one on a listener : we now clear ECN bits
properly.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_cong.c   | 12 ++++++++++--
 net/ipv4/tcp_output.c | 10 +++-------
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 93c4dc3ab23f..882caa4e72bc 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -173,6 +173,10 @@ out:
 	 */
 	if (ca->get_info)
 		memset(icsk->icsk_ca_priv, 0, sizeof(icsk->icsk_ca_priv));
+	if (ca->flags & TCP_CONG_NEEDS_ECN)
+		INET_ECN_xmit(sk);
+	else
+		INET_ECN_dontxmit(sk);
 }
 
 void tcp_init_congestion_control(struct sock *sk)
@@ -181,6 +185,10 @@ void tcp_init_congestion_control(struct sock *sk)
 
 	if (icsk->icsk_ca_ops->init)
 		icsk->icsk_ca_ops->init(sk);
+	if (tcp_ca_needs_ecn(sk))
+		INET_ECN_xmit(sk);
+	else
+		INET_ECN_dontxmit(sk);
 }
 
 static void tcp_reinit_congestion_control(struct sock *sk,
@@ -192,8 +200,8 @@ static void tcp_reinit_congestion_control(struct sock *sk,
 	icsk->icsk_ca_ops = ca;
 	icsk->icsk_ca_setsockopt = 1;
 
-	if (sk->sk_state != TCP_CLOSE && icsk->icsk_ca_ops->init)
-		icsk->icsk_ca_ops->init(sk);
+	if (sk->sk_state != TCP_CLOSE)
+		tcp_init_congestion_control(sk);
 }
 
 /* Manage refcounts on socket close. */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ab03018fb621..dcb5c144f8fa 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -357,14 +357,10 @@ static void tcp_ecn_clear_syn(struct sock *sk, struct sk_buff *skb)
 }
 
 static void
-tcp_ecn_make_synack(const struct request_sock *req, struct tcphdr *th,
-		    struct sock *sk)
+tcp_ecn_make_synack(const struct request_sock *req, struct tcphdr *th)
 {
-	if (inet_rsk(req)->ecn_ok) {
+	if (inet_rsk(req)->ecn_ok)
 		th->ece = 1;
-		if (tcp_ca_needs_ecn(sk))
-			INET_ECN_xmit(sk);
-	}
 }
 
 /* Set up ECN state for a packet on a ESTABLISHED socket that is about to
@@ -2999,7 +2995,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	memset(th, 0, sizeof(struct tcphdr));
 	th->syn = 1;
 	th->ack = 1;
-	tcp_ecn_make_synack(req, th, sk);
+	tcp_ecn_make_synack(req, th);
 	th->source = htons(ireq->ir_num);
 	th->dest = ireq->ir_rmt_port;
 	/* Setting of flags are superfluous here for callers (and ECE is
-- 
2.6.0.rc2.230.g3dd15c0
