From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 06/12] nfp: shorten CPP core probe logs
Date: Sat, 27 May 2017 17:34:05 -0700
Message-ID: <20170528003411.17603-7-jakub.kicinski@netronome.com>
References: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36696 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbdE1Aer (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 20:34:47 -0400
Received: by mail-pg0-f51.google.com with SMTP id x64so8594386pgd.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 17:34:46 -0700 (PDT)
In-Reply-To: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently print reserved BAR mappings info as we create them.
This makes the probe logs longer than necessary.  Print into a
buffer instead and log all the info as a single line.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
index 597ac8febb63..cd678323bacb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
@@ -588,9 +588,15 @@ static int enable_bars(struct nfp6000_pcie *nfp, u16 interface)
 		NFP_PCIE_BAR_PCIE2CPP_MapType(
 			NFP_PCIE_BAR_PCIE2CPP_MapType_EXPLICIT3),
 	};
+	char status_msg[196] = {};
 	struct nfp_bar *bar;
 	int i, bars_free;
 	int expl_groups;
+	char *msg, *end;
+
+	msg = status_msg +
+		snprintf(status_msg, sizeof(status_msg) - 1, "RESERVED BARs: ");
+	end = status_msg + sizeof(status_msg) - 1;
 
 	bar = &nfp->bar[0];
 	for (i = 0; i < ARRAY_SIZE(nfp->bar); i++, bar++) {
@@ -637,8 +643,7 @@ static int enable_bars(struct nfp6000_pcie *nfp, u16 interface)
 		bar->iomem = ioremap_nocache(nfp_bar_resource_start(bar),
 					     nfp_bar_resource_len(bar));
 	if (bar->iomem) {
-		dev_info(nfp->dev,
-			 "BAR0.0 RESERVED: General Mapping/MSI-X SRAM\n");
+		msg += snprintf(msg, end - msg,	"0.0: General/MSI-X SRAM, ");
 		atomic_inc(&bar->refcnt);
 		bars_free--;
 
@@ -665,7 +670,7 @@ static int enable_bars(struct nfp6000_pcie *nfp, u16 interface)
 
 	/* Configure, and lock, BAR0.1 for PCIe XPB (MSI-X PBA) */
 	bar = &nfp->bar[1];
-	dev_info(nfp->dev, "BAR0.1 RESERVED: PCIe XPB/MSI-X PBA\n");
+	msg += snprintf(msg, end - msg, "0.1: PCIe XPB/MSI-X PBA, ");
 	atomic_inc(&bar->refcnt);
 	bars_free--;
 
@@ -684,9 +689,8 @@ static int enable_bars(struct nfp6000_pcie *nfp, u16 interface)
 		bar->iomem = ioremap_nocache(nfp_bar_resource_start(bar),
 					     nfp_bar_resource_len(bar));
 		if (bar->iomem) {
-			dev_info(nfp->dev,
-				 "BAR0.%d RESERVED: Explicit%d Mapping\n",
-				 4 + i, i);
+			msg += snprintf(msg, end - msg,
+					"0.%d: Explicit%d, ", 4 + i, i);
 			atomic_inc(&bar->refcnt);
 			bars_free--;
 
@@ -704,8 +708,7 @@ static int enable_bars(struct nfp6000_pcie *nfp, u16 interface)
 	sort(&nfp->bar[0], nfp->bars, sizeof(nfp->bar[0]),
 	     bar_cmp, NULL);
 
-	dev_info(nfp->dev, "%d NFP PCI2CPP BARs, %d free\n",
-		 nfp->bars, bars_free);
+	dev_info(nfp->dev, "%sfree: %d/%d\n", status_msg, bars_free, nfp->bars);
 
 	return 0;
 }
-- 
2.11.0
