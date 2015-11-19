From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: IPv6 fib lookup tracepoint
Date: Thu, 19 Nov 2015 12:24:22 -0800
Message-ID: <1447964662-39263-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35733 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934327AbbKSUYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 15:24:33 -0500
Received: by pacej9 with SMTP id ej9so91318558pac.2
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 12:24:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add tracepoint to show fib6 table lookups and result.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/trace/events/fib6.h | 76 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/net-traces.c       |  4 +++
 net/ipv6/route.c            | 10 ++++++
 3 files changed, 90 insertions(+)
 create mode 100644 include/trace/events/fib6.h

diff --git a/include/trace/events/fib6.h b/include/trace/events/fib6.h
new file mode 100644
index 000000000000..4cf6bac4686d
--- /dev/null
+++ b/include/trace/events/fib6.h
@@ -0,0 +1,76 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM fib6
+
+#if !defined(_TRACE_FIB6_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_FIB6_H
+
+#include <linux/in6.h>
+#include <net/flow.h>
+#include <net/ip6_fib.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(fib6_table_lookup,
+
+	TP_PROTO(const struct net *net, const struct rt6_info *rt,
+		 u32 tb_id, const struct flowi6 *flp),
+
+	TP_ARGS(net, rt, tb_id, flp),
+
+	TP_STRUCT__entry(
+		__field(	u32,	tb_id		)
+
+		__field(	int,	oif		)
+		__field(	int,	iif		)
+		__field(	__u8,	tos		)
+		__field(	__u8,	scope		)
+		__field(	__u8,	flags		)
+		__array(	__u8,	src,	16	)
+		__array(	__u8,	dst,	16	)
+
+		__dynamic_array(	char,	name,	IFNAMSIZ )
+		__array(		__u8,	gw,	16	 )
+	),
+
+	TP_fast_assign(
+		struct in6_addr *in6;
+
+		__entry->tb_id = tb_id;
+		__entry->oif = flp->flowi6_oif;
+		__entry->iif = flp->flowi6_iif;
+		__entry->tos = flp->flowi6_tos;
+		__entry->scope = flp->flowi6_scope;
+		__entry->flags = flp->flowi6_flags;
+
+		in6 = (struct in6_addr *)__entry->src;
+		*in6 = flp->saddr;
+
+		in6 = (struct in6_addr *)__entry->dst;
+		*in6 = flp->daddr;
+
+		if (rt->rt6i_idev) {
+			__assign_str(name, rt->rt6i_idev->dev->name);
+		} else {
+			__assign_str(name, "");
+		}
+		if (rt == net->ipv6.ip6_null_entry) {
+			struct in6_addr in6_zero = {};
+
+			in6 = (struct in6_addr *)__entry->gw;
+			*in6 = in6_zero;
+
+		} else if (rt) {
+			in6 = (struct in6_addr *)__entry->gw;
+			*in6 = rt->rt6i_gateway;
+		}
+	),
+
+	TP_printk("table %3u oif %d iif %d src %pI6c dst %pI6c tos %d scope %d flags %x ==> dev %s gw %pI6c",
+		  __entry->tb_id, __entry->oif, __entry->iif,
+		  __entry->src, __entry->dst, __entry->tos, __entry->scope,
+		  __entry->flags, __get_str(name), __entry->gw)
+);
+
+#endif /* _TRACE_FIB6_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index adef015b2f41..92da5e4ceb4f 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -32,6 +32,10 @@
 #include <trace/events/sock.h>
 #include <trace/events/udp.h>
 #include <trace/events/fib.h>
+#if IS_ENABLED(CONFIG_IPV6)
+#include <trace/events/fib6.h>
+EXPORT_TRACEPOINT_SYMBOL_GPL(fib6_table_lookup);
+#endif
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6f01fe122abd..89758be9c6a6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -62,6 +62,7 @@
 #include <net/lwtunnel.h>
 #include <net/ip_tunnels.h>
 #include <net/l3mdev.h>
+#include <trace/events/fib6.h>
 
 #include <asm/uaccess.h>
 
@@ -865,6 +866,9 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 	}
 	dst_use(&rt->dst, jiffies);
 	read_unlock_bh(&table->tb6_lock);
+
+	trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
+
 	return rt;
 
 }
@@ -1078,6 +1082,8 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 		read_unlock_bh(&table->tb6_lock);
 
 		rt6_dst_from_metrics_check(rt);
+
+		trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
 		return rt;
 	} else if (unlikely((fl6->flowi6_flags & FLOWI_FLAG_KNOWN_NH) &&
 			    !(rt->rt6i_flags & RTF_GATEWAY))) {
@@ -1101,6 +1107,8 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			uncached_rt = net->ipv6.ip6_null_entry;
 
 		dst_hold(&uncached_rt->dst);
+
+		trace_fib6_table_lookup(net, uncached_rt, table->tb6_id, fl6);
 		return uncached_rt;
 
 	} else {
@@ -1125,6 +1133,7 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			dst_release(&rt->dst);
 		}
 
+		trace_fib6_table_lookup(net, pcpu_rt, table->tb6_id, fl6);
 		return pcpu_rt;
 
 	}
@@ -1474,6 +1483,7 @@ static struct rt6_info *__ip6_route_redirect(struct net *net,
 
 	read_unlock_bh(&table->tb6_lock);
 
+	trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
 	return rt;
 };
 
-- 
1.9.1
