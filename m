From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 05/13] nfp: only try to get to PCIe ctrl memory if BARs are wide enough
Date: Sun, 28 May 2017 17:52:56 -0700
Message-ID: <20170529005304.20847-6-jakub.kicinski@netronome.com>
References: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35938 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750904AbdE2Ayi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 20:54:38 -0400
Received: by mail-pg0-f48.google.com with SMTP id x64so15377146pgd.3
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 17:54:32 -0700 (PDT)
In-Reply-To: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For accessing PCIe ctrl memory we depend on the BAR aperture being
large enough to reach all registers.  Since the BAR aperture can
be set in the flash make sure the driver won't oops the kernel
when the PCIe configuration is unusual.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
index 1fde213d5b83..597ac8febb63 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
@@ -119,6 +119,11 @@
 #define NFP_PCIE_EM                                     0x020000
 #define NFP_PCIE_SRAM                                   0x000000
 
+/* Minimal size of the PCIe cfg memory we depend on being mapped,
+ * queue controller and DMA controller don't have to be covered.
+ */
+#define NFP_PCI_MIN_MAP_SIZE				0x080000
+
 #define NFP_PCIE_P2C_FIXED_SIZE(bar)               (1 << (bar)->bitsize)
 #define NFP_PCIE_P2C_BULK_SIZE(bar)                (1 << (bar)->bitsize)
 #define NFP_PCIE_P2C_GENERAL_TARGET_OFFSET(bar, x) ((x) << ((bar)->bitsize - 2))
@@ -628,8 +633,9 @@ static int enable_bars(struct nfp6000_pcie *nfp, u16 interface)
 
 	/* Configure, and lock, BAR0.0 for General Target use (MSI-X SRAM) */
 	bar = &nfp->bar[0];
-	bar->iomem = ioremap_nocache(nfp_bar_resource_start(bar),
-				     nfp_bar_resource_len(bar));
+	if (nfp_bar_resource_len(bar) >= NFP_PCI_MIN_MAP_SIZE)
+		bar->iomem = ioremap_nocache(nfp_bar_resource_start(bar),
+					     nfp_bar_resource_len(bar));
 	if (bar->iomem) {
 		dev_info(nfp->dev,
 			 "BAR0.0 RESERVED: General Mapping/MSI-X SRAM\n");
-- 
2.11.0
