From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6 flowlabel: add __rcu annotations
Date: Thu, 07 Mar 2013 06:20:32 -0800
Message-ID: <1362666032.15793.212.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:55534 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755112Ab3CGOUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 09:20:35 -0500
Received: by mail-pa0-f49.google.com with SMTP id kp6so500831pab.36
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 06:20:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 18367681a10b (ipv6 flowlabel: Convert np->ipv6_fl_list to RCU.)
omitted proper __rcu annotations.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h       |    8 ++++----
 net/ipv6/ip6_flowlabel.c |   11 ++++++++---
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 64d12e7..988c9f2 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -217,7 +217,7 @@ struct ipv6_txoptions {
 };
 
 struct ip6_flowlabel {
-	struct ip6_flowlabel	*next;
+	struct ip6_flowlabel __rcu *next;
 	__be32			label;
 	atomic_t		users;
 	struct in6_addr		dst;
@@ -238,9 +238,9 @@ struct ip6_flowlabel {
 #define IPV6_FLOWLABEL_MASK	cpu_to_be32(0x000FFFFF)
 
 struct ipv6_fl_socklist {
-	struct ipv6_fl_socklist	*next;
-	struct ip6_flowlabel	*fl;
-	struct rcu_head		rcu;
+	struct ipv6_fl_socklist	__rcu	*next;
+	struct ip6_flowlabel		*fl;
+	struct rcu_head			rcu;
 };
 
 extern struct ip6_flowlabel	*fl6_sock_lookup(struct sock *sk, __be32 label);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index b973ed3..46e8843 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -144,7 +144,9 @@ static void ip6_fl_gc(unsigned long dummy)
 	spin_lock(&ip6_fl_lock);
 
 	for (i=0; i<=FL_HASH_MASK; i++) {
-		struct ip6_flowlabel *fl, **flp;
+		struct ip6_flowlabel *fl;
+		struct ip6_flowlabel __rcu **flp;
+
 		flp = &fl_ht[i];
 		while ((fl = rcu_dereference_protected(*flp,
 						       lockdep_is_held(&ip6_fl_lock))) != NULL) {
@@ -179,7 +181,9 @@ static void __net_exit ip6_fl_purge(struct net *net)
 
 	spin_lock(&ip6_fl_lock);
 	for (i = 0; i <= FL_HASH_MASK; i++) {
-		struct ip6_flowlabel *fl, **flp;
+		struct ip6_flowlabel *fl;
+		struct ip6_flowlabel __rcu **flp;
+
 		flp = &fl_ht[i];
 		while ((fl = rcu_dereference_protected(*flp,
 						       lockdep_is_held(&ip6_fl_lock))) != NULL) {
@@ -506,7 +510,8 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_flowlabel_req freq;
 	struct ipv6_fl_socklist *sfl1=NULL;
-	struct ipv6_fl_socklist *sfl, **sflp;
+	struct ipv6_fl_socklist *sfl;
+	struct ipv6_fl_socklist __rcu **sflp;
 	struct ip6_flowlabel *fl, *fl1 = NULL;
 
 
