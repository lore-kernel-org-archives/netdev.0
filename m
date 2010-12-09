From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Abstract away all dst_entry metrics accesses.
Date: Wed, 08 Dec 2010 21:48:34 -0800 (PST)
Message-ID: <20101208.214834.226775385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42776
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751749Ab0LIFsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 00:48:07 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id BD00224C089
	for <netdev@vger.kernel.org>; Wed,  8 Dec 2010 21:48:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use helper functions to hide all direct accesses, especially writes,
to dst_entry metrics values.

This will allow us to:

1) More easily change how the metrics are stored.

2) Implement COW for metrics.

In particular this will help us put metrics into the inetpeer
cache if that is what we end up doing.  We can make the _metrics
member a pointer instead of an array, initially have it point
at the read-only metrics in the FIB, and then on the first set
grab an inetpeer entry and point the _metrics member there.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h         |   26 +++++++++++++++--
 net/bridge/br_device.c    |    2 +-
 net/bridge/br_netfilter.c |    2 +-
 net/decnet/dn_route.c     |   13 ++++-----
 net/ipv4/ip_gre.c         |    2 +-
 net/ipv4/route.c          |   55 ++++++++++++++++++++-----------------
 net/ipv4/tcp_input.c      |   22 +++++++++------
 net/ipv6/ndisc.c          |    5 ++-
 net/ipv6/route.c          |   66 +++++++++++++++++++++++++-------------------
 net/xfrm/xfrm_policy.c    |    6 ++--
 10 files changed, 118 insertions(+), 81 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index a5bd726..85dee3a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -70,7 +70,7 @@ struct dst_entry {
 
 	struct  dst_ops	        *ops;
 
-	u32			metrics[RTAX_MAX];
+	u32			_metrics[RTAX_MAX];
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	__u32			tclassid;
@@ -106,7 +106,27 @@ struct dst_entry {
 static inline u32
 dst_metric(const struct dst_entry *dst, int metric)
 {
-	return dst->metrics[metric-1];
+	return dst->_metrics[metric-1];
+}
+
+static inline void dst_metric_set(struct dst_entry *dst, int metric, u32 val)
+{
+	dst->_metrics[metric-1] = val;
+}
+
+static inline void dst_import_metrics(struct dst_entry *dst, const u32 *src_metrics)
+{
+	memcpy(dst->_metrics, src_metrics, RTAX_MAX * sizeof(u32));
+}
+
+static inline void dst_copy_metrics(struct dst_entry *dest, const struct dst_entry *src)
+{
+	dst_import_metrics(dest, src->_metrics);
+}
+
+static inline u32 *dst_metrics_ptr(struct dst_entry *dst)
+{
+	return dst->_metrics;
 }
 
 static inline u32
@@ -134,7 +154,7 @@ static inline unsigned long dst_metric_rtt(const struct dst_entry *dst, int metr
 static inline void set_dst_metric_rtt(struct dst_entry *dst, int metric,
 				      unsigned long rtt)
 {
-	dst->metrics[metric-1] = jiffies_to_msecs(rtt);
+	dst_metric_set(dst, metric, jiffies_to_msecs(rtt));
 }
 
 static inline u32
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 17cb0b6..5564435 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -141,7 +141,7 @@ static int br_change_mtu(struct net_device *dev, int new_mtu)
 
 #ifdef CONFIG_BRIDGE_NETFILTER
 	/* remember the MTU in the rtable for PMTU */
-	br->fake_rtable.dst.metrics[RTAX_MTU - 1] = new_mtu;
+	dst_metric_set(&br->fake_rtable.dst, RTAX_MTU, new_mtu);
 #endif
 
 	return 0;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 6e13920..16f5c33 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -124,7 +124,7 @@ void br_netfilter_rtable_init(struct net_bridge *br)
 	atomic_set(&rt->dst.__refcnt, 1);
 	rt->dst.dev = br->dev;
 	rt->dst.path = &rt->dst;
-	rt->dst.metrics[RTAX_MTU - 1] = 1500;
+	dst_metric_set(&rt->dst, RTAX_MTU, 1500);
 	rt->dst.flags	= DST_NOXFRM;
 	rt->dst.ops = &fake_dst_ops;
 }
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 8280e43..e2e9268 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -240,13 +240,13 @@ static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu)
 
 	if (dst_metric(dst, RTAX_MTU) > mtu && mtu >= min_mtu) {
 		if (!(dst_metric_locked(dst, RTAX_MTU))) {
-			dst->metrics[RTAX_MTU-1] = mtu;
+			dst_metric_set(dst, RTAX_MTU, mtu);
 			dst_set_expires(dst, dn_rt_mtu_expires);
 		}
 		if (!(dst_metric_locked(dst, RTAX_ADVMSS))) {
 			u32 mss = mtu - DN_MAX_NSP_DATA_HEADER;
 			if (dst_metric(dst, RTAX_ADVMSS) > mss)
-				dst->metrics[RTAX_ADVMSS-1] = mss;
+				dst_metric_set(dst, RTAX_ADVMSS, mss);
 		}
 	}
 }
