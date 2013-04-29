From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/18] netfilter: ipset: The hash types with counter support
Date: Mon, 29 Apr 2013 20:22:17 +0200
Message-ID: <1367259744-8922-12-git-send-email-pablo@netfilter.org>
References: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41447 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758708Ab3D2SW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 14:22:56 -0400
In-Reply-To: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_gen.h       |   65 ++++++++++++++++++++++++++-
 net/netfilter/ipset/ip_set_hash_ip.c        |   33 +++++++++++++-
 net/netfilter/ipset/ip_set_hash_ipport.c    |   46 ++++++++++++++++++-
 net/netfilter/ipset/ip_set_hash_ipportip.c  |   50 ++++++++++++++++++++-
 net/netfilter/ipset/ip_set_hash_ipportnet.c |   53 +++++++++++++++++++++-
 net/netfilter/ipset/ip_set_hash_net.c       |   47 +++++++++++++++++--
 net/netfilter/ipset/ip_set_hash_netiface.c  |   55 +++++++++++++++++++++--
 net/netfilter/ipset/ip_set_hash_netport.c   |   51 +++++++++++++++++++--
 8 files changed, 381 insertions(+), 19 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 2ba7d4e..57beb17 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -177,6 +177,8 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 
 #define ext_timeout(e, h)	\
 (unsigned long *)(((void *)(e)) + (h)->offset[IPSET_OFFSET_TIMEOUT])
+#define ext_counter(e, h)	\
+(struct ip_set_counter *)(((void *)(e)) + (h)->offset[IPSET_OFFSET_COUNTER])
 
 #endif /* _IP_SET_HASH_GEN_H */
 
@@ -660,6 +662,8 @@ reuse_slot:
 #endif
 	if (SET_WITH_TIMEOUT(set))
 		ip_set_timeout_set(ext_timeout(data, h), ext->timeout);
+	if (SET_WITH_COUNTER(set))
+		ip_set_init_counter(ext_counter(data, h), ext);
 
 out:
 	rcu_read_unlock_bh();
@@ -721,6 +725,10 @@ static inline int
 mtype_data_match(struct mtype_elem *data, const struct ip_set_ext *ext,
 		 struct ip_set_ext *mext, struct ip_set *set, u32 flags)
 {
+	if (SET_WITH_COUNTER(set))
+		ip_set_update_counter(ext_counter(data,
+						  (struct htype *)(set->data)),
+				      ext, mext, flags);
 	return mtype_do_data_match(data);
 }
 
@@ -826,7 +834,10 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 	if (nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE, htonl(memsize)) ||
 	    ((set->extensions & IPSET_EXT_TIMEOUT) &&
-	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(h->timeout))))
+	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(h->timeout))) ||
+	    ((set->extensions & IPSET_EXT_COUNTER) &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS,
+			   htonl(IPSET_FLAG_WITH_COUNTERS))))
 		goto nla_put_failure;
 	ipset_nest_end(skb, nested);
 
@@ -880,6 +891,9 @@ mtype_list(const struct ip_set *set,
 					  htonl(ip_set_timeout_get(
 						ext_timeout(e, h)))))
 				goto nla_put_failure;
+			if (SET_WITH_COUNTER(set) &&
+			    ip_set_put_counter(skb, ext_counter(e, h)))
+				goto nla_put_failure;
 			ipset_nest_end(skb, nested);
 		}
 	}
@@ -931,6 +945,7 @@ static int
 TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
+	u32 cadt_flags = 0;
 	u8 hbits;
 #ifdef IP_SET_HASH_WITH_NETMASK
 	u8 netmask;
@@ -1007,7 +1022,53 @@ TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	else
 		set->variant = &TOKEN(HTYPE, 6_variant);
 
