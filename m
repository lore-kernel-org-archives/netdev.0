From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] inet: add proper locking in __inet{6}_lookup()
Date: Fri, 25 Mar 2016 15:15:15 -0700
Message-ID: <1458944115.6473.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Lorenzo Colitti <lorenzo@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34430 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754349AbcCYWPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 18:15:18 -0400
Received: by mail-pa0-f46.google.com with SMTP id fe3so54102560pab.1
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 15:15:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Blocking BH in __inet{6}_lookup() is not correct, as the lookups
are done using RCU protection.

It matters only starting from Lorenzo Colitti patches to destroy
a TCP socket, since rcu_read_lock() is already held by other users
of these functions.

This can be backported to all known stable versions, since TCP got RCU
lookups back in 2.6.29 : Even if iproute2 contained no code to trigger
the bug, some user programs could have used the API.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/inet_hashtables.h |    5 ++---
 net/ipv6/inet6_hashtables.c   |    5 ++---
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 50f635c2c536..4575d4f9509a 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -284,7 +284,6 @@ static inline struct sock *inet_lookup_listener(struct net *net,
  * Sockets in TCP_CLOSE state are _always_ taken out of the hash, so we need
  * not check it for lookups anymore, thanks Alexey. -DaveM
  *
- * Local BH must be disabled here.
  */
 struct sock *__inet_lookup_established(struct net *net,
 				       struct inet_hashinfo *hashinfo,
@@ -326,10 +325,10 @@ static inline struct sock *inet_lookup(struct net *net,
 {
 	struct sock *sk;
 
-	local_bh_disable();
+	rcu_read_lock();
 	sk = __inet_lookup(net, hashinfo, skb, doff, saddr, sport, daddr,
 			   dport, dif);
-	local_bh_enable();
+	rcu_read_unlock();
 
 	return sk;
 }
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 70f2628be6fa..9dcd0481fae2 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -200,11 +200,10 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 {
 	struct sock *sk;
 
-	local_bh_disable();
+	rcu_read_lock();
 	sk = __inet6_lookup(net, hashinfo, skb, doff, saddr, sport, daddr,
 			    ntohs(dport), dif);
-	local_bh_enable();
-
+	rcu_read_unlock();
 	return sk;
 }
 EXPORT_SYMBOL_GPL(inet6_lookup);
