From: Craig Hada <craig.hada@hp.com>
Subject: [PATCH net-next] drivers/net: Enable IOMMU pass through for be2net
Date: Wed, 12 Sep 2012 10:58:54 -0700
Message-ID: <1347472734-3196-2-git-send-email-craig.hada@hp.com>
References: <1347472734-3196-1-git-send-email-craig.hada@hp.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, craig.hada@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347472734-3196-1-git-send-email-craig.hada@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch sets the coherent DMA mask to 64-bit after the be2net driver
has been acknowledged that the system is 64-bit DMA capable. The coherent
DMA mask is examined by the Intel IOMMU driver to determine whether to
allow pass through context mapping for all devices. With this patch, the
be2net driver combined with be2net compatible hardware provides
comparable performance to the case where vt-d is disabled. The main use
case for this change is to decrease the time necessary to copy virtual
machine memory during KVM live migration instantiations.

This patch was tested on a system that enables the IOMMU in non-coherent
mode. Two DMA remapper issues were encountered and both are in the Intel
IOMMU driver with the following patches submitted upstream but not yet
commited.

Patch 1 - DMAR:[fault reason 02] Present bit in context entry is clear
https://lkml.org/lkml/2012/6/15/20

Patch 2 - DMAR:[fault reason 02] Present bit in context entry is clear
https://lkml.org/lkml/2011/11/11/279

Signed-off-by: Craig Hada <craig.hada@hp.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 78b8aa8..57bbea4 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3835,6 +3835,12 @@ static int __devinit be_probe(struct pci_dev *pdev,
 
 	status = dma_set_mask(&pdev->dev, DMA_BIT_MASK(64));
 	if (!status) {
+		status = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
+		if (status < 0) {
+			dev_err(&pdev->dev,
+				"dma_set_coherent_mask failed, aborting\n");
+			goto free_netdev;
+		}
 		netdev->features |= NETIF_F_HIGHDMA;
 	} else {
 		status = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
-- 
1.7.1
