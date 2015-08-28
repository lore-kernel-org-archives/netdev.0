From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: FIB tracepoints
Date: Thu, 27 Aug 2015 21:59:32 -0700
Message-ID: <1440737972-10468-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35782 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbbH1E7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 00:59:40 -0400
Received: by pacdd16 with SMTP id dd16so49502030pac.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 21:59:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few useful tracepoints developing VRF driver.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
I realize the sensitivity around adding tracepoints, but these have been
invaluable developing the VRF device driver along with a return probe:
  perf probe -a 'fib_table_lookup_ret=fib_table_lookup%return ret=%ax'

 include/trace/events/fib.h | 97 ++++++++++++++++++++++++++++++++++++++++++++++
 net/core/net-traces.c      |  1 +
 net/ipv4/fib_frontend.c    |  3 ++
 net/ipv4/fib_trie.c        |  5 +++
 4 files changed, 106 insertions(+)
 create mode 100644 include/trace/events/fib.h

diff --git a/include/trace/events/fib.h b/include/trace/events/fib.h
new file mode 100644
index 000000000000..1fd7cfeb36ff
--- /dev/null
+++ b/include/trace/events/fib.h
@@ -0,0 +1,97 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM fib
+
+#if !defined(_TRACE_FIB_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_FIB_H
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <net/ip_fib.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(fib_table_lookup,
+
+	TP_PROTO(int tb_id, const struct flowi4 *flp),
+
+	TP_ARGS(tb_id, flp),
+
+	TP_STRUCT__entry(
+		__field(	int,	tb_id		)
+		__field(	int,	oif		)
+		__field(	int,	iif		)
+		__field(	__u8,	tos		)
+		__field(	__u8,	scope		)
+		__field(	__u8,	flags		)
+		__array(	__u8,	src,	4	)
+		__array(	__u8,	dst,	4	)
+	),
+
+	TP_fast_assign(
+		__entry->tb_id = tb_id;
+		__entry->oif = flp->flowi4_oif;
+		__entry->iif = flp->flowi4_iif;
+		__entry->tos = flp->flowi4_tos;
+		__entry->scope = flp->flowi4_scope;
+		__entry->flags = flp->flowi4_flags;
+		memcpy(&__entry->src,  &flp->saddr, 4);
+		memcpy(&__entry->dst,  &flp->daddr, 4);
+	),
+
+	TP_printk("table %d oif %d iif %d src %pI4 dst %pI4 tos %d scope %d flags %x",
+		  __entry->tb_id, __entry->oif, __entry->iif,
+		  __entry->src, __entry->dst, __entry->tos, __entry->scope,
+		  __entry->flags)
+);
+
+TRACE_EVENT(fib_table_lookup_nh,
+
+	TP_PROTO(const struct fib_nh *nh),
+
+	TP_ARGS(nh),
+
+	TP_STRUCT__entry(
+		__string(	name,	nh->nh_dev->name)
+		__field(	int,	oif		)
+		__array(	__u8,	src,	4	)
+	),
+
+	TP_fast_assign(
+		__assign_str(name, nh->nh_dev ? nh->nh_dev->name : "not set");
+		__entry->oif = nh->nh_oif;
+		memcpy(&__entry->src,  &nh->nh_saddr, 4);
+	),
+
+	TP_printk("nexthop dev %s oif %d src %pI4",
+		  __get_str(name), __entry->oif, __entry->src)
+);
+
+TRACE_EVENT(fib_validate_source,
+
+	TP_PROTO(const struct net_device *dev, const struct flowi4 *flp),
+
+	TP_ARGS(dev, flp),
+
+	TP_STRUCT__entry(
+		__string(	name,	dev->name	)
+		__field(	int,	oif		)
+		__field(	int,	iif		)
+		__array(	__u8,	src,	4	)
+		__array(	__u8,	dst,	4	)
+	),
+
+	TP_fast_assign(
+		__assign_str(name, dev ? dev->name : "not set");
+		__entry->oif = flp->flowi4_oif;
+		__entry->iif = flp->flowi4_iif;
+		memcpy(&__entry->src,  &flp->saddr, 4);
+		memcpy(&__entry->dst,  &flp->daddr, 4);
+	),
+
+	TP_printk("dev %s oif %d iif %d src %pI4 dst %pI4",
+		  __get_str(name), __entry->oif, __entry->iif,
+		  __entry->src, __entry->dst)
+);
+#endif /* _TRACE_FIB_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index ba3c0120786c..adef015b2f41 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -31,6 +31,7 @@
 #include <trace/events/napi.h>
 #include <trace/events/sock.h>
 #include <trace/events/udp.h>
+#include <trace/events/fib.h>
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 7fa277176c33..4036c94dfbe1 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -46,6 +46,7 @@
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
 #include <net/vrf.h>
+#include <trace/events/fib.h>
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
@@ -344,6 +345,8 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 
 	fl4.flowi4_mark = IN_DEV_SRC_VMARK(idev) ? skb->mark : 0;
 
+	trace_fib_validate_source(dev, &fl4);
+
 	net = dev_net(dev);
 	if (fib_lookup(net, &fl4, &res, 0))
 		goto last_resort;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 5154f81c5326..26d6ffb6d23c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -81,6 +81,7 @@
 #include <net/sock.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
+#include <trace/events/fib.h>
 #include "fib_lookup.h"
 
 #define MAX_STAT_DEPTH 32
@@ -1278,6 +1279,8 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 	unsigned long index;
 	t_key cindex;
 
+	trace_fib_table_lookup(tb->tb_id, flp);
+
 	pn = t->kv;
 	cindex = 0;
 
@@ -1442,6 +1445,8 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			this_cpu_inc(stats->semantic_match_passed);
 #endif
+			trace_fib_table_lookup_nh(nh);
+
 			return err;
 		}
 	}
-- 
1.9.1
