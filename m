From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 12/16] sfc: Change entity reset on MC reboot to
 a new datapath-only reset.
Date: Wed, 20 May 2015 11:11:35 +0100
Message-ID: <555C5DD7.60409@solarflare.com>
References: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:3538 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752009AbbETKLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:11:42 -0400
In-Reply-To: <555C5C91.4000004@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Currently we do an entity reset when we detect an MC reboot.
This messes up SRIOV because it leaves VFs orphaned. The extra
reset is rather redundant anyway, since the MC reboot will have
basically reset everything.

This change replaces the entity reset after MC reboot with a
simpler datapath reset that reallocates resources but doesn't
perform the entity reset.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 12 ++++++++++--
 drivers/net/ethernet/sfc/efx.c  |  8 ++++++--
 drivers/net/ethernet/sfc/enum.h |  2 ++
 drivers/net/ethernet/sfc/mcdi.c |  4 +++-
 4 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index e8d760c..525808f 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -866,6 +866,14 @@ static void efx_ef10_reset_mc_allocations(struct efx_nic *efx)
 	nic_data->rx_rss_context = EFX_EF10_RSS_CONTEXT_INVALID;
 }
 
+static enum reset_type efx_ef10_map_reset_reason(enum reset_type reason)
+{
+	if (reason == RESET_TYPE_MC_FAILURE)
+		return RESET_TYPE_DATAPATH;
+
+	return efx_mcdi_map_reset_reason(reason);
+}
+
 static int efx_ef10_map_reset_flags(u32 *flags)
 {
 	enum {
@@ -3940,7 +3948,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.dimension_resources = efx_ef10_dimension_resources,
 	.init = efx_ef10_init_nic,
 	.fini = efx_port_dummy_op_void,
-	.map_reset_reason = efx_mcdi_map_reset_reason,
+	.map_reset_reason = efx_ef10_map_reset_reason,
 	.map_reset_flags = efx_ef10_map_reset_flags,
 	.reset = efx_ef10_reset,
 	.probe_port = efx_mcdi_port_probe,
@@ -4040,7 +4048,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.dimension_resources = efx_ef10_dimension_resources,
 	.init = efx_ef10_init_nic,
 	.fini = efx_port_dummy_op_void,
-	.map_reset_reason = efx_mcdi_map_reset_reason,
+	.map_reset_reason = efx_ef10_map_reset_reason,
 	.map_reset_flags = efx_ef10_map_reset_flags,
 	.reset = efx_ef10_reset,
 	.probe_port = efx_mcdi_port_probe,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index abb9c0e..0ca6e77 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -77,6 +77,7 @@ const char *const efx_reset_type_names[] = {
 	[RESET_TYPE_RECOVER_OR_ALL]     = "RECOVER_OR_ALL",
 	[RESET_TYPE_WORLD]              = "WORLD",
 	[RESET_TYPE_RECOVER_OR_DISABLE] = "RECOVER_OR_DISABLE",
+	[RESET_TYPE_DATAPATH]           = "DATAPATH",
 	[RESET_TYPE_MC_BIST]		= "MC_BIST",
 	[RESET_TYPE_DISABLE]            = "DISABLE",
 	[RESET_TYPE_TX_WATCHDOG]        = "TX_WATCHDOG",
@@ -2430,7 +2431,8 @@ void efx_reset_down(struct efx_nic *efx, enum reset_type method)
 	efx_disable_interrupts(efx);
 
 	mutex_lock(&efx->mac_lock);
-	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE)
+	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE &&
+	    method != RESET_TYPE_DATAPATH)
 		efx->phy_op->fini(efx);
 	efx->type->fini(efx);
 }
@@ -2459,7 +2461,8 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 	if (!ok)
 		goto fail;
 
-	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE) {
+	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE &&
+	    method != RESET_TYPE_DATAPATH) {
 		rc = efx->phy_op->init(efx);
 		if (rc)
 			goto fail;
@@ -2655,6 +2658,7 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 	case RESET_TYPE_WORLD:
 	case RESET_TYPE_DISABLE:
 	case RESET_TYPE_RECOVER_OR_DISABLE:
+	case RESET_TYPE_DATAPATH:
 	case RESET_TYPE_MC_BIST:
 	case RESET_TYPE_MCDI_TIMEOUT:
 		method = type;
diff --git a/drivers/net/ethernet/sfc/enum.h b/drivers/net/ethernet/sfc/enum.h
index d1dbb5f..c94f562 100644
--- a/drivers/net/ethernet/sfc/enum.h
+++ b/drivers/net/ethernet/sfc/enum.h
@@ -143,6 +143,7 @@ enum efx_loopback_mode {
  * @RESET_TYPE_WORLD: Reset as much as possible
  * @RESET_TYPE_RECOVER_OR_DISABLE: Try to recover. Apply RESET_TYPE_DISABLE if
  * unsuccessful.
+ * @RESET_TYPE_DATAPATH: Reset datapath only.
  * @RESET_TYPE_MC_BIST: MC entering BIST mode.
  * @RESET_TYPE_DISABLE: Reset datapath, MAC and PHY; leave NIC disabled
  * @RESET_TYPE_TX_WATCHDOG: reset due to TX watchdog
@@ -159,6 +160,7 @@ enum reset_type {
 	RESET_TYPE_ALL,
 	RESET_TYPE_WORLD,
 	RESET_TYPE_RECOVER_OR_DISABLE,
+	RESET_TYPE_DATAPATH,
 	RESET_TYPE_MC_BIST,
 	RESET_TYPE_DISABLE,
 	RESET_TYPE_MAX_METHOD,
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index fcee761..8267a1c 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1558,7 +1558,9 @@ int efx_mcdi_reset(struct efx_nic *efx, enum reset_type method)
 	if (rc)
 		return rc;
 
-	if (method == RESET_TYPE_WORLD)
+	if (method == RESET_TYPE_DATAPATH)
+		return 0;
+	else if (method == RESET_TYPE_WORLD)
 		return efx_mcdi_reset_mc(efx);
 	else
 		return efx_mcdi_reset_func(efx);
