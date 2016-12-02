From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/4] tcp: tsq: remove one locked operation in tcp_wfree()
Date: Fri,  2 Dec 2016 10:25:57 -0800
Message-ID: <1480703159-2327-3-git-send-email-edumazet@google.com>
References: <1480703159-2327-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35104 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752249AbcLBS1b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:27:31 -0500
Received: by mail-pg0-f51.google.com with SMTP id p66so110023260pga.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:26:20 -0800 (PST)
In-Reply-To: <1480703159-2327-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of atomically clear TSQ_THROTTLED and atomically set TSQ_QUEUED
bits, use one cmpxchg() to perform a single locked operation.

Since the following patch will also set TCP_TSQ_DEFERRED here,
this cmpxchg() will make this addition free.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ac55aefc881d..76be79437595 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -860,6 +860,7 @@ void tcp_wfree(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned long flags, nval, oval;
 	int wmem;
 
 	/* Keep one reference on sk_wmem_alloc.
@@ -877,11 +878,17 @@ void tcp_wfree(struct sk_buff *skb)
 	if (wmem >= SKB_TRUESIZE(1) && this_cpu_ksoftirqd() == current)
 		goto out;
 
-	if (test_and_clear_bit(TSQ_THROTTLED, &tp->tsq_flags) &&
-	    !test_and_set_bit(TSQ_QUEUED, &tp->tsq_flags)) {
-		unsigned long flags;
+	for (oval = READ_ONCE(tp->tsq_flags);; oval = nval) {
 		struct tsq_tasklet *tsq;
 
+		if (!(oval & TSQF_THROTTLED) || (oval & TSQF_QUEUED))
+			goto out;
+
+		nval = (oval & ~TSQF_THROTTLED) | TSQF_QUEUED;
+		nval = cmpxchg(&tp->tsq_flags, oval, nval);
+		if (nval != oval)
+			continue;
+
 		/* queue this socket to tasklet queue */
 		local_irq_save(flags);
 		tsq = this_cpu_ptr(&tsq_tasklet);
-- 
2.8.0.rc3.226.g39d4020
