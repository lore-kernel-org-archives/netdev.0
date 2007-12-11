From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/2] [IPSEC]: Add ICMP host relookup support
Date: Wed, 12 Dec 2007 00:55:02 +0800
Message-ID: <E1J28Nq-0004IU-00@gondolin.me.apana.org.au>
References: <20071211165317.GA16420@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2047 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752371AbXLKQzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 11:55:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[IPSEC]: Add ICMP host relookup support

RFC 4301 requires us to relookup ICMP traffic that does not match any
policies using the reverse of its payload.  This patch implements this
for ICMP traffic that originates from or terminates on localhost.

This is activated on outbound with the new policy flag XFRM_POLICY_ICMP,
and on inbound by the new state flag XFRM_STATE_ICMP.

On inbound the policy check is now performed by the ICMP protocol so
that it can repeat the policy check where necessary.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/xfrm.h   |    3 +
 include/net/dst.h      |    1 
 net/ipv4/af_inet.c     |    1 
 net/ipv4/icmp.c        |   82 +++++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/icmp.c        |   60 +++++++++++++++++++++++++++++++++--
 net/xfrm/xfrm_policy.c |   17 ++++++++--
 6 files changed, 154 insertions(+), 10 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index f3819ee..b0c4cc8 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -337,6 +337,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_DECAP_DSCP	2
 #define XFRM_STATE_NOPMTUDISC	4
 #define XFRM_STATE_WILDRECV	8
+#define XFRM_STATE_ICMP		16
 };
 
 struct xfrm_usersa_id {
@@ -371,6 +372,8 @@ struct xfrm_userpolicy_info {
 #define XFRM_POLICY_BLOCK	1
 	__u8				flags;
 #define XFRM_POLICY_LOCALOK	1	/* Allow user to override global policy */
+	/* Automatically expand selector to include matching ICMP payloads. */
+#define XFRM_POLICY_ICMP	2
 	__u8				share;
 };
 
diff --git a/include/net/dst.h b/include/net/dst.h
index aaa2dbb..31468c9 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -268,6 +268,7 @@ extern void		dst_init(void);
 /* Flags for xfrm_lookup flags argument. */
 enum {
 	XFRM_LOOKUP_WAIT = 1 << 0,
+	XFRM_LOOKUP_ICMP = 1 << 1,
 };
 
 struct flowi;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 0e4b6eb..48fc0f8 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1291,6 +1291,7 @@ static struct net_protocol udp_protocol = {
 
 static struct net_protocol icmp_protocol = {
 	.handler =	icmp_rcv,
+	.no_policy =	1,
 };
 
 static int __init init_ipv4_mibs(void)
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index c0898c5..4e3bfcd 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -92,6 +92,7 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 #include <net/checksum.h>
+#include <net/xfrm.h>
 
 /*
  *	Build xmit assembly blocks
@@ -564,11 +565,71 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 				}
 			}
 		};
+		int err;
+		struct rtable *rt2;
+
 		security_skb_classify_flow(skb_in, &fl);
-		if (ip_route_output_key(&rt, &fl))
+		if (__ip_route_output_key(&rt, &fl))
+			goto out_unlock;
+
+		/* No need to clone since we're just using its address. */
+		rt2 = rt;
+
+		err = xfrm_lookup((struct dst_entry **)&rt, &fl, NULL, 0);
+		switch (err) {
+		case 0:
+			if (rt != rt2)
+				goto route_done;
+			break;
+		case -EPERM:
+			rt = NULL;
+			break;
+		default:
+			goto out_unlock;
+		}
+
+		if (xfrm_decode_session_reverse(skb_in, &fl, AF_INET))
+			goto out_unlock;
+
+		if (inet_addr_type(fl.fl4_src) == RTN_LOCAL)
+			err = __ip_route_output_key(&rt2, &fl);
+		else {
+			struct flowi fl2 = {};
+			struct dst_entry *odst;
+
+			fl2.fl4_dst = fl.fl4_src;
+			if (ip_route_output_key(&rt2, &fl2))
+				goto out_unlock;
+
+			/* Ugh! */
+			odst = skb_in->dst;
+			err = ip_route_input(skb_in, fl.fl4_dst, fl.fl4_src,
+					     RT_TOS(tos), rt2->u.dst.dev);
+
+			dst_release(&rt2->u.dst);
+			rt2 = (struct rtable *)skb_in->dst;
+			skb_in->dst = odst;
+		}
+
+		if (err)
+			goto out_unlock;
+
+		err = xfrm_lookup((struct dst_entry **)&rt2, &fl, NULL,
+				  XFRM_LOOKUP_ICMP);
+		if (err == -ENOENT) {
+			if (!rt)
+				goto out_unlock;
+			goto route_done;
+		}
+
+		dst_release(&rt->u.dst);
+		rt = rt2;
+
+		if (err)
 			goto out_unlock;
 	}
 
+route_done:
 	if (!icmpv4_xrlim_allow(rt, type, code))
 		goto ende;
 
@@ -917,6 +978,22 @@ int icmp_rcv(struct sk_buff *skb)
 	struct icmphdr *icmph;
 	struct rtable *rt = (struct rtable *)skb->dst;
 
+	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb) &&
+	    skb->sp->xvec[skb->sp->len - 1]->props.flags & XFRM_STATE_ICMP) {
+		int nh;
+
+		if (!pskb_may_pull(skb, sizeof(*icmph) + sizeof(struct iphdr)))
+			goto drop;
+
+		nh = skb_network_offset(skb);
+		skb_set_network_header(skb, sizeof(*icmph));
+
+		if (!xfrm4_policy_check_reverse(NULL, XFRM_POLICY_IN, skb))
+			goto drop;
+
+		skb_set_network_header(skb, nh);
+	}
+
 	ICMP_INC_STATS_BH(ICMP_MIB_INMSGS);
 
 	switch (skb->ip_summed) {
@@ -930,8 +1007,7 @@ int icmp_rcv(struct sk_buff *skb)
 			goto error;
 	}
 
