From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH Round 2 2/2] Core network changes to support network event notification.
Date: Mon, 26 Jun 2006 15:36:59 -0500
Message-ID: <20060626203659.19083.28194.stgit@stevo-desktop>
References: <20060626203638.19083.71231.stgit@stevo-desktop>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-227-247-53.sw.biz.rr.com ([24.227.247.53]:31122 "EHLO
	linux.local") by vger.kernel.org with ESMTP id S932093AbWFZUg7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 16:36:59 -0400
To: davem@davemloft.net
In-Reply-To: <20060626203638.19083.71231.stgit@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds netevent and netlink calls for neighbour change, route
add/del, and routing redirect events.

TBD: 
	PMTU change netevent and netlink calls.
	netlink call for redirect events.
---

 include/linux/rtnetlink.h |    2 ++
 net/core/Makefile         |    2 +-
 net/core/neighbour.c      |   37 ++++++++++++++++++++++++++++++-------
 net/ipv4/fib_semantics.c  |    9 +++++++++
 net/ipv4/route.c          |   16 ++++++++++++++++
 net/ipv6/route.c          |   22 ++++++++++++++++++++++
 6 files changed, 80 insertions(+), 8 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index df0cdd4..14f5622 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -42,6 +42,8 @@ #define RTM_NEWNEIGH	RTM_NEWNEIGH
 #define RTM_DELNEIGH	RTM_DELNEIGH
 	RTM_GETNEIGH,
 #define RTM_GETNEIGH	RTM_GETNEIGH
+	RTM_CHGNEIGH,
+#define RTM_CHGNEIGH	RTM_CHGNEIGH
 
 	RTM_NEWRULE	= 32,
 #define RTM_NEWRULE	RTM_NEWRULE
diff --git a/net/core/Makefile b/net/core/Makefile
index e9bd246..2645ba4 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -7,7 +7,7 @@ obj-y := sock.o request_sock.o skbuff.o 
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
-obj-y		     += dev.o ethtool.o dev_mcast.o dst.o \
+obj-y		     += dev.o ethtool.o dev_mcast.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
 
 obj-$(CONFIG_XFRM) += flow.o
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 50a8c73..7b67da8 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -30,9 +30,11 @@ #include <linux/times.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/sock.h>
+#include <net/netevent.h>
 #include <linux/rtnetlink.h>
 #include <linux/random.h>
 #include <linux/string.h>
+#include <linux/notifier.h>
 
 #define NEIGH_DEBUG 1
 
@@ -59,6 +61,7 @@ static void neigh_app_notify(struct neig
 #endif
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
+static void rtm_neigh_change(struct neighbour *n);
 
 static struct neigh_table *neigh_tables;
 #ifdef CONFIG_PROC_FS
@@ -755,6 +758,7 @@ #endif
 			neigh->nud_state = NUD_STALE;
 			neigh->updated = jiffies;
 			neigh_suspect(neigh);
+			notify = 1;
 		}
 	} else if (state & NUD_DELAY) {
 		if (time_before_eq(now, 
@@ -763,6 +767,7 @@ #endif
 			neigh->nud_state = NUD_REACHABLE;
 			neigh->updated = jiffies;
 			neigh_connect(neigh);
+			notify = 1;
 			next = neigh->confirmed + neigh->parms->reachable_time;
 		} else {
 			NEIGH_PRINTK2("neigh %p is probed.\n", neigh);
@@ -820,6 +825,8 @@ #endif
 out:
 		write_unlock(&neigh->lock);
 	}
+	if (notify)
+		rtm_neigh_change(neigh);
 
 #ifdef CONFIG_ARPD
 	if (notify && neigh->parms->app_probes)
@@ -927,9 +934,7 @@ int neigh_update(struct neighbour *neigh
 {
 	u8 old;
 	int err;
-#ifdef CONFIG_ARPD
 	int notify = 0;
-#endif
 	struct net_device *dev;
 	int update_isrouter = 0;
 
@@ -949,9 +954,7 @@ #endif
 			neigh_suspect(neigh);
 		neigh->nud_state = new;
 		err = 0;
-#ifdef CONFIG_ARPD
 		notify = old & NUD_VALID;
-#endif
 		goto out;
 	}
 
@@ -1023,9 +1026,7 @@ #endif
 		if (!(new & NUD_CONNECTED))
 			neigh->confirmed = jiffies -
 				      (neigh->parms->base_reachable_time << 1);
-#ifdef CONFIG_ARPD
 		notify = 1;
-#endif
 	}
 	if (new == old)
 		goto out;
@@ -1056,7 +1057,11 @@ out:
 			(neigh->flags | NTF_ROUTER) :
 			(neigh->flags & ~NTF_ROUTER);
 	}
+
 	write_unlock_bh(&neigh->lock);
+
+	if (notify)
+		rtm_neigh_change(neigh);
 #ifdef CONFIG_ARPD
 	if (notify && neigh->parms->app_probes)
 		neigh_app_notify(neigh);
@@ -2370,9 +2375,27 @@ static void neigh_app_notify(struct neig
 	NETLINK_CB(skb).dst_group  = RTNLGRP_NEIGH;
 	netlink_broadcast(rtnl, skb, 0, RTNLGRP_NEIGH, GFP_ATOMIC);
 }
-
 #endif /* CONFIG_ARPD */
 
+static void rtm_neigh_change(struct neighbour *n)
+{
+	struct nlmsghdr *nlh;
+	int size = NLMSG_SPACE(sizeof(struct ndmsg) + 256);
+	struct sk_buff *skb = alloc_skb(size, GFP_ATOMIC);
+
+	call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
+	if (!skb)
+		return;
+
+	if (neigh_fill_info(skb, n, 0, 0, RTM_CHGNEIGH, 0) < 0) {
+		kfree_skb(skb);
+		return;
+	}
+	nlh			   = (struct nlmsghdr *)skb->data;
+	NETLINK_CB(skb).dst_group  = RTNLGRP_NEIGH;
+	netlink_broadcast(rtnl, skb, 0, RTNLGRP_NEIGH, GFP_ATOMIC);
+}
+
 #ifdef CONFIG_SYSCTL
 
 static struct neigh_sysctl_table {
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 0f4145b..197c365 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -45,6 +45,7 @@ #include <net/tcp.h>
 #include <net/sock.h>
 #include <net/ip_fib.h>
 #include <net/ip_mp_alg.h>
+#include <net/netevent.h>
 
 #include "fib_lookup.h"
 
@@ -280,6 +281,14 @@ void rtmsg_fib(int event, u32 key, struc
 	struct sk_buff *skb;
 	u32 pid = req ? req->pid : n->nlmsg_pid;
 	int size = NLMSG_SPACE(sizeof(struct rtmsg)+256);
+	struct netevent_route_info nri;
+	int netevent;
+
+	nri.family = AF_INET;
+	nri.data = &fa->fa_info;
+	netevent = event == RTM_NEWROUTE ? NETEVENT_ROUTE_ADD 
+					 : NETEVENT_ROUTE_DEL;
+	call_netevent_notifiers(netevent, &nri);
 
 	skb = alloc_skb(size, GFP_KERNEL);
 	if (!skb)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cc9423d..a20c320 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -105,6 +105,7 @@ #include <net/tcp.h>
 #include <net/icmp.h>
 #include <net/xfrm.h>
 #include <net/ip_mp_alg.h>
+#include <net/netevent.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -1112,6 +1113,19 @@ static void rt_del(unsigned hash, struct
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
+static void rtm_redirect(struct rtable *old, struct rtable *new)
+{
+	struct netevent_redirect netevent;
+	netevent.old = &old->u.dst;
+	netevent.new = &new->u.dst;
+	struct sk_buff *skb;
+
+	/* notify netevent subscribers */
+	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
+
+	/* TBD...post NETLINK msg */
+}
+
 void ip_rt_redirect(u32 old_gw, u32 daddr, u32 new_gw,
 		    u32 saddr, struct net_device *dev)
 {
@@ -1211,6 +1225,8 @@ void ip_rt_redirect(u32 old_gw, u32 dadd
 					rt_drop(rt);
 					goto do_next;
 				}
+				
+				rtm_redirect(rth, rt);
 
 				rt_del(hash, rth);
 				if (!rt_intern_hash(hash, rt, &rt))
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8a77793..ff523fb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -908,6 +908,7 @@ int ip6_route_add(struct in6_rtmsg *rtms
 	struct net_device *dev = NULL;
 	struct inet6_dev *idev = NULL;
 	int addr_type;
+	struct netevent_route_info nri;
 
 	rta = (struct rtattr **) _rtattr;
 
@@ -1086,6 +1087,9 @@ install_route:
 		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&rt->u.dst));
 	rt->u.dst.dev = dev;
 	rt->rt6i_idev = idev;
+	nri.family = AF_INET6;
+	nri.data = rt;
+	call_netevent_notifiers(NETEVENT_ROUTE_ADD, &nri);
 	return ip6_ins_rt(rt, nlh, _rtattr, req);
 
 out:
@@ -1117,6 +1121,7 @@ static int ip6_route_del(struct in6_rtms
 	struct fib6_node *fn;
 	struct rt6_info *rt;
 	int err = -ESRCH;
+	struct netevent_route_info nri;
 
 	read_lock_bh(&rt6_lock);
 
@@ -1138,6 +1143,10 @@ static int ip6_route_del(struct in6_rtms
 				continue;
 			dst_hold(&rt->u.dst);
 			read_unlock_bh(&rt6_lock);
+			
+			nri.family = AF_INET6;
+			nri.data = rt;
+			call_netevent_notifiers(NETEVENT_ROUTE_DEL, &nri);
 
 			return ip6_del_rt(rt, nlh, _rtattr, req);
 		}
@@ -1147,6 +1156,17 @@ static int ip6_route_del(struct in6_rtms
 	return err;
 }
 
+static void rtm_redirect(struct rt6_info *old, struct rt6_info *new)
+{
+	struct netevent_redirect netevent;
+
+	netevent.old = &old->u.dst;
+	netevent.new = &new->u.dst;
+	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
+
+	/* TBD...post NETLINK msg */
+}
+
 /*
  *	Handle redirects
  */
@@ -1253,6 +1273,8 @@ restart:
 	if (ip6_ins_rt(nrt, NULL, NULL, NULL))
 		goto out;
 
+	rtm_redirect(rt, nrt);
+
 	if (rt->rt6i_flags&RTF_CACHE) {
 		ip6_del_rt(rt, NULL, NULL, NULL);
 		return;