@@ -806,8 +806,7 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 		if (DN_FIB_RES_GW(*res) &&
 		    DN_FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = DN_FIB_RES_GW(*res);
-		memcpy(rt->dst.metrics, fi->fib_metrics,
-		       sizeof(rt->dst.metrics));
+		dst_import_metrics(&rt->dst, fi->fib_metrics);
 	}
 	rt->rt_type = res->type;
 
@@ -820,11 +819,11 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 
 	if (dst_metric(&rt->dst, RTAX_MTU) == 0 ||
 	    dst_metric(&rt->dst, RTAX_MTU) > rt->dst.dev->mtu)
-		rt->dst.metrics[RTAX_MTU-1] = rt->dst.dev->mtu;
+		dst_metric_set(&rt->dst, RTAX_MTU, rt->dst.dev->mtu);
 	mss = dn_mss_from_pmtu(dev, dst_mtu(&rt->dst));
 	if (dst_metric(&rt->dst, RTAX_ADVMSS) == 0 ||
 	    dst_metric(&rt->dst, RTAX_ADVMSS) > mss)
-		rt->dst.metrics[RTAX_ADVMSS-1] = mss;
+		dst_metric_set(&rt->dst, RTAX_ADVMSS, mss);
 	return 0;
 }
 
@@ -1502,7 +1501,7 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	RTA_PUT(skb, RTA_PREFSRC, 2, &rt->rt_local_src);
 	if (rt->rt_daddr != rt->rt_gateway)
 		RTA_PUT(skb, RTA_GATEWAY, 2, &rt->rt_gateway);
-	if (rtnetlink_put_metrics(skb, rt->dst.metrics) < 0)
+	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto rtattr_failure;
 	expires = rt->dst.expires ? rt->dst.expires - jiffies : 0;
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, 0, 0, expires,
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 258c98d..ff4e7a4 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -818,7 +818,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			     !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
 			    rt6->rt6i_dst.plen == 128) {
 				rt6->rt6i_flags |= RTF_MODIFIED;
-				skb_dst(skb)->metrics[RTAX_MTU-1] = mtu;
+				dst_metric_set(skb_dst(skb), RTAX_MTU, mtu);
 			}
 		}
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3843c2d..26ac396 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1686,11 +1686,14 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 					if (mtu < dst_mtu(&rth->dst)) {
 						dst_confirm(&rth->dst);
 						if (mtu < ip_rt_min_pmtu) {
+							u32 lock = dst_metric(&rth->dst,
+									      RTAX_LOCK);
 							mtu = ip_rt_min_pmtu;
-							rth->dst.metrics[RTAX_LOCK-1] |=
-								(1 << RTAX_MTU);
+							lock |= (1 << RTAX_MTU);
+							dst_metric_set(&rth->dst, RTAX_LOCK,
+								       lock);
 						}
-						rth->dst.metrics[RTAX_MTU-1] = mtu;
+						dst_metric_set(&rth->dst, RTAX_MTU, mtu);
 						dst_set_expires(&rth->dst,
 							ip_rt_mtu_expires);
 					}
