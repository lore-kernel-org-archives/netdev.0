From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 25/32] sfc: Fold falcon_probe_nic_variant() into
	falcon_probe_nic()
Date: Sat, 28 Nov 2009 03:51:19 +0000
Message-ID: <1259380279.2811.56.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42744 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072AbZK1DvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:51:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

falcon_probe_nic_variant() does a lot less than it used to, and a
lot less than it claims to.  Fold the remainder into its caller.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   64 +++++++++++++++++----------------------------
 1 files changed, 24 insertions(+), 40 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 9eb3bfb..dbd0d62 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2806,40 +2806,6 @@ u32 efx_nic_fpga_ver(struct efx_nic *efx)
 	return EFX_OWORD_FIELD(altera_build, FRF_AZ_ALTERA_BUILD_VER);
 }
 
-/* Probe the NIC variant (revision, ASIC vs FPGA, function count, port
- * count, port speed).  Set workaround and feature flags accordingly.
- */
-static int falcon_probe_nic_variant(struct efx_nic *efx)
-{
-	efx_oword_t nic_stat;
-
-	if (efx_nic_fpga_ver(efx) != 0) {
-		EFX_ERR(efx, "Falcon FPGA not supported\n");
-		return -ENODEV;
-	}
-
-	efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
-
-	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1) {
-		u8 pci_rev = efx->pci_dev->revision;
-
-		if ((pci_rev == 0xff) || (pci_rev == 0)) {
-			EFX_ERR(efx, "Falcon rev A0 not supported\n");
-			return -ENODEV;
-		}
-		if (EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_10G) == 0) {
-			EFX_ERR(efx, "Falcon rev A1 1G not supported\n");
-			return -ENODEV;
-		}
-		if (EFX_OWORD_FIELD(nic_stat, FRF_AA_STRAP_PCIE) == 0) {
-			EFX_ERR(efx, "Falcon rev A1 PCI-X not supported\n");
-			return -ENODEV;
-		}
-	}
-
-	return 0;
-}
-
 /* Probe all SPI devices on the NIC */
 static void falcon_probe_spi_devices(struct efx_nic *efx)
 {
@@ -2891,15 +2857,33 @@ static int falcon_probe_nic(struct efx_nic *efx)
 		return -ENOMEM;
 	efx->nic_data = nic_data;
 
-	/* Determine number of ports etc. */
-	rc = falcon_probe_nic_variant(efx);
-	if (rc)
+	rc = -ENODEV;
+
+	if (efx_nic_fpga_ver(efx) != 0) {
+		EFX_ERR(efx, "Falcon FPGA not supported\n");
 		goto fail1;
+	}
+
+	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1) {
+		efx_oword_t nic_stat;
+		struct pci_dev *dev;
+		u8 pci_rev = efx->pci_dev->revision;
 
-	/* Probe secondary function if expected */
-	if (efx_nic_is_dual_func(efx)) {
-		struct pci_dev *dev = pci_dev_get(efx->pci_dev);
+		if ((pci_rev == 0xff) || (pci_rev == 0)) {
+			EFX_ERR(efx, "Falcon rev A0 not supported\n");
+			goto fail1;
+		}
+		efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
+		if (EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_10G) == 0) {
+			EFX_ERR(efx, "Falcon rev A1 1G not supported\n");
+			goto fail1;
+		}
+		if (EFX_OWORD_FIELD(nic_stat, FRF_AA_STRAP_PCIE) == 0) {
+			EFX_ERR(efx, "Falcon rev A1 PCI-X not supported\n");
+			goto fail1;
+		}
 
+		dev = pci_dev_get(efx->pci_dev);
 		while ((dev = pci_get_device(EFX_VENDID_SFC, FALCON_A_S_DEVID,
 					     dev))) {
 			if (dev->bus == efx->pci_dev->bus &&

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

