From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 1/2] sfc: Change efx_mcdi_reset_port to use ENTITY_RESET
 MC command.
Date: Fri, 17 Jan 2014 19:48:06 +0000
Message-ID: <52D988F6.1020609@solarflare.com>
References: <52D98860.4020402@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38218 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107AbaAQTsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 14:48:10 -0500
In-Reply-To: <52D98860.4020402@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

PORT_RESET MC command was NOP in the ef10 firmware hence we are using
ENTITY_RESET to make sure all resource allocations are reset.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c |   31 ++++++++++++++++++++++++++-----
 drivers/net/ethernet/sfc/mcdi.c |   14 +++++++++++---
 2 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 4dfc229..174a92f 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -683,6 +683,17 @@ static int efx_ef10_init_nic(struct efx_nic *efx)
 	return 0;
 }
 
+static void efx_ef10_reset_mc_allocations(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+	/* All our allocations have been reset */
+	nic_data->must_realloc_vis = true;
+	nic_data->must_restore_filters = true;
+	nic_data->must_restore_piobufs = true;
+	nic_data->rx_rss_context = EFX_EF10_RSS_CONTEXT_INVALID;
+}
+
 static int efx_ef10_map_reset_flags(u32 *flags)
 {
 	enum {
@@ -713,6 +724,19 @@ static int efx_ef10_map_reset_flags(u32 *flags)
 	return -EINVAL;
 }
 
+static int efx_ef10_reset(struct efx_nic *efx, enum reset_type reset_type)
+{
+	int rc = efx_mcdi_reset(efx, reset_type);
+
+	/* If it was a port reset, trigger reallocation of MC resources.
+	 * Note that on an MC reset nothing needs to be done now because we'll
+	 * detect the MC reset later and handle it then.
+	 */
+	if (reset_type == RESET_TYPE_ALL && !rc)
+		efx_ef10_reset_mc_allocations(efx);
+	return rc;
+}
+
 #define EF10_DMA_STAT(ext_name, mcdi_name)			\
 	[EF10_STAT_ ## ext_name] =				\
 	{ #ext_name, 64, 8 * MC_CMD_MAC_ ## mcdi_name }
@@ -1078,10 +1102,7 @@ static int efx_ef10_mcdi_poll_reboot(struct efx_nic *efx)
 	nic_data->warm_boot_count = rc;
 
 	/* All our allocations have been reset */
-	nic_data->must_realloc_vis = true;
-	nic_data->must_restore_filters = true;
-	nic_data->must_restore_piobufs = true;
-	nic_data->rx_rss_context = EFX_EF10_RSS_CONTEXT_INVALID;
+	efx_ef10_reset_mc_allocations(efx);
 
 	/* The datapath firmware might have been changed */
 	nic_data->must_check_datapath_caps = true;
@@ -3571,7 +3592,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.fini = efx_port_dummy_op_void,
 	.map_reset_reason = efx_mcdi_map_reset_reason,
 	.map_reset_flags = efx_ef10_map_reset_flags,
-	.reset = efx_mcdi_reset,
+	.reset = efx_ef10_reset,
 	.probe_port = efx_mcdi_port_probe,
 	.remove_port = efx_mcdi_port_remove,
 	.fini_dmaq = efx_ef10_fini_dmaq,
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 0d5d7b5..eb59abb 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1471,9 +1471,17 @@ void efx_mcdi_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
 			  NULL, 0, NULL);
 }
 
-static int efx_mcdi_reset_port(struct efx_nic *efx)
+static int efx_mcdi_reset_func(struct efx_nic *efx)
 {
-	return efx_mcdi_rpc(efx, MC_CMD_ENTITY_RESET, NULL, 0, NULL, 0, NULL);
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_ENTITY_RESET_IN_LEN);
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_ENTITY_RESET_OUT_LEN != 0);
+	MCDI_POPULATE_DWORD_1(inbuf, ENTITY_RESET_IN_FLAG,
+			      ENTITY_RESET_IN_FUNCTION_RESOURCE_RESET, 1);
+	rc = efx_mcdi_rpc(efx, MC_CMD_ENTITY_RESET, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	return rc;
 }
 
 static int efx_mcdi_reset_mc(struct efx_nic *efx)
@@ -1510,7 +1518,7 @@ int efx_mcdi_reset(struct efx_nic *efx, enum reset_type method)
 	if (method == RESET_TYPE_WORLD)
 		return efx_mcdi_reset_mc(efx);
 	else
-		return efx_mcdi_reset_port(efx);
+		return efx_mcdi_reset_func(efx);
 }
 
 static int efx_mcdi_wol_filter_set(struct efx_nic *efx, u32 type,
