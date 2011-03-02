From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Make icmp route lookup code a bit clearer.
Date: Tue, 01 Mar 2011 22:15:43 -0800 (PST)
Message-ID: <20110301.221543.226770795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55759
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751499Ab1CBGPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 01:15:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The route lookup code in icmpv6_send() is slightly tricky as a result of
having to handle all of the requirements of RFC 4301 host relookups.

Pull the route resolution into a seperate function, so that the error
handling and route reference counting is hopefully easier to see and
contained wholly within this new routine.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/icmp.c |  117 +++++++++++++++++++++++++++++++------------------------
 1 files changed, 66 insertions(+), 51 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index a31d91b..e332bae 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -300,6 +300,70 @@ static void mip6_addr_swap(struct sk_buff *skb)
 static inline void mip6_addr_swap(struct sk_buff *skb) {}
 #endif
 
+static struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *skb,
+					     struct sock *sk, struct flowi *fl)
+{
+	struct dst_entry *dst, *dst2;
+	struct flowi fl2;
+	int err;
+
+	err = ip6_dst_lookup(sk, &dst, fl);
+	if (err)
+		return ERR_PTR(err);
+
+	/*
+	 * We won't send icmp if the destination is known
+	 * anycast.
+	 */
+	if (((struct rt6_info *)dst)->rt6i_flags & RTF_ANYCAST) {
+		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6_send: acast source\n");
+		dst_release(dst);
+		return ERR_PTR(-EINVAL);
+	}
+
+	/* No need to clone since we're just using its address. */
+	dst2 = dst;
+
+	err = xfrm_lookup(net, &dst, fl, sk, 0);
+	switch (err) {
+	case 0:
+		if (dst != dst2)
+			return dst;
+		break;
+	case -EPERM:
+		dst = NULL;
+		break;
+	default:
+		return ERR_PTR(err);
+	}
+
+	err = xfrm_decode_session_reverse(skb, &fl2, AF_INET6);
+	if (err)
+		goto relookup_failed;
+
+	err = ip6_dst_lookup(sk, &dst2, &fl2);
+	if (err)
+		goto relookup_failed;
+
+	err = xfrm_lookup(net, &dst2, &fl2, sk, XFRM_LOOKUP_ICMP);
+	switch (err) {
+	case 0:
+		dst_release(dst);
+		dst = dst2;
+		break;
+	case -EPERM:
+		dst_release(dst);
+		return ERR_PTR(err);
+	default:
+		goto relookup_failed;
+	}
+
+relookup_failed:
+	if (dst)
+		return dst;
+	return ERR_PTR(err);
+}
+
 /*
  *	Send an ICMP message in response to a packet in error
  */
@@ -312,10 +376,8 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	struct ipv6_pinfo *np;
 	struct in6_addr *saddr = NULL;
 	struct dst_entry *dst;
-	struct dst_entry *dst2;
 	struct icmp6hdr tmp_hdr;
 	struct flowi fl;
-	struct flowi fl2;
 	struct icmpv6_msg msg;
 	int iif = 0;
 	int addr_type = 0;
@@ -408,57 +470,10 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
-	if (err)
-		goto out;
-
-	/*
-	 * We won't send icmp if the destination is known
-	 * anycast.
-	 */
-	if (((struct rt6_info *)dst)->rt6i_flags & RTF_ANYCAST) {
-		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6_send: acast source\n");
-		goto out_dst_release;
-	}
-
-	/* No need to clone since we're just using its address. */
-	dst2 = dst;
-
-	err = xfrm_lookup(net, &dst, &fl, sk, 0);
-	switch (err) {
-	case 0:
-		if (dst != dst2)
-			goto route_done;
-		break;
-	case -EPERM:
-		dst = NULL;
-		break;
-	default:
+	dst = icmpv6_route_lookup(net, skb, sk, &fl);
+	if (IS_ERR(dst))
 		goto out;
-	}
-
-	if (xfrm_decode_session_reverse(skb, &fl2, AF_INET6))
-		goto relookup_failed;
-
-	if (ip6_dst_lookup(sk, &dst2, &fl2))
-		goto relookup_failed;
-
-	err = xfrm_lookup(net, &dst2, &fl2, sk, XFRM_LOOKUP_ICMP);
-	switch (err) {
-	case 0:
-		dst_release(dst);
-		dst = dst2;
-		break;
-	case -EPERM:
-		goto out_dst_release;
-	default:
-relookup_failed:
-		if (!dst)
-			goto out;
-		break;
-	}
 
-route_done:
 	if (ipv6_addr_is_multicast(&fl.fl6_dst))
 		hlimit = np->mcast_hops;
 	else
-- 
1.7.4.1

