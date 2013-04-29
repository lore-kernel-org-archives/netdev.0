From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/18] netfilter: ipset: Introduce extensions to elements in the core
Date: Mon, 29 Apr 2013 20:22:09 +0200
Message-ID: <1367259744-8922-4-git-send-email-pablo@netfilter.org>
References: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Introduce extensions to elements in the core and prepare timeout as
the first one.

This patch also modifies the em_ipset classifier to use the new
extension struct layout.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set.h         |   46 +++++++++--
 include/linux/netfilter/ipset/ip_set_timeout.h |  102 +++++-------------------
 net/netfilter/ipset/ip_set_core.c              |   24 ++++--
 net/netfilter/xt_set.c                         |   24 ++----
 net/sched/em_ipset.c                           |    2 +-
 5 files changed, 87 insertions(+), 111 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 9701871..bf0220c 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -1,7 +1,7 @@
 /* Copyright (C) 2000-2002 Joakim Axelsson <gozem@linux.nu>
  *                         Patrick Schaaf <bof@bof.de>
  *                         Martin Josefsson <gandalf@wlug.westbo.se>
- * Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ * Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -47,10 +47,30 @@ enum ip_set_feature {
 	IPSET_DUMP_LAST = (1 << IPSET_DUMP_LAST_FLAG),
 };
 
+/* Set extensions */
+enum ip_set_extension {
+	IPSET_EXT_NONE = 0,
+	IPSET_EXT_BIT_TIMEOUT = 1,
+	IPSET_EXT_TIMEOUT = (1 << IPSET_EXT_BIT_TIMEOUT),
+};
+
+/* Extension offsets */
+enum ip_set_offset {
+	IPSET_OFFSET_TIMEOUT = 0,
+	IPSET_OFFSET_MAX,
+};
+
+#define SET_WITH_TIMEOUT(s)	((s)->extensions & IPSET_EXT_TIMEOUT)
+
+struct ip_set_ext {
+	unsigned long timeout;
+};
+
 struct ip_set;
 
 typedef int (*ipset_adtfn)(struct ip_set *set, void *value,
-			   u32 timeout, u32 flags);
+			   const struct ip_set_ext *ext,
+			   struct ip_set_ext *mext, u32 flags);
 
 /* Kernel API function options */
 struct ip_set_adt_opt {
@@ -58,7 +78,7 @@ struct ip_set_adt_opt {
 	u8 dim;			/* Dimension of match/target */
 	u8 flags;		/* Direction and negation flags */
 	u32 cmdflags;		/* Command-like flags */
-	u32 timeout;		/* Timeout value */
+	struct ip_set_ext ext;	/* Extensions */
 };
 
 /* Set type, variant-specific part */
@@ -69,7 +89,7 @@ struct ip_set_type_variant {
 	 *			positive for matching element */
 	int (*kadt)(struct ip_set *set, const struct sk_buff *skb,
 		    const struct xt_action_param *par,
-		    enum ipset_adt adt, const struct ip_set_adt_opt *opt);
+		    enum ipset_adt adt, struct ip_set_adt_opt *opt);
 
 	/* Userspace: test/add/del entries
 	 *		returns negative error code,
@@ -151,6 +171,8 @@ struct ip_set {
 	u8 family;
 	/* The type revision */
 	u8 revision;
+	/* Extensions */
+	u8 extensions;
 	/* The type specific data */
 	void *data;
 };
@@ -167,19 +189,21 @@ extern void ip_set_nfnl_put(ip_set_id_t index);
 
 extern int ip_set_add(ip_set_id_t id, const struct sk_buff *skb,
 		      const struct xt_action_param *par,
-		      const struct ip_set_adt_opt *opt);
+		      struct ip_set_adt_opt *opt);
 extern int ip_set_del(ip_set_id_t id, const struct sk_buff *skb,
 		      const struct xt_action_param *par,
-		      const struct ip_set_adt_opt *opt);
+		      struct ip_set_adt_opt *opt);
 extern int ip_set_test(ip_set_id_t id, const struct sk_buff *skb,
 		       const struct xt_action_param *par,
-		       const struct ip_set_adt_opt *opt);
+		       struct ip_set_adt_opt *opt);
 
 /* Utility functions */
 extern void *ip_set_alloc(size_t size);
 extern void ip_set_free(void *members);
 extern int ip_set_get_ipaddr4(struct nlattr *nla,  __be32 *ipaddr);
 extern int ip_set_get_ipaddr6(struct nlattr *nla, union nf_inet_addr *ipaddr);
