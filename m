From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 10/15] nouveau: don't call pci_dma_supported
Date: Sat,  3 Oct 2015 17:19:34 +0200
Message-ID: <1443885579-7094-11-git-send-email-hch@lst.de>
References: <1443885579-7094-1-git-send-email-hch@lst.de>
Cc: linux-net-drivers@solarflare.com, dri-devel@lists.freedesktop.org,
	linux-media@vger.kernel.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Don Fry <pcnet32@frontier.com>,
	Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:51300 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbJCPYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 11:24:04 -0400
In-Reply-To: <1443885579-7094-1-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just try to set a 64-bit DMA mask first and retry with the smaller dma_mask
if dma_set_mask failed.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_ttm.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_ttm.c b/drivers/gpu/drm/nouveau/nouveau_ttm.c
index 3f0fb55..bb030e6 100644
--- a/drivers/gpu/drm/nouveau/nouveau_ttm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_ttm.c
@@ -350,11 +350,14 @@ nouveau_ttm_init(struct nouveau_drm *drm)
 
 	bits = nvxx_mmu(&drm->device)->dma_bits;
 	if (nvxx_device(&drm->device)->func->pci) {
-		if (drm->agp.bridge ||
-		     !pci_dma_supported(dev->pdev, DMA_BIT_MASK(bits)))
+		if (drm->agp.bridge)
 			bits = 32;
 
 		ret = pci_set_dma_mask(dev->pdev, DMA_BIT_MASK(bits));
+		if (ret && bits != 32) {
+			bits = 32;
+			ret = pci_set_dma_mask(dev->pdev, DMA_BIT_MASK(bits));
+		}
 		if (ret)
 			return ret;
 
-- 
1.9.1
