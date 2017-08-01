From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 06/10] net: ipv6: Convert inet socket lookups to new struct
Date: Mon, 31 Jul 2017 20:13:22 -0700
Message-ID: <1501557206-27503-7-git-send-email-dsahern@gmail.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33007 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751779AbdHADNq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:13:46 -0400
Received: by mail-pg0-f67.google.com with SMTP id u185so596510pgb.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:13:46 -0700 (PDT)
In-Reply-To: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the various inet6_lookup functions to use the new sk_lookup
struct.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/inet6_hashtables.h      | 39 +++++++-------------
 net/dccp/ipv6.c                     | 22 ++++++++----
 net/ipv4/inet_diag.c                | 19 ++++++----
 net/ipv4/udp_diag.c                 |  2 ++
 net/ipv6/inet6_hashtables.c         | 72 +++++++++++++++++++------------------
 net/ipv6/netfilter/nf_socket_ipv6.c |  5 ++-
 net/ipv6/tcp_ipv6.c                 | 60 +++++++++++++++++++++----------
 net/netfilter/xt_TPROXY.c           |  8 ++---
 8 files changed, 125 insertions(+), 102 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index b87becacd9d3..15db41272ff2 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -46,63 +46,50 @@ static inline unsigned int __inet6_ehashfn(const u32 lhash,
  */
 struct sock *__inet6_lookup_established(struct net *net,
 					struct inet_hashinfo *hashinfo,
-					const struct in6_addr *saddr,
-					const __be16 sport,
-					const struct in6_addr *daddr,
-					const u16 hnum, const int dif);
+					const struct sk_lookup *params);
 
 struct sock *inet6_lookup_listener(struct net *net,
 				   struct inet_hashinfo *hashinfo,
 				   struct sk_buff *skb, int doff,
-				   const struct in6_addr *saddr,
-				   const __be16 sport,
-				   const struct in6_addr *daddr,
-				   const unsigned short hnum, const int dif);
+				   struct sk_lookup *params);
 
 static inline struct sock *__inet6_lookup(struct net *net,
 					  struct inet_hashinfo *hashinfo,
 					  struct sk_buff *skb, int doff,
-					  const struct in6_addr *saddr,
-					  const __be16 sport,
-					  const struct in6_addr *daddr,
-					  const u16 hnum,
-					  const int dif,
+					  struct sk_lookup *params,
 					  bool *refcounted)
 {
-	struct sock *sk = __inet6_lookup_established(net, hashinfo, saddr,
-						sport, daddr, hnum, dif);
+	struct sock *sk = __inet6_lookup_established(net, hashinfo, params);
+
 	*refcounted = true;
 	if (sk)
 		return sk;
 	*refcounted = false;
-	return inet6_lookup_listener(net, hashinfo, skb, doff, saddr, sport,
-				     daddr, hnum, dif);
+	return inet6_lookup_listener(net, hashinfo, skb, doff, params);
 }
 
 static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
 					      struct sk_buff *skb, int doff,
-					      const __be16 sport,
-					      const __be16 dport,
-					      int iif,
+					      struct sk_lookup *params,
 					      bool *refcounted)
 {
 	struct sock *sk = skb_steal_sock(skb);
 
+	params->saddr.ipv6 = &ipv6_hdr(skb)->saddr,
+	params->daddr.ipv6 = &ipv6_hdr(skb)->daddr,
+	params->hnum = ntohs(params->dport),
+
 	*refcounted = true;
 	if (sk)
 		return sk;
 
 	return __inet6_lookup(dev_net(skb_dst(skb)->dev), hashinfo, skb,
-			      doff, &ipv6_hdr(skb)->saddr, sport,
-			      &ipv6_hdr(skb)->daddr, ntohs(dport),
-			      iif, refcounted);
+			      doff, params, refcounted);
 }
 
 struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 			  struct sk_buff *skb, int doff,
