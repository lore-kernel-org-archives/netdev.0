From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH next v2] nf-nat: don't use per destination incrementing ports in nat random mode
Date: Fri, 20 Dec 2013 01:48:22 +0100
Message-ID: <20131220004822.GC32129@order.stressinduktion.org>
References: <20131219134007.GA24118@order.stressinduktion.org> <52B37F6B.9010105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41327 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753917Ab3LTAsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 19:48:23 -0500
Content-Disposition: inline
In-Reply-To: <52B37F6B.9010105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently use prandom_u32 for allocation of ports in tcp bind(0)
and udp code. In case of plain SNAT we try to keep the ports as is or
increment on collision.

SNAT --random mode does use per-destination incrementing port
allocation. As a recent paper pointed out that this mode of port
allocation makes it possible an attacker to find the randomly
allocated ports. So NF_NAT_RANGE_PROTO_RANDOM actually weakens the port
randomization in regard to the attack in this paper.

You can find details in this paper:
<https://sites.google.com/site/hayashulman/files/NIC-derandomisation.pdf>.

The idea is to send burts of packets to a socket to overflow its receive
queue and measure the latency to detect a possible retransmit when the
port is found. Because of increasing ports to given destination and port
further allocations can be predicted.

So switch NF_NAT_RANGE_PROTO_RANDOM to prandom_u32, too.

Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2:
More verbose changelog as suggested by Daniel.

 include/net/netfilter/nf_nat_l3proto.h   | 2 --
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c | 8 --------
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c | 8 --------
 net/netfilter/nf_nat_proto_common.c      | 4 +---
 4 files changed, 1 insertion(+), 21 deletions(-)

diff --git a/include/net/netfilter/nf_nat_l3proto.h b/include/net/netfilter/nf_nat_l3proto.h
index 5a2919b..e4ed045 100644
--- a/include/net/netfilter/nf_nat_l3proto.h
+++ b/include/net/netfilter/nf_nat_l3proto.h
@@ -8,8 +8,6 @@ struct nf_nat_l3proto {
 	bool	(*in_range)(const struct nf_conntrack_tuple *t,
 			    const struct nf_nat_range *range);
 
-	u32 	(*secure_port)(const struct nf_conntrack_tuple *t, __be16);
-
 	bool	(*manip_pkt)(struct sk_buff *skb,
 			     unsigned int iphdroff,
 			     const struct nf_nat_l4proto *l4proto,
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index d8b2e14..f50d820 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -15,7 +15,6 @@
 #include <linux/icmp.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
-#include <net/secure_seq.h>
 #include <net/checksum.h>
 #include <net/route.h>
 #include <net/ip.h>
@@ -69,12 +68,6 @@ static bool nf_nat_ipv4_in_range(const struct nf_conntrack_tuple *t,
 	       ntohl(t->src.u3.ip) <= ntohl(range->max_addr.ip);
 }
 
-static u32 nf_nat_ipv4_secure_port(const struct nf_conntrack_tuple *t,
-				   __be16 dport)
-{
-	return secure_ipv4_port_ephemeral(t->src.u3.ip, t->dst.u3.ip, dport);
-}
-
 static bool nf_nat_ipv4_manip_pkt(struct sk_buff *skb,
 				  unsigned int iphdroff,
 				  const struct nf_nat_l4proto *l4proto,
@@ -173,7 +166,6 @@ static int nf_nat_ipv4_nlattr_to_range(struct nlattr *tb[],
 static const struct nf_nat_l3proto nf_nat_l3proto_ipv4 = {
 	.l3proto		= NFPROTO_IPV4,
 	.in_range		= nf_nat_ipv4_in_range,
-	.secure_port		= nf_nat_ipv4_secure_port,
 	.manip_pkt		= nf_nat_ipv4_manip_pkt,
 	.csum_update		= nf_nat_ipv4_csum_update,
 	.csum_recalc		= nf_nat_ipv4_csum_recalc,
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index abfe75a..9e5b3a0 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -13,7 +13,6 @@
 #include <linux/ipv6.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
-#include <net/secure_seq.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
 #include <net/ip6_route.h>
@@ -68,12 +67,6 @@ static bool nf_nat_ipv6_in_range(const struct nf_conntrack_tuple *t,
 	       ipv6_addr_cmp(&t->src.u3.in6, &range->max_addr.in6) <= 0;
 }
 
-static u32 nf_nat_ipv6_secure_port(const struct nf_conntrack_tuple *t,
-				   __be16 dport)
-{
-	return secure_ipv6_port_ephemeral(t->src.u3.ip6, t->dst.u3.ip6, dport);
-}
-
 static bool nf_nat_ipv6_manip_pkt(struct sk_buff *skb,
 				  unsigned int iphdroff,
 				  const struct nf_nat_l4proto *l4proto,
@@ -178,7 +171,6 @@ static int nf_nat_ipv6_nlattr_to_range(struct nlattr *tb[],
 
 static const struct nf_nat_l3proto nf_nat_l3proto_ipv6 = {
 	.l3proto		= NFPROTO_IPV6,
-	.secure_port		= nf_nat_ipv6_secure_port,
 	.in_range		= nf_nat_ipv6_in_range,
 	.manip_pkt		= nf_nat_ipv6_manip_pkt,
 	.csum_update		= nf_nat_ipv6_csum_update,
diff --git a/net/netfilter/nf_nat_proto_common.c b/net/netfilter/nf_nat_proto_common.c
index 9baaf73..1d13101 100644
--- a/net/netfilter/nf_nat_proto_common.c
+++ b/net/netfilter/nf_nat_proto_common.c
@@ -75,9 +75,7 @@ void nf_nat_l4proto_unique_tuple(const struct nf_nat_l3proto *l3proto,
 	}
 
 	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM)
-		off = l3proto->secure_port(tuple, maniptype == NF_NAT_MANIP_SRC
-						  ? tuple->dst.u.all
-						  : tuple->src.u.all);
+		off = prandom_u32();
 	else
 		off = *rover;
 
-- 
1.8.3.1
