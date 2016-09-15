From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: avoid sk_forward_alloc overflows
Date: Thu, 15 Sep 2016 08:48:46 -0700
Message-ID: <1473954526.22679.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34987 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751606AbcIOPss (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 11:48:48 -0400
Received: by mail-pf0-f196.google.com with SMTP id z84so2373031pfi.2
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:48:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

A malicious TCP receiver, sending SACK, can force the sender to split
skbs in write queue and increase its memory usage.

Then, when socket is closed and its write queue purged, we might
overflow sk_forward_alloc (It becomes negative)

sk_mem_reclaim() does nothing in this case, and more than 2GB
are leaked from TCP perspective (tcp_memory_allocated is not changed)

Then warnings trigger from inet_sock_destruct() and
sk_stream_kill_queues() seeing a not zero sk_forward_alloc

All TCP stack can be stuck because TCP is under memory pressure.

A simple fix is to preemptively reclaim from sk_mem_uncharge().

This makes sure a socket wont have more than 2 MB forward allocated,
after burst and idle period.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index c797c57f4d9f6b2ef6cc23f1d63210cd41c8cff4..ebf75db08e062dfe7867cc80c7699f593be16349 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1339,6 +1339,16 @@ static inline void sk_mem_uncharge(struct sock *sk, int size)
 	if (!sk_has_account(sk))
 		return;
 	sk->sk_forward_alloc += size;
+
+	/* Avoid a possible overflow.
+	 * TCP send queues can make this happen, if sk_mem_reclaim()
+	 * is not called and more than 2 GBytes are released at once.
+	 *
+	 * If we reach 2 MBytes, reclaim 1 MBytes right now, there is
+	 * no need to hold that much forward allocation anyway.
+	 */
+	if (unlikely(sk->sk_forward_alloc >= 1 << 21))
+		__sk_mem_reclaim(sk, 1 << 20);
 }
 
 static inline void sk_wmem_free_skb(struct sock *sk, struct sk_buff *skb)
