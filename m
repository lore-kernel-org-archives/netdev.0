From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 13/17] ndisc: Calculate checksum and build IPv6
 header in __ndisc_send().
Date: Tue, 18 Dec 2012 19:56:03 +0900
Message-ID: <50D04BC3.9070404@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56636 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754700Ab2LRK4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:56:04 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   32 +++++++++++++-------------------
 1 file changed, 13 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 5458aed..c0937d3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -417,8 +417,6 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 				       const struct in6_addr *target,
 				       int llinfo)
 {
-	struct net *net = dev_net(dev);
-	struct sock *sk = net->ipv6.ndisc_sk;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
 	int len;
@@ -450,19 +448,15 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (llinfo)
 		ndisc_fill_addr_option(skb, llinfo, dev->dev_addr);
 
-	hdr->icmp6_cksum = csum_ipv6_magic(saddr, daddr, skb->len,
-					   IPPROTO_ICMPV6,
-					   csum_partial(hdr,
-							skb->len, 0));
-
-	ip6_nd_hdr(skb, saddr, daddr, inet6_sk(sk)->hop_limit, skb->len);
-
 	return skb;
 }
 
-static void __ndisc_send(struct sk_buff *skb, struct dst_entry *dst)
+static void __ndisc_send(struct sk_buff *skb, struct dst_entry *dst,
+			 const struct in6_addr *daddr,
+			 const struct in6_addr *saddr)
 {
 	struct net *net = dev_net(dst->dev);
+	struct sock *sk = net->ipv6.ndisc_sk;
 	struct inet6_dev *idev;
 	struct icmp6hdr *icmp6h = icmp6_hdr(skb);
 	u8 type = icmp6h->icmp6_type;
@@ -470,6 +464,13 @@ static void __ndisc_send(struct sk_buff *skb, struct dst_entry *dst)
 
 	skb_dst_set(skb, dst);
 
+	icmp6h->icmp6_cksum = csum_ipv6_magic(saddr, daddr,
+					      skb->len, IPPROTO_ICMPV6,
+					      csum_partial(icmp6h, skb->len, 0));
+
+	ip6_nd_hdr(skb, saddr, daddr,
+		   inet6_sk(sk)->hop_limit, skb->len);
+
 	rcu_read_lock();
 	idev = __in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
@@ -512,7 +513,7 @@ static void ndisc_send(struct net_device *dev,
 		return;
 	}
 
-	__ndisc_send(skb, dst);
+	__ndisc_send(skb, dst, daddr, saddr);
 }
 
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
@@ -1486,14 +1487,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (rd_len)
 		ndisc_fill_redirect_hdr_option(buff, skb, rd_len);
 
-	msg->icmph.icmp6_cksum = csum_ipv6_magic(&saddr_buf, &ipv6_hdr(skb)->saddr,
-						 buff->len, IPPROTO_ICMPV6,
-						 csum_partial(msg, buff->len, 0));
-
-	ip6_nd_hdr(buff, &saddr_buf, &ipv6_hdr(skb)->saddr,
-		   inet6_sk(sk)->hop_limit, buff->len);
-
-	__ndisc_send(buff, dst);
+	__ndisc_send(buff, dst, &ipv6_hdr(skb)->saddr, &saddr_buf);
 	return;
 
 release:
-- 
1.7.9.5
