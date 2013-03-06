From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: uninline tcp_prequeue()
Date: Wed, 06 Mar 2013 14:58:01 -0800
Message-ID: <1362610681.15793.205.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:49026 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756295Ab3CFW6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 17:58:05 -0500
Received: by mail-pb0-f43.google.com with SMTP id md12so6720776pbc.30
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 14:58:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_prequeue() became too big to be inlined.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h   |   45 ------------------------------------------
 net/ipv4/tcp_ipv4.c |   44 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 44 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cf0694d..a2baa5e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1030,50 +1030,7 @@ static inline void tcp_prequeue_init(struct tcp_sock *tp)
 #endif
 }
 
-/* Packet is added to VJ-style prequeue for processing in process
- * context, if a reader task is waiting. Apparently, this exciting
- * idea (VJ's mail "Re: query about TCP header on tcp-ip" of 07 Sep 93)
- * failed somewhere. Latency? Burstiness? Well, at least now we will
- * see, why it failed. 8)8)				  --ANK
- *
- * NOTE: is this not too big to inline?
- */
-static inline bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	if (sysctl_tcp_low_latency || !tp->ucopy.task)
-		return false;
-
-	if (skb->len <= tcp_hdrlen(skb) &&
-	    skb_queue_len(&tp->ucopy.prequeue) == 0)
-		return false;
-
-	__skb_queue_tail(&tp->ucopy.prequeue, skb);
-	tp->ucopy.memory += skb->truesize;
-	if (tp->ucopy.memory > sk->sk_rcvbuf) {
-		struct sk_buff *skb1;
-
-		BUG_ON(sock_owned_by_user(sk));
-
-		while ((skb1 = __skb_dequeue(&tp->ucopy.prequeue)) != NULL) {
-			sk_backlog_rcv(sk, skb1);
-			NET_INC_STATS_BH(sock_net(sk),
-					 LINUX_MIB_TCPPREQUEUEDROPPED);
-		}
-
-		tp->ucopy.memory = 0;
-	} else if (skb_queue_len(&tp->ucopy.prequeue) == 1) {
-		wake_up_interruptible_sync_poll(sk_sleep(sk),
-					   POLLIN | POLLRDNORM | POLLRDBAND);
-		if (!inet_csk_ack_scheduled(sk))
-			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						  (3 * tcp_rto_min(sk)) / 4,
-						  TCP_RTO_MAX);
-	}
-	return true;
-}
-
+extern bool tcp_prequeue(struct sock *sk, struct sk_buff *skb);
 
 #undef STATE_TRACE
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4a8ec45..8cdee12 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1950,6 +1950,50 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 	}
 }
 
+/* Packet is added to VJ-style prequeue for processing in process
+ * context, if a reader task is waiting. Apparently, this exciting
+ * idea (VJ's mail "Re: query about TCP header on tcp-ip" of 07 Sep 93)
+ * failed somewhere. Latency? Burstiness? Well, at least now we will
+ * see, why it failed. 8)8)				  --ANK
+ *
+ */
+bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (sysctl_tcp_low_latency || !tp->ucopy.task)
+		return false;
+
+	if (skb->len <= tcp_hdrlen(skb) &&
+	    skb_queue_len(&tp->ucopy.prequeue) == 0)
+		return false;
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
+		}
+
+		tp->ucopy.memory = 0;
+	} else if (skb_queue_len(&tp->ucopy.prequeue) == 1) {
+		wake_up_interruptible_sync_poll(sk_sleep(sk),
+					   POLLIN | POLLRDNORM | POLLRDBAND);
+		if (!inet_csk_ack_scheduled(sk))
+			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
+						  (3 * tcp_rto_min(sk)) / 4,
+						  TCP_RTO_MAX);
+	}
+	return true;
+}
+EXPORT_SYMBOL(tcp_prequeue);
+
 /*
  *	From tcp_input.c
  */
