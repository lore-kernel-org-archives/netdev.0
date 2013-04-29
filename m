From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/18] netfilter: ipset: Hash types using the unified code base
Date: Mon, 29 Apr 2013 20:22:13 +0200
Message-ID: <1367259744-8922-8-git-send-email-pablo@netfilter.org>
References: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41419 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758670Ab3D2SWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 14:22:50 -0400
In-Reply-To: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_ip.c        |  306 +++++---------------
 net/netfilter/ipset/ip_set_hash_ipport.c    |  320 +++++----------------
 net/netfilter/ipset/ip_set_hash_ipportip.c  |  322 +++++----------------
 net/netfilter/ipset/ip_set_hash_ipportnet.c |  399 +++++++-------------------
 net/netfilter/ipset/ip_set_hash_net.c       |  340 ++++++-----------------
 net/netfilter/ipset/ip_set_hash_netiface.c  |  400 +++++++--------------------
 net/netfilter/ipset/ip_set_hash_netport.c   |  388 +++++++-------------------
 7 files changed, 610 insertions(+), 1865 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index c486ad2..2fcfb21 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+/* Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -21,7 +21,6 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/ipset/pfxlen.h>
 #include <linux/netfilter/ipset/ip_set.h>
-#include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define REVISION_MIN	0
@@ -33,58 +32,36 @@ IP_SET_MODULE_DESC("hash:ip", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:ip");
 
 /* Type specific function prefix */
-#define TYPE		hash_ip
-
-static bool
-hash_ip_same_set(const struct ip_set *a, const struct ip_set *b);
-
-#define hash_ip4_same_set	hash_ip_same_set
-#define hash_ip6_same_set	hash_ip_same_set
+#define HTYPE		hash_ip
+#define IP_SET_HASH_WITH_NETMASK
 
-/* The type variant functions: IPv4 */
+/* IPv4 variants */
 
-/* Member elements without timeout */
+/* Member elements */
 struct hash_ip4_elem {
+	/* Zero valued IP addresses cannot be stored */
 	__be32 ip;
 };
 
-/* Member elements with timeout support */
-struct hash_ip4_telem {
+struct hash_ip4t_elem {
 	__be32 ip;
 	unsigned long timeout;
 };
 
-static inline bool
-hash_ip4_data_equal(const struct hash_ip4_elem *ip1,
-		    const struct hash_ip4_elem *ip2,
-		    u32 *multi)
-{
-	return ip1->ip == ip2->ip;
-}
+/* Common functions */
 
 static inline bool
-hash_ip4_data_isnull(const struct hash_ip4_elem *elem)
-{
-	return elem->ip == 0;
-}
-
-static inline void
-hash_ip4_data_copy(struct hash_ip4_elem *dst, const struct hash_ip4_elem *src)
-{
-	dst->ip = src->ip;
-}
-
-/* Zero valued IP addresses cannot be stored */
-static inline void
-hash_ip4_data_zero_out(struct hash_ip4_elem *elem)
+hash_ip4_data_equal(const struct hash_ip4_elem *e1,
+		    const struct hash_ip4_elem *e2,
+		    u32 *multi)
 {
-	elem->ip = 0;
+	return e1->ip == e2->ip;
 }
 
 static inline bool
-hash_ip4_data_list(struct sk_buff *skb, const struct hash_ip4_elem *data)
+hash_ip4_data_list(struct sk_buff *skb, const struct hash_ip4_elem *e)
 {
-	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip))
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, e->ip))
 		goto nla_put_failure;
 	return 0;
 
@@ -92,41 +69,26 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_ip4_data_tlist(struct sk_buff *skb, const struct hash_ip4_elem *data)
+static inline void
+hash_ip4_data_next(struct hash_ip4_elem *next, const struct hash_ip4_elem *e)
 {
-	const struct hash_ip4_telem *tdata =
-		(const struct hash_ip4_telem *)data;
-
-	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(tdata->timeout))))
-		goto nla_put_failure;
-
-	return 0;
-
-nla_put_failure:
-	return 1;
+	next->ip = e->ip;
 }
 
-#define IP_SET_HASH_WITH_NETMASK
+#define MTYPE		hash_ip4
 #define PF		4
 #define HOST_MASK	32
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_ip4_data_next(struct ip_set_hash *h, const struct hash_ip4_elem *d)
-{
-	h->next.ip = d->ip;
-}
+#include "ip_set_hash_gen.h"
 
 static int
 hash_ip4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	      const struct xt_action_param *par,
-	      enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+	      enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct hash_ip4_elem e = {};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 	__be32 ip;
 
 	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &ip);
@@ -134,17 +96,19 @@ hash_ip4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	if (ip == 0)
 		return -EINVAL;
 
-	return adtfn(set, &ip, opt_timeout(opt, h), opt->cmdflags);
+	e.ip = ip;
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	      enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	u32 ip, ip_to, hosts, timeout = h->timeout;
-	__be32 nip;
+	struct hash_ip4_elem e = {};
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	u32 ip, ip_to, hosts;
 	int ret = 0;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -154,23 +118,18 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
 	ip &= ip_set_hostmask(h->netmask);
 
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
-
 	if (adt == IPSET_TEST) {
-		nip = htonl(ip);
-		if (nip == 0)
+		e.ip = htonl(ip);
+		if (e.ip == 0)
 			return -IPSET_ERR_HASH_ELEM;
-		return adtfn(set, &nip, timeout, flags);
+		return adtfn(set, &e, &ext, &ext, flags);
 	}
 
 	ip_to = ip;
@@ -193,10 +152,10 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (retried)
 		ip = ntohl(h->next.ip);
 	for (; !before(ip_to, ip); ip += hosts) {
-		nip = htonl(ip);
-		if (nip == 0)
+		e.ip = htonl(ip);
+		if (e.ip == 0)
 			return -IPSET_ERR_HASH_ELEM;
-		ret = adtfn(set, &nip, timeout, flags);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 
 		if (ret && !ip_set_eexist(ret, flags))
 			return ret;
@@ -206,29 +165,20 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-static bool
-hash_ip_same_set(const struct ip_set *a, const struct ip_set *b)
-{
-	const struct ip_set_hash *x = a->data;
-	const struct ip_set_hash *y = b->data;
-
-	/* Resizing changes htable_bits, so we ignore it */
-	return x->maxelem == y->maxelem &&
-	       x->timeout == y->timeout &&
-	       x->netmask == y->netmask;
-}
-
-/* The type variant functions: IPv6 */
+/* IPv6 variants */
 
+/* Member elements */
 struct hash_ip6_elem {
 	union nf_inet_addr ip;
 };
 
-struct hash_ip6_telem {
+struct hash_ip6t_elem {
 	union nf_inet_addr ip;
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_ip6_data_equal(const struct hash_ip6_elem *ip1,
 		    const struct hash_ip6_elem *ip2,
@@ -237,28 +187,16 @@ hash_ip6_data_equal(const struct hash_ip6_elem *ip1,
 	return ipv6_addr_equal(&ip1->ip.in6, &ip2->ip.in6);
 }
 
-static inline bool
-hash_ip6_data_isnull(const struct hash_ip6_elem *elem)
-{
-	return ipv6_addr_any(&elem->ip.in6);
-}
-
 static inline void
-hash_ip6_data_copy(struct hash_ip6_elem *dst, const struct hash_ip6_elem *src)
+hash_ip6_netmask(union nf_inet_addr *ip, u8 prefix)
 {
-	dst->ip.in6 = src->ip.in6;
-}
-
-static inline void
-hash_ip6_data_zero_out(struct hash_ip6_elem *elem)
-{
-	ipv6_addr_set(&elem->ip.in6, 0, 0, 0, 0);
+	ip6_netmask(ip, prefix);
 }
 
 static bool
-hash_ip6_data_list(struct sk_buff *skb, const struct hash_ip6_elem *data)
+hash_ip6_data_list(struct sk_buff *skb, const struct hash_ip6_elem *e)
 {
-	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &data->ip.in6))
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6))
 		goto nla_put_failure;
 	return 0;
 
@@ -266,65 +204,49 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_ip6_data_tlist(struct sk_buff *skb, const struct hash_ip6_elem *data)
+static inline void
+hash_ip6_data_next(struct hash_ip4_elem *next, const struct hash_ip6_elem *e)
 {
-	const struct hash_ip6_telem *e =
-		(const struct hash_ip6_telem *)data;
-
-	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(e->timeout))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
 }
 
+#undef MTYPE
 #undef PF
 #undef HOST_MASK
+#undef HKEY_DATALEN
 
+#define MTYPE		hash_ip6
 #define PF		6
 #define HOST_MASK	128
-#include <linux/netfilter/ipset/ip_set_ahash.h>
 
-static inline void
-hash_ip6_data_next(struct ip_set_hash *h, const struct hash_ip6_elem *d)
-{
-}
+#define IP_SET_EMIT_CREATE
+#include "ip_set_hash_gen.h"
 
 static int
 hash_ip6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	      const struct xt_action_param *par,
-	      enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+	      enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	union nf_inet_addr ip;
+	struct hash_ip6_elem e = {};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
-	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &ip.in6);
-	ip6_netmask(&ip, h->netmask);
-	if (ipv6_addr_any(&ip.in6))
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip.in6);
+	hash_ip6_netmask(&e.ip, h->netmask);
+	if (ipv6_addr_any(&e.ip.in6))
 		return -EINVAL;
 