-			  const struct in6_addr *saddr, const __be16 sport,
-			  const struct in6_addr *daddr, const __be16 dport,
-			  const int dif);
+			  struct sk_lookup *params);
 
 int inet6_hash(struct sock *sk);
 #endif /* IS_ENABLED(CONFIG_IPV6) */
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index c376af5bfdfb..e92f10a832dd 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -70,6 +70,11 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			u8 type, u8 code, int offset, __be32 info)
 {
 	const struct ipv6hdr *hdr = (const struct ipv6hdr *)skb->data;
+	struct sk_lookup params = {
+		.saddr.ipv6 = &hdr->daddr,
+		.daddr.ipv6 = &hdr->saddr,
+		.dif = inet6_iif(skb),
+	};
 	const struct dccp_hdr *dh;
 	struct dccp_sock *dp;
 	struct ipv6_pinfo *np;
@@ -86,11 +91,10 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	BUILD_BUG_ON(offsetofend(struct dccp_hdr, dccph_dport) > 8);
 	dh = (struct dccp_hdr *)(skb->data + offset);
 
-	sk = __inet6_lookup_established(net, &dccp_hashinfo,
-					&hdr->daddr, dh->dccph_dport,
-					&hdr->saddr, ntohs(dh->dccph_sport),
-					inet6_iif(skb));
-
+	params.sport = dh->dccph_dport;
+	params.dport = dh->dccph_sport;
+	params.hnum = ntohs(dh->dccph_sport);
+	sk = __inet6_lookup_established(net, &dccp_hashinfo, &params);
 	if (!sk) {
 		__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev),
 				  ICMP6_MIB_INERRORS);
@@ -656,6 +660,9 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 static int dccp_v6_rcv(struct sk_buff *skb)
 {
+	struct sk_lookup params = {
+		.dif = inet6_iif(skb),
+	};
 	const struct dccp_hdr *dh;
 	bool refcounted;
 	struct sock *sk;
@@ -683,10 +690,11 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 	else
 		DCCP_SKB_CB(skb)->dccpd_ack_seq = dccp_hdr_ack_seq(skb);
 
+	params.sport = dh->dccph_sport;
+	params.dport = dh->dccph_dport;
 lookup:
 	sk = __inet6_lookup_skb(&dccp_hashinfo, skb, __dccp_hdr_len(dh),
-			        dh->dccph_sport, dh->dccph_dport,
-				inet6_iif(skb), &refcounted);
+				&params, &refcounted);
 	if (!sk) {
 		dccp_pr_debug("failed to look up flow ID in table and "
 			      "get corresponding socket\n");
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 6c3bc4e408d0..c1ec0d3cc4b9 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -422,13 +422,18 @@ struct sock *inet_diag_find_one_icsk(struct net *net,
 			};
 
 			sk = inet_lookup(net, hashinfo, NULL, 0, &params);
-		} else
-			sk = inet6_lookup(net, hashinfo, NULL, 0,
-					  (struct in6_addr *)req->id.idiag_dst,
-					  req->id.idiag_dport,
-					  (struct in6_addr *)req->id.idiag_src,
-					  req->id.idiag_sport,
-					  req->id.idiag_if);
+		} else {
+			struct sk_lookup params = {
+				.saddr.ipv6 = (struct in6_addr *)req->id.idiag_dst,
+				.daddr.ipv6 = (struct in6_addr *)req->id.idiag_src,
+				.sport = req->id.idiag_dport,
+				.dport = req->id.idiag_sport,
+				.hnum  = ntohs(req->id.idiag_sport),
+				.dif   = req->id.idiag_if,
+			};
+
+			sk = inet6_lookup(net, hashinfo, NULL, 0, &params);
+		}
 	}
 #endif
 	else {
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 10738c10c5ae..bd358f9dde1f 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -60,6 +60,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 			.daddr.ipv6 = (struct in6_addr *)req->id.idiag_dst,
 			.sport = req->id.idiag_sport,
 			.dport = req->id.idiag_dport,
+			.hnum  = ntohs(req->id.idiag_dport),
 			.dif   =  req->id.idiag_if,
 		};
 
