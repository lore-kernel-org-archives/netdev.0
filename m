From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/33] netfilter: ipset: Support comments for ipset entries in the core.
Date: Fri,  4 Oct 2013 10:33:06 +0200
Message-ID: <1380875598-5250-22-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56022 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753907Ab3JDIfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:35:06 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>

This adds the core support for having comments on ipset entries.

The comments are stored as standard null-terminated strings in
dynamically allocated memory after being passed to the kernel. As a
result of this, code has been added to the generic destroy function to
iterate all extensions and call that extension's destroy task if the set
has that extension activated, and if such a task is defined.

Signed-off-by: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h         |   51 +++++++++++++++++----
 include/linux/netfilter/ipset/ip_set_comment.h |   57 ++++++++++++++++++++++++
 include/uapi/linux/netfilter/ipset/ip_set.h    |    8 +++-
 net/netfilter/ipset/ip_set_core.c              |   14 ++++++
 4 files changed, 121 insertions(+), 9 deletions(-)
 create mode 100644 include/linux/netfilter/ipset/ip_set_comment.h

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 6372ee2..407f84d 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -53,6 +53,8 @@ enum ip_set_extension {
 	IPSET_EXT_TIMEOUT = (1 << IPSET_EXT_BIT_TIMEOUT),
 	IPSET_EXT_BIT_COUNTER = 1,
 	IPSET_EXT_COUNTER = (1 << IPSET_EXT_BIT_COUNTER),
+	IPSET_EXT_BIT_COMMENT = 2,
+	IPSET_EXT_COMMENT = (1 << IPSET_EXT_BIT_COMMENT),
 	/* Mark set with an extension which needs to call destroy */
 	IPSET_EXT_BIT_DESTROY = 7,
 	IPSET_EXT_DESTROY = (1 << IPSET_EXT_BIT_DESTROY),
@@ -60,11 +62,13 @@ enum ip_set_extension {
 
 #define SET_WITH_TIMEOUT(s)	((s)->extensions & IPSET_EXT_TIMEOUT)
 #define SET_WITH_COUNTER(s)	((s)->extensions & IPSET_EXT_COUNTER)
+#define SET_WITH_COMMENT(s)	((s)->extensions & IPSET_EXT_COMMENT)
 
 /* Extension id, in size order */
 enum ip_set_ext_id {
 	IPSET_EXT_ID_COUNTER = 0,
 	IPSET_EXT_ID_TIMEOUT,
+	IPSET_EXT_ID_COMMENT,
 	IPSET_EXT_ID_MAX,
 };
 
@@ -85,6 +89,7 @@ struct ip_set_ext {
 	u64 packets;
 	u64 bytes;
 	u32 timeout;
+	char *comment;
 };
 
 struct ip_set_counter {
@@ -92,20 +97,19 @@ struct ip_set_counter {
 	atomic64_t packets;
 };
 
-struct ip_set;
+struct ip_set_comment {
+	char *str;
+};
 
-static inline void
-ip_set_ext_destroy(struct ip_set *set, void *data)
-{
-	/* Check that the extension is enabled for the set and
-	 * call it's destroy function for its extension part in data.
-	 */
-}
+struct ip_set;
 
 #define ext_timeout(e, s)	\
 (unsigned long *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_TIMEOUT])
 #define ext_counter(e, s)	\
 (struct ip_set_counter *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_COUNTER])
+#define ext_comment(e, s)	\
+(struct ip_set_comment *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_COMMENT])
+
 
 typedef int (*ipset_adtfn)(struct ip_set *set, void *value,
 			   const struct ip_set_ext *ext,
@@ -223,6 +227,36 @@ struct ip_set {
 };
 
 static inline void
+ip_set_ext_destroy(struct ip_set *set, void *data)
+{
+	/* Check that the extension is enabled for the set and
+	 * call it's destroy function for its extension part in data.
+	 */
+	if (SET_WITH_COMMENT(set))
+		ip_set_extensions[IPSET_EXT_ID_COMMENT].destroy(
+			ext_comment(data, set));
+}
+
+static inline int
+ip_set_put_flags(struct sk_buff *skb, struct ip_set *set)
+{
+	u32 cadt_flags = 0;
+
+	if (SET_WITH_TIMEOUT(set))
+		if (unlikely(nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+					   htonl(set->timeout))))
+			return -EMSGSIZE;
+	if (SET_WITH_COUNTER(set))
+		cadt_flags |= IPSET_FLAG_WITH_COUNTERS;
+	if (SET_WITH_COMMENT(set))
+		cadt_flags |= IPSET_FLAG_WITH_COMMENT;
+
+	if (!cadt_flags)
+		return 0;
+	return nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(cadt_flags));
+}
+
+static inline void
 ip_set_add_bytes(u64 bytes, struct ip_set_counter *counter)
 {
 	atomic64_add((long long)bytes, &(counter)->bytes);
@@ -425,6 +459,7 @@ bitmap_bytes(u32 a, u32 b)
 }
 
 #include <linux/netfilter/ipset/ip_set_timeout.h>
