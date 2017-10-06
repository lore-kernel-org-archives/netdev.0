From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/7] tcp: uninline tcp_write_queue_purge()
Date: Thu,  5 Oct 2017 22:21:22 -0700
Message-ID: <20171006052127.19913-3-edumazet@google.com>
References: <20171006052127.19913-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:46795 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751644AbdJFFVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 01:21:39 -0400
Received: by mail-pg0-f44.google.com with SMTP id k7so4462160pga.3
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 22:21:39 -0700 (PDT)
In-Reply-To: <20171006052127.19913-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the upcoming rtx rbtree will add some extra code,
it is time to not inline this fat function anymore.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h | 15 +--------------
 net/ipv4/tcp.c    | 14 ++++++++++++++
 2 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3b16f353b539a563dae0b37328a52d67e6476f31..744559b727847db79b9751e6c6bef57e83c141f8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1606,20 +1606,7 @@ static inline void tcp_skb_tsorted_anchor_cleanup(struct sk_buff *skb)
 	skb->_skb_refdst = _save;		\
 }
 
-/* write queue abstraction */
-static inline void tcp_write_queue_purge(struct sock *sk)
-{
-	struct sk_buff *skb;
-
-	tcp_chrono_stop(sk, TCP_CHRONO_BUSY);
-	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL) {
-		tcp_skb_tsorted_anchor_cleanup(skb);
-		sk_wmem_free_skb(sk, skb);
-	}
-	INIT_LIST_HEAD(&tcp_sk(sk)->tsorted_sent_queue);
-	sk_mem_reclaim(sk);
-	tcp_clear_all_retrans_hints(tcp_sk(sk));
-}
+void tcp_write_queue_purge(struct sock *sk);
 
 static inline struct sk_buff *tcp_write_queue_head(const struct sock *sk)
 {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8cf742fd4f99d7eb1bd9632afcfb09c36ba1130e..f8ebae62f834ce6059d5bcf7dcb84988187dfbce 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2318,6 +2318,20 @@ static inline bool tcp_need_reset(int state)
 		TCPF_FIN_WAIT2 | TCPF_SYN_RECV);
 }
 
+void tcp_write_queue_purge(struct sock *sk)
+{
+	struct sk_buff *skb;
+
+	tcp_chrono_stop(sk, TCP_CHRONO_BUSY);
+	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL) {
+		tcp_skb_tsorted_anchor_cleanup(skb);
+		sk_wmem_free_skb(sk, skb);
+	}
+	INIT_LIST_HEAD(&tcp_sk(sk)->tsorted_sent_queue);
+	sk_mem_reclaim(sk);
+	tcp_clear_all_retrans_hints(tcp_sk(sk));
+}
+
 int tcp_disconnect(struct sock *sk, int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
-- 
2.14.2.920.gcf0c67979c-goog
