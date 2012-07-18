From: David Miller <davem@davemloft.net>
Subject: [PATCH 08/15] ipv4: Kill routes during PMTU/redirect updates.
Date: Wed, 18 Jul 2012 11:23:56 -0700 (PDT)
Message-ID: <20120718.112356.1409220904008377845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405Ab2GRSX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:23:57 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 37E5F583FCF
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 11:23:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Mark them obsolete so there will be a re-lookup to fetch the
FIB nexthop exception info.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   39 +++++++++++++++++++++++++++------------
 1 file changed, 27 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7ebf788..4d170a1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -657,7 +657,8 @@ out:
 	return fnhe;
 }
 
-static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flowi4 *fl4)
+static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flowi4 *fl4,
+			     bool kill_route)
 {
 	__be32 new_gw = icmp_hdr(skb)->un.gateway;
 	__be32 old_gw = ip_hdr(skb)->saddr;
@@ -716,8 +717,8 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 					fnhe->fnhe_gw = new_gw;
 				spin_unlock_bh(&fnhe_lock);
 			}
-			rt->rt_gateway = new_gw;
-			rt->rt_flags |= RTCF_REDIRECTED;
+			if (kill_route)
+				rt->dst.obsolete = -2;
 			call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
 		}
 		neigh_release(n);
@@ -748,7 +749,7 @@ static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buf
 	rt = (struct rtable *) dst;
 
 	ip_rt_build_flow_key(&fl4, sk, skb);
-	__ip_do_redirect(rt, skb, &fl4);
+	__ip_do_redirect(rt, skb, &fl4, true);
 }
 
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
@@ -907,7 +908,7 @@ out:	kfree_skb(skb);
 	return 0;
 }
 
-static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
+static u32 __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 {
 	struct fib_result res;
 
@@ -926,8 +927,7 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 		}
 		spin_unlock_bh(&fnhe_lock);
 	}
-	rt->rt_pmtu = mtu;
-	dst_set_expires(&rt->dst, ip_rt_mtu_expires);
+	return mtu;
 }
 
 static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
@@ -937,7 +937,14 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 	struct flowi4 fl4;
 
 	ip_rt_build_flow_key(&fl4, sk, skb);
-	__ip_rt_update_pmtu(rt, &fl4, mtu);
+	mtu = __ip_rt_update_pmtu(rt, &fl4, mtu);
+
+	if (!rt->rt_pmtu) {
+		dst->expires = -2;
+	} else {
+		rt->rt_pmtu = mtu;
+		dst_set_expires(&rt->dst, ip_rt_mtu_expires);
+	}
 }
 
 void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
@@ -983,7 +990,7 @@ void ipv4_redirect(struct sk_buff *skb, struct net *net,
 			 RT_TOS(iph->tos), protocol, mark, flow_flags);
 	rt = __ip_route_output_key(net, &fl4);
 	if (!IS_ERR(rt)) {
-		__ip_do_redirect(rt, skb, &fl4);
+		__ip_do_redirect(rt, skb, &fl4, false);
 		ip_rt_put(rt);
 	}
 }
@@ -998,7 +1005,7 @@ void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk)
 	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
 	rt = __ip_route_output_key(sock_net(sk), &fl4);
 	if (!IS_ERR(rt)) {
-		__ip_do_redirect(rt, skb, &fl4);
+		__ip_do_redirect(rt, skb, &fl4, false);
 		ip_rt_put(rt);
 	}
 }
@@ -1008,7 +1015,13 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {
 	struct rtable *rt = (struct rtable *) dst;
 
-	if (rt_is_expired(rt))
+	/* All IPV4 dsts are created with obsoluete set to -1, that
+	 * forces validation calls down into this function always.
+	 *
+	 * When a PMTU/redirect information update invalidates a
+	 * route, this is indicated by setting obsolete to -2.
+	 */
+	if (dst->obsolete == -2 || rt_is_expired(rt))
 		return NULL;
 	return dst;
 }
@@ -1168,8 +1181,10 @@ static void rt_bind_exception(struct rtable *rt, struct fib_nh *nh, __be32 daddr
 					dst_set_expires(&rt->dst, diff);
 				}
 			}
-			if (fnhe->fnhe_gw)
+			if (fnhe->fnhe_gw) {
+				rt->rt_flags |= RTCF_REDIRECTED;
 				rt->rt_gateway = fnhe->fnhe_gw;
+			}
 			fnhe->fnhe_stamp = jiffies;
 			break;
 		}
-- 
1.7.10.4
