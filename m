From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v3 net-next 5/7] net: ipv6: add second dif to udp socket lookups
Date: Mon,  7 Aug 2017 08:44:20 -0700
Message-ID: <1502120662-1430-6-git-send-email-dsahern@gmail.com>
References: <1502120662-1430-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:38178 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751457AbdHGPol (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 11:44:41 -0400
Received: by mail-pg0-f67.google.com with SMTP id 123so694213pga.5
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 08:44:41 -0700 (PDT)
In-Reply-To: <1502120662-1430-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a second device index, sdif, to udp socket lookups. sdif is the
index for ingress devices enslaved to an l3mdev. It allows the lookups
to consider the enslaved device as well as the L3 domain when searching
for a socket.

Early demux lookups are handled in the next patch as part of INET_MATCH
changes.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/ipv6.h | 10 ++++++++++
 include/net/udp.h    |  2 +-
 net/ipv4/udp_diag.c  |  4 ++--
 net/ipv6/udp.c       | 40 ++++++++++++++++++++++------------------
 4 files changed, 35 insertions(+), 21 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 474d6bbc158c..ac2da4e11d5e 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -159,6 +159,16 @@ static inline bool inet6_is_jumbogram(const struct sk_buff *skb)
 }
 
 /* can not be used in TCP layer after tcp_v6_fill_cb */
+static inline int inet6_sdif(const struct sk_buff *skb)
+{
+#if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
+	if (skb && ipv6_l3mdev_skb(IP6CB(skb)->flags))
+		return IP6CB(skb)->iif;
+#endif
+	return 0;
+}
+
+/* can not be used in TCP layer after tcp_v6_fill_cb */
 static inline bool inet6_exact_dif_match(struct net *net, struct sk_buff *skb)
 {
 #if defined(CONFIG_NET_L3_MASTER_DEV)
diff --git a/include/net/udp.h b/include/net/udp.h
index 826c713d5a48..20dcdca4e85c 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -298,7 +298,7 @@ struct sock *udp6_lib_lookup(struct net *net,
 struct sock *__udp6_lib_lookup(struct net *net,
 			       const struct in6_addr *saddr, __be16 sport,
 			       const struct in6_addr *daddr, __be16 dport,
-			       int dif, struct udp_table *tbl,
+			       int dif, int sdif, struct udp_table *tbl,
 			       struct sk_buff *skb);
 struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 1f07fe109535..d0390d844ac8 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -53,7 +53,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 				req->id.idiag_sport,
 				(struct in6_addr *)req->id.idiag_dst,
 				req->id.idiag_dport,
-				req->id.idiag_if, tbl, NULL);
+				req->id.idiag_if, 0, tbl, NULL);
 #endif
 	if (sk && !refcount_inc_not_zero(&sk->sk_refcnt))
 		sk = NULL;
