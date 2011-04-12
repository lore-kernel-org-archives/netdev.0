From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 1/3] sfc: Stop the TX queues during loopback
 self-tests
Date: Wed, 13 Apr 2011 00:49:29 +0100
Message-ID: <1302652169.2880.29.camel@bwh-desktop>
References: <1302652065.2880.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12500 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757163Ab1DLXtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:49:31 -0400
In-Reply-To: <1302652065.2880.28.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Turton <nturton@solarflare.com>

If the TX queues are running during loopback self tests, host
traffic gets looped back which causes the test to fail.  Avoid
restarting the TX queues after the port reset so that any packets
sent by the host get held back until after the tests have completed.

[bwh: Also wake all TX queues at the end of self-tests.]

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c      |    2 +-
 drivers/net/sfc/selftest.c |    2 ++
 drivers/net/sfc/tx.c       |    3 ++-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d890679..0dc800b 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1436,7 +1436,7 @@ static void efx_start_all(struct efx_nic *efx)
 	 * restart the transmit interface early so the watchdog timer stops */
 	efx_start_port(efx);
 
-	if (efx_dev_registered(efx))
+	if (efx_dev_registered(efx) && !efx->port_inhibited)
 		netif_tx_wake_all_queues(efx->net_dev);
 
 	efx_for_each_channel(channel, efx)
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index a0f49b3..8458084 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -770,6 +770,8 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	__efx_reconfigure_port(efx);
 	mutex_unlock(&efx->mac_lock);
 
+	netif_tx_wake_all_queues(efx->net_dev);
+
 	return rc_test;
 }
 
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 1398019..d2c85df 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -435,7 +435,8 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	 * queue state. */
 	smp_mb();
 	if (unlikely(netif_tx_queue_stopped(tx_queue->core_txq)) &&
-	    likely(efx->port_enabled)) {
+	    likely(efx->port_enabled) &&
+	    likely(!efx->port_inhibited)) {
 		fill_level = tx_queue->insert_count - tx_queue->read_count;
 		if (fill_level < EFX_TXQ_THRESHOLD(efx)) {
 			EFX_BUG_ON_PARANOID(!efx_dev_registered(efx));
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

