From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/7] sfc: Allow resets to be upgraded; use
 atomic ops for safety
Date: Thu, 14 Jul 2011 02:16:46 +0100
Message-ID: <1310606206.2756.25.camel@bwh-desktop>
References: <1310606090.2756.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:11193 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008Ab1GNBQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 21:16:53 -0400
In-Reply-To: <1310606090.2756.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently an attempt to schedule any reset is ignored if a reset
is already pending.  This ignores the relative scopes - if the
requested reset is greater in scope then the scheduled reset should
be upgraded accordingly.

There are also some race conditions which could lead to a reset
request being lost.  Deal with them by using atomic operations on a
bitmask.  This also makes tests on reset_pending easier to get right.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   38 +++++++++++++++++---------------------
 drivers/net/sfc/enum.h       |    3 ++-
 drivers/net/sfc/falcon.c     |    2 +-
 drivers/net/sfc/net_driver.h |    4 ++--
 4 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index c914729..9b4cfdb 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -229,8 +229,7 @@ static int efx_process_channel(struct efx_channel *channel, int budget)
 	struct efx_nic *efx = channel->efx;
 	int spent;
 
-	if (unlikely(efx->reset_pending != RESET_TYPE_NONE ||
-		     !channel->enabled))
+	if (unlikely(efx->reset_pending || !channel->enabled))
 		return 0;
 
 	spent = efx_nic_process_eventq(channel, budget);
@@ -1461,7 +1460,7 @@ static void efx_start_all(struct efx_nic *efx)
 	 * reset_pending [modified from an atomic context], we instead guarantee
 	 * that efx_mcdi_mode_poll() isn't reverted erroneously */
 	efx_mcdi_mode_event(efx);
-	if (efx->reset_pending != RESET_TYPE_NONE)
+	if (efx->reset_pending)
 		efx_mcdi_mode_poll(efx);
 
 	/* Start the hardware monitor if there is one. Otherwise (we're link
@@ -2118,8 +2117,10 @@ int efx_reset(struct efx_nic *efx, enum reset_type method)
 		goto out;
 	}
 
-	/* Allow resets to be rescheduled. */
-	efx->reset_pending = RESET_TYPE_NONE;
+	/* Clear flags for the scopes we covered.  We assume the NIC and
+	 * driver are now quiescent so that there is no race here.
+	 */
+	efx->reset_pending &= -(1 << (method + 1));
 
 	/* Reinitialise bus-mastering, which may have been turned off before
 	 * the reset was scheduled. This is still appropriate, even in the
@@ -2154,12 +2155,13 @@ out:
 static void efx_reset_work(struct work_struct *data)
 {
 	struct efx_nic *efx = container_of(data, struct efx_nic, reset_work);
+	unsigned long pending = ACCESS_ONCE(efx->reset_pending);
 
-	if (efx->reset_pending == RESET_TYPE_NONE)
+	if (!pending)
 		return;
 
 	/* If we're not RUNNING then don't reset. Leave the reset_pending
-	 * flag set so that efx_pci_probe_main will be retried */
+	 * flags set so that efx_pci_probe_main will be retried */
 	if (efx->state != STATE_RUNNING) {
 		netif_info(efx, drv, efx->net_dev,
 			   "scheduled reset quenched. NIC not RUNNING\n");
@@ -2167,7 +2169,7 @@ static void efx_reset_work(struct work_struct *data)
 	}
 
 	rtnl_lock();
-	(void)efx_reset(efx, efx->reset_pending);
+	(void)efx_reset(efx, fls(pending) - 1);
 	rtnl_unlock();
 }
 
