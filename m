From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH] ftgmac100: return error in ftgmac100_alloc_rx_buf
Date: Tue, 25 Jul 2017 10:19:01 +0930
Message-ID: <20170725004901.13406-1-joel@jms.id.au>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33868 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751869AbdGYAtO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:49:14 -0400
Received: by mail-pg0-f66.google.com with SMTP id v190so13085217pgv.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 17:49:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The error paths set err, but it's not returned.

I wondered if we should fix all of the callers to check the returned
value, but Ben explains why the code is this way:

> Most call sites ignore it on purpose. There's nothing we can do if
> we fail to get a buffer at interrupt time, so we point the buffer to
> the scratch page so the HW doesn't DMA into lalaland and lose the
> packet.
>
> The one call site that tests and can fail is the one used when brining
> the interface up. If we fail to allocate at that point, we fail the
> ifup. But as you noticed, I do have a bug not returning the error.

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index fce0aa4f78b7..33b5c8eb9961 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -392,7 +392,7 @@ static int ftgmac100_alloc_rx_buf(struct ftgmac100 *priv, unsigned int entry,
 	struct net_device *netdev = priv->netdev;
 	struct sk_buff *skb;
 	dma_addr_t map;
-	int err;
+	int err = 0;
 
 	skb = netdev_alloc_skb_ip_align(netdev, RX_BUF_SIZE);
 	if (unlikely(!skb)) {
@@ -428,7 +428,7 @@ static int ftgmac100_alloc_rx_buf(struct ftgmac100 *priv, unsigned int entry,
 	else
 		rxdes->rxdes0 = 0;
 
-	return 0;
+	return err;
 }
 
 static unsigned int ftgmac100_next_rx_pointer(struct ftgmac100 *priv,
-- 
2.13.3
