From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/6] net: do not block BH while processing socket backlog
Date: Wed, 27 Apr 2016 22:25:52 -0700
Message-ID: <1461821152-23200-7-git-send-email-edumazet@google.com>
References: <1461821152-23200-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33282 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcD1F0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 01:26:15 -0400
Received: by mail-pa0-f49.google.com with SMTP id zm5so31079618pac.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 22:26:15 -0700 (PDT)
In-Reply-To: <1461821152-23200-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Socket backlog processing is a major latency source.

With current TCP socket sk_rcvbuf limits, I have sampled __release_sock()
holding cpu for more than 5 ms, and packets being dropped by the NIC
once ring buffer is filled.

All users are now ready to be called from process context,
we can unblock BH and let interrupts be serviced faster.

cond_resched_softirq() could be removed, as it has no more user.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index e16a5db853c6..70744dbb6c3f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2019,33 +2019,27 @@ static void __release_sock(struct sock *sk)
 	__releases(&sk->sk_lock.slock)
 	__acquires(&sk->sk_lock.slock)
 {
-	struct sk_buff *skb = sk->sk_backlog.head;
+	struct sk_buff *skb, *next;
 
-	do {
+	while ((skb = sk->sk_backlog.head) != NULL) {
 		sk->sk_backlog.head = sk->sk_backlog.tail = NULL;
-		bh_unlock_sock(sk);
 
-		do {
-			struct sk_buff *next = skb->next;
+		spin_unlock_bh(&sk->sk_lock.slock);
 
+		do {
+			next = skb->next;
 			prefetch(next);
 			WARN_ON_ONCE(skb_dst_is_noref(skb));
 			skb->next = NULL;
 			sk_backlog_rcv(sk, skb);
 
-			/*
-			 * We are in process context here with softirqs
-			 * disabled, use cond_resched_softirq() to preempt.
-			 * This is safe to do because we've taken the backlog
-			 * queue private:
-			 */
-			cond_resched_softirq();
+			cond_resched();
 
 			skb = next;
 		} while (skb != NULL);
 
-		bh_lock_sock(sk);
-	} while ((skb = sk->sk_backlog.head) != NULL);
+		spin_lock_bh(&sk->sk_lock.slock);
+	}
 
 	/*
 	 * Doing the zeroing here guarantee we can not loop forever
-- 
2.8.0.rc3.226.g39d4020
