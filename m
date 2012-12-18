From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 02/17] ipv6: Introduce __ip6_hdr() for setting
 IPv6 header.
Date: Tue, 18 Dec 2012 19:52:46 +0900
Message-ID: <50D04AFE.6030101@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56599 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754393Ab2LRKwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:52:47 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h    |   15 +++++++++++++++
 net/ipv6/ip6_gre.c    |   18 ++++++------------
 net/ipv6/ip6_output.c |   26 +++++---------------------
 net/ipv6/ip6_tunnel.c |   12 +++++-------
 4 files changed, 31 insertions(+), 40 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5af66b2..710bf2b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -622,6 +622,21 @@ extern int			ip6_mc_input(struct sk_buff *skb);
 extern int			__ip6_local_out(struct sk_buff *skb);
 extern int			ip6_local_out(struct sk_buff *skb);
 
+static inline void		__ip6_hdr(struct ipv6hdr *hdr,
+					  unsigned int tclass,
+					  __be32 flowlabel,
+					  unsigned int proto,
+					  unsigned int hoplimit,
+					  const struct in6_addr *saddr,
+					  const struct in6_addr *daddr)
+{
+	*(__be32 *)hdr = htonl(0x60000000 | (tclass << 20)) | flowlabel;
+	hdr->nexthdr = proto;
+	hdr->hop_limit = hoplimit;
+	hdr->saddr = *saddr;
+	hdr->daddr = *daddr;
+}
+
 /*
  *	Extension header (options) processing
  */
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 867466c..d91deaa 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -773,13 +773,10 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	 *	Push down and install the IP header.
 	 */
 	ipv6h = ipv6_hdr(skb);
-	*(__be32 *)ipv6h = fl6->flowlabel | htonl(0x60000000);
-	dsfield = INET_ECN_encapsulate(0, dsfield);
-	ipv6_change_dsfield(ipv6h, ~INET_ECN_MASK, dsfield);
-	ipv6h->hop_limit = tunnel->parms.hop_limit;
-	ipv6h->nexthdr = proto;
-	ipv6h->saddr = fl6->saddr;
-	ipv6h->daddr = fl6->daddr;
+
+	__ip6_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
+		  fl6->flowlabel, proto, tunnel->parms.hop_limit,
+		  &fl6->saddr, &fl6->daddr);
 
 	((__be16 *)(ipv6h + 1))[0] = tunnel->parms.o_flags;
 	((__be16 *)(ipv6h + 1))[1] = (dev->type == ARPHRD_ETHER) ?
@@ -1241,11 +1238,8 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 	struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb_push(skb, t->hlen);
 	__be16 *p = (__be16 *)(ipv6h+1);
 
-	*(__be32 *)ipv6h = t->fl.u.ip6.flowlabel | htonl(0x60000000);
-	ipv6h->hop_limit = t->parms.hop_limit;
-	ipv6h->nexthdr = NEXTHDR_GRE;
-	ipv6h->saddr = t->parms.laddr;
-	ipv6h->daddr = t->parms.raddr;
+	__ip6_hdr(ipv6h, 0, t->fl.u.ip6.flowlabel, NEXTHDR_GRE,
+		  t->parms.hop_limit, &t->parms.laddr, &t->parms.raddr);
 
 	p[0]		= t->parms.o_flags;
 	p[1]		= htons(type);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 5552d13..8c597b3 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -216,14 +216,9 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-	*(__be32 *)hdr = htonl(0x60000000 | (tclass << 20)) | fl6->flowlabel;
-
+	__ip6_hdr(hdr, tclass, fl6->flowlabel, proto, hlimit,
+		  &fl6->saddr, first_hop);
 	hdr->payload_len = htons(seg_len);
-	hdr->nexthdr = proto;
-	hdr->hop_limit = hlimit;
-
-	hdr->saddr = fl6->saddr;
-	hdr->daddr = *first_hop;
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
@@ -267,14 +262,8 @@ int ip6_nd_hdr(struct sock *sk, struct sk_buff *skb, struct net_device *dev,
 	skb_put(skb, sizeof(struct ipv6hdr));
 	hdr = ipv6_hdr(skb);
 
-	*(__be32*)hdr = htonl(0x60000000);
-
+	__ip6_hdr(hdr, 0, 0, proto, np->hop_limit, saddr, daddr);
 	hdr->payload_len = htons(len);
-	hdr->nexthdr = proto;
-	hdr->hop_limit = np->hop_limit;
-
-	hdr->saddr = *saddr;
-	hdr->daddr = *daddr;
 
 	return 0;
 }
@@ -1548,13 +1537,8 @@ int ip6_push_pending_frames(struct sock *sk)
 	skb_reset_network_header(skb);
 	hdr = ipv6_hdr(skb);
 
-	*(__be32*)hdr = fl6->flowlabel |
-		     htonl(0x60000000 | ((int)np->cork.tclass << 20));
-
-	hdr->hop_limit = np->cork.hop_limit;
-	hdr->nexthdr = proto;
-	hdr->saddr = fl6->saddr;
-	hdr->daddr = *final_dst;
+	__ip6_hdr(hdr, np->cork.tclass, fl6->flowlabel, proto,
+		  np->cork.hop_limit, &fl6->saddr, final_dst);
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index a14f28b..28e4bf0 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1030,13 +1030,11 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
-	*(__be32*)ipv6h = fl6->flowlabel | htonl(0x60000000);
-	dsfield = INET_ECN_encapsulate(0, dsfield);
-	ipv6_change_dsfield(ipv6h, ~INET_ECN_MASK, dsfield);
-	ipv6h->hop_limit = t->parms.hop_limit;
-	ipv6h->nexthdr = proto;
-	ipv6h->saddr = fl6->saddr;
-	ipv6h->daddr = fl6->daddr;
+
+	__ip6_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
+		  fl6->flowlabel, proto, t->parms.hop_limit,
+		  &fl6->saddr, &fl6->daddr);
+
 	nf_reset(skb);
 	pkt_len = skb->len;
 	err = ip6_local_out(skb);
-- 
1.7.9.5
