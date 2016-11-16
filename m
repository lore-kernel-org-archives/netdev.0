From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] udp: enable busy polling for all sockets
Date: Wed, 16 Nov 2016 09:10:42 -0800
Message-ID: <1479316242.8455.213.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35662 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932162AbcKPRKo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 12:10:44 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so15181107pga.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 09:10:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

UDP busy polling is restricted to connected UDP sockets.

This is because sk_busy_loop() only takes care of one NAPI context.

There are cases where it could be extended.

1) Some hosts receive traffic on a single NIC, with one RX queue.

2) Some applications use SO_REUSEPORT and associated BPF filter
   to split the incoming traffic on one UDP socket per RX
queue/thread/cpu

3) Some UDP sockets are used to send/receive traffic for one flow, but
they do not bother with connect()


This patch records the napi_id of first received skb, giving more
reach to busy polling.

Tested:

lpaa23:~# echo 70 >/proc/sys/net/core/busy_read
lpaa24:~# echo 70 >/proc/sys/net/core/busy_read

lpaa23:~# for f in `seq 1 10`; do ./super_netperf 1 -H lpaa24 -t UDP_RR -l 5; done

Before patch :
   27867   28870   37324   41060   41215
   36764   36838   44455   41282   43843
After patch :
   73920   73213   70147   74845   71697
   68315   68028   75219   70082   73707

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 include/net/busy_poll.h |   28 +++++++++++++++++++---------
 net/ipv4/udp.c          |    2 ++
 net/ipv6/udp.c          |    2 ++
 3 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 2fbeb1313c0f4f78ac82ddf6c18d1016a901f99a..34c57a0ec040a58f09b12e3878f534433dc30015 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -81,11 +81,6 @@ static inline void skb_mark_napi_id(struct sk_buff *skb,
 	skb->napi_id = napi->napi_id;
 }
 
-/* used in the protocol hanlder to propagate the napi_id to the socket */
-static inline void sk_mark_napi_id(struct sock *sk, struct sk_buff *skb)
-{
-	sk->sk_napi_id = skb->napi_id;
-}
 
 #else /* CONFIG_NET_RX_BUSY_POLL */
 static inline unsigned long net_busy_loop_on(void)
@@ -108,10 +103,6 @@ static inline void skb_mark_napi_id(struct sk_buff *skb,
 {
 }
 
-static inline void sk_mark_napi_id(struct sock *sk, struct sk_buff *skb)
-{
-}
-
 static inline bool busy_loop_timeout(unsigned long end_time)
 {
 	return true;
@@ -123,4 +114,23 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 }
 
 #endif /* CONFIG_NET_RX_BUSY_POLL */
+
+/* used in the protocol hanlder to propagate the napi_id to the socket */
+static inline void sk_mark_napi_id(struct sock *sk, const struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	sk->sk_napi_id = skb->napi_id;
+#endif
+}
+
+/* variant used for unconnected sockets */
+static inline void sk_mark_napi_id_once(struct sock *sk,
+					const struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	if (!sk->sk_napi_id)
+		sk->sk_napi_id = skb->napi_id;
+#endif
+}
+
 #endif /* _LINUX_NET_BUSY_POLL_H */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9ae7c63a8b131f56a3c05e00a8f7d106a0362c54..e1fc0116e8d59d8185670c6e55d1219bde55610d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1569,6 +1569,8 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sock_rps_save_rxhash(sk, skb);
 		sk_mark_napi_id(sk, skb);
 		sk_incoming_cpu_update(sk);
+	} else {
+		sk_mark_napi_id_once(sk, skb);
 	}
 
 	rc = __udp_enqueue_schedule_skb(sk, skb);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 86a8cacd333b64f40acc7350a45213cb422a9c1a..4f99417d9b401f2a65c7828e7d6b86d1d6161794 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -519,6 +519,8 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sock_rps_save_rxhash(sk, skb);
 		sk_mark_napi_id(sk, skb);
 		sk_incoming_cpu_update(sk);
+	} else {
+		sk_mark_napi_id_once(sk, skb);
 	}
 
 	rc = __udp_enqueue_schedule_skb(sk, skb);
