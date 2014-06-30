From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: switch snt_synack back to measuring transmit time of first SYNACK
Date: Mon, 30 Jun 2014 15:09:49 -0400
Message-ID: <1404155389-22927-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Octavian Purdila <octavian.purdila@intel.com>,
	Jerry Chu <hkchu@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:45690 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753797AbaF3TJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 15:09:56 -0400
Received: by mail-oa0-f73.google.com with SMTP id eb12so1969565oac.2
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 12:09:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always store in snt_synack the time at which the server received the
first client SYN and attempted to send the first SYNACK.

Recent commit aa27fc501 ("tcp: tcp_v[46]_conn_request: fix snt_synack
initialization") resolved an inconsistency between IPv4 and IPv6 in
the initialization of snt_synack. This commit brings back the idea
from 843f4a55e (tcp: use tcp_v4_send_synack on first SYN-ACK), which
was going for the original behavior of snt_synack from the commit
where it was added in 9ad7c049f0f79 ("tcp: RFC2988bis + taking RTT
sample from 3WHS for the passive open side") in v3.1.

In addition to being simpler (and probably a tiny bit faster),
unconditionally storing the time of the first SYNACK attempt has been
useful because it allows calculating a performance metric quantifying
how long it took to establish a passive TCP connection.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
Cc: Jerry Chu <hkchu@google.com>
---
 include/net/tcp.h   | 2 +-
 net/ipv4/tcp_ipv4.c | 2 --
 net/ipv6/tcp_ipv6.c | 2 --
 3 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0d5389a..c9a75db 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1093,7 +1093,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	req->cookie_ts = 0;
 	tcp_rsk(req)->rcv_isn = TCP_SKB_CB(skb)->seq;
 	tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
-	tcp_rsk(req)->snt_synack = 0;
+	tcp_rsk(req)->snt_synack = tcp_time_stamp;
 	req->mss = rx_opt->mss_clamp;
 	req->ts_recent = rx_opt->saw_tstamp ? rx_opt->rcv_tsval : 0;
 	ireq->tstamp_ok = rx_opt->tstamp_ok;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5dfebd2..52d0f6a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -838,8 +838,6 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 					    ireq->ir_rmt_addr,
 					    ireq->opt);
 		err = net_xmit_eval(err);
-		if (!tcp_rsk(req)->snt_synack && !err)
-			tcp_rsk(req)->snt_synack = tcp_time_stamp;
 	}
 
 	return err;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index bc24ee2..a97c955 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -498,8 +498,6 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 		skb_set_queue_mapping(skb, queue_mapping);
 		err = ip6_xmit(sk, skb, fl6, np->opt, np->tclass);
 		err = net_xmit_eval(err);
-		if (!tcp_rsk(req)->snt_synack && !err)
-			tcp_rsk(req)->snt_synack = tcp_time_stamp;
 	}
 
 done:
-- 
2.0.0.526.g5318336
