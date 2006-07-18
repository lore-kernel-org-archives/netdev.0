From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH Round 4 2/3] Core network changes to support network event notification.
Date: Tue, 18 Jul 2006 13:49:07 -0500
Message-ID: <20060718184907.25455.8174.stgit@dell3.ogc.int>
References: <20060718184847.25455.88191.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:32989 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S932357AbWGRStI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 14:49:08 -0400
To: davem@davemloft.net, rdreier@cisco.com
In-Reply-To: <20060718184847.25455.88191.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds netevent and netlink calls for neighbour change, route
add/del, pmtu change, and routing redirect events.

Netlink Details:

Neighbour change events are broadcast as a new ndmsg type RTM_NEIGHUPD.

Path mtu change events are broadcast as a new rtmsg type RTM_ROUTEUPD.

Routing redirect events are broadcast as a pair of rtmsgs, RTM_DELROUTE
and RTM_NEWROUTE.
---

 include/linux/rtnetlink.h |    4 ++
 net/core/Makefile         |    2 +
 net/core/neighbour.c      |   37 ++++++++++++++++---
 net/ipv4/fib_semantics.c  |    9 +++++
 net/ipv4/route.c          |   86 ++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/route.c          |   87 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 213 insertions(+), 12 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index facd9ee..340ca4f 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -35,6 +35,8 @@ #define RTM_NEWROUTE	RTM_NEWROUTE
 #define RTM_DELROUTE	RTM_DELROUTE
 	RTM_GETROUTE,
 #define RTM_GETROUTE	RTM_GETROUTE
+	RTM_ROUTEUPD,
+#define RTM_ROUTEUPD	RTM_ROUTEUPD
 
 	RTM_NEWNEIGH	= 28,
 #define RTM_NEWNEIGH	RTM_NEWNEIGH
@@ -42,6 +44,8 @@ #define RTM_NEWNEIGH	RTM_NEWNEIGH
 #define RTM_DELNEIGH	RTM_DELNEIGH
 	RTM_GETNEIGH,
 #define RTM_GETNEIGH	RTM_GETNEIGH
+	RTM_NEIGHUPD,
+#define RTM_NEIGHUPD	RTM_NEIGHUPD
 
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
index 7ad681f..11c7643 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -29,9 +29,11 @@ #include <linux/times.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/sock.h>
+#include <net/netevent.h>
 #include <linux/rtnetlink.h>
 #include <linux/random.h>
 #include <linux/string.h>
+#include <linux/notifier.h>
 
 #define NEIGH_DEBUG 1
 
