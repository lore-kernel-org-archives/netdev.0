From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 2/6] udp: Constify skb argument in lookup functions
Date: Tue, 29 Aug 2017 10:19:38 -0700
Message-ID: <20170829171942.8974-3-tom@quantonium.net>
References: <20170829171942.8974-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35110 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751242AbdH2RUO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 13:20:14 -0400
Received: by mail-pf0-f179.google.com with SMTP id g13so12041251pfm.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 10:20:14 -0700 (PDT)
In-Reply-To: <20170829171942.8974-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For UDP socket lookup functions, and associateed functions that take an
skbuf as argument, declare the skb argument as constant.

One caveat is that reuseport_select_sock can be called from the UDP
lookup functions with an skb argument. This function temporarily
modifies the skbuff data pointer (in bpf_run via a pull/push sequence).
To resolve compiler warning I added a local skbuf declaration that is
not const and assigned to the skb argument with an explicit cast.
---
 include/net/ip.h             |  2 +-
 include/net/sock_reuseport.h |  2 +-
 include/net/udp.h            | 11 ++++++-----
 net/core/sock_reuseport.c    |  5 +++--
 net/ipv4/udp.c               | 11 ++++++-----
 net/ipv6/udp.c               | 10 +++++-----
 6 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 9896f46cbbf1..8c0d84ffc659 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -79,7 +79,7 @@ struct ipcm_cookie {
 #define PKTINFO_SKB_CB(skb) ((struct in_pktinfo *)((skb)->cb))
 
 /* return enslaved device index if relevant */
-static inline int inet_sdif(struct sk_buff *skb)
+static inline int inet_sdif(const struct sk_buff *skb)
 {
 #if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
 	if (skb && ipv4_l3mdev_skb(IPCB(skb)->flags))
diff --git a/include/net/sock_reuseport.h b/include/net/sock_reuseport.h
index aecd30308d50..d25352a848d9 100644
--- a/include/net/sock_reuseport.h
+++ b/include/net/sock_reuseport.h
@@ -20,7 +20,7 @@ extern int reuseport_add_sock(struct sock *sk, struct sock *sk2);
 extern void reuseport_detach_sock(struct sock *sk);
 extern struct sock *reuseport_select_sock(struct sock *sk,
 					  u32 hash,
-					  struct sk_buff *skb,
+					  const struct sk_buff *skb,
 					  int hdr_len);
 extern struct bpf_prog *reuseport_attach_prog(struct sock *sk,
 					      struct bpf_prog *prog);
diff --git a/include/net/udp.h b/include/net/udp.h
index 4e5f23fec35e..f3d1de6f0983 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -167,7 +167,7 @@ static inline void udp_csum_pull_header(struct sk_buff *skb)
 	UDP_SKB_CB(skb)->cscov -= sizeof(struct udphdr);
 }
 
-typedef struct sock *(*udp_lookup_t)(struct sk_buff *skb, __be16 sport,
+typedef struct sock *(*udp_lookup_t)(const struct sk_buff *skb, __be16 sport,
 				     __be16 dport);
 
 struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
@@ -288,8 +288,9 @@ struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif);
 struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			       __be32 daddr, __be16 dport, int dif, int sdif,
-			       struct udp_table *tbl, struct sk_buff *skb);
-struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
+			       struct udp_table *tbl,
+			       const struct sk_buff *skb);
+struct sock *udp4_lib_lookup_skb(const struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
 struct sock *udp6_lib_lookup(struct net *net,
 			     const struct in6_addr *saddr, __be16 sport,
@@ -299,8 +300,8 @@ struct sock *__udp6_lib_lookup(struct net *net,
 			       const struct in6_addr *saddr, __be16 sport,
 			       const struct in6_addr *daddr, __be16 dport,
 			       int dif, int sdif, struct udp_table *tbl,
-			       struct sk_buff *skb);
-struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
+			       const struct sk_buff *skb);
+struct sock *udp6_lib_lookup_skb(const struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
 
 /* UDP uses skb->dev_scratch to cache as much information as possible and avoid
diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
index eed1ebf7f29d..a17f13b33189 100644
--- a/net/core/sock_reuseport.c
+++ b/net/core/sock_reuseport.c
@@ -164,9 +164,10 @@ void reuseport_detach_sock(struct sock *sk)
 EXPORT_SYMBOL(reuseport_detach_sock);
 
 static struct sock *run_bpf(struct sock_reuseport *reuse, u16 socks,
-			    struct bpf_prog *prog, struct sk_buff *skb,
+			    struct bpf_prog *prog, const struct sk_buff *_skb,
 			    int hdr_len)
 {
+	struct sk_buff *skb = (struct sk_buff *)_skb; /* Override const */
 	struct sk_buff *nskb = NULL;
 	u32 index;
 
@@ -205,7 +206,7 @@ static struct sock *run_bpf(struct sock_reuseport *reuse, u16 socks,
  */
 struct sock *reuseport_select_sock(struct sock *sk,
 				   u32 hash,
-				   struct sk_buff *skb,
+				   const struct sk_buff *skb,
 				   int hdr_len)
 {
 	struct sock_reuseport *reuse;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index bf6c406bf5e7..a851026ef28b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -135,7 +135,8 @@ EXPORT_SYMBOL(udp_memory_allocated);
 #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
 
 /* IPCB reference means this can not be used from early demux */
-static bool udp_lib_exact_dif_match(struct net *net, struct sk_buff *skb)
+static bool udp_lib_exact_dif_match(struct net *net,
+				    const struct sk_buff *skb)
 {
 #if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
 	if (!net->ipv4.sysctl_udp_l3mdev_accept &&
@@ -445,7 +446,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 				     __be32 daddr, unsigned int hnum,
 				     int dif, int sdif, bool exact_dif,
 				     struct udp_hslot *hslot2,
-				     struct sk_buff *skb)
+				     const struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	int score, badness, matches = 0, reuseport = 0;
@@ -484,7 +485,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
  */
 struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 		__be16 sport, __be32 daddr, __be16 dport, int dif,
-		int sdif, struct udp_table *udptable, struct sk_buff *skb)
+		int sdif, struct udp_table *udptable, const struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	unsigned short hnum = ntohs(dport);
@@ -552,7 +553,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 }
 EXPORT_SYMBOL_GPL(__udp4_lib_lookup);
 
-static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
+static inline struct sock *__udp4_lib_lookup_skb(const struct sk_buff *skb,
 						 __be16 sport, __be16 dport,
 						 struct udp_table *udptable)
 {
@@ -563,7 +564,7 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 				 inet_sdif(skb), udptable, skb);
 }
 
-struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
+struct sock *udp4_lib_lookup_skb(const struct sk_buff *skb,
 				 __be16 sport, __be16 dport)
 {
 	return __udp4_lib_lookup_skb(skb, sport, dport, &udp_table);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 976f30391356..e9aa4db3ba53 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -56,7 +56,7 @@
 #include <trace/events/skb.h>
 #include "udp_impl.h"
 
-static bool udp6_lib_exact_dif_match(struct net *net, struct sk_buff *skb)
+static bool udp6_lib_exact_dif_match(struct net *net, const struct sk_buff *skb)
 {
 #if defined(CONFIG_NET_L3_MASTER_DEV)
 	if (!net->ipv4.sysctl_udp_l3mdev_accept &&
@@ -181,7 +181,7 @@ static struct sock *udp6_lib_lookup2(struct net *net,
 		const struct in6_addr *saddr, __be16 sport,
 		const struct in6_addr *daddr, unsigned int hnum,
 		int dif, int sdif, bool exact_dif,
-		struct udp_hslot *hslot2, struct sk_buff *skb)
+		struct udp_hslot *hslot2, const struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	int score, badness, matches = 0, reuseport = 0;
@@ -221,7 +221,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 			       const struct in6_addr *saddr, __be16 sport,
 			       const struct in6_addr *daddr, __be16 dport,
 			       int dif, int sdif, struct udp_table *udptable,
-			       struct sk_buff *skb)
+			       const struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	unsigned short hnum = ntohs(dport);
@@ -290,7 +290,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 }
 EXPORT_SYMBOL_GPL(__udp6_lib_lookup);
 
-static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
+static struct sock *__udp6_lib_lookup_skb(const struct sk_buff *skb,
 					  __be16 sport, __be16 dport,
 					  struct udp_table *udptable)
 {
@@ -301,7 +301,7 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 				 inet6_sdif(skb), udptable, skb);
 }
 
-struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
+struct sock *udp6_lib_lookup_skb(const struct sk_buff *skb,
 				 __be16 sport, __be16 dport)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
-- 
2.11.0
