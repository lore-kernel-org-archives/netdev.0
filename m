From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 06/19] ipv6: Unshare ip6_nd_hdr() and change return
 type to void.
Date: Tue, 22 Jan 2013 01:48:19 +0900
Message-ID: <50FD7153.8060808@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50346 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752838Ab3AUQsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:48:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- move ip6_nd_hdr() to its users' source files.
  In net/ipv6/mcast.c, it will be called ip6_mc_hdr().
- make return type to void since this function never fails.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h    |    7 -------
 net/ipv6/ip6_output.c |   33 ---------------------------------
 net/ipv6/mcast.c      |   29 +++++++++++++++++++++++++++--
 net/ipv6/ndisc.c      |   25 +++++++++++++++++++++++++
 4 files changed, 52 insertions(+), 42 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 464c6f7..c1878f7 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -661,13 +661,6 @@ extern int			ip6_xmit(struct sock *sk,
 					 struct ipv6_txoptions *opt,
 					 int tclass);
 
-extern int			ip6_nd_hdr(struct sock *sk,
-					   struct sk_buff *skb,
-					   struct net_device *dev,
-					   const struct in6_addr *saddr,
-					   const struct in6_addr *daddr,
-					   int proto, int len);
-
 extern int			ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr);
 
 extern int			ip6_append_data(struct sock *sk,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b0895f5..7eee94c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -254,39 +254,6 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 
 EXPORT_SYMBOL(ip6_xmit);
 
-/*
- *	To avoid extra problems ND packets are send through this
- *	routine. It's code duplication but I really want to avoid
- *	extra checks since ipv6_build_header is used by TCP (which
- *	is for us performance critical)
- */
-
-int ip6_nd_hdr(struct sock *sk, struct sk_buff *skb, struct net_device *dev,
-	       const struct in6_addr *saddr, const struct in6_addr *daddr,
-	       int proto, int len)
-{
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct ipv6hdr *hdr;
-
-	skb->protocol = htons(ETH_P_IPV6);
-	skb->dev = dev;
-
-	skb_reset_network_header(skb);
-	skb_put(skb, sizeof(struct ipv6hdr));
-	hdr = ipv6_hdr(skb);
-
-	ip6_flow_hdr(hdr, 0, 0);
-
-	hdr->payload_len = htons(len);
-	hdr->nexthdr = proto;
-	hdr->hop_limit = np->hop_limit;
-
-	hdr->saddr = *saddr;
-	hdr->daddr = *daddr;
-
-	return 0;
-}
-
 static int ip6_call_ra_chain(struct sk_buff *skb, int sel)
 {
 	struct ip6_ra_chain *ra;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 587a845..f25002a 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1313,6 +1313,31 @@ mld_scount(struct ifmcaddr6 *pmc, int type, int gdeleted, int sdeleted)
 	return scount;
 }
 
+static void ip6_mc_hdr(struct sock *sk, struct sk_buff *skb,
+		       struct net_device *dev,
+		       const struct in6_addr *saddr,
+		       const struct in6_addr *daddr,
+		       int proto, int len)
+{
+	struct ipv6hdr *hdr;
+
+	skb->protocol = htons(ETH_P_IPV6);
+	skb->dev = dev;
+
+	skb_reset_network_header(skb);
+	skb_put(skb, sizeof(struct ipv6hdr));
+	hdr = ipv6_hdr(skb);
+
+	ip6_flow_hdr(hdr, 0, 0);
+
+	hdr->payload_len = htons(len);
+	hdr->nexthdr = proto;
+	hdr->hop_limit = inet6_sk(sk)->hop_limit;
+
+	hdr->saddr = *saddr;
+	hdr->daddr = *daddr;
+}
+
 static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 {
 	struct net *net = dev_net(dev);
@@ -1348,7 +1373,7 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 	} else
 		saddr = &addr_buf;
 
-	ip6_nd_hdr(sk, skb, dev, saddr, &mld2_all_mcr, NEXTHDR_HOP, 0);
+	ip6_mc_hdr(sk, skb, dev, saddr, &mld2_all_mcr, NEXTHDR_HOP, 0);
 
 	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
 
@@ -1740,7 +1765,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	} else
 		saddr = &addr_buf;
 
-	ip6_nd_hdr(sk, skb, dev, saddr, snd_addr, NEXTHDR_HOP, payload_len);
+	ip6_mc_hdr(sk, skb, dev, saddr, snd_addr, NEXTHDR_HOP, payload_len);
 
 	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 1776a0d..7ce266f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -389,6 +389,31 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 	return skb;
 }
 
+static void ip6_nd_hdr(struct sock *sk,
+		       struct sk_buff *skb, struct net_device *dev,
+		       const struct in6_addr *saddr,
+		       const struct in6_addr *daddr,
+		       int proto, int len)
+{
+	struct ipv6hdr *hdr;
+
+	skb->protocol = htons(ETH_P_IPV6);
+	skb->dev = dev;
+
+	skb_reset_network_header(skb);
+	skb_put(skb, sizeof(struct ipv6hdr));
+	hdr = ipv6_hdr(skb);
+
+	ip6_flow_hdr(hdr, 0, 0);
+
+	hdr->payload_len = htons(len);
+	hdr->nexthdr = proto;
+	hdr->hop_limit = inet6_sk(sk)->hop_limit;
+
+	hdr->saddr = *saddr;
+	hdr->daddr = *daddr;
+}
+
 static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 				       const struct in6_addr *daddr,
 				       const struct in6_addr *saddr,
-- 
1.7.9.5
