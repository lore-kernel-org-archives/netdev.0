From: Florian Westphal <fw@strlen.de>
Subject: [RFC PATCH] netfilter: conntrack: cache route for forwarded connections
Date: Tue,  2 Dec 2014 01:28:34 +0100
Message-ID: <1417480114-3002-1-git-send-email-fw@strlen.de>
Cc: brouer@redhat.com, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

... to avoid per-packet FIB lookup if possible.

The cached dst is re-used provided the input interface
is the same as that of the previous packet in the same direction.

If not, the cached dst is invalidated.

This should speed up forwarding when conntrack is already in use
anyway, especially when using reverse path filtering -- active RPF
enforces two FIB lookups for each packet.

Before the routing cache removal this didn't matter since RPF
was performed only when route cache didn't yield a result; but without
route cache it comes at high price.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Sending as RFC since I haven't tested this yet (aside from
 single-forwarded-flow), so no performance data either.

  - doesn't work when iif changes (it invalidates cached dst), don't
  think its a problem
  - auto-active when module is loaded (and always active when =y).
  - cache becomes used after conntrack enters ASSURED state.

  TODOs:
  - integrate with netfilter ipv4/ipv6 rpfilter match (already working on this)

  Things to consider:
  - perhaps extend it for local connections too; could cache
  socket to get sk from conntrack (and then fetchg dst from sk).

 include/net/netfilter/nf_conntrack_extend.h  |   4 +
 include/net/netfilter/nf_conntrack_rtcache.h |  28 +++
 net/netfilter/Kconfig                        |  11 +
 net/netfilter/Makefile                       |   1 +
 net/netfilter/nf_conntrack_rtcache.c         | 327 +++++++++++++++++++++++++++
 5 files changed, 371 insertions(+)
 create mode 100644 include/net/netfilter/nf_conntrack_rtcache.h
 create mode 100644 net/netfilter/nf_conntrack_rtcache.c

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 55d1504..1b00d57 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -30,6 +30,9 @@ enum nf_ct_ext_id {
 #if IS_ENABLED(CONFIG_NETFILTER_SYNPROXY)
 	NF_CT_EXT_SYNPROXY,
 #endif
+#if IS_ENABLED(CONFIG_NF_CONNTRACK_RTCACHE)
+	NF_CT_EXT_RTCACHE,
+#endif
 	NF_CT_EXT_NUM,
 };
 
@@ -43,6 +46,7 @@ enum nf_ct_ext_id {
 #define NF_CT_EXT_TIMEOUT_TYPE struct nf_conn_timeout
 #define NF_CT_EXT_LABELS_TYPE struct nf_conn_labels
 #define NF_CT_EXT_SYNPROXY_TYPE struct nf_conn_synproxy
+#define NF_CT_EXT_RTCACHE_TYPE struct nf_conn_rtcache
 
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
diff --git a/include/net/netfilter/nf_conntrack_rtcache.h b/include/net/netfilter/nf_conntrack_rtcache.h
new file mode 100644
index 0000000..e8d215d
--- /dev/null
+++ b/include/net/netfilter/nf_conntrack_rtcache.h
@@ -0,0 +1,28 @@
+#include <linux/gfp.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_extend.h>
+
+struct dst_entry;
+union nf_conn_cache_ptr {
+	struct dst_entry *dst;
+};
+
+struct nf_conn_rtcache {
+	union nf_conn_cache_ptr ptr[IP_CT_DIR_MAX];
+	int iif[IP_CT_DIR_MAX];
+};
+
+static inline struct nf_conn_rtcache *nf_ct_rtcache_find(const struct nf_conn *ct)
+{
+#if IS_ENABLED(CONFIG_NF_CONNTRACK_RTCACHE)
+	return nf_ct_ext_find(ct, NF_CT_EXT_RTCACHE);
+#else
+	return NULL;
+#endif
+}
+
+static inline int nf_conn_rtcache_iif_get(const struct nf_conn_rtcache *rtc,
+					  enum ip_conntrack_dir dir)
+{
+	return rtc->iif[dir];
+}
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index b02660f..4a8b7e7 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -106,6 +106,17 @@ config NF_CONNTRACK_EVENTS
 
 	  If unsure, say `N'.
 
+config NF_CONNTRACK_RTCACHE
+	tristate "Cache route entries in conntrack objects"
+	depends on NETFILTER_ADVANCED
+	depends on NF_CONNTRACK
+	help
+	  If this option is enabled, the connection tracking code will
+	  cache routing information for each connection that is being
+	  forwarded.
+
+	  If unsure, say `N'.
+
 config NF_CONNTRACK_TIMEOUT
 	bool  'Connection tracking timeout'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 89f73a9..ac830c9 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -5,6 +5,7 @@ nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMEOUT) += nf_conntrack_timeout.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMESTAMP) += nf_conntrack_timestamp.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_EVENTS) += nf_conntrack_ecache.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_LABELS) += nf_conntrack_labels.o
