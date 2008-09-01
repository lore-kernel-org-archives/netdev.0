From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 13/52] sfc: Speed up loopback self-test
Date: Mon, 1 Sep 2008 12:46:33 +0100
Message-ID: <20080901114632.GG7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:33920 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756269AbYIALqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:46:35 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add efx_poll_loopback() function to test for successful completion of test.
Change efx_test_loopback() to end the test after 1 ms if
efx_poll_loopback() indicates success, and otherwise to wait for 100 ms
as before.

While we're here, rename efx_{rx,tx}_loopback() to
efx_{begin,end}_loopback() which more accurately reflect their
purpose.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/selftest.c |   44 +++++++++++++++++++++++++++++---------------
 1 files changed, 29 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 8ad517c..53fa4ed 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -400,7 +400,7 @@ static void efx_iterate_state(struct efx_nic *efx)
 	smp_wmb();
 }
 
-static int efx_tx_loopback(struct efx_tx_queue *tx_queue)
+static int efx_begin_loopback(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	struct efx_selftest_state *state = efx->loopback_selftest;
@@ -449,8 +449,22 @@ static int efx_tx_loopback(struct efx_tx_queue *tx_queue)
 	return 0;
 }
 
-static int efx_rx_loopback(struct efx_tx_queue *tx_queue,
-			   struct efx_loopback_self_tests *lb_tests)
+static int efx_poll_loopback(struct efx_nic *efx)
+{
+	struct efx_selftest_state *state = efx->loopback_selftest;
+	struct efx_channel *channel;
+
+	/* NAPI polling is not enabled, so process channels
+	 * synchronously */
+	efx_for_each_channel_with_interrupt(channel, efx) {
+		if (channel->work_pending)
+			efx_process_channel_now(channel);
+	}
+	return atomic_read(&state->rx_good) == state->packet_count;
+}
+
+static int efx_end_loopback(struct efx_tx_queue *tx_queue,
+			    struct efx_loopback_self_tests *lb_tests)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	struct efx_selftest_state *state = efx->loopback_selftest;
@@ -513,8 +527,7 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 {
 	struct efx_nic *efx = tx_queue->efx;
 	struct efx_selftest_state *state = efx->loopback_selftest;
-	struct efx_channel *channel;
-	int i, tx_rc, rx_rc;
+	int i, begin_rc, end_rc;
 
 	for (i = 0; i < loopback_test_level; i++) {
 		/* Determine how many packets to send */
@@ -531,23 +544,24 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 			state->packet_count);
 
 		efx_iterate_state(efx);
-		tx_rc = efx_tx_loopback(tx_queue);
-		
-		/* NAPI polling is not enabled, so process channels synchronously */
-		schedule_timeout_uninterruptible(HZ / 50);
-		efx_for_each_channel_with_interrupt(channel, efx) {
-			if (channel->work_pending)
-				efx_process_channel_now(channel);
+		begin_rc = efx_begin_loopback(tx_queue);
+
+		/* This will normally complete very quickly, but be
+		 * prepared to wait up to 100 ms. */
+		msleep(1);
+		if (!efx_poll_loopback(efx)) {
+			msleep(100);
+			efx_poll_loopback(efx);
 		}
 
-		rx_rc = efx_rx_loopback(tx_queue, lb_tests);
+		end_rc = efx_end_loopback(tx_queue, lb_tests);
 		kfree(state->skbs);
 
-		if (tx_rc || rx_rc) {
+		if (begin_rc || end_rc) {
 			/* Wait a while to ensure there are no packets
 			 * floating around after a failure. */
 			schedule_timeout_uninterruptible(HZ / 10);
-			return tx_rc ? tx_rc : rx_rc;
+			return begin_rc ? begin_rc : end_rc;
 		}
 	}
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

