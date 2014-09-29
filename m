From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/34] netfilter: ipset: Add skbinfo extension kernel support in the ipset core.
Date: Mon, 29 Sep 2014 14:38:55 +0200
Message-ID: <1411994363-8451-7-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34054 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754045AbaI2MiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:38:25 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Danilov <littlesmilingcloud@gmail.com>

Skbinfo extension provides mapping of metainformation with lookup in the ipset tables.
This patch defines the flags, the constants, the functions and the structures
for the data type independent support of the extension.
Note the firewall mark stores in the kernel structures as two 32bit values,
but transfered through netlink as one 64bit value.

Signed-off-by: Anton Danilov <littlesmilingcloud@gmail.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h      |   56 ++++++++++++++++++++++++++-
 include/uapi/linux/netfilter/ipset/ip_set.h |   12 ++++++
 net/netfilter/ipset/ip_set_core.c           |   27 ++++++++++++-
 3 files changed, 93 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 96afc29..b97aac5 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -57,6 +57,8 @@ enum ip_set_extension {
 	IPSET_EXT_COUNTER = (1 << IPSET_EXT_BIT_COUNTER),
 	IPSET_EXT_BIT_COMMENT = 2,
 	IPSET_EXT_COMMENT = (1 << IPSET_EXT_BIT_COMMENT),
+	IPSET_EXT_BIT_SKBINFO = 3,
+	IPSET_EXT_SKBINFO = (1 << IPSET_EXT_BIT_SKBINFO),
 	/* Mark set with an extension which needs to call destroy */
 	IPSET_EXT_BIT_DESTROY = 7,
 	IPSET_EXT_DESTROY = (1 << IPSET_EXT_BIT_DESTROY),
@@ -65,12 +67,14 @@ enum ip_set_extension {
 #define SET_WITH_TIMEOUT(s)	((s)->extensions & IPSET_EXT_TIMEOUT)
 #define SET_WITH_COUNTER(s)	((s)->extensions & IPSET_EXT_COUNTER)
 #define SET_WITH_COMMENT(s)	((s)->extensions & IPSET_EXT_COMMENT)
+#define SET_WITH_SKBINFO(s)	((s)->extensions & IPSET_EXT_SKBINFO)
 #define SET_WITH_FORCEADD(s)	((s)->flags & IPSET_CREATE_FLAG_FORCEADD)
 
 /* Extension id, in size order */
 enum ip_set_ext_id {
 	IPSET_EXT_ID_COUNTER = 0,
 	IPSET_EXT_ID_TIMEOUT,
+	IPSET_EXT_ID_SKBINFO,
 	IPSET_EXT_ID_COMMENT,
 	IPSET_EXT_ID_MAX,
 };
@@ -92,6 +96,10 @@ struct ip_set_ext {
 	u64 packets;
 	u64 bytes;
 	u32 timeout;
+	u32 skbmark;
+	u32 skbmarkmask;
+	u32 skbprio;
+	u16 skbqueue;
 	char *comment;
 };
 
@@ -104,6 +112,13 @@ struct ip_set_comment {
 	char *str;
 };
 
+struct ip_set_skbinfo {
+	u32 skbmark;
+	u32 skbmarkmask;
+	u32 skbprio;
+	u16 skbqueue;
+};
+
 struct ip_set;
 
 #define ext_timeout(e, s)	\
@@ -112,7 +127,8 @@ struct ip_set;
 (struct ip_set_counter *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_COUNTER])
 #define ext_comment(e, s)	\
 (struct ip_set_comment *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_COMMENT])
