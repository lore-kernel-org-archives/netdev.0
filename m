From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: ep93xx_eth: Do not crash unloading module
Date: Sun,  4 Dec 2016 19:22:05 -0800
Message-ID: <20161205032205.14127-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, hsweeten@visionengravers.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36020 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751227AbcLEDWg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 22:22:36 -0500
Received: by mail-oi0-f66.google.com with SMTP id u15so34830773oie.3
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 19:22:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we unload the ep93xx_eth, whether we have opened the network
interface or not, we will either hit a kernel paging request error, or a
simple NULL pointer de-reference because:

- if ep93xx_open has been called, we have created a valid DMA mapping
  for ep->descs, when we call ep93xx_stop, we also call
  ep93xx_free_buffers, ep->descs now has a stale value

- if ep93xx_open has not been called, we have a NULL pointer for
  ep->descs, so performing any operation against that address just won't
  work

Fix this by adding a NULL pointer check for ep->descs which means that
ep93xx_free_buffers() was able to successfully tear down the descriptors
and free the DMA cookie as well.

Fixes: 1d22e05df818 ("[PATCH] Cirrus Logic ep93xx ethernet driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/cirrus/ep93xx_eth.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index de9f7c97d916..9a161e981529 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -468,6 +468,9 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
 	struct device *dev = ep->dev->dev.parent;
 	int i;
 
+	if (!ep->descs)
+		return;
+
 	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
 		dma_addr_t d;
 
@@ -490,6 +493,7 @@ static void ep93xx_free_buffers(struct ep93xx_priv *ep)
 
 	dma_free_coherent(dev, sizeof(struct ep93xx_descs), ep->descs,
 							ep->descs_dma_addr);
+	ep->descs = NULL;
 }
 
 static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
-- 
2.9.3