@@ -221,6 +222,7 @@ static int __udp_diag_destroy(struct sk_buff *in_skb,
 				.daddr.ipv6 = (struct in6_addr *)req->id.idiag_src,
 				.sport = req->id.idiag_dport,
 				.dport = req->id.idiag_sport,
+				.hnum  = ntohs(req->id.idiag_sport),
 				.dif   = req->id.idiag_if,
 			};
 
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index b13b8f93079d..878c03094f2e 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -52,33 +52,35 @@ u32 inet6_ehashfn(const struct net *net,
  */
 struct sock *__inet6_lookup_established(struct net *net,
 					struct inet_hashinfo *hashinfo,
-					   const struct in6_addr *saddr,
-					   const __be16 sport,
-					   const struct in6_addr *daddr,
-					   const u16 hnum,
-					   const int dif)
+					const struct sk_lookup *params)
 {
+	const __portpair ports = INET_COMBINED_PORTS(params->sport,
+						     params->hnum);
+	const struct in6_addr *saddr = params->saddr.ipv6;
+	const struct in6_addr *daddr = params->daddr.ipv6;
 	struct sock *sk;
 	const struct hlist_nulls_node *node;
-	const __portpair ports = INET_COMBINED_PORTS(sport, hnum);
+
 	/* Optimize here for direct hit, only listening connections can
 	 * have wildcards anyways.
 	 */
-	unsigned int hash = inet6_ehashfn(net, daddr, hnum, saddr, sport);
+	unsigned int hash = inet6_ehashfn(net, daddr, params->hnum,
+					  saddr, params->sport);
 	unsigned int slot = hash & hashinfo->ehash_mask;
 	struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
 
-
 begin:
 	sk_nulls_for_each_rcu(sk, node, &head->chain) {
 		if (sk->sk_hash != hash)
 			continue;
-		if (!INET6_MATCH(sk, net, saddr, daddr, ports, dif))
+		if (!INET6_MATCH(sk, net, saddr, daddr, ports,
+				 params->dif))
 			continue;
 		if (unlikely(!refcount_inc_not_zero(&sk->sk_refcnt)))
 			goto out;
 
-		if (unlikely(!INET6_MATCH(sk, net, saddr, daddr, ports, dif))) {
+		if (unlikely(!INET6_MATCH(sk, net, saddr, daddr, ports,
+				 params->dif))) {
 			sock_gen_put(sk);
 			goto begin;
 		}
@@ -94,26 +96,27 @@ struct sock *__inet6_lookup_established(struct net *net,
 EXPORT_SYMBOL(__inet6_lookup_established);
 
 static inline int compute_score(struct sock *sk, struct net *net,
-				const unsigned short hnum,
-				const struct in6_addr *daddr,
-				const int dif, bool exact_dif)
+				const struct sk_lookup *params)
 {
 	int score = -1;
 
-	if (net_eq(sock_net(sk), net) && inet_sk(sk)->inet_num == hnum &&
+	if (net_eq(sock_net(sk), net) &&
+	    inet_sk(sk)->inet_num == params->hnum &&
 	    sk->sk_family == PF_INET6) {
+		int rc;
 
 		score = 1;
 		if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
-			if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, daddr))
+			if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr,
+					     params->daddr.ipv6))
 				return -1;
 			score++;
 		}
-		if (sk->sk_bound_dev_if || exact_dif) {
-			if (sk->sk_bound_dev_if != dif)
-				return -1;
+		rc = sk_lookup_device_cmp(sk, params);
+		if (rc < 0)
+			return -1;
+		if (rc > 0)
 			score++;
-		}
 		if (sk->sk_incoming_cpu == raw_smp_processor_id())
 			score++;
 	}