@@ -58,6 +60,7 @@ static void neigh_app_notify(struct neig
 #endif
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
+static void rtm_neigh_change(struct neighbour *n);
 
 static struct neigh_table *neigh_tables;
 #ifdef CONFIG_PROC_FS
@@ -754,6 +757,7 @@ #endif
 			neigh->nud_state = NUD_STALE;
 			neigh->updated = jiffies;
 			neigh_suspect(neigh);
+			notify = 1;
 		}
 	} else if (state & NUD_DELAY) {
 		if (time_before_eq(now, 
@@ -762,6 +766,7 @@ #endif
 			neigh->nud_state = NUD_REACHABLE;
 			neigh->updated = jiffies;
 			neigh_connect(neigh);
+			notify = 1;
 			next = neigh->confirmed + neigh->parms->reachable_time;
 		} else {
 			NEIGH_PRINTK2("neigh %p is probed.\n", neigh);
@@ -819,6 +824,8 @@ #endif
 out:
 		write_unlock(&neigh->lock);
 	}
+	if (notify)
+		rtm_neigh_change(neigh);
 
 #ifdef CONFIG_ARPD
 	if (notify && neigh->parms->app_probes)
@@ -926,9 +933,7 @@ int neigh_update(struct neighbour *neigh
 {
 	u8 old;
 	int err;
-#ifdef CONFIG_ARPD
 	int notify = 0;
-#endif
 	struct net_device *dev;
 	int update_isrouter = 0;
 
@@ -948,9 +953,7 @@ #endif
 			neigh_suspect(neigh);
 		neigh->nud_state = new;
 		err = 0;
-#ifdef CONFIG_ARPD
 		notify = old & NUD_VALID;
-#endif
 		goto out;
 	}
 
@@ -1022,9 +1025,7 @@ #endif
 		if (!(new & NUD_CONNECTED))
 			neigh->confirmed = jiffies -
 				      (neigh->parms->base_reachable_time << 1);
-#ifdef CONFIG_ARPD
 		notify = 1;
-#endif
 	}
 	if (new == old)
 		goto out;
@@ -1055,7 +1056,11 @@ out:
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
@@ -2369,9 +2374,27 @@ static void neigh_app_notify(struct neig
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
+	if (neigh_fill_info(skb, n, 0, 0, RTM_NEIGHUPD, 0) < 0) {
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
index 5f87533..33d8a83 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -44,6 +44,7 @@ #include <net/tcp.h>
 #include <net/sock.h>
 #include <net/ip_fib.h>
 #include <net/ip_mp_alg.h>
+#include <net/netevent.h>
 
 #include "fib_lookup.h"
 
@@ -279,6 +280,14 @@ void rtmsg_fib(int event, u32 key, struc
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
index 2dc6dbb..18879e6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -104,6 +104,7 @@ #include <net/tcp.h>
 #include <net/icmp.h>
 #include <net/xfrm.h>
 #include <net/ip_mp_alg.h>
+#include <net/netevent.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -151,6 +152,8 @@ static struct dst_entry *ipv4_negative_a
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 static int rt_garbage_collect(void);
+static int rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
+			int nowait, unsigned int flags, unsigned int prot);
 
 
 static struct dst_ops ipv4_dst_ops = {
@@ -1117,6 +1120,52 @@ static void rt_del(unsigned hash, struct
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
+static void rtm_redirect(struct rtable *old, struct rtable *new)
+{
+	struct netevent_redirect netevent;
+	struct sk_buff *skb;
+	int err;
+
+	netevent.old = &old->u.dst;
+	netevent.new = &new->u.dst;
+
+	/* notify netevent subscribers */
+	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
+
+	/* Post NETLINK messages:  RTM_DELROUTE for old route, 
+				   RTM_NEWROUTE for new route */
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!skb)
+		return;
+	skb->mac.raw = skb->nh.raw = skb->data;
+	skb->dst = &old->u.dst;
+	NETLINK_CB(skb).dst_pid = 0;
+
+	err = rt_fill_info(skb, 0, 0, RTM_DELROUTE, 1, 0, RTPROT_UNSPEC);
+	if (err <= 0)
+		goto out_free;
+
+	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV4_ROUTE, GFP_ATOMIC);
+
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!skb)
+		return;
+	skb->mac.raw = skb->nh.raw = skb->data;
+	skb->dst = &new->u.dst;
+	NETLINK_CB(skb).dst_pid = 0;
+
+	err = rt_fill_info(skb, 0, 0, RTM_NEWROUTE, 1, 0, RTPROT_REDIRECT);
+	if (err <= 0)
+		goto out_free;
+
+	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV4_ROUTE, GFP_ATOMIC);
+	return;
+
+out_free:
+	kfree_skb(skb);
+	return;
+}
+
 void ip_rt_redirect(u32 old_gw, u32 daddr, u32 new_gw,
 		    u32 saddr, struct net_device *dev)
 {
@@ -1216,6 +1265,8 @@ void ip_rt_redirect(u32 old_gw, u32 dadd
 					rt_drop(rt);
 					goto do_next;
 				}
+				
+				rtm_redirect(rth, rt);
 
 				rt_del(hash, rth);
 				if (!rt_intern_hash(hash, rt, &rt))
@@ -1442,6 +1493,32 @@ unsigned short ip_rt_frag_needed(struct 
 	return est_mtu ? : new_mtu;
 }
 
+static void rtm_pmtu_update(struct rtable *rt)
+{
+	struct sk_buff *skb;
+	int err;
+
+	call_netevent_notifiers(NETEVENT_PMTU_UPDATE, &rt->u.dst);
+
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!skb)
+		return;
+	skb->mac.raw = skb->nh.raw = skb->data;
+	skb->dst = &rt->u.dst;
+	NETLINK_CB(skb).dst_pid = 0;
+
+	err = rt_fill_info(skb, 0, 0, RTM_ROUTEUPD, 1, 0, RTPROT_UNSPEC);
+	if (err <= 0)
+		goto out_free;
+
+	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV4_ROUTE, GFP_ATOMIC);
+	return;
+
+out_free:
+	kfree_skb(skb);
+	return;
+}
+
 static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 	if (dst->metrics[RTAX_MTU-1] > mtu && mtu >= 68 &&
@@ -1452,6 +1529,7 @@ static void ip_rt_update_pmtu(struct dst
 		}
 		dst->metrics[RTAX_MTU-1] = mtu;
 		dst_set_expires(dst, ip_rt_mtu_expires);
+		rtm_pmtu_update((struct rtable *)dst);
 	}
 }
 
