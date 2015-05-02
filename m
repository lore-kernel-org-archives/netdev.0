From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next v3 2/9] ipv6: Remove external dependency on rt6i_gateway and RTF_ANYCAST
Date: Fri, 1 May 2015 17:26:51 -0700
Message-ID: <1430526418-3132761-3-git-send-email-kafai@fb.com>
References: <1430526418-3132761-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59950 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbbEBA2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 20:28:20 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t420RJaL012255
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 17:28:19 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u4k6482qr-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 17:28:19 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 213c100ef06211e4bd440002c992ebde-d6d5d6e0 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 17:28:18 -0700
In-Reply-To: <1430526418-3132761-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating a RTF_CACHE route, RTF_ANYCAST is set based on rt6i_dst.
Also, rt6i_gateway is always set to the nexthop while the nexthop
could be a gateway or the rt6i_dst.addr.

After removing the rt6i_dst and rt6i_src dependency in the last patch,
we also need to stop the caller from depending on rt6i_gateway and
RTF_ANYCAST.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip6_route.h                | 19 ++++++++++++++-----
 net/bluetooth/6lowpan.c                |  2 +-
 net/ipv6/icmp.c                        |  4 ++--
 net/ipv6/ip6_output.c                  |  5 +++--
 net/ipv6/route.c                       |  6 +-----
 net/netfilter/nf_conntrack_h323_main.c |  4 ++--
 net/netfilter/xt_addrtype.c            |  2 +-
 7 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 5e19206..4caf7d6 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -163,11 +163,14 @@ static inline bool ipv6_unicast_destination(const struct sk_buff *skb)
 	return rt->rt6i_flags & RTF_LOCAL;
 }
 
-static inline bool ipv6_anycast_destination(const struct sk_buff *skb)
+static inline bool ipv6_anycast_destination(const struct dst_entry *dst,
+					    const struct in6_addr *daddr)
 {
-	struct rt6_info *rt = (struct rt6_info *) skb_dst(skb);
+	struct rt6_info *rt = (struct rt6_info *)dst;
 
-	return rt->rt6i_flags & RTF_ANYCAST;
+	return rt->rt6i_flags & RTF_ANYCAST ||
+		(rt->rt6i_dst.plen != 128 &&
+		 ipv6_addr_equal(&rt->rt6i_dst.addr, daddr));
 }
 
 int ip6_fragment(struct sock *sk, struct sk_buff *skb,
@@ -194,9 +197,15 @@ static inline bool ip6_sk_ignore_df(const struct sock *sk)
 	       inet6_sk(sk)->pmtudisc == IPV6_PMTUDISC_OMIT;
 }
 
-static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt)
+static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt,
+					   struct in6_addr *daddr)
 {
-	return &rt->rt6i_gateway;
+	if (rt->rt6i_flags & RTF_GATEWAY)
+		return &rt->rt6i_gateway;
+	else if (rt->rt6i_flags & RTF_CACHE)
+		return &rt->rt6i_dst.addr;
+	else
+		return daddr;
 }
 
 #endif
diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 1742b84..f3d6046 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -192,7 +192,7 @@ static inline struct lowpan_peer *peer_lookup_dst(struct lowpan_dev *dev,
 		if (ipv6_addr_any(nexthop))
 			return NULL;
 	} else {
-		nexthop = rt6_nexthop(rt);
+		nexthop = rt6_nexthop(rt, daddr);
 
 		/* We need to remember the address because it is needed
 		 * by bt_xmit() when sending the packet. In bt_xmit(), the
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 24b359d..713d743 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -337,7 +337,7 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net,
 	 * We won't send icmp if the destination is known
 	 * anycast.
 	 */
-	if (((struct rt6_info *)dst)->rt6i_flags & RTF_ANYCAST) {
+	if (ipv6_anycast_destination(dst, &fl6->daddr)) {
 		net_dbg_ratelimited("icmp6_send: acast source\n");
 		dst_release(dst);
 		return ERR_PTR(-EINVAL);
@@ -564,7 +564,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 
 	if (!ipv6_unicast_destination(skb) &&
 	    !(net->ipv6.sysctl.anycast_src_echo_reply &&
-	      ipv6_anycast_destination(skb)))
+	      ipv6_anycast_destination(skb_dst(skb), saddr)))
 		saddr = NULL;
 
 	memcpy(&tmp_hdr, icmph, sizeof(tmp_hdr));
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b987fbf..e58e402 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -105,7 +105,7 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 	}
 
 	rcu_read_lock_bh();
-	nexthop = rt6_nexthop((struct rt6_info *)dst);
+	nexthop = rt6_nexthop((struct rt6_info *)dst, &ipv6_hdr(skb)->daddr);
 	neigh = __ipv6_neigh_lookup_noref(dst->dev, nexthop);
 	if (unlikely(!neigh))
 		neigh = __neigh_create(&nd_tbl, nexthop, dst->dev, false);
@@ -913,7 +913,8 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 */
 	rt = (struct rt6_info *) *dst;
 	rcu_read_lock_bh();
-	n = __ipv6_neigh_lookup_noref(rt->dst.dev, rt6_nexthop(rt));
+	n = __ipv6_neigh_lookup_noref(rt->dst.dev,
+				      rt6_nexthop(rt, &fl6->daddr));
 	err = n && !(n->nud_state & NUD_VALID) ? -EINVAL : 0;
 	rcu_read_unlock_bh();
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3522711..8efde73 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1936,11 +1936,7 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 		if (rt->rt6i_idev)
 			in6_dev_hold(rt->rt6i_idev);
 		rt->dst.lastuse = jiffies;
-
-		if (ort->rt6i_flags & RTF_GATEWAY)
-			rt->rt6i_gateway = ort->rt6i_gateway;
-		else
-			rt->rt6i_gateway = *dest;
+		rt->rt6i_gateway = ort->rt6i_gateway;
 		rt->rt6i_flags = ort->rt6i_flags;
 		rt6_set_from(rt, ort);
 		rt->rt6i_metric = 0;
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 1d69f5b..9511af0 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -779,8 +779,8 @@ static int callforward_do_filter(struct net *net,
 				   flowi6_to_flowi(&fl1), false)) {
 			if (!afinfo->route(net, (struct dst_entry **)&rt2,
 					   flowi6_to_flowi(&fl2), false)) {
-				if (ipv6_addr_equal(rt6_nexthop(rt1),
-						    rt6_nexthop(rt2)) &&
+				if (ipv6_addr_equal(rt6_nexthop(rt1, &fl1.daddr),
+						    rt6_nexthop(rt2, &fl2.daddr)) &&
 				    rt1->dst.dev == rt2->dst.dev)
 					ret = 1;
 				dst_release(&rt2->dst);
diff --git a/net/netfilter/xt_addrtype.c b/net/netfilter/xt_addrtype.c
index fab6eea..5b4743c 100644
--- a/net/netfilter/xt_addrtype.c
+++ b/net/netfilter/xt_addrtype.c
@@ -73,7 +73,7 @@ static u32 match_lookup_rt6(struct net *net, const struct net_device *dev,
 
 	if (dev == NULL && rt->rt6i_flags & RTF_LOCAL)
 		ret |= XT_ADDRTYPE_LOCAL;
-	if (rt->rt6i_flags & RTF_ANYCAST)
+	if (ipv6_anycast_destination((struct dst_entry *)rt, addr))
 		ret |= XT_ADDRTYPE_ANYCAST;
 
 	dst_release(&rt->dst);
-- 
1.8.1