+extern int ip_set_get_extensions(struct ip_set *set, struct nlattr *tb[],
+				 struct ip_set_ext *ext);
 
 static inline int
 ip_set_get_hostipaddr4(struct nlattr *nla, u32 *ipaddr)
@@ -292,4 +316,12 @@ bitmap_bytes(u32 a, u32 b)
 	return 4 * ((((b - a + 8) / 8) + 3) / 4);
 }
 
+#include <linux/netfilter/ipset/ip_set_timeout.h>
+
+#define IP_SET_INIT_KEXT(skb, opt, map)		\
+	{ .timeout = ip_set_adt_opt_timeout(opt, map) }
+
+#define IP_SET_INIT_UEXT(map)			\
+	{ .timeout = (map)->timeout }
+
 #endif /*_IP_SET_H */
diff --git a/include/linux/netfilter/ipset/ip_set_timeout.h b/include/linux/netfilter/ipset/ip_set_timeout.h
index 41d9cfa..3aac041 100644
--- a/include/linux/netfilter/ipset/ip_set_timeout.h
+++ b/include/linux/netfilter/ipset/ip_set_timeout.h
@@ -1,7 +1,7 @@
 #ifndef _IP_SET_TIMEOUT_H
 #define _IP_SET_TIMEOUT_H
 
-/* Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+/* Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -17,13 +17,14 @@
 #define IPSET_GC_PERIOD(timeout) \
 	((timeout/3) ? min_t(u32, (timeout)/3, IPSET_GC_TIME) : 1)
 
-/* Set is defined without timeout support: timeout value may be 0 */
-#define IPSET_NO_TIMEOUT	UINT_MAX
+/* Entry is set with no timeout value */
+#define IPSET_ELEM_PERMANENT	0
 
-#define with_timeout(timeout)	((timeout) != IPSET_NO_TIMEOUT)
+/* Set is defined with timeout support: timeout value may be 0 */
+#define IPSET_NO_TIMEOUT	UINT_MAX
 
-#define opt_timeout(opt, map)	\
-	(with_timeout((opt)->timeout) ? (opt)->timeout : (map)->timeout)
+#define ip_set_adt_opt_timeout(opt, map)	\
+((opt)->ext.timeout != IPSET_NO_TIMEOUT ? (opt)->ext.timeout : (map)->timeout)
 
 static inline unsigned int
 ip_set_timeout_uget(struct nlattr *tb)
@@ -38,61 +39,6 @@ ip_set_timeout_uget(struct nlattr *tb)
 	return timeout == IPSET_NO_TIMEOUT ? IPSET_NO_TIMEOUT - 1 : timeout;
 }
 
-#ifdef IP_SET_BITMAP_TIMEOUT
-
-/* Bitmap specific timeout constants and macros for the entries */
-
-/* Bitmap entry is unset */
-#define IPSET_ELEM_UNSET	0
-/* Bitmap entry is set with no timeout value */
-#define IPSET_ELEM_PERMANENT	(UINT_MAX/2)
-
-static inline bool
-ip_set_timeout_test(unsigned long timeout)
-{
-	return timeout != IPSET_ELEM_UNSET &&
-	       (timeout == IPSET_ELEM_PERMANENT ||
-		time_is_after_jiffies(timeout));
-}
-
-static inline bool
-ip_set_timeout_expired(unsigned long timeout)
-{
-	return timeout != IPSET_ELEM_UNSET &&
-	       timeout != IPSET_ELEM_PERMANENT &&
-	       time_is_before_jiffies(timeout);
-}
-
-static inline unsigned long
-ip_set_timeout_set(u32 timeout)
-{
-	unsigned long t;
-
-	if (!timeout)
-		return IPSET_ELEM_PERMANENT;
-
-	t = msecs_to_jiffies(timeout * 1000) + jiffies;
-	if (t == IPSET_ELEM_UNSET || t == IPSET_ELEM_PERMANENT)
-		/* Bingo! */
-		t++;
-
-	return t;
-}
-
-static inline u32
-ip_set_timeout_get(unsigned long timeout)
-{
-	return timeout == IPSET_ELEM_PERMANENT ? 0 :
-		jiffies_to_msecs(timeout - jiffies)/1000;
-}
-
-#else
-
-/* Hash specific timeout constants and macros for the entries */
-
-/* Hash entry is set with no timeout value */
-#define IPSET_ELEM_PERMANENT	0
-
 static inline bool
 ip_set_timeout_test(unsigned long timeout)
 {
@@ -101,36 +47,32 @@ ip_set_timeout_test(unsigned long timeout)
 }
 
 static inline bool
