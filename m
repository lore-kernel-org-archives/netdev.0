From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 1/4] tcp: extract code to compute SYNACK RTT
Date: Sat, 22 Sep 2012 10:18:54 -0400
Message-ID: <1348323537-30310-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Jerry Chu <hkchu@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:36315 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab2IVOT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 10:19:28 -0400
Received: by qcqs25 with SMTP id s25so285843qcq.1
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 07:19:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for adding another spot where we compute the SYNACK
RTT, extract this code so that it can be shared.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/net/tcp.h   |    9 +++++++++
 net/ipv4/tcp_ipv4.c |    4 +---
 net/ipv6/tcp_ipv6.c |    4 +---
 3 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index a8cb00c..a718d0e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1137,6 +1137,15 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->loc_port = tcp_hdr(skb)->dest;
 }
 
+/* Compute time elapsed between SYNACK and the ACK completing 3WHS */
+static inline void tcp_synack_rtt_meas(struct sock *sk,
+				       struct request_sock *req)
+{
+	if (tcp_rsk(req)->snt_synack)
+		tcp_valid_rtt_meas(sk,
+		    tcp_time_stamp - tcp_rsk(req)->snt_synack);
+}
+
 extern void tcp_enter_memory_pressure(struct sock *sk);
 
 static inline int keepalive_intvl_when(const struct tcp_sock *tp)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e64abed..1e66f7f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1733,9 +1733,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newtp->advmss = tcp_sk(sk)->rx_opt.user_mss;
 
 	tcp_initialize_rcv_mss(newsk);
-	if (tcp_rsk(req)->snt_synack)
-		tcp_valid_rtt_meas(newsk,
-		    tcp_time_stamp - tcp_rsk(req)->snt_synack);
+	tcp_synack_rtt_meas(newsk, req);
 	newtp->total_retrans = req->retrans;
 
 #ifdef CONFIG_TCP_MD5SIG
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f3bfb8b..cfeeeb7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1348,9 +1348,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newtp->advmss = tcp_sk(sk)->rx_opt.user_mss;
 
 	tcp_initialize_rcv_mss(newsk);
-	if (tcp_rsk(req)->snt_synack)
-		tcp_valid_rtt_meas(newsk,
-		    tcp_time_stamp - tcp_rsk(req)->snt_synack);
+	tcp_synack_rtt_meas(newsk, req);
 	newtp->total_retrans = req->retrans;
 
 	newinet->inet_daddr = newinet->inet_saddr = LOOPBACK4_IPV6;
-- 
1.7.7.3
