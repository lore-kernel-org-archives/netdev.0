From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 1/7] net: ipv4: add second dif to udp socket lookups
Date: Fri,  4 Aug 2017 13:16:57 -0700
Message-ID: <1501877823-31365-2-git-send-email-dsahern@gmail.com>
References: <1501877823-31365-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33052 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdHDURL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 16:17:11 -0400
Received: by mail-pf0-f194.google.com with SMTP id c65so2765947pfl.0
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 13:17:11 -0700 (PDT)
In-Reply-To: <1501877823-31365-1-git-send-email-dsahern@gmail.com>
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
 include/net/ip.h    | 10 +++++++++
 include/net/udp.h   |  2 +-
 net/ipv4/udp.c      | 58 +++++++++++++++++++++++++++++++----------------------
 net/ipv4/udp_diag.c |  6 +++---
 4 files changed, 48 insertions(+), 28 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 821cedcc8e73..6a2c4b4aaa98 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -78,6 +78,16 @@ struct ipcm_cookie {
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
 #define PKTINFO_SKB_CB(skb) ((struct in_pktinfo *)((skb)->cb))
 
+/* return enslaved device index if relevant */
+static inline int inet_sdif(struct sk_buff *skb)
+{
+#if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
+	if (skb && ipv4_l3mdev_skb(IPCB(skb)->flags))
+		return IPCB(skb)->iif;
+#endif
+	return 0;
+}
+
 struct ip_ra_chain {
 	struct ip_ra_chain __rcu *next;
 	struct sock		*sk;
diff --git a/include/net/udp.h b/include/net/udp.h
index cc8036987dcb..826c713d5a48 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -287,7 +287,7 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif);
 struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
-			       __be32 daddr, __be16 dport, int dif,
+			       __be32 daddr, __be16 dport, int dif, int sdif,
 			       struct udp_table *tbl, struct sk_buff *skb);
 struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e6276fa3750b..ff79bcf19276 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -380,8 +380,8 @@ int udp_v4_get_port(struct sock *sk, unsigned short snum)
 
 static int compute_score(struct sock *sk, struct net *net,
 			 __be32 saddr, __be16 sport,
-			 __be32 daddr, unsigned short hnum, int dif,
-			 bool exact_dif)
+			 __be32 daddr, unsigned short hnum,
+			 int dif, int sdif, bool exact_dif)
 {
 	int score;
 	struct inet_sock *inet;
@@ -413,10 +413,15 @@ static int compute_score(struct sock *sk, struct net *net,
 	}
 
 	if (sk->sk_bound_dev_if || exact_dif) {
-		if (sk->sk_bound_dev_if != dif)
+		bool dev_match = (sk->sk_bound_dev_if == dif ||
+				  sk->sk_bound_dev_if == sdif);
+
+		if (exact_dif && !dev_match)
 			return -1;
-		score += 4;
+		if (sk->sk_bound_dev_if && dev_match)
+			score += 4;
 	}
+
 	if (sk->sk_incoming_cpu == raw_smp_processor_id())
 		score++;
 	return score;
@@ -436,10 +441,11 @@ static u32 udp_ehashfn(const struct net *net, const __be32 laddr,
 
 /* called with rcu_read_lock() */
 static struct sock *udp4_lib_lookup2(struct net *net,
-		__be32 saddr, __be16 sport,
-		__be32 daddr, unsigned int hnum, int dif, bool exact_dif,
-		struct udp_hslot *hslot2,
-		struct sk_buff *skb)
+				     __be32 saddr, __be16 sport,
+				     __be32 daddr, unsigned int hnum,
+				     int dif, int sdif, bool exact_dif,
+				     struct udp_hslot *hslot2,
+				     struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	int score, badness, matches = 0, reuseport = 0;
@@ -449,7 +455,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 	badness = 0;
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
 		score = compute_score(sk, net, saddr, sport,
-				      daddr, hnum, dif, exact_dif);
+				      daddr, hnum, dif, sdif, exact_dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
@@ -477,8 +483,8 @@ static struct sock *udp4_lib_lookup2(struct net *net,
  * harder than this. -DaveM
  */
 struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
-		__be16 sport, __be32 daddr, __be16 dport,
-		int dif, struct udp_table *udptable, struct sk_buff *skb)
+		__be16 sport, __be32 daddr, __be16 dport, int dif,
+		int sdif, struct udp_table *udptable, struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	unsigned short hnum = ntohs(dport);
@@ -496,7 +502,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 			goto begin;
 
 		result = udp4_lib_lookup2(net, saddr, sport,
-					  daddr, hnum, dif,
+					  daddr, hnum, dif, sdif,
 					  exact_dif, hslot2, skb);
 		if (!result) {
 			unsigned int old_slot2 = slot2;
@@ -511,7 +517,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 				goto begin;
 
 			result = udp4_lib_lookup2(net, saddr, sport,
-						  daddr, hnum, dif,
+						  daddr, hnum, dif, sdif,
 						  exact_dif, hslot2, skb);
 		}
 		return result;
@@ -521,7 +527,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	badness = 0;
 	sk_for_each_rcu(sk, &hslot->head) {
 		score = compute_score(sk, net, saddr, sport,
-				      daddr, hnum, dif, exact_dif);
+				      daddr, hnum, dif, sdif, exact_dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
@@ -554,7 +560,7 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 
 	return __udp4_lib_lookup(dev_net(skb->dev), iph->saddr, sport,
 				 iph->daddr, dport, inet_iif(skb),
-				 udptable, skb);
+				 inet_sdif(skb), udptable, skb);
 }
 
 struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
@@ -576,7 +582,7 @@ struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 	struct sock *sk;
 
 	sk = __udp4_lib_lookup(net, saddr, sport, daddr, dport,
-			       dif, &udp_table, NULL);
+			       dif, 0, &udp_table, NULL);
 	if (sk && !refcount_inc_not_zero(&sk->sk_refcnt))
 		sk = NULL;
 	return sk;
