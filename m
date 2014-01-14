From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] eth_type_trans() can access stale data
Date: Tue, 14 Jan 2014 15:52:21 -0800
Message-ID: <1389743541.31367.279.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f45.google.com ([209.85.213.45]:61111 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaANXw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 18:52:26 -0500
Received: by mail-yh0-f45.google.com with SMTP id i72so336090yha.32
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 15:52:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following code :

if (unlikely(skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF))
	return htons(ETH_P_802_3);

expects the additional bytes are in skb->head

I do not think all eth_type_trans() are ready for a pskb_may_pull()
(I am too lazy to perform a whole check)

Would following workaround be OK ?

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 8f032bae60ad..d95403098f09 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -194,7 +194,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
 	 *      won't work for fault tolerant netware but does for the rest.
 	 */
-	if (unlikely(skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF))
+	if (unlikely(skb_headlen(skb) >= 2 &&
+		     *(unsigned short *)(skb->data) == 0xFFFF))
 		return htons(ETH_P_802_3);
 
 	/*
