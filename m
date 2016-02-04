From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 4/7] inet: refactor inet[6]_lookup functions to take skb
Date: Thu,  4 Feb 2016 10:35:15 -0500
Message-ID: <1454600118-30152-5-git-send-email-kraigatgoog@gmail.com>
References: <1454600118-30152-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:36537 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756600AbcBDPf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 10:35:29 -0500
Received: by mail-qk0-f179.google.com with SMTP id s68so22190862qkh.3
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 07:35:27 -0800 (PST)
In-Reply-To: <1454600118-30152-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This is a preliminary step to allow fast socket lookup of SO_REUSEPORT
groups.  Doing so with a BPF filter will require access to the
skb in question.  This change plumbs the skb (and offset to payload
data) through the call stack to the listening socket lookup
implementations where it will be used in a following patch.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/net/addrconf.h         |  2 ++
 include/net/inet6_hashtables.h | 11 +++++++----
 include/net/inet_hashtables.h  | 18 ++++++++++++------
 net/ipv4/inet_diag.c           |  6 +++---
 net/ipv4/inet_hashtables.c     |  1 +
 net/ipv4/tcp_ipv4.c            | 10 ++++++----
 net/ipv6/inet6_hashtables.c    |  8 ++++++--
 net/ipv6/tcp_ipv6.c            |  8 +++++---
 net/netfilter/xt_TPROXY.c      | 31 ++++++++++++++++++++-----------
 net/netfilter/xt_socket.c      | 28 +++++++++++++++++++++-------
 10 files changed, 83 insertions(+), 40 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 47f52d3cd8df..730d856683e5 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -87,6 +87,8 @@ int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
 		      u32 banned_flags);
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
 		    u32 banned_flags);
+int ipv4_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
+			 bool match_wildcard);
 int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
 			 bool match_wildcard);
 void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr);
diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index b3c28a9dfbf1..28332bdac333 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -53,6 +53,7 @@ struct sock *__inet6_lookup_established(struct net *net,
 
 struct sock *inet6_lookup_listener(struct net *net,
 				   struct inet_hashinfo *hashinfo,
+				   struct sk_buff *skb, int doff,
 				   const struct in6_addr *saddr,
 				   const __be16 sport,
 				   const struct in6_addr *daddr,
@@ -60,6 +61,7 @@ struct sock *inet6_lookup_listener(struct net *net,
 
 static inline struct sock *__inet6_lookup(struct net *net,
 					  struct inet_hashinfo *hashinfo,
+					  struct sk_buff *skb, int doff,
 					  const struct in6_addr *saddr,
 					  const __be16 sport,
 					  const struct in6_addr *daddr,
@@ -71,12 +73,12 @@ static inline struct sock *__inet6_lookup(struct net *net,
 	if (sk)
 		return sk;
 
-	return inet6_lookup_listener(net, hashinfo, saddr, sport,
+	return inet6_lookup_listener(net, hashinfo, skb, doff, saddr, sport,
 				     daddr, hnum, dif);
 }
 
 static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
-					      struct sk_buff *skb,
+					      struct sk_buff *skb, int doff,
 					      const __be16 sport,
 					      const __be16 dport,
 					      int iif)
@@ -86,13 +88,14 @@ static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
 	if (sk)
 		return sk;
 
-	return __inet6_lookup(dev_net(skb_dst(skb)->dev), hashinfo,
-			      &ipv6_hdr(skb)->saddr, sport,
+	return __inet6_lookup(dev_net(skb_dst(skb)->dev), hashinfo, skb,
+			      doff, &ipv6_hdr(skb)->saddr, sport,
 			      &ipv6_hdr(skb)->daddr, ntohs(dport),
 			      iif);
 }
 
 struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
+			  struct sk_buff *skb, int doff,
 			  const struct in6_addr *saddr, const __be16 sport,
 			  const struct in6_addr *daddr, const __be16 dport,
 			  const int dif);
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 554440e7f83d..82403390af58 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -213,6 +213,7 @@ void inet_unhash(struct sock *sk);
 
 struct sock *__inet_lookup_listener(struct net *net,
 				    struct inet_hashinfo *hashinfo,
+				    struct sk_buff *skb, int doff,
 				    const __be32 saddr, const __be16 sport,
 				    const __be32 daddr,
 				    const unsigned short hnum,
@@ -220,10 +221,11 @@ struct sock *__inet_lookup_listener(struct net *net,
 
 static inline struct sock *inet_lookup_listener(struct net *net,
 		struct inet_hashinfo *hashinfo,
+		struct sk_buff *skb, int doff,
 		__be32 saddr, __be16 sport,
 		__be32 daddr, __be16 dport, int dif)
 {
-	return __inet_lookup_listener(net, hashinfo, saddr, sport,
+	return __inet_lookup_listener(net, hashinfo, skb, doff, saddr, sport,
 				      daddr, ntohs(dport), dif);
 }
 
@@ -299,6 +301,7 @@ static inline struct sock *
 
 static inline struct sock *__inet_lookup(struct net *net,
 					 struct inet_hashinfo *hashinfo,
+					 struct sk_buff *skb, int doff,
 					 const __be32 saddr, const __be16 sport,
 					 const __be32 daddr, const __be16 dport,
 					 const int dif)
@@ -307,12 +310,13 @@ static inline struct sock *__inet_lookup(struct net *net,
 	struct sock *sk = __inet_lookup_established(net, hashinfo,
 				saddr, sport, daddr, hnum, dif);
 
-	return sk ? : __inet_lookup_listener(net, hashinfo, saddr, sport,
-					     daddr, hnum, dif);
+	return sk ? : __inet_lookup_listener(net, hashinfo, skb, doff, saddr,
+					     sport, daddr, hnum, dif);
 }
 
 static inline struct sock *inet_lookup(struct net *net,
 				       struct inet_hashinfo *hashinfo,
+				       struct sk_buff *skb, int doff,
 				       const __be32 saddr, const __be16 sport,
 				       const __be32 daddr, const __be16 dport,
 				       const int dif)
@@ -320,7 +324,8 @@ static inline struct sock *inet_lookup(struct net *net,
 	struct sock *sk;
 
 	local_bh_disable();
-	sk = __inet_lookup(net, hashinfo, saddr, sport, daddr, dport, dif);
+	sk = __inet_lookup(net, hashinfo, skb, doff, saddr, sport, daddr,
+			   dport, dif);
 	local_bh_enable();
 
 	return sk;
@@ -328,6 +333,7 @@ static inline struct sock *inet_lookup(struct net *net,
 
 static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 					     struct sk_buff *skb,
+					     int doff,
 					     const __be16 sport,
 					     const __be16 dport)
 {
@@ -337,8 +343,8 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 	if (sk)
 		return sk;
 	else
-		return __inet_lookup(dev_net(skb_dst(skb)->dev), hashinfo,
-				     iph->saddr, sport,
+		return __inet_lookup(dev_net(skb_dst(skb)->dev), hashinfo, skb,
+				     doff, iph->saddr, sport,
 				     iph->daddr, dport, inet_iif(skb));
 }
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 6029157a19ed..50c0d96b8441 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -357,18 +357,18 @@ struct sock *inet_diag_find_one_icsk(struct net *net,
 	struct sock *sk;
 
 	if (req->sdiag_family == AF_INET)
-		sk = inet_lookup(net, hashinfo, req->id.idiag_dst[0],
+		sk = inet_lookup(net, hashinfo, NULL, 0, req->id.idiag_dst[0],
 				 req->id.idiag_dport, req->id.idiag_src[0],
 				 req->id.idiag_sport, req->id.idiag_if);
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (req->sdiag_family == AF_INET6) {
 		if (ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_dst) &&
 		    ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_src))
-			sk = inet_lookup(net, hashinfo, req->id.idiag_dst[3],
+			sk = inet_lookup(net, hashinfo, NULL, 0, req->id.idiag_dst[3],
 					 req->id.idiag_dport, req->id.idiag_src[3],
 					 req->id.idiag_sport, req->id.idiag_if);
 		else
-			sk = inet6_lookup(net, hashinfo,
+			sk = inet6_lookup(net, hashinfo, NULL, 0,
 					  (struct in6_addr *)req->id.idiag_dst,
 					  req->id.idiag_dport,
 					  (struct in6_addr *)req->id.idiag_src,
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index b6023b7baae0..5e4290b83255 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -205,6 +205,7 @@ static inline int compute_score(struct sock *sk, struct net *net,
 
 struct sock *__inet_lookup_listener(struct net *net,
 				    struct inet_hashinfo *hashinfo,
+				    struct sk_buff *skb, int doff,
 				    const __be32 saddr, __be16 sport,
 				    const __be32 daddr, const unsigned short hnum,
 				    const int dif)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a4d523709ab3..d9c52b8fe9de 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -637,8 +637,8 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 		 * Incoming packet is checked with md5 hash with finding key,
 		 * no RST generated if md5 hash doesn't match.
 		 */
-		sk1 = __inet_lookup_listener(net,
-					     &tcp_hashinfo, ip_hdr(skb)->saddr,
+		sk1 = __inet_lookup_listener(net, &tcp_hashinfo, NULL, 0,
+					     ip_hdr(skb)->saddr,
 					     th->source, ip_hdr(skb)->daddr,
 					     ntohs(th->source), inet_iif(skb));
 		/* don't send rst if it can't find key */
@@ -1582,7 +1582,8 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
 lookup:
-	sk = __inet_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
+	sk = __inet_lookup_skb(&tcp_hashinfo, skb, __tcp_hdrlen(th), th->source,
+			       th->dest);
 	if (!sk)
 		goto no_tcp_socket;
 
@@ -1696,7 +1697,8 @@ do_time_wait:
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN: {
 		struct sock *sk2 = inet_lookup_listener(dev_net(skb->dev),
-							&tcp_hashinfo,
+							&tcp_hashinfo, skb,
+							__tcp_hdrlen(th),
 							iph->saddr, th->source,
 							iph->daddr, th->dest,
 							inet_iif(skb));
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 3521b15b8b85..19913e9e09e0 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -121,7 +121,9 @@ static inline int compute_score(struct sock *sk, struct net *net,
 }
 
 struct sock *inet6_lookup_listener(struct net *net,
-		struct inet_hashinfo *hashinfo, const struct in6_addr *saddr,
+		struct inet_hashinfo *hashinfo,
+		struct sk_buff *skb, int doff,
+		const struct in6_addr *saddr,
 		const __be16 sport, const struct in6_addr *daddr,
 		const unsigned short hnum, const int dif)
 {
@@ -177,6 +179,7 @@ begin:
 EXPORT_SYMBOL_GPL(inet6_lookup_listener);
 
 struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
+			  struct sk_buff *skb, int doff,
 			  const struct in6_addr *saddr, const __be16 sport,
 			  const struct in6_addr *daddr, const __be16 dport,
 			  const int dif)
@@ -184,7 +187,8 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 	struct sock *sk;
 
 	local_bh_disable();
-	sk = __inet6_lookup(net, hashinfo, saddr, sport, daddr, ntohs(dport), dif);
+	sk = __inet6_lookup(net, hashinfo, skb, doff, saddr, sport, daddr,
+			    ntohs(dport), dif);
 	local_bh_enable();
 
 	return sk;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d72bcfb326d8..9977b6f19f2a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -866,7 +866,8 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 		 * no RST generated if md5 hash doesn't match.
 		 */
 		sk1 = inet6_lookup_listener(dev_net(skb_dst(skb)->dev),
-					   &tcp_hashinfo, &ipv6h->saddr,
+					   &tcp_hashinfo, NULL, 0,
+					   &ipv6h->saddr,
 					   th->source, &ipv6h->daddr,
 					   ntohs(th->source), tcp_v6_iif(skb));
 		if (!sk1)
@@ -1375,8 +1376,8 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	hdr = ipv6_hdr(skb);
 
 lookup:
-	sk = __inet6_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest,
-				inet6_iif(skb));
+	sk = __inet6_lookup_skb(&tcp_hashinfo, skb, __tcp_hdrlen(th),
+				th->source, th->dest, inet6_iif(skb));
 	if (!sk)
 		goto no_tcp_socket;
 
@@ -1500,6 +1501,7 @@ do_time_wait:
 		struct sock *sk2;
 
 		sk2 = inet6_lookup_listener(dev_net(skb->dev), &tcp_hashinfo,
+					    skb, __tcp_hdrlen(th),
 					    &ipv6_hdr(skb)->saddr, th->source,
 					    &ipv6_hdr(skb)->daddr,
 					    ntohs(th->dest), tcp_v6_iif(skb));
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 3ab591e73ec0..7f4414d26a66 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -105,19 +105,24 @@ tproxy_laddr4(struct sk_buff *skb, __be32 user_laddr, __be32 daddr)
  * belonging to established connections going through that one.
  */
 static inline struct sock *
-nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
+nf_tproxy_get_sock_v4(struct net *net, struct sk_buff *skb, void *hp,
+		      const u8 protocol,
 		      const __be32 saddr, const __be32 daddr,
 		      const __be16 sport, const __be16 dport,
 		      const struct net_device *in,
 		      const enum nf_tproxy_lookup_t lookup_type)
 {
 	struct sock *sk;
+	struct tcphdr *tcph;
 
 	switch (protocol) {
 	case IPPROTO_TCP:
 		switch (lookup_type) {
 		case NFT_LOOKUP_LISTENER:
-			sk = inet_lookup_listener(net, &tcp_hashinfo,
+			tcph = hp;
+			sk = inet_lookup_listener(net, &tcp_hashinfo, skb,
+						    ip_hdrlen(skb) +
+						      __tcp_hdrlen(tcph),
 						    saddr, sport,
 						    daddr, dport,
 						    in->ifindex);
@@ -169,19 +174,23 @@ nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
 
 #ifdef XT_TPROXY_HAVE_IPV6
 static inline struct sock *
-nf_tproxy_get_sock_v6(struct net *net, const u8 protocol,
+nf_tproxy_get_sock_v6(struct net *net, struct sk_buff *skb, int thoff, void *hp,
+		      const u8 protocol,
 		      const struct in6_addr *saddr, const struct in6_addr *daddr,
 		      const __be16 sport, const __be16 dport,
 		      const struct net_device *in,
 		      const enum nf_tproxy_lookup_t lookup_type)
 {
 	struct sock *sk;
+	struct tcphdr *tcph;
 
 	switch (protocol) {
 	case IPPROTO_TCP:
 		switch (lookup_type) {
 		case NFT_LOOKUP_LISTENER:
-			sk = inet6_lookup_listener(net, &tcp_hashinfo,
+			tcph = hp;
+			sk = inet6_lookup_listener(net, &tcp_hashinfo, skb,
+						   thoff + __tcp_hdrlen(tcph),
 						   saddr, sport,
 						   daddr, ntohs(dport),
 						   in->ifindex);
@@ -267,7 +276,7 @@ tproxy_handle_time_wait4(struct net *net, struct sk_buff *skb,
 		 * to a listener socket if there's one */
 		struct sock *sk2;
 
-		sk2 = nf_tproxy_get_sock_v4(net, iph->protocol,
+		sk2 = nf_tproxy_get_sock_v4(net, skb, hp, iph->protocol,
 					    iph->saddr, laddr ? laddr : iph->daddr,
 					    hp->source, lport ? lport : hp->dest,
 					    skb->dev, NFT_LOOKUP_LISTENER);
@@ -305,7 +314,7 @@ tproxy_tg4(struct net *net, struct sk_buff *skb, __be32 laddr, __be16 lport,
 	 * addresses, this happens if the redirect already happened
 	 * and the current packet belongs to an already established
 	 * connection */
-	sk = nf_tproxy_get_sock_v4(net, iph->protocol,
+	sk = nf_tproxy_get_sock_v4(net, skb, hp, iph->protocol,
 				   iph->saddr, iph->daddr,
 				   hp->source, hp->dest,
 				   skb->dev, NFT_LOOKUP_ESTABLISHED);
@@ -321,7 +330,7 @@ tproxy_tg4(struct net *net, struct sk_buff *skb, __be32 laddr, __be16 lport,
 	else if (!sk)
 		/* no, there's no established connection, check if
 		 * there's a listener on the redirected addr/port */
-		sk = nf_tproxy_get_sock_v4(net, iph->protocol,
+		sk = nf_tproxy_get_sock_v4(net, skb, hp, iph->protocol,
 					   iph->saddr, laddr,
 					   hp->source, lport,
 					   skb->dev, NFT_LOOKUP_LISTENER);
@@ -429,7 +438,7 @@ tproxy_handle_time_wait6(struct sk_buff *skb, int tproto, int thoff,
 		 * to a listener socket if there's one */
 		struct sock *sk2;
 
-		sk2 = nf_tproxy_get_sock_v6(par->net, tproto,
+		sk2 = nf_tproxy_get_sock_v6(par->net, skb, thoff, hp, tproto,
 					    &iph->saddr,
 					    tproxy_laddr6(skb, &tgi->laddr.in6, &iph->daddr),
 					    hp->source,
@@ -472,7 +481,7 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 	 * addresses, this happens if the redirect already happened
 	 * and the current packet belongs to an already established
 	 * connection */
-	sk = nf_tproxy_get_sock_v6(par->net, tproto,
+	sk = nf_tproxy_get_sock_v6(par->net, skb, thoff, hp, tproto,
 				   &iph->saddr, &iph->daddr,
 				   hp->source, hp->dest,
 				   par->in, NFT_LOOKUP_ESTABLISHED);
@@ -487,8 +496,8 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 	else if (!sk)
 		/* no there's no established connection, check if
 		 * there's a listener on the redirected addr/port */
-		sk = nf_tproxy_get_sock_v6(par->net, tproto,
-					   &iph->saddr, laddr,
+		sk = nf_tproxy_get_sock_v6(par->net, skb, thoff, hp,
+					   tproto, &iph->saddr, laddr,
 					   hp->source, lport,
 					   par->in, NFT_LOOKUP_LISTENER);
 
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 2ec08f04b816..49d14ecad444 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -112,14 +112,15 @@ extract_icmp4_fields(const struct sk_buff *skb,
  *     box.
  */
 static struct sock *
-xt_socket_get_sock_v4(struct net *net, const u8 protocol,
+xt_socket_get_sock_v4(struct net *net, struct sk_buff *skb, const int doff,
+		      const u8 protocol,
 		      const __be32 saddr, const __be32 daddr,
 		      const __be16 sport, const __be16 dport,
 		      const struct net_device *in)
 {
 	switch (protocol) {
 	case IPPROTO_TCP:
-		return __inet_lookup(net, &tcp_hashinfo,
+		return __inet_lookup(net, &tcp_hashinfo, skb, doff,
 				     saddr, sport, daddr, dport,
 				     in->ifindex);
 	case IPPROTO_UDP:
@@ -148,6 +149,8 @@ static struct sock *xt_socket_lookup_slow_v4(struct net *net,
 					     const struct net_device *indev)
 {
 	const struct iphdr *iph = ip_hdr(skb);
+	struct sk_buff *data_skb = NULL;
+	int doff = 0;
 	__be32 uninitialized_var(daddr), uninitialized_var(saddr);
 	__be16 uninitialized_var(dport), uninitialized_var(sport);
 	u8 uninitialized_var(protocol);
@@ -169,6 +172,10 @@ static struct sock *xt_socket_lookup_slow_v4(struct net *net,
 		sport = hp->source;
 		daddr = iph->daddr;
 		dport = hp->dest;
+		data_skb = (struct sk_buff *)skb;
+		doff = iph->protocol == IPPROTO_TCP ?
+			ip_hdrlen(skb) + __tcp_hdrlen((struct tcphdr *)hp) :
+			ip_hdrlen(skb) + sizeof(*hp);
 
 	} else if (iph->protocol == IPPROTO_ICMP) {
 		if (extract_icmp4_fields(skb, &protocol, &saddr, &daddr,
@@ -198,8 +205,8 @@ static struct sock *xt_socket_lookup_slow_v4(struct net *net,
 	}
 #endif
 
-	return xt_socket_get_sock_v4(net, protocol, saddr, daddr,
-				     sport, dport, indev);
+	return xt_socket_get_sock_v4(net, data_skb, doff, protocol, saddr,
+				     daddr, sport, dport, indev);
 }
 
 static bool
@@ -318,14 +325,15 @@ extract_icmp6_fields(const struct sk_buff *skb,
 }
 
 static struct sock *
-xt_socket_get_sock_v6(struct net *net, const u8 protocol,
+xt_socket_get_sock_v6(struct net *net, struct sk_buff *skb, int doff,
+		      const u8 protocol,
 		      const struct in6_addr *saddr, const struct in6_addr *daddr,
 		      const __be16 sport, const __be16 dport,
 		      const struct net_device *in)
 {
 	switch (protocol) {
 	case IPPROTO_TCP:
-		return inet6_lookup(net, &tcp_hashinfo,
+		return inet6_lookup(net, &tcp_hashinfo, skb, doff,
 				    saddr, sport, daddr, dport,
 				    in->ifindex);
 	case IPPROTO_UDP:
@@ -343,6 +351,8 @@ static struct sock *xt_socket_lookup_slow_v6(struct net *net,
 	__be16 uninitialized_var(dport), uninitialized_var(sport);
 	const struct in6_addr *daddr = NULL, *saddr = NULL;
 	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct sk_buff *data_skb = NULL;
+	int doff = 0;
 	int thoff = 0, tproto;
 
 	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
@@ -362,6 +372,10 @@ static struct sock *xt_socket_lookup_slow_v6(struct net *net,
 		sport = hp->source;
 		daddr = &iph->daddr;
 		dport = hp->dest;
+		data_skb = (struct sk_buff *)skb;
+		doff = tproto == IPPROTO_TCP ?
+			thoff + __tcp_hdrlen((struct tcphdr *)hp) :
+			thoff + sizeof(*hp);
 
 	} else if (tproto == IPPROTO_ICMPV6) {
 		struct ipv6hdr ipv6_var;
@@ -373,7 +387,7 @@ static struct sock *xt_socket_lookup_slow_v6(struct net *net,
 		return NULL;
 	}
 
-	return xt_socket_get_sock_v6(net, tproto, saddr, daddr,
+	return xt_socket_get_sock_v6(net, data_skb, doff, tproto, saddr, daddr,
 				     sport, dport, indev);
 }
 
-- 
2.7.0.rc3.207.g0ac5344