@@ -1708,10 +1711,11 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 	if (dst_mtu(dst) > mtu && mtu >= 68 &&
 	    !(dst_metric_locked(dst, RTAX_MTU))) {
 		if (mtu < ip_rt_min_pmtu) {
+			u32 lock = dst_metric(dst, RTAX_LOCK);
 			mtu = ip_rt_min_pmtu;
-			dst->metrics[RTAX_LOCK-1] |= (1 << RTAX_MTU);
+			dst_metric_set(dst, RTAX_LOCK, lock | (1 << RTAX_MTU));
 		}
-		dst->metrics[RTAX_MTU-1] = mtu;
+		dst_metric_set(dst, RTAX_MTU, mtu);
 		dst_set_expires(dst, ip_rt_mtu_expires);
 		call_netevent_notifiers(NETEVENT_PMTU_UPDATE, dst);
 	}
@@ -1796,36 +1800,37 @@ static void set_class_tag(struct rtable *rt, u32 tag)
 
 static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 {
+	struct dst_entry *dst = &rt->dst;
 	struct fib_info *fi = res->fi;
 
 	if (fi) {
 		if (FIB_RES_GW(*res) &&
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
-		memcpy(rt->dst.metrics, fi->fib_metrics,
-		       sizeof(rt->dst.metrics));
+		dst_import_metrics(dst, fi->fib_metrics);
 		if (fi->fib_mtu == 0) {
-			rt->dst.metrics[RTAX_MTU-1] = rt->dst.dev->mtu;
-			if (dst_metric_locked(&rt->dst, RTAX_MTU) &&
+			dst_metric_set(dst, RTAX_MTU, dst->dev->mtu);
+			if (dst_metric_locked(dst, RTAX_MTU) &&
 			    rt->rt_gateway != rt->rt_dst &&
-			    rt->dst.dev->mtu > 576)
-				rt->dst.metrics[RTAX_MTU-1] = 576;
+			    dst->dev->mtu > 576)
+				dst_metric_set(dst, RTAX_MTU, 576);
 		}
 #ifdef CONFIG_NET_CLS_ROUTE
-		rt->dst.tclassid = FIB_RES_NH(*res).nh_tclassid;
+		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
 	} else
-		rt->dst.metrics[RTAX_MTU-1]= rt->dst.dev->mtu;
-
-	if (dst_metric(&rt->dst, RTAX_HOPLIMIT) == 0)
-		rt->dst.metrics[RTAX_HOPLIMIT-1] = sysctl_ip_default_ttl;
-	if (dst_mtu(&rt->dst) > IP_MAX_MTU)
-		rt->dst.metrics[RTAX_MTU-1] = IP_MAX_MTU;
-	if (dst_metric(&rt->dst, RTAX_ADVMSS) == 0)
-		rt->dst.metrics[RTAX_ADVMSS-1] = max_t(unsigned int, rt->dst.dev->mtu - 40,
-				       ip_rt_min_advmss);
-	if (dst_metric(&rt->dst, RTAX_ADVMSS) > 65535 - 40)
-		rt->dst.metrics[RTAX_ADVMSS-1] = 65535 - 40;
+		dst_metric_set(dst, RTAX_MTU, dst->dev->mtu);
+
+	if (dst_metric(dst, RTAX_HOPLIMIT) == 0)
+		dst_metric_set(dst, RTAX_HOPLIMIT, sysctl_ip_default_ttl);
+	if (dst_mtu(dst) > IP_MAX_MTU)
+		dst_metric_set(dst, RTAX_MTU, IP_MAX_MTU);
+	if (dst_metric(dst, RTAX_ADVMSS) == 0)
+		dst_metric_set(dst, RTAX_ADVMSS,
+			       max_t(unsigned int, dst->dev->mtu - 40,
+				     ip_rt_min_advmss));
+	if (dst_metric(dst, RTAX_ADVMSS) > 65535 - 40)
+		dst_metric_set(dst, RTAX_ADVMSS, 65535 - 40);
 
 #ifdef CONFIG_NET_CLS_ROUTE
 #ifdef CONFIG_IP_MULTIPLE_TABLES
@@ -2720,7 +2725,7 @@ static int ipv4_dst_blackhole(struct net *net, struct rtable **rp, struct flowi
 		new->__use = 1;
 		new->input = dst_discard;
 		new->output = dst_discard;
-		memcpy(new->metrics, ort->dst.metrics, RTAX_MAX*sizeof(u32));
+		dst_copy_metrics(new, &ort->dst);
 
 		new->dev = ort->dst.dev;
 		if (new->dev)
@@ -2827,7 +2832,7 @@ static int rt_fill_info(struct net *net,
 	if (rt->rt_dst != rt->rt_gateway)
 		NLA_PUT_BE32(skb, RTA_GATEWAY, rt->rt_gateway);
 
-	if (rtnetlink_put_metrics(skb, rt->dst.metrics) < 0)
+	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
 	if (rt->fl.mark)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6d8ab1c..824e8c8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -734,7 +734,7 @@ void tcp_update_metrics(struct sock *sk)
 			 * Reset our results.
 			 */
 			if (!(dst_metric_locked(dst, RTAX_RTT)))
-				dst->metrics[RTAX_RTT - 1] = 0;
+				dst_metric_set(dst, RTAX_RTT, 0);
 			return;
 		}
 
@@ -776,34 +776,38 @@ void tcp_update_metrics(struct sock *sk)
 			if (dst_metric(dst, RTAX_SSTHRESH) &&
 			    !dst_metric_locked(dst, RTAX_SSTHRESH) &&
 			    (tp->snd_cwnd >> 1) > dst_metric(dst, RTAX_SSTHRESH))
-				dst->metrics[RTAX_SSTHRESH-1] = tp->snd_cwnd >> 1;
+				dst_metric_set(dst, RTAX_SSTHRESH, tp->snd_cwnd >> 1);
 			if (!dst_metric_locked(dst, RTAX_CWND) &&
 			    tp->snd_cwnd > dst_metric(dst, RTAX_CWND))
-				dst->metrics[RTAX_CWND - 1] = tp->snd_cwnd;
+				dst_metric_set(dst, RTAX_CWND, tp->snd_cwnd);
 		} else if (tp->snd_cwnd > tp->snd_ssthresh &&
 			   icsk->icsk_ca_state == TCP_CA_Open) {
 			/* Cong. avoidance phase, cwnd is reliable. */
 			if (!dst_metric_locked(dst, RTAX_SSTHRESH))
-				dst->metrics[RTAX_SSTHRESH-1] =
-					max(tp->snd_cwnd >> 1, tp->snd_ssthresh);
+				dst_metric_set(dst, RTAX_SSTHRESH,
+					       max(tp->snd_cwnd >> 1, tp->snd_ssthresh));
 			if (!dst_metric_locked(dst, RTAX_CWND))
-				dst->metrics[RTAX_CWND-1] = (dst_metric(dst, RTAX_CWND) + tp->snd_cwnd) >> 1;
+				dst_metric_set(dst, RTAX_CWND,
+					       (dst_metric(dst, RTAX_CWND) +
+						tp->snd_cwnd) >> 1);
 		} else {
 			/* Else slow start did not finish, cwnd is non-sense,
 			   ssthresh may be also invalid.
 			 */
 			if (!dst_metric_locked(dst, RTAX_CWND))
-				dst->metrics[RTAX_CWND-1] = (dst_metric(dst, RTAX_CWND) + tp->snd_ssthresh) >> 1;
+				dst_metric_set(dst, RTAX_CWND,
+					       (dst_metric(dst, RTAX_CWND) +
+						tp->snd_ssthresh) >> 1);
 			if (dst_metric(dst, RTAX_SSTHRESH) &&
 			    !dst_metric_locked(dst, RTAX_SSTHRESH) &&
 			    tp->snd_ssthresh > dst_metric(dst, RTAX_SSTHRESH))
-				dst->metrics[RTAX_SSTHRESH-1] = tp->snd_ssthresh;
+				dst_metric_set(dst, RTAX_SSTHRESH, tp->snd_ssthresh);
 		}
 
 		if (!dst_metric_locked(dst, RTAX_REORDERING)) {
 			if (dst_metric(dst, RTAX_REORDERING) < tp->reordering &&
 			    tp->reordering != sysctl_tcp_reordering)
-				dst->metrics[RTAX_REORDERING-1] = tp->reordering;
+				dst_metric_set(dst, RTAX_REORDERING, tp->reordering);
 		}
 	}
 }
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index e18f841..2342545 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1259,7 +1259,8 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	if (ra_msg->icmph.icmp6_hop_limit) {
 		in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
 		if (rt)
-			rt->dst.metrics[RTAX_HOPLIMIT-1] = ra_msg->icmph.icmp6_hop_limit;
+			dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
+				       ra_msg->icmph.icmp6_hop_limit);
 	}
 
 skip_defrtr:
