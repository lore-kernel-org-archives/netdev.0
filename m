From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATC net-next] tcp: must block bh in __inet_twsk_hashdance()
Date: Tue, 03 May 2016 17:10:50 -0700
Message-ID: <1462320650.5535.334.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36811 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756826AbcEDAKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 20:10:54 -0400
Received: by mail-pf0-f172.google.com with SMTP id c189so18085581pfb.3
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 17:10:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

__inet_twsk_hashdance() might be called from process context,
better block BH before acquiring bind hash and established locks

Fixes: c10d9310edf5 ("tcp: do not assume TCP code is non preemptible")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_timewait_sock.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 99ee5c4a9b6844929a995b0b4b5bd693bb211123..2065816748066986f0356df168c2d76fe2d53d85 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -94,7 +94,7 @@ static void inet_twsk_add_bind_node(struct inet_timewait_sock *tw,
 }
 
 /*
- * Enter the time wait state. This is called with locally disabled BH.
+ * Enter the time wait state.
  * Essentially we whip up a timewait bucket, copy the relevant info into it
  * from the SK, and mess with hash chains and list linkage.
  */
@@ -112,7 +112,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 	 */
 	bhead = &hashinfo->bhash[inet_bhashfn(twsk_net(tw), inet->inet_num,
 			hashinfo->bhash_size)];
-	spin_lock(&bhead->lock);
+	spin_lock_bh(&bhead->lock);
 	tw->tw_tb = icsk->icsk_bind_hash;
 	WARN_ON(!icsk->icsk_bind_hash);
 	inet_twsk_add_bind_node(tw, &tw->tw_tb->owners);
@@ -138,7 +138,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 	if (__sk_nulls_del_node_init_rcu(sk))
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 
-	spin_unlock(lock);
+	spin_unlock_bh(lock);
 }
 EXPORT_SYMBOL_GPL(__inet_twsk_hashdance);
 
