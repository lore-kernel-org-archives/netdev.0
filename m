From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/16] sfc: Add GFP flags to efx_nic_alloc_buffer()
 and make most callers allow blocking
Date: Mon, 26 Aug 2013 00:00:53 +0100
Message-ID: <1377471653.2586.71.camel@deadeye.wl.decadent.org.uk>
References: <1377471363.2586.69.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56299 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756213Ab3HYXA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 19:00:58 -0400
In-Reply-To: <1377471363.2586.69.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most call sites for efx_nic_alloc_buffer() are part of the probe or
reconfiguration paths and can allocate with GFP_KERNEL.  A few others
should use GFP_NOIO (I think).  Only one is in atomic context and
must use the current GFP_ATOMIC.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon.c      |    5 +++--
 drivers/net/ethernet/sfc/mcdi_mon.c    |    2 +-
 drivers/net/ethernet/sfc/mcdi_port.c   |    2 +-
 drivers/net/ethernet/sfc/nic.c         |    4 ++--
 drivers/net/ethernet/sfc/nic.h         |    2 +-
 drivers/net/ethernet/sfc/ptp.c         |    2 +-
 drivers/net/ethernet/sfc/siena.c       |    3 ++-
 drivers/net/ethernet/sfc/siena_sriov.c |   10 ++++++----
 drivers/net/ethernet/sfc/tx.c          |    3 ++-
 9 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 522850036..395d89d 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -1418,7 +1418,7 @@ static int falcon_probe_port(struct efx_nic *efx)
 
 	/* Allocate buffer for stats */
 	rc = efx_nic_alloc_buffer(efx, &efx->stats_buffer,
-				  FALCON_MAC_STATS_SIZE);
+				  FALCON_MAC_STATS_SIZE, GFP_KERNEL);
 	if (rc)
 		return rc;
 	netif_dbg(efx, probe, efx->net_dev,
@@ -2035,7 +2035,8 @@ static int falcon_probe_nic(struct efx_nic *efx)
 	}
 
 	/* Allocate memory for INT_KER */
-	rc = efx_nic_alloc_buffer(efx, &efx->irq_status, sizeof(efx_oword_t));
+	rc = efx_nic_alloc_buffer(efx, &efx->irq_status, sizeof(efx_oword_t),
+				  GFP_KERNEL);
 	if (rc)
 		goto fail4;
 	BUG_ON(efx->irq_status.dma_addr & 0x0f);
diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index 3179b2b..958c73f 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -261,7 +261,7 @@ int efx_mcdi_mon_probe(struct efx_nic *efx)
 		return -EIO;
 
 	rc = efx_nic_alloc_buffer(efx, &hwmon->dma_buf,
-				  4 * MC_CMD_SENSOR_ENTRY_MAXNUM);
+				  4 * MC_CMD_SENSOR_ENTRY_MAXNUM, GFP_KERNEL);
 	if (rc)
 		return rc;
 
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 8f31e3d..91df43f 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -989,7 +989,7 @@ int efx_mcdi_port_probe(struct efx_nic *efx)
 
 	/* Allocate buffer for stats */
 	rc = efx_nic_alloc_buffer(efx, &efx->stats_buffer,
-				  MC_CMD_MAC_NSTATS * sizeof(u64));
+				  MC_CMD_MAC_NSTATS * sizeof(u64), GFP_KERNEL);
 	if (rc)
 		return rc;
 	netif_dbg(efx, probe, efx->net_dev,
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 56ed3bc..efe2773 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -303,11 +303,11 @@ efx_free_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
  **************************************************************************/
 
 int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
-			 unsigned int len)
+			 unsigned int len, gfp_t gfp_flags)
 {
 	buffer->addr = dma_alloc_coherent(&efx->pci_dev->dev, len,
 					  &buffer->dma_addr,
-					  GFP_ATOMIC | __GFP_ZERO);
+					  gfp_flags | __GFP_ZERO);
 	if (!buffer->addr)
 		return -ENOMEM;
 	buffer->len = len;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index c699203..9120e8b 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -332,7 +332,7 @@ extern void efx_nic_init_common(struct efx_nic *efx);
 extern void efx_nic_push_rx_indir_table(struct efx_nic *efx);
 
 int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
