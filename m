From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/34] netfilter: ipset: hash:mac type added to ipset
Date: Mon, 29 Sep 2014 14:39:01 +0200
Message-ID: <1411994363-8451-13-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34131 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754123AbaI2Mid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:38:33 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/Kconfig           |    9 ++
 net/netfilter/ipset/Makefile          |    1 +
 net/netfilter/ipset/ip_set_hash_gen.h |   11 ++-
 net/netfilter/ipset/ip_set_hash_mac.c |  173 +++++++++++++++++++++++++++++++++
 4 files changed, 193 insertions(+), 1 deletion(-)
 create mode 100644 net/netfilter/ipset/ip_set_hash_mac.c

diff --git a/net/netfilter/ipset/Kconfig b/net/netfilter/ipset/Kconfig
index 2f7f5c3..234a8ec 100644
--- a/net/netfilter/ipset/Kconfig
+++ b/net/netfilter/ipset/Kconfig
@@ -99,6 +99,15 @@ config IP_SET_HASH_IPPORTNET
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_SET_HASH_MAC
+	tristate "hash:mac set support"
+	depends on IP_SET
+	help
+	  This option adds the hash:mac set type support, by which
+	  one can store MAC (ethernet address) elements in a set.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP_SET_HASH_NETPORTNET
 	tristate "hash:net,port,net set support"
 	depends on IP_SET
diff --git a/net/netfilter/ipset/Makefile b/net/netfilter/ipset/Makefile
index 231f101..3dbd5e9 100644
--- a/net/netfilter/ipset/Makefile
+++ b/net/netfilter/ipset/Makefile
@@ -18,6 +18,7 @@ obj-$(CONFIG_IP_SET_HASH_IPMARK) += ip_set_hash_ipmark.o
 obj-$(CONFIG_IP_SET_HASH_IPPORT) += ip_set_hash_ipport.o
 obj-$(CONFIG_IP_SET_HASH_IPPORTIP) += ip_set_hash_ipportip.o
 obj-$(CONFIG_IP_SET_HASH_IPPORTNET) += ip_set_hash_ipportnet.o
+obj-$(CONFIG_IP_SET_HASH_MAC) += ip_set_hash_mac.o
 obj-$(CONFIG_IP_SET_HASH_NET) += ip_set_hash_net.o
 obj-$(CONFIG_IP_SET_HASH_NETPORT) += ip_set_hash_netport.o
 obj-$(CONFIG_IP_SET_HASH_NETIFACE) += ip_set_hash_netiface.o
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index ac3a268..fee7c64e 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -1054,8 +1054,10 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 	struct HTYPE *h;
 	struct htable *t;
 
+#ifndef IP_SET_PROTO_UNDEF
 	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
+#endif
 
 #ifdef IP_SET_HASH_WITH_MARKMASK
 	markmask = 0xffffffff;
@@ -1137,25 +1139,32 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 	rcu_assign_pointer(h->table, t);
 
 	set->data = h;
+#ifndef IP_SET_PROTO_UNDEF
 	if (set->family == NFPROTO_IPV4) {
+#endif
 		set->variant = &IPSET_TOKEN(HTYPE, 4_variant);
 		set->dsize = ip_set_elem_len(set, tb,
 				sizeof(struct IPSET_TOKEN(HTYPE, 4_elem)));
+#ifndef IP_SET_PROTO_UNDEF
 	} else {
 		set->variant = &IPSET_TOKEN(HTYPE, 6_variant);
 		set->dsize = ip_set_elem_len(set, tb,
 				sizeof(struct IPSET_TOKEN(HTYPE, 6_elem)));
 	}
+#endif
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
+#ifndef IP_SET_PROTO_UNDEF
 		if (set->family == NFPROTO_IPV4)
+#endif
 			IPSET_TOKEN(HTYPE, 4_gc_init)(set,
 				IPSET_TOKEN(HTYPE, 4_gc));
+#ifndef IP_SET_PROTO_UNDEF
 		else
 			IPSET_TOKEN(HTYPE, 6_gc_init)(set,
 				IPSET_TOKEN(HTYPE, 6_gc));
+#endif
 	}
-
 	pr_debug("create %s hashsize %u (%u) maxelem %u: %p(%p)\n",
 		 set->name, jhash_size(t->htable_bits),
 		 t->htable_bits, h->maxelem, set->data, t);
