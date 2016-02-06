From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fastopen: call tcp_fin() if FIN present in
 SYNACK
Date: Sat, 06 Feb 2016 11:16:28 -0800
Message-ID: <1454786188.7627.339.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454389388-1506-1-git-send-email-edumazet@google.com>
	 <20160206.031302.1262914455786911151.davem@davemloft.net>
	 <1454784731.7627.329.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, sara@sinodun.com,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36019 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbcBFTQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 14:16:31 -0500
Received: by mail-pa0-f48.google.com with SMTP id yy13so51710630pab.3
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 11:16:31 -0800 (PST)
In-Reply-To: <1454784731.7627.329.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When we acknowledge a FIN, it is not enough to ack the sequence number
and queue the skb into receive queue. We also have to call tcp_fin()
to properly update socket state and send proper poll() notifications.

It seems we also had the problem if we received a SYN packet with the
FIN flag set, but it does not seem an urgent issue, as no known
implementation can do that.

Fixes: 61d2bcae99f6 ("tcp: fastopen: accept data/FIN present in SYNACK message")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 include/net/tcp.h       |    1 +
 net/ipv4/tcp_fastopen.c |    3 +++
 net/ipv4/tcp_input.c    |    2 +-
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 27f4c733116d..479d535609fd 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -568,6 +568,7 @@ void tcp_rearm_rto(struct sock *sk);
 void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req);
 void tcp_reset(struct sock *sk);
 void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp, struct sk_buff *skb);
+void tcp_fin(struct sock *sk);
 
 /* tcp_timer.c */
 void tcp_init_xmit_timers(struct sock *);
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 6a6e11e54bae..fdb286ddba04 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -154,6 +154,9 @@ void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb)
 	 * as we certainly are not changing upper 32bit value (0)
 	 */
 	tp->bytes_received = skb->len;
+
+	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
+		tcp_fin(sk);
 }
 
 static struct sock *tcp_fastopen_create_child(struct sock *sk,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4add3eb40e58..8194a250a01e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3995,7 +3995,7 @@ void tcp_reset(struct sock *sk)
  *
  *	If we are in FINWAIT-2, a received FIN moves us to TIME-WAIT.
  */
-static void tcp_fin(struct sock *sk)
+void tcp_fin(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
