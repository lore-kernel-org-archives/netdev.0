From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/9] net: r6040: Increase statistics upon transmit completion
Date: Mon,  4 Jul 2016 14:36:02 -0700
Message-ID: <1467668169-31547-3-git-send-email-f.fainelli@gmail.com>
References: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36596 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbcGDVgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:36:15 -0400
Received: by mail-oi0-f68.google.com with SMTP id x6so24965855oif.3
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 14:36:15 -0700 (PDT)
In-Reply-To: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

r6040_xmit() is increasing transmit statistics during transmission while
this may still fail, do this in r6040_tx() where we complete transmitted
buffers instead.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 12fc7cd67fa7..75776eee36f9 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -614,6 +614,11 @@ static void r6040_tx(struct net_device *dev)
 		if (descptr->status & DSC_OWNER_MAC)
 			break; /* Not complete */
 		skb_ptr = descptr->skb_ptr;
+
+		/* Statistic Counter */
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += skb_ptr->len;
+
 		pci_unmap_single(priv->pdev, le32_to_cpu(descptr->buf),
 			skb_ptr->len, PCI_DMA_TODEVICE);
 		/* Free buffer */
@@ -821,9 +826,6 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	/* Statistic Counter */
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
 	/* Set TX descriptor & Transmit it */
 	lp->tx_free_desc--;
 	descptr = lp->tx_insert_ptr;
-- 
2.7.4
