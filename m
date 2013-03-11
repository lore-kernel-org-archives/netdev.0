From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/22] sfc: Allow efx_channel_type::receive_skb()
 to reject a packet
Date: Mon, 11 Mar 2013 19:53:11 +0000
Message-ID: <1363031591.2608.38.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>,
	Laurence Evans <levans@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16690 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab3CKTxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:53:15 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having efx_ptp_rx() call netif_receive_skb() for an invalid
PTP packet, make it return false for rejected packets and have
efx_rx_deliver() pass them up.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    2 +-
 drivers/net/ethernet/sfc/ptp.c        |   16 +++++++---------
 drivers/net/ethernet/sfc/rx.c         |   10 ++++++----
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 0a90abd..cdcf510 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -410,7 +410,7 @@ struct efx_channel_type {
 	void (*post_remove)(struct efx_channel *);
 	void (*get_name)(struct efx_channel *, char *buf, size_t len);
 	struct efx_channel *(*copy)(const struct efx_channel *);
-	void (*receive_skb)(struct efx_channel *, struct sk_buff *);
+	bool (*receive_skb)(struct efx_channel *, struct sk_buff *);
 	bool keep_eventq;
 };
 
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 3f93624..faf4baf 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1006,7 +1006,7 @@ bool efx_ptp_is_ptp_tx(struct efx_nic *efx, struct sk_buff *skb)
  * the receive timestamp from the MC - this will probably occur after the
  * packet arrival because of the processing in the MC.
  */
-static void efx_ptp_rx(struct efx_channel *channel, struct sk_buff *skb)
+static bool efx_ptp_rx(struct efx_channel *channel, struct sk_buff *skb)
 {
 	struct efx_nic *efx = channel->efx;
 	struct efx_ptp_data *ptp = efx->ptp_data;
@@ -1019,18 +1019,15 @@ static void efx_ptp_rx(struct efx_channel *channel, struct sk_buff *skb)
 	/* Correct version? */
 	if (ptp->mode == MC_CMD_PTP_MODE_V1) {
 		if (skb->len < PTP_V1_MIN_LENGTH) {
-			netif_receive_skb(skb);
-			return;
+			return false;
 		}
 		version = ntohs(*(__be16 *)&skb->data[PTP_V1_VERSION_OFFSET]);
 		if (version != PTP_VERSION_V1) {
-			netif_receive_skb(skb);
-			return;
+			return false;
 		}
 	} else {
 		if (skb->len < PTP_V2_MIN_LENGTH) {
-			netif_receive_skb(skb);
-			return;
+			return false;
 		}
 		version = skb->data[PTP_V2_VERSION_OFFSET];
 
@@ -1041,8 +1038,7 @@ static void efx_ptp_rx(struct efx_channel *channel, struct sk_buff *skb)
 		BUILD_BUG_ON(PTP_V1_SEQUENCE_LENGTH != PTP_V2_SEQUENCE_LENGTH);
 
 		if ((version & PTP_VERSION_V2_MASK) != PTP_VERSION_V2) {
-			netif_receive_skb(skb);
-			return;
+			return false;
 		}
 	}
 
@@ -1073,6 +1069,8 @@ static void efx_ptp_rx(struct efx_channel *channel, struct sk_buff *skb)
 
 	skb_queue_tail(&ptp->rxq, skb);
 	queue_work(ptp->workwq, &ptp->work);
+
+	return true;
 }
 
 /* Transmit a PTP packet.  This has to be transmitted by the MC
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index bb579a6..f31c23e 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -575,12 +575,14 @@ static void efx_rx_deliver(struct efx_channel *channel,
 	/* Record the rx_queue */
 	skb_record_rx_queue(skb, channel->rx_queue.core_index);
 
-	/* Pass the packet up */
 	if (channel->type->receive_skb)
-		channel->type->receive_skb(channel, skb);
-	else
-		netif_receive_skb(skb);
+		if (channel->type->receive_skb(channel, skb))
+			goto handled;
+
+	/* Pass the packet up */
+	netif_receive_skb(skb);
 
+handled:
 	/* Update allocation strategy method */
 	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
 }
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
