From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net v3 2/2] ipv6: fix ECMP route replacement
Date: Mon, 18 May 2015 20:54:00 +0200 (CEST)
Message-ID: <239760fdec3e503029fae3e5bb9d4eb3c4c33c20.1431974706.git.mkubecek@suse.cz>
References: <cover.1431974706.git.mkubecek@suse.cz>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	roopa <roopa@cumulusnetworks.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1431974706.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When replacing an IPv6 multipath route with "ip route replace", i.e.
NLM_F_CREATE | NLM_F_REPLACE, fib6_add_rt2node() replaces only first
matching route without fixing its siblings, resulting in corrupted
siblings linked list; removing one of the siblings can then end in an
infinite loop.

IPv6 ECMP implementation is a bit different from IPv4 so that route
replacement cannot work in exactly the same way. This should be a
reasonable approximation:

1. If the new route is ECMP-able and there is a matching ECMP-able one
already, replace it and all its siblings (if any).

2. If the new route is ECMP-able and no matching ECMP-able route exists,
replace first matching non-ECMP-able (if any) or just add the new one.

3. If the new route is not ECMP-able, replace first matching
non-ECMP-able route (if any) or add the new route.

We also need to remove the NLM_F_REPLACE flag after replacing old
route(s) by first nexthop of an ECMP route so that each subsequent
nexthop does not replace previous one.

Fixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (ECMP)")
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/ipv6/ip6_fib.c | 39 +++++++++++++++++++++++++++++++++++++--
 net/ipv6/route.c   | 11 +++++++----
 2 files changed, 44 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 96dbffff5a24..bde57b113009 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -693,6 +693,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 {
 	struct rt6_info *iter = NULL;
 	struct rt6_info **ins;
+	struct rt6_info **fallback_ins = NULL;
 	int replace = (info->nlh &&
 		       (info->nlh->nlmsg_flags & NLM_F_REPLACE));
 	int add = (!info->nlh ||
@@ -716,8 +717,13 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			    (info->nlh->nlmsg_flags & NLM_F_EXCL))
 				return -EEXIST;
 			if (replace) {
-				found++;
-				break;
+				if (rt_can_ecmp == rt6_qualify_for_ecmp(iter)) {
+					found++;
+					break;
+				}
+				if (rt_can_ecmp)
+					fallback_ins = fallback_ins ?: ins;
+				goto next_iter;
 			}
 
 			if (iter->dst.dev == rt->dst.dev &&
@@ -753,9 +759,17 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		if (iter->rt6i_metric > rt->rt6i_metric)
 			break;
 
+next_iter:
 		ins = &iter->dst.rt6_next;
 	}
 
+	if (fallback_ins && !found) {
+		/* No ECMP-able route found, replace first non-ECMP one */
+		ins = fallback_ins;
+		iter = *ins;
+		found++;
+	}
+
 	/* Reset round-robin state, if necessary */
 	if (ins == &fn->leaf)
 		fn->rr_ptr = NULL;
@@ -815,6 +829,8 @@ add:
 		}
 
 	} else {
+		int nsiblings;
+
 		if (!found) {
 			if (add)
 				goto add;
@@ -835,8 +851,27 @@ add:
 			info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
 			fn->fn_flags |= RTN_RTINFO;
 		}
+		nsiblings = iter->rt6i_nsiblings;
 		fib6_purge_rt(iter, fn, info->nl_net);
 		rt6_release(iter);
+
+		if (nsiblings) {
+			/* Replacing an ECMP route, remove all siblings */
+			ins = &rt->dst.rt6_next;
+			iter = *ins;
+			while (iter) {
+				if (rt6_qualify_for_ecmp(iter)) {
+					*ins = iter->dst.rt6_next;
+					fib6_purge_rt(iter, fn, info->nl_net);
+					rt6_release(iter);
+					nsiblings--;
+				} else {
+					ins = &iter->dst.rt6_next;
+				}
+				iter = *ins;
+			}
+			WARN_ON(nsiblings != 0);
+		}
 	}
 
 	return 0;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3821a3517478..c73ae5039e46 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2541,11 +2541,14 @@ beginning:
 			}
 		}
 		/* Because each route is added like a single route we remove
-		 * this flag after the first nexthop (if there is a collision,
-		 * we have already fail to add the first nexthop:
-		 * fib6_add_rt2node() has reject it).
+		 * these flags after the first nexthop: if there is a collision,
+		 * we have already failed to add the first nexthop:
+		 * fib6_add_rt2node() has rejected it; when replacing, old
+		 * nexthops have been replaced by first new, the rest should
+		 * be added to it.
 		 */
-		cfg->fc_nlinfo.nlh->nlmsg_flags &= ~NLM_F_EXCL;
+		cfg->fc_nlinfo.nlh->nlmsg_flags &= ~(NLM_F_EXCL |
+						     NLM_F_REPLACE);
 		rtnh = rtnh_next(rtnh, &remaining);
 	}
 
-- 
2.4.1