-	return adtfn(set, &ip, opt_timeout(opt, h), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
-static const struct nla_policy hash_ip6_adt_policy[IPSET_ATTR_ADT_MAX + 1] = {
-	[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
-	[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
-	[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
-};
-
 static int
 hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	      enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	union nf_inet_addr ip;
-	u32 timeout = h->timeout;
+	struct hash_ip6_elem e = {};
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -336,110 +258,20 @@ hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &ip);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
-	ip6_netmask(&ip, h->netmask);
-	if (ipv6_addr_any(&ip.in6))
+	hash_ip6_netmask(&e.ip, h->netmask);
+	if (ipv6_addr_any(&e.ip.in6))
 		return -IPSET_ERR_HASH_ELEM;
 
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
-
-	ret = adtfn(set, &ip, timeout, flags);
+	ret = adtfn(set, &e, &ext, &ext, flags);
 
 	return ip_set_eexist(ret, flags) ? 0 : ret;
 }
 
-/* Create hash:ip type of sets */
-
-static int
-hash_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
-{
-	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
-	u8 netmask, hbits;
-	size_t hsize;
-	struct ip_set_hash *h;
-
-	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
-		return -IPSET_ERR_INVALID_FAMILY;
-	netmask = set->family == NFPROTO_IPV4 ? 32 : 128;
-	pr_debug("Create set %s with family %s\n",
-		 set->name, set->family == NFPROTO_IPV4 ? "inet" : "inet6");
-
-	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_MAXELEM) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
-		return -IPSET_ERR_PROTOCOL;
-
-	if (tb[IPSET_ATTR_HASHSIZE]) {
-		hashsize = ip_set_get_h32(tb[IPSET_ATTR_HASHSIZE]);
-		if (hashsize < IPSET_MIMINAL_HASHSIZE)
-			hashsize = IPSET_MIMINAL_HASHSIZE;
-	}
-
-	if (tb[IPSET_ATTR_MAXELEM])
-		maxelem = ip_set_get_h32(tb[IPSET_ATTR_MAXELEM]);
-
-	if (tb[IPSET_ATTR_NETMASK]) {
-		netmask = nla_get_u8(tb[IPSET_ATTR_NETMASK]);
-
-		if ((set->family == NFPROTO_IPV4 && netmask > 32) ||
-		    (set->family == NFPROTO_IPV6 && netmask > 128) ||
-		    netmask == 0)
-			return -IPSET_ERR_INVALID_NETMASK;
-	}
-
-	h = kzalloc(sizeof(*h), GFP_KERNEL);
-	if (!h)
-		return -ENOMEM;
-
-	h->maxelem = maxelem;
-	h->netmask = netmask;
-	get_random_bytes(&h->initval, sizeof(h->initval));
-	h->timeout = IPSET_NO_TIMEOUT;
-
-	hbits = htable_bits(hashsize);
-	hsize = htable_size(hbits);
-	if (hsize == 0) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table = ip_set_alloc(hsize);
-	if (!h->table) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table->htable_bits = hbits;
-
-	set->data = h;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_ip4_tvariant : &hash_ip6_tvariant;
-
-		if (set->family == NFPROTO_IPV4)
-			hash_ip4_gc_init(set);
-		else
-			hash_ip6_gc_init(set);
-	} else {
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_ip4_variant : &hash_ip6_variant;
-	}
-
-	pr_debug("create %s hashsize %u (%u) maxelem %u: %p(%p)\n",
-		 set->name, jhash_size(h->table->htable_bits),
-		 h->table->htable_bits, h->maxelem, set->data, h->table);
-
-	return 0;
-}
-
 static struct ip_set_type hash_ip_type __read_mostly = {
 	.name		= "hash:ip",
 	.protocol	= IPSET_PROTOCOL,
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index d8f77ba..d89cf41 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+/* Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -21,7 +21,6 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/ipset/pfxlen.h>
 #include <linux/netfilter/ipset/ip_set.h>
-#include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_getport.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
@@ -34,17 +33,11 @@ IP_SET_MODULE_DESC("hash:ip,port", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:ip,port");
 
 /* Type specific function prefix */
-#define TYPE		hash_ipport
+#define HTYPE		hash_ipport
 
-static bool
-hash_ipport_same_set(const struct ip_set *a, const struct ip_set *b);
-
-#define hash_ipport4_same_set	hash_ipport_same_set
-#define hash_ipport6_same_set	hash_ipport_same_set
-
-/* The type variant functions: IPv4 */
+/* IPv4 variants */
 
-/* Member elements without timeout */
+/* Member elements */
 struct hash_ipport4_elem {
 	__be32 ip;
 	__be16 port;
@@ -52,8 +45,7 @@ struct hash_ipport4_elem {
 	u8 padding;
 };
 
-/* Member elements with timeout support */
-struct hash_ipport4_telem {
+struct hash_ipport4t_elem {
 	__be32 ip;
 	__be16 port;
 	u8 proto;
@@ -61,6 +53,8 @@ struct hash_ipport4_telem {
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_ipport4_data_equal(const struct hash_ipport4_elem *ip1,
 			const struct hash_ipport4_elem *ip2,
@@ -71,27 +65,6 @@ hash_ipport4_data_equal(const struct hash_ipport4_elem *ip1,
 	       ip1->proto == ip2->proto;
 }
 
-static inline bool
-hash_ipport4_data_isnull(const struct hash_ipport4_elem *elem)
-{
-	return elem->proto == 0;
-}
-
-static inline void
-hash_ipport4_data_copy(struct hash_ipport4_elem *dst,
-		       const struct hash_ipport4_elem *src)
-{
-	dst->ip = src->ip;
-	dst->port = src->port;
-	dst->proto = src->proto;
-}
-
-static inline void
-hash_ipport4_data_zero_out(struct hash_ipport4_elem *elem)
-{
-	elem->proto = 0;
-}
-
 static bool
 hash_ipport4_data_list(struct sk_buff *skb,
 		       const struct hash_ipport4_elem *data)
@@ -106,64 +79,47 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_ipport4_data_tlist(struct sk_buff *skb,
-			const struct hash_ipport4_elem *data)
-{
-	const struct hash_ipport4_telem *tdata =
-		(const struct hash_ipport4_telem *)data;
-
-	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
-	    nla_put_net16(skb, IPSET_ATTR_PORT, tdata->port) ||
-	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(tdata->timeout))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
-}
-
-#define PF		4
-#define HOST_MASK	32
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
 static inline void
-hash_ipport4_data_next(struct ip_set_hash *h,
+hash_ipport4_data_next(struct hash_ipport4_elem *next,
 		       const struct hash_ipport4_elem *d)
 {
-	h->next.ip = d->ip;
-	h->next.port = d->port;
+	next->ip = d->ip;
+	next->port = d->port;
 }
 
+#define MTYPE           hash_ipport4
+#define PF              4
+#define HOST_MASK       32
+#define HKEY_DATALEN	sizeof(struct hash_ipport4_elem)
+#include "ip_set_hash_gen.h"
+
 static int
 hash_ipport4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
-		  enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipport4_elem data = { };
+	struct hash_ipport4_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
 	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
-				 &data.port, &data.proto))
+				 &e.port, &e.proto))
 		return -EINVAL;
 
-	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
-
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		  enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipport4_elem data = { };
+	struct hash_ipport4_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	u32 ip, ip_to, p = 0, port, port_to;
-	u32 timeout = h->timeout;
 	bool with_ports = false;
 	int ret;
 
@@ -176,41 +132,36 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &data.ip);
+	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
 	if (tb[IPSET_ATTR_PORT])
-		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
+		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 	else
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_PROTO]) {
-		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
-		with_ports = ip_set_proto_with_ports(data.proto);
+		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(e.proto);
 
-		if (data.proto == 0)
+		if (e.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	if (!(with_ports || data.proto == IPPROTO_ICMP))
-		data.port = 0;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+	if (!(with_ports || e.proto == IPPROTO_ICMP))
+		e.port = 0;
 
 	if (adt == IPSET_TEST ||
 	    !(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_CIDR] ||
 	      tb[IPSET_ATTR_PORT_TO])) {
-		ret = adtfn(set, &data, timeout, flags);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
-	ip_to = ip = ntohl(data.ip);
+	ip_to = ip = ntohl(e.ip);
 	if (tb[IPSET_ATTR_IP_TO]) {
 		ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP_TO], &ip_to);
 		if (ret)
@@ -225,7 +176,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	}
 
-	port_to = port = ntohs(data.port);
+	port_to = port = ntohs(e.port);
 	if (with_ports && tb[IPSET_ATTR_PORT_TO]) {
 		port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 		if (port > port_to)
@@ -238,9 +189,9 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		p = retried && ip == ntohl(h->next.ip) ? ntohs(h->next.port)
 						       : port;
 		for (; p <= port_to; p++) {
-			data.ip = htonl(ip);
-			data.port = htons(p);
-			ret = adtfn(set, &data, timeout, flags);
+			e.ip = htonl(ip);
+			e.port = htons(p);
+			ret = adtfn(set, &e, &ext, &ext, flags);
 
 			if (ret && !ip_set_eexist(ret, flags))
 				return ret;
@@ -251,18 +202,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-static bool
-hash_ipport_same_set(const struct ip_set *a, const struct ip_set *b)
-{
-	const struct ip_set_hash *x = a->data;
-	const struct ip_set_hash *y = b->data;
-
-	/* Resizing changes htable_bits, so we ignore it */
-	return x->maxelem == y->maxelem &&
-	       x->timeout == y->timeout;
-}
-
-/* The type variant functions: IPv6 */
+/* IPv6 variants */
 
 struct hash_ipport6_elem {
 	union nf_inet_addr ip;
@@ -271,7 +211,7 @@ struct hash_ipport6_elem {
 	u8 padding;
 };
 
-struct hash_ipport6_telem {
+struct hash_ipport6t_elem {
 	union nf_inet_addr ip;
 	__be16 port;
 	u8 proto;
@@ -279,6 +219,8 @@ struct hash_ipport6_telem {
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_ipport6_data_equal(const struct hash_ipport6_elem *ip1,
 			const struct hash_ipport6_elem *ip2,
@@ -289,25 +231,6 @@ hash_ipport6_data_equal(const struct hash_ipport6_elem *ip1,
 	       ip1->proto == ip2->proto;
 }
 
-static inline bool
-hash_ipport6_data_isnull(const struct hash_ipport6_elem *elem)
-{
-	return elem->proto == 0;
-}
-
-static inline void
-hash_ipport6_data_copy(struct hash_ipport6_elem *dst,
-		       const struct hash_ipport6_elem *src)
-{
-	memcpy(dst, src, sizeof(*dst));
-}
-
-static inline void
-hash_ipport6_data_zero_out(struct hash_ipport6_elem *elem)
-{
-	elem->proto = 0;
-}
-
 static bool
 hash_ipport6_data_list(struct sk_buff *skb,
 		       const struct hash_ipport6_elem *data)
@@ -322,66 +245,52 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_ipport6_data_tlist(struct sk_buff *skb,
-			const struct hash_ipport6_elem *data)
+static inline void
+hash_ipport6_data_next(struct hash_ipport4_elem *next,
+		       const struct hash_ipport6_elem *d)
 {
-	const struct hash_ipport6_telem *e =
-		(const struct hash_ipport6_telem *)data;
-
-	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
-	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
-	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(e->timeout))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
+	next->port = d->port;
 }
 
+#undef MTYPE
 #undef PF
 #undef HOST_MASK
+#undef HKEY_DATALEN
 
+#define MTYPE		hash_ipport6
 #define PF		6
 #define HOST_MASK	128
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_ipport6_data_next(struct ip_set_hash *h,
-		       const struct hash_ipport6_elem *d)
-{
-	h->next.port = d->port;
-}
+#define HKEY_DATALEN	sizeof(struct hash_ipport6_elem)
+#define	IP_SET_EMIT_CREATE
+#include "ip_set_hash_gen.h"
 
 static int
 hash_ipport6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
-		  enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipport6_elem data = { };
+	struct hash_ipport6_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
 	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
-				 &data.port, &data.proto))
+				 &e.port, &e.proto))
 		return -EINVAL;
 
-	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
-
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip.in6);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		  enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipport6_elem data = { };
+	struct hash_ipport6_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	u32 port, port_to;
-	u32 timeout = h->timeout;
 	bool with_ports = false;
 	int ret;
 
@@ -396,39 +305,34 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &data.ip);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
 	if (tb[IPSET_ATTR_PORT])
-		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
+		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 	else
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_PROTO]) {
-		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
-		with_ports = ip_set_proto_with_ports(data.proto);
+		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(e.proto);
 
-		if (data.proto == 0)
+		if (e.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	if (!(with_ports || data.proto == IPPROTO_ICMPV6))
-		data.port = 0;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+	if (!(with_ports || e.proto == IPPROTO_ICMPV6))
+		e.port = 0;
 
 	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
-		ret = adtfn(set, &data, timeout, flags);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
-	port = ntohs(data.port);
+	port = ntohs(e.port);
 	port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 	if (port > port_to)
 		swap(port, port_to);
@@ -436,8 +340,8 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (retried)
 		port = ntohs(h->next.port);
 	for (; port <= port_to; port++) {
-		data.port = htons(port);
-		ret = adtfn(set, &data, timeout, flags);
+		e.port = htons(port);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 
 		if (ret && !ip_set_eexist(ret, flags))
 			return ret;
@@ -447,78 +351,6 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-/* Create hash:ip type of sets */
-
-static int
-hash_ipport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
-{
-	struct ip_set_hash *h;
-	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
-	u8 hbits;
-	size_t hsize;
-
-	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
-		return -IPSET_ERR_INVALID_FAMILY;
-
-	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_MAXELEM) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
-		return -IPSET_ERR_PROTOCOL;
-
-	if (tb[IPSET_ATTR_HASHSIZE]) {
-		hashsize = ip_set_get_h32(tb[IPSET_ATTR_HASHSIZE]);
-		if (hashsize < IPSET_MIMINAL_HASHSIZE)
-			hashsize = IPSET_MIMINAL_HASHSIZE;
-	}
-
-	if (tb[IPSET_ATTR_MAXELEM])
-		maxelem = ip_set_get_h32(tb[IPSET_ATTR_MAXELEM]);
-
-	h = kzalloc(sizeof(*h), GFP_KERNEL);
-	if (!h)
-		return -ENOMEM;
-
-	h->maxelem = maxelem;
-	get_random_bytes(&h->initval, sizeof(h->initval));
-	h->timeout = IPSET_NO_TIMEOUT;
-
-	hbits = htable_bits(hashsize);
-	hsize = htable_size(hbits);
-	if (hsize == 0) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table = ip_set_alloc(hsize);
-	if (!h->table) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table->htable_bits = hbits;
-
-	set->data = h;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_ipport4_tvariant : &hash_ipport6_tvariant;
-
-		if (set->family == NFPROTO_IPV4)
-			hash_ipport4_gc_init(set);
-		else
-			hash_ipport6_gc_init(set);
-	} else {
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_ipport4_variant : &hash_ipport6_variant;
-	}
-
-	pr_debug("create %s hashsize %u (%u) maxelem %u: %p(%p)\n",
-		 set->name, jhash_size(h->table->htable_bits),
-		 h->table->htable_bits, h->maxelem, set->data, h->table);
-
-	return 0;
-}
-
 static struct ip_set_type hash_ipport_type __read_mostly = {
 	.name		= "hash:ip,port",
 	.protocol	= IPSET_PROTOCOL,
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 1da1e95..4b58e5c 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+/* Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -21,7 +21,6 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/ipset/pfxlen.h>
 #include <linux/netfilter/ipset/ip_set.h>
-#include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_getport.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
@@ -34,17 +33,11 @@ IP_SET_MODULE_DESC("hash:ip,port,ip", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:ip,port,ip");
 
 /* Type specific function prefix */
-#define TYPE		hash_ipportip
+#define HTYPE		hash_ipportip
 
-static bool
-hash_ipportip_same_set(const struct ip_set *a, const struct ip_set *b);
-
-#define hash_ipportip4_same_set	hash_ipportip_same_set
-#define hash_ipportip6_same_set	hash_ipportip_same_set
-
-/* The type variant functions: IPv4 */
+/* IPv4 variants */
 
-/* Member elements without timeout */
+/* Member elements  */
 struct hash_ipportip4_elem {
 	__be32 ip;
 	__be32 ip2;
@@ -53,8 +46,7 @@ struct hash_ipportip4_elem {
 	u8 padding;
 };
 
-/* Member elements with timeout support */
-struct hash_ipportip4_telem {
+struct hash_ipportip4t_elem {
 	__be32 ip;
 	__be32 ip2;
 	__be16 port;
@@ -74,25 +66,6 @@ hash_ipportip4_data_equal(const struct hash_ipportip4_elem *ip1,
 	       ip1->proto == ip2->proto;
 }
 
-static inline bool
-hash_ipportip4_data_isnull(const struct hash_ipportip4_elem *elem)
-{
-	return elem->proto == 0;
-}
-
-static inline void
-hash_ipportip4_data_copy(struct hash_ipportip4_elem *dst,
-			 const struct hash_ipportip4_elem *src)
-{
-	memcpy(dst, src, sizeof(*dst));
-}
-
-static inline void
-hash_ipportip4_data_zero_out(struct hash_ipportip4_elem *elem)
-{
-	elem->proto = 0;
-}
-
 static bool
 hash_ipportip4_data_list(struct sk_buff *skb,
 		       const struct hash_ipportip4_elem *data)
@@ -108,66 +81,48 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_ipportip4_data_tlist(struct sk_buff *skb,
-			const struct hash_ipportip4_elem *data)
+static inline void
+hash_ipportip4_data_next(struct hash_ipportip4_elem *next,
+			 const struct hash_ipportip4_elem *d)
 {
-	const struct hash_ipportip4_telem *tdata =
-		(const struct hash_ipportip4_telem *)data;
-
-	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
-	    nla_put_ipaddr4(skb, IPSET_ATTR_IP2, tdata->ip2) ||
-	    nla_put_net16(skb, IPSET_ATTR_PORT, tdata->port) ||
-	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(tdata->timeout))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
+	next->ip = d->ip;
+	next->port = d->port;
 }
 
+/* Common functions */
+#define MTYPE		hash_ipportip4
 #define PF		4
 #define HOST_MASK	32
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_ipportip4_data_next(struct ip_set_hash *h,
-			 const struct hash_ipportip4_elem *d)
-{
-	h->next.ip = d->ip;
-	h->next.port = d->port;
-}
+#include "ip_set_hash_gen.h"
 
 static int
 hash_ipportip4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		    const struct xt_action_param *par,
-		    enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		    enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipportip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportip4_elem data = { };
+	struct hash_ipportip4_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
 	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
-				 &data.port, &data.proto))
+				 &e.port, &e.proto))
 		return -EINVAL;
 
