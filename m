From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] irda: fix a race in irlan_eth_xmit()
Date: Wed, 18 Aug 2010 12:24:43 +0200
Message-ID: <1282127083.2194.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41041 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902Ab0HRKYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 06:24:47 -0400
Received: by wyb32 with SMTP id 32so607871wyb.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 03:24:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After skb is queued, its illegal to dereference it.

Cache skb->len into a temporary variable.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/irda/irlan/irlan_eth.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index 9616c32..5bb8353 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -169,6 +169,7 @@ static netdev_tx_t irlan_eth_xmit(struct sk_buff *skb,
 {
 	struct irlan_cb *self = netdev_priv(dev);
 	int ret;
+	unsigned int len;
 
 	/* skb headroom large enough to contain all IrDA-headers? */
 	if ((skb_headroom(skb) < self->max_header_size) || (skb_shared(skb))) {
@@ -188,6 +189,7 @@ static netdev_tx_t irlan_eth_xmit(struct sk_buff *skb,
 
 	dev->trans_start = jiffies;
 
+	len = skb->len;
 	/* Now queue the packet in the transport layer */
 	if (self->use_udata)
 		ret = irttp_udata_request(self->tsap_data, skb);
@@ -209,7 +211,7 @@ static netdev_tx_t irlan_eth_xmit(struct sk_buff *skb,
 		self->stats.tx_dropped++;
 	} else {
 		self->stats.tx_packets++;
-		self->stats.tx_bytes += skb->len;
+		self->stats.tx_bytes += len;
 	}
 
 	return NETDEV_TX_OK;


