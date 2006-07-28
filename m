From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH Round 5 2/3] Core net changes to generate netevents
Date: Fri, 28 Jul 2006 13:29:09 -0500
Message-ID: <20060728182909.14325.2628.stgit@stevo-desktop>
References: <20060728182849.14325.62898.stgit@stevo-desktop>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:35300 "EHLO
	linux.local") by vger.kernel.org with ESMTP id S1751254AbWG1S3U
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 14:29:20 -0400
To: davem@davemloft.net, rdreier@cisco.com
In-Reply-To: <20060728182849.14325.62898.stgit@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Generate netevents for:
- neighbour changes
- routing redirects
- pmtu changes
---

 net/core/Makefile    |    2 +-
 net/core/neighbour.c |   14 ++++++++------
 net/ipv4/route.c     |    8 ++++++++
 net/ipv6/route.c     |    7 +++++++
 4 files changed, 24 insertions(+), 7 deletions(-)

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
index 7ad681f..5130d2e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -29,6 +29,7 @@ #include <linux/times.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/sock.h>
+#include <net/netevent.h>
 #include <linux/rtnetlink.h>
 #include <linux/random.h>
 #include <linux/string.h>
@@ -754,6 +755,7 @@ #endif
 			neigh->nud_state = NUD_STALE;
 			neigh->updated = jiffies;
 			neigh_suspect(neigh);
+			notify = 1;
 		}
 	} else if (state & NUD_DELAY) {
 		if (time_before_eq(now, 
@@ -762,6 +764,7 @@ #endif
 			neigh->nud_state = NUD_REACHABLE;
 			neigh->updated = jiffies;
 			neigh_connect(neigh);
+			notify = 1;
 			next = neigh->confirmed + neigh->parms->reachable_time;
 		} else {
 			NEIGH_PRINTK2("neigh %p is probed.\n", neigh);
@@ -819,6 +822,8 @@ #endif
 out:
 		write_unlock(&neigh->lock);
 	}
+	if (notify)
+		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, neigh);
 
 #ifdef CONFIG_ARPD
 	if (notify && neigh->parms->app_probes)
@@ -926,9 +931,7 @@ int neigh_update(struct neighbour *neigh
 {
 	u8 old;
 	int err;
-#ifdef CONFIG_ARPD
 	int notify = 0;
-#endif
 	struct net_device *dev;
 	int update_isrouter = 0;
 
@@ -948,9 +951,7 @@ #endif
 			neigh_suspect(neigh);
 		neigh->nud_state = new;
 		err = 0;
-#ifdef CONFIG_ARPD
 		notify = old & NUD_VALID;
-#endif
 		goto out;
 	}
 
@@ -1022,9 +1023,7 @@ #endif
 		if (!(new & NUD_CONNECTED))
 			neigh->confirmed = jiffies -
 				      (neigh->parms->base_reachable_time << 1);
-#ifdef CONFIG_ARPD
 		notify = 1;
-#endif
 	}
 	if (new == old)
 		goto out;
@@ -1056,6 +1055,9 @@ out:
 			(neigh->flags & ~NTF_ROUTER);
 	}
 	write_unlock_bh(&neigh->lock);
+
+	if (notify)
+		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, neigh);
 #ifdef CONFIG_ARPD
 	if (notify && neigh->parms->app_probes)
 		neigh_app_notify(neigh);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2dc6dbb..19bd49d 100644
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
@@ -1125,6 +1126,7 @@ void ip_rt_redirect(u32 old_gw, u32 dadd
 	struct rtable *rth, **rthp;
 	u32  skeys[2] = { saddr, 0 };
 	int  ikeys[2] = { dev->ifindex, 0 };
+	struct netevent_redirect netevent;
 
 	if (!in_dev)
 		return;
@@ -1216,6 +1218,11 @@ void ip_rt_redirect(u32 old_gw, u32 dadd
 					rt_drop(rt);
 					goto do_next;
 				}
+				
+				netevent.old = &rth->u.dst;
+				netevent.new = &rt->u.dst;
+				call_netevent_notifiers(NETEVENT_REDIRECT, 
+						        &netevent);
 
 				rt_del(hash, rth);
 				if (!rt_intern_hash(hash, rt, &rt))
@@ -1452,6 +1459,7 @@ static void ip_rt_update_pmtu(struct dst
 		}
 		dst->metrics[RTAX_MTU-1] = mtu;
 		dst_set_expires(dst, ip_rt_mtu_expires);
+		call_netevent_notifiers(NETEVENT_PMTU_UPDATE, dst);
 	}
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 87c39c9..4b16371 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -53,6 +53,7 @@ #include <net/tcp.h>
 #include <linux/rtnetlink.h>
 #include <net/dst.h>
 #include <net/xfrm.h>
+#include <net/netevent.h>
 
 #include <asm/uaccess.h>
 
@@ -742,6 +743,7 @@ static void ip6_rt_update_pmtu(struct ds
 			dst->metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
 		}
 		dst->metrics[RTAX_MTU-1] = mtu;
+		call_netevent_notifiers(NETEVENT_PMTU_UPDATE, dst);
 	}
 }
 
@@ -1155,6 +1157,7 @@ void rt6_redirect(struct in6_addr *dest,
 	struct rt6_info *rt, *nrt = NULL;
 	int strict;
 	struct fib6_node *fn;
+	struct netevent_redirect netevent;
 
 	/*
 	 * Get the "current" route for this destination and
@@ -1252,6 +1255,10 @@ restart:
 	if (ip6_ins_rt(nrt, NULL, NULL, NULL))
 		goto out;
 
+	netevent.old = &rt->u.dst;
+	netevent.new = &nrt->u.dst;
+	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
+
 	if (rt->rt6i_flags&RTF_CACHE) {
 		ip6_del_rt(rt, NULL, NULL, NULL);
 		return;
