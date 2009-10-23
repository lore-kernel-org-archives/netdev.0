From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 20/27] sfc: Remove pointless abstraction of memory BAR
	number
Date: Fri, 23 Oct 2009 19:32:33 +0100
Message-ID: <1256322753.2785.43.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8884 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbZJWScc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:32:32 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c    |   16 +++++++---------
 drivers/net/sfc/efx.h    |    3 +++
 drivers/net/sfc/falcon.c |    2 --
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 30951fb..29003fe 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -818,9 +818,8 @@ static int efx_init_io(struct efx_nic *efx)
 		goto fail2;
 	}
 
-	efx->membase_phys = pci_resource_start(efx->pci_dev,
-					       efx->type->mem_bar);
-	rc = pci_request_region(pci_dev, efx->type->mem_bar, "sfc");
+	efx->membase_phys = pci_resource_start(efx->pci_dev, EFX_MEM_BAR);
+	rc = pci_request_region(pci_dev, EFX_MEM_BAR, "sfc");
 	if (rc) {
 		EFX_ERR(efx, "request for memory BAR failed\n");
 		rc = -EIO;
@@ -829,21 +828,20 @@ static int efx_init_io(struct efx_nic *efx)
 	efx->membase = ioremap_nocache(efx->membase_phys,
 				       efx->type->mem_map_size);
 	if (!efx->membase) {
-		EFX_ERR(efx, "could not map memory BAR %d at %llx+%x\n",
-			efx->type->mem_bar,
+		EFX_ERR(efx, "could not map memory BAR at %llx+%x\n",
 			(unsigned long long)efx->membase_phys,
 			efx->type->mem_map_size);
 		rc = -ENOMEM;
 		goto fail4;
 	}
-	EFX_LOG(efx, "memory BAR %u at %llx+%x (virtual %p)\n",
-		efx->type->mem_bar, (unsigned long long)efx->membase_phys,
+	EFX_LOG(efx, "memory BAR at %llx+%x (virtual %p)\n",
+		(unsigned long long)efx->membase_phys,
 		efx->type->mem_map_size, efx->membase);
 
 	return 0;
 
  fail4:
-	pci_release_region(efx->pci_dev, efx->type->mem_bar);
+	pci_release_region(efx->pci_dev, EFX_MEM_BAR);
  fail3:
 	efx->membase_phys = 0;
  fail2:
@@ -862,7 +860,7 @@ static void efx_fini_io(struct efx_nic *efx)
 	}
 
 	if (efx->membase_phys) {
-		pci_release_region(efx->pci_dev, efx->type->mem_bar);
+		pci_release_region(efx->pci_dev, EFX_MEM_BAR);
 		efx->membase_phys = 0;
 	}
 
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index ae76760..179e0e3 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -19,6 +19,9 @@
 #define FALCON_A_S_DEVID        0x6703
 #define FALCON_B_P_DEVID        0x0710
 
+/* Solarstorm controllers use BAR 0 for I/O space and BAR 2(&3) for memory */
+#define EFX_MEM_BAR 2
+
 /* TX */
 extern netdev_tx_t efx_xmit(struct efx_nic *efx,
 				  struct efx_tx_queue *tx_queue,
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index e3c33fa..ade2792 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -3117,7 +3117,6 @@ void falcon_update_nic_stats(struct efx_nic *efx)
  */
 
 struct efx_nic_type falcon_a_nic_type = {
-	.mem_bar = 2,
 	.mem_map_size = 0x20000,
 	.txd_ptr_tbl_base = FR_AA_TX_DESC_PTR_TBL_KER,
 	.rxd_ptr_tbl_base = FR_AA_RX_DESC_PTR_TBL_KER,
@@ -3131,7 +3130,6 @@ struct efx_nic_type falcon_a_nic_type = {
 };
 
 struct efx_nic_type falcon_b_nic_type = {
-	.mem_bar = 2,
 	/* Map everything up to and including the RSS indirection
 	 * table.  Don't map MSI-X table, MSI-X PBA since Linux
 	 * requires that they not be mapped.  */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

