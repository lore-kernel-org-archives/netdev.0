From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 2/2] net: ethoc: Correctly pad short packets
Date: Mon, 11 Jul 2016 16:35:55 -0700
Message-ID: <1468280155-13152-3-git-send-email-f.fainelli@gmail.com>
References: <1468280155-13152-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jcmvbkbc@gmail.com, colin.king@canonical.com,
	tklauser@distanz.ch, thierry.reding@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32776 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbcGKXgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 19:36:03 -0400
Received: by mail-pf0-f195.google.com with SMTP id c74so14230324pfb.0
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 16:36:02 -0700 (PDT)
In-Reply-To: <1468280155-13152-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even though the hardware can be doing zero padding, we want the SKB to
be going out on the wire with the appropriate size. This fixes packet
truncations observed with e.g: ARP packets.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 06ae14a8e946..ca678d46c322 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -860,6 +860,11 @@ static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int entry;
 	void *dest;
 
+	if (skb_put_padto(skb, ETHOC_ZLEN)) {
+		dev->stats.tx_errors++;
+		goto out;
+	}
+
 	if (unlikely(skb->len > ETHOC_BUFSIZ)) {
 		dev->stats.tx_errors++;
 		goto out;
-- 
2.7.4
