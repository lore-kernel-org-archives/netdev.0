From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/4] tcp: tsq: add shortcut in tcp_tasklet_func()
Date: Fri,  2 Dec 2016 10:25:58 -0800
Message-ID: <1480703159-2327-4-git-send-email-edumazet@google.com>
References: <1480703159-2327-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35884 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752286AbcLBS1b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:27:31 -0500
Received: by mail-pg0-f51.google.com with SMTP id f188so109585077pgc.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:26:27 -0800 (PST)
In-Reply-To: <1480703159-2327-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under high stress, I've seen tcp_tasklet_func() consuming
~700 usec, handling ~150 tcp sockets.

By setting TCP_TSQ_DEFERRED in tcp_wfree(), we give a chance
for other cpus/threads entering tcp_write_xmit() to grab it,
allowing tcp_tasklet_func() to skip sockets that already did
an xmit cycle.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 76be79437595..9143c52b3105 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -767,19 +767,19 @@ static void tcp_tasklet_func(unsigned long data)
 	list_for_each_safe(q, n, &list) {
 		tp = list_entry(q, struct tcp_sock, tsq_node);
 		list_del(&tp->tsq_node);
+		clear_bit(TSQ_QUEUED, &tp->tsq_flags);
 
 		sk = (struct sock *)tp;
-		bh_lock_sock(sk);
-
-		if (!sock_owned_by_user(sk)) {
-			tcp_tsq_handler(sk);
-		} else {
-			/* defer the work to tcp_release_cb() */
-			set_bit(TCP_TSQ_DEFERRED, &tp->tsq_flags);
+		if (!sk->sk_lock.owned &&
+		    test_bit(TCP_TSQ_DEFERRED, &tp->tsq_flags)) {
+			bh_lock_sock(sk);
+			if (!sock_owned_by_user(sk)) {
+				clear_bit(TCP_TSQ_DEFERRED, &tp->tsq_flags);
+				tcp_tsq_handler(sk);
+			}
+			bh_unlock_sock(sk);
 		}
-		bh_unlock_sock(sk);
 
-		clear_bit(TSQ_QUEUED, &tp->tsq_flags);
 		sk_free(sk);
 	}
 }
@@ -884,7 +884,7 @@ void tcp_wfree(struct sk_buff *skb)
 		if (!(oval & TSQF_THROTTLED) || (oval & TSQF_QUEUED))
 			goto out;
 
-		nval = (oval & ~TSQF_THROTTLED) | TSQF_QUEUED;
+		nval = (oval & ~TSQF_THROTTLED) | TSQF_QUEUED | TCP_TSQ_DEFERRED;
 		nval = cmpxchg(&tp->tsq_flags, oval, nval);
 		if (nval != oval)
 			continue;
@@ -2229,6 +2229,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
 			break;
 
+		if (test_bit(TCP_TSQ_DEFERRED, &tp->tsq_flags))
+			clear_bit(TCP_TSQ_DEFERRED, &tp->tsq_flags);
 		if (tcp_small_queue_check(sk, skb, 0))
 			break;
 
-- 
2.8.0.rc3.226.g39d4020