@@ -1377,7 +1378,7 @@ skip_linkparms:
 			in6_dev->cnf.mtu6 = mtu;
 
 			if (rt)
-				rt->dst.metrics[RTAX_MTU-1] = mtu;
+				dst_metric_set(&rt->dst, RTAX_MTU, mtu);
 
 			rt6_mtu_change(skb->dev, mtu);
 		}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 026caef..4aed081 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -129,7 +129,6 @@ static struct rt6_info ip6_null_entry_template = {
 		.__use		= 1,
 		.obsolete	= -1,
 		.error		= -ENETUNREACH,
-		.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
 		.input		= ip6_pkt_discard,
 		.output		= ip6_pkt_discard_out,
 	},
@@ -150,7 +149,6 @@ static struct rt6_info ip6_prohibit_entry_template = {
 		.__use		= 1,
 		.obsolete	= -1,
 		.error		= -EACCES,
-		.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
 		.input		= ip6_pkt_prohibit,
 		.output		= ip6_pkt_prohibit_out,
 	},
@@ -166,7 +164,6 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 		.__use		= 1,
 		.obsolete	= -1,
 		.error		= -EINVAL,
-		.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
 		.input		= dst_discard,
 		.output		= dst_discard,
 	},
@@ -844,7 +841,7 @@ int ip6_dst_blackhole(struct sock *sk, struct dst_entry **dstp, struct flowi *fl
 		new->input = dst_discard;
 		new->output = dst_discard;
 
-		memcpy(new->metrics, ort->dst.metrics, RTAX_MAX*sizeof(u32));
+		dst_copy_metrics(new, &ort->dst);
 		new->dev = ort->dst.dev;
 		if (new->dev)
 			dev_hold(new->dev);
@@ -928,10 +925,12 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
 		rt6->rt6i_flags |= RTF_MODIFIED;
 		if (mtu < IPV6_MIN_MTU) {
+			u32 features = dst_metric(dst, RTAX_FEATURES);
 			mtu = IPV6_MIN_MTU;
-			dst->metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
+			features |= RTAX_FEATURE_ALLFRAG;
+			dst_metric_set(dst, RTAX_FEATURES, features);
 		}
-		dst->metrics[RTAX_MTU-1] = mtu;
+		dst_metric_set(dst, RTAX_MTU, mtu);
 		call_netevent_notifiers(NETEVENT_PMTU_UPDATE, dst);
 	}
 }
