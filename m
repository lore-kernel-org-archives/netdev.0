From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: l2tp_eth: fix l2tp_eth_dev_xmit race
Date: Mon, 25 Jun 2012 12:45:14 +0200
Message-ID: <1340621114.10893.29.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	James Chapman <jchapman@katalix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57156 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600Ab2FYKpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 06:45:21 -0400
Received: by bkcji2 with SMTP id ji2so2970370bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 03:45:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Its illegal to dereference skb after giving it to l2tp_xmit_skb()
as it might be already freed/reused.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: James Chapman <jchapman@katalix.com>
---
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 185f12f..c3738f4 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -88,12 +88,12 @@ static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct l2tp_eth *priv = netdev_priv(dev);
 	struct l2tp_session *session = priv->session;
 
-	l2tp_xmit_skb(session, skb, session->hdr_len);
-
 	dev->stats.tx_bytes += skb->len;
 	dev->stats.tx_packets++;
 
-	return 0;
+	l2tp_xmit_skb(session, skb, session->hdr_len);
+
+	return NETDEV_TX_OK;
 }
 
 static struct net_device_ops l2tp_eth_netdev_ops = {