-
+#define ext_skbinfo(e, s)	\
+(struct ip_set_skbinfo *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_SKBINFO])
 
 typedef int (*ipset_adtfn)(struct ip_set *set, void *value,
 			   const struct ip_set_ext *ext,
@@ -256,6 +272,8 @@ ip_set_put_flags(struct sk_buff *skb, struct ip_set *set)
 		cadt_flags |= IPSET_FLAG_WITH_COUNTERS;
 	if (SET_WITH_COMMENT(set))
 		cadt_flags |= IPSET_FLAG_WITH_COMMENT;
+	if (SET_WITH_SKBINFO(set))
+		cadt_flags |= IPSET_FLAG_WITH_SKBINFO;
 	if (SET_WITH_FORCEADD(set))
 		cadt_flags |= IPSET_FLAG_WITH_FORCEADD;
 
@@ -304,6 +322,39 @@ ip_set_update_counter(struct ip_set_counter *counter,
 	}
 }
 
+static inline void
+ip_set_get_skbinfo(struct ip_set_skbinfo *skbinfo,
+		      const struct ip_set_ext *ext,
+		      struct ip_set_ext *mext, u32 flags)
+{
+		mext->skbmark = skbinfo->skbmark;
+		mext->skbmarkmask = skbinfo->skbmarkmask;
+		mext->skbprio = skbinfo->skbprio;
+		mext->skbqueue = skbinfo->skbqueue;
+}
+static inline bool
+ip_set_put_skbinfo(struct sk_buff *skb, struct ip_set_skbinfo *skbinfo)
+{
+	return nla_put_net64(skb, IPSET_ATTR_SKBMARK,
+			     cpu_to_be64((u64)skbinfo->skbmark << 32 |
+					 skbinfo->skbmarkmask)) ||
+	       nla_put_net32(skb, IPSET_ATTR_SKBPRIO,
+			     cpu_to_be32(skbinfo->skbprio)) ||
+	       nla_put_net16(skb, IPSET_ATTR_SKBQUEUE,
+			     cpu_to_be16(skbinfo->skbqueue));
+
+}
+
+static inline void
+ip_set_init_skbinfo(struct ip_set_skbinfo *skbinfo,
+		    const struct ip_set_ext *ext)
+{
+	skbinfo->skbmark = ext->skbmark;
+	skbinfo->skbmarkmask = ext->skbmarkmask;
+	skbinfo->skbprio = ext->skbprio;
+	skbinfo->skbqueue = ext->skbqueue;
+}
+
 static inline bool
 ip_set_put_counter(struct sk_buff *skb, struct ip_set_counter *counter)
 {
@@ -497,6 +548,9 @@ ip_set_put_extensions(struct sk_buff *skb, const struct ip_set *set,
 	if (SET_WITH_COMMENT(set) &&
 	    ip_set_put_comment(skb, ext_comment(e, set)))
 		return -EMSGSIZE;
+	if (SET_WITH_SKBINFO(set) &&
+	    ip_set_put_skbinfo(skb, ext_skbinfo(e, set)))
+		return -EMSGSIZE;
 	return 0;
 }
 
diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index 78c2f2e..ca03119 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -115,6 +115,9 @@ enum {
 	IPSET_ATTR_BYTES,
 	IPSET_ATTR_PACKETS,
 	IPSET_ATTR_COMMENT,
+	IPSET_ATTR_SKBMARK,
+	IPSET_ATTR_SKBPRIO,
+	IPSET_ATTR_SKBQUEUE,
 	__IPSET_ATTR_ADT_MAX,
 };
 #define IPSET_ATTR_ADT_MAX	(__IPSET_ATTR_ADT_MAX - 1)
@@ -147,6 +150,7 @@ enum ipset_errno {
 	IPSET_ERR_COUNTER,
 	IPSET_ERR_COMMENT,
 	IPSET_ERR_INVALID_MARKMASK,
+	IPSET_ERR_SKBINFO,
 
 	/* Type specific error codes */
 	IPSET_ERR_TYPE_SPECIFIC = 4352,
@@ -170,6 +174,12 @@ enum ipset_cmd_flags {
 	IPSET_FLAG_MATCH_COUNTERS = (1 << IPSET_FLAG_BIT_MATCH_COUNTERS),
 	IPSET_FLAG_BIT_RETURN_NOMATCH = 7,
 	IPSET_FLAG_RETURN_NOMATCH = (1 << IPSET_FLAG_BIT_RETURN_NOMATCH),
+	IPSET_FLAG_BIT_MAP_SKBMARK = 8,
+	IPSET_FLAG_MAP_SKBMARK = (1 << IPSET_FLAG_BIT_MAP_SKBMARK),
+	IPSET_FLAG_BIT_MAP_SKBPRIO = 9,
+	IPSET_FLAG_MAP_SKBPRIO = (1 << IPSET_FLAG_BIT_MAP_SKBPRIO),
+	IPSET_FLAG_BIT_MAP_SKBQUEUE = 10,
+	IPSET_FLAG_MAP_SKBQUEUE = (1 << IPSET_FLAG_BIT_MAP_SKBQUEUE),
 	IPSET_FLAG_CMD_MAX = 15,
 };
 
@@ -187,6 +197,8 @@ enum ipset_cadt_flags {
 	IPSET_FLAG_WITH_COMMENT = (1 << IPSET_FLAG_BIT_WITH_COMMENT),
 	IPSET_FLAG_BIT_WITH_FORCEADD = 5,
 	IPSET_FLAG_WITH_FORCEADD = (1 << IPSET_FLAG_BIT_WITH_FORCEADD),
+	IPSET_FLAG_BIT_WITH_SKBINFO = 6,
+	IPSET_FLAG_WITH_SKBINFO = (1 << IPSET_FLAG_BIT_WITH_SKBINFO),
 	IPSET_FLAG_CADT_MAX	= 15,
 };
 
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 4ca4e5c..26c795e 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -337,6 +337,12 @@ const struct ip_set_ext_type ip_set_extensions[] = {
 		.len	= sizeof(unsigned long),
 		.align	= __alignof__(unsigned long),
 	},
+	[IPSET_EXT_ID_SKBINFO] = {
+		.type	= IPSET_EXT_SKBINFO,
+		.flag	= IPSET_FLAG_WITH_SKBINFO,
+		.len	= sizeof(struct ip_set_skbinfo),
+		.align	= __alignof__(struct ip_set_skbinfo),
+	},
 	[IPSET_EXT_ID_COMMENT] = {
 		.type	 = IPSET_EXT_COMMENT | IPSET_EXT_DESTROY,
 		.flag	 = IPSET_FLAG_WITH_COMMENT,
@@ -382,6 +388,7 @@ int
 ip_set_get_extensions(struct ip_set *set, struct nlattr *tb[],
 		      struct ip_set_ext *ext)
 {
+	u64 fullmark;
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		if (!(set->extensions & IPSET_EXT_TIMEOUT))
 			return -IPSET_ERR_TIMEOUT;
@@ -402,7 +409,25 @@ ip_set_get_extensions(struct ip_set *set, struct nlattr *tb[],
 			return -IPSET_ERR_COMMENT;
 		ext->comment = ip_set_comment_uget(tb[IPSET_ATTR_COMMENT]);
 	}
-
+	if (tb[IPSET_ATTR_SKBMARK]) {
+		if (!(set->extensions & IPSET_EXT_SKBINFO))
+			return -IPSET_ERR_SKBINFO;
+		fullmark = be64_to_cpu(nla_get_be64(tb[IPSET_ATTR_SKBMARK]));
+		ext->skbmark = fullmark >> 32;
+		ext->skbmarkmask = fullmark & 0xffffffff;
+	}
+	if (tb[IPSET_ATTR_SKBPRIO]) {
+		if (!(set->extensions & IPSET_EXT_SKBINFO))
+			return -IPSET_ERR_SKBINFO;
+		ext->skbprio = be32_to_cpu(nla_get_be32(
+					    tb[IPSET_ATTR_SKBPRIO]));
+	}
+	if (tb[IPSET_ATTR_SKBQUEUE]) {
+		if (!(set->extensions & IPSET_EXT_SKBINFO))
+			return -IPSET_ERR_SKBINFO;
+		ext->skbqueue = be16_to_cpu(nla_get_be16(
+					    tb[IPSET_ATTR_SKBQUEUE]));
+	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ip_set_get_extensions);
-- 
1.7.10.4
