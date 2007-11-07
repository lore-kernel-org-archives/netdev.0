From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/24] [NET]: Eliminate duplicate copies of dst_discard
Date: Wed, 07 Nov 2007 22:08:20 +0800
Message-ID: <E1IplZs-0001GK-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3523 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757932AbXKGOIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Eliminate duplicate copies of dst_discard

We have a number of copies of dst_discard scattered around the place which
all do the same thing, namely free a packet on the input or output paths.

This patch deletes all of them except dst_discard and points all the users
to it.

The only non-trivial bit is decnet where it returns an error.  However,
conceptually this is identical to the blackhole functions used in IPv4
and IPv6 which do not return errors.  So they should either all return
errors or all return zero.  For now I've stuck with the majority and
picked zero as the return value.

It doesn't really matter in practice since few if any driver would react
differently depending on a zero return value or NET_RX_DROP.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/dst.h     |    1 +
 net/core/dst.c        |    3 ++-
 net/decnet/dn_route.c |   13 +------------
 net/ipv4/route.c      |   11 +++--------
 net/ipv6/exthdrs.c    |   13 ++-----------
 net/ipv6/route.c      |   21 ++++-----------------
 6 files changed, 13 insertions(+), 49 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 8f88c52..4df103b 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -172,6 +172,7 @@ static inline struct dst_entry *dst_pop(struct dst_entry *dst)
 	return child;
 }
 
+extern int dst_discard(struct sk_buff *skb);
 extern void * dst_alloc(struct dst_ops * ops);
 extern void __dst_free(struct dst_entry * dst);
 extern struct dst_entry *dst_destroy(struct dst_entry * dst);
diff --git a/net/core/dst.c b/net/core/dst.c
index 16958e6..21b1d0f 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -154,11 +154,12 @@ loop:
 #endif
 }
 
-static int dst_discard(struct sk_buff *skb)
+int dst_discard(struct sk_buff *skb)
 {
 	kfree_skb(skb);
 	return 0;
 }
+EXPORT_SYMBOL(dst_discard);
 
 void * dst_alloc(struct dst_ops * ops)
 {
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 97eee5e..e1f6669 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -769,17 +769,6 @@ drop:
 }
 
 /*
- * Drop packet. This is used for endnodes and for
- * when we should not be forwarding packets from
- * this dest.
- */
-static int dn_blackhole(struct sk_buff *skb)
-{
-	kfree_skb(skb);
-	return NET_RX_DROP;
-}
-
-/*
  * Used to catch bugs. This should never normally get
  * called.
  */
@@ -1402,7 +1391,7 @@ make_route:
 		default:
 		case RTN_UNREACHABLE:
 		case RTN_BLACKHOLE:
-			rt->u.dst.input = dn_blackhole;
+			rt->u.dst.input = dst_discard;
 	}
 	rt->rt_flags = flags;
 	if (rt->u.dst.dev)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 21b12de..d5cbcee 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -92,6 +92,7 @@
 #include <linux/jhash.h>
 #include <linux/rcupdate.h>
 #include <linux/times.h>
+#include <net/dst.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
 #include <net/ip.h>
@@ -2362,12 +2363,6 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 };
 
 
-static int ipv4_blackhole_output(struct sk_buff *skb)
-{
-	kfree_skb(skb);
-	return 0;
-}
-
 static int ipv4_dst_blackhole(struct rtable **rp, struct flowi *flp, struct sock *sk)
 {
 	struct rtable *ort = *rp;
@@ -2379,8 +2374,8 @@ static int ipv4_dst_blackhole(struct rtable **rp, struct flowi *flp, struct sock
 
 		atomic_set(&new->__refcnt, 1);
 		new->__use = 1;
-		new->input = ipv4_blackhole_output;
-		new->output = ipv4_blackhole_output;
+		new->input = dst_discard;
+		new->output = dst_discard;
 		memcpy(new->metrics, ort->u.dst.metrics, RTAX_MAX*sizeof(u32));
 
 		new->dev = ort->u.dst.dev;
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 1e89efd..cee06b1 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -32,6 +32,7 @@
 #include <linux/in6.h>
 #include <linux/icmpv6.h>
 
+#include <net/dst.h>
 #include <net/sock.h>
 #include <net/snmp.h>
 
@@ -318,18 +319,8 @@ void __init ipv6_destopt_init(void)
 		printk(KERN_ERR "ipv6_destopt_init: Could not register protocol\n");
 }
 
-/********************************
-  NONE header. No data in packet.
- ********************************/
-
-static int ipv6_nodata_rcv(struct sk_buff *skb)
-{
-	kfree_skb(skb);
-	return 0;
-}
-
 static struct inet6_protocol nodata_protocol = {
-	.handler	=	ipv6_nodata_rcv,
+	.handler	=	dst_discard,
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 95f8e4a..7db3cdf 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -156,7 +156,6 @@ struct rt6_info ip6_null_entry = {
 
 static int ip6_pkt_prohibit(struct sk_buff *skb);
 static int ip6_pkt_prohibit_out(struct sk_buff *skb);
-static int ip6_pkt_blk_hole(struct sk_buff *skb);
 
 struct rt6_info ip6_prohibit_entry = {
 	.u = {
@@ -185,8 +184,8 @@ struct rt6_info ip6_blk_hole_entry = {
 			.obsolete	= -1,
 			.error		= -EINVAL,
 			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
-			.input		= ip6_pkt_blk_hole,
-			.output		= ip6_pkt_blk_hole,
+			.input		= dst_discard,
+			.output		= dst_discard,
 			.ops		= &ip6_dst_ops,
 			.path		= (struct dst_entry*)&ip6_blk_hole_entry,
 		}
@@ -785,12 +784,6 @@ struct dst_entry * ip6_route_output(struct sock *sk, struct flowi *fl)
 
 EXPORT_SYMBOL(ip6_route_output);
 
-static int ip6_blackhole_output(struct sk_buff *skb)
-{
-	kfree_skb(skb);
-	return 0;
-}
-
 int ip6_dst_blackhole(struct sock *sk, struct dst_entry **dstp, struct flowi *fl)
 {
 	struct rt6_info *ort = (struct rt6_info *) *dstp;
@@ -803,8 +796,8 @@ int ip6_dst_blackhole(struct sock *sk, struct dst_entry **dstp, struct flowi *fl
 
 		atomic_set(&new->__refcnt, 1);
 		new->__use = 1;
-		new->input = ip6_blackhole_output;
-		new->output = ip6_blackhole_output;
+		new->input = dst_discard;
+		new->output = dst_discard;
 
 		memcpy(new->metrics, ort->u.dst.metrics, RTAX_MAX*sizeof(u32));
 		new->dev = ort->u.dst.dev;
@@ -1814,12 +1807,6 @@ static int ip6_pkt_prohibit_out(struct sk_buff *skb)
 	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED, IPSTATS_MIB_OUTNOROUTES);
 }
 
-static int ip6_pkt_blk_hole(struct sk_buff *skb)
-{
-	kfree_skb(skb);
-	return 0;
-}
-
 #endif
 
 /*
