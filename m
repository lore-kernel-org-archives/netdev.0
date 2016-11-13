From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 32/39] netfilter: ipset: Make struct htype per ipset family
Date: Sun, 13 Nov 2016 23:25:26 +0100
Message-ID: <1479075933-4491-33-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47656 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965234AbcKMW02 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:26:28 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 3638AC1069
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:27 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1562FDA848
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:27 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 75F61DA85D
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:24 +0100 (CET)
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Before this patch struct htype created at the first source
of ip_set_hash_gen.h and it is common for both IPv4 and IPv6
set variants.

Make struct htype per ipset family and use NLEN to make
nets array fixed size to simplify struct htype allocation.

Ported from a patch proposed by Sergey Popovich <popovich_sergei@mail.ua>.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h        | 51 +++++++++++-----------------
 net/netfilter/ipset/ip_set_hash_ip.c         | 10 +++---
 net/netfilter/ipset/ip_set_hash_ipmark.c     | 10 +++---
 net/netfilter/ipset/ip_set_hash_ipport.c     |  6 ++--
 net/netfilter/ipset/ip_set_hash_ipportip.c   |  6 ++--
 net/netfilter/ipset/ip_set_hash_ipportnet.c  | 10 +++---
 net/netfilter/ipset/ip_set_hash_net.c        |  8 ++---
 net/netfilter/ipset/ip_set_hash_netiface.c   |  8 ++---
 net/netfilter/ipset/ip_set_hash_netnet.c     |  8 ++---
 net/netfilter/ipset/ip_set_hash_netport.c    | 10 +++---
 net/netfilter/ipset/ip_set_hash_netportnet.c | 10 +++---
 11 files changed, 63 insertions(+), 74 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index de1d16fd4121..c600f6d9f15e 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -166,6 +166,18 @@ htable_bits(u32 hashsize)
 
 #endif /* _IP_SET_HASH_GEN_H */
 
+#ifndef MTYPE
+#error "MTYPE is not defined!"
+#endif
+
+#ifndef HTYPE
+#error "HTYPE is not defined!"
+#endif
+
+#ifndef HOST_MASK
+#error "HOST_MASK is not defined!"
+#endif
+
 /* Family dependent templates */
 
 #undef ahash_data
@@ -189,7 +201,6 @@ htable_bits(u32 hashsize)
 #undef mtype_same_set
 #undef mtype_kadt
 #undef mtype_uadt
-#undef mtype
 
 #undef mtype_add
 #undef mtype_del
@@ -205,6 +216,7 @@ htable_bits(u32 hashsize)
 #undef mtype_variant
 #undef mtype_data_match
 
+#undef htype
 #undef HKEY
 
 #define mtype_data_equal	IPSET_TOKEN(MTYPE, _data_equal)
@@ -231,7 +243,6 @@ htable_bits(u32 hashsize)
 #define mtype_same_set		IPSET_TOKEN(MTYPE, _same_set)
 #define mtype_kadt		IPSET_TOKEN(MTYPE, _kadt)
 #define mtype_uadt		IPSET_TOKEN(MTYPE, _uadt)
-#define mtype			MTYPE
 
 #define mtype_add		IPSET_TOKEN(MTYPE, _add)
 #define mtype_del		IPSET_TOKEN(MTYPE, _del)
@@ -247,18 +258,12 @@ htable_bits(u32 hashsize)
 #define mtype_variant		IPSET_TOKEN(MTYPE, _variant)
 #define mtype_data_match	IPSET_TOKEN(MTYPE, _data_match)
 
-#ifndef MTYPE
-#error "MTYPE is not defined!"
-#endif
-
-#ifndef HOST_MASK
-#error "HOST_MASK is not defined!"
-#endif
-
 #ifndef HKEY_DATALEN
 #define HKEY_DATALEN		sizeof(struct mtype_elem)
 #endif
 
+#define htype			MTYPE
+
 #define HKEY(data, initval, htable_bits)			\
 ({								\
 	const u32 *__k = (const u32 *)data;			\
@@ -269,33 +274,26 @@ htable_bits(u32 hashsize)
 	jhash2(__k, __l, initval) & jhash_mask(htable_bits);	\
 })
 