-ip_set_timeout_expired(unsigned long timeout)
+ip_set_timeout_expired(unsigned long *timeout)
 {
-	return timeout != IPSET_ELEM_PERMANENT &&
-	       time_is_before_jiffies(timeout);
+	return *timeout != IPSET_ELEM_PERMANENT &&
+	       time_is_before_jiffies(*timeout);
 }
 
-static inline unsigned long
-ip_set_timeout_set(u32 timeout)
+static inline void
+ip_set_timeout_set(unsigned long *timeout, u32 t)
 {
-	unsigned long t;
-
-	if (!timeout)
-		return IPSET_ELEM_PERMANENT;
+	if (!t) {
+		*timeout = IPSET_ELEM_PERMANENT;
+		return;
+	}
 
-	t = msecs_to_jiffies(timeout * 1000) + jiffies;
-	if (t == IPSET_ELEM_PERMANENT)
+	*timeout = msecs_to_jiffies(t * 1000) + jiffies;
+	if (*timeout == IPSET_ELEM_PERMANENT)
 		/* Bingo! :-) */
-		t++;
-
-	return t;
+		(*timeout)--;
 }
 
 static inline u32
-ip_set_timeout_get(unsigned long timeout)
+ip_set_timeout_get(unsigned long *timeout)
 {
-	return timeout == IPSET_ELEM_PERMANENT ? 0 :
-		jiffies_to_msecs(timeout - jiffies)/1000;
+	return *timeout == IPSET_ELEM_PERMANENT ? 0 :
+		jiffies_to_msecs(*timeout - jiffies)/1000;
 }
-#endif /* ! IP_SET_BITMAP_TIMEOUT */
 
 #endif	/* __KERNEL__ */
