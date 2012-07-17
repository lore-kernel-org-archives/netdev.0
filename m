From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: fix rcu splat
Date: Tue, 17 Jul 2012 22:42:13 +0200
Message-ID: <1342557733.2626.1103.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:65351 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab2GQUmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 16:42:19 -0400
Received: by ghrr11 with SMTP id r11so872388ghr.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 13:42:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

free_nh_exceptions() should use rcu_dereference_protected(..., 1)
since its called after one RCU grace period.

Also add some const-ification in recent code.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/fib_semantics.c        |    4 ++--
 net/ipv4/inet_connection_sock.c |    4 ++--
 net/ipv4/route.c                |   13 +++++++------
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 1e09852..2b57d76 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -148,11 +148,11 @@ static void free_nh_exceptions(struct fib_nh *nh)
 	for (i = 0; i < FNHE_HASH_SIZE; i++) {
 		struct fib_nh_exception *fnhe;
 
-		fnhe = rcu_dereference(hash[i].chain);
+		fnhe = rcu_dereference_protected(hash[i].chain, 1);
 		while (fnhe) {
 			struct fib_nh_exception *next;
 			
-			next = rcu_dereference(fnhe->fnhe_next);
+			next = rcu_dereference_protected(fnhe->fnhe_next, 1);
 			kfree(fnhe);
 
 			fnhe = next;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 89e74a3..68bb5a6 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -806,8 +806,8 @@ EXPORT_SYMBOL_GPL(inet_csk_compat_setsockopt);
 
 static struct dst_entry *inet_csk_rebuild_route(struct sock *sk, struct flowi *fl)
 {
-	struct inet_sock *inet = inet_sk(sk);
-	struct ip_options_rcu *inet_opt;
+	const struct inet_sock *inet = inet_sk(sk);
+	const struct ip_options_rcu *inet_opt;
 	__be32 daddr = inet->inet_daddr;
 	struct flowi4 *fl4;
 	struct rtable *rt;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 812e444..f67e702 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1275,7 +1275,7 @@ static void rt_del(unsigned int hash, struct rtable *rt)
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
-static void __build_flow_key(struct flowi4 *fl4, struct sock *sk,
+static void __build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 			     const struct iphdr *iph,
 			     int oif, u8 tos,
 			     u8 prot, u32 mark, int flow_flags)
@@ -1294,7 +1294,8 @@ static void __build_flow_key(struct flowi4 *fl4, struct sock *sk,
 			   iph->daddr, iph->saddr, 0, 0);
 }
 
-static void build_skb_flow_key(struct flowi4 *fl4, struct sk_buff *skb, struct sock *sk)
+static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
+			       const struct sock *sk)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	int oif = skb->dev->ifindex;
@@ -1305,10 +1306,10 @@ static void build_skb_flow_key(struct flowi4 *fl4, struct sk_buff *skb, struct s
 	__build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
 }
 
-static void build_sk_flow_key(struct flowi4 *fl4, struct sock *sk)
+static void build_sk_flow_key(struct flowi4 *fl4, const struct sock *sk)
 {
 	const struct inet_sock *inet = inet_sk(sk);
-	struct ip_options_rcu *inet_opt;
+	const struct ip_options_rcu *inet_opt;
 	__be32 daddr = inet->inet_daddr;
 
 	rcu_read_lock();
@@ -1323,8 +1324,8 @@ static void build_sk_flow_key(struct flowi4 *fl4, struct sock *sk)
 	rcu_read_unlock();
 }
 
-static void ip_rt_build_flow_key(struct flowi4 *fl4, struct sock *sk,
-				 struct sk_buff *skb)
+static void ip_rt_build_flow_key(struct flowi4 *fl4, const struct sock *sk,
+				 const struct sk_buff *skb)
 {
 	if (skb)
 		build_skb_flow_key(fl4, skb, sk);
