From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/21] ipv6: fib: Add in-kernel notifications for route add / delete
Date: Thu,  3 Aug 2017 13:28:17 +0200
Message-ID: <20170803112831.1831-8-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36875 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752149AbdHCL2s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:28:48 -0400
Received: by mail-wm0-f67.google.com with SMTP id t138so1806927wmt.4
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:28:47 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

As with IPv4, allow listeners of the FIB notification chain to receive
notifications whenever a route is added, replaced or deleted. This is
done by placing calls to the FIB notification chain in the two lowest
level functions that end up performing these operations - namely,
fib6_add_rt2node() and fib6_del_route().

Unlike IPv4, APPEND notifications aren't sent as the kernel doesn't
distinguish between "append" (NLM_F_CREATE|NLM_F_APPEND) and "prepend"
(NLM_F_CREATE). If NLM_F_EXCL isn't set, duplicate routes are always
added after the existing duplicate routes.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip6_fib.h |  5 +++++
 net/ipv6/ip6_fib.c    | 17 +++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index be8ddf3..e2b292b 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -258,6 +258,11 @@ typedef struct rt6_info *(*pol_lookup_t)(struct net *,
 					 struct fib6_table *,
 					 struct flowi6 *, int);
 
+struct fib6_entry_notifier_info {
+	struct fib_notifier_info info; /* must be first */
+	struct rt6_info *rt;
+};
+
 /*
  *	exported functions
  */
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index f93976e..595a57c 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -33,6 +33,7 @@
 #include <net/ndisc.h>
 #include <net/addrconf.h>
 #include <net/lwtunnel.h>
+#include <net/fib_notifier.h>
 
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
@@ -302,6 +303,17 @@ static void __net_init fib6_tables_init(struct net *net)
 
 #endif
 
+static int call_fib6_entry_notifiers(struct net *net,
+				     enum fib_event_type event_type,
+				     struct rt6_info *rt)
+{
+	struct fib6_entry_notifier_info info = {
+		.rt = rt,
+	};
+
+	return call_fib6_notifiers(net, event_type, &info.info);
+}
+
 static int fib6_dump_node(struct fib6_walker *w)
 {
 	int res;
@@ -879,6 +891,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		*ins = rt;
 		rt->rt6i_node = fn;
 		atomic_inc(&rt->rt6i_ref);
+		call_fib6_entry_notifiers(info->nl_net, FIB_EVENT_ENTRY_ADD,
+					  rt);
 		if (!info->skip_notify)
 			inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
 		info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
@@ -906,6 +920,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		rt->rt6i_node = fn;
 		rt->dst.rt6_next = iter->dst.rt6_next;
 		atomic_inc(&rt->rt6i_ref);
+		call_fib6_entry_notifiers(info->nl_net, FIB_EVENT_ENTRY_REPLACE,
+					  rt);
 		if (!info->skip_notify)
 			inet6_rt_notify(RTM_NEWROUTE, rt, info, NLM_F_REPLACE);
 		if (!(fn->fn_flags & RTN_RTINFO)) {
@@ -1459,6 +1475,7 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 
 	fib6_purge_rt(rt, fn, net);
 
+	call_fib6_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, rt);
 	if (!info->skip_notify)
 		inet6_rt_notify(RTM_DELROUTE, rt, info, 0);
 	rt6_release(rt);
-- 
2.9.3