+nf_conntrack-$(CONFIG_NF_CONNTRACK_RTCACHE) += nf_conntrack_rtcache.o
 
 obj-$(CONFIG_NETFILTER) = netfilter.o
 
diff --git a/net/netfilter/nf_conntrack_rtcache.c b/net/netfilter/nf_conntrack_rtcache.c
new file mode 100644
index 0000000..1013987
--- /dev/null
+++ b/net/netfilter/nf_conntrack_rtcache.c
@@ -0,0 +1,327 @@
+/* route cache for netfilter.
+ *
+ * (C) 2014 Red Hat GmbH
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/types.h>
+#include <linux/netfilter.h>
+#include <linux/skbuff.h>
+#include <linux/stddef.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/export.h>
+#include <linux/module.h>
+
+#include <net/dst.h>
+
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_extend.h>
+#include <net/netfilter/nf_conntrack_rtcache.h>
+
+static void __nf_conn_rtcache_destroy(struct nf_conn_rtcache *rtc, int dir)
+{
+	struct dst_entry *dst;
+
+	if (rtc->iif[dir] < 0)
+		return;
+
+	dst = rtc->ptr[dir].dst;
+	pr_debug("release dst %p, refcnt %d, dir %d\n", dst, atomic_read(&dst->__refcnt), dir);
+	dst_release(dst);
+}
+
+static void nf_conn_rtcache_destroy(struct nf_conn *ct)
+{
+	struct nf_conn_rtcache *rtc = nf_ct_rtcache_find(ct);
+
+	if (!rtc)
+		return;
+
+	__nf_conn_rtcache_destroy(rtc, IP_CT_DIR_ORIGINAL);
+	__nf_conn_rtcache_destroy(rtc, IP_CT_DIR_REPLY);
+}
+
+static void nf_ct_rtcache_ext_add(struct nf_conn *ct)
+{
+	struct nf_conn_rtcache *rtc;
+
+	rtc = nf_ct_ext_add(ct, NF_CT_EXT_RTCACHE, GFP_ATOMIC);
+	if (rtc) {
+		rtc->iif[IP_CT_DIR_ORIGINAL] = -1;
+		rtc->iif[IP_CT_DIR_REPLY] = -1;
+	}
+}
+
+static bool nf_rtcache_ignore_ct(struct nf_conn *ct)
+{
+	if (nf_ct_is_untracked(ct))
+		return true;
+
+	if (!test_bit(IPS_ASSURED_BIT, &ct->status))
+		return true;
+	return false;
+}
+
+static struct nf_conn_rtcache *nf_ct_rtcache_find_usable(struct nf_conn *ct)
+{
+	if (nf_rtcache_ignore_ct(ct))
+		return NULL;
+	return nf_ct_rtcache_find(ct);
+}
+
+static struct dst_entry *
+nf_conn_rtcache_dst_get(const struct nf_conn_rtcache *rtc,
+		        enum ip_conntrack_dir dir)
+{
+	return rtc->ptr[dir].dst;
+}
+
+static void nf_conn_rtcache_dst_set(struct nf_conn_rtcache *rtc,
+				    struct dst_entry *dst,
+				    enum ip_conntrack_dir dir, int iif)
+{
+	if (rtc->iif[dir] != iif)
+		rtc->iif[dir] = iif;
+
+	if (rtc->ptr[dir].dst != dst) {
+		struct dst_entry *old;
+
+		dst_hold(dst);
+
+		old = xchg(&rtc->ptr[dir].dst, dst);
+		dst_release(old);
+	}
+}
+
+static void nf_conn_rtcache_dst_obsolete(struct nf_conn_rtcache *rtc,
+					 enum ip_conntrack_dir dir)
+{
+	struct dst_entry *old;
+
+	pr_debug("Invalidate iif %d for dir %d on cache %p\n",
+		   rtc->iif[dir], dir, rtc);
+
+	old = xchg(&rtc->ptr[dir].dst, NULL);
+	dst_release(old);
+	rtc->iif[dir] = -1;
+}
+
+static unsigned int nf_rtcache_in(const struct nf_hook_ops *ops,
+				  struct sk_buff *skb,
+				  const struct net_device *in,
+				  const struct net_device *out,
+				  int (*okfn)(struct sk_buff *))
+{
+	struct nf_conn_rtcache *ct_rtcache;
+	enum ip_conntrack_info ctinfo;
+	enum ip_conntrack_dir dir;
+	struct dst_entry *dst;
+	struct nf_conn *ct;
+	int iif;
+
+	if (in == NULL || skb_dst(skb))
+		return NF_ACCEPT;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct)
+		return NF_ACCEPT;
+
+	ct_rtcache = nf_ct_rtcache_find_usable(ct);
+	if (!ct_rtcache)
+		return NF_ACCEPT;
+
+	/* if iif changes, don't use cache and let ip stack
+	 * do route lookup.
+	 *
+	 * If rp_filter is enabled it might toss skb, so
+	 * we don't want to avoid these checks.
+	 */
+	dir = CTINFO2DIR(ctinfo);
+	iif = nf_conn_rtcache_iif_get(ct_rtcache, dir);
+	if (in->ifindex != iif) {
+		pr_debug("iif %d did not match cached iif %d of ct %p\n\n", iif, in->ifindex, ct);
+		return NF_ACCEPT;
+	}
+	dst = nf_conn_rtcache_dst_get(ct_rtcache, dir);
+	if (dst == NULL)
+		return NF_ACCEPT;
+	dst = dst_check(dst, 0);
+	if (likely(dst)) {
+		pr_debug("using cached dst %p for skb %p\n", dst, skb);
+		skb_dst_set_noref_force(skb, dst);
+	} else {
+		nf_conn_rtcache_dst_obsolete(ct_rtcache, dir);
+	}
+	return NF_ACCEPT;
+}
+
+static unsigned int nf_rtcache_forward(const struct nf_hook_ops *ops,
+				       struct sk_buff *skb,
+				       const struct net_device *in,
+				       const struct net_device *out,
+				       int (*okfn)(struct sk_buff *))
+{
+	struct nf_conn_rtcache *ct_rtcache;
+	enum ip_conntrack_info ctinfo;
+	enum ip_conntrack_dir dir;
+	struct dst_entry *dst;
+	struct nf_conn *ct;
+	int iif;
+
+	dst = skb_dst(skb);
+	if (WARN_ON_ONCE(dst == NULL || in == NULL))
+		return NF_ACCEPT;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct)
+		return NF_ACCEPT;
+
+	if (!nf_ct_is_confirmed(ct)) {
+		pr_debug("new ct %p, skb %p, adding rtcache extension\n", ct, skb);
+		BUG_ON(nf_ct_rtcache_find(ct));
+		nf_ct_rtcache_ext_add(ct);
+		return NF_ACCEPT;
+	}
+
+	ct_rtcache = nf_ct_rtcache_find_usable(ct);
+	if (!ct_rtcache)
+		return NF_ACCEPT;
+
+	dir = CTINFO2DIR(ctinfo);
+	iif = nf_conn_rtcache_iif_get(ct_rtcache, dir);
+	pr_debug("ct %p, skb %p, dir %d, iif %d, cached iif %d\n", ct, skb, dir, iif, in->ifindex);
+	if (likely(in->ifindex == iif))
+		return NF_ACCEPT;
+
+	nf_conn_rtcache_dst_set(ct_rtcache, dst, dir, in->ifindex);
+	return NF_ACCEPT;
+}
+
+static struct nf_hook_ops rtcache_ops[] = {
+	{
+		.hook		= nf_rtcache_in,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV4,
+		.hooknum	= NF_INET_PRE_ROUTING,
+		.priority       = NF_IP_PRI_LAST,
+	},
+	{
+		.hook           = nf_rtcache_forward,
+		.owner          = THIS_MODULE,
+		.pf             = NFPROTO_IPV4,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = NF_IP_PRI_LAST,
+	},
+#if IS_ENABLED(CONFIG_NF_CONNTRACK_IPV6)
+	{
+		.hook		= nf_rtcache_in,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_PRE_ROUTING,
+		.priority       = NF_IP_PRI_LAST,
+	},
+	{
+		.hook           = nf_rtcache_forward,
+		.owner          = THIS_MODULE,
+		.pf             = NFPROTO_IPV6,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = NF_IP_PRI_LAST,
+	},
+#endif
+};
+
+static struct nf_ct_ext_type rtcache_extend __read_mostly = {
+	.len	= sizeof(struct nf_conn_rtcache),
+	.align	= __alignof__(struct nf_conn_rtcache),
+	.id	= NF_CT_EXT_RTCACHE,
+	.destroy = nf_conn_rtcache_destroy,
+};
+
+int __init nf_conntrack_rtcache_init(void)
+{
+	int ret = nf_ct_extend_register(&rtcache_extend);
+	if (ret < 0) {
+		pr_err("nf_conntrack_rtcache: Unable to register extension\n");
+		return ret;
+	}
+
+	ret = nf_register_hooks(rtcache_ops, ARRAY_SIZE(rtcache_ops));
+	if (ret < 0) {
+		nf_ct_extend_unregister(&rtcache_extend);
+		return ret;
+	}
+
+	return ret;
+}
+
+static int nf_rtcache_ext_remove(struct nf_conn *ct, void *data)
+{
+	struct nf_conn_rtcache *rtc = nf_ct_rtcache_find(ct);
+	return rtc != NULL;
+}
+
+void __exit nf_conntrack_rtcache_fini(void)
+{
+	struct net *net;
+	bool wait;
+	int cpu, count = 0;
+
+	/* first remove hooks so no new connections get rtcache extension */
+	nf_unregister_hooks(rtcache_ops, ARRAY_SIZE(rtcache_ops));
+
+	synchronize_net();
+
+	/* zap all conntracks with rtcache extension */
+	for_each_net(net)
+		nf_ct_iterate_cleanup(net, nf_rtcache_ext_remove, NULL, 0, 0);
+
+	/* again, so that affected conntracks on the unconfirmed list are now
+	 * free'd or on dying list */
+	synchronize_net();
+
+	/* ... and wait until dying list contains no affected items any more */
+	do {
+		wait = false;
+		for_each_possible_cpu(cpu) {
+			struct nf_conntrack_tuple_hash *h;
+			struct hlist_nulls_node *n;
+			struct nf_conn *ct;
+			struct ct_pcpu *pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
+
+			rcu_read_lock();
+			spin_lock_bh(&pcpu->lock);
+
+			hlist_nulls_for_each_entry(h, n, &pcpu->unconfirmed, hnnode) {
+				ct = nf_ct_tuplehash_to_ctrack(h);
+				if (nf_ct_rtcache_find(ct) != NULL) {
+					wait = true;
+					break;
+				}
+			}
+			spin_unlock_bh(&pcpu->lock);
+			rcu_read_unlock();
+
+			if (wait) {
+				/* conntrack on dying list, i.e. waiting for
+				 * some event, e.g. reinject or whatever */
+				msleep(200);
+				WARN_ONCE(++count > 25, "Waiting for all rtcache conntracks to go away\n");
+			}
+		}
+	} while (wait);
+
+	nf_ct_extend_unregister(&rtcache_extend);
+}
+module_init(nf_conntrack_rtcache_init);
+module_exit(nf_conntrack_rtcache_fini);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
+MODULE_DESCRIPTION("Conntrack route cache extension");
-- 
2.0.4

