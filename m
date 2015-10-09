From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 1/1] sfc: fully reset if MC_REBOOT event received
 without warm_boot_count increment
Date: Fri, 9 Oct 2015 10:40:35 +0100
Message-ID: <56178B93.6020205@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:27644 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755508AbbJIJmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 05:42:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

On EF10, MC_CMD_VPORT_RECONFIGURE can cause a CODE_MC_REBOOT event
to be sent to a function without incrementing the (adapter-wide)
warm_boot_count.  In this case, the reboot is not detected by the
loop on efx_mcdi_poll_reboot(), so prepare for recovery from an MC
reboot anyway.  When this codepath is run, the MC has always just
rebooted, so this recovery is valid.

The loop on efx_mcdi_poll_reboot() is still required for other MC
reboot cases, so that actions in response to an MC reboot are
performed, such as clearing locally calculated statistics.
Siena NICs are unaffected by this change as the above scenario
does not apply.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 30 +++++++++++++++++++-----------
 drivers/net/ethernet/sfc/mcdi.c       | 13 ++++++++++++-
 drivers/net/ethernet/sfc/net_driver.h |  1 +
 3 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index ff649eb..78b7b7b 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1604,6 +1604,22 @@ efx_ef10_mcdi_read_response(struct efx_nic *efx, efx_dword_t *outbuf,
 	memcpy(outbuf, pdu + offset, outlen);
 }
 
+static void efx_ef10_mcdi_reboot_detected(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+	/* All our allocations have been reset */
+	efx_ef10_reset_mc_allocations(efx);
+
+	/* The datapath firmware might have been changed */
+	nic_data->must_check_datapath_caps = true;
+
+	/* MAC statistics have been cleared on the NIC; clear the local
+	 * statistic that we update with efx_update_diff_stat().
+	 */
+	nic_data->stats[EF10_STAT_port_rx_bad_bytes] = 0;
+}
+
 static int efx_ef10_mcdi_poll_reboot(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
@@ -1623,17 +1639,7 @@ static int efx_ef10_mcdi_poll_reboot(struct efx_nic *efx)
 		return 0;
 
 	nic_data->warm_boot_count = rc;
-
-	/* All our allocations have been reset */
-	efx_ef10_reset_mc_allocations(efx);
-
-	/* The datapath firmware might have been changed */
-	nic_data->must_check_datapath_caps = true;
-
-	/* MAC statistics have been cleared on the NIC; clear the local
-	 * statistic that we update with efx_update_diff_stat().
-	 */
-	nic_data->stats[EF10_STAT_port_rx_bad_bytes] = 0;
+	efx_ef10_mcdi_reboot_detected(efx);
 
 	return -EIO;
 }
@@ -4670,6 +4676,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.mcdi_poll_response = efx_ef10_mcdi_poll_response,
 	.mcdi_read_response = efx_ef10_mcdi_read_response,
 	.mcdi_poll_reboot = efx_ef10_mcdi_poll_reboot,
+	.mcdi_reboot_detected = efx_ef10_mcdi_reboot_detected,
 	.irq_enable_master = efx_port_dummy_op_void,
 	.irq_test_generate = efx_ef10_irq_test_generate,
 	.irq_disable_non_ev = efx_port_dummy_op_void,
@@ -4774,6 +4781,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.mcdi_poll_response = efx_ef10_mcdi_poll_response,
 	.mcdi_read_response = efx_ef10_mcdi_read_response,
 	.mcdi_poll_reboot = efx_ef10_mcdi_poll_reboot,
+	.mcdi_reboot_detected = efx_ef10_mcdi_reboot_detected,
 	.irq_enable_master = efx_port_dummy_op_void,
 	.irq_test_generate = efx_ef10_irq_test_generate,
 	.irq_disable_non_ev = efx_port_dummy_op_void,
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 98d172b..d3f307e 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1028,10 +1028,21 @@ static void efx_mcdi_ev_death(struct efx_nic *efx, int rc)
 
 		/* Consume the status word since efx_mcdi_rpc_finish() won't */
 		for (count = 0; count < MCDI_STATUS_DELAY_COUNT; ++count) {
-			if (efx_mcdi_poll_reboot(efx))
+			rc = efx_mcdi_poll_reboot(efx);
+			if (rc)
 				break;
 			udelay(MCDI_STATUS_DELAY_US);
 		}
+
+		/* On EF10, a CODE_MC_REBOOT event can be received without the
+		 * reboot detection in efx_mcdi_poll_reboot() being triggered.
+		 * If zero was returned from the final call to
+		 * efx_mcdi_poll_reboot(), the MC reboot wasn't noticed but the
+		 * MC has definitely rebooted so prepare for the reset.
+		 */
+		if (!rc && efx->type->mcdi_reboot_detected)
+			efx->type->mcdi_reboot_detected(efx);
+
 		mcdi->new_epoch = true;
 
 		/* Nobody was waiting for an MCDI request, so trigger a reset */
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index c530e1c..ad56231 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1277,6 +1277,7 @@ struct efx_nic_type {
 	void (*mcdi_read_response)(struct efx_nic *efx, efx_dword_t *pdu,
 				   size_t pdu_offset, size_t pdu_len);
 	int (*mcdi_poll_reboot)(struct efx_nic *efx);
+	void (*mcdi_reboot_detected)(struct efx_nic *efx);
 	void (*irq_enable_master)(struct efx_nic *efx);
 	void (*irq_test_generate)(struct efx_nic *efx);
 	void (*irq_disable_non_ev)(struct efx_nic *efx);
