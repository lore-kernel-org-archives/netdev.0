From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/19] sfc: Skip RX end-of-batch work on channels
 without an RX queue
Date: Thu, 16 Feb 2012 00:44:30 +0000
Message-ID: <1329353070.2565.27.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27512 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753354Ab2BPAod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:44:33 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in efx_process_channel() to update the RX queue after each
batch of RX completions works out as a no-op on a TX-only channel
where the RX queue structure is set to all-zeroes, but
(1) efx_channel_get_rx_queue() will BUG() if DEBUG is defined, and
(2) it's a waste of time.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 952d0bf..b7cf9f0 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -224,19 +224,20 @@ static int efx_process_channel(struct efx_channel *channel, int budget)
 		return 0;
 
 	spent = efx_nic_process_eventq(channel, budget);
-	if (spent == 0)
-		return 0;
+	if (spent && efx_channel_has_rx_queue(channel)) {
+		struct efx_rx_queue *rx_queue =
+			efx_channel_get_rx_queue(channel);
+
+		/* Deliver last RX packet. */
+		if (channel->rx_pkt) {
+			__efx_rx_packet(channel, channel->rx_pkt);
+			channel->rx_pkt = NULL;
+		}
 
-	/* Deliver last RX packet. */
-	if (channel->rx_pkt) {
-		__efx_rx_packet(channel, channel->rx_pkt);
-		channel->rx_pkt = NULL;
+		efx_rx_strategy(channel);
+		efx_fast_push_rx_descriptors(rx_queue);
 	}
 
-	efx_rx_strategy(channel);
-
-	efx_fast_push_rx_descriptors(efx_channel_get_rx_queue(channel));
-
 	return spent;
 }
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
