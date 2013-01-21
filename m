From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 10/19] ndisc: Defer building IPv6 header.
Date: Tue, 22 Jan 2013 01:48:39 +0900
Message-ID: <50FD7167.7030709@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50358 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752140Ab3AUQsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:48:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Build ICMPv6 message first and make buffer management easier;
we can use skb->len when filling checksum in ICMPv6 header,
and then build IP header with length field.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 200b2b2..09171fd 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -387,7 +387,7 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
 
-	skb_reserve(skb, hlen);
+	skb_reserve(skb, hlen + sizeof(struct ipv6hdr));
 
 	return skb;
 }
@@ -399,8 +399,8 @@ static void ip6_nd_hdr(struct sk_buff *skb,
 {
 	struct ipv6hdr *hdr;
 
+	skb_push(skb, sizeof(*hdr));
 	skb_reset_network_header(skb);
-	skb_put(skb, sizeof(struct ipv6hdr));
 	hdr = ipv6_hdr(skb);
 
 	ip6_flow_hdr(hdr, 0, 0);
@@ -438,8 +438,6 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (!skb)
 		return NULL;
 
-	ip6_nd_hdr(skb, saddr, daddr, inet6_sk(sk)->hop_limit, len);
-
 	skb->transport_header = skb->tail;
 	skb_put(skb, len);
 
@@ -455,10 +453,12 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (llinfo)
 		ndisc_fill_addr_option(opt, llinfo, dev->dev_addr, dev);
 
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
@@ -1479,9 +1479,6 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	ip6_nd_hdr(buff, &saddr_buf, &ipv6_hdr(skb)->saddr,
-		   inet6_sk(sk)->hop_limit, len);
-
 	skb_set_transport_header(buff, skb_tail_pointer(buff) - buff->data);
 	skb_put(buff, len);
 	msg = (struct rd_msg *)icmp6_hdr(buff);
@@ -1513,8 +1510,11 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 		opt = ndisc_fill_redirect_hdr_option(opt, skb, rd_len);
 
 	msg->icmph.icmp6_cksum = csum_ipv6_magic(&saddr_buf, &ipv6_hdr(skb)->saddr,
-						 len, IPPROTO_ICMPV6,
-						 csum_partial(msg, len, 0));
+						 buff->len, IPPROTO_ICMPV6,
+						 csum_partial(msg, buff->len, 0));
+
+	ip6_nd_hdr(buff, &saddr_buf, &ipv6_hdr(skb)->saddr,
+		   inet6_sk(sk)->hop_limit, buff->len);
 
 	skb_dst_set(buff, dst);
 	rcu_read_lock();
-- 
1.7.9.5
