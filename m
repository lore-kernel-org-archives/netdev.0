From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] tcp: tcp_prequeue() cleanup
Date: Thu, 07 May 2009 19:08:38 +0200
Message-ID: <4A031596.4020904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43524 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbZEGRIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 13:08:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small cleanup patch to reduce line lengths, before a change in tcp_prequeue().

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b55b489..ac37228 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -890,30 +890,31 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (!sysctl_tcp_low_latency && tp->ucopy.task) {
-		__skb_queue_tail(&tp->ucopy.prequeue, skb);
-		tp->ucopy.memory += skb->truesize;
-		if (tp->ucopy.memory > sk->sk_rcvbuf) {
-			struct sk_buff *skb1;
-
-			BUG_ON(sock_owned_by_user(sk));
-
-			while ((skb1 = __skb_dequeue(&tp->ucopy.prequeue)) != NULL) {
-				sk_backlog_rcv(sk, skb1);
-				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPPREQUEUEDROPPED);
-			}
-
-			tp->ucopy.memory = 0;
-		} else if (skb_queue_len(&tp->ucopy.prequeue) == 1) {
-			wake_up_interruptible(sk->sk_sleep);
-			if (!inet_csk_ack_scheduled(sk))
-				inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						          (3 * TCP_RTO_MIN) / 4,
-							  TCP_RTO_MAX);
+	if (sysctl_tcp_low_latency || !tp->ucopy.task)
+		return 0;
+
+	__skb_queue_tail(&tp->ucopy.prequeue, skb);
+	tp->ucopy.memory += skb->truesize;
+	if (tp->ucopy.memory > sk->sk_rcvbuf) {
+		struct sk_buff *skb1;
+
+		BUG_ON(sock_owned_by_user(sk));
+
+		while ((skb1 = __skb_dequeue(&tp->ucopy.prequeue)) != NULL) {
+			sk_backlog_rcv(sk, skb1);
+			NET_INC_STATS_BH(sock_net(sk),
+					 LINUX_MIB_TCPPREQUEUEDROPPED);
 		}
-		return 1;
+
+		tp->ucopy.memory = 0;
+	} else if (skb_queue_len(&tp->ucopy.prequeue) == 1) {
+		wake_up_interruptible(sk->sk_sleep);
+		if (!inet_csk_ack_scheduled(sk))
+			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
+						  (3 * TCP_RTO_MIN) / 4,
+						  TCP_RTO_MAX);
 	}
-	return 0;
+	return 1;
 }
 
 
