From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 1/7] ipv6: Introduce ip6_flow_hdr() to fill version,
 tclass and flowlabel.
Date: Mon, 14 Jan 2013 00:01:39 +0900
Message-ID: <50F2CC53.3050708@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38227 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755061Ab3AMPBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 10:01:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is not only for readability but also for optimization.
What we do here is to build the 32bit word at the beginning of the ipv6
header (the "ip6_flow" virtual member of struct ip6_hdr in RFC3542) and
we do not need to read the tclass portion of the target buffer.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h               |    9 +++++++++
 net/ipv6/ip6_gre.c               |    6 ++----
 net/ipv6/ip6_output.c            |    8 +++-----
 net/ipv6/ip6_tunnel.c            |    4 +---
 net/ipv6/netfilter/ip6t_REJECT.c |    2 +-
 5 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5af66b2..fcbc646 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -547,6 +547,15 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 extern void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
 
 /*
+ *	Header manipulation
+ */
+static inline void ip6_flow_hdr(struct ipv6hdr *hdr, unsigned int tclass,
+				__be32 flowlabel)
+{
+	*(__be32 *)hdr = ntohl(0x60000000 | (tclass << 20)) | flowlabel;
+}
+
+/*
  *	Prototypes exported by ipv6
  */
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index c727e47..db91fe3 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -772,9 +772,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	 *	Push down and install the IP header.
 	 */
 	ipv6h = ipv6_hdr(skb);
-	*(__be32 *)ipv6h = fl6->flowlabel | htonl(0x60000000);
-	dsfield = INET_ECN_encapsulate(0, dsfield);
-	ipv6_change_dsfield(ipv6h, ~INET_ECN_MASK, dsfield);
+	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield), fl6->flowlabel);
 	ipv6h->hop_limit = tunnel->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
@@ -1240,7 +1238,7 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 	struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb_push(skb, t->hlen);
 	__be16 *p = (__be16 *)(ipv6h+1);
 
-	*(__be32 *)ipv6h = t->fl.u.ip6.flowlabel | htonl(0x60000000);
+	ip6_flow_hdr(ipv6h, 0, t->fl.u.ip6.flowlabel);
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = NEXTHDR_GRE;
 	ipv6h->saddr = t->parms.laddr;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 5552d13..9250c69 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -216,7 +216,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-	*(__be32 *)hdr = htonl(0x60000000 | (tclass << 20)) | fl6->flowlabel;
+	ip6_flow_hdr(hdr, tclass, fl6->flowlabel);
 
 	hdr->payload_len = htons(seg_len);
 	hdr->nexthdr = proto;
@@ -267,7 +267,7 @@ int ip6_nd_hdr(struct sock *sk, struct sk_buff *skb, struct net_device *dev,
 	skb_put(skb, sizeof(struct ipv6hdr));
 	hdr = ipv6_hdr(skb);
 
-	*(__be32*)hdr = htonl(0x60000000);
+	ip6_flow_hdr(hdr, 0, 0);
 
 	hdr->payload_len = htons(len);
 	hdr->nexthdr = proto;
@@ -1548,9 +1548,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	skb_reset_network_header(skb);
 	hdr = ipv6_hdr(skb);
 
-	*(__be32*)hdr = fl6->flowlabel |
-		     htonl(0x60000000 | ((int)np->cork.tclass << 20));
-
+	ip6_flow_hdr(hdr, np->cork.tclass, fl6->flowlabel);
 	hdr->hop_limit = np->cork.hop_limit;
 	hdr->nexthdr = proto;
 	hdr->saddr = fl6->saddr;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index a14f28b..fff83cb 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1030,9 +1030,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
-	*(__be32*)ipv6h = fl6->flowlabel | htonl(0x60000000);
-	dsfield = INET_ECN_encapsulate(0, dsfield);
-	ipv6_change_dsfield(ipv6h, ~INET_ECN_MASK, dsfield);
+	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield), fl6->flowlabel);
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index fd4fb34..8e75b6f 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -126,7 +126,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 	skb_put(nskb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(nskb);
 	ip6h = ipv6_hdr(nskb);
-	*(__be32 *)ip6h =  htonl(0x60000000 | (tclass << 20));
+	ip6_flow_hdr(ip6h, tclass, 0);
 	ip6h->hop_limit = ip6_dst_hoplimit(dst);
 	ip6h->nexthdr = IPPROTO_TCP;
 	ip6h->saddr = oip6h->daddr;
-- 
1.7.9.5
