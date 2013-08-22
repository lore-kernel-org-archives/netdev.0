From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH RESEND net-next 13/16] sfc: Move siena_reset_hw() and
 siena_map_reset_reason() into MCDI module
Date: Thu, 22 Aug 2013 20:29:06 +0100
Message-ID: <1377199746.1703.62.camel@bwh-desktop.uk.level5networks.com>
References: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29897 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454Ab3HVT3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 15:29:09 -0400
In-Reply-To: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These implementations should work for EF10 too.  Rename them
accordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c  | 24 ++++++++++++++++++++++--
 drivers/net/ethernet/sfc/mcdi.h  |  4 ++--
 drivers/net/ethernet/sfc/siena.c | 33 ++++++---------------------------
 3 files changed, 30 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 3f55b16..4781e02 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1087,7 +1087,7 @@ void efx_mcdi_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
 			  __func__, rc);
 }
 
-int efx_mcdi_reset_port(struct efx_nic *efx)
+static int efx_mcdi_reset_port(struct efx_nic *efx)
 {
 	int rc = efx_mcdi_rpc(efx, MC_CMD_ENTITY_RESET, NULL, 0, NULL, 0, NULL);
 	if (rc)
@@ -1096,7 +1096,7 @@ int efx_mcdi_reset_port(struct efx_nic *efx)
 	return rc;
 }
 
-int efx_mcdi_reset_mc(struct efx_nic *efx)
+static int efx_mcdi_reset_mc(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_REBOOT_IN_LEN);
 	int rc;
@@ -1114,6 +1114,26 @@ int efx_mcdi_reset_mc(struct efx_nic *efx)
 	return rc;
 }
 
+enum reset_type efx_mcdi_map_reset_reason(enum reset_type reason)
+{
+	return RESET_TYPE_RECOVER_OR_ALL;
+}
+
+int efx_mcdi_reset(struct efx_nic *efx, enum reset_type method)
+{
+	int rc;
+
+	/* Recover from a failed assertion pre-reset */
+	rc = efx_mcdi_handle_assertion(efx);
+	if (rc)
+		return rc;
+
+	if (method == RESET_TYPE_WORLD)
+		return efx_mcdi_reset_mc(efx);
+	else
+		return efx_mcdi_reset_port(efx);
+}
+
 static int efx_mcdi_wol_filter_set(struct efx_nic *efx, u32 type,
 				   const u8 *mac, int *id_out)
 {
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 899f094..e62dc04 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -190,8 +190,6 @@ extern int efx_mcdi_nvram_update_finish(struct efx_nic *efx,
 extern int efx_mcdi_nvram_test_all(struct efx_nic *efx);
 extern int efx_mcdi_handle_assertion(struct efx_nic *efx);
 extern void efx_mcdi_set_id_led(struct efx_nic *efx, enum efx_led_mode mode);
-extern int efx_mcdi_reset_port(struct efx_nic *efx);
-extern int efx_mcdi_reset_mc(struct efx_nic *efx);
 extern int efx_mcdi_wol_filter_set_magic(struct efx_nic *efx,
 					 const u8 *mac, int *id_out);
 extern int efx_mcdi_wol_filter_get_magic(struct efx_nic *efx, int *id_out);
@@ -203,6 +201,8 @@ extern int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 			      u32 dma_len, int enable, int clear);
 extern int efx_mcdi_mac_reconfigure(struct efx_nic *efx);
 extern bool efx_mcdi_mac_check_fault(struct efx_nic *efx);
+extern enum reset_type efx_mcdi_map_reset_reason(enum reset_type reason);
+extern int efx_mcdi_reset(struct efx_nic *efx, enum reset_type method);
 
 #ifdef CONFIG_SFC_MCDI_MON
 extern int efx_mcdi_mon_probe(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 8c91775..6babc8e 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -30,7 +30,6 @@
 /* Hardware control for SFC9000 family including SFL9021 (aka Siena). */
 
 static void siena_init_wol(struct efx_nic *efx);
-static int siena_reset_hw(struct efx_nic *efx, enum reset_type method);
 

 static void siena_push_irq_moderation(struct efx_channel *channel)
@@ -178,7 +177,7 @@ static int siena_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 	/* Reset the chip immediately so that it is completely
 	 * quiescent regardless of what any VF driver does.
 	 */
-	rc = siena_reset_hw(efx, reset_method);
+	rc = efx_mcdi_reset(efx, reset_method);
 	if (rc)
 		goto out;
 
@@ -187,7 +186,7 @@ static int siena_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 				       ARRAY_SIZE(siena_register_tests))
 		? -1 : 1;
 
-	rc = siena_reset_hw(efx, reset_method);
+	rc = efx_mcdi_reset(efx, reset_method);
 out:
 	rc2 = efx_reset_up(efx, reset_method, rc == 0);
 	return rc ? rc : rc2;
@@ -200,11 +199,6 @@ out:
  **************************************************************************
  */
 
-static enum reset_type siena_map_reset_reason(enum reset_type reason)
-{
-	return RESET_TYPE_RECOVER_OR_ALL;
-}
-
 static int siena_map_reset_flags(u32 *flags)
 {
 	enum {
@@ -230,21 +224,6 @@ static int siena_map_reset_flags(u32 *flags)
 	return -EINVAL;
 }
 
-static int siena_reset_hw(struct efx_nic *efx, enum reset_type method)
-{
-	int rc;
-
-	/* Recover from a failed assertion pre-reset */
-	rc = efx_mcdi_handle_assertion(efx);
-	if (rc)
-		return rc;
-
-	if (method == RESET_TYPE_WORLD)
-		return efx_mcdi_reset_mc(efx);
-	else
-		return efx_mcdi_reset_port(efx);
-}
-
 #ifdef CONFIG_EEH
 /* When a PCI device is isolated from the bus, a subsequent MMIO read is
  * required for the kernel EEH mechanisms to notice. As the Solarflare driver
@@ -327,7 +306,7 @@ static int siena_probe_nic(struct efx_nic *efx)
 			  "Host already registered with MCPU\n");
 
 	/* Now we can reset the NIC */
-	rc = siena_reset_hw(efx, RESET_TYPE_ALL);
+	rc = efx_mcdi_reset(efx, RESET_TYPE_ALL);
 	if (rc) {
 		netif_err(efx, probe, efx->net_dev, "failed to reset NIC\n");
 		goto fail3;
@@ -458,7 +437,7 @@ static void siena_remove_nic(struct efx_nic *efx)
 
 	efx_nic_free_buffer(efx, &efx->irq_status);
 
-	siena_reset_hw(efx, RESET_TYPE_ALL);
+	efx_mcdi_reset(efx, RESET_TYPE_ALL);
 
 	/* Relinquish the device back to the BMC */
 	efx_mcdi_drv_attach(efx, false, NULL);
@@ -688,9 +667,9 @@ const struct efx_nic_type siena_a0_nic_type = {
 #else
 	.monitor = NULL,
 #endif
-	.map_reset_reason = siena_map_reset_reason,
+	.map_reset_reason = efx_mcdi_map_reset_reason,
 	.map_reset_flags = siena_map_reset_flags,
-	.reset = siena_reset_hw,
+	.reset = efx_mcdi_reset,
 	.probe_port = siena_probe_port,
 	.remove_port = siena_remove_port,
 	.prepare_flush = siena_prepare_flush,


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
