From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v3 2/2] net: ethoc: Correctly pad short packets
Date: Tue, 12 Jul 2016 16:04:36 -0700
Message-ID: <1468364676-19242-3-git-send-email-f.fainelli@gmail.com>
References: <1468364676-19242-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jcmvbkbc@gmail.com, colin.king@canonical.com,
	tklauser@distanz.ch, thierry.reding@gmail.com, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [209.85.192.195] ([209.85.192.195]:34204 "EHLO
	mail-pf0-f195.google.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752429AbcGLXFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 19:05:15 -0400
Received: by mail-pf0-f195.google.com with SMTP id g202so1949482pfb.1
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 16:05:15 -0700 (PDT)
In-Reply-To: <1468364676-19242-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even though the hardware can be doing zero padding, we want the SKB to
be going out on the wire with the appropriate size. This fixes packet
truncations observed with e.g: ARP packets.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 06ae14a8e946..4466a1187110 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -860,6 +860,11 @@ static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int entry;
 	void *dest;
 
+	if (skb_put_padto(skb, ETHOC_ZLEN)) {
+		dev->stats.tx_errors++;
+		goto out_no_free;
+	}
+
 	if (unlikely(skb->len > ETHOC_BUFSIZ)) {
 		dev->stats.tx_errors++;
 		goto out;
@@ -894,6 +899,7 @@ static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_tx_timestamp(skb);
 out:
 	dev_kfree_skb(skb);
+out_no_free:
 	return NETDEV_TX_OK;
 }
 
-- 
2.7.4