@@ -2175,12 +2177,6 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 {
 	enum reset_type method;
 
-	if (efx->reset_pending != RESET_TYPE_NONE) {
-		netif_info(efx, drv, efx->net_dev,
-			   "quenching already scheduled reset\n");
-		return;
-	}
-
 	switch (type) {
 	case RESET_TYPE_INVISIBLE:
 	case RESET_TYPE_ALL:
@@ -2208,7 +2204,7 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 		netif_dbg(efx, drv, efx->net_dev, "scheduling %s reset\n",
 			  RESET_TYPE(method));
 
-	efx->reset_pending = method;
+	set_bit(method, &efx->reset_pending);
 
 	/* efx_process_channel() will no longer read events once a
 	 * reset is scheduled. So switch back to poll'd MCDI completions. */
@@ -2288,7 +2284,6 @@ static int efx_init_struct(struct efx_nic *efx, const struct efx_nic_type *type,
 	efx->pci_dev = pci_dev;
 	efx->msg_enable = debug;
 	efx->state = STATE_INIT;
-	efx->reset_pending = RESET_TYPE_NONE;
 	strlcpy(efx->name, pci_name(pci_dev), sizeof(efx->name));
 
 	efx->net_dev = net_dev;
@@ -2510,7 +2505,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 		cancel_work_sync(&efx->reset_work);
 
 		if (rc == 0) {
-			if (efx->reset_pending != RESET_TYPE_NONE) {
+			if (efx->reset_pending) {
 				/* If there was a scheduled reset during
 				 * probe, the NIC is probably hosed anyway */
 				efx_pci_remove_main(efx);
@@ -2521,11 +2516,12 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 		}
 
 		/* Retry if a recoverably reset event has been scheduled */
-		if ((efx->reset_pending != RESET_TYPE_INVISIBLE) &&
-		    (efx->reset_pending != RESET_TYPE_ALL))
+		if (efx->reset_pending &
+		    ~(1 << RESET_TYPE_INVISIBLE | 1 << RESET_TYPE_ALL) ||
+		    !efx->reset_pending)
 			goto fail3;
 
-		efx->reset_pending = RESET_TYPE_NONE;
+		efx->reset_pending = 0;
 	}
 
 	if (rc) {
@@ -2609,7 +2605,7 @@ static int efx_pm_poweroff(struct device *dev)
 
 	efx->type->fini(efx);
 
-	efx->reset_pending = RESET_TYPE_NONE;
+	efx->reset_pending = 0;
 
 	pci_save_state(pci_dev);
 	return pci_set_power_state(pci_dev, PCI_D3hot);
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index 384cfe3..d725a8f 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -134,6 +134,8 @@ enum efx_loopback_mode {
  * other valuesspecify reasons, which efx_schedule_reset() will choose
  * a method for.
  *
+ * Reset methods are numbered in order of increasing scope.
+ *
  * @RESET_TYPE_INVISIBLE: don't reset the PHYs or interrupts
  * @RESET_TYPE_ALL: reset everything but PCI core blocks
  * @RESET_TYPE_WORLD: reset everything, save & restore PCI config
@@ -147,7 +149,6 @@ enum efx_loopback_mode {
  * @RESET_TYPE_MC_FAILURE: MC reboot/assertion
  */
 enum reset_type {
-	RESET_TYPE_NONE = -1,
 	RESET_TYPE_INVISIBLE = 0,
 	RESET_TYPE_ALL = 1,
 	RESET_TYPE_WORLD = 2,
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 60176e8..a4c7830 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -536,7 +536,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	efx_oword_t reg;
 	int link_speed, isolate;
 
-	isolate = (efx->reset_pending != RESET_TYPE_NONE);
+	isolate = !!ACCESS_ONCE(efx->reset_pending);
 
 	switch (link_state->speed) {
 	case 10000: link_speed = 3; break;
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index e8d5f03..c422eb2 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -645,7 +645,7 @@ struct efx_filter_state;
  * @irq_rx_moderation: IRQ moderation time for RX event queues
  * @msg_enable: Log message enable flags
  * @state: Device state flag. Serialised by the rtnl_lock.
- * @reset_pending: Pending reset method (normally RESET_TYPE_NONE)
+ * @reset_pending: Bitmask for pending resets
  * @tx_queue: TX DMA queues
  * @rx_queue: RX DMA queues
  * @channel: Channels
@@ -728,7 +728,7 @@ struct efx_nic {
 	u32 msg_enable;
 
 	enum nic_state state;
-	enum reset_type reset_pending;
+	unsigned long reset_pending;
 
 	struct efx_channel *channel[EFX_MAX_CHANNELS];
 	char channel_name[EFX_MAX_CHANNELS][IFNAMSIZ + 6];
-- 
1.7.4.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

