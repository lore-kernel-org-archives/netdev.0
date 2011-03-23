From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] sfc: Siena: Disable write-combining when SR-IOV is
 enabled
Date: Wed, 23 Mar 2011 21:16:59 +0000
Message-ID: <1300915019.2638.20.camel@bwh-desktop>
References: <1300914873.2638.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:55064 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754434Ab1CWVRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 17:17:02 -0400
In-Reply-To: <1300914873.2638.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

If SR-IOV is enabled by firmware, even if it is not enabled in the PCI
capability, TX pushes using write-combining may be corrupted.

We want to know whether it is enabled before mapping the NIC
registers, and even if PCI extended capabilities are not accessible.
Therefore, we look for the MSI capability, which is removed if SR-IOV
is enabled.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c         |   18 ++++++++++++++++--
 drivers/net/sfc/workarounds.h |    2 ++
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index b8bd936..d890679 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1054,6 +1054,7 @@ static int efx_init_io(struct efx_nic *efx)
 {
 	struct pci_dev *pci_dev = efx->pci_dev;
 	dma_addr_t dma_mask = efx->type->max_dma_mask;
+	bool use_wc;
 	int rc;
 
 	netif_dbg(efx, probe, efx->net_dev, "initialising I/O\n");
@@ -1104,8 +1105,21 @@ static int efx_init_io(struct efx_nic *efx)
 		rc = -EIO;
 		goto fail3;
 	}
-	efx->membase = ioremap_wc(efx->membase_phys,
-				  efx->type->mem_map_size);
+
+	/* bug22643: If SR-IOV is enabled then tx push over a write combined
+	 * mapping is unsafe. We need to disable write combining in this case.
+	 * MSI is unsupported when SR-IOV is enabled, and the firmware will
+	 * have removed the MSI capability. So write combining is safe if
+	 * there is an MSI capability.
+	 */
+	use_wc = (!EFX_WORKAROUND_22643(efx) ||
+		  pci_find_capability(pci_dev, PCI_CAP_ID_MSI));
+	if (use_wc)
+		efx->membase = ioremap_wc(efx->membase_phys,
+					  efx->type->mem_map_size);
+	else
+		efx->membase = ioremap_nocache(efx->membase_phys,
+					       efx->type->mem_map_size);
 	if (!efx->membase) {
 		netif_err(efx, probe, efx->net_dev,
 			  "could not map memory BAR at %llx+%x\n",
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index e4dd3a7..99ff114 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -38,6 +38,8 @@
 #define EFX_WORKAROUND_15783 EFX_WORKAROUND_ALWAYS
 /* Legacy interrupt storm when interrupt fifo fills */
 #define EFX_WORKAROUND_17213 EFX_WORKAROUND_SIENA
+/* Write combining and sriov=enabled are incompatible */
+#define EFX_WORKAROUND_22643 EFX_WORKAROUND_SIENA
 
 /* Spurious parity errors in TSORT buffers */
 #define EFX_WORKAROUND_5129 EFX_WORKAROUND_FALCON_A
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

