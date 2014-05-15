From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: systemport: fix dma_unmap_single() len
Date: Thu, 15 May 2014 14:33:52 -0700
Message-ID: <1400189633-7602-2-git-send-email-f.fainelli@gmail.com>
References: <1400189633-7602-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:61883 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbaEOVe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 17:34:26 -0400
Received: by mail-ig0-f174.google.com with SMTP id h3so8493575igd.13
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 14:34:26 -0700 (PDT)
In-Reply-To: <1400189633-7602-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dma_unmap_single() was called with dma_unmap_len(cb, dma_len),
unfortunately we failed to assign this length field in
bcm_sysport_rx_refill() or bcm_sysport_alloc_rx_bufs() using
dma_unmap_len_set().

This causes packet contents corruption because are we not invoking the
cache invalidation routines with the proper length.  Fix this by using
the full RX buffer size (RX_BUF_LENGTH) because the mappings for the RX
bufers are created with that size.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 8edc0980cdf5..26030d67518b 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -479,7 +479,7 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 		cb = &priv->rx_cbs[priv->rx_read_ptr];
 		skb = cb->skb;
 		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
-				dma_unmap_len(cb, dma_len), DMA_FROM_DEVICE);
+				RX_BUF_LENGTH, DMA_FROM_DEVICE);
 
 		/* Extract the Receive Status Block prepended */
 		rsb = (struct rsb *)skb->data;
-- 
1.9.1
