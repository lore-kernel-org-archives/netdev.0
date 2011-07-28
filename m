From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: avoid a dst_entry refcount change in
 ipv6_destopt_rcv()
Date: Thu, 28 Jul 2011 16:00:35 +0200
Message-ID: <1311861635.2346.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49629 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755264Ab1G1OAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 10:00:43 -0400
Received: by mail-wy0-f174.google.com with SMTP id 8so139467wyg.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 07:00:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_destopt_rcv() runs with rcu_read_lock(), so there is no need to
take a temporay reference on dst_entry, even if skb is freed by
ip6_parse_tlv()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/exthdrs.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 79a485e..1318de4 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -273,12 +273,12 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	__u16 dstbuf;
 #endif
-	struct dst_entry *dst;
+	struct dst_entry *dst = skb_dst(skb);
 
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
-		IP6_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(skb)),
+		IP6_INC_STATS_BH(dev_net(dst->dev), ip6_dst_idev(dst),
 				 IPSTATS_MIB_INHDRERRORS);
 		kfree_skb(skb);
 		return -1;
@@ -289,9 +289,7 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 	dstbuf = opt->dst1;
 #endif
 
-	dst = dst_clone(skb_dst(skb));
 	if (ip6_parse_tlv(tlvprocdestopt_lst, skb)) {
-		dst_release(dst);
 		skb->transport_header += (skb_transport_header(skb)[1] + 1) << 3;
 		opt = IP6CB(skb);
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
@@ -304,7 +302,6 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 
 	IP6_INC_STATS_BH(dev_net(dst->dev),
 			 ip6_dst_idev(dst), IPSTATS_MIB_INHDRERRORS);
-	dst_release(dst);
 	return -1;
 }
 


