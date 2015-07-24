From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/2] lwtunnel: change prototype of lwtunnel_state_get()
Date: Fri, 24 Jul 2015 12:28:36 +0200
Message-ID: <1437733716-4494-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:50859 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbbGXK2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 06:28:53 -0400
In-Reply-To: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It saves some lines and simplify a bit the code when the state is returning
by this function. It's also useful to handle a NULL entry.

To avoid too long lines, I've also renamed lwtunnel_state_get() and
lwtunnel_state_put() to lwtstate_get() and lwtstate_put().

CC: Thomas Graf <tgraf@suug.ch>
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/lwtunnel.h   | 16 +++++++++++-----
 net/ipv4/fib_semantics.c |  9 ++++-----
 net/ipv4/route.c         |  9 ++-------
 net/ipv6/ip6_fib.c       |  2 +-
 net/ipv6/route.c         |  8 ++------
 5 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index bd72e82b45a1..78376da1afa2 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -37,12 +37,16 @@ extern const struct lwtunnel_encap_ops __rcu *
 		lwtun_encaps[LWTUNNEL_ENCAP_MAX+1];
 
 #ifdef CONFIG_LWTUNNEL
-static inline void lwtunnel_state_get(struct lwtunnel_state *lws)
+static inline struct lwtunnel_state *
+lwtstate_get(struct lwtunnel_state *lws)
 {
-	atomic_inc(&lws->refcnt);
+	if (lws)
+		atomic_inc(&lws->refcnt);
+
+	return lws;
 }
 
-static inline void lwtunnel_state_put(struct lwtunnel_state *lws)
+static inline void lwtstate_put(struct lwtunnel_state *lws)
 {
 	if (!lws)
 		return;
@@ -76,11 +80,13 @@ int lwtunnel_output6(struct sock *sk, struct sk_buff *skb);
 
 #else
 
-static inline void lwtunnel_state_get(struct lwtunnel_state *lws)
+static inline struct lwtunnel_state *
+lwtstate_get(struct lwtunnel_state *lws)
 {
+	return lws;
 }
 
-static inline void lwtunnel_state_put(struct lwtunnel_state *lws)
+static inline void lwtstate_put(struct lwtunnel_state *lws)
 {
 }
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 6754c64b2fe0..7226df887531 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -209,7 +209,7 @@ static void free_fib_info_rcu(struct rcu_head *head)
 	change_nexthops(fi) {
 		if (nexthop_nh->nh_dev)
 			dev_put(nexthop_nh->nh_dev);
-		lwtunnel_state_put(nexthop_nh->nh_lwtstate);
+		lwtstate_put(nexthop_nh->nh_lwtstate);
 		free_nh_exceptions(nexthop_nh);
 		rt_fibinfo_free_cpus(nexthop_nh->nh_pcpu_rth_output);
 		rt_fibinfo_free(&nexthop_nh->nh_rth_input);
@@ -512,8 +512,8 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 							   nla, &lwtstate);
 				if (ret)
 					goto errout;
-				lwtunnel_state_get(lwtstate);
-				nexthop_nh->nh_lwtstate = lwtstate;
+				nexthop_nh->nh_lwtstate =
+					lwtstate_get(lwtstate);
 			}
 		}
 
@@ -969,8 +969,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			if (err)
 				goto failure;
 
-			lwtunnel_state_get(lwtstate);
-			nh->nh_lwtstate = lwtstate;
+			nh->nh_lwtstate = lwtstate_get(lwtstate);
 		}
 		nh->nh_oif = cfg->fc_oif;
 		nh->nh_gw = cfg->fc_gw;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 519ec232818d..11096396ef4a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1358,7 +1358,7 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 		list_del(&rt->rt_uncached);
 		spin_unlock_bh(&ul->lock);
 	}
-	lwtunnel_state_put(rt->rt_lwtstate);
+	lwtstate_put(rt->rt_lwtstate);
 }
 
 void rt_flush_dev(struct net_device *dev)
@@ -1407,12 +1407,7 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
-		if (nh->nh_lwtstate) {
-			lwtunnel_state_get(nh->nh_lwtstate);
-			rt->rt_lwtstate = nh->nh_lwtstate;
-		} else {
-			rt->rt_lwtstate = NULL;
-		}
+		rt->rt_lwtstate = lwtstate_get(nh->nh_lwtstate);
 		if (unlikely(fnhe))
 			cached = rt_bind_exception(rt, fnhe, daddr);
 		else if (!(rt->dst.flags & DST_NOCACHE))
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index d715f2e0c4e7..5693b5eb8482 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -178,7 +178,7 @@ static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 static void rt6_release(struct rt6_info *rt)
 {
 	if (atomic_dec_and_test(&rt->rt6i_ref)) {
-		lwtunnel_state_put(rt->rt6i_lwtstate);
+		lwtstate_put(rt->rt6i_lwtstate);
 		rt6_free_pcpu(rt);
 		dst_free(&rt->dst);
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ac01ab0886a5..894cb18cd8ca 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1778,8 +1778,7 @@ int ip6_route_add(struct fib6_config *cfg)
 					   cfg->fc_encap, &lwtstate);
 		if (err)
 			goto out;
-		lwtunnel_state_get(lwtstate);
-		rt->rt6i_lwtstate = lwtstate;
+		rt->rt6i_lwtstate = lwtstate_get(lwtstate);
 		if (lwtunnel_output_redirect(rt->rt6i_lwtstate))
 			rt->dst.output = lwtunnel_output6;
 	}
@@ -2164,10 +2163,7 @@ static void ip6_rt_copy_init(struct rt6_info *rt, struct rt6_info *ort)
 #endif
 	rt->rt6i_prefsrc = ort->rt6i_prefsrc;
 	rt->rt6i_table = ort->rt6i_table;
-	if (ort->rt6i_lwtstate) {
-		lwtunnel_state_get(ort->rt6i_lwtstate);
-		rt->rt6i_lwtstate = ort->rt6i_lwtstate;
-	}
+	rt->rt6i_lwtstate = lwtstate_get(ort->rt6i_lwtstate);
 }
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
-- 
2.4.2
