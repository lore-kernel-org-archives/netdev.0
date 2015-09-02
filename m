From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Support ip route get via given table
Date: Wed,  2 Sep 2015 12:03:12 -0700
Message-ID: <1441220592-7339-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36579 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbbIBTDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 15:03:20 -0400
Received: by pacwi10 with SMTP id wi10so20114265pac.3
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 12:03:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 'ip [-6] route get table X' where the user wants to
force the FIB lookup from a given table.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/flow.h      |  4 ++++
 include/net/ip_fib.h    | 15 +++++++++++++++
 net/ipv4/fib_frontend.c |  2 ++
 net/ipv4/route.c        |  2 ++
 net/ipv6/route.c        | 24 ++++++++++++++++++++++++
 5 files changed, 47 insertions(+)

diff --git a/include/net/flow.h b/include/net/flow.h
index acd6a096250e..910f2dcaab78 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -36,6 +36,7 @@ struct flowi_common {
 #define FLOWI_FLAG_KNOWN_NH		0x02
 #define FLOWI_FLAG_VRFSRC		0x04
 	__u32	flowic_secid;
+	__u32	flowic_table_id;
 	struct flowi_tunnel flowic_tun_key;
 };
 
@@ -74,6 +75,7 @@ struct flowi4 {
 #define flowi4_flags		__fl_common.flowic_flags
 #define flowi4_secid		__fl_common.flowic_secid
 #define flowi4_tun_key		__fl_common.flowic_tun_key
+#define flowi4_table_id		__fl_common.flowic_table_id
 
 	/* (saddr,daddr) must be grouped, same order as in IP header */
 	__be32			saddr;
@@ -103,6 +105,7 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 	fl4->flowi4_proto = proto;
 	fl4->flowi4_flags = flags;
 	fl4->flowi4_secid = 0;
+	fl4->flowi4_table_id = 0;
 	fl4->flowi4_tun_key.tun_id = 0;
 	fl4->daddr = daddr;
 	fl4->saddr = saddr;
@@ -132,6 +135,7 @@ struct flowi6 {
 #define flowi6_flags		__fl_common.flowic_flags
 #define flowi6_secid		__fl_common.flowic_secid
 #define flowi6_tun_key		__fl_common.flowic_tun_key
+#define flowi6_table_id		__fl_common.flowic_table_id
 	struct in6_addr		daddr;
 	struct in6_addr		saddr;
 	__be32			flowlabel;
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index a37d0432bebd..c7024094726d 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -233,6 +233,9 @@ static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 	struct fib_table *tb;
 	int err = -ENETUNREACH;
 
+	if (flp->flowi4_table_id && flp->flowi4_table_id != RT_TABLE_MAIN)
+		return -ENETUNREACH;
+
 	rcu_read_lock();
 
 	tb = fib_get_table(net, RT_TABLE_MAIN);
@@ -261,6 +264,18 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 	int err;
 
 	flags |= FIB_LOOKUP_NOREF;
+	if (flp->flowi4_table_id) {
+		err = -ENETUNREACH;
+
+		rcu_read_lock();
+		tb = fib_get_table(net, flp->flowi4_table_id);
+		if (tb)
+			err = fib_table_lookup(tb, flp, res, flags);
+		rcu_read_unlock();
+
+		return err;
+	}
+
 	if (net->ipv4.fib_has_custom_rules)
 		return __fib_lookup(net, flp, res, flags);
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 6fcbd215cdbc..65519445ca0d 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -129,6 +129,7 @@ struct fib_table *fib_get_table(struct net *net, u32 id)
 	}
 	return NULL;
 }
+EXPORT_SYMBOL(fib_get_table);
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
 
 static void fib_replace_table(struct net *net, struct fib_table *old,
@@ -339,6 +340,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	fl4.saddr = dst;
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_table_id = 0;
 	fl4.flowi4_tun_key.tun_id = 0;
 
 	no_addr = idev->ifa_list == NULL;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5f4a5565ad8b..b3e5ee821450 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2476,6 +2476,8 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	fl4.flowi4_tos = rtm->rtm_tos;
 	fl4.flowi4_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0;
 	fl4.flowi4_mark = mark;
+	if (tb[RTA_TABLE])
+		fl4.flowi4_table_id = nla_get_u32(tb[RTA_TABLE]);
 
 	if (iif) {
 		struct net_device *dev;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f45cac6f8356..f605c8ea5a16 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -61,6 +61,7 @@
 #include <net/nexthop.h>
 #include <net/lwtunnel.h>
 #include <net/ip_tunnels.h>
+#include <net/fib_rules.h>
 
 #include <asm/uaccess.h>
 
@@ -1142,6 +1143,20 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	}
 }
 
+static struct dst_entry *ip6_route_table(struct net *net, int flags,
+					 struct flowi6 *fl6,
+					 pol_lookup_t lookup)
+{
+	struct rt6_info *rt = NULL;
+	struct fib6_table *table;
+
+	table = fib6_get_table(net, fl6->flowi6_table_id);
+	if (table)
+		rt = lookup(net, table, fl6, FIB_LOOKUP_NOREF | flags);
+
+	return (struct dst_entry *)rt;
+}
+
 static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *table,
 					    struct flowi6 *fl6, int flags)
 {
@@ -1155,6 +1170,9 @@ static struct dst_entry *ip6_route_input_lookup(struct net *net,
 	if (rt6_need_strict(&fl6->daddr) && dev->type != ARPHRD_PIMREG)
 		flags |= RT6_LOOKUP_F_IFACE;
 
+	if (fl6->flowi6_table_id)
+		return ip6_route_table(net, flags, fl6, ip6_pol_route_input);
+
 	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_input);
 }
 
@@ -1201,6 +1219,9 @@ struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
 	else if (sk)
 		flags |= rt6_srcprefs2flags(inet6_sk(sk)->srcprefs);
 
+	if (fl6->flowi6_table_id)
+		return ip6_route_table(net, flags, fl6, ip6_pol_route_output);
+
 	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_output);
 }
 EXPORT_SYMBOL(ip6_route_output);
@@ -3104,6 +3125,9 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	if (tb[RTA_MARK])
 		fl6.flowi6_mark = nla_get_u32(tb[RTA_MARK]);
 
+	if (tb[RTA_TABLE])
+		fl6.flowi6_table_id = nla_get_u32(tb[RTA_TABLE]);
+
 	if (iif) {
 		struct net_device *dev;
 		int flags = 0;
-- 
1.9.1