-	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
-	ip4addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &data.ip2);
-
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &e.ip2);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 		    enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipportip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportip4_elem data = { };
+	struct hash_ipportip4_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	u32 ip, ip_to, p = 0, port, port_to;
-	u32 timeout = h->timeout;
 	bool with_ports = false;
 	int ret;
 
@@ -180,45 +135,40 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &data.ip);
+	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
-	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP2], &data.ip2);
+	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP2], &e.ip2);
 	if (ret)
 		return ret;
 
 	if (tb[IPSET_ATTR_PORT])
-		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
+		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 	else
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_PROTO]) {
-		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
-		with_ports = ip_set_proto_with_ports(data.proto);
+		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(e.proto);
 
-		if (data.proto == 0)
+		if (e.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	if (!(with_ports || data.proto == IPPROTO_ICMP))
-		data.port = 0;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+	if (!(with_ports || e.proto == IPPROTO_ICMP))
+		e.port = 0;
 
 	if (adt == IPSET_TEST ||
 	    !(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_CIDR] ||
 	      tb[IPSET_ATTR_PORT_TO])) {
-		ret = adtfn(set, &data, timeout, flags);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
-	ip_to = ip = ntohl(data.ip);
+	ip_to = ip = ntohl(e.ip);
 	if (tb[IPSET_ATTR_IP_TO]) {
 		ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP_TO], &ip_to);
 		if (ret)
@@ -233,7 +183,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	}
 
-	port_to = port = ntohs(data.port);
+	port_to = port = ntohs(e.port);
 	if (with_ports && tb[IPSET_ATTR_PORT_TO]) {
 		port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 		if (port > port_to)
@@ -246,9 +196,9 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 		p = retried && ip == ntohl(h->next.ip) ? ntohs(h->next.port)
 						       : port;
 		for (; p <= port_to; p++) {
-			data.ip = htonl(ip);
-			data.port = htons(p);
-			ret = adtfn(set, &data, timeout, flags);
+			e.ip = htonl(ip);
+			e.port = htons(p);
+			ret = adtfn(set, &e, &ext, &ext, flags);
 
 			if (ret && !ip_set_eexist(ret, flags))
 				return ret;
@@ -259,18 +209,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-static bool
-hash_ipportip_same_set(const struct ip_set *a, const struct ip_set *b)
-{
-	const struct ip_set_hash *x = a->data;
-	const struct ip_set_hash *y = b->data;
-
-	/* Resizing changes htable_bits, so we ignore it */
-	return x->maxelem == y->maxelem &&
-	       x->timeout == y->timeout;
-}
-
-/* The type variant functions: IPv6 */
+/* IPv6 variants */
 
 struct hash_ipportip6_elem {
 	union nf_inet_addr ip;
@@ -280,7 +219,7 @@ struct hash_ipportip6_elem {
 	u8 padding;
 };
 
-struct hash_ipportip6_telem {
+struct hash_ipportip6t_elem {
 	union nf_inet_addr ip;
 	union nf_inet_addr ip2;
 	__be16 port;
@@ -289,6 +228,8 @@ struct hash_ipportip6_telem {
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_ipportip6_data_equal(const struct hash_ipportip6_elem *ip1,
 			  const struct hash_ipportip6_elem *ip2,
@@ -300,25 +241,6 @@ hash_ipportip6_data_equal(const struct hash_ipportip6_elem *ip1,
 	       ip1->proto == ip2->proto;
 }
 
-static inline bool
-hash_ipportip6_data_isnull(const struct hash_ipportip6_elem *elem)
-{
-	return elem->proto == 0;
-}
-
-static inline void
-hash_ipportip6_data_copy(struct hash_ipportip6_elem *dst,
-			 const struct hash_ipportip6_elem *src)
-{
-	memcpy(dst, src, sizeof(*dst));
-}
-
-static inline void
-hash_ipportip6_data_zero_out(struct hash_ipportip6_elem *elem)
-{
-	elem->proto = 0;
-}
-
 static bool
 hash_ipportip6_data_list(struct sk_buff *skb,
 			 const struct hash_ipportip6_elem *data)
@@ -334,68 +256,51 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_ipportip6_data_tlist(struct sk_buff *skb,
-			  const struct hash_ipportip6_elem *data)
+static inline void
+hash_ipportip6_data_next(struct hash_ipportip4_elem *next,
+			 const struct hash_ipportip6_elem *d)
 {
-	const struct hash_ipportip6_telem *e =
-		(const struct hash_ipportip6_telem *)data;
-
-	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
-	    nla_put_ipaddr6(skb, IPSET_ATTR_IP2, &data->ip2.in6) ||
-	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
-	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(e->timeout))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
+	next->port = d->port;
 }
 
+#undef MTYPE
 #undef PF
 #undef HOST_MASK
 
+#define MTYPE		hash_ipportip6
 #define PF		6
 #define HOST_MASK	128
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_ipportip6_data_next(struct ip_set_hash *h,
-			 const struct hash_ipportip6_elem *d)
-{
-	h->next.port = d->port;
-}
+#define IP_SET_EMIT_CREATE
+#include "ip_set_hash_gen.h"
 
 static int
 hash_ipportip6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		    const struct xt_action_param *par,
-		    enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		    enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipportip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportip6_elem data = { };
+	struct hash_ipportip6_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
 	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
-				 &data.port, &data.proto))
+				 &e.port, &e.proto))
 		return -EINVAL;
 
-	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
-	ip6addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &data.ip2.in6);
-
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip.in6);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &e.ip2.in6);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 		    enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipportip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportip6_elem data = { };
+	struct hash_ipportip6_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	u32 port, port_to;
-	u32 timeout = h->timeout;
 	bool with_ports = false;
 	int ret;
 
@@ -410,43 +315,38 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &data.ip);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP2], &data.ip2);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP2], &e.ip2);
 	if (ret)
 		return ret;
 
 	if (tb[IPSET_ATTR_PORT])
-		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
+		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 	else
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_PROTO]) {
-		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
-		with_ports = ip_set_proto_with_ports(data.proto);
+		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(e.proto);
 
-		if (data.proto == 0)
+		if (e.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	if (!(with_ports || data.proto == IPPROTO_ICMPV6))
-		data.port = 0;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+	if (!(with_ports || e.proto == IPPROTO_ICMPV6))
+		e.port = 0;
 
 	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
-		ret = adtfn(set, &data, timeout, flags);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
-	port = ntohs(data.port);
+	port = ntohs(e.port);
 	port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 	if (port > port_to)
 		swap(port, port_to);
@@ -454,8 +354,8 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (retried)
 		port = ntohs(h->next.port);
 	for (; port <= port_to; port++) {
-		data.port = htons(port);
-		ret = adtfn(set, &data, timeout, flags);
+		e.port = htons(port);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 
 		if (ret && !ip_set_eexist(ret, flags))
 			return ret;
@@ -465,78 +365,6 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-/* Create hash:ip type of sets */
-
-static int
-hash_ipportip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
-{
-	struct ip_set_hash *h;
-	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
-	u8 hbits;
-	size_t hsize;
-
-	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
-		return -IPSET_ERR_INVALID_FAMILY;
-
-	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_MAXELEM) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
-		return -IPSET_ERR_PROTOCOL;
-
-	if (tb[IPSET_ATTR_HASHSIZE]) {
-		hashsize = ip_set_get_h32(tb[IPSET_ATTR_HASHSIZE]);
-		if (hashsize < IPSET_MIMINAL_HASHSIZE)
-			hashsize = IPSET_MIMINAL_HASHSIZE;
-	}
-
-	if (tb[IPSET_ATTR_MAXELEM])
-		maxelem = ip_set_get_h32(tb[IPSET_ATTR_MAXELEM]);
-
-	h = kzalloc(sizeof(*h), GFP_KERNEL);
-	if (!h)
-		return -ENOMEM;
-
-	h->maxelem = maxelem;
-	get_random_bytes(&h->initval, sizeof(h->initval));
-	h->timeout = IPSET_NO_TIMEOUT;
-
-	hbits = htable_bits(hashsize);
-	hsize = htable_size(hbits);
-	if (hsize == 0) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table = ip_set_alloc(hsize);
-	if (!h->table) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table->htable_bits = hbits;
-
-	set->data = h;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_ipportip4_tvariant : &hash_ipportip6_tvariant;
-
-		if (set->family == NFPROTO_IPV4)
-			hash_ipportip4_gc_init(set);
-		else
-			hash_ipportip6_gc_init(set);
-	} else {
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_ipportip4_variant : &hash_ipportip6_variant;
-	}
-
-	pr_debug("create %s hashsize %u (%u) maxelem %u: %p(%p)\n",
-		 set->name, jhash_size(h->table->htable_bits),
-		 h->table->htable_bits, h->maxelem, set->data, h->table);
-
-	return 0;
-}
-
 static struct ip_set_type hash_ipportip_type __read_mostly = {
 	.name		= "hash:ip,port,ip",
 	.protocol	= IPSET_PROTOCOL,
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 352f8b4..bfde4ea 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+/* Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -21,7 +21,6 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/ipset/pfxlen.h>
 #include <linux/netfilter/ipset/ip_set.h>
-#include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_getport.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
@@ -36,23 +35,19 @@ IP_SET_MODULE_DESC("hash:ip,port,net", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:ip,port,net");
 
 /* Type specific function prefix */
-#define TYPE		hash_ipportnet
-
-static bool
-hash_ipportnet_same_set(const struct ip_set *a, const struct ip_set *b);
-
-#define hash_ipportnet4_same_set	hash_ipportnet_same_set
-#define hash_ipportnet6_same_set	hash_ipportnet_same_set
-
-/* The type variant functions: IPv4 */
+#define HTYPE		hash_ipportnet
 
 /* We squeeze the "nomatch" flag into cidr: we don't support cidr == 0
  * However this way we have to store internally cidr - 1,
  * dancing back and forth.
  */
 #define IP_SET_HASH_WITH_NETS_PACKED
+#define IP_SET_HASH_WITH_PROTO
+#define IP_SET_HASH_WITH_NETS
 
-/* Member elements without timeout */
+/* IPv4 variants */
+
+/* Member elements */
 struct hash_ipportnet4_elem {
 	__be32 ip;
 	__be32 ip2;
@@ -62,8 +57,7 @@ struct hash_ipportnet4_elem {
 	u8 proto;
 };
 
-/* Member elements with timeout support */
-struct hash_ipportnet4_telem {
+struct hash_ipportnet4t_elem {
 	__be32 ip;
 	__be32 ip2;
 	__be16 port;
@@ -73,6 +67,8 @@ struct hash_ipportnet4_telem {
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_ipportnet4_data_equal(const struct hash_ipportnet4_elem *ip1,
 			   const struct hash_ipportnet4_elem *ip2,
@@ -85,38 +81,22 @@ hash_ipportnet4_data_equal(const struct hash_ipportnet4_elem *ip1,
 	       ip1->proto == ip2->proto;
 }
 
-static inline bool
-hash_ipportnet4_data_isnull(const struct hash_ipportnet4_elem *elem)
+static inline int
+hash_ipportnet4_do_data_match(const struct hash_ipportnet4_elem *elem)
 {
-	return elem->proto == 0;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
-hash_ipportnet4_data_copy(struct hash_ipportnet4_elem *dst,
-			  const struct hash_ipportnet4_elem *src)
+hash_ipportnet4_data_set_flags(struct hash_ipportnet4_elem *elem, u32 flags)
 {
-	memcpy(dst, src, sizeof(*dst));
+	elem->nomatch = !!((flags >> 16) & IPSET_FLAG_NOMATCH);
 }
 
 static inline void
-hash_ipportnet4_data_flags(struct hash_ipportnet4_elem *dst, u32 flags)
+hash_ipportnet4_data_reset_flags(struct hash_ipportnet4_elem *elem, u8 *flags)
 {
-	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
-}
-
-static inline void
-hash_ipportnet4_data_reset_flags(struct hash_ipportnet4_elem *dst, u32 *flags)
-{
-	if (dst->nomatch) {
-		*flags = IPSET_FLAG_NOMATCH;
-		dst->nomatch = 0;
-	}
-}
-
-static inline int
-hash_ipportnet4_data_match(const struct hash_ipportnet4_elem *elem)
-{
-	return elem->nomatch ? -ENOTEMPTY : 1;
+	swap(*flags, elem->nomatch);
 }
 
 static inline void
@@ -126,12 +106,6 @@ hash_ipportnet4_data_netmask(struct hash_ipportnet4_elem *elem, u8 cidr)
 	elem->cidr = cidr - 1;
 }
 
-static inline void
-hash_ipportnet4_data_zero_out(struct hash_ipportnet4_elem *elem)
-{
-	elem->proto = 0;
-}
-
 static bool
 hash_ipportnet4_data_list(struct sk_buff *skb,
 			  const struct hash_ipportnet4_elem *data)
@@ -152,81 +126,56 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_ipportnet4_data_tlist(struct sk_buff *skb,
-			   const struct hash_ipportnet4_elem *data)
+static inline void
+hash_ipportnet4_data_next(struct hash_ipportnet4_elem *next,
+			  const struct hash_ipportnet4_elem *d)
 {
-	const struct hash_ipportnet4_telem *tdata =
-		(const struct hash_ipportnet4_telem *)data;
-	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
-
-	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
-	    nla_put_ipaddr4(skb, IPSET_ATTR_IP2, tdata->ip2) ||
-	    nla_put_net16(skb, IPSET_ATTR_PORT, tdata->port) ||
-	    nla_put_u8(skb, IPSET_ATTR_CIDR2, data->cidr + 1) ||
-	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(tdata->timeout))) ||
-	    (flags &&
-	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
+	next->ip = d->ip;
+	next->port = d->port;
+	next->ip2 = d->ip2;
 }
 
-#define IP_SET_HASH_WITH_PROTO
-#define IP_SET_HASH_WITH_NETS
-
+#define MTYPE		hash_ipportnet4
 #define PF		4
 #define HOST_MASK	32
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_ipportnet4_data_next(struct ip_set_hash *h,
-			  const struct hash_ipportnet4_elem *d)
-{
-	h->next.ip = d->ip;
-	h->next.port = d->port;
-	h->next.ip2 = d->ip2;
-}
+#include "ip_set_hash_gen.h"
 
 static int
 hash_ipportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		     const struct xt_action_param *par,
-		     enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		     enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportnet4_elem data = {
+	struct hash_ipportnet4_elem e = {
 		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1
 	};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK - 1;
+		e.cidr = HOST_MASK - 1;
 
 	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
-				 &data.port, &data.proto))
+				 &e.port, &e.proto))
 		return -EINVAL;
 
-	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
-	ip4addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &data.ip2);
-	data.ip2 &= ip_set_netmask(data.cidr + 1);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &e.ip2);
+	e.ip2 &= ip_set_netmask(e.cidr + 1);
 
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportnet4_elem data = { .cidr = HOST_MASK - 1 };
+	struct hash_ipportnet4_elem e = { .cidr = HOST_MASK - 1 };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	u32 ip, ip_to, p = 0, port, port_to;
 	u32 ip2_from, ip2_to, ip2_last, ip2;
-	u32 timeout = h->timeout;
 	bool with_ports = false;
 	u8 cidr;
 	int ret;
@@ -241,7 +190,8 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -253,31 +203,25 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
 		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
-		data.cidr = cidr - 1;
+		e.cidr = cidr - 1;
 	}
 
 	if (tb[IPSET_ATTR_PORT])