-			 unsigned int len);
+			 unsigned int len, gfp_t gfp_flags);
 void efx_nic_free_buffer(struct efx_nic *efx, struct efx_buffer *buffer);
 
 /* Tests */
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index d96bfc4..56a8b88 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -875,7 +875,7 @@ static int efx_ptp_probe_channel(struct efx_channel *channel)
 	if (!efx->ptp_data)
 		return -ENOMEM;
 
-	rc = efx_nic_alloc_buffer(efx, &ptp->start, sizeof(int));
+	rc = efx_nic_alloc_buffer(efx, &ptp->start, sizeof(int), GFP_KERNEL);
 	if (rc != 0)
 		goto fail1;
 
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 73b511a..f0ae262 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -237,7 +237,8 @@ static int siena_probe_nic(struct efx_nic *efx)
 	siena_init_wol(efx);
 
 	/* Allocate memory for INT_KER */
-	rc = efx_nic_alloc_buffer(efx, &efx->irq_status, sizeof(efx_oword_t));
+	rc = efx_nic_alloc_buffer(efx, &efx->irq_status, sizeof(efx_oword_t),
+				  GFP_KERNEL);
 	if (rc)
 		goto fail4;
 	BUG_ON(efx->irq_status.dma_addr & 0x0f);
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 2587d30..6258e7f 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -997,7 +997,7 @@ static void efx_sriov_reset_vf_work(struct work_struct *work)
 	struct efx_nic *efx = vf->efx;
 	struct efx_buffer buf;
 
-	if (!efx_nic_alloc_buffer(efx, &buf, EFX_PAGE_SIZE)) {
+	if (!efx_nic_alloc_buffer(efx, &buf, EFX_PAGE_SIZE, GFP_NOIO)) {
 		efx_sriov_reset_vf(vf, &buf);
 		efx_nic_free_buffer(efx, &buf);
 	}
@@ -1241,7 +1241,8 @@ static int efx_sriov_vfs_init(struct efx_nic *efx)
 			 pci_domain_nr(pci_dev->bus), pci_dev->bus->number,
 			 PCI_SLOT(devfn), PCI_FUNC(devfn));
 
-		rc = efx_nic_alloc_buffer(efx, &vf->buf, EFX_PAGE_SIZE);
+		rc = efx_nic_alloc_buffer(efx, &vf->buf, EFX_PAGE_SIZE,
+					  GFP_KERNEL);
 		if (rc)
 			goto fail;
 
@@ -1273,7 +1274,8 @@ int efx_sriov_init(struct efx_nic *efx)
 	if (rc)
 		goto fail_cmd;
 
-	rc = efx_nic_alloc_buffer(efx, &efx->vfdi_status, sizeof(*vfdi_status));
+	rc = efx_nic_alloc_buffer(efx, &efx->vfdi_status, sizeof(*vfdi_status),
+				  GFP_KERNEL);
 	if (rc)
 		goto fail_status;
 	vfdi_status = efx->vfdi_status.addr;
@@ -1528,7 +1530,7 @@ void efx_sriov_reset(struct efx_nic *efx)
 	efx_sriov_usrev(efx, true);
 	(void)efx_sriov_cmd(efx, true, NULL, NULL);
 
-	if (efx_nic_alloc_buffer(efx, &buf, EFX_PAGE_SIZE))
+	if (efx_nic_alloc_buffer(efx, &buf, EFX_PAGE_SIZE, GFP_NOIO))
 		return;
 
 	for (vf_i = 0; vf_i < efx->vf_init_count; ++vf_i) {
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 5e090e5..c0d4040 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -708,7 +708,8 @@ static u8 *efx_tsoh_get_buffer(struct efx_tx_queue *tx_queue,
 			TSOH_STD_SIZE * (index % TSOH_PER_PAGE) + TSOH_OFFSET;
 
 		if (unlikely(!page_buf->addr) &&
-		    efx_nic_alloc_buffer(tx_queue->efx, page_buf, PAGE_SIZE))
+		    efx_nic_alloc_buffer(tx_queue->efx, page_buf, PAGE_SIZE,
+					 GFP_ATOMIC))
 			return NULL;
 
 		result = (u8 *)page_buf->addr + offset;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
