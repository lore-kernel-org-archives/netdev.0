From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bcmgenet: correctly pad short packets
Date: Tue, 22 Jul 2014 11:01:52 -0700
Message-ID: <1406052112-19958-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:48080 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbaGVSCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 14:02:23 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so7431pad.36
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 11:02:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packets shorter than ETH_ZLEN were not padded with zeroes, hence leaking
potentially sensitive information. This bug has been present since the
driver got accepted in commit 1c1008c793fa46703a2fee469f4235e1c7984333
("net: bcmgenet: add main driver file").

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 16281ad2da12..4e615debe472 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1149,6 +1149,11 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 	}
 
+	if (skb_padto(skb, ETH_ZLEN)) {
+		ret = NETDEV_TX_OK;
+		goto out;
+	}
+
 	/* set the SKB transmit checksum */
 	if (priv->desc_64b_en) {
 		ret = bcmgenet_put_tx_csum(dev, skb);
-- 
1.9.1