@@ -989,9 +988,9 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt->rt6i_idev     = idev;
 	rt->rt6i_nexthop  = neigh;
 	atomic_set(&rt->dst.__refcnt, 1);
-	rt->dst.metrics[RTAX_HOPLIMIT-1] = 255;
-	rt->dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
-	rt->dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->dst));
+	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
+	dst_metric_set(&rt->dst, RTAX_MTU, ipv6_get_mtu(rt->rt6i_dev));
+	dst_metric_set(&rt->dst, RTAX_ADVMSS, ipv6_advmss(net, dst_mtu(&rt->dst)));
 	rt->dst.output  = ip6_output;
 
 #if 0	/* there's no chance to use these for ndisc */
@@ -1305,17 +1304,17 @@ install_route:
 					goto out;
 				}
 
-				rt->dst.metrics[type - 1] = nla_get_u32(nla);
+				dst_metric_set(&rt->dst, type, nla_get_u32(nla));
 			}
 		}
 	}
 
 	if (dst_metric(&rt->dst, RTAX_HOPLIMIT) == 0)
-		rt->dst.metrics[RTAX_HOPLIMIT-1] = -1;
+		dst_metric_set(&rt->dst, RTAX_HOPLIMIT, -1);
 	if (!dst_mtu(&rt->dst))
