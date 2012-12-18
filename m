From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 09/17] ndisc: Defer building IPv6 header.
Date: Tue, 18 Dec 2012 19:54:50 +0900
Message-ID: <50D04B7A.1050807@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56622 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754686Ab2LRKyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:54:51 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fill out IPv6 header just before sending ND message.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b32f079..2ebb2fb 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -391,7 +391,7 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
 
-	skb_reserve(skb, hlen);
+	skb_reserve(skb, hlen + sizeof(struct ipv6hdr));
 	return skb;
 }
 
@@ -400,8 +400,8 @@ static void ip6_nd_hdr(struct sk_buff *skb, const struct in6_addr *saddr,
 {
 	struct ipv6hdr *hdr;
 
+	__skb_push(skb, sizeof(*hdr));
 	skb_reset_network_header(skb);
-	skb_put(skb, sizeof(struct ipv6hdr));
 	hdr = ipv6_hdr(skb);
 
 	__ip6_hdr(hdr, 0, 0, IPPROTO_ICMPV6, hoplimit, saddr, daddr);
@@ -433,8 +433,6 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (!skb)
 		return NULL;
 
-	ip6_nd_hdr(skb, saddr, daddr, inet6_sk(sk)->hop_limit, len);
-
 	skb->transport_header = skb->tail;
 	skb_put(skb, len);
 
@@ -451,10 +449,12 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 		ndisc_fill_addr_option(opt, llinfo, dev->dev_addr,
 				       dev->addr_len, dev->type);
 
-	hdr->icmp6_cksum = csum_ipv6_magic(saddr, daddr, len,
+	hdr->icmp6_cksum = csum_ipv6_magic(saddr, daddr, skb->len,
 					   IPPROTO_ICMPV6,
 					   csum_partial(hdr,
-							len, 0));
+							skb->len, 0));
+
+	ip6_nd_hdr(skb, saddr, daddr, inet6_sk(sk)->hop_limit, skb->len);
 
 	return skb;
 }
@@ -1457,9 +1457,6 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	ip6_nd_hdr(buff, &saddr_buf, &ipv6_hdr(skb)->saddr,
-		   inet6_sk(sk)->hop_limit, len);
-
 	skb_set_transport_header(buff, skb_tail_pointer(buff) - buff->data);
 	skb_put(buff, len);
 	msg = (struct red_msg *)icmp6_hdr(buff);
@@ -1492,8 +1489,11 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 		opt = ndisc_fill_redirect_hdr_option(opt, skb, rd_len);
 
 	msg->icmph.icmp6_cksum = csum_ipv6_magic(&saddr_buf, &ipv6_hdr(skb)->saddr,
-						 len, IPPROTO_ICMPV6,
-						 csum_partial(msg, len, 0));
+						 buff->len, IPPROTO_ICMPV6,
+						 csum_partial(msg, buff->len, 0));
+
+	ip6_nd_hdr(buff, &saddr_buf, &ipv6_hdr(skb)->saddr,
+		   inet6_sk(sk)->hop_limit, buff->len);
 
 	__ndisc_send(buff, dst);
 	return;
-- 
1.7.9.5
