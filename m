From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 03/12] nfp: don't set aux pointers if ioremap failed
Date: Sat, 27 May 2017 17:34:02 -0700
Message-ID: <20170528003411.17603-4-jakub.kicinski@netronome.com>
References: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35043 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbdE1Aep (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 20:34:45 -0400
Received: by mail-pg0-f44.google.com with SMTP id 8so8584713pgc.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 17:34:44 -0700 (PDT)
In-Reply-To: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If ioremap of PCIe ctrl memory failed we can still get to it through
PCI config space, therefore we allow ioremap() to fail.  When if fails,
however, we must leave all the IOMEM pointers as NULL.  Currently we
would calculate csr and em pointers, adding offsets to the potential
NULL value and therefore making the NULL-checks throughout the code
ineffective.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c    | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
index 43dc68e01274..1fde213d5b83 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
@@ -639,19 +639,23 @@ static int enable_bars(struct nfp6000_pcie *nfp, u16 interface)
 		nfp6000_bar_write(nfp, bar, barcfg_msix_general);
 
 		nfp->expl.data = bar->iomem + NFP_PCIE_SRAM + 0x1000;
+
+		if (nfp->pdev->device == PCI_DEVICE_ID_NETRONOME_NFP4000 ||
+		    nfp->pdev->device == PCI_DEVICE_ID_NETRONOME_NFP6000) {
+			nfp->iomem.csr = bar->iomem + NFP_PCIE_BAR(0);
+		} else {
+			int pf = nfp->pdev->devfn & 7;
+
+			nfp->iomem.csr = bar->iomem + NFP_PCIE_BAR(pf);
+		}
+		nfp->iomem.em = bar->iomem + NFP_PCIE_EM;
 	}
 
 	if (nfp->pdev->device == PCI_DEVICE_ID_NETRONOME_NFP4000 ||
-	    nfp->pdev->device == PCI_DEVICE_ID_NETRONOME_NFP6000) {
-		nfp->iomem.csr = bar->iomem + NFP_PCIE_BAR(0);
+	    nfp->pdev->device == PCI_DEVICE_ID_NETRONOME_NFP6000)
 		expl_groups = 4;
-	} else {
-		int pf = nfp->pdev->devfn & 7;
-
-		nfp->iomem.csr = bar->iomem + NFP_PCIE_BAR(pf);
+	else
 		expl_groups = 1;
-	}
-	nfp->iomem.em = bar->iomem + NFP_PCIE_EM;
 
 	/* Configure, and lock, BAR0.1 for PCIe XPB (MSI-X PBA) */
 	bar = &nfp->bar[1];
-- 
2.11.0