@@ -122,26 +125,27 @@ static inline int compute_score(struct sock *sk, struct net *net,
 
 /* called with rcu_read_lock() */
 struct sock *inet6_lookup_listener(struct net *net,
-		struct inet_hashinfo *hashinfo,
-		struct sk_buff *skb, int doff,
-		const struct in6_addr *saddr,
-		const __be16 sport, const struct in6_addr *daddr,
-		const unsigned short hnum, const int dif)
+				   struct inet_hashinfo *hashinfo,
+				   struct sk_buff *skb, int doff,
+				   struct sk_lookup *params)
 {
-	unsigned int hash = inet_lhashfn(net, hnum);
+	unsigned int hash = inet_lhashfn(net, params->hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
 	int score, hiscore = 0, matches = 0, reuseport = 0;
-	bool exact_dif = inet6_exact_dif_match(net, skb);
 	struct sock *sk, *result = NULL;
 	u32 phash = 0;
 
+	params->exact_dif = inet6_exact_dif_match(net, skb);
+
 	sk_for_each(sk, &ilb->head) {
-		score = compute_score(sk, net, hnum, daddr, dif, exact_dif);
+		score = compute_score(sk, net, params);
 		if (score > hiscore) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				phash = inet6_ehashfn(net, daddr, hnum,
-						      saddr, sport);
+				phash = inet6_ehashfn(net, params->daddr.ipv6,
+						      params->hnum,
+						      params->saddr.ipv6,
+						      params->sport);
 				result = reuseport_select_sock(sk, phash,
 							       skb, doff);
 				if (result)
@@ -163,15 +167,12 @@ EXPORT_SYMBOL_GPL(inet6_lookup_listener);
 
 struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 			  struct sk_buff *skb, int doff,
-			  const struct in6_addr *saddr, const __be16 sport,
-			  const struct in6_addr *daddr, const __be16 dport,
-			  const int dif)
+			  struct sk_lookup *params)
 {
 	struct sock *sk;
 	bool refcounted;
 
-	sk = __inet6_lookup(net, hashinfo, skb, doff, saddr, sport, daddr,
-			    ntohs(dport), dif, &refcounted);
+	sk = __inet6_lookup(net, hashinfo, skb, doff, params, &refcounted);
 	if (sk && !refcounted && !refcount_inc_not_zero(&sk->sk_refcnt))
 		sk = NULL;
 	return sk;
@@ -203,7 +204,8 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 		if (sk2->sk_hash != hash)
 			continue;
 
-		if (likely(INET6_MATCH(sk2, net, saddr, daddr, ports, dif))) {
+		if (likely(INET6_MATCH(sk2, net, saddr, daddr, ports,
+				       dif))) {
 			if (sk2->sk_state == TCP_TIME_WAIT) {
 				tw = inet_twsk(sk2);
 				if (twsk_unique(sk, sk2, twp))
diff --git a/net/ipv6/netfilter/nf_socket_ipv6.c b/net/ipv6/netfilter/nf_socket_ipv6.c
index c1c193103063..1d815e0933b7 100644
--- a/net/ipv6/netfilter/nf_socket_ipv6.c
+++ b/net/ipv6/netfilter/nf_socket_ipv6.c
@@ -91,14 +91,13 @@ nf_socket_get_sock_v6(struct net *net, struct sk_buff *skb, int doff,
 		.daddr.ipv6 = daddr,
 		.sport = sport,
 		.dport = dport,
+		.hnum  = ntohs(dport),
 		.dif   = in->ifindex,
 	};
 
 	switch (protocol) {
 	case IPPROTO_TCP:
-		return inet6_lookup(net, &tcp_hashinfo, skb, doff,
-				    saddr, sport, daddr, dport,
-				    in->ifindex);
+		return inet6_lookup(net, &tcp_hashinfo, skb, doff, &params);
 	case IPPROTO_UDP:
 		return udp6_lib_lookup(net, &params);
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2968a33cca7d..19fee98e1ae0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -45,6 +45,7 @@
 #include <linux/random.h>
 
 #include <net/tcp.h>
+#include <net/inet_hashtables.h>
 #include <net/ndisc.h>
 #include <net/inet6_hashtables.h>
 #include <net/inet6_connection_sock.h>
@@ -338,6 +339,13 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 {
 	const struct ipv6hdr *hdr = (const struct ipv6hdr *)skb->data;
 	const struct tcphdr *th = (struct tcphdr *)(skb->data+offset);
+	struct sk_lookup params = {
+		.saddr.ipv6 = &hdr->daddr,
+		.daddr.ipv6 = &hdr->saddr,
+		.sport = th->dest,
+		.hnum  = ntohs(th->source),
+		.dif   = skb->dev->ifindex,
+	};
 	struct net *net = dev_net(skb->dev);
 	struct request_sock *fastopen;
 	struct ipv6_pinfo *np;
@@ -347,11 +355,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	bool fatal;
 	int err;
 
-	sk = __inet6_lookup_established(net, &tcp_hashinfo,
-					&hdr->daddr, th->dest,
-					&hdr->saddr, ntohs(th->source),
-					skb->dev->ifindex);
-
+	sk = __inet6_lookup_established(net, &tcp_hashinfo, &params);
 	if (!sk) {
 		__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev),
 				  ICMP6_MIB_INERRORS);
@@ -907,6 +911,14 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 	if (sk && sk_fullsock(sk)) {
 		key = tcp_v6_md5_do_lookup(sk, &ipv6h->saddr);
 	} else if (hash_location) {
+		struct sk_lookup params = {
+			.saddr.ipv6 = &ipv6h->saddr,
+			.daddr.ipv6 = &ipv6h->daddr,
+			.sport = th->source,
+			.hnum = ntohs(th->source),
+			.dif  = tcp_v6_iif(skb),
+		};
+
 		/*
 		 * active side is lost. Try to find listening socket through
 		 * source port, and then find md5 key through listening socket.
@@ -915,10 +927,7 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 		 * no RST generated if md5 hash doesn't match.
 		 */
 		sk1 = inet6_lookup_listener(dev_net(skb_dst(skb)->dev),
-					   &tcp_hashinfo, NULL, 0,
-					   &ipv6h->saddr,
-					   th->source, &ipv6h->daddr,
-					   ntohs(th->source), tcp_v6_iif(skb));
+					   &tcp_hashinfo, NULL, 0, &params);
 		if (!sk1)
 			goto out;
 
@@ -1403,6 +1412,9 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	struct sock *sk;
 	int ret;
 	struct net *net = dev_net(skb->dev);
+	struct sk_lookup params = {
+		.dif = inet6_iif(skb),
+	};
 
 	if (skb->pkt_type != PACKET_HOST)
 		goto discard_it;
@@ -1428,10 +1440,11 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	th = (const struct tcphdr *)skb->data;
 	hdr = ipv6_hdr(skb);
 
+	params.sport = th->source;
+	params.dport = th->dest;
 lookup:
 	sk = __inet6_lookup_skb(&tcp_hashinfo, skb, __tcp_hdrlen(th),
-				th->source, th->dest, inet6_iif(skb),
-				&refcounted);
+				&params, &refcounted);
 	if (!sk)
 		goto no_tcp_socket;
 
@@ -1558,13 +1571,17 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN:
 	{
+		struct sk_lookup params = {
+			.saddr.ipv6 = &ipv6_hdr(skb)->saddr,
+			.daddr.ipv6 = &ipv6_hdr(skb)->daddr,
+			.sport = th->source,
+			.hnum = ntohs(th->dest),
+			.dif  = tcp_v6_iif(skb),
+		};
 		struct sock *sk2;
 
 		sk2 = inet6_lookup_listener(dev_net(skb->dev), &tcp_hashinfo,
-					    skb, __tcp_hdrlen(th),
-					    &ipv6_hdr(skb)->saddr, th->source,
-					    &ipv6_hdr(skb)->daddr,
-					    ntohs(th->dest), tcp_v6_iif(skb));
+					    skb, __tcp_hdrlen(th), &params);
 		if (sk2) {
 			struct inet_timewait_sock *tw = inet_twsk(sk);
 			inet_twsk_deschedule_put(tw);
@@ -1591,6 +1608,10 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 
 static void tcp_v6_early_demux(struct sk_buff *skb)
 {
+	/* Note : We use inet6_iif() here, not tcp_v6_iif() */
+	struct sk_lookup params = {
+		.dif = inet6_iif(skb),
+	};
 	const struct ipv6hdr *hdr;
 	const struct tcphdr *th;
 	struct sock *sk;
@@ -1607,11 +1628,12 @@ static void tcp_v6_early_demux(struct sk_buff *skb)
 	if (th->doff < sizeof(struct tcphdr) / 4)
 		return;
 
-	/* Note : We use inet6_iif() here, not tcp_v6_iif() */
+	params.saddr.ipv6 = &hdr->saddr,
+	params.daddr.ipv6 = &hdr->daddr,
+	params.sport = th->source,
+	params.hnum = ntohs(th->dest),
 	sk = __inet6_lookup_established(dev_net(skb->dev), &tcp_hashinfo,
-					&hdr->saddr, th->source,
-					&hdr->daddr, ntohs(th->dest),
-					inet6_iif(skb));
+					&params);
 	if (sk) {
 		skb->sk = sk;
 		skb->destructor = sock_edemux;
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 56bb40544035..3ee75189d1c3 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -193,6 +193,7 @@ nf_tproxy_get_sock_v6(struct net *net, struct sk_buff *skb, int thoff, void *hp,
 		.daddr.ipv6 = daddr,
 		.sport = sport,
 		.dport = dport,
+		.hnum  = ntohs(dport),
 		.dif   = in->ifindex,
 	};
 	struct sock *sk;
@@ -205,9 +206,7 @@ nf_tproxy_get_sock_v6(struct net *net, struct sk_buff *skb, int thoff, void *hp,
 			tcph = hp;
 			sk = inet6_lookup_listener(net, &tcp_hashinfo, skb,
 						   thoff + __tcp_hdrlen(tcph),
-						   saddr, sport,
-						   daddr, ntohs(dport),
-						   in->ifindex);
+						   &params);
 
 			if (sk && !refcount_inc_not_zero(&sk->sk_refcnt))
 				sk = NULL;
@@ -219,8 +218,7 @@ nf_tproxy_get_sock_v6(struct net *net, struct sk_buff *skb, int thoff, void *hp,
 			break;
 		case NFT_LOOKUP_ESTABLISHED:
 			sk = __inet6_lookup_established(net, &tcp_hashinfo,
-							saddr, sport, daddr, ntohs(dport),
-							in->ifindex);
+							&params);
 			break;
 		default:
 			BUG();
-- 
2.1.4
