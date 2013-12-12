From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/16] sfc: Tighten the check for RX merged
 completion events
Date: Thu, 12 Dec 2013 23:00:18 +0000
Message-ID: <1386889218.1516.341.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43709 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab3LLXAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:00:22 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The addition of RX event merging support means we don't reliably
detect dropped RX events now.  Currently we will only detect them if
the previous event for the RX queue had the CONT bit set.

Only accept RX completion events as merged if the
GET_CAPABILITIES_OUT_RX_BATCHING bit is set in datapath_caps (which it
won't be for the low-latency datapath) and the CONT bit is not set on
the event.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 5d46d155b642..2f77359607d2 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1766,6 +1766,8 @@ static int efx_ef10_handle_rx_event(struct efx_channel *channel,
 		   ((1 << ESF_DZ_RX_DSC_PTR_LBITS_WIDTH) - 1));
 
 	if (n_descs != rx_queue->scatter_n + 1) {
+		struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
 		/* detect rx abort */
 		if (unlikely(n_descs == rx_queue->scatter_n)) {
 			WARN_ON(rx_bytes != 0);
@@ -1773,10 +1775,13 @@ static int efx_ef10_handle_rx_event(struct efx_channel *channel,
 			return 0;
 		}
 
-		if (unlikely(rx_queue->scatter_n != 0)) {
-			/* Scattered packet completions cannot be
-			 * merged, so something has gone wrong.
-			 */
+		/* Check that RX completion merging is valid, i.e.
+		 * the current firmware supports it and this is a
+		 * non-scattered packet.
+		 */
+		if (!(nic_data->datapath_caps &
+		      (1 << MC_CMD_GET_CAPABILITIES_OUT_RX_BATCHING_LBN)) ||
+		    rx_queue->scatter_n != 0 || rx_cont) {
 			efx_ef10_handle_rx_bad_lbits(
 				rx_queue, next_ptr_lbits,
 				(rx_queue->removed_count +


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
