From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/9] net: r6040: Utilize skb_put_padto()
Date: Mon,  4 Jul 2016 14:36:03 -0700
Message-ID: <1467668169-31547-4-git-send-email-f.fainelli@gmail.com>
References: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35708 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855AbcGDVgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:36:16 -0400
Received: by mail-oi0-f67.google.com with SMTP id d132so24947605oig.2
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 14:36:16 -0700 (PDT)
In-Reply-To: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pad the SKB to the minimum length of ETH_ZLEN by using skb_put_padto()
and take this operation out of the critical section since there is no
need to check any HW resources before doing that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 75776eee36f9..46ed093348da 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -815,6 +815,9 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
 	void __iomem *ioaddr = lp->base;
 	unsigned long flags;
 
+	if (skb_put_padto(skb, ETH_ZLEN) < 0)
+		return NETDEV_TX_OK;
+
 	/* Critical Section */
 	spin_lock_irqsave(&lp->lock, flags);
 
@@ -829,11 +832,7 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
 	/* Set TX descriptor & Transmit it */
 	lp->tx_free_desc--;
 	descptr = lp->tx_insert_ptr;
-	if (skb->len < ETH_ZLEN)
-		descptr->len = ETH_ZLEN;
-	else
-		descptr->len = skb->len;
-
+	descptr->len = skb->len;
 	descptr->skb_ptr = skb;
 	descptr->buf = cpu_to_le32(pci_map_single(lp->pdev,
 		skb->data, skb->len, PCI_DMA_TODEVICE));
-- 
2.7.4
