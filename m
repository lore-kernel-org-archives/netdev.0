From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] tcp: add SYN/data info to TCP_INFO
Date: Fri, 19 Oct 2012 18:14:44 -0700
Message-ID: <1350695684-26962-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f202.google.com ([209.85.160.202]:45558 "EHLO
	mail-gh0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759439Ab2JTBO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 21:14:57 -0400
Received: by mail-gh0-f202.google.com with SMTP id z15so126002ghb.1
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 18:14:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a bit TCPI_OPT_SYN_DATA (32) to the socket option TCP_INFO:tcpi_options.
It's set if the data in SYN (sent or received) is acked by SYN-ACK. Server or
client application can use this information to check Fast Open success rate.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/linux/tcp.h      |    3 ++-
 include/uapi/linux/tcp.h |    1 +
 net/ipv4/tcp.c           |    2 ++
 net/ipv4/tcp_input.c     |    1 +
 net/ipv4/tcp_ipv4.c      |    1 +
 net/ipv4/tcp_minisocks.c |    1 +
 6 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 8a7fc4b..60b7aac 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -191,7 +191,8 @@ struct tcp_sock {
 	u8	do_early_retrans:1,/* Enable RFC5827 early-retransmit  */
 		early_retrans_delayed:1, /* Delayed ER timer installed */
 		syn_data:1,	/* SYN includes data */
-		syn_fastopen:1;	/* SYN includes Fast Open option */
+		syn_fastopen:1,	/* SYN includes Fast Open option */
+		syn_data_acked:1;/* data in SYN is acked by SYN-ACK */
 
 /* RTT measurement */
 	u32	srtt;		/* smoothed round trip time << 3	*/
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index c4b89a5..e962faa 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -130,6 +130,7 @@ enum {
 #define TCPI_OPT_WSCALE		4
 #define TCPI_OPT_ECN		8 /* ECN was negociated at TCP session init */
 #define TCPI_OPT_ECN_SEEN	16 /* we received at least one packet with ECT */
+#define TCPI_OPT_SYN_DATA	32 /* SYN-ACK acked data in SYN sent or rcvd */
 
 enum tcp_ca_state {
 	TCP_CA_Open = 0,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b7c2f43..197c000 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2764,6 +2764,8 @@ void tcp_get_info(const struct sock *sk, struct tcp_info *info)
 		info->tcpi_options |= TCPI_OPT_ECN;
 	if (tp->ecn_flags & TCP_ECN_SEEN)
 		info->tcpi_options |= TCPI_OPT_ECN_SEEN;
+	if (tp->syn_data_acked)
+		info->tcpi_options |= TCPI_OPT_SYN_DATA;
 
 	info->tcpi_rto = jiffies_to_usecs(icsk->icsk_rto);
 	info->tcpi_ato = jiffies_to_usecs(icsk->icsk_ack.ato);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 432c366..036f857 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5646,6 +5646,7 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 		tcp_rearm_rto(sk);
 		return true;
 	}
+	tp->syn_data_acked = tp->syn_data;
 	return false;
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ef998b0..0c4a643 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1461,6 +1461,7 @@ static int tcp_v4_conn_req_fastopen(struct sock *sk,
 		skb_set_owner_r(skb, child);
 		__skb_queue_tail(&child->sk_receive_queue, skb);
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+		tp->syn_data_acked = 1;
 	}
 	sk->sk_data_ready(sk, 0);
 	bh_unlock_sock(child);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 27536ba..a7302d9 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -510,6 +510,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->rx_opt.mss_clamp = req->mss;
 		TCP_ECN_openreq_child(newtp, req);
 		newtp->fastopen_rsk = NULL;
+		newtp->syn_data_acked = 0;
 
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_PASSIVEOPENS);
 	}
-- 
1.7.7.3