-
 #endif /* _IP_SET_TIMEOUT_H */
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 86f5e26..4486285d 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1,6 +1,6 @@
 /* Copyright (C) 2000-2002 Joakim Axelsson <gozem@linux.nu>
  *                         Patrick Schaaf <bof@bof.de>
- * Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ * Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -315,6 +315,19 @@ ip_set_get_ipaddr6(struct nlattr *nla, union nf_inet_addr *ipaddr)
 }
 EXPORT_SYMBOL_GPL(ip_set_get_ipaddr6);
 
+int
+ip_set_get_extensions(struct ip_set *set, struct nlattr *tb[],
+		      struct ip_set_ext *ext)
+{
+	if (tb[IPSET_ATTR_TIMEOUT]) {
+		if (!(set->extensions & IPSET_EXT_TIMEOUT))
+			return -IPSET_ERR_TIMEOUT;
+		ext->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ip_set_get_extensions);
+
 /*
  * Creating/destroying/renaming/swapping affect the existence and
  * the properties of a set. All of these can be executed from userspace
@@ -365,8 +378,7 @@ ip_set_rcu_get(ip_set_id_t index)
 
 int
 ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
-	    const struct xt_action_param *par,
-	    const struct ip_set_adt_opt *opt)
+	    const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
 	struct ip_set *set = ip_set_rcu_get(index);
 	int ret = 0;
@@ -404,8 +416,7 @@ EXPORT_SYMBOL_GPL(ip_set_test);
 
 int
 ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
-	   const struct xt_action_param *par,
-	   const struct ip_set_adt_opt *opt)
+	   const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
 	struct ip_set *set = ip_set_rcu_get(index);
 	int ret;
@@ -427,8 +438,7 @@ EXPORT_SYMBOL_GPL(ip_set_add);
 
 int
 ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
-	   const struct xt_action_param *par,
-	   const struct ip_set_adt_opt *opt)
+	   const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
 	struct ip_set *set = ip_set_rcu_get(index);
 	int ret = 0;
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 865a9e5..636c519 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -1,7 +1,7 @@
 /* Copyright (C) 2000-2002 Joakim Axelsson <gozem@linux.nu>
  *                         Patrick Schaaf <bof@bof.de>
  *                         Martin Josefsson <gandalf@wlug.westbo.se>
- * Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ * Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -30,7 +30,7 @@ MODULE_ALIAS("ip6t_SET");
 static inline int
 match_set(ip_set_id_t index, const struct sk_buff *skb,
 	  const struct xt_action_param *par,
-	  const struct ip_set_adt_opt *opt, int inv)
+	  struct ip_set_adt_opt *opt, int inv)
 {
 	if (ip_set_test(index, skb, par, opt))
 		inv = !inv;
@@ -38,20 +38,12 @@ match_set(ip_set_id_t index, const struct sk_buff *skb,
 }
 
 #define ADT_OPT(n, f, d, fs, cfs, t)	\
-const struct ip_set_adt_opt n = {	\
-	.family	= f,			\
-	.dim = d,			\
-	.flags = fs,			\
-	.cmdflags = cfs,		\
-	.timeout = t,			\
-}
-#define ADT_MOPT(n, f, d, fs, cfs, t)	\
 struct ip_set_adt_opt n = {		\
 	.family	= f,			\
 	.dim = d,			\
 	.flags = fs,			\
 	.cmdflags = cfs,		\
-	.timeout = t,			\
+	.ext.timeout = t,		\
 }
 
 /* Revision 0 interface: backward compatible with netfilter/iptables */
@@ -305,15 +297,15 @@ static unsigned int
 set_target_v2(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_set_info_target_v2 *info = par->targinfo;
-	ADT_MOPT(add_opt, par->family, info->add_set.dim,
-		 info->add_set.flags, info->flags, info->timeout);
+	ADT_OPT(add_opt, par->family, info->add_set.dim,
+		info->add_set.flags, info->flags, info->timeout);
 	ADT_OPT(del_opt, par->family, info->del_set.dim,
 		info->del_set.flags, 0, UINT_MAX);
 
 	/* Normalize to fit into jiffies */
-	if (add_opt.timeout != IPSET_NO_TIMEOUT &&
-	    add_opt.timeout > UINT_MAX/MSEC_PER_SEC)
-		add_opt.timeout = UINT_MAX/MSEC_PER_SEC;
+	if (add_opt.ext.timeout != IPSET_NO_TIMEOUT &&
+	    add_opt.ext.timeout > UINT_MAX/MSEC_PER_SEC)
+		add_opt.ext.timeout = UINT_MAX/MSEC_PER_SEC;
 	if (info->add_set.index != IPSET_INVALID_ID)
 		ip_set_add(info->add_set.index, skb, par, &add_opt);
 	if (info->del_set.index != IPSET_INVALID_ID)
diff --git a/net/sched/em_ipset.c b/net/sched/em_ipset.c
index 3130320..938b7cb 100644
--- a/net/sched/em_ipset.c
+++ b/net/sched/em_ipset.c
@@ -83,7 +83,7 @@ static int em_ipset_match(struct sk_buff *skb, struct tcf_ematch *em,
 	opt.dim = set->dim;
 	opt.flags = set->flags;
 	opt.cmdflags = 0;
-	opt.timeout = ~0u;
+	opt.ext.timeout = ~0u;
 
 	network_offset = skb_network_offset(skb);
 	skb_pull(skb, network_offset);
-- 
1.7.10.4