-		rt->dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(dev);
+		dst_metric_set(&rt->dst, RTAX_MTU, ipv6_get_mtu(dev));
 	if (!dst_metric(&rt->dst, RTAX_ADVMSS))
-		rt->dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->dst));
+		dst_metric_set(&rt->dst, RTAX_ADVMSS, ipv6_advmss(net, dst_mtu(&rt->dst)));
 	rt->dst.dev = dev;
 	rt->rt6i_idev = idev;
 	rt->rt6i_table = table;
@@ -1541,9 +1540,9 @@ void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
 	ipv6_addr_copy(&nrt->rt6i_gateway, (struct in6_addr*)neigh->primary_key);
 	nrt->rt6i_nexthop = neigh_clone(neigh);
 	/* Reset pmtu, it may be better */
-	nrt->dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(neigh->dev);
-	nrt->dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dev_net(neigh->dev),
-							dst_mtu(&nrt->dst));
+	dst_metric_set(&nrt->dst, RTAX_MTU, ipv6_get_mtu(neigh->dev));
+	dst_metric_set(&nrt->dst, RTAX_ADVMSS, ipv6_advmss(dev_net(neigh->dev),
+							   dst_mtu(&nrt->dst)));
 
 	if (ip6_ins_rt(nrt))
 		goto out;
