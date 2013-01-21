From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 16/19] ndisc: Fill in ICMPv6 checksum and IPv6 header
 in ndisc_send_skb().
Date: Tue, 22 Jan 2013 01:49:08 +0900
Message-ID: <50FD7184.2020107@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50377 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752592Ab3AUQtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:49:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 437781c..dda4add 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -420,8 +420,6 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 				       const struct in6_addr *target,
 				       int llinfo)
 {
-	struct net *net = dev_net(dev);
-	struct sock *sk = net->ipv6.ndisc_sk;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
 	int len;
@@ -453,13 +451,6 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
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
 
@@ -469,6 +460,7 @@ static void ndisc_send_skb(struct sk_buff *skb,
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct net *net = dev_net(skb->dev);
+	struct sock *sk = net->ipv6.ndisc_sk;
 	struct inet6_dev *idev;
 	int err;
 	struct icmp6hdr *icmp6h = icmp6_hdr(skb);
@@ -490,6 +482,13 @@ static void ndisc_send_skb(struct sk_buff *skb,
 		skb_dst_set(skb, dst);
 	}
 
+	icmp6h->icmp6_cksum = csum_ipv6_magic(saddr, daddr, skb->len,
+					      IPPROTO_ICMPV6,
+					      csum_partial(icmp6h,
+							   skb->len, 0));
+
+	ip6_nd_hdr(skb, saddr, daddr, inet6_sk(sk)->hop_limit, skb->len);
+
 	rcu_read_lock();
 	idev = __in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
@@ -1508,13 +1507,6 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (rd_len)
 		ndisc_fill_redirect_hdr_option(buff, skb, rd_len);
 
-	msg->icmph.icmp6_cksum = csum_ipv6_magic(&saddr_buf, &ipv6_hdr(skb)->saddr,
-						 buff->len, IPPROTO_ICMPV6,
-						 csum_partial(msg, buff->len, 0));
-
-	ip6_nd_hdr(buff, &saddr_buf, &ipv6_hdr(skb)->saddr,
-		   inet6_sk(sk)->hop_limit, buff->len);
-
 	skb_dst_set(buff, dst);
 	ndisc_send_skb(buff, &ipv6_hdr(skb)->saddr, &saddr_buf);
 	return;
-- 
1.7.9.5