-#ifndef htype
-#ifndef HTYPE
-#error "HTYPE is not defined!"
-#endif /* HTYPE */
-#define htype			HTYPE
-
 /* The generic hash structure */
 struct htype {
 	struct htable __rcu *table; /* the hash table */
+	struct timer_list gc;	/* garbage collection when timeout enabled */
 	u32 maxelem;		/* max elements in the hash */
 	u32 initval;		/* random jhash init value */
 #ifdef IP_SET_HASH_WITH_MARKMASK
 	u32 markmask;		/* markmask value for mark mask to store */
 #endif
-	struct timer_list gc;	/* garbage collection when timeout enabled */
-	struct mtype_elem next; /* temporary storage for uadd */
 #ifdef IP_SET_HASH_WITH_MULTI
 	u8 ahash_max;		/* max elements in an array block */
 #endif
 #ifdef IP_SET_HASH_WITH_NETMASK
 	u8 netmask;		/* netmask value for subnets to store */
 #endif
+	struct mtype_elem next; /* temporary storage for uadd */
 #ifdef IP_SET_HASH_WITH_NETS
-	struct net_prefixes nets[0]; /* book-keeping of prefixes */
+	struct net_prefixes nets[NLEN]; /* book-keeping of prefixes */
 #endif
 };
-#endif /* htype */
 
 #ifdef IP_SET_HASH_WITH_NETS
 /* Network cidr size book keeping when the hash stores different
@@ -348,13 +346,7 @@ mtype_del_cidr(struct htype *h, u8 cidr, u8 n)
 static size_t
 mtype_ahash_memsize(const struct htype *h, const struct htable *t)
 {
-	size_t memsize = sizeof(*h) + sizeof(*t);
-
-#ifdef IP_SET_HASH_WITH_NETS
-	memsize += sizeof(struct net_prefixes) * NLEN;
-#endif
-
-	return memsize;
+	return sizeof(*h) + sizeof(*t);
 }
 
 /* Get the ith element from the array block n */
@@ -392,7 +384,7 @@ mtype_flush(struct ip_set *set)
 		kfree_rcu(n, rcu);
 	}
 #ifdef IP_SET_HASH_WITH_NETS
-	memset(h->nets, 0, sizeof(struct net_prefixes) * NLEN);
+	memset(h->nets, 0, sizeof(h->nets));
 #endif
 	set->elements = 0;
 	set->ext_size = 0;
@@ -1290,9 +1282,6 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 		maxelem = ip_set_get_h32(tb[IPSET_ATTR_MAXELEM]);
 
 	hsize = sizeof(*h);
-#ifdef IP_SET_HASH_WITH_NETS
-	hsize += sizeof(struct net_prefixes) * NLEN;
-#endif
 	h = kzalloc(hsize, GFP_KERNEL);
 	if (!h)
 		return -ENOMEM;
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 9d6bf19f7b78..20bfbd315f61 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -82,7 +82,7 @@ hash_ip4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	      const struct xt_action_param *par,
 	      enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_ip *h = set->data;
+	const struct hash_ip4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ip4_elem e = { 0 };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
@@ -101,7 +101,7 @@ static int
 hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	      enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_ip *h = set->data;
+	const struct hash_ip4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ip4_elem e = { 0 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -199,7 +199,7 @@ hash_ip6_data_list(struct sk_buff *skb, const struct hash_ip6_elem *e)
 }
 
 static inline void
-hash_ip6_data_next(struct hash_ip4_elem *next, const struct hash_ip6_elem *e)
+hash_ip6_data_next(struct hash_ip6_elem *next, const struct hash_ip6_elem *e)
 {
 }
 
@@ -217,7 +217,7 @@ hash_ip6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	      const struct xt_action_param *par,
 	      enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_ip *h = set->data;
+	const struct hash_ip6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ip6_elem e = { { .all = { 0 } } };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
@@ -234,7 +234,7 @@ static int
 hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	      enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_ip *h = set->data;
+	const struct hash_ip6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ip6_elem e = { { .all = { 0 } } };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index a0695a2ab585..b64cf14e8352 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -85,7 +85,7 @@ hash_ipmark4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
 		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_ipmark *h = set->data;
