From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/6] tcp: rename sk_forced_wmem_schedule() to sk_forced_mem_schedule()
Date: Fri, 15 May 2015 07:53:54 -0700
Message-ID: <1431701638-24451-3-git-send-email-edumazet@google.com>
References: <1431701638-24451-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>, Jason Baron <jbaron@akamai.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f74.google.com ([209.85.218.74]:33075 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbbEOOyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 10:54:17 -0400
Received: by oiax69 with SMTP id x69so6310632oia.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 07:54:16 -0700 (PDT)
In-Reply-To: <1431701638-24451-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We plan to use sk_forced_wmem_schedule() in input path as well,
so make it non static and rename it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     | 2 ++
 net/ipv4/tcp_output.c | 6 ++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7ace6acbf5fd..841691a296dc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -311,6 +311,8 @@ static inline bool tcp_out_of_memory(struct sock *sk)
 	return false;
 }
 
+void sk_forced_mem_schedule(struct sock *sk, int size);
+
 static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
 {
 	struct percpu_counter *ocp = sk->sk_prot->orphan_count;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7386d32cd670..bac1a950d087 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2816,8 +2816,10 @@ begin_fwd:
  * connection tear down and (memory) recovery.
  * Otherwise tcp_send_fin() could be tempted to either delay FIN
  * or even be forced to close flow without any FIN.
+ * In general, we want to allow one skb per socket to avoid hangs
+ * with edge trigger epoll()
  */
-static void sk_forced_wmem_schedule(struct sock *sk, int size)
+void sk_forced_mem_schedule(struct sock *sk, int size)
 {
 	int amt, status;
 
@@ -2864,7 +2866,7 @@ coalesce:
 			return;
 		}
 		skb_reserve(skb, MAX_TCP_HEADER);
-		sk_forced_wmem_schedule(sk, skb->truesize);
+		sk_forced_mem_schedule(sk, skb->truesize);
 		/* FIN eats a sequence byte, write_seq advanced by tcp_queue_skb(). */
 		tcp_init_nondata_skb(skb, tp->write_seq,
 				     TCPHDR_ACK | TCPHDR_FIN);
-- 
2.2.0.rc0.207.ga3a616c