@@ -198,7 +198,7 @@ static int __udp_diag_destroy(struct sk_buff *in_skb,
 					req->id.idiag_dport,
 					(struct in6_addr *)req->id.idiag_src,
 					req->id.idiag_sport,
-					req->id.idiag_if, tbl, NULL);
+					req->id.idiag_if, 0, tbl, NULL);
 	}
 #endif
 	else {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 578142b7ca3e..d96a877798a7 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -129,7 +129,7 @@ static void udp_v6_rehash(struct sock *sk)
 static int compute_score(struct sock *sk, struct net *net,
 			 const struct in6_addr *saddr, __be16 sport,
 			 const struct in6_addr *daddr, unsigned short hnum,
-			 int dif, bool exact_dif)
+			 int dif, int sdif, bool exact_dif)
 {
 	int score;
 	struct inet_sock *inet;
@@ -161,9 +161,13 @@ static int compute_score(struct sock *sk, struct net *net,
 	}
 
 	if (sk->sk_bound_dev_if || exact_dif) {
-		if (sk->sk_bound_dev_if != dif)
+		bool dev_match = (sk->sk_bound_dev_if == dif ||
+				  sk->sk_bound_dev_if == sdif);
+
+		if (exact_dif && !dev_match)
 			return -1;
-		score++;
+		if (sk->sk_bound_dev_if && dev_match)
+			score++;
 	}
 
 	if (sk->sk_incoming_cpu == raw_smp_processor_id())
@@ -175,9 +179,9 @@ static int compute_score(struct sock *sk, struct net *net,
 /* called with rcu_read_lock() */
 static struct sock *udp6_lib_lookup2(struct net *net,
 		const struct in6_addr *saddr, __be16 sport,
-		const struct in6_addr *daddr, unsigned int hnum, int dif,
-		bool exact_dif, struct udp_hslot *hslot2,
-		struct sk_buff *skb)
+		const struct in6_addr *daddr, unsigned int hnum,
+		int dif, int sdif, bool exact_dif,
+		struct udp_hslot *hslot2, struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	int score, badness, matches = 0, reuseport = 0;
@@ -187,7 +191,7 @@ static struct sock *udp6_lib_lookup2(struct net *net,
 	badness = -1;
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
 		score = compute_score(sk, net, saddr, sport,
-				      daddr, hnum, dif, exact_dif);
+				      daddr, hnum, dif, sdif, exact_dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
@@ -214,10 +218,10 @@ static struct sock *udp6_lib_lookup2(struct net *net,
 
 /* rcu_read_lock() must be held */
 struct sock *__udp6_lib_lookup(struct net *net,
-				      const struct in6_addr *saddr, __be16 sport,
-				      const struct in6_addr *daddr, __be16 dport,
-				      int dif, struct udp_table *udptable,
-				      struct sk_buff *skb)
+			       const struct in6_addr *saddr, __be16 sport,
+			       const struct in6_addr *daddr, __be16 dport,
+			       int dif, int sdif, struct udp_table *udptable,
+			       struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	unsigned short hnum = ntohs(dport);
@@ -235,7 +239,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 			goto begin;
 
 		result = udp6_lib_lookup2(net, saddr, sport,
-					  daddr, hnum, dif, exact_dif,
+					  daddr, hnum, dif, sdif, exact_dif,
 					  hslot2, skb);
 		if (!result) {
 			unsigned int old_slot2 = slot2;
@@ -250,7 +254,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 				goto begin;
 
 			result = udp6_lib_lookup2(net, saddr, sport,
-						  daddr, hnum, dif,
+						  daddr, hnum, dif, sdif,
 						  exact_dif, hslot2,
 						  skb);
 		}
@@ -261,7 +265,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 	badness = -1;
 	sk_for_each_rcu(sk, &hslot->head) {
 		score = compute_score(sk, net, saddr, sport, daddr, hnum, dif,
-				      exact_dif);
+				      sdif, exact_dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
@@ -294,7 +298,7 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 
 	return __udp6_lib_lookup(dev_net(skb->dev), &iph->saddr, sport,
 				 &iph->daddr, dport, inet6_iif(skb),
-				 udptable, skb);
+				 inet6_sdif(skb), udptable, skb);
 }
 
 struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
@@ -304,7 +308,7 @@ struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 
 	return __udp6_lib_lookup(dev_net(skb->dev), &iph->saddr, sport,
 				 &iph->daddr, dport, inet6_iif(skb),
-				 &udp_table, skb);
+				 inet6_sdif(skb), &udp_table, skb);
 }
 EXPORT_SYMBOL_GPL(udp6_lib_lookup_skb);
 
@@ -320,7 +324,7 @@ struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be
 	struct sock *sk;
 
 	sk =  __udp6_lib_lookup(net, saddr, sport, daddr, dport,
-				dif, &udp_table, NULL);
+				dif, 0, &udp_table, NULL);
 	if (sk && !refcount_inc_not_zero(&sk->sk_refcnt))
 		sk = NULL;
 	return sk;
@@ -501,7 +505,7 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct net *net = dev_net(skb->dev);
 
 	sk = __udp6_lib_lookup(net, daddr, uh->dest, saddr, uh->source,
-			       inet6_iif(skb), udptable, skb);
+			       inet6_iif(skb), 0, udptable, skb);
 	if (!sk) {
 		__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev),
 				  ICMP6_MIB_INERRORS);
-- 
2.1.4
