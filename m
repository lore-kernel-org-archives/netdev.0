From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net] Call efx_set_channels() before efx->type->dimension_resources()
Date: Tue, 1 Apr 2014 13:10:34 +0100
Message-ID: <533AACBA.3020807@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35829 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbaDAMKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 08:10:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

When using the "separate_tx_channels=1" module parameter, the TX queues are
initially numbered starting from the first TX-only channel number (after all the
RX-only channels).  efx_set_channels() renumbers the queues so that they are
indexed from zero.

On EF10, the TX queues need to be relabelled in this way before calling the
dimension_resources NIC type operation, otherwise the TX queue PIO buffers can be
linked to the wrong VIs when using "separate_tx_channels=1".

Added comments to explain UC/WC mappings for PIO buffers

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
This bug fix is needed for all versions supporting EF10
i.e all versions including and after 3.12.
---
 drivers/net/ethernet/sfc/ef10.c |    7 +++++++
 drivers/net/ethernet/sfc/efx.c  |    3 ++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 174a92f..7645a3c 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -565,10 +565,17 @@ static int efx_ef10_dimension_resources(struct efx_nic *efx)
 	 * several of each (in fact that's the only option if host
 	 * page size is >4K).  So we may allocate some extra VIs just
 	 * for writing PIO buffers through.
+	 *
+	 * The UC mapping contains (min_vis - 1) complete VIs and the
+	 * first half of the next VI.  Then the WC mapping begins with
+	 * the second half of this last VI.
 	 */
 	uc_mem_map_size = PAGE_ALIGN((min_vis - 1) * EFX_VI_PAGE_SIZE +
 				     ER_DZ_TX_PIOBUF);
 	if (nic_data->n_piobufs) {
+		/* pio_write_vi_base rounds down to give the number of complete
+		 * VIs inside the UC mapping.
+		 */
 		pio_write_vi_base = uc_mem_map_size / EFX_VI_PAGE_SIZE;
 		wc_mem_map_size = (PAGE_ALIGN((pio_write_vi_base +
 					       nic_data->n_piobufs) *
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 83d4643..f06c790 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1603,6 +1603,8 @@ static int efx_probe_nic(struct efx_nic *efx)
 	if (rc)
 		goto fail1;
 
+	efx_set_channels(efx);
+
 	rc = efx->type->dimension_resources(efx);
 	if (rc)
 		goto fail2;
@@ -1613,7 +1615,6 @@ static int efx_probe_nic(struct efx_nic *efx)
 		efx->rx_indir_table[i] =
 			ethtool_rxfh_indir_default(i, efx->rss_spread);
 
-	efx_set_channels(efx);
 	netif_set_real_num_tx_queues(efx->net_dev, efx->n_tx_channels);
 	netif_set_real_num_rx_queues(efx->net_dev, efx->n_rx_channels);
 
