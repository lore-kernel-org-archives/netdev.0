From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/5] netfilter: add nf_ipv6_ops hook to fix xt_addrtype with IPv6
Date: Wed, 29 May 2013 18:03:09 +0200
Message-ID: <1369843394-24251-2-git-send-email-pablo@netfilter.org>
References: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Quoting https://bugzilla.netfilter.org/show_bug.cgi?id=812:

[ ip6tables -m addrtype ]
When I tried to use in the nat/PREROUTING it messes up the
routing cache even if the rule didn't matched at all.
[..]
If I remove the --limit-iface-in from the non-working scenario, so just
use the -m addrtype --dst-type LOCAL it works!

This happens when LOCAL type matching is requested with --limit-iface-in,
and the default ipv6 route is via the interface the packet we test
arrived on.

Because xt_addrtype uses ip6_route_output, the ipv6 routing implementation
creates an unwanted cached entry, and the packet won't make it to the
real/expected destination.

Silently ignoring --limit-iface-in makes the routing work but it breaks
rule matching (--dst-type LOCAL with limit-iface-in is supposed to only
match if the dst address is configured on the incoming interface;
without --limit-iface-in it will match if the address is reachable
via lo).

The test should call ipv6_chk_addr() instead.  However, this would add
a link-time dependency on ipv6.

There are two possible solutions:

1) Revert the commit that moved ipt_addrtype to xt_addrtype,
   and put ipv6 specific code into ip6t_addrtype.
2) add new "nf_ipv6_ops" struct to register pointers to ipv6 functions.

While the former might seem preferable, Pablo pointed out that there
are more xt modules with link-time dependeny issues regarding ipv6,
so lets go for 2).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_ipv6.h |   16 ++++++++++++++++
 include/net/addrconf.h         |    2 +-
 net/ipv6/addrconf.c            |    2 +-
 net/ipv6/netfilter.c           |    7 +++++++
 net/netfilter/core.c           |    2 ++
 net/netfilter/xt_addrtype.c    |   27 ++++++++++++++++-----------
 6 files changed, 43 insertions(+), 13 deletions(-)

diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index 98ffb54..2d4df6ce 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -17,6 +17,22 @@ extern __sum16 nf_ip6_checksum(struct sk_buff *skb, unsigned int hook,
 
 extern int ipv6_netfilter_init(void);
 extern void ipv6_netfilter_fini(void);
+
+/*
+ * Hook functions for ipv6 to allow xt_* modules to be built-in even
+ * if IPv6 is a module.
+ */
+struct nf_ipv6_ops {
+	int (*chk_addr)(struct net *net, const struct in6_addr *addr,
+			const struct net_device *dev, int strict);
+};
+
+extern const struct nf_ipv6_ops __rcu *nf_ipv6_ops;
+static inline const struct nf_ipv6_ops *nf_get_ipv6_ops(void)
+{
+	return rcu_dereference(nf_ipv6_ops);
+}
+
 #else /* CONFIG_NETFILTER */
 static inline int ipv6_netfilter_init(void) { return 0; }
 static inline void ipv6_netfilter_fini(void) { return; }
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 84a6440..21f70270 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -65,7 +65,7 @@ extern int			addrconf_set_dstaddr(struct net *net,
 
 extern int			ipv6_chk_addr(struct net *net,
 					      const struct in6_addr *addr,
-					      struct net_device *dev,
+					      const struct net_device *dev,
 					      int strict);
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d1ab6ab..d1b2d80 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1487,7 +1487,7 @@ static int ipv6_count_addresses(struct inet6_dev *idev)
 }
 
 int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
-		  struct net_device *dev, int strict)
+		  const struct net_device *dev, int strict)
 {
 	struct inet6_ifaddr *ifp;
 	unsigned int hash = inet6_addr_hash(addr);
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 72836f4..95f3f1d 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -10,6 +10,7 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
 #include <linux/export.h>
+#include <net/addrconf.h>
 #include <net/dst.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
@@ -186,6 +187,10 @@ static __sum16 nf_ip6_checksum_partial(struct sk_buff *skb, unsigned int hook,
 	return csum;
 };
 
+static const struct nf_ipv6_ops ipv6ops = {
+	.chk_addr	= ipv6_chk_addr,
+};
+
 static const struct nf_afinfo nf_ip6_afinfo = {
 	.family			= AF_INET6,
 	.checksum		= nf_ip6_checksum,
@@ -198,6 +203,7 @@ static const struct nf_afinfo nf_ip6_afinfo = {
 
 int __init ipv6_netfilter_init(void)
 {
+	RCU_INIT_POINTER(nf_ipv6_ops, &ipv6ops);
 	return nf_register_afinfo(&nf_ip6_afinfo);
 }
 
@@ -206,5 +212,6 @@ int __init ipv6_netfilter_init(void)
  */
 void ipv6_netfilter_fini(void)
 {
+	RCU_INIT_POINTER(nf_ipv6_ops, NULL);
 	nf_unregister_afinfo(&nf_ip6_afinfo);
 }
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 07c865a..857ca9f 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -30,6 +30,8 @@ static DEFINE_MUTEX(afinfo_mutex);
 
 const struct nf_afinfo __rcu *nf_afinfo[NFPROTO_NUMPROTO] __read_mostly;
 EXPORT_SYMBOL(nf_afinfo);
+const struct nf_ipv6_ops __rcu *nf_ipv6_ops __read_mostly;
+EXPORT_SYMBOL_GPL(nf_ipv6_ops);
 
 int nf_register_afinfo(const struct nf_afinfo *afinfo)
 {
diff --git a/net/netfilter/xt_addrtype.c b/net/netfilter/xt_addrtype.c
index 49c5ff7..68ff29f 100644
--- a/net/netfilter/xt_addrtype.c
+++ b/net/netfilter/xt_addrtype.c
@@ -22,6 +22,7 @@
 #include <net/ip6_fib.h>
 #endif
 
+#include <linux/netfilter_ipv6.h>
 #include <linux/netfilter/xt_addrtype.h>
 #include <linux/netfilter/x_tables.h>
 
@@ -33,12 +34,12 @@ MODULE_ALIAS("ip6t_addrtype");
 
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 static u32 match_lookup_rt6(struct net *net, const struct net_device *dev,
-			    const struct in6_addr *addr)
+			    const struct in6_addr *addr, u16 mask)
 {
 	const struct nf_afinfo *afinfo;
 	struct flowi6 flow;
 	struct rt6_info *rt;
-	u32 ret;
+	u32 ret = 0;
 	int route_err;
 
 	memset(&flow, 0, sizeof(flow));
@@ -49,12 +50,19 @@ static u32 match_lookup_rt6(struct net *net, const struct net_device *dev,
 	rcu_read_lock();
 
 	afinfo = nf_get_afinfo(NFPROTO_IPV6);
-	if (afinfo != NULL)
+	if (afinfo != NULL) {
+		const struct nf_ipv6_ops *v6ops;
+
+		if (dev && (mask & XT_ADDRTYPE_LOCAL)) {
+			v6ops = nf_get_ipv6_ops();
+			if (v6ops && v6ops->chk_addr(net, addr, dev, true))
+				ret = XT_ADDRTYPE_LOCAL;
+		}
 		route_err = afinfo->route(net, (struct dst_entry **)&rt,
-					flowi6_to_flowi(&flow), !!dev);
-	else
+					  flowi6_to_flowi(&flow), false);
+	} else {
 		route_err = 1;
-
+	}
 	rcu_read_unlock();
 
 	if (route_err)
@@ -62,15 +70,12 @@ static u32 match_lookup_rt6(struct net *net, const struct net_device *dev,
 
 	if (rt->rt6i_flags & RTF_REJECT)
 		ret = XT_ADDRTYPE_UNREACHABLE;
-	else
-		ret = 0;
 
-	if (rt->rt6i_flags & RTF_LOCAL)
+	if (dev == NULL && rt->rt6i_flags & RTF_LOCAL)
 		ret |= XT_ADDRTYPE_LOCAL;
 	if (rt->rt6i_flags & RTF_ANYCAST)
 		ret |= XT_ADDRTYPE_ANYCAST;
 
-
 	dst_release(&rt->dst);
 	return ret;
 }
@@ -90,7 +95,7 @@ static bool match_type6(struct net *net, const struct net_device *dev,
 
 	if ((XT_ADDRTYPE_LOCAL | XT_ADDRTYPE_ANYCAST |
 	     XT_ADDRTYPE_UNREACHABLE) & mask)
-		return !!(mask & match_lookup_rt6(net, dev, addr));
+		return !!(mask & match_lookup_rt6(net, dev, addr, mask));
 	return true;
 }
 
-- 
1.7.10.4

