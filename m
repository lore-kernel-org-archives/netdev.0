From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/16] sfc: Correct and expand some comments
Date: Fri, 16 May 2008 21:18:14 +0100
Message-ID: <20080516201814.GB28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53550 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760420AbYEPUTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:19:13 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These comments have been revised in response to questions raised by Andrew
Morton in <20080501120858.207b6dd6.akpm@linux-foundation.org>.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index f6131e5..11ee0d4 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -199,11 +199,12 @@ static inline int efx_process_channel(struct efx_channel *channel, int rx_quota)
  */
 static inline void efx_channel_processed(struct efx_channel *channel)
 {
-	/* Write to EVQ_RPTR_REG.  If a new event arrived in a race
-	 * with finishing processing, a new interrupt will be raised.
-	 */
+	/* The interrupt handler for this channel may set work_pending
+	 * as soon as we acknowledge the events we've seen.  Make sure
+	 * it's cleared before then. */
 	channel->work_pending = 0;
-	smp_wmb(); /* Ensure channel updated before any new interrupt. */
+	smp_wmb();
+
 	falcon_eventq_read_ack(channel);
 }
 
@@ -427,9 +428,12 @@ static void efx_start_channel(struct efx_channel *channel)
 		netif_napi_add(channel->napi_dev, &channel->napi_str,
 			       efx_poll, napi_weight);
 
+	/* The interrupt handler for this channel may set work_pending
+	 * as soon as we enable it.  Make sure it's cleared before
+	 * then.  Similarly, make sure it sees the enabled flag set. */
 	channel->work_pending = 0;
 	channel->enabled = 1;
-	smp_wmb(); /* ensure channel updated before first interrupt */
+	smp_wmb();
 
 	napi_enable(&channel->napi_str);
 
@@ -1332,13 +1336,17 @@ static int efx_net_stop(struct net_device *net_dev)
 	return 0;
 }
 
-/* Context: process, dev_base_lock held, non-blocking. */
+/* Context: process, dev_base_lock or RTNL held, non-blocking. */
 static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
 {
 	struct efx_nic *efx = net_dev->priv;
 	struct efx_mac_stats *mac_stats = &efx->mac_stats;
 	struct net_device_stats *stats = &net_dev->stats;
 
+	/* Update stats if possible, but do not wait if another thread
+	 * is updating them (or resetting the NIC); slightly stale
+	 * stats are acceptable.
+	 */
 	if (!spin_trylock(&efx->stats_lock))
 		return stats;
 	if (efx->state == STATE_RUNNING) {

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
