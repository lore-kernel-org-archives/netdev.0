From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 2/4] tcp: mitigate ACK loops for connections as tcp_request_sock
Date: Fri,  6 Feb 2015 16:04:39 -0500
Message-ID: <1423256681-31716-3-git-send-email-ncardwell@google.com>
References: <1423256681-31716-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:44119 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbbBFVFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 16:05:50 -0500
Received: by mail-yh0-f42.google.com with SMTP id b6so5844947yha.1
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 13:05:49 -0800 (PST)
In-Reply-To: <1423256681-31716-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the SYN_RECV state, where the TCP connection is represented by
tcp_request_sock, we now rate-limit SYNACKs in response to a client's
retransmitted SYNs: we do not send a SYNACK in response to client SYN
if it has been less than sysctl_tcp_invalid_ratelimit (default 500ms)
since we last sent a SYNACK in response to a client's retransmitted
SYN.

This allows the vast majority of legitimate client connections to
proceed unimpeded, even for the most aggressive platforms, iOS and
MacOS, which actually retransmit SYNs 1-second intervals for several
times in a row. They use SYN RTO timeouts following the progression:
1,1,1,1,1,2,4,8,16,32.

Reported-by: Avery Fay <avery@mixpanel.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h      | 1 +
 include/net/tcp.h        | 1 +
 net/ipv4/tcp_minisocks.c | 6 +++++-
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 67309ec..bcc828d 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -115,6 +115,7 @@ struct tcp_request_sock {
 	u32				rcv_isn;
 	u32				snt_isn;
 	u32				snt_synack; /* synack sent time */
+	u32				last_oow_ack_time; /* last SYNACK */
 	u32				rcv_nxt; /* the ack # by SYNACK. For
 						  * FastOpen it's the seq#
 						  * after data-in-SYN.
diff --git a/include/net/tcp.h b/include/net/tcp.h
index b81f45c..da4196fb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1145,6 +1145,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	tcp_rsk(req)->rcv_isn = TCP_SKB_CB(skb)->seq;
 	tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
 	tcp_rsk(req)->snt_synack = tcp_time_stamp;
+	tcp_rsk(req)->last_oow_ack_time = 0;
 	req->mss = rx_opt->mss_clamp;
 	req->ts_recent = rx_opt->saw_tstamp ? rx_opt->rcv_tsval : 0;
 	ireq->tstamp_ok = rx_opt->tstamp_ok;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index bc9216d..131aa49 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -605,7 +605,11 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 		 * Reset timer after retransmitting SYNACK, similar to
 		 * the idea of fast retransmit in recovery.
 		 */
-		if (!inet_rtx_syn_ack(sk, req))
+		if (!tcp_oow_rate_limited(sock_net(sk), skb,
+					  LINUX_MIB_TCPACKSKIPPEDSYNRECV,
+					  &tcp_rsk(req)->last_oow_ack_time) &&
+
+		    !inet_rtx_syn_ack(sk, req))
 			req->expires = min(TCP_TIMEOUT_INIT << req->num_timeout,
 					   TCP_RTO_MAX) + jiffies;
 		return NULL;
-- 
2.2.0.rc0.207.ga3a616c
