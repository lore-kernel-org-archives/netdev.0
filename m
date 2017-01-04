From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: systemport: Pad packet before inserting TSB
Date: Tue,  3 Jan 2017 16:34:49 -0800
Message-ID: <20170104003449.27078-3-f.fainelli@gmail.com>
References: <20170104003449.27078-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35303 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762207AbdADAfk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 19:35:40 -0500
Received: by mail-pg0-f65.google.com with SMTP id i5so35093462pgh.2
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 16:35:02 -0800 (PST)
In-Reply-To: <20170104003449.27078-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inserting the TSB means adding an extra 8 bytes in fron the of packet
that is going to be used as metadata information by the TDMA engine, but
stripped off, so it does not really help with the packet padding.

For some odd packet sizes that fall below the 60 bytes payload (e.g: ARP)
we can end-up padding them after the TSB insertion, thus making them 64
bytes, but with the TDMA stripping off the first 8 bytes, they could
still be smaller than 64 bytes which is required to ingress the switch.

Fix this by swapping the padding and TSB insertion, guaranteeing that
the packets have the right sizes.

Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index e67908b5edfe..7e8cf213fd81 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1012,15 +1012,6 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 		goto out;
 	}
 
-	/* Insert TSB and checksum infos */
-	if (priv->tsb_en) {
-		skb = bcm_sysport_insert_tsb(skb, dev);
-		if (!skb) {
-			ret = NETDEV_TX_OK;
-			goto out;
-		}
-	}
-
 	/* The Ethernet switch we are interfaced with needs packets to be at
 	 * least 64 bytes (including FCS) otherwise they will be discarded when
 	 * they enter the switch port logic. When Broadcom tags are enabled, we
@@ -1033,6 +1024,15 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 		goto out;
 	}
 
+	/* Insert TSB and checksum infos */
+	if (priv->tsb_en) {
+		skb = bcm_sysport_insert_tsb(skb, dev);
+		if (!skb) {
+			ret = NETDEV_TX_OK;
+			goto out;
+		}
+	}
+
 	skb_len = skb->len;
 
 	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
-- 
2.9.3
