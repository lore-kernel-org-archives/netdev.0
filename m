From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 2/2] netfilter: use conntrack rtcache if available
Date: Mon,  8 Dec 2014 16:36:04 +0100
Message-ID: <1418052964-4632-3-git-send-email-fw@strlen.de>
References: <1418052964-4632-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, brouer@redhat.com,
	Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52449 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755101AbaLHPgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 10:36:15 -0500
In-Reply-To: <1418052964-4632-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skip the reverse lookup if the iif matches the cached one.
In this case we know that a previous rpfilter check did not result
in packet drop.

This shortcut only works if rtcache is available and rule is placed
in mangle table (raw table is too early; skb->nfct will not be set).

While it would be possible to enforce rtcache, it would a)
force a dependency on conntrack and b) break backwards compatibility
since we'd have to restrict it to mangle table.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/netfilter/nf_conntrack_rtcache.h | 12 +++++++++++
 net/ipv4/netfilter/ipt_rpfilter.c            |  4 +++-
 net/ipv6/netfilter/ip6t_rpfilter.c           |  4 +++-
 net/netfilter/core.c                         | 30 ++++++++++++++++++++++++++++
 4 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_rtcache.h b/include/net/netfilter/nf_conntrack_rtcache.h
index e2fb302..19265ad 100644
--- a/include/net/netfilter/nf_conntrack_rtcache.h
+++ b/include/net/netfilter/nf_conntrack_rtcache.h
@@ -27,6 +27,18 @@ struct nf_conn_rtcache *nf_ct_rtcache_find(const struct nf_conn *ct)
 #endif
 }
 
+#if IS_ENABLED(CONFIG_NF_CONNTRACK_RTCACHE)
+bool nf_conn_rtcache_match_dev(const struct sk_buff *skb,
+			       const struct net_device *dev);
+#else
+static inline bool
+nf_conn_rtcache_match_dev(const struct sk_buff *skb,
+			  const struct net_device *dev)
+{
+	return false;
+}
+#endif
+
 static inline int nf_conn_rtcache_iif_get(const struct nf_conn_rtcache *rtc,
 					  enum ip_conntrack_dir dir)
 {
diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index 4bfaedf..f39e934 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -19,6 +19,8 @@
 #include <linux/netfilter/xt_rpfilter.h>
 #include <linux/netfilter/x_tables.h>
 
+#include <net/netfilter/nf_conntrack_rtcache.h>
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
 MODULE_DESCRIPTION("iptables: ipv4 reverse path filter match");
@@ -82,7 +84,7 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	info = par->matchinfo;
 	invert = info->flags & XT_RPFILTER_INVERT;
 
-	if (rpfilter_is_local(skb))
+	if (rpfilter_is_local(skb) || nf_conn_rtcache_match_dev(skb, par->in))
 		return true ^ invert;
 
 	iph = ip_hdr(skb);
diff --git a/net/ipv6/netfilter/ip6t_rpfilter.c b/net/ipv6/netfilter/ip6t_rpfilter.c
index 790e0c6..8db9fe7 100644
--- a/net/ipv6/netfilter/ip6t_rpfilter.c
+++ b/net/ipv6/netfilter/ip6t_rpfilter.c
@@ -16,6 +16,8 @@
 #include <linux/netfilter/xt_rpfilter.h>
 #include <linux/netfilter/x_tables.h>
 
+#include <net/netfilter/nf_conntrack_rtcache.h>
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
 MODULE_DESCRIPTION("Xtables: IPv6 reverse path filter match");
@@ -85,7 +87,7 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	struct ipv6hdr *iph;
 	bool invert = info->flags & XT_RPFILTER_INVERT;
 
-	if (rpfilter_is_local(skb))
+	if (rpfilter_is_local(skb) || nf_conn_rtcache_match_dev(skb, par->in))
 		return true ^ invert;
 
 	iph = ipv6_hdr(skb);
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index fea9ef5..651b4c6 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -25,6 +25,8 @@
 #include <net/net_namespace.h>
 #include <net/sock.h>
 
+#include <net/netfilter/nf_conntrack_rtcache.h>
+
 #include "nf_internals.h"
 
 static DEFINE_MUTEX(afinfo_mutex);
@@ -267,6 +269,34 @@ EXPORT_SYMBOL_GPL(nfq_ct_hook);
 struct nfq_ct_nat_hook __rcu *nfq_ct_nat_hook __read_mostly;
 EXPORT_SYMBOL_GPL(nfq_ct_nat_hook);
 
+#if IS_ENABLED(CONFIG_NF_CONNTRACK_RTCACHE)
+/* returns true if dev matches the last recorded
+ * input interface of the conntrack attached to skb.
+ *
+ * This is not in conntrack to avoid module dependency.
+ */
+bool nf_conn_rtcache_match_dev(const struct sk_buff *skb,
+			       const struct net_device *dev)
+{
+	struct nf_conn_rtcache *rtc;
+	enum ip_conntrack_info ctinfo;
+	enum ip_conntrack_dir dir;
+	struct nf_conn *ct;
+	int iif;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	rtc = nf_ct_rtcache_find(ct);
+	if (!rtc)
+		return false;
+
+	dir = CTINFO2DIR(ctinfo);
+	iif = nf_conn_rtcache_iif_get(rtc, dir);
+
+	return iif == dev->ifindex;
+}
+EXPORT_SYMBOL_GPL(nf_conn_rtcache_match_dev);
+#endif
+
 #endif /* CONFIG_NF_CONNTRACK */
 
 #ifdef CONFIG_NF_NAT_NEEDED
-- 
2.0.4
