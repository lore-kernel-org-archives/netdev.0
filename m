From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Make icmp route lookup code a bit clearer.
Date: Tue, 01 Mar 2011 15:48:16 -0800 (PST)
Message-ID: <20110301.154816.212683830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44414
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755155Ab1CAXrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:47:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The route lookup code in icmp_send() is slightly tricky as a result of
having to handle all of the requirements of RFC 4301 host relookups.

Pull the route resolution into a seperate function, so that the error
handling and route reference counting is hopefully easier to see and
contained wholly within this new routine.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/icmp.c |  175 ++++++++++++++++++++++++++++++-------------------------
 1 files changed, 96 insertions(+), 79 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index ad2bcf1..527ffd1 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -369,6 +369,98 @@ out_unlock:
 	icmp_xmit_unlock(sk);
 }
 
+struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
+				 struct iphdr *iph,
+				 __be32 saddr, u8 tos,
+				 int type, int code,
+				 struct icmp_bxm *param)
+{
+	struct flowi fl = {
+		.fl4_dst = (param->replyopts.srr ?
+			    param->replyopts.faddr : iph->saddr),
+		.fl4_src = saddr,
+		.fl4_tos = RT_TOS(tos),
+		.proto = IPPROTO_ICMP,
+		.fl_icmp_type = type,
+		.fl_icmp_code = code,
+	};
+	struct rtable *rt, *rt2;
+	int err;
+
+	security_skb_classify_flow(skb_in, &fl);
+	err = __ip_route_output_key(net, &rt, &fl);
+	if (err)
+		return ERR_PTR(err);
+
+	/* No need to clone since we're just using its address. */
+	rt2 = rt;
+
+	if (!fl.fl4_src)
+		fl.fl4_src = rt->rt_src;
+
+	err = xfrm_lookup(net, (struct dst_entry **)&rt, &fl, NULL, 0);
+	switch (err) {
+	case 0:
+		if (rt != rt2)
+			return rt;
+		break;
+	case -EPERM:
+		rt = NULL;
+		break;
+	default:
+		return ERR_PTR(err);
+	}
+
+	err = xfrm_decode_session_reverse(skb_in, &fl, AF_INET);
+	if (err)
+		goto relookup_failed;
+
+	if (inet_addr_type(net, fl.fl4_src) == RTN_LOCAL) {
+		err = __ip_route_output_key(net, &rt2, &fl);
+	} else {
+		struct flowi fl2 = {};
+		unsigned long orefdst;
+
+		fl2.fl4_dst = fl.fl4_src;
+		err = ip_route_output_key(net, &rt2, &fl2);
+		if (err)
+			goto relookup_failed;
+		/* Ugh! */
+		orefdst = skb_in->_skb_refdst; /* save old refdst */
+		err = ip_route_input(skb_in, fl.fl4_dst, fl.fl4_src,
+				     RT_TOS(tos), rt2->dst.dev);
+
+		dst_release(&rt2->dst);
+		rt2 = skb_rtable(skb_in);
+		skb_in->_skb_refdst = orefdst; /* restore old refdst */
+	}
+
+	if (err)
+		goto relookup_failed;
+
+	err = xfrm_lookup(net, (struct dst_entry **)&rt2, &fl, NULL,
+			  XFRM_LOOKUP_ICMP);
+	switch (err) {
+	case 0:
+		dst_release(&rt->dst);
+		rt = rt2;
+		break;
+	case -EPERM:
+		return ERR_PTR(err);
+	default:
+		if (!rt)
+			return ERR_PTR(err);
+		break;
+	}
+
+
+	return rt;
+
+relookup_failed:
+	if (rt)
+		return rt;
+	return ERR_PTR(err);
+}
 
 /*
  *	Send an ICMP message in response to a situation
@@ -506,86 +598,11 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	ipc.opt = &icmp_param.replyopts;
 	ipc.tx_flags = 0;
 
-	{
-		struct flowi fl = {
-			.fl4_dst = icmp_param.replyopts.srr ?
-				   icmp_param.replyopts.faddr : iph->saddr,
-			.fl4_src = saddr,
-			.fl4_tos = RT_TOS(tos),
-			.proto = IPPROTO_ICMP,
-			.fl_icmp_type = type,
-			.fl_icmp_code = code,
-		};
-		int err;
-		struct rtable *rt2;
-
-		security_skb_classify_flow(skb_in, &fl);
-		if (__ip_route_output_key(net, &rt, &fl))
-			goto out_unlock;
-
-		/* No need to clone since we're just using its address. */
-		rt2 = rt;
-
-		if (!fl.nl_u.ip4_u.saddr)
-			fl.nl_u.ip4_u.saddr = rt->rt_src;
-
-		err = xfrm_lookup(net, (struct dst_entry **)&rt, &fl, NULL, 0);
-		switch (err) {
-		case 0:
-			if (rt != rt2)
-				goto route_done;
-			break;
-		case -EPERM:
-			rt = NULL;
-			break;
-		default:
-			goto out_unlock;
-		}
-
-		if (xfrm_decode_session_reverse(skb_in, &fl, AF_INET))
-			goto relookup_failed;
-
-		if (inet_addr_type(net, fl.fl4_src) == RTN_LOCAL)
-			err = __ip_route_output_key(net, &rt2, &fl);
-		else {
-			struct flowi fl2 = {};
-			unsigned long orefdst;
-
-			fl2.fl4_dst = fl.fl4_src;
-			if (ip_route_output_key(net, &rt2, &fl2))
-				goto relookup_failed;
-
-			/* Ugh! */
-			orefdst = skb_in->_skb_refdst; /* save old refdst */
-			err = ip_route_input(skb_in, fl.fl4_dst, fl.fl4_src,
-					     RT_TOS(tos), rt2->dst.dev);
-
-			dst_release(&rt2->dst);
-			rt2 = skb_rtable(skb_in);
-			skb_in->_skb_refdst = orefdst; /* restore old refdst */
-		}
-
-		if (err)
-			goto relookup_failed;
-
-		err = xfrm_lookup(net, (struct dst_entry **)&rt2, &fl, NULL,
-				  XFRM_LOOKUP_ICMP);
-		switch (err) {
-		case 0:
-			dst_release(&rt->dst);
-			rt = rt2;
-			break;
-		case -EPERM:
-			goto ende;
-		default:
-relookup_failed:
-			if (!rt)
-				goto out_unlock;
-			break;
-		}
-	}
+	rt = icmp_route_lookup(net, skb_in, iph, saddr, tos,
+			       type, code, &icmp_param);
+	if (IS_ERR(rt))
+		goto out_unlock;
 
-route_done:
 	if (!icmpv4_xrlim_allow(net, rt, type, code))
 		goto ende;
 
-- 
1.7.4.1

