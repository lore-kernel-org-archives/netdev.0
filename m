From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 3/3] sfc: work around TRIGGER_INTERRUPT command not
 working on SFC9140
Date: Fri, 26 Aug 2016 15:13:30 +0100
Message-ID: <0d4f51ce-9073-22d9-2ca1-2fdc8c2c5d59@solarflare.com>
References: <da7f8a31-f24c-7727-7d78-67572f5494d5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:53871 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751997AbcHZOT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 10:19:58 -0400
In-Reply-To: <da7f8a31-f24c-7727-7d78-67572f5494d5@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

MC_CMD_TRIGGER_INTERRUPT does not work on the SFC9140, as used in the
sfn7x42q and sfn7x24f.
Check for this using the MCDI workaround mechanism.
The command is only used during self test.  If it's not supported, skip
the interrupt test.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  8 ++++++--
 drivers/net/ethernet/sfc/farch.c      |  3 ++-
 drivers/net/ethernet/sfc/net_driver.h |  2 +-
 drivers/net/ethernet/sfc/nic.c        |  4 ++--
 drivers/net/ethernet/sfc/nic.h        |  4 ++--
 drivers/net/ethernet/sfc/selftest.c   | 10 +++++++++-
 drivers/net/ethernet/sfc/selftest.h   |  2 +-
 7 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index c4cd6b0..6fe1d0b 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2048,14 +2048,18 @@ static irqreturn_t efx_ef10_legacy_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static void efx_ef10_irq_test_generate(struct efx_nic *efx)
+static int efx_ef10_irq_test_generate(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_TRIGGER_INTERRUPT_IN_LEN);
 
+	if (efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG41750, true,
+				    NULL) == 0)
+		return -ENOTSUPP;
+
 	BUILD_BUG_ON(MC_CMD_TRIGGER_INTERRUPT_OUT_LEN != 0);
 
 	MCDI_SET_DWORD(inbuf, TRIGGER_INTERRUPT_IN_INTR_LEVEL, efx->irq_level);
-	(void) efx_mcdi_rpc(efx, MC_CMD_TRIGGER_INTERRUPT,
+	return efx_mcdi_rpc(efx, MC_CMD_TRIGGER_INTERRUPT,
 			    inbuf, sizeof(inbuf), NULL, 0, NULL);
 }
 
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 4c83739..4762ec4 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -1477,9 +1477,10 @@ void efx_farch_irq_disable_master(struct efx_nic *efx)
  * Interrupt must already have been enabled, otherwise nasty things
  * may happen.
  */
-void efx_farch_irq_test_generate(struct efx_nic *efx)
+int efx_farch_irq_test_generate(struct efx_nic *efx)
 {
 	efx_farch_interrupts(efx, true, true);
+	return 0;
 }
 
 /* Process a fatal interrupt
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 13b7f52..0a2504b 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1275,7 +1275,7 @@ struct efx_nic_type {
 	int (*mcdi_poll_reboot)(struct efx_nic *efx);
 	void (*mcdi_reboot_detected)(struct efx_nic *efx);
 	void (*irq_enable_master)(struct efx_nic *efx);
-	void (*irq_test_generate)(struct efx_nic *efx);
+	int (*irq_test_generate)(struct efx_nic *efx);
 	void (*irq_disable_non_ev)(struct efx_nic *efx);
 	irqreturn_t (*irq_handle_msi)(int irq, void *dev_id);
 	irqreturn_t (*irq_handle_legacy)(int irq, void *dev_id);
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 89b83e5..aa1945a 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -66,11 +66,11 @@ void efx_nic_event_test_start(struct efx_channel *channel)
 	channel->efx->type->ev_test_generate(channel);
 }
 
-void efx_nic_irq_test_start(struct efx_nic *efx)
+int efx_nic_irq_test_start(struct efx_nic *efx)
 {
 	efx->last_irq_cpu = -1;
 	smp_wmb();
-	efx->type->irq_test_generate(efx);
+	return efx->type->irq_test_generate(efx);
 }
 
 /* Hook interrupt handler(s)
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index d8b1694..73bee7e 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -746,12 +746,12 @@ static inline void efx_update_diff_stat(u64 *stat, u64 diff)
 
 /* Interrupts */
 int efx_nic_init_interrupt(struct efx_nic *efx);
-void efx_nic_irq_test_start(struct efx_nic *efx);
+int efx_nic_irq_test_start(struct efx_nic *efx);
 void efx_nic_fini_interrupt(struct efx_nic *efx);
 
 /* Falcon/Siena interrupts */
 void efx_farch_irq_enable_master(struct efx_nic *efx);
-void efx_farch_irq_test_generate(struct efx_nic *efx);
+int efx_farch_irq_test_generate(struct efx_nic *efx);
 void efx_farch_irq_disable_master(struct efx_nic *efx);
 irqreturn_t efx_farch_msi_interrupt(int irq, void *dev_id);
 irqreturn_t efx_farch_legacy_interrupt(int irq, void *dev_id);
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index 9d78830..cd38b44 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -135,11 +135,19 @@ static int efx_test_interrupts(struct efx_nic *efx,
 {
 	unsigned long timeout, wait;
 	int cpu;
+	int rc;
 
 	netif_dbg(efx, drv, efx->net_dev, "testing interrupts\n");
 	tests->interrupt = -1;
 
-	efx_nic_irq_test_start(efx);
+	rc = efx_nic_irq_test_start(efx);
+	if (rc == -ENOTSUPP) {
+		netif_dbg(efx, drv, efx->net_dev,
+			  "direct interrupt testing not supported\n");
+		tests->interrupt = 0;
+		return 0;
+	}
+
 	timeout = jiffies + IRQ_TIMEOUT;
 	wait = 1;
 
diff --git a/drivers/net/ethernet/sfc/selftest.h b/drivers/net/ethernet/sfc/selftest.h
index 009dbe8..32a4272 100644
--- a/drivers/net/ethernet/sfc/selftest.h
+++ b/drivers/net/ethernet/sfc/selftest.h
@@ -28,7 +28,7 @@ struct efx_loopback_self_tests {
 
 /* Efx self test results
  * For fields which are not counters, 1 indicates success and -1
- * indicates failure.
+ * indicates failure; 0 indicates test could not be run.
  */
 struct efx_self_tests {
 	/* online tests */
