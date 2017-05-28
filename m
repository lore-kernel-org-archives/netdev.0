From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 04/12] nfp: only try to get to PCIe ctrl memory if BARs are wide enough
Date: Sat, 27 May 2017 17:34:03 -0700
Message-ID: <20170528003411.17603-5-jakub.kicinski@netronome.com>
References: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34470 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750784AbdE1Aep (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 20:34:45 -0400
Received: by mail-pf0-f181.google.com with SMTP id 9so32597449pfj.1
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 17:34:45 -0700 (PDT)
In-Reply-To: <20170528003411.17603-1-jakub.kicinski@netronome.com>
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
