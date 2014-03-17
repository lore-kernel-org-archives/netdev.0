From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/38] netfilter: ipset: add markmask for hash:ip,mark data type
Date: Mon, 17 Mar 2014 13:42:33 +0100
Message-ID: <1395060178-11833-14-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59377 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933109AbaCQMnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:37 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vytas Dauksa <vytas.dauksa@smoothwall.net>

Introduce packet mark mask for hash:ip,mark data type. This allows to
set mark bit filter for the ip set.

Change-Id: Id8dd9ca7e64477c4f7b022a1d9c1a5b187f1c96e

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/uapi/linux/netfilter/ipset/ip_set.h |    2 ++
 net/netfilter/ipset/ip_set_hash_gen.h       |   31 +++++++++++++++++++++++++++
 net/netfilter/ipset/ip_set_hash_ipmark.c    |    9 ++++++++
 3 files changed, 42 insertions(+)

diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index 5368f82..f636f28 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -89,6 +89,7 @@ enum {
 	IPSET_ATTR_GC,
 	IPSET_ATTR_HASHSIZE,
 	IPSET_ATTR_MAXELEM,
+	IPSET_ATTR_MARKMASK,
 	IPSET_ATTR_NETMASK,
 	IPSET_ATTR_PROBES,
 	IPSET_ATTR_RESIZE,
@@ -138,6 +139,7 @@ enum ipset_errno {
 	IPSET_ERR_EXIST,
 	IPSET_ERR_INVALID_CIDR,
 	IPSET_ERR_INVALID_NETMASK,
+	IPSET_ERR_INVALID_MARKMASK,
 	IPSET_ERR_INVALID_FAMILY,
 	IPSET_ERR_TIMEOUT,
 	IPSET_ERR_REFERENCED,
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index be6932a..b1eed81 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -263,6 +263,9 @@ struct htype {
 	u32 maxelem;		/* max elements in the hash */
 	u32 elements;		/* current element (vs timeout) */
 	u32 initval;		/* random jhash init value */
+#ifdef IP_SET_HASH_WITH_MARKMASK
+	u32 markmask;		/* markmask value for mark mask to store */
+#endif
 	struct timer_list gc;	/* garbage collection when timeout enabled */
 	struct mtype_elem next; /* temporary storage for uadd */
 #ifdef IP_SET_HASH_WITH_MULTI
@@ -454,6 +457,9 @@ mtype_same_set(const struct ip_set *a, const struct ip_set *b)
 #ifdef IP_SET_HASH_WITH_NETMASK
 	       x->netmask == y->netmask &&
 #endif
+#ifdef IP_SET_HASH_WITH_MARKMASK
+	       x->markmask == y->markmask &&
+#endif
 	       a->extensions == b->extensions;
 }
 
@@ -908,6 +914,10 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 	    nla_put_u8(skb, IPSET_ATTR_NETMASK, h->netmask))
 		goto nla_put_failure;
 #endif
+#ifdef IP_SET_HASH_WITH_MARKMASK
+	if (nla_put_u32(skb, IPSET_ATTR_MARKMASK, h->markmask))
+		goto nla_put_failure;
+#endif
 	if (nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE, htonl(memsize)))
 		goto nla_put_failure;
@@ -1016,6 +1026,9 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 			    struct nlattr *tb[], u32 flags)
 {
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
+#ifdef IP_SET_HASH_WITH_MARKMASK
+	u32 markmask;
+#endif
 	u8 hbits;
 #ifdef IP_SET_HASH_WITH_NETMASK
 	u8 netmask;
@@ -1026,6 +1039,10 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 
 	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
+
+#ifdef IP_SET_HASH_WITH_MARKMASK
+	markmask = 0xffffffff;
+#endif
 #ifdef IP_SET_HASH_WITH_NETMASK
 	netmask = set->family == NFPROTO_IPV4 ? 32 : 128;
 	pr_debug("Create set %s with family %s\n",
@@ -1034,6 +1051,9 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_MAXELEM) ||
+#ifdef IP_SET_HASH_WITH_MARKMASK
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_MARKMASK) ||
+#endif
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
@@ -1057,6 +1077,14 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 			return -IPSET_ERR_INVALID_NETMASK;
 	}
 #endif
+#ifdef IP_SET_HASH_WITH_MARKMASK
+	if (tb[IPSET_ATTR_MARKMASK]) {
+		markmask = ntohl(nla_get_u32(tb[IPSET_ATTR_MARKMASK]));
+
+		if ((markmask > 4294967295u) || markmask == 0)
+			return -IPSET_ERR_INVALID_MARKMASK;
+	}
+#endif
 
 	hsize = sizeof(*h);
 #ifdef IP_SET_HASH_WITH_NETS
@@ -1071,6 +1099,9 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 #ifdef IP_SET_HASH_WITH_NETMASK
 	h->netmask = netmask;
 #endif
+#ifdef IP_SET_HASH_WITH_MARKMASK
+	h->markmask = markmask;
+#endif
 	get_random_bytes(&h->initval, sizeof(h->initval));
 	set->timeout = IPSET_NO_TIMEOUT;
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index e56c0d9..1bf8e85 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -34,6 +34,7 @@ MODULE_ALIAS("ip_set_hash:ip,mark");
 
 /* Type specific function prefix */
 #define HTYPE		hash_ipmark
+#define IP_SET_HASH_WITH_MARKMASK
 
 /* IPv4 variant */
 
@@ -85,11 +86,13 @@ hash_ipmark4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
 		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
+	const struct hash_ipmark *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipmark4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	e.mark = skb->mark;
+	e.mark &= h->markmask;
 
 	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip);
 	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
@@ -122,6 +125,7 @@ hash_ipmark4_uadt(struct ip_set *set, struct nlattr *tb[],
 		return ret;
 
 	e.mark = ntohl(nla_get_u32(tb[IPSET_ATTR_MARK]));
+	e.mark &= h->markmask;
 
 	if (adt == IPSET_TEST ||
 	    !(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_CIDR])) {
@@ -213,11 +217,13 @@ hash_ipmark6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
 		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
+	const struct hash_ipmark *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipmark6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	e.mark = skb->mark;
+	e.mark &= h->markmask;
 
 	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip.in6);
 	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
@@ -227,6 +233,7 @@ static int
 hash_ipmark6_uadt(struct ip_set *set, struct nlattr *tb[],
 		  enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
+	const struct hash_ipmark *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipmark6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -250,6 +257,7 @@ hash_ipmark6_uadt(struct ip_set *set, struct nlattr *tb[],
 		return ret;
 
 	e.mark = ntohl(nla_get_u32(tb[IPSET_ATTR_MARK]));
+	e.mark &= h->markmask;
 
 	if (adt == IPSET_TEST) {
 		ret = adtfn(set, &e, &ext, &ext, flags);
@@ -275,6 +283,7 @@ static struct ip_set_type hash_ipmark_type __read_mostly = {
 	.revision_max	= IPSET_TYPE_REV_MAX,
 	.create		= hash_ipmark_create,
 	.create_policy	= {
+		[IPSET_ATTR_MARKMASK]	= { .type = NLA_U32 },
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
 		[IPSET_ATTR_MAXELEM]	= { .type = NLA_U32 },
 		[IPSET_ATTR_PROBES]	= { .type = NLA_U8 },
-- 
1.7.10.4
