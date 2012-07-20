From: David Miller <davem@davemloft.net>
Subject: [PATCH 09/16] ipv4: Kill routes during PMTU/redirect updates.
Date: Fri, 20 Jul 2012 14:26:04 -0700 (PDT)
Message-ID: <20120720.142604.619488622366439492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268Ab2GTV0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 17:26:05 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id BCBAB583615
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 14:26:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Mark them obsolete so there will be a re-lookup to fetch the
FIB nexthop exception info.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h |    1 +
 net/ipv4/route.c  |   41 +++++++++++++++++++++++++++++------------
 2 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 0df661a..baf5978 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -78,6 +78,7 @@ struct dst_entry {
 #define DST_OBSOLETE_NONE	0
 #define DST_OBSOLETE_DEAD	2
 #define DST_OBSOLETE_FORCE_CHK	-1
+#define DST_OBSOLETE_KILL	-2
 	unsigned short		header_len;	/* more space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
 #ifdef CONFIG_IP_ROUTE_CLASSID
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 50d2498..d52f769 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -673,7 +673,8 @@ out_unlock:
 	return;
 }
 
-static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flowi4 *fl4)
+static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flowi4 *fl4,
+			     bool kill_route)
 {
 	__be32 new_gw = icmp_hdr(skb)->un.gateway;
 	__be32 old_gw = ip_hdr(skb)->saddr;
@@ -728,8 +729,8 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 				update_or_create_fnhe(nh, fl4->daddr, new_gw,
 						      0, 0);
 			}
-			rt->rt_gateway = new_gw;
-			rt->rt_flags |= RTCF_REDIRECTED;
+			if (kill_route)
+				rt->dst.obsolete = DST_OBSOLETE_KILL;
 			call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
 		}
 		neigh_release(n);
@@ -760,7 +761,7 @@ static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buf
 	rt = (struct rtable *) dst;
 
 	ip_rt_build_flow_key(&fl4, sk, skb);
-	__ip_do_redirect(rt, skb, &fl4);
+	__ip_do_redirect(rt, skb, &fl4, true);
 }
 
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
@@ -919,7 +920,7 @@ out:	kfree_skb(skb);
 	return 0;
 }
 
-static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
+static u32 __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 {
 	struct fib_result res;
 
@@ -932,8 +933,7 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 		update_or_create_fnhe(nh, fl4->daddr, 0, mtu,
 				      jiffies + ip_rt_mtu_expires);
 	}
-	rt->rt_pmtu = mtu;
-	dst_set_expires(&rt->dst, ip_rt_mtu_expires);
+	return mtu;
 }
 
 static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
@@ -943,7 +943,14 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 	struct flowi4 fl4;
 
 	ip_rt_build_flow_key(&fl4, sk, skb);
-	__ip_rt_update_pmtu(rt, &fl4, mtu);
+	mtu = __ip_rt_update_pmtu(rt, &fl4, mtu);
+
+	if (!rt->rt_pmtu) {
+		dst->obsolete = DST_OBSOLETE_KILL;
+	} else {
+		rt->rt_pmtu = mtu;
+		dst_set_expires(&rt->dst, ip_rt_mtu_expires);
+	}
 }
 
 void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
@@ -989,7 +996,7 @@ void ipv4_redirect(struct sk_buff *skb, struct net *net,
 			 RT_TOS(iph->tos), protocol, mark, flow_flags);
 	rt = __ip_route_output_key(net, &fl4);
 	if (!IS_ERR(rt)) {
-		__ip_do_redirect(rt, skb, &fl4);
+		__ip_do_redirect(rt, skb, &fl4, false);
 		ip_rt_put(rt);
 	}
 }
@@ -1004,7 +1011,7 @@ void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk)
 	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
 	rt = __ip_route_output_key(sock_net(sk), &fl4);
 	if (!IS_ERR(rt)) {
-		__ip_do_redirect(rt, skb, &fl4);
+		__ip_do_redirect(rt, skb, &fl4, false);
 		ip_rt_put(rt);
 	}
 }
@@ -1014,7 +1021,15 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {
 	struct rtable *rt = (struct rtable *) dst;
 
-	if (rt_is_expired(rt))
+	/* All IPV4 dsts are created with ->obsolete set to the value
+	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
+	 * into this function always.
+	 *
+	 * When a PMTU/redirect information update invalidates a
+	 * route, this is indicated by setting obsolete to
+	 * DST_OBSOLETE_KILL.
+	 */
+	if (dst->obsolete == DST_OBSOLETE_KILL || rt_is_expired(rt))
 		return NULL;
 	return dst;
 }
@@ -1186,8 +1201,10 @@ restart:
 				dst_set_expires(&rt->dst, diff);
 			}
 		}
-		if (gw)
+		if (gw) {
+			rt->rt_flags |= RTCF_REDIRECTED;
 			rt->rt_gateway = gw;
+		}
 		fnhe->fnhe_stamp = jiffies;
 		break;
 	}
-- 
1.7.10.4
