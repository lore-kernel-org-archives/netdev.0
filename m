From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/33] netfilter: ipset: Add hash:net,net module to kernel.
Date: Fri,  4 Oct 2013 10:33:05 +0200
Message-ID: <1380875598-5250-21-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>

This adds a new set that provides the ability to configure pairs of
subnets. A small amount of additional handling code has been added to
the generic hash header file - this code is conditionally activated by a
preprocessor definition.

Signed-off-by: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/Kconfig              |    9 +
 net/netfilter/ipset/Makefile             |    1 +
 net/netfilter/ipset/ip_set_hash_gen.h    |   58 +++-
 net/netfilter/ipset/ip_set_hash_netnet.c |  482 ++++++++++++++++++++++++++++++
 4 files changed, 541 insertions(+), 9 deletions(-)
 create mode 100644 net/netfilter/ipset/ip_set_hash_netnet.c

diff --git a/net/netfilter/ipset/Kconfig b/net/netfilter/ipset/Kconfig
index fd2c14b..9119f65 100644
--- a/net/netfilter/ipset/Kconfig
+++ b/net/netfilter/ipset/Kconfig
@@ -99,6 +99,15 @@ config IP_SET_HASH_NET
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_SET_HASH_NETNET
+	tristate "hash:net,net set support"
+	depends on IP_SET
+	help
+	  This option adds the hash:net,net  set type support, by which
+	  one can store IPv4/IPv6 network address/prefix pairs in a set.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP_SET_HASH_NETPORT
 	tristate "hash:net,port set support"
 	depends on IP_SET
diff --git a/net/netfilter/ipset/Makefile b/net/netfilter/ipset/Makefile
index 6e965ec..43eef7a 100644
--- a/net/netfilter/ipset/Makefile
+++ b/net/netfilter/ipset/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_IP_SET_HASH_IPPORTNET) += ip_set_hash_ipportnet.o
 obj-$(CONFIG_IP_SET_HASH_NET) += ip_set_hash_net.o
 obj-$(CONFIG_IP_SET_HASH_NETPORT) += ip_set_hash_netport.o
 obj-$(CONFIG_IP_SET_HASH_NETIFACE) += ip_set_hash_netiface.o
+obj-$(CONFIG_IP_SET_HASH_NETNET) += ip_set_hash_netnet.o
 
 # list types
 obj-$(CONFIG_IP_SET_LIST_SET) += ip_set_list_set.o
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 3c26e5b..6bd2eef 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -142,11 +142,16 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 }
 
 #ifdef IP_SET_HASH_WITH_NETS
+#if IPSET_NET_COUNT > 1
+#define __CIDR(cidr, i)		(cidr[i])
+#else
+#define __CIDR(cidr, i)		(cidr)
+#endif
 #ifdef IP_SET_HASH_WITH_NETS_PACKED
 /* When cidr is packed with nomatch, cidr - 1 is stored in the entry */
-#define CIDR(cidr)		(cidr + 1)
+#define CIDR(cidr, i)		(__CIDR(cidr, i) + 1)
 #else
-#define CIDR(cidr)		(cidr)
+#define CIDR(cidr, i)		(__CIDR(cidr, i))
 #endif
 
 #define SET_HOST_MASK(family)	(family == AF_INET ? 32 : 128)
@@ -210,6 +215,7 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #define mtype_do_data_match(d)	1
 #endif
 #define mtype_data_set_flags	IPSET_TOKEN(MTYPE, _data_set_flags)
+#define mtype_data_reset_elem	IPSET_TOKEN(MTYPE, _data_reset_elem)
 #define mtype_data_reset_flags	IPSET_TOKEN(MTYPE, _data_reset_flags)
 #define mtype_data_netmask	IPSET_TOKEN(MTYPE, _data_netmask)
 #define mtype_data_list		IPSET_TOKEN(MTYPE, _data_list)
@@ -461,6 +467,9 @@ mtype_expire(struct ip_set *set, struct htype *h, u8 nets_length, size_t dsize)
 	struct mtype_elem *data;
 	u32 i;
 	int j;