-		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
+		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 	else
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_PROTO]) {
-		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
-		with_ports = ip_set_proto_with_ports(data.proto);
+		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(e.proto);
 
-		if (data.proto == 0)
+		if (e.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	if (!(with_ports || data.proto == IPPROTO_ICMP))
-		data.port = 0;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+	if (!(with_ports || e.proto == IPPROTO_ICMP))
+		e.port = 0;
 
 	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
@@ -289,9 +233,9 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (adt == IPSET_TEST ||
 	    !(tb[IPSET_ATTR_CIDR] || tb[IPSET_ATTR_IP_TO] || with_ports ||
 	      tb[IPSET_ATTR_IP2_TO])) {
-		data.ip = htonl(ip);
-		data.ip2 = htonl(ip2_from & ip_set_hostmask(data.cidr + 1));
-		ret = adtfn(set, &data, timeout, flags);
+		e.ip = htonl(ip);
+		e.ip2 = htonl(ip2_from & ip_set_hostmask(e.cidr + 1));
+		ret = adtfn(set, &e, &ext, &ext, flags);
 		return ip_set_enomatch(ret, flags, adt) ? 1 :
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
@@ -311,7 +255,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		ip_set_mask_from_to(ip, ip_to, cidr);
 	}
 
-	port_to = port = ntohs(data.port);
+	port_to = port = ntohs(e.port);
 	if (tb[IPSET_ATTR_PORT_TO]) {
 		port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 		if (port > port_to)
@@ -327,28 +271,27 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 			swap(ip2_from, ip2_to);
 		if (ip2_from + UINT_MAX == ip2_to)
 			return -IPSET_ERR_HASH_RANGE;
-	} else {
-		ip_set_mask_from_to(ip2_from, ip2_to, data.cidr + 1);
-	}
+	} else
+		ip_set_mask_from_to(ip2_from, ip2_to, e.cidr + 1);
 
 	if (retried)
 		ip = ntohl(h->next.ip);
 	for (; !before(ip_to, ip); ip++) {
-		data.ip = htonl(ip);
+		e.ip = htonl(ip);
 		p = retried && ip == ntohl(h->next.ip) ? ntohs(h->next.port)
 						       : port;
 		for (; p <= port_to; p++) {
-			data.port = htons(p);
+			e.port = htons(p);
 			ip2 = retried
 			      && ip == ntohl(h->next.ip)
 			      && p == ntohs(h->next.port)
 				? ntohl(h->next.ip2) : ip2_from;
 			while (!after(ip2, ip2_to)) {
-				data.ip2 = htonl(ip2);
+				e.ip2 = htonl(ip2);
 				ip2_last = ip_set_range_to_cidr(ip2, ip2_to,
 								&cidr);
-				data.cidr = cidr - 1;
-				ret = adtfn(set, &data, timeout, flags);
+				e.cidr = cidr - 1;
+				ret = adtfn(set, &e, &ext, &ext, flags);
 
 				if (ret && !ip_set_eexist(ret, flags))
 					return ret;
@@ -361,18 +304,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-static bool
-hash_ipportnet_same_set(const struct ip_set *a, const struct ip_set *b)
-{
-	const struct ip_set_hash *x = a->data;
-	const struct ip_set_hash *y = b->data;
-
-	/* Resizing changes htable_bits, so we ignore it */
-	return x->maxelem == y->maxelem &&
-	       x->timeout == y->timeout;
-}
-
-/* The type variant functions: IPv6 */
+/* IPv6 variants */
 
 struct hash_ipportnet6_elem {
 	union nf_inet_addr ip;
@@ -383,7 +315,7 @@ struct hash_ipportnet6_elem {
 	u8 proto;
 };
 
-struct hash_ipportnet6_telem {
+struct hash_ipportnet6t_elem {
 	union nf_inet_addr ip;
 	union nf_inet_addr ip2;
 	__be16 port;
@@ -393,6 +325,8 @@ struct hash_ipportnet6_telem {
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_ipportnet6_data_equal(const struct hash_ipportnet6_elem *ip1,
 			   const struct hash_ipportnet6_elem *ip2,
@@ -405,44 +339,22 @@ hash_ipportnet6_data_equal(const struct hash_ipportnet6_elem *ip1,
 	       ip1->proto == ip2->proto;
 }
 
-static inline bool
-hash_ipportnet6_data_isnull(const struct hash_ipportnet6_elem *elem)
-{
-	return elem->proto == 0;
-}
-
-static inline void
-hash_ipportnet6_data_copy(struct hash_ipportnet6_elem *dst,
-			  const struct hash_ipportnet6_elem *src)
-{
-	memcpy(dst, src, sizeof(*dst));
-}
-
-static inline void
-hash_ipportnet6_data_flags(struct hash_ipportnet6_elem *dst, u32 flags)
+static inline int
+hash_ipportnet6_do_data_match(const struct hash_ipportnet6_elem *elem)
 {
-	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
-hash_ipportnet6_data_reset_flags(struct hash_ipportnet6_elem *dst, u32 *flags)
-{
-	if (dst->nomatch) {
-		*flags = IPSET_FLAG_NOMATCH;
-		dst->nomatch = 0;
-	}
-}
-
-static inline int
-hash_ipportnet6_data_match(const struct hash_ipportnet6_elem *elem)
+hash_ipportnet6_data_set_flags(struct hash_ipportnet6_elem *elem, u32 flags)
 {
-	return elem->nomatch ? -ENOTEMPTY : 1;
+	elem->nomatch = !!((flags >> 16) & IPSET_FLAG_NOMATCH);
 }
 
 static inline void
-hash_ipportnet6_data_zero_out(struct hash_ipportnet6_elem *elem)
+hash_ipportnet6_data_reset_flags(struct hash_ipportnet6_elem *elem, u8 *flags)
 {
-	elem->proto = 0;
+	swap(*flags, elem->nomatch);
 }
 
 static inline void
@@ -472,78 +384,58 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_ipportnet6_data_tlist(struct sk_buff *skb,
-			   const struct hash_ipportnet6_elem *data)
+static inline void
+hash_ipportnet6_data_next(struct hash_ipportnet4_elem *next,
+			  const struct hash_ipportnet6_elem *d)
 {
-	const struct hash_ipportnet6_telem *e =
-		(const struct hash_ipportnet6_telem *)data;
-	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
-
-	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
-	    nla_put_ipaddr6(skb, IPSET_ATTR_IP2, &data->ip2.in6) ||
-	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
-	    nla_put_u8(skb, IPSET_ATTR_CIDR2, data->cidr + 1) ||
-	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(e->timeout))) ||
-	    (flags &&
-	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
+	next->port = d->port;
 }
 
+#undef MTYPE
 #undef PF
 #undef HOST_MASK
 
+#define MTYPE		hash_ipportnet6
 #define PF		6
 #define HOST_MASK	128
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_ipportnet6_data_next(struct ip_set_hash *h,
-			  const struct hash_ipportnet6_elem *d)
-{
-	h->next.port = d->port;
-}
+#define IP_SET_EMIT_CREATE
+#include "ip_set_hash_gen.h"
 
 static int
 hash_ipportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		     const struct xt_action_param *par,
-		     enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		     enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportnet6_elem data = {
+	struct hash_ipportnet6_elem e = {
 		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1
 	};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK - 1;
+		e.cidr = HOST_MASK - 1;
 
 	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
-				 &data.port, &data.proto))
+				 &e.port, &e.proto))
 		return -EINVAL;
 
-	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
-	ip6addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &data.ip2.in6);
-	ip6_netmask(&data.ip2, data.cidr + 1);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip.in6);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &e.ip2.in6);
+	ip6_netmask(&e.ip2, e.cidr + 1);
 
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_ipportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportnet6_elem data = { .cidr = HOST_MASK - 1 };
+	struct hash_ipportnet6_elem e = { .cidr = HOST_MASK - 1 };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	u32 port, port_to;
-	u32 timeout = h->timeout;
 	bool with_ports = false;
 	u8 cidr;
 	int ret;
@@ -562,11 +454,12 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &data.ip);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP2], &data.ip2);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP2], &e.ip2);
 	if (ret)
 		return ret;
 
@@ -574,33 +467,27 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
 		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
-		data.cidr = cidr - 1;
+		e.cidr = cidr - 1;
 	}
 
-	ip6_netmask(&data.ip2, data.cidr + 1);
+	ip6_netmask(&e.ip2, e.cidr + 1);
 
 	if (tb[IPSET_ATTR_PORT])
