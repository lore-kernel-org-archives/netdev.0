From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: [PATCH] econet: failed calls to skb_share_check() and
 pskb_may_pull() are kernel errors, so return NET_RX_BAD
Date: Sat, 20 Jun 2009 19:37:43 +0930
Message-ID: <20090620193743.9d0efe8d.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:40248 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbZFTKHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 06:07:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per the following #define and comment in netdevice.h,

#define NET_RX_BAD              5  /* packet dropped due to kernel error */

return NET_RX_BAD when skb_share_check() or pskb_may_pull() fail in
econet_rcv().

Signed-off-by: Mark Smith <markzzzsmith@yahoo.com.au>


diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 6f479fa..b363ac5 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -1072,10 +1072,12 @@ static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 		goto drop;
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
-		return NET_RX_DROP;
+		return NET_RX_BAD;
 
-	if (!pskb_may_pull(skb, sizeof(struct ec_framehdr)))
-		goto drop;
+	if (!pskb_may_pull(skb, sizeof(struct ec_framehdr))) {
+		kfree_skb(skb);
+		return NET_RX_BAD;
+	}
 
 	hdr = (struct ec_framehdr *) skb->data;
 