@@ -587,7 +593,7 @@ EXPORT_SYMBOL_GPL(udp4_lib_lookup);
 static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
 				       __be16 loc_port, __be32 loc_addr,
 				       __be16 rmt_port, __be32 rmt_addr,
-				       int dif, unsigned short hnum)
+				       int dif, int sdif, unsigned short hnum)
 {
 	struct inet_sock *inet = inet_sk(sk);
 
@@ -597,7 +603,8 @@ static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
 	    (inet->inet_dport != rmt_port && inet->inet_dport) ||
 	    (inet->inet_rcv_saddr && inet->inet_rcv_saddr != loc_addr) ||
 	    ipv6_only_sock(sk) ||
-	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
+	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif &&
+	     sk->sk_bound_dev_if != sdif))
 		return false;
 	if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, dif))
 		return false;
@@ -628,8 +635,8 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 	struct net *net = dev_net(skb->dev);
 
 	sk = __udp4_lib_lookup(net, iph->daddr, uh->dest,
-			iph->saddr, uh->source, skb->dev->ifindex, udptable,
-			NULL);
+			       iph->saddr, uh->source, skb->dev->ifindex, 0,
+			       udptable, NULL);
 	if (!sk) {
 		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 		return;	/* No socket for error */
@@ -1956,6 +1963,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
 	unsigned int offset = offsetof(typeof(*sk), sk_node);
 	int dif = skb->dev->ifindex;
+	int sdif = inet_sdif(skb);
 	struct hlist_node *node;
 	struct sk_buff *nskb;
 
@@ -1970,7 +1978,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 
 	sk_for_each_entry_offset_rcu(sk, node, &hslot->head, offset) {
 		if (!__udp_is_mcast_sock(net, sk, uh->dest, daddr,
-					 uh->source, saddr, dif, hnum))
+					 uh->source, saddr, dif, sdif, hnum))
 			continue;
 
 		if (!first) {
@@ -2160,7 +2168,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
 						  __be16 loc_port, __be32 loc_addr,
 						  __be16 rmt_port, __be32 rmt_addr,
-						  int dif)
+						  int dif, int sdif)
 {
 	struct sock *sk, *result;
 	unsigned short hnum = ntohs(loc_port);
@@ -2174,7 +2182,7 @@ static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
 	result = NULL;
 	sk_for_each_rcu(sk, &hslot->head) {
 		if (__udp_is_mcast_sock(net, sk, loc_port, loc_addr,
-					rmt_port, rmt_addr, dif, hnum)) {
+					rmt_port, rmt_addr, dif, sdif, hnum)) {
 			if (result)
 				return NULL;
 			result = sk;
@@ -2219,6 +2227,7 @@ void udp_v4_early_demux(struct sk_buff *skb)
 	struct sock *sk = NULL;
 	struct dst_entry *dst;
 	int dif = skb->dev->ifindex;
+	int sdif = inet_sdif(skb);
 	int ours;
 
 	/* validate the packet */
@@ -2244,7 +2253,8 @@ void udp_v4_early_demux(struct sk_buff *skb)
 		}
 
 		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
-						   uh->source, iph->saddr, dif);
+						   uh->source, iph->saddr,
+						   dif, sdif);
 	} else if (skb->pkt_type == PACKET_HOST) {
 		sk = __udp4_lib_demux_lookup(net, uh->dest, iph->daddr,
 					     uh->source, iph->saddr, dif);
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 4515836d2a3a..1f07fe109535 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -45,7 +45,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		sk = __udp4_lib_lookup(net,
 				req->id.idiag_src[0], req->id.idiag_sport,
 				req->id.idiag_dst[0], req->id.idiag_dport,
-				req->id.idiag_if, tbl, NULL);
+				req->id.idiag_if, 0, tbl, NULL);
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (req->sdiag_family == AF_INET6)
 		sk = __udp6_lib_lookup(net,
@@ -182,7 +182,7 @@ static int __udp_diag_destroy(struct sk_buff *in_skb,
 		sk = __udp4_lib_lookup(net,
 				req->id.idiag_dst[0], req->id.idiag_dport,
 				req->id.idiag_src[0], req->id.idiag_sport,
-				req->id.idiag_if, tbl, NULL);
+				req->id.idiag_if, 0, tbl, NULL);
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (req->sdiag_family == AF_INET6) {
 		if (ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_dst) &&
@@ -190,7 +190,7 @@ static int __udp_diag_destroy(struct sk_buff *in_skb,
 			sk = __udp4_lib_lookup(net,
 					req->id.idiag_dst[3], req->id.idiag_dport,
 					req->id.idiag_src[3], req->id.idiag_sport,
-					req->id.idiag_if, tbl, NULL);
+					req->id.idiag_if, 0, tbl, NULL);
 
 		else
 			sk = __udp6_lib_lookup(net,
-- 
2.1.4
