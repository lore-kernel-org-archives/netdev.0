From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/3] sfc: Fix TX queue numbering when
 separate_tx_channels=1
Date: Tue, 17 May 2011 17:05:04 +0100
Message-ID: <1305648304.2848.16.camel@bwh-desktop>
References: <1305647988.2848.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26403 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755345Ab1EQQFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 12:05:08 -0400
In-Reply-To: <1305647988.2848.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This option appears to have been broken by commit
8313aca38b3937947fffebca6e34bac8e24300c8 ('sfc: Allocate each channel
separately, along with its RX and TX queues').

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 38a55e9..796c47e 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1319,8 +1319,20 @@ static void efx_remove_interrupts(struct efx_nic *efx)
 
 static void efx_set_channels(struct efx_nic *efx)
 {
+	struct efx_channel *channel;
+	struct efx_tx_queue *tx_queue;
+
 	efx->tx_channel_offset =
 		separate_tx_channels ? efx->n_channels - efx->n_tx_channels : 0;
+
+	/* We need to adjust the TX queue numbers if we have separate
+	 * RX-only and TX-only channels.
+	 */
+	efx_for_each_channel(channel, efx) {
+		efx_for_each_channel_tx_queue(tx_queue, channel)
+			tx_queue->queue -= (efx->tx_channel_offset *
+					    EFX_TXQ_TYPES);
+	}
 }
 
 static int efx_probe_nic(struct efx_nic *efx)
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

