From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] ethernet: call __skb_pull() in eth_type_trans()
Date: Mon,  3 May 2010 22:12:52 +0800
Message-ID: <1272895972-13799-1-git-send-email-xiaosuo@gmail.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:44660 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759024Ab0ECONP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 10:13:15 -0400
Received: by pxi5 with SMTP id 5so224379pxi.19
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 07:13:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

call __skb_pull() in eth_type_trans().

The callers of eth_type_trans() should always feed it long enough packets. When
the length of the packet is less than ETH_ZLEN, a warning message will be shown,
and the later behaviors are undefined.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ethernet/eth.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 61ec032..1df31cc 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -162,7 +162,10 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	skb->dev = dev;
 	skb_reset_mac_header(skb);
-	skb_pull_inline(skb, ETH_HLEN);
+	if (unlikely(skb->len < ETH_ZLEN))
+		dev_warn(&dev->dev, "too small ethernet packet: %u bytes\n",
+			 skb->len);
+	__skb_pull(skb, ETH_HLEN);
 	eth = eth_hdr(skb);
 
 	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {
