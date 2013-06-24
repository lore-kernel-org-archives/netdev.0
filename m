From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/9] sfc: Fix EEH with legacy interrupts.
Date: Mon, 24 Jun 2013 21:12:45 +0100
Message-ID: <1372104765.1896.30.camel@bwh-desktop.uk.level5networks.com>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17269 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab3FXUMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 16:12:49 -0400
In-Reply-To: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre Rames <arames@solarflare.com>

PCI legacy interrupts are level-triggered, and we cannot mask them up
on an isolated device.  Instead, disable the IRQ at the controller
until we have recovered.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |  7 ++++++-
 drivers/net/ethernet/sfc/efx.h        |  1 +
 drivers/net/ethernet/sfc/net_driver.h |  1 +
 drivers/net/ethernet/sfc/nic.c        | 10 ++++++++++
 4 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 46cc11d..787c9eb 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -23,6 +23,7 @@
 #include <linux/gfp.h>
 #include <linux/cpu_rmap.h>
 #include <linux/aer.h>
+#include <linux/interrupt.h>
 #include "net_driver.h"
 #include "efx.h"
 #include "nic.h"
@@ -1427,6 +1428,10 @@ static void efx_start_interrupts(struct efx_nic *efx, bool may_keep_eventq)
 
 	BUG_ON(efx->state == STATE_DISABLED);
 
+	if (efx->eeh_disabled_legacy_irq) {
+		enable_irq(efx->legacy_irq);
+		efx->eeh_disabled_legacy_irq = false;
+	}
 	if (efx->legacy_irq)
 		efx->legacy_irq_enabled = true;
 	efx_nic_enable_interrupts(efx);
@@ -2365,7 +2370,7 @@ out:
  * Returns 0 if the recovery mechanisms are unsuccessful.
  * Returns a non-zero value otherwise.
  */
-static int efx_try_recovery(struct efx_nic *efx)
+int efx_try_recovery(struct efx_nic *efx)
 {
 #ifdef CONFIG_EEH
 	/* A PCI error can occur and not be seen by EEH because nothing
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 8372da2..bdb30bb 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -124,6 +124,7 @@ extern const struct ethtool_ops efx_ethtool_ops;
 extern int efx_reset(struct efx_nic *efx, enum reset_type method);
 extern void efx_reset_down(struct efx_nic *efx, enum reset_type method);
 extern int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok);
+extern int efx_try_recovery(struct efx_nic *efx);
 
 /* Global */
 extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 9a2914c..2dec48b 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -788,6 +788,7 @@ struct efx_nic {
 	const struct efx_nic_type *type;
 	int legacy_irq;
 	bool legacy_irq_enabled;
+	bool eeh_disabled_legacy_irq;
 	struct workqueue_struct *workqueue;
 	char workqueue_name[16];
 	struct work_struct reset_work;
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index b0503cd..39432d3 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -1579,6 +1579,16 @@ static irqreturn_t efx_legacy_interrupt(int irq, void *dev_id)
 	efx_readd(efx, &reg, FR_BZ_INT_ISR0);
 	queues = EFX_EXTRACT_DWORD(reg, 0, 31);
 
+	/* Legacy interrupts are disabled too late by the EEH kernel
+	 * code. Disable them earlier.
+	 * If an EEH error occurred, the read will have returned all ones.
+	 */
+	if (EFX_DWORD_IS_ALL_ONES(reg) && efx_try_recovery(efx) &&
+	    !efx->eeh_disabled_legacy_irq) {
+		disable_irq_nosync(efx->legacy_irq);
+		efx->eeh_disabled_legacy_irq = true;
+	}
+
 	/* Handle non-event-queue sources */
 	if (queues & (1U << efx->irq_level)) {
 		syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
