From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6]: Do no rely on skb->dst before it is assigned.
Date: Wed, 09 May 2007 19:18:35 +0900 (JST)
Message-ID: <20070509.191835.125516836.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, snakebyte@gmx.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37426 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755453AbXEIKSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 06:18:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because skb->dst is assigned in ip6_route_input(), it is really
bad to use it in hop-by-hop option handler(s).

This fix is also needed for -stable.

Closes: Bug #8450 (Eric Sesterhenn <snakebyte@gmx.de>)
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index fb39604..1e6e67e 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -651,6 +651,14 @@ EXPORT_SYMBOL_GPL(ipv6_invert_rthdr);
   Hop-by-hop options.
  **********************************/
 
+/*
+ * Note: we cannot rely on skb->dst before we assign it in ip6_route_input(). 
+ */
+static inline struct inet6_dev *ipv6_skb_idev(struct sk_buff *skb)
+{
+	return skb->dst ? ip6_dst_idev(skb->dst) : __in6_dev_get(skb->dev);
+}
+
 /* Router Alert as of RFC 2711 */
 
 static int ipv6_hop_ra(struct sk_buff **skbp, int optoff)
@@ -677,25 +685,25 @@ static int ipv6_hop_jumbo(struct sk_buff **skbp, int optoff)
 	if (skb->nh.raw[optoff+1] != 4 || (optoff&3) != 2) {
 		LIMIT_NETDEBUG(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n",
 			       skb->nh.raw[optoff+1]);
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(ipv6_skb_idev(skb),
 				 IPSTATS_MIB_INHDRERRORS);
 		goto drop;
 	}
 
 	pkt_len = ntohl(*(__be32*)(skb->nh.raw+optoff+2));
 	if (pkt_len <= IPV6_MAXPLEN) {
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(ipv6_skb_idev(skb), IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff+2);
 		return 0;
 	}
 	if (skb->nh.ipv6h->payload_len) {
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(ipv6_skb_idev(skb), IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff);
 		return 0;
 	}
 
 	if (pkt_len > skb->len - sizeof(struct ipv6hdr)) {
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INTRUNCATEDPKTS);
+		IP6_INC_STATS_BH(ipv6_skb_idev(skb), IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	}
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
