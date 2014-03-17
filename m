From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/38] netfilter: ipset: add hash:ip,mark data type to ipset
Date: Mon, 17 Mar 2014 13:42:32 +0100
Message-ID: <1395060178-11833-13-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59393 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933119AbaCQMne (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:34 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vytas Dauksa <vytas.dauksa@smoothwall.net>

Introduce packet mark support with new ip,mark hash set. This includes
userspace and kernelspace code, hash:ip,mark set tests and man page
updates.

The intended use of ip,mark set is similar to the ip:port type, but for
protocols which don't use a predictable port number. Instead of port
number it matches a firewall mark determined by a layer 7 filtering
program like opendpi.

As well as allowing or blocking traffic it will also be used for
accounting packets and bytes sent for each protocol.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h      |   10 +-
 include/uapi/linux/netfilter/ipset/ip_set.h |    1 +
 net/netfilter/ipset/Kconfig                 |    9 +
 net/netfilter/ipset/Makefile                |    1 +
 net/netfilter/ipset/ip_set_hash_ipmark.c    |  312 +++++++++++++++++++++++++++
 5 files changed, 329 insertions(+), 4 deletions(-)
 create mode 100644 net/netfilter/ipset/ip_set_hash_ipmark.c

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 0c7d01e..4ac00d4 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -39,11 +39,13 @@ enum ip_set_feature {
 	IPSET_TYPE_NAME = (1 << IPSET_TYPE_NAME_FLAG),
 	IPSET_TYPE_IFACE_FLAG = 5,
 	IPSET_TYPE_IFACE = (1 << IPSET_TYPE_IFACE_FLAG),
-	IPSET_TYPE_NOMATCH_FLAG = 6,
+	IPSET_TYPE_MARK_FLAG = 6,
+	IPSET_TYPE_MARK = (1 << IPSET_TYPE_MARK_FLAG),
+	IPSET_TYPE_NOMATCH_FLAG = 7,
 	IPSET_TYPE_NOMATCH = (1 << IPSET_TYPE_NOMATCH_FLAG),
 	/* Strictly speaking not a feature, but a flag for dumping:
 	 * this settype must be dumped last */
-	IPSET_DUMP_LAST_FLAG = 7,
+	IPSET_DUMP_LAST_FLAG = 8,
 	IPSET_DUMP_LAST = (1 << IPSET_DUMP_LAST_FLAG),
 };
 
@@ -171,8 +173,6 @@ struct ip_set_type {
 	char name[IPSET_MAXNAMELEN];
 	/* Protocol version */
 	u8 protocol;
-	/* Set features to control swapping */
-	u8 features;
 	/* Set type dimension */
 	u8 dimension;
 	/*
@@ -182,6 +182,8 @@ struct ip_set_type {
 	u8 family;
 	/* Type revisions */
 	u8 revision_min, revision_max;
+	/* Set features to control swapping */
+	u16 features;
 
 	/* Create set */
 	int (*create)(struct net *net, struct ip_set *set,
diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index 25d3b2f..5368f82 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -82,6 +82,7 @@ enum {
 	IPSET_ATTR_PROTO,	/* 7 */
 	IPSET_ATTR_CADT_FLAGS,	/* 8 */
 	IPSET_ATTR_CADT_LINENO = IPSET_ATTR_LINENO,	/* 9 */
+	IPSET_ATTR_MARK,	/* 10 */
 	/* Reserve empty slots */
 	IPSET_ATTR_CADT_MAX = 16,
 	/* Create-only specific attributes */
diff --git a/net/netfilter/ipset/Kconfig b/net/netfilter/ipset/Kconfig
index 44cd4f5..2f7f5c3 100644
--- a/net/netfilter/ipset/Kconfig
+++ b/net/netfilter/ipset/Kconfig
@@ -61,6 +61,15 @@ config IP_SET_HASH_IP
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_SET_HASH_IPMARK
+	tristate "hash:ip,mark set support"
+	depends on IP_SET
+	help
+	  This option adds the hash:ip,mark set type support, by which one
+	  can store IPv4/IPv6 address and mark pairs.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP_SET_HASH_IPPORT
 	tristate "hash:ip,port set support"
 	depends on IP_SET
diff --git a/net/netfilter/ipset/Makefile b/net/netfilter/ipset/Makefile
index 44b2d38..231f101 100644
--- a/net/netfilter/ipset/Makefile
+++ b/net/netfilter/ipset/Makefile
@@ -14,6 +14,7 @@ obj-$(CONFIG_IP_SET_BITMAP_PORT) += ip_set_bitmap_port.o
 
 # hash types
 obj-$(CONFIG_IP_SET_HASH_IP) += ip_set_hash_ip.o
+obj-$(CONFIG_IP_SET_HASH_IPMARK) += ip_set_hash_ipmark.o
 obj-$(CONFIG_IP_SET_HASH_IPPORT) += ip_set_hash_ipport.o
 obj-$(CONFIG_IP_SET_HASH_IPPORTIP) += ip_set_hash_ipportip.o
 obj-$(CONFIG_IP_SET_HASH_IPPORTNET) += ip_set_hash_ipportnet.o
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
new file mode 100644
index 0000000..e56c0d9
--- /dev/null
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -0,0 +1,312 @@
+/* Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ * Copyright (C) 2013 Smoothwall Ltd. <vytas.dauksa@smoothwall.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+/* Kernel module implementing an IP set type: the hash:ip,mark type */
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
+#include <net/tcp.h>
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
+MODULE_AUTHOR("Vytas Dauksa <vytas.dauksa@smoothwall.net>");
+IP_SET_MODULE_DESC("hash:ip,mark", IPSET_TYPE_REV_MIN, IPSET_TYPE_REV_MAX);
+MODULE_ALIAS("ip_set_hash:ip,mark");
+
+/* Type specific function prefix */
+#define HTYPE		hash_ipmark
+
+/* IPv4 variant */
+
+/* Member elements */
+struct hash_ipmark4_elem {
+	__be32 ip;
+	__u32 mark;
+};
+
+/* Common functions */
+
+static inline bool
+hash_ipmark4_data_equal(const struct hash_ipmark4_elem *ip1,
+			const struct hash_ipmark4_elem *ip2,
+			u32 *multi)
+{
+	return ip1->ip == ip2->ip &&
+	       ip1->mark == ip2->mark;
+}
+
+static bool
+hash_ipmark4_data_list(struct sk_buff *skb,
+		       const struct hash_ipmark4_elem *data)
+{
+	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip) ||
+	    nla_put_net32(skb, IPSET_ATTR_MARK, htonl(data->mark)))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return 1;
+}
+
+static inline void
+hash_ipmark4_data_next(struct hash_ipmark4_elem *next,
+		       const struct hash_ipmark4_elem *d)
+{
+	next->ip = d->ip;
+}
+
+#define MTYPE           hash_ipmark4
+#define PF              4
+#define HOST_MASK       32
+#define HKEY_DATALEN	sizeof(struct hash_ipmark4_elem)
+#include "ip_set_hash_gen.h"
+
+static int
+hash_ipmark4_kadt(struct ip_set *set, const struct sk_buff *skb,
+		  const struct xt_action_param *par,
+		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
+{
+	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct hash_ipmark4_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
+
+	e.mark = skb->mark;
+
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
+}
+
+static int
+hash_ipmark4_uadt(struct ip_set *set, struct nlattr *tb[],
+		  enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
+{
+	const struct hash_ipmark *h = set->data;
+	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct hash_ipmark4_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
+	u32 ip, ip_to = 0;
+	int ret;
+
+	if (unlikely(!tb[IPSET_ATTR_IP] ||
+		     !ip_set_attr_netorder(tb, IPSET_ATTR_MARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
+		return -IPSET_ERR_PROTOCOL;
+
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
+	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
+	if (ret)
+		return ret;
+
+	e.mark = ntohl(nla_get_u32(tb[IPSET_ATTR_MARK]));
+
+	if (adt == IPSET_TEST ||
+	    !(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_CIDR])) {
+		ret = adtfn(set, &e, &ext, &ext, flags);
+		return ip_set_eexist(ret, flags) ? 0 : ret;
+	}
+
+	ip_to = ip = ntohl(e.ip);
+	if (tb[IPSET_ATTR_IP_TO]) {
+		ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP_TO], &ip_to);
+		if (ret)
+			return ret;
+		if (ip > ip_to)
+			swap(ip, ip_to);
+	} else if (tb[IPSET_ATTR_CIDR]) {
+		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+
+		if (!cidr || cidr > 32)
+			return -IPSET_ERR_INVALID_CIDR;
+		ip_set_mask_from_to(ip, ip_to, cidr);
+	}
+
+	if (retried)
+		ip = ntohl(h->next.ip);
+	for (; !before(ip_to, ip); ip++) {
+		e.ip = htonl(ip);
+		ret = adtfn(set, &e, &ext, &ext, flags);
+
+		if (ret && !ip_set_eexist(ret, flags))
+			return ret;
+		else
+			ret = 0;
+	}
+	return ret;
+}
+
+/* IPv6 variant */
+
+struct hash_ipmark6_elem {
+	union nf_inet_addr ip;
+	__u32 mark;
+};
+
+/* Common functions */
+
+static inline bool
+hash_ipmark6_data_equal(const struct hash_ipmark6_elem *ip1,
+			const struct hash_ipmark6_elem *ip2,
+			u32 *multi)
+{
+	return ipv6_addr_equal(&ip1->ip.in6, &ip2->ip.in6) &&
+	       ip1->mark == ip2->mark;
+}
+
+static bool
+hash_ipmark6_data_list(struct sk_buff *skb,
+		       const struct hash_ipmark6_elem *data)
+{
+	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &data->ip.in6) ||
+	    nla_put_net32(skb, IPSET_ATTR_MARK, htonl(data->mark)))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return 1;
+}
+
+static inline void
+hash_ipmark6_data_next(struct hash_ipmark4_elem *next,
+		       const struct hash_ipmark6_elem *d)
+{
+}
+
+#undef MTYPE
+#undef PF
+#undef HOST_MASK
+#undef HKEY_DATALEN
+
+#define MTYPE		hash_ipmark6
+#define PF		6
+#define HOST_MASK	128
+#define HKEY_DATALEN	sizeof(struct hash_ipmark6_elem)
+#define	IP_SET_EMIT_CREATE
+#include "ip_set_hash_gen.h"
+
+
+static int
+hash_ipmark6_kadt(struct ip_set *set, const struct sk_buff *skb,
+		  const struct xt_action_param *par,
+		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
+{
+	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct hash_ipmark6_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
+
+	e.mark = skb->mark;
+
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip.in6);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
+}
+
+static int
+hash_ipmark6_uadt(struct ip_set *set, struct nlattr *tb[],
+		  enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
+{
+	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct hash_ipmark6_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
+	int ret;
+
+	if (unlikely(!tb[IPSET_ATTR_IP] ||
+		     !ip_set_attr_netorder(tb, IPSET_ATTR_MARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
+		     tb[IPSET_ATTR_IP_TO] ||
+		     tb[IPSET_ATTR_CIDR]))
+		return -IPSET_ERR_PROTOCOL;
+
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
+	if (ret)
+		return ret;
+
+	e.mark = ntohl(nla_get_u32(tb[IPSET_ATTR_MARK]));
+
+	if (adt == IPSET_TEST) {
+		ret = adtfn(set, &e, &ext, &ext, flags);
+		return ip_set_eexist(ret, flags) ? 0 : ret;
+	}
+
+	ret = adtfn(set, &e, &ext, &ext, flags);
+	if (ret && !ip_set_eexist(ret, flags))
+		return ret;
+	else
+		ret = 0;
+
+	return ret;
+}
+
+static struct ip_set_type hash_ipmark_type __read_mostly = {
+	.name		= "hash:ip,mark",
+	.protocol	= IPSET_PROTOCOL,
+	.features	= IPSET_TYPE_IP | IPSET_TYPE_MARK,
+	.dimension	= IPSET_DIM_TWO,
+	.family		= NFPROTO_UNSPEC,
+	.revision_min	= IPSET_TYPE_REV_MIN,
+	.revision_max	= IPSET_TYPE_REV_MAX,
+	.create		= hash_ipmark_create,
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
+		[IPSET_ATTR_MARK]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
+		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+	},
+	.me		= THIS_MODULE,
+};
+
+static int __init
+hash_ipmark_init(void)
+{
+	return ip_set_type_register(&hash_ipmark_type);
+}
+
+static void __exit
+hash_ipmark_fini(void)
+{
+	ip_set_type_unregister(&hash_ipmark_type);
+}
+
+module_init(hash_ipmark_init);
+module_exit(hash_ipmark_fini);
-- 
1.7.10.4