diff --git a/net/netfilter/ipset/ip_set_hash_mac.c b/net/netfilter/ipset/ip_set_hash_mac.c
new file mode 100644
index 0000000..65690b5
--- /dev/null
+++ b/net/netfilter/ipset/ip_set_hash_mac.c
@@ -0,0 +1,173 @@
+/* Copyright (C) 2014 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+/* Kernel module implementing an IP set type: the hash:mac type */
+
+#include <linux/jhash.h>
+#include <linux/module.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/errno.h>
+#include <linux/if_ether.h>
+#include <net/netlink.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter/ipset/ip_set.h>
+#include <linux/netfilter/ipset/ip_set_hash.h>
+
+#define IPSET_TYPE_REV_MIN	0
+#define IPSET_TYPE_REV_MAX	0
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
+IP_SET_MODULE_DESC("hash:mac", IPSET_TYPE_REV_MIN, IPSET_TYPE_REV_MAX);
+MODULE_ALIAS("ip_set_hash:mac");
+
+/* Type specific function prefix */
+#define HTYPE		hash_mac
+
+/* Member elements */
+struct hash_mac4_elem {
+	/* Zero valued IP addresses cannot be stored */
+	union {
+		unsigned char ether[ETH_ALEN];
+		__be32 foo[2];
+	};
+};
+
+/* Common functions */
+
+static inline bool
+hash_mac4_data_equal(const struct hash_mac4_elem *e1,
+		     const struct hash_mac4_elem *e2,
+		     u32 *multi)
+{
+	return ether_addr_equal(e1->ether, e2->ether);
+}
+
+static inline bool
+hash_mac4_data_list(struct sk_buff *skb, const struct hash_mac4_elem *e)
+{
+	return nla_put(skb, IPSET_ATTR_ETHER, ETH_ALEN, e->ether);
+}
+
+static inline void
+hash_mac4_data_next(struct hash_mac4_elem *next,
+		    const struct hash_mac4_elem *e)
+{
+}
+
+#define MTYPE		hash_mac4
+#define PF		4
+#define HOST_MASK	32
+#define IP_SET_EMIT_CREATE
+#define IP_SET_PROTO_UNDEF
+#include "ip_set_hash_gen.h"
+
+/* Zero valued element is not supported */
+static const unsigned char invalid_ether[ETH_ALEN] = { 0 };
+
+static int
+hash_mac4_kadt(struct ip_set *set, const struct sk_buff *skb,
+	       const struct xt_action_param *par,
+	       enum ipset_adt adt, struct ip_set_adt_opt *opt)
+{
+	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct hash_mac4_elem e = { { .foo[0] = 0, .foo[1] = 0 } };
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
+
+	 /* MAC can be src only */
+	if (!(opt->flags & IPSET_DIM_ONE_SRC))
+		return 0;
+
+	if (skb_mac_header(skb) < skb->head ||
+	     (skb_mac_header(skb) + ETH_HLEN) > skb->data)
+		return -EINVAL;
+
+	memcpy(e.ether, eth_hdr(skb)->h_source, ETH_ALEN);
+	if (memcmp(e.ether, invalid_ether, ETH_ALEN) == 0)
+		return -EINVAL;
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
+}
+
+static int
+hash_mac4_uadt(struct ip_set *set, struct nlattr *tb[],
+	       enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
+{
+	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct hash_mac4_elem e = { { .foo[0] = 0, .foo[1] = 0 } };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
+	int ret;
+
+	if (unlikely(!tb[IPSET_ATTR_ETHER] ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)   ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBMARK) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBPRIO) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_SKBQUEUE)))
+		return -IPSET_ERR_PROTOCOL;
+
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
+	ret = ip_set_get_extensions(set, tb, &ext);
+	if (ret)
+		return ret;
+	memcpy(e.ether, nla_data(tb[IPSET_ATTR_ETHER]), ETH_ALEN);
+	if (memcmp(e.ether, invalid_ether, ETH_ALEN) == 0)
+		return -IPSET_ERR_HASH_ELEM;
+
+	return adtfn(set, &e, &ext, &ext, flags);
+}
+
+static struct ip_set_type hash_mac_type __read_mostly = {
+	.name		= "hash:mac",
+	.protocol	= IPSET_PROTOCOL,
+	.features	= IPSET_TYPE_MAC,
+	.dimension	= IPSET_DIM_ONE,
+	.family		= NFPROTO_UNSPEC,
+	.revision_min	= IPSET_TYPE_REV_MIN,
+	.revision_max	= IPSET_TYPE_REV_MAX,
+	.create		= hash_mac_create,
+	.create_policy	= {
+		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
+		[IPSET_ATTR_MAXELEM]	= { .type = NLA_U32 },
+		[IPSET_ATTR_PROBES]	= { .type = NLA_U8 },
+		[IPSET_ATTR_RESIZE]	= { .type = NLA_U8  },
+		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
+	},
+	.adt_policy	= {
+		[IPSET_ATTR_ETHER]	= { .type = NLA_BINARY,
+					    .len  = ETH_ALEN },
+		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
+		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
+	},
+	.me		= THIS_MODULE,
+};
+
+static int __init
+hash_mac_init(void)
+{
+	return ip_set_type_register(&hash_mac_type);
+}
+
+static void __exit
+hash_mac_fini(void)
+{
+	ip_set_type_unregister(&hash_mac_type);
+}
+
+module_init(hash_mac_init);
+module_exit(hash_mac_fini);
-- 
1.7.10.4
