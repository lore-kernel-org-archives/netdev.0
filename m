From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/7] tcp: tcp_tx_timestamp() cleanup
Date: Thu,  5 Oct 2017 22:21:23 -0700
Message-ID: <20171006052127.19913-4-edumazet@google.com>
References: <20171006052127.19913-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:49810 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdJFFVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 01:21:41 -0400
Received: by mail-pg0-f53.google.com with SMTP id v13so9416383pgq.6
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 22:21:41 -0700 (PDT)
In-Reply-To: <20171006052127.19913-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_write_queue_tail() call can be factorized.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f8ebae62f834ce6059d5bcf7dcb84988187dfbce..b8d379c8093661ccc4ef7fb82fa92828ab5f6918 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -469,8 +469,10 @@ void tcp_init_transfer(struct sock *sk, int bpf_op)
 	tcp_init_buffer_space(sk);
 }
 
-static void tcp_tx_timestamp(struct sock *sk, u16 tsflags, struct sk_buff *skb)
+static void tcp_tx_timestamp(struct sock *sk, u16 tsflags)
 {
+	struct sk_buff *skb = tcp_write_queue_tail(sk);
+
 	if (tsflags && skb) {
 		struct skb_shared_info *shinfo = skb_shinfo(skb);
 		struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
@@ -1041,7 +1043,7 @@ ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 
 out:
 	if (copied) {
-		tcp_tx_timestamp(sk, sk->sk_tsflags, tcp_write_queue_tail(sk));
+		tcp_tx_timestamp(sk, sk->sk_tsflags);
 		if (!(flags & MSG_SENDPAGE_NOTLAST))
 			tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
 	}
@@ -1418,7 +1420,7 @@ int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 
 out:
 	if (copied) {
-		tcp_tx_timestamp(sk, sockc.tsflags, tcp_write_queue_tail(sk));
+		tcp_tx_timestamp(sk, sockc.tsflags);
 		tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
 	}
 out_nopush:
-- 
2.14.2.920.gcf0c67979c-goog