+#ifdef IP_SET_HASH_WITH_NETS
+	u8 k;
+#endif
 
 	rcu_read_lock_bh();
 	t = rcu_dereference_bh(h->table);
@@ -471,8 +480,9 @@ mtype_expire(struct ip_set *set, struct htype *h, u8 nets_length, size_t dsize)
 			if (ip_set_timeout_expired(ext_timeout(data, set))) {
 				pr_debug("expired %u/%u\n", i, j);
 #ifdef IP_SET_HASH_WITH_NETS
-				mtype_del_cidr(h, CIDR(data->cidr),
-					       nets_length, 0);
+				for (k = 0; k < IPSET_NET_COUNT; k++)
+					mtype_del_cidr(h, CIDR(data->cidr, k),
+						       nets_length, k);
 #endif
 				ip_set_ext_destroy(set, data);
 				if (j != n->pos - 1)
@@ -658,8 +668,12 @@ reuse_slot:
 		/* Fill out reused slot */
 		data = ahash_data(n, j, set->dsize);
 #ifdef IP_SET_HASH_WITH_NETS
-		mtype_del_cidr(h, CIDR(data->cidr), NLEN(set->family), 0);
-		mtype_add_cidr(h, CIDR(d->cidr), NLEN(set->family), 0);
+		for (i = 0; i < IPSET_NET_COUNT; i++) {
+			mtype_del_cidr(h, CIDR(data->cidr, i),
+				       NLEN(set->family), i);
+			mtype_add_cidr(h, CIDR(d->cidr, i),
+				       NLEN(set->family), i);
+		}
 #endif
 		ip_set_ext_destroy(set, data);
 	} else {
@@ -673,7 +687,9 @@ reuse_slot:
 		}
 		data = ahash_data(n, n->pos++, set->dsize);
 #ifdef IP_SET_HASH_WITH_NETS
-		mtype_add_cidr(h, CIDR(d->cidr), NLEN(set->family), 0);
+		for (i = 0; i < IPSET_NET_COUNT; i++)
+			mtype_add_cidr(h, CIDR(d->cidr, i), NLEN(set->family),
+				       i);
 #endif
 		h->elements++;
 	}
@@ -704,6 +720,9 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	struct mtype_elem *data;
 	struct hbucket *n;
 	int i, ret = -IPSET_ERR_EXIST;
+#ifdef IP_SET_HASH_WITH_NETS
+	u8 j;
+#endif
 	u32 key, multi = 0;
 
 	rcu_read_lock_bh();
@@ -725,7 +744,9 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		n->pos--;
 		h->elements--;
 #ifdef IP_SET_HASH_WITH_NETS
