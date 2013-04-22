From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 5/5] be2net: enable IOMMU pass through for be2net
Date: Mon, 22 Apr 2013 14:58:18 +0530
Message-ID: <1366622898-1416-6-git-send-email-sathya.perla@emulex.com>
References: <1366622898-1416-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:2838 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755748Ab3DVJZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 05:25:49 -0400
In-Reply-To: <1366622898-1416-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Hada <craig.hada@hp.com>

This patch sets the coherent DMA mask to 64-bit after the be2net driver has
been acknowledged that the system is 64-bit DMA capable. The coherent DMA
mask is examined by the Intel IOMMU driver to determine whether to allow
pass through context mapping for all devices. With this patch, the be2net
driver combined with be2net compatible hardware provides comparable
performance to the case where vt-d is disabled. The main use-case for this
change is to decrease the time necessary to copy virtual machine memory
during KVM live migration instantiations.

This patch was tested on a system that enables the IOMMU in non-coherent
mode. Two DMA remapper issues were encountered in the previous version and
both patches have been committed.
    commit ea2447f700cab264019b52e2b417d689e052dcfd
    commit 2e12bc29fc5a12242d68e11875db3dd58efad9ff

Signed-off-by: Craig Hada <craig.hada@hp.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c1254cb..852ab5c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4134,6 +4134,11 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 
 	status = dma_set_mask(&pdev->dev, DMA_BIT_MASK(64));
 	if (!status) {
+		status = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
+		if (status < 0) {
+			dev_err(&pdev->dev, "dma_set_coherent_mask failed\n");
+			goto free_netdev;
+		}
 		netdev->features |= NETIF_F_HIGHDMA;
 	} else {
 		status = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
-- 
1.7.1
