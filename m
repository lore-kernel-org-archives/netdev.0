From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] ipv6: let trace_fib6_table_lookup() dereference the fib table
Date: Thu, 19 Oct 2017 09:31:43 +0200
Message-ID: <48235df8fdf787356070d8baa1ac9816ef5736d4.1508398120.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34372 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751726AbdJSHcM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 03:32:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The perf traces for ipv6 routing code show a relevant cost around
trace_fib6_table_lookup(), even if no trace is enabled. This is
due to the fib6_table de-referencing currently performed by the
caller.

Let's the tracing code pay this overhead, passing to the trace
helper the table pointer. This gives small but measurable
performance improvement under UDP flood.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/trace/events/fib6.h |  6 +++---
 net/ipv6/route.c            | 12 ++++++------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/trace/events/fib6.h b/include/trace/events/fib6.h
index d60096cddb2a..b34bed17abc7 100644
--- a/include/trace/events/fib6.h
+++ b/include/trace/events/fib6.h
@@ -12,9 +12,9 @@
 TRACE_EVENT(fib6_table_lookup,
 
 	TP_PROTO(const struct net *net, const struct rt6_info *rt,
-		 u32 tb_id, const struct flowi6 *flp),
+		 struct fib6_table *table, const struct flowi6 *flp),
 
-	TP_ARGS(net, rt, tb_id, flp),
+	TP_ARGS(net, rt, table, flp),
 
 	TP_STRUCT__entry(
 		__field(	u32,	tb_id		)
@@ -34,7 +34,7 @@ TRACE_EVENT(fib6_table_lookup,
 	TP_fast_assign(
 		struct in6_addr *in6;
 
-		__entry->tb_id = tb_id;
+		__entry->tb_id = table->tb6_id;
 		__entry->oif = flp->flowi6_oif;
 		__entry->iif = flp->flowi6_iif;
 		__entry->tos = ip6_tclass(flp->flowlabel);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2e8842fa6450..d638fd993287 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -945,7 +945,7 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 
 	rcu_read_unlock();
 
-	trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
+	trace_fib6_table_lookup(net, rt, table, fl6);
 
 	return rt;
 
@@ -1670,7 +1670,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	if (rt == net->ipv6.ip6_null_entry) {
 		rcu_read_unlock();
 		dst_hold(&rt->dst);
-		trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
+		trace_fib6_table_lookup(net, rt, table, fl6);
 		return rt;
 	} else if (rt->rt6i_flags & RTF_CACHE) {
 		if (ip6_hold_safe(net, &rt, true)) {
@@ -1678,7 +1678,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			rt6_dst_from_metrics_check(rt);
 		}
 		rcu_read_unlock();
-		trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
+		trace_fib6_table_lookup(net, rt, table, fl6);
 		return rt;
 	} else if (unlikely((fl6->flowi6_flags & FLOWI_FLAG_KNOWN_NH) &&
 			    !(rt->rt6i_flags & RTF_GATEWAY))) {
@@ -1714,7 +1714,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 		}
 
 uncached_rt_out:
-		trace_fib6_table_lookup(net, uncached_rt, table->tb6_id, fl6);
+		trace_fib6_table_lookup(net, uncached_rt, table, fl6);
 		return uncached_rt;
 
 	} else {
@@ -1742,7 +1742,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 		}
 		local_bh_enable();
 		rcu_read_unlock();
-		trace_fib6_table_lookup(net, pcpu_rt, table->tb6_id, fl6);
+		trace_fib6_table_lookup(net, pcpu_rt, table, fl6);
 		return pcpu_rt;
 	}
 }
@@ -2183,7 +2183,7 @@ static struct rt6_info *__ip6_route_redirect(struct net *net,
 
 	rcu_read_unlock();
 
-	trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
+	trace_fib6_table_lookup(net, rt, table, fl6);
 	return rt;
 };
 
-- 
2.13.6
