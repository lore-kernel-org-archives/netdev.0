From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/52] sfc: Self-test reporting cleanup
Date: Mon, 1 Sep 2008 12:46:28 +0100
Message-ID: <20080901114628.GF7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:35810 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755917AbYIALqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:46:30 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed log messages that are redundant with calling functions.
Fixed bitwise or-ing of return codes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/selftest.c |   42 ++++++++++++++++--------------------------
 1 files changed, 16 insertions(+), 26 deletions(-)

diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index c79ddce..8ad517c 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -566,8 +566,8 @@ static int efx_test_loopbacks(struct efx_nic *efx,
 	struct ethtool_cmd ecmd, ecmd_loopback;
 	struct efx_tx_queue *tx_queue;
 	enum efx_loopback_mode old_mode, mode;
-	int count, rc = 0, link_up;
-	
+	int count, rc, link_up;
+
 	rc = efx_ethtool_get_settings(efx->net_dev, &ecmd);
 	if (rc) {
 		EFX_ERR(efx, "could not get GMII settings\n");
@@ -641,8 +641,8 @@ static int efx_test_loopbacks(struct efx_nic *efx,
 		efx_for_each_tx_queue(tx_queue, efx) {
 			state->offload_csum = (tx_queue->queue ==
 					       EFX_TX_QUEUE_OFFLOAD_CSUM);
-			rc |= efx_test_loopback(tx_queue,
-						&tests->loopback[mode]);
+			rc = efx_test_loopback(tx_queue,
+					       &tests->loopback[mode]);
 			if (rc)
 				goto out;
 		}
@@ -668,22 +668,20 @@ static int efx_test_loopbacks(struct efx_nic *efx,
 int efx_online_test(struct efx_nic *efx, struct efx_self_tests *tests)
 {
 	struct efx_channel *channel;
-	int rc = 0;
+	int rc;
 
-	EFX_LOG(efx, "performing online self-tests\n");
-
-	rc |= efx_test_interrupts(efx, tests);
+	rc = efx_test_interrupts(efx, tests);
+	if (rc)
+		return rc;
 	efx_for_each_channel(channel, efx) {
 		if (channel->has_interrupt)
-			rc |= efx_test_eventq_irq(channel, tests);
+			rc = efx_test_eventq_irq(channel, tests);
 		else
-			rc |= efx_test_eventq(channel, tests);
+			rc = efx_test_eventq(channel, tests);
+		if (rc)
+			return rc;
 	}
-	rc |= efx_test_phy(efx, tests);
-
-	if (rc)
-		EFX_ERR(efx, "failed online self-tests\n");
-
+	rc = efx_test_phy(efx, tests);
 	return rc;
 }
 
@@ -693,16 +691,12 @@ int efx_offline_test(struct efx_nic *efx,
 		     struct efx_self_tests *tests, unsigned int loopback_modes)
 {
 	struct efx_selftest_state *state;
-	int rc = 0;
-
-	EFX_LOG(efx, "performing offline self-tests\n");
+	int rc;
 
 	/* Create a selftest_state structure to hold state for the test */
 	state = kzalloc(sizeof(*state), GFP_KERNEL);
-	if (state == NULL) {
-		rc = -ENOMEM;
-		goto out;
-	}
+	if (state == NULL)
+		return -ENOMEM;
 
 	/* Set the port loopback_selftest member. From this point on
 	 * all received packets will be dropped. Mark the state as
@@ -717,10 +711,6 @@ int efx_offline_test(struct efx_nic *efx,
 	wmb();
 	kfree(state);
 
- out:
-	if (rc)
-		EFX_ERR(efx, "failed offline self-tests\n");
-
 	return rc;
 }
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