+#include <linux/netfilter/ipset/ip_set_comment.h>
 
 #define IP_SET_INIT_KEXT(skb, opt, set)			\
 	{ .bytes = (skb)->len, .packets = 1,		\
diff --git a/include/linux/netfilter/ipset/ip_set_comment.h b/include/linux/netfilter/ipset/ip_set_comment.h
new file mode 100644
index 0000000..21217ea
--- /dev/null
+++ b/include/linux/netfilter/ipset/ip_set_comment.h
@@ -0,0 +1,57 @@
+#ifndef _IP_SET_COMMENT_H
+#define _IP_SET_COMMENT_H
+
+/* Copyright (C) 2013 Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifdef __KERNEL__
+
+static inline char*
+ip_set_comment_uget(struct nlattr *tb)
+{
+	return nla_data(tb);
+}
+
+static inline void
+ip_set_init_comment(struct ip_set_comment *comment,
+		    const struct ip_set_ext *ext)
+{
+	size_t len = ext->comment ? strlen(ext->comment) : 0;
+
+	if (unlikely(comment->str)) {
+		kfree(comment->str);
+		comment->str = NULL;
+	}
+	if (!len)
+		return;
+	if (unlikely(len > IPSET_MAX_COMMENT_SIZE))
+		len = IPSET_MAX_COMMENT_SIZE;
+	comment->str = kzalloc(len + 1, GFP_ATOMIC);
+	if (unlikely(!comment->str))
+		return;
+	strlcpy(comment->str, ext->comment, len + 1);
+}
+
+static inline int
+ip_set_put_comment(struct sk_buff *skb, struct ip_set_comment *comment)
+{
+	if (!comment->str)
+		return 0;
+	return nla_put_string(skb, IPSET_ATTR_COMMENT, comment->str);
+}
+
+static inline void
+ip_set_comment_free(struct ip_set_comment *comment)
+{
+	if (unlikely(!comment->str))
+		return;
+	kfree(comment->str);
+	comment->str = NULL;
+}
+
+#endif
+#endif
diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index 2b61ac4..25d3b2f 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -10,12 +10,14 @@
 #ifndef _UAPI_IP_SET_H
 #define _UAPI_IP_SET_H
 
-
 #include <linux/types.h>
 
 /* The protocol version */
 #define IPSET_PROTOCOL		6
 
+/* The maximum permissible comment length we will accept over netlink */
+#define IPSET_MAX_COMMENT_SIZE	255
+
 /* The max length of strings including NUL: set and type identifiers */
 #define IPSET_MAXNAMELEN	32
 
@@ -110,6 +112,7 @@ enum {
 	IPSET_ATTR_IFACE,
 	IPSET_ATTR_BYTES,
 	IPSET_ATTR_PACKETS,
+	IPSET_ATTR_COMMENT,
 	__IPSET_ATTR_ADT_MAX,
 };
 #define IPSET_ATTR_ADT_MAX	(__IPSET_ATTR_ADT_MAX - 1)
@@ -140,6 +143,7 @@ enum ipset_errno {
 	IPSET_ERR_IPADDR_IPV4,
 	IPSET_ERR_IPADDR_IPV6,
 	IPSET_ERR_COUNTER,
+	IPSET_ERR_COMMENT,
 
 	/* Type specific error codes */
 	IPSET_ERR_TYPE_SPECIFIC = 4352,
@@ -176,6 +180,8 @@ enum ipset_cadt_flags {
 	IPSET_FLAG_NOMATCH	= (1 << IPSET_FLAG_BIT_NOMATCH),
 	IPSET_FLAG_BIT_WITH_COUNTERS = 3,
 	IPSET_FLAG_WITH_COUNTERS = (1 << IPSET_FLAG_BIT_WITH_COUNTERS),
+	IPSET_FLAG_BIT_WITH_COMMENT = 4,
+	IPSET_FLAG_WITH_COMMENT = (1 << IPSET_FLAG_BIT_WITH_COMMENT),
 	IPSET_FLAG_CADT_MAX	= 15,
 };
 
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index f35afed..3bf9a3d 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -315,6 +315,7 @@ ip_set_get_ipaddr6(struct nlattr *nla, union nf_inet_addr *ipaddr)
 }
 EXPORT_SYMBOL_GPL(ip_set_get_ipaddr6);
 
+typedef void (*destroyer)(void *);
 /* ipset data extension types, in size order */
 
 const struct ip_set_ext_type ip_set_extensions[] = {
@@ -329,6 +330,13 @@ const struct ip_set_ext_type ip_set_extensions[] = {
 		.len	= sizeof(unsigned long),
 		.align	= __alignof__(unsigned long),
 	},
+	[IPSET_EXT_ID_COMMENT] = {
+		.type	 = IPSET_EXT_COMMENT | IPSET_EXT_DESTROY,
+		.flag	 = IPSET_FLAG_WITH_COMMENT,
+		.len	 = sizeof(struct ip_set_comment),
+		.align	 = __alignof__(struct ip_set_comment),
+		.destroy = (destroyer) ip_set_comment_free,
+	},
 };
 EXPORT_SYMBOL_GPL(ip_set_extensions);
 
@@ -380,6 +388,12 @@ ip_set_get_extensions(struct ip_set *set, struct nlattr *tb[],
 			ext->packets = be64_to_cpu(nla_get_be64(
 						   tb[IPSET_ATTR_PACKETS]));
 	}
+	if (tb[IPSET_ATTR_COMMENT]) {
+		if (!(set->extensions & IPSET_EXT_COMMENT))
+			return -IPSET_ERR_COMMENT;
+		ext->comment = ip_set_comment_uget(tb[IPSET_ATTR_COMMENT]);
+	}
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ip_set_get_extensions);
-- 
1.7.10.4
