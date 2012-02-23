From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 5/5] sfc: Correct
 efx_for_each_possible_channel_tx_queue() to skip non-TX channels
Date: Thu, 23 Feb 2012 17:41:56 +0000
Message-ID: <1330018916.2511.6.camel@bwh-desktop>
References: <1330018734.2511.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7318 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752154Ab2BWRmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 12:42:00 -0500
In-Reply-To: <1330018734.2511.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_for_each_possible_channel_tx_queue() should do nothing for RX-only
or extra channels.  The current definition results in allocating
additional unused hardware TX queues when using the mqprio qdisc and
either separate_tx_channels or SR-IOV.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 3fbec45..0b95505 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1030,9 +1030,12 @@ static inline bool efx_tx_queue_used(struct efx_tx_queue *tx_queue)
 
 /* Iterate over all possible TX queues belonging to a channel */
 #define efx_for_each_possible_channel_tx_queue(_tx_queue, _channel)	\
-	for (_tx_queue = (_channel)->tx_queue;				\
-	     _tx_queue < (_channel)->tx_queue + EFX_TXQ_TYPES;		\
-	     _tx_queue++)
+	if (!efx_channel_has_tx_queues(_channel))			\
+		;							\
+	else								\
+		for (_tx_queue = (_channel)->tx_queue;			\
+		     _tx_queue < (_channel)->tx_queue + EFX_TXQ_TYPES;	\
+		     _tx_queue++)
 
 static inline bool efx_channel_has_rx_queue(struct efx_channel *channel)
 {
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
