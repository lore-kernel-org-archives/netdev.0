From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: [PATCH] net: ep93xx_eth: drop GFP_DMA from memory allocations
Date: Sun, 29 May 2011 12:03:57 +0300
Message-ID: <1306659837-23553-1-git-send-email-mika.westerberg@iki.fi>
Cc: kernel@wantstofly.org, hsweeten@visionengravers.com,
	ryan@bluewatersys.com, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:58090 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab1E2JGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2011 05:06:04 -0400
Received: by ewy4 with SMTP id 4so1050750ewy.19
        for <netdev@vger.kernel.org>; Sun, 29 May 2011 02:06:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a197b59ae6e8 (mm: fail GFP_DMA allocations when ZONE_DMA is not
configured) made page allocator to return NULL if GFP_DMA is set but
CONFIG_ZONE_DMA is disabled.

This causes ep93xx_eth to fail:

 WARNING: at mm/page_alloc.c:2251 __alloc_pages_nodemask+0x11c/0x638()
 Modules linked in:
 [<c0035498>] (unwind_backtrace+0x0/0xf4) from [<c0043da4>] (warn_slowpath_common+0x48/0x60)
 [<c0043da4>] (warn_slowpath_common+0x48/0x60) from [<c0043dd8>] (warn_slowpath_null+0x1c/0x24)
 [<c0043dd8>] (warn_slowpath_null+0x1c/0x24) from [<c0083b6c>] (__alloc_pages_nodemask+0x11c/0x638)
 [<c0083b6c>] (__alloc_pages_nodemask+0x11c/0x638) from [<c00366fc>] (__dma_alloc+0x8c/0x3ec)
 [<c00366fc>] (__dma_alloc+0x8c/0x3ec) from [<c0036adc>] (dma_alloc_coherent+0x54/0x60)
 [<c0036adc>] (dma_alloc_coherent+0x54/0x60) from [<c0227808>] (ep93xx_open+0x20/0x864)
 [<c0227808>] (ep93xx_open+0x20/0x864) from [<c0283144>] (__dev_open+0xb8/0x108)
 [<c0283144>] (__dev_open+0xb8/0x108) from [<c0280528>] (__dev_change_flags+0x70/0x128)
 [<c0280528>] (__dev_change_flags+0x70/0x128) from [<c0283054>] (dev_change_flags+0x10/0x48)
 [<c0283054>] (dev_change_flags+0x10/0x48) from [<c001a720>] (ip_auto_config+0x190/0xf68)
 [<c001a720>] (ip_auto_config+0x190/0xf68) from [<c00233b0>] (do_one_initcall+0x34/0x18c)
 [<c00233b0>] (do_one_initcall+0x34/0x18c) from [<c0008400>] (kernel_init+0x94/0x134)
 [<c0008400>] (kernel_init+0x94/0x134) from [<c0030858>] (kernel_thread_exit+0x0/0x8)

Since there is no restrictions for DMA on ep93xx, we can fix this by just
removing the GFP_DMA flag from the allocations.

Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
---
 drivers/net/arm/ep93xx_eth.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 5a77001..e495f76 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -494,7 +494,7 @@ static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
 	int i;
 
 	ep->descs = dma_alloc_coherent(NULL, sizeof(struct ep93xx_descs),
-				&ep->descs_dma_addr, GFP_KERNEL | GFP_DMA);
+				&ep->descs_dma_addr, GFP_KERNEL);
 	if (ep->descs == NULL)
 		return 1;
 
@@ -502,7 +502,7 @@ static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
 		void *page;
 		dma_addr_t d;
 
-		page = (void *)__get_free_page(GFP_KERNEL | GFP_DMA);
+		page = (void *)__get_free_page(GFP_KERNEL);
 		if (page == NULL)
 			goto err;
 
@@ -525,7 +525,7 @@ static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
 		void *page;
 		dma_addr_t d;
 
-		page = (void *)__get_free_page(GFP_KERNEL | GFP_DMA);
+		page = (void *)__get_free_page(GFP_KERNEL);
 		if (page == NULL)
 			goto err;
 
-- 
1.7.4.4

