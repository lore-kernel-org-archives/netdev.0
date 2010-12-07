From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 1/2] sfc: Fix crash in legacy onterrupt handler
 during ring reallocation
Date: Tue, 07 Dec 2010 21:42:26 +0000
Message-ID: <1291758146.21627.20.camel@bwh-desktop>
References: <1291758047.21627.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:41824 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954Ab0LGVma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 16:42:30 -0500
In-Reply-To: <1291758047.21627.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we are using a legacy interrupt, our IRQ may be shared and our
interrupt handler may be called even though interrupts are disabled on
the NIC. When we change ring sizes, we reallocate the event queue and
the interrupt handler may use an invalid pointer when called for
another device's interrupt.

Maintain a legacy_irq_enabled flag and test that at the top of the
interrupt handler.  Note that this problem results from the need to
work around broken INT_ISR0 reads, and does not affect the legacy
interrupt handler for Falcon A1.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   12 ++++++++++--
 drivers/net/sfc/net_driver.h |    2 ++
 drivers/net/sfc/nic.c        |    6 ++++++
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 05df20e..d06cb74 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -335,8 +335,10 @@ void efx_process_channel_now(struct efx_channel *channel)
 
 	/* Disable interrupts and wait for ISRs to complete */
 	efx_nic_disable_interrupts(efx);
-	if (efx->legacy_irq)
+	if (efx->legacy_irq) {
 		synchronize_irq(efx->legacy_irq);
+		efx->legacy_irq_enabled = false;
+	}
 	if (channel->irq)
 		synchronize_irq(channel->irq);
 
@@ -351,6 +353,8 @@ void efx_process_channel_now(struct efx_channel *channel)
 	efx_channel_processed(channel);
 
 	napi_enable(&channel->napi_str);
+	if (efx->legacy_irq)
+		efx->legacy_irq_enabled = true;
 	efx_nic_enable_interrupts(efx);
 }
 
@@ -1400,6 +1404,8 @@ static void efx_start_all(struct efx_nic *efx)
 		efx_start_channel(channel);
 	}
 
+	if (efx->legacy_irq)
+		efx->legacy_irq_enabled = true;
 	efx_nic_enable_interrupts(efx);
 
 	/* Switch to event based MCDI completions after enabling interrupts.
@@ -1460,8 +1466,10 @@ static void efx_stop_all(struct efx_nic *efx)
 
 	/* Disable interrupts and wait for ISR to complete */
 	efx_nic_disable_interrupts(efx);
-	if (efx->legacy_irq)
+	if (efx->legacy_irq) {
 		synchronize_irq(efx->legacy_irq);
+		efx->legacy_irq_enabled = false;
+	}
 	efx_for_each_channel(channel, efx) {
 		if (channel->irq)
 			synchronize_irq(channel->irq);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 0a7e26d..b137c88 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -621,6 +621,7 @@ struct efx_filter_state;
  * @pci_dev: The PCI device
  * @type: Controller type attributes
  * @legacy_irq: IRQ number
+ * @legacy_irq_enabled: Are IRQs enabled on NIC (INT_EN_KER register)?
  * @workqueue: Workqueue for port reconfigures and the HW monitor.
  *	Work items do not hold and must not acquire RTNL.
  * @workqueue_name: Name of workqueue
@@ -709,6 +710,7 @@ struct efx_nic {
 	struct pci_dev *pci_dev;
 	const struct efx_nic_type *type;
 	int legacy_irq;
+	bool legacy_irq_enabled;
 	struct workqueue_struct *workqueue;
 	char workqueue_name[16];
 	struct work_struct reset_work;
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 41c36b9..67cb0c9 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1418,6 +1418,12 @@ static irqreturn_t efx_legacy_interrupt(int irq, void *dev_id)
 	u32 queues;
 	int syserr;
 
+	/* Could this be ours?  If interrupts are disabled then the
+	 * channel state may not be valid.
+	 */
+	if (!efx->legacy_irq_enabled)
+		return result;
+
 	/* Read the ISR which also ACKs the interrupts */
 	efx_readd(efx, &reg, FR_BZ_INT_ISR0);
 	queues = EFX_EXTRACT_DWORD(reg, 0, 31);
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

