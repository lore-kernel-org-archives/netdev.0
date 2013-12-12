From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/16] sfc: Add MC BISTs to ethtool offline self
 test on EF10
Date: Thu, 12 Dec 2013 22:59:56 +0000
Message-ID: <1386889196.1516.340.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43700 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab3LLXAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:00:00 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

To run BISTs the MC goes down in to a special mode where it will only
respond to MCDI from the testing PF, and TX, RX and event queues are
torn down. Other PFs get a message as it goes down to tell them it's
going down.

When the other PFs get this message, they check the soft status
register to tell when the MC has rebooted after BIST mode and they can
start recovery.

[bwh: Convert the test result to 1 or -1 as for earlier NICs]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 84 ++++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/sfc/efx.c        | 29 ++++++++++++
 drivers/net/ethernet/sfc/enum.h       |  1 +
 drivers/net/ethernet/sfc/ethtool.c    |  2 +
 drivers/net/ethernet/sfc/mcdi.c       | 34 ++++++++++++++
 drivers/net/ethernet/sfc/net_driver.h |  1 +
 drivers/net/ethernet/sfc/selftest.c   |  2 +-
 drivers/net/ethernet/sfc/selftest.h   |  1 +
 8 files changed, 152 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 676c3c057bfb..5d46d155b642 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -14,6 +14,7 @@
 #include "mcdi_pcol.h"
 #include "nic.h"
 #include "workarounds.h"
+#include "selftest.h"
 #include <linux/in.h>
 #include <linux/jhash.h>
 #include <linux/wait.h>
@@ -3195,6 +3196,87 @@ static int efx_ef10_mac_reconfigure(struct efx_nic *efx)
 	return efx_mcdi_set_mac(efx);
 }
 
