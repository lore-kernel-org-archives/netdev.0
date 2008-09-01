From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 05/52] sfc: Avoid mangling error codes in efx_test_loopback()
Date: Mon, 1 Sep 2008 12:45:08 +0100
Message-ID: <20080901114508.GY7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:49733 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753764AbYIALpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:45:11 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_test_loopback() used "|" to combine the results of the RX and TX
phases.  If both phases fail with different error codes, this results
in a bogus error code.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/selftest.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 0a47786..c79ddce 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -514,7 +514,7 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 	struct efx_nic *efx = tx_queue->efx;
 	struct efx_selftest_state *state = efx->loopback_selftest;
 	struct efx_channel *channel;
-	int i, rc = 0;
+	int i, tx_rc, rx_rc;
 
 	for (i = 0; i < loopback_test_level; i++) {
 		/* Determine how many packets to send */
@@ -531,7 +531,7 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 			state->packet_count);
 
 		efx_iterate_state(efx);
-		rc = efx_tx_loopback(tx_queue);
+		tx_rc = efx_tx_loopback(tx_queue);
 		
 		/* NAPI polling is not enabled, so process channels synchronously */
 		schedule_timeout_uninterruptible(HZ / 50);
@@ -540,14 +540,14 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 				efx_process_channel_now(channel);
 		}
 
-		rc |= efx_rx_loopback(tx_queue, lb_tests);
+		rx_rc = efx_rx_loopback(tx_queue, lb_tests);
 		kfree(state->skbs);
 
-		if (rc) {
+		if (tx_rc || rx_rc) {
 			/* Wait a while to ensure there are no packets
 			 * floating around after a failure. */
 			schedule_timeout_uninterruptible(HZ / 10);
-			return rc;
+			return tx_rc ? tx_rc : rx_rc;
 		}
 	}
 
@@ -555,7 +555,7 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 		"of %d packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
 		state->packet_count);
 
-	return rc;
+	return 0;
 }
 
 static int efx_test_loopbacks(struct efx_nic *efx,
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