-		mtype_del_cidr(h, CIDR(d->cidr), NLEN(set->family), 0);
+		for (j = 0; j < IPSET_NET_COUNT; j++)
+			mtype_del_cidr(h, CIDR(d->cidr, j), NLEN(set->family),
+				       j);
 #endif
 		ip_set_ext_destroy(set, data);
 		if (n->pos + AHASH_INIT_SIZE < n->size) {
@@ -772,13 +793,26 @@ mtype_test_cidrs(struct ip_set *set, struct mtype_elem *d,
 	struct htable *t = rcu_dereference_bh(h->table);
 	struct hbucket *n;
 	struct mtype_elem *data;
+#if IPSET_NET_COUNT == 2
+	struct mtype_elem orig = *d;
+	int i, j = 0, k;
+#else
 	int i, j = 0;
+#endif
 	u32 key, multi = 0;
 	u8 nets_length = NLEN(set->family);
 
 	pr_debug("test by nets\n");
 	for (; j < nets_length && h->nets[j].nets[0] && !multi; j++) {
+#if IPSET_NET_COUNT == 2
+		mtype_data_reset_elem(d, &orig);
+		mtype_data_netmask(d, h->nets[j].cidr[0], false);
+		for (k = 0; k < nets_length && h->nets[k].nets[1] && !multi;
+		     k++) {
+			mtype_data_netmask(d, h->nets[k].cidr[1], true);
+#else
 		mtype_data_netmask(d, h->nets[j].cidr[0]);
+#endif
 		key = HKEY(d, h->initval, t->htable_bits);
 		n = hbucket(t, key);
 		for (i = 0; i < n->pos; i++) {
@@ -798,6 +832,9 @@ mtype_test_cidrs(struct ip_set *set, struct mtype_elem *d,
 				return mtype_data_match(data, ext,
 							mext, set, flags);
 		}
+#if IPSET_NET_COUNT == 2
+		}
+#endif
 	}
 	return 0;
 }
@@ -821,7 +858,10 @@ mtype_test(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 #ifdef IP_SET_HASH_WITH_NETS
 	/* If we test an IP address and not a network address,
 	 * try all possible network sizes */
-	if (CIDR(d->cidr) == SET_HOST_MASK(set->family)) {
+	for (i = 0; i < IPSET_NET_COUNT; i++)
+		if (CIDR(d->cidr, i) != SET_HOST_MASK(set->family))
+			break;
+	if (i == IPSET_NET_COUNT) {
 		ret = mtype_test_cidrs(set, d, ext, mext, flags);
 		goto out;
 	}
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
new file mode 100644
index 0000000..771ce2b
--- /dev/null
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -0,0 +1,482 @@
+/* Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ * Copyright (C) 2013 Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+/* Kernel module implementing an IP set type: the hash:net type */
+
+#include <linux/jhash.h>
+#include <linux/module.h>
+#include <linux/ip.h>
+#include <linux/skbuff.h>
+#include <linux/errno.h>
+#include <linux/random.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/netlink.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter/ipset/pfxlen.h>
+#include <linux/netfilter/ipset/ip_set.h>
+#include <linux/netfilter/ipset/ip_set_hash.h>
+
+#define IPSET_TYPE_REV_MIN	0
+#define IPSET_TYPE_REV_MAX	0
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>");
+IP_SET_MODULE_DESC("hash:net,net", IPSET_TYPE_REV_MIN, IPSET_TYPE_REV_MAX);
+MODULE_ALIAS("ip_set_hash:net,net");
+
+/* Type specific function prefix */
+#define HTYPE		hash_netnet
+#define IP_SET_HASH_WITH_NETS
+#define IPSET_NET_COUNT 2
+
+/* IPv4 variants */
+
+/* Member elements  */
+struct hash_netnet4_elem {
+	union {
+		__be32 ip[2];
+		__be64 ipcmp;
+	};
+	u8 nomatch;
+	union {
+		u8 cidr[2];
+		u16 ccmp;
+	};
+};
+
+/* Common functions */
+
+static inline bool
+hash_netnet4_data_equal(const struct hash_netnet4_elem *ip1,
+		     const struct hash_netnet4_elem *ip2,
+		     u32 *multi)
+{
+	return ip1->ipcmp == ip2->ipcmp &&
+	       ip2->ccmp == ip2->ccmp;
+}
+
+static inline int
+hash_netnet4_do_data_match(const struct hash_netnet4_elem *elem)
+{
+	return elem->nomatch ? -ENOTEMPTY : 1;
+}
+
+static inline void
+hash_netnet4_data_set_flags(struct hash_netnet4_elem *elem, u32 flags)
+{
+	elem->nomatch = (flags >> 16) & IPSET_FLAG_NOMATCH;
+}
+
+static inline void
+hash_netnet4_data_reset_flags(struct hash_netnet4_elem *elem, u8 *flags)
+{
+	swap(*flags, elem->nomatch);
+}
+
+static inline void
+hash_netnet4_data_reset_elem(struct hash_netnet4_elem *elem,
+			  struct hash_netnet4_elem *orig)
+{
+	elem->ip[1] = orig->ip[1];
+}
+
+static inline void
+hash_netnet4_data_netmask(struct hash_netnet4_elem *elem, u8 cidr, bool inner)
+{
+	if (inner) {
+		elem->ip[1] &= ip_set_netmask(cidr);
+		elem->cidr[1] = cidr;
+	} else {
+		elem->ip[0] &= ip_set_netmask(cidr);
+		elem->cidr[0] = cidr;
+	}
+}
+
+static bool
+hash_netnet4_data_list(struct sk_buff *skb,
+		    const struct hash_netnet4_elem *data)
+{
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
+
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip[0]) ||
+	    nla_put_ipaddr4(skb, IPSET_ATTR_IP2, data->ip[1]) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr[0]) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR2, data->cidr[1]) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return 1;
+}
+
+static inline void
+hash_netnet4_data_next(struct hash_netnet4_elem *next,
+		    const struct hash_netnet4_elem *d)
+{
+	next->ipcmp = d->ipcmp;
+}
+
+#define MTYPE		hash_netnet4
+#define PF		4
+#define HOST_MASK	32
+#include "ip_set_hash_gen.h"
+
+static int
+hash_netnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
+	       const struct xt_action_param *par,
+	       enum ipset_adt adt, struct ip_set_adt_opt *opt)
+{
+	const struct hash_netnet *h = set->data;
+	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct hash_netnet4_elem e = {
+		.cidr[0] = h->nets[0].cidr[0] ? h->nets[0].cidr[0] : HOST_MASK,
+		.cidr[1] = h->nets[0].cidr[1] ? h->nets[0].cidr[1] : HOST_MASK,
+	};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
+
+	if (adt == IPSET_TEST)
+		e.ccmp = (HOST_MASK << (sizeof(e.cidr[0]) * 8)) | HOST_MASK;
+
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip[0]);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_TWO_SRC, &e.ip[1]);
+	e.ip[0] &= ip_set_netmask(e.cidr[0]);
+	e.ip[1] &= ip_set_netmask(e.cidr[1]);
+
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
+}
+
+static int
+hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
+	       enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
+{
+	const struct hash_netnet *h = set->data;
+	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct hash_netnet4_elem e = { .cidr[0] = HOST_MASK,
+				       .cidr[1] = HOST_MASK };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
+	u32 ip = 0, ip_to = 0, last;
+	u32 ip2 = 0, ip2_from = 0, ip2_to = 0, last2;
+	u8 cidr, cidr2;
+	int ret;
+
+	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		return -IPSET_ERR_PROTOCOL;
+
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
+	      ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP2], &ip2_from) ||
+	      ip_set_get_extensions(set, tb, &ext);
+	if (ret)
+		return ret;
+
+	if (tb[IPSET_ATTR_CIDR]) {
+		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+		if (!cidr || cidr > HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+		e.cidr[0] = cidr;
+	}
+
+	if (tb[IPSET_ATTR_CIDR2]) {
+		cidr2 = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
+		if (!cidr2 || cidr2 > HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+		e.cidr[1] = cidr2;
+	}
+
+	if (tb[IPSET_ATTR_CADT_FLAGS]) {
+		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+		if (cadt_flags & IPSET_FLAG_NOMATCH)
+			flags |= (IPSET_FLAG_NOMATCH << 16);
+	}
+
+	if (adt == IPSET_TEST || !(tb[IPSET_ATTR_IP_TO] &&
+				   tb[IPSET_ATTR_IP2_TO])) {
+		e.ip[0] = htonl(ip & ip_set_hostmask(e.cidr[0]));
+		e.ip[1] = htonl(ip2_from & ip_set_hostmask(e.cidr[1]));
+		ret = adtfn(set, &e, &ext, &ext, flags);
+		return ip_set_enomatch(ret, flags, adt, set) ? -ret :
+		       ip_set_eexist(ret, flags) ? 0 : ret;
+	}
+
+	ip_to = ip;
+	if (tb[IPSET_ATTR_IP_TO]) {
+		ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP_TO], &ip_to);
+		if (ret)
+			return ret;
+		if (ip_to < ip)
+			swap(ip, ip_to);
+		if (ip + UINT_MAX == ip_to)
+			return -IPSET_ERR_HASH_RANGE;
+	}
+
+	ip2_to = ip2_from;
+	if (tb[IPSET_ATTR_IP2_TO]) {
+		ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP2_TO], &ip2_to);
+		if (ret)
+			return ret;
+		if (ip2_to < ip2_from)
+			swap(ip2_from, ip2_to);
+		if (ip2_from + UINT_MAX == ip2_to)
+			return -IPSET_ERR_HASH_RANGE;
+
+	}
+
+	if (retried)
+		ip = ntohl(h->next.ip[0]);
+
+	while (!after(ip, ip_to)) {
+		e.ip[0] = htonl(ip);
+		last = ip_set_range_to_cidr(ip, ip_to, &cidr);
+		e.cidr[0] = cidr;
+		ip2 = (retried &&
+		       ip == ntohl(h->next.ip[0])) ? ntohl(h->next.ip[1])
+						   : ip2_from;
+		while (!after(ip2, ip2_to)) {
+			e.ip[1] = htonl(ip2);
+			last2 = ip_set_range_to_cidr(ip2, ip2_to, &cidr2);
+			e.cidr[1] = cidr2;
+			ret = adtfn(set, &e, &ext, &ext, flags);
+			if (ret && !ip_set_eexist(ret, flags))
+				return ret;
+			else
+				ret = 0;
+			ip2 = last2 + 1;
+		}
+		ip = last + 1;
+	}
+	return ret;
+}
+
+/* IPv6 variants */
+
+struct hash_netnet6_elem {
+	union nf_inet_addr ip[2];
+	u8 nomatch;
+	union {
+		u8 cidr[2];
+		u16 ccmp;
+	};
+};
+
+/* Common functions */
+
+static inline bool
+hash_netnet6_data_equal(const struct hash_netnet6_elem *ip1,
+		     const struct hash_netnet6_elem *ip2,
+		     u32 *multi)
+{
+	return ipv6_addr_equal(&ip1->ip[0].in6, &ip2->ip[0].in6) &&
+	       ipv6_addr_equal(&ip1->ip[1].in6, &ip2->ip[1].in6) &&
+	       ip1->ccmp == ip2->ccmp;
+}
+
+static inline int
+hash_netnet6_do_data_match(const struct hash_netnet6_elem *elem)
+{
+	return elem->nomatch ? -ENOTEMPTY : 1;
+}
+
+static inline void
+hash_netnet6_data_set_flags(struct hash_netnet6_elem *elem, u32 flags)
+{
+	elem->nomatch = (flags >> 16) & IPSET_FLAG_NOMATCH;
+}
+
+static inline void
+hash_netnet6_data_reset_flags(struct hash_netnet6_elem *elem, u8 *flags)
+{
+	swap(*flags, elem->nomatch);
+}
+
+static inline void
+hash_netnet6_data_reset_elem(struct hash_netnet6_elem *elem,
+			  struct hash_netnet6_elem *orig)
+{
+	elem->ip[1] = orig->ip[1];
+}
+
+static inline void
+hash_netnet6_data_netmask(struct hash_netnet6_elem *elem, u8 cidr, bool inner)
+{
+	if (inner) {
+		ip6_netmask(&elem->ip[1], cidr);
+		elem->cidr[1] = cidr;
+	} else {
+		ip6_netmask(&elem->ip[0], cidr);
+		elem->cidr[0] = cidr;
+	}
+}
+
+static bool
+hash_netnet6_data_list(struct sk_buff *skb,
+		    const struct hash_netnet6_elem *data)
+{
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
+
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &data->ip[0].in6) ||
+	    nla_put_ipaddr6(skb, IPSET_ATTR_IP2, &data->ip[1].in6) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR, data->cidr[0]) ||
+	    nla_put_u8(skb, IPSET_ATTR_CIDR2, data->cidr[1]) ||
+	    (flags &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return 1;
+}
+
+static inline void
+hash_netnet6_data_next(struct hash_netnet4_elem *next,
+		    const struct hash_netnet6_elem *d)
+{
+}
+
+#undef MTYPE
+#undef PF
+#undef HOST_MASK
+
+#define MTYPE		hash_netnet6
+#define PF		6
+#define HOST_MASK	128
+#define IP_SET_EMIT_CREATE
+#include "ip_set_hash_gen.h"
+
+static int
+hash_netnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
+	       const struct xt_action_param *par,
+	       enum ipset_adt adt, struct ip_set_adt_opt *opt)
+{
+	const struct hash_netnet *h = set->data;
+	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct hash_netnet6_elem e = {
+		.cidr[0] = h->nets[0].cidr[0] ? h->nets[0].cidr[0] : HOST_MASK,
+		.cidr[1] = h->nets[0].cidr[1] ? h->nets[0].cidr[1] : HOST_MASK
+	};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
+
+	if (adt == IPSET_TEST)
+		e.ccmp = (HOST_MASK << (sizeof(u8)*8)) | HOST_MASK;
+
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip[0].in6);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_TWO_SRC, &e.ip[1].in6);
+	ip6_netmask(&e.ip[0], e.cidr[0]);
+	ip6_netmask(&e.ip[1], e.cidr[1]);
+
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
+}
+
+static int
+hash_netnet6_uadt(struct ip_set *set, struct nlattr *tb[],
+	       enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
+{
+	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct hash_netnet6_elem e = { .cidr[0] = HOST_MASK,
+				       .cidr[1] = HOST_MASK };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
+	int ret;
+
+	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		return -IPSET_ERR_PROTOCOL;
+	if (unlikely(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_IP2_TO]))
+		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
+
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip[0]) ||
+	      ip_set_get_ipaddr6(tb[IPSET_ATTR_IP2], &e.ip[1]) ||
+	      ip_set_get_extensions(set, tb, &ext);
+	if (ret)
+		return ret;
+
+	if (tb[IPSET_ATTR_CIDR])
+		e.cidr[0] = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+
+	if (tb[IPSET_ATTR_CIDR2])
+		e.cidr[1] = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
+
+	if (!e.cidr[0] || e.cidr[0] > HOST_MASK || !e.cidr[1] ||
+	    e.cidr[1] > HOST_MASK)
+		return -IPSET_ERR_INVALID_CIDR;
+
+	ip6_netmask(&e.ip[0], e.cidr[0]);
+	ip6_netmask(&e.ip[1], e.cidr[1]);
+
+	if (tb[IPSET_ATTR_CADT_FLAGS]) {
+		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+		if (cadt_flags & IPSET_FLAG_NOMATCH)
+			flags |= (IPSET_FLAG_NOMATCH << 16);
+	}
+
+	ret = adtfn(set, &e, &ext, &ext, flags);
+
+	return ip_set_enomatch(ret, flags, adt, set) ? -ret :
+	       ip_set_eexist(ret, flags) ? 0 : ret;
+}
+
+static struct ip_set_type hash_netnet_type __read_mostly = {
+	.name		= "hash:net,net",
+	.protocol	= IPSET_PROTOCOL,
+	.features	= IPSET_TYPE_IP | IPSET_TYPE_IP2 | IPSET_TYPE_NOMATCH,
+	.dimension	= IPSET_DIM_TWO,
+	.family		= NFPROTO_UNSPEC,
+	.revision_min	= IPSET_TYPE_REV_MIN,
+	.revision_max	= IPSET_TYPE_REV_MAX,
+	.create		= hash_netnet_create,
+	.create_policy	= {
+		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
+		[IPSET_ATTR_MAXELEM]	= { .type = NLA_U32 },
+		[IPSET_ATTR_PROBES]	= { .type = NLA_U8 },
+		[IPSET_ATTR_RESIZE]	= { .type = NLA_U8  },
+		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
+	},
+	.adt_policy	= {
+		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
+		[IPSET_ATTR_IP_TO]	= { .type = NLA_NESTED },
+		[IPSET_ATTR_IP2]	= { .type = NLA_NESTED },
+		[IPSET_ATTR_IP2_TO]	= { .type = NLA_NESTED },
+		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
+		[IPSET_ATTR_CIDR2]	= { .type = NLA_U8 },
+		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+	},
+	.me		= THIS_MODULE,
+};
+
+static int __init
+hash_netnet_init(void)
+{
+	return ip_set_type_register(&hash_netnet_type);
+}
+
+static void __exit
+hash_netnet_fini(void)
+{
+	ip_set_type_unregister(&hash_netnet_type);
+}
+
+module_init(hash_netnet_init);
+module_exit(hash_netnet_fini);
-- 
1.7.10.4