@@ -2627,7 +2705,7 @@ int ip_route_output_key(struct rtable **
 }
 
 static int rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-			int nowait, unsigned int flags)
+			int nowait, unsigned int flags, unsigned int prot)
 {
 	struct rtable *rt = (struct rtable*)skb->dst;
 	struct rtmsg *r;
@@ -2646,7 +2724,7 @@ #endif
 	r->rtm_table	= RT_TABLE_MAIN;
 	r->rtm_type	= rt->rt_type;
 	r->rtm_scope	= RT_SCOPE_UNIVERSE;
-	r->rtm_protocol = RTPROT_UNSPEC;
+	r->rtm_protocol = prot;
 	r->rtm_flags	= (rt->rt_flags & ~0xFFFF) | RTM_F_CLONED;
 	if (rt->rt_flags & RTCF_NOTIFY)
 		r->rtm_flags |= RTM_F_NOTIFY;
@@ -2792,7 +2870,7 @@ int inet_rtm_getroute(struct sk_buff *in
 	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
 
 	err = rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
-				RTM_NEWROUTE, 0, 0);
+				RTM_NEWROUTE, 0, 0, RTPROT_UNSPEC);
 	if (!err)
 		goto out_free;
 	if (err < 0) {
@@ -2830,7 +2908,7 @@ int ip_rt_dump(struct sk_buff *skb,  str
 			skb->dst = dst_clone(&rt->u.dst);
 			if (rt_fill_info(skb, NETLINK_CB(cb->skb).pid,
 					 cb->nlh->nlmsg_seq, RTM_NEWROUTE, 
-					 1, NLM_F_MULTI) <= 0) {
+					 1, NLM_F_MULTI, RTPROT_UNSPEC) <= 0) {
 				dst_release(xchg(&skb->dst, NULL));
 				rcu_read_unlock_bh();
 				goto done;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 87c39c9..a2b1d53 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -53,6 +53,7 @@ #include <net/tcp.h>
 #include <linux/rtnetlink.h>
 #include <net/dst.h>
 #include <net/xfrm.h>
+#include <net/netevent.h>
 
 #include <asm/uaccess.h>
 
@@ -96,6 +97,10 @@ static int		ip6_pkt_discard(struct sk_bu
 static int		ip6_pkt_discard_out(struct sk_buff *skb);
 static void		ip6_link_failure(struct sk_buff *skb);
 static void		ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
+static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
+			 struct in6_addr *dst, struct in6_addr *src,
+			 int iif, int type, u32 pid, u32 seq,
+			 int prefix, unsigned int flags);
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
 static struct rt6_info *rt6_add_route_info(struct in6_addr *prefix, int prefixlen,
@@ -731,6 +736,32 @@ static void ip6_link_failure(struct sk_b
 	}
 }
 
+static void rtm_pmtu_update(struct rt6_info *rt)
+{
+	struct sk_buff *skb;
+	int err;
+
+	call_netevent_notifiers(NETEVENT_PMTU_UPDATE, &rt->u.dst);
+
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!skb)
+		return;
+	skb->mac.raw = skb->nh.raw = skb->data;
+	skb->dst = &rt->u.dst;
+	NETLINK_CB(skb).dst_pid = 0;
+
+	err = rt6_fill_node(skb, rt, NULL, NULL, 0, RTM_ROUTEUPD, 0, 0, 0, 0);
+	if (err <= 0)
+		goto out_free;
+
+	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV6_ROUTE, GFP_ATOMIC);
+	return;
+
+out_free:
+	kfree_skb(skb);
+	return;
+}
+
 static void ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 	struct rt6_info *rt6 = (struct rt6_info*)dst;
