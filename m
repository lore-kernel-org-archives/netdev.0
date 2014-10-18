From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: fix a potential use after free in sit.c
Date: Sat, 18 Oct 2014 17:33:38 +0800
Message-ID: <1413624818-20804-1-git-send-email-roy.qing.li@gmail.com>
Cc: ghorbel@pivasoftware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:53728 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaJRJdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 05:33:43 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so2243066pab.12
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 02:33:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull() maybe change skb->data and make iph pointer oboslete,
fix it by geting ip header length directly.

Fixes: ca15a078 (sit: generate icmpv6 error when receiving icmpv4 error)
Cc: Oussama Ghorbel <ghorbel@pivasoftware.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/sit.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 6eab37c..0ccadab 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -485,11 +485,11 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
  */
 static int ipip6_err_gen_icmpv6_unreach(struct sk_buff *skb)
 {
-	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	int ihl = ((const struct iphdr *)skb->data)->ihl*4;
 	struct rt6_info *rt;
 	struct sk_buff *skb2;
 
-	if (!pskb_may_pull(skb, iph->ihl * 4 + sizeof(struct ipv6hdr) + 8))
+	if (!pskb_may_pull(skb, ihl + sizeof(struct ipv6hdr) + 8))
 		return 1;
 
 	skb2 = skb_clone(skb, GFP_ATOMIC);
@@ -498,7 +498,7 @@ static int ipip6_err_gen_icmpv6_unreach(struct sk_buff *skb)
 		return 1;
 
 	skb_dst_drop(skb2);
-	skb_pull(skb2, iph->ihl * 4);
+	skb_pull(skb2, ihl);
 	skb_reset_network_header(skb2);
 
 	rt = rt6_lookup(dev_net(skb->dev), &ipv6_hdr(skb2)->saddr, NULL, 0, 0);
-- 
1.7.10.4