+static int efx_ef10_start_bist(struct efx_nic *efx, u32 bist_type)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_START_BIST_IN_LEN);
+
+	MCDI_SET_DWORD(inbuf, START_BIST_IN_TYPE, bist_type);
+	return efx_mcdi_rpc(efx, MC_CMD_START_BIST, inbuf, sizeof(inbuf),
+			    NULL, 0, NULL);
+}
+
+/* MC BISTs follow a different poll mechanism to phy BISTs.
+ * The BIST is done in the poll handler on the MC, and the MCDI command
+ * will block until the BIST is done.
+ */
+static int efx_ef10_poll_bist(struct efx_nic *efx)
+{
+	int rc;
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_POLL_BIST_OUT_LEN);
+	size_t outlen;
+	u32 result;
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_POLL_BIST, NULL, 0,
+			   outbuf, sizeof(outbuf), &outlen);
+	if (rc != 0)
+		return rc;
+
+	if (outlen < MC_CMD_POLL_BIST_OUT_LEN)
+		return -EIO;
+
+	result = MCDI_DWORD(outbuf, POLL_BIST_OUT_RESULT);
+	switch (result) {
+	case MC_CMD_POLL_BIST_PASSED:
+		netif_dbg(efx, hw, efx->net_dev, "BIST passed.\n");
+		return 0;
+	case MC_CMD_POLL_BIST_TIMEOUT:
+		netif_err(efx, hw, efx->net_dev, "BIST timed out\n");
+		return -EIO;
+	case MC_CMD_POLL_BIST_FAILED:
+		netif_err(efx, hw, efx->net_dev, "BIST failed.\n");
+		return -EIO;
+	default:
+		netif_err(efx, hw, efx->net_dev,
+			  "BIST returned unknown result %u", result);
+		return -EIO;
+	}
+}
+
+static int efx_ef10_run_bist(struct efx_nic *efx, u32 bist_type)
+{
+	int rc;
+
+	netif_dbg(efx, drv, efx->net_dev, "starting BIST type %u\n", bist_type);
+
+	rc = efx_ef10_start_bist(efx, bist_type);
+	if (rc != 0)
+		return rc;
+
+	return efx_ef10_poll_bist(efx);
+}
+
+static int
+efx_ef10_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
+{
+	int rc, rc2;
+
+	efx_reset_down(efx, RESET_TYPE_WORLD);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_ENABLE_OFFLINE_BIST,
+			  NULL, 0, NULL, 0, NULL);
+	if (rc != 0)
+		goto out;
+
+	tests->memory = efx_ef10_run_bist(efx, MC_CMD_MC_MEM_BIST) ? -1 : 1;
+	tests->registers = efx_ef10_run_bist(efx, MC_CMD_REG_BIST) ? -1 : 1;
+
+	rc = efx_mcdi_reset(efx, RESET_TYPE_WORLD);
+
+out:
+	rc2 = efx_reset_up(efx, RESET_TYPE_WORLD, rc == 0);
+	return rc ? rc : rc2;
+}
+
 #ifdef CONFIG_SFC_MTD
 
 struct efx_ef10_nvram_type_info {
@@ -3345,7 +3427,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.get_wol = efx_ef10_get_wol,
 	.set_wol = efx_ef10_set_wol,
 	.resume_wol = efx_port_dummy_op_void,
-	/* TODO: test_chip */
+	.test_chip = efx_ef10_test_chip,
 	.test_nvram = efx_mcdi_nvram_test_all,
 	.mcdi_request = efx_ef10_mcdi_request,
 	.mcdi_poll_response = efx_ef10_mcdi_poll_response,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index a35c63d43ae5..869418164364 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -83,6 +83,7 @@ const char *const efx_reset_type_names[] = {
 	[RESET_TYPE_DMA_ERROR]          = "DMA_ERROR",
 	[RESET_TYPE_TX_SKIP]            = "TX_SKIP",
 	[RESET_TYPE_MC_FAILURE]         = "MC_FAILURE",
+	[RESET_TYPE_MC_BIST]		= "MC_BIST",
 };
 
 /* Reset workqueue. If any NIC has a hardware failure then a reset will be
@@ -91,6 +92,12 @@ const char *const efx_reset_type_names[] = {
  */
 static struct workqueue_struct *reset_workqueue;
 
+/* How often and how many times to poll for a reset while waiting for a
+ * BIST that another function started to complete.
+ */
+#define BIST_WAIT_DELAY_MS	100
+#define BIST_WAIT_DELAY_COUNT	100
+
 /**************************************************************************
  *
  * Configurable values
@@ -2389,6 +2396,24 @@ int efx_try_recovery(struct efx_nic *efx)
 	return 0;
 }
 
+static void efx_wait_for_bist_end(struct efx_nic *efx)
+{
+	int i;
+
+	for (i = 0; i < BIST_WAIT_DELAY_COUNT; ++i) {
+		if (efx_mcdi_poll_reboot(efx))
+			goto out;
+		msleep(BIST_WAIT_DELAY_MS);
+	}
+
+	netif_err(efx, drv, efx->net_dev, "Warning: No MC reboot after BIST mode\n");
+out:
+	/* Either way unset the BIST flag. If we found no reboot we probably
+	 * won't recover, but we should try.
+	 */
+	efx->mc_bist_for_other_fn = false;
+}
+
 /* The worker thread exists so that code that cannot sleep can
  * schedule a reset for later.
  */
@@ -2401,6 +2426,9 @@ static void efx_reset_work(struct work_struct *data)
 	pending = ACCESS_ONCE(efx->reset_pending);
 	method = fls(pending) - 1;
 
+	if (method == RESET_TYPE_MC_BIST)
+		efx_wait_for_bist_end(efx);
+
 	if ((method == RESET_TYPE_RECOVER_OR_DISABLE ||
 	     method == RESET_TYPE_RECOVER_OR_ALL) &&
 	    efx_try_recovery(efx))
@@ -2439,6 +2467,7 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 	case RESET_TYPE_WORLD:
 	case RESET_TYPE_DISABLE:
 	case RESET_TYPE_RECOVER_OR_DISABLE:
+	case RESET_TYPE_MC_BIST:
 		method = type;
 		netif_dbg(efx, drv, efx->net_dev, "scheduling %s reset\n",
 			  RESET_TYPE(method));
diff --git a/drivers/net/ethernet/sfc/enum.h b/drivers/net/ethernet/sfc/enum.h
index 7fdfee019092..75ef7ef6450b 100644
--- a/drivers/net/ethernet/sfc/enum.h
+++ b/drivers/net/ethernet/sfc/enum.h
@@ -165,6 +165,7 @@ enum reset_type {
 	RESET_TYPE_DMA_ERROR,
 	RESET_TYPE_TX_SKIP,
 	RESET_TYPE_MC_FAILURE,
+	RESET_TYPE_MC_BIST,
 	RESET_TYPE_MAX,
 };
 
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 1f529fa2edb1..fb8993806167 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -318,6 +318,8 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 			      "eventq.int", NULL);
 	}
 
