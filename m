From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 1/1] sfc: MC allocations must be restored following
 an entity reset
Date: Fri, 31 Jul 2015 11:15:22 +0100
Message-ID: <55BB4ABA.3080005@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:39843 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751069AbbGaKP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 06:15:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 7e2e206..06b8061 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -991,12 +991,24 @@ static int efx_ef10_init_nic(struct efx_nic *efx)
 static void efx_ef10_reset_mc_allocations(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+#ifdef CONFIG_SFC_SRIOV
+	unsigned int i;
+#endif
 
 	/* All our allocations have been reset */
 	nic_data->must_realloc_vis = true;
 	nic_data->must_restore_filters = true;
 	nic_data->must_restore_piobufs = true;
 	nic_data->rx_rss_context = EFX_EF10_RSS_CONTEXT_INVALID;
+
+	/* Driver-created vswitches and vports must be re-created */
+	nic_data->must_probe_vswitching = true;
+	nic_data->vport_id = EVB_PORT_ID_ASSIGNED;
+#ifdef CONFIG_SFC_SRIOV
+	if (nic_data->vf)
+		for (i = 0; i < efx->vf_count; i++)
+			nic_data->vf[i].vport_id = 0;
+#endif
 }
 
 static enum reset_type efx_ef10_map_reset_reason(enum reset_type reason)
@@ -1571,10 +1583,6 @@ static int efx_ef10_mcdi_poll_reboot(struct efx_nic *efx)
 	/* All our allocations have been reset */
 	efx_ef10_reset_mc_allocations(efx);
 
-	/* Driver-created vswitches and vports must be re-created */
-	nic_data->must_probe_vswitching = true;
-	nic_data->vport_id = EVB_PORT_ID_ASSIGNED;
-
 	/* The datapath firmware might have been changed */
 	nic_data->must_check_datapath_caps = true;
 
