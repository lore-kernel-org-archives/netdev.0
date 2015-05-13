From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net 2/2] ipv6: fix ECMP route replacement
Date: Wed, 13 May 2015 11:50:40 +0200 (CEST)
Message-ID: <9353448103f659d9b7ab51283b4222daaf0df54c.1431500953.git.mkubecek@suse.cz>
References: <cover.1431500953.git.mkubecek@suse.cz>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1431500953.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When replacing an IPv6 multipath route with "ip route replace", i.e.
NLM_F_CREATE | NLM_F_REPLACE, fib6_add_rt2node() replaces only first
matching route without fixing its siblings, resulting in corrupted
siblings linked list; removing one of the siblings can then end in an
infinite loop.

Replacing the whole set of nexthops does IMHO make more sense than
replacing a random one. We also need to remove the NLM_F_REPLACE flag
after replacing old nexthops by first new so that each subsequent
nexthop does not replace previous one.

Fixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (ECMP)")
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/ipv6/ip6_fib.c | 17 ++++++++++++++---
 net/ipv6/route.c   |  8 +++++---
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 96dbffff5a24..abf4e4e5bdab 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -815,6 +815,8 @@ add:
 		}
 
 	} else {
+		struct rt6_info *next;
+
 		if (!found) {
 			if (add)
 				goto add;
@@ -828,15 +830,24 @@ add:
 
 		*ins = rt;
 		rt->rt6i_node = fn;
-		rt->dst.rt6_next = iter->dst.rt6_next;
+
+		/* skip potential siblings */
+		next = iter->dst.rt6_next;
+		while (next && next->rt6i_metric == rt->rt6i_metric)
+			next = next->dst.rt6_next;
+		rt->dst.rt6_next = next;
+
 		atomic_inc(&rt->rt6i_ref);
 		inet6_rt_notify(RTM_NEWROUTE, rt, info);
 		if (!(fn->fn_flags & RTN_RTINFO)) {
 			info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
 			fn->fn_flags |= RTN_RTINFO;
 		}
-		fib6_purge_rt(iter, fn, info->nl_net);
-		rt6_release(iter);
+		while (iter != next) {
+			fib6_purge_rt(iter, fn, info->nl_net);
+			rt6_release(iter);
+			iter = iter->dst.rt6_next;
+		}
 	}
 
 	return 0;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 18b92c05b541..b9af963207fa 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2541,11 +2541,13 @@ beginning:
 			}
 		}
 		/* Because each route is added like a single route we remove
-		 * this flag after the first nexthop (if there is a collision,
+		 * these flags after the first nexthop: if there is a collision,
 		 * we have already fail to add the first nexthop:
-		 * fib6_add_rt2node() has reject it).
+		 * fib6_add_rt2node() has reject it; when replacing, old
+		 * nexthops are removed by first new, the rest is added to it.
 		 */
-		cfg->fc_nlinfo.nlh->nlmsg_flags &= ~NLM_F_EXCL;
+		cfg->fc_nlinfo.nlh->nlmsg_flags &= ~(NLM_F_EXCL |
+						     NLM_F_REPLACE);
 		rtnh = rtnh_next(rtnh, &remaining);
 	}
 
-- 
2.3.7
