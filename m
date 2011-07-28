From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: use RCU in inet6_csk_xmit()
Date: Thu, 28 Jul 2011 15:43:47 +0200
Message-ID: <1311860627.2346.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61512 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930Ab1G1Nnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 09:43:51 -0400
Received: by wyg8 with SMTP id 8so123591wyg.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 06:43:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use RCU to avoid changing dst_entry refcount in fast path.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/inet6_connection_sock.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 8a58e8c..2916200 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -211,6 +211,7 @@ int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
 	struct flowi6 fl6;
 	struct dst_entry *dst;
 	struct in6_addr *final_p, final;
+	int res;
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_proto = sk->sk_protocol;
@@ -241,12 +242,14 @@ int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
 		__inet6_csk_dst_store(sk, dst, NULL, NULL);
 	}
 
-	skb_dst_set(skb, dst_clone(dst));
+	rcu_read_lock();
+	skb_dst_set_noref(skb, dst);
 
 	/* Restore final destination back after routing done */
 	ipv6_addr_copy(&fl6.daddr, &np->daddr);
 
-	return ip6_xmit(sk, skb, &fl6, np->opt);
+	res = ip6_xmit(sk, skb, &fl6, np->opt);
+	rcu_read_unlock();
+	return res;
 }
-
 EXPORT_SYMBOL_GPL(inet6_csk_xmit);


