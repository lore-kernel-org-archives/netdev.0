From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 07/17] ipv6: Move ip6_nd_hdr() to its users' source
 files.
Date: Tue, 18 Dec 2012 19:54:27 +0900
Message-ID: <50D04B63.5070106@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56615 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754349Ab2LRKy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:54:28 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also makes return type to void since this function
never fails, and uses hoplimit argument instead of pointer
to struct sock.  For ND, it also removes protocol argument.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h    |    7 -------
 net/ipv6/ip6_output.c |   27 ---------------------------
 net/ipv6/mcast.c      |   24 ++++++++++++++++++++++--
 net/ipv6/ndisc.c      |   24 +++++++++++++++++++++---
 4 files changed, 43 insertions(+), 39 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 710bf2b..dcc4b45 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -570,13 +570,6 @@ extern int			ip6_xmit(struct sock *sk,
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
index 8c597b3..bb0c4cc 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -241,33 +241,6 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 
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
-	__ip6_hdr(hdr, 0, 0, proto, np->hop_limit, saddr, daddr);
-	hdr->payload_len = htons(len);
-
-	return 0;
-}
-
 static int ip6_call_ra_chain(struct sk_buff *skb, int sel)
 {
 	struct ip6_ra_chain *ra;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 28dfa5f..7c42776 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1340,6 +1340,24 @@ mld_scount(struct ifmcaddr6 *pmc, int type, int gdeleted, int sdeleted)
 	return scount;
 }
 
+static void ip6_mc_hdr(struct sk_buff *skb, struct net_device *dev,
+		       const struct in6_addr *saddr,
+		       const struct in6_addr *daddr,
+		       int proto, int hoplimit, int len)
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
+	__ip6_hdr(hdr, 0, 0, proto, hoplimit, saddr, daddr);
+	hdr->payload_len = htons(len);
+}
+
 static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 {
 	struct net *net = dev_net(dev);
@@ -1375,7 +1393,8 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 	} else
 		saddr = &addr_buf;
 
-	ip6_nd_hdr(sk, skb, dev, saddr, &mld2_all_mcr, NEXTHDR_HOP, 0);
+	ip6_mc_hdr(skb, dev, saddr, &mld2_all_mcr,
+		   NEXTHDR_HOP, inet6_sk(sk)->hop_limit, 0);
 
 	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
 
@@ -1767,7 +1786,8 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	} else
 		saddr = &addr_buf;
 
-	ip6_nd_hdr(sk, skb, dev, saddr, snd_addr, NEXTHDR_HOP, payload_len);
+	ip6_mc_hdr(skb, dev, saddr, snd_addr, NEXTHDR_HOP,
+		   inet6_sk(sk)->hop_limit, payload_len);
 
 	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 45ce72c..f2942f3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -392,6 +392,24 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 	return skb;
 }
 
+static void ip6_nd_hdr(struct sk_buff *skb, struct net_device *dev,
+		       const struct in6_addr *saddr,
+		       const struct in6_addr *daddr,
+		       int hoplimit, int len)
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
+	__ip6_hdr(hdr, 0, 0, IPPROTO_ICMPV6, hoplimit, saddr, daddr);
+	hdr->payload_len = htons(len);
+}
+
 static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 				       const struct in6_addr *daddr,
 				       const struct in6_addr *saddr,
@@ -417,7 +435,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (!skb)
 		return NULL;
 
-	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
+	ip6_nd_hdr(skb, dev, saddr, daddr, inet6_sk(sk)->hop_limit, len);
 
 	skb->transport_header = skb->tail;
 	skb_put(skb, len);
@@ -1441,8 +1459,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	ip6_nd_hdr(sk, buff, dev, &saddr_buf, &ipv6_hdr(skb)->saddr,
-		   IPPROTO_ICMPV6, len);
+	ip6_nd_hdr(buff, dev, &saddr_buf, &ipv6_hdr(skb)->saddr,
+		   inet6_sk(sk)->hop_limit, len);
 
 	skb_set_transport_header(buff, skb_tail_pointer(buff) - buff->data);
 	skb_put(buff, len);
-- 
1.7.9.5