-		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
+		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 	else
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_PROTO]) {
-		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
-		with_ports = ip_set_proto_with_ports(data.proto);
+		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(e.proto);
 
-		if (data.proto == 0)
+		if (e.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	if (!(with_ports || data.proto == IPPROTO_ICMPV6))
-		data.port = 0;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+	if (!(with_ports || e.proto == IPPROTO_ICMPV6))
+		e.port = 0;
 
 	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
@@ -609,12 +496,12 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
-		ret = adtfn(set, &data, timeout, flags);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 		return ip_set_enomatch(ret, flags, adt) ? 1 :
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
-	port = ntohs(data.port);
+	port = ntohs(e.port);
 	port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 	if (port > port_to)
 		swap(port, port_to);
@@ -622,8 +509,8 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (retried)
 		port = ntohs(h->next.port);
 	for (; port <= port_to; port++) {
-		data.port = htons(port);
-		ret = adtfn(set, &data, timeout, flags);
+		e.port = htons(port);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 
 		if (ret && !ip_set_eexist(ret, flags))
 			return ret;
@@ -633,81 +520,6 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-/* Create hash:ip type of sets */
-
-static int
-hash_ipportnet_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
-{
-	struct ip_set_hash *h;
-	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
-	u8 hbits;
-	size_t hsize;
-
-	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
-		return -IPSET_ERR_INVALID_FAMILY;
-
-	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_MAXELEM) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
-		return -IPSET_ERR_PROTOCOL;
-
-	if (tb[IPSET_ATTR_HASHSIZE]) {
-		hashsize = ip_set_get_h32(tb[IPSET_ATTR_HASHSIZE]);
-		if (hashsize < IPSET_MIMINAL_HASHSIZE)
-			hashsize = IPSET_MIMINAL_HASHSIZE;
-	}
-
-	if (tb[IPSET_ATTR_MAXELEM])
-		maxelem = ip_set_get_h32(tb[IPSET_ATTR_MAXELEM]);
-
-	h = kzalloc(sizeof(*h)
-		    + sizeof(struct ip_set_hash_nets)
-		      * (set->family == NFPROTO_IPV4 ? 32 : 128), GFP_KERNEL);
-	if (!h)
-		return -ENOMEM;
-
-	h->maxelem = maxelem;
-	get_random_bytes(&h->initval, sizeof(h->initval));
-	h->timeout = IPSET_NO_TIMEOUT;
-
-	hbits = htable_bits(hashsize);
-	hsize = htable_size(hbits);
-	if (hsize == 0) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table = ip_set_alloc(hsize);
-	if (!h->table) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table->htable_bits = hbits;
-
-	set->data = h;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_ipportnet4_tvariant
-			: &hash_ipportnet6_tvariant;
-
-		if (set->family == NFPROTO_IPV4)
-			hash_ipportnet4_gc_init(set);
-		else
-			hash_ipportnet6_gc_init(set);
-	} else {
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_ipportnet4_variant : &hash_ipportnet6_variant;
-	}
-
-	pr_debug("create %s hashsize %u (%u) maxelem %u: %p(%p)\n",
-		 set->name, jhash_size(h->table->htable_bits),
-		 h->table->htable_bits, h->maxelem, set->data, h->table);
-
-	return 0;
-}
-
 static struct ip_set_type hash_ipportnet_type __read_mostly = {
 	.name		= "hash:ip,port,net",
 	.protocol	= IPSET_PROTOCOL,
@@ -724,6 +536,7 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 		[IPSET_ATTR_PROBES]	= { .type = NLA_U8 },
 		[IPSET_ATTR_RESIZE]	= { .type = NLA_U8  },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 370947c..cfbcdd4 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+/* Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -20,7 +20,6 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/ipset/pfxlen.h>
 #include <linux/netfilter/ipset/ip_set.h>
-#include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define REVISION_MIN	0
@@ -33,17 +32,12 @@ IP_SET_MODULE_DESC("hash:net", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:net");
 
 /* Type specific function prefix */
-#define TYPE		hash_net
-
-static bool
-hash_net_same_set(const struct ip_set *a, const struct ip_set *b);
-
-#define hash_net4_same_set	hash_net_same_set
-#define hash_net6_same_set	hash_net_same_set
+#define HTYPE		hash_net
+#define IP_SET_HASH_WITH_NETS
 
-/* The type variant functions: IPv4 */
+/* IPv4 variants */
 
-/* Member elements without timeout */
+/* Member elements  */
 struct hash_net4_elem {
 	__be32 ip;
 	u16 padding0;
@@ -51,8 +45,7 @@ struct hash_net4_elem {
 	u8 cidr;
 };
 
-/* Member elements with timeout support */
-struct hash_net4_telem {
+struct hash_net4t_elem {
 	__be32 ip;
 	u16 padding0;
 	u8 nomatch;
@@ -60,6 +53,8 @@ struct hash_net4_telem {
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_net4_data_equal(const struct hash_net4_elem *ip1,
 		     const struct hash_net4_elem *ip2,
@@ -69,40 +64,22 @@ hash_net4_data_equal(const struct hash_net4_elem *ip1,
 	       ip1->cidr == ip2->cidr;
 }
 
-static inline bool
-hash_net4_data_isnull(const struct hash_net4_elem *elem)
-{
-	return elem->cidr == 0;
-}
-
-static inline void
-hash_net4_data_copy(struct hash_net4_elem *dst,
-		    const struct hash_net4_elem *src)
+static inline int
+hash_net4_do_data_match(const struct hash_net4_elem *elem)
 {
-	dst->ip = src->ip;
-	dst->cidr = src->cidr;
-	dst->nomatch = src->nomatch;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
-hash_net4_data_flags(struct hash_net4_elem *dst, u32 flags)
+hash_net4_data_set_flags(struct hash_net4_elem *elem, u32 flags)
 {
-	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
+	elem->nomatch = (flags >> 16) & IPSET_FLAG_NOMATCH;
 }
 
 static inline void
-hash_net4_data_reset_flags(struct hash_net4_elem *dst, u32 *flags)
-{
-	if (dst->nomatch) {
-		*flags = IPSET_FLAG_NOMATCH;
-		dst->nomatch = 0;
-	}
-}
-
-static inline int
-hash_net4_data_match(const struct hash_net4_elem *elem)
+hash_net4_data_reset_flags(struct hash_net4_elem *elem, u8 *flags)
 {
-	return elem->nomatch ? -ENOTEMPTY : 1;
+	swap(*flags, elem->nomatch);
 }
 
 static inline void
@@ -112,13 +89,6 @@ hash_net4_data_netmask(struct hash_net4_elem *elem, u8 cidr)
 	elem->cidr = cidr;
 }
 
-/* Zero CIDR values cannot be stored */
-static inline void
-hash_net4_data_zero_out(struct hash_net4_elem *elem)
-{
-	elem->cidr = 0;
-}
-
 static bool
 hash_net4_data_list(struct sk_buff *skb, const struct hash_net4_elem *data)
 {
@@ -135,69 +105,49 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_net4_data_tlist(struct sk_buff *skb, const struct hash_net4_elem *data)
+static inline void
+hash_net4_data_next(struct hash_net4_elem *next,
+		    const struct hash_net4_elem *d)
 {
-	const struct hash_net4_telem *tdata =
-		(const struct hash_net4_telem *)data;
-	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
-
-	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
-	    nla_put_u8(skb, IPSET_ATTR_CIDR, tdata->cidr) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(tdata->timeout))) ||
-	    (flags &&
-	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
+	next->ip = d->ip;
 }
 
-#define IP_SET_HASH_WITH_NETS
-
+#define MTYPE		hash_net4
 #define PF		4
 #define HOST_MASK	32
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_net4_data_next(struct ip_set_hash *h,
-		    const struct hash_net4_elem *d)
-{
-	h->next.ip = d->ip;
-}
+#include "ip_set_hash_gen.h"
 
 static int
 hash_net4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	       const struct xt_action_param *par,
-	       enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+	       enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_net *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_net4_elem data = {
+	struct hash_net4_elem e = {
 		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
 	};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
-	if (data.cidr == 0)
+	if (e.cidr == 0)
 		return -EINVAL;
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK;
+		e.cidr = HOST_MASK;
 
-	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
-	data.ip &= ip_set_netmask(data.cidr);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip);
+	e.ip &= ip_set_netmask(e.cidr);
 
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	       enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_net *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_net4_elem data = { .cidr = HOST_MASK };
-	u32 timeout = h->timeout;
+	struct hash_net4_elem e = { .cidr = HOST_MASK };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	u32 ip = 0, ip_to, last;
 	int ret;
 
@@ -209,22 +159,17 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
 	if (tb[IPSET_ATTR_CIDR]) {
-		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-		if (!data.cidr || data.cidr > HOST_MASK)
+		e.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+		if (!e.cidr || e.cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 	}
 
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
-
 	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_NOMATCH)
@@ -232,8 +177,8 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (adt == IPSET_TEST || !tb[IPSET_ATTR_IP_TO]) {
-		data.ip = htonl(ip & ip_set_hostmask(data.cidr));
-		ret = adtfn(set, &data, timeout, flags);
+		e.ip = htonl(ip & ip_set_hostmask(e.cidr));
+		ret = adtfn(set, &e, &ext, &ext, flags);
 		return ip_set_enomatch(ret, flags, adt) ? 1 :
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
@@ -251,9 +196,9 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (retried)
 		ip = ntohl(h->next.ip);
 	while (!after(ip, ip_to)) {
-		data.ip = htonl(ip);
-		last = ip_set_range_to_cidr(ip, ip_to, &data.cidr);
-		ret = adtfn(set, &data, timeout, flags);
+		e.ip = htonl(ip);
+		last = ip_set_range_to_cidr(ip, ip_to, &e.cidr);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 		if (ret && !ip_set_eexist(ret, flags))
 			return ret;
 		else
@@ -263,18 +208,7 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-static bool
-hash_net_same_set(const struct ip_set *a, const struct ip_set *b)
-{
-	const struct ip_set_hash *x = a->data;
-	const struct ip_set_hash *y = b->data;
-
-	/* Resizing changes htable_bits, so we ignore it */
-	return x->maxelem == y->maxelem &&
-	       x->timeout == y->timeout;
-}
-
-/* The type variant functions: IPv6 */
+/* IPv6 variants */
 
 struct hash_net6_elem {
 	union nf_inet_addr ip;
@@ -283,7 +217,7 @@ struct hash_net6_elem {
 	u8 cidr;
 };
 
-struct hash_net6_telem {
+struct hash_net6t_elem {
 	union nf_inet_addr ip;
 	u16 padding0;
 	u8 nomatch;
@@ -291,6 +225,8 @@ struct hash_net6_telem {
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_net6_data_equal(const struct hash_net6_elem *ip1,
 		     const struct hash_net6_elem *ip2,
@@ -300,46 +236,22 @@ hash_net6_data_equal(const struct hash_net6_elem *ip1,
 	       ip1->cidr == ip2->cidr;
 }
 
-static inline bool
-hash_net6_data_isnull(const struct hash_net6_elem *elem)
-{
-	return elem->cidr == 0;
-}
-
-static inline void
-hash_net6_data_copy(struct hash_net6_elem *dst,
-		    const struct hash_net6_elem *src)
-{
-	dst->ip.in6 = src->ip.in6;
-	dst->cidr = src->cidr;
-	dst->nomatch = src->nomatch;
-}
-
-static inline void
-hash_net6_data_flags(struct hash_net6_elem *dst, u32 flags)
+static inline int
+hash_net6_do_data_match(const struct hash_net6_elem *elem)
 {
-	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
-hash_net6_data_reset_flags(struct hash_net6_elem *dst, u32 *flags)
-{
-	if (dst->nomatch) {
-		*flags = IPSET_FLAG_NOMATCH;
-		dst->nomatch = 0;
-	}
-}
-
-static inline int
-hash_net6_data_match(const struct hash_net6_elem *elem)
+hash_net6_data_set_flags(struct hash_net6_elem *elem, u32 flags)
 {
-	return elem->nomatch ? -ENOTEMPTY : 1;
+	elem->nomatch = (flags >> 16) & IPSET_FLAG_NOMATCH;
 }
 
 static inline void
-hash_net6_data_zero_out(struct hash_net6_elem *elem)
+hash_net6_data_reset_flags(struct hash_net6_elem *elem, u8 *flags)
 {
-	elem->cidr = 0;
+	swap(*flags, elem->nomatch);
 }
 
 static inline void
@@ -365,69 +277,53 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_net6_data_tlist(struct sk_buff *skb, const struct hash_net6_elem *data)
+static inline void
+hash_net6_data_next(struct hash_net4_elem *next,
+		    const struct hash_net6_elem *d)
 {
-	const struct hash_net6_telem *e =
-		(const struct hash_net6_telem *)data;
-	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
-
-	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
-	    nla_put_u8(skb, IPSET_ATTR_CIDR, e->cidr) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(e->timeout))) ||
-	    (flags &&
-	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
 }
 
+#undef MTYPE
 #undef PF
 #undef HOST_MASK
 
+#define MTYPE		hash_net6
 #define PF		6
 #define HOST_MASK	128
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_net6_data_next(struct ip_set_hash *h,
-		    const struct hash_net6_elem *d)
-{
-}
+#define IP_SET_EMIT_CREATE
+#include "ip_set_hash_gen.h"
 
 static int
 hash_net6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	       const struct xt_action_param *par,
-	       enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+	       enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_net *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_net6_elem data = {
+	struct hash_net6_elem e = {
 		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
 	};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
-	if (data.cidr == 0)
+	if (e.cidr == 0)
 		return -EINVAL;
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK;
+		e.cidr = HOST_MASK;
 
-	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
-	ip6_netmask(&data.ip, data.cidr);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip.in6);
+	ip6_netmask(&e.ip, e.cidr);
 
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 	       enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_net *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_net6_elem data = { .cidr = HOST_MASK };
-	u32 timeout = h->timeout;
+	struct hash_net6_elem e = { .cidr = HOST_MASK };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -440,23 +336,18 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &data.ip);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
 	if (tb[IPSET_ATTR_CIDR])
-		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+		e.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-	if (!data.cidr || data.cidr > HOST_MASK)
+	if (!e.cidr || e.cidr > HOST_MASK)
 		return -IPSET_ERR_INVALID_CIDR;
 
-	ip6_netmask(&data.ip, data.cidr);
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+	ip6_netmask(&e.ip, e.cidr);
 
 	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
@@ -464,86 +355,12 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 
-	ret = adtfn(set, &data, timeout, flags);
+	ret = adtfn(set, &e, &ext, &ext, flags);
 
 	return ip_set_enomatch(ret, flags, adt) ? 1 :
 	       ip_set_eexist(ret, flags) ? 0 : ret;
 }
 
-/* Create hash:ip type of sets */
-
-static int
-hash_net_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
-{
-	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
-	struct ip_set_hash *h;
-	u8 hbits;
-	size_t hsize;
-
-	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
-		return -IPSET_ERR_INVALID_FAMILY;
-
-	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_MAXELEM) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
-		return -IPSET_ERR_PROTOCOL;
-
-	if (tb[IPSET_ATTR_HASHSIZE]) {
-		hashsize = ip_set_get_h32(tb[IPSET_ATTR_HASHSIZE]);
-		if (hashsize < IPSET_MIMINAL_HASHSIZE)
-			hashsize = IPSET_MIMINAL_HASHSIZE;
-	}
-
-	if (tb[IPSET_ATTR_MAXELEM])
-		maxelem = ip_set_get_h32(tb[IPSET_ATTR_MAXELEM]);
-
-	h = kzalloc(sizeof(*h)
-		    + sizeof(struct ip_set_hash_nets)
-		      * (set->family == NFPROTO_IPV4 ? 32 : 128), GFP_KERNEL);
-	if (!h)
-		return -ENOMEM;
-
-	h->maxelem = maxelem;
-	get_random_bytes(&h->initval, sizeof(h->initval));
-	h->timeout = IPSET_NO_TIMEOUT;
-
-	hbits = htable_bits(hashsize);
-	hsize = htable_size(hbits);
-	if (hsize == 0) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table = ip_set_alloc(hsize);
-	if (!h->table) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table->htable_bits = hbits;
-
-	set->data = h;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_net4_tvariant : &hash_net6_tvariant;
-
-		if (set->family == NFPROTO_IPV4)
-			hash_net4_gc_init(set);
-		else
-			hash_net6_gc_init(set);
-	} else {
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_net4_variant : &hash_net6_variant;
-	}
-
-	pr_debug("create %s hashsize %u (%u) maxelem %u: %p(%p)\n",
-		 set->name, jhash_size(h->table->htable_bits),
-		 h->table->htable_bits, h->maxelem, set->data, h->table);
-
-	return 0;
-}
-
 static struct ip_set_type hash_net_type __read_mostly = {
 	.name		= "hash:net",
 	.protocol	= IPSET_PROTOCOL,
@@ -559,6 +376,7 @@ static struct ip_set_type hash_net_type __read_mostly = {
 		[IPSET_ATTR_PROBES]	= { .type = NLA_U8 },
 		[IPSET_ATTR_RESIZE]	= { .type = NLA_U8  },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index dd9843e..555ebb7 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+/* Copyright (C) 2011-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -21,7 +21,6 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/ipset/pfxlen.h>
 #include <linux/netfilter/ipset/ip_set.h>
-#include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define REVISION_MIN	0
@@ -127,17 +126,14 @@ iface_add(struct rb_root *root, const char **iface)
 }
 
 /* Type specific function prefix */
-#define TYPE		hash_netiface
-
-static bool
-hash_netiface_same_set(const struct ip_set *a, const struct ip_set *b);
-
-#define hash_netiface4_same_set	hash_netiface_same_set
-#define hash_netiface6_same_set	hash_netiface_same_set
+#define HTYPE		hash_netiface
+#define IP_SET_HASH_WITH_NETS
+#define IP_SET_HASH_WITH_RBTREE
+#define IP_SET_HASH_WITH_MULTI
 
 #define STREQ(a, b)	(strcmp(a, b) == 0)
 
-/* The type variant functions: IPv4 */
+/* IPv4 variants */
 
 struct hash_netiface4_elem_hashed {
 	__be32 ip;
@@ -147,8 +143,6 @@ struct hash_netiface4_elem_hashed {
 	u8 elem;
 };
 
-#define HKEY_DATALEN	sizeof(struct hash_netiface4_elem_hashed)
-
 /* Member elements without timeout */
 struct hash_netiface4_elem {
 	__be32 ip;
@@ -159,8 +153,7 @@ struct hash_netiface4_elem {
 	const char *iface;
 };
 
-/* Member elements with timeout support */
-struct hash_netiface4_telem {
+struct hash_netiface4t_elem {
 	__be32 ip;
 	u8 physdev;
 	u8 cidr;
@@ -170,6 +163,8 @@ struct hash_netiface4_telem {
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_netiface4_data_equal(const struct hash_netiface4_elem *ip1,
 			  const struct hash_netiface4_elem *ip2,
@@ -182,38 +177,22 @@ hash_netiface4_data_equal(const struct hash_netiface4_elem *ip1,
 	       ip1->iface == ip2->iface;
 }
 
-static inline bool
-hash_netiface4_data_isnull(const struct hash_netiface4_elem *elem)
+static inline int
+hash_netiface4_do_data_match(const struct hash_netiface4_elem *elem)
 {
-	return elem->elem == 0;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
-hash_netiface4_data_copy(struct hash_netiface4_elem *dst,
-			 const struct hash_netiface4_elem *src)
+hash_netiface4_data_set_flags(struct hash_netiface4_elem *elem, u32 flags)
 {
-	memcpy(dst, src, sizeof(*dst));
+	elem->nomatch = (flags >> 16) & IPSET_FLAG_NOMATCH;
 }
 
 static inline void
-hash_netiface4_data_flags(struct hash_netiface4_elem *dst, u32 flags)
+hash_netiface4_data_reset_flags(struct hash_netiface4_elem *elem, u8 *flags)
 {
-	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
-}
-
-static inline void
-hash_netiface4_data_reset_flags(struct hash_netiface4_elem *dst, u32 *flags)
-{
-	if (dst->nomatch) {
-		*flags = IPSET_FLAG_NOMATCH;
-		dst->nomatch = 0;
-	}
-}
-
-static inline int
-hash_netiface4_data_match(const struct hash_netiface4_elem *elem)
-{
-	return elem->nomatch ? -ENOTEMPTY : 1;
+	swap(*flags, elem->nomatch);
 }
 
 static inline void
@@ -223,12 +202,6 @@ hash_netiface4_data_netmask(struct hash_netiface4_elem *elem, u8 cidr)
 	elem->cidr = cidr;
 }
 
-static inline void
-hash_netiface4_data_zero_out(struct hash_netiface4_elem *elem)
-{
-	elem->elem = 0;
-}
-
 static bool
 hash_netiface4_data_list(struct sk_buff *skb,
 			 const struct hash_netiface4_elem *data)
@@ -249,66 +222,40 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_netiface4_data_tlist(struct sk_buff *skb,
-			  const struct hash_netiface4_elem *data)
+static inline void
+hash_netiface4_data_next(struct hash_netiface4_elem *next,
+			 const struct hash_netiface4_elem *d)
 {
-	const struct hash_netiface4_telem *tdata =
-		(const struct hash_netiface4_telem *)data;
-	u32 flags = data->physdev ? IPSET_FLAG_PHYSDEV : 0;
-
-	if (data->nomatch)
-		flags |= IPSET_FLAG_NOMATCH;
-	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip) ||
-	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr) ||
-	    nla_put_string(skb, IPSET_ATTR_IFACE, data->iface) ||
-	    (flags &&
-	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(tdata->timeout))))
-		goto nla_put_failure;
-
-	return 0;
-
-nla_put_failure:
-	return 1;
+	next->ip = d->ip;
 }
 
-#define IP_SET_HASH_WITH_NETS
-#define IP_SET_HASH_WITH_RBTREE
-#define IP_SET_HASH_WITH_MULTI
-
+#define MTYPE		hash_netiface4
 #define PF		4
 #define HOST_MASK	32
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_netiface4_data_next(struct ip_set_hash *h,
-			 const struct hash_netiface4_elem *d)
-{
-	h->next.ip = d->ip;
-}
+#define HKEY_DATALEN	sizeof(struct hash_netiface4_elem_hashed)
+#include "ip_set_hash_gen.h"
 
 static int
 hash_netiface4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		    const struct xt_action_param *par,
-		    enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		    enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	struct ip_set_hash *h = set->data;
+	struct hash_netiface *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netiface4_elem data = {
+	struct hash_netiface4_elem e = {
 		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK,
 		.elem = 1,
 	};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 	int ret;
 
-	if (data.cidr == 0)
+	if (e.cidr == 0)
 		return -EINVAL;
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK;
+		e.cidr = HOST_MASK;
 
-	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
-	data.ip &= ip_set_netmask(data.cidr);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip);
+	e.ip &= ip_set_netmask(e.cidr);
 
 #define IFACE(dir)	(par->dir ? par->dir->name : NULL)
 #define PHYSDEV(dir)	(nf_bridge->dir ? nf_bridge->dir->name : NULL)
@@ -320,38 +267,38 @@ hash_netiface4_kadt(struct ip_set *set, const struct sk_buff *skb,
 
 		if (!nf_bridge)
 			return -EINVAL;
-		data.iface = SRCDIR ? PHYSDEV(physindev) : PHYSDEV(physoutdev);
-		data.physdev = 1;
+		e.iface = SRCDIR ? PHYSDEV(physindev) : PHYSDEV(physoutdev);
+		e.physdev = 1;
 #else
-		data.iface = NULL;
+		e.iface = NULL;
 #endif
 	} else
-		data.iface = SRCDIR ? IFACE(in) : IFACE(out);
+		e.iface = SRCDIR ? IFACE(in) : IFACE(out);
 
-	if (!data.iface)
+	if (!e.iface)
 		return -EINVAL;
-	ret = iface_test(&h->rbtree, &data.iface);
+	ret = iface_test(&h->rbtree, &e.iface);
 	if (adt == IPSET_ADD) {
 		if (!ret) {
-			ret = iface_add(&h->rbtree, &data.iface);
+			ret = iface_add(&h->rbtree, &e.iface);
 			if (ret)
 				return ret;
 		}
 	} else if (!ret)
 		return ret;
 
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 		    enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	struct ip_set_hash *h = set->data;
+	struct hash_netiface *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netiface4_elem data = { .cidr = HOST_MASK, .elem = 1 };
+	struct hash_netiface4_elem e = { .cidr = HOST_MASK, .elem = 1 };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	u32 ip = 0, ip_to, last;
-	u32 timeout = h->timeout;
 	char iface[IFNAMSIZ];
 	int ret;
 
@@ -364,28 +311,23 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
 	if (tb[IPSET_ATTR_CIDR]) {
-		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-		if (data.cidr > HOST_MASK)
+		e.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+		if (e.cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 	}
 
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
-
 	strcpy(iface, nla_data(tb[IPSET_ATTR_IFACE]));
-	data.iface = iface;
-	ret = iface_test(&h->rbtree, &data.iface);
+	e.iface = iface;
+	ret = iface_test(&h->rbtree, &e.iface);
 	if (adt == IPSET_ADD) {
 		if (!ret) {
-			ret = iface_add(&h->rbtree, &data.iface);
+			ret = iface_add(&h->rbtree, &e.iface);
 			if (ret)
 				return ret;
 		}
@@ -395,13 +337,13 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_PHYSDEV)
-			data.physdev = 1;
+			e.physdev = 1;
 		if (cadt_flags & IPSET_FLAG_NOMATCH)
 			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 	if (adt == IPSET_TEST || !tb[IPSET_ATTR_IP_TO]) {
-		data.ip = htonl(ip & ip_set_hostmask(data.cidr));
-		ret = adtfn(set, &data, timeout, flags);
+		e.ip = htonl(ip & ip_set_hostmask(e.cidr));
+		ret = adtfn(set, &e, &ext, &ext, flags);
 		return ip_set_enomatch(ret, flags, adt) ? 1 :
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
@@ -414,16 +356,15 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 			swap(ip, ip_to);
 		if (ip + UINT_MAX == ip_to)
 			return -IPSET_ERR_HASH_RANGE;
-	} else {
-		ip_set_mask_from_to(ip, ip_to, data.cidr);
-	}
+	} else
+		ip_set_mask_from_to(ip, ip_to, e.cidr);
 
 	if (retried)
 		ip = ntohl(h->next.ip);
 	while (!after(ip, ip_to)) {
-		data.ip = htonl(ip);
-		last = ip_set_range_to_cidr(ip, ip_to, &data.cidr);
-		ret = adtfn(set, &data, timeout, flags);
+		e.ip = htonl(ip);
+		last = ip_set_range_to_cidr(ip, ip_to, &e.cidr);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 
 		if (ret && !ip_set_eexist(ret, flags))
 			return ret;
@@ -434,18 +375,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-static bool
-hash_netiface_same_set(const struct ip_set *a, const struct ip_set *b)
-{
-	const struct ip_set_hash *x = a->data;
-	const struct ip_set_hash *y = b->data;
-
-	/* Resizing changes htable_bits, so we ignore it */
-	return x->maxelem == y->maxelem &&
-	       x->timeout == y->timeout;
-}
-
-/* The type variant functions: IPv6 */
+/* IPv6 variants */
 
 struct hash_netiface6_elem_hashed {
 	union nf_inet_addr ip;
@@ -455,8 +385,6 @@ struct hash_netiface6_elem_hashed {
 	u8 elem;
 };
 
-#define HKEY_DATALEN	sizeof(struct hash_netiface6_elem_hashed)
-
 struct hash_netiface6_elem {
 	union nf_inet_addr ip;
 	u8 physdev;
@@ -466,7 +394,7 @@ struct hash_netiface6_elem {
 	const char *iface;
 };
 
-struct hash_netiface6_telem {
+struct hash_netiface6t_elem {
 	union nf_inet_addr ip;
 	u8 physdev;
 	u8 cidr;
@@ -476,6 +404,8 @@ struct hash_netiface6_telem {
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_netiface6_data_equal(const struct hash_netiface6_elem *ip1,
 			  const struct hash_netiface6_elem *ip2,
@@ -488,44 +418,22 @@ hash_netiface6_data_equal(const struct hash_netiface6_elem *ip1,
 	       ip1->iface == ip2->iface;
 }
 
-static inline bool
-hash_netiface6_data_isnull(const struct hash_netiface6_elem *elem)
-{
-	return elem->elem == 0;
-}
-
-static inline void
-hash_netiface6_data_copy(struct hash_netiface6_elem *dst,
-			 const struct hash_netiface6_elem *src)
-{
-	memcpy(dst, src, sizeof(*dst));
-}
-
-static inline void
-hash_netiface6_data_flags(struct hash_netiface6_elem *dst, u32 flags)
-{
-	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
-}
-
 static inline int
-hash_netiface6_data_match(const struct hash_netiface6_elem *elem)
+hash_netiface6_do_data_match(const struct hash_netiface6_elem *elem)
 {
 	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
-hash_netiface6_data_reset_flags(struct hash_netiface6_elem *dst, u32 *flags)
+hash_netiface6_data_set_flags(struct hash_netiface6_elem *elem, u32 flags)
 {
-	if (dst->nomatch) {
-		*flags = IPSET_FLAG_NOMATCH;
-		dst->nomatch = 0;
-	}
+	elem->nomatch = (flags >> 16) & IPSET_FLAG_NOMATCH;
 }
 
 static inline void
-hash_netiface6_data_zero_out(struct hash_netiface6_elem *elem)
+hash_netiface6_data_reset_flags(struct hash_netiface6_elem *elem, u8 *flags)
 {
-	elem->elem = 0;
+	swap(*flags, elem->nomatch);
 }
 
 static inline void
@@ -555,63 +463,45 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_netiface6_data_tlist(struct sk_buff *skb,
-			  const struct hash_netiface6_elem *data)
+static inline void
+hash_netiface6_data_next(struct hash_netiface4_elem *next,
+			 const struct hash_netiface6_elem *d)
 {
-	const struct hash_netiface6_telem *e =
-		(const struct hash_netiface6_telem *)data;
-	u32 flags = data->physdev ? IPSET_FLAG_PHYSDEV : 0;
-
-	if (data->nomatch)
-		flags |= IPSET_FLAG_NOMATCH;
-	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
-	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr) ||
-	    nla_put_string(skb, IPSET_ATTR_IFACE, data->iface) ||
-	    (flags &&
-	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(e->timeout))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
 }
 
+#undef MTYPE
 #undef PF
 #undef HOST_MASK
+#undef HKEY_DATALEN
 
+#define MTYPE		hash_netiface6
 #define PF		6
 #define HOST_MASK	128
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_netiface6_data_next(struct ip_set_hash *h,
-			 const struct hash_netiface6_elem *d)
-{
-}
+#define HKEY_DATALEN	sizeof(struct hash_netiface6_elem_hashed)
+#define IP_SET_EMIT_CREATE
+#include "ip_set_hash_gen.h"
 
 static int
 hash_netiface6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		    const struct xt_action_param *par,
-		    enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		    enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	struct ip_set_hash *h = set->data;
+	struct hash_netiface *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netiface6_elem data = {
+	struct hash_netiface6_elem e = {
 		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK,
 		.elem = 1,
 	};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 	int ret;
 
-	if (data.cidr == 0)
+	if (e.cidr == 0)
 		return -EINVAL;
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK;
+		e.cidr = HOST_MASK;
 
-	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
-	ip6_netmask(&data.ip, data.cidr);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip.in6);
+	ip6_netmask(&e.ip, e.cidr);
 
 	if (opt->cmdflags & IPSET_FLAG_PHYSDEV) {
 #ifdef CONFIG_BRIDGE_NETFILTER
@@ -619,37 +509,37 @@ hash_netiface6_kadt(struct ip_set *set, const struct sk_buff *skb,
 
 		if (!nf_bridge)
 			return -EINVAL;
-		data.iface = SRCDIR ? PHYSDEV(physindev) : PHYSDEV(physoutdev);
-		data.physdev = 1;
+		e.iface = SRCDIR ? PHYSDEV(physindev) : PHYSDEV(physoutdev);
+		e.physdev = 1;
 #else
-		data.iface = NULL;
+		e.iface = NULL;
 #endif
 	} else
-		data.iface = SRCDIR ? IFACE(in) : IFACE(out);
+		e.iface = SRCDIR ? IFACE(in) : IFACE(out);
 
-	if (!data.iface)
+	if (!e.iface)
 		return -EINVAL;
-	ret = iface_test(&h->rbtree, &data.iface);
+	ret = iface_test(&h->rbtree, &e.iface);
 	if (adt == IPSET_ADD) {
 		if (!ret) {
-			ret = iface_add(&h->rbtree, &data.iface);
+			ret = iface_add(&h->rbtree, &e.iface);
 			if (ret)
 				return ret;
 		}
 	} else if (!ret)
 		return ret;
 
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 		   enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	struct ip_set_hash *h = set->data;
+	struct hash_netiface *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netiface6_elem data = { .cidr = HOST_MASK, .elem = 1 };
-	u32 timeout = h->timeout;
+	struct hash_netiface6_elem e = { .cidr = HOST_MASK, .elem = 1 };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	char iface[IFNAMSIZ];
 	int ret;
 
@@ -664,28 +554,23 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &data.ip);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
 	if (tb[IPSET_ATTR_CIDR])
-		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-	if (data.cidr > HOST_MASK)
+		e.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+	if (e.cidr > HOST_MASK)
 		return -IPSET_ERR_INVALID_CIDR;
-	ip6_netmask(&data.ip, data.cidr);
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+	ip6_netmask(&e.ip, e.cidr);
 
 	strcpy(iface, nla_data(tb[IPSET_ATTR_IFACE]));
-	data.iface = iface;
-	ret = iface_test(&h->rbtree, &data.iface);
+	e.iface = iface;
+	ret = iface_test(&h->rbtree, &e.iface);
 	if (adt == IPSET_ADD) {
 		if (!ret) {
-			ret = iface_add(&h->rbtree, &data.iface);
+			ret = iface_add(&h->rbtree, &e.iface);
 			if (ret)
 				return ret;
 		}
@@ -695,93 +580,17 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_PHYSDEV)
-			data.physdev = 1;
+			e.physdev = 1;
 		if (cadt_flags & IPSET_FLAG_NOMATCH)
 			flags |= (IPSET_FLAG_NOMATCH << 16);
 	}
 
-	ret = adtfn(set, &data, timeout, flags);
+	ret = adtfn(set, &e, &ext, &ext, flags);
 
 	return ip_set_enomatch(ret, flags, adt) ? 1 :
 	       ip_set_eexist(ret, flags) ? 0 : ret;
 }
 
-/* Create hash:ip type of sets */
-
-static int
-hash_netiface_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
-{
-	struct ip_set_hash *h;
-	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
-	u8 hbits;
-	size_t hsize;
-
-	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
-		return -IPSET_ERR_INVALID_FAMILY;
-
-	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_MAXELEM) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
-		return -IPSET_ERR_PROTOCOL;
-
-	if (tb[IPSET_ATTR_HASHSIZE]) {
-		hashsize = ip_set_get_h32(tb[IPSET_ATTR_HASHSIZE]);
-		if (hashsize < IPSET_MIMINAL_HASHSIZE)
-			hashsize = IPSET_MIMINAL_HASHSIZE;
-	}
-
-	if (tb[IPSET_ATTR_MAXELEM])
-		maxelem = ip_set_get_h32(tb[IPSET_ATTR_MAXELEM]);
-
-	h = kzalloc(sizeof(*h)
-		    + sizeof(struct ip_set_hash_nets)
-		      * (set->family == NFPROTO_IPV4 ? 32 : 128), GFP_KERNEL);
-	if (!h)
-		return -ENOMEM;
-
-	h->maxelem = maxelem;
-	get_random_bytes(&h->initval, sizeof(h->initval));
-	h->timeout = IPSET_NO_TIMEOUT;
-	h->ahash_max = AHASH_MAX_SIZE;
-
-	hbits = htable_bits(hashsize);
-	hsize = htable_size(hbits);
-	if (hsize == 0) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table = ip_set_alloc(hsize);
-	if (!h->table) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table->htable_bits = hbits;
-	h->rbtree = RB_ROOT;
-
-	set->data = h;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_netiface4_tvariant : &hash_netiface6_tvariant;
-
-		if (set->family == NFPROTO_IPV4)
-			hash_netiface4_gc_init(set);
-		else
-			hash_netiface6_gc_init(set);
-	} else {
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_netiface4_variant : &hash_netiface6_variant;
-	}
-
-	pr_debug("create %s hashsize %u (%u) maxelem %u: %p(%p)\n",
-		 set->name, jhash_size(h->table->htable_bits),
-		 h->table->htable_bits, h->maxelem, set->data, h->table);
-
-	return 0;
-}
-
 static struct ip_set_type hash_netiface_type __read_mostly = {
 	.name		= "hash:net,iface",
 	.protocol	= IPSET_PROTOCOL,
@@ -799,6 +608,7 @@ static struct ip_set_type hash_netiface_type __read_mostly = {
 		[IPSET_ATTR_RESIZE]	= { .type = NLA_U8  },
 		[IPSET_ATTR_PROTO]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index cd1d3c1..43b1f1e 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+/* Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -20,7 +20,6 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/ipset/pfxlen.h>
 #include <linux/netfilter/ipset/ip_set.h>
-#include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_getport.h>
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
@@ -35,15 +34,9 @@ IP_SET_MODULE_DESC("hash:net,port", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_hash:net,port");
 
 /* Type specific function prefix */
-#define TYPE		hash_netport
-
-static bool
-hash_netport_same_set(const struct ip_set *a, const struct ip_set *b);
-
-#define hash_netport4_same_set	hash_netport_same_set
-#define hash_netport6_same_set	hash_netport_same_set
-
-/* The type variant functions: IPv4 */
+#define HTYPE		hash_netport
+#define IP_SET_HASH_WITH_PROTO
+#define IP_SET_HASH_WITH_NETS
 
 /* We squeeze the "nomatch" flag into cidr: we don't support cidr == 0
  * However this way we have to store internally cidr - 1,
@@ -51,7 +44,9 @@ hash_netport_same_set(const struct ip_set *a, const struct ip_set *b);
  */
 #define IP_SET_HASH_WITH_NETS_PACKED
 
-/* Member elements without timeout */
+/* IPv4 variants */
+
+/* Member elements */
 struct hash_netport4_elem {
 	__be32 ip;
 	__be16 port;
@@ -60,8 +55,7 @@ struct hash_netport4_elem {
 	u8 nomatch:1;
 };
 
-/* Member elements with timeout support */
-struct hash_netport4_telem {
+struct hash_netport4t_elem {
 	__be32 ip;
 	__be16 port;
 	u8 proto;
@@ -70,6 +64,8 @@ struct hash_netport4_telem {
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_netport4_data_equal(const struct hash_netport4_elem *ip1,
 			 const struct hash_netport4_elem *ip2,
@@ -81,42 +77,22 @@ hash_netport4_data_equal(const struct hash_netport4_elem *ip1,
 	       ip1->cidr == ip2->cidr;
 }
 
-static inline bool
-hash_netport4_data_isnull(const struct hash_netport4_elem *elem)
+static inline int
+hash_netport4_do_data_match(const struct hash_netport4_elem *elem)
 {
-	return elem->proto == 0;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
-hash_netport4_data_copy(struct hash_netport4_elem *dst,
-			const struct hash_netport4_elem *src)
+hash_netport4_data_set_flags(struct hash_netport4_elem *elem, u32 flags)
 {
-	dst->ip = src->ip;
-	dst->port = src->port;
-	dst->proto = src->proto;
-	dst->cidr = src->cidr;
-	dst->nomatch = src->nomatch;
+	elem->nomatch = !!((flags >> 16) & IPSET_FLAG_NOMATCH);
 }
 
 static inline void
-hash_netport4_data_flags(struct hash_netport4_elem *dst, u32 flags)
+hash_netport4_data_reset_flags(struct hash_netport4_elem *elem, u8 *flags)
 {
-	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
-}
-
-static inline void
-hash_netport4_data_reset_flags(struct hash_netport4_elem *dst, u32 *flags)
-{
-	if (dst->nomatch) {
-		*flags = IPSET_FLAG_NOMATCH;
-		dst->nomatch = 0;
-	}
-}
-
-static inline int
-hash_netport4_data_match(const struct hash_netport4_elem *elem)
-{
-	return elem->nomatch ? -ENOTEMPTY : 1;
+	swap(*flags, elem->nomatch);
 }
 
 static inline void
@@ -126,12 +102,6 @@ hash_netport4_data_netmask(struct hash_netport4_elem *elem, u8 cidr)
 	elem->cidr = cidr - 1;
 }
 
-static inline void
-hash_netport4_data_zero_out(struct hash_netport4_elem *elem)
-{
-	elem->proto = 0;
-}
-
 static bool
 hash_netport4_data_list(struct sk_buff *skb,
 			const struct hash_netport4_elem *data)
@@ -151,77 +121,53 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_netport4_data_tlist(struct sk_buff *skb,
-			 const struct hash_netport4_elem *data)
+static inline void
+hash_netport4_data_next(struct hash_netport4_elem *next,
+			const struct hash_netport4_elem *d)
 {
-	const struct hash_netport4_telem *tdata =
-		(const struct hash_netport4_telem *)data;
-	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
-
-	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, tdata->ip) ||
-	    nla_put_net16(skb, IPSET_ATTR_PORT, tdata->port) ||
-	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr + 1) ||
-	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(tdata->timeout))) ||
-	    (flags &&
-	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
+	next->ip = d->ip;
+	next->port = d->port;
 }
 
-#define IP_SET_HASH_WITH_PROTO
-#define IP_SET_HASH_WITH_NETS
-
+#define MTYPE		hash_netport4
 #define PF		4
 #define HOST_MASK	32
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_netport4_data_next(struct ip_set_hash *h,
-			const struct hash_netport4_elem *d)
-{
-	h->next.ip = d->ip;
-	h->next.port = d->port;
-}
+#include "ip_set_hash_gen.h"
 
 static int
 hash_netport4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		   const struct xt_action_param *par,
-		   enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		   enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_netport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netport4_elem data = {
+	struct hash_netport4_elem e = {
 		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1
 	};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK - 1;
+		e.cidr = HOST_MASK - 1;
 
 	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
-				 &data.port, &data.proto))
+				 &e.port, &e.proto))
 		return -EINVAL;
 
-	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
-	data.ip &= ip_set_netmask(data.cidr + 1);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip);
+	e.ip &= ip_set_netmask(e.cidr + 1);
 
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		   enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_netport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netport4_elem data = { .cidr = HOST_MASK - 1 };
+	struct hash_netport4_elem e = { .cidr = HOST_MASK - 1 };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	u32 port, port_to, p = 0, ip = 0, ip_to, last;
-	u32 timeout = h->timeout;
 	bool with_ports = false;
 	u8 cidr;
 	int ret;
@@ -236,7 +182,8 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -244,31 +191,25 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
-		data.cidr = cidr - 1;
+		e.cidr = cidr - 1;
 	}
 
 	if (tb[IPSET_ATTR_PORT])
-		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
+		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 	else
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_PROTO]) {
-		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
-		with_ports = ip_set_proto_with_ports(data.proto);
+		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(e.proto);
 
-		if (data.proto == 0)
+		if (e.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	if (!(with_ports || data.proto == IPPROTO_ICMP))
-		data.port = 0;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+	if (!(with_ports || e.proto == IPPROTO_ICMP))
+		e.port = 0;
 
 	with_ports = with_ports && tb[IPSET_ATTR_PORT_TO];
 
@@ -279,13 +220,13 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (adt == IPSET_TEST || !(with_ports || tb[IPSET_ATTR_IP_TO])) {
-		data.ip = htonl(ip & ip_set_hostmask(data.cidr + 1));
-		ret = adtfn(set, &data, timeout, flags);
+		e.ip = htonl(ip & ip_set_hostmask(e.cidr + 1));
+		ret = adtfn(set, &e, &ext, &ext, flags);
 		return ip_set_enomatch(ret, flags, adt) ? 1 :
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
-	port = port_to = ntohs(data.port);
+	port = port_to = ntohs(e.port);
 	if (tb[IPSET_ATTR_PORT_TO]) {
 		port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 		if (port_to < port)
@@ -299,21 +240,20 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 			swap(ip, ip_to);
 		if (ip + UINT_MAX == ip_to)
 			return -IPSET_ERR_HASH_RANGE;
-	} else {
-		ip_set_mask_from_to(ip, ip_to, data.cidr + 1);
-	}
+	} else
+		ip_set_mask_from_to(ip, ip_to, e.cidr + 1);
 
 	if (retried)
 		ip = ntohl(h->next.ip);
 	while (!after(ip, ip_to)) {
-		data.ip = htonl(ip);
+		e.ip = htonl(ip);
 		last = ip_set_range_to_cidr(ip, ip_to, &cidr);
-		data.cidr = cidr - 1;
+		e.cidr = cidr - 1;
 		p = retried && ip == ntohl(h->next.ip) ? ntohs(h->next.port)
 						       : port;
 		for (; p <= port_to; p++) {
-			data.port = htons(p);
-			ret = adtfn(set, &data, timeout, flags);
+			e.port = htons(p);
+			ret = adtfn(set, &e, &ext, &ext, flags);
 
 			if (ret && !ip_set_eexist(ret, flags))
 				return ret;
@@ -325,18 +265,7 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-static bool
-hash_netport_same_set(const struct ip_set *a, const struct ip_set *b)
-{
-	const struct ip_set_hash *x = a->data;
-	const struct ip_set_hash *y = b->data;
-
-	/* Resizing changes htable_bits, so we ignore it */
-	return x->maxelem == y->maxelem &&
-	       x->timeout == y->timeout;
-}
-
-/* The type variant functions: IPv6 */
+/* IPv6 variants */
 
 struct hash_netport6_elem {
 	union nf_inet_addr ip;
@@ -346,7 +275,7 @@ struct hash_netport6_elem {
 	u8 nomatch:1;
 };
 
-struct hash_netport6_telem {
+struct hash_netport6t_elem {
 	union nf_inet_addr ip;
 	__be16 port;
 	u8 proto;
@@ -355,6 +284,8 @@ struct hash_netport6_telem {
 	unsigned long timeout;
 };
 
+/* Common functions */
+
 static inline bool
 hash_netport6_data_equal(const struct hash_netport6_elem *ip1,
 			 const struct hash_netport6_elem *ip2,
@@ -366,44 +297,22 @@ hash_netport6_data_equal(const struct hash_netport6_elem *ip1,
 	       ip1->cidr == ip2->cidr;
 }
 
-static inline bool
-hash_netport6_data_isnull(const struct hash_netport6_elem *elem)
-{
-	return elem->proto == 0;
-}
-
-static inline void
-hash_netport6_data_copy(struct hash_netport6_elem *dst,
-			const struct hash_netport6_elem *src)
-{
-	memcpy(dst, src, sizeof(*dst));
-}
-
-static inline void
-hash_netport6_data_flags(struct hash_netport6_elem *dst, u32 flags)
+static inline int
+hash_netport6_do_data_match(const struct hash_netport6_elem *elem)
 {
-	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
-hash_netport6_data_reset_flags(struct hash_netport6_elem *dst, u32 *flags)
-{
-	if (dst->nomatch) {
-		*flags = IPSET_FLAG_NOMATCH;
-		dst->nomatch = 0;
-	}
-}
-
-static inline int
-hash_netport6_data_match(const struct hash_netport6_elem *elem)
+hash_netport6_data_set_flags(struct hash_netport6_elem *elem, u32 flags)
 {
-	return elem->nomatch ? -ENOTEMPTY : 1;
+	elem->nomatch = !!((flags >> 16) & IPSET_FLAG_NOMATCH);
 }
 
 static inline void
-hash_netport6_data_zero_out(struct hash_netport6_elem *elem)
+hash_netport6_data_reset_flags(struct hash_netport6_elem *elem, u8 *flags)
 {
-	elem->proto = 0;
+	swap(*flags, elem->nomatch);
 }
 
 static inline void
@@ -432,76 +341,57 @@ nla_put_failure:
 	return 1;
 }
 
-static bool
-hash_netport6_data_tlist(struct sk_buff *skb,
-			 const struct hash_netport6_elem *data)
+static inline void
+hash_netport6_data_next(struct hash_netport4_elem *next,
+			const struct hash_netport6_elem *d)
 {
-	const struct hash_netport6_telem *e =
-		(const struct hash_netport6_telem *)data;
-	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
-
-	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6) ||
-	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
-	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr + 1) ||
-	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto) ||
-	    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			  htonl(ip_set_timeout_get(e->timeout))) ||
-	    (flags &&
-	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
-		goto nla_put_failure;
-	return 0;
-
-nla_put_failure:
-	return 1;
+	next->port = d->port;
 }
 
+#undef MTYPE
 #undef PF
 #undef HOST_MASK
 
+#define MTYPE		hash_netport6
 #define PF		6
 #define HOST_MASK	128
-#include <linux/netfilter/ipset/ip_set_ahash.h>
-
-static inline void
-hash_netport6_data_next(struct ip_set_hash *h,
-			const struct hash_netport6_elem *d)
-{
-	h->next.port = d->port;
-}
+#define IP_SET_EMIT_CREATE
+#include "ip_set_hash_gen.h"
 
 static int
 hash_netport6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		   const struct xt_action_param *par,
-		   enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		   enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_netport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netport6_elem data = {
+	struct hash_netport6_elem e = {
 		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1,
 	};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK - 1;
+		e.cidr = HOST_MASK - 1;
 
 	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
-				 &data.port, &data.proto))
+				 &e.port, &e.proto))
 		return -EINVAL;
 
-	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
-	ip6_netmask(&data.ip, data.cidr + 1);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip.in6);
+	ip6_netmask(&e.ip, e.cidr + 1);
 
-	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
 hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		   enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct ip_set_hash *h = set->data;
+	const struct hash_netport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netport6_elem data = { .cidr = HOST_MASK  - 1 };
+	struct hash_netport6_elem e = { .cidr = HOST_MASK  - 1 };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
 	u32 port, port_to;
-	u32 timeout = h->timeout;
 	bool with_ports = false;
 	u8 cidr;
 	int ret;
@@ -518,7 +408,8 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &data.ip);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -526,32 +417,26 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
-		data.cidr = cidr - 1;
+		e.cidr = cidr - 1;
 	}
-	ip6_netmask(&data.ip, data.cidr + 1);
+	ip6_netmask(&e.ip, e.cidr + 1);
 
 	if (tb[IPSET_ATTR_PORT])
-		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
+		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 	else
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_PROTO]) {
-		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
-		with_ports = ip_set_proto_with_ports(data.proto);
+		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(e.proto);
 
-		if (data.proto == 0)
+		if (e.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	if (!(with_ports || data.proto == IPPROTO_ICMPV6))
-		data.port = 0;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(h->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+	if (!(with_ports || e.proto == IPPROTO_ICMPV6))
+		e.port = 0;
 
 	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
@@ -560,12 +445,12 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
-		ret = adtfn(set, &data, timeout, flags);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 		return ip_set_enomatch(ret, flags, adt) ? 1 :
 		       ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
-	port = ntohs(data.port);
+	port = ntohs(e.port);
 	port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 	if (port > port_to)
 		swap(port, port_to);
@@ -573,8 +458,8 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (retried)
 		port = ntohs(h->next.port);
 	for (; port <= port_to; port++) {
-		data.port = htons(port);
-		ret = adtfn(set, &data, timeout, flags);
+		e.port = htons(port);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 
 		if (ret && !ip_set_eexist(ret, flags))
 			return ret;
@@ -584,80 +469,6 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-/* Create hash:ip type of sets */
-
-static int
-hash_netport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
-{
-	struct ip_set_hash *h;
-	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
-	u8 hbits;
-	size_t hsize;
-
-	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
-		return -IPSET_ERR_INVALID_FAMILY;
-
-	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_MAXELEM) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
-		return -IPSET_ERR_PROTOCOL;
-
-	if (tb[IPSET_ATTR_HASHSIZE]) {
-		hashsize = ip_set_get_h32(tb[IPSET_ATTR_HASHSIZE]);
-		if (hashsize < IPSET_MIMINAL_HASHSIZE)
-			hashsize = IPSET_MIMINAL_HASHSIZE;
-	}
-
-	if (tb[IPSET_ATTR_MAXELEM])
-		maxelem = ip_set_get_h32(tb[IPSET_ATTR_MAXELEM]);
-
-	h = kzalloc(sizeof(*h)
-		    + sizeof(struct ip_set_hash_nets)
-		      * (set->family == NFPROTO_IPV4 ? 32 : 128), GFP_KERNEL);
-	if (!h)
-		return -ENOMEM;
-
-	h->maxelem = maxelem;
-	get_random_bytes(&h->initval, sizeof(h->initval));
-	h->timeout = IPSET_NO_TIMEOUT;
-
-	hbits = htable_bits(hashsize);
-	hsize = htable_size(hbits);
-	if (hsize == 0) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table = ip_set_alloc(hsize);
-	if (!h->table) {
-		kfree(h);
-		return -ENOMEM;
-	}
-	h->table->htable_bits = hbits;
-
-	set->data = h;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_netport4_tvariant : &hash_netport6_tvariant;
-
-		if (set->family == NFPROTO_IPV4)
-			hash_netport4_gc_init(set);
-		else
-			hash_netport6_gc_init(set);
-	} else {
-		set->variant = set->family == NFPROTO_IPV4
-			? &hash_netport4_variant : &hash_netport6_variant;
-	}
-
-	pr_debug("create %s hashsize %u (%u) maxelem %u: %p(%p)\n",
-		 set->name, jhash_size(h->table->htable_bits),
-		 h->table->htable_bits, h->maxelem, set->data, h->table);
-
-	return 0;
-}
-
 static struct ip_set_type hash_netport_type __read_mostly = {
 	.name		= "hash:net,port",
 	.protocol	= IPSET_PROTOCOL,
@@ -674,6 +485,7 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 		[IPSET_ATTR_RESIZE]	= { .type = NLA_U8  },
 		[IPSET_ATTR_PROTO]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
-- 
1.7.10.4