-	if (!pskb_pull(skb, sizeof(struct icmphdr)))
-		goto error;
+	__skb_pull(skb, sizeof(*icmph));
 
 	icmph = icmp_hdr(skb);
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 4582bbc..478ee77 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -63,6 +63,7 @@
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
 #include <net/icmp.h>
+#include <net/xfrm.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -86,7 +87,7 @@ static int icmpv6_rcv(struct sk_buff *skb);
 
 static struct inet6_protocol icmpv6_protocol = {
 	.handler	=	icmpv6_rcv,
-	.flags		=	INET6_PROTO_FINAL,
+	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
 static __inline__ int icmpv6_xmit_lock(void)
@@ -310,8 +311,10 @@ void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
 	struct ipv6_pinfo *np;
 	struct in6_addr *saddr = NULL;
 	struct dst_entry *dst;
+	struct dst_entry *dst2;
 	struct icmp6hdr tmp_hdr;
 	struct flowi fl;
+	struct flowi fl2;
 	struct icmpv6_msg msg;
 	int iif = 0;
 	int addr_type = 0;
@@ -418,9 +421,42 @@ void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
 		goto out_dst_release;
 	}
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+	/* No need to clone since we're just using its address. */
+	dst2 = dst;
+
+	err = xfrm_lookup(&dst, &fl, sk, 0);
+	switch (err) {
+	case 0:
+		if (dst != dst2)
+			goto route_done;
+		break;
+	case -EPERM:
+		dst = NULL;
+		break;
+	default:
+		goto out;
+	}
+
+	if (xfrm_decode_session_reverse(skb, &fl2, AF_INET6))
+		goto out;
+
+	if (ip6_dst_lookup(sk, &dst2, &fl))
 		goto out;
 
+	err = xfrm_lookup(&dst2, &fl, sk, XFRM_LOOKUP_ICMP);
+	if (err == -ENOENT) {
+		if (!dst)
+			goto out;
+		goto route_done;
+	}
+
+	dst_release(dst);
+	dst = dst2;
+
+	if (err)
+		goto out;
+
+route_done:
 	if (ipv6_addr_is_multicast(&fl.fl6_dst))
 		hlimit = np->mcast_hops;
 	else
@@ -610,6 +646,22 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	struct icmp6hdr *hdr;
 	int type;
 
+	if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb) &&
+	    skb->sp->xvec[skb->sp->len - 1]->props.flags & XFRM_STATE_ICMP) {
+		int nh;
+
+		if (!pskb_may_pull(skb, sizeof(*hdr) + sizeof(*orig_hdr)))
+			goto drop_no_count;
+
+		nh = skb_network_offset(skb);
+		skb_set_network_header(skb, sizeof(*hdr));
+
+		if (!xfrm6_policy_check_reverse(NULL, XFRM_POLICY_IN, skb))
+			goto drop_no_count;
+
+		skb_set_network_header(skb, nh);
+	}
+
 	ICMP6_INC_STATS_BH(idev, ICMP6_MIB_INMSGS);
 
 	saddr = &ipv6_hdr(skb)->saddr;
@@ -632,8 +684,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 		}
 	}
 
-	if (!pskb_pull(skb, sizeof(struct icmp6hdr)))
-		goto discard_it;
+	__skb_pull(skb, sizeof(*hdr));
 
 	hdr = icmp6_hdr(skb);
 
@@ -719,6 +770,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 
 discard_it:
 	ICMP6_INC_STATS_BH(idev, ICMP6_MIB_INERRORS);
+drop_no_count:
 	kfree_skb(skb);
 	return 0;
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 55fd8b7..b04d88c 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1469,11 +1469,13 @@ restart:
 			goto dropdst;
 	}
 
+	err = -ENOENT;
+
 	if (!policy) {
 		/* To accelerate a bit...  */
 		if ((dst_orig->flags & DST_NOXFRM) ||
 		    !xfrm_policy_count[XFRM_POLICY_OUT])
-			return 0;
+			goto nopol;
 
 		policy = flow_cache_lookup(fl, dst_orig->ops->family,
 					   dir, xfrm_policy_lookup);
@@ -1483,14 +1485,18 @@ restart:
 	}
 
 	if (!policy)
-		return 0;
+		goto nopol;
 
 	family = dst_orig->ops->family;
-	policy->curlft.use_time = get_seconds();
 	pols[0] = policy;
 	npols ++;
 	xfrm_nr += pols[0]->xfrm_nr;
 
+	if ((flags & XFRM_LOOKUP_ICMP) && !(policy->flags & XFRM_POLICY_ICMP))
+		goto error;
+
+	policy->curlft.use_time = get_seconds();
+
 	switch (policy->action) {
 	default:
 	case XFRM_POLICY_BLOCK:
@@ -1649,6 +1655,11 @@ dropdst:
 	dst_release(dst_orig);
 	*dst_p = NULL;
 	return err;
+
+nopol:
+	if (flags & XFRM_LOOKUP_ICMP)
+		goto dropdst;
+	return 0;
 }
 EXPORT_SYMBOL(__xfrm_lookup);
 
