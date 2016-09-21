From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: properly account Fast Open SYN-ACK retrans
Date: Wed, 21 Sep 2016 16:16:15 -0700
Message-ID: <1474499775-26436-2-git-send-email-ycheng@google.com>
References: <1474499775-26436-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36176 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756976AbcIUXRr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 19:17:47 -0400
Received: by mail-pf0-f170.google.com with SMTP id q2so23712900pfj.3
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 16:17:03 -0700 (PDT)
In-Reply-To: <1474499775-26436-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the TFO socket is accepted right off SYN-data, the socket
owner can call getsockopt(TCP_INFO) to collect ongoing SYN-ACK
retransmission or timeout stats (i.e., tcpi_total_retrans,
tcpi_retransmits). Currently those stats are only updated
upon handshake completes. This patch fixes it.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_input.c  | 2 +-
 net/ipv4/tcp_output.c | 2 ++
 net/ipv4/tcp_timer.c  | 1 +
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6c8f4cd0..8faf97e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5852,7 +5852,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		 * so release it.
 		 */
 		if (req) {
-			tp->total_retrans = req->num_retrans;
+			inet_csk(sk)->icsk_retransmits = 0;
 			reqsk_fastopen_remove(sk, req, false);
 		} else {
 			/* Make sure socket is routed, for correct metrics. */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8bd9911..810be35 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3559,6 +3559,8 @@ int tcp_rtx_synack(const struct sock *sk, struct request_sock *req)
 	if (!res) {
 		__TCP_INC_STATS(sock_net(sk), TCP_MIB_RETRANSSEGS);
 		__NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
+		if (unlikely(tcp_passive_fastopen(sk)))
+			tcp_sk(sk)->total_retrans++;
 	}
 	return res;
 }
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index debdd8b..39bc5b2 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -346,6 +346,7 @@ static void tcp_fastopen_synack_timer(struct sock *sk)
 	 */
 	inet_rtx_syn_ack(sk, req);
 	req->num_timeout++;
+	icsk->icsk_retransmits++;
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 			  TCP_TIMEOUT_INIT << req->num_timeout, TCP_RTO_MAX);
 }
-- 
2.8.0.rc3.226.g39d4020