@@ -1602,9 +1601,12 @@ static void rt6_do_pmtu_disc(struct in6_addr *daddr, struct in6_addr *saddr,
 	   would return automatically.
 	 */
 	if (rt->rt6i_flags & RTF_CACHE) {
-		rt->dst.metrics[RTAX_MTU-1] = pmtu;
-		if (allfrag)
-			rt->dst.metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
+		dst_metric_set(&rt->dst, RTAX_MTU, pmtu);
+		if (allfrag) {
+			u32 features = dst_metric(&rt->dst, RTAX_FEATURES);
+			features |= RTAX_FEATURE_ALLFRAG;
+			dst_metric_set(&rt->dst, RTAX_FEATURES, features);
+		}
 		dst_set_expires(&rt->dst, net->ipv6.sysctl.ip6_rt_mtu_expires);
 		rt->rt6i_flags |= RTF_MODIFIED|RTF_EXPIRES;
 		goto out;
@@ -1621,9 +1623,12 @@ static void rt6_do_pmtu_disc(struct in6_addr *daddr, struct in6_addr *saddr,
 		nrt = rt6_alloc_clone(rt, daddr);
 
 	if (nrt) {
-		nrt->dst.metrics[RTAX_MTU-1] = pmtu;
-		if (allfrag)
-			nrt->dst.metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
+		dst_metric_set(&nrt->dst, RTAX_MTU, pmtu);
+		if (allfrag) {
+			u32 features = dst_metric(&nrt->dst, RTAX_FEATURES);
+			features |= RTAX_FEATURE_ALLFRAG;
+			dst_metric_set(&nrt->dst, RTAX_FEATURES, features);
+		}
 
 		/* According to RFC 1981, detecting PMTU increase shouldn't be
 		 * happened within 5 mins, the recommended timer is 10 mins.
@@ -1674,7 +1679,7 @@ static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 		rt->dst.input = ort->dst.input;
 		rt->dst.output = ort->dst.output;
 
-		memcpy(rt->dst.metrics, ort->dst.metrics, RTAX_MAX*sizeof(u32));
+		dst_copy_metrics(&rt->dst, &ort->dst);
 		rt->dst.error = ort->dst.error;
 		rt->dst.dev = ort->dst.dev;
 		if (rt->dst.dev)
@@ -1966,9 +1971,9 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->dst.output = ip6_output;
 	rt->rt6i_dev = net->loopback_dev;
 	rt->rt6i_idev = idev;
-	rt->dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
-	rt->dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->dst));
-	rt->dst.metrics[RTAX_HOPLIMIT-1] = -1;
+	dst_metric_set(&rt->dst, RTAX_MTU, ipv6_get_mtu(rt->rt6i_dev));
+	dst_metric_set(&rt->dst, RTAX_ADVMSS, ipv6_advmss(net, dst_mtu(&rt->dst)));
+	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, -1);
 	rt->dst.obsolete = -1;
 
 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;
@@ -2068,8 +2073,8 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 	    (dst_mtu(&rt->dst) >= arg->mtu ||
 	     (dst_mtu(&rt->dst) < arg->mtu &&
 	      dst_mtu(&rt->dst) == idev->cnf.mtu6))) {
-		rt->dst.metrics[RTAX_MTU-1] = arg->mtu;
-		rt->dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, arg->mtu);
+		dst_metric_set(&rt->dst, RTAX_MTU, arg->mtu);
+		dst_metric_set(&rt->dst, RTAX_ADVMSS, ipv6_advmss(net, arg->mtu));
 	}
 	return 0;
 }
@@ -2295,7 +2300,7 @@ static int rt6_fill_node(struct net *net,
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
 
-	if (rtnetlink_put_metrics(skb, rt->dst.metrics) < 0)
+	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
 	if (rt->dst.neighbour)
@@ -2686,6 +2691,7 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.ip6_null_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_null_entry;
 	net->ipv6.ip6_null_entry->dst.ops = &net->ipv6.ip6_dst_ops;
+	dst_metric_set(&net->ipv6.ip6_null_entry->dst, RTAX_HOPLIMIT, 255);
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	net->ipv6.ip6_prohibit_entry = kmemdup(&ip6_prohibit_entry_template,
@@ -2696,6 +2702,7 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.ip6_prohibit_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_prohibit_entry;
 	net->ipv6.ip6_prohibit_entry->dst.ops = &net->ipv6.ip6_dst_ops;
+	dst_metric_set(&net->ipv6.ip6_prohibit_entry->dst, RTAX_HOPLIMIT, 255);
 
 	net->ipv6.ip6_blk_hole_entry = kmemdup(&ip6_blk_hole_entry_template,
 					       sizeof(*net->ipv6.ip6_blk_hole_entry),
@@ -2705,6 +2712,7 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.ip6_blk_hole_entry->dst.path =
 		(struct dst_entry *)net->ipv6.ip6_blk_hole_entry;
 	net->ipv6.ip6_blk_hole_entry->dst.ops = &net->ipv6.ip6_dst_ops;
+	dst_metric_set(&net->ipv6.ip6_blk_hole_entry->dst, RTAX_HOPLIMIT, 255);
 #endif
 
 	net->ipv6.sysctl.flush_delay = 0;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 044e778..6e50ccd 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1433,7 +1433,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		}
 
 		xdst->route = dst;
-		memcpy(&dst1->metrics, &dst->metrics, sizeof(dst->metrics));
+		dst_copy_metrics(dst1, dst);
 
 		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
 			family = xfrm[i]->props.family;
@@ -2271,7 +2271,7 @@ static void xfrm_init_pmtu(struct dst_entry *dst)
 		if (pmtu > route_mtu_cached)
 			pmtu = route_mtu_cached;
 
-		dst->metrics[RTAX_MTU-1] = pmtu;
+		dst_metric_set(dst, RTAX_MTU, pmtu);
 	} while ((dst = dst->next));
 }
 
@@ -2349,7 +2349,7 @@ static int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 		mtu = xfrm_state_mtu(dst->xfrm, mtu);
 		if (mtu > last->route_mtu_cached)
 			mtu = last->route_mtu_cached;
-		dst->metrics[RTAX_MTU-1] = mtu;
+		dst_metric_set(dst, RTAX_MTU, mtu);
 
 		if (last == first)
 			break;
-- 
1.7.3.2