-	if (tb[IPSET_ATTR_TIMEOUT]) {
+	if (tb[IPSET_ATTR_CADT_FLAGS])
+		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
+		set->extensions |= IPSET_EXT_COUNTER;
+		if (tb[IPSET_ATTR_TIMEOUT]) {
+			h->timeout =
+				ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
+			set->extensions |= IPSET_EXT_TIMEOUT;
+			if (set->family == NFPROTO_IPV4) {
+				h->dsize =
+					sizeof(struct TOKEN(HTYPE, 4ct_elem));
+				h->offset[IPSET_OFFSET_TIMEOUT] =
+					offsetof(struct TOKEN(HTYPE, 4ct_elem),
+						 timeout);
+				h->offset[IPSET_OFFSET_COUNTER] =
+					offsetof(struct TOKEN(HTYPE, 4ct_elem),
+						 counter);
+				TOKEN(HTYPE, 4_gc_init)(set,
+					TOKEN(HTYPE, 4_gc));
+			} else {
+				h->dsize =
+					sizeof(struct TOKEN(HTYPE, 6ct_elem));
+				h->offset[IPSET_OFFSET_TIMEOUT] =
+					offsetof(struct TOKEN(HTYPE, 6ct_elem),
+						 timeout);
+				h->offset[IPSET_OFFSET_COUNTER] =
+					offsetof(struct TOKEN(HTYPE, 6ct_elem),
+						 counter);
+				TOKEN(HTYPE, 6_gc_init)(set,
+					TOKEN(HTYPE, 6_gc));
+			}
+		} else {
+			if (set->family == NFPROTO_IPV4) {
+				h->dsize =
+					sizeof(struct TOKEN(HTYPE, 4c_elem));
+				h->offset[IPSET_OFFSET_COUNTER] =
+					offsetof(struct TOKEN(HTYPE, 4c_elem),
+						 counter);
+			} else {
+				h->dsize =
+					sizeof(struct TOKEN(HTYPE, 6c_elem));
+				h->offset[IPSET_OFFSET_COUNTER] =
+					offsetof(struct TOKEN(HTYPE, 6c_elem),
+						 counter);
+			}
+		}
+	} else if (tb[IPSET_ATTR_TIMEOUT]) {
 		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 		set->extensions |= IPSET_EXT_TIMEOUT;
 		if (set->family == NFPROTO_IPV4) {
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 2fcfb21..c74e6e1 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -24,7 +24,7 @@
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define REVISION_MIN	0
-#define REVISION_MAX	0
+#define REVISION_MAX	1	/* Counters support */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -48,6 +48,17 @@ struct hash_ip4t_elem {
 	unsigned long timeout;
 };
 
+struct hash_ip4c_elem {
+	__be32 ip;
+	struct ip_set_counter counter;
+};
+
+struct hash_ip4ct_elem {
+	__be32 ip;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -112,7 +123,9 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret = 0;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -177,6 +190,17 @@ struct hash_ip6t_elem {
 	unsigned long timeout;
 };
 
+struct hash_ip6c_elem {
+	union nf_inet_addr ip;
+	struct ip_set_counter counter;
+};
+
+struct hash_ip6ct_elem {
+	union nf_inet_addr ip;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -251,6 +275,8 @@ hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
@@ -288,6 +314,7 @@ static struct ip_set_type hash_ip_type __read_mostly = {
 		[IPSET_ATTR_RESIZE]	= { .type = NLA_U8  },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_NETMASK]	= { .type = NLA_U8  },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
@@ -295,6 +322,8 @@ static struct ip_set_type hash_ip_type __read_mostly = {
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index d89cf41..7a2d2bd 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -25,7 +25,8 @@
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define REVISION_MIN	0
-#define REVISION_MAX	1 /* SCTP and UDPLITE support added */
+/*			1    SCTP and UDPLITE support added */
+#define REVISION_MAX	2 /* Counters support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -53,6 +54,23 @@ struct hash_ipport4t_elem {
 	unsigned long timeout;
 };
 
+struct hash_ipport4c_elem {
+	__be32 ip;
+	__be16 port;
+	u8 proto;
+	u8 padding;
+	struct ip_set_counter counter;
+};
+
+struct hash_ipport4ct_elem {
+	__be32 ip;
+	__be16 port;
+	u8 proto;
+	u8 padding;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -126,7 +144,9 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -219,6 +239,23 @@ struct hash_ipport6t_elem {
 	unsigned long timeout;
 };
 
+struct hash_ipport6c_elem {
+	union nf_inet_addr ip;
+	__be16 port;
+	u8 proto;
+	u8 padding;
+	struct ip_set_counter counter;
+};
+
+struct hash_ipport6ct_elem {
+	union nf_inet_addr ip;
+	__be16 port;
+	u8 proto;
+	u8 padding;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -298,6 +335,8 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
@@ -367,6 +406,7 @@ static struct ip_set_type hash_ipport_type __read_mostly = {
 		[IPSET_ATTR_RESIZE]	= { .type = NLA_U8  },
 		[IPSET_ATTR_PROTO]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
@@ -377,6 +417,8 @@ static struct ip_set_type hash_ipport_type __read_mostly = {
 		[IPSET_ATTR_PROTO]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 4b58e5c..34e8a1a 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -25,7 +25,8 @@
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define REVISION_MIN	0
-#define REVISION_MAX	1 /* SCTP and UDPLITE support added */
+/*			1    SCTP and UDPLITE support added */
+#define REVISION_MAX	2 /* Counters support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -55,6 +56,25 @@ struct hash_ipportip4t_elem {
 	unsigned long timeout;
 };
 
+struct hash_ipportip4c_elem {
+	__be32 ip;
+	__be32 ip2;
+	__be16 port;
+	u8 proto;
+	u8 padding;
+	struct ip_set_counter counter;
+};
+
+struct hash_ipportip4ct_elem {
+	__be32 ip;
+	__be32 ip2;
+	__be16 port;
+	u8 proto;
+	u8 padding;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 static inline bool
 hash_ipportip4_data_equal(const struct hash_ipportip4_elem *ip1,
 			  const struct hash_ipportip4_elem *ip2,
@@ -129,7 +149,9 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -228,6 +250,25 @@ struct hash_ipportip6t_elem {
 	unsigned long timeout;
 };
 
+struct hash_ipportip6c_elem {
+	union nf_inet_addr ip;
+	union nf_inet_addr ip2;
+	__be16 port;
+	u8 proto;
+	u8 padding;
+	struct ip_set_counter counter;
+};
+
+struct hash_ipportip6ct_elem {
+	union nf_inet_addr ip;
+	union nf_inet_addr ip2;
+	__be16 port;
+	u8 proto;
+	u8 padding;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -308,6 +349,8 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
@@ -380,6 +423,7 @@ static struct ip_set_type hash_ipportip_type __read_mostly = {
 		[IPSET_ATTR_PROBES]	= { .type = NLA_U8 },
 		[IPSET_ATTR_RESIZE]	= { .type = NLA_U8  },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
@@ -391,6 +435,8 @@ static struct ip_set_type hash_ipportip_type __read_mostly = {
 		[IPSET_ATTR_PROTO]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index bfde4ea..c6a5253 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -27,7 +27,8 @@
 #define REVISION_MIN	0
 /*			1    SCTP and UDPLITE support added */
 /*			2    Range as input support for IPv4 added */
-#define REVISION_MAX	3 /* nomatch flag support added */
+/*			3    nomatch flag support added */
+#define REVISION_MAX	4 /* Counters support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -67,6 +68,27 @@ struct hash_ipportnet4t_elem {
 	unsigned long timeout;
 };
 
+struct hash_ipportnet4c_elem {
+	__be32 ip;
+	__be32 ip2;
+	__be16 port;
+	u8 cidr:7;
+	u8 nomatch:1;
+	u8 proto;
+	struct ip_set_counter counter;
+};
+
+struct hash_ipportnet4ct_elem {
+	__be32 ip;
+	__be32 ip2;
+	__be16 port;
+	u8 cidr:7;
+	u8 nomatch:1;
+	u8 proto;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -184,7 +206,9 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -325,6 +349,27 @@ struct hash_ipportnet6t_elem {
 	unsigned long timeout;
 };
 
+struct hash_ipportnet6c_elem {
+	union nf_inet_addr ip;
+	union nf_inet_addr ip2;
+	__be16 port;
+	u8 cidr:7;
+	u8 nomatch:1;
+	u8 proto;
+	struct ip_set_counter counter;
+};
+
+struct hash_ipportnet6ct_elem {
+	union nf_inet_addr ip;
+	union nf_inet_addr ip2;
+	__be16 port;
+	u8 cidr:7;
+	u8 nomatch:1;
+	u8 proto;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -445,6 +490,8 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
@@ -551,6 +598,8 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index cfbcdd4..da740ce 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -24,7 +24,8 @@
 
 #define REVISION_MIN	0
 /*			1    Range as input support for IPv4 added */
-#define REVISION_MAX	2 /* nomatch flag support added */
+/*			2    nomatch flag support added */
+#define REVISION_MAX	3 /* Counters support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -53,6 +54,23 @@ struct hash_net4t_elem {
 	unsigned long timeout;
 };
 
+struct hash_net4c_elem {
+	__be32 ip;
+	u16 padding0;
+	u8 nomatch;
+	u8 cidr;
+	struct ip_set_counter counter;
+};
+
+struct hash_net4ct_elem {
+	__be32 ip;
+	u16 padding0;
+	u8 nomatch;
+	u8 cidr;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -153,7 +171,9 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -225,6 +245,23 @@ struct hash_net6t_elem {
 	unsigned long timeout;
 };
 
+struct hash_net6c_elem {
+	union nf_inet_addr ip;
+	u16 padding0;
+	u8 nomatch;
+	u8 cidr;
+	struct ip_set_counter counter;
+};
+
+struct hash_net6ct_elem {
+	union nf_inet_addr ip;
+	u16 padding0;
+	u8 nomatch;
+	u8 cidr;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -328,7 +365,9 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
@@ -384,6 +423,8 @@ static struct ip_set_type hash_net_type __read_mostly = {
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 555ebb7..84ae6f6 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -25,7 +25,8 @@
 
 #define REVISION_MIN	0
 /*			1    nomatch flag support added */
-#define REVISION_MAX	2 /* /0 support added */
+/*			2    /0 support added */
+#define REVISION_MAX	3 /* Counters support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -163,6 +164,27 @@ struct hash_netiface4t_elem {
 	unsigned long timeout;
 };
 
+struct hash_netiface4c_elem {
+	__be32 ip;
+	u8 physdev;
+	u8 cidr;
+	u8 nomatch;
+	u8 elem;
+	const char *iface;
+	struct ip_set_counter counter;
+};
+
+struct hash_netiface4ct_elem {
+	__be32 ip;
+	u8 physdev;
+	u8 cidr;
+	u8 nomatch;
+	u8 elem;
+	const char *iface;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -305,7 +327,9 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !tb[IPSET_ATTR_IFACE] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -404,6 +428,27 @@ struct hash_netiface6t_elem {
 	unsigned long timeout;
 };
 
+struct hash_netiface6c_elem {
+	union nf_inet_addr ip;
+	u8 physdev;
+	u8 cidr;
+	u8 nomatch;
+	u8 elem;
+	const char *iface;
+	struct ip_set_counter counter;
+};
+
+struct hash_netiface6ct_elem {
+	union nf_inet_addr ip;
+	u8 physdev;
+	u8 cidr;
+	u8 nomatch;
+	u8 elem;
+	const char *iface;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -546,7 +591,9 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !tb[IPSET_ATTR_IFACE] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
@@ -619,6 +666,8 @@ static struct ip_set_type hash_netiface_type __read_mostly = {
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 43b1f1e..9a08698 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -26,7 +26,8 @@
 #define REVISION_MIN	0
 /*			1    SCTP and UDPLITE support added */
 /*			2    Range as input support for IPv4 added */
-#define REVISION_MAX	3 /* nomatch flag support added */
+/*			3    nomatch flag support added */
+#define REVISION_MAX	4 /* Counters support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -64,6 +65,25 @@ struct hash_netport4t_elem {
 	unsigned long timeout;
 };
 
+struct hash_netport4c_elem {
+	__be32 ip;
+	__be16 port;
+	u8 proto;
+	u8 cidr:7;
+	u8 nomatch:1;
+	struct ip_set_counter counter;
+};
+
+struct hash_netport4ct_elem {
+	__be32 ip;
+	__be16 port;
+	u8 proto;
+	u8 cidr:7;
+	u8 nomatch:1;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -176,7 +196,9 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -284,6 +306,25 @@ struct hash_netport6t_elem {
 	unsigned long timeout;
 };
 
+struct hash_netport6c_elem {
+	union nf_inet_addr ip;
+	__be16 port;
+	u8 proto;
+	u8 cidr:7;
+	u8 nomatch:1;
+	struct ip_set_counter counter;
+};
+
+struct hash_netport6ct_elem {
+	union nf_inet_addr ip;
+	__be16 port;
+	u8 proto;
+	u8 cidr:7;
+	u8 nomatch:1;
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 /* Common functions */
 
 static inline bool
@@ -400,7 +441,9 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
@@ -497,6 +540,8 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 	},
 	.me		= THIS_MODULE,
 };
-- 
1.7.10.4