@@ -742,6 +773,7 @@ static void ip6_rt_update_pmtu(struct ds
 			dst->metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
 		}
 		dst->metrics[RTAX_MTU-1] = mtu;
+		rtm_pmtu_update(rt6);
 	}
 }
 
@@ -907,6 +939,7 @@ int ip6_route_add(struct in6_rtmsg *rtms
 	struct net_device *dev = NULL;
 	struct inet6_dev *idev = NULL;
 	int addr_type;
+	struct netevent_route_info nri;
 
 	rta = (struct rtattr **) _rtattr;
 
@@ -1085,6 +1118,9 @@ install_route:
 		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&rt->u.dst));
 	rt->u.dst.dev = dev;
 	rt->rt6i_idev = idev;
+	nri.family = AF_INET6;
+	nri.data = rt;
+	call_netevent_notifiers(NETEVENT_ROUTE_ADD, &nri);
 	return ip6_ins_rt(rt, nlh, _rtattr, req);
 
 out:
@@ -1116,6 +1152,7 @@ static int ip6_route_del(struct in6_rtms
 	struct fib6_node *fn;
 	struct rt6_info *rt;
 	int err = -ESRCH;
+	struct netevent_route_info nri;
 
 	read_lock_bh(&rt6_lock);
 
@@ -1137,6 +1174,10 @@ static int ip6_route_del(struct in6_rtms
 				continue;
 			dst_hold(&rt->u.dst);
 			read_unlock_bh(&rt6_lock);
+			
+			nri.family = AF_INET6;
+			nri.data = rt;
+			call_netevent_notifiers(NETEVENT_ROUTE_DEL, &nri);
 
 			return ip6_del_rt(rt, nlh, _rtattr, req);
 		}
@@ -1146,6 +1187,50 @@ static int ip6_route_del(struct in6_rtms
 	return err;
 }
 
+static void rtm_redirect(struct rt6_info *old, struct rt6_info *new)
+{
+	struct netevent_redirect netevent;
+	struct sk_buff *skb;
+	int err;
+
+	netevent.old = &old->u.dst;
+	netevent.new = &new->u.dst;
+	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
+
+	/* Post NETLINK messages:  RTM_DELROUTE for old route, 
+				   RTM_NEWROUTE for new route */
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!skb)
+		return;
+	skb->mac.raw = skb->nh.raw = skb->data;
+	NETLINK_CB(skb).dst_pid = 0;
+	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_ROUTE;
+
+	err = rt6_fill_node(skb, old, NULL, NULL, 0, RTM_DELROUTE, 0, 0, 0, 0);
+	if (err <= 0)
+		goto out_free;
+
+	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV6_ROUTE, GFP_ATOMIC);
+
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!skb)
+		return;
+	skb->mac.raw = skb->nh.raw = skb->data;
+	NETLINK_CB(skb).dst_pid = 0;
+	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_ROUTE;
+
+	err = rt6_fill_node(skb, new, NULL, NULL, 0, RTM_NEWROUTE, 0, 0, 0, 0);
+	if (err <= 0)
+		goto out_free;
+
+	netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV6_ROUTE, GFP_ATOMIC);
+	return;
+
+out_free:
+	kfree_skb(skb);
+	return;
+}
+
 /*
  *	Handle redirects
  */
@@ -1252,6 +1337,8 @@ restart:
 	if (ip6_ins_rt(nrt, NULL, NULL, NULL))
 		goto out;
 
+	rtm_redirect(rt, nrt);
+
 	if (rt->rt6i_flags&RTF_CACHE) {
 		ip6_del_rt(rt, NULL, NULL, NULL);
 		return;
