From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 31/35] sfc: Use pci_enable_msix_range() instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 11:12:00 +0100
Message-ID: <ee04d8c3b86765cbfd0f5ea7ce2e79db34113401.1392717503.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Shradha Shah <sshah@solarflare.com>,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392717502.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
Cc: Shradha Shah <sshah@solarflare.com>
Cc: linux-net-drivers@solarflare.com
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
Acked-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 62d1a78..d72e003 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1344,20 +1344,23 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 
 		for (i = 0; i < n_channels; i++)
 			xentries[i].entry = i;
-		rc = pci_enable_msix(efx->pci_dev, xentries, n_channels);
-		if (rc > 0) {
+		rc = pci_enable_msix_range(efx->pci_dev,
+					   xentries, 1, n_channels);
+		if (rc < 0) {
+			/* Fall back to single channel MSI */
+			efx->interrupt_mode = EFX_INT_MODE_MSI;
+			netif_err(efx, drv, efx->net_dev,
+				  "could not enable MSI-X\n");
+		} else if (rc < n_channels) {
 			netif_err(efx, drv, efx->net_dev,
 				  "WARNING: Insufficient MSI-X vectors"
 				  " available (%d < %u).\n", rc, n_channels);
 			netif_err(efx, drv, efx->net_dev,
 				  "WARNING: Performance may be reduced.\n");
-			EFX_BUG_ON_PARANOID(rc >= n_channels);
 			n_channels = rc;
-			rc = pci_enable_msix(efx->pci_dev, xentries,
-					     n_channels);
 		}
 
-		if (rc == 0) {
+		if (rc > 0) {
 			efx->n_channels = n_channels;
 			if (n_channels > extra_channels)
 				n_channels -= extra_channels;
@@ -1373,11 +1376,6 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 			for (i = 0; i < efx->n_channels; i++)
 				efx_get_channel(efx, i)->irq =
 					xentries[i].vector;
-		} else {
-			/* Fall back to single channel MSI */
-			efx->interrupt_mode = EFX_INT_MODE_MSI;
-			netif_err(efx, drv, efx->net_dev,
-				  "could not enable MSI-X\n");
 		}
 	}
 
-- 
1.7.7.6