+	const struct hash_ipmark4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipmark4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
@@ -101,7 +101,7 @@ static int
 hash_ipmark4_uadt(struct ip_set *set, struct nlattr *tb[],
 		  enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_ipmark *h = set->data;
+	const struct hash_ipmark4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipmark4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -193,7 +193,7 @@ hash_ipmark6_data_list(struct sk_buff *skb,
 }
 
 static inline void
-hash_ipmark6_data_next(struct hash_ipmark4_elem *next,
+hash_ipmark6_data_next(struct hash_ipmark6_elem *next,
 		       const struct hash_ipmark6_elem *d)
 {
 }
@@ -211,7 +211,7 @@ hash_ipmark6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
 		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_ipmark *h = set->data;
+	const struct hash_ipmark6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipmark6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
@@ -227,7 +227,7 @@ static int
 hash_ipmark6_uadt(struct ip_set *set, struct nlattr *tb[],
 		  enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_ipmark *h = set->data;
+	const struct hash_ipmark6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipmark6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 9d84b3dff603..f438740e6c6a 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -108,7 +108,7 @@ static int
 hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		  enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_ipport *h = set->data;
+	const struct hash_ipport4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipport4_elem e = { .ip = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -231,7 +231,7 @@ hash_ipport6_data_list(struct sk_buff *skb,
 }
 
 static inline void
-hash_ipport6_data_next(struct hash_ipport4_elem *next,
+hash_ipport6_data_next(struct hash_ipport6_elem *next,
 		       const struct hash_ipport6_elem *d)
 {
 	next->port = d->port;
@@ -266,7 +266,7 @@ static int
 hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		  enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_ipport *h = set->data;
+	const struct hash_ipport6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipport6_elem e = { .ip = { .all = { 0 } } };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 215b7b942038..6215fb898c50 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -111,7 +111,7 @@ static int
 hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 		    enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_ipportip *h = set->data;
+	const struct hash_ipportip4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportip4_elem e = { .ip = 0 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -241,7 +241,7 @@ hash_ipportip6_data_list(struct sk_buff *skb,
 }
 
 static inline void
-hash_ipportip6_data_next(struct hash_ipportip4_elem *next,
+hash_ipportip6_data_next(struct hash_ipportip6_elem *next,
 			 const struct hash_ipportip6_elem *d)
 {
 	next->port = d->port;
@@ -277,7 +277,7 @@ static int
 hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 		    enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_ipportip *h = set->data;
+	const struct hash_ipportip6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportip6_elem e = {  .ip = { .all = { 0 } } };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 9ca719625ea3..5ab1b99a53c2 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -138,7 +138,7 @@ hash_ipportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		     const struct xt_action_param *par,
 		     enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_ipportnet *h = set->data;
+	const struct hash_ipportnet4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet4_elem e = {
 		.cidr = INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
@@ -163,7 +163,7 @@ static int
 hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_ipportnet *h = set->data;
+	const struct hash_ipportnet4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet4_elem e = { .cidr = HOST_MASK - 1 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -370,7 +370,7 @@ hash_ipportnet6_data_list(struct sk_buff *skb,
 }
 
 static inline void
-hash_ipportnet6_data_next(struct hash_ipportnet4_elem *next,
+hash_ipportnet6_data_next(struct hash_ipportnet6_elem *next,
 			  const struct hash_ipportnet6_elem *d)
 {
 	next->port = d->port;
@@ -389,7 +389,7 @@ hash_ipportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		     const struct xt_action_param *par,
 		     enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_ipportnet *h = set->data;
+	const struct hash_ipportnet6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet6_elem e = {
 		.cidr = INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
@@ -414,7 +414,7 @@ static int
 hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_ipportnet *h = set->data;
+	const struct hash_ipportnet6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet6_elem e = { .cidr = HOST_MASK - 1 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 3e4bffdc1cc0..5d9e895452e7 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -117,7 +117,7 @@ hash_net4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	       const struct xt_action_param *par,
 	       enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_net *h = set->data;
+	const struct hash_net4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_net4_elem e = {
 		.cidr = INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
@@ -139,7 +139,7 @@ static int
 hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	       enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_net *h = set->data;
+	const struct hash_net4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_net4_elem e = { .cidr = HOST_MASK };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -268,7 +268,7 @@ hash_net6_data_list(struct sk_buff *skb, const struct hash_net6_elem *data)
 }
 
 static inline void
-hash_net6_data_next(struct hash_net4_elem *next,
+hash_net6_data_next(struct hash_net6_elem *next,
 		    const struct hash_net6_elem *d)
 {
 }
@@ -286,7 +286,7 @@ hash_net6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	       const struct xt_action_param *par,
 	       enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_net *h = set->data;
+	const struct hash_net6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_net6_elem e = {
 		.cidr = INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index aa1a776613b9..44cf11939c91 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -156,7 +156,7 @@ hash_netiface4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		    const struct xt_action_param *par,
 		    enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	struct hash_netiface *h = set->data;
+	struct hash_netiface4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netiface4_elem e = {
 		.cidr = INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
@@ -196,7 +196,7 @@ static int
 hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 		    enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	struct hash_netiface *h = set->data;
+	struct hash_netiface4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netiface4_elem e = { .cidr = HOST_MASK, .elem = 1 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -348,7 +348,7 @@ hash_netiface6_data_list(struct sk_buff *skb,
 }
 
 static inline void
-hash_netiface6_data_next(struct hash_netiface4_elem *next,
+hash_netiface6_data_next(struct hash_netiface6_elem *next,
 			 const struct hash_netiface6_elem *d)
 {
 }
@@ -367,7 +367,7 @@ hash_netiface6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		    const struct xt_action_param *par,
 		    enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	struct hash_netiface *h = set->data;
+	struct hash_netiface6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netiface6_elem e = {
 		.cidr = INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index a93dfebffa81..db614e13b193 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -143,7 +143,7 @@ hash_netnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
 		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_netnet *h = set->data;
+	const struct hash_netnet4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netnet4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
@@ -165,7 +165,7 @@ static int
 hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		  enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_netnet *h = set->data;
+	const struct hash_netnet4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netnet4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -352,7 +352,7 @@ hash_netnet6_data_list(struct sk_buff *skb,
 }
 
 static inline void
-hash_netnet6_data_next(struct hash_netnet4_elem *next,
+hash_netnet6_data_next(struct hash_netnet6_elem *next,
 		       const struct hash_netnet6_elem *d)
 {
 }
@@ -377,7 +377,7 @@ hash_netnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
 		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_netnet *h = set->data;
+	const struct hash_netnet6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netnet6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 731813e0f08c..54b64b6cd0cd 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -133,7 +133,7 @@ hash_netport4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		   const struct xt_action_param *par,
 		   enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_netport *h = set->data;
+	const struct hash_netport4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport4_elem e = {
 		.cidr = INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
@@ -157,7 +157,7 @@ static int
 hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		   enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_netport *h = set->data;
+	const struct hash_netport4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport4_elem e = { .cidr = HOST_MASK - 1 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -329,7 +329,7 @@ hash_netport6_data_list(struct sk_buff *skb,
 }
 
 static inline void
-hash_netport6_data_next(struct hash_netport4_elem *next,
+hash_netport6_data_next(struct hash_netport6_elem *next,
 			const struct hash_netport6_elem *d)
 {
 	next->port = d->port;
@@ -348,7 +348,7 @@ hash_netport6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		   const struct xt_action_param *par,
 		   enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_netport *h = set->data;
+	const struct hash_netport6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport6_elem e = {
 		.cidr = INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
@@ -372,7 +372,7 @@ static int
 hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		   enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_netport *h = set->data;
+	const struct hash_netport6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport6_elem e = { .cidr = HOST_MASK  - 1 };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index 9a14c237830f..aff846960ac4 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -154,7 +154,7 @@ hash_netportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		      const struct xt_action_param *par,
 		      enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_netportnet *h = set->data;
+	const struct hash_netportnet4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netportnet4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
@@ -180,7 +180,7 @@ static int
 hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		      enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_netportnet *h = set->data;
+	const struct hash_netportnet4 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netportnet4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -406,7 +406,7 @@ hash_netportnet6_data_list(struct sk_buff *skb,
 }
 
 static inline void
-hash_netportnet6_data_next(struct hash_netportnet4_elem *next,
+hash_netportnet6_data_next(struct hash_netportnet6_elem *next,
 			   const struct hash_netportnet6_elem *d)
 {
 	next->port = d->port;
@@ -432,7 +432,7 @@ hash_netportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		      const struct xt_action_param *par,
 		      enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_netportnet *h = set->data;
+	const struct hash_netportnet6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netportnet6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
@@ -458,7 +458,7 @@ static int
 hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		      enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_netportnet *h = set->data;
+	const struct hash_netportnet6 *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netportnet6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
-- 
2.1.4