+	efx_fill_test(n++, strings, data, &tests->memory,
+		      "core", 0, "memory", NULL);
 	efx_fill_test(n++, strings, data, &tests->registers,
 		      "core", 0, "registers", NULL);
 
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 25f91c0ca6a6..da14e2428944 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -543,6 +543,9 @@ int efx_mcdi_rpc_start(struct efx_nic *efx, unsigned cmd,
 	if (rc)
 		return rc;
 
+	if (efx->mc_bist_for_other_fn)
+		return -ENETDOWN;
+
 	efx_mcdi_acquire_sync(mcdi);
 	efx_mcdi_send_request(efx, cmd, inbuf, inlen);
 	return 0;
@@ -581,6 +584,9 @@ efx_mcdi_rpc_async(struct efx_nic *efx, unsigned int cmd,
 	if (rc)
 		return rc;
 
+	if (efx->mc_bist_for_other_fn)
+		return -ENETDOWN;
+
 	async = kmalloc(sizeof(*async) + ALIGN(max(inlen, outlen), 4),
 			GFP_ATOMIC);
 	if (!async)
@@ -834,6 +840,30 @@ static void efx_mcdi_ev_death(struct efx_nic *efx, int rc)
 	spin_unlock(&mcdi->iface_lock);
 }
 
+/* The MC is going down in to BIST mode. set the BIST flag to block
+ * new MCDI, cancel any outstanding MCDI and and schedule a BIST-type reset
+ * (which doesn't actually execute a reset, it waits for the controlling
+ * function to reset it).
+ */
+static void efx_mcdi_ev_bist(struct efx_nic *efx)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+
+	spin_lock(&mcdi->iface_lock);
+	efx->mc_bist_for_other_fn = true;
+	if (efx_mcdi_complete_sync(mcdi)) {
+		if (mcdi->mode == MCDI_MODE_EVENTS) {
+			mcdi->resprc = -EIO;
+			mcdi->resp_hdr_len = 0;
+			mcdi->resp_data_len = 0;
+			++mcdi->credits;
+		}
+	}
+	mcdi->new_epoch = true;
+	efx_schedule_reset(efx, RESET_TYPE_MC_BIST);
+	spin_unlock(&mcdi->iface_lock);
+}
+
 /* Called from  falcon_process_eventq for MCDI events */
 void efx_mcdi_process_event(struct efx_channel *channel,
 			    efx_qword_t *event)
@@ -875,6 +905,10 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 		netif_info(efx, hw, efx->net_dev, "MC Reboot\n");
 		efx_mcdi_ev_death(efx, -EIO);
 		break;
+	case MCDI_EVENT_CODE_MC_BIST:
+		netif_info(efx, hw, efx->net_dev, "MC entered BIST mode\n");
+		efx_mcdi_ev_bist(efx);
+		break;
 	case MCDI_EVENT_CODE_MAC_STATS_DMA:
 		/* MAC stats are gather lazily.  We can ignore this. */
 		break;
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 542a0d252ae0..d98b3f031ab5 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -852,6 +852,7 @@ struct efx_nic {
 	struct work_struct mac_work;
 	bool port_enabled;
 
+	bool mc_bist_for_other_fn;
 	bool port_initialized;
 	struct net_device *net_dev;
 
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index 144bbff5a4ae..26641817a9c7 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -722,7 +722,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 			return rc_reset;
 		}
 
-		if ((tests->registers < 0) && !rc_test)
+		if ((tests->memory < 0 || tests->registers < 0) && !rc_test)
 			rc_test = -EIO;
 	}
 
diff --git a/drivers/net/ethernet/sfc/selftest.h b/drivers/net/ethernet/sfc/selftest.h
index a2f4a06ffa4e..009dbe88f3be 100644
--- a/drivers/net/ethernet/sfc/selftest.h
+++ b/drivers/net/ethernet/sfc/selftest.h
@@ -38,6 +38,7 @@ struct efx_self_tests {
 	int eventq_dma[EFX_MAX_CHANNELS];
 	int eventq_int[EFX_MAX_CHANNELS];
 	/* offline tests */
+	int memory;
 	int registers;
 	int phy_ext[EFX_MAX_PHY_TESTS];
 	struct efx_loopback_self_tests loopback[LOOPBACK_TEST_MAX + 1];


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
